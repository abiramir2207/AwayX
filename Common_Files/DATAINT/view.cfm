<style>
	.header{
		font-size:14px;
		font-weight:bold;
		text-align:left;
		background-color:#A5BAFF;
		float:left;
		}
</style>
<cfinclude template="/actionFormat.cfm">

	<cfquery name="details" datasource="#application.datasource#">
						SELECT DISTINCT Invoice_Number
			<cfif url.from EQ 'invoice'>
						FROM #URL.Log_CF_Header_Table#
						WHERE #Log_Distributor_Column# = '#url.CustomerNumber#'		
			<cfelseif url.from EQ 'item'>
						FROM #Log_CF_Detail_Table#
						WHERE #Log_Item_Column# = '#url.ItemNumber#'		
			</cfif>
						AND Created_Date BETWEEN '#startdate#' AND '#enddate#'	
	</cfquery>
	
	<cfoutput>
		<table border="0" width="500">
			<tr>
				<td colspan="3"  class="header">Invoice Numbers Associated with 
					<cfif url.from EQ 'invoice'>
						#application.returned_customer_setting.distributor_label_singular#(#url.CustomerNumber#) 
					<cfelseif url.from EQ 'item'>
						#application.returned_customer_setting.item_label#(#url.ItemNumber#)
					</cfif>	
				</td>
				<td style="font-size:14px;">
				<cfif url.from EQ 'invoice'>
						<a href="export.cfm?CustomerNumber=#url.CustomerNumber#&from=invoice&startdate=#startdate#&enddate=#enddate#&Log_CF_Header_Table=#Log_CF_Header_Table#&Log_CF_Detail_Table=#Log_CF_Detail_Table#&Log_Distributor_Column=#Log_Distributor_Column#">#ActionText("export")#</a>
				<cfelseif url.from EQ 'item'>
						<a href="export.cfm?ItemNumber=#url.ItemNumber#&from=item&startdate=#startdate#&enddate=#enddate#&Log_CF_Header_Table=#Log_CF_Header_Table#&Log_CF_Detail_Table=#Log_CF_Detail_Table#&Log_Item_Column=#Log_Item_Column#">#ActionText("export")#</a>
				</cfif>
				</td>
			</tr>
		</table>
		<table border="0" width="500">
			<tr>
				<cfloop query="details">
				<td style="font-size:12px;">
						#Invoice_Number#
				</td>
				<cfif details.CurrentRow MOD 3 EQ 0>
			</tr>				
				</cfif>
				</cfloop>
		</table>
	</cfoutput>
	
