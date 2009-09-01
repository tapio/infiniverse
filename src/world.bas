

Sub AddVariance(ByRef tile As ASCIITile, variance As Short)
	Dim As Short r,g,b, rndvar
	If tile.tex1.char <> 0 Then
		rndvar = Rand(-variance,variance)
		r = tile.tex1.r + rndvar
		g = tile.tex1.g + rndvar
		b = tile.tex1.b + rndvar
		tile.tex1.r = rgb_limit(r)
		tile.tex1.g = rgb_limit(g)
		tile.tex1.b = rgb_limit(b)
	EndIf
	If tile.tex2.char <> 0 Then
		rndvar = Rand(-variance,variance)
		r = tile.tex2.r + rndvar
		g = tile.tex2.g + rndvar
		b = tile.tex2.b + rndvar
		tile.tex2.r = rgb_limit(r)
		tile.tex2.g = rgb_limit(g)
		tile.tex2.b = rgb_limit(b)
	Endif
End Sub

Function AddVarianceToColor(col As UInteger, variance As Short) As UInteger
	Dim As Short r = rgb_r(col), g = rgb_g(col), b = rgb_b(col), rndvar = Rand(-variance,variance)
	r += rndvar : g += rndvar : b += rndvar
	Return RGB(rgb_limit(r),rgb_limit(g),rgb_limit(b))
End Function

Function Anim_Flicker(tile As ASCIITile, x As Integer, y As Integer) As ASCIITile
	Dim As Short r,g,b, rndvar
	If tile.tex2.char <> 0 Then
		rndvar = Rand(-15,15)
		r = tile.tex2.r + rndvar
		g = tile.tex2.g + rndvar
		b = tile.tex2.b + rndvar
		tile.tex2.r = rgb_limit(r)
		tile.tex2.g = rgb_limit(g)
		tile.tex2.b = rgb_limit(b)
	EndIf
	Return tile
End Function

Function Anim_Water(tile As ASCIITile, x As Integer, y As Integer) As ASCIITile
	Static water_frame As Integer = 0
	Static water_timer As Double = 0
	#Define repsize 64
	If Timer > water_timer+0.100 Then water_frame = (water_frame + 1) Mod 32: water_timer = Timer' Else Return tile
	'tile.tex1.b = rgb_limit(16 * Sin( DegToRad*(Perlin(x,y,repsize,repsize,16,5)+water_frame) ) + 128)
	'tile.tex1.b = wrap(Perlin(x,y,repsize,repsize,16,5) + water_frame - 16, 255)
	tile.tex1.b = Perlin(x+water_frame,y+water_frame,repsize,repsize,16,5)
	Return tile
End Function


Function Anim_RotatePlanet(tile As ASCIITile, x As Integer, y As Integer) As ASCIITile
	Dim As Integer radius = game.curPlanet.h / ORBITFACTOR
	Dim As Integer c = ORBITSIZE*.5
	'AddLog(Str(radius)+"trying: "+Str((x -c+radius) Mod radius) +" ;;;; "+Str((y -c+radius) Mod radius))
	x = x - c + radius
	x = (x + (GetTime() Mod (radius*2))) Mod (radius*2)
	y = (y - c + radius) Mod radius
	Return planetorbitmap(x,y)
End Function

Sub GenerateTextures(seed As Double = -1)
    Dim As UByte r,g,b
    If seed <> -1 Then Randomize seed
    textures(water)         = ASCIITexture(247, Rnd*64, Rnd*128, 100+Rnd*155, "water")
    textures(lava)          = ASCIITexture(Asc("~"), 128+Rnd*128, Rnd*256, 0, "lava")
    textures(ground_cold)   = ASCIITexture(Asc("."), 200+Rnd*55, 200+Rnd*55, 200+Rnd*55, "snow")
    textures(ground_cold2)  = ASCIITexture(Asc(","), 200+Rnd*55, 200+Rnd*55, 200+Rnd*55, "ice")
    textures(ground_cold3)  = ASCIITexture(Asc("o"), 200+Rnd*55, 200+Rnd*55, 200+Rnd*55, "rock")
    Do : r = Rnd*256: g = Rnd*256: b = Rnd*256 : Loop While (r+g+b)>384
    textures(ground_base)   = ASCIITexture(Asc("."), r,g,b, "ground")
    textures(ground_base2)  = ASCIITexture(Asc(","), r,g,b, "ground")
    textures(ground_base3)  = ASCIITexture(Asc("o"), r,g,b, "rock")
    textures(hill)          = ASCIITexture(30, r,g,b, "hill")
    textures(mountain_low)  = ASCIITexture(30, (textures(ground_cold).r+r)/2,(textures(ground_cold).g+g)/2,(textures(ground_cold).b+b)/2, "low mountain")
    textures(mountain_high) = ASCIITexture(30, textures(ground_cold).r, textures(ground_cold).g, textures(ground_cold).b, "high mountain")
    Do : r = Rnd*256: g = Rnd*256: b = Rnd*256 : Loop While (r+g+b)>384 AndAlso b>r AndAlso b>g
    textures(ground_warm)   = ASCIITexture(Asc("."), r,g,b, "desert")
    textures(ground_warm2)  = ASCIITexture(Asc(","), r,g,b, "desert")
    textures(ground_warm2)  = ASCIITexture(Asc("o"), r,g,b, "rock")
    
    textures(vegetation_cold)       = ASCIITexture( vegChars(Int(Rnd*numVegChars)), Rnd*256,Rnd*256,Rnd*256, "tundra-like vegetation")
    textures(vegetation_base)       = ASCIITexture( vegChars(Int(Rnd*numVegChars)), Rnd*256,Rnd*256,Rnd*256, "forest-like vegetation")
    textures(vegetation_base_humid) = ASCIITexture( vegChars(Int(Rnd*numVegChars)), Rnd*256,Rnd*256,Rnd*256, "swamp-like vegetation")
    textures(vegetation_warm)       = ASCIITexture( vegChars(Int(Rnd*numVegChars)), Rnd*256,Rnd*256,Rnd*256, "savanna-like vegetation")
    textures(vegetation_warm_humid) = ASCIITexture( vegChars(Int(Rnd*numVegChars)), Rnd*256,Rnd*256,Rnd*256, "jungle-like vegetation")
End Sub

Sub GenerateDistantStarBG(array() As UByte)
	For j As Integer = iterArray(array,2)
		For i As Integer = iterArray(array,1)
			If Rnd >.99 Then array(i,j) = 20+Rnd*200
		Next i
	Next j
End Sub

Function GetAreaTile(x As Integer, y As Integer) As ASCIITile
	If in2DArray(game.curArea.areaArray,x,y) Then Return game.curArea.areaArray(x,y) Else Return 0
	/'
	Dim As Integer worldW = game.curArea.w, worldH = game.curArea.h
	'Dim As ASCIITile texW, texN, texE, texS, texC
	Dim As Single xcoef = x/CSng(worldW), ycoef = y/CSng(worldH)
	Dim As UByte height,vegetation,temperature,rainfall
	Dim As SurfaceArea a = game.curArea
	'Dim As Single valC,valN,valE,valS,valW
	Dim As Single a00,a10,a01,a11
	
	#Define P(xplus,yplus,noiselvl,noiseid) Perlin(a.x+xplus,a.y+yplus,game.curPlanet.w,game.curPlanet.h,noiselvl,noiseid)
	#Macro Interpolate(v,noiselvl,noiseid)
	    a00 = P(0,0,noiselvl,noiseid) * (1.0-xcoef)*(1.0-ycoef)
	    a10 = P(1,0,noiselvl,noiseid) * xcoef*(1.0-ycoef)
	    a01 = P(0,1,noiselvl,noiseid) * (1.0-xcoef)*ycoef
	    a11 = P(1,1,noiselvl,noiseid) * xcoef*ycoef
	    v = ( a00 + a10 + a01 + a11 )
'hTop = hNW + (hN - hNW) * (0.5 + x)
'hBottom = hW + (h - hW) * (0.5 + x)
'h(x,y) = hTop + (hBottom - hTop) * (0.5 + y)
	#EndMacro
	'Interpolate(height,16,1)
	'Interpolate(vegetation,16,2)
	'Interpolate(rainfall,32,3)
	height      = Clip( P(xcoef,ycoef,16,1) + (P(xcoef,ycoef,2,4)-128.0)/8, 0,255)
	vegetation  = Clip( P(xcoef,ycoef,16,2) + (P(xcoef,ycoef,2,4)-128.0)/8, 0,255)
	rainfall    = Clip( P(xcoef,ycoef,32,3) + (P(xcoef,ycoef,2,4)-128.0)/8, 0,255)
	temperature = ( (255-(Abs(game.curPlanet.h/2-a.y)*2 / CDbl(game.curPlanet.h) * 255.0))*4 + (255-height) + Perlin(a.x,a.y,game.curPlanet.w,game.curPlanet.h,8,4)) / 6.0
	Return GetGroundTexture(height,temperature,rainfall,vegetation)
	'Dim As Short fuzzy1 = Perlin(x,y,worldW,worldH,4,1)-128
	'Dim As Short fuzzy2 = Perlin(x,y,worldW,worldH,4,2)-128
	'texW = GetGroundTile(game.curArea.x-1, game.curArea.y  )
	'texN = GetGroundTile(game.curArea.x  , game.curArea.y-1)
	'texE = GetGroundTile(game.curArea.x+1, game.curArea.y  )
	'texS = GetGroundTile(game.curArea.x  , game.curArea.y+1)
	'texC = GetGroundTile(game.curArea.x  , game.curArea.y  )
	'xcoef = x-worldW/2 + fuzzy1
	'ycoef = y-worldH/2 + fuzzy2
	'If Between(xcoef,-worldW/4,worldW/4) And Between(ycoef,-worldH/4,worldH/4) Then Return texC
	'If ycoef < -worldH/4 And ycoef < -Abs(xcoef) Then Return texN
	'If ycoef >  worldH/4 And ycoef >  Abs(xcoef) Then Return texS
	'If xcoef < -worldW/4 Then Return texW
	'If xcoef >  worldW/4 Then Return texE
	'Return texC
    'Return ASCIITile(ASCIITexture(game.curArea.areaChar, 128,128,128),0)
    '/
End Function


Function GetGroundTile(x As Integer, y As Integer) As ASCIITile
    If game.curPlanet.objType = pGas Then Return GetGasGiantTile(x,y)
    Dim As Integer worldW = game.curPlanet.w, worldH = game.curPlanet.h
    x = wrap(x,worldW)
    y = wrap(y,worldH)
    Dim As UByte height      = Perlin(x,y,worldW,worldH,16,1)
    Dim As UByte vegetation  = 0
    Dim As UByte rainfall    = 0
    Dim As UByte temperature = ( (255-(Abs(worldH/2-y)*2 / CDbl(worldH) * 255.0))*4 + (255-height) + Perlin(x,y,worldW,worldH,8,4)) / 6.0
    
    '#Define turb (-(Perlin(x,y,worldW,worldH,2,5) Mod 2 = 0))
    #Define turb 0
    If game.curPlanet.objType = pGaia Then vegetation = Perlin(x,y,worldW,worldH,16,2): rainfall = Perlin(x,y,worldW,worldH,32,3)
    Dim As ASCIITile retTile = GetGroundTexture(height,temperature,rainfall,vegetation,turb)
    AddVariance (retTile, 25)
    
	'Dim As UInteger col = AddVarianceToColor(RGB(retTile.tex1.r,retTile.tex1.g,retTile.tex1.b),5)
    'Dim As ASCIITexture bgtex = ASCIITexture(219, rgb_r(col), rgb_g(col), rgb_b(col))
    'retTile.tex2 = bgtex
    
    Return retTile
End Function

Function GetPureGround(x As Integer, y As Integer) As ASCIITile
    Dim As Integer worldW = game.curPlanet.w, worldH = game.curPlanet.h
    x = wrap(x,worldW)
    y = wrap(y,worldH)
    Dim As UByte height      = 130 '' over water, under mountains
    Dim As UByte rainfall    = 0
    Dim As UByte temperature = ( (255-(Abs(worldH/2-y)*2 / CDbl(worldH) * 255.0))*4 + (255-height) + Perlin(x,y,worldW,worldH,8,4)) / 6.0
    If game.curPlanet.objType = pGaia Then rainfall = Perlin(x,y,worldW,worldH,32,3)
    Return GetGroundTexture(height,temperature,rainfall,0,0)
End Function

Function GetGroundTexture(height As UByte, temperature As UByte, rainfall As UByte, vegetation As UByte, turb As UByte = 0)  As ASCIITile  
    '#Define bgt ASCIITexture(177, height,height,height)
    Dim As ASCIITexture bgt
    If height > 160 Then 
		Dim As UByte r1 = textures(hill).r, g1 = textures(hill).g, b1 = textures(hill).b
		Dim As UByte r2 = textures(mountain_high).r, g2 = textures(mountain_high).g, b2 = textures(mountain_high).b
		Dim As Single f = 1.0-((Clip(height+50.0,0,255)-160.0)/95.0) '((height-160.0)/95.0)
    	'Dim As ASCIITexture mountBG = textures(ground_base)
    	'If height > 200 Then mountBG = textures(ground_cold)
    	Dim desc As String = "hill"
    	If height > 190 Then desc = "low mountains"
    	If height > 215 Then desc = "high mountains"
    	Return ASCIITile(ASCIITexture(30, blend(r1,r2,f),blend(g1,g2,f),blend(b1,b2,f),desc))',mountBG)
    EndIf 
    'If height + Clip(255-Int(temperature)-100,0,255)/5.0 > 200 Then Return ASCIITile(textures(mountain_high),bgt)
    'If height > 180 Then Return ASCIITile(textures(mountain_low),bgt)
    'If height > 160 Then Return ASCIITile(textures(hill),bgt)
    If height < 120 And between(temperature,40,180) And rainfall > 50 Then Return ASCIITile(textures(water), ASCIITexture(0,0,0,150)       ) ',, @Anim_water)
    If temperature > 180 And rainfall < 100 Then Return ASCIITile(textures(ground_warm + turb),bgt)
    
    If vegetation > 128 Then
        If temperature > 150 And rainfall > 150            Then Return ASCIITile(textures(vegetation_warm_humid))
        If between(temperature,128,161) And rainfall > 150 Then Return ASCIITile(textures(vegetation_base_humid))
        If between(temperature,60,161)  And rainfall > 40  Then Return ASCIITile(textures(vegetation_base))
        If between(temperature,20,80)   And rainfall > 40  Then Return ASCIITile(textures(vegetation_cold))
        If between(temperature,161,200) And between(rainfall,40,80) Then Return ASCIITile(textures(vegetation_warm))
    EndIf
    If temperature < 80 Then Return ASCIITile(textures(ground_cold + turb),bgt)
    Return ASCIITile(textures(ground_base + turb),bgt)
    
End Function

Function GetGasGiantTile(x As Integer, y As Integer) As ASCIITile
    Dim As UByte r=0,g=0,b=0,char=0
    Dim As Integer worldW = game.curStarmap.size, worldH = game.curStarmap.size
    x = wrap(x,worldW)
    y = wrap(y,worldH)
    char = 176'219
    #Define PR Perlin(x,y,worldW,worldH,128,1)
    #Define PG Perlin(x,y,worldW,worldH,128,2)
    #Define PB Perlin(x,y,worldW,worldH,128,3)
    Select Case game.curPlanet.flags
    	Case 1: r = PR: g = PG
    	Case 2: r = PR: b = PB
    	Case 3: g = PG: b = PB
    	Case 4: r = PR: g = PR: b = PB
    	Case 5: r = PR: g = PG: b = PR
    	Case 6: r = PR: g = PG: b = PG
    End Select
    Return ASCIITile(ASCIITexture(char, r,g,b),0)	
End Function

Function GetOrbitTile(x As Integer, y As Integer) As ASCIITile
	Dim As Integer radius = game.curPlanet.h*.5 / ORBITFACTOR
	Dim As Integer c = ORBITSIZE*.5
	Dim As UByte r = 200, g = 0, b = 50 
	If Distance(x,y,c,c) <= radius Then
		'AddLog(Str(radius)+"trying: "+Str((x -c+radius) Mod radius) +" ;;;; "+Str((y -c+radius) Mod radius))
		x = x - c + radius
		x = (x + (GetTime() Mod (radius*2))) Mod (radius*2)
		'y = y - c + radius
		y = (y - c + radius) Mod radius
		Return planetorbitmap(x,y)
		'Dim As Integer cor = -c+cor
		'Var til = GetGroundTile((cor+x)*ORBITFACTOR, (cor+y)*ORBITFACTOR)
		'r = til.tex1.r : g = til.tex1.g : b = til.tex1.b
		'Return ASCIITile(ASCIITexture(176, r,g,b, "planet"), 0)
	EndIf
    Dim As UByte star = Perlin(x,y,ORBITSIZE,ORBITSIZE,4,3)
    Dim As UByte starC = star / 2 + 128
    If star Mod 10 = 0 Then Return ASCIITexture(Asc("."), starC,starC,starC, "distant star")
    Return ASCIITexture(0, 0,0,0,"emptiness")
End Function

Function GetSolarTile(x As Integer, y As Integer) As ASCIITile
    Dim As Integer i, dst = 0, dst2 = 0, col = 0, mask = 0, temp=0, center = game.curSystem.size/2
    Dim As UByte r,g,b
    Dim As Double mask2
    Dim As Integer worldW = game.curSystem.size, worldH = game.curSystem.size
    x = wrap(x,worldW)
    y = wrap(y,worldH)
    Var bg = SystemStarBG(x,y)
    Dim animFunc As Any Ptr = 0
    
    'planets
    For i = game.curSystem.starCount To game.curSystem.starCount + game.curSystem.planetCount-1
        If x = game.curSystem.objects(i).x And y = game.curSystem.objects(i).y Then
        	r = rgb_r(game.curSystem.objects(i).col)
        	g = rgb_g(game.curSystem.objects(i).col)
        	b = rgb_b(game.curSystem.objects(i).col)
            Return ASCIITile(ASCIITexture(Asc("O"), r,g,b, table_SystemObjectNames(game.curSystem.objects(i).objType)),0)
        EndIf
    Next i

    'suns
    Dim sun As SystemObject
    Dim As UByte sunR,sunG,sunB
    For i = 0 To game.curSystem.starCount-1
        sun = game.curSystem.objects(i)
        dst = Sqr((x-sun.x)*(x-sun.x) + (y-sun.y)*(y-sun.y))
        If dst < sun.size Then
            dst2 = CDbl(dst) / sun.size * 256.0
            mask = 256-dst2'ExpFilter(dst2, 0, .99)
            temp = (Perlin(x,y,worldW,worldH,2,2) - 128.0) / 8.0
            mask = Max( Min(mask+temp, 255), 0 )
            mask2 = mask / 256.0
            If mask2 > 1.0 Then mask2 = 1.0
            sunR = rgb_r(sun.col)
            sunG = rgb_g(sun.col)
            sunB = rgb_b(sun.col)
            bg = ASCIITexture(0, 0,0,0, "sun")
            animFunc = @Anim_Flicker
            Exit For
        EndIf
    Next i
    
    'nebula
    Dim As Integer neb = Perlin(x,y,worldW,worldH,32,1)
    neb = ExpFilter(neb,200,.99)
    r = blendMul(rgb_r(game.curSystem.nebulaColor),neb)
    g = blendMul(rgb_g(game.curSystem.nebulaColor),neb)
    b = blendMul(rgb_b(game.curSystem.nebulaColor),neb)
    
    'mask2 = neb / 256.0
    'If mask2 > 1.0 Then mask2 = 1.0

    'blending
    mask = min(mask*2.0, 255)
    r = blend( sunR, r, mask/255.0)
    g = blend( sunG, g, mask/255.0)
    b = blend( sunB, b, mask/255.0)
    'r = blend( sunR, r*mask2, mask/255.0)
    'g = blend( sunG, g*mask2, mask/255.0)
    'b = blend( sunB, b*mask2, mask/255.0)
	
    Return ASCIITile(bg,ASCIITexture(219, r,g,b),,animFunc)
    'Return ASCIITexture(219, r*mask2,g*mask2,b*mask2)
End Function

Function SystemStarBG(x As Integer, y As Integer) As ASCIITexture
    Dim As Integer dst = 0, center = game.curSystem.size/2
    Dim As Integer worldW = game.curSystem.size, worldH = game.curSystem.size
    x = wrap(x,worldW)
    y = wrap(y,worldH) 
    Dim As UByte star = Perlin(x,y,worldW,worldH,4,3)
    Dim As UByte starC = star / 2 + 128
    If star Mod 10 = 0 Then Return ASCIITexture(Asc("."), starC,starC,starC, "distant star")
'    star = farStarBG(x,y)
'	If star > 0 Then Return ASCIITexture(Asc("."), star,star,star, "distant star")
    Return ASCIITexture(0, 0,0,0,"emptiness")
End function


Function GetStarmapTile(x As Integer, y As Integer) As ASCIITile
    Dim As UByte r=0,g=0,b=0,char=0, mask=0
    Dim As Integer worldW = game.curStarmap.size, worldH = game.curStarmap.size
    x = wrap(x,worldW)
    y = wrap(y,worldH)

    char = 219
'worldW = 256: worldH = 256
    mask = Perlin(x,y,worldW,worldH,32,4)
    mask = ExpFilter(mask,100,.99)
    r = blendMul(Perlin(x,y,worldW,worldH,64,1),mask)
    g = blendMul(Perlin(x,y,worldW,worldH,64,2),mask)
    b = blendMul(Perlin(x,y,worldW,worldH,64,3),mask)

    Return ASCIITile(StarmapHasStar(x,y),ASCIITexture(char, r,g,b))
End Function


Function StarmapHasStar(x As Integer, y As Integer) As ASCIITexture
    Dim As Integer worldW = game.curStarmap.size, worldH = game.curStarmap.size
    x = wrap(x,worldW)
    y = wrap(y,worldH)
    If Perlin(x,y,worldW,worldH,4,5) Mod 10 = 0 Then
        Dim As UByte r=0,g=0,b=0,char=0
        Dim col As Integer = Perlin(x,y,worldW,worldH,4,6)
        If col < 180 Then
            char = 249
        ElseIf col < 200 Then
            char = Asc("*")
        Else
            char = 15'Asc("*")
        EndIf
        col += 50
        If col > 255 Then col = 255
        r = col: g = r: b = r
        Return ASCIITexture(char,r,g,b,"star")
    EndIf
    Return ASCIITexture(0,0,0,0,"emptiness")
End Function


Function GetGalaxyTile(x As Integer, y As Integer) As ASCIITile
    Dim As UByte col = 0
    col = Perlin(x,y,GALAXYSIZE,GALAXYSIZE,32,1)
    col = ExpFilter(col,200,.99) *.333
    If Not in2dArray(game.curGalaxy.gmap,x,y) OrElse game.curGalaxy.gmap(x,y) = 0 Then Return ASCIITile(ASCIITexture(0,0,0,0, "emptiness"), ASCIITexture(219, col,col,col))
    Dim As Integer star = Min( 100 + game.curGalaxy.gmap(x,y) * 20, 255)
    Dim As UByte char
        If star < 160 Then
            char = 249
        ElseIf star < 200 Then
            char = Asc("*")
        Else
            char = Asc("*")'15
        EndIf
    Return ASCIITile(ASCIITexture(char, star,star,star, "star"), ASCIITexture(219, col,col,col))
End Function
