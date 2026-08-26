<cfset objProgram = CreateObject("component", "components.programs.program") />

<cfset BatchNumber = objProgram.getMaxEntryForContractEndDateChangeHistory()>

		<!--- Loop through the form --->
		<cfloop index="FieldName" list="#FORM.FieldNames#">

			<!--- This is the form field which stores the modified program end date--->
			<cfif (FindNoCase("txtEndDate_",FieldName) NEQ 0)>

				<!--- Extract program end date --->
				<cfset ProgramEndDate = Evaluate(FieldName)>

				<cfif ProgramEndDate neq "">
					<cfset FirstDashPosition = FindNoCase("_",FieldName)>
					<cfset SecondDashPosition = FindNoCase("_",FieldName,12)>
					
					<!--- Extract program id --->
					<cfset ProgramID = Mid(FieldName,12,(SecondDashPosition - FirstDashPosition - 1))>
					
					<!--- Extract contract number --->
					<cfset ContractNumber = Evaluate('Contract_Number_Short_Version_'&ProgramID)>
					
					<!--- Extract orginal program end date --->
					<cfset ProgramOriginalEndDate = Evaluate('txtOriginalEndDate_'&ProgramID)>

					<!--- Log "end date" change. --->
					<cfset objProgram.updProgramEndDate(ProgramID, ContractNumber, request.AccessStructure.User_ID, ProgramOriginalEndDate, ProgramEndDate, BatchNumber)>
				</cfif>
			</cfif>
		</cfloop>

<!--- "Contract_Main_ID_List" is the variable used to display programs. "Contract_Main_ID_List" is the selected list of programs in CF.
"display_type=1" takes the user back to the "delete pre-active dates" tool."
--->
<cflocation url="index.cfm?Contract_Main_ID_List=#selectedItems#&display_type=1">