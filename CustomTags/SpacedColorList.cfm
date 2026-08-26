<!---
Id: /CustomTags/SpacedColorList.cfm, v1.1.11 12/31/2001 11:39:28 AM dbabbitt
Description: This custom tag produces a list of colors spaced optimally 
             apart from each other to give the highest contrast. 
			 Neither black nor white will ever be chosen.
Example: 

			<CF_SpacedColorList NumberOfColorsNeeded="5">
			<CFOUTPUT><TABLE>
				<CAPTION ALIGN="top">Color Space</CAPTION>
				<TR><CFLOOP 
					INDEX="Variables.MyBGColor" 
					LIST="#Variables.MyBGColorSet#"
				><TD 
					WIDTH="100" 
					HEIGHT="100" 
					BGCOLOR="#Variables.MyBGColor#"
				>&nbsp;</TD></CFLOOP></TR>
			</TABLE></CFOUTPUT>
--->
 
<CFPARAM NAME="Attributes.NumberOfColorsNeeded" TYPE="numeric" DEFAULT="3">
<CFSCRIPT>
	Variables.ColorSpace = 0;
	Variables.AllColors = "FF0000,008000,0000FF,FFFF00,FF00FF,00FFFF,848684,00FF00,848600,C6C7C6,000084,847900,008684,840000,840084";
	if(ListLen(Variables.AllColors) LT Attributes.NumberOfColorsNeeded) {
		Variables.ColorSpace = Round(256/(Attributes.NumberOfColorsNeeded+3));
		Caller.MyBGColorSet = Variables.AllColors;
		Variables.NumberOfColorsFound = ListLen(Variables.AllColors);
		}
	else {
		if(Attributes.NumberOfColorsNeeded GT 0) {
			Caller.MyBGColorSet = Left(Variables.AllColors, (7*Attributes.NumberOfColorsNeeded)-1);
			}
		else {
			Caller.MyBGColorSet = "";
			}
		Variables.NumberOfColorsFound = ListLen(Caller.MyBGColorSet);
		}
	while(Variables.NumberOfColorsFound LT Attributes.NumberOfColorsNeeded) {
		Variables.MyBGColor = "";
		for(RGB = 1; RGB LTE 3; RGB = IncrementValue(RGB)) {
			Variables.MyColor = FormatBaseN(Variables.ColorSpace*RandRange(1, Attributes.NumberOfColorsNeeded), 16);
			Variables.MyBGColor = Variables.MyBGColor & Variables.MyColor;
			}
		Variables.MyBGColor = UCase(Variables.MyBGColor);
		if(NOT ListFindNoCase(Caller.MyBGColorSet, Variables.MyBGColor)) {
			Variables.NumberOfColorsFound = IncrementValue(Variables.NumberOfColorsFound);
			Caller.MyBGColorSet = ListAppend(Caller.MyBGColorSet, Variables.MyBGColor);
			}
		}
</CFSCRIPT>

<!---
	Log: /CustomTags/SpacedColorList.cfm
	Revision 1.1 4/23/2001 10:30:44 PM flopes
	Standardized the first fifteen colors.
	
	Revision 1.0 10/4/00 5:00:20 PM dbabbitt
	This custom tag produces a list of 
	colors spaced optimally apart from each 
	other given the number of colors needed. 
	Neither black nor white will ever be 
	chosen.
	--->