<!---
	Name: budget_access_rights_action.cfm        
	Copyright (c) 2006 Blacksmith Applications, Inc.       
    Author: 		Clarence Morse         
	Description: 	Processes the user profile settings for Budgets
	Usage:			is included inside access_rights_matrix_action.cfm
--->	
		<cfloop query="getProfiles">
		<cfset LOOPCOUNT = getProfiles.profiles_id>
		
			<!--- Default Field Values --->
			<CFPARAM NAME="Budget_Access_Level_#LOOPCOUNT#" 		DEFAULT="0">
			<CFPARAM NAME="Budget_Approve_#LOOPCOUNT#" 				DEFAULT="0">
			<CFPARAM NAME="Budget_Approval_With_Zero_#LOOPCOUNT#" 	DEFAULT="0">
			<CFPARAM NAME="Budget_Commit_Tolerance_#LOOPCOUNT#" 	DEFAULT="0">
			<CFPARAM NAME="Budget_Settlement_Tolerance_#LOOPCOUNT#" DEFAULT="0">

			<CFQUERY NAME="Save_Data" DATASOURCE="#application.datasource#">
				DELETE		
				FROM		Budget_Profiles_Settings
				WHERE		Profiles_ID = #LOOPCOUNT#;
				INSERT INTO
				Budget_Profiles_Settings
				(
					Profiles_ID, 
					Budget_Access_Level, 
					Budget_Approve,
					Budget_Approval_With_Zero, 
					Budget_Commit_Tolerance, 
					Budget_Settlement_Tolerance, 
					Budget_Updated_Date,
					Budget_Updated_User_Id
				)
				VALUES
				(
					#LOOPCOUNT#, 
					#Evaluate("Budget_Access_Level_#LOOPCOUNT#")#, 
					#Evaluate("Budget_Approve_#LOOPCOUNT#")#, 
					#Evaluate("Budget_Approval_With_Zero_#LOOPCOUNT#")#,
					'#Evaluate("Budget_Commit_Tolerance_#LOOPCOUNT#")#',
					'#Evaluate("Budget_Settlement_Tolerance_#LOOPCOUNT#")#',
					GetDate(),
					'#request.AccessStructure.User_ID#'
				)
			</CFQUERY>
		</CFLOOP>
