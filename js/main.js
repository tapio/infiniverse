/*jshint browser:true trailing:true latedef:true */

var term, eng; // Can't be initialized yet because DOM is not ready
var universe;

var pl = new Ship(30, 50);

var messages = [];
var maxMessages = 3;

var activeMenu = "";

function addMessage(msg, msgtype) {
	msgtype = msgtype || "info";
	if (messages.length && messages[messages.length-1].text === msg)
		messages[messages.length-1].count++;
	else messages.push({ text: msg, type: msgtype, count: 1 });
	if (messages.length > maxMessages) messages.splice(0, messages.length - maxMessages);
	var msgs = "", last = messages.length-1, color, fadefactor, r, g, b, mult;
	var colors = { info: {r:80,g:80,b:255}, action: {r:150,g:0,b:250}, error: {r:255,g:80,b:80} };
	for (var i = last; i >= 0; --i) {
		color = colors[messages[i].type];
		fadefactor = (last-i)/3 + 1;
		r = Math.floor(color.r / fadefactor);
		g = Math.floor(color.g / fadefactor);
		b = Math.floor(color.b / fadefactor);
		if (messages[i].count > 1) mult = " x" + messages[i].count;
		else mult = "";
		msgs += '<span style="color: rgb('+r+','+g+','+b+');">'+messages[i].text+mult+'</span><br/>';
		if (i == messages.length-1) msgs = '<span style="font-size:1.1em">'+msgs+'</span>';
	}
	$("#messages").html(msgs);
}

// "Main loop"
function tick() {
	var i, a, item, len, fg, bg, tilex, tiley;
	universe.updateActors();
	pl.updateUI();
	var camx = clamp(pl.x - term.cx, 0, universe.current.size - term.w);
	var camy = clamp(pl.y - term.cy, 0, universe.current.size - term.h);
	eng.update(camx + term.cx, camy + term.cy); // Update tiles
	// Collectables
	var items = universe.getItems();
	len = items ? items.length : 0;
	for (i = 0; i < len; ++i) {
		item = items[i];
		tilex = item.x - camx;
		tiley = item.y - camy;
		fg = item.tile;
		bg = term.get(tilex, tiley).getBackgroundJSON(); // Background color
		term.put(new ut.Tile(fg.ch, fg.r, fg.g, fg.b, bg.r, bg.g, bg.b), tilex, tiley);
		if (item.x === pl.x && item.y === pl.y) {
			addMessage("Collect " + item.tile.desc.toLowerCase() + " with [Space].");
		}
	}
	// Actors
	len = universe.actors.length;
	for (i = 0; i < len; ++i) {
		a = universe.actors[i];
		if (!a.getTile) continue;
		tilex = a.x - camx;
		tiley = a.y - camy;
		fg = a.getTile(); // Actor tile
		bg = term.get(tilex, tiley).getBackgroundJSON(); // Background color
		term.put(new ut.Tile(fg.ch, fg.r, fg.g, fg.b, bg.r, bg.g, bg.b), tilex, tiley);
	}
	term.render(); // Render
}

function toggleMenu(menuid) {
	var ids = [ "#beacon-menu", "#energyconverter-menu", "#massfabricator-menu" ];
	for (var i = 0; i < ids.length; ++i) {
		var elem = $(ids[i]);
		var visible = elem.is(":visible");
		if (menuid == ids[i] && !visible) {
			elem.show("blind", 500);
			elem.parent().parent().children("span").first().attr("class", "online");
		} else if (visible) {
			elem.hide("blind", 500);
			elem.parent().parent().children("span").first().attr("class", "");
		}
	}
	if (activeMenu === menuid) activeMenu = "";
	else activeMenu = menuid;
	// Trigger targetlist closing
	if (menuid !== "#targetlist") pl.targets = [];
	else activeMenu = "#targetlist";
	// Add help message
	if (menuid === "#beacon-menu") addMessage("Press a number to jump to that navbeacon.", "action");
	if (menuid === "#energyconverter-menu") addMessage("Press a number to convert the corresponding mass to energy.", "action");
	if (menuid === "#massfabricator-menu") addMessage("Press a number to create the corresponding item.", "action");
}

// Key press handler - movement & collision handling
function onKeyDown(k) {
	var movedir = { x: 0, y: 0 }; // Movement vector
	var doTick = false;
	if (k === ut.KEY_LEFT || k === ut.KEY_H || k === ut.KEY_NUMPAD4) movedir.x = -1;
	else if (k === ut.KEY_RIGHT || k === ut.KEY_L || k === ut.KEY_NUMPAD6) movedir.x = 1;
	else if (k === ut.KEY_UP || k === ut.KEY_K || k === ut.KEY_NUMPAD8) movedir.y = -1;
	else if (k === ut.KEY_DOWN || k === ut.KEY_J || k === ut.KEY_NUMPAD2) movedir.y = 1;
	else if (k === ut.KEY_Y || k === ut.KEY_NUMPAD7) { movedir.x = -1; movedir.y = -1; }
	else if (k === ut.KEY_U || k === ut.KEY_NUMPAD9) { movedir.x = 1; movedir.y = -1; }
	else if (k === ut.KEY_B || k === ut.KEY_NUMPAD1) { movedir.x = -1; movedir.y = 1; }
	else if (k === ut.KEY_N || k === ut.KEY_NUMPAD3) { movedir.x = 1; movedir.y = 1; }
	if (k === ut.KEY_PERIOD) { tick(); return; }
	if (k === ut.KEY_ENTER) { pl.enter(); doTick = true; }
	if (k === ut.KEY_BACKSPACE) { pl.exit(); doTick = true; }
	if (k === ut.KEY_SPACE) { pl.collect(); doTick = true; }
	if (k === ut.KEY_TAB) { pl.scanSensors(); doTick = true; }
	if (k === ut.KEY_S) pl.toggleSensors();
	if (k === ut.KEY_F1) $(".help").toggle("blind", 500);
	if (k === ut.KEY_G) toggleMenu("#beacon-menu");
	if (k === ut.KEY_E) toggleMenu("#energyconverter-menu");
	if (k === ut.KEY_F) toggleMenu("#massfabricator-menu");
	if (k === ut.KEY_D) { pl.deployBeacon(); doTick = true; }
	if (k === ut.KEY_M) {
		if (pl.prepareMissile()) toggleMenu("#targetlist");
	}
	if (k >= ut.KEY_1 && k <= ut.KEY_9) {
		if (activeMenu === "#targetlist") { pl.launchMissile(k - ut.KEY_1); doTick = true; }
		else if (activeMenu === "#beacon-menu") { pl.gotoBeacon(k - ut.KEY_1); doTick = true; }
		else if (activeMenu === "#energyconverter-menu") { pl.createEnergy(k - ut.KEY_1 + 1); doTick = true; }
		else if (activeMenu === "#massfabricator-menu") { pl.createMass(k - ut.KEY_1 + 1); doTick = true; }
	}
	if (k === ut.KEY_R) term.setRenderer(term.getRendererString() === "dom" ? "canvas" : "dom");
	if (movedir.x !== 0 || movedir.y !== 0) {
		pl.move(movedir.x, movedir.y, ut.isKeyPressed(ut.KEY_SHIFT));
		doTick = true;
	}
	if (doTick) tick();
	else pl.updateUI();
}

function onKeyUp(k) {
	pl.updateUI();
}

// Initialize stuff
function init() {
	term = new ut.Viewport(document.getElementById("game"), 37, 37, "auto", true);
	eng = new ut.Engine(term);
	universe = new Universe(eng); // Also sets the tile function to Engine
	universe.enter(pl);
	ut.initInput(onKeyDown, onKeyUp);
	tick();
	addMessage("");
	addMessage("Locate the ancient alien knowledge.");
	addMessage("Welcome to Infiniverse. Press F1 for help.");
	$("#wrap").fadeIn(500);
	$("#starthelp").fadeOut(5000);
}
