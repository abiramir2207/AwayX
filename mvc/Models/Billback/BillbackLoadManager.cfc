
<cfcomponent name="BillbackLoadManager" displayname="BillbackLoadManager" hint="Billback Load" extends="mvc.Models.SettingsService">
	<cfset appSettings = application.appSettingsGet />
	<cfscript>
		variables.bbManager	= CreateObject("component", "mvc.Models.Billback.BillbackManager");
		variables.oSettlement	= CreateObject("component","mvc.Models.Billback.vos.BBSettlement").init();
	</cfscript>


	<cffunction name="getBillbackLookupData" access="remote" returntype="Struct">
	  <cfargument name="userId" type="string" required="true" default="00000000-9999-9999-0000000000000000">

	  <cfset var arrgetStatusTypes = ArrayNew(1)>
	  <cfset var arrgetClosingMethods = ArrayNew(1)>
	  <cfset var arrgetBBTypes = ArrayNew(1)>
	  <cfset var arrgetAnalysts = ArrayNew(1)>
	  <cfset var arrgetUsers = ArrayNew(1)>

	  <cfset var arrgetBBAmountTypes = ArrayNew(1)>
	  <cfset var arrgetBBDateTypes = ArrayNew(1)>
	  <cfset var arrgetHistoryTypes = ArrayNew(1)>
	  <cfset var arrgetCriteriaTypes = ArrayNew(1)>
	  <cfset var arrgetEntityTypes = ArrayNew(1)>
	  <cfset var arrgetActionTypes = ArrayNew(1)>
	  <cfset var arrgetConditionTypes = ArrayNew(1)>
	  <cfset var arrgetDistinctYears = ArrayNew(1)>


	  <cfscript>
		//get Status Array
		arrgetStatusTypes = getAllStauses(arguments.userId);

		//get Closing Method Array
		arrgetClosingMethods = getAllClosingMethods(UseselectedRecords = 0,selectedRecords="",includeBEnabled=1,includeProfile=0);

		//get BB Type Array
		arrgetBBTypes = getAllBBUploadedTypeLabels();

		//get Analyst Array
		arrgetAnalysts = getAnalysts();

		//get User array
		arrgetUsers = getUsers(BBUsersViewCreateOnly=1);

		//get BB Amount Types Array
		arrgetBBAmountTypes = getBBAmountTypes();

		//get BB Date Types Array
		arrgetBBDateTypes = getBBDateTypes();

		//get History Types Array
		arrgetHistoryTypes = getHistoryTypes();

		//get Criteria Types Array
		arrgetCriteriaTypes = getCriteriaTypes();

		//get Entity Types Array
		arrgetEntityTypes = getEntityTypes();

		//get Action Types Array
		arrgetActionTypes = getActionTypes();

		//get Condition Types Array
		arrgetConditionTypes = getConditionTypes();

		//get Distinct Years Array
		arrgetDistinctYears = getDistinctYears();


		/* Assign the objects */
		stData = structNew();
		stData["__type__"] = "mvc.Models.Billback.vos.BBFilterDef";
		stData["statusList"] = arrgetStatusTypes;
		stData["closingMethodList"] = arrgetClosingMethods;
		stData["analystList"] = arrgetAnalysts;
		stData["userList"] = arrgetUsers;
		stData["typeList"] = arrgetBBTypes;
		stData["dateTypeList"] = arrgetBBDateTypes;
		stData["amountTypeList"] = arrgetBBAmountTypes;
		stData["entityTypeList"] = arrgetEntityTypes;
		stData["historyTypeList"] = arrgetHistoryTypes;
		stData["criteriaList"] = arrgetCriteriaTypes;
		stData["actionList"] = arrgetActionTypes;
		stData["conditionList"] = arrgetConditionTypes;
		stData["loadByYearList"] = arrgetDistinctYears;
	  </cfscript>
		<cfreturn stData>
	</cffunction>

	<!--- <cffunction name="getBillbackHeader" access="remote" returntype="Array"> --->
	<cffunction name="getBillbackHeader" access="remote" returntype="any">
		<cfargument name="BBFilterParams" required="false" default="">
		<cfargument name="userid" type="string" required="true" default="00000000-9999-9999-0000000000000000"/>
		<cfargument name="billbackIdIntList" type="string" required="false" default="" />

		<cfscript>
			// new argument key for search bb 2020
			param arguments.BBFilterParams.called_from = "";

			local.arrSearchData = arrayNew(1);
			local.profiles_id   = getUserProfile(arguments.userid);

			// Deduct time difference between UTC and EST from the localtimezone passed to flex. This will give us the difference between localtimezone and EST (in minutes)
			local.DiffLocalTimeZoneAndEST = this.DiffLocalTimeZoneAndEST();

			local.function_to_call = "archive";
			local.called_from_2020 = arguments.BBFilterParams.called_from contains "2020";

			if (IsDefined("arguments.BBFilterParams.currentIncludingPaid")) {
				if (arguments.BBFilterParams.currentIncludingPaid eq 0)
					// when the data is loaded from the home page, Call "getBillbackHeaderData"
					local.function_to_call = "header";
			}
			// Note: arguments.BBFilterParams.will not exist when the data gets loaded from the home page
			else {
				// when the data is loaded from the home page, Call "getBillbackHeaderData" ("arguments.BBFilterParams" will be undefined at this stage)
				local.function_to_call = "header";
			}

			if ( local.function_to_call contains "archive" ) {
				local.qSearchData = getBillbackArchiveData(   arguments.BBFilterParams,
																arguments.userid,
																local.profiles_Id,
																local.DiffLocalTimeZoneAndEST,
																arguments.billbackIdIntList );
			}
			else {
				local.qSearchData = getBillbackHeaderData(    arguments.BBFilterParams,
																arguments.userid,
																local.profiles_Id,
																local.DiffLocalTimeZoneAndEST,
																arguments.billbackIdIntList );
			}

			// request.dumpToEmail_address = "kvangapalli@bigredflame.com";
			// application.util.io.dumpToEmail( arguments.BBFilterParams, local, application.util.query.reveal_sql(qSearchData, 'qSearchData in BillbackLoadManager.cfc') );

			// return query result w/o extra information when it is a 2020 format
			if ( local.called_from_2020 ) {
				return local.qSearchData;
			}
		</cfscript>



		<!--- <cfset application.util.query.reveal_sql(qSearchData, 'qSearchData in BillbackLoadManager.cfc')> --->

			<!--- If there are records, create a object of the records returned --->
			<cfif qSearchData.recordcount GT 0>
				<!---	When "NumberofRecords" field exists in the "qSearchData" query, then set Billback_ID_Int" to -1.
					This way we will know that the number of records is a lot and the user needs to refine search.
					Note: Did not use "qSearchData.billback_Id_Int = 0" (instead it was -1)  as that exists when we
					have 0 records returned from the query.
				--->
				<cfif IsDefined("qSearchData.NumberofRecords") AND INT(qSearchData.NumberofRecords)>
					<cfset qSearchData.billback_Id_Int = -1>
				</cfif>

			   <cfloop query="qSearchData">
				<!--- Assign the objects to the arrSearchData Array --->
				<cfset getCreateBillbackHeaderObject(qSearchData,1)>
				<cfset ArrayAppend(arrSearchData, duplicate(stData))>
			   </cfloop>

			<!--- If there are no records records, create an empty object --->
			<cfelse>
				<!--- Assign the objects to the arrSearchData Array --->
				<cfset getCreateBillbackHeaderObject(qSearchData,1)>
				<cfset ArrayAppend(arrSearchData, duplicate(stData))>
			</cfif>

	   <cfreturn arrSearchData />
	</cffunction>


	<!--- Any change to this function may require a corresponding change in the "getBillbackArchiveData" function and "Update_billback_search" stored procedure and
	mvc\models\billback\billbacksearchdetails.cfc and "getBBData" function in mvc\models\billback\billbackDAO.cfc
	--->
	<cffunction access="public" name="getBillbackHeaderData" output="false" returntype="query"> <!--- returntype="struct" --->
		<cfargument name="BBFilterParams" required="false">
		<cfargument name="userId" type="string" required="true" default="00000000-9999-9999-0000000000000000">
		<cfargument name="profiles_Id" type="string" required="true">
		<cfargument name="timeZoneDiff" type="numeric" required="true"/>
		<cfargument name="billbackIdIntList" type="string" required="false" default="" />
		<cfargument name="includeAllStatus" type="boolean" required="false" default="false"/>

		<cfscript>
			// request.dumpToEmail_address = "cnguyen@blacksmithapplications.com"; application.util.io.dumpToEmail( arguments );
		</cfscript>

		<!--- "UseHashTables" to make sure that the hash tables are used for billback permission query in "Billback_Access_Permission.cfm" --->
		<cfset var UseHashTables = 1>
		<cfset var qUserNumber = ''>
		<!--- App setting exists on "Billback_Access_Permission.cfm" --->
		<cfset var forbidType = appSettings.getForbidAllowProfilesInTemplates() />

		<!--- App setting BB Search Flex - only display parent billback in search results --->
		<cfset var bOnlyDisplayBillbackParent = appSettings.getDisplayOnlyBillbackParent() />

		<cfset var stSearch = StructNew()>

		<cfquery name="qDropTempTables" datasource="#application.datasource#">
		if object_id('tempdb..##tmp_billacks_cannot_see') is not null
		drop table ##tmp_billacks_cannot_see

		if object_id('tempdb..##Profile_Forbidden_Template') is not null
		drop table ##Profile_Forbidden_Template

		if object_id('tempdb..##tmp_billack_templates') is not null
		drop table ##tmp_billack_templates

		if object_id('tempdb..##Allow_Only_Billbacks') is not null
		drop table ##Allow_Only_Billbacks

		if object_id('tempdb..##Allow_Analysts') is not null
		drop table ##Allow_Analysts

		if object_id('tempdb..##Positions_Below_Me') is not null
		drop table ##Positions_Below_Me

		if object_id('tempdb..##Billback') is not null
		drop table ##Billback

		if object_id('tempdb..##Tmp_BB_Conditions') is not null
		drop table ##Tmp_BB_Conditions

		if object_id('tempdb..##tmp_Approved_bb') is not null
		drop table ##tmp_Approved_bb
	   </cfquery>

		<!--- We unlock all billbacks of the user during loading only. --->
		<CFINCLUDE TEMPLATE="/billbacks/scorecard/unlock_billbacks.cfm">

		<CFINCLUDE TEMPLATE="/billbacks/Billback_Access_Permission.cfm">
		<!---<cfinclude template="deduction_age.cfm">--->

		<cfif Not isDefined("request.AccessStructure")>
			<cfset request.AccessStructure = structNew() />
			<cfset request.AccessStructure.user_id = arguments.user_id />
			<cfset request.AccessStructure.profiles_id = arguments.profiles_id />
		</cfif>

		<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

		<cfset stSearch.Profiles_ID = arguments.profiles_id>
		<!---<cfset stSearch.User_ID = arguments.user_id>--->

		<cfif Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
			<cfset stSearch.programScorecardRestrictCreatedByUserId = request.AccessStructure.user_id>
		</cfif>

		<cfquery name="var_qBillbackSearchResults" datasource="#application.datasource#">
			set transaction isolation level read uncommitted

		DECLARE @ViewPrivateDocuments bit,
		@DatesToInt int,
		@DateWithTimeZoneDiff int,
		@useDayLightSavingsTime bit

		SET @DateWithTimeZoneDiff = #arguments.timeZoneDiff#
		<!--- Without using "INT", the value is 'YES' without single quotes, causing issues in the "SET" Statement. --->
		SET @useDayLightSavingsTime = #int(request.AccessStructure.useDayLightSavingsTime)#

			<cfif NOT UserIsAnalyst>
				#PreserveSingleQuotes(AllowBillbackIDs)#
			<cfelse>
				#PreserveSingleQuotes(AllowAnalystIds)#
			</cfif>

		if object_id('tempdb..##Profile_Forbidden_Template') is not null
		drop table ##Profile_Forbidden_Template

		Create  table ##Profile_Forbidden_Template
		(
		  template_id int not null
		)

		INSERT INTO  ##Profile_Forbidden_Template(Template_ID)
		<!------ forbit type=1, forbid, 0=allow ----->
		<cfif forbidType EQ 1>
		SELECT Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
		FROM Program_Control_Panel_Options
		LEFT JOIN Profile_Forbidden_Template
		ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Profile_Forbidden_Template.template_id
		AND Profile_Forbidden_Template.Forbid_Access_Type = 1
		AND Profile_Forbidden_Template.deleted = 0
		AND Profile_Forbidden_Template.Forbid_Type = #forbidType#
		AND Profile_Forbidden_Template.profile_id = #stSearch.Profiles_ID#
		<!--- Show me the templates, which are not in the "Profile_Forbidden_Template" table --->
		WHERE Profile_Forbidden_Template.template_id IS NULL

		<cfelse>

		SELECT Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
		FROM Program_Control_Panel_Options
		INNER JOIN Profile_Forbidden_Template
		ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Profile_Forbidden_Template.template_id
		WHERE Profile_Forbidden_Template.deleted = 0
		AND Profile_Forbidden_Template.Forbid_Access_Type = 1
		AND Profile_Forbidden_Template.Forbid_Type = #forbidType#
		AND Profile_Forbidden_Template.profile_id = #stSearch.Profiles_ID#
		</cfif>

		CREATE  CLUSTERED  INDEX [I_Profile_Forbidden_Template_tmp] ON [dbo].[##Profile_Forbidden_Template]([Template_ID])
		WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]

		SELECT    Billback.Billback_ID
		INTO ##tmp_billacks_cannot_see
		FROM Billback
		INNER JOIN Billback_Program
		ON    Billback.Billback_ID = Billback_Program.Billback_ID
		AND   Billback_Program.Deleted = 0
			INNER JOIN Contract_Main
		ON  Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
		WHERE Billback.Deleted = 0
		<cfif IsNumeric(appSettings.getBBCreatedRecentlyDays())>
		AND billback.Created_Date >= DateAdd(d,- #appSettings.getBBCreatedRecentlyDays()#,getDate()) <!--- Billbacks created in the last N days  --->
		</cfif>

		<cfif (isDefined("arguments.includeAllStatus") AND arguments.includeAllStatus EQ "false")>
			<!--- Exclude "Paid" and "Approved Void" statuses --->
			AND Billback.Billback_Status_ID NOT IN (5,8)
		</cfif>

		AND  ProgramType_ID NOT IN
		(
		  SELECT Template_ID
		  FROM ##Profile_Forbidden_Template
		)


		SELECT @ViewPrivateDocuments = View_Private_Documents
		FROM Profiles_Settings
		WHERE Profiles_ID = #Request.AccessStructure.Profiles_ID#

		<!--- Add "document_attached" information (yes/no) in the ##Tmp_BB_Conditions temp table --->
		SELECT Billback.Billback_ID_Int,CASE
		 WHEN
			  LEN((
		  SELECT  CASE WHEN COUNT(Document_Details.Doc_ID) > 0 THEN 1 ELSE NULL END
		  FROM    Document_Details
		  INNER JOIN 	Contract_Attachments ON Document_Details.Doc_ID = Contract_Attachments.Doc_ID
		  WHERE  Contract_Attachments.Billback_ID = Billback.billback_id
		  AND Document_Details.Deleted = 0
			AND
			(
			<!--- Public_View = 0 means "public" --->
			Public_View = 0 OR (Public_View = 1  AND @ViewPrivateDocuments = 1) OR (Document_Details.Uploaded_By = '#Request.AccessStructure.User_ID#')
			)
		  )) > 0

		 THEN CAST(1 As bit)
		  ELSE
			  CAST(0 As bit)
		  END
		As Document_Attached
		INTO ##Tmp_BB_Conditions
		FROM Billback


		CREATE TABLE ##tmp_Approved_bb
		(
		  Billback_ID_Int int NOT NULL,
		  BB_Closing_Method varchar(25)
		)

		<!--- If only parent billbacks are displayed in the search result, then get the closing method of the child billbacks as a comma-delimited list
		as the closing method of the parent billback. The users should be able to search on the child billbacks as these are the actual closing method
		of the billback. --->
		<cfif bOnlyDisplayBillbackParent>
		INSERT INTO ##tmp_Approved_bb(Billback_ID_Int,BB_Closing_Method)

		SELECT parent.Billback_ID_Int,
				BB_Closing_Method = REPLACE(
			(
				  SELECT      child.BB_Closing_Method AS [data()]
				FROM  BILLBACK child
				  WHERE child.BB_Parent_ID = parent.Billback_ID
				  AND   child.Deleted = 0
				  AND child.Billback_Status_ID >= 3
				  /* When a billback has several closing methods (splits), one split can be in paid status
					 and the other may not be and so the status of the parent billback is important and not the split.
				  AND child.Billback_Status_ID NOT IN (5,8)
				  */
				FOR XML PATH ('')
			), ' ', ',')
		FROM  BILLBACK parent
		WHERE   parent.Deleted = 0
		AND   parent.BB_Parent_ID is null
		AND Billback_Status_ID >= 3
			<cfif (isDefined("arguments.includeAllStatus") AND arguments.includeAllStatus EQ "false")>
				AND Billback_Status_ID NOT IN (5,8)
			</cfif>
		</cfif>

		<cfparam name="arguments.BBFilterParams.called_from" default="">

		<!--- Populate payee in the header object and then let the user search by name and id on flex itself.--->
			SELECT DISTINCT
		Billback.Billback_ID,Billback.Billback_ID_Int,Billback.BB_Code,Billback.BB_Reference,Billback.referenceNum,SubString(Billback.BB_Code,charIndex('-',Billback.BB_Code)+1,len(Billback.BB_Code))
		As Searchable_BB_Code,Billback.BB_Title,Billback.BB_Amount,
		Billback.Uploaded_Billback,
		BB_Approved.Approved_Amount,

		<!---  Use DateAdd to add or subtract time for the specific timezone of the user.Get the new date based on Time Zone.
		   For eg: If a person logs in to the flex application from CST time zone, then the date would be one hour more than the value in the db.
		--->
	   <!--- BB_Request_Approval_Date and Approved_date and Created_Date do not have timeformat of 0:00:00. Here it is being converted to that format --->
		dbo.get_TimeZoneOffset_Date(billback.BB_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As BB_Date,
		<cfif arguments.BBFilterParams.called_from contains "2020">
			/* convert to yyyymmdd format to simplify filtering logic on client browser */
			CONVERT(VARCHAR(10), billback.BB_Start_Date, 112) As BB_Start_Date,
			CONVERT(VARCHAR(10), billback.BB_End_Date,  112) As BB_End_Date,
			CONVERT(VARCHAR(10), billback.Created_Date, 112) As Created_Date,
			CASE WHEN billback.Billback_Status_ID = 1 THEN CONVERT(VARCHAR(10), '', 112) ELSE CONVERT(VARCHAR(10), billback.BB_Request_Approval_Date, 112) END As BB_Request_Approval_Date,
			CONVERT(VARCHAR(10), BB_Approved.Date_Approved, 112) As Date_Approved,
			CONVERT(VARCHAR(10), billback.Paid_Date, 112) As Paid_Date,
			CONVERT(VARCHAR(10), billback.BB_Received_Date, 112) AS BB_Received_Date,
		<cfelse>
			dbo.get_TimeZoneOffset_Date(billback.BB_Start_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As BB_Start_Date,
			dbo.get_TimeZoneOffset_Date(billback.BB_End_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As BB_End_Date,
			dbo.get_TimeZoneOffset_Date(billback.Created_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As Created_Date,
			dbo.get_TimeZoneOffset_Date(billback.BB_Request_Approval_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As BB_Request_Approval_Date,
			dbo.get_TimeZoneOffset_Date(BB_Approved.Date_Approved,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As Date_Approved,
			dbo.get_TimeZoneOffset_Date(billback.Paid_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As Paid_Date,
			dbo.get_TimeZoneOffset_Date(billback.BB_Received_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As BB_Received_Date,
		</cfif>

		BB_Approved.Check_Number,
		##Tmp_BB_Conditions.Document_Attached,
		billback.Billback_Status_ID,Billback_Status.BB_Status_Description,Billback_Status.BB_Status_Abbreviation,

		Billback.BB_Closing_Method As Billback_Closing_Method_ID,

		CASE
		WHEN LEN(##tmp_Approved_bb.billback_ID_Int) > 0 AND #bOnlyDisplayBillbackParent# = 1
			THEN  ##tmp_Approved_bb.BB_Closing_Method
		ELSE
			''
		END
		As Billback_Closing_Method_ID_List,

	   CASE
		WHEN LEN(##tmp_Approved_bb.billback_ID_Int) > 0 AND #bOnlyDisplayBillbackParent# = 1
			THEN 'MULTI'
		ELSE
			Billback_Closing_Methods.vchBillback_Closing_Method_Desc
		END
		As Billback_Closing_Method_Desc,

		CASE
		WHEN LEN(##tmp_Approved_bb.billback_ID_Int) > 0 AND #bOnlyDisplayBillbackParent# = 1
			THEN 'MULTI'
		ELSE
			Billback_Closing_Methods.abbreviation
		END
		As Billback_Closing_Method_Abbreviation,
		<!--- The order of the case statement is important. --->
		CASE
		WHEN Auto_Billback  = 1
			THEN 4
		WHEN Auto_Approved = 1
			THEN 5
		WHEN Uploaded_Billback = 0
			THEN 1
		WHEN Uploaded_Billback = 2
			THEN 2
		WHEN Uploaded_Billback = 3
			THEN 3
		END
		 As BB_Type_ID,
		<!--- The order of the case statement is important. --->
		CASE
		WHEN Auto_Billback = 1
			THEN 'Auto Pay'
		WHEN Auto_Approved = 1
			THEN 'Auto Approved'
		WHEN Uploaded_Billback = 0
			THEN 'Manual'
		WHEN Uploaded_Billback = 2
			THEN 'Upload'
			<!---THEN 'User'--->
		WHEN Uploaded_Billback = 3
			THEN '3rd Party'
			<!---THEN 'Auto'--->
		END
		 As BB_Type_Description,

		Analyst_User.Sales_Person_ID As Analyst_User_Int,
		Analyst_User.User_ID as Analyst_User_ID,
		Analyst_User.Name_First + ' ' + Analyst_User.Name_Last As Analyst_User,
		Creator_User.Sales_Person_ID As Creator_User_Int,
		Creator_User.Name_First + ' ' + Creator_User.Name_Last As Creator_User,
		Request_Approval_User.Sales_Person_ID As Request_Approval_User_Int,
		Request_Approval_User.Name_First + ' ' + Request_Approval_User.Name_Last As Request_Approval_User,
		Disagree_User.Sales_Person_ID As Disagree_User_Int,
		Disagree_User.Name_First + ' ' +Disagree_User.Name_Last As Disagree_User,
		Reset_User.Sales_Person_ID As Reset_User_Int,
		Reset_User.Name_First + ' ' + Reset_User.Name_Last As Reset_User,
		Approved_User.Sales_Person_ID As Approved_User_Int,
		Approved_User.Name_First + ' ' + Approved_User.Name_Last As Approved_User,
		Billback.Billback_Payee_Type_ID,
		CASE Billback.Billback_Payee_Type_ID
			WHEN 1 THEN  CASE WHEN Auto_Billback = 1 AND L.BillBack_Id IS NULL THEN '** Auto Pay **' ELSE ISNULL(BSA_Foodservice_Customers.Name,Cust2.Name)  END
			WHEN 2 THEN BSA_Operator.Operator_Name
			WHEN 3 THEN BSA_Foodservice_Brokers.Broker_Name
		END As Payee,

	   CASE Billback.Billback_Payee_Type_ID
				WHEN  1
		THEN   ISNULL(BSA_Foodservice_Customers.Shr_Ship_To,Cust2.Shr_Ship_To)

			WHEN 2
		THEN BSA_Operator.Legacy_ID

			WHEN 3
		THEN BSA_Foodservice_Brokers.Broker_Legcy_Shard

		END
		As Payee_ID,
		ISNULL(VM.Vendor_Name,VM2.Vendor_Name) As vendorPayee,
		ISNULL(VM.Vendor_ID,VM2.Vendor_ID) As vendorPayeeId,

		CASE
		 WHEN
			<!--- Note: There is no need to look for lock on billbacks.
			That is checked when the user takes action to reset a billback. --->
			(
			<!--- RFA and Approved --->
			billback.Billback_Status_ID IN (2,3)
			OR
				(
				<!--- Payment Request  --->
				billback.Billback_Status_ID IN (4)
						AND
						(
							(
							<!--- To allow reset, getBBAllowResetBeforePMTInterfacePRStatus is 1 and interface has not been sent --->
							(#appSettings.getBBAllowResetBeforePMTInterfacePRStatus()# = 1 AND billback.BB_Payment_Request_Sent = 0)
							AND
							<!--- To allow reset, billback.DD_Closure_Sent_On should be blank when getBBAllowResetAfterDEDInterface is 0.
							When getBBAllowResetAfterDEDInterface is 1, it is allowed --->
							(#appSettings.getBBAllowResetAfterDEDInterface()# = 1 OR billback.DD_Closure_Sent_On IS NULL)
							)
						OR
							(
							<!--- This condition has been initially added for GM. It can be used by other clients too --->
							(#appSettings.getBBAllowResetBeforePMTInterfacePRStatus()# = 1 AND billback.BB_Reversed = 0)
							AND
							(billback.BB_Payment_Request_Sent = 1 OR billback.DD_Closure_Sent_On IS NOT NULL)
							AND
							(billback.BB_Received_Ack_Type = 0)
							)
						)
				)
			)
			AND #Get_Profile_Settings.BB_Create# = 1
			<!--- When we display only parent billbacks on the bb search screen, reset is only allowed for parent billbacks and not for child billbacks (splits) --->
			<cfif bOnlyDisplayBillbackParent>
			AND Billback.BB_Parent_ID IS NULL
			<cfelse>
			<!--- When we display parent billbacks and child billbacks on the bb search screen, reset is only allowed for child billbacks (split) and not for the parent billback Or billbacks with no children --->
			AND NOT EXISTS (
					SELECT BChild.Billback_ID
					FROM Billback BChild
					WHERE BChild.Deleted = 0
						AND BChild.BB_Parent_ID = Billback.Billback_ID
					)
			</cfif>
			AND Billback.Auto_Billback = 0
			<!--- When we display only parent billbacks on the bb search screen, then the billback (parent of a split or a split of a parent or not a split bb), can be reset, even if it
			is associated to a deduction or one of its splits is associated to a deduction as the reset code unassociates the deduction.
			When we display all the billbacks (parent and split), then since we can only split the child (split) bb, the child bb cannot be reset if it is associated to a deduction. The user
			needs to manually unassociate the deduction. This is important as one deduction can be associated to multiple billbacks. --->
			<cfif bOnlyDisplayBillbackParent eq 0>
			AND Billback.BB_Associated_To_DD = 0
			</cfif>

		THEN 1
		ELSE 0
		END

		As ResetAllowed,

		CASE
		 WHEN	<!--- Note: There is no need to look for lock on billbacks..
			That is checked when the user takes action to delete a billback. --->
			(
			<!--- GM does not want to delete bb in approved status --->
			<!--- WIP,RFA,Pending Fund Update,Pending Vendor ID --->
			billback.Billback_Status_ID IN (1,2,6,7)
			OR
				(
					<!--- Payment Request --->
					billback.Billback_Status_ID IN (4)
					AND
					(
					billback.BB_Payment_Request_Sent = 0
					)
				)
				<!--- Approved - VOID  --->
				<!--- GM does not want to delete bb in approved void status --->
				<!---
				OR
				(
					billback.Billback_Status_ID IN (8)
					AND
					(
					(#appSettings.getBBAllowReverse()# = 0 OR billback.BB_Approved_Void_Ack_Type = 1)
					)
				)
				--->
			)
			AND billback.DD_Closure_Sent_On IS NULL
			<!--- When we display only parent billbacks on the bb search screen, delete is only allowed for parent billbacks and not for child billbacks (splits) --->
			<cfif bOnlyDisplayBillbackParent>
			AND Billback.BB_Parent_ID IS NULL
			<cfelse>
			<!--- When we display parent billbacks and child billbacks on the bb search screen, delete is only allowed for child billbacks (split) and not for the parent billback --->
			AND Billback.BB_Parent_ID IS NOT NULL
			</cfif>
			AND #Get_Profile_Settings.BB_Delete# = 1
		THEN 1
		ELSE 0
		END

		As DeleteAllowed,

		CASE
		 WHEN
		 (
			(
			(#appSettings.getBBReinterfaceUnacknowledgedInterface()# = 1 AND billback.BB_Reversed = 0)
			AND
			(billback.BB_Payment_Request_Sent = 1 OR billback.DD_Closure_Sent_On IS NOT NULL)
			AND
			(billback.BB_Received_Ack_Type = 0)
			)
		 OR
			(
			(#appSettings.getBBReinterfaceUnacknowledgedInterface()# = 1 AND billback.BB_Reversed = 1)
			AND
			(billback.Reversal_Sent = 1)
			AND
			(billback.BB_Received_Ack_Type = 0)
			)
		)
		THEN 1
		ELSE 0
		END

		As notAcknowledged,


		<!---CASE WHEN
		(
			('#Get_Profile_Settings.BB_Pay_Req_Approval_Amount#' = '*')
			OR
			(
			'#Get_Profile_Settings.BB_Pay_Req_Approval_Amount#' != '*'
			AND BB_Approved.Paid_Amount <= '#Get_Profile_Settings.BB_Pay_Req_Approval_Amount#'
			)
		)
		AND
			(ISNULL(Gl_Code_Allocation.Approved, 0) = 1
			 AND billback.BB_Payment_Request_Approved = 0
			 )
		THEN 1
		ELSE 0
		END
		As ReleaseAllowed
		--->

		0 As ReleaseAllowed,

		<!---CASE WHEN
			(ISNULL(Gl_Code_Allocation.Approved, 0) = 1
			 AND billback.BB_Payment_Request_Approved = 1
			 AND billback.BB_Payment_Request_Sent = 0
			 )
		THEN 1
		ELSE 0
		END
		As HoldAllowed
		--->

		0 As HoldAllowed,

		CASE
		 WHEN
			billback.Billback_Status_ID = 2
		 THEN 1
		 ELSE 0
		 END

		 As MassApproveAllowed,

		CASE WHEN
			billback.Billback_Status_ID = 2
			 OR
			(
			 billback.Billback_Status_ID = 3
			  AND
			 #appSettings.getUpdate_BB_Approve_Amt()# = 1
			)
			AND billback.DD_Closure_Sent_on IS NULL  AND billback.Auto_Billback = 0
		THEN 1
		ELSE 0
		END

		As deviationAllowed,
		billback.deviated As deviated,

		Billback.Payment_Notes AS Payment_Notes,
		Billback.Special_Handling AS Special_Handling,
		CASE
			WHEN	billback.Billback_Status_ID IN (1,2) THEN 1
			ELSE 0
		END AS ReassignAllowed,
		Billback.BB_Upload_Dup_Group_ID,
		Billback_Allied.BB_Is_Locked as Is_Locked,
		Billback_Allied.BB_Locked_By_User_ID as Locked_By,
		user_locked.Name_First, user_locked.Name_Last,
		CASE WHEN BB_Approved.Expected_Amount - BB_Approved.Approved_Amount != 0 THEN 1 ELSE 0 END as Discrepancy
		FROM billback

			INNER JOIN ##Tmp_BB_Conditions
			ON ##Tmp_BB_Conditions.Billback_ID_Int = Billback.Billback_ID_Int

			INNER JOIN Billback_Status
			ON Billback_Status.Billback_Status_ID = Billback.Billback_Status_ID

			INNER JOIN Billback_Closing_Methods
			ON Billback_Closing_Methods.iBillback_Closing_Method_ID = Billback.BB_Closing_Method

			LEFT JOIN _Users Analyst_User
			ON 	Analyst_User.User_ID = Billback.Analyst_User_ID

			LEFT JOIN _Users Creator_User
			ON 	Creator_User.User_ID = Billback.BB_Creator_ID

			LEFT JOIN _Users Request_Approval_User
			ON 	Request_Approval_User.User_ID = Billback.BB_Request_Approval_User_ID

			LEFT JOIN _Users Disagree_User
			ON 	Disagree_User.User_ID = Billback.BB_Disagree_By
			AND     Billback.BB_Disagree = 1

			LEFT JOIN _Users Reset_User
			ON 	Reset_User.User_ID = Billback.BB_Reset_User_ID

			LEFT JOIN BB_Approved
			ON BB_Approved.Billback_ID = Billback.Billback_ID

			LEFT JOIN _Users Approved_User
			ON Approved_User.User_ID = BB_Approved.User_Approved

			<!---
			Note: Need this for hold/release functionality. Do not use the join here. Instead create a temp table on top of the query whenever this
			functionalty needs to be added

			LEFT JOIN Gl_Code_Allocation
			ON Gl_Code_Allocation.Billback_ID = Billback.Billback_ID
			AND Gl_Code_Allocation.Deleted = 0
			--->

			LEFT JOIN Billback_Operator
			ON Billback_Operator.Billback_ID = Billback.Billback_ID
			AND Billback_Operator.Deleted = 0

			LEFT JOIN BSA_Operator
			ON BSA_Operator.BSA_Operator_ID = Billback_Operator.Operator_ID

			LEFT JOIN Billback_Distributor
			ON Billback_Distributor.Billback_ID = Billback.Billback_ID
			AND Billback_Distributor.deleted = 0

			LEFT JOIN Billback_Broker
			ON Billback_Broker.Billback_ID = Billback.Billback_ID
			AND Billback_Broker.deleted = 0

			LEFT JOIN BSA_Foodservice_Brokers
			ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Billback_Broker.Broker_ID

			LEFT JOIN Vendor_Master VM
			ON
			VM.vendor_Id= ISNULL(Billback_Operator.Uploaded_Vendor_ID, Billback_Distributor.Uploaded_Vendor_ID)

			LEFT JOIN Vendor_Master VM2 ON
				Billback_Distributor.Distributor_ID = VM2.Vendor_Master_Id

			/* --Use distributor if there is Only one */
			LEFT JOIN BillBack_Distributor_List L ON
			L.BillBack_Id = Billback.Billback_ID
			AND L.Deleted = 0
			AND (SELECT COUNT(L2.BillBack_Distributor_List_Id) FROM BillBack_Distributor_List L2 WHERE L2.BillBack_Id = Billback.Billback_ID  AND L2.Deleted = 0) <= 1

			LEFT JOIN BSA_Foodservice_Customers
			ON (L.BillBack_Id IS NULL AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID)
/* 				--OR
				-- (L.BillBack_Id IS NOT NULL AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = L.Distributor_ID)
 */			LEFT JOIN BSA_Foodservice_Customers Cust2
			ON (L.BillBack_Id IS NOT NULL AND L.BillBack_Id IS NOT NULL AND Cust2.BSA_Foodservice_Customers_ID = L.Distributor_ID)

			LEFT JOIN ##tmp_Approved_bb
			ON ##tmp_Approved_bb.Billback_ID_Int = Billback.Billback_ID_Int
			AND ##tmp_Approved_bb.BB_Closing_Method IS NOT NULL

			/** D100712 Excessive CPU spikes in CF server / Anand Rao / 28-Sep-2020  **/
			LEFT JOIN Billback_Allied ON Billback_Allied.Billback_ID = Billback.Billback_ID
			LEFT JOIN _Users user_locked ON user_locked.User_ID = Billback_Allied.BB_Locked_By_User_ID

		WHERE  billback.deleted = 0
		<cfif IsNumeric(appSettings.getBBCreatedRecentlyDays())>
		AND billback.Created_Date >= DateAdd(d,- #appSettings.getBBCreatedRecentlyDays()#,getDate()) <!--- Billbacks created in the last N days  --->
		</cfif>

		<cfif (isDefined("arguments.includeAllStatus") AND arguments.includeAllStatus EQ "false")>
			<!--- Exclude "Paid" and "Approved Void" statuses --->
			AND Billback.Billback_Status_ID NOT IN (5,8)
		</cfif>

			<cfif IsDefined("stSearch.programScorecardRestrictCreatedByUserId")>
			<!--- If the below profile settings is on, then the user should only be allowed to see programs
			that have him/her as an RSP OR where the program creator's RSP has the user number same as
			this user's User number
			--->
			AND NOT EXISTS
			(
		   <cfif appSettings.getUserNumberRestrict()>
				<cfset qUser = createObject("component", "components.user.UserManager").getUser(stSearch.programScorecardRestrictCreatedByUserId) />
				<cfset qUserNumber = qUser.User_Number />
			</cfif>
			SELECT Billback_ID
			FROM Billback_Program
			INNER JOIN Contract_Main
			ON Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
			LEFT JOIN _Users responsibleSalesPerson
			ON 	responsibleSalesPerson.User_ID = Contract_Main.Responsible_User_ID
			AND	responsibleSalesPerson.Deleted = 0
			WHERE Billback_Program.Billback_ID = Billback.Billback_ID
			AND Billback_Program.Deleted = 0
			AND(
			Isnull(rtrim(ltrim(Contract_Main.Responsible_User_ID)),'') != '#stSearch.programScorecardRestrictCreatedByUserId#'
			<cfif len(qUserNumber)>
				AND Isnull(rtrim(ltrim(responsibleSalesPerson.User_Number)),'') != '#qUserNumber#'
			</cfif>
			)
			)
			</cfif>

		AND NOT EXISTS
			(
		select Billback_ID
		FROM ##tmp_billacks_cannot_see
		WHERE ##tmp_billacks_cannot_see.Billback_ID = Billback.Billback_ID
		)

			<!---TSF - Label 16253: Add Billback filter logic if search by analyst is not on for this profile--->
			<cfif not Get_Profile_Settings.BB_Search_By_Analyst>
			<cfif HQUser NEQ 1 OR UserIsAnalyst> <!--- if user is an analyst or not HQ --->
	   <!--- The values of "UserPositionList" and "##Allow_Only_Billbacks" and "AnalystList" comes from "/billbacks/Billback_Access_Permission.cfm" --->
			AND (
				Billback.BB_Creator_ID = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
				<cfif UserIsAnalyst EQ 0>
					OR Billback.BB_Creator_User_Position_ID IN (#PreserveSingleQuotes(UserPositionList)#)
					<cfif listlen(BillbackIDs) GT 0>
						OR Billback.Billback_ID IN (SELECT Billback_ID FROM ##Allow_Only_Billbacks)
					</cfif>
				<cfelse><!------ If billback analyst do not look at the position tree, use the analyst logic alone ----->
					<cfif AnalystList NEQ "">
						OR	Billback.Analyst_User_ID IN (#PreserveSingleQuotes(AnalystList)#)
						OR	Billback.BB_Creator_ID IN (#PreserveSingleQuotes(AnalystList)#)
					</cfif>
				</cfif>
			)
			</cfif>

			</cfif>

		<cfif arguments.billbackIdIntList neq "">
		AND billback.billback_ID_Int IN  (SELECT * FROM dbo.udf_BreakStringIntoRows('#arguments.billbackIdIntList#'))
		</cfif>

		<cfif bOnlyDisplayBillbackParent>
		AND billback.BB_Is_Child = 0
		</cfif>

		<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
		<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~ 2020 filtering criteria ~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
		<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
		<cfif arguments.BBFilterParams.called_from contains "2020">
		</cfif>





		if object_id('tempdb..##tmp_billacks_cannot_see') is not null
		drop table ##tmp_billacks_cannot_see

		if object_id('tempdb..##Profile_Forbidden_Template') is not null
		drop table ##Profile_Forbidden_Template

		if object_id('tempdb..##tmp_billack_templates') is not null
		drop table ##tmp_billack_templates

		if object_id('tempdb..##Allow_Only_Billbacks') is not null
		drop table ##Allow_Only_Billbacks

		if object_id('tempdb..##Allow_Analysts') is not null
		drop table ##Allow_Analysts

		if object_id('tempdb..##Positions_Below_Me') is not null
		drop table ##Positions_Below_Me

		if object_id('tempdb..##Billback') is not null
		drop table ##Billback

		if object_id('tempdb..##Tmp_BB_Conditions') is not null
		drop table ##Tmp_BB_Conditions

		if object_id('tempdb..##tmp_Approved_bb') is not null
		drop table ##tmp_Approved_bb
		</cfquery>

		<!---<Cfdump var="#var_qBillbackSearchResults#" output="C:\var_qBillbackSearchResults.txt" />--->
		<cfreturn var_qBillbackSearchResults>

	</cffunction>

	<cffunction name="getCreateBillbackHeaderObject" access="public" returntype="Struct">
	  <cfargument name="qSearchData" type="query" required="true">
	  <cfargument name="bGetSettlementData" type="boolean" required="false" default="false">
		<!---default values for the address object --->
		<cfset var address1 = "" />
		<cfset var addressLine2 = "" />
		<cfset var city = "" />
		<cfset var state = "" />
		<cfset var zipCode = "" />

		<!---default values for the vendor object --->
		<cfset var vendorPayee = "" />
		<cfset var vendorPayeeId = "" />
		<cfset var vendorAddress1 = "" />
		<cfset var vendorAddressLine2 = "" />
		<cfset var vendorCity = "" />
		<cfset var vendorState = "" />
		<cfset var vendorZipCode = "" />

		<!---default values for the check --->
		<cfset var checkDate = "" />
		<cfset var checkAmount = 0 />
		<cfset var documentNumber1 = "">
		<cfset var documentNumber2 = "">

		<!---default values for bbsettlement --->
		<cfset var paymentNotes = "" />
		<cfset var specialHandling = 0 />

		<!---other--->
		<cfset var resetAllowed = 0>
		<cfset var deleteAllowed = 0>
		<cfset var releaseAllowed = 0>
		<cfset var holdAllowed = 0>
		<cfset var massApproveAllowed = 0>
		<cfset var deviationAllowed = 0>
		<cfset var userAgreed = 0>
		<cfset var reassignAllowed = 0>
		<cfset var closingMethodList = "">
		<cfset var notAcknowledged = 0>
		<cfset var payeeUUId = "">
		<cfset var bDisplaySettlement = 0>
		<cfset var UploadID = 0>

		<!---default values for the bill to object --->
		<cfset var billTo 			= "" />
		<cfset var billToId 		= "" />
		<cfset var billToName		= "" />
		<cfset var billToShipTo		= "" />
		<cfset var billToShipToId	= "" />
		<cfset var billToAddress1 	= "" />
		<cfset var billToAddress2 	= "" />
		<cfset var billToCity 		= "" />
		<cfset var billToState 		= "" />
		<cfset var billToZipCode	= "" />
		<cfset var defaultProgram	= "" />
		<cfset var BBUploadDupGroupID = 0 />


		<!--- set address values if passed from the query argument --->
		<cfif isDefined("arguments.qSearchData.address1")><cfset address1 = arguments.qSearchData.address1 /></cfif>
		<cfif isDefined("arguments.qSearchData.addressLine2")><cfset addressLine2 = arguments.qSearchData.addressLine2 /></cfif>
		<cfif isDefined("arguments.qSearchData.city")><cfset city = arguments.qSearchData.city /></cfif>
		<cfif isDefined("arguments.qSearchData.state")><cfset state = arguments.qSearchData.state /></cfif>
		<cfif isDefined("arguments.qSearchData.zipCode")><cfset zipCode = arguments.qSearchData.zipCode /></cfif>

		<!--- set vendor values if passed from the query argument --->
		<cfif isDefined("arguments.qSearchData.vendorPayee")><cfset vendorPayee  = arguments.qSearchData.vendorPayee /></cfif>
		<cfif isDefined("arguments.qSearchData.vendorPayeeId")><cfset vendorPayeeId = arguments.qSearchData.vendorPayeeId /></cfif>
		<cfif isDefined("arguments.qSearchData.vendorAddress1")><cfset vendorAddress1 = arguments.qSearchData.vendorAddress1 /></cfif>
		<cfif isDefined("arguments.qSearchData.vendorAddressLine2")><cfset vendorAddressLine2 = arguments.qSearchData.vendorAddressLine2 /></cfif>
		<cfif isDefined("arguments.qSearchData.vendorCity")><cfset vendorCity = arguments.qSearchData.vendorCity /></cfif>
		<cfif isDefined("arguments.qSearchData.vendorState")><cfset vendorState = arguments.qSearchData.vendorState /></cfif>
		<cfif isDefined("arguments.qSearchData.vendorZipCode")><cfset vendorZipCode = arguments.qSearchData.vendorZipCode /></cfif>

		<!--- set check values if passed from the query argument --->
		<cfif isDefined("arguments.qSearchData.Check_Date")><cfset checkDate = arguments.qSearchData.Check_Date /></cfif>
		<cfif isDefined("arguments.qSearchData.Check_Amount")><cfset checkAmount = arguments.qSearchData.Check_Amount /></cfif>
		<cfif isDefined("arguments.qSearchData.Document_Number_1")><cfset documentNumber1 = arguments.qSearchData.Document_Number_1 /></cfif>
		<cfif isDefined("arguments.qSearchData.Document_Number_2")><cfset documentNumber2 = arguments.qSearchData.Document_Number_2 /></cfif>

		<!--- set bbsettlement values if passed from the query argument --->
		<cfif isDefined("arguments.qSearchData.Payment_Notes")><cfset paymentNotes = arguments.qSearchData.Payment_Notes /></cfif>
		<cfif isDefined("arguments.qSearchData.Special_Handling")><cfset specialHandling = arguments.qSearchData.Special_Handling /></cfif>

		<!---other--->
		<cfif isDefined("arguments.qSearchData.ResetAllowed")><cfset resetAllowed = arguments.qSearchData.ResetAllowed /></cfif>
		<cfif isDefined("arguments.qSearchData.DeleteAllowed")><cfset deleteAllowed = arguments.qSearchData.DeleteAllowed /></cfif>
		<cfif isDefined("arguments.qSearchData.ReleaseAllowed")><cfset releaseAllowed = arguments.qSearchData.ReleaseAllowed /></cfif>
		<cfif isDefined("arguments.qSearchData.HoldAllowed")><cfset holdAllowed = arguments.qSearchData.HoldAllowed /></cfif>
		<cfif isDefined("arguments.qSearchData.MassApproveAllowed")><cfset massApproveAllowed = arguments.qSearchData.MassApproveAllowed /></cfif>
		<cfif isDefined("arguments.qSearchData.deviationAllowed")><cfset deviationAllowed = arguments.qSearchData.deviationAllowed /></cfif>
		<cfif isDefined("arguments.qSearchData.userAgreed")><cfset userAgreed = arguments.qSearchData.userAgreed /></cfif>
		<cfif isDefined("arguments.qSearchData.ReassignAllowed")><cfset reassignAllowed = arguments.qSearchData.ReassignAllowed /></cfif>
		<cfif isDefined("arguments.qSearchData.Billback_Closing_Method_ID_List")><cfset closingMethodList = arguments.qSearchData.Billback_Closing_Method_ID_List /></cfif>
		<cfif isDefined("arguments.qSearchData.notAcknowledged")><cfset notAcknowledged = arguments.qSearchData.notAcknowledged /></cfif>
		<cfif isDefined("arguments.qSearchData.payeeUUId")><cfset payeeUUId = arguments.qSearchData.payeeUUId /></cfif>
		<cfif isDefined("arguments.qSearchData.bDisplaySettlement")><cfset bDisplaySettlement = arguments.qSearchData.bDisplaySettlement /></cfif>


		<!--- set bill to values if passed from the query argument --->
		<cfif isDefined("arguments.qSearchData.billTo")><cfset billTo  = arguments.qSearchData.billTo /></cfif>
		<cfif isDefined("arguments.qSearchData.billToId")><cfset billToId = arguments.qSearchData.billToId /></cfif>
		<cfif isDefined("arguments.qSearchData.billToName")><cfset billToName = arguments.qSearchData.billToName /></cfif>
		<cfif isDefined("arguments.qSearchData.billToShipTo")><cfset billToShipTo = arguments.qSearchData.billToShipTo /></cfif>
		<cfif isDefined("arguments.qSearchData.billToShipToId")><cfset billToShipToId = arguments.qSearchData.billToShipToId /></cfif>
		<cfif isDefined("arguments.qSearchData.billToAddress1")><cfset billToAddress1 = arguments.qSearchData.billToAddress1 /></cfif>
		<cfif isDefined("arguments.qSearchData.billToAddress2")><cfset billToAddress2 = arguments.qSearchData.billToAddress2 /></cfif>
		<cfif isDefined("arguments.qSearchData.billToCity")><cfset billToCity = arguments.qSearchData.billToCity /></cfif>
		<cfif isDefined("arguments.qSearchData.billToState")><cfset billToState = arguments.qSearchData.billToState /></cfif>
		<cfif isDefined("arguments.qSearchData.billToZipCode")><cfset billToZipCode = arguments.qSearchData.billToZipCode /></cfif>

		<cfif isDefined("arguments.qSearchData.strDefaultProgram")><cfset defaultProgram = arguments.qSearchData.strDefaultProgram /></cfif>
		<cfif isDefined("arguments.qSearchData.Upload_ID")><cfset UploadID = arguments.qSearchData.Upload_ID /></cfif>
		<cfif isDefined("arguments.qSearchData.BB_Upload_Dup_Group_ID")><cfset BBUploadDupGroupID = arguments.qSearchData.BB_Upload_Dup_Group_ID /></cfif>
		<cfscript>
		/* Note: Do not add the "createObject" notation inside this function as this is called inside a loop and it causes memory issues.
		   Even using the "createObject" outside the loop and using the "duplicate" function inside will be very slow if used for all
		   the cfc's. Currently, the duplicate notation is only being used for "BBSettlement".
		*/
			//build Status Object
			stStatus = structNew();
			stData = structNew();
			stData["__type__"] = "mvc.Models.Billback.vos.Status";
			stData["id"] = val(arguments.qSearchData.Billback_Status_ID);
			/* If the billback has been "agreed to" by the logged in user. set "subStatus" of status to 3 - "Agreed".
			   Note: 1 is "Under Review" and 2 is "pending Approval".
			*/
			if(userAgreed neq 0){
				stData["subStatus"] = 3;
				stData["subStatusDescription"] = 'Agreed';
			}

			stData["description"] = arguments.qSearchData.BB_Status_Description;
			stData["abbreviation"] = arguments.qSearchData.BB_Status_Abbreviation;
			stStatus = stData;

			//build Closing Method Object
			stClosingMethod = structNew();
			stData = structNew();
			stData["__type__"] = "mvc.Models.Billback.vos.ClosingMethod";
			stData["id"] = val(arguments.qSearchData.Billback_Closing_Method_ID);
			stData["idList"] = closingMethodList;
			stData["description"] = arguments.qSearchData.Billback_Closing_Method_Desc;
			stData["abbreviation"] = arguments.qSearchData.Billback_Closing_Method_Abbreviation;
			stClosingMethod = stData;

			//build Type (Uploaded_Billback etc field in the db) Object
			stType = structNew();
			stData = structNew();
			stData["__type__"] = "mvc.Models.Billback.vos.Type";
			stData["id"] = val(arguments.qSearchData.BB_Type_ID);
			stData["description"] = arguments.qSearchData.BB_Type_Description;
			stType = stData;

			//build Analyst User Object
			stAnalystUser = structNew();
			stData = structNew();
			stData["__type__"] = "mvc.Models.Entity.vos.User";
			stData["id"] = arguments.qSearchData.Analyst_User_ID;
			stData["idInt"] = val(arguments.qSearchData.Analyst_User_Int);
			stData["fullName"] = arguments.qSearchData.Analyst_User;
			stAnalystUser = stData;

			//build Creator User Object
			stCreatorUser = structNew();
			stData = structNew();
			stData["__type__"] = "mvc.Models.Entity.vos.User";
			stData["id"] = "";
			stData["idInt"] = val(arguments.qSearchData.Creator_User_Int);
			stData["fullName"] = arguments.qSearchData.Creator_User;
			stCreatorUser = stData;

			//build Request Approval User Object
			stRequestApprovalUser = structNew();
			stData = structNew();
			stData["__type__"] = "mvc.Models.Entity.vos.User";
			stData["id"] = "";
			stData["idInt"] = val(arguments.qSearchData.Request_Approval_User_Int);
			stData["fullName"] = arguments.qSearchData.Request_Approval_User;
			stRequestApprovalUser = stData;

			//build Disagree User Object
			stDisagreeUser = structNew();
			stData = structNew();
			stData["__type__"] = "mvc.Models.Entity.vos.User";
			stData["id"] = "";
			stData["idInt"] = val(arguments.qSearchData.Disagree_User_Int);
			stData["fullName"] = arguments.qSearchData.Disagree_User;
			stDisagreeUser = stData;

			//build Reset User Object
			stResetUser = structNew();
			stData = structNew();
			stData["__type__"] = "mvc.Models.Entity.vos.User";
			stData["id"] = "";
			stData["idInt"] = val(arguments.qSearchData.Reset_User_Int);
			stData["fullName"] = arguments.qSearchData.Reset_User;
			stResetUser = stData;

			//build Approved User Object
			stApprovedUser = structNew();
			stData = structNew();
			stData["__type__"] = "mvc.Models.Entity.vos.User";
			stData["id"] = "";
			stData["idInt"] = val(arguments.qSearchData.Approved_User_Int);
			stData["fullName"] = arguments.qSearchData.Approved_User;
			stApprovedUser = stData;

			//build Address Object
			stAddress = structNew();
			stAddress["__type__"] = "mvc.Models.Entity.vos.Address";
			stAddress["addressLine1"] = trim(address1);
			stAddress["addressLine2"] = trim(addressLine2);
			stAddress["city"] = trim(city);
			stAddress["state"] = trim(state);
			stAddress["zipCode"] = trim(zipCode);

			//build Payee Object
			stPayee = structNew();
			stData = structNew();
			stData["__type__"] = "mvc.Models.Entity.vos.Payee";
			stData["payeeTypeId"] = val(arguments.qSearchData.Billback_Payee_Type_ID);
			stData["name"] = trim(arguments.qSearchData.Payee);
			stData["payeeId"] = trim(arguments.qSearchData.Payee_ID);
			stData["address"] = stAddress;
			stData["payeeUUId"] = trim(payeeUUId);
			stPayee = stData;

			//build Vendor Address Object
			stVendorAddress = structNew();
			stVendorAddress["__type__"] = "mvc.Models.Entity.vos.Address";
			stVendorAddress["addressLine1"] = trim(vendorAddress1);
			stVendorAddress["addressLine2"] = trim(vendorAddressLine2);
			stVendorAddress["city"] = trim(vendorCity);
			stVendorAddress["state"] = trim(vendorState);
			stVendorAddress["zipCode"] = trim(vendorZipCode);

			//build Vendor Payee Object
			stVendorPayee = structNew();
			stData = structNew();
			stData["__type__"] = "mvc.Models.Entity.vos.Payee";
			stData["payeeTypeId"] = val(arguments.qSearchData.Billback_Payee_Type_ID);
			stData["name"] = trim(vendorPayee);
			stData["payeeId"] = trim(vendorPayeeId);
			stData["address"] = stVendorAddress;
			stVendorPayee = stData;


			//build BillTo Address Object
			stBillToAddress = structNew();
			stBillToAddress["__type__"] = "mvc.Models.Entity.vos.Address";
			stBillToAddress["addressLine1"] = trim(billToAddress1);
			stBillToAddress["addressLine2"] = trim(billToAddress1);
			stBillToAddress["city"] = trim(billToCity);
			stBillToAddress["state"] = trim(billToState);
			stBillToAddress["zipCode"] = trim(billToZipCode);

			//build BillTo Object
			stBillTo = structNew();
			stData = structNew();
			stData["__type__"] 		= "mvc.Models.Entity.vos.BillTo";
			stData["billTo"] 		=  billTo;
			stData["name"] 			=  billToName;
			stData["billToId"] 		=  billToId;
			stData["shipTo"] 		=  billToShipTo;
			stData["shipToId"] 		=  billToShipToId;
			stData["address"] 		= stBillToAddress;
			stBillTo = stData;

			stData = structNew();
			stData["__type__"] = "mvc.Models.Billback.vos.BBHeader";
			stData["isSelected"] = "";
			stData["billbackIDInt"] = val(arguments.qSearchData.Billback_ID_Int);
			stData["billbackIDGUID"] = arguments.qSearchData.Billback_ID;
			stData["BBCode"] = arguments.qSearchData.BB_Code;
			stData["BBNumber"] = arguments.qSearchData.BB_Reference;
			stData["referenceNumber"] = arguments.qSearchData.referenceNum;
			stData["UploadedBillback"] = arguments.qSearchData.Uploaded_Billback;
			stData["searchableBBCode"] = arguments.qSearchData.Searchable_BB_Code;
			stData["title"] = arguments.qSearchData.BB_Title;
			stData["amount"] = val(arguments.qSearchData.BB_Amount);
			stData["approvedAmount"] = val(arguments.qSearchData.Approved_Amount);
			stData["createdDate"] = arguments.qSearchData.Created_Date;
			stData["requestApprovalDate"] = arguments.qSearchData.BB_Request_Approval_Date;
			stData["BBDate"] = arguments.qSearchData.BB_Date;
			stData["startDate"] = arguments.qSearchData.BB_Start_Date;
			stData["endDate"] = arguments.qSearchData.BB_End_Date;
			stData["approvedDate"] = arguments.qSearchData.Date_Approved;
			stData["paidDate"] = arguments.qSearchData.Paid_Date;
			stData["BBReceivedDate"] = arguments.qSearchData.BB_Received_Date;

			stData["documentAttached"] = arguments.qSearchData.Document_Attached;
			stData["checkNumber"] = arguments.qSearchData.Check_Number;
			stData["documentNumber1"] = documentNumber1;
			stData["documentNumber2"] = documentNumber2;
			stData["resetAllowed"] = resetAllowed;
			stData["deleteAllowed"] = deleteAllowed;
			stData["releaseAllowed"] = releaseAllowed;
			stData["holdAllowed"] = holdAllowed;
			stData["massApproveAllowed"] = massApproveAllowed;
			stData["deviationAllowed"] = deviationAllowed;
			stData["deviated"] = arguments.qSearchData.deviated;
			stData["reassignAllowed"] = reassignAllowed;
			stData["notAcknowledged"] = notAcknowledged;
			stData["bDisplaySettlement"] = bDisplaySettlement;
			stData["UploadID"] = UploadID;
			stData["BBUploadDupGroupID"] = BBUploadDupGroupID;

			stDataSettlement = duplicate(variables.oSettlement);
			stDataSettlement.bbSettlement.paymentNotes = paymentNotes;
			stDataSettlement.bbSettlement.bSpecialHandling = specialHandling;

			stData["status"] = stStatus;
			stData["closingMethod"] = stClosingMethod;
			stData["BBtype"] = stType;
			stData["analyst"] = stAnalystUser;
			stData["creator"] = stCreatorUser;
			stData["requestApproval"] = stRequestApprovalUser;
			stData["disagree"] = stDisagreeUser;
			stData["reset"] = stResetUser;
			stData["approved"] = stApprovedUser;
			stData["payee"] = stPayee;
			stData["vendor"] = stVendorPayee;
			stData["checkDate"] = checkDate;
			stData["checkAmount"] = checkAmount;

			stData["bbSettlement"] = stDataSettlement;
			stData["billTo"] = stBillTo;

			stData["strDefaultProgram"] = defaultProgram;


		</cfscript>

		<cfreturn stData />
	</cffunction>

	<!--- Any change to this function may require a corresponding change in the "getBillbackHeaderData" function and "Update_billback_search" stored procedure and
	mvc\models\billback\billbacksearchdetails.cfc  and "getBBData" function in mvc\models\billback\billbackDAO.cfc
	--->
	<cffunction name="getBillbackArchiveData" returntype="query" access="private"> <!--- returntype="struct" --->
		<cfargument name="BBFilterParams" required="false">
		<cfargument name="userId" type="string" required="true" default="00000000-9999-9999-0000000000000000">
		<cfargument name="profiles_Id" type="string" required="true">
		<cfargument name="timeZoneDiff" type="numeric" required="true"/>
		<cfargument name="billbackIdIntList" type="string" required="false" default="" />

		<!--- "UseHashTables" to make sure that the hash tables are used for billback permission query in "Billback_Access_Permission.cfm" --->
		<cfset var UseHashTables = 1>
		<cfset var qUserNumber = ''>
		<!--- App setting exists on "Billback_Access_Permission.cfm" --->
		<cfset var forbidType = appSettings.getForbidAllowProfilesInTemplates() />

		<!--- App setting BB Search Flex - only display parent billback in search results --->
		<cfset var bOnlyDisplayBillbackParent = appSettings.getDisplayOnlyBillbackParent() />

		<cfset var stSearch = StructNew()>

			   <cfquery name="qDropTempTables" datasource="#application.datasource#">
		if object_id('tempdb..##tmp_billacks_cannot_see') is not null
		drop table ##tmp_billacks_cannot_see

		if object_id('tempdb..##Profile_Forbidden_Template') is not null
		drop table ##Profile_Forbidden_Template

		if object_id('tempdb..##tmp_billack_templates') is not null
		drop table ##tmp_billack_templates

		if object_id('tempdb..##Allow_Only_Billbacks') is not null
		drop table ##Allow_Only_Billbacks

		if object_id('tempdb..##Allow_Analysts') is not null
		drop table ##Allow_Analysts

		if object_id('tempdb..##Positions_Below_Me') is not null
		drop table ##Positions_Below_Me

		if object_id('tempdb..##Billback_Search') is not null
		drop table ##Billback_Search

		if object_id('tempdb..##Tmp_BB_Conditions') is not null
		drop table ##Tmp_BB_Conditions
	   </cfquery>

		<!--- We unlock all billbacks of the user during loading only. --->
		<CFINCLUDE TEMPLATE="/billbacks/scorecard/unlock_billbacks.cfm">

		<CFINCLUDE TEMPLATE="/billbacks/Billback_Access_Permission.cfm">
		<!---<cfinclude template="deduction_age.cfm">--->

		<cfif Not isDefined("request.AccessStructure")>
			<cfset request.AccessStructure = structNew() />
			<cfset request.AccessStructure.user_id = arguments.user_id />
			<cfset request.AccessStructure.profiles_id = arguments.profiles_id />
		</cfif>

		<cfset stBBLabels = getBBLabels()>

		<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

		<cfset var ArrStatusDesc = ArrayNew(1)>
		<cfset var ArrStatusID = ArrayNew(1)>
		<cfset var ArrClosingMethodDesc = ArrayNew(1)>
		<cfset var ArrClosingMethodID = ArrayNew(1)>
		<cfset var ArrAnalystDesc = ArrayNew(1)>
		<cfset var ArrAnalystID = ArrayNew(1)>
		<cfset var ArrBBTypeDesc = ArrayNew(1)>
		<cfset var ArrBBTypeID = ArrayNew(1)>
		<cfset var ArrHistoryUserNameDesc = ArrayNew(1)>
		<cfset var ArrHistoryUserNameID = ArrayNew(1)>

		<cfset var StrStatusDesc = "">
		<cfset var StrStatusID = "">
		<cfset var StrClosingMethodDesc = "">
		<cfset var StrClosingMethodID = "">
		<cfset var StrAnalystDesc = "">
		<cfset var StrAnalystID = "">
		<cfset var StrBBTypeDesc = "">
		<cfset var StrBBTypeID = "">
		<cfset var StrHistoryUserNameDesc = "">
		<cfset var StrHistoryUserNameID = "">

		<!---
		NOTE:
		WE USED TO USE FULL-TEXT INITIALLY BUT CHANGED TO REGULAR QUERY SO THAT THE FLEX FILTER FOR NON-PAID BB'S AND SQL QUERY FOR PAID BB'S FILTERED RECORDS THE SAME WAY.
		SINCE FULL-TEXT FILTERS THE RECORD FROM THE BEGINNING OF A SEARCH STRING, WE NEED TO USE LIKE FOR SEARCH STRINGS ENTERED BY THE USER BUT FOR MULTIPLE-OPTION DROPDOWNS
		WE CAN PROBABLY GO BACK TO USING FULL-TEXT. IF WE HAVE ANY PERFORMANCE ISSUES IN THE FUTURE, WE CAN CONSIDER USING FULL-TEXT FOR MULTIPLE-OPTION DROPDOWN SEARCHES
		--->

		<!--- Get the status from the object passed from flex --->
		<cfif IsDefined("arguments.BBFilterparams.statusListSelect")>
			<cfif IsArray("#arguments.BBFilterparams.statusListSelect#")>
				<cfloop from="1" to="#Arraylen(arguments.BBFilterparams.statusListSelect)#" index="k">
					<cfset ArrStatusDesc[k] = arguments.BBFilterparams.statusListSelect[k].description>
					<cfset StrStatusDesc = ArrayToList(ArrStatusDesc)>
					<cfset ArrStatusID[k] = arguments.BBFilterparams.statusListSelect[k].id>
					<cfset StrStatusID =  ArrayToList(ArrStatusID)>
				</cfloop>
			</cfif>
		</cfif>

		<!--- Get the closing method from the object passed from flex --->
		<cfif IsDefined("arguments.BBFilterparams.closingMethodSelect")>
			<cfif IsArray("#arguments.BBFilterparams.closingMethodSelect#")>
				<cfloop from="1" to="#Arraylen(arguments.BBFilterparams.closingMethodSelect)#" index="k">
					<cfset ArrClosingMethodDesc[k] = arguments.BBFilterparams.closingMethodSelect[k].description>
					<cfset StrClosingMethodDesc = ArrayToList(ArrClosingMethodDesc)>
					<cfset ArrClosingMethodID[k] = arguments.BBFilterparams.closingMethodSelect[k].id>
					<cfset StrClosingMethodID = ArrayToList(ArrClosingMethodID)>
				</cfloop>
			</cfif>
		</cfif>

		<!--- Get the analyst from the object passed from flex --->
		<cfif IsDefined("arguments.BBFilterparams.analystListSelect")>
			<cfif IsArray("#arguments.BBFilterparams.analystListSelect#")>
				<cfloop from="1" to="#Arraylen(arguments.BBFilterparams.analystListSelect)#" index="k">
					<cfset ArrAnalystDesc[k] = arguments.BBFilterparams.analystListSelect[k].fullName>
					<cfset StrAnalystDesc = ArrayToList(ArrAnalystDesc)>
					<cfset ArrAnalystID[k] = arguments.BBFilterparams.analystListSelect[k].idInt>
					<cfset StrAnalystID = ArrayToList(ArrAnalystID)>
				</cfloop>
			</cfif>
		</cfif>

		<!--- Get the BB Type from the object passed from flex --->
		<cfif IsDefined("arguments.BBFilterparams.typeListSelect")>
			<cfif IsArray("#arguments.BBFilterparams.typeListSelect#")>
				<cfloop from="1" to="#Arraylen(arguments.BBFilterparams.typeListSelect)#" index="k">
					<cfset ArrBBTypeDesc[k] = arguments.BBFilterparams.typeListSelect[k].description>
					<cfset StrBBTypeDesc = ArrayToList(ArrBBTypeDesc)>
					<cfset ArrBBTypeID[k] = arguments.BBFilterparams.typeListSelect[k].id>
					<cfset StrBBTypeID = ArrayToList(ArrBBTypeID)>
				</cfloop>
			</cfif>
		</cfif>

		<!--- Get the user from the object passed from flex --->
		<cfif IsDefined("arguments.BBFilterparams.historyUsernameSelect")>
			<cfif IsArray("#arguments.BBFilterparams.historyUsernameSelect#")>
				<cfloop from="1" to="#Arraylen(arguments.BBFilterparams.historyUsernameSelect)#" index="k">
					<cfset ArrHistoryUserNameDesc[k] = arguments.BBFilterparams.historyUsernameSelect[k].fullName>
					<cfset StrHistoryUserNameDesc = ArrayToList(ArrHistoryUserNameDesc)>
					<cfset ArrHistoryUserNameID[k] =  arguments.BBFilterparams.historyUsernameSelect[k].idInt>
					<cfset StrHistoryUserNameID = ArrayToList(ArrHistoryUserNameID)>
				</cfloop>
			</cfif>
		</cfif>

		<cfset stSearch.Profiles_ID = arguments.profiles_id>
		<!---<cfset stSearch.User_ID = arguments.user_id>--->

		<cfif Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
			<cfset stSearch.programScorecardRestrictCreatedByUserId = request.AccessStructure.user_id>
		</cfif>

		<cfquery name="qGetBillbackArchiveDataCount" datasource="#application.datasource#">
		set transaction isolation level read uncommitted

	DECLARE @ViewPrivateDocuments bit,
	@DatesToInt int,
	@DateWithTimeZoneDiff int,
	@DateWithTimeZoneDiff_1 int,
	@useDayLightSavingsTime bit,
	@RecordCount int

		SET @DateWithTimeZoneDiff = #arguments.timeZoneDiff#
		<!--- Without using "INT", the value is 'YES' without single quotes, causing issues in the "SET" Statement. --->
		SET @useDayLightSavingsTime = #int(request.AccessStructure.useDayLightSavingsTime)#

	<!--- When we use "dbo.get_TimeZoneOffset_Date" sql function for a SELECT statement, then we need to modify the date before we send it back to flex.
	For eg:If a user logs for India (which is 9.5 hours ahead of EST based of time of the year), and the date in the db is 12/12/2012 00:00:00,
	the query would return 12/11/2012 14:30:00, so that when flex adds 09:30 for the local time zone, the date goes back to is 12/12/2012 00:00:00.
	In the case below, i.e. insert - when a user creates a new billback and the date in India is 12/12/2012, the date of 12/11/2012 14:30:00 will be
	passed by flex to CF, as that is the local time in EST and so we need to add 09:30 to 12/11/2012 14:30:00 which makes the date 12/12/2012 00:00:00.
	Since we need to add add 09:30, I have reversed the logic below -  Added a minus sign before DiffLocalTimeZoneAndEST.
	One more thing to keep in mind here is that "dbo.get_TimeZoneOffset_Date" sql function is passing "1" as the argument for "timeFormat".
	This preserves the time part of the date.
	Eg: A user in India searches for billbacks with an approval date of 12/12/2012. Flex passes 12/11/2012 14:30 to CF as this is the local time is EST.
	We need to preserve the Time here so that CF can now add 9.5 hours to 12/11/2012 14:30 to make it 12/12/2012 and do a search on 12/12/2012.
	--->
		SET @DateWithTimeZoneDiff_1 = -(#arguments.timeZoneDiff#)

			<cfif NOT UserIsAnalyst>
				#PreserveSingleQuotes(AllowBillbackIDs)#
			<cfelse>
				#PreserveSingleQuotes(AllowAnalystIds)#
			</cfif>

		if object_id('tempdb..##Profile_Forbidden_Template') is not null
		drop table ##Profile_Forbidden_Template

		Create  table ##Profile_Forbidden_Template
		(
		  template_id int not null
		)

		INSERT INTO  ##Profile_Forbidden_Template(Template_ID)
		<!------ forbit type=1, forbid, 0=allow ----->
		<cfif forbidType EQ 1>
		SELECT Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
		FROM Program_Control_Panel_Options
		LEFT JOIN Profile_Forbidden_Template
		ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Profile_Forbidden_Template.template_id
		AND Profile_Forbidden_Template.Forbid_Access_Type = 1
		AND Profile_Forbidden_Template.deleted = 0
		AND Profile_Forbidden_Template.Forbid_Type = #forbidType#
		AND Profile_Forbidden_Template.profile_id = #stSearch.Profiles_ID#
		<!--- Show me the templates, which are not in the "Profile_Forbidden_Template" table --->
		WHERE Profile_Forbidden_Template.template_id IS NULL

		<cfelse>

		SELECT Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
		FROM Program_Control_Panel_Options
		INNER JOIN Profile_Forbidden_Template
		ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Profile_Forbidden_Template.template_id
		WHERE Profile_Forbidden_Template.deleted = 0
		AND Profile_Forbidden_Template.Forbid_Access_Type = 1
		AND Profile_Forbidden_Template.Forbid_Type = #forbidType#
		AND Profile_Forbidden_Template.profile_id = #stSearch.Profiles_ID#
		</cfif>

		CREATE  CLUSTERED  INDEX [I_Profile_Forbidden_Template_tmp] ON [dbo].[##Profile_Forbidden_Template]([Template_ID])
		WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]

		SELECT    Billback.Billback_ID
		INTO ##tmp_billacks_cannot_see
		FROM Billback
		INNER JOIN Billback_Program
		ON    Billback.Billback_ID = Billback_Program.Billback_ID
		AND   Billback_Program.Deleted = 0
			INNER JOIN Contract_Main
		ON  Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
		WHERE Billback.Deleted = 0

		AND  ProgramType_ID NOT IN
		(
		  SELECT Template_ID
		  FROM ##Profile_Forbidden_Template
		)

		SELECT @ViewPrivateDocuments = View_Private_Documents
		FROM Profiles_Settings
		WHERE Profiles_ID = #Request.AccessStructure.Profiles_ID#

		<!--- For "Doc attached" and "No Doc attached", keep data in a temp table --->
		<cfif arguments.BBFilterparams.conditionSelect eq "Doc attached" OR arguments.BBFilterparams.conditionSelect eq "No Doc attached">
		SELECT Billback_Search.Billback_ID_Int,CASE
		 WHEN
			  LEN((
		  SELECT  CASE WHEN COUNT(Document_Details.Doc_ID) > 0 THEN 1 ELSE NULL END
		  FROM    Document_Details
		  INNER JOIN 	Contract_Attachments ON Document_Details.Doc_ID = Contract_Attachments.Doc_ID
		  WHERE  Contract_Attachments.Billback_ID = Billback_Search.billback_id
		  AND Document_Details.Deleted = 0
			AND
			(
			<!--- Public_View = 0 means "public" --->
			Public_View = 0 OR (Public_View = 1  AND @ViewPrivateDocuments = 1) OR (Document_Details.Uploaded_By = '#Request.AccessStructure.User_ID#')
			)
		  )) > 0

		 THEN CAST(1 As bit)
		  ELSE
			  CAST(0 As bit)
		  END
		As Document_Attached
		INTO ##Tmp_BB_Conditions
		FROM Billback_Search
		  </cfif>

		<!--- Populate payee in the header object and then let the user search by name and id on flex itself.--->
			SELECT DISTINCT TOP 50000 Billback_Search.Billback_ID,Billback_Search.Billback_ID_Int,Billback_Search.BB_Code,Billback_Search.BB_Reference,Billback_Search.referenceNum,
		Billback_Search.Searchable_BB_Code,Billback_Search.BB_Title,Billback_Search.BB_Amount,Billback_Search.Approved_Amount,

	   <!---  Use DateAdd to add or subtract time for the specific timezone of the user.Get the new date based on Time Zone.
		   For eg: If a person logs in to the flex application from CST time zone, then the date would be one hour more than the value in the db.
		--->
		<!--- BB_Request_Approval_Date and Approved_date and Created_Date do not have timeformat of 0:00:00. Here it is being converted to that format --->
		dbo.get_TimeZoneOffset_Date(Billback_Search.BB_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As BB_Date,
		dbo.get_TimeZoneOffset_Date(Billback_Search.BB_Start_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As BB_Start_Date,
		dbo.get_TimeZoneOffset_Date(Billback_Search.BB_End_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As BB_End_Date,
		dbo.get_TimeZoneOffset_Date(Billback_Search.Created_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As Created_Date,
		dbo.get_TimeZoneOffset_Date(Billback_Search.BB_Request_Approval_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As BB_Request_Approval_Date,
		dbo.get_TimeZoneOffset_Date(Billback_Search.Date_Approved,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As Date_Approved,
		dbo.get_TimeZoneOffset_Date(Billback_Search.Paid_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As Paid_Date,
		dbo.get_TimeZoneOffset_Date(ISNULL(Billback_Search.BB_Received_Date, Billback_Search.BB_Date),@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As BB_Received_Date,
		Billback_Search.Check_Number,
		<!--- For "Doc attached" and "No Doc attached", get the actual data --->
	   <cfif arguments.BBFilterparams.conditionSelect eq "Doc attached" OR arguments.BBFilterparams.conditionSelect EQ "No Doc attached">
		##Tmp_BB_Conditions.Document_Attached,
	   <cfelse>
		<!--- If the user does not serach for "Doc attached" and "No Doc attached", just send 0 (this data is not being used in this case) --->
		 CAST(0 As bit) As Document_Attached,
	   </cfif>
	   Billback_Search.Billback_Status_ID,Billback_Search.BB_Status_Description,Billback_Search.BB_Status_Abbreviation,Billback_Search.Billback_Closing_Method_ID,
	   Billback_Search.Billback_Closing_Method_ID_List,Billback_Search.Billback_Closing_Method_Desc,Billback_Search.Billback_Closing_Method_Abbreviation,
	   Billback_Search.BB_Type_ID,
	   Billback_Search.BB_Type_Description,

		Billback_Search.Analyst_User_Int,
		Billback_Search.Analyst_User_ID,
		Billback_Search.Analyst_User,
		Billback_Search.Creator_User_Int,
		Billback_Search.Creator_User,
		Billback_Search.Request_Approval_User_Int,
		Billback_Search.Request_Approval_User,
		Billback_Search.Disagree_User_Int,
		Billback_Search.Disagree_User,
		Billback_Search.Reset_User_Int,
		Billback_Search.Reset_User,
		Billback_Search.Approved_User_Int,
		Billback_Search.Approved_User,
		Billback_Search.Billback_Payee_Type_ID,
		Billback_Search.Payee,
		Billback_Search.Payee_ID,
		Billback_Search.vendorPayee,
		Billback_Search.vendorPayeeId,

		<!--- A paid billback cannot be reset --->
		CAST(0 As bit) As ResetAllowed,
		 <!--- A paid billback cannot be deleted --->
		CAST(0 As bit) As DeleteAllowed,
		 <!--- A paid billback cannot be reinterfaced --->
		CAST(0 As bit) As notAcknowledged,
		 <!--- A paid billback cannot be approved --->
		CAST(0 As bit) As MassApproveAllowed,
		CAST(0 As bit) As deviationAllowed,
		CAST(0 As bit) As ReleaseAllowed,
		CAST(0 As bit) As HoldAllowed,

		Billback_Search.deviated,
		Billback.Payment_Notes AS Payment_Notes,
		Billback.Special_Handling AS Special_Handling,
		CASE
		WHEN	billback.Billback_Status_ID IN (1,2) THEN 1
		ELSE 0
		END AS ReassignAllowed,
		Billback.BB_Upload_Dup_Group_ID,
		Billback.Uploaded_Billback,
		CASE WHEN Billback_Search.Expected_Amount - Billback_Search.Approved_Amount != 0 THEN 1 ELSE 0 END as Discrepancy
		INTO ##Billback_Search
		FROM Billback_Search

		<cfif arguments.BBFilterparams.conditionSelect eq "Doc attached" OR arguments.BBFilterparams.conditionSelect EQ "No Doc attached">
		INNER JOIN ##Tmp_BB_Conditions
		ON ##Tmp_BB_Conditions.Billback_ID_Int = Billback_Search.Billback_ID_Int
		</cfif>

		INNER JOIN Billback
		ON Billback_Search.Billback_ID_Int = Billback.Billback_ID_Int

		<!--- program search --->
		<cfif arguments.BBFilterparams.programKeyword neq "">
			INNER JOIN Program_Search PS ON 1 = 1
			<cfloop from="1" to="#listLen(arguments.BBFilterparams.programKeyword)#" index="p">
			INNER JOIN CONTAINSTABLE(Program_Search, *, '"*#ListGetAt(arguments.BBFilterparams.programKeyword,p)#*"') AS PROGRAM_TABLE_#p#
			ON PROGRAM_TABLE_#p#.[KEY] = PS.Program_ID
			</cfloop>

			INNER JOIN Contract_Main CM
			ON PS.Program_ID = CM.Contract_Main_ID
			AND CM.Deleted = 0
			<!---Some of the programs which are actually not cancelled have manual_cancel = 1 and CM.Cancel_And_End_Dated = 1. These programs should be included.
			   The "Cancel_And_End_Dated" is a date field and the program has been end dated with this date but should be included as it is not cancelled.
			--->
			AND (CM.Manual_Cancel = 0 OR CM.Cancel_And_End_Dated = 1)
			AND CM.Flagged_As_Purged = 0

			INNER JOIN Billback_Program BP ON
			PS.Program_ID = BP.Program_ID AND
			Billback.Billback_ID =  BP.Billback_ID AND
			BP.Deleted = 0
		</cfif>

		<!--- customer search --->
		<cfif arguments.BBFilterparams.entitySelect eq application.returned_customer_setting.distributor_label_singular AND arguments.BBFilterparams.entityKeyword neq "">
			INNER JOIN dbo.BSA_Foodservice_Customers BFC ON 1 = 1
			<cfloop from="1" to="#listLen(arguments.BBFilterparams.entityKeyword)#" index="e">
			INNER JOIN CONTAINSTABLE(BSA_Foodservice_Customers, *, '"*#ListGetAt(arguments.BBFilterparams.entityKeyword,e)#*"') AS DIST_TABLE_#e#
			ON DIST_TABLE_#e#.[KEY] = BFC.BSA_Foodservice_Customers_ID
			</cfloop>

			INNER JOIN Billback_Distributor_List BD ON
			BFC.BSA_Foodservice_Customers_ID = BD.Distributor_ID AND
			Billback.Billback_ID =  BD.Billback_ID AND
			BD.Deleted = 0
		</cfif>

		<!--- operator search --->
		<cfif arguments.BBFilterparams.entitySelect eq application.returned_customer_setting.operator_label_singular AND arguments.BBFilterparams.entityKeyword neq "">
			INNER JOIN dbo.BSA_Operator BSO ON 1 = 1
			<cfloop from="1" to="#listLen(arguments.BBFilterparams.entityKeyword)#" index="o">
			INNER JOIN CONTAINSTABLE(BSA_Operator, *, '"*#ListGetAt(arguments.BBFilterparams.entityKeyword,o)#*"') AS OPR_TABLE_#o#
			ON OPR_TABLE_#o#.[KEY] = BSO.BSA_Operator_ID
			</cfloop>

			INNER JOIN Billback_Operator BO ON
			BSO.BSA_Operator_ID = BO.Operator_ID AND
			Billback.Billback_ID =  BO.Billback_ID AND
			BO.Deleted = 0
		</cfif>

		<!--- broker search --->
		<cfif arguments.BBFilterparams.entitySelect eq application.returned_customer_setting.broker_label_singular AND arguments.BBFilterparams.entityKeyword neq "">
			INNER JOIN dbo.BSA_Foodservice_Brokers BFB ON 1 = 1
			<cfloop from="1" to="#listLen(arguments.BBFilterparams.entityKeyword)#" index="b">
			INNER JOIN CONTAINSTABLE(BSA_Foodservice_Brokers, *, '"*#ListGetAt(arguments.BBFilterparams.entityKeyword,b)#*"') AS BRK_TABLE_#b#
			ON BRK_TABLE_#b#.[KEY] = BFB.BSA_Foodservice_Brokers_ID
			</cfloop>

			INNER JOIN Billback_Broker BBR ON
			BFB.BSA_Foodservice_Brokers_ID = BBR.Broker_ID AND
			Billback.Billback_ID = BBR.Billback_ID AND
			BBR.Deleted = 0
		</cfif>


	WHERE Billback.deleted = 0

		<cfif arguments.BBFilterparams.bChkDuplicate>
		AND ISNULL(Billback.BB_Upload_Dup_Group_ID,'') != ''
		</cfif>

			<cfif IsDefined("stSearch.programScorecardRestrictCreatedByUserId")>
			<!--- If the below profile settings is on, then the user should only be allowed to see programs
			that have him/her as an RSP OR where the program creator's RSP has the user number same as
			this user's User number
			--->
			AND NOT EXISTS
			(
		   <cfif appSettings.getUserNumberRestrict()>
				<cfset qUser = createObject("component", "components.user.UserManager").getUser(stSearch.programScorecardRestrictCreatedByUserId) />
				<cfset qUserNumber = qUser.User_Number />
			</cfif>
			SELECT Billback_ID
			FROM Billback_Program
			INNER JOIN Contract_Main
			ON Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
			LEFT JOIN _Users responsibleSalesPerson
			ON 	responsibleSalesPerson.User_ID = Contract_Main.Responsible_User_ID
			AND	responsibleSalesPerson.Deleted = 0
			WHERE Billback_Program.Billback_ID = Billback.Billback_ID
			AND Billback_Program.Deleted = 0
			AND(
			Isnull(rtrim(ltrim(Contract_Main.Responsible_User_ID)),'') != '#stSearch.programScorecardRestrictCreatedByUserId#'
			<cfif len(qUserNumber)>
				AND Isnull(rtrim(ltrim(responsibleSalesPerson.User_Number)),'') != '#qUserNumber#'
			</cfif>
			)
			)
			</cfif>

		AND NOT EXISTS
			(
		select Billback_ID
		FROM ##tmp_billacks_cannot_see
		WHERE ##tmp_billacks_cannot_see.Billback_ID = Billback.Billback_ID
		)

			<!---TSF - Label 16253: Add Billback filter logic if search by analyst is not on for this profile--->
			<cfif not Get_Profile_Settings.BB_Search_By_Analyst>
			<cfif HQUser NEQ 1 OR UserIsAnalyst> <!--- if user is an analyst or not HQ --->
	   <!--- The values of "UserPositionList" and "##Allow_Only_Billbacks" and "AnalystList" comes from "/billbacks/Billback_Access_Permission.cfm" --->
			AND (
				Billback.BB_Creator_ID = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
				<cfif UserIsAnalyst EQ 0>
					OR Billback.BB_Creator_User_Position_ID IN (#PreserveSingleQuotes(UserPositionList)#)
					<cfif listlen(BillbackIDs) GT 0>
						OR Billback.Billback_ID IN (SELECT Billback_ID FROM ##Allow_Only_Billbacks)
					</cfif>
				<cfelse><!------ If billback analyst do not look at the position tree, use the analyst logic alone ----->
					<cfif AnalystList NEQ "">
						OR	Billback.Analyst_User_ID IN (#PreserveSingleQuotes(AnalystList)#)
						OR	Billback.BB_Creator_ID IN (#PreserveSingleQuotes(AnalystList)#)
					</cfif>
				</cfif>
			)
			</cfif>

			</cfif>

		<cfif arguments.billbackIdIntList neq "">
		AND billback.billback_ID_Int IN (#PreserveSingleQuotes(arguments.billbackIdIntList)#)
		</cfif>

	<!--- BBCode and BB Title search --->
	<cfif arguments.BBFilterparams.BBCodeKeyword neq "">
	 AND
	 (
	  <!--- CONTAINS(Billback_Search.BB_Code, '"#arguments.BBFilterparams.BBCodeKeyword#*"')
	  OR
		   CONTAINS(Billback_Search.BB_Title, '"#arguments.BBFilterparams.BBCodeKeyword#*"')
	  --->
	   Billback_Search.BB_Code like '%#arguments.BBFilterparams.BBCodeKeyword#%'
	   OR
	   Billback_Search.BB_Title like '%#arguments.BBFilterparams.BBCodeKeyword#%'
	 )
	</cfif>

	<!--- BB Reference and ReferenceNum search --->
	<cfif arguments.BBFilterparams.BBNumberKeyword neq "">
	 AND
	 (
	   <!---CONTAINS(Billback_Search.BB_Reference, '"#arguments.BBFilterparams.BBNumberKeyword#*"')
	   OR
	   CONTAINS(Billback_Search.ReferenceNum, '"#arguments.BBFilterparams.BBNumberKeyword#*"')
	   --->
	   Billback_Search.BB_Reference like '%#arguments.BBFilterparams.BBNumberKeyword#%'
	   OR
	   Billback_Search.ReferenceNum like '%#arguments.BBFilterparams.BBNumberKeyword#%'
	 )
	</cfif>

	<!--- check number search --->
	<cfif arguments.BBFilterparams.checkNoKeyword neq "">
	 AND <!---CONTAINS(Billback_Search.Check_Number, '"#arguments.BBFilterparams.checkNoKeyword#*"')--->
		Billback_Search.Check_Number like '%#arguments.BBFilterparams.checkNoKeyword#%'
	</cfif>

	<!--- payee(id and name) search --->
	<cfif arguments.BBFilterparams.payeeKeyword neq "">
	 AND
	 (
	   <!---
	   CONTAINS(Billback_Search.Payee_ID, '"#arguments.BBFilterparams.payeeKeyword#*"')
	   OR
	   CONTAINS(Billback_Search.Payee, '"#arguments.BBFilterparams.payeeKeyword#*"')
	   --->
	   Billback_Search.Payee_ID like '%#arguments.BBFilterparams.payeeKeyword#%'
	   OR
	   Billback_Search.Payee like '%#arguments.BBFilterparams.payeeKeyword#%'
	 )
	</cfif>

	<!--- multiple status search --->
	<cfif StrStatusID neq "">
	 AND <!---CONTAINS(Billback_Search.BB_Status_Description, '"#StrStatusDesc#"')--->
	<!--- Note: Billback_Search has "paid" only (ID = 5) and so any other criteria will not return records, but do not hard-code the value to 5,
	as the user could have statuses other than 'paid' selected in the dropdown. --->
	Billback_Search.Billback_Status_ID IN (#StrStatusID#)
	</cfif>

	<!--- multiple closing method search --->
	<cfif StrClosingMethodID neq "">
	 AND
	 (<!---CONTAINS(Billback_Search.Billback_Closing_Method_Desc, '"#StrClosingMethodDesc#"')--->
	Billback_Search.Billback_Closing_Method_ID IN (#StrClosingMethodID#)

	<!--- If only parent billbacks are displayed in the search result, then get the closing method of the child billbacks as a comma-delimited list.
	The users should be able to search on the child billbacks as these are the actual closing method of the billback. --->
		<cfif bOnlyDisplayBillbackParent>
			<cfloop list="#StrClosingMethodID#" index="i">
			 OR Billback_Search.Billback_Closing_Method_ID_List like '%#i#%'
			</cfloop>
		</cfif>
	)
	</cfif>

	<!--- multiple analyst search --->
	<cfif StrAnalystID neq "">
	 AND <!---CONTAINS(Billback_Search.Analyst_User, '"#StrAnalystDesc#"')--->
	Billback_Search.Analyst_User_Int IN (#StrAnalystID#)
	</cfif>

	<!--- multiple billback type search --->
	<cfif StrBBTypeID neq "">
	 AND <!---CONTAINS(Billback_Search.BB_Type_Description, '"#StrBBTypeDesc#"')--->
	Billback_Search.BB_Type_ID IN (#StrBBTypeID#)
	</cfif>

	<!--- user history search --->
	<cfif StrHistoryUserNameID neq "">

		<cfif arguments.BBFilterparams.historySelect eq "Created By">
		 AND <!---CONTAINS(Billback_Search.Creator_User, '"#StrHistoryUserNameDesc#"')--->
		 Billback_Search.Creator_User_Int IN (#StrHistoryUserNameID#)

		<cfelseif arguments.BBFilterparams.historySelect eq "RFA By">
		 AND <!---CONTAINS(Billback_Search.Request_Approval_User, '"#StrHistoryUserNameDesc#"')--->
		 Billback_Search.Request_Approval_User_Int IN (#StrHistoryUserNameID#)

		<cfelseif arguments.BBFilterparams.historySelect eq "Approved By">
		 AND <!---CONTAINS(Billback_Search.Approved_User, '"#StrHistoryUserNameDesc#"')--->
		 Billback_Search.Approved_User_Int IN (#StrHistoryUserNameID#)

		<cfelseif arguments.BBFilterparams.historySelect eq "Disagreed By">
		 AND <!---CONTAINS(Billback_Search.Disagree_User, '"#StrHistoryUserNameDesc#"')--->
		 Billback_Search.Disagree_User_Int IN (#StrHistoryUserNameID#)

		<cfelseif arguments.BBFilterparams.historySelect eq "Reset By">
		 AND <!---CONTAINS(Billback_Search.Reset_User, '"#StrHistoryUserNameDesc#"')--->
		 Billback_Search.Reset_User_Int IN (#StrHistoryUserNameID#)
		</cfif>
	</cfif>

	<!--- date history search (range start) --->

	<!---"dbo.get_TimeZoneOffset_Date" sql function is passing "1" as the argument for "timeFormat".
	This preserves the time part of the date.
	Eg: A user in India searches for billbacks with an approval date of 12/12/2012. Flex passes 12/11/2012 14:30 to CF as this is the local time is EST.
	We need to preserve the Time here so that CF can now add 9.5 hours to 12/11/2012 14:30 to make it 12/12/2012 and do a search on 12/12/2012.
	--->
	<cfif arguments.BBFilterparams.dateRangeStartCriteriaSelect neq "" AND arguments.BBFilterparams.dateRangeStartValueKeyword neq "">
		<cfif arguments.BBFilterparams.dateRangeStartTypeSelect eq "#stBBLabels.Billback#">

		 AND Billback_Search.BB_Date #arguments.BBFilterparams.dateRangeStartCriteriaSelect# dbo.get_TimeZoneOffset_Date('#arguments.BBFilterparams.dateRangeStartValueKeyword#',@DateWithTimeZoneDiff_1,@useDayLightSavingsTime, 1, 0)

		<cfelseif arguments.BBFilterparams.dateRangeStartTypeSelect eq "Start">
		 AND Billback_Search.BB_Start_Date #arguments.BBFilterparams.dateRangeStartCriteriaSelect# dbo.get_TimeZoneOffset_Date('#arguments.BBFilterparams.dateRangeStartValueKeyword#',@DateWithTimeZoneDiff_1,@useDayLightSavingsTime, 1, 0)

		<cfelseif arguments.BBFilterparams.dateRangeStartTypeSelect eq "End">

		 AND Billback_Search.BB_End_Date  #arguments.BBFilterparams.dateRangeStartCriteriaSelect# dbo.get_TimeZoneOffset_Date('#arguments.BBFilterparams.dateRangeStartValueKeyword#',@DateWithTimeZoneDiff_1,@useDayLightSavingsTime, 1, 0)

		<!--- Since the time part of the date is not "0:00:00", use the "CONVERT" function. It is useful when using the "=" operator. "<=" and ">=" does not need it.  --->
		<cfelseif arguments.BBFilterparams.dateRangeStartTypeSelect eq "Create">

		 AND CONVERT(VARCHAR(10),Billback_Search.Created_Date,120) #arguments.BBFilterparams.dateRangeStartCriteriaSelect# CONVERT(VARCHAR(10),dbo.get_TimeZoneOffset_Date('#arguments.BBFilterparams.dateRangeStartValueKeyword#',@DateWithTimeZoneDiff_1,@useDayLightSavingsTime, 1, 0),120)

		<!--- Since the time part of the date is not "0:00:00", use the "CONVERT" function. It is useful when using the "=" operator. "<=" and ">=" does not need it.  --->
		<cfelseif arguments.BBFilterparams.dateRangeStartTypeSelect eq "RFA">

		 AND CONVERT(VARCHAR(10),Billback_Search.BB_Request_Approval_Date,120) #arguments.BBFilterparams.dateRangeStartCriteriaSelect# CONVERT(VARCHAR(10),dbo.get_TimeZoneOffset_Date('#arguments.BBFilterparams.dateRangeStartValueKeyword#',@DateWithTimeZoneDiff_1,@useDayLightSavingsTime, 1, 0),120)

		<!--- Since the time part of the date is not "0:00:00", use the "CONVERT" function. It is useful when using the "=" operator. "<=" and ">=" does not need it.  --->
		<cfelseif arguments.BBFilterparams.dateRangeStartTypeSelect eq "Approved">

		 AND CONVERT(VARCHAR(10),Billback_Search.Date_Approved,120) #arguments.BBFilterparams.dateRangeStartCriteriaSelect# CONVERT(VARCHAR(10),dbo.get_TimeZoneOffset_Date('#arguments.BBFilterparams.dateRangeStartValueKeyword#',@DateWithTimeZoneDiff_1,@useDayLightSavingsTime, 1, 0),120)

		<!--- Since the time part of the date is not "0:00:00", use the "CONVERT" function. It is useful when using the "=" operator. "<=" and ">=" does not need it.  --->
		<cfelseif arguments.BBFilterparams.dateRangeStartTypeSelect eq "Paid">
		 AND CONVERT(VARCHAR(10),Billback_Search.Paid_Date,120) #arguments.BBFilterparams.dateRangeStartCriteriaSelect# CONVERT(VARCHAR(10),dbo.get_TimeZoneOffset_Date('#arguments.BBFilterparams.dateRangeStartValueKeyword#',@DateWithTimeZoneDiff_1,@useDayLightSavingsTime, 1, 0),120)
		</cfif>
	</cfif>

	<!--- date history search (range end) --->

	<!---"dbo.get_TimeZoneOffset_Date" sql function is passing "1" as the argument for "timeFormat".
	This preserves the time part of the date.
	Eg: A user in India searches for billbacks with an approval date of 12/12/2012. Flex passes 12/11/2012 14:30 to CF as this is the local time is EST.
	We need to preserve the Time here so that CF can now add 9.5 hours to 12/11/2012 14:30 to make it 12/12/2012 and do a search on 12/12/2012.
	--->
	<cfif arguments.BBFilterparams.dateRangeEndCriteriaSelect neq "" AND arguments.BBFilterparams.dateRangeEndValueKeyword neq "">
		<cfif arguments.BBFilterparams.dateRangeEndTypeSelect eq "#stBBLabels.Billback#">
		 AND Billback_Search.BB_Date #arguments.BBFilterparams.dateRangeEndCriteriaSelect# dbo.get_TimeZoneOffset_Date('#arguments.BBFilterparams.dateRangeEndValueKeyword#',@DateWithTimeZoneDiff_1,@useDayLightSavingsTime, 1, 0)

		<cfelseif arguments.BBFilterparams.dateRangeEndTypeSelect eq "Start">
		 AND Billback_Search.BB_Start_Date #arguments.BBFilterparams.dateRangeEndCriteriaSelect# dbo.get_TimeZoneOffset_Date('#arguments.BBFilterparams.dateRangeEndValueKeyword#',@DateWithTimeZoneDiff_1,@useDayLightSavingsTime, 1, 0)

		<cfelseif arguments.BBFilterparams.dateRangeEndTypeSelect eq "End">
		 AND Billback_Search.BB_End_Date  #arguments.BBFilterparams.dateRangeEndCriteriaSelect# dbo.get_TimeZoneOffset_Date('#arguments.BBFilterparams.dateRangeEndValueKeyword#',@DateWithTimeZoneDiff_1,@useDayLightSavingsTime, 1, 0)

		<!--- Since the time part of the date is not "0:00:00", use the "CONVERT" function. It is useful when using the "=" operator. "<=" and ">=" does not need it.  --->
		<cfelseif arguments.BBFilterparams.dateRangeEndTypeSelect eq "Create">
		 AND CONVERT(VARCHAR(10),Billback_Search.Created_Date,120) #arguments.BBFilterparams.dateRangeEndCriteriaSelect# CONVERT(VARCHAR(10),dbo.get_TimeZoneOffset_Date('#arguments.BBFilterparams.dateRangeEndValueKeyword#',@DateWithTimeZoneDiff_1,@useDayLightSavingsTime, 1, 0),120)

		<!--- Since the time part of the date is not "0:00:00", use the "CONVERT" function. It is useful when using the "=" operator. "<=" and ">=" does not need it.  --->
		<cfelseif arguments.BBFilterparams.dateRangeEndTypeSelect eq "RFA">

		 AND CONVERT(VARCHAR(10),Billback_Search.BB_Request_Approval_Date,120) #arguments.BBFilterparams.dateRangeEndCriteriaSelect# CONVERT(VARCHAR(10),dbo.get_TimeZoneOffset_Date('#arguments.BBFilterparams.dateRangeEndValueKeyword#',@DateWithTimeZoneDiff_1,@useDayLightSavingsTime, 1, 0),120)

		<!--- Since the time part of the date is not "0:00:00", use the "CONVERT" function. It is useful when using the "=" operator. "<=" and ">=" does not need it.  --->
		<cfelseif arguments.BBFilterparams.dateRangeEndTypeSelect eq "Approved">

		 AND CONVERT(VARCHAR(10),Billback_Search.Date_Approved,120) #arguments.BBFilterparams.dateRangeEndCriteriaSelect# CONVERT(VARCHAR(10),dbo.get_TimeZoneOffset_Date('#arguments.BBFilterparams.dateRangeEndValueKeyword#',@DateWithTimeZoneDiff_1,@useDayLightSavingsTime, 1, 0),120)

		<!--- Since the time part of the date is not "0:00:00", use the "CONVERT" function. It is useful when using the "=" operator. "<=" and ">=" does not need it.  --->
		<cfelseif arguments.BBFilterparams.dateRangeEndTypeSelect eq "Paid">
		 AND CONVERT(VARCHAR(10),Billback_Search.Paid_Date,120) #arguments.BBFilterparams.dateRangeEndCriteriaSelect# CONVERT(VARCHAR(10),dbo.get_TimeZoneOffset_Date('#arguments.BBFilterparams.dateRangeEndValueKeyword#',@DateWithTimeZoneDiff_1,@useDayLightSavingsTime, 1, 0),120)
		</cfif>
	</cfif>

	<!--- amount history search --->
	<cfif arguments.BBFilterparams.amountCriteriaSelect neq "" AND arguments.BBFilterparams.amountValueKeyword neq "">
		<cfif arguments.BBFilterparams.amountTypeSelect eq "Claimed">
		 AND Billback_Search.BB_Amount #arguments.BBFilterparams.amountCriteriaSelect# '#arguments.BBFilterparams.amountValueKeyword#'

		<cfelseif arguments.BBFilterparams.amountTypeSelect eq "Approved">
		 AND Billback_Search.Approved_Amount #arguments.BBFilterparams.amountCriteriaSelect# '#arguments.BBFilterparams.amountValueKeyword#'

		 </cfif>
	</cfif>

	<!--- user history search --->
	<cfif arguments.BBFilterparams.conditionSelect eq "Doc attached">
		AND ##Tmp_BB_Conditions.Document_Attached = 1

	<cfelseif arguments.BBFilterparams.conditionSelect EQ "No Doc attached">
		AND ##Tmp_BB_Conditions.Document_Attached = 0

	<!--- "Deviation" access is not allowed from the search grid for paid billbacks --->
	<cfelseif arguments.BBFilterparams.conditionSelect EQ "Deviated">
		AND 1 = 0

	</cfif>

	<!--- FULL-TEXT ON VENDOR SEARCH --->
	<!--- If the search is for Vendor:
		  - Vendor Exists as "uploaded_vendor_id" in Billback_Distributor and Billback_Operator tables. We check both the tables
		to see whether the vendor exists
	Note: Vendor Info is actually loaded to CF (non-paid) and so if we search for vendor for non-paid billbacks, the search is on
	the client-side (flex) only.
	Here we are using the full-text search for Vendor because here the search is for paid billbacks and so the search needs to be
	made on the server (db), as the paid billbacks are not loaded to flex to be searched on the client-side. For every paid billback search,
	a request is made to the server (db).
	--->
	<cfif arguments.BBFilterparams.entitySelect eq "#stBBLabels.Vendor#" AND arguments.BBFilterparams.entityKeyword neq "">
		AND EXISTS
		(
		  SELECT Billback_ID_Int
		  FROM Billback BB1
			INNER JOIN dbo.Vendor_Master VM ON 1 = 1
			<cfloop from="1" to="#listLen(arguments.BBFilterparams.entityKeyword)#" index="v">
			INNER JOIN CONTAINSTABLE(Vendor_Master, *, '"*#ListGetAt(arguments.BBFilterparams.entityKeyword,v)#*"') AS VM_TABLE_#v#
			ON VM_TABLE_#v#.[KEY] = VM.Vendor_Master_ID
			</cfloop>
			INNER JOIN Billback_Distributor BD
			ON BB1.Billback_ID = BD.Billback_ID
			WHERE BB1.Deleted = 0
			AND VM.Vendor_ID = BD.Uploaded_Vendor_ID
			AND BD.Deleted = 0
			AND Billback.Billback_ID = BB1.Billback_ID

		UNION
		  SELECT Billback_ID_Int
		  FROM Billback BB2
			INNER JOIN dbo.Vendor_Master VM ON 1 = 1
			<cfloop from="1" to="#listLen(arguments.BBFilterparams.entityKeyword)#" index="v">
			INNER JOIN CONTAINSTABLE(Vendor_Master, *, '"*#ListGetAt(arguments.BBFilterparams.entityKeyword,v)#*"') AS VM_TABLE_#v#
			ON VM_TABLE_#v#.[KEY] = VM.Vendor_Master_ID
			</cfloop>
			INNER JOIN Billback_Operator BO
			ON BB2.Billback_ID = BO.Billback_ID
			WHERE BB2.Deleted = 0
			AND VM.Vendor_ID = BO.Uploaded_Vendor_ID
			AND BO.Deleted = 0
			AND Billback.Billback_ID = BB2.Billback_ID

		UNION
		/* For Auto Pay billbacks, we do not update the "uplaoded_vendor_ID field in the "Billback_Distributor" or "Billback_Operator" tables.
		Here the vendor information comes from the "bb_approved" table instead.
		*/
		  SELECT Billback_ID_Int
		  FROM Billback BB3
			INNER JOIN dbo.Vendor_Master VM ON 1 = 1
			<cfloop from="1" to="#listLen(arguments.BBFilterparams.entityKeyword)#" index="v">
			INNER JOIN CONTAINSTABLE(Vendor_Master, *, '"*#ListGetAt(arguments.BBFilterparams.entityKeyword,v)#*"') AS VM_TABLE_#v#
			ON VM_TABLE_#v#.[KEY] = VM.Vendor_Master_ID
			</cfloop>
			INNER JOIN BB_Approved BBA
			ON BB3.Billback_ID = BBA.Billback_id
			WHERE BB3.Deleted = 0
			AND VM.Vendor_Master_ID = BBA.Vendor_Master_ID
			AND Billback.Billback_ID = BB3.Billback_ID
		)
	</cfif>


	<cfif bOnlyDisplayBillbackParent>
		AND billback.BB_Is_Child = 0
	</cfif>

		if object_id('tempdb..##tmp_billacks_cannot_see') is not null
		drop table ##tmp_billacks_cannot_see

		if object_id('tempdb..##Profile_Forbidden_Template') is not null
		drop table ##Profile_Forbidden_Template

		if object_id('tempdb..##tmp_billack_templates') is not null
		drop table ##tmp_billack_templates

		if object_id('tempdb..##Allow_Only_Billbacks') is not null
		drop table ##Allow_Only_Billbacks

		if object_id('tempdb..##Allow_Analysts') is not null
		drop table ##Allow_Analysts

		if object_id('tempdb..##Positions_Below_Me') is not null
		drop table ##Positions_Below_Me

		if object_id('tempdb..##Billback') is not null
		drop table ##Billback

		if object_id('tempdb..##Tmp_BB_Conditions') is not null
		drop table ##Tmp_BB_Conditions
		
		<!---	If there are more than 50000 records, then do not return the entire resultset, just send the Top 1, so that we could get the value of the
		"NumberofRecords".  In this case, it would alert the user to use search conditions to refine search.
		UPDATE-> lets send top 50k AND a message in UI
		--->
			SELECT *
			FROM ##Billback_Search
		</cfquery>



	 <!---
	 <cfquery name="qGetBillbackArchiveData" datasource="#application.datasource#">
	  SELECT <cfif qGetBillbackArchiveDataCount.NumberofRecords GT 10000>TOP 1 #qGetBillbackArchiveDataCount.NumberofRecords# As NumberofRecords,</cfif> *
	  FROM ##Billback_Search
	 </cfquery>
	--->
	 <cfset qGetBillbackArchiveData = qGetBillbackArchiveDataCount />

		<cfreturn qGetBillbackArchiveData>

	</cffunction>


	<cffunction name="getUserProfile" returntype="string">
		<cfargument name="userId" type="string" required="true" />
		<cfset var p = 0/>
		<cfif not isdefined("request.AccessStructure")>
			<cfquery name="qryGetUserProfile" datasource="#application.datasource#">
				SELECT profiles.profiles_id
				FROM profiles inner join _users
				ON profiles.profiles_id = _users.profiles_id
				WHERE _users.user_id ='#arguments.userId#'
				AND profiles.deleted = 0
			</cfquery>
			<cfset request.AccessStructure.profiles_id = qryGetUserProfile.profiles_id />
			<cfset request.AccessStructure.user_id = arguments.userId />
		</cfif>
			<cfreturn request.AccessStructure.profiles_id />
	</cffunction>

	<cffunction name="getAllStauses" access="public" returntype="array">
	 <cfargument name="userId" type="string" required="true" />
	 <cfargument name="UseselectedRecords" type="boolean" required="false" default ="0" />
	 <cfargument name="selectedRecords" type="string" required="false" default ="" />

	  <cfset var arrStatus = ArrayNew(1)>

	   <!--- For the default query of all statuses OR If selected statuses are being passed to the query --->
	   <cfif UseselectedRecords eq 0 OR selectedRecords neq "">

		<cfset profiles_id = getUserProfile('#arguments.userid#')>

		<cfif Not isDefined("request.AccessStructure")>
			<cfset request.AccessStructure = structNew() />
			<cfset request.AccessStructure.profiles_id = arguments.profiles_id />
		</cfif>

		<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

		<cfquery name="qgetAllStauses" datasource="#application.datasource#">
		  SELECT Billback_Status_ID,BB_Status_Description,BB_Status_Abbreviation
		  FROM 	 Billback_Status
		  <!--- selected statuses are being passed to the query --->
		 <cfif selectedRecords neq "">
		  WHERE Billback_Status_ID IN (#selectedRecords#)
		  </cfif>

		<!--- If "RFA scorecard - Agreed" profile setting is ON. --->
		 <CFIF Get_Profile_Settings.BB_RFA_Agreed EQ 1>

		 <!--- Currently "SelectedRecords" has a value when called from "Favorites" --->

		 <!--- UseselectedRecords is 0 by default. SelectedRecords has a value when the this query is being called to convert the passed data into a status object --->
		 <cfif UseselectedRecords eq 0 OR ListFind(selectedRecords,201) neq 0>
		  UNION
		  SELECT 201,'Agreed','AG'
		 </cfif>

		 <!--- UseselectedRecords is 0 by default. SelectedRecords has a value when the this query is being called to convert the passed data into a status object --->
		 <cfif UseselectedRecords eq 0 OR ListFind(selectedRecords,202) neq 0>
		  UNION
		  SELECT 202,'Pending Approval','PA'
		 </cfif>

		<!--- UseselectedRecords is 0 by default. SelectedRecords has a value when the this query is being called to convert the passed data into a status object --->
		 <cfif UseselectedRecords eq 0 OR ListFind(selectedRecords,203) neq 0>
		  UNION
		  SELECT 203,'Under Review','UR'
		 </cfif>

		  </CFIF>

		ORDER BY Billback_Status_ID

		</cfquery>

		<cfloop query="qgetAllStauses">
		<cfscript>
		//build status Object
		stStatus = structNew();
		stData = structNew();
		stData["__type__"] = "mvc.Models.Billback.vos.Status";
		stData["id"] = qgetAllStauses.Billback_Status_ID;
		stData["description"] = qgetAllStauses.BB_Status_Description;
		stData["abbreviation"] = qgetAllStauses.BB_Status_Abbreviation;
		stStatus = stData;

		arrStatus[qgetAllStauses.currentrow] = stStatus;
		</cfscript>
		</cfloop>
	  </cfif>

	  <cfreturn arrStatus>

	</cffunction>

	<cffunction name="getAllClosingMethods" access="remote" returntype="array">
	  <cfargument name="UseselectedRecords" type="boolean" required="false" default ="0" />
	  <cfargument name="selectedRecords" type="string" required="false" default ="" />
	  <cfargument name="includeBEnabled" type="boolean" required="false" default="1" />
	  <cfargument name="includeProfile" type="boolean" required="false" default="0" />

	  <cfset var arrBBClosingMethods = ArrayNew(1)>

	  <!--- For the default query of all closing method OR If selected closing method are being passed to the query --->
	  <cfif UseselectedRecords eq 0 OR selectedRecords neq "">

		<cfquery name="qgetClosingMethods" datasource="#application.datasource#">
		  SELECT  BCM.iBillback_Closing_Method_ID,BCM.vchBillback_Closing_Method_Desc,
				  BCM.bEnabled, BCM.tiAutoPay_BB_Status, BCM.Deleted, BCM.Abbreviation, BCM.bDefault
		   FROM   Billback_Closing_Methods BCM
			<cfif arguments.includeProfile EQ 1 AND isDefined("Request.AccessStructure.profiles_id")>
				  INNER JOIN
		   			BB_Profile_Closing_Methods AS BPCM
		   		ON BCM.iBillback_Closing_Method_ID = BPCM.Billback_Closing_Method_ID
		   		AND BPCM.Profile_ID = #Request.AccessStructure.profiles_id#
		   		AND BPCM.Deleted = 0
		   </cfif>
		   WHERE BCM.Deleted = 0
		   <cfif arguments.includeBEnabled EQ 1>
		   	AND BCM.bEnabled = 1
		   </cfif>
		   <!--- selected closing method are being passed to the query --->
		   <cfif selectedRecords neq "">
		  AND BCM.iBillback_Closing_Method_ID IN (#selectedRecords#)
		  </cfif>
		   ORDER BY BCM.vchBillback_Closing_Method_Desc
		</cfquery>

		<cfloop query="qgetClosingMethods">
		<cfscript>
		//build closing method object
		stClosingMethod = structNew();
		stData = structNew();
		stData["__type__"] = "mvc.Models.Billback.vos.ClosingMethod";
		stData["id"] = qgetClosingMethods.iBillback_Closing_Method_ID;
		stData["description"] = qgetClosingMethods.vchBillback_Closing_Method_Desc;
		stData["abbreviation"] = qgetClosingMethods.Abbreviation;
		stData["bDefault"] = qgetClosingMethods.bDefault;
		stClosingMethod = stData;

		arrBBClosingMethods[qgetClosingMethods.currentrow] = stClosingMethod;
		</cfscript>
		</cfloop>
	   </cfif>

	  <cfreturn arrBBClosingMethods>
	</cffunction>

	<cffunction name="getAllBBUploadedTypeLabels" access="public" returntype="array">
	  <cfargument name="UseselectedRecords" type="boolean" required="false" default ="0" />
	  <cfargument name="selectedRecords" type="string" required="false" default ="" />
		 <!---
		 <cfset oBillbackTypeLabelSettings = createObject("component", "components.billback.BillbackSettingsManager") />
		 <cfset qgetBBUploadedTypeLabels = oBillbackTypeLabelSettings.getBBUploadedTypeLabels() />
		 --->

		<cfset var arrType = ArrayNew(1)>
		<cfset var arrTypeList = ArrayNew(1)>

	  <!--- For the default query of all BB Type OR If selected BB Type are being passed to the query --->
	  <cfif UseselectedRecords eq 0 OR selectedRecords neq "">

		 <!--- Always include these two --->
		<cfset typeLabels ="Manual,Upload">
		<!--- <cfset typeLabels ="Manual,User">--->

		  <!--- Only if "Third Party" upload is not OFF --->
		  <cfif appSettings.getThirdPartyBBUpload() neq 0>
		 <cfset typeLabels = ListAppend(typeLabels,'3rd Party')>
		<!---<cfset typeLabels = ListAppend(typeLabels,'Auto')>--->
		  </cfif>

		  <!--- Only if "Auto Pay" is ON --->
		  <cfif appSettings.getBBAutoReport()>
		<cfset typeLabels = ListAppend(typeLabels,'Auto Pay')>
		  </cfif>

		  <cfquery name="qgetAutoApprove" datasource="#application.datasource#">
		SELECT Auto_Approve_On
		FROM Billback_Settings
		  </cfquery>

		  <!--- Only if "Auto Approve" is ON --->
		  <cfif qgetAutoApprove.Auto_Approve_On eq 1>
		<cfset typeLabels = ListAppend(typeLabels,'Auto Approved')>
		  </cfif>

		  <cfset arrTypeLabels = ListToArray(typeLabels)>

		  <cfloop from="1" to="#ArrayLen(arrTypeLabels)#" index ="i">
		 <cfset arrType[i] = arrTypeLabels[i]>
		  </cfloop>

		<cfset qBBTypeLabels = QueryNew("BB_Type_ID,BB_Type_Description")>

		<cfloop from="1" to="#ArrayLen(arrTypeLabels)#" index="i">
		<!--- selected BB Type are being passed to the query --->
		<cfif UseselectedRecords eq 0 OR ListFind(selectedRecords,i) neq 0>
		   <cfset AddNewRow = QueryAddRow(qBBTypeLabels)>
		   <cfset AddNewRow = QuerySetCell(qBBTypeLabels, "BB_Type_ID", i)>
		   <cfset AddNewRow = QuerySetCell(qBBTypeLabels, "BB_Type_Description", arrType[i])>
		 </cfif>
		</cfloop>

	   <cfloop query="qBBTypeLabels">
		<cfscript>
		//build BBType Object
		stType = structNew();
		stData = structNew();
		stData["__type__"] = "mvc.Models.Billback.vos.Type";
		stData["id"] = qBBTypeLabels.BB_Type_ID;
		stData["description"] = qBBTypeLabels.BB_Type_Description;
		stType = stData;

		arrTypeList[qBBTypeLabels.currentrow] = stType;
		</cfscript>
		</cfloop>
	   </cfif>
	   <cfreturn arrTypeList>

	</cffunction>

	<cffunction name="getAnalysts" access="remote" returntype="array">
	  <cfargument name="UseselectedRecords" type="boolean" required="false" default ="0" />
	  <cfargument name="selectedRecords" type="string" required="false" default ="" />

	   <cfset arrAnalyst =  ArrayNew(1)>

	 <!--- For the default query of all analyst OR If selected analyst are being passed to the query --->
	 <cfif UseselectedRecords eq 0 OR selectedRecords neq "">

		<cfset oBillbackAssignmentManager = CreateObject("component", "components.billback.BillbackAssignmentManager") />
		<!--- 28389: BB Flex Search - sort user names by First name(A to Z)/Anand Rao/06-Jan-2012
				- changed from Name_Last to Name_First	--->
		<cfset qgetAnalysts = oBillbackAssignmentManager.getAnalysts(sortBy = "Name_First",sourceCaller="FLEXBB") />


	   <cfloop query="qgetAnalysts">
	   <!--- selected analyst are being passed to the query --->
		<cfif UseselectedRecords eq 0 OR ListFind(selectedRecords,qgetAnalysts.User_ID_Int) neq 0>
		<cfscript>
		stAnalystUser = structNew();
		stData = structNew();
		stData["__type__"] = "mvc.Models.Entity.vos.User";
		stData["id"] = qgetAnalysts.Analyst_User_ID;
		stData["idInt"] = qgetAnalysts.User_ID_Int;
		stData["fullName"] = qgetAnalysts.Name_First & ' ' & qgetAnalysts.Name_Last;
		stAnalystUser = stData;

		arrAnalyst[qgetAnalysts.currentrow] = stAnalystUser;
		</cfscript>
		</cfif>
		</cfloop>

	  </cfif>
		<cfreturn arrAnalyst>

	</cffunction>

	<cffunction name="getBBAmountTypes" access="public" returntype="Array">

		<cfset var arrBBAmountTypes = ArrayNew(1)>

		 <cfset arrBBAmountTypes[1] = 'Claimed'>
		 <cfset arrBBAmountTypes[2] = 'Approved'>

	   <cfreturn arrBBAmountTypes>

	</cffunction>

	<cffunction name="getBBDateTypes" access="public" returntype="Array">

		<cfset var arrBBDateTypes = ArrayNew(1)>

		<cfset stBBLabels = getBBLabels()>

		 <cfset arrBBDateTypes[1] = '#stBBLabels.Billback#'>
		 <cfset arrBBDateTypes[2] = 'Start'>
		 <cfset arrBBDateTypes[3] = 'End'>
		 <cfset arrBBDateTypes[4] = 'Create'>
		 <cfset arrBBDateTypes[5] = 'RFA'>
		 <cfset arrBBDateTypes[6] = 'Approved'>
		 <cfset arrBBDateTypes[7] = 'Paid'>

	   <cfreturn arrBBDateTypes>

	</cffunction>

	<cffunction name="getHistoryTypes" access="public" returntype="Array">

		<cfset var arrHistoryTypes = ArrayNew(1)>

		 <cfset arrHistoryTypes[1] = 'Created By'>
		 <cfset arrHistoryTypes[2] = 'RFA By'>
		 <cfset arrHistoryTypes[3] = 'Approved By'>
		 <cfset arrHistoryTypes[4] = 'Disagreed By'>
		 <cfset arrHistoryTypes[5] = 'Reset By'>

	   <cfreturn arrHistoryTypes>

	</cffunction>

	<cffunction name="getCriteriaTypes" access="public" returntype="Array">

		<cfset var arrCriteriaTypes = ArrayNew(1)>

		 <cfset arrCriteriaTypes[1] = '='>
		 <cfset arrCriteriaTypes[2] = '<='>
		 <cfset arrCriteriaTypes[3] = '>='>

	   <cfreturn arrCriteriaTypes>

	</cffunction>

	<cffunction name="getEntityTypes" access="public" returntype="Array">

		<cfset var arrEntityTypes = ArrayNew(1)>

		<cfset stBBLabels = getBBLabels()>

		 <cfset arrEntityTypes[1] = application.returned_customer_setting.distributor_label_singular>
		 <cfset arrEntityTypes[2] = application.returned_customer_setting.operator_label_singular>
		 <cfset arrEntityTypes[3] = '#stBBLabels.Vendor#'>
		 <cfset arrEntityTypes[4] = application.returned_customer_setting.broker_label_singular>

	   <cfreturn arrEntityTypes>

	</cffunction>


	<cffunction name="getUsers" output="false" access="public" returntype="array">
	  <cfargument name="UseselectedRecords" type="boolean" required="false" default ="0" />
	  <cfargument name="selectedRecords" type="string" required="false" default ="" />
	  <cfargument name="BBUsersViewCreateOnly" type="boolean" required="false" default ="0" />

	   <cfset arrUsers = ArrayNew(1)>

	<!--- For the default query of all users OR If selected users are being passed to the query --->
	<cfif UseselectedRecords eq 0 OR selectedRecords neq "">

  	  <cfquery name="qgetUsers" datasource="#application.datasource#" cachedwithin="#APPLICATION.userDataCacheSpan#">
	   SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		<!--- FullName is sent as FullName(User_Code) format --->
  		SELECT	_Users.Name_First + ' ' +  _Users.Name_Last + '(' + _Users.User_Code + ')' As FullName,_Users.Sales_Person_ID As User_ID_Int
  		FROM	_Users
		<!---
				D32712: BB Search Screen - Need filter/Anand Rao/26-Jun-2012
			  	when the user passes the argument then return only the user that can create/view BB set in the profiles.
		--->
		<cfif arguments.BBUsersViewCreateOnly EQ 1>
			INNER JOIN BB_Profiles_Settings BBPS ON BBPS.Profiles_ID = _Users.Profiles_ID AND BBPS.Deleted = 0 AND BBPS.BB_Create = 1
		</cfif>
  		WHERE _Users.Deleted = 0
		AND Len(_Users.Name_First) > 0
		AND Len(_Users.Name_Last) > 0
		AND Len(_Users.User_Code) > 0
		 <!--- selected users are being passed to the query --->
		<cfif selectedRecords neq "">
		  AND Sales_Person_ID IN (#selectedRecords#)
		 </cfif>
  		ORDER BY _Users.Name_First
  	   </cfquery>

		<cfloop query="qgetUsers">
		<cfscript>
		stUser = structNew();
		stData = structNew();
		stData["__type__"] = "mvc.Models.Entity.vos.User";
		stData["id"] = "";
		stData["idInt"] = qgetUsers.User_ID_Int;
		stData["fullName"] = qgetUsers.FullName;
		stUser = stData;

		arrUsers[qgetUsers.currentrow] = stUser;
		</cfscript>
		</cfloop>

		</cfif>
	  <cfreturn arrUsers />

	</cffunction>

	<cffunction name="getActionTypes" access="public" returntype="Array">

		<cfset var arrActionTypes = ArrayNew(1)>

		<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

		 <cfset arrActionTypes[1] = 'Reset'>
		 <cfset arrActionTypes[2] = 'Delete'>
		 <cfset arrActionTypes[3] = 'Reassign'>
		<cfif Get_Profile_Settings.BB_Mass_Approve eq 1>
		 <cfset arrActionTypes[4] = 'Mass Approve'>
		</cfif>
		 <!---
		 <cfset arrActionTypes[4] = 'Hold'>
		 <cfset arrActionTypes[5] = 'Release'>
		 --->

	   <cfreturn arrActionTypes>

	</cffunction>

	<cffunction name="getConditionTypes" access="public" returntype="Array">

		<cfset var arrConditionsTypes = ArrayNew(1)>

		<cfset stBBLabels = getBBLabels()>

		 <cfset arrConditionsTypes[1] = 'Doc attached'>
		 <cfset arrConditionsTypes[2] = 'No Doc attached'>
		 <cfset arrConditionsTypes[3] = '#stBBLabels.Deviation#'>
		 <cfset arrConditionsTypes[4] = 'Not Ack''d'>

	   <cfreturn arrConditionsTypes>

	</cffunction>

	<cffunction name="getDistinctYears" access="remote" returntype="Array">

	<cfset var arrBBDistinctYears = ArrayNew(1)>
	<!---<cfset arrBBDistinctYears[1] = 'Include Paid'>--->
		<cfquery name="qGetDistinctYears" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		select   distinct year(bb_end_date) as archive_year
		from     billback
		where  deleted = 0
		and bb_end_date IS NOT NULL
		order by year(bb_end_date) DESC
		</cfquery>

		<cfloop query="qGetDistinctYears">

			<cfset arrBBDistinctYears[qGetDistinctYears.currentrow] = archive_year>

		</cfloop>

		<cfreturn arrBBDistinctYears>
	</cffunction>

</cfcomponent>


