<cfcomponent hint="Data Get methods for BBAutoReport">
	<cffunction name="init" output="false" returntype="components.billback.BBAutoReportGet">
		<cfreturn this />
	</cffunction>
<!---
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXX	Get Data functions: Select
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--->
<!--- XXXXXXXXXXXX	getPeriods	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getPeriods" access="public" returntype="query">
		<cfargument name="Del" default="0" type="numeric">
			<cfset var qGetPeriods = "" />
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetPeriods">
				SELECT 	P.bb_auto_report_period_id,
				isnull(R.BB_Auto_Report_id,0) as BB_Auto_Report_id,
				R.Is_Manual,
				isnull(R.Pause_Schedule,0) as Pause_Schedule,
				(select max(bb_auto_report_period_id)
						from bb_auto_report_period)
				AS current_id,
				isnull(R.status,0) as status,
				R.updated_date,
				R.Report_Title,
				P.Start_Date,
				P.End_Date,
				U.User_Code,
				isnull(count(DISTINCT PP.Program_ID), 0) AS Program_Count,
				isnull(count(DISTINCT PPB.Billback_ID), 0) AS Billback_Count,
				isnull(SUM(BA.Paid_Amount), 0) AS BB_Amount,
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
				END 	AS Status_Desc
			FROM		BB_Auto_Report_Period P
			INNER JOIN	BB_Auto_Report R ON
				R.bb_auto_report_period_id = P.bb_auto_report_period_id AND
				R.Deleted = '#arguments.Del#'
			LEFT JOIN	BB_Auto_Program_Pay_Period PP
				ON PP.BB_Auto_Report_ID = R.BB_Auto_Report_ID AND
		 		pp.Deleted = '#arguments.Del#'
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
		 	WHERE p.end_date < GetDate() AND
		 		r.created_date > dateadd(mm,-24,GetDate())		 		
			GROUP BY P.bb_auto_report_period_id,
				R.BB_Auto_Report_id,
				R.Is_Manual,
				Pause_Schedule,
				R.updated_date,
				R.Report_Title,
				P.Start_Date,
				P.End_Date,
				R.status,
				U.User_Code
			ORDER BY BB_Auto_Report_id DESC, end_date DESC 
			</CFQUERY>
		<cfreturn qGetPeriods>
	</cffunction>
	
	<!--- XXXXXXXXXXXX	get Auto Pay type: full auto aor manual Auto	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getAutoPayType" access="public" returntype="numeric">
		<cfargument name="isManual" default="-1" type="numeric">
			<cfset var bReportType = 1 />
			<!--- 	1 = Full Auto
					2 = Manual Auto --->
			<cfif application.appSettingsGet.getBBAutoReportisManuallyConfigured()>
				<cfset bReportType = 2 />
			</cfif>
			<!--- Full auto, but this auto pay is manual --->
			<cfif bReportType eq 1 and arguments.isManual eq 1>
				<cfset bReportType = 2 />
			</cfif>
		<cfreturn bReportType />
	</cffunction>

	<!--- XXXXXXXXXXXX	getOpenPeriod	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getOpenPeriod" access="public" returntype="query">
			<cfset var qGetOpenPeriod = "" />
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetOpenPeriod">
					SELECT Distinct P2.bb_auto_report_period_id,
						0 as BB_Auto_Report_id,
						0 as Pause_Schedule,
						p2.end_date as end_date,
						(select max(bb_auto_report_period_id)
								from bb_auto_report_period)
						AS current_id,
						0 as status,
						getDate(),
						'' AS First,
						'Create' AS Last
					FROM		BB_Auto_Report_Period P2
					INNER JOIN BB_Auto_Program_Pay_Period Pay
						ON Payment_End_Date <= p2.end_date AND
						Pay.BB_Auto_Report_id is NULL
				 	WHERE p2.end_date < GetDate() AND
				 		p2.end_date > dateadd(mm,-12,GetDate()) AND
						p2.bb_auto_report_period_id = (SELECT MAX(bb_auto_report_period_id)
															FROM bb_auto_report_period)
					ORDER BY end_date DESC, BB_Auto_Report_id DESC
			</CFQUERY>
		<cfreturn qGetOpenPeriod>
	</cffunction>

<!--- XXXXXXXXXXXX	Get Current Period	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getCurrentPeriod" access="public" returntype="numeric">
		<cfset var qGetCurrentPeriod = "" />
		
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetCurrentPeriod">
					SELECT TOP 1
							isnull(bb_auto_report_period_id,0) as bb_auto_report_period_id,
							end_date
						FROM BB_Auto_Report_Period
						<cfif application.oBBReportGet.getAutoPayType() EQ 2>
							ORDER BY bb_auto_report_period_id DESC
						<cfelse>
							ORDER BY end_date DESC
						</cfif>
			</CFQUERY>

		<cfif qGetCurrentPeriod.recordCount>
			<cfreturn qGetCurrentPeriod.bb_auto_report_period_id>
		<cfelse>
			<cfreturn 0>
		</cfif>
  	</cffunction>

<!--- XXXXXXXXXXXX	getOpenClaims	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getOpenClaims" access="public" returntype="boolean">
		<cfargument name="periodId" required="yes" type="numeric" />
		<cfset var qGetOpenClaims = "" />
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetOpenClaims">
				SELECT top 1 * FROM dbo.BB_Auto_Program_Pay_Period Pay
					JOIN BB_Auto_Report_Period P
						ON P.BB_Auto_Report_Period_ID = '#arguments.periodId#'
 					WHERE Pay.BB_Auto_Report_id IS NULL
					AND Payment_End_Date <= p.end_date
			</CFQUERY>
		<cfreturn qGetOpenClaims.recordcount>
	</cffunction>

<!---START  REPORT LOCK		REPORT LOCK		REPORT LOCK		REPORT LOCK		REPORT LOCK		REPORT LOCK		REPORT LOCK		REPORT LOCK		 --->
<!--- XXXXXXXXXXXX	getReportLock	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getReportLock" access="public" returntype="boolean">
		<cfargument name="UserId"	required="yes"	type="any" default="0" />
		<cfargument name="cache"	required="no"	type="any" default="1" />
		<cfset var qGetReportLock 	= "" />
		<cfset var qinsertReportLock 	= "" />

		<cfif isdefined("request.GetReportLock") AND arguments.cache eq 1 >
			<!--- Do nothing. request.qGetReportLock.Locked is returned --->
		<cfelse> <!--- get lock status --->
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetReportLock">
				BEGIN TRANSACTION;
					INSERT BB_Auto_Report_Lock 
					(Locked) SELECT 0
					WHERE NOT EXISTS(SELECT Locked FROM BB_Auto_Report_Lock)

					SELECT Locked,
							Processing
					FROM BB_Auto_Report_Lock
				COMMIT TRANSACTION;
			</CFQUERY>
			<!--- put in request scope for future checks.
					Report must be UnLocked and Not processing. A user could start the Job and then logout while it is
					still running, so we check the processing bit as well --->
			 <cfif qGetReportLock.Locked EQ 0 AND qGetReportLock.Processing EQ 0>
				<cfset request.GetReportLock = 0 />
			<cfelse>
				<cfset request.GetReportLock = 1/>
			</cfif>
		</cfif>
		<cfreturn request.GetReportLock />
	</cffunction>

<!--- XXXXXXXXXXXX	getReportLockByMe	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getReportLockByMe" access="public" returntype="boolean">
		<cfargument name="UserId"	required="yes"	type="any" default="0" />
		<cfargument name="cache"	required="no"	type="any" default="1" />
		<cfset var qGetReportLockByMe = "" />
		<cfset var getReportLockByMe = 0 />
		<cfif isdefined("request.getReportLockByMe") AND arguments.cache eq 1 >
			<!--- this value is returned --->
		<cfelse> <!--- get lockByMe status --->
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetReportLockByMe">
				SELECT Locked
				FROM BB_Auto_Report_Lock
				WHERE Locked_By_User_Id= '#arguments.userId#'
			</CFQUERY>
				<cfif qGetReportLockByMe.Locked EQ 1>
					<cfset getReportLockByMe = 1 />
				</cfif>
			<cfset request.getReportLockByMe = getReportLockByMe />
		</cfif>
		<cfreturn request.getReportLockByMe />
	</cffunction>

<!--- XXXXXXXXXXXX	getReportLockIcon	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getReportLockIcon" access="public" returntype="string">
		<cfargument name="UserId"	required="yes"	type="any" default="0" />
		<cfset var qGetReportLockByMe = "" />
		<cfset var icon 	= "" />
		<cfset var tmpUnlock 	= "" />
		<!--- Check to see if report lockholder has an expired Session and Unlock if that is the case --->
		<!--- <cfset this.oUpd	= CreateObject("component","components.Billback.BBAutoReportUpdate").init() /> --->
		<cfset tmpUnlock	= application.oBBReportUpdate.UnlockReport() />
		<cfsavecontent variable="icon">
		<cfoutput>
			<cfif this.getReportLock()>
			  <cfif this.getReportLockByMe(arguments.userId)>
			  	<a  id="lockReport"
					title="Click To Unlock"
					onclick="this.disabled=1;"
					href="/billbacks/auto_bb_report/index.cfm?Disp=view&PageTitle=PAYABLES: Auto Pay Report Maintenance&Lck=0">
			  			<img src="/images/edit_mode.gif" align="middle" border="0" />
				</a>
			  <cfelse>
			    Locked By #this.getReportLockInfo().Name_Last#
			  </cfif>
			<cfelse>
				<a  id="lockReport"
					title="Click To Lock"
					onclick="this.disabled=1;"
					href="/billbacks/auto_bb_report/index.cfm?Disp=view&PageTitle=PAYABLES: Auto Pay Report Maintenance&Lck=1">
						<img src="/images/readonly_mode.gif" align="middle" border="0" />
				</a>
			</cfif>
		</cfoutput>
		</cfsavecontent>
		<cfreturn icon />
	</cffunction>

<!--- XXXXXXXXXXXX	getReportLockInfo	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getReportLockInfo" access="public" returntype="query">
		<cfset var qGetReportLockInfo = "" />
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetReportLockInfo">
				SELECT	Locked_By_User_Id,
						Locked_Date,
						CASE Locked
							WHEN 1 THEN
								Name_Last
							WHEN 0 THEN
								'Job Processing'
						END
						AS Name_Last,
						Name_First,
						ISNULL(Processing,0)  AS Processing,
						ISNULL(Locked,0) AS Locked
				FROM BB_Auto_Report_Lock L
				LEFT JOIN _Users U ON
						U.user_Id = L.Locked_By_user_Id
			</CFQUERY>
		<cfreturn qGetReportLockInfo />
	</cffunction>
	
<!--- XXXXXXXXXXXX	getReportProcessingFlag	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getReportProcessingFlag" access="public" returntype="boolean">
		<cfset var processing = 0 />
		<cfif isdefined("request.getReportProcessingFlag") and isBoolean(request.getReportProcessingFlag)>
			<cfset processing = request.getReportProcessingFlag />
		<cfelse>
			<cfset qGetReportLockInfo = this.getReportLockInfo() />
			<cfif qGetReportLockInfo.RecordCount>
				<cfset processing = qGetReportLockInfo.processing />
			</cfif>
			<cfset request.getReportProcessingFlag = processing />
		</cfif>
		<cfreturn processing />
	</cffunction>
<!---END REPORT LOCK		REPORT LOCK		REPORT LOCK		REPORT LOCK		REPORT LOCK		REPORT LOCK		REPORT LOCK		REPORT LOCK		 --->

<!--- XXXXXXXXXXXX	getReportBB	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getReportBB" access="public" returntype="boolean">
		<cfargument name="reportId" required="yes" type="numeric" />
		<cfset var qGetReportBB = "" />
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetReportBB">
				SELECT top 1 PP.BB_Auto_Program_Pay_Period_id
					FROM BB_Auto_Program_Pay_Period PP
					INNER JOIN BB_Auto_Pay_Period_Billback PBB ON
						PBB.BB_Auto_Program_Pay_Period_Id = PP.BB_Auto_Program_Pay_Period_Id
					WHERE pp.bb_auto_Report_id = '#arguments.reportId#'
						AND PP.deleted = 0
						--AND BBillback_Id is NOT NULL
			</CFQUERY>
		<cfreturn qGetReportBB.recordcount />
	</cffunction>

<!--- XXXXXXXXXXXX	getBBInfo   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getBBInfo" access="public" returntype="query">
		<cfargument name="BillBackId" required="yes" type="any" />
		<cfargument name="PayPeriod_ID"	required="no" type="any" default="0" />
		<cfset var qGetBBInfo = "" />
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetBBInfo">
				SELECT	B.BB_code,
						B.BB_Title,
						B.Billback_Id
				FROM Billback B
				<CFIF arguments.PayPeriod_ID NEQ 0>
				INNER JOIN	BB_Auto_Pay_Period_Billback PBB ON
						PBB.BB_Auto_Program_Pay_Period_Id = '#arguments.PayPeriod_ID#' AND
						PBB.Billback_Id = B.Billback_Id
				<CFELSE>
					WHERE Billback_Id = '#arguments.BillbackId#'
				</CFIF>
				ORDER BY B.BB_code DESC
			</CFQUERY>
		<cfreturn qGetBBInfo />
	</cffunction>

<!--- XXXXXXXXXXXX	get a single report and period	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getReportPeriod" access="public" returntype="query">
			<cfargument name="reportID"	required="yes"	type="numeric" default="0" />
			<cfset var qGetReportPeriod = "" />
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetReportPeriod">
				SELECT 	P.bb_auto_report_period_id,
						isnull(R.BB_Auto_Report_id,0) as BB_Auto_Report_id,
						end_date,
						start_date,
						status,
						R.updated_date,
						R.Pause_Schedule,
						R.Report_Title,
						U.Name_first AS First,
						U.Name_Last AS Last,
						CASE status
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
						END AS Status_Desc
					FROM		BB_Auto_Report_Period P
					LEFT JOIN	BB_Auto_Report R ON
						R.bb_auto_report_period_id = P.bb_auto_report_period_id
						--And R.Deleted = 0
					LEFT JOIN _users U ON
						U.user_id = R.updated_User_id And
						R.updated_User_id IS NOT NULL
				 	WHERE BB_Auto_Report_id = #arguments.reportId#
			</CFQUERY>
		<cfreturn qGetReportPeriod>
	</cffunction>

<!--- XXXXXXXXXXXX	get report details 	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getReportDetails" access="public" returntype="query">
			<cfargument name="reportID"	required="yes"	type="numeric" default="0" />
			<cfargument name="Search_String"	required="no"	type="string" default="" />
			<cfargument name="billbackData"	required="false"	type="boolean" default="1" />
			<cfset var qGetReportDetails = "" />
			<cfset var bBillbackData = 1 />
			
			<cfset bBillbackData = arguments.billbackData />
			
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetReportDetails">
				SELECT 	P.bb_auto_report_period_id,
						isnull(R.BB_Auto_Report_id,0) AS BB_Auto_Report_id,
						R.status as ReportStatus,
						R.updated_date,
						R.updated_User_id,
						/*B.Billback_id,
						B.BB_code,
						B.BB_Title,*/
						SUM(BA.Paid_Amount) AS BB_Amount,
						SUM(isnull(BA.Pullback_Applied_Amount, 0)) as Pullback_Applied_Amount,
						P.end_date,
						PP.Status AS BBStatus,
						PP.BB_Auto_Program_Pay_Period_ID,
						PP.Payment_Start_Date,
						PP.Payment_End_Date,
						PP.Discount_Type_Id,
						U.Name_first AS First,
						U.Name_Last AS Last,
						CM.Contract_Title,
						CM.Contract_Number,
						CM.Contract_Main_Id,
						IsNull(BO.Operator_name,IsNull(BFC.Name,IsNull(BRO.Broker_Name,ISNull(VM.Vendor_Name,'NA')))) as Vendor_Name,
						IsNull(Eshark_RecordID,IsNull(BFC.Ship_to,IsNull(BRO.Broker_legcy_Shard,ISNULL(VM.Vendor_id,'')))) as Vendor_ID,
						PC.Payment_Cycle
					FROM	BB_Auto_Report_Period P
					JOIN	BB_Auto_Report R ON
						R.bb_auto_report_period_id = P.bb_auto_report_period_id
						--And R.Deleted = 0
					JOIN	BB_Auto_Program_Pay_Period PP ON
							PP.BB_Auto_Report_id = R.BB_Auto_Report_id And
							--don't need this check. Look for report_id. If bb_id = null, it is recalc
							--(PP.Billback_id IS Not Null OR PP.Status = 1) AND
							PP.Deleted = 0
					LEFT JOIN	BB_Auto_Pay_Period_Billback PBB ON
							PBB.BB_Auto_Program_Pay_Period_Id = PP.BB_Auto_Program_Pay_Period_Id
					LEFT JOIN	Billback B ON
							B.Billback_id = PBB.Billback_id
					LEFT JOIN	BB_Approved BA ON
							B.Billback_id = BA.Billback_id
					LEFT JOIN Contract_Main CM ON
							CM.Contract_Main_ID = PP.Program_ID
					
					<cfif bBillbackData>
					LEFT JOIN Billback_Distributor BD ON
						BD.Billback_id = B.Billback_id		
					LEFT JOIN Billback_Operator BBO ON
						BBO.Billback_id = B.Billback_id
					LEFT JOIN BillBack_Broker BBr ON
						BBr.Billback_id = B.Billback_id	
					<cfelse>
						LEFT JOIN Billback_Distributor BD ON
							BD.Billback_id = PP.Billback_id		
						LEFT JOIN Billback_Operator BBO ON
							BBO.Billback_id = PP.Billback_id
						LEFT JOIN BillBack_Broker BBr ON
							BBr.Billback_id = PP.Billback_id
					</cfif>
							
					LEFT JOIN _users U ON
						U.user_id = R.updated_User_id And
						R.updated_User_id IS NOT NULL
					LEFT JOIN BSA_Foodservice_Customers BFC ON
							BFC.BSA_Foodservice_Customers_ID = BD.Distributor_ID
					LEFT JOIN BSA_Operator BO ON
							BO.BSA_Operator_ID = BBO.Operator_ID
					LEFT JOIN BSA_Foodservice_Brokers BRO ON
							BBr.Broker_ID = BRO.BSA_Foodservice_Brokers_ID
					LEFT JOIN Payment_Cycle PC ON
						PC.Payment_Cycle_ID = PP.Payment_Cycle_Id
					LEFT JOIN Vendor_Master VM ON
						VM.vendor_Master_Id = BD.Distributor_ID
				 	WHERE R.BB_Auto_Report_id =  '#arguments.reportId#'
					<cfif trim(arguments.Search_String) NEQ "">
						AND (
							BB_Code Like '%#arguments.Search_String#%'
								OR
							CM.Contract_Number Like '%#arguments.Search_String#%'
								OR
							BO.Operator_name Like '%#arguments.Search_String#%'
								OR
							BFC.Name LIKE '%#arguments.Search_String#%'
								OR
							BRO.Broker_Name LIKE '%#arguments.Search_String#%'
						
							)
					</cfif>
						GROUP BY
						P.bb_auto_report_period_id,
						R.BB_Auto_Report_id,
						R.status,
						R.updated_date,
						R.updated_User_id,
						P.end_date,
						PP.Status,
						PP.BB_Auto_Program_Pay_Period_ID,
						PP.Payment_Start_Date,
						PP.Payment_End_Date,
						PP.Discount_Type_Id,
						U.Name_first,
						U.Name_Last,
						CM.Contract_Title,
						CM.Contract_Number,
						CM.Contract_Main_Id,
						PC.Payment_Cycle,
						BFC.Name,
						BFC.Ship_to,
						BO.Operator_name,
						BO.Eshark_RecordID,
						BRO.Broker_Name,
						BRO.Broker_legcy_Shard,
						VM.Vendor_Name,
						VM.Vendor_id
			</CFQUERY>
		<cfreturn qGetReportDetails />
	</cffunction>

<!--- Gets information for copy and edit --->
	<cffunction name="getReportInfo" access="public" returntype="query">
	<cfargument name="Report_ID"	required="yes"	type="numeric" /> 
	<!--- Initialize all vars used in the component--->
		<cfset var qGetReportInfo = "">
		
		<cfquery name="qGetReportInfo" datasource="#application.datasource#">
		SELECT DISTINCT
			BB_Auto_Report.Report_Title,
			BB_Auto_Report_Period.Start_Date,
			BB_Auto_Report_Period.End_Date
		FROM BB_Auto_Report
			INNER JOIN BB_Auto_Report_Period
			ON BB_Auto_Report_Period.BB_Auto_Report_Period_ID = BB_Auto_Report.BB_Auto_Report_Period_ID
		WHERE BB_Auto_Report.BB_Auto_Report_ID = <cfqueryparam cfsqltype="numeric" value="#arguments.Report_ID#"> 
		</cfquery>
	
	<cfreturn qGetReportInfo />
	
	</cffunction>
	
	<cffunction name="getReportPrograms" access="public" returntype="query">
	<cfargument name="Report_ID"	required="yes"	type="numeric" /> 
	<!--- Initialize all vars used in the component--->
		<cfset var qGetReportPrograms = "">
		
		<cfquery name="qGetReportPrograms" datasource="#application.datasource#">
		SELECT DISTINCT
			Program_ID
		FROM BB_Auto_Program_Pay_Period
		WHERE BB_Auto_Report_ID = <cfqueryparam cfsqltype="numeric" value="#arguments.Report_ID#"> 
		AND Deleted = 0
		</cfquery>
	
	<cfreturn qGetReportPrograms />
	
	</cffunction>
	
<!--- XXXXXXXXXXXX	getBBDetail	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getBBDetail" access="public" returntype="query">
		<!--- <cfargument name="reportID"	required="yes"	type="numeric" /> <!--- Not Needed --->
		<cfargument name="userId"	required="yes" type="any" />
		<cfargument name="BillBackId"	required="no" type="any" default="0" /> --->
		<cfargument name="PayPeriodId"	required="no" type="any" default="0" />
		<cfargument name="summary"	required="no" type="any" default="0" />
		<cfset var qGetBBDetails = "" />
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetBBDetails">
				SELECT	U.Name_first AS First,
						U.Name_Last AS Last,
						isnull(B.BB_Code,'ReCalc') as BB_code,
						<cfif Summary EQ 1>
							isnull(sum(B.BB_Amount),'') as BB_Amount,
							SUM(isnull(BB_Approved.Pullback_Applied_Amount, 0)) as Pullback_Applied_Amount,
						<cfelse>
							B.BB_Title,
							B.Billback_Id,
							isnull(B.BB_Amount,'') as BB_Amount,
							isnull(BB_Approved.Pullback_Applied_Amount, 0) as Pullback_Applied_Amount,
						</cfif>
						PP.BB_Auto_Program_Pay_Period_Id,
						PP.Updated_Date,
						PP.Status as BBStatus,
						R.status as ReportStatus,
						C.Contract_Number,
						ISNULL(BFC.Name, VM.Vendor_Name) as Name,
						ISNULL(BFC.Ship_To, VM.Vendor_ID) as Ship_To
					FROM BB_Auto_Program_Pay_Period PP
					LEFT JOIN	BB_Auto_Pay_Period_Billback PBB ON
							PBB.BB_Auto_Program_Pay_Period_Id = PP.BB_Auto_Program_Pay_Period_Id
					LEFT JOIN BillBack B ON
							B.Billback_Id = PBB.Billback_Id
					LEFT JOIN BB_Approved ON
							B.Billback_Id = BB_Approved.Billback_Id
					LEFT JOIN Billback_Distributor BD
						ON BD.Billback_ID = B.Billback_ID
					LEFT JOIN BSA_Foodservice_Customers BFC
						ON BFC.BSA_Foodservice_Customers_ID = BD.Distributor_ID		
					LEFT JOIN Vendor_Master VM
						ON VM.Vendor_Master_ID = BD.Distributor_ID
					LEFT JOIN _users U ON
						U.User_id = PP.Updated_User_ID And
						PP.Updated_User_id IS NOT NULL
					LEFT JOIN	BB_Auto_Report R ON
						R.BB_Auto_Report_Id = PP.BB_Auto_Report_Id
					LEFT JOIN Contract_Main C ON
						C.Contract_Main_Id = PP.Program_Id
				 	WHERE PP.BB_Auto_Program_Pay_Period_id = '#arguments.PayPeriodId#'
				 	<cfif Summary EQ 1>
					 	GROUP BY
						 	U.Name_first,
							U.Name_Last,
							B.BB_Code,
							PP.BB_Auto_Program_Pay_Period_Id,
							PP.Updated_Date,
							PP.Status,
							R.status,
							C.Contract_Number,
							ISNULL(BFC.Name, VM.Vendor_Name),
							ISNULL(BFC.Ship_To, VM.Vendor_ID)
					</cfif>
					ORDER BY BB_Code DESC
			</CFQUERY>
		<cfreturn qGetBBDetails />
	</cffunction>

<!--- XXXXXXXXXXXX	getBBLink	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getBBLink" access="public" returntype="string">
		<cfargument name="PayPeriodId"	required="no" type="any" default="0" />
		<cfargument name="reportID"	required="yes"	type="numeric" /> <!--- Not Needed --->
		<!--- <cfargument name="userId"	required="yes" type="any" />
		<cfargument name="BillBackId"	required="no" type="any" default="0" /> --->
		
		<cfset var getBBLink = "" />
		<cfset var i = 0 />
		<cfset var qBBInfo = this.getBBDetail(arguments.PayPeriodId) />
		<cfsavecontent variable="getBBLink">
			<cfoutput query="qBBInfo">
				<cfif qBBInfo.BB_CODE NEQ '' AND qBBInfo.BB_CODE NEQ 'ReCalc'>
					<cfif i GT 0> <!--- line break if more than one --->
					 	<br>
					</cfif>
					<a href="##" onclick="browse('#JSSTRINGFORMAT(qBBInfo.billback_id)#')" title="#qBBInfo.BB_Title#">#qBBInfo.BB_CODE#</a>
<a  id="spanAction#arguments.reportID#"
						 title="View the line item details for this billback in the export file"
						href="/billbacks/auto_bb_report/index.cfm?Report=#arguments.reportID#&disp=ExpView&PP_ID=#arguments.PayPeriodId#&BB_ID=#qBBInfo.Billback_ID#&PageTitle=PAYABLES: Auto Pay Export Report #arguments.reportID#">
							<img src="/images/view.gif" align="middle" border="0" /></a>
				<cfelse><!--- Recalc Record --->
					&nbsp;
				</cfif>
				<cfset i = i + 1 />
			</cfoutput>
		</cfsavecontent>
		<cfreturn getBBLink />
	</cffunction>

<!--- XXXXXXXXXXXX	getBBIds	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getBBIds" access="public" returntype="query">
		<!--- <cfargument name="reportID"	required="yes"	type="numeric" /> <!--- Not Needed --->
		<cfargument name="userId"	required="yes" type="any" />
		<cfargument name="BillBackId"	required="no" type="any" default="0" /> --->
		<cfargument name="PayPeriodId"	required="no" type="any" default="0" />
		<cfset var qGetBBIds = "" />
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetBBIds">
				SELECT	PBB.Billback_Id
					FROM BB_Auto_Program_Pay_Period PP
					INNER JOIN	BB_Auto_Pay_Period_Billback PBB ON
							PBB.BB_Auto_Program_Pay_Period_Id = PP.BB_Auto_Program_Pay_Period_Id
					--INNER JOIN BillBack B ON
							--B.Billback_Id = PBB.Billback_Id
				 	WHERE PP.BB_Auto_Program_Pay_Period_id = '#arguments.PayPeriodId#'
			</CFQUERY>
		<cfreturn qGetBBIds />
	</cffunction>
	
<!--- XXXXXXXXXXXX	getBBIds	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getReportBBIds" access="public" returntype="query">
		<!--- <cfargument name="reportID"	required="yes"	type="numeric" /> <!--- Not Needed --->
		<cfargument name="userId"	required="yes" type="any" />
		<cfargument name="BillBackId"	required="no" type="any" default="0" /> --->
		<cfargument name="ReportId"	required="no" type="any" default="0" />
		<cfset var qGetBBIds = "" />
		<cfset var qGetReportBBIds = "" />
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetReportBBIds">
				SELECT	PBB.Billback_Id,B.BB_code
					FROM BB_Auto_Program_Pay_Period PP
					INNER JOIN	BB_Auto_Pay_Period_Billback PBB ON
							PBB.BB_Auto_Program_Pay_Period_Id = PP.BB_Auto_Program_Pay_Period_Id
					INNER JOIN BillBack B ON
							B.Billback_Id = PBB.Billback_Id
				 	WHERE PP.BB_Auto_report_id = '#arguments.ReportId#'
				 	ORDER BY B.BB_code DESC
			</CFQUERY>
		<cfreturn qGetReportBBIds />
	</cffunction>

<!--- XXXXXXXXXXXX	getExportBBDetail	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getExportBBDetails" access="public" returntype="query">
		<cfargument name="reportID"	required="yes"	type="numeric" />
		<cfargument name="BillBackId"	required="no" type="any" default="0" />
		<cfargument name="PayPeriod_ID"	required="no" type="any" default="0" />
		<cfset var qGetExportBBDetails = "" />
		<cfset var Billback_List = 0 />
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetExportBBDetails">
				SELECT
					BBH.*,
					BBD.*,
					ID.Operator_Id,
					UOM.Unit_Of_Measure_Desc
				FROM BB_Auto_Report_Export_Header H
				INNER JOIN BB_Auto_Report_Export_BB_Header BBH
					ON H.Export_Header_Id = BBH.Export_Header_Id
					<cfif arguments.BillBackID NEQ 0>
						AND BBH.BillBack_Id = '#arguments.BillBackID#'
					<cfelse>
						AND 1=0
					</cfif>
				<cfif arguments.PayPeriod_ID NEQ 0>
					INNER JOIN	BB_Auto_Pay_Period_Billback PBB ON
							PBB.BB_Auto_Program_Pay_Period_Id = '#arguments.PayPeriod_ID#' AND
							BBH.BillBack_Id = PBB.BillBack_Id
				</cfif>
				INNER JOIN BB_Auto_Report_Export_BB_Detail BBD
					ON H.Export_Header_Id = BBD.Export_Header_Id AND
						BBD.BB_Header_Id = BBH.BB_Header_Id
				INNER JOIN Invoice_Detail ID ON
						ID.Invoice_Detail_Id = BBD.Invoice_Detail_Id
				LEFT JOIN Units_of_Measure UOM ON
						UOM.Unit_Of_Measure_ID = BBD.Discount_UOM
				WHERE H.BB_Auto_Report_ID = '#arguments.reportID#'
				ORDER BY BB_code,Shr_Ship_To,Shared_Invoice_Number,BBD.Item
			</CFQUERY>
		<cfreturn qGetExportBBDetails />
	</cffunction>

<!--- XXXXXXXXXXXX	getExportBBLabels	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getExportBBLabels" access="public" returntype="query">
		<cfset var qGetExportBBLabels = "" />
		<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetExportBBLabels">
			SELECT *
			FROM BB_Auto_Report_Export_Labels
			WHERE Table_Code LIKE '%BB%'
				AND Active = 1
			ORDER BY Sequence
		</CFQUERY>
		<cfreturn qGetExportBBLabels />
	</cffunction>

<!--- XXXXXXXXXXXX	getExportPullDetail	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getExportPullDetails" access="public" returntype="query">
		<cfargument name="reportID"	required="yes"	type="numeric" />
		<cfargument name="BillBackId"	required="no" type="any" default="0" />
		<cfargument name="PayPeriod_ID"	required="no" type="any" default="0" />
		<cfargument name="Distributor_ID"	required="no" type="any" default="0" />
		<cfset var qGetExportPullDetails = "" />
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetExportPullDetails">
				SELECT
					PH.*,
					PD.*,
					UOM.Unit_Of_Measure_Desc
				FROM BB_Auto_Report_Export_Header H
				INNER JOIN BB_Auto_Report_Export_PullBack_Header PH
					ON PH.Export_Header_Id = H.Export_Header_Id
				INNER JOIN BB_Auto_Report_Export_PullBack_Detail PD
					ON PH.Export_Header_Id = PD.Export_Header_Id AND
					PH.PullBack_Header_Id = PD.PullBack_Header_Id
					<cfif arguments.BillBackID NEQ 0>
						AND PH.Dis_Corp_BillBack_Id = '#arguments.BillBackID#'
					</cfif>
					<cfif arguments.Distributor_ID NEQ 0>
						AND PH.Customer_ID =  '#arguments.Distributor_ID#'
					</cfif>
					<cfif arguments.PayPeriod_ID NEQ 0>
					INNER JOIN	BB_Auto_Pay_Period_Billback PBB ON
							PBB.BB_Auto_Program_Pay_Period_Id = '#arguments.PayPeriod_ID#' AND
							PH.Dis_Corp_BillBack_Id = PBB.BillBack_Id
					</cfif>
					
				LEFT JOIN Units_of_Measure UOM ON
						UOM.Unit_Of_Measure_ID = PD.PB_From_Program_UOM
				WHERE H.BB_Auto_Report_ID = '#arguments.reportID#'
				ORDER BY Dis_Corp_BB_Code,Shr_Ship_To,PullBack_BB_Code,Item
			</CFQUERY>
		<cfreturn qGetExportPullDetails/>
	</cffunction>
	
<!--- XXXXXXXXXXXX	getExportPullbackDistSum	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getExportPullbackDistSum" access="public" returntype="query">
		<cfargument name="reportID"	required="yes"	type="numeric" />
		<cfargument name="BillBackId"	required="no" type="any" default="0" />
		<cfargument name="PayPeriod_ID"	required="no" type="any" default="0" />
		<cfargument name="Distributor_ID"	required="no" type="any" default="0" />
		<cfset var qGetExportPullDetails = "" />
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetExportPullDistSum">
				SELECT SUM(Pullback_Amount) AS Sum_Pullback_Amount
				FROM BB_Auto_Report_Export_Header H
				INNER JOIN BB_Auto_Report_Export_PullBack_Header PH
					ON PH.Export_Header_Id = H.Export_Header_Id
				INNER JOIN BB_Auto_Report_Export_PullBack_Detail PD
					ON PH.Export_Header_Id = PD.Export_Header_Id AND
					PH.PullBack_Header_Id = PD.PullBack_Header_Id
					<cfif arguments.BillBackID NEQ 0>
						AND PH.Dis_Corp_BillBack_Id = '#arguments.BillBackID#'
					</cfif>
					<cfif arguments.Distributor_ID NEQ 0>
						<cfif arguments.Distributor_ID EQ "">
						AND PH.Customer_ID IS NULL
						<cfelse>
						AND PH.Customer_ID =  '#arguments.Distributor_ID#'
						</cfif>
					</cfif>
					<cfif arguments.PayPeriod_ID NEQ 0>
					INNER JOIN	BB_Auto_Pay_Period_Billback PBB ON
							PBB.BB_Auto_Program_Pay_Period_Id = '#arguments.PayPeriod_ID#' AND
							PH.Dis_Corp_BillBack_Id = PBB.BillBack_Id
					</cfif>
				WHERE H.BB_Auto_Report_ID = '#arguments.reportID#'				
			</CFQUERY>
		<cfreturn qGetExportPullDistSum />
	</cffunction>

<!--- XXXXXXXXXXXX	getExportPullLabels	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getExportPullLabels" access="public" returntype="query">
		<cfset var qGetExportPullLabels = "" />
		<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetExportPullLabels">
			SELECT *
			FROM BB_Auto_Report_Export_Labels
			WHERE Table_Code LIKE '%PB%'
				AND Active = 1
			ORDER BY Sequence
		</CFQUERY>
		<cfreturn qGetExportPullLabels />
	</cffunction>

<!--- XXXXXXXXXXXX	get report status: returns a description for display	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getReportStatus" access="public" returntype="string">
		<cfargument name="status" required="yes" type="numeric" />
		<cfargument name="pause" required="no" type="any" default="0" />
		<cfset var result = "">
		<cfswitch expression="#arguments.status#">
			<cfcase value="-1">
				<cfset result = "New" />
			</cfcase>
			<cfcase value="0,9">
				<cfset result = "Deleted" />
			</cfcase>
			<cfcase value="1">
				<cfset result = "Scheduled" />
			</cfcase>
			<cfcase value="2">
				<cfif arguments.pause EQ 1>
					<cfset result = "Re-calc on Hold" />
				<cfelse>
					<cfset result = "Set to Re-calc" />
				</cfif>
			</cfcase>
			<cfcase value="3">
				<cfset result = "RFA" />
			</cfcase>
			<cfcase value="4">
				<cfset result = "Approved" />
			</cfcase>
		</cfswitch>
		<cfreturn result />
  	</cffunction>

<!--- XXXXXXXXXXXX	Get available action	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getAction" access="public" returntype="string">
		<cfargument name="reportId"	required="no"	type="numeric" default="0" />
		<cfargument name="periodId"	required="yes" type="numeric" />
		<cfargument name="status"	required="no" type="any" default="0" />
		<cfargument name="currPeriod" required="no" type="numeric" default="#this.getCurrentPeriod()#" />
		<cfargument name="pause"	required="no" type="any" default="0" />
		<cfargument name="isManual"	required="no" type="numeric" default="-1" />
		
		<cfset var result = "" />
		<cfset var createLink = "" />
		<cfset var cancelLink = "" />
		<cfset var viewLink = "" />
		<cfset var approveLink = "" />
		<cfset var deleteLink = "" />
		<cfset var pauseLink = "" />
		<cfset var editLink = "" />
		<cfset var addProgLink = "" />
		<cfset var locked = "" />
		<cfset var reportProcessing = "" />
		<cfset var linkEnabled = "" />
		
		<cfset locked = this.getReportLockByMe(request.accessStructure.User_Id) />
		<cfset reportProcessing = this.getReportProcessingFlag() />
		
		<cfset linkEnabled = locked />
		<cfif reportProcessing>
			<cfset linkEnabled = 0 />						
		</cfif>

		<cfsavecontent variable="result">
			<cfoutput>
			<cfif arguments.Reportid GT 0>
				<cfswitch expression="#trim(arguments.status)#">
					<cfcase value="1"><!--- Scheduled Status--->
							<!--- cancel --->
						<cfset cancelLink = this.getActionLink(reportId	= arguments.reportId,
															periodId	= arguments.periodId,
															action		= 'delete') /> <!--- cancel --->
															
							<!--- edit --->
						<cfset editLink = this.getActionLink(reportId	= arguments.reportId,
															periodId	= arguments.periodId,
															action		= 'edit') />
						<table width="75" class="NoBorder">
							<tr>
								<td width="25%" class="NoBorder">&nbsp;</td>
								<td width="25%" class="NoBorder"><cfif application.oBBReportGet.getAutoPayType(arguments.isManual) EQ 2 AND this.getReportLockByMe(request.accessStructure.User_Id) EQ 1 AND linkEnabled ><a href="/billbacks/Auto_BB_Report/index.cfm?action=edit&disp=CreatePeriod&Report_ID=#arguments.reportId#" ><img src="/Images/edit.gif" title="edit this report" border="0"></a><cfelse>&nbsp;</cfif></td>
								<cfif application.oBBReportGet.getAutoPayType(arguments.isManual) EQ 2 AND linkEnabled><td width="25%" class="NoBorder"><a href="javascript:void(0)" onclick="this.disabled=disabled;lockLinks();disabledImageZone.style.visibility = 'visible';document.location = '/billbacks/auto_bb_report/index.cfm?del=0&runall=1&Report=#arguments.reportId#'; return false;"  ><img src="/Images/Green_Play.jpg" title="run this report only" border="0"></a></td></td></cfif>
								<!---<td width="25%" class="NoBorder">
									<a href="javascript:alert('RUN');" >
										<img src="/Images/Green_Play.jpg" title="run this report only" border="0"></a>
								</td></td>
								
								<td width="25%" class="NoBorder">
									<a href="javascript:alert('STOP');" >
										<img src="/Images/Green_Play.jpg" title="run this report only" border="0"></a>
								</td></td>--->
								
								
								<cfif application.oBBReportGet.getAutoPayType(arguments.isManual) EQ 2 AND linkEnabled><td width="25%" class="NoBorder"><a href="/billbacks/Auto_BB_Report/index.cfm?action=copy&disp=CreatePeriod&Report_ID=#arguments.reportId#" ><img src="/Images/copy.png" title="copy this report" border="0"></a></td></td></cfif>
								<td width="25%" class="NoBorder">#cancelLink#</td>
						  	</tr>
						</table>
					</cfcase>
					<cfcase value="2"><!--- Scheduled for Recalc(s) --->
						<!--- view --->
						<cfset viewLink = this.getActionLink(reportId	= arguments.reportId,
															periodId	= arguments.periodId,
															action		= 'view') />
						<cfset pauseLink = this.getActionLink(reportId	= arguments.reportId,
															periodId	= arguments.periodId,
															pause		= arguments.pause,
															action		= 'pause') />
						<table width="75" class="NoBorder">
							<tr>
								<td width="25%" class="NoBorder">&nbsp;</td>
								<td width="25%" class="NoBorder">#viewLink#</td>
								<cfif application.oBBReportGet.getAutoPayType(arguments.isManual) EQ 2 AND linkEnabled><td width="25%" class="NoBorder"><a href="/billbacks/auto_bb_report/index.cfm?del=0&runall=1&Report=#arguments.reportId#"  ><img src="/Images/Green_Play.jpg" title="run this report only" border="0"></a></td></td></cfif>
								<cfif application.oBBReportGet.getAutoPayType(arguments.isManual) EQ 2 AND linkEnabled><td width="25%" class="NoBorder"><a href="/billbacks/Auto_BB_Report/index.cfm?action=copy&disp=CreatePeriod&Report_ID=#arguments.reportId#" ><img src="/Images/copy.png" title="copy this report" border="0"></a></a></td></cfif>
								<td width="25%" class="NoBorder">#pauseLink#</td>
						  	</tr>
						</table>

					</cfcase>
					<cfcase value="3"> <!--- RFA Status--->
						<!--- approve --->
						<cfset approveLink = this.getActionLink(reportId	= arguments.reportId,
																periodId	= arguments.periodId,
																action		= 'approve') />
						<!--- view --->
						<cfset viewLink = this.getActionLink(reportId	= arguments.reportId,
															periodId	= arguments.periodId,
															action		= 'view') />
						<!--- delete --->
						<cfset deleteLink = this.getActionLink(reportId	= arguments.reportId,
															periodId	= arguments.periodId,
															action		= 'delete') />

						<table width="75" class="NoBorder">
							<tr>
								<td width="30" class="NoBorder">#approveLink#</td>
								<td width="25%" class="NoBorder">#viewLink#</td>
								<cfif application.oBBReportGet.getAutoPayType(arguments.isManual) EQ 2 AND linkEnabled><td width="25%" class="NoBorder">&nbsp;</td></td></cfif>
								<cfif application.oBBReportGet.getAutoPayType(arguments.isManual) EQ 2 AND linkEnabled><td width="25%" class="NoBorder"><a href="/billbacks/Auto_BB_Report/index.cfm?action=copy&disp=CreatePeriod&Report_ID=#arguments.reportId#" ><img src="/Images/copy.png" title="copy this report" border="0"></a></a></td></cfif>
								<td width="25%" class="NoBorder">#deleteLink#</td>
						  </tr>
						</table>
					</cfcase>
					<cfcase value="4"> <!--- Approved Status--->
							<!--- view --->
							<cfset viewLink = this.getActionLink(reportId	= arguments.reportId,
																periodId	= arguments.periodId,
																action		= 'view') />
							<!--- delete --->
							<!--- <cfset deleteLink = this.getActionLink(reportId	= arguments.reportId,
																periodId	= arguments.periodId,
																action		= 'delete') /> --->
						<table width="75" class="NoBorder">
							<tr>
								<td width="25%" class="NoBorder">&nbsp;</td>
								<td width="25%" class="NoBorder">#viewLink#</td>
								<cfif application.oBBReportGet.getAutoPayType(arguments.isManual) EQ 2 AND linkEnabled><td width="25%" class="NoBorder">&nbsp;</td></td></cfif>
								<cfif application.oBBReportGet.getAutoPayType(arguments.isManual) EQ 2 AND linkEnabled><td width="25%" class="NoBorder"><a href="/billbacks/Auto_BB_Report/index.cfm?action=copy&disp=CreatePeriod&Report_ID=#arguments.reportId#" ><img src="/Images/copy.png" title="copy this report" border="0"></a></a></td></cfif>
								<td width="25%" class="NoBorder">#deleteLink#</td>
						  	</tr>
						</table>
					</cfcase>
					<cfcase value="-1"><!--- New Status--->
							<!--- user will select programs --->
						<cfset cancelLink = this.getActionLink(reportId	= arguments.reportId,
															periodId	= arguments.periodId,
															action		= 'delete') /> <!--- cancel --->
						<cfset addProgLink = this.getActionLink(reportId	= arguments.reportId,
															periodId	= arguments.periodId,
															action		= 'addProg') /> <!--- addProgLink   "this.disabled=disabled;lockLinks();disabledImageZone.style.visibility = 'visible';document.location = ' --->

						<table width="75" class="NoBorder">
							<tr>
								<td width="25%" class="NoBorder">&nbsp;</td>
								<td width="25%" class="NoBorder">#addProgLink#</td>
								<cfif application.oBBReportGet.getAutoPayType(arguments.isManual) EQ 2 AND linkEnabled><td width="25%" class="NoBorder"><a href="javascript:void(0)" onclick="this.disabled=disabled;lockLinks();disabledImageZone.style.visibility = 'visible';document.location = '/billbacks/auto_bb_report/index.cfm?del=0&runall=1&Report=#arguments.reportId#'; return false;" ><img src="/Images/Green_Play.jpg" title="run this report only" border="0"></a></td></td></cfif>
				
								<cfif application.oBBReportGet.getAutoPayType(arguments.isManual) EQ 2 AND linkEnabled><td width="25%" class="NoBorder"><a href="javascript:void(0)" onclick="this.disabled=disabled;lockLinks();disabledImageZone.style.visibility = 'visible';document.location = '/billbacks/Auto_BB_Report/index.cfm?action=copy&disp=CreatePeriod&Report_ID=#arguments.reportId#'; return false;" ><img src="/Images/copy.png" title="copy this report" border="0"></a></a></td></cfif>
								<td width="25%" class="NoBorder">#cancelLink#</td>
								
						  	</tr>
						</table>
					</cfcase>
			 		<cfdefaultcase>
						NA
					</cfdefaultcase>
				</cfswitch>
			<cfelse>
				<!--- <cfif arguments.currPeriod EQ arguments.periodid> ---><!--- only check once for open claims --->
					<cfif This.getOpenClaims(arguments.periodid)><!--- there are open BB's --->
						<!--- create --->
						<cfset createLink = this.getActionLink(reportId	= arguments.reportId,
															periodId	= arguments.periodId,
															action		= 'create') />
						#createLink#
					<cfelse><!--- NO open claims for a report...don't give option --->
						There are currently no open claims.
					</cfif>
				<!--- </cfif> --->
			</cfif>
			</cfoutput>
	  	</cfsavecontent>

	  <cfreturn result>
  	</cffunction>

<!--- XXXXXXXXXXXX	Get Report Action Link	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getActionLink" access="public" returntype="string">
		<cfargument name="reportId"	required="no"	type="numeric" default="0" />
		<cfargument name="periodId"	required="yes"	type="numeric" />
		<cfargument name="action"	required="no" type="string" />
		<cfargument name="pause"	required="no" type="any" default="0" />
		
	  	<cfset var link = ""/>
	  	<cfset var reportProcessing = "" />
		<cfset var linkEnabled = "" />
		
		<!--- If locked by me, show action link --->
		<cfset var locked = this.getReportLockByMe(request.accessStructure.User_Id) />
		
		<cfset reportProcessing = this.getReportProcessingFlag() />
		
		<cfset linkEnabled = locked />
		<cfif reportProcessing>
			<cfset linkEnabled = 0 />						
		</cfif>
		
			<cfsavecontent variable="link">
				<cfoutput>
				
					<cfswitch expression="#arguments.action#">
						<cfcase value="create">
							<cfif linkEnabled>
								<a  href="##"
									name="createLink"
									onClick="this.disabled=1;createReportAction('#arguments.periodID#','#request.accessStructure.User_ID#')" title="Create Report">
										<span style="color:Navy" id="create"><IMG BORDER="0" SRC="#this.getNavIcon(linkEnabled)#" ALIGN="absmiddle"></span>
								</a>
								<a  href="##"
									name="createLink"
									onClick="this.disabled=1;createReportAction('#arguments.periodID#','#request.accessStructure.User_ID#')" title="Create Report">
										<span style="color:Navy" id="create">Create Report</span>
								</a>
							</cfif>
						</cfcase>
						<cfcase value="cancel">
							<cfif linkEnabled>
								<a  href="##" id="cancelReport#arguments.reportId#"
									name="cancelReport"  title="Cancel the scheduled report"
									onClick="this.disabled=1;cancelReportAction('#arguments.reportId#','#arguments.periodId#','#request.accessStructure.User_ID#');">
										<img src="/images/delete_new2.gif" align="middle" border="0" />
								</a>
							</cfif>
						</cfcase>
						<cfcase value="view">
							<a  id="viewReport#arguments.reportId#"
								title="View or Edit the report details"
								href="/billbacks/auto_bb_report/index.cfm?Disp=detail&report=#arguments.Reportid#&PageTitle=PAYABLES: Auto Pay Report Detail" >
									<img src="/images/view.gif" align="middle" border="0" />
							</a>
						</cfcase>
						<cfcase value="approve">
							<cfif This.getReportBB(arguments.reportId)> <!--- If the report has any BB's, Approve --->
								<cfif linkEnabled>
									<a  href="##" id="approveReport#arguments.reportId#"
											name="approveReport" title="Approve all Billbacks in this report"
											onClick="if (confirm('Would you like to approve all Billbacks in Report?')){
												this.disabled=1;approveReportAction('#arguments.reportId#','#arguments.periodId#','#request.accessStructure.User_ID#');
												}">
										<img src="/images/checkmark.gif" align="middle" border="0" />
									</a>
								</cfif>
							<cfelse>
								<span title="There are no Billbacks in this report">0</span>
							</cfif>
						</cfcase>
						<cfcase value="delete">
							<cfif linkEnabled>
								<a  href="##" id="deleteReport#arguments.reportId#"
										name="deleteReport"
										onClick="if (confirm('Would you like to delete the entry?')){
											this.disabled=1;deleteReportAction('#arguments.reportId#','#arguments.periodId#','#request.accessStructure.User_ID#');
											}"
										title="Delete Report and Billbacks in this report">
											<img src="/images/delete_new2.gif" align="middle" border="0" />
								</a>
							</cfif>
						</cfcase>
						<cfcase value="pause">
							<cfif linkEnabled>
								<cfif arguments.pause EQ 0><!--- if it is scheduled, send the pause link --->
									<a  href="##" id="pauseReport#arguments.reportId#"
											name="pauseReport"
											onClick="this.disabled=1;pauseReportAction('#arguments.reportId#','#arguments.periodId#','#request.accessStructure.User_ID#','1');"
											title="Put this scheduled recalc on hold">
												<img src="/images/deviations/stop.gif" align="middle" border="0" />
									</a>
								<cfelse> <!--- else it is on hold, send the resumelink --->
									<a  href="##" id="resumeReport#arguments.reportId#"
											name="resumeReport"
											onClick="this.disabled=1;pauseReportAction('#arguments.reportId#','#arguments.periodId#','#request.accessStructure.User_ID#','0');"
											title="Resume the scheduled recalc">
												<img src="/images/active.gif" align="middle" border="0" />
									</a>
								</cfif>
							</cfif>
						</cfcase>
						<cfcase value="createPeriod">
						
							<a  id="createPeriod#arguments.reportId#"
								title="View or Edit the report details"
								href="/billbacks/auto_bb_report/index.cfm?Disp=createPeriod&report=#arguments.Reportid#&PageTitle=PAYABLES:Create Auto Pay Report Period">
									<img src="/images/view.gif" align="middle" border="0" />
							</a>
						</cfcase>
						<cfcase value="addProg">
						
							<cfif linkEnabled>
								<a  href="##" id="addProg#arguments.reportId#"
									name="addPrograms"  title="Add programs to the report"
									onClick="this.disabled=1;SearchPrograms('',#arguments.reportId#);return false;">
										<!--- <img src="/images/delete_new2.gif" align="middle" border="0" /> ---> Add Program(s)
								</a>
							</cfif>
						</cfcase>
					
					</cfswitch>
				</cfoutput>
			</cfsavecontent>
	  	<cfreturn link />
  	</cffunction>

<!--- XXXXXXXXXXXX	Get BB Detail Links	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
 	<cffunction name="getBBDetailAction" access="public" returntype="string">
		<cfargument name="reportId"	required="yes"	type="numeric" default="" />
		<cfargument name="UserId"	required="yes"	type="any" default="0" />
		<cfargument name="BBId"		required="yes"	type="any" default="0" />
		<cfargument name="PayPeriodId" required="yes"	type="any" default="0" />
		<cfargument name="reportStatus"	required="no" type="numeric" default="0" />
		<cfargument name="Contract_Main_ID"		required="no"	type="any" default="0" /> 
		<!---D35392: GM Pullback Log entries START --->
		<cfargument name="PullbacksOn"	required="no" type="numeric" default="0" />
		<cfargument name="BBApplyPullback"	required="no" type="numeric" default="0" />
		<cfargument name="Autopay_Reverse"	required="no" type="numeric" default="0" />
				
		<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()> 
		<!---D35392: GM Pullback Log entries END---> 
		
		<cfset var result = ""/>
		<!--- If locked by me, show action link --->
		<cfset var locked = this.getReportLockByMe(request.accessStructure.User_Id) />
		<cfif trim(arguments.BBId) EQ ""><cfset arguments.BBId = 0 /></cfif>
		<!--- <cfif reportStatus LT 4 >  ---><!--- if the report is approved, we can not delete or recalc --->
			<cfsavecontent variable="result">
				<cfoutput>
				<cfswitch expression="#trim(arguments.BBId)#">
					<cfcase value="0">
						No BB Data
					</cfcase>
					<cfdefaultcase>
						<cfif locked and reportStatus LT 4>
							<a  href="##" id="ReCalcBB"
								name="ReCalcBB" title="Re-Calculate this Pay Period"
								onClick="this.disabled=1;recalcBBAction('#arguments.reportId#','#request.accessStructure.User_ID#','#arguments.BBId#','#arguments.PayPeriodId#');">
									<img src="/images/recycle1.gif" align="middle" border="0" /></a>&nbsp;
						</cfif>
						
						<!--- View moved to billback line --->
						
						<cfif locked and reportStatus LT 4>
							<a  href="##" id="RemoveBB"
								name="RemoveBB" title="Remove from report and delete BB"
								onClick="if (confirm('Would you like to delete the entry?')){
										this.disabled=1;removeBBAction('#arguments.reportId#','#request.accessStructure.User_ID#','#arguments.BBId#','#arguments.PayPeriodId#');
										}">
									<img src="/images/delete_new2.gif" align="middle" border="0" /></a>
						</cfif>
						
						<!--- Download a pdf --->
						
						<a  href="##" id="CreatePDF"
								name="CreatePDF" title="Create a PDF backup for this report"
								onClick="this.disabled=1; return CreatePDF('#arguments.reportId#','#arguments.Contract_Main_ID#');">
						<img src="/images/PDF_Icon.gif" align="middle" border="0" height="15" width="12"/></a>
						
						<!---D35392: GM Pullback Log entries START --->
						<cfif locked and reportStatus LT 4>	
								<cfif (arguments.PullbacksOn) AND (arguments.BBApplyPullback)>
									&nbsp;<a  href="##" id="ApplyPullback" name="ApplyPullback" title="Apply #appsettings.getPullbackLabel()# for this BB" onclick="pullbacks('#arguments.BBId#',0);return false;"><img src="/images/statusImage1.gif" align="middle" border="0" /></a>
									&nbsp;<a  href="##" id="UnApplyPullback"name="UnApplyPullback" title="Un-apply #appsettings.getPullbackLabel()# for this BB" onclick="pullbacks('#arguments.BBId#',1);return false;"><img src="/images/statusImage2.gif" align="middle" border="0" /></a>
								<!---D39144 :: Autopay Recapture START 
									&nbsp;<a  href="##" id="ApplyPullback" name="ApplyPullback" title="Apply #appsettings.getPullbackLabel()# for this BB" onclick="submitapplypullbackform('#arguments.BBId#');return false;"><img src="/images/statusImage1.gif" align="middle" border="0" /></a>
									&nbsp;<a  href="##" id="UnApplyPullback"name="UnApplyPullback" title="Un-apply #appsettings.getPullbackLabel()# for this BB" onclick="submitunapplypullbackform('#arguments.BBId#');return false;"><img src="/images/statusImage2.gif" align="middle" border="0" /></a>
								D39144 :: Autopay Recapture END --->
								</cfif>
						</cfif>
						<!---D35392: GM Pullback Log entries END --->
						
						<!--- Reverse --->
						<cfif locked and reportStatus EQ 4 and appSettings.getBBAutoReportAllowReverse() and arguments.Autopay_Reverse>
							<!--- Only if all billbacks are in correct status that can allow reverse --->
							<cfif this.getCanReverse(arguments.PayPeriodId)>
							<a  href="##" id="RevserseBB"
								name="RemoveBB" title="Reverse/Delete billbacks"
								onClick="if (confirm('Would you like to reverse/delete the billbacks?')){
										this.disabled=1;reverseBBAction('#arguments.reportId#','#request.accessStructure.User_ID#','#arguments.BBId#','#arguments.PayPeriodId#');
										}">
									<img src="/images/reverse.png" align="middle" border="0" /></a>
							</cfif>
						</cfif>
						
					</cfdefaultcase>
				</cfswitch>
				</cfoutput>
			</cfsavecontent>
		<!--- </cfif> --->
		<cfreturn result />
  	</cffunction>

<!--- XXXXXXXXXXXX	DATETimeFORMAT	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="formatDateTime" access="public" returntype="string">
		<cfargument name="theDate" required="yes" type="date" />
		<cfset var result = dateformat(arguments.theDate,"mm/dd/yy")&" "&TimeFormat(arguments.theDate,"hh:mm:ss") />
		<cfreturn result />
  	</cffunction>

<!--- XXXXXXXXXXXX	getDiscountName	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getDiscountName" access="public" returntype="string">
		<cfargument name="discountTypeId" default="0" type="numeric">
	 	<cfset var result = "">
			<cfswitch expression="#arguments.discountTypeId#">
				<cfcase value="1">
					<cfset result = "Fixed" />
				</cfcase>
				<cfcase value="2">
					<cfset result = "Rebate" />
				</cfcase>
				<cfcase value="3">
					<cfset result = "Lump Sum" />
				</cfcase>
				<cfcase value="4">
					<cfset result = "Growth" />
				</cfcase>
				<cfcase value="5">
					<cfset result = "Formula" />
				</cfcase>
			</cfswitch>
	 	<cfreturn result />
  	</cffunction>

<!--- XXXXXXXXXXXX	DATEFORMAT	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="formatDate" access="public" returntype="string">
		<cfargument name="theDate" required="yes" type="date" />
		<cfset var result = dateformat(arguments.theDate,"mm/dd/yy") />
		<cfreturn result />
  	</cffunction>

 <!--- XXXXXXXXXXXX	Program Detail Link Icon	XXXXXXXXXXXX --->
	 <cffunction name="getProgramLink" access="public" returntype="string">
		<cfargument name="prgNumber" default="0" type="Any">
		<cfargument name="Contract_Main_ID" default="Report Home" type="string">
		  <cfset var CID = 0 />
		  <cfset var result = "" />
		  <cfif isNumeric(arguments.Contract_Main_ID) and  arguments.Contract_Main_ID NEQ 0>
			  <CF_CRYP type="en" string="#arguments.Contract_Main_ID#" key="#request.key#">
			  <cfset CID = cryp.value />
			  <cfsavecontent variable="result">
					<cfoutput>
						<A onclick="javaScript: NewWindow(this.href , 'Program_View' , 815 , 650 , 'yes' , 'yes'); return false;" target="thisProg" HREF="/scorecard/program_display.cfm?display_program=1&CID=#CID#" TITLE="View the details for program #arguments.prgNumber#">#arguments.prgNumber#</A>
					</cfoutput>
			  </cfsavecontent>
		  </cfif>
		  <cfreturn result>
	 </cffunction>

<!--- START START
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		LEFT HAND NAV		LEFT HAND NAV		LEFT HAND NAV		LEFT HAND NAV		LEFT HAND NAV
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
--->

<!--- XXXXXXXXXXXX	Left hand Nav Icon	XXXXXXXXXXXX --->
	<cffunction name="getNavIcon" access="public" returntype="string">
		<cfargument name="locked" default="0" type="numeric">
		  <cfset var result = "" />
		  <!---  Images used for Nav icons --->
		<CFIF arguments.locked>
			<CFSET result = "/images/programs/ball_green.gif" />
		<CFELSE>
			<CFSET result = "/images/programs/ball_gray.gif" />
		</CFIF>
		 <cfreturn result>
	</cffunction>

<!--- XXXXXXXXXXXX	Left hand REPORT HOME, RUN REPORTS, AND VIEW Icons	XXXXXXXXXXXX
	This is used for Links: Report Home, Run reports, and View deleted--->
	<cffunction name="getLeftMainIcon" access="public" returntype="string">
		<cfargument name="locked"	default="0"	type="numeric" />
		<cfargument name="text"		default="BB Report"	type="string" />
		<cfargument name="Desc"		default="BB Report"	type="string" />
		<cfargument name="Del"		default="0"	type="numeric" />
		<cfargument name="runall"	default=""	type="string" />
		<cfargument name="Disp"		default=""	type="string"	required="false" />
		<cfargument name="Export"	default="0"	type="numeric"	required="false">
		<cfargument name="reportID"	default="0" type="numeric" required="false" />
		<cfargument name="showRegardlessofLock"	default="0" type="numeric" required="false" />
		 
		 <!--- All "var" scoped variables must be defined in the top of the procedure --->
		 <cfset var result = "">
		 <cfset var LinkText="##">
		 <cfset var OnClickFunction = "this.disabled=disabled;lockLinks();disabledImageZone.style.visibility = 'visible';document.location = '/billbacks/auto_bb_report/index.cfm?del=#arguments.del#&runall=#arguments.runall#&Disp=#arguments.Disp#&Report=#arguments.ReportID#'; return false;">
		<cfif arguments.Export EQ 0>
			<cfset LinkText =  "javascript:void(0)">
		</cfif>
		 <!--- Add conditional argument to link text --->
		<!--- <cfif arguments.disp NEQ "">
		 	<cfset LinkText = LinkText & "&disp=#arguments.disp#">
		 </cfif>
		 
		  <cfif arguments.ReportID NEQ "">
		 	<cfset LinkText = LinkText & "&Report=#arguments.ReportID#">
		 </cfif>--->
		
		 <!--- Change the link text and onClick if exporting page --->
		<cfif arguments.Export EQ 1>
			<!--- Add export link text --->
			<cfset LinkText = LinkText & "&Export=1">
			
			<!--- Different exports for different views --->
			<cfif arguments.Disp EQ "view"><!--- Download report of reports --->
				<cfset LinkText="####">
				<cfset OnClickFunction ="NewWindow('/billbacks/Auto_BB_Report/BB_Auto_Report_Export_Universal.cfm?Disp=#arguments.Disp#&Del=#arguments.Del#','ExportView','600','400','Yes', 'Yes'); return false;">
			
			<cfelseif arguments.Disp EQ "detail"><!--- Download main reports - header and detail --->
				<cfset LinkText="####">
				<cfset OnClickFunction ="NewWindow('/billbacks/Auto_BB_Report/BB_Auto_Report_Export_Universal.cfm?ReportID=#arguments.reportID#&Del=#arguments.Del#&Disp=#arguments.Disp#', 'downloadAutoReports', 600, 400, 'yes', 'yes'); return false;">
			
			<cfelseif arguments.Disp EQ "ExpView"><!--- Download old detail report --->
			<cfset LinkText="####">
			<cfset OnClickFunction ="NewWindow('/billbacks/Auto_BB_Report/downloadreports.cfm?BB_Auto_Report_id=#arguments.reportID#&Del=#arguments.Del#&Disp=#arguments.Disp#', 'downloadAutoReports', 600, 400, 'yes', 'yes'); return false;">
			<!--- arguments.Disp EQ --->
			</cfif>
		<!--- arguments.Export EQ 1 --->
		</cfif>

		<cfif arguments.Export EQ 2>
			<!--- Add export link text --->
			<cfset LinkText = LinkText & "&Export=2">
			
			<!--- Different exports for different views --->
			<cfif arguments.Disp EQ "detail"><!--- Download main reports - header and detail --->
				<cfset LinkText="####">
				<cfset OnClickFunction ="NewWindow('/billbacks/Auto_BB_Report/BB_Auto_Report_Export_Pullback_Universal.cfm?ReportID=#arguments.reportID#&Del=#arguments.Del#&Disp=#arguments.Disp#', 'downloadAutoPullbackReports', 600, 400, 'yes', 'yes'); return false;">
			</cfif>
		</cfif>
		
		<cfif arguments.Export EQ 3>
			<!--- Add export link text --->
			<cfset LinkText = LinkText & "&Export=3">
			
			<!--- Different exports for different views --->
			<cfif arguments.Disp EQ "detail"><!--- Download main reports - header and detail --->
				<cfset LinkText="####">
				<cfset OnClickFunction ="NewWindow('/billbacks/Auto_BB_Report/Unipro_450_Report.cfm?ReportID=#arguments.reportID#&Del=#arguments.Del#&Disp=#arguments.Disp#', 'downloadAutoUniprReports', 600, 400, 'yes', 'yes'); return false;">
			</cfif>
		</cfif>
		
		<cfif arguments.Export EQ 4>
			<!--- Link --->
			<cfset LinkText = LinkText & "&Export=4">
			<cfset OnClickFunction ="NewWindow('BB_Auto_Report_Growth_Calc_Details.cfm?ReportID=#arguments.reportID#', 'GrowthDetails', 870, 700, 'yes', 'yes'); return false;">
		</cfif>
		 		 
		  <cfsavecontent variable="result">
			  <cfif arguments.locked OR runall EQ 0 OR showRegardlessofLock EQ 1>
				<cfoutput>
					<a href="#LinkText#" title="#arguments.Desc#" onclick="#OnClickFunction#" > <!------>
						<IMG BORDER="0" SRC="#this.getNavIcon(1)#" ALIGN="absmiddle">
					</a>
					<a href="#LinkText#" title="#arguments.Desc#" onclick="#OnClickFunction#" >  <!------>
						<span style="color:Navy">#arguments.text#</span>
					</a>
				</cfoutput>
			<cfelse>
				<cfoutput>
					<IMG BORDER="0" SRC="#this.getNavIcon(arguments.locked)#" ALIGN="absmiddle">
					<A CLASS="Grayed">#arguments.text#</A>
				</cfoutput>
			</cfif>
		  </cfsavecontent>
		  <cfreturn result>
	 </cffunction>

 <!--- XXXXXXXXXXXX	Left hand CREATE REPORT Nav Icon	XXXXXXXXXXXX --->
	<cffunction name="getCreateReportIcon" access="public" returntype="string">
		<cfargument name="locked" default="0" type="numeric">
		  <cfset var result = "" />
		  <cfset var qGetOpenPeriod = "" />
		  <cfsavecontent variable="result">
			<cfset qGetOpenPeriod = this.GetOpenPeriod() />
			<cfif arguments.locked and qGetOpenPeriod.recordcount GT 0>				
				<cfoutput>#this.getAction(		reportID 	= qGetOpenPeriod.BB_Auto_Report_id,
												periodId	= qGetOpenPeriod.bb_auto_report_period_id,
												status		= qGetOpenPeriod.status,
												endDate		= qGetOpenPeriod.end_date,
												currPeriod	= this.getCurrentPeriod(),
												pause		= qGetOpenPeriod.Pause_Schedule)#</cfoutput>
			<cfelse>
				<cfoutput><IMG BORDER="0" SRC="#this.getNavIcon(0)#" ALIGN="absmiddle"></cfoutput>
				<A CLASS="Grayed">Create Report</A>
			</cfif>
			</cfsavecontent>

		  <cfreturn result>
	</cffunction>

<!--- XXXXXXXXXXXX	Left hand DETAIL REFRESH Icon	XXXXXXXXXXXX --->
	<cffunction name="getDetailRefreshLink" access="public" returntype="string">
		<cfargument name="locked" default="0" type="numeric">
		<cfargument name="Report" default="0" type="numeric">
		<cfargument name="text" default="Report Detail" type="string">
		  <cfset var result = "">
		  <cfsavecontent variable="result">
				<cfoutput>
					<a href="/billbacks/auto_bb_report/index.cfm?Report=#arguments.Report#&disp=detail" title="Refresh Detail View">
						<IMG BORDER="0" SRC="#this.getNavIcon(1)#" ALIGN="absmiddle"> <!--- arguments.locked --->
					</a>
					<a href="/billbacks/auto_bb_report/index.cfm?Report=#arguments.Report#&disp=detail" title="Refresh Detail View">
						<span style="color:Navy">#arguments.text#</span>
					</a>
				</cfoutput>
		  </cfsavecontent>
		  <cfreturn result>
	</cffunction>

<!--- XXXXXXXXXXXX	Left hand DETAIL EXPORT Icon	XXXXXXXXXXXX --->
	<cffunction name="getDetailExportLink" access="public" returntype="string">
		<cfargument name="locked" default="0" type="numeric">
		<cfargument name="Report" default="0" type="numeric">
		<cfargument name="BillBackId" default="0" type="any" />
		<cfargument name="PP_Id" default="0" type="numeric" />
		<cfargument name="LinkType" default="0" type="numeric" />
		  <cfset var result = "">
		  <cfsavecontent variable="result">
			<!--- <cfif arguments.locked> --->
				<cfoutput>
					<cfif LinkType EQ 0> <!--- default --->
						<a href="/billbacks/auto_bb_report/index.cfm?Report=#arguments.Report#&disp=ExpView&PageTitle=PAYABLES: Auto Pay Report Export Report #arguments.Report#" title="View the line item details in the Export file">
							<IMG BORDER="0" SRC="#this.getNavIcon(1)#" ALIGN="absmiddle">
						</a>
						<a href="/billbacks/auto_bb_report/index.cfm?Report=#arguments.Report#&BB_ID=#arguments.billbackid#&PP_ID=#arguments.PP_ID#&disp=ExpView&PageTitle=PAYABLES: Auto Pay Report Export Report #arguments.Report#" title="View the line item details in the Export file">
							<span style="color:Navy">Export Report</span>
						</a>
					<cfelse><!--- BBlink --->
						<a href="/billbacks/auto_bb_report/index.cfm?Report=#arguments.Report#&BB_ID=#arguments.billbackid#&PP_ID=#arguments.PP_ID#&disp=ExpView&PageTitle=PAYABLES: Auto Pay Report Export Report #arguments.Report#" title="View the line item details in the Export file">
						<span style="color:Navy">#this.getBBInfo(arguments.billbackid).bb_code#</span>
					</a>
					</cfif>
				</cfoutput>
			<!--- <cfelse>
					<cfoutput>
					<IMG BORDER="0" SRC="#this.getNavIcon(arguments.locked)#" ALIGN="absmiddle">
					</cfoutput>
					<A CLASS="Grayed">Export Report</A>
			</cfif> --->
		  </cfsavecontent>
		  <cfreturn result>
	 </cffunction>

<!--- XXXXXXXXXXXX	Get Applied Auto PAy LITE Pullbacks (Ineligible Volume for a specific Billback	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction access="public" name="GetAutoPayLitePBApplied" returntype="Query">
		<cfargument name="Billback_Id" type="any" required="true">
		<cfset var qGetAutoPayLitePB = "" />
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetAutoPayLitePB">
				SELECT	L.BillBack_Id,
						B.BB_Code,
						B.BB_Title,
						SUM(Net_Dollars) AS Applied_Dollars
				FROM BB_Auto_Report_PB_Log L
				JOIN BillBack B ON
					B.BillBack_Id = L.Billback_Id
				WHERE Applied_To_Billback_Id = '#arguments.Billback_Id#' AND
					L.Applied = 1 AND
					L.Deleted = 0
				GROUP BY 	L.BillBack_Id, 
							B.BB_Code,
							B.BB_Title
			</CFQUERY>
	 	<cfreturn qGetAutoPayLitePB />
	</cffunction>
	 
	 <cffunction name="getDeviationReportLink" access="public" returntype="string">
		 <cfargument name="BillBackId" default="0" type="any" />
	  <cfset var result = "">
	  <cfset var qgetDeviations = "">
		<CFQUERY NAME="qgetDeviations" DATASOURCE="#application.datasource#">
			SELECT BA.Adjustment_Deducted_From_BB_ID,
					B.BB_Code
			FROM BB_Adjustment BA
			INNER JOIN Billback B ON
				B.Billback_ID = '#arguments.billbackId#'
			WHERE BA.Adjustment_Deducted_From_BB_ID = '#arguments.billbackId#'
		</CFQUERY>
		
		<CFIF qgetDeviations.recordcount GT 0>
			<cfoutput>
				<cfsavecontent variable="result">
					<a href="##" onclick="vDeviations('#JSSTRINGFORMAT(URL.BB_ID)#')" title="">View #qgetDeviations.BB_Code# Deviations</a>
				</cfsavecontent>
			</cfoutput>
		</CFIF>
	  <cfreturn result />
  	</cffunction>
	
<!----This function takes the viewable page, locates the query that drives the display and returns the query as a downloadable CSV --->
	<cffunction name="getExportFile" access="public" returntype="string" output="true">
		<cfargument name="Disp" type="string" required="true">
		<cfargument name="Deleted" type="numeric" default="0">
		<cfargument name="Report" type="numeric" default="0">
		<!--- List all vars here --->
		<cfset var QueryResults = "">
		<cfset var QueryResultDetail = "">
		<cfset var ResultContent = "">
		<cfset var ResultContentDetail = "">
		<cfset var DownloadFilePath = "">
		<cfset var DownloadFilePathDetail = "">
		<cfset var Billbackfilepath = "">
		<cfset var BillbackfilepathDetail = "">
		<cfset var DownloadLinks = "">
		<cfset var CurrentTimeandUser = "">
		<cfset var ModifiedUID = "">
		<cfset var action = "">
		
		<!--- Set file path location --->
		<cfset ModifiedUID = replace(session.user_id, "-", "", "all")>
		<cfset CurrentTimeandUser = timeformat(now(), 'mmddyyyyhhmmss_') & ModifiedUID>

		
		<!--- Get the query ---->
		<cfswitch expression="#arguments.Disp#">
			<cfcase value="view">
			<!---- VIEW ---->
			
				<cfset QueryResults = getPeriods(Del	= arguments.Deleted)>				
			
				<cfsavecontent variable="ResultContent">Auto Pay Report ID|Title|Start Date|End Date|Status|Updated By|Updated On|Number of Programs|Number of Billbacks|Billback $ Amount
<cfoutput query="QueryResults">#BB_Auto_Report_ID#|#Report_Title#|#dateformat(Start_Date, 'mm/dd/yyyy')#|#dateformat(End_Date, 'mm/dd/yyyy')#|#Status_Desc#|#User_Code#|#dateformat(Updated_Date, 'mm/dd/yyyy')#|#Program_Count#|#Billback_Count#|#BB_Amount##chr(10)#</cfoutput>
Data provided by Blacksmith Applications</cfsavecontent>
			
				<cfset Billbackfilepath = application.Doc_Path & "\Temp_Files\Billback\AutoPayReport\" & Disp & "_" & CurrentTimeandUser & ".txt">
				<cfset DownloadFilePath = application.HTTPVar & cgi.SERVER_NAME & "/common_documents/Temp_Files/Billback/AutoPayReport/" & Disp & "_" & CurrentTimeandUser & ".txt">
		
				<!--- Write file location --->
				<CFFILE action = "write"
				file="#Billbackfilepath#"
				output="#ResultContent#">
				
				<!--- show links --->
				<cfsavecontent variable="DownloadLinks">
				<div align="center">Your report is ready to download.</div>
					<p></p>
					<div align="center">
					<CF_smallLink
					title = "click here to download"
					url = "##"
					parameters = "onClick=""javascript: downloadDoc('#DownloadFilePath#');"""
					> 
					</div>
				</cfsavecontent>
			
			<!---- END VIEW ---->
			</cfcase>
			<cfcase value="detail">
			
			<!--- DETAILS --->
			
			<!--- Move display to calling page --->			
			
			<!--- 	<!--- Queries --->
				<cfset QueryResults = getAutoPayExtractHeader(Report_ID = arguments.Report)>
				<cfset QueryResultDetail = getAutoPayExtractDetail(Report_ID = arguments.Report)>
				
				<!--- Header document content --->
				<cfsavecontent variable="ResultContent">Report ID|Report Title|Report Start Date|Report End Date|Program Title|Program Number|Billback Title|Billback Code|Distributor Number|Distributor Name|Distributor Family Name|Distributor Family Number|Distributor Buying Group Name|Distributor Buying Group Number|Total Cases|Total Pounds|Total Dollars#chr(10)#
<cfoutput query="QueryResults">#BB_Auto_Report_ID#|#Report_Title#|#dateformat(Start_Date, 'mm/dd/yyyy')#|#dateformat(End_Date, 'mm/dd/yyyy')#|#Contract_Title#|#Contract_Number#|#BB_Title#|#BB_Code#|#Shr_Ship_To#|#Shr_Ship_To_Name#|#Family_Name#|#Family#|#Buying_Group_Name#|#Buying_Group#|#Total_Cases#|#Total_Pounds#|#lscurrencyformat(Total_Earned)##chr(10)#</cfoutput>
Data provided by Blacksmith Applications</cfsavecontent>
				<!--- Details document content --->
				
				<cfsavecontent variable="ResultContentDetail">Report ID|Report Title|Start Date|End Date|Distributor Number|Distributor Name|Distributor Family Name|Distributor Family Number|Distributor Buying Group Name|Distributor Buying Group Number|Item|UPC|Description|Brand|Invoice Date|Purchase Order|Invoice Number|Cases Invoiced|Pounds Invoiced|Invoice Dollars|Price|Price UOM|Discount Offered|Discount UOM|$ Amount Earned#chr(10)#
		
<cfoutput query="QueryResultDetail">#BB_Auto_Report_ID#|#Report_Title#|#dateformat(Start_Date, 'mm/dd/yyyy')#|#dateformat(End_Date, 'mm/dd/yyyy')#|#Shr_Ship_To#|#Shr_Ship_To_Name#|#Family_Name#|#Family#|#Buying_Group_Name#|#Buying_Group#|#Item#|#UPC#|#Description#|#Brand_Name#|#dateformat(Invoice_Date, 'mm/dd/yyyy')#|#Purchase_Order#|#Shared_Invoice_Number#|#Cases_Invoiced#|#Pounds_Invoiced#|#lscurrencyformat(Sales_Dollars)#|#lscurrencyformat(Unit_Price)#|#Price_Unit_of_Measure#|#lscurrencyformat(Discount_Offered)#|#Discount_UOM#|#lscurrencyformat(Amount_Earned)##chr(10)#</cfoutput>
Data provided by Blacksmith Applications</cfsavecontent>


				<!--- Write header file --->
				
				<cfset Billbackfilepath = application.Doc_Path & "\Temp_Files\Billback\AutoPayReport\header_" & Disp & "_" & CurrentTimeandUser & ".txt">
				<cfset DownloadFilePath = "http://" & cgi.SERVER_NAME & "/common_documents/Temp_Files/Billback/AutoPayReport/header_" & Disp & "_" & CurrentTimeandUser & ".txt">
		
				<!--- Write file location --->
				<CFFILE action = "write"
				file="#Billbackfilepath#"
				output="#ResultContent#">
				
				<!--- Write detail file --->
				<cfset Billbackfilepathdetail = application.Doc_Path & "\Temp_Files\Billback\AutoPayReport\detail_" & Disp & "_" & CurrentTimeandUser & ".txt">
				<cfset DownloadFilePathdetail = "http://" & cgi.SERVER_NAME & "/common_documents/Temp_Files/Billback/AutoPayReport/detail_" & Disp & "_" & CurrentTimeandUser & ".txt">
		
				<!--- Write file location --->
				<CFFILE action = "write"
				file="#Billbackfilepathdetail#"
				output="#ResultContentDetail#">
				
				<!--- show links --->
				<cfsavecontent variable="DownloadLinks">
				<div align="center">Your report is ready to download.</div>
					<p></p>
					<div align="center">
					<CF_smallLink
					title = "download the report header"
					url = "##"
					parameters = "onClick=""javascript: downloadDoc('#DownloadFilePath#');"""
					> 
					</div>
					<p></p>
					<div align="center">
					<CF_smallLink
					title = "download the report details"
					url = "##"
					parameters = "onClick=""javascript: downloadDoc('#DownloadFilePathdetail#');"""
					> 
					</div>
				</cfsavecontent> --->

			<!--- END DETAILS --->
			</cfcase>
		</cfswitch>
				
		 <cfreturn DownloadLinks/>
	</cffunction>
	
	<cffunction name="getAutoPayExtractHeader"  access="public" returntype="query" output="true">
		<cfargument name="Report_ID" type="numeric" required="true">
		<cfargument name="Contract_Main_ID" type="numeric" required="true">
		
		<cfset var GetExtractHeader = "">
		
		<cfquery name="GetExtractHeader" datasource="#application.datasource#">
		SELECT DISTINCT
		BB_Auto_Report.Report_Title,
		BB_Auto_Report.BB_Auto_Report_ID,
		BB_Auto_Report_Period.Start_Date,
		BB_Auto_Report_Period.End_Date,
		Contract_Main.Contract_Title,
		Contract_Main.Contract_Number,
		Contract_Main.Contract_Main_ID,
		BB_Auto_Report_Export_BB_Header.Billback_ID,
		BB_Auto_Report_Export_BB_Header.BB_Title,
		BB_Auto_Report_Export_BB_Header.BB_Code,
		BB_Auto_Report_Export_BB_Header.Shr_Ship_To,
		ISNULL(BB_Auto_Report_Export_BB_Header.Shr_Ship_To, VM.Vendor_ID) as Distributor_ID,
		ISNULL(BB_Auto_Report_Export_BB_Header.Shr_Ship_To_Name, VM.Vendor_Name) as Shr_Ship_To_Name,
		BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID AS Payee_ID
		<!--- ,
		isnull(sum(BB_Auto_Report_Export_BB_Detail.Cases_Invoiced), 0) AS Total_Cases,
		isnull(sum(BB_Auto_Report_Export_BB_Detail.Pounds_Invoiced), 0) AS Total_Pounds, --->
		<!--- isnull(sum(BB_Approved.Paid_Amount), 0) AS Total_Earned, --->
		<!--- isnull(sum(BB_Auto_Report_Export_BB_Detail.Sales_Dollars), 0) AS Total_Sales_Dollars,
		isnull(sum(BB_Auto_Report_Export_BB_Detail.Amount_Earned), 0) AS Initial_Earned --->
		<!--- isnull(sum(BB_Adjustment.Adjustment_Amount),0) AS Adjustment --->
	FROM BB_Auto_Report
		INNER JOIN BB_Auto_Report_Period
		ON BB_Auto_Report.BB_Auto_Report_Period_ID = BB_Auto_Report_Period.BB_Auto_Report_Period_ID
		INNER JOIN BB_Auto_Program_Pay_Period
		ON BB_Auto_Program_Pay_Period.BB_Auto_Report_ID = BB_Auto_Report.BB_Auto_Report_ID AND
			BB_Auto_Program_Pay_Period.Program_ID = <cfqueryparam value="#arguments.Contract_Main_ID#" cfsqltype="numeric">
		INNER JOIN Contract_Main
		ON Contract_Main.Contract_Main_ID = BB_Auto_Program_Pay_Period.Program_ID
		AND Contract_Main.Contract_Main_ID = <cfqueryparam value="#arguments.Contract_Main_ID#" cfsqltype="numeric">
		INNER JOIN BB_Auto_Report_Export_Header
		ON BB_Auto_Report_Export_Header.BB_Auto_Report_ID = BB_Auto_Report.BB_Auto_Report_ID
		INNER JOIN BB_Auto_Report_Export_BB_Header
		ON BB_Auto_Report_Export_BB_Header.Export_Header_ID = BB_Auto_Report_Export_Header.Export_Header_ID AND 
			BB_Auto_Report_Export_BB_Header.Contract_Main_ID IN (
				SELECT CM_Id.Contract_Main_ID FROM Contract_Main CM_Id 
				INNER JOIN Contract_Main CM_Number ON
					CM_Number.Contract_Number = CM_Id.Contract_Number
				WHERE CM_Number.Contract_Main_ID = <cfqueryparam value="#arguments.Contract_Main_ID#" cfsqltype="numeric">
				) 
		LEFT JOIN BSA_Foodservice_Customers
		ON BSA_Foodservice_Customers.Shr_Ship_To = BB_Auto_Report_Export_BB_Header.Shr_Ship_To
		LEFT JOIN Vendor_Master VM
		ON	VM.Vendor_Master_ID = BB_Auto_Report_Export_BB_Header.Distributor_ID_Earned
		AND BB_Auto_Report_Export_BB_Header.Shr_Ship_To IS NULL
		<!--- INNER JOIN BB_Auto_Report_Export_BB_Detail
		ON BB_Auto_Report_Export_BB_Header.BB_Header_ID = BB_Auto_Report_Export_BB_Detail.BB_Header_ID --->
		<!--- INNER JOIN BB_Approved
		ON BB_Approved.Billback_ID = BB_Auto_Report_Export_BB_Header.Billback_ID
		LEFT JOIN BB_Adjustment
		ON BB_Adjustment.Adjustment_deducted_From_BB_ID = BB_Auto_Report_Export_BB_Header.Billback_ID --->
		
	WHERE BB_Auto_Report.BB_Auto_Report_ID = <cfqueryparam value="#arguments.Report_ID#" cfsqltype="numeric"> 
	GROUP BY
		BB_Auto_Report.Report_Title,
		BB_Auto_Report.BB_Auto_Report_ID,
		BB_Auto_Report_Period.Start_Date,
		BB_Auto_Report_Period.End_Date,
		Contract_Main.Contract_Title,
		Contract_Main.Contract_Number,
		Contract_Main.Contract_Main_ID,
		BB_Auto_Report_Export_BB_Header.BB_Title,
		BB_Auto_Report_Export_BB_Header.BB_Code,
	 	BB_Auto_Report_Export_BB_Header.Shr_Ship_To,
	 	ISNULL(BB_Auto_Report_Export_BB_Header.Shr_Ship_To, VM.Vendor_ID),
		ISNULL(BB_Auto_Report_Export_BB_Header.Shr_Ship_To_Name, VM.Vendor_Name),
		BB_Auto_Report_Export_BB_Header.Billback_ID,
		BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
	ORDER BY ISNULL(BB_Auto_Report_Export_BB_Header.Shr_Ship_To_Name, VM.Vendor_Name)
		</cfquery>
	
	<cfreturn GetExtractHeader />
	
	</cffunction>
	<!--- 
	<cffunction name="getAutoPayExtractDetail"  access="public" returntype="query" output="true">
	
	<cfargument name="Report_ID" type="numeric" required="true">
	<cfargument name="Contract_Main_ID" type="numeric" required="true">
		
		<cfset var GetExtractDetail = "">
		
		<cfquery name="GetExtractDetail" datasource="#application.datasource#">
		SELECT 
		BB_Auto_Report.BB_Auto_Report_ID,
		BB_Auto_Report.Report_Title,
		BB_Auto_Report_Period.Start_Date,
		BB_Auto_Report_Period.End_Date,
		BB_Auto_Report_Export_BB_Header.Shr_Ship_To,
		BB_Auto_Report_Export_BB_Header.Shr_Ship_To_Name,
		Distributor_Family.Family_Name,
		Distributor_Family.Family,
		Distributor_Buying_Groups.Buying_Group_Name,
		Distributor_Buying_Groups.Buying_Group,
		Item_Master.Item,
		Item_Master.UPC,
		Item_Master.Description,
		Brand.Brand_Name,
		BB_Auto_Report_Export_BB_Header.Invoice_Date,
		BB_Auto_Report_Export_BB_Header.Purchase_Order,
		BB_Auto_Report_Export_BB_Header.Shared_Invoice_Number,
		isnull(BB_Auto_Report_Export_BB_Detail.Cases_Invoiced, 0) AS Cases_Invoiced,
		isnull(BB_Auto_Report_Export_BB_Detail.Pounds_Invoiced, 0) AS Pounds_Invoiced,
		isnull(BB_Auto_Report_Export_BB_Detail.Sales_Dollars, 0) AS Sales_Dollars,
		isnull(BB_Auto_Report_Export_BB_Detail.Unit_Price, 0) AS Unit_Price,
		BB_Auto_Report_Export_BB_Detail.Price_Unit_of_Measure,
		isnull(BB_Auto_Report_Export_BB_Detail.Discount_Offered, 0) AS Discount_Offered,
		CASE WHEN Discount_UOM = 1
		THEN 'LBS'
		ELSE 
			'CS'
		END AS Discount_UOM,
		isnull(BB_Auto_Report_Export_BB_Detail.Amount_Earned, 0) AS Amount_Earned
	FROM BB_Auto_Report
		INNER JOIN BB_Auto_Report_Period
		ON BB_Auto_Report.BB_Auto_Report_Period_ID = BB_Auto_Report_Period.BB_Auto_Report_Period_ID
		INNER JOIN BB_Auto_Program_Pay_Period
		ON BB_Auto_Program_Pay_Period.BB_Auto_Report_ID = BB_Auto_Report.BB_Auto_Report_ID
		INNER JOIN Contract_Main
		ON Contract_Main.Contract_Main_ID = BB_Auto_Program_Pay_Period.Program_ID
		AND Contract_Main.Contract_Main_ID = <cfqueryparam value="#arguments.Contract_Main_ID#" cfsqltype="numeric">
		INNER JOIN BB_Auto_Report_Export_Header
		ON BB_Auto_Report_Export_Header.BB_Auto_Report_ID = BB_Auto_Report.BB_Auto_Report_ID
		INNER JOIN BB_Auto_Report_Export_BB_Header
		ON BB_Auto_Report_Export_BB_Header.Billback_ID = BB_Auto_Program_Pay_Period.Billback_ID
		AND BB_Auto_Report_Export_BB_Header.Export_Header_ID = BB_Auto_Report_Export_Header.Export_Header_ID
		INNER JOIN BB_Auto_Report_Export_BB_Detail
		ON BB_Auto_Report_Export_BB_Header.Export_Header_ID = BB_Auto_Report_Export_BB_Detail.Export_Header_ID
		AND BB_Auto_Report_Export_BB_Header.BB_Header_ID = BB_Auto_Report_Export_BB_Detail.BB_Header_ID
		INNER JOIN BSA_Foodservice_Items_Master Item_Master
		ON Item_Master.BSA_Foodservice_Items_Master_ID = BB_Auto_Report_Export_BB_Detail.Product_ID
		LEFT JOIN Brand
		ON Brand.Brand_ID = Item_Master.Brand_ID
		LEFT JOIN Billback_Distributor
		ON Billback_Distributor.Billback_ID = BB_Auto_Report_Export_BB_Header.Billback_ID
		LEFT JOIN BSA_Foodservice_Customers
		ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID
		LEFT JOIN Distributor_Family
		ON Distributor_Family.Family_ID = BSA_Foodservice_Customers.Family_ID
		LEFT JOIN Distributor_Buying_Groups
		ON Distributor_Buying_Groups.Buying_Group_ID = BSA_Foodservice_Customers.Buying_Group_ID
	WHERE BB_Auto_Report.BB_Auto_Report_ID = <cfqueryparam value="#arguments.Report_ID#" cfsqltype="numeric">
		
		</cfquery>
	
	<cfreturn GetExtractDetail />
	
	</cffunction>
	 --->
	<cffunction name="getAutoPayExtractComplete"  access="public" returntype="query" output="true">
		<cfargument name="Report_ID" type="numeric" required="true">
		<cfset var qAutoPayExtractComplete = "">
		
		
		<cfquery name="qAutoPayExtractComplete" datasource="#application.datasource#">
		SELECT
			R.BB_Auto_Report_ID,
			R.Report_Title,
			CONVERT(VARCHAR(10), RP.Start_Date, 101) AS Start_Date,
			CONVERT(VARCHAR(10), RP.End_Date, 101) AS End_Date,
			REPLACE(CM.Contract_Title,',','') AS Contract_Title,
			CM.Contract_Number,
			REPLACE(ExBBH.BB_Title,',','') AS BB_Title,
			ExBBH.BB_Code,
			ExBBH.Shr_Ship_To,
			REPLACE(ExBBH.Shr_Ship_To_Name,',','') AS Shr_Ship_To_Name,
		--	DF.Family_Name,
		--	DF.Family,
		--	DBG.Buying_Group_Name,
		--	DBG.Buying_Group,
			ID.Operator_ID,--Operator ID,
			REPLACE(IM.Item,',','') AS Item,
			REPLACE(IM.UPC,',','') AS UPC,
			REPLACE(IM.Description,',','') AS Description,
			REPLACE(B.Brand_Name,char(13),'') AS Brand_Name,
			CONVERT(VARCHAR(10), ExBBH.Invoice_Date, 101) AS Invoice_Date,
			REPLACE(ExBBH.Purchase_Order,',','') AS Purchase_Order,
			REPLACE(ExBBH.Shared_Invoice_Number,',','') AS Shared_Invoice_Number,
			isnull(ExBBD.Cases_Invoiced, 0) AS Cases_Invoiced,
			isnull(ExBBD.Pounds_Invoiced, 0) AS Pounds_Invoiced,
			isnull(ExBBD.Sales_Dollars, 0) AS Sales_Dollars,--Invoice $,
			ID.gross_Sales_Dollars AS Gross_Sales,--Gross Inv $,
			ID.Sales_Dollars AS Rebateable_Sales,--Rebateable Inv $,
			isnull(ExBBD.Unit_Price, 0) AS Unit_Price,--Price,
			ExBBD.Price_Unit_of_Measure,--Price UOM,
			isnull(ExBBD.Discount_Offered, 0) AS Discount_Offered,--Discount,
			UOM.Abbreviation_Singular AS Discount_UOM,--Discount UOM,
			isnull(ExBBD.Amount_Earned, 0) AS Amount_Earned,--$ Earned,
			BFC.Shr_CustID,--Cust ID
			<!--- Get the program associated with the billback where the
			billback is a credit, i.e. a pullback (negative value).
			--->
			CM1.Contract_Number As Credit_Program_Number,
			REPLACE(CM1.Contract_Title,',','') As Credit_Program_Title
			--CM.Contract_Main_ID,
		FROM BB_Auto_Report R
			INNER JOIN BB_Auto_Report_Period RP ON
				R.BB_Auto_Report_Period_ID = RP.BB_Auto_Report_Period_ID
			INNER JOIN BB_Auto_Report_Export_Header ExH ON
				ExH.BB_Auto_Report_ID = R.BB_Auto_Report_ID
			INNER JOIN BB_Auto_Report_Export_BB_Header ExBBH ON
				ExBBH.Export_Header_ID = ExH.Export_Header_ID
			INNER JOIN BB_Auto_Report_Export_BB_Detail ExBBD ON
				ExBBH.Export_Header_ID = ExBBD.Export_Header_ID AND
				ExBBH.BB_Header_ID = ExBBD.BB_Header_ID
			INNER JOIN Contract_Main CM ON
				CM.Contract_Main_ID = ExBBH.Contract_Main_ID
			LEFT JOIN BSA_Foodservice_Items_Master IM ON
				IM.BSA_Foodservice_Items_Master_ID = ExBBD.Product_ID
			LEFT JOIN Invoice_Detail ID ON
				ID.Invoice_Detail_Id = ExBBD.Invoice_Detail_Id
			LEFT JOIN Brand B ON
				B.Brand_ID = IM.Brand_ID
			LEFT JOIN Billback_Distributor BD ON
				BD.Billback_ID = ExBBH.Billback_ID
			LEFT JOIN BSA_Foodservice_Customers BFC ON
				BFC.BSA_Foodservice_Customers_ID = BD.Distributor_ID
			LEFT JOIN Distributor_Family DF ON
				DF.Family_ID = BFC.Family_ID
			LEFT JOIN Distributor_Buying_Groups DBG ON
				DBG.Buying_Group_ID = BFC.Buying_Group_ID
			LEFT JOIN Units_Of_Measure UOM On
				UOM.Unit_Of_Measure_id = ExBBD.Discount_UOM
			<!--- Sometime billbacks are inserted as "credits" (pullback) in the "invoice_header" table.
			"BB_Auto_Report_Export_BB_Header" has it populated from the "invoice_header" table.
			In the case of credits, "Shared_Invoice_Number" stores bb code.
			--->
			LEFT JOIN Billback BB
				ON ExBBH.Shared_Invoice_Number = BB.BB_code
			LEFT JOIN Billback_Program BP
				ON BB.Billback_ID = BP.Billback_ID
			LEFT JOIN Contract_Main CM1
				ON BP.Program_ID = CM1.Contract_Main_ID
			AND BP.deleted = 0
		WHERE R.BB_Auto_Report_ID = <cfqueryparam value="#arguments.Report_ID#" cfsqltype="numeric">  
		ORDER BY CM.Contract_Number	
		</cfquery>
	<cfreturn qAutoPayExtractComplete />

	</cffunction>
	
	<cffunction name="getAutoPayPullbackExport"  access="public" returntype="query" output="true">
		<cfargument name="Report_ID" type="numeric" required="true">
		
		<cfset var qGetAutoPayPullbackExport = "">
		
		<cfquery name="qGetAutoPayPullbackExport" datasource="#application.datasource#">

			SELECT
					R.BB_Auto_Report_ID,
					R.Report_Title,
					contract_main.Contract_Number as [Auto Pay Program],
					contract_main.Contract_Title as [Auto Pay Program Title],
					B.BB_Code as [Auto PayBB],
					B.BB_Title as [Auto PayBB Title],
					B.BB_Amount as [Auto Pay BB $],
					isnull(BB_Approved.Pullback_Applied_Amount, 0) as Pullback_Applied_Amount,
					BB_Approved.Paid_Amount as [Auto Pay BB Final $],
					PH.PullBack_Contract_Number,
					PH.PullBack_Contract_Title,
					OPRBB.bb_code as [Recap BB],
					OPRBB.BB_title as [Recap BB Title],
					OPRBB.bb_start_date as [Recap BB Start Date],
					OPRBB.bb_end_date as [Recap BB End Date],
					OPRBBAPPR.Date_Approved,
					ISNULL(SUM(PD.Pullback_Amount),0) as Pullback_Amount,
					cast(SUM(PD.product_BB_volume_CS) as decimal(20,4)) as [Recap Cases]
			FROM BB_Auto_Report_Export_Header H
			INNER JOIN BB_Auto_Report R 
			ON		R.BB_Auto_Report_ID = H.BB_Auto_Report_ID
			INNER JOIN BB_Auto_Report_Export_PullBack_Header PH
				ON PH.Export_Header_Id = H.Export_Header_Id
			INNER JOIN BB_Auto_Report_Export_PullBack_Detail PD
				ON PH.Export_Header_Id = PD.Export_Header_Id AND
				PH.PullBack_Header_Id = PD.PullBack_Header_Id					
			INNER JOIN BillBack B 
			ON		B.Billback_Id = PH.Dis_Corp_Billback_Id
			INNER JOIN BB_Approved 
			ON		B.Billback_Id = BB_Approved.Billback_Id
			INNER JOIN billback_program 
			on		billback_program.billback_id = PH.Dis_Corp_Billback_Id
			INNER JOIN contract_main 
			on		contract_main.contract_main_id = billback_program.program_id 
			INNER JOIN BillBack OPRBB
			ON		OPRBB.Billback_Id = PH.Pullback_Billback_Id
			INNER JOIN BB_Approved  OPRBBAPPR
			ON		OPRBB.Billback_Id = OPRBBAPPR.Billback_Id
			WHERE H.BB_Auto_Report_ID = <cfqueryparam value="#arguments.Report_ID#" cfsqltype="numeric">   
			Group by R.BB_Auto_Report_ID,
					R.Report_Title,
					contract_main.Contract_Number,
					contract_main.Contract_Title,
					B.BB_Code,
					B.BB_Title,
					B.BB_Amount,
					isnull(BB_Approved.Pullback_Applied_Amount, 0),
					BB_Approved.Paid_Amount,
					PH.PullBack_Contract_Number,
					PH.PullBack_Contract_Title,
					OPRBB.bb_code,
					OPRBB.BB_title,
					OPRBB.bb_start_date,
					OPRBB.bb_end_date,
					OPRBBAPPR.Date_Approved

		</cfquery>
	
	<cfreturn qGetAutoPayPullbackExport />
	
	</cffunction>
	
	<cffunction name="getAutoPayPullbackExportDetails"  access="public" returntype="query" output="true">
		<cfargument name="Report_ID" type="numeric" required="true">
		
		<cfset var qGetAutoPayPullbackExport = "">
		
		<cfquery name="qGetAutoPayPullbackExport" datasource="#application.datasource#">

			 SELECT 
					R.BB_Auto_Report_ID,
					REPLACE(R.Report_Title,',','') AS [Report_Title],
					CM.Contract_Number AS [Auto_Pay_Program],
					REPLACE(CM.Contract_Title,',','') AS [Auto_Pay_Program_Title],
					B.BB_Code AS [Auto_PayBB],
					REPLACE(B.BB_Title,',','') AS [Auto_PayBB_Title],
					B.BB_Amount AS [Auto_Pay_BB_$],
					isnull(BB_Approved.Pullback_Applied_Amount, 0) AS Pullback_Applied_Amount,
					BB_Approved.Paid_Amount AS [Auto_Pay_BB_Final_$],
					PH.PullBack_Contract_Number,     
					REPLACE(PH.PullBack_Contract_Title,',','') [PullBack_Contract_Title],
					ISNULL(OPR.Legacy_ID,OPR1.Legacy_ID) [Operator_ID],
					ISNULL(OPR.BSA_Operator_ID,OPR1.BSA_Operator_ID) [BSA_Operator_ID],
					REPLACE(ISNULL(OPR.Operator_Name,OPR1.Operator_Name),',','') [Operator_Name],
					OPRBB.bb_code AS [Recap_BB],
					REPLACE(OPRBB.BB_title,',','') AS [Recap_BB_Title],
					I_Group.Description [Group_Name],
					I.Item [Item_Number],
					REPLACE(I.Description,',','') [Item_Description],
					OPRBB.bb_start_date AS [Recap_BB_Start_Date],
					OPRBB.bb_end_date AS [Recap_BB_End_Date],
					OPRBBAPPR.Date_Approved,
					CAST(PD.PB_From_Program_Rate AS VARCHAR(12)) + '/' + UOM.Abbreviation_Singular AS [Recap_Rate_Percent],-- 
					CASE
					WHEN PB_From_Program_UOM = 1 THEN 
						cast((PD.Corp_Rate) as decimal(20,6))
					ELSE
						cast((PD.Corp_Rate*I.net_weight) as decimal(20,6))
					END AS [Recap_Rate_Per_Case],
					CAST(PD.Budget_Recapture_Rate  AS VARCHAR(12)) + '/' + UOM_Alt.Abbreviation_Singular AS [Alt_Recap_Rate],
				--	CAST(ISNULL(PD.Pullback_Amount,0)/ISNULL(nullif(cast(PD.product_BB_volume_CS AS decimal(20,4)),0),1) AS decimal(20,4)) [Recap_Rate_Per_Case],
					CASE
					WHEN PD.Budget_Recapture_Rate_UOM = 1 THEN 
						cast((PD.Budget_Recapture_Rate) as decimal(20,6))
					ELSE
						cast((PD.Budget_Recapture_Rate*I.net_weight) as decimal(20,6))
					END AS [Alt_Recap_Rate_Per_Case],
					ISNULL(PD.Pullback_Amount,0) AS Pullback_Amount,
					ISNULL(PD.Pullback_Amount_Raw,0) AS Pullback_Amount_Raw,
					cast(PD.product_BB_volume_CS AS decimal(20,0))  AS [Recap_Cases],
					PH.SHR_Ship_To,
					PH.SHR_Ship_To_Name
					--,pd.product_BB_volume_LB
			FROM BB_Auto_Report_Export_Header H
			INNER JOIN BB_Auto_Report R 
			ON		R.BB_Auto_Report_ID = H.BB_Auto_Report_ID
			INNER JOIN BB_Auto_Report_Export_PullBack_Header PH
				ON PH.Export_Header_Id = H.Export_Header_Id
			INNER JOIN BB_Auto_Report_Export_PullBack_Detail PD
				ON PH.Export_Header_Id = PD.Export_Header_Id AND
				PH.PullBack_Header_Id = PD.PullBack_Header_Id					
			INNER JOIN BillBack B 
			ON		B.Billback_Id = PH.Dis_Corp_Billback_Id
			INNER JOIN BB_Approved 
			ON		B.Billback_Id = BB_Approved.Billback_Id
			INNER JOIN Billback_Program  BP
			on		BP.billback_id = PH.Dis_Corp_Billback_Id
			INNER JOIN Contract_Main CM
			on		CM.contract_main_id = BP.program_id 
			INNER JOIN BillBack OPRBB
			ON		OPRBB.Billback_Id = PH.Pullback_Billback_Id
			LEFT JOIN Billback_Operator BO ON
				BO.Billback_ID = PH.Pullback_Billback_Id AND
				BO.Billback_Operator_ID = (SELECT TOP 1 Billback_Operator_ID FROM Billback_Operator WHERE Billback_ID = PH.Pullback_Billback_Id)
			INNER JOIN BB_Approved  OPRBBAPPR
			ON		OPRBB.Billback_Id = OPRBBAPPR.Billback_Id
			LEFT JOIN Billback_Program  BPOpr
			ON		BPOpr.billback_id = OPRBBAPPR.billback_id
			LEFT JOIN CONTRACT_OPERATORS CO ON CO.Contract_Main_Id = BPOpr.Program_Id
											AND CO.Deleted = 0
											AND CO.Captured_From_Group = 0
											AND CO.Contract_Operators_ID = (SELECT TOP 1 Contract_Operators_ID FROM CONTRACT_OPERATORS WHERE Contract_Main_Id = BPOpr.Program_Id AND CO.Deleted = 0
																	AND CO.Captured_From_Group = 0)
		   LEFT JOIN BSA_OPERATOR OPR1 ON OPR1.bsa_Operator_Id = CO.bsa_Operator_Id
									 AND CO.Is_Group = 0
			LEFT JOIN BSA_Operator OPR ON
				OPR.BSA_Operator_ID = BO.Operator_ID
			LEFT JOIN Contract_Products CP ON
				CP.Contract_Main_ID = CM.Contract_Main_ID AND
				CP.Deleted = 0 AND
				CP.Is_Group = 0 AND CP.BSA_Foodservice_Items_Master_ID = PD.Product_Id
				--Item groups
			LEFT JOIN Contract_Products CP_Group ON
				CP_Group.Contract_Products_ID = CP.Group_Contract_Product_ID AND
				CP.Group_Contract_Product_ID IS NOT NULL AND
				CP_Group.Contract_Main_ID = CM.Contract_Main_ID
			LEFT JOIN BSA_Foodservice_Items_Master I_Group ON
				I_Group.BSA_Foodservice_Items_Master_ID = CP_Group.BSA_Foodservice_Items_Master_ID
			LEFT JOIN BSA_Foodservice_Items_Master I2 ON
				I2.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
			LEFT JOIN BSA_Foodservice_Items_Master I ON
				I.BSA_Foodservice_Items_Master_ID = PD.Product_Id
			LEFT JOIN Units_of_Measure UOM ON
				UOM.Unit_Of_Measure_ID = PD.PB_From_Program_UOM  --Budget_Recapture_Rate_UOM
			LEFT JOIN Units_of_Measure UOM_Alt ON
				UOM_Alt.Unit_Of_Measure_ID = PD.Budget_Recapture_Rate_UOM	
			WHERE 	H.BB_Auto_Report_ID = <cfqueryparam value="#arguments.Report_ID#" cfsqltype="numeric">  AND
					R.BB_Auto_Report_ID = <cfqueryparam value="#arguments.Report_ID#" cfsqltype="numeric">
		</cfquery>
	
		<cfreturn qGetAutoPayPullbackExport />
	
	</cffunction>
	
	<cffunction name="getProgramsonReport" access="public" returntype="query" output="false">
		<cfargument name="Report_ID" required="true">
		<cfset var qProgramsonReport = "">
		
		<!--- As far as I know, this function is no longer used --->
		
		<cfquery name="qProgramsonReport" datasource="#application.datasource#">
		SELECT DISTINCT
			CM.Contract_Title,
			CM.Contract_Number,
			CM.Contract_Main_ID
		FROM Contract_Main CM
			INNER JOIN BB_Auto_Program_Pay_Period BAPPP
			ON BAPPP.Program_ID = CM.Contract_Main_ID
			AND BAPPP.BB_Auto_Report_ID = <cfqueryparam value="#arguments.Report_ID#" cfsqltype="numeric">
		</cfquery>
		
	<cfreturn qProgramsonReport />
	
	</cffunction>
	
	<cffunction name="getProgramsDistributorDetails" access="public" returntype="query" output="false">
		<cfargument name="Billback_ID" required="true">
		<cfargument name="Shr_Ship_To" required="true">

		<cfset var qProgramsDistributorDetails = "">
		
		<cfquery name="qProgramsDistributorDetails" datasource="#application.datasource#">
		SELECT DISTINCT
			
			isnull(sum(BB_Auto_Report_Export_BB_Detail.Amount_Earned), 0) AS Program_Distributor_Earned,
			isnull(sum(BB_Auto_Report_Export_BB_Detail.Cases_Invoiced), 0) AS Total_Cases,
			isnull(sum(BB_Auto_Report_Export_BB_Detail.Pounds_Invoiced), 0) AS Total_Pounds,
			isnull(sum(BB_Auto_Report_Export_BB_Detail.Sales_Dollars), 0) AS Total_Sales_Dollars,
			isnull(sum(BB_Auto_Report_Export_BB_Detail.Amount_Earned), 0) AS Initial_Earned 
		FROM BB_Auto_Report_Export_BB_Header
			INNER JOIN BB_Auto_Report_Export_BB_Detail
			ON BB_Auto_Report_Export_BB_Header.BB_Header_ID = BB_Auto_Report_Export_BB_Detail.BB_Header_ID
		WHERE BB_Auto_Report_Export_BB_Header.Billback_ID = <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="cf_sql_char">
			<cfif arguments.Shr_Ship_To EQ "">
			AND BB_Auto_Report_Export_BB_Header.Shr_Ship_To IS NULL
			<cfelse>
			AND BB_Auto_Report_Export_BB_Header.Shr_Ship_To = <cfqueryparam value="#arguments.Shr_Ship_To#" cfsqltype="cf_sql_char">
			</cfif>			
		</cfquery>
		
	<cfreturn qProgramsDistributorDetails />
	
	</cffunction>
	
	<cffunction name="getProgramsDetails" access="public" returntype="query" output="false">
		<cfargument name="Report_ID" required="true">
		<cfargument name="Contract_Main_ID" required="true">

		<cfset var qProgramsDetails = "">
		
		<cfquery name="qProgramsDetails" datasource="#application.datasource#">
		SELECT DISTINCT
			
			isnull(sum(BB_Auto_Report_Export_BB_Detail.Amount_Earned), 0) AS Program_Earned
		FROM Contract_Main CM
			INNER JOIN BB_Auto_Program_Pay_Period BAPPP
			ON BAPPP.Program_ID = CM.Contract_Main_ID
			AND BAPPP.BB_Auto_Report_ID = <cfqueryparam value="#arguments.Report_ID#" cfsqltype="numeric">
			INNER JOIN BB_Auto_Report_Export_Header
			ON BB_Auto_Report_Export_Header.BB_Auto_Report_ID = BAPPP.BB_Auto_Report_ID
			INNER JOIN BB_Auto_Report_Export_BB_Header
			ON BB_Auto_Report_Export_BB_Header.Billback_ID = BAPPP.Billback_ID
			AND BB_Auto_Report_Export_BB_Header.Export_Header_ID = BB_Auto_Report_Export_Header.Export_Header_ID
			INNER JOIN BB_Auto_Report_Export_BB_Detail
			ON BB_Auto_Report_Export_BB_Header.Export_Header_ID = BB_Auto_Report_Export_BB_Detail.Export_Header_ID
			AND BB_Auto_Report_Export_BB_Header.BB_Header_ID = BB_Auto_Report_Export_BB_Detail.BB_Header_ID
		WHERE CM.Contract_Main_ID = <cfqueryparam value="#arguments.Contract_Main_ID#" cfsqltype="cf_sql_integer">
		</cfquery>
		
	<cfreturn qProgramsDetails />
	
	</cffunction>
	
	<cffunction name="getCustomersonReport" access="public" returntype="query" output="false">
		<cfargument name="Report_ID"  required="true">
		<cfargument name="Contract_Main_ID" required="true">
		
		<cfset var qCustomersonReport = "">
		
		<cfquery name="qCustomersonReport" datasource="#application.datasource#">
		SELECT DISTINCT
			BAREBH.Shr_Ship_To,
			ISNULL(BAREBH.Shr_Ship_To_Name, VM.Vendor_Name) as Shr_Ship_To_Name,
			BAREBH.Billback_ID,
			BAREBH.BB_Code,
			ISNULL(BFC.Ship_To, VM.Vendor_ID) as Ship_To,
			BFC.Shr_CustID,
			BFC.Address_1 AS Dist_Address_1,
			BFC.Address_2 AS Dist_Address_2,
			BFC.City AS Dist_City,
			BFC.State AS Dist_State,
			BFC.ZipCode AS Dist_Zip,
			ISNULL(BFC.BSA_Foodservice_Customers_ID, VM.Vendor_Master_ID) as BSA_Foodservice_Customers_ID,
			DBG.Buying_Group,
			DBG.Buying_Group_Name,
			BFB.Broker_Name,
			BFB.Broker_Shard,
			BFB.Address AS Brok_Address_1,
			BFB.Address_2  AS Brok_Address_2,
			BFB.City AS Brok_City,
			BFB.State AS Brok_State,
			BFB.Zip AS Brok_Zip,
			BAR.BB_Auto_Report_ID,
			BAR.Report_Title,
			BAR.Run_Date,
			BARP.Start_Date,
			BARP.End_Date,
			CM.Contract_Main_ID,
			CM.Contract_Number,
			CM.Contract_Title,
			CM.Contract_Start_Date,
			CM.Contract_End_Date,
			BB_Approved.Paid_Amount
		FROM BB_Auto_Report BAR
			INNER JOIN BB_Auto_Report_Period BARP
			ON Barp.BB_Auto_Report_Period_ID = BAR.BB_Auto_Report_Period_ID
			INNER JOIN BB_Auto_Report_Export_Header BAREH
			ON BAREH.BB_Auto_Report_ID = BAR.BB_Auto_Report_ID
			INNER JOIN BB_Auto_Report_Export_BB_Header BAREBH
			ON BAREH.Export_Header_ID = BAREBH.Export_Header_ID
			INNER JOIN BB_Approved 
			ON BB_Approved.Billback_ID = BAREBH.Billback_ID					
			INNER JOIN Contract_Main CM
			ON CM.Contract_Main_ID = BAREBH.Contract_Main_ID
			AND CM.Contract_Main_ID = <cfqueryparam value="#arguments.Contract_Main_ID#" cfsqltype="numeric">
			LEFT JOIN BSA_Foodservice_Customers BFC
			ON BFC.Shr_Ship_To = BAREBH.Shr_Ship_To
			LEFT JOIN Vendor_Master VM
			ON VM.Vendor_Master_ID = BAREBH.Distributor_ID_Earned
			AND BAREBH.Shr_Ship_To IS NULL <!--- When payee is vendor and it is growth LS --->
			LEFT JOIN Distributor_Buying_Groups DBG
			ON DBG.Buying_Group_ID = BFC.Buying_Group_ID
			LEFT JOIN BSA_Foodservice_Brokers BFB
			ON BFB.BSA_Foodservice_Brokers_ID = BFC.BSA_Foodservice_Brokers_ID
		WHERE BAR.BB_Auto_Report_ID = <cfqueryparam value="#arguments.Report_ID#" cfsqltype="cf_sql_integer">
		ORDER BY ISNULL(BAREBH.Shr_Ship_To_Name, VM.Vendor_Name)
		</cfquery>
		
	<cfreturn qCustomersonReport />
	
	</cffunction>

	<cffunction name="getAppliedAdjustments" access="public" returntype="query" output="true">
		<cfargument name="Billback_ID" required="true">
		<cfargument name="Payee_Id" required="true">
		<cfset var qAppliedAdjustments = "">
		
		<cfquery name="qAppliedAdjustments" datasource="#application.datasource#">
		SELECT 
			DeviationBB.BB_Code,
			DeviationBB.BB_Title,
			DeviationBB.BB_Start_Date,
			DeviationBB.BB_End_Date,
			DeviationBB.BB_Reference,
			isnull(DeviationBB.BB_Amount, 0) AS BB_Amount,
			isnull(BA.Adjustment_Amount, 0) AS Adjustment_Amount
		FROM  BB_Adjustment BA
		INNER JOIN Billback DeviationBB ON 
			BA.Billback_ID = DeviationBB.Billback_ID AND
			BA.Payee_ID = <cfqueryparam value="#arguments.Payee_Id#" cfsqltype="cf_sql_varchar">
		INNER JOIN BSA_Foodservice_Customers BFC ON
			BFC.BSA_Foodservice_Customers_ID = BA.Payee_ID
		WHERE BA.Adjustment_Deducted_From_BB_ID = <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="cf_sql_varchar">
		ORDER BY DeviationBB.BB_Code
		</cfquery>
		
		<cfreturn qAppliedAdjustments />
	
	</cffunction>
	
	<cffunction name="getLumpsum" access="public" returntype="query" output="true">
		<cfargument name="Billback_ID" required="true">
		<cfset var qAppliedAdjustments = "">
		
		<cfquery name="qGetLumpsum" datasource="#application.datasource#">
		SELECT 	isnull(LS_Paid_Amount, 0) AS LS_Paid_Amount
		FROM  	BB_Lump_Sums
		WHERE 	BB_Lump_Sums.Billback_ID = <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="cf_sql_varchar">
		AND		BB_Lump_Sums.Deleted = 0
		</cfquery>
		
		<cfreturn qGetLumpsum />
	
	</cffunction>

	<cffunction name="getSumDistAppliedAdjustments" access="public" returntype="query" output="false">
		<cfargument name="Billback_ID" required="true">
		<cfargument name="Payee_Id" required="true">
		<cfset var qGetSumDistAppliedAdjustments = "">
		
		<cfquery name="qGetSumDistAppliedAdjustments" datasource="#application.datasource#">
		SELECT 
			SUM(BA.Adjustment_Amount) AS Sum_Adjustment_Amount
		FROM  BB_Adjustment BA
		INNER JOIN Billback DeviationBB ON 
			BA.Billback_ID = DeviationBB.Billback_ID AND
			BA.Payee_ID = <cfqueryparam value="#arguments.Payee_Id#" cfsqltype="cf_sql_varchar" null="#IIF(arguments.Payee_Id EQ '', true, false)#">
		INNER JOIN BSA_Foodservice_Customers BFC ON
			BFC.BSA_Foodservice_Customers_ID = <cfqueryparam value="#arguments.Payee_Id#" cfsqltype="cf_sql_varchar" null="#IIF(arguments.Payee_Id EQ '', true, false)#">
		WHERE BA.Adjustment_Deducted_From_BB_ID = <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="cf_sql_varchar"> AND
			  BA.Payee_ID = <cfqueryparam value="#arguments.Payee_Id#" cfsqltype="cf_sql_varchar" null="#IIF(arguments.Payee_Id EQ '', true, false)#">
		</cfquery>
		
		<cfreturn qGetSumDistAppliedAdjustments />
	
	</cffunction>

	<cffunction name="getAdjustments" access="public" returntype="query" output="false">
		<cfargument name="Billback_ID" required="true">
		
		<cfset var qGetAdjustments = "">
		
		<cfquery name="qGetAdjustments" datasource="#application.datasource#">
		SELECT isnull(sum(BA.Adjustment_Amount), 0) AS Adjustment
		FROM BB_Adjustment BA
		WHERE BA.Adjustment_Deducted_From_BB_ID = <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		
		<cfreturn qGetAdjustments />
	
	</cffunction>
	
	<cffunction name="getClawbacks" access="public" returntype="query" output="false">
		<cfargument name="Billback_ID" required="true">
		
		<cfset var qGetAdjustments = "">
		
		<cfquery name="qGetAdjustments" datasource="#application.datasource#">
		SELECT isnull(sum(BA.Adjustment_Amount), 0) AS Adjustment
		FROM BB_Adjustment BA
		WHERE BA.Adjustment_Deducted_From_BB_ID = <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		
		<cfreturn qGetAdjustments />
	
	</cffunction>
	
	<cffunction name="getTotalEarned" access="public" returntype="query" output="false">
		<cfargument name="Billback_ID" required="true">
		
		<cfset var qGetTotalEarned = "">
		
		<cfquery name="qGetTotalEarned" datasource="#application.datasource#">
		SELECT isnull(sum(BA.Paid_Amount), 0) AS Total_Earned
		FROM BB_Approved BA
		WHERE BA.Billback_ID = <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		
		<cfreturn qGetTotalEarned />
	
	</cffunction>

	<cffunction name="getInvoiceLevelInfo" access="public" returntype="query" output="false">
		<cfargument name="Report_ID"  required="true">
		<cfargument name="Shr_Ship_To"  required="true">
		<cfargument name="Contract_Main_ID"  required="true">
	
		<cfset var qInvoiceLevelInfo = "">
		
		<cfquery name="qInvoiceLevelInfo" datasource="#application.datasource#">
		SELECT DISTINCT
			BAREBH.Shared_Invoice_Number,
			BAREBH.Invoice_Date,
			BAREBH.Purchase_Order,
			<!--- Get the program associated with the billback where the
			billback is a credit, i.e. a pullback (negative value).
			--->
			CM.contract_Number As Credit_Program_Number,
			REPLACE(CM.contract_Title,',','') As Credit_Program_Title
		FROM BB_Auto_Report_Export_Header BAREH
			INNER JOIN BB_Auto_Report_Export_BB_Header BAREBH
			ON BAREBH.Export_Header_ID = BAREH.Export_Header_ID
			<!--- Sometime billbacks are inserted as "credits" (pullback) in the "invoice_header" table.
			"BB_Auto_Report_Export_BB_Header" has it populated from the "invoice_header" table.
			In the case of credits, "Shared_Invoice_Number" stores bb code.
			--->
			LEFT JOIN Billback B
			ON BAREBH.Shared_Invoice_Number = B.BB_code
			LEFT JOIN Billback_Program BP
			ON B.Billback_ID = BP.Billback_ID
			LEFT JOIN Contract_Main CM
			ON BP.Program_ID = CM.Contract_Main_ID
			AND BP.deleted = 0
		WHERE BAREH.BB_Auto_Report_ID = <cfqueryparam value="#arguments.Report_ID#" cfsqltype="cf_sql_integer">
			<cfif arguments.Shr_Ship_To EQ "">
			AND BAREBH.Shr_Ship_To IS NULL
			<cfelse>
			AND BAREBH.Shr_Ship_To = <cfqueryparam value="#arguments.Shr_Ship_To#" cfsqltype="cf_sql_char">
			</cfif>
			AND BAREBH.Contract_Main_ID = <cfqueryparam value="#arguments.Contract_Main_ID#" cfsqltype="cf_sql_integer">	
		ORDER BY BAREBH.Shared_Invoice_Number
		</cfquery>
		
		<cfreturn qInvoiceLevelInfo />
	
	</cffunction>
	
	<cffunction name="getDistAmountEarned" access="public" returntype="query" output="false">
		<cfargument name="Report_ID"  required="true">
		<cfargument name="Shr_Ship_To"  required="true">
		<cfargument name="Contract_Main_ID"  required="true">
		<cfargument name="Distributor_GUID"  required="false" default="">
	
		<cfset var qGetDistAmountEarned = "">
		
		<cfquery name="qGetDistAmountEarned" datasource="#application.datasource#">
			SELECT SUM(BAREBD.Amount_Earned) AS Sum_Amount_Earned
			FROM BB_Auto_Report_Export_Header BAREH
			INNER JOIN BB_Auto_Report_Export_BB_Header BAREBH ON 
				BAREBH.Export_Header_ID = BAREH.Export_Header_ID
			INNER JOIN BB_Auto_Report_Export_BB_Detail BAREBD ON 
				BAREBD.Export_Header_ID = BAREBH.Export_Header_ID AND 
				BAREBD.BB_Header_ID = BAREBH.BB_Header_ID
			WHERE BAREH.BB_Auto_Report_ID = <cfqueryparam value="#arguments.Report_ID#" cfsqltype="cf_sql_integer">
				<CFIF arguments.Shr_Ship_To EQ "">
				AND BAREBH.Shr_Ship_To IS NULL
				<CFELSE>
				AND BAREBH.Shr_Ship_To = <cfqueryparam value="#arguments.Shr_Ship_To#" cfsqltype="cf_sql_char">
				</CFIF>
				<CFIF arguments.Distributor_GUID NEQ "">
				AND BAREBH.Distributor_ID_Earned = <cfqueryparam value="#arguments.Distributor_GUID#" cfsqltype="cf_sql_char">
				</CFIF>
				AND BAREBH.Contract_Main_ID = <cfqueryparam value="#arguments.Contract_Main_ID#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfreturn qGetDistAmountEarned />
	
	</cffunction>
	
	<cffunction name="getInvoiceDetailInfo" access="public" returntype="query" output="false">
		<cfargument name="Report_ID"  required="true">
		<cfargument name="Shr_Ship_To"  required="true">
		<cfargument name="Contract_Main_ID"  required="true">
		<cfargument name="Shared_Invoice_Number"  required="true">
		<cfargument name="Distributor_GUID"  required="false" default="">
	
		<cfset var qInvoiceDetailInfo = "">
		<cfset var qAttributeQuery = "">
		<cfset var AttributeTable="Brand">
		<cfset var AttributeField="Brand_ID">
		<cfset var AttributeValue="Brand_Name">
		<cfset var AttributeNumber="Brand">
		<cfset var AttributeDescription="Brand">
		
		<!--- Using dynamic product attributes --->
		
		<cfquery name="qAttributeQuery" datasource="#application.datasource#">
		SELECT		PGL.Group_Level_Desc,
					PGA.Product_Group_Attribute_Table,
					PGA.Product_Group_Attribute_ID_Field,
					PGA.Product_Group_Attribute_Name_Field,
					PGA.Product_Group_Attribute_Number_Field
		FROM		Product_Group_Level PGL
		INNER JOIN	Product_Group_Attribute PGA
		ON			PGA.Product_Group_Level_ID = PGL.Product_Group_Level_ID
		WHERE		PGA.Product_Group_Level_ID = <cfqueryparam value="#application.appSettingsGet.getPrimary_Product_Attribute()#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfif qAttributeQuery.Recordcount EQ 1>
			<cfset AttributeTable = qAttributeQuery.Product_Group_Attribute_Table>
			<cfset AttributeField = qAttributeQuery.Product_Group_Attribute_ID_Field>
			<cfset AttributeValue = qAttributeQuery.Product_Group_Attribute_Name_Field>
			<cfset AttributeNumber = qAttributeQuery.Product_Group_Attribute_Number_Field>
			<cfset AttributeDescription = qAttributeQuery.Group_Level_Desc>
		</cfif>
		
		<cfquery name="qInvoiceDetailInfo" datasource="#application.datasource#">
		SELECT DISTINCT
			BAREBH.Shared_Invoice_Number,
			BAREBH.Invoice_Date,
			BAREBH.Purchase_Order,
			'#AttributeDescription#' AS Attribute_Description,
			AttributeTable.#AttributeValue# AS Attribute_Value,
			AttributeTable.#AttributeNumber# AS Attribute_Number,
			BAREBD.Item,
			BFID.UPC,
			BAREBD.Item_Description,
			ISNULL(BAREBD.Cases_Invoiced,0) AS Cases_Invoiced,
			ISNULL(BAREBD.Pounds_Invoiced,0) AS Pounds_Invoiced,
			ISNULL(BAREBD.Unit_Price,0) AS Unit_Price,
			BAREBD.Price_Unit_Of_Measure,
			ISNULL(BAREBD.Sales_Dollars,0) AS Sales_Dollars,
			BAREBD.Discount_Offered,
			BAREBD.Invoice_Detail_ID,
			CASE WHEN BAREBD.Discount_UOM = 1
			THEN '/CS'
			WHEN BAREBD.Discount_UOM = 2
			THEN '/LB'
			WHEN BAREBD.Discount_UOM = 3
			THEN '%'	
			END AS Discount_UOM,
			ISNULL(BAREBD.Amount_Earned,0) AS Amount_Earned,
			ISNULL(BAREBD.Previous_Paid_Amount,0) AS Previous_Paid_Amount
		FROM BB_Auto_Report_Export_Header BAREH
		INNER JOIN BB_Auto_Report_Export_BB_Header BAREBH ON
			BAREBH.Export_Header_ID = BAREH.Export_Header_ID
		INNER JOIN BB_Auto_Report_Export_BB_Detail BAREBD ON
			BAREBD.Export_Header_ID = BAREBH.Export_Header_ID AND
			BAREBD.BB_Header_ID = BAREBH.BB_Header_ID
		INNER JOIN BSA_Foodservice_Items_Master BFID ON
			BFID.BSA_Foodservice_Items_Master_ID = BAREBD.Product_ID
		INNER JOIN Invoice_Detail ID ON
			ID.Invoice_Detail_Id = BAREBD.Invoice_Detail_ID AND
			ISNULL(CAST(ID.Current_Shared_Ship_To AS NVARCHAR(50)),BAREBH.Shr_Ship_To) = BAREBH.Shr_Ship_To
		LEFT JOIN #AttributeTable# AttributeTable ON
			AttributeTable.#AttributeField# = BFID.#AttributeField#
		WHERE BAREH.BB_Auto_Report_ID = <cfqueryparam value="#arguments.Report_ID#" cfsqltype="cf_sql_integer">
			AND BAREBH.Shr_Ship_To = <cfqueryparam value="#arguments.Shr_Ship_To#" cfsqltype="cf_sql_char">
			AND BAREBH.Contract_Main_ID = <cfqueryparam value="#arguments.Contract_Main_ID#" cfsqltype="cf_sql_integer">	
			AND BAREBH.Shared_Invoice_Number = <cfqueryparam value="#arguments.Shared_Invoice_Number#" cfsqltype="cf_sql_char">
		UNION ALL
		SELECT DISTINCT
			BAREBH.Shared_Invoice_Number,
			BAREBH.Invoice_Date,
			BAREBH.Purchase_Order,
			'' AS Attribute_Description,
			'' AS Attribute_Value,
			'' AS Attribute_Number,
			'Bonus' as Item,
			'' as UPC,
			'' as Item_Description,
			0 AS Cases_Invoiced,
			0 AS Pounds_Invoiced,
			0 AS Unit_Price,
			'' as Price_Unit_Of_Measure,
			0 AS Sales_Dollars,
			0 as Discount_Offered,
			null as Invoice_Detail_ID,
			'' AS Discount_UOM,
			ISNULL(BAREBD.Amount_Earned,0) AS Amount_Earned,
			ISNULL(BAREBD.Previous_Paid_Amount,0) AS Previous_Paid_Amount
		FROM BB_Auto_Report_Export_Header BAREH
		INNER JOIN BB_Auto_Report_Export_BB_Header BAREBH ON
			BAREBH.Export_Header_ID = BAREH.Export_Header_ID
		INNER JOIN BB_Auto_Report_Export_BB_Detail BAREBD ON
			BAREBD.Export_Header_ID = BAREBH.Export_Header_ID AND
			BAREBD.BB_Header_ID = BAREBH.BB_Header_ID
		WHERE BAREH.BB_Auto_Report_ID = <cfqueryparam value="#arguments.Report_ID#" cfsqltype="cf_sql_integer">
			<CFIF arguments.Shr_Ship_To EQ "">
			AND BAREBH.Shr_Ship_To IS NULL
			<CFELSE>
			AND BAREBH.Shr_Ship_To = <cfqueryparam value="#arguments.Shr_Ship_To#" cfsqltype="cf_sql_char">
			</CFIF>
			<CFIF arguments.Distributor_GUID NEQ "">
			AND BAREBH.Distributor_ID_Earned = <cfqueryparam value="#arguments.Distributor_GUID#" cfsqltype="cf_sql_char">
			</CFIF>
			AND BAREBH.Contract_Main_ID = <cfqueryparam value="#arguments.Contract_Main_ID#" cfsqltype="cf_sql_integer">	
			AND BAREBH.Shared_Invoice_Number = <cfqueryparam value="#arguments.Shared_Invoice_Number#" cfsqltype="cf_sql_char">
			AND BAREBD.Product_ID IS NULL
		ORDER BY 1
		</cfquery>

		<cfreturn qInvoiceDetailInfo />
	
	</cffunction>
	
	<cffunction name="getExcludedInvoices" access="public" returntype="query" output="false">
		<cfargument name="BSA_Foodservice_Customers_ID"  required="true">
		<cfargument name="Contract_Main_ID"  required="true">
		<cfargument name="Report_Start_Date"  required="true">
		<cfargument name="Report_End_Date"  required="true">
	
		<cfset var qExcludedInvoices = "">
		
		<cfquery name="qExcludedInvoices" datasource="#application.datasource#">
		SELECT
			IH.Order_Number,
			IH.Invoice_Date,
			IH.Purchase_Order,
			ID.Item,
			ID.Cases_Invoiced,
			ID.Pounds_Invoiced,
			ID.Sales_Dollars,
			ID.BSA_Contract_Number,
			CM.Contract_Title,
			ID.Contract_Number,
			ID.BSA_Operator_ID,
			BO.Operator_Name,
			ID.Operator_ID
		FROM Invoice_Header IH
			INNER JOIN Invoice_Detail ID
			ON IH.Invoice_Header_ID = ID.Invoice_Header_ID
			AND ID.Fob_Price_Ind = 'X'
			INNER JOIN Contract_Products CP
			ON CP.Contract_Main_ID = <cfqueryparam value="#arguments.Contract_Main_ID#" cfsqltype="cf_sql_integer">
			AND CP.BSA_Foodservice_Items_Master_ID = ID.BSA_Foodservice_Items_Master_ID
			LEFT JOIN Contract_Main CM
			ON CM.Contract_Number = ID.Contract_Number
			AND CM.Deleted = 0
			LEFT JOIN BSA_Operator BO
			ON BO.BSA_Operator_ID = ID.BSA_Operator_ID
		WHERE 
			IH.Invoice_Date >= <cfqueryparam value="#arguments.Report_Start_Date#" cfsqltype="cf_sql_date">
			AND IH.Invoice_Date <= <cfqueryparam value="#arguments.Report_End_Date#" cfsqltype="cf_sql_date">
			AND IH.BSA_Foodservice_Customers_ID = <cfqueryparam value="#arguments.BSA_Foodservice_Customers_ID#" cfsqltype="cf_sql_char">
		ORDER BY IH.Order_Number
		</cfquery>
		
		<cfreturn qExcludedInvoices />
	
	</cffunction>
	
	<cffunction name="getAutoPayData" access="public" returntype="query" output="false">
		<cfargument name="dtStart"  required="false" default="">
		<cfargument name="dtEnd"  	required="false" default="">
		<cfargument name="reportId" type="string"	required="false" default="0">
		<cfargument name="invoiceNumber" type="string"	required="false" default="">
		<cfset var qAutoPayData = "">
		<cfset var a = arguments>
		<cfquery name="qAutoPayData" datasource="#application.datasource#">
			SELECT DISTINCT
				--PP.BB_Auto_Program_Pay_Period_ID,
				isnull(R.BB_Auto_Report_id,0) AS reportId,
				R.status AS statusId,
				B.Billback_id AS Billback_id_guid,
				B.Billback_ID_Int AS Billback_id,
				B.BB_code AS bbCode,
				B.BB_Title AS bbTitle,
				R.Report_Title AS reportTitle,
				BA.Paid_Amount AS bbAmount,
				BA.Pullback_applied_Amount AS pullbackAmount,
				BA.Total_Adjustment_Applied AS deviationAmount,
				BA.Total_Exclusion_Applied AS exclusionAmount,
				PP.Payment_Start_Date AS startDate,
				PP.Payment_End_Date AS endDate,
				ISNULL(PRCN.Program_Rebates_Component_Name,ISNULL(PFCN.Program_Fixed_Component_Name,ISNULL(PLSN.Program_Lump_Sum_Name,PGCN.Program_Growth_Components_Name))) AS compName,
				R.updated_date AS updDate,
				U.Name_first AS firstName,
				U.Name_Last AS lastName,
				CM.Contract_Title AS contractTitle,
				CM.Contract_Number AS contractNumber,
				CM.Contract_Main_Id AS contractId,
				 IsNull(Eshark_RecordID,IsNull(BFC.Ship_to,IsNull(BRO.Broker_legcy_Shard,ISNULL(VM.Vendor_id,'')))) + ' '  + IsNull(BO.Operator_name,IsNull(BFC.Name,IsNull(BRO.Broker_Name,ISNull(VM.Vendor_Name,'')))) as payeeName,
				IsNull(Eshark_RecordID,IsNull(BFC.Ship_to,IsNull(BRO.Broker_legcy_Shard,ISNULL(VM.Vendor_id,'')))) as payeeId
			FROM	BB_Auto_Report_Period P
			JOIN	BB_Auto_Report R ON
				R.bb_auto_report_period_id = P.bb_auto_report_period_id AND
				R.Deleted = 0
			JOIN	BB_Auto_Program_Pay_Period PP ON
					PP.BB_Auto_Report_id = R.BB_Auto_Report_id AND
					PP.Deleted = 0
			LEFT JOIN	BB_Auto_Pay_Period_Billback PBB ON
					PBB.BB_Auto_Program_Pay_Period_Id = PP.BB_Auto_Program_Pay_Period_Id
			LEFT JOIN	Billback B ON
					B.Billback_id = PBB.Billback_id
			LEFT JOIN	BB_Approved BA ON
					B.Billback_id = BA.Billback_id
			LEFT JOIN Contract_Main CM ON
					CM.Contract_Main_ID = PP.Program_ID
			--LEFT JOIN Program_Rebates_Component PRC ON
			--	PRC.Program_Rebates_Component_ID = PP.Program_Component_ID AND
			--	PRC.Program_ID = PP.Program_ID AND
			--	PP.Discount_Type_ID = 2
			--LEFT JOIN Program_Fixed_Component PFC ON
			--	PFC.Program_Fixed_Component_ID = PP.Program_Component_ID AND
			--	PFC.Program_ID = PP.Program_ID AND
			--	PP.Discount_Type_ID = 1
			LEFT JOIN Program_Rebates_Component_Name PRCN ON
					PRCN.Program_Rebates_Component_Name_ID = PP.Component_ID AND
					PP.Discount_Type_ID = 2
			LEFT JOIN Program_Lump_Sum_Name PLSN ON
				PLSN.Program_Lump_Sum_Name_Id = PP.Component_ID AND
			  	PP.Discount_Type_ID = 3
			LEFT JOIN Program_Fixed_Component_Name PFCN ON
				PFCN.Program_Fixed_Component_Name_ID = PP.Component_ID AND
			  	PP.Discount_Type_ID = 1
			--LEFT JOIN Program_Growth_Components PGC ON
			--	PGC.Growth_Component_Name_Id = PP.Component_ID
			LEFT JOIN Program_Growth_Components_Name PGCN ON
				PGCN.Program_Growth_Components_Name_Id = PP.Component_ID
			LEFT JOIN Billback_Distributor BD ON
				BD.Billback_id = B.Billback_id		
			LEFT JOIN Billback_Operator BBO ON
				BBO.Billback_id = B.Billback_id
			LEFT JOIN BillBack_Broker BBr ON
				BBr.Billback_id = B.Billback_id	
			LEFT JOIN _users U ON
				U.user_id = R.updated_User_id And
				R.updated_User_id IS NOT NULL
			LEFT JOIN BSA_Foodservice_Customers BFC ON
					BFC.BSA_Foodservice_Customers_ID = BD.Distributor_ID
			LEFT JOIN BSA_Operator BO ON
					BO.BSA_Operator_ID = BBO.Operator_ID
			LEFT JOIN BSA_Foodservice_Brokers BRO ON
					BBr.Broker_ID = BRO.BSA_Foodservice_Brokers_ID
			LEFT JOIN Payment_Cycle PC ON
				PC.Payment_Cycle_ID = PP.Payment_Cycle_Id
			LEFT JOIN Vendor_Master VM ON
				VM.vendor_Master_Id = BD.Distributor_ID
			--LEFT JOIN Vendor_Master VM2 ON
			--	VM.vendor_Master_Id = PP.Vendor_Master_Id
			LEFT JOIN BillBack_Distributor_List BDL ON
				BDL.Billback_id = PBB.Billback_id
			LEFT JOIN BSA_Foodservice_Customers BFC2 ON
					BFC2.BSA_Foodservice_Customers_ID = BDL.Distributor_ID	
			WHERE PP.Deleted = 0
				<cfif a.dtStart NEQ '' >
					AND PP.Payment_Start_Date >= <cfqueryparam value="#a.dtStart#" cfsqltype="cf_sql_date" /> 
				</cfif>
				<cfif a.dtEnd NEQ '' >
					AND PP.Payment_End_Date <= <cfqueryparam value="#a.dtEnd#" cfsqltype="cf_sql_date" /> 
				</cfif>
				<cfif a.reportId NEQ 0 AND a.reportId NEQ '' AND ISNUMERIC(a.reportId)>
					AND R.BB_Auto_Report_id = <cfqueryparam value="#a.reportId#" cfsqltype="cf_sql_integer" /> 
				</cfif>
				<cfif a.invoiceNumber NEQ '' >
				AND EXISTS(SELECT Top 1 BB_Auto_Accrual_Log_Id 
						FROM BB_Auto_Accrual_Log 
						WHERE Shared_Invoice_Number like '%#a.invoiceNumber#%' AND
						BB_Id = B.Billback_Id)
				</cfif>
			ORDER BY reportId DESC, CM.Contract_Main_Id, B.Billback_id_Int
		</cfquery>
		
		<cfreturn qAutoPayData />
	
	</cffunction>

<!--- XXXXXXXXXXXX	getReportSummary	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getReportSummary" access="remote" returntype="query">
		<cfargument name="ReportId"	required="no" type="any" default="0" />
		<cfset var qGetBBIds = "" />
		<cfset var qGetReportBBIds = "" />
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetReportSummary">
				SELECT	R.Report_Title as title,
						R.BB_Auto_report_id AS id,
						SUM(isnull(BA.Paid_Amount,0)) as amount,
						SUM(isnull(BA.Pullback_applied_Amount,0)) AS pullbackAmount,
						SUM(isnull(BA.Total_Adjustment_Applied,0)) AS deviationAmount,
						SUM(isnull(BA.Total_Exclusion_Applied,0)) AS exclusionAmount,
						R.status,
						BARP.Start_Date as start,
						BARP.End_Date as [end]
					FROM BB_Auto_Report R
					INNER JOIN BB_Auto_Program_Pay_Period PP ON
						PP.BB_Auto_report_id = R.BB_Auto_report_id
					LEFT JOIN	BB_Auto_Pay_Period_Billback PBB ON
							PBB.BB_Auto_Program_Pay_Period_Id = PP.BB_Auto_Program_Pay_Period_Id
					INNER JOIN BB_Auto_Report_Period BARP ON
							BARP.BB_Auto_Report_Period_ID = R.BB_Auto_Report_Period_ID
					LEFT JOIN BillBack B ON
							B.Billback_Id = PBB.Billback_Id
					LEFT JOIN	BB_Approved BA ON
							B.Billback_id = BA.Billback_id
				 	WHERE R.BB_Auto_report_id = <cfqueryparam value="#arguments.ReportId#" /> AND
					 		ISNULL(B.deleted,0) = 0 AND
					 		PP.deleted = 0
					 GROUP BY R.BB_Auto_report_id,R.Report_Title,R.status,BARP.Start_Date,BARP.End_Date
			</CFQUERY>
		<cfreturn qGetReportSummary />
	</cffunction>
	
<!--- XXXXXXXXXXXX	getReportSummary	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getUniproReportSummary" access="remote" returntype="query">
		<cfargument name="ReportId"	required="no" type="any" default="0" />
		<cfset var qGetReportSummary = "" />
		<!--- 
			Format Version,
			Supplier #,
			Member #,
			Member Location #,
			Member Duns #,
			Member Name,
			Member GLN,
			Supplier Invoice #,
			Member PO #,
			Invoice Date,
			Original Manufacturer DUNs Number,
			Supplier Product #,
			Pack Size,
			Brand,
			ITEM DESC,
			GTIN,
			UPC,
			CASES,
			NET WT,
			Gross Sales,
			Net Sales,
			EDA Rate,
			EDA Pymt,
			SPA Rate,
			SPA Pymt,
			Show Spec Rate,
			Show Spec Pymt,
			Other Rate,
			Other Pymt,
			Drop Ship Paid To,
			Deduction Code,
			Member Billback Reference,
			Reason for Deduction,
			Ship to Address,
			Ship to City,
			Ship to State,
			CaRMA,
			Unit Price,
			Product,
			Internal Vendor Number (ReDistributors Only,
			Manufacturers Item # (ReDistributors Only),
			Manufacturers Name (ReDistributors Only)
			 --->
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetReportSummary">
				SELECT --Top 1
				'A' AS Format	--Format Version
				,'' AS Supplier	--Supplier
				,XREF.Unipro_Num AS Member_Num
				,XREF.Loc AS Member_Location
				,XREF.External_Code AS Member_Duns
				,XREF.External_Description AS Member_Name
				,'' AS Member_GLN
				,ExBBH.Shared_Invoice_Number AS Supplier_Invoice
				,ExBBH.Purchase_Order AS Member_PO
				,CONVERT(VARCHAR(10), ExBBH.Invoice_Date, 101) AS Invoice_Date
				,'' AS Orig_Duns_Num
				,IM.Item AS Supplier_Product
				,IM.Pack_Size AS Pack_Size
				,REPLACE(B.Brand_Name,char(13),'') AS Brand_Name
				,IM.Description AS ITEM_DESC
				,IM.GTIN AS GTIN
				,IM.UPC AS UPC
				,ISNULL(ExBBD.Cases_Invoiced, 0) AS Cases_Invoiced
				,ISNULL(ExBBD.Pounds_Invoiced, 0) AS Pounds_Invoiced
				,IM.Net_Weight AS NET_WT ---IS THIS EXTRA? NOT IN SPEC
				,ID.gross_Sales_Dollars AS Gross_Sales--Gross Sales,
				,ID.Sales_Dollars AS Net_Sales
				,ISNULL(ExBBD.Discount_Offered, 0) AS EDA_Rate
				,ISNULL(ExBBD.Amount_Earned, 0) AS EDA_Pymt
				,0 AS SPA_Rate
				,0 AS SPA_Pymt
				,0 AS Show_Spec_Rate
				,0 AS Show_Spec_Pymt
				,0 AS Other_Rate
				,0 AS Other_Pymt
				,'' AS Drop_Ship_Paid_To
				,CASE WHEN ISNULL(ExBBD.Amount_Earned, 0) >= 0 THEN ''
					ELSE	
						CASE
						  WHEN LEFT(Shared_Invoice_Number,4) = '000-' AND RIGHT(rtrim(Shared_Invoice_Number),3) = '-00' THEN '2'
						  ELSE '6'
						END
					END
					AS Deduction_Code ---SPEC LOGIC
				,CASE
					WHEN LEFT(Shared_Invoice_Number,4) = '000-' AND RIGHT(rtrim(Shared_Invoice_Number),3) = '-00' THEN ltrim(rtrim(Shared_Invoice_Number))
						ELSE ''
					END
					AS Member_Billback_Reference ---SPEC LOGIC
				,CASE 
					WHEN LEFT(Shared_Invoice_Number,4) = '000-' AND RIGHT(rtrim(Shared_Invoice_Number),3) = '-00' THEN ISNULL(BSAO.Operator_Name,'')+'_'+CONVERT(VARCHAR(10),ISNULL(BA.Date_Approved,getDate()), 101)--Could use a (SELECT FROM...here?)
							ELSE ''
					END 
					AS Reason_For_Deduction ---SPEC LOGIC
				,'' AS Ship_to_Address
				,'' AS Ship_to_City
				,'' AS Ship_to_State
				,'' AS CaRMA
				-- NOT IN SPEC FROM HERE DOWN
				,'' AS Unit_Price	--Unit Price
				,'' AS Product	--Product
				,'' AS Internal_Vendor_Number	--Internal Vendor Number (ReDistributors Only
				,'' AS Man_Item_Num_Redist	--Manufacturers Item  (ReDistributors Only)
				,'' AS Man_Name_ReDist	--Manufacturers Name (ReDistributors Only)
							
						FROM BB_Auto_Report R
							INNER JOIN BB_Auto_Report_Period RP ON
								R.BB_Auto_Report_Period_ID = RP.BB_Auto_Report_Period_ID
							INNER JOIN BB_Auto_Report_Export_Header ExH ON
								ExH.BB_Auto_Report_ID = R.BB_Auto_Report_ID
							INNER JOIN BB_Auto_Report_Export_BB_Header ExBBH ON
								ExBBH.Export_Header_ID = ExH.Export_Header_ID
							INNER JOIN BB_Auto_Report_Export_BB_Detail ExBBD ON
								ExBBH.Export_Header_ID = ExBBD.Export_Header_ID AND
								ExBBH.BB_Header_ID = ExBBD.BB_Header_ID
							INNER JOIN Contract_Main CM ON
								CM.Contract_Main_ID = ExBBH.Contract_Main_ID
							INNER JOIN BSA_Foodservice_Items_Master IM ON
								IM.BSA_Foodservice_Items_Master_ID = ExBBD.Product_ID
							INNER JOIN Invoice_Detail ID ON
								ID.Invoice_Detail_Id = ExBBD.Invoice_Detail_Id
							LEFT JOIN Brand B ON
								B.Brand_ID = IM.Brand_ID
							LEFT JOIN Billback_Distributor BD ON
								BD.Billback_ID = ExBBH.Billback_ID
							LEFT JOIN BSA_Foodservice_Customers BFC ON
								BFC.BSA_Foodservice_Customers_ID = BD.Distributor_ID
							OUTER APPLY
							(
								SELECT  TOP 1	XREF2.Unipro_Num
												,XREF2.Loc
												,XREF2.External_Code
												,XREF2.External_Description
								FROM    BB_Claim_Dist_XREF XREF2
								WHERE   XREF2.Source_Code = 'UNIPRO_450' AND
										XREF2.Shipto = ExBBH.Shr_Ship_To
							) XREF
							LEFT JOIN Billback BB_Opr ON
								LEFT(Shared_Invoice_Number,4) = '000-' AND 
								RIGHT(rtrim(Shared_Invoice_Number),3) = '-00' AND
								BB_Opr.BB_Code = Shared_Invoice_Number
							LEFT JOIN BB_Approved BA ON
								BA.Billback_ID = BB_Opr.Billback_ID
							LEFT JOIN Billback_Operator BO ON
								BO.Billback_ID = BB_Opr.Billback_ID AND
								BO.Billback_Operator_ID = (SELECT Top 1 Billback_Operator_ID FROM Billback_Operator BO2 WHERE BO2.Billback_ID = BB_Opr.Billback_ID)
							LEFT JOIN BSA_Operator BSAO ON
								ISNULL(BSAO.Eshark_RecordID,'') = CAST(BO.Operator_ID as varchar(35))
							LEFT JOIN Distributor_Family DF ON
								DF.Family_ID = BFC.Family_ID
							LEFT JOIN Distributor_Buying_Groups DBG ON
								DBG.Buying_Group_ID = BFC.Buying_Group_ID
							LEFT JOIN Units_Of_Measure UOM On
								UOM.Unit_Of_Measure_id = ExBBD.Discount_UOM
						WHERE R.BB_Auto_Report_ID = <cfqueryparam value="#arguments.ReportId#" /> 
						ORDER BY CM.Contract_Number
			</CFQUERY>
		<cfreturn qGetReportSummary />
	</cffunction>  

<!--- XXXXXXXXXXXX	getGrowthCalcExist	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getGrowthCalcExist" access="remote" returntype="boolean">
		<cfargument name="ReportId"	required="no" type="any" default="0" />
		<cfset var qGetGrowthCalc = "" />		
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetGrowthCalc">
				SELECT	1 as Growth_Calc_Exist
				FROM	BB_Auto_Report R
				INNER JOIN BB_Auto_Program_Pay_Period PP
				ON		PP.BB_Auto_Report_id = R.BB_Auto_Report_ID
				AND		PP.Deleted = 0
				INNER JOIN BB_Auto_Growth_Calc GC
				ON		GC.BB_Auto_Program_Pay_Period_ID = PP.BB_Auto_Program_Pay_Period_ID
				WHERE R.BB_Auto_Report_ID = <cfqueryparam value="#arguments.ReportId#" />
			</CFQUERY>
		<cfreturn Val(qGetGrowthCalc.Growth_Calc_Exist) />
	</cffunction>
	
<!--- XXXXXXXXXXXX	getGrowthCalc	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getGrowthCalc" access="remote" returntype="query">
		<cfargument name="ReportId"	required="no" type="any" default="0" />
		<cfset var qGetGrowthCalc = "" />		
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetGrowthCalc">
				SELECT	GC.BB_Auto_Growth_Calc_ID,
						CM.Contract_Number, CM.Contract_Title, B.BB_Code, B.BB_Title, 
						GC.Distributor_ID_Paid,
						COALESCE(pg.PG_Customer_Category_Code, c.Shr_Ship_To, vm.Vendor_ID) as Payee_ID, 
						COALESCE(pg.PG_Customer_Category_Name, c.Name, vm.Vendor_Name) as Payee_Name,
						Original_Component_UOM, Component_UOM, UOM.Abbreviation as Component_UOM_Desc,
						Tier_Attained, Override_Tier_Attained,
						ISNULL(Override_Tier_Attained, Tier_Attained) as Selected_Tier,
						ISNULL(GC.Component_Total, 0) as Component_Total,
						ISNULL(GC.Last_Year_Total, 0) as Last_Year_Total,
						T.Tier_Number, T.Range_Start, T.Range_End, 
						GT.New_Range_Start, GT.New_Range_End
				FROM	BB_Auto_Report R
				INNER JOIN BB_Auto_Program_Pay_Period PP
				ON		PP.BB_Auto_Report_id = R.BB_Auto_Report_ID
				AND		PP.Deleted = 0
				INNER JOIN Contract_Main CM
				ON		CM.Contract_Main_ID = PP.Program_ID
				INNER JOIN BB_Auto_Growth_Calc GC
				ON		GC.BB_Auto_Program_Pay_Period_ID = PP.BB_Auto_Program_Pay_Period_ID
				LEFT JOIN Billback B
				ON		B.Billback_ID = GC.BillBack_ID
				INNER JOIN BB_Auto_Growth_Tier GT
				ON		GT.BB_Auto_Program_Pay_Period_ID = PP.BB_Auto_Program_Pay_Period_ID
				AND		GT.Distributor_ID_Paid = GC.Distributor_ID_Paid
				INNER JOIN Program_Growth_Component_Tiers T
				ON		T.Program_Growth_Component_Tier_ID = GT.Program_Growth_Component_Tier_ID
				INNER JOIN Units_of_Measure UOM
				ON		UOM.Unit_Of_Measure_ID = Component_UOM
				LEFT JOIN BSA_Foodservice_Customers c
				ON		c.BSA_Foodservice_Customers_ID = GC.Distributor_ID_Paid
				LEFT JOIN Vendor_Master vm
				ON		vm.Vendor_Master_ID = GC.Distributor_ID_Paid
				LEFT JOIN PG_Customer_Category pg
				ON		pg.PG_Customer_Category_ID = GC.Distributor_ID_Paid
				WHERE R.BB_Auto_Report_ID = <cfqueryparam value="#arguments.ReportId#" />
				UNION ALL
				<!---  Dummy record with Tier Number = 0 ---> 
				SELECT	GC.BB_Auto_Growth_Calc_ID,
						CM.Contract_Number, CM.Contract_Title, B.BB_Code, B.BB_Title, 
						GC.Distributor_ID_Paid,
						COALESCE(pg.PG_Customer_Category_Code, c.Shr_Ship_To, vm.Vendor_ID) as Payee_ID, 
						COALESCE(pg.PG_Customer_Category_Name, c.Name, vm.Vendor_Name) as Payee_Name,
						Original_Component_UOM, Component_UOM, UOM.Abbreviation Component_UOM_Desc,
						Tier_Attained, Override_Tier_Attained,
						ISNULL(Override_Tier_Attained, Tier_Attained) as Selected_Tier,
						ISNULL(GC.Component_Total, 0) as Component_Total,
						ISNULL(GC.Last_Year_Total, 0) as Last_Year_Total,
						0 as Tier_Number, null as Range_Start, null as Range_End, 
						null as New_Range_Start, null as New_Range_End
				FROM	BB_Auto_Report R
				INNER JOIN BB_Auto_Program_Pay_Period PP
				ON		PP.BB_Auto_Report_id = R.BB_Auto_Report_ID
				AND		PP.Deleted = 0
				INNER JOIN Contract_Main CM
				ON		CM.Contract_Main_ID = PP.Program_ID
				INNER JOIN BB_Auto_Growth_Calc GC
				ON		GC.BB_Auto_Program_Pay_Period_ID = PP.BB_Auto_Program_Pay_Period_ID
				LEFT JOIN Billback B
				ON		B.Billback_ID = GC.BillBack_ID
				INNER JOIN Units_of_Measure UOM
				ON		UOM.Unit_Of_Measure_ID = Component_UOM
				LEFT JOIN BSA_Foodservice_Customers c
				ON		c.BSA_Foodservice_Customers_ID = GC.Distributor_ID_Paid
				LEFT JOIN Vendor_Master vm
				ON		vm.Vendor_Master_ID = GC.Distributor_ID_Paid
				LEFT JOIN PG_Customer_Category pg
				ON		pg.PG_Customer_Category_ID = GC.Distributor_ID_Paid
				WHERE R.BB_Auto_Report_ID = <cfqueryparam value="#arguments.ReportId#" />
				Order By CM.Contract_Number, B.BB_Code, COALESCE(pg.PG_Customer_Category_Name, c.Name, vm.Vendor_Name), T.Tier_Number
			</CFQUERY>
		<cfreturn qGetGrowthCalc />
	</cffunction>

<!--- XXXXXXXXXXXX	getCanReverse	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getCanReverse" access="public" returntype="boolean">
		<cfargument name="PayPeriodId"	required="no" type="any" default="0" />
		<cfset var qGetBB = "" />
		<cfset var iCanReverse = 1 />
		<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetBB">
			SELECT	DISTINCT B.Billback_Status_ID, B.BB_Payment_Request_Sent, B.BB_Received_Ack_Type
			FROM BB_Auto_Program_Pay_Period PP
			INNER JOIN	BB_Auto_Pay_Period_Billback PBB ON
					PBB.BB_Auto_Program_Pay_Period_Id = PP.BB_Auto_Program_Pay_Period_Id
			INNER JOIN BillBack B ON
					B.Billback_Id = PBB.Billback_Id
		 	WHERE PP.BB_Auto_Program_Pay_Period_id = '#arguments.PayPeriodId#'
		</CFQUERY>
		<cfif qGetBB.RecordCount EQ 0>
			<cfset iCanReverse = 0 />
		</cfif>
		<cfloop query="qGetBB">
			<!--- Cannot reverse if any billback has interfaced and not yet acknowledged --->
			<cfif BB_Payment_Request_Sent EQ 1 AND BB_Received_Ack_Type EQ 0>
				<cfset iCanReverse = 0 />
			</cfif>
		</cfloop>
		<cfreturn iCanReverse />
	</cffunction>
	
	<cffunction name="dmp" >
		<cfargument name="x" type="any" required="true" default="">	
		<cfdump var="#x#" output="c:\dump.log">
	</cffunction>
<!--- END END
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		LEFT HAND NAV		LEFT HAND NAV		LEFT HAND NAV		LEFT HAND NAV		LEFT HAND NAV
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
--->
	<!--- XXXXXXXXXXXX		XXXXXXXXXXXX --->
<!--- 	<cffunction name="" access="public" returntype="string">
	  <cfset var result = "">
	  <cfreturn result>
  	</cffunction> --->
</cfcomponent>