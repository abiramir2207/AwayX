
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Save Auto Pay Report</title>
</head>
<body>
	<cfparam name="form.fx"	         default="0">
	<cfparam name="FORM.FlexAppName" default="AutoPayMain">

	<cfscript>
	variables.oBBReportPeriod = application.oBBReportPeriod.init(0);
	variables.oBBReportPeriod.setStart_date(Form.Start_Date);
	variables.oBBReportPeriod.setEnd_date(Form.End_Date);
	variables.oBBReportPeriod.setSpan(DateDiff("d",Form.Start_Date,Form.End_Date));

	variables.oBBReportPeriod.save(0);
	variables.Report_ID = application.oBBReportUpdate.createReport(variables.oBBReportPeriod.getBB_Auto_Report_Period_ID(),request.accessStructure.User_Id,-1,form.Report_Title);
	application.oBBReportUpdate.saveBBReportProgram(variables.Report_ID,session.user_id,form.Program_List,form);

	</cfscript>

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
					       getFlexApp('AutoPayMain').copyEditReportCallBack('#variables.Report_ID#');

						//	window.opener = 'x';
							window.close();

						//	alert('close');
					    } catch (err) {
					        alert(err.description || err) //or console.log or however you debug
					        alert('catch!')
					    }
					}
			copyEditReport();
		</SCRIPT>
		</cfoutput>
	<cfelse>
		<cflocation url="/billbacks/Auto_BB_Report/BB_Auto_Report_View.cfm">	<!--- 48219 --->
	</cfif>
</body>
</html>

