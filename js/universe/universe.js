
function Universe(engine) {
	this.eng = engine;
	var locationStack = [];
	var viewLevelStack = [];
	viewLevelStack.push(new Galaxy());
	this.current = viewLevelStack[viewLevelStack.length-1];
	this.actors = [];
	this.persistentStore = {};
	this.items = {};

	this.postViewChange = function() {
		this.current = viewLevelStack[viewLevelStack.length-1];
		if (this.current.type == "aerial") this.eng.setWorldSize();
		else this.eng.setWorldSize(this.current.size, this.current.size);
		this.eng.setTileFunc(this.current.getTile);
		this.actors = this.current.actors ? this.current.actors : [];
		var i;
		for (i = 0; i < this.actors.length; ++i)
			if (this.actors[i] === pl) break;
		if (i >= this.actors.length) this.actors.push(pl);
	};
	this.postViewChange();

	// actor: { x, y }
	this.enter = function(actor) {
		function neighbours(offsetx, offsety) {
			offsetx = offsetx || 0;
			offsety = offsety || 0;
			return viewLevelStack[viewLevelStack.length-1].getTile(actor.x+offsetx, actor.y+offsety);
		}
		var newPlace;
		try {
			switch (viewLevelStack.length) {
				case 1: newPlace = StarmapProxy(actor.x, actor.y, neighbours, this.current.hash); break;
				case 2: newPlace = new SolarSystem(actor.x, actor.y, neighbours, this.current.hash); break;
				case 3: newPlace = new PlanetProxy(actor.x, actor.y, neighbours, this.current.hash); break;
				case 4: newPlace = new PlanetDetail(actor.x, actor.y, neighbours, this.current.hash); break;
				default: return;
			}
			if (!newPlace) return false;
		} catch (err) {
			if ("string" === typeof err) {
				addMessage(err, "error");
				return false;
			} else throw err;
		}
		viewLevelStack.push(newPlace);
		locationStack.push({ x: actor.x, y: actor.y });
		this.postViewChange();
		this.current.x = actor.x;
		this.current.y = actor.y;
		actor.x = Math.floor(this.current.size / 2);
		actor.y = Math.floor(this.current.size / 2);
		var placename = this.current.getDescription();
		if (actor.clearSensors) actor.clearSensors();
		addMessage("Entered " + placename + ".");
		return true;
	};

	// actor: { x, y }
	this.exit = function(actor) {
		if (viewLevelStack.length <= 1) return;
		var placename = this.current.getShortDescription();
		actor.x = this.current.x;
		actor.y = this.current.y;
		viewLevelStack.pop();
		locationStack.pop();
		this.postViewChange();
		if (actor.clearSensors) actor.clearSensors();
		addMessage("Exited " + placename + ".");
	};

	// actor: { x, y, update() }
	this.addActor = function(actor) {
		this.actors.push(actor);
	};

	this.updateActors = function() {
		var i = 0;
		// Update
		for (i = 0; i< this.actors.length; ++i)
			this.actors[i].update();
		// Reap the dead
		i = 0;
		while (i < this.actors.length) {
			if (this.actors[i].dead !== true) ++i;
			else this.actors.splice(i,1);
		}
	};

	this.saveInfo = function(hash, info) {
		this.persistentStore[hash] = info;
	};

	this.getInfo = function(hash) {
		if (this.persistentStore.hasOwnProperty(hash))
			return this.persistentStore[hash];
		else return {};
	};

	this.addItem = function(item, owner) {
		owner = owner || this.current.hash;
		if (!this.items[owner]) this.items[owner] = [];
		this.items[owner].push(item);
	};

	this.getItems = function(owner) {
		owner = owner || this.current.hash;
		return this.items[owner];
	};

	this.removeItem = function(x, y, owner) {
		owner = owner || this.current.hash;
		var coll = this.items[owner];
		if (!coll || !coll.length) return "";
		for (var i = 0; i < coll.length; ++i) {
			if (x === coll[i].x && y === coll[i].y) {
				var item = coll[i].tile.item;
				coll.splice(i,1);
				return item;
			}
		}
		return "";
	};

	this.getState = function() {
		return clone(locationStack);
	};

	this.setState = function(state) {
		locationStack = [];
		while (viewLevelStack.length > 1) {
			viewLevelStack.pop();
		}
		this.postViewChange();
		for (var i = 0; i < state.length; ++i) {
			this.enter(clone(state[i]));
		}
	};
}

var UniverseItems = {};

UniverseItems.metals = new ut.Tile("M", 119, 119, 153);
UniverseItems.metals.desc = "Metals";
UniverseItems.metals.item = "metals";
UniverseItems.metals.baseprice = 10;

UniverseItems.hydrogen = new ut.Tile("H", 0, 119, 255);
UniverseItems.hydrogen.desc = "Hydrogen";
UniverseItems.hydrogen.item = "hydrogen";
UniverseItems.hydrogen.energy = 100;
UniverseItems.hydrogen.baseprice = 10;

UniverseItems.radioactives = new ut.Tile("R", 0, 255, 0);
UniverseItems.radioactives.desc = "Radioactives";
UniverseItems.radioactives.item = "radioactives";
UniverseItems.radioactives.energy = 2000;
UniverseItems.radioactives.baseprice = 200;

UniverseItems.antimatter = new ut.Tile("A", 255, 255, 255);
UniverseItems.antimatter.desc = "Antimatter";
UniverseItems.antimatter.item = "antimatter";
UniverseItems.antimatter.energy = 50000;
UniverseItems.antimatter.baseprice = 5000;

UniverseItems.missile = new ut.Tile("⇑", 136, 68, 34);
UniverseItems.missile.desc = "Missile";
UniverseItems.missile.item = "missile";
UniverseItems.missile.baseprice = 40;

UniverseItems.navbeacon = new ut.Tile("b", 170, 0, 221);
UniverseItems.navbeacon.desc = "Navbeacon";
UniverseItems.navbeacon.item = "navbeacon";
UniverseItems.navbeacon.baseprice = 450;
