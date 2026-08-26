<cfparam name="url.level" default="1">
<cfparam name="url.item" default="">

<cfoutput>
<div class="section_title" style="background-color:##FFFF00; color:##000000;">
<cfswitch expression="#url.level#">
<cfcase value="1">
All regions
</cfcase>
<cfcase value="2">
Sub-Regions under #url.item#
<a href="javascript:history.go(-1)">[ back to regions ]</a>
</cfcase>
<cfcase value="3">
Territories under #url.item#
<a href="javascript:history.go(-1)">[ back to sub regions ]</a>
</cfcase>
<cfdefaultcase>
	<cfabort>
</cfdefaultcase>
</cfswitch>
&nbsp;&nbsp;&nbsp;
</div>
</cfoutput>

<br />

<cfset chartwidth=925>
<cfset chartheight=370>
<cfset foregroundcolor="##FFFFFF">
<cfset databackgroundcolor="##000000">
<cfset backgroundcolor="##000000">
<cfset pieslicestyle="solid">
<cfset show3d="Yes">

<cfset colorlist="##b64926, ##ffae21">

<cfset sUrl = "display.cfm?content=50493201990712445824981794589105" />
<cfset sUrl = sUrl & "&level=" & (url.level+1) />
<cfset sUrl = sUrl & "&item=$ITEMLABEL$&series=$SERIESLABEL$" />
<cfif url.level eq 3>
	<cfset sUrl = "" />
</cfif>

<cfinclude template="_get_position_lists.cfm">

<cfquery name="get_data_1"  datasource="#application.datasource#">
 
SELECT		<cfswitch expression="#url.level#">
			<cfcase value="1">
			dbo.Dashboards_Sales_Summary.level_1_description as description,
            dbo.Dashboards_Sales_Summary.level_1_code as code,
            dbo.Dashboards_Sales_Summary.level_1_id as id,
            </cfcase>
			<cfcase value="2">
			dbo.Dashboards_Sales_Summary.level_2_description as description,
            dbo.Dashboards_Sales_Summary.level_2_code as code,
            dbo.Dashboards_Sales_Summary.level_2_id as id,
            </cfcase>
			<cfcase value="3">
			dbo.Dashboards_Sales_Summary.level_3_description as description,
            dbo.Dashboards_Sales_Summary.level_3_code as code,
            dbo.Dashboards_Sales_Summary.level_3_id as id,
            </cfcase>
            </cfswitch>
            SUM(dbo.Dashboards_Sales_Summary.Actual_Current) as Sales
FROM		dbo.Dashboards_Sales_Summary
            INNER JOIN dbo.Dashboards_Sales_Month_Lookup ON dbo.Dashboards_Sales_Summary.month_id = dbo.Dashboards_Sales_Month_Lookup.dashboards_sales_month_lookup_id
            INNER JOIN dbo.Dashboards_Sales_Metric_Lookup ON dbo.Dashboards_Sales_Summary.metric_id = dbo.Dashboards_Sales_Metric_Lookup.dashboards_sales_metric_lookup_id

WHERE		dbo.Dashboards_Sales_Summary.level_id = 3

			<cfif 	user_market_list neq "">
            AND		level_3_id in (#user_market_list#)
            <cfelse>
            AND		1=2 <!--- Do not return any record if user is below this level --->
            </cfif>
<cfswitch expression="#url.level#">
<cfcase value="1">
GROUP BY 	dbo.Dashboards_Sales_Summary.level_1_description,
            dbo.Dashboards_Sales_Summary.level_1_code,
            dbo.Dashboards_Sales_Summary.level_1_id
ORDER BY	dbo.Dashboards_Sales_Summary.level_1_description
</cfcase>
<cfcase value="2">
			AND dbo.Dashboards_Sales_Summary.level_1_description = '#url.item#'
GROUP BY 	dbo.Dashboards_Sales_Summary.level_2_description,
            dbo.Dashboards_Sales_Summary.level_2_code,
            dbo.Dashboards_Sales_Summary.level_2_id
ORDER BY	dbo.Dashboards_Sales_Summary.level_2_description
</cfcase>
<cfcase value="3">
			AND dbo.Dashboards_Sales_Summary.level_2_description = '#url.item#'
GROUP BY 	dbo.Dashboards_Sales_Summary.level_3_description,
            dbo.Dashboards_Sales_Summary.level_3_code,
            dbo.Dashboards_Sales_Summary.level_3_id
ORDER BY	dbo.Dashboards_Sales_Summary.level_3_description
</cfcase>
</cfswitch>


</cfquery>

<cfquery name="get_data_2" dbtype="query">
SELECT	SUM(Sales)  as Sum_Sales
FROM 	get_data_1
</cfquery>
<cfset sum_sales = get_data_2.Sum_Sales />



<table align="center">
	<tr>

		<td>

			<cfchart
				format="png" 
				chartheight=#chartheight# 
				chartwidth=#chartwidth# fontsize="12" fontbold="yes" 
				url="#sUrl#"
				style="/dashboards/pie_chart_style_number_format.xml"
				>
				<cfchartseries type="pie" colorlist="#colorlist#">
                	<cfloop query="get_data_1">
                    	<cfchartdata item="#description#" value="#Sales#">
                    </cfloop>					
				</cfchartseries>
			</cfchart>

		</td>
	</tr>
</table>


<script language="javascript"> 
function toggle() {
	var ele = document.getElementById("toggleText");
	var text = document.getElementById("displayText");
	if(ele.style.display == "block") {
    		ele.style.display = "none";
		text.innerHTML = "[+] display data details";
  	}
	else {
		ele.style.display = "block";
		text.innerHTML = "[-] hide data details";
	}
} 
</script>


<style>
td.row_title, td.row_data
{
	font-size:		10px;
	color:			#555555;
	font-weight:	bold;
	border-bottom:	1px #cccccc solid;
	padding:		5px 10px 3px 10px;
	white-space: 	nowrap;
}

td.row_title
{
	font-size:		11px;
	font-weight:	bold;
}

td.heading
{
	border-bottom:	2px #000000 solid;
	font-size:		13px;
}

div.hover_box
{
	border:			1px #DDDDDD solid;
	top:			100px;
	bottom:			100px;
	left:			150px;
	right:			150px;
	padding:		20px 20px 20px 20px;
	margin:			5px auto 5px auto;
	position:		absolute;
	background-color:#EEEEEE;
	overflow:		scroll;
	overflow-x:		hidden;

	opacity:		0.98;

	z-index:		1;
	
	-webkit-box-shadow: 0px 0px 10px 5px #000000;
	-moz-box-shadow: 0px 0px 10px 5px #000000;
	box-shadow: 0px 0px 10px 5px #000000; 	
	
}

</style>



<a id="displayText" href="javascript:toggle();" style="margin-left:40px; font-size:14px; font-weight:bold; color:#FFFFFF">[+] display data details</a>



<div class="hover_box" id="toggleText" style="display: none;">

<a id="displayText" href="javascript:toggle();">[x]</a>

<table cellpadding="0" cellspacing="0" border="0" width="90%" align="center">
    <tr>
        <td class="row_title heading" align="right">&nbsp;</td>
        <td class="row_title heading" align="right">sales</td>
        <td class="row_title heading" align="right">percentage</td>
    </tr>


<cfloop query="get_data_1">


			<cfif sum_sales eq 0>
                <cfset region_perc = "n/a" />
            <cfelse>
                <cfset region_perc = numberformat((Sales*100/sum_sales), '9,999.9') & "%" />
            </cfif>



    <tr>
		<td class="row_title" nowrap="nowrap">
		    <cfoutput>#description#</cfoutput>
        </td>
		<td class="row_data" align="right">
		    <cfoutput>#numberformat(Sales, '9,999,999')#</cfoutput>
        </td>
		<td class="row_data" align="right">
		    <cfoutput>#region_perc#</cfoutput>
        </td>
    </tr>
</cfloop>
</table>
</div>
