<cfparam name="FORM.PROGRAM_TYPE_ID" default="0">


<cfset FORM.PROGRAM_TYPE_ID = SESSION.PROGRAMS.PROPERTIES.CURRENT_PROGRAM_TYPE_ID>


<cfquery name="getTabFields" datasource="#application.datasource#">
	SELECT * 
	FROM Program_Control_Panel_Options_MAP_TO_Menu_Tab
	WHERE Menu_Tab_ID = '#URL.tab_ID#'
</cfquery>

<cfquery name="getFieldSettings" datasource="#application.datasource#">
	SELECT #ValueList(getTabFields.Program_Control_Panel_Option_Column_Name)# 
	FROM Program_Control_Panel_Options
	WHERE ProgramControl_Panel_Options_ID = '#FORM.PROGRAM_TYPE_ID#'
</cfquery>


<DIV></DIV>
<!--- <cfloop query="getTabFields">
<cfoutput>	#Program_Control_Panel_Option_Column_Name# - #evaluate("getFieldSettings.#Program_Control_Panel_Option_Column_Name#")#<br>
<br>
</cfoutput>
</cfloop>
 --->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>xxxxxxxxxxxxxxxxxxxxxxxxx</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfinclude template="program_number_generator.cfm">

<style>
	.TextInput {
		width: 300px;
	}

	.DataLabelColumn {
		text-align : right;
	}
</style>
<table width="95%" border="0" cellspacing="0" cellpadding="2" align="left">
	<TR>
		<TD class="DataLabelColumn">Program Number</TD>
		<TD rowspan="100%" bgcolor="0000CC" style="width: 2px;"></TD>
		<TD><cfoutput>#generator_program_number#</cfoutput></TD>
	</TR>
	<TR>
		<TD class="DataLabelColumn">Program Reference Number</TD>
		<TD><input type="Text" class="TextInput"></TD>
	</TR>
	<TR>
		<TD class="DataLabelColumn">Program Title</TD>
		<TD><input type="Text" class="TextInput"></TD>
	</TR>
	<TR>
		<TD class="DataLabelColumn">Program Start/Program End</TD>
		<TD nowrap><table width="0" border="0" cellspacing="0" cellpadding="0" align="left"><TR><TD><CF_EASYDATE FORMNAME="MyForm" FIELDNAME="from_date" FORMAT="mm/dd/yyyy" DEFAULT=""></TD><TD><CF_EASYDATE FORMNAME="MyForm" FIELDNAME="end_date" FORMAT="mm/dd/yyyy" DEFAULT=""></TD></TR></table></TD>
	</TR>
	<TR>
		<TD class="DataLabelColumn">Trade Program Eligibility</TD>
		<TD><input type="Checkbox"></TD>
	</TR>
	<TR>
		<TD class="DataLabelColumn">Discount Type</TD>
		<TD><input type="Checkbox"></TD>
	</TR>
	<TR>
		<TD class="DataLabelColumn">Volume Target/Volume Target UOM</TD>
		<TD><input type="Text"><select></select></TD>
	</TR>
	<TR>
		<TD class="DataLabelColumn">Claim Mechanics</TD>
		<TD><input type="radio">off-invoice<BR><input type="radio">Billback Request-<input type="checkbox">Build-Up Invoice<BR><input type="radio">Auto Payment</TD>
	</TR>
	<TR>
		<TD class="DataLabelColumn">Auto Renewal</TD>
		<TD><input type="Checkbox">Automatically Renew&nbsp;<input type="radio">Fixed Margin<input type="radio">Variable Margin<cfoutput>#getFieldSettings.Auto_Renew_Option#</cfoutput></TD>
	</TR>
	<TR>
		<TD class="DataLabelColumn">Communicate Program To</TD>
		<TD><input type="checkbox">Sales&nbsp;<input type="checkbox">Brokers&nbsp;<input type="checkbox"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> - HQ  &nbsp;<input type="checkbox"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> - Local </TD>
	</TR>
	<TR>
		<TD class="DataLabelColumn">Payment Cycle</TD>
		<TD><Select></SELECT></TD>
	</TR>
	<TR>
		<TD class="DataLabelColumn">Performance Requirements</TD>
		<TD>			
			<table>
				<tr>
					<td><input type="checkbox" name="ClaimPerfReq" id="ClaimPerfReq" value="1">Invoice/Billback</td>
					<td><input type="checkbox" name="ClaimPerfReq" id="ClaimPerfReq" value="2">Claim Period</td>
				</tr>
				<tr>
					<td><input type="checkbox" name="ClaimPerfReq" id="ClaimPerfReq" value="3">Total $'s & Lbs</td>
					<td><input type="checkbox" name="ClaimPerfReq" id="ClaimPerfReq" value="4">Total $'s & Lbs</td>
				</tr>
				<tr>
					<td><input type="checkbox" name="ClaimPerfReq" id="ClaimPerfReq" value="5">Menu Listing</td>
					<td><input type="checkbox" name="ClaimPerfReq" id="ClaimPerfReq" value="6">Branded Point of Sale</td>
				</tr>
				<tr>
					<td><input type="checkbox" name="ClaimPerfReq" id="ClaimPerfReq" value="7">Mandated Specification</td>
					<td><input type="checkbox" name="ClaimPerfReq" id="ClaimPerfReq" value="8">Optional Specification</td>
				</tr>
				<tr>
					<td><input type="checkbox" name="ClaimPerfReq" id="ClaimPerfReq" value="9">Feature Sheet Flyer</td>
					<td></td>
				</tr>
			</table>
		
		</TD>
	</TR>
	<TR>
		<TD class="DataLabelColumn"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Brand Eligibility</TD>
		<TD><input type="Radio"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Brands ARE eligible&nbsp;<input type="Radio"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Brands ARE NOT eligible&nbsp;</TD>
	</TR>
	<TR>
		<TD class="DataLabelColumn">Notes</TD>
		<TD><textarea></textarea></TD>
	</TR>
	

</table>





<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



