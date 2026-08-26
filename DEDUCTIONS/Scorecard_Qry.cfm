<!--- Dev Note: KAL; 7821 --->
<cfset DD_Status_toHide	= CreateObject("component", "components.Deduction.settings.DeductionSettingsManager").DD_Status_Control(request.AccessStructure.profiles_id) />

	<cfset Query_Item_Array = ArrayNew(2) /> <!--- Dev Note: KAL; 7821 --->

	<cfif ListFind(DD_Status_toHide, 1) EQ 0>
		<cfset Query_Item_Array[ArrayLen(Query_Item_Array)+1][1] = "NewDeductionsForUser" />
		<cfset Query_Item_Array[ArrayLen(Query_Item_Array)][2] = 1 />
	</cfif>
	<cfif ListFind(DD_Status_toHide, 2) EQ 0>
		<cfset Query_Item_Array[ArrayLen(Query_Item_Array)+1][1] = "OpenDeductionsForUser" />
		<cfset Query_Item_Array[ArrayLen(Query_Item_Array)][2] = 2 />
	</cfif>
  <!---
	  Dev Notes: 19384/Anand Rao/16-Apr-10
  	Rebill Interface and changes/
    Added the new appsetting
  --->
	<cfif ListFind(DD_Status_toHide, 7) EQ 0>
		<cfif (application.returned_customer_setting.DD_Show_Rebill EQ 1 OR appSettings.getIntegrated_Rebill() EQ 1)>
			<cfset Query_Item_Array[ArrayLen(Query_Item_Array)+1][1] = "RebillDeductionsForUser" />
			<cfset Query_Item_Array[ArrayLen(Query_Item_Array)][2] = 7 />
		</cfif>
	</cfif>
	<cfif ListFind(DD_Status_toHide, 3) EQ 0>
		<cfif Get_Profile_Settings.DD_RFA_Agreed EQ 0>
			<cfset Query_Item_Array[ArrayLen(Query_Item_Array)+1][1] = "RFADeductionsForUser" />
			<cfset Query_Item_Array[ArrayLen(Query_Item_Array)][2] = 3 />
		</cfif>
	</cfif>

	<cfif ListFind(DD_Status_toHide, 4) EQ 0>
		<cfset Query_Item_Array[ArrayLen(Query_Item_Array)+1][1] = "ClosedDeductionsForUser" />
		<cfset Query_Item_Array[ArrayLen(Query_Item_Array)][2] = 4 />
	</cfif>

	<cfif ListFind(DD_Status_toHide, 5) EQ 0>
		<cfset Query_Item_Array[ArrayLen(Query_Item_Array)+1][1] = "AutoClosedDeductionsForUser" />
		<cfset Query_Item_Array[ArrayLen(Query_Item_Array)][2] = 5 />
	</cfif>

	<cfif ListFind(DD_Status_toHide, 6) EQ 0>
		<cfset Query_Item_Array[ArrayLen(Query_Item_Array)+1][1] = "DeletedDeductionsForUser" />
		<cfset Query_Item_Array[ArrayLen(Query_Item_Array)][2] = 6 />
	</cfif>

	<CFIF AppLevelAllowCredits EQ 1>
		<cfif ListFind(DD_Status_toHide, 8) EQ 0>
			<cfset Query_Item_Array[ArrayLen(Query_Item_Array)+1][1] = "CreditsForUser" />
			<cfset Query_Item_Array[ArrayLen(Query_Item_Array)][2] = 8 />
		</cfif>
	 	<cfif ListFind(DD_Status_toHide, 9) EQ 0>
			<cfset Query_Item_Array[ArrayLen(Query_Item_Array)+1][1] = "ClosedCreditsForUser" />
			<cfset Query_Item_Array[ArrayLen(Query_Item_Array)][2] = 9 />
		</cfif>
	</CFIF>

	<CFIF URL.SC_Shr_Ship_To NEQ "">
		<cfset Distributor_ID  = Replace(URL.SC_Shr_Ship_To, "#chr(39)#", "", "ALL")>

		<cfset Distributor_ID  = Replace(Distributor_ID, "#chr(13)##chr(10)#",",", "ALL")>

			<CFQUERY NAME="Dist_Search_Result" DATASOURCE = "#Application.Datasource#">
				SELECT BSA_Foodservice_Customers_ID
				FROM BSA_Foodservice_Customers
				WHERE
				/* Label 9812- From the advanced search, we have search coming as a text search, and so I made it as varchar */
				/* Label 14445 - Do not add cfqueryparam here. It might not return results. */
				BSA_Foodservice_Customers.Shr_Ship_To IN ( #ListQualify(Distributor_ID, "'", ",")# )
				AND BSA_Foodservice_Customers.Deleted = 0
				AND BSA_Foodservice_Customers.Active_Code = 'A'

				UNION

				SELECT Distributor_Bill_To_ID As BSA_Foodservice_Customers_ID
				FROM Distributor_Bill_To
				WHERE
				/* Label 9812- From the advanced search, we have search coming as a text search, and so I made it as varchar */
				/* Label 14445 - Do not add cfqueryparam here. It might not return results. */
				Distributor_Bill_To.Shr_Bill_To IN ( #ListQualify(Distributor_ID, "'", ",")# )
				AND Distributor_Bill_To.Deleted = 0
				AND Distributor_Bill_To.Active_Code = 'A'
			</CFQUERY>

			<CFIF Dist_Search_Result.Recordcount neq 0>
						<CFSET Distributor_ID = TRIM(ValueList(Dist_Search_Result.BSA_Foodservice_Customers_ID))>
			<CFELSE>
						<CFSET Distributor_ID =  ''>
			</CFIF>
		</CFIF>

<cfloop index="Qry_Count" from="1" to="#ArrayLen(Query_Item_Array)#">
<cfquery name="#Query_Item_Array[Qry_Count][1]#" datasource="#application.datasource#" cachedafter="#cacheSpan#">
	SELECT  	count(Deductions.Created_Date) AS Deductions,
				isnull(sum(Deductions.DD_Amount), 0) AS Dollar_Amount

	FROM 		Deductions  WITH (NOLOCK)
	LEFT JOIN		BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID
	LEFT JOIN		BSA_Foodservice_Brokers	ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Deductions.Broker_ID
	LEFT JOIN		Service_Markets 		ON Service_Markets.Service_Market_ID = BSA_Foodservice_Brokers.Service_Market_ID
	WHERE		<CFIF DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 0>
				<!------------------------ check access permission - start -------------------------------------->
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
					<cfif displayOnlyAssignedDeductions AND (isDefined("UserHasAssignments.RecordCount") AND UserHasAssignments.RecordCount)>
						Deductions.Analyst_User_ID = '#request.AccessStructure.User_ID#' AND
					<cfelse>
						(
						<CFIF (isDefined("UserHasAssignments.RecordCount") AND UserHasAssignments.RecordCount) AND NOT IaASupervisor.RecordCount><!--- Just an anlayst ---->
							Deductions.Analyst_User_ID = '#request.AccessStructure.User_ID#'
						<CFELSEIF UserIsASupervisor> <!---- Supervisor ----->
							Deductions.Analyst_User_ID IN (#listQualify(AnalystUnderMe_List,"'",",","ALL")#)
						<CFELSEIF ListFind(UserPositionList, HQPosition.User_Positions_ID)> <!---- not analyst, not supervisor, is an HQ ----->
							1=1
						<CFELSE> <!---- not analyst, not supervisor, not HQ ---->
							Service_Markets.Service_Market_ID IN (	SELECT DISTINCT Service_Markets.Service_Market_ID

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
																						)
						</CFIF>
						) AND

					</cfif>
				<CFELSE>
				1=2 AND
				<!------------------------ check access permission - end -------------------------------------->
				</CFIF>

				<CFIF URL.SC_Shr_Ship_To NEQ "">
					<cfif Distributor_ID eq "">
					1=2
					<cfelse>
					(
					Deductions.Distributor_ID IN (#ListQualify(Distributor_ID, "'", ",")#)
					OR
					Deductions.Distributor_Bill_To_ID IN (#ListQualify(Distributor_ID, "'", ",")#)
					)
					</cfif>
					AND
				</CFIF>
				<CFIF URL.SC_Broker_Shard NEQ "">
					BSA_Foodservice_Brokers.Broker_Shard = '#TRIM(URL.SC_Broker_Shard)#' AND
				</CFIF>
				<CFIF URL.ScorecardToShow EQ "Age">
					(DateDiff(d, getdate(), Deductions.DD_Date) * -1) >= #Start_Range# AND
					(DateDiff(d, getdate(), Deductions.DD_Date) * -1) <= #End_Range#  AND
				<CFELSEIF URL.ScorecardToShow EQ "Action">
					DD_Stage = '#DD_Stage_ID#' AND
				<CFELSE>
					<CFIF Is_Default EQ 1>
					(DD_Classification_ID = '#DD_Classification_ID#' OR DD_Classification_ID IS NULL) AND
					<CFELSE>
					DD_Classification_ID = '#DD_Classification_ID#' AND
					</CFIF>
				</CFIF>
				DD_Status = #Query_Item_Array[Qry_Count][2]# AND
				Deductions.Deleted = 0 <cfif appSettings.getDDSentRejectIn1510() NEQ 1>AND DD_Rejected=0</CFIF>
				<cfif chkHideParent>
					AND Deductions.Deduction_ID NOT IN
						 	(SELECT Deductions.Deduction_ID
							 FROM Deductions Deductions_1
							 WHERE Deleted = 0
							 AND Deductions_1.DD_Parent_ID  = Deductions.Deduction_ID)
				</cfif>


</cfquery>
</cfloop>



<CFIF Get_Profile_Settings.DD_RFA_Agreed EQ 1>
	<cfquery name="UnderReviewDeductionsForUser" datasource="#application.datasource#" cachedafter="#cacheSpan#"><!---   --->
		SELECT 		count(Deductions.Created_Date) AS Deductions,
					sum(Deductions.DD_Amount) AS Dollar_Amount
		FROM 		Deductions  WITH (NOLOCK)
		LEFT JOIN		BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID
		LEFT JOIN		BSA_Foodservice_Brokers	ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Deductions.Broker_ID
		LEFT JOIN		Service_Markets 		ON Service_Markets.Service_Market_ID = BSA_Foodservice_Brokers.Service_Market_ID
		LEFT JOIN 	Program_Agree_Status 		ON Deductions.DD_Status = 3
		WHERE 		<CFIF DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 0>
					<!------------------------ check access permission - start -------------------------------------->
						<cfif displayOnlyAssignedDeductions and (isDefined("UserHasAssignments.RecordCount") AND UserHasAssignments.RecordCount)>
							Deductions.Analyst_User_ID = '#request.AccessStructure.User_ID#' AND
						<cfelse>
							(
							<CFIF (isDefined("UserHasAssignments.RecordCount") AND UserHasAssignments.RecordCount) AND NOT IaASupervisor.RecordCount><!--- Just an anlayst ---->
								Deductions.Analyst_User_ID = '#request.AccessStructure.User_ID#'
							<CFELSEIF UserIsASupervisor> <!---- Supervisor ----->
								Deductions.Analyst_User_ID IN (#listQualify(AnalystUnderMe_List,"'",",","ALL")#)
							<CFELSEIF ListFind(UserPositionList, HQPosition.User_Positions_ID)> <!---- not analyst, not supervisor, is an HQ ----->
								1 = 1
							<CFELSE> <!---- not analyst, not supervisor, not HQ ---->
								Service_Markets.Service_Market_ID IN (	SELECT DISTINCT Service_Markets.Service_Market_ID

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
																							)
							</CFIF>
							) AND
						</cfif>
					<CFELSE>
					1=2 AND
					<!------------------------ check access permission - end -------------------------------------->
					</CFIF>

					<CFIF URL.SC_Shr_Ship_To NEQ "">
					<cfif Distributor_ID eq "">
					1=2
					<cfelse>
					(
					Deductions.Distributor_ID IN (#ListQualify(Distributor_ID, "'", ",")#)
					OR
					Deductions.Distributor_Bill_To_ID IN (#ListQualify(Distributor_ID, "'", ",")#)
					)
					</cfif>
					AND
					</CFIF>
					<CFIF URL.SC_Broker_Shard NEQ "">
						BSA_Foodservice_Brokers.Broker_Shard = '#TRIM(URL.SC_Broker_Shard)#' AND
					</CFIF>
					<CFIF URL.ScorecardToShow EQ "Age">
						(DateDiff(d, getdate(), Deductions.DD_Date) * -1) >= #Start_Range# AND
						(DateDiff(d, getdate(), Deductions.DD_Date) * -1) <= #End_Range# AND
					<CFELSEIF URL.ScorecardToShow EQ "Action">
						DD_Stage = '#GetActions.DD_Stage_ID#' AND
					<CFELSE>
						<CFIF Is_Default EQ 1>
						(DD_Classification_ID = '#DD_Classification_ID#' OR DD_Classification_ID IS NULL) AND
						<CFELSE>
						DD_Classification_ID = '#DD_Classification_ID#' AND
						</CFIF>
					</CFIF>


					<!--- UnderReview --->
					<CFIF UserIsASupervisor EQ 1>
					( DD_Status = 3 AND Program_Agree_Status.Program_Agree_Status_ID = 1 AND
						NOT EXISTS
							(SELECT * FROM DD_Agreed_Info WHERE Deduction_ID = Deductions.Deduction_ID AND DD_Agreed_Info.User_ID = Deductions.Analyst_User_ID) AND
						NOT EXISTS
							(SELECT * FROM DD_Agreed_Info WHERE Deduction_ID = Deductions.Deduction_ID AND DD_Agreed_Info.User_ID = '#request.AccessStructure.User_ID#')
					) AND
					<CFELSEIF (isDefined("UserHasAssignments.RecordCount") AND UserHasAssignments.RecordCount GT 0) AND IaASupervisor.RecordCount EQ 0>
					1=2 AND
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
					) AND
					</CFIF>
					<!--- UnderReview --->
					Deductions.Deleted = 0 <cfif appSettings.getDDSentRejectIn1510() NEQ 1>AND DD_Rejected=0</CFIF>
					<cfif chkHideParent eq 1>
					AND Deductions.Deduction_ID NOT IN
							 	(SELECT Deductions.Deduction_ID
								 FROM Deductions Deductions_1
								 WHERE Deleted = 0
								 AND Deductions_1.DD_Parent_ID  = Deductions.Deduction_ID)
					</cfif>
	</cfquery>

	<cfquery name="PendingApprovalDeductionsForUser" datasource="#application.datasource#" cachedafter="#cacheSpan#"><!---   --->
		SELECT 		count(Deductions.Created_Date) AS Deductions,
					sum(Deductions.DD_Amount) AS Dollar_Amount
		FROM 		Deductions  WITH (NOLOCK)
		LEFT JOIN		BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID
		LEFT JOIN		BSA_Foodservice_Brokers	ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Deductions.Broker_ID
		LEFT JOIN		Service_Markets 		ON Service_Markets.Service_Market_ID = BSA_Foodservice_Brokers.Service_Market_ID
		LEFT JOIN 	Program_Agree_Status 		ON Deductions.DD_Status = 3
		WHERE 		<CFIF DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 0>
					<!------------------------ check access permission - start -------------------------------------->
						<cfif displayOnlyAssignedDeductions and (isDefined("UserHasAssignments.RecordCount") AND UserHasAssignments.RecordCount)>
							Deductions.Analyst_User_ID = '#request.AccessStructure.User_ID#' AND
						<cfelse>
							(
							<CFIF (isDefined("UserHasAssignments.RecordCount") AND UserHasAssignments.RecordCount) AND NOT IaASupervisor.RecordCount><!--- Just an anlayst ---->
								Deductions.Analyst_User_ID = '#request.AccessStructure.User_ID#'
							<CFELSEIF UserIsASupervisor> <!---- Supervisor ----->
								Deductions.Analyst_User_ID IN (#listQualify(AnalystUnderMe_List,"'",",","ALL")#)
							<CFELSEIF ListFind(UserPositionList, HQPosition.User_Positions_ID)> <!---- not analyst, not supervisor, is an HQ ----->
								1 = 1
							<CFELSE> <!---- not analyst, not supervisor, not HQ ---->
								Service_Markets.Service_Market_ID IN (	SELECT DISTINCT Service_Markets.Service_Market_ID

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
																							)
							</CFIF>
							) AND
						</cfif>
					<CFELSE>
					1=2 AND
					<!------------------------ check access permission - end -------------------------------------->
					</CFIF>

					<CFIF URL.SC_Shr_Ship_To NEQ "">
					<cfif Distributor_ID eq "">
					1=2
					<cfelse>
					(
					Deductions.Distributor_ID IN (#ListQualify(Distributor_ID, "'", ",")#)
					OR
					Deductions.Distributor_Bill_To_ID IN (#ListQualify(Distributor_ID, "'", ",")#)
					)
					</cfif>
					AND
					</CFIF>
					<CFIF URL.SC_Broker_Shard NEQ "">
						BSA_Foodservice_Brokers.Broker_Shard = '#TRIM(URL.SC_Broker_Shard)#' AND
					</CFIF>
					<CFIF URL.ScorecardToShow EQ "Age">
						(DateDiff(d, getdate(), Deductions.DD_Date) * -1) >= #Start_Range# AND
						(DateDiff(d, getdate(), Deductions.DD_Date) * -1) <= #End_Range# AND
					<CFELSEIF URL.ScorecardToShow EQ "Action">
						DD_Stage = '#GetActions.DD_Stage_ID#' AND
					<CFELSE>
						<CFIF Is_Default EQ 1>
						(DD_Classification_ID = '#DD_Classification_ID#' OR DD_Classification_ID IS NULL) AND
						<CFELSE>
						DD_Classification_ID = '#DD_Classification_ID#' AND
						</CFIF>
					</CFIF>
					<!--- Pending Approval --->
					<CFIF UserIsASupervisor EQ 1>
					( DD_Status = 3 AND Program_Agree_Status.Program_Agree_Status_ID = 2 AND
						EXISTS
							(SELECT * FROM DD_Agreed_Info WHERE Deduction_ID = Deductions.Deduction_ID AND DD_Agreed_Info.User_ID = Deductions.Analyst_User_ID) AND
						NOT EXISTS
							(SELECT * FROM DD_Agreed_Info WHERE Deduction_ID = Deductions.Deduction_ID AND DD_Agreed_Info.User_ID = '#request.AccessStructure.User_ID#')
					) AND
					<CFELSEIF (isDefined("UserHasAssignments.RecordCount") AND UserHasAssignments.RecordCount GT 0) AND IaASupervisor.RecordCount EQ 0>
					( DD_Status = 3 AND Program_Agree_Status.Program_Agree_Status_ID = 2 AND
						NOT EXISTS
							(SELECT * FROM DD_Agreed_Info WHERE Deduction_ID = Deductions.Deduction_ID AND DD_Agreed_Info.User_ID = '#request.AccessStructure.User_ID#')
					) AND
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
					) AND
					</CFIF>
					<!--- Pending Approval --->

					Deductions.Deleted = 0 <cfif appSettings.getDDSentRejectIn1510() NEQ 1>AND DD_Rejected=0</CFIF>
					<cfif chkHideParent eq 1>
					AND Deductions.Deduction_ID NOT IN
							 	(SELECT Deductions.Deduction_ID
								 FROM Deductions Deductions_1
								 WHERE Deleted = 0
								 AND Deductions_1.DD_Parent_ID  = Deductions.Deduction_ID)
					</cfif>
	</cfquery>

	<cfquery name="AgreedDeductionsForUser" datasource="#application.datasource#" cachedafter="#cacheSpan#"><!---   --->
		SELECT 		count(Deductions.Created_Date) AS Deductions,
					sum(Deductions.DD_Amount) AS Dollar_Amount
		FROM 		Deductions  WITH (NOLOCK)
		LEFT JOIN		BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID
		LEFT JOIN		BSA_Foodservice_Brokers	ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Deductions.Broker_ID
		LEFT JOIN		Service_Markets 		ON Service_Markets.Service_Market_ID = BSA_Foodservice_Brokers.Service_Market_ID
		LEFT JOIN 	Program_Agree_Status 		ON Deductions.DD_Status = 3
		WHERE 		<CFIF DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 0>
						<cfif displayOnlyAssignedDeductions and (isDefined("UserHasAssignments.RecordCount") AND UserHasAssignments.RecordCount)>
							Deductions.Analyst_User_ID = '#request.AccessStructure.User_ID#' AND
						<cfelse>
							(
							<CFIF (isDefined("UserHasAssignments.RecordCount") AND UserHasAssignments.RecordCount) AND NOT IaASupervisor.RecordCount> <!--- Just an anlayst ---->
								Deductions.Analyst_User_ID = '#request.AccessStructure.User_ID#'
							<CFELSEIF UserIsASupervisor> <!---- Supervisor ----->
								Deductions.Analyst_User_ID IN (#listQualify(AnalystUnderMe_List,"'",",","ALL")#)
							<CFELSEIF ListFind(UserPositionList, HQPosition.User_Positions_ID)> <!---- not analyst, not supervisor, is an HQ ----->
								1 = 1
							<CFELSE> <!---- not analyst, not supervisor, not HQ ---->
								Service_Markets.Service_Market_ID IN (	SELECT DISTINCT Service_Markets.Service_Market_ID

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
																							)
							</CFIF>
							) AND
						</cfif>
					</CFIF>

					<CFIF URL.SC_Shr_Ship_To NEQ "">
					<cfif Distributor_ID eq "">
					1=2
					<cfelse>
					(
					Deductions.Distributor_ID IN (#ListQualify(Distributor_ID, "'", ",")#)
					OR
					Deductions.Distributor_Bill_To_ID IN (#ListQualify(Distributor_ID, "'", ",")#)
					)
					</cfif>
					AND
					</CFIF>
					<CFIF URL.SC_Broker_Shard NEQ "">
						BSA_Foodservice_Brokers.Broker_Shard = '#TRIM(URL.SC_Broker_Shard)#' AND
					</CFIF>
					<CFIF URL.ScorecardToShow EQ "Age">
						(DateDiff(d, getdate(), Deductions.DD_Date) * -1) >= #Start_Range# AND
						(DateDiff(d, getdate(), Deductions.DD_Date) * -1) <= #End_Range# AND
					<CFELSEIF URL.ScorecardToShow EQ "Action">
						DD_Stage = '#GetActions.DD_Stage_ID#' AND
					<CFELSE>
						<CFIF Is_Default EQ 1>
						(DD_Classification_ID = '#DD_Classification_ID#' OR DD_Classification_ID IS NULL) AND
						<CFELSE>
						DD_Classification_ID = '#DD_Classification_ID#' AND
						</CFIF>
					</CFIF>
					<!--- Agreed --->
					<CFIF UserIsASupervisor EQ 1 OR ((isDefined("UserHasAssignments.RecordCount") AND UserHasAssignments.RecordCount GT 0) AND IaASupervisor.RecordCount EQ 0)>
					(DD_Status = 3 AND Program_Agree_Status.Program_Agree_Status_ID = 3 AND
						EXISTS
						(SELECT * FROM DD_Agreed_Info WHERE Deduction_ID = Deductions.Deduction_ID AND DD_Agreed_Info.User_ID = '#request.AccessStructure.User_ID#')
					) AND
					<CFELSE>
					(DD_Status = 3 AND Program_Agree_Status.Program_Agree_Status_ID = 3 AND
					  Exists
					  (SELECT * FROM DD_Agreed_Info WHERE Deduction_ID = Deductions.Deduction_ID AND User_position_ID IN (#PreserveSingleQuotes(UserPositionList)#) AND Authority_Sequence_ID = '#Auth_Sequence_ID#')
					) AND
					</CFIF>
					<!--- Agreed --->

					Deductions.Deleted = 0 <cfif appSettings.getDDSentRejectIn1510() NEQ 1>AND DD_Rejected=0</CFIF>
					<cfif chkHideParent eq 1>
					AND Deductions.Deduction_ID NOT IN
							 	(SELECT Deductions.Deduction_ID
								 FROM Deductions Deductions_1
								 WHERE Deleted = 0
								 AND Deductions_1.DD_Parent_ID  = Deductions.Deduction_ID)
					</cfif>
	</cfquery>

</CFIF>
