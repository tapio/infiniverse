#Include Once "zlib.bi"

Declare Function savepng( _
Byref filename As String = "screenshot.png", _
Byval image As Any Ptr = 0, _
Byval save_alpha As Integer = 0) As Integer

Const PNG_HEADER As String = !"\137PNG\r\n\26\n"
Const IHDR_CRC0 As Uinteger = &ha8a1ae0a 'crc32(0, @"IHDR", 4)
Const PLTE_CRC0 As Uinteger = &h4ba88955 'crc32(0, @"PLTE", 4)
Const IDAT_CRC0 As Uinteger = &h35af061e 'crc32(0, @"IDAT", 4)
Const IEND_CRC0 As Uinteger = &hae426082 'crc32(0, @"IEND", 4)

Type struct_ihdr Field = 1
    Width As Uinteger
    height As Uinteger
    bitdepth As Ubyte
    colortype As Ubyte
    compression As Ubyte
    filter As Ubyte
    interlace As Ubyte
End Type
Const IHDR_SIZE As Uinteger = sizeof( struct_ihdr )

Function bswap(Byval n As Uinteger) As Uinteger
    
    Return (n And &h000000ff) Shl 24 Or _
    (n And &h0000ff00) Shl 8  Or _
    (n And &h00ff0000) Shr 8  Or _
    (n And &hff000000) Shr 24
    
End Function

Function savepng( _
    Byref filename As String = "screenshot.png", _
    Byval image As Any Ptr = 0, _
    Byval save_alpha As Integer = 0) As Integer
    
    
    Dim As Uinteger w, h, depth
    Dim As Integer f = Freefile()
    Dim As Integer e
    
    If image <> 0 Then
        If imageinfo( image, w, h, depth ) < 0 Then Return -1
        depth *= 8
    Else
        If screenptr = 0 Then Return -1
        screeninfo( w, h, depth )
    End If
    
    If depth <> 32 Then save_alpha = 0
    
    Select Case As Const depth
    
    Case 1 To 8
        
        Scope
            
            Dim ihdr As struct_ihdr = (bswap(w), bswap(h), 8, 3, 0, 0, 0)
            Dim As Uinteger ihdr_crc32 = crc32(IHDR_CRC0, cptr(Ubyte Ptr, @ihdr), sizeof(ihdr))
            
            Dim palsize As Uinteger = 1 Shl depth
            Dim pltesize As Uinteger = palsize * 3
            Dim plte(0 To 767) As Ubyte
            Dim plte_crc32 As Uinteger
            
            Dim As Uinteger l = w + 1
            Dim As Uinteger imgsize = l * h
            Dim As Uinteger idatsize = imgsize + 11 + 5 * (imgsize \ 16383)
            Dim imgdata(0 To imgsize - 1) As Ubyte
            Dim idat(0 To idatsize - 1) As Ubyte
            Dim As Uinteger idat_crc32
            Dim As Uinteger x, y, col, r, g, b
            Dim As Uinteger index
            
            index = 0
            For col = 0 To palsize - 1
                Palette Get col, r, g, b
                plte(index) = r : index += 1
                plte(index) = g : index += 1
                plte(index) = b : index += 1
            Next col
            
            plte_crc32 = crc32(PLTE_CRC0, @plte(0), pltesize)
            
            index = 0
            
            If image <> 0 Then
                For y = 0 To h - 1
                    imgdata(index) = 0 : index += 1
                    For x = 0 To w - 1
                        col = Point(x, y, image)
                        imgdata(index) = col : index += 1
                    Next x
                Next y
            Else
                screenlock
                For y = 0 To h - 1
                    imgdata(index) = 0 : index += 1
                    For x = 0 To w - 1
                        col = Point(x, y)
                        imgdata(index) = col : index += 1
                    Next x
                Next y
                screenunlock
            End If
            
            If compress2(@idat(0), @idatsize, @imgdata(0), imgsize, 9) Then Return -1
            idat_crc32 = crc32(IDAT_CRC0, @idat(0), idatsize)
            
            If Open (filename For Output As #f) Then Return -1
            
            e = Put( #f, 1, PNG_HEADER )
            
            e orelse= Put( #f, , bswap(IHDR_SIZE) )
            e orelse= Put( #f, , "IHDR" )
            e orelse= Put( #f, , ihdr )
            e orelse= Put( #f, , bswap(ihdr_crc32) )
            
            e orelse= Put( #f, , bswap(pltesize) )
            e orelse= Put( #f, , "PLTE" )
            e orelse= Put( #f, , plte(0), 3 * (1 Shl depth) )
            e orelse= Put( #f, , bswap(plte_crc32) )
            
            e orelse= Put( #f, , bswap(idatsize) )
            e orelse= Put( #f, , "IDAT" )
            e orelse= Put( #f, , idat(0), idatsize )
            e orelse= Put( #f, , bswap(idat_crc32) )
            
            e orelse= Put( #f, , bswap(0) )
            e orelse= Put( #f, , "IEND" )
            e orelse= Put( #f, , bswap(IEND_CRC0) )
            
            Close #f
            
            Return e
            
        End Scope
        
    Case 9 To 32
        
        Scope
            
            Dim ihdr As struct_ihdr = (bswap(w), bswap(h), 8, iif( save_alpha, 6, 2), 0, 0, 0)
            Dim As Uinteger ihdr_crc32 = crc32(IHDR_CRC0, cptr(Ubyte Ptr, @ihdr), sizeof(ihdr))
            
            Dim As Uinteger l = iif(save_alpha, (w * 4) + 1, (w * 3) + 1)
            Dim As Uinteger imgsize = l * h
            Dim As Uinteger idatsize = imgsize + 11 + 5 * (imgsize \ 16383)
            Dim imgdata(0 To imgsize - 1) As Ubyte
            Dim idat(0 To idatsize - 1) As Ubyte
            Dim As Uinteger idat_crc32
            Dim As Uinteger x, y, col, r, g, b, a
            Dim As Uinteger index
            Dim As Integer ret
            
            index = 0
            
            If image <> 0 Then
                For y = 0 To h - 1
                    imgdata(index) = 0 : index += 1
                    For x = 0 To w - 1
                        col = Point(x, y, image)
                        r = col Shr 16 And 255
                        g = col Shr 8 And 255
                        b = col And 255
                        imgdata(index) = r : index += 1
                        imgdata(index) = g : index += 1
                        imgdata(index) = b : index += 1
                        If save_alpha Then
                            a = col Shr 24
                            imgdata(index) = a : index += 1
                        End If
                    Next x
                Next y
            Else
                screenlock
                For y = 0 To h - 1
                    imgdata(index) = 0 : index += 1
                    For x = 0 To w - 1
                        col = Point(x, y)
                        r = col Shr 16 And 255
                        g = col Shr 8 And 255
                        b = col And 255
                        imgdata(index) = r : index += 1
                        imgdata(index) = g : index += 1
                        imgdata(index) = b : index += 1
                        If save_alpha Then 
                            a = col Shr 24
                            imgdata(index) = a : index += 1
                        End If
                    Next x
                Next y
                screenunlock
            End If
            
            If compress2(@idat(0), @idatsize, @imgdata(0), imgsize, 9) Then Return -1
            idat_crc32 = crc32(IDAT_CRC0, @idat(0), idatsize)
            
            If Open (filename For Output As #f) Then Return -1
            
            e = Put( #f, 1, PNG_HEADER )
            
            e orelse= Put( #f, , bswap(IHDR_SIZE) )
            e orelse= Put( #f, , "IHDR" )
            e orelse= Put( #f, , ihdr )
            e orelse= Put( #f, , bswap(ihdr_crc32) )
            
            e orelse= Put( #f, , bswap(idatsize) )
            e orelse= Put( #f, , "IDAT" )
            e orelse= Put( #f, , idat(0), idatsize )
            e orelse= Put( #f, , bswap(idat_crc32) )
            
            e orelse= Put( #f, , bswap(0) )
            e orelse= Put( #f, , "IEND" )
            e orelse= Put( #f, , bswap(IEND_CRC0) )
            
            Close #f
            
            Return e
            
        End Scope
        
    Case Else
        
        Return -1
        
    End Select
    
End Function
