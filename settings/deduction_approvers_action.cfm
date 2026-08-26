
<!--- <cfquery name="deleteData" datasource="#application.datasource#">
	DELETE FROM Deduction_Cost_Range_Assignments
</cfquery> --->

<cfloop index="fieldname" list="#form.fieldnames#">
	<cfif left(fieldname, 4) EQ "USER">
		<cfif listlen(fieldname, "_") EQ 3>
			<cfset user_id = listgetat(fieldname,3,"_")>
			<!--- update the data --->
			<cfif isdefined("FORM.#fieldname#_RECORDID")>
				<cfquery name="saveRange" datasource="#application.datasource#">
					UPDATE Deduction_Cost_Range_Assignments
					SET 
						User_ID = '#user_id#',
						Range_Min = '#evaluate("FORM.#fieldname#_RangeMin")#',
						Range_Max = '#evaluate("FORM.#fieldname#_RangeMax")#',
						Setting_Last_Updated = getdate()
					WHERE Deduction_Cost_Range_Assignment_ID = '#evaluate("FORM.#fieldname#_RECORDID")#'
				</cfquery>
			
			<!--- insert the data --->
			<cfelse>
				<!--- save the data --->
				<cfquery name="saveRange" datasource="#application.datasource#">
					INSERT INTO Deduction_Cost_Range_Assignments
					(User_ID,Range_Min,Range_Max,Setting_Last_Updated)
					VALUES
					('#user_id#', '#evaluate("FORM.#fieldname#_RangeMin")#', '#evaluate("FORM.#fieldname#_RangeMax")#',getdate())
				</cfquery>
			</cfif>
		</cfif>
	</cfif>
</cfloop>

<cflocation url="deduction_approvers.cfm?ID=#createuuid()#">