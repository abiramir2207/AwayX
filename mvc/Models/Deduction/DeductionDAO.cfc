 <!-----------------------------------------------------------------------------

FILE NAME:		DeductionDAO.cfc
DESCRIPTION:	All the data access Queries and SPs go here...
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	01-Jun-2011	Created
							
------------------------------------------------------------------------------> 

<cfcomponent output="false" alias="mvc.Models.Deduction.DeductionDAO" hint="Data Access components, that does all the DB calls">

	<!--- DATA ACCESS FOR DeductionManager --->
	<cfset appSettings = application.appSettingsGet />
	
	<cffunction name="init" output="false" returntype="mvc.Models.Deduction.DeductionDAO">
		<cfreturn this />
	</cffunction>
	
	
	<cffunction name="getIaASupervisor" output="false" returntype="query">
		<cfquery name="qryIaASupervisor" datasource="#Application.Datasource#">
			SELECT * FROM DD_Analyst 	
			WHERE 	Analyst_User_ID = '#request.AccessStructure.User_ID#' AND
			Is_Supervisor = 1 AND Supervisor_ID IS NULL AND 
			(LEN(LTRIM(RTRIM(Supervisor_ID))) = 0 OR LEN(LTRIM(RTRIM(Supervisor_ID))) IS NULL) AND 
			Deleted = 0 
		</cfquery>
		<cfreturn qryIaASupervisor />
	</cffunction>
	
	
	<cffunction name="getAnalystUnderMe" output="false" returntype="query">	
		<cfargument name="Is_Default_Supervisor" type="boolean" required="true">		
		<cfquery name="qryAnalystUnderMe" DATASOURCE="#Application.Datasource#">
			SELECT * FROM DD_Analyst 
			WHERE 	Supervisor_ID = '#request.AccessStructure.User_ID#' <cfif arguments.Is_Default_Supervisor EQ 1>OR (LEN(LTRIM(RTRIM(Supervisor_ID))) = 0 OR LEN(LTRIM(RTRIM(Supervisor_ID))) IS NULL)</cfif> AND
				Is_Supervisor = 0 AND
				Deleted = 0
		</cfquery>
		<cfreturn qryAnalystUnderMe />

	</cffunction>
	
 
	<cffunction name="getHQPosition" output="false" returntype="query">
		<cfset useLakebaseForqryHQPosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_positions")>
<cfif useLakebaseForqryHQPosition>
	<cftry>
		<cfset qryHQPosition = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_positions", {
				"service_zone_id" = "is.null",
				"service_region_id" = "is.null",
				"service_market_id" = "is.null",
				"deleted" = "eq.0",
				"select" = "user_positions_id"
			}), "user_positions_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryHQPosition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryHQPosition>
<cfquery name="qryHQPosition" datasource="#Application.Datasource#">
			SELECT 	User_Positions_ID 
			FROM 	User_Positions 
			WHERE 	Service_Zone_ID IS NULL AND 
					Service_Region_ID IS NULL AND 
					Service_Market_ID IS NULL AND 
					Deleted = 0
		</cfquery>
</cfif>
		<cfreturn qryHQPosition />
		
	</cffunction>
	
	
	
	<cffunction name="getDDSearchResults" output="false" returntype="query"><!--- getDeductionsOnBBID --->
		 <cfargument name="billbackID" required="true" type="string">
		 <cfargument name="stForm" required = "true" type="struct">
		<cfif NOT ISDefined("arguments.stForm.DD_Report_CacheSpan")>
			<cfset arguments.stForm.DD_Report_CacheSpan = DateAdd("n",5,Now())  />    <!--- This is a fix for a CF Bug.  Set it to a future date or else it uses cache --->
		</cfif>
		
		<cfset UserPositionList = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.user_id, 0, 1) />
		<cfset HQPosition = this.getHQPosition() />
		<cfset isFlexSettlement = true />
		<cfset DD_Status_toHide	= CreateObject("component", "components.Deduction.settings.DeductionSettingsManager").DD_Status_Control(request.AccessStructure.profiles_id) />
		<cfset profile = CreateObject("component","components.user.Profile").init() />
		<cfset Get_Profile_Settings = profile.getProfileSettings(request.AccessStructure.Profiles_ID)>
		<cfset IaASupervisor = this.getIaASupervisor() />
		<cfset UserIsASupervisor = 0>
		<cfset isDefaultSupervisor = 0 />
		<cfif IaASupervisor.RecordCount GT 0>
		<!--- 
			fix for issue #362, not sure, if for some reason this field was null and hence 
			we got an error so if null then set it to 0
		--->
		<cfif IaASupervisor.Is_Default_Supervisor EQ "">
			<cfset isDefaultSupervisor = 0 />
		<cfelse>
			<cfset isDefaultSupervisor = IaASupervisor.Is_Default_Supervisor />
		</cfif>
		<cfset GetAnalystUnderMe = this.getAnalystUnderMe(isDefaultSupervisor) />
		<cfset AnalystUnderMe_List = VALUELIST(GetAnalystUnderMe.Analyst_User_ID)>
		<cfset AnalystUnderMe_List = ListAppend(AnalystUnderMe_List, request.AccessStructure.User_ID)>
	</cfif>
		
		
		<cfset qryAnalystUnderMe = this.GetAnalystUnderMe(isDefaultSupervisor) />
		<cfif IaASupervisor.RecordCount GT 0 AND qryAnalystUnderMe.RecordCount GT 0>
			<cfset UserIsASupervisor = 1>
		</cfif>		
		
		<cfset useLakebaseForDeductionsProfilesSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions_profiles_settings")>
<cfif useLakebaseForDeductionsProfilesSettings>
	<cftry>
		<cfset DeductionsProfilesSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions_profiles_settings", {
				"profiles_id" = "eq.#Get_Profile_Settings.Profiles_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeductionsProfilesSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionsProfilesSettings>
<cfquery name="DeductionsProfilesSettings" datasource="#application.datasource#">
			SELECT * FROM Deductions_Profiles_Settings WHERE Profiles_ID = '#Get_Profile_Settings.Profiles_ID#'
		</cfquery>
</cfif>
		<cfset useLakebaseForDeductionSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_settings")>
<cfif useLakebaseForDeductionSettings>
	<cftry>
		<cfset DeductionSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deduction_settings", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeductionSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionSettings>
<cfquery name="DeductionSettings" datasource="#application.datasource#">
			SELECT * FROM Deduction_Settings
		</cfquery>
</cfif>
		<cfparam name="SrchByAnalystAllowed" default="false">
		<cfif DeductionsProfilesSettings.DD_Search_By_Analyst>
			<cfset SrchByAnalystAllowed = true>
		</cfif>		
 		<cfset displayOnlyAssignedDeductions = appSettings.getDisplayOnlyAssignedDeductions()>		
		<cfset BusEnabled = 0>
		<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<cfset BusEnabled = businessSegManager.isEnabled()>
		
		
<cftransaction isolation="read_uncommitted">
<cfquery name="qryDDResults" datasource="#Application.Datasource#" cachedafter="#arguments.stForm.DD_Report_CacheSpan#">
	<cfif NOT ListFind(UserPositionList, HQPosition.User_Positions_ID)> <!---- not an HQ ----->	
	DECLARE @Temp_Market_ID table
		(
			Service_Market_ID int
		)
	INSERT INTO @Temp_Market_ID(Service_Market_ID)
	SELECT DISTINCT Service_Markets.Service_Market_ID
	FROM 		User_Positions

	LEFT JOIN 	Service_Regions ON Service_Regions.Service_Zone_ID = User_Positions.Service_Zone_ID AND
				User_Positions.Service_Zone_ID IS NOT NULL AND
				User_Positions.Service_Region_ID IS NULL AND
				User_Positions.Service_Market_ID IS NULL

	LEFT JOIN 	Service_Markets ON
				(	(	Service_Markets.Service_Market_ID = User_Positions.Service_Market_ID AND
						User_Positions.Service_Market_ID IS NOT NULL
					) OR
					(	Service_Markets.Service_Region_ID = User_Positions.Service_Region_ID AND
						User_Positions.Service_Region_ID IS NOT NULL AND
						User_Positions.Service_Market_ID IS NULL
					) OR
					(	User_Positions.Service_Zone_ID IS NOT NULL AND
						User_Positions.Service_Region_ID IS NULL AND
						User_Positions.Service_Market_ID IS NULL AND
						Service_Markets.Service_Region_ID = Service_Regions.Service_Region_ID
					) OR
					(	1=1 AND
						User_Positions.Service_Zone_ID IS NULL AND
						User_Positions.Service_Region_ID IS NULL AND
						User_Positions.Service_Market_ID IS NULL
					)
				) AND Service_Markets.Service_Market_ID IS NOT NULL

	WHERE 		User_Positions.User_Positions_ID IN (#PreserveSingleQuotes(UserPositionList)#)
	</cfif>

	SELECT 	 datediff(d,dd_date,getdate()) NumberOfDays,
					DD_Aging.DD_Aging_Label,
					Deductions.*,
					DD_Classification.DD_Classification_Desc,
					DD_Stage.DD_Stage_Description,
					Replace(Replace(DD_Ded_Actions.Comments, CHAR(10), ' '), CHAR(13), ' ') as Comments,
					DD_Ded_Actions.Date_Completed,
					DD_Analyst.Is_Supervisor,
					_Users_1.Name_First As Supervisor_FirstName,
					_Users_1.Name_Last As Supervisor_LastName,
					DateDiff(day, DD_Date, getdate()) AS Deduction_Age,
					DD_Reason_Code.DD_Reason_Code_Description,
					DD_Status.DD_Status_ID,
					DD_Status.DD_Status_Description,
					Distributor_Bill_To.Name,
					Distributor_Bill_To.Shr_Bill_To,
					<cfif arguments.stForm.Distributor_List  NEQ "" OR isFlexSettlement>
					BSA_Foodservice_Customers.Name CustomerName,
					BSA_Foodservice_Customers.Ship_To,
					</cfif>
					BSA_Foodservice_Brokers.Broker_Name,
					BSA_Foodservice_Brokers.Broker_Shard,
					Distributor_Family.Family,
					Distributor_Family.Family_Name,
					Service_Markets.Service_Market_ID,
					Service_Markets.Market_Name,
					Service_Regions.Region_Name,
					Service_Regions.Region_Number,
					Service_Zones.Zone_Name,
					Service_Zones.Zone_Number,
					_Users.Name_First,
					_Users.Name_last,
					userLock.Name_First AS LockedName_First,
					userLock.Name_Last AS LockedName_Last,
					(SELECT Count(Deleted) FROM Contract_Attachments WHERE Contract_Attachments.Deduction_ID = Deductions.Deduction_ID AND Contract_Attachments.Deleted = 0) AS attachment_count,
				CASE WHEN BSA_Foodservice_Customers.Shr_ship_to IS NULL
				THEN
					Distributor_Bill_To.Name
				ELSE
					BSA_Foodservice_Customers.Name
				END AS Distributor_Name,
				BSA_Foodservice_Customers.Shr_ship_to,		
				DD_Rebill_Integration.Rebill_Ack_Status,
				DD_Rebill_Integration.Rebill_Number,
				DD_Rebill_Integration.Rebill_Ack_On,
				DD_Rebill_Integration.Rebill_Sent_On,
				DD_Notes.DD_Note,
				Deduction_Type.DeductionType_Desc,
				0 AS DD_Amount_Parent,
				'' AS DD_DedID_SP_Number_Parent
	FROM			Deductions WITH (NOLOCK)
	LEFT JOIN 		Distributor_Bill_To ON Distributor_Bill_To.Distributor_Bill_To_ID = Deductions.Distributor_Bill_To_ID
	LEFT JOIN	BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID	AND BSA_Foodservice_Customers.Active_Code = 'A'
	INNER JOIN 	DD_Status ON DD_Status.DD_Status_ID = Deductions.DD_Status AND
				<cfif arguments.stForm.DD_Number NEQ "">
					(Deductions.DD_DedID_SP_Number LIKE '%#TRIM(arguments.stForm.DD_Number)#%' OR
					Deductions.DD_DedID LIKE '%#TRIM(arguments.stForm.DD_Number)#%'
					) 
					AND
				</cfif>
				<cfif arguments.stForm.Analyst_User_ID NEQ "">
					Deductions.Analyst_User_ID = '#arguments.stForm.Analyst_User_ID#' AND
				</cfif>
				<cfif arguments.stForm.DD_Status NEQ "">
          Deductions.DD_Status in (  
                                    <cfscript>
                                     listCount = 0;
                                     listSize  = listLen(arguments.stForm.DD_Status);
                                    </cfscript>
                                    <cfloop index="thisStatus" list="#arguments.stForm.DD_Status#">
                                      #thisStatus#
                                      <cfset listCount = listCount + 1>
                                      <!---insert a comma if this status is not the last one in the list--->
                                      <cfif (listCount lt listSize)>
                                          ,
                                      </cfif>
                                    </cfloop>   
                                  ) AND
				</cfif>
				<cfif arguments.stForm.Filter_Closed EQ 1>
					Deductions.DD_Status NOT IN (4,5,6,9) AND
				</cfif>
				<cfif arguments.stForm.Filter_Attached EQ 1>
					Deductions.DD_Closure_ID IS NULL AND
					Deductions.Is_Write_Off = 0 AND
					ISNULL(Deductions.DD_Closure_Type, 0) != 7 AND
				</cfif>
				<cfif LISTLEN(DD_Status_toHide) GT 0>
					Deductions.DD_Status NOT IN (#DD_Status_toHide#) AND
				</cfif>
				<cfif arguments.stForm.Distributor NEQ "" OR arguments.stForm.Distributor_Name NEQ "">
				<cfif arguments.stForm.Distributor_ID NEQ "">
					(
					Deductions.Distributor_ID IN (#ListQualify(arguments.stForm.Distributor_ID, "'", ",")#)
					OR 
					Deductions.Distributor_Bill_To_ID IN (#ListQualify(arguments.stForm.Distributor_ID, "'", ",")#)
					)
				<cfelse>
				  	1=2
				</cfif>
			AND
				<cfelseif arguments.stForm.Distributor_List NEQ "" >
				Deductions.Distributor_ID IN (#ListQualify(arguments.stForm.Distributor_List, "'", ",")#) AND
				<cfelseif arguments.stForm.MC_Shr_Ship_to NEQ "" OR arguments.stForm.MC_Shr_Bill_To NEQ "">
				(1=2
					<cfif (arguments.stForm.MC_Shr_Ship_to NEQ "")>
					 OR
					 (
						BSA_Foodservice_Customers.Shr_Ship_To = '#arguments.stForm.MC_Shr_Ship_To#'
						OR
						BSA_Foodservice_Customers.Name LIKE '%#TRIM(arguments.stForm.MC_Distributor_Name)#%'
					 )
					</cfif>
					<cfif (arguments.stForm.MC_Shr_Bill_To NEQ "")>
						OR 
						(
						<cfif (arguments.stForm.MC_Shr_Ship_to NEQ "") AND (arguments.stForm.MC_Shr_Ship_To NEQ arguments.stForm.MC_Shr_Bill_To)>
						Deductions.Distributor_ID IS NULL AND 
						</cfif>
							(
							 Distributor_Bill_To.Shr_Bill_To = '#arguments.stForm.MC_Shr_Bill_To#'
							 OR
							 Distributor_Bill_To.Name LIKE '%#TRIM(arguments.stForm.MC_Bill_To_Name)#%'
							)
						 )
					</cfif>
					)AND
				</cfif>	
				<cfif arguments.stForm.Distributor_Bill_To_ID NEQ "">
					Deductions.Distributor_Bill_To_ID = '#arguments.stForm.Distributor_Bill_To_ID#' AND
				</cfif>
				<cfif arguments.stForm.Broker_List NEQ "">
					Deductions.Broker_ID IN (#ListQualify(arguments.stForm.Broker_List, "'", ",")#) AND
				</cfif>
				<cfif arguments.stForm.DD_Stage_ID NEQ "">
					Deductions.DD_Stage = '#arguments.stForm.DD_Stage_ID#' AND
				</cfif>
				<cfif arguments.stForm.DD_Amount NEQ "">
					(Deductions.DD_Amount <cfif arguments.stForm.Dollar_Operator EQ "">=<cfelse>#arguments.stForm.Dollar_Operator#</cfif> '#arguments.stForm.DD_Amount#' <cfif arguments.stForm.Dollar_Operator EQ "between">AND '#arguments.stForm.DD_To_Amount#'</cfif>
					<cfif DeductionSettings.Use_Cleared_Amount IS 1>
					OR
					Deductions.Cleared_Amount <cfif arguments.stForm.Dollar_Operator EQ "">=<cfelse>#arguments.stForm.Dollar_Operator#</cfif> '#arguments.stForm.DD_Amount#' <cfif arguments.stForm.Dollar_Operator EQ "between">AND '#arguments.stForm.DD_To_Amount#'</cfif>
					</cfif>) AND
				</cfif>
				 <cfif arguments.stForm.Date_Time NEQ "">
					<cfif arguments.stForm.Date_Operator EQ "Between">
					DATEDIFF(d, #CreateODBCDate(arguments.stForm.Date_Time)#, Deductions.DD_Date) >= 0 AND
					DATEDIFF(d, #CreateODBCDate(arguments.stForm.To_Date_Time)#, Deductions.DD_Date) <= 0 AND
					<cfelse>
					DATEDIFF(d, #CreateODBCDate(arguments.stForm.Date_Time)#, Deductions.DD_Date) <cfif arguments.stForm.Date_Operator EQ "">=<cfelse>#arguments.stForm.Date_Operator#</cfif> 0 AND
					</cfif>
				</cfif>
				<cfif arguments.stForm.ClDate_Time NEQ "">
					<cfif arguments.stForm.ClDate_Operator EQ "Between">
					DATEDIFF(d, #CreateODBCDate(arguments.stForm.ClDate_Time)#, Deductions.DD_Date_Closed) >= 0 AND
					DATEDIFF(d, #CreateODBCDate(arguments.stForm.ClTo_Date_Time)#, Deductions.DD_Date_Closed) <= 0 AND
					<cfelse>
					DATEDIFF(d, #CreateODBCDate(arguments.stForm.ClDate_Time)#, Deductions.DD_Date_Closed) <cfif arguments.stForm.ClDate_Operator EQ "">=<cfelse>#arguments.stForm.ClDate_Operator#</cfif> 0 AND
					</cfif>
				</cfif>
				<cfif arguments.stForm.Check_No NEQ "">
					Deductions.DD_Check_Number Like '%#arguments.stForm.Check_No#%' AND
				</cfif>
				<cfif arguments.stForm.IsBusEnabled EQ 1>
					<cfif arguments.stForm.Business_Segment_ID NEQ "">
						Deductions.Business_Segment_ID = '#arguments.stForm.Business_Segment_ID#' AND
					</cfif>
					<cfif arguments.stForm.Operating_Unit_ID NEQ "">
						Deductions.Operating_Unit_ID = '#arguments.stForm.Operating_Unit_ID#' AND
					</cfif>
				</cfif>
				<cfif arguments.stForm.Q_Brand_ID NEQ "">
					Deductions.Q_Brand_ID = '#arguments.stForm.Q_Brand_ID#' AND
				</cfif>
				<cfif arguments.stForm.DD_Operator_ID NEQ "">
					Deductions.DD_Operator_ID = '#arguments.stForm.DD_Operator_ID#' AND
				</cfif>
				<cfif arguments.stForm.C1AR_Reference NEQ "">
					Deductions.DD_Reference Like '%#arguments.stForm.C1AR_Reference#%' AND
				</cfif>
				<cfif arguments.stForm.C1Cust_RefNo NEQ "">
					Deductions.DD_Customer_RefNo Like '%#arguments.stForm.C1Cust_RefNo#%' AND
				</cfif>
				<cfif arguments.stForm.IsParentDeduction eq 1>
					Deductions.Split_Count = 0 AND
				</cfif>
				<cfif arguments.stForm.DD_Reason_Code_ID NEQ "">
					Deductions.DD_Resolution_Code='#arguments.stForm.DD_Reason_Code_ID#' AND
				</cfif>
				<cfif arguments.stForm.Family_ID NEQ "">
					(Deductions.Ass_BasedOn_Family_ID = '#arguments.stForm.Family_ID#' OR  BSA_Foodservice_Customers.Family_ID = '#arguments.stForm.Family_ID#') AND
				</cfif>
				Deductions.Deleted=0
	INNER JOIN	DD_Aging ON Start_Range <= datediff(d,Deductions.dd_date,getdate()) AND (End_Range IS NULL OR End_Range >= datediff(d,Deductions.dd_date,getdate())) AND DD_Aging.Deleted = 0
				<cfif arguments.stForm.DD_Aging NEQ ""> AND Tier_Number = '#arguments.stForm.DD_Aging#' </cfif>
	LEFT JOIN 		BSA_Foodservice_Brokers ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Deductions.Broker_ID
	<!---Brokers may not have market currently but may receive it in future so left join on service market table--->
	LEFT JOIN 	Service_Markets ON Service_Markets.Service_Market_ID = BSA_Foodservice_Brokers.Service_Market_ID

	LEFT JOIN DD_Classification ON Deductions.DD_Classification_ID = DD_Classification.DD_Classification_ID

	LEFT JOIN DD_Ded_Actions ON Deductions.Deduction_ID = DD_Ded_Actions.Deduction_ID
	AND Deductions.DD_Stage = DD_Ded_Actions.DD_Stage_ID
	AND DD_Ded_Actions.DD_Ded_Action_ID = Deductions.DD_Ded_Action_ID
	AND DD_Ded_Actions.Deleted = 0
	LEFT JOIN DD_Analyst ON DD_Analyst.Analyst_User_ID = Deductions.Analyst_User_ID
	AND DD_Analyst.Deleted = 0
	LEFT JOIN _Users _Users_1 ON _Users_1.User_ID = DD_Analyst.Supervisor_ID
	LEFT JOIN		Distributor_Family ON Distributor_Family.Family_ID = Deductions.Ass_BasedOn_Family_ID
	LEFT JOIN 		_Users ON _Users.User_ID = Deductions.Analyst_User_ID
	LEFT JOIN 		Service_Regions ON Service_Regions.Service_Region_ID = BSA_Foodservice_Brokers.Service_Region_ID

	LEFT JOIN 		DD_Stage ON DD_Stage.DD_Stage_ID = Deductions.DD_Stage
	LEFT JOIN 		Service_Zones ON Service_Zones.Service_Zone_ID = BSA_Foodservice_Brokers.Service_Zone_ID

	LEFT JOIN 		DD_Reason_Code ON DD_Reason_Code.DD_Reason_Code_ID = Deductions.DD_Resolution_Code
	LEFT JOIN 		DD_Notes ON DD_Notes.DD_Note_ID = Deductions.Latest_DD_Note_ID AND DD_Notes.Deleted = 0
  	LEFT JOIN     Deduction_Type ON Deductions.DeductionType_ID = Deduction_Type.DeductionType_ID    <!---26491--->
	LEFT JOIN     DD_Rebill_Integration ON DD_Rebill_Integration.Deduction_ID = Deductions.Deduction_ID AND DD_Rebill_Integration.Deleted = 0
  	LEFT JOIN	 _Users userLock ON userLock.User_ID = Deductions.Locked_By
	WHERE 			1=1 AND  <cfif appSettings.getDDSentRejectIn1510() NEQ 1>Deductions.DD_Rejected=0 AND</cfif>
<!------------------------ check access permission - start -------------------------------------->	
<!-----
Quick / Advanced Search					Profile Search By Analyst = ON	
--------------------------------------------------------------------------------------------------------------------
HQ (not Analyst / not Supervisor)		All	
HQ (Analyst / Supervisor)				All	
Non HQ (not Analyst / not Supervisor)	All	
Non HQ (Analyst / Supervisor)			All	
--------------------------------------------------------------------------------------------------------------------
Quick / Advanced Search					Profile Search By Analyst = OFF	
--------------------------------------------------------------------------------------------------------------------
HQ (not Analyst / not Supervisor)		All	
HQ (Analyst / Supervisor)				All	
Non HQ (not Analyst / not Supervisor)	Based on user position only	
Non HQ (Analyst / Supervisor)			Based on analyst assignment only	
------>
				<cfif NOT DeductionsProfilesSettings.DD_ACCESS_LEVEL>
				1=2 AND
				<cfelseif NOT SrchByAnalystAllowed>
					<cfif displayOnlyAssignedDeductions and (isDefined("UserHasAssignments.RecordCount") AND UserHasAssignments.RecordCount)>
						Deductions.Analyst_User_ID = '#request.AccessStructure.User_ID#' AND
					<cfelse>
						<cfif ListFind(UserPositionList, HQPosition.User_Positions_ID)> <!---- is an HQ ----->
							1=1
						<cfelseif (isDefined("UserHasAssignments.RecordCount") AND UserHasAssignments.RecordCount) AND NOT IaASupervisor.RecordCount><!--- not HQ, just an anlayst ---->
							Deductions.Analyst_User_ID = '#request.AccessStructure.User_ID#'
						<cfelseif UserIsASupervisor> <!---- not HQ, supervisor ----->
							Deductions.Analyst_User_ID IN (#LISTQUALIFY(AnalystUnderMe_List,"'",",","All")#)
						<cfelse> <!---- not analyst, not supervisor, not HQ ---->
							Service_Markets.Service_Market_ID IN (SELECT Service_Market_ID FROM @Temp_Market_ID)
						</cfif>
						 AND
					</cfif>
				</cfif>
<!------------------------ check access permission - end -------------------------------------->				
				<cfif arguments.stForm.Service_Market_ID NEQ "">
					 Service_Markets.Service_Market_ID IN (#PreserveSingleQuotes(arguments.stForm.Service_Market_ID)#) AND
				</cfif>
				<cfif arguments.stForm.Service_Region_ID NEQ "">
					Service_Regions.Service_Region_ID IN (#PreserveSingleQuotes(arguments.stForm.Service_Region_ID)#) AND
				</cfif>
				<cfif arguments.stForm.Service_Zone_ID NEQ "">
					Service_Zones.Service_Zone_ID='#arguments.stForm.Service_Zone_ID#' AND
				</cfif>
				<cfif TRIM(arguments.stForm.Distributor_Bill_To) NEQ "">
					(Distributor_Bill_To.Shr_Bill_to LIKE '%#TRIM(arguments.stForm.Distributor_Bill_To)#%'
					OR Distributor_Bill_To.Name LIKE '%#TRIM(arguments.stForm.Distributor_Bill_To)#%'
					)AND
				</cfif>
 					<cfif arguments.stForm.Line_Of_Business_ID NEQ "">
						EXISTS
						(
							SELECT 		TOP 1 Cust.BSA_Foodservice_Customers_ID
							FROM		BSA_Foodservice_Customers Cust
							INNER JOIN 	Line_Of_Business ON Line_Of_Business.Line_Of_Business_ID = Cust.Line_Of_Business_ID AND
										Line_Of_Business.Line_Of_Business_ID = '#arguments.stForm.LINE_OF_BUSINESS_ID#'
							WHERE 		Cust.Distributor_Bill_To_ID = Deductions.Distributor_Bill_To_ID AND
										Cust.Deleted = 0 AND Cust.Active_Code = 'A'
						) AND
					</cfif>
					<cfif arguments.stForm.Only_DD_With_Inactive_Relations EQ 1>
					(	BSA_Foodservice_Customers.Deleted <> 0
					OR	BSA_Foodservice_Customers.Active_Code <> 'A'
					OR	BSA_Foodservice_Brokers.Deleted <> 0
					OR	BSA_Foodservice_Brokers.Active_Code <> 'A'
					OR	Service_Markets.Deleted <> 0
					OR	Service_Regions.Deleted <> 0
					OR	Service_Zones.Deleted <> 0
					)
					 AND
					</cfif>
					1=1
					
				<cfif arguments.stForm.SearchSource EQ "MatchCentralDD">
					AND Is_Credit = 0
					AND DD_Status <> 7
					<cfif arguments.stForm.DD_Ref NEQ "">
						AND Deductions.DD_Reference LIKE '%#arguments.stForm.DD_Ref#%'
					</cfif>
					<cfif arguments.stForm.DDAmountFilter NEQ "">
						AND DD_Amount <= #arguments.stForm.DDAmountFilter#
					</cfif>
				<cfelseif arguments.stForm.SearchSource EQ "MatchCentralCR">
					AND Is_Credit = 1
					<cfif arguments.stForm.DDAmountFilter NEQ "">
						AND DD_Amount >= #arguments.stForm.DDAmountFilter#
					</cfif>
					<cfif arguments.stForm.DD_Ref NEQ "">
						AND Deductions.DD_Reference LIKE '%#arguments.stForm.DD_Ref#%'
					</cfif>
				</cfif>			
				

				<cfif arguments.stForm.Broker_Name NEQ "">
					AND BSA_Foodservice_Brokers.Broker_Name LIKE '%#arguments.stForm.Broker_Name#%'
				</cfif>
			
			<!--- 
				TODO: We need to add this later on after finalizing on the Business_segments.
					Removed this for now as it was not returning the expected results - Anand Rao/5-Aug-2011
			
				<cfif BusEnabled EQ 1 AND (arguments.stForm.SearchSource EQ "MatchCentralDD" OR arguments.stForm.SearchSource EQ "MatchCentralCR")>
				/* AND 
				(
					SELECT BSA_Foodservice_Customers.Business_Segment_ID
					FROM BSA_Foodservice_Customers
					WHERE Deductions.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
				)
				 =
								CASE '#stForm.businessSegmentID#'
									<!--- Do not filter when the Payee is the Vendor (Vendors do not have a business segment) --->
									WHEN ''
										THEN 							
											(
											SELECT BSA_Foodservice_Customers.Business_Segment_ID
											FROM BSA_Foodservice_Customers
											WHERE Deductions.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
											) 
									ELSE
									'#stForm.businessSegmentID#'
								END 
					*/			
				</cfif> --->
        <cfif (appSettings.getIntegrated_Rebill() EQ 1) AND arguments.stForm.Rebill_Number NEQ "">
          AND DD_Rebill_Integration.Rebill_Number LIKE '%#arguments.stForm.Rebill_Number#%'
        </cfif>  
        <cfif arguments.stForm.Classification neq "0">AND Deductions.DD_Classification_ID = #arguments.stForm.Classification#</cfif>
        <cfif arguments.stForm.DeductionType neq "0">AND Deductions.DeductionType_ID = #arguments.stForm.DeductionType#</cfif>
		ORDER BY 		<cfif arguments.stForm.SORT_BY EQ "Broker_Name">
						BSA_Foodservice_Brokers.Broker_Name
					<cfelseif arguments.stForm.SORT_BY EQ "Name">
						Distributor_Name
					<cfelse>
						#arguments.stForm.SORT_BY#
					</cfif>
					 #arguments.stForm.SORT_ORDER#
	
		</cfquery>
		</cftransaction>		
	<cfreturn qryDDResults />
	
	</cffunction>
	
	<cffunction name="getDeductionOnID" output="false" returntype="query" access="public" >	
		<cfargument name="Deduction_ID" type="string" required="true">	
	
			<cfquery name="qGetDeductions" datasource="#application.datasource#">
				SELECT	Deductions.*,
						CASE WHEN BSA_Foodservice_Customers.Shr_ship_to IS NULL
							THEN Distributor_Bill_To.Name
							ELSE BSA_Foodservice_Customers.Name
						END AS Distributor_Name,
						BSA_Foodservice_Brokers.Broker_Name,	
						_Users.Name_First,
						_Users.Name_last,
						usr2.Name_First AS LockedName_First,
						usr2.Name_last AS LockedName_Last,
						ISNULL(DD2_Parent.DD_Amount, 0) AS DD_Amount_Parent,
						DD2_Parent.DD_DedID_SP_Number AS DD_DedID_SP_Number_Parent
				FROM 	Deductions
						LEFT JOIN Distributor_Bill_To ON Distributor_Bill_To.Distributor_Bill_To_ID = Deductions.Distributor_Bill_To_ID
						LEFT JOIN BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID	AND BSA_Foodservice_Customers.Active_Code = 'A'					
						LEFT JOIN BSA_Foodservice_Brokers ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Deductions.Broker_ID
						LEFT JOIN DD_Analyst ON DD_Analyst.Analyst_User_ID = Deductions.Analyst_User_ID AND DD_Analyst.Deleted = 0					
						LEFT JOIN _Users ON _Users.User_ID = Deductions.Analyst_User_ID
						LEFT JOIN _Users usr2 ON usr2.User_ID = Deductions.Locked_by
						LEFT JOIN Deductions DD2_Parent ON DD2_Parent.Deduction_ID = Deductions.DD_Parent_ID AND DD2_Parent.Deleted = 0 AND DD2_Parent.DD_IsParent = 1
				WHERE 	Deductions.Deduction_ID = <cfqueryparam value="#arguments.Deduction_ID#" cfsqltype="cf_sql_varchar"> 
				AND 	Deductions.Deleted = 0
				--AND Deductions.DD_Rejected = 0 
				ORDER BY Deductions.DD_DedID_SP_Number ASC
		</cfquery>
		<cfreturn qGetDeductions />
	</cffunction>
	
	
	<cffunction name="updDedSplitWithBB" output="false" returntype="void" access="public" >	
		<cfargument name="DeductionID" type="string" required="true">	
		<cfargument name="BillbackID" type="string" required="true">	
		<cfargument name="writeOff" type="numeric" required="true">	
		<cfargument name="BBAction" type="string" required="true">	
		
		<cfif arguments.writeOff EQ 1>
			<cfset  DDClosureType = 1 />		
		<cfelse>
			<!--- when it is not a write off we need to set the DD_Closure_Type_ID =7 (Re-Instate) --->
			<cfset  DDClosureType = 7 />
		</cfif>
 
		<cfif arguments.DeductionID NEQ "" AND arguments.BillbackID NEQ "">
			<cfquery name="qUpdDedSplitWithBB" datasource="#application.datasource#">
				UPDATE Deductions
				SET Split_By_Billback_ID = '#arguments.BillbackID#',
					Is_Write_Off = #arguments.writeOff#,
					DD_Closure_Type = #DDClosureType#
				<cfif (arguments.BBAction EQ "APPROVE")>	
					,DD_Status = 4
				</cfif>					
				WHERE Deduction_ID = '#arguments.DeductionID#'
			</cfquery> 
		</cfif>
		
	</cffunction>	 

	<!--- 	This fn reopens the DD associated to the BB, assuming there is only 1 BB associated to the DD.
			If there is more than one BB for the DD then dont use this fn.	--->
	<cffunction name="qReopenDDforBB" output="false" returntype="void" access="public" 
				hint="this function should not be called when there are more than one BB associated to Deduction, as it opens the DD for all the billlbacks" >
				
		<cfargument name="billbackID" 	required="true"	type="string" />
		<cfargument name="userId" 		required="true"	type="string" />
		<cfset var ddNoteText = "Deduction was Reopened" />
		<cfquery name="qDDAssociatedtoBB" datasource="#application.datasource#">
			SELECT	DD_Closure_Detail_ID, Deduction_ID, DD_Closure_ID, DD_Closure_Status_ID 		
			FROM	DD_Closure_Detail
			WHERE 	DD_Closure_ID =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billbackID#">
			AND		Deleted = 0
		</cfquery>

		<cfquery name="qRemoveDDAssociatedtoBB" datasource="#application.datasource#">
			UPDATE	DD_Closure_Detail
			SET		Deleted = 1
			WHERE 	DD_Closure_ID =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billbackID#">
			AND		Deleted = 0
		</cfquery>
		
		<!--- BEGIN: loop thru each deduction for this BB and set the values for reopen --->
		<cfloop query="qDDAssociatedtoBB">
			<!--- ------------------------------------------------------------------------------------- --->
			<!--- Dev Note: KAL; Most of the code in this section is from DEDUCTIONS/Closure/reopen.cfm --->
			<!--- ------------------------------------------------------------------------------------- --->
			<cfquery name="qDeductionInfo" datasource="#application.datasource#">
				SELECT 	* 
				FROM 	Deductions 
				WHERE 	Deduction_ID = <cfqueryparam value="#qDDAssociatedtoBB.Deduction_ID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<!--- add notes entry --->
			<cfset ddNoteText = "Deduction was Reopened" />
			<cfif qDeductionInfo.DD_Closure_Sent neq 1>
				<cfset ddNoteText = "Closed and Reopened on the same date" />
			</cfif>
			
			<cfquery name="qAddNotes" datasource="#Application.Datasource#">
				INSERT INTO DD_Notes (Deduction_ID, DD_Note, DD_Note_Date, DD_Note_By, Automated_notes)
				VALUES (
							<cfqueryparam value="#qDDAssociatedtoBB.Deduction_ID#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#ddNoteText#" cfsqltype="cf_sql_varchar">,
							getdate(),
							<cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_varchar">,
							1
						)
			</cfquery>

			<cfquery name="qUpdateDeductionNumber" datasource="#application.datasource#">
				UPDATE 	Deductions
				SET 	DD_Status = CASE WHEN Is_Credit = 1 THEN 8 ELSE CASE WHEN Is_Last_Status_Rebill = 1 THEN 7 ELSE 2 END END,
						ReOpened = CASE WHEN DD_Closure_Sent = 1 THEN 1 ELSE ReOpened END,
						DD_ReOpened_On = getdate(),
						DD_Reopened_Sent = 0,				
						DD_Closure_Type = NULL, 
						DD_Closure_ID =  NULL,	
						DD_Closure_Sent = 0,
						DD_Closure_GL_Sent = 0,
						Ack_received_Closure = 0,	
						Ack_received_Reopen = 0
				WHERE 	Deductions.Deduction_ID = <cfqueryparam value="#qDDAssociatedtoBB.Deduction_ID#" cfsqltype="cf_sql_varchar">
			</cfquery>
			
		</cfloop>		
		<!--- END: loop thru each deduction for this BB and set the values for reopen --->

	</cffunction>	 
	
</cfcomponent>