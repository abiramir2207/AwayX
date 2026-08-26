<!-----------------------------------------------------------------------------

FILE NAME:		MC_work_list.cfm
DESCRIPTION:	Work list display file for Match Central
CREATED BY:		Daniel Arsenault
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	9-Dec-2008	Added check number and 
							DD_Reference fields

------------------------------------------------------------------------------>


<cfsetting  showdebugoutput="false">
<cfset MCObject = createObject("Component","components.Match_Central.MatchCentral").init()>
<cfparam name="typ" default="none">

<cfif isDefined("clear") and clear EQ 1>
	<cfset itemsExist = MCObject.clearWorkListItem(typidremove)>
	<cfif not itemsExist>
		<div id="waterMark" class="workListWatermarkMargin">WORK LIST</div>
		<cfabort>
	</cfif>	
<cfelseif isDefined("clear") and clear EQ 2>
	<cfset MCObject.clearWorkList()>
	<div id="waterMark" class="workListWatermarkMargin">WORK LIST</div>
	<cfabort>
</cfif>


<!--- ADD TO WORKLIST FUNCTION --->
<cfif isDefined("typid")>

	<cfloop from="1" to="#listlen(typid)#" index="id">
		<cfset MCObject.addToWorkList(#listGetAt(typid, id)#,typ,matchTyp)>
	</cfloop>

<cfelse>
	<!--- Display the watermark if the file does not exist. --->
	<cfif NOT fileExists("#MCObject.MatchCentralPath#\worklist.xml")>
		<div id="waterMark" class="workListWatermarkMargin">WORK LIST</div>
		<cfabort>
	</cfif>
</cfif>

<!--- GET XML DATA IN AN ARRAY TO OUTPUT TO WORKLIST --->
<cfset itemArray = MCObject.getWorkListXMLArray()>

<cfoutput>
<div>  	
	<table border="0" cellpadding="1" cellspacing="0" width="100%">
		<tr>
			<td align="left" colspan="3"><h4 style="display:inline;">Work List</h4></td>
			<td align="right" colspan="2">
				<CF_smallLink 
					title = "clear" 
					url = "javascript:clearWorkList();">
			</td>
		</tr>
		<tr>
			<td class="searchHeader" width="20px">&nbsp;</td>
			<td class="searchHeader" width="100px">ID ##</td>
			<td class="searchHeader" align="right" width="70px">Amt</td>
			<td class="searchHeader" align="right" width="70px">Bal</td>
			<td class="searchHeader" align="right" width="20px">Cut</td>
		</tr>

		<cfloop from="1" to="#arrayLen(itemArray)#" index="row">

			<cfscript>
				workItemType = itemArray[row].typ;
				matchType = itemArray[row].match_type;
				BillTo_ID = "";
				BillTo_Name = "";
				Payee_ID = "";
				Payee_Name= "";
				if (workItemType EQ "DD"){
					workItemID = itemArray[row].deduction_id;
					code = itemArray[row].dd_dedid;
					amount = itemArray[row].dd_amount;
					Distributor_ID = itemArray[row].distributor_id;
					OnClickStr = "workThisItemDD('#workItemID#','#amount#',#row#,'#Distributor_ID#');";
					Chk_No = itemArray[row].DD_Check_Number;
					Ref_No = itemArray[row].DD_Reference;
					qWorkItemInfo = MCObject.DDMgr.getDeduction(workItemID);
						
					if (Distributor_ID NEQ ""){
						distInfo = MCObject.getDistributorInfo(qWorkItemInfo.distributor_id);
						workItemInfo = "#application.returned_customer_setting.shard_ship_to_label#: " & distInfo.Name & " (" & qWorkItemInfo.Shr_Ship_To & ")";
					} else {
						workItemInfo = "";
					}

					if (qWorkItemInfo.Shr_Bill_To NEQ ""){
						BillTo_ID = qWorkItemInfo.Shr_Bill_To;
						BillTo_Name = qWorkItemInfo.BillToName;
					}

				} else if (workItemType EQ "CR"){
					workItemID = itemArray[row].deduction_id;
					code = itemArray[row].DD_DedID;
					amount = itemArray[row].DD_Amount;
					Distributor_ID = itemArray[row].distributor_id;
					OnClickStr = "workThisItemCR('#workItemID#','#amount#',#row#,'#Distributor_ID#');";
					Chk_No = itemArray[row].DD_Check_Number;
					Ref_No = itemArray[row].DD_Reference;
					qWorkItemInfo = MCObject.DDMgr.getDeduction(workItemID);
					if (Distributor_ID NEQ ""){
						distInfo = MCObject.getDistributorInfo(qWorkItemInfo.distributor_id);
						workItemInfo = "#application.returned_customer_setting.shard_ship_to_label#: " & distInfo.Name & " (" & qWorkItemInfo.Shr_Ship_To & ")";
					} else {
						workItemInfo = "";
					}
					if (qWorkItemInfo.Shr_Bill_To NEQ ""){
						BillTo_ID = qWorkItemInfo.Shr_Bill_To;
						BillTo_Name = qWorkItemInfo.BillToName;
					}
					
					
				} else if (workItemType EQ "BB"){
					workItemID = itemArray[row].billback_id;
					code = itemArray[row].bb_code;
					amount = itemArray[row].bb_approved_amount;
					Payee_ID = itemArray[row].payee_id;
					Payee_Name = itemArray[row].payee_name;
					matchingType = itemArray[row].match_type;
					OnClickStr = "workThisItemBB('#workItemID#','#amount#',#row#);";
					qWorkItemInfo = MCObject.getBBInfo(workItemID);
					workItemInfo = "";
		
				}
				
				if (isDefined("rowHilite") AND rowHilite EQ row){
					session.workingAmount = amount;
				}
				
				balance = MCObject.GetMatchedAmounts(workItemID);

				if (row MOD 2){
					style = "roweven";
				} else {
					style = "rowodd";
				}
			</cfscript>
	<tr>
		<td colspan="100%" <cfif isDefined("rowHilite") AND rowHilite EQ row>bgcolor="lightblue" class="searchrow"<cfelse>class="searchrow #style#" onmouseover="this.className='hover';" onmouseout="this.className='#style#';"</cfif>>
			<table border="0" cellpadding="1" cellspacing="0" width="100%">
				<tr>
					<td width="20px"
						<cfif isDefined("rowHilite") AND rowHilite EQ row>
							title="Reload item list." 
							title="Reload item list." 
							onClick="#OnClickStr#"
							style="cursor:pointer;background-image:url('/images/recycle1.gif');background-position:center center;background-repeat:no-repeat;"
						</cfif>
						>
						<cfif isDefined("rowHilite") AND rowHilite EQ row>
							&nbsp;
						<cfelse>
							<input type="radio"
								name="item" 
								value="#workItemID#" 
								title="Select to work this item."
								onClick="#OnClickStr#">
						</cfif>
					</td>
					<td title="#code#" width="100px">
						<cfif len(code) GT 12>#left(code,12)#...<cfelse>#code#</cfif>
					</td>
					<td width="70px" align="right">#dollarformat(amount)#</td>
					<td width="70px" align="right"><div id="remBal2#row#">#dollarformat(balance)#</div></td>
					<td align="right" width="20px">
						<a href="javascript:clearWorkListItem('#workItemID#','#workItemType#');">
							<img src="/images/scissor.gif" border="0" title="Remove from work list." />
						</a>
					</td>
				</tr>
				<cfif BillTo_ID NEQ "">
					<tr>
						<td width="20px">&nbsp;</td>
						<td colspan="5">#application.returned_customer_setting.billto_label# : #BillTo_Name# (#BillTo_ID#)&nbsp;</td>
					</tr>
				</cfif>
				<cfif ((workItemType EQ "BB") AND (Payee_Name NEQ "" AND Payee_ID NEQ ""))>
					<tr>
						<td width="20px"></td>
						<td colspan="5">Payee : #Payee_Name# (#Payee_ID#)&nbsp;</td>
					</tr>
				</cfif>				
				<cfif workItemInfo NEQ "">
					<tr>
						<td width="20px">&nbsp;</td>
						<td colspan="5">#workItemInfo#&nbsp;</td>
					</tr>
				</cfif>

				
				<cfif (workItemType EQ "DD") OR (workItemType EQ "CR")>
					<tr>
						<td width="20px">&nbsp;</td>
						<td colspan="5">Chk ##: #Chk_No#&nbsp;&nbsp;#MCObject.stDeductionLabels["Reference"]#: #Ref_No#</td>
					</tr>
				</cfif>			
			</table>
		</td>
	</tr>
		</cfloop>
	</table>
</div>
</cfoutput>