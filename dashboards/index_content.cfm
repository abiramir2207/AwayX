
<style>

div.links
{
	float: 					left;
	margin:					5px 15px 5px 15px;
	line-height:			28px; 
	width:					225px;
	text-align:				center;
	padding: 				0px 0px 0px 0px; 
	color:					#FFFFFF; 
	font-size:				11px; 
	font-weight:			bold;
	text-decoration:		none;
	text-transform: 		capitalize;

	background: #777777; /* Old browsers */
	/* IE9 SVG, needs conditional override of 'filter' to 'none' */
	background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEgMSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ibm9uZSI+CiAgPGxpbmVhckdyYWRpZW50IGlkPSJncmFkLXVjZ2ctZ2VuZXJhdGVkIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIwJSIgeTI9IjEwMCUiPgogICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iIzc3Nzc3NyIgc3RvcC1vcGFjaXR5PSIxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiMyMjIyMjIiIHN0b3Atb3BhY2l0eT0iMSIvPgogIDwvbGluZWFyR3JhZGllbnQ+CiAgPHJlY3QgeD0iMCIgeT0iMCIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0idXJsKCNncmFkLXVjZ2ctZ2VuZXJhdGVkKSIgLz4KPC9zdmc+);
	background: -moz-linear-gradient(top,  #777777 0%, #222222 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#777777), color-stop(100%,#222222)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top,  #777777 0%,#222222 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top,  #777777 0%,#222222 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top,  #777777 0%,#222222 100%); /* IE10+ */
	background: linear-gradient(top,  #777777 0%,#222222 100%); /* W3C */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#777777', endColorstr='#222222',GradientType=0 ); /* IE6-8 */

    border:					0px #333333 solid;
    -moz-border-radius:		6px;
    -webkit-border-radius:	6px;
    border-radius:			6px;
	/* used byt IE */
	border-top-right-radius: 6px;
	border-top-left-radius: 6px;
	border-bottom-right-radius: 6px;
	border-bottom-left-radius: 6px;	
	
}


td.titles
{
	border-bottom:			2px #FF0000 solid; 
	color:					#FFFFFF; 
	font-size:				14px;
}

a.links
{
	color:					#FFFFFF; 
	font-size:				16px;
	cursor:					pointer;
	text-decoration:		none;
}

img.links
{
	padding:				0px 10px 0px 10px;
}

select.selector
{
	width: 					220px; 
	margin:					14px 0px 0px 20px; 
	padding: 				0px 0px 0px 10px; 
	height:					32px; 
	font-size:				13px; 
	font-weight:			bold;
}

div.radio_buttons
{
	color:					#FFFFFF;
	font-size:				11px;
	padding: 				0px 0px 2px 3px; 
}

fieldset.radio_buttons
{
	margin:					5px 0px 0px 0px;
	border: 				0px #00FF00 solid;
	border-top: 			1px #00FF00 solid;
}

legend.radio_buttons
{
	color:					#FFFFFF; 
	font-size:				12px;
}

input
{
	margin: 				0px 0px 0px 0px;
}


</style>

<br />




<!--- ----------------------------------------------------------------------------------------- --->
<!--- CHECK IF THE USER IS ALLOWED TO USE THE IPAD -------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<div align="center">
<cfif #getProfiles.DASHBOARD_REMOTE_ACCESS# EQ 0 AND FindNoCase('safari','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>
<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />
To access dashboards, you need to contact your support person.<br /><br /><br />Thanks You.
<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />
<cfabort>
</cfif>
</div>
<!--- ----------------------------------------------------------------------------------------- --->



<!--- ----------------------------------------------------------------------------------------- --->
<!--- used by the drop down select box --->
<script type="text/javascript">
function MM_jumpMenu(targ,selObj,restore){ //v3.0
eval(targ+".location='"+selObj.options[selObj.selectedIndex].value+"'");
if (restore) selObj.selectedIndex=0;
}
</script>
<!--- ----------------------------------------------------------------------------------------- --->


<!--[if gte IE 9]>
  <style type="text/css">
    div.gradient_fix {filter: none;}
  </style>
<![endif]-->




<table cellpadding="0" cellspacing="0" border="0" align="center" width="90%">



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- budgets --------------------------------------------------------------------- --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif	#qDashboardAccessInfo.Budget# EQ 1
		and
		(
			qDashboardAccessInfo.Budgets_territory_total				+
			qDashboardAccessInfo.Budgets_customer_specific_budgets		+
			qDashboardAccessInfo.Budgets_program_details				+
			qDashboardAccessInfo.Budgets_territory_budget_level_detail	+
			qDashboardAccessInfo.Budgets_sub_region_budget_level_detail
		)
		GTE 1
>

    <tr>
        <td style="border-bottom:2px #FF0000 solid;"><img src="images/box_red.png" hspace="10"></td>
        <td colspan="3" width="100%" class="titles" style="border-bottom:2px #FF0000 solid;"><CFOUTPUT>#label.budget.plural#</CFOUTPUT></td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td>

			<a class="links" href="budgets/display.cfm?content=78887-94749-95959-90409"><div class="links budgets gradient_fix buttons" title="select budget classes">select <CFOUTPUT>#label.budget_class.plural#</CFOUTPUT></div></a>


			<cfif #qDashboardAccessInfo.Budgets_territory_total# EQ 1>
			<a class="links" href="budgets/display.cfm?content=78888-94737-84955-80478"><div class="links budgets gradient_fix buttons" title="territory total"><CFOUTPUT>#label.territory.singular#</CFOUTPUT> total</div></a>
			</cfif>
			
			<cfif #qDashboardAccessInfo.Budgets_customer_specific_budgets# EQ 1>
			<a class="links" href="budgets/display.cfm?content=35852-17070-37427-48000"><div class="links budgets gradient_fix buttons" title="customer specific budgets"><CFOUTPUT>#label.customer.singular#</CFOUTPUT> specific budgets</div></a>
			</cfif>
			
			<cfif #qDashboardAccessInfo.Budgets_program_details# EQ 1>
			<a class="links" href="budgets/display.cfm?content=78887-94887-85955-88428"><div class="links budgets gradient_fix buttons" title="program details"><CFOUTPUT>#label.program.singular#</CFOUTPUT> details</div></a>
			</cfif>
			
			<cfif #qDashboardAccessInfo.Budgets_territory_budget_level_detail# EQ 1>
			<a class="links" href="budgets/display.cfm?content=78887-94737-85955-80428"><div class="links budgets gradient_fix buttons" title="territory budget level detail"><CFOUTPUT>#label.territory.singular#</CFOUTPUT> budget level detail</div></a>
			</cfif>
			
			<cfif #qDashboardAccessInfo.Budgets_sub_region_budget_level_detail# EQ 1>
			<a class="links" href="budgets/display.cfm?content=78889-94739-95955-90429"><div class="links budgets gradient_fix buttons" title="sub region budget level detail"><CFOUTPUT>#label.sub_region.singular#</CFOUTPUT> budget level detail</div></a>
			</cfif>

			




			
			<!--- this content is commented out per Ray Flies request on 4/29/2013 --->
			<!--- <a class="links" href="budgets/display.cfm?content=61432-92781-14853-63278"><div class="links budgets gradient_fix" title="user total">user total</div></a> --->
			<!--- ----------------------------------------------------------------------------------------- --->

		</td>
			

    </tr>


</cfif>
<!--- ----------------------------------------------------------------------------------------- --->









<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- billbacks --------------------------------------------------------------------- --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif	#qDashboardAccessInfo.Billback# EQ 1
		and
		(
			qDashboardAccessInfo.Billbacks_summary_table				+
			qDashboardAccessInfo.Billbacks_monthly_summary				+
			qDashboardAccessInfo.Billbacks_stats						+
			qDashboardAccessInfo.Billbacks_yearly_summary				+
			qDashboardAccessInfo.Billbacks_quarterly_summary
		)
		GTE 1
>
    <tr>
        <td style="border-bottom:2px #4671D5 solid;"><img src="images/box_blue.png" hspace="10"></td>
        <td colspan="3" width="100%" class="titles" style="border-bottom:2px #4671D5 solid;"><CFOUTPUT>#label.billback.plural#</CFOUTPUT></td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td>
        	<cfif #qDashboardAccessInfo.Billbacks_summary_table# EQ 1>
        	<a class="links" href="billbacks/bb_summary_data.cfm"><div class="links billbacks gradient_fix buttons" title="summary table">summary table</div></a>
        	</cfif>

        	<cfif #qDashboardAccessInfo.Billbacks_monthly_summary# EQ 1>
        	<a class="links" href="billbacks/bb_summary_data_period.cfm?period=3"><div class="links billbacks gradient_fix buttons" >monthly summary</div></a>
        	</cfif>

        	<cfif #qDashboardAccessInfo.Billbacks_yearly_summary# EQ 1>
        	<a class="links" href="billbacks/bb_summary_data_period.cfm?period=5"><div class="links billbacks gradient_fix buttons" title="yearly summary">yearly summary</div></a>
        	</cfif>

        	<cfif #qDashboardAccessInfo.Billbacks_quarterly_summary# EQ 1>
        	<a class="links" href="billbacks/bb_summary_data_period.cfm?period=4"><div class="links billbacks gradient_fix buttons" >quarterly summary</div></a>
        	</cfif>

			<cfif #qDashboardAccessInfo.Billbacks_stats# EQ 1>
			<form name="form" id="form">
				<select name="jumpMenu" id="jumpMenu" onchange="MM_jumpMenu('parent',this,0)" class="selector" style="height:22px">
		
					<option value="#" selected>12 months rolling...</option>

					<option value="billbacks/bb_summary_data_rolling12.cfm?content=27251464714966096215018589478188">Total Count</option>
					<option value="billbacks/bb_summary_data_rolling12.cfm?content=45568534524436135648186757688533">$'s: Total</option>
					<option value="billbacks/bb_summary_data_rolling12.cfm?content=83383662199107988683933154394379">$'s: Off Invoice</option>
					<option value="billbacks/bb_summary_data_rolling12.cfm?content=44251709366036422873906987835441">$'s: Billback</option>
					<option value="billbacks/bb_summary_data_rolling12.cfm?content=64496065404382576131220545894677">$'s: Ave per billback</option>
					<option value="billbacks/bb_summary_data_rolling12.cfm?content=68992132496321383440838589234418">Ave items per invoice</option>
					<option value="billbacks/bb_summary_data_rolling12.cfm?content=79276942499215024465167292390306">Discrepancy: Count > $0</option>
					<option value="billbacks/bb_summary_data_rolling12.cfm?content=52223300440575879209296854847383">Discrepancy: Total $'s</option>
					<option value="billbacks/bb_summary_data_rolling12.cfm?content=28058019805677983043027481003584">Discrepancy: Percent of $</option>
					<option value="billbacks/bb_summary_data_rolling12.cfm?content=96584561334820676041942072593055">Deduction days outstanding</option>
					<option value="billbacks/bb_summary_data_rolling12.cfm?content=14861127198521465868954826336496">Cycle - Created to Paid</option>
					<option value="billbacks/bb_summary_data_rolling12.cfm?content=85309939245394706795463161903757">Cycle - Perf End to Paid</option>
					<option value="billbacks/bb_summary_data_rolling12.cfm?content=28925981445625825062079391940251">Type - Check</option>
					<option value="billbacks/bb_summary_data_rolling12.cfm?content=21014311315907368110293248688226">Type - Deduction</option>
					<option value="billbacks/bb_summary_data_rolling12.cfm?content=23007111898819874628340698836933">Type - AT</option>
					<option value="billbacks/bb_summary_data_rolling12.cfm?content=51971847421630836604852211730804">Entry - EDI</option>
					<option value="billbacks/bb_summary_data_rolling12.cfm?content=57400554671981952676017695668982">Entry - eInvoice</option>
					<option value="billbacks/bb_summary_data_rolling12.cfm?content=46633024967030533087337972740629">Entry - Manual</option>
		
				</select>
			</form>
			<br />			
			</cfif>


        </td>
    </tr>
</cfif>
<!--- ----------------------------------------------------------------------------------------- --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- sales --------------------------------------------------------------------------- --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfif 	#qDashboardAccessInfo.Sales# EQ 1
		and
		(
			qDashboardAccessInfo.Sales_last_12_months_eqc		+
			qDashboardAccessInfo.Sales_fiscal_year_summary_eqc	+
			qDashboardAccessInfo.Sales_sales_view_drilldown		+
			qDashboardAccessInfo.Sales_TBM_sales_tracker		+
			qDashboardAccessInfo.Sales_NAM_sales_tracker		+
			qDashboardAccessInfo.Sales_tracker
		)
		GTE 1
>

<form action="display.cfm" name="myFORM" method="post">
    <tr>
        <td style="border-bottom:2px #00FF00 solid;"><img src="images/box_green.png" hspace="10"></td>
        <td colspan="3" width="100%" class="titles" style="border-bottom:2px #00FF00 solid;"><CFOUTPUT>#label.sales.plural#</CFOUTPUT></td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td>
        	<cfif #qDashboardAccessInfo.Sales_last_12_months_eqc# EQ 1>
        	<a class="links" href="#" onclick="javascript:myFORM.action='sales/display.cfm?content=26792-99654-16070-96715'; myFORM.submit(); return false;"><div class="links sales gradient_fix buttons">last 12 months (eqc)</div></a>
       		</cfif>

        	<cfif #qDashboardAccessInfo.Sales_fiscal_year_summary_eqc# EQ 1>
        	<a class="links" href="#" onclick="javascript:myFORM.action='sales/display.cfm?content=21496-54091-46875-59977'; myFORM.submit(); return false;"><div class="links sales gradient_fix buttons">fiscal year summary (eqc)</div></a>
        	</cfif>

        	<cfif #qDashboardAccessInfo.Sales_sales_view_drilldown# EQ 1>
        	<a class="links" href="#" onclick="javascript:myFORM.action='sales/display.cfm?content=15339-12021-74875-68397'; myFORM.submit(); return false;"><div class="links sales gradient_fix buttons">sales view drilldown</div></a>
        	</cfif>

        	<cfif #qDashboardAccessInfo.Sales_tracker# EQ 1>
        	<a class="links" href="#" onclick="javascript:myFORM.action='sales/sales_tracker.cfm?content=81957-97068-45938-95590'; myFORM.submit(); return false;"><div class="links sales gradient_fix buttons">sales tracker</div></a>
        	</cfif>
  
       	</td>
    </tr>
</form>


</cfif>
<!--- ----------------------------------------------------------------------------------------- --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- performance --------------------------------------------------------------------- --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif 	#qDashboardAccessInfo.performance# EQ 1
		and
		(
			qDashboardAccessInfo.performance_programs + 0
		)
		GTE 1
>

    <tr>
        <td style="border-bottom:2px #FF9900 solid;"><img src="images/box_yellow.png" hspace="10"></td>
        <td colspan="3" width="100%" class="titles" style="border-bottom:2px #FF9900 solid;"><CFOUTPUT>#label.performance.singular#</CFOUTPUT></td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td>
        	<cfif #qDashboardAccessInfo.performance_programs# EQ 1>
        		<a class="links" href="programs/index.cfm?content=75718-73349-64488-74924"><div class="links sales gradient_fix buttons"><CFOUTPUT>#label.program.plural#</CFOUTPUT></div></a>
        	</cfif>
        	<!--- <a class="links" href="programs/index.cfm?content=59613-88929-18962-37888"><div class="links sales gradient_fix">gains & losses</div></a> --->
        </td>
    </tr>

</cfif>
<!--- ----------------------------------------------------------------------------------------- --->


</table>























<br />
