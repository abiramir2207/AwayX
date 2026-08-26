<!--- claim_mechanics_popup.cfm - Copyright (c) 2004 Blacksmith Applications, Inc. --->
<!---
	Created By:		Tim Ford
	Created Date:	01/20/2005
--->
<!--- more enhancement for mcCain
claim mechanic value is determined by the discount types billback is claiming against
if the discount type of the program is not lump sum and rebate, the claim mechanic will be default program claim mechanics
if the discount type of the program is rebate or lump sum, the claim mechanic value will be for the components claimed by rebate or the components claimed by lump sum
---->

<cfparam name="url.formName" default="" />
<cfparam name="form.formName" default="#url.formName#" />
<cfparam name="url.billBackId" default="0" />
<cfparam name="form.billBackId" default="#url.billBackId#" />

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset billbackProgramManager = CreateObject("component", "components.billback.Programs.BillbackProgramsManager").init() />
<cfset ProgramPaymentType = createObject("component", "components.programs.payment_type.ProgramPaymentType") />
<cfset qGetClaimMechanics = ProgramPaymentType.getBillbackProgramPaymentTypes(form.billBackId) />
<!---set the claim mechanic label in case it changes--->
<cfset claimMechLabel = "Claim Mechanics" />

<cfoutput>
<cfset billbackProgramManager.setBillbackID(form.billBackId) />
<html>
<head>
<script>

	var paymtOpenerFormObj = opener.document.all.#form.formName#;

	function submitBillBackPayment()
	{
		paymtOpenerFormObj.submit();
		window.close();
	}

	function submitClMech()
	{
		document.all.ClMechForm.submit();

	}
</script>
<cfif isdefined("form.paytype")>
	<cfquery datasource="#application.datasource#" name="qUpdPayType">
		Update Billback
		Set payment_type = '#Form.PayType#'
		where Billback_Id = '#Form.billBackId#'
	</cfquery>
<script>submitBillBackPayment();</script>

</cfif>

<cfquery datasource="#application.datasource#" name="QGetValidPayType">
	select payment_type_Id, payment_type_name
	from payment_type
	where deleted = 0 --and is_auto_pay = 1
</cfquery>

<cfquery datasource="#application.datasource#" name="qGetBBPayType">
	select B.payment_type, B.Scheduled_Auto_BB , CM.Contract_Number, CM.contract_title
	from billback B
	 INNER JOIN Billback_Program BP
	 	On BP.Billback_ID = B.Billback_ID
	 INNER JOIN Contract_Main CM
					ON CM.Contract_Main_ID = BP.Program_ID
	where B.Billback_ID = '#billBackId#' and b.deleted = 0 and cm.deleted = 0
</cfquery>
<title>BillBack Claim Mechanism</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</head>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">

<div style="width:250" align="center"><b>#claimMechLabel#</b></div>
<hr align="left" width="250" color="##FFCC66">
<table width="250" border="0" cellpadding="1" cellspacing="0" style="border:thin">
<cfif qGetBBPayType.Scheduled_Auto_BB neq "" and not qGetBBPayType.Scheduled_Auto_BB>
	<cfloop query="qGetClaimMechanics">
		<tr bgcolor="navy">
			<td align="left" style="color:white;" colspan="3"><strong>Program: #contract_number# (#contract_title#)</strong></td>
		</tr>
		<tr bgcolor="ccffcc">
			<td align="right" nowrap colspan="3"><b>#Payment_Type_Name#</b></td>
		</tr>
		<cfif appSettings.Claims_at_Comp_Level>
		<!--- if has rebate, display selected rebate component--->
			<cfset billbackProgramManager.setBillbackProgramID(Contract_Main_ID) />
			<cfset billbackProgramManager.setRealBillbackProgramID(billback_program_id) />
			 <cfif billbackProgramManager.hasRebateCmp() >
				<cfset getRebateCmps = billbackProgramManager.loadRebateComps() >
				<tr bgcolor="999999"><td align="right" style="color:white;" colspan="3"><strong>Claim Mechanics for #Application.RebateLabel# include:</strong></td></tr>
				<cfif getRebateCmps.recordCount eq 0>
					<tr align="right"><td nowrap  style="color:990000" colspan="3"><b>Claim mechanic at the component level does not apply</b></td></tr>
				</cfif>
				<cfloop query="getRebateCmps">
					<tr align="right" bgcolor="ccffcc"><td nowrap align="right" width="50%"><strong>#rebate_claim_mechanics#</strong></td><td width="1px" bgcolor="CCCCCC"></td><td width="50%" nowrap align="right">#Program_Rebates_Component_Name#</td></tr>
				</cfloop>
			</cfif>
		<!--- if has lump sum, display lump sum components --->
			 <cfif billbackProgramManager.hasLumpSumCmp() >
				<cfset getLumpSumCmps = billbackProgramManager.loadLumpSum() >
				<tr bgcolor="999999"><td align="right" style="color:white;" colspan="3"><strong>Claim Mechanics for #Application.LumpsumLabel# include:</strong></td></tr>
				<cfloop query="getLumpSumCmps">
					<tr align="right" bgcolor="ccffcc"><td nowrap align="right" width="50%"><strong>#claim_mechanics#</strong></td><td width="1px" bgcolor="CCCCCC"></td><td align="right" width="50%" nowrap>#Component_Name#</td></tr>
				</cfloop>
			 </cfif>
		 </cfif>
	</cfloop>
<cfelse>
	<tr bgcolor="navy">
				<td align="left" style="color:white;" colspan="3"><strong><cfoutput>Program: #qGetBBPayType.contract_number# (#qGetBBPayType.contract_title#)</cfoutput></strong>
				<!--- IE 10: Form can be either inside a cell ("td") as it is here below OR it has to be outside the table. --->
				<form action="claim_mechanics_popup.cfm?billBackId=#billBackId#" method="POST" name="ClMechForm" id="ClMechForm">
				<input type="Hidden" name="formName" value="#Form.formName#">
				<input type="Hidden" name="billBackId" value="#billBackId#">		
				</form>
				</td>
			</tr>
			<cfloop query="QGetValidPayType">
			<tr bgcolor="ccffcc">
				<td align="left" nowrap colspan="3">&nbsp;
				<input type="Radio" name="PayType" value="#QGetValidPayType.Payment_Type_id#"<cfif qGetBBPayType.payment_type eq QGetValidPayType.Payment_Type_id>checked</cfif>>
				<b>&nbsp;&nbsp;#QGetValidPayType.Payment_Type_Name#</b>&nbsp;
				<!--- <cfoutput>#qGetBBPayType.payment_type# #QGetValidPayType.Payment_Type_id#</cfoutput> ---></td>
				<!--- <td>&nbsp;</td> --->
			</tr>
			</cfloop>
</cfif>
</table>

<p>
<cfif qGetBBPayType.Scheduled_Auto_BB neq "" and not qGetBBPayType.Scheduled_Auto_BB>
<CF_smallLink
	title = "continue"
	url = "##"
	parameters = "onClick=""javascript: submitBillBackPayment();"""
>
<CFELSE>
<CF_smallLink
	title = "continue"
	url = "##"
	parameters = "onClick=""javascript: submitClMech();"""
>
</CFIF>
<CF_smallLink
	title = "cancel"
	url = "##"
	parameters = "onClick=""javascript: window.close();"""
>
</body>
</html>
</cfoutput>