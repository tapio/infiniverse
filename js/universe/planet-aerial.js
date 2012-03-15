
function addVariance(t, amount, rng) {
	if (t.r) {
		t.r = clampColor(t.r + rand(-amount, amount, rng));
		t.g = clampColor(t.g + rand(-amount, amount, rng));
		t.b = clampColor(t.b + rand(-amount, amount, rng));
	}
	if (!t.br) return;
	t.br = clampColor(t.r + rand(-amount, amount, rng));
	t.bg = clampColor(t.g + rand(-amount, amount, rng));
	t.bb = clampColor(t.b + rand(-amount, amount, rng));
}

function PlanetAerial(x, y, neighbours) {
	this.size = 64;
	this.type = "aerial";
	var self = this;
	var tile = neighbours(0,0);
	this.planet = tile.planet;
	if (!this.planet)
		throw "Find a planet to land.";
	var planetType = this.planet.type;

	var simplex_height = new SimplexNoise(new Alea('planet_height', x, y));
	var simplex_vegetation = new SimplexNoise(new Alea('planet_vegetation', x, y));
	var rng = new Alea("texture-RNG", x, y);
	var r = function(lo,hi) { return rand(lo,hi,rng); };
	this.heightTextures = [];
	this.clutterTextures = [];
	this.vegetationTextures = [];

	this.generateHeightTextures = function() {
		var curH = 0;
		if (this.waterLevel) {
			this.heightTextures.push({
				tile: new ut.Tile("≋", r(0,20),r(0,20),r(150,255), 0,0,r(80,100)),
				minh: 0
			});
			curH = this.waterLevel;
		}
		this.heightTextures.push({
			tile: new ut.Tile(".", 128,128,128, 100,100,100),
			minh: curH
		});
		curH += (1.0 - curH) * 0.5;
		if (curH > 0.95) return;
		this.heightTextures.push({
			tile: new ut.Tile("▴", 128,128,128, 100,100,100),
			minh: curH
		});
		curH += (1.0 - curH) * 0.5;
		if (curH > 0.95) return;
		this.heightTextures.push({
			tile: new ut.Tile("▲", 128,128,128, 100,100,100),
			minh: curH
		});
		curH += (1.0 - curH) * 0.5;
		if (curH > 0.95) return;
		this.heightTextures.push({
			tile: new ut.Tile("▲", 255,255,255, 100,100,100),
			minh: curH
		});
	};

	this.generateClutterTextures = function() {
		var rockChars = "Oo⌓∙∘";
	};

	this.generateVegetationTextures = function() {
		var grassChars = ".,'";
		var bushChars = "t☙⌓";
		var treeChars = "T☤⚚⚕⚘☘♣♠♧♤";
		this.vegetationTextures.push({
			tile: new ut.Tile(treeChars[r(0,treeChars.length-1)], 0,200,0)
		});

	};

	if (planetType === "ocean") this.waterLevel = randf(0.8, 1.0, rng);
	else if (planetType === "gaia") this.waterLevel = randf(0.2, 0.7, rng);
	else if (planetType === "ice") this.waterLevel = randf(0.0, 0.1, rng);
	if (planetType !== "gas") {
		this.generateHeightTextures();
		this.generateClutterTextures();
	}
	if (planetType === "gaia") this.generateVegetationTextures();

	this.getTile = function(x, y) {
		x = x % self.size;
		y = y % self.size;
		if (planetType == "gas") {
			var gas = convertNoise(simplex_height.noise(x*0.03, y*0.03));
			return new ut.Tile("▒", 200,200,200, gas,gas,gas);
		}
		// Get the tile based on height
		var h = simplex_height.noise(x*0.05, y*0.05);
		var i, basetile;
		for (i = self.heightTextures.length-1; i >= 0; --i) {
			basetile = self.heightTextures[i];
			if (h > basetile.minh) break;
		}
		// Handle water
		if (self.waterLevel && h <= self.waterLevel) {
			// TODO: Animate wind etc.
			return basetile.tile;
		}
		var modtile = basetile.tile.clone();
		//addVariance(modtile, 10, rng);
		// Nothing grows on non-gaia worlds, nor at high altitudes
		if (planetType !== "gaia" || h > 0.7) return modtile;
		// Determine vegetation (if any)
		var vegtile;
		var veg = simplex_height.noise(x*0.06, y*0.06);
		if (veg < 0.6) return modtile;
		vegtile = self.vegetationTextures[0].tile;
		modtile.ch = vegtile.ch;
		modtile.r = vegtile.r;
		modtile.g = vegtile.g;
		modtile.b = vegtile.b;
		return modtile;
	};

	this.getShortDescription = function() {
		return this.planet.desc.toLowerCase();
	};

	this.getDescription = function() {
		return this.planet.desc.toLowerCase();
	};
}


function PlanetProxy(x, y, neighbours) {
	try {
		return new SpaceStation(x, y, neighbours);
	} catch (e) {}
	return new PlanetAerial(x, y, neighbours);
}
