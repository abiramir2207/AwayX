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
		<cfargument name="filters" required="true" hint="A structure of all filters supplied by end-user">

		<!--- remove unwanted white spaces in filtering criteria 48219 --->
		<cfloop collection="#arguments.filters#" item="local.filter">
			<cfset arguments.filters[local.filter] = trim( arguments.filters[local.filter] )>
		</cfloop>
		
		<!--- START: 108967: Autopay access by Segment / Anand Rao / 15-Nov-2021 --->
		<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<cfif  businessSegManager.isEnabled()>
			<cfset Business_Segment_On = 1>
			<cfset UserSegmentFiltersAutopayResults = businessSegManager.getEnabled().User_Segment_Filters_Autopay_Results />
		<cfelse>
			<cfset Business_Segment_On = 0>
			<cfset UserSegmentFiltersAutopayResults = 0>
		</cfif>
		<cfset lsBBAutoReportPeriodID = '' />

		<cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>
			<cfquery datasource="#application.datasource#" name="getAllowedAutoReportIDs">
			SELECT  BB_Auto_Report_Period.BB_Auto_Report_Period_ID
			FROM    BB_Auto_Report_Period
			INNER JOIN BB_Auto_Report
			        ON BB_Auto_Report.BB_Auto_Report_Period_ID = BB_Auto_Report_Period.BB_Auto_Report_Period_ID
			           AND BB_Auto_Report.Deleted = <cfqueryparam value="#arguments.del#">
			LEFT JOIN BB_Auto_Program_Pay_Period
			        ON BB_Auto_Program_Pay_Period.BB_Auto_Report_id = BB_Auto_Report.BB_Auto_Report_ID
			           AND BB_Auto_Program_Pay_Period.Deleted = <cfqueryparam value="#arguments.del#">
			LEFT JOIN _Users
			        ON _Users.User_ID = IsNull(BB_Auto_Report.approved_user_id, BB_Auto_Report.updated_User_id)
			           AND BB_Auto_Report.updated_User_id IS NOT NULL
			LEFT JOIN BB_Auto_Pay_Period_Billback
			        ON BB_Auto_Pay_Period_Billback.BB_Auto_Program_Pay_Period_Id = BB_Auto_Program_Pay_Period.BB_Auto_Program_Pay_Period_ID
			LEFT JOIN Billback
			        ON Billback.Billback_ID = BB_Auto_Pay_Period_Billback.Billback_Id
			           AND Billback.Deleted = 0
			LEFT JOIN BB_Approved
			        ON BB_Approved.Billback_ID = Billback.Billback_ID
	
			LEFT JOIN Contract_Main CM ON CM.Contract_Main_ID = BB_Auto_Program_Pay_Period.Program_ID AND CM.Deleted = 0
			-- LEFT JOIN Billback_Program BP ON BP.Billback_ID = B.Billback_ID 
		 	LEFT JOIN User_Business_Segment UBS ON UBS.Business_Segment_ID = CM.Business_Segment_ID 
		 	LEFT JOIN Business_Segment BS ON BS.Business_Segment_ID = UBS.Business_Segment_ID
		 	LEFT JOIN _users u2 ON u2.User_ID = UBS.User_ID
		 
		<cfif arguments.filters.distributor neq "" or arguments.filters.family neq "">
	        LEFT JOIN Billback_Distributor_List
	                ON Billback_Distributor_List.Billback_ID = Billback.Billback_ID
	                   AND Billback_Distributor_List.Deleted = 0
	        LEFT JOIN BSA_Foodservice_Customers
	                ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Distributor_List.Distributor_ID
		</cfif>
		<cfif arguments.filters.operator neq "">
	        LEFT JOIN dbo.Billback_Operator
	                ON Billback_Operator.Billback_ID = Billback.Billback_ID
	                   AND Billback_Operator.Deleted = 0
	        LEFT JOIN dbo.BSA_Operator
	                ON BSA_Operator.BSA_Operator_ID = Billback_Operator.Operator_ID
					AND BSA_Operator.Deleted = 0
		</cfif>
		<cfif arguments.filters.vendor neq "">		
			LEFT JOIN dbo.Vendor_Master
			ON Vendor_Master.Vendor_Master_ID = BB_Approved.Vendor_Master_ID
		</cfif>
		<cfif arguments.filters.program_number neq "">	
			LEFT JOIN dbo.Contract_Main
			ON Contract_Main.Contract_Main_ID = BB_Auto_Program_Pay_Period.Program_ID
		</cfif>
				WHERE   BB_Auto_Report_Period.end_date < GetDate()
			        AND CAST(BB_Auto_Report.created_date AS DATE) >= <cfqueryparam value="#arguments.filters.from_date#" cfsqltype="cf_sql_date">
			        AND CAST(BB_Auto_Report.created_date AS DATE) <= <cfqueryparam value="#arguments.filters.to_date#"   cfsqltype="cf_sql_date">
					<cfif arguments.del eq 0>
			        AND BB_Auto_Program_Pay_Period.Status != 9<!--- 9 is deleted --->
					AND u2.User_ID = '#request.accessStructure.User_Id#' 
					AND UBS.deleted = 0
					</cfif>
			        <cfif arguments.filters.distributor neq "">
						AND (    BSA_Foodservice_Customers.Ship_To LIKE <cfqueryparam value="%#arguments.filters.distributor#%">
								OR BSA_Foodservice_Customers.Name   LIKE <cfqueryparam value="%#arguments.filters.distributor#%"> 
								OR BSA_Foodservice_Customers.Shr_Ship_To LIKE <cfqueryparam value="%#arguments.filters.distributor#%"> )
					</cfif>
			        <cfif arguments.filters.operator neq "">
						AND (    BSA_Operator.Legacy_ID     LIKE <cfqueryparam value="%#arguments.filters.operator#%">
							  OR BSA_Operator.Operator_Name LIKE <cfqueryparam value="%#arguments.filters.operator#%"> )
					</cfif>
					<cfif arguments.filters.family neq "">
						AND BSA_Foodservice_Customers.Family_Name LIKE <cfqueryparam value="%#arguments.filters.family#%">
					</cfif>
			        <cfif arguments.filters.autopay_status neq "">
						AND BB_Auto_Report.Status IN ( <cfqueryparam value="#arguments.filters.autopay_status#" list="yes"> )
					</cfif>
					<cfif arguments.filters.payable_number neq "">
						AND (Billback.BB_Code LIKE <cfqueryparam value="%#arguments.filters.payable_number#%">
							OR Billback.BB_Title LIKE <cfqueryparam value="%#arguments.filters.payable_number#%">)
					</cfif>
			        <cfif arguments.filters.updated_by neq "">
						AND _Users.user_code = <cfqueryparam value="#arguments.filters.updated_by#">
					</cfif>
					<cfif arguments.filters.vendor neq "">	
						AND (Vendor_Master.Vendor_Name LIKE <cfqueryparam value="%#arguments.filters.vendor#%">
						OR Vendor_Master.Vendor_ID LIKE <cfqueryparam value="%#arguments.filters.vendor#%">)
					</cfif>
					<cfif arguments.filters.program_number neq "">	
						AND (Contract_Main.Contract_Number LIKE <cfqueryparam value="%#arguments.filters.program_number#%">
							OR Contract_Main.Contract_Title LIKE <cfqueryparam value="%#arguments.filters.program_number#%">)
					</cfif>
					<cfif arguments.filters.report_search neq "">	
						AND 
						(
						BB_Auto_Report.Report_Title LIKE <cfqueryparam value="%#arguments.filters.report_search#%">
						<cfif IsNumeric(arguments.filters.report_search)>
						OR
						BB_Auto_Report.BB_Auto_Report_ID = <cfqueryparam value="#arguments.filters.report_search#">
						</cfif>
						)
					</cfif>
					<cfif arguments.filters.invoice_number neq "">
						<cfif arguments.filters.invoice_number_exact_search eq 1>
						/* AND IH.Order_Number = '#arguments.filters.invoice_number#' */
						AND EXISTS (
	                                         SELECT 1
	                                         FROM   BB_Auto_Accrual_LOG L 
	                                         INNER JOIN Invoice_Header IH ON IH.Invoice_Header_ID = L.Invoice_Header_ID
	                                         WHERE  L.BB_ID = BB_Auto_Pay_Period_Billback.Billback_Id
	                                         AND IH.Order_Number = '#arguments.filters.invoice_number#'
	                                  )
	
						<cfelseif arguments.filters.invoice_number_exact_search eq 0>
						/* AND IH.Order_Number LIKE '%#arguments.filters.invoice_number#%' */
						AND EXISTS (
	                                         SELECT 1
	                                         FROM   BB_Auto_Accrual_LOG L 
	                                         INNER JOIN Invoice_Header IH ON IH.Invoice_Header_ID = L.Invoice_Header_ID
	                                         WHERE  L.BB_ID = BB_Auto_Pay_Period_Billback.Billback_Id
	                                         AND IH.Order_Number LIKE '%#arguments.filters.invoice_number#%'
	                                  )
						
						</cfif>
					</cfif>
			
			GROUP BY BB_Auto_Report_Period.BB_Auto_Report_Period_ID
			      /* ,BB_Auto_Report.BB_Auto_Report_ID
			       ,BB_Auto_Report.Is_Manual
			       ,Pause_Schedule
			       ,BB_Auto_Report.updated_date
			       ,BB_Auto_Report.Report_Title
			       ,BB_Auto_Report_Period.start_date
			       ,BB_Auto_Report_Period.end_date
			       ,BB_Auto_Report.status
			       ,_Users.User_Code*/
			ORDER BY BB_Auto_Report_Period.BB_Auto_Report_Period_ID DESC
			</cfquery>
			
			<cfset lsBBAutoReportPeriodID = ValueList(getAllowedAutoReportIDs.BB_Auto_Report_Period_ID) />
		</cfif>
		
	<!--- END: 108967: Autopay access by Segment / Anand Rao / 15-Nov-2021 --->
			
		<cfquery datasource="#application.datasource#" name="local.query">
		SELECT  BB_Auto_Report_Period.BB_Auto_Report_Period_ID
		       ,IsNull(BB_Auto_Report.BB_Auto_Report_ID, 0) AS BB_Auto_Report_id
		       ,BB_Auto_Report.Is_Manual
		       ,IsNull(BB_Auto_Report.Pause_Schedule, 0) AS Pause_Schedule
		       ,(
		          SELECT    Max(BB_Auto_Report_Period_ID)
		          FROM      BB_Auto_Report_Period ) AS current_id
		       ,IsNull(BB_Auto_Report.status, 0) AS status
		       ,BB_Auto_Report.updated_date
		       ,BB_Auto_Report.Report_Title
		       ,BB_Auto_Report_Period.start_date
		       ,BB_Auto_Report_Period.end_date
		       ,_Users.User_Code
		       ,IsNull(Count(DISTINCT BB_Auto_Program_Pay_Period.Program_ID), 0) AS Program_Count
		       ,IsNull(Count(DISTINCT BB_Auto_Pay_Period_Billback.Billback_Id), 0) AS Billback_Count
		       ,Max(BB_Auto_Program_Pay_Period.Status) AS BBStatus
		       ,IsNull(Sum(BB_Approved.Paid_Amount), 0) AS BB_Amount
		       ,CASE BB_Auto_Report.status
		          WHEN -1 THEN 'New'
		          WHEN 1 THEN 'Scheduled'
		          WHEN 2 THEN 'Scheduled for recalc'
		          WHEN 3 THEN 'RFA'
		          WHEN 4 THEN 'Approved'
		        END AS Status_Desc,
			IsNull(Sum(Billback.BB_Amount), 0) AS Gross_Amount,
			IsNull(Sum(BB_Approved.Paid_Amount), 0) AS Net_Amount				
		FROM    BB_Auto_Report_Period
		INNER JOIN BB_Auto_Report
		        ON BB_Auto_Report.BB_Auto_Report_Period_ID = BB_Auto_Report_Period.BB_Auto_Report_Period_ID
		           AND BB_Auto_Report.Deleted = <cfqueryparam value="#arguments.del#">
		LEFT JOIN BB_Auto_Program_Pay_Period
		        ON BB_Auto_Program_Pay_Period.BB_Auto_Report_id = BB_Auto_Report.BB_Auto_Report_ID
		           AND BB_Auto_Program_Pay_Period.Deleted = <cfqueryparam value="#arguments.del#">
		LEFT JOIN _Users
		        ON _Users.User_ID = IsNull(BB_Auto_Report.approved_user_id, BB_Auto_Report.updated_User_id)
		           AND BB_Auto_Report.updated_User_id IS NOT NULL
		LEFT JOIN BB_Auto_Pay_Period_Billback
		        ON BB_Auto_Pay_Period_Billback.BB_Auto_Program_Pay_Period_Id = BB_Auto_Program_Pay_Period.BB_Auto_Program_Pay_Period_ID
		LEFT JOIN Billback
		        ON Billback.Billback_ID = BB_Auto_Pay_Period_Billback.Billback_Id
		           AND Billback.Deleted = 0
		LEFT JOIN BB_Approved
		        ON BB_Approved.Billback_ID = Billback.Billback_ID

	<!--- <cfif arguments.filters.invoice_number neq "">
		LEFT JOIN BB_Auto_Accrual_LOG L ON 
			   L.BB_ID = BB_Auto_Pay_Period_Billback.Billback_Id
		LEFT JOIN Invoice_Header IH ON
			   IH.Invoice_Header_ID = L.Invoice_Header_ID
	</cfif> --->

	<cfif arguments.filters.distributor neq "" or arguments.filters.family neq "">
        LEFT JOIN Billback_Distributor_List
                ON Billback_Distributor_List.Billback_ID = Billback.Billback_ID
                   AND Billback_Distributor_List.Deleted = 0
        LEFT JOIN BSA_Foodservice_Customers
                ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Distributor_List.Distributor_ID
	</cfif>
	<cfif arguments.filters.operator neq "">
        LEFT JOIN dbo.Billback_Operator
                ON Billback_Operator.Billback_ID = Billback.Billback_ID
                   AND Billback_Operator.Deleted = 0
        LEFT JOIN dbo.BSA_Operator
                ON BSA_Operator.BSA_Operator_ID = Billback_Operator.Operator_ID
				AND BSA_Operator.Deleted = 0
	</cfif>
	<cfif arguments.filters.vendor neq "">		
		LEFT JOIN dbo.Vendor_Master
		ON Vendor_Master.Vendor_Master_ID = BB_Approved.Vendor_Master_ID
	</cfif>
	<cfif arguments.filters.program_number neq "">	
		LEFT JOIN dbo.Contract_Main
		ON Contract_Main.Contract_Main_ID = BB_Auto_Program_Pay_Period.Program_ID
	</cfif>
			WHERE   BB_Auto_Report_Period.end_date < GetDate()
		        AND CAST(BB_Auto_Report.created_date AS DATE) >= <cfqueryparam value="#arguments.filters.from_date#" cfsqltype="cf_sql_date">
		        AND CAST(BB_Auto_Report.created_date AS DATE) <= <cfqueryparam value="#arguments.filters.to_date#"   cfsqltype="cf_sql_date">
				<cfif arguments.del eq 0>
		        AND BB_Auto_Program_Pay_Period.Status != 9<!--- 9 is deleted --->
				</cfif>
		        <cfif arguments.filters.distributor neq "">
					AND (    BSA_Foodservice_Customers.Ship_To LIKE <cfqueryparam value="%#arguments.filters.distributor#%">
							OR BSA_Foodservice_Customers.Name   LIKE <cfqueryparam value="%#arguments.filters.distributor#%"> 
							OR BSA_Foodservice_Customers.Shr_Ship_To LIKE <cfqueryparam value="%#arguments.filters.distributor#%"> )
				</cfif>
		        <cfif arguments.filters.operator neq "">
					AND (    BSA_Operator.Legacy_ID     LIKE <cfqueryparam value="%#arguments.filters.operator#%">
						  OR BSA_Operator.Operator_Name LIKE <cfqueryparam value="%#arguments.filters.operator#%"> )
				</cfif>
				<cfif arguments.filters.family neq "">
					AND BSA_Foodservice_Customers.Family_Name LIKE <cfqueryparam value="%#arguments.filters.family#%">
				</cfif>
		        <cfif arguments.filters.autopay_status neq "">
					AND BB_Auto_Report.Status IN ( <cfqueryparam value="#arguments.filters.autopay_status#" list="yes"> )
				</cfif>
				<cfif arguments.filters.payable_number neq "">
					AND (Billback.BB_Code LIKE <cfqueryparam value="%#arguments.filters.payable_number#%">
						OR Billback.BB_Title LIKE <cfqueryparam value="%#arguments.filters.payable_number#%">)
				</cfif>
		        <cfif arguments.filters.updated_by neq "">
					AND _Users.user_code = <cfqueryparam value="#arguments.filters.updated_by#">
				</cfif>
				<cfif arguments.filters.vendor neq "">	
					AND (Vendor_Master.Vendor_Name LIKE <cfqueryparam value="%#arguments.filters.vendor#%">
					OR Vendor_Master.Vendor_ID LIKE <cfqueryparam value="%#arguments.filters.vendor#%">)
				</cfif>
				<cfif arguments.filters.program_number neq "">	
					AND (Contract_Main.Contract_Number LIKE <cfqueryparam value="%#arguments.filters.program_number#%">
						OR Contract_Main.Contract_Title LIKE <cfqueryparam value="%#arguments.filters.program_number#%">)
				</cfif>
				<cfif arguments.filters.report_search neq "">	
					AND 
					(
					BB_Auto_Report.Report_Title LIKE <cfqueryparam value="%#arguments.filters.report_search#%">
					<cfif IsNumeric(arguments.filters.report_search)>
					OR
					BB_Auto_Report.BB_Auto_Report_ID = <cfqueryparam value="#arguments.filters.report_search#">
					</cfif>
					)
				</cfif>
				<cfif arguments.filters.invoice_number neq "">
					<cfif arguments.filters.invoice_number_exact_search eq 1>
					/* AND IH.Order_Number = '#arguments.filters.invoice_number#' */
					AND EXISTS (
                                         SELECT 1
                                         FROM   BB_Auto_Accrual_LOG L 
                                         INNER JOIN Invoice_Header IH ON IH.Invoice_Header_ID = L.Invoice_Header_ID
                                         WHERE  L.BB_ID = BB_Auto_Pay_Period_Billback.Billback_Id
                                         AND IH.Order_Number = '#arguments.filters.invoice_number#'
                                  )

					<cfelseif arguments.filters.invoice_number_exact_search eq 0>
					/* AND IH.Order_Number LIKE '%#arguments.filters.invoice_number#%' */
					AND EXISTS (
                                         SELECT 1
                                         FROM   BB_Auto_Accrual_LOG L 
                                         INNER JOIN Invoice_Header IH ON IH.Invoice_Header_ID = L.Invoice_Header_ID
                                         WHERE  L.BB_ID = BB_Auto_Pay_Period_Billback.Billback_Id
                                         AND IH.Order_Number LIKE '%#arguments.filters.invoice_number#%'
                                  )
					
					</cfif>
				</cfif>
				<cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>
					AND BB_Auto_Report_Period.BB_Auto_Report_Period_ID in (#lsBBAutoReportPeriodID#)
				</cfif>	
		GROUP BY BB_Auto_Report_Period.BB_Auto_Report_Period_ID
		       ,BB_Auto_Report.BB_Auto_Report_ID
		       ,BB_Auto_Report.Is_Manual
		       ,Pause_Schedule
		       ,BB_Auto_Report.updated_date
		       ,BB_Auto_Report.Report_Title
		       ,BB_Auto_Report_Period.start_date
		       ,BB_Auto_Report_Period.end_date
		       ,BB_Auto_Report.status
		       ,_Users.User_Code
		ORDER BY BB_Auto_Report_id DESC
		       ,BB_Auto_Report_Period.end_date DESC
		</cfquery>

		<cfreturn local.query>
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
					DECLARE
					@FY AS VARCHAR(7),
					@Last_Fiscal_Start DateTime,
					@Last_Fiscal_End DateTime,
					@GracePeriod INT,
					@BB_Auto_Report_Period_ID INT
					SET @BB_Auto_Report_Period_ID = 0

					SELECT @GracePeriod = Auto_Claim_Buffer
					FROM _Application_Settings

									--get most recent fiscal period end_date > app setting @GracePeriod datys in the PAST
									SELECT TOP 1 @FY = Fiscal_Year,
											@Last_Fiscal_End = End_Date,
											@Last_Fiscal_Start = Start_Date
									FROM Fiscal_Year
									WHERE	End_Date <= (dateadd(day, -@GracePeriod, GetDate())) AND
											Deleted = 0
									ORDER BY End_Date DESC

									SELECT	@BB_Auto_Report_Period_ID = BB_Auto_Report_Period_Id
									FROM BB_Auto_Report_Period
									WHERE End_Date = @Last_Fiscal_End  + '23:59:59' AND
										 Start_Date = @Last_Fiscal_Start

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
					WHERE -- p2.end_date < @Last_Fiscal_End AND
						p2.end_date > dateadd(mm,-12,GetDate()) AND
						p2.bb_auto_report_period_id = @BB_Auto_Report_Period_ID
						AND Pay.Deleted = 0
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
						<cfif This.getAutoPayType() EQ 2>
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
					onclick="document.getElementById('lockReport').setAttribute('disabled','disabled');"
					href="/billbacks/auto_bb_report/index.cfm?Disp=view&PageTitle=PAYABLES: Auto Pay Report Maintenance&Lck=0">
			  			<img src="/images/edit_mode.gif" align="middle" border="0" />
				</a>
			  <cfelse>
			    Locked By #this.getReportLockInfo().Name_Last#
			  </cfif>
			<cfelse>
				<a  id="lockReport"
					title="Click To Lock"
					onclick="document.getElementById('lockReport').setAttribute('disabled','disabled');"
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
	
	<cfset  genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset  appSettings = genSettingsManager.get()>
	
		<cfset var qGetReportBB = "" />
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetReportBB">
				SELECT max(PP.BB_Auto_Program_Pay_Period_id) AS BB_Auto_Program_Pay_Period_id,
					COUNT(PP_Appr.BB_Auto_Program_Pay_Period_id) AS Approved
					FROM BB_Auto_Program_Pay_Period PP
					LEFT JOIN BB_Auto_Program_Pay_Period PP_Appr 
					ON PP.BB_Auto_Program_Pay_Period_ID = PP_Appr.BB_Auto_Program_Pay_Period_ID 
					AND	PP_Appr.Status = 4
					INNER JOIN BB_Auto_Pay_Period_Billback PBB 
					ON PBB.BB_Auto_Program_Pay_Period_Id = PP.BB_Auto_Program_Pay_Period_Id
				<cfif appSettings.get_Setting('BB_Auto_Pay_enable_BB_Number') eq '1' OR appSettings.get_Setting('BB_Auto_Pay_enable_Ref_Number') eq '1'>
					INNER JOIN BILLBACK B
					ON B.Billback_ID = PP.BillBack_ID
				<cfif appSettings.get_Setting('BB_Auto_Pay_enable_BB_Number') eq '1' >
					AND len(B.BB_Reference) > 0
				</cfif>
				<cfif appSettings.get_Setting('BB_Auto_Pay_enable_Ref_Number') eq '1'>
					AND len(B.referenceNum) > 0
				</cfif>
				</cfif>
					WHERE pp.bb_auto_Report_id = '#arguments.reportId#'
					AND PP.deleted = 0
					group by PP.BB_Auto_Program_Pay_Period_id,PP_Appr.BB_Auto_Program_Pay_Period_ID
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
						B.Billback_Id,
						B.BB_Reference
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
						SUM(isnull(BA.Paid_Amount, 0)) AS BB_Amount,
						SUM(isnull(BA.Paid_Amount, 0)) AS Net_Amount,
						SUM(isnull(B.BB_Amount, 0)) AS Gross_Amount,
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
						IsNull(BO.Operator_name,
						IsNull(BFC.Name,IsNull(BRO.Broker_Name,
						ISNull(VM.Vendor_Name,'NA')))) as Vendor_Name,
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
						ORDER BY Vendor_Name ASC, BB_Amount DESC
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
		SELECT DISTINCT Program_ID
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

		<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<cfif  businessSegManager.isEnabled()>
			<cfset Business_Segment_On = 1>
			<cfset UserSegmentFiltersAutopayResults = businessSegManager.getEnabled().User_Segment_Filters_Autopay_Results />
		<cfelse>
			<cfset Business_Segment_On = 0>
			<cfset UserSegmentFiltersAutopayResults = 0>
		</cfif>		
		
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetBBDetails">
				SELECT	U.Name_first AS First,
						U.Name_Last AS Last,
						isnull(B.BB_Code,'ReCalc') as BB_code,
						<cfif Summary EQ 1>
							B.Billback_Id,
							isnull(sum(B.BB_Amount),'') as BB_Amount,
							SUM(isnull(BB_Approved.Pullback_Applied_Amount, 0)) as Pullback_Applied_Amount,
						<cfelse>
							B.BB_Title,
							B.Billback_Id,
							isnull(B.BB_Amount,'') as BB_Amount,
							isnull(BB_Approved.Pullback_Applied_Amount, 0) as Pullback_Applied_Amount,
							isnull(BB_Approved.Paid_Amount, 0) AS Net_Amount,
						</cfif>
						PP.BB_Auto_Program_Pay_Period_Id,
						PP.Updated_Date,
						PP.Status as BBStatus,
						CONVERT(CHAR(10), PP.Payment_Start_Date, 101) As Payment_Start_Date,
						CONVERT(CHAR(10), PP.Payment_End_Date, 101) As Payment_End_Date,
						R.status as ReportStatus,
						C.Contract_Number,
						ISNULL(BFC.Name, VM.Vendor_Name) as Name,
						ISNULL(BFC.Ship_To, VM.Vendor_ID) as Ship_To,
						PC.Payment_Cycle,
						PP.Discount_Type_Id,
						PP.BB_Auto_Report_id,
						B.Billback_Id,
						B.BB_Reference,
						B.referenceNum
						<cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>
						,(SELECT Business_Segment_ID FROM User_Business_Segment WHERE Business_Segment_ID = C.Business_Segment_ID AND User_ID = '#request.accessStructure.User_Id#' AND deleted = 0) AS User_Business_segment_ID
						</cfif>
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
					LEFT JOIN Payment_Cycle PC ON
						PC.Payment_Cycle_ID = PP.Payment_Cycle_Id
				 	WHERE PP.BB_Auto_Program_Pay_Period_id = '#arguments.PayPeriodId#'
				 	<cfif Summary EQ 1>
					 	GROUP BY
						 	U.Name_first,
							U.Name_Last,
							B.BB_Code,
							B.Billback_Id,
							B.BB_Reference,
							B.referenceNum,
							PP.BB_Auto_Program_Pay_Period_Id,
							PP.Updated_Date,
							PP.Status,
							R.status,
							C.Contract_Number,
							ISNULL(BFC.Name, VM.Vendor_Name),
							ISNULL(BFC.Ship_To, VM.Vendor_ID),
							PP.Payment_Start_Date,
							PP.Payment_End_Date,
							PC.Payment_Cycle,
							PP.Discount_Type_Id,
							PP.BB_Auto_Report_id
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
<!--- XXXXXXXXXXXX	getApprovedPayPeriodCount	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getApprovedPayPeriodCount" access="public" returntype="Numeric">
		<cfargument name="ID" required="no" type="numeric" default="0" />
		<cfset var qGetApprovedPayPeriodCount = "" />
		<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetApprovedPayPeriodCount">
			SELECT COUNT(BB_Auto_Program_Pay_Period_Id) AS Num
			FROM BB_Auto_Program_Pay_Period
			WHERE BB_Auto_Report_id = #ID# AND
				Status = 4
		</CFQUERY>
		<cfreturn qGetApprovedPayPeriodCount.Num />
	</cffunction>
<!--- XXXXXXXXXXXX	get report status: returns a description for display	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getReportStatus" access="public" returntype="string">
		<cfargument name="status" required="yes" type="numeric" />
		<cfargument name="pause" required="no" type="any" default="0" />
		<cfargument name="ID" required="no" type="numeric" default="0" />
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
				<cfset approved =  this.getApprovedPayPeriodCount(ID)/>
				<cfif approved GT 0>
					<cfset result = "RFA (#approved# Approved Pay Periods)" />
				</cfif>
			</cfcase>
			<cfcase value="4">
				<cfset result = "Approved" />
			</cfcase>
		</cfswitch>
		<cfreturn result />
  	</cffunction>

<!--- XXXXXXXXXXXX	Get available action	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getAction" access="public">
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
		<cfset var IsAnAutoPayExceptionReport = 0>

		<cfif NOT structKeyExists(application,"oBBReportGet")>
			<cfset application.oBBReportAjaxCaller = CreateObject("component","components.Billback.BBAutoReportAjaxCaller").init() />
			<cfset application.oBBReportGet = CreateObject("component","components.Billback.BBAutoReportGet").init() />
			<cfset application.oBBReportUpdate = CreateObject("component","components.Billback.BBAutoReportUpdate").init() />
			<cfset application.oBBReportPeriod = CreateObject("component","components.Billback.BB_Auto_Report_Period") />
			<cfset application.oBBReportPeriodGateway = CreateObject("component","components.Billback.BB_Auto_Report_PeriodGateway") />
		</cfif>
	  	<!--- request.auto_pay is defined in layout.cfm --->
		<cfif NOT isDefined("request.auto_pay.editing_by_me")>
		 	<cfscript>
				request.auto_pay = { editing_by_me = 0,
                                    lock = This.getReportLockInfo()
                         			};
				if (request.auto_pay.lock.processing eq 0 and  request.auto_pay.lock.locked and request.auto_pay.lock.Locked_By_User_Id eq request.accessStructure.User_Id) {
        			request.auto_pay.editing_by_me = 1;			 
				}
			</cfscript>
		</cfif>
	  	<cfscript>
			locked      = request.auto_pay.editing_by_me;
			linkEnabled = locked and (request.auto_pay.lock.processing eq 0);
		</cfscript>

		<cfset IsAnAutoPayExceptionReport = This.getIsAnAutoPayExceptionReport(arguments.reportId)>

		<cfset local.actions = ["", "", "", "", ""]>	<!--- 48219 --->
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
						<cfif This.getAutoPayType(arguments.isManual) EQ 2 AND this.getReportLockByMe(request.accessStructure.User_Id) EQ 1 AND linkEnabled>
							<cfsavecontent variable="local.action"><a href="/billbacks/Auto_BB_Report/BB_Auto_Report_Create_Report.cfm?action=edit&disp=CreatePeriod&Report_ID=#arguments.reportId#&create_exception=#IsAnAutoPayExceptionReport#"><img src="/Images/edit.gif" title="edit this report" border="0"></a></cfsavecontent>
							<cfset local.actions[2] = local.action>
						</cfif>
						<cfif This.getAutoPayType(arguments.isManual) EQ 2 AND linkEnabled>
							<cfsavecontent variable="local.action"><a href="##" id="runReport#arguments.reportId#" onclick="run_report(#arguments.reportId#)"><img src="/Images/Green_Play.jpg" title="run this report only" border="0"></a></cfsavecontent>
							<cfset local.actions[3] = local.action>
							<cfsavecontent variable="local.action"><a class2="popup" href="/billbacks/Auto_BB_Report/BB_Auto_Report_Create_Report.cfm?action=copy&disp=CreatePeriod&Report_ID=#arguments.reportId#&create_exception=#IsAnAutoPayExceptionReport#" ><img src="/Images/copy.png" title="copy this report" border="0"></a></cfsavecontent>
							<cfset local.actions[4] = local.action>
						</cfif>
						<cfset local.actions[5] = cancelLink>
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
						<cfset local.actions[2] = viewLink>
						<cfif This.getAutoPayType(arguments.isManual) EQ 2 AND linkEnabled>
							<cfsavecontent variable="local.action"><a href="##" onclick="run_report(#arguments.reportId#)"><img src="/Images/Green_Play.jpg" title="run this report only" border="0"></a></cfsavecontent>
							<cfset local.actions[3] = local.action>
							<cfsavecontent variable="local.action"><a class2="popup" href="/billbacks/Auto_BB_Report/BB_Auto_Report_Create_Report.cfm?action=copy&disp=CreatePeriod&Report_ID=#arguments.reportId#&create_exception=#IsAnAutoPayExceptionReport#" ><img src="/Images/copy.png" title="copy this report" border="0"></a></cfsavecontent>
							<cfset local.actions[4] = local.action>
						</cfif>
						<cfset local.actions[5] = pauseLink>
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

						<cfset local.actions[1] = approveLink>
						<cfset local.actions[2] = viewLink>
						<cfif This.getAutoPayType(arguments.isManual) EQ 2 AND linkEnabled>
							<cfsavecontent variable="local.action"><a class2="popup" href="/billbacks/Auto_BB_Report/BB_Auto_Report_Create_Report.cfm?action=copy&disp=CreatePeriod&Report_ID=#arguments.reportId#&create_exception=#IsAnAutoPayExceptionReport#" ><img src="/Images/copy.png" title="copy this report" border="0"></a></cfsavecontent>
							<cfset local.actions[4] = local.action>
						</cfif>
						<cfset local.actions[5] = deleteLink>
					</cfcase>
					<cfcase value="3.5"> <!--- RFA Status (W/approved pay periods)--->
							<!--- approve --->
							<cfset approveLink = this.getActionLink(reportId	= arguments.reportId,
																periodId	= arguments.periodId,
																action		= 'approve') />
							<!--- view --->
							<cfset viewLink = this.getActionLink(reportId	= arguments.reportId,
																periodId	= arguments.periodId,
																action		= 'view') />
							<!--- delete --->
							<!--- <cfset deleteLink = this.getActionLink(reportId	= arguments.reportId,
																periodId	= arguments.periodId,
																action		= 'delete') /> --->
								<cfset local.actions[1] = approveLink>
								<cfset local.actions[2] = viewLink>
								<cfif This.getAutoPayType(arguments.isManual) EQ 2 AND linkEnabled>
									<cfsavecontent variable="local.action"><a class2="popup" href="/billbacks/Auto_BB_Report/BB_Auto_Report_Create_Report.cfm?action=copy&disp=CreatePeriod&Report_ID=#arguments.reportId#&create_exception=#IsAnAutoPayExceptionReport#" ><img src="/Images/copy.png" title="copy this report" border="0"></a></cfsavecontent>
									<cfset local.actions[4] = local.action>
								</cfif>
								<cfset local.actions[5] = deleteLink>
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
								<cfset local.actions[2] = viewLink>
								<cfif This.getAutoPayType(arguments.isManual) EQ 2 AND linkEnabled>
									<cfsavecontent variable="local.action"><a class2="popup" href="/billbacks/Auto_BB_Report/BB_Auto_Report_Create_Report.cfm?action=copy&disp=CreatePeriod&Report_ID=#arguments.reportId#&create_exception=#IsAnAutoPayExceptionReport#" ><img src="/Images/copy.png" title="copy this report" border="0"></a></cfsavecontent>
									<cfset local.actions[4] = local.action>
								</cfif>
								<cfset local.actions[5] = deleteLink>
					</cfcase>
					<cfcase value="-1"><!--- New Status--->
							<!--- user will select programs --->
						<cfset cancelLink = this.getActionLink(reportId	= arguments.reportId,
															periodId	= arguments.periodId,
															action		= 'delete') /> <!--- cancel --->
						<cfset addProgLink = this.getActionLink(reportId	= arguments.reportId,
															periodId	= arguments.periodId,
															action		= 'addProg') /> <!--- addProgLink   "this.disabled=disabled;lockLinks();disabledImageZone.style.visibility = 'visible';document.location = ' --->
								<cfset local.actions[2] = addProgLink>
								<cfif This.getAutoPayType(arguments.isManual) EQ 2 AND linkEnabled>
									<cfsavecontent variable="local.action"><a href="##" id="runReport#arguments.reportId#" onclick="run_report(#arguments.reportId#)"><img src="/Images/Green_Play.jpg" title="run this report only" border="0"></a></cfsavecontent>
									<cfset local.actions[3] = local.action>

									<cfsavecontent variable="local.action"><td width="25%" class="NoBorder"><a href="javascript:void(0)" id="createReport#arguments.reportId#" onclick="document.getElementById('createReport#arguments.reportId#').setAttribute('disabled','disabled');lockLinks();disabledImageZone.style.visibility = 'visible';document.location = '/billbacks/Auto_BB_Report/BB_Auto_Report_Create_Report.cfm?action=copy&disp=CreatePeriod&Report_ID=#arguments.reportId#&create_exception=#IsAnAutoPayExceptionReport#'; return false;" ><img src="/Images/copy.png" title="copy this report" border="0"></a></cfsavecontent>
									<cfset local.actions[4] = local.action>
								</cfif>
								<cfset local.actions[5] = cancelLink>
					</cfcase>
				</cfswitch>
			<cfelse>
				<!--- <cfif arguments.currPeriod EQ arguments.periodid> ---><!--- only check once for open claims --->
					<cfif This.getOpenClaims(arguments.periodid)><!--- there are open BB's --->
						<!--- create --->
						<cfset createLink = this.getActionLink(reportId	= arguments.reportId,
															periodId	= arguments.periodId,
															action		= 'create') />
						<cfset local.actions[1] = createLink>
					</cfif>
				<!--- </cfif> --->
			</cfif>
		</cfoutput>

	  <cfreturn local.actions>
  	</cffunction>

<!--- XXXXXXXXXXXX	Get Report Action Link	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getActionLink" access="public" returntype="string">
		<cfargument name="reportId"	required="no"	type="numeric" default="0" />
		<cfargument name="periodId"	required="yes"	type="numeric" />
		<cfargument name="action"	required="no" type="string" />
		<cfargument name="pause"	required="no" type="any" default="0" />

	  	<!--- request.auto_pay is initialized in layout.cfm --->
	  	<cfscript>
			var link             = "";
			var reportProcessing = "";
			var locked           = request.auto_pay.editing_by_me;
			var linkEnabled      = locked and (not request.auto_pay.lock.processing);
		</cfscript>

			<cfsavecontent variable="link">
				<cfoutput>

					<cfswitch expression="#arguments.action#">
						<cfcase value="create">
							<cfif linkEnabled>
								<a  href="##"
									name="createLink"
									onClick="createReportAction('#arguments.periodID#','#request.accessStructure.User_ID#');this.disabled=1;return false;" title="Create Report">
										<span style="color:Navy" id="create"><IMG BORDER="0" SRC="#this.getNavIcon(linkEnabled)#" ALIGN="absmiddle"></span>
								</a>
								<a  href="##"
									name="createLink"
									onClick="createReportAction('#arguments.periodID#','#request.accessStructure.User_ID#');this.disabled=1;return false;" title="Create Report">
										<span style="color:Navy" id="create">Create Report</span>
								</a>
							</cfif>
						</cfcase>
						<cfcase value="cancel">
							<cfif linkEnabled>
								<a  href="##" id="cancelReport#arguments.reportId#"
									name="cancelReport"  title="Cancel the scheduled report"
									onClick="cancelReportAction('#arguments.reportId#','#arguments.periodId#','#request.accessStructure.User_ID#');this.disabled=1;return false;">
										<img src="/images/delete_new2.gif" align="middle" border="0" />
								</a>
							</cfif>
						</cfcase>
						<cfcase value="view">
							<a  id="viewReport#arguments.reportId#"
								title="View or Edit the report details"
								class="popup"
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
												approveReportAction('#arguments.reportId#','#arguments.periodId#','#request.accessStructure.User_ID#');this.disabled=1;return false;
												}">
										<img src="/images/checkmark.gif" align="middle" border="0" />
									</a>
								</cfif>
							</cfif>
						</cfcase>
						<cfcase value="delete">
							<cfif linkEnabled>
								<a  href="##" id="deleteReport#arguments.reportId#"
										name="deleteReport"
										onClick="if (confirm('Would you like to delete the entry?')){
											deleteReportAction('#arguments.reportId#','#arguments.periodId#','#request.accessStructure.User_ID#');this.disabled=1;return false;
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
											onClick="pauseReportAction('#arguments.reportId#','#arguments.periodId#','#request.accessStructure.User_ID#','1');this.disabled=1;return false;"
											title="Put this scheduled recalc on hold">
												<img src="/images/deviations/stop.gif" align="middle" border="0" />
									</a>
								<cfelse> <!--- else it is on hold, send the resumelink --->
									<a  href="##" id="resumeReport#arguments.reportId#"
											name="resumeReport"
											onClick="pauseReportAction('#arguments.reportId#','#arguments.periodId#','#request.accessStructure.User_ID#','0');this.disabled=1;return false;"
											title="Resume the scheduled recalc">
												<img src="/images/active.gif" align="middle" border="0" />
									</a>
								</cfif>
							</cfif>
						</cfcase>
						<cfcase value="createPeriod">

							<a  id="createPeriod#arguments.reportId#"
								title="View or Edit the report details"
								class="popup"
								href="/billbacks/auto_bb_report/index.cfm?Disp=createPeriod&report=#arguments.Reportid#&PageTitle=PAYABLES:Create Auto Pay Report Period">
									<img src="/images/view.gif" align="middle" border="0" />
							</a>
						</cfcase>
						<cfcase value="addProg">

							<cfif linkEnabled>
								<a  href="##" id="addProg#arguments.reportId#"
									name="addPrograms"  title="Add programs to the report"
									onClick="SearchPrograms('',#arguments.reportId#,false);this.disabled=1;return false;">
										<!--- <img src="/images/delete_new2.gif" align="middle" border="0" /> ---> Add Program(s)
								</a>
							</cfif>
						</cfcase>

						<cfcase value="addProgForException">

							<cfif linkEnabled>
								<a  href="##" id="addProgForException#arguments.reportId#"
									name="addPrograms"  title="Add programs to the exception report"
									onClick="SearchPrograms('',#arguments.reportId#,true);this.disabled=1;return false;">
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
		<cfargument name="BBStatus"	required="no" type="numeric" default="0" />

		<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
		<!---D35392: GM Pullback Log entries END--->
		
		<!--- START: 108967: Autopay access by Segment / Anand Rao / 15-Nov-2021 --->
		<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<cfif  businessSegManager.isEnabled()>
			<cfset Business_Segment_On = 1>
			<cfset UserSegmentFiltersAutopayResults = businessSegManager.getEnabled().User_Segment_Filters_Autopay_Results />
			<cfquery datasource="#application.datasource#" name="getUsrBusSegPrgs">
				/* SELECT * FROM Contract_Main CM 
				WHERE CM.Business_Segment_ID IN (SELECT UBS.Business_segment_ID FROM User_Business_Segment UBS WHERE UBS.User_ID = '#request.accessStructure.User_Id#' AND UBS.deleted = 0)
				AND BB.deleted = 0 */
				SELECT DISTINCT CM.Business_Segment_ID FROM Contract_Main CM 
				WHERE CM.Business_Segment_ID IN 
				(SELECT UBS.Business_segment_ID FROM User_Business_Segment UBS WHERE UBS.User_ID =  '#request.accessStructure.User_Id#' AND UBS.deleted = 0) 
				AND CM.deleted = 0 
				AND CM.Contract_Main_ID = #arguments.Contract_Main_ID#
			</cfquery>
			<cfset BusSegBBs = ValueList(getUsrBusSegPrgs.Business_Segment_ID) />
		<cfelse>
				<cfset Business_Segment_On = 0>
				<cfset UserSegmentFiltersAutopayResults = 0>
				<cfset BusSegBBs = 0 />
		</cfif>

		
		<cfset var result = ""/>
		<!--- If locked by me, show action link --->
		<cfset var locked = this.getReportLockByMe(request.accessStructure.User_Id) />
		<cfif trim(arguments.BBId) EQ ""><cfset arguments.BBId = 0 /></cfif>
		<!--- <cfif reportStatus LT 4 >  ---><!--- if the report is approved, we can not delete or recalc --->
			<cfsavecontent variable="result">
			<cfif (BusSegBBs EQ 0 OR BusSegBBs NEQ "")>
				<cfoutput>
				<cfswitch expression="#trim(arguments.BBId)#">
					<cfcase value="0">
						No BB Data
					</cfcase>
					<cfdefaultcase>
						<cfif locked and reportStatus LT 4 and BBStatus LT 4 >
							<a  href="##" id="ReCalcBB"
								name="ReCalcBB" title="Re-Calculate this Pay Period"
								onClick="document.getElementById('ReCalcBB').setAttribute('disabled','disabled');recalcBBAction('#arguments.reportId#','#request.accessStructure.User_ID#','#arguments.BBId#','#arguments.PayPeriodId#');">
									<img src="/images/recycle1.gif" align="middle" border="0" /></a>&nbsp;
						</cfif>

						<!--- View moved to billback line --->

						<cfif locked and reportStatus LT 4 and BBStatus LT 4 >
							<a  href="##" id="RemoveBB"
								name="RemoveBB" title="Remove from report and delete BB"
								onClick="if (confirm('Would you like to delete the entry?')){
										document.getElementById('RemoveBB').setAttribute('disabled','disabled');removeBBAction('#arguments.reportId#','#request.accessStructure.User_ID#','#arguments.BBId#','#arguments.PayPeriodId#');
										}">
									<img src="/images/delete_new2.gif" align="middle" border="0" /></a>
						</cfif>

						<cfif locked and reportStatus LT 4 and BBStatus LT 4  and This.getReportBB(arguments.reportId)>
							<a  href="##" id="approvePeriod#arguments.reportId#"
									name="approveReport" title="Approve all Billbacks in this Pay Period"
									onClick="if (confirm('Would you like to approve all Billbacks in this Pay Period?')){
										document.getElementById('approvePeriod#arguments.reportId#').setAttribute('disabled','disabled');approvePayPeriodAction('#arguments.reportId#','#arguments.PayPeriodId#','#request.accessStructure.User_ID#');
										}">
								<img src="/images/checkmark.gif" align="middle" border="0" />
							</a>
						</cfif>

						<!--- Download a pdf --->

						<a  href="##" id="CreatePDF"
								name="CreatePDF" title="Create a PDF backup for this report"
								onClick="document.getElementById('CreatePDF').setAttribute('disabled','disabled'); return CreatePDF('#arguments.reportId#','#arguments.Contract_Main_ID#','#arguments.PayPeriodId#');">
						<img src="/images/PDF_Icon.gif" align="middle" border="0" height="15" width="12"/></a>

						
						<!--- Reverse --->
						<cfif locked and (reportStatus EQ 4 OR BBStatus EQ 4) and appSettings.getBBAutoReportAllowReverse() and arguments.Autopay_Reverse >
							<!--- Only if all billbacks are in correct status that can allow reverse --->
							<cfif this.getCanReverse(arguments.PayPeriodId)>
							<a  href="##" id="RevserseBB"
								name="RemoveBB" title="Reverse/Delete billbacks"
								onClick="if (confirm('Would you like to reverse/delete the billbacks?')){
										reverseBBAction('#arguments.reportId#','#request.accessStructure.User_ID#','#arguments.BBId#','#arguments.PayPeriodId#');this.disabled=1;
										}">
									<img src="/images/reverse.png" align="middle" border="0" /></a>
							</cfif>
						</cfif>

					</cfdefaultcase>
				</cfswitch>
				</cfoutput>
				</cfif> 
			</cfsavecontent>
		<!--- </cfif> --->
		<cfreturn result />
  	</cffunction>

<!--- XXXXXXXXXXXX	DATETimeFORMAT	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="formatDateTime" access="public" returntype="string">
		<cfargument name="theDate" required="yes" type="any" />
		<cfscript>
			var d = arguments.theDate;
			if(!isDate(d)){
				d = NOW();
			}
		</cfscript>
		<cfset var result = dateformat(d,"mm/dd/yy")&" "&TimeFormat(d,"hh:mm:ss") />
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
		<cfargument name="theDate" required="yes" type="any" />
		<cfscript>
			var d = arguments.theDate;
			if(!isDate(d)){
				d = NOW();
			}
		</cfscript>
		<cfset var result = dateformat(d,"mm/dd/yy") />
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
		 <cfset var OnClickFunction = "lockLinks();disabledImageZone.style.visibility = 'visible';document.location = '/billbacks/auto_bb_report/index.cfm?del=#arguments.del#&runall=#arguments.runall#&Disp=#arguments.Disp#&Report=#arguments.ReportID#'; return false;">
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

				<cfsavecontent variable="ResultContent">Auto Pay Report ID,Title,Start Date,End Date,Status,Updated By,Updated On,Number of Programs,Number of Billbacks,Billback $ Amount
<cfoutput query="QueryResults">#BB_Auto_Report_ID#,#Report_Title#,#dateformat(Start_Date, 'mm/dd/yyyy')#,#dateformat(End_Date, 'mm/dd/yyyy')#,#Status_Desc#,#User_Code#,#dateformat(Updated_Date, 'mm/dd/yyyy')#,#Program_Count#,#Billback_Count#,#BB_Amount##chr(10)#</cfoutput>
Data provided by Blacksmith Applications</cfsavecontent>

				<cfset Billbackfilepath = application.Doc_Path & "\Temp_Files\Billback\AutoPayReport\" & Disp & "_" & CurrentTimeandUser & ".txt">
				<cfset DownloadFilePath = application.HTTPVar & cgi.SERVER_NAME & "/common_documents/Temp_Files/Billback/AutoPayReport/" & Disp & "_" & CurrentTimeandUser & ".txt">

				<!--- Write file location --->
				<CFFILE action = "write"
				file="#Billbackfilepath#"
				output="#ResultContent#">

				<!--- show links --->
				<!---<cfsavecontent variable="DownloadLinks">
				<div align="center">Your report is ready to download.</div>
					<p></p>
					<div align="center">
					<CF_smallLink
					title = "click here to download"
					url = "##"
					parameters = "onClick=""javascript: downloadDoc('#DownloadFilePath#');"""
					>
					</div>
				</cfsavecontent>--->
				<cfset DownloadLinks = Billbackfilepath/>

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
		<cfargument name="BB_Auto_Program_Pay_Period_ID" default="0">

		<cfset var GetExtractHeader = "">
        <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

		<cfquery name="GetExtractHeader" datasource="#application.datasource#">
		SELECT DISTINCT
            BB_Auto_Report.Report_Title,
            BB_Auto_Report.BB_Auto_Report_ID,
            BB_Auto_Program_Pay_Period.Payment_Start_Date As Start_Date,
            BB_Auto_Program_Pay_Period.Payment_End_Date As End_Date,
            Contract_Main.Contract_Title,
            Contract_Main.Contract_Number,
            Contract_Main.Contract_Main_ID,
            BB_Auto_Report_Export_BB_Header.Billback_ID,
            BB_Auto_Report_Export_BB_Header.BB_Title,
            BB_Auto_Report_Export_BB_Header.BB_Code,
            BB_Auto_Report_Export_BB_Header.Shr_Ship_To,
            ISNULL(BB_Auto_Report_Export_BB_Header.Shr_Ship_To, VM.Vendor_ID) as Distributor_ID,
            ISNULL(
            <cfif appSettings.get_Setting('Display_Distributor_ID') eq '1'>
            BSA_Foodservice_Customers.Shr_Ship_To
            <cfelse>
            BSA_Foodservice_Customers.Ship_To
            </cfif>, VM.Vendor_ID) as Display_Distributor_ID,
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
			AND BB_Auto_Program_Pay_Period.BB_Auto_Program_Pay_Period_ID = <cfqueryparam value="#arguments.BB_Auto_Program_Pay_Period_ID#" cfsqltype="numeric">
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
            INNER JOIN BB_Auto_Pay_Period_Billback PPB ON
            PPB.BB_Auto_Program_Pay_Period_Id =    BB_Auto_Program_Pay_Period.BB_Auto_Program_Pay_Period_ID AND
            PPB.Billback_Id = BB_Auto_Report_Export_BB_Header.Billback_Id

            LEFT JOIN BSA_Foodservice_Customers
            ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = BB_Auto_Report_Export_BB_Header.Distributor_ID_Earned <!--- WR 77868 :: Was joind on Ship_to --->
            LEFT JOIN Vendor_Master VM
            ON    VM.Vendor_Master_ID = BB_Auto_Report_Export_BB_Header.Distributor_ID_Earned
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
            BB_Auto_Program_Pay_Period.Payment_Start_Date,
            BB_Auto_Program_Pay_Period.Payment_End_Date,
            Contract_Main.Contract_Title,
            Contract_Main.Contract_Number,
            Contract_Main.Contract_Main_ID,
            BB_Auto_Report_Export_BB_Header.BB_Title,
            BB_Auto_Report_Export_BB_Header.BB_Code,
           BB_Auto_Report_Export_BB_Header.Shr_Ship_To,
           ISNULL(BB_Auto_Report_Export_BB_Header.Shr_Ship_To, VM.Vendor_ID),
            ISNULL(
            <cfif appSettings.get_Setting('Display_Distributor_ID') eq '1'>
            BSA_Foodservice_Customers.Shr_Ship_To
            <cfelse>
            BSA_Foodservice_Customers.Ship_To
            </cfif>, VM.Vendor_ID),
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
        <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

		<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<cfif  businessSegManager.isEnabled()>
			<cfset Business_Segment_On = 1>
			<cfset UserSegmentFiltersAutopayResults = businessSegManager.getEnabled().User_Segment_Filters_Autopay_Results />
		<cfelse>
			<cfset Business_Segment_On = 0>
			<cfset UserSegmentFiltersAutopayResults = 0>
		</cfif>		
		<cfquery name="qUserSegments" datasource="#application.datasource#">
			SELECT Business_Segment_ID FROM User_Business_Segment WHERE USER_ID = '#request.accessStructure.User_Id#' AND deleted = 0
		</cfquery>
		<cfset userSegmentIds = ValueList(qUserSegments.Business_Segment_ID) />

		<cfquery name="qAutoPayExtractComplete" datasource="#application.datasource#">
		SELECT
			R.BB_Auto_Report_ID,
			REPLACE(R.Report_Title,',','') AS Report_Title,
			CONVERT(VARCHAR(10), RP.Start_Date, 101) AS Start_Date,
			CONVERT(VARCHAR(10), RP.End_Date, 101) AS End_Date,
			REPLACE(CM.Contract_Title,',','') AS Contract_Title,
			CM.Contract_Number,
			REPLACE(ExBBH.BB_Title,',','') AS BB_Title,
			ExBBH.BB_Code,
            <cfif appSettings.get_Setting('Display_Distributor_ID') eq '1'>
            ExBBH.Shr_Ship_To
            <cfelse>
            DistEarned.Ship_To
            </cfif> as Shr_Ship_To,
			REPLACE(ExBBH.Shr_Ship_To_Name,',','') AS Shr_Ship_To_Name,
		/* --	DF.Family_Name,
		--	DF.Family,
		--	DBG.Buying_Group_Name,
		--	DBG.Buying_Group, */
			ID.Operator_ID, /* --Operator ID, */
			REPLACE(IM.Item,',','') AS Item,
			REPLACE(IM.GTIN,',','') AS GTIN,
			REPLACE(IM.UPC,',','') AS UPC,
			REPLACE(REPLACE(IM.Description,',',''),'"','') AS Description,
			REPLACE(REPLACE(B.Brand_Name,char(13),''),',','') AS Brand_Name,
			CONVERT(VARCHAR(10), ExBBH.Invoice_Date, 101) AS Invoice_Date,
			REPLACE(ExBBH.Purchase_Order,',','') AS Purchase_Order,
			REPLACE(ExBBH.Shared_Invoice_Number,',','') AS Shared_Invoice_Number,
			REPLACE(IH.Pro_Number,',','') AS Pro_Number,
			isnull(ExBBD.Cases_Invoiced, 0) AS Cases_Invoiced,
			isnull(ExBBD.Pounds_Invoiced, 0) AS Pounds_Invoiced,
			isnull(ExBBD.Sales_Dollars, 0) AS Sales_Dollars, /* --Invoice $, */
			ID.gross_Sales_Dollars AS Gross_Sales, /* --Gross Inv $, */
			ID.Sales_Dollars AS Rebateable_Sales, /* --Rebateable Inv $, */
			isnull(ExBBD.Unit_Price, 0) AS Unit_Price, /* --Price, */
			ExBBD.Price_Unit_of_Measure, /* --Price UOM, */
			isnull(ExBBD.Discount_Offered, 0) AS Discount_Offered, /* --Discount, */
			UOM.Abbreviation_Singular AS Discount_UOM, /* --Discount UOM, */
			isnull(ExBBD.Amount_Earned, 0) AS Amount_Earned, /* --$ Earned, */
			BFC.Shr_CustID, /* --Cust ID */
			<!--- Get the program associated with the billback where the
			billback is a credit, i.e. a pullback (negative value).
			--->
			CM1.Contract_Number As Credit_Program_Number,
			REPLACE(CM1.Contract_Title,',','') As Credit_Program_Title
			/* --CM.Contract_Main_ID, */
			,Payee_ID = 
				CASE 
				WHEN BFC.BSA_Foodservice_Customers_ID IS NULL THEN VM.Vendor_ID 
				ELSE 
					<cfif appSettings.get_Setting('Display_Distributor_ID') eq '1'>
					BFC.Shr_Ship_To
					<cfelse>
					BFC.Ship_To
					</cfif>
				END
			,Payee_Name = CASE WHEN BFC.BSA_Foodservice_Customers_ID IS NULL THEN VM.Vendor_Name ELSE BFC.Name END
			,Prod_Var_B.Prod_Var_B
			,Prod_Var_E.Prod_Var_E
			,ID.Primary_Broker_Commission as Invoice_Zipcode
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
			LEFT JOIN Invoice_Header IH ON
				IH.Invoice_Header_Id = ExBBH.Invoice_Header_Id
			LEFT JOIN Invoice_Detail ID ON
				ID.Invoice_Detail_Id = ExBBD.Invoice_Detail_Id
			LEFT JOIN Brand B ON
				B.Brand_ID = IM.Brand_ID
			LEFT JOIN Prod_Var_E ON
				Prod_Var_E.Prod_Var_E_ID = IM.Prod_Var_E_ID
			LEFT JOIN Prod_Var_B ON
				Prod_Var_B.Prod_Var_B_ID = IM.Prod_Var_B_ID
			LEFT JOIN Billback_Distributor BD ON
				BD.Billback_ID = ExBBH.Billback_ID
			LEFT JOIN BSA_Foodservice_Customers BFC ON
				BFC.BSA_Foodservice_Customers_ID = BD.Distributor_ID
			LEFT JOIN Vendor_Master VM ON
				VM.Vendor_Master_ID = BD.Distributor_ID
            LEFT JOIN BSA_Foodservice_Customers DistEarned ON
				DistEarned.BSA_Foodservice_Customers_ID = ExBBH.Distributor_ID_Earned
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
			<cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>
				AND CM.Business_Segment_ID in (#userSegmentIds#)
			</cfif>
		ORDER BY CM.Contract_Number
		</cfquery>
	<cfreturn qAutoPayExtractComplete />

	</cffunction>

	<cffunction name="getAutoPayPullbackExport"  access="public" returntype="query" output="true">
		<cfargument name="Report_ID" type="numeric" required="true">

		<cfset var qGetAutoPayPullbackExport = "">

		<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<cfif  businessSegManager.isEnabled()>
			<cfset Business_Segment_On = 1>
			<cfset UserSegmentFiltersAutopayResults = businessSegManager.getEnabled().User_Segment_Filters_Autopay_Results />
		<cfelse>
			<cfset Business_Segment_On = 0>
			<cfset UserSegmentFiltersAutopayResults = 0>
		</cfif>
		<cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>
			<cfquery name="qUserSegments" datasource="#application.datasource#">
				SELECT Business_Segment_ID FROM User_Business_Segment WHERE USER_ID = '#request.accessStructure.User_Id#' AND deleted = 0
			</cfquery>
			<cfset userSegmentIds = ValueList(qUserSegments.Business_Segment_ID) />
		</cfif>		
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
			LEFT JOIN BB_Approved  OPRBBAPPR
			ON		OPRBB.Billback_Id = OPRBBAPPR.Billback_Id
			WHERE H.BB_Auto_Report_ID = <cfqueryparam value="#arguments.Report_ID#" cfsqltype="numeric">
			<cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>
				AND contract_main.Business_Segment_ID in (#userSegmentIds#)
			</cfif>
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
		<cfargument name="ReportLevel"	required="no" type="numeric" default="1" />
		<cfargument name="Billback_ID"	required="no" type="any" default="" />
			
		<cfset var qGetAutoPayPullbackExport = "">

		<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<cfif  businessSegManager.isEnabled()>
			<cfset Business_Segment_On = 1>
			<cfset UserSegmentFiltersAutopayResults = businessSegManager.getEnabled().User_Segment_Filters_Autopay_Results />
		<cfelse>
			<cfset Business_Segment_On = 0>
			<cfset UserSegmentFiltersAutopayResults = 0>
		</cfif>	
		<cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>
			<cfquery name="qUserSegments" datasource="#application.datasource#">
				SELECT Business_Segment_ID FROM User_Business_Segment WHERE USER_ID = '#request.accessStructure.User_Id#' AND deleted = 0
			</cfquery>
			<cfset userSegmentIds = ValueList(qUserSegments.Business_Segment_ID) />
		</cfif>			

		<cfquery name="qGetAutoPayPullbackExport" datasource="#application.datasource#">

			 SELECT
					R.BB_Auto_Report_ID,
					REPLACE(R.Report_Title,',','') AS [Report_Title],
					CM.Contract_Number AS [Auto_Pay_Program],
					REPLACE(CM.Contract_Title,',','') AS [Auto_Pay_Program_Title],
					PCPO_Corp.created_Type AS [Auto_Pay_Program_Template],
					B.BB_Code AS [Auto_PayBB],
					REPLACE(replace(replace(B.BB_Title,char(10),''),char(13),''),',','') AS [Auto_PayBB_Title],
					B.BB_Amount AS [Auto_Pay_BB_$],
					isnull(BB_Approved.Pullback_Applied_Amount, 0) AS Pullback_Applied_Amount,
					BB_Approved.Paid_Amount AS [Auto_Pay_BB_Final_$],
					PH.PullBack_Contract_Number,
					REPLACE(PH.PullBack_Contract_Title,',','') [PullBack_Contract_Title],
					PCPO_Opr.created_Type AS [PullBack_Contract_Template],
					ISNULL(OPR.Legacy_ID,OPR1.Legacy_ID) [Operator_ID],
					ISNULL(OPR.BSA_Operator_ID,OPR1.BSA_Operator_ID) [BSA_Operator_ID],
					REPLACE(ISNULL(OPR.Operator_Name,OPR1.Operator_Name),',','') [Operator_Name],
					OPRBB.bb_code AS [Recap_BB],
					REPLACE(replace(replace(OPRBB.BB_Title,char(10),''),char(13),''),',','') AS [Recap_BB_Title],
					I_Group.Description [Group_Name],
					I.Item [Item_Number],
					REPLACE(I.Description,',','') [Item_Description],
					OPRBB.bb_start_date AS [Recap_BB_Start_Date],
					OPRBB.bb_end_date AS [Recap_BB_End_Date],
					OPRBBAPPR.Date_Approved,
					CAST(PD.PB_From_Program_Rate AS VARCHAR(12)) + '/' + UOM.Abbreviation_Singular AS [Recap_Rate_Percent],  
					CAST(PD.PB_From_Program_Rate AS VARCHAR(12)) AS [Recap_Rate_Percent_num],
					CASE
					WHEN PB_From_Program_UOM = 1 THEN
						cast((PD.Corp_Rate) as decimal(20,6))
					ELSE
						cast((PD.Corp_Rate*I.net_weight) as decimal(20,6))
					END AS [Recap_Rate_Per_Case],
					CAST(PD.Budget_Recapture_Rate  AS VARCHAR(12)) + '/' + UOM_Alt.Abbreviation_Singular AS [Alt_Recap_Rate],
					/* -- CAST(ISNULL(PD.Pullback_Amount,0)/ISNULL(nullif(cast(PD.product_BB_volume_CS AS decimal(20,4)),0),1) AS decimal(20,4)) [Calculated_Pullback_Rate_CS], */
					CASE
					WHEN Convert(decimal(20,6),PD.PB_From_Program_Rate) = 0 THEN
					 0
					WHEN PB_From_Program_UOM = 3 THEN	
						CAST((cast((PD.Corp_Rate*I.net_weight) as decimal(20,6))/(CAST(PD.PB_From_Program_Rate AS decimal(20,6))/100)) * cast(PD.product_BB_volume_CS AS decimal(20,0)) as Decimal(20,2))
					ELSE
						0
					END AS [Calculated_Pullback_Invoice_Dollars],
					CASE
					WHEN PD.Budget_Recapture_Rate_UOM = 1 THEN
						cast((PD.Budget_Recapture_Rate) as decimal(20,6))
					WHEN PD.Budget_Recapture_Rate_UOM = 2 THEN 
						cast((PD.Budget_Recapture_Rate*I.net_weight) as decimal(20,6))
					ELSE
						cast((PD.Budget_Recapture_Amount/PD.Product_BB_Volume_CS) as decimal(20,6))
					END AS [Alt_Recap_Rate_Per_Case],
					ISNULL(PD.Pullback_Amount,0) AS Pullback_Amount,
					ISNULL(PD.Pullback_Amount_Raw,0) AS Pullback_Amount_Raw,
					cast(PD.product_BB_volume_CS AS decimal(20,0))  AS [Recap_Cases],
					cast(PD.product_BB_volume_LB AS decimal(20,0))  AS [Recap_Lb],
					PH.SHR_Ship_To,
					PH.SHR_Ship_To_Name
					/* --,pd.product_BB_volume_LB */
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
			LEFT JOIN Program_Control_Panel_Options PCPO_Corp ON
				PCPO_Corp.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
			INNER JOIN BillBack OPRBB
			ON		OPRBB.Billback_Id = PH.Pullback_Billback_Id
			LEFT JOIN Billback_Operator BO ON
				BO.Billback_ID = PH.Pullback_Billback_Id AND
				BO.Billback_Operator_ID = (SELECT TOP 1 Billback_Operator_ID FROM Billback_Operator WHERE Billback_ID = PH.Pullback_Billback_Id)
			LEFT JOIN BB_Approved  OPRBBAPPR
			ON		OPRBB.Billback_Id = OPRBBAPPR.Billback_Id
			LEFT JOIN Billback_Program  BPOpr
			ON		BPOpr.billback_id = OPRBB.billback_id AND
					BPOpr.Deleted = 0 AND
					BPOpr.Program_ID in (SELECT Contract_MAin_Id from Contract_Main Where contract_number = PH.PullBack_Contract_Number)
			LEFT JOIN Contract_Main CM_Opr ON
				CM_Opr.contract_main_id = BPOpr.Program_Id
			LEFT JOIN Program_Control_Panel_Options PCPO_Opr ON
				PCPO_Opr.ProgramControl_Panel_Options_ID = CM_Opr.ProgramType_ID
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
				CP.Is_Group = 0 AND CP.BSA_Foodservice_Items_Master_ID = PD.Product_Id AND
			    CP.Product_Type_ID = 2 AND
				CP.Group_Contract_Product_ID IS NOT NULL
				/* --Item groups */
			LEFT JOIN Contract_Products CP_Group ON
				CP_Group.Contract_Products_ID = CP.Group_Contract_Product_ID AND
				CP.Group_Contract_Product_ID IS NOT NULL AND
				CP_Group.Contract_Main_ID = CM.Contract_Main_ID AND
				CP_Group.Product_Type_ID = 2
			LEFT JOIN BSA_Foodservice_Items_Master I_Group ON
				I_Group.BSA_Foodservice_Items_Master_ID = CP_Group.BSA_Foodservice_Items_Master_ID
			LEFT JOIN BSA_Foodservice_Items_Master I2 ON
				I2.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
			LEFT JOIN BSA_Foodservice_Items_Master I ON
				I.BSA_Foodservice_Items_Master_ID = PD.Product_Id
			LEFT JOIN Units_of_Measure UOM ON
				UOM.Unit_Of_Measure_ID = PD.PB_From_Program_UOM  /* --Budget_Recapture_Rate_UOM */
			LEFT JOIN Units_of_Measure UOM_Alt ON
				UOM_Alt.Unit_Of_Measure_ID = PD.Budget_Recapture_Rate_UOM
			WHERE 		
						<cfif arguments.ReportLevel>
						H.BB_Auto_Report_ID = <cfqueryparam value="#arguments.Report_ID#" cfsqltype="numeric">  
						AND	R.BB_Auto_Report_ID = <cfqueryparam value="#arguments.Report_ID#" cfsqltype="numeric">
							<cfelse>
						B.Billback_ID  in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true"  value="#arguments.Billback_ID#">)	
						</cfif>
						<cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>
						 AND CM.Business_Segment_ID in (#userSegmentIds#)
						</cfif>
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
		<cfargument name="BB_Auto_Program_Pay_Period_Id" required="false" default="0">

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
			ON BAREH.Export_Header_ID = BAREBH.Export_Header_ID AND
				BAREBH.shr_ship_to is NOT null
			INNER JOIN BB_Auto_Pay_Period_Billback PPB ON
					PPB.Billback_Id = BAREBH.Billback_ID
			INNER JOIN BB_Approved
			ON BB_Approved.Billback_ID = BAREBH.Billback_ID
			INNER JOIN Contract_Main CM
			ON CM.Contract_Main_ID = BAREBH.Contract_Main_ID
			<!--- AND CM.Contract_Main_ID = <cfqueryparam value="#arguments.Contract_Main_ID#" cfsqltype="cf_sql_integer"> 
					D74019 :: when latest revision is active at time report is created and report spans a previous revision, no data returned --->
			AND CM.Contract_Number = (SELECT top 1 Contract_Number FROM Contract_main Where Contract_Main_Id = <cfqueryparam value="#arguments.Contract_Main_ID#" cfsqltype="cf_sql_integer">)
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
			<cfif arguments.BB_Auto_Program_Pay_Period_Id NEQ 0>
				AND PPB.BB_Auto_Program_Pay_Period_Id = <cfqueryparam value="#arguments.BB_Auto_Program_Pay_Period_Id#" >
			</cfif>
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
			IH.Pro_Number,
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
			LEFT JOIN Invoice_Header IH
			ON IH.Invoice_Header_ID = BAREBH.Invoice_Header_ID
		WHERE BAREH.BB_Auto_Report_ID = <cfqueryparam value="#arguments.Report_ID#" cfsqltype="cf_sql_integer">
			<cfif arguments.Shr_Ship_To EQ "">
			AND BAREBH.Shr_Ship_To IS NULL
			<cfelse>
			AND BAREBH.Shr_Ship_To = <cfqueryparam value="#arguments.Shr_Ship_To#" cfsqltype="cf_sql_char">
			</cfif>
			<!--- AND BAREBH.Contract_Main_ID = <cfqueryparam value="#arguments.Contract_Main_ID#" cfsqltype="cf_sql_integer"> 
				D74019 :: when latest revision is active at time report is created and report spans a previous revision, no data returned --->
			AND BAREBH.Contract_Number = (SELECT top 1 Contract_Number FROM Contract_main Where Contract_Main_Id = <cfqueryparam value="#arguments.Contract_Main_ID#" cfsqltype="cf_sql_integer">)
		ORDER BY BAREBH.Shared_Invoice_Number
		</cfquery>

		<cfreturn qInvoiceLevelInfo />

	</cffunction>

	<cffunction name="getDistAmountEarned" access="public" returntype="query" output="false">
		<cfargument name="Report_ID"  required="true">
		<cfargument name="Shr_Ship_To"  required="true">
		<cfargument name="Contract_Main_ID"  required="true">
		<cfargument name="Distributor_GUID"  required="false" default="">
		<cfargument name="BB_Auto_Program_Pay_Period_Id" required="false" default="0">

		<cfset var qGetDistAmountEarned = "">

		<cfquery name="qGetDistAmountEarned" datasource="#application.datasource#">
			SELECT SUM(BAREBD.Amount_Earned) AS Sum_Amount_Earned
			FROM BB_Auto_Report_Export_Header BAREH
			INNER JOIN BB_Auto_Report_Export_BB_Header BAREBH ON
				BAREBH.Export_Header_ID = BAREH.Export_Header_ID
			INNER JOIN BB_Auto_Pay_Period_Billback PPB ON
					PPB.Billback_Id = BAREBH.Billback_ID
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
				<cfif arguments.BB_Auto_Program_Pay_Period_Id NEQ 0>
					AND PPB.BB_Auto_Program_Pay_Period_Id = <cfqueryparam value="#arguments.BB_Auto_Program_Pay_Period_Id#" >
				</cfif>
		</cfquery>

		<cfreturn qGetDistAmountEarned />

	</cffunction>

	<cffunction name="getInvoiceDetailInfo" access="public" returntype="query" output="false">
		<cfargument name="Report_ID"  required="true">
		<cfargument name="Shr_Ship_To"  required="true">
		<cfargument name="Contract_Main_ID"  required="true">
		<cfargument name="Shared_Invoice_Number"  required="true">
		<cfargument name="Distributor_GUID"  required="false" default="">
		<cfargument name="BB_Auto_Program_Pay_Period_Id" required="false" default="0">

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
		INNER JOIN BB_Auto_Pay_Period_Billback PPB ON
					PPB.Billback_Id = BAREBH.Billback_ID
		INNER JOIN BB_Auto_Report_Export_BB_Detail BAREBD ON
			BAREBD.Export_Header_ID = BAREBH.Export_Header_ID AND
			BAREBD.BB_Header_ID = BAREBH.BB_Header_ID
		INNER JOIN BSA_Foodservice_Items_Master BFID ON
			BFID.BSA_Foodservice_Items_Master_ID = BAREBD.Product_ID
		<!---INNER JOIN Invoice_Detail ID ON
			ID.Invoice_Detail_Id = BAREBD.Invoice_Detail_ID AND
			ISNULL(CAST(ID.Current_Shared_Ship_To AS NVARCHAR(50)),BAREBH.Shr_Ship_To) = BAREBH.Shr_Ship_To --->
		LEFT JOIN #AttributeTable# AttributeTable ON
			AttributeTable.#AttributeField# = BFID.#AttributeField#
		WHERE BAREH.BB_Auto_Report_ID = <cfqueryparam value="#arguments.Report_ID#" cfsqltype="cf_sql_integer">
			AND BAREBH.Shr_Ship_To = <cfqueryparam value="#arguments.Shr_Ship_To#" cfsqltype="cf_sql_char">
			<!--- D74019 :: when latest revision is active at time report is created and report spans a previous revision, no data returned  --->
			AND BAREBH.Contract_Number = (SELECT top 1 Contract_Number FROM Contract_main Where Contract_Main_Id = <cfqueryparam value="#arguments.Contract_Main_ID#" cfsqltype="cf_sql_integer">)
			AND BAREBH.Shared_Invoice_Number = <cfqueryparam value="#arguments.Shared_Invoice_Number#" cfsqltype="cf_sql_char">
			<cfif arguments.BB_Auto_Program_Pay_Period_Id NEQ 0>
				AND PPB.BB_Auto_Program_Pay_Period_Id = <cfqueryparam value="#arguments.BB_Auto_Program_Pay_Period_Id#" >
			</cfif>
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
		INNER JOIN BB_Auto_Pay_Period_Billback PPB ON
					PPB.Billback_Id = BAREBH.Billback_ID
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
			<cfif arguments.BB_Auto_Program_Pay_Period_Id NEQ 0>
				AND PPB.BB_Auto_Program_Pay_Period_Id = <cfqueryparam value="#arguments.BB_Auto_Program_Pay_Period_Id#" >
			</cfif>
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
				B.BB_Reference AS bbReference, -- referenceNum
				B.BB_Title AS bbTitle,
				R.Report_Title AS reportTitle,
				BA.Paid_Amount AS bbAmount,
				BCM.vchBillback_Closing_Method_Desc AS closingMethod,
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
			LEFT JOIN Billback_Closing_Methods BCM ON BCM.iBillback_Closing_Method_ID = B.BB_Closing_Method
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
		<cfargument name="ReportLevel"	required="no" type="numeric" default="1" />
		<cfargument name="Billback_ID"	required="no" type="any" default="" />
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
				SELECT --Top 100
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
				,ISNULL(IM.Pack_Size,CC.Case_Count) AS Pack_Size
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
							LEFT JOIN Vendor_Master VM ON
								Vendor_Master_Id = BD.Distributor_ID
							LEFT JOIN Case_Count CC on CC.Case_Count_Id = IM.Case_Count_Id
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
						WHERE 
						<cfif arguments.ReportLevel>
						R.BB_Auto_Report_ID = <cfqueryparam value="#arguments.ReportId#" /> 
							<cfelse>
						ExBBH.Billback_ID in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true"  value="#arguments.Billback_ID#">)
						</cfif>
						AND	(BFC.Name like '%Unipro%' OR VM.Vendor_Name like '%Unipro%' or df.family_name like '%Unipro%')
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
		<cfargument name="ReportLevel"	required="no" type="numeric" default="1" />
		<cfargument name="Billback_ID"	required="no" type="any" default="" />
		
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
				WHERE 
						<cfif arguments.ReportLevel>
						R.BB_Auto_Report_ID = <cfqueryparam value="#arguments.ReportId#" /> 
							<cfelse>
						B.Billback_ID  in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true"  value="#arguments.Billback_ID#">)		
						</cfif>				
				
				
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

	<cffunction name="getReportDistributors" access="public" returntype="query" output="false">
		<cfargument name="Auto_Pay_Contract_ID" type="string" required="true" />
		<cfargument name="Contract_List" type="string" required="false" />
		<cfargument name="BBAutoReportID" type="string" required="true" default="0" />
		<cfargument name="showSelectedOnly" type="string" required="false" default="0" />

		<CFQUERY NAME="qGetAutoPayDistributors" datasource="#application.datasource#">
		SELECT DISTINCT 
				BSA_Foodservice_Customers.Name,
				BSA_Foodservice_Customers.Shr_Ship_To,
				BSA_Foodservice_Customers.City,
				BSA_Foodservice_Customers.State,
				BSA_Foodservice_Customers.Address_1,
				BSA_Foodservice_Customers.zipcode,
				BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
				Distributor_Buying_Groups.Buying_Group_Name,
				Distributor_Family.Family_Name,
				<!--- For an existing report, get the selected distributors --->
				<cfif arguments.BBAutoReportID neq 0>
				BB_Auto_Report_Distributor_Filter.Distributor_ID As Selected_Distributor_ID
				<cfelse>
				'' As Selected_Distributor_ID
				</cfif>
		FROM	
				BSA_Foodservice_Customers
				<!--- Always do a join here. We want to get program distributors only --->
				INNER JOIN Contract_Distributors
				ON Contract_Distributors.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID

				<!--- To get the auto pay selected distributors --->
				<cfif arguments.BBAutoReportID neq 0>
				LEFT JOIN	BB_Auto_Report_Distributor_Filter	
				ON BB_Auto_Report_Distributor_Filter.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
				</cfif>				
				
				<!--- Filter below is used because we have a LEFT JOIN on "BB_Auto_Report_Distributor_Filter". To show all records, we
				need to add filter here.
				Note: When "arguments.showSelectedOnly" is 1, we will not get all records, but get only the selected records. In that case,
				we need this same filter after the "WHERE" clause and this below filter will not be called.
				--->
				<cfif arguments.BBAutoReportID neq 0 AND arguments.showSelectedOnly eq 0>
				AND BB_Auto_Report_Distributor_Filter.Contract_Main_ID = '#arguments.Auto_Pay_Contract_ID#'
				AND BB_Auto_Report_Distributor_Filter.BB_Auto_Report_ID = '#arguments.BBAutoReportID#'
				AND BB_Auto_Report_Distributor_Filter.deleted = 0
				</cfif>

				INNER JOIN	Distributor_Family
				ON
				BSA_Foodservice_Customers.Family_ID = Distributor_Family.Family_ID
				INNER JOIN	Distributor_Buying_Groups
				ON
				BSA_Foodservice_Customers.Buying_Group_ID = Distributor_Buying_Groups.Buying_Group_ID
		WHERE	1 = 1

				<!---  No need to check program distributors, when we need to get a count of existing distributors in the "BB_Auto_Report_Distributor_Filter" table. --->
				<cfif arguments.showSelectedOnly eq 0>
				<!--- We want to get program distributors only. --->
				AND Contract_Distributors.Contract_Main_ID IN (#PreserveSingleQuotes(arguments.Contract_List)#)
				AND	Contract_Distributors.Is_Group = 0
				AND Contract_Distributors.deleted = 0
				</cfif>

				<!--- For a new report, when programs are added by a user and the distributors are not added as yet, we want to return no
				records, so that the "count" next to "filter distributors" link shows "0 distributors selected". --->
				<cfif arguments.BBAutoReportID eq 0 AND arguments.showSelectedOnly eq 1>
				AND 1 = 0
				</cfif>

				<!--- Filter below is used only when we need the selected records only.
				Note: a similar filter is being used before the "WHERE" clause (above) too. In that case (arguments.showSelectedOnly = 0),
				we need all the records and not just the selected records.
				--->
				<cfif arguments.BBAutoReportID neq 0 AND arguments.showSelectedOnly eq 1>
				AND BB_Auto_Report_Distributor_Filter.Contract_Main_ID = '#arguments.Auto_Pay_Contract_ID#'
				AND BB_Auto_Report_Distributor_Filter.BB_Auto_Report_ID = '#arguments.BBAutoReportID#'
				AND BB_Auto_Report_Distributor_Filter.deleted = 0
				</cfif>

				ORDER BY BSA_Foodservice_Customers.Name
		</CFQUERY>

		<cfreturn qGetAutoPayDistributors />
	</cffunction>

	<cffunction name="getReportInvoices" access="public" returntype="struct" output="false">
		<cfargument name="ContractNumber" type="string" required="false" />
		<cfargument name="Auto_Pay_Contract_ID" type="string" required="true" />
		<cfargument name="BBAutoReportID" type="string" required="true" default="0" />
		<cfargument name="showSelectedOnly" type="string" required="false" default="0" />
		<cfargument name="showCurrentlySelectedOnly" type="string" required="false" default="0" />
		<cfargument name="invoiceList" type="string" required="false" default="" />
		<cfargument name="distributorIDList" type="string" required="false" default="" />
		<cfargument name="StartDate" type="string" required="false" default="" />
		<cfargument name="EndDate" type="string" required="false" default="" />
		<cfargument name="dollar_operator" type="string" required="false" default="" />
		<cfargument name="dollar_amount" type="string" required="false" default="" />
		<cfargument name="distributor_name" type="string" required="false" default="" />
		<cfargument name="ship_to" type="string" required="false" default="" />
		<cfargument name="customerPO" type="string" required="false" default="" />
		<cfargument name="invoiceNumber" type="string" required="false" default="" />
		<cfargument name="orderNumber" type="string" required="false" default="" />
		<!--- "column_sequence_number" default has been set below just in case we need to create Excel report
		from this query.Default of "2" below is "ORDER_NUJMBER", the second column on the grid. Default column
		is also set on the grid. "Shared_Invoice_Number" is not populated orrectly for Kraft and so we cannot make 
		"Shared_invoice_number" as the default column to sort on.
		--->
		<cfargument name="column_sequence_number" type="string" required="false" default="2" /> 
		<cfargument name="sort_order" type="string" required="false" default="" />		
		<cfargument name="startRow" type="numeric" required="false" default="0" />
		<cfargument name="endRow" type="numeric" required="false" default="0" />

		<cfset returnStruct = StructNew()>
		
		<cfif arguments.showSelectedOnly eq 0>
			<cfset programManager = CreateObject("component","components.programs.ProgramManager") />
			<cfset qGetProgramEffectiveDateSpan = programManager.getProgramEffectiveDateSpan(arguments.ContractNumber)>
		</cfif>

		<CFQUERY NAME="qDropTempTables" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##Temp_InvoiceData') IS NOT NULL
			DROP TABLE ##Temp_InvoiceData

			IF OBJECT_ID('tempdb..##Temp_Prod_List') IS NOT NULL
			DROP TABLE ##Temp_Prod_List

			IF OBJECT_ID('tempdb..##Temp_Dist_List') IS NOT NULL
			DROP TABLE ##Temp_Dist_List
		</CFQUERY>

		<CFQUERY NAME="qGetReportInvoices" datasource="#application.datasource#">
			CREATE TABLE ##Temp_InvoiceData
			(
				rowIDInt int Identity (1,1),
				Invoice_Header_ID uniqueidentifier NOT NULL,
				Shared_Invoice_Number varchar(100) NULL,
				Purchase_Order varchar(100) NULL,
				Pro_Number  varchar(50) NULL,
				Name varchar(255) NULL,
				Shr_Ship_to varchar(50) NULL,
				Invoice_Date datetime NULL,
				Invoice_Number varchar(100) NULL,
				Distributor_ID uniqueidentifier NOT NULL,
				Total_Dollars float NULL,
				Total_Cases float NULL,
				Selected_Invoice_Header_ID varchar(50) NULL
			)

			CREATE TABLE ##Temp_Prod_List
			(
				BSA_Foodservice_Items_Master_ID uniqueIdentifier
			)
			
			CREATE TABLE ##Temp_Dist_List
			(
				BSA_Foodservice_Customers_ID uniqueIdentifier
			)
			
			<cfif arguments.showSelectedOnly eq 0 AND arguments.showCurrentlySelectedOnly eq 0>
				INSERT INTO ##Temp_Prod_List(BSA_Foodservice_Items_Master_ID)
				SELECT  DISTINCT Contract_Products.BSA_Foodservice_Items_Master_ID
				FROM Contract_Main
				INNER JOIN Program_Rebates_Component
				ON Program_Rebates_Component.Program_ID = Contract_Main.Contract_Main_ID
				INNER JOIN Payment_Type ON
				Payment_Type.Payment_Type_ID = Program_Rebates_Component.Claim_Mechanics
				INNER JOIN Contract_Products
				ON    Contract_Products.Contract_Main_ID = Program_Rebates_Component.Program_ID
				AND    Contract_Products.Product_Type_ID = 2
				WHERE Contract_Main.Contract_Number = '#arguments.ContractNumber#'
				<!--- Below logic is the overlap logic --->
				AND Contract_Main.Effective_Start_Date <= #CreateODBCDate(arguments.end_date)#
				AND Contract_Main.Effective_End_Date >= #CreateODBCDate(arguments.start_date)#
				AND Contract_Products.Deleted = 0
				AND Contract_Products.Is_Group = 0
				AND Program_Rebates_Component.deleted = 0
				AND Payment_Type.Is_Auto_Pay = 1
				
				<!--- Eception report should consider rebate only --->
				<!---
				UNION
				
				SELECT  DISTINCT Contract_Products.BSA_Foodservice_Items_Master_ID
				FROM Contract_Main
				INNER JOIN Program_Fixed_Component	
				ON Program_Fixed_Component.Program_ID = Contract_Main.Contract_Main_ID
				INNER JOIN Payment_Type ON
				Payment_Type.Payment_Type_ID = Program_Fixed_Component.Claim_Mechanics
				INNER JOIN Contract_Products
				ON    Contract_Products.Contract_Main_ID = Program_Fixed_Component.Program_ID
				AND    Contract_Products.Product_Type_ID = 1
				WHERE Contract_Main.Contract_Number = '#arguments.ContractNumber#'
				/* Below logic is the overlap logic */
				AND Contract_Main.Effective_Start_Date <= #CreateODBCDate(arguments.end_date)#
				AND Contract_Main.Effective_End_Date >= #CreateODBCDate(arguments.start_date)#
				AND Contract_Products.Deleted = 0
				AND Contract_Products.Is_Group = 0
				AND Program_Fixed_Component.deleted = 0
				AND Payment_Type.Is_Auto_Pay = 1	
				--->
				
				<cfif arguments.distributorIDList eq "">
					INSERT INTO ##Temp_Dist_List(BSA_Foodservice_Customers_ID)
					SELECT  DISTINCT Contract_Distributors.BSA_Foodservice_Customers_ID
					FROM Contract_Main
					INNER JOIN Contract_Distributors
					ON    Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
					WHERE Contract_Main.Contract_Number = '#arguments.ContractNumber#'
					<!--- Below logic is the overlap logic --->
					AND Contract_Main.Effective_Start_Date <= #CreateODBCDate(arguments.end_date)#
					AND Contract_Main.Effective_End_Date >= #CreateODBCDate(arguments.start_date)#
					AND Contract_Distributors.Deleted = 0
					AND Contract_Distributors.Is_Group = 0
				<cfelse>
				<cfloop list="#arguments.distributorIDList#" index="distid">
					INSERT INTO ##Temp_Dist_List (BSA_Foodservice_Customers_ID) 
					VALUES ('#distid#')
				</cfloop>
				</cfif>

			</cfif>
		
		INSERT INTO ##Temp_InvoiceData(Invoice_Header_ID,Shared_Invoice_Number,Purchase_Order,Pro_Number,Name,Shr_Ship_to,Invoice_Date,Invoice_Number,Distributor_ID,Total_Dollars,Total_Cases,Selected_Invoice_Header_ID)
		SELECT 	DISTINCT Invoice_Header.Invoice_Header_ID,Invoice_Header.shared_invoice_number,Invoice_Header.Purchase_Order,Invoice_Header.Pro_Number, BSA_Foodservice_Customers.Name
							,BSA_Foodservice_Customers.Shr_Ship_to,Invoice_Header.Invoice_Date
							,(Invoice_Header.Invoice_Version + '-' + Invoice_Header.Order_Number) AS Invoice_Number,Invoice_Header.BSA_Foodservice_Customers_ID AS Distributor_ID,
							SUM(cast(isnull(Invoice_Detail.Sales_Dollars, 0) as float)) 
							AS Total_Dollars,
							SUM(cast(isnull(Invoice_Detail.Cases_Invoiced, 0) as float))
							AS Total_Cases,
							<!--- For an existing report, get the selected invoices --->
							<cfif arguments.BBAutoReportID neq 0>
							BB_Auto_Report_Invoice_Filter.Invoice_Header_ID As Selected_Invoice_Header_ID
							<cfelse>
							'' As Selected_Invoice_Header_ID
							</cfif>
		FROM 	Invoice_Header
				INNER JOIN BSA_Foodservice_Customers
				ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Invoice_Header.BSA_Foodservice_Customers_ID
				INNER JOIN Invoice_Detail
				ON Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
				AND ISNULL(Invoice_Detail.Deleted,0) = 0

				<!--- To get the auto pay selected invoices --->
				<cfif arguments.BBAutoReportID neq 0>
				LEFT JOIN	BB_Auto_Report_Invoice_Filter	
				ON BB_Auto_Report_Invoice_Filter.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
				</cfif>				
				
				<!--- Filter below is used because we have a LEFT JOIN on "BB_Auto_Report_Distributor_Filter". To show all records, we
				need to add filter here.
				Note: When "arguments.showSelectedOnly" is 1, we will not get all records, but get only the selected records from the db. In that case,
				we need this same filter after the "WHERE" clause and this below filter will not be called.
				We want to ignore this when "arguments.showCurrentlySelectedOnly" is 0, because we want to see only the selected records in the form scope and
				not the unselected recods also.
				--->
				<cfif arguments.BBAutoReportID neq 0 AND arguments.showSelectedOnly eq 0 AND arguments.showCurrentlySelectedOnly eq 0>
				AND BB_Auto_Report_Invoice_Filter.Contract_Main_ID = '#arguments.Auto_Pay_Contract_ID#'
				AND BB_Auto_Report_Invoice_Filter.BB_Auto_Report_ID = '#arguments.BBAutoReportID#'
				AND BB_Auto_Report_Invoice_Filter.deleted = 0
				</cfif>
		
		<!--- No need to use filters when we want to see selected records only. --->
		<cfif arguments.showSelectedOnly eq 0 AND arguments.showCurrentlySelectedOnly eq 0>
				WHERE EXISTS
				(
					SELECT 1
					FROM  ##Temp_Dist_List
					WHERE BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = ##Temp_Dist_List.BSA_Foodservice_Customers_ID
				)
				
				<!--- Filter by the "date overlap" logic. --->
				AND Invoice_Header.Invoice_Date >= #CreateODBCDate(qGetProgramEffectiveDateSpan.Start_Date)#
				AND Invoice_Header.Invoice_Date <= #CreateODBCDate(qGetProgramEffectiveDateSpan.End_Date)#
				
				<!--- Do another filter by dates entered by the user on the auto pay report. --->
				AND Invoice_Header.Invoice_Date >= #CreateODBCDate(arguments.Start_Date)#
				AND Invoice_Header.Invoice_Date <= #CreateODBCDate(arguments.End_Date)#

			<!--- Distributor name --->
			<cfif arguments.distributor_name NEQ "">
				AND BSA_Foodservice_Customers.Name LIKE '%#arguments.distributor_name#%'
			</cfif>

			<!--- Ship To --->
			<cfif arguments.ship_to NEQ "">
				AND BSA_Foodservice_Customers.Shr_Ship_To LIKE '%#arguments.ship_to#%'
			</cfif>

			<!--- Invoice number --->
			<cfif len(trim(arguments.invoiceNumber)) GT 0>		
				AND Invoice_Header.Shared_Invoice_Number LIKE '%#arguments.invoiceNumber#%'
			</cfif>

			<!--- Order number --->
			<cfif len(trim(arguments.orderNumber)) GT 0>
				AND Invoice_Header.Pro_Number like '%#trim(arguments.orderNumber)#%'
			</cfif>

			<!--- Purchase order --->
			<cfif len(trim(arguments.customerPO)) GT 0>
				AND Invoice_Header.Purchase_Order LIKE '%#arguments.customerPO#%'
			</cfif>

			<!--- Dollar value --->
			<cfif arguments.dollar_operator neq "" and arguments.dollar_amount neq "">
				AND Invoice_Detail.Sales_Dollars #arguments.dollar_operator# '#arguments.dollar_amount#'
			</cfif>

				AND EXISTS
				(
					SELECT 1
					FROM  ##Temp_Prod_List
					WHERE Invoice_Detail.BSA_Foodservice_Items_Master_ID = ##Temp_Prod_List.BSA_Foodservice_Items_Master_ID
				)
		<cfelse>
		<!---  No need to do above logic when we need to get a count of existing invoices in the "BB_Auto_Report_Invoice_Filter" table. --->
		WHERE 1 = 1
		</cfif>
		
		<!--- For a new report, when programs are added by a user and the invoices are not added as yet, we want to return no
		records, so that the "count" next to "filter invoices" link shows "0 invoices selected". --->
		<cfif arguments.BBAutoReportID eq 0 AND arguments.showSelectedOnly eq 1>
		AND 1 = 0
		</cfif>

		<!--- Filter below is used only when we need the selected records only.
		Note: a similar filter is being used before the "WHERE" clause (above) too. In that case (arguments.showSelectedOnly = 0),
		we need all the records and not just the selected records.
		--->
		<cfif arguments.BBAutoReportID neq 0 AND arguments.showSelectedOnly eq 1>
		AND BB_Auto_Report_Invoice_Filter.Contract_Main_ID = '#arguments.Auto_Pay_Contract_ID#'
		AND BB_Auto_Report_Invoice_Filter.BB_Auto_Report_ID = '#arguments.BBAutoReportID#'
		AND BB_Auto_Report_Invoice_Filter.deleted = 0
		
		<!--- 	When "arguments.showCurrentlySelectedOnly" is 1,we want to see only the selected records in the form scope and
				not the unselected records.
		--->
		<cfelseif arguments.BBAutoReportID neq 0 AND arguments.showCurrentlySelectedOnly eq 1>
		AND Invoice_Header.Invoice_Header_ID IN (#ListQualify(arguments.invoiceList,"'")#)
		</cfif>

		GROUP BY Invoice_Header.shared_invoice_number,Invoice_Header.Purchase_Order,Invoice_Header.Pro_Number, BSA_Foodservice_Customers.Name
							,BSA_Foodservice_Customers.Shr_Ship_to,Invoice_Header.Invoice_Date,Invoice_Header.Invoice_Version 
							,Invoice_Header.Order_Number,Invoice_Header.BSA_Foodservice_Customers_ID,Invoice_Header.Invoice_Header_ID
							<cfif arguments.BBAutoReportID neq 0>
							,BB_Auto_Report_Invoice_Filter.Invoice_Header_ID
							</cfif>

			<!--- Ordering here is important. This way we can assign correct "rowIDInt" values, which can then be used for getting correct records when paging. --->
			<cfswitch expression="#arguments.column_sequence_number#">
				 <cfcase value=1>ORDER BY Invoice_Header.shared_invoice_number</cfcase>
				 <cfcase value=2>ORDER BY Invoice_Header.Purchase_Order</cfcase>
				 <cfcase value=3>ORDER BY Invoice_Header.Pro_Number</cfcase>
				 <cfcase value=4>ORDER BY BSA_Foodservice_Customers.Name</cfcase>
				 <cfcase value=5>ORDER BY Invoice_Header.Invoice_Date</cfcase>
				 <cfcase value=6>ORDER BY (Invoice_Header.Invoice_Version + '-' + Invoice_Header.Order_Number)</cfcase>
				 <cfcase value=7>ORDER BY SUM(cast(isnull(Invoice_Detail.Sales_Dollars, 0) as float)) </cfcase>
				 <cfcase value=8>ORDER BY SUM(cast(isnull(Invoice_Detail.Cases_Invoiced, 0) as float))</cfcase>
			</cfswitch>
			#arguments.sort_order#
			 
			 <!--- Total number of records --->
			SELECT count(Invoice_Header_ID) As recordTotalCount  
			FROM ##Temp_InvoiceData
		</CFQUERY>			

		<CFQUERY name="qGetReportInvoicesResults" datasource="#application.datasource#">
			SELECT * FROM ##Temp_InvoiceData
			<!--- Query usng a range to return what is needed for paging. --->	
			<cfif arguments.startRow eq 0>
			WHERE 1 = 1
			<cfelse>
			WHERE rowIDInt >= #arguments.startRow#
			AND rowIDInt <= #arguments.endRow#
			</cfif>

			ORDER BY rowIDInt ASC

		</CFQUERY>

		<!--- Total records --->
		<cfset returnStruct.recordTotal = qGetReportInvoices.recordTotalCount>

		<!--- records query --->
		<cfset returnStruct.resultsQueryName = qGetReportInvoicesResults>

		<cfreturn returnStruct />
	</cffunction>

	
	<cffunction name="getIsAnAutoPayExceptionReport" access="public" returntype="boolean" output="false">
		<cfargument name="ReportId"	required="yes" type="string" default="0" />
		
		<cfset var IsAnAutoPayExceptionReport = 0>

		<CFQUERY NAME="qGetIsAnAutoPayExceptionReport" datasource="#application.datasource#">
			SELECT COUNT(BB_Auto_Report_Distributor_Filter_ID) As ExceptionCount
			FROM BB_Auto_Report_Distributor_Filter
			WHERE BB_Auto_Report_ID = '#arguments.ReportId#'
			AND deleted = 0
		</CFQUERY>
		
		<cfif qGetIsAnAutoPayExceptionReport.ExceptionCount EQ 0>
			<CFQUERY NAME="qGetIsAnAutoPayExceptionReport" datasource="#application.datasource#">
				SELECT COUNT(BB_Auto_Report_Invoice_Filter_ID) As ExceptionCount
				FROM BB_Auto_Report_Invoice_Filter
				WHERE BB_Auto_Report_ID = '#arguments.ReportId#'
				AND deleted = 0
			</CFQUERY>
		</cfif>
		
		<!--- If there are either distributor OR invoice records, the report is an exception report. --->
		<cfif qGetIsAnAutoPayExceptionReport.ExceptionCount GT 0>
				<cfset IsAnAutoPayExceptionReport = 1>
		</cfif>

		<cfreturn IsAnAutoPayExceptionReport />
	</cffunction>

	<cffunction name="getIncludeExceptionReportFeatures" access="public" returntype="boolean" output="false">
		<cfargument name="ContractNumber"	required="yes" type="string" />
		<cfargument name="start_date"	required="yes" type="string"  />
		<cfargument name="end_date"	required="yes" type="string"  />
		
		<cfset var includeExceptionReportFeatures = 1>
		
		<CFQUERY NAME="qGetIncludeExceptionReportFeatures" datasource="#application.datasource#">
			SELECT  COUNT(Program_Growth_Components.Program_ID) As Component_Count
			FROM Contract_Main
			INNER JOIN Program_Growth_Components	
			ON Program_Growth_Components.Program_ID = Contract_Main.Contract_Main_ID
			INNER JOIN Payment_Type ON
			Payment_Type.Payment_Type_ID = Program_Growth_Components.Claim_Mechanics
			WHERE Contract_Main.Contract_Number = '#arguments.ContractNumber#'
			<!--- Below logic is the overlap logic --->
			AND Contract_Main.Effective_Start_Date <= #CreateODBCDate(arguments.end_date)#
			AND Contract_Main.Effective_End_Date >= #CreateODBCDate(arguments.start_date)#
			AND Program_Growth_Components.deleted = 0
			AND Payment_Type.Is_Auto_Pay = 1

			UNION

			SELECT  COUNT(Program_Lump_Sums.Program_ID) As Component_Count
			FROM Contract_Main
			INNER JOIN Program_Lump_Sums	
			ON Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID
			INNER JOIN Payment_Type ON
			Payment_Type.Payment_Type_ID = Program_Lump_Sums.Claim_Mechanics
			WHERE Contract_Main.Contract_Number = '#arguments.ContractNumber#'
			<!--- Below logic is the overlap logic --->
			AND Contract_Main.Effective_Start_Date <= #CreateODBCDate(arguments.end_date)#
			AND Contract_Main.Effective_End_Date >= #CreateODBCDate(arguments.start_date)#
			AND Program_Lump_Sums.deleted = 0
			AND Payment_Type.Is_Auto_Pay = 1

			UNION

			SELECT  COUNT(Program_Fixed_Component.Program_ID)
			FROM Contract_Main
			INNER JOIN Program_Fixed_Component	
			ON Program_Fixed_Component.Program_ID = Contract_Main.Contract_Main_ID
			INNER JOIN Payment_Type ON
			Payment_Type.Payment_Type_ID = Program_Fixed_Component.Claim_Mechanics
			WHERE Contract_Main.Contract_Number = '#arguments.ContractNumber#'
			<!--- Below logic is the overlap logic --->
			AND Contract_Main.Effective_Start_Date <= #CreateODBCDate(arguments.end_date)#
			AND Contract_Main.Effective_End_Date >= #CreateODBCDate(arguments.start_date)#
			AND Program_Fixed_Component.deleted = 0
			AND Payment_Type.Is_Auto_Pay = 1
		</CFQUERY>
		
		<!---  Check to see whether aby non-rebate component is on the program. If yes, do not allow exception report for that program. 
		Exception report is for rebate only.
		--->
		<cfif qGetIncludeExceptionReportFeatures.Component_Count GT 0>
				<cfset includeExceptionReportFeatures = 0>
		</cfif>

		<cfreturn includeExceptionReportFeatures />
	</cffunction>


	<cffunction name="getOpenPayPeriods" access="public" returntype="query" output="false">
		<cfargument name="search_Start_Date" required="yes" type="string" />
		<cfargument name="search_End_Date" required="yes" type="string" />
		<!---
		Note: The query to show all pay periods will be slow as we need to call UDF per program to populate
		the pay periods temp table, from which we can figure out the open pay periods.
		So, we decided to just show the open pay periods in a different way.
		e.g. An auto pay component pays monthly every month for 2017.
		If today is June 2017 and the auto pay has run from March to June, we will show the following
		as the open pay period -
		Jan 1st - 28th Feb and NOT as 2 records - Jan 1st, 2017 - 31st Jan, 2017 and Feb 1st, 2017 - Feb 28th, 2017.
		--->
		<cfquery name="delTbl" datasource="#application.datasource#">
			IF object_id('tempdb..##Tmp_PrgList') is not null
			DROP TABLE ##Tmp_PrgList
			
			IF object_id('tempdb..##tmp_Open_Pay_Periods') is not null
			DROP TABLE ##tmp_Open_Pay_Periods

			IF object_id('tempdb..##tmp_Numbers') is not null
			DROP TABLE ##tmp_Numbers	
			
			IF object_id('tempdb..##AllDates') is not null
			DROP TABLE ##AllDates
		</cfquery>

		<cfquery name="qGetOpenPayPeriods" datasource="#application.datasource#">
			DECLARE @Start datetime,@End datetime
			
			/* STEP 1 - Get a list of programs which have auto pay ON for the "search period". */
			SELECT 	Contract_Main.Contract_Main_ID
					,Contract_Main.Contract_Number
					,Contract_Main.Effective_Start_Date
					,Contract_Main.Effective_End_Date
					,Contract_Main.contract_title
			INTO ##Tmp_PrgList
			FROM Program_Rebates_Component PRC	
			INNER JOIN Payment_Type ON
			Payment_Type.Payment_Type_ID = PRC.Claim_Mechanics
			INNER JOIN Contract_Main
			ON Contract_Main.Contract_Main_ID = PRC.Program_ID
			WHERE Contract_Main.Effective_End_Date >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.search_Start_Date#">
			AND Contract_Main.Effective_Start_Date <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.search_End_Date#">
			AND PRC.deleted = 0
			/* "Auto pay" must be ON for the claim mechanism. */
			AND Payment_Type.Is_Auto_Pay = 1
			
			UNION
			
			SELECT 	Contract_Main.Contract_Main_ID
					,Contract_Main.Contract_Number
					,Contract_Main.Effective_Start_Date
					,Contract_Main.Effective_End_Date
					,Contract_Main.contract_title
			FROM Program_Growth_Components PRC
			INNER JOIN Payment_Type ON
			Payment_Type.Payment_Type_ID = PRC.Claim_Mechanics
			INNER JOIN Contract_Main
			ON Contract_Main.Contract_Main_ID = PRC.Program_ID
			WHERE Contract_Main.Effective_End_Date >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.search_Start_Date#">
			AND Contract_Main.Effective_Start_Date <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.search_End_Date#">
			AND PRC.deleted = 0
			/* "Auto pay" must be ON for the claim mechanism. */
			AND Payment_Type.Is_Auto_Pay = 1
			
			UNION
			
			SELECT 	Contract_Main.Contract_Main_ID
					,Contract_Main.Contract_Number
					,Contract_Main.Effective_Start_Date
					,Contract_Main.Effective_End_Date
					,Contract_Main.contract_title
			FROM Program_Fixed_Component PRC	
			INNER JOIN Payment_Type ON
			Payment_Type.Payment_Type_ID = PRC.Claim_Mechanics
			INNER JOIN Contract_Main
			ON Contract_Main.Contract_Main_ID = PRC.Program_ID
			WHERE Contract_Main.Effective_End_Date >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.search_Start_Date#">
			AND Contract_Main.Effective_Start_Date <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.search_End_Date#">
			AND PRC.deleted = 0
			/*  "Auto pay" must be ON for the claim mechanism. */
			AND Payment_Type.Is_Auto_Pay = 1
			
			UNION
			
			SELECT	Contract_Main.Contract_Main_ID
					,Contract_Main.Contract_Number
					,Contract_Main.Effective_Start_Date
					,Contract_Main.Effective_End_Date
					,Contract_Main.contract_title
			FROM Program_Lump_Sums PRC	
			INNER JOIN Payment_Type ON
			Payment_Type.Payment_Type_ID = PRC.Claim_Mechanics
			INNER JOIN Contract_Main
			ON Contract_Main.Contract_Main_ID = PRC.Program_ID
			WHERE Contract_Main.Effective_End_Date >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.search_Start_Date#">
			AND Contract_Main.Effective_Start_Date <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.search_End_Date#">
			AND PRC.deleted = 0
			/*  "Auto pay" must be ON for the claim mechanism. */
			AND Payment_Type.Is_Auto_Pay = 1
			

			/*  STEP 2 - Since the the user will search for one fiscal year at a time,which should be around 365 days.
			Populating 500 records should be safe, as it is more than 365
			*/
			SELECT TOP 500 IDENTITY(int,1,1) AS Number
			INTO ##tmp_Numbers
			FROM sys.objects s1
			CROSS JOIN sys.objects s2

			SELECT @Start = '#arguments.search_Start_Date#', @End = '#arguments.search_End_Date#'

			CREATE TABLE ##AllDates(day datetime)

			/* Here the goal is to create a temp table with records for the dates of the fiscal period for which the user has searched.s
			eg: 1/1/2017,1/2/2017,1/3/2017....12/31/2017.
			*/
			INSERT INTO ##AllDates(day)
			SELECT @Start+Number-1
			FROM ##tmp_Numbers
			WHERE Number<=DATEDIFF(day,@Start,@End)+1

			/*  STEP 3 - 		
			This query will populate a temp table with all the individual dates of the fiscal period for which the user
			is searching. Eg: 2017 or 2016, as long as it is within the effective dates of the program and those dates
			do not exist with the "payment start" and "payment end" dates in the BB_Auto_Program_Pay_Period table.
			*/
			SELECT DISTINCT t.*, d.Day, CAST(null as DATE) as Range_Start, CAST(null as DATE) as Range_End
			INTO	##tmp_Open_Pay_Periods
			FROM	##Tmp_PrgList t
			INNER JOIN ##AllDates d
			ON		d.Day BETWEEN t.Effective_Start_Date AND t.Effective_End_Date
			/* Payment start date is not in the future
			AND d.Day <= getdate()
			*/
			WHERE	NOT EXISTS
			(
				/* Dev Note (70167) - Note: We are using "Contract_Main" and not "##Tmp_PrgList" in the below subquery because we want to take into 
				consideration all the versions of a program. This is needed because of the following reason -
				If a program has multiple versions and the latest version of a program does not have a particular pay period in the 
				"BB_Auto_Program_Pay_Period" table, but a previous version does, then we should not consider it as an open pay period
				as a previous version has already covered it.
				*/
				SELECT 1
				FROM   Contract_Main cm2
				INNER JOIN BB_Auto_Program_Pay_Period t2
				ON		t2.Program_ID = cm2.Contract_Main_ID
				WHERE cm2.Contract_Number = t.Contract_Number
				AND		t2.Deleted = 0	
				AND	
				/* A report ID is currently associated with the record. */
				(t2.BB_Auto_Report_id IS NOT NULL
				/* Report is either "Scheduled" or "deleted" */
				AND		t2.Status NOT IN (1,9)
				)
				AND		d.Day BETWEEN t2.Payment_Start_Date AND t2.Payment_End_Date
			)
			ORDER BY t.Contract_Number, d.Day
			
			/* This will populate the first record of every missing period in the program.
				The objective here is to populate that record which does not have a record in the db
				for a date prior to that date.
				eg:
				For the following records, Range_Start for "2017-12-15" will get populated because "2017-12-14"
				does not exist for that program in  the table.
				Also, "2017-12-25" will get populated because "2017-12-24" does not exist.

				2017-12-15
				2017-12-16
				2017-12-17
				2017-12-18
				2017-12-25
				2017-12-26
				2017-12-27
			*/
			UPDATE ##tmp_Open_Pay_Periods
			SET		Range_Start = Day
			WHERE	NOT EXISTS 
			(
			SELECT 1 FROM ##tmp_Open_Pay_Periods d2 WHERE d2.Day = DateAdd(d, -1, ##tmp_Open_Pay_Periods.Day)
			AND d2.Contract_Number = ##tmp_Open_Pay_Periods.Contract_Number
			)

			/* This will populate the last record of every program.
				The objective here is to populate that record which does not have a record in the db
				for a date later to that date.
				eg:
				For the following records, Range_Start for 2017-12-18" will get populated because "2017-12-19"
				does not exist for that program in the table.
				Also, "2017-12-27" will get populated because "2017-12-28" does not exist.

				2017-12-15
				2017-12-16
				2017-12-17
				2017-12-18
				2017-12-25
				2017-12-26
				2017-12-27
			*/
			UPDATE ##tmp_Open_Pay_Periods
			SET		Range_End = Day
			WHERE	NOT EXISTS 
			(
			SELECT 1 FROM ##tmp_Open_Pay_Periods d2 WHERE d2.Day = DateAdd(d, 1, ##tmp_Open_Pay_Periods.Day)
			AND d2.Contract_Number = ##tmp_Open_Pay_Periods.Contract_Number
			)
			/* This will populate the first record of every missing period in the program with the "Range_End".
			Basically, it will take the "Range_End" of the last record in the missing period and put it as the "Range_End"
			of the first record.
			This way we can get missing periods.
			In the above example, if the effective date of the program was from 2017-12-15 to 2017-12-31, then
			the missing payment periods are from 2017-12-15 - 2017-12-18 and 2017-12-25 - 2017-12-27. Rest of the
			periods already exist in the "BB_Auto_Program_Pay_Period" table.
			*/
			UPDATE ##tmp_Open_Pay_Periods
			SET		Range_End = (SELECT Min(Range_End) FROM ##tmp_Open_Pay_Periods d2 WHERE d2.Day > ##tmp_Open_Pay_Periods.Day
								AND d2.Contract_Number = ##tmp_Open_Pay_Periods.Contract_Number
								)
			WHERE	Range_Start IS NOT NULL
			AND Range_End IS NULL
			
			/* open pay periods. 
			(Note: For clients using "manual auto pay", we will not show monthly or quarterly etc
			pay period records. We will just show the missing periods. Showing all the records will 
			make the process slow, as we need to call a UDF per program.			
			*/
			SELECT DISTINCT Contract_Main_ID, Contract_Number, Effective_Start_Date, Effective_End_Date,
					contract_title, Range_Start as Start_Date, Range_End as End_Date
			FROM	##tmp_Open_Pay_Periods
			WHERE Range_Start IS NOT NULL
			AND Range_End IS NOT NULL
			ORDER BY Contract_Number,Range_Start DESC
			</cfquery>

		<cfreturn qGetOpenPayPeriods>
			
	</cffunction>

	<cffunction name="getExceptionReportDistributorsForExcelReport" access="public" returntype="query" output="false">
		<cfargument name="BBAutoReportID" type="string" required="true" default="0" />

		<CFQUERY NAME="qGetExceptionReportDistributorsForExcelReport" datasource="#application.datasource#">
		SELECT DISTINCT 
				BSA_Foodservice_Customers.Shr_Ship_To As '#application.returned_customer_setting.shard_ship_to_label#',
				BSA_Foodservice_Customers.Name As '#application.returned_customer_setting.distributor_label_singular# Name',				
				BSA_Foodservice_Customers.Address_1 + char(13) + BSA_Foodservice_Customers.City + ',' + BSA_Foodservice_Customers.State As Address,
				Distributor_Family.Family_Name As '#application.returned_customer_setting.family_name_label_singular#',
				Distributor_Buying_Groups.Buying_Group_Name As '#application.returned_customer_setting.buying_group_label_singular#'				
		FROM
				BSA_Foodservice_Customers
				INNER JOIN	BB_Auto_Report_Distributor_Filter         
				ON BB_Auto_Report_Distributor_Filter.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID   
				
				INNER JOIN	Distributor_Family
				ON
				BSA_Foodservice_Customers.Family_ID = Distributor_Family.Family_ID

				INNER JOIN	Distributor_Buying_Groups
				ON
				BSA_Foodservice_Customers.Buying_Group_ID = Distributor_Buying_Groups.Buying_Group_ID
				
				WHERE BB_Auto_Report_Distributor_Filter.BB_Auto_Report_ID = '#arguments.BBAutoReportID#'
				AND BB_Auto_Report_Distributor_Filter.deleted = 0

				ORDER BY BSA_Foodservice_Customers.Name
		</CFQUERY>

		<cfreturn qGetExceptionReportDistributorsForExcelReport />
	</cffunction>

	<cffunction name="getExceptionReportInvoicesForExcelReport" access="public" returntype="query" output="false">
		<cfargument name="BBAutoReportID" type="string" required="true" default="0" />

		<cfset labelsObject = createObject("component", "components.settings.labels.labels").init()>
		<cfset orderNumberLabel = labelsObject.GetGeneralLabels(labelDescription = "Order Number")>

		<CFQUERY NAME="qGetExceptionReportInvoicesForExcelReport" datasource="#application.datasource#">
		SELECT DISTINCT Invoice_Header.shared_invoice_number As 'Invoice Number',Invoice_Header.Purchase_Order As 'PO Number',
					Invoice_Header.Pro_Number As '#orderNumberLabel.General_Labels_Label#',BSA_Foodservice_Customers.Name
					As '#application.returned_customer_setting.distributor_label_singular#'
					,CONVERT(Char(10),Invoice_Header.Invoice_Date,101) As 'Invoice Date'
					<cfif application.returned_customer_setting.shared_invoice IS 1>
					,(Invoice_Header.Invoice_Version + '-' + Invoice_Header.Order_Number) AS 'Legacy Invoice ##'
					</cfif>
					,SUM(cast(isnull(Invoice_Detail.Sales_Dollars, 0) as float)) 
					AS 'Total $'
					,SUM(cast(isnull(Invoice_Detail.Cases_Invoiced, 0) as float))
					AS 'Total Cases'
		FROM	Invoice_Header
				INNER JOIN BSA_Foodservice_Customers
				ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Invoice_Header.BSA_Foodservice_Customers_ID

				INNER JOIN Invoice_Detail
				ON Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
				AND ISNULL(Invoice_Detail.Deleted,0) = 0

				INNER JOIN	BB_Auto_Report_Invoice_Filter 
				ON BB_Auto_Report_Invoice_Filter.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID         
				
				WHERE BB_Auto_Report_Invoice_Filter.BB_Auto_Report_ID = '#arguments.BBAutoReportID#'
				AND BB_Auto_Report_Invoice_Filter.deleted = 0

				GROUP BY Invoice_Header.shared_invoice_number,Invoice_Header.Purchase_Order,Invoice_Header.Pro_Number
				,BSA_Foodservice_Customers.Name,Invoice_Header.Invoice_Date
				<cfif application.returned_customer_setting.shared_invoice IS 1>
				,Invoice_Header.Invoice_Version,Invoice_Header.Order_Number
				</cfif>
				ORDER BY Invoice_Header.shared_invoice_number
		</CFQUERY>

		<cfreturn qGetExceptionReportInvoicesForExcelReport />
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