<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<cfset useLakebaseForSelYear3Back = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_fund_setting")>
<cfif useLakebaseForSelYear3Back>
	<cftry>
		<cfset SelYear3Back = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_code_fund_setting", {
				"ar_from_fiscal_year" = "eq.#FORM.Year3Back#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSelYear3Back = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSelYear3Back>
<CFQUERY NAME="SelYear3Back" DATASOURCE="#Application.Datasource#">
	SELECT * FROM GL_Code_Fund_Setting WHERE AR_From_Fiscal_Year = '#FORM.Year3Back#' AND Deleted = 0
</CFQUERY>
</cfif>
<cfset useLakebaseForSelYear2Back = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_fund_setting")>
<cfif useLakebaseForSelYear2Back>
	<cftry>
		<cfset SelYear2Back = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_code_fund_setting", {
				"ar_from_fiscal_year" = "eq.#FORM.Year2Back#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSelYear2Back = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSelYear2Back>
<CFQUERY NAME="SelYear2Back" DATASOURCE="#Application.Datasource#">
	SELECT * FROM GL_Code_Fund_Setting WHERE AR_From_Fiscal_Year = '#FORM.Year2Back#' AND Deleted = 0
</CFQUERY>
</cfif>
<cfset useLakebaseForSelYear1Back = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_fund_setting")>
<cfif useLakebaseForSelYear1Back>
	<cftry>
		<cfset SelYear1Back = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_code_fund_setting", {
				"ar_from_fiscal_year" = "eq.#FORM.Year1Back#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSelYear1Back = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSelYear1Back>
<CFQUERY NAME="SelYear1Back" DATASOURCE="#Application.Datasource#">
	SELECT * FROM GL_Code_Fund_Setting WHERE AR_From_Fiscal_Year = '#FORM.Year1Back#' AND Deleted = 0
</CFQUERY>
</cfif>
<cfset useLakebaseForSelYearNow = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_fund_setting")>
<cfif useLakebaseForSelYearNow>
	<cftry>
		<cfset SelYearNow = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_code_fund_setting", {
				"ar_from_fiscal_year" = "eq.#FORM.YearNow#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSelYearNow = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSelYearNow>
<CFQUERY NAME="SelYearNow" DATASOURCE="#Application.Datasource#">
	SELECT * FROM GL_Code_Fund_Setting WHERE AR_From_Fiscal_Year = '#FORM.YearNow#' AND Deleted = 0
</CFQUERY>
</cfif>
<cfset useLakebaseForSelYear1Plus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_fund_setting")>
<cfif useLakebaseForSelYear1Plus>
	<cftry>
		<cfset SelYear1Plus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_code_fund_setting", {
				"ar_from_fiscal_year" = "eq.#FORM.Year1Plus#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSelYear1Plus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSelYear1Plus>
<CFQUERY NAME="SelYear1Plus" DATASOURCE="#Application.Datasource#">
	SELECT * FROM GL_Code_Fund_Setting WHERE AR_From_Fiscal_Year = '#FORM.Year1Plus#' AND Deleted = 0
</CFQUERY>
</cfif>
<cfset useLakebaseForSelYear2Plus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_fund_setting")>
<cfif useLakebaseForSelYear2Plus>
	<cftry>
		<cfset SelYear2Plus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_code_fund_setting", {
				"ar_from_fiscal_year" = "eq.#FORM.Year2Plus#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSelYear2Plus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSelYear2Plus>
<CFQUERY NAME="SelYear2Plus" DATASOURCE="#Application.Datasource#">
	SELECT * FROM GL_Code_Fund_Setting WHERE AR_From_Fiscal_Year = '#FORM.Year2Plus#' AND Deleted = 0
</CFQUERY>
</cfif>
<cfset useLakebaseForSelYear3Plus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_fund_setting")>
<cfif useLakebaseForSelYear3Plus>
	<cftry>
		<cfset SelYear3Plus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_code_fund_setting", {
				"ar_from_fiscal_year" = "eq.#FORM.Year3Plus#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSelYear3Plus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSelYear3Plus>
<CFQUERY NAME="SelYear3Plus" DATASOURCE="#Application.Datasource#">
	SELECT * FROM GL_Code_Fund_Setting WHERE AR_From_Fiscal_Year = '#FORM.Year3Plus#' AND Deleted = 0
</CFQUERY>
</cfif>


<CFSET AddToList_3 = 1>
<CFIF SelYear3Back.recordcount GT 0 AND SelYear3Back.AR_Status EQ 0>
	<CFSET AddToList_3 = 0>
</CFIF>

<CFSET AddToList_2 = 1>
<CFIF SelYear2Back.recordcount GT 0 AND SelYear2Back.AR_Status EQ 0>
	<CFSET AddToList_2 = 0>
</CFIF>

<CFSET AddToList_1 = 1>
<CFIF SelYear1Back.recordcount GT 0 AND SelYear1Back.AR_Status EQ 0>
	<CFSET AddToList_1 = 0>
</CFIF>

<CFSET AddToList0 = 1>
<CFIF SelYearNow.recordcount GT 0 AND SelYearNow.AR_Status EQ 0>
	<CFSET AddToList0 = 0>
</CFIF>

<CFSET AddToList1 = 1>
<CFIF SelYear1Plus.recordcount GT 0 AND SelYear1Plus.AR_Status EQ 0>
	<CFSET AddToList1 = 0>
</CFIF>

<CFSET AddToList2 = 1>
<CFIF SelYear2Plus.recordcount GT 0 AND SelYear2Plus.AR_Status EQ 0>
	<CFSET AddToList2 = 0>
</CFIF>

<CFSET AddToList3 = 1>
<CFIF SelYear3Plus.recordcount GT 0 AND SelYear3Plus.AR_Status EQ 0>
	<CFSET AddToList3 = 0>
</CFIF>


<CFSET FYTurnedOff = "">
<CFIF FORM.Year3BackSwitchStatus EQ 0>
	<CFIF FYTurnedOff EQ "">
		<CFIF AddToList_3 EQ 1>
			<CFSET FYTurnedOff = "#FORM.Year3Back#">	
		</CFIF>
	</CFIF>
</CFIF>
<CFIF FORM.Year2BackSwitchStatus EQ 0>
	<CFIF FYTurnedOff EQ "">
		<CFIF AddToList_2 EQ 1>
			<CFSET FYTurnedOff = "#FORM.Year2Back#">
		</CFIF>
	<CFELSE>
		<CFIF AddToList_2 EQ 1>
			<CFSET FYTurnedOff = "#FYTurnedOff#,#FORM.Year2Back#">
		</CFIF>
	</CFIF>
</CFIF>
<CFIF FORM.Year1BackSwitchStatus EQ 0>
	<CFIF FYTurnedOff EQ "">
		<CFIF AddToList_1 EQ 1>
			<CFSET FYTurnedOff = "#FORM.Year1Back#">
		</CFIF>
	<CFELSE>
		<CFIF AddToList_1 EQ 1>
			<CFSET FYTurnedOff = "#FYTurnedOff#,#FORM.Year1Back#">
		</CFIF>
	</CFIF>
</CFIF>
<CFIF FORM.YearNowSwitchStatus EQ 0>
	<CFIF FYTurnedOff EQ "">
		<CFIF AddToList0 EQ 1>
			<CFSET FYTurnedOff = "#FORM.YearNow#">
		</CFIF>
	<CFELSE>
		<CFIF AddToList0 EQ 1>
			<CFSET FYTurnedOff = "#FYTurnedOff#,#FORM.YearNow#">
		</CFIF>
	</CFIF>
</CFIF>
<CFIF FORM.Year1PlusSwitchStatus EQ 0>
	<CFIF FYTurnedOff EQ "">
		<CFIF AddToList1 EQ 1>
			<CFSET FYTurnedOff = "#FORM.Year1Plus#">
		</CFIF>
	<CFELSE>
		<CFIF AddToList1 EQ 1>
			<CFSET FYTurnedOff = "#FYTurnedOff#,#FORM.Year1Plus#">
		</CFIF>
	</CFIF>
</CFIF>
<CFIF FORM.Year2PlusSwitchStatus EQ 0>
	<CFIF FYTurnedOff EQ "">
		<CFIF AddToList2 EQ 1>
			<CFSET FYTurnedOff = "#FORM.Year2Plus#">
		</CFIF>
	<CFELSE>
		<CFIF AddToList2 EQ 1>
			<CFSET FYTurnedOff = "#FYTurnedOff#,#FORM.Year2Plus#">
		</CFIF>
	</CFIF>
</CFIF>
<CFIF FORM.Year3PlusSwitchStatus EQ 0>
	<CFIF FYTurnedOff EQ "">
		<CFIF AddToList3 EQ 1>
			<CFSET FYTurnedOff = "#FORM.Year3Plus#">
		</CFIF>
	<CFELSE>
		<CFIF AddToList3 EQ 1>
			<CFSET FYTurnedOff = "#FYTurnedOff#,#FORM.Year3Plus#">
		</CFIF>
	</CFIF>
</CFIF>



<CFTRANSACTION ACTION="BEGIN">
	<!--- 3 year back --->
	<CFIF SelYear3Back.RecordCount GT 0>
		<CFQUERY NAME="Update_year3" DATASOURCE="#Application.Datasource#">
			UPDATE 	GL_Code_Fund_Setting
			
			SET 	AR_Status = '#FORM.Year3BackSwitchStatus#'
			
			WHERE 	AR_From_Fiscal_Year = '#FORM.Year3Back#' AND 
					Deleted = 0
		</CFQUERY>	
	<CFELSE>
		<CFQUERY NAME="Insert_year3" DATASOURCE="#Application.Datasource#">
			INSERT INTO 
			GL_Code_Fund_Setting	(	AR_From_Fiscal_Year,
										AR_Status				)
										
			VALUES					(	'#FORM.Year3Back#',
										'#FORM.Year3BackSwitchStatus#' )
		</CFQUERY>
	</CFIF>
	<CFIF FORM.Year3BackSwitchStatus EQ 0>
		<CFQUERY NAME="EligibleTemplateID" DATASOURCE="#Application.Datasource#">
			SELECT DISTINCT Template_ID FROM GL_Code_AR_For_ProgTemp WHERE Fiscal_Year = '#FORM.Year3Back#' AND Deleted = 0
		</CFQUERY>
		<CFLOOP QUERY="EligibleTemplateID">
			<CFQUERY NAME="DeleteFY" DATASOURCE="#Application.Datasource#">
				DELETE FROM GL_Code_AR_For_ProgTemp WHERE Template_ID = '#Template_ID#' AND Fiscal_Year = '#FORM.Year3Back#' AND Deleted = 0
			</CFQUERY>
			
			<CFQUERY NAME="CheckAnythingElse" DATASOURCE="#Application.Datasource#">
				SELECT Top 1 * FROM GL_Code_AR_For_ProgTemp WHERE Template_ID = '#Template_ID#' AND Deleted = 0
			</CFQUERY>
			<CFIF CheckAnythingElse.RecordCount EQ 0>
				<CFQUERY NAME="DeactivateProgWiz" DATASOURCE="#Application.Datasource#">
					UPDATE 	Program_Control_Panel_Options
					
					SET 	Deleted = 1,
							FiscalYear_Off_Deactivated = 1
							
					WHERE 	ProgramControl_Panel_Options_ID = '#Template_ID#'
				</CFQUERY>
			</CFIF>
		</CFLOOP>		
	</CFIF>
	
	
	<!--- 2 years back --->
	<CFIF SelYear2Back.RecordCount GT 0>
		<CFQUERY NAME="Update_year2" DATASOURCE="#Application.Datasource#">
			UPDATE 	GL_Code_Fund_Setting
			
			SET 	AR_Status = '#FORM.Year2BackSwitchStatus#'
			
			WHERE 	AR_From_Fiscal_Year = '#FORM.Year2Back#' AND 
					Deleted = 0
		</CFQUERY>	
	<CFELSE>
		<CFQUERY NAME="Insert_year2" DATASOURCE="#Application.Datasource#">
			INSERT INTO 
			GL_Code_Fund_Setting	(	AR_From_Fiscal_Year,
										AR_Status				)
										
			VALUES					(	'#FORM.Year2Back#',
										'#FORM.Year2BackSwitchStatus#' )
		</CFQUERY>
	</CFIF>
	<CFIF FORM.Year2BackSwitchStatus EQ 0>
		<!--- <CFQUERY NAME="DeactivateProgWiz" DATASOURCE="#Application.Datasource#">
			UPDATE 	Program_Control_Panel_Options
			
			SET 	Deleted = 1,
					FiscalYear_Off_Deactivated = 1
					
			WHERE 	AR_From_Fiscal_Year = '#FORM.Year2Back#' AND Deleted = 0
		</CFQUERY> --->
		<CFQUERY NAME="EligibleTemplateID" DATASOURCE="#Application.Datasource#">
			SELECT DISTINCT Template_ID FROM GL_Code_AR_For_ProgTemp WHERE Fiscal_Year = '#FORM.Year2Back#' AND Deleted = 0
		</CFQUERY>
		<CFLOOP QUERY="EligibleTemplateID">
			<CFQUERY NAME="DeleteFY" DATASOURCE="#Application.Datasource#">
				DELETE FROM GL_Code_AR_For_ProgTemp WHERE Template_ID = '#Template_ID#' AND Fiscal_Year = '#FORM.Year2Back#' AND Deleted = 0
			</CFQUERY>
			
			<CFQUERY NAME="CheckAnythingElse" DATASOURCE="#Application.Datasource#">
				SELECT Top 1 * FROM GL_Code_AR_For_ProgTemp WHERE Template_ID = '#Template_ID#' AND Deleted = 0
			</CFQUERY>
			<CFIF CheckAnythingElse.RecordCount EQ 0>
				<CFQUERY NAME="DeactivateProgWiz" DATASOURCE="#Application.Datasource#">
					UPDATE 	Program_Control_Panel_Options
					
					SET 	Deleted = 1,
							FiscalYear_Off_Deactivated = 1
							
					WHERE 	ProgramControl_Panel_Options_ID = '#Template_ID#'
				</CFQUERY>
			</CFIF>
		</CFLOOP>		
	</CFIF>
	
	
	<!--- 1 year back --->
	<CFIF SelYear1Back.RecordCount GT 0>
		<CFQUERY NAME="Update_year_1" DATASOURCE="#Application.Datasource#">
			UPDATE 	GL_Code_Fund_Setting
			
			SET 	AR_Status = '#FORM.Year1BackSwitchStatus#'
			
			WHERE 	AR_From_Fiscal_Year = '#FORM.Year1Back#' AND 
					Deleted = 0
		</CFQUERY>	
	<CFELSE>
		<CFQUERY NAME="Insert_year_1" DATASOURCE="#Application.Datasource#">
			INSERT INTO 
			GL_Code_Fund_Setting	(	AR_From_Fiscal_Year,
										AR_Status				)
										
			VALUES					(	'#FORM.Year1Back#',
										'#FORM.Year1BackSwitchStatus#' )
		</CFQUERY>
	</CFIF>
	<CFIF FORM.Year1BackSwitchStatus EQ 0>
		<!--- <CFQUERY NAME="DeactivateProgWiz" DATASOURCE="#Application.Datasource#">
			UPDATE 	Program_Control_Panel_Options
			
			SET 	Deleted = 1,
					FiscalYear_Off_Deactivated = 1
					
			WHERE 	AR_From_Fiscal_Year = '#FORM.Year1Back#' AND Deleted = 0
		</CFQUERY> --->
		<CFQUERY NAME="EligibleTemplateID" DATASOURCE="#Application.Datasource#">
			SELECT DISTINCT Template_ID FROM GL_Code_AR_For_ProgTemp WHERE Fiscal_Year = '#FORM.Year1Back#' AND Deleted = 0
		</CFQUERY>
		<CFLOOP QUERY="EligibleTemplateID">
			<CFQUERY NAME="DeleteFY" DATASOURCE="#Application.Datasource#">
				DELETE FROM GL_Code_AR_For_ProgTemp WHERE Template_ID = '#Template_ID#' AND Fiscal_Year = '#FORM.Year1Back#' AND Deleted = 0
			</CFQUERY>
			
			<CFQUERY NAME="CheckAnythingElse" DATASOURCE="#Application.Datasource#">
				SELECT Top 1 * FROM GL_Code_AR_For_ProgTemp WHERE Template_ID = '#Template_ID#' AND Deleted = 0
			</CFQUERY>
			<CFIF CheckAnythingElse.RecordCount EQ 0>
				<CFQUERY NAME="DeactivateProgWiz" DATASOURCE="#Application.Datasource#">
					UPDATE 	Program_Control_Panel_Options
					
					SET 	Deleted = 1,
							FiscalYear_Off_Deactivated = 1
							
					WHERE 	ProgramControl_Panel_Options_ID = '#Template_ID#'
				</CFQUERY>
			</CFIF>
		</CFLOOP>	
	</CFIF>
	
	<!--- This Year --->
	<CFIF SelYearNow.RecordCount GT 0>
		<CFQUERY NAME="Update_year0" DATASOURCE="#Application.Datasource#">
			UPDATE 	GL_Code_Fund_Setting
			
			SET 	AR_Status = '#FORM.YearNowSwitchStatus#'
			
			WHERE 	AR_From_Fiscal_Year = '#FORM.YearNow#' AND 
					Deleted = 0
		</CFQUERY>	
	<CFELSE>
		<CFQUERY NAME="Insert_year0" DATASOURCE="#Application.Datasource#">
			INSERT INTO 
			GL_Code_Fund_Setting	(	AR_From_Fiscal_Year,
										AR_Status				)
										
			VALUES					(	'#FORM.YearNow#',
										'#FORM.YearNowSwitchStatus#' )
		</CFQUERY>
	</CFIF>
	<CFIF FORM.YearNowSwitchStatus EQ 0>
		<!--- <CFQUERY NAME="DeactivateProgWiz" DATASOURCE="#Application.Datasource#">
			UPDATE 	Program_Control_Panel_Options
			
			SET 	Deleted = 1,
					FiscalYear_Off_Deactivated = 1
					
			WHERE 	AR_From_Fiscal_Year = '#FORM.YearNow#' AND Deleted = 0
		</CFQUERY> --->
		<CFQUERY NAME="EligibleTemplateID" DATASOURCE="#Application.Datasource#">
			SELECT DISTINCT Template_ID FROM GL_Code_AR_For_ProgTemp WHERE Fiscal_Year = '#FORM.YearNow#' AND Deleted = 0
		</CFQUERY>
		<CFLOOP QUERY="EligibleTemplateID">
			<CFQUERY NAME="DeleteFY" DATASOURCE="#Application.Datasource#">
				DELETE FROM GL_Code_AR_For_ProgTemp WHERE Template_ID = '#Template_ID#' AND Fiscal_Year = '#FORM.YearNow#' AND Deleted = 0
			</CFQUERY>
			
			<CFQUERY NAME="CheckAnythingElse" DATASOURCE="#Application.Datasource#">
				SELECT Top 1 * FROM GL_Code_AR_For_ProgTemp WHERE Template_ID = '#Template_ID#' AND Deleted = 0
			</CFQUERY>
			<CFIF CheckAnythingElse.RecordCount EQ 0>
				<CFQUERY NAME="DeactivateProgWiz" DATASOURCE="#Application.Datasource#">
					UPDATE 	Program_Control_Panel_Options
					
					SET 	Deleted = 1,
							FiscalYear_Off_Deactivated = 1
							
					WHERE 	ProgramControl_Panel_Options_ID = '#Template_ID#'
				</CFQUERY>
			</CFIF>
		</CFLOOP>	
	</CFIF>
	
	<!--- Next year --->
	<CFIF SelYear1Plus.RecordCount GT 0>
		<CFQUERY NAME="Update_year1" DATASOURCE="#Application.Datasource#">
			UPDATE 	GL_Code_Fund_Setting
			
			SET 	AR_Status = '#FORM.Year1PlusSwitchStatus#'
			
			WHERE 	AR_From_Fiscal_Year = '#FORM.Year1Plus#' AND 
					Deleted = 0
		</CFQUERY>	
	<CFELSE>
		<CFQUERY NAME="Insert_year1" DATASOURCE="#Application.Datasource#">
			INSERT INTO 
			GL_Code_Fund_Setting	(	AR_From_Fiscal_Year,
										AR_Status				)
										
			VALUES					(	'#FORM.Year1Plus#',
										'#FORM.Year1PlusSwitchStatus#' )
		</CFQUERY>
	</CFIF>
	<CFIF FORM.Year1PlusSwitchStatus EQ 0>
		<!--- <CFQUERY NAME="DeactivateProgWiz" DATASOURCE="#Application.Datasource#">
			UPDATE 	Program_Control_Panel_Options
			
			SET 	Deleted = 1,
					FiscalYear_Off_Deactivated = 1
					
			WHERE 	AR_From_Fiscal_Year = '#FORM.Year1Plus#' AND Deleted = 0
		</CFQUERY> --->
		<CFQUERY NAME="EligibleTemplateID" DATASOURCE="#Application.Datasource#">
			SELECT DISTINCT Template_ID FROM GL_Code_AR_For_ProgTemp WHERE Fiscal_Year = '#FORM.Year1Plus#' AND Deleted = 0
		</CFQUERY>
		<CFLOOP QUERY="EligibleTemplateID">
			<CFQUERY NAME="DeleteFY" DATASOURCE="#Application.Datasource#">
				DELETE FROM GL_Code_AR_For_ProgTemp WHERE Template_ID = '#Template_ID#' AND Fiscal_Year = '#FORM.Year1Plus#' AND Deleted = 0
			</CFQUERY>
			
			<CFQUERY NAME="CheckAnythingElse" DATASOURCE="#Application.Datasource#">
				SELECT Top 1 * FROM GL_Code_AR_For_ProgTemp WHERE Template_ID = '#Template_ID#' AND Deleted = 0
			</CFQUERY>
			<CFIF CheckAnythingElse.RecordCount EQ 0>
				<CFQUERY NAME="DeactivateProgWiz" DATASOURCE="#Application.Datasource#">
					UPDATE 	Program_Control_Panel_Options
					
					SET 	Deleted = 1,
							FiscalYear_Off_Deactivated = 1
							
					WHERE 	ProgramControl_Panel_Options_ID = '#Template_ID#'
				</CFQUERY>
			</CFIF>
		</CFLOOP>	
	</CFIF>
	
	
	<!--- Next to Next year --->
	<CFIF SelYear2Plus.RecordCount GT 0>
		<CFQUERY NAME="Update_year2" DATASOURCE="#Application.Datasource#">
			UPDATE 	GL_Code_Fund_Setting
			
			SET 	AR_Status = '#FORM.Year2PlusSwitchStatus#'
			
			WHERE 	AR_From_Fiscal_Year = '#FORM.Year2Plus#' AND 
					Deleted = 0
		</CFQUERY>	
	<CFELSE>
		<CFQUERY NAME="Insert_year2" DATASOURCE="#Application.Datasource#">
			INSERT INTO 
			GL_Code_Fund_Setting	(	AR_From_Fiscal_Year,
										AR_Status				)
										
			VALUES					(	'#FORM.Year2Plus#',
										'#FORM.Year2PlusSwitchStatus#' )
		</CFQUERY>
	</CFIF>
	<CFIF FORM.Year2PlusSwitchStatus EQ 0>
		<!--- <CFQUERY NAME="DeactivateProgWiz" DATASOURCE="#Application.Datasource#">
			UPDATE 	Program_Control_Panel_Options
			
			SET 	Deleted = 1,
					FiscalYear_Off_Deactivated = 1
					
			WHERE 	AR_From_Fiscal_Year = '#FORM.Year1Plus#' AND Deleted = 0
		</CFQUERY> --->
		<CFQUERY NAME="EligibleTemplateID" DATASOURCE="#Application.Datasource#">
			SELECT DISTINCT Template_ID FROM GL_Code_AR_For_ProgTemp WHERE Fiscal_Year = '#FORM.Year2Plus#' AND Deleted = 0
		</CFQUERY>
		<CFLOOP QUERY="EligibleTemplateID">
			<CFQUERY NAME="DeleteFY" DATASOURCE="#Application.Datasource#">
				DELETE FROM GL_Code_AR_For_ProgTemp WHERE Template_ID = '#Template_ID#' AND Fiscal_Year = '#FORM.Year2Plus#' AND Deleted = 0
			</CFQUERY>
			
			<CFQUERY NAME="CheckAnythingElse" DATASOURCE="#Application.Datasource#">
				SELECT Top 1 * FROM GL_Code_AR_For_ProgTemp WHERE Template_ID = '#Template_ID#' AND Deleted = 0
			</CFQUERY>
			<CFIF CheckAnythingElse.RecordCount EQ 0>
				<CFQUERY NAME="DeactivateProgWiz" DATASOURCE="#Application.Datasource#">
					UPDATE 	Program_Control_Panel_Options
					
					SET 	Deleted = 1,
							FiscalYear_Off_Deactivated = 1
							
					WHERE 	ProgramControl_Panel_Options_ID = '#Template_ID#'
				</CFQUERY>
			</CFIF>
		</CFLOOP>	
	</CFIF>
	
	
	<!--- Next Next to Next year --->
	<CFIF SelYear3Plus.RecordCount GT 0>
		<CFQUERY NAME="Update_year3" DATASOURCE="#Application.Datasource#">
			UPDATE 	GL_Code_Fund_Setting
			
			SET 	AR_Status = '#FORM.Year3PlusSwitchStatus#'
			
			WHERE 	AR_From_Fiscal_Year = '#FORM.Year3Plus#' AND 
					Deleted = 0
		</CFQUERY>	
	<CFELSE>
		<CFQUERY NAME="Insert_year3" DATASOURCE="#Application.Datasource#">
			INSERT INTO 
			GL_Code_Fund_Setting	(	AR_From_Fiscal_Year,
										AR_Status				)
										
			VALUES					(	'#FORM.Year3Plus#',
										'#FORM.Year3PlusSwitchStatus#' )
		</CFQUERY>
	</CFIF>
	<CFIF FORM.Year3PlusSwitchStatus EQ 0>
		<!--- <CFQUERY NAME="DeactivateProgWiz" DATASOURCE="#Application.Datasource#">
			UPDATE 	Program_Control_Panel_Options
			
			SET 	Deleted = 1,
					FiscalYear_Off_Deactivated = 1
					
			WHERE 	AR_From_Fiscal_Year = '#FORM.Year1Plus#' AND Deleted = 0
		</CFQUERY> --->
		<CFQUERY NAME="EligibleTemplateID" DATASOURCE="#Application.Datasource#">
			SELECT DISTINCT Template_ID FROM GL_Code_AR_For_ProgTemp WHERE Fiscal_Year = '#FORM.Year3Plus#' AND Deleted = 0
		</CFQUERY>
		<CFLOOP QUERY="EligibleTemplateID">
			<CFQUERY NAME="DeleteFY" DATASOURCE="#Application.Datasource#">
				DELETE FROM GL_Code_AR_For_ProgTemp WHERE Template_ID = '#Template_ID#' AND Fiscal_Year = '#FORM.Year3Plus#' AND Deleted = 0
			</CFQUERY>
			
			<CFQUERY NAME="CheckAnythingElse" DATASOURCE="#Application.Datasource#">
				SELECT Top 1 * FROM GL_Code_AR_For_ProgTemp WHERE Template_ID = '#Template_ID#' AND Deleted = 0
			</CFQUERY>
			<CFIF CheckAnythingElse.RecordCount EQ 0>
				<CFQUERY NAME="DeactivateProgWiz" DATASOURCE="#Application.Datasource#">
					UPDATE 	Program_Control_Panel_Options
					
					SET 	Deleted = 1,
							FiscalYear_Off_Deactivated = 1
							
					WHERE 	ProgramControl_Panel_Options_ID = '#Template_ID#'
				</CFQUERY>
			</CFIF>
		</CFLOOP>	
	</CFIF>
	
	<!--- Set BB below status 3 to expired --->
	<!--- <CFIF FYTurnedOff NEQ "">
	<CFQUERY NAME="GetAllBB" DATASOURCE="#Application.Datasource#">
		SELECT 	* 
		FROM 	Billback
		WHERE 	Billback_Status_ID < 3 AND Deleted=0
	</CFQUERY>
	
	<CFLOOP QUERY="GetAllBB">
		<CFQUERY NAME="CheckProgram" DATASOURCE="#Application.Datasource#">
			SELECT 		Billback_Program_ID,
						Billback_Program.Program_ID
						
			FROM 		Billback_Program
			
			INNER JOIN	Contract_Main ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
			INNER JOIN	Program_Control_Panel_Options ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID AND
						AR_From_Fiscal_Year IN (#FYTurnedOff#)
						
			WHERE		Billback_ID = '#Billback_ID#' AND 
						Billback_Program.DELETED = 0
		</CFQUERY>
		<CFIF CheckProgram.RecordCount GT 0>
			
			<CFQUERY NAME="CheckLock" DATASOURCE="#Application.Datasource#">
				SELECT BB_Is_Locked FROM Billback_Allied WHERE Billback_ID = '#Billback_ID#'
			</CFQUERY>
			
			<CFIF CheckLock.BB_Is_Locked EQ 1>
				<CFQUERY NAME="Unlock" DATASOURCE="#Application.Datasource#">
					UPDATE 	Billback_Allied
					
					SET 	BB_Is_Locked = 0,
							BB_Locked_By_User_ID = NULL,
							BB_Lock_Date = NULL
							
					WHERE 	Billback_ID = '#Billback_ID#'
				</CFQUERY>
			</CFIF>
			
			<!--- 
			<CFQUERY NAME="LockBB" DATASOURCE="#Application.Datasource#">
				UPDATE 	Billback_Allied
					
				SET 	BB_Is_Locked = 1,
						BB_Locked_By_User_ID = NULL,
						BB_Lock_Date = getdate()
						
				WHERE 	Billback_ID = '#Billback_ID#'
			</CFQUERY> --->
			
		
			<CFQUERY NAME="CheckforOtherPrograms" DATASOURCE="#Application.Datasource#">
				SELECT Count(*) FROM Billback_Program WHERE Billback_ID = '#Billback_ID#' AND DELETED = 0
			</CFQUERY>
			<CFIF CheckProgram.RecordCount EQ CheckforOtherPrograms.Recordcount>			
				<CFQUERY NAME="MakeBBExpired" DATASOURCE="#Application.Datasource#">
					UPDATE 	Billback
					SET 	Deleted = 1,
							FYDisabled = 1
							
					WHERE	Billback_ID = '#Billback_ID#'
				</CFQUERY>
			<CFELSE>
				<CFSET BBID = Billback_ID>
				<CFLOOP QUERY="CheckProgram">
					<CFQUERY NAME="DeleteProductDetails" DATASOURCE="#Application.Datasource#">
						UPDATE 	Billback_Product_Detail
						SET 	Deleted = 1
						WHERE 	Deleted = 0 AND
								Billback_ID = '#BBID#' AND
								Billback_Product_ID IN (	SELECT 	Billback_Product_ID 
															FROM 	Billback_Product 
															WHERE 	Billback_Program_ID = '#Billback_Program_ID#' AND 
																	Deleted = 0			) 
					</CFQUERY>
					
					<CFQUERY NAME="DeleteProduct" DATASOURCE="#Application.Datasource#">
						UPDATE 	Billback_Product
						SET		Deleted = 1
						WHERE 	Billback_ID = '#BBID#' AND
								Billback_Program_ID = '#Billback_Program_ID#' AND 
								Deleted = 0
					</CFQUERY>
					
					<CFQUERY NAME="DeleteLumpSum" DATASOURCE="#Application.Datasource#">
						UPDATE 	Billback_Program_Lumpsum_Component
						SET 	Deleted = 1
						WHERE 	Billback_ID = '#BBID#' AND
								Billback_Program_ID = '#Billback_Program_ID#' AND 
								Deleted = 0
					</CFQUERY>
					
					<CFQUERY NAME="DeleteProgram" DATASOURCE="#Application.Datasource#">
						UPDATE 	Billback_Program
						SET 	Deleted = 1,
								FYDisabled = 1
								
						WHERE 	Billback_ID = '#BBID#' AND
								Billback_Program_ID = '#Billback_Program_ID#' AND 
								Deleted = 0
					</CFQUERY>
				</CFLOOP>
			</CFIF>
			
			
			<!--- 
			<CFQUERY NAME="UnLockBB" DATASOURCE="#Application.Datasource#">
				UPDATE 	Billback_Allied
					
				SET 	BB_Is_Locked = 0,
						BB_Locked_By_User_ID = NULL,
						BB_Lock_Date = NULL
						
				WHERE 	Billback_ID = '#Billback_ID#'
			</CFQUERY> --->
		</CFIF>
	</CFLOOP>
	</CFIF> --->
<CFTRANSACTION ACTION="COMMIT">
</CFTRANSACTION>

<CFLOCATION URL="Fund_Management.cfm" ADDTOKEN="No">
</body>
</html>
