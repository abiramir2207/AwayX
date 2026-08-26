<!--- Dev Note: KAL; D7821 --->


	<!--- Dev Note: drachala; D28010: Profile Setting modifications 
		  what For: Check weather user selected any profiles if so we are passing argument into getDD_Status_Settings query.	--->

	<cfset profile_id = ''>
	<cfif isdefined("url.profile_id")>
		<cfset profile_id = #trim(url.profile_id)#>
	</cfif>
<cfset DD_Status_Profile_Settings =  CreateObject("component", "components.settings.profiles.profile").getDD_Status_Settings(profile_id)>

	<!--- End Dev Note: drachala; D28010: Profile Setting modifications  ---> 


	<!--- Deleting the prior records --->
	<cfquery name="DD_Statuses_Update" datasource="#application.datasource#">
		UPDATE	DD_Status_Profile_Control
		SET		Deleted = 1, Created_Date = GETDATE()
		WHERE	(ISNULL(DD_Status_ID, 0) <> '')  
		<!--- Dev Note: drachala; D28010: Profile Setting modifications 
		What For: Check weather user selected any profiles if so we run Query OF Query on getprofiles query.
		--->
		<cfif isdefined("url.profile_id") AND len(url.profile_id) GT 0> 
		AND Profiles_id IN ( <cfqueryparam value="#trim(url.profile_id)#" cfsqltype="CF_SQL_INTEGER" list="yes"	/>	)
		</cfif>
		<!--- End Dev Note: drachala; D28010: Profile Setting modifications  --->
		<cfif UserSetting.Settings_Panel LT 5>
			AND Profiles_ID NOT IN (select distinct  Profiles_ID from Profiles_Settings where Settings_Panel = 5 and Profiles_Settings.deleted = 0)
		</cfif>
		AND		Deleted = 0
	</cfquery>
	
	

	<cfoutput query="DD_Status_Profile_Settings" group="DD_Status_Order">
		<cfoutput group="Profiles_ID">
			<cfparam name="Hide_#DD_Status_ID#_#Profiles_ID#"		 default="0">
			<cfif (evaluate("Hide_#DD_Status_ID#_#Profiles_ID#") eq 1)>
				<cfset useLakebaseForDD_Status_Update = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_status_profile_control")>
				<cfif useLakebaseForDD_Status_Update>
					<cftry>
						<cfset application.oLakebase.insertRow("dd_status_profile_control", {
							"profiles_id" = Profiles_ID,
							"dd_status_id" = DD_Status_ID
						})>
						<cfcatch type="any">
							<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
							<cfset useLakebaseForDD_Status_Update = false>
						</cfcatch>
					</cftry>
				</cfif>
				<cfif NOT useLakebaseForDD_Status_Update>
				<cfquery name="DD_Status_Update" datasource="#application.datasource#">
					INSERT INTO	DD_Status_Profile_Control (Profiles_ID, DD_Status_ID)
						Values	(#Profiles_ID#, #DD_Status_ID#)
				</cfquery>
				</cfif>
			</cfif>
		</cfoutput>		<!--- Profiles_ID --->
	</cfoutput>		<!--- DD_Status_Order --->
<!--- End Note: KAL; D7821 --->



	        <!--- Dev Note: drachala; D28010: Profile Setting modifications 
			  what For: Check weather user selected any profiles if so we are passing argument into getprofiles query.	--->

		<cfset oProfiles = CreateObject("component","components.settings.profiles.profile") />
		<cfset Get_Profile_Settings = oProfiles.getAllProfiles(profile_id)>

			<!--- End Dev Note: drachala; D28010: Profile Setting modifications  ---> 
		
		
		

		

		<CFLOOP query="Get_Profile_Settings">
			<CFSET LOOPCOUNT = Get_Profile_Settings.profiles_ID>


			<cfparam name="Deduction_Analyst_#LOOPCOUNT#" 						default="0">
			<cfparam name="DD_Approve_#LOOPCOUNT#" 								default="0">
			<cfparam name="DD_Approve_Amount_#LOOPCOUNT#" 						default="0">
			<cfparam name="DD_Reassign_Access_#LOOPCOUNT#" 						default="0">
			<cfparam name="DD_Delete_#LOOPCOUNT#" 								default="0">
			<cfparam name="DD_Internal_Notes_#LOOPCOUNT#" 						default="0">
			<cfparam name="DD_Approve_Rebill_#LOOPCOUNT#" 						default="0">
			<cfparam name="DD_Open_Rebill_Transfer_#LOOPCOUNT#" 				default="0">
			<cfparam name="DD_Split_#LOOPCOUNT#" 								default="0">
			<cfparam name="DD_Reject_#LOOPCOUNT#" 								default="0">  <!--- Dev Note: KAL; D8047 --->
			<cfparam name="DD_Edit_Cust_RefNo_#LOOPCOUNT#"						default="0">  <!--- Dev Note: KAL; D7819 --->
			<CFPARAM NAME="DD_RFA_Agreed_#LOOPCOUNT#" 							DEFAULT="0">
			<cfparam name="DD_Disable_Inv_Link_#LOOPCOUNT#"						default="0">  <!--- Dev Note: KAL; D8151 --->
			<CFPARAM name="DD_ACCESS_LEVEL_#LOOPCOUNT#"							default="1">  <!--- Dev Note: CPM; D8429 0 = None; 1=View Only;--->
			<CFPARAM name="DD_Search_By_Analyst_#LOOPCOUNT#"					default="0">  <!--- Dev Note: DAA; D14555 --->
			<CFPARAM name="DD_Match_Central_#LOOPCOUNT#"						default="0">  <!--- Dev Note: DAA; D14555 --->
			<CFPARAM name="DD_Match_Central_Write_Off_Amount_#LOOPCOUNT#"		default="0">  <!--- Dev Note: DAA; D14555 --->
			<CFPARAM name="DD_Non_Trade_Tolerance_#LOOPCOUNT#"					default="0">  <!--- D29481:Non trade deductions --->
			<CFPARAM name="DD_New_From_Open_#LOOPCOUNT#"						default="0">  <!--- Dev Note: DAA; D14555 --->
			<CFPARAM name="DD_ReOpen_#LOOPCOUNT#"								default="0">  <!--- Dev Note: Anand Rao; D111888 --->
			
			<CFPARAM name="Search_Customer_Invoice_#LOOPCOUNT#"						default="0">  
			<!----------------
			<CFPARAM NAME="BB_Approve_Critical_Amount_#LOOPCOUNT#" 	DEFAULT=0>
			------------->

			<CFIF (Trim(Evaluate("DD_Approve_Amount_#LOOPCOUNT#")) EQ "") OR (Evaluate("DD_Approve_#LOOPCOUNT#") EQ 0)>
				<CFSET "DD_Approve_Amount_#LOOPCOUNT#"=0>
			</CFIF>
			<CFIF (Trim(Evaluate("DD_Match_Central_Write_Off_Amount_#LOOPCOUNT#")) EQ "") OR (Evaluate("DD_Match_Central_Write_Off_Amount_#LOOPCOUNT#") EQ 0)>
				<CFSET "DD_Match_Central_Write_Off_Amount_#LOOPCOUNT#"=0>
			</CFIF>
			<!--- AUDITING - CAPTURE ORIGINAL --->
			<cfquery name="variables.qOriginal" datasource="#application.datasource#">
				SELECT Profiles_Desc, DS.*
				FROM Deductions_Profiles_Settings  DS
				INNER JOIN Profiles p on DS.profiles_id  = p.profiles_id 
				WHERE DS.Profiles_ID = #loopCount# AND DS.deleted = 0 and p.deleted = 0
			</cfquery>
			
			<CFQUERY NAME="Save_Data" DATASOURCE="#application.datasource#">
				DELETE
				FROM		Deductions_Profiles_Settings
				WHERE		Profiles_ID = #LOOPCOUNT#;
				INSERT INTO Deductions_Profiles_Settings	(
					Profiles_ID,
					Deduction_Analyst,
					DD_Approve,
					DD_Approve_Amount,
					DD_User_ID,
					DD_Updated_Date,
					DD_Reassign_Access,
					DD_Delete,
					DD_Internal_Notes,
					DD_Approve_Rebill,
					DD_Open_Rebill_Transfer,
					DD_Split,
					DD_Reject,
					DD_RFA_Agreed,
					DD_Edit_Cust_RefNo,
					DD_Disable_Inv_Link,
					DD_ACCESS_LEVEL,
					DD_Search_By_Analyst,
					DD_Match_Central,
					DD_Match_Central_Write_Off_Amount,
					DD_Non_Trade_Tolerance, <!--- D29481:Non trade deductions --->
					DD_New_From_Open
					,Search_Customer_Invoice
					,DD_ReOpen
				)
				VALUES
				(
					#LOOPCOUNT#,
					#Evaluate("Deduction_Analyst_#LOOPCOUNT#")#,
					#Evaluate("DD_Approve_#LOOPCOUNT#")#,
					'#Evaluate("DD_Approve_Amount_#LOOPCOUNT#")#',
					'#request.AccessStructure.User_ID#',
					GetDate(),
					#Evaluate("DD_Reassign_Access_#LOOPCOUNT#")#,
					'#Evaluate("DD_Delete_#LOOPCOUNT#")#',
					'#Evaluate("DD_Internal_Notes_#LOOPCOUNT#")#',
					'#Evaluate("DD_Approve_Rebill_#LOOPCOUNT#")#',
					'#Evaluate("DD_Open_Rebill_Transfer_#LOOPCOUNT#")#',
					'#Evaluate("DD_Split_#LOOPCOUNT#")#',
					'#Evaluate("DD_Reject_#LOOPCOUNT#")#',
					'#Evaluate("DD_RFA_Agreed_#LOOPCOUNT#")#',
					'#Evaluate("DD_Edit_Cust_RefNo_#LOOPCOUNT#")#',
					'#Evaluate("DD_Disable_Inv_Link_#LOOPCOUNT#")#',
					'#Evaluate("DD_ACCESS_LEVEL_#LOOPCOUNT#")#',
					'#Evaluate("DD_Search_By_Analyst_#LOOPCOUNT#")#',
					'#Evaluate("DD_Match_Central_#LOOPCOUNT#")#',
					'#Evaluate("DD_Match_Central_Write_Off_Amount_#LOOPCOUNT#")#',
					'#Evaluate("DD_Non_Trade_Tolerance_#LOOPCOUNT#")#', <!--- D29481:Non trade deductions --->
					'#Evaluate("DD_New_From_Open_#LOOPCOUNT#")#'
					,'#Evaluate("Search_Customer_Invoice_#LOOPCOUNT#")#'
					,'#Evaluate("DD_ReOpen_#LOOPCOUNT#")#'
				)
			</CFQUERY>

			<!--- AUDITING - CAPTURE CHANGES --->
			<cfquery name="variables.qUpdated" datasource="#application.datasource#">
				SELECT Profiles_Desc, DS.*
				FROM Deductions_Profiles_Settings  DS
				INNER JOIN Profiles p on DS.profiles_id  = p.profiles_id 
				WHERE DS.Profiles_ID = #loopCount# AND DS.deleted = 0 and p.deleted = 0
			</cfquery>
			<cfscript>
				variables.udf = createObject( "component", "components.udf" );
				variables.udf.WriteSettingsAudit( variables.qOriginal, variables.qUpdated, "Deductions_Profiles_Settings", loopCount, "#variables.qUpdated.Profiles_Desc#", "DD_User_ID,Profiles_Id,Created_Date,DD_Profile_Settings_ID,DD_Updated_Date" );
			</cfscript>
		</CFLOOP>
