<!---
Id: /Custom Tags/ProgramSelector.cfm, v1.1.2 11/10/00 4:55:21 PM dbabbitt
Description: This custom tag produces a drop down box containing a 
             SelectName list of programs from the Caller.GetProgramNames 
			 query.
--->

<CFPARAM NAME="Attributes.SelectName" DEFAULT="Program">
<CFPARAM NAME="Attributes.QueryContents" DEFAULT="
SELECT DISTINCT
	A_Program.Program_ID,
	A_Program.Program_Name,
	Agency_Divisions.Division
FROM 
	A_Program INNER JOIN
	Agency_Divisions ON 
	A_Program.Division_ID = Agency_Divisions.Division_ID INNER JOIN
	Agency ON 
	Agency_Divisions.Agency_ID = Agency.Agency_ID
ORDER BY 
	Agency_Divisions.Division,
	A_Program.Program_Name
">
<CFPARAM NAME="Attributes.QueryResults" DEFAULT="">
<CFPARAM NAME="Attributes.SelectMultiple" DEFAULT="True">
<CFPARAM NAME="Attributes.SelectSize" DEFAULT="">
<CFPARAM NAME="Attributes.ProgramID" DEFAULT="0">

<CFSET VARIABLES.ID="#RandRange(111111111, 999999999)#">

<!--- Get program list --->
<CFIF IsQuery(Attributes.QueryResults)>
	<CFSET Caller.GetProgramNames=Attributes.QueryResults>
	<CFELSE>
	<CFQUERY NAME="Caller.GetProgramNames" DATASOURCE="HHSS_DB"DBTYPE="ODBC">#Attributes.QueryContents#</CFQUERY></CFIF>
		
<CFIF NOT Len(Attributes.SelectSize)>
	<CFSET Variables.ProgramIDList="#ValueList(Caller.GetProgramNames.Program_ID)#">
	<CFQUERY NAME="GetProgramIDs" DATASOURCE="HHSS_DB"DBTYPE="ODBC">
SELECT DISTINCT
	A_Program.Program_ID
FROM 
	A_Program
WHERE
	A_Program.Program_ID IN (#Variables.ProgramIDList#)</CFQUERY>
	<CFSET Attributes.SelectSize="#Evaluate('Caller.GetProgramNames.RecordCount+ListLen(GetProgramIDs.Program_ID)+1')#"></CFIF>

<CFOUTPUT><SELECT NAME="#Attributes.SelectName#" SIZE="#Attributes.SelectSize#" ID="ProgramSelector#Variables.ID#" STYLE="font-size:8pt"#IIF(ATTRIBUTES.SELECTMULTIPLE,DE(' TITLE="Use the Ctrl key to select individual programs, use the Shift key to select groups of programs." MULTIPLE'),DE(''))#></CFOUTPUT>
	<!--- 	The code between this CFOUTPUT and the next CFOUTPUT is only outputted once per 
			division, since it is grouped by division --->
	<CFOUTPUT QUERY="Caller.GetProgramNames" GROUP="Division"><OPTGROUP LABEL="#Division#">
		<!--- Remove this next line when optgroup comes in vogue --->
		<OPTION VALUE="0">-- #Division# --</OPTION>
		<!--- Make sure that something is already selected --->
		<CFOUTPUT><OPTION VALUE="#Program_ID#"#IIf(Caller.GetProgramNames.Program_ID EQ Attributes.ProgramID, DE(' SELECTED'), DE(''))#>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#Trim(Program_Name)#</OPTION></CFOUTPUT></OPTGROUP></CFOUTPUT>
	</SELECT>
<!---
	Log: ProgramSelector.cfm
	Revision 1.1 11/10/00 4:49:34 PM dbabbitt
	Now we compute the select size if not 
	given.
	
	Revision 1.0 11/10/00 6:05:18 AM dbabbitt
	This template produces a drop down box
	containing a SelectName list of programs 
	from the QueryName.
	--->

