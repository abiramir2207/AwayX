<cfset objProgram = CreateObject("component", "components.programs.program") />

<cfset BatchNumber = objProgram.getMaxEntryForContractStartDateChangeHistory()>

		<!--- Loop through the form --->
		<cfloop index="FieldName" list="#FORM.FieldNames#">
			<!--- This is the form field which stores the modified program start date--->
			<cfif (FindNoCase("txtStartDate_",FieldName) NEQ 0)>

				<!--- Extract program start date --->
				<cfset ProgramStartDate = Evaluate(FieldName)>

				<cfif ProgramStartDate neq "">
					<!--- Extract program id --->
					<cfset ProgramID = Mid(FieldName,14,len(FieldName))>
					
					<cfset ContractNumber = Evaluate('Contract_Number_Short_Version_'&ProgramID)>
					
					<!--- Extract orginal program start date --->
					<cfset ProgramOriginalStartDate = Evaluate('txtOriginalStartDate_'&ProgramID)>

					<!--- Log "start date" change. --->
					<cfset objProgram.updProgramStartDate(ProgramID, ContractNumber, request.AccessStructure.User_ID, ProgramOriginalStartDate, ProgramStartDate, BatchNumber)>
				</cfif>
			</cfif>
		</cfloop>

<!--- "Contract_Main_ID_List" is the variable used to display programs. "Contract_Main_ID_List" is the selected list of programs in CF. 
"display_type=0" takes the user back to the "modify pre-active dates" tool."
--->
<cflocation url="index.cfm?Contract_Main_ID_List=#selectedItems#&display_type=0">