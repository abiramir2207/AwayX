<cfparam name="Attributes.selectedBgColor" 	default="##FFE083">
<cfparam name="Attributes.selectedFontColor" 	default="##000000">
<cfparam name="Attributes.unSelectedBgColor" 	default="##DDDDDD">
<cfparam name="Attributes.unSelectedFontColor" 	default="##000000">
<cfparam name="Attributes.borderColor" 	default="##000000">
<cfparam name="Attributes.borderWidth" 	default="3">
<cfoutput>
<STYLE TYPE="text/css">
TD.headerselected A, TD.headerselected A:Hover, , TD.headerselected A:visited
{
	color: 				#Attributes.selectedFontColor#;
	font-family:		Arial;
	font-size :			11px; 
	font-weight:		bold;
	text-decoration:	none;
}
TD.headernotselected A, TD.headernotselected A:Hover, , TD.headernotselected A:visited
{
	color: 				#Attributes.unSelectedFontColor#;
	font-family:		Arial;
	font-size :			11px; 
	font-weight:		bold;
	text-decoration:	none;
}
TD.headerselected
{
	border-left			: solid #Attributes.borderWidth#px #Attributes.borderColor#;
	border-top			: solid #Attributes.borderWidth#px #Attributes.borderColor#;
	border-right		: solid #Attributes.borderWidth#px #Attributes.borderColor#;
	background-color 	: #Attributes.selectedBgColor#;
	cursor				: pointer;	
	TEXT-TRANSFORM		: uppercase;
}
TD.headernotselected
{
	background-color 	: #Attributes.unSelectedBgColor#;
	border-bottom		: solid #Attributes.borderWidth#px #Attributes.borderColor#;
	cursor				: pointer;	
}
TD.headerspacer
{
	border-bottom		: solid #Attributes.borderWidth#px #Attributes.borderColor#;
}
</STYLE>
</cfoutput>