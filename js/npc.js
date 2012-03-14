
var animalRNG = new Alea();

function Animal(x, y, tile) {
	this.x = x;
	this.y = y;
	this.tile = tile;
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
