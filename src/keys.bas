
Sub Keys(ByRef pl As SpaceShip, ByRef tileBuf As TileCache, frameTime As Double = 1.0)
	#Macro dostuff(updown)
		game.viewLevel += updown
		If updown < 0 Then pl.upX = pl.x : pl.upY = pl.y Else pl.upX = -100 : pl.upY = -100
		game.updateBounds
		moveStyle = 0
		pl.spd = 0
		game.viewLevelChanged = -1
		buildMode = 0
	#EndMacro
	'Static moveTimer As DelayTimer = DelayTimer(0.002)
	Static keyTimer As DelayTimer = DelayTimer(0.5)
	hasMoved = 0

	'If MultiKey(KEY_LSHIFT) Then moveTimer.delay = 0 Else moveTimer.delay = .002
	'If moveStyle = 0 Then moveTimer.delay = .1 Else moveTimer.delay = .002
	'If buildMode = 0 Then moveTimer.delay = 0.002 Else moveTimer.delay = 0.1

	Dim As Integer tempx, tempy

	pl.oldx = pl.x : pl.oldy = pl.y : pl.strafe = 0
	Dim As Integer thrust = 0, tempang = 0
	If moveStyle = 0 Then
		pl.spd = 0
		Dim As Single arrows_spd = fine_spd
		If buildMode <> 0 Then arrows_spd = build_spd
		If MultiKey(KEY_UP)    Then tempang+=&b1000: pl.spd = arrows_spd: thrust = 1
		If MultiKey(KEY_DOWN)  Then tempang+=&b0010: pl.spd = arrows_spd: thrust = 1
		If MultiKey(KEY_LEFT)  Then tempang+=&b0001: pl.spd = arrows_spd: thrust = 1
		If MultiKey(KEY_RIGHT) Then tempang+=&b0100: pl.spd = arrows_spd: thrust = 1
		If MultiKey(KEY_LSHIFT) OrElse MultiKey(KEY_RSHIFT) Then pl.strafe = tempang
		If tempang <> 0 AndAlso pl.strafe = 0 Then pl.ang = table_dirAngles(tempang)
		If MultiKey(KEY_W) AndAlso isMacroVL(game.viewLevel) Then _
			moveStyle = 1: pl.spd = fine_spd: thrust = 1
	Else
		If MultiKey(KEY_SPACE) Then
			pl.spd -= acc * 4 * frameTime '*= .85
			If pl.spd < 0.01 Then pl.spd = 0: pl.x = CInt(pl.x): pl.y = CInt(pl.y)
		EndIf
		If MultiKey(KEY_W) Then
			pl.spd += acc * frameTime
			thrust = 1
		Else
			If MultiKey(KEY_S) OrElse auto_slow Then pl.spd -= acc * frameTime
			If pl.spd < .15 Then pl.spd = 0: moveStyle = 0
		EndIf
		'If MultiKey(KEY_S) Then pl.spd = Max(0.0, pl.spd-0.01) ': moveTimer.start
	EndIf
	If MultiKey(KEY_A) Then pl.ang = wrap(pl.ang+turn_rate*frameTime,2*pi) ': moveTimer.start
	If MultiKey(KEY_D) Then pl.ang = wrap(pl.ang-turn_rate*frameTime,2*pi) ': moveTimer.start
	If (Not MultiKey(KEY_A)) AndAlso (Not MultiKey(Key_D)) Then
		If wrap(pl.ang,pi/4) < 0.2 Then pl.ang = CInt(pl.ang/(pi/4))*(pi/4.0)
	EndIf
	pl.thrust = thrust
	If pl.spd <> 0 Then hasMoved = -1

	'If ( game.viewLevel = zGalaxy ) AndAlso (Not inBounds(pl.x,0,game.boundW(game.viewLevel)-1) OrElse Not inBounds(pl.y,0,game.boundH(game.viewLevel)-1)) Then
	'	pl.x = pl.oldx: pl.y = pl.oldy
	'' Detail level
	If game.viewLevel = zDetail AndAlso (pl.x <> pl.oldx OrElse pl.y <> pl.oldy) Then
		'' Collisions
		If (game.curArea.areaArray(CInt(pl.x),CInt(pl.y)).flags And BLOCKS_MOVEMENT) Then
			Dim As Single backang = GetAngle(pl.x,pl.y,pl.oldx,pl.oldy)
			pl.x -= Cos(backang)
			pl.y += Sin(backang)
			pl.spd = 0
		EndIf
		'' Borders...
		If (Not inBounds(pl.x,0,game.boundW(game.viewLevel)-1) OrElse Not inBounds(pl.y,0,game.boundH(game.viewLevel)-1)) Then
			tempx = game.curArea.x
			tempy = game.curArea.y
			Dim As Integer arriveX = CInt(pl.x), arriveY = CInt(pl.y)
			If pl.x < 0 Then tempx -= 1: arriveX = game.boundW(game.viewLevel)-1
			If pl.x > game.boundW(game.viewLevel)-1 Then tempx += 1: arriveX = 0
			If pl.y < 0 Then tempy -= 1: arriveY = game.boundH(game.viewLevel)-1
			If pl.y > game.boundH(game.viewLevel)-1 Then tempy += 1: arriveY = 0
			game.curArea = SurfaceArea(tempx, tempy, tempy * game.curPlanet.w + tempx)
			game.updateBounds
			pl.x = arriveX : pl.y = arriveY
			prevTileBuf = tileBuf
			tileBuf = TileCache(pl.x, pl.y, @GetAreaTile)
			bufferBlendFunc = 0
			game.viewLevelChanged = -1
		EndIf
	'' Handle coming to borders on other levels
	ElseIf (Not inBounds(pl.x,0,game.boundW(game.viewLevel)-1)) OrElse (Not inBounds(pl.y,0,game.boundH(game.viewLevel)-1)) Then
		If game.viewLevel = zSystem Then
			pl.x = game.curSystem.x
			pl.y = game.curSystem.y
			prevTileBuf = tileBuf
			tileBuf = TileCache(pl.x, pl.y, @GetStarmapTile)
			bufferBlendFunc = @CacheBlend_CircleInwards
			BuildNoiseTables game.curStarmap.seed, 8
			dostuff(-1)
			AddMsg("Entering inter-stellar navigation mode")
		ElseIf game.viewLevel = zOrbit Then
			pl.x = game.curPlanet.x
			pl.y = game.curPlanet.y
			prevTileBuf = tileBuf
			tileBuf = TileCache(pl.x, pl.y, @GetSolarTile)
			bufferBlendFunc = @CacheBlend_CircleInwards
			BuildNoiseTables game.curSystem.seed, 8
			pl.curIcon = char_starship
			dostuff(-1)
			AddMsg("Leaving planet orbit")
		Else
			If pl.x < 0 Then pl.x += game.boundW(game.viewLevel)
			If pl.y < 0 Then pl.y += game.boundH(game.viewLevel)
			If pl.x > game.boundW(game.viewLevel) Then pl.x -= game.boundW(game.viewLevel)
			If pl.y > game.boundH(game.viewLevel) Then pl.y -= game.boundH(game.viewLevel)
			'pl.x = wrap(pl.x, game.boundW(game.viewLevel))
			'pl.y = wrap(pl.y, game.boundH(game.viewLevel))
		EndIf
	EndIf

	Dim As Integer controlKey = 0 ', buildMode = 0
	If MultiKey(KEY_CONTROL) Then controlKey = -1

	tempx = CInt(pl.x): tempy = CInt(pl.y)
	' Keys that are pressed, not held down:
	If keyTimer.hasExpired Then
		Dim As String tempk
		If MultiKey(Key_K) Then AddExplosion(pl.x+5,pl.y)
		' Missiles
		If MultiKey(Key_M) AndAlso isMacroVL(game.viewLevel) Then
			missiles.add(New Missile(pl.x, pl.y, pl.ang, pl.spd+20))
			keyTimer.start
		EndIf
		If MultiKey(KEY_T) Then consoleOpen = -1: tempk = InKey: Exit Sub
		If MultiKey(KEY_B) AndAlso game.viewLevel = zDetail Then switch(buildMode): keyTimer.start ' = -1'Not buildmode '-1
		'If MultiKey(KEY_F2) Then switch(moveStyle): pl.x = Int(pl.x): pl.y = Int(pl.y): keyTimer.start
		If MultiKey(KEY_F3) Then switch(auto_slow): keyTimer.start
		#Ifdef NETWORK_enabled
		If MultiKey(KEY_I) Then serverQueries = queries.areaInfo   : keyTimer.start
		If MultiKey(KEY_O) Then serverQueries = queries.playerCount: keyTimer.start
		If MultiKey(KEY_P) Then AddMsg("PING: " & Str(CInt((ping)*1000.0))) : keyTimer.start
		#EndIf
		If buildMode And Not LEE Then
			For i As Integer = 1 To BuildingCount
				'FIXME: This keybinding is bullsh
				If MultiKey(i+1) Then
					tempx += CInt(Cos(pl.ang))
					tempy -= CInt(Sin(pl.ang))
					If game.curArea.Modify(tempx,tempy, ASCIITile( buildings(i).tex,0,buildings(i).flags )) Then
						#IfDef NETWORK_enabled
							modQueue += Chr(i,tempx,tempy)
						#EndIf
						tileBuf.isEmpty = -1
					EndIf
					keyTimer.start
					Exit For
				EndIf
			Next i
		EndIf

		'' Enter Places
		If MultiKey(KEY_SPACE) Then
			If pl.spd <> 0 Then
				'nop
			Else
			Select Case game.viewLevel
				Case zGalaxy
					If in2dArray(game.curGalaxy.gmap,tempx,tempy) Then
						Dim As Double temp = CDbl(game.curStarmap.size) / GALAXYSIZE
						pl.x = CInt(temp * CInt(pl.x))
						pl.y = CInt(temp * CInt(pl.y))
						prevTileBuf = tileBuf
						tileBuf = TileCache(pl.x, pl.y, @GetStarmapTile)
						bufferBlendFunc = @CacheBlend_CircleOutwards
						BuildNoiseTables game.curStarmap.seed, 8
						dostuff(1)
						AddMsg("Jumping to designated galaxy location")
					EndIf
				Case zStarmap
					If StarmapHasStar(tempx,tempy).char <> 0 Then
						game.curSystem = SolarSystem(CInt(pl.x), CInt(pl.y))
						pl.x = CInt(game.curSystem.size / 2)
						pl.y = CInt(game.curSystem.size / 2)
						prevTileBuf = tileBuf
						tileBuf = TileCache(pl.x, pl.y, @GetSolarTile)
						bufferBlendFunc = @CacheBlend_CircleOutwards
						dostuff(1)
						AddMsg("Entering solar system")
					EndIf
				Case zSystem
					For i As Integer = game.curSystem.starCount To game.curSystem.starCount + game.curSystem.planetCount-1
						If tempx = game.curSystem.objects(i).x And tempy = game.curSystem.objects(i).y Then
							game.curPlanet = game.curSystem.objects(i)
							game.curPlanet.Enter
							game.curPlanet.BuildMap
							pl.x = CInt(ORBITSIZE/2 - Cos(pl.ang) * game.curPlanet.h/ORBITFACTOR)
							pl.y = CInt(ORBITSIZE/2 + Sin(pl.ang) * game.curPlanet.h/ORBITFACTOR)
							prevTileBuf = tileBuf
							tileBuf = TileCache(pl.x, pl.y, @GetOrbitTile)
							bufferBlendFunc = @CacheBlend_CircleOutwards
							'pl.curIcon = char_lander
							dostuff(1)
							AddMsg("Orbiting planet")
							Exit For
						EndIf
					Next i
				Case zOrbit
					Dim As Integer radius = CInt(game.curPlanet.h * .5 / ORBITFACTOR)
					If Distance(pl.x,pl.y,ORBITSIZE/2,ORBITSIZE/2) <= radius Then
						'TODO: laitas oikeaks tuo koordinaatti juttu
						pl.x = CInt( (pl.x - ORBITSIZE*.5 + radius + (GetTime() Mod radius)) * ORBITFACTOR + ORBITFACTOR*.5 )
						pl.y = CInt( (pl.y - ORBITSIZE*.5 + radius) * ORBITFACTOR + ORBITFACTOR*.5 )
						'pl.x = CInt(game.curPlanet.w / 2)
						'pl.y = CInt(game.curPlanet.h / 2)
						prevTileBuf = tileBuf
						tileBuf = TileCache(pl.x, pl.y, @GetGroundTile)
						bufferBlendFunc = @CacheBlend_CircleOutwards
						pl.curIcon = char_lander
						dostuff(1)
						AddMsg("Landing shuttle launched")
						If game.curPlanet.objType = pGaia Then AddMsg("Entering planet atmosphere") Else AddMsg("Descending from high orbit")
					EndIf
				Case zPlanet
					If game.curPlanet.objType <> pGas Then
						'AddLog("--Trying to enter area")
						If GetGroundTile(pl.x,pl.y).tex1.desc <> "water" Then
							game.curArea = SurfaceArea(tempx, tempy, tempy * game.curPlanet.w + tempx)
							pl.x = CInt(game.curArea.w / 2)
							pl.y = CInt(game.curArea.h / 2)
							prevTileBuf = tileBuf
							tileBuf = TileCache(pl.x, pl.y, @GetAreaTile)
							bufferBlendFunc = @CacheBlend_CircleOutwards
							pl.curIcon = char_walking
							dostuff(1)
							AddMsg("Landing")
							'Addlog("--Entering succesful")
						EndIf
					Else
						AddMsg("Unable to land: no surface on gas planets")
					EndIf
			End Select
			EndIf
			keyTimer.start
		EndIf
		'exit places
		If MultiKey(KEY_CONTROL) And MultiKey(KEY_X) Then
			Select Case game.viewLevel
				Case zStarmap
					'Dim As Double temp = CDbl(game.curStarmap.size) / GALAXYSIZE *.5
					pl.x = CInt(clngint(pl.x) * GALAXYSIZE / game.curStarmap.size)
					pl.y = CInt(clngint(pl.y) * GALAXYSIZE / game.curStarmap.size)
					prevTileBuf = tileBuf
					tileBuf = TileCache(pl.x, pl.y, @GetGalaxyTile)
					bufferBlendFunc = @CacheBlend_CircleInwards
					dostuff(-1)
					AddMsg("Entering trans-galactic navigation mode")
				Case zSystem
					pl.x = game.curSystem.x
					pl.y = game.curSystem.y
					prevTileBuf = tileBuf
					tileBuf = TileCache(pl.x, pl.y, @GetStarmapTile)
					bufferBlendFunc = @CacheBlend_CircleInwards
					BuildNoiseTables game.curStarmap.seed, 8
					dostuff(-1)
					AddMsg("Entering inter-stellar navigation mode")
				Case zOrbit
					pl.x = game.curPlanet.x
					pl.y = game.curPlanet.y
					prevTileBuf = tileBuf
					tileBuf = TileCache(pl.x, pl.y, @GetSolarTile)
					bufferBlendFunc = @CacheBlend_CircleInwards
					BuildNoiseTables game.curSystem.seed, 8
					pl.curIcon = char_starship
					dostuff(-1)
					AddMsg("Leaving planet orbit")
				Case zPlanet
					'TODO: add proper formulas
					'x = (x + (GetTime() Mod (radius*2))) Mod (radius*2)
					'pl.x = CInt(ORBITSIZE*.5 + (pl.x - game.curPlanet.w*.5) / ORBITFACTOR)
					'pl.y = CInt(ORBITSIZE*.5 + (pl.y - game.curPlanet.h*.5) / ORBITFACTOR)
					Dim As Double tempang = GetAngle(game.curPlanet.w*.5,game.curPlanet.h*.5,pl.x,pl.y)
					Dim As Double radius = game.curPlanet.h*.5 / ORBITFACTOR
					pl.x = CInt(ORBITSIZE*.5 + Cos(tempang) * radius * 1.2)
					pl.y = CInt(ORBITSIZE*.5 - Sin(tempang) * radius * 1.2)
					prevTileBuf = tileBuf
					tileBuf = TileCache(pl.x, pl.y, @GetOrbitTile)
					bufferBlendFunc = @CacheBlend_CircleInwards
					BuildNoiseTables game.curSystem.seed, 8
					pl.curIcon = char_starship
					dostuff(-1)
					pl.upX = -100 : pl.upY = -100
					AddMsg("Ascending to high orbit")
				Case zDetail
					pl.x = game.curArea.x
					pl.y = game.curArea.y
					prevTileBuf = tileBuf
					tileBuf = TileCache(pl.x, pl.y, @GetGroundTile)
					bufferBlendFunc = @CacheBlend_CircleInwards
					BuildNoiseTables game.curPlanet.seed, 8
					pl.curIcon = char_lander
					dostuff(-1)
					AddMsg("Leaving surface")
				Case zSpecial

			End Select
			keyTimer.start
		EndIf
		#Macro addBookmark(slot)
			If MultiKey(KEY_##slot) Then
				If game.getAreaCoordStamp() <> "" Then bookmarks(slot) = game.getAreaCoordStamp() & "#" & tempx & "," & tempy Else bookmarks(slot) = tempx & "," & tempy
				AddLog(Date & " " & Time & " : " & bookmarks(slot), BOOKMARKLOG)
				SaveBookmarks(BOOKMARKFILE)
				keyTimer.start
			EndIf
		#EndMacro
		Dim As Byte tempb
		#Macro gotoBookmark(slot)
			If MultiKey(KEY_##slot) AndAlso bookmarks(slot) <> "" Then gotoBookmarkSlot = slot: keyTimer.start 'GoToCoords(bookmarks(slot), pl, tileBuf): keyTimer.start: AddLog("onnas")
		#EndMacro
		If buildMode = 0 Then
		If controlKey Then
			addBookmark(1)
			addBookmark(2)
			addBookmark(3)
			addBookmark(4)
			addBookmark(5)
			addBookmark(6)
			addBookmark(7)
			addBookmark(8)
			addBookmark(9)
		Else
			gotoBookmark(1)
			gotoBookmark(2)
			gotoBookmark(3)
			gotoBookmark(4)
			gotoBookmark(5)
			gotoBookmark(6)
			gotoBookmark(7)
			gotoBookmark(8)
			gotoBookmark(9)
		EndIf
		EndIf
	EndIf
	If hasMoved Then hasMovedOnline = -1
End Sub

