<!---------------------------------------------------------------------
Use this template to check whether a user can pay this amount
once ths status is approved
BB_Validate_Pay_Amount.cfm
---------------------------------------------------------------------->
<cfinclude template="/get_access_profile.cfm">

<CFPARAM NAME="Amount_To_Pay" 	DEFAULT=0>
<CFPARAM NAME="Billback_ID" 	DEFAULT="">


<CFSET Can_Pay_Billback = 0>
<CFSET Cannot_Pay_Message = "">

<CFIF Billback_ID NEQ "">
	<CFQUERY  dataSource="#application.datasource#" NAME="Approved_Expected_Amount">
		SELECT 	Billback.BB_UP, Billback.BB_PNF, ISNULL(BB_Approved.Expected_Amount, 0) AS Expected_Amount, Billback_Status_ID
		FROM	Billback
				LEFT JOIN BB_Approved	
				ON
				(
					Billback.Billback_ID = BB_Approved.Billback_ID
					AND
					Billback.Billback_Status_ID = 3
				)
		WHERE	
				Billback.Billback_ID = '#Billback_ID#'
				AND
				Billback.Deleted = 0
	</CFQUERY>
	<CFIF Approved_Expected_Amount.RecordCount GT 0>
		<CFIF Approved_Expected_Amount.Billback_Status_ID EQ 3>
			<CFSET Payment_Difference = Amount_To_Pay - Approved_Expected_Amount.Expected_Amount>
			<CFIF (Approved_Expected_Amount.BB_UP EQ 1 OR Approved_Expected_Amount.BB_PNF EQ 1) AND Get_Profile_Settings.BB_Approve_Critical EQ 1>
			<!-------- can approve critical --------------->			
				<CFIF (Payment_Difference LTE Get_Profile_Settings.BB_Approve_Amount) OR (Get_Profile_Settings.BB_Approve_Amount EQ "*")>
					<CFSET Can_Pay_Billback = 1>
				<CFELSE>
					<CFSET Cannot_Pay_Message = "You are not authorized to pay this amount #DollarFormat(Amount_To_Pay)# for this billback">
				</CFIF>
			<CFELSEIF Approved_Expected_Amount.BB_UP EQ 0 AND Approved_Expected_Amount.BB_PNF EQ 0 AND Get_Profile_Settings.BB_Approve EQ 1>
				<CFIF (Payment_Difference LTE Get_Profile_Settings.BB_Approve_Amount) OR (Get_Profile_Settings.BB_Approve_Amount EQ "*")>
					<CFSET Can_Pay_Billback = 1>
				<CFELSE>
					<CFSET Cannot_Pay_Message = "You are not authorized to pay this amount #DollarFormat(Amount_To_Pay)# for this billback">
				</CFIF>
			<CFELSE>
				<CFSET Cannot_Pay_Message = "You are not authorized to pay this billback">
			</CFIF>
		<CFELSE>
			<CFSET Cannot_Pay_Message = "You can pay a billback only if the status is approved">
		</CFIF>
	<CFELSE>
		<CFSET Cannot_Pay_Message = "Could not find the billback">
	</CFIF>
</CFIF>



