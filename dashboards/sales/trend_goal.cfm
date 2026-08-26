<!--- ----------------------------------------------------------------------------------------- --->
<!---calculate the trend function (y=a+bx) for the forecasted (goal) data --------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfset xlist = "1,2,3,4,5,6,7,8,9,10,11,12">
<cfset ylist = "1102,1583,1854,2648,2673,3423,4219,5132,5939,6473,6903,7035">
<cfset xnew="7">
<cfset myforecast = #forecast(Xlist, Ylist, xnew)#>
<!--<cfoutput><br>Y is: #myforecast[1][1]#</cfoutput> -->

<cfset goal_inter=myforecast[1][2]>
<cfset goal_slope=myforecast[1][3]>

<cfoutput>
goal:&nbsp;&nbsp;&nbsp; Y=#numberformat(goal_inter, '9,999,999.999')#+#numberformat(goal_slope, '9,999,999,.999')# * x
</cfoutput>

<cfset goal_x_list=xlist>
<cfset goal_y_list=ylist>

<!--- create the trend line points for the forecast data --->
<cfset goal_trend_list="">
<cfloop index="i" from="1" to="12" step="1">
<cfset new_value=goal_inter+goal_slope*i>
<cfset goal_trend_list = ListAppend(goal_trend_list, new_value)>
</cfloop>
<!--<cfoutput>#goal_trend_list#</cfoutput> -->

<!--- ----------------------------------------------------------------------------------------- --->
<br />
