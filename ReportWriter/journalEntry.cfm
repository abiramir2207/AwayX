<!doctype html>
<cfsilent>
<!---------------------------------------------------------------------------------------------------------------------
      Template: \ReportWriter\journalEntry.cfm
      Date:     2015 May
      Author:   Chris Nguyen
      Purpose:  Display auto pay reports and provide option to generate journal entry report
----------------------------------------------------------------------------------------------------------------------->
<cfif cgi.request_method eq "post">
	<cfoutput>
	<cfquery name="variables.extract" datasource="#application.datasource#">
	    IF Object_Id( 'tempdb..##tmp_ids') IS NOT NULL
	        DROP TABLE ##tmp_ids

	    CREATE TABLE ##tmp_ids (Row_Id INT)

	    <!--- place all selected IDs in a temp table to share with the stored procedure --->
	    <cfloop list="#form.autopay#" index="variables.singleID">
	        INSERT INTO ##tmp_ids VALUES (#variables.singleID#)
	    </cfloop>

	    EXEC Journal_Entry_Extract
	</cfquery>
	</cfoutput>
	<cfscript>
	    variables.outputFullPathName = application.util.io.TempFileName("journal_entry") & ".xls";
	</cfscript>
	
	<!--- Tim Ford 09/16/2015: WR 52493 - Journal Entry Extract Revision - Added code below to retain leading zeros when exporting to Excel for journal entry.--->
	<cfset sObj=SpreadsheetNew()>
	<cfset SpreadsheetAddRow(sObj, "Created_Type,Type_Code_Legacy,Type_Code_desc,Prod_var_d,Prod_var_d_desc,gl_Account,gl_Account_desc,Approved,Dollars,bb_Start_Date,bb_End_Date")>
	<cfoutput query="variables.extract">
		<cfset SpreadsheetAddRow(sObj, "#Created_Type#,#Type_Code_Legacy#,#Type_Code_desc#,#Prod_var_d#,#Prod_var_d_desc#,#gl_Account#,#gl_Account_desc#,#variables.extract['Approved Dollars'][currentRow]#,#bb_Start_Date#,#bb_End_Date#")>
		<cfset SpreadsheetFormatColumn(sObj, {dataformat="#RepeatString('0', len(trim(Type_Code_Legacy)))#"}, 2)>
	</cfoutput>

	<cfspreadsheet action="write" filename="#variables.outputFullPathName#" name="sObj" sheetname="Journal Entry" overwrite=true>

</cfif>
<cfquery name="variables.autopays" datasource="#application.datasource#">
	SELECT TOP 2000
	        p.bb_Auto_Report_Period_Id
	       ,IsNull( r.bb_Auto_Report_Id, 0 )               AS bb_Auto_Report_Id
	       ,r.Is_Manual
	       ,IsNull( r.Pause_Schedule, 0 )                  AS Pause_Schedule
	       ,( SELECT Max( bb_Auto_Report_Period_Id )
	            FROM bb_Auto_Report_Period )               AS Current_Id
	       ,IsNull( r.Status, 0 )                          AS Status
	       ,r.Updated_Date
	       ,r.Report_Title
	       ,p.Start_Date
	       ,p.End_Date
	       ,u.User_Code
	       ,IsNull( Count( DISTINCT pp.Program_Id ), 0 )   AS Program_Count
	       ,IsNull( Count( DISTINCT ppb.BillBack_Id ), 0 ) AS BillBack_Count
	       ,IsNull( Sum( ba.Paid_Amount ), 0 )             AS bb_Amount
	       ,CASE r.Status
	          WHEN -1 THEN 'New'
	          WHEN 1 THEN 'Scheduled'
	          WHEN 2 THEN 'Scheduled for recalc'
	          WHEN 3 THEN 'RFA'
	          WHEN 4 THEN 'Approved'
	        END                                            AS Status_desc
	  FROM bb_Auto_Report_Period p
	       INNER JOIN bb_Auto_Report r ON r.bb_Auto_Report_Period_Id = p.bb_Auto_Report_Period_Id
	                                      AND r.Deleted = '0'
	       LEFT JOIN bb_Auto_Program_Pay_Period pp ON pp.bb_Auto_Report_Id = r.bb_Auto_Report_Id
	                                                  AND pp.Deleted = '0'
	       LEFT JOIN _Users u ON u.User_Id = IsNull( r.Approved_User_Id, r.Updated_User_Id )
	                             AND r.Updated_User_Id IS NOT NULL
	       LEFT JOIN bb_Auto_Pay_Period_BillBack ppb ON ppb.bb_Auto_Program_Pay_Period_Id = pp.bb_Auto_Program_Pay_Period_Id
	       LEFT JOIN BillBack b ON b.BillBack_Id = ppb.BillBack_Id
	                               AND b.Deleted = 0
	       LEFT JOIN bb_Approved ba ON ba.BillBack_Id = b.BillBack_Id
	 WHERE p.End_Date < GetDate()
	       AND r.Created_Date > DateAdd( mm, -24, GetDate())    --- goes back to most recent 24 months
	 GROUP BY p.bb_Auto_Report_Period_Id
	          ,r.bb_Auto_Report_Id
	          ,r.Is_Manual
	          ,Pause_Schedule
	          ,r.Updated_Date
	          ,r.Report_Title
	          ,p.Start_Date
	          ,p.End_Date
	          ,r.Status
	          ,u.User_Code
	 ORDER BY bb_Auto_Report_Id DESC
	          ,End_Date DESC
</cfquery>

<cfscript>
	variables.aaData = [];
	variables.nbsp = '&nbsp;';
</cfscript>
<!--- build aaData parameter (an array of arrays) for DataTables --->
<cfoutput query="variables.autopays">
	<cfscript>
		variables.aTemp = [];
		arrayAppend(variables.aTemp,'<input type=checkbox name=autopay value="#variables.autopays.bb_Auto_Report_Id#">');
		arrayAppend(variables.aTemp, variables.autopays.bb_Auto_Report_Id);
		arrayAppend(variables.aTemp, variables.autopays.Report_Title);
		arrayAppend(variables.aTemp, application.util.datetime.DateSpanFormat(variables.autopays.Start_Date, variables.autopays.End_Date));
		arrayAppend(variables.aTemp, variables.autopays.Status_desc);
		arrayAppend(variables.aTemp, variables.autopays.Program_Count);
		arrayAppend(variables.aTemp, variables.autopays.BillBack_Count);
		arrayAppend(variables.aTemp, dollarFormat(variables.autopays.bb_Amount));
		arrayAppend(variables.aaData, variables.aTemp);
	</cfscript>
</cfoutput>
</cfsilent>
<html>
<head>
    <title>Journal Entry</title>
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
    <style>
	.right { text-align: right; }
	.header1 { margin: 10px 0; width: 100%; }
	div.content { margin:8px 0; }
	.header2 a { margin-right: 25px; }
	.info { margin-left:30px; font-weight:bold; font-size:1em; color:black; padding:5px 20px; letter-spacing:0.75px; border: 3px solid orange; }
	div#msg55 { font-size: 1.15em; letter-spacing:0.9px; }
	div#msg55 p { font-size: 1.35em; margin:20px; padding:20px; background-color: #BDE5F8; letter-spacing:0.9px; }
	button { cursor: pointer; }
	span.mode1, span.mode2 { font-size: 0.9em; font-weight: normal; }
	span.mode1 { color: #ffce84; }
	span.mode2 { color: white; }
	table.datagrid { table-layout: fixed; }
	table.datagrid td { height2: 20px; overflow: hidden; }
	th, td { overflow:hidden; }
	td.dollar { text-align: right; }
	th.center, td.center { text-align: center; }
	thead th { text-align:left; }
	#hdr22 { background: #a7caf2 url("/Images/gradient.jpg") repeat-y; height:17px;
			 padding: 10px; color:white; font-weight:bold; font-size:1.2em; letter-spacing:1.75px; }
    </style>
</head>
<body>
	<cfsavecontent variable="variables.body">
	<div id="hdr22">JOURNAL ENTRY</div>
	<div id="msg55"></div>    <!--- reserve this div for displaying message in long process (e.g. saving changes) --->
	<!--- main form --->
	<form name="journal_entry" method="post">
		<div class="content">
			<!--- data table grid --->
			<cfset variables.columnSizes = [1,
											1.5,
											5,
											3,
											1.5,
											1.5,
											1.5,
											2.5
											]>
			<!--- <cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( variables.columnSizes )> --->

			<table id="datagrid" class="datagrid" style='table-layout:fixed;width:100%;'>
				<!--- <cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
					<cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
				</cfloop> --->
				<col width="5%"> <col width="8%"> <col width="29%"> <col width="17%"> <col width="8%"> <col width="9%"> <col width="8%"> <col width="16%">
				<cfoutput>
				<thead>
					<tr>
						<th class="center"><input type="checkbox" name="checkall"></th>
						<th id="seg51">ID</th>
						<th>Title</th>
						<th>Date Range</th>
						<th>Status</th>
						<th>## of Programs</th>
						<th>## of Billbacks</th>
						<th>Amount</th>
					</tr>
				</thead>
				</cfoutput>
				<tbody>
				</tbody>
			</table>
		</div> <!--- class="content" --->
		<cfoutput><div><a href="##" id="submit">#application.util.string.actionLinkFormat2("generate journal entry")#</a></div></cfoutput>
	</form>
	</cfsavecontent>
	<!--- remove extra white spaces prior to displaying on the page --->
	<cfoutput>#application.util.string.compress( variables.body )#</cfoutput>

	<cfinclude template="/common_files/jQuery.cfm">
	<cfinclude template="/common_files/dataTables2.cfm">
	<script src="/script/javascript/jquery.dataTables-api.js"></script>

	<script>
	<!--- page was posted and report was generated :: open .xls report content --->
	<cfif isDefined("variables.outputFullPathName")>
	    <!--- replace backslashes which cause problems in window.open --->
	    <cfscript>
	    	variables.outputFileName = GetFileFromPath(variables.outputFullPathName);
	    	variables.webServerPath  = replace(replace( variables.outputFullPathName, '\', '/', 'all' ), variables.outputFileName, '');
		</cfscript>
        <cfoutput>window.open('/common_files/openContent.cfm?type=xls&fileName=#variables.outputFileName#' + '&webServerPath=#variables.webServerPath#', 'openContent', 'height=50,width=10,top=0,left=0');</cfoutput>
	</cfif>
  	var  my_form = $('form[name=journal_entry]')
  		,checkall = $("input[name=checkall]")
  		,windowHeight = $(window).height(), sScrollY = Math.floor( ( windowHeight > 800 ? 0.75 : .70 ) * windowHeight )
     	,mydatagrid = $('#datagrid').show().dataTable({
     						   "aaData": <cfoutput>#serializeJSON(variables.aaData)#</cfoutput>
						      ,"aaSorting": []
						      ,"aoColumns": [	 {"bSortable":false, "bSearchable":false, "sClass":"center"}
												,{"bSortable":true, "sClass":"center"}
												,{"bSortable":true}
												,{"bSortable":true, "bSearchable":false}
												,{"bSearchable":true}
												,{"bSearchable":false, "sClass":"dollar"}
												,{"bSearchable":false, "sClass":"dollar"}
												,{"bSortable":true, "bSearchable":false, "sClass":"dollar"}
						      				]
						      ,"bAutoWidth": false            // false for quicker rendering
						      ,"bDeferRender": true           // true for quicker rendering
						      ,"bPaginate": false
						      ,"bProcessing": true            // true to show processing message in sorting large table
						      ,"bScrollCollapse": false
						      ,"bSortClasses": false
						      ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
						      ,"sDom": 'ftir'
							  ,"sScrollY": sScrollY
	  				});
	// highlight current row
	$('#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
	checkall.change(function() {
		$("input[name=autopay]").attr("checked", (this.checked ? true : false));
	});
	// user clicked generate report option
	$("#submit").click(function() {
		if ($("input[name=autopay]:checked").length == 0) {
			alert("Please select at least one journal entry.");
			return false;
		}
		my_form.hide();
		$("#msg55").append("<p>Generating report, please wait...</p>");
		my_form.submit();
	});
	</script>
</body>
</html>