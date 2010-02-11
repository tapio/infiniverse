'' Utilities '' 

'#IfNDef Rand
Declare Function Rand OverLoad (first As Double, last As Double) As Double
Declare Function Rand OverLoad (first As Integer, last As Integer) As Integer
'#Endif
Declare Function middle(a As Double, b As Double, c As Double) As Double
Declare Function blendRGB(col1 As UInteger, col2 As UInteger, factor As Single) As UInteger


'' Math Functions ''
'#IfNDef Rand
Function Rand(first As Double, last As Double) As Double
    Return Rnd * (last - first) + first
End Function

Function Rand(first As Integer, last As Integer) As Integer
    Return Int(Rnd * (last - first + 1)) + first
End Function
'#Endif

Function blendRGB(col1 As UInteger, col2 As UInteger, factor As Single) As UInteger'
	''requires def.bi
	Dim As UByte r,g,b
	r = blend(rgb_r(col1), rgb_r(col2), factor)
	g = blend(rgb_g(col1), rgb_g(col2), factor)
	b = blend(rgb_b(col1), rgb_b(col2), factor)
	Return RGB(r,g,b)
End Function

Function Middle(a As Double, b As Double, c As Double) As Double
    Dim As Double minval = min(a,b): minval = min(c, minval)
    Dim As Double maxval = max(a,b): maxval = max(c, maxval)
    If minval < a And maxval > a Then Return a
    If minval < b And maxval > b Then Return b
    Return c 
End Function

'Declare Function Distance Overload (x1 As Double, y1 As Double, x2 As Double, y2 As Double) As Double
'Declare Function Distance Overload (x1 As Integer, y1 As Integer, x2 As Integer, y2 As Integer) As Integer

Function Distance (x1 As Double, y1 As Double, x2 As Double, y2 As Double) As Double
	Return Sqr( (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) )
End Function 

'Function Distance Overload (x1 As Integer, y1 As Integer, x2 As Integer, y2 As Integer) As Integer
'	Return Sqr( CSng((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1)) )
'End Function 

'Function GetAngle(x1 As Double, y1 As Double, x2 As Double, y2 As Double) As Double
'    Dim result As Double = (Atan2( y1-y2, x2-x1 )
'    If result < 0 Then Return result+360 Else Return result
'End Function

'#Define GetAngle(x1,y1,x2,y2) Atan2((y1)-(y2), (x2)-(x1))

Sub TextCenterScreen(_txt As String, _y As Integer, r As Short = -1, g As Short = -1, b As Short = -1)
	Dim As Integer _w
	ScreenInfo _w
	Dim As UInteger _col
	If r <> -1 And g <> -1 And b <> -1 Then _col = RGB(r,g,b) Else _col = Color()
	Draw String ( (_w-Len(_txt)*8)*.5, _y ), _txt, _col
End Sub

Sub PrintCenterScreen(_txt As String, _y As Integer, r As Short = -1, g As Short = -1, b As Short = -1)
	Dim As Short _w = LoWord(Width())
	Dim As UInteger _col
	If r <> -1 And g <> -1 And b <> -1 Then Color RGB(r,g,b)
	Locate _y, ( _w-Len(_txt) ) \ 2
	Print _txt
End Sub

Sub ConsolePrint(_txt As String)
	Var f = FREEFILE
	Open Cons For Output As #f
	Print #f, _txt
	Close #f
End Sub

'' Useful timers ''

Type DelayTimer
    delay As Double
    record As Double
    running As Byte
    Declare Constructor(delay As Double, running As Byte = -1)
    Declare Function hasExpired() As Byte
    Declare Sub start()
    Declare Sub stop()
End Type
    Constructor DelayTimer(delay As Double, running As Byte = -1)
        this.delay = delay
        this.running = running
        this.record = Timer
    End Constructor 
    Function DelayTimer.hasExpired() As Byte
        If this.running = 0 OrElse Timer > this.record + this.delay Then
            'this.record = Timer
            this.running = 0
            Return Not 0
        EndIf
        Return 0
    End Function
    Sub DelayTimer.Start()
        this.running = Not 0
        this.record = Timer
    End Sub
    Sub DelayTimer.Stop()
        this.running = 0
    End Sub


#IfNDef _FRAMETIMER_AVERAGE_SPAN_
	#Define _FRAMETIMER_AVERAGE_SPAN_ 1.0
#EndIf
Type FrameTimer
    prevTime As Double
    frameTime As Double
    frameCounter As UInteger
    Declare Constructor()
    Declare Sub Update()
    Declare Function getFPS() As Integer
    Declare Function getFrameTime As Double
End Type
    Constructor FrameTimer()
        this.prevTime = Timer
    End Constructor
    Sub FrameTimer.Update()
		this.frameCounter+=1
		If Timer > this.prevTime + _FRAMETIMER_AVERAGE_SPAN_ Then
			this.frameTime = (Timer - this.prevTime) / CDbl(this.frameCounter)
			this.frameCounter = 0
			this.prevTime = Timer
		EndIf
    End Sub
    Function FrameTimer.getFPS As Integer
        Return Int(1.0 / this.frameTime)
    End Function
    Function FrameTimer.getFrameTime As Double
        Return this.frameTime
    End Function
        
'MISC

Sub AddLog(logstr As String, filename As String = "log.txt")
	Var f = FreeFile
	Open filename For Append As #f
		Print #f, logstr
    Close #f
End Sub

