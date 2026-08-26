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
	.Orangline{
		border-right: 2px solid orange;
	}
	select{
		width: 180px;
	}
</style>
<!--- load custom labels for deduction account, payment account --->
<cfinclude template="/common_Files/general_labels.cfm">

<!--- Last edited info --->
	<cfif isdefined("qGetCompRebates.Last_Edited_By") AND len(trim(qGetCompRebates.Last_Edited_By)) GT 0 >
		<cfset useLakebaseForGetUserLastEdited = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGetUserLastEdited>
	<cftry>
		<cfset GetUserLastEdited = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#qGetCompRebates.Last_Edited_By#",
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
			WHERE User_ID = '#qGetCompRebates.Last_Edited_By#'
		</cfquery>
</cfif>
		<cfif GetUserLastEdited.Recordcount IS 1>
			<TABLE ID="lastUpdatedBy" BGCOLOR="White" style="border-color:Orange;border-style:solid;margin-top:10px;" CELLPADDING="3" CELLSPACING="0" align="center">
				<TR>
					<TD align="center" width="400px" style="font-size:12px;">
						<B>Last updated on <CFOUTPUT>#dateformat(qGetCompRebates.Last_Edited_Date, 'm/d/yyy')# #timeformat(qGetCompRebates.Last_Edited_Date, 'h:mm:ss TT')# by #GetUserLastEdited.UserLastEdited#</CFOUTPUT></B></TD>
					</TD>
				</TR>
			</TABLE>
		</cfif>
		<br>
	</cfif>
<cfoutput>
<FIELDSET STYLE="padding:10px; width:1150px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Component Information</LEGEND>
	<table width="100%" border="0"   cellpadding="3" cellspacing="0">
		<!------ external id ----->
		<cfif application.returned_customer_setting.external_id_on EQ 1>
			<TR>
				<TD ALIGN="right" class="Orangline"><B>#ID.General_Labels_Label#:</B></TD>
				<TD><INPUT NAME="compExternalID" TYPE="text" VALUE="#qGetCompRebates.External_ID#" SIZE="30" MAXLENGTH="50"></TD>
			</TR>
		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Display #ID.General_Labels_Label# on View Program page:</B></TD>
			<TD><INPUT NAME="displayExternalID" TYPE="checkbox" VALUE="1" <cfif qGetCompRebates.ID_on_ViewProgramPage>Checked</cfif>></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program END--->
		<cfelse>
			<INPUT NAME="compExternalID" TYPE="hidden" VALUE="#qGetCompRebates.External_ID#">
			<INPUT NAME="displayExternalID" TYPE="hidden" VALUE="#qGetCompRebates.ID_on_ViewProgramPage#"><!---D58135 --->
		</cfif>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>#Application.LumpsumLabel# Component Name:</B></TD>
			<TD><INPUT NAME="compName" TYPE="text" VALUE="#qGetCompRebates.Program_Lump_Sum_Name#" MAXLENGTH="50" style="width:220px"></TD>
		</TR>
		<!--- Dev Note: KAL; 9896: Lumpsum page to handle for samples --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Related to Samples:</B></TD>
			<TD><INPUT NAME="samples_related" TYPE="Checkbox" VALUE="1" <cfif qGetCompRebates.samples_related>CHECKED</cfif> ></TD>
		</TR>
		<!--- Dev Note: KAL; D20537: Margin Approval – Trade as Percent of Gross Sales. Forge changes  --->

		<!--- Accrual: Dev Note: KAL; D40125 --->
		<cfif appSettings.getShow_Component_Accrual()>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Accrual On:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Accrual_On" checked id="AccrualOff"> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Accrual_On" <cfif qGetCompRebates.Accrual_On IS 1>checked</cfif> id="AccrualOn">
			</TD>
		</TR>
		<!--- 62609  Lump Sum Component Settings - Accrual Dropdown Option START --->
		<TR id="AccrualPostingOptions" <cfif qGetCompRebates.Accrual_On IS 0>style="display:None;"</cfif>>
			<TD ALIGN="right" class="Orangline"><B>Accrual Posting Options</TD>
			<TD>
				<select name="Accrual_Posting_Options">
					<option value="0"  <cfif qGetCompRebates.Accrual_Posting_Options EQ 0>SELECTED</cfif>>None</option>
					<option value="1"  <cfif qGetCompRebates.Accrual_Posting_Options EQ 1>SELECTED</cfif>>1st Day of Program</option>
					<option value="2"  <cfif qGetCompRebates.Accrual_Posting_Options EQ 2>SELECTED</cfif>>Weekly</option>
					<option value="3"  <cfif qGetCompRebates.Accrual_Posting_Options EQ 3>SELECTED</cfif>>Accrue against 1st Invoice</option>
				</select>
			</TD>
		</TR>
		<!--- 62609  Lump Sum Component Settings - Accrual Dropdown Option END --->
		<cfelse>
			<!--- D41515 : Invalid data ' for CFSQLTYPE CF_SQL_BIT --->
			<cfset bAccrual = qGetCompRebates.Accrual_On />
			<cfif bAccrual EQ ''>
				<cfset bAccrual = 0 />
			</cfif>
			<input type="hidden" name="Accrual_On" value ="#bAccrual#" >
			<input type="hidden" name="Accrual_Posting_Options" value ="0" >
		</cfif>

		<TR>
			<TD ALIGN="right" class="Orangline"><B>Exclude from TPA:</B></TD>
			<TD><INPUT NAME="Exclude_From_TPA" TYPE="Checkbox" VALUE="1" <cfif qGetCompRebates.Exclude_From_TPA>CHECKED</cfif> ></TD>
		</TR>
		<!--- 28732: Component as Cost --->
		<!--- D37295 Kraft Equipment LS set up --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Related to Equipment:</B></TD>
			<TD><INPUT NAME="Related_to_Equipment" TYPE="Checkbox" VALUE="1" <cfif qGetCompRebates.Related_to_Equipment EQ 1>CHECKED</cfif> onclick="toggle('EquipmentValue');"></TD>
		</TR>
		<TR <cfif qGetCompRebates.Related_to_Equipment NEQ 1>style="display:none;"</cfif>id="EquipmentValue">
			<TD ALIGN="right" class="Orangline"><B>Equipment Value:</B></TD>
			<cfif len(qGetCompRebates.Equipment_value) EQ 0>
					<cfset Equipment_value= 0>
				<cfelse>
					<cfset Equipment_value = #qGetCompRebates.Equipment_value#>
			</cfif>
			<TD><INPUT NAME="Equipment_Value" TYPE="text" MAXLENGTH="50" value="#Equipment_value#" style="width:75px" onKeyUp="clenseText(this, '0123456789., ');"></TD>
		</TR>
		<!--- D37295 Kraft Equipment LS set up --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Lump Sum Type: </B></TD>
			<TD>
				<select name="Lump_Sum_Type">
					<option value="0"  <cfif qGetCompRebates.Lump_Sum_Type EQ 0>SELECTED</cfif>>None</option>
					<option value="1"  <cfif qGetCompRebates..Lump_Sum_Type EQ 1>SELECTED</cfif>>Express as Cost in margin</option>
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

			<TD><INPUT NAME="Deduction_Account" TYPE="text" VALUE="#qGetCompRebates.Deduction_Account#" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Display #general_labels[ deduction_account ]# on View Program page:</B></TD>
			<TD><INPUT NAME="displayDeductionAccount" TYPE="checkbox" VALUE="1" <cfif qGetCompRebates.DeductionAccount_on_ViewProgramPage>Checked</cfif>></TD>
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

			<TD><INPUT NAME="Payment_Account" TYPE="text" VALUE="#qGetCompRebates.Payment_Account#" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Display #general_labels[ payment_account ]# on View Program page:</B></TD>
			<TD><INPUT NAME="displayPaymentAccount" TYPE="checkbox" VALUE="1" <cfif qGetCompRebates.PaymentAccount_on_ViewProgramPage>Checked</cfif>></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program END--->
		<!--- End account info --->

		<!--- PROGRAM INTERFACE LOCK --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Program Interface Lock:</B></TD>
			<TD>
			<cfif application.appsettingsget.getProgramLockTypeID() EQ 0>
			  <cfif qGetCompRebates.Program_Lock_Type_ID EQ 0>
				No<CF_SmallHelp
							width="300"
							displayShifyX = "-200"
							imgPath="/images/i.gif"
							imgWidth="12"
							imgHeight="11"
							dropdownCheck="0">
						<center>The setting called Program Lock Type is set to ‘Do Not Lock’, therefore you cannot change this claim mechanic setting</center>
					</CF_SmallHelp>
			  <cfelse>
				Yes<CF_SmallHelp
							width="300"
							displayShifyX = "-200"
							imgPath="/images/i.gif"
							imgWidth="12"
							imgHeight="11"
							dropdownCheck="0">
						<center>The setting called Program Lock Type is set to ‘Do Not Lock’, therefore you cannot change this claim mechanic setting</center>
					</CF_SmallHelp>
			  </cfif>
			<input type="hidden"  name = "Program_Lock_Type_ID"  value= "<cfoutput>#qGetCompRebates.Program_Lock_Type_ID#</cfoutput>" />
			 <cfelse>
					No <input type="radio" name="Program_Lock_Type_ID" value="0" <cfif qGetCompRebates.Program_Lock_Type_ID EQ 0>checked</cfif>>&nbsp;
					Yes <input type="radio" name="Program_Lock_Type_ID" value="<cfoutput>#application.appsettingsget.getProgramLockTypeID()#</cfoutput>" <cfif application.appsettingsget.getProgramLockTypeID() eq qGetCompRebates.Program_Lock_Type_ID>checked</cfif>>
				</cfif>
			</TD>
		</TR>
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

			<TD><INPUT NAME="Allow_Negative" TYPE="Checkbox" VALUE="1" <cfif qGetCompRebates.Allow_Negative>CHECKED</cfif> ></TD>
		</TR>
		<!--- END Allow Negative Values  --->

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

			<TD><INPUT NAME="Allow_Broker_Payee" TYPE="Checkbox" VALUE="1" <cfif qGetCompRebates.Allow_Broker_Payee>CHECKED</cfif> ></TD>
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
					<option value="#Operating_Group_ID#" <cfif qGetCompRebates.Operating_Group_ID EQ Operating_Group_ID> selected</cfif>>#Operating_Group_Number# : #Operating_Group_Desc#</option>
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
					<cfif qGetCompRebates.Allowance_Code_ID EQ Allowance_Code_ID OR NOT ListFindNOCase(usedAllowanceCodes, Allowance_Code_ID)>
					<cfset anyAllowanceCodeAvailable = 1 />
					<option value="#Allowance_Code_ID#" <cfif qGetCompRebates.Allowance_Code_ID EQ Allowance_Code_ID> selected</cfif>>#Allowance_Code_Number# : #Allowance_Code_Desc#</option>
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

			<cfparam name="ExistingGLList" default="">
			<cfquery name="GetExistingGLs" datasource="#application.datasource#">
				SELECT GL_Account.*
				FROM GL_Account
				INNER JOIN GL_Component_Mapping
				ON GL_Component_Mapping.GL_Account_ID = GL_Account.GL_Account_ID
				AND GL_Component_Mapping.Discount_Type_ID = 3 <!--- CHANGE PER DISCOUNT TYPE --->
				AND GL_Component_Mapping.Component_Name_ID = '#qGetCompRebates.Program_Lump_Sum_Name_ID#'
			</cfquery>

			<cfset ExistingGLList = valuelist(GetExistingGLs.GL_Account_ID)>

			<cfif isdefined("form.ExistingGLList")>
				<cfquery name="DeleteComponentGL" datasource="#application.datasource#">
					DELETE FROM GL_Component_Mapping
					WHERE Component_Name_ID = <cfqueryparam value="#qGetCompRebates.Program_Lump_Sum_Name_ID#" cfsqltype="CF_SQL_INTEGER">
						AND Discount_Type_ID = 3
				</cfquery>

				<!--- Insert GLs --->
				<cfloop list="#form.ExistingGLList#" index="GL_Account_ID">
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
							'#qGetCompRebates.Program_Lump_Sum_Name_ID#',
							3
						)
					</cfquery>
				</cfloop>
			</cfif>

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
	<cfif GLQuery.recordCount GT 1>
			<TR>
				<td ALIGN="right" class="Orangline"><strong><cfoutput>#Application.GLAccountLabel#</cfoutput>s</strong></td><!---D42774 --->
				<td>
					<CF_button
						button_name		=	""
						button_caption	=	"Search for GLs"
						button_action	=	"return searchGL('','edit');"
						button_type		=	"javascript_link"
						button_width	=	"75"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				</td>
			</TR>
	</cfif>
			<cfquery name="GetExistingGLs" datasource="#application.datasource#">
				SELECT GL_Account.*
				FROM GL_Account
				INNER JOIN GL_Component_Mapping
				ON GL_Component_Mapping.GL_Account_ID = GL_Account.GL_Account_ID
				AND GL_Component_Mapping.Discount_Type_ID = 3 <!--- CHANGE PER DISCOUNT TYPE --->
				AND GL_Component_Mapping.Component_Name_ID = '#qGetCompRebates.Program_Lump_Sum_Name_ID#'
			</cfquery>

			<cfset ExistingGLList = valuelist(GetExistingGLs.GL_Account_ID)>

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
			<input type="hidden" name="Component_ID" value="#qGetCompRebates.Program_Lump_Sum_Name_ID#">
		</cfif>
		<input name="GLList" type="hidden" value="">

		<!---95126 START--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>TPO Field:</B></TD>
			<TD>
				<select name="TPO_Field" style="width:200px">
					<option value="0" <cfif qGetCompRebates.TPO_Field EQ 0>selected</cfif>>None</option>
					<option value="1" <cfif qGetCompRebates.TPO_Field EQ 1>selected</cfif>>EDLP</option>
					<option value="2" <cfif qGetCompRebates.TPO_Field EQ 2>selected</cfif>>Promo Event</option>
				</select>
			</TD>
			</TR>
			<TR>
			<TD ALIGN="right" class="Orangline"><B>TPO Rate Type:</B></TD>
			<TD>
			<select name="TPO_Rate_Type" style="width:200px">
				<option value="0" <cfif qGetCompRebates.TPO_Rate_Type EQ 0>selected</cfif>>None</option>
				<option value="1" <cfif qGetCompRebates.TPO_Rate_Type EQ 1>selected</cfif>>Base Rate</option>
				<option value="2" <cfif qGetCompRebates.TPO_Rate_Type EQ 2>selected</cfif>>OI Rate</option>
				<option value="3" <cfif qGetCompRebates.TPO_Rate_Type EQ 3>selected</cfif>>BB Rate</option>
				<option value="4" <cfif qGetCompRebates.TPO_Rate_Type EQ 4>selected</cfif>>Scan Rate</option>
				<option value="5" <cfif qGetCompRebates.TPO_Rate_Type EQ 5>selected</cfif>>Lump Sum</option>
			</select>
			</TD>
		</TR>
		<!---95126 END--->

		<!--- 98880 START--->
		<cfif appSettings.get_Setting('Planner_Targets_Enabled') EQ "1">
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Retail <cfoutput>#Application.PlannerLabel#</cfoutput> Target type:</B></TD>
			<TD>
				<select name="Planner_Target_Type" style="width:200px">
					<option value="0" <cfif qGetCompRebates.Planner_Target_Type EQ 0>selected</cfif>>None</option>
					<option value="1" <cfif qGetCompRebates.Planner_Target_Type EQ 1>selected</cfif>>Demo</option>
					<option value="2" <cfif qGetCompRebates.Planner_Target_Type EQ 2>selected</cfif>>Slotting</option>
				</select>
			</TD>
		</TR>
		</cfif>
		<!--- 98880 END--->
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

				<TD><INPUT NAME="Manual_LS_Allocation" TYPE="Checkbox" VALUE="1" <cfif qGetCompRebates.Manual_LS_Allocation>CHECKED</cfif> ></TD>
		</TR>
		<TR>
			<TD colspan="100%">
			<cfset component_select_templates_component_id = form.compId />
			<cfset component_select_templates_discount_type_id = 3 />
			<cfinclude template="/program_wizard/component_select_templates_grid.cfm" />
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Update"
					button_action	=	"return checkData('3','#qGetCompRebates.Program_Lump_Sum_Name_ID#');"
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
		actionFrm.compId.value = compId;
		actionFrm.command.value = 'update';
		actionFrm.display.value = actionFrm.returnTo.value;
		actionFrm.submit();
		$("##msgSave").append("<p>Saving changes, please wait...</p>");
		return false;
	}
	//62609  Lump Sum Component Settings - Accrual Dropdown Option START
	$( "##AccrualOn" ).click(function() {
		$( "##AccrualPostingOptions" ).show( );
	});
	$( "##AccrualOff" ).click(function() {
		$( "##AccrualPostingOptions" ).hide( );
	});
	//62609  Lump Sum Component Settings - Accrual Dropdown Option END
	</script>
</cfoutput>