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
<cfset fixedComponentTypeObj = CreateObject("component", "components.programs.Fixed.FixedComponent") />

<cfset fixedComponentTypeList = fixedComponentTypeObj.getFixedComponentType()>

<cfparam name="form.compExternalID" 	default="">
<cfparam name="form.compName" 	default="">
<cfparam name="form.compType" 	default="1">
<cfparam name="form.useFixedPriceType" default="0">

<!---D79237:  Fixed Price - OI and Redi START---->
	<cfset qGetALLCompFixedPrice = compFixed.getActive()>
	<cfset useLakebaseForqGetActiveComps = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetallcompfixedprice")>
<cfif useLakebaseForqGetActiveComps>
	<cftry>
		<cfset qGetActiveComps = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetallcompfixedprice", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetActiveComps = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetActiveComps>
<cfquery name="qGetActiveComps" dbtype="query">
		SELECT *
		FROM qGetALLCompFixedPrice
	</cfquery>
</cfif>
<!---D79237:  Fixed Price - OI and Redi END---->

<!--- load custom labels for deduction account, payment account --->
<cfinclude template="/common_Files/general_labels.cfm">

<FIELDSET STYLE="padding:10px; width:1150px; border: 1px solid Blue;margin-top:10px;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Component Information</LEGEND>
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
			<TD><INPUT NAME="compExternalID" TYPE="text" VALUE="" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Display #ID.General_Labels_Label# on View Program page:</B></TD>
			<TD><INPUT NAME="displayExternalID" TYPE="checkbox" VALUE="1"></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program END--->
		<cfelse>
			<INPUT NAME="compExternalID" TYPE="hidden" VALUE="">
			<INPUT NAME="displayExternalID" TYPE="hidden" VALUE="#form.displayExternalID#"><!---D58135 --->
		</cfif>

		<TR>
			<TD ALIGN="right" class="Orangline" width="30%"><B>Component Name:</B></TD>
			<TD width="70%"><INPUT NAME="compName" TYPE="text" MAXLENGTH="50" value="#form.compName#" style="width:220px"></TD>
		</TR>

		<tr>
		  <td align="right" class="Orangline"><b>View Program Display Name:</b></td>
		  <td><input name="program_summary_display_name"
		  		     type="text"
		  		     maxlength="50"
		  		     style="width:220px">
		 </td>
		</tr>
		</cfoutput>
		<TR>
			<TD ALIGN="right" valign="bottom" class="Orangline"><B>Component Type:</B></TD>
			<TD valign="bottom">
			<cfoutput query="fixedComponentTypeList">
				<cfif appSettings.get_Setting('Custom_RFP_Process',0) EQ 1  AND Delivery_Type_ID GT 4>	<!--- CUSTOM RFP ONLY USES Delivery_Type_ID 5+ --->
					<INPUT NAME="compType" TYPE="radio" value="#Delivery_Type_ID#" <cfif Delivery_Type_ID eq 1>checked</cfif>>#Delivery_Type_Desc#
				<cfelseif appSettings.get_Setting('Custom_RFP_Process',0) EQ 0 >
					<INPUT NAME="compType" TYPE="radio" value="#Delivery_Type_ID#" <cfif Delivery_Type_ID eq 1>checked</cfif>>#Delivery_Type_Desc#
				</cfif>
			</cfoutput>
			</TD>
		</TR>
		<cfoutput>
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

		<!--- Floor Pricing --->
		<cfif appSettings.getShow_Component_Floor_Pricing()>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Floor Pricing On:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Floor_Pricing_On" checked> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Floor_Pricing_On">
			</TD>
		</TR>
		<cfelse>
		<input type="hidden" name="Floor_Pricing_On" value ="0">
		</cfif>

		<TR>
			<TD ALIGN="right" class="Orangline"><B>Off Invoice On:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Off_Invoice_On" checked> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Off_Invoice_On">
			</TD>
		</TR>
	<!--- D41867 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work  START --->
		<TR>
			<TD ALIGN="right" class="Orangline">
        		<B>Update BB Expected Rate:
				<CF_SmallHelp
					width="350"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
				<center>When this is ON, in the billback rate pop up window you will see a row called Override Rate with the appropriate rate it is adding/subtracting.</center>
				</CF_SmallHelp>
				</B><br>
            </TD>
			<TD>
				No &nbsp;<input type="radio" onclick="Toggle('hide','ExpectedRateTR')" value="0" name="Update_BB_Expected_Rate" checked> &nbsp;&nbsp;
				Yes <input type="radio" onclick="Toggle('show','ExpectedRateTR')" value="1" name="Update_BB_Expected_Rate">
			</TD>
		</TR>
<!---  62455 :: Fixed Price Components - Additional Drop Down for Fixed Price Type START --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Fixed Price Type:</B></TD>
			<TD>
			<select name="FP_Type">
				<option value="0">None</option>
				<option value="1">Max Volume Fixed Price</option>
			</select>
			</TD>
		</TR>
		<!---D79237:  Fixed Price - OI and Redi START--->
		<cfif appSettings.get_Setting('Include_Second_Component_Feature') eq '1'>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Include 2nd Component With Same Rates:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Include_Second_Component"  class="Include_Second_Component" checked onclick="$('.SecondCompNameId').hide();">
				&nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Include_Second_Component"  class="Include_Second_Component" onclick="$('.SecondCompNameId').show();">
			</TD>
		</TR>
		</cfif>
		<TR class="SecondCompNameId" style="display:none;">
			<TD ALIGN="right" class="Orangline">&nbsp;</TD>
			<TD>2nd #Application.FixedPriceLabel# Component:<br />
				<select name="Second_Component_Name_ID" id="Second_Component_Name_ID" style="width:200px;">
					<option value="0">Select one option</option>
					<cfloop query="qGetActiveComps">
					<option value="#Program_Fixed_Component_Name_ID#">#Program_Fixed_Component_Name#</option>
					</cfloop>
				</select>
			</TD>
		</TR>
		<TR class="SecondCompNameId" style="display:none;">
			<TD ALIGN="right" class="Orangline">&nbsp;</TD>
			<TD>2nd Component Payment Cycle:<br />
				<select name="Second_Component_Payment_Cycle_ID" id="Second_Component_Payment_Cycle_ID" style="width:200px;">
					<option value="0">Select one option</option>
					<cfloop query="qGetPaymentCycles">
					<option value="#Payment_Cycle_ID#">#Payment_Cycle#</option>
					</cfloop>
				</select>
			</TD>
		</TR>
		<TR class="SecondCompNameId" style="display:none;">
			<TD ALIGN="right" class="Orangline">&nbsp;</TD>
			<TD>2nd Component Claim Mechanic:<br />
			<select name="Second_Component_Payment_Type_ID" id="Second_Component_Payment_Type_ID" style="width:200px;">
					<option value="0">Select one option</option>
					<cfloop query="GetClaimMechInfo">
					<option value="#Payment_Type_ID#">#Payment_Type_Name#</option>
					</cfloop>
				</select>
			</TD>
		</TR>
		<cfif appsettings.getGL_Account_On() IS 1>
		<TR class="SecondCompNameId" style="display:none;">
			<TD ALIGN="right" class="Orangline">&nbsp;</TD>
			<TD>2nd Component GL Account:<br />
				<select name="Second_Component_GL_Account_ID" id="Second_Component_GL_Account_ID" style="width:200px;">
						<option value="0" SELECTED>Select one option</option>
					<cfloop query="qGetGLs">
						<option value="#GL_Account_ID#">
						#Gl_Account# (#GL_Account_Desc#)
						</option>
					</cfloop>
				</select>
			</TD>
		</TR>
		</cfif>
		<!---D79237:  Fixed Price - OI and Redi END--->
<!---  62455 :: Fixed Price Components - Additional Drop Down for Fixed Price Type END --->
		<TR class="ExpectedRateTR" style="display:none;">
			<TD ALIGN="right" class="Orangline"><B>BB Expected Rate should be:</B></TD>
			<TD>
					<select name="Expected_Rate">
						<option value="0">Select an option</option>
						<option value="1">Set to $0</option>
						<option value="2">Less than program's rebate rate</option>
					</select>
			</TD>
		</TR>
<!--- 91550 :: Enhancement: Template-specific Expected Rate Adjustments START --->
	<TR class="ExpectedRateTR" style="display:none;">
		<TD ALIGN="right" class="Orangline"><B>Apply Expected Rate to:</B></TD>
		<TD>
				<select name="Expected_Rate_Affect_Discount_Type">
					<option value="0">Select an Option</option>
					<option value="1">Fixed</option>
					<option value="2">Rebate</option>
					<option value="3">Both</option>
				</select>
		</TD>
	</TR>

		<TR class="ExpectedRateTR" style="display:none;">
			<TD ALIGN="right" class="Orangline"><B>Apply to all templates:</B></TD>
			<TD>
				<table>
					<tr>
						<td>
							No <input type="radio" value="0" name="Expected_Rate_Apply_All_Templates" Checked onclick="$('##TemplateLink').show();"> &nbsp;
						</td>
						<td>
							Yes <input type="radio" value="1" name="Expected_Rate_Apply_All_Templates" onclick="$('##TemplateLink').hide();">
						</td>
						<td id="TemplateLink">
							<input type="hidden" name="ExpectedRateTemplateList" value="">
							<CF_button
							button_name		=	""
							button_caption	=	"templates"
							button_action	=	"template('', 0);"
							button_type		=	"javascript_link"
							button_width	=	"75"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						>
						</td>
					</tr>
				</table>
			</TD>
		</TR>
<!--- 91550 :: Enhancement: Template-specific Expected Rate Adjustments END --->
		<TR class="ExpectedRateTR" style="display:none;">
			<TD ALIGN="right" class="Orangline"><B>When the BB Payee Type is:</B></TD>
			<TD>
					<select name="Program_Pays_To">
						<option value="0">Select an option</option>
						<option value="1">Distributor</option>
						<option value="2">Operator</option>
						<option value="4">Both</option>
					</select>
			</TD>
		</TR>
	<!--- D41867 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work  END --->
		<!--- 34392 --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Greatest Program Value:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="greatest_program_value" checked> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="greatest_program_value">
			</TD>
		</TR>
		<cfif form.useFixedPriceType eq 1>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Fixed Price Type:</B></TD>
			<TD>
				<input type="radio" value="1" name="Fixed_Price_Type" checked>&nbsp;Deviated Price
				<input type="radio" value="2" name="Fixed_Price_Type">&nbsp;Price Extension
				<input type="radio" value="3" name="Fixed_Price_Type">&nbsp;Combination
			</TD>
		</TR>
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
		<!--- FORMULA PRICING --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Formula Pricing:</B></TD>
			<TD><INPUT NAME="formulaPrice" TYPE="checkbox" VALUE="1"></TD>
		</TR>
		<!--- FORMULA PRICING --->

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
			<td ALIGN="right" class="Orangline"><strong>GL Accounts</strong></td>
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
		<cfset component_select_templates_discount_type_id = 1 />
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
		<cfset discountTypeId = 1 />

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
		</cfif>  <!--- if auto pay app switch is ON --->

		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Add"
					button_action	=	"return checkData('1','');"
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
	function addComp(compId)
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
				alert("Please add at least one GL Account");
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

		<cfif appSettings.get_Setting('Include_Second_Component_Feature') eq '1'>
		if($(".Include_Second_Component:checked").val() == 1)
		{
			if($("#Second_Component_Name_ID option:selected").val() == 0)
			{
				alert("Please select a 2nd component");
				return false;
			}

			if($("#Second_Component_Payment_Cycle_ID option:selected").val() == 0)
			{
				alert("Please select a payment cycle for the 2nd component");
				return false;
			}

			if($("#Second_Component_Payment_Type_ID option:selected").val() == 0)
			{
				alert("Please select a claim mechanic for the 2nd component");
				return false;
			}


		<cfif appsettings.getGL_Account_On() IS 1 AND appsettings.getGL_Account_Required_for_Comp() IS 1>
			if($("#Second_Component_GL_Account_ID option:selected").val() == 0)
			{
				alert("Please select a GL Account for the 2nd component");
				return false;
			}
		</cfif>
		}
		</cfif>

		//set hidden form fields and submit
		actionFrm.command.value = 'addComp';
		actionFrm.display.value = 'active';
		actionFrm.submit();
		$("#msgSave").append("<p>Saving changes, please wait...</p>");
		return false;

	}
	</script>
</FIELDSET>