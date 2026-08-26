<!---
Id: /CustomTags/state_select_code.cfm, v1.0.1 10/26/00 2:37:52 PM dbabbitt
Description: This custom tag output a drop-down menu of all the states 
             in the states table with the user's default state code set.
Example: 

         <CF_STATE_SELECT_CODE FieldName="Work_State" DefaultStateCode="MA" Verbose="True">
--->

<CFPARAM NAME="Attributes.FieldName" DEFAULT="State">
<CFPARAM NAME="Attributes.DefaultStateCode" DEFAULT="MA">
<CFPARAM NAME="Attributes.Verbose" DEFAULT=False>

<!--- Retrieve all possible states names for a drop down list. --->
<CFQUERY NAME="SelectAllStates" DATASOURCE="HHSS_DB" DBTYPE="ODBC" BLOCKFACTOR="50">
SELECT
	StateCode, 
	State
FROM States</CFQUERY>

<CFOUTPUT><SELECT NAME="#Attributes.FieldName#"><CFOUTPUT QUERY="SelectAllStates">
	<OPTION VALUE="#SelectAllStates.StateCode#"#IIf(SelectAllStates.StateCode IS Attributes.DefaultStateCode, DE(' SELECTED'), DE(''))#>#IIf(Attributes.Verbose, 'SelectAllStates.State', 'SelectAllStates.StateCode')#</OPTION></CFOUTPUT></SELECT></CFOUTPUT>

<!---
	Log: /CustomTags/state_select_code.cfm
	Revision 1.0 10/26/00 2:26:22 PM dbabbitt
	This custom tag output a drop-down menu 
	of all the states in the states table 
	with the user's default state code set.
	--->