
var stationTileProtos = {
	space: new ut.Tile(),
	wall: new ut.Tile("#", 100, 100, 100, 20, 20, 20),
	floor: new ut.Tile(".", 140, 140, 140, 20, 20, 20)
};
stationTileProtos.wall.desc = "Wall";
stationTileProtos.wall.blocks = true;
stationTileProtos.floor.desc = "Floor";

function createBox(buf, x, y, w, h, doorx, doory) {
	for (var i = x; i <= x+w; ++i) {
		buf[y][i] = stationTileProtos.wall;
		buf[y+h][i] = stationTileProtos.wall;
	}
	for (var j = y+1; j <= y+h-1; ++j) {
		buf[j][x] = stationTileProtos.wall;
		buf[j][x+w] = stationTileProtos.wall;
	}
	if (doorx !== undefined && doory !== undefined)
		buf[doory][doorx] = stationTileProtos.floor;
}

function createShop(buf, x, y, type) {
	var shopw = 10, shoph = 10;
	var hw = (shopw/2)|0, hh = (shoph/2)|0;
	createBox(buf, x-hw, y-hh, shopw, shoph, x, y + hh);
	var namelen = 2 + "Shop".length;
	var startx = x - Math.ceil(namelen/2), i;
	buf[y-hh+1][startx] = replaceBackground(clone(type), stationTileProtos.floor);
	for (i = 2; i < namelen; ++i)
		buf[y-hh+1][startx+i] = replaceBackground(new ut.Tile("Shop"[i-2], 255, 255, 255), stationTileProtos.floor);
	for (i = x-hw; i <= x+hw; ++i)
		buf[y-hh+2][i] = stationTileProtos.wall;
}

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
	this.hash = ((rng.random() * 100000000000)|0).toString(16) + "sta";

	var buffer = new Array(this.size);
	for (i = 0; i < this.size; ++i)
		buffer[i] = new Array(this.size);

	var radius = (hsize*0.66)|0;
	for (j = 0; j < this.size; ++j) {
		for (i = 0; i < this.size; ++i) {
			d = distance(hsize, hsize, i, j)|0;
			if (d > radius+1) {
				if (rand(0, 3, rng) === 0) {
					var star = rand(50, 200, rng);
					buffer[j][i] = new ut.Tile("·", star, star, star);
				} else buffer [j][i] = stationTileProtos.space;
			} else if (d < radius) buffer[j][i] = clone(stationTileProtos.floor);
			else buffer[j][i] = clone(stationTileProtos.wall);
		}
	}

	var shopCount = rand(2, 4, rng);
	var shopPos = [ {x:0,y:-1}, {x:-1,y:0}, {x:1,y:0}, {x:0,y:1} ];
	shuffle(shopPos, rng);
	var shopTypes = [];
	for (i in UniverseItems)
		if (UniverseItems.hasOwnProperty(i)) shopTypes.push(UniverseItems[i]);
	shuffle(shopTypes, rng);
	for (i = 0; i < shopCount; ++i) {
		createShop(buffer, shopPos[i].x*13+hsize, shopPos[i].y*13+hsize, shopTypes[i]);
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
