<cfif isDefined("stError")>
	<cfset showCompTypeName = "Component name" />
	<script>
	<cfoutput>		
	<cfif stError.bNameExists EQ 2>
		alert("#showCompTypeName# already exists with a different ID.");		
	<cfelseif stError.bNameExists EQ 3>
		alert("Another component exists with the same allowance code.");
	</cfif>
	</cfoutput>
	</script>
</cfif>
<style>
.Orangline
{
	border-right: 2px solid orange;
}
</style>
<cfparam name="form.compExternalID" 	default="">
<cfparam name="form.compName" 	default="">
<cfparam name="form.compType" 	default="1">

<!--- load custom labels for deduction account, payment account --->
<cfinclude template="/common_Files/general_labels.cfm">

<!--- Dev Note: drachala; D28881: Update growth component settings to include additional elements  START
Added/Changed: get credit type details --->
<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBBAutoReport()><!--- if auto pay app switch is ON --->
<cfsilent>
	<cfset qGetCreditTypes = application.oCreditTypeManager.getCreditTypes() />
	<cfset alreadySelectedCreditTypeExclusionList = "" />	
</cfsilent>
</cfif>
<!--- End Dev Note: drachala; D28881: Update growth component settings to include additional elements  --->

<FIELDSET STYLE="padding:10px; width: width:1150px; border: 1px solid Blue;margin-top:10px;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Component Information</LEGEND>
	<!--- Dev Note: drachala; D28881: Update growth component settings to include additional elements  START
Added/Changed: Changed Table width to 100%--->
	<table width="100%" border="0" cellpadding="3" cellspacing="0">
		<!--- <colgroup>
		<col width="30%"></col>
		<col width="30%"></col>
		</colgroup> --->
		<cfoutput>
			<!------ external id ----->
			<cfif application.returned_customer_setting.external_id_on EQ 1>
				<TR>
					<TD ALIGN="right" class="Orangline"><B>#ID.General_Labels_Label#:</B></TD>
					<TD><INPUT NAME="compExternalID" TYPE="text" VALUE="#form.compExternalID#" SIZE="30" MAXLENGTH="50"></TD>
				</TR>
				<!--- D58135 ::  Additional Component info displaye inside program START--->
				<TR>
					<TD ALIGN="right" class="Orangline"><B>Display #ID.General_Labels_Label# on View Program page:</B></TD>			
					<TD><INPUT NAME="displayExternalID" TYPE="checkbox" VALUE="1"></TD>
				</TR>
				<!--- D58135 ::  Additional Component info displaye inside program END--->		
			<cfelse>
				<INPUT NAME="compExternalID" TYPE="hidden" VALUE="#form.compExternalID#">
				<INPUT NAME="displayExternalID" TYPE="hidden" VALUE="#form.displayExternalID#"><!---D58135 --->
			</cfif>
			<TR>
				<TD ALIGN="right" class="Orangline" width="50%"><B>Component Name:</B></TD>
				<TD width="50%"><INPUT NAME="compName" TYPE="text" SIZE="30" MAXLENGTH="25" value="#form.compName#"></TD>
			</TR>	
<!--- Dev Note: drachala; D28881: Update growth component settings to include additional elements  START
Added/Changed: Added Below Form Fields--->
            
            
            
            <!---<cfset Growth_Percent_Option = qGetCompGrowth.Growth_Percent_Option_ID>--->
            
            
            
			<cfset qPercentOptions = compRebate.getPercentOptions() />
			<TR>
				<TD ALIGN="right" class="Orangline"><B>Business rules for percentage rebates - Margin & Auto Pay:
					<CF_SmallHelp width="500" displayShifyX = "-200" imgPath="/Images/i.gif" imgWidth="12" imgHeight="11" dropdownCheck="0">
							<table cellpadding="0" cellspacing="0">	
							<tr><td align="left">		
							<span style="text-decoration:underline">Auto Pay Calculations</span>
							<ul>
							<li>If this option is set to 'Gross Sales', auto pay calculations will be based upon regular invoice records only. The application will not consider additional records such as credits.</li>
							<li>If this option is set to 'Net Sales', you will have the following additional options to select from:
							<ol>
							<li>Auto pay calculations are net of cash discount [yes or no]</li>
							<li>Auto pay calculations are net of freight allowances [yes or no]</li> 
							<li>Auto pay should exclude by credit type [yes or no]</li>
							</ol>
							</li>
							<li>Options ##1 & 2 are applicable only if the client sends the necessary data in their invoice detail file.  The columns in the invoice detail file for the data would be:  Freight_Revenue and Cash_Discount.  Coordination with Blacksmith is needed when implementing this data.</li>
							<li>If option ##3 is set to YES, then, you will select which credit types to exclude.  By default, the application will consider all credit types, eg, the transaction rows the application will use to calculate the amount due will include all records for each eligible customer and item combination.  If you do not wish to net out specific credit types, you should turn the check box on for those to exclude.  Credit types that are excluded will not be considered.</li>
							</ul>
							</td></tr>
							<tr><td align="left">
							<span style="text-decoration:underline">Margin Calculations</span>
							<ul>
							<li>If this option is set to '<span style="text-decoration:underline">Gross Sales</span>', the allowance resolution for percentage-based rebates [eg, converting the percentage offered to a per case and/or per pound equivalent] will consider the <span style="text-decoration:underline">Base Sales</span> [eg, into-stock price] value for the calculation.</li>
							<li>If this option is set to '<span style="text-decoration:underline">Net Sales</span>', the allowance resolution for percentage-based rebates [eg, converting the percentage offered to a per case and/or per pound equivalent] will consider the <span style="text-decoration:underline">Net Sales</span> [eg, into-stock price less other trade and allowances] value for the calculation.</li>
							</ul>
							</td></tr>
							</table>
					</CF_SmallHelp>
				</TD>
				<TD>
			<select name="Growth_Percent_Option" onChange="showHideOptions()">
			<cfloop query="qPercentOptions">
			<option value="#Rebate_Percent_Option_ID#" <cfif Rebate_Percent_Option_ID EQ Growth_Percent_Option>SELECTED</cfif>>#Rebate_Percent_Option_Desc#</option>
			</cfloop>
			</select>					
				</TD>
			</TR>
			<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBBAutoReport()>
			<TR id="id_autopay_netdiscount" style="display:none;">
			<TD ALIGN="right" class="Orangline"><B>Auto pay calculations are net of cash discount:</B>
			</TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Auto_Pay_Net_Of_Cash_Discount"> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Auto_Pay_Net_Of_Cash_Discount" checked>
			</TD>
			</TR>
			<TR id="id_autopay_netfreight" style="display:none;">
			<TD ALIGN="right" class="Orangline"><B>Auto pay calculations are net of freight allowances:</B>
			</TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Auto_Pay_Net_Of_Freight_Allowance"> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Auto_Pay_Net_Of_Freight_Allowance" checked>
			</TD>
			</TR>
			<TR id="id_autopay_excludecredit" style="display:none;">
			<TD ALIGN="right" class="Orangline"><B>Auto pay should exclude by credit type:</B>
			</TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Auto_Pay_Exclude_Credit_Type" checked  onClick="showHideOptions()"> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Auto_Pay_Exclude_Credit_Type" onClick="showHideOptions()">
			</TD>
			</TR>
					<cfsilent>
		<cfset divHeight = qGetCreditTypes.recordCount * 20 />
		<cfif divHeight gt 100>
			<cfset divHeight = 100 />
		</cfif>		
		</cfsilent>

		<cfinclude template="../inc_credit_types.cfm" />
		</cfif>
		<!--- Accrual --->
		<cfif appSettings.getShow_Component_Accrual()>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Accrual On:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Accrual_On" checked> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Accrual_On">
			</TD>
		</TR>
		<cfelse>
		<input type="hidden" name="Accrual_On" value ="0">
		</cfif>
		
		<!--- Brokerage --->
		<cfif appSettings.getBrokerage_Functionality_On()>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Exclude Brokerage:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Exclude_Brokerage" checked> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Exclude_Brokerage" >
			</TD>
		</TR>
		<cfelse>
		<input type="hidden" name="Exclude_Brokerage" value ="0">
		</cfif>

		<!--- D17171 Optional Payment and Deduction account information --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>#general_labels[ deduction_account ]#: <CF_SmallHelp
					width="300"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
				<center>This is optional information. If you do not know what value to enter here, leave this blank.</center>
				</CF_SmallHelp></B></TD>
			
			<TD><INPUT NAME="Deduction_Account" TYPE="text" VALUE="" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Display #general_labels[ deduction_account ]# on View Program page:</B></TD>			
			<TD><INPUT NAME="displayDeductionAccount" TYPE="checkbox" VALUE="1"></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program END--->		
		<TR>
			<TD ALIGN="right" class="Orangline"><B>#general_labels[ payment_account ]#: <CF_SmallHelp
					width="300"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
				<center>This is optional information. If you do not know what value to enter here, leave this blank.</center>
				</CF_SmallHelp></B></TD>
			
			<TD><INPUT NAME="Payment_Account" TYPE="text" VALUE="" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Display #general_labels[ payment_account ]# on View Program page:</B></TD>			
			<TD><INPUT NAME="displayPaymentAccount" TYPE="checkbox" VALUE="1"></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program END--->		
		<!--- End account info --->

		<!--- PROGRAM INTERFACE LOCK --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Program Interface Lock:</B></TD>	
			<TD>
				<cfif application.appsettingsget.getProgramLockTypeID() EQ 0>
				No <CF_SmallHelp
							width="300"
							displayShifyX = "-200"
							imgPath="/images/i.gif"
							imgWidth="12"
							imgHeight="11"
							dropdownCheck="0"
					>
				<center>The setting called Program Lock Type is set to 'Do Not Lock', therefore you cannot change this setting.</center>
				</CF_SmallHelp>
				<input type="hidden"  name = "Program_Lock_Type_ID"  value= "0" />
				<cfelse>
					No<input type="radio" name="Program_Lock_Type_ID" value="0" checked>&nbsp;
					Yes <input type="radio" name="Program_Lock_Type_ID" value="<cfoutput>#application.appsettingsget.getProgramLockTypeID()#</cfoutput>">
				</cfif>
			</TD>
		<TR>
		<!--- PROGRAM INTERFACE LOCK --->
		
		<!--- Operating Group --->
		<cfif operatingGroupOn>
				<TR>
					<TD ALIGN="right" class="Orangline"><B>#operatingGroupManager.getLabel(operatingGroupLevel)#:</B></TD>
					<TD>
					<cfset qGetOperatingGroups = operatingGroupManager.get(level = operatingGroupLevel, active = 1) />
					<select name="Operating_Group_ID" style="width:200px">
						<cfloop query="qGetOperatingGroups">
						<option value="#Operating_Group_ID#">#Operating_Group_Number# : #Operating_Group_Desc#</option>
						</cfloop>
					</select>
					</TD>
				</TR>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Allowance Code:</B></TD>
			<TD>
			<cfsilent>
			<cfset qGetAllowanceCodes = allowanceCodeManager.getAllowanceCodes() />
			<!------ going to re-use the code to get list of all component names for diffent discount types ----->
			<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
			<cfset discountTypeList = templateManager.getComponentDiscountTypeList() />
			<cfset qGetAllTemplateDiscountComponents = templateManager.getAllTemplateDiscountComponents(0, discountTypeList, 0,0,0,0,0) />	
			<cfset usedAllowanceCodes = ValueList(qGetAllTemplateDiscountComponents.Allowance_Code_ID) />
			<cfset anyAllowanceCodeAvailable = 0 />
			</cfsilent>
			<select name="Allowance_Code_ID" style="width:200px">
				<option value="0">Select Allowance Code</option>
				<cfloop query="qGetAllowanceCodes">
				<cfif NOT ListFindNOCase(usedAllowanceCodes, Allowance_Code_ID)>
				<cfset anyAllowanceCodeAvailable = 1 />
				<option value="#Allowance_Code_ID#" <cfif form.Allowance_Code_ID EQ Allowance_Code_ID>selected</cfif>>#Allowance_Code_Number# : #Allowance_Code_Desc#</option>
				</cfif>
				</cfloop>
			</select>
			<cfif anyAllowanceCodeAvailable EQ 0>			
			<font color="red">No allowance code available.</font>
			</cfif>
			</TD>
		</TR>
		</cfif>
		<cfif appSettings.getGL_Account_On()>
		<cfset useLakebaseForGLQuery = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_account")>
<cfif useLakebaseForGLQuery>
	<cftry>
		<cfset GLQuery = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_account", {
				"deleted" = "eq.0",
				"is_active" = "eq.1",
				"select" = "gl_account,gl_account_desc,gl_account_id"
			}), "gl_account,gl_account_desc,gl_account_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGLQuery = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGLQuery>
<cfquery name="GLQuery" datasource="#application.datasource#">
			SELECT GL_Account, GL_Account_Desc, GL_Account_ID
			FROM GL_Account
			WHERE Deleted = 0
			AND Is_Active = 1
		</cfquery>
</cfif>	
		<cfif GLQuery.recordCount GT 1>			
		<TR id="ShowGLSearch" >
			<td ALIGN="right" class="Orangline"><strong><cfoutput>#Application.GLAccountLabel#</cfoutput>s</strong></td><!---D42774 --->
			<td><CF_button
					button_name		=	""
					button_caption	=	"Search for GLs"
					button_action	=	"return searchGL('','add');"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				></td>
		</TR>
			
		<tr id="ShowGLInfo" style="display: none">
		<td align="right" valign="top" class="Orangline"><strong>Current GLs</strong></td>
		<td>
			<cfdiv bind="url:/settings/GL_Account/componentGL.cfm?GLList={GLList}" ID="compInfo"/>
			<input name="GLList" type="hidden" value="">
		</td>
		</tr>
		<cfelse>
			<tr>
			<td align="right" valign="top" class="Orangline"><strong>Current GLs</strong></td>
			<td>
				#GLQuery.GL_Account# (#GLQuery.GL_Account_Desc#)
				<input name="GLList" type="hidden" value="#GLQuery.GL_Account_ID#">
			</td>
			</tr>		
		</cfif>		
		</cfif>

		<input type="hidden" name="Component_ID" value="">
		<input name="ExistingGLList" type="hidden" value="">
		</cfoutput>	
		
		<!---95126 START--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>TPO Field:</B></TD>
			<TD>
				<select name="TPO_Field" style="width:200px">
					<option value="0">None</option>
					<option value="1">EDLP</option>
					<option value="2">Promo Event</option>
				</select>
			</TD>
			</TR>
			<TR>
			<TD ALIGN="right" class="Orangline"><B>TPO Rate Type:</B></TD>
			<TD>
			<select name="TPO_Rate_Type" style="width:200px">
				<option value="0">None</option>
				<option value="1">Base Rate</option>
				<option value="2">OI Rate</option>
				<option value="3">BB Rate</option>
				<option value="4">Scan Rate</option>
				<option value="5">Lump Sum</option>			
			</select>
			</TD>	
		</TR>	
		<!---95126 END--->		
		
		<!--- ***************************** select templates ***************************** --->
		<TR>
		<TD colspan="100%">
		<cfset component_select_templates_component_id = -1 />
		<cfset component_select_templates_discount_type_id = 4 />
		<cfinclude template="/program_wizard/component_select_templates_grid.cfm" />
		</TD>
		</TR>
		
		<!--- ***************************** select Auto Pay Transaction Filters ***************************** --->
		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBBAutoReport()>  <!--- if auto pay app switch is ON --->
		<TR>			
		<TD colspan="2">
			
		<cfset maxCols = 1 />
		<cfset tdWidth = 100/maxCols />
		<CFSCRIPT>
		Border="Yes";
		BorderSize=1;  
		BorderColor="orange";
		Image="/images/plus3.gif";
		ImageOpen="/images/minus3.gif";
		TitleColor="Blue"; 
		TitleFont="Arial";
		TitleSize=9;
		IsClosed="No";
		</CFSCRIPT>
		
		<CF_OPENLAYER
			BORDER="#Border#"							BORDERSIZE="#BorderSize#"  
			BORDERCOLOR="#BorderColor#"					IMAGE="#Image#"
			IMAGEOPEN="#ImageOpen#"						TITLE="Select the transaction types to INCLUDE in Auto Pay calculations"  
			TITLECLOSED="Select the transaction types to INCLUDE in Auto Pay calculations"	TITLETOOLTIP="Click here to toggle view"  
			TITLECOLOR="#TitleColor#"					TITLEFONT="#TitleFont#"
			TITLESIZE="#TitleSize#"						ISCLOSED="#IsClosed#">
		
		<cfset componentNameId = 0 />			
		<cfset discountTypeId = 4 />
		
		<!--- Payee = Distributor --->
		<cfset payeeTypeId = 1 />
		<cfinclude template="/settings/program_component_fob_price_indicator_select.cfm" />
		
		<!--- Payee = Operator --->
		<cfset payeeTypeId = 2 />
		<cfinclude template="/settings/program_component_fob_price_indicator_select.cfm" />
		
		<!--- Payee = Broker --->
		<cfset payeeTypeId = 3 />
		<cfinclude template="/settings/program_component_fob_price_indicator_select.cfm" />
		
		</CF_OPENLAYER>
		</TD>
		</TR>
		</cfif> <!--- if auto pay app switch is ON --->
		
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Add"
					button_action	=	"return checkData('4','');"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</TD>
		</TR>
	</table>
	
	<script>
	///////////////////////////////////   Update Component //////////////////////////////////////////
	function addComp()
	{
	
		var actionFrm = document.DataForm;
	
		if (trim(actionFrm.compName.value) == "")
		{
			alert("Please provide a component name");
			return;
		}
		if (actionFrm.Allowance_Code_ID)
		{
			if (trim(actionFrm.Allowance_Code_ID.value) == "0")
			{
				alert("Please select an allowance code");
				return;
			}
		}		
		<cfif appSettings.getGL_Account_On() AND appSettings.getGL_ACCOUNT_REQUIRED_FOR_COMP()>
		
		if (trim(actionFrm.GLList.value) == "" )
			{
				alert("Please add at least one <cfoutput>#Application.GLAccountLabel#</cfoutput>");//D42774
				return false;
			}
		</cfif> 
		
		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBBAutoReport()>
		<cfoutput>
		if(anyFOBSelected(1) == 0) // payee = distributor
		{
			alert("Please select the transaction types to INCLUDE in Auto Pay calculations for payee = #application.returned_customer_setting.distributor_label_singular#");
			return false;
		}
		if(anyFOBSelected(2) == 0) // payee = operator
		{
			alert("Please select the transaction types to INCLUDE in Auto Pay calculations for payee = #application.returned_customer_setting.operator_label_singular#");
			return false;
		}
		if(anyFOBSelected(3) == 0) // payee = broker
		{
			alert("Please select the transaction types to INCLUDE in Auto Pay calculations for payee = #application.returned_customer_setting.broker_label_singular#");
			return false;
		}
		</cfoutput>
		</cfif>
		
		//set hidden form fields and submit
		actionFrm.command.value = 'addComp';
		actionFrm.display.value = 'active';
		actionFrm.submit();
		$("#msgSave").append("<p>Saving changes, please wait...</p>");
		return false;	
	
	}

<cfinclude template="../credit_type_js.cfm" />
</script>
</FIELDSET>