
function Universe(engine) {
	this.eng = engine;
	var viewLevelStack = [];
	viewLevelStack.push(new Starmap());

	this.update = function() {
		this.eng.setTileFunc(viewLevelStack[viewLevelStack.length-1].getTile);
		tick();
	};
	this.update();

	this.enter = function(x, y) {
		var newPlace;
		switch (viewLevelStack.length) {
			case 1: newPlace = new SolarSystem(x, y); break;
			case 2: /*newPlace = new PlanetAerial(x, y);*/ break;
			case 3: /*newPlace = new PlanetDetail(x, y);*/ break;
			default: return;
		}
		if (!newPlace) return;
		viewLevelStack.push(newPlace);
		this.update();
	};

	this.exit = function() {
		if (viewLevelStack.length <= 1) return;
		viewLevelStack.pop();
		this.update();
	};

}
