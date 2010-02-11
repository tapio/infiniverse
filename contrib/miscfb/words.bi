'' String Functions ''

Function CountWords(st As String, sep_ As String = " ") As Integer
    Dim As Integer count = 0, nextIndex = 0
    st = Trim(st, sep_)
    If Len(st) = 0 Then Return 0
    nextIndex = InStr(st, sep_)
	Do While nextIndex > 0 'if not found loop will be skipped
		count+=1
	    nextIndex = InStr(nextIndex + Len(sep_), st, sep_)
	Loop
    Return count+1
End Function


Function GetWord(st As String, index As Integer, sep_ As String = " ") As String
    Dim As Integer count = 1, nextIndex = 0, wordStart = -1
    Dim As String st1 = Trim(st, sep_)
    If Len(st1) = 0 Or index <= 0 Or index > CountWords(st1,sep_) Then Return ""
    st1 += sep_
    If index = 1 Then Return Mid(st1, 1, InStr(st1,sep_)-1)
    Do
        If count = index Then wordStart = nextIndex + Len(sep_)
        nextIndex = InStr(nextIndex + Len(sep_), st1, sep_)
        count+=1
    Loop Until wordStart <> -1
    Dim As String ret = Mid(st1, wordStart, nextIndex-wordStart)
    Return ret
End Function


Function Clean(st As String, chars As String) As String
	Dim As Integer i,j
	Dim As String prev = "", cur = "", ret = ""
	For i As Integer = 1 To Len(st)
		cur = Mid(st,i,1)
		If cur <> prev OrElse InStr(chars,cur) = 0 Then ret+=cur
		prev = cur
	Next
	Return ret
End Function


Function Replace( _
        Byref text As Const String, _
        Byref subString As Const String, _
        Byref newString As Const String) As String

        If Len(text) = 0 Then Return ""
        If Len(subString) = 0 Then Return text

        Dim As Integer match = Instr(text, subString), match0 = Any
        If match = 0 Then Return text

        Dim As String  result
        Dim As Integer sublen = Len(subString), newlen = Len(newString)

        result = Left(text, match - 1) & newstring

        Do
			match0 = match + sublen
			match  = Instr(match0, text, subString)

			If match = 0 Then Return result & Mid(text, match0)

			Assert( match >= match0 )
			result &= Mid(text, match0, match - match0)
			result &= newString
        Loop
End Function
