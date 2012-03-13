
function PlanetAerial() {
	this.size = 512;
	this.type = "aerial";

	this.getTile = function(x, y) {
		return ut.NULLTILE;
	};

	this.getShortDescription = function() {
		return "planet";
	};

	this.getDescription = function() {
		return "planet";
	};

	// TODO: Check for planet
	throw "Find a planet to land.";
}
