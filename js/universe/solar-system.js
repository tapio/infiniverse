
var starMultiples = [
	1,1,1,1,1,1,1,1,
	1,1,1,1,1,1,1,1,
	1,1,2,2,2,2,2,2,
	2,3,3,3,3,4,4,5
];

var planetMultiples = [
	0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,
	1,1,1,2,2,2,3,3,
	4,4,5,6,7,8,9,10
];

var starTypes = [
	{ tile: new ut.Tile("✸", 200, 200, 255), radius:125, freq:1, desc:"Class O star" },
	{ tile: new ut.Tile("✷", 160, 160, 255), radius:75, freq:100, desc:"Class B star" },
	{ tile: new ut.Tile("✳", 200, 200, 255), radius:40, freq:100, desc:"Class A star" },
	{ tile: new ut.Tile("✶", 220, 220, 160), radius:25, freq:500, desc:"Class F star" },
	{ tile: new ut.Tile("☀", 255, 255, 0), radius:22, freq:1500, desc:"Class G star" },
	{ tile: new ut.Tile("★", 200, 100, 0), radius:20, freq:2200, desc:"Class K star" },
	{ tile: new ut.Tile("✦", 200, 0, 5), radius:10, freq:4500, desc:"Class M star" },
	{ tile: new ut.Tile("✧", 160, 160, 160), radius:4, freq:100, desc:"Class D star" }
];
(function() {
	// Calculate cumulative frequencies
	var starTotalFreq = 0;
	for (var i = 0; i < starTypes.length; ++i) {
		starTypes[i].freq += starTotalFreq;
		starTotalFreq = starTypes[i].freq;
	}
})();

var planetTypes = [
	{ type:"gas", tile: new ut.Tile("◌", 128, 0, 0), desc:"Gas giant" },
	{ type:"rock", tile: new ut.Tile("●", 100, 100, 100), desc:"Rock planet" },
	{ type:"ice", tile: new ut.Tile("●", 255, 255, 255), desc:"Ice planet" },
	{ type:"ocean", tile: new ut.Tile("○", 128, 128, 255), desc:"Ocean planet" },
	{ type:"gaia", tile: new ut.Tile("◍", 0, 255, 0), desc:"Terrestrial" }
];

var stationTypes = [
	{ tile: new ut.Tile("S", 100, 100, 120), desc:"Space station" }
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

	var rng = new Alea("solar-system-randomizer", x, y);
	var fullRandom = new Alea();
	var starCount = starMultiples[rand(0, starMultiples.length, rng)];
	var planetCount = planetMultiples[rand(0, planetMultiples.length, rng)];
	var stationCount = rand(0,1,rng) ? rand(1,3,rng) : 0;

	this.suns = [];
	this.planets = [];
	this.stations = [];

	var i, j;

	// Suns
	var ang = rng.random() * 360;
	for (i = 0; i < starCount; ++i) {
		var starTypeChooser = rand(0, starTypes[starTypes.length-1].freq, rng);
		var starProto;
		for (j = 0; j < starTypes.length; ++j)
			if (starTypeChooser < starTypes[j].freq) { starProto = starTypes[j]; break; }
		this.suns.push(clone(starProto));
		ang += i * (360.0 / starCount);
		var minDist = Math.min(starProto.radius*2, halfSize-5);
		this.suns[i].x = ~~(halfSize + cosd(ang) * randf(minDist, halfSize, rng));
		this.suns[i].y = ~~(halfSize - sind(ang) * randf(minDist, halfSize, rng));
	}

	// Planets
	for (i = 0; i < planetCount; ++i) {
		var planetProto = planetTypes[(rng.random()*planetTypes.length)|0];
		this.planets.push(clone(planetProto));
		this.planets[i].tile.desc = planetProto.desc;
		if (this.planets[i].type === "gas")
			this.planets[i].gasType = rand(0,5,rng);
		ang = rng.random() * 360;
		this.planets[i].x = ~~(halfSize + cosd(ang) * randf(30, halfSize*0.6, rng));
		this.planets[i].y = ~~(halfSize - sind(ang) * randf(30, halfSize*0.6, rng));
	}

	// Space stations
	for (i = 0; i < stationCount; ++i) {
		this.stations.push(clone(stationTypes[0]));
		this.stations[i].tile.desc = this.stations[i].desc;
		ang = rng.random() * 360;
		this.stations[i].x = ~~(halfSize + cosd(ang) * randf(30, halfSize*0.5, rng));
		this.stations[i].y = ~~(halfSize - sind(ang) * randf(30, halfSize*0.5, rng));
	}

	// Actors
	if (rand(0,5,rng) === 0) {
		var lo = (this.size*0.2)|0, hi = (this.size*0.8)|0, npctype;
		var hostile = (rand(0,3,rng) === 0);
		var npcs = [ "trader", "police" ];
		this.actors = new Array(rand(1, 20, fullRandom));
		for (i = 0; i < this.actors.length; ++i) {
			npctype = hostile ? "pirate" : npcs[rand(0, npcs.length-1, fullRandom)];
			this.actors[i] = new NPCShip(rand(lo,hi,fullRandom), rand(lo,hi,fullRandom), npctype);
		}
	}

	// Can't use 'this' here due to passing this function to the tile engine
	this.getTile = function(x, y) {
		var i, obj, tile;
		var desc = "Empty space";
		// Background stars
		var star = convertNoise(simplex_bgstars.noise(x*10, y*10));
		var block = " ";
		if (star % 10 === 0) {
			block = "·";
			star = Math.min(star+50, 255);
		}
		// Planets
		for (i = 0; i < planetCount; ++i) {
			obj = self.planets[i];
			if (x == obj.x && y == obj.y) {
				tile = obj.tile;
				tile.planet = obj; // Attach planet reference
				return tile;
			}
		}
		// Stations
		for (i = 0; i < stationCount; ++i) {
			obj = self.stations[i];
			if (x == obj.x && y == obj.y) {
				return obj.tile;
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
				sunR = clampColor(sun.tile.r + rand(-20, 20, rng));
				sunG = clampColor(sun.tile.g + rand(-20, 20, rng));
				sunB = clampColor(sun.tile.b + rand(-20, 20, rng));
				block = " ";
				desc = sun.desc;
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
		tile = new ut.Tile(block, star,star,star, r, g, b);
		tile.desc = desc;
		return tile;
	};

	this.getMovementEnergy = function(x, y) {
		return 5;
	};

	this.getDescendEnergy = function() {
		return 50;
	};

	this.getAscendEnergy = function() {
		return 1000;
	};

	this.getShortDescription = function() {
		return "solar system";
	};

	this.getDescription = function() {
		return "solar system of " + this.suns.length + " suns and " + this.planets.length + " planets";
	};
}
