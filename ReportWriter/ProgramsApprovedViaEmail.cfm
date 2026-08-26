<!--- Template: \ReportWriter\ProgramsApprovedViaEmail.cfm
      Date:     Feb 9, 2011
      Author:   Chris Nguyen
      Purpose:  Generate Programs Approved Via Email Report in Excel format,
                and allow users to open or save the Excel report.
--->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>Programs Approved Via Email</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<cfscript>
  // default to the last 367 days, custom value (in integer) may be specified in Reports.Report_URL_Options
  daysRange      = 367;   
  ReportTemplate = "ProgramsApprovedViaEmail.cfm";
</cfscript>

<!--- get all reports for group 1 ---> 
<cfinvoke component="components.user.ReportsCentralAccess"
          method="getReports"
          returnvariable="ReportsQuery">
    <cfinvokeargument name="report_group" value="1">      
</cfinvoke>     

<!--- determine the no. of days from today to filter --->
<cfloop query="ReportsQuery">
    <!--- find the Programs Approved Via Email report & get the days filter value --->
  <cfif FindNoCase(ReportTemplate, ReportsQuery.Report_url) 
         and Len(ReportsQuery.Report_URL_Options) 
         and isNumeric(ReportsQuery.Report_URL_Options)>
       <cfset daysRange = ReportsQuery.Report_URL_Options>
     <cfbreak>
  </cfif>
</cfloop>


<body topmargin="0" leftmargin="0">
<cfoutput>
    <table width="100%" align="center" style="margin-top:15px">
      <tr>
        <td align="center" style="font:17px arial, sans-serif;color:000080;">
          <b>Programs Approved Via Email within the last #daysRange# days</b>
        </td>
        <td align="center">
            <cf_button
                Button_Name    = ""
                Button_Caption = "programs_approved_via_email_#DateFormat(Now(), 'mmmddyyyy')#"
                Button_Action  = "/ReportWriter/ProgramsApprovedViaEmailReport.cfm?daysRange=#daysRange#"
                Button_Type    = "link"
                Button_Width   = "150"
                Button_Color   = "Navy"
                Button_Tip     = ""
                Font_Color     = "White"
                Font_Size      = "14"
                Font_Weight    = "bold">
        </td>
      </tr>
    </table>
</cfoutput>

<!---<cfdump var="#DateAdd('d', -daysRange, now())#">--->
</body>
</html>




