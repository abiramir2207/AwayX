<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFSET PAGETITLE = "PRICE PROTECTION">
<cfparam name="form.job_details" default="0">
<cfparam name="form.contractIds" default="">

<cfif form.job_details EQ 0>
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
</cfif>

<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset stStruct = Form>
<cfif form.item_list NEQ "">
	<cfset product_search_list = form.item_list>
<cfelse>
	<cfset product_search_list = form.product_list>
</cfif>
	<cfset stStruct.Operator_List = form.Operator_List>
	<cfset stStruct.product_search_list = product_search_list>
	<cfif appSettings.getSearchSequenceOn()>
	<cfset stStruct.Search_Sequence_ID = form.Search_Sequence_ID>
	<cfset stStruct.eligibleprograms = 1>
	</cfif>
	<cfset priceprotectionManager = CreateObject("component", "components.settings.price_protection.price_protection_manager").init(stStruct)>
	<cfset getPrograms = priceprotectionManager.search()>
	
<cfif getPrograms.recordcount GT 0>
<cfset stStruct.eligibleprograms = 0>
<cfset stStruct.contract_main_ids = Valuelist(getPrograms.contract_main_id)>
<cfset priceprotectionManager = CreateObject("component", "components.settings.price_protection.price_protection_manager").init(stStruct)>
<cfset getnoteligiblePrograms = priceprotectionManager.search()>
<cfset noteligibleprogramslist = Valuelist(getnoteligiblePrograms.contract_main_id)>

	
	<cfquery name="GetProgramsEligible" dbtype="query">
	select distinct contract_title, contract_start_date, contract_end_date,
	contract_number, contract_main_id,contract_status_type_desc from getPrograms
	<cfif listlen(noteligibleprogramslist) GT 0>
	where contract_main_id not in (#noteligibleprogramslist#)
	</cfif>
	</cfquery>
	
<table width="90%" cellpadding="2" cellspacing="0" border="0" class="maintable">

<cfif GetProgramsEligible.recordcount GT 0>
<cfset form.contractIds = Valuelist(GetProgramsEligible.contract_main_id)>
<cfif form.job_details EQ 0>
<FORM ACTION="schedule_price_protection_job.cfm" METHOD="post" NAME="price_protection_schedule" ID="price_protection_schedule" style="display:inline">
<cfoutput>
<TR>
<TD style="font-size:11px"><b>Job Name:</b> 
<INPUT MAXLENGTH="50" type="text" name="price_protection_job_name" size="20" VALUE=""></TD>
<TD style="font-size:11px"><b>Price Protection Rate:</b> 
<INPUT MAXLENGTH="7" type="text" name="price_protection_rate" size="10" VALUE="" onKeyUp="clenseText(this, '.0123456789');"></TD>
<td align="left" style="font-size:11px">
<b>UOM:</b><cf_uom_dropdown
					company_main_id			=	""
					default_option_on		=	"0"
					dropdown_name			=	"price_protection_uom"
					option_text_abbreviated	=	""
					product_type_id			=	""
					program_template_id		=	""
					selected_uom_id			=	""
					text_before_tag_close	=	"STYLE=""width: 100px;"""
					uom_id_exclusion_list	=	"3"
					uom_id_inclusion_list	=	""
				></td>
<td style="font-size:11px;font-weight:bold"><CF_smallLink 
		title = "schedulejob" 
		url = "##"
		parameters = "onClick=""javascript: return schedulejob();"""
	></td>
<td colspan="100%">&nbsp;</td>
</TR>
<INPUT type="Hidden" name="Operator_List" value="#FORM.Operator_List#">
<INPUT TYPE="Hidden" NAME="product_search_list" 		VALUE="#Form.product_search_list#">
<INPUT TYPE="Hidden" NAME="Search_Sequence_ID" 		VALUE="#form.Search_Sequence_ID#">
<INPUT TYPE="Hidden" NAME="contractIds" 		VALUE="#form.contractIds#">
</cfoutput>
</form>
</cfif>
<TR><TD style="font-size:12px" colspan="100%"><b>Eligible Programs</b></TD></TR>
<tr>
	<td bgcolor="FFCE84"><strong>Contract Number</strong></td>
	<td bgcolor="FFCE84"><strong>Contract Title</strong></td>
	<td bgcolor="FFCE84"><strong>Start Date</strong></td>
	<td bgcolor="FFCE84"><strong>End Date</strong></td>
	<td bgcolor="FFCE84"><strong>Status</strong></td>
</tr>
<tr><td colspan="100%"><hr width="100%" color="navy"></td></tr>
<cfoutput query="GetProgramsEligible">
<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
<cf_cryp type="en" string ="#GetProgramsEligible.contract_main_id#" key="#request.key#">
<cfset ContractID = cryp.value>
	<td><A STYLE="cursor:pointer;"
ONCLICK="viewContract('#ContractID#')">#Contract_Number#</A></td>
	<td>#Contract_Title#</td>
	<td>#dateformat(contract_start_date,"mm/dd/yyyy")#</td>
	<td>#dateformat(contract_end_date,"mm/dd/yyyy")#</td>
	<td>#contract_status_type_desc#</td>
</tr>
</cfoutput>
<cfelse>
<TR>
<td colspan="100%">No Eligible Programs Found.</td>
</TR>
</cfif></table>
<cfif getnoteligiblePrograms.recordcount GT 0>
<br><br>
<table width="90%" cellpadding="2" cellspacing="0" border="0" class="maintable">
<TR><TD style="font-size:12px" colspan="100%"><b>Non Eligible Programs</b></TD></TR>
<tr>
	<td bgcolor="FFCE84"><strong>Contract Number</strong></td>
	<td bgcolor="FFCE84"><strong>Contract Title</strong></td>
	<td bgcolor="FFCE84"><strong>Start Date</strong></td>
	<td bgcolor="FFCE84"><strong>End Date</strong></td>
	<td bgcolor="FFCE84"><strong>Status</strong></td>
</tr>
<tr><td colspan="100%"><hr width="100%" color="navy"></td></tr>
<cfoutput query="getnoteligiblePrograms">
<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
<cf_cryp type="en" string ="#getnoteligiblePrograms.contract_main_id#" key="#request.key#">
<cfset ContractID = cryp.value>
	<td><A STYLE="cursor:pointer;"
ONCLICK="viewContract('#ContractID#')">#Contract_Number#</A></td>
	<td>#Contract_Title#</td>
	<td>#dateformat(contract_start_date,"mm/dd/yyyy")#</td>
	<td>#dateformat(contract_end_date,"mm/dd/yyyy")#</td>
	<td>#contract_status_type_desc#</td>
</tr>
</cfoutput>
</table>
</cfif>
<cfelse>
<div align="center">
<SPAN CLASS="Title4">
NO PROGRAMS FOUND</SPAN></div>
</cfif>

<script>
function viewContract(program_id)
{
NewWindow('/scorecard/program_display.cfm?display_program=1&CID='+program_id,'ViewProgram','800','600','Yes', 'Yes');
}
function schedulejob()
{
	if(document.all.price_protection_job_name.value == "")
	{
	alert("You must enter a job name");
	return;
	}
	if(document.all.price_protection_rate.value == "" || document.all.price_protection_rate.value == 0)
	{
	alert("You must enter a price protection rate");
	return;
	}
	price_protection_schedule.submit();
}
</script>
