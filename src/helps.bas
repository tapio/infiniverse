
Sub DrawHelp(vl As Byte)
	#define kc Color RGB(0,0,128)
	#define dc Color RGB(64,32,64)
	Print 
	Print " Help Screen - Controls and Display"
	Print
	Color RGB(0,64,0)
	?:Print " NAVIGATION":?
	If vl <> zDetail Then
		kc: Print !"\tW     \t\t";: dc: Print "Engage main thursters / accelerate":?
		kc: Print !"\tS     \t\t";: dc: Print "Use retro-thursters / decelerate":?
		kc: Print !"\tA, D  \t\t";: dc: Print "Change heading (while main thrusters are online)":?
		kc: Print !"\tArrows\t\t";: dc: Print "Trim position with directional auxiliary thrusters (main thrusters offline)":?
		kc: Print !"\tSpace \t\t";: dc: Print "Dead stop / Enter lower view level (when stopped)":?
		kc: Print !"\tCtrl+X\t\t";: dc: Print "Engage jump drive - go to higher view level":?
		kc: Print !"\tF3    \t\t";: dc: Print "Toggle auto-breaking (automatically slow down when not accelerating)":?
	Else
		kc: Print !"\tArrows\t";: dc: Print "Move around":?
		kc: Print !"\tCtrl+X\t";: dc: Print "Call landing craft - go to higher view level":?
	EndIf 
	Color RGB(100,50,0): ?:Print !"\tBookmarks":?
	kc: Print !"\tCtrl+1...9\t";: dc: Print "Save location":?
	kc: Print !"\t1...9     \t";: dc: Print "Go to location":?
	'kc: Print !"\t \t";: dc: Print "":?
	
	
	If vl = zDetail Then
		Color RGB(0,64,0)
		?:Print " BUILD MODE":?
		kc: Print !"\tB\t\t";: dc: Print "Switch to build mode":?
	EndIf
	Color RGB(0,64,0)
	?:Print " GENERAL":?
	kc: Print !"\tF10\t\t";: dc: Print !"Save screenshot to ""shots/"" -folder":?
	kc: Print !"\tp\t\t";  : dc: Print "Get ping info":?
	kc: Print !"\tF1\t\t"; : dc: Print "Show this help screen (content depends on context)":?
	Color RGB(100,50,0): ?:Print !"\tConsole":?
	kc: Print !"\tt\t\t";  : dc: Print "Open communication console (chat)":?
	kc: Print !"\tEnter\t\t";  : dc: Print "Send message":?
	kc: Print !"\tCtrl+C\t\t";  : dc: Print "Copy text to clipboard":?
	kc: Print !"\tCtrl+V\t\t";  : dc: Print "Paste text from clipboard":?
	
	Print
	Print
	Color RGB(96,96,0)
	?:Print " LEGEND":?
	#define legtab (8*8)
	#define legrow ((CsrLin()-3)*8)
	If vl = zPlanet Or vl = zDetail Then
		dc: Print !"\t\t\tWater, lava":?
		textures(water).DrawTexture(legtab, legrow)
		textures(lava ).DrawTexture(legtab+8, legrow)
		dc: Print !"\t\t\tGround and rocks":?
		textures(ground_cold) .DrawTexture(legtab,    legrow)
		textures(ground_cold2).DrawTexture(legtab+8,  legrow)
		textures(ground_cold3).DrawTexture(legtab+16, legrow)
		textures(ground_base) .DrawTexture(legtab+24, legrow)
		textures(ground_base2).DrawTexture(legtab+32, legrow)
		textures(ground_base3).DrawTexture(legtab+40, legrow)
		textures(ground_warm) .DrawTexture(legtab+48, legrow)
		textures(ground_warm2).DrawTexture(legtab+56, legrow)
		textures(ground_warm3).DrawTexture(legtab+64, legrow)
		dc: Print !"\t\t\tHills, mountains":?
		textures(hill)         .DrawTexture(legtab,    legrow)
		textures(mountain_low) .DrawTexture(legtab+8,  legrow)
		textures(mountain_high).DrawTexture(legtab+16, legrow)
		dc: Print !"\t\t\tVegetation":?
		textures(vegetation_cold      ).DrawTexture(legtab,    legrow)
		textures(vegetation_base      ).DrawTexture(legtab+8,  legrow)
		textures(vegetation_base_humid).DrawTexture(legtab+16, legrow)
		textures(vegetation_warm      ).DrawTexture(legtab+24, legrow)
		textures(vegetation_warm_humid).DrawTexture(legtab+32, legrow)
	ElseIf vl = zSystem Then
		dc: Print !"\tTriangles on the edge of view point to suns and planets."
	ElseIf vl = zStarmap Then
		Color RGB(255,255,255): Print !"\t"+Chr(249)+"*"+Chr(15)+!"\t\t";: dc: Print "Stars (solar systems)":?
		Print !"\t";
		Randomize 4 			'' Potential BUG CAUSE!!!!
		For i As Integer = 1 To 8
			Color CUInt(Rand(1,&hffffff)): Print Chr(219);
		Next i
		dc: Print !"\tNebulae":?
	ElseIf vl = zGalaxy Then
		Color RGB(255,255,255): Print !"\t"+Chr(249)+"*"+!"\t\t";: dc: Print "The Galaxy":?
	EndIf
End Sub


Sub LEETitle()
	Dim As Integer rows = HiWord(Width()), cols = LoWord(Width())
	Dim As Byte workpage
	Do
		ScreenSet workpage, workpage Xor 1
		Cls
		Color RGB(0,0,255)
		PrintCenterScreen "|  |\  |  |--  |  |\  |  |  |  |  |--  |-\  /--  |--", 7
		PrintCenterScreen "|  | \ |  |-   |  | \ |  |  |  |  |-   |_/  \-\  |- ", 8
		PrintCenterScreen "|  |  \|  |    |  |  \|  |   \/   |--  | \  --/  |  ", 9
		PrintCenterScreen "|                                                |-/", 10
		PrintCenterScreen "Lone Explorer Edition" ,11
		PrintCenterScreen "Version " & INF_VERSION ,13
		PrintCenterScreen "(c) Tapio Vierros 2008-2009", rows-1, 24,24,24
		Color RGB(128,128,128)
		PrintCenterScreen "This is a single-player version of Infiniverse, a procedural space exploration game.", 20
		PrintCenterScreen "This program is an early alpha version, designed to be a sneak-peak of things to come.", 23
		PrintCenterScreen "'LEE' is very limited, it doesn't have the advanced features of the main game and you", 25
		PrintCenterScreen "can only travel and explore the incomplete and buggy universe.", 27
		
		PrintCenterScreen "Please do NOT judge Infiniverse based on this version.", 30, 255,0,0
		
		PrintCenterScreen "Happy testing!", 33, 128,255,0
		Sleep 100, 1
		switch(workpage)
	Loop Until InKey <> ""
End Sub
