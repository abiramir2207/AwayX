<cfparam name="form.chkCalculateInvoice" default="0">

<!--- Count the number of brackets to be added --->
<cfset TotalBrackets = 0>
<cfloop list="#form.fieldnames#" index="i"> 
	<cfif Left(i,7) eq "txtCode">
		<cfif evaluate(i) neq "">
			<cfset TotalBrackets = TotalBrackets + 1>
		</cfif>
	</cfif>
</cfloop>

<!--- The last "To" bracket must be a *. I am already doing JS validation on the form page
	  to force the user to make it a "*". Just doing a double check. --->
<cfset "form.txtTo_#TotalBrackets#" =  "*">

<!--- Call the function to insert freight bracket data from the form page --->
<cfinvoke
		component="components.freight.FreightBracketSetting"
		method="SetFreightBracketInfo">
			
	<cfinvokeargument name="formValues" value="#form.fieldnames#">
	<cfinvokeargument name="TotalBrackets" value="#TotalBrackets#">
</cfinvoke>

<cflocation url="index.cfm?action=AddFreightBracket">