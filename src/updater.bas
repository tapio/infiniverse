' Auto-updater software v0.7
' Dependencies: Chisock socket library
'
' Downloads files from an internet server according to an "update.conf" file
' Works by reading the file into memory, then downloading a new one and
' comparing the sizes and md5 checksums of the files to determine if someone
' needs updating.
'
' update.conf file format
' Example:
'		TODO
' (End of example file)
' Notes follow:
'  * host is the url to the directory where the downloads are situated,
'    trailing forward slash is required!
'  * backup is used if primary host fails, same rules apply
'  * notes is a message to deliver with the update
'  * after that all filenames followed by their version (after the equals sign)
'  * the filenames can include paths to directorys, but currently no directories are created
'    so the structure must be in place before downloading (the host must have same folder structure)
'  * this updater doesn't check if there actually is a file, it blindly trusts the ini-file

#Define update_file "data/update.conf"
#IfDef __FB_LINUX__
 #Define LAUNCH_PROG "infiniverse-client"
#Else
 #Define LAUNCH_PROG "infiniverse-client.exe"
#EndIf
#Define LAUNCH_ARGS "-d"

#Include Once "chisock/chisock.bi"
#Include Once "miscfb/md5.bi"
#Include Once "miscfb/words.bi"
#Include Once "file.bi"


Declare Function DownloadFile(filepath As String) As Integer
Declare Function GetFile(filepath As String, serverpath As String, sock As chi.Socket) As Integer
Declare Function AddSlash(st As String) As String
Declare Sub PrintError(msg As String="")

Dim As String initxt, row, varkey, varval
Dim Shared As String host, hostpath, backuphost, backuphostpath, notes
Dim As Integer i = 0, numFiles = 0, arrSize = 10
Dim As String arrFiles(1 To arrSize, 1)
Dim As Double version = 0
Dim As Integer fileSection = 0, updated = 0, errors = 0

Dim Shared errordesc(1 To 3) As String
errordesc(1) = "File not found at server"
errordesc(2) = "Couldn't open file for writing"
errordesc(3) = "Couldn't connect to hosts"

StartUpdate:
Color 9: Print "Reading update info..."
Var f = FreeFile
If Open(update_file For Input As #f) <> 0 Then PrintError("Couldn't open "+update_file)
	If LOF(f) > 0 Then
		While Not EOF(f)
			Line Input #f, row
			row = Trim(row)
			If row = "" OrElse InStr(Chr(row[0]), Any ";#/-") <> 0 Then Continue While
			If row = "[GENERAL]" Then fileSection = 1: Continue While
			If row = "[NOTES]"   Then fileSection = 2: Continue While
			If row = "[HOSTS]"   Then fileSection = 3: Continue While
			If row = "[FILES]"   Then fileSection = 4: Continue While
			If fileSection = 3 Then
				If Trim(GetWord(row,1,"|")) = "primary" Then
					hostpath = AddSlash(Trim(GetWord(row,2,"|")))
					host = Trim(GetWord(hostpath,1,"/"))
				ElseIf Trim(GetWord(row,1,"|")) = "secondary" Then
					backuphostpath = AddSlash(Trim(GetWord(row,2,"|")))
					backuphost = Trim(GetWord(backuphostpath,1,"/"))				
				EndIf
			EndIf
		Wend
	End If
Close f

If hostpath = "" Then hostpath = backuphostpath: host = backuphost: backuphost= "": backuphostpath= ""
If hostpath = "" And backuphostpath = "" Then _
	PrintError("No update hosts specified in the configuration file!")

Color 14: Print "Downloading new update info..."
If DownloadFile(update_file) <> 0 Then _
	PrintError("Couldn't download new update info!")

Color 9: Print "Analyzing new update info..."
fileSection = 0
f = FreeFile
If Open(update_file For Input As #f) <> 0 Then PrintError("Couldn't open "+update_file)
	If LOF(f) > 0 Then
		While Not EOF(f)
			Line Input #f, row
			row = Trim(row)
			If row = "" OrElse InStr(Chr(row[0]), Any ";#/-") <> 0 Then Continue While
			If row = "[GENERAL]" Then fileSection = 1: Continue While
			If row = "[NOTES]"   Then fileSection = 2: Continue While
			If row = "[HOSTS]"   Then fileSection = 3: Continue While
			If row = "[FILES]"   Then fileSection = 4: Continue While
			If fileSection = 1 Then

			ElseIf fileSection = 2 Then

			ElseIf fileSection = 3 Then
			
			ElseIf fileSection = 4 Then
				Var file_name	= Trim(GetWord(row,1,"|"))
				Var file_size	= CInt(Trim(GetWord(row,2,"|")))
				Var file_md5	= Trim(GetWord(row,3,"|"))
				Var file_path	= AddSlash(Trim(GetWord(row,4,"|")))
				Var file_pak	= Trim(GetWord(row,5,"|"))
				Dim As String file = file_path + file_name
				If FileExists(file) = 0 OrElse FileLen(file) <> file_size OrElse _
					MD5_FromFile(file) <> file_md5 Then
						Color 14: Print "Downloading " & file_name
						If DownloadFile(file) <> 0 Then errors = 1
						updated += 1
				Else
						Color 2: Print file & " up-to-date"
				EndIf
			EndIf
		Wend
	Else
		PrintError("Corrupted config file, aborting!")
	EndIf
Close #f


If errors > 0 Then
	Color 4: Print "There were error(s)!"
	if notes <> "" Then Color 8: Print: Print "Notes:": Print notes
ElseIf updated = 0 Then
	Color 2: Print "Your software is up-to-date."
	If notes <> "" Then Color 8: Print: Print "Notes for the current version:": Print notes
Else
	Color 2: Print "Updated " +Str(updated)+ " files."
	Color 2: Print "Your software is now updated."
	If notes <> "" Then Color 4: Print: Print "Notes:": Print notes
EndIf
Color 7
Print
Print "Press any key..."
Sleep
If errors = 0 Then 
	Color 9: Print "Launching "+LAUNCH_PROG
	Run("./"+LAUNCH_PROG, LAUNCH_ARGS)
EndIf
End




Function DownloadFile(filepath As String) As Integer
	Dim As chi.Socket sock
	Dim check As Integer
	If host="" OrElse sock.client( host, chi.socket.PORT.HTTP ) <> chi.SOCKET_OK Then
		Color  4: Print "  Primary host failed!"
		Color 14: Print "  Downloading from backup"
		If backuphost="" OrElse sock.client( backuphost, chi.socket.PORT.HTTP ) <> chi.SOCKET_OK Then
			Color 4: Print "  Backup host failed, skipping file!"
			Return 3
		EndIf
		check = GetFile(filepath,backuphostpath,sock)
		If check <> 0 Then Color 4: Print "  Download failed! ("+errordesc(check)+")"
		Return check
	EndIf
	check = GetFile(filepath,hostpath,sock)
	If check = 0 Then Return 0
	Color  4: Print "  Primary host failed! ("+errordesc(check)+")"
	Color 14: Print "  Downloading from backup"
	If backuphost="" OrElse sock.client( backuphost, chi.socket.PORT.HTTP ) <> chi.SOCKET_OK Then
		Color 4: Print "  Backup host failed, skipping file!"
		Return 3
	EndIf
	check = GetFile(filepath,backuphostpath,sock)
	If check <> 0 Then Color 4: Print "  Download failed! ("+errordesc(check)+")"
	Return check
End Function


Function GetFile(filepath As String, serverpath As String, sock As chi.Socket) As Integer
	sock.put_HTTP_request(serverpath & filepath)
	Var the_data = sock.get_until( "" )
	Var header = Mid(the_data, 1, Instr( the_data, Chr(13, 10, 13, 10)))
	the_data = Mid( the_data, Instr( the_data, chr(13, 10, 13, 10) ) + 4 )
	'Color 1: Print header
	If Len(the_data) > 0 AndAlso InStr(LCase(header), "not found") = 0 Then
		Var ff = FreeFile
		If Open(filepath For Binary Access Write As #ff) <> 0 Then Return 2
			Put #ff, , the_data[0], Len(the_data)
		Close ff
		Return 0
	EndIf
	Return 1
End Function


Sub PrintError(msg As String="")
	Color 4: Print "Error! " & msg
	Color 7: Print "Press any key to quit."
	Sleep  : End
End Sub

Function AddSlash(st As String) As String
	If st = "" Then Return ""
	If Right(st,1) <> "/" Then Return st & "/"
	Return st
End Function
