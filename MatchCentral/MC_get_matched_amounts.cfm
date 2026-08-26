<cfsetting showdebugoutput="false">

<cfscript>
	MCObject = createObject("Component","components.Match_Central.MatchCentral").init();
	itemAmount = MCObject.GetMatchedAmounts(workItem);
		
	matchingType = MCObject.getMatchingType(workItem);
		
	if (matchingType EQ "BB"){
		itemListFile = "MC_Item_List_BB.cfm";
	} else if (matchingType EQ "CR"){
		itemListFile = "MC_Item_List_DD.cfm";
		SearchSource = "MatchCentralCR";
	} else if (matchingType EQ "DD"){
		itemListFile = "MC_Item_List_DD.cfm";
		SearchSource = "MatchCentralDD";
	}
</cfscript>

<cfif isDefined("numberOnly")>
	<cfinclude template="MC_remaining_dollar.cfm">
<cfelse>
	<cfif showItemList>
		<cfinclude template="#itemListFile#">
	<cfelse>
		<cfinclude template="MC_remaining_dollar.cfm">
	</cfif>
</cfif>