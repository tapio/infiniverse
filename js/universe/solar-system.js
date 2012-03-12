
function SolarSystem(starmapx, starmapy, neighbours) {
	var simplex_neb = new SimplexNoise(new Alea('solar-system_neb', starmapx, starmapy));
	var systemNebulaColor = neighbours(0,0).getBackgroundJSON();

	this.getTile = function(x, y) {
		var scale = 0.05;
		x *= scale;
		y *= scale;

		var neb = convertNoise(simplex_neb.noise(x,y));
		//neb = expFilter(neb, 200, 0.99);
		var r = blendMul(systemNebulaColor.r, neb);
		var g = blendMul(systemNebulaColor.g, neb);
		var b = blendMul(systemNebulaColor.b, neb);
		return new ut.Tile(" ", 0,0,0, r, g, b);
	};

	this.getShortDescription = function() {
		return "solar system";
	};
}
