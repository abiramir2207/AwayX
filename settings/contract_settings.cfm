<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<script SRC="/common_files/scripts/wholeNumberValidation.js"></script>
	<!--- Dev Note: drachala; D28078: Text Editor tools in Forge not working with Windows 7  START
					What  I did: Added New Jquery Text Editor WYUIWYG--->
	<script type="text/javascript" src="/Script/Editor/scripts/wysiwyg.js"></script>
	<script type="text/javascript" src="/Script/Editor/scripts/wysiwyg-settings.js"></script>
	<script type="text/javascript">
		WYSIWYG.attach('textarea', full);
	</script>
	<!--- End Dev Note: drachala; D28078: Text Editor tools in Forge not working with Windows 7  --->
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFSET pagetitle = "PROGRAMS: PROGRAM SETTINGS">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<cfquery name="Get_Settings" datasource="#application.datasource#">
	SELECT _Users_Settings.*, _Users.Name_First + ' ' + _Users.Name_Last AS Editor_FullName
	  FROM _Users_Settings
		   LEFT JOIN _Users	ON _Users_Settings.Contract_Settings_Editor_ID = _Users.User_ID
	Where _Users_Settings.User_ID =	'#request.AccessStructure.Company_Main_ID#'
</cfquery>

<cfscript>
	if ( Get_Settings.Max_Operator_ID_Length eq 0 )
		MaxOperatorIDLength = 20;
	else
		MaxOperatorIDLength = Get_Settings.Max_Operator_ID_Length;

	if ( Get_Settings.Max_Program_Title_Length eq 0 )
		MaxProgramTitleLength = 1000;
	else
		MaxProgramTitleLength = Get_Settings.Max_Program_Title_Length;

	budgetReportMgr              = CreateObject("component","mvc.models.Reports.BudgetReport");
	qbudgetReport                = budgetReportMgr.getBudgetLabels();
	SearchProgramManager         = application.oController.getObject(path="mvc.models.program.search_program",bReload= 0);
	qryProgramStatusList         = SearchProgramManager.getAllCurrentViewStatus();
	ProductGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init();
	qAllProductAttributes        = ProductGroupAttributeManager.getProductGroupAttributes(active=1, includePG=0);
	udf                          = createObject( "component", "components.udf" );
</cfscript>

<BR>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<BR>
<SCRIPT SRC="/Script/javascript/string_validations.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<script language="JavaScript">
	function validateThisField(iType, oInput, sMsg)
	{
		var isValid = true;
		switch(iType)
		{
			case 1://numeric
			{
				isValid = isInt(oInput.value);
				break;
			}
			case 2://string
			{
				isValid = !isSpace(oInput.value);
				break;
			}
			case 3://select
			{
				if(oInput.value == "")
				{
					isValid = false;
				}
				break;
			}
		}

		var errObj = eval("document.all.err_sp_" + oInput.name);
		if(isValid)
		{
			clearQueue(errObj);
		}
		else
		{
			queueMessage(sMsg, errObj);
		}
		return isValid;
	}

	function validateForm(thisForm)
	{
		var isValid = true;
		<!--- isValid = validateThisField(1, thisForm.contract_expiration_range, "'Contract expiring age' should be a valid number") && isValid; removed with 19969 --->
		isValid = validateThisField(1, thisForm.Max_Program_Product_Display, "'Max Program Product Display' should be a valid number") && isValid;
		<!--- isValid = validateThisField(2, thisForm.nightly_report_email_list, "'Email Addresses' cannot be empty") && isValid; --->
		isValid = validateThisField(3, thisForm.volumeUOTID, "Select a volume unit of time") && isValid;

		if(isValid)
		{
			return true;
		}
		else
		{
			showMessageWindow();
			return false;
		}
	}
</script>

<!--- Set the update/save flag that will be passed to the next page --->
<FORM ACTION="contract_settings_Action.cfm" METHOD="post" onSubmit="javaScript: return validateForm(this);" name="myForm">
<CFIF Get_Settings.recordcount EQ 0>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="0">
<CFELSE>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="1">

	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated on <CFOUTPUT>#dateformat(Get_Settings.Contract_Expiration_Range_Date_Update, 'm/d/yyy')# #timeformat(Get_Settings.Contract_Expiration_Range_Date_Update, 'h:mm:ss TT')#</CFOUTPUT> by <CFOUTPUT>#Get_Settings.Editor_FullName#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
	<BR>
</CFIF>

<cfoutput>

<table CELLPADDING="2" CELLSPACING="2" border="0">
	<INPUT type="hidden" NAME="contract_expiration_range" VALUE="<CFIF len(Get_Settings.Contract_Expiration_Range) GT 0><CFOUTPUT>#Get_Settings.Contract_Expiration_Range#</CFOUTPUT><CFELSE>8</CFIF>">

	<tr>
		<td><B>How many days after request for approval should approver be reminded?</B><br><i>(If no reminder desired, leave as 0)</i></td>
		<td><span id="err_Days_For_Reminder_Email">&nbsp;&nbsp;</span></td>
		<td><INPUT TYPE="text" SIZE="4" NAME="Days_For_Reminder_Email" VALUE="#Get_Settings.Days_For_Reminder_Email#" onKeyUp="clenseText(this, '01234567890')"></td>
	</tr>

	<tr>
		<td><B>Default unit of time for volume</B></td>
		<td><span id="err_sp_volumeUOTID">&nbsp;&nbsp;</span></td>
		<td>
		<cfset current_Volume_UOT_ID = Get_Settings.Volume_UOT_ID />
    <!---
      22522/Anand Rao/24-Feb-2010
      Default unit of time for volume -- only allow Program
      changed the function call from getall to getUMZero which will
      return only Program UOM record
    --->
		<cfset qVolumeOUT = CreateObject("component", "components.volume.uotManager").getUMZero() />
		<select style="width:200px" name="volumeUOTID">
			<option value=""></option>
			<cfloop query="qVolumeOUT">
			<option value="#Volume_UOT_ID#" <cfif current_Volume_UOT_ID EQ Volume_UOT_ID>SELECTED</cfif>>#UOT_Desc#</option>
			</cfloop>
		</select>
		</td>
	</tr>

	<INPUT type="hidden" NAME="Global_UOM" VALUE="<CFIF len(Get_Settings.Volume_UOM_For_Performance_Indicator) GT 0><CFOUTPUT>#Get_Settings.Volume_UOM_For_Performance_Indicator#</CFOUTPUT><CFELSE>2</CFIF>">

	<!--- Default Sort option for scorecard --->
	<tr>
		<td><B>Default sort option for Scorecard</B></td>
		<td><span id="err_sp_scorecard_sort_option">&nbsp;&nbsp;</span></td>
		<td>
			<cfset ScoreCardList = "Program,Type,Title,Approved Date,Start Date,End Date">
				<select name="scorecard_sort_option" id="scorecard_sort_option">
					<option value="CN" <cfif Get_Settings.scorecard_sort_option EQ "CN">SELECTED</cfif>><cfoutput>#trim(ListGetAt(ScoreCardList,1))#</cfoutput></option>
					<option value="PT" <cfif Get_Settings.scorecard_sort_option EQ "PT">SELECTED</cfif>><cfoutput>#trim(ListGetAt(ScoreCardList,2))#</cfoutput></option>
					<option value="CT" <cfif Get_Settings.scorecard_sort_option EQ "CT">SELECTED</cfif>><cfoutput>#trim(ListGetAt(ScoreCardList,3))#</cfoutput></option>
					<!--- Dev Note: Milan (40939). "Approved date" is not a column on the program search flex grid.
					application.appsettingsget.getFlexProgramSearch() = 2 means "FLEX" option.
					--->
					<cfif application.appsettingsget.getFlexProgramSearch() NEQ 2>
					<option value="AD" <cfif Get_Settings.scorecard_sort_option EQ "AD">SELECTED</cfif>><cfoutput>#trim(ListGetAt(ScoreCardList,4))#</cfoutput></option>
					</cfif>
					<option value="SD" <cfif Get_Settings.scorecard_sort_option EQ "SD">SELECTED</cfif>><cfoutput>#trim(ListGetAt(ScoreCardList,5))#</cfoutput></option>
					<option value="ED" <cfif Get_Settings.scorecard_sort_option EQ "ED">SELECTED</cfif>><cfoutput>#trim(ListGetAt(ScoreCardList,6))#</cfoutput></option>
				</select>
		</td>
	</tr>
	<tr>
		<td><B>Ascending / Descending?</B></td>
		<td><span id="err_sp_scorecard_sort_method">&nbsp;&nbsp;</span></td>
		<td>
			<select name="scorecard_sort_method" id="scorecard_sort_method">
				<option value="ASC" <cfif Get_Settings.scorecard_sort_method EQ "ASC">SELECTED</cfif>>Ascending</option>
				<option value="DESC" <cfif Get_Settings.scorecard_sort_method EQ "DESC">SELECTED</cfif>>Descending</option>
			</select>
		</td>
	</tr>
	<!--- Setting to control if agreement number should display in program search --->
	<tr>
		<td><B>Display #application.returned_customer_setting.reference_number_label# Number in Program Search Results</B></td>
		<td><span id="">&nbsp;&nbsp;</span></td>
		<td><INPUT TYPE="checkbox" NAME="Display_Reference_Number_In_Search_Results" VALUE="1" <cfif Get_Settings.Display_Reference_Number_In_Search_Results EQ 1>checked</cfif>></td>
	</tr>
	<tr>
		<td><B>Cancel Program Options</B></td>
		<td><span id="err_Cancel_Program_Options">&nbsp;&nbsp;</span></td>
		<td>
			<select style="width:200px" name="Cancel_Program_Options" >
	 			<option value="1" <cfif Get_Settings.Cancel_Program_Options EQ 1>selected</cfif>>Cancel as if it never existed</option>
				<option value="2" <cfif Get_Settings.Cancel_Program_Options EQ 2>selected</cfif>>Cancel as of today</option>
				<option value="3" <cfif Get_Settings.Cancel_Program_Options EQ 3>selected</cfif>>Both</option>
	 		</select>
		</td>
	</tr>

<!--- D29654 - Settings for BB Reset/Delete, PRG Unlock/Reactivate START --->
	<tr>
		<td><B>Reactivate Cancelled Program</B>
					<!--- D32928: Settings Warning - Reactivate Cancelled Program START --->
						<CF_SmallHelp
								width="300"
								displayShifyX = "0"
								imgPath="/images/help_small.gif"
								imgWidth="14"
								imgHeight="13"
								dropdownCheck="0"
								>
							Selecting this option will not have an impact on any ERP program communications and should be used with caution.
							For clients with program-related integration, if a given program has already been interfaced as Cancelled, and the program is then reactivated using this tool,
							the ERP may have errors in process subsequent approvals of that program.
						</CF_SmallHelp>
						<!--- D32928: Settings Warning - Reactivate Cancelled Program END --->



		</td>
		<td><span>&nbsp;&nbsp;</span></td>
		<td>

		<CF_smallLink
					title = "Click Here"
					url = "/settings/reactivate_programs.cfm"
					parameters = ""
				>
		</td>
	</tr>
	<cfif application.appsettingsget.getThirdPartyBBUpload() EQ 3>
	<tr>
		<td><B>Unlock Program </B></td>
		<td><span id="err_sp_scorecard_sort_method">&nbsp;&nbsp;</span></td>
		<td>

		<CF_smallLink
					title = "Click Here"
					url = "/settings/unlock_programs.cfm"
					parameters = ""
				>
		</td>
	</tr>
	</cfif>
<!--- D29654 - Settings for BB Reset/Delete, PRG Unlock/Reactivate END --->
<!--- D29824:New Settings.. --->
	<tr>
		<td><B>Convert Program To Different Template</B>
		<!--- D32929: Settings Warning - Convert Program to Different Template START --->
			<CF_SmallHelp
					width="300"
					displayShifyX = "0"
					imgPath="/images/help_small.gif"
					imgWidth="14"
					imgHeight="13"
					dropdownCheck="0"
					>

						CAUTION:  Programs reassigned to a new template will inherit the settings of the new template.
						If the two templates are not consistent, there can be issues with Business Segments, Filters, Budgets and master data objects.

			</CF_SmallHelp>
			<!--- D32929: Settings Warning - Convert Program to Different Template END --->
		</td>
		<td><span>&nbsp;&nbsp;</span></td>
		<td>

		<CF_smallLink
					title = "Select Template"
					url = "/settings/convert_programs.cfm"
					parameters = ""
				>
		</td>
	</tr>
<!--- D29824:New Settings.. --->
<!--- START: D36667: Volume Automation Settings Extract/Anand Rao/08-Apr-2013 --->
	<tr>
		<td><b>Template Volume Automation Settings</b><td>
		<td>
			<font color="Red">[</font>
			<a href="##" onClick="NewWindow('Volume_Automation_Settings_Extract.cfm', 'Volume_Automation_Settings_Extract', '600', '400', 'Yes', 'Yes')">
				<strong>Extract of Volume Automation Settings</strong>
			</a>
			<font color="Red">]</font>
		</td>
	</tr>

<!--- END: D36667: Volume Automation Settings Extract/Anand Rao/08-Apr-2013 --->

	<!---TSF: Label 9704 - Added Unit of Time setting for margin if Layered Margin is on--->
	<cfif application.appsettingsget.getApprovalLayeredOn()>
		<tr>
			<td>
				<B>Default unit of time for margin</B>
			</td>
			<td>&nbsp;&nbsp;</td>
			<td>
				<cfsilent>
				<!---set the current margin unit of time set in the database--->
				<cfset variables.current_Margin_UOT_ID	= Get_Settings.Margin_UOT_ID />
				<!---Initialize the uotManager and get the uot for program and annual--->
				<cfset variables.uotManager 			= CreateObject("component", "components.volume.uotManager") />
				<cfset variables.programUOT 			= variables.uotManager.get(1) />
				<cfset variables.annualUOT 				= variables.uotManager.get(6) />
				</cfsilent>
				<select style="width:200px" name="marginUOTID">
					<option value="#trim(variables.programUOT.getId())#" <cfif not compareNoCase(variables.current_Margin_UOT_ID, trim(variables.programUOT.getId()))>SELECTED</cfif>>#trim(variables.programUOT.getDesc())#</option>
					<option value="#trim(variables.annualUOT.getId())#" <cfif not compareNoCase(variables.current_Margin_UOT_ID, trim(variables.annualUOT.getId()))>SELECTED</cfif>>#trim(variables.annualUOT.getDesc())#</option>
				</select>
			</td>
		</tr>
	</cfif>
	<tr>
		<td><B>Maximum Program Products to Display?</B><br><i>(Special Product display handling for very large programs such as Brokerage)</i></td>
		<td><span id="err_Max_Program_Product_Display">&nbsp;&nbsp;</span></td>
		<td><INPUT TYPE="text" SIZE="4" NAME="Max_Program_Product_Display" VALUE="#Get_Settings.Max_Program_Product_Display#" onKeyUp="clenseText(this, '01234567890')"></td>
	</tr>
	<tr>
		<td>
		    <B>Maximum Program Products for margin page with fixed header</B> <br>
		    <i>(If program exceeds this value, the margin page will not freeze the header row)</i>
		</td>
		<td>
		    <span id="err_max_program_products_for_margin_page">&nbsp;&nbsp;</span>
		</td>
		<td>
		    <input type="text" size="4" name="max_program_products_for_fixed_header_margin_page"
			       value="#udf.get_setting( 'max_program_products_for_fixed_header_margin_page', 0 )#" onKeyUp="clenseText(this, '01234567890')">
		</td>
	</tr>
	<tr>
		<td><B>Maximum Operator ID Length</B>
			   <img src="/images/help_small.gif" title="Only applies to adding/editing operators within the Forge application"/>
		</td>
		<td>&nbsp;&nbsp;</span></td>
		<td><INPUT TYPE="text" SIZE="1" NAME="Max_Operator_ID_Length" VALUE="#MaxOperatorIDLength#" MAXLENGTH="2" onKeyUp="clenseText(this, '01234567890')"></td>
	</tr>
	<tr>
		<td><B>Maximum Program Title Length</B>
		</td>
		<td>&nbsp;&nbsp;</span></td>
		<td><INPUT TYPE="text" SIZE="1" NAME="Max_Program_Title_Length" VALUE="#MaxProgramTitleLength#" MAXLENGTH="4" onKeyUp="clenseText(this, '01234567890')"></td>
	</tr>
  	<!--- Pullback Settings --->
	<!--- 23238 Do not show pullback settings if app setting for pullbacks is OFF --->
	<cfif application.appsettingsget.getPullbacksOn()>
	<tr>
		<td><B>#application.appsettingsget.getPullbackLabel()# requires approval</B>
		</td>
		<td>&nbsp;&nbsp;</span></td>
		<td><INPUT TYPE="checkbox" NAME="Pullback_Requires_Approval" VALUE="1" <cfif Get_Settings.Pullback_Requires_Approval EQ 1>checked</cfif>></td>
	</tr>
	<tr>
		<td><B>Modify #application.appsettingsget.getPullbackLabel()# rates in distributor program</B>
		</td>
		<td>&nbsp;&nbsp;</span></td>
		<td><INPUT TYPE="checkbox" NAME="Pullback_Modify_Corporate_Program_Rates" VALUE="1" <cfif Get_Settings.Pullback_Modify_Corporate_Program_Rates EQ 1>checked</cfif>></td>
	</tr>
	<tr>
		<td><B>Modify #application.appsettingsget.getPullbackLabel()# rates in operator program</B>
		</td>
		<td>&nbsp;&nbsp;</span></td>
		<td><INPUT TYPE="checkbox" NAME="Pullback_Modify_Operator_Program_Rates" VALUE="1" <cfif Get_Settings.Pullback_Modify_Operator_Program_Rates EQ 1>checked</cfif>></td>
	</tr>
	</cfif>
	<!--- Pullback Settings --->


  <!--- Settings Defaults for the Control Panel in the flex volume applicator tool --->

  <tr>
		<td>
      <B>Volume Page - distributor template Group A default</B>
		</td>
		<td>&nbsp;&nbsp;</td>
		<td>
      <select style="width:200px" name="Volume_Distributor_Template_GroupA">
        <option value="CUSTOMER" selected <cfif Get_Settings.Volume_Distributor_Template_GroupA EQ "CUSTOMER">SELECTED</cfif>>#application.returned_customer_setting.distributor_label_singular#</option>
        <option value="ITEM" <cfif Get_Settings.Volume_Distributor_Template_GroupA EQ "ITEM">SELECTED</cfif>>#application.returned_customer_setting.item_label#</option>
      </select>
    </td>
	</tr>
  <tr>
		<td>
      <B>Volume Page - operator template Group A default</B>
		</td>
		<td>&nbsp;&nbsp;</td>
		<td>
    <!--- Operator option will show up only for the operator templates --->
      <select style="width:200px" name="Volume_Operator_Template_GroupA">
        <option value="CUSTOMER" selected <cfif Get_Settings.Volume_Operator_Template_GroupA EQ "CUSTOMER">SELECTED</cfif>>#application.returned_customer_setting.distributor_label_singular#</option>
        <option value="ITEM" <cfif Get_Settings.Volume_Operator_Template_GroupA EQ "ITEM">SELECTED</cfif>>#application.returned_customer_setting.item_label#</option>
        <option value="OPERATOR" <cfif Get_Settings.Volume_Operator_Template_GroupA EQ "OPERATOR">SELECTED</cfif>>#application.returned_customer_setting.operator_label_singular#</option>
      </select>
    </td>
	</tr>
  <tr>
		<td><B>Payment History � product attribute to display on accrual page:  </B></td>
		<td>&nbsp;&nbsp;</td>
		<td>
		<select name='Accrual_Product_Group_Level_ID'>
		<cfloop query='qAllProductAttributes'>
		<option value='#qAllProductAttributes.Product_Group_Level_ID#' #(Get_Settings.Accrual_Product_Group_Level_ID eq qAllProductAttributes.Product_Group_Level_ID ? 'selected' : '')#>#qAllProductAttributes.Group_Level_Desc#</option>
		</cfloop>
		</select>
		</td>
  </tr>
  <tr>
		<td><B>Program Search 'current/catalog view' contains</B></td>
		<td>&nbsp;&nbsp;</td>
		<td>
		<cfloop query="qryProgramStatusList">
				#Contract_Status_Type_Desc#<INPUT TYPE="checkbox" NAME="Program_Status" VALUE="#Contract_Status_Type_ID#" <cfif Contract_Status_Type_Selected EQ 1>checked</cfif>>
		</cfloop>
		</td>
	</tr>
<cfif application.appsettingsget.getProgramSearchDollarsAndVolume()>
  <tr>
		<td><B> Flex Program Search Display:</B></td>
		<td>&nbsp;&nbsp;</td>
		<td>&nbsp;&nbsp;</td>
	</tr>
    <!--- 50324: Display Trade Dollars for program search --->
    <tr class="programSearchAttributes">
    <td style="padding-left:20px;"> Display  <cfif application.appsettingsget.getBudgetsFunctionalityOn()>#qbudgetReport.Committed_Dollar_Label#<cfelse>Trade $</cfif></td>
    <td>&nbsp;&nbsp;</td>
    <td align="left">
      <input value="1" type="checkbox" name="Display_Trade_Dollars" id="Display_Trade_Dollars" <cfif Get_Settings.Display_Trade_Dollars EQ 1>checked</cfif>>
     <select name="Display_Trade_Dollars_Type">
	 	<option value="0" <cfif Get_Settings.Display_Trade_Dollars_Type EQ 0>selected</cfif>>Total Program Value</option>
		<option value="1" <cfif Get_Settings.Display_Trade_Dollars_Type EQ 1>selected</cfif>>Version Value</option>
     </select>
    </td>
  </tr>
    <!--- 50324: Display payment Dollars for program search --->
    <tr class="programSearchAttributes">
    <td style="padding-left:20px;"> Display <cfif application.appsettingsget.getBudgetsFunctionalityOn()>#qbudgetReport.Approved_Payment_Dollar_Label#<cfelse>Pymt $</cfif></td>
    <td>&nbsp; </td>
    <td align="left">
      <input value="1" type="checkbox" name="Display_Payment_Dollars" id="Display_Payment_Dollars" <cfif Get_Settings.Display_Payment_Dollars EQ 1>checked</cfif>>
    </td>
  </tr>
    <!--- 50324: Display volume for program search --->
    <tr class="programSearchAttributes">
    <td style="padding-left:20px;"> Display Volume</td>
    <td>&nbsp;&nbsp;</td>
    <td align="left">
      <input value="1" type="checkbox" name="Display_Volume" id="Display_Volume" <cfif Get_Settings.Display_Volume EQ 1>checked</cfif>>
     <select name="Display_Volume_Type">
	 	<option value="0" <cfif Get_Settings.Display_Volume_Type EQ 0>selected</cfif>>Total Program Value</option>
		<option value="1" <cfif Get_Settings.Display_Volume_Type EQ 1>selected</cfif>>Version Value</option>
     </select>    </td>
  </tr>
    <!--- Display operator info for program search --->
    <tr class="programSearchAttributes">
    <td style="padding-left:20px;"> Display #application.returned_customer_setting.operator_label_singular# in download</td>
    <td>&nbsp;&nbsp;</td>
    <td align="left">
      <input value="1" type="checkbox" name="Display_Operator_Info" id="Display_Operator_Info" <cfif Get_Settings.Display_Operator_Info EQ 1>checked</cfif>>
	</td>
  </tr>
</cfif>

<!--- Dev Note: drachala; D29226: New settings page to update template to latest template setting  START
Added/Changed: Clear Temp Files/Clear Program Files/Clear Cache/Update programs to use latest template settings--->
<tr valign="top">
	<td nowrap><B>Clear Temp Files</B></td>
	<td>&nbsp; </td>
	<td nowrap colspan="3"><input type="button" value="Click here" onClick="NewWindow('/settings/clear_temp_files.cfm','temp','600','400','No', 'No'); return false;"></td>
</tr>
<tr valign="top">
	<td nowrap><B>Clear Program Files</B></td>
	<td>&nbsp; </td>
	<td nowrap colspan="3"><input type="button" value="Click here" onClick="NewWindow('/scheduled/clear_program_files.cfm','temp','600','400','No', 'No'); return false;"></td>
</tr>
<tr valign="top">
	<td nowrap><B>Clear Cache</B></td>
	<td>&nbsp; </td>
	<td nowrap colspan="3"><input type="button" value="Click here" onClick="NewWindow('/scheduled/clear_cache.cfm','temp','600','400','No', 'No'); return false;"></td>
</tr>
<tr valign="top">
	<td nowrap><B>Update programs to use latest template settings</B></td>
	<td>&nbsp; </td>
	<td nowrap colspan="3"><input type="button" value="Click here" onClick="NewWindow('/settings/update_programs_to_latest_templates.cfm','UpdatePrograms','500','250','No', 'No'); return false;"></td>
</tr>
<!--- End Dev Note: drachala; D29226: New settings page to update template to latest template setting  --->

<!---  --->
<tr>
	<td><B>Update CRA</B></td>
	<td>&nbsp; </td>
	<td nowrap colspan="3"><input type="button" value="Click here" onClick="NewWindow('/settings/update_cra.cfm','Update_CRA','600','400','No', 'No'); return false;"></td>
</tr>
<tr>
	<td><b>Run revision reports</b></td>
	<td>&nbsp;</td>
	<td><input type="button" value="Click here" onClick="NewWindow('/settings/revision_report.cfm','Revision_Report','600','400','No', 'No'); return false;"></td>
</tr>
<!---  --->
<!--- D31522: Dashboard data START--->
<tr>
	<td><b>Run Dashboard Data</b></td>
	<td>&nbsp;</td>
	<td><input type="button" value="Click here" onClick="NewWindow('/settings/Dashboard_data.cfm','Dashboard_Data','600','400','No', 'No'); return false;"></td>
</tr>
<!--- D31522: Dashboard data END--->
</table>

<!--- D20217: Volume Applicator Upgrades section start --->
<p>
<span style="font-weight:bold;font-size:13px">Volume Help Text</span>&nbsp;<br>
<input readonly type="text" name="remain_length" size="3" maxlength="3" value="4000">&nbsp;&nbsp;<span style="font-weight:bold;text-decoration:none;">Characters Remaining &nbsp;</span><br>
</p>
  <!--- D20217: Volume Applicator Upgrades section end --->
<!--- Dev Note: drachala; D28078: Text Editor tools in Forge not working with Windows 7  START
What  I did: Comment out CF_ACTIVEEDIT and replace it with TEXTAREA for WYSIWYG tool--->
<textarea id="textarea" name="Volume_Help_Text" style="width:610px;height:200px;" onKeyDown="textCounter(document.myForm.Volume_Help_Text,document.myForm.remain_length,4000)"
onKeyUp="textCounter(document.myForm.Volume_Help_Text,document.myForm.remain_length,4000)">
<cfif Get_Settings.Volume_Help_Text NEQ "">
<CFOUTPUT>#Get_Settings.Volume_Help_Text#</CFOUTPUT>
</cfif>
</textarea>
<!--- End Dev Note: drachala; D28078:Text Editor tools in Forge not working with Windows 7 END  --->
</cfoutput>
<BR>

<INPUT TYPE="hidden" NAME="User_ID" VALUE="<CFOUTPUT>#request.AccessStructure.User_ID#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="Date_Updated" VALUE="<CFOUTPUT>#createodbcdatetime(now())#</CFOUTPUT>">
<!--- Dev Note: Clay 10151 Hide Nightly Report form fields.  --->
<INPUT TYPE="hidden" NAME="nightly_report_email_list" value="<cfoutput>#Get_Settings.Nightly_Report_Email_List#</cfoutput>">

<INPUT TYPE="hidden" NAME="Volume_Resolution" VALUE="1">
<INPUT TYPE="hidden" NAME="Margin_Calc_Display" VALUE="1">
<!--- Pass a list of all the stauses. We need to compare with the checked statuses on the action page--->
<cfoutput>
<INPUT TYPE="hidden" NAME="All_Program_Statuses" VALUE="#ValueList(qryProgramStatusList.Contract_Status_Type_ID)#">
</cfoutput>

<div align="center">
<INPUT TYPE="submit" VALUE="Save Preferences...">
</div>

</FORM>

<CF_MessageWindow />
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<SCRIPT LANGUAGE="JavaScript">
	function textCounter(field,cntfield,maxlimit) {
		if (field.value.length > maxlimit) // if too long...trim it!
			field.value = field.value.substring(0, maxlimit);
		// otherwise, update 'characters left' counter
		else
			cntfield.value = maxlimit - field.value.length;
	}
</script>
</BODY>
</HTML>
