<cfif isdefined("form.delete_recid")>
	<CFQUERY NAME="deleteRecords" datasource="#application.datasource#">
		DELETE
		FROM deduction_market_to_user
		WHERE deduction_market_to_user_ID IN(#form.delete_recid#)
	</CFQUERY>
</cfif>


<CFLOOP INDEX="fieldName" LIST="#FORM.FIELDNAMES#">
	<cfset localuser_id = evaluate(fieldname)>
	
	<cfif lcase(right(fieldName,4)) EQ "user">
		<cfset record_id 	= evaluate("#mid(fieldName, 1, len(fieldName)-5)#_recid")>
		<cfset marketarea	= evaluate("#mid(fieldName, 1, len(fieldName)-5)#_market")>
		<!--- not a new record --->
		<cfif record_id NEQ 0>
			<cfquery name="getMarketRecord" datasource="#application.datasource#">
				SELECT *
				FROM deduction_market_to_user
				WHERE deduction_market_to_user_id = '#record_id#'
			</cfquery>
		
			<cfquery name="updateInfo" datasource="#application.datasource#">
				UPDATE deduction_market_to_user
				SET 
					User_ID = '#localuser_id#',
					Market_Area_ID = '#marketarea#',
					Setting_Last_Updated = getdate()
				WHERE deduction_market_to_user_id = '#record_id#'
			</cfquery>			
			
		<CFELSE>
				<cfquery name="saveMarketAreaAssignments" datasource="#application.datasource#">
					INSERT INTO deduction_market_to_user
					(User_ID, Market_Area_ID, Company_Main_ID, Setting_Last_Updated)
					VALUES
					('#localuser_id#','#marketarea#','#request.AccessStructure.Company_Main_ID#', getdate())
				</cfquery>			
		</cfif>
	
	</cfif>
</cfloop>
					<!--- WHERE Market_Area = '#evaluate("#mid(fieldName, 1, len(fieldName)-5)#_market")#' --->

<cflocation url="deduction_market_to_user.cfm?ID=#createuuid()#">
