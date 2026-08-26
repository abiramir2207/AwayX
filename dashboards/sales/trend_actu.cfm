<!--- ----------------------------------------------------------------------------------------- --->
<!---calculate the trend function (y=a+bx) for the actual (historical) data ------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfset xlist = "1,2,3,4,5,6,7">
<cfset ylist = "458,1135,1187,1765,2135,2626,2670">
<cfset xnew="7">
<cfset myforecast = #forecast(Xlist, Ylist, xnew)#>
<!--<cfoutput><br>Y is: #myforecast[1][1]#</cfoutput> -->

<cfset actual_inter=myforecast[1][2]>
<cfset actual_slope=myforecast[1][3]>

<cfoutput>
actu:&nbsp;&nbsp;&nbsp; Y=#numberformat(actual_inter, '9,999,999.999')#+#numberformat(actual_slope, '9,999,999,.999')# * x
</cfoutput>

<cfset actual_x_list=xlist>
<cfset actual_y_list=ylist>

<!--- create the trend line points for the actual data --->
<cfset actual_trend_list="">
<cfloop index="i" from="1" to="12" step="1">
<cfset new_value=actual_inter+actual_slope*i>
<cfset actual_trend_list = ListAppend(actual_trend_list, new_value)>
</cfloop>
<!--<cfoutput>#actual_trend_list#</cfoutput> -->

<!--- ----------------------------------------------------------------------------------------- --->
<br />
