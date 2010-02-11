' def.bi
'
' Contains some useful macros


' Color macros
#Define rgb_a(x) ((x) Shr 24)
#Define rgb_r(x) ((x) Shr 16 And 255)
#Define rgb_g(x) ((x) Shr 8 And 255)
#Define rgb_b(x) ((x) And 255)
#Define rgb_clamp(_c) (IIf((_c)>0, IIf((_c)<255, (_c),255), 0))

'#Define blend(a,b,f) ((Abs((b)-(a))*(f) + (a)))
#Define blend(a,b,f) ((a)*(f) + (b)*(1.0-(f)))
#Define blendMul(a,b) (((a) * (b)) Shr 8)

' Math
#Define DegToRad 0.017453292519943  ' constant for converting degrees to radians
#Define RadToDeg 57.29577951308233  ' constant for converting radians to degrees
#Define PI 3.141592653589793
#Define wrap(a,limit) ( (a) - Int((a) / (limit)) * (limit) )  ' modulus that works with floats
#Define mean(a,b) (((a)+(b))*.5)
#Define in2dArray(array,a,b) ((a) >= LBound(array,1) And (a) <= UBound(array,1) And (b) >= LBound(array,2) And (b) <= UBound(array,2))
'#Define round(a) ( Fix(0.5*Sgn(a)+a) )
#IfNDef max
	#Define max(a,b) ( IIf((a)>(b),(a),(b)) )
#EndIf
#IfNDef min
	#Define min(a,b) ( IIf((a)<(b),(a),(b)) )
#EndIf
#Define clip(x,lo,hi) ( IIf((x)>(lo),IIf((x)<(hi),(x),(hi)),(lo)) )
#Define GetAngle(x1,y1,x2,y2) Atan2((y1)-(y2), (x2)-(x1))


' Misc
#Define UpFirst(s) (UCase(Left((s),1))+Mid((s),2))
#Define iterArray(array,dimId) LBound(array,dimId) To UBound(array,dimId)
#Define between(v,a,b) ( (v) > (a) And (v) < (b) )
#Define inBounds(v,a,b) ( (v) >= (a) And (v) <= (b) )
#Define dimLen(array,dimId) (UBound(array,dimId) - LBound(array,dimId) + 1)
#Define switch(a) a = (a) Xor 1
#Define printval(bar) Print #bar; " ="; bar
#Macro ForIJ(loI,hiI,loJ,hiJ)
For j = loJ To hiJ
	For i = loI To hiI
#EndMacro
#Define NextIJ Next:Next 

#Macro printsleep(foo)
    Print foo: Sleep
#EndMacro


' Declaration
#Define dimI Dim As Integer
#Define dimSh Dim As Short
#Define dimL Dim As Long
#Define dimS Dim As Single
#Define dimD Dim As Double
#Define dimB Dim As Byte
#Define dimUB Dim As UByte
#Define dimStr Dim As String


' Scan codes
#Define KEY_ESC &h01
#Define KEY_1 &h02
#Define KEY_2 &h03
#Define KEY_3 &h04
#Define KEY_4 &h05
#Define KEY_5 &h06
#Define KEY_6 &h07
#Define KEY_7 &h08
#Define KEY_8 &h09
#Define KEY_9 &h0A
#Define KEY_0 &h0B
#Define KEY_MINUS &h0C
#Define KEY_EQUALS &h0D
#Define KEY_BACKSPACE &h0E
#Define KEY_TAB &h0F
#Define KEY_Q &h10
#Define KEY_W &h11
#Define KEY_E &h12
#Define KEY_R &h13
#Define KEY_T &h14
#Define KEY_Y &h15
#Define KEY_U &h16
#Define KEY_I &h17
#Define KEY_O &h18
#Define KEY_P &h19
#Define KEY_LEFTBRACKET &h1A
#Define KEY_RIGHTBRACKET &h1B
#Define KEY_ENTER &h1C
#Define KEY_CONTROL &h1D
#Define KEY_A &h1E
#Define KEY_S &h1F
#Define KEY_D &h20
#Define KEY_F &h21
#Define KEY_G &h22
#Define KEY_H &h23
#Define KEY_J &h24
#Define KEY_K &h25
#Define KEY_L &h26
#Define KEY_SEMICOLON &h27
#Define KEY_QUOTE &h28
#Define KEY_TILDE &h29
#Define KEY_LSHIFT &h2A
#Define KEY_BACKSLASH &h2B
#Define KEY_Z &h2C
#Define KEY_X &h2D
#Define KEY_C &h2E
#Define KEY_V &h2F
#Define KEY_B &h30
#Define KEY_N &h31
#Define KEY_M &h32
#Define KEY_COMMA &h33
#Define KEY_PERIOD &h34
#Define KEY_SLASH &h35
#Define KEY_RSHIFT &h36
#Define KEY_MULTIPLY &h37
#Define KEY_ALT &h38
#Define KEY_SPACE &h39
#Define KEY_CAPSLOCK &h3A
#Define KEY_F1 &h3B
#Define KEY_F2 &h3C
#Define KEY_F3 &h3D
#Define KEY_F4 &h3E
#Define KEY_F5 &h3F
#Define KEY_F6 &h40
#Define KEY_F7 &h41
#Define KEY_F8 &h42
#Define KEY_F9 &h43
#Define KEY_F10 &h44
#Define KEY_NUMLOCK &h45
#Define KEY_SCROLLLOCK &h46
#Define KEY_HOME &h47
#Define KEY_UP &h48
#Define KEY_PAGEUP &h49
#Define KEY_LEFT &h4B
#Define KEY_RIGHT &h4D
#Define KEY_PLUS &h4E
#Define KEY_END &h4F
#Define KEY_DOWN &h50
#Define KEY_PAGEDOWN &h51
#Define KEY_INSERT &h52
#Define KEY_DELETE &h53
#Define KEY_F11 &h57
#Define KEY_F12 &h58
