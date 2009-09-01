
Sub DrawHelp(vl As Byte)
	#define kc Color RGB(0,0,64)
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
	kc: Print !"\tt\t\t";  : dc: Print "Open communication console (chat)":?
	kc: Print !"\tF10\t\t";: dc: Print !"Save screenshot to ""shots/"" -folder":?
	kc: Print !"\tp\t\t";  : dc: Print "Get ping info":?
	kc: Print !"\tF1\t\t"; : dc: Print "Show this help screen (content depends on context)":?
	
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
		dc: Print "Triangles on the edge of view point to suns and planets."
	ElseIf vl = zStarmap Then
		Color RGB(255,255,255): Print !"\t"+Chr(249)+"*"+Chr(15)+!"\t\t";: dc: Print "Stars (solar systems)":?
	ElseIf vl = zGalaxy Then
		Color RGB(255,255,255): Print !"\t"+Chr(249)+"*"+!"\t\t";: dc: Print "The Galaxy":?
	EndIf
End Sub
