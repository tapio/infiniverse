' Project "Infiniverse" - A Procedural Exploration Game

#Define INF_VERSION "0.4.6+"

#Define NETWORK_enabled			'' Comment to create LEE-only version
#Define CLIPBOARD_enabled		'' Comment to exclude clipboard functionality

#IfDef __FB_LINUX__
 #Define UPDATER_EXE_NAME "updater"
#Else
 #Define UPDATER_EXE_NAME "updater.exe"
#EndIf

#IfDef CLIPBOARD_enabled
	#Include Once "fbclp.bi"
	Using fb_clipboard
#EndIf

#Include Once "PNGscreenshot.bas"
#Include Once "miscfb/def.bi"
#Include Once "miscfb/util.bas"
#Include Once "miscfb/libNoise.bas"
#Include Once "miscfb/words.bi"
#Include Once "miscfb/singlelinkedlist.bi"
#Include Once "crt/string.bi"
#Include Once "misc.bas"

Dim Shared EXENAME As String: EXENAME = Command(0)
Dim Shared LOGFILE As String: LOGFILE = ""
Dim Shared CONFIGFILE As String: CONFIGFILE = "data/server.ini"
Dim Shared LEE As Integer: LEE = 0
Dim Shared As String my_name, passwd

Dim Shared As String serveraddress
Dim Shared As Integer port = 11000
Var f = FreeFile
If Not Open(CONFIGFILE, For Input,, As #f) Then
	Line Input #f, serveraddress
	Input #f, port
	Close #f
EndIf

Declare Sub ParseCommandLine()
ParseCommandline
#IfNDef NETWORK_enabled
	LEE = Not 0
#EndIf

If Not LEE Then Print "Infiniverse-client "+INF_VERSION _
Else Print "Infiniverse Lone Explorer Edition "+INF_VERSION
PrintStars()
If LOGFILE = "" Then Print "Logging disabled (no log file specified)"

Const scrW = 1024
Const scrH = 768
ScreenRes scrW, scrH, 32, 2', 1
WindowTitle "Infiniverse Client"
Dim As Integer workpage, curTileCache = 0

'Const viewX = 36
'Const viewY = 36
#Define viewX (36)
#Define viewY (36)
Const viewStartX = scrW * .5 - viewX * 8
Const viewStartY = 7 * 8

Const log_enabled = -1
Const BOOKMARKFILE = "data/bookmarks.ini"
Const BOOKMARKLOG  = "data/bookmarks.log"

#Include Once "protocol.bi"
#Include Once "game.bi"
#Include Once "tileengine.bas"

Declare Function Anim_RotatePlanet(tile As ASCIITile, x As Integer, y As Integer) As ASCIITile
Declare Function GetAreaTile(x As Integer, y As Integer) As ASCIITile
Declare Function GetGroundTile(x As Integer, y As Integer) As ASCIITile
Declare Function GetGasGiantTile(x As Integer, y As Integer) As ASCIITile
Declare Function GetOrbitTile(x As Integer, y As Integer) As ASCIITile
Declare Function GetSolarTile(x As Integer, y As Integer) As ASCIITile
Declare Function GetStarmapTile(x As Integer, y As Integer) As ASCIITile
Declare Function StarmapHasStar(x As Integer, y As Integer) As ASCIITexture
Declare Function SystemStarBG(x As Integer, y As Integer) As ASCIITexture
Declare Function GetGroundTexture(height As UByte, temperature As UByte, rainfall As UByte, vegetation As UByte, turb As UByte = 0) As ASCIITile
Declare Function GetPureGround(x As Integer, y As Integer) As ASCIITile
Declare Function GetGalaxyTile(x As Integer, y As Integer) As ASCIITile
Declare Sub Keys(ByRef pl As SpaceShip, ByRef tileBuf As TileCache, frameTime As Double = 1.0)
Declare Function GameInput(promt As String = "", x As Integer, y As Integer, stri As String, k As String = "", passwordchar As String = "") As String
Declare Function GoToCoords(stamp As String, ByRef pl As SpaceShip, ByRef tileBuf As TileCache) As Integer
Declare Sub GenerateTextures(seed As Double = -1)
Declare Sub GenerateDistantStarBG(array() As UByte)
Declare Sub AddVariance(ByRef tile As ASCIITile, variance As Short)
Declare Function AddVarianceToColor(col As UInteger, variance As Short) As UInteger
Declare Sub AddMsg(_msg As String)
Declare Sub PrintMessages(x As Integer, y As Integer, _count As Integer = 1)
Declare Sub SaveBookmarks(filename As String = BOOKMARKFILE)
Declare Sub LoadBookmarks(filename As String = BOOKMARKFILE)

Const TimeSyncInterval = 3.000
Declare Sub TimeManager()
Declare Function GetTime() As ULongInt
Declare Function GetTimeString() As String
Dim Shared As ULongInt gametime = 0


#Include Once "universe.bi"
#Include Once "helps.bas"
#IfDef NETWORK_enabled
	#Include Once "../server/client/lobby.bas"
	'#Include Once "../server/client/networking.bas"
#Else
	'' Dummy funtions for LEE
	Sub Lobby(): End Sub
	'Sub HandleTraffic(): End Sub
#EndIf
'Dim Shared As UByte farStarBG(1024, 1024)
'GenerateDistantStarBG(farStarBG())


Dim As String temp, temp2, tempst
Dim As String msg = "", traffic_in = "", traffic_out = "", k = "", missiles_status = ""
Dim As Double pingTime, lastPingResponse
Dim Shared As Double ping
Dim As UByte char, testbyte
Dim As Integer i,j, tempx,tempy, tempz, count
Dim As UInteger tempuid

If LEE Then LEETitle() Else Lobby()

#IfNDef SEP
	#Define SEP Chr(1)
#EndIf

Dim Shared modQueue As String
'If log_enabled Then AddLog(my_name & "---NEW---")

Dim Shared game As GameLogic
	game.viewLevel = zStarmap
	game.curGalaxy = Galaxy(42)
	game.updateBounds
	game.curStarmap.seed = game.curGalaxy.seed
	BuildNoiseTables game.curStarmap.seed, 8
BuildNoiseTable 1, 9 'fixed noise

Dim pl As SpaceShip = SpaceShip(game.curStarmap.size/2,game.curStarmap.size/2,pi/2)
Dim tileBuf As TileCache = TileCache(pl.x, pl.y, @GetStarmapTile)
Dim Shared prevTileBuf As TileCache
Dim bufferBlendFactor As Single = 0
Dim Shared bufferBlendFunc As Function(As Integer, As Integer) As Single
GoToCoords("4194312,4194292", pl, tileBuf)
Dim gameTimer As FrameTimer
Dim trafficTimer As DelayTimer = DelayTimer(TRAFFIC_DELAY)
Dim missileTimer As DelayTimer = DelayTimer(MISSILES_INTERVAL)
Dim keepAliveTimer As DelayTimer = DelayTimer(KEEP_ALIVE_DELAY)
Dim pingTimer As DelayTimer = DelayTimer(PING_INTERVAL)
Dim Shared As Byte moveStyle = 0, hasMoved = 0, hasMovedOnline = 0, buildMode = 0
Dim Shared As Byte consoleOpen = 0, auto_slow = 0
Dim Shared As UByte serverQueries = queries.timeSync, gotoBookmarkSlot = 0
Dim Shared As String bookmarks(1 To 9)
Dim As Byte helpscreen = 0

LoadBookmarks()

#Ifdef NETWORK_enabled
	If Not LEE Then
		sock.put(1)
		formatChangeArea(traffic_out)
		sock.put(traffic_out)
		lastPingResponse = Timer
	EndIf
#EndIf


' ------- MAIN LOOP ------- '
Do
	gameTimer.Update
	TimeManager()
	ScreenSet workpage, workpage Xor 1
	Cls

	If helpscreen = 0 Then
	If consoleOpen = 0 Then Keys pl, tileBuf, gameTimer.frameTime
	If gotoBookmarkSlot <> 0 Then tempz = GoToCoords(bookmarks(gotoBookmarkSlot),pl,tileBuf): gotoBookmarkSlot = 0

	If LEE Then
		ForIJ(1, viewStartX/8, 1, scrH/8)
			tempx = Perlin(i,j,512,512,2,9)
			If tempx > 200 Then Draw String ((i-1)*8, (j-1)*8), ".", RGB(tempx,tempx,tempx)
		NextIJ
		ForIJ(viewX*2 +1 + viewStartX/8, scrW/8, 1, scrH/8)
			tempx = Perlin(i,j,512,512,2,9)
			If tempx > 200 Then Draw String ((i-1)*8, (j-1)*8), ".", RGB(tempx,tempx,tempx)
		NextIJ
	EndIf

	UpdateCache tileBuf, CInt(pl.x),CInt(pl.y), viewX,viewY
	'Blending
	If game.viewLevelChanged And bufferBlendFunc <> 0 Then bufferBlendFactor = 1.0
	If bufferBlendFactor <= 0 Then
		DrawView tileBuf, CInt(pl.x),CInt(pl.y), viewStartX,viewStartY, viewX,viewY
		bufferBlendFunc = 0
	Else
		bufferBlendFactor -= .04
		Var tempTileBuf = BlendTileCaches(prevTileBuf, tileBuf, bufferBlendFactor, bufferBlendFunc)
		DrawView tempTileBuf, CInt(pl.x),CInt(pl.y), viewStartX,viewStartY, viewX,viewY
	EndIf
	'Particles
	DrawParticles CInt(pl.x),CInt(pl.y), viewStartX,viewStartY, viewX,viewY, gameTimer.frameTime
	'Missiles
	Dim mIter As Missile Ptr = missiles.initIterator()
	If missileTimer.hasExpired() Then count = 1 : missiles_status = "" Else count = 0
	While mIter <> 0
		mIter->updatePos(gameTimer.frameTime)
		If count > 0 AndAlso mIter->owner = 0 Then
			missiles_status += String(MISSILE_NETSIZE, Chr(0))
			tempx = CInt(mIter->x)
			tempy = CInt(mIter->y)
			tempuid = mIter->id
			memcpy(@missiles_status[  (count-1)*MISSILE_NETSIZE], @tempx, 4)
			memcpy(@missiles_status[4+(count-1)*MISSILE_NETSIZE], @tempy, 4)
			memcpy(@missiles_status[8+(count-1)*MISSILE_NETSIZE], @tempuid, 4)
			count += 1
		EndIf
		'If mIter->owner <> 0 Then ConsolePrint Str(mIter->x-pl.x)+" "+Str(mIter->y-pl.y)+" "+Str(mIter->spd)
		AddTrail(mIter->x,mIter->y,mIter->oldx,mIter->oldy,RGB(255,196,0),0.667)
		drawCharToWorld(mIter->x, mIter->y, _
						missile_char( (CInt(mIter->ang/(2*pi)*8.0)+32) Mod 8 ), _
						RGB(255,0,0) )

		If mIter->owner = 0 Then mIter->fuel -= gameTimer.frameTime
		If mIter->fuel <= 0 OrElse (mIter->owner <> 0 AndAlso _
			Timer > mIter->lastUpdate + LOSE_DELAY) Then
				mIter = missiles.remove(mIter)
				Delete mIter
		EndIf
		mIter = missiles.getNext()
	Wend

	'Player stuff
	If pl.spd <> 0 Then
		Dim As Single moveang = pl.ang
		If pl.strafe <> 0 Then moveang = table_dirAngles(pl.strafe)
		pl.x += Cos(moveang) * pl.spd * gameTimer.frameTime
		pl.y -= Sin(moveang) * pl.spd * gameTimer.frameTime
		'hasMoved = -1
		If game.viewLevel <> zDetail AndAlso game.viewLevel <> zSpecial _
			AndAlso game.viewLevel <> zGalaxy Then
			If pl.thrust = 0 Then _
				 AddTrail(pl.x,pl.y,pl.oldx,pl.oldy) _
			Else AddTrail(pl.x,pl.y,pl.oldx,pl.oldy,RGB(255,196,0))
		EndIf
		'moveTimer.start
	EndIf
	Draw String ( viewStartX + 8*viewX, viewStartY + 8*viewY ), pl.curIcon, RGB(150,250,150)
	Draw String ( viewStartX + 8*(viewX+CInt(Cos(pl.ang)*10)), viewStartY + 8*(viewY-CInt(Sin(pl.ang)*10)) ), "x", RGB(0,255,0)
	If pl.upX > 0 AndAlso Abs(pl.upX-pl.x) < viewX AndAlso Abs(pl.upY-pl.y) < viewY Then Draw String ( viewStartX + 8*(viewX + (pl.upX-CInt(pl.x))), viewStartY + 8*(viewY + (pl.upY-CInt(pl.y))) ), "X", RGB(200,0,200)

	'Guide arrows
	If game.viewLevel = zSystem Then
		For i = 0 To game.curSystem.starCount + game.curSystem.planetCount - 1
			Dim As Integer xdiff = game.curSystem.objects(i).x - pl.x
			Dim As Integer ydiff = game.curSystem.objects(i).y - pl.y
			If Abs(xdiff) > viewX Or Abs(ydiff) > viewY Then
				If Abs(xdiff) > Abs(ydiff) Then
					If xdiff < 0 Then xdiff = -viewX: char = 17 Else xdiff = viewX: char = 16
				Else
					If ydiff < 0 Then ydiff = -viewY: char = 30 Else ydiff = viewY: char = 31
				EndIf
				xdiff = Clip(xdiff,-viewX,viewX)
				ydiff = Clip(ydiff,-viewY,viewY)
				Draw String ( viewStartX + 8*(viewX+xdiff), viewStartY + 8*(viewY+ydiff) ), Chr(char), game.curSystem.objects(i).col
			EndIf
		Next i
	EndIf

	Locate 1,1: Color RGB(80,40,40)
	'Print "spds:";(pl.spd);" ";(Distance(pl.x,pl.y,pl.oldx,pl.oldy)/gameTimer.frameTime)
	Print "FPS: ";gameTimer.getFPS
	If Not LEE Then
		#Ifdef NETWORK_enabled
			If keepAliveTimer.hasExpired() Then hasMovedOnline = -1
			'HandleTraffic()
			#Include "../server/client/networking.bas"
		#EndIf
		Print "Ping:";CInt((ping)*1000.0)
		Print "Players:";numPlayers
		Print "Particles: ";particles.itemCount
		Print traffic_in
	Else
		game.viewLevelChanged = 0
	EndIf
	'Print "UniqueId:";GetStarId(pl.x,pl.y)
	'Print "frameTime: ";gameTimer.frameTime
	DrawASCIIFrame viewStartX-8, viewStartY-8, scrW-viewStartX+8, viewStartY+8+16*viewY, RGB(0,32,48)

	#Define UIframe1 RGB(0,24,96)
	#Define UItext1  RGB(64,64,96)
	If LEE Then

	Else 'Not LEE
	'' Status ''
	tempx = 0 : tempy = viewStartY-8
	DrawASCIIFrame tempx, tempy, viewStartX-16, tempy+8*8, UIframe1, "Ship Status"
	Color UItext1
	Draw String (tempx+16, tempy+16 ), "Hull cond: "+Str(100)+"%"
	'Draw String (tempx+16, tempy+16), "Shields  : "+Str(100)+"%"
	Draw String (tempx+16, tempy+24), "A-M Fuel : "+Str(pl.fuel)+"kg"
	Draw String (tempx+16, tempy+32), "Energy   : "+Str(pl.energy)+""
	'' Scanners ''
	tempx = 0 : tempy = viewStartY-8 + 10*8
	DrawASCIIFrame tempx, tempy, viewStartX-16, tempy+8*8, UIframe1, "Scanners"
	Color UItext1
	temp = tileBuf.GetTexture(pl.x,pl.y).tex1.desc
	Draw String (tempx+16, tempy+16), UpFirst(temp)
	Select Case As Const game.viewLevel
		Case zSystem
			Draw String (tempx+16, tempy+24 ), "Suns   : "+Str(game.curSystem.starCount)
			Draw String (tempx+16, tempy+32) , "Planets: "+Str(game.curSystem.planetCount)
		Case zOrbit
			Draw String (tempx+16, tempy+24 ), UpFirst(table_SystemObjectNames(game.curPlanet.objType))
			'TODO: add starship count
			Draw String (tempx+16, tempy+32), "Starships: "+"0"
	End Select
	'' Devices ''
	tempy = viewStartY-8 + 20*8
	DrawASCIIFrame tempx, tempy, viewStartX-16, tempy+8*8, RGB(32,32,64), "Devices"
	Draw String (tempx+16, tempy+16), "No Devices"
	'' Beacons ''
	tempy = viewStartY-8 + 30*8
	DrawASCIIFrame tempx, tempy, viewStartX-16, tempy+12*8, RGB(64,0,64), "Nav Beacons"
	Color RGB(96,0,96)
	For i = 1 to 9
		Draw String (tempx+16, tempy+16+(i-1)*8), Str(i)+": N/A"
	Next i
	'Draw String (tempx+16, tempy+8)
	'' Missiles ''
	tempy = viewStartY-8 + 44*8
	DrawASCIIFrame tempx, tempy, viewStartX-16, tempy+5*8, RGB(64,0,16), "Torpedos"
	Color RGB(96,0,00)
	Draw String (tempx+16, tempy+2*8), "Amount: 0"
	Draw String (tempx+16, tempy+3*8), "Armed:  0"

	'' Cargo / Build ''
	DrawASCIIFrame viewStartX+16*viewX+16, viewStartY-8, scrW-8, viewStartY+8*8, RGB(0,96,24), "Cargo Stats"
	Color UItext1
	Draw String (viewStartX+16*viewX+16+16, viewStartY+8 ), !"Total Space:    100 m3"
	Draw String (viewStartX+16*viewX+16+16, viewStartY+16), !"Used Space :      0 m3"
	Draw String (viewStartX+16*viewX+16+16, viewStartY+24), !"Used %     :      0 %"
	tempy = viewStartY + 11*8
	If buildMode Then temp = "BUILD MENU" Else temp = "Cargo Inventory"
	DrawASCIIFrame viewStartX+16*viewX+16, tempy-8, scrW-8, viewStartY+8+16*viewY, RGB(100,50,0), temp
	If buildMode = 0 Then
		Color UItext1
		Draw String (viewStartX+16*viewX+16+16, tempy+8), "Nothing"
	Else
		tempx = viewStartX+16*viewX+16+16
		For i = 1 To BuildingCount
			temp = Str(i) + " = " + Buildings(i).desc + String(17-Len(Buildings(i).desc), " ") +Chr(Buildings(i).tex.char)
			Draw String (tempx, tempy+i*8), temp, RGB(Buildings(i).tex.r, Buildings(i).tex.g, Buildings(i).tex.b)
		Next i
	EndIf

	EndIf 'LEE
	'' Info ''
	DrawASCIIFrame viewStartX-8, 8, scrW-viewStartX+8, 5*8, RGB(0,0,96), "Information"
	Draw String (viewStartX+8, 16), "Coords: "+Str(CLngInt(pl.x))+" - "+Str(CLngInt(pl.y))
	Draw String (viewStartX+8, 24), "Time: "+GetTimeString()
	Draw String (viewStartX+8, 32), "Credits: "+Str(0)
	'' Messages ''
	DrawASCIIFrame viewStartX-8, 9*8+16*viewY, scrW-viewStartX+8, scrH-4*8, RGB(64,0,24), "Messages"
	PrintMessages viewStartX, 10*8+16*viewY, 10
	Else
		DrawHelp(game.viewLevel)
	EndIf

	k = InKey
	If k = Chr(255,68) Then
		Var shotname = "shots/shot"+Str(Int(Rnd*90000)+10000)+".png"
		SavePNG(shotname)': Sleep 1000
		AddMsg("Screenshot saved to "+shotname)
	EndIf
	If consoleOpen Then
		msg = GameInput("> ", viewStartX, scrH-16, msg, k)
		#IfDef CLIPBOARD_enabled
			If MultiKey(KEY_CONTROL) And MultiKey(KEY_V) Then msg = msg & getClip():Sleep 500
			If MultiKey(KEY_CONTROL) And MultiKey(KEY_C) Then setClip(msg):Sleep 500
		#EndIf
		If MultiKey(KEY_ENTER) Then
			consoleOpen = 0
			If msg = "/ping" Then AddMsg("PING: " & Str(CInt((ping)*1000.0))): msg = ""
			If msg = "/info" Or msg = "/who" Or msg = "/count" Then serverQueries = queries.playerCount : msg = ""
			If Left(msg,6) = "/goto " Then GoToCoords(Mid(msg,7),pl,tileBuf): msg = ""
		EndIf
	Else
		If helpscreen = 1 And k <> "" Then helpscreen = 0: k = ""
		If k = Chr(255,59) Then helpscreen = 1
	EndIf
	switch(workpage)
	Sleep 2,1 'this hack reduces cpu usage in some cases
Loop Until k = Chr(27) Or k = Chr(255) & "k"

#Ifdef NETWORK_enabled
sock.close()
#EndIf

End


''''''''''''''''''''''''''''
'''                      '''
'''   END OF MAIN LOOP   '''
'''                      '''
''''''''''''''''''''''''''''

Function GoToCoords(stamp As String, ByRef pl As SpaceShip, ByRef tileBuf As TileCache) As Integer
	pl.spd = 0
	pl.upX = -100 : pl.upY = -100
	moveStyle = 0
	Dim As Integer count = CountWords(stamp,"#")
	Dim As Integer x,y, oldx,oldy
	Dim As Byte nounder = 0
	pl.curIcon = char_starship
	prevTileBuf = tileBuf
	For i As Integer = zStarmap To zStarmap+count-1
		x = CInt( GetWord( GetWord(stamp,i-zStarmap+1,"#"), 1, "," ) )
		y = CInt( GetWord( GetWord(stamp,i-zStarmap+1,"#"), 2, "," ) )
		oldx = pl.x: oldy = pl.y
		pl.x = x : pl.y = y
		game.viewLevel = i
		game.viewLevelChanged = -1
		game.updateBounds
		Select Case i
			Case zStarmap
				BuildNoiseTables game.curStarmap.seed, 8
				tileBuf = TileCache(pl.x, pl.y, @GetStarmapTile)
			Case zSystem
				If StarmapHasStar(oldx,oldy).char <> 0 Then game.curSystem = SolarSystem(oldx, oldy) Else pl.x = oldx: pl.y = oldy: Return 0
				tileBuf = TileCache(pl.x, pl.y, @GetSolarTile)
			Case zOrbit
				nounder = -1
				For j As Integer = game.curSystem.starCount To game.curSystem.starCount + game.curSystem.planetCount-1
					If oldx = game.curSystem.objects(j).x And oldy = game.curSystem.objects(j).y Then
						game.curPlanet = game.curSystem.objects(j)
						nounder = 0
						Exit For
					EndIf
				Next j
				If nounder Then pl.x = oldx: pl.y = oldy: Return 0
				game.curPlanet.Enter
				game.curPlanet.BuildMap
				tileBuf = TileCache(pl.x, pl.y, @GetOrbitTile)
				If pl.x = -1 OrElse pl.y = -1 Then pl.x = ORBITSIZE/2: pl.y = ORBITSIZE/2
			Case zPlanet
				tileBuf = TileCache(pl.x, pl.y, @GetGroundTile)
				pl.curIcon = char_lander
			Case zDetail
				If game.curPlanet.objType = pGas Then pl.x = oldx: pl.y = oldy: Return 0 Else game.curArea = SurfaceArea(oldx, oldy, oldy * game.curPlanet.w + oldx)
				tileBuf = TileCache(pl.x, pl.y, @GetAreaTile)
				pl.curIcon = char_walking
		End Select
	Next i
	bufferBlendFunc = @CacheBlend_Fractal
	Return -1
End Function














Const maxMsg = 10
Dim Shared messageBuffer(1 To maxMsg) As String
Sub AddMsg(_msg As String)
	For i As Integer = maxMsg To 2 Step -1
		messageBuffer(i) = messageBuffer(i-1)
	Next i
	messageBuffer(1) = _msg
End Sub

Sub PrintMessages(x As Integer, y As Integer, _count As Integer = 1)
	#define mcolr 128.0
	#define mcolg 128.0
	#define mcolb 128.0
	#define mcolmin 32.0
	For i As Integer = 1 To _count
		If messageBuffer(i) = "" Then Return
		Draw String ( x, y + (i-1)*8 ), messageBuffer(i), RGB( 	blend(mcolr,mcolmin,(_count-i)/_count), _
																blend(mcolg,mcolmin,(_count-i)/_count), _
																blend(mcolb,mcolmin,(_count-i)/_count)  )
	Next i
End Sub



Function GameInput(promt As String = "", x As Integer, y As Integer, stri As String, k As String = "", passwordchar As String = "") As String
	Static _input_timer As Double
	Static _backspace_timer_delay As Double = 0.5
	Static _backspace_down_flag As Integer = 0
	Dim As UByte j = Asc(k)
	If j >= 32 And j <= 246 Then stri = stri & Chr(j)
	If Len(stri) > 0 And Timer > _input_timer + _backspace_timer_delay Then
		If j = 8 Or MultiKey(KEY_BACKSPACE) Then
			stri = Left(stri,Len(stri)-1)
			_input_timer = Timer
			If _backspace_down_flag = 1 Then _
				_backspace_timer_delay = 0.01 _
				Else _backspace_down_flag += 1
		Else
			_backspace_timer_delay = .5
			_backspace_down_flag = 0
		EndIf
	EndIf
	Var dispstri = stri
	If passwordchar <> "" Then dispstri = String(Len(stri), passwordchar)
	Draw String (x,y), promt & dispstri & "|", RGB(150,250,250)
	Return stri
End Function


Sub SaveBookmarks(filename As String = BOOKMARKFILE)
	Var f = FreeFile
	Open filename For Output As #f
		For i As Integer = 1 To 9
			Print #f, bookmarks(i)
		Next i
	Close #f
End Sub

Sub LoadBookmarks(filename As String = BOOKMARKFILE)
	Var f = FreeFile
	Open filename For Input As #f
		For i As Integer = 1 To 9
			Line Input #f, bookmarks(i)
		Next i
	Close #f
End Sub


Sub TimeManager()
	Static timeGame As DelayTimer = DelayTimer(ticksecs)
	Static timeSyncTimer As DelayTimer = DelayTimer(TimeSyncInterval)
	If timeGame.hasExpired Then
		gametime+=1
		timeGame.start
	EndIf
	#Ifdef NETWORK_enabled
	If timeSyncTimer.hasExpired Then
		''''' Send time update request
		serverQueries = queries.timeSync
		timeSyncTimer.start
	EndIf
	#EndIf
End Sub

Function GetTime() As ULongInt
	Return gametime
End Function

Function GetTimeString() As String
	Var timeString = "Epoch "+Str(Int(gametime / 50000000)+1001) + ", "
	timeString += "Span "+Str(Int((gametime / 2500000)) Mod 20) + ", "
	timeString += "Unit "+Str(Int((gametime / 100000)) Mod 25) + ", "
	timeString += "Beat "+Str(gametime Mod 100000)
	Return timeString
End Function


Sub ParseCommandline()
	Dim i As Integer = 1
	Dim launch_updater As Integer = -1
	Var arg = Command(i)
	Do While arg <> ""
		Select Case arg
			Case "-h", "--help"
				Print "Infiniverse-client ("+EXENAME+")"
				#IfNDef NETWORK_enabled
				Print "(Networking disabled)"
				#EndIf
				Print "Version " + INF_VERSION
				Print "Arguments:"
				Print !"\t-h, --help"
				Print !"\t\tDisplay this text and exit"
				Print !"\t-v, --version"
				Print !"\t\tDisplay version and exit"
				Print !"\t-s <server_address>, --server <server_address>"
				Print !"\t\tConnect to specified server"
				Print !"\t-p <port>, --port <port>"
				Print !"\t\tUse the specified port"
				Print !"\t-u <name>, --user <name>"
				Print !"\t\tAuto-login with given user name"
				Print !"\t-w <password>, --password <password>"
				Print !"\t\tAuto-login password, -u required"
				Print !"\t-c <ini-file>, --config <ini-file>"
				Print !"\t\tRead configuration from specified file"
				Print !"\t\tdefault: " + CONFIGFILE
				Print !"\t-l <logfile>, --logfile <logfile>"
				Print !"\t\tLog output to specified file"
				#IfDef NETWORK_enabled
				Print !"\t-z, --lee"
				Print !"\t\tStart Lone Explorer Edition"
				Print !"\t\t(single-player version)"
				#EndIf
				End
			Case "-v", "--version"
				Print EXENAME + " " + INF_VERSION
				End
			Case "-p", "--port"
				If CInt(Command(i+1)) > 0 Then port = CInt(Command(i+1))
				i += 1
			Case "-s", "--server"
				serveraddress = Command(i+1)
				i += 1
			Case "-c", "--config"
				If Command(i+1) <> "" Then CONFIGFILE = Command(i+1)
				i += 1
			Case "-u", "--user"
				my_name = Command(i+1)
				i += 1
			Case "-w", "--password"
				passwd = Command(i+1)
				i += 1
			Case "-l", "--logfile"
				LOGFILE = Command(i+1)
				i += 1
			Case "-z", "--lee"
				LEE = Not 0
			Case "-d", "--no-launcher"
				launch_updater = 0
			Case "-s", "--stars"
				PrintStars()
				End
			Case Else
				Print "Unknown command line argument: " + arg
				Print "Try --help"
				End
		End Select
		i += 1
		arg = Command(i)
	Loop
	''If launch_updater Then Print "Launching Updater..." : Run("./"+UPDATER_EXE_NAME) : End
End Sub

#Include Once "keys.bas"
#Include Once "world.bas"
