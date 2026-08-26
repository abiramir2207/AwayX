<cfif isdefined("session.programs")>
	<cfif session.programs.properties.CURRENT_PROGRAM_TYPE_ID NEQ 0>
		<form action="select_program_type_action.cfm" method="post" name="frmProgramSelect" id="frmProgramSelect">
			<input type="Hidden" name="Program_ID" value="<cfoutput>#session.programs.properties.CURRENT_PROGRAM_TYPE_ID#</cfoutput>">
		</form>
		<script>
			frmProgramSelect.submit()
		</script>
	<cfabort>
	</cfif>
</cfif>
<br>

<cfset useLakebaseForGetAllPrograms = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForGetAllPrograms>
	<cftry>
		<cfset GetAllPrograms = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"company_main_id" = "eq.#request.AccessStructure.Company_Main_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetAllPrograms = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetAllPrograms>
<cfquery name="GetAllPrograms" datasource="#application.datasource#">
	SELECT *
	FROM Program_Control_Panel_Options
	WHERE Company_Main_ID = '#request.AccessStructure.Company_Main_ID#'
</cfquery>
</cfif>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Select Program Type</title>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<script>
		resetProgramSelection=function(){
			listOfRadios=document.frmProgramSelect.Program_ID
			for(var x=0;x<listOfRadios.length;x++){
				listOfRadios[x].checked = false;
			}
		}
	</script>
</head>

<body onload="resetProgramSelection()">

<form action="select_program_type_action.cfm" method="post" name="frmProgramSelect" id="frmProgramSelect">
<DIV class="title2">Select A Program</DIV>
<HR color="red" SIZE="1">
<table border="1">
<CFIF GetAllPrograms.RecordCount NEQ 0>
	<TR>
		
		<cfoutput>
		<cfloop query="GetAllPrograms">
			<TD valign="middle"><input type="Radio" value="#GetAllPrograms.ProgramControl_Panel_Options_ID#" name="Program_ID" id="Program_ID" onclick="if(confirm('Press OK To Continue With This Program Type')) {document.forms[0].submit()} else{this.checked=false;}">#GetAllPrograms.Created_Type#</TD>
			<cfif NOT currentrow mod 4></TR><TR></cfif>
		</cfloop>
		</cfoutput>
	</TR>
</CFIF>
</table>
</form>


</body>
</html>
