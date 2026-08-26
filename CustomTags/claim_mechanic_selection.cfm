<!---
Created by Brenda Flynn using payment_cycle_option.cfm as template
January 20, 2005
--->

<!------ claim_mechanic_selection.cfm ----->
<!------ 

<cf_claim_mechanic_selection
			Default_Claim_Selection = "#CSLGetContractInfo.ClaimMechanics#"
			Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
			Edit_Selection = "#FORM.ClaimMechanic#"
			Is_Revision = #CSLGetContractInfo.Is_Revision#
			>
 ----->
<cfsilent>
<cfparam name="Attributes.Default_Claim_Selection" 					default="0">
<cfparam name="Attributes.Template_ID" 								default="0">
<cfparam name="Attributes.Edit_Selection" 							default="0">
<cfparam name="Attributes.Is_Revision" 								default="0">
<cfparam name="Attributes.disabled" 								default="0">
<!--- Default attributes to 1 instead of 0 so it doesn't cause problems for 4.3 where these attributes are not defined --->
<cfparam name="Attributes.Allow_Auto_Payment"						default="1">
<!--- Dev Note: drachala; D28893: Event error DISCOUNT_TYPE_ID argument is not of type numeric  START
Added/Changed: Added 0 as DEFAULt value for Attributes.Discount_Type_ID--->
<cfparam name="Attributes.Component_Name_ID"						default="0">
<cfparam name="Attributes.Discount_Type_ID"							default="0">
<!--- End Dev Note: drachala; D28893: Event error DISCOUNT_TYPE_ID argument is not of type numeric  --->
<cfparam name="Attributes.Allow_Off_Invoice"						default="1">

<cfparam name="Attributes.Auto_Pay"		default="0"><!--- D35731 Growth Auto Pay --->		
<cfparam name="Attributes.ItemsDisabled" 	default="0">

<cfset appSettings = application.appsettingsGet />

<Cfif Attributes.Edit_Selection IS 0 OR len(trim(Attributes.Edit_Selection)) IS 0>
	<cfset Pre_Selected = Attributes.Default_Claim_Selection>
<cfelse>
	<cfset Pre_Selected = Attributes.Edit_Selection>
</CFIF>
<!--- Get Payment types bases on template first, then look at the component level and the Payment_Type tables.
			If the component has off invoice ON, then get all payment types which have Off Invoice On in the Payment Types
			table, else get the ones which have Off Invoice Off.Lumpsum and Growth Components do not have OffInvoice at the
			component level, instead they have it only at the claim mechanism level. Fixed and Rebate have it at component and
			Claim mechanism level.
	--->
<cfset GetPaymentTypesforTemplate = CreateObject("component", "components.programs.payment_type.paymenttype").GetPaymentTypesforTemplate(
		Template_ID = Attributes.Template_ID,
		Discount_Type_ID = Attributes.Discount_Type_ID,
		Component_Name_ID = Attributes.Component_Name_ID,
		Allow_Off_Invoice = Attributes.Allow_Off_Invoice,
		Allow_Auto_Payment = Attributes.Allow_Auto_Payment,
		Auto_Pay = Attributes.Auto_Pay) ><!--- D35731 Growth Auto Pay --->	

</cfsilent>

<!---
D20867: CAG DEV 14770 - FORMSCOPE.VENDOR_MASTER_ID undefined in ARGUMENTS
enableDisableIncludeComponentLink (false) will disable the link "include this rebate component"  
Only in rebate we will disable the link "include this rebate component" when claim mechanics drop down selection is changed.
The link will get re-enabled at the end of the page claim_mech_info.cfm
--->
	<span id="Err_Sp_PaymentCycle"></span>	
	<select name="Claim_Mechanics" id="Claim_Mechanics" class="Claim_Mechanics"<cfif Attributes.disabled EQ 1>disabled</cfif> 
		onchange="calc();if(document.all.bEnableDisableIncludeComponentLink){enableDisableIncludeComponentLink(false);};">
		<cfif GetPaymentTypesforTemplate.Recordcount eq 0>
			<option value="" id='0'>None</option>
		</cfif>
		<cfoutput query="GetPaymentTypesforTemplate">
			<option value="#Payment_Type_ID#" id="#IS_AUTO_PAY#" <cfif Payment_Type_ID eq Pre_Selected>selected</cfif>  <cfif Attributes.ItemsDisabled EQ 1 and Payment_Type_ID NEQ Pre_Selected>disabled</cfif>> #Payment_Type_Name#</option>
		</cfoutput>
	</select>