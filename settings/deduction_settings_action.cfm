<cfif isnumeric(FORM.deduction_aging_range)>
	<cfif FORM.up_sv EQ 0>
		<CFQUERY NAME="INSERT" datasource="#application.datasource#">
			INSERT INTO _Users_Settings
			(deduction_aging_range, User_ID, deduction_AGING_RANGE_Date_Updated)
			VALUE
			('#int(FORM.deduction_aging_range)#', '#request.AccessStructure.Company_Main_ID#', #createodbcdatetime(Now())#)
		</CFQUERY>
	
	<cfelse>
		<CFQUERY NAME="UPDATE" datasource="#application.datasource#">
			UPDATE _Users_Settings
			SET deduction_aging_range = '#int(FORM.deduction_aging_range)#', deduction_AGING_RANGE_Date_Updated = #createodbcdatetime(Now())#
			WHERE User_ID = '#request.AccessStructure.Company_Main_ID#'
		</CFQUERY>
	</cfif>
</cfif>


<CFLOCATION URL="deduction_settings.cfm?ID=#createuuid()#" ADDTOKEN="No"> 