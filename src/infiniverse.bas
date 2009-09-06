' Project "Infiniverse" - A Procedural Exploration Game

#Define INF_VERSION "0.4.5"

#Define NETWORK_enabled
#Define CLIPBOARD_enabled


#Include Once "fbclp.bi"
Using fb_clipboard


#Include Once "PNGscreenshot.bas"
#Include Once "miscfb/def.bi"
#Include Once "miscfb/util.bas"
#Include Once "miscfb/libNoise.bas"
#Include Once "miscfb/words.bi"
'#Include "fbgfx.bi"


Dim Shared EXENAME As String: EXENAME = Command(0)
Dim Shared LOGFILE As String: LOGFILE = ""
Dim Shared CONFIGFILE As String: CONFIGFILE = "data/server.ini"
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

#IfDef NETWORK_enabled
	Print "Infiniverse-client "+INF_VERSION
#Else
	Print "Infiniverse Lone Explorer Edition "+INF_VERSION
#EndIf
Print ".  . .   .    .       .    . . \|/ ."
Print " .       +     ..    .   *     -o-  "
Print "   * .     . .  . .     .  . . /|\ ."
Print ". .     .    . * .   +     *    .   "
If LOGFILE = "" Then Print "Logging disabled (no log file specified)"

Const scrW = 1024
Const scrH = 768
ScreenRes scrW, scrH, 32, 2', 1
WindowTitle "Infiniverse Client"
Dim As Byte workpage, curTileCache = 0

'Const viewX = 36
'Const viewY = 36
#Define viewX (36)
#Define viewY (36)
Const viewStartX = scrW * .5 - viewX * 8
Const viewStartY = 7 * 8

Const log_enabled = -1
Const BOOKMARKFILE = "data/bookmarks.ini"

#Include Once "protocol.bi"
#Include Once "tileengine.bas"

'Print SizeOf(ASCIITexture)
'Print SizeOf(ASCIITile)
'Sleep

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
Declare Function GameInput(promt As String = "", x As Integer, y As Integer, stri As String, k As String = "") As String
'Declare Function GoToCoords(stamp As String, ByRef pl As SpaceShip, ByRef tileBuf As TileCache) As Byte
Declare Sub GenerateTextures(seed As Double = -1)
Declare Sub GenerateDistantStarBG(array() As UByte)
Declare Sub AddVariance(ByRef tile As ASCIITile, variance As Short)
Declare Function AddVarianceToColor(col As UInteger, variance As Short) As UInteger
Declare Sub AddMsg(_msg As String)
Declare Sub PrintMessages(x As Integer, y As Integer, _count As Integer = 1)
Declare Sub DrawASCIIFrame(x1 As Integer, y1 As Integer, x2 As Integer, y2 As Integer, col As UInteger = 0, Title As String = "")
Declare Sub SaveBookmarks(filename As String = BOOKMARKFILE)
Declare Sub LoadBookmarks(filename As String = BOOKMARKFILE)

Const TimeSyncInterval = 3.000
Declare Sub TimeManager()
Declare Function GetTime() As ULongInt
Declare Function GetTimeString() As String
Dim Shared As ULongInt gametime = 0


#Include Once "universe.bi"
#Include Once "helps.bas"

'Dim Shared As UByte farStarBG(1024, 1024)
'GenerateDistantStarBG(farStarBG()) 

#Define char_starship Chr(234)
#Define char_lander   Chr(227)
#Define char_walking  "@"

Type SpaceShip
	x    As Double
	y    As Double
    ang  As Single  = 0
    spd  As Double  = 0
    oldx As Integer = 0
    oldy As Integer = 0
    upX  As Integer = -100
    upY  As Integer = -100
    fuel As Single  = 100
	energy As Single = 100
    curIcon As String = char_starship
    Declare Constructor(x As Double = 0, y As Double = 0, ang As Single = 0)
End Type
    Constructor SpaceShip(x As Double = 0, y As Double = 0, ang As Single = 0)
        this.x   = x
        this.y   = y
        this.ang = ang
    End Constructor

Declare Sub Keys(ByRef pl As SpaceShip, ByRef tileBuf As TileCache)
Declare Function GoToCoords(stamp As String, ByRef pl As SpaceShip, ByRef tileBuf As TileCache) As Byte

Type Player
	x As Integer
	y As Integer
	id As String
End Type
ReDim players(0) As Player
Dim numPlayers As Integer = 0
Dim As String temp, temp2, tempst
Dim As String msg = "", traffic_in = "", traffic_out = "", k = "" 'k = key
Dim As Double pingTime
Dim As UByte char, testbyte
Dim As Integer i,j, tempx,tempy, tempz, count


#Ifdef NETWORK_enabled
	#Include "client.bas"
#EndIf
#Ifndef SEP
	#Define SEP Chr(1)
#EndIf

	Dim Shared As Integer pendingModifications = 0
	Dim Shared modQueue(pendingModifications) As String
	'If log_enabled Then AddLog(my_name & "---NEW---")

    Dim Shared game As GameLogic
        game.viewLevel = zStarmap
        game.curGalaxy = Galaxy(42)
        game.updateBounds
        game.curStarmap.seed = game.curGalaxy.seed
		BuildNoiseTables game.curStarmap.seed, 8
    'Dim pl As SpaceShip = SpaceShip(GALAXYSIZE/2,GALAXYSIZE/2,90)
    Dim pl As SpaceShip = SpaceShip(game.curStarmap.size/2,game.curStarmap.size/2,90)
    Dim tileBuf As TileCache = TileCache(pl.x, pl.y, @GetStarmapTile)
    GoToCoords("4194312,4194292", pl, tileBuf)
    Dim gameTimer As FrameTimer
    Dim trafficTimer As DelayTimer = DelayTimer(0.05)
	Dim Shared As Byte moveStyle = 0, hasMoved = 0, hasMovedOnline = 0
	Dim Shared As UByte serverQueries = queries.timeSync, gotoBookmarkSlot = 0
	Dim Shared As Byte consoleOpen = 0, auto_slow = 0
	Dim Shared As String bookmarks(1 To 9)
	Dim As Byte helpscreen = 0

	LoadBookmarks()

	#Ifdef NETWORK_enabled
		sock.put(1)
		sock.put(Chr(actions.changeArea + game.viewLevel) & my_name & SEP & Str(CInt(pl.x)) & SEP & Str(CInt(pl.y)) & SEP & game.getAreaID)
	#EndIf


    ' ------- MAIN LOOP ------- '
    Do
        gameTimer.Update
		TimeManager()
        ScreenSet workpage, workpage Xor 1
        Cls
        
        If helpscreen = 0 Then
        If consoleOpen = 0 Then Keys pl, tileBuf
        If gotoBookmarkSlot <> 0 Then tempz = GoToCoords(bookmarks(gotoBookmarkSlot),pl,tileBuf): gotoBookmarkSlot = 0
        
        UpdateCache tileBuf, CInt(pl.x),CInt(pl.y), viewX,viewY
        DrawView tileBuf, CInt(pl.x),CInt(pl.y), viewStartX,viewStartY, viewX,viewY
        Draw String ( viewStartX + 8*viewX, viewStartY + 8*viewY ), pl.curIcon, RGB(150,250,150)
        Draw String ( viewStartX + 8*(viewX+CInt(Cos(pl.ang*DegToRad)*10)), viewStartY + 8*(viewY-CInt(Sin(pl.ang*DegToRad)*10)) ), "x", RGB(0,255,0)
        If pl.upX > 0 AndAlso Abs(pl.upX-pl.x) < viewX AndAlso Abs(pl.upY-pl.y) < viewY Then Draw String ( viewStartX + 8*(viewX + (pl.upX-CInt(pl.x))), viewStartY + 8*(viewY + (pl.upY-CInt(pl.y))) ), "X", RGB(200,0,200)
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

		#Ifdef NETWORK_enabled
			#Include "networking.bas"
		#EndIf

        Locate 1,1: Color RGB(80,40,40)
        Print "FPS:";gameTimer.getFPS
        'Print "UniqueId:";GetStarId(pl.x,pl.y)
        'Print "Players:";numPlayers
        'Print traffic_in
        'Print "Coords:";pl.x;pl.y
        DrawASCIIFrame viewStartX-8, viewStartY-8, scrW-viewStartX+8, viewStartY+8+16*viewY, RGB(0,32,48)
        
		#Define UIframe1 RGB(0,24,96)
		#Define UItext1  RGB(64,64,96)
        '' Status ''
        tempx = 0 : tempy = viewStartY-8
		DrawASCIIFrame tempx, tempy, viewStartX-16, tempy+8*8, UIframe1, "Ship Status"
		Color UItext1
		Draw String (tempx+16, tempy+8 ), "Hull cond: "+Str(100)+"%"
		'Draw String (tempx+16, tempy+16), "Shields  : "+Str(100)+"%"
		Draw String (tempx+16, tempy+16), "A-M Fuel : "+Str(pl.fuel)+"kg"
		Draw String (tempx+16, tempy+24), "Energy   : "+Str(pl.energy)+"kg"
	    '' Scanners ''
        tempx = 0 : tempy = viewStartY-8 + 10*8
		DrawASCIIFrame tempx, tempy, viewStartX-16, tempy+8*8, UIframe1, "Scanners"
		Color UItext1
        Draw String (tempx+16, tempy+8), UpFirst(tileBuf.GetTexture(pl.x,pl.y).tex1.desc)
        Select Case game.viewLevel
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
        '' Cargo ''
		DrawASCIIFrame viewStartX+16*viewX+16, viewStartY-8, scrW-8, viewStartY+8*8, RGB(0,96,24), "Cargo Stats"
		Color UItext1
		Draw String (viewStartX+16*viewX+16+16, viewStartY   ), !"Total Space:     100 m3"
		Draw String (viewStartX+16*viewX+16+16, viewStartY+8 ), !"Used Space :       0 m3"
		Draw String (viewStartX+16*viewX+16+16, viewStartY+16), !"Used %     :       0 %"
		tempy = viewStartY + 11*8
		DrawASCIIFrame viewStartX+16*viewX+16, tempy-8, scrW-8, viewStartY+8+16*viewY, RGB(100,50,0), "Cargo Inventory"
		Color UItext1
		Draw String (viewStartX+16*viewX+16+16, tempy+8), "Nothing"
        '' Info ''
        DrawASCIIFrame viewStartX-8, 8, scrW-viewStartX+8, 5*8, RGB(0,0,96), "Information"
        Draw String (viewStartX+8, 16), "Coords: "+Str(CLngInt(pl.x))+" - "+Str(CLngInt(pl.y))
		Draw String (viewStartX+8, 24), "Time: "+GetTimeString()
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
        	'#Ifdef CLIPBOARD_enabled
        		If MultiKey(KEY_CONTROL) And MultiKey(KEY_V) Then msg = msg & getClip():Sleep 500
        		If MultiKey(KEY_CONTROL) And MultiKey(KEY_C) Then setClip(msg):Sleep 500
        	'#EndIf
        	If MultiKey(KEY_ENTER) Then
        		consoleOpen = 0
        		If msg = "/ping" Then serverQueries += queries.ping : msg = ""
        		If msg = "/info" Or msg = "/who" Or msg = "/count" Then serverQueries += queries.playerCount : msg = ""
        		If Left(msg,6) = "/goto " Then GoToCoords(Mid(msg,7),pl,tileBuf): msg = ""
        	EndIf
        Else
        	If helpscreen = 1 And k <> "" Then helpscreen = 0
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


Function GoToCoords(stamp As String, ByRef pl As SpaceShip, ByRef tileBuf As TileCache) As Byte
    pl.spd = 0
	pl.upX = -100 : pl.upY = -100
	moveStyle = 0
    Dim As Integer count = CountWords(stamp,"#")
    Dim As Integer x,y, oldx,oldy
    Dim As Byte nounder = 0
    pl.curIcon = char_starship
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
	Return -1
End Function





Sub Keys(ByRef pl As SpaceShip, ByRef tileBuf As TileCache)
	#Macro dostuff(updown)
	    game.viewLevel += updown
	    If updown < 0 Then pl.upX = pl.x : pl.upY = pl.y Else pl.upX = -100 : pl.upY = -100
	    game.updateBounds
	    moveStyle = 0
	    pl.spd = 0
	    game.viewLevelChanged = -1
	#EndMacro
    Static moveTimer As DelayTimer = DelayTimer(0.01)
    Static keyTimer As DelayTimer = DelayTimer(0.5)
    hasMoved = 0
    
    If MultiKey(KEY_LSHIFT) Then moveTimer.delay = 0 Else moveTimer.delay = .002
    'If moveStyle = 0 Then moveTimer.delay = .1 Else moveTimer.delay = .002
    
    Dim As Integer tempx, tempy
    
    If moveTimer.hasExpired Then
        pl.oldx = pl.x : pl.oldy = pl.y
        If moveStyle = 0 Then
        	Dim As UByte tempang = 0
        	pl.spd = 0
	        If MultiKey(KEY_UP)    Then tempang+=&b1000: pl.spd = .333
	        If MultiKey(KEY_DOWN)  Then tempang+=&b0010: pl.spd = .333
	        If MultiKey(KEY_LEFT)  Then tempang+=&b0001: pl.spd = .333
	        If MultiKey(KEY_RIGHT) Then tempang+=&b0100: pl.spd = .333
	        If pl.spd <> 0 Then pl.ang = table_dirAngles(tempang)
	        If MultiKey(KEY_W) AndAlso game.viewLevel <> zDetail AndAlso game.viewLevel <> zGalaxy Then moveStyle = 1: pl.spd = 1.0
        Else
        	'If MultiKey(KEY_SPACE) Then pl.spd = 0
	        If MultiKey(KEY_W) Then
	        	pl.spd += .02
	        Else
	        	If auto_slow Then pl.spd *= .95
	        	If pl.spd < .2 Then pl.spd = 0: moveStyle = 0
	        EndIf
	        If MultiKey(KEY_S)  Then pl.spd = Max(0,pl.spd-.01)': moveTimer.start
        EndIf
        If MultiKey(KEY_A) Then pl.ang = wrap(pl.ang+5,360): moveTimer.start
        If MultiKey(KEY_D) Then pl.ang = wrap(pl.ang-5,360): moveTimer.start
		If pl.spd <> 0 Then
	        pl.x = pl.x + Cos(pl.ang * DegToRad) * pl.spd
	        pl.y = pl.y - Sin(pl.ang * DegToRad) * pl.spd
			hasMoved = -1
			moveTimer.start
		EndIf
		'If ( game.viewLevel = zGalaxy ) AndAlso (Not inBounds(pl.x,0,game.boundW(game.viewLevel)-1) OrElse Not inBounds(pl.y,0,game.boundH(game.viewLevel)-1)) Then
		'	pl.x = pl.oldx: pl.y = pl.oldy
		If game.viewLevel = zDetail AndAlso (pl.x <> pl.oldx OrElse pl.y <> pl.oldy) Then
			If (game.curArea.areaArray(CInt(pl.x),CInt(pl.y)).flags And BLOCKS_MOVEMENT) <> 0 Then pl.x = CInt(pl.oldx): pl.y = CInt(pl.oldy): pl.spd = 0
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
                tileBuf = TileCache(pl.x, pl.y, @GetAreaTile)
        		game.viewLevelChanged = -1
			EndIf
		ElseIf (Not inBounds(pl.x,0,game.boundW(game.viewLevel)-1)) OrElse (Not inBounds(pl.y,0,game.boundH(game.viewLevel)-1)) Then
			If game.viewLevel = zSystem Then
                pl.x = game.curSystem.x
                pl.y = game.curSystem.y
                tileBuf = TileCache(pl.x, pl.y, @GetStarmapTile)
                BuildNoiseTables game.curStarmap.seed, 8
				dostuff(-1)
			Else
				If pl.x < 0 Then pl.x += game.boundW(game.viewLevel)
				If pl.y < 0 Then pl.y += game.boundH(game.viewLevel)
				If pl.x > game.boundW(game.viewLevel) Then pl.x -= game.boundW(game.viewLevel)
				If pl.y > game.boundH(game.viewLevel) Then pl.y -= game.boundH(game.viewLevel)
				'pl.x = wrap(pl.x, game.boundW(game.viewLevel))
				'pl.y = wrap(pl.y, game.boundH(game.viewLevel))
			EndIf
		EndIf
    EndIf
    
    Dim As Byte controlKey = 0, buildMode = 0
    If MultiKey(KEY_B) And game.viewLevel = zDetail Then buildMode = -1'Not buildmode '-1
    If MultiKey(KEY_CONTROL) Then controlKey = -1
    
    tempx = CInt(pl.x): tempy = CInt(pl.y)
    ' Keys that are pressed, not held down: 
    If keyTimer.hasExpired Then
    	Dim As String tempk
    	If MultiKey(KEY_T) Then consoleOpen = -1: tempk = InKey: Exit Sub
    	'If MultiKey(KEY_F2) Then switch(moveStyle): pl.x = Int(pl.x): pl.y = Int(pl.y): keyTimer.start
    	If MultiKey(KEY_F3) Then switch(auto_slow): keyTimer.start
    	#Ifdef NETWORK_enabled
    	If MultiKey(KEY_I) Then serverQueries = queries.areaInfo   : keyTimer.start
    	If MultiKey(KEY_O) Then serverQueries = queries.playerCount: keyTimer.start
    	If MultiKey(KEY_P) Then serverQueries = queries.ping       : keyTimer.start
    	#EndIf
    	If buildMode Then
    		For i As Integer = 1 To BuildingCount
    			If MultiKey(i+1) Then
    				If game.curArea.Modify(tempx,tempy, ASCIITile( buildings(i).tex,0,buildings(i).flags )) Then
						#Ifdef NETWORK_enabled
				    		pendingModifications+=1
				    		ReDim Preserve modQueue(1 To pendingModifications) As String
				    		modQueue(pendingModifications) = Chr(tempx+detCoordOffSet,tempy+detCoordOffSet,i)
						#Endif
						'RefreshTile(tileBuf,tempx,tempy)
						tileBuf.isEmpty = -1
					EndIf
					keyTimer.start
    				Exit For
    			EndIf
    		Next i
       	EndIf
    	If MultiKey(KEY_N) And MultiKey(KEY_B) And game.viewLevel = zDetail Then
    		For i As Integer = 1 To 100
    			tempx = Rand(1,127) : tempy = Rand(1,127)
    			game.curArea.Modify(tempx,tempy,ASCIITile(ASCIITexture(Asc("#"), 128,128,128),0,BLOCKS_MOVEMENT))
	    		pendingModifications+=1
	    		ReDim Preserve modQueue(1 To pendingModifications) As String
	    		modQueue(pendingModifications) = SEP & Str(tempx) & SEP & Str(tempy) & SEP & "#" & Chr(128,128,128)
    		Next i
    		tileBuf.isEmpty = -1
    		keyTimer.start
    	EndIf

        ' enter places
        If MultiKey(KEY_SPACE) Then
        	If pl.spd <> 0 Then
        		pl.spd = 0
        		pl.x = CInt(pl.x)
        		pl.y = CInt(pl.y)
        	Else
            Select Case game.viewLevel
                Case zGalaxy
                    If in2dArray(game.curGalaxy.gmap,tempx,tempy) Then
                        Dim As Double temp = CDbl(game.curStarmap.size) / GALAXYSIZE
                        pl.x = CInt(temp * CInt(pl.x))
                        pl.y = CInt(temp * CInt(pl.y))
                        tileBuf = TileCache(pl.x, pl.y, @GetStarmapTile)
                        BuildNoiseTables game.curStarmap.seed, 8
						dostuff(1)
						AddMsg("Jumping to designated galaxy location")
                    EndIf
                Case zStarmap
                    If StarmapHasStar(tempx,tempy).char <> 0 Then
                        game.curSystem = SolarSystem(CInt(pl.x), CInt(pl.y))
                        pl.x = CInt(game.curSystem.size / 2)
                        pl.y = CInt(game.curSystem.size / 2)
                        tileBuf = TileCache(pl.x, pl.y, @GetSolarTile)
						dostuff(1)
						AddMsg("Entering solar system")
	                EndIf 
                Case zSystem
                    For i As Integer = game.curSystem.starCount To game.curSystem.starCount + game.curSystem.planetCount-1
                        If tempx = game.curSystem.objects(i).x And tempy = game.curSystem.objects(i).y Then
                            game.curPlanet = game.curSystem.objects(i)
                            game.curPlanet.Enter
							game.curPlanet.BuildMap
                            pl.x = CInt(ORBITSIZE/2 - Cos(pl.ang*DegToRad) * game.curPlanet.h/ORBITFACTOR)
                            pl.y = CInt(ORBITSIZE/2 + Sin(pl.ang*DegToRad) * game.curPlanet.h/ORBITFACTOR)
                            tileBuf = TileCache(pl.x, pl.y, @GetOrbitTile)
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
	                    tileBuf = TileCache(pl.x, pl.y, @GetGroundTile)
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
		                    tileBuf = TileCache(pl.x, pl.y, @GetAreaTile)
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
                    tileBuf = TileCache(pl.x, pl.y, @GetGalaxyTile)
					dostuff(-1)
					AddMsg("Entering trans-galactic navigation mode")
                Case zSystem
                    pl.x = game.curSystem.x
                    pl.y = game.curSystem.y
                    tileBuf = TileCache(pl.x, pl.y, @GetStarmapTile)
                    BuildNoiseTables game.curStarmap.seed, 8
					dostuff(-1)
					AddMsg("Entering inter-stellar navigation mode")
            	Case zOrbit
            		pl.x = game.curPlanet.x
                    pl.y = game.curPlanet.y
                    tileBuf = TileCache(pl.x, pl.y, @GetSolarTile)
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
                    tileBuf = TileCache(pl.x, pl.y, @GetOrbitTile)
                    BuildNoiseTables game.curSystem.seed, 8
                    pl.curIcon = char_starship
					dostuff(-1)
					pl.upX = -100 : pl.upY = -100
					AddMsg("Ascending to high orbit")
                Case zDetail
                    pl.x = game.curArea.x
                    pl.y = game.curArea.y
                    tileBuf = TileCache(pl.x, pl.y, @GetGroundTile)
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
				AddLog(Date & " " & Time & " : " & bookmarks(slot), "bookmarks.log")
				SaveBookmarks("bookmarks.ini")
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



Function GameInput(promt As String = "", x As Integer, y As Integer, stri As String, k As String = "") As String
	Dim As UByte j = Asc(k)
	If j >= 32 And j <= 246 Then stri = stri & Chr(j)
	If Len(stri) > 0 Then
		If j = 8 Then
			stri = Left(stri,Len(stri)-1)
		ElseIf MultiKey(KEY_BACKSPACE) Then	
			stri = Left(stri,Len(stri)-1)
		EndIf		
	EndIf
	Draw String (x,y), promt & stri & "|", RGB(150,250,250)
	Return stri
End Function

Sub DrawASCIIFrame(x1 As Integer, y1 As Integer, x2 As Integer, y2 As Integer, col As UInteger = 0, Title As String = "")
	If col = 0 Then col = LoWord(Color())
	Dim As String sthorz = String((x2-x1-8)/8, Chr(205)) '196
	Draw String (x1+8,y1  ), sthorz, col
	Draw String (x1+8,y2  ), sthorz, col
	For j As Integer = y1+8 To y2-8 Step 8 
		Draw String (x1,j), Chr(186), col '179
		Draw String (x2,j), Chr(186), col '179
	Next j
	'corners
	Draw String (x1,y1), Chr(201), col '218
	Draw String (x2,y1), Chr(187), col '191
	Draw String (x1,y2), Chr(200), col '192
	Draw String (x2,y2), Chr(188), col '217
	If Title <> "" Then Line (x1+15, y1)-(x1+15+8*Len(Title), y1+7), RGB(0,0,0), BF : Draw String (x1+16, y1), Title, col
End Sub

Sub SaveBookmarks(filename As String = "bookmarks.ini")
	Var f = FreeFile
	Open filename For Output As #f
		For i As Integer = 1 To 9
			Print #f, bookmarks(i)
		Next i
    Close #f
End Sub

Sub LoadBookmarks(filename As String = "bookmarks.ini")
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
	Var arg = Command(i)
	Do While arg <> ""
		Select Case arg
			Case "-h", "--help"
				#IfDef NETWORK_enabled
					Print "Infiniverse-client ("+EXENAME+")"
				#Else
					Print "Infiniverse Lone Explorer Edition ("+EXENAME+")"
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
			Case "-s", "--stars"
				Print ".  . .   .    .       .    . . \|/ ."
				Print " .       +     ..    .   *     -o-  "
				Print "   * .     . .  . .     .  . . /|\ ."
				Print ". .     .    . * .   +     *    .   "
				End
			Case Else
				Print "Unknown command line argument: " + arg
				Print "Try --help"
				End
		End Select
		i += 1
		arg = Command(i)
	Loop
End Sub

#Include "world.bas"
