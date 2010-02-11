
'''''''''''''''''''''''''''''''''
'' Perlin Noise Implementation ''
''  (and some useful helpers)  ''
'''''''''''''''''''''''''''''''''

#Define FADE(_t) (_t * _t * _t * (_t * (_t * 6 - 15) + 10))
#Define NLERP(_t, _a, _b) ((_a) + (_t)*((_b)-(_a)))

Declare Sub BuildNoiseTables(seed As Double = -1, num As Byte = 1)
Declare Sub BuildNoiseTable(seed As Double = -1, k As Byte = 0)
Declare Function Noise(x As Double, y As Double, px As Double, py As Double, noiseId As Byte = 1) As Double
Declare Function Perlin(x As Double, y As Double, xsizemax As Double, ysizemax As Double, size As Double, noiseId As Byte = 1) As UByte
Declare Function ExpFilter(value As UByte, cover As Double, sharpness As Double) As UByte
Declare Sub DumpBMP(filename As String, xsizemax As Double, ysizemax As Double, size As Double, noiseId As Byte = 1)

Const MAX_PERMS = 10
Dim Shared As UByte perm(512, 1 To MAX_PERMS)
Dim Shared As Double ms_grad4(256, 1 To MAX_PERMS)
Dim Shared As Double kkf(256)
    For i As Integer = 0 To 255
        kkf(i) = -1.0f + 2.0f * (i / 255.0f)
    Next


'' Inititalize some permutation tables for different noises
Sub BuildNoiseTables(seed As Double = -1, num As Byte = 1)
    If seed <> -1 Then Randomize seed
    For k As Integer = 1 To num
        BuildNoiseTable -1, k
    Next k
End Sub

'' Buil a permutation table
Sub BuildNoiseTable(seed As Double = -1, k As Byte = 0)
    If seed <> -1 Then Randomize seed
    If k = 0 Then BuildNoiseTables(seed,MAX_PERMS): Exit Sub
    Dim As Integer i,j
    For i = 0 To 255
        perm(i,k) = i
    Next i

    For i = 0 To 255
        j = Rnd*256
        Swap perm(i,k), perm(j,k)
    Next i

    For i = 0 To 255
        perm(i+256,k) = perm(i,k)
    Next i
    
    For i As Integer = 0 To 255
        ms_grad4(i,k) = kkf(perm(i,k)) * 0.507f
    Next i  
End Sub

'' Perlin noise function
Function Noise(x As Double, y As Double, px As Double, py As Double, noiseId As Byte = 1) As Double
        Dim As Integer ix0, iy0, ix1, iy1
        Dim As Double fx0, fy0
        Dim As Double s, t, nx0, nx1, n0, n1
   
        ix0 = CInt(x - 0.5f)
        iy0 = CInt(y - 0.5f)
   
        fx0 = x - ix0
        fy0 = y - iy0
        If px < 1 Then px = 1
        If py < 1 Then py = 1
        ix1 = ((ix0 + 1) Mod px) And &hff
        iy1 = ((iy0 + 1) Mod py) And &hff
        ix0 = (ix0 Mod px) And &hff
        iy0 = (iy0 Mod py) And &hff
   
        t = FADE(fy0)
        s = FADE(fx0)
   
        nx0 = ms_grad4(perm(ix0 + perm(iy0, noiseId), noiseId), noiseId)
        nx1 = ms_grad4(perm(ix0 + perm(iy1, noiseId), noiseId), noiseId)
        n0 = NLERP( t, nx0, nx1 )
   
        nx0 = ms_grad4(perm(ix1 + perm(iy0, noiseId), noiseId), noiseId)
        nx1 = ms_grad4(perm(ix1 + perm(iy1, noiseId), noiseId), noiseId)
        n1 = NLERP(t, nx0, nx1)
   
        Return NLERP(s, n0, n1)
End Function

'' The actual Perlin noise function that sums octaves.
'' Call this.
'' Returns UByte.
Function Perlin(x As Double, y As Double, xsizemax As Double, ysizemax As Double, size As Double, noiseId As Byte = 1) As UByte
    ' size must be 2 ^ n
    Dim As Double value = 0.0, initialSize = size
   
    While(size >= 1)
        value += Noise(x / size, y / size, xsizemax / size, ysizemax / size, noiseId) * size
        size /= 2.0 '1.5
    Wend
   
    Return (128.0 * value / initialSize) + 127
End Function


'' Exponent filter for making clouds
Function ExpFilter(value As UByte, cover As Double, sharpness As Double) As UByte
    Dim As Double c = value - (255.0f-cover) '''''255
    If c < 0 Then c = 0
    value = 255.0f - (CDbl(sharpness^c)*255.0f)
    Return CUByte(value)
End Function


'' Dumps a .bmp image from the given noise
Sub DumpBMP(filename As String = "NoiseMap.bmp", xsizemax As Double, ysizemax As Double, size As Double, noiseId As Byte = 1)
    Dim mapimage As Any Ptr = ImageCreate(xsizemax,ysizemax)
    Dim b As UByte
    For j As Integer = 0 To ysizemax-1
        For i As Integer = 0 To xsizemax-1
            b = Perlin(i,j,xsizemax,ysizemax,size,noiseId)
            PSet mapimage, (i,j), Rgb(b,b,b)
        Next i
    Next j
    BSave filename, mapimage
    ImageDestroy(mapimage)
End Sub
