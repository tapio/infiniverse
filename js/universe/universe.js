
function Universe(engine) {
	this.eng = engine;
	var locationStack = [];
	var viewLevelStack = [];
	viewLevelStack.push(new Galaxy());
	this.current = viewLevelStack[viewLevelStack.length-1];
	this.actors = [];

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
				case 1: newPlace = new Starmap(actor.x, actor.y, neighbours); break;
				case 2: newPlace = new SolarSystem(actor.x, actor.y, neighbours); break;
				case 3: newPlace = new PlanetProxy(actor.x, actor.y, neighbours); break;
				case 4: newPlace = new PlanetDetail(actor.x, actor.y, neighbours); break;
				default: return;
			}
			if (!newPlace) return false;
		} catch (err) {
			addMessage(err, "error");
			return false;
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
		while (i < this.actors.length) {
			if (!this.actors[i].update || this.actors[i].update()) ++i;
			else this.actors.splice(i,1); // If update returns false, remove the actor
		}
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
