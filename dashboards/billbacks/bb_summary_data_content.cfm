<br />

<!--- ----------------------------------------------------------------------------------------- --->
<cfinclude template="bb_summary_data_content_sql.cfm">
<!--- ----------------------------------------------------------------------------------------- --->


<style>
a.links
{ color:#ffffff; text-decoration:none;}
</style>


<!--- ----------------------------------------------------------------------------------------- --->
<style>
th
{
		text-align:				left;
		border-bottom:			4px green solid;
		padding-bottom:			3px;
		vertical-align:			bottom;
}
</style>
<!--- ----------------------------------------------------------------------------------------- --->



<cfset column_width=100>

<cfoutput>
<table cellspacing="0" cellpadding="0" border="0" width="925" align="center">

	<tr>
		<td></td>
		<td class="data_grid_header" colspan="2" width="225">Monthly</td>
		<td class="data_grid_header" colspan="2" width="225">Quarterly</td>
		<td class="data_grid_header" colspan="2" width="225">Year to Date</td>
	</tr>
	<tr>
		<td class="data_grid_header">&nbsp;</td>
		<td class="data_grid_header" width="#column_width#">9/2011</td>
		<td class="data_grid_header" width="#column_width#">SPLY</td>
		<td class="data_grid_header" width="#column_width#">Q3 2011</td>
		<td class="data_grid_header" width="#column_width#">SPLY</td>
		<td class="data_grid_header" width="#column_width#">1/2011 - 9/2011</td>
		<td class="data_grid_header">SPLY</td>
	</tr>
	
	<tr>
		<td colspan="100%">&nbsp;&nbsp;</td>
	</tr>

	
	
	<tr>
		<td class="data_grid_level1" colspan="100%" style="padding-top:20px;">Overall Process</td>
	</tr>

  <tr bgcolor="##373737">
    <td class="grid_data"><a class="links" href="display.cfm?content=80237186"><img src="images/link_small.png" hspace="10" border="0">Total <CFOUTPUT>#label.invoice.plural#</CFOUTPUT> Processed</a></td>
    <td class="grid_data"><cfoutput>#numberformat(monthly.invoices_processed_count,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(7482,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(quarterly.invoices_processed_count,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(23181.73,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(yearly.invoices_processed_count,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(63310.8135,'9,999,999,999')#</cfoutput></td>
  </tr>
  <tr bgcolor="##222222">
    <td class="grid_data"><a class="links" href="display.cfm?content=13048838"><img src="images/link_small.png" hspace="10" border="0" border="0">Dollars processed: Total</a></td>
    <td class="grid_data"><cfoutput>$#numberformat(monthly.dollars_processed_total/1000,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(24185646/1000,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(quarterly.dollars_processed_total/1000,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(69728333/1000,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(yearly.dollars_processed_total/1000,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(186888439/1000,'9,999,999,999')#</cfoutput></td>
  </tr>
  <tr bgcolor="##373737">
    <td class="grid_data"><a class="links" href="display.cfm?content=63324230"><img src="images/link_small.png" hspace="10" border="0">Dollars processed: Off Invoice</a></td>
    <td class="grid_data"><cfoutput>$#numberformat(monthly.dollars_processed_off_invoice/1000,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(7776615/1000,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(quarterly.dollars_processed_off_invoice/1000,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(26206232/1000,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(yearly.dollars_processed_off_invoice/1000,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(80633867/1000,'9,999,999,999')#</cfoutput></td>
  </tr>
  <tr bgcolor="##222222">
    <td class="grid_data"><a class="links" href="display.cfm?content=19392811"><img src="images/link_small.png" hspace="10" border="0">Dollars processed: <CFOUTPUT>#label.billback.singular#</CFOUTPUT></a></td>
    <td class="grid_data"><cfoutput>$#numberformat(monthly.dollars_processed_billback/1000,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(13841631/1000,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(quarterly.dollars_processed_billback/1000,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(44568026/1000,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(yearly.dollars_processed_billback/1000,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(133514800/1000,'9,999,999,999')#</cfoutput></td>
  </tr>
  <tr bgcolor="##373737">
    <td class="grid_data"><a class="links" href="display.cfm?content=21426439"><img src="images/link_small.png" hspace="10" border="0">Dollars processed: Average dollars per <CFOUTPUT>#label.billback.singular#</CFOUTPUT></a></td>
    <td class="grid_data"><cfoutput>$#numberformat(monthly.dollars_processed_avg_per_billback,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(2035,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(quarterly.dollars_processed_avg_per_billback,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(2115,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(yearly.dollars_processed_avg_per_billback,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(1963,'9,999,999,999')#</cfoutput></td>
  </tr>
  <tr bgcolor="##222222">
    <td class="grid_data"><a class="links" href="display.cfm?content=11726525"><img src="images/link_small.png" hspace="10" border="0">Average line items per <CFOUTPUT>#label.invoice.singular#</CFOUTPUT></a></td>
    <td class="grid_data"><cfoutput>#numberformat(monthly.avg_count_items_per_invoice,'9,999,999,999.9')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(25.7,'9,999,999,999.9')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(monthly.avg_count_items_per_invoice,'9,999,999,999.9')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(23.8,'9,999,999,999.9')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(monthly.avg_count_items_per_invoice,'9,999,999,999.9')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(24.3,'9,999,999,999.9')#</cfoutput></td>
  </tr>

	<tr><tdcolspan="100%">&nbsp;&nbsp;</td></tr>
  <tr>
    <td class="data_grid_level1" colspan="100%" style="padding-top:20px;">Discrepancy</td>
  </tr>

  <tr bgcolor="##222222">
    <td class="grid_data"><a class="links" href="display.cfm?content=46718543"><img src="images/link_small.png" hspace="10" border="0">Discrepancy: <CFOUTPUT>#label.invoice.plural#</CFOUTPUT> with disprepancy &gt;0</a></td>
    <td class="grid_data"><cfoutput>#numberformat(monthly.discrepancy_invoices,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(0,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(quarterly.discrepancy_invoices,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(0,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(yearly.discrepancy_invoices,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(0,'9,999,999,999')#</cfoutput></td>
  </tr>
  <tr bgcolor="##373737">
    <td class="grid_data"><a class="links" href="display.cfm?content=84084061"><img src="images/link_small.png" hspace="10" border="0">Discrepancy:Total discrepancy dollars</a></td>
    
    <td class="grid_data"><cfoutput>$#numberformat(monthly.discrepancy_total_dollars/1000,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(1044403/1000,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(quarterly.discrepancy_total_dollars/1000,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(3068694/1000,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(yearly.discrepancy_total_dollars/1000,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>$#numberformat(10012378/1000,'9,999,999,999')#</cfoutput></td>
  </tr>
  <tr bgcolor="##222222">
    <td class="grid_data"><a class="links" href="display.cfm?content=12441663"><img src="images/link_small.png" hspace="10" border="0">Discrepancy: Dollars as % of total <CFOUTPUT>#label.billback.singular#</CFOUTPUT> dollars</a></td>
    <td class="grid_data"><cfoutput>#numberformat(monthly.discrepancy_dollars_as_percent,'9,999,999,999')#%</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(10.70,'9,999,999,999')#%</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(quarterly.discrepancy_dollars_as_percent,'9,999,999,999')#%</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(8.21,'9,999,999,999')#%</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(yearly.discrepancy_dollars_as_percent,'9,999,999,999')#%</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(10.56,'9,999,999,999')#%</cfoutput></td>
  </tr>
  <tr bgcolor="##373737">
    <td class="grid_data"><a class="links" href="display.cfm?content=11507173"><img src="images/link_small.png" hspace="10" border="0">Deduction days outstanding</a></td>
    <td class="grid_data"><cfoutput>#numberformat(monthly.deduction_days_outstanding,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(22,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(quarterly.deduction_days_outstanding,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(21,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(yearly.deduction_days_outstanding,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(22,'9,999,999,999')#</cfoutput></td>
  </tr>

	<tr><tdcolspan="100%">&nbsp;&nbsp;</td></tr>
  <tr>
    <td class="data_grid_level1" colspan="100%" style="padding-top:20px;">Cycle Time</td>
  </tr>

  <tr bgcolor="##222222">
    <td class="grid_data"><a class="links" href="display.cfm?content=58244118"><img src="images/link_small.png" hspace="10" border="0">Cycle Time - Created to Paid</a></td>
    <td class="grid_data"><cfoutput>#numberformat(monthly.cycle_time_created_to_paid,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(6,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(quarterly.cycle_time_created_to_paid,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(8,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(yearly.cycle_time_created_to_paid,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(6,'9,999,999,999')#</cfoutput></td>
  </tr>
  <tr bgcolor="##373737">
    <td class="grid_data"><a class="links" href="display.cfm?content=29833828"><img src="images/link_small.png" hspace="10" border="0">Cycle Time - Performance End to Paid</a></td>
    <td class="grid_data"><cfoutput>#numberformat(monthly.cycle_time_end_to_paid,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(29,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(quarterly.cycle_time_end_to_paid,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(26,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(yearly.cycle_time_end_to_paid,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(34,'9,999,999,999')#</cfoutput></td>
  </tr>

	<tr><tdcolspan="100%">&nbsp;&nbsp;</td></tr>
  <tr>
    <td class="data_grid_level1" colspan="100%" style="padding-top:20px;">Payment Type</td>
  </tr>

  <tr bgcolor="##222222">
    <td class="grid_data"><a class="links" href="display.cfm?content=58986677"><img src="images/link_small.png" hspace="10" border="0">Payment Type - Check</a></td>
    <td class="grid_data"><cfoutput>#numberformat(monthly.payment_type_check,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(3080,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(quarterly.payment_type_check,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(9505,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(yearly.payment_type_check,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(23425,'9,999,999,999')#</cfoutput></td>
  </tr>
  <tr bgcolor="##373737">
    <td class="grid_data"><a class="links" href="display.cfm?content=97220806"><img src="images/link_small.png" hspace="10" border="0">Payment Type - Deduction</a></td>
    <td class="grid_data"><cfoutput>#numberformat(monthly.payment_type_deduction,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(1496,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(quarterly.payment_type_deduction,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(4922,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(yearly.payment_type_deduction,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(15195,'9,999,999,999')#</cfoutput></td>
  </tr>
  <tr bgcolor="##222222">
    <td class="grid_data"><a class="links" href="display.cfm?content=34309355"><img src="images/link_small.png" hspace="10" border="0">Payment Type - AT</a></td>
    <td class="grid_data"><cfoutput>#numberformat(monthly.payment_type_at,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(2881,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(quarterly.payment_type_at,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(7917,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(yearly.payment_type_at,'9,999,999,999')#</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(26936,'9,999,999,999')#</cfoutput></td>
  </tr>

	<tr><tdcolspan="100%">&nbsp;&nbsp;</td></tr>
  <tr>
    <td class="data_grid_level1" colspan="100%" style="padding-top:20px;">Entry Type</td>
  </tr>

  <tr bgcolor="##373737">
    <td class="grid_data"><a class="links" href="display.cfm?content=99833999"><img src="images/link_small.png" hspace="10" border="0">Entry Type - EDI</a></td>
    <td class="grid_data"><cfoutput>#numberformat(monthly.entry_type_edi,'9,999,999,999')#%</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(42.90,'9,999,999,999')#%</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(quarterly.entry_type_edi,'9,999,999,999')#%</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(38.50,'9,999,999,999')#%</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(yearly.entry_type_edi,'9,999,999,999')#%</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(37.20,'9,999,999,999')#%</cfoutput></td>
  </tr>
  <tr bgcolor="##222222">
    <td class="grid_data"><a class="links" href="display.cfm?content=67481702"><img src="images/link_small.png" hspace="10" border="0">Entry Type - eInvoice</a></td>
    <td class="grid_data"><cfoutput>#numberformat(monthly.entry_type_einvoice,'9,999,999,999')#%</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(6.60,'9,999,999,999')#%</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(quarterly.entry_type_einvoice,'9,999,999,999')#%</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(5.20,'9,999,999,999')#%</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(yearly.entry_type_einvoice,'9,999,999,999')#%</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(6.00,'9,999,999,999')#%</cfoutput></td>
  </tr>
  <tr bgcolor="##373737">
    <td class="grid_data"><a class="links" href="display.cfm?content=82909819"><img src="images/link_small.png" hspace="10" border="0">Entry Type - Manual</a></td>
    <td class="grid_data"><cfoutput>#numberformat(monthly.entry_type_manual,'9,999,999,999')#%</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(67.10,'9,999,999,999')#%</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(quarterly.entry_type_manual,'9,999,999,999')#%</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(78.00,'9,999,999,999')#%</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(yearly.entry_type_manual,'9,999,999,999')#%</cfoutput></td>
    <td class="grid_data"><cfoutput>#numberformat(83.20,'9,999,999,999')#%</cfoutput></td>
  </tr>
</table>
</cfoutput>


<br />

<!--- ----------------------------------------------------------------------------------------- --->
<cfinclude template="sply_note.cfm">
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js"></script>
<script type="text/javascript" src="../javascript/jquery.tablescroll.js"></script>
<script>
	/*<![CDATA[*/
	jQuery(document).ready(function($)
	{
		$('#thetable').tableScroll({height:400});
	});
	/*]]>*/
</script>
<!--- ----------------------------------------------------------------------------------------- --->