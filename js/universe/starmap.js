
function Starmap(x, y, neighbours) {
	this.size = 256;
	var simplex_exp = new SimplexNoise(new Alea('starmap_exp', x, y));
	var simplex_r = new SimplexNoise(new Alea('starmap_r', x, y));
	var simplex_g = new SimplexNoise(new Alea('starmap_g', x, y));
	var simplex_b = new SimplexNoise(new Alea('starmap_b', x, y));
	var simplex_star = new SimplexNoise(new Alea('starmap_star', x, y));

	var STARS = [ "✦", "★", "☀", "✶", "✳", "✷", "✸" ]; // ·✧✦☼☀✳☆★✶✷✸

	this.getTile = function(x, y) {
		var star = convertNoise(simplex_star.noise(x*10,y*10));
		var block = " ";
		if (star % 10 === 0) {
			block = STARS[Math.floor(star / 255 * STARS.length)];
			star = Math.min(star+50, 255);
		}

		var scale = 0.05;
		x *= scale;
		y *= scale;

		var mask = convertNoise(simplex_exp.noise(x,y));
		mask = expFilter(mask, 100, 0.99);
		var br = blendMul(convertNoise(simplex_r.noise(x,y)), mask);
		var bg = blendMul(convertNoise(simplex_g.noise(x,y)), mask);
		var bb = blendMul(convertNoise(simplex_b.noise(x,y)), mask);
		return new ut.Tile(block, star, star, star, br, bg, bb);
	};

	this.getShortDescription = function() {
		return "star cluster";
	};

	this.getDescription = function() {
		return "star cluster";
	};
}
