'Types

Const BUFFERXDIST = viewX
Const BUFFERYDIST = viewY
Const TEXTURESIZE = 8

/'
Type ASCIITexture
    r As UByte = 0
    g As UByte = 0
    b As UByte = 0
    char As UByte = 0
    desc As String = ""
    Declare Constructor()
    Declare Constructor(char As UByte=0, r As UByte=0, g As UByte=0, b As UByte=0, desc As String = "")
    Declare Operator Cast () As String
    Declare Sub DrawTexture(x As Integer, y As Integer)
End Type
    Constructor ASCIITexture()
    End Constructor
    Constructor ASCIITexture(char As UByte=0, r As UByte=0, g As UByte=0, b As UByte=0, desc As String = "")
        this.r = r
        this.g = g
        this.b = b
        this.char = char
        this.desc = desc
    End Constructor
    Operator ASCIITexture.Cast() As String
    	Return char & r & g & b
    End Operator
    Sub ASCIITexture.DrawTexture(x As Integer, y As Integer)
        Draw String (x,y), Chr(this.char), RGB(this.r,this.g,this.b)
    End Sub

'/

Type ASCIITileFwd As ASCIITile

Type ASCIITile
    tex1 As ASCIITexture
    tex2 As ASCIITexture
    flags As UByte
    anim As Any Ptr = 0 'Function(x As Integer, y As Integer) As ASCIITileFwd Ptr' = 0
    Declare Constructor()
    Declare Constructor(tex1 As ASCIITexture = ASCIITexture(), tex2 As ASCIITexture = ASCIITexture(), flags As UByte = 0, anim As Any Ptr = 0)
    Declare Sub DrawTexture(x As Integer, y As Integer)
End Type
    Constructor ASCIITile()
    End Constructor
    Constructor ASCIITile(tex1 As ASCIITexture = ASCIITexture(), tex2 As ASCIITexture = ASCIITexture(), flags As UByte = 0, anim As Any Ptr = 0)
        this.tex1 = tex1
        this.tex2 = tex2
        this.flags = flags
        this.anim = anim
    End Constructor
    Sub ASCIITile.DrawTexture(x As Integer, y As Integer)
        If tex2.char <> 0 Then tex2.DrawTexture(x,y)
        If tex1.char <> 0 Then tex1.DrawTexture(x,y)
    End Sub
    


Type Camera
    x    As Integer
    y    As Integer
    oldx As Integer = 0
    oldy As Integer = 0
    Declare Constructor(x As Integer=0, y As Integer=0)
End Type
    Constructor Camera(x As Integer=0, y As Integer=0)
        this.x = x
        this.y = y
    End Constructor


Type TileCache
    originX As Integer
    originY As Integer
    isEmpty As Byte
    'buffer    (-BUFFERXDIST To BUFFERXDIST, -BUFFERYDIST To BUFFERYDIST) As UByte
    texBuffer (-BUFFERXDIST To BUFFERXDIST, -BUFFERYDIST To BUFFERYDIST) As ASCIITile
    'texBuffer2(-BUFFERXDIST To BUFFERXDIST, -BUFFERYDIST To BUFFERYDIST) As ASCIITexture
    Dim GetTexture As Function(x As Integer, y As Integer) As ASCIITile'ASCIITexture
    'Dim GetTexture2 As Function(x As Integer, y As Integer) As ASCIITexture
    Declare Constructor(originX As Integer = 0, originY As Integer = 0)
    Declare Constructor(originX As Integer, originY As Integer, func As Function(x As Integer, y As Integer) As ASCIITile) ', func2 As Function(x As Integer, y As Integer) As ASCIITexture = 0)
    Declare Sub setOrigin(originX As Integer, originY As Integer)
End Type
    Constructor TileCache(originX As Integer = 0, originY As Integer = 0)
        this.originX = originX
        this.originY = originY
        this.isEmpty = -1
    End Constructor
    Constructor TileCache(originX As Integer, originY As Integer, func As Function(x As Integer, y As Integer) As ASCIITile) ', func2 As Function(x As Integer, y As Integer) As ASCIITexture = 0)
        this.originX = originX
        this.originY = originY
        this.isEmpty = -1
        this.GetTexture  = func
        'this.GetTexture2 = func2
    End Constructor
    Sub TileCache.setOrigin(originX As Integer, originY As Integer)
        this.originX = originX
        this.originY = originY
    End Sub




Type Particle
	x As Double
	y As Double
	r As UByte
	g As UByte
	b As UByte
	c As UByte = 249
	fadeTime As Single
	startTime As Double
	Declare Constructor(x As Integer=0, y As Integer=0, col As UInteger = 0, startTime As Double, fade As Single=1, char As UByte=249)
End Type
	Constructor Particle(x As Integer=0, y As Integer=0, col As UInteger = 0, startTime As Double, fade As Single=1, char As UByte=249)
		this.x = x
		this.y = y
		this.r = rgb_r(col)
		this.g = rgb_g(col)
		this.b = rgb_b(col)
		this.c = char
		this.fadeTime = fade
		this.startTime = startTime
	End Constructor

'Operator = (lhs As Trail, rhs As Trail) As Integer
'	Return (lhs.x = rhs.x) AndAlso (lhs.y = rhs.y) AndAlso (lhs.fade = rhs.fade)
'End Operator


'DeclareSingleLinkedListType(Trail)
'Dim Shared trails As TrailSingleLinkedList
Dim Shared particles As SingleLinkedList
