<cfcomponent name="MassPriceChange" hint="handles all the function call for mass price change">

	<!--- init --->
	<cffunction name="init" output="false" returntype="mvc.Models.Program.Upload.MassPriceChange">
		<cfreturn this />
	</cffunction>

	<!--- Check if the upload is locked --->
	<cffunction name="checkLock" access="public" returntype="query" output="false" >

		<cfset var qCheckLock = "" />
		<cfquery name="qCheckLock" datasource="#application.datasource#">
			SELECT 		ISNULL(Mass_Price_Lock.IS_LOCKED, 0) AS IS_LOCKED,
						Mass_Price_Lock.USER_ID,
						(NAME_FIRST + ' ' + NAME_LAST) AS LOCKER,
						_Users.User_Code,
						_Users.User_Email
			FROM		Mass_Price_Lock
			LEFT JOIN	_USERS
			ON			_USERS.USER_ID =  Mass_Price_Lock.USER_ID
			WHERE		Mass_Price_Lock.DELETED = 0
			AND			Mass_Price_Lock.IS_LOCKED = 1
			ORDER BY	IS_LOCKED DESC
		</cfquery>

		<cfreturn qCheckLock />
	</cffunction>

	<!--- Lock the page --->
	<cffunction name="lockPage" access="public" returntype="boolean" >
		<cfargument name="user_id" type="string" required="true">

		<cfset var qLock = "" />
		<cfset var temp = this.unlockPage()/> <!--- unlock first others --->

		<cfquery name="qLock" datasource="#application.datasource#">
			INSERT INTO		Mass_Price_Lock (USER_ID,IS_LOCKED)
			VALUES			(<cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">,
							 <cfqueryparam value="1" cfsqltype="cf_sql_varchar">)
		</cfquery>

		<cfreturn true />
	</cffunction>

	<!--- Unlock the page --->
	<cffunction name="unlockPage" access="public" returntype="boolean" >

		<cfset var qUnlock = "" />
		<cfquery name="qUnlock" datasource="#application.datasource#">
			UPDATE		Mass_Price_Lock
			SET			IS_LOCKED = <cfqueryparam value="0" cfsqltype="cf_sql_bit">,
						DELETED = <cfqueryparam value="1" cfsqltype="cf_sql_bit">
			WHERE		IS_LOCKED = 1
			AND			DELETED = 0
		</cfquery>

		<cfreturn true />
	</cffunction>

	<!--- check if there is a schedule --->
	<cffunction name="checkScheduled" access="public" returntype="boolean">
		<cfset var qCheckScheduled= "" />
		<cfset var returnVar = 0 />

		<cfquery name="qCheckScheduled" datasource="#application.datasource#" >
			SELECT 	COUNT(*) AS COUNTS
			FROM	Mass_Price_Schedule
			WHERE	Deleted = 0
			AND		Scheduled = 1
		</cfquery>

		<!--- if count greater than 0 return true --->
		<cfreturn qCheckScheduled.counts />
	</cffunction>

	<!--- clear Schedule --->
	<cffunction name="clearSchedule" access="public" returntype="void">

		<cfquery name="qqResetUploadSchedule" datasource="#application.datasource#">
			UPDATE 	Mass_Price_Schedule
			SET		Deleted = 1
			WHERE	Deleted = 0
		</cfquery>
	</cffunction>

	<!--- clear existing Data from data holding tables  --->
	<cffunction name="clearData" access="public" returntype="void">

		<cfquery name="qClearData" datasource="#application.datasource#">
			TRUNCATE TABLE Mass_Price_Templates
			TRUNCATE TABLE Mass_Price_Products
			TRUNCATE TABLE Mass_Price_Programs
			TRUNCATE TABLE Mass_Price_Distributors
		</cfquery>
	</cffunction>

	<!--- set updateType --->
	<cffunction name="setUpdateType" access="public" returntype="void">
		<cfargument name="user_id" type="string" required="true">
		<cfargument name="update_type" type="string" required="true">

		<cfquery name="qDelUpdateType" datasource="#application.datasource#" >
			UPDATE 	Mass_Price_Schedule
			SET 	Deleted = 1,
					Scheduled = 0
			WHERE	User_ID = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">
			AND		Deleted = 0
		</cfquery>

		<cfquery name="qSetUpdateType" datasource="#application.datasource#" >
			INSERT INTO	Mass_Price_Schedule (User_ID, Update_Type)
			VALUES 	(
						<cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.update_type#" cfsqltype="cf_sql_varchar">
					)
		</cfquery>
	</cffunction>

	<!--- set schedule --->
	<cffunction name="setSchedule" access="public" returntype="void">
		<cfargument name="user_id" type="string" required="true">

		<cfset var qSetSchedule = "" />
		<cfquery name="qSetSchedule" datasource="#application.datasource#" >
			UPDATE	Mass_Price_Schedule
			SET		Scheduled = 1
			WHERE	User_ID = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">
			AND		Deleted = 0
			AND		Scheduled = 0
		</cfquery>
	</cffunction>

	<!--- mass update: last user who executed --->
	<cffunction name="lastMassUpdateUser" access="public" returntype="query">

		<cfset var qLastMassUpdateUser = "" />
		<cfquery name="qLastMassUpdateUser" datasource="#application.datasource#" >
			SELECT 		Top 1 MASS_PRICE_SCHEDULE.USER_ID,
						(NAME_FIRST + ' ' + NAME_LAST) AS USER_FULLNAME,
						MASS_PRICE_SCHEDULE.UPDATE_TYPE,
						MASS_PRICE_SCHEDULE.CREATED_DATE
			FROM		MASS_PRICE_SCHEDULE
			INNER JOIN	_USERS
			ON			_USERS.USER_ID =  MASS_PRICE_SCHEDULE.USER_ID
			WHERE		MASS_PRICE_SCHEDULE.DELETED = 1
			AND 		MASS_PRICE_SCHEDULE.SCHEDULED = 1
			ORDER BY	MASS_PRICE_SCHEDULE.CREATED_DATE DESC
		</cfquery>

		<cfreturn qLastMassUpdateUser />
	</cffunction>

	<!--- get the uom allowed for the mass price --->
	<cffunction name="massPriceUoms" access="public" returntype="query">
		<cfset var qMassPriceUoms = "" />
		<cfquery name="qMassPriceUoms" datasource="#application.datasource#" >
			SELECT	Unit_Of_Measure_ID,
					Abbreviation_Singular
			FROM	UNITS_OF_MEASURE
			WHERE	Unit_Of_Measure_ID IN (2,3)
		</cfquery>
		<cfreturn qMassPriceUoms />
	</cffunction>

	<!--- populate data for templates selected --->
	<cffunction name="insertTemplateData" access="public" returntype="void">
		<cfargument name="templateIds" type="string" default=""/>

		<cfquery name="qPopulateMPTemplates" datasource="#application.datasource#">
			INSERT INTO [Mass_Price_Templates]
			(
				[Programcontrol_Panel_Options_ID],
				[Created_Type],
				[Generic_Type],
				[Program_Description],
				[Childof],
				[First_Parent_ID],
				[Discount_Fixed_Prices],
				[Fixed_Type],
				[Isdominant],
				[Auto_Renew_Option]
			)
			SELECT DISTINCT PCP.Programcontrol_Panel_Options_ID,
				PCP.Created_Type,
				PCP.Generic_Type,
				PCP.Program_Description,
				PCP.Childof,
				PCP.First_Parent_ID,
				PCP.Discount_Fixed_Prices,
				PCP.Fixed_Type,
				PCP.Isdominant,
				PCP.Auto_Renew_Option
			FROM Program_Control_Panel_Options PCP_Latest
			INNER JOIN Program_Control_Panel_Options PCP
				ON PCP_Latest.First_Parent_ID = PCP.First_Parent_ID
			WHERE PCP_Latest.Discount_Fixed_Prices = 1
				AND PCP_Latest.Isdominant = 1
				AND PCP_Latest.Deleted = 0
				AND PCP.Deleted = 0
				AND PCP_Latest.Programcontrol_Panel_Options_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.templateIds#" list="true">)
			ORDER BY PCP.First_Parent_ID, PCP.Childof
		</cfquery>
	</cffunction>


	<cffunction name="checkValidProduct" access="public" returntype="numeric">
		<cfargument name="productId" type="string" default="" />

		<cfquery name="qCheckValidProduct" datasource="#application.datasource#">
			Select 	Count(Prod_Var_B) as counts
			From 	Prod_Var_B
					inner join BSA_Foodservice_Items_Master im on im.Prod_Var_B_ID = Prod_Var_B.Prod_Var_B_ID and im.Item = <cfqueryparam value="#arguments.productId#" cfsqltype="cf_sql_varchar">
			WHERE	Prod_Var_B.Deleted = 0
		</cfquery>

		<cfreturn qCheckValidProduct.counts />
	</cffunction>

	<cffunction name="insertProductData" access="public" returntype="void">
		<cfargument name="productId" type="string" default="" />
		<cfargument name="rate" type="string" default="0" />
		<cfargument name="uom" type="numeric" default="3" />
		<cfargument name="effectiveDate" type="string" default="" />

		<cfquery name="qGetInvalidData" datasource="#application.datasource#">
			Insert into Mass_Price_Products (Product, Rate_Change, Rate_UOM, Effective_Date)
			Values (
						<cfqueryparam value="#arguments.productId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.rate#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.uom#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.effectiveDate#" cfsqltype="cf_sql_date">
					)
		</cfquery>
	</cffunction>

	<cffunction name="insertDistributorData" access="public" returntype="void">

		<cfargument name="distributorIds" type="string" required="true" />

		<cfscript>
			//set local variables
			var indx			= "";
			var qAddDistData		= "";
			var lDistributors	= "";

			//assign local variables
			lDistributors = arguments.distributorIds;

		</cfscript>

		<cfloop index="indx" list="#lDistributors#">

			<cfquery name="qAddDistData" datasource="#application.datasource#">
				INSERT INTO Mass_Price_Distributors (BSA_Foodservice_Customers_ID)
				VALUES (
							<cfqueryparam value="#indx#" cfsqltype="cf_sql_varchar">
						)
			</cfquery>

		</cfloop>

	</cffunction>

	<cffunction name="insertProgramData" access="public" returntype="void">

		<cfargument name="programIds" type="string" required="true" />

		<cfscript>
			//set local variables
			var indx		= "";
			var qAddPrgData	= "";
			var lPrograms	= "";

			//assign local variables
			lPrograms = arguments.programIds;

		</cfscript>

		<cfloop index="indx" list="#lPrograms#">

			<cfquery name="qAddPrgData" datasource="#application.datasource#">
				INSERT INTO Mass_Price_Programs (Contract_Main_ID)
				VALUES (<cfqueryparam value="#indx#" cfsqltype="CF_SQL_INTEGER">)
			</cfquery>

		</cfloop>

	</cffunction>

	<!--- Check Data exists --->
	<cffunction name="getDataExists" access="remote" returntype="boolean">
		<cfset var qGetData = "" />
		<cfset var returnVar = 0 />

		<cfquery name="qGetProductData" datasource="#application.datasource#">
			SELECT COUNT(*) AS counts FROM Mass_Price_Products
		</cfquery>

		<cfquery name="qGetTemplateData" datasource="#application.datasource#">
			SELECT COUNT(*) AS counts FROM Mass_Price_Templates
		</cfquery>

		<!--- if counts greater than 0 return true --->
		<cfif qGetProductData.counts AND qGetTemplateData.counts>
			<cfset returnVar = 1 />
		</cfif>

		<cfreturn returnVar/>
	</cffunction>

	<!--- *** cancel mass update *** --->
	<cffunction name="cancelMassUpdate" access="remote" returntype="boolean" returnformat="JSON">
			<cfset clearData() />
			<cfset clearSchedule() />
			<cfreturn true />
	</cffunction>

	<!--- *** execute mass update *** --->
	<cffunction name="executeMassUpdate" access="remote" returntype="numeric" returnformat="JSON">
		<cfargument name="user_id" type="string" required="true">

		<!--- set the schedule --->
		<cfset setSchedule(arguments.user_id) />

		<cfquery name="qGetEffectiveDate" datasource="#application.datasource#">
			Select top 1 Effective_Date from Mass_Price_Products
		</cfquery>

		<!--- populate mass price programs --->
		<cfset populateMPPrograms(qGetEffectiveDate.Effective_Date) />

		<!--- get the program counts --->
		<cfset qCheckAllRevised = getProgramCounts() />

		<!--- schedule task to revise the programs, count > 0 --->
		<cfif qCheckAllRevised.Total>
			<cfset renewMPPrograms() />
		<cfelse>
			<cfset clearData() />
			<cfset clearSchedule() />
		</cfif>

		<!--- send the total programs count --->
		<cfreturn qCheckAllRevised.Total />
	</cffunction>

	<cffunction name="getProgramCounts" access="remote" returntype="query">
		<cfquery name="qGetProgramCounts" datasource="#application.datasource#">
			SELECT 	ISNULL(Sum(CASE WHEN Completed = 1 THEN 1 END), 0) AS Complete,
					ISNULL(Sum(CASE WHEN Completed = 0 THEN 1 END), 0) AS Pending,
					ISNULL(Sum(1), 0) AS Total
			FROM 	Mass_price_program_list with (nolock)
			WHERE 	Killed = 0 AND Skip = 0
		</cfquery>

		<!--- if the counts are zero or complete eq Total --->
		<!--- Kal: Uncomment when programs are zero and utility is still locked.
		<cfif qGetProgramCounts.Complete eq qGetProgramCounts.Total>
			<cfset clearData() />
			<cfset clearSchedule() />
		</cfif>
		--->
		<cfreturn qGetProgramCounts />
	</cffunction>

	<!--- get the uom allowed for the mass price --->
	<cffunction name="lockMassPrograms" access="public" returntype="void">
		<cfquery name="qLockMassPrograms" datasource="#application.datasource#">
			Update 	Contract_Main
			Set 	Contract_Is_Locked = 1,
					Contract_Lock_Date = getdate(),
					Contract_Locked_By_User_ID = '00000000-0000-0000-0000000000000001'
			FROM 	Contract_Main CM
			INNER JOIN Mass_Price_Program_List MPP on MPP.Contract_Main_ID = CM.Contract_Main_ID
			AND 	MPP.Killed = 0 AND MPP.Skip = 0 AND MPP.Completed = 0
		</cfquery>
	</cffunction>

	<!--- get the uom allowed for the mass price --->
	<cffunction name="unlockMassPrograms" access="public" returntype="void">
		<cfquery name="qUnlockMassPrograms" datasource="#application.datasource#">
			Update 	Contract_Main
			Set		Contract_Is_Locked = 0,
					Contract_Lock_Date = null,
					Contract_Locked_By_User_ID = null
			FROM 	Contract_Main CM
			INNER JOIN Mass_Price_Program_List MPP on MPP.Contract_Main_ID = CM.Contract_Main_ID
			AND 	MPP.Killed = 0 AND MPP.Skip = 0
		</cfquery>
	</cffunction>

	<!--- call the sp to populate the programs and pass the effective date --->
	<cffunction name="populateMPPrograms" access="public" returntype="void">
		<cfargument name="effDate" type="string" required="true" />

		<cfstoredproc procedure="USP_Mass_Price_Change" datasource="#application.datasource#">
			<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#arguments.effDate#" />
		</cfstoredproc>
	</cffunction>


	<!--- revise, update price & approve programs --->
	<cffunction name="renewMPPrograms" access="public" returntype="void">

		<cfset temp            = lockMassPrograms() />
		<cfset pgmCounts       = getProgramCounts() />
		<cfset local.runs      = ceiling(pgmCounts.Total/25) />			<!--- number of runs --->
		<cfset local.interval  = 5 />									<!--- minutes between runs --->
		<cfset local.duration  = (local.runs * (local.interval+1))  />	<!--- duration of process to set end time --->

		<cfset local.startDate = dateFormat(now(), "short") />
		<cfset local.startTime = timeFormat(now(), "short") />
		<cfset local.endDate   = dateFormat(dateAdd("n", local.duration, now()), "short") />
		<cfset local.endTime   = timeFormat(dateAdd("n", local.duration, now()), "short") />

		<cfschedule action = "update"
			task           = "#application.returned_customer_setting.Company_Name# - Mass_Price_Change_via_App"
			operation      = "HTTPRequest"
			url            = "http://#HTTP_HOST#/Scheduled/Mass_Price_Change_Via_App.cfm"
			startDate      = "#local.startDate#"
			startTime      = "#local.startTime#"
			endDate        = "#local.endDate#"
			endTime        = "#local.endTime#"
			interval       = "#(local.interval * 60)#"
			resolveURL     = "Yes"
			publish        = "Yes"
			path           = "#expandPath('/Scheduled/')#"
			file           = "Mass_Price_Change_via_App.log"
			requestTimeOut = "600">

	</cffunction>

	<!--- Insert into the log files for reporting --->
	<cffunction name="InsertHistoryLog" access="public" returntype="void">

		<cfquery name="qInsertHistoryLog" datasource="#application.Datasource#">
			INSERT 	INTO Mass_Price_Products_Log
					(Product, Rate_Change, Rate_Uom, Effective_Date)
			SELECT 	Product, Rate_Change, Rate_Uom, Effective_Date
			FROM 	Mass_Price_Products


			INSERT 	INTO Mass_Price_Templates_Log
				(
					Programcontrol_Panel_Options_ID, Created_Type, Generic_Type, Program_Description, Childof, First_Parent_ID,
					Discount_Fixed_Prices, Fixed_Type, Isdominant, Auto_Renew_Option
				)
			SELECT	Programcontrol_Panel_Options_ID, Created_Type, Generic_Type, Program_Description, Childof, First_Parent_ID,
					Discount_Fixed_Prices, Fixed_Type, Isdominant, Auto_Renew_Option
			FROM    Mass_Price_Templates


			INSERT INTO Mass_Price_Program_List_Log
				(
					Programtype_ID, Created_Type, Contract_Main_ID, Contract_Number, Version, Program_Number, Contract_Title, Contract_Start_Date, Contract_End_Date,
					Contract_Status_ID, Contract_Status, Is_A_Revision, Revision_Of_Contract_Main_ID, Responsible_User_ID, RSP, CUP_ID, RSP_Position_Name,
					New_Contract_Main_ID, New_Contract_Status_ID, New_Contract_Status, New_Version, Mod_Start_Date, Mod_End_Date, New_Start_Date, New_End_Date,
					Copied_Program_Number, Copied_Program_ID, Copied_Contract_Status_ID, Copied_Contract_Status,
					Killed, Skip, Cancelled, Skip_Revision, Skip_Copy, Revised, Copied, Completed
				)
			SELECT	Programtype_ID, Created_Type, Contract_Main_ID, Contract_Number, Version, Program_Number, Contract_Title, Contract_Start_Date, Contract_End_Date,
					Contract_Status_ID, Contract_Status, Is_A_Revision, Revision_Of_Contract_Main_ID, Responsible_User_ID, RSP, CUP_ID, RSP_Position_Name,
					New_Contract_Main_ID, New_Contract_Status_ID, New_Contract_Status, New_Version, Mod_Start_Date, Mod_End_Date, New_Start_Date, New_End_Date,
					Copied_Program_Number, Copied_Program_ID, Copied_Contract_Status_ID, Copied_Contract_Status,
					Killed, Skip, Cancelled, Skip_Revision, Skip_Copy, Revised, Copied, Completed
			FROM 	Mass_Price_Program_List


			INSERT INTO Mass_Price_Program_Products_Log
				(
					Programtype_ID, Created_Type, Contract_Main_ID, Contract_Number, Version, Program_Number, Contract_Title, Contract_Start_Date, Contract_End_Date,
					Contract_Status_ID, Contract_Status, Is_A_Revision, Revision_Of_Contract_Main_ID, Approved, Broker_Approved, Responsible_User_ID, RSP, CUP_ID, RSP_Position_Name,
					Item, Description, BSA_Foodservice_Items_Master_ID, Old_Price, Old_Price_UOM, Net_Weight, Rate_Change, Rate_UOM, New_Price, New_Price_UOM, Change_Completed
				)
			SELECT	Programtype_ID, Created_Type, Contract_Main_ID, Contract_Number, Version, Program_Number, Contract_Title, Contract_Start_Date, Contract_End_Date,
					Contract_Status_ID, Contract_Status, Is_A_Revision, Revision_Of_Contract_Main_ID, Approved, Broker_Approved, Responsible_User_ID, RSP, CUP_ID, RSP_Position_Name,
					Item, Description, BSA_Foodservice_Items_Master_ID, Old_Price, Old_Price_UOM, Net_Weight, Rate_Change, Rate_UOM, New_Price, New_Price_UOM, Change_Completed
			FROM	Mass_Price_Program_Products
		</cfquery>

		<cfquery name="qUpdateHistoryLogIds" datasource="#application.Datasource#">
			Declare @maxId int

			Select 	@maxId = ISNULL(max(Mass_Price_Products_ID),0) from Mass_Price_Products_Log
			UPDATE	Mass_Price_Products_Log
			SET		Mass_Price_Products_ID = @maxId+1
			WHERE	Mass_Price_Products_ID IS NULL

			Select 	@maxId = ISNULL(max(Mass_Price_Templates_ID),0) from Mass_Price_Templates_Log
			UPDATE	Mass_Price_Templates_Log
			SET		Mass_Price_Templates_ID = @maxId+1
			WHERE	Mass_Price_Templates_ID IS NULL

			Select 	@maxId = ISNULL(max(Mass_Price_Program_List_ID),0) from Mass_Price_Program_List_Log
			UPDATE	Mass_Price_Program_List_Log
			SET		Mass_Price_Program_List_ID = @maxId+1
			WHERE	Mass_Price_Program_List_ID IS NULL

			Select 	@maxId = ISNULL(max(Mass_Price_Program_Products_ID),0) from Mass_Price_Program_Products_Log
			UPDATE	Mass_Price_Program_Products_Log
			SET		Mass_Price_Program_Products_ID = @maxId+1
			WHERE	Mass_Price_Program_Products_ID IS NULL
		</cfquery>
	</cffunction>

	<!--- program report --->
	<cffunction name="getProgramReport" access="public" returntype="query">
		<cfquery name="qGetProgramReport" datasource="#application.datasource#">
			Select 		CONTRACT_NUMBER, PROGRAM_NUMBER, CONTRACT_TITLE,
						CONTRACT_START_DATE, CONTRACT_END_DATE, MOD_END_DATE, NEW_START_DATE, NEW_END_DATE,
						CONTRACT_STATUS, NEW_CONTRACT_STATUS, NEW_VERSION, KILLED, SKIP, COMPLETED
			From		Mass_Price_Program_List
			Order By 	CONTRACT_NUMBER, PROGRAM_NUMBER, CONTRACT_START_DATE, CONTRACT_END_DATE
		</cfquery>
		<cfreturn qGetProgramReport />
	</cffunction>

	<!--- program product report --->
	<cffunction name="getProgramProductReport" access="public" returntype="query">
		<cfquery name="qGetProgramProductReport" datasource="#application.datasource#">
			Select		CREATED_TYPE, CONTRACT_MAIN_ID, PROGRAM_NUMBER, CONTRACT_TITLE,
						CONTRACT_START_DATE, CONTRACT_END_DATE, CONTRACT_STATUS,
						ITEM, DESCRIPTION, BSA_FOODSERVICE_ITEMS_MASTER_ID, OLD_PRICE, OLD_PRICE_UOM,
						RATE_CHANGE, RATE_UOM, NEW_PRICE, NEW_PRICE_UOM, CHANGE_COMPLETED
			From		Mass_Price_Program_Products
			Order By 	PROGRAM_NUMBER, CONTRACT_MAIN_ID, CONTRACT_START_DATE, CONTRACT_END_DATE, ITEM
		</cfquery>
		<cfreturn qGetProgramProductReport />
	</cffunction>

</cfcomponent>
