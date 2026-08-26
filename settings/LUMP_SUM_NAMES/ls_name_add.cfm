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

select
{
	width: 180px;
}
</style>
<!--- load custom labels for deduction account, payment account --->
<cfinclude template="/common_Files/general_labels.cfm">

<cfparam name="form.compExternalID" 				default="">
<cfparam name="form.compName" 						default="">
<cfparam name="form.samples_related"				default="0">
<cfparam name="form.exclude_from_tpa"			default="0">
<cfparam name="form.Allow_negative"				default="0">
<cfparam name="form.Allow_Broker_Payee"				default="0">
<!--- D37295 Kraft Equipment LS set up --->
<cfparam name="form.Related_to_Equipment" 	default="0">
<cfparam name="form.Equipment_value" 			default=" ">
<cfparam name="Manual_LS_Allocation" 			default="0">

<!--- D37295 Kraft Equipment LS set up --->
<FIELDSET STYLE="padding:10px; width:1150px; border: 1px solid Blue;margin-top:10px;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfoutput>#Application.LumpsumLabel# </cfoutput>Components</LEGEND>
	<table width="100%" border="0"  cellpadding="3" cellspacing="0">
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
			<TD ALIGN="right" class="Orangline"><B><cfoutput>#Application.LumpsumLabel# </cfoutput>Components:</B></TD>
			<TD><INPUT NAME="compName" TYPE="text" MAXLENGTH="50" value="#form.compName#" style="width:220px"></TD>
		</TR>
		<!--- Dev Note: KAL; 9896: Lumpsum page to handle for samples --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Related to Samples:</B></TD>
			<TD><INPUT NAME="samples_related" TYPE="Checkbox" VALUE="1" <cfif form.samples_related EQ 1>CHECKED</cfif> ></TD>
		</TR>
		<!--- Dev Note: KAL; D20537: Margin Approval Trade as Percent of Gross Sales. Forge changes  --->
		<!--- Accrual: Dev Note: KAL; D40125 --->
		<cfif appSettings.getShow_Component_Accrual()>
			<TR>
				<TD ALIGN="right" class="Orangline"><B>Accrual On:</B></TD>
				<TD>
					No &nbsp;<input type="radio" value="0" name="Accrual_On" checked id="AccrualOff"> &nbsp;&nbsp;
					Yes <input type="radio" value="1" name="Accrual_On" id="AccrualOn">
				</TD>
			</TR>
		<!--- 62609  Lump Sum Component Settings - Accrual Dropdown Option START --->
		<TR id="AccrualPostingOptions" style="display:none;">
			<TD ALIGN="right" class="Orangline"><B>Accrual Posting Options</TD>
			<TD>
				<select name="Accrual_Posting_Options">
					<option value="0" >None</option>
					<option value="1" >1st Day of Program</option>
					<option value="2" >Weekly</option>
					<option value="3" >Accrue against 1st Invoice</option>
				</select>
			</TD>
		</TR>
		<!--- 62609  Lump Sum Component Settings - Accrual Dropdown Option END --->
		<cfelse>
			<input type="hidden" name="Accrual_On" value ="0">
		</cfif>

		<TR>
			<TD ALIGN="right" class="Orangline"><B>Exclude from TPA:</B></TD>
			<TD><INPUT NAME="Exclude_From_TPA" TYPE="Checkbox" VALUE="1" <cfif form.Exclude_From_TPA EQ 1>CHECKED</cfif> ></TD>
		</TR>
		<!--- 28732: Component as Cost --->
		<!--- D37295 Kraft Equipment LS set up --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Related to Equipment:</B></TD>
			<TD><INPUT NAME="Related_to_Equipment" TYPE="Checkbox" VALUE="1" <cfif form.Related_to_Equipment EQ 1>CHECKED</cfif> onclick="toggle('EquipmentValue');"></TD>
		</TR>
		<TR style="display:none;" id="EquipmentValue">
			<TD ALIGN="right" class="Orangline"><B>Equipment Value:</B></TD>
			<TD><INPUT NAME="Equipment_Value" TYPE="text" MAXLENGTH="50" value="#form.Equipment_value#" style="width:75px" onKeyUp="clenseText(this, '0123456789., ');"></TD>
		</TR>
		<!--- D37295 Kraft Equipment LS set up --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Lump Sum Type: </B></TD>
			<TD>
				<select name="Lump_Sum_Type">
					<option value="0" SELECTED>None</option>
					<option value="1">Express as Cost in margin</option>
				</select>
			</TD>
		</TR>
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
				No<span onmouseout="popUpTip(event,'dist_Tip');" onmouseover="popUpTip(event,'dist_Tip');">
					  <img src="/images/help_small.gif" />
				</span>
				<div id="dist_Tip" class="tip">
						  <p align="left">The setting called Program Lock Type is set to ‘Do Not Lock’, therefore you cannot change this setting</p>
					</div>
				<input type="hidden"  name = "Program_Lock_Type_ID"  value= "0" />
				<cfelse>
					No<input type="radio" name="Program_Lock_Type_ID" value="0" checked>&nbsp;
					Yes <input type="radio" name="Program_Lock_Type_ID" value="<cfoutput>#application.appsettingsget.getProgramLockTypeID()#</cfoutput>">
				</cfif>
			</TD>
		<TR>
		<!--- PROGRAM INTERFACE LOCK --->

<!--- START: Allow Negative Values--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Allow Negative Values: <CF_SmallHelp
					width="300"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
				<center>If this is turned ON, the Lumpsum Amount in the Program will accept negative values.</center>
				</CF_SmallHelp></B></TD>

			<TD><INPUT NAME="Allow_Negative" TYPE="Checkbox" VALUE="1" <cfif form.Allow_Negative>CHECKED</cfif> ></TD>
		</TR>
		<!--- ENDL Allow Negative Values  --->

		<!--- START: Allow Broker Payee--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Allow Broker Payee: <CF_SmallHelp
					width="300"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
				<center>If this is turned ON, Brokers will be available as a Payee option for the Lump Sum Component regardless of the template setting.</center>
				</CF_SmallHelp></B></TD>

			<TD><INPUT NAME="Allow_Broker_Payee" TYPE="Checkbox" VALUE="1" ></TD>
		</TR>
		<!--- END Allow Broker  --->


		<!--- Operating Group --->
		<cfif operatingGroupOn>
			<TR>
				<TD ALIGN="right" class="Orangline"><B>#operatingGroupManager.getLabel(operatingGroupLevel)#:</B></TD>
				<TD>
				<cfset qGetOperatingGroups = operatingGroupManager.get(level = operatingGroupLevel, active = 1) />
				<select name="Operating_Group_ID" style="width:200px">
					<cfloop query="qGetOperatingGroups">
					<option value="#Operating_Group_ID#" <cfif form.Operating_Group_ID EQ Operating_Group_ID></cfif>>#Operating_Group_Number# : #Operating_Group_Desc#</option>
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
		<cfquery name="GLQuery" datasource="#application.datasource#">
			SELECT GL_Account, GL_Account_Desc, GL_Account_ID
			FROM GL_Account
			WHERE Deleted = 0
			AND Is_Active = 1
		</cfquery>
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

		<!---98880 START--->
		<cfif appSettings.get_Setting('Planner_Targets_Enabled') EQ "1">
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Retail <cfoutput>#Application.PlannerLabel#</cfoutput> Target type:</B></TD>
			<TD>
				<select name="Planner_Target_Type" style="width:200px">
					<option value="0">None</option>
					<option value="1">Demo</option>
					<option value="2">Slotting</option>
				</select>
			</TD>
		</TR>
		</cfif>
		<!---98880 END--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Manual LS Allocation: <CF_SmallHelp
					width="300"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
				<center>When this feature is ON: In the LS page, provide the user with a list of the products / product groups associated with the component and a field to enter a whole number which indicates the percentage of the LS dollars to allocate to that row.  </center>
				</CF_SmallHelp></B></TD>

			<TD><INPUT NAME="Manual_LS_Allocation" TYPE="Checkbox" VALUE="1" <cfif form.Manual_LS_Allocation>CHECKED</cfif> ></TD>
		</TR>
		<TR>
			<TD colspan="100%">
			<cfset component_select_templates_component_id = -1 />
			<cfset component_select_templates_discount_type_id = 3 />
			<cfinclude template="/program_wizard/component_select_templates_grid.cfm" />
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Add"
					button_action	=	"return checkData('3','');"
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
		//set hidden form fields and submit
		actionFrm.command.value = 'addComp';
		actionFrm.display.value = 'active';
		actionFrm.submit();
		$("#msgSave").append("<p>Saving changes, please wait...</p>");
		return false;

	}
	//62609  Lump Sum Component Settings - Accrual Dropdown Option START
	$( "#AccrualOn" ).click(function() {
		$( "#AccrualPostingOptions" ).show( );
	});
	$( "#AccrualOff" ).click(function() {
		$( "#AccrualPostingOptions" ).hide( );
	});
	//62609  Lump Sum Component Settings - Accrual Dropdown Option END
	</script>
</FIELDSET>