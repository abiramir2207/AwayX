<!--- ----------------------------------------------------------------------------------------- --->

<!--- generate fake 1 year old data. to be replaced when there is enough historical data ------ --->
<cfset data_this_month_year_ago=round(data_month*(1+rand()-0.25))>
<cfset data_this_quarter_year_ago=round(data_quarter*(1+rand()-0.25))>
<cfset data_this_year_year_ago=round(data_year*(1+rand()-0.25))>
<!--- ----------------------------------------------------------------------------------------- --->



<div style="width:925px; padding:10px 10px 10px 10px;">


<style>
a.links
{ color:#ffffff; text-decoration:none;}

span.button
{
	border:						1px #333333 solid;
    -webkit-border-radius:		10px;
    -moz-border-radius:			10px;
    border-radius:				10px;
	padding:					5px 70px 5px 70px;
	text-align:					center;
	text-transform:				lowercase;
	line-height:				30px;
    background-image:			-webkit-gradient(linear, left top, left bottom, color-stop(0, #0097fe), color-stop(1, #0125ab));/* webkit:safari/chrome 10 */
    background-image:			linear-gradient(top, #0097fe 0%, #0125ab 100%);/* proposed w3c markup */ 
	margin:						15px 0px 15px 10px;
}

0097fe	0125ab


</style>



<!--- 
<div style="text-align:left;">
<a href="bb_summary_data.cfm" style="color:#ffdd00;"><span class="button">back to summary data</span></a>
</div>
----------------------------------------------------------------------------------------- --->

<cfoutput>
<table cellspacing="0" cellpadding="0" border="0" width="900" align="center">
  <tr>
    <td class="data_grid_header" colspan="3">Monthly</td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td class="data_grid_header" colspan="3">Quarterly</td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td class="data_grid_header" colspan="3">Year to Date</td>
  </tr>
  <tr>
    <td class="data_grid_header" width="100">SPLY</td>
    <td class="data_grid_header" width="100">#monthly.period_desc#</td>
    <td class="data_grid_header" width="100">Delta</td>
    <td>&nbsp;&nbsp;</td>
    <td class="data_grid_header" width="100">SPLY</td>
    <td class="data_grid_header" width="100">#quarterly.period_desc#</td>
    <td class="data_grid_header" width="100">Delta</td>
    <td>&nbsp;&nbsp;</td>
    <td class="data_grid_header" width="100">SPLY</td>
    <td class="data_grid_header" width="100">#yearly.period_desc#</td>
    <td class="data_grid_header" width="100">Delta</td>
  </tr>
  <tr>
    <td class="data_grid_level1">#numberformat(data_this_month_year_ago,'9,999,999')#</td>
    <td class="data_grid_level1">#numberformat(data_month,'9,999,999')#</td>
    <td class="data_grid_level1">#numberformat(evaluate(100*(data_month-data_this_month_year_ago)/data_this_month_year_ago),'9,999.99')#%</td>
    <td>&nbsp;&nbsp;</td>
    <td class="data_grid_level1">#numberformat(data_this_quarter_year_ago,'9,999,999')#</td>
    <td class="data_grid_level1">#numberformat(data_quarter,'9,999,999')#</td>
    <td class="data_grid_level1">#numberformat(evaluate(100*(data_quarter-data_this_quarter_year_ago)/data_this_quarter_year_ago),'9,999.99')#%</td>
    <td>&nbsp;&nbsp;</td>
    <td class="data_grid_level1">#numberformat(data_this_year_year_ago,'9,999,999')#</td>
    <td class="data_grid_level1">#numberformat(data_year,'9,999,999')#</td>
    <td class="data_grid_level1">#numberformat(evaluate(100*(data_year-data_this_year_year_ago)/data_this_year_year_ago),'9,999.99')#%</td>
  </tr>
</cfoutput>

  <tr>
    <td colspan="3" width="225">
    	<br /><br />
        <cfchart   
            format=						"png"  
            chartheight=				"350"  
            chartwidth=					"275"  
            showlegend=					"no"  
            backgroundcolor=			"000000"  
            foregroundcolor=			"bbbbbb"  
            show3d=						"yes"  
            databackgroundcolor=		"000000"  
            showxgridlines=				"no"  
            showygridlines=				"yes"  
            >  
            <cfchartseries type="bar" paintstyle="light" colorlist="##ffa500,##6a9c17"> 
                <cfchartdata item = "SPLY" value = #data_this_month_year_ago#>
                <cfchartdata item = "#monthly.period_desc#" value = #data_month#>
            </cfchartseries>
        </cfchart> 
    </td>
    <td>&nbsp;&nbsp;</td>
    <td colspan="3" width="225">
    	<br /><br />
        <cfchart   
            format=						"png"  
            chartheight=				"350"  
            chartwidth=					"275"  
            showlegend=					"no"  
            backgroundcolor=			"000000"  
            foregroundcolor=			"bbbbbb"  
            show3d=						"yes"  
            databackgroundcolor=		"000000"  
            showxgridlines=				"no"  
            showygridlines=				"yes"  
            >  
            <cfchartseries type="bar" paintstyle="light" colorlist="##5366dc,##b83a9d"> 
                <cfchartdata item = "SPLY" value = #data_this_quarter_year_ago#>
                <cfchartdata item = "#quarterly.period_desc#" value = #data_quarter#>
            </cfchartseries>
        </cfchart> 
    </td>
    <td>&nbsp;&nbsp;</td>
    <td colspan="3" width="225">
    	<br /><br />
        <cfchart   
            format=						"png"  
            chartheight=				"350"  
            chartwidth=					"275"  
            showlegend=					"no"  
            backgroundcolor=			"000000"  
            foregroundcolor=			"bbbbbb"  
            show3d=						"yes"  
            databackgroundcolor=		"000000"  
            showxgridlines=				"no"  
            showygridlines=				"yes"  
            >  
            <cfchartseries type="bar" paintstyle="light" colorlist="##a7a37e,##777777"> 
                <cfchartdata item = "SPLY" value = #data_this_year_year_ago#>
                <cfchartdata item = "#yearly.period_desc#" value = #data_year#>
            </cfchartseries>
        </cfchart> 
    </td>
  </tr>

</table>

<!--- ----------------------------------------------------------------------------------------- --->
<cfinclude template="sply_note.cfm">
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->

