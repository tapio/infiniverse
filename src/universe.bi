
#Define GetStarId(x,y) ( CDbl(y) * STARMAPSIZE + CDbl(x) )
#Define GetPlanetSeed(x,y,id) ( (CDbl(y) * STARMAPSIZE + CDbl(x))*100 +(id) )

Const letters  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
Const lettersA = "AEIOUY"
Const lettersB = "BCDFGHJKLMNPQRSTVWXZ"

Dim Shared textures(20) As ASCIITexture
Const numVegChars = 20
Dim Shared vegChars(numVegChars) As UByte = {5,6,12,15,37,38,102,109,110,116,164,229,230,231,232,234,235,237,238,239}

Dim Shared As Byte table_StarMultiples(32) = { 1,1,1,1,1,1,1,1, _
                                               1,1,1,1,1,1,1,1, _
                                               1,1,2,2,2,2,2,2, _
                                               3,3,3,3,4,4,5,6 }
/'
Dim Shared As Byte table_StarTypes(32)     = { 0,0,0,1,1,1,1,1, _
                                               1,1,1,1,1,1,1,1, _
                                               2,2,2,2,2,3,3,3, _
                                               3,4,4,4,5,6,7,8 }
                                               '/
Dim Shared As Byte table_PlanetMultiples(32) = { 0,0,0,0,0,0,0,0, _
                                                 0,0,0,0,0,0,0,0, _
                                                 1,1,1,2,2,2,3,3, _
                                                 4,4,5,6,7,8,9,10 }
Dim Shared As Integer table_PlanetSizes(8)   = { 512,1024,2048,4096,8192,16384,32768,65536 }

Dim Shared As String table_SystemObjectNames(4)
table_SystemObjectNames(0) = "sun"
table_SystemObjectNames(1) = "gas giant"
table_SystemObjectNames(2) = "rocky planet"
table_SystemObjectNames(3) = "gaia planet"

Dim Shared As Double table_dirAngles(0 To 16)
table_dirAngles(&b0001) = pi
table_dirAngles(&b0010) = pi + pi/2.0
table_dirAngles(&b0100) = 0
table_dirAngles(&b1000) = pi/2.0
table_dirAngles(&b0011) = pi + pi/4.0
table_dirAngles(&b0110) = 2*pi - pi/4.0
table_dirAngles(&b1100) = pi/4.0
table_dirAngles(&b1001) = pi - pi/4.0
table_dirAngles(&b1110) = 0
table_dirAngles(&b0111) = pi + pi/2.0
table_dirAngles(&b1011) = pi
table_dirAngles(&b1101) = pi/2.0

Enum tex
    water
    lava
    ground_cold
    ground_cold2
    ground_cold3
    ground_base
    ground_base2
    ground_base3
    ground_warm
    ground_warm2
    ground_warm3
    hill
    mountain_low
    mountain_high
    vegetation_cold
    vegetation_base
    vegetation_base_humid
    vegetation_warm
    vegetation_warm_humid
End Enum

Enum StellarBodyTypes
	pSun
	pGas
	pRock
	pGaia
End Enum


Type StarProtos
    col  As UInteger
    size As UByte
    freq As Double
    desc As String
    Declare Constructor()
    Declare Constructor(col As UInteger, size As UByte, freq As Double, desc As String)
End Type
    Constructor StarProtos()
    End Constructor
    Constructor StarProtos(col As UInteger, size As UByte, freq As Double, desc As String)
        this.col  = col
        this.size = size
        this.freq = freq
        this.desc = desc
    End Constructor
/'
Dim Shared table_StarTypes(8) As StarProtos = {StarProtos(RGB(200,200,255), 250, 1.0/3000000.0, "Class O"), _
                                               StarProtos(RGB(160,160,255), 125,       0.00125, "Class B"), _
                                               StarProtos(RGB(200,200,255),  50,       0.00625, "Class A"), _
                                               StarProtos(RGB(220,220,160),  25,         0.030, "Class F"), _
                                               StarProtos(RGB(255,255,  0),  22,         0.077, "Class G"), _
                                               StarProtos(RGB(200,100,  0),  20,         0.125, "Class K"), _
                                               StarProtos(RGB(200,  0,  5),  10,         0.760, "Class M"), _
                                               StarProtos(RGB(160,160,160),   4,        0.0005, "Class D")}
'/
Dim Shared table_StarTypes(8) As StarProtos = {StarProtos(RGB(200,200,255), 250,       0.00001, "Class O"), _
                                               StarProtos(RGB(160,160,255), 125,         0.010, "Class B"), _
                                               StarProtos(RGB(200,200,255),  50,         0.010, "Class A"), _
                                               StarProtos(RGB(220,220,160),  25,         0.050, "Class F"), _
                                               StarProtos(RGB(255,255,  0),  22,         0.150, "Class G"), _
                                               StarProtos(RGB(200,100,  0),  20,         0.220, "Class K"), _
                                               StarProtos(RGB(200,  0,  5),  10,         0.550, "Class M"), _
                                               StarProtos(RGB(160,160,160),   4,         0.010, "Class D")}

Const ORBITSIZE = 1024
Const ORBITFACTOR = 128
Const STARMAPSIZE = 8388608
Type Starmap
    seed As Double = 42
    size As Integer = STARMAPSIZE
End Type

ReDim Shared planetorbitmap(ORBITSIZE,ORBITSIZE) As ASCIITile

Type SystemObject
    seed    As Double
    id      As Byte
    objType As Byte = 0 '0=sun, 1=gas giant, 2=rock/ice, 3=gaia
    x As Integer
    y As Integer 
    w As Integer = 0
    h As Integer = 0
    col As UInteger
    size As UByte = 1
    flags As UByte = 0
    Declare Constructor()
    Declare Constructor(seed As Double, id As Byte, x As Integer, y As Integer, w As Integer, h As Integer, objType As Byte = 0)
    Declare Sub Enter()
	Declare Sub BuildMap()
End Type
    Constructor SystemObject()
    End Constructor 
    Constructor SystemObject(seed As Double, id As Byte, x As Integer, y As Integer, w As Integer, h As Integer, objType As Byte = 0)
        this.id = id
        this.objType = objType
        this.x = x
        this.y = y
        this.w = w
        this.h = h
        this.seed = seed
    End Constructor
    Sub SystemObject.Enter()
        BuildNoiseTables this.seed, 8
        If this.objType <> 0 Then GenerateTextures(this.seed)
        Randomize this.seed
    End Sub
	Sub SystemObject.BuildMap()
		Select Case this.objType
		Case Is > 0
			Redim planetorbitmap(0 to this.w/ORBITFACTOR-1, 0 to this.h/ORBITFACTOR-1)
			dim as integer r,g,b,cnt
			'AddLog("Start Building Map.")
			For j as integer = 0 to UBound(planetorbitmap,2)'-1
				for i as integer = 0 to UBound(planetorbitmap,1)'-1
					cnt = 0: r=0:g=0:b=0
					For n as integer= 1 to ORBITFACTOR step 32
						For m as integer = 1 to ORBITFACTOR step 32
							cnt+=1
							Var til = GetGroundTile(i*ORBITFACTOR+m, j*ORBITFACTOR+n)
							r += til.tex1.r : g += til.tex1.g : b += til.tex1.b
						Next m
					Next n
					planetorbitmap(i,j) = ASCIITile(ASCIITexture(176, r/cnt,g/cnt,b/cnt, "planet"), 0,,@Anim_RotatePlanet)
				Next i
			Next j
			'AddLog("Orbit Map Built.")
		End Select
	End Sub

Type SolarSystem
    x As Integer
    y As Integer
    seed As Double
    size As Integer
    starCount As Byte
    planetCount As Byte
    objects(32) As SystemObject
    numObjects As Byte
    nebulaColor As UInteger
    nebulaIntensity As UByte = 0
    sysName As String
    Declare Constructor()
    Declare Constructor(x As Integer, y As Integer)
End Type
    Constructor SolarSystem()
    End Constructor
    Constructor SolarSystem(x As Integer, y As Integer)
        this.x = x
        this.y = y
        this.size = 1024
        Dim t As ASCIITexture = GetStarmapTile(x,y).tex2
        this.nebulaColor = RGB(t.r,t.g,t.b)
        this.nebulaIntensity = max(t.r, t.g): this.nebulaIntensity = max(this.nebulaIntensity, t.b)
        this.seed = GetStarId(x,y)
        BuildNoiseTables this.seed, 3
        Randomize this.seed
        this.starCount   = table_StarMultiples(Int(Rnd*32))
        this.planetCount = table_PlanetMultiples(Int(Rnd*32))
        this.numObjects = this.starCount + this.planetCount
        Dim As Double ang
        'suns
        Dim thisStar As StarProtos
        ang = Rnd*360
        For i As Integer = 0 To this.starCount-1
    		Dim As Double freqcount = 0, value = Rnd
			For j As Integer = 0 To 7
				freqcount += table_StarTypes(j).freq
				If value < freqcount Then thisStar = table_StarTypes(j): Exit For
			Next j
            'thisStar = table_StarTypes(Int(Rnd*8))
            objects(i).seed     = 0
            objects(i).id       = i
            objects(i).objType  = 0
            objects(i).size     = thisStar.size
            objects(i).col      = AddVarianceToColor(thisStar.col, 25)
            ang = ang + (i * (360 / this.starCount))
            objects(i).x = this.size/2 + Cos(ang*DegToRad) * Rand(thisStar.size,255)
            objects(i).y = this.size/2 - Sin(ang*DegToRad) * Rand(thisStar.size,255)
        Next
        'planets
        For i As Integer = this.starCount To this.starCount+this.planetCount-1
            objects(i).seed = GetPlanetSeed(x,y,i)
            objects(i).id = i
            objects(i).objType = Int(Rnd*3)+1
            Select Case objects(i).objType
            	Case 1 : objects(i).col = RGB(128,0,0) : objects(i).flags = Int(Rnd*6)+1
            	Case 2 : objects(i).col = RGB(128,128,128)
            	Case 3 : objects(i).col = RGB(0,255,0)
            End Select
            ang = Rnd*360
            objects(i).x = this.size/2 + Cos(ang*DegToRad) * Rand(30,100)
            objects(i).y = this.size/2 - Sin(ang*DegToRad) * Rand(30,100)
            If objects(i).objType = pGas Then objects(i).w = table_PlanetSizes(Int(Rnd*3)+5) Else objects(i).w = table_PlanetSizes(Int(Rnd*5))
            objects(i).h = objects(i).w/2
        Next
        'this.sysName = GetStarName(this.seed)
    End Constructor


Function GetHighest(array() As Double) As Integer
	Dim As Integer winner = LBound(array,1)
	For i As Integer = LBound(array,1) To UBound(array,1)
		If array(i,1) > array(winner,1) Then winner = i
	Next i
	Return winner
End Function

Const AREASIZE = 128
Type SurfaceArea
	seed As Double
    x As Integer
    y As Integer
    w As Integer = AREASIZE
    h As Integer = AREASIZE
    areaChar As UByte
    r As UByte
    g As UByte
    b As UByte
    areaArray(AREASIZE,AREASIZE) As ASCIITile 
    Declare Constructor()
    Declare Constructor(x As Integer, y As Integer, seed As Double = -1)
    Declare Function Modify(x As Integer, y As Integer, newTile As ASCIITile) As Byte
End Type
    Constructor SurfaceArea()
    End Constructor 
    Constructor SurfaceArea(x As Integer, y As Integer, seed As Double = -1)
        this.x = x
        this.y = y
        this.areaChar = GetGroundTile(x,y).tex1.char
        this.seed = seed
        BuildNoiseTable this.seed, 8
        Randomize this.seed
    	Dim As Integer i,j
    	#Define hs CDbl(AREASIZE/2)
    	#Define fs CDbl(AREASIZE*.75)
    	#Define sqr2 1.4142135623
    	#Define rndvar Rnd*.333
    	#Define noiseSize 8
    	#Define noiseTol 100
		#Macro addRoughness()
			If areaArray(i,j).tex1.char = Asc(".") Then
				rndvalue = Rnd
				If rndvalue > .95 Then
					areaArray(i,j).tex1.char = Asc("o"): areaArray(i,j).tex1.desc = "rock"
				ElseIf rndvalue > .7 Then
					areaArray(i,j).tex1.char = Asc(",")
				EndIf
			EndIf
		#EndMacro
		
    	'#Define t(xoff,yoff) GetGroundTile((xoff)+x,(yoff)+y)
    	'AddLog("--trying to init neighbors")
    	Dim As ASCIITile neighbors(1 To 9)' = {t(-1,1),t(0,1),t(1,1),t(-1,0),t(0,0),t(1,0),t(-1,-1),t(0,-1),t(1,-1)}
    	neighbors(1) = GetGroundTile(x-1,y+1)
    	neighbors(2) = GetGroundTile(x  ,y+1)
    	neighbors(3) = GetGroundTile(x+1,y+1)
    	neighbors(4) = GetGroundTile(x-1,y  )
    	neighbors(5) = GetGroundTile(x  ,y  )
    	neighbors(6) = GetGroundTile(x+1,y  )
    	neighbors(7) = GetGroundTile(x-1,y-1)
    	neighbors(8) = GetGroundTile(x  ,y-1)
    	neighbors(9) = GetGroundTile(x+1,y-1)
    	'AddLog("--success init neighbors")
    	Dim As ASCIITile gr = GetPureGround(x,y)
    	Dim As Double freqs(4,1)
    	Dim As Double rndvalue
		ForIJ(0,hs,0,hs)
			freqs(0,0) = 5 : freqs(0,1) = 1.0 - (Distance(i,j,hs,hs) / (fs*sqr2)) + rndvar
			freqs(1,0) = 8 : freqs(1,1) = (Abs(j-hs) / fs) + rndvar
			freqs(2,0) = 4 : freqs(2,1) = (Abs(i-hs) / fs) + rndvar
			freqs(3,0) = 7 : freqs(3,1) = (Distance(i,j,hs,hs) / (fs*sqr2)) + rndvar
			areaArray(i,j) = neighbors(CInt(freqs(GetHighest(freqs()),0)))
			If Str(areaArray(i,j).tex1) <> Str(gr.tex1) AndAlso ( Rnd < .333 OrElse Perlin(i,j,1024,1024,noiseSize,8) < noiseTol ) Then areaArray(i,j) = gr
			addRoughness()
		NextIJ
		ForIJ(hs,this.w-1,0,hs)
			freqs(0,0) = 5 : freqs(0,1) = 1.0 - (Distance(i,j,hs,hs) / (fs*sqr2)) + rndvar
			freqs(1,0) = 8 : freqs(1,1) = (Abs(j-hs) / fs) + rndvar
			freqs(2,0) = 6 : freqs(2,1) = (Abs(i-hs) / fs) + rndvar
			freqs(3,0) = 9 : freqs(3,1) = (Distance(i,j,hs,hs) / (fs*sqr2)) + rndvar
			areaArray(i,j) = neighbors(CInt(freqs(GetHighest(freqs()),0)))
			If Str(areaArray(i,j).tex1) <> Str(gr.tex1) AndAlso ( Rnd < .300 OrElse Perlin(i,j,1024,1024,noiseSize,8) < noiseTol ) Then areaArray(i,j) = gr
			addRoughness()
		NextIJ
		ForIJ(0,hs,hs,this.h-1)
			freqs(0,0) = 5 : freqs(0,1) = 1.0 - (Distance(i,j,hs,hs) / (fs*sqr2)) + rndvar
			freqs(1,0) = 2 : freqs(1,1) = (Abs(j-hs) / fs) + rndvar
			freqs(2,0) = 4 : freqs(2,1) = (Abs(i-hs) / fs) + rndvar
			freqs(3,0) = 1 : freqs(3,1) = (Distance(i,j,hs,hs) / (fs*sqr2)) + rndvar
			areaArray(i,j) = neighbors(CInt(freqs(GetHighest(freqs()),0)))
			If Str(areaArray(i,j).tex1) <> Str(gr.tex1) AndAlso ( Rnd < .333 OrElse Perlin(i,j,1024,1024,noiseSize,8) < noiseTol ) Then areaArray(i,j) = gr
			addRoughness()
		NextIJ
		ForIJ(hs,this.w-1,hs,this.h-1)
			freqs(0,0) = 5 : freqs(0,1) = 1.0 - (Distance(i,j,hs,hs) / (fs*sqr2)) + rndvar
			freqs(1,0) = 2 : freqs(1,1) = (Abs(j-hs) / fs) + rndvar
			freqs(2,0) = 6 : freqs(2,1) = (Abs(i-hs) / fs) + rndvar
			freqs(3,0) = 3 : freqs(3,1) = (Distance(i,j,hs,hs) / (fs*sqr2)) + rndvar
			areaArray(i,j) = neighbors(CInt(freqs(GetHighest(freqs()),0)))
			If Str(areaArray(i,j).tex1) <> Str(gr.tex1) AndAlso ( Rnd < .333 OrElse Perlin(i,j,1024,1024,noiseSize,8) < noiseTol ) Then areaArray(i,j) = gr
			addRoughness()
		NextIJ
		ForIJ(0,this.w-1,0,this.h-1)
			AddVariance(areaArray(i,j),35)
			If areaArray(i,j).tex1.desc = "water" Then areaArray(i,j).flags Or= BLOCKS_MOVEMENT
		NextIJ
    End Constructor
	Function SurfaceArea.Modify(x As Integer, y As Integer, newTile As ASCIITile) As Byte
		If (this.areaArray(x,y).flags And BLOCKS_MOVEMENT) = BLOCKS_MOVEMENT Then Return 0
		this.areaArray(x,y) = newTile
		Return -1
	End Function

Const SPECIALAREAMAXSIZE = 128
Type SpecialArea
	seed As Double
    x As Integer
    y As Integer
    w As Integer = SPECIALAREAMAXSIZE
    h As Integer = SPECIALAREAMAXSIZE
    areaChar As UByte
    r As UByte
    g As UByte
    b As UByte
    areaArray(SPECIALAREAMAXSIZE,SPECIALAREAMAXSIZE) As ASCIITile 
    Declare Constructor()
    Declare Constructor(x As Integer, y As Integer, seed As Double = -1)
    Declare Function Modify(x As Integer, y As Integer, newTile As ASCIITile) As Byte
End Type
    Constructor SpecialArea()
    End Constructor 


Type star
    x As Single
    y As Single
End type
Const NUMHUB   = 5000    ' Number of stars in the core (Example: 2000)
Const NUMDISK  = 10000   ' Number of stars in the disk (Example: 4000)
Const DISKRAD  = 20000.0 ' Radius of the disk (Example: 90.0)
Const HUBRAD   = 10000.0 ' Radius of the hub (Example: 45.0)
Const NUMARMS  = 2       ' Number of arms (Example: 3)
Const ARMROTS  = 1.0'0.45    ' Tightness of winding (Example: 0.5)
Const ARMWIDTH = 60'15.0    ' Arm width in degrees (Not affected by number of arms or rotations)
Const FUZZ     = 40'25.0    ' Maximum outlier distance from arms (Example: 25.0)

Const GALAXYSIZE = 80
Type Galaxy
    seed As Double
    size As Integer = GALAXYSIZE
    gmap(GALAXYSIZE,GALAXYSIZE) As UByte
    Declare Constructor()
    Declare Constructor(seed As Double)
End Type
    Constructor Galaxy()
    End Constructor 
    Constructor Galaxy(seed As Double = -1)
        If seed <> -1 Then this.seed = seed: Randomize seed
        Dim As Single omega, theta, dist, scale
        Dim As Integer i,sx,sy
        Dim stars(NUMHUB + NUMDISK) As star
        omega = 360.0 / NUMARMS ' omega is the separation (in degrees) between each arm
        For i = 1 To NUMDISK
            ' Choose a random distance from center
            dist = HUBRAD + Rnd * DISKRAD
            ' This is the 'clever' bit, that puts a star at a given distance
            ' into an arm: First, it wraps the star round by the number of
            ' rotations specified.  By multiplying the distance by the number of
            ' rotations the rotation is proportional to the distance from the
            ' center, to give curvature
            theta = ( ( 360.0 * ARMROTS * ( dist / DISKRAD ) ) _
                    + rnd * ARMWIDTH _            'move the point further around by a random factor up to ARMWIDTH
                    + (omega * (Int(rnd * NUMARMS)+1) ) _  'multiply the angle by a factor of omega, putting the point into one of the arms
                    + rnd * FUZZ * 2.0 - FUZZ )   'add a further random factor, 'fuzzin' the edge of the arms
            ' Convert to cartesian
            stars(i).x = cos(theta * DegToRad) * dist
            stars(i).y = sin(theta * DegToRad) * dist
        Next i
        For i = NUMDISK+1 To NUMDISK+NUMHUB
            dist = rnd * HUBRAD
            theta = rnd * 360
            stars(i).x = Cos(theta * DegToRad) * dist
            stars(i).y = Sin(theta * DegToRad) * dist
        Next i
    
        ' Find maximal star distance
        Dim As Single maxim = 0
        For i = 1 To NUMHUB+NUMDISK
            If Abs(stars(i).x) > maxim then maxim = stars(i).x
            If Abs(stars(i).y) > maxim then maxim = stars(i).y
        Next i
        
        ' Calculate zoom factor to fit the galaxy to the PNG size
        Dim s As Single = GALAXYSIZE'dimLen(this.gmap,1)
        Dim As Single factor = s / (maxim * 2) 
        For i = 1 To NUMHUB+NUMDISK
            sx = Int(factor * stars(i).x) + s / 2.0
            sy = Int(factor * stars(i).y) + s / 2.0
            this.gmap(sx,sy) = min(255, this.gmap(sx,sy)+1) 
        Next i  
    End Constructor

Type GameLogic
    viewLevel As Byte
    viewLevelChanged As Byte = 0
    boundW(6) As Integer
    boundH(6) As Integer
    curGalaxy  As Galaxy
    curStarmap As Starmap
    curSystem  As SolarSystem
    curPlanet  As SystemObject
    curArea    As SurfaceArea
    curSpecial As SpecialArea
    Declare Sub updateBounds(all As Byte = 0)
    Declare Function getAreaID() As String
    Declare Function getAreaCoordStamp() As String
End Type
    Sub GameLogic.updateBounds(all As Byte = 0)
        Dim i As Byte = this.viewLevel
        If all <> 0 Then i = 0
        Do
            Select Case i
                Case zGalaxy
                    boundW(zGalaxy) = GALAXYSIZE
                    boundH(zGalaxy) = GALAXYSIZE
                Case zStarmap
                    boundW(zStarmap) = this.curStarmap.size
                    boundH(zStarmap) = this.curStarmap.size
                Case zSystem
                    boundW(zSystem) = this.curSystem.size
                    boundH(zSystem) = this.curSystem.size
                Case zOrbit
                    boundW(zOrbit) = ORBITSIZE
                    boundH(zOrbit) = ORBITSIZE
				Case zPlanet
                    boundW(zPlanet) = this.curPlanet.w
                    boundH(zPlanet) = this.curPlanet.h
                Case zDetail
                    boundW(zDetail) = this.curArea.w
                    boundH(zDetail) = this.curArea.h
            	Case zSpecial
                    boundW(zSpecial) = this.curSpecial.w
                    boundH(zSpecial) = this.curSpecial.h
            End Select
            If all <> 0 Then i+=1 Else Exit Do
        Loop Until i >= 6
    End Sub
    Function GameLogic.getAreaID() As String
        Select Case this.viewLevel
            Case zGalaxy
                Return "0"
            Case zStarmap
                Return Hex(this.curStarmap.seed)
            Case zSystem
                Return Hex(this.curStarmap.seed) & Hex(this.curSystem.seed)
        	Case zOrbit
        		Return Hex(this.curStarmap.seed) & Hex(this.curSystem.seed) & Hex(this.curPlanet.seed) & "O"
            Case zPlanet
                Return Hex(this.curStarmap.seed) & Hex(this.curSystem.seed) & Hex(this.curPlanet.seed) & "P"
            Case zDetail
                Return Hex(this.curStarmap.seed) & Hex(this.curSystem.seed) & Hex(this.curPlanet.seed) & Hex(this.curArea.seed)
        	Case zSpecial
        		Return "SPCL"+Hex(this.curSpecial.seed)
        End Select
    End Function
    Function GameLogic.getAreaCoordStamp() As String
        Select Case this.viewLevel
            Case zSystem
                Return this.curSystem.x & "," & this.curSystem.y
        	Case zOrbit
        		Return this.curSystem.x & "," & this.curSystem.y & "#" & this.curPlanet.x & "," & this.curPlanet.y
            Case zPlanet
                Return this.curSystem.x & "," & this.curSystem.y & "#" & this.curPlanet.x & "," & this.curPlanet.y & "#" & "-1,-1"
            Case zDetail
                Return this.curSystem.x & "," & this.curSystem.y & "#" & this.curPlanet.x & "," & this.curPlanet.y & "#" & "-1,-1" & "#" & this.curArea.x & "," & this.curArea.y
        	Case zSpecial
        		Return "0"
        End Select
        Return ""
    End Function    
