'' md5.bas
''
'' This implementation of MD5 is a translation of the code in md5deep-1.8
'' The copyright notice of md5deep is retained below
''
''
'' This code implements the MD5 message-digest algorithm.
'' The algorithm was written by Ron Rivest.  This code was
'' written by Colin Plumb in 1993, our understanding is
'' that no copyright is claimed and that
'' this code is in the public domain.
''
'' Equivalent code is available from RSA Data Security, Inc.
'' This code has been tested against that, and is
'' functionally equivalent,
''
'' To compute the message digest of a chunk of bytes, declare an
'' MD5Context structure, pass it to MD5Init, call MD5Update as
'' needed on buffers full of bytes, and then call MD5Final, which
'' will fill a supplied 16-byte array with the digest.
''
''------------------------------------------------------------------------------

#include once "crt.bi"


'' User functions ''
Declare Function MD5_FromFile(filename As String) As String
Declare Function MD5_FromString(st As String) As String
'' -------------- ''


type MD5Context
	buf(0 to 3) as unsigned integer
	bits(0 to 1) as unsigned integer
	in(0 to 63) as ubyte
end type

declare sub MD5Init(byval ctx as MD5Context ptr)
declare sub MD5Update(byval ctx as MD5Context ptr, byval buf as ubyte ptr, byval llen as unsigned integer)
declare sub MD5Final(byval digest as ubyte ptr, byval ctx as MD5Context ptr)
declare sub MD5Transform (byval buf as integer ptr, byval in as integer ptr)

''
'' Start MD5 accumulation.  Set bit count to 0 and buffer to mysterious
'' initialization constants.
''

sub  MD5Init(byval ctx as MD5Context ptr)
	ctx->buf(0) = cuint(&h67452301)
	ctx->buf(1) = cuint(&hefcdab89)
	ctx->buf(2) = cuint(&h98badcfe)
	ctx->buf(3) = cuint(&h10325476)
	ctx->bits(0) = 0
	ctx->bits(1) = 0
end sub

''
'' Update context to reflect the concatenation of another buffer full
'' of bytes.
''
sub MD5Update(byval ctx as MD5Context ptr, byval buf as ubyte ptr, byval llen as unsigned integer)
	dim as unsigned integer t
	dim as ubyte ptr p

'	'' Update bitcount

	t = ctx->bits(0)
    ctx->bits(0) = t + (llen shl 3)
	if ctx->bits(0) < t then ctx->bits(1) += 1 '' Carry from low to high
	ctx->bits(1) = (ctx->bits(1) + llen) shr 29

	t = (t shr 3) and &h3f	'' Bytes already in shsInfo->data

	'' Handle any leading odd-sized chunks
	if t <> 0 then
		p = @ctx->in(t)
		t = 64 - t
		if (llen < t) then
			memcpy(p, buf, llen)
			exit sub
		end if
		memcpy(p, buf, t)
		MD5Transform(@ctx->buf(0), cptr(integer ptr,@ctx->in(0)))
		buf += t
		llen -= t
	end if



	'' Process data in 64-byte chunks
	while llen >= 64
		memcpy(@ctx->in(0), buf, 64)
		MD5Transform(@ctx->buf(0), cptr(integer ptr,@ctx->in(0)))
		buf += 64
		llen -= 64
	wend

	'' Handle any remaining bytes of data.
	memcpy(@ctx->in(0), buf, llen)

end sub

''
'' Final wrapup - pad to 64-byte boundary with the bit pattern
'' 1 0* (64-bit count of bits processed, MSB-first)
''
sub MD5Final(byval digest as ubyte ptr, byval ctx as MD5Context ptr)
	dim as unsigned integer count
	dim as ubyte ptr p

	'' Compute number of bytes mod 64
	count = (ctx->bits(0) shr 3) and &h3f

	'' Set the first char of padding to &h80.  This is safe since there is
	'' always at least one byte free
	p = @ctx->in(count)
	*p = &h80
	p = p + 1

	'' Bytes of padding needed to make 64 bytes
	count = 64 - 1 - count

	'' Pad out to 56 mod 64
	if (count < 8) then
		'' Two lots of padding:  Pad the first block to 64 bytes
		memset(p, 0, count)
		MD5Transform(@ctx->buf(0), cptr(integer ptr,@ctx->in(0)))

		'' Now fill the next block with 56 bytes
		memset(@ctx->in(0), 0, 56)
	else
		'' Pad block to 56 bytes
		memset(p, 0, count - 8)
	end if

	'' Append length in bits and transform
    '' ((u_int32_t *) ctx->in)[14] = ctx->bits[0];
    '' ((u_int32_t *) ctx->in)[15] = ctx->bits[1];
    dim pint as unsigned integer pointer
	pint = cptr(unsigned integer pointer, @ctx->in(14*4)) : *pint = ctx->bits(0)
	pint = cptr(unsigned integer pointer, @ctx->in(15*4)) : *pint = ctx->bits(1)

	MD5Transform(@ctx->buf(0), cptr(integer ptr,@ctx->in(0)))
	memcpy(digest, @ctx->buf(0), 16)
	memset(ctx, 0, sizeof(*ctx))	'' In case it's sensitive
	'' The original version of this code omitted the asterisk. In
	'' effect, only the first part of ctx was wiped with zeros, not
	'' the whole thing. Bug found by Derek Jones. Original line:
	'' memset(ctx, 0, sizeof(ctx));	'' In case it's sensitive
end sub


'' The four core functions - F1 is optimized somewhat

'' #define F1(x, y, z) (x & y | ~x & z)
#define F1(x, y, z) (z xor (x and (y xor z)))
#define F2(x, y, z) F1(z, x, y)
#define F3(x, y, z) (x xor y xor z)
#define F4(x, y, z) (y xor (x or (not z)))

'' This is the central step in the MD5 algorithm.
#define MD5STEP(f, w, x, y, z, ddata, s) w += f  + ddata :  w = w shl s or w  shr (32-s) :  w += x

''
'' The core of the MD5 algorithm, this alters an existing MD5 hash to
'' reflect the addition of 16 longwords of new data.  MD5Update blocks
'' the data and converts bytes into longwords for this routine.

sub MD5Transform (byval buf as integer ptr, byval in as integer ptr)
	dim as unsigned integer a, b, c, d

	a = buf[0]
	b = buf[1]
	c = buf[2]
	d = buf[3]

	MD5STEP(F1(b,c,d), a, b, c, d, in[0] + &hd76aa478L, 7)
	MD5STEP(F1(a,b,c), d, a, b, c, in[1] + &he8c7b756L, 12)
	MD5STEP(F1(d,a,b), c, d, a, b, in[2] + &h242070dbL, 17)
	MD5STEP(F1(c,d,a), b, c, d, a, in[3] + &hc1bdceeeL, 22)
	MD5STEP(F1(b,c,d), a, b, c, d, in[4] + &hf57c0fafL, 7)
	MD5STEP(F1(a,b,c), d, a, b, c, in[5] + &h4787c62aL, 12)
	MD5STEP(F1(d,a,b), c, d, a, b, in[6] + &ha8304613L, 17)
	MD5STEP(F1(c,d,a), b, c, d, a, in[7] + &hfd469501L, 22)
	MD5STEP(F1(b,c,d), a, b, c, d, in[8] + &h698098d8L, 7)
	MD5STEP(F1(a,b,c), d, a, b, c, in[9] + &h8b44f7afL, 12)
	MD5STEP(F1(d,a,b), c, d, a, b, in[10] + &hffff5bb1L, 17)
	MD5STEP(F1(c,d,a), b, c, d, a, in[11] + &h895cd7beL, 22)
	MD5STEP(F1(b,c,d), a, b, c, d, in[12] + &h6b901122L, 7)
	MD5STEP(F1(a,b,c), d, a, b, c, in[13] + &hfd987193L, 12)
	MD5STEP(F1(d,a,b), c, d, a, b, in[14] + &ha679438eL, 17)
	MD5STEP(F1(c,d,a), b, c, d, a, in[15] + &h49b40821L, 22)

	MD5STEP(F2(b,c,d), a, b, c, d, in[1] + &hf61e2562L, 5)
	MD5STEP(F2(a,b,c), d, a, b, c, in[6] + &hc040b340L, 9)
	MD5STEP(F2(d,a,b), c, d, a, b, in[11] + &h265e5a51L, 14)
	MD5STEP(F2(c,d,a), b, c, d, a, in[0] + &he9b6c7aaL, 20)
	MD5STEP(F2(b,c,d), a, b, c, d, in[5] + &hd62f105dL, 5)
	MD5STEP(F2(a,b,c), d, a, b, c, in[10] + &h02441453L, 9)
	MD5STEP(F2(d,a,b), c, d, a, b, in[15] + &hd8a1e681L, 14)
	MD5STEP(F2(c,d,a), b, c, d, a, in[4] + &he7d3fbc8L, 20)
	MD5STEP(F2(b,c,d), a, b, c, d, in[9] + &h21e1cde6L, 5)
	MD5STEP(F2(a,b,c), d, a, b, c, in[14] + &hc33707d6L, 9)
	MD5STEP(F2(d,a,b), c, d, a, b, in[3] + &hf4d50d87L, 14)
	MD5STEP(F2(c,d,a), b, c, d, a, in[8] + &h455a14edL, 20)
	MD5STEP(F2(b,c,d), a, b, c, d, in[13] + &ha9e3e905L, 5)
	MD5STEP(F2(a,b,c), d, a, b, c, in[2] + &hfcefa3f8L, 9)
	MD5STEP(F2(d,a,b), c, d, a, b, in[7] + &h676f02d9L, 14)
	MD5STEP(F2(c,d,a), b, c, d, a, in[12] + &h8d2a4c8aL, 20)

	MD5STEP(F3(b,c,d), a, b, c, d, in[5] + &hfffa3942L, 4)
	MD5STEP(F3(a,b,c), d, a, b, c, in[8] + &h8771f681L, 11)
	MD5STEP(F3(d,a,b), c, d, a, b, in[11] + &h6d9d6122L, 16)
	MD5STEP(F3(c,d,a), b, c, d, a, in[14] + &hfde5380cL, 23)
	MD5STEP(F3(b,c,d), a, b, c, d, in[1] + &ha4beea44L, 4)
	MD5STEP(F3(a,b,c), d, a, b, c, in[4] + &h4bdecfa9L, 11)
	MD5STEP(F3(d,a,b), c, d, a, b, in[7] + &hf6bb4b60L, 16)
	MD5STEP(F3(c,d,a), b, c, d, a, in[10] + &hbebfbc70L, 23)
	MD5STEP(F3(b,c,d), a, b, c, d, in[13] + &h289b7ec6L, 4)
	MD5STEP(F3(a,b,c), d, a, b, c, in[0] + &heaa127faL, 11)
	MD5STEP(F3(d,a,b), c, d, a, b, in[3] + &hd4ef3085L, 16)
	MD5STEP(F3(c,d,a), b, c, d, a, in[6] + &h04881d05L, 23)
	MD5STEP(F3(b,c,d), a, b, c, d, in[9] + &hd9d4d039L, 4)
	MD5STEP(F3(a,b,c), d, a, b, c, in[12] + &he6db99e5L, 11)
	MD5STEP(F3(d,a,b), c, d, a, b, in[15] + &h1fa27cf8L, 16)
	MD5STEP(F3(c,d,a), b, c, d, a, in[2] + &hc4ac5665L, 23)

	MD5STEP(F4(b,c,d), a, b, c, d, in[0] + &hf4292244L, 6)
	MD5STEP(F4(a,b,c), d, a, b, c, in[7] + &h432aff97L, 10)
	MD5STEP(F4(d,a,b), c, d, a, b, in[14] + &hab9423a7L, 15)
	MD5STEP(F4(c,d,a), b, c, d, a, in[5] + &hfc93a039L, 21)
	MD5STEP(F4(b,c,d), a, b, c, d, in[12] + &h655b59c3L, 6)
	MD5STEP(F4(a,b,c), d, a, b, c, in[3] + &h8f0ccc92L, 10)
	MD5STEP(F4(d,a,b), c, d, a, b, in[10] + &hffeff47dL, 15)
	MD5STEP(F4(c,d,a), b, c, d, a, in[1] + &h85845dd1L, 21)
	MD5STEP(F4(b,c,d), a, b, c, d, in[8] + &h6fa87e4fL, 6)
	MD5STEP(F4(a,b,c), d, a, b, c, in[15] + &hfe2ce6e0L, 10)
	MD5STEP(F4(d,a,b), c, d, a, b, in[6] + &ha3014314L, 15)
	MD5STEP(F4(c,d,a), b, c, d, a, in[13] + &h4e0811a1L, 21)
	MD5STEP(F4(b,c,d), a, b, c, d, in[4] + &hf7537e82L, 6)
	MD5STEP(F4(a,b,c), d, a, b, c, in[11] + &hbd3af235L, 10)
	MD5STEP(F4(d,a,b), c, d, a, b, in[2] + &h2ad7d2bbL, 15)
	MD5STEP(F4(c,d,a), b, c, d, a, in[9] + &heb86d391L, 21)
	buf[0] += a
	buf[1] += b
	buf[2] += c
	buf[3] += d
end sub




Function MD5_FromString(st As String) As String
	Var st_len = Len(st)
	Dim st_in As ZString Ptr = Allocate(st_len+1)
	*st_in = st
	Dim As MD5Context ctx
	Dim As UByte md5sum(0 To 15)
	Dim As String st_out, st_temp

	MD5Init( @ctx )
	MD5Update( @ctx, st_in, st_len )
	MD5Final( @md5sum(0), @ctx)

	For i As Integer = 0 To 15
		st_temp = Lcase(Hex(md5sum(i)))
		If Len(st_temp) = 1 Then st_out += "0" + st_temp Else st_out += st_temp 
	Next i

	Return st_out
End Function


Function MD5_FromFile(filename As String) As String
	Var f = FreeFile
	Open filename For Binary Access Read Lock Read As f
	If Err > 0 Then Return ""
	
	#Define chunksize 524288 '(2^20)
	Dim buf_in(chunksize) As UByte
	Dim buf_len As UInteger
	Dim As MD5Context ctx

	MD5Init( @ctx )
	Do Until EOF(f)
		Get #f, , buf_in(0), chunksize, buf_len
		MD5Update( @ctx, @buf_in(0), buf_len )
	Loop	
	Dim As UByte md5sum(0 To 15)
	MD5Final( @md5sum(0), @ctx)
	Close f
	
	Dim As String st_out, st_temp
	For i As Integer = 0 To 15
		st_temp = Lcase(Hex(md5sum(i)))
		If Len(st_temp) = 1 Then st_out += "0" + st_temp Else st_out += st_temp 
	Next i

	Return st_out
End Function
