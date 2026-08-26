<cfset Permit_Approval = 0>

<cfif Get_Profile_Settings.BB_Pay_Req_Approval_Amount NEQ "*">
	<cfif Get_data.Tot_Amount LTE Get_Profile_Settings.BB_Pay_Req_Approval_Amount>
		<cfset Permit_Approval = 1>	
	<cfelse>
		<cfset Permit_Approval = 0>
	</cfif>
<cfelse>
	<cfset Permit_Approval = 1>
</cfif>