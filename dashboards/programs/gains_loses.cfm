<!--- 59613-88929-18962-37888 --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- setup variables ------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->

<!--- stats data --->
<cfset max_vol	=	numberformat(randrange(1111,9999), ',')>
<cfset max_dol	=	mydollarformat(randrange(1111,9999))>
<cfset growth	=	randrange(-10,25)>
<cfset gpm		=	randrange(1,20)>

<!--- table data --->
<!--- 21246-53516-10386-18997 = cases, 24425-76629-95324-57130 = dollars --->

<cfset gridtable_header	=	"Sales<br />09/12,Sales<br />SPLY,Delta<br />Abs.,Delta<br />%,Rank<br />09/12,Rank<br />SPLY">
<cfparam name="mode" default="21246-53516-10386-18997" type="any">

<cfif mode EQ "21246-53516-10386-18997">

	<cfset table_title	=	"cases">
    <cfset url_mode	=	"24425-76629-95324-57130">
    <cfset table_link_label	=	"view dollars">
    <cfset sysco_ne	=	"9435,8035,1400,17%,2,2">
    <cfset sysco_se	=	"8793,6842,1951,29%,3,5">
    <cfset usfs_ne	=	"3574,6925,-3351,-48%,8,4">
    <cfset usfs_sw	=	"7367,7396,-29,0%,5,3">
    <cfset reinhard_se	=	"9597,1371,8226,600%,1,7">
    <cfset reinhard_nw	=	"5416,1623,3793,234%,6,6">
    <cfset unipro_sw	=	"8197,1186,7011,591%,4,8">
    <cfset unipro_nw	=	"3591,8204,-4613,56%,7,1">

<cfelse>

	<cfset table_title	=	"dollars">
    <cfset url_mode	=	"21246-53516-10386-18997">
    <cfset table_link_label	=	"view cases">
    <cfset sysco_ne	=	"$9446,$1365,$8081,592%,2,8">
    <cfset sysco_se	=	"$5106,$3909,$1197,31%,6,7">
    <cfset usfs_ne	=	"$6147,$5490,$657,12%,4,5">
    <cfset usfs_sw	=	"$1216,$4424,$-3208,-73%,8,6">
    <cfset reinhard_se	=	"$5831,$9132,$-3301,-36%,5,1">
    <cfset reinhard_nw	=	"$9242,$7200,$2042,28%,3,4">
    <cfset unipro_sw	=	"$1421,$8004,$-6583,-82%,7,2">
    <cfset unipro_nw	=	"$9587,$7639,$1948,26%,1,3">

</cfif>


<!--- pie data --->
<cfset pie_labels	=	"Mkt.1,Mkt.2,Mkt.3,Mkt.4,Mkt.5,Mkt.6">
<cfset pie_data 	= 	"">
<cfloop index="i" from="1" to="6" step="1">
<cfset pie_data = listAppend(pie_data, randrange(1,100)/100)>
</cfloop>

<!--- graph data  --->
<cfset distributors	=	"sysco_ne,sysco_se,usfs_ne,usfs_sw,reinhard_se,reinhard_nw,unipro_sw,unipro_nw">

<cfif mode EQ "21246-53516-10386-18997">

	<cfset table_title	=	"cases">
	<cfset sales_curr	=	"9435,8793,3574,7367,9597,5416,8197,3591">
    <cfset sales_sply	=	"8035,6842,6925,7396,1371,1623,1186,8204">

<cfelse>

	<cfset table_title	=	"dollars">
	<cfset sales_curr	=	"9446,5106,6147,1216,5831,9242,1421,9587">
    <cfset sales_sply	=	"1365,3909,5490,4424,9132,7200,8004,7639">

</cfif>


<!--- ----------------------------------------------------------------------------------------- --->
<!--- stats data ------------------------------------------------------------------------------ --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfsavecontent variable = "stats">
<div class="border">
<div class="stats">Stats</div>
<table class="stats">
    <tr>
        <td class="stats_left">Max Vol:</td>
        <td class="stats_right"><cfoutput>#max_vol#</cfoutput></td>
    </tr>
    <tr>
        <td class="stats_left">Max Dolars:</td>
        <td class="stats_right"><cfoutput>#max_dol#</cfoutput></td>
    </tr>
    <tr>
        <td class="stats_left">Growth:</td>
        <td class="stats_right"><cfoutput>#growth#%</cfoutput></td>
    </tr>
    <tr>
        <td class="stats_left">GPM:</td>
        <td class="stats_right"><cfoutput>#gpm#%</cfoutput></td>
    </tr>
    </table>
</div>
</cfsavecontent>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<!--- table data ------------------------------------------------------------------------------ --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfsavecontent variable = "gridtable">
<table class="gridtable">
    <tr>
        <td class="gridtable_headers light_gradient align-left">Distributor</td>
        <cfloop index="i" list="#gridtable_header#">
        <td class="gridtable_headers light_gradient align-left"><cfoutput>#i#</cfoutput></td>
        </cfloop>
    </tr>
    <tr>
        <td class="gridtable_data align-left">sysco_ne</td>
        <cfloop index="i" list="#sysco_ne#">
        <td class="gridtable_data align-left"><cfoutput>#i#</cfoutput></td>
        </cfloop>
    </tr>
    <tr>
        <td class="gridtable_data align-left">sysco_se</td>
        <cfloop index="i" list="#sysco_se#">
        <td class="gridtable_data align-left"><cfoutput>#i#</cfoutput></td>
        </cfloop>
    </tr>
    <tr>
        <td class="gridtable_data align-left">usfs_ne</td>
        <cfloop index="i" list="#usfs_ne#">
        <td class="gridtable_data align-left"><cfoutput>#i#</cfoutput></td>
        </cfloop>
    </tr>
    <tr>
        <td class="gridtable_data align-left">usfs_sw</td>
        <cfloop index="i" list="#usfs_sw#">
        <td class="gridtable_data align-left"><cfoutput>#i#</cfoutput></td>
        </cfloop>
    </tr>
    <tr>
        <td class="gridtable_data align-left">reinhard_se</td>
        <cfloop index="i" list="#reinhard_se#">
        <td class="gridtable_data align-left"><cfoutput>#i#</cfoutput></td>
        </cfloop>
    </tr>
    <tr>
        <td class="gridtable_data align-left">reinhard_nw</td>
        <cfloop index="i" list="#reinhard_nw#">
        <td class="gridtable_data align-left"><cfoutput>#i#</cfoutput></td>
        </cfloop>
    </tr>
    <tr>
        <td class="gridtable_data align-left">unipro_sw</td>
        <cfloop index="i" list="#unipro_sw#">
        <td class="gridtable_data align-left"><cfoutput>#i#</cfoutput></td>
        </cfloop>
    </tr>
    <tr>
        <td class="gridtable_data align-left">unipro_nw</td>
        <cfloop index="i" list="#unipro_nw#">
        <td class="gridtable_data align-left"><cfoutput>#i#</cfoutput></td>
        </cfloop>
    </tr>
</table>
</cfsavecontent>
<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- pie data -------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfsavecontent variable = "pie_chart">
<div class="border">
<div class="pie">Share - %</div>
<cfchart format="png" chartheight="260" chartwidth="300" showygridlines="no" foregroundcolor="##CCCCCC" fontsize="10" fontbold="yes" show3d="yes" showmarkers="no" pieslicestyle="solid" backgroundcolor="##333333" labelformat="percent">
	<cfchartseries type="pie">
		<cfset counter	=	0>
        <cfloop index="i" list=#pie_data#>
            <cfset counter	=	counter + 1>
            <cfchartdata item="#ListGetAt(pie_labels, counter)#" value="#i#">
        </cfloop>
	</cfchartseries>
</cfchart>
</div>
</cfsavecontent>
<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- graph data ------------------------------------------------------------------------------ --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfsavecontent variable = "gridchart">
<cfchart format="png" chartheight="260" chartwidth="575" foregroundcolor="##CCCCCC" databackgroundcolor="##333333" showlegend="yes" backgroundcolor="##333333">
    <cfchartseries type="bar" serieslabel="Current Month" seriescolor="##FFFF00" markerstyle="none">
        <cfloop index="i" from="1" to="8">
	        <cfchartdata item="#ListGetAt(distributors, i)#" value="#ListGetAt(sales_curr, i)#">
        </cfloop>
    </cfchartseries>
    <cfchartseries type="bar" serieslabel="Same Period Last Year" seriescolor="##ED4035" markerstyle="none">
        <cfloop index="i" from="1" to="8">
	        <cfchartdata item="#ListGetAt(distributors, i)#" value="#ListGetAt(sales_sply, i)#">
        </cfloop>
    </cfchartseries>
</cfchart>
</cfsavecontent>
<!--- ----------------------------------------------------------------------------------------- --->


<!--[if gte IE 9]>
  <style type="text/css">
    div.gradient_fix {filter: none;}
  </style>
<![endif]-->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- output ---------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<table cellpadding="0" cellspacing="0" width="100%" align="center">
<tr>
	<td valign="top"><cfoutput>#stats#</cfoutput></td>
    <td rowspan="2" valign="top">
		<div class="border">
            <div class="gridtable">
                Gains/Losses - <cfoutput>#table_title#</cfoutput>
                <div class="nav rounded_corners light_gradient gradient_fix" style="float:right; font-size:11px; padding:2px 10px 2px 10px;" onclick="location.href='index.cfm?content=59613-88929-18962-37888&mode=<cfoutput>#url_mode#</cfoutput>'"><cfoutput>#table_link_label#</cfoutput></div>
            </div>
            <cfoutput>#gridtable#</cfoutput><br /><cfoutput>#gridchart#</cfoutput></td>
        </div>
</tr>
<tr>
	<td valign="top"><cfoutput>#pie_chart#</cfoutput></td>
</tr>
</table>
<!--- ----------------------------------------------------------------------------------------- --->

