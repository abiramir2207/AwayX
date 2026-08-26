<!------Formula_Price_Delete.cfm----->
<CFPARAM NAME="URL.RID" 	DEFAULT="">
<CFPARAM NAME="FORM.RID" 	DEFAULT="#URL.RID#">

<CFINCLUDE TEMPLATE="Paging_Retain_Old_Values.cfm">

<CFSET RID = Trim(FORM.EXISTING_RID)>
<CFIF Len(RID) GT 0>
	<CFLOOP LIST="#RID#" INDEX="This_RID">
			<CFTRANSACTION ACTION="BEGIN">
				<CFQUERY NAME="Inactivate_Rule" DATASOURCE="#application.datasource#">
					UPDATE	Formula_Pricing_Rule
					SET		Deleted = 0,
							Active_Code = 1
					WHERE
							Formula_Pricing_Rule_ID = '#This_RID#'
				</CFQUERY>
				
				<CFTRANSACTION ACTION="COMMIT">
			</CFTRANSACTION>		
	</CFLOOP>
</CFIF>
<CFPARAM NAME="URL.active" 	DEFAULT="true">
<CFPARAM NAME="FORM.active" 	DEFAULT="#URL.active#">
<CFLOCATION ADDTOKEN="No" URL="index.cfm?active=#FORM.active#">