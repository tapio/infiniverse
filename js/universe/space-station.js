
function SpaceStation(x, y, neighbours) {
	this.size = 64;
	this.type = "station";
	this.name = "";

	var tile = neighbours(0,0);
	if (tile.ch !== "S")
		throw "Can't dock there.";

	var i,j,d;
	var hsize = (this.size/2)|0;
	var rng = new Alea("space-station", x, y);
	for (i = 0; i < 10; ++i) this.name += (~~(rng.random()*16)).toString(16);

	var buffer = new Array(this.size);
	for (i = 0; i < this.size; ++i)
		buffer[i] = new Array(this.size);

	var tileProtos = {
		space: new ut.Tile(),
		wall: new ut.Tile("#", 100, 100, 100, 20, 20, 20),
		floor: new ut.Tile(".", 140, 140, 140, 20, 20, 20)
	};
	tileProtos.wall.desc = "Wall";
	tileProtos.wall.blocks = true;
	tileProtos.floor.desc = "Floor";

	var radius = (hsize*0.66)|0;
	for (j = 0; j < this.size; ++j) {
		for (i = 0; i < this.size; ++i) {
			d = distance(hsize, hsize, i, j)|0;
			if (d > radius+1) {
				if (rand(0, 3, rng) === 0) {
					var star = rand(50, 200, rng);
					buffer[j][i] = new ut.Tile("·", star, star, star);
				} else buffer [j][i] = tileProtos.space;
			} else if (d < radius) buffer[j][i] = clone(tileProtos.floor);
			else buffer[j][i] = clone(tileProtos.wall);
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
		return "space station";
	};

	this.getDescription = function() {
		return "space station " + this.name;
	};
}
