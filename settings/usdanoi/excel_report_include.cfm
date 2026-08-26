
<cfquery name="TheQuery2" dbtype="query">
	SELECT DISTINCT * FROM TheQuery ORDER BY  Operator_Name,  bsa_operator_id,BB_Date_Month_Number,BB_Date, Item, BB_Title
</cfquery>
			

<cfoutput query="TheQuery2">
<cfsilent>
<cfswitch expression="#lcase(url.ReportUOM)#">
				<cfcase value="1">
				<cfset uom_PTV 							= TheQuery2.PTV_CS>
				<cfset uom_PTV 							= trim(NumberFormat(uom_PTV, '______.____'))>
				<cfset uom_str = "&nbsp;cs">
				<cfset uom_PTV = TheQuery2.PTV_CS>
				<cfset uom_LastBBClaim	= TheQuery2.LastBBClaim_CS>
				</cfcase>
				<cfcase value="2">
				<cfset uom_PTV 							= TheQuery2.PTV_LB>
				<cfset uom_PTV 							= trim(NumberFormat(uom_PTV, '______.____'))>
				<cfset uom_str = "&nbsp;lbs">
				<cfset uom_PTV = TheQuery2.PTV_LB>
				<cfset uom_LastBBClaim	= TheQuery2.LastBBClaim_LB>
				</cfcase>
				<cfcase value="rm">
				<cfset uom_PTV 							= TheQuery2.PTV_RM>
				<cfset uom_PTV 							= trim(NumberFormat(uom_PTV, '______.____'))>
				<cfset uom_str = "&nbsp;lbs">
				<cfset uom_PTV = TheQuery2.PTV_RM>
				<cfset uom_LastBBClaim	 				= TheQuery2.LastBBClaim_LB / RM_Conversion_Value>
				</cfcase>
	</cfswitch>
	<cfset uom_cases						= TheQuery2.LastBBClaim_CS> 
	<cfset uom_ValueUsed					= uom_PTV*uom_LastBBClaim>
</cfsilent>
<tr>
					<td nowrap>#TheQuery2.Operator_Name#</td> 
					<td nowrap>#TheQuery2.Legacy_ID#</td>
					<td nowrap>#TheQuery2.bb_title#</td> 
					<td nowrap>#TheQuery2.bb_reference#</td> 
					<td nowrap>#dateformat(TheQuery2.bb_date,"mm/dd/yyyy")#</td>
					<td nowrap>#TheQuery2.item#</td> 
					<td nowrap>#TheQuery2.description#</td>
					 <td align="right">#trim(numberformat(uom_PTV, '___,___,___.____'))#</td>
					<td align="right">#trim(NumberFormat(uom_LastBBClaim, '-___,___,___,___,___'))##uom_str#</td>
					<td align="right">#trim(NumberFormat(uom_cases, '-___,___,___,___,___'))# cs</td>
					<td align="right">#trim(NumberFormat(uom_ValueUsed, '-$___,___,___,___,___.__'))#</td>	
</tr>
</cfoutput>
					
					
			