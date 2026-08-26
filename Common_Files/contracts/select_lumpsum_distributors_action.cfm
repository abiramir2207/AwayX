<!------ select_lumpsum_distributors_action.cfm ----->

<cfparam name="FORM.CID" 	default="">
<cfparam name="FORM.Program_ID" 	default="">
<cfparam name="FORM.Program_Lump_Sum_ID" 	default="">
<cfparam name="FORM.Lumpsum_Distributors" 	default="">

<cfif form.deletedateexclusions EQ 1>
<cfquery name="GetSettings" datasource="#application.datasource#">

	SELECT 	Program_Control_Panel_Options.Date_Exclusions_ON
	FROM 	Program_Control_Panel_Options
			INNER JOIN Contract_Main ON 
			Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
	WHERE 	Contract_Main_ID = #form.program_id#
	
</cfquery>

<cfif GetSettings.Date_Exclusions_ON EQ 1>
			<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />	
			<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(form.program_id,0)>
		<cfif form.deletedateexclusions EQ 1>
			<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
			<cfquery name="deletedateexclusions" datasource="#application.datasource#">
				update contract_main
				set deleted = 1
				where contract_main_id in (#valuelist(getDateExclusionprogramIDs.revision_program_id)#)
			</cfquery>
			<cfquery name="deletedateexclusions" datasource="#application.datasource#">
				update program_exclusions
				set deleted = 1
				where revision_program_id in (#valuelist(getDateExclusionprogramIDs.revision_program_id)#)
			</cfquery>
			</CFIF>
		</cfif>
</cfif>
</cfif>

<cfif isNumeric(FORM.Program_ID) AND Len(FORM.Program_Lump_Sum_ID) GT 0>
	<cftransaction action="BEGIN" isolation="READ_COMMITTED">
	
		<cftry>
		
			<!------ Delete Existing ----->
			<cfquery name="qDeleteExisting" datasource="#application.datasource#">
				UPDATE	Program_Lump_Sum_Distributor
				SET		Deleted = 1
				WHERE	Deleted = 0
				AND		Program_ID = #FORM.Program_ID#
				AND		Program_Lump_Sum_ID = '#FORM.Program_Lump_Sum_ID#'
			</cfquery>
			
			<cfloop list="#FORM.Lumpsum_Distributors#" index="thisDistID">
				<!------ Insert records ----->
				<cfquery name="qInsertLumpDist" datasource="#application.datasource#">
					INSERT INTO Program_Lump_Sum_Distributor (Program_ID, Program_Lump_Sum_ID, Distributor_ID)
					VALUES (#FORM.Program_ID#, '#FORM.Program_Lump_Sum_ID#', '#thisDistID#')
				</cfquery>
			</cfloop>
		
			<cfcatch>
				<cftransaction action="COMMIT" />
				<cfrethrow />
			</cfcatch>
		
		</cftry>
		
		<cftransaction action="COMMIT" />
	
	</cftransaction>
	
</cfif>

<cflocation addtoken="No" url="Contract_Discount_Lump_Sums.cfm?CID=#FORM.CID#" />
