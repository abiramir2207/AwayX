<CFPARAM name="form.STATE" default="0">
<CFPARAM name="form.COUNTY" default="0">
<CFPARAM name="form.OPERATOR" default="0">
<CFPARAM name="Distributor_ID" default="">
<CFPARAM name="dist" default="">
<CFPARAM NAME="distname" default="">
<CFPARAM name="Broker" default="">
<CFPARAM name="Broker_ID" default="">
<CFPARAM name="BrokerName" default="">
<CFPARAM name="Operator" default="">
<CFPARAM name="Operator_ID" default="">
<CFPARAM name="OperatorName" default="">



<cfset GetOperatorMap = querynew("Operator_Name")>
<CFIF len(trim(form.state)) GT 0 >
<cfquery name="GetOperatorMap" datasource="#application.datasource#">
	SELECT	*
	FROM	Operator_ZipCode_Map
	WHERE 
	BSA_Operator_ID IN (SELECT BSA_Operator_ID FROM USDANOI_Operators)

	<cfif len(trim(form.state)) GT 0>
		<cfif trim(form.state) NEQ 0>
			AND
			StateFIPS	= '#form.state#'
		</cfif>
	</cfif>
	
	
	<cfif len(trim(form.county)) GT 0>
		<cfif trim(form.county) NEQ 0>
			AND
			CountyFIPS = '#form.county#'
		</cfif>
	</cfif>
</cfquery>
</CFIF>


<cfquery name="GetStates" datasource="#application.datasource#">
SELECT DISTINCT StateCode, State, StateFIPS
	FROM Operator_ZipCode_Map
	WHERE StateFIPS NOT IN('00','64','60','69','78','66','68','72','70')
	ORDER By StateCode, State, StateFIPS
</cfquery>

<cfset GetCounties = QueryNew("County")>
<CFIF GetOperatorMap.recordcount GT 0 AND form.state NEQ 0>
	<cfset useLakebaseForGetCounties = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getoperatormap")>
<cfif useLakebaseForGetCounties>
	<cftry>
		<cfset GetCounties = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getoperatormap", {
				"order" = "county.asc",
				"select" = "county,countyfips"
			}), "county,countyfips"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCounties = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCounties>
<cfquery name="GetCounties" dbtype="query">
		SELECT DISTINCT County, CountyFIPS
		FROM GetOperatorMap
		ORDER BY County
	</cfquery>
</cfif>
</CFIF>

<cfset GetOperators = QueryNew("Operator_Name")>
<CFIF GetCounties.recordcount GT 0 AND form.state NEQ 0>
<cfset useLakebaseForGetOperators = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getoperatormap")>
<cfif useLakebaseForGetOperators>
	<cftry>
		<cfset GetOperators = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getoperatormap", {
				"order" = "operator_name.asc",
				"select" = "bsa_operator_id,operator_name"
			}), "bsa_operator_id,operator_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetOperators = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetOperators>
<cfquery name="GetOperators" dbtype="query">
	SELECT DISTINCT BSA_operator_id, Operator_Name
	FROM GetOperatorMap
	ORDER BY Operator_Name
</cfquery>
</cfif>
</CFIF>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
	<script>
		function submitForm() {
			document.all.MyForm.submit();
		
		}
		
	</script>

</head>

<body leftmargin="0" topmargin="0" rightmargin="0" bottommargin="0" bgcolor="Whitesmoke" <!--- onload="setParentWindowVars();" --->>
<!--- <form action="user_setting_report_restrictor.cfm" method="get" name="MyForm" id="MyForm"> --->
<table>
	<tr>
		<td colspan="100%" valign="bottom"><b style="color:red;">Select the report criteria this user will have restricted access to:</b></td>
	</tr>
	<tr>
		<td>
			<span style="font-weight:bold; font-size:10px;">State</span><br>
			<select size="1" name="State" onchange="finalsubmit = 0;submitForm();" helpboxid=1>
				<option value="" <cfif form.State EQ ""> SELECTED</cfif>>Select A State...</option>
				<cfoutput>
				<cfloop query="GetStates">
					<option value="#GetStates.StateFIPS#" <cfif form.State EQ GetStates.StateFIPS> SELECTED</cfif>>#GetStates.StateCode# - #GetStates.State#</option>
				</cfloop>
				</cfoutput>
			</select>
		</td>
		
		<td>
			<span style="font-weight:bold; font-size:10px;">County</span><br>
			<select size="1" name="County" onchange="finalsubmit = 0;submitForm();">
				<option value="0" <cfif form.County EQ "0"> SELECTED</cfif>>ALL COUNTIES</option>
				<cfoutput>
				<cfloop query="GetCounties">
					<option value="#GetCounties.CountyFIPS#" <cfif form.County EQ GetCounties.CountyFIPS> SELECTED</cfif>>#GetCounties.County#</option>
				</cfloop>
				</cfoutput>
			</select>
		</td>
		
		<td>
			<cfoutput><span style="font-weight:bold; font-size:10px;">#application.returned_customer_setting.operator_label_singular#</span><br>
			<select size="1" name="Operator">
				<option value="0" <cfif form.operator EQ 0>SELECTED</cfif>>ALL #UCASE(application.returned_customer_setting.operator_label_singular)#</option>
				<cfoutput>
				<cfloop query="GetOperators">
					<option value="#GetOperators.BSA_Operator_ID#" <cfif form.Operator EQ GetOperators.BSA_Operator_ID> SELECTED</CFIF>>#GetOperators.Operator_Name#</option>
				</cfloop>
				</cfoutput>
			</select></cfoutput>
		</td>
	</tr>
	
<!--- </form> --->

<!--- <form action="user_setting_report_restrictor.cfm" method="post" name="AddDistributor"> --->
	<tr>
	<td><strong>OR</strong></td>
	</tr><tr>
	<td colspan="100%" valign="bottom"><b style="color:red;">Select the <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput> this user is a member of:</b></td>
</tr><tr>
	<td colspan="100%">
	
	<cfif len(trim(Dist)) GT 0>
		<cfset Distributor_ID = listqualify(Dist, "'")>
	</cfif>
	<cfif len(trim(form.Distributor_List)) GT 0>
		<cfset Distributor_ID = listqualify(form.Distributor_List, "'")>
	</cfif>
	
	
	<cfif len(trim(Distributor_ID)) GT 0 AND Distributor_ID IS NOT 0 AND Distributor_ID IS NOT "'Null'">
		<cfquery name="GetDistributorName" datasource="#application.datasource#">
		SELECT Name FROM BSA_Foodservice_Customers
		WHERE BSA_Foodservice_Customers_ID IN (#preservesinglequotes(Distributor_ID)#)
		</cfquery>
		
			<cfif GetDistributorName.Recordcount GT 0>
				<cfset DistName = valuelist(GetDistributorName.Name, ", ")>			
			<cfelse>
				<cfset DistName = "">
			</cfif>
			
		</cfif>
	
	<cfif len(trim(DistName)) GT 0><cfoutput>#DistName#</cfoutput><br></cfif>
	
<CF_smallLink 
	title = "assign #lcase(application.returned_customer_setting.distributor_label_plural)#" 
	url = "##"
	parameters = "onClick=""javascript:  NewWindow('/billbacks/search_Screens/PM_select_distributors.cfm?Formname=MyForm&SelectSingleSearchResultOnly=0', 'DistributorSearch', '800', '600', 'yes', 'yes'); return false;"""
>
<input type="hidden" name="Distributor_List" value="<cfoutput>#form.Distributor_List#</cfoutput>">
<!--- <INPUT NAME="SelectSingleSearchResultOnly" TYPE="Hidden" VALUE="0">	
<INPUT NAME="FinalItemList" TYPE="HIDDEN" VALUE="#url.user_usda_distributor_id_list#" > --->
	</td>
	</tr>
<!--- </form> --->

<!---Brokers--->	
<!--- <form action="user_setting_report_restrictor.cfm" method="post" name="AddBrokers"> --->
	<tr>
	<td><strong>OR</strong></td>
	</tr><tr>
	<td colspan="100%" valign="bottom"><b style="color:red;">Select the brokers this user is a member of:</b></td>
</tr><tr>
	<td colspan="100%">
	
	<cfif len(trim(Broker)) GT 0>
		<cfset Broker_ID = Broker>
	</cfif>
	<cfif len(trim(form.Broker_List)) GT 0>
		<cfset Broker_ID = listqualify(form.Broker_List, "'")>
	</cfif>
	
	
	<cfif len(trim(Broker_ID)) GT 0 AND Broker_ID IS NOT 0>
		<cfquery name="GetBrokerName" datasource="#application.datasource#">
		SELECT Broker_Name FROM BSA_Foodservice_Brokers
		WHERE BSA_Foodservice_Brokers_ID IN (#preservesinglequotes(Broker_ID)#)
		</cfquery>
		
			<cfif GetBrokerName.Recordcount GT 0>
				<cfset BrokerName = valuelist(GetBrokerName.Broker_Name, ", ")>			
			<cfelse>
				<cfset BrokerName = "">
			</cfif>
			
		</cfif>
	
	<cfif len(trim(BrokerName)) GT 0><cfoutput>#BrokerName#</cfoutput><br></cfif>
	
<CF_smallLink 
	title = "assign brokers" 
	url = "##"
	parameters = "onClick=""javascript:  NewWindow('/billbacks/search_Screens/PM_select_brokers.cfm?Formname=MyForm&SelectSingleSearchResultOnly=0', 'BrokerSearch', '800', '600', 'yes', 'yes'); return false;"""
>
<input type="hidden" name="Broker_List" value="<cfoutput>#form.Broker_List#</cfoutput>">
<!--- <INPUT NAME="SelectSingleSearchResultOnly" TYPE="Hidden" VALUE="0">	
<INPUT NAME="FinalItemList" TYPE="HIDDEN" VALUE="#url.user_usda_broker_id_list#" > ---><!--- <cfif DistName IS NOT "">#DistName#<br></cfif> --->

	</td>
	</tr>
<!--- </form> --->
	
<!---Operators--->	
<!--- <form action="user_setting_report_restrictor.cfm" method="post" name="AddOperators"> --->
	<tr>
	<td><strong>OR</strong></td>
	</tr><tr>
	<td colspan="100%" valign="bottom"><b style="color:red;">Select the <cfoutput>#lcase(application.returned_customer_setting.operator_label_plural)# </cfoutput>this user is a member of:</b></td>
</tr><tr>
	<td colspan="100%">
	
	<cfif len(trim(Operator)) GT 0>
		<cfset Operator_ID = Operator>
	</cfif>
	<cfif len(trim(form.Operator_List)) GT 0>
		<cfset Operator_ID = listqualify(form.Operator_List, "'")>
	</cfif>
	
	
	<cfif len(trim(Operator_ID)) GT 0 AND Operator_ID IS NOT 0>
		<cfquery name="GetOperatorName" datasource="#application.datasource#">
		SELECT Operator_Name FROM BSA_Operator
		WHERE BSA_Operator_ID IN (#preservesinglequotes(Operator_ID)#)
		</cfquery>
		
			<cfif GetOperatorName.Recordcount GT 0>
				<cfset OperatorName = valuelist(GetOperatorName.Operator_Name, ", ")>			
			<cfelse>
				<cfset OperatorName = "">
			</cfif>
			
		</cfif>
	
	<cfif len(trim(OperatorName)) GT 0><cfoutput>#OperatorName#</cfoutput><br></cfif>
	
<CF_smallLink 
	title = "assign operators" 
	url = "##"
	parameters = "onClick=""javascript:  NewWindow('/billbacks/search_Screens/PM_select_operators.cfm?Formname=MyForm&SelectSingleSearchResultOnly=0&searchoperator=1', 'OperatorSearch', '800', '600', 'yes', 'yes'); return false;"""
>
<input type="hidden" name="Operator_List" value="<cfoutput>#form.Operator_List#</cfoutput>">
<!--- <INPUT NAME="SelectSingleSearchResultOnly" TYPE="Hidden" VALUE="0">	
<INPUT NAME="FinalItemList" TYPE="HIDDEN" VALUE="#url.user_usda_operator_id_list#" > --->
<!--- </form> --->
	</td>
	</tr>

</table>

</body>
</html>
<cfoutput>
<script>





</script>
</cfoutput>
