<cfsilent>
<!---  
       Name:          scheduleMassProgramChange.cfm           
       Copyright:     Copyright (c) 2010 Blacksmith Applications, Inc.       
       Created Date:  12/01/2010
       Created By:    Kal
       Label:		  25195
       Description:   Mass Program Change Upload Utility
--->
</cfsilent>

<!--- Initiate the CFC --->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset MPCUManager = createObject("component","mvc.Models.Program.Upload.MassProgramChange") />
<cfset program = CreateObject("component", "components.programs.program") />
<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init() />

<!--- update type --->
<cfparam name="variables.updateType" default="#MPCUManager.getUpdateType(url.user_ID)#" />

<cftry>
	<!--- procedure to populate the header and detail table --->
	<cfstoredproc procedure="USP_Mass_Program_GET_MPCU_Data" datasource="#application.datasource#" >
			<cfprocparam cfsqltype = "cf_sql_varchar" type = "in" value="#variables.updateType#">
	</cfstoredproc>
	<cfscript> sleep(500);</cfscript>
	
	<!--- decide if cancel or revise/revise-copy --->
	<cfif  lcase(variables.updateType) eq "cancel">
		<cfquery name="programsToCancel" datasource="#application.datasource#">
			Select distinct contract_main_ID, Notes from Mass_Program_Change_Header where skip = 0 and complete = 0
		</cfquery>
		
		<cfloop query="programsToCancel">
			<!--- program settings --->
			<cfset programsettings =  program.getprogramsettings(programsToCancel.contract_main_ID)>
			
			<cfset temp = program.cancelProgram(
					programId = programsToCancel.contract_main_ID,
					userId = url.user_ID,
					cancelallprogramversions = appSettings.getcancelallprogramversions(),
					Date_Exclusions_ON = programsettings.Date_Exclusions_ON,
					IS_Date_Exclusions_child = 0,
					cancelOption = 0
					) />
					
			<cfquery name="updateProgramNotes" datasource="#application.datasource#">
				UPDATE	Contract_Main
				SET 	Notes =  <cfqueryparam value="#programsToCancel.notes#" cfsqltype="cf_sql_varchar"> 
				WHERE 	contract_main_ID = <cfqueryparam value="#programsToCancel.contract_main_ID#" cfsqltype="cf_sql_integer">
			</cfquery>				
			
		</cfloop>
					
	<cfelse>
	
		<!--- procedure to run the mass revise/copy --->
		<cfstoredproc procedure="USP_Mass_Program_Copy_Revise" datasource="#application.datasource#" >
			<cfprocresult  name = "qProcessed" />
		</cfstoredproc>
		<!---if the lock type is not Do not lock and the program has claim mechanics with locks on...
			then set the program lock type id in contract_main_aux_data--->
		<cfloop query="qProcessed">
			<cfset Contract_Main_ID = qProcessed.Contract_Main_ID/>
			<cfset programManager.setProgramLockType(Contract_Main_ID) />
		</cfloop>
		<!--- DO WE NEED THIS SINCE THE PROC IS RETURNING DATA --->
		<cfscript> Sleep(30000);</cfscript>
	
	</cfif>
	<!---  --->
	<cfcatch>
		<!--- TODO: Notify the user that the Upload Failed. Since this piece is run via scheduler,
			  we can not reply directly back --->

		<!--- copy the upload data into Log table --->
		<!--- truncate the upload data table --->
		<!--- truncate the error detail table --->
		<!--- reset the lock for the upload utility --->
		<!--- remove the scheduled flag --->	  
		<cfset MPCUManager.processEnd() />
		
		<cfrethrow>
	</cfcatch>
</cftry>

<!--- copy the upload data into Log table --->
<!--- truncate the upload data table --->
<!--- truncate the error detail table --->
<!--- reset the lock for the upload utility --->
<!--- remove the scheduled flag --->
<cfset MPCUManager.processEnd() />


