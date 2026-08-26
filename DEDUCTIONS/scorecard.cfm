<HTML>
<cfset application.util.query.request_settings()>
	<!--- Show parent records by default --->
	<CFPARAM NAME="chkHideParent" default="0">
	<cfparam name="chkRefreshView" 	default="0">
	<CFPARAM name="URL.useCache" default="#request.settings.deductionScorecardCache#">

	<!--- Dev Note: KAL; 7916 : Setting all Dollar amount to Zero --->
	<cfparam name="New_Dollar_Amount" 			default="0">
	<cfparam name="Open_Dollar_Amount" 			default="0">
	<cfparam name="Rebill_Dollar_Amount" 		default="0">
	<cfparam name="UR_Dollar_Amount" 			default="0">
	<cfparam name="PA_Dollar_Amount" 			default="0">
	<cfparam name="Agreed_Dollar_Amount" 		default="0">
	<cfparam name="RFA_Dollar_Amount" 			default="0">
	<cfparam name="Closed_Dollar_Amount" 		default="0">
	<cfparam name="AutoClosed_Dollar_Amount" 	default="0">
	<cfparam name="Deleted_Dollar_Amount" 		default="0">
	<cfparam name="Credits_Dollar_Amount" 		default="0">
	<cfparam name="ClosedCredits_Dollar_Amount" default="0">
	<CFPARAM NAME="URL.SC_Shr_Ship_To" 			DEFAULT="">
	<CFPARAM NAME="URL.SC_Broker_Shard" 		DEFAULT="">

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
			SELECT *
			FROM Scorecard_Customize
			WHERE Scorecard_ID = '4' AND USER_ID = '#request.AccessStructure.User_ID#' AND Deleted = 0
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

	<cfparam name="cacheSpan" default="0" />

	<cfset cacheSpan = DateAdd("n",5,Now())  />    <!--- This is a fix for a CF Bug.  Set it to a future date or else it uses cache --->
	<cfif (chkRefreshView EQ 0 OR URL.useCache EQ '1')>
		<cfset cacheSpan = createodbcdatetime("#DateFormat(Now(), "mm/dd/yyyy")#") /> <!--- this creates a data with 0 hour,minute, seconds.... midnight so the cache gets used all day --->
	</cfif>

	<cfset textBoxSize = "12" />
	<!---User profile--->
	<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
	<!--- Dev Note: KAL; 7821 --->
	<cfset DD_Status_toHide	= CreateObject("component", "components.Deduction.settings.DeductionSettingsManager").DD_Status_Control(request.AccessStructure.profiles_id) />

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

	<!---if the application settings is in the application scope then get it from there--->
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>

	<CFSET displayOnlyAssignedDeductions = appSettings.getDisplayOnlyAssignedDeductions()>
	<CFSET AppLevelAllowCredits = appSettings.getDDAllowNegativeAmountCredits()>

	<HEAD>
	<META http-equiv="Content-Language" content="en-us">
	<META http-equiv="Content-Type" content="text/html; charset=windows-1252">
	<TITLE>Deduction Scorecard</TITLE>
	</HEAD>

	<BODY bgcolor="#FFFFEA">
	<STYLE>
		body,td	{
			font-family:	Arial, Helvetica, sans-serif;
			font-size:		10px;
		}
		.biglink {
			color:			Blue;
			text-decoration:None;
			font-size:		12px;
			font-weight:	Bold;
		}
		.bigtext {
			color:			Black;
			text-decoration:None;
			font-size:		10px;
			font-weight:	Bold;
		}
		input {
			border:			1px solid silver;
			color:			Navy;
			font-weight:	Bold;
		}
	</STYLE>

	<CFIF URL.ScorecardToShow EQ "Age">
		<cfquery name="GetAges" datasource="#application.datasource#">
			SELECT DD_Aging_Label, Start_Range, isnull(End_Range, 10000) as End_Range, Tier_Number, Aging_Count, ColorID, FontID
			FROM DD_Aging
			WHERE Deleted = 0
			ORDER BY Start_Range ASC
		</cfquery>
	<CFELSEIF URL.ScorecardToShow EQ "action">
		<cfquery name="GetActions" datasource="#application.datasource#">
			SELECT DD_Stage_Description, DD_Stage_ID
			FROM DD_Stage
			 WHERE Deleted = 0
			ORDER BY Is_Default ASC
		</cfquery>
	<CFELSE>
		<cfquery name="GetClass" datasource="#application.datasource#">
			SELECT DD_Classification_Desc, DD_Classification_ID, Is_Default
			FROM DD_Classification
			WHERE Deleted = 0
			ORDER BY Is_Default ASC
		</cfquery>
	</CFIF>

	<CFQUERY NAME="GetStatus" DATASOURCE="#Application.Datasource#">
		SELECT 	DD_Status_ID,
				<CFIF Get_Profile_Settings.DD_RFA_Agreed EQ 1>
				CASE
				WHEN DD_Status_ID = 3 THEN
				Program_Agree_Status.Program_Agree_Status_Desc
				ELSE
				DD_Status_Description
				END As DD_Status_Description
				<CFELSE>
				DD_Status_Description
				</CFIF>,
				Program_Agree_Status_ID,
				DD_Status_Order
		FROM 	DD_Status

		LEFT JOIN Program_Agree_Status ON 1 = 2 <CFIF Get_Profile_Settings.DD_RFA_Agreed EQ 1>OR DD_Status_ID = 3</CFIF>
		WHERE 	<CFIF (application.returned_customer_setting.DD_Show_Rebill NEQ 1 AND appSettings.getIntegrated_Rebill() NEQ 1)>
				DD_Status_ID <> 7 AND
				</CFIF>
				<CFIF AppLevelAllowCredits NEQ 1>
				DD_Status_ID NOT IN (8,9) AND
				</CFIF>
				DD_Status_ID NOT IN (4,5,6,9) AND
				DD_Status.Deleted = 0
		ORDER BY DD_Status_Order, Program_Agree_Status_ID
	</CFQUERY>
	<CFQUERY NAME="GetStatusDeduction" dbtype="query">
		SELECT	*
		FROM	GetStatus
		WHERE	DD_Status_ID NOT IN (8) <!--- add to this list if there are more credit status --->
		ORDER BY DD_Status_Order, Program_Agree_Status_ID
	</CFQUERY>
	<CFQUERY NAME="GetStatusCredit" dbtype="query">
		SELECT	*
		FROM	GetStatus
		WHERE	DD_Status_ID IN (8) <!--- add to this list if there are more credit status --->
		ORDER BY DD_Status_Order, Program_Agree_Status_ID
	</CFQUERY>

	<!--- initialize variables --->
	<cfset inputFontStyle = "font-size:10px;" />
	<cfset tdSTyle = "padding:0 4 0 4;" />
	<cfset sCountFormat = "___,___,___,___,___" />
	<cfset sRowTotalCellStyle = "border-left:1px solid gray;border-right:1px solid gray;" />
	<cfset sRowTotalCreditCellStyle = "border-right:1px solid gray;" />
	<cfset sColumnTotalCellStyle = "border-top:3px double gray;" />
	<cfset ColumnRowTotal = 0 />
	<cfset arColumnTotal = ArrayNew(1) />
	<CFLOOP QUERY="GetStatusDeduction">
		<cfset ArrayAppend(arColumnTotal, 0) />
	</CFLOOP>
	<CFLOOP QUERY="GetStatusCredit">
		<cfset ArrayAppend(arColumnTotal, 0) />
	</CFLOOP>

		<!--- DELETE THIS LATER --->
		<CFQUERY NAME="GetRFASubDiv" DATASOURCE="#Application.Datasource#">
			SELECT Program_Agree_Status_ID,Program_Agree_Status_Desc FROM Program_Agree_Status
		</CFQUERY>


	<style>
		table.deduction_summary td {
			padding-bottom: 10px;
			padding-right: 10px;
		}
	</style>
	<TABLE border="0" CELLPADDING="0" CELLSPACING="0" class="deduction_summary">
		<CFOUTPUT>
		<tr>
			<td TITLE="Click to set this scorecard view as your default.">&nbsp;</td>
			<!---- we need to put the row total before the credit column, so we are using 2 queries to loop over ------>
			<cfloop list="DED,CRD" index="currentItem">
				<cfif currentItem eq "DED">
					<cfset qStatus = GetStatusDeduction />
				<cfelse>
					<cfset qStatus = GetStatusCredit />
				</cfif>
				<CFLOOP QUERY="qStatus">
					<cfif ListFind(DD_Status_toHide, DD_STATUS_ID) EQ 0>
						<cfset variables.url_params = arrayToList([  "SC_Shr_Ship_To=#URL.SC_Shr_Ship_To#" & (Get_Profile_Settings.DD_RFA_Agreed EQ 1
																													? "&Program_Agree_Status_ID=#Program_Agree_Status_ID#"
																													: "")
																	,"SC_Broker_Shard=#URL.SC_Broker_Shard#"
																	,"Show_Status=#DD_Status_ID#"
																	,"chkHideParent=#chkHideParent#"
																], "&")>
						<CFIF DD_STATUS_ID EQ 8>
							<td class="bigtext" align="center" style="#tdSTyle##sRowTotalCreditCellStyle#">
								<a href="/deductions/scorecard/index.cfm?#variables.url_params#" target="_parent">Total Credits</a>
							</td>
						<CFELSE>
							<td class="bigtext" align="center">
								<a href="/deductions/scorecard/index.cfm?#variables.url_params#" target="_parent">#DD_Status_Description#</a>
							</td>
						</CFIF>
					</cfif>
				</CFLOOP>
				<cfif currentItem eq "DED">
					<!---- row total ------>
					<td class="bigtext" align="center" style="#sRowTotalCellStyle#;color:##343540;">Total Deductions</td>
				</cfif>
			</cfloop>

		</CFOUTPUT>

	<cfquery name="UserHasAssignments" datasource="#application.datasource#">
		SELECT * FROM DD_Analyst WHERE Analyst_User_ID = '#request.AccessStructure.User_ID#' AND Deleted=0
	</cfquery>

	<cfswitch expression="#URL.ScorecardToShow#">
		<cfcase value="Age">
			<CFSET QueryName="GetAges">
		</cfcase>
		<cfcase value="Action">
			<CFSET QueryName="GetActions">
		</cfcase>
		<cfdefaultcase>
			<CFSET QueryName="GetClass">
		</cfdefaultcase>
	</cfswitch>

	<CFINCLUDE TEMPLATE="DD_Supervisor_Qry.cfm">

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


	<cfset UserPositionList = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.user_id, 0, 1) />
	<cfoutput query="#QueryName#">
		<cfset rowTotal = 0 />
		<CFINCLUDE TEMPLATE="Scorecard_Qry.cfm">

			<cfif IsDefined("NewDeductionsForUser") AND IsQuery(NewDeductionsForUser)>
				<cfif len(trim(NewDeductionsForUser.Dollar_Amount)) IS 0>
					<cfset New_Dollar_Amount="0">
				<cfelse>
					<cfset New_Dollar_Amount = NewDeductionsForUser.Dollar_Amount>
				</cfif>
				<cfset New_Deductions = NewDeductionsForUser.Deductions>
			</cfif>

			<cfif IsDefined("OpenDeductionsForUser") AND IsQuery(OpenDeductionsForUser)>
				<cfif len(trim(OpenDeductionsForUser.Dollar_Amount)) IS 0>
					<cfset Open_Dollar_Amount="0">
				<cfelse>
					<cfset Open_Dollar_Amount = OpenDeductionsForUser.Dollar_Amount>
				</cfif>
				<cfset Open_Deductions = OpenDeductionsForUser.Deductions>
			</cfif>
		<!---
			Dev Notes: 19384/Anand Rao/16-Apr-10
			Rebill Interface and changes/
		  Added the new appsettings here and also in the above query
		--->

			<CFIF (application.returned_customer_setting.DD_Show_Rebill EQ 1 OR appSettings.getIntegrated_Rebill() EQ 1)>
				<cfif IsDefined("RebillDeductionsForUser") AND IsQuery(RebillDeductionsForUser)>
					<cfif len(trim(RebillDeductionsForUser.Dollar_Amount)) IS 0>
						<cfset Rebill_Dollar_Amount="0">
					<cfelse>
						<cfset Rebill_Dollar_Amount = RebillDeductionsForUser.Dollar_Amount>
					</cfif>
					<cfset Rebill_Deductions = RebillDeductionsForUser.Deductions>
				</cfif>
			</CFIF>

			<CFIF Get_Profile_Settings.DD_RFA_Agreed EQ 1>
				<cfif IsDefined("UnderReviewDeductionsForUser") AND IsQuery(UnderReviewDeductionsForUser)>
					<cfif len(trim(UnderReviewDeductionsForUser.Dollar_Amount)) IS 0>
						<CFSET UnderReview_Dollar_Amount="0">
						<cfset UR_Dollar_Amount="0">
					<cfelse>
						<cfset UnderReview_Dollar_Amount = UnderReviewDeductionsForUser.Dollar_Amount>
						<cfset UR_Dollar_Amount = UnderReviewDeductionsForUser.Dollar_Amount>
					</cfif>
					<cfset UnderReview_Deductions = UnderReviewDeductionsForUser.Deductions>
				</cfif>
				<cfif IsDefined("PendingApprovalDeductionsForUser") AND IsQuery(PendingApprovalDeductionsForUser)>
					<cfif len(trim(PendingApprovalDeductionsForUser.Dollar_Amount)) IS 0>
						 <cfset PendingApproval_Dollar_Amount="0">
						<cfset PA_Dollar_Amount="0">
					<cfelse>
						<cfset PendingApproval_Dollar_Amount = PendingApprovalDeductionsForUser.Dollar_Amount>
						<cfset PA_Dollar_Amount = PendingApprovalDeductionsForUser.Dollar_Amount>
					</cfif>
					<cfset PendingApproval_Deductions = PendingApprovalDeductionsForUser.Deductions>
				</cfif>
				<cfif IsDefined("AgreedDeductionsForUser") AND IsQuery(AgreedDeductionsForUser)>
					<cfif len(trim(AgreedDeductionsForUser.Dollar_Amount)) IS 0>
						<cfset Agreed_Dollar_Amount="0">
					<cfelse>
						<cfset Agreed_Dollar_Amount = AgreedDeductionsForUser.Dollar_Amount>
					</cfif>
					<cfset Agreed_Deductions = AgreedDeductionsForUser.Deductions>
				</cfif>
			<CFELSE>
				<cfif IsDefined("RFADeductionsForUser") AND IsQuery(RFADeductionsForUser)>
					<cfif len(trim(RFADeductionsForUser.Dollar_Amount)) IS 0>
						<cfset RFA_Dollar_Amount="0">
					<cfelse>
						<cfset RFA_Dollar_Amount = RFADeductionsForUser.Dollar_Amount>
					</cfif>
					<cfset RFA_Deductions = RFADeductionsForUser.Deductions>
				</cfif>
			</CFIF>

			<cfif IsDefined("ClosedDeductionsForUser") AND IsQuery(ClosedDeductionsForUser)>
				<cfif len(trim(ClosedDeductionsForUser.Dollar_Amount)) IS 0>
					<cfset Closed_Dollar_Amount="0">
				<cfelse>
					<cfset Closed_Dollar_Amount = ClosedDeductionsForUser.Dollar_Amount>
				</cfif>
				<cfset Closed_Deductions = ClosedDeductionsForUser.Deductions>
			</cfif>

			<cfif IsDefined("AutoClosedDeductionsForUser") AND IsQuery(AutoClosedDeductionsForUser)>
				<cfif len(trim(AutoClosedDeductionsForUser.Dollar_Amount)) IS 0>
					<cfset AutoClosed_Dollar_Amount="0">
				<cfelse>
					<cfset AutoClosed_Dollar_Amount = AutoClosedDeductionsForUser.Dollar_Amount>
				</cfif>
				<cfset AutoClosed_Deductions = AutoClosedDeductionsForUser.Deductions>
			</cfif>

			<cfif IsDefined("DeletedDeductionsForUser") AND IsQuery(DeletedDeductionsForUser)>
				<cfif len(trim(DeletedDeductionsForUser.Dollar_Amount)) IS 0>
					<cfset Deleted_Dollar_Amount="0">
				<cfelse>
					<cfset Deleted_Dollar_Amount = DeletedDeductionsForUser.Dollar_Amount>
				</cfif>
				<cfset Deleted_Deductions = DeletedDeductionsForUser.Deductions>
			</cfif>

			<CFIF AppLevelAllowCredits EQ 1>
			<cfparam name="Credit_Dollar_Amount" default=0>
			<cfparam name="Credits_Dollar_Amount" default=0>

				<cfif IsDefined("CreditsForUser") AND IsQuery(CreditsForUser)>
					<cfif len(trim(CreditsForUser.Dollar_Amount)) IS 0>
						<cfset Credit_Dollar_Amount="0">
						<cfset Credits_Dollar_Amount="0">
					<cfelse>
						<cfset Credit_Dollar_Amount = CreditsForUser.Dollar_Amount>
						<cfset Credits_Dollar_Amount = CreditsForUser.Dollar_Amount>
					</cfif>
					<cfset Credit_Deductions = CreditsForUser.Deductions>
				</cfif>
				<cfif IsDefined("ClosedCreditsForUser") AND IsQuery(ClosedCreditsForUser)>
					<cfif len(trim(ClosedCreditsForUser.Dollar_Amount)) IS 0>
						<cfset ClosedCredit_Dollar_Amount="0">
						<cfset ClosedCredits_Dollar_Amount="0">
					<cfelse>
						<cfset ClosedCredit_Dollar_Amount = ClosedCreditsForUser.Dollar_Amount>
						<cfset ClosedCredits_Dollar_Amount = ClosedCreditsForUser.Dollar_Amount>
					</cfif>
					<cfset ClosedCredit_Deductions = ClosedCreditsForUser.Deductions>
				</cfif>
			</CFIF>

		<form name="frmScorecard">

	<cfswitch expression="#URL.ScorecardToShow#">
		<cfcase value="Age">
		 <TR>
			<TD>
				#DD_Aging_Label#
				<span style="background-color:#colorID#">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
				(#Start_Range# - <Cfif End_Range IS "10000">*<cfelse>#End_Range#</CFIF>)
			</TD>
			<CFSET ThisTier_Number = Tier_Number>
			<!---- we need to put the row total before the credit column, so we are using 2 queries to loop over ------>
			<cfset loopIndex = 1 />
			<cfloop list="DED,CRD" index="currentItem">
				<cfif currentItem eq "DED">
					<cfset qStatus = GetStatusDeduction />
				<cfelse>
					<cfset qStatus = GetStatusCredit />
				</cfif>

				<CFLOOP QUERY="qStatus">
					<CFSET StatusVar = REPLACE(DD_Status_Description," ","","All")>
					<CFSET ThisStatusVal = 0>
					<CFSET ThisStatusValNoFormat = 0>
					<CFIF ScorecardToShow_basedon EQ "dollar">
						<CFSET ThisStatusValNoFormat = EVALUATE("#StatusVar#_Dollar_Amount") />
						<CFSET ThisStatusVal = DOLLARFORMAT(ThisStatusValNoFormat)>
					<CFELSE>
						<cfif isDefined("#StatusVar#_Deductions")>
						<CFSET ThisStatusValNoFormat = EVALUATE("#StatusVar#_Deductions") />
						<CFSET ThisStatusVal = NumberFormat(ThisStatusValNoFormat, sCountFormat)>
						</cfif>
					</CFIF>
					<cfif ListFind(DD_Status_toHide, DD_STATUS_ID) EQ 0>

						<td align="right" <CFIF DD_STATUS_ID EQ 8>style="#tdSTyle##sRowTotalCreditCellStyle#"<CFELSE>style="#tdSTyle#"</CFIF>>
							<cfset variables.url_params = arrayToList([ "SC_Shr_Ship_To=#URL.SC_Shr_Ship_To#" & (Get_Profile_Settings.DD_RFA_Agreed EQ 1
																													? "&Program_Agree_Status_ID=#Program_Agree_Status_ID#"
																													: "")
																		,"SC_Broker_Shard=#URL.SC_Broker_Shard#"
																		,"Show_Status=#DD_Status_ID#"
																		,"Tier_Number=#ThisTier_Number#"
																		,"chkHideParent=#chkHideParent#"
																	], "&")>
							<a href="/deductions/scorecard/index.cfm?#variables.url_params#" target="_parent">
								<CFIF DD_STATUS_ID EQ 8>
								<INPUT CLASS="textbox_input" type="text" name="Dollar" size="#textBoxSize#" READONLY="" VALUE="#ThisStatusVal#"  style="border: none; cursor: pointer; #inputFontStyle#">
								<CFELSE>
								<INPUT CLASS="textbox_input" type="text" name="Dollar" size="#textBoxSize#" READONLY="" VALUE="#ThisStatusVal#"  style="cursor: pointer; #inputFontStyle#">
								</CFIF>
							</a>
						</td>
						<cfset arColumnTotal[loopIndex] = arColumnTotal[loopIndex] + ThisStatusValNoFormat />
						<cfif currentItem eq "DED">
							<cfset rowTotal = rowTotal + ThisStatusValNoFormat />
						</cfif>
					</cfif>
					<cfset loopIndex = loopIndex + 1 />
				</CFLOOP>

				<cfif currentItem eq "DED">
					<!---- row total ------>
					<CFIF ScorecardToShow_basedon EQ "dollar">
						<CFSET ThisStatusVal = DOLLARFORMAT(rowTotal)>
					<CFELSE>
						<CFSET ThisStatusVal = NumberFormat(rowTotal, sCountFormat)>
					</CFIF>
					<td align="right" style="#tdSTyle##sRowTotalCellStyle#">
						<INPUT CLASS="textbox_input" type="text" name="Dollar" size="#textBoxSize#" READONLY="" VALUE="#ThisStatusVal#"  style="border: none; #inputFontStyle#">
					</td>
				</cfif>
			</cfloop>
			<!---- end: we need to put the row total before the credit column, so we are using 2 queries to loop over ------>

		</TR>
		</cfcase>
		<cfcase value="Action">
		<TR>
			<TD ALIGN="RIGHT" <!--- WIDTH="160" --->><div class="BigText">#DD_Stage_Description# <!--- (#DD_Stage_ID#) ---></div></TD>
			<CFSET ThisAction = DD_Stage_ID>
			<!---- we need to put the row total before the credit column, so we are using 2 queries to loop over ------>
			<cfset loopIndex = 1 />
			<cfloop list="DED,CRD" index="currentItem">
				<cfif currentItem eq "DED">
					<cfset qStatus = GetStatusDeduction />
				<cfelse>
					<cfset qStatus = GetStatusCredit />
				</cfif>

				<CFLOOP QUERY="qStatus">
					<CFSET StatusVar = REPLACE(DD_Status_Description," ","","All")>
					<CFSET ThisStatusVal = 0>
					<CFSET ThisStatusValNoFormat = 0>
					<CFIF ScorecardToShow_basedon EQ "dollar">
						<cfif isDefined("#StatusVar#_Dollar_Amount")>
						<cfset ThisStatusValNoFormat = EVALUATE("#StatusVar#_Dollar_Amount") />
						<CFSET ThisStatusVal = DOLLARFORMAT(ThisStatusValNoFormat)>
						</cfif>
					<CFELSE>
						<cfif isDefined("#StatusVar#_Deductions")>
						<cfset ThisStatusValNoFormat = EVALUATE("#StatusVar#_Deductions") />
						<CFSET ThisStatusVal = NumberFormat(ThisStatusValNoFormat, sCountFormat)>
						</cfif>
					</CFIF>
					<cfif ListFind(DD_Status_toHide, DD_STATUS_ID) EQ 0>
						<td align="right" <CFIF DD_STATUS_ID EQ 8>style="#tdSTyle##sRowTotalCreditCellStyle#"<CFELSE>style="#tdSTyle#"</CFIF>>
							<cfset variables.url_params = arrayToList([  "SC_Shr_Ship_To=#URL.SC_Shr_Ship_To#" & (Get_Profile_Settings.DD_RFA_Agreed EQ 1
																													? "&Program_Agree_Status_ID=#Program_Agree_Status_ID#"
																													: "")
																		,"SC_Broker_Shard=#URL.SC_Broker_Shard#"
																		,"Show_Status=#DD_Status_ID#"
																		,"Action=#ThisAction#"
																		,"chkHideParent=#chkHideParent#"
																	], "&")>
							<a href="/deductions/scorecard/index.cfm?#variables.url_params#" target="_parent">
								<CFIF DD_STATUS_ID EQ 8>
								<INPUT CLASS="textbox_input" type="text" name="Dollar" size="#textBoxSize#" READONLY="" VALUE="#ThisStatusVal#"  style="border: none; cursor: pointer; #inputFontStyle#">
								<CFELSE>
								<INPUT CLASS="textbox_input" type="text" name="Dollar" size="#textBoxSize#" READONLY="" VALUE="#ThisStatusVal#" style="cursor: pointer; #inputFontStyle#">
								</CFIF>
							</a>
						</td>
						<cfset arColumnTotal[loopIndex] = arColumnTotal[loopIndex] + ThisStatusValNoFormat />
						<cfif currentItem eq "DED">
							<cfset rowTotal = rowTotal + ThisStatusValNoFormat />
						</cfif>
					</cfif>
					<cfset loopIndex = loopIndex + 1 />
				</CFLOOP>

				<cfif currentItem eq "DED">
					<!---- row total ------>
					<CFIF ScorecardToShow_basedon EQ "dollar">
						<CFSET ThisStatusVal = DOLLARFORMAT(rowTotal)>
					<CFELSE>
						<CFSET ThisStatusVal = NumberFormat(rowTotal, sCountFormat)>
					</CFIF>
					<td align="right" style="#tdSTyle##sRowTotalCellStyle#">
						<INPUT CLASS="textbox_input" type="text" name="Dollar" size="#textBoxSize#" READONLY="" VALUE="#ThisStatusVal#"  style="border: none; #inputFontStyle#">
					</td>
				</cfif>
			</cfloop>
			<!---- end: we need to put the row total before the credit column, so we are using 2 queries to loop over ------>

		</TR>
		</cfcase>
		<cfdefaultcase>
		<TR>
			<TD ALIGN="RIGHT" <!--- WIDTH="160" --->><div class="BigText">#DD_Classification_Desc# <!--- (#DD_Stage_ID#) ---></div></TD>
			<CFSET ThisClass = DD_Classification_ID>
			<!---- we need to put the row total before the credit column, so we are using 2 queries to loop over ------>
			<cfset loopIndex = 1 />
			<cfloop list="DED,CRD" index="currentItem">
				<cfif currentItem eq "DED">
					<cfset qStatus = GetStatusDeduction />
				<cfelse>
					<cfset qStatus = GetStatusCredit />
				</cfif>

				<CFLOOP QUERY="qStatus">
					<CFSET StatusVar = REPLACE(DD_Status_Description," ","","All")>
					<CFSET ThisStatusVal = 0>
					<CFSET ThisStatusValNoFormat = 0>
					<CFIF ScorecardToShow_basedon EQ "dollar">
						<cfset ThisStatusValNoFormat = EVALUATE("#StatusVar#_Dollar_Amount") />
						<CFSET ThisStatusVal = DOLLARFORMAT(ThisStatusValNoFormat)>
					<CFELSE>
						<cfif isDefined("#StatusVar#_Deductions")>
						<cfset ThisStatusValNoFormat = EVALUATE("#StatusVar#_Deductions") />
						<CFSET ThisStatusVal = NumberFormat(ThisStatusValNoFormat, sCountFormat)>
						</cfif>
					</CFIF>
					<cfif ListFind(DD_Status_toHide, DD_STATUS_ID) EQ 0>
						<td align="right" <CFIF DD_STATUS_ID EQ 8>style="#tdSTyle##sRowTotalCreditCellStyle#"<CFELSE>style="#tdSTyle#"</CFIF>>
							<cfset variables.url_params = arrayToList([  "SC_Shr_Ship_To=#URL.SC_Shr_Ship_To#" & (Get_Profile_Settings.DD_RFA_Agreed EQ 1
																													? "&Program_Agree_Status_ID=#Program_Agree_Status_ID#"
																													: "")
																		,"SC_Broker_Shard=#URL.SC_Broker_Shard#"
																		,"Show_Status=#DD_Status_ID#"
																		,"Class=#ThisClass#"
																		,"chkHideParent=#chkHideParent#"
																	], "&")>
							<a href="/deductions/scorecard/index.cfm?#variables.url_params#" target="_parent">
								<CFIF DD_STATUS_ID EQ 8>
								<INPUT CLASS="textbox_input" type="text" name="Number" size="#textBoxSize#" READONLY="" VALUE="#ThisStatusVal#"  style="border: none; cursor: pointer; #inputFontStyle#">
								<CFELSE>
								<INPUT CLASS="textbox_input" type="text" name="Number" size="#textBoxSize#" READONLY="" VALUE="#ThisStatusVal#" style="cursor: pointer; #inputFontStyle#">
								</CFIF>
							</a>
						</TD>
						<cfset arColumnTotal[loopIndex] = arColumnTotal[loopIndex] + ThisStatusValNoFormat />
						<cfif currentItem eq "DED">
							<cfset rowTotal = rowTotal + ThisStatusValNoFormat />
						</cfif>
					</cfif>
					<cfset loopIndex = loopIndex + 1 />
				</CFLOOP>

				<cfif currentItem eq "DED">
					<!---- row total ------>
					<CFIF ScorecardToShow_basedon EQ "dollar">
						<CFSET ThisStatusVal = DOLLARFORMAT(rowTotal)>
					<CFELSE>
						<CFSET ThisStatusVal = NumberFormat(rowTotal, sCountFormat)>
					</CFIF>
					<td align="right" style="#tdSTyle##sRowTotalCellStyle#">
						<INPUT CLASS="textbox_input" type="text" name="Dollar" size="#textBoxSize#" READONLY="" VALUE="#ThisStatusVal#"  style="border: none; #inputFontStyle#">
					</td>
				</cfif>
			</cfloop>
			<!---- end: we need to put the row total before the credit column, so we are using 2 queries to loop over ------>

		</TR>
		</cfdefaultcase>
	</cfswitch>
	</form>
	<cfset ColumnRowTotal = ColumnRowTotal + rowTotal />
	</cfoutput>

	<!---- show column totals ----->
	<cfoutput>
	<!--- add some space before the total using teh following dummy row ---->
	<tr>
		<td colspan="1">&nbsp;</td>
		<td colspan="#GetStatusDeduction.recordCount#">&nbsp;</td>
		<td colspan="1" style="#tdSTyle##sRowTotalCellStyle#">&nbsp;</td>
		<!--- <td colspan="1" style="#tdSTyle##sRowTotalCreditCellStyle#">&nbsp;</td> --->
		<!--- <td colspan="#GetStatusCredit.recordCount#">&nbsp;</td> --->
	</tr>
	<TR>
		<TD style="#sColumnTotalCellStyle#" ALIGN="RIGHT"><div class="bigtext">&nbsp;&nbsp;Total&nbsp;</div></TD>
	<!---- we need to put the row total before the credit column, so we are using 2 queries to loop over ------>
			<cfset loopIndex = 1 />
			<cfloop list="DED,CRD" index="currentItem">
				<cfif currentItem eq "DED">
					<cfset qStatus = GetStatusDeduction />
				<cfelse>
					<cfset qStatus = GetStatusCredit />
				</cfif>

				<CFLOOP QUERY="qStatus">
					<CFSET ThisStatusVal = 0>
					<CFIF ScorecardToShow_basedon EQ "dollar">
						<CFSET ThisStatusVal = DOLLARFORMAT(arColumnTotal[loopIndex])>
					<CFELSE>
						<CFSET ThisStatusVal = NumberFormat(arColumnTotal[loopIndex], sCountFormat)>
					</CFIF>
					<cfif ListFind(DD_Status_toHide, DD_STATUS_ID) EQ 0>
						<td align="right" <CFIF DD_STATUS_ID EQ 8>style="#tdSTyle##sColumnTotalCellStyle##sRowTotalCreditCellStyle#"<CFELSE>style="#tdSTyle##sColumnTotalCellStyle#"</CFIF>>
						<INPUT CLASS="textbox_input" type="text" name="Dollar" size="#textBoxSize#" READONLY="" VALUE="#ThisStatusVal#"  style="border:none; #inputFontStyle#">
						</td>
					</cfif>
					<cfset loopIndex = loopIndex + 1 />
				</CFLOOP>

				<!--- Total --->
				<cfif currentItem eq "DED">
					<CFIF ScorecardToShow_basedon EQ "dollar">
						<CFSET ThisStatusVal = DOLLARFORMAT(ColumnRowTotal)>
					<CFELSE>
						<CFSET ThisStatusVal = NumberFormat(ColumnRowTotal, sCountFormat)>
					</CFIF>
					<td align="right" style="#tdSTyle##sColumnTotalCellStyle##sRowTotalCellStyle#">
						<INPUT CLASS="textbox_input" type="text" name="Dollar" size="#textBoxSize#" READONLY="" VALUE="#ThisStatusVal#"  style="border: none; #inputFontStyle#">
					</td>
				</cfif>
			</cfloop>
	</TR>
	</cfoutput>
	<!---- end: show column totals ----->

		<!--- BJF: Readded back in for McCain D12279 --->
	<CFOUTPUT>
			<TR>
				<td></td>
				<cfset linklist = "Closed Ded,Closed Credit,Auto Closed,Deleted">
				<cfset DD_Status_toHide_List = "4,9,5,6">
				<cfset row = 0>
				<cfloop list="#linklist#" index="i">
					<cfset row = row + 1>
					<cfset linkName = i>
					<cfset statusToHide = listGetAt(DD_Status_toHide_List,row)>
					<cfif ListFind(DD_Status_toHide, statusToHide) EQ 0>
						<td style="padding-left:8;" class="bigtext">
							<FONT COLOR="Red">[</FONT>
								<cfset variables.url_params = arrayToList([  "SC_Shr_Ship_To=#URL.SC_Shr_Ship_To#"
																			,"SC_Broker_Shard=#URL.SC_Broker_Shard#"
																			,"Show_Status=#statusToHide#"
																			,"chkHideParent=#chkHideParent#"
																		], "&")>
								<a href="/deductions/scorecard/index.cfm?#variables.url_params#" target="_parent">
									#linkName#
								</a>
							<FONT COLOR="Red">]</FONT>
						</td>
					</cfif>
				</cfloop>
			</TR>
		</TABLE>
	</CFOUTPUT>

	</BODY>

	</HTML>
