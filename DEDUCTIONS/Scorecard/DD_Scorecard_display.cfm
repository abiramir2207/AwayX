<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<!---User profile--->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfset useLakebaseForDeductionsProfilesSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions_profiles_settings")>
<cfif useLakebaseForDeductionsProfilesSettings>
	<cftry>
		<cfset DeductionsProfilesSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions_profiles_settings", {
				"profiles_id" = "eq.#Get_Profile_Settings.Profiles_ID#"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDeductionsProfilesSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionsProfilesSettings>
<cfquery name="DeductionsProfilesSettings" datasource="#application.datasource#">
SELECT * FROM Deductions_Profiles_Settings WHERE Profiles_ID = '#Get_Profile_Settings.Profiles_ID#'
</cfquery>
</cfif>

<html>
<head>
	<title>Untitled</title>
</head>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<cfset UserPositionList = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.user_id, 0, 1) />

<!--- Show parent records  (Parent Deductions) by default --->
<CFPARAM NAME="URL.Show_Status" DEFAULT="">
<CFPARAM NAME="HIDE_PARENT" DEFAULT="0">
<CFPARAM NAME="FORM.SORT_BY" 	DEFAULT="DD_DedID">
<CFPARAM NAME="FORM.SORT_ORDER" 	DEFAULT="ASC">
<CFPARAM NAME="URL.SC_Shr_Ship_To" DEFAULT="">
<CFPARAM NAME="URL.SC_Broker_Shard" DEFAULT="">

<!--- (Start)Certain testing tool scripts behave unexpectedly at times.
We are specifically setting it to these values due to that reason --->
<cfif TRIM(FORM.SORT_BY) eq "">
	<cfset FORM.SORT_BY = "DD_DedID">
</cfif>

<cfif TRIM(FORM.SORT_ORDER) eq "">
	<cfset FORM.SORT_ORDER = "ASC">
</cfif>
<!--- (End)Certain testing tool scripts behave unexpectedly at times.
We are specifically setting it to these values due to that reason --->

<CFIF URL.SC_Shr_Ship_To EQ "" AND URL.SC_Broker_Shard EQ "">
	<cfset useLakebaseForGetSCDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("scorecard_customize")>
	<cfif useLakebaseForGetSCDefault>
		<cftry>
			<cfset GetSCDefault = application.oLakebase.toQuery(
				application.oLakebase.selectRows("scorecard_customize", {
					"scorecard_id" = "eq.4",
					"user_id" = "eq.#request.AccessStructure.User_ID#",
					"deleted" = "eq.0"
				})
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForGetSCDefault = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForGetSCDefault>
	<CFQUERY NAME="GetSCDefault" DATASOURCE="#Application.Datasource#">
		SELECT 		*
		FROM 		Scorecard_Customize
		WHERE 		Scorecard_ID = '4' AND
					USER_ID = '#request.AccessStructure.User_ID#' AND
					Deleted = 0
	</CFQUERY>
	</cfif>
	<CFIF GetSCDefault.RecordCount GT 0>
		<CFIF GetSCDefault.Shr_Ship_To NEQ "" AND LEN(GetSCDefault.Shr_Ship_To) GT 0>
			<CFSET URL.SC_Shr_Ship_To = GetSCDefault.Shr_Ship_To>
		</CFIF>

		<CFIF GetSCDefault.Broker_Shard NEQ "" AND LEN(GetSCDefault.Broker_Shard) GT 0>
			<CFSET URL.SC_Broker_Shard = GetSCDefault.Broker_Shard>
		</CFIF>
	</CFIF>
</CFIF>
<CFIF Isdefined("URL.Tier_Number")>
	<cfset useLakebaseForAge_Date_Range = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_aging")>
	<cfif useLakebaseForAge_Date_Range>
		<cftry>
			<cfset Age_Date_Range = application.oLakebase.toQuery(
				application.oLakebase.selectRows("dd_aging", {
					"tier_number" = "eq.#URL.Tier_Number#",
					"deleted" = "eq.0"
				})
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForAge_Date_Range = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForAge_Date_Range>
	<CFQUERY NAME="Age_Date_Range" DATASOURCE="#Application.Datasource#">
		SELECT * FROM DD_Aging WHERE TIer_Number = #URL.Tier_Number# AND Deleted = 0
	</CFQUERY>
	</cfif>
	<CFSET Aging_Start = Age_Date_Range.Start_Range>
	<CFSET Aging_End = Age_Date_Range.End_Range>
</CFIF>

<CFIF IsDefined("URL.DD_Classification_ID")>
	<cfset useLakebaseForCheckDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification")>
	<cfif useLakebaseForCheckDefault>
		<cftry>
			<cfset CheckDefault = application.oLakebase.toQuery(
				application.oLakebase.selectRows("dd_classification", {
					"dd_classification_id" = "eq.#URL.DD_Classification_ID#"
				})
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForCheckDefault = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForCheckDefault>
	<CFQUERY NAME="CheckDefault" DATASOURCE="#Application.Datasource#">
		SELECT * FROM DD_Classification WHERE DD_Classification_ID = '#URL.DD_Classification_ID#'
	</CFQUERY>
	</cfif>
</CFIF>


<cfset useLakebaseForUserHasAssignments = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
<cfif useLakebaseForUserHasAssignments>
	<cftry>
		<cfset UserHasAssignments = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_analyst", {
				"analyst_user_id" = "eq.#request.AccessStructure.User_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForUserHasAssignments = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUserHasAssignments>
<cfquery name="UserHasAssignments" datasource="#application.datasource#">
 SELECT * FROM DD_Analyst WHERE Analyst_User_ID = '#request.AccessStructure.User_ID#' AND Deleted=0
</cfquery>
</cfif>

<CFINCLUDE TEMPLATE="/Common_Files/Documents/User_Positions_Under_this_User.cfm">
<CFSET Access_Position_List = GP_Position_List_From_My_Position_Down>


<CFINCLUDE TEMPLATE="/Deductions/DD_Supervisor_Qry.cfm">
<!---if the application settings is in the application scope then get it from there--->

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<CFSET displayOnlyAssignedDeductions = appSettings.getDisplayOnlyAssignedDeductions()>

<CFIF Get_Profile_Settings.DD_RFA_Agreed EQ 1>
	<CFSET Auth_Sequence_Order = 0>
	<CFSET Auth_Sequence_ID = 0>
	<CFQUERY NAME="AuthoritySeq" DATASOURCE="#Application.Datasource#">
		SELECT Authority_Sequence_Order,Authority_Sequence_ID FROM Authority_Sequence WHERE Authority_Sequence_ID = (SELECT Authority_Sequence_ID FROM _Users WHERE User_ID = '#request.AccessStructure.User_ID#')
	</CFQUERY>
	<CFIF AuthoritySeq.recordCount GT 0>
		<CFSET Auth_Sequence_Order = AuthoritySeq.Authority_Sequence_Order>
		<CFSET Auth_Sequence_ID = AuthoritySeq.Authority_Sequence_ID>
	</CFIF>
</CFIF>

<CFQUERY NAME="SC_Display_Result" DATASOURCE="#Application.Datasource#">
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	IF OBJECT_ID('tempdb..##Tmp_Deduction_Table') IS NOT NULL
		DROP TABLE ##Tmp_Deduction_Table
	SELECT 			Deductions.Deduction_ID,
					Deductions.DD_Closure_Sent,
					Deductions.DD_Reopened_Sent,
					Deductions.Ack_Closure_Date,
					Deductions.Ack_received_Closure,
					Deductions.Ack_Reopen_Date,
					Deductions.Ack_received_Reopen,
					Deductions.ReOpened,
					Deductions.DD_DedID,
					Deductions.DD_IsParent,
					Deductions.DD_Parent_ID,
					Deductions.DD_IsChild,
					Deductions.DD_Amount,
					Deductions.DD_Date,
					Deductions.Analyst_User_ID,
					Deductions.SP_Number,
					Deductions.Is_Locked,
					Deductions.Locked_By,
					_Users.Name_First,
					_Users.Name_Last,
					_Users.User_ID,
					DD_Stage.DD_Stage_Description,
					Deductions.DD_Status,
					DD_Status.DD_Status_Description,
					Deductions.DD_Modified_On,
					Case When Deductions.DD_Status = 4 THEN
						DateDiff(d, Deductions.DD_Date, Deductions.DD_Date_Closed)
					Else
						DateDiff(d, Deductions.DD_Date, GetDate())
					End  AS DD_Age,
					Distributor_Bill_To.Name,
					Distributor_Bill_To.Shr_Bill_To,
					BSA_Foodservice_Brokers.Broker_Name,
					Service_Regions.Region_Name,
					DD_DedID_SP_Number,
					(	select count(*)
						from Contract_Attachments
						INNER JOIN 	Document_Details
								ON 	Document_Details.Doc_ID =  Contract_Attachments.Doc_ID
						where 	Deduction_ID	=	Deductions.Deduction_ID
						AND 	Contract_Attachments.Deleted = 0
						AND 	(	(	Public_View = 1
										AND User_Position_ID IN (#preserveSingleQuotes(Access_Position_List)#)
									)
									OR Public_View = 0
								)
					) as attachment_count,
					CASE WHEN BSA_Foodservice_Customers.Shr_ship_to IS NULL
					THEN
						Distributor_Bill_To.Name
					ELSE
						BSA_Foodservice_Customers.Name
					END AS Distributor_Name,
					<!--- Ana D19384 Rebill Interface Data --->
					BSA_Foodservice_Customers.Shr_ship_to,
					DRI.Rebill_Ack_Status,
					DRI.Rebill_Number,
					DRI.Rebill_Ack_On,
					DRI.Rebill_Sent_On,
					Is_Last_Status_Rebill
					,Deductions.Split_Count
	INTO			##Tmp_Deduction_Table
	FROM			Deductions
	LEFT JOIN		_Users 					ON _Users.User_ID = Deductions.Analyst_User_ID AND
					_Users.deleted=0
	LEFT JOIN 		DD_Stage 				ON DD_Stage.DD_Stage_ID = Deductions.DD_Stage AND DD_Stage.deleted=0
	INNER JOIN 		DD_Status 				ON DD_Status.DD_Status_ID = Deductions.DD_Status

	LEFT JOIN		BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID

	LEFT JOIN		Distributor_Bill_To 	ON Distributor_Bill_To.Distributor_Bill_To_ID = Deductions.Distributor_Bill_To_ID AND
											Distributor_Bill_To.Deleted=0
	LEFT JOIN		BSA_Foodservice_Brokers	ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Deductions.Broker_ID
	LEFT JOIN		Service_Regions 		ON Service_Regions.Service_Region_ID = BSA_Foodservice_Brokers.Service_Region_ID
	LEFT JOIN		Service_Markets 		ON Service_Markets.Service_Market_ID = BSA_Foodservice_Brokers.Service_Market_ID
	LEFT JOIN   	DD_Rebill_Integration DRI ON DRI.Deduction_ID = Deductions.Deduction_ID AND DRI.Deleted = 0
	LEFT JOIN 		Program_Agree_Status 	ON 1=2 <CFIF Get_Profile_Settings.DD_RFA_Agreed EQ 1>OR Deductions.DD_Status = 3</CFIF>
	WHERE 			Deductions.deleted=0 AND <cfif appSettings.getDDSentRejectIn1510() NEQ 1>Deductions.DD_Rejected=0 AND</CFIF>
					DD_Status.deleted=0 AND
					<CFIF Get_Profile_Settings.DD_RFA_Agreed EQ 1 AND URL.Show_Status EQ 3>
						<CFIF Program_Agree_Status_ID EQ 1>
							<CFIF UserIsASupervisor>
							( DD_Status = 3 AND Program_Agree_Status.Program_Agree_Status_ID = 1 AND
								NOT EXISTS
									(SELECT * FROM DD_Agreed_Info WHERE Deduction_ID = Deductions.Deduction_ID AND DD_Agreed_Info.User_ID = Deductions.Analyst_User_ID) AND
								NOT EXISTS
									(SELECT * FROM DD_Agreed_Info WHERE Deduction_ID = Deductions.Deduction_ID AND DD_Agreed_Info.User_ID = '#request.AccessStructure.User_ID#')
							)
							<CFELSEIF UserHasAssignments.RecordCount AND NOT UserIsASupervisor>
							1=2
							<CFELSE>
							( DD_Status = 3 AND Program_Agree_Status.Program_Agree_Status_ID = 1 AND
							  Not Exists
							 	(SELECT * FROM DD_Agreed_Info WHERE Deduction_ID = Deductions.Deduction_ID AND User_position_ID IN (#PreserveSingleQuotes(UserPositionList)#) AND Authority_Sequence_ID = '#Auth_Sequence_ID#')
							  AND
								(
									#Get_Profile_Settings.DD_ACCESS_LEVEL# = 0

									OR

									((		SELECT 	Top 1 User_positions_ID
											FROM 	Deductions_Approvable_Positions
											WHERE 	Deductions_Approvable_Positions.Deduction_ID = Deductions.Deduction_ID AND
													NOT (	(	ISNULL(Authority_Sequence_Order, 0) = 0 OR

																Authority_Sequence_Order IN (	SELECT 		ISNULL(Authority_Sequence_ORDER,0)
																								FROM 		DD_Agreed_Info
																								INNER JOIN 	Authority_Sequence ON Authority_Sequence.Authority_Sequence_ID = DD_Agreed_Info.Authority_Sequence_ID
																								WHERE 		Deduction_ID = Deductions.Deduction_ID)
															) AND
															User_positions_ID IN (		SELECT 	DISTINCT User_position_ID
																						FROM 	DD_Agreed_Info
																						WHERE 	Deduction_ID = Deductions.Deduction_ID AND
																						Deleted = 0)
														)
										) NOT IN (#PreserveSingleQuotes(UserPositionList)#))
									OR

									(	ISNULL((	SELECT 	Top 1 Authority_Sequence_Order
													FROM 	Deductions_Approvable_Positions
													WHERE 	Deductions_Approvable_Positions.Deduction_ID = Deductions.Deduction_ID AND
															NOT (	(	ISNULL(Authority_Sequence_Order, 0) = 0 OR
																		Authority_Sequence_Order IN (	SELECT 		ISNULL(Authority_Sequence_ORDER,0)
																										FROM	 	DD_Agreed_Info
																										INNER JOIN 	Authority_Sequence ON Authority_Sequence.Authority_Sequence_ID = DD_Agreed_Info.Authority_Sequence_ID
																										WHERE 		Deduction_ID = Deductions.Deduction_ID)
																	) AND
																	User_positions_ID IN (		SELECT 	DISTINCT User_position_ID
																								FROM 	DD_Agreed_Info
																								WHERE 	Deduction_ID = Deductions.Deduction_ID AND
																								Deleted = 0)
																)
												),0) <> '#Auth_Sequence_Order#')
								)
							)
							</CFIF>
						<CFELSEIF Program_Agree_Status_ID EQ 2>
							<CFIF UserIsASupervisor>
							( DD_Status = 3 AND Program_Agree_Status.Program_Agree_Status_ID = 2 AND
								EXISTS
									(SELECT * FROM DD_Agreed_Info WHERE Deduction_ID = Deductions.Deduction_ID AND DD_Agreed_Info.User_ID = Deductions.Analyst_User_ID) AND
								NOT EXISTS
									(SELECT * FROM DD_Agreed_Info WHERE Deduction_ID = Deductions.Deduction_ID AND DD_Agreed_Info.User_ID = '#request.AccessStructure.User_ID#')
							)
							<CFELSEIF UserHasAssignments.RecordCount AND NOT UserIsASupervisor>
							( DD_Status = 3 AND Program_Agree_Status.Program_Agree_Status_ID = 2 AND
								NOT EXISTS
									(SELECT * FROM DD_Agreed_Info WHERE Deduction_ID = Deductions.Deduction_ID AND DD_Agreed_Info.User_ID = '#request.AccessStructure.User_ID#')
							)
							<CFELSE>
							( DD_Status = 3 AND Program_Agree_Status.Program_Agree_Status_ID = 2 AND
							  Not Exists
							 	(SELECT * FROM DD_Agreed_Info WHERE Deduction_ID = Deductions.Deduction_ID AND User_position_ID IN (#PreserveSingleQuotes(UserPositionList)#) AND Authority_Sequence_ID = '#Auth_Sequence_ID#')
							  AND
								(
									#Get_Profile_Settings.DD_ACCESS_LEVEL# > 0

									AND

									((	SELECT 	Top 1 User_positions_ID
											FROM 	Deductions_Approvable_Positions
											WHERE 	Deductions_Approvable_Positions.Deduction_ID = Deductions.Deduction_ID AND
													NOT (	(	ISNULL(Authority_Sequence_Order, 0) = 0 OR
																Authority_Sequence_Order IN (	SELECT 		ISNULL(Authority_Sequence_ORDER,0)
																								FROM 		DD_Agreed_Info
																								INNER JOIN 	Authority_Sequence ON Authority_Sequence.Authority_Sequence_ID = DD_Agreed_Info.Authority_Sequence_ID
																								WHERE 		Deduction_ID = Deductions.Deduction_ID)
															) AND
															User_positions_ID IN (	SELECT 	DISTINCT User_position_ID
																					FROM 	DD_Agreed_Info
																					WHERE 	Deduction_ID = Deductions.Deduction_ID AND
																							Deleted = 0)
														)
										) IN (#PreserveSingleQuotes(UserPositionList)#))
									AND

									(	ISNULL((	SELECT 	Top 1 Authority_Sequence_Order
													FROM 	Deductions_Approvable_Positions
													WHERE 	Deductions_Approvable_Positions.Deduction_ID = Deductions.Deduction_ID AND
															NOT (	(	ISNULL(Authority_Sequence_Order, 0) = 0 OR
																		Authority_Sequence_Order IN (	SELECT 		ISNULL(Authority_Sequence_ORDER,0)
																										FROM 		DD_Agreed_Info
																										INNER JOIN 	Authority_Sequence ON Authority_Sequence.Authority_Sequence_ID = DD_Agreed_Info.Authority_Sequence_ID
																										WHERE 		Deduction_ID = Deductions.Deduction_ID)
																	) AND
																	User_positions_ID IN (	SELECT 	DISTINCT User_position_ID
																							FROM 	DD_Agreed_Info
																							WHERE 	Deduction_ID = Deductions.Deduction_ID AND
																									Deleted = 0)
																) ORDER BY Authority_Sequence_Order DESC
												),0) = '#Auth_Sequence_Order#'
									)
								)
							)
							</CFIF>
						<CFELSEIF Program_Agree_Status_ID EQ 3>
							<CFIF UserIsASupervisor OR (UserHasAssignments.RecordCount AND NOT UserIsASupervisor)>
							(DD_Status = 3 AND Program_Agree_Status.Program_Agree_Status_ID = 3 AND
								EXISTS
								(SELECT * FROM DD_Agreed_Info WHERE Deduction_ID = Deductions.Deduction_ID AND DD_Agreed_Info.User_ID = '#request.AccessStructure.User_ID#')
							)
							<CFELSE>
							(DD_Status = 3 AND Program_Agree_Status.Program_Agree_Status_ID = 3 AND
							  Exists
							  (SELECT * FROM DD_Agreed_Info WHERE Deduction_ID = Deductions.Deduction_ID AND User_position_ID IN (#PreserveSingleQuotes(UserPositionList)#) AND Authority_Sequence_ID = '#Auth_Sequence_ID#')
							)
							</CFIF>
						</CFIF>
					<CFELSE>
						Deductions.DD_Status = '#URL.Show_Status#'
					</CFIF>
				<!------------------------ check access permission - start -------------------------------------->
					<CFIF DeductionsProfilesSettings.DD_ACCESS_LEVEL>
						<cfif displayOnlyAssignedDeductions and UserHasAssignments.RecordCount>
							AND Deductions.Analyst_User_ID = '#request.AccessStructure.User_ID#'
						<cfelse>
<!-----
--------------------------------------------------------------------------------------------------------------------
Scorecard (Profile Search by Analyst has no effect)
										Profile Search By Analyst = ON/OFF
--------------------------------------------------------------------------------------------------------------------
HQ (not Analyst / not Supervisor)		All
HQ (Analyst / Supervisor)				Based on analyst assignment only
Non HQ (not Analyst / not Supervisor)	Based on user position only
Non HQ (Analyst / Supervisor)			Based on analyst assignment only
------>
							<CFIF UserHasAssignments.RecordCount AND NOT UserIsASupervisor> <!--- Just an anlayst ---->
							AND Deductions.Analyst_User_ID = '#request.AccessStructure.User_ID#'
							<CFELSEIF UserIsASupervisor> <!---- Supervisor ----->
							AND Deductions.Analyst_User_ID IN (#LISTQUALIFY(AnalystUnderMe_List,"'",",","All")#)
							<CFELSEIF ListFind(UserPositionList, HQPosition.User_Positions_ID)> <!---- not analyst, not supervisor, is an HQ ----->
							AND 1 = 1
							<CFELSE> <!---- not analyst, not supervisor, not HQ ---->
							AND Service_Markets.Service_Market_ID IN (	SELECT DISTINCT Service_Markets.Service_Market_ID

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

																		WHERE User_Positions.User_Positions_ID IN (#PreserveSingleQuotes(UserPositionList)#)
											)
							</CFIF>
						</cfif>
					<CFELSE>
						AND 1=2
					</cfif>
<!------------------------ check access permission end -------------------------------------->
					<CFIF URL.SC_Shr_Ship_To NEQ "">
						AND

						( BSA_Foodservice_Customers.Shr_Ship_To IN ( #listQualify( URL.SC_Shr_Ship_To, "'", "," )# ) OR Distributor_Bill_To.Shr_Bill_To IN ( #listQualify( URL.SC_Shr_Ship_To, "'", "," )# ) )
					</CFIF>
					<CFIF URL.SC_Broker_Shard NEQ "">
						AND BSA_Foodservice_Brokers.Broker_Shard = '#TRIM(URL.SC_Broker_Shard)#'
					</CFIF>
					<CFIF Isdefined("URL.DD_Stage_ID")>
						AND DD_Stage = #URL.DD_Stage_ID#
					</CFIF>
					<CFIF ISDefined("URL.DD_Classification_ID")>
						AND
						<CFIF CheckDefault.Is_Default>
							(Deductions.DD_Classification_ID = '#DD_Classification_ID#' OR Deductions.DD_Classification_ID IS NULL)
						<CFELSE>
							Deductions.DD_Classification_ID = '#DD_Classification_ID#'
						</CFIF>
					</CFIF>
					<CFIF HIDE_PARENT EQ 1>
						 AND Deductions.Deduction_ID NOT IN
						 	(SELECT Deductions.Deduction_ID
							 FROM Deductions Deductions_1
							 WHERE Deleted = 0
							 AND Deductions_1.DD_Parent_ID  = Deductions.Deduction_ID)
					</CFIF>
					<CFIF Isdefined("URL.Tier_Number")>
						<CFIF Aging_End EQ "">
							AND DateDiff(d,CONVERT(Char(10),Deductions.DD_Date,101),CONVERT(Char(10),getdate(),101)) >= '#Aging_Start#'
						<CFELSE>
							AND DateDiff(d,CONVERT(Char(10),Deductions.DD_Date,101),CONVERT(Char(10),getdate(),101)) Between '#Aging_Start#' AND '#Aging_End#'
						</CFIF>
					</CFIF>

	SELECT	* FROM ##Tmp_Deduction_Table
	ORDER BY		<CFIF FORM.SORT_BY EQ "Name">
						<!--- BSA_Foodservice_Customers.Name --->
						Distributor_Name
					<CFELSEIF FORM.SORT_BY EQ "Broker_Name">
						<!--- BSA_Foodservice_Brokers.Broker_Name --->
						Broker_Name
					<CFELSE>
						#FORM.SORT_BY#
					</CFIF> #FORM.SORT_ORDER#

	DROP TABLE ##Tmp_Deduction_Table

</CFQUERY>

<!--- Dev Note for 9103 Clay : Ship to filter was not passed in the next/previous links --->
<FORM NAME="DD_Scorecard" ACTION=<CFOUTPUT>"DD_Scorecard_Display.cfm?Show_Status=#URL.Show_Status#<CFIF ISDefined("URL.DD_Stage_ID")>&DD_Stage_ID=#URL.DD_Stage_ID#</CFIF><CFIF ISDefined("URL.Tier_Number")>&Tier_Number=#URL.Tier_Number#</CFIF><CFIF ISDefined("URL.Program_Agree_Status_ID")>&Program_Agree_Status_ID=#URL.Program_Agree_Status_ID#</CFIF><CFIF ISDefined("URL.SC_SHR_SHIP_TO")>&SC_SHR_SHIP_TO=#URL.SC_SHR_SHIP_TO#</CFIF>"</CFOUTPUT> METHOD="post">

	<cfparam name="FORM.startrow"  default="1">
   	<cfparam name="FORM.frompage"   default="1">
   	<cfparam name="FORM.pageLength"  default="100">
   	<cfset startrow=FORM.startrow>
   	<cfset frompage=FORM.frompage>
   	<cf_Number_of_Rows maxrows="#FORM.pageLength#">

	<CFOUTPUT>
   	<input type="hidden" value = "#FORM.frompage#" name="frompage">
	<input type="hidden" value = "#FORM.StartRow#" name="startrow">
	<input type="hidden" value = "#FORM.SORT_BY#" name="SORT_BY">
	<input type="hidden" value = "#FORM.SORT_ORDER#" name="SORT_ORDER">
	<input type="hidden" value = "#HIDE_PARENT#" name="HIDE_PARENT">
	</CFOUTPUT>

	<CFQUERY NAME="Get_Max_Aging" DATASOURCE="#Application.Datasource#">
		SELECT 	*
		FROM 	DD_Aging
		WHERE 	Tier_Number = (	SELECT 	MAX(Tier_Number)
								FROM 	DD_Aging
								WHERE 	Deleted=0	) AND
				Deleted=0
	</CFQUERY>

	<CFSET LastAgeEndRange = Get_Max_Aging.Start_Range>
	<CFSET LastAgeLabel = Get_Max_Aging.DD_Aging_Label>
	<CFSET ReopenMessageDisplay = 0 />
	<CFSET ReopenNotAckRowColor = "FFDDDD" />
	<TABLE CLASS="Maintable" WIDTH="1250" BORDER="0" CELLPADDING="1" CELLSPACING="0" ALIGN="center">
		<CFOUTPUT QUERY="SC_Display_Result" startrow="#StartRow#" maxrows="#MaxRows#">
		<CFSET sBGColor = IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6')) />
		<cfif ReOpened EQ 1 AND Ack_received_Reopen EQ 0>
			<cfset sBGColor = ReopenNotAckRowColor />
			<CFSET ReopenMessageDisplay = 1 />
		</cfif>
		<TR BGCOLOR="#sBGColor#">
		<TD WIDTH="30">
			<CFIF attachment_count GT 0>
				<IMG SRC="/images/doc.gif" width="13" height="16" TITLE="This program has #attachment_count# attached document(s)" height="16" width="13">
			<CFELSE>
				<IMG SRC="/images/fill.gif" width="13" height="16">
			</CFIF>

			<CFIF Is_Locked EQ 1>
				<cfset useLakebaseForGetLockedBy = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGetLockedBy>
	<cftry>
		<cfset GetLockedBy = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#Locked_By#",
				"deleted" = "eq.0",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetLockedBy = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetLockedBy>
<CFQUERY NAME="GetLockedBy" DATASOURCE="#Application.Datasource#">
					SELECT Name_First,Name_Last FROM _Users WHERE User_ID = '#Locked_By#' AND Deleted=0
				</CFQUERY>
</cfif>
				<IMG SRC="/images/lock.gif" TITLE="This deduction is locked by user #ucase(GetLockedBy.Name_First)# #ucase(GetLockedBy.Name_Last)#" height="16" width="12">
			<CFELSE>
			&nbsp;
			</CFIF>
		</TD>
		<!--- <TD WIDTH="20">&nbsp;
				<CFIF DD_IsParent EQ 1>
					<CFQUERY NAME="Check_Child" DATASOURCE="#Application.Datasource#">
						SELECT * FROM Deductions WHERE DD_DedID = '#DD_DedID#' AND Deleted=0
					</CFQUERY>
					<CFIF Check_Child.Recordcount GT 1>
						<CFSET ChildCount = Check_Child.Recordcount - 1>
						<img src="/Images/parent_New.gif" alt="Splitted into #ChildCount# deductions." width="13" height="13" border="0">
					</CFIF>
				<CFELSE>
					<A HREF="/deductions/deduction.cfm?Deduction_ID=#DD_Parent_ID#" target="_parent"><img src="/Images/child_New.gif" alt="Click to view original deduction." width="13" height="13" border="0"></A>
				</CFIF>
		</TD> --->
		<TD WIDTH="180">
			<B><FONT COLOR="red" SIZE="2">[ </FONT><A HREF="/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#" target="_parent">#DD_DedID_SP_Number#<!--- #DD_DedID# - <CFIF SP_Number EQ "">000<CFELSE>#SP_Number#</CFIF> ---></A><FONT COLOR="red" SIZE="2"> ]</FONT></B>
		<br>&nbsp;<A onClick="javaScript: NewWindow(this.href , 'Preview' , 850 , 600 , 'yes' , 'yes'); return false;" target="_blank" HREF="/deductions/inc_deduction_details.cfm?Deduction_ID=#Deduction_ID#&Display=Preview" STYLE="FONT-SIZE:10PX;" TITLE="View the details for deduction #DD_DedID#"><font color="660033"><b>Preview</b></font></A>
		<!--- D42846 :: Deduction tool upgrades --->
		<cfif (
			( (DD_Status LTE 3 OR DD_Status EQ 8) AND appSettings.get_Setting('deduction_Quick_Update_For_New_Open_RFA') eq '1')
			OR ( DD_Status EQ 4 AND appSettings.getDeductionQuickUpdate() ))
			AND (Is_Locked EQ 0 OR Locked_By EQ '#request.AccessStructure.user_ID#')>
		<font color="660033"> / </font>
		&nbsp;<A onClick="javaScript: NewWindow(this.href , 'Update' , 850 , 600 , 'yes' , 'yes'); return false;" target="_blank" HREF="/deductions/update_status.cfm?Deduction_ID=#Deduction_ID#" STYLE="FONT-SIZE:10PX;" TITLE="Quick update for deduction #DD_DedID#"><font color="660033"><b>Update</b></font></A>
		</cfif>

		<cfif appSettings.get_Setting('Quick_Pay_in_Program_Search') eq '2' AND Get_Profile_Settings.AQP_Available EQ 1 AND (DD_ISParent EQ 0 OR Split_Count EQ 0) AND (Is_Locked EQ 0 OR Locked_By EQ '#request.AccessStructure.user_ID#') AND NOT (ReOpened EQ 1 AND Ack_received_Reopen EQ 0	AND appSettings.getDD_Reopen_Interface() EQ 0)>
		<cfif (appSettings.getDDAllowNegativeAmountCredits() AND (DD_Status LT 3 OR DD_Status EQ 8) ) OR (! appSettings.getDDAllowNegativeAmountCredits() AND DD_Status LT 3)>
			<font color="660033"> / </font>
			<a onClick="javaScript:QuickPay('#Deduction_ID#')"><font style="font-weight:bold; color:660033">Quick Pay</font></a>
		</cfif>
		</cfif>

		<table border="0" cellpadding="0" cellspacing="0" width="100%" STYLE="Border-botton: none">
			<TR>
				<TD HEIGHT="10" STYLE="Border-bottom: none">
				<CFIF DD_IsParent EQ 1>
					<CFQUERY NAME="Check_Child" DATASOURCE="#Application.Datasource#">
						SELECT * FROM Deductions WHERE DD_DedID = '#DD_DedID#' AND Deleted=0
					</CFQUERY>
					<CFIF Check_Child.Recordcount GT 1>
						<CFSET ChildCount = Check_Child.Recordcount - 1>
						<img src="/Images/parent_New.gif" title="Split into #ChildCount# deductions." width="13" height="13" border="0">
					</CFIF>
				<CFELSE>
					<A HREF="/deductions/deduction.cfm?Deduction_ID=#DD_Parent_ID#" target="_parent"><img src="/Images/child_New.gif" title="Click to view original deduction." width="13" height="13" border="0"></A>
				</CFIF>

				</TD>
				<!--- Ana D19384 Rebill Interface Arrow --->
				<TD Align="Right" STYLE="Border-bottom: none">
				<CFIF DD_Status EQ 8 OR DD_Status EQ 9>
					<CFSET DD_Type = "Credit">
				<CFELSEIF DD_Status EQ 7 OR Is_Last_Status_Rebill EQ 1>
					<CFSET DD_Type = "Rebill">
				<CFELSE>
					<CFSET DD_Type = "Deduction">
				</CFIF>
				<CFIF DD_Closure_Sent EQ 1 OR Ack_received_Closure EQ 1 OR Ack_received_Reopen EQ 1 OR DD_Reopened_Sent EQ 1>
					<cfset useLakebaseForDD_SentDate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_closure_detail")>
<cfif useLakebaseForDD_SentDate>
	<cftry>
		<cfset DD_SentDate = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_closure_detail", {
				"deduction_id" = "eq.#Deduction_ID#",
				"interfaced_on" = "not.is.null",
				"deleted" = "eq.0",
				"limit" = "1",
				"select" = "interfaced_on"
			}), "interfaced_on"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDD_SentDate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDD_SentDate>
<CFQUERY NAME="DD_SentDate" DATASOURCE="#Application.Datasource#">
					SELECT TOP 1 Interfaced_On FROM DD_Closure_Detail WHERE Deduction_ID = '#Deduction_ID#' AND Interfaced_On IS NOT NULL AND Deleted = 0
					</CFQUERY>
</cfif>
				<CFELSEIF Rebill_Ack_Status EQ 3 OR Rebill_Ack_Status EQ 2>
					<CFSET DD_SentDate.Interfaced_On = Rebill_Sent_On>
				</CFIF>
				<CFIF Ack_received_Closure EQ 1 OR Ack_received_Reopen EQ 1 OR Rebill_Ack_Status EQ 3>
					<CFIF Ack_received_Closure EQ 1>
						<CFSET Ack_Date_Disp = Ack_Closure_Date>
					<CFELSEIF  Ack_received_Reopen EQ 1>
						<CFSET Ack_Date_Disp = Ack_Reopen_Date>
					<CFELSE>
						<CFSET Ack_Date_Disp = Rebill_Ack_On>
					</CFIF>
					<IMG SRC="/images/arrow2.gif" width="10" height="10" title="This #DD_Type# has been successfully loaded in ERP <CFIF Rebill_Number NEQ "">#chr(13)##chr(10)#Rebill Num: #Rebill_Number#</CFIF>#chr(13)##chr(10)#Send Date: <cfif isDefined("Is_Write_off") and Is_Write_off EQ 1>#DD_Ack_Sent_Date#<cfelse>#DD_SentDate.Interfaced_On#</cfif>  #chr(13)##chr(10)#Acknowledge Date: #Ack_Date_Disp#">&nbsp;&nbsp;
				<CFELSEIF (DD_Closure_Sent EQ 1 AND Ack_received_Closure EQ 0) OR (DD_Reopened_Sent EQ 1 AND Ack_received_Reopen EQ 0) OR (Rebill_Ack_Status EQ 2)>
					<IMG SRC="/images/arrow1.gif" width="10" height="10" title="This #DD_Type# is being sent to ERP <CFIF Rebill_Number NEQ "">#chr(13)##chr(10)#Rebill Num: #Rebill_Number#</CFIF>#chr(13)##chr(10)#Send Date: #DD_SentDate.Interfaced_On#">&nbsp;&nbsp;
				</CFIF>
				</TD>
				</TR>
			</table>
		</TD>
		<TD WIDTH="260" TITLE="Bill To Name: #Name##Chr(13)##application.returned_customer_setting.billto_label# Number: #Shr_Bill_To##Chr(13)##application.returned_customer_setting.shard_ship_to_label#: #Shr_ship_to#">
			#DollarFormat(DD_Amount)#
			<Br>
			<CFSET DispName = TRIM(Distributor_Name)>
			<CFSET DispNameLen = LEN(DispName)>
			<CFIF DispNameLen GT 30>
				<CFSET DispName = LEFT(DispName,30)>
				#DispName#...
			<CFELSE>
				#DispName#
			</CFIF>
			<!--- #Name# --->
		</TD>
		<td width="62">
		 #DateFormat(DD_Date, "MM/DD/YYYY")#
		</td>
		<TD WIDTH="175">
			<CFIF DD_Age GTE LastAgeEndRange>
					#LastAgeLabel#
			<CFELSE>
				<CFQUERY NAME="Get_Aging_Details" DATASOURCE="#Application.Datasource#">
					SELECT * FROM DD_Aging WHERE Deleted=0 AND Start_Range <= '#DD_Age#' AND End_Range >= '#DD_Age#'
				</CFQUERY>
				#Get_Aging_Details.DD_Aging_Label#
			</CFIF>
			<Br>
			#DD_Stage_Description#
		</TD>
		<TD WIDTH="260" TITLE="Broker: #Broker_Name# #Chr(13)#Region: #Region_Name#">
			<CFSET DispBrok = TRIM(Broker_Name)>
			<CFSET DispBrokLen = LEN(DispBrok)>
			<CFIF DispBrokLen GT 30>
				<CFSET DispBrok = LEFT(DispBrok,30)>
				#DispBrok#...
			<CFELSE>
				#DispBrok#
			</CFIF>
			<!--- #Broker_Name# --->
			<Br>
			<CFSET DispRegion = TRIM(Region_Name)>
			<CFSET DispRegionLen = LEN(DispRegion)>
			<CFIF DispRegionLen GT 30>
				<CFSET DispRegion = LEFT(DispRegion,30)>
				#DispRegion#...
			<CFELSE>
				#DispRegion#
			</CFIF>
			<!--- #Region_Name# --->
		</TD>
		<TD WIDTH="175">
			#Name_First# #Name_Last#
		</TD>
		<CFIF DeductionsProfilesSettings.DD_Delete EQ 1 AND DD_Status LT 4>
			<TD WIDTH="10">
				<A Href="Javascript: DeleteUnDelete(1,'#DD_DedID_SP_Number#','#Deduction_ID#')"><img  src="/Images/scissor.gif" width="14" height="9" title="Delete this deduction" border="0"></A>
			</TD>
		<CFELSEIF DeductionsProfilesSettings.DD_Delete EQ 1 AND DD_Status EQ 6>
			<TD WIDTH="10">
				<A Href="Javascript: DeleteUnDelete(2,'#DD_DedID_SP_Number#','#Deduction_ID#')"><img src="/images/undo.gif" title="Undelete this deduction" border="0"></A>
			</TD>
		</CFIF>
		</TR>
		</CFOUTPUT>
	</TABLE>

	<TABLE BORDER="0" width="1250" CELLPADDING="0" CELLSPACING="0">
		<TR>
			<TD>
			<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
			    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			    <CF_Next_Previous_For_Forms
			    formname="DD_Scorecard"
			    query="SC_Display_Result"
			    maxpages="25"
			    previous  = "<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
			    next   = "<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
			    previousseries = "<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
			    nextseries  = "<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
			    addparams="">
		   </DIV>
			</TD>
			<TD ALIGN="Right" style="font-size: 12px;"><FONT SIZE="2" COLOR="Red"><B>There are <CFOUTPUT>#SC_Display_Result.recordcount#</CFOUTPUT> Deductions in This Status.</B></FONT>
			<cfoutput>
			<cfif ReopenMessageDisplay><br><span style="background-color:#ReopenNotAckRowColor#">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> Highlighted deductions have been reopened but not yet acknowledged</cfif>
			</cfoutput>
			</TD>
		</TR>
	</TABLE>

</FORM>

<SCRIPT language="JavaScript">
function DeleteUnDelete(Type,DedNo,DedID)
{
	if (Type == 1)
	{
		if(window.confirm("Do you want to delete deduction [" + DedNo + "] ?"))
		{
			NewWindow("Confirm_Delete.cfm?DelFlag=" + Type + "&DD_DedID=" + DedNo + "&Deduction_ID=" +DedID, 'delete_Deduction' , 600 , 500 , 'yes' , 'yes');
		}
	}
	else if (Type == 2)
	{
		if(window.confirm("Do you want to undelete deduction [" + DedNo + "] ?"))
		{
			NewWindow("Confirm_Delete.cfm?DelFlag=" + Type + "&DD_DedID=" + DedNo + "&Deduction_ID=" +DedID, 'delete_Deduction' , 600 , 500 , 'yes' , 'yes');
		}
	}
}
function QuickPay(DDID){
	var QuickPayHeight =  window.screen.height;
	var QuickPayWidth =  window.screen.width;
	window.open('/Scorecard/adv_quick_pay_DD.cfm?<cfoutput>Overspend=#Get_Profile_Settings.AQP_Max_Overspend#</cfoutput>&Deduction_ID='+DDID,'AdvanceQuickPay','width='+QuickPayWidth+',height='+QuickPayHeight+',scrollbars=1');
}
</SCRIPT>
</body>
</html>
<!---
			<TD WIDTH="88"><B><FONT COLOR="red" SIZE="2">[ </FONT><A HREF="/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#" target="_parent">#DD_DedID#</A><FONT COLOR="red" SIZE="2"> ]</FONT></B></TD>
			<TD WIDTH="145">
				<CFIF DD_IsParent EQ 1>
					<img src="/Images/parent_New.gif" alt="" width="13" height="13" border="0">
				<CFELSE>
					<A HREF="/deductions/deduction.cfm?Deduction_ID=#DD_Parent_ID#"><img src="/Images/child_New.gif" alt="" width="13" height="13" border="0"></A>
				</CFIF>
			</TD>
			<TD WIDTH="83">#DollarFormat(DD_Amount)#</TD>
			<TD WIDTH="110">
				<CFSET NumberOfDays = DateDiff("d",DateFormat(DD_Date,"mm/dd/yyyy"),DateFormat(now(),"mm/dd/yyyy"))>
				<CFIF NumberOfDays GTE LastAgeEndRange>
					#LastAgeLabel# -- #SC_Display_Result.DD_Age# days
				<CFELSE>
				<CFQUERY NAME="Get_Aging_Details" DATASOURCE="#Application.Datasource#">
					SELECT * FROM DD_Aging WHERE Deleted=0 AND Start_Range <= '#NumberOfDays#' AND End_Range >= '#NumberOfDays#'
				</CFQUERY>
				#Get_Aging_Details.DD_Aging_Label# -- #SC_Display_Result.DD_Age# days
				</CFIF>
			</TD> --->
