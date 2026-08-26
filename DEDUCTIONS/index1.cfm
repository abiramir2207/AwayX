<BODY bgcolor="#FFE083" style="overflow:hidden;">
<style>
	.sectiontitle
		{
			color:			##000000;
		}
</style>
<CFPARAM NAME="chkRefreshView" DEFAULT="0">
<CFPARAM NAME="FORM.Form_Submitted" DEFAULT="0">
<CFPARAM NAME="FORM.Distributor_List" DEFAULT="">
<CFPARAM NAME="URL.Distributor_List" DEFAULT="">
<CFPARAM NAME="Selected_Distributor_Num" DEFAULT="">
<CFPARAM NAME="FORM.Broker_List" DEFAULT="">
<CFPARAM NAME="URL.Broker_List" DEFAULT="">
<CFPARAM NAME="Selected_Broker_Num" DEFAULT="">

<cfset useLakebaseForDefaultSC = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("scorecard_customize")>
<cfif useLakebaseForDefaultSC>
	<cftry>
		<cfset Default_SC = application.oLakebase.toQuery(
			application.oLakebase.selectRows("scorecard_customize", {
				"scorecard_id" = "eq.4",
				"user_id" = "eq.#request.AccessStructure.User_ID#",
				"deleted" = "eq.false"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDefaultSC = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDefaultSC>
	<CFQUERY NAME="Default_SC" DATASOURCE="#Application.Datasource#">
		SELECT 	*
		FROM 	Scorecard_Customize
		WHERE 	Scorecard_ID = '4'
		AND		USER_ID = '#request.AccessStructure.User_ID#'
		AND 	Deleted = 0
	</CFQUERY>
</cfif>

<cfset stDeductionLabels = createObject("component", "components.settings.Labels.Labels").init().GetDeductionLabelsStruct() />

<CFIF Default_SC.recordcount GT 0>
	<CFIF Default_SC.Scorecard_Grouping_ID EQ 1 AND Default_SC.Scorecard_Display_ID EQ 1>
		<CFSET DefaultCurSel = 2>
	<CFELSEIF Default_SC.Scorecard_Grouping_ID EQ 1 AND Default_SC.Scorecard_Display_ID EQ 2>
		<CFSET defaultCurSel = 1>
	<CFELSEIF Default_SC.Scorecard_Grouping_ID EQ 2 AND Default_SC.Scorecard_Display_ID EQ 1>
		<CFSET defaultCurSel = 4>
	<CFELSEIF Default_SC.Scorecard_Grouping_ID EQ 2 AND Default_SC.Scorecard_Display_ID EQ 2>
		<CFSET defaultCurSel = 3>
	<CFELSEIF Default_SC.Scorecard_Grouping_ID EQ 3 AND Default_SC.Scorecard_Display_ID EQ 1>
		<CFSET defaultCurSel = 6>
	<CFELSEIF Default_SC.Scorecard_Grouping_ID EQ 3 AND Default_SC.Scorecard_Display_ID EQ 2>
		<CFSET defaultCurSel = 5>
	</CFIF>
	<CFIF Selected_Distributor_Num EQ "">
		<CFSET Selected_Distributor_Num = Default_SC.Shr_Ship_To>
	</CFIF>
	<CFIF Selected_Broker_Num EQ "">
		<CFSET Selected_Broker_Num = Default_SC.Broker_Shard>
	</CFIF>


	<CFIF isDefined("URL.ScorecardToShow")>
		<CFIF chkRefreshView>
			<CFSET chkRefreshView = 1>
		<CFELSE>
			<CFSET chkRefreshView = 0>
		</CFIF>
	<CFELSE>
		<CFSET chkRefreshView = Default_SC.chk_Refresh_View>
	</cfif>
<CFELSE>
	<CFSET defaultCurSel = 1>
</CFIF>
<CFPARAM NAME="URL.CurSel" DEFAULT="#defaultCurSel#">

<cf_include files="/styles/fontawesome/5.8/all.css, /Script/javascript/dhtml.js">

<!--- Tech Note 14337, 14424 correction by RBL 01/23/08 [begin] (6 options in 2 instances - else clauses) --->
<SCRIPT language="JavaScript">
function changeScorecard()
{
	var URLStr = "";
	var CurSel;
	if (document.Changethis.SCBasedOn.value == 1)
	{
		URLStr="ScorecardToShow=age&ScorecardToShow_basedon=count&CurSel=1&chkHideParent=1";
	}
	else if (document.Changethis.SCBasedOn.value == 2)
	{
		URLStr="ScorecardToShow=age&ScorecardToShow_basedon=dollar&CurSel=2&chkHideParent=1";
	}
	else if (document.Changethis.SCBasedOn.value == 3)
	{
		URLStr="ScorecardToShow=action&ScorecardToShow_basedon=count&CurSel=3&chkHideParent=1";
	}
	else if (document.Changethis.SCBasedOn.value == 4)
	{
		URLStr="ScorecardToShow=action&ScorecardToShow_basedon=dollar&CurSel=4&chkHideParent=1";
	}
	else if (document.Changethis.SCBasedOn.value == 5)
	{
		URLStr="ScorecardToShow=class&ScorecardToShow_basedon=count&CurSel=5&chkHideParent=1";
	}
	else if (document.Changethis.SCBasedOn.value == 6)
	{
		URLStr="ScorecardToShow=class&ScorecardToShow_basedon=dollar&CurSel=6&chkHideParent=1";
	}
	if (document.Changethis.SC_Shr_Ship_To.value != "")
	{
		URLStr = URLStr + "&SC_Shr_Ship_To=" + document.Changethis.SC_Shr_Ship_To.value;
	}
	if (document.Changethis.SC_Broker_Shard.value != "")
	{
		URLStr = URLStr + "&SC_Broker_Shard=" + document.Changethis.SC_Broker_Shard.value;
	}

	if(document.Changethis.chkRefreshView.checked == true)
	{
		URLStr = URLStr + "&chkRefreshView=1";
	}
	else
	{
		URLStr = URLStr + "&chkRefreshView=0";
	}

	if(document.Changethis.SCBasedOn.value != ''){
	CurSel = document.Changethis.SCBasedOn.value;
	}

	/* First show the name of the customer and the Broker searched. If Invalid, Say so. */
	//window.location ="index1.cfm?CurSel="+CurSel+"&Broker_List="+document.Changethis.SC_Broker_Shard.value+"&Distributor_List=" + document.Changethis.SC_Shr_Ship_To.value;
	window.location ="index1.cfm?Broker_List="+document.Changethis.SC_Broker_Shard.value+"&Distributor_List="+document.Changethis.SC_Shr_Ship_To.value+"&"+URLStr;

	/* Then refresh the scorecard for the results */
	window.parent.deduction_scorecard.location.href="/deductions/scorecard.cfm?"+URLStr;
}

function setDefault()
{
	// ngt
	const ship_tos = document.Changethis.SC_Shr_Ship_To.value;
	// multiple distributors selected, disable set as default option & bail out
	if ( ship_tos.indexOf(",") !== -1 ) {
		const element = document.getElementById("set_as_default");
		element.classList.add("disabled");
		return;
	}
	var URLStr = "";
	if (document.Changethis.SCBasedOn.value == 1)
	{
		URLStr="ScorecardToShow=age&ScorecardToShow_basedon=count&CurSel=1";
	}
	else if (document.Changethis.SCBasedOn.value == 2)
	{
		URLStr="ScorecardToShow=age&ScorecardToShow_basedon=dollar&CurSel=2";
	}
	else if (document.Changethis.SCBasedOn.value == 3)
	{
		URLStr="ScorecardToShow=action&ScorecardToShow_basedon=count&CurSel=3";
	}
	else if (document.Changethis.SCBasedOn.value == 4)
	{
		URLStr="ScorecardToShow=action&ScorecardToShow_basedon=dollar&CurSel=4";
	}
	else if (document.Changethis.SCBasedOn.value == 5)
	{
		URLStr="ScorecardToShow=class&ScorecardToShow_basedon=count&CurSel=5";
	}
	else if (document.Changethis.SCBasedOn.value == 6)
	{
		URLStr="ScorecardToShow=class&ScorecardToShow_basedon=dollar&CurSel=6";
	}
	if (document.Changethis.SC_Shr_Ship_To.value != "")
	{
		URLStr = URLStr + "&SC_Shr_Ship_To=" + document.Changethis.SC_Shr_Ship_To.value;
	}
	if (document.Changethis.SC_Broker_Shard.value != "")
	{
		URLStr = URLStr + "&SC_Broker_Shard=" + document.Changethis.SC_Broker_Shard.value;
	}
	if(document.Changethis.chkRefreshView.checked == true)
	{
		URLStr = URLStr + "&chkRefreshView=1";
	}
	else
	{
		URLStr = URLStr + "&chkRefreshView=0";
	}

	window.location.href="Scorecard_Remember.cfm?"+URLStr;
}

function ResetForm()
{
	resetSelect("SCBasedOn");
	document.all.SC_Shr_Ship_To.value = "";
	document.all.Distributor_List.value = "";
	document.all.SC_Broker_Shard.value = "";
	document.all.Broker_List.value="";
	document.all.DistributorResult.innerHTML="";
	document.all.BrokerResult.innerHTML="";
	const element = document.getElementById("set_as_default");
	element.classList.remove("disabled");
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
<!--- Tech Note 14337, 14424 correction by RBL 01/23/08 [end] (6 options in 2 instances - else clauses) --->

<CFOUTPUT>
<FORM NAME="Changethis" ACTION="Index1.cfm" METHOD="POST" style="display:inline;">
<INPUT TYPE="Hidden" NAME="Form_Submitted" VALUE="0">
<INPUT TYPE="Hidden" ID="Distributor_List" NAME="Distributor_List" VALUE="#FORM.Distributor_List#">
<INPUT TYPE="Hidden" ID="Broker_List" NAME="Broker_List" VALUE="#FORM.Broker_List#">
<INPUT TYPE="Hidden" ID="SelectSingleSearchResultOnly" NAME="<b>Broker_List</b>" VALUE="0">


<style>
	##scorecard_header {
		margin-top: 5px;
		/* border: 1px solid blue; */
	}
	##scorecard_header td {
		padding: 0 5px;
		width: 20%;
		/* border: 1px solid blue; */
	}
</style>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" style="border-collapse: collapse" CLASS="sectiontitle" ID="scorecard_header" WIDTH="100%">
	<TR>
		<!--- <TD>&nbsp;&nbsp;<B><font color="black">Filter</font></B>&nbsp; &nbsp;</TD> --->
		<TD><B><font color="black">Filter</font></B><BR>
			<SELECT NAME="SCBasedOn" ID="SCBasedOn" ><!--- ONCHANGE="Javascript: changeScorecard()" --->
				<OPTION VALUE="1" <CFIF URL.CurSel EQ 1>SELECTED</CFIF>>age, ## of deductions</OPTION>
				<OPTION VALUE="2" <CFIF URL.CurSel EQ 2>SELECTED</CFIF>>age, dollar</OPTION>
				<OPTION VALUE="3" <CFIF URL.CurSel EQ 3>SELECTED</CFIF>>#LCase(stDeductionLabels["Action"])#, ## of deductions</OPTION>
				<OPTION VALUE="4" <CFIF URL.CurSel EQ 4>SELECTED</CFIF>>#LCase(stDeductionLabels["Action"])#, dollar</OPTION>
				<OPTION VALUE="5" <CFIF URL.CurSel EQ 5>SELECTED</CFIF>>#LCase(stDeductionLabels["Classification"])#, ## of deductions</OPTION>
				<OPTION VALUE="6" <CFIF URL.CurSel EQ 6>SELECTED</CFIF>>#LCase(stDeductionLabels["Classification"])#, dollar</OPTION>
			</SELECT>
		</TD>
		<SCRIPT LANGUAGE="JavaScript">
			function showDistSearchWindow()
			{
				document.all.Form_Submitted.value=0;
				document.Changethis.target = "_self";
				document.Changethis.SelectSingleSearchResultOnly.value = 1;
				document.Changethis.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";
				NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?Formname=Changethis", "searchwindow", 800, 600, "yes", "yes");
			}
		</SCRIPT>
		<CFPARAM NAME="Selected_Name" 	DEFAULT="">
		<CFIF FORM.Distributor_List NEQ "" OR URL.Distributor_List NEQ "" OR Selected_Distributor_Num NEQ "">
			<CFQUERY NAME="Dist_Search_Result" DATASOURCE = "#Application.Datasource#">
				SELECT DISTINCT Name,Shr_Ship_To
				FROM BSA_Foodservice_Customers
				<CFIF FORM.Distributor_List NEQ "">
				WHERE
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN (#ListQualify(FORM.Distributor_List, "'", ",")#)
					AND
					BSA_Foodservice_Customers.Deleted = 0
					AND
					BSA_Foodservice_Customers.Active_Code = 'A'

				<CFELSEIF Selected_Distributor_Num NEQ "">
				WHERE	BSA_Foodservice_Customers.SHR_SHIP_TO IN ( #listQualify( Selected_Distributor_Num, "'", "," )# )
				<cfelse>
				WHERE
					BSA_Foodservice_Customers.SHR_SHIP_TO IN ( #listQualify( URL.Distributor_List, "'", "," )# )
				</CFIF>

				UNION

				SELECT DISTINCT Name,Shr_Bill_To As Shr_Ship_To
				FROM Distributor_Bill_To
				<CFIF FORM.Distributor_List NEQ "">
				WHERE
					Distributor_Bill_To.Distributor_Bill_To_ID IN (#ListQualify(FORM.Distributor_List, "'", ",")#)
					AND
					Distributor_Bill_To.Deleted = 0
					AND
					Distributor_Bill_To.Active_Code = 'A'
				<CFELSEIF Selected_Distributor_Num NEQ "">
				WHERE	Distributor_Bill_To.Shr_Bill_To IN ( #listQualify( Selected_Distributor_Num, "'", "," )# )
				<CFELSE>
				WHERE
					Distributor_Bill_To.Shr_Bill_To IN ( #listQualify( URL.Distributor_List, "'", "," )# )
				</CFIF>
				ORDER BY Name
			</CFQUERY>

			<CFSET Selected_Distributor_Num=ValueList(Dist_Search_Result.Shr_Ship_To)>
		</CFIF>
		<TD>
			<B>#application.returned_customer_setting.shard_ship_to_label# / #application.returned_customer_setting.billto_label#</B><BR>
			<CFIF URL.Distributor_List NEQ "">
			<INPUT TYPE="Text" NAME="SC_Shr_Ship_To" value="#URL.Distributor_List#">
			<CFELSE>
			<INPUT TYPE="Text" NAME="SC_Shr_Ship_To" value="#Selected_Distributor_Num#">
			</CFIF>
			<A HREF="javascript: void(0);" onClick="javaScript: showDistSearchWindow();">
				<!--- <IMG border="0" src="/images/searchtool.gif" width="20" height="20"> --->
				<i class="fa fa-search btn-icon"></i>
			</A>
		</TD>
		<CFIF FORM.Broker_List NEQ "" OR URL.Broker_List NEQ "" OR Selected_Broker_Num NEQ "">
			<CFQUERY NAME="Broker_Search_Result" DATASOURCE = "#Application.Datasource#">
				SELECT BSA_Foodservice_Brokers_ID,Broker_Name,Broker_Shard
				FROM BSA_Foodservice_Brokers
				<CFIF FORM.Broker_List NEQ "">
				WHERE
					BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID  = '#FORM.Broker_List#'
					AND
					BSA_Foodservice_Brokers.Deleted = 0
					AND
					BSA_Foodservice_Brokers.Active_Code = 'A'

				<CFELSEIF Selected_Broker_Num NEQ "">
				WHERE BSA_Foodservice_Brokers.Broker_Shard = '#Selected_Broker_Num#'
				<CFELSE>
				WHERE
					BSA_Foodservice_Brokers.Broker_Shard = '#URL.Broker_List#'
				</CFIF>
				ORDER BY Broker_Name
			</CFQUERY>
			<CFSET Selected_Broker_Num = Broker_Search_Result.Broker_Shard>
		</CFIF>
		<SCRIPT LANGUAGE="JavaScript">
			function showSearchWindow()
			{
				document.all.Form_Submitted.value=0;
				document.Changethis.target = "_self";
				document.Changethis.SelectSingleSearchResultOnly.value = 1;
				document.Changethis.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";
				NewWindow("/Billbacks/search_Screens/PM_select_Brokers.cfm?Formname=Changethis", "searchwindow", 800, 600, "yes", "yes");
			}
		</SCRIPT>
		<CFPARAM NAME="Selected_Name" 	DEFAULT="">
		<TD><B>#application.returned_customer_setting.broker_label_singular# ##</B><BR>
			<cfif URL.Broker_List neq "">
				<INPUT TYPE="Text" NAME="SC_Broker_Shard" value="#url.broker_list#">
			<cfelse>
				<INPUT TYPE="Text" NAME="SC_Broker_Shard" value="#Selected_Broker_Num#">
			</cfif>
			<A HREF="javascript: void(0);" onClick="javaScript: showSearchWindow();">
				<i class="fa fa-search btn-icon"></i>
			</a>
		</TD>
		<TD align="left">
			<cfset set_as_default = isDefined("Dist_Search_Result") and Dist_Search_Result.recordCount gt 1 ? "disabled" : ''>
			<a href="Javascript: changeScorecard()"> #application.util.string.linkFormat("filter scorecard")# </a> &nbsp;
			<a href="Javascript: setDefault()" class="#set_as_default#" id="set_as_default"> #application.util.string.linkFormat("set as default")# </a> <br>
			<a href="Javascript: ResetForm()">       #application.util.string.linkFormat("reset form")# </a>
		</TD>
		<TD valign="top" align="left">
			<cfset scorecardTime = Now() />
			<cfsavecontent variable="countersCacheMessage">Counters current as of <cfif chkRefreshView EQ 0>#DateFormat(Now(), "mm/dd/yyyy")# 00:00:00 AM<cfelse>#DateFormat(scorecardTime, "mm/dd/yyyy")# #TimeFormat(scorecardTime, "hh:mm:ss tt")#</cfif></cfsavecontent>
			<b>Refresh View</b> <input type="checkbox" style="position:relative;top:2px;" name="chkRefreshView" value="1" <cfif chkRefreshView eq 1>checked</cfif> onClick="changeScorecard();"><br><br>
		<!--- </TD> --->
		<!--- <td nowrap>&nbsp;</td> --->
		<!--- <td nowrap width2="90">Reminders --->
			<b>Reminders</b>
			<a href="##" onClick="NewWindow('/deductions/reminders.cfm?ShowAll=1','name','375','400','yes', 'no'); return false;"> #application.util.string.linkFormat("show all")# </a> &nbsp;
			<a href="##" onClick="NewWindow('/deductions/reminders.cfm?ShowAll=0','name','375','400','yes', 'no'); return false;"> #application.util.string.linkFormat("show active")# </a>
		</td>
	</TR>
	<!--- Dev Note: Milan; 9557 and 11136 --->
	<TR>
			<TD>&nbsp;</TD>
			<TD align="left" style="font-size: 8px;" id="DistributorResult" <cfif IsDefined("Dist_Search_Result")>Title="#Dist_Search_Result.Name#"</cfif>>&nbsp;&nbsp;<cfif IsDefined("Dist_Search_Result")><cfif Dist_Search_Result.Recordcount eq 0><b><span style="color:red">Invalid #application.returned_customer_setting.distributor_label_singular#</span></b><cfelse>#valueList( Dist_Search_Result.Name )#</cfif></cfif>&nbsp;</TD>
			<TD align="left" style="font-size: 8px;" id="BrokerResult" <cfif IsDefined("Broker_Search_Result")>Title="#Broker_Search_Result.Broker_Name#"</cfif>>&nbsp;&nbsp;<cfif IsDefined("Broker_Search_Result")><cfif Broker_Search_Result.Recordcount eq 0><b><span style="color:red">Invalid #application.returned_customer_setting.broker_label_singular#</span></b><cfelse>#Broker_Search_Result.Broker_Name#</cfif></cfif>&nbsp;</TD>
			<TD>&nbsp;</TD>
			<TD>&nbsp;</TD>
	</TR>
	<!--- End Note: Milan; 9557 and 11136 --->
</TABLE>
</FORM>
</CFOUTPUT>
</BODY>
