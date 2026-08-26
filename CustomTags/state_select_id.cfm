<!---
Id: /CustomTags/state_select_id.cfm, v1.1.1 10/26/00 2:54:31 PM dbabbitt
Description: This custom tag output a drop-down menu of all the states 
             in the states table with the user's default set.
Example: 

         <CF_STATE_SELECT_ID FieldName="Program_Address_State_ID" DefaultStateID="#Variables.ProgramState#" Verbose="False" TabIndex="#Variables.TabIndex#">
--->

<CFPARAM NAME="Attributes.FieldName" DEFAULT="State">
<CFPARAM NAME="Attributes.DefaultStateID" DEFAULT="22">
<CFPARAM NAME="Attributes.Verbose" DEFAULT=False>
<CFPARAM NAME="Attributes.TabIndex" TYPE="numeric" DEFAULT="">

<CFIF Len(Attributes.TabIndex)>
	<CFSET Attributes.TabIndex=" TABINDEX=""#Attributes.TabIndex#""">
	<CFELSE></CFIF>

<!--- Retrieve all possible states names for a drop down list. --->
<CFQUERY NAME="SelectAllStates" DATASOURCE="HHSS_DB" DBTYPE="ODBC" BLOCKFACTOR="50">
SELECT
	State_ID,
	StateCode,
	State
FROM States</CFQUERY>

<CFOUTPUT><SELECT NAME="#Attributes.FieldName#"#Attributes.TabIndex#></CFOUTPUT><CFOUTPUT QUERY="SelectAllStates">
	<OPTION VALUE="#SelectAllStates.State_ID#"#IIf(SelectAllStates.State_ID IS Attributes.DefaultStateID, DE(' SELECTED'), DE(''))#>#IIf(Attributes.Verbose, 'SelectAllStates.State', 'SelectAllStates.StateCode')#</OPTION></CFOUTPUT></SELECT>

<!---
	Log: /CustomTags/state_select_id.cfm
	Revision 1.1 10/26/00 2:50:43 PM dbabbitt
	Added tab index.
	
	Revision 1.0 10/26/00 2:26:22 PM dbabbitt
	This custom tag output a drop-down menu 
	of all the states in the states table 
	with the user's default id set.
	--->