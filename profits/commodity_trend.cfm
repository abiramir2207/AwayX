
<!--- Get the list of commodity prices: the Y points --->
<CFSET Y=VALUELIST(GET_COMMODITY_DATA.COMM_LAST)>

<!--- Get the count of items being trended: the X points --->
<CFSET itemcount=listlen(Y)>

<CFSET x="0">
<CFLOOP INDEX="i" FROM="1" TO="#evaluate(itemcount-1)#">
	<CFSET x=x&","&i>
</CFLOOP>

<!--- This is where all of the stat functions are located --->	
<CFINCLUDE TEMPLATE="stat_functions.cfm">	
 
 
<!--- compare list lengths --->
<CFIF ListLen(X) EQ ListLen(Y)>
	<CFSET N=ListLen(X)>
<CFELSE>
	THE LISTS HAVE DIFFERENT LENGHTS!!
	<CFABORT>
</CFIF>


<!--- Get the Sumation of the XY product --->
<CFSET XY=0>
<CFLOOP INDEX="i" FROM="1" TO="#n#">
	<CFSET XY=XY+(ListGetAt(x,i)*ListGetAt(y,i))>
</CFLOOP>

<!--- Mean/Average --->
<CFSET Mx=mean(x)>
<CFSET My=mean(y)>

<!--- Standard Deviation (n method) --->
<CFSET Sx=StdDevPop(x)>
<CFSET Sy=StdDevPop(y)>

<!--- Correlation --->
<CFSET r=(xy/n-(Mx*My))/(Sx*Sy)>

<!--- Slope --->
<CFSET Slope=r*(Sy/Sx)>

<!--- Intercept --->
<CFSET Intercept=My-(Slope*Mx)>

<!--- <CFOUTPUT>Y= #Intercept#  +  #slope#X</CFOUTPUT> --->

<!--- Get the first and the last point in the series												 --->
<CFSET firstpoint=intercept>
<CFSET lastpoint=intercept+slope*itemcount>

