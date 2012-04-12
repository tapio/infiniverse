
function PlanetDetail(x, y, neighbours, hash) {
	this.size = 50;
	this.type = "detail";

	var tile = neighbours(0,0);
	if (tile.ch === "≋")
		throw "Find solid ground to land on.";
	if (tile.ch === "▒")
		throw "Gas planet has no surface to land on.";

	var i,j;
	var rng = new Alea('planet-detail', x, y, hash);
	this.hash = ((rng.random() * 100000000000)|0).toString(16) + "det";
	var simplex_bare = new SimplexNoise(new Alea('planet-detail-noise', x, y, this.hash));
	var buffer = new Array(this.size);
	for (i = 0; i < this.size; ++i)
		buffer[i] = new Array(this.size);

	tiles = [
		neighbours(-1,  1),
		neighbours( 0,  1),
		neighbours( 1,  1),
		neighbours(-1,  0),
		tile,
		neighbours( 1,  0),
		neighbours(-1, -1),
		neighbours( 0, -1),
		neighbours( 1, -1)
	];

	var gr = tile.bare;
	var bs = 0.06;
	var noiseTol = 0.333;
	var hs = this.size * 0.50;
	var fs = this.size * 0.75;
	var sqr2 = Math.SQRT2;
	var freqs = [ {}, {}, {}, {} ];

	function highestFreqTile() {
		var winner = 0;
		for (var i = 1; i < freqs.length; ++i)
			if (freqs[i].f > freqs[winner].f) winner = i;
		return freqs[winner].t;
	}

	function addRoughness(x, y) {
		if (buffer[y][x].ch === ".") {
			var rndvalue = rng.random();
			if (rndvalue > 0.95) {
				buffer[y][x].ch = "o";
				buffer[y][x].desc = "Rock";
			} else if (rndvalue > 0.7) {
				buffer[y][x].ch = ",";
			}
		}
		addVariance(buffer[y][x], 5, rng);
	}

	// NE quadrant
	freqs = [ {t:tiles[4]}, {t:tiles[7]}, {t:tiles[3]}, {t:tiles[6]} ];
	for (j = 0; j < hs; ++j) {
		for (i = 0; i < hs; ++i) {
			freqs[0].f = 1.0 - (distance(i,j,hs,hs) / (fs*sqr2)) + randf(0,0.333,rng);
			freqs[1].f = (Math.abs(j-hs) / fs) + randf(0,0.333,rng);
			freqs[2].f = (Math.abs(i-hs) / fs) + randf(0,0.333,rng);
			freqs[3].f = (distance(i,j,hs,hs) / (fs*sqr2)) + randf(0,0.333,rng);
			buffer[j][i] = clone(highestFreqTile());
			if (gr && buffer[j][i].ch !== gr.ch && (rng.random() < 0.333 || simplex_bare.noise(i*bs,j*bs) < noiseTol))
				buffer[j][i] = clone(gr);
			addRoughness(i,j);
		}
	}
	// NW quadrant
	freqs = [ {t:tiles[4]}, {t:tiles[7]}, {t:tiles[5]}, {t:tiles[8]} ];
	for (j = 0; j < hs; ++j) {
		for (i = hs; i < this.size; ++i) {
			freqs[0].f = 1.0 - (distance(i,j,hs,hs) / (fs*sqr2)) + randf(0,0.333,rng);
			freqs[1].f = (Math.abs(j-hs) / fs) + randf(0,0.333,rng);
			freqs[2].f = (Math.abs(i-hs) / fs) + randf(0,0.333,rng);
			freqs[3].f = (distance(i,j,hs,hs) / (fs*sqr2)) + randf(0,0.333,rng);
			buffer[j][i] = clone(highestFreqTile());
			if (gr && buffer[j][i].ch !== gr.ch && (rng.random() < 0.333 || simplex_bare.noise(i*bs,j*bs) < noiseTol))
				buffer[j][i] = clone(gr);
			addRoughness(i,j);
		}
	}
	// SW quadrant
	freqs = [ {t:tiles[4]}, {t:tiles[1]}, {t:tiles[3]}, {t:tiles[0]} ];
	for (j = hs; j < this.size; ++j) {
		for (i = 0; i < hs; ++i) {
			freqs[0].tile = tiles[4]; freqs[0].f = 1.0 - (distance(i,j,hs,hs) / (fs*sqr2)) + randf(0,0.333,rng);
			freqs[1].tile = tiles[1]; freqs[1].f = (Math.abs(j-hs) / fs) + randf(0,0.333,rng);
			freqs[2].tile = tiles[3]; freqs[2].f = (Math.abs(i-hs) / fs) + randf(0,0.333,rng);
			freqs[3].tile = tiles[0]; freqs[3].f = (distance(i,j,hs,hs) / (fs*sqr2)) + randf(0,0.333,rng);
			buffer[j][i] = clone(highestFreqTile());
			if (gr && buffer[j][i].ch !== gr.ch && (rng.random() < 0.333 || simplex_bare.noise(i*bs,j*bs) < noiseTol))
				buffer[j][i] = clone(gr);
			addRoughness(i,j);
		}
	}
	// SE quadrant
	freqs = [ {t:tiles[4]}, {t:tiles[1]}, {t:tiles[5]}, {t:tiles[2]} ];
	for (j = hs; j < this.size; ++j) {
		for (i = hs; i < this.size; ++i) {
			freqs[0].f = 1.0 - (distance(i,j,hs,hs) / (fs*sqr2)) + randf(0,0.333,rng);
			freqs[1].f = (Math.abs(j-hs) / fs) + randf(0,0.333,rng);
			freqs[2].f = (Math.abs(i-hs) / fs) + randf(0,0.333,rng);
			freqs[3].f = (distance(i,j,hs,hs) / (fs*sqr2)) + randf(0,0.333,rng);
			buffer[j][i] = clone(highestFreqTile());
			if (gr && buffer[j][i].ch !== gr.ch && (rng.random() < 0.333 || simplex_bare.noise(i*bs,j*bs) < noiseTol))
				buffer[j][i] = clone(gr);
			addRoughness(i,j);
		}
	}

	// Create collectables
	if (universe.getItems(this.hash) === undefined) {
		if (rand(0,2,rng) === 0) {
			var cnt = rand(0,3,rng) === 0 ? rand(3,10,rng) : rand(1,3,rng);
			for (i = 0; i < cnt; ++i) {
				universe.addItem({
					tile: clone(UniverseItems.metals),
					x: rand(0, this.size-1, rng),
					y: rand(0, this.size-1, rng)
				}, this.hash);
			}
			cnt = rand(0,3,rng) === 0 ? rand(1,3,rng) : 0;
			for (i = 0; i < cnt; ++i) {
				universe.addItem({
					tile: clone(UniverseItems.radioactives),
					x: rand(0, this.size-1, rng),
					y: rand(0, this.size-1, rng)
				}, this.hash);
			}
		}
	}

	this.getTile = function(x, y) {
		return buffer[y][x];
	};

	this.getMovementEnergy = function(x, y) {
		return 0;
	};

	this.getDescendEnergy = function() {
		return -1;
	};

	this.getAscendEnergy = function() {
		return 20;
	};

	this.getShortDescription = function() {
		return "planet surface";
	};

	this.getDescription = function() {
		return "planet surface";
	};
}
