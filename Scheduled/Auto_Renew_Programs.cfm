<cfparam name ="url.logPunchList" default="0">

<cfset Scheduled = 1>

<cfscript>
	request.app_general_functions = CreateObject("component","components.general.General_Functions");
	request.key = request.app_general_functions.GenerateKey();
</cfscript>

<cfquery name="local.query" datasource="#application.datasource#">
	SELECT Top 1 Company_Main_ID
	FROM Company_Main
</cfquery>
<cfset request.AccessStructure.Company_Main_ID = local.query.Company_Main_ID>
<cfset request.AccessStructure.User_ID = "0000000000"><!--- D34822:Element ACCESSSTRUCTURE.USER_ID is undefined in REQUEST --->
<cfset objProgram = CreateObject("component", "components.programs.Program") />


<cfquery name="Needs_Renewal" datasource="#application.datasource#">
	SELECT 	*
	FROM 	Program_Auto_Renew
	INNER JOIN Contract_Main
	ON		Contract_Main.Contract_Main_ID = Program_Auto_Renew.Program_ID
	AND 	Contract_Main.Contract_Status_Type_IDX > 2
	AND 	Contract_Main.Deleted = 0
	AND 	Contract_Main.Auto_Renew = 1 	<!----- D10567: if the user had turned off auto renew we are not deleting from the Program_Auto_Renew table, so make sure we have auto renew on at the basic info ----->
	WHERE 	Program_Auto_Renew.Renewed = 0
	AND 	Program_Auto_Renew.deleted = 0
	AND 	Program_Auto_Renew.Active = 1
	AND 	DateDiff(d, Program_Auto_Renew.AR_Notification_Date, GetDate()) >= 0
</cfquery>

<cfset NumberUpdated = 0>
<!------ <cfdump var="#Needs_Renewal#"> ----->
<cfset programObj = CreateObject("component", "components.programs.program") />
<cfset fiscalPeriodManager = createObject('component','mvc.Models.Settings.FiscalPeriodManager') />

<cfinclude template="/get_Contact_Admin_Email_Address.cfm">
<!--- Label 36615 - The routine Assign_Budgets has been declared twice in different templates: Moved this include outside of the loop to avoid error --->
<cfinclude template="/Common_Files/Contracts/assign_budgets.cfm">

<cfloop query="Needs_Renewal">
<cftry>

	<!---sets all the stuff that contract_renewal_action needs--->
	<cf_cryp type="en" string="#Needs_Renewal.Program_ID#"  key="#request.key#">
	<cfset Program_ID_To_Replicate = Needs_Renewal.Program_ID />
	<cfset Form.IsRevisionOfExistingContract = 0 />


	<CFSTOREDPROC PROCEDURE="USP_Copy_Program" datasource="#application.datasource#">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@Program_ID_To_Replicate"		VALUE="#Program_ID_To_Replicate#">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_VARCHAR"	DBVARNAME="@New_Contract_Number"			VALUE="">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@IsRevisionOfExistingContract"	VALUE="0">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@ISROLLOVER"						VALUE="0">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@ForceFreightOnAutoCopy"			VALUE="0">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@User_Position_ID"				VALUE="0" null="true">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_VARCHAR"	DBVARNAME="@Responsible_User_ID"			VALUE="" null="true">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_VARCHAR"	DBVARNAME="@Current_User_ID"				VALUE="00000000-0000-0000-0000000000000000">
		<CFPROCPARAM TYPE="Out"	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@Contract_Main_ID"				VARIABLE="Renewed_Program_ID">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@Is_Mass_Copy"					VALUE="0">
		<CFPROCPARAM TYPE="Out"	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@Is_Group_Deal"					VARIABLE="Is_Group_Deal">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@From_EZ_Template"				VALUE="0">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@Is_AutoRenew"					VALUE="1">
	</CFSTOREDPROC>

	<cfquery name="qGetNewProgram" datasource="#application.datasource#">
		SELECT 	Contract_Number, ProgramType_ID, Fiscal_Year
		FROM 		Contract_Main
		WHERE 	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Renewed_Program_ID#">
	</cfquery>

	<cfquery name="getTemplateSettings" datasource="#application.datasource#">
		SELECT 	Program_Date_Type
		FROM 		Program_Control_Panel_Options
		WHERE 	ProgramControl_Panel_Options_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetNewProgram.ProgramType_ID#">
	</cfquery>

	<cfquery name="qAutoRenew" datasource="#application.datasource#">
		SELECT 	*
		FROM 		Program_Auto_Renew
		WHERE 	Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Program_ID_To_Replicate#">
	</cfquery>

	<cfset Form.Date_Method = 0 />
	<cfset AutoRenewRecordActive = 1 />
	<cfset Form.AR_Renewal_Type = qAutoRenew.AR_Renewal_Type />
	<cfset Form.Renewal_Lead_Time = qAutoRenew.Renewal_Lead_Time />

	<!--- Dev Note: Kal; D43268: Auto Renew changes for new enhancement - program dates as fiscal date --->
	<cfif getTemplateSettings.Program_Date_Type eq 2> 	<!--- fiscal date --->
		<!--- get the start end dates from the fiscal periods & year --->
		<cfset Form.Start_Date = fiscalPeriodManager.getFiscalDateforPeriod(
						fiscalPeriod = qAutoRenew.AR_Start_Period,
						fiscalYear = qAutoRenew.AR_Fiscal_Year,
						startEnd = "start") />

		<cfset Form.End_Date = fiscalPeriodManager.getFiscalDateforPeriod(
						fiscalPeriod = qAutoRenew.AR_End_Period,
						fiscalYear = qAutoRenew.AR_Fiscal_Year,
						startEnd = "end") />

	<cfelse>	<!--- free form date --->
		<cfset Form.Start_Date = qAutoRenew.AR_Start_Date />
		<cfset Form.End_Date = qAutoRenew.AR_End_Date />
	</cfif>

	<!--- ****** UPDATE AUTO RENEW DATES *****
		WE NO LONGER NEED THIS LOGIC AS WE ARE GETTING DATES FROM TABLE
	<!---If it's leap year, reset it--->
	<cfif DatePart('m', Form.Start_Date) IS "02" AND DatePart('d', Form.Start_Date) IS "29">
		<cfset Form.Start_Date = DatePart('yyyy', Form.Start_Date) & "-02-28">
	</cfif>
	<cfif DatePart('m', Form.End_Date) IS "02" AND DatePart('d', Form.End_Date) IS "29">
		<cfset Form.End_Date = DatePart('yyyy', Form.End_Date) & "-02-28">
	</cfif>--->

	<cfquery name="qUpdateDates" datasource="#application.datasource#">
		UPDATE	Contract_Main
		SET			Contract_Start_Date = <cfqueryparam cfsqltype="cf_sql_date" value="#Form.Start_Date#">,
						Contract_End_Date = <cfqueryparam cfsqltype="cf_sql_date" value="#Form.End_Date#">,
						Fiscal_Year = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qAutoRenew.AR_Fiscal_Year#">
		WHERE		Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Renewed_Program_ID#">
	</cfquery>

	<!--- Set values for new auto renew version --->
	<cfset stAutoRenewDates = objProgram.getAutoRenewDates(
					autoRenewType = AR_RENEWAL_TYPE,
					autoRenewalLeadTime = Renewal_Lead_Time,
					programDateType = getTemplateSettings.Program_Date_Type,
					startDate = Form.Start_Date,
					endDate = Form.End_Date) />

	<cfset New_AR_Start_Date = stAutoRenewDates.AR_Start_Date />
	<cfset New_AR_Start_Period = stAutoRenewDates.AR_Start_Period />
	<cfset New_AR_End_Date = stAutoRenewDates.AR_End_Date />
	<cfset New_AR_End_Period = stAutoRenewDates.AR_End_Period />
	<cfset New_AR_Notification_Date = stAutoRenewDates.AR_Notification_Date />
	<cfset New_AR_Fiscal_Year = stAutoRenewDates.AR_Fiscal_Year />

	<cfquery name="UpdateAutoRenewData" datasource="#application.datasource#">
		UPDATE 	Program_Auto_Renew
		SET 		AR_Notification_Date 	= '#dateFormat(New_AR_Notification_Date,"short")#',
						AR_Start_Date 				= '#dateFormat(New_AR_Start_Date,"short")#',
						AR_End_Date 					= '#dateFormat(New_AR_End_Date,"short")#',
						AR_Renewal_Type 			= '#Form.AR_Renewal_Type#',
						Active 								= '#AutoRenewRecordActive#',
						Renewal_Lead_Time 		= '#Form.Renewal_Lead_Time#',
						AR_Start_Period 			= '#New_AR_Start_Period#',
						AR_End_Period 				= '#New_AR_End_Period#',
						AR_Fiscal_Year 				= '#New_AR_Fiscal_Year#'
		WHERE 	Program_ID 						= <cfqueryparam cfsqltype="cf_sql_integer" value="#Renewed_Program_ID#">
	</cfquery>

	<cfquery name="qUpdatePerformanceMappings" datasource="#application.datasource#">
		INSERT INTO One_Program_Perf_Mapping
			(Contract_Main_ID, Program_Perf_Req_ID, Checked, Operator_Category_ID, Operator_Priority_ID, PR_Start_Date, PR_End_Date)
		SELECT	'#Renewed_Program_ID#', Program_Perf_Req_ID, Checked, Operator_Category_ID, Operator_Priority_ID, PR_Start_Date, PR_End_Date
		FROM	One_Program_Perf_Mapping
				INNER JOIN Contract_Main ON Contract_Main.Contract_Main_ID = One_Program_Perf_Mapping.Contract_Main_ID
		WHERE	Contract_Main.Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Program_ID_To_Replicate#">
	</cfquery>

	<cfoutput>
	#qGetNewProgram.Contract_Number#<hr>
	<cfset FORM.Contract_Number = qGetNewProgram.Contract_Number />
	</cfoutput>

	<!--- Dev Note: Clay : Auto Renew Errors  --->
	<cfquery name="MarkAsRenewed" datasource="#application.datasource#">
		UPDATE 	Program_Auto_Renew
		SET 		Renewed = 1
		WHERE 	Program_Auto_Renew_ID = '#Needs_Renewal.Program_Auto_Renew_ID#'
	</cfquery>

	<cfset Contract_Main_ID = renewed_program_id>
	<!------ Change the status to RFA ----->
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>

	<!--- Email to RSP or system admin BJF D9316 --->
	<cfif appSettings.getEmail_Auto_Renewed_Programs() EQ 1>

		<!----- D10567: 2. When auto renew happens if the auto renewing program has a revision in progress out there, inform the RSP via the existing email notification. ----->
		<cfquery name="qGetAutorenewRevisionsInProgress" datasource="#application.datasource#">
			SELECT	*
			FROM	Program_Auto_Renew

			INNER JOIN Contract_Main
			ON		Contract_Main.Contract_Main_ID = Program_Auto_Renew.Program_ID
			AND		Contract_Main.Deleted = 0
			AND		Contract_Main.Approved = 0
			AND		Contract_Main.Contract_Number = '#Needs_Renewal.Contract_Number#'

			WHERE	Program_Auto_Renew.Renewed = 0
			AND		Program_Auto_Renew.Deleted = 0
		</cfquery>

		<cfset NotifyReAutoRenewEmail = "">

		<cfquery name="GetRSPInfo" datasource="#application.datasource#">
				SELECT 	DISTINCT User_Email
				FROM 		_Users
				INNER JOIN User_Position_Holders
				ON 			User_Position_Holders.User_ID = _Users.User_ID
				AND 		User_Position_Holders.User_Positions_ID = '#Needs_Renewal.Creating_User_Position_ID#'
				WHERE 	_Users.User_ID = '#Needs_Renewal.Responsible_User_ID#' 	<!----- D10567: 5. Auto renew process is sending email to the creator, but it should send email to the RSP (D9316) ----->
				AND 		_Users.Deleted = 0
		</cfquery>

		<cfif GetRSPInfo.Recordcount EQ 1>
			<cfset NotifyReAutoRenewEmail = GetRSPInfo.User_Email>
		<cfelse>
			<cfset NotifyReAutoRenewEmail = Contact_Admin_Email_Address>
		</cfif>
		<CFIF FORM.ISREVISIONOFEXISTINGCONTRACT EQ 1>
			<cfset sSUBJECT		=	 "has been renewed as a revision" />
		<CFELSE>
			<cfset sSUBJECT		=	 "has been renewed -> New: "&FORM.Contract_Number />
		</CFIF>

		<!--- prevent problem in including this template more than once --->
		<cfif not (isDefined("EmailSubject") and isCustomFunction(EmailSubject))>
			<cfinclude template="/Common_Files/Programs/emailsubject.cfm"/>   <!--- 30738 --->
		</cfif>

		<CF_EMAILWRAPPER
			TO			=	"#NotifyReAutoRenewEmail#"
			FROM		=	"#Contact_Admin_Email_Address#"
			subject = "#EmailSubject(Needs_Renewal.Contract_Number, Needs_Renewal.Contract_Title, sSUBJECT)#"
			TYPE		=	"html"
			messagetype	="1"
			generatedby	="2"
			appArea			="1">

			<TABLE>
				<TR>
					<TD VALIGN="top">
						<cfoutput>
							Program [#Needs_Renewal.Contract_Number#] "#Needs_Renewal.Contract_Title#" was automatically renewed on #DateFormat(now(), "mm/dd/yyyy")#.
							The new <CFIF FORM.ISREVISIONOFEXISTINGCONTRACT EQ 1>program is a revision of the original #Needs_Renewal.Contract_Number#<CFELSE>program is: #FORM.Contract_Number#</CFIF>.
							<cfif qGetAutorenewRevisionsInProgress.recordCount>
							<BR>This program is in the process of being revised. Any changes made in that revision are not reflected in this renewal.
							</cfif>
						</cfoutput>
					</TD>
				</TR>
			</TABLE>

			<!---77408 Product Group sequencing START--->
			<cfif application.appSettingsGet.get_Setting('Product_Group_Sequencing') >
				<cfset request.AccessStructure.numberOfProductGroupLevels = 9>
			<cfelse>
				<cfset request.AccessStructure.numberOfProductGroupLevels = 3>
			</cfif>
			<!---77408 Product Group sequencing END--->

			<cfif appSettings.getSendAutoAttachments() and appSettings.getDisplayQuoteLetter() eq 0>    <!--- 30738 --->
				<!--- Tim Ford - 03/26/2013: Label 37007 - Auto Renew sending wrong program email attachments --->
				<cfset commonqueries_Called = 0>
				<!---TSF: Label 9796 --->
				<cfset CSL_Contract_Main_ID = Renewed_Program_ID>
				<cfinclude template="/common_files/contracts/commonqueries.cfm">
				<cfsavecontent variable = "EmailContents">
					<cfinclude TEMPLATE="/common_files/contracts/thin_contract_general_display.cfm">
				</cfsavecontent>

				<CF_Writing_Email_Attachment
	  				Naming_Format="AutoRenew_#Needs_Renewal.Contract_Title#"
					File_Extension="html"
					Relative_Path="\Temp_Files\Program\"
					Output_Content="#EmailContents#"
					addNewLine="No"
					Return_File_Name="fName">
				<cf_emailwrapperparam file = "#fName#" store="yes" />
			</cfif>
		</CF_EMAILWRAPPER>
	</cfif>
	<!--- END Email to RSP or system admin BJF D9316 --->

	<cfif appSettings.getStartAutoRenewAtRFA() >
		<!---35154: a.	if the program�s template has 1 budget then we pick that budget and associate it to the new auto renewed program.
								b.	if the program�s template has multiple budgets, then put the program in WIP status and make the user manually pick the budget for the program.--->

		<cfquery name="getProgramTemplateInfo" datasource="#application.datasource#">
			SELECT 	First_Parent_ID
			FROM 		Contract_Main
			INNER JOIN Program_Control_Panel_Options
			ON 			Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
			WHERE 	Contract_Main.Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Renewed_Program_ID#">
		</cfquery>

    <!---assign budgets, get the next action--->
    <cfset next_action = Assign_Budgets(program_id = renewed_program_id,
                                        Template_First_Parent_ID = getProgramTemplateInfo.First_Parent_ID)>
    <cfswitch expression="#next_action#">
      <!---there is no program budget, but the program template has budgets--->
      <cfcase value="stop">
      </cfcase>
      <!---found budget class with more than 1 budgets--->
      <cfcase value="prompt">
      </cfcase>
      <!---budget was found & assigned--->
      <cfdefaultcase>
				<cfset programObj.makeRFA(renewed_program_id, Needs_Renewal.Responsible_User_ID) />
      </cfdefaultcase>
    </cfswitch>

		<!---Sends out an email notification upon the rfa request, and at a scheduled later date--->
		<cfinclude template="/ANYTHING_AUTOMATED/EMAIL/rfa_program_emailer.cfm">
	</cfif>


	<cfif appsettings.getsend_to_sap()>
		<cfset program_id = renewed_program_id>
		<cfquery name="getUserapproved" datasource="#application.datasource#">
			SELECT 	Approved_By_User_ID
			FROM 		Contract_Main
			WHERE 	Contract_Main_ID =  <cfqueryparam value="#Renewed_Program_ID#" cfsqltype="cf_sql_integer" />
		</cfquery>
		<cfset user_id = getUserapproved.Approved_By_User_ID>
		<cfset autorenew = 1>
		<cfinclude template="/common_files/contracts/send_data_SAP.cfm">
	</cfif>

	<cfset NumberUpdated = NumberUpdated + 1>

<cfcatch type="database">
	<cfquery name="getdbName" datasource="#application.datasource#">
		SELECT DB_NAME() As DBName
	</cfquery>

	<cfset punchListTitle =  getdbName.DBName & ' Auto Renew CF job failed for contract_main_id ' & Program_ID_To_Replicate & ' as of ' & dateFormat(now(), "medium")>
	<cfset punchListDesc =  getdbName.DBName & ' Auto Renew CF job failed for contract_main_id ' & Program_ID_To_Replicate & ' renewing new contract_main_id ' & Renewed_Program_ID & ' as of ' & dateFormat(now(), "medium")>
	<cfset punchListDesc =  punchListDesc & "#chr(13)##chr(10)#" & cfcatch.message  & "#chr(13)##chr(10)#" & cfcatch.detail>

	<!--- Dev Note: (73131) - Only if the request is from the "scheduled task", create a WR.
	Note- We only create one WR per day for one program/client (KraftHeinz etc) combination. If the scheduled task for one client,
	is called more than once a day, a second WR will be created, provided the error was on another program.
	The code on the punchlist server wants a unique "punchListDesc" to createa new WR.

	If we need to create more than one WR per day for the same program/client combination, then we could  add minute/second to punchListDesc
	to make it unique.
	"999999" is just an arbitrary number being used for "Punch_List_Create_ID", as "Punch_List_Create_ID" does not accept nulls.
	--->
	<cfif url.logPunchList>
		<cfquery name="InsertToPunchlist" datasource="PunchList">
		   DECLARE
				@Server_Name varchar(50)

				SET @Server_Name = CONVERT(VARCHAR,((SERVERPROPERTY('MachineName'))))

			  INSERT INTO BA_Punch_List_Create (Punch_List_Create_ID,Server_Name, Company_Name, Punch_Title, Punch_Desc)
			  VALUES(999999,@Server_Name,'#application.returned_customer_setting.Company_Name#','#punchListTitle#','#punchListDesc#')

			  EXEC Create_Punch_List 37 <!--- 37 is the "punch list function" meaning "programs". --->
		</cfquery>
	</cfif>
	<cfrethrow>
	<cfabort>
</cfcatch>
</cftry>

</cfloop>
