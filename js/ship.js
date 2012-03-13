
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
	this.maxActiveBeacons = 8;
	this.minerals = 6;
	this.radioactives = 3;
	this.antimatter = 1;
	this.energyCosts = {
		convertMinerals: 100, convertRadioactives: 2000, convertAntimatter: 100000,
		createTorpedo: 200, createBeacon: 5000,
		drive: 1, warp: 100,
		sensors: 1,
		gotoBeacon: 1000,
		launchTorpedo: 200
	};

	this.move = function(dx, dy, warp) {
		// TODO: different costs for different view levels
		var cost = this.energyCosts.drive;
		if (warp) {
			dx *= 5;
			dy *= 5;
			cost = this.energyCosts.warp;
		}
		if (this.useEnergy(cost)) {
			this.x += dx;
			this.y += dy;
		}
		if (this.sensorsOn && !this.useEnergy(this.energyCosts.sensors)) this.sensorsOn = false;
		var worldsize = universe.current.size;
		if (universe.current.type == "aerial") {
			this.x = (this.x + worldsize) % worldsize;
			this.y = (this.y + worldsize) % worldsize;
		} else {
			this.x = clamp(this.x, 0, worldsize-1);
			this.y = clamp(this.y, 0, worldsize-1);
		}
	};

	this.toggleSensors = function() {
		this.sensorsOn = !this.sensorsOn;
	};

	this.deployBeacon = function() {
		if (this.beacons === 0) {
			addMessage("Out of navbeacons.", "error");
			return;
		}
		if (this.activeBeacons.length >= this.maxActiveBeacons) {
			addMessage("Maximum number of active navbeacons reached.", "error");
			return;
		}
		this.beacons--;
		var navname = "", rnd = new Alea();
		for (var i = 0; i < 10; ++i) navname += (~~(rnd.random()*16)).toString(16);
		this.activeBeacons.push({
			title: navname, x: this.x, y: this.y,
			universeState: universe.getState()
		});
	};

	this.gotoBeacon = function(index) {
		if (index < 0 || index >= this.activeBeacons.length) return;
		if (!this.useEnergy(this.energyCosts.gotoBeacon)) return;
		universe.setState(this.activeBeacons[index].universeState);
		this.x = this.activeBeacons[index].x;
		this.y = this.activeBeacons[index].y;
	};

	this.createEnergy = function(button) {
		switch (button) {
			case 1:
				if (this.minerals > 0) {
					this.minerals--;
					this.energy += this.energyCosts.convertMinerals;
				} else addMessage("Not enough minerals.", "error");
				break;
			case 2:
				if (this.radioactives > 0) {
					this.radioactives--;
					this.energy += this.energyCosts.convertRadioactives;
				} else addMessage("Not enough radioactives.", "error");
				break;
			case 3:
				if (this.antimatter > 0) {
					this.antimatter--;
					this.energy += this.energyCosts.convertAntimatter;
				} else addMessage("Not enough antimatter.", "error");
				break;
		}
	};

	this.createMass = function(button) {
		switch (button) {
			case 1:
				if (this.usedCargo >= this.maxCargo)
					addMessage("Not enough cargo space.", "error");
				else if (this.useEnergy(this.energyCosts.createTorpedo))
					this.torpedos++;
				break;
			case 2:
				if (this.usedCargo >= this.maxCargo)
					addMessage("Not enough cargo space.", "error");
				else if (this.useEnergy(this.energyCosts.createBeacon))
					this.beacons++;
				break;
		}
	};

	this.launchTorpedo = function() {
		if (this.torpedos === 0) {
			addMessage("Out of torpedos.", "error");
			return;
		}
		if (!this.useEnergy(this.energyCosts.launchTorpedo)) return;
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
		var contactCount = 0;
		function addContacts(collec) {
			var arrows = "→↗↑↖←↙↓↘";
			contactCount += collec.length;
			for (var i = 0, ret = ""; i < collec.length; ++i) {
				var obj = collec[i];
				var dir = getAngle(self.x, obj.y, obj.x, self.y); // Flip y
				dir = (dir + Math.PI*2 + Math.PI/8) % (Math.PI*2);
				var dirchar = arrows[~~(dir/(Math.PI/4))];
				var dist = ~~distance(self.x, self.y, obj.x, obj.y);
				if ((obj.radius && dist <= obj.radius) || dist < 1)
					dirchar = "↺";
				var sty = 'style="color:rgb('+obj.r+','+obj.g+','+obj.b+');">';
				ret += '<li>' + dirchar + ' <span ' + sty + collec[i].desc + "</span> - " + dist + '</li>';
			}
			return ret;
		}
		if (this.sensorsOn) {
			$("#sensorstatus").html("ONLINE").attr("class", "online");
			$("#sensorenergy").html("-" + this.energyCosts.sensors);
			str = "";
			if (universe.current.type === "solarsystem") {
				str += addContacts(universe.current.planets);
				str += addContacts(universe.current.suns);
			}
			$("#sensorlist").html(str);
			if (!contactCount) $("#contactstitle").html("No contacts.");
			else $("#contactstitle").html(contactCount + " contacts:");
		} else {
			$("#sensorstatus").html("OFFLINE").attr("class", "offline");
			$("#sensorenergy").html("0");
			$("#contactstitle").html("Enable sensors to scan.");
			$("#sensorlist").html("");
		}

		// Beacons
		$("#beaconstatus").html(this.beacons);
		len = this.activeBeacons.length;
		$("#activebeacons").html(len + "/" + this.maxActiveBeacons);
		if (len === 0) $("#beacon-menu").html("<li>No active beacons.</li>");
		else {
			str = "";
			for (i = 0; i < len; ++i)
				str += "<li>["+(i+1)+"] " + this.activeBeacons[i].title +
					' <span class="energy">-' + this.energyCosts.gotoBeacon + '</span>';
			$("#beacon-menu").html(str);
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
		$("#minerals-energy").html("+" + this.energyCosts.convertMinerals);
		$("#radioactives-energy").html("+" + this.energyCosts.convertRadioactives);
		$("#antimatter-energy").html("+" + this.energyCosts.convertAntimatter);
		$("#torpedo-cost").html("-" + this.energyCosts.createTorpedo);
		$("#beacon-cost").html("-" + this.energyCosts.createBeacon);
		var movkeys = [ ut.KEY_LEFT, ut.KEY_RIGHT, ut.KEY_UP, ut.KEY_DOWN, ut.KEY_H, ut.KEY_J, ut.KEY_K, ut.KEY_L ];
		for (i = 0; i < movkeys.length; ++i)
			if (ut.isKeyPressed(movkeys[i])) { $("#drives span").first().attr("class", "online"); break; }
		if (i >= movkeys.length) $("#drives span").first().attr("class", "");
		$("#drives").children(".energy").html("-" + this.energyCosts.drive);

		if (ut.isKeyPressed(ut.KEY_SHIFT)) $("#warpdrives span").first().attr("class", "online");
		else $("#warpdrives span").first().attr("class", "");
		$("#warpdrives").children(".energy").html("-" + this.energyCosts.warp);

		// Torpedos
		$("#torpedos").html(this.torpedos);
		$("#torpedos").siblings(".energy").html("-" + this.energyCosts.launchTorpedo);
		/*if (this.torpedos <= 0) $("#torpedos").html("-");
		else {
			str = "";
			for (i = 0; i < this.torpedos; ++i)
				str += "| ";
			$("#torpedos").html(str);
		}*/

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
