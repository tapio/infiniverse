
function SolarSystem(starmapx, starmapy, neighbours) {
	var simplex_neb = new SimplexNoise(new Alea('solar-system_neb', starmapx, starmapy));
	var simplex_bgstars = new SimplexNoise(new Alea('solar-system_bgstars', starmapx, starmapy));
	var tile = neighbours(0,0);
	if (tile.getChar() === " " || !tile.getChar().length)
		throw "Nothing interesting there, just empty space.";
	var nebColor = tile.getBackgroundJSON();

	this.getTile = function(x, y) {
		var star = convertNoise(simplex_neb.noise(x*10, y*10));
		var block = " ";
		if (star % 10 === 0) {
			block = "·";
			star = Math.min(star+50, 255);
		}

		var neb = convertNoise(simplex_neb.noise(x*0.05, y*0.05));
		//neb = expFilter(neb, 200, 0.99);
		var r = blendMul(nebColor.r, neb);
		var g = blendMul(nebColor.g, neb);
		var b = blendMul(nebColor.b, neb);
		return new ut.Tile(block, star,star,star, r, g, b);
	};

	this.getShortDescription = function() {
		return "solar system";
	};
}
