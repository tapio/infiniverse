
function Universe(engine) {
	this.eng = engine;
	var viewLevelStack = [];
	viewLevelStack.push(new Galaxy());

	this.update = function() {
		this.eng.setTileFunc(viewLevelStack[viewLevelStack.length-1].getTile);
		tick();
	};
	this.update();

	this.enter = function(x, y) {
		function neighbours(offsetx, offsety) {
			offsetx = offsetx || 0;
			offsety = offsety || 0;
			return viewLevelStack[viewLevelStack.length-1].getTile(x-offsetx, y-offsety);
		}
		var newPlace;
		try {
			switch (viewLevelStack.length) {
				case 1: newPlace = new Starmap(); break;
				case 2: newPlace = new SolarSystem(x, y, neighbours); break;
				case 2: /*newPlace = new PlanetAerial(x, y, neighbours);*/ break;
				case 3: /*newPlace = new PlanetDetail(x, y, neighbours);*/ break;
				default: return;
			}
			if (!newPlace) return;
		} catch (err) {
			addMessage(err);
			return;
		}
		viewLevelStack.push(newPlace);
		this.update();
		var placename = viewLevelStack[viewLevelStack.length-1].getShortDescription();
		addMessage("Entered " + placename + ".");
	};

	this.exit = function() {
		if (viewLevelStack.length <= 1) return;
		var placename = viewLevelStack[viewLevelStack.length-1].getShortDescription();
		viewLevelStack.pop();
		this.update();
		addMessage("Exited " + placename + ".");
	};

}
