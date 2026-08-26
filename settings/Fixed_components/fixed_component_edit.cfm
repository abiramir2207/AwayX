<cfparam name="form.useFixedPriceType" default="0">
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
<cfoutput>
<style>
.Orangline
{
	border-right: 2px solid orange;
}
</style>

	<!--- Last edited info --->
<cfif isdefined("qGetCompFixed.Last_Edited_By") AND len(trim(qGetCompFixed.Last_Edited_By)) GT 0 >

	<cfset useLakebaseForGetUserLastEdited = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGetUserLastEdited>
	<cftry>
		<cfset GetUserLastEdited = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#qGetCompFixed.Last_Edited_By#",
				"select" = "name_first + ' ' + name_last as userlastedited"
			}), "name_first + ' ' + name_last as userlastedited"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetUserLastEdited = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetUserLastEdited>
<cfquery name="GetUserLastEdited" datasource="#application.datasource#">
	SELECT Name_First + ' ' + Name_Last AS UserLastEdited
	FROM _Users
	WHERE User_ID = '#qGetCompFixed.Last_Edited_By#'
	</cfquery>
</cfif>
	<cfif GetUserLastEdited.Recordcount IS 1>
	<TABLE ID="lastUpdatedBy" BGCOLOR="White" style="border-color:Orange;border-style:solid;margin-top:10px;" CELLPADDING="3" CELLSPACING="0" align="center">
	<TR>
	<TD align="center" width="400px" style="font-size:12px;">
		<B>Last updated on <CFOUTPUT>#dateformat(qGetCompFixed.Last_Edited_Date, 'm/d/yyy')# #timeformat(qGetCompFixed.Last_Edited_Date, 'h:mm:ss TT')# by #GetUserLastEdited.UserLastEdited#</CFOUTPUT></B>
	</TD>
	</TR>
	</TABLE>
	</cfif>
	<br>
</cfif>

<!--- load custom labels for deduction account, payment account --->
<cfinclude template="/common_Files/general_labels.cfm">

<!---D79237:  Fixed Price - OI and Redi START---->
	<cfset qGetALLCompFixedPrice = compFixed.getActive()>
	<cfquery name="qGetActiveComps" dbtype="query">
		SELECT *
		FROM qGetALLCompFixedPrice
		WHERE Program_Fixed_Component_Name_ID NOT IN (#form.compId#)
	</cfquery>
<!---D79237:  Fixed Price - OI and Redi END---->

<FIELDSET STYLE="padding:10px; width:1150px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Component Information</LEGEND>
	<table width="100%" border="0" cellpadding="3" cellspacing="0">
		<!--- <colgroup>
		<col width="30%"></col>
		<col width="1"></col>
		<col width="30%"></col>
		</colgroup> --->
		<!------ external id ----->
		<cfif application.returned_customer_setting.external_id_on EQ 1>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>#ID.General_Labels_Label#:</B></TD>
			<TD><INPUT NAME="compExternalID" TYPE="text" VALUE="#qGetCompFixed.External_ID#" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Display #ID.General_Labels_Label# on View Program page:</B></TD>
			<TD><INPUT NAME="displayExternalID" TYPE="checkbox" VALUE="1" <cfif qGetCompFixed.ID_on_ViewProgramPage>Checked</cfif>></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program END--->
		<cfelse>
			<INPUT NAME="compExternalID" TYPE="hidden" VALUE="#qGetCompFixed.External_ID#">
			<INPUT NAME="displayExternalID" TYPE="hidden" VALUE="#qGetCompFixed.ID_on_ViewProgramPage#"><!---D58135 --->
		</cfif>
		<TR>
			<TD ALIGN="right" class="Orangline" width="30%"><B>Component Name:</B></TD>
			<TD width="70%"><INPUT NAME="compName" TYPE="text" VALUE="#qGetCompFixed.Program_Fixed_Component_Name#" MAXLENGTH="50" style="width:220px"></TD>
		</TR>
		<tr>
			<td ALIGN="right" class="Orangline"><B>View Program Display Name:</B></td>
			<td><INPUT NAME="program_summary_display_name" TYPE="text" VALUE="#qGetCompFixed.program_summary_display_name#" MAXLENGTH="50" style="width:220px"></td>
		</tr>
		<cfif appSettings.get_Setting('Custom_RFP_Process',0) EQ 1 >
			<TR>
				<TD ALIGN="right" class="Orangline"><B>Component Type:</B></TD>
				<TD><INPUT NAME="compType" TYPE="radio" value="5" <cfif #qGetCompFixed.Fixed_Component_Type# EQ 5>checked</cfif>>Blended Delivered &nbsp;&nbsp;
					<INPUT NAME="compType" TYPE="radio" value="6" <cfif #qGetCompFixed.Fixed_Component_Type# EQ 6>checked</cfif>>FOB Plant (H)&nbsp;&nbsp;
					<INPUT NAME="compType" TYPE="radio" value="7" <cfif #qGetCompFixed.Fixed_Component_Type# EQ 7>checked</cfif>>FOB DC &nbsp;&nbsp;
					<INPUT NAME="compType" TYPE="radio" value="8" <cfif #qGetCompFixed.Fixed_Component_Type# EQ 8>checked</cfif>>Blended Delivered Freight Matrix &nbsp;&nbsp;
					<INPUT NAME="compType" TYPE="radio" value="9" <cfif #qGetCompFixed.Fixed_Component_Type# EQ 9>checked</cfif>>Non Blended Delivered Freight Matrix
				</TD>
			</TR>
		<cfelse>
			<TR>
				<TD ALIGN="right" class="Orangline"><B>Component Type:</B></TD>
				<TD><INPUT NAME="compType" TYPE="radio" value="1" <cfif #qGetCompFixed.Fixed_Component_Type# EQ 1>checked</cfif>>Delivered &nbsp;&nbsp;
					<cfif application.appSettingsGet.getTemplateMultipleProductAttrGroups() EQ 1>
						<INPUT NAME="compType" TYPE="radio" value="3" <cfif #qGetCompFixed.Fixed_Component_Type#  EQ 3>checked</cfif>>#application.returned_customer_setting.distributor_label_singular# Level Rates
					</cfif>
					<INPUT NAME="compType" TYPE="radio" value="2" <cfif #qGetCompFixed.Fixed_Component_Type# EQ 2>checked</cfif>>FOB Plant &nbsp;&nbsp;
					<INPUT NAME="compType" TYPE="radio" value="4" <cfif #qGetCompFixed.Fixed_Component_Type#  EQ 4>checked</cfif>>FOB FDC
				</TD>
			</TR>
		</cfif>

		<!--- Accrual --->
		<cfif appSettings.getShow_Component_Accrual()>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Accrual On:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Accrual_On" checked> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Accrual_On" <cfif qGetCompFixed.Accrual_On IS 1>checked</cfif>>
			</TD>
		</TR>
		<cfelse>
		<input type="hidden" name="Accrual_On" value ="#qGetCompFixed.Accrual_On#">
		</cfif>

		<!--- Brokerage --->
		<cfif appSettings.getBrokerage_Functionality_On()>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Exclude Brokerage:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Exclude_Brokerage" checked> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Exclude_Brokerage" <cfif qGetCompFixed.Exclude_Brokerage IS 1>checked</cfif>>
			</TD>
		</TR>
		<cfelse>
		<input type="hidden" name="Exclude_Brokerage" value ="#qGetCompFixed.Exclude_Brokerage#">
		</cfif>

		<!--- Floor Pricing --->
		<cfif appSettings.getShow_Component_Floor_Pricing()>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Floor Pricing On:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Floor_Pricing_On" checked> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Floor_Pricing_On" <cfif qGetCompFixed.Floor_Pricing_On IS 1>checked</cfif>>
			</TD>
		</TR>
		<cfelse>
		<input type="hidden" name="Floor_Pricing_On" value ="#qGetCompFixed.Floor_Pricing_On#">
		</cfif>

		<TR>
			<TD ALIGN="right" class="Orangline"><B>Off Invoice On:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Off_Invoice_On" checked> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Off_Invoice_On" <cfif qGetCompFixed.Off_Invoice_On IS 1>checked</cfif>>
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
				Yes <input type="radio" onclick="Toggle('show','ExpectedRateTR')" value="1" name="Update_BB_Expected_Rate" <cfif qGetCompFixed.Update_BB_Expected_Rate IS 1>checked</cfif>>
			</TD>
		</TR>
<!---  62455 :: Fixed Price Components - Additional Drop Down for Fixed Price Type START --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Fixed Price Type:</B></TD>
			<TD>
			<select name="FP_Type">
				<option value="0" <cfif qGetCompFixed.FP_Type EQ 0>SELECTED</cfif>>None</option>
				<option value="1" <cfif qGetCompFixed.FP_Type EQ 1>SELECTED</cfif>>Max Volume Fixed Price</option>
			</select>
			</TD>
		</TR>
<!---  62455 :: Fixed Price Components - Additional Drop Down for Fixed Price Type END --->
		<cfif appSettings.get_Setting('Include_Second_Component_Feature') eq '1'>
		<!---D79237:  Fixed Price - OI and Redi START---->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Include 2nd Component With Same Rates:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Include_Second_Component" class="Include_Second_Component" <cfif qGetCompFixed.Include_Second_Component IS 0>checked</cfif> onclick="$('.SecondCompNameId').hide();">
				&nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Include_Second_Component" class="Include_Second_Component" <cfif qGetCompFixed.Include_Second_Component IS 1>checked</cfif> onclick="$('.SecondCompNameId').show();">
			</TD>
		</TR>
		<cfelse>
		<cfset qGetCompFixed.Include_Second_Component = 0>
		</cfif>
		<TR class="SecondCompNameId" <cfif qGetCompFixed.Include_Second_Component IS 0>style="display:none;"</cfif>>
			<TD ALIGN="right" class="Orangline">&nbsp;</TD>
			<TD>2nd #Application.FixedPriceLabel# Component:<br />
				<select name="Second_Component_Name_ID" id="Second_Component_Name_ID" style="width:200px;">
					<option value="0">Select one option</option>
					<cfloop query="qGetActiveComps">
					<option value="#Program_Fixed_Component_Name_ID#" <cfif qGetCompFixed.Second_Component_Name_ID EQ Program_Fixed_Component_Name_ID>SELECTED</cfif>>#Program_Fixed_Component_Name#</option>
					</cfloop>
				</select>
			</TD>
		</TR>
		<TR class="SecondCompNameId" <cfif qGetCompFixed.Include_Second_Component IS 0>style="display:none;"</cfif>>
			<TD ALIGN="right" class="Orangline">&nbsp;</TD>
			<TD>2nd Component Payment Cycle:<br />
				<select name="Second_Component_Payment_Cycle_ID" id="Second_Component_Payment_Cycle_ID" style="width:200px;">
					<option value="0" SELECTED>Select one option</option>
					<cfloop query="qGetPaymentCycles">
						<option value="#Payment_Cycle_ID#"  <cfif qGetCompFixed.Second_Component_Payment_Cycle_ID EQ Payment_Cycle_ID>SELECTED</cfif>>#Payment_Cycle#</option>
					</cfloop>
				</select>
			</TD>
		</TR>
		<TR class="SecondCompNameId" <cfif qGetCompFixed.Include_Second_Component IS 0>style="display:none;"</cfif>>
			<TD ALIGN="right" class="Orangline">&nbsp;</TD>
			<TD>2nd Component Claim Mechanic:<br />
			<select name="Second_Component_Payment_Type_ID" id="Second_Component_Payment_Type_ID" style="width:200px;">
					<option value="0">Select one option</option>
					<cfloop query="GetClaimMechInfo">
					<option value="#Payment_Type_ID#" <cfif qGetCompFixed.Second_Component_Payment_Type_ID EQ Payment_Type_ID>SELECTED</cfif>>#Payment_Type_Name#</option>
					</cfloop>
				</select>
			</TD>
		</TR>
		<cfif appsettings.getGL_Account_On() IS 1>
		<TR class="SecondCompNameId" <cfif qGetCompFixed.Include_Second_Component IS 0>style="display:none;"</cfif>>
			<TD ALIGN="right" class="Orangline">&nbsp;</TD>
			<TD>2nd Component GL Account:<br />
				<select name="Second_Component_GL_Account_ID" id="Second_Component_GL_Account_ID" style="width:200px;">
						<option value="0" SELECTED>Select one option</option>
					<cfloop query="qGetGLs">
						<option value="#GL_Account_ID#"  <cfif qGetCompFixed.Second_Component_GL_Account_ID EQ GL_Account_ID>SELECTED</cfif>>
						#Gl_Account# (#GL_Account_Desc#)
						</option>
					</cfloop>
				</select>
			</TD>
		</TR>
		</cfif>
		<!---D79237:  Fixed Price - OI and Redi END--->
		<cfif qGetCompFixed.Update_BB_Expected_Rate>
		<TR class="ExpectedRateTR">
		<cfelse>
		<TR class="ExpectedRateTR" style="display:none;">
		</cfif>
			<TD ALIGN="right" class="Orangline"><B>BB Expected Rate should be:</B></TD>
			<TD>
					<select name="Expected_Rate">
						<option value="0">Select an Option</option>
						<option value="1" <cfif qGetCompFixed.Expected_Rate IS 1>selected</cfif>>Set to $0</option>
						<option value="2" <cfif qGetCompFixed.Expected_Rate IS 2>selected</cfif>>Less the program's rebate rate</option>
					</select>
			</TD>
		</TR>
<!--- 91550 :: Enhancement: Template-specific Expected Rate Adjustments START --->
<cfif qGetCompFixed.Update_BB_Expected_Rate>
	<TR class="ExpectedRateTR">
	<cfelse>
	<TR class="ExpectedRateTR" style="display:none;">
	</cfif>
		<TD ALIGN="right" class="Orangline"><B>Apply Expected Rate to:</B></TD>
		<TD>
				<select name="Expected_Rate_Affect_Discount_Type">
					<option value="0">Select an Option</option>
					<option value="1" <cfif qGetCompFixed.Expected_Rate_Affect_Discount_Type IS 1>selected</cfif>>Fixed</option>
					<option value="2" <cfif qGetCompFixed.Expected_Rate_Affect_Discount_Type IS 2>selected</cfif>>Rebate</option>
					<option value="3" <cfif qGetCompFixed.Expected_Rate_Affect_Discount_Type IS 3>selected</cfif>>Both</option>
				</select>
		</TD>
	</TR>

	<cfif qGetCompFixed.Update_BB_Expected_Rate>
		<TR class="ExpectedRateTR">
		<cfelse>
		<TR class="ExpectedRateTR" style="display:none;">
		</cfif>
			<TD ALIGN="right" class="Orangline"><B>Apply to all templates:</B></TD>
			<TD>
				<table>
					<tr>
						<td>
							No <input type="radio" value="0" name="Expected_Rate_Apply_All_Templates" checked onclick="$('##TemplateLink').show();"> &nbsp;
						</td>
						<td>
							Yes <input type="radio" value="1" name="Expected_Rate_Apply_All_Templates" <cfif qGetCompFixed.Expected_Rate_Apply_All_Templates IS 1>checked</cfif> onclick="$('##TemplateLink').hide();">
						</td>
						<td id="TemplateLink" <cfif qGetCompFixed.Expected_Rate_Apply_All_Templates IS 1>style="display:none;"</cfif>>
							<cfset ExpectedRateTemplateList = compFixed.getExpectedRateTemplates(form.compid)>
							<input type="hidden" name="ExpectedRateTemplateList" value="#ValueList(ExpectedRateTemplateList.First_Parent_ID,",")#">
							<CF_button
							button_name		=	""
							button_caption	=	"templates"
							button_action	=	"template('', #form.compid#, document.all.DataForm.ExpectedRateTemplateList.value);"
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
		<cfif qGetCompFixed.Update_BB_Expected_Rate>
		<TR class="ExpectedRateTR">
		<cfelse>
		<TR class="ExpectedRateTR" style="display:none;">
		</cfif>
			<TD ALIGN="right" class="Orangline"><B>When the BB Payee Type is:</B></TD>
			<TD>
					<select name="Program_pays_to">
						<option value="0">Select an Option</option>
						<option value="1"<cfif qGetCompFixed.Program_Pays_To IS 1>selected</cfif>>Distributor</option>
						<option value="2"<cfif qGetCompFixed.Program_Pays_To IS 2>selected</cfif>>Operator</option>
						<option value="4"<cfif qGetCompFixed.Program_Pays_To IS 4>selected</cfif>>Both</option>
					</select>
			</TD>
		</TR>
	<!--- D41867 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work  END --->
		<!--- 34392 --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Greatest Program Value:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="greatest_program_value" <cfif qGetCompFixed.greatest_program_value neq "1">checked</cfif>> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="greatest_program_value" <cfif qGetCompFixed.greatest_program_value eq "1">checked</cfif>>
			</TD>
		</TR>
		<cfif form.useFixedPriceType eq 1>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Fixed Component Type:</B></TD>
			<TD>
				<input type="radio" value="1" name="Fixed_Price_Type" <cfif qGetCompFixed.Fixed_Price_Type IS 1  OR qGetCompFixed.Fixed_Price_Type EQ "" OR qGetCompFixed.Fixed_Price_Type EQ 0>checked</cfif>>&nbsp;Deviated Price
				<input type="radio" value="2" name="Fixed_Price_Type" <cfif qGetCompFixed.Fixed_Price_Type IS 2>checked</cfif>>&nbsp;Price Extension
				<input type="radio" value="3" name="Fixed_Price_Type" <cfif qGetCompFixed.Fixed_Price_Type IS 3>checked</cfif>>&nbsp;Combination
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

			<TD><INPUT NAME="Deduction_Account" TYPE="text" VALUE="#qGetCompFixed.Deduction_Account#" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Display #general_labels[ deduction_account ]# on View Program page:</B></TD>
			<TD><INPUT NAME="displayDeductionAccount" TYPE="checkbox" VALUE="1" <cfif qGetCompFixed.DeductionAccount_on_ViewProgramPage>Checked</cfif>></TD>
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

			<TD><INPUT NAME="Payment_Account" TYPE="text" VALUE="#qGetCompFixed.Payment_Account#" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Display #general_labels[ payment_account ]# on View Program page:</B></TD>
			<TD><INPUT NAME="displayPaymentAccount" TYPE="checkbox" VALUE="1" <cfif qGetCompFixed.PaymentAccount_on_ViewProgramPage>Checked</cfif>></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program END--->
		<!--- End account info --->
		<!--- FORMULA PRICING --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Formula Pricing:</B></TD>
			<TD><INPUT NAME="formulaPrice" TYPE="checkbox" VALUE="1" <cfif qGetCompFixed.Formula_Pricing>Checked</cfif>></TD>
		</TR>
		<!--- FORMULA PRICING --->

		<!--- PROGRAM INTERFACE LOCK --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Program Interface Lock:</B></TD>
			<TD>
			<cfif application.appsettingsget.getProgramLockTypeID() EQ 0>
			  <cfif qGetCompFixed.Program_Lock_Type_ID EQ 0>
				No<CF_SmallHelp
							width="300"
							displayShifyX = "-200"
							imgPath="/images/i.gif"
							imgWidth="12"
							imgHeight="11"
							dropdownCheck="0">
						<center>The setting called Program Lock Type is set to 'Do Not Lock', therefore you cannot change this claim mechanic setting</center>
					</CF_SmallHelp>
			  <cfelse>
				Yes<CF_SmallHelp
							width="300"
							displayShifyX = "-200"
							imgPath="/images/i.gif"
							imgWidth="12"
							imgHeight="11"
							dropdownCheck="0">
						<center>The setting called Program Lock Type is set to 'Do Not Lock', therefore you cannot change this claim mechanic setting</center>
					</CF_SmallHelp>
			  </cfif>
			<input type="hidden"  name = "Program_Lock_Type_ID"  value= "<cfoutput>#qGetCompFixed.Program_Lock_Type_ID#</cfoutput>" />
			 <cfelse>
					No <input type="radio" name="Program_Lock_Type_ID" value="0" <cfif qGetCompFixed.Program_Lock_Type_ID EQ 0>checked</cfif>>&nbsp;
					Yes <input type="radio" name="Program_Lock_Type_ID" value="<cfoutput>#application.appsettingsget.getProgramLockTypeID()#</cfoutput>" <cfif application.appsettingsget.getProgramLockTypeID() eq qGetCompFixed.Program_Lock_Type_ID>checked</cfif>>
				</cfif>
			</TD>
		</TR>
		<!--- PROGRAM INTERFACE LOCK --->

		<!--- Operating Group --->
		<cfif operatingGroupOn>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>#operatingGroupManager.getLabel(operatingGroupLevel)#:</B></TD>
			<TD>
			<cfset qGetOperatingGroups = operatingGroupManager.get(level = operatingGroupLevel, active = 1) />
			<select name="Operating_Group_ID" style="width:200px">
				<cfloop query="qGetOperatingGroups">
				<option value="#Operating_Group_ID#" <cfif qGetCompFixed.Operating_Group_ID EQ Operating_Group_ID> selected</cfif>>#Operating_Group_Number# : #Operating_Group_Desc#</option>
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
				<cfif qGetCompFixed.Allowance_Code_ID EQ Allowance_Code_ID OR NOT ListFindNOCase(usedAllowanceCodes, Allowance_Code_ID)>
				<cfset anyAllowanceCodeAvailable = 1 />
				<option value="#Allowance_Code_ID#" <cfif qGetCompFixed.Allowance_Code_ID EQ Allowance_Code_ID> selected</cfif>>#Allowance_Code_Number# : #Allowance_Code_Desc#</option>
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
		SELECT GL_Account, GL_Account_Desc ,GL_Account_ID
		FROM GL_Account
		WHERE Deleted = 0
		AND Is_Active = 1
	</cfquery>
</cfif>

			<cfparam name="ExistingGLList" default="">
			<cfquery name="GetExistingGLs" datasource="#application.datasource#">
				SELECT GL_Account.*
				FROM GL_Account
					INNER JOIN GL_Component_Mapping
					ON GL_Component_Mapping.GL_Account_ID = GL_Account.GL_Account_ID
					AND GL_Component_Mapping.Discount_Type_ID = 1 <!--- CHANGE PER DISCOUNT TYPE --->
					AND GL_Component_Mapping.Component_Name_ID = '#qGetCompFixed.Program_Fixed_Component_Name_ID#'
			</cfquery>

			<cfset ExistingGLList = valuelist(GetExistingGLs.GL_Account_ID)>

			<cfif isdefined("form.ExistingGLList")>
				<cfquery name="DeleteComponentGL" datasource="#application.datasource#">
					DELETE FROM GL_Component_Mapping
					WHERE Component_Name_ID = <cfqueryparam value="#qGetCompFixed.Program_Fixed_Component_Name_ID#" cfsqltype="CF_SQL_INTEGER">
						AND Discount_Type_ID = 1
				</cfquery>

				<!--- Insert GLs --->
				<cfloop list="#form.ExistingGLList#" index="GL_Account_ID">
						 <cfset useLakebaseForInsertNewGLS = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_component_mapping")>
<cfif useLakebaseForInsertNewGLS>
	<cftry>
		<cfset application.oLakebase.insertRow("gl_component_mapping", {
			"gl_account_id" = "#GL_Account_ID#",
			"component_name_id" = "#qGetCompFixed.Program_Fixed_Component_Name_ID#",
			"discount_type_id" = "1"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertNewGLS = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertNewGLS>
<cfquery name="InsertNewGLS" datasource="#application.datasource#">
							INSERT INTO GL_Component_Mapping
							(
								GL_Account_ID,
								Component_Name_ID,
								Discount_Type_ID
							)
							VALUES
							(
								'#GL_Account_ID#',
								'#qGetCompFixed.Program_Fixed_Component_Name_ID#',
								1
							)
						</cfquery>
</cfif>
				</cfloop>
			</cfif>

			<cfif GLQuery.recordCount GT 1>
			<TR>
				<td ALIGN="right" class="Orangline"><strong><cfoutput>#Application.GLAccountLabel#</cfoutput>s</strong></td><!---D42774 --->
				<td><CF_button
						button_name		=	""
						button_caption	=	"Search for GLs"
						button_action	=	"return searchGL('#ExistingGLList#');"
						button_type		=	"javascript_link"
						button_width	=	"75"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					></td>
			</TR>
			</cfif>

			<cfquery name="GetExistingGLs" datasource="#application.datasource#">
				SELECT GL_Account.*
				FROM GL_Account
					INNER JOIN GL_Component_Mapping
					ON GL_Component_Mapping.GL_Account_ID = GL_Account.GL_Account_ID
					AND GL_Component_Mapping.Discount_Type_ID = 1 <!--- CHANGE PER DISCOUNT TYPE --->
					AND GL_Component_Mapping.Component_Name_ID = '#qGetCompFixed.Program_Fixed_Component_Name_ID#'
			</cfquery>
			<cfif GetExistingGLs.Recordcount GT 0>
				<tr>
					<td align="right" valign="top" class="Orangline"><strong>Current GLs</strong></td>
					<td>
						<table bgcolor="WhiteSmoke" cellpadding="2" cellspacing="0">
							<!--- <cfdump var="#GetExistingGLs#"> --->
							<cfloop query="GetExistingGLs">
							<tr id="#GL_Account_ID#">
								<td>#GL_Account# (#Gl_Account_Desc#)</td>
								<td><img src="/images/scissor.gif" onclick="deleteGL(#GL_Account_ID#)" style="cursor: pointer;"></td>
							</tr>
							</cfloop>
						</table>
					</td>
				</tr>
			</cfif>
			<input name="ExistingGLList" value="#ExistingGLList#" type="hidden">
			<input type="hidden" name="Component_ID" value="#qGetCompFixed.Program_Fixed_Component_Name_ID#">
		</cfif>
		<input name="GLList" type="hidden" value="">

		<!---95126 START--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>TPO Field:</B></TD>
			<TD>
				<select name="TPO_Field" style="width:200px">
					<option value="0" <cfif qGetCompFixed.TPO_Field EQ 0>selected</cfif>>None</option>
					<option value="1" <cfif qGetCompFixed.TPO_Field EQ 1>selected</cfif>>EDLP</option>
					<option value="2" <cfif qGetCompFixed.TPO_Field EQ 2>selected</cfif>>Promo Event</option>
				</select>
			</TD>
			</TR>
			<TR>
			<TD ALIGN="right" class="Orangline"><B>TPO Rate Type:</B></TD>
			<TD>
			<select name="TPO_Rate_Type" style="width:200px">
				<option value="0" <cfif qGetCompFixed.TPO_Rate_Type EQ 0>selected</cfif>>None</option>
				<option value="1" <cfif qGetCompFixed.TPO_Rate_Type EQ 1>selected</cfif>>Base Rate</option>
				<option value="2" <cfif qGetCompFixed.TPO_Rate_Type EQ 2>selected</cfif>>OI Rate</option>
				<option value="3" <cfif qGetCompFixed.TPO_Rate_Type EQ 3>selected</cfif>>BB Rate</option>
				<option value="4" <cfif qGetCompFixed.TPO_Rate_Type EQ 4>selected</cfif>>Scan Rate</option>
				<option value="5" <cfif qGetCompFixed.TPO_Rate_Type EQ 5>selected</cfif>>Lump Sum</option>
			</select>
			</TD>
		</TR>
		<!---95126 END--->

		<!--- ***************************** select templates ***************************** --->
		<TR>
		<TD colspan="100%">
		<cfset component_select_templates_component_id = form.compId />
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
		IsClosed="Yes";
		</CFSCRIPT>

		<CF_OPENLAYER
			BORDER="#Border#"							BORDERSIZE="#BorderSize#"
			BORDERCOLOR="#BorderColor#"					IMAGE="#Image#"
			IMAGEOPEN="#ImageOpen#"						TITLE="Select the transaction types to INCLUDE in Auto Pay calculations"
			TITLECLOSED="Select the transaction types to INCLUDE in Auto Pay calculations"	TITLETOOLTIP="Click here to toggle view"
			TITLECOLOR="#TitleColor#"					TITLEFONT="#TitleFont#"
			TITLESIZE="#TitleSize#"						ISCLOSED="#IsClosed#">

		<cfset componentNameId = form.compId />
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
					button_caption	=	"Update"
					button_action	=	"return checkData('1','#qGetCompFixed.Program_Fixed_Component_Name_ID#');"
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
	</FIELDSET>

	<script>
	///////////////////////////////////   Update Component //////////////////////////////////////////
	function upadateComp(compId)
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

		if (trim(actionFrm.ExistingGLList.value) == "" || ((listLength(actionFrm.ExistingGLList.value, ',') == listLength(actionFrm.GLList.value, ',')) && trim(actionFrm.GLList.value) != ""))
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

		<cfif appSettings.get_Setting('Include_Second_Component_Feature') eq '1'>
		if($(".Include_Second_Component:checked").val() == 1)
		{
			if($("##Second_Component_Name_ID option:selected").val() == 0)
			{
				alert("Please select a 2nd component");
				return false;
			}

			if($("##Second_Component_Payment_Cycle_ID option:selected").val() == 0)
			{
				alert("Please select a payment cycle for the 2nd component");
				return false;
			}

			if($("##Second_Component_Payment_Type_ID option:selected").val() == 0)
			{
				alert("Please select a claim mechanic for the 2nd component");
				return false;
			}


		<cfif appsettings.getGL_Account_On() IS 1 AND appsettings.getGL_Account_Required_for_Comp() IS 1>
			if($("##Second_Component_GL_Account_ID option:selected").val() == 0)
			{
				alert("Please select a GL Account for the 2nd component");
				return false;
			}
		</cfif>
		}
		</cfif>

		actionFrm.compId.value = compId;
		actionFrm.command.value = 'update';
		actionFrm.display.value = actionFrm.returnTo.value;
		actionFrm.submit();
		$("##msgSave").append("<p>Saving changes, please wait...</p>");
		return false;
	}
	</script>

	</cfoutput>