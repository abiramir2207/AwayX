<cfset useLakebaseForGetCodes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_programs_and_gl_reason_codes")>
<cfif useLakebaseForGetCodes>
	<cftry>
		<cfset GetCodes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deduction_programs_and_gl_reason_codes", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCodes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCodes>
<cfquery name="GetCodes" datasource="#application.datasource#">
	SELECT *
	FROM Deduction_programs_and_GL_reason_codes
</cfquery>
</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>General Ledger Code</TITLE>
	<script>
		function initPage() {
			preSelectLastSelectedElement()

		}	
	
		function preSelectLastSelectedElement(){
			if(document.all.reasonCode.value != null) {
				if(document.all.reasonCode.value == window.dialogArguments){
					document.all.reasonCode.checked=true;
				}
			}
			else{
				for(var x=0;x<document.all.reasonCode.length;x++){
					
					if(document.all.reasonCode[x].value == window.dialogArguments){
						document.all.reasonCode[x].checked=true;
					}
				}
			}
		}
		function verifySelection(){
			if(confirm("Press OK To Assign This GL Code To The Deduction.")){
				window.returnValue = event.srcElement;
				window.close();
			}
		else{
			event.srcElement.checked = false;
		}
	}
	
	</script>
</HEAD>
<body bgcolor="White" text="Black" link="Blue" vlink="Blue" alink="Red" onLoad="initPage()">


<style>
	body, table, td
		{font-family: Arial; font-size: 12px;}
	.data
		{font-size: 12px; font-weight: bold}
	select, TEXTAREA
		{width:	200px;font-size: 10px;}
	TEXTAREA
		{width:	400px;font-size: 10px;}

	TABLE.Maintable TD 
		{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	
	Maintable
		{cellspacing: 0;}
	
	header 
		{font-size: 12px;}
</style>

<table border="0" cellspacing="10" cellpadding="0" align="center">
<TR><TD>
<DIV class="title2">
	General Ledger Codes
</DIV>

<HR color="Red" SIZE="1">

<B>To Assign A GL Code To The Deduction: 1) Select the radio button (<input type="Radio">) next to the appropiate GL Code.</B>

<form action="route_for_approval_assign_reason_code_action.cfm" method="post" name="theForm" id="theForm">
<TABLE CELLPADDING="4" CELLSPACING="0" CLASS="maintable">
	<TR VALIGN="bottom" BGCOLOR="#FFCE84">
			<TD ID="header">&nbsp;</TD>
			<TD ID="header"><B>Reason Code</B></TD>
			<TD ID="header"><B>Legacy System Name</B></TD>
			<TD ID="header"><B>Legacy Code</B></TD>
			<TD ID="header"><B>PS Code</B></TD>
			<TD ID="header"><B>Op Unit</B></TD>
			<TD ID="header"><B>Account</B></TD>
			<TD ID="header"><B>Minor</B></TD>
			<TD ID="header"><B>Dept</B></TD>
			<TD ID="header"><B>RC</B></TD>
			<TD ID="header"><B>INTERC</B></TD>
	</TR>
	
	<cfoutput query="GetCodes">
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<TD><input type="radio" name="reasonCode" value="#Deduction_programs_and_GL_reason_code_ID#" GL_Name="#program_name#" onclick="verifySelection()"></TD>
			<!--- <TD><input NAME="deduction_status_codes_id" TYPE="Radio" VALUE="#GetCodes.Deduction_programs_and_GL_reason_code_ID#"></TD> --->
			<TD>#program_name#</TD>
			<TD>#legacy_system_name#</TD>
			<TD>#legacy_database_reason_code#</TD>
			<TD>#peoplesoft_reason_code#</TD>
			<TD>#operating_unit_number#</TD>
			<TD>#numberformat(GL_section_one_number, '000000')#</TD>
			<TD>#numberformat(GL_section_two_number, '000')#</TD>
			<TD>#numberformat(GL_section_three_number, '0000')#</TD>
			<TD>#numberformat(GL_section_four_number, '00000')#</TD>
			<TD>#numberformat(GL_section_five_number, '00000')#</TD>
		</TR>
	</cfoutput>

</TABLE>

</form>
</TD></TR>
</table>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



