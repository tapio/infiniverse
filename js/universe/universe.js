
function Universe(engine) {
	this.eng = engine;
	var viewLevelStack = [];
	viewLevelStack.push(new Galaxy());
	this.current = viewLevelStack[viewLevelStack.length-1];

	this.update = function() {
		this.current = viewLevelStack[viewLevelStack.length-1];
		this.eng.setWorldSize(this.current.size, this.current.size);
		this.eng.setTileFunc(this.current.getTile);
	};
	this.update();

	// actor: { x, y }
	this.enter = function(actor) {
		function neighbours(offsetx, offsety) {
			offsetx = offsetx || 0;
			offsety = offsety || 0;
			return viewLevelStack[viewLevelStack.length-1].getTile(actor.x-offsetx, actor.y-offsety);
		}
		var newPlace;
		try {
			switch (viewLevelStack.length) {
				case 1: newPlace = new Starmap(actor.x, actor.y, neighbours); break;
				case 2: newPlace = new SolarSystem(actor.x, actor.y, neighbours); break;
				case 3: newPlace = new PlanetAerial(actor.x, actor.y, neighbours); break;
				case 4: newPlace = new PlanetDetail(actor.x, actor.y, neighbours); break;
				default: return;
			}
			if (!newPlace) return;
		} catch (err) {
			addMessage(err);
			return;
		}
		viewLevelStack.push(newPlace);
		this.update();
		this.current.x = actor.x;
		this.current.y = actor.y;
		actor.x = Math.floor(this.current.size / 2);
		actor.y = Math.floor(this.current.size / 2);
		var placename = this.current.getDescription();
		addMessage("Entered " + placename + ".");
	};

	// actor: { x, y }
	this.exit = function(actor) {
		if (viewLevelStack.length <= 1) return;
		var placename = this.current.getShortDescription();
		actor.x = this.current.x;
		actor.y = this.current.y;
		viewLevelStack.pop();
		this.update();
		addMessage("Exited " + placename + ".");
	};

	this.getState = function() {
		return clone(viewLevelStack);
	};

	this.setState = function(state) {
		viewLevelStack = state;
		this.update();
	};
}
