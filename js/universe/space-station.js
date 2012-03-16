
function SpaceStation(x, y, neighbours) {
	this.size = 64;
	this.type = "station";
	this.name = "";

	var tile = neighbours(0,0);
	if (tile.ch !== "S")
		throw "Can't dock there.";

	var i,j;
	var rng = new Alea("space-station", x, y);
	for (i = 0; i < 10; ++i) this.name += (~~(rng.random()*16)).toString(16);

	var buffer = new Array(this.size);
	for (i = 0; i < this.size; ++i)
		buffer[i] = new Array(this.size);

	var tileProtos = {
		wall: new ut.Tile("#", 100, 100, 100, 20, 20, 20),
		floor: new ut.Tile(".", 140, 140, 140, 20, 20, 20)
	};
	tileProtos.wall.desc = "Wall";
	tileProtos.floor.desc = "Floor";
	for (j = 0; j < this.size; ++j) {
		for (i = 0; i < this.size; ++i) {
			if (i === 0 || i == this.size-1 || j === 0 || j == this.size-1)
				buffer[j][i] = clone(tileProtos.wall);
			else buffer[j][i] = clone(tileProtos.floor);
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
