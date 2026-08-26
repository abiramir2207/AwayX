<!---
       Name:          Custom_Mass_Price_Change_Process_End_Date_Programs_Step1.cfm
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.       
       Created Date:  02/02/2010
       Created By:    Tim Ford
       Label:		  TBD
       Description:   This file is used to auto reivse a bunch of programs selected in the query and change their end date.
--->

<!---*** Removed the Stored Proc as we would be running the SP manually and scheduling the Mass Price to run in batches of 25. ***--->

<cfquery name="Programs_Custom_Revision" datasource="#application.datasource#">
	SELECT Top 25 CONTRACT_MAIN_ID, CONTRACT_NUMBER, Mod_Start_Date, Mod_End_Date, Responsible_User_ID 
	FROM  PriceChangeProgramList
	WHERE Killed = 0 AND Skip = 0 AND Revised = 0 and Skip_Revision = 0
	ORDER BY  CONTRACT_NUMBER, CONTRACT_MAIN_ID
</cfquery>

<!--- Setting Variables --->
<cfset Scheduled = 1>
<cfset NumberUpdated = 0> <!--- Just an indicator of number of programs renewed --->
<cfset form.IsAutoRevision = 1 />
<cfset Form.ForceFreightOnAutoCopy = 1 />
<cfset programObj = CreateObject("component", "components.programs.program") />
<!--- Dev Note: Kal;D15656  Add Legacy ID, Business Considerations, Date on Notes to Mass Price Change --->
<cfset variables.BizCon = "Program End Date was changed to - " & DateFormat(Programs_Custom_Revision.Mod_End_Date, "mm/dd/yyyy") & ". Program not sent to client through the 2000/2100."  />
<!--- /////////////////////////////////////////////////////////////////////////////////////////////////// --->

<cfloop query="Programs_Custom_Revision">


			
			<!---sets all the stuff that contract revision needs--->
			<cfset Program_ID_To_Replicate = Programs_Custom_Revision.CONTRACT_MAIN_ID />
		
			<CFSTOREDPROC PROCEDURE="USP_Copy_Program" datasource="#application.datasource#">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER "	DBVARNAME="@Program_ID_To_Replicate"		VALUE="#Program_ID_To_Replicate#">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_VARCHAR "	DBVARNAME="@New_Contract_Number"			VALUE="">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@IsRevisionOfExistingContract"	VALUE="1">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@ISROLLOVER"						VALUE="0">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@ForceFreightOnAutoCopy"			VALUE="1">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@User_Position_ID"				VALUE="0" null="true">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_VARCHAR"	DBVARNAME="@Responsible_User_ID"			VALUE="" null="true">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_VARCHAR"	DBVARNAME="@Current_User_ID"				VALUE="00000000-0000-0000-0000000000000000">
				<CFPROCPARAM TYPE="Out"	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@Contract_Main_ID"				VARIABLE="Renewed_Program_ID">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@Is_Mass_Copy"					VALUE="0">
				<CFPROCPARAM TYPE="Out"	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@Is_Group_Deal"					VARIABLE="Is_Group_Deal">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@From_EZ_Template"				VALUE="0">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@Is_AutoRenew"					VALUE="1">
			</CFSTOREDPROC>
			
			<cfset New_Pgm_Start_Date 	= Programs_Custom_Revision.Mod_Start_Date	/>	
			<cfset New_Pgm_End_Date 	= Programs_Custom_Revision.Mod_End_Date	/>
		
			<cfquery name="Getcompany" datasource="#application.datasource#">
				SELECT	Top 1 Company_Main_ID
				FROM 	Company_Main
				WHERE	Deleted = 0
			</cfquery>
		
			<cfset request.AccessStructure.Company_Main_ID = GetCompany.Company_Main_ID>
			
			<cfquery name="qGetProgram" datasource="#application.datasource#">
				SELECT 	Original_Creating_User_Position_ID, 
						Creating_User_Position_ID, 
						Creator_ID,
						Responsible_User_ID,
						Contract_Number,
						Notes,
						Contract_Start_Date,
						Contract_End_Date,
						Contract_Quantity
				FROM 	Contract_Main
				WHERE 	Contract_Main_ID = <cfqueryparam value="#Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">
			</cfquery>
				
			<cfset Original_Creating_User_Position_ID 					= qGetProgram.Original_Creating_User_Position_ID>
			<cfset User_Position_ID 									= qGetProgram.Creating_User_Position_ID>
			<cfset request.AccessStructure.Creating_User_Position_ID 	= qGetProgram.Creating_User_Position_ID>
			<cfset request.AccessStructure.User_ID 						= qGetProgram.Creator_ID>
			<CFSET FORM.Contract_Number 								= qGetProgram.Contract_Number>
			<CFSET FORM.Notes											= trim(qGetProgram.Notes)>
			
			<!--- Dev Note: KAL; Setting the values for the intermediate revision version here --->
			<CFSET FORM.start_date				= New_Pgm_Start_Date>
			<CFSET FORM.end_date				= New_Pgm_End_Date>
		
			<!--- Dev Note: KAL; D15524: Prorate the volume for the remainder of the program span --->
			<CFSET variables.previous_start_date	=	qGetProgram.Contract_Start_Date>
			<CFSET variables.previous_end_date		= 	qGetProgram.Contract_End_Date>	
			<CFSET variables.previous_span			= 	DateDiff("d", variables.previous_start_date, variables.previous_end_date) + 1>
			<CFSET variables.new_span				= 	DateDiff("d", New_Pgm_Start_Date, New_Pgm_End_Date) + 1>
			<CFSET variables.new_pgm_quantity		= 	Round((variables.new_span/variables.previous_span)*qGetProgram.Contract_Quantity) />
			<CFSET FORM.Quantity					= 	variables.new_pgm_quantity>	 
				
			<CFSET FORM.Approved_By_User_ID 		=  "00000000-0000-0000-0000000000000001"> <!--- Dev Note: KAL; D14181: Change the Approver to the Auto Price Change --->
			
			<!--- Dev Note: Kal;D15656  Add Legacy ID, Business Considerations, Date on Notes to Mass Price Change --->
			<cfset FORM.Notes = FORM.Notes & " - (End Date Changed to - " & DateFormat(Programs_Custom_Revision.Mod_End_Date, "mm/dd/yyyy") &")" />
			
			<cfquery name="qUpdateDatesAndVolume" datasource="#application.datasource#">
				UPDATE	Contract_Main
				SET		Contract_Quantity = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#trim(FORM.Quantity)#">,
						Contract_Start_Date = <cfqueryparam cfsqltype="cf_sql_date" value="#Form.Start_Date#">,
						Contract_End_Date = <cfqueryparam cfsqltype="cf_sql_date" value="#Form.End_Date#">
				WHERE 	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Renewed_Program_ID#">
			</cfquery>
			
			<cfquery name="qGetNewProgram" datasource="#application.datasource#">
				SELECT 	Contract_Number, ProgramType_ID
				FROM 	Contract_Main 
				WHERE 	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Renewed_Program_ID#">
			</cfquery>
			
			<CFOUTPUT>
				<cfset form.Scheduled 	= 1>
				<cfset NumberUpdated 	= NumberUpdated + 1>
				#NumberUpdated# - #FORM.Contract_Number# - #Renewed_Program_ID#<hr>
			</CFOUTPUT>
		
			<!--- Make RFA --->
			<cfset programObj = CreateObject("component", "components.programs.program") />
			<cfset programObj.makeRFA(renewed_program_id, qGetProgram.Responsible_User_ID) />	
			<cfset Contract_Main_ID = renewed_program_id>
		
			<!--- For Simplot/5.0 Only: Call the freight populate routine
			<cfstoredproc datasource="#application.datasource#" procedure="Populate_Program_Distributor_Freight" >
				<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#RENEWED_PROGRAM_ID#" />
				<cfprocparam type="in" cfsqltype="cf_sql_bit" value="0" />
			</cfstoredproc>
			 --->
			
			<!--- Auto Approve the program --->
			<cfset program_id = Renewed_Program_ID>
			<CFINCLUDE TEMPLATE = "/Common_Files/Contracts/Contract_layered_approve_action_Auto.cfm">
			
			<!--- Dev Note: KAL; D16959: JRS - Margin page previous version summary displaying zero's --->
			<cfstoredproc datasource="#application.datasource#" procedure="GET_PROFIT_MARGIN_LAYERED" >
				<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#RENEWED_PROGRAM_ID#" />
			</cfstoredproc>
			
		
			<!--- Dev Note: Kal;D15656  Add Legacy ID, Business Considerations, Date on Notes to Mass Price Change --->
			<CFQUERY NAME="InsertBizCon" DATASOURCE="#Application.Datasource#">
				INSERT INTO Contract_Evaluation_Notes (Contract_Number, Entered_By, Eval_Action, Notes, Created_Date, Contract_Notes_Type)
				VALUES	(	<cfqueryparam value="#FORM.CONTRACT_NUMBER#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="System" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="Pricing Update" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#variables.BizCon#" cfsqltype="cf_sql_varchar">,
							GETDATE(),
							<cfqueryparam value="2" cfsqltype="cf_sql_integer">
						)				
			</CFQUERY>
			 
			<!--- Dev Note: Kal;  Update the temp table and set 1 if revision created succesfully --->
			<CFQUERY NAME="SetProcessed" DATASOURCE="#Application.Datasource#">
				UPDATE 	PriceChangeProgramList
				SET 	Revised = 1,
						NEW_CONTRACT_MAIN_ID = <cfqueryparam value="#RENEWED_PROGRAM_ID#" cfsqltype="cf_sql_integer">,
						Mod_Start_Date = <cfqueryparam value="#New_Pgm_Start_Date#" cfsqltype="cf_sql_date">,
						Mod_End_Date =  <cfqueryparam value="#New_Pgm_End_Date#" cfsqltype="cf_sql_date">
				WHERE 	CONTRACT_NUMBER = <cfqueryparam value="#FORM.CONTRACT_NUMBER#" cfsqltype="cf_sql_varchar">
				AND 	CONTRACT_MAIN_ID = <cfqueryparam value="#Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">
			</CFQUERY>
		
			<!---initialize the BidRequestManager--->
			<cfset bidRequestManager = CreateObject("component", "components.programs.bid_request.BidRequestManager") />
		
			<!---apply status for bid request--->
			<cfset bidRequestManager.applyStatus(RENEWED_PROGRAM_ID, 2) />
		

		
</cfloop>

<!--- Dev Note: Kal;  Update the temp table with the new program's status and version --->
<CFQUERY NAME="UpdateStatus" DATASOURCE="#Application.Datasource#">
	UPDATE 	PriceChangeProgramList
	SET		New_Version = Revision_Version, 
			New_Contract_Status_ID = Contract_Status_Type_IDX,
			New_Contract_Status = Contract_Status_Type_Desc
	FROM	PriceChangeProgramList, Contract_Main, Contract_Status_Types  
	WHERE	PriceChangeProgramList.New_Contract_Main_ID = Contract_Main.Contract_Main_ID
	AND		PriceChangeProgramList.Contract_Main_ID = Contract_Main.Revision_of_Contract_Main_ID
	AND		Contract_Status_Types.Contract_Status_Type_ID = Contract_Status_Type_IDX
</CFQUERY>

