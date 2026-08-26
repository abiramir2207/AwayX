<!---
Id: /Custom Tags/PeopleSelector.cfm, v3.1.3 9/27/00 4:17:55 PM dbabbitt
Description: This custom tag produces a drop down box
             containing a SelectName list of people 
             from the Caller.GetEmployeeNames query.
--->

<CFPARAM NAME="Attributes.SelectName" DEFAULT="Employee">
<CFPARAM NAME="Attributes.QueryContents" DEFAULT="SELECT DISTINCT A_Program.Program_Name, Users.Name_First, Users.Name_Last, Users.Users_ID FROM Users INNER JOIN A_Program ON Users.program_id = A_Program.Program_ID ORDER BY A_Program.Program_Name, Users.Name_Last, Users.Name_First">
<CFPARAM NAME="Attributes.SelectMultiple" DEFAULT="True">
<CFPARAM NAME="Attributes.SelectSize" DEFAULT="15">
<CFPARAM NAME="Attributes.ProgramID" DEFAULT="0">

<CFSET VARIABLES.ID="#RandRange(111111111, 999999999)#">
<!--- Get employee list - using CachedWithin for performance gain --->
<CFQUERY NAME="Caller.GetEmployeeNames" DATASOURCE="HHSS_DB" CACHEDWITHIN="#CreateTimeSpan(0, 0, 10, 0)#" DBTYPE="ODBC"><CFOUTPUT>
	#Attributes.QueryContents#</CFOUTPUT></CFQUERY>
<CFOUTPUT><SELECT NAME="#Attributes.SelectName#" SIZE="#Attributes.SelectSize#" ID="PeopleSelector#Variables.ID#" STYLE="font-size:8pt"#IIF(ATTRIBUTES.SELECTMULTIPLE,DE(' TITLE="Use the Ctrl key to select individual employees, use the Shift key to select groups of employees." MULTIPLE'),DE(''))#></CFOUTPUT>
	<!--- The code between this CFOUTPUT and the 
		next CFOUTPUT is only outputted once per 
		Program_Name, since it is grouped by 
		Program_Name --->
	<CFOUTPUT QUERY="Caller.GetEmployeeNames" GROUP="Program_Name"><OPTGROUP LABEL="#Program_Name#">
		<!--- Remove this next line when optgroup comes in vogue --->
		<OPTION VALUE="0">-- #Program_Name# --</OPTION>
		<!--- Make sure that something is already selected --->
		<CFOUTPUT><OPTION VALUE="#Users_ID#"#IIF(ATTRIBUTES.SELECTMULTIPLE AND Caller.GetEmployeeNames.Program_ID EQ Attributes.ProgramID,DE(' SELECTED'),DE(''))#>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#Trim(Name_First)# #Trim(Name_Last)#</OPTION></CFOUTPUT></OPTGROUP></CFOUTPUT>
	</SELECT>
<CFIF NOT ATTRIBUTES.SELECTMULTIPLE><SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript"><CFOUTPUT>
	document.all.PeopleSelector#Variables.ID#.options[1].selected = true;</CFOUTPUT></SCRIPT></CFIF>
<!---
	Log: PeopleSelector.cfm
	Revision 3.1 9/27/00 4:09:52 PM dbabbitt
	Now only the attributes program id is 
	selected initially when the select 
	multiple attribute is set to true.
	
	Revision 3.0 9/18/00 9:50:34 AM dbabbitt
	Now you can use the results of the 
	query outside the module.
	
	Revision 2.4 9/15/00 9:47:17 AM dbabbitt
	Now the selector id is more unique.
	
	Revision 2.3 7/11/00 12:37:04 PM dbabbitt
	Added a tool tip about the control and 
	shift keys.
	
	Revision 2.2 2000/04/18 09:37:14 dbabbitt
	Added Attributes.QueryContents.
	
	Revision 2.1 2000/04/17 13:36:57 dbabbitt
	Hardcoded the name of the query. Now 
	must call your query 
	"GetEmployeeNames".
	
	Revision 2.0 2000/04/17 12:21:15 dbabbitt
	Turned it into a custom tag. Now you can 
	call it with CF_PeopleSelector 
	SelectName = "Employee" QueryName = 
	"GetEmployeeNames" SelectMultiple = 
	"True" SelectSize = "15".
	
	Revision 1.1 2000/04/13 11:43:23 dbabbitt
	Added ability to have multiple selects.
	
	Revision 1.0 2000/04/13 11:02:46 dbabbitt
	This template produces a drop down box
	containing a SelectName list of people 
	from the QueryName.
	--->

