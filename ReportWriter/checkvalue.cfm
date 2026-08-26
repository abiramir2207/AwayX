<CFPARAM NAME="Attributes.currentvalue"	DEFAULT="">
<CFPARAM NAME="getReport5.Contract_Title"	DEFAULT="">
<CFPARAM NAME="getReport5.Cust_Des"	DEFAULT="">

<cfswitch expression="#Attributes.currentvalue#">
	<cfcase value="Contract_Status_Type_Desc">
		<cfoutput>#caller.Contract_Status_Type_Desc#</cfoutput>
	</cfcase>
	<cfcase value="contract_number">
		<cfoutput>#getReport5.Contract_Title#</cfoutput>
	</cfcase>
	<cfcase value="cust_des">
		<cfoutput>#getReport5.Cust_Des#</cfoutput>
	</cfcase>
	<cfcase value="buying_name">
	
	</cfcase>
	<cfcase value="family_name">
	
	</cfcase>
</cfswitch> 
