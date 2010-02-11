
#Macro PrintStars()
	Print ".  . .   .    .       .    . . \|/ ."
	Print " .       +     ..    .   *     -o-  "
	Print "   * .     . .  . .     .  . . /|\ ."
	Print ". .     .    . * .   +     *    .   "
#EndMacro

#Macro formatUpdatePos(variable)
	tempx = CInt(pl.x) : tempy = CInt(pl.y)
	variable = Chr(actions.updatePos, game.viewLevel, 0,0,0,0,0,0,0,0) & my_name
	memcpy(StrPtr(variable)+2, @tempx, 4)
	memcpy(StrPtr(variable)+6, @tempy, 4)
#EndMacro

#Macro formatChangeArea(variable)
	tempx = CInt(pl.x) : tempy = CInt(pl.y)
	variable = String(10+NAME_MAX_LEN, Chr(0))
	variable[0] = actions.changeArea
	variable[1] = game.viewLevel
	'variable = Chr(actions.changeArea, game.viewLevel, 0,0,0,0,0,0,0,0) & my_name
	memcpy(StrPtr(variable)+2, @tempx, 4)
	memcpy(StrPtr(variable)+6, @tempy, 4)
	memcpy(StrPtr(variable)+10, StrPtr(my_name), NAME_MAX_LEN)
	variable += game.getAreaID
#EndMacro

#Macro drawCharToWorld(_x, _y, _c, _col)
	tempx = CInt(_x)-CInt(pl.x)
	tempy = CInt(_y)-CInt(pl.y)
	If Abs(tempx) < viewX AndAlso Abs(tempy) < viewY Then 
		Draw String (	viewStartX + 8*(viewX + (tempx)), _
						viewStartY + 8*(viewY + (tempy))), _
						_c, _col
	EndIf
#EndMacro

#Macro erasePlayer(_i)
	'players(_i) = players(numPlayers)
	'players(numPlayers).id = ""
	players(_i).id = ""
	'Delete players(_i)
	numPlayers-=1
	'If log_enabled Then AddLog(my_name & "Player " & temp & " erased.")	
#EndMacro


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


Sub TextLine(x1 As Integer, y1 As Integer, x2 As Integer, y2 As Integer, char As String = ".", col As UInteger = 0)
	If col = 0 Then col = LoWord(Color())
	Dim As Integer steep = Abs(y2 - y1) > Abs(x2 - x1)
	If steep Then
		Swap x1, y1
		Swap x2, y2
	EndIf
	If x1 > x2 Then
		Swap x1, x2
		Swap y1, y2
	EndIf
	Dim As Integer deltax = x2 - x1
	Dim As Integer deltay = Abs(y2 - y1)
	Dim As Integer erro = deltax / 2
	Dim As Integer ystep
	Dim As Integer y = y1
	If y1 < y2 Then ystep = 1 Else ystep = -1
	For x As Integer = x1 To x2
		If steep Then
			Draw String (y*8,x*8), char, col
		Else
			Draw String (x*8,y*8), char, col
		EndIf
		erro = erro - deltay
		If erro < 0 Then
			y = y + ystep
			erro = erro + deltax
		EndIf
	Next x
End Sub

