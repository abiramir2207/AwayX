<cfsetting enablecfoutputonly=true>
<cfif form.paid_to  eq "operator">
	<cfquery name="qGetSelectedPaidTo" datasource="#application.datasource#">
		SELECT 	DISTINCT
						BO.BSA_Operator_ID as BSA_ID,
						ISNULL(BO.Legacy_ID,BO.BSA_Operator_ID) as ID,
						BO.Operator_Name as Name,
						BO.Operator_Address as Address_1,
						BO.Operator_City as City,
						BO.Operator_State as State,
						BO.Operator_Zip as zipcode
		FROM 	BSA_Operator BO
		WHERE BO.Deleted = 0
		AND		BO.BSA_Operator_ID IN (#ListQualify(form.paidToList,"'")#)
		ORDER BY BO.Operator_Name	
	</cfquery>	
<cfelse>
	<cfquery name="qGetSelectedPaidTo" datasource="#application.datasource#">
		SELECT 	DISTINCT
						C.BSA_Foodservice_Customers_ID as BSA_ID,
						C.Shr_Ship_To as ID,
						C.Name,
						C.Address_1,
						C.City,
						C.State,
						C.zipcode
		FROM 	BSA_Foodservice_Customers C
		WHERE C.Deleted = 0
		AND 	C.Active_Code = 'A'
		AND		C.BSA_Foodservice_Customers_ID IN (#ListQualify(form.paidToList,"'")#)
		ORDER BY C.Name	
	</cfquery>
</cfif>

<cfoutput><table cellpadding="5" cellspacing="2" style="width:100%">	</cfoutput>
	<cfoutput><tr valign="top" bgcolor="F2F2F2"></cfoutput>
		<cfset ListPosition = 0>
			<cfloop query="qGetSelectedPaidTo">
				<cfset ListPosition = ListPosition + 1>
				<!--- display distributors/operators --->
				<cfoutput><TD WIDTH="15%" VALIGN="top"></cfoutput>
				<cfoutput><FONT SIZE="1"></cfoutput>
				<cfoutput>#Name# [#ID#]<br /></cfoutput>
				<cfoutput>#Address_1#<br />#City#, #State# - #zipcode#</cfoutput>
				<cfoutput></font></cfoutput>
				<cfoutput></TD></cfoutput>
				<cfoutput><CFIF ListPosition MOD 6><CFELSE></tr><tr bgcolor="F2F2F2" valign="top"></CFIF></cfoutput>
			</cfloop>
	<cfoutput></tr></cfoutput>
<cfoutput></table></cfoutput>
<cfsetting enablecfoutputonly=false>
