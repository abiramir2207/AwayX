<cfsilent>

<!---Why use this tag?
This tag does two important things. It allows one source for making defaults on how many decimals customers use, gives us a central place to control rounding and displays for clients.

Secondarily, there is a rounding issue inherent with coldfusion fixed by: <cfset number = attributes.number + .000000000000001>

Basically if you have a number which has been manipulated by colddfusion, is even, and is followed by 5, when rounding it rounds down instead of up.

So 1.625 = 1.62 instead of 1.63. This resolves that issue.

Written by Brenda Flynn
December 29, 2004

--->

<!------ formatnumber.cfm ----->
<!------ 
This is how to call this format
<CF_formatnumber
	number = "#yourvariable#" 
	decimals = "4"
	showcurrency = 0
>
 ------>
 
<cfparam name="attributes.number" 	default="0">
<cfparam name="attributes.decimals" 	default="2">
<cfparam name="attributes.showcurrency" 	default="0">


<cfset number = attributes.number + .000000000000001>
<cfset mask="_-___,___,___,___">
<cfif attributes.decimals GT 0>
	<cfset mask = mask & ".">
	<cfloop index = "LoopCount" from = "1" to = #attributes.decimals#>
		<cfset mask = mask & "0">
	</cfloop>
</cfif>

</cfsilent><cfoutput><cfif attributes.showcurrency IS 1>$</cfif>#trim(numberformat(number,'#mask#'))#</cfoutput>