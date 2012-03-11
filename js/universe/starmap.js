var simplex = [
	new SimplexNoise(Math),
	new SimplexNoise(Math),
	new SimplexNoise(Math),
	new SimplexNoise(Math),
	new SimplexNoise(Math)
];

var STARS = [ "✦", "★", "☀", "✶", "✳", "✷", "✸" ]; // ✧✦☼☀✳☆★✶✷✸

// Exponent filter for making cloud like heightmaps
function expFilter(value, cover, sharpness) {
	var c = value - (255.0-cover);
	if (c < 0) c = 0;
	value = 255.0 - (Math.pow(sharpness,c)*255.0);
	return Math.floor(value);
}

function convertNoise(value) {
	return Math.floor(256 * (value * 0.5 + 0.5));
}

function getStarmapTile(x, y) {
	var star = convertNoise(simplex[4].noise(x*10,y*10));
	var block = " ";
	if (star % 10 === 0) {
		block = STARS[Math.floor(star / 255 * STARS.length)];
		star = Math.min(star+50, 255);
	}

	var scale = 0.05;
	x *= scale;
	y *= scale;

	var mask = convertNoise(simplex[0].noise(x,y));
	mask = expFilter(mask, 100, 0.99);
	var br = blendMul(convertNoise(simplex[1].noise(x,y)), mask);
	var bg = blendMul(convertNoise(simplex[2].noise(x,y)), mask);
	var bb = blendMul(convertNoise(simplex[3].noise(x,y)), mask);
	return new ut.Tile(block, star, star, star, br, bg, bb);
}
