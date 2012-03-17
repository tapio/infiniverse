
function Ship(x, y) {
	this.x = x || 0;
	this.y = y || 0;
	this.tile = new ut.Tile("@", 100, 100, 100);
	this.desc = "Player";
	this.energy = 10000000;
	this.maxHull = 100;
	this.hull = this.maxHull;
	this.torpedos = 10;
	this.sensorSetting = 0;
	this.contacts = [];
	this.targets = [];
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
	this.scanSettings = [ "Closest", "Artificial", "Celestial" ];

	this.sortContacts = function() {
		if (!this.contacts.length) return;
		var self = this;
		this.contacts.sort(function(a,b) {
			var d1 = distance2(self.x, self.y, a.x, a.y);
			var d2 = distance2(self.x, self.y, b.x, b.y);
			return d1-d2;
		});
	};

	this.toggleSensors = function() {
		this.sensorSetting = (this.sensorSetting + 1) % this.scanSettings.length;
	};

	this.clearSensors = function() {
		this.contacts = [];
		this.targets = [];
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
		this.sortContacts();
		if (this.contacts.length > 9)
			this.contacts.length = 9; // Max 9 contacts
		if (!this.contacts.length)
			addMessage("Scan came out empty.");
	};

	this.getPrettyContact = function(obj) {
		var arrows = "→↗↑↖←↙↓↘";
		var dirchar = arrows[getAngledCharIndex(this.x, this.y, obj.x, obj.y)];
		var dist = ~~distance(this.x, this.y, obj.x, obj.y);
		if ((obj.radius && dist <= obj.radius) || dist < 1)
			dirchar = "↺";
		var sty = 'style="color:' + obj.tile.getColorRGB() + ';">';
		return '<span ' + sty + obj.tile.ch + ' ' + obj.desc + "</span> - " + dist + dirchar;
	};

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

	this.prepareTorpedo = function() {
		if (this.targets.length) {
			this.targets = [];
			addMessage("Cancelled torpedo launch.");
			return false;
		}
		if (this.torpedos === 0) {
			addMessage("Out of torpedos.", "error");
			return false;
		}
		if (!this.contacts.length) {
			addMessage("No targets available, use sensors to scan.", "error");
			return false;
		}
		this.targets = [];
		var i;
		for (i = 0; i < this.contacts.length; ++i) {
			if (this.contacts[i].targetable) this.targets.push(this.contacts[i]);
		}
		if (!this.targets.length) {
			addMessage("No suitable targets, use sensors to rescan.", "error");
			return false;
		}
		addMessage("Press target's number to launch, [T] to cancel.", "action");
		return true;
	};

	this.launchTorpedo = function(num) {
		if (!this.useEnergy(this.energyCosts.launchTorpedo)) return;
		if (num >= this.targets.length) return;
		if (this.torpedos === 0) return; // This should not happen ever
		this.torpedos--;
		var torp = new Torpedo(this.x, this.y, this.targets[num]);
		universe.addActor(torp);
		this.targets = [];
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
}


Ship.prototype.getTile = function() {
	return this.tile;
};
