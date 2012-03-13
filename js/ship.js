
function Ship(x, y) {
	this.x = x || 0;
	this.y = y || 0;
	this.energy = 10000;
	this.maxHull = 100;
	this.hull = this.maxHull;
	this.torpedos = 10;
	this.sensorRange = 100;
	this.sensorsOn = true;
	this.maxCargo = 30;
	this.usedCargo = 0;
	this.beacons = 2;
	this.activeBeacons = [];
	this.minerals = 6;
	this.radioactives = 3;
	this.antimatter = 1;

	this.move = function(dx, dy, warp) {
		// TODO: different costs for different view levels
		var cost = 1;
		if (warp) {
			dx *= 5;
			dy *= 5;
			cost *= 10;
		}
		if (!this.useEnergy(cost)) return;
		this.x += dx;
		this.y += dy;
	};

	this.toggleSensors = function() {
		this.sensorsOn = !this.sensorsOn;
	};

	this.deployBeacon = function() {
		if (this.beacons === 0) {
			addMessage("Out of navbeacons.", "error");
			return;
		}
		this.beacons--;
		this.activeBeacons.push({ title: "Active beacon" });
	};

	this.launchTorpedo = function() {
		if (this.torpedos === 0) {
			addMessage("Out of torpedos.", "error");
			return;
		}
		this.torpedos--;
	};

	this.damage = function(amount) {
		this.hull -= amount;
		if (this.hull <= 0) {
			addMessage("Ship destroyed!", "error");
		}
	};

	this.useEnergy = function(amount) {
		if (this.energy < amount) {
			addMessage("Not enough energy.", "error");
			return false;
		}
		this.energy -= amount;
		return true;
	};

	this.updateUI = function() {
		var i, str, len, statusclass;
		var self = this;

		// Sensorsbox
		if (this.sensorsOn) $("#sensorstatus").html("ONLINE").attr("class", "online");
		else $("#sensorstatus").html("OFFLINE").attr("class", "offline");

		// Beacons
		//str = this.beacons + " available ";
		//if (this.beacons > 0) str += "[B] to deploy";
		$("#beaconstatus").html(this.beacons);
		len = this.activeBeacons.length;
		if (len === 0) $("#navbeaconlist").html("<li>No active beacons.</li>");
		else {
			str = "";
			for (i = 0; i < len; ++i)
				str += "<li>["+(i+1)+"] " + this.activeBeacons[i].title;
			$("#navbeaconlist").html(str);
		}

		// Ship status
		var cond = Math.floor(this.hull / this.maxHull * 100);
		if (cond < 0) cond = 0;
		statusclass = "good";
		if (cond <= 25) statusclass = "bad";
		else if (cond < 75) statusclass = "warn";
		$("#hullcond").html(cond+"%").attr("class", statusclass);
		$("#energy").html(this.energy);

		// Devices
		if (ut.isKeyPressed(ut.KEY_SHIFT)) $("#warpdrives span").attr("class", "online");
		else $("#warpdrives span").attr("class", "");

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
		if (this.beacons > 0) str += cargoTypeHTML("B", "beacon", "Navbeacon", this.beacons);
		if (this.torpedos > 0) str += cargoTypeHTML("T", "torpedo", "Torpedo", this.torpedos);
		if (this.minerals > 0) str += cargoTypeHTML("M", "minerals", "Minerals", this.minerals);
		if (this.radioactives > 0) str += cargoTypeHTML("R", "radioactives", "Radioactives", this.radioactives);
		if (this.antimatter > 0) str += cargoTypeHTML("A", "antimatter", "Antimatter", this.antimatter);
		var emptySpace = this.maxCargo - this.usedCargo;
		if (emptySpace > 0) str += cargoTypeHTML("-", "empty", "Free space", emptySpace);
		$("#cargo").html(str);

		statusclass = "good";
		if (emptySpace <= 5) statusclass = "bad";
		else if (this.usedCargo / this.maxCargo > 0.666) statusclass = "warn";
		$("#cargostatus").html(this.usedCargo + "/" + this.maxCargo).attr("class", statusclass);
	};
}
