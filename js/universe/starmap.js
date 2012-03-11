var simplex_starmap_exp = new SimplexNoise(new Alea('starmap_exp'));
var simplex_starmap_r = new SimplexNoise(new Alea('starmap_r'));
var simplex_starmap_g = new SimplexNoise(new Alea('starmap_g'));
var simplex_starmap_b = new SimplexNoise(new Alea('starmap_b'));
var simplex_starmap_star = new SimplexNoise(new Alea('starmap_star'));

var STARS = [ "✦", "★", "☀", "✶", "✳", "✷", "✸" ]; // ✧✦☼☀✳☆★✶✷✸

function getStarmapTile(x, y) {
	var star = convertNoise(simplex_starmap_star.noise(x*10,y*10));
	var block = " ";
	if (star % 10 === 0) {
		block = STARS[Math.floor(star / 255 * STARS.length)];
		star = Math.min(star+50, 255);
	}

	var scale = 0.05;
	x *= scale;
	y *= scale;

	var mask = convertNoise(simplex_starmap_exp.noise(x,y));
	mask = expFilter(mask, 100, 0.99);
	var br = blendMul(convertNoise(simplex_starmap_r.noise(x,y)), mask);
	var bg = blendMul(convertNoise(simplex_starmap_g.noise(x,y)), mask);
	var bb = blendMul(convertNoise(simplex_starmap_b.noise(x,y)), mask);
	return new ut.Tile(block, star, star, star, br, bg, bb);
}
