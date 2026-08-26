<!--- ----------------------------------------------------------------------------------------- --->
<a href="test.cfm">test.cfm</a>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<cfinclude template="customer_specific_budgets.css">
<!--- ----------------------------------------------------------------------------------------- --->

<!--- total volume --->
<cfset total_vol	=	94763798>
<!--- total dollars spent --->
<cfset total_dol	=	4806073>
<!--- roi: volume per dollar --->
<cfset vol_per_dol	=	total_vol/total_dol>
<!--- budgets --->
<cfset budgets	=	"Budget 1,Budget 2,Budget 3,Budget 4,Budget 5,Budget 6,Budget 7,Budget 8,Budget 9,Budget 10,Budget 11,Budget 12,Budget 13,Budget 14,Budget 15,Budget 16,Budget 17">
<!--- dollars --->
<cfset budgets_dollars	=	"186897,162893,121413,393126,327173,247846,131180,220990,442871,498552,425709,179739,148284,389902,370956,211229,347313">
<!--- volume --->
<cfset budgets_volume	=	"7880017,8112763,5613088,7942334,7827753,1776447,2771722,1237106,6012044,3802789,9359395,2010218,2908427,2961990,9984993,7346050,7216662">

<cfset columns				=	7>
<cfset table_width			=	920>
<cfset column_width			=	100>
<cfset column_width_first	=	table_width - ((columns-1) * column_width)>

<!--- since the iPad doesn't  use scroll bars, it needs this fix ------------------------------ --->
<CFIF FindNoCase('iPad','#CGI.HTTP_USER_AGENT#') GT 0>
<cfset table_width_header	=	table_width - 0>
<cfelse>
<cfset table_width_header	=	table_width - 17>
</cfif>
<!--- ----------------------------------------------------------------------------------------- --->

<style>

td.scroll_header
{
	COLOR:	#FFFFFF;
	background-color:#888888;
}

td.scroll_data
{
	COLOR:	#FFFFFF;
}

div.scroll_header
{
	width:				<cfoutput>#table_width_header#</cfoutput>px; 
}

div.scroll_data
{
	overflow-x: 		hidden; 
	overflow-y: 		scroll;
	-webkit-overflow-scrolling: touch;	
	height:				200px; 
	width:				<cfoutput>#table_width#</cfoutput>px; 
}

table.scroll_data, table.scroll_header
{
	border-collapse:	collapse;
	border-spacing:		0;
	margin:				0px 0px 0px 20px;
}
</style>


<DIV align="left" style="padding:5PX;">


<div class="scroll_header">
<table class="scroll_header">
	<cfoutput>
    <col width="#column_width_first#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    </cfoutput>
    <tr>
        <td class="scroll_header"><br />budget desc</td>
        <td class="scroll_header"><br />dollars</td>
        <td class="scroll_header"><br />dol %</td>
        <td class="scroll_header"><br />volume</td>
        <td class="scroll_header"><br />vol %</td>
        <td class="scroll_header"><br />vol per dol</td>
        <td class="scroll_header"><br />roi vs total</td>
    </tr>
</table>
</div>

<div class="scroll_data">
<table class="scroll_data">
	<cfoutput>
    <col width="#column_width_first#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    </cfoutput>

	<cfloop index="i" from="1" to="#listlen(budgets, ",")#">
	<cfset budget_vol_per_dol	=	ListGetAt(budgets_volume, i)/ListGetAt(budgets_dollars, i)>
    <cfset vol_per_dol_ratio	=	(budget_vol_per_dol - vol_per_dol)*100/vol_per_dol>
    <cfoutput>
        <tr>
            <td class="scroll_data">#ListGetAt(budgets, i)#</td>
            <td class="scroll_data">$#numberformat(ListGetAt(budgets_dollars, i), ',')#</td>
            <td class="scroll_data">#numberformat(ListGetAt(budgets_dollars, i)*100/total_dol, ',.00')#%</td>
            <td class="scroll_data">#numberformat(ListGetAt(budgets_volume, i), ',')#</td>
            <td class="scroll_data">#numberformat(ListGetAt(budgets_volume, i)*100/total_vol, ',.00')#%</td>
            <td class="scroll_data">#numberformat(budget_vol_per_dol, '0.000')#</td>
            <td class="scroll_data">#numberformat(vol_per_dol_ratio, ',.00')#%</td>
        </tr>
    </cfoutput>
	</cfloop>

	<cfoutput>
        <tr>
            <td class="grandtotals">&nbsp;</td>
            <td class="grandtotals">#total_dol#</td>
            <td class="grandtotals">&nbsp;</td>
            <td class="grandtotals">#total_vol#</td>
            <td class="grandtotals">&nbsp;</td>
            <td class="grandtotals">#vol_per_dol#</td>
            <td class="grandtotals">&nbsp;</td>
        </tr>
    </cfoutput>

</table>
</div>

</DIV>

<center>
<cfchart format="png" chartheight="300" chartwidth="875" foregroundcolor="##FFFFFF" databackgroundcolor="##000000" fontsize="9" backgroundcolor="##000000">
	<cfchartseries type="line" serieslabel="global vol/dol" seriescolor="##FFFF00" markerstyle="none">
        <cfloop index="i" from="1" to="#listlen(budgets, ",")#">
        <cfchartdata item="#i#" value="#numberformat(vol_per_dol, '0.000')#">
        </cfloop>
    </cfchartseries>
	<cfchartseries serieslabel="budget vol/dol" type="bar" seriescolor="##0066FF" >
        <cfloop index="i" from="1" to="#listlen(budgets, ",")#">
        <cfchartdata item="#i#" value="#numberformat(ListGetAt(budgets_volume, i)/ListGetAt(budgets_dollars, i), '0.000')#">
        </cfloop>
    </cfchartseries>
</cfchart>
</center>

