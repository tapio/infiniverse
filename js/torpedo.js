
var torpedoProto = new ut.Tile("|", 136, 68, 34);
var torpedoTiles = [
	new ut.Tile("-", torpedoProto.r, torpedoProto.g, torpedoProto.b),
	new ut.Tile("/", torpedoProto.r, torpedoProto.g, torpedoProto.b),
	new ut.Tile("|", torpedoProto.r, torpedoProto.g, torpedoProto.b),
	new ut.Tile("\\", torpedoProto.r, torpedoProto.g, torpedoProto.b),
	new ut.Tile("-", torpedoProto.r, torpedoProto.g, torpedoProto.b),
	new ut.Tile("/", torpedoProto.r, torpedoProto.g, torpedoProto.b),
	new ut.Tile("|", torpedoProto.r, torpedoProto.g, torpedoProto.b),
	new ut.Tile("\\", torpedoProto.r, torpedoProto.g, torpedoProto.b)
];

// target: { x, y, damage() }
function Torpedo(x, y, target) {
	this.x = x || 0;
	this.y = y || 0;
	this.target = target;
	this.energy = 100;
	this.tileId = getAngledCharIndex(x, y, target.x, target.y);
}

Torpedo.prototype.damage = function(amount) {
	this.energy = 0;
};

Torpedo.prototype.update = function() {
	if (this.energy <= 0) return false;
	this.energy--;
	var dx = sign(this.target.x - this.x);
	var dy = sign(this.target.y - this.y);
	this.x += dx;
	this.y += dy;
	if (this.x === this.target.x && this.y === this.target.y) {
		if (this.target.damage) this.target.damage(50);
		return false;
	}
	this.tileId = getAngledCharIndex(this.x, this.y, this.target.x, this.target.y);
	return true;
};

Torpedo.prototype.getTile = function() {
	return torpedoTiles[this.tileId];
};
