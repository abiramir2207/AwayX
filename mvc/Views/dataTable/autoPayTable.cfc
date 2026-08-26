
<cfcomponent output="false" displayname="mvc.Views.dataTable.autoPayTable.cfc">
	<cfsetting showDebugOutput="No">
	<cffunction name="getAttrs" returntype="mvc.Views.pm.dataTableAttrs" >
		<cfscript>
			var sRowDetailsHtml = '';
			var attrs   		= structnew();
			
			attrs = createObject('component','mvc.Views.pm.dataTableAttrs');
			//required
			attrs.setArrColumns(["Detail","P.BB_Auto_Report_Period_Id", "R.BB_Auto_Report_Id", "Pause_Schedule", "Current_Id", "Status",  "BB_Amount", "Report_Title", "Date",  "Program_Count", "Billback_Count",  "Status_Info","IMG"]);
	      	attrs.setSqlData(this.getSQL());//query to get data.  needs same columns as arrColumns
	      	attrs.setSqlCount(this.getSQLCount());//replace colnames with "count(1) rownbr"
	      	attrs.setsIdColumn('BB_Auto_Report_Id');
	      	//required end
	      	attrs.setArrColumnDesc(["Detail","Period", "ID", "Pause", "Current_Id", "Status", "Amount",  "Title", "Start Date <br/> End Date", "Prg's", "BB's", "Status <br/> Updated", ""]);
	      	attrs.setArrSearchField(["P.BB_Auto_Report_Period_Id", "R.BB_Auto_Report_Id", "R.Status", "R.Updated_Date", "Report_Title", "User_Code", "B.BB_Code","CM.Contract_Number"]);
			//attrs.setArrSort(["BB_Auto_Report_Period_Id", "BB_Auto_Report_Id", "Pause_Schedule", "Current_Id", "Status", "Updated_Date", "Report_Title", "Start_Date", "End_Date", "User_Code", "Program_Count", "Billback_Count", "BB_Amount", "Status_Desc"]);
			attrs.setArrSort(["BB_Auto_Report_Id", "Updated_Date", "Report_Title", "Start_Date", "User_Code","Program_Count", "Billback_Count", "BB_Amount", "Status_Desc"]);
			//CUSTOM SORT SQL
			objProgram_Count['Program_Count']= 'isnull(count(DISTINCT PP.Program_ID), 0)';
			objProgram_Count['Billback_Count']= 'isnull(count(DISTINCT PPB.Billback_ID), 0)';
			objProgram_Count['Status_Desc']= "CASE R.Status
					WHEN -1 THEN
						'New'
					WHEN 1 THEN
						'Scheduled'
					WHEN 2 THEN
						'Scheduled for recalc'
					WHEN 3 THEN
						'RFA'
					WHEN 4 THEN
						'Approved'
				END";
			objProgram_Count['BB_Amount']= 'isnull(SUM(BA.Paid_Amount), 0)';
			attrs.setObjCustomSort(objProgram_Count);
			//END CUSTOM SORT SQL
			attrs.setArrVisible(["BB_Auto_Report_Id", "Report_Title", "Date", "Program_Count", "Billback_Count", "BB_Amount", "Status_Info", "IMG"]);
			attrs.setbSingleSelect(0);
			attrs.setiDisplayLength(50); 
			attrs.setsPaginationType('full_numbers');
			
			//this will display when a row is expanded.  use sData.colName to access ajax data.  js formatted (+ to concat strings)
			sRowDetailsHtml  = "TRUE";
			attrs.setSRowDetailsHtml(sRowDetailsHtml); //empty row turns off the expand row feature

			return attrs;
		</cfscript>
		
	</cffunction>
	
	<cffunction name="getRow" returnformat="json" access="remote">
		<cfscript>
			var action = structnew();
		</cfscript>
		<cfset qgetPeriods = application.oBBReportGet.getReportPeriod(arguments.id)/>
	 <!---<cfdump var="#arguments#" output = "c:\dump.log"/> ---> 
		<cfset bReportProcessing 	= application.oBBReportGet.getReportProcessingFlag() />
		<cfset qLockInfo 	= application.oBBReportGet.getReportLockInfo() />
		<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetRowBBData">
			SELECT --SUM(CAST(BB.BB_Amount as DECIMAL(12,2))) as AMOUNT, 
					'$' + convert(varchar,cast(isnull(SUM(BB.BB_Amount), 0) as money),-1) as AMOUNT,
				COUNT(BB.Billback_ID) AS NUM
			FROM BB_Auto_Program_Pay_Period PP
			INNER JOIN Billback BB ON 
				BB.Billback_ID = PP.BillBack_ID
			WHERE 	BB_Auto_Report_id = #arguments.id#
		</CFQUERY>
		<!---<cfset bGetReportLock 	= application.oBBReportGet.getReportLock() />
		<cfset bGetReportLockByMe 	= application.oBBReportGet.getReportLockByMe() />--->
		<cfif bReportProcessing eq 0> 
			<cfset links = application.oBBReportGet.getAction(reportID = qgetPeriods.BB_Auto_Report_id,
											periodId	= qgetPeriods.bb_auto_report_period_id,
											status		= qgetPeriods.status,
											endDate		= qgetPeriods.end_date,
											startDate	= qgetPeriods.start_date,
											currPeriod	= qgetPeriods.bb_auto_report_period_id,
											pause		= qGetPeriods.Pause_Schedule) />
		<cfelse>
			<cfset links = "Auto Pay is Processing (locked by #qLockInfo.name_Last#).  Please wait until current Process completes."/>
		</cfif>

		<cfset action['links'] = links/>
		<cfset action['count'] = qGetRowBBData.Num />
		<cfset action['amount'] = qGetRowBBData.Amount />
		<cfset action['status'] = qgetPeriods.Status_Desc/>
		 <cfset action = SerializeJSON( action )>
		<cfreturn action />
	</cffunction>

	<cffunction name="getSQL" returnformat="plain" access="package">
		<!--- #arguments.Del# --->

		<cfreturn " SELECT '' as Detail,	P.bb_auto_report_period_id,
									isnull(R.BB_Auto_Report_id,0) as BB_Auto_Report_id,
									isnull(R.Pause_Schedule,0) as Pause_Schedule,
									(select max(bb_auto_report_period_id) from bb_auto_report_period) 	AS current_id,
									isnull(R.status,0) AS status,
									'$'  + convert(varchar(20),cast( CAST(isnull(SUM(BA.Paid_Amount), 0) AS DECIMAL(12,2)) as money),1) AS BB_Amount,
									R.Report_Title,
									CONVERT(VARCHAR(10), P.Start_Date, 110) + '<br>' +	CONVERT(VARCHAR(10), P.End_Date, 110) AS Date,
									isnull(count(DISTINCT PP.Program_ID), 0) AS Program_Count,
									isnull(count(DISTINCT PPB.Billback_ID), 0) AS Billback_Count,
						CASE R.Status
									WHEN -1 THEN
											'New'
									WHEN 1 THEN
											'Scheduled'
									WHEN 2 THEN
											'Scheduled for recalc'
									WHEN 3 THEN
											'RFA'
									WHEN 4 THEN
											'Approved'
						END +'<br/>'+ U.User_Code +'<br/>'+ CONVERT(VARCHAR(10), R.updated_date, 110) AS Status_Info 
						,' ' as IMG
			FROM		BB_Auto_Report_Period P
			INNER JOIN	BB_Auto_Report R ON
				R.bb_auto_report_period_id = P.bb_auto_report_period_id AND
				R.Deleted = '0'
			LEFT JOIN	BB_Auto_Program_Pay_Period PP
				ON PP.BB_Auto_Report_ID = R.BB_Auto_Report_ID
			LEFT JOIN _users U ON
				U.user_id = ISNULL(R.Approved_User_ID,R.Updated_User_id) AND
				R.updated_User_id IS NOT NULL
			LEFT JOIN	BB_Auto_Pay_Period_Billback PPB
				ON PPB.BB_Auto_Program_Pay_Period_Id = PP.BB_Auto_Program_Pay_Period_Id
			LEFT JOIN	Billback B
				ON	B.Billback_id =  PPB.Billback_id
				AND B.Deleted = 0
			LEFT JOIN BB_Approved BA
				ON BA.Billback_ID = B.Billback_ID
			LEFT JOIN Billback_Program BP ON 
					B.Billback_Id = BP.Billback_id AND 
					BP.Deleted = 0
			LEFT JOIN	Contract_Main CM ON
					CM.Contract_Main_ID = BP.Program_ID
		 	WHERE --WHERE AND
		 		(p.end_date < GetDate() AND
		 		--DATE 
		 		pp.Deleted = 0)
			GROUP BY P.bb_auto_report_period_id,
				R.BB_Auto_Report_id,
				Pause_Schedule,
				R.updated_date,
				R.Report_Title,
				P.Start_Date,
				P.End_Date,
				R.status,
				U.User_Code"/>
	</cffunction>
	
	<cffunction name="getSQLCount" returnformat="plain" access="package">
		
		<cfreturn "SELECT count(1) rownbr
			FROM		BB_Auto_Report_Period P
			INNER JOIN	BB_Auto_Report R ON
				R.bb_auto_report_period_id = P.bb_auto_report_period_id AND
				R.Deleted = '0'
			LEFT JOIN	BB_Auto_Program_Pay_Period PP
				ON PP.BB_Auto_Report_ID = R.BB_Auto_Report_ID
			LEFT JOIN _users U ON
				U.user_id = ISNULL(R.Approved_User_ID,R.Updated_User_id) AND
				R.updated_User_id IS NOT NULL
			LEFT JOIN	BB_Auto_Pay_Period_Billback PPB
				ON PPB.BB_Auto_Program_Pay_Period_Id = PP.BB_Auto_Program_Pay_Period_Id
			LEFT JOIN	Billback B
				ON	B.Billback_id =  PPB.Billback_id
				AND B.Deleted = 0
			LEFT JOIN BB_Approved BA
				ON BA.Billback_ID = B.Billback_ID
			LEFT JOIN Billback_Program BP ON 
					B.Billback_Id = BP.Billback_id AND 
					BP.Deleted = 0
			LEFT JOIN	Contract_Main CM ON  
					CM.Contract_Main_ID = BP.Program_ID
		 	WHERE --WHERE AND
		 		(p.end_date < GetDate() AND
		 		--DATE 
		 		pp.Deleted = 0 )
			GROUP BY P.bb_auto_report_period_id,
				R.BB_Auto_Report_id,
				Pause_Schedule,
				R.updated_date,
				R.Report_Title,
				P.Start_Date,
				P.End_Date,
				R.status,
				U.User_Code"/>
	</cffunction>
</cfcomponent>