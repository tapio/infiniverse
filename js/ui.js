
Ship.prototype.updateUI = function() {
	var i, str, len, statusclass, elem;
	var ec = this.energyCosts;
	var u = universe.current;
	var self = this;

	// Sensorsbox
	var t = universe.current.getTile(this.x, this.y);
	$("#tiledesc").html(t && t.desc && t.desc.length ? t.desc : "n/a");
	$("#sensorenergy").html("-" + ec.sensors);
	$("#sensorsetting").html(this.scanSettings[this.sensorSetting]);
	len = this.contacts.length;
	if (len) {
		var arrows = "→↗↑↖←↙↓↘";
		this.sortContacts();
		for (i = 0, str = ""; i < len; ++i) {
			var obj = this.contacts[i];
			var dirchar = arrows[getAngledCharIndex(this.x, this.y, obj.x, obj.y)];
			var dist = ~~distance(this.x, this.y, obj.x, obj.y);
			if ((obj.radius && dist <= obj.radius) || dist < 1)
				dirchar = "↺";
			var sty = 'style="color:' + obj.tile.getColorRGB() + ';">';
			str += '<li><span ' + sty + obj.tile.ch + ' ' + obj.desc + "</span> - " + dist + dirchar + '</li>';
		}
		elem = $("#sensorlist");
		elem.html(str);
		if (!elem.is(":visible")) elem.show("blind", 500);
		$("#contactstitle").html(len + " contacts:");
	} else {
		$("#contactstitle").html("No contacts.");
		$("#sensorlist").html("").hide();
	}

	// Beacons
	$("#beaconstatus").html(this.beacons);
	len = this.activeBeacons.length;
	$("#activebeacons").html(len + "/" + this.maxActiveBeacons);
	if (len === 0) $("#beacon-menu").html("<li>No active beacons.</li>");
	else {
		str = "";
		for (i = 0; i < len; ++i)
			str += "<li>["+(i+1)+"] " + this.activeBeacons[i].title +
				' <span class="energy">-' + ec.gotoBeacon + '</span>';
		$("#beacon-menu").html(str);
	}

	// Ship status
	var cond = Math.floor(this.hull / this.maxHull * 100);
	if (cond < 0) cond = 0;
	statusclass = "good";
	if (cond <= 25) statusclass = "bad";
	else if (cond < 75) statusclass = "warn";
	$("#hullcond").html(cond+"%").attr("class", statusclass);
	$("#energy").html(prettyNumber(this.energy));

	// Devices
	$("#minerals-energy").html("+" + ec.convertMinerals);
	$("#radioactives-energy").html("+" + ec.convertRadioactives);
	$("#antimatter-energy").html("+" + ec.convertAntimatter);
	$("#torpedo-cost").html("-" + ec.createTorpedo);
	$("#beacon-cost").html("-" + ec.createBeacon);
	var movkeys = [ ut.KEY_LEFT, ut.KEY_RIGHT, ut.KEY_UP, ut.KEY_DOWN, ut.KEY_H, ut.KEY_J, ut.KEY_K, ut.KEY_L ];
	for (i = 0; i < movkeys.length; ++i)
		if (ut.isKeyPressed(movkeys[i])) { $("#drives span").first().attr("class", "online"); break; }
	if (i >= movkeys.length) $("#drives span").first().attr("class", "");
	var movEne = u.getMovementEnergy(this.x, this.y);
	$("#drives").children(".energy").html("-" + this.energyCosts.driveFactor * movEne);

	if (ut.isKeyPressed(ut.KEY_SHIFT)) $("#warpdrives span").first().attr("class", "online");
	else $("#warpdrives span").first().attr("class", "");
	$("#warpdrives").children(".energy").html("-" + ec.warpFactor * movEne);
	if (u.getDescendEnergy() >= 0)
		$("#enter").show().children(".energy").html("-" + ec.enterFactor * u.getDescendEnergy());
	else $("#enter").hide();
	if (u.getAscendEnergy() >= 0)
		$("#exit").show().children(".energy").html("-" + ec.exitFactor * u.getAscendEnergy());
	else $("#exit").hide();

	// Torpedos
	$("#torpedos").html(this.torpedos);
	$("#torpedos").siblings(".energy").html("-" + this.energyCosts.launchTorpedo);
	/*if (this.torpedos <= 0) $("#torpedos").html("-");
	else {
		str = "";
		for (i = 0; i < this.torpedos; ++i)
			str += "| ";
		$("#torpedos").html(str);
	}*/

	// Cargo
	function cargoTypeHTML(cargochar, cssclass, title, amount) {
		if (cssclass !== "empty") self.usedCargo += amount;
		var ret = '<span class=" ' +cssclass + '" title="' + title + '">';
		for (var cargoitem = 0; cargoitem < amount; ++cargoitem)
			ret += cargochar + " ";
		return ret + '</span>';
	}
	this.usedCargo = 0;
	str = "";
	if (this.beacons > 0) str += cargoTypeHTML("B", "beacon", "Navbeacon", this.beacons);
	if (this.torpedos > 0) str += cargoTypeHTML("T", "torpedo", "Torpedo", this.torpedos);
	if (this.minerals > 0) str += cargoTypeHTML("M", "minerals", "Minerals", this.minerals);
	if (this.radioactives > 0) str += cargoTypeHTML("R", "radioactives", "Radioactives", this.radioactives);
	if (this.antimatter > 0) str += cargoTypeHTML("A", "antimatter", "Antimatter", this.antimatter);
	var emptySpace = this.maxCargo - this.usedCargo;
	if (emptySpace > 0) str += cargoTypeHTML("-", "empty", "Free space", emptySpace);
	$("#cargo").html(str);

	statusclass = "good";
	if (emptySpace <= 5) statusclass = "bad";
	else if (this.usedCargo / this.maxCargo > 0.666) statusclass = "warn";
	$("#cargostatus").html(this.usedCargo + "/" + this.maxCargo).attr("class", statusclass);
};
