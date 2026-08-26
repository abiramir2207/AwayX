<!----------------------------------------------------------------------------------------------------------------------------------
	Template:	/settings/Mass_Program_Load/process_import.cfm
	Author: 	Tim Ford
	Date: 		4/7/2017
	Purpose: 	Process import programs from Excel XLSX file
----------------------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<html lang="en">
<head>
  <cfsavecontent variable="head_content">
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<cfinclude template="/common_files/jQuery.cfm">

	<cfset jQueryUI.widgets = "tooltip">
	<cfinclude template="/common_files/jQuery.cfm">
	<cf_include files="/common_files/datatable.css, /common_files/datatableIcon.css">
	<style>
	  div.header {
		height: 27px;
		margin:0 0 10px 0;
		background-image:
		  linear-gradient(
			to right,
			 #010281, #A7CAF2
		  );
		color: white;
		font-size: 14px;
		font-weight: bold;
		letter-spacing: 0.75px;
		padding:8px 0 0 8px;
	  }
	  #abc { text-align:center; }
	  #abc > .error { font-weight: bold; font-size:13px; color: red; }
	  .exclamation { position:relative; top:5px; height=15; width=15; margin-right:5px; }
	  .datagrid thead tr th { text-align: left; vertical-align: top; }
	  .datagrid tbody tr td { overflow: hidden; text-align: left; vertical-align: top;  }
	  div.file { color: #818152; font-size: 14px; font-weight: bold; letter-spacing:0.25px; text-align: center; margin-bottom: 8px; }
	  div#result { color: #818152; font-size: 12px; font-weight: bold; letter-spacing:0.25px; text-align: center; }
	  .center { text-align: center; }
	  .numeric { text-align: right; }
	</style>
  </cfsavecontent>
  <!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
  <cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>
<body>
	<div class="header">
		PROGRAMS - IMPORT
	</div>

	<cfset read_failure = false>
	<cftry>
		<!--- column names & column order are important:  do not change them --->
		<cfspreadsheet action="read"
						src              	= "#url.f#"
						query            	= "qExcelEntries"
						headerrow       	= "1"
						excludeHeaderRow	= "true"
		>
	<cfcatch type="any">
		<cfset read_failure = true>
		<cfset qExcelEntries = queryNew( qExcelEntries.columnList )>
	</cfcatch>
	</cftry>

	<cfoutput>
	<div class="file">#getFileFromPath(url.f)#</div>
	
	<cfquery name="qTruncate" datasource="#application.datasource#">
		TRUNCATE TABLE Y_DEAL_DUMP_FROM_UI
	</cfquery>
	
	
	<cfloop query="qExcelEntries">
		
		<cfquery name="qInsert" datasource="#application.datasource#">
			INSERT INTO Y_DEAL_DUMP_FROM_UI
			(
				[Row_Indicator]
				,[Action]
				,[Segment_ID]
				,[Template]
				,[LEGACY_PROGRAM_ID]
				,[Program_Title]
				,[Start_Date]
				,[End_Date]
				,[DISTRIBUTOR_WEIGHT]
				,[SHIP_TO]
				,[Operator]
				,[Component_Type]
				,[COMPONENT_NAME]
				,[Pays_To]
				,[Claim_Mechanic]
				,[PAYMENT_FREQUENCY]
				,[Vendor_ID]
				,[Material_Type]
				,[ITEM_NUMBER]
				,[Rate]
				,[Rate_UOM]
				,[Lump_Sum_Amount]
				,[Volume]
				,[Volume_UOM]
				,[User_First_Name]
				,[User_Last_Name]
			)
			VALUES
			(
				'#qExcelEntries["Row Indicator"][currentrow]#'
				,'#qExcelEntries["Action"][currentrow]#'
				,'#qExcelEntries["Segment ID"][currentrow]#'
				,'#qExcelEntries["Template"][currentrow]#'
				,'#qExcelEntries["Program ID"][currentrow]#'
				,'#qExcelEntries["Program Title"][currentrow]#'
				,'#qExcelEntries["Program Start Date"][currentrow]#'
				,'#qExcelEntries["Program End Date"][currentrow]#'
				,'#qExcelEntries["Customer Type"][currentrow]#'
				,'#qExcelEntries["Customer ID"][currentrow]#'
				,'#qExcelEntries["Operator"][currentrow]#'
				,'#qExcelEntries["Component Type"][currentrow]#'
				,'#qExcelEntries["External Component ID"][currentrow]#'
				,'#qExcelEntries["Pays To"][currentrow]#'
				,'#qExcelEntries["Claim Mechanic"][currentrow]#'
				,'#qExcelEntries["Payment Cycle"][currentrow]#'
				,'#qExcelEntries["Vendor ID"][currentrow]#'
				,'#qExcelEntries["Material Type"][currentrow]#'
				,'#qExcelEntries["Material ID"][currentrow]#'
				,'#qExcelEntries["Rate or Price"][currentrow]#'
				,'#qExcelEntries["Rate or Price UOM"][currentrow]#'
				,'#qExcelEntries["Lump Sum Amount"][currentrow]#'
				,'#qExcelEntries["Volume"][currentrow]#'
				,'#qExcelEntries["Volume UOM"][currentrow]#'
				,'#qExcelEntries["User First Name"][currentrow]#'
				,'#qExcelEntries["User Last Name"][currentrow]#'
			)
			
		</cfquery>
		
	</cfloop>


	<cfquery name="qCallMassProc" datasource="#application.datasource#">
		EXEC USP_Mass_Program_Load
	</cfquery>
	
	<cfquery name="qCheckErrorLog" datasource="#application.datasource#">
		SELECT	DISTINCT l.Upload_Description, l.Upload_Stat, y.* 
		FROM	LOG_Y_DEAL_Program_Upload l
				INNER JOIN Y_DEAL_DUMP_FROM_UI y on y.LEGACY_PROGRAM_ID = l.LEGACY_PROGRAM_ID
		WHERE	l.Upload_Ratio in ('D','R')
	</cfquery>
	
	<cfset total_errors = qCheckErrorLog.RecordCount />
	
	<cfif total_errors gt 0>
		<div id="result">
		#total_errors# row#(total_errors gt 1 ? 's' : '')# have problems. Please make corrections in your Excel file and try again.<br>
		<a href="index.cfm" style="font-weight:normal;font-size:11px;">#application.util.string.actionLinkFormat('return to home page')#</a>
		</div>
	</cfif>
			
			
	<!--- fail the whole file when number of columns is not right or file has no data --->
	<cfif read_failure or qExcelEntries.recordCount eq 0>
		<div id="abc">
			<img src="/images/Exclamation_Triangle.gif" alt="" class="exclamation"><span class="error">Sorry, something wasn't right in the selected Excel file. Please check the file and try again.</span><br><br>
			<a href="/Manufacturers/home.cfm">#application.util.string.actionLinkFormat('return to home page')#</a>
		</div>
	<cfelse>
		<!--- data table grid --->
		<table class="datagrid">
			<thead>
			<tr>
				<th>Description</th>	
				<th>Status</th>	
				<th>Segment ID</th>	
				<th>TEMPLATE</th>	
				<th>LEGACY PROGRAM ID</th>	
				<th>PROGRAM TITLE</th>	
				<th>START DATE</th>	
				<th>END DATE</th>	
				<th>DISTRIBUTOR WEIGHT</th>	
				<th>SHIP TO</th>	
				<th>Operator</th>	
				<th>Component Type</th>
				<th>COMPONENT NAME</th>	
				<th>PAYS TO</th>	
				<th>CLAIM MECHANIC</th>	
				<th>PAYMENT FREQUENCY</th>	
				<th>Vendor ID</th>	
				<th>Material Type</th>	
				<th>ITEM NUMBER</th>	
				<th>Rate</th>	
				<th>Rate UOM</th>	
				<th>Lump Sum Amount</th>	
				<th>Volume</th>	
				<th>Volume UOM</th>	
				<th>User First Name</th>	
				<th>User Last Name</th>
			</tr>
			</thead>
			<tbody>

			<cfloop query="qCheckErrorLog">
			
					<tr>
						<td>#qCheckErrorLog.Upload_Description#</td>	
						<td>#qCheckErrorLog.Upload_Stat#</td>		
						<td>#qCheckErrorLog.Segment_ID#</td>	
						<td>#qCheckErrorLog.TEMPLATE#</td>	
						<td>#qCheckErrorLog.LEGACY_PROGRAM_ID#</td>	
						<td>#qCheckErrorLog.PROGRAM_TITLE#</td>	
						<td>#qCheckErrorLog.START_DATE#</td>	
						<td>#qCheckErrorLog.END_DATE#</td>	
						<td>#qCheckErrorLog.DISTRIBUTOR_WEIGHT#</td>	
						<td>#qCheckErrorLog.SHIP_TO#</td>	
						<td>#qCheckErrorLog.Operator#</td>	
						<td>#qCheckErrorLog.Component_Type#</td>
						<td>#qCheckErrorLog.COMPONENT_NAME#</td>	
						<td>#qCheckErrorLog.PAYS_TO#</td>	
						<td>#qCheckErrorLog.CLAIM_MECHANIC#</td>	
						<td>#qCheckErrorLog.PAYMENT_FREQUENCY#</td>	
						<td>#qCheckErrorLog.Vendor_ID#</td>	
						<td>#qCheckErrorLog.Material_Type#</td>	
						<td>#qCheckErrorLog.ITEM_NUMBER#</td>	
						<td>#qCheckErrorLog.Rate#</td>	
						<td>#qCheckErrorLog.Rate_UOM#</td>	
						<td>#qCheckErrorLog.Lump_Sum_Amount#</td>	
						<td>#qCheckErrorLog.Volume#</td>	
						<td>#qCheckErrorLog.Volume_UOM#</td>	
						<td>#qCheckErrorLog.User_First_Name#</td>	
						<td>#qCheckErrorLog.User_Last_Name#</td>
					</tr>

			</cfloop>
			</tbody>
		</table>

		
		<hr class="two">
		<div id="result">
			<cfif total_errors gt 0>
				#total_errors# row#(total_errors gt 1 ? 's' : '')# have problems. Please make corrections in your Excel file and try again.<br>
			<cfelse>
				<!--- save entries in Excel file to the database --->
				#qExcelEntries.recordCount# rows in the above Excel file have been loaded successfully.<br>
			</cfif>
			<a href="index.cfm" style="font-weight:normal;font-size:11px;">#application.util.string.actionLinkFormat('return to home page')#</a>
		</div>
	</cfif>
	</cfoutput>

	<cfinclude template="/common_files/dataTables2.cfm">

  	<script>
		<cfif total_errors eq 0>
			jQuery('table.datagrid').hide();
		<cfelse>
			jQuery('table.datagrid').DataTable({
	                               "aaSorting": []
							      ,"aoColumns": [
							                       {"bSortable":true, "bSearchable":false}
							                      ,{"bSortable":true, "bSearchable":false}
							                      ,{"bSortable":true, "bSearchable":false}
							                      ,{"bSortable":true, "bSearchable":false}
							                      ,{"bSortable":true, "bSearchable":false}
							                      ,{"bSortable":true, "bSearchable":false}
							                      ,{"bSortable":true, "bSearchable":false}
							                      ,{"bSortable":true, "bSearchable":false}
							                      ,{"bSortable":true, "bSearchable":false}
							                      ,{"bSortable":true, "bSearchable":false}
							                    ]
	                              ,"bAutoWidth": false
	                              ,"bPaginate": false
	                              ,"bSortClasses": true
	                              ,"bScrollCollapse": true
	                              ,"bFilter": false
								  ,"language": {"emptyTable": <cfoutput>"<b>No problems in Excel import.</b>"</cfoutput>}
	                              ,"sDom": 't'
	                              ,"scrollY": Math.floor(jQuery(window).height()) - 190
	                            });
			jQuery('tbody').on('hover', 'tr', function() { jQuery(this).toggleClass("over"); });
		</cfif>
	</script>

	<cfinclude template="/common_files/focus.cfm">
</body>
</html>