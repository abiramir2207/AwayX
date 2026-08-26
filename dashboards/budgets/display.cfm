<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<!--- To indicate that the web application should run in full screen mode on the iPad --------- --->
<meta name = "apple-mobile-web-app-capable" content="yes" />
<!--- used to avoid mobile safari from looking at a 7 digit string as a phone number ---------- --->
<meta name = "format-detection" content = "telephone=no" />


<title>blacksmith applications :: dashboards</title>

<!--- ----------------------------------------------------------------------------------------- --->
<!--- This is the master file with all the settings ------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfinclude template="appsettings.cfm">
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfif NOT isdefined("cookie.budget_classes") AND NOT isdefined('form.remember_budget_classes')>
	<cfquery name="Get_budget_Class_Selection" datasource="#Application.Datasource#">
		SELECT  BCS.Budget_Class_ID,
				 BC.Budget_Class_Desc
		FROM Budget_Class_Selection BCS
		INNER JOIN Budget_Class BC ON
			BC.Budget_Class_ID = BCS.Budget_Class_ID
		WHERE User_Id = '#request.AccessStructure.user_id#'
		Order by BC.start_date
	</cfquery>


	<cfquery name="Get_budget_classes" datasource="#Application.Datasource#">
	SELECT	distinct Budget_Class.Budget_Class_Desc	as	Budget_Class_Desc,
			Budget_Class.is_fiscal,
			Budget_Class.start_date,
			Budget_Class.end_date
			,Budget_Class.Budget_Class_ID
	FROM	dbo.dashboards_budget_weekly_summary


	        left join Budget on Budget.Budget_ID = Dashboards_Budget_Weekly_Summary.Budget_ID
	        left join Budget_Class on Budget_Class.Budget_Class_ID = Budget.Budget_Class_ID
	WHERE	1=1

	        AND     dash_budget_type = 3
	        <cfif 	user_market_list neq "">
	        AND		market_id in (#user_market_list#)
	        <cfelse>
	        AND		1=2 <!--- Do not return any record if user is below this level --->
			</cfif>
	Order by Budget_Class.start_date
	</cfquery>
	<!--- IF USER HAS MADE A SELECTION, USE IT ELSE LIST ALL --->
	<cfif Get_budget_Class_Selection.RecordCount GT 0 >
		<cfcookie name="budget_classes" value="#ValueList(Get_budget_Class_Selection.Budget_Class_Desc,",")#">
	<cfelse>
		<cfcookie name="budget_classes" value="#ValueList(Get_budget_classes.Budget_Class_Desc,",")#">
	</cfif>
</CFIF>

</head>


<body>

<div align="center">

<!--- ----------------------------------------------------------------------------------------- --->
<div class="header gradient_fix">
	<cfinclude template="_header.cfm">
</div>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<div class="main_container">
	<cfinclude template=#content#>
</div>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<div class="footer gradient_fix">
	<cfinclude template="_footer.cfm">
</div>
<!--- ----------------------------------------------------------------------------------------- --->

</div>

</body>
</html>
