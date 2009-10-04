'Generic ASCII Tile Engine


'Dim Shared As Integer VIEWXDIST=10, VIEWYDIST=10, TEXTURESIZE=8


#Include Once "tiles.bi"


Sub UpdateCache(ByRef cache As TileCache, x As Integer, y As Integer, xdist As Integer = BUFFERXDIST, ydist As Integer = BUFFERYDIST, refreshAll As Byte = 0)
    Dim As Integer i,j
    Dim newCache As TileCache = TileCache(x,y)
    newCache.GetTexture  = cache.GetTexture
    'newCache.GetTexture2 = cache.GetTexture2
    Dim As Integer xdiff = x - cache.originX, ydiff = y - cache.originY
    For j = -YDIST To YDIST
        For i = -XDIST To XDIST
            If refreshAll = 0 AndAlso cache.isEmpty = 0 AndAlso i+xdiff >= -XDIST AndAlso i+xdiff <= XDIST AndAlso j+ydiff >= -YDIST AndAlso j+ydiff <= YDIST Then
				If cache.texBuffer(i+xdiff, j+ydiff).anim <> 0 Then
					'animate
					Var func = Cast(Function(As ASCIITile, As Integer, As Integer) As ASCIITile, cache.texBuffer(i+xdiff, j+ydiff).anim)
					newCache.texBuffer(i,j) = func(cache.GetTexture(i+x, j+y), i+x, j+y)
				Else
					'newCache.buffer(i,j)     = cache.buffer(i+xdiff, j+ydiff)
	                newCache.texBuffer(i,j)  = cache.texBuffer(i+xdiff, j+ydiff)
	                'newCache.texBuffer2(i,j) = cache.texBuffer2(i+xdiff, j+ydiff)				
				EndIf
            Else
                newCache.texBuffer(i,j)  = newCache.GetTexture(i+x, j+y)
                'If newCache.GetTexture2 <> 0 Then newCache.texBuffer2(i,j)  = newCache.GetTexture2(i+x, j+y)
            EndIf  
        Next
    Next
    cache = newCache
    cache.isEmpty = 0
End Sub


Sub DrawTrails(x As Integer, y As Integer, viewScreenX As Integer, viewScreenY As Integer, viewXDist As Integer, viewYDist As Integer)
	Dim As Integer i,j
	Var trailtex = ASCIITexture(249, 0, 0, 0)
	viewScreenX += TEXTURESIZE * VIEWXDIST
	viewScreenY += TEXTURESIZE * VIEWYDIST 
	Dim iter As Trail Ptr = trails.initIterator()
	While iter <> 0
		iter->fade -= 5
		trailtex.b = iter->fade
		If iter->fade <= 0 Then
			trails.remove(iter)
		Else
			If inBounds(iter->x,x-VIEWXDIST,x+VIEWXDIST) AndAlso _
			   inBounds(iter->y,y-VIEWYDIST,y+VIEWYDIST) AndAlso _
			   trailtex <> 0 Then _
			   trailtex.DrawTexture( viewStartX + 8*(viewX + (iter->x-x)), _
			   						 viewStartY + 8*(viewY + (iter->y-y)) )
		EndIf
		iter = trails.getNext()
	Wend
End Sub


Sub DrawView(ByRef cache As TileCache, x As Integer, y As Integer, viewScreenX As Integer, viewScreenY As Integer, viewXDist As Integer, viewYDist As Integer)
    Dim As Integer i,j
    Dim texId As UByte
    Dim As ASCIITexture tex1,tex2
    viewScreenX += TEXTURESIZE * VIEWXDIST
    viewScreenY += TEXTURESIZE * VIEWYDIST 
    For j = -VIEWYDIST To VIEWYDIST
        For i = -VIEWXDIST To VIEWXDIST
            cache.texBuffer(i,j).DrawTexture( viewScreenX + i * TEXTURESIZE, viewScreenY + j * TEXTURESIZE )
            
            'tex1 = cache.texBuffer(i,j)
            'If tex1.char <> 0 Then tex1.DrawTexture( viewScreenX + i * TEXTURESIZE, viewScreenY + j * TEXTURESIZE )
            'tex2 = cache.texBuffer2(i,j)
            'If tex2.char <> 0 Then tex2.DrawTexture( viewScreenX + i * TEXTURESIZE, viewScreenY + j * TEXTURESIZE )

            'texId = cache.buffer(i,j)
            'If texId > 0 Then Put ( viewScreenX + i * 8, viewScreenY + j * 8 ), textures(texId), Trans
        Next i
    Next j
End Sub

Sub RefreshTile(ByRef cache As TileCache, x As Integer, y As Integer, i As Integer = -1, j As Integer = -1)
	If i = -1 Then i = x
	If j = -1 Then j = y
	cache.texBuffer(i,j) = cache.GetTexture(x,y)
End Sub


Function CacheBlend_CircleInwards(_x As Integer, _y As Integer) As Single
	Return Sqr(_x*_x + _y*_y) / Sqr(BUFFERXDIST * BUFFERXDIST + BUFFERYDIST * BUFFERYDIST)
End Function

Function CacheBlend_CircleOutwards(_x As Integer, _y As Integer) As Single
	Return 1.0 - (Sqr(_x*_x + _y*_y) / Sqr(BUFFERXDIST * BUFFERXDIST + BUFFERYDIST * BUFFERYDIST))
End Function

Function CacheBlend_Fractal(_x As Integer, _y As Integer) As Single
	Return CSng(Perlin(_x+BUFFERXDIST,_y+BUFFERYDIST,BUFFERXDIST*2+1, BUFFERYDIST*2+1, 4, 8) / 255.0)
End Function

Function BlendTileCaches(ByRef cache1 As TileCache, ByRef cache2 As TileCache, factor As Single = 0.5, thres_func As Function(As Integer, As Integer) As Single = @CacheBlend_CircleInwards) As TileCache
	Dim As Integer i,j, r,g,b, char
	Dim cache As TileCache
	Dim As ASCIITexture tex1, tex2
	factor = clip(factor, 0.0, 1.0)
	'#Define threshold (.2 + Rnd*.6)
	'#Define threshold CSng(Perlin(i+BUFFERXDIST,j+BUFFERYDIST,BUFFERXDIST*2+1, BUFFERYDIST*2+1, 4, 1) / 255.0)
	'#Define threshold Distance(0,0,i,j) / Distance(0,0,BUFFERXDIST,BUFFERYDIST)
	#Define threshold thres_func(i,j)
	For j = -BUFFERYDIST To BUFFERYDIST
		For i = -BUFFERXDIST To BUFFERXDIST
			r = blend(cache1.texBuffer(i,j).tex1.r, cache2.texBuffer(i,j).tex1.r, factor)
			g = blend(cache1.texBuffer(i,j).tex1.g, cache2.texBuffer(i,j).tex1.g, factor)
			b = blend(cache1.texBuffer(i,j).tex1.b, cache2.texBuffer(i,j).tex1.b, factor)
			If factor > threshold Then char = cache1.texBuffer(i,j).tex1.char Else char = cache2.texBuffer(i,j).tex1.char
			tex1 = ASCIITexture(char,r,g,b)
			r = blend(cache1.texBuffer(i,j).tex2.r, cache2.texBuffer(i,j).tex2.r, factor)
			g = blend(cache1.texBuffer(i,j).tex2.g, cache2.texBuffer(i,j).tex2.g, factor)
			b = blend(cache1.texBuffer(i,j).tex2.b, cache2.texBuffer(i,j).tex2.b, factor)
			If factor > threshold Then char = cache1.texBuffer(i,j).tex2.char Else char = cache2.texBuffer(i,j).tex2.char
			tex2 = ASCIITexture(char,r,g,b)
			cache.texBuffer(i,j) = ASCIITile(tex1,tex2)
		Next i
	Next j
	Return cache
End Function
