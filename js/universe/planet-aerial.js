
function PlanetAerial(x, y, neighbours) {
	this.size = 64;
	this.type = "aerial";
	var self = this;
	var tile = neighbours(0,0);
	this.planet = tile.planet;
	if (!this.planet)
		throw "Find a planet to land.";

	var simplex_height = new SimplexNoise(new Alea('planet_height', x, y));
	var texWater = new ut.Tile("≋", 0,0,255); // ♒
	var texGround = new ut.Tile(".", 128,128,128);
	var texHills = new ut.Tile("▴", 120,100,0);
	var texMountains = new ut.Tile("▲", 100,100,100);
	var texPeaks = new ut.Tile("▲", 255,255,255);

	this.getTile = function(x, y) {
		x = x % self.size;
		y = y % self.size;
		var h = simplex_height.noise(x*0.05, y*0.05);
		var tile = texWater;
		if (h > 0.95) tile = texPeaks;
		else if (h > 0.85) tile = texMountains;
		else if (h > 0.75) tile = texHills;
		else if (h > 0.25) tile = texGround;
		return tile;
	};

	this.getShortDescription = function() {
		return this.planet.desc.toLowerCase();
	};

	this.getDescription = function() {
		return this.planet.desc.toLowerCase();
	};
}
