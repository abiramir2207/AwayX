<cfparam name="checkSelectedBB" type="boolean" default="false">
<cfparam name="checkSelectedDD" type="boolean" default="false">
<cfparam name="checkSelectedCR" type="boolean" default="false">
<cfparam name="numberOnly" type="boolean" default="false">
<cfparam name="smallBalance" type="boolean" default="false">
<cfparam name="session.remainBalance" default="0">
<cfset MCObject = createObject("Component","components.Match_Central.MatchCentral").init()>

<!--- if billback is already selected, don't update the reamining dollar field. --->
<cfif checkSelectedBB OR checkSelectedDD OR checkSelectedCR>
	<cfloop from="1" to="#listlen(matchItem)#" index="id">

		<cfif checkSelectedBB>
			<cfset exists = MCObject.checkForBB(listGetAt(matchItem, id),listGetAt(workItem, id))>
			<cfoutput>#exists#</cfoutput>
			<cfabort>
		</cfif>
		<cfif checkSelectedDD>
			<cfset exists = MCObject.checkForDD(listGetAt(matchItem, id),listGetAt(workItem, id))>
			<cfoutput>#exists#</cfoutput>
			<cfabort>
		</cfif>
		<cfif checkSelectedCR>
			<cfset exists = MCObject.checkForCR(listGetAt(matchItem, id),listGetAt(workItem, id))>
			<cfoutput>#exists#</cfoutput>
			<cfabort>
		</cfif>

	</cfloop>
</cfif>

		<cfset session.remainBalance = itemAmount>
		<cfoutput>
			<cfif numberOnly>
				#itemAmount#
			<cfelseif smallBalance>
				#dollarFormat(itemAmount)#
			<cfelse>
				<cfif itemAmount GT 0>
					#dollarFormat(itemAmount)#
				<cfelse>
					<font color="red">#dollarFormat(itemAmount)#</font>	
				</cfif>
			</cfif>
		</cfoutput>

<cfsetting showdebugoutput="false">