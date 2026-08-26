<cfparam name="Auto_Renew_Type" default="1">
<cfparam name="Form.Start_Date" default="01/01/2004">
<cfparam name="Form.End_Date" default="09/31/2004">


<cfset Program_Span = abs(DateDiff('y', Form.End_Date, Form.Start_Date))>
<cfif Auto_Renew_Type IS 2>
	<cfset AR_Start_Date = DateAdd('yyyy', 1, Form.Start_Date)>
	<cfset AR_End_Date = DateAdd('y', Program_Span, AR_Start_Date)>
<cfelse>
	<cfset AR_Start_Date = DateAdd('y', 1, Form.End_Date)>
	<cfset AR_End_Date = DateAdd('y', Program_Span, AR_Start_Date)>
</cfif>

<cfoutput>
#AR_Start_Date#
#AR_End_Date#</cfoutput>