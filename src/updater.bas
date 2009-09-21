' Auto-updater software v0.7
' Dependencies: Chisock socket library
'
' Downloads files from an internet server according to an "update.ini" file
' Works by reading the file into memory, then downloading a new one and
' comparing the version numbers to determine, which files need an update.
'
' Update.ini file format
' Example:
'		[UPDATE]
'		version = 3
'		host = www.example.com/updatedir/
'		backup = www.backup_host.net/backup/update/
'		notes = This is an example update file, hosts won't work!
'		readme.txt = 1
'		application.exe = 0.3
'		folder/image.png = 2
' (End of example file)
' Notes follow:
'  * everything in the file before [UPDATE] -line is ignored (can be used for commenting)
'  * version -line is used to quickly evaluate if something has changed:
'    if it is not greater than the previous, the rest of the file is skipped.
'    set to 0 to disable (in other words, manually check every file)
'  * host is the url to the directory where the downloads are situated,
'    trailing forward slash is required!
'  * backup is used if primary host fails, same rules apply
'  * notes is a message to deliver with the update
'  * after that all filenames followed by their version (after the equals sign)
'  * file is only downloaded if the previous version is lesser or is missing completely
'  * the filenames can include paths to directorys, but currently no directories are created
'    so the structure must be in place before downloading (the host must have same folder structure)
'  * this updater doesn't check if there actually is a file, it blindly trusts the ini-file



#Include Once "chisock/chisock.bi"

Using chi

Declare Function DownloadFile(filepath As String) As Byte
Declare Function GetFile(filepath As String, serverpath As String, sock As socket) As Byte
Declare Function CountWords(st As String, sep_ As String = " ") As Integer
Declare Function GetWord(st As String, index As Integer, sep_ As String = " ") As String 

Dim As String initxt, row, varkey, varval
Dim Shared As String host, hostpath, backup, backuppath, notes
Dim As Integer i = 0, numFiles = 0, arrSize = 10
Dim As String arrFiles(1 To arrSize, 1)
Dim As Double version = 0
Dim As Byte fileStart = 0, updated = 0, errors = 0

'ScreenRes 640,480

StartUpdate:
Color 9: Print "Reading update info..."
Var f = FreeFile
Open "update.ini" For Input As #f
	If LOF(f) > 0 Then
		Do
			Line Input #f, row
			If row = "" Then Exit Do
			If Trim(row) = "[UPDATE]" Then fileStart = -1: Continue Do
			If fileStart Then
				varkey = Trim(GetWord(row,1,"="))
				varval = Trim(GetWord(row,2,"="))
				Select Case varkey
					Case "version": version = CDbl(varval)
					Case "host"   : host    = Trim(GetWord(varval,1,"/")) : hostpath = varval
					Case "backup" : backup  = Trim(GetWord(varval,1,"/")) : backuppath = varval
					Case "notes"  : notes   = varval
					Case Else
						numFiles+=1
						If numFiles > arrSize Then ReDim Preserve arrFiles(1 To numFiles, 1): arrSize = numFiles
						arrFiles(numFiles,0) = varkey
						arrFiles(numFiles,1) = varval
				End Select
			EndIf
		Loop
	End If
Close f

If hostpath = "" And backuppath = "" Then
	Color 4
	Print !"Corrupted update.ini, aborting!\nTry manually downloading a new one from the software's website."	
	Color 7: Print "Press any key to quit."
	Sleep : End
EndIf


Color 14: Print "Downloading new update info..."
If DownloadFile("update.ini") = 0 Then
	Color 4
	Print "Couldn't download new update.ini!"
	Print
	Color 7
	Print "Aborting, press any key to quit..."
EndIf

Color 9: Print "Analyzing new update info..."
f = FreeFile
Open "update.ini" For Input As #f
	If LOF(f) > 0 Then
		Do
			Line Input #f, row
			If row = "" Then Exit Do
			If row = "[UPDATE]" Then fileStart = -1: Continue Do
			If fileStart Then
				varkey = Trim(GetWord(row,1,"="))
				varval = Trim(GetWord(row,2,"="))
				Select Case varkey
					Case "version"
						If CDbl(varval) <= version And version > 0 Then Exit Do
					Case "host"
						If host <> Trim(GetWord(varval,1,"/")) Then Close f: GoTo StartUpdate
					Case "backup"
						backup = Trim(GetWord(varval,1,"/")) : backuppath = varval
					Case "notes"
						notes = varval
					Case Else
						For i = 1 To numFiles
							If arrFiles(i,0) = varkey Then
								If CDbl(arrFiles(i,1)) < CDbl(varval) Then
									Color 14: Print "Downloading " & varkey
									If DownloadFile(varkey) = 0 Then errors = 1
									updated = -1
								EndIf
								Continue Do
							EndIf
						Next i
						Color 14: Print "Downloading " & varkey
						If DownloadFile(varkey) = 0 Then errors = 1
						updated = -1
				End Select
			EndIf
		Loop
	Else
		Color 4
		Print !"Corrupted update.ini, aborting!\nTry manually downloading a new one from the software's website."	
		Color 7: Print "Press any key to quit."
		Sleep : End
	EndIf
Close #f


If errors > 0 Then
	Color 4: Print "There were error(s)!"
	Color 7: Print "Notes:": Print notes
ElseIf updated = 0 Then
	Color 2: Print "Your software is up-to-date.": Print
	Color 7: Print "Notes for the current version:": Print notes
Else
	Color 2: Print "Your software is now updated.": Print
	Color 4: Print "Notes:": Print notes
EndIf
Color 8
Print
Print "Press any key..."
Sleep
End


Function DownloadFile(filepath As String) As Byte
	Dim As Socket sock
	Dim As String temphost = hostpath
	If sock.client( host, socket.PORT.HTTP ) <> SOCKET_OK Then
		Color  4: Print "Primary host failed!"
		Color 14: Print "Downloading from backup"
		If sock.client( backup, socket.PORT.HTTP ) <> SOCKET_OK Then
			Color 4: Print "Backup host failed, skipping file!"
			Return 0
		EndIf
		Return GetFile(filepath,backuppath,sock)
	EndIf
	If GetFile(filepath,hostpath,sock) <> 0 Then Return -1
	Color  4: Print "Primary host failed!"
	Color 14: Print "Downloading from backup"
	If sock.client( backup, socket.PORT.HTTP ) <> SOCKET_OK Then
		Color 4: Print "Backup host failed, skipping file!"
		Return 0
	EndIf
	Return GetFile(filepath,backuppath,sock)
End Function


Function GetFile(filepath As String, serverpath As String, sock As socket) As Byte
	sock.put_HTTP_request(serverpath & filepath)
	Var the_data = sock.get_until( "" )
	the_data = Mid( the_data, Instr( the_data, chr(13, 10, 13, 10) ) + 4 )
	
	If Len(the_data) > 0 AndAlso InStr( the_data, "Not Found") = 0 AndAlso InStr( the_data, "not found") = 0 Then
		Var ff = FreeFile
		If Open(filepath For Binary Access Write As #ff) <> 0 Then Return 0
			Put #ff, , the_data[0], Len(the_data)
		Close ff
		Return -1
	EndIf
	Return 0	
End Function


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
    st = Trim(st, sep_)
    If Len(st) = 0 Or index <= 0 Or index > CountWords(st,sep_) Then Return ""
    st += sep_
    Do
        If count = index Then wordStart = nextIndex + Len(sep_)
        nextIndex = InStr(nextIndex + Len(sep_), st, sep_)
        count+=1
    Loop Until wordStart <> -1
    Dim As String ret = Mid(st, wordStart, nextIndex-wordStart)
    Return ret
End Function
