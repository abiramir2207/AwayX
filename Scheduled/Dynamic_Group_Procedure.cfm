<cfset useLakebaseForEnterLog = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dynamic_group_log")>
<cfif useLakebaseForEnterLog>
	<cftry>
		<cfset application.oLakebase.insertRow("dynamic_group_log", {
			"start_date_time" = "#now()#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForEnterLog = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForEnterLog>
<CFQUERY NAME="EnterLog" DATASOURCE="#Application.Datasource#">
	INSERT INTO Dynamic_Group_Log (Start_Date_Time) VALUES (getdate())
</CFQUERY>
</cfif>

<CFQUERY NAME="UpdatedBitInfo" DATASOURCE="#Application.Datasource#">
	EXEC Program_Revision__Dynamic_Group_Change
</CFQUERY>

<cfquery name="Call_Capture" datasource="#application.datasource#">
	SELECT DISTINCT DGPP.Contract_main_ID Program_ID,DGPP.Dynamic_Group_Type 
	FROM 	Dynamic_Group_Processed_Program DGPP
	INNER JOIN Contract_Main 
	ON		Contract_Main.Contract_Main_ID = DGPP.Contract_main_ID
	WHERE 	DGPP.Contract_Updated_Type = 1 AND DGPP.Is_Processed = 0 AND DGPP.Deleted = 0
</cfquery>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Update Contract_products/Contract_Distributor --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFLOOP QUERY="Call_Capture">
	<CFIF Dynamic_Group_Type EQ 1>
		<CFQUERY NAME="ProductCapture" DATASOURCE="#Application.Datasource#">
			EXEC SP_CAPTURE_ALL_FOR_GROUPS #Program_ID#
		</CFQUERY>
	<CFELSEIF Dynamic_Group_Type EQ 2>
		<CFSET Program_ID_Var = Program_ID>
		<cfset useLakebaseForGetParam = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_distributors")>
<cfif useLakebaseForGetParam>
	<cftry>
		<cfset GetParam = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_distributors", {
				"contract_main_id" = "eq.#Program_ID_Var#",
				"is_group" = "eq.1",
				"dynamic_static_groups" = "eq.1",
				"deleted" = "eq.0",
				"select" = "contract_main_id,program_weight,distributor_group_level_id,distributor_group_id"
			}), "contract_main_id,program_weight,distributor_group_level_id,distributor_group_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetParam = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetParam>
<CFQUERY NAME="GetParam" DATASOURCE="#Application.Datasource#">
			SELECT DISTINCT Contract_Main_ID,Program_Weight,Distributor_Group_Level_ID,Distributor_Group_ID 
			FROM Contract_Distributors WHERE Contract_main_ID = #Program_ID_Var# AND Is_Group = 1 AND Dynamic_Static_Groups = 1 AND Deleted = 0 
		</CFQUERY>
</cfif>
		<CFLOOP QUERY = "GetParam">
			<CFQUERY NAME="CustomerCapture" DATASOURCE="#Application.Datasource#">
				EXEC CAPTURE_CUSTOMER_GROUPS #GetParam.Contract_Main_ID#,#GetParam.Program_Weight#,'#GetParam.Distributor_Group_Level_ID#','#GetParam.Distributor_Group_ID#',1		
			</CFQUERY>
		</CFLOOP>		
	</CFIF>
</CFLOOP>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Revision --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfquery name="Needs_Revision" datasource="#application.datasource#">
	SELECT 	DISTINCT DGPP.Contract_main_ID Program_ID,
			CAST(CAST(Year(DGPP.Effective_Date) AS NVARCHAR(4)) + '/' + CAST(Month(DGPP.Effective_Date) AS NVARCHAR(20)) + '/' + CAST(Day(DGPP.Effective_Date) AS NVARCHAR(2)) As Datetime) New_Pgm_Start_Date
	FROM 	Dynamic_Group_Processed_Program DGPP
	INNER JOIN Contract_Main 
	ON		Contract_Main.Contract_Main_ID = DGPP.Contract_main_ID
	WHERE 	DGPP.Contract_Updated_Type = 2 AND DGPP.Is_Processed = 0 AND DGPP.Deleted = 0
	Order by DGPP.Contract_main_ID, New_Pgm_Start_Date
</cfquery>

<cfset Scheduled = 1>

<cfset NumberUpdated = 0>
<!------ <cfdump var="#Needs_Renewal#"> ----->
<cfset programObj = CreateObject("component", "components.programs.program") />

<cfloop query="Needs_Revision"><!--- start date- --->
	<CFINCLUDE TEMPLATE ="Auto_Revise_Program.cfm">
	<CFOUTPUT>#Renewed_Program_ID#</CFOUTPUT>
	<CFQUERY NAME="" DATASOURCE="#Application.Datasource#">
		UPDATE Contract_main SET Dynamic_Group_Revision = 1 WHERE Contract_main_ID = #Renewed_Program_ID#
	</CFQUERY>
	<!--- <CFINCLUDE TEMPLATE = "Auto_Program_Approval.cfm"> --->
	<CFSET program_id = Renewed_Program_ID>
	<CFINCLUDE TEMPLATE = "/Common_Files/Contracts/Contract_layered_approve_action_Auto.cfm">
	
	<CFQUERY NAME="SetProcessed" DATASOURCE="#Application.Datasource#">
		UPDATE Dynamic_Group_Processed_Program
		SET Is_Processed = 1
		WHERE Is_processed = 0 AND Contract_Main_ID = '#Program_ID#' AND Deleted = 0
	</CFQUERY>
</cfloop>
<cfset useLakebaseForResetUpdatedBit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("group_members")>
<cfif useLakebaseForResetUpdatedBit>
	<cftry>
		<cfset application.oLakebase.updateRows("group_members",
			{
				"updated_bit" = "eq.1",
				"deleted" = "eq.0"
			},
			{
				"updated_bit" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForResetUpdatedBit = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForResetUpdatedBit>
<CFQUERY NAME="ResetUpdatedBit" DATASOURCE="#Application.Datasource#">
	UPDATE Group_Members SET Updated_Bit = 0 WHERE Updated_Bit = 1 AND Deleted = 0
</CFQUERY>
</cfif>

<CFQUERY NAME="ResetUpdatedBit" DATASOURCE="#Application.Datasource#">
	UPDATE Customer_Group_Members SET Updated_Bit = 0 WHERE Updated_Bit = 1 AND Deleted = 0
</CFQUERY>

                                                                                     
<CFQUERY NAME="EnterLog" DATASOURCE="#Application.Datasource#">
	UPDATE Dynamic_Group_Log 
	SET	End_Date_Time = getdate()
	WHERE Dynamic_Group_Log_ID = (SELECT MAX(Dynamic_Group_Log_ID) FROM Dynamic_Group_Log WHERE Start_Date_Time IS NOT NULL AND End_Date_Time IS NULL AND Deleted = 0)
</CFQUERY>
