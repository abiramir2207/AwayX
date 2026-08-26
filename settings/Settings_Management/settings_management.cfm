<!---
***********************************************************************
Created By: Jianxiu Wei
File Path:  AwayX\settings\settings_management\settings_management.cfm
Created Date: 
Purpose: add a new settings page called Settings Management under settings / administration section
to control the first page of program wizard and user profile page 
***********************************************************************
--->

<CFSET PAGETITLE = "SYSTEM ADMINISTRATION: SETTINGS MANAGEMENT">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
</HEAD>
<BODY>
<style>
    body {
        background-color: Whitesmoke;
    }
    .last_changed {
        background-color: #ffedd2;
        border-bottom: 1px solid #d8d9dd;
        border-radius: 5px;
        color: #343540;
        font-size: 12px;
        margin-bottom: 10px;
        padding: 7px 0 5px 5px;
        text-align: center;
        /* font-weight: bold; */
    }
</style>        
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfoutput>
<cfparam name="Generic_Type" 	default="0">
<cfparam name="Form.Generic_Type" 	default="#Generic_Type#">
<cfparam name="tabHeader" 		default="1">
<cfparam name="Action"		default="">
<cfset variables.retro = "">
</cfoutput>

<!--- Query Generic Type --->
<cfquery name="qGetGenericType" datasource="#application.datasource#">
	SELECT Generic_Type, ISNULL(Generic_Type_ID, 0) as Generic_Type_ID
	FROM Generic_Type
	WHERE Settings_Management =1
	ORDER BY Generic_Type_ID
</cfquery>

<cfset useLakebaseForGetGenericTypeID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetgenerictype")>
<cfif useLakebaseForGetGenericTypeID>
	<cftry>
		<cfset GetGenericTypeID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetgenerictype", {
				"generic_type" = "eq.#Form.Generic_Type#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetGenericTypeID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetGenericTypeID>
<cfquery name="GetGenericTypeID" dbtype="query"> 
  select * from qGetGenericType where Generic_Type = '#Form.Generic_Type#' 
</cfquery>
</cfif>
<!--- 	Payment paid To --->
<cfquery name="GetPaymentPaidToTypes" datasource="#application.datasource#">
	SELECT 	*
	FROM 	Payment_Paid_To_Types
	WHERE 	Deleted = 0
	<cfif Generic_Type IS "Brokerage" > and	Payment_Paid_To_ID = 3 </cfif>
	ORDER BY Payment_Paid_To_ID
</cfquery>

<cfset useLakebaseForGetCurrencyTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("currency")>
<cfif useLakebaseForGetCurrencyTypes>
	<cftry>
		<cfset GetCurrencyTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("currency", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"order" = "currency_name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCurrencyTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCurrencyTypes>
<cfquery name="GetCurrencyTypes" datasource="#application.datasource#">
	SELECT 	*
	FROM 	Currency
	WHERE 	Deleted = 0
	AND 	Active = 1
	ORDER BY Currency_Name
</cfquery>
</cfif>

<cfoutput><CF_MessageWindow></cfoutput>

<script language="JavaScript">
function SubmitForm()
{
	var ErrorCount = 0;

	if (SettingsManagment.Generic_Type.value  =="0")
	{
		ErrorCount++;
		queueMessage("Please select a settings page", document.all.error_title);
		
	}
	else
	{
		clearQueue(document.all.error_title);
	}

	if(ErrorCount == 0) {
		SettingsManagment.submit();
		return false;	
	}		
	else {
		showMessageWindow();
		return false;
	}	
}
</script>

<cfquery name="getCurrentSettings" datasource="#application.datasource#">
	SELECT 	general_Settings.*, 
		Distributor_Updated.Name_First as Distributor_Updated_Name_First, Distributor_Updated.Name_Last as Distributor_Updated_Name_Last, 
		FieldExe_Updated.Name_First as FieldExe_Updated_Name_First, FieldExe_Updated.Name_Last as FieldExe_Updated_Name_Last, 
		OperatorHQ_Updated.Name_First as OperatorHQ_Updated_Name_First, OperatorHQ_Updated.Name_Last as OperatorHQ_Updated_Name_Last, 
		OperatorDP_Updated.Name_First as OperatorDP_Updated_Name_First, OperatorDP_Updated.Name_Last as OperatorDP_Updated_Name_Last, 
		Brokerage_Updated.Name_First as Brokerage_Updated_Name_First, Brokerage_Updated.Name_Last as Brokerage_Updated_Name_Last, 
		LumpAutoPay_Updated.Name_First as LumpAutoPay_Updated_Name_First, LumpAutoPay_Updated.Name_Last as LumpAutoPay_Updated_Name_Last,
		Profiles_Updated.Name_First as Profiles_Updated_Name_First, Profiles_Updated.Name_Last as Profiles_Updated_Name_Last
	FROM general_Settings
		LEFT JOIN _Users Distributor_Updated 
		ON  general_Settings.Settings_Management_Distributor_Updated_By = Distributor_Updated.User_ID
		LEFT JOIN _Users FieldExe_Updated 
		ON  general_Settings.Settings_Management_FieldExe_Updated_By = FieldExe_Updated.User_ID 
		LEFT JOIN _Users OperatorHQ_Updated 
		ON general_Settings.Settings_Management_OperatorHQ_Updated_By = OperatorHQ_Updated.User_ID 
		LEFT JOIN _Users OperatorDP_Updated 
		ON general_Settings.Settings_Management_OperatorDP_Updated_By = OperatorDP_Updated.User_ID 
		LEFT JOIN _Users Brokerage_Updated 
		ON general_Settings.Settings_Management_Brokerage_Updated_By = Brokerage_Updated.User_ID 
		LEFT JOIN _Users LumpAutoPay_Updated 
		ON general_Settings.Settings_Management_LumpAutoPay_Updated_By = LumpAutoPay_Updated.User_ID 
		LEFT JOIN _Users Profiles_Updated
		ON general_Settings.Settings_Management_Profiles_Updated_By = Profiles_Updated.User_ID 
</cfquery>

<form action="settings_management.cfm" method="post" name="SettingsManagment">
<FIELDSET STYLE="padding:8px; border: 1px solid Blue;width:90%">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">settings page</LEGEND>
<table width="100%" CELLPADDING="1" CELLSPACING="0" >
	<tr valign="top" align="center" >
		<td nowrap  style="border-bottom:none;">Select Settings Page: 
			<select name="Generic_Type" onchange="SubmitForm();">
				<option value="0">Select Settings Page</option>
				<cfoutput>
				<cfloop query="qGetGenericType">
					<option value="#qGetGenericType.Generic_Type#" <cfif #qGetGenericType.Generic_Type# eq #Form.Generic_Type#>selected</cfif> >#qGetGenericType.Generic_Type#</option>
				</cfloop>
				</cfoutput>
				<option value="Profiles" <cfif #Form.Generic_Type# eq "Profiles">selected</cfif>>Profiles</option>
			</select>
			<!---<B><font COLOR="Red">[</font><A ONCLICK="SubmitForm();" STYLE="cursor: pointer;">Get Settings</A><font COLOR="Red">]</font></B>--->
		</td>	
	</tr>
</table>
</FIELDSET>
</form>

<CFOUTPUT>
    <cfif #Form.Generic_Type# eq "Profiles">
        <cfif getCurrentSettings.Settings_Management_Profiles_Updated_Date neq ''>
            <div class="last_changed">
                The profile settings were last updated on   <b>#dateformat(getCurrentSettings.Settings_Management_Profiles_Updated_Date, 'm/d/yyy')# </b>
                                                        at #timeformat(getCurrentSettings.Settings_Management_Profiles_Updated_Date, 'h:mm:ss TT')# 
                                                        by <b>#getCurrentSettings.Profiles_Updated_Name_First# #getCurrentSettings.Profiles_Updated_Name_Last#</b>
            </div>
        </cfif>
    <cfelseif #GetGenericTypeID.Generic_Type_ID# eq "1">
        <cfif getCurrentSettings.Settings_Management_Distributor_Updated_Date neq ''>
            <div class="last_changed">
                The #Form.Generic_Type# Template Settings were last updated on  <b>#dateformat(getCurrentSettings.Settings_Management_Distributor_Updated_Date, 'm/d/yyy')# </b>
                                                                        at #timeformat(getCurrentSettings.Settings_Management_Distributor_Updated_Date, 'h:mm:ss TT')# 
                                                                        by <b>#getCurrentSettings.Distributor_Updated_Name_First# #getCurrentSettings.Distributor_Updated_Name_Last#</b>
            </div>
        </cfif>
    <cfelseif #GetGenericTypeID.Generic_Type_ID# eq "2">
        <cfif getCurrentSettings.Settings_Management_FieldExe_Updated_Date neq ''>
            <div class="last_changed">
                The #Form.Generic_Type# template settings were last updated on  <b>#dateformat(getCurrentSettings.Settings_Management_FieldExe_Updated_Date, 'm/d/yyy')# </b>
                                                                        at #timeformat(getCurrentSettings.Settings_Management_FieldExe_Updated_Date, 'h:mm:ss TT')# 
                                                                        by <b>#getCurrentSettings.FieldExe_Updated_Name_First# #getCurrentSettings.FieldExe_Updated_Name_Last#</b>
            </div>
        </cfif>

    <cfelseif #GetGenericTypeID.Generic_Type_ID# eq "3">
        <cfif getCurrentSettings.Settings_Management_OperatorHQ_Updated_Date neq ''>
            <div class="last_changed">
            The #Form.Generic_Type# template settings were last updated on  <b>#dateformat(getCurrentSettings.Settings_Management_OperatorHQ_Updated_Date, 'm/d/yyy')# </b>
                                                                        at #timeformat(getCurrentSettings.Settings_Management_OperatorHQ_Updated_Date, 'h:mm:ss TT')# 
                                                                        by <b>#getCurrentSettings.OperatorHQ_Updated_Name_First# #getCurrentSettings.OperatorHQ_Updated_Name_Last#</b>
            </div>
        </cfif>
    <cfelseif #GetGenericTypeID.Generic_Type_ID# eq "4">
        <cfif getCurrentSettings.Settings_Management_OperatorDP_Updated_Date neq ''>
            <div class="last_changed">
            The #Form.Generic_Type# template settings were last updated on  <b>#dateformat(getCurrentSettings.Settings_Management_OperatorDP_Updated_Date, 'm/d/yyy')# </b>
                                                                        at #timeformat(getCurrentSettings.Settings_Management_OperatorDP_Updated_Date, 'h:mm:ss TT')# 
                                                                        by <b>#getCurrentSettings.OperatorDP_Updated_Name_First# #getCurrentSettings.OperatorDP_Updated_Name_Last#</b>
            </div>
        </cfif>
    <cfelseif #GetGenericTypeID.Generic_Type_ID# eq "8">
        <cfif getCurrentSettings.Settings_Management_Brokerage_Updated_Date neq ''>
            <div class="last_changed">
            The #Form.Generic_Type# template settings were last updated on  <b>#dateformat(getCurrentSettings.Settings_Management_Brokerage_Updated_Date, 'm/d/yyy')# </b>
                                                                        at #timeformat(getCurrentSettings.Settings_Management_Brokerage_Updated_Date, 'h:mm:ss TT')# 
                                                                        by <b>#getCurrentSettings.Brokerage_Updated_Name_First# #getCurrentSettings.Brokerage_Updated_Name_Last#</b>
            </div>
        </cfif>
    <cfelseif #GetGenericTypeID.Generic_Type_ID# eq "9">
        <cfif getCurrentSettings.Settings_Management_LumpAutoPay_Updated_Date neq ''>
            <div class="last_changed">
            The #Form.Generic_Type# template settings were last updated on  <b>#dateformat(getCurrentSettings.Settings_Management_LumpAutoPay_Updated_Date, 'm/d/yyy')# </b>
                                                                        at #timeformat(getCurrentSettings.Settings_Management_LumpAutoPay_Updated_Date, 'h:mm:ss TT')# 
                                                                        by <b>#getCurrentSettings.LumpAutoPay_Updated_Name_First# #getCurrentSettings.LumpAutoPay_Updated_Name_Last#</b>
            </div>
        </cfif>
    </cfif>
</CFOUTPUT>

<cfif Form.Generic_Type NEQ 0>
	<cfif Form.Generic_Type EQ "Profiles">
		<CFINCLUDE TEMPLATE="Settings_Profile.cfm">
	<cfelse>
		<CFINCLUDE TEMPLATE="Settings_ProgramTemplate.cfm">	
	</cfif>
</cfif>
</BODY>
</HTML>
