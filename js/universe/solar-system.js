
var starMultiples = [
	1,1,1,1,1,1,1,1,
	1,1,1,1,1,1,1,1,
	1,1,2,2,2,2,2,2,
	3,3,3,3,4,4,5,6
];

var planetMultiples = [
	0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,
	1,1,1,2,2,2,3,3,
	4,4,5,6,7,8,9,10
];

var starTypes = [
	{ ch:"✸", r:200, g:200, b:255, radius:125, freq:0.00001, desc:"Class O star" },
	{ ch:"✷", r:160, g:160, b:255, radius:75, freq:0.010, desc:"Class B star" },
	{ ch:"✳", r:200, g:200, b:255, radius:40, freq:0.010, desc:"Class A star" },
	{ ch:"✶", r:220, g:220, b:160, radius:25, freq:0.050, desc:"Class F star" },
	{ ch:"☀", r:255, g:255, b:0, radius:22, freq:0.150, desc:"Class G star" },
	{ ch:"★", r:200, g:100, b:0, radius:20, freq:0.220, desc:"Class K star" },
	{ ch:"✦", r:200, g:0, b:5, radius:10, freq:0.550, desc:"Class M star" },
	{ ch:"✧", r:160, g:160, b:160, radius:4, freq:0.010, desc:"Class D star" }
];

var planetTypes = [
	{ type:"gas", ch:"◌", r:128, g:0, b:0, desc:"Gas giant" },
	{ type:"rock", ch:"●", r:128, g:128, b:128, desc:"Rock planet" },
	{ type:"ocean", ch:"○", r:128, g:128, b:255, desc:"Ocean planet" },
	{ type:"gaia", ch:"◍", r:0, g:255, b:0, desc:"Terrestrial" }
];

// TODO: Use also upper level coordinates in seeding
function SolarSystem(x, y, neighbours) {
	this.size = 256;
	this.type = "solarsystem";
	var self = this;
	var halfSize = (this.size * 0.5) | 0;
	var simplex_neb = new SimplexNoise(new Alea('solar-system_neb', x, y));
	var simplex_bgstars = new SimplexNoise(new Alea('solar-system_bgstars', x, y));
	var tile = neighbours(0,0);
	if (!tile.getChar().length || tile.getChar() === " " || tile.getChar() === "·")
		throw "Nothing interesting there, just empty space.";
	var nebColor = tile.getBackgroundJSON();

	var rnd = new Alea("randomizer", x, y);
	var starCount = starMultiples[rand(0, starMultiples.length, rnd)];
	var planetCount = planetMultiples[rand(0, planetMultiples.length, rnd)];
	var numObjects = starCount + planetCount;

	this.suns = [];
	this.planets = [];

	// Suns
	var i, j;

	var ang = rnd.random() * 360;
	for (i = 0; i < starCount; ++i) {
		var starProto = starTypes[(rnd.random()*starTypes.length)|0];
		this.suns.push(clone(starProto));
		ang += i * (360.0 / starCount);
		this.suns[i].x = ~~(halfSize + cosd(ang) * randf(starProto.radius, halfSize, rnd));
		this.suns[i].y = ~~(halfSize - sind(ang) * randf(starProto.radius, halfSize, rnd));
	}

	// Planets
	for (i = 0; i < planetCount; ++i) {
		var planetProto = planetTypes[(rnd.random()*planetTypes.length)|0];
		this.planets.push(clone(planetProto));
		ang = rnd.random() * 360;
		this.planets[i].x = ~~(halfSize + cosd(ang) * randf(30, halfSize*0.6, rnd));
		this.planets[i].y = ~~(halfSize - sind(ang) * randf(30, halfSize*0.6, rnd));
	}

	// Can't use 'this' here due to passing this function to the tile engine
	this.getTile = function(x, y) {
		// Background stars
		var star = convertNoise(simplex_bgstars.noise(x*10, y*10));
		var block = " ";
		if (star % 10 === 0) {
			block = "·";
			star = Math.min(star+50, 255);
		}
		// Planets
		for (i = 0; i < planetCount; ++i) {
			var p = self.planets[i];
			if (x == p.x && y == p.y) {
				var tile = new ut.Tile(p.ch, p.r, p.g, p.b);
				tile.planet = p; // Attach planet reference
				return tile;
			}
		}
		// Suns
		var sunR = 0, sunG = 0, sunB = 0, mask = 0;
		for (i = 0; i < starCount; ++i) {
			var sun = self.suns[i];
			var distSquared = (x-sun.x)*(x-sun.x) + (y-sun.y)*(y-sun.y);
			if (distSquared < sun.radius * sun.radius) {
				dist2 = Math.sqrt(distSquared) / sun.radius * 256.0;
				mask = 256-dist2; //expFilter(dst2, 0, .99)
				//temp = (Perlin(x,y,worldW,worldH,2,2) - 128.0) / 8.0;
				//mask = Max( Min(mask+temp, 255), 0 );
				mask2 = mask / 256.0;
				if (mask2 > 1.0) mask2 = 1.0;
				sunR = sun.r;
				sunG = sun.g;
				sunB = sun.b;
				block = " ";
				break;
			}
		}
		// Nebula
		var neb = convertNoise(simplex_neb.noise(x*0.05, y*0.05));
		//neb = expFilter(neb, 200, 0.99);
		var r = blendMul(nebColor.r, neb);
		var g = blendMul(nebColor.g, neb);
		var b = blendMul(nebColor.b, neb);
		// Blend sun and background
		mask = Math.min(mask*2, 255);
		r = blend(sunR, r, mask/255.0) | 0;
		g = blend(sunG, g, mask/255.0) | 0;
		b = blend(sunB, b, mask/255.0) | 0;

		return new ut.Tile(block, star,star,star, r, g, b);
	};

	this.getShortDescription = function() {
		return "solar system";
	};

	this.getDescription = function() {
		return "solar system of " + this.suns.length + " suns and " + this.planets.length + " planets";
	};
}
