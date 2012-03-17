
var missileProto = new ut.Tile("|", 136, 68, 34);
var missileTiles = [
	new ut.Tile("-", missileProto.r, missileProto.g, missileProto.b),
	new ut.Tile("/", missileProto.r, missileProto.g, missileProto.b),
	new ut.Tile("|", missileProto.r, missileProto.g, missileProto.b),
	new ut.Tile("\\", missileProto.r, missileProto.g, missileProto.b),
	new ut.Tile("-", missileProto.r, missileProto.g, missileProto.b),
	new ut.Tile("/", missileProto.r, missileProto.g, missileProto.b),
	new ut.Tile("|", missileProto.r, missileProto.g, missileProto.b),
	new ut.Tile("\\", missileProto.r, missileProto.g, missileProto.b)
];

// target: { x, y, damage() }
function Missile(x, y, target) {
	this.x = x || 0;
	this.y = y || 0;
	this.target = target;
	this.dead = false;
	this.energy = 30;
	this.targetable = true;
	this.tile = missileTiles[getAngledCharIndex(x, y, target.x, target.y)];
	this.desc = "Missile";
}

Missile.prototype.damage = function(amount) {
	this.energy = 0;
	this.dead = true;
};

Missile.prototype.update = function() {
	if (this.dead) return;
	this.energy--;
	if (this.energy <= 0) this.dead = true;
	var dx = sign(this.target.x - this.x);
	var dy = sign(this.target.y - this.y);
	this.x += dx;
	this.y += dy;
	if (this.x === this.target.x && this.y === this.target.y) {
		if (this.target.damage) this.target.damage(50);
		this.dead = true;
		return;
	}
	this.tile = missileTiles[getAngledCharIndex(this.x, this.y, this.target.x, this.target.y)];
};

Missile.prototype.getTile = function() {
	return this.tile;
};
