
var animalRNG = new Alea();

function Animal(x, y, tile) {
	this.x = x;
	this.y = y;
	this.tile = tile;
	this.desc = "Animal";
	this.hp = 100;
}

Animal.prototype.damage = function(amount) {
	this.hp -= amount;
};

Animal.prototype.update = function() {
	if (this.hp <= 0) return false;
	this.x += rand(-1, 1, animalRNG);
	this.y += rand(-1, 1, animalRNG);
	return true;
};

Animal.prototype.getTile = function() {
	return this.tile;
};



var npcRNG = new Alea();

function NPCShip(x, y, type) {
	this.x = x;
	this.y = y;
	this.type = type;
	this.hp = 100;
	if (type === "pirate") {
		this.tile = new ut.Tile("@", 255, 0, 0);
		this.desc = "Pirate ship";
	} else if (type === "police") {
		this.tile = new ut.Tile("@", 0, 0, 255);
		this.desc = "Police ship";
	} else if (type === "trader") {
		this.tile = new ut.Tile("@", 0, 255, 0);
		this.desc = "Merchant ship";
	} else {
		this.tile = new ut.Tile("@", 255, 0, 255);
		this.desc = "Unknown ship";
	}
}

NPCShip.prototype.damage = function(amount) {
	this.hp -= amount;
};

NPCShip.prototype.update = function() {
	if (this.hp <= 0) return false;
	this.x += rand(-1, 1, npcRNG);
	this.y += rand(-1, 1, npcRNG);
	return true;
};

NPCShip.prototype.getTile = function() {
	return this.tile;
};
