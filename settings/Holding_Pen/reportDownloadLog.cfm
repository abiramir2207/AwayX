<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\settings\Holding_Pen\reportDownloadLog.cfm
      Date:     08-Jul-2015
      Author:   Anand Rao
      Purpose:  Download files for the Holding pen

      Notes:

----------------------------------------------------------------------------------------------------------------------->

<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">
<cfparam name="URL.fileParam" default="" />
<cfparam name="URL.BBUploadHoldScorecardID" default=0 />
<cfparam name="URL.UploadID" default=0 />

<!--- Initiate the CFC --->
<cfset holdingPenManager = CreateObject("component", "mvc.Models.Settings.HoldingPenManager") />

<cfset qryReportDownloadLog = holdingPenManager.fnReportDownloadLog("#URL.BBUploadHoldScorecardID#") />

<cfset URL.PageTitle="Report Download Log:: Batch No.#URL.UploadID#">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfinclude template="/settings/settings_title.cfm">


<cfoutput> 
	<table class="datagrid">
	  <thead>
	    <th class="header" width="40%"><b>Download Date</b></th>
	    <th class="header" width="60%"><b>User</b></th>
	  </thead>
	  <tbody>
	  	<cfif isDefined("qryReportDownloadLog.RecordCount") and qryReportDownloadLog.RecordCount GTE 1>
	  		<cfloop query="qryReportDownloadLog">
				<tr>
					<td>#DATEFORMAT(qryReportDownloadLog.created_date,"mm/dd/yyyy")# #TimeFormat(qryReportDownloadLog.created_date, "hh:mm:sstt")#</td>
					<td>#qryReportDownloadLog.Name_First# #qryReportDownloadLog.Name_Last#</td>
				</tr>
			</cfloop>
		<cfelse>
			<tr>
				<td colspan="100%" align="center">
					<br>
					<strong>No records were found!</strong>
					<br><br>
					
				</td>
			</tr>
		</cfif>
	  </tbody>
	</table>
</cfoutput><br>
<br>
<br>

<div align="center">
	<input type="button" title="Close Window" value="Close Window" onclick="javascript:window.close();"/>
</div>