
function Ship(x, y) {
	this.x = x || 0;
	this.y = y || 0;
	this.energy = 100;
	this.maxHull = 100;
	this.hull = this.maxHull;
	this.torpedos = 5;
	this.sensorRange = 100;
	this.sensorsOn = true;

	this.move = function() {

	};

	this.toggleSensors = function() {
		this.sensorsOn = !this.sensorsOn;
	};

	this.updateUI = function() {
		// Sensorsbox
		if (this.sensorsOn) $("#sensorstatus").html("ONLINE").attr("class", "online");
		else $("#sensorstatus").html("OFFLINE").attr("class", "offline");
	};
}
