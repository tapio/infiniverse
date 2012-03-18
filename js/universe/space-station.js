
var stationTileProtos = {
	space: new ut.Tile(),
	wall: new ut.Tile("#", 100, 100, 100, 20, 20, 20),
	floor: new ut.Tile(".", 140, 140, 140, 20, 20, 20),
	buy: new ut.Tile("+", 0, 180, 0, 20, 20, 20),
	sell: new ut.Tile("-", 187, 100, 0, 20, 20, 20),
	price: new ut.Tile("$", 187, 187, 0, 20, 20, 20),
	textbg: new ut.Tile(" ", 255, 255, 255, 20, 20, 20)
};
stationTileProtos.wall.desc = "Wall";
stationTileProtos.wall.blocks = true;
stationTileProtos.floor.desc = "Floor";
stationTileProtos.buy.desc = "Buy goods";
stationTileProtos.sell.desc = "Sell goods";

var CustomShops = {};

CustomShops.cargoUpgrade = new ut.Tile("C", 180, 130, 0, 20, 20, 20);
CustomShops.cargoUpgrade.desc = "Cargo space upgrade";
CustomShops.cargoUpgrade.shopTitle = "Cargo +1";
CustomShops.cargoUpgrade.item = "cargoslot";
CustomShops.cargoUpgrade.baseprice = 200;

CustomShops.hullUpgrade = new ut.Tile("H", 180, 130, 0, 20, 20, 20);
CustomShops.hullUpgrade.desc = "Hull strength upgrade";
CustomShops.hullUpgrade.shopTitle = "Hull +20";
CustomShops.hullUpgrade.item = "hull";
CustomShops.hullUpgrade.baseprice = 500;

CustomShops.repair = new ut.Tile("R", 150, 0, 0, 20, 20, 20);
CustomShops.repair.desc = "Repair damage";
CustomShops.repair.shopTitle = "Repair";
CustomShops.repair.item = "repair";
CustomShops.repair.baseprice = 50;


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

function fillBox(buf, tile, x, y, w, h) {
	for (var j = y; j <= y+h; ++j)
		for (var i = x; i <= x+w; ++i)
			buf[j][i] = tile;
}

function putText(buf, text, x, y, protoTile, right_justify) {
	protoTile = protoTile || stationTileProtos.floor;
	var i;
	if (!right_justify) {
		for (i = 0; i < text.length; ++i) {
			buf[y][x+i] = clone(protoTile);
			buf[y][x+i].ch = text[i];
		}
	} else {
		for (i = 0; i < text.length; ++i) {
			buf[y][x-i] = clone(protoTile);
			buf[y][x-i].ch = text[text.length - i - 1];
		}
	}
}

function createShop(buf, x, y, type) {
	var shopw = 10, shoph = 10;
	var hw = (shopw/2)|0, hh = (shoph/2)|0;
	var startx, endx;
	var i, row = y-hh;
	var isSpecial = (type.shopTitle !== undefined);
	// Outer wall
	createBox(buf, x-hw, row, shopw, shoph, x, y + hh);
	row++;
	// Texts background
	fillBox(buf, stationTileProtos.textbg, x-hw+1, row, shopw-2, shoph - (isSpecial?7:5));
	// Title text
	if (type.shopTitle) {
		startx = x - Math.ceil(type.shopTitle.length/2);
		putText(buf, type.shopTitle, startx, row, type);
	} else {
		startx = x - Math.ceil((2 + "Shop".length)/2);
		buf[row][startx] = replaceBackground(clone(type), stationTileProtos.textbg);
		putText(buf, "Shop", startx + 2, row);
	}
	row++;
	startx = x-hw+1; endx = x+hw-1;
	// Divider wall
	for (i = startx; i <= endx; ++i) buf[row][i] = stationTileProtos.wall;
	// Shopping stuff
	var buyprice = (type.baseprice)|0;
	var sellprice = (type.baseprice * 0.75)|0;
	row++; putText(buf, "Buy", startx, row, stationTileProtos.buy);
	row++; putText(buf, "$"+buyprice, endx, row, stationTileProtos.price, true);
	if (!isSpecial) {
		row++; putText(buf, "Sell", startx, row, stationTileProtos.sell);
		row++; putText(buf, "$"+sellprice, endx, row, stationTileProtos.price, true);
	}
	row++; for (i = startx; i <= endx; ++i) buf[row][i] = stationTileProtos.wall;
	buf[++row][startx] = clone(stationTileProtos.buy);
	buf[row][startx].buy = clone(type);
	buf[row][startx].buy.price = buyprice;
	if (!isSpecial) {
		buf[++row][startx] = clone(stationTileProtos.sell);
		buf[row][startx].sell = clone(type);
		buf[row][startx].sell.price = sellprice;
	}
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

	var shopCount = rand(3, 4, rng);
	var shopPos = [ {x:0,y:-1}, {x:-1,y:0}, {x:1,y:0}, {x:0,y:1} ];
	shuffle(shopPos, rng);
	var shopTypes = [];
	for (i in UniverseItems)
		if (UniverseItems.hasOwnProperty(i)) shopTypes.push(UniverseItems[i]);
	for (i in CustomShops)
		if (CustomShops.hasOwnProperty(i)) shopTypes.push(CustomShops[i]);
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
