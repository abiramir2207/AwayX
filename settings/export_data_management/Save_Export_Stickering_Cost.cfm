<cfparam name="form.txtAddLookupStickeringCostsLB" default="">
<cfparam name="form.txtAddLookupStickeringCostsDesc" default="">

<cfoutput>
	<cfloop collection="#Form#" item="i">
		<cfset Export_Stickering_Cost_ID = Mid(i, Find("_",i)+ 1,len(i))>
		<cfif Left(i,28) eq "TxtLookupStickeringCostsDesc">
				<CFQUERY NAME="UpdCosts" datasource="#application.datasource#">
					UPDATE Export_Lookup_Stickering_Cost
					SET Export_Stickering_Cost_LB = '#val(Evaluate("txtLookupStickeringCostsLB_"&Export_Stickering_Cost_ID))#'
					WHERE Export_Stickering_Cost_ID = '#Export_Stickering_Cost_ID#'
				</CFQUERY>
			</cfif>
	</cfloop>

	<cfif Trim(form.txtAddLookupStickeringCostsDesc) neq "" AND Trim(form.txtAddLookupStickeringCostsLB) neq "">		
				<CFQUERY NAME="GetMaxID" datasource="#application.datasource#">
					SELECT MAX(Export_Stickering_Cost_ID) + 1 As Export_Stickering_Cost_ID
					FROM Export_Lookup_Stickering_Cost
				</CFQUERY>

				<CFQUERY NAME="InsCosts" datasource="#application.datasource#">
					INSERT INTO Export_Lookup_Stickering_Cost(Export_Stickering_Cost_ID,Export_Stickering_Cost_Desc,Export_Stickering_Cost_LB)
					VALUES('#GetMaxID.Export_Stickering_Cost_ID#','#form.txtAddLookupStickeringCostsDesc#','#val(form.txtAddLookupStickeringCostsLB)#')
				</CFQUERY>
	</cfif>
</cfoutput>

<cflocation url="index.cfm?Action=#Action#">