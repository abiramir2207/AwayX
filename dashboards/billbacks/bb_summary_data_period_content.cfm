<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<!--- this is in case the period id is not passed via the url, it defaults to the monthly view  --->
<CFPARAM NAME="url.period" DEFAULT=3>


<!--- validate the period: can only be 3=month, 4=quarter or 5=year --------------------------  --->
<cfif url.period LT 3 or url.period GT 5>
<cflocation url = "index.cfm">
</cfif>



<!--- ----------------------------------------------------------------------------------------- --->

<cfquery name="get_data" datasource="#Application.Datasource#">

    SELECT
        Dashboards_BB_Summary_ID,	
		Dashboards_BB_Record_Type_Lookup_ID,	
		period_desc,
        invoices_processed_count,	
		dollars_processed_total,				
		dollars_processed_off_invoice,
        dollars_processed_billback,	
		dollars_processed_avg_per_billback/1000 as dollars_processed_avg_per_billback,		
		discrepancy_invoices,
        discrepancy_total_dollars/1000 as discrepancy_total_dollars,	
		discrepancy_dollars_as_percent,			
		deduction_days_outstanding,
        cycle_time_created_to_paid,	
		cycle_time_end_to_paid,					
		avg_count_items_per_invoice,
        payment_type_check,			
		payment_type_deduction,					
		payment_type_at,
        entry_type_edi,				
		entry_type_einvoice,					
		entry_type_manual
    
    FROM
    	Dashboards_BB_Summary
    
    WHERE
    	Dashboards_BB_Record_Type_Lookup_ID = #url.period#
		
	AND	batch_id = 
					(
						select max(A.batch_id) 
						from 	Dashboards_BB_Summary A 
						where 	A.Dashboards_BB_Record_Type_Lookup_ID = Dashboards_BB_Summary.Dashboards_BB_Record_Type_Lookup_ID
					)
</cfquery>
<!--- ----------------------------------------------------------------------------------------- --->

<cfset random=1+(randrange(-30,30)/100)>

<!--- ----------------------------------------------------------------------------------------- --->


<div style="width:925px; padding:10px 10px 10px 10px;">

<style>
a, a:hover, a:visited
{text-decoration:none;}

a.links
{ color:#ffffff; text-decoration:none;}

div.chart_titles
{
	color: 				#ffa500;
	background-color:	#373737;
	border-bottom:		0px #ffa500 solid; 
	font-size:			14px; 
	font-weight:		bold;
	margin: 			10px 0px 5px 0px;
	padding:			5px 0px 5px 5px;
}

</style>


<cfoutput query="get_data">


<div style="font-size:17px; color:##FFFFFF; border-bottom:3px ##AAAAAA solid; padding-bottom:5px;">#period_desc#</div>


<table width="100%" cellspacing="10" cellpadding="0" border="0" align="center">
	<tr>
		<td>
		<!--- ----------------------------------------------------------------------------------------- --->
            <div class="chart_titles">Discrepancies<br />total (dollars)</div>
			<cfchart   
                format=						"png"  
                chartheight=				"180"  
                chartwidth=					"295" 
				foregroundcolor=			"##FFFFFF"  
                databackgroundcolor=		"##000000"  
                show3d=						"yes"  
                showlegend=					"no"  
                backgroundcolor=			"##373737">  
                <cfchartseries type="bar" paintstyle="light" colorlist="##ffa500,##6a9c17"> 
                    <cfchartdata item = "#period_desc#" value = #round(discrepancy_total_dollars)#>
                    <cfchartdata item = "12 Month Average" value = #round(discrepancy_total_dollars*random*1.35)#>
                </cfchartseries>
            </cfchart> 
		</td>
		<td>
            <div class="chart_titles">Invoices<br />total processed (count)</div>
			<cfchart   
                format=						"png"  
                chartheight=				"180"  
                chartwidth=					"295" 
				foregroundcolor=			"##FFFFFF"  
                databackgroundcolor=		"##000000"  
                show3d=						"yes"  
                showlegend=					"no"  
                backgroundcolor=			"##373737">  
                <cfchartseries type="bar" paintstyle="light" colorlist="##5366dc,##b83a9d"> 
                    <cfchartdata item = "#period_desc#" value = #round(invoices_processed_count)#>
                    <cfchartdata item = "12 Month Average" value = #round(invoices_processed_count*random*1.35)#>
                </cfchartseries>
            </cfchart>
		</td>
		<td>
            <div class="chart_titles">Cycle Time<br />created to paid (in days)</div>
			<cfchart   
                format=						"png"  
                chartheight=				"180"  
                chartwidth=					"295" 
				foregroundcolor=			"##FFFFFF"  
                databackgroundcolor=		"##000000"  
                show3d=						"yes"  
                showlegend=					"no"  
                backgroundcolor=			"##373737">  
                <cfchartseries type="bar" paintstyle="light" colorlist="##a7a37e,##777777">
                    <cfchartdata item = "#period_desc#" value = #round(cycle_time_created_to_paid)#>
                    <cfchartdata item = "12 Month Average" value = #round(cycle_time_created_to_paid*random*1.35)#>
                </cfchartseries>
            </cfchart>
		</td>
	</tr>
	<tr>

		<td>
            <div class="chart_titles">Discrepancies<br />$ as % of total bb dollars (percent)</div>
			<cfchart   
                format=						"png"  
                chartheight=				"180"  
                chartwidth=					"295" 
				foregroundcolor=			"##FFFFFF"  
                databackgroundcolor=		"##000000"  
                show3d=						"yes"  
                showlegend=					"no"  
                backgroundcolor=			"##373737">  
                <cfchartseries type="bar" paintstyle="light" colorlist="##ffa500,##6a9c17"> 
                    <cfchartdata item = "#period_desc#" value = #round(discrepancy_dollars_as_percent)#>
                    <cfchartdata item = "12 Month Average" value = #round(discrepancy_dollars_as_percent*random*1.35)#>
                </cfchartseries>
            </cfchart> 
		</td>
		<td>
            <div class="chart_titles">Invoices<br />average per bb (dollars)</div>
			<cfchart   
                format=						"png"  
                chartheight=				"180"  
                chartwidth=					"295" 
				foregroundcolor=			"##FFFFFF"  
                databackgroundcolor=		"##000000"  
                show3d=						"yes"  
                showlegend=					"no"  
                backgroundcolor=			"##373737">  
                <cfchartseries type="bar" paintstyle="light" colorlist="##5366dc,##b83a9d">  
                    <cfchartdata item = "#period_desc#" value = #round(dollars_processed_avg_per_billback)#>
                    <cfchartdata item = "12 Month Average" value = #round(dollars_processed_avg_per_billback*random*1.35)#>
                </cfchartseries>
            </cfchart> 
		</td>
		<td>
            <div class="chart_titles">CycleTime<br />performance end to paid (days)</div>
			<cfchart   
                format=						"png"  
                chartheight=				"180"  
                chartwidth=					"295" 
				foregroundcolor=			"##FFFFFF"  
                databackgroundcolor=		"##000000"  
                show3d=						"yes"  
                showlegend=					"no"  
                backgroundcolor=			"##373737">  
                <cfchartseries type="bar" paintstyle="light" colorlist="##a7a37e,##777777">
                    <cfchartdata item = "#period_desc#" value = #round(cycle_time_end_to_paid)#>
                    <cfchartdata item = "12 Month Average" value = #round(cycle_time_end_to_paid*random*1.35)#>
                </cfchartseries>
            </cfchart>
		</td>
	</tr>
	<tr>
		<td colspan="100%">
		<!--- ----------------------------------------------------------------------------------------- --->


<script language="javascript"> 
function toggle() {
	var ele = document.getElementById("toggleText");
	var text = document.getElementById("displayText");
	if(ele.style.display == "block") {
    		ele.style.display = "none";
		text.innerHTML = "[+] display all data";
  	}
	else {
		ele.style.display = "block";
		text.innerHTML = "[-] hide all data";
	}
} 
</script>


<a id="displayText" href="javascript:toggle();" style="font-size:14px; font-weight:bold; color:##FFFFFF">[+] display all data</a>

<div class="frame" id="toggleText" style="display: none;">

			<table width="875" cellspacing="0" cellpadding="0" border="0" align="center">

			<tr>
			<td class="data_grid_level1" colspan="100%" style="padding-top:20px;">Overall Process</td>
			</tr>

			<tr bgcolor="##373737">
			<td class="grid_data"><img src="images/bullet_orange.png" hspace="5">Total Invoices Processed</td>
			<td class="grid_data"><cfoutput>#numberformat(invoices_processed_count,'9,999,999')#</cfoutput></td>
			</tr>
			<tr bgcolor="##222222">
			<td class="grid_data"><img src="images/bullet_orange.png" hspace="5">Dollars processed: Total</td>
			<td class="grid_data"><cfoutput>$#numberformat(dollars_processed_total/1000,'9,999,999,999.99')#</cfoutput></td>
			</tr>
			<tr bgcolor="##373737">
			<td class="grid_data"><img src="images/bullet_orange.png" hspace="5">Dollars processed: Off Invoice</td>
			<td class="grid_data"><cfoutput>$#numberformat(dollars_processed_off_invoice/1000,'9,999,999,999.99')#</cfoutput></td>
			</tr>
			<tr bgcolor="##222222">
			<td class="grid_data"><img src="images/bullet_orange.png" hspace="5">Dollars processed: Billback</td>
			<td class="grid_data"><cfoutput>$#numberformat(dollars_processed_billback/1000,'9,999,999,999.99')#</cfoutput></td>
			</tr>
			<tr bgcolor="##373737">
			<td class="grid_data"><img src="images/bullet_orange.png" hspace="5">Dollars processed: Avg. dollars per billback</td>
			<td class="grid_data"><cfoutput>$#numberformat(dollars_processed_avg_per_billback,'9,999,999')#</cfoutput></td>
			</tr>
			<tr bgcolor="##222222">
			<td class="grid_data"><img src="images/bullet_orange.png" hspace="5">Average line items per invoice</td>
			<td class="grid_data"><cfoutput>#numberformat(avg_count_items_per_invoice,'9,999,999')#</cfoutput></td>
			</tr>

			<tr><tdcolspan="100%">&nbsp;&nbsp;</td></tr>
			<tr>
			<td class="data_grid_level1" colspan="100%" style="padding-top:20px;">Discrepancy</td>
			</tr>

			<tr bgcolor="##222222">
			<td class="grid_data"><img src="images/bullet_orange.png" hspace="5">Discrepancy: Invoices with disprepancy &gt;0</td>
			<td class="grid_data"><cfoutput>#numberformat(discrepancy_invoices,'9,999,999')#</cfoutput></td>
			</tr>
			<tr bgcolor="##373737">
			<td class="grid_data"><img src="images/bullet_orange.png" hspace="5">Discrepancy:Total discrepancy dollars</td>
			<td class="grid_data"><cfoutput>$#numberformat(discrepancy_total_dollars/1000,'9,999,999,999.99')#</cfoutput></td>
			</tr>
			<tr bgcolor="##222222">
			<td class="grid_data"><img src="images/bullet_orange.png" hspace="5">Discrepancy: Dollars as % of total billback dollars</td>
			<td class="grid_data"><cfoutput>#numberformat(discrepancy_dollars_as_percent,'9,999,999.99')#%</cfoutput></td>
			</tr>
			<tr bgcolor="##373737">
			<td class="grid_data"><img src="images/bullet_orange.png" hspace="5">Deduction days outstanding</td>
			<td class="grid_data"><cfoutput>#numberformat(deduction_days_outstanding,'9,999,999')#</cfoutput></td>
			</tr>


			<tr><tdcolspan="100%">&nbsp;&nbsp;</td></tr>
			<tr>
			<td class="data_grid_level1" colspan="100%" style="padding-top:20px;">Cycle Time</td>
			</tr>

			<tr bgcolor="##222222">
			<td class="grid_data"><img src="images/bullet_orange.png" hspace="5">Cycle Time - Created to Paid</td>
			<td class="grid_data"><cfoutput>#numberformat(cycle_time_created_to_paid,'9,999,999')#</cfoutput></td>
			</tr>
			<tr bgcolor="##373737">
			<td class="grid_data"><img src="images/bullet_orange.png" hspace="5">Cycle Time - Performance End to Paid</td>
			<td class="grid_data"><cfoutput>#numberformat(cycle_time_end_to_paid,'9,999,999')#</cfoutput></td>
			</tr>

			<tr><tdcolspan="100%">&nbsp;&nbsp;</td></tr>
			<tr>
			<td class="data_grid_level1" colspan="100%" style="padding-top:20px;">Payment Time</td>
			</tr>

			<tr bgcolor="##222222">
			<td class="grid_data"><img src="images/bullet_orange.png" hspace="5">Payment Type - Check</td>
			<td class="grid_data"><cfoutput>#numberformat(payment_type_check,'9,999,999')#</cfoutput></td>
			</tr>
			<tr bgcolor="##373737">
			<td class="grid_data"><img src="images/bullet_orange.png" hspace="5">Payment Type - Deduction</td>
			<td class="grid_data"><cfoutput>#numberformat(payment_type_deduction,'9,999,999')#</cfoutput></td>
			</tr>
			<tr bgcolor="##222222">
			<td class="grid_data"><img src="images/bullet_orange.png" hspace="5">Payment Type - AT</td>
			<td class="grid_data"><cfoutput>#numberformat(payment_type_at,'9,999,999')#</cfoutput></td>
			</tr>

			<tr><tdcolspan="100%">&nbsp;&nbsp;</td></tr>
			<tr>
			<td class="data_grid_level1" colspan="100%" style="padding-top:20px;">Entry Type</td>
			</tr>

			<tr bgcolor="##373737">
			<td class="grid_data"><img src="images/bullet_orange.png" hspace="5">Entry Type - EDI</td>
			<td class="grid_data"><cfoutput>#numberformat(entry_type_edi,'9,999,999.99')#%</cfoutput></td>
			</tr>
			<tr bgcolor="##222222">
			<td class="grid_data"><img src="images/bullet_orange.png" hspace="5">Entry Type - eInvoice</td>
			<td class="grid_data"><cfoutput>#numberformat(entry_type_einvoice,'9,999,999.99')#%</cfoutput></td>
			</tr>
			<tr bgcolor="##373737">
			<td class="grid_data"><img src="images/bullet_orange.png" hspace="5">Entry Type - Manual</td>
			<td class="grid_data"><cfoutput>#numberformat(entry_type_manual,'9,999,999.99')#%</cfoutput></td>
			</tr>

			</table>



</div>



		<!--- ----------------------------------------------------------------------------------------- --->
		</td>
	</tr>
</table>


		


</cfoutput>




</div>

<!--- ----------------------------------------------------------------------------------------- --->

