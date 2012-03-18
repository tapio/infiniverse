
function Ship(x, y) {
	this.x = x || 0;
	this.y = y || 0;
	this.tile = new ut.Tile("@", 100, 100, 100);
	this.desc = "Player";
	this.type = "player";
	this.energy = 100000;
	this.credits = 100;
	this.maxHull = 100;
	this.hull = this.maxHull;
	this.dead = false;
	this.sensorSetting = 0;
	this.contacts = [];
	this.targets = [];
	this.maxCargo = 20;
	this.usedCargo = 0;
	this.activeBeacons = [];
	this.maxActiveBeacons = 8;
	this.warpSpeed = 5;
	this.energyCosts = {
		createMissile: 500, createBeacon: 5000,
		driveFactor: 1, warpFactor: 3,
		enterFactor: 1, exitFactor: 1,
		sensors: 100,
		gotoBeacon: 5000,
		launchMissile: 200
	};
	this.cargo = { missile: 5, navbeacon: 1, metals: 2, hydrogen: 4, radioactives: 0, antimatter: 0 };
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
			dx *= this.warpSpeed;
			dy *= this.warpSpeed;
			cost *= this.warpSpeed * this.energyCosts.warpFactor;
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
		} else if (checktile.buy) {
			addMessage("Buy " + checktile.buy.desc.toLowerCase() + " by pressing [Space].", "action");
		} else if (checktile.sell) {
			addMessage("Sell " + checktile.sell.desc.toLowerCase() + " by pressing [Space].", "action");
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

	this.hasCargoSpace = function() {
		if (this.usedCargo >= this.maxCargo) {
			addMessage("Not enough cargo space.", "error");
			return false;
		}
		return true;
	};

	this.collect = function() {
		// Check for shop first
		var checktile = universe.current.getTile(this.x, this.y);
		if (checktile.buy) {
			if (this.credits < checktile.buy.price) {
				addMessage("Not enough credits.", "error");
				return;
			}
			// Special cases
			if (checktile.buy.item === "cargoslot") {
				this.credits -= checktile.buy.price;
				this.maxCargo++;
				addMessage("Cargo space upgraded.");
				return;
			} else if (checktile.buy.item === "hull") {
				this.credits -= checktile.buy.price;
				this.maxHull += 20;
				this.hull = this.maxHull;
				addMessage("Hull strength upgraded.");
				return;
			} else if (checktile.buy.item === "repair") {
				this.credits -= checktile.buy.price;
				this.hull = this.maxHull;
				addMessage("Ship hull repaired.");
				return;
			}
			// Regular matter buying
			if (!this.hasCargoSpace()) return;
			this.credits -= checktile.buy.price;
			this.cargo[checktile.buy.item]++;
			addMessage("Bought " + checktile.buy.desc.toLowerCase() + ".");
			return;
		} else if (checktile.sell) {
			if (this.cargo[checktile.sell.item] < 1) {
				addMessage("Not enough " + checktile.sell.desc.toLowerCase() + ".", "error");
				return;
			}
			this.credits += checktile.sell.price;
			this.cargo[checktile.sell.item]--;
			return;
		}
		// Try to collect an item
		if (!this.hasCargoSpace()) return;
		var item = universe.removeItem(this.x, this.y);
		if (!item || !item.length) return;
		this.cargo[item] += 1;
		addMessage("Collected " + UniverseItems[item].desc.toLowerCase() + ".");
	};

	this.deployBeacon = function() {
		if (this.cargo.navbeacon === 0) {
			addMessage("Out of navbeacons.", "error");
			return;
		}
		if (this.activeBeacons.length >= this.maxActiveBeacons) {
			addMessage("Maximum number of active navbeacons reached.", "error");
			return;
		}
		this.cargo.navbeacon--;
		var navname = "", rnd = new Alea();
		for (var i = 0; i < 10; ++i) navname += (~~(rnd.random()*16)).toString(16);
		this.activeBeacons.push({
			title: navname, x: this.x, y: this.y,
			universeState: universe.getState()
		});
		addMessage("Navbeacon deployed.");
	};

	this.gotoBeacon = function(index) {
		if (index < 0 || index >= this.activeBeacons.length) return;
		if (!this.useEnergy(this.energyCosts.gotoBeacon)) return;
		universe.setState(this.activeBeacons[index].universeState);
		this.x = this.activeBeacons[index].x;
		this.y = this.activeBeacons[index].y;
		addMessage("Jump to navbeacon completed.");
	};

	this.createEnergy = function(button) {
		var matter;
		switch (button) {
			case 1: matter = "hydrogen"; break;
			case 2: matter = "radioactives"; break;
			case 3: matter = "antimatter"; break;
		}
		if (!matter) return;
		var protoitem = UniverseItems[matter];
		if (this.cargo[matter] <= 0) {
			addMessage("Not enough " + protoitem.desc.toLowerCase() + ".", "error");
			return;
		}
		if (!protoitem.energy) {
			addMessage("Cannot convert " + protoitem.desc.toLowerCase() + " to energy.", "error");
			return;
		}
		this.cargo[matter] -= 1;
		this.energy += protoitem.energy;
		addMessage("Converted " + protoitem.desc.toLowerCase() + " to " + protoitem.energy + " energy.");
	};

	this.createMass = function(button) {
		// Sanity checks
		if (button < 1 || button > 2) return;
		if (this.cargo.metals < 1) {
			addMessage("Not enough metals.", "error");
			return;
		} else if (!this.hasCargoSpace()) return;
		// What to produce?
		if (button == 1 && this.useEnergy(this.energyCosts.createMissile)) {
			this.cargo.metals--;
			this.cargo.missile++;
		} else if (button == 2 && this.useEnergy(this.energyCosts.createBeacon)) {
			this.cargo.metals--;
			this.cargo.navbeacon++;
		}
	};

	this.prepareMissile = function() {
		if (this.targets.length) {
			this.targets = [];
			addMessage("Cancelled missile launch.");
			return false;
		}
		if (this.cargo.missile === 0) {
			addMessage("Out of missiles.", "error");
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
		addMessage("Press target's number to launch, [M] to cancel.", "action");
		return true;
	};

	this.launchMissile = function(num) {
		if (!this.useEnergy(this.energyCosts.launchMissile)) return;
		if (num >= this.targets.length) return;
		if (this.cargo.missile === 0) return; // This should not happen ever
		this.cargo.missile--;
		var m = new Missile(this.x, this.y, this.targets[num], this);
		universe.addActor(m);
		this.targets = [];
		addMessage("Missile launched.");
	};

	this.damage = function(amount) {
		this.hull -= amount;
		if (this.hull <= 0) {
			this.dead = true;
			addMessage("Ship destroyed! Game over. Press Ctrl+R to restart.", "error");
		}
	};

	this.useEnergy = function(amount) {
		if (this.energy < amount) {
			addMessage("Not enough energy. Use energy converter to create more.", "error");
			// TODO: Check if this means death
			return false;
		}
		this.energy -= amount;
		return true;
	};

	this.update = function() {
		//if (this.dead) return;
	};
}


Ship.prototype.getTile = function() {
	return this.tile;
};
