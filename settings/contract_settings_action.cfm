<cfparam name="form.Contract_Expiration_Range" default="8">
<cfparam name="Days_For_Reminder_Email" default="0">
<cfparam name="form.Nightly_Report_Email_List" default="">
<cfparam name="FORM.marginUOTID" default="0">
<cfparam name="applicationpath" default="#application.apppath#">
<cfparam name="FORM.Global_UOM" default="2">
<cfparam name="FORM.Pullback_Requires_Approval" default="0">
<cfparam name="FORM.Pullback_Modify_Corporate_Program_Rates" default="0">
<cfparam name="FORM.Pullback_Modify_Operator_Program_Rates" default="0">
<cfparam name="Form.Display_Trade_Dollars" default="0">
<cfparam name="Form.Display_Trade_Dollars_Type" default="0">
<cfparam name="Form.Display_Payment_Dollars" default="0">
<cfparam name="Form.Display_Volume" default="0">
<cfparam name="Form.Display_Volume_Type" default="0">
<cfparam name="Form.Accrual_Product_Group_Level_ID" default="0">
<cfparam name="Form.Display_Operator_Info" default="0">
<cfparam name="Form.Display_Reference_Number_In_Search_Results" default="0">

<cfif len(trim(form.Days_For_Reminder_Email)) LT 1>
	<cfset Form.Days_For_Reminder_Email = 0>
</cfif>

<cfif isnumeric(FORM.contract_expiration_range)>
	<cfif FORM.up_sv EQ 0>
		<CFQUERY NAME="INSERT" datasource="#application.datasource#">
			INSERT INTO _Users_Settings
			(Contract_Expiration_Range, User_ID, Contract_Expiration_Range_Date_Update, Contract_Settings_Editor_ID, Volume_Resolution, Margin_Calc_Display, Nightly_Report_Email_List, Volume_UOT_ID, Volume_UOM_For_Performance_Indicator, scorecard_sort_option, scorecard_sort_method, Margin_UOT_ID, Max_Operator_ID_Length, Max_Program_Title_Length, Volume_Distributor_Template_GroupA, Volume_Operator_Template_GroupA, Volume_Help_Text,
			Pullback_Requires_Approval, Pullback_Modify_Corporate_Program_Rates, Pullback_Modify_Operator_Program_Rates, Display_Trade_Dollars, Display_Trade_Dollars_Type, Display_Payment_Dollars,
			Display_Volume, Display_Volume_Type,Accrual_Product_Group_Level_ID,Display_Operator_Info, Display_Reference_Number_In_Search_Results)
			VALUES
			('#int(FORM.contract_expiration_range)#', '#request.AccessStructure.Company_Main_ID#', #createodbcdatetime(Now())#, '#request.AccessStructure.User_ID#','#Form.Volume_Resolution#', '#form.Margin_Calc_Display#', '#form.Nightly_Report_Email_List#', #FORM.volumeUOTID#, #FORM.Global_UOM#, '#FORM.scorecard_sort_option#', '#FORM.scorecard_sort_method#', #FORM.marginUOTID#, #Max_Operator_ID_Length#, #Max_Program_Title_Length#, '#FORM.Volume_Distributor_Template_GroupA#', '#FORM.Volume_Operator_Template_GroupA#', '#FORM.Volume_Help_Text#',
			'#Form.Pullback_Requires_Approval#', '#Form.Pullback_Modify_Corporate_Program_Rates#', '#Form.Pullback_Modify_Operator_Program_Rates#', '#Form.Display_Trade_Dollars#','#Form.Display_Trade_Dollars_Type#','#Form.Display_Payment_Dollars#',
			'#Form.Display_Volume#','#Form.Display_Volume_Type#','#Form.Accrual_Product_Group_Level_ID#','#Form.Display_Operator_Info#', '#form.Display_Reference_Number_In_Search_Results#')
		</CFQUERY>

	<cfelse>
		<CFQUERY NAME="UPDATE" datasource="#application.datasource#">
			UPDATE _Users_Settings
			SET Contract_Expiration_Range = '#int(FORM.contract_expiration_range)#',
				Contract_Expiration_Range_Date_Update = #createodbcdatetime(Now())#,
				Volume_Resolution = '#Form.Volume_Resolution#',
				Margin_Calc_Display = '#form.Margin_Calc_Display#',
				Nightly_Report_Email_List = '#form.Nightly_Report_Email_List#',
				Volume_UOT_ID = #FORM.volumeUOTID#,
				Volume_UOM_For_Performance_Indicator = #FORM.Global_UOM#,
				Days_For_Reminder_Email = #FORM.Days_For_Reminder_Email#,
				Contract_Settings_Editor_ID = '#request.AccessStructure.User_ID#',
				scorecard_sort_option = '#FORM.scorecard_sort_option#',
				scorecard_sort_method = '#FORM.scorecard_sort_method#',
				Max_Program_Product_Display = '#Form.Max_Program_Product_Display#',
				Max_Operator_ID_Length = '#Form.Max_Operator_ID_Length#',
				Max_Program_Title_Length = '#Form.Max_Program_Title_Length#',
		        Volume_Distributor_Template_GroupA = '#FORM.Volume_Distributor_Template_GroupA#',
		        Volume_Operator_Template_GroupA = '#FORM.Volume_Operator_Template_GroupA#',
		        Volume_Help_Text = '#FORM.Volume_Help_Text#',
		        Pullback_Requires_Approval = '#Form.Pullback_Requires_Approval#',
		        Pullback_Modify_Corporate_Program_Rates = '#Form.Pullback_Modify_Corporate_Program_Rates#',
		        Pullback_Modify_Operator_Program_Rates = '#Form.Pullback_Modify_Operator_Program_Rates#',
			Cancel_Program_Options = '#Form.Cancel_Program_Options#',
			Display_Trade_Dollars = '#Form.Display_Trade_Dollars#',
			Display_Trade_Dollars_Type = '#Form.Display_Trade_Dollars_Type#',
			Display_Payment_Dollars = '#Form.Display_Payment_Dollars#',
			Display_Volume = '#Form.Display_Volume#',
			Display_Operator_Info = '#Form.Display_Operator_Info#',
			Display_Volume_Type = '#Form.Display_Volume_Type#',
			Accrual_Product_Group_Level_ID = '#Form.Accrual_Product_Group_Level_ID#',
			Display_Reference_Number_In_Search_Results = '#form.Display_Reference_Number_In_Search_Results#'

				<cfif FORM.marginUOTID neq 0>,Margin_UOT_ID = #FORM.marginUOTID#</cfif>

			WHERE User_ID = '#request.AccessStructure.Company_Main_ID#'
		</CFQUERY>
	</cfif>
</cfif>

<!--- 2022 Feb 3 - define new settings to be saved in _Settings here, append the form elements inside this array --->
<cfset _settings = [ "max_program_products_for_fixed_header_margin_page" ]>
<cfoutput>
	<cfloop array="#_settings#" item="_setting">
		<cfif structKeyExists(form, _setting) eq false>
			<cfset form[ _setting ] = ''>
		</cfif>

		<cfquery datasource="#application.datasource#" result="qResult">
			UPDATE _Settings
			   SET Value = '#form[ _setting ]#'
			 WHERE Input_Name = '#_setting#'
		</cfquery>

		<cfif qResult.recordCount eq 0>
			<cfquery datasource="#application.datasource#">
				INSERT INTO _Settings ( Input_Name, Value )
					           VALUES ( '#_setting#', '#form[ _setting ]#')
			</cfquery>
		</cfif>
	</cfloop>
</cfoutput>



<!--- Set 0 or 1 for the different statuses in the Contract_Search_Options table. "All_Program_Statuses" has
all the statuses. "Program_Status" holds the checked statuses (form page) only.
--->

<!--- Loop through all the stasuses --->
<cfloop list="#All_Program_Statuses#" index="i">
	<!--- Check for Checked Statuses --->
	<cfset PrgStatusExist = ListFind(Program_Status,i)>

	<cfif PrgStatusExist GT 0>
		<cfset PrgStatusExist = 1>
	</cfif>

		<cfset useLakebaseForUpdateStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_search_options")>
<cfif useLakebaseForUpdateStatus>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_search_options",
			{
				"contract_status_type_id" = "eq.#i#"
			},
			{
				"contract_status_type_selected" = "#PrgStatusExist#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateStatus>
<cfquery name="UpdateStatus" datasource="#application.datasource#">
			UPDATE Contract_Search_Options
			SET Contract_Status_Type_Selected = '#PrgStatusExist#'
			WHERE Contract_Status_Type_ID = '#i#'
		</cfquery>
</cfif>
</cfloop>

<CFSET tempfilepath = APPLICATIONPATH & "\Common_Files\contracts\Program_Releaser\Nightly_Emailer_Data.cfm">

<cfif fileexists(tempfilepath) EQ "YES">
	<cffile action="DELETE" file="#tempfilepath#">
</cfif>

<cffile action="WRITE" file="#tempfilepath#" output="#request.AccessStructure.Company_Main_ID#" addnewline="Yes">

<CFLOCATION URL="contract_settings.cfm?ID=#createuuid()#&t=#now()#" ADDTOKEN="No">

