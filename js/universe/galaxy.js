
function Galaxy() {
	this.size = 60;
	this.type = "galaxy";
	this.nebulaFade = 0.333;
	var self = this;
	var NUMHUB   = 2000; // Number of stars in the core (Example: 2000)
	var NUMDISK  = 4000; // Number of stars in the disk (Example: 4000)
	var DISKRAD  = 90.0; // Radius of the disk (Example: 90.0)
	var HUBRAD   = 45.0; // Radius of the hub (Example: 45.0)
	var NUMARMS  = 2; // Number of arms (Example: 3)
	var ARMROTS  = 1.0; // 0.45 // Tightness of winding (Example: 0.5)
	var ARMWIDTH = 60; // 15.0 // Arm width in degrees (Not affected by number of arms or rotations)
	var FUZZ     = 25; // 25.0 // Maximum outlier distance from arms (Example: 25.0)

	var rnd = new Alea('galaxy');
	this.hash = ((rnd.random() * 100000000000)|0).toString(16) + "gal";

	var i, j, sx, sy;
	var buffer = new Array(this.size);
	for (j = 0; j < this.size; ++j) {
		buffer[j] = new Array(this.size);
		for (i = 0; i < this.size; ++i)
			buffer[j][i] = 0;
	}

	var armSeparation, angle, dist, maxim = 0;
	var stars = [];
	for (i = 0; i < NUMHUB + NUMDISK; ++i)
		stars.push({ "x":0, "y":0 });

	// Arms
	armSeparation = 360.0 / NUMARMS;
	for (i = 0; i < NUMDISK; ++i) {
		dist = HUBRAD + rnd.random() * DISKRAD;
		// This is the clever bit, that puts a star at a given distance
		// into an arm: First, it wraps the star round by the number of
		// rotations specified. By multiplying the distance by the number of
		// rotations the rotation is proportional to the distance from the
		// center, to give curvature
		angle = ( (360.0 * ARMROTS * (dist / DISKRAD)) +
				rnd.random() * ARMWIDTH + // move the point further around by a random factor up to ARMWIDTH
				(armSeparation * (~~(rnd.random() * NUMARMS)+1) ) + // multiply the angle by a factor of armSeparation, putting the point into one of the arms
				rnd.random() * FUZZ * 2.0 - FUZZ ); // add a further random factor, fuzzing the edge of the arms
		//  Convert to cartesian
		stars[i].x = cosd(angle) * dist;
		stars[i].y = sind(angle) * dist;
		maxim = Math.max(maxim, dist);
	}

	// Center
	for (i = NUMDISK; i < NUMDISK+NUMHUB; ++i) {
		dist = rnd.random() * HUBRAD;
		angle = rnd.random() * 360;
		stars[i].x = cosd(angle) * dist;
		stars[i].y = sind(angle) * dist;
		maxim = Math.max(maxim, dist);
	}

	// Fit the galaxy to the requested size
	var factor = this.size / (maxim * 2);
	for (i = 0; i < NUMHUB+NUMDISK; ++i) {
		sx = ~~mapRange(stars[i].x, -maxim, maxim, 0, this.size-1);
		sy = ~~mapRange(stars[i].y, -maxim, maxim, 0, this.size-1);
		buffer[sy][sx] = Math.min(255, Math.floor(buffer[sy][sx])+1);
	}

	// Create tiles
	var simplex_neb = new SimplexNoise(new Alea('galaxy_noise'));
	var STARS = [ " ", "✦", "★", "☀", "✶", "✳", "✷", "✸" ]; // ✧✦☼☀✳☆★✶✷✸
	var block;
	for (j = 0; j < this.size; ++j) {
		for (i = 0; i < this.size; ++i) {
			var bg = convertNoise(simplex_neb.noise(i*0.05,j*0.05));
			bg = (bg * this.nebulaFade) | 0;
			var star = Math.min(100 + buffer[j][i] * 20, 255);
			block = isNaN(star) ? " " : STARS[~~mapRange(star, 100, 255, 0, STARS.length-1)];
			buffer[j][i] = new ut.Tile(block, star,star,star, bg,bg,bg);
			buffer[j][i].desc = "Millions of stars";
		}
	}

	this.getTile = function(x, y) {
		return buffer[y][x];
	};

	this.getMovementEnergy = function(x, y) {
		return 100000;
	};

	this.getDescendEnergy = function() {
		return 1000;
	};

	this.getAscendEnergy = function() {
		return -1;
	};

	this.getShortDescription = function() {
		return "galaxy";
	};

	this.getDescription = function() {
		return "galaxy";
	};
}
