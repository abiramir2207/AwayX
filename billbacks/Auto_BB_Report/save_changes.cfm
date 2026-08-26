<!--- NOTE: Update is only intended for reports that haven't been run yet --->

<cfparam name="form.fx"	         default="0">
<cfparam name="FORM.FlexAppName" default="AutoPayMain">

<!--- MAKE SURE A REPORT IS NOT PROCESSING.  BACK BUTTON COULD GET US HERE IN THAT STATE --->
<cfscript>
	bProcessing = application.oBBReportGet.getReportLockInfo().Processing;
	if(bProcessing){
		location(url="/billbacks/Auto_BB_Report/index.cfm");
		abort;
	}
</cfscript>
<!--- EXTRA insurance  --->
<CFIF NOT bProcessing>
	<!--- Updates title based on Report ID --->
	<cfquery name="UpdateTitle" datasource="#application.datasource#">
	UPDATE BB_Auto_Report
	SET
		Report_Title =   <cfqueryparam cfsqltype="cf_sql_varchar" value="#Report_Title#">,
		Updated_Date = getdate(),
		Updated_User_ID =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.accessStructure.User_Id#">
	WHERE BB_Auto_Report_ID = <cfqueryparam cfsqltype="numeric" value="#Report_ID#">
	</cfquery>

	<!--- Updates Dates:
	1) Get records to update
	2) Figure out report span
	3) Update bb_auto_report_period
	4) Delete from BB_Auto_Program_Pay_Period
	5) Insert new records
	---->

	<!--- Get records to update --->
	<cfquery name="PeriodsToUpdate" datasource="#application.datasource#">
	SELECT BB_Auto_Report_Period_ID
	FROM BB_Auto_Report
	WHERE BB_Auto_Report_ID = <cfqueryparam cfsqltype="numeric" value="#Report_ID#">
	</cfquery>

	<cfset BB_Auto_Report_Period_ID =  PeriodsToUpdate.BB_Auto_Report_Period_ID>

	<!--- Figure out the report span --->
	<cfset Report_Span = datediff('d' ,Start_Date, End_Date)>

	<!--- Update bb_auto_report_period --->
	<cfquery name="UpdateFirstDates" datasource="#application.datasource#">
	UPDATE BB_Auto_Report_Period
	SET Start_Date 	= <cfqueryparam cfsqltype="date" value="#Start_Date#"> ,
		End_Date	= <cfqueryparam cfsqltype="date" value="#End_Date#">,
		Span		= <cfqueryparam cfsqltype="numeric" value="#Report_Span#">
	WHERE BB_Auto_Report_Period_ID = <cfqueryparam cfsqltype="numeric" value="#BB_Auto_Report_Period_ID#">
	</cfquery>

	<!--- Update BB_Auto_Program_Pay_Period -- this uses report ID --->
	<cfquery name="UpdateSecondDates" datasource="#application.datasource#">
	UPDATE BB_Auto_Program_Pay_Period
	SET Deleted = 1,
		Updated_Date = getdate(),
		Updated_User_ID =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.User_Id#">
	WHERE BB_Auto_Report_ID = <cfqueryparam cfsqltype="numeric" value="#Report_ID#">
	AND Billback_Id IS NULL
	</cfquery>

	<!--- Insert new programs --->
	<cfscript>
		application.oBBReportUpdate.saveBBReportProgram(Report_ID,session.user_id,form.Program_List,form);
	</cfscript>
</CFIF>
 <cfif form.fx eq 1>
		<cfoutput>
		<SCRIPT language="JavaScript"  type="text/javascript">
			function getFlexApp(appName)
				{
				  if (navigator.appName.indexOf ("Microsoft") !=-1)
				  {
				    return opener.window[appName];
				  }
				  else
				  {
				    return opener.document[appName];
				  }
				}

			 function copyEditReport()
					{
						//alert('close1');
						try {
					       getFlexApp('AutoPayMain').copyEditReportCallBack('#Report_ID#');

						//	window.opener = 'x';
							window.close();

						//	alert('close');
					    } catch (err) {
					        alert(err.description || err) //or console.log or however you debug
					        alert('catch changes!')
					    }
					}
			copyEditReport();
		</SCRIPT>
		</cfoutput>
	<cfelse>
		<cflocation url="/billbacks/Auto_BB_Report/BB_Auto_Report_View.cfm">     <!--- 48219 --->
	</cfif>