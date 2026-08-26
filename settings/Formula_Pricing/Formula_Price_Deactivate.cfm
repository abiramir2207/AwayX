<!------Formula_Price_Delete.cfm----->
<CFPARAM NAME="URL.RID" 	DEFAULT="">
<CFPARAM NAME="FORM.RID" 	DEFAULT="#URL.RID#">

<CFINCLUDE TEMPLATE="Paging_Retain_Old_Values.cfm">

<CFSET RID = Trim(FORM.EXISTING_RID)>
<CFIF Len(RID) GT 0>
	<CFLOOP LIST="#RID#" INDEX="This_RID">
		<CFQUERY NAME="Program_Exists" DATASOURCE="#application.datasource#">
			SELECT Formula_Pricing_Rule.Active_Code
			FROM 	Formula_Pricing_Rule
			WHERE 
					Formula_Pricing_Rule.Formula_Pricing_Rule_ID = '#This_RID#'
		</CFQUERY>
		<CFSET Can_DeActivate_Formula = 0>
		<CFIF Program_Exists.Active_Code EQ 1>
			<CFSET Can_DeActivate_Formula = 1>
		</CFIF>
		<CFIF Can_DeActivate_Formula>
			<CFTRANSACTION ACTION="BEGIN">
				<CFQUERY NAME="Inactivate_Rule" DATASOURCE="#application.datasource#">
					UPDATE	Formula_Pricing_Rule
					SET		Active_Code = 0
					WHERE
							Formula_Pricing_Rule_ID = '#This_RID#'
				</CFQUERY>
				<CFTRANSACTION ACTION="COMMIT">
			</CFTRANSACTION>		
		</CFIF>
	</CFLOOP>
</CFIF>
<CFPARAM NAME="URL.active" 	DEFAULT="true">
<CFPARAM NAME="FORM.active" 	DEFAULT="#URL.active#">
<CFLOCATION ADDTOKEN="No" URL="index.cfm?active=#FORM.active#">