<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Program Template - EZ Button Settings</title>
  <style>
  table.MainTable { margin:10px 0; }
  table.MainTable tr { line-height:17px; }
  </style>
</head>

<body>
<!---	D36607	--->
	<script type="text/javascript" src="/script/tTip.js"></script>
	<link rel="stylesheet" href="/styles/tTip.css" type="text/css" />
<!---	D36607	--->
<!---D43310 EZ Button max-Rate setting --->
<cfinclude template="/actionFormat.cfm">
<!---D43310 EZ Button max-Rate setting ---> 
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<cfset ThisPage = CGI.SCRIPT_NAME>
<cfset formName = "frmEZButton">

<cfparam name="url.id" 																									default="0">
<cfparam name="filepath" 																							default="">
<cfparam name="form.command" 																				default="">
<cfparam name="form.ezprogram_editcomponent" 												default="1">
<cfparam name="form.discountrebatemaxrateon" 													default="0">
<cfparam name="form.ezbuttonupdatewithlatesttemplatesettingsonrevise" 		default="0">
<cfparam name="form.ezbuttondefaultshowitemrates" 											default="0">
<cfparam name="form.ezbutton_max_rate_consider"												default="0">
<cfparam name="form.Filter_EZButton_Products" 														default="0"><!---63628 --->
<CFSET PAGETITLE = "PROGRAM TEMPLATES: EZ BUTTON">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<cfset vars = StructNew()>

<cfif url.id>

<cfif form.command EQ "save">

		<!---------------------------------------------------------------------------------------------------------------------
			D40005 :: new option was added. DiscountRebateMaxRateOn, has option to display the default rate on the rebate page.
			if DiscountRebateMaxRateOn is off
		  ---------------------------------------------------------------------------------------------------------------------
		--->
		<cfif FORM.DiscountRebateMaxRateOn eq "2">
			<cfset FORM.DiscountRebateMaxRateOn = 1 />
			<cfset FORM.EzButtonDefaultShowItemRates = 1 />
		<cfelse>
			<cfset FORM.EzButtonDefaultShowItemRates = 0 />
		</cfif>
		
		<cfif FORM.DiscountRebateMaxRateOn eq "1">
			<cfset FORM.EzButtonUpdateWithLatestTemplateSettingsOnRevise = 0 />
		</cfif>
		<!--- 
			55147: EZ Button Settings - New Location in Application /Anand Rao/15-Oct-2015 
			Update the EZ_Contract_ID in the from the Program_Control_Panel_Options with 
			EZ_Contract_ID from the EZ_Button_Rate_Setting table.
		--->
		<cfscript>
			vars.EZButtonRateCFC = createObject("component", "components.programs.EZButton_ProgramManager");
			vars.EZButtonRateSettings = vars.EZButtonRateCFC.getEZButtonRates(EZButtonRateID=form.EZButtonRateID);
		</cfscript>
 		<!------ Redirect to next page ----->
		<cfquery name="saveeditcomp_setting" datasource="#application.datasource#">
				update Program_Control_Panel_Options
				set 	EZprogram_editcomponent = #form.EZprogram_editcomponent#
				    	,Discount_Rebate_Max_Rate_On = #FORM.DiscountRebateMaxRateOn#
				    	,EzButton_Update_With_Latest_Template_Settings_On_Revise = #FORM.EzButtonUpdateWithLatestTemplateSettingsOnRevise#
						,EzButton_Enter_Beyond_Max_Rates = <cfif StructKeyExists(FORM, "EZButtonEnterBeyondMaxRates")>1<cfelse>0</cfif><!---dinesh --->
						,EzButton_Default_Show_Item_Rates = #FORM.EzButtonDefaultShowItemRates#
						,EzButton_Auto_Approve_On = <cfif StructKeyExists(FORM, "EzButton_Auto_Approve_On")>1<cfelse>0</cfif>     <!---27333--->
						,EzButton_Max_Rate_Consider = <cfif StructKeyExists(FORM, "maxrateconsider")>#FORM.maxrateconsider#<cfelse>0</cfif><!--- D30064:  Max Rate to consider Rebate and Lump Sum --->
						,Default_rate_equal_to_zero = <cfif StructKeyExists(FORM, "Default_rate_equal_to_zero")>#form.Default_rate_equal_to_zero# <cfelse>0</cfif><!---	36607	--->
						,EZ_Button_Rate_ID = #form.EZButtonRateID# <!--- 55147: EZ Button Settings - New Location in Application /Anand Rao/20-Oct-2015 --->
						,EZ_Contract_ID = #vars.EZButtonRateSettings.EZ_Contract_ID#
						,Filter_EZButton_Products = #form.Filter_EZButton_Products# <!---63628 --->
				WHERE ProgramControl_Panel_Options_ID = #url.id#
		</cfquery>

		<cfset id = url.id>
		<cfset pageName = "EZ_button_settings">
		<cfinclude template="Next_Page.cfm" />

<cfelse>

		<!---Gets application settings--->
		<cfif not isdefined("appSettings")>
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>
		</cfif>
		<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
			<cfset template = templateManager.get(url.id)>
			<cfset template_discounttypes = templateManager.getAllDiscountTypes(url.id)>

		<!------ display header ----->
		<cfset Created_Type = template.getCreatedType()>
		<cfset Generic_Type = template.getGenericType()>
		<cfset Active = template.getActive()>
		<cfset Action = "edit">
		<cfset pageName = "EZ_button_settings">

<cfinclude template="header.cfm">
		<CF_CRYP type="en" string="#val(template.getEZContractId())#" key="#request.key#" return="Enc">
		<CFSET EncryptedCID = Enc.value>

	<script language="javascript">
		function showHideOnAbsMaxChange(iType){
			if(iType == 1){
				document.getElementById('trEzButtonUpdateWithLatestTemplateSettingsOnRevise').style.display='';
				document.getElementById('trMaxRateshouldconsider').style.display='none';//D30064:  Max Rate to consider Rebate and Lump Sum
			}
			else{
				document.getElementById('trEzButtonUpdateWithLatestTemplateSettingsOnRevise').style.display='none';
				document.getElementById('trMaxRateshouldconsider').style.display='';//D30064:  Max Rate to consider Rebate and Lump Sum
			}

		}
	</script>
	<form name="<cfoutput>#formName#</cfoutput>" method="post" action="ez_button_settings.cfm?id=<cfoutput>#url.id#</cfoutput>" style="display:inline;">
  <cfif LockedBy_Current_User EQ 1>
  		<table width ="100%" border="0" cellpadding="0" cellspacing="0" style="margin:10px 0;">
		  		<tr>
				  		<td align="right">
					  		<CF_button
					  			button_name		=	""
					  			button_caption	=	"save and continue"
					  			button_action	=	"submitForm(document.#formName#, 'save');"
					  			button_type		=	"javascript_link"
					  			button_width	=	"150"
					  			button_color	=	"Navy"
					  			button_tip		=	"Continue"
					  			font_color		=	"White"
					  			font_size		=	"12"
					  			font_weight		=	"bold"
					  			>
				  		</td>
		  		</tr>
  		</table>
  </cfif>
<table cellpadding="4" cellspacing="0" border="0" class="MainTable" width="100%">
		<tr bgcolor="FFCE84" valign="bottom">
			<td style="font-size: 12px;font-weight:bold;" align="Left" colspan="100%">
				EZ Button Settings
			</td>
		</tr>
		<cfoutput>
		<tr valign="bottom">
			<td style="font-size: 10px;" align="Left" colspan="100%">
				<cfif val(template.getEZContractId())>
				<a onClick="javaScript: NewWindow(this.href , 'EZ_Button_Settings' , '815' , '700' , 'yes' , 'yes'); return false;" href="/scorecard/program_display.cfm?CID=#EncryptedCID#&EZTemplate=1&display_program=1&forceCachedView=0" target="_blank" style="cursor:pointer">
					#ActionText("view settings")#
				</a>
					<cfelse>
						<span title="Please select a EZ Rate">#ActionText("view settings")#</span>
				</cfif>
			</td>
		</tr>
		</cfoutput>
		<cfset useLakebaseForgetdiscounttypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("template_discounttypes")>
<cfif useLakebaseForgetdiscounttypes>
	<cftry>
		<cfset getdiscounttypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("template_discounttypes", {
				"discount_type_id" = "eq.2"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetdiscounttypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetdiscounttypes>
<cfquery name="getdiscounttypes" dbtype="query">
			SELECT * 
			FROM 		template_discounttypes
			WHERE 	Discount_Type_ID = 2  
		</cfquery>
</cfif>

	    <cfif LockedBy_Current_User EQ 1>
	     	<cfset vars.disabled = "">
	    <cfelse>
	      	<cfset vars.disabled = "disabled">
	    </cfif>

		<cfoutput query="getdiscounttypes">
			<cfif LockedBy_Current_User EQ 1>
				<cfsilent>
					
					<cfif Discount_Type_ID EQ 1>
						<CFIF appSettings.getFixedcomponents_on()>
							<cfset filepath = "/Common_Files/contracts/Contract_Discount_Fixed_Component.cfm?CID=#EncryptedCID#">
						<cfelse>
							<cfset filepath = "/Common_Files/contracts/Contract_Discount_Fixed_Prices.cfm?CID=#EncryptedCID#">
						</CFIF>
					<cfelseif Discount_Type_ID EQ 2>
						<cfset filepath = "/Common_Files/contracts/Contract_Discount_Rebates.cfm?CID=#EncryptedCID#">
					<cfelseif Discount_Type_ID EQ 3>
						<cfset filepath = "/Common_Files/contracts/Contract_Discount_Lump_Sums.cfm?CID=#EncryptedCID#">
					</cfif>
					
				</cfsilent>
		<tr valign="bottom">
			<td style="font-size: 10px;" align="Left" colspan="100%">
			
			<!--- 55147: EZ Button Settings - New Location in Application /Anand Rao/20-Oct-2015 --->
				<!--- <a onClick="javaScript: NewWindow(this.href , 'EZ_Button_Settings' , '830' , '650' , 'yes' , 'yes'); return false;" href="#filepath#&EZTemplate=1" target="_blank">
					#Discount_Type_Desc#
				</a><br>  ---> 
				<br>
				<cfscript>
					vars.EZButtonRateCFC = createObject("component", "components.programs.EZButton_ProgramManager");
					vars.EZButtonRateSettings = vars.EZButtonRateCFC.getEZButtonRates();
				</cfscript>
				 Select an EZ Rate: 
				 <select name="EZButtonRateID" <cfif LockedBy_Current_User EQ 0>disabled</cfif> style="width:225px">
				 	<option value="0">Select an EZ Rate</option>
				 	<cfloop query="vars.EZButtonRateSettings">
				 		<option value="#vars.EZButtonRateSettings.EZ_Button_Rate_ID#" <cfif template.EZ_Button_Rate_ID EQ vars.EZButtonRateSettings.EZ_Button_Rate_ID>selected</cfif>>#vars.EZButtonRateSettings.EZ_Button_Rate_Title#</option>
				 	</cfloop>
				 </select>
				 
				<cfif Discount_Type_ID EQ 2><br />
				 	<input value="0" type="radio" name="DiscountRebateMaxRateOn"   <cfif template.getDiscountRebateMaxRateOn() eq 0>checked</cfif> onclick="showHideOnAbsMaxChange(1);"> Rebates are absolute amounts <br>
				 	<input value="1" type="radio" name="DiscountRebateMaxRateOn"  <cfif template.getDiscountRebateMaxRateOn() eq 1>checked</cfif> onclick="showHideOnAbsMaxChange(2);"> Rebates are max amounts (rates are hidden)<br>
				  	<input value="2" type="radio" name="DiscountRebateMaxRateOn"  <cfif template.getDiscountRebateMaxRateOn() eq 1 AND template.EzButton_Default_Show_Item_Rates eq 1>checked</cfif> onclick="showHideOnAbsMaxChange(2);"> Rebates are max amounts (rates are displayed)<br>
				</cfif>
			</td>
		</tr>
<!--- Not locked by Current User--->
			<cfelse>
				<tr valign="bottom">
				   <td style="font-size: 10px;" align="Left" colspan="100%">
				   		#Discount_Type_Desc#
				    <cfif Discount_Type_ID EQ 2><br />
						<input value="0" type="radio" name="DiscountRebateMaxRateOn"   <cfif template.getDiscountRebateMaxRateOn() eq 0>checked</cfif> disabled> Rebates are absolute amounts <br>
						<input value="1" type="radio" name="DiscountRebateMaxRateOn"  <cfif template.getDiscountRebateMaxRateOn() eq 1>checked</cfif> disabled> Rebates are max amounts (rates are hidden)<br>
				  		<input value="2" type="radio" name="DiscountRebateMaxRateOn"  <cfif template.getDiscountRebateMaxRateOn() eq 1 AND template.EzButton_Default_Show_Item_Rates eq 1>checked</cfif> disabled> Rebates are max amounts (rates are displayed)<br>
				    </cfif>
				    </td>
				</tr>
			</cfif>
		</cfoutput>

<!---
     	Dev Notes: 21553/Anand Rao/25-Mar-10
    	HZ - min/max rates for EZ button
--->
	 <tr valign="bottom"  id="trEzButtonUpdateWithLatestTemplateSettingsOnRevise" <cfif (template.getDiscountRebateMaxRateOn() EQ 1)>style="display:none;"</cfif>>
	   <td style="font-size: 10px;" align="Left" colspan="100%">
	        <input value="0" type="radio" name="EzButtonUpdateWithLatestTemplateSettingsOnRevise" <cfif template.getEzButtonUpdateWithLatestTemplateSettingsOnRevise() EQ 0>checked</cfif> <cfif (LockedBy_Current_User NEQ 1)>DISABLED</cfif>>  Retain program content on Revise <br>
			<input value="1" type="radio" name="EzButtonUpdateWithLatestTemplateSettingsOnRevise" <cfif template.getEzButtonUpdateWithLatestTemplateSettingsOnRevise() EQ 1>checked</cfif> <cfif (LockedBy_Current_User NEQ 1)>DISABLED</cfif>> Update with latest template settings on Revise<br>
	   </td>
	</tr>
<!--- D30064:  Max Rate to consider Rebate and Lump Sum --->
	<tr valign=="bottom" id="trMaxRateshouldconsider"  <cfif (template.getDiscountRebateMaxRateOn() EQ 0)>style="display:none;"</cfif>>
		<td style="font-size: 10px;" align="Left" colspan="100%" valign="top">
			Max Rate should consider
			<select name="maxrateconsider" <cfif LockedBy_Current_User EQ 0>disabled</cfif>>
				<option value="1" <cfif template.EzButton_Max_Rate_Consider EQ 1>selected</cfif>>Rebate Only </option>
				<option value="2" <cfif template.EzButton_Max_Rate_Consider EQ 2>selected</cfif>>Rebate & LumpSum </option>
			</select>
		</td>
	</tr>
<!--- D30064:  Max Rate to consider Rebate and Lump Sum --->
<!---
     	Dev Notes: D25709/Anand Rao/17-Mar-2011
    	EZ button changes
--->


<cfoutput>
	<!--- 63628 :: EZ Button - new template setting to determine if product search filters on EZ Button products START--->
	<tr>
		<td style="font-size: 10px;" align="Left" colspan="100%">
			Filter product search based on EZ Button Products <input type="checkbox" value = 1 name="Filter_EZButton_Products" <cfif template.Filter_EZButton_Products>checked</cfif> #vars.disabled#>
	  	</td>
	</tr>	
	<!--- 63628 :: EZ Button - new template setting to determine if product search filters on EZ Button products END--->
	<tr>
		<td style="font-size: 10px;" align="Left" colspan="100%">
			Auto Approve EZ Button Items <span onmouseout="popUpTip(event,'additional_information');" onmouseover="popUpTip(event,'additional_information');"><img src="/images/help_small.gif" /></span>
		<div id="additional_information" class="tip">
			When this setting is ON, products that are within the template max rate are auto approved.  The profile's margin thresholds are not taken into consideration.
		</div>
            <input type="checkbox" name="EzButton_Auto_Approve_On" <cfif template.EzButton_Auto_Approve_On>checked</cfif> #vars.disabled#>
	  	</td>
	</tr>
<!---	D36607	--->
<!---D43310 :: EZ Button max-Rate setting --->
	<tr>
		<td style="font-size: 10px;" align="Left" colspan="100%">
		Allow users to enter rates greater than max <input type="checkbox" name="EZButtonEnterBeyondMaxRates" <cfif template.EzButton_Enter_Beyond_Max_Rates>checked</cfif> #vars.disabled#>
	  </td>
	</tr>
<!---D43310 :: EZ Button max-Rate setting --->
	<tr>
	<td style="font-size: 10px;" align="Left" colspan="100%">
		Default rate equal to zero
		<span onmouseout="popUpTip(event,'additional_information');" onmouseover="popUpTip(event,'additional_information');"><img src="/images/help_small.gif" /></span>
		<div id="additional_information" class="tip">
			When this setting is checked (On), any product in a program without a rate will be treated as if the rate is $0.00 (zero).  This will result in requiring approval for any rate greater than zero.
		</div>
		<input type="checkbox" value="1" name="Default_rate_equal_to_zero" <cfif template.Default_rate_equal_to_zero>checked</cfif> #vars.disabled#>
	</td>
	</tr>
	<!--- 55147: EZ Button Settings - New Location in Application
			This was moved to Ez Button Rate settings
	--->
	<!--- <tr valign="bottom">
		<td style="font-size: 10px;" align="Left" colspan="100%">
		<a onClick="NewWindow('Ez_button_rates.cfm?TemplateID=#url.id#', 'EZButtonRates', '600', '400', 'Yes', 'Yes')" style="cursor:pointer">
			#ActionText("Download Rates")#
		</a>
		</td>
	</tr> --->
<!---	D36607	--->
	<tr valign="bottom">
		 <td style="font-size: 10px;" align="Left" colspan="100%">
		 <a onClick="NewWindow('Ez_button_Programs.cfm?TemplateID=#url.id#', 'PrgList', '600', '400', 'Yes', 'Yes')" style="cursor:pointer">
		 	#ActionText("Download WIP/RFA programs which do not have latest template settings")#
		 	</a>
		 </td>
	</tr>
<!--- D37181: Easy Button CF Spreadsheet Extract/Anand Rao/08-Apr-2013 --->
	<tr valign="bottom">
		 <td style="font-size: 10px;" align="Left" colspan="100%">
			 <a onClick="NewWindow('Ez_button_Max_rates.cfm?TemplateID=#url.id#', 'EZButtonMaxRates', '600', '400', 'Yes', 'Yes')" style="cursor:pointer">
			 	#ActionText("Download programs and products with rate greater than max rate")#
			</a>
		</td>
	</tr>

</cfoutput>

</table>
	  <!---
        21553/Anand Rao/25-Mar-10
        Found the issue, when the user is on this page, even if the page is not locked,
        he still sees "[Save and Continue]" link adding condition to display it only
        if it is loced by the current user after confirming with Karen.
    --->
  	<cfif LockedBy_Current_User EQ 1>
  		<table align="left" width ="100%" id="oTableButton" border="0" cellpadding="4" cellspacing="0">
	  		<tr>
		  		<td align="center">
		  		<CF_button
		  			button_name		=	""
		  			button_caption	=	"save and continue"
		  			button_action	=	"submitForm(document.#formName#, 'save');"
		  			button_type		=	"javascript_link"
		  			button_width	=	"150"
		  			button_color	=	"Navy"
		  			button_tip		=	"Continue"
		  			font_color		=	"White"
		  			font_size		=	"12"
		  			font_weight		=	"bold"
		  			>
		  		</td>
	  		</tr>
  		</table>
  </cfif>
<cfoutput>
<input type="hidden" name="command" value="#form.command#">
<input type="hidden" name="id" value="#url.id#">
</form>
</cfoutput>
		<script>
		function submitForm(thisForm, sCommand)
		{
			if (thisForm.EZButtonRateID.selectedIndex == 0)
			{
		    	alert("Select a EZ Rate!");
				return false;
			}
				
				thisForm.command.value = sCommand;
				thisForm.submit();
				return false;
				}
		</script>
</cfif>
</cfif>
</body>
</html>