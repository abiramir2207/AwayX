<cfcomponent hint="Deduction Manager" extends="components.Base">

	<cfset variables.appsettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

	<cffunction name="init" output="false" returntype="components.deduction.DeductionManager">

		<cfreturn this />

	</cffunction>
	<!--- stage ---->
	<cfset variables.ddStageID = "" />
	<cfset variables.ddStageDescription = "" />
	<cfset variables.ddStageCreatedDate = "" />
	<cfset variables.ddStageAutoDefaultDays = 0 />
	<cfset variables.IsAutoReminded = false />
	<!--- action section --->
	<cfset variables.ddActionID = "" />
	<cfset variables.ddActionCreatedDate = "" />
	<cfset variables.ddActionCompletedDate = "" />

	<!---- actionID ---->
	<cffunction name="getDDActionID" returntype="string" access="public">
		<cfreturn variables.ddActionID/>
	</cffunction>
	<cffunction name="setDDActionID" returntype="void"  access="package">
		<cfargument name="ddActionID" required="true" type="string">
		<cfset variables.ddActionID = arguments.ddActionID />
	</cffunction>
	<!---- actoin created date ---->
	<cffunction name="getDDActionCreatedDate" returntype="date" access="public">
		<cfreturn variables.ddActionCreatedDate/>
	</cffunction>
	<cffunction name="setDDActionCreatedDate" returntype="void"  access="package">
		<cfargument name="ddActionCreatedDate" required="true" type="date">
		<cfset variables.ddActionCreatedDate = arguments.ddActionCreatedDate />
	</cffunction>
	<!---- action complete date ---->
	<cffunction name="getDDActionCompletedDate" returntype="date" access="public">
		<cfreturn variables.ddActionCompletedDate/>
	</cffunction>
	<cffunction name="setDDActionCompletedDate" returntype="void"  access="package">
		<cfargument name="ddActionCompletedDate" required="true" type="date">
		<cfset variables.ddActionCompletedDate = arguments.ddActionCompletedDate />
	</cffunction>
	<!---- getter (stageID)------>
	<cffunction name="getDDStageIsAutoReminded" returntype="boolean" access="public">
		<cfreturn variables.IsAutoReminded/>
	</cffunction>
	<!---- setter (stageID)------>
	<cffunction name="setDDStageIsAutoReminded" returntype="void"  access="package">
		<cfargument name="IsAutoReminded" required="true" type="boolean">
		<cfset variables.IsAutoReminded = arguments.IsAutoReminded />
	</cffunction>


	<!---- getter (stageID)------>
	<cffunction name="getDDStageID" returntype="numeric" access="public">
		<cfreturn variables.ddStageID/>
	</cffunction>
	<!---- setter (stageID)------>
	<cffunction name="setDDStageID" returntype="void"  access="package">
		<cfargument name="ddStageID" required="true" type="numeric">
		<cfset variables.ddStageID = arguments.ddStageID />
	</cffunction>

	<!---- getter (stageDescription)------>
	<cffunction name="getDDStageDescription" returntype="string" access="public">
		<cfreturn variables.ddStageDescription/>
	</cffunction>
	<!---- setter (stageDescription)------>
	<cffunction name="setDDStageDescription" returntype="void"  access="package">
		<cfargument name="ddStageDescription" required="true" type="string">
		<cfset variables.ddStageDescription = arguments.ddStageDescription />
	</cffunction>

	<!---- getter (stageCreatedDate)------>
	<cffunction name="getDDStageCreatedDate" returntype="date" access="public">
		<cfreturn variables.ddStageCreatedDate/>
	</cffunction>
	<!---- setter (stageCreatedDate)------>
	<cffunction name="setDDStageCreatedDate" returntype="void"  access="package">
		<cfargument name="ddStageCreatedDate" required="true" type="date">
		<cfset variables.ddStageCreatedDate = arguments.ddStageCreatedDate />
	</cffunction>

	<!---- getter (stageAutoDefaultDays)------>
	<cffunction name="getDDStageAutoDefaultDays" returntype="numeric" access="public">
		<cfreturn variables.ddStageAutoDefaultDays/>
	</cffunction>
	<!---- setter (stageAutoDefaultDays)------>
	<cffunction name="setDDStageAutoDefaultDays" returntype="void"  access="package">
		<cfargument name="ddStageAutoDefaultDays" required="true" type="numeric">
		<cfset variables.ddStageAutoDefaultDays = arguments.ddStageAutoDefaultDays />
	</cffunction>

	<cffunction name="addReminder" output="false" returntype="string">

		<cfargument name="deductionId" type="string" required="true" />
		<cfargument name="reminderMessage" type="string" required="true" />
		<cfargument name="reminderDate" type="date" required="true" />
		<cfargument name="typeOfReminderType" type="numeric" required="false" default="0" hint="Only to be used from outside the regular create reminder, 2=action, 3=new deduction" />
		<cfargument name="reminderType" type="numeric" required="false" default="0" />
		<cfargument name="reminderStatus" type="numeric" required="false" default="0" />
		<cfargument name="emailReminder" type="boolean" required="false" default="1" />
		<cfargument name="extraEmailAddress" type="string" required="false" default="" />

		<!------ If  reminderType is passed in use it----->
		<cfif arguments.reminderType EQ 0 AND arguments.typeOfReminderType NEQ 0>
			<!------ If  reminderType is not passed in and if typeOfReminderType is passed in, get the reminderType using typeOfReminderType  ----->
			<!------ Only to be used from outside the regular create reminder ----->
			<cfset arguments.reminderType = getReminderTypeId(arguments.typeOfReminderType) />
		</cfif>

		<cfquery name="InsertReminder" datasource="#application.datasource#">
			INSERT INTO DD_Reminders
			(
				Deduction_ID,
				DD_Reminder,
				DD_Reminder_Type,
				DD_Reminder_Date,
				DD_Reminder_Status,
				Email_Reminder,
				Others_To_Email
			)
			VALUES
			(
				<cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#arguments.reminderMessage#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#arguments.reminderType#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#arguments.reminderDate#" cfsqltype="CF_SQL_DATE">,
				<cfqueryparam value="#arguments.reminderStatus#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#arguments.emailReminder#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#arguments.extraEmailAddress#" cfsqltype="CF_SQL_LONGVARCHAR">
			)

		</cfquery>
		<cfreturn InsertReminder.DD_Reminder_ID />
	</cffunction>

	<cffunction name="getReminderTypeId" output="false" returntype="numeric">

		<cfargument name="typeOfReminderID" type="numeric" required="true" />

		<cfquery name="qGetReminderType" datasource="#application.datasource#">
			SELECT 	TOP 1 DD_Reminder_Type.*
			FROM	DD_Reminder_Type
			WHERE	DD_Reminder_Type.Deleted = 0
			AND		DD_Reminder_Type.DD_Type_Of_Reminder_ID = <cfqueryparam value="#arguments.typeOfReminderID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

<!---
	<cfreturn qGetReminderType.DD_Reminder_Type_ID />
D40254 :: Event error The value returned from the getReminderTypeId function is not of type numeric
	--->
<cfif qGetReminderType.Recordcount>
            <cfset DD_Reminder_Type_ID = qGetReminderType.DD_Reminder_Type_ID >
<cfelse>
            <cfset DD_Reminder_Type_ID = 0>
</cfif>

<cfreturn DD_Reminder_Type_ID />


	</cffunction>

	<cffunction name="getReminderStatusDesc" output="false" returntype="string">

		<cfargument name="statusId" type="numeric" required="true" />

		<cfquery name="qGetReminderStatus" datasource="#application.datasource#">
			SELECT 	TOP 1 DD_Status.*
			FROM	DD_Status
			WHERE	DD_Status.Deleted = 0
			AND		DD_Status.DD_Status_ID = <cfqueryparam value="#arguments.statusId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfreturn qGetReminderStatus.DD_Status_Description />

	</cffunction>

	<cffunction name="loadDDStageInfo" returntype="void" output="false">
		<cfargument name="ddStageID" required="true" type="numeric" />
		<cfquery name="qLoadDDStageInfo" datasource="#application.datasource#">
			select *
			from dd_stage
			where deleted = 0
			and dd_stage_id = #arguments.ddStageID#
		</cfquery>
		<cfif qLoadDDStageInfo.Is_Auto_Reminded eq 1 >
			<cfset theReminderSetting = true />
		<cfelse>
			<cfset theReminderSetting = false />
		</cfif>
		<cfset setDDStageID(qLoadDDStageInfo.DD_Stage_ID) />
		<cfset setDDStageDescription(qLoadDDStageInfo.DD_Stage_Description) />
		<cfset setDDStageCreatedDate(qLoadDDStageInfo.Created_Date) />
		<cfset setDDStageIsAutoReminded(theReminderSetting) />
		<cfset setDDStageAutoDefaultDays(qLoadDDStageInfo.Auto_Default_Days) />
	</cffunction>

	<cffunction name="loadDDActionInfo" returntype="void" output="false">
		<cfargument name="ddActionID" required="true" type="string" />
		<cfset useLakebaseForqLoadDDActionInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_ded_actions")>
<cfif useLakebaseForqLoadDDActionInfo>
	<cftry>
		<cfset qLoadDDActionInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_ded_actions", {
				"deleted" = "eq.0",
				"dd_ded_action_id" = "eq.#arguments.ddActionID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqLoadDDActionInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqLoadDDActionInfo>
<cfquery name="qLoadDDActionInfo" datasource="#application.datasource#">
			select *
			from DD_Ded_Actions
			where deleted = 0
			and DD_Ded_Action_ID = '#arguments.ddActionID#'
		</cfquery>
</cfif>
		<cfset setDDActionID(qLoadDDActionInfo.DD_Stage_ID) />
		<cfset setDDActionCreatedDate(qLoadDDActionInfo.Created_Date) />
		<cfset setDDActionCompletedDate(qLoadDDActionInfo.Date_Completed) />
	</cffunction>

	<cffunction name="updateAction" output="false" returntype="void">
		<cfargument name="DD_Ded_Action_ID" required="true" type="string" />
		<cfargument name="DD_Reminder_ID" 	required="true" type="string" />
		<cfset useLakebaseForqUpdateAction = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_ded_actions")>
<cfif useLakebaseForqUpdateAction>
	<cftry>
		<cfset application.oLakebase.updateRows("dd_ded_actions",
			{
				"dd_ded_action_id" = "eq.#arguments.DD_Ded_Action_ID#",
				"deleted" = "eq.0"
			},
			{
				"dd_reminder_id" = "#arguments.DD_Reminder_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdateAction = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdateAction>
<cfquery name="qUpdateAction" datasource="#application.datasource#">
			Update DD_Ded_Actions
			set DD_Reminder_ID = '#arguments.DD_Reminder_ID#'
			where DD_Ded_Action_ID = '#arguments.DD_Ded_Action_ID#'
			and deleted = 0
		</cfquery>
</cfif>

	</cffunction>

	<cffunction name="getDeduction" output="false" returntype="query">
		<cfargument name="deductionId" required="true" type="string" />
		<!---D41078 -- match central -- credit/deduction & deduction/credit matching logic update START--->
		<cfargument name="amount" required="false" type="string" default=""/>
		<cfargument name="ApplyAmountFilter" required="false" type="numeric" default="0"/>
		<!---D41078 -- match central -- credit/deduction & deduction/credit matching logic update END--->
		<cfquery name="qGetDeduction" datasource="#application.datasource#">
			SELECT	Deductions.*,
					BSA_Foodservice_Customers.Name,
					BSA_Foodservice_Customers.BSA_FOODSERVICE_CUSTOMERS_ID,
					RTRIM(BSA_Foodservice_Customers.Shr_Ship_To) as Shr_Ship_To,
					BSA_Foodservice_Customers.Business_Segment_ID As Dist_Business_Segment_ID,
					Distributor_Bill_To.Name AS BillToName,
					Distributor_Bill_To.Shr_Bill_To,
					_Users.Name_First + ' ' + _Users.Name_Last Anlayst
					,BSA_Foodservice_Customers.Family_ID
			FROM	Deductions

			LEFT JOIN	_Users
			ON 			_Users.User_ID = Deductions.Analyst_User_ID
			AND			_Users.deleted = 0
			LEFT JOIN	Distributor_Bill_To
			ON 			Distributor_Bill_To.Distributor_Bill_To_ID = Deductions.Distributor_Bill_To_ID
			LEFT JOIN	BSA_Foodservice_Customers
			ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID

			WHERE	Deductions.Deduction_ID IN (<cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR" list="true">)
			<!---D41078 -- match central -- credit/deduction & deduction/credit matching logic update START

			IN WR 41078 FOR ADVANCE FOODS WE MADE THE CHANGE TO RESTRICT THE OPTIONS IN THE SPLIT BILLBACK/DEDUCTION/CREDIT DROPDOWN.
			SINCE ADVANCE FOODS IS NO LONGER A CLIENT, WE DECIDED TO UNDO THE LOGIC FROM 41078 IN WR 99879.

			<cfif ApplyAmountFilter EQ 1>
				AND Deductions.DD_Amount >= '#arguments.amount#'
			</cfif>
			D41078 -- match central -- credit/deduction & deduction/credit matching logic update END--->
		</cfquery>

		<cfreturn qGetDeduction />

	</cffunction>

	<cffunction name="RemoveClosureFromDeduction" output="false" returntype="void">
		<cfargument name="deductionId" required="true" type="string" />

		<CFQUERY NAME="qRemoveClosureFromDeduction" DATASOURCE="#Application.Datasource#">
			UPDATE 	Deductions
			SET 	DD_Closure_ID = NULL,
					DD_Closure_Type = NULL,
					DD_Status = CASE WHEN Is_Credit = 1 THEN 8 ELSE 2 END
			WHERE 	Deduction_ID = <cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>

		<CFQUERY NAME="qRemoveClosureFromDeductionClosureDetail" DATASOURCE="#Application.Datasource#">
			UPDATE 	DD_Closure_Detail
			SET 	Deleted = 1
			WHERE 	Deduction_ID = <cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR">
			<!------ TODO: Check for DD_Closure_Status_ID? ----->
		</CFQUERY>

		<!--- ReOpen Parent --->
		<CFQUERY NAME="DeductionInfo" DATASOURCE="#Application.Datasource#">
			SELECT DD_Parent_ID,DD_IsChild FROM Deductions WHERE Deduction_ID = <cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>

		<CFIF DeductionInfo.DD_IsChild EQ 1>
			<cfquery name="GetDeductionNumber" datasource="#application.datasource#">
				UPDATE 	Deductions
				SET 	DD_Status = CASE WHEN Is_Credit = 1 THEN 8 ELSE 2 END
				WHERE 	Deductions.Deduction_ID = '#DeductionInfo.DD_Parent_ID#'
			</cfquery>
		</CFIF>
	</cffunction>

	<cffunction name="RemoveClosureFromCreditForThisDeduction" output="false" returntype="void">
		<cfargument name="deductionId" required="true" type="string" />

		<cfset qGetAssociatedCredits = getAssociatedCredits(arguments.deductionId) />

		<cfloop query="qGetAssociatedCredits">
			<cfset RemoveClosureFromCredit(Credit_ID) />
		</cfloop>

	</cffunction>

	<cffunction name="RemoveClosureFromCredit" output="false" returntype="void">
		<cfargument name="creditId" required="true" type="string" />

		<CFQUERY NAME="qRemoveClosureFromCredit" DATASOURCE="#Application.Datasource#">
			UPDATE 	Deductions
			SET 	DD_Closure_ID = NULL,
					DD_Closure_Type = NULL,
					DD_Status = CASE WHEN Is_Credit = 1 THEN 8 ELSE 2 END
			WHERE 	Deduction_ID = <cfqueryparam value="#arguments.creditId#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>
		<!--- ReOpen Parent --->
		<CFQUERY NAME="DeductionInfo" DATASOURCE="#Application.Datasource#">
			SELECT DD_Parent_ID,DD_IsChild FROM Deductions WHERE Deduction_ID = <cfqueryparam value="#arguments.creditId#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>

		<CFIF DeductionInfo.DD_IsChild EQ 1>
			<cfquery name="GetDeductionNumber" datasource="#application.datasource#">
				UPDATE 	Deductions
				SET 	DD_Status = CASE WHEN Is_Credit = 1 THEN 8 ELSE 2 END
				WHERE 	Deductions.Deduction_ID = '#DeductionInfo.DD_Parent_ID#'
			</cfquery>
		</CFIF>
	</cffunction>

	<cffunction name="getAssociatedCredits" output="false" returntype="query">
		<cfargument name="deductionId" required="true" type="string" />

		<CFQUERY NAME="qGetAssociatedCredits" DATASOURCE="#Application.Datasource#">
			SELECT	DISTINCT Credit.*, Credit.Deduction_ID Credit_ID
			FROM 	DD_Closure_Detail
			INNER JOIN Deductions Credit
			ON		Credit.Deduction_ID = DD_Closure_Detail.DD_Closure_ID
			WHERE 	DD_Closure_Detail.Deduction_ID = <cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR">
			AND		DD_Closure_Detail.Deleted = 0
			AND		DD_Closure_Detail.DD_Closure_Status_ID = 1
		</CFQUERY>

		<cfreturn qGetAssociatedCredits />

	</cffunction>

	<cffunction name="RemoveAssociatedBB" output="false" returntype="void">
		<cfargument name="deductionId" required="true" type="string" />

		<CFQUERY NAME="UpdateBB" DATASOURCE="#Application.Datasource#">
			UPDATE 	Billback
			SET 	BB_Associated_To_DD = 0
			WHERE 	Billback_ID IN (SELECT DD_Closure_ID FROM DD_Closure_Detail WHERE Deduction_ID = <cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0)
		</CFQUERY>
		<CFQUERY NAME="DeletePreAsso" DATASOURCE="#Application.Datasource#">
			UPDATE DD_Closure_Detail
			SET Deleted = 1
			WHERE Deduction_ID = <cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
		</CFQUERY>
		<CFQUERY NAME="UpdateDD" DATASOURCE="#Application.Datasource#">
			UPDATE 	Deductions
			SET 	DD_Closure_ID = NULL,
					DD_Closure_Type = NULL
			WHERE 	Deduction_ID = <cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>
	</cffunction>

	<cffunction name="getAssociatedBB" output="false" returntype="query">
		<cfargument name="deductionId" required="true" type="string" />

		<CFQUERY NAME="qGetAssociatedBB" DATASOURCE="#Application.Datasource#">
			SELECT DD_Closure_ID
			FROM DD_Closure_Detail
			WHERE Deduction_ID = <cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR"> AND
			Interfaced_On IS NULL AND Ack_Received IS NULL AND Deleted = 0
		</CFQUERY>
		<cfreturn qGetAssociatedBB />
	</cffunction>

	<cffunction name="setAssociatedBB" output="false" returntype="void">

		<cfargument name="Deduction_ID" required="true" type="string">
		<cfargument name="Billback_ID" required="true" type="string" hint="billback list to attach to DD">

			<CFSET LoopCount = 0>
			<CFLOOP LIST="#arguments.Billback_ID#" INDEX="BBIDItem">
				<CFSET LoopCount = LoopCount + 1>
				<!---Insert into reason code and  relocate to closure--->
				<CFIF LoopCount EQ 1>
					<cfset useLakebaseForAddReason = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForAddReason>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{
				"deduction_id" = "eq.#arguments.Deduction_ID#"
			},
			{
				"dd_closure_id" = "#BBIDItem#",
				"dd_closure_type" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForAddReason = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAddReason>
<cfquery name="AddReason" datasource="#application.datasource#">
						UPDATE 	Deductions
						Set 	DD_Closure_ID = '#BBIDItem#',
								DD_Closure_Type = 1
						WHERE 	Deduction_ID = '#arguments.Deduction_ID#'
					</cfquery>
</cfif>
				</CFIF>
				<!--- Check for existing entry in DD_Closure_Detail for this given Deduction/Billback Combination to prevent duplicate entries --->
				<cfset useLakebaseForqCheckIfExists = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_closure_detail")>
<cfif useLakebaseForqCheckIfExists>
	<cftry>
		<cfset qCheckIfExists = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_closure_detail", {
				"deduction_id" = "eq.#arguments.Deduction_ID#",
				"dd_closure_id" = "eq.#BBIDItem#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckIfExists = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckIfExists>
<CFQUERY NAME="qCheckIfExists" DATASOURCE="#Application.Datasource#">
					SELECT	*
					FROM	DD_Closure_Detail
					WHERE	Deduction_ID 	= '#arguments.Deduction_ID#'
					AND		DD_Closure_ID 	= '#BBIDItem#'
					AND		Deleted			= 0
				</CFQUERY>
</cfif>
				<cfif not qCheckIfExists.RecordCount>
					<cfset useLakebaseForInsData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_closure_detail")>
<cfif useLakebaseForInsData>
	<cftry>
		<cfset application.oLakebase.insertRow("dd_closure_detail", {
			"deduction_id" = "#arguments.Deduction_ID#",
			"dd_closure_id" = "#BBIDItem#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsData>
<CFQUERY NAME="InsData" DATASOURCE="#Application.Datasource#">
						INSERT INTO DD_Closure_Detail (arguments.Deduction_ID,arguments.DD_Closure_ID)
						VALUES ('#arguments.Deduction_ID#','#BBIDItem#')
					</CFQUERY>
</cfif>
				</cfif>
				<cfset useLakebaseForUpdateBBBit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForUpdateBBBit>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#BBIDItem#"
			},
			{
				"bb_associated_to_dd" = "1",
				"bb_closing_method" = "2"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateBBBit = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateBBBit>
<CFQUERY NAME="UpdateBBBit" DATASOURCE="#Application.Datasource#">
					UPDATE 	Billback
					SET 	BB_Associated_To_DD = 1,
							BB_Closing_Method = 2
					WHERE 	Billback_ID = '#BBIDItem#'
				</CFQUERY>
</cfif>
			</CFLOOP>

	</cffunction>

	<cffunction name="setUpdateBBPaidAutoReconcile" output="false" returntype="any">

		<cfargument name="REMAININGAMOUNT" required="true" type="numeric">
		<cfargument name="MatchList" required="true" type="string" hint="billback list">


		<CFQUERY NAME="qGetMaxBBPaid" DATASOURCE="#Application.Datasource#">
			SELECT	top 1 '#arguments.REMAININGAMOUNT#' AS RemainingAmount,Ba.*
			FROM	Billback B
			Inner Join BB_Approved BA ON
				BA.billback_id = B.billback_id
			WHERE	B.billback_id in(<cfqueryparam Value="#arguments.matchList#" list="Yes">)
			AND		b.Deleted	= 0
			AND BA.paid_amount > abs(#arguments.REMAININGAMOUNT#)
			ORDER BY BA.paid_amount DESC
		</CFQUERY>
		<cfif qGetMaxBBPaid.recordcount>
			<CFQUERY NAME="qSetMaxBBPaid" DATASOURCE="#Application.Datasource#">
				UPDATE BB_Approved
				SET paid_amount = paid_amount + #arguments.REMAININGAMOUNT#
				Where Billback_Id = <cfqueryparam Value="#qGetMaxBBPaid.Billback_Id#" />
			</CFQUERY>
			<cfreturn 1 />
		<cfelse>
			<cfreturn 0 />
		</cfif>

	</cffunction>


	<cffunction name="getAssociatedBBTotal" output="false" returntype="numeric">
		<cfargument name="deductionId" required="true" type="string" />
		<cfset var bbTotal = 0 />
		<CFQUERY NAME="qGetAssociatedBBTotal" DATASOURCE="#Application.Datasource#">
			select	dd_closure_detail.deduction_id, sum(bb_approved.paid_amount) as sum_attached_amount
			from	dd_closure_detail

			inner join billback
			on		billback.billback_id = dd_closure_detail.DD_Closure_ID
			and		billback.deleted = 0

			inner join bb_approved
			on		billback.billback_id = bb_approved.billback_id

			where	dd_closure_detail.deleted = 0
			and		dd_closure_detail.deduction_id = <cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR">

			Group by dd_closure_detail.deduction_id

		</CFQUERY>
		<cfif qGetAssociatedBBTotal.recordCount>
			<cfset bbTotal = qGetAssociatedBBTotal.sum_attached_amount />
		</cfif>
		<cfreturn bbTotal />
	</cffunction>

	<cffunction name="getAssociatedCRDTotal" output="false" returntype="numeric">
		<cfargument name="deductionId" required="true" type="string" />
		<cfset var crdTotal = 0 />
		<CFQUERY NAME="qGetAssociatedCRDTotal" DATASOURCE="#Application.Datasource#">
			select	dd_closure_detail.deduction_id, sum(credit.dd_amount) as sum_attached_amount
			from	dd_closure_detail

			inner join deductions as credit
			on		credit.deduction_id = dd_closure_detail.DD_Closure_ID
			and		credit.deleted = 0

			where	dd_closure_detail.deleted = 0
			and		dd_closure_detail.deduction_id = <cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR">

			Group by dd_closure_detail.deduction_id

		</CFQUERY>
		<cfif qGetAssociatedCRDTotal.recordCount>
			<cfset crdTotal = qGetAssociatedCRDTotal.sum_attached_amount />
		</cfif>
		<cfreturn crdTotal />
	</cffunction>

	<cffunction name="updateParentBalanceAmount" output="false" returntype="void">
		<cfargument name="parentDeductionId" required="true" type="string" />

		<cfstoredproc procedure = "UPDATE_PARENT_BALANCE_AMOUNT" dataSource="#application.datasource#">
	   		<cfprocparam type="IN" CFSQLType="CF_SQL_VARCHAR" value="#arguments.parentDeductionId#"  />
			<cfprocparam type="IN" CFSQLType="CF_SQL_VARCHAR" value="DEDUCTION"  />
		</cfstoredproc>

	</cffunction>

	<cffunction name="updateParentBalanceAmountForCreditsAssociated" output="false" returntype="void">
		<cfargument name="deductionId" required="true" type="string" />

		<cfstoredproc procedure = "UPDATE_PARENT_BALANCE_AMOUNT" dataSource="#application.datasource#">
	   		<cfprocparam type="IN" CFSQLType="CF_SQL_VARCHAR" value="#arguments.deductionId#"  />
			<cfprocparam type="IN" CFSQLType="CF_SQL_VARCHAR" value="ASSOCIATED_CREDITS"  />
		</cfstoredproc>

	</cffunction>

	<cffunction name="closeDeduction" output="true" returntype="void">

		<cfargument name="Deduction_ID" required="true" type="string">
		<cfargument name="ReasonCode" required="true" type="string">
		<cfargument name="ClearedAmount" required="false" default="0" type="numeric">
		<cfargument name="isMatchCentral" required="false" default="false" type="boolean">
		<cfargument name="Classification_ID" required="false" default="0" type="numeric"><!---66788 --->
		<cfargument name="autoReconcile" required="false" default="false" type="boolean">
		<cfargument name="DontUpdateReasonCode" required="false" default="0" type="boolean">

		<cfscript>
			if(isMatchCentral){
				// Variables for the closing function, required for function to work.
				FORM.Cleared_Amount			= arguments.ClearedAmount;
				FORM.ClosingAction			= "Approve";
			}
		</cfscript>

		<cfset useLakebaseForGetDeductionInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForGetDeductionInfo>
	<cftry>
		<cfset GetDeductionInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"deduction_id" = "eq.#arguments.Deduction_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDeductionInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDeductionInfo>
<cfquery name="GetDeductionInfo" datasource="#application.datasource#">
			SELECT *
			FROM Deductions
			WHERE Deduction_ID = '#arguments.Deduction_ID#'
		</cfquery>
</cfif>

		<cfset useLakebaseForGetClosureInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForGetClosureInfo>
	<cftry>
		<cfset GetClosureInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"deduction_id" = "eq.#arguments.Deduction_ID#",
				"select" = "dd_closure_id,dd_closure_type,distributor_id,dd_amount"
			}), "dd_closure_id,dd_closure_type,distributor_id,dd_amount"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetClosureInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetClosureInfo>
<cfquery name="GetClosureInfo" datasource="#application.datasource#">
			SELECT DD_Closure_ID, DD_Closure_Type, Distributor_ID, DD_Amount
			FROM Deductions
			WHERE Deduction_ID = '#arguments.Deduction_ID#'
		</cfquery>
</cfif>

		<cftry>

		<!---Update some deduction info--->
		<cfset useLakebaseForUpdateFalgs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForUpdateFalgs>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{
				"deduction_id" = "eq.#arguments.Deduction_ID#"
			},
			{
				"dd_closure_sent" = "0",
				"ack_received_closure" = "0",
				"ack_received_reopen" = "0",
				"reopened" = "0",
				"dd_reopened_sent" = "0/*",
				"log_processing" = "1*/"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateFalgs = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateFalgs>
<CFQUERY NAME="UpdateFalgs" DATASOURCE="#Application.Datasource#">
			UPDATE Deductions
			SET DD_Closure_Sent = 0,
			Ack_received_Closure = 0,
			Ack_received_Reopen = 0,
			ReOpened = 0,
			DD_Reopened_Sent = 0/*,
			Log_Processing = 1*/
			WHERE Deduction_ID = '#arguments.Deduction_ID#'
		</CFQUERY>
</cfif>

		<cfset useLakebaseForResetBB_Credit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_closure_detail")>
<cfif useLakebaseForResetBB_Credit>
	<cftry>
		<cfset application.oLakebase.updateRows("dd_closure_detail",
			{
				"deduction_id" = "eq.#arguments.Deduction_ID#",
				"deleted" = "eq.0"
			},
			{
				"interfaced_on" = javaCast("null",""),
				"ack_received" = javaCast("null","")
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForResetBB_Credit = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForResetBB_Credit>
<CFQUERY NAME="ResetBB_Credit" DATASOURCE="#Application.Datasource#">
			UPDATE DD_Closure_Detail
			SET Interfaced_On = NULL,
			Ack_Received = NULL
			WHERE Deduction_ID = '#arguments.Deduction_ID#' AND Deleted = 0
		</CFQUERY>
</cfif>

		<cfquery name="UpdateDeduction" datasource="#application.datasource#">
		UPDATE Deductions
		SET DD_Date_Closed = getdate(),
			DD_Closed_By = '#request.AccessStructure.User_ID#',
			<!--- If the client send the "reasn code" in the file, do not update it --->
			<cfif arguments.DontUpdateReasonCode eq 0>
			DD_Resolution_Code = '#arguments.ReasonCode#',
			</cfif>
			Cleared_Amount = '#form.Cleared_Amount#',
			ReOpened = 0,
			DD_ReOpened_On = NULL,
			--DD_Status = 4,
			<cfif variables.appSettings.getDD_Show_Classification()>
			DD_Classification_ID = ISNULL(DD_Classification_ID,#arguments.Classification_ID#),
			</cfif>
			<CFIF FORM.ClosingAction EQ "Approve">
				<CFIF IsDefined("FORM.IsTrade")>
					Q_Brand_ID = '#FORM.Q_Brand_ID#',
					Is_Trade = 1,
					<cfif isDefined("FORM.Operating_Unit_ID")>
						Operating_Unit_ID = '#FORM.Operating_Unit_ID#',
					</cfif>
				<CFELSE>
					<CFIF IsDefined("FORM.Business_Segment_ID")>
						Business_Segment_ID = '#FORM.Business_Segment_ID#',
						Q_Brand_ID = '#FORM.Q_Brand_ID#',
						<cfif isDefined("FORM.Operating_Unit_ID")>
							Operating_Unit_ID = '#FORM.Operating_Unit_ID#',
						</cfif>
					</CFIF>
					Program_ID = NULL,
					Is_Trade = 0,
				</CFIF>
				<CFIF IsDefined("FORM.DD_Operator_ID")>
				DD_Operator_ID = '#FORM.DD_Operator_ID#',
				</CFIF>
			</CFIF>
			<CFIF FORM.ClosingAction EQ "Approve">
			DD_Closure_Method = 1,
			Is_Locked = 0,
			Locked_By = NULL
			<CFELSEIF FORM.ClosingAction EQ "Rebill">
			DD_Closure_Method = 2
			<CFELSEIF FORM.ClosingAction EQ "Adjust">
			DD_Closure_Method = 3
			</CFIF>
		WHERE Deduction_ID = '#arguments.Deduction_ID#'
		</cfquery>

		<CFIF GetClosureInfo.DD_Closure_ID NEQ "" AND GetClosureInfo.DD_Closure_Type EQ 1>
			<CFQUERY NAME="UpdateStatus" DATASOURCE="#Application.Datasource#">
				UPDATE Billback
				<!--- When "Billback: set to paid status when deduction is closed" app setting is ON, set to paid, else approved --->
				SET Billback_Status_ID = <CFIF variables.appsettings.getDDClosedBBStatus()> 5 <CFELSE> 3 </CFIF>
				WHERE Billback_ID IN (SELECT DD_Closure_ID FROM DD_Closure_Detail
				WHERE Deduction_ID = '#arguments.Deduction_ID#' AND Interfaced_On IS NULL AND Ack_Received IS NULL AND Deleted = 0)
			</CFQUERY>
		</CFIF>

		<!--- If match central, unlock the match central lock --->
		<!--- May not be necessary
		<cfif isMatchCentral>
			<CFQUERY NAME="UpdateStatus" DATASOURCE="#Application.Datasource#">
				UPDATE Billback_Allied
				SET BB_Locked_By_Match_Central = 0
				WHERE Billback_ID IN (SELECT DD_Closure_ID FROM DD_Closure_Detail
				WHERE Deduction_ID = '#arguments.Deduction_ID#' AND Interfaced_On IS NULL AND Ack_Received IS NULL AND Deleted = 0)
			</CFQUERY>
		</cfif>
		 --->

		<!--- Dev Notes: Ana 12447 start ---------------------------------------------------------------------
		<CFSET DeductionManager = CreateObject("component", "components.Deduction.DeductionManager").init() /> --->
		<CFSET AssociatedBB = this.getAssociatedBB(Deduction_ID) />

		<CFIF LEFT(application.returned_customer_setting.Customer_Keyword,1) EQ "H" AND GetClosureInfo.DD_Closure_Type EQ 1><!--- "H" --->
			<CFSET DateTimeHolder = now()>
			<CFSET Billback_ID = GetClosureInfo.DD_Closure_ID>
			<CFSET Log_1700_DataInsert = CreateObject("Component", "Components.Interfaces.Log1700").init(Billback_ID,1,Deduction_ID,DateTimeHolder) />
			<CFSET Log_1700_DataInsert.DeleteFromLog()>
		</CFIF>
		<CFLOOP QUERY = "AssociatedBB">
			<CFSET Billback_ID = DD_Closure_ID>

			<CFIF LEFT(application.returned_customer_setting.Customer_Keyword,1) EQ "H" AND GetClosureInfo.DD_Closure_Type EQ 1><!--- "H" --->
				<CFSET Log_900_DataInsert = CreateObject("component", "components.Interfaces.Log900").init(Billback_ID,2,DateTimeHolder,Deduction_ID) />
				<CFSET Log_900_DataInsert.AddtoLog()>

				<CFSET Log_910_DataInsert = CreateObject("Component", "Components.Interfaces.Log910").init(Billback_ID, 2, Log_900_DataInsert.getLog_900_ID(), DateTimeHolder,Deduction_ID) />
				<CFSET Log_910_DataInsert.AddtoLog()>

				<CFSET Log_920_DataInsert = CreateObject("Component", "Components.Interfaces.Log920").init(Billback_ID, 2, Log_900_DataInsert.getLog_900_ID(), DateTimeHolder,Deduction_ID) />
				<CFSET Log_920_DataInsert.AddtoLog()>

				<CFIF Currentrow EQ RecordCount>
					<CFSET Log_1510_DataInsert = CreateObject("Component", "Components.Interfaces.Log1510").init(Billback_ID,1,Deduction_ID,DateTimeHolder) />
					<CFSET Log_1510_DataInsert.AddtoLog()>

					<CFSET Log_1700_DataInsert = CreateObject("Component", "Components.Interfaces.Log1700").init(Billback_ID,1,Deduction_ID,DateTimeHolder) />
					<CFSET Log_1700_DataInsert.AddtoLog()>
				</CFIF>
			</CFIF>

			<cfset useLakebaseForCheckParent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForCheckParent>
	<cftry>
		<cfset CheckParent = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#Billback_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckParent = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckParent>
<CFQUERY NAME="CheckParent" DATASOURCE="#Application.Datasource#">
				SELECT * FROM Billback WHERE Billback_ID = '#Billback_ID#'
			</CFQUERY>
</cfif>
			<CFIF CheckParent.BB_parent_ID NEQ "">
				<CFQUERY NAME="AnyUnclosedSplit" DATASOURCE="#Application.Datasource#">
					SELECT 	*
					FROM 	Billback
					WHERE 	BB_Parent_ID = '#CheckParent.BB_Parent_ID#' AND
							(	(BB_Closing_Method = 2 AND BB_Associated_To_DD = 0) OR
								(BB_Closing_Method = 1 AND Billback_Status_ID NOT IN (4,5))
							) AND
							Deleted = 0
			 	</CFQUERY>

				<CFIF AnyUnclosedSplit.RecordCOunt EQ 0>

					<cfset useLakebaseForIsAnyUnPaid = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForIsAnyUnPaid>
	<cftry>
		<cfset IsAnyUnPaid = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"bb_parent_id" = "eq.#CheckParent.BB_Parent_ID#",
				"billback_status_id" = "neq.5",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIsAnyUnPaid = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsAnyUnPaid>
<CFQUERY NAME="IsAnyUnPaid" DATASOURCE="#Application.Datasource#">
						SELECT 	*
						FROM 	Billback
						WHERE 	BB_Parent_ID = '#CheckParent.BB_Parent_ID#' AND
								Billback_Status_ID <> 5 AND
								Deleted = 0
					</CFQUERY>
</cfif>
					<CFIF IsAnyUnPaid.RecordCount EQ 0>
						<CFQUERY NAME="CloseBillbackParent" DATASOURCE="#Application.Datasource#">
							UPDATE Billback
							<!--- When "Billback: set to paid status when deduction is closed" app setting is ON, set to paid, else approved --->
							SET Billback_Status_ID = <CFIF variables.appsettings.getDDClosedBBStatus()> 5 <CFELSE> 3 </CFIF>
							WHERE Billback_ID = '#CheckParent.BB_Parent_ID#'
						</CFQUERY>
					</CFIF>
				</CFIF>
			</CFIF>
		</CFLOOP>
		<!--- </CFIF> --->

		<!---  Dev Notes: Ana 12447 End ------------------------------------------------------------- --->


		<CFQUERY NAME="UpdateClose" DATASOURCE="#Application.Datasource#">
			UPDATE Deductions
			SET DD_Closure_BBPaid = 1
			WHERE Deduction_ID = '#arguments.Deduction_ID#'
		</CFQUERY>
		<CFIF LEFT(application.returned_customer_setting.Customer_Keyword,1) EQ "H" AND GetClosureInfo.DD_Closure_Type EQ 1><!--- "H" --->
			<CFLOOP QUERY = "AssociatedBB">
				<CFSET Billback_ID = DD_Closure_ID>
				<CFSET Close_900 = 1>
				<CFSET Close_910 = 1>
				<CFSET Close_920 = 1>
				<CFSET Close_1510 = 1>
				<CFSET Close_1700 = 1>
				<!--- Ana 15454 - Commentting to avoid DeadLock
				<CFINCLUDE TEMPLATE="/GL_Code/GL_Code_In_Billback/Close_All_Interface_Insert.cfm"> --->
			</CFLOOP>
		</CFIF>

		<!--- Dev Note: Clay 8996: Set Deduction Status to (Closed Credit) if it is a Credit   --->
		<cfquery name="UpdateDeductionAfterPopulatingLogTables" datasource="#application.datasource#">
		UPDATE Deductions
		SET DD_Status = CASE WHEN IS_CREDIT = 1 THEN 9 ELSE 4 END
			<cfif isMatchCentral>
				,DD_Locked_By_Match_Central = 0
			</cfif>
		WHERE Deduction_ID = '#arguments.Deduction_ID#'
		</cfquery>

		<!---Close any reminders associated with this--->
		<cfquery name="CloseReminders" datasource="#application.datasource#">
		UPDATE DD_Reminders
		SET Deleted = 1
		WHERE Deduction_ID = '#arguments.Deduction_ID#'
		</cfquery>

		<!------
		D16950 G. Close from application should update the parent balance amount on parent credits
		Following update of ParentBalanceAmount should happen
		after the Deduction/Credit status is updated
		and outside the if condition for GetDeductionInfo.DD_IsChild IS 1
		------->
		<CFIF GetClosureInfo.DD_Closure_Type EQ 5> <!---- closed against credit ---->
			<cfset this.updateParentBalanceAmountForCreditsAssociated(deductionId = Deduction_ID) />
		</CFIF>

		<!---Close Parent--->
		<cfif GetDeductionInfo.DD_IsChild>
			<cfset closeParent(arguments.Deduction_ID) />
			<!---
			Ana: D17123 - Redefining the query as from 5.0 onwards user could
			create splits with positive and negative $ out of the same parent
			--->
			<!---
			<cfquery name="SeeIfAllAreClosed" datasource="#application.datasource#">
				SELECT DISTINCT DD_Status,IS_CREDIT
				FROM 	Deductions
				WHERE 	DD_DedID = '#GetDeductionInfo.DD_DedID#'
				AND 	DD_IsChild = 1
				AND		(
							(DD_Status <> 4 AND Is_Credit = 0) OR
							(DD_Status <> 9 AND Is_Credit = 1)
						)
				AND 	Deleted = 0
			</cfquery>

			<cfset DeductionManager = CreateObject("component", "components.deduction.DeductionManager") />
			<cfset DeductionManager.updateParentBalanceAmount(parentDeductionId = GetDeductionInfo.dd_parent_Id) />
			 --->
			<!---
			Ana: D17123 - Redefining the condition as from 5.0 onwards user could
			create splits with positive and negative $ out of the same parent
			which will result in two distinct status (4 - closed and 9 - closed credit) records
			--->
			<!---All children are closed, so close parent--->
			<cfif SeeIfAllAreClosed.Recordcount IS 0>
				<!---
				<CFQUERY NAME="GetCLosedBy" DATASOURCE="#Application.Datasource#">
					SELECT 	Top 1 DD_Closed_By
					FROM 	Deductions
					WHERE 	DD_Parent_ID = '#GetDeductionInfo.dd_parent_Id#' AND
							DD_IsChild = 1 AND
							Deleted = 0 AND
							(DD_Closed_By IS NOT NULL OR LEN(DD_Closed_By) > 0)
					ORDER BY DD_DedID_SP_Number
				</CFQUERY>
				<CFQUERY NAME="GetClearedAmount" DATASOURCE="#Application.Datasource#">
					SELECT 	SUM(Deductions.Cleared_Amount) as Total_Cleared_Amount
					FROM	Deductions
					WHERE 	Deleted = 0
					AND		DD_Parent_ID = '#GetDeductionInfo.dd_parent_Id#'
					AND		DD_IsChild = 1
					AND 	DD_Status IN (4,9)
				</CFQUERY>
				<cfquery name="CloseParent" datasource="#application.datasource#">
					UPDATE 	Deductions
					SET 	DD_Status = CASE WHEN IS_CREDIT = 1 THEN 9 ELSE 4 END,
							DD_Date_Closed = getdate(),
							DD_Closed_By = '#GetCLosedBy.DD_Closed_By#',
							Cleared_Amount = '#GetClearedAmount.Total_Cleared_Amount#'
					WHERE 	Deduction_ID = '#GetDeductionInfo.dd_parent_Id#'
					AND 	DD_IsParent = 1
				</cfquery>
				 --->

				<!----- Insert log entry for parent ----->
				<CFIF LEFT(application.returned_customer_setting.Customer_Keyword,1) EQ "H" AND GetClosureInfo.DD_Closure_Type EQ 1><!--- "H" --->

					<CFSET Log_1510_DataInsert = CreateObject("Component", "Components.Interfaces.Log1510").init("", 1, GetDeductionInfo.dd_parent_Id,DateTimeHolder) />
					<CFSET Log_1510_DataInsert.AddtoLog()>

					<CFSET Close_900 = 0>
					<CFSET Close_910 = 0>
					<CFSET Close_920 = 0>
					<CFSET Close_1510 = 1>
					<CFSET Close_1700 = 0>

					<cfset Original_Deduction_ID = Deduction_ID />
					<cfset Deduction_ID = GetDeductionInfo.dd_parent_Id />
					<!--- Ana 15454 - Commentting to avoid DeadLock
					<CFINCLUDE TEMPLATE="/GL_Code/GL_Code_In_Billback/Close_All_Interface_Insert.cfm"> --->
					<cfset Deduction_ID = Original_Deduction_ID />

				</CFIF>
			</cfif>
		</cfif>
		<!---
		<!-----  reset the flag -------->
		<cfquery name="UpdateDeductionAfterPopulatingLogTables" datasource="#application.datasource#">
		UPDATE 	Deductions
		SET 	Log_Processing = 0
		WHERE 	Deduction_ID = '#arguments.Deduction_ID#'
		</cfquery>
			 --->
		<cfcatch>

			<!-----  reset the flag -------->
			<cfquery name="UpdateDeductionAfterPopulatingLogTables" datasource="#application.datasource#">
			UPDATE 	Deductions
			SET 	Log_Processing = 0
			WHERE 	Deduction_ID = '#arguments.Deduction_ID#'
			</cfquery>

			<cfrethrow>

		</cfcatch>

		</cftry>

	</cffunction>


	<cffunction name="splitDeduction" output="false" returntype="array">
		<cfargument name="deductionId" required="true" type="string" />
		<cfargument name="newDeductionAmount" required="true" type="numeric" />
		<cfargument name="currentRecordSplitClassificationID" required="true" type="numeric" />
		<cfargument name="currentRecordSplitReason" required="true" type="string" />
		<cfargument name="balanceRecordSplitClassificationID" required="true" type="numeric" />
		<cfargument name="balanceRecordSplitReason" required="true" type="string" />

		<cfscript>
			var currentRecordDeductionId = "";
			var balanceRecordDeductionId = "";
			this.dmp(arguments);
			// build the array to pass to function splitDeductionMulti
			var arSplit = ArrayNew(1);
			var stSplit = StructNew();

			StructInsert(stSplit, "dd_amount", arguments.newDeductionAmount);
			StructInsert(stSplit, "classification", arguments.currentRecordSplitClassificationID);
			StructInsert(stSplit, "split_reason", arguments.currentRecordSplitReason);
			arrayAppend(arSplit, stSplit);

			// call function splitDeductionMulti to split the deduction
			arReturnValue = splitDeductionMulti(
					deductionId = arguments.deductionId,
					arSplit = arSplit,
					balanceRecordSplitClassificationID = arguments.balanceRecordSplitClassificationID,
					balanceRecordSplitReason = arguments.balanceRecordSplitReason
					);

			// get deduction id from the return value
			if (ArrayLen(arReturnValue) gte 1){
				currentRecordDeductionId = arReturnValue[1].deduction_id;
			}
			if (ArrayLen(arReturnValue) gte 2){
				balanceRecordDeductionId = arReturnValue[2].deduction_id;
			}


			// return the deduction id back as an array
			retrunArray = ArrayNew(1);
			retrunArray[1] = currentRecordDeductionId;
			retrunArray[2] = balanceRecordDeductionId;

		</cfscript>

		<cfreturn retrunArray />

	</cffunction>

	<cffunction name="splitDeductionMulti" output="false" returntype="array">
		<cfargument name="deductionId" required="true" type="string" />
		<cfargument name="arSplit" required="true" type="array" />
		<cfargument name="balanceRecordSplitClassificationID" required="true" type="numeric" />
		<cfargument name="balanceRecordSplitReason" required="true" type="string" />
		<cfargument name="matchCentralLock" required="false" type="boolean" default="0" />

		<cfscript>
			var arLen = ArrayLen(arguments.arSplit);
			var arReturnValue = ArrayNew(1);
			var stSplit = StructNew();
		</cfscript>

		<cfquery name="qCheckIfDeductionHasChildren" datasource="#application.datasource#">
			SELECT 	COUNT(*) as cnt
			FROM 	Deductions
			WHERE 	DD_Parent_ID = <cfqueryparam value="#arguments.deductionId#" cfsqltype="cf_sql_varchar">
			AND 	DD_IsChild = 1
			AND 	Deleted = 0
		</cfquery>

		<cfif qCheckIfDeductionHasChildren.cnt eq 0 and arLen gt 0><!--- If current record does not already have children --->

			<cfquery name="qGetDeductionDetails" datasource="#application.datasource#">
				SELECT	DD_DedID,
						DD_IsChild,
						DD_Amount,
						CASE
							WHEN DD_IsParent = 1 THEN Deduction_ID
							ELSE DD_Parent_ID
						END as Parent_Deduction_ID
				FROM	Deductions
				WHERE	Deduction_ID = <cfqueryparam value="#arguments.deductionId#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfscript>
				// add up the amount
				totalAllocatedAmount = 0;
				for (i=1;i LTE arLen;i=i+1){
					totalAllocatedAmount = totalAllocatedAmount + arguments.arSplit[i].dd_amount;
				}

				Parent_Deduction_ID = qGetDeductionDetails.Parent_Deduction_ID;
				// append balance split record
				balanceDeductionAmount = qGetDeductionDetails.DD_Amount - totalAllocatedAmount;

				// append balance split record
				if (balanceDeductionAmount neq 0){
					StructInsert(stSplit, "dd_amount", balanceDeductionAmount);
					StructInsert(stSplit, "classification", arguments.balanceRecordSplitClassificationID);
					StructInsert(stSplit, "split_reason", arguments.balanceRecordSplitReason);
					arrayAppend(arguments.arSplit, stSplit);
					arLen = ArrayLen(arguments.arSplit);
				}
			</cfscript>

			<cfif arLen eq 1><!---- split array has only 1 record, we will not create split --->

				<cfset arrayAppend(arReturnValue,
							buildSplitReturnStruct(
								arguments.deductionId,
								arguments.arSplit[1].dd_amount,
								arguments.arSplit[1].classification,
								arguments.arSplit[1].split_reason
								)) />

			<cfelseif arLen gt 1><!---- split array has more than one record, we will create splits --->

				<cftransaction action="begin">

					<cftry>

						<cfif qGetDeductionDetails.DD_IsChild eq 1>
							<cfquery name="qDeleteDeduction" datasource="#application.datasource#">
								UPDATE 	Deductions
								SET 	Deleted = 1
								WHERE 	Deduction_ID = <cfqueryparam value="#arguments.deductionId#" cfsqltype="cf_sql_varchar">
							</cfquery>
						</cfif>

						<cfloop from="1" to="#arLen#" index="i">

							<cfstoredproc procedure = "USP_DEDUCTION_SPLIT" dataSource="#application.datasource#">
						   		<cfprocparam type="IN" CFSQLType="CF_SQL_VARCHAR" value="#Parent_Deduction_ID#"  />
								<cfprocparam type="IN" CFSQLType="CF_SQL_FLOAT" value="#arguments.arSplit[i].dd_amount#"  />
								<cfprocparam type="IN" CFSQLType="CF_SQL_INTEGER" value="#arguments.arSplit[i].classification#"  />
								<cfprocparam type="IN" CFSQLType="CF_SQL_VARCHAR" value="#arguments.arSplit[i].split_reason#"  />
								<cfprocparam type="OUT" CFSQLType="CF_SQL_VARCHAR" variable="ReturnDeductionId"  />
							</cfstoredproc>

							<cfif arguments.matchCentralLock>
								<cfquery name="lockDeduction" datasource="#application.datasource#">
									UPDATE 	Deductions
									SET 	Is_Locked = 1,
											Locked_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">,
											DD_Locked_By_Match_Central = 1
									WHERE 	Deduction_ID = <cfqueryparam value="#ReturnDeductionId#" cfsqltype="cf_sql_varchar">
								</cfquery>
							</cfif>

							<cfset arrayAppend(arReturnValue,
									buildSplitReturnStruct(
										ReturnDeductionId,
										arguments.arSplit[i].dd_amount,
										arguments.arSplit[i].classification,
										arguments.arSplit[i].split_reason
										)) />

						</cfloop>

						<cfset updateParentBalanceAmount(Parent_Deduction_ID) />

						<cfquery name="qUpdateDeductionSplitCount" datasource="#application.datasource#">
							UPDATE	Deductions
							SET		Split_Count = (SELECT COUNT(*) FROM Deductions WHERE DD_Parent_ID = <cfqueryparam value="#Parent_Deduction_ID#" cfsqltype="cf_sql_varchar"> AND DD_IsChild = 1 AND Deleted = 0)
							<!---66788--->
							<cfif variables.appSettings.getDD_Show_Classification()>
							,DD_Classification_ID = ISNULL(DD_Classification_ID,#arguments.arSplit[1].classification#)
							</cfif>
							WHERE	Deduction_ID = <cfqueryparam value="#Parent_Deduction_ID#" cfsqltype="cf_sql_varchar">
						</cfquery>


						<cfcatch>

							<cftransaction action="rollback" />
							<cfrethrow />

						</cfcatch>

					</cftry>

					<cftransaction action="commit" />

				</cftransaction>


			</cfif><!---- end: split array has more than one record --->

		</cfif><!--- If current record does not already have children --->

		<cfreturn arReturnValue />

	</cffunction>

	<cffunction name="buildSplitReturnStruct" output="false" returntype="struct">
		<cfargument name="deductionId" required="true" type="string" />
		<cfargument name="DeductionAmount" required="true" type="numeric" />
		<cfargument name="SplitClassificationID" required="true" type="numeric" />
		<cfargument name="SplitReason" required="true" type="string" />

		<cfscript>
			var stSplit = StructNew();

			StructInsert(stSplit, "deduction_id", arguments.deductionId);
			StructInsert(stSplit, "dd_amount", arguments.DeductionAmount);
			StructInsert(stSplit, "classification", arguments.SplitClassificationID);
			StructInsert(stSplit, "split_reason", arguments.SplitReason);
		</cfscript>

		<cfreturn stSplit />

	</cffunction>

	<cffunction name="associateCreditsToDeduction" output="false" returntype="boolean">
		<cfargument name="deductionId" required="true" type="string" />
		<cfargument name="creditIdList" required="true" type="string" />
		<cfargument name="fromCredit" required="true" type="numeric" />
		<cfargument name="fromMatchCentral" required="false" type="numeric" default="0" />

		<CFIF arguments.fromCredit EQ 0>
			<!------ If from deduction --->
			<!---- release any billback which is already linked to this deduction ----->
			<cfset RemoveAssociatedBB(arguments.deductionId) />
			<!---
			<CFQUERY NAME="IsAnyAssociatedBB" DATASOURCE="#Application.Datasource#">
				SELECT DD_Closure_ID FROM Deductions WHERE Deduction_ID = '#arguments.deductionId#' AND DD_Closure_Type = 1
			</CFQUERY>
			<CFIF IsAnyAssociatedBB.RecordCount GT 0 AND IsAnyAssociatedBB.DD_Closure_ID NEQ "">
			<CFQUERY NAME="UnAssociateBBIfAny" DATASOURCE="#Application.Datasource#">
				UPDATE Billback
				SET BB_Associated_To_DD = 0
				WHERE Billback_ID = '#IsAnyAssociatedBB.DD_Closure_ID#'
			</CFQUERY>
			</CFIF>
			--->

			<!------
			D16948: JRS - Deduction record was sent in GL Credit interface file
			If the deduction is already flagged as write-off, re-set it
			We don't want a deduction flagged as both write-off and associated to a credit
			Even though label D16948 is supposed to stop the user from continuing the association to billback/credit if it is already flagged as write-off,
			as we already have existing code which removes existing billback/credit association,
			it is easier and less risk to do the same way to re-set the write-off
			----->
			<cfset useLakebaseForResetWriteOff = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForResetWriteOff>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{
				"deduction_id" = "eq.#arguments.deductionId#",
				"is_write_off" = "eq.1"
			},
			{
				"is_write_off" = "0",
				"write_off_by" = javaCast("null",""),
				"write_off_date" = javaCast("null",""),
				"write_off_toopen_reason" = "Deduction is getting associated to credit"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForResetWriteOff = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForResetWriteOff>
<CFQUERY NAME="ResetWriteOff" DATASOURCE="#Application.Datasource#">
				UPDATE 	Deductions
				SET 	Is_Write_Off = 0,
						Write_Off_By = NULL,
						Write_Off_Date = NULL,
						Write_Off_ToOpen_Reason = 'Deduction is getting associated to credit'
				WHERE 	Deduction_ID = '#arguments.deductionId#'
				AND		Is_Write_Off = 1
			</CFQUERY>
</cfif>


			<cfset RemoveClosureFromCreditForThisDeduction(arguments.deductionId) />
			<cfset RemoveClosureFromDeduction(arguments.deductionId) />

			<CFSET bUpdatedClosureIDWithFirstCredit = 0 />
			<CFLOOP list="#arguments.creditIdList#" index="SELECTED_CREDIT_ID">

				<cftransaction action="BEGIN" isolation="READ_COMMITTED">
				<cftry>
					<!------ Update the flags, status and credit association on current deduction ----->
					<CFIF bUpdatedClosureIDWithFirstCredit EQ 0>
						<!------ populate DD_Closure_ID with top 1 credit ID so that we do not have to chnage the code where we chnage DD_Closure_ID IS NOT NULL throughout the application.  ----->
						<CFQUERY NAME="AssociateOneCreditToDD" DATASOURCE="#Application.Datasource#">
							UPDATE 	Deductions
							SET 	DD_Status = CASE WHEN Is_Credit = 1 THEN 8 ELSE 2 END,
									DD_Closure_Type = 5,
									DD_Closure_ID = <cfqueryparam value="#SELECTED_CREDIT_ID#" cfsqltype="CF_SQL_VARCHAR">

							WHERE 	Deduction_ID = <cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR">
						</CFQUERY>
						<CFSET bUpdatedClosureIDWithFirstCredit = 1 />
					</CFIF>

					<CFQUERY NAME="AssociateCreditToDD" DATASOURCE="#Application.Datasource#">
						INSERT INTO DD_Closure_Detail (Deduction_ID, DD_Closure_ID)
						VALUES (<cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#SELECTED_CREDIT_ID#" cfsqltype="CF_SQL_VARCHAR">)
					</CFQUERY>

					<!------ Update the flags, status and deduction association on the selected credit ----->
					<CFQUERY NAME="AssociateDDToCredit" DATASOURCE="#Application.Datasource#">
						UPDATE 	Deductions
						SET 	DD_Status = CASE WHEN Is_Credit = 1 THEN 9 ELSE 4 END,
								DD_Closure_Type = 6,
								Cleared_Amount = DD_amount,
								DD_Closure_ID = <cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR">

						WHERE 	Deduction_ID = <cfqueryparam value="#SELECTED_CREDIT_ID#" cfsqltype="CF_SQL_VARCHAR">
					</CFQUERY>

					<cfset closeParent(SELECTED_CREDIT_ID) />
					<!---
					<CFQUERY NAME="IsAnyUnClosedChild" DATASOURCE="#Application.Datasource#">
						SELECT DD_DedID FROM Deductions
						WHERE DD_DedID = (SELECT DD_DedID FROM Deductions WHERE Deduction_ID = <cfqueryparam value="#SELECTED_CREDIT_ID#" cfsqltype="CF_SQL_VARCHAR">) AND
						DD_IsChild = 1 AND
						(
							(DD_Status <> 4 AND Is_Credit = 0) OR
							(DD_Status <> 9 AND Is_Credit = 1)
						) AND
						Deleted = 0
					</CFQUERY>
					<CFIF IsAnyUnClosedChild.RecordCount EQ 0>
						<CFQUERY NAME="CloseParent" DATASOURCE="#Application.Datasource#">
							UPDATE Deductions
							SET DD_Status = CASE WHEN IS_CREDIT = 1 THEN 9 ELSE 4 END,
								Cleared_Amount = DD_amount
							WHERE Deduction_ID = (SELECT DD_Parent_ID FROM Deductions WHERE Deduction_ID = <cfqueryparam value="#SELECTED_CREDIT_ID#" cfsqltype="CF_SQL_VARCHAR">)
						</CFQUERY>
					</CFIF>
					--->
					<cftransaction action="COMMIT" />
					<cfcatch>
						<cftransaction action="ROLLBACK" />
					</cfcatch>
				</cftry>
				</cftransaction>

			</CFLOOP>

		<CFELSE>
			<!------ If from Credit --->

			<!------
			arguments.deductionId = the selected DEDUCTION ID
			creditID = Current CREDIT ID
			----->
			<cfset creditID = ListFirst(arguments.creditIdList) />

			<!------*********************************************************************************
			D16948: JRS - Deduction record was sent in GL Credit interface file
			check if this credit can be associated to a deduction - START
			It is possible that someone has already flagged it as write-off, associated to a billback or deduction
			*********************************************************************************------>
			<cfset DeductionLinkManager = CreateObject("component", "components.deduction.DeductionLinkManager").init() />
			<cfset bCanAssocCreditToDeduction = DeductionLinkManager.isCreditAssocToDeductionAvailable(deductionId = creditID, fromMatchCentral = arguments.fromMatchCentral) />

			<cfif bCanAssocCreditToDeduction eq 0>

				<cfreturn false />

			</cfif>

			<!------*********************************************************************************
			check if this credit can be associated to a deduction - END
			*********************************************************************************------>

			<!------ Update the flags, status and credit association on current credit ----->
			<CFQUERY NAME="AssociateDDToCredit" DATASOURCE="#Application.Datasource#">
				UPDATE 	Deductions
				SET 	DD_Status = CASE WHEN Is_Credit = 1 THEN 9 ELSE 4 END,
						DD_Closure_Type = 6,
						Cleared_Amount = DD_amount,
						DD_Closure_ID = '#arguments.deductionId#'

				WHERE 	Deduction_ID = '#creditID#'
			</CFQUERY>

			<CFQUERY NAME="AssociateCreditToDD" DATASOURCE="#Application.Datasource#">
				INSERT INTO DD_Closure_Detail (Deduction_ID, DD_Closure_ID)
				VALUES (<cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#creditID#" cfsqltype="CF_SQL_VARCHAR">)
			</CFQUERY>

			<!------ Update the flags, status and deduction association on the selected deduction ----->
			<CFQUERY NAME="AssociateCreditToDD" DATASOURCE="#Application.Datasource#">
				UPDATE 	Deductions
				SET 	DD_Status = CASE WHEN Is_Credit = 1 THEN 8 ELSE 2 END,
						DD_Closure_Type = 5,
						DD_Closure_ID = '#creditID#'

				WHERE 	Deduction_ID = '#arguments.deductionId#'
			</CFQUERY>

			<CFSET closeParent(creditID)>
			<!---
			<CFQUERY NAME="IsAnyUnClosedChild" DATASOURCE="#Application.Datasource#">
				SELECT * FROM Deductions
				WHERE DD_DedID = (SELECT DD_DedID FROM Deductions WHERE Deduction_ID = <cfqueryparam value="#creditID#" cfsqltype="CF_SQL_VARCHAR">) AND
				DD_IsChild = 1 AND DD_Status = 8 AND Deleted = 0
			</CFQUERY>

			<CFIF IsAnyUnClosedChild.RecordCount EQ 0>
				<CFQUERY NAME="CloseParent" DATASOURCE="#Application.Datasource#">
					UPDATE Deductions
					SET DD_Status = 9,
						Cleared_Amount = DD_amount
					WHERE Deduction_ID = (SELECT DD_Parent_ID FROM Deductions WHERE Deduction_ID = <cfqueryparam value="#creditID#" cfsqltype="CF_SQL_VARCHAR">)
				</CFQUERY>
			</CFIF>	 --->
		</CFIF>

	<cfreturn true />

	</cffunction>

	<cffunction name="closeParent" output="false" returntype="void">
		<cfargument name="deductionId" required="true" type="string" />

		<cfquery name="GetDeductionInfo" datasource="#application.datasource#">
			SELECT *
			FROM Deductions
			WHERE Deduction_ID = <cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!---
		Ana: D17123 - Redefining the query as from 5.0 onwards user could
		create splits with positive and negative $ out of the same parent
		--->
		<CFIF GetDeductionInfo.DD_IsChild EQ 1>
			<cfquery name="SeeIfAllAreClosed" datasource="#application.datasource#">
				SELECT DISTINCT DD_Status,IS_CREDIT
				FROM 	Deductions
				WHERE 	DD_DedID = '#GetDeductionInfo.DD_DedID#'
				AND 	DD_IsChild = 1
				---- Ana D25013 - in some cases DD_Status = 4 but the Is_Credit = 1, not able to recreate - So changed the below update condition
				AND		DD_Status NOT IN (4,9)
				/*
				AND		(
							(DD_Status <> 4 AND Is_Credit = 0) OR
							(DD_Status <> 9 AND Is_Credit = 1)
						)*/
				AND 	Deleted = 0
			</cfquery>

			<cfset updateParentBalanceAmount(parentDeductionId = GetDeductionInfo.dd_parent_Id) />
			<!---
			Ana: D17123 - Redefining the condition as from 5.0 onwards user could
			create splits with positive and negative $ out of the same parent
			which will result in two distinct status (4 - closed and 9 - closed credit) records
			--->

			<!---All children are closed, so close parent--->
			<cfif SeeIfAllAreClosed.Recordcount IS 0>
				<CFQUERY NAME="GetCLosedBy" DATASOURCE="#Application.Datasource#">
					SELECT 	Top 1 DD_Closed_By
					FROM 	Deductions
					WHERE 	DD_Parent_ID = '#GetDeductionInfo.dd_parent_Id#' AND
							DD_IsChild = 1 AND
							Deleted = 0 AND
							(DD_Closed_By IS NOT NULL OR LEN(DD_Closed_By) > 0)
					ORDER BY DD_DedID_SP_Number
				</CFQUERY>
				<CFQUERY NAME="GetClearedAmount" DATASOURCE="#Application.Datasource#">
					SELECT 	SUM(Deductions.Cleared_Amount) as Total_Cleared_Amount
					FROM	Deductions
					WHERE 	Deleted = 0
					AND		DD_Parent_ID = '#GetDeductionInfo.dd_parent_Id#'
					AND		DD_IsChild = 1
					AND 	DD_Status IN (4,9)
				</CFQUERY>
				<cfquery name="CloseDeductionParent" datasource="#application.datasource#">
					UPDATE 	Deductions
					SET 	DD_Status = CASE WHEN IS_CREDIT = 1 THEN 9 ELSE 4 END,
							DD_Date_Closed = getdate(),
							DD_Closed_By = '#GetCLosedBy.DD_Closed_By#',
							Cleared_Amount = '#GetClearedAmount.Total_Cleared_Amount#'
					WHERE 	Deduction_ID = '#GetDeductionInfo.dd_parent_Id#'
					AND 	DD_IsParent = 1
				</cfquery>
			</cfif>
		</CFIF>
	</cffunction>

	<cffunction name="addUserReference" output="false" returntype="void">
		<cfargument name="deductionId" type="string" required="true" />
		<cfargument name="DD_User_Reference1" type="string" required="false" default="" />
		<cfargument name="DD_User_Reference2" type="string" required="false" default="" />

		<CFQUERY NAME="save_UserReference" DATASOURCE="#Application.Datasource#">
			update 	Deductions
			set	DD_User_Reference1  = <cfqueryparam value="#DD_User_Reference1#" cfsqltype="CF_SQL_VARCHAR">
				,DD_User_Reference2 = <cfqueryparam value="#DD_User_Reference2#" cfsqltype="CF_SQL_VARCHAR">
			where	Deduction_ID = <cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>

	</cffunction>
	<!--- D29481:Non trade deductions START--->
	<cffunction name="RFADeduction" output="false">
		<cfargument name="deductionId" type="string" required="true" />
		<CFQUERY NAME="save_UserReference" DATASOURCE="#Application.Datasource#">
			UPDATE Deductions
			SET   	DD_Status = 3,
					RFA_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">,
					RFA_Date = getdate(),
					Is_Non_Trade_Off = 1
			WHERE Deduction_ID = <cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>
	</cffunction>
	<!--- D29481:Non trade deductions END --->

	<cffunction name="ReopenDeduction" output="false" returntype="void">
		<cfargument name="deductionId" required="true" type="string" />

		<CFQUERY NAME="DeductionInfo" DATASOURCE="#Application.Datasource#">
			SELECT * FROM Deductions WHERE Deduction_ID = '#arguments.deductionId#'
		</CFQUERY>

		<!----- - add notes entry ----->
		<CFIF DeductionInfo.DD_Closure_Sent NEQ 1>
			<cfset useLakebaseForAddNotes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_notes")>
<cfif useLakebaseForAddNotes>
	<cftry>
		<cfset application.oLakebase.insertRow("dd_notes", {
			"deduction_id" = "#arguments.deductionId#",
			"dd_note" = "Closed and Reopened on the same date",
			"dd_note_date" = "#now()#",
			"dd_note_by" = "#request.AccessStructure.User_ID#",
			"automated_notes" = "1"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForAddNotes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAddNotes>
<CFQUERY NAME="AddNotes" DATASOURCE="#Application.Datasource#">
				INSERT INTO DD_Notes (Deduction_ID,DD_Note,DD_Note_Date,DD_Note_By,Automated_notes)
				VALUES ('#arguments.deductionId#','Closed and Reopened on the same date',getdate(),'#request.AccessStructure.User_ID#',1)
			</CFQUERY>
</cfif>
		<CFELSE>
			<CFQUERY NAME="AddNotes" DATASOURCE="#Application.Datasource#">
				INSERT INTO DD_Notes (Deduction_ID,DD_Note,DD_Note_Date,DD_Note_By,Automated_notes)
				VALUES ('#arguments.deductionId#','Deduction was Reopened',getdate(),'#request.AccessStructure.User_ID#',1)
			</CFQUERY>
		</CFIF>

		<!----- - Reset the deduction back to open status  ----->
		<!----- - Reset sent flags for 1510 and 1700, ack received, reopen sent etc. ----->
		<!--- Dev Note: Clay 8996: Deductions Credit allows write-off --->
		<cfquery name="GetDeductionNumber" datasource="#application.datasource#">
		UPDATE 	Deductions
		SET 	DD_Status = CASE WHEN Is_Credit = 1 THEN 8 ELSE CASE WHEN Is_Last_Status_Rebill = 1 THEN 7 ELSE 2 END END,
				ReOpened = CASE WHEN DD_Closure_Sent = 1 THEN 1 ELSE ReOpened END,
				DD_ReOpened_On = getdate(),
				DD_Reopened_Sent = 0,
				DD_Closure_Sent = 0,
				DD_Closure_GL_Sent = 0,
				Ack_received_Closure = 0,
				Ack_received_Reopen = 0
		WHERE 	(Deductions.Deduction_ID = '#arguments.deductionId#'
				<CFIF DeductionInfo.DD_Parent_ID NEQ ""><!---- D13448: reopen the parent also ------>
					OR Deductions.Deduction_ID = '#DeductionInfo.DD_Parent_ID#' OR Deductions.Deduction_ID = '#DeductionInfo.DD_Parent_ID#'
				</CFIF>
				)
		</cfquery>


		<!----- - Reset the billback to approved status if closed by billback ----->
		<CFIF DeductionInfo.DD_Closure_Type EQ 1>
			<cfquery name="ChangeBBStatusFrom5To3" datasource="#application.datasource#">
				UPDATE Billback
				SET Billback_Status_ID = 3,
					<!--- D30653: Reset any interface arrows on the billback when we reset the arrows on the deduction --->
					BB_Payment_Request_Sent = 0,
					BB_Payment_Request_Sent_On = NULL,
					BB_Received_Ack_Type = 0,
					BB_Received_Ack_Date = NULL,
					DD_Closure_Sent_On = NULL
				<cfif application.returned_customer_setting.customer_keyword IS "Heinz">
					,BB_Associated_To_DD = 0
				</cfif>
				WHERE Billback_ID IN (SELECT DD_Closure_ID FROM DD_Closure_Detail
				WHERE Deduction_ID = '#arguments.deductionId#' AND
				Deleted = 0)
			</cfquery>
		</CFIF>

		<CFQUERY NAME="ResetBB_Credit" DATASOURCE="#Application.Datasource#">
			UPDATE 	DD_Closure_Detail
			SET 	Interfaced_On = NULL,
					Ack_Received = NULL
			WHERE 	Deduction_ID = '#arguments.deductionId#' AND Deleted = 0
		</CFQUERY>
		<!--- D25559 - On reopen of DD make the parent BB status = Approved --->
		<CFQUERY NAME="UpdParentStatus" DATASOURCE="#Application.Datasource#">
			SELECT  	BB_Parent_ID
			FROM 		Billback
			INNER JOIN 	DD_Closure_Detail ON DD_Closure_Detail.Deduction_ID = '#arguments.deductionId#' AND
						DD_Closure_Detail.DD_Closure_ID = Billback.Billback_ID AND
						DD_Closure_Detail.Deleted = 0 AND Billback.BB_Parent_ID IS NOT NULL AND
						Billback.Deleted = 0
		</CFQUERY>
		<cfloop query="UpdParentStatus">
		<!------ set the parent status ------->
		<cfset setBillbackSplitParentStatus(billbackParentId = BB_parent_ID) />
		</cfloop>

		<CFIF DeductionInfo.DD_Closure_Type EQ 5> <!---- closed against credit ---->
			<cfset DeductionManager = CreateObject("component", "components.deduction.DeductionManager") />
			<cfset DeductionManager.updateParentBalanceAmountForCreditsAssociated(deductionId = '#arguments.deductionId#') />
		</cfif>

	</cffunction>

	<cffunction name="setBillbackSplitParentStatus" access="public" returntype="void" output="false">
		<cfargument name="billbackParentId" type="string" required="Yes">

		<cfif arguments.billbackParentId neq ""><!--- is a split --->
			<!---
				1. if all children are
				in payment request/paid status (for closing method = payment)
				or associated to a deduction   (for closing method = deduction)
				then the parent status will be payment request

				2. if all children are
				in paid status then the parent status will be paid status

				3. if all children are
				in approved status then the parent status will be approved status
			--->
			<CFQUERY NAME="AnyUnclosedSplit" DATASOURCE="#Application.Datasource#">
				SELECT 	*
				FROM 	Billback
				WHERE 	BB_Parent_ID = '#arguments.billbackParentId#'
				AND		(
							(BB_Closing_Method = 2 AND BB_Associated_To_DD = 0)
							OR
							(BB_Closing_Method = 1 AND Billback_Status_ID NOT IN (4,5))
						)
				AND		Deleted = 0
		 	</CFQUERY>
		 	<cfset newParentStatus = 3 />
		 	<CFIF AnyUnclosedSplit.RecordCount EQ 0><!--- option#1 - all children are in payment request/paid/associated to ded --->
			 	<cfset newParentStatus = 4 />
			 	<CFQUERY NAME="IsAnyUnPaid" DATASOURCE="#Application.Datasource#">
					SELECT 	*
					FROM 	Billback
					WHERE 	BB_Parent_ID = '#arguments.billbackParentId#'
					AND		Billback_Status_ID <> 5
					AND		Deleted = 0
				</CFQUERY>
				<CFIF IsAnyUnPaid.RecordCount EQ 0><!--- option#2 - all children are in paid status --->
					<cfset newParentStatus = 5 />
				</CFIF>
			</CFIF>
			<CFQUERY NAME="CloseParent" DATASOURCE="#Application.Datasource#">
				UPDATE 	Billback
				SET 	Billback_Status_ID = <cfqueryparam value="#newParentStatus#" cfsqltype="cf_sql_integer">
				WHERE 	Billback_ID = <cfqueryparam value="#arguments.billbackParentId#" cfsqltype="cf_sql_varchar">
			</CFQUERY>

		</cfif>

	</cffunction>

	<!--- Check whether the deduction is a split or has a split --->
	<cffunction name="getDeductionIsSplitORHasSplit" returntype="boolean" output="false">
		<cfargument name="deductionId" type="string" required="true" />

		<cfset var IsSplit = 0>

		<CFQUERY NAME="qgetDeductionIsSplitORHasSplit" DATASOURCE="#Application.Datasource#">
			SELECT 1
			FROM Deductions
			WHERE Deduction_ID = <cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR">
			AND deleted = 0
			AND
			(
			(DD_Parent_ID IS NULL AND Split_Count > 0)<!--- HAS A SPLIT (PARENT) --->
			OR
			(DD_Parent_ID IS NOT NULL AND DD_IsChild = 1)<!--- IS A SPLIT (CHILD) --->
			)
		</CFQUERY>

		<CFIF qgetDeductionIsSplitORHasSplit.RecordCount GT 0>
			<cfset IsSplit = 1>
		</CFIF>

		<cfreturn IsSplit>

	</cffunction>
<!--- 70923 :: Create new feature for deduction workflow START --->
	<cffunction name="getExistingAnalystProfile" returntype="query">
		<CFQUERY NAME="Get_Existing_Analyst_Profile" datasource="#application.datasource#">
				SELECT DISTINCT P.Profiles_Desc, P.Profiles_ID
				FROM DD_Analyst DA
				INNER JOIN _users U
				ON U.User_ID = DA.Analyst_User_ID
				INNER JOIN Profiles P
				ON P.Profiles_ID = U.Profiles_ID
				AND P.Deleted = 0
				WHERE DA.Deleted = 0
		</CFQUERY>
		<cfreturn Get_Existing_Analyst_Profile>
	</cffunction>

	<cffunction name="getActionAnalystProfile" returntype="query" access="remote" >
		<cfargument name="DDStageID" type="numeric" required="true" />
		<CFQUERY NAME="Get_Action_Selected_Analyst" datasource="#application.datasource#">
			SELECT P.Profiles_Desc, P.Profiles_ID
			FROM DD_Action_Analyst DAA
			INNER JOIN Profiles P
			ON P.Profiles_ID = DAA.Analyst_Profiles_ID
			WHERE DAA.Deleted = 0
			AND DAA.DD_Stage_ID = #arguments.DDStageID#
		</CFQUERY>
		<cfreturn Get_Action_Selected_Analyst>
	</cffunction>

	<cffunction name="getClassificationAnalystProfile" returntype="query" access="remote" >
		<cfargument name="DDClassificationID" type="numeric" required="true" />
		<CFQUERY NAME="Get_Classification_Selected_Analyst_Profile" datasource="#application.datasource#">
			SELECT P.Profiles_Desc, P.Profiles_ID
			FROM DD_Classification_Analyst DCA
			INNER JOIN Profiles P
			ON P.Profiles_ID = DCA.Analyst_Profiles_ID
			WHERE DCA.Deleted = 0
			AND DCA.DD_Classification_ID = #arguments.DDClassificationID#
		</CFQUERY>
		<cfreturn Get_Classification_Selected_Analyst_Profile>
	</cffunction>
<!--- 70923 :: Create new feature for deduction workflow END --->
	<cffunction name="getAnalystNames" returntype="query" access="remote" >
		<cfargument name="DDStageID" type="numeric" required="false" default="0" />
		<cfargument name="DDClassificationID" type="numeric" required="false" default="0" />

		<CFQUERY NAME="Get_Analyst" datasource="#application.datasource#">
				SELECT U.user_id , U.Name_First+' '+U.Name_Last AS Name
				FROM DD_Analyst DA
				INNER JOIN _Users U
				ON U.User_ID = DA.Analyst_User_ID
				<cfif DDClassificationID>
				INNER JOIN DD_Classification_Analyst  DCA
				ON DCA.Analyst_Profiles_ID = U.Profiles_ID
				WHERE DCA.DD_Classification_ID  = #arguments.DDClassificationID#
				AND DCA.Deleted = 0
				<cfelse>
				INNER JOIN DD_Action_Analyst  DAA
				ON DAA.Analyst_Profiles_ID = U.Profiles_ID
				WHERE DAA.DD_Stage_ID  = #arguments.DDStageID#
				AND DAA.Deleted = 0
				</cfif>
				AND  DA.Deleted = 0
		</CFQUERY>
		<cfreturn Get_Analyst>
	</cffunction>

	<cffunction name="DisableLinks" returntype="boolean" output="false">
		<cfargument name="Deduction_ID" required="true" type="string" />
		<cfargument name="forAction" required="false" type="boolean" default="0" />

		<cfset disableBasedOnClassification = 0>
		<CFQUERY name="GetClassDescription" DATASOURCE="#Application.Datasource#">
			select DDC.DD_Classification_Desc, D.dd_stage
			from Deductions D
			inner join DD_Classification DDC
			ON DDC.DD_Classification_ID = D.DD_Classification_ID
			WHERE D.Deduction_ID = '#arguments.Deduction_ID#'
			AND DDC.deleted = 0
		</CFQUERY>
		<cfif arguments.forAction>
			<cfif len(GetClassDescription.DD_Classification_Desc) EQ 0 OR GetClassDescription.DD_Classification_Desc EQ 'UNKNOWN'>
				<cfset disableBasedOnClassification = 1>
			</cfif>
		<cfelse>
			<cfif GetClassDescription.DD_Classification_Desc EQ 'UNKNOWN' OR (len(GetClassDescription.dd_stage) EQ 0 OR GetClassDescription.dd_stage EQ 0)>
				<cfset disableBasedOnClassification = 1>
			</cfif>
		</cfif>
		<cfreturn disableBasedOnClassification>
	</cffunction>

	<cffunction name="getClassificationReasonCode" returntype="query" access="remote" >
		<cfargument name="DDClassificationID" type="numeric" required="true" />
		<CFQUERY NAME="Get_Classification_Selected_Reason_code" datasource="#application.datasource#">
			select DISTINCT DRC.DD_Reason_Code_ID,DRC.DD_Reason_Code_Description
			from DD_Reason_Code DRC
			inner join DD_Classification DDC
			<!--- WR 73332- We use only the last 6 digits to mactch the "GL_Account_code" --->
			ON DDC.GL_Account_code = Right(DRC.GL_Account_code,6)
			where DDC.DD_Classification_ID = #arguments.DDClassificationID#
			AND DRC.deleted = 0
		</CFQUERY>
		<cfreturn Get_Classification_Selected_Reason_code>
	</cffunction>

</cfcomponent>