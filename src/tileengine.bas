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



Sub DrawView(cache As TileCache, x As Integer, y As Integer, viewScreenX As Integer, viewScreenY As Integer, viewXDist As Integer, viewYDist As Integer)
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
