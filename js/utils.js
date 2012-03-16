// Math utilities

function degToRad(degrees) {
	return degrees * Math.PI / 180;
}

function cosd(degrees) {
	return Math.cos(degrees * 0.017453292519943295);
}

function sind(degrees) {
	return Math.sin(degrees * 0.017453292519943295);
}

function rand(lo, hi, rng) {
	//rng = rng || Math;
	return lo + ~~(rng.random() * (hi - lo + 1));
}

function randf(lo, hi, rng) {
	//rng = rng || Math;
	return lo + (hi - lo) * (rng.random());
}

function randchar(str, rng) {
	return str[rand(0, str.length-1, rng)];
}

function sign(num) { return ((num > 0) ? 1 : ((num < 0) ? -1 : 0)); }

function fract(num) {
	return num - Math.floor(num);
}

function distance(x1, y1, x2, y2) {
	var dx = x2-x1, dy = y2-y1;
	return Math.sqrt(dx*dx + dy*dy);
}

function distance2(x1, y1, x2, y2) {
	var dx = x2-x1, dy = y2-y1;
	return dx*dx + dy*dy;
}

function getAngle(x1, y1, x2, y2) {
	return Math.atan2(y2-y1, x2-x1);
}

function between(x, a, b) {
	return (x < a || x > b) ? false : true;
}

// Returns angle between points as integer [0,7]
function getAngledCharIndex(x1, y1, x2, y2) {
	var dir = getAngle(x1, y2, x2, y1); // Flip y
	dir = (dir + Math.PI*2 + Math.PI/8) % (Math.PI*2);
	return (dir/(Math.PI/4)) | 0;
}

function blend(a, b, f) {
	return a*f + b*(1.0-f);
}

function blendMul(a, b) {
	return (a * b) >> 8;
}

function clamp(x, a, b) {
	return x < a ? a : ( x > b ? b : x );
}

function clampColor(x) {
	return x < 0 ? 0 : (x > 255 ? 255 : (x|0));
}

function mapRange(x, in_min, in_max, out_min, out_max) {
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

// Convert float [0,1] to integer [0,255]
function convertNoise(value) {
	var ret = (256 * value)|0; // |0 is floor
	return ret < 256 ? ret : 255;
}

// Exponent filter for making cloud like heightmaps
function expFilter(value, cover, sharpness) {
	var c = (value - (1.0 - cover)) * 10000;
	value = 10000 - (Math.pow(sharpness, c < 0 ? 0 : c) * 10000);
	return value / 10000;
}



function prettyNumber(num) {
	if (num >= 10000000) return ((num / 1000000)|0) + "M";
	if (num >= 10000) return ((num / 1000)|0) + "k";
	return num;
}


// Array utils

function last(arr) { return arr[arr.length-1]; }


// Object utils

// If an object has clone() function, it is assumed to return a copy.
function clone(obj) {
	// Handle the 3 simple types, and null or undefined
	if (null === obj || "object" != typeof obj) return obj;
	var copy;

	// Handle Date
	if (obj instanceof Date) {
		copy = new Date();
		copy.setTime(obj.getTime());
		return copy;
	}

	// Handle Array
	if (obj instanceof Array) {
		copy = [];
		for (var i = 0, len = obj.length; i < len; ++i)
			copy[i] = clone(obj[i]);
		return copy;
	}

	// Handle Object
	if (obj instanceof Object) {
		if (obj.constructor) copy = new obj.constructor();
		else copy = {};
		for (var attr in obj)
			if (obj.hasOwnProperty(attr)) copy[attr] = clone(obj[attr]);
		return copy;
	}

	throw new Error("Unable to copy obj! Its type isn't supported.");
}
