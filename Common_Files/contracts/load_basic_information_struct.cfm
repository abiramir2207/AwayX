<!---
Name: 			load_basic_information_struct.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:	04/08/2010
Created By:		Deepa Kunnath (D22578: CAG - mass copy a program) 
Description:	This file will load the necesary data into the program packet to be used in program basic info page
Output:			Program_Packet  
--->
	<!--- Basic Information - Contract_Main --->

	<CFQUERY NAME="getContractInfo" datasource="#application.datasource#">
		SELECT     *, dbo.Contract_Main_Aux_Data.Comments, dbo.Contract_Main_Aux_Data.Forecast_ID
		FROM         dbo.Contract_Main INNER JOIN
		                      dbo.Contract_Main_Aux_Data ON dbo.Contract_Main.Contract_Main_ID = dbo.Contract_Main_Aux_Data.Contract_Main_ID
		WHERE dbo.Contract_Main.Contract_Main_ID = '#Program_ID_To_Replicate#'
	</CFQUERY>

	<cfset this.ProgramType_ID = getContractInfo.ProgramType_ID />

	<cfset useLakebaseForgettemplateparent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForgettemplateparent>
	<cftry>
		<cfset gettemplateparent = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#this.ProgramType_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgettemplateparent = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgettemplateparent>
<cfquery name="gettemplateparent" datasource="#application.datasource#">
		SELECT *
		FROM Program_Control_Panel_Options
		WHERE ProgramControl_Panel_Options_ID = '#this.ProgramType_ID#'
	</cfquery>
</cfif>

	<cfif gettemplateparent.isdominant EQ 1>
		<cfset getContractTemplateDetails = gettemplateparent />
	<cfelse>
		<cfset useLakebaseForgetContractTemplateDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForgetContractTemplateDetails>
	<cftry>
		<cfset getContractTemplateDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"first_parent_id" = "eq.#gettemplateparent.first_parent_id#",
				"isdominant" = "eq.1",
				"deleted" = "eq.0",
				"order" = "programcontrol_panel_options_id.desc",
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetContractTemplateDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetContractTemplateDetails>
<cfquery name="getContractTemplateDetails" datasource="#application.datasource#">
			SELECT top 1 * 
			FROM Program_Control_Panel_Options
			WHERE first_parent_id = #gettemplateparent.first_parent_id#
			and isdominant = 1
			and deleted = 0
			ORDER BY ProgramControl_Panel_Options_ID desc
		</cfquery>
</cfif>
		<cfif getContractTemplateDetails.recordcount EQ 0>
			<cfset getContractTemplateDetails = gettemplateparent />
		</cfif>
	</cfif>
	<cfset this.ProgramType_ID = getContractTemplateDetails.ProgramControl_Panel_Options_ID />
	

<!--- End suppress distributors & products --->
			

		<!------ Operating Group ----->
		<cfset operatingGroupProgramLevel1 = "0" />
		<cfset operatingGroupProgramLevel2 = "0" />
			
		<cfif appSettings.getOperatingGroupOn()>
			<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
			
			<cfset programLevel1Level 				= operatingGroupManager.getProgramLevel1Level() />		
			<cfset programLevel2Level 				= operatingGroupManager.getProgramLevel2Level() />
			
			<cfset operatingGroupProgramLevel1 = operatingGroupManager.getProgramOperatingGroupID(level=programLevel1Level, programId=Program_ID_To_Replicate) />
			<cfset operatingGroupProgramLevel2 = operatingGroupManager.getProgramOperatingGroupID(level=programLevel2Level, programId=Program_ID_To_Replicate) />
			
		</cfif>

	
	<!--- BuildStruct --->
		<CFSET Program_Packet = StructNew()>
		<!--- Contract_Main --->
		<CFSET Program_Packet.Basic_Information = StructNew()>
		<CFOUTPUT QUERY="getContractInfo">
			<CFLOOP INDEX="Contract_Main_Column_List" LIST="#getContractInfo.ColumnList#">
				<CFSET ThisRowAndColumnData = evaluate("getContractInfo.#Contract_Main_Column_List#")>
				<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
					<CFSET ThisRowAndColumnData = "NULL">
				</CFIF>
				<CFSET "Program_Packet.Basic_Information.#Contract_Main_Column_List#" = ThisRowAndColumnData>
			</CFLOOP>
		</CFOUTPUT>
		<CFSET Program_Packet.Basic_Information.Operating_Group_Level_1_ID = operatingGroupProgramLevel1>
		<CFSET Program_Packet.Basic_Information.Operating_Group_Level_2_ID = operatingGroupProgramLevel2>
		<CFSET Program_Packet.Basic_Information.TemplateFiltersId = Form.TemplateFiltersId />
		
		<!---Comment: TF - include this if not coming from trade plan--->
		<cfif not isDefined("form.bIsFromTradePlan")>
		
			<CFIF ucase(Program_Packet.Basic_Information.Adv_Spending_Amount) EQ "NULL">
				<CFSET Program_Packet.Basic_Information.Adv_Spending_Amount = 0>
			</CFIF> 
	
			<CFIF ucase(Program_Packet.Basic_Information.ProgramType) EQ "NULL">
				<CFSET Program_Packet.Basic_Information.ProgramType = "">
			</CFIF>
			
			<CFIF ucase(Program_Packet.Basic_Information.Contract_Reference_Number) EQ "NULL">
				<CFSET Program_Packet.Basic_Information.Contract_Reference_Number = "">
			</CFIF>
			
		</cfif>
		<cfif getContractTemplateDetails.Adv_Spend EQ 0>
			<cfset Program_Packet.Basic_Information.Adv_Spending_Amount = 0>
		</cfif>
		<cfif getContractTemplateDetails.Payable_To EQ 0>
		<cfset Program_Packet.Basic_Information.Pay_To_Distributor = "">
		<cfset Program_Packet.Basic_Information.Payable_Company = "">
		<cfset Program_Packet.Basic_Information.Payable_Attention = "">
		<cfset Program_Packet.Basic_Information.Payable_Address_1 = "">
		<cfset Program_Packet.Basic_Information.Payable_Address_2 = "">
		<cfset Program_Packet.Basic_Information.Payable_City = "">
		<cfset Program_Packet.Basic_Information.Payable_State = "">
		<cfset Program_Packet.Basic_Information.Payable_Zip = "">
		<cfset Program_Packet.Basic_Information.Payable_Comments = "">
		</cfif>
		
		<cfif getContractTemplateDetails.Send_Payment_To EQ 0>
		<cfset Program_Packet.Basic_Information.Send_To_Broker = "">
		<cfset Program_Packet.Basic_Information.Send_Company = "">
		<cfset Program_Packet.Basic_Information.Send_Attention = "">
		<cfset Program_Packet.Basic_Information.Send_Address_1 = "">
		<cfset Program_Packet.Basic_Information.Send_Address_2 = "">
		<cfset Program_Packet.Basic_Information.Send_City = "">
		<cfset Program_Packet.Basic_Information.Send_State = "">
		<cfset Program_Packet.Basic_Information.Send_Zip = "">
		</cfif>
		
		<cfif getContractTemplateDetails.Auto_Renew_Option EQ 0>
		<cfset Program_Packet.Basic_Information.Auto_Renew = 0>
		<cfset Program_Packet.Auto_Renew.AR_Notification_Date = "">
		<cfset Program_Packet.Auto_Renew.AR_Start_Date = "">
		<cfset Program_Packet.Auto_Renew.AR_End_Date = "">
		<cfset Program_Packet.Auto_Renew.Renewal_Lead_Time = "">
		<cfset Program_Packet.Auto_Renew.AR_Renewal_Type = "">
		</cfif>
		
		<cfif getContractTemplateDetails.Controllable_Volume EQ 0>
			<cfset Program_Packet.Basic_Information.Controllable_Volume = 0>
		</cfif>
		
		<cfif getContractTemplateDetails.Growth_Inclusion EQ 0>
			<cfset Program_Packet.Basic_Information.Growth_Inclusion = 0>
		</cfif>
		<cfif getContractTemplateDetails.Equipment_Placement EQ 0>
			<cfset Program_Packet.Basic_Information.Equipment_Placement = 0>
		</cfif>
		<cfset Program_Packet.Basic_Information.ProgramType_ID = this.ProgramType_ID>
		
		<!--- format the columns to a non-odbc timestamp --->		
		<!---Comment: TF - Include this if not coming from trade plan--->
		<!--- Basic Information --->
		<cfif not isDefined("form.bIsFromTradePlan")>
			<!------<cfif isdate(Program_Packet.BASIC_INFORMATION.APPROVAL_DATE)><CFSET Program_Packet.BASIC_INFORMATION.APPROVAL_DATE 			= DateFormat(Program_Packet.BASIC_INFORMATION.APPROVAL_DATE,'m/d/yyyy')></cfif> ----->
			<cfif isdate(Program_Packet.BASIC_INFORMATION.BROKER_APPROVED_DATE)><CFSET Program_Packet.BASIC_INFORMATION.BROKER_APPROVED_DATE 	= DateFormat(Program_Packet.BASIC_INFORMATION.BROKER_APPROVED_DATE,'m/d/yyyy')></cfif>
			<cfif isdate(Program_Packet.BASIC_INFORMATION.CONTRACT_CREATED_DATE)><CFSET Program_Packet.BASIC_INFORMATION.CONTRACT_CREATED_DATE 	= DateFormat(Program_Packet.BASIC_INFORMATION.CONTRACT_CREATED_DATE,'m/d/yyyy')></cfif>
			<cfif isdate(Program_Packet.BASIC_INFORMATION.CONTRACT_END_DATE)><CFSET Program_Packet.BASIC_INFORMATION.CONTRACT_END_DATE 		= DateFormat(Program_Packet.BASIC_INFORMATION.CONTRACT_END_DATE,'m/d/yyyy')></cfif>
			<cfif isdate(Program_Packet.BASIC_INFORMATION.CONTRACT_LOCK_DATE)><CFSET Program_Packet.BASIC_INFORMATION.CONTRACT_LOCK_DATE = DateFormat(Program_Packet.BASIC_INFORMATION.CONTRACT_LOCK_DATE,'m/d/yyyy')></cfif>
			<cfif isdate(Program_Packet.BASIC_INFORMATION.CONTRACT_START_DATE)><CFSET Program_Packet.BASIC_INFORMATION.CONTRACT_START_DATE 	= DateFormat(Program_Packet.BASIC_INFORMATION.CONTRACT_START_DATE,'m/d/yyyy')></cfif>
		</cfif>
		