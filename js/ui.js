
Ship.prototype.updateUI = function() {
	var echar = "↯", cchar = "$";
	var i, str, len, statusclass, elem;
	var ec = this.energyCosts;
	var u = universe.current;
	var self = this;

	// Ship status
	var cond = Math.floor(this.hull / this.maxHull * 100);
	if (cond < 0) cond = 0;
	statusclass = "good";
	if (cond <= 25) statusclass = "bad";
	else if (cond < 75) statusclass = "warn";
	$("#hullcond").html(cond+"%").attr("class", statusclass);
	$("#energy").html(echar + prettyNumber(this.energy));
	$("#credits").html(cchar + prettyNumber(this.credits));

	// Sensorsbox
	var t = universe.current.getTile(this.x, this.y);
	$("#tiledesc").html(t && t.desc && t.desc.length ? t.desc : "n/a");
	$("#sensorenergy").html(echar + ec.sensors);
	$("#sensorsetting").html(this.scanSettings[this.sensorSetting]);
	len = this.contacts.length;
	elem = $("#sensorlist");
	if (len && !this.targets.length) {
		this.sortContacts();
		for (i = 0, str = ""; i < len; ++i)
			str += '<li>' + this.getPrettyContact(this.contacts[i]) + '</li>';
		elem.html(str);
		if (!elem.is(":visible")) elem.show("blind", 500);
		$("#contactstitle").html(len + " contacts:");
	} else {
		$("#contactstitle").html(this.targets.length ? "Targeting..." : "No contacts.");
		elem.html("").hide();
	}

	// Devices
	$("#hydrogen-energy").html("+" + echar + UniverseItems.hydrogen.energy);
	$("#radioactives-energy").html("+" + echar + UniverseItems.radioactives.energy);
	$("#antimatter-energy").html("+" + echar + UniverseItems.antimatter.energy);
	$("#missile-cost").html(echar + ec.createMissile);
	$("#beacon-cost").html(echar + ec.createBeacon);
	var movkeys = [ ut.KEY_LEFT, ut.KEY_RIGHT, ut.KEY_UP, ut.KEY_DOWN, ut.KEY_H, ut.KEY_J, ut.KEY_K, ut.KEY_L ];
	for (i = 0; i < movkeys.length; ++i)
		if (ut.isKeyPressed(movkeys[i])) { $("#drives span").first().attr("class", "online"); break; }
	if (i >= movkeys.length) $("#drives span").first().attr("class", "");
	var movEne = u.getMovementEnergy(this.x, this.y);
	$("#drives").children(".energy").html(echar + this.energyCosts.driveFactor * movEne);

	if (ut.isKeyPressed(ut.KEY_SHIFT)) $("#warpdrives span").first().attr("class", "online");
	else $("#warpdrives span").first().attr("class", "");
	$("#warpdrives").children(".energy").html(echar + ec.warpFactor * movEne);
	if (u.getDescendEnergy() >= 0)
		$("#enter").show().children(".energy").html(echar + ec.enterFactor * u.getDescendEnergy());
	else $("#enter").hide();
	if (u.getAscendEnergy() >= 0)
		$("#exit").show().children(".energy").html(echar + ec.exitFactor * u.getAscendEnergy());
	else $("#exit").hide();

	// Weapons
	$("#missiles").html(this.cargo.missile);
	$("#missiles").siblings(".energy").html(echar + this.energyCosts.launchMissile);
	elem = $("#targetlist");
	if (this.targets.length) {
		str = "";
		for (i = 0; i < this.targets.length; ++i) {
			str += '<li>[' + (i+1) + '] ' + this.getPrettyContact(this.targets[i]) + '</li>';
		}
		elem.html(str);
		if (!elem.is(":visible")) elem.show("blind", 500);
	} else elem.html("").hide();

	/*if (this.cargo.missiles <= 0) $("#missiles").html("-");
	else {
		str = "";
		for (i = 0; i < this.cargo.missiles; ++i)
			str += "| ";
		$("#missiles").html(str);
	}*/

	// Beacons
	$("#beaconstatus").html(this.cargo.navbeacon);
	len = this.activeBeacons.length;
	$("#activebeacons").html(len + "/" + this.maxActiveBeacons);
	if (len === 0) $("#beacon-menu").html("<li>No active beacons.</li>");
	else {
		str = "";
		for (i = 0; i < len; ++i)
			str += "<li>["+(i+1)+"] " + this.activeBeacons[i].title +
				' <span class="energy">' + echar + ec.gotoBeacon + '</span>';
		$("#beacon-menu").html(str);
	}

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
	for (var cargotype in this.cargo) {
		if (this.cargo[cargotype]) {
			var protoitem = UniverseItems[cargotype];
			str += cargoTypeHTML(protoitem.ch, cargotype, protoitem.desc, this.cargo[cargotype]);
		}
	}
	var emptySpace = this.maxCargo - this.usedCargo;
	if (emptySpace > 0) str += cargoTypeHTML("-", "empty", "Free space", emptySpace);
	$("#cargo").html(str);

	statusclass = "good";
	if (emptySpace <= 5) statusclass = "bad";
	else if (this.usedCargo / this.maxCargo > 0.666) statusclass = "warn";
	$("#cargostatus").html(this.usedCargo + "/" + this.maxCargo).attr("class", statusclass);
};
