<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!---
##	Data Integration Viewer
##	mws - 9-13-04
##	displays details on upload files based on the "Intra_Id"
##	This value is hard wired at time of file upload.
##	If different file types (intra id's) are added, they should be added in ascending order
##	logic assumes that all intra id's are accounted for...if not, the file type header rows will not be accurate
--->
<html>
<head>
	<title>Untitled</title>
</head>

<cfparam name="m" default="#datepart("m",now())#">
<cfparam name="d" default="#datepart("d",now())#">
<cfparam name="y" default="#datepart("yyyy",now())#">
<cfparam name="ymd" default="#dateFormat(CreateDate(y, m, d),"ddd. mmmm d, yyyy")#">
<cfparam name="mdy" default="#dateFormat(CreateDate(y, m, d),"mmddyyyy")#">
<cfparam name="jymd" default="#dateFormat(CreateDate(y, m, d),"yyyymmdd")#">

<cfset archDir= Application.Doc_Path&"/Data_Files/DataIntArchive/"&mdy&"/">

<cfquery datasource="#application.datasource#" name="qDataInt">
	SELECT      *
	FROM         Data_integration_Upload
	WHERE			datepart(dd, created_date) = <cfqueryparam value="#d#">
	and  		datepart(mm, created_date) = <cfqueryparam value="#m#">
	and			datepart(yyyy, created_date) = <cfqueryparam value="#y#">
	order by category, Intra_id, created_date
</cfquery>

<cfquery datasource="#application.datasource#" name="qFailedJobs">
	DECLARE @dbname varchar(35)

	SET @dbname = (select TOP 1 TABLE_CATALOG  from INFORMATION_SCHEMA.TABLES)

	SELECT	distinct(name) as Job_name, ISNULL(CAST(IsInbox AS int), 3)  as IsInbox,j.*, jh.*
	FROM	msdb.dbo.sysjobs j 
		Full outer Join  Data_integration_Jobs DIJ on dij.job_name = j.name
		Join msdb.dbo.sysjobhistory jh on jh.job_id = j.job_id
	WHERE	jh.run_date = #jymd#	
		and step_id = 0
		and run_status = 0
		and j.name LIKE '%' + @DBName + '%'
</cfquery> 

<body>
<form name=viewForm>
	<input type=hidden name=ymd value="form.ymd">
</form>

<cfset pagetitle = "#ymd#">
<div style="width:99%">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
</div>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<table class="datagrid">
<thead>
	<th class="header">&nbsp;</th>
	<th class="header" style="display: none;">&nbsp;</th>
	<th class="header">Process<br>Date/Time</th>
	<th class="header">Amount<br>Check Sum</th>
	<th class="header">Quantity<br>Check Sum</th>
	<th class="header">Proc.<br>File</th>
	<th class="header">Total<br>Records</th>
	<th class="header">Accpt.<br>Records</th>
	<th class="header">Rejected<br>Records</th>
	<th class="header">View<br>File</th>
	<th class="header">File Name</th>
</thead>
<tbody>
<cfoutput query="qdataInt">
<cfif trim(category) is "">
	<cfset thisCategory = "OTHER">
<cfelse>
	<cfset thisCategory = ReReplace(category, "[^a-zA-Z0-9]", "", "ALL")>
</cfif>
<tr>
	<td>#Flat_File_Name#</td>
	<td style="display: none;">#trim(thisCategory)#</td>
	<td>#Run_Time# #Run_Date#</td>
	<td><cfif Amount_Checksum is 0>N/A<cfelse>#numberformat(Amount_Checksum,999999999.99)#</cfif></td>
	<td><cfif Quantity_Checksum is 0>N/A<cfelse>#numberformat(Quantity_Checksum,999999999.99)#</cfif></td>
	<td>#Process_Yes_No#</td>
	<td>#Total_Count_Received#</td>
	<td>#Total_Count#</td>
	<td>
		<cfif Count_Rejected gt 0>
			<a href="javascript:(void);" onClick="javascript:window.open('ViewHistory.cfm?from=#Replace(category,"_","")#&tName=#Log_Tablename#&upid=#Data_integration_Upload_ID#&type=error&rt=#run_time#&rd=#run_date#&t=#Flat_File_Name#','viewHist','toolbar=no,width=1010,height=660,location=no,menubar=no,resizable=no,scrollbars=no');return false">
				<span style="color:red;text-decoration : underline;" title="View Error Log">#Count_Rejected#</span>
			</a>
		<cfelse>
			0
		</cfif>
	</td>
	<td>
		<cfif trim(Archive_Tablename) neq "">
			<a href="javascript:(void);" onClick="javascript:window.open('ViewHistory.cfm?tName=#Archive_Tablename#&upid=#Data_integration_Upload_ID#&type=arch&t=#Flat_File_Name#&rt=#run_time#&rd=#run_date#','viewHist','toolbar=no,width=1010,height=660,location=no,menubar=no,resizable=no,scrollbars=no');return false">
				<img src="/images/download.gif" border="0" title="View the <cfif Total_Count_Received gt 10000>top 10,000 records of the </cfif>file in your browser">
			</a>
		</cfif>
	</td>
	<td>#Unique_File_Name#</td>
</tr>
</cfoutput>
</tbody>
</table>
<style>
	tr.group,
	tr.group:hover {
	    background-color: #ddd !important;
	    font-weight: bold;
	}
</style>
<cfset datatables.version = "1.10.15">
<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables2.cfm">
<script>
	var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .84 : .84) * windowHeight;
	oTable = $('.datagrid').DataTable({
	 "bAutoWidth": true
	,"bPaginate": false
	,"bSortClasses": false
	,"sDom": "t"
	,"sScrollY": sScrollY
	,"aoColumns": [
									  {"bSearchable": false,  "bSortable":false}
									,	{"bSearchable": false, 	"bSortable":false}
									,	{"bSearchable": false, 	"bSortable":false}
									,	{"bSearchable": false, 	"bSortable":false}
									,	{"bSearchable": false, 	"bSortable":false}
									,	{"bSearchable": false, 	"bSortable":false}
									,	{"bSearchable": false, 	"bSortable":false}
									,	{"bSearchable": false, 	"bSortable":false}
									,	{"bSearchable": false, 	"bSortable":false}
									,	{"bSearchable": false, 	"bSortable":false}
									,	{"bSearchable": false, 	"bSortable":false}
		            ]
  ,"order": [[ 1, 'asc' ]]
  ,"drawCallback": function ( settings ) {
            var api = this.api();
            var rows = api.rows( {page:'aLL'} ).nodes();
            var last=null;
            api.column(1, {page:'all'} ).data().each( function ( group, i ) {
                if ( last !== group ) {
                    $(rows).eq( i ).before(
                        '<tr class="group"><td colspan="11">'+group+'</td></tr>'
                    );
                    last = group;
                }
            } );
			}
		})
</script>
<cfoutput><br>
<a href="javascript:(void);" onClick="javascript:window.open('ViewFailedJobs.cfm?rd=#jymd#&ymd=#ymd#&y=#y#&m=#m#&d=#d#','ViewFailedJobs','toolbar=no,width=1010,height=660,location=no,menubar=no,resizable=yes,scrollbars=yes');return false">
				<img src="/images/process_failed.gif" border="0" title="ViewFailedJobs">    <span class="toptext"> Failed DataBase Jobs  ::  <cfoutput>#ymd#</cfoutput></span>
			</a>
</cfoutput>
</body>
</html>