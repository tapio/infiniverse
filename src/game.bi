
#Define TRAFFIC_DELAY 0.05
#Define PING_INTERVAL 1.5
#Define KEEP_ALIVE_DELAY 0.5
#Define LOSE_DELAY 2.0
#Define LOSE_DISTANCE 512

#Define acc 20.0
#Define turn_rate pi
#Define fine_spd 15.0	'speed when using arrows
#Define build_spd 3.0	'speed in build mode

#Define char_starship Chr(234)
#Define char_lander   Chr(227)
#Define char_walking  "@"


Function isMacroVL(_vl As Integer) As Integer
	Return (_vl <> zDetail AndAlso _vl <> zSpecial AndAlso _vl <> zGalaxy)
End Function


Type SpaceShip
	x    As Double
	y    As Double
    ang  As Double  = 0
    spd  As Double  = 0
    oldx As Integer = 0
    oldy As Integer = 0
    upX  As Integer = -100
    upY  As Integer = -100
    fuel As Single  = 100
    thrust As Integer = 0
    strafe As Integer = 0
	energy As Single = 100
    curIcon As String = char_starship
    Declare Constructor(x As Double = 0, y As Double = 0, ang As Single = 0)
End Type
    Constructor SpaceShip(x As Double = 0, y As Double = 0, ang As Single = 0)
        this.x   = x
        this.y   = y
        this.ang = ang
    End Constructor



Type Player
	id As String
	As Double x,y,oldx,oldy,refx,refy
	As Single ang
	As Single spd
	As Double lastUpdate
	Declare Sub updatePos(_frameTime As Double = 1.0)
	Declare Sub updatePos(_x As Double, _y As Double, _timeAdjust As Double = 0)
End Type
	Sub Player.updatePos(_frameTime As Double = 1.0)
		this.oldx = this.x
		this.oldy = this.y
		this.x += (Cos(this.ang) * this.spd * _frameTime)
		this.y -= (Sin(this.ang) * this.spd * _frameTime)
	End Sub
	Sub Player.updatePos(_x As Double, _y As Double, _timeAdjust As Double = 0)
		this.oldx = this.refx
		this.oldy = this.refy
		this.refx = _x
		this.refy = _y
		this.x = _x
		this.y = _y
		this.ang = GetAngle(oldx,oldy,x,y)
		this.spd = Distance(oldx,oldy,x,y) / (Timer - this.lastUpdate)
		this.lastUpdate = Timer + _timeAdjust
	End Sub

ReDim players(0) As Player
Dim numPlayers As Integer = 0






Dim missile_char(0 To 7) As ZString*2
	missile_char(0) = "-"
	missile_char(1) = "/"
	missile_char(2) = "|"
	missile_char(3) = "\"
	missile_char(4) = "-"
	missile_char(5) = "/"
	missile_char(6) = "|"
	missile_char(7) = "\"


Type Missile
	As UInteger id
	As Double x,y,oldx,oldy,refx,refy
	As Single ang
	As Single spd
	As Single fuel
	As Double lastUpdate
	Declare Constructor (_x As Double = 0, _y As Double = 0, _ang As Single = 0, _spd As Single = 1.0, _fuel As Single = 0)
	Declare Sub updatePos(_frameTime As Double = 1.0)
	Declare Sub updatePos(_x As Double, _y As Double, _timeAdjust As Double = 0)
End Type
	Constructor Missile(_x As Double = 0, _y As Double = 0, _ang As Single = 0, _spd As Single = 1.0, _fuel As Single = 0)
		this.x = _x
		this.y = _y
		this.id = CUInt(Rnd*4294967395.0)
		this.ang = _ang
		this.spd = _spd
		this.fuel = _fuel
		this.oldx = _x
		this.oldy = _y
		this.lastUpdate = Timer
	End Constructor
	Sub Missile.updatePos(_frameTime As Double = 1.0)
		this.oldx = this.x
		this.oldy = this.y
		this.x += (Cos(this.ang) * this.spd * _frameTime)
		this.y -= (Sin(this.ang) * this.spd * _frameTime)
	End Sub
	Sub Missile.updatePos(_x As Double, _y As Double, _timeAdjust As Double = 0)
		this.oldx = this.refx
		this.oldy = this.refy
		this.refx = _x
		this.refy = _y
		this.x = _x
		this.y = _y
		this.ang = GetAngle(oldx,oldy,x,y)
		this.spd = Distance(oldx,oldy,x,y) / (Timer - this.lastUpdate)
		this.lastUpdate = Timer + _timeAdjust
	End Sub

Dim Shared missiles As SingleLinkedList






Type Particle
	x As Double
	y As Double
	r As UByte
	g As UByte
	b As UByte
	c As UByte = 249
	ang As Single
	spd As Single
	fadeTime As Single
	startTime As Double
	Declare Constructor(x As Integer=0, y As Integer=0, col As UInteger = 0, startTime As Double, _
						fade As Single=1, char As UByte=249, spd As Single=0, ang As Single=0)
End Type
	Constructor Particle(x As Integer=0, y As Integer=0, col As UInteger = 0, startTime As Double, _
						fade As Single=1, char As UByte=249, spd As Single=0, ang As Single=0)
		this.x = x
		this.y = y
		this.r = rgb_r(col)
		this.g = rgb_g(col)
		this.b = rgb_b(col)
		this.c = char
		this.ang = ang
		this.spd = spd
		this.fadeTime = fade
		this.startTime = startTime
	End Constructor

Dim Shared particles As SingleLinkedList




Sub AddTrail(x1 As Double, y1 As Double, x2 As Double, y2 As Double, col As UInteger = 0, trailTime As Single = 1.0)
	If col = 0 Then col = RGB(128,0,255)
	Var xdiff = Abs(CInt(x1)-CInt(x2))
	Var ydiff = Abs(CInt(y1)-CInt(y2))
	If xdiff = 1 OrElse ydiff = 1 Then
		'Dim As Single d = Distance(x1, y1, x2, y2)
		'Dim As Single tempang = GetAngle(x1,y1,x2,y2)
		particles.add(New Particle(x2,y2,col,Timer,trailTime)) ',,d,tempang))
	ElseIf xdiff > 1 OrElse ydiff > 1 Then
		Dim As Integer d = Distance(x1, y1, x2, y2)
		Dim As Single tempang = GetAngle(x1,y1,x2,y2)
		For dd As Single = 1 To d ' Step 0.5
			Var tempx = x1 + CInt(Cos(tempang)*dd)
			Var tempy = y1 - CInt(Sin(tempang)*dd)
			particles.add(New Particle(tempx,tempy,col,Timer,trailTime)) ',,d,tempang))
		Next dd
	EndIf
End Sub


Sub AddExplosion(x As Double, y As Double, col As UInteger = 0, pCount As Integer = 8, explTime As Single = 1.0)
	If col = 0 Then col = RGB(255,255,0)
	#Define EXPL_SPD 2.0
	Dim As Single angleStep = 2*pi / pCount
	For a As Single = 0 To 2*pi Step angleStep
		particles.add(New Particle(x,y,col,Timer,explTime,249,EXPL_SPD,a))
	Next a
End Sub
