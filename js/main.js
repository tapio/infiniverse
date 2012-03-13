/*jshint browser:true trailing:true latedef:true */

var term, eng; // Can't be initialized yet because DOM is not ready
var universe;

var pl = new Ship(40,40);

var messages = [];
var maxMessages = 3;

var activeMenu = "";

function addMessage(msg, msgtype) {
	msgtype = msgtype || "info";
	messages.push({ text: msg, type: msgtype });
	if (messages.length > maxMessages) messages.splice(0, messages.length - maxMessages);
	var msgs = "", last = messages.length-1, color, fadefactor, r, g, b;
	var colors = { info: {r:80,g:80,b:255}, error: {r:255,g:80,b:80} };
	for (var i = last; i >= 0; --i) {
		color = colors[messages[i].type];
		fadefactor = (last-i)/3 + 1;
		r = Math.floor(color.r / fadefactor);
		g = Math.floor(color.g / fadefactor);
		b = Math.floor(color.b / fadefactor);
		msgs += '<span style="color: rgb('+r+','+g+','+b+');">'+messages[i].text+'</span><br/>';
		if (i == messages.length-1) msgs = '<span style="font-size:1.1em">'+msgs+'</span>';
	}
	$("#messages").html(msgs);
}

// "Main loop"
function tick() {
	pl.updateUI();
	eng.update(pl.x, pl.y); // Update tiles
	// Player character
	var bg = term.get(term.cx, term.cy).getBackgroundJSON();
	term.unsafePut(new ut.Tile("@", 200,200,200, bg.r, bg.g, bg.b), term.cx, term.cy);
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
}

// Key press handler - movement & collision handling
function onKeyDown(k) {
	var movedir = { x: 0, y: 0 }; // Movement vector
	if (k === ut.KEY_LEFT || k === ut.KEY_H) movedir.x = -1;
	else if (k === ut.KEY_RIGHT || k === ut.KEY_L) movedir.x = 1;
	else if (k === ut.KEY_UP || k === ut.KEY_K) movedir.y = -1;
	else if (k === ut.KEY_DOWN || k === ut.KEY_J) movedir.y = 1;
	if (k === ut.KEY_ENTER) universe.enter(pl.x, pl.y);
	if (k === ut.KEY_BACKSPACE) universe.exit();
	if (k === ut.KEY_TAB) pl.toggleSensors();
	if (k === ut.KEY_G) toggleMenu("#beacon-menu");
	if (k === ut.KEY_E) toggleMenu("#energyconverter-menu");
	if (k === ut.KEY_M) toggleMenu("#massfabricator-menu");
	if (k === ut.KEY_B) pl.deployBeacon();
	if (k === ut.KEY_T) pl.launchTorpedo();
	if (movedir.x !== 0 || movedir.y !== 0)
		pl.move(movedir.x, movedir.y, ut.isKeyPressed(ut.KEY_SHIFT));
	tick();
}

function onKeyUp(k) {
	if (k === ut.KEY_SHIFT) tick();
}

// Initialize stuff
function init() {
	term = new ut.Viewport(document.getElementById("game"), 55, 31);
	eng = new ut.Engine(term);
	universe = new Universe(eng); // Also sets the tile function to Engine
	ut.initInput(onKeyDown, onKeyUp);
	tick();
	addMessage("Press F1 for help.");
	addMessage("Locate the ancient alien knowledge.");
	addMessage("Welcome to Infiniverse.");
	$("#wrap").fadeIn(500);
}
