<cfcomponent hint="All Database updates fror BBauto report Process">
    <cffunction name="init" output="false" returntype="components.billback.BBAutoReportUpdate">
        <!--- Initialize Main Objects --->
        <cfif NOT structKeyExists(application,"oBBReportGet")>
            <cfset application.oBBReportAjaxCaller = CreateObject("component","components.Billback.BBAutoReportAjaxCaller").init() />
            <cfset application.oBBReportGet = CreateObject("component","components.Billback.BBAutoReportGet").init() />
            <cfset application.oBBReportUpdate = CreateObject("component","components.Billback.BBAutoReportUpdate").init() />
            <cfset application.oBBReportPeriod = CreateObject("component","components.Billback.BB_Auto_Report_Period") />
            <cfset application.oBBReportPeriodGateway = CreateObject("component","components.Billback.BB_Auto_Report_PeriodGateway") />
        </cfif>
        <cfreturn this />
    </cffunction>

<!---
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXX   Data Action Functions:  update/insert
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--->
<!--- XXXXXXXXXXXX  populatePeriods XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
    <cffunction name="populatePeriods" access="public" returntype="void" output="FALSE">
    <cfset var qInsertDate = "" />

        <CFQUERY  dataSource="#application.datasource#" NAME="qInsertDate">
            EXEC BB_Auto_Populate_Report_Period
        </CFQUERY>
    </cffunction>

<!--- XXXXXXXXXXXX  (Un)Lock Report XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
    <cffunction name="lockReport" access="public" returntype="numeric">
        <cfargument name="userId"   required="yes" type="any" />
        <cfargument name="status"   required="yes" type="any" />

        <cfset var qLockReport = "" />
        <cfset var tmpLock = "" />
        <cfset var tmpLockme = "" />
        <cfset tmp = this.init() />
        <cfset this.oGet    =  application.oBBReportGet />
        <cfif this.oGet.getReportLock(arguments.userId) eq 0 OR (arguments.status eq 0 and this.oGet.getReportLockByMe(arguments.userId) eq 1)>
            <CFQUERY DATASOURCE="#application.datasource#" NAME="qLockReport">
                BEGIN TRANSACTION;
                    --CLEAR DUPES
                    DELETE FROM BB_Auto_Report_Lock
                    WHERE EXISTS(SELECT * FROM BB_Auto_Report_Lock HAVING COUNT(*) > 1)
                    --INSERT IN CASE WE HAD DUPES
                    INSERT BB_Auto_Report_Lock
                    (Locked) SELECT 0
                    WHERE NOT EXISTS(SELECT Locked FROM BB_Auto_Report_Lock)
                    --SET LOCK
                    UPDATE BB_Auto_Report_Lock
                    SET
                        Locked_By_User_ID = '#arguments.userId#',
                        Locked_Date = GetDate(),
                        Locked = '#arguments.status#'
                COMMIT TRANSACTION;
            </CFQUERY>
        </cfif>
        <!--- update request scope by calling functions w/param 2 as 0 incase it is already set for future calls --->
            <cfset tmpLock = this.oGet.getReportLock(arguments.userId,0) />
            <cfset tmpLockme = this.oGet.getReportLockByMe(arguments.userId,0) />
        <cfreturn this.oGet.getReportLock() />
    </cffunction>

    <cffunction name="lock_auto_pay" access="remote">   <!--- 48219 --->
        <cfargument name="userId" required="yes"/>
        <cfargument name="lock" required="yes"/>

        <cfset local.lock_message = "Unable to lock auto pay, please try again later.">
        <cflock name="lock_auto_pay" type="exclusive" timeout="7" throwontimeout="false">
            <cfset local.lock_message = "">
            <cfquery name="local.auto_pay" datasource="#application.datasource#">
                INSERT BB_Auto_Report_Lock (Locked)
                    SELECT 0
                 WHERE NOT EXISTS (SELECT Locked FROM BB_Auto_Report_Lock)
                SELECT * FROM BB_Auto_Report_Lock
            </cfquery>

            <!--- attempt to lock --->
            <cfif arguments.lock eq '1' and local.auto_pay.locked eq '0'>
                <cfquery name="local.update" datasource="#application.datasource#">
                    UPDATE BB_Auto_Report_Lock
                       SET Locked_By_User_ID = <cfqueryparam value='#arguments.userId#'>,
                           Locked_Date = GetDate(),
                           Locked = <cfqueryparam value='#arguments.lock#'>
                </cfquery>

            <!--- attempt to unlock --->
            <cfelseif arguments.lock eq '0' and local.auto_pay.Locked_By_User_ID eq arguments.userId>
                <cfquery name="local.update" datasource="#application.datasource#">
                    UPDATE BB_Auto_Report_Lock
                       SET Locked = <cfqueryparam value='#arguments.lock#'>
                </cfquery>
            </cfif>
        </cflock>

        <cfreturn local.lock_message/>
    </cffunction>


<!--- XXXXXXXXXXXX  UnLock Old Report Based on Session Status   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
    <cffunction name="UnlockReport" access="public" returntype="void">

        <cfset var qUnLockReport = "" />
        <cfset var DeleteAll = "" />

        <CFQUERY DATASOURCE="#application.datasource#" NAME="qUnLockReport">
            UPDATE      BB_Auto_Report_Lock
            SET     Locked = 0
            FROM BB_Auto_Report_Lock
                INNER JOIN _Users ON
                    Locked_By_User_ID = _Users.User_ID
                LEFT JOIN Session_Tracker ON
                    Session_Tracker.Session_User_ID = _Users.User_ID
                INNER JOIN General_Settings
                    ON 1=1
            WHERE
                Locked = 1
                AND
                (
                    Session_ID IS NULL
                    --No Valid Session
                    OR
                    (CAST(DateDiff(s, Session_Date_Time_Stamp, GetDate()) AS FLOAT)/(24.00*60.00*60.00)) > Session_Expiration_Length
                    --session is no longer valid
                )
            </CFQUERY>

        <!--- This deletes any old report files --->
        <cfset DeleteAll = this.DeleteReports() />

    </cffunction>

    <cffunction name="DeleteReports" output="true" access="public" returntype="void">

        <cfset var fileDir = "#Application.Doc_Path#\Temp_Files\Billback\AutoPayReport\" />
        <cfset var AutoPayFiles = "">


        <!---loop over the dir and delete all the files--->
        <cfdirectory directory="#fileDir#" action="list" name="AutoPayFiles" recurse="false">

        <cfoutput query="AutoPayFiles">
            <cfif name NEQ "CVS">
                <cffile action = "delete" file = "#fileDir##name#">
            </cfif>
        </cfoutput>
    </cffunction>

    <!--- XXXXXXXXXXXX  setReportStatus XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
    <cffunction name="setReportProcess" access="remote" returntype="void">
        <cfargument name="status" required="yes" type="numeric" />

        <cfquery datasource="#application.datasource#" name="local.query">
            UPDATE BB_Auto_Report_Lock
               SET Processing = <cfqueryparam value='#arguments.status#'>
        </CFQUERY>
    </cffunction>

<!--- XXXXXXXXXXXX  Create Report   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
    <cffunction name="createReport" access="public" returntype="numeric">
        <cfargument name="periodID"     required="yes"  type="numeric" />
        <cfargument name="userId"       required="yes"  type="any" />
        <cfargument name="status"       required="no"   type="numeric" default="1" />
        <cfargument name="Report_Title" required="no"   type="string" default="">
        <cfset var qInsertReport = "" />
        <cfset var isManual = 0 />

        <cfif arguments.status EQ -1>
            <cfset isManual = 1 />
        </cfif>
        <cfscript>
            var s = arguments.Report_Title;
            if(s == ''){
                s = 'Auto Generated: ' & DateFormat(NOW(), 'mm/dd/yyyy') & ' ' &  TimeFormat(NOW(), 'hh:mm tt');
            }

        </cfscript>
            <!--- Insert new report record --->
            <CFQUERY DATASOURCE="#application.datasource#" NAME="qInsertReport">
                INSERT INTO bb_auto_report
                (BB_Auto_Report_Period_ID,updated_User_ID,updated_Date,Status,Report_Title,Is_Manual)
                VALUES
                ('#arguments.periodID#','#arguments.userId#',GetDate(),#arguments.status#,'#s#',#isManual#)

                SELECT @@identity as report_id
            </CFQUERY>
            <!--- if status = -1 then the user adds the programs to the report manually, so don't flag payPeriods --->
            <cfif arguments.status NEQ -1>
                <cfscript>
                    this.updatePayPeriod(   arguments.periodID,
                                            arguments.userId,
                                            arguments.status,
                                            qInsertReport.report_id);
                </cfscript>
            </cfif>
            <cfreturn qInsertReport.report_id />
    </cffunction>

    <!--- XXXXXXXXXXXX  Save Programs to a Report   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
    <cffunction name="saveBBReportProgram" access="public" returntype="numeric" output="true">
        <cfargument name="reportID" required="yes"  type="numeric" />
        <cfargument name="userId"   required="yes" type="any" />
        <cfargument name="programList"  required="no" type="string" default="0" />
	<cfargument name="formvars"  required="no" type="struct"  />

        <cfset var qInsertReport = "" />
        <cfset var qCreateTmp = "" />
        <cfset var qInsProgID = "" />
        <cfset var i = "" />
        <cfset var Program_Id = 0 />
        <cfset var qUpdReport = "" />
        <cfset var qGetID = "" />
        <cfset var qInsertPayPeriod = "" />
        <cfset var qUpdpayPeriods = "" />


        <!--- <CFLOG file="AutoPay.txt" text="#arguments.programList#"> --->
            <CFQUERY DATASOURCE="#application.datasource#" NAME="qCreateTmp">
                --Create temp table to hold program list
                IF OBJECT_ID ('tempAutoPayProgramList', 'U') IS NULL
                BEGIN
                    CREATE TABLE tempAutoPayProgramList
                    (
                        Program_ID INT
                    )
                END
                TRUNCATE TABLE tempAutoPayProgramList
            </CFQUERY>

            <CFLOOP list="#Arguments.programList#" index="i">
                <CFQUERY DATASOURCE="#application.datasource#" NAME="qGetLatestRevision">
                    SELECT Contract_Main_Id
                    FROM Contract_Main
                    WHERE Contract_Number = (SELECT Contract_Number From
                                                Contract_Main
                                                WHERE Contract_Main_Id = #i#) AND
                            Deleted = 0 AND
                            Approved =  1
                            AND Contract_Status_type_Idx != 4
                </CFQUERY>
                <cfoutput>
                    <cfset Program_Id = qGetLatestRevision.Contract_Main_Id />
                </cfoutput>
                <cfif NOT isNumeric(Program_Id)>
                    <cfset Program_Id = 0 />
                </cfif>
                <CFQUERY DATASOURCE="#application.datasource#" NAME="qInsProgID">
                    INSERT INTO tempAutoPayProgramList (Program_Id)
                    VALUES (#Program_Id#)
                </CFQUERY>
            </CFLOOP>


            <!--- update report status --->
            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdReport">
                UPDATE bb_auto_report
                SET Status = 1,
                    updated_User_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userId#">,
                    updated_Date = getDate()
                WHERE bb_auto_report_id = <cfqueryparam cfsqltype="numeric" value="#arguments.reportID#">
            </CFQUERY>

            <CFQUERY DATASOURCE="#application.datasource#" NAME="qGetID">
                --TRUNCATE TABLE ##tempAutoPayProgramList
                SELECT top 1 Program_ID FROM tempAutoPayProgramList
            </CFQUERY>

            <CFQUERY  dataSource="#application.datasource#" NAME="qInsertPayPeriod">
                EXEC BB_Auto_Populate_Program_Pay_Periods 0,#arguments.reportID#
            </CFQUERY>

		<!---
		/********************************************************* (START)INSERT DISTRIBUTORS FOR AUTO PAY ****************************************************************/
		--->


			<!--- Loop through the form.  --->
			<cfloop collection = "#arguments.formvars#" item = "FieldName">
				<!--- Look for formfield names starting from "Filterdistributors_". The formfield name will have the
				"Filterdistributors_contractMainID" naming convention.
				--->
				<cfif left(FieldName, 19) IS "Filterdistributors_">
					<cfset fieldLength = len(FieldName)>
					<cfset programID = Mid(FieldName,20,(fieldLength - 20 + 1))>

					<!--- "BB_Auto_Populate_Program_Pay_Periods" SP (above) inserts into "BB_Auto_Program_Pay_Period" table.
					Get the BB_Auto_Program_Pay_Period_ID for the "BB_Auto_Report_ID".
					--->
					<CFQUERY  DATASOURCE="#application.datasource#" NAME="getBBAutoProgramPayPeriodID">
					SELECT BB_Auto_Program_Pay_Period_ID
					FROM BB_Auto_Program_Pay_Period
					WHERE BB_Auto_Report_ID = '#arguments.reportID#'
					AND Program_ID = '#programID#'
					</CFQUERY>

					<!--- "-1" means that the user either did not select any distributors OR did not change any previously selected distributors.
					If the distributor list is empty, then distributor_id would be ""(blank) and not 0(zero).
					--->
					<cfif Evaluate(FieldName) neq "-1">
						<CFQUERY  DATASOURCE="#application.datasource#" NAME="updBBAutoReportDistributorFilter">
							UPDATE BB_Auto_Report_Distributor_Filter
							SET deleted  = 1
							WHERE BB_Auto_Report_ID = '#arguments.reportID#'
							AND Contract_Main_ID = '#programID#'
						</CFQUERY>
					</cfif>

					<!--- get the distributorID's for the selected programs. --->
						<cfloop list="#Evaluate(FieldName)#" index="distributor_id">
							<!--- "-1" means that the user either did not select any distributors OR did not change any previously selected distributors.
							If the distributor list is empty, then distributor_id would be ""(blank) and not 0(zero).
							--->
							<cfif distributor_id neq "-1">
								<cfset useLakebaseForqSaveDistributors = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_auto_report_distributor_filter")>
<cfif useLakebaseForqSaveDistributors>
	<cftry>
		<cfset application.oLakebase.insertRow("bb_auto_report_distributor_filter", {
			"bb_auto_program_pay_period_id" = "#getBBAutoProgramPayPeriodID.BB_Auto_Program_Pay_Period_ID#",
			"bb_auto_report_id" = "#arguments.reportID#",
			"distributor_id" = "#distributor_id#",
			"contract_main_id" = "#programID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqSaveDistributors = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqSaveDistributors>
<CFQUERY name="qSaveDistributors" DATASOURCE="#application.datasource#">
									INSERT INTO BB_Auto_Report_Distributor_Filter(BB_Auto_Program_Pay_Period_ID,BB_Auto_Report_ID,Distributor_ID,Contract_Main_ID)
									VALUES('#getBBAutoProgramPayPeriodID.BB_Auto_Program_Pay_Period_ID#','#arguments.reportID#','#distributor_id#','#programID#')
								</CFQUERY>
</cfif>
							</cfif>
						</cfloop>
				</cfif>

				<!--- Look for formfield names starting from "Filterinvoices_". The formfield name will have the
				"Filterinvoices_contractMainID" naming convention.
				--->
				<cfif left(FieldName, 15) IS "Filterinvoices_">
					<cfset fieldLength = len(FieldName)>
					<cfset programID = Mid(FieldName,16,(fieldLength - 16 + 1))>

					<!--- "BB_Auto_Populate_Program_Pay_Periods" SP (above) inserts into "BB_Auto_Program_Pay_Period" table.
					Get the BB_Auto_Program_Pay_Period_ID for the "BB_Auto_Report_ID".
					--->
					<CFQUERY  DATASOURCE="#application.datasource#" NAME="getBBAutoProgramPayPeriodID">
					SELECT BB_Auto_Program_Pay_Period_ID
					FROM BB_Auto_Program_Pay_Period
					WHERE BB_Auto_Report_ID = '#arguments.reportID#'
					AND Program_ID = '#programID#'
					</CFQUERY>

					<!--- "-1" means that the user either did not select any invoices OR did not change any previously selected invoices.
					If the invoice list is empty, then invoice_header_id would be ""(blank) and not 0(zero).
					--->
					<cfif Evaluate(FieldName) neq "-1">
						<CFQUERY  DATASOURCE="#application.datasource#" NAME="updBBAutoReportInvoiceFilter">
							UPDATE BB_Auto_Report_Invoice_Filter
							SET deleted  = 1
							WHERE BB_Auto_Report_ID = '#arguments.reportID#'
							AND Contract_Main_ID = '#programID#'
						</CFQUERY>
					</cfif>

					<!--- get the invoice_Header_ID's for the selected programs. --->
						<cfloop list="#Evaluate(FieldName)#" index="invoice_header_id">
							<!--- "-1" means that the user either did not select any invoices OR did not change any previously selected invoices.
							If the invoices list is empty, then invoice_header_id would be ""(blank) and not 0(zero).
							--->
							<cfif invoice_header_id neq "-1">
								<cfset useLakebaseForqSaveInvoices = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_auto_report_invoice_filter")>
<cfif useLakebaseForqSaveInvoices>
	<cftry>
		<cfset application.oLakebase.insertRow("bb_auto_report_invoice_filter", {
			"bb_auto_program_pay_period_id" = "#getBBAutoProgramPayPeriodID.BB_Auto_Program_Pay_Period_ID#",
			"bb_auto_report_id" = "#arguments.reportID#",
			"invoice_header_id" = "#invoice_header_id#",
			"contract_main_id" = "#programID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqSaveInvoices = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqSaveInvoices>
<CFQUERY name="qSaveInvoices" DATASOURCE="#application.datasource#">
									INSERT INTO BB_Auto_Report_Invoice_Filter(BB_Auto_Program_Pay_Period_ID,BB_Auto_Report_ID,Invoice_Header_ID,Contract_Main_ID)
									VALUES('#getBBAutoProgramPayPeriodID.BB_Auto_Program_Pay_Period_ID#','#arguments.reportID#','#invoice_header_id#','#programID#')
								</CFQUERY>
</cfif>
							</cfif>
						</cfloop>
				</cfif>
			</cfloop>
			<!---
			/********************************************************* (END)INSERT DISTRIBUTORS FOR AUTO PAY ****************************************************************/
			--->


            <!--- Update PAy Period Status.  For Full Auto this happens in updatePayPeriod() method as already existing pay periods are flagged w/ report id--->
            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdpayPeriods">
                UPDATE BB_Auto_Program_Pay_Period
                SET Status = 1
                WHERE bb_auto_report_id = <cfqueryparam cfsqltype="numeric" value="#arguments.reportID#">
            </CFQUERY>

            <cfreturn Program_ID />
    </cffunction>

<!--- XXXXXXXXXXXX  Update Pay Period   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
    <cffunction name="updatePayPeriod" access="public" returntype="void">
        <cfargument name="periodID" required="yes"  type="numeric" />
        <cfargument name="userId"   required="yes" type="any" />
        <cfargument name="status"   required="no" type="numeric" default="1" />
        <cfargument name="reportId" required="yes" type="numeric" />

        <cfset var qUpdatePayPeriod = "" />

        <!--- Update pay Period records with new report --->
            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdatePayPeriod">
                UPDATE BB_Auto_Program_Pay_Period
                SET Status = #arguments.status#,
                    Updated_User_id = '#arguments.userId#',
                    Updated_Date = GetDate(),
                    BB_Auto_Report_ID = '#arguments.reportId#'
                FROM BB_Auto_Program_Pay_Period Pay
                    JOIN BB_Auto_Report_Period P
                        ON P.BB_Auto_Report_Period_ID = '#arguments.periodID#'
                    WHERE Payment_End_Date <= p.end_date
                        and Pay.BB_Auto_Report_id is null
                        and Pay.Deleted = 0
            </CFQUERY>
    </cffunction>
<!--- XXXXXXXXXXXX  Cancel Report   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
    <cffunction name="cancelReport" access="public" returntype="void">
        <cfargument name="reportID" required="yes"  type="numeric" />
        <cfargument name="userId"   required="yes" type="any" />

        <cfset var qUpdateReport = "" />
        <cfset var qUpdatePayPeriod = "" />
        <cfset var DeleteFilesForThis = "" />

            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdateReport">
                UPDATE bb_auto_report
                SET
                    Updated_User_ID = '#arguments.userId#',
                    Updated_Date = GetDate(),
                    Status = NULL,
                    Deleted = 1
                WHERE
                    BB_Auto_Report_ID = '#arguments.reportID#'
            </CFQUERY>
            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdatePayPeriod">
                UPDATE BB_Auto_Program_Pay_Period
                SET Status = 0,
                    Updated_User_id = '#arguments.userId#',
                    Updated_Date = GetDate(),
                    BB_Auto_Report_ID = NULL
                WHERE BB_Auto_Report_id = '#arguments.reportID#'
            </CFQUERY>

            <!--- If they have any saved download files for this, delete them --->
            <cfset DeleteFilesForThis = this.DeleteAssociatedDocs(arguments.reportID)>
    </cffunction>

<!--- XXXXXXXXXXXX  Pause Recalc Report XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
    <cffunction name="setRecalcReport" access="public" returntype="void">
        <cfargument name="reportID" required="yes"  type="numeric" />
        <cfargument name="userId"   required="yes" type="any" />
        <cfargument name="pause"    required="yes" type="any" default="0" />

        <cfset var qUpdateReport = "" />

            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdateReport">
                UPDATE bb_auto_report
                SET
                    Updated_User_ID = '#arguments.userId#',
                    Updated_Date = GetDate(),
                    Pause_Schedule = '#arguments.pause#'
                WHERE
                    BB_Auto_Report_ID = '#arguments.reportID#' AND
                    Status = 2
            </CFQUERY>
    </cffunction>

<!--- XXXXXXXXXXXX  approve Report  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
    <cffunction name="approveReport" access="public" returntype="void">
        <cfargument name="reportID" required="yes"  type="numeric" />
        <cfargument name="userId"   required="yes" type="any" />

        <cfset var qUpdateReport = "" />
        <cfset var qUpdateBBLockStatus = "" />
        <cfset var qUpdateBBApproved = "" />
        <cfset var qUpdateContractLockStatus = "" />
        <cfset var DeleteFilesForThis = "" />
        <cfset var qUpdateBBStatus = "" />

        <!--- NEED FULL APPROVAL LOGIC AT BB LEVEL HERE
                Update report ok
                Update BB status ok
                unlock BB ok
                unlock programs ok
                --->
            <!--- Flag as RFA -> the SP will then approve the BB's -> then we flag the pay period as Approved = 4 --->
            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdatePayPeriod">
                UPDATE BB_Auto_Program_Pay_Period
                SET  Updated_User_ID = '#arguments.userId#',
                     Updated_Date = GetDate(),
                     Status = 3
                WHERE
                    BB_Auto_Report_ID = '#arguments.reportID#' AND
                    Status < 4 AND Status != 2
            </CFQUERY>

            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdateReport">
                UPDATE bb_auto_report
                SET
                    Approved_User_ID = '#arguments.userId#',
                    Updated_Date = GetDate(),
                    Status = 4
                WHERE
                    BB_Auto_Report_ID = '#arguments.reportID#'
            </CFQUERY>
            <!--- <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdateBBStatus">
                UPDATE BillBack
                    SET Billback_Status_ID = 3,
                        BB_Request_Approval_User_ID = '#arguments.userId#',
                        BB_Request_Approval_Date = GetDate()
                FROM BillBack B
                INNER JOIN BB_Auto_Report R ON
                    R.BB_Auto_Report_ID = '#arguments.reportID#'
                INNER JOIN BB_Auto_Program_Pay_Period P ON
                    P.BB_Auto_Report_id = R.BB_Auto_Report_ID AND
                    P.Deleted = 0
                INNER JOIN  BB_Auto_Pay_Period_Billback PBB ON
                        PBB.BB_Auto_Program_Pay_Period_Id = P.BB_Auto_Program_Pay_Period_Id AND
                        B.Billback_id = PBB.Billback_id
            </CFQUERY> --->
            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdateBBLockStatus">
                UPDATE Billback_Allied
                    SET BB_Is_Locked = 0
                FROM Billback_Allied B
                INNER JOIN BB_Auto_Report R ON
                    R.BB_Auto_Report_ID = '#arguments.reportID#'
                INNER JOIN BB_Auto_Program_Pay_Period P ON
                    P.BB_Auto_Report_id = R.BB_Auto_Report_ID AND
                    P.Deleted = 0
                INNER JOIN  BB_Auto_Pay_Period_Billback PBB ON
                        PBB.BB_Auto_Program_Pay_Period_Id = P.BB_Auto_Program_Pay_Period_Id AND
                        B.Billback_id = PBB.Billback_id
            </CFQUERY>
            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdateBBApproved">
                Update BB_Approved
                    SET Date_Approved = getDate(),
                        User_Approved = '#arguments.userId#'
                FROM BB_Approved B
                INNER JOIN BB_Auto_Report R ON
                    R.BB_Auto_Report_ID = '#arguments.reportID#'
                INNER JOIN BB_Auto_Program_Pay_Period P ON
                    P.BB_Auto_Report_id = R.BB_Auto_Report_ID AND
                    P.Deleted = 0 AND
                    P.Status = 3
                INNER JOIN  BB_Auto_Pay_Period_Billback PBB ON
                        PBB.BB_Auto_Program_Pay_Period_Id = P.BB_Auto_Program_Pay_Period_Id AND
                        B.Billback_id = PBB.Billback_id
            </CFQUERY>
            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdateBBApproved">
                EXEC BB_Auto_Report_Set_Status '#arguments.reportID#'
            </CFQUERY>

            <CFQUERY DATASOURCE="#application.datasource#" NAME="qAllBillbacks">
                SELECT B.Billback_ID
                FROM   BillBack B
                INNER JOIN    BB_Auto_Report R
                ON                   R.BB_Auto_Report_ID = #arguments.reportID#
                INNER JOIN    BB_Auto_Program_Pay_Period P
                ON                   P.BB_Auto_Report_id = R.BB_Auto_Report_ID
                AND                  P.Status = 3
                AND                  P.Deleted = 0
                INNER JOIN    BB_Auto_Pay_Period_Billback PBB
                ON                   PBB.BB_Auto_Program_Pay_Period_Id = P.BB_Auto_Program_Pay_Period_Id
                AND                  B.Billback_ID = PBB.Billback_id
            </CFQUERY>

            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdatePayPeriod">
                UPDATE BB_Auto_Program_Pay_Period
                SET  Updated_User_ID = '#arguments.userId#',
                     Updated_Date = GetDate(),
                     Status = 4
                WHERE
                    BB_Auto_Report_ID = '#arguments.reportID#' AND
                    Status = 3
            </CFQUERY>

            <cfloop query="qAllBillbacks">
                <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdateBBBudget">
                    EXEC ADV_BUDGET_ACTUAL_ADD_BILLBACK '#qAllBillbacks.Billback_ID#'
                </CFQUERY>
            </cfloop>

            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdateContractLockStatus">
                EXEC BB_Auto_UnlockPrograms '#arguments.reportID#'
            </CFQUERY>
            <!--- If they have any saved download files for this, delete them --->
            <cfset DeleteFilesForThis = this.DeleteAssociatedDocs(arguments.reportID)>

    </cffunction>

    <!--- XXXXXXXXXXXX  approve Report  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
    <cffunction name="approvePayPeriod" access="public" returntype="void">
        <cfargument name="reportID" required="yes"  type="numeric" />
        <cfargument name="periodID" required="yes"  type="numeric" />
        <cfargument name="userId"   required="yes" type="any" />

        <cfset var qUpdateReport = "" />
        <cfset var qUpdateBBLockStatus = "" />
        <cfset var qUpdateBBApproved = "" />
        <cfset var qUpdateContractLockStatus = "" />
        <cfset var DeleteFilesForThis = "" />
        <cfset var qUpdateBBStatus = "" />

        <!--- NEED FULL APPROVAL LOGIC AT BB LEVEL HERE
                Update report ok
                Update BB status ok
                unlock BB ok
                unlock programs ok
                --->
        <!---   <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdateReport">
                UPDATE bb_auto_report
                SET
                    Approved_User_ID = '#arguments.userId#',
                    Updated_Date = GetDate(),
                    Status = 4
                WHERE
                    BB_Auto_Report_ID = '#arguments.reportID#'
            </CFQUERY> --->

            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdatePayPeriod">
                UPDATE BB_Auto_Program_Pay_Period
                SET  Updated_User_ID = '#arguments.userId#',
                     Updated_Date = GetDate(),
                     Status = 3
                WHERE
                    BB_Auto_Report_ID = '#arguments.reportID#'  AND
                    BB_Auto_Program_Pay_Period_id = #arguments.periodID# AND
                    Status < 4 AND Status != 2
            </CFQUERY>


            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdateBBLockStatus">
                UPDATE Billback_Allied
                    SET BB_Is_Locked = 0
                FROM Billback_Allied B
                INNER JOIN BB_Auto_Report R ON
                    R.BB_Auto_Report_ID = '#arguments.reportID#'
                INNER JOIN BB_Auto_Program_Pay_Period P ON
                    P.BB_Auto_Report_id = R.BB_Auto_Report_ID AND
                    P.BB_Auto_Program_Pay_Period_id = #arguments.periodID# AND
                    P.Deleted = 0
                INNER JOIN  BB_Auto_Pay_Period_Billback PBB ON
                        PBB.BB_Auto_Program_Pay_Period_Id = P.BB_Auto_Program_Pay_Period_Id AND
                        B.Billback_id = PBB.Billback_id
            </CFQUERY>
            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdateBBApproved">
                Update BB_Approved
                    SET Date_Approved = getDate(),
                        User_Approved = '#arguments.userId#'
                FROM BB_Approved B
                INNER JOIN BB_Auto_Report R ON
                    R.BB_Auto_Report_ID = '#arguments.reportID#'
                INNER JOIN BB_Auto_Program_Pay_Period P ON
                    P.BB_Auto_Report_id = R.BB_Auto_Report_ID AND
                    P.BB_Auto_Program_Pay_Period_id = #arguments.periodID# AND
                    P.Deleted = 0
                INNER JOIN  BB_Auto_Pay_Period_Billback PBB ON
                        PBB.BB_Auto_Program_Pay_Period_Id = P.BB_Auto_Program_Pay_Period_Id AND
                        B.Billback_id = PBB.Billback_id
            </CFQUERY>
            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdateBBApproved">
                EXEC BB_Auto_Report_Set_Status '#arguments.reportID#'
            </CFQUERY>

            <CFQUERY DATASOURCE="#application.datasource#" NAME="qAllBillbacks">
                SELECT B.Billback_ID
                FROM   BillBack B
                INNER JOIN    BB_Auto_Report R
                ON                   R.BB_Auto_Report_ID = #arguments.reportID#
                INNER JOIN    BB_Auto_Program_Pay_Period P
                ON                   P.BB_Auto_Report_id = R.BB_Auto_Report_ID
                AND                  P.Status = 3
                AND                  P.Deleted = 0
                INNER JOIN    BB_Auto_Pay_Period_Billback PBB
                ON                   PBB.BB_Auto_Program_Pay_Period_Id = P.BB_Auto_Program_Pay_Period_Id
                AND                  B.Billback_ID = PBB.Billback_id
                WHERE           P.BB_Auto_Program_Pay_Period_id = #arguments.periodID#
            </CFQUERY>

            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdatePayPeriod">
                UPDATE BB_Auto_Program_Pay_Period
                SET  Updated_User_ID = '#arguments.userId#',
                     Updated_Date = GetDate(),
                     Status = 4
                WHERE
                    BB_Auto_Report_ID = '#arguments.reportID#'  AND
                    BB_Auto_Program_Pay_Period_id = #arguments.periodID# AND
                    Status = 3
            </CFQUERY>

            <cfloop query="qAllBillbacks">
                <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdateBBBudget">
                    EXEC ADV_BUDGET_ACTUAL_ADD_BILLBACK '#qAllBillbacks.Billback_ID#'
                </CFQUERY>
            </cfloop>

            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdateContractLockStatus">
                EXEC BB_Auto_UnlockPrograms '#arguments.reportID#'
            </CFQUERY>

            <!--- If they have any saved download files for this, delete them --->
            <cfset DeleteFilesForThis = this.DeleteAssociatedDocs(arguments.reportID)>

    </cffunction>

<!--- XXXXXXXXXXXX  Delete Report   XXXXXXXXXXXX --->
    <cffunction name="deleteReport" access="public" returntype="boolean">
        <cfargument name="reportID" required="yes"  type="numeric" />
        <cfargument name="userId"   required="yes" type="any" />

        <cfset var delBB = "" />
        <cfset var qdeleteReport = "" />
        <cfset var DeleteFilesForThis = "" />
        <cfset var reportProcessing = "" />
        <cfset var returnValue = 0 />
        <cfset tmp = this.init() />
        <CFTRANSACTION>
            <cfset reportProcessing = application.oBBReportGet.getReportLockInfo().Processing />
            <cfif not reportProcessing>
                    <!--- Delete existing BB: send only report id to delete the whole report--->
                    <cfset delBB = this.removeBB(reportID   = reportID,
                                                        userId  = userId) />
                    <CFQUERY DATASOURCE="#application.datasource#" NAME="qdeleteReport">
                        UPDATE bb_auto_report
                        SET
                            Updated_User_ID = '#arguments.userId#',
                            Updated_Date = GetDate(),
                            Status = 9,
                            Deleted = 1
                        WHERE
                            BB_Auto_Report_ID = '#arguments.reportID#'
                    </CFQUERY>
                    <!--- THIS IS A MANUALLY CONFIGURED AUTO PAY --->
                    <cfif application.oBBReportGet.getAutoPayType() eq 2>
                        <CFQUERY DATASOURCE="#application.datasource#" NAME="qdeleteReport">
                            Update BB_Auto_Program_Pay_Period
                            SET Deleted = 1,
                                Updated_Date = getDate(),
                                Updated_User_ID = '#arguments.userId#'
                            WHERE
                                BB_Auto_Report_ID IS NULL
                        </CFQUERY>
                    </cfif>
                    <!--- If they have any saved download files for this, delete them --->
                    <cfset DeleteFilesForThis = this.DeleteAssociatedDocs(arguments.reportID)>
                <cfset returnValue = 1 />
            </cfif>
        </CFTRANSACTION>
        <cfreturn returnValue />
    </cffunction>
<!--- XXXXXXXXXXXX  Delete a BB.  Used to call remove BB from App   XXXXXXXXXXXX --->
    <cffunction name="deleteBB" access="public" returntype="void">
        <cfargument name="BillBackId" required="yes" type="any" />
        <cfargument name="userId"   required="yes" type="any" />
        <cfset var delBB = '' />
        <cfset var qgetDelBB = "" />
        <!--- Delete existing BB: send only report id to delete the whole report--->

            <CFQUERY DATASOURCE="#application.datasource#" NAME="qgetDelBB">
                    SELECT  P.BB_Auto_Program_Pay_Period_Id AS PayPeriodId,
                            P.BB_Auto_Report_Id AS reportID
                    FROM BB_Auto_Pay_Period_Billback PBB
                    INNER JOIN BB_Auto_Program_Pay_Period P ON
                        PBB.BB_Auto_Program_Pay_Period_Id = P.BB_Auto_Program_Pay_Period_Id AND
                        P.Deleted = 0
                    INNER JOIN BB_Auto_Report R ON
                        R.BB_Auto_Report_ID = P.BB_Auto_Report_ID
                    WHERE PBB.BillBack_ID =  '#arguments.BillBackId#'
            </CFQUERY>
            <cfif isNumeric(qgetDelBB.reportID)>
                <cfset delBB = this.removeBB(reportID   = qgetDelBB.reportID,
                                                userId  = arguments.userId,
                                                PayPeriodId = qgetDelBB.PayPeriodId,
                                                BBOnly = 1) />
            </cfif>
    </cffunction>

<!--- XXXXXXXXXXXX  Delete BB(s) From Report    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
    <cffunction name="removeBB" access="public" returntype="boolean">
        <cfargument name="reportID" required="yes"  type="numeric" />
        <cfargument name="userId"   required="yes" type="any" />
        <cfargument name="PayPeriodId" required="no" type="any" default="0" />
        <cfargument name="BBOnly" required="no" type="numeric" default="0" />
        <cfargument name="BBID" required="no" type="string" default="NULL" />

        <cfset var qRemoveBB = "" />
        <cfset var BB_Auto_Delete_BillBack = "" />
        <cfset var qdeleteExportBBHeader = "" />
        <cfset var DeleteFilesForThis = ""/>
        <cfset var returnValue = 0>

        <cfif arguments.BBID eq "" OR arguments.BBID eq "NULL">
        <!--- Set Status to 9 = delete. Then Call SP  --->
            <CFQUERY DATASOURCE="#application.datasource#" NAME="qRemoveBB">
                UPDATE BB_Auto_Program_Pay_Period
                SET Status = 9,
                    Updated_User_id = '#arguments.userId#',
                    Updated_Date = GetDate()
                ---FROM BB_Auto_Program_Pay_Period P
                ---INNER JOIN BB_Auto_Report R ON
                    ---P.BB_Auto_Report_id = R.BB_Auto_Report_ID
                WHERE
                    BB_Auto_Report_ID = '#arguments.reportID#' AND
                    Deleted = 0
                    <cfif arguments.PayPeriodId NEQ 0> <!--- If PayPeriodId != 0, then delete specific payPeriod (or BB since it is 1:1) --->
                    AND BB_Auto_Program_Pay_Period_Id = '#arguments.PayPeriodId#'
                    </cfif>
            </CFQUERY>
        </cfif>


        <!--- Call SP.  If more than 1 BB has status = 9, SP is ok --->
        <!--- clears accrual_log, export_report, pullbacks_log, unlock programs --->
        <cfstoredproc procedure="BB_Auto_Delete_BillBack" datasource="#application.datasource#">
            <cfprocparam type="In" CFSQLType="CF_SQL_INTEGER"   dbVarName = "@@Report_ID" value = "#arguments.reportID#" null="no" />
            <cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR"   dbVarName = "@@User_ID" value="#arguments.userId#" null="no" />
            <cfprocparam type="In" CFSQLType="CF_SQL_BIT"       dbVarName = "@@BBOnly" value="#arguments.BBOnly#" null="no" />
            <cfif arguments.BBID eq "" OR arguments.BBID eq "NULL">
                <cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR"   dbVarName = "@BB_ID" value="#arguments.BBID#" null="true" />
            <cfelse>
                <cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR"   dbVarName = "@BB_ID" value="#arguments.BBID#" null="false" />
            </cfif>
        </cfstoredproc>
        <!---
            D39812: Validate EDI files for potential billback duplicate/Anand Rao/13-Feb-2014
            Added the below section for deleting EDI duplicate, if it is flagged as duplicate.
        --->
        <cfif !(arguments.BBID eq "" OR arguments.BBID eq "NULL")>
            <cfstoredproc procedure="Upload_EDI_Dup_Delete" datasource="#application.datasource#">
                <cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR"   dbVarName = "@@Billback_ID" value="#arguments.BBID#" null="false" />
                <cfprocparam type="In" CFSQLType="CF_SQL_INTEGER"   dbVarName = "@@Upload_ID" null="true"/>
                <cfprocparam type="In" CFSQLType="CF_SQL_INTEGER"   dbVarName = "@@Header_ID" null="true"/>
            </cfstoredproc>
            <!---
                50616 - New Duplicate BB Logic/Anand Rao/22-Jun-2015
            --->
            <cfstoredproc procedure="BB_All_Dup_Delete" datasource="#application.datasource#">
                <cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR"   dbVarName = "@@Billback_ID" value="#arguments.BBID#" null="false" />
            </cfstoredproc>
        </cfif>
        <cfif arguments.PayPeriodId EQ 0> <!--- If PayPeriodId  = 0, then delete whole report --->
            <!--- Export detail records are handled in SP BB_Auto_Delete_BillBack where individual BB's are removed. --->
            <CFQUERY DATASOURCE="#application.datasource#" NAME="qdeleteExportBBHeader">
                    DELETE FROM BB_Auto_Report_Export_Header
                        WHERE BB_Auto_Report_ID ='#arguments.reportID#'
            </CFQUERY>
        </cfif>

        <!--- If they have any saved download files for this, delete them --->
            <cfset DeleteFilesForThis = this.DeleteAssociatedDocs(arguments.reportID)>
            <cfset returnValue = 1>
      <cfreturn returnValue />
    </cffunction>

<!--- XXXXXXXXXXXX  Recalc BB(s) From Report    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
    <cffunction name="recalcBB" access="public" returntype="void">
        <cfargument name="reportID"     required="yes"  type="numeric" />
        <cfargument name="userId"       required="yes"  type="any" />
        <cfargument name="CalcNow"      required="no"   type="any" default="0" />
        <cfargument name="PayPeriodId"  required="yes"  type="any" default="0" />
        <cfset var ProgramID = "0" />
        <!--- Delete existing BB --->
        <cfset var delBB = this.removeBB(   reportID    = arguments.reportID,
                                            userId      = arguments.userId,
                                            PayPeriodId = arguments.PayPeriodId,
                                            BBOnly      = 1)>
        <cfset var qGetReportProgram = ""/>
        <cfset var qRecalcBB = ""/>
        <cfset var qUpdateReport = ""/>
        <cfset var runBB = ""/>

        <!--- Get Program id to send to the re-calc proc if we are runing Calc Now --->
        <cfif arguments.PayPeriodId NEQ 0>
            <CFQUERY DATASOURCE="#application.datasource#" NAME="qGetReportProgram">
                SELECT  Program_Id,
                        BB_Auto_Program_Pay_Period_Id
                FROM BB_Auto_Program_Pay_Period P
                WHERE BB_Auto_Report_ID = '#arguments.reportID#' AND
                    BB_Auto_Program_Pay_Period_Id = '#arguments.PayPeriodId#'
            </CFQUERY>
            <cfset ProgramID    = qGetReportProgram.Program_Id />
        </cfif>
        <!--- Set Status to 1 = recalc. delete BB -> update report to run again  --->
            <CFQUERY DATASOURCE="#application.datasource#" NAME="qRecalcBB">
                UPDATE BB_Auto_Program_Pay_Period
                SET Status = 1,
                    Updated_User_id = '#arguments.userId#',
                    Updated_Date    = GetDate(),
                    Billback_Id     = NULL
                FROM BB_Auto_Program_Pay_Period P
                INNER JOIN BB_Auto_Report R ON
                    P.BB_Auto_Report_id = R.BB_Auto_Report_ID
                WHERE
                    P.BB_Auto_Report_ID = '#arguments.reportID#' AND
                    P.Deleted = 0
                    <cfif arguments.PayPeriodId NEQ 0> <!--- If BBid = 0, then recalc whole report --->
                    AND Program_id = '#ProgramID#'
                    </cfif>
            </CFQUERY>

            <!--- Update report for Recalc --->
            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdateReport">
                UPDATE bb_auto_report
                SET
                    Updated_User_ID = '#arguments.userId#',
                    Updated_Date = GetDate(),
                    Extracted = 0,
                    Status = 2
                WHERE
                    BB_Auto_Report_ID = '#arguments.reportID#'
            </CFQUERY>

        <cfif CalcNow EQ 1 >

            <cfset runBB =This.runBBAutoCreate(programID    = ProgramID,
                                                reportID    = arguments.reportID) />
        </cfif>
    </cffunction>

    <!--- XXXXXXXXXXXX  Run Auto Create BB Job  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
    <cffunction name="runBBAutoCreate" access="remote" returntype="void">
        <cfargument name="programID"    required="no"   type="numeric" default="0" />
        <cfargument name="reportID"     required="no"   type="any" default="0" />

        <cfset var BB_Auto_Create_Process = ""/>
        <cfset var status = "" />

            <!--- Call SP.  If more than 1 BB has status = 1, SP is ok-> pass 0,0: OR run for 1 -> exec BB_Auto_Create_Process 850,14--->
            <!--- **NOTE: DBCVARNAME is Ignored in JDBC Driver.  Vars must be passed in correct Order!! --->
            <CFTRY>
                  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
                        There is also a try catch in The SP BB_Auto_Create_Process.
                          * In Sp it is only available in SQL2005, So I put it here also in case we build back.
                            Having it in SP also handles for SP being called from Scheduled DB Job
                          * SP also updates the Report Process bit, so no need to do it here
                        xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
                <cfstoredproc procedure="BB_Auto_Create_Process" datasource="#application.datasource#">
                    <cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@Program_Id" value ="#arguments.ProgramID#" null="no" />
                    <cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@BB_Auto_Report_ID"     value="#arguments.reportID#" null="no" />
                </cfstoredproc>

                <CFCATCH type="any">
                    <!--- We had an error.  Set processing to Off --->
                    <cfset status = This.setReportProcess(0) />

                    <CFRETHROW /> <!--- resend the error so error handler can have some fun --->
                </CFCATCH>
            </CFTRY>

    </cffunction>
<!--- XXXXXXXXXXXX  UpdPrgClaimMechanic         XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
    <!--- Update the program level claim mechanic based on the Component Level Mechanics
          If any one component is Auto pay set the program is auto Pay.  Auto Pay routine will look at each
          components claim mechanic to determine whether to auto pay, but looks at the contract level switch to
          decide wheter to check the components at all --->
    <cffunction access="public" name="UpdPrgClaimMechanic" returntype="void">
        <cfargument name="contract_main_id" type="Numeric" required="true">

        <cfset var updPrgClaimMechanicBasedOnCompnt = ""/>

        <cfquery NAME="updPrgClaimMechanicBasedOnCompnt" datasource="#application.datasource#">
            DECLARE
            @Contract_Main_ID int,
            @Payment_Type_ID int

            SET @Contract_Main_ID = #arguments.contract_main_id#
            SET @Payment_Type_ID = 0

                  SELECT @Payment_Type_ID =  PT.Payment_Type_ID
                  FROM Payment_Type PT
                  LEFT JOIN Program_Rebates_Component PRC ON
                                    PRC.Program_ID = @Contract_Main_ID AND
                                    PRC.Deleted = 0 AND
                                    PT.Payment_Type_ID = PRC.Claim_Mechanics
                  LEFT JOIN Program_Fixed_Component PFC ON
                                    PFC.Program_ID = @Contract_Main_ID AND
                                    PFC.Deleted = 0 AND
                                    PT.Payment_Type_ID = PFC.Claim_Mechanics
                  LEFT JOIN Program_Lump_Sums PLS ON
                                    PLS.Program_ID = @Contract_Main_ID AND
                                    PLS.Deleted = 0 AND
                                    PT.Payment_Type_ID = PLS.Claim_Mechanics
                  LEFT JOIN Program_Growth_Components PGC ON
                                    PGC.Program_ID = @Contract_Main_ID AND
                                    PGC.Deleted = 0 AND
                                    PT.Payment_Type_ID = PGC.Claim_Mechanics
                  WHERE PT.Is_Auto_Pay = 1 AND
                              (PRC.Claim_Mechanics IS NOT NULL OR
                              PFC.Claim_Mechanics IS NOT NULL OR
                              PLS.Claim_Mechanics IS NOT NULL OR
                              PGC.Claim_Mechanics IS NOT NULL)
            --SELECT @Payment_Type_ID
            --will be set to 0 if none is found
            UPDATE Contract_Main
            SET ClaimMechanics = @Payment_Type_ID
            WHERE  Contract_Main_Id = @Contract_Main_Id
        </cfquery>
    </cffunction>

<!--- XXXXXXXXXXXX  DeleteAssociatedDocs        XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
    <!--- We should delete the downloadable auto pay summary at three points:
    1) When an auto pay program is approved and no longer viewable
    2) When an auto pay program is deleted
    3) When an auto pay program is modified.
    We would rather delete too many files than too few.
     --->
    <cffunction access="public" name="DeleteAssociatedDocs" returntype="void">
    <cfargument name="BB_Auto_Report_id" type="Numeric" required="true">

        <cfset var BillbackFileName = "ExportDetails_" & arguments.BB_Auto_Report_id & ".txt">
        <cfset var Billbackfilepath = application.Doc_Path & "\Temp_Files\Billback\AutoPayReport\"  & BillbackFileName>
        <cfset var PullbackFileName = "PullbackDetails_" & arguments.BB_Auto_Report_id & ".txt">
        <cfset var Pullbackfilepath = application.Doc_Path & "\Temp_Files\Billback\AutoPayReport\"  & PullbackFileName>


    <cfif FileExists(Billbackfilepath)>
        <CFFILE action = "delete"
        file="#Billbackfilepath#">
    </cfif>

    <cfif FileExists(Pullbackfilepath)>
        <CFFILE action = "delete"
        file="#Pullbackfilepath#">
    </cfif>

    </cffunction>

<!--- XXXXXXXXXXXX  SaveGrowthCalcChanges       XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->

    <cffunction access="public" name="SaveGrowthCalcChanges" returntype="void">
        <cfargument name="BB_Auto_Report_id" type="Numeric" required="true">
        <cfargument name="BB_Auto_Growth_Calc_ID_List" type="string" required="true">
        <cfargument name="oForm" type="struct" required="true">
        <cfargument name="userId" type="string" required="true">

        <cfset var qUpdateGrowthTier = ""  />
        <cfset var qGetGrowthTier = ""  />
        <cfset var BB_Auto_Program_Pay_Period_Id_List = ""  />

        <cfloop list="#arguments.BB_Auto_Growth_Calc_ID_List#" index="i">
            <cfif IsNumeric(i) and IsDefined("arguments.oForm.Select_Tier_#i#")>
                <cfset selectedTier = arguments.oForm["Select_Tier_#i#"] />

                <CFQUERY DATASOURCE="#application.datasource#" NAME="qGetGrowthTier">
                    SELECT  Program_Id,
                            BB_Auto_Program_Pay_Period_Id,
                            ISNULL(Override_Tier_Attained, Tier_Attained) as Current_Selected_Tier
                    FROM    BB_Auto_Growth_Calc
                    WHERE   BB_Auto_Growth_Calc_ID = #i#
                </CFQUERY>

                <cfif qGetGrowthTier.Current_Selected_Tier NEQ selectedTier AND IsNumeric(selectedTier)>

                    <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdateGrowthTier">
                        UPDATE  BB_Auto_Growth_Calc
                        SET     Override_Tier_Attained = #selectedTier#
                        WHERE   BB_Auto_Growth_Calc_ID = #i#
                    </CFQUERY>

                    <cfif NOT ListContains(BB_Auto_Program_Pay_Period_Id_List, qGetGrowthTier.BB_Auto_Program_Pay_Period_Id)>
                        <cfset BB_Auto_Program_Pay_Period_Id_List = ListAppend(BB_Auto_Program_Pay_Period_Id_List, qGetGrowthTier.BB_Auto_Program_Pay_Period_Id)  />
                    </cfif>

                </cfif>
            </cfif>
        </cfloop>

        <!--- If any changes, re-calc --->
        <cfif BB_Auto_Program_Pay_Period_Id_List NEQ "">

            <cfloop list="#BB_Auto_Program_Pay_Period_Id_List#" index="PayPeriodID">

                <cfset var delBB = this.removeBB(
                                                reportID    = arguments.BB_Auto_Report_id,
                                                userId      = arguments.userId,
                                                PayPeriodId = PayPeriodID,
                                                BBOnly      = 1)>

                <!--- Set Status to 1 = recalc. delete BB -> update report to run again  --->
                <CFQUERY DATASOURCE="#application.datasource#" NAME="qRecalcBB">
                    UPDATE BB_Auto_Program_Pay_Period
                    SET Status = 1,
                        Updated_User_id = '#arguments.userId#',
                        Updated_Date    = GetDate(),
                        Billback_Id     = NULL
                    FROM BB_Auto_Program_Pay_Period P
                    INNER JOIN BB_Auto_Report R ON
                        P.BB_Auto_Report_id = R.BB_Auto_Report_ID
                    WHERE
                        P.BB_Auto_Report_ID = '#arguments.BB_Auto_Report_id#' AND
                        P.Deleted = 0
                        AND BB_Auto_Program_Pay_Period_Id = #PayPeriodID#

                </CFQUERY>

            </cfloop>

            <!--- Update report for Recalc --->
            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdateReport">
                UPDATE bb_auto_report
                SET
                    Updated_User_ID = '#arguments.userId#',
                    Updated_Date = GetDate(),
                    Extracted = 0,
                    Status = 2
                WHERE
                    BB_Auto_Report_ID = '#arguments.BB_Auto_Report_id#'
            </CFQUERY>

        </cfif>

    </cffunction>

<!--- XXXXXXXXXXXX  RestoreGrowthCalcChanges        XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->

    <cffunction access="public" name="RestoreGrowthCalcChanges" returntype="void">
        <cfargument name="BB_Auto_Report_id" type="Numeric" required="true">
        <cfargument name="BB_Auto_Growth_Calc_ID_List" type="string" required="true">
        <cfargument name="userId" type="string" required="true">

        <cfset var qUpdateGrowthTier = ""  />
        <cfset var qGetGrowthTier = ""  />
        <cfset var BB_Auto_Program_Pay_Period_Id_List = ""  />

        <cfloop list="#arguments.BB_Auto_Growth_Calc_ID_List#" index="i">
            <cfif IsNumeric(i)>

                <CFQUERY DATASOURCE="#application.datasource#" NAME="qGetGrowthTier">
                    SELECT  Program_Id,
                            BB_Auto_Program_Pay_Period_Id,
                            Override_Tier_Attained,
                            Tier_Attained
                    FROM    BB_Auto_Growth_Calc
                    WHERE   BB_Auto_Growth_Calc_ID = #i#
                </CFQUERY>

                <!--- If there is some override only --->
                <cfif qGetGrowthTier.Override_Tier_Attained NEQ "">

                    <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdateGrowthTier">
                        UPDATE  BB_Auto_Growth_Calc
                        SET     Override_Tier_Attained = NULL
                        WHERE   BB_Auto_Growth_Calc_ID = #i#
                    </CFQUERY>

                    <!--- If current tier is different from original tier --->
                    <cfif qGetGrowthTier.Override_Tier_Attained NEQ qGetGrowthTier.Tier_Attained>
                        <cfif NOT ListContains(BB_Auto_Program_Pay_Period_Id_List, qGetGrowthTier.BB_Auto_Program_Pay_Period_Id)>
                            <cfset BB_Auto_Program_Pay_Period_Id_List = ListAppend(BB_Auto_Program_Pay_Period_Id_List, qGetGrowthTier.BB_Auto_Program_Pay_Period_Id)  />
                        </cfif>
                    </cfif>

                </cfif>
            </cfif>
        </cfloop>

        <!--- If any changes, re-calc --->
        <cfif BB_Auto_Program_Pay_Period_Id_List NEQ "">

            <cfloop list="#BB_Auto_Program_Pay_Period_Id_List#" index="PayPeriodID">

                <cfset var delBB = this.removeBB(
                                                reportID    = arguments.BB_Auto_Report_id,
                                                userId      = arguments.userId,
                                                PayPeriodId = PayPeriodID,
                                                BBOnly      = 1)>

                <!--- Set Status to 1 = recalc. delete BB -> update report to run again  --->
                <CFQUERY DATASOURCE="#application.datasource#" NAME="qRecalcBB">
                    UPDATE BB_Auto_Program_Pay_Period
                    SET Status = 1,
                        Updated_User_id = '#arguments.userId#',
                        Updated_Date    = GetDate(),
                        Billback_Id     = NULL
                    FROM BB_Auto_Program_Pay_Period P
                    INNER JOIN BB_Auto_Report R ON
                        P.BB_Auto_Report_id = R.BB_Auto_Report_ID
                    WHERE
                        P.BB_Auto_Report_ID = '#arguments.BB_Auto_Report_id#' AND
                        P.Deleted = 0
                        AND BB_Auto_Program_Pay_Period_Id = #PayPeriodID#

                </CFQUERY>

            </cfloop>

            <!--- Update report for Recalc --->
            <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdateReport">
                UPDATE bb_auto_report
                SET
                    Updated_User_ID = '#arguments.userId#',
                    Updated_Date = GetDate(),
                    Extracted = 0,
                    Status = 2
                WHERE
                    BB_Auto_Report_ID = '#arguments.BB_Auto_Report_id#'
            </CFQUERY>

        </cfif>

    </cffunction>

<!--- XXXXXXXXXXXX  Reverse BB(s) in Report XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
    <cffunction name="reverseBB" access="public" returntype="boolean">
        <cfargument name="reportID" required="yes"  type="numeric" />
        <cfargument name="userId"   required="yes" type="any" />
        <cfargument name="PayPeriodId" required="no" type="any" default="0" />

        <cfset var qGetBB = "" />
        <cfset var iCanReverse = 1 />
        <CFQUERY DATASOURCE="#application.datasource#" NAME="qGetBB">
            SELECT  DISTINCT B.Billback_ID, B.Billback_Status_ID, B.BB_Payment_Request_Sent, B.BB_Received_Ack_Type, B.BB_Associated_To_DD
            FROM BB_Auto_Program_Pay_Period PP
            INNER JOIN  BB_Auto_Pay_Period_Billback PBB ON
                    PBB.BB_Auto_Program_Pay_Period_Id = PP.BB_Auto_Program_Pay_Period_Id
            INNER JOIN BillBack B ON
                    B.Billback_Id = PBB.Billback_Id
            WHERE PP.BB_Auto_Program_Pay_Period_id = '#arguments.PayPeriodId#'
        </CFQUERY>

        <!--- Find if there are billback that have interfaced and not yet acknowledged --->
        <cfset useLakebaseForqCheckBBCannotReverse = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetbb")>
<cfif useLakebaseForqCheckBBCannotReverse>
	<cftry>
		<cfset qCheckBBCannotReverse = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetbb", {
				"bb_payment_request_sent" = "eq.1",
				"bb_received_ack_type" = "eq.0",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckBBCannotReverse = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckBBCannotReverse>
<CFQUERY Name="qCheckBBCannotReverse" dbtype="query">
            SELECT  1
            FROM    qGetBB
            WHERE   BB_Payment_Request_Sent = 1
            AND     BB_Received_Ack_Type = 0
        </CFQUERY>
</cfif>

        <!--- Stop if atleast one billback cannot be reversed --->
        <cfif qCheckBBCannotReverse.RecordCount>
            <cfreturn 0 />
        </cfif>

        <cfset oBillbackDAO = CreateObject("component","mvc.Models.Billback.BillbackDAO") />
        <cfset oDeductionManager = CreateObject("component","components.Deduction.DeductionManager") />
        <!--- Loop over each billback in the auto pay program pay period --->
        <cfloop query="qGetBB">

            <!--- If billback has deduction attached, reopen DD and detach BB --->
            <cfif BB_Associated_To_DD EQ 1>
                <CFQUERY DATASOURCE="#application.datasource#" NAME="qGetDD">
                    SELECT  DISTINCT Deduction_ID
                    FROM    DD_Closure_Detail
                    WHERE   DD_Closure_ID = '#qGetBB.Billback_ID#'
                    AND     Deleted = 0
                </CFQUERY>
                <cfif qGetDD.RecordCount>
                    <!--- Reopen DD --->
                    <cfset oDeductionManager.ReopenDeduction(qGetDD.Deduction_ID) />

                    <!--- Detach BB --->
                    <cfstoredproc procedure="Deduction_Detach_Billback" datasource="#application.datasource#">
                        <cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR"   dbVarName = "@Deduction_ID" value="#qGetDD.Deduction_ID#" null="no" />
                    </cfstoredproc>
                </cfif>
            </cfif>

            <!--- Delete / Reverse billback --->
            <cfif BB_Payment_Request_Sent EQ 1 AND BB_Received_Ack_Type EQ 1>
                <!--- If Interfaced and ackowledged, unapply pullbacks and reverse billback --->
                <!--- Unapply pullbacks --->
                <CFQUERY DATASOURCE="#application.datasource#" NAME="qUnapplyPullbacks">
                    UPDATE  PullBacks_Log
                    SET     Deleted = 1,
                            Deleted_By = 'BB_Auto_Delete',
                            Deleted_Date = getDate()
                    WHERE   Pullback_applied_to_billback_id = '#qGetBB.Billback_ID#'
                    AND     DELETED = 0
                </CFQUERY>
                <!--- Reverse --->
                <cfset oBillbackDAO.setReverseBillback(qGetBB.Billback_ID, arguments.userId) />
            <cfelseif BB_Payment_Request_Sent EQ 0>
                <!--- Did not interface yet, just delete the billback --->
                <cfset this.removeBB(
                                            reportID    = arguments.reportID,
                                            userId      = arguments.userId,
                                            PayPeriodId = arguments.PayPeriodId,
                                            BBOnly      = 1,
                                            BBID        = qGetBB.Billback_ID)>
            </cfif>
        </cfloop>

        <CFQUERY DATASOURCE="#application.datasource#" NAME="qUpdatePayPeriod">
            UPDATE  BB_Auto_Program_Pay_Period
            SET     Status = 9,
                    Updated_Date = getDate()
            WHERE   BB_Auto_Program_Pay_Period_id = '#arguments.PayPeriodId#'
        </CFQUERY>

        <cfreturn 1 />
    </cffunction>

    <!--- XXXXXXXXXXXX      XXXXXXXXXXXX --->
<!---   <cffunction name="" access="public" returntype="string">
      <cfset var result = "">
      <cfreturn result>
    </cffunction> --->
</cfcomponent>