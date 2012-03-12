
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
	{ r:200, g:200, b:255, size:250, freq:0.00001, desc:"Class O" },
	{ r:160, g:160, b:255, size:125, freq:0.010, desc:"Class B" },
	{ r:200, g:200, b:255, size:50, freq:0.010, desc:"Class A" },
	{ r:220, g:220, b:160, size:25, freq:0.050, desc:"Class F" },
	{ r:255, g:255, b:0, size:22, freq:0.150, desc:"Class G" },
	{ r:200, g:100, b:0, size:20, freq:0.220, desc:"Class K" },
	{ r:200, g:0, b:5, size:10, freq:0.550, desc:"Class M" },
	{ r:160, g:160, b:160, size:4, freq:0.010, desc:"Class D" }
];

function SolarSystem(starmapx, starmapy, neighbours) {
	var self = this;
	var size = 256;
	var simplex_neb = new SimplexNoise(new Alea('solar-system_neb', starmapx, starmapy));
	var simplex_bgstars = new SimplexNoise(new Alea('solar-system_bgstars', starmapx, starmapy));
	var tile = neighbours(0,0);
	if (tile.getChar() === " " || !tile.getChar().length)
		throw "Nothing interesting there, just empty space.";
	var nebColor = tile.getBackgroundJSON();

	var rnd = new Alea(starmapx, starmapy);
	var starCount = starMultiples[rand(0, starMultiples.length, rnd)];
	var planetCount = planetMultiples[rand(0, planetMultiples.length, rnd)];
	var numObjects = starCount + planetCount;

	this.suns = [];
	this.planets = [];

	// Suns
	var i, j;

	var ang = rnd.random() * 360;
	for (i = 0; i < starCount; ++i) {
		var starProto = starTypes[~~(rnd.random()*starTypes.length)];
		this.suns.push(clone(starProto));
		ang += i * (360.0 / starCount);
		this.suns[i].x = ~~(size/2 + cosd(ang) * randf(starProto.size, 255, rnd));
		this.suns[i].y = ~~(size/2 - sind(ang) * randf(starProto.size, 255, rnd));
	}

	// Planets
	for (i = 0; i < planetCount; ++i) {
		this.planets.push({});
		var p = this.planets[i];
		p.objType = rand(1, 3, rnd);
		switch (p.objType) {
			case 1: p.r = 128; p.g = 0; p.b = 0; break;
			case 2: p.r = 128; p.g = 128; p.b = 128; break;
			case 3: p.r = 0; p.g = 255; p.b = 0; break;
		}
		ang = rnd.random() * 360;
		p.x = ~~(size/2 + cosd(ang) * randf(30, 100, rnd));
		p.y = ~~(size/2 - sind(ang) * randf(30, 100, rnd));
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
				return new ut.Tile("O", p.r, p.g, p.b);
			}
		}
		// Suns
		var sunR = 0, sunG = 0, sunB = 0, mask = 0;
		for (i = 0; i < starCount; ++i) {
			var sun = self.suns[i];
			var distSquared = (x-sun.x)*(x-sun.x) + (y-sun.y)*(y-sun.y);
			if (x == pl.x && y == pl.y) console.log(Math.sqrt(distSquared));
			if (distSquared < sun.size * sun.size) {
				dist2 = Math.sqrt(distSquared) / sun.size * 256.0;
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
		r = ~~blend(sunR, r, mask/255.0);
		g = ~~blend(sunG, g, mask/255.0);
		b = ~~blend(sunB, b, mask/255.0);

		return new ut.Tile(block, star,star,star, r, g, b);
	};

	this.getShortDescription = function() {
		return "solar system";
	};

	this.getDescription = function() {
		return "solar system of " + this.suns.length + " suns and " + this.planets.length + " planets";
	};
}
