<!-----------------------------------------------------------------------------

FILE NAME:		Search_Program.cfc
DESCRIPTION:	This is a component file for returning creating all the drop downs
              and returns the data for populating the datagrid in the search
              page.
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
*******************************************************************************
<Add any modifications to this file here>
*******************************************************************************

------------------------------------------------------------------------------>

<cfcomponent displayname="Search_program" hint="Main Object fro Flex based Program Scorecard Remote calls">
<!---<cfset appSettings = application.appSettingsGet />--->

  <cffunction name="getIsBestPlanOn" output="false" returntype="boolean">
	  <!---<cflog text="getAllTemplate_Fired">--->

	  <cfset local.BestPlanOn = 0>

	<cfset useLakebaseForqBestPLanprofileSetting = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profiles_settings")>
<cfif useLakebaseForqBestPLanprofileSetting>
	<cftry>
		<cfset qBestPLanprofileSetting = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profiles_settings", {
				"profiles_id" = "eq.#request.AccessStructure.Profiles_ID#",
				"deleted" = "eq.0",
				"best_plan_program" = "eq.1",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqBestPLanprofileSetting = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqBestPLanprofileSetting>
<cfquery name="qBestPLanprofileSetting" datasource="#application.datasource#">
	  SELECT 1
	  FROM Profiles_Settings
	  WHERE Profiles_ID = '#request.AccessStructure.Profiles_ID#'
	  AND deleted = 0
	  AND Best_Plan_Program = 1
	</cfquery>
</cfif>

	<cfif qBestPLanprofileSetting.recordcount GT 0>
		<cfset useLakebaseForqgetIsBestPlanOn = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForqgetIsBestPlanOn>
	<cftry>
		<cfset qgetIsBestPlanOn = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"allow_best_plan_programs" = "eq.1",
				"deleted" = "eq.0",
				"isdominant" = "eq.1",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetIsBestPlanOn = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetIsBestPlanOn>
<cfquery name="qgetIsBestPlanOn" datasource="#application.datasource#">
		SELECT 1
		FROM Program_Control_Panel_Options
		WHERE 	allow_Best_Plan_Programs = 1
		AND Deleted = 0
		AND  IsDominant = 1
		</cfquery>
</cfif>

		<cfif qgetIsBestPlanOn.recordcount GT 0>
			 <cfset local.BestPlanOn = 1>
		</cfif>

	 </cfif>
		<cfreturn local.BestPlanOn />
	</cffunction>

	<!----------------------------------------------------------------------------
    This function returns all the program templates
   ------------------------------------------------------------------------------>

  <cffunction name="getAllTemplate" output="false" access="remote" returntype="query">
	  <!---<cflog text="getAllTemplate_Fired">--->
		<cfquery name="qGetAllTemplate" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT ltrim(rtrim(Created_Type)) As Created_Type,
				First_Parent_ID
				<!---
				Generic_Type,
				ProgramControl_Panel_Options_ID,
				BidRequestStatusOn,
				BidRequestStatusChangePgmStatus
				--->
			FROM
        Program_Control_Panel_Options
			WHERE
        Deleted = 0
				AND
        IsDominant = 1
			ORDER BY
        Created_Type
		</cfquery>
		<cfreturn qgetalltemplate />
	</cffunction>

  <!----------------------------------------------------------------------------
    This function returns all the program Statuses
  ------------------------------------------------------------------------------>
  <cffunction name="getAllStatus" output="false" access="remote" returntype="query">

  <cfset var programManager = CreateObject("component", "components.programs.ProgramManager").init()>

		<cfquery name="qGetAllStatus" datasource="#application.datasource#"  cachedwithin="#APPLICATION.masterDataCacheSpan#">
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
      SELECT
      	Contract_Status_Type_ID,
        Contract_Status_Type_Desc
      FROM
      	Contract_Status_Types
      WHERE
      	Contract_Status_Type_ID <> 3
	<cfif programManager.getIsBidFeatureOn() eq 0>
	AND Contract_Status_Type_ID NOT IN (8,10)
	</cfif>
      ORDER BY
        Contract_Status_Order
    </cfquery>
		<cfreturn qgetallstatus />

	</cffunction>

 <!-----------------------------------------------------------------------------
    This function returns the program search 'current/catalog view' options
  ------------------------------------------------------------------------------>
  <cffunction name="getAllCurrentViewStatus" output="false" access="remote" returntype="query">
	<cfquery name="qGetAllCurrentViewStatus" datasource="#application.datasource#">
		SELECT Contract_Search_Options.Contract_Status_Type_ID,Contract_Status_Types.Contract_Status_Type_Desc,
		Contract_Search_Options.Contract_Status_Type_Selected
		FROM Contract_Search_Options
		LEFT JOIN Contract_Status_Types
		ON Contract_Search_Options.Contract_Status_Type_ID = Contract_Status_Types.Contract_Status_Type_ID
		ORDER BY Contract_Search_Options.Contract_Status_Order
    </cfquery>
		<cfreturn qGetAllCurrentViewStatus />

   </cffunction>

  <!----------------------------------------------------------------------------
    This function returns all the User Positions
  ------------------------------------------------------------------------------>
  <cffunction name="getAllUserPositions" output="false" access="remote" returntype="Query">
    <cfquery name="qGet_All_User_Positions" datasource="#application.datasource#">
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT	User_Positions.User_Positions_ID, LTRIM(RTRIM(User_Positions.Position_Label)) As Position_Label,
		CASE
                WHEN 	Service_Markets.Service_Market_ID IS NOT NULL
                  THEN      LTRIM(RTRIM(User_Positions.Position_Label)) + ' (' + ISNULL(LTRIM(RTRIM(Service_Markets.Market_Number)) ,' ')  + ')'
                WHEN 	Service_Regions.Service_Region_ID IS NOT NULL
                  THEN      LTRIM(RTRIM(User_Positions.Position_Label)) + ' (' + ISNULL(LTRIM(RTRIM(Service_Regions.Region_Number)) ,' ')   + ')'
                WHEN      Service_Zones.Service_Zone_ID IS NOT NULL
                  THEN      LTRIM(RTRIM(User_Positions.Position_Label)) + ' (' + ISNULL(LTRIM(RTRIM(Service_Zones.Zone_Number)) ,' ')   + ')'
		ELSE
			LTRIM(RTRIM(User_Positions.Position_Label))/* Headquarters */
		END
			AS Position_Label_And_ID

		FROM	User_Positions
		LEFT JOIN Service_Zones
		ON Service_Zones.Service_Zone_ID = User_Positions.Service_Zone_ID
		AND Service_Zones.Deleted = 0

		LEFT JOIN Service_Regions
		ON Service_Regions.Service_Region_ID = User_Positions.Service_Region_ID
		AND Service_Regions.Deleted = 0

		LEFT JOIN Service_Markets
		ON Service_Markets.Service_Market_ID = User_Positions.Service_Market_ID
		AND Service_Markets.Deleted = 0

		WHERE  len(User_Positions.Position_Label) <> 0
		AND User_Positions.Deleted = 0
		AND ( User_Positions.Service_Market_ID IS NULL OR Service_Markets.Service_Market_ID IS NOT NULL)
		AND ( User_Positions.Service_Region_ID IS NULL OR Service_Regions.Service_Region_ID IS NOT NULL	)
		AND ( User_Positions.Service_Zone_ID IS NULL OR Service_Zones.Service_Zone_ID IS NOT NULL)
	     ORDER BY Position_Label
    </cfquery>
		<cfreturn qGet_All_User_Positions />
  </cffunction>

  <!-------------------------------------------------------------------------
    This function returns all the Buying Groups
  --------------------------------------------------------------------------->
  <cffunction name="getAllBuyingGroups" output="false" access="remote" returntype="Query">
  	 <cfquery name="qGetAllBuyingGroups" datasource="#application.datasource#" cachedwithin="#APPLICATION.masterDataCacheSpan#">
	 SELECT LTRIM(RTRIM(Buying_Group_Name)) As Buying_Group_Name, Buying_Group_ID
  	 FROM Distributor_Buying_Groups
  	 WHERE Deleted = 0
  	 AND	Active_Code = 'A'
  	 AND Buying_Group_Name<> ''
  	 ORDER BY Buying_Group_Name
  	</cfquery>
		<cfreturn qgetallbuyinggroups />
	</cffunction>

  <!---------------------------------------------------------------------------
    This function returns all the Family Names
  ----------------------------------------------------------------------------->
  <cffunction name="getAllFamilyNames" output="false" access="remote" returntype="Query">
  	<cfquery name="qGetAllFamilyNames" datasource="#application.datasource#" cachedwithin="#APPLICATION.masterDataCacheSpan#">
  		SELECT LTRIM(RTRIM(Family_Name)) As Family_Name,Family_ID
  		FROM Distributor_Family
  		WHERE Deleted = 0
  		AND Family_Name <> ''
  		ORDER BY Family_Name
  	</cfquery>
		<cfreturn qgetallfamilynames />
	</cffunction>

  <!---------------------------------------------------------------------------
    This function returns all the Users and Positions
  ----------------------------------------------------------------------------->
  <cffunction name="getUsersAndPositions" output="false" access="remote" returntype="Query">
  	<cfquery name="qGetUsersAndPositions" datasource="#application.datasource#" cachedwithin="#APPLICATION.userDataCacheSpan#">
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
  		SELECT	User_Position_Holders.User_Positions_ID, _Users.Name_First + ' ' +  _Users.Name_Last AS User_Name,
		_Users.Sales_Person_ID, _Users.Is_Eligible_RSP, _Users.User_ID
  		--User_Positions.Position_Label
  		FROM	_Users
  				INNER JOIN User_Position_Holders
  				ON
  				User_Position_Holders.User_ID = _Users.User_ID
  				AND
  				User_Position_Holders.Deleted = 0
  				AND User_Position_Holders.User_Position_Type = 'P'
  				--INNER JOIN User_Positions
  				--ON User_Position_Holders.User_Positions_ID = User_Positions.User_Positions_ID
  		WHERE
  				_Users.Deleted = 0
  				AND
  				Len(_Users.Name_First) > 0
  				AND
  				Len(_Users.Name_Last) > 0
      	<!---Don't show BSA users
      	<cfif appSettings.getHide_BSA_Users() IS 1 AND request.AccessStructure.User_Rights_ID NEQ 9999>
      	AND (_Users.User_Rights_ID IS NULL
      	OR _Users.User_Rights_ID != 9999)
      	</cfif> --->
  		ORDER BY _Users.Name_First
  	</cfquery>
	  <cfreturn qgetusersandpositions />
	</cffunction>

 <!-----------------------------------------------------------------------------
    This function returns the budget classes
  ------------------------------------------------------------------------------>
  <cffunction name="getBudgetClasses" output="false" access="remote" returntype="query">
	<cfquery name="qgetBudgetClasses" datasource="#application.datasource#">
	DECLARE @FY int
	SELECT      @FY = Replace(fy.Fiscal_Year, 'FY_', '')
	FROM  Fiscal_Year fy
	WHERE GETDATE() between fy.Start_Date AND fy.End_Date

	SELECT DISTINCT bc.Budget_Class_Desc
		,bc.Budget_Class_ID
	FROM  Budget b
	INNER JOIN Budget_Class bc
	ON          b.Budget_Class_ID = bc.Budget_Class_ID
	WHERE b.Deleted = 0
	AND         b.Active = 1
	AND         ((bc.Is_Fiscal = 1 AND ABS(Replace(bc.Year_Selection, 'FY_', '') - @FY) <= 2) -- (Fiscal year entries) +/- 2 years
		    OR
		    (bc.Is_Fiscal = 0 AND ABS(Replace(bc.Year_Selection, 'FY_', '') - Year(GetDate())) <= 2) -- (Calendar year entries) +/- 2 years
		    )
	ORDER BY bc.Budget_Class_Desc
	</cfquery>
		<cfreturn qgetBudgetClasses />
   </cffunction>

  <!---------------------------------------------------------------------------
    This function returns the business segments
  ----------------------------------------------------------------------------->
  <cffunction name="getBusinessSegments" output="false" access="remote" returntype="query">
      <cfset var businesssegmenton = getbusinesssegmentsetting()>

		<cfquery name="qgetBusinessSegments" datasource="#application.datasource#">
			SELECT DISTINCT Business_Segment.Business_Segment_ID, Business_Unit_ID, Business_Unit_Desc
			FROM Business_Segment
			WHERE Active = 1 AND Deleted = 0
			<!--- If the "Business segment" is OFF, do not return any records. --->
			<cfif businesssegmenton eq 0>
			AND 1 = 0
			</cfif>
			ORDER BY Business_Unit_Desc
		</cfquery>

		<cfreturn qgetBusinessSegments />
   </cffunction>

  <!---------------------------------------------------------------------------
    This function returns the program Details for the popup
  ----------------------------------------------------------------------------->
  <cffunction name="getProgramDetails" output="false"  access="remote" returntype="Query">
    <cfargument name="Program_ID" type="numeric" required="true">
    <cfset var appsettings 		= application.oapplicationappsettingsmanager.getapplicationappsettings()>
    <!---
    <cfset var ApprovableUserList = "">
     --->

    <cfquery name="qgetProgramDetails" datasource="#application.datasource#">
	if object_id('tempdb..##tmp_Effective_Dates') is not null
	drop table ##tmp_Effective_Dates

	Create  table ##tmp_Effective_Dates
	(
	  Contract_Number varchar(50) not null,
	  Effective_Start_Date datetime,
	  Effective_End_Date datetime
	)

	<!--- Dev Note:38050 (Milan) - Get the minimum "Effective_Start_Date" and maximum "Effective_End_Date" per program (contract_number).
	Note: We need this logic for the following reason:
	When we do a price increase for a client, the affected programs get revised and the new rates are valid for the
	new revision with the start and/or end date of the revision changing based on the date when the price change needs
	to be effective. By doing this, we only show the start and end dates for the new revision on the program.
	By looking at the dates, the users do not know what is the complete date span of the program. The effective dates
	have the actual date span, provided we get the minimum effective start date and maximum effective end date. This
	way the users will see the complete start date and end date for a program and will not be revision dependant.
	On the program summary, we show show both - version dates and delivery dates.
	--->
	<cfif appSettings.getProgram_search_dates()>
	INSERT INTO ##tmp_Effective_Dates(Contract_Number,Effective_Start_Date,Effective_End_Date)
	SELECT Contract_Main.Contract_Number, MIN(Contract_Main.Effective_Start_Date) As Effective_Start_Date,
	MAX(Contract_Main.Effective_End_Date) As Effective_End_Date
	FROM Contract_Main
	WHERE Contract_Main.Approved = 1
	AND Contract_Main.effective_start_date IS NOT NULL
	AND Contract_Main.effective_end_Date IS NOT NULL
	GROUP BY Contract_Main.Contract_Number
	</cfif>

    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SELECT CM.Contract_Main_ID, Replace(CM.Contract_Number, '000-', '') + (CASE WHEN CM.Contract_Status_Type_IDX > 2 THEN '-' + CASE
																																		WHEN LEN(CM.revision_version) = 4 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 4)
																																		WHEN LEN(CM.revision_version) = 5 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 5)
																																		ELSE RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 3)
																																	END ELSE '' END) as contract_number,
		CM.contract_title,
		CM.contract_title,cast(convert(varchar(50), CM.contract_start_date, 101) + ' - ' + convert(varchar(50), CM.contract_end_date, 101) As varchar(50)) As date_span,
		<!--- Note: "##tmp_Effective_Dates" is populated only when "appSettings.getProgram_search_dates" is set to 1.	Even then, "##tmp_Effective_Dates"
		will not be populated for all programs.
		--->
		cast
		(
		<!--- When it is null, send blank, so that flex can understabd it as blank --->
		IsNull(
		convert(char(10),##tmp_Effective_Dates.Effective_Start_Date,101)
		+ ' - ' +
		<!--- Note: "##tmp_Effective_Dates" is populated only when "appSettings.getProgram_search_dates" is set to 1.	Even then, "##tmp_Effective_Dates"
		will not be populated for all programs.
		--->
		convert(char(10),##tmp_Effective_Dates.Effective_End_Date,101),'')
		As varchar(50)
		) As delivery_period_date_span,
		0 As Contract_Quantity,	UOM.Abbreviation, CMAD.Program_Spend,U1.Name_First + ' ' + U1.Name_last As Approver_User,convert(varchar(50), CM.Approval_date, 101) As Approval_Date,
    	U2.Name_First + ' ' + U2.Name_last As RFA_User,convert(varchar(50), CM.Broker_Approved_Date, 101) As Broker_Approved_Date, CM.Contract_Status_Type_IDX, CM.Responsible_User_ID,
    	Position_To_Approve.Position_Label Position_To_Approve_Label, CM.contract_reference_number,CM.Revision_of_Contract_Main_ID,CM.Is_A_Revision,
    	Business_Segment.Business_Unit_Desc,
		(SELECT LTRIM(RTRIM(Position_Label)) FROM User_Positions
		WHERE User_Positions_ID = CM.Creating_User_Position_ID
		) As RSP_Position_Label,
		U6.Name_First + ' ' + U6.Name_last As Responsible_Sales_Person,
    	CASE CM.Contract_Is_Locked
    		WHEN 1
    			THEN U3.Name_First + ' ' + U3.Name_last
    		ELSE ''
    	END
    	 As Locked_By,
    	CASE CM.modifying_program
    		WHEN 1
    			THEN U5.Name_First + ' ' + U5.Name_last
    		ELSE ''
    	END
    	 As Modifying_User,
    	CASE
    		WHEN CM.Cancelled_Date ! = ''
    			THEN  U4.Name_First + ' ' + U4.Name_last + ' ' + convert(varchar(50), CM.Cancelled_Date, 101)
    		ELSE ''
    	END
    	  As Cancelled_By
    	<!--- If the appsetting allows for viewing requester/approver position on the scorecard and
    		  the program is approved --->
    	<cfif appsettings.get_requester_approver_position()> <!---AND this.search.scorecardStatus GTE 4--->
    		,User_Positions.Position_Label As Position_Approved_Label
		<cfelse>
			,'' As Position_Approved_Label
    	</cfif>
	<!--- Dev Note:38050 (Milan) - The "effective date" logic will not be used here as the below dates are being used for volume. --->
    	, CM.Contract_Start_Date, CM.Contract_End_Date, CM.Contract_Quantity_UOM_IDX <!---D36174 Program volume --->
		<!--- D37069 :: View Programs - Cases and Dollars for all effective versions START --->
		, CM.Contract_Number AS  ContractNumber
		,0 AS Total_Contract_Quantity
		,CM.Planner_ID  AS Planner_ID
    	<!--- D37069 :: View Programs - Cases and Dollars for all effective versions END --->
		,CM.Planner_ID
    	FROM contract_main CM
    	INNER JOIN Units_of_Measure UOM
    	ON CM.Contract_Quantity_UOM_IDX = UOM.Unit_Of_Measure_ID
    	INNER JOIN Contract_Main_Aux_Data CMAD
    	ON CM.Contract_Main_ID = CMAD.Contract_Main_ID
    	LEFT JOIN _Users U1
    	ON CM.Approved_By_User_ID = U1.User_ID
    	LEFT JOIN _Users U2
    	ON CM.Broker_User_ID = U2.User_ID
    	LEFT JOIN _Users U3
    	ON CM.Contract_Locked_By_User_ID = U3.User_ID
    	LEFT JOIN _Users U4
    	ON CM.Cancelled_By = U4.User_ID
    	LEFT JOIN _Users U5
    	ON CM.modifying_user_id = U5.User_ID
		LEFT JOIN _Users U6
		ON CM.Responsible_User_ID = U6.User_ID
    	LEFT JOIN Business_Segment
    	ON Business_Segment.Deleted = 0
    	AND Business_Segment.Business_Segment_ID = CM.Business_Segment_ID
    	LEFT JOIN User_Positions Position_To_Approve
    	ON 	Position_To_Approve.User_Positions_ID =
    	(
    	SELECT	TOP 1 User_positions_ID
    	FROM	Program_Approvable_Profiles
    	WHERE	Program_Approvable_Profiles.Contract_Main_ID = CM.Contract_Main_ID
    	)
    	<!--- If the appsetting allows for viewing requester/approver position on the scorecard and
    		  the program is approved --->
    	<cfif appsettings.get_requester_approver_position()>
    	LEFT JOIN  User_Position_Holders
    	ON
    		CM.Approved_By_User_ID = User_Position_Holders.User_ID
    		AND User_Position_Type = 'P'
    		AND User_Position_Holders.Deleted = 0
    	LEFT JOIN User_Positions
    	ON
    		User_Positions.User_Positions_ID = User_Position_Holders.User_Positions_ID
    	AND User_Positions.deleted = 0
    	</cfif>

	LEFT JOIN ##tmp_Effective_Dates
	ON ##tmp_Effective_Dates.Contract_Number = CM.Contract_Number

    	WHERE CM.Contract_Main_ID =	'#arguments.Program_ID#'
    	</cfquery>
      <!---
    	<cfloop query="qgetProgramDetails">
    		<cfif Contract_Status_Type_IDX eq 2>
    			<cfset ApprovableUserList = getApprovableUserList(arguments.Program_ID,)>
    		</cfif>
    	</cfloop>
      --->


 <!---D36174 Program volume --->
		<CFQUERY NAME="Get_Settings" datasource="#application.datasource#">
				SELECT	 Volume_UOT_ID
				FROM	_Users_Settings
				WHERE User_ID		=		'#request.AccessStructure.Company_Main_ID#'
		</CFQUERY>

		<cfset program_Span = Datediff('d',qgetprogramdetails.Contract_Start_Date, qgetprogramdetails.Contract_End_Date) + 1>
		<cfset ProgVolQty 	= CreateObject("component", "components.programs.volume.ProgramVolume").getProgramQty(arguments.Program_ID, program_Span, Get_Settings.Volume_UOT_ID) />

		<cfif qgetprogramdetails.Contract_Quantity_UOM_IDX EQ 2>
				<cfset qgetprogramdetails.Contract_Quantity =  ProgVolQty.ProgramQtglbs>
		<cfelse>
				<cfset qgetprogramdetails.Contract_Quantity =  ProgVolQty.ProgramQtgCases>
		</cfif>
<!--- D36174 Program volume --->

		<!--- D37069 :: View Programs - Cases and Dollars for all effective versions START --->
		<cfset ProgTotalVolQty 	= CreateObject("component", "components.programs.volume.ProgramVolume").getTotalProgramQty(qgetProgramDetails.ContractNumber,  Get_Settings.Volume_UOT_ID) />

		<cfif qgetprogramdetails.Contract_Quantity_UOM_IDX EQ 2>
				<cfset qgetprogramdetails.Total_Contract_Quantity =  ProgTotalVolQty.ProgramQtglbs>
		<cfelse>
				<cfset qgetprogramdetails.Total_Contract_Quantity =  ProgTotalVolQty.ProgramQtgCases>
		</cfif>
		<!--- D37069 :: View Programs - Cases and Dollars for all effective versions END --->

    <cfreturn qgetprogramdetails />
  </cffunction>

  <cffunction name="getBusinessSegmentSetting" output="false" returntype="boolean" access="remote">
	  <cfset var businesssegmentson = 0 />
		<cfset businesssegmanager = createobject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<cfif businesssegmanager.isenabled()>
			<cfset businesssegmentson = 1 />
		</cfif>
	  <cfreturn businesssegmentson>
  </cffunction>

  <cffunction name="getApprovableUserList" output="false" returntype="query" access="remote">
		<cfargument name="Program_ID" type="string" required="true">
  		<cfargument name="Responsible_User_ID" type="string" required="true">
  			<cfset var programmanager = createobject("component", "components.programs.ProgramManager").init() />
			 <cfset var businesssegmenton = getbusinesssegmentsetting()>

	    <cfset var businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
	    <cfset var businessSegmentsOn = 0>
    	<cfif businessSegManager.isEnabled()>
		  	<cfset businessSegmentsOn = 1 />
	    </cfif>


    <cfset qgetapprovableusers = programmanager.getapprovableusers(arguments.program_id,BusinessSegmentOn,arguments.responsible_user_id) />

    <cfreturn qgetapprovableusers>
  </cffunction>

  <cffunction name="getProgramAutoRenewInfo" output="false" access="remote" returntype="String">
    <cfargument name="Program_ID" type="numeric" required="true">
  	<cfset var renewal_message = "">

	  <cfset useLakebaseForIs_Auto_Renew = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForIs_Auto_Renew>
	<cftry>
		<cfset Is_Auto_Renew = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#arguments.Program_ID#",
				"select" = "auto_renew"
			}), "auto_renew"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIs_Auto_Renew = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIs_Auto_Renew>
<cfquery name="Is_Auto_Renew" datasource="#application.datasource#">
		  SELECT Auto_Renew
		  FROM Contract_Main
		  WHERE Contract_Main_ID =  '#arguments.Program_ID#'
	  </cfquery>
</cfif>

    <cfif is_auto_renew.auto_renew eq 1>
		  <cfquery name="Get_Auto_Renew_Info" datasource="#application.datasource#">
		  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
				SELECT	DATEDIFF(d, GetDate(), AR_Notification_Date) AS After_Days, AR_Notification_Date
				FROM	Program_Auto_Renew
				WHERE	Program_Auto_Renew.Renewed = 0
				AND		Program_Auto_Renew.Deleted = 0
				AND		Program_Auto_Renew.Active = 1
				AND		Program_Auto_Renew.Program_ID =  '#arguments.Program_ID#'
			</cfquery>
			<cfif get_auto_renew_info.recordcount gt 0><!----- Display will auto renew message ----->
			  <cfset auto_renew_info_available = 1 />
				<cfset ar_creation_date = get_auto_renew_info.ar_notification_date />
				<cfset ar_after_days = get_auto_renew_info.after_days />
				<cfif ar_after_days lte 0>
				  <cfset ar_creation_date = now() + 1 />
					<cfset ar_after_days = 1 />
				</cfif>
				<cfset renewal_message = "This program will be automatically renewed on #DateFormat(AR_Creation_Date, "mm/dd/yyyy")# (#AR_After_Days# day(s))">
				<cfelse>
					<cfquery name="Get_Auto_Renewed_Info" datasource="#application.datasource#">
					SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
						SELECT	Contract_Main.Contract_Number, Contract_Main.Contract_title
						FROM	Program_Auto_Renew
						INNER JOIN Contract_Main
						ON		Contract_Main.Deleted = 0
						AND		Contract_Main.Is_AutoRenew = 1
						AND		Contract_Main.Renewal_Of_Contract_main_ID = Program_Auto_Renew.Program_ID
						WHERE	Program_Auto_Renew.Renewed = 1
						AND		Program_Auto_Renew.Deleted = 0
						AND		Program_Auto_Renew.Active = 1
						AND		Program_Auto_Renew.Program_ID = '#arguments.Program_ID#'
					</cfquery>
					<cfif get_auto_renewed_info.recordcount gt 0><!----- Display already auto renewed message ----->
						<cfset renewal_message = "This program has automatically renewed to create program [#Get_Auto_Renewed_Info.Contract_Number#] #JSStringFormat(Get_Auto_Renewed_Info.Contract_title)#">
					</cfif>
				</cfif>
			</cfif>

			<cfreturn renewal_message>
		</cffunction>

  <!---------------------------------------------------------------------------
    This function returns the interface info
  ----------------------------------------------------------------------------->
	<cffunction name="getInterfaceInfo" output="false"  access="remote" returntype="String">
  	<cfargument name="Program_ID" type="numeric" required="true">
	  <cfset var appsettings 		= application.oapplicationappsettingsmanager.getapplicationappsettings()>

		<cfset var interface_message = "">
		<cfquery name="Program_Info" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT Sent_To_External_Client,error_from_external_client,Cancel_Sent_to_Client,
			Sending_To_External_Client,Unsuccessful_Ack_From_External_Client,Cancelled_Date,
			External_Client_Cancel_Ack_Date,last_extract_date,External_Client_Ack_Date,
			Unsuccessful_Ack_Reason_From_External_Client,
			Contract_Number
			FROM Contract_Main
			WHERE Contract_Main_ID =  '#arguments.Program_ID#'
		</cfquery>

		<cfset useLakebaseForGetAckIDs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("forge_erp_mapping")>
<cfif useLakebaseForGetAckIDs>
	<cftry>
		<cfset GetAckIDs = application.oLakebase.toQuery(
			application.oLakebase.selectRows("forge_erp_mapping", {
				"program_number" = "eq.#Program_Info.Contract_Number#",
				"deleted" = "eq.0",
				"select" = "deal_id"
			}), "deal_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetAckIDs = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetAckIDs>
<cfquery name="GetAckIDs" datasource="#application.datasource#">
			SELECT DISTINCT Deal_ID
			FROM Forge_ERP_Mapping
			WHERE Program_Number  = '#Program_Info.Contract_Number#'
			AND Deleted = 0
		</cfquery>
</cfif>
		<cfif (GetAckIDs.RecordCount GT 0)>
			<cfset DealIDs = Replace(ValueList(GetAckIDs.Deal_ID),",","; ","ALL") />
			<cfset SapMessage = "#chr(13)##chr(10)#Ack ID's: #DealIDs#" />
		<cfelse>
			<cfset SapMessage = "" />
		</cfif>

		<cfif appsettings.getSend_to_SAP()>
			<cfif program_info.sent_to_external_client eq 1 or program_info.error_from_external_client eq 1>
				<cfif program_info.sent_to_external_client eq 1>
					<cfset interface_message = "[This program is being sent to SAP]">
				<cfelseif program_info.error_from_external_client eq 1>
					<cfset interface_message = "[Errors in sending data to SAP]">
				</cfif>
			</cfif>
		<cfelseif program_info.cancel_sent_to_client eq 1>
			<cfset interface_message = "This program has been cancelled in ERP #chr(13)##chr(10)#Cancel Date: #Program_Info.Cancelled_Date# #chr(13)##chr(10)#Cancel Acknowledge Date: #Program_Info.External_Client_Cancel_Ack_Date#">
		<cfelseif program_info.sent_to_external_client eq 1>
			<cfset interface_message = "This program has been successfully loaded in ERP #chr(13)##chr(10)#Send Date: #Program_Info.last_extract_date# #chr(13)##chr(10)#Acknowledge Date: #Program_Info.External_Client_Ack_Date# #SapMessage#">
		<cfelseif program_info.sending_to_external_client eq 1>
			<cfset interface_message = "This program is being sent to ERP #chr(13)##chr(10)#Send Date: #Program_Info.last_extract_date# #chr(13)##chr(10)#Acknowledge Date: #Program_Info.External_Client_Ack_Date#">
		<cfelseif program_info.unsuccessful_ack_from_external_client eq 1>
			<cfset interface_message = "#Program_Info.Unsuccessful_Ack_Reason_From_External_Client#">
		</cfif>

		<cfreturn interface_message>
  </cffunction>

  <!---------------------------------------------------------------------------
    This function returns the Attachment info
  ----------------------------------------------------------------------------->
	<cffunction name="getAttachmentInfo" output="false"  access="remote" returntype="String">
		<cfargument name="Program_ID" type="numeric" required="true">
		<cfset var attachment_message = "">
		<cfquery name="Program_Info" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT Count(Attachment_ID) As AttachmentCount
			FROM Contract_Attachments
			WHERE Program_ID =  '#arguments.Program_ID#'
			AND Deleted = 0
		</cfquery>

		<cfif program_info.attachmentcount gt 0>
			<cfset attachment_message = "Document attached">
		</cfif>

		<cfreturn attachment_message>
	</cffunction>

  <!---------------------------------------------------------------------------
    This function returns the SAP Info
  ----------------------------------------------------------------------------->
	<cffunction name="getProgramSAPInfo" output="false"  access="remote" returntype="Query">
	  <cfargument name="Program_ID" type="numeric" required="true">

		<cfset saperror = querynew("pactiv_program_id,BSA_Program_Id")>
		<cfquery name="getprogramsapdetails" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			select Sent_To_External_Client,error_from_external_client,contract_status_type_idx,contract_number
			from contract_main
			where contract_main_id = #arguments.Program_ID#
		</cfquery>

		<cfif (getprogramsapdetails.sent_to_external_client eq 1 and getprogramsapdetails.error_from_external_client eq 0 and getprogramsapdetails.contract_status_type_idx eq 2) or (getprogramsapdetails.contract_status_type_idx gt 2)>
		  <cfquery name="SAPError" datasource="#application.datasource#">
  			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			select distinct Program_Webservices_Error_Detail.pactiv_program_id,Program_Webservices_Error_Detail.BSA_Program_Id
  			from
  			Program_Webservices_Error_Detail
  			INNER JOIN
  			Program_Webservices_Detail
  			ON Program_Webservices_Error_Detail.BSA_Program_Id = Program_Webservices_Detail.BSA_Program_Id
  			and Program_Webservices_Detail.deleted = 0
  			where Program_Webservices_Error_Detail.deleted = 0
  			and Program_Webservices_Detail.bsa_program_id LIKE '%#Replace(getprogramsapdetails.contract_number,"-","")#%'
  			and Program_Webservices_Error_Detail.message_type = 'S'
		  </cfquery>
		</cfif>

    	<cfreturn saperror>
	</cffunction>

  <!---------------------------------------------------------------------------
    This function returns the number of revisions for a given program
  ----------------------------------------------------------------------------->
	<cffunction name="getAreThereRevisions" output="false"  access="remote" returntype="String">
		  <cfargument name="Program_ID" type="numeric" required="true">

			<cfset var number_of_revisions = 0>

			<cfquery name="qryAreThereRevisions" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
				SELECT count(Contract_Main_ID) AS numberofrevisions
				FROM Contract_Main
				WHERE Revision_of_Contract_Main_ID = '#arguments.Program_ID#'
				AND Deleted = 0
			</cfquery>

	    <cfset number_of_revisions = qryarethererevisions.numberofrevisions>

			<cfreturn number_of_revisions>
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

	<!---------------------------------------------------------------------------
	Returns a struct of structs (settings) to flex that contains cf AppSettings:settingsService.getAppSettingsObject (generic CF appsettings),
		User:settingsService.getUserObject (sruct w/ accessstructure and profiles), and appFlex (custom app settings) objects
	--------------------------------------------------------------------------->
	<cffunction name="getSettingsObject" returntype="Struct"  access="remote">
	    <cfargument name="userId" type="string" /><!--- default="FF2AF20A-19B9-E720-22E49BCAB476054"--->
	    <cfargument name="timeZoneOffset" default="0">
        <cfargument name="useDayLightSavingsTime" type="boolean" default="0">

        <cfset var obj = "" />
        <cfset var stsettings = structnew()/>
        <cfset request.AccessStructure.Profiles_ID = val(getUserProfile('#arguments.userid#'))>

        <cfinclude template="/get_access_profile.cfm">

        <cfscript>
            // <!--- profile and user settings [empty for now] -> we may want to write and all use a common function for profile data --->
            obj             = createobject("component", "mvc.models.SettingsService");
            programmanager  = createobject("component", "mvc.Models.Program.ProgramManager").init();
            userManager     = CreateObject("component", "components.user.UserManager");
            budgetReportMgr = CreateObject("component","mvc.models.Reports.BudgetReport");
            qbudgetReport   = budgetReportMgr.getBudgetLabels();

            // <!--- These values must be used to get the correct dates in flex. Without it, the dates are shown in the user's timezone --->
            obj.setFlexClientValues(arguments.timeZoneOffset,arguments.useDayLightSavingsTime);
            stsettings.user        = structnew();
            stsettings.appflex     = structnew();
            stsettings.user        = obj.getuserobject(arguments.userid);
            stsettings.userprogram = structnew();
            stsettings.userprogram = programmanager.getProgramSettings();

            // <!--- return application.appSettingsGet as a structure with keys named the same as the appsettings methods --->
            stsettings.appsettings = structnew();

            // <!--- Other appsettings that is need for the Program search are set here --->
            appsettings = application.appsettingsget;
            uomLabel    = (application.appsettingsget.getViewProgramVolumeUOM() eq 2) ? "LBS" : "CS";

            stsettings.appflex = {
                                        cfApp_buttonHeight:         16
                                        , cfApp_comboBoxHeight:       15
                                        , cfApp_textInputHeight:      20
                                        , cfApp_comboBoxContentWidth: 440
                                        , cfapp_familylabel:          application.returned_customer_setting.family_name_label_singular
                                        , cfapp_buyinggrouplabel:     application.returned_customer_setting.buying_group_label_singular
                                        , cfapp_operatorlabel:        application.returned_customer_setting.operator_label_singular
                                        , cfapp_operatorIDlabel:      application.returned_customer_setting.operator_label_singular & " ID"
                                        , cfapp_operatorNamelabel:    application.returned_customer_setting.operator_label_singular & " Name"
                                        , cfapp_referencenumberlabel: application.returned_customer_setting.reference_number_label
                                        , cfapp_qbrandlabel:          application.returned_customer_setting.q_brand_label_singular
                                        , cfapp_typegrouplabel:       application.returned_customer_setting.type_group_label_singular
                                        , cfapp_typecodelabel:        application.returned_customer_setting.type_code_label_singular
                                        , cfapp_itemlabel:            application.returned_customer_setting.item_label
                                        , cfapp_shardshiptolabel:     application.returned_customer_setting.shard_ship_to_label
                                        , cfapp_distributorlabel:     application.returned_customer_setting.distributor_label_singular neq ""
                                                                        ? application.returned_customer_setting.distributor_label_singular
                                                                        : "Distributor"
                                        //
                                        //      All the variables are prefixed with a "cf_" so that the names are not confused with the CSV file field names
                                        //      All the Appsettings and profile settings that are requried on the page is set here.
                                        //      - Anand Rao on 11-May-09
                                        //
                                        , cfapp_deleteiscancelautorenew:          appsettings.deleteiscancelautorenew
                                        , cfapp_deleteprogrammessage:             appsettings.deleteprogrammessage
                                        , cfapp_approvalspendingcapon:            appsettings.approvalspendingcapon
                                        , cfapp_pgmscorecardrevisionreport:       appsettings.pgmscorecardrevisionreport
                                        , cfapp_sendtosap:                        appsettings.send_to_sap
                                        , cfapp_programagreeescalate:             appsettings.programagreeescalate
                                        , cfapp_approvallayeredon:                appsettings.approvallayeredon
                                        , cfapp_approvalstandardon:               appsettings.approvalstandardon
                                        , cfApp_programclaimratesreportavailable: appsettings.programclaimratesreportavailable
                                        , cfApp_showpricingreport:                appsettings.showpricingreport
                                        , cfApp_exactlistmatchingon:              appsettings.Exact_List_Matching_On
                                        , cfApp_rolloverprogramson:               appsettings.rolloverprograms_on
                                        , cfApp_pgmpostapprovalstatus:            appsettings.pgmPostApprovalStatus
                                        , cfApp_scorecardsortoption:              stsettings.userprogram.scorecard_sort_option
                                        , cfApp_scorecardsortmethod:              stsettings.userprogram.scorecard_sort_method
                                        , cfApp_displayTradeDollars:              stsettings.userprogram.display_trade_dollars
                                        , cfApp_displayPaymentDollars:            stsettings.userprogram.display_payment_dollars
                                        , cfApp_displayVolume:                    stsettings.userprogram.display_volume
                                        , cfApp_displayOperatorInfo:              stsettings.userprogram.display_operator_info
                                        , cfApp_displayTradeDollarsLabel:         application.appsettingsget.getBudgetsFunctionalityOn()
                                                                                    ? qbudgetReport.Committed_Dollar_Label
                                                                                    : "Trade $"
                                        , cfApp_displayPaymentDollarsLabel:       application.appsettingsget.getBudgetsFunctionalityOn()
                                                                                    ? qbudgetReport.Approved_Payment_Dollar_Label
                                                                                    : "Pymt $"
                                        , cfApp_BestPlanOn:                       JavaCast( "boolean",getIsBestPlanOn())
                                        , cfApp_displayVolumeLabel:               "Volume (#uomLabel#)"

                                        // "Quote letters" link should be available when 2 conditions are true:
                                        //    - "Quote letters" app setting is ON.
                                        //    - When "Letters available" app setting is set to "Custom 2". "Custom 2" is set for Hormel.
                                        , cfApp_QuoteLetters:                     (application.appSettingsGet.getDisplayQuoteLetter() AND application.appSettingsGet.getlettersavailable() eq 3)
                                                                                    ? 1
                                                                                    : 0

                                        , cfApp_ReleaseSettlement:     appsettings.ReleaseSettlement
                                        , cfApp_BusinessSegmentsLabel: appSettings.getbusiness_segment_label()
                                        , cfpro_deleteprogramaccess:   get_profile_settings.delete_program_access
                                        , cfpro_massrfaprogramapprove: get_profile_settings.mass_rfa_program_approve
                                        , cfpro_readonlycatalogaccess: get_profile_settings.read_only_catalog_access
                                        , cfpro_seeawardedincatalog:   get_profile_settings.see_awarded_in_catalog
                                        , cfpro_rfaagreed:             get_profile_settings.rfa_agreed
                                        , cfpro_searchdocuments:       Get_Profile_Settings.Search_Documents
                                        , cfpro_createProgramAccess:   get_profile_settings.Cont_Prog_View_Create_Program EQ 1 AND (appSettings.userNumberRestrict EQ 0 OR userManager.getUserNumberExists(arguments.userid) EQ 1)
                                        , cfpro_releaseSettlement:     get_profile_settings.Release_Settlement
                                        , cfApp_showbudgetDropdown:    application.appsettingsget.getBudgetsFunctionalityOn() AND get_profile_settings.Cont_Prog_View_Create_Program EQ 1
                                        , cfApp_ProgramLockTypeID:     application.appsettingsget.getProgramLockTypeID()
                                        , cfApp_businesssegmenton:     JavaCast( "boolean",getbusinesssegmentsetting())
                                };

            stsettings.appflex.cfApp_exactlistmatchingonmessage = (stSettings.appFlex.cfApp_exactlistmatchingon eq 0)
                                                                        ? " The program number should only include the middle 7 digits, ex: 1000233."
                                                                        : "";
        </cfscript>
	    <cfreturn stsettings>
    </cffunction>

	<!---Note: This function is a modified version of "GetSettingsObject" function above. This gets used for the new AG Grid program search. That one gets used
	for Flex program search.
	--->
	<cffunction name="getProgramSettingsObject" returntype="Struct"  access="public">
	    <cfargument name="userId" type="string" />
			<cfset var obj = "" />
			<cfset var stsettings = structnew()/>

			<cfset request.AccessStructure.Profiles_ID = val(getUserProfile('#arguments.userid#'))>

			<cfinclude template="/get_access_profile.cfm">

			<!--- profile and user settings [empty for now] -> we may want to write and all use a common function for profile data --->
			<cfset obj = createobject("component", "mvc.models.SettingsService") />
			<cfset programmanager = createobject("component", "mvc.Models.Program.ProgramManager").init() />
			<cfset userManager = CreateObject("component", "components.user.UserManager") />
			<cfset budgetReportMgr = CreateObject("component","mvc.models.Reports.BudgetReport") />
			<cfset qbudgetReport = budgetReportMgr.getBudgetLabels()>

			<cfset stsettings.user = structnew()/>
			<cfset stsettings.appUI = structnew()/>

			<cfset stsettings.user = obj.getuserobject(arguments.userid) />

			<cfset stsettings.userprogram = structnew()/>
			<cfset stsettings.userprogram = programmanager.getPrgSettings() />

			<!--- return application.appSettingsGet as a structure with keys named the same as the appsettings methods --->
			<cfset stsettings.appsettings = structnew()/>
			<!--- We dont require this --->
			<!---<cfset stsettings.appsettings = obj.getappsettingsobject(arguments.userid) /> --->

			<cfset stsettings.appUI = obj.getUIAttributes()>


			<!--- Other appsettings that is need for the Program search are set here --->

			<cfset appsettings = application.appsettingsget>

			<cfif application.appsettingsget.getBudgetsFunctionalityOn()>
				<cfset stsettings.tradeDollarsLabel = qbudgetReport.Committed_Dollar_Label>
				<cfset stsettings.paymentDollarsLabel = qbudgetReport.Approved_Payment_Dollar_Label>

				<cfset stsettings.tradeDollarsLabel = qbudgetReport.Committed_Dollar_Label>
				<cfset stsettings.paymentDollarsLabel = qbudgetReport.Approved_Payment_Dollar_Label>
			<cfelse>
				<cfset stsettings.tradeDollarsLabel= "Trade $">
				<cfset stsettings.paymentDollarsLabel = "Pymt $">

				<cfset stsettings.tradeDollarsLabel = "Trade $">
				<cfset stsettings.paymentDollarsLabel = "Pymt $">
			</cfif>

			<cfif application.appsettingsget.getViewProgramVolumeUOM() eq 2>
				<cfset uomLabel = "LBS">
			<cfelse>
				<cfset uomLabel = "CS">
			</cfif>

			<cfset stsettings.volumeLabel = "Volume (#uomLabel#)">

			<cfset stsettings.createProgramAccess   = get_profile_settings.Cont_Prog_View_Create_Program EQ 1
			AND (appSettings.userNumberRestrict EQ 0 OR userManager.getUserNumberExists(arguments.userid) EQ 1) />

			<cfif appsettings.Exact_List_Matching_On eq 0>
				<cfset stSettings.exactlistmatchingonmessage ="The program number should only include digits from the middle 7 digits, e.g. 1000233.">
			<cfelse>
				<cfset stSettings.exactlistmatchingonmessage ="The program number should include all the middle 7 digits, e.g. 1000233.">
			</cfif>

			<cfset stsettings.showbudgetDropdown = application.appsettingsget.getBudgetsFunctionalityOn() AND get_profile_settings.Cont_Prog_View_Create_Program EQ 1  />
			<cfset stsettings.businesssegmenton = getbusinesssegmentsetting()>

			<cfset stsettings.BestPlanOn = getIsBestPlanOn() />

	   <cfreturn stsettings>

	</cffunction>

	<cffunction name="getIsBidRequest" output="false" returntype="Boolean" access="remote">

		<CFSET var showPendingAccept = 0>
		<cfquery name="qGetIsBidRequest" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT 	Count(ProgramControl_Panel_Options_ID) As BidRequestTemplateCount
			FROM	Program_Control_Panel_Options
			WHERE 	Deleted = 0
			AND		IsDominant = 1
			AND		BidRequestStatusOn = 1
			AND		BidRequestStatusChangePgmStatus = 1
		</cfquery>

			<cfif qGetIsBidRequest.BidRequestTemplateCount GT 0>
				<cfset showPendingAccept = 1>
			</cfif>

		<cfreturn showPendingAccept>
	</cffunction>

	<!--- This function is used by Adobe Flex program search --->
	<cffunction name="SetDeleteProgram" output="false"  access="remote" returntype="Array">
		<cfargument name="Program_ID" type="String" required="true">
		<cfargument name="User_ID" type="string" required="true">

		<cfset var arrShowMsg = ArrayNew(1)>
		<cfset var showMsg = "">
		<cfset var programId = arguments.Program_ID>
		<cfset var program = CreateObject("component", "components.programs.program") />
		<cfset var qProgram = program.getProgramInfo(programId) />
		<cfset var programDesc = "[#qProgram.Contract_Number#] #qProgram.Contract_Title#" />

		<!------ lock the program ----->
		<cfset var lockReturnValue = program.setLockStatus(programId, 1, arguments.User_ID) />
			<cfif lockReturnValue EQ 1>

				<!------ delete program ----->
				<cfset deleteProgramId = programId>
				<cfset request.AccessStructure.User_ID = arguments.User_ID>
					<cfsilent>
					<cfinclude template="/scorecard/delete_program_common.cfm">
					</cfsilent>

				<cfif deleteSuccess>
						<cfset showMsg = "Program #programDesc# has been deleted successfully" />
				<cfelse>
						<cfset showMsg = "Program #programDesc# could not be deleted" />
				</cfif>

				<cfset program.setLockStatus(programId, 0)>

			<cfelseif lockReturnValue EQ 2>
					<cfset showMsg = "Program not found" />
			<cfelseif lockReturnValue EQ 3>
					<cfset showMsg = "This program #programDesc# is locked by someone else" />
			</cfif>

				<cfset arrShowMsg[1] = lockReturnValue>
				<cfset arrShowMsg[2] = showMsg>

			<cfreturn arrShowMsg>
	</cffunction>

	<!--- This function is used by AG Grid program search --->
	<cffunction name="deleteProgram" output="false"  access="remote" returnFormat="json">
		<cfargument name="program_id_list" type="String" required="true">

		<cfset var arrPrograms = listToArray(arguments.program_id_list)>
		<cfset var arrShowMsg = ArrayNew(1)>
		<cfset var stReturnMsg = StructNew()>
			<cfloop from="1" to="#ArrayLen(arrPrograms)#" index="i">
				<cfset var stShowMsg = StructNew()>
				<cfset var showMsg = "">
				<cfset var programId = arrPrograms[i]>
				<cfset var program = CreateObject("component", "components.programs.program") />
				<cfset var qProgram = program.getProgramInfo(programId) />
				<cfset var programDesc = "[#qProgram.Contract_Number#]" />
				<cfset var deleteSuccess = 0 />

				<cfset var lockReturnValue = program.setLockStatus(programId, 1, request.AccessStructure.User_ID) />
					<cfif lockReturnValue EQ 1>

						<!--- delete program --->
						<cfset deleteProgramId = programId>
							<cfsilent>
							<cfif request.AccessStructure.User_ID neq "" AND (qProgram.Contract_Status_Type_IDX EQ 1 OR qProgram.Contract_Status_Type_IDX EQ 2)>
								<cfinclude template="/scorecard/delete_program_common.cfm">
							</cfif>
							</cfsilent>

						<cfif deleteSuccess>
								<cfset showMsg = "Program #programDesc# has been deleted successfully" />
						<cfelse>
								<cfset showMsg = "Program #programDesc# could not be deleted" />
						</cfif>

						<cfset program.setLockStatus(programId, 0)>

					<cfelseif lockReturnValue EQ 2>
							<cfset showMsg = "Program #programDesc# not found" />
					<cfelseif lockReturnValue EQ 3>
							<cfset showMsg = "This program #programDesc# is locked by someone else" />
					</cfif>

						<cfset stShowMsg.lock_return_value = lockReturnValue>
						<cfset stShowMsg.show_msg = showMsg>
						<cfset ArrayAppend(arrShowMsg,stShowMsg)>
			</cfloop>
					<cfset stReturnMsg.returnMsg = arrShowMsg>

					<cfset stReturnMsg = serializeJSON(stReturnMsg, "struct")>

			<cfreturn stReturnMsg>
	</cffunction>

	<cffunction name="getGLAccount" returntype="String" access="remote">
	    <cfargument name="Program_ID" type="numeric" required="true">

		<cfquery name="qrygetGLAccount" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			DECLARE  @GL_Account varchar(max),
			             @GL_Account_On bit


			SELECT  @GL_Account_On = GL_Account_On
			FROM   _Application_Settings

			IF @GL_Account_On = 1
			BEGIN

			SELECT @GL_Account = @GL_Account + ' ' + RTRIM(GL_Account.GL_Account)
			FROM Program_Fixed_Component
			INNER JOIN GL_Account
			ON Program_Fixed_Component.GL_Account_ID = GL_Account.GL_Account_ID
			WHERE Program_Fixed_Component.Program_ID = '#arguments.Program_ID#'
			AND Program_Fixed_Component.Deleted = 0



			SELECT @GL_Account = @GL_Account + ' ' + RTRIM(GL_Account.GL_Account)
			FROM Program_Rebates_Component
			INNER JOIN GL_Account
			ON Program_Rebates_Component.GL_Account_ID = GL_Account.GL_Account_ID
			WHERE Program_Rebates_Component.Program_ID = '#arguments.Program_ID#'
			AND Program_Rebates_Component.Deleted = 0
			AND Program_Rebates_Component.GL_Account_ID NOT IN
			(

			SELECT GL_ACCOUNT_ID
			FROM Program_Fixed_Component
			WHERE Program_ID = '#arguments.Program_ID#'
			AND Deleted = 0
			)

			SELECT @GL_Account = @GL_Account + ' ' + RTRIM(GL_Account.GL_Account)
			FROM Program_Lump_Sums
			INNER JOIN GL_Account
			ON Program_Lump_Sums.GL_Account_ID = GL_Account.GL_Account_ID
			WHERE Program_Lump_Sums.Program_ID = '#arguments.Program_ID#'
			AND Program_Lump_Sums.Deleted = 0
			AND Program_Lump_Sums.GL_Account_ID NOT IN

			(

			SELECT GL_ACCOUNT_ID
			FROM Program_Fixed_Component
			WHERE Program_ID = '#arguments.Program_ID#'
			AND Deleted = 0

			UNION

			SELECT GL_ACCOUNT_ID
			FROM Program_Rebates_Component
			WHERE Program_ID = '#arguments.Program_ID#'
			AND Deleted = 0
			)



			SELECT @GL_Account = @GL_Account + ' ' + RTRIM(GL_Account.GL_Account)
			FROM Program_Growth_Components
			INNER JOIN GL_Account
			ON Program_Growth_Components.GL_Account_ID = GL_Account.GL_Account_ID
			WHERE Program_Growth_Components.Program_ID = '#arguments.Program_ID#'
			AND Program_Growth_Components.Deleted = 0
			AND Program_Growth_Components.GL_Account_ID NOT IN

			(

			SELECT GL_ACCOUNT_ID
			FROM Program_Fixed_Component
			WHERE Program_ID = '#arguments.Program_ID#'
			AND Deleted = 0

			UNION

			SELECT GL_ACCOUNT_ID
			FROM Program_Rebates_Component
			WHERE Program_ID = '#arguments.Program_ID#'
			AND Deleted = 0

			UNION

			SELECT GL_ACCOUNT_ID
			FROM Program_Growth_Components
			WHERE Program_ID = '#arguments.Program_ID#'
			AND Deleted = 0
			)
			END

			SELECT @GL_Account As GL_Account
		</cfquery>


		<cfreturn qrygetGLAccount.GL_Account>
	</cffunction>

	<!---------------------------------------------------------------------------
	Filter function for Fulltext keyword searches And/or Program status filters:
		Agreed, Pending Approval, and Under review
	--------------------------------------------------------------------------->
	<cffunction name="filterData" output="false" access="remote" returntype="Struct">
		<cfargument name="DistString" required="true" default="" />
		<cfargument name="OprString" required="true" default="" />
		<cfargument name="ItemString" required="true" default="" />
		<cfargument name="prgStatus" required="true" default="" />
		<cfargument name="userId" type="string" required="true" />
		<cfargument name="BuyingGroup" type="string" default="" required="true" />
		<cfargument name="Family" type="string" default="" required="true" />
		<!--- "SalesPersonID" is the incremental integer in the "_Users" table --->
		<cfargument name="selectedSalesPersonID" default="" required="false" />
		<cfargument name="selectedUserPositionID" default="" required="false" />
		<cfargument name="selectedAction" type="string" default="" required="false" />
		<cfargument name="budgetClassIDList" type="string" default="" required="false" />

		<cfset var Budget_ProgramsForUser = 0>
		<cfset var CRA_ProgramsForUser = 0>
		<!--- Return programs where the selected user is the CRA. --->
		<cfif (arguments.selectedAction eq "CRA" AND (Left(arguments.selectedSalesPersonID, 8) neq "Show All" OR Left(arguments.selectedUserPositionID, 8) neq "Show All"))>
			<cfset CRA_ProgramsForUser = 1>
			<cfif Left(arguments.selectedSalesPersonID, 8) neq "Show All">
				<cfset useLakebaseForgetUserID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetUserID>
	<cftry>
		<cfset getUserID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"sales_person_id" = "eq.#arguments.selectedSalesPersonID#",
				"select" = "user_id"
			}), "user_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserID>
<cfquery name="getUserID" datasource="#application.datasource#">
					SELECT 	User_ID
					FROM _Users
					WHERE Sales_Person_ID = #arguments.selectedSalesPersonID#
				</cfquery>
</cfif>
			<cfelse>
				<cfset getUserID.User_ID = "">
			</cfif>

			<cfif Left(arguments.selectedUserPositionID, 8) eq "Show All">
				<cfset arguments.selectedUserPositionID = 0>
			</cfif>
		</cfif>

		<!--- Return programs where the selected "budget classes" are associated to the programs. --->
		<cfif Len(arguments.budgetClassIDList) GT 0 AND Left(arguments.budgetClassIDList, 8) neq "Show All">
				<cfquery name="getBudgetClassID" datasource="#application.datasource#">
				SELECT  Budget_Class_ID
				FROM Budget_Class
				WHERE Budget_Class_Desc IN ( <cfqueryparam value="#arguments.budgetClassIDList#" cfsqltype="cf_sql_varchar" list="true"> )
				</cfquery>
			<cfset Budget_ProgramsForUser = 1>
			<cfset BudgetClassIDList = ValueList(getBudgetClassID.Budget_Class_ID)>
		</cfif>
     	 <!---<cfset User_ID = '#request.AccessStructure.user_id#'> --->

		<cfscript>
				var reload = 1; //used for mvc calls
				var qContractFilter = '';
				var s = structNew();
				var a = ArrayNew(1);
				var b = ArrayNew(1);
				var c = ArrayNew(1);
				var arrFilterString = ArrayNew(1);
				var arrFilterStatus = ArrayNew(1);
				var arrUnderRev = ArrayNew(1);
				var arrFilterCRA = ArrayNew(1);
				var arrFilterBudget = ArrayNew(1);
				var useStringFilter		= 0;
				var usePendingFilter	= 0;
				var useAgreedFilter		= 0;
				var useUnderReviewFilter= 0;
				var i = 0;
				var profiles_id = 0;
				profiles_id = val(getUserProfile('#arguments.userId#'));
				/*First check for keyword filters and get array of contract_main_ids that meet the keyword criteria*/
				if(arguments.DistString != '' || arguments.OprString != '' || arguments.ItemString != '' || (arguments.BuyingGroup != '' &&  Left(arguments.BuyingGroup, 8) != "Show All"  ) || (arguments.Family != '' && Left(arguments.Family, 8) != "Show All"))
					{
						/*if any keyword filters are passed, use fulltext to get array of contract_main_id that meet criteria*/
						arrFilterString = application.oController.getObject(path="mvc.Models.Program.ProgramManager",bReload= reload).fullTextProgramFilter(arguments.DistString,arguments.OprString,arguments.ItemString,arguments.BuyingGroup,arguments.Family);
						useStringFilter = 1;
					}
				/* Second check for the Program status filter and get contract_main_ids.  "Under Review" returns its own exclusion array*/
				if(arguments.prgStatus.indexOf('Pending Approval') != -1)
					{
						/*if program status filter is paseed get array of contract_main_id that are in that status*/
						arrFilterStatus = application.oController.getObject(path="mvc.Models.Program.ProgramManager",bReload= reload).getPendingApprovalPrograms(arguments.userId,profiles_Id);
						usePendingFilter = 1;
					}
				else if(arguments.prgStatus.indexOf('Agreed') != -1)
					{
						/*if program status filter is paseed get array of contract_main_id that are in that status*/
						arrFilterStatus = application.oController.getObject(path="mvc.Models.Program.ProgramManager",bReload= reload).getUserAgreedProgramsIdList(arguments.userId);
						useAgreedFilter = 1;
					}
				/*for under review get a get both Agreed and 'Pending approval' contracts*/
				else if(arguments.prgStatus.indexOf('Under Review') != -1)
					{
						/*if program status filter is paseed get array of contract_main_id that are in that status*/
						arrFilterStatus 	= application.oController.getObject(path="mvc.Models.Program.ProgramManager",bReload= reload).getUserAgreedProgramsIdList(arguments.userId);
						arrUnderRev = application.oController.getObject(path="mvc.Models.Program.ProgramManager",bReload= reload).getPendingApprovalPrograms(arguments.userId,profiles_Id);
						useUnderReviewFilter = 1;
					}

				/* CRA filter */
				if(CRA_ProgramsForUser == 1)
					{
						/* Dev Note(51678)- When searching for programs a user is responsible for approving (CRA), do not include the user position of the user. We need to retrieve all the programs
						the user is responsible for approving,regardless of the user position. The reason why a specific user position also gets passed to this function, is because in the
						"program search flex", when a user is selected from the user dropdown, the position gets automatically set to the user's primary position and when that position is passed to
						this query, it only retreives those programs,where a user is CRA for that primary position and not all positions.
						*/
						/* var qFilterCRA = CreateObject("component", "components.programs.ProgramManager").getApprovableUsers(programId=0, businessSegmentsOn=0, userID = getUserID.User_ID, userPositionsID = arguments.selectedUserPositionID); */
						var qFilterCRA = CreateObject("component", "components.programs.ProgramManager").getApprovableUsers(programId=0, businessSegmentsOn=0, userID = getUserID.User_ID);
						arrFilterCRA.AddAll(qFilterCRA[ "Contract_Main_ID" ]);

					}


				/* "Budget Classes" filter */
				if(Budget_ProgramsForUser == 1)
					{
						var qFilterBudget = application.oController.getObject(path="mvc.Models.Program.ProgramManager",bReload= reload).getProgramBudgetClasses(BudgetClassIDList);
						arrFilterBudget.AddAll(qFilterBudget[ "Contract_Main_ID" ]);

					}

				/*now decide what to return -> get the common elements from the Arrays or for under review combine 2 arrays*/
				if(useStringFilter == 1 && (usePendingFilter == 1 || useAgreedFilter == 1))
					{
						for (i = 1; i lte arraylen(arrFilterStatus); i = i + 1)
							{
								if(arrFilterString.indexOf(arrFilterStatus[i]) > -1)
									{
										ArrayAppend( a,arrFilterStatus[i] );
									}
							}
					}
				else if(useStringFilter == 1)
					{
						a = arrFilterString;
					}
				else if(usePendingFilter == 1 || useAgreedFilter == 1)
					{
						a = arrFilterStatus;
					}
				/*For 'under review' return a list of all of the 'pending approval' and 'under review' contracts*/
				else if(useUnderReviewFilter == 1)
					{
						for (i = 1; i lte arraylen(arrFilterStatus); i = i + 1)
							{
								ArrayAppend( arrUnderRev,arrFilterStatus[i] );
							}
					}

				/* If the user searches for programs where the selected user is a CRA, then filter the existing programs being returned in array "a",
				against the programs returned where selected user is a CRA. The common programs are in array "b".
				*/
				if(ArrayLen(a) > 0){
					if(CRA_ProgramsForUser == 1){
						if(ArrayLen(arrFilterCRA) > 0){
							for (j = 1; j lte arraylen(a); j = j + 1)
								{
									if(arrFilterCRA.indexOf(JavaCast( "int", a[j] )) > -1)
										{
											ArrayAppend( b,a[j] );
										}
								}
							a = b;
						}
					}
				}
				else{
					if(ArrayLen(arrFilterCRA) > 0){
						a = arrFilterCRA;
					}
				}

				/* If the user searches for programs using "budget classes", then filter the existing programs being returned in array "a",
				against the programs returned where the selected "budget classes" are associated to a program. The common programs are in array "c".
				*/
				if(ArrayLen(a) > 0){
					if(Budget_ProgramsForUser == 1){
						if(ArrayLen(arrFilterBudget) > 0){
							for (m = 1; m lte arraylen(a); m = m + 1)
								{
									if(arrFilterBudget.indexOf(JavaCast( "int", a[m] )) > -1)
										{
											ArrayAppend( c,a[m] );
										}
								}
							a = c;
						}
					}
				}
				else{
					if(ArrayLen(arrFilterBudget) > 0){
						a = arrFilterBudget;
					}
				}




				/* return a Struct w 2 arrays: F = Filter Array used as an inclusion.  U = Under Review array that is used as an exclusion list.
					Both arrays are used in the Filter function */
				s.F = a;
				s.U = arrUnderRev;
        </cfscript>

			<cfreturn s />
	</cffunction>

	<!---------------------------------------------------------------------------
	Main Query that returns data to Flex Scorecard on initial load
	--------------------------------------------------------------------------->
	<cffunction name="getScoreCardData" access="remote" returntype="query">
		<cfargument name="userid" type="string" required="true" /><!---default="D1635E3F-19B9-E720-22F5DFCEB4BD2882"--->
		<!---<cfargument name="profiles_Id" type="Numeric" required="true" /> default="35"--->
		<cfargument name="startDate" type="String"  required="false" default="" />
		<cfargument name="endDate" type="String"  required="false" default="" />
		<cfargument name="showCatalog" type="Boolean" required="true" default="0" />
		<cfargument name="Creating_User_Position" type="numeric" default="0" />
		<cfargument name="Include_work_in_progress_below_me" type="numeric" default="0" />

		<cfset var profiles_id = "">
		<cfset var TheQuery = '' />
		<cfset profiles_id = getUserProfile('#arguments.userid#')>

		<!--- Whenever a user clicks on "refresh data" from program flex, the "program scorecard" on the home page should be automatically refreshed.
		The first step is to include this file below ""/Scorecard/CF_Search_Struct.cfm".
		--->
		<cfinclude template="/Scorecard/CF_Search_Struct.cfm">

		<!--- Thiis step updates the numbers on the "program scorecard" on the home page. --->
		<cfset RefreshProgramScorecardSummary =  CreateObject("component", "components.programs.ProgramManager").getProgramScorecardSummary(stSearch, 0)>

		<cfset TheQuery = CreateObject("component", "mvc.Models.Program.ProgramManager").getPrograms(arguments.userid,profiles_Id,arguments.startDate,arguments.endDate,arguments.showCatalog,arguments.Creating_User_Position,arguments.Include_work_in_progress_below_me) />
		<cfreturn TheQuery />
	</cffunction>

	<cffunction name="getDistinctYears" access="remote" returntype="query">
		<cfquery name="qGetDistinctYears" datasource="#application.datasource#">
		<!--- Dev Note: Milan (22938). We want to show all the years --->
		<!---
		declare @Expired_Recently_Days int,
		@ArchiveDt datetime

		SELECT  @Expired_Recently_Days = Expired_Recently_Days
		FROM   _Application_Settings

		SET @ArchiveDt = DateAdd(d,-@Expired_Recently_Days,getDate())
		--->
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		select   distinct year(contract_end_date) as archive_year
		from     contract_main
		where  deleted = 0
		<!--- Temp Programs (EzButton) do not have any dates --->
		and contract_end_date IS NOT NULL
		<!--- and Contract_End_Date < @ArchiveDt --->
		order by year(contract_end_date) DESC
		</cfquery>

		<cfreturn qGetDistinctYears>
	</cffunction>

	<cffunction name="getWorkFlowData" access="remote" output="false" returntype="array">

		<cfargument name="programId" type="Numeric" required="true" />

			<cfscript>
			//set local variables
			var nProgramID			= "";
			var objWorkflow			= "";
			var qWorkflowData		= "";
			var arrRetData 			= ArrayNew(1);

			//assign local variables
			nProgramID 				= arguments.programId;

		</cfscript>

		<cfset objWorkflow = CreateObject("component", "components.workflow.WorkFlowManager") />
		<cfset qWorkflowData = objWorkflow.getWorkFlowData(nProgramID) />

		<cfoutput query="qWorkflowData">

			<cfscript>

				//build Workflow Object
				stWorkflow = structNew();

				stWorkflow["Action"] = qWorkflowData.Action;
				stWorkflow["Action_Date"] = qWorkflowData.Action_Date;
				stWorkflow["Action_Type"] = qWorkflowData.Action_Type;
				stWorkflow["Action_User_ID"] = qWorkflowData.Action_User_ID;
				stWorkflow["Authority_Sequence_Name"] = qWorkflowData.Authority_Sequence_Name;
				stWorkflow["ID"] = qWorkflowData.ID;
				stWorkflow["Name"] = qWorkflowData.Name;
				stWorkflow["Position"] = qWorkflowData.Position;
				stWorkflow["Profiles_Desc"] = qWorkflowData.Profiles_Desc;
				/*D32855: show the Agree Reasons for that user when you hover over the Agreed row. START*/
				if (qWorkflowData.Action== "Agreed")
						{
								stWorkflow["Agree_Reasons"] = getProgramAgreeReason(nProgramID,qWorkflowData.Action_User_ID);
						}
				else {
								stWorkflow["Agree_Reasons"] = ArrayNew(1);
						}
				/*D32855: show the Agree Reasons for that user when you hover over the Agreed row. END*/
				ArrayAppend(arrRetData, duplicate(stWorkflow));
			</cfscript>

		</cfoutput>

		<cfreturn arrRetData />

	</cffunction>

	<cffunction name="getNextApprovableUsers" access="remote" output="false" returntype="query">

		<cfargument name="programId" type="Numeric" required="true" />

			<cfscript>
			//set local variables
			var nProgramID					= "";
			var objWorkflowApprovableUser	= "";
			var qNextApprovableUserRet		= "";

			//assign local variables
			nProgramID 				= arguments.programId;

		</cfscript>

		<cfset objWorkflowApprovableUser = CreateObject("component", "components.workflow.WorkFlowManager") />
		<cfset qNextApprovableUserRet = objWorkflowApprovableUser.getNextApprovableUsers(nProgramID) />

		<cfreturn qNextApprovableUserRet />

	</cffunction>

	<cffunction name="getProgramAgreeReason" output="false" returntype="array">

		<cfargument name="programId"	type="Numeric" 	required="true" />
		<cfargument name="userId" 		type="string" 	required="true" />

		<cfscript>
			//set local variables
			var nProgramID				= "";
			var sUserID					= "";
			var objWorkflowAgreeReasons	= "";
			var q						= "";
			var arrRetData 				= ArrayNew(1);

			//assign local variables
			nProgramID 				= arguments.programId;
			sUserID 				= arguments.userId;
		</cfscript>

		<cfset objWorkflowAgreeReasons = CreateObject("component", "components.workflow.WorkFlowManager") />
		<cfset q = objWorkflowAgreeReasons.getProgramAgreeReason(nProgramID, sUserID) />

		<cfoutput query="q">

			<cfscript>
				ArrayAppend(arrRetData, trim(q.Agree_Reason));
			</cfscript>

		</cfoutput>

		<cfreturn arrRetData />

	</cffunction>

	<!--- get saved Search Grid column width for FLEX --->
	<cffunction name="getSearchGridColumnSize" output="false" access="remote" returntype="mvc.Models.Program.vos.SearchGridColumnSize">
		<cfargument name="userId" type="string" required="true">
		<cfset var qGetData = "">
		<cfset programmanager = createobject("component", "mvc.Models.Program.ProgramManager").init() />

		<!--- COLUMN SIZE --->
		<cfset useLakebaseForqGetData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_search_grid_column_size")>
<cfif useLakebaseForqGetData>
	<cftry>
		<cfset qGetData = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_search_grid_column_size", {
				"user_id" = "eq.#arguments.userId#",
				"select" = "user_id,status,rfa_age,program,title,type,start_date,end_date,rsp,more_info,trade_dollars,payment_dollars,volume,business_segment"
			}), "user_id,status,rfa_age,program,title,type,start_date,end_date,rsp,more_info,trade_dollars,payment_dollars,volume,business_segment"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetData>
<cfquery name="qGetData" datasource="#application.datasource#">
			SELECT  User_Id,Status,RFA_Age,Program,Title,Type,Start_Date,End_Date,RSP,More_Info,
				Trade_Dollars,Payment_Dollars,Volume,Business_Segment
			FROM  Program_Search_Grid_Column_Size
			WHERE User_Id = '#arguments.userId#'
		</cfquery>
</cfif>

		<!--- Default width based on 1024/768 resolution --->
		<cfif qGetData.recordcount eq 0>
			<cfquery name="qGetData" datasource="#application.datasource#">
				SELECT  User_Id,Status,RFA_Age,Program,Title,Type,Start_Date,End_Date,RSP,More_Info,
					Trade_Dollars,Payment_Dollars,Volume,Business_Segment
				FROM  Program_Search_Grid_Column_Size
				WHERE User_Id = '00000000-9999-9999-0000000000000000'
			</cfquery>
		</cfif>

		<cfquery name="qdropTbl" datasource="#application.datasource#">
			if object_id('tempdb..##tmp_Program_Search_Grid_Field_Include') is not null
			drop table ##tmp_Program_Search_Grid_Field_Include
		</cfquery>

		<cfquery name="qGetColumnShowHideData" datasource="#application.datasource#">
			CREATE TABLE ##tmp_Program_Search_Grid_Field_Include
			(
			Field_Name varchar(25),
			Field_Viewable bit,
			Field_Order tinyint,
			Program_Search_Grid_Field_Include_ID int
			)

			INSERT INTO ##tmp_Program_Search_Grid_Field_Include(Field_Name,Field_Viewable,Field_Order,Program_Search_Grid_Field_Include_ID)
			SELECT  Field_Name,Field_Viewable,Field_Order,Program_Search_Grid_Field_Include_ID
			FROM  Program_Search_Grid_Field_Include
			WHERE User_Id = '#arguments.userId#'

			SELECT * FROM ##tmp_Program_Search_Grid_Field_Include
			ORDER BY Program_Search_Grid_Field_Include_ID
		</cfquery>

		<cfset qPrgSettings = programmanager.getProgramLevelSettings() />

		<!--- Default HIDE//SHOW DATA. All columns are ON by default, except "contract_main_id" and  "BidRequest_Status". These colunns are
		not shown to the user, when the data loads. These columns are only visible due to certain action taken by the user on the program search grid.
		So, the value of Field_Viewable for "contract_main_id" and  "BidRequest_Status" will always be 0 (OFF).
		--->
		<cfif qGetColumnShowHideData.recordcount eq 0>
			<cfquery name="qGetColumnShowHideData" datasource="#application.datasource#">
				INSERT INTO ##tmp_Program_Search_Grid_Field_Include(Field_Name,Field_Viewable,Field_Order,Program_Search_Grid_Field_Include_ID)
				SELECT  Field_Name,Field_Viewable,Field_Order,Program_Search_Grid_Field_Include_ID
				FROM  Program_Search_Grid_Field_Include
				WHERE User_Id = '00000000-9999-9999-0000000000000000'
				ORDER BY Program_Search_Grid_Field_Include_ID

				SELECT * FROM ##tmp_Program_Search_Grid_Field_Include
			</cfquery>
		</cfif>
		<!--- We have also added the new program search (AG GRID), which uses the "Field_Order" column to order columns.
		So, when a user has saves the order of columns using AG GRID, we need to show the same order for FLEX program search as well.
		The reason is that "Program_Search_Grid_Field_Include_ID" loses it's correct order when a user saves order of columns using AG GRID.
		In the below query, we are just querying the "program" columnn, as that column will always exist in the table. Users will not turn it OFF.
		"Field_Order" will be 0 by default. Only when a user saves the COLUMN ORDER from AG Grid, will the "Field_Order" be populated.
		--->
		<cfquery name="qGetColumnOrder" datasource="#application.datasource#">
		SELECT 1
		FROM  ##tmp_Program_Search_Grid_Field_Include
		WHERE Field_Name = 'program'
		AND Field_Order = 0
		</cfquery>

		<!--- Order the data by "Field_Order" --->
		<cfif qGetColumnOrder.recordcount eq 0>
			<cfquery name="qGetColumnShowHideData" datasource="#application.datasource#">
			SELECT *
			FROM  ##tmp_Program_Search_Grid_Field_Include
			ORDER BY Field_Order
			</cfquery>
		</cfif>

		<cfset list_Include_Column_List_Order = "">
		<!--- The query data will be made an array and sent to flex in "column:showOrHide" format.
		Eg:"title:0" or "rfa:1".
		--->
		<cfloop query="qGetColumnShowHideData">
			<!--- Certain columns (tradeDollars,paymentDollars and volume) will be shown to the user, only if the setting in ON on the "program settings" page.
			If that column-level setting (application level) is ON, then we need to look at the user level setting to decide whether that column can
			be shown to the user or not. If the application level setting is OFF, then that column will not be shown to the user, regardless of user-level setting.
			--->
			<cfif qGetColumnShowHideData.Field_Name eq "tradeDollars">
				<cfif val(qPrgSettings.display_trade_dollars)>
					<cfset fieldViewable = qGetColumnShowHideData.Field_Viewable>
				<cfelse>
					<cfset fieldViewable = 0>
				</cfif>
			<cfelseif qGetColumnShowHideData.Field_Name eq "paymentDollars">
				<cfif val(qPrgSettings.display_payment_dollars)>
					<cfset fieldViewable = qGetColumnShowHideData.Field_Viewable>
				<cfelse>
					<cfset fieldViewable = 0>
				</cfif>
			<cfelseif qGetColumnShowHideData.Field_Name eq "volume">
				<cfif val(qPrgSettings.display_volume)>
					<cfset fieldViewable = qGetColumnShowHideData.Field_Viewable>
				<cfelse>
					<cfset fieldViewable = 0>
				</cfif>
			<cfelseif qGetColumnShowHideData.Field_Name eq "businessSegment">
				<cfif getbusinesssegmentsetting()>
					<cfset fieldViewable = qGetColumnShowHideData.Field_Viewable>
				<cfelse>
					<cfset fieldViewable = 0>
				</cfif>
			<cfelse>
					<cfset fieldViewable = qGetColumnShowHideData.Field_Viewable>
			</cfif>

			<cfset list_Include_Column_List_Order = ListAppend(list_Include_Column_List_Order,qGetColumnShowHideData.Field_Name & ":" & fieldViewable)>
		</cfloop>

		<cfset arrIncludeColumnList = ArrayNew(1)>

		<cfset indexCounter = 0>
		<cfloop list="#list_Include_Column_List_Order#" index="i">
			<cfset indexCounter = indexCounter + 1>
			<cfset arrIncludeColumnList[indexCounter]= i>
		</cfloop>

	   <cfscript>
		ObjPrgSearchGridColumnSize = createObject("component","mvc.Models.Program.vos.SearchGridColumnSize");

		ObjPrgSearchGridColumnSize.status = qGetData.Status;
		ObjPrgSearchGridColumnSize.rfaAge = qGetData.RFA_Age;
		ObjPrgSearchGridColumnSize.program = qGetData.Program;
		ObjPrgSearchGridColumnSize.title = qGetData.Title;
		ObjPrgSearchGridColumnSize.type = qGetData.Type;
		ObjPrgSearchGridColumnSize.startDate = qGetData.Start_Date;
		ObjPrgSearchGridColumnSize.endDate = qGetData.End_Date;
		ObjPrgSearchGridColumnSize.rsp = qGetData.RSP;
		ObjPrgSearchGridColumnSize.moreInfo = qGetData.More_Info;
		ObjPrgSearchGridColumnSize.tradeDollars = qGetData.Trade_Dollars;
		ObjPrgSearchGridColumnSize.paymentDollars = qGetData.Payment_Dollars;
		ObjPrgSearchGridColumnSize.volume = qGetData.Volume;
		ObjPrgSearchGridColumnSize.businessSegment = qGetData.Business_Segment;
		ObjPrgSearchGridColumnSize.includeColumnList = arrIncludeColumnList;
	   </cfscript>

	   <cfreturn ObjPrgSearchGridColumnSize>
	</cffunction>

	<!--- save Search Grid width values --->
	<cffunction name="saveSearchGridColumnSize" output="false" access="remote" returntype="void">
		<cfargument name="userID" required="true">
		<cfargument name="SearchGridColumnSize" required="true">

		  <cfset saveSearchGridColumnSizeData(argumentcollection='#arguments#')>
	</cffunction>

	<!--- Even though there are arguments being passed to "saveSearchGridColumnSizeData". It does not work
	  when we use "cfargument" here".
	--->
	<cffunction name="saveSearchGridColumnSizeData" output="false" access="private" returntype="void">

		<cfset var qGetData = "">
		<cfset var qSaveColumnSize = "">

		<cfquery name="qGetData" datasource="#application.datasource#">
			SELECT Count(*) As IsExistsUserEntry
			FROM  Program_Search_Grid_Column_Size
			WHERE User_Id = '#arguments.userId#'
		</cfquery>

		<!--- COLUMN SIZE --->
	  <cfif qGetData.IsExistsUserEntry eq 0>

			<cfquery name="qSaveColumnSize" datasource="#application.datasource#">
				insert into Program_Search_Grid_Column_Size
				(
				User_Id,Status,RFA_Age,Program,Title,Type,Start_Date,End_Date,RSP,More_Info,
				Trade_Dollars,Payment_Dollars,Volume,Business_Segment
				)

				values
				(
				<cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.SearchGridColumnSize.status#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.SearchGridColumnSize.rfaAge#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.SearchGridColumnSize.program#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.SearchGridColumnSize.title#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.SearchGridColumnSize.type#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.SearchGridColumnSize.startDate#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.SearchGridColumnSize.endDate#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.SearchGridColumnSize.rsp#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.SearchGridColumnSize.moreInfo#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.SearchGridColumnSize.tradeDollars#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.SearchGridColumnSize.paymentDollars#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.SearchGridColumnSize.volume#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.SearchGridColumnSize.businessSegment#" cfsqltype="CF_SQL_INTEGER" />
				)
			</cfquery>
	   <cfelse>
			<cfquery name="qSaveColumnSize" datasource="#application.datasource#">
				UPDATE Program_Search_Grid_Column_Size
					SET
						Status = <cfqueryparam value="#arguments.SearchGridColumnSize.status#" cfsqltype="CF_SQL_INTEGER" />,
						RFA_Age = <cfqueryparam value="#arguments.SearchGridColumnSize.rfaAge#" cfsqltype="CF_SQL_INTEGER" />,
						Program = <cfqueryparam value="#arguments.SearchGridColumnSize.program#" cfsqltype="CF_SQL_INTEGER" />,
						Title = <cfqueryparam value="#arguments.SearchGridColumnSize.title#" cfsqltype="CF_SQL_INTEGER" />,
						Type = <cfqueryparam value="#arguments.SearchGridColumnSize.type#" cfsqltype="CF_SQL_INTEGER" />,
						Start_Date = <cfqueryparam value="#arguments.SearchGridColumnSize.startDate#" cfsqltype="CF_SQL_INTEGER" />,
						End_Date = <cfqueryparam value="#arguments.SearchGridColumnSize.endDate#" cfsqltype="CF_SQL_INTEGER" />,
						RSP = <cfqueryparam value="#arguments.SearchGridColumnSize.rsp#" cfsqltype="CF_SQL_INTEGER" />,
						More_Info = <cfqueryparam value="#arguments.SearchGridColumnSize.moreInfo#" cfsqltype="CF_SQL_INTEGER" />,
						Trade_Dollars = <cfqueryparam value="#arguments.SearchGridColumnSize.tradeDollars#" cfsqltype="CF_SQL_INTEGER" />,
						Payment_Dollars = <cfqueryparam value="#arguments.SearchGridColumnSize.paymentDollars#" cfsqltype="CF_SQL_INTEGER" />,
						Volume = <cfqueryparam value="#arguments.SearchGridColumnSize.volume#" cfsqltype="CF_SQL_INTEGER" />,
						Business_Segment= <cfqueryparam value="#arguments.SearchGridColumnSize.businessSegment#" cfsqltype="CF_SQL_INTEGER" />

					WHERE User_Id = <cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_VARCHAR" />
			</cfquery>
	   </cfif>

		<!--- COLUMN HIDE/SHOW (This stores data as to whether the column should be shown to the user or not)--->
		<cfquery name="qDeleteUserData" datasource="#application.datasource#">
			DELETE FROM Program_Search_Grid_Field_Include
			WHERE User_Id = <cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_VARCHAR" />
		</cfquery>

			<!--- Array "arguments.SearchGridColumnSize.includeColumnList" as the information --->
			<cfset list_includeColumnListList = ArrayToList("#arguments.SearchGridColumnSize.includeColumnList#")>

	   		<cfloop list="#list_includeColumnListList#" index="i">
				<cfset fieldName = ListFirst(i,":")>
				<cfset fieldViewable = ListLast(i,":")>

				<cfif fieldName eq "PAYMENTDOLLARS">
					<cfset fieldName = "paymentDollars">
				</cfif>

				<cfquery name="qSaveColumnInclude" datasource="#application.datasource#">
					insert into Program_Search_Grid_Field_Include(User_Id,Field_Name,Field_Viewable)
					values
					(
					<cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_VARCHAR" />,
					<cfqueryparam value="#fieldName#" cfsqltype="CF_SQL_VARCHAR" />,
					<cfqueryparam value="#fieldViewable#" cfsqltype="CF_SQL_VARCHAR" />
					)
				</cfquery>
			</cfloop>

	</cffunction>

		<!--- get saved Search Grid column width for AG GRID --->
	<cffunction name="callSearchGridColumnSizeInfo" output="false" access="remote" returnFormat="json">
		<cfargument name="userId" type="string" required="true">

			<cfreturn serializeJSON(getSearchGridColumnSizeInfo(arguments.userId), 'struct')>

	</cffunction>

	<!--- get saved Search Grid column width for AG GRID --->
	<cffunction name="getSearchGridColumnSizeInfo" output="false" access="public" returntype="query">
		<cfargument name="userId" type="string" required="true">
		<cfargument name="ignoreColumnList" type="string" required="false" default="">

		<cfset programmanager = createobject("component", "mvc.Models.Program.ProgramManager").init() />

		<cfset qPrgSettings = programmanager.getProgramLevelSettings() />

			<cfquery name="qGetColumnsInfo" datasource="#application.datasource#">
			DECLARE @bRecordExists bit = 0

				SELECT @bRecordExists = 1
				FROM Program_Search_Grid_Field_Include
				WHERE User_ID = '#arguments.userId#'

				SELECT UPPER(Field_Name) As ColName,
                        CASE
                            WHEN Field_Name = 'Program' THEN 1
                            ELSE Field_Viewable
                        END AS ColViewable,
						Field_Order As ColOrder,Field_Width As ColWidth
				FROM Program_Search_Grid_Field_Include
				where user_id =
				CASE
					WHEN @bRecordExists = 1
						THEN
							'#arguments.userId#'
					ELSE
							'00000000-9999-9999-0000000000000000'
				END
				<cfif getbusinesssegmentsetting()  EQ 0>
				AND Field_Name != 'businessSegment'
				</cfif>

				<cfif val(qPrgSettings.display_trade_dollars) eq 0>
				AND Field_Name != 'tradeDollars'
				</cfif>

				<cfif val(qPrgSettings.display_payment_dollars) eq 0>
				AND Field_Name != 'paymentDollars'
				</cfif>

				<cfif val(qPrgSettings.display_volume) eq 0>
				AND Field_Name != 'volume'
				</cfif>

				<cfif request.AccessStructure.External_Customer_Profile_Access EQ "1">
				AND Field_Name NOT IN ('RFAAGE', 'tradeDollars', 'paymentDollars')
				</cfif>

				<!--- Exclude columns which are used in FLEX program search --->
				AND Field_Name NOT IN('isSelected','contractMainID','BidRequestStatus')

				<!--- These columns are on the grid but are not a part of "download data" csv file. --->
				<cfif arguments.ignoreColumnList neq "">
				AND Field_Name NOT IN (#ListQualify(arguments.ignoreColumnList, "'" , ",", "ALL")#)
				</cfif>

				ORDER BY Field_Order
			</cfquery>

			<cfreturn qGetColumnsInfo>

	</cffunction>

	<!--- Function used by AG Grid to save column width, hide/show, order --->
	<cffunction name="saveSearchGridColumnInfo" output="false" access="remote" returntype="void">
        <cfset arguments.SearchGridColumnSize = DeserializeJSON(form.columns)>

        <!--- "arguments.SearchGridColumnSize" is in the following format:
		{endDate: "8:1:70", moreInfo: "9:1:187", program: "4:1:126", rfaAge: "3:1:111.600...", rsp: "10:1:110",
		startDate: "7:1:70", status: "2:1:70", title: "5:1:120", type: "6:1:120"}

		The first part of the value ("8") [endDate: "8:1:70"] is the column index.
		The second part ("1") is whether to "display" this column on the program search screen or not - 1 or 0.
		The third part ("70") of the value is the width of the column in pixels.
		--->

        <cfquery datasource="#application.datasource#">
			DELETE FROM Program_Search_Grid_Field_Include
                WHERE User_Id = <cfqueryparam value="#form.userID#" cfsqltype="CF_SQL_VARCHAR" />

            <cfloop collection="#arguments.SearchGridColumnSize#" item="local.key">
                <cfset local.ActualList = ListRest(arguments.SearchGridColumnSize[key],":")>
                <!--- "ListRest" removes the first part of the value --->
                <cfset local.fieldViewable = ListFirst(local.ActualList,":")>
                <cfset local.fieldWidth = ListLast(local.ActualList,":")>
                <cfset local.fieldOrder = ListFirst(arguments.SearchGridColumnSize[key],":")>

                <!--- START - Add following code for flex - This feature should continue working on flex as of now as we are are using the same table for flex as well --->
                <cfswitch expression="#local.key#">
                    <cfcase value="PROGRAM"><cfset local.key = "program"></cfcase>
                    <cfcase value="STATUS"><cfset local.key = "status"></cfcase>
                    <cfcase value="RFAAGE"><cfset local.key = "rfaAge"></cfcase>
                    <cfcase value="TITLE"><cfset local.key = "title"></cfcase>
                    <cfcase value="TYPE"><cfset local.key = "type"></cfcase>
                    <cfcase value="STARTDATE"><cfset local.key = "startDate"></cfcase>
                    <cfcase value="ENDDATE"><cfset local.key = "endDate"></cfcase>
                    <cfcase value="RSP"><cfset local.key = "rsp"></cfcase>
                    <cfcase value="VOLUME"><cfset local.key = "volume"></cfcase>
                    <cfcase value="BUSINESSSEGMENT"><cfset local.key = "businessSegment"></cfcase>
                    <cfcase value="TRADEDOLLARS"><cfset local.key = "tradeDollars"></cfcase>
                    <cfcase value="PAYMENTDOLLARS"><cfset local.key = "paymentDollars"></cfcase>
                    <cfcase value="MOREINFO"><cfset local.key = "moreInfo"></cfcase>
                </cfswitch>
                <!--- END  - Add following code for flex - This feature should continue working on flex as of now as we are are using the same table for flex as well --->

                insert into Program_Search_Grid_Field_Include(User_Id,Field_Name,Field_Viewable,Field_Order,Field_Width)
                    values
                            (
                            <cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_VARCHAR" />,
                            <cfqueryparam value="#local.key#" cfsqltype="CF_SQL_VARCHAR" />,
                            <cfqueryparam value="#local.fieldViewable#" cfsqltype="CF_SQL_VARCHAR" />,
                            <cfqueryparam value="#local.fieldOrder#" cfsqltype="CF_SQL_INTEGER" />,
                            <cfqueryparam value="#local.fieldWidth#" cfsqltype="CF_SQL_INTEGER" />
                            )
            </cfloop>
        </cfquery>
	</cffunction>

</cfcomponent>