



















<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- DO NOT CHANGE THIS F!@#$%^&... CODE!!!!														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->












































<cfsetting enablecfoutputonly="yes">
<!--- 
	Phormat written by Isaac Dealey 23-JUN-2000
	Distribute freely without warranty.
	
ATTRIBUTES
	Align	:	The alignment of paragraphs formatted with Phormat.
	
	Class	:	The CSS class of paragraphs formatted with Phormat.
	
	Display	:	YES|NO - If the GeneratedContent is being returned 
				to the calling template, the display of 
				GeneratedContent is suppressed by default. If no
				return variable name is given or the Display 
				attribute is set to YES the GeneratedContend displays.
	
	Return	:	The variable returned to the calling module.
				An empty return attribute (Default "") forces the 
				module to display the GeneratedContent instead of 
				passing a variable back to the calling module.
				
	Scope	:	The variable scope of the returned variable.
				Defaults to "CALLER"
	
	Style	:	An in-line CSS style attribute applied to each 
				paragraph in the GeneratedContent.
--->
<cfparam name="Attributes.Scope" default="CALLER">
<cfparam name="Attributes.Return" default="">
<cfparam name="Attributes.Display" 
	default="#iif(len(Attributes.Return), DE('NO'), DE('YES'))#">
<cfparam name="Attributes.Class" default="">
<cfparam name="Attributes.Align" default="">
<cfparam name="Attributes.Style" default="">
<cfif not ThisTag.HasEndTag>
	<cfoutput>ERROR: CF_Phormat tag must have an end tag.</cfoutput>
	<cfexit method="exittag">
</cfif>
<cfscript>
	switch (ThisTag.ExecutionMode) { 
		case "END": { Content = ThisTag.GeneratedContent; ThisTag.GeneratedContent = ''; OpenString = '';
			if (len(Attributes.Align)) OpenString = Insert(' align="#Attributes.Align#"',OpenString,2); 
			if (len(Attributes.Class)) OpenString = Insert(' class="#Attributes.Class#"',OpenString,2); 
			if (len(Attributes.Style)) OpenString = Insert(' style="#Attributes.Style#"',OpenString,2); 
			CloseString = '<BR>'; Replace = RepeatString('#CloseString##OpenString#,',4);
			Search = '#CHR(10)##CHR(10)#,#CHR(10)##CHR(13)#,#CHR(13)##CHR(10)#,#CHR(13)##CHR(13)#';
			Content = OpenString & ReplaceList(Content,Search,Replace) & CloseString; 
			if (len(Attributes.Return)) { "#Attributes.Scope#.#Attributes.Return#" = Content; } 
			if (Attributes.Display) { writeOutput(Content); }}}
</cfscript>
<cfsetting enablecfoutputonly="no">



<!--- 
This was the original as it came from allaire. I replace the <p> with a blank and the </p> with a <BR>
	switch (ThisTag.ExecutionMode) { 
		case "END": { Content = ThisTag.GeneratedContent; ThisTag.GeneratedContent = ''; OpenString = '<p>';
			if (len(Attributes.Align)) OpenString = Insert(' align="#Attributes.Align#"',OpenString,2); 
			if (len(Attributes.Class)) OpenString = Insert(' class="#Attributes.Class#"',OpenString,2); 
			if (len(Attributes.Style)) OpenString = Insert(' style="#Attributes.Style#"',OpenString,2); 
			CloseString = '</p>'; Replace = RepeatString('#CloseString##OpenString#,',4);
			Search = '#CHR(10)##CHR(10)#,#CHR(10)##CHR(13)#,#CHR(13)##CHR(10)#,#CHR(13)##CHR(13)#';
			Content = OpenString & ReplaceList(Content,Search,Replace) & CloseString; 
			if (len(Attributes.Return)) { "#Attributes.Scope#.#Attributes.Return#" = Content; } 
			if (Attributes.Display) { writeOutput(Content); }}}
 --->


 
 
 
 
 
 
 
 
 
 
 
 






 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 









<!--- 
<!---
	Phormat written by Isaac Dealey 23-JUN-2000
	Distribute freely without warranty.
	
	Description: 
		This custom tag replaces carriage returns, etc. with HTML 
		breaks.
	Attributes
		Align: 
			The alignment of paragraphs formatted with Phormat.
		Class: 
			The CSS class of paragraphs formatted with Phormat.
		Display: 
			YES|NO - If the GeneratedContent is being returned
			to the calling template, the display of
			GeneratedContent is suppressed by default. If no
			return variable name is given or the Display
			attribute is set to YES the GeneratedContend displays.
		Return: 
			The variable returned to the calling module.
			An empty return attribute (Default "") forces the
			module to display the GeneratedContent instead of
			passing a variable back to the calling module.
		Scope: 
			The variable scope of the returned variable.
			Defaults to "CALLER"
		Style: 
			An in-line CSS style attribute applied to each
			paragraph in the GeneratedContent.
	--->

<CFSETTING EnableCFOutputOnly="yes">
<CFPARAM NAME="Attributes.Scope" DEFAULT="CALLER">
<CFPARAM NAME="Attributes.Return" DEFAULT="">
<CFIF Len(Attributes.Return)>
	<CFPARAM NAME="Attributes.Display" DEFAULT="No">
	<CFELSE>
	<CFPARAM NAME="Attributes.Display" DEFAULT="Yes">
</CFIF>
<CFPARAM NAME="Attributes.Class" DEFAULT="">
<CFPARAM NAME="Attributes.Align" DEFAULT="">
<CFPARAM NAME="Attributes.Style" DEFAULT="">
<CFPARAM NAME="Attributes.DisableScripts" DEFAULT="True">
<CFPARAM NAME="Attributes.DisableHTML" DEFAULT="False">
<CFPARAM NAME="Attributes.OpenString" DEFAULT="">
<CFPARAM NAME="Attributes.CloseString" DEFAULT="#Chr(60)#BR#Chr(62)#">

<CFIF NOT ThisTag.HasEndTag>
	<CFOUTPUT>
		ERROR: CF_Phormat tag must have an end tag.
	</CFOUTPUT>
	<CFEXIT METHOD="EXITTAG">
</CFIF>
<CFSCRIPT>
	switch(ThisTag.ExecutionMode) {
		case "End": {
			Content = ThisTag.GeneratedContent;
			ThisTag.GeneratedContent = '';
			OpenString = Attributes.OpenString;
			if(REFind(Chr(60) & '[^' & Chr(62) & ']+' & Chr(62), OpenString)) {
				if(Len(Attributes.Align)) {
					OpenString = Replace(OpenString, Chr(62), ' ALIGN="' & Attributes.Align & '"' & Chr(62), 'ONE');
					}
				if(Len(Attributes.Class)) {
					OpenString = Replace(OpenString, Chr(62), ' CLASS="' & Attributes.Class & '"' & Chr(62), 'ONE');
					}
				if(Len(Attributes.Style)) {
					OpenString = Replace(OpenString, Chr(62), ' STYLE="' & Attributes.Style & '"' & Chr(62), 'ONE');
					}
				}
			CloseString = Attributes.CloseString;
			ScriptString = Chr(60) & 'SCRIPT';
			ScriptsAlreadyDisabled = false;
			if(Attributes.DisableHTML) {
				if(FindNoCase(Chr(60), Content)) {
					Content = ReplaceNoCase(Content, Chr(60), Chr(60) & '!', 'ALL'); 
					ScriptsAlreadyDisabled = true;
					}
				}
			if(Attributes.DisableScripts AND (NOT ScriptsAlreadyDisabled)) {
				if(FindNoCase(ScriptString, Content)) {
					Content = ReplaceNoCase(Content, ScriptString, Insert('!', ScriptString, 2), 'ALL'); 
					}
				}
			Replace = RepeatString(CloseString & OpenString & ', ', 4);
			Search = RepeatString(Chr(10), 2) & ', ' & Chr(10) & Chr(13) & ', ' & Chr(13) & Chr(10) & ', ' & RepeatString(Chr(13), 2);
			Content = OpenString & ReplaceList(Content, Search, Replace) & CloseString; 
			if(Len(Attributes.Return)) {
				SetVariable(Attributes.Scope & '.' & Attributes.Return, Content);
				}
			if(Attributes.Display) {
				writeOutput(Content);
				}
			}
		}
</CFSCRIPT>
<CFSETTING EnableCFOutputOnly="no">

<!---
	Log: /CustomTags/Phormat.cfm
	Revision 2.0 7/24/2001 1:03:03 PM dbabbitt
	Added the open and close string.
	
	Revision 1.2 7/24/2001 12:50:38 AM dbabbitt
	Added the disable html attribute.
	
	Revision 1.1 7/24/2001 12:42:18 AM dbabbitt
	Added the disable scripts attribute.
	
	Revision 1.0 7/24/2001 12:40:05 AM dbabbitt
	Basic functionality established.
	--->

 --->