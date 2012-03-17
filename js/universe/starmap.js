
function Starmap(x, y, neighbours) {
	this.size = 256;
	this.type = "starmap";
	var simplex_exp = new SimplexNoise(new Alea('starmap_exp', x, y));
	var simplex_r = new SimplexNoise(new Alea('starmap_r', x, y));
	var simplex_g = new SimplexNoise(new Alea('starmap_g', x, y));
	var simplex_b = new SimplexNoise(new Alea('starmap_b', x, y));
	var simplex_star = new SimplexNoise(new Alea('starmap_star', x, y));
	var simplex_startype = new SimplexNoise(new Alea('starmap_startype', x, y));
	var rng = new Alea("starmap", x, y);
	this.hash = ((rng.random() * 100000000000)|0).toString(16) + "map";
	var fullRandom = new Alea();
	var STARS = [ "✦", "★", "☀", "✶", "✳", "✷", "✸" ]; // ·✧✦☼☀✳☆★✶✷✸

	var tile = neighbours(0,0);
	var bright = (!tile.ch.length || tile.ch === " ") ? 0 : tile.r;
	var starthreshold = 0.95 - 0.2 * bright / 255;
	var fogfactor = tile.br / universe.current.nebulaFade / 255;
	var coverage = 0.3 + 0.5 * fogfactor;
	var nebulascale = 0.02 + 0.02 * fogfactor;
	var colorscale = 0.03;

	var lo = (this.size*0.2)|0, hi = (this.size*0.8)|0, type;
	var npcs = [ "trader", "police", "pirate" ];
	this.actors = new Array(rand(0,20,fullRandom));
	for (var i = 0; i < this.actors.length; ++i) {
		type = npcs[rand(0, npcs.length-1, fullRandom)];
		this.actors[i] = new NPCShip(rand(lo,hi,fullRandom), rand(lo,hi,fullRandom), type);
	}

	this.getTile = function(x, y) {
		var star = simplex_star.noise(x*10,y*10);
		var block = " ";
		var desc = "";
		if (star > starthreshold) {
			star = convertNoise(simplex_startype.noise(x*100,y*100));
			block = STARS[(star / 256 * STARS.length)|0];
			star = Math.min(star+30, 255);
			desc = "Solar system";
		} else if (star > starthreshold * 0.9) {
			block = "·";
			star = 30;
		}

		var mask = simplex_exp.noise(x * nebulascale, y * nebulascale);
		mask = expFilter(mask, coverage, 0.9999);
		x *= colorscale;
		y *= colorscale;
		var br = convertNoise(simplex_r.noise(x,y) * mask);
		var bg = convertNoise(simplex_g.noise(x,y) * mask);
		var bb = convertNoise(simplex_b.noise(x,y) * mask);
		var minneb = Math.max(Math.max(br, bg), bb);
		star = Math.min(star + minneb, 255);

		var tile = new ut.Tile(block, star, star, star, br, bg, bb);
		if (mask > 0.1) tile.nebula = true;
		if (tile.nebula && !desc.length) tile.desc = "Nebula";
		else if (desc.length) tile.desc = desc;
		else tile.desc = "Vast empty space";
		return tile;
	};

	this.getMovementEnergy = function(x, y) {
		var tile = this.getTile(x, y);
		if (tile.nebula) return 120;
		return 100;
	};

	this.getDescendEnergy = function() {
		return 300;
	};

	this.getAscendEnergy = function() {
		return 10000;
	};

	this.getShortDescription = function() {
		return "star cluster";
	};

	this.getDescription = function() {
		return "star cluster";
	};
}
