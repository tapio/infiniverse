
function pickBackground(t, rng) {
	var dir, lo, hi;
	var colorSum = t.br + t.bg + t.bb;
	if (colorSum > 660) dir = 0;
	else if (colorSum < 200) dir = 1;
	else dir = rand(0, 1, rng);
	if (dir === 0) { lo = -40; hi = -25; }
	else if (dir === 1) { lo = 25; hi = 40; }
	t.br = clampColor(t.r + rand(lo, hi, rng));
	t.bg = clampColor(t.g + rand(lo, hi, rng));
	t.bb = clampColor(t.b + rand(lo, hi, rng));
	return t;
}

function replaceBackground(t, bg) {
	t.br = bg.br; t.bg = bg.bg; t.bb = bg.bb;
	return t;
}

function addVariance(t, amount, rng) {
	if (t.r !== undefined) {
		t.r = clampColor(t.r + rand(-amount, amount, rng));
		t.g = clampColor(t.g + rand(-amount, amount, rng));
		t.b = clampColor(t.b + rand(-amount, amount, rng));
	}
	if (t.br === undefined) return t;
	t.br = clampColor(t.br + rand(-amount, amount, rng));
	t.bg = clampColor(t.bg + rand(-amount, amount, rng));
	t.bb = clampColor(t.bb + rand(-amount, amount, rng));
	return t;
}

function PlanetAerial(x, y, neighbours) {
	this.size = 128;
	this.type = "aerial";
	var self = this;
	var tile = neighbours(0,0);
	this.planet = tile.planet;
	if (!this.planet)
		throw "Find a planet to land.";
	var planetType = this.planet.type;

	var simplex_height = new SimplexNoise(new Alea('planet_height', x, y));
	var simplex_vegetation = new SimplexNoise(new Alea('planet_vegetation', x, y));
	var simplex_temperature = new SimplexNoise(new Alea('planet_temperature', x, y));
	var simplex_rainfall = new SimplexNoise(new Alea('planet_rainfall', x, y));

	var rng = new Alea("texture-RNG", x, y);
	var c = function(lo,hi) { return rand(lo,hi,rng); };
	this.heightTextures = [];
	var vegeTextures = {};
	var groundTextures = {};

	this.hash = ((rng.random() * 100000000000)|0).toString(16) + "pla";

	// Create collectables
	var cnt;
	if (planetType === "gas" && universe.getItems(this.hash) === undefined) {
		cnt = rand(0,10,rng);
		for (i = 0; i < cnt; ++i) {
			universe.addItem({
				tile: clone(UniverseItems.hydrogen),
				x: rand(0, this.size-1, rng),
				y: rand(0, this.size-1, rng)
			}, this.hash);
		}
		cnt = rand(0,3,rng);
		for (i = 0; i < cnt; ++i) {
			universe.addItem({
				tile: clone(UniverseItems.radioactives),
				x: rand(0, this.size-1, rng),
				y: rand(0, this.size-1, rng)
			}, this.hash);
		}
	}

	this.generateGroundTextures = function() {
		var r,g,b;
		do {
			r = c(0,255); g = c(0,255); b = c(0,255);
		} while (r+g+b > 384 && b > r && b > g);
		groundTextures.warm = pickBackground(new ut.Tile(".", r,g,b), rng);
		groundTextures.warm.desc = "Desert";
		groundTextures.cold = pickBackground(new ut.Tile(".", c(200,255), c(200,255), c(200,255)), rng);
		groundTextures.cold.desc = "Icy ground";

		var curH = 0;
		if (this.waterLevel) {
			this.heightTextures.push({
				tile: pickBackground(new ut.Tile("≋", c(0,64),c(0,128),100+c(0,155)), rng),
				minh: 0
			});
			last(this.heightTextures).tile.desc = "Water";
			curH = this.waterLevel;
		}
		do { r = c(0,255); g = c(0,255); b = c(0,255); } while (r+g+b > 384);
		this.heightTextures.push({
			tile: pickBackground(new ut.Tile(".", r,g,b), rng),
			minh: curH
		});
		last(this.heightTextures).tile.desc = "Ground";
		curH += (1.0 - curH) * 0.5;
		if (curH > 0.95) return;
		this.heightTextures.push({
			tile: pickBackground(new ut.Tile("▴", r,g,b), rng),
			minh: curH
		});
		last(this.heightTextures).tile.desc = "Hills";
		curH += (1.0 - curH) * 0.5;
		if (curH > 0.95) return;
		function avg(a,b) { return ((a+b)/2)|0; }
		this.heightTextures.push({
			tile: pickBackground(new ut.Tile("▲", avg(groundTextures.cold.r, r), avg(groundTextures.cold.g, g), avg(groundTextures.cold.b, b)), rng),
			minh: curH
		});
		last(this.heightTextures).tile.desc = "Mountains";
		curH += (1.0 - curH) * 0.5;
		if (curH > 0.95) return;
		this.heightTextures.push({
			tile: pickBackground(new ut.Tile("▲", groundTextures.cold.r, groundTextures.cold.g, groundTextures.cold.b), rng),
			minh: curH
		});
		last(this.heightTextures).tile.desc = "High peaks";
	};

	this.generateClutterTextures = function() {
		var rockChars = "Oo⌓∙∘";
	};

	this.generateVegetationTextures = function() {
		var grassChars = ".,'";
		var bushChars = "t☙⌓";
		var treeChars = "T§£&%☤⚚⚕⚘☘♣♠♧♤¤";
		vegeTextures.cold = new ut.Tile(randchar(treeChars, rng), c(0,255), c(0,255), c(0,255));
		vegeTextures.base = new ut.Tile(randchar(treeChars, rng), c(0,255), c(0,255), c(0,255));
		vegeTextures.base_humid = new ut.Tile(randchar(treeChars, rng), c(0,255), c(0,255), c(0,255));
		vegeTextures.warm = new ut.Tile(randchar(treeChars, rng), c(0,255), c(0,255), c(0,255));
		vegeTextures.warm_humid = new ut.Tile(randchar(treeChars, rng), c(0,255), c(0,255), c(0,255));
		vegeTextures.cold.desc = "Tundra";
		vegeTextures.base.desc = "Forest";
		vegeTextures.base_humid.desc = "Swamp";
		vegeTextures.warm.desc = "Savannah";
		vegeTextures.warm_humid.desc = "Jungle";
	};

	if (planetType === "ocean") this.waterLevel = randf(0.8, 1.0, rng);
	else if (planetType === "gaia") this.waterLevel = randf(0.2, 0.7, rng);
	else if (planetType === "ice") this.waterLevel = randf(0.0, 0.1, rng);
	if (planetType !== "gas") {
		this.generateGroundTextures();
		this.generateClutterTextures();
	}
	if (planetType === "gaia") {
		this.generateVegetationTextures();
	}

	this.getGasTile = function(x, y) {
		var gas1 = convertNoise(simplex_height.noise(x*0.03, y*0.03));
		var gas2 = convertNoise(simplex_temperature.noise(x*0.03, y*0.03));
		var gas3 = convertNoise(simplex_rainfall.noise(x*0.03, y*0.03));
		var r = 0, g = 0, b = 0;
		switch (self.planet.gasType) {
			case 0: r = gas1; g = gas2; break;
			case 1: r = gas1; b = gas3; break;
			case 2: g = gas2; b = gas3; break;
			case 3: r = gas1; g = gas1; b = gas3; break;
			case 4: r = gas1; g = gas2; b = gas1; break;
			case 5: r = gas1; g = gas2; b = gas2; break;
		}
		var tile = new ut.Tile("▒", r,g,b, clampColor(r*0.6), clampColor(g*0.6), clampColor(b*0.6));
		tile.desc = "Gas";

		var item = universe.getItem(x, y, this.hash);
		if (item) return replaceBackground(item, tile);
		return tile;
	};

	this.getTile = function(x, y) {
		x = x % self.size;
		y = y % self.size;
		if (planetType == "gas") return self.getGasTile(x, y);
		var rng = new Alea(x, y);
		var i, basetile;
		// Get the tile based on height
		var h = simplex_height.noise(x*0.05, y*0.05);
		for (i = self.heightTextures.length-1; i >= 0; --i) {
			basetile = self.heightTextures[i];
			if (h > basetile.minh) break;
		}
		var modtile = clone(basetile.tile);
		// Handle water
		if (self.waterLevel && h <= self.waterLevel) {
			// TODO: Animate waves etc.
			return addVariance(modtile, 7, rng);
		}
		// High altitudes as is
		if (h > 0.7) return addVariance(modtile, 7, rng);
		// Icy ground for ice planets
		if (planetType === "ice") return addVariance(clone(groundTextures.cold), 7, rng);
		// Nothing grows on non-gaia worlds
		if (planetType !== "gaia") return addVariance(modtile, 7, rng);
		// Determine vegetation parameters
		var vegetation = simplex_vegetation.noise(x*0.06, y*0.06);
		var rainfall = simplex_rainfall.noise(x*0.03, y*0.03);
		var temperature = (1-(Math.abs(self.size/2-y)*2 / self.size))*7 + (1.0-h)*2;
		temperature += simplex_temperature.noise(x*0.07, y*0.07);
		temperature /= 10;
		// Get special ground
		var gndtile = clone(modtile);
		if (temperature > 0.7 && rainfall < 0.4) gndtile = groundTextures.warm;
		if (temperature < 0.3) gndtile = groundTextures.cold;
		// Vegetation?
		var veg;
		if (vegetation > 0.5) {
			if (temperature > 0.6 && rainfall > 0.6) veg = vegeTextures.warm_humid;
			else if (between(temperature,0.50,0.63) && rainfall > 0.63) veg = vegeTextures.base_humid;
			else if (between(temperature,0.25,0.63) && rainfall > 0.15) veg = vegeTextures.base;
			else if (between(temperature,0.07,0.30) && rainfall > 0.15) veg = vegeTextures.cold;
			else if (between(temperature,0.63,0.80) && between(rainfall,0.15,0.30)) veg = vegeTextures.warm;
		}
		modtile.bare = gndtile;
		modtile.desc = gndtile.desc;
		modtile.br = gndtile.r;
		modtile.bg = gndtile.g;
		modtile.bb = gndtile.b;
		if (veg) {
			modtile.ch = veg.ch;
			modtile.r = veg.r;
			modtile.g = veg.g;
			modtile.b = veg.b;
			modtile.desc = veg.desc;
		}
		return addVariance(modtile, 5, rng);
	};

	this.getMovementEnergy = function(x, y) {
		return 2;
	};

	this.getDescendEnergy = function() {
		return 10;
	};

	this.getAscendEnergy = function() {
		return 200;
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
	} catch (e) {
		if ("string" !== typeof e) console.log(e);
	}
	return new PlanetAerial(x, y, neighbours);
}
