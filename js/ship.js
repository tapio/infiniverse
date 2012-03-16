
function Ship(x, y) {
	this.x = x || 0;
	this.y = y || 0;
	this.tile = new ut.Tile("@", 100, 100, 100);
	this.desc = "Player";
	this.energy = 10000;
	this.maxHull = 100;
	this.hull = this.maxHull;
	this.torpedos = 10;
	this.sensorSetting = 0;
	this.contacts = [];
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
		driveFactor: 1, warpFactor: 30,
		enterFactor: 1, exitFactor: 1,
		sensors: 100,
		gotoBeacon: 5000,
		launchTorpedo: 200
	};
	var self = this;
	var scanSettings = [ "Closest", "Artificial", "Celestial" ];

	function sortContacts() {
		if (!self.contacts.length) return;
		self.contacts.sort(function(a,b) {
			var d1 = distance2(self.x, self.y, a.x, a.y);
			var d2 = distance2(self.x, self.y, b.x, b.y);
			return d1-d2;
		});
	}

	this.move = function(dx, dy, warp) {
		var cost = universe.current.getMovementEnergy(this.x, this.y);
		if (warp && universe.current.type !== "station") {
			dx *= 5;
			dy *= 5;
			cost *= this.energyCosts.warpFactor;
		} else cost *= this.energyCosts.driveFactor;
		var oldx = this.x, oldy = this.y;
		if (this.useEnergy(cost)) {
			this.x += dx;
			this.y += dy;
		}
		var worldsize = universe.current.size;
		if (universe.current.type == "aerial") {
			this.x = (this.x + worldsize) % worldsize;
			this.y = (this.y + worldsize) % worldsize;
		} else {
			this.x = clamp(this.x, 0, worldsize-1);
			this.y = clamp(this.y, 0, worldsize-1);
		}
		var checktile = universe.current.getTile(this.x, this.y);
		if (checktile.blocks) {
			this.x = oldx; this.y = oldy;
		}
	};

	this.enter = function() {
		var cost = this.energyCosts.enterFactor * universe.current.getDescendEnergy();
		if (cost < 0) return;
		if (!this.useEnergy(cost)) return;
		if (!universe.enter(this)) this.energy += cost; // Refund if unsuccessful
	};

	this.exit = function() {
		var cost = this.energyCosts.exitFactor * universe.current.getAscendEnergy();
		if (cost < 0) return;
		if (!this.useEnergy(cost)) return;
		universe.exit(this);
	};

	this.toggleSensors = function() {
		this.sensorSetting = (this.sensorSetting + 1) % scanSettings.length;
	};

	this.clearSensors = function() {
		this.contacts = [];
	};

	this.scanSensors = function() {
		if (!this.useEnergy(this.energyCosts.sensors)) return;
		this.contacts = [];
		if (universe.current.type === "solarsystem") {
			if (this.sensorSetting != 1) {
				this.contacts = this.contacts.concat(universe.current.planets);
				this.contacts = this.contacts.concat(universe.current.suns);
			}
			if (this.sensorSetting != 2) {
				this.contacts = this.contacts.concat(universe.current.stations);
			}
		}
		if (this.sensorSetting != 2)
			this.contacts = this.contacts.concat(universe.actors);
		// Remove self
		for (var i = 0; i < this.contacts.length; ++i) {
			if (this.contacts[i] === this) { this.contacts.splice(i,1); break; }
		}
		sortContacts();
		if (this.contacts.length > 9)
			this.contacts.length = 9; // Max 9 contacts
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
		var torp = new Torpedo(this.x, this.y, { x: this.x, y: this.y-20 });
		universe.addActor(torp);
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

	this.update = function() {
		//if (this.hull <= 0) return false;
		return true;
	};

	this.updateUI = function() {
		var i, str, len, statusclass, elem;
		var ec = this.energyCosts;
		var u = universe.current;
		var self = this;

		// Sensorsbox
		var t = universe.current.getTile(this.x, this.y);
		$("#tiledesc").html(t && t.desc && t.desc.length ? t.desc : "n/a");
		$("#sensorenergy").html("-" + ec.sensors);
		$("#sensorsetting").html(scanSettings[this.sensorSetting]);
		len = this.contacts.length;
		if (len) {
			var arrows = "→↗↑↖←↙↓↘";
			sortContacts();
			for (i = 0, str = ""; i < len; ++i) {
				var obj = this.contacts[i];
				var dirchar = arrows[getAngledCharIndex(this.x, this.y, obj.x, obj.y)];
				var dist = ~~distance(this.x, this.y, obj.x, obj.y);
				if ((obj.radius && dist <= obj.radius) || dist < 1)
					dirchar = "↺";
				var sty = 'style="color:' + obj.tile.getColorRGB() + ';">';
				str += '<li><span ' + sty + obj.tile.ch + ' ' + obj.desc + "</span> - " + dist + dirchar + '</li>';
			}
			elem = $("#sensorlist");
			elem.html(str);
			if (!elem.is(":visible")) elem.show("blind", 500);
			$("#contactstitle").html(len + " contacts:");
		} else {
			$("#contactstitle").html("No contacts.");
			$("#sensorlist").html("").hide();
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
					' <span class="energy">-' + ec.gotoBeacon + '</span>';
			$("#beacon-menu").html(str);
		}

		// Ship status
		var cond = Math.floor(this.hull / this.maxHull * 100);
		if (cond < 0) cond = 0;
		statusclass = "good";
		if (cond <= 25) statusclass = "bad";
		else if (cond < 75) statusclass = "warn";
		$("#hullcond").html(cond+"%").attr("class", statusclass);
		$("#energy").html(prettyNumber(this.energy));

		// Devices
		$("#minerals-energy").html("+" + ec.convertMinerals);
		$("#radioactives-energy").html("+" + ec.convertRadioactives);
		$("#antimatter-energy").html("+" + ec.convertAntimatter);
		$("#torpedo-cost").html("-" + ec.createTorpedo);
		$("#beacon-cost").html("-" + ec.createBeacon);
		var movkeys = [ ut.KEY_LEFT, ut.KEY_RIGHT, ut.KEY_UP, ut.KEY_DOWN, ut.KEY_H, ut.KEY_J, ut.KEY_K, ut.KEY_L ];
		for (i = 0; i < movkeys.length; ++i)
			if (ut.isKeyPressed(movkeys[i])) { $("#drives span").first().attr("class", "online"); break; }
		if (i >= movkeys.length) $("#drives span").first().attr("class", "");
		var movEne = u.getMovementEnergy(this.x, this.y);
		$("#drives").children(".energy").html("-" + this.energyCosts.driveFactor * movEne);

		if (ut.isKeyPressed(ut.KEY_SHIFT)) $("#warpdrives span").first().attr("class", "online");
		else $("#warpdrives span").first().attr("class", "");
		$("#warpdrives").children(".energy").html("-" + ec.warpFactor * movEne);
		if (u.getDescendEnergy() >= 0)
			$("#enter").show().children(".energy").html("-" + ec.enterFactor * u.getDescendEnergy());
		else $("#enter").hide();
		if (u.getAscendEnergy() >= 0)
			$("#exit").show().children(".energy").html("-" + ec.exitFactor * u.getAscendEnergy());
		else $("#exit").hide();

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


Ship.prototype.getTile = function() {
	return this.tile;
};
