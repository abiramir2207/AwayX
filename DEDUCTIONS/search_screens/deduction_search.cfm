<cfinvoke component="components.settings.ApplicationSettingsManager"
 		         method="get"
 		 returnVariable="appSettings">
</cfinvoke>

<cfif isDefined("FORM.FromSmallSearch")>
	<cfset noCACHE = "true" />
<cfelse>
	<cfset noCACHE = "false" />
</cfif>

<cfset stDeductionLabels = createObject("component", "components.settings.Labels.Labels").init().GetDeductionLabelsStruct() />
<!---
<cfmodule template="/Customtags/accelerate.cfm" secondaryKey="pagesection" cachedWithin="#createTimeSpan(0,0,30,0)#" StripWhitespace="true" noCACHE="#noCACHE#">
--->

<cfparam name="FORM.DD_Number" default="">
<cfparam name="FORM.DD_Amount" default="">
<cfparam name="FORM.Date_Time" default="">
<cfparam name="FORM.Distributor" default="">
<cfparam name="FORM.Broker" default="">
<cfparam name="FORM.Dollar_Operator" default="">
<cfparam name="FORM.Date_Operator" default="">
<CFPARAM NAME="Selected_Distributor" DEFAULT="">
<CFPARAM NAME="FORM.Distributor_List" DEFAULT="">
<CFPARAM NAME="Selected_Broker" DEFAULT="">
<CFPARAM NAME="Display_Broker" Default = "">
<CFPARAM NAME="Selected_Broker_Name" DEFAULT="">
<CFPARAM NAME="FORM.Broker_List" DEFAULT="">
<CFPARAM NAME="FORM.IsParentDeduction" 	DEFAULT="1">
<CFPARAM NAME="FORM.Filter_Closed" DEFAULT="1">
<HTML>

<HEAD>
<META http-equiv="Content-Language" content="en-us">
<META http-equiv="Content-Type" content="text/html; charset=windows-1252">
<cf_include files="/styles/fontawesome/5.8/all.css">
</HEAD>

<BODY bgcolor="#FFFFEA" TOPMARGIN="0" BOTTOMMARGIN="0" LEFTMARGIN="0">

<STYLE>

	body,td
		{
			font-family:	Arial, Helvetica, sans-serif;
			font-size:		11px;
		}
  .indent01 {
    margin-left: 10px;
  }
</STYLE>

<SCRIPT language="JavaScript">
function GoToAdvSearch()
{
	document.all.Form_Submitted.value=0;
	document.SearchDeductions.target = "_parent";
	document.SearchDeductions.action = "/deductions/search_screens/Ded_Advanced_Search.cfm";
	document.SearchDeductions.submit();
	//window.parent.location.href = "/deductions/search_screens/Ded_Advanced_Search.cfm?DD_Number=document.all.DD_Number.value"
}
</SCRIPT>


<!---User profile--->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfset useLakebaseForDeductionsProfilesSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions_profiles_settings")>
<cfif useLakebaseForDeductionsProfilesSettings>
	<cftry>
		<cfset DeductionsProfilesSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions_profiles_settings", {
				"profiles_id" = "eq.#Get_Profile_Settings.Profiles_ID#"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDeductionsProfilesSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionsProfilesSettings>
<CFQUERY NAME="DeductionsProfilesSettings" DATASOURCE="#application.datasource#">
	SELECT * FROM Deductions_Profiles_Settings WHERE Profiles_ID = '#Get_Profile_Settings.Profiles_ID#'
</CFQUERY>
</cfif>

<cfset useLakebaseForUserHasAssignments = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
<cfif useLakebaseForUserHasAssignments>
	<cftry>
		<cfset UserHasAssignments = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_analyst", {
				"analyst_user_id" = "eq.#request.AccessStructure.User_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForUserHasAssignments = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUserHasAssignments>
<CFQUERY NAME="UserHasAssignments" DATASOURCE="#Application.Datasource#">
	 SELECT * FROM DD_Analyst WHERE Analyst_User_ID = '#request.AccessStructure.User_ID#' AND Deleted=0
</CFQUERY>
</cfif>

<CFQUERY NAME="Get_Analyst" DATASOURCE="#Application.Datasource#">
	SELECT 		User_ID, Name_First, Name_Last
	FROM 		DD_Analyst INNER JOIN 	_Users ON _Users.user_ID = DD_Analyst.Analyst_User_ID
	WHERE 		DD_Analyst.Deleted=0 AND _Users.Deleted=0
	ORDER BY	_Users.Name_First,_Users.Name_Last
</CFQUERY>

<CFINCLUDE TEMPLATE="/Deductions/DD_Supervisor_Qry.cfm">
<cfset UserPositionList = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.user_id, 0, 1) />

<cfset SrchByAnalystAllowed = false />
<!---- if the user profile "search by analyst"" = on or if user is an HQ ---->
<cfif DeductionsProfilesSettings.DD_Search_By_Analyst OR ListFind(UserPositionList, HQPosition.User_Positions_ID)>
	<cfset SrchByAnalystAllowed = true>
</cfif>

<cfoutput>
<form name="SearchDeductions" action="/deductions/search_screens/ded_advanced_search_Result.cfm" target="_parent" method="post" style="display:inline;">
<INPUT NAME="FromSmallSearch"				TYPE="Hidden"  VALUE="1">
<INPUT NAME="SelectSingleSearchResultOnly"	TYPE="Hidden"  VALUE="0">
	<style>
		##table1 td {
			padding-right: 7px;
		}
		img[name=calendar2], img[name=up2] {
			position: relative;
			top: -4px;
		}
	</style>
	<TABLE border="0" cellpadding="2" cellspacing="0" style="border-collapse: collapse" id="table1" align="left" width="1200">
	<tr>
		<td><B>Deduction Number:</B></td>
		<td colspan="2"><B>Deduction Date:</B></td>
		<td colspan="1"><strong>Dollars:</strong></td>
		<td colspan="1"><strong>Analyst:</strong></td>
		<td colspan="2" width="25%"><B>Broker:</B>
				<A HREF="javascript: void(0);" onClick="javaScript: showSearchWindow();">
					<i class="fa fa-search btn-icon"></i>
				</a>
		</td>
	</tr>

		<TR>
			<TD width="15%" valign="top"><INPUT type="text" name="DD_Number" size="20" value="#DD_Number#"></TD>
			<TD align="left" valign="top" width="5%"><CFSET Date_Operators=" ,>,=,<">
				<CFSET Date_Operator_Symbols=" ,>,=,<">
				<SELECT NAME="Date_Operator" ID="Date_Operators" >
					<CFSET cnt=0>
					<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
						<CFSET cnt=cnt+1>
						<OPTION VALUE="#Trim(thisOperator)#" <CFIF TRIM(thisOperator) EQ FORM.Date_Operator>SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
					</CFLOOP>
			</TD>
			<TD width="25%" valign="top">
				<CF_EASYDATE FORMNAME="SearchDeductions" FIELDNAME="Date_Time" FORMAT="mm/dd/yyyy" default="#Date_Time#">
			</TD>
			<TD valign="top" width="20%" colspan="1"><CFSET Dollar_Operators=" ,>,=,<">
				<CFSET Dollar_Operator_Symbols=" ,>,=,<">
				<SELECT NAME="Dollar_Operator" ID="Dollar_Operator" >
					<CFSET cnt=0>
					<CFLOOP LIST="#Dollar_Operators#" INDEX="thisOperator">
						<CFSET cnt=cnt+1>
						<OPTION VALUE="#Trim(thisOperator)#" <CFIF TRIM(thisOperator) EQ FORM.Dollar_Operator>SELECTED</CFIF>>#Trim(ListGetAt(Dollar_Operator_Symbols,cnt))#</OPTION>
					</CFLOOP>
				</SELECT>&nbsp;&nbsp;&nbsp;<INPUT type="text" name="DD_Amount" size="8" value="#DD_Amount#" onKeyUp="clenseText(this, '0123456789.-'); "></TD>
			<TD colspan="1" valign="top">
				<SELECT NAME="Analyst_User_ID" ID="Analyst_User_ID" STYLE="Width:150px" <CFIF NOT SrchByAnalystAllowed>DISABLED</CFIF>>
					<OPTION VALUE="">**Any** Analyst</OPTION>
					<cfloop QUERY="Get_Analyst">
						<OPTION VALUE="#User_ID#" <CFIF NOT IaASupervisor.RecordCount AND User_ID EQ request.AccessStructure.User_ID>SELECTED</CFIF>>#Name_First# #Name_Last#</OPTION>
					</cfloop>
				</SELECT>
			</TD>
			<TD align2="right" colspan="2">
				<CFPARAM NAME="Selected_Name" 	DEFAULT="">
				<input type="hidden" name="Broker_ID">
				<CFIF FORM.Broker_List NEQ "">
					<cfset useLakebaseForBroker_Search_Result = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_brokers")>
					<cfif useLakebaseForBroker_Search_Result>
						<cftry>
							<cfset Broker_Search_Result = application.oLakebase.toQuery(
								application.oLakebase.selectRows("bsa_foodservice_brokers", {
									"select" = "broker_legcy_shard,broker_name",
									"bsa_foodservice_brokers_id" = "in.(#FORM.Broker_List#)",
									"deleted" = "eq.0",
									"active_code" = "eq.A",
									"order" = "broker_name.asc"
								}),
								"broker_legcy_shard,broker_name"
							)>
							<cfcatch type="any">
								<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
								<cfset useLakebaseForBroker_Search_Result = false>
							</cfcatch>
						</cftry>
					</cfif>
					<cfif NOT useLakebaseForBroker_Search_Result>
					<CFQUERY NAME="Broker_Search_Result" DATASOURCE = "#Application.Datasource#">
						SELECT Broker_Legcy_Shard,
						Broker_name
						FROM BSA_Foodservice_Brokers
						WHERE BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID IN (#ListQualify(FORM.Broker_List, "'", ",")#)
						AND BSA_Foodservice_Brokers.Deleted = 0
						AND BSA_Foodservice_Brokers.Active_Code = 'A'
						ORDER BY Broker_Name
					</CFQUERY>
					</cfif>
					<CFSET Selected_Broker = ValueList(Broker_Search_Result.Broker_Legcy_Shard)>
					<cfset Selected_Broker_Name =  ValueList(Broker_Search_Result.Broker_name)>
					<cfloop  query = "Broker_Search_Result">
						<cfset Display_Broker = Display_Broker & Broker_Search_Result.Broker_name & "-[" & Broker_Search_Result.Broker_Legcy_Shard & "]," />
					</cfloop>
				</CFIF>
				<textarea NAME="Broker" cols="50" rows="3" style="background-color:cccccc" READONLY><CFIF FORM.Broker_List NEQ "">#TRIM(replace(Display_Broker,",","#chr(10)#","All"))#</CFIF></textarea>
			</TD>
		</TR>
		<CFIF FORM.Distributor_List NEQ "">
			<cfset useLakebaseForDist_Search_Result = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
			<cfif useLakebaseForDist_Search_Result>
				<cftry>
					<cfset Dist_Search_Result = application.oLakebase.toQuery(
						application.oLakebase.selectRows("bsa_foodservice_customers", {
							"select" = "bsa_foodservice_customers_id,name,shr_ship_to",
							"bsa_foodservice_customers_id" = "in.(#FORM.Distributor_List#)",
							"deleted" = "eq.0",
							"active_code" = "eq.A",
							"order" = "name.asc"
						}),
						"bsa_foodservice_customers_id,name,shr_ship_to"
					)>
					<cfcatch type="any">
						<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
						<cfset useLakebaseForDist_Search_Result = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForDist_Search_Result>
			<CFQUERY NAME="Dist_Search_Result" DATASOURCE = "#Application.Datasource#">
				SELECT BSA_Foodservice_Customers_ID,Name,Shr_Ship_To
				FROM BSA_Foodservice_Customers
				WHERE
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN (#ListQualify(FORM.Distributor_List, "'", ",")#)
					AND
					BSA_Foodservice_Customers.Deleted = 0
					AND
					BSA_Foodservice_Customers.Active_Code = 'A'
				ORDER BY Name
			</CFQUERY>
			</cfif>
		<CFSET Selected_Distributor=VAlueList(Dist_Search_Result.Shr_Ship_To)>
		</CFIF>

		<SCRIPT LANGUAGE="JavaScript">
			function showDistSearchWindow()
			{
				document.all.Form_Submitted.value=0;
				document.SearchDeductions.target = "_self";
				document.SearchDeductions.SelectSingleSearchResultOnly.value = 0;
				document.SearchDeductions.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";
				NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?Formname=SearchDeductions", "searchwindow", 800, 600, "yes", "yes")
			}
		</SCRIPT>
		<CFPARAM NAME="Selected_Name" 	DEFAULT="">
		<TR>
			<TD align="left"  colspan="3" valign="top">
				<B>
					<cfoutput>#application.returned_customer_setting.shard_ship_to_label# / #application.returned_customer_setting.billto_label#</cfoutput>:
				</B>
			<span style="color:navy;font-size:10px;font-weight:bold;padding-right:10px;">
				(Enter ID followed by enter key)
			</span>
			<A HREF="javascript: void(0);" onClick="javaScript: showDistSearchWindow();">
				<i class="fa fa-search btn-icon"></i>
			</A>
			<br />
			<!--- D42846 :: Deduction tool upgrades Added  &##13;--->
			<textarea NAME="Distributor" cols="50" rows="3"><cfloop index = "ListElement" list = "#Selected_Distributor#"><CFOUTPUT>#Trim(ListElement)#&##13;</CFOUTPUT></cfloop></textarea>
		</TD>
		<SCRIPT LANGUAGE="JavaScript">
			function showSearchWindow()
			{
				document.all.Form_Submitted.value=0;
				document.SearchDeductions.target = "_self";
				document.SearchDeductions.SelectSingleSearchResultOnly.value = 0;
				document.SearchDeductions.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";
				NewWindow("/Billbacks/search_Screens/PM_select_Brokers.cfm?Formname=SearchDeductions", "searchwindow", 800, 600, "yes", "yes")
			}
		</SCRIPT>
		<CFPARAM NAME="Selected_Name" 	DEFAULT="">
			<TD colspan="2" valign="top">
			<!---26472 - 2011-mar-8 chrisn: added classification--->
			<cfif (appSettings.getDD_Show_Classification() EQ 1)><br/><cfinclude template="select_classification.cfm"></cfif>
			<!---26487 - 2011-mar-9 chrisn: added deduction type--->
			<cfif (appSettings.getDD_Show_DeductionType() EQ 1)><br/><cfinclude template="select_deductiontype.cfm"></cfif>
			</TD>
			<TD colspan="2">
				<A HREF="##" ONCLICK="Javascript: validate(); return false;">#application.util.string.actionLinkFormat("search deduction")#</A> &nbsp; &nbsp;
				<A HREF="##" ONCLICK="Javascript: resetForm(); return false;">#application.util.string.actionLinkFormat("reset")#</A><br>
      			<input type="checkbox" name="IsParentDeduction" value="1" class="indent01" <CFIF FORM.IsParentDeduction EQ 1>CHECKED</CFIF>><B>Filter out Parent</B><br />
				<input type="checkbox" name="Filter_Closed" value="1" class="indent01" <CFIF FORM.IsParentDeduction EQ 1>CHECKED</CFIF>><B>Filter out all Closed Statuses</B>
			</TD>
		</TR>
		</TABLE>

<input type="hidden" name="Form_Submitted" value="1">
<input type="hidden" name="SubmittheForm" value="1">
<INPUT TYPE="Hidden" ID="Distributor_List" NAME="Distributor_List" VALUE="#FORM.Distributor_List#">
<INPUT TYPE="Hidden" ID="Broker_List" NAME="Broker_List" VALUE="#FORM.Broker_List#">
</form>
</cfoutput>

<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT language="JavaScript">
function validate()
{
	var validateOk = 1;

	if (document.all.DD_Amount.value == "." || document.all.DD_Amount.value == "-" || document.all.DD_Amount.value == "-." )
		{
			validateOk  = 0;
			alert("Please enter a valid dollar amount.");
			document.all.DD_Amount.focus();
			return;
		}

	var selectedOperator = document.getElementById("Dollar_Operator");
	if (selectedOperator.selectedIndex == 0 && document.all.DD_Amount.value.length > 0)
	{
		validateOk = 0;
		alert("Please select a valid dollar operator ( >,=, or < ).");
		document.all.Dollar_Operator.focus();
		return;
	}

	if(validateOk == 1)
	document.SearchDeductions.submit();
}
function resetForm()
{
	document.all.Form_Submitted.value = "";
	document.all.DD_Number.value = "";
	document.all.DD_Amount.value = "";
	//document.all.Distributor.value = ""; CHROMEFIX
	jQuery("textarea[name=Distributor]").val('');
	//document.all.Broker.value = ""; CHROMEFIX
	jQuery("textarea[name=Broker]").val('');
	document.all.Date_Time.value = "";
	resetSelect("Date_Operator");
	resetSelect("Dollar_Operator");
	resetSelect("classification");	  /*26472*/
	resetSelect("deductiontype");	    /*26487*/
}
function resetSelect(selName)
{
	var sObj = document.getElementById(selName);
	if(sObj)
	{
		sObj.selectedIndex = 0;
		callfireEvent(document,sObj,'Change');
	}
}
</SCRIPT>
<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
<SCRIPT language="JavaScript" src="/Common_Files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>
</BODY>
</HTML>
