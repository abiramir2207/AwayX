<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>xxxxxxxxxxxxxxxxxxxxxxxxx</TITLE>
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE>

<BR><BR>

<!--- This is where all of the stat functions are located --->	
<CFINCLUDE TEMPLATE="stat_functions.cfm">	

<CFSET X="1,2,8">
<CFSET Y="4,5,6">

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

<BR><BR><BR>
<PRE>
<CFOUTPUT>
	X=#x#		Y=#y#		N=#n#
	XY=#xy#
	Mx=#Mx#			My=#My#
	Sx=#Sx#			Sy=#Sy#

	r=#r#
	Slope=#slope#
	Intercept=#Intercept#
</PRE>
<HR>

<FONT SIZE="+1">
Y= #Intercept#  +  #slope#X
</FONT>

<HR>

</CFOUTPUT>
</BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



