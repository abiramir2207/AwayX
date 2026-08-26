<!---
FILE: 		deduction.cfm
FILENAME:   DEDUCTIONS/deduction.cfm
EDITED:   	11/18/2008 - Brad Lee MMCP/ACI
--->

	<cfif isdefined("url.removebb")>
		<cfset  deductionmanager = createobject("component", "components.deduction.deductionmanager").init() />
		<cfset  deductionmanager.Removeassociatedbb(url.deduction_id) />
	</cfif>

	<cfset  genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset  appSettings = genSettingsManager.get()>

	<cfif isdefined("bbpaid") or isdefined("noaccess")>
		<cfquery name="" datasource="#application.datasource#">
		update deductions
		set dd_closure_bbpaid = 1
		where deduction_id = '#deduction_id#'
		</cfquery>
	</cfif>
	<cfif NOT isDefined("Deduction_ID")>
		No deduction has been selected.
		<cfabort>
	</cfif>


<!---User profile--->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

	<cfset useLakebaseForDeductionsProfilesSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions_profiles_settings")>
	<cfif useLakebaseForDeductionsProfilesSettings>
		<cftry>
			<cfset DeductionsProfilesSettings = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions_profiles_settings", { "profiles_id" = "eq.#Get_Profile_Settings.Profiles_ID#" })
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForDeductionsProfilesSettings = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDeductionsProfilesSettings>
		<cfquery name="DeductionsProfilesSettings" datasource="#application.datasource#">
			SELECT *
			FROM Deductions_Profiles_Settings
			WHERE Profiles_ID = '#Get_Profile_Settings.Profiles_ID#'
		</cfquery>
	</cfif>

<cfparam name="url.emailFax" 	default="0">
<cfparam name="showScissor" default="0">
<cfparam name=" letRfaApprove" default="1"><!---D41362 :: BAT & Prod - Deduction Closing <$0 Total Billback Association --->
<cfparam name="CenterToShow" default="Details">
<cfparam name="Invoices" default="">
<cfparam name="Adj_Excl" default="">
<cfparam name="Billbacks" default="">
<cfparam name="formtype" default="">
<cfparam name="form.broker_list" default="">
<cfparam name="form.distributor_list" default="">
<cfparam name="form.userreferencesave" default="0">
<cfparam name="form.dd_user_reference1" default="">
<cfparam name="form.dd_user_reference2" default="">
<cfparam name="Closure_Type" default="NoReason">
<cfparam name="DD_Stage_ID" default="">
<cfparam name="UpdateAction" default="">
<cfparam name="url.showall" default="0">
<cfparam name="Reminder_Date" default="" />
<cfparam name="Notes_Date" default=" " />
<!--- D38841 : Update non-trade feature to open in a new window START--->
<cfparam name="form.deduction_ID" default="0">
<cfparam name="form.reasoncode" default="0">
<cfparam name="form.closure_Type" default="0">
		<!--- 71877	Deduction Workflow Enhancement Updates START--->
		<cfset disableBasedOnClassification = 0>
		<cfif ! isdefined('DeductionManager')>
			<cfset  DeductionManager = CreateObject("component", "components.deduction.DeductionManager").init() />
		</cfif>
		<cfif appSettings.get_Setting('Custom_Deduction_workflow') eq '1'>
			<cfset disableBasedOnClassification = DeductionManager.DisableLinks(#deduction_id#)/>
		</cfif>
		<!--- 71877	Deduction Workflow Enhancement Updates END--->

<cfif CenterToShow IS "setToNew">
		<cfquery name="SetAsNew" datasource="#application.datasource#">
			UPDATE Deductions
			Set DD_Status = 1,
			DD_Stage = CASE WHEN DD_Stage IS NULL THEN (SELECT DD_Stage_ID FROM DD_Stage WHERE Deleted  = 0 AND Is_Default = 1) ELSE DD_Stage END
			WHERE Deduction_ID = '#Deduction_ID#'
		</cfquery>
		<script language="javascript">
			alert("Deduction is set to 'New' status");
		</script>
</cfif>
	<form name="dataForm" action="deduction.cfm?CenterToShow=NonTrade" method="post">
	<cfoutput>
		<input type="hidden" name="deduction_ID" value="#form.deduction_ID#">
		<input type="hidden" name="reasoncode" value="#form.reasoncode#">
		<input type="hidden" name="closure_Type" value="#form.closure_Type#">
	</cfoutput>
	</form>
<!--- D38841 : Update non-trade feature to open in a new window END--->

	<cfif Form.UserReferenceSave EQ 1>
		<cfset  DeductionManager.addUserReference(deductionId = Form.Deduction_ID, DD_User_Reference1 = Form.DD_User_Reference1, DD_User_Reference2 = Form.DD_User_Reference2)>
	</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Locking Action Part--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	<cfif Isdefined("FORM.SubmitLockStatus")>
		<cfset useLakebaseForLockDD = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForLockDD>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{
				"deduction_id" = "eq.#FORM.Deduction_ID#",
				"deleted" = "eq.0"
			},
			{
				"is_locked" = "#FORM.Lock_Status#",
				"locked_by" = "#Locked_By#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForLockDD = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForLockDD>
<CFQUERY name="LockDD" DATASOURCE="#Application.Datasource#">
			UPDATE 	Deductions
			SET 	Is_Locked = #FORM.Lock_Status#,
								Locked_By = '#Locked_By#'
			WHERE 	Deduction_ID = '#FORM.Deduction_ID#'
			AND Deleted=0
		</CFQUERY>
</cfif>
	</cfif>

<cfinclude template="/deductions/Get_Lock_Status.cfm">

	<cfif FormType IS "RemoveShipTo">
		<cfset useLakebaseForUpdateDeductions = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForUpdateDeductions>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{
				"deduction_id" = "eq.#Deduction_ID#"
			},
			{
				"distributor_id" = javaCast("null","")
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateDeductions = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateDeductions>
<cfquery name="UpdateDeductions" datasource="#application.datasource#">
			UPDATE Deductions
			SET Distributor_ID = null
			WHERE Deduction_ID = '#Deduction_ID#'
		</cfquery>
</cfif>
	</cfif>

<!---Gets data about deduction--->
<cfinclude template="/deductions/sql_Deduction_Info.cfm">

	<cfif FormType IS "AddDistributor" AND len(trim(form.Distributor_List)) GT 0 AND form.Distributor_List NEQ "">

		<cfset useLakebaseForGetPriorAnalyst = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForGetPriorAnalyst>
	<cftry>
		<cfset GetPriorAnalyst = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"deduction_id" = "eq.#Deduction_ID#",
				"select" = "analyst_user_id"
			}), "analyst_user_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetPriorAnalyst = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetPriorAnalyst>
<CFQUERY name="GetPriorAnalyst" DATASOURCE="#Application.Datasource#">
			SELECT Analyst_User_ID
			FROM Deductions
			WHERE Deduction_ID = '#Deduction_ID#'
		</CFQUERY>
</cfif>

		<cfif appSettings.getDDReassignAnalystWhileChangingPayTo()>
			<cfset useLakebaseForGetDistInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForGetDistInfo>
	<cftry>
		<cfset GetDistInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"bsa_foodservice_customers_id" = "eq.#form.Distributor_List#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDistInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDistInfo>
<CFQUERY name="GetDistInfo" DATASOURCE="#Application.Datasource#">
				SELECT *
				FROM BSA_Foodservice_Customers
				WHERE BSA_Foodservice_Customers_ID = '#form.Distributor_List#'
			</CFQUERY>
</cfif>
			<CFQUERY name="GetAnalyst" DATASOURCE="#Application.Datasource#">
				SELECT Analyst_User_ID
				FROM DD_Assignment
				WHERE DELETED = 0
			<cfif appSettings.getDDAssignmentBasedOnShrShipto() EQ 1>
				AND Customer_Id =  '#form.Distributor_List#'
			<cfelse>
				AND Family_ID =  '#GetDistInfo.Family_ID#'
			</cfif>
			</CFQUERY>
					<cfif GetAnalyst.Analyst_User_ID EQ "">
						<CFQUERY name="GetMarket" DATASOURCE="#Application.Datasource#">
							SELECT  Service_Market_ID
							FROM	BSA_Foodservice_Brokers
							WHERE 	BSA_Foodservice_Brokers_ID = '#GetDistInfo.BSA_Foodservice_Brokers_ID#'
							AND DELETED = 0
						</CFQUERY>
								<cfif GetMarket.Service_Market_ID EQ 0 OR GetMarket.Service_Market_ID EQ "">
										<CFQUERY name="GetAnalyst" DATASOURCE="#Application.Datasource#">
											SELECT Analyst_User_ID
											FROM DD_Analyst
											WHERE Default_Analyst = 1
											AND DELETED = 0
										</CFQUERY>
										<cfset  Ass_BasedOn_Family_ID = "">
										<cfset  Ass_BasedOn_Service_Market_ID = 0>
								<cfelse>
										<CFQUERY name="GetAnalyst" DATASOURCE="#Application.Datasource#">
											SELECT Analyst_User_ID
											FROM DD_Assignment
											WHERE DELETED = 0
											AND Service_Market_ID =  '#GetMarket.Service_Market_ID#'
										</CFQUERY>
									<cfif GetAnalyst.Analyst_User_ID EQ "">
											<CFQUERY name="GetAnalyst" DATASOURCE="#Application.Datasource#">
												SELECT Analyst_User_ID
												FROM DD_Analyst
												WHERE Default_Analyst = 1
												AND DELETED = 0
											</CFQUERY>
											<cfset  Ass_BasedOn_Family_ID = "">
											<cfset  Ass_BasedOn_Service_Market_ID = 0>
									<cfelse>
											<cfset  Ass_BasedOn_Family_ID = "">
											<cfset  Ass_BasedOn_Service_Market_ID = GetMarket.Service_Market_ID>
									</cfif>
								</cfif>
					<cfelse>
						<cfset  Ass_BasedOn_Family_ID = GetDistInfo.Family_ID>
						<cfset  Ass_BasedOn_Service_Market_ID = 0>
					</cfif>
		</cfif>

		<CFQUERY name="GetCurrentDetail" DATASOURCE="#Application.Datasource#">
			SELECT *
			FROM Deductions
			WHERE Deduction_ID = '#Deduction_ID#'
		</CFQUERY>



		<cfif DeductionsProfilesSettings.DD_Reassign_Access NEQ 1 AND GetCurrentDetail.Analyst_User_ID NEQ GetPriorAnalyst.Analyst_User_ID>
			<cfset  DisplayNoReassignAccess = 1>
			<cfset  CenterToShow = "NoAccessReassignMessage">
		<cfelse>
			<CFQUERY name="AddDistributor" DATASOURCE="#Application.Datasource#">
				UPDATE 	Deductions
				SET 	<cfif appSettings.getDDReassignAnalystWhileChangingPayTo()>
					Analyst_User_ID = '#GetAnalyst.Analyst_User_ID#',
					Ass_BasedOn_Family_ID = <cfif Ass_BasedOn_Family_ID EQ "">NULL<cfelse>'#Ass_BasedOn_Family_ID#'</cfif>,
					Ass_BasedOn_Service_Market_ID = '#Ass_BasedOn_Service_Market_ID#',
					</cfif>
					Distributor_ID = '#form.Distributor_List#'
				WHERE 	Deduction_ID = '#Deduction_ID#'
			</CFQUERY>
			<CFQUERY name="Get_Broker" DATASOURCE="#application.datasource#">
				SELECT BSA_Foodservice_Brokers_ID
				FROM BSA_Foodservice_Customers
				WHERE BSA_Foodservice_Customers_ID = '#form.Distributor_List#'
			</CFQUERY>

			<cfset  Broker_List = valuelist(Get_Broker.BSA_Foodservice_Brokers_ID)>
			<cfset  FormType = "AddBroker">
			<cfset  CurrentBroker = Deduction_Info.Broker_ID>

			<cfif appSettings.getDDReassignAnalystWhileChangingPayTo() AND GetCurrentDetail.Analyst_User_ID NEQ GetAnalyst.Analyst_User_ID>
				<CFQUERY name="LogReassign" DATASOURCE="#Application.Datasource#">
				INSERT INTO DD_Reassign (	Deduction_ID,From_Analyst,To_Analyst,By_Analyst,Reassign_Triggered_By )
				VALUES ('#Deduction_ID#','#GetCurrentDetail.Analyst_User_ID#','#GetAnalyst.Analyst_User_ID#','#request.AccessStructure.User_ID#','Triggered by customer reassignment')
				</CFQUERY>
			</cfif>
		</cfif>
	</cfif>

	<cfif FormType IS "AddBroker" AND len(trim(Broker_List)) GT 0 and Broker_List NEQ "">

		<CFQUERY name="DeletedIfRefesh" DATASOURCE="#Application.Datasource#">
			UPDATE DD_Broker_Reassign
			SET Deleted = 1
			WHERE Deduction_ID = '#Deduction_ID#'
			AND Latest_Insert = 1
			<cfif len(trim(CurrentBroker))>
			AND From_Broker_ID = '#CurrentBroker#'
			</cfif>
			AND To_Broker_ID = '#Broker_List#'
			AND Reassigned_By = '#request.AccessStructure.User_ID#'
			AND Deleted = 0
		</CFQUERY>
		<cfset useLakebaseForBrokerUpdate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_broker_reassign")>
<cfif useLakebaseForBrokerUpdate>
	<cftry>
		<cfset application.oLakebase.updateRows("dd_broker_reassign",
			{
				"latest_insert" = "eq.1",
				"deduction_id" = "eq.#Deduction_ID#"
			},
			{
				"latest_insert" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBrokerUpdate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBrokerUpdate>
<CFQUERY name="BrokerUpdate" DATASOURCE="#Application.Datasource#">
			UPDATE DD_Broker_Reassign
			SET Latest_Insert = 0
			WHERE Latest_Insert = 1
			AND Deduction_ID = '#Deduction_ID#'
		</CFQUERY>
</cfif>
		<CFQUERY name="InsHistory" DATASOURCE="#Application.Datasource#">
			INSERT INTO DD_Broker_Reassign (Deduction_ID,<cfif len(trim(CurrentBroker))>From_Broker_ID,</cfif>To_Broker_ID,Reassigned_By,Latest_Insert)
			VALUES ('#Deduction_ID#',<cfif len(trim(CurrentBroker))>'#CurrentBroker#',</cfif>'#Broker_List#','#request.AccessStructure.User_ID#',1)
		</CFQUERY>
		<CFQUERY name="DDUpdate" DATASOURCE="#Application.Datasource#">
			UPDATE Deductions
			SET Broker_ID = '#Broker_List#'
			WHERE Deduction_Id = '#Deduction_ID#'
		</CFQUERY>

	</cfif>

	<cfset useLakebaseForGetDistributor = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForGetDistributor>
	<cftry>
		<cfset GetDistributor = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"deduction_id" = "eq.#Deduction_ID#",
				"select" = "distributor_id,distributor_bill_to_id,dd_stage,dd_status"
			}), "distributor_id,distributor_bill_to_id,dd_stage,dd_status"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDistributor = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDistributor>
<cfquery name="GetDistributor" datasource="#application.datasource#">
		SELECT Distributor_ID, Distributor_Bill_To_ID, DD_Stage, DD_Status
		FROM Deductions
		WHERE Deduction_ID = '#Deduction_ID#'
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
		SELECT *
		FROM Deduction_Settings
	</cfquery>
</cfif>

	<cfif CenterToShow neq  "setToNew">
<!---No longer new, mark as opened--->
	<cfif GetDistributor.DD_Status IS 1>
		<cfquery name="SetAsOpen" datasource="#application.datasource#">
			UPDATE Deductions
			Set DD_Status = CASE WHEN Is_Locked = 1 THEN 2 ELSE DD_Status END,
			DD_Stage = CASE WHEN DD_Stage IS NULL THEN (SELECT DD_Stage_ID FROM DD_Stage WHERE Deleted  = 0 AND Is_Default = 1) ELSE DD_Stage END
			WHERE Deduction_ID = '#Deduction_ID#'
		</cfquery>
		<cfset useLakebaseForSetClearedAmount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForSetClearedAmount>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{
				"deduction_id" = "eq.#Deduction_ID#"
			},
			{
				"cleared_amount" = "#Deduction_Info.DD_Amount#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSetClearedAmount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSetClearedAmount>
<cfquery name="SetClearedAmount" datasource="#application.datasource#">
			UPDATE Deductions
			SET Cleared_Amount = #Deduction_Info.DD_Amount#
			WHERE Deduction_ID = '#Deduction_ID#'
		</cfquery>
</cfif>
	</cfif>
	</cfif>

<cfset  Distributor_ID = GetDistributor.Distributor_ID>

	<cfif len(trim(Billbacks)) GT 0>
		<cfset  BillbackReplaced = replace(Billbacks,'_', '-', "all")>
		<cfquery name="UpdateDeduction" datasource="#application.datasource#">
			UPDATE Deductions
			SET DD_Closure_ID = '#BillbackReplaced#',
			DD_Closure_Type = 1
			WHERE Deduction_ID = '#Deduction_ID#'
		</cfquery>
		<cfset  CenterToShow="Closure">
	</cfif>

	<cfif FormType IS "AddProgram">
			<cfset  businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<cfif businessSegManager.isEnabled()>
			<cfset  busSegIdForProgram = businessSegManager.getSegmentIdByProgram(form.Program_ID) />
		</cfif>
		<cfquery name="AddProgram" datasource="#application.datasource#">
			UPDATE 	Deductions
			SET 	<cfif IsDefined("busSegIdForProgram")>Business_Segment_ID = '#busSegIdForProgram#',</cfif>
			Program_ID = '#form.Program_ID#'
			WHERE 	Deduction_ID = '#Deduction_ID#'
		</cfquery>
	</cfif>

<cfoutput>

	<cfquery name="GetReminders" datasource="#application.datasource#">
		SELECT	CONVERT(DATETIME, CONVERT(char(10), DD_Reminder_Date, 101)) AS DD_Reminder_Date,
		DD_Reminders.DD_Reminder, DD_Reminders.DD_Reminder_ID, DD_Reminders.DD_Reminder_Status
		FROM 	DD_Reminders
		WHERE 	Deduction_ID = <cfqueryparam value="#Deduction_ID#" cfsqltype="cf_sql_idstamp">
		<cfif URL.ShowAll EQ 0>
		AND DD_Reminder_Status = 0
		</cfif>
		ORDER BY DD_Reminders.DD_Reminder_Date DESC, DD_Reminders.DD_Reminder
	</cfquery>
	<cfquery name="GetNotes" datasource="#application.datasource#">
		SELECT	CONVERT(DATETIME, CONVERT(char(10), DD_Note_Date, 101)) AS DD_Note_Date,
		DD_Note, DD_Note_ID,  left(convert(char(10), DD_Note), 10) as DD_Note_Sort
		FROM 	DD_Notes
		WHERE 	Deduction_ID = <cfqueryparam value="#Deduction_ID#" cfsqltype="cf_sql_idstamp">
		AND 	Deleted = 0
		ORDER BY DD_Note_Date Desc, DD_Note_Sort
	</cfquery>

<HTML>

	<HEAD>
		<META http-equiv="Content-Language" content="en-us">
		<META http-equiv="Content-Type" content="text/html; charset=windows-1252">
		<TITLE><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput></TITLE>
	</HEAD>

<BODY onResize="moveDiv()">
<cfset  page_title="Single Deduction View">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<STYLE>
	body,td
		{
			font-family:	Arial, Helvetica, sans-serif;
			font-size:		12px;
		}
	.no_access
	{
		color:gray;
	}
</STYLE>
<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/ViewModes.css">
<!--- Top --->
<!---Get color for aging--->
	<cfquery name="GetColor" datasource="#application.datasource#">
		SELECT ColorID, FontID
		FROM DD_Aging
		WHERE #Deduction_Info.DD_Age# >= Start_Range
		AND #Deduction_Info.DD_Age# <= End_Range
		AND Deleted = 0
	</cfquery>
	<cfif GetColor.Recordcount LT 1>
		<cfquery name="GetColor" datasource="#application.datasource#">
			SELECT ColorID, FontID
			FROM DD_Aging
			WHERE Deleted = 0
			AND End_Range IS null
		</cfquery>
	</cfif>
	<cfset  backgroundcolor = GetColor.ColorID>
	<cfset  fontcolor = GetColor.FontID>
	<CFQUERY name="CheckForAgreed" DATASOURCE="#Application.Datasource#">
		SELECT TOP 1 *
		FROM DD_Agreed_Info
		WHERE Deduction_ID = '#Deduction_ID#'
		AND Deleted = 0
	</CFQUERY>

<!---Begin top display--->
<TABLE border="0" cellpadding="4" style="border-collapse: collapse" id="table2" cellspacing="4">
<tr>
	<td nowrap bgcolor="###Backgroundcolor#" STYLE="Border:Solid C0C0C0 1px;  Border-left:Solid C0C0C0 1px;">
			<B>
				<FONT size="3" color="###fontcolor#">
					#Deduction_Info.DD_DedID_SP_Number#
				</FONT>
			</B>
	</td>
	<td  width="100%" bgcolor="###backgroundcolor#" STYLE="Border:Solid C0C0C0 1px;">
			<cfif Deduction_Info.attachment_count gt 0>
				<table>
				<tr>
					<td width="99%" nowrap>
						<B>
							<FONT size="3" color="###fontcolor#">
								<cfif Deduction_Info.ShipToName NEQ "">
										#Deduction_Info.ShipToName# (#Deduction_Info.Shr_Ship_To#)
								<cfelse>
										#Deduction_Info.Name# (#Deduction_Info.Shr_Bill_To#)
								</cfif>
							</FONT>
						</B>
					</td>
					<td width="1%">
						<img  align="right"   SRC="/images/doc.gif" width="13" height="16" title="This program has #Deduction_Info.attachment_count# attached document(s)">
					</td>
				</tr>
				</table>
			<cfelse>
				<B>
					<FONT size="3" color="###fontcolor#">
						<cfif Deduction_Info.ShipToName NEQ "">
							#Deduction_Info.ShipToName# (#Deduction_Info.Shr_Ship_To#)
						<cfelse>
							#Deduction_Info.Name# (#Deduction_Info.Shr_Bill_To#)
						</cfif>
					</FONT>
				</B>
			</cfif>
	</td>
	<td nowrap bgcolor="###backgroundcolor#" STYLE="Border:Solid C0C0C0 1px;">
		<B>
			<FONT size="3" color="###fontcolor#">
				#Deduction_Info.DD_Stage_Description#
			</FONT>
		</B>
	</td>
	<td nowrap bgcolor="###backgroundcolor#" STYLE="Border:Solid C0C0C0 1px;">
		<B>
			<FONT size="3" color="###fontcolor#">
				<cfif Deduction_Info.DD_Status IS 1>
						New
				<cfelseif Deduction_Info.DD_Status IS 2>
						Open
						<cfif Deduction_Info.Is_Write_Off EQ 1>
								(#stDeductionLabels["Write Off"]#)
						<cfelseif Deduction_Info.DD_Rejected EQ 1>
								(Reject)
						</cfif>
				<cfelseif Deduction_Info.DD_Status IS 3>
						<cfif CheckForAgreed.RecordCount GT 0 AND Get_Profile_Settings.DD_RFA_Agreed EQ 1>
								AGREE
						<cfelse>
								RFA
						</cfif>
						<cfif Deduction_Info.Is_Write_Off EQ 1>
								(#stDeductionLabels["Write Off"]#)
						<cfelseif Deduction_Info.Is_Last_Status_Rebill EQ 1>
								(Rebill)
						<cfelseif Deduction_Info.DD_Rejected EQ 1>
								(Reject)
						</cfif>
				<cfelseif Deduction_Info.DD_Status IS 4>
						Closed
						<cfif Deduction_Info.Is_Write_Off EQ 1>
								(#stDeductionLabels["Write Off"]#)
						<cfelseif Deduction_Info.Is_Last_Status_Rebill EQ 1>
								(Rebill)
						<cfelseif Deduction_Info.DD_Rejected EQ 1>
								(Reject)
						</cfif>
				<cfelseif Deduction_Info.DD_Status IS 5>
						Auto Closed
				<cfelseif Deduction_Info.DD_Status IS 6>
						Deleted
				<cfelseif Deduction_Info.DD_Status IS 7>
						Rebill
				<cfelseif Deduction_Info.DD_Status IS 8>
						Credit
				<cfelseif Deduction_Info.DD_Status IS 9>
						Closed Credit
				</cfif>
			</FONT>
		</B>
	</td>
	<td nowrap bgcolor="###backgroundcolor#" STYLE="Border:Solid C0C0C0 1px;">
		<B>
			<FONT size="3" color="###fontcolor#">
				#Deduction_Info.DD_Age# Days
			</FONT>
		</B>
	</td>
	<td nowrap bgcolor="###backgroundcolor#" STYLE="Border:Solid C0C0C0 1px;">
		<B>
			<FONT size="3" color="###fontcolor#">
				#LSCurrencyFormat(Deduction_Info.DD_Amount)#
			</FONT>
		</B>
	</td>
</tr>
</table>
<!---Left--->
<div style="border:1px solid ##C0C0C0; width: 200px;z-index: 1; left: 10px; top: 60px; background-color:##FFFFEA" id="deduct_dashboard">
<div align="center">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<TABLE border="0" cellpadding="0" style="border-collapse: collapse" width="100%" id="table3" cellspacing="5">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Locking Form Part --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset  locked_img = "/images/edit_mode.gif">
<cfset  unlocked_img = "/images/readonly_mode.gif">
	<form name="LockDeduction" action="deduction.cfm" method="post">
		<input type="hidden" name="submitlockstatus" value="1">
		<input type="hidden" name="deduction_id" value="#deduction_id#">
<tr>
	<TH align="center" colspan="2" nowrap style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0">
		<cfif LockStatus EQ 2>
			<!--- If the deduction is locked by another user --->
			<img src="/Images/readonly_mode.gif" title="This deduction is currently being viewed by: #ucase(CheckLocked.Name_First)# #ucase(CheckLocked.Name_Last)#"  border="0"><BR />
			<span style="color: RGB(255,0,0);font-size:12px;font-weight:bold;text-decoration:none;">
				Locked By<br />#ucase(CheckLocked.Name_First)# #ucase(CheckLocked.Name_Last)#
			</span>
		<cfelseif LockStatus EQ 3>
				<!--- If the deduction is locked by another user in QUICK PAY --->
				<img src="/Images/readonly_mode.gif" title="This deduction is currently locked by: #ucase(CheckLocked.Name_First)# #ucase(CheckLocked.Name_Last)# in Quick Pay"  border="0"><BR />
				<span style="color: RGB(255,0,0);font-size:12px;font-weight:bold;text-decoration:none;">
					Locked By<br />#ucase(CheckLocked.Name_First)# #ucase(CheckLocked.Name_Last)#
				</span>
		<cfelseif LockStatus EQ 1>
			<input type="Hidden" name="Lock_Status" value="0">
			<CFOUTPUT><input type="Hidden" name="Locked_By" value=""></CFOUTPUT>
			<input type="Image" SRC="#Locked_Img#" title="Edit Mode" onclick="Javascript: LockUnLock();">
		<cfelseif LockStatus EQ 0>
			<input type="Hidden" name="Lock_Status" value="1">
			<input type="Hidden" name="Locked_By" value="#request.AccessStructure.user_ID#">
			<input type="Image" SRC="#UnLocked_Img#" title="Read-Only Mode" onclick="Javascript: LockUnLock();">
		</cfif>
		<BR/>
		<!--- If the deduction is not locked by another user --->
		<cfif LockStatus NEQ 2>
			<!--- If the deduction is locked by the current user --->
			<cfif LockStatus EQ 1>
				<span class="ViewModesBracket">[</span><span class="ViewModes">Click for Read Only</span><span class="ViewModesBracket">]</span>
			<cfelse>
				<span class="ViewModesBracket">[</span><span class="ViewModes">Click to Edit</span><span class="ViewModesBracket">]</span>
			</cfif>
		</cfif>
	</TH>
</tr>
</form>
<cfset  Reject_UnLocked = 0>
	<cfif Deduction_Info.DD_Rejected EQ 1>
		<cfif LockStatus EQ 1>
			<cfset  Reject_UnLocked = 1>
		</cfif>
	<cfset  LockStatus = 0>
	</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Locking Ends --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<cfif LockStatus EQ 0>
		<cfif Isdefined("URL.CenterToShow")>
			<cfif URL.CenterToShow NEQ "Optionfor_email"
					AND URL.CenterToShow NEQ "Optionfor_Fax"
					AND URL.CenterToShow NEQ "Optionfor_Print"
					AND URL.CenterToShow NEQ "EmailLog"
					AND URL.CenterToShow NEQ "FaxLog"
					AND URL.CenterToShow NEQ "UnDelete"
					AND URL.CenterToShow NEQ "Reopen"
					AND URL.CenterToShow NEQ "Attachments"
					AND URL.CenterToShow NEQ "ERPDocuments"
					AND URL.CenterToShow NEQ "ReassignHistory"
					AND NOT (URL.CenterToShow EQ "Closure" AND Deduction_Info.DD_Rejected EQ 1 AND appSettings.getDDSentRejectIn1510())>
				<cfset  URL.CenterToShow = "Details">
			</cfif>
		</cfif>
	</cfif>
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// LEFT MENU SECTION 1 ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<tr>
	<td align="center" nowrap style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0">
		<img border="0" src="/images/manage2.gif"  title="Manage">
	</td>
	<td width="100%" style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0">
		<A href="/deductions/deduction.cfm?CenterToShow=Details&Deduction_ID=#Deduction_ID#">View</A><BR/>
		<cfif ReOpenLogic_ShowLinks EQ 1
				AND DeductionsProfilesSettings.DD_Split EQ 1
				AND LockStatus EQ 1
				AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1
				AND (Deduction_Info.DD_Status LT 3 OR Deduction_Info.DD_Status EQ 8)
				AND Deduction_Info.Is_Write_Off NEQ 1
				AND Deduction_Info.DD_Closure_ID EQ "">
			<A href="/deductions/deduction.cfm?CenterToShow=Split&Deduction_ID=#Deduction_ID#&FromSplit=1">Split</A><BR/>
		<cfelse>
			<font class="no_access">Split</font><BR/>
		</cfif>
		<cfif appSettings.getDD_Show_reassign()>
			<cfif ReOpenLogic_ShowLinks EQ 1
					AND DeductionsProfilesSettings.DD_Reassign_Access EQ 1
					AND LockStatus EQ 1
					AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1
					AND (((Deduction_Info.DD_Status LT 3 OR DeductionsProfilesSettings.DD_Approve IS 1) AND Deduction_Info.DD_Status LT 4  OR Deduction_Info.DD_Status EQ 7) OR Deduction_Info.DD_Status EQ 8)>
				<A href="/deductions/deduction.cfm?CenterToShow=Reassign&Deduction_ID=#Deduction_ID#">Reassign</A><BR/>
			<cfelse>
				<font class="no_access">Reassign</font><BR/>
			</cfif>
		</cfif>

		<cfif (DeductionsProfilesSettings.DD_New_From_Open EQ 1 AND Deduction_Info.DD_Status EQ 2 AND LockStatus EQ 1)>
			<A href="/deductions/deduction.cfm?CenterToShow=setToNew&Deduction_ID=#Deduction_ID#">Set to New</A><BR/>
		<cfelseif(DeductionsProfilesSettings.DD_New_From_Open EQ 1 AND Deduction_Info.DD_Status EQ 2 AND LockStatus EQ 0)>
			<font class="no_access">Set to New</font><BR/>
		</cfif>

	<cfset inEditMode = ReOpenLogic_ShowLinks EQ 1
	            AND LockStatus EQ 1
	            AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1
	            AND (( Deduction_Info.DD_Status LT 3 OR DeductionsProfilesSettings.DD_Approve IS 1 ) AND Deduction_Info.DD_Status LT 4 OR Deduction_Info.DD_Status EQ 7 OR Deduction_Info.DD_Status EQ 8 )>
		<cfif appSettings.getDD_Show_Classification() and appSettings.get_Setting('Custom_Deduction_workflow') neq '1'>
			<cfif inEditMode>
				<A href="/deductions/deduction.cfm?CenterToShow=Classification&Deduction_ID=#Deduction_ID#">#stDeductionLabels["Classification"]#</A><BR/>
			<cfelse>
				<font class="no_access">#stDeductionLabels["Classification"]#</font><BR/>
			</cfif>
		</cfif>
	<!---26487 - 2011-mar-9 chrisn: added deduction type--->
		<cfif appSettings.getDD_Show_DeductionType()>
			<cfif inEditMode>
				<a href="/deductions/deduction.cfm?CenterToShow=DeductionType&Deduction_ID=#Deduction_ID#">#stDeductionLabels["Deduction Type"]#</a><BR/>
			<cfelse>
				<font class="no_access">#stDeductionLabels["Deduction Type"]#</font><BR/>
			</cfif>
		</cfif>
		<cfif appSettings.getDD_Show_Edit_Customer_Num()>
			<cfif ReOpenLogic_ShowLinks EQ 1
				AND DeductionsProfilesSettings.DD_Edit_Cust_RefNo EQ 1
				AND LockStatus EQ 1
				AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1
				AND (((Deduction_Info.DD_Status LT 3 OR DeductionsProfilesSettings.DD_Approve IS 1) AND Deduction_Info.DD_Status LT 4 OR Deduction_Info.DD_Status EQ 7) OR Deduction_Info.DD_Status EQ 8) >
				<A href="/deductions/deduction.cfm?CenterToShow=CustRefNo&Deduction_ID=#Deduction_ID#">#stDeductionLabels["Customer Reference"]#</A><BR/>
			<cfelse>
				<font class="no_access">#stDeductionLabels["Customer Reference"]#</font><BR/>
			</cfif>
		</cfif>
	</td>
</tr>
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// LEFT MENU SECTION 2 ///////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<tr>
	<td align="center" nowrap style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0">
		<img border="0" src="/images/close1.gif" title="Manage">
	</td>
	<td width="100%" style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0">
	<cfif DeductionSettings.Billback IS 0
			AND LockStatus EQ 1 AND
			DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1
			AND (Deduction_Info.DD_Status LT 3 OR DeductionsProfilesSettings.DD_Approve IS 1)
			<!--- Dev Note: Clay : Add Writeoff functionality to Credit Transactions  --->
			AND (Deduction_Info.DD_Status LT 4 OR Deduction_Info.DD_Status EQ 7 OR Deduction_Info.DD_Status EQ 8)>
		<A href="/deductions/deduction.cfm?CenterToShow=Closure&Closure_Type=Approve&Deduction_ID=#Deduction_ID#">Approve</A><BR/>
	<cfelse>
		<cfset  ApprovalPermission = 0>
			<cfif DeductionsProfilesSettings.DD_Approve EQ 1>
				<cfset  ApprovalPermission = 1>
			</cfif>
		<cfset  ApprovalRebillPermission = 0>
			<cfif Deduction_Info.Is_Last_Status_Rebill EQ 1 AND DeductionsProfilesSettings.DD_Approve_Rebill EQ 1>
				<cfset  ApprovalRebillPermission = 1>
			</cfif>
		<cfif appSettings.getDDChangeClassificationBeforeRFA()>
			<cfset useLakebaseForGetDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification")>
<cfif useLakebaseForGetDefault>
	<cftry>
		<cfset GetDefault = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_classification", {
				"is_default" = "eq.1",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDefault = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDefault>
<CFQUERY name="GetDefault" DATASOURCE="#Application.Datasource#">
				SELECT *
				FROM DD_Classification
				WHERE Is_Default = 1
				AND Deleted = 0
			</CFQUERY>
</cfif>
			<cfif Deduction_Info.DD_Classification_ID EQ GetDefault.DD_Classification_ID OR Deduction_Info.DD_Classification_ID EQ "">
				<cfset  ApprovalPermission = 0>
			</cfif>
		</cfif>
			<!---
				D41362 :: BAT & Prod - Deduction Closing <$0 Total Billback Association
				Below query gets the sum of all Associated Billback and check if sum of all Associated Billbacks Less than 0.
				If sum less than 0 we will stop user from RFA/Approve the Deduction by setting Variable letRfaApprove to 0, by default that variable value will be 1.
				All these is based on App setting "Allow Credits (Deductions with negative Amount)"
			  --->
			<!--- 72217 App setting to match ded to bb with equal amount not working for credits START --->
			<cfset AmountMisMatch = 0>
			<cfif Deduction_Info.DD_Status EQ 2 OR Deduction_Info.DD_Status EQ 3>

				<cfif Deduction_Info.DD_Closure_Type	EQ 1>
					<cfquery name="Associated_Billbacks_Amount" datasource="#application.datasource#">
						SELECT 	 SUM(ISNull(BB_Approved.Paid_Amount, 0)) AS Amount, D.DD_Amount
						FROM Billback
						INNER JOIN DD_Closure_Detail
						ON DD_Closure_Detail.DD_Closure_ID = Billback.Billback_ID
						AND DD_Closure_Detail.Deleted = 0
						INNER JOIN BB_Approved
						ON BB_Approved.Billback_ID = Billback.Billback_ID
						INNER JOIN Deductions D
						ON D.Deduction_ID = DD_Closure_Detail.Deduction_ID
						WHERE D.Deduction_ID = '#Deduction_ID#'
						GROUP BY D.DD_Amount
					</cfquery>

					<cfif appSettings.getDDAllowNegativeAmountCredits() EQ 0 AND Deduction_Info.DD_Status LTE 3 AND Associated_Billbacks_Amount.RecordCount AND len(Associated_Billbacks_Amount.Amount) AND Associated_Billbacks_Amount.Amount Lt 0>
						<cfset  letRfaApprove = 0>
					</cfif>

					<cfif appSettings.getDDCloseWithEqualBBAmt() AND (Associated_Billbacks_Amount.Amount NEQ Associated_Billbacks_Amount.DD_Amount)>
						<cfset  letRfaApprove = 0>
						<cfset AmountMisMatch = 1>
					</cfif>
				<cfelseif Deduction_Info.DD_Closure_Type	EQ 5>
					<cfquery name="Associated_Credits_Amount" datasource="#application.datasource#">
						SELECT SUM(c.DD_Amount) * -1 AS Amount, D.DD_Amount
						FROM Deductions c
						INNER JOIN DD_Closure_Detail
						ON DD_Closure_Detail.DD_Closure_ID = c.Deduction_ID
						AND DD_Closure_Detail.Deleted = 0
						INNER JOIN Deductions D
						ON D.Deduction_ID = DD_Closure_Detail.Deduction_ID
						WHERE D.Deduction_ID = '#Deduction_ID#'
						GROUP BY D.DD_Amount
					</cfquery>

					<cfif appSettings.getDDCloseWithEqualBBAmt() AND (Associated_Credits_Amount.Amount NEQ Associated_Credits_Amount.DD_Amount)>
						<cfset  letRfaApprove = 0>
						<cfset AmountMisMatch = 1>
					</cfif>
				</cfif>

			</cfif>
			<!--- 72217 App setting to match ded to bb with equal amount not working for credits END --->

		<!--- D41362 :: BAT & Prod - Deduction Closing <$0 Total Billback Association  --->
		<cfif (ApprovalPermission EQ 1 OR ApprovalRebillPermission EQ 1) AND ReOpenLogic_ShowLinks EQ 1 AND
					(
						Deduction_Info.DD_Rejected EQ 1
						OR Deduction_Info.Is_Write_Off EQ 1
						OR ApprovalRebillPermission EQ 1
						OR DeductionSettings.Require_BB_To_Close IS 0
						OR
						(
							len(trim(Deduction_Info.DD_Closure_ID)) GT 0 AND
							(
							Deduction_Info.DD_Closure_Type IS 1
							OR Deduction_Info.DD_Closure_Type EQ 5
							)
						)
					)
					AND
					(
						LockStatus EQ 1 OR
						(
						Reject_UnLocked EQ 1
						AND Deduction_Info.DD_Rejected EQ 1
						AND appSettings.getDDSentRejectIn1510()
						)
					)
					AND
					(
						Deduction_Info.DD_Status LT 4
						OR Deduction_Info.DD_Status EQ 7
						OR Deduction_Info.DD_Status EQ 8<!--- Dev Note: Clay : Add Writeoff functionality to Credit Transactions  --->
					)
					AND letRfaApprove
					>
				<A href="/deductions/deduction.cfm?CenterToShow=Closure&Closure_Type=Approve&Deduction_ID=#Deduction_ID#">
					<cfif CheckForAgreed.RecordCount GT 0 AND Get_Profile_Settings.DD_RFA_Agreed EQ 1 AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1 >
						Agree
					<cfelseif Deduction_Info.DD_Status EQ 4 AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
						Approved
					<cfelseif Deduction_Info.DD_Status EQ 3>
						Approve
					<cfelse>
						RFA
					</cfif>
				</A>
			<BR/>
		<cfelse>
			<font class="no_access">
				<cfif CheckForAgreed.RecordCount GT 0 AND Get_Profile_Settings.DD_RFA_Agreed EQ 1>
					Agree
				<cfelseif Deduction_Info.DD_Status EQ 4>
					Approved
				<cfelseif Deduction_Info.DD_Status EQ 3>
					<!---
						D41362 :: BAT & Prod - Deduction Closing <$0 Total Billback Association
						Once we prevent user not RFA/Approve the deduction we will show user a Mouse over message why they cannot RFA/Approve that deduction
					--->
					<cfif letRfaApprove EQ 0>
						<cfif AmountMisMatch>
							<span title="<cfif Deduction_Info.DD_Closure_Type EQ 5>Credit<cfelse>Billback</cfif> amount is not equal to deduction amount" style="cursor: pointer">RFA</span>
						<cfelse>
							<span title="Associated Billbacks total shouldn't be less than 0" style="cursor:pointer">Approve</span>
						</cfif>
					<cfelse>
						Approve
					</cfif>
					<!--- D41362 :: BAT & Prod - Deduction Closing <$0 Total Billback Association  --->
				<cfelse>
					<!---
						D41362 :: BAT & Prod - Deduction Closing <$0 Total Billback Association
						Once we prevent user not RFA/Approve the deduction we will show user a Mouse over message why they cannot RFA/Approve that deduction
					--->
					<cfif letRfaApprove EQ 0>
						<cfif AmountMisMatch>
							<span title="<cfif Deduction_Info.DD_Closure_Type EQ 5>Credit<cfelse>Billback</cfif> amount is not equal to deduction amount" style="cursor: pointer">RFA</span>
						<cfelse>
							<span title="Associated Billbacks total shouldn't be less than 0" style="cursor:pointer">RFA</span>
						</cfif>
					<cfelse>
						RFA
					</cfif>
					<!--- D41362 :: BAT & Prod - Deduction Closing <$0 Total Billback Association  --->
				</cfif>
			</font>
			<BR/>
		</cfif>
			<!---- DisAgree Link ---->
			<cfif (ApprovalPermission EQ 1 OR ApprovalRebillPermission EQ 1)
					AND ReOpenLogic_ShowLinks EQ 1
					AND
					(
						LockStatus EQ 1
						OR
						(
						Reject_UnLocked EQ 1
						AND Deduction_Info.DD_Rejected EQ 1
						AND appSettings.getDDSentRejectIn1510()
						)
					)
					AND Deduction_Info.DD_Status EQ 3
			>
					<A href="/deductions/deduction.cfm?CenterToShow=Disagree&Deduction_ID=#Deduction_ID#">DisAgree</A><BR/>
			<cfelse>
				<font class="no_access">DisAgree</font><BR/>
			</cfif>
	<!---Billback requirements--->
		</cfif>
		<!---
		Dev Notes: 19384/Anand Rao/05-Apr-10
		Rebill Interface and changes/Added appSettings.getIntegrated_Rebill()
		--->
		<cfif disableBasedOnClassification EQ 0 AND (appSettings.getIntegrated_Rebill() EQ 1 AND Deduction_Info.Is_Write_Off EQ 0 AND ReOpenLogic_ShowLinks EQ 1 AND DeductionsProfilesSettings.DD_Approve_Rebill AND Deduction_Info.DD_Status EQ 2 AND len(trim(Deduction_Info.DD_Closure_ID)) EQ 0 AND LockStatus EQ 1 AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1 AND ((CheckForChild.RecordCount EQ 0 AND Deduction_Info.DD_ISParent EQ 1) OR Deduction_Info.DD_Ischild EQ 1) )>
				<A href="/deductions/deduction.cfm?CenterToShow=RebillInt&Deduction_ID=#Deduction_ID#" title="Rebill Integration">Rebill</A><BR/>
		<cfelseif (appSettings.getIntegrated_Rebill() EQ 1 AND Deduction_Info.Is_Write_Off EQ 0 AND ReOpenLogic_ShowLinks EQ 1 AND DeductionsProfilesSettings.DD_Approve_Rebill AND Deduction_Info.DD_Status EQ 7 AND len(trim(Deduction_Info.DD_Closure_ID)) EQ 0 AND LockStatus EQ 1 AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1 AND ((CheckForChild.RecordCount EQ 0 AND Deduction_Info.DD_ISParent EQ 1) OR Deduction_Info.DD_Ischild EQ 1) AND Deduction_Info.Rebill_Ack_Status EQ 1)>
				<A href="/deductions/deduction.cfm?CenterToShow=ClearRebill&Deduction_ID=#Deduction_ID#">Clear Rebill<!---Clear Rebill---></A><BR/>
		<!--- added this else if to display the Rebill as text when the DD is not Locked --->
		<cfelseif (appSettings.getIntegrated_Rebill() EQ 1 AND Deduction_Info.Is_Write_Off EQ 0 AND ReOpenLogic_ShowLinks EQ 1 AND DeductionsProfilesSettings.DD_Approve_Rebill AND Deduction_Info.DD_Status EQ 2 AND len(trim(Deduction_Info.DD_Closure_ID)) EQ 0 AND LockStatus EQ 0 AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1 AND ((CheckForChild.RecordCount EQ 0 AND Deduction_Info.DD_ISParent EQ 1) OR Deduction_Info.DD_Ischild EQ 1) )>
				<font class="no_access">Rebill</font><BR/>
		</cfif>
		<cfif (application.returned_customer_setting.DD_Show_Rebill EQ 1)>
			<cfif Deduction_Info.Is_Write_Off EQ 0
					AND disableBasedOnClassification EQ 0
					AND ReOpenLogic_ShowLinks EQ 1
					AND DeductionsProfilesSettings.DD_Open_Rebill_Transfer EQ 1
					AND Deduction_Info.DD_Status LTE 2
					AND len(trim(Deduction_Info.DD_Closure_ID)) EQ 0
					AND LockStatus EQ 1
					AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1
					AND ((CheckForChild.RecordCount EQ 0 AND Deduction_Info.DD_ISParent EQ 1) OR Deduction_Info.DD_Ischild EQ 1)>
						<A href="/deductions/deduction.cfm?CenterToShow=Rebill&Deduction_ID=#Deduction_ID#">Rebill</A>
						<BR/>
			<cfelseif Deduction_Info.Is_Write_Off EQ 0
					AND ReOpenLogic_ShowLinks EQ 1
					AND Deduction_Info.DD_Status EQ 7
					AND DeductionsProfilesSettings.DD_Open_Rebill_Transfer EQ 1
					AND application.returned_customer_setting.DD_Show_Rebill EQ 1
					AND LockStatus EQ 1
					AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1
					AND ((CheckForChild.RecordCount EQ 0 AND Deduction_Info.DD_ISParent EQ 1) OR Deduction_Info.DD_Ischild EQ 1)>
				<A href="/deductions/deduction.cfm?CenterToShow=BackToOpen&Deduction_ID=#Deduction_ID#">Back to Open </A><BR/>
			<cfelse>
				<font class="no_access">Rebill</font><BR/>
			</cfif>
		</cfif>
	<!--- Dev Note: Clay : Add Writeoff functionality to Credit Transactions  --->
		<cfif appSettings.getDDAllowWriteOff() EQ 1>
			<cfif ReOpenLogic_ShowLinks EQ 1
					AND disableBasedOnClassification EQ 0
					AND Deduction_Info.Is_Write_Off NEQ 1
					AND (Deduction_Info.DD_Status LTE 2 OR Deduction_Info.DD_Status EQ 8)
					AND len(trim(Deduction_Info.DD_Closure_ID)) EQ 0
					AND LockStatus EQ 1
					AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1
					AND ((CheckForChild.RecordCount EQ 0 AND Deduction_Info.DD_ISParent EQ 1) OR Deduction_Info.DD_Ischild EQ 1)>
				<A href="/deductions/deduction.cfm?CenterToShow=WriteOff&Deduction_ID=#Deduction_ID#">#stDeductionLabels["Write Off"]#</A><BR/>
			<cfelseif ReOpenLogic_ShowLinks EQ 1
					AND disableBasedOnClassification EQ 0
					AND Deduction_Info.Is_Write_Off EQ 1
					AND (Deduction_Info.DD_Status LTE 2 OR Deduction_Info.DD_Status EQ 8)
					AND appSettings.getDDAllowWriteOff() EQ 1
					AND LockStatus EQ 1
					AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1
					AND ((CheckForChild.RecordCount EQ 0 AND Deduction_Info.DD_ISParent EQ 1)
					OR Deduction_Info.DD_Ischild EQ 1)>
				<A href="/deductions/deduction.cfm?CenterToShow=WFToOpen&Deduction_ID=#Deduction_ID#">#stDeductionLabels["Write Off"]# to Open</A><BR/>
			<cfelse>
				<font class="no_access">#stDeductionLabels["Write Off"]#</font><BR/>
			</cfif>
		</cfif>
	<!--- D29481:Non trade deductions START--->
		<cfif appSettings.getDD_Allow_Non_Trade()>
			<!--- This condition check if user can close deduction as non trade --->
			<cfif ReOpenLogic_ShowLinks EQ 1
					AND Deduction_Info.Is_Write_Off NEQ 1
					AND Deduction_Info.Is_Non_trade_Off NEQ 1
					AND (Deduction_Info.DD_Status EQ 1 OR Deduction_Info.DD_Status EQ 2)
					AND len(trim(Deduction_Info.DD_Closure_ID)) EQ 0
					AND LockStatus EQ 1
					AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1
					AND ((CheckForChild.RecordCount EQ 0 AND Deduction_Info.DD_ISParent EQ 1) OR Deduction_Info.DD_Ischild EQ 1)>
				  	  <!--- D38841 : Update non-trade feature to open in a new window--->
					<a href="##" onclick="window.open('/deductions/closure/DD_Non_trade_all_items.cfm?from=detail&Deduction_ID=#Deduction_ID#&Profile_ID=#Get_Profile_Settings.Profiles_ID#','Close_As_Non_Trade', 'width=1000, height=600,resizable=1,scrollbars=1');">Close As Non Trade</a>
			<!--- This condition check if user closed deduction as non trade --->
			<cfelseif ReOpenLogic_ShowLinks EQ 1 AND Deduction_Info.Is_Write_Off NEQ 1  AND Deduction_Info.Is_Non_trade_Off EQ 1 AND
				      (Deduction_Info.DD_Status EQ 1 OR Deduction_Info.DD_Status EQ 2) <!---  AND len(trim(Deduction_Info.DD_Closure_ID)) EQ 0 D34163 : Deduction - unable to close--->
					  AND LockStatus EQ 1 AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1 AND ((CheckForChild.RecordCount EQ 0 AND
					  Deduction_Info.DD_ISParent EQ 1) OR Deduction_Info.DD_Ischild EQ 1)>
				<a href="/deductions/deduction.cfm?CenterToShow=NonTradeToOpen&Deduction_ID=#Deduction_ID#">Open Non Trade</a>
			<cfelse>
				<font class="no_access">Close As Non Trade</font><img src="/images/doc.gif" border="0" width="10" height="13" onclick="window.open('/deductions/closure/DD_Non_trade_Items_info.cfm?Deduction_ID=#Deduction_ID#','Deduction_Info', 'width=1000, height=600,resizable=1,scrollbars=1');">
				<BR/>
			</cfif>
		</cfif>
	<!--- D29481:Non trade deductions END--->
		<cfif appSettings.getDD_Show_Create_Adjustment()>
			<cfif Deduction_Info.Is_Write_Off EQ 0
					AND ReOpenLogic_ShowLinks EQ 1
					AND DeductionSettings.ExcandAdj IS 1
					AND len(trim(Deduction_Info.Distributor_ID)) GT 0
					AND len(trim(Deduction_Info.DD_Closure_ID)) EQ 0
					AND LockStatus EQ 1
					AND (Deduction_Info.DD_Status LT 3 OR DeductionsProfilesSettings.DD_Approve IS 1)
					AND (Deduction_Info.DD_Status LT 4 OR Deduction_Info.DD_Status EQ 7)
					AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
				<A href="/deductions/deduction.cfm?CenterToShow=Closure&Closure_Type=Adjust&Deduction_ID=#Deduction_ID#">Create Adjustment</A><BR/>
			<cfelse>
				<font class="no_access">Create Adjustment</font><BR/>
			</cfif>
		</cfif>
		<cfif appSettings.getDD_Show_Delete()>
			<cfif Deduction_Info.Is_Write_Off EQ 0
					AND ReOpenLogic_ShowLinks EQ 1
					AND Deduction_Info.DD_Status IS 6
					AND DeductionsProfilesSettings.DD_Delete EQ 1
					AND LockStatus EQ 1
					AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
					<A href="/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#&CenterToShow=UnDelete">UnDelete</a><BR/>
			<cfelseif Deduction_Info.Is_Write_Off EQ 0
					AND ReOpenLogic_ShowLinks EQ 1
					AND DeductionsProfilesSettings.DD_Delete EQ 1
					AND len(trim(Deduction_Info.DD_Closure_ID)) EQ 0
					AND LockStatus EQ 1
					AND (Deduction_Info.DD_Status LT 3 OR Deduction_Info.DD_Status EQ 7)
					AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1
					AND ((CheckForChild.RecordCount EQ 0 AND Deduction_Info.DD_ISParent EQ 1) OR Deduction_Info.DD_Ischild EQ 1)>
				<A href="/deductions/deduction.cfm?CenterToShow=Delete&Deduction_ID=#Deduction_ID#">Delete</A><BR/>
			<cfelse>
				<font class="no_access"><cfif Deduction_Info.DD_Status IS 6>UnDelete<cfelse>Delete</cfif></font><BR/>
			</cfif>
		</cfif>
	<cfset  ReopenLinkEnabled = 0>
		<cfif (Deduction_Info.DD_Status IS 4 OR Deduction_Info.DD_Status IS 9)
				AND
				(
					(Deduction_Info.DD_Closure_Sent EQ 0 AND Deduction_Info.Ack_received_Closure EQ 0 AND Deduction_Info.ReOpened EQ 0 AND Deduction_Info.DD_Reopened_Sent EQ 0 AND Deduction_Info.Ack_received_Reopen EQ 0)
				OR
					(Deduction_Info.DD_Closure_Sent EQ 1 AND Deduction_Info.Ack_received_Closure EQ 1 AND Deduction_Info.ReOpened EQ 0 AND Deduction_Info.DD_Reopened_Sent EQ 0 AND Deduction_Info.Ack_received_Reopen EQ 0)
				)
		>
			<cfset  ReopenLinkEnabled = 1>
		</cfif>
		<cfif appSettings.getDD_Show_ReOpen()>
			<cfif ReopenLinkEnabled
					AND LockStatus EQ 1
					AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1
					AND (Deduction_Info.DD_Status EQ 4 OR (Deduction_Info.DD_Status EQ 9 AND Deduction_Info.Is_Write_Off EQ 1) OR (Deduction_Info.DD_Status EQ 9 AND Deduction_Info.DD_Closure_Type EQ 1))
					AND ( (appSettings.getDDReopenParent() EQ 0 AND ((CheckForChild.RecordCount EQ 0 AND Deduction_Info.DD_ISParent EQ 1) OR Deduction_Info.DD_Ischild EQ 1))
					OR (appSettings.getDDReopenParent() EQ 1 AND ((CheckForChild.RecordCount EQ 0 AND Deduction_Info.DD_ISParent EQ 1) OR Deduction_Info.DD_ISParent EQ 1))
					)
					AND DeductionsProfilesSettings.DD_ReOpen EQ 1
				>
				<A href="/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#&CenterToShow=Reopen">Reopen</a><BR/>
			<cfelse>
				<font class="no_access">Reopen</font><BR/>
			</cfif>
		</cfif>
		<cfif appSettings.getDD_Show_Reject()>
			<cfif Deduction_Info.Is_Write_Off EQ 0
					AND ReOpenLogic_ShowLinks EQ 1
					AND Deduction_Info.DD_Rejected NEQ 1
					AND LockStatus EQ 1
					AND (Deduction_Info.DD_IsChild NEQ 1 OR CheckForChild.RecordCount EQ 0)
					AND DeductionsProfilesSettings.DD_Reject EQ 1
					AND (Deduction_Info.DD_Status LT 3 OR Deduction_Info.DD_Status EQ 8)
					AND len(trim(Deduction_Info.DD_Closure_ID)) EQ 0
					AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1
					AND ((CheckForChild.RecordCount EQ 0 AND Deduction_Info.DD_ISParent EQ 1) OR Deduction_Info.DD_Ischild EQ 1)>
					<A HREF="/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#&CenterToShow=Reject">Reject</A>
			<cfelse>
				<font class="no_access">Reject</font><BR/>
			</cfif>
		</cfif>
	</td>
</tr>
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// LEFT MENU SECTION 3 ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cfset useLakebaseForDisableIfParent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForDisableIfParent>
	<cftry>
		<cfset DisableIfParent = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"dd_parent_id" = "eq.#Deduction_Info.Deduction_ID#",
				"deleted" = "eq.0",
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDisableIfParent = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDisableIfParent>
<CFQUERY name="DisableIfParent" DATASOURCE="#Application.Datasource#">
		SELECT TOP 1 *
		FROM Deductions
		WHERE DD_Parent_ID = '#Deduction_Info.Deduction_ID#'
		AND Deleted = 0
	</CFQUERY>
</cfif>

	<cfif ((Deduction_Info.DD_Status LT 3 OR DeductionsProfilesSettings.DD_Approve IS 1) AND (Deduction_Info.DD_Status LT 4 OR Deduction_Info.DD_Status EQ 7))
			OR (Appsettings.getDDAllowNegativeAmountCredits() AND Deduction_Info.DD_Status EQ 8 AND Deduction_Info.Is_Credit EQ 1)>
	<cfif Deduction_Info.Is_Write_Off EQ 0
			AND ReOpenLogic_ShowLinks EQ 1
			AND LockStatus EQ 1
			AND len(trim(Deduction_Info.DD_Closure_ID)) EQ 0
			AND DisableIfParent.RecordCount EQ 0><!------ Locked ----->
<tr>
	<td align="center" nowrap style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0">
		<img border="0" src="/images/search.gif" title="Searches">
	</td>
	<td width="100%" style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0">
		<!---Associate a program with the deduction--->
		<cfif appSettings.getDD_Show_Program()>
			<cfif DeductionSettings.Program IS 1
				AND Deduction_Info.DD_Status NEQ 8
				AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
				<A href="##" onclick="NewWindow('/billbacks/search_screens/search_programs.cfm?Distributor_ID=#GetDistributor.Distributor_ID#&Distributor_Bill_To_ID=#GetDistributor.Distributor_Bill_To_ID#&Formname=AddProgram&Deduction_ID=#Deduction_ID#&SelectSingleSearchResultOnly=1&Source=Deductions&Fieldname=Program_ID', 'programs', 800, 600, 'yes', 'yes')">Programs</a><BR/>
			<cfelseif DeductionSettings.Program IS 1>
				<font class="no_access">Programs</font><BR/>
			</cfif>
		</cfif>

		<cfif DeductionSettings.Billback IS 1
			AND disableBasedOnClassification EQ 0
			AND Deduction_Info.DD_Status LT 3
			AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
		<!--- D17544 modified width from 900 to 930 RBL 11/17/08 --->
			<A href="##" onclick="NewWindow('/deductions/search_screens/billbacks.cfm?ParentForm=Deductions&Deduction_ID=#Deduction_ID#&Return_value=1&Source=Deductions&Distributor_ID=#Distributor_ID#', 'billbacks', 1300, 800, 'yes', 'yes')">Billbacks</a><BR/>
		<cfelse>
			<font class="no_access">Billbacks</font><BR/>
		</cfif>
		<cfif Appsettings.getDDAllowNegativeAmountCredits()>
			<cfif Deduction_Info.DD_Status EQ 8
					AND Deduction_Info.Is_Credit EQ 1
					AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
				<A href="/deductions/deduction.cfm?CenterToShow=LinkDeduction&Deduction_ID=#Deduction_ID#">Deduction</A><BR/>
			<cfelseif Deduction_Info.DD_Status LT 3
							AND disableBasedOnClassification EQ 0
							AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
				<A href="/deductions/deduction.cfm?CenterToShow=LinkCredit&Deduction_ID=#Deduction_ID#">Credit</A><BR/>
			<cfelse>
				<font class="no_access"><cfif Deduction_Info.Is_Credit EQ 1>Deduction<cfelse>Credit</cfif></font><BR/>
			</cfif>
		</cfif>
		<cfif DeductionSettings.Pricing IS 1
				AND Deduction_Info.DD_Status LT 3
				AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
		<A href="##">Pricing errors</A><BR/>
		<cfelseif DeductionSettings.Pricing IS 1
						AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
		<font class="no_access">Pricing errors</font><BR/>
		</cfif>
		<cfif DeductionSettings.OSandD IS 1
				AND Deduction_Info.DD_Status LT 3
				AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
				<A href="##">OS&amp;D</A><BR/>
		<cfelseif DeductionSettings.OSandD IS 1
				AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
			<font class="no_access">OS&amp;D</font><BR/>
		</cfif>
		<cfif appSettings.getDD_Show_Invoices()>
			<cfif DeductionSettings.Invoices IS 1
					AND Deduction_Info.DD_Status LT 3
					AND DeductionsProfilesSettings.DD_Disable_Inv_Link EQ 0
					AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1> <!--- Dev Note: KAL; D8151 --->
					<A href="javascript: void(0);" onclick="NewWindow('/deductions/search_screens/invoice.cfm?ParentForm=Deductions&Deduction_ID=#Deduction_ID#&Return_value=1&Source=Deductions&Distributor_ID=#Distributor_ID#', 'invoices', 1000, 600, 'yes', 'yes')">Invoices</a><BR/>
			<cfelseif DeductionSettings.Invoices IS 1>
					<font class="no_access">Invoices</font><BR/>
			</cfif>
		</cfif>
		<cfif appSettings.getDD_Show_Create_Adjustment()>
			<cfif DeductionSettings.ExcandAdj IS 1
					AND Deduction_Info.DD_Status LT 3
					AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
				<A href="javascript: void(0);" onclick="NewWindow('/deductions/search_screens/adjustment_exclusions.cfm?ParentForm=Deductions&Deduction_ID=#Deduction_ID#', 'adjustmentsandexclusions', 1000, 600, 'yes', 'yes')">Adjustments</a><BR/>
			<cfelseif DeductionSettings.ExcandAdj IS 1>
				<font class="no_access">Adjustments</font><BR/>
			</cfif>
		</cfif>
		<cfif application.returned_customer_setting.DD_Show_Distributor EQ 1>
			<cfif (Deduction_Info.DD_Status LT 3 OR Deduction_Info.DD_Status EQ 8)
					AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
			<!--- D39095 :: Deduction Filtering  --->
				<cfset DistributorBillToID = GetDistributor.Distributor_Bill_To_ID/>
				<cfif appSettings.get_Setting('Deduction_Ship_To_Bill_To_Association_Required') neq '1'>
					<cfset DistributorBillToID = ''/>
				</cfif>
				<A href="javascript: void(0);" onclick="NewWindow('/billbacks/search_Screens/PM_select_distributors.cfm?Formname=AddDistributor&Distributor_Bill_To_ID=#DistributorBillToID#', 'DistributorSearch', '800', '600', 'yes', 'yes')">#application.returned_customer_setting.distributor_label_singular#</a><BR/><!--- &Distributor_Bill_To_ID=#GetDistributor.Distributor_Bill_To_ID# --->
			<cfelse>
				<font class="no_access">#application.returned_customer_setting.distributor_label_singular#</font><BR/>
			</cfif>
		</cfif>
		<cfif application.returned_customer_setting.DD_Show_Distributor EQ 1>
			<cfif (Deduction_Info.DD_Status LT 3 OR Deduction_Info.DD_Status EQ 8)
					AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
				<A href="javascript: void(0);" onclick="NewWindow('/billbacks/search_Screens/PM_select_brokers.cfm?Formname=AddBroker', 'BrokerSearch', '800', '600', 'yes', 'yes')">#application.returned_customer_setting.Broker_label_singular#</a><BR/><!--- &Distributor_Bill_To_ID=#GetDistributor.Distributor_Bill_To_ID# --->
			<cfelse>
				<font class="no_access">#application.returned_customer_setting.broker_label_singular#</font><BR/>
			</cfif>
		</cfif>
		<cfif application.returned_customer_setting.DD_Show_Rebill EQ 1
			AND Deduction_Info.DD_Status IS 7
			AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
		<a href="/deductions/deduction.cfm?CenterToShow=RebillLetter&Deduction_ID=#Deduction_ID#">Rebill Letters</a><BR/>
	</cfif>
	</td>
</tr>
<cfelse><!------ Not Locked ----->
<!---Display if the deduction is not locked/unavailable--->
<tr>
	<td align="center" nowrap style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0">
		<img border="0" src="/images/search.gif" title="Searches">
	</td>
	<td width="100%" style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0">
		<cfif appSettings.getDD_Show_Program()
				AND DeductionSettings.Program IS 1>
			<font class="no_access">Programs</font><BR/>
		</cfif>
		<cfif DeductionSettings.Billback IS 1>
			<font class="no_access">Billbacks</font><BR/>
		</cfif>
		<cfif Appsettings.getDDAllowNegativeAmountCredits()
			AND Deduction_Info.DD_Status EQ 8
			AND Deduction_Info.Is_Credit EQ 1>
			<font class="no_access">Deduction</font><BR/>
		</cfif>
		<cfif DeductionSettings.Pricing IS 1>
			<font class="no_access">Pricing errors</font><BR/>
		</cfif>
		<cfif DeductionSettings.OSandD IS 1>
			<font class="no_access">OS&amp;D</font><BR/>
		</cfif>
		<cfif appSettings.getDD_Show_Invoices()
				AND DeductionSettings.Invoices IS 1>
			<font class="no_access">Invoices</font><BR/>
		</cfif>
		<cfif appSettings.getDD_Show_Create_Adjustment()
				AND DeductionSettings.ExcandAdj IS 1>
			<font class="no_access">Adjustments</font><BR/>
		</cfif>
		<cfif application.returned_customer_setting.DD_Show_Distributor EQ 1>
			<font class="no_access">#application.returned_customer_setting.distributor_label_singular#</font><BR/>
		</cfif>
		<cfif application.returned_customer_setting.DD_Show_Distributor EQ 1>
			<font class="no_access">#application.returned_customer_setting.Broker_label_singular#</font><BR/>
		</cfif>
		<cfif application.returned_customer_setting.DD_Show_Rebill EQ 1 AND Deduction_Info.DD_Status IS 7>
		<font class="no_access">Rebill Letters</font><BR/>
	</cfif>
	</td>
</tr>
</cfif><!------ Locked ----->
	<cfelse><!------ Else for (Deduction_Info.DD_Status LT 3 OR DeductionsProfilesSettings.DD_Approve IS 1) AND Deduction_Info.DD_Status LT 4 ----->
	<tr>
	<td align="center" nowrap style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0">
		<img border="0" src="/images/search.gif" title="Searches">
	</td>
	<td width="100%" style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0">
		<cfif DeductionSettings.Billback IS 1>
			<font class="no_access">Billbacks</font><BR/>
		</cfif>
		<cfif Appsettings.getDDAllowNegativeAmountCredits() AND Deduction_Info.DD_Status EQ 8 AND Deduction_Info.Is_Credit EQ 1>
			<font class="no_access">Deduction</font><BR/>
		</cfif>
		<cfif DeductionSettings.Pricing IS 1>
			<font class="no_access">Pricing errors</font><BR/>
		</cfif>
		<cfif DeductionSettings.OSandD IS 1>
			<font class="no_access">OS&amp;D</font><BR/>
		</cfif>
		<cfif DeductionSettings.Invoices IS 1>
			<font class="no_access">Invoices</font><BR/>
		</cfif>
		<cfif application.returned_customer_setting.DD_Show_Distributor EQ 1>
			<font class="no_access">#application.returned_customer_setting.distributor_label_singular# </font><BR/>
		</cfif>
		<cfif application.returned_customer_setting.DD_Show_Distributor EQ 1>
			<font class="no_access">#application.returned_customer_setting.Broker_label_singular# </font><BR/>
		</cfif>
		<cfif application.returned_customer_setting.DD_Show_Rebill EQ 1 AND Deduction_Info.DD_Status IS 7>
			<font class="no_access">Rebill Letters</font><BR/>
		</cfif>
	</td>
	</tr>
	</cfif>
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// LEFT MENU SECTION 3 ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<tr>
	<td rowspan="2" align="center" nowrap style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0">
		<img src="/images/communicate.gif">
	</td>
	<TD>
		<A href="/deductions/deduction.cfm?CenterToShow=Optionfor_Email&Deduction_ID=#Deduction_ID#">Email</A> / <A Href="/deductions/deduction.cfm?CenterToShow=EmailLog&Deduction_ID=#Deduction_ID#">View Log</A><BR/>
		<!------ DEV NOTE DRK: D9450 - Reviewing and Printing the attached documents always ----->
		<A href="/deductions/deduction.cfm?CenterToShow=Attachments&Deduction_ID=#Deduction_ID#">Attach Documents</A><BR/>
		<cfif appSettings.getErpDeductionDocPath() NEQ ''>
			<A href="/deductions/deduction.cfm?CenterToShow=ERPDocuments&Deduction_ID=#Deduction_ID#">View OnBase Docs</A><BR/>
		</cfif>
		<A href="/deductions/deduction.cfm?CenterToShow=Optionfor_Print&Deduction_ID=#Deduction_ID#">Print</A><BR/>
	</td>
	</tr>
	<tr>
	<TD>
		<cfset  userManager = CreateObject("component", "components.user.UserManager").init() />
	<table cellpadding="0" cellspacing="0">
		<tr>
			<td style="color:blue;cursor:pointer;">
					<cf_smallHelp
						borderColor="black"
						backgroundColor="WhiteSMoke"
						showImage="0"
						showText="Created On"
						borderWidth="1">
						#Dateformat(Deduction_Info.Created_Date, "mm/dd/yyyy")#
					</cf_smallHelp>
			</td>
		</tr>
		<!--- Ana D19384 Rebill By --->
		<cfif Deduction_Info.DD_Status EQ 7 OR Deduction_Info.Is_last_Status_Rebill EQ 1>
		<tr>
			<td style="color:blue;cursor:pointer;">
				<cf_smallHelp
						borderColor="black"
						backgroundColor="WhiteSMoke"
						showImage="0"
						showText="Rebilled By"
						borderWidth="1">
						#Deduction_Info.Rebilled_By#<BR/>#Dateformat(Deduction_Info.Rebilled_Date, "mm/dd/yyyy")#
				</cf_smallHelp>
			</td>
		</tr>
		</cfif>
	<cfinclude template="users_agreed.cfm">
		<tr>
		<cfif getdeductionsuseragreed.recordcount GT 0>
			<td style="color:blue;cursor:pointer;">
				<cf_smallHelp
					borderColor="black"
					backgroundColor="WhiteSMoke"
					showImage="0"
					width="150"
					showText="Agreed By"
					borderWidth="1">
					#agreed_users#
				</cf_smallHelp>
			</td>
		<cfelse>
				<td style="color:gray;cursor:pointer;">Agreed By</td>
		</cfif>
		</tr>
		<tr>
		<cfif Deduction_Info.DD_Closed_By NEQ "">
			<td style="color:blue;cursor:pointer;">
				<cf_smallHelp
						borderColor="black"
						backgroundColor="WhiteSMoke"
						showImage="0"
						showText="Closed By"
						borderWidth="1">
						#userManager.getUserName(Deduction_Info.DD_Closed_By)#
						#Dateformat(Deduction_Info.DD_Date_Closed, "mm/dd/yyyy")#
				</cf_smallHelp>
			</td>
		<cfelse>
			<td style="color:gray;cursor:pointer;">Closed By</td>
		</cfif>
		</tr>
		<tr>
		<cfif Deduction_Info.DD_Rejected_By NEQ "">
			<td style="color:blue;cursor:pointer;">
				<cf_smallHelp
						borderColor="black"
						backgroundColor="WhiteSMoke"
						showImage="0"
						showText="Rejected By"
						borderWidth="1">
						#userManager.getUserName(Deduction_Info.DD_Rejected_By)#
						#Dateformat(Deduction_Info.DD_Rejected_Date, "mm/dd/yyyy")#
				</cf_smallHelp>
			</td>
		<cfelse>
			<td style="color:gray;cursor:pointer;">Rejected By</td>
		</cfif>
		</tr>
		<tr>
			<td style="color:blue;cursor:pointer;">
				<a href="/deductions/deduction.cfm?CenterToShow=ReassignHistory&Deduction_ID=#Deduction_ID#">Reassign History</a>
			</td>
		</tr>
	</table>
</td>
</tr>
	<cfquery name="GetCompletedActions" datasource="#application.datasource#">
		SELECT DD_Ded_Actions.*, DD_Stage_Description ,_Users.Name_first, _Users.Name_Last
		FROM DD_Ded_Actions
		INNER JOIN DD_Stage
		ON DD_Stage.DD_Stage_ID = DD_Ded_Actions.DD_Stage_ID
		LEFT JOIN _USERS
		ON  _USERS.User_Id = DD_Ded_Actions.Completed_by
		WHERE Deduction_ID = '#Deduction_ID#'
		ORDER BY DD_Ded_Actions.Date_Completed DESC
	</cfquery>
	<tr>
		<td align="center" nowrap style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0" colspan="2">
			<HR noshade color="##C0C0C0" size="1" style="margin-top:10px;margin-bottom:10px;">
		</td>
	<form action="/deductions/deduction.cfm" method="post" name="ChangeStage">
	<tr>
	<td align="left" nowrap style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0" valign="top">
		<cfif DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
			<img src="/images/actions.gif">
		</cfif>
	</td>
	<td width="100%" style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0" valign="center">
	<cfif appSettings.get_Setting('Custom_Deduction_workflow') neq '1' AND ((Deduction_Info.DD_Status LT 3 OR DeductionsProfilesSettings.DD_Approve IS 1) AND (Deduction_Info.DD_Status LT 4 OR Deduction_Info.DD_Status EQ 7)) OR Deduction_Info.DD_Status EQ 8 AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
	<cfset useLakebaseForGetStages = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_stage")>
<cfif useLakebaseForGetStages>
	<cftry>
		<cfset GetStages = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_stage", {
				"deleted" = "eq.0",
				"order" = "dd_stage_description.asc",
				"select" = "dd_stage_description,dd_stage_id"
			}), "dd_stage_description,dd_stage_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetStages = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetStages>
<cfquery name="GetStages" datasource="#application.datasource#">
		SELECT DISTINCT DD_Stage_Description, DD_Stage_ID
		FROM DD_Stage
		WHERE Deleted = 0
		ORDER BY DD_Stage_Description
	</cfquery>
</cfif>
	<cfif DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
		<select name="DD_Stage_ID" <cfif LockStatus NEQ 1>DISABLED</cfif> STYLE="WIDTH: 123px">
			<cfloop query="GetStages">
			<option value="#DD_Stage_ID#">#DD_Stage_Description#</option>
			</cfloop>
		</select>
	</cfif>
	<cfif ReOpenLogic_ShowLinks EQ 1 AND LockStatus EQ 1 AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1 and appSettings.get_Setting('Custom_Deduction_workflow') neq '1'>
		(<a href="javascript: void(0);" onclick="NewWindow('action_comments.cfm?Deduction_ID=#Deduction_ID#&DD_Ded_Action_ID=#GetCompletedActions.DD_Ded_Action_ID#&UpdateAction=0&DD_Stage_ID='+document.ChangeStage.DD_Stage_ID.options[document.ChangeStage.DD_Stage_ID.selectedIndex].value, 'Action_Comments', 450, 400, 'yes', 'yes')">Add</a>)
	</cfif>
	<cfelse>
		<cfset useLakebaseForGetStatusDescription = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_stage")>
<cfif useLakebaseForGetStatusDescription>
	<cftry>
		<cfset GetStatusDescription = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_stage", {
				"dd_stage_id" = "eq.#Deduction_Info.DD_Stage#",
				"select" = "dd_stage_description"
			}), "dd_stage_description"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetStatusDescription = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetStatusDescription>
<cfquery name="GetStatusDescription" datasource="#application.datasource#">
			SELECT DD_Stage_Description
			FROM DD_Stage
			WHERE DD_Stage_ID = '#Deduction_Info.DD_Stage#'
		</cfquery>
</cfif>
		Current Action: #GetStatusDescription.DD_Stage_Description#
	</cfif>
	</tr>
	</form>
	<cfif GetCompletedActions.Recordcount GT 0>
	<tr>
		<td align="left" nowrap style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0" colspan="2">
			<strong>Completed #stDeductionLabels["Action"]#:</strong>
		</td>
	</tr>
	<tr>
		<td width="100%" style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0" valign="top" colspan="2">
			<cfloop query="GetCompletedActions">
				<cfset  NoAccess = 0>
				 <cfif DeductionsProfilesSettings.DD_Internal_Notes eq 0 AND CommentsFlag eq 1>
				 	<cfset  NoAccess = 1>
				</cfif>
				<cfif NoAccess eq 0>
					<li>
						<a href="javascript: void(0);" onclick="NewWindow('action_comments.cfm?Deduction_ID=#Deduction_ID#&DD_Ded_Action_ID=#DD_Ded_Action_ID#&DD_Stage_ID=#DD_Stage_ID#&UpdateAction=1', 'Action_Comments', 450, 400, 'yes', 'yes')">
								<cf_smallHelp
										borderColor="black"
										backgroundColor="WhiteSMoke"
										showImage="0"
										showText="#dateformat(Date_Completed, 'MM/DD/YYYY')# - #DD_Stage_Description# "
										showTextColor="blue"
										borderWidth="1">
										<cfoutput>
										<span style="color:RGB(0,0,255)">#JSStringFormat(GetCompletedActions.Name_First)# #JSStringFormat(GetCompletedActions.Name_Last)#</span>
										</cfoutput>
								</cf_smallHelp>
						</a>
					</li>
				</cfif>
			</cfloop>
		</td>
	</tr>
<cfelse>
	<tr>
		<td width="100%" colspan="2" style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0" valign="top">
			No #LCase(stDeductionLabels["Action"])#s completed
		</td>
	</tr>
</cfif>
	<tr>
		<td align="right"  style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0" valign="top">&nbsp;</td>
		<td width="100%" style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0" valign="top">&nbsp;</td>
	</tr>
</table>
</div>
</div>
<cfparam name="IncludedFile" default="/deductions/inc_deduction_details.cfm?Deduction_ID=#Deduction_ID#&showScissor=#LockStatus#">
	<cfif CenterToShow IS "Details">
		<cfset IncludedFile="/deductions/inc_deduction_details.cfm?Deduction_ID=#Deduction_ID#&showScissor=#LockStatus#">
	<cfelseif CenterToShow IS "Closure">
		<cfset IncludedFile="/deductions/closure/index.cfm?Deduction_ID=#Deduction_ID#&Closure_Type=#Closure_Type#">
	<cfelseif CenterToShow IS "Split">
		<cfset IncludedFile="/deductions/split/Split_parent.cfm?Deduction_ID=#Deduction_ID#&FromSplit=1">
	<cfelseif CenterToShow IS "SplitandEdit">
		<cfset IncludedFile="/deductions/split/Split_parent.cfm?Deduction_ID=#Deduction_ID#&FromSplit=1&Mode=Edit">
	<cfelseif CenterToShow IS "Edit">
		<cfset IncludedFile="/deductions/Edit_Deduction.cfm?Deduction_ID=#Deduction_ID#">
	<cfelseif CenterToShow IS "SplitResult">
		<cfset IncludedFile="/deductions/split/Split_Result.cfm?Deduction_ID=#Deduction_ID#">
	<cfelseif CenterToShow IS "Reassign">
		<cfset IncludedFile="/deductions/Reassign/Single_DD_Reassign.cfm?Deduction_ID=#Deduction_ID#">
	<cfelseif CenterToShow IS "Reopen">
		<cfset IncludedFile="/deductions/closure/reopen.cfm?Deduction_ID=#Deduction_ID#">
	<cfelseif CenterToShow IS "Optionfor_email">
		<cfset IncludedFile="/deductions/Communications/Email_Fax_Print/DD_Attach_Option.cfm?Deduction_ID=#Deduction_ID#&from=Email">
	<cfelseif CenterToShow IS "Optionfor_Fax">
		<cfset IncludedFile="/deductions/Communications/Email_Fax_Print/DD_Attach_Option.cfm?Deduction_ID=#Deduction_ID#&from=Fax">
	<cfelseif CenterToShow IS "Optionfor_Print">
		<cfset IncludedFile="/deductions/Communications/Email_Fax_Print/DD_Attach_Option.cfm?Deduction_ID=#Deduction_ID#&from=Print">
	<cfelseif CenterToShow IS "Attachments">
		<cfset IncludedFile="/deductions/Attachments/Attach_Doc.cfm?Deduction_ID=#Deduction_ID#">
	<cfelseif CenterToShow IS "ERPDocuments">
		<cfset IncludedFile="/deductions/Attachments/ERPDocuments.cfm?Deduction_ID=#Deduction_ID#">
	<cfelseif CenterToShow IS "EmailLog">
		<cfset IncludedFile="/deductions/Communications/Email_Fax_Print/Email_Fax_Log.cfm?Deduction_ID=#Deduction_ID#&Type=Email">
	<cfelseif CenterToShow IS "FaxLog">
		<cfset IncludedFile="/deductions/Communications/Email_Fax_Print/Email_Fax_Log.cfm?Deduction_ID=#Deduction_ID#&Type=Fax">
	<cfelseif CenterToShow IS "Delete">
		<cfset IncludedFile="/deductions/closure/delete.cfm?Deduction_ID=#Deduction_ID#">
	<cfelseif CenterToShow IS "UnDelete">
		<cfset IncludedFile="/deductions/closure/undelete.cfm?Deduction_ID=#Deduction_ID#">
	<cfelseif CenterToShow IS "Reject">
		<cfset IncludedFile="/deductions/closure/Reject_This_DD.cfm?Deduction_ID=#Deduction_ID#">
	<cfelseif CenterToShow IS "Rebill">
		<cfset IncludedFile="/deductions/Rebill/DD_Open_To_Rebill.cfm?Deduction_ID=#Deduction_ID#">
	<cfelseif CenterToShow IS "RebillInt">
		<cfset IncludedFile="/deductions/Rebill/rebill_integration.cfm?Deduction_ID=#Deduction_ID#">
	<cfelseif CenterToShow IS "BackToOpen">
		<cfset IncludedFile="/deductions/Rebill/DD_Rebill_To_Open.cfm?Deduction_ID=#Deduction_ID#">
	<cfelseif CenterToShow IS "Classification">
		<cfset IncludedFile="/deductions/Classification.cfm?Deduction_ID=#Deduction_ID#">
	<cfelseif CenterToShow IS "DeductionType">   <!--26487-->
		<cfset IncludedFile="/deductions/DeductionType.cfm?Deduction_ID=#Deduction_ID#">
	<cfelseif CenterToShow IS "LinkDeduction">
		<cfset IncludedFile="/deductions/Credits/LinkDeduction.cfm?Deduction_ID=#Deduction_ID#&FromCredit=1">
	<cfelseif CenterToShow IS "LinkCredit">
		<cfset IncludedFile="/deductions/Credits/LinkDeduction.cfm?Deduction_ID=#Deduction_ID#&FromDeduction=1">
	<cfelseif CenterToShow IS "CustRefNo">
		<cfset IncludedFile="/deductions/Customer_RefNo.cfm?Deduction_ID=#Deduction_ID#">
	<cfelseif CenterToShow IS "RebillLetter">
		<cfset IncludedFile="/deductions/Rebill/letter_home.cfm?Deduction_ID=#Deduction_ID#">
	<cfelseif CenterToShow IS "WriteOff">
		<cfset IncludedFile="/deductions/Closure/DD_Write_Off.cfm?Deduction_ID=#Deduction_ID#">
	<cfelseif CenterToShow IS "WFToOpen">
		<cfset IncludedFile="/deductions/Closure/DD_Write_Off_To_Open.cfm?Deduction_ID=#Deduction_ID#&WFToOpen=1">
	<cfelseif CenterToShow IS "NoAccessReassignMessage" AND IsDefined("DisplayNoReassignAccess")>
		<cfset IncludedFile= "/deductions/NoReassignAccessMessage.cfm?Deduction_ID=#Deduction_ID#">
	<cfelseif CenterToShow IS "Disagree">
		<cfset IncludedFile ="/deductions/Closure/BackToOpen.cfm?Deduction_ID=#Deduction_ID#">
	<cfelseif CenterToShow IS "ClearRebill">
		<cfset IncludedFile ="/deductions/rebill/Clear_Rebill.cfm?Deduction_ID=#Deduction_ID#">
	<!--- D29481:Non trade deductions START--->
	<cfelseif CenterToShow IS "NonTrade">
		<cfset IncludedFile = "/deductions/closure/index.cfm?Deduction_ID=#form.Deduction_ID#&PopupReasonCode=1&reasoncode=#form.reasoncode#&Closure_Type=#form.closure_Type#">
	<cfelseif CenterToShow IS "NonTradeToOpen">
		<cfset IncludedFile = "/deductions/closure/DD_Non_Trade_To_Open.cfm?from=detail&Deduction_ID=#Deduction_ID#&Profile_ID=#Get_Profile_Settings.Profiles_ID#">
	<!--- D29481:Non trade deductions END--->
	<cfelseif CenterToShow IS "ReassignHistory">
		<cfset IncludedFile ="/deductions/DD_Reassign_History.cfm?Deduction_ID=#Deduction_ID#">
	<cfelse>
		<cfset IncludedFile="/deductions/inc_deduction_details.cfm?Deduction_ID=#Deduction_ID#&showScissor=#LockStatus#">
	</cfif>
	<div style="padding:0px; position: absolute; z-index: 1; left: 210; top: 50px;" id="deduct_details">
		<IFRAME name="I2" width="100%" src="#IncludedFile#" height="100%" border="0" frameborder="0" align="center"></IFRAME>
	</div>
<!---Right--->
	<div style="border:1px solid ##C0C0C0; padding:10px; position: absolute; width: 205px; z-index: 1; top: 60px; background-color:##FFFFEA" id="deduct_dashboard_right">
	<div align="center">
	<TABLE border="0" cellpadding="0" style="border-collapse: collapse" width="100%" id="table3" cellspacing="5">
		<tr>
			<td COLSPAN="2">
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
				<tr>
					<TD>
						<B>
								<FONT COLOR="Red" SIZE="2">[ </FONT>
								<A Href="/deductions/search_screens/Ded_Advanced_Search.cfm">Search</A>
								<FONT COLOR="Red" SIZE="2"> ]</FONT>
						</B>&nbsp;&nbsp;
					</td>
					<TD>
						<B>
								<FONT COLOR="Red" SIZE="2">[ </FONT>
								<A Href="/deductions/scorecard/index.cfm?SC_Shr_Ship_To=&SC_Broker_Shard=&Show_Status=1&Program_Agree_Status_ID=">Scorecard</A>
								<FONT COLOR="Red" SIZE="2"> ]</FONT>
						</B>
					</td>
				</tr>
				</table>
			</td>
		</tr>
	<cfif appSettings.getDD_User_Reference() EQ 1>
	<form name="UserReference" method="post" action="/deductions/deduction.cfm">
		<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">
		<input type="hidden" name="UserReferenceSave" value="0">
	<cfset  UserReferenceStatus = "DISABLED" />
	<cfif LockStatus EQ 1  AND (Deduction_Info.DD_Status NEQ 4 AND Deduction_Info.DD_Status NEQ 9)>
		<cfset  UserReferenceStatus = "" />
	</cfif>
	<tr>
		<td colspan="2"><hr noshade color="##C0C0C0" size="1"></td>
	</tr>
	<tr>
		<td colspan="2"><strong>User References:</strong>
	</tr>
<cfoutput>
	<tr>
		<td colspan="2">
			#stDeductionLabels["User Ref 1"]#<BR/>
			<input type="text" name="DD_User_Reference1" maxlength="50" size="29" value="#Deduction_Info.DD_User_Reference1#"  #UserReferenceStatus# >
	</td>
	</tr>
	<tr>
		<td colspan="2">
				#stDeductionLabels["User Ref 2"]#<BR/>
				<input type="text" name="DD_User_Reference2" maxlength="50" size="29" value="#Deduction_Info.DD_User_Reference2#"  #UserReferenceStatus#>
		</td>
	</tr>
	<cfif LockStatus EQ 1  AND (Deduction_Info.DD_Status NEQ 4 AND Deduction_Info.DD_Status NEQ 9)>
	<tr>
		<td COLSPAN="2" ALIGN="left">
				<CF_button
					button_name		=	""
					button_caption	=	"save"
					button_action	=	"return SaveUserReference();"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
		</td>
	</tr>
	</cfif>
</cfoutput>
	</form>
	</cfif>
	<tr>
		<td colspan="2"><hr noshade color="##C0C0C0" size="1"></td>
	</tr>
	<tr>
		<td><img src="/images/reminder2.gif"></td>
		<td valign="center">
			<strong>Reminders:</strong>
			<cfif ReOpenLogic_ShowLinks EQ 1
					AND Deduction_Info.DD_Status LT 4
					OR Deduction_Info.DD_Status EQ 7
					OR Deduction_Info.DD_Status EQ 8
					AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 0>
				<cfif LockStatus EQ 1>
					(<a href="javascript: void(0);" onclick="NewWindow('/deductions/reminders/create_reminder.cfm?Deduction_ID=#Deduction_ID#', 'reminder', 450, 400, 'yes', 'yes')">Add</A>)
				</cfif>
			</cfif>
			<cfif GetReminders.RecordCount GT 1>
			<BR/>
				(
					<cfif URL.ShowAll EQ 0>
						<A Href="/deductions/Deduction.cfm?CenterToShow=Details&Deduction_ID=#Deduction_ID#&ShowAll=1">list all</A>
					<cfelse>
						<A Href="/deductions/Deduction.cfm?CenterToShow=Details&Deduction_ID=#Deduction_ID#&ShowAll=0">list active</A>
					</cfif>
				)
			</cfif>
		</td>
	</tr>
</cfoutput>
	<tr>
		<td colspan="2">
	<cfoutput query="GetReminders">
		<cfif Reminder_Date NEQ GetReminders.DD_Reminder_Date>
			<cfset Reminder_Date = GetReminders.DD_Reminder_Date >
			<strong>#DateFormat(GetReminders.DD_Reminder_Date, 'MM/DD/YYYY')#</strong><cfif GetReminders.DD_Reminder_Status IS 1>(Closed)</cfif><BR/>
		</cfif>
		<cfif LockStatus EQ 1>
			<a onclick="NewWindow('/deductions/reminders/reminder_details.cfm?DD_Reminder_ID=#GetReminders.DD_Reminder_ID#&Deduction_ID=#Deduction_ID#', 'reminder', 450, 400, 'yes', 'yes')" href="javascript: void(0);"><cfif len(trim(GetReminders.DD_Reminder)) GT 25>#left(GetReminders.DD_Reminder, 23)#...<cfelse>#GetReminders.DD_Reminder#</cfif></a>
		<cfelse>
			<cfif len(trim(GetReminders.DD_Reminder)) GT 25>#left(GetReminders.DD_Reminder, 23)#...<cfelse>#GetReminders.DD_Reminder#</cfif>
		</cfif>
		<BR/>
	</cfoutput>
		</td>
	</tr>
<!---Spacer--->
	<tr>
		<td colspan="2"><hr noshade color="#C0C0C0" size="1"></td>
	</tr>
	<cfoutput>
	<tr>
		<td><img src="/images/notes.gif"></td>
		<td valign="center">
		<strong>Notes:</strong>
		<cfif ReOpenLogic_ShowLinks EQ 1>
				<cfif LockStatus EQ 1>
						(<a href="javascript: void(0);" onclick="NewWindow('/deductions/notes/create_note.cfm?Deduction_ID=#Deduction_ID#', 'reminder', 450, 400, 'yes', 'yes')">Add</A>)
				</cfif>
				&nbsp;
				<cfif GetNotes.recordcount GT 0>
					<FONT COLOR="##FF0000">[</FONT>
							<a href="javascript: void(0);" onclick="NewWindow('/deductions/notes/view_all_notes.cfm?Deduction_ID=#Deduction_ID#', 'reminder', 800,500, 'yes', 'yes')">View All</A>
					<FONT COLOR="##FF0000">]</FONT>
				</cfif>
			</cfif>
		</td>
	</tr>
	</cfoutput>
	<tr>
		<td colspan="2" valign="top">
 		<cfoutput query="GetNotes" >
 			<cfif Notes_Date NEQ GetNotes.DD_Note_Date >
				<cfset Notes_Date = GetNotes.DD_Note_Date />
				<strong>#DateFormat(GetNotes.DD_Note_Date, 'MM/DD/YYYY')#</strong><BR/>
			</cfif>
			<cfif LockStatus EQ 1>
			<a href="javascript: void(0);" onclick="NewWindow('/deductions/notes/note_details.cfm?&DD_Note_ID=#GetNotes.DD_Note_ID#&Deduction_ID=#Deduction_ID#', 'reminder', 450, 400, 'yes', 'yes')">
				<cfif len(trim(GetNotes.DD_Note)) GT 25>
					#left(GetNotes.DD_Note, 23)#...
				<cfelse>
					#GetNotes.DD_Note#
				</cfif>
			</a>
			<cfelse>
				<cfif len(trim(GetNotes.DD_Note)) GT 25>
					#left(GetNotes.DD_Note, 23)#...
				<cfelse>
					#GetNotes.DD_Note#
				</cfif>
			</cfif><BR/>
		</cfoutput>
		</td>
	</tr>
	<cfoutput>
	<!---Spacer--->
	<tr>
		<td colspan="2"><hr noshade color="##C0C0C0" size="1"></td>
	</tr>
	<!---Get Communications Query--->
	<cfquery name="GetCalls" datasource="#application.datasource#">
		SELECT DD_Call_Log_ID, Deduction_ID, Person_Who_Called, Person_Called,
					CONVERT(DATETIME, CONVERT(char(10), Call_Date, 101)) AS Call_Date
		FROM 	DD_Call_Log
		WHERE 	Deduction_ID = <cfqueryparam value="#Deduction_ID#" cfsqltype="cf_sql_idstamp">
		AND 	Deleted = 0
		ORDER BY Call_Date desc, Person_Called
	</cfquery>
	<!---Communications--->
	<tr>
		<td><img src="/images/phone.gif" alt="" width="40" height="42" border="0"></td>
		<td valign="center">
		<strong>Call Log:</strong>
		<cfif ReOpenLogic_ShowLinks EQ 1
				AND Deduction_Info.DD_Status LT 4
				OR Deduction_Info.DD_Status EQ 7
				OR Deduction_Info.DD_Status EQ 8>
		<cfif LockStatus EQ 1>
			(<a href="javascript: void(0);" onclick="NewWindow('/deductions/communications/call_log.cfm?Deduction_ID=#Deduction_ID#', 'CallLog', 450, 400, 'yes', 'yes')">Add</A>)
		</cfif>
		</cfif>
		</td>
	</tr>
	<tr>
		<td colspan="2" valign="top">
		<cfif lockstatus eq 1>
			<cfloop query="GetCalls">
				<li><a href="javascript: void(0);" onclick="NewWindow('/deductions/communications/call_log_detail.cfm?&DD_Call_Log_ID=#GetCalls.DD_Call_Log_ID#&Deduction_ID=#Deduction_ID#', 'reminder', 450, 400, 'yes', 'yes')"><cfif len(Person_Called) LT 30>#Person_Called#<cfelse>#left(Person_Called, 27)#...</cfif> - #DateFormat(Call_Date, 'MM/DD/YY')#</li>
			</cfloop>
		<cfelse>
			<cfloop query="GetCalls">
				<li><cfif len(Person_Called) LT 30>#Person_Called#<cfelse>#left(Person_Called, 27)#...</cfif> - #DateFormat(Call_Date, 'MM/DD/YY')#</li>
			</cfloop>
		</cfif>
		</td>
	</tr>
	<cfquery name="CheckforSiblings" datasource="#application.datasource#">
		SELECT Deductions.Deduction_ID, Deductions.DD_DedID, Deductions.SP_Number, DD_Status.DD_Status_Description,
					 Deductions.SP_Reason, Deductions.DD_IsParent, Deductions.DD_Amount,DD_DedID_SP_Number
		FROM Deductions
		INNER JOIN DD_Status
		ON DD_Status.Deleted = 0
		AND DD_Status.DD_Status_ID = Deductions.DD_Status
		WHERE Deductions.Deleted = 0
		AND Deductions.DD_DedID = <cfqueryparam value="#Deduction_Info.DD_DedID#" cfsqltype="cf_sql_varchar">
		ORDER BY Deductions.DD_IsParent DESC, Deductions.SP_Number
	</cfquery>
	<!---There will always be at least one--->
	<cfif CheckforSiblings.Recordcount GT 1>
		<tr>
			<td colspan="2">
			<hr noshade color="##C0C0C0" size="1">
			<cfset counter = 0>
			<table style="maintable">
				<cfloop query="CheckforSiblings">
				<tr>
					<td>
					<cfif CheckforSiblings.Deduction_ID IS NOT Deduction_Info.Deduction_ID>
						<a href="/deductions/deduction.cfm?Deduction_ID=#CheckforSiblings.Deduction_ID#">
					</cfif>
					<cfif CheckforSiblings.DD_IsParent IS 0>
						#CheckforSiblings.DD_DedID_SP_Number# #CheckforSiblings.SP_Reason#
					<cfelse>
						#CheckforSiblings.DD_DedID#
					</cfif>
					<cfif CheckforSiblings.Deduction_ID IS NOT Deduction_Info.Deduction_ID>
						</a>
					</cfif><BR/>
						Status: #CheckforSiblings.DD_Status_Description#<BR/>
						Amount: #lscurrencyformat(CheckforSiblings.DD_Amount)#
					</td>
				</tr>
				</cfloop>
			</table>
			</td>
	</tr>
<!---Show sibling links--->
	</cfif>
	<tr>
		<td align="right" style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0" valign="top">&nbsp;</td>
		<td style="width:100%;border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0" valign="top">&nbsp;</td>
	</tr>
	</table>
	</div>
	</div>
	<form name="Refresh" method="post" action="/deductions/deduction.cfm">
		<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">
	</form>
	<script>
	/* Earlier this was being used in a CSS Expression. CSS expressions are not a part of IE 10 and so this is now being
	called onLoad and onResize.
	*/
		function moveDiv() {
						document.getElementById('deduct_details').style.width = document.body.clientWidth-430;
						document.getElementById('deduct_details').style.height = document.body.clientHeight-65;
						document.getElementById('deduct_dashboard_right').style.left = document.body.clientWidth-213;
						document.getElementById('deduct_dashboard_right').style.height = document.body.clientHeight-100;
						document.getElementById('deduct_dashboard').style.height = document.body.clientHeight-100;
						document.getElementsByName('I2')[0].style.height = document.body.clientHeight-55;
		}
		moveDiv();
	</script>
	<form name="AddProgram" method="post" action="/deductions/deduction.cfm">
		<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">
		<input type="hidden" name="Program_ID" value="">
		<input type="hidden" name="runsearchonfirstload" value=1>
		<input type="hidden" name="FilterType" value="1">
		<input type="hidden" name="FilterDataList" value="#Deduction_Info.Distributor_ID#">
		<input type="hidden" name="FilterSearchPrograms" value=0>
		<input type="hidden" name="Distributor_List" value="#Deduction_Info.Distributor_ID#">
		<input type="hidden" name="FormType" value="AddProgram">
	</form>
	<form name="AddDistributor" method="Post" actions="/deductions/deduction.cfm">
		<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">
		<input type="hidden" name="Distributor_List" value="">
		<input type="hidden" name="FormType" value="AddDistributor">
	</form>
	<form name="AddBroker" method="Post" actions="/deductions/deduction.cfm">
		<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">
		<input type="hidden" name="Broker_List" value="#FORM.Broker_List#">
		<input type="hidden" name="CurrentBroker" value="#Deduction_Info.Broker_ID#">
		<input type="hidden" name="FormType" value="AddBroker">
	</form>
</BODY>
</HTML>
<script>
function LockUnLock()	{
	document.LockDeduction.submit();
}
function fnShowComments(){
		ChangeStage.submit();
}
function SaveUserReference (){
	var errorMessage = '';
		if(#len(Deduction_Info.DD_User_Reference1)# > 0 && document.all.UserReference.DD_User_Reference1.value==''){
			errorMessage = errorMessage.concat('<cfoutput>#stDeductionLabels["User Ref 1"]#</cfoutput> cannot be empty.\n');
		}
		if(#len(Deduction_Info.DD_User_Reference2)# > 0 && document.all.UserReference.DD_User_Reference2.value==''){
			errorMessage = errorMessage.concat('<cfoutput>#stDeductionLabels["User Ref 2"]#</cfoutput> cannot be empty.\n');
		}
		if(errorMessage.length){
			alert(errorMessage);
			return false;
		}
		else{
		document.all.UserReference.UserReferenceSave.value = 1;
		document.all.UserReference.submit();
		}
}
</script>
</cfoutput>
	<cfif url.emailFax>
		<CF_displayLayer
			layername="divEmailFax"
			width="400"
			bgColor="FFEFD5"
			scroll="1"
		>
	<table width="100%" cellpadding="3" cellspacing="0" border="0" background="Images/yellow.gif">
		<tr>
			<td align="right" colspan="100%">
				<a href="void(0);" onclick="javaScript: return closeDivWindow();"><img src="/Images/close_1.gif" border="0" width="16" height="14"></a>
			</td>
		</tr>
		<tr>
			<td colspan="100%">&nbsp;&nbsp;&nbsp;&nbsp;	<B>Please select your next action.</B><BR/><BR/><BR/></td>
		</tr>
		<tr>
			<td align="center">
				<CF_button
					button_name		=	""
					button_caption	=	"print"
					button_action	=	"window.location.href='/deductions/deduction.cfm?CenterToShow=Optionfor_Print&Deduction_ID=#Deduction_ID#'"
					button_type		=	"javascript_link"
					button_width	=	"50"
					button_color	=	"Navy"
					button_tip		=	"Prepare an email contents"
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</td>
			<td align="center">
				<CF_button
					button_name		=	""
					button_caption	=	"email"
					button_action	=	"window.location.href='/deductions/deduction.cfm?CenterToShow=Optionfor_Email&Deduction_ID=#Deduction_ID#'"
					button_type		=	"javascript_link"
					button_width	=	"50"
					button_color	=	"Navy"
					button_tip		=	"Prepare an email contents"
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</td>
		</tr>
		<tr>
			<td align="center" colspan="100%">
			<BR/><BR/>
				<cf_smallLink
					title="close"
					url="/deductions/index.cfm"       <!--- 55622 - redirect to deduction search page --->
					>
			</td>
		</tr>
	</table>
	</CF_displayLayer>
</cfif>