
var animalRNG = new Alea();

function Animal(x, y, tile, name) {
	this.x = x;
	this.y = y;
	this.tile = tile;
	this.desc = name || "Animal";
	this.hp = 100;
	this.targetable = true;
	this.dead = false;
}

Animal.prototype.damage = function(amount) {
	this.hp -= amount;
	if (this.hp <= 0) this.dead = true;
};

Animal.prototype.update = function() {
	if (this.dead) return;
	this.x += rand(-1, 1, animalRNG);
	this.y += rand(-1, 1, animalRNG);
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
	this.targetable = true;
	this.dead = false;
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
	if (this.dead) return;
	this.hp -= amount;
	if (this.hp <= 0) {
		var loot = { tile: clone(UniverseItems.metals), x: this.x, y: this.y };
		universe.addItem(loot);
		this.dead = true;
	}
};

NPCShip.prototype.update = function() {
	if (this.dead) return;
	this.x += rand(-1, 1, npcRNG);
	this.y += rand(-1, 1, npcRNG);
};

NPCShip.prototype.getTile = function() {
	return this.tile;
};
