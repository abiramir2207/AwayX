
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Save the session expiration data																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Dev Note: (WR 74707)
<cfif application.returned_customer_setting.Customer_Keyword eq "smithfield">
	<cfset Form.Inactivity_Period = 1000000>
</cfif>
 --->
<!--- If the users do not want session expiration in place, make the window really big: 1,000,000 days --->
<CFIF Session_Management_Status EQ 0>
	<CFSET Form.Inactivity_Period=1000000>
</CFIF>

<CFQUERY NAME="Session_Expire" datasource="#application.datasource#">
	Update	General_Settings
	Set		Session_Expiration_Length	=	'#Form.Inactivity_Period#',
			Session_Expiration_Changed_By	=	'#request.AccessStructure.User_ID#',
			Session_Expiration_Last_Changed_Date	=	#now()#
</CFQUERY>

<CFLOCATION URL="session_management.cfm" ADDTOKEN="No">
