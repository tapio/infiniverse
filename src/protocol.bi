'' FILE: protocol.bi

Const ticksecs = 1.0

Enum actions
	message     = &b00100000
	updatePos   = &b01000000
	changeArea  = &b01100000
	areaStatus  = &b10000000
	modifyArea  = &b10100000
	serverQuery = &b11000000
	login		= &b11100000
	register    = &b11110000
End Enum

Enum queries
	ping        = &b00000001
	playerCount = &b00000010
	areaInfo    = &b00000011
	timeSync    = &b00000100
	clientWait	= &b00000101
	adminOp		= &b00000111
End Enum


Enum cflags
	admin		= &b10000000
End Enum

Enum tile_flags
	BLOCKS_MOVEMENT = &b00000001
End Enum

Enum viewLevels
    'zUniverse
    zGalaxy
    zStarmap
    zSystem
    zOrbit
    zPlanet
    zDetail
    zSpecial
End Enum



#Define actionMask &b11100000
#Define viewLvlMask &b00000111
#Define success &b00001000
#Define SEP Chr(1)
#Define detCoordOffSet 32


Type ASCIITexture
	'Union
	r As UByte = 0
	g As UByte = 0
	b As UByte = 0
	'	col As UInteger
	'	chan As RGBA_Color
	'End Union
	char As UByte = 0
	descid As UByte = 0
	desc As String 'ZString * 8
	Declare Constructor()
	Declare Constructor(_char As UByte=0, _r As UByte=0, _g As UByte=0, _b As UByte=0, _desc As String="")
	Declare Operator Cast () As String
	'Declare Property desc(_desc As String)
	'Declare Property desc() As String
	Declare Sub DrawTexture(x As Integer, y As Integer)
End Type
	Constructor ASCIITexture()
	End Constructor
    Constructor ASCIITexture(_char As UByte=0, _r As UByte=0, _g As UByte=0, _b As UByte=0, _desc As String="")
        this.r = _r
        this.g = _g
        this.b = _b
        this.char = _char
        this.desc = _desc
        'If _desc <> "" Then
			'this.desc = CUByte(_desc)
		'EndIf
    End Constructor
    Operator ASCIITexture.Cast() As String
    	Return char & r & g & b
    End Operator
    Sub ASCIITexture.DrawTexture(x As Integer, y As Integer)
        Draw String (x,y), Chr(this.char), RGB(this.r,this.g,this.b)
    End Sub
'	Property ASCIITexture.desc(_desc As String)
'	
'	End Property
'	Property ASCIITexture.desc() As String
'		Return ""
'	End Property


Type Building
	tex As ASCIITexture
	desc As String
	flags As UByte
	Declare Constructor(char As String, r As UByte, g As UByte, b As UByte, desc As String = "", flags As UByte = 0)
End Type
	Constructor Building(char As String, r As UByte, g As UByte, b As UByte, desc As String = "", flags As UByte = 0)
		this.tex = ASCIITexture(Asc(char),r,g,b,desc)
		this.desc = desc
		this.flags = flags
	End Constructor

Const BuildingCount As Short = 6
Dim Shared Buildings(1 To BuildingCount) As Building = {	Building("#",128,128,128,"wall",BLOCKS_MOVEMENT), _
															Building("+",220,  0,  0,"door"), _
															Building(".",120, 60,  0,"floor"), _
															Building("A",160,160,160,"extractor",BLOCKS_MOVEMENT), _
															Building("b",250,  0,250,"beacon",BLOCKS_MOVEMENT), _
															Building(".",  0, 255,  0,"lawn") _
														}
