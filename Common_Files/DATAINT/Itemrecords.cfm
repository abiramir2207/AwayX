<cfquery name="details" datasource="#application.datasource#">
		SELECT  BSA.Item, BSA.Description
		FROM log_cf_invoice_detail LOGS
		INNER JOIN BSA_Foodservice_Items_Master BSA
		ON BSA.Item = LOGS.ITEM_NUMBER
		WHERE LOGS.INVOICE_NUMBER IN (
										SELECT DISTINCT Invoice_Number
										FROM LOG_CF_Invoice_Header
										WHERE Customer_Number = '#url.CustomerNumber#'		
										AND LOGS.Created_Date BETWEEN '#url.startdate#' AND '#url.enddate#'					  
									  )	
</cfquery>
<style>
	.header{
		border:solid;
		border-width:1px;
		border-color:white;
		font-size:12px;
		font-weight:bold;
		width:490px;
		text-align:left;
		background-color:#A5BAFF;
		float:left;
		}
</style>
<div style="width:500px;height:500px;overflow-y:scroll;">
						<div class="header">
								
										<div style="float:left; width:150px; text-align:left;padding-top:3px;">
											<cfoutput>#application.returned_customer_setting.item_label#</cfoutput>
										</div>
										<div style="float:left; width:330px; text-align:left;padding-top:3px;">
											Description
										</div>
						
						</div>

			<div style="width:500px;clear:both;">
					<cfif details.recordcount>
							<cfoutput query="details">
									<div style="width:490px;">
														<div style="float:left; width:150px; text-align:left;padding-top:3px;">&nbsp;#item#&nbsp;</div>
														<div style="float:left; width:330px; text-align:left;padding-top:3px;">&nbsp;#description#&nbsp;</div>
									</div>
							</cfoutput>
					<cfelse>
									<div style="width:500px;text-align:center;font-weight:bold;">No Records!!</div>
					</cfif>
			</div>

</div>