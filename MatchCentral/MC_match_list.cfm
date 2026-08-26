<cfsetting  showdebugoutput="false">
<cfset matchItemArray = []>
<cfset MCObject = createObject("Component","components.Match_Central.MatchCentral").init()>
<cfset selectedlist = ''>
<cfif isDefined("clear")>
	<cfset clearType = clear>
	<cfswitch expression="#clearType#">
		<cfcase value="1">
			<cfset itemsExist = MCObject.clearMatchListItem(workItemID,IDremove)>
			<cfscript>
			if (itemsExist)
			{
				BBList = MCObject.selectedMatchListByTyp(workItemID);
				BBListAll = MCObject.selectedBBlist;
			}
			</cfscript>
			<cfset selectedlist = BBListAll />
			<cfif not itemsExist>
				<div id="waterMark" class="matchListWatermarkMargin">MATCH LIST</div>
				<cfabort>
			</cfif>
		</cfcase>
		<cfcase value="2">
			<cfset MCObject.clearMatchList(workItemID)>
			<div id="waterMark" class="matchListWatermarkMargin">MATCH LIST</div>
			<cfabort>
		</cfcase>
		<cfcase value="4">
			<div id="waterMark" class="matchListWatermarkMargin">MATCH LIST</div>
			<cfabort>
		</cfcase>
	</cfswitch>
</cfif>


<cfif isDefined("bbtomatch")>
	<cfset selectedlist = bbtomatch>
<cfelseif isDefined("ddtomatch")>
	<cfset selectedlist = ddtomatch>
<cfelseif isDefined("crtomatch")>
	<cfset selectedlist = crtomatch>
</cfif>

<cfif len(selectedlist)>
	
	<cfloop from="1" to="#listlen(selectedlist)#" index="id">
		<cfscript>
			// ADD TO MATCHLIST FUNCTION
			if (isDefined("bbtomatch")){
				MCObject.addBBToMatchList(listgetat(selectedlist,id),workItemID);
			} else if (isDefined("ddtomatch")){
				MCObject.addDDToMatchList(listgetat(selectedlist,id),workItemID);
			} else if (isDefined("crtomatch")){
				MCObject.addCRToMatchList(listgetat(selectedlist,id),workItemID);
			}
		</cfscript>

	</cfloop>
	
</cfif>
	
		<cfscript>
			session.remainBalance = MCObject.getMatchedAmounts(workItemID);

			// GET XML DATA IN AN ARRAY TO OUTPUT TO MATCHLIST
			matchItemArray = MCObject.getMatchListXMLArray(workItemID);
			matchType = MCObject.getMatchingType(workItemID);
			workType = MCObject.getWorkItemType(WorkItemID);

			if (matchType EQ "DD"){
				pageTitle = "Deductions to Match";
				col1 = "Deduction";
			} else if (matchType EQ "CR"){
				pageTitle = "Credits to Match";
				col1 = "Credit";
			} else if (matchType EQ "BB"){
				pageTitle = "Billbacks to Match";
				col1 = "Billback";
			}
		</cfscript>

<!--- SHOW WATERMARK IF XML FILE WITH MATCHES DOES NOT EXIST --->
<cfif arraylen(MatchItemArray) EQ 0>
	<div id="waterMark" class="matchListWatermarkMargin">MATCH LIST</div>
	<cfabort>
</cfif>

<cfoutput>
<div>
	<table border="0" cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td align="left" colspan="2"><h4 style="display:inline;">#pageTitle#</h4></td>
			<td align="right" colspan="2"></td>
		</tr>
		<tr>
			<td class="searchHeader">#col1#</td>
			<td class="searchHeader" align="right">Amount</td>
			<td class="searchHeader" align="right">Cut</td>
		</tr>
		<cfloop from="1" to="#arrayLen(matchItemArray)#" index="row">
			
			<cfscript>
				if (matchType EQ "DD"){
					id = matchItemArray[row].deduction_id;
					code = matchItemArray[row].DD_DedID;
					title = "";
					amt = matchItemArray[row].DD_Amount;
				} else if (matchType EQ "CR"){
					id = matchItemArray[row].deduction_id;
					code = matchItemArray[row].DD_DedID;
					title = "";
					amt = matchItemArray[row].DD_Amount;
				} else if (matchType EQ "BB"){
					id = matchItemArray[row].billback_id;
					code = matchItemArray[row].bb_code;
					title = matchItemArray[row].bb_title;
					amt = matchItemArray[row].BB_Approved_Amount;
				}
				
				if (row MOD 2) {
					style = "rowEven";
				} else {
					style = "rowOdd";
				}
			</cfscript>

			<tr>
				<td class="searchRow" colspan="3">
					<table border="0" cellspacing="0" cellpadding="0" width="100%">
						<tr class="#style#">
							<td>#code#</td>
							<td align="right">#dollarFormat(amt)#</td>
							<td align="right">
								<a href="
									javascript:
									if (Ajax.activeRequestCount == 0){
										clearMatchListItem('#id#','#workItemID#',#amt#,'#code#','#matchType#','#workType#');
									}
										"><img src="/images/scissor.gif" border="0" title="Remove from work list." /></a>
							</td>
						</tr>
						<tr class="#style#">
							<td colspan="3">#title#</td>
						</tr>
					</table>
				</td>
			</tr>
		</cfloop>
	</table>
</div>
</cfoutput>