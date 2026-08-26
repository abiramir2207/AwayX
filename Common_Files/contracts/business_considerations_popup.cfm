<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Business Considerations</title>
</head>

<body>
<cfparam name ="Business_Considerations" default="">
<cfparam name = "parentformname" default="">
<cfparam name="reject" default="0">
<cfparam name="ProgramAgree" default="0">
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfif isDefined("url.CID")>
	<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
	<CFQUERY NAME="getBusinessConsiderations" datasource="#application.datasource#">
		SELECT Contract_Main_Aux_Data.Comments, is_a_revision,contract_main.contract_main_id
		from
		contract_main inner join
		Contract_Main_Aux_Data on
		Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID
		WHERE Contract_Main.Contract_Main_ID = '#cryp.value#'
	</CFQUERY>
	<cfset Business_Considerations = getBusinessConsiderations.Comments>
</cfif>
<CFIF isdefined("URL.FormName") and URL.FormName NEQ "">
	<cfset parentformname = URL.FormName>
</cfif>
<FORM ACTION="" METHOD="post" NAME="Businessconsiderations" ID="Businessconsiderations">
<cfif parentformname EQ "BrokerApprovalForm" OR parentformname EQ "MyForm" OR parentformname EQ "PostApprovalForm">
	<TABLE>
	<TR>
		<TD valign="top"><b>Business Considerations</b></TD>
		<TD><textarea name="Business_considerations_text" cols=70"" rows="7"><cfoutput>#Business_Considerations#</cfoutput></textarea></TD>
	</TR>
	<tr>
	<TD align="center" colspan="2">
	<CF_button
						button_name		=	"save"
						button_caption	=	"Save"
						button_action	=	"javascript:submitform('save_table');"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"save your comments"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>	
	</TD>
	</tr>
	</TABLE>
<cfelse>
<TABLE align="center">
	<TR>
		<TD align="center"><b><font size="3"> Business Considerations </font></b></TD>
	</TR>
	<TR>
	<TD align="center">
	<cfif Business_Considerations NEQ "">
			<cfoutput><font size="2">#Business_Considerations#</font></cfoutput>
	<cfelse>
			None
	</cfif>
	</TD>
	</TR>
<tr>
<TR>
<TD>&nbsp;</TD>
</TR>
	<TD align="center">
			<CF_button
						button_name		=	"continue"
						button_caption	=	"Continue"
						button_action	=	"javascript:continueapproval('continue_table');"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"save your comments"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>	
</TD>
</TR>
</TABLE>
	
	</cfif>		
</FORM>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<script>

function submitform(disableClickedButtonName)
{
disableButton(disableClickedButtonName, true, false);
<cfif isdefined("URL.FormName") and URL.FormName NEQ "">
opener.document.all.<CFOUTPUT>#ParentFormname#</CFOUTPUT>.Business_considerations.value = this.document.all.Business_considerations_text.value;
if(opener.document.all.<CFOUTPUT>#ParentFormname#</CFOUTPUT>.ProgramAgree){
opener.document.all.<CFOUTPUT>#ParentFormname#</CFOUTPUT>.ProgramAgree.value = <cfoutput>#ProgramAgree#</cfoutput>;
}
<cfif  URL.FormName EQ "MyForm" and reject EQ 1>
opener.document.all.<CFOUTPUT>#ParentFormname#</CFOUTPUT>.action = "program_reject_action.cfm?CID=<cfoutput>#URL.CID#</cfoutput>&User_Id=<cfoutput>#URL.user_id#</cfoutput>";
</cfif>
opener.document.all.<CFOUTPUT>#ParentFormname#</CFOUTPUT>.submit();	
</cfif>
window.close()
}

function continueapproval(disableClickedButtonName)
{
	disableButton(disableClickedButtonName, true, false);
	<cfif appSettings.getpaymenthistoryon() and getBusinessConsiderations.is_a_revision EQ 1 and Get_Profile_Settings.payment_history_alert EQ 1>
	if(confirm("Review Settlement History"))
	{
	opener.NewWindow('/common_files/contracts/view_contract_payment_history.cfm?ContractId=<cfoutput>#getBusinessConsiderations.contract_main_id#</cfoutput>&approval=1','paymenthistorywindow','1150','620','Yes', 'Yes');
	}
	else
	{
	opener.NewWindow('/clause_library/clause_approval.cfm?CID=<cfoutput>#URL.CID#</cfoutput>','name','1150','620','Yes', 'Yes');
	}
	<cfelse>
	opener.NewWindow('/clause_library/clause_approval.cfm?CID=<cfoutput>#URL.CID#</cfoutput>','name','1150','620','Yes', 'Yes');
	</cfif>
	window.close();
	
}

</script>


</body>
</html>
