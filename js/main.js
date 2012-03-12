/*jshint browser:true trailing:true latedef:true */

var term, eng; // Can't be initialized yet because DOM is not ready
var universe;

var pl = { x: 1024, y: 1024 }; // Player position, FIXME: Make a proper class

var messages = [];
var maxMessages = 5;

function addMessage(msg) {
	messages.push(msg);
	if (messages.length > maxMessages) messages.splice(0, messages.length - maxMessages);
	var msgs = "";
	var color = { r:60, g:77, b:255 };
	for (var i = messages.length-1; i >= 0; --i) {
		msgs += '<span style="color: rgb('+color.r+','+color.g+','+color.b+');">'+messages[i]+'</span><br/>';
		if (i == messages.length-1) msgs = '<span style="font-size:1.1em">'+msgs+'</span>';
		color.r = Math.max(color.r - 15, 0);
		color.g = Math.max(color.g - 15, 0);
		color.b = Math.max(color.b - 25, 0);
	}
	$("#messages").html(msgs);
}

// "Main loop"
function tick() {
	eng.update(pl.x, pl.y); // Update tiles
	var plc = term.get(term.cx, term.cy); // Player character
	plc.setChar("@");
	plc.setColor(255,255,255);
	term.render(); // Render
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
	if (movedir.x === 0 && movedir.y === 0) return;
	pl.x += movedir.x;
	pl.y += movedir.y;
	tick();
}

// Initialize stuff
function init() {
	term = new ut.Viewport(document.getElementById("game"), 55, 31);
	eng = new ut.Engine(term);
	universe = new Universe(eng); // Also sets the tile function to Engine
	ut.initInput(onKeyDown);
	tick();
	addMessage("Welcome to Infiniverse.");
}
