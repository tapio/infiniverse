
Sub DrawHelp(vl As Byte)
	#define kc Color RGB(0,0,64)
	#define dc Color RGB(64,32,64)
	Print 
	Print " Help Screen - Controls and Display"
	Print
	Color RGB(0,64,0)
	Print " NAVIGATION":?
	If vl <> zDetail Then
		kc: Print !"\t W     \t";: dc: Print "Engage main thursters / accelerate":?
		kc: Print !"\t S     \t";: dc: Print "Use retro-thursters / decelerate":?
		kc: Print !"\t A, D  \t";: dc: Print "Change heading (while main thrusters are online)":?
		kc: Print !"\t Arrows\t";: dc: Print "Trim position with directional auxiliary thrusters (main thrusters offline)":?
		kc: Print !"\t Space \t";: dc: Print "Dead stop / Enter lower view level (when stopped)":?
		kc: Print !"\t Ctrl+X\t";: dc: Print "Engage jump drive - go to higher view level":?
		kc: Print !"\t F3    \t";: dc: Print "Toggle auto-break (automatically slow down when not accelerating)":?
	Else
		kc: Print !"\t Arrows\t";: dc: Print "Move around":?
		kc: Print !"\t Ctrl+X\t";: dc: Print "Call landing craft - go to higher view level":?
	EndIf 
	Color RGB(100,50,0): Print !"\t Bookmarks";: dc: Print "":?
	kc: Print !"\t Ctrl+1...9\t";: dc: Print "Save location":?
	kc: Print !"\t 1...9 \t\t";: dc: Print "Go to location":?
	kc: Print !"\t a \t";: dc: Print "":?
	
	If vl = zDetail Then
		Print
		Color RGB(0,64,0)
		Print " BUILD MODE":?
		kc: Print !"\tB     \t";: dc: Print "Switch to build mode":?
	EndIf
	Color RGB(0,64,0)
	Print " GENERAL":?
	kc: Print !"\t t \t";: dc: Print "Open communication console (chat)":?
	kc: Print !"\t p \t";: dc: Print "Get ping info":?
	
	Print
	Print
	Print
	Color RGB(96,96,0)
	Print "LEGEND"
	 
End Sub
