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
