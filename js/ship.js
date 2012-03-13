
function Ship(x, y) {
	this.x = x || 0;
	this.y = y || 0;
	this.energy = 100;
	this.maxHull = 100;
	this.hull = this.maxHull;
	this.torpedos = 10;
	this.sensorRange = 100;
	this.sensorsOn = true;
	this.maxCargo = 30;
	this.usedCargo = 0;

	this.move = function() {

	};

	this.toggleSensors = function() {
		this.sensorsOn = !this.sensorsOn;
	};

	this.launchTorpedo = function() {
		if (this.torpedos === 0) return;
		this.torpedos--;
	};

	this.updateUI = function() {
		var i, str;
		var self = this;

		// Sensorsbox
		if (this.sensorsOn) $("#sensorstatus").html("ONLINE").attr("class", "online");
		else $("#sensorstatus").html("OFFLINE").attr("class", "offline");

		// Torpedos
		if (this.torpedos <= 0) $("#torpedos").html("-");
		else {
			str = "";
			for (i = 0; i < this.torpedos; ++i)
				str += "| ";
			$("#torpedos").html(str);
		}

		// Cargo
		function cargoTypeHTML(cargochar, cssclass, title, amount) {
			if (cssclass !== "empty") self.usedCargo += amount;
			var ret = '<span class=" ' +cssclass + '" title="' + title + '">';
			for (var cargoitem = 0; cargoitem < amount; ++cargoitem)
				ret += cargochar + " ";
			return ret + '</span>';
		}
		this.usedCargo = 0;
		str = "";

		if (this.torpedos > 0) str += cargoTypeHTML("T", "torpedo", "Torpedo", this.torpedos);

		var emptySpace = this.maxCargo - this.usedCargo;
		if (emptySpace > 0) str += cargoTypeHTML("-", "empty", "Free space", emptySpace);

		$("#cargo").html(str);

		var cargostatusclass = "good";
		if (emptySpace <= 5) cargostatusclass = "bad";
		else if (this.usedCargo / this.maxCargo > 0.666) cargostatusclass = "warn";
		$("#cargostatus").html(this.usedCargo + "/" + this.maxCargo).attr("class", cargostatusclass);
	};
}
