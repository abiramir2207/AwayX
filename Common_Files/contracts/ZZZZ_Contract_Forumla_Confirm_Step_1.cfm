
<CFSET URL.CID = FORM.Program_ID>
<CFSET URL.RID = FORM.Rule_ID>



<cf_cryp type="de" key="#request.key#" string="#URL.RID#">
<CFSET Rule_ID = cryp.value>

<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFSET Program_ID = cryp.value>


<CFQUERY NAME="getRuleInfo" datasource="#application.datasource#">
	SELECT Rule_Name, Number_Of_Comms
	FROM Program_Formula_Pricing_Rules
	WHERE
		Program_ID = '#Program_ID#'
		AND
		Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
		AND
		DELETED = 0
</CFQUERY>
<CFIF getRuleInfo.recordCount GT 0>
	<CFSET Form.Original_Rule_Name = getRuleInfo.Rule_Name>
	<CFSET Form.Original_Comm_Count = getRuleInfo.Number_Of_Comms>
<CFELSE>
	
</CFIF>


<CFSET PAGE_TITLE="">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT>
		function submitForm() {
			if(confirm("Press OK to activate this rule.")){
				document.all.MyForm.submit();
			}
		}
	</SCRIPT>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFIF len(URL.CID) EQ 0>
<CFSET temp = 0>
<CFELSE>
<CFSEt temp = cryp.value>
</CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "formula"> 

<CFINCLUDE TEMPLATE="contract_status_legend.cfm">

<BLOCKQUOTE><BLOCKQUOTE>

<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>
<cfinclude template="minimal_contract_info.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	<!--- TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;} --->
	#header {font-size: 12px;}
</style>

<cfoutput>
<Table>
	<TR>
		<TD COLSPAN="2">
			<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
				<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Step 1 - Edit Confirmation</LEGEND>
				<BR>
				<TABLE WIDTH="100%" CELLPADDING="0" CELLSPACING="0" STYLE="font-size : 10px;" BORDER="0">
					<TR>
						<TD WIDTH="50%">
							<TABLE WIDTH="100%" CELLPADDING="5" CELLSPACING="0" STYLE="font-size : 10px;" BORDER="0">
							<CAPTION><b>Current Settings</b></CAPTION>
								<TR>
									<TD ALIGN="right" VALIGN="top"><B>Rule Name</B>&nbsp;:</TD>						
									<TD>#Form.Original_Rule_Name#</TD>
								</TR>
								<TR>
									<TD ALIGN="right" VALIGN="top"><B>Number Of Commodities</B>&nbsp;:</TD>						
									<TD>#Form.Original_Comm_Count#</TD>
								</TR>
							</TABLE>
						</TD>
						<TD BGCOLOR="000080" ROWSPAN="100%" WIDTH="1"><IMG SRC="/images/fill.gif" ALT="" WIDTH="2" HEIGHT="1" BORDER="0"></TD>
						<TD WIDTH="50%">
							<FORM ACTION="Contract_Forumla_Rule_Step_1_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
								<INPUT TYPE="hidden" NAME="UPDATE" ID="UPDATE" VALUE="1">
								<INPUT TYPE="hidden" NAME="Rule_ID" ID="Rule_ID" VALUE="#FORM.Rule_ID#">
								<INPUT TYPE="hidden" NAME="PROGRAM_ID" ID="PROGRAM_ID" VALUE="#URL.CID#">
							<TABLE WIDTH="100%" CELLPADDING="5" CELLSPACING="0" STYLE="font-size : 10px;" BORDER="0">
							<CAPTION><b>Edited To</b></CAPTION>
								<TR>
									<TD ALIGN="right" VALIGN="top"><B>Rule Name</B>&nbsp;:</TD>						
									<TD>
									#Form.Rule_Name#
									<INPUT TYPE="HIDDEN" ID="Rule_Name" NAME="Rule_Name" VALUE="#Form.Rule_Name#">
									</TD>
								</TR>
								<TR>
									<TD ALIGN="right" VALIGN="top"><B>Number Of Commodities</B>&nbsp;:</TD>						
									<TD>
									#Form.Number_Of_Comms#
									<INPUT TYPE="HIDDEN" ID="Number_Of_Comms" NAME="Number_Of_Comms" VALUE="#Form.Number_Of_Comms#">
									<INPUT TYPE="HIDDEN" ID="Original_Comm_Count" NAME="Original_Comm_Count" VALUE="#Form.Original_Comm_Count#">
									</TD>
								</TR>
							</TABLE>
							</FORM>
						</TD>
					</TR>
				</TABLE>				
			</cfoutput>
			</FIELDSET>		
			<BR><BR>
		</TD>
	</TR>
	<TR>
		<TD ALIGN="right">
			<CF_button
				button_name		=	""
				button_caption	=	"cancel"
				button_action	=	"document.all.STEP_1_EDIT.submit();"
				button_type		=	"javascript_link"
				button_width	=	"75"
				button_color	=	"Navy"
				button_tip		=	"cancel"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>			
		</TD>
		<TD ALIGN="left">
			<CF_button
				button_name		=	""
				button_caption	=	"save"
				button_action	=	"document.all.MyForm.submit();"
				button_type		=	"javascript_link"
				button_width	=	"75"
				button_color	=	"Navy"
				button_tip		=	"save"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>			
		</TD>
	</TR>
</TABLE>

<CFOUTPUT>
	<FORM ACTION="Contract_Formula_Rule_Step_1.cfm?CID=#URL.CID#" METHOD="post" NAME="STEP_1_EDIT" ID="STEP_1_EDIT">
		<INPUT TYPE="Hidden" NAME="RID" VALUE="#URL.RID#">
	</FORM>
	<!----
	<FORM ACTION="Contract_Formula_Rule_Step_2.cfm?CID=#URL.CID#" METHOD="post" NAME="STEP_2_EDIT" ID="STEP_2_EDIT">
		<INPUT TYPE="Hidden" NAME="Update" VALUE="1">
		<INPUT TYPE="Hidden" NAME="RULE_ID" VALUE="#URL.RID#">
	</FORM>
	<FORM ACTION="Contract_Formula_Rule_Step_3.cfm?CID=#URL.CID#" METHOD="post" NAME="STEP_3_EDIT" ID="STEP_3_EDIT">
		<INPUT TYPE="Hidden" NAME="Update" VALUE="1">
		<INPUT TYPE="Hidden" NAME="RID" VALUE="#URL.RID#">
	</FORM>
	---->
</CFOUTPUT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>

</BODY>
</HTML>
