// Math utilities

function degToRad(degrees) {
	return degrees * Math.PI / 180;
}

function rand(lo, hi) {
	return lo + Math.floor(Math.random() * (hi - lo + 1));
}

function sign(num) { return ((num > 0) ? 1 : ((num < 0) ? -1 : 0)); }

function fract(num) {
	return num - Math.floor(num);
}

function blend(a, b, f) {
	return a*f + b*(1.0-f);
}

function blendMul(a, b) {
	return (a * b) >> 8;
}

// Convert float [-1,1] to integer [0,255]
function convertNoise(value) {
	return ~~(256 * (value * 0.5 + 0.5)); // ~~ is floor
}
