<cfsetting showdebugoutput="true">

<!--- PAGING AND SORTING --->
<cfparam name="initialSearch" default="true">
<cfparam name="pagingmaxrows" default="50">
<cfparam name="pagingstartrow" default="1">
<cfparam name="sortField" default="BB_Approved_Amount">
<cfparam name="sortOrder" default="DESC">

<!--- FILTERING --->
<cfparam name="SESSION.FILTERdistributor" default="1">
<cfparam name="SESSION.FILTERamount" default="true">
<cfparam name="SESSION.FILTERremainingBalance" default="false">
<cfparam name="SESSION.resultsKeyword" default="">
<!---D82085 :: JRS Upgrade 8.0 - BR6 Wildcard Search START--->
<cfparam name="SESSION.FILTERrefnumber" default="true">
<cfparam name="SESSION.FILTERfamily" default="2">
<!---D82085 :: JRS Upgrade 8.0 - BR6 Wildcard Search END--->

<cfscript>
	if (isDefined("amtFilter")){
		SESSION.FILTERamount = amtFilter;
	}
	if (isDefined("distFilter")){
		SESSION.FILTERdistributor = distFilter;
	}
	if (isDefined("balFilter")){
		SESSION.FILTERremainingBalance = balFilter;
	}
	if (isDefined("refFilter")){
		SESSION.FILTERrefnumber = refFilter;
	}
	if (isDefined("keyword")){
		SESSION.resultsKeyword = keyword;
	}

	MCObject = createObject("Component","components.Match_Central.MatchCentral").init();
	workItemType = MCObject.getWorkItemType(workItem);
	matchingType = MCObject.getMatchingType(workItem);
</cfscript>

<cfif isDefined("resetItemList")>
	<div id="waterMark" class="itemListWatermarkMargin">
		ITEM LIST<br /><font size="3">(SELECT AN ITEM FROM THE WORK LIST)</font>
	</div>
	<cfabort>
</cfif>
<!---D40740 :: Heinz BAT: Event error 'Variable APPSETTINGS is undefined' in Match Central START --->
<cfscript>
		genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init();
		appSettings = genSettingsManager.get();
</cfscript>
<!---D40740 :: Heinz BAT: Event error 'Variable APPSETTINGS is undefined' in Match Central END --->

<cfif initialSearch>
	<cfscript>
		MATCHCentral = true;
		source = "Deductions";
		workItem = workItem;
		deduction_id = workItem;
		default_sort = "BBApprovedAmount";
		default_sort_order = "DESC";
		ExcludeLockedBillbacks = 1;
		Status_List = "Work In Progress,Request For App.,Approved,Paid";
		CallingBBSearchFromDD = 1;
		FORM.Distributor_ID = "";		
		FORM.MC_Shr_Ship_to = "";
		FORM.MC_Distributor_Name = "";
		FORM.MC_Bill_To_Name = "";
		FORM.MC_Shr_Bill_To = "";
		FORM.referenceNum = "";
		FORM.MC_Distributor_Family_ID = "";

		workItemInfo = MCObject.DDMgr.getDeduction(workItem);

		if (SESSION.FILTERdistributor EQ 1){
			FORM.MC_Distributor_Family_ID = "";
			FORM.MC_Shr_Ship_to = workItemInfo.Shr_Ship_To;
			FORM.MC_Distributor_Name = workItemInfo.Name;
			if(FORM.MC_Shr_Ship_to == ""){
				FORM.MC_Bill_To_Name = workItemInfo.BillToName;
				FORM.MC_Shr_Bill_To =	 workItemInfo.Shr_Bill_To;
			}
		} else if(SESSION.FILTERdistributor EQ 2){
			FORM.MC_Distributor_Family_ID = workItemInfo.Family_ID;
		}else{
			FORM.MC_Shr_Ship_to = "";
			FORM.MC_Distributor_Name = "";
			FORM.MC_Bill_To_Name = "";
			FORM.MC_Shr_Bill_To = "";			
			FORM.MC_Distributor_Family_ID = "";
		}
		if (SESSION.FILTERrefnumber){
				FORM.referenceNum = workItemInfo.DD_Reference;
		}
		
		if (SESSION.FILTERamount){
			filterAmount = true;
		} else {
			filterAmount = false;
		}
		
		if (workItemType EQ "CR"){
			workItemValue = workItemInfo.dd_amount;
			matchToCredit = true;
		} else if (workItemType EQ "DD"){
			workItemValue = workItemInfo.dd_amount;
			matchToCredit = false;
		}
	</cfscript>
	<cfparam name="FORM.SELECTEDITEMVALUE" default="#workItemValue#">
	<cfparam name="FORM.DOSEARCH" default="1">
	<cfparam name="FORM.source" default="#source#">
	<cfparam name="FORM.BB_Closing_Method" default="2">
	<cfparam name="URL.SECTION_TO_OPEN" default="1">


	<cfinclude template="/billbacks/scorecard/billback_search_result.cfm">
	<!--- <cfinclude template="/billbacks/scorecard/billback_status_tool_tip.cfm" /> --->
	
	<cfset session.get_data = variables.qBillbackSearchResults>
<cfelse>
	<cfif not isDefined("session.get_data")>
		<h2 style="text-align:center;">Your search session has expired.</h2>
		<h3 style="text-align:center;">Please reload the item list by reselecting a work list item.</h3>
		<h5 style="text-align:center;">
			Note: Your session expires when the alloted time set on the server has passed
			before you try and select an option. The default time is approximately 20 
			minutes. These sessions expire for server performance purposes.  
		</h5>
		<cfabort>
	</cfif>
</cfif>

<cfif workItemType EQ "CR">
	<cfset session.remainBalance = session.remainBalance * -1>
</cfif>

<cfif isDefined('keyword')>
	<!--- 
		D115144: Match central Event Error / Anand Rao / 10-May-2022 
		Fix added for CF2021 to list the columns in the query instead of using "SELECT *" 
	--->
	<cfquery name="session.get_data" dbtype="query">
		SELECT 	Billback_ID,
				Billback_Status_ID,
				BB_Code,
				BB_Approved_Amount,
				BB_Date,
				BB_Reference,
				BB_Start_Date,
				BB_End_Date,
				BB_Title,
				referencenum,
				shr_ship_to,
				Name,
				BB_Locked_By_Match_Central,  
				BB_Is_Locked,
				BB_Locked_By_User_ID
		FROM session.get_data
			WHERE 
				(
					(LOWER(name) 			LIKE '%#lcase(keyword)#%' AND name 			IS NOT NULL)
					OR (LOWER(shr_ship_to) 	LIKE '%#lcase(keyword)#%' AND shr_ship_to 	IS NOT NULL)
					OR (LOWER(referencenum)	LIKE '%#lcase(keyword)#%' AND referencenum 	IS NOT NULL)
					OR (LOWER(bb_reference)	LIKE '%#lcase(keyword)#%' AND bb_reference 	IS NOT NULL)
				) 
			<cfif SESSION.FILTERremainingBalance>
				AND BB_Approved_Amount <= #session.remainBalance#
			</cfif>
		ORDER BY #sortField# #sortOrder#
	</cfquery>
<cfelse>
	<cfquery name="session.get_data" dbtype="query">
		SELECT Billback_ID,
				Billback_Status_ID,
				BB_Code,
				BB_Approved_Amount,
				BB_Date,
				BB_Reference,
				BB_Start_Date,
				BB_End_Date,
				BB_Title,
				referencenum,
				shr_ship_to,
				Name,
				BB_Locked_By_Match_Central,  
				BB_Is_Locked,
				BB_Locked_By_User_ID
		FROM session.get_data
		<cfif SESSION.FILTERremainingBalance>
			WHERE BB_Approved_Amount <= #session.remainBalance#
		</cfif>
		ORDER BY #sortField# #sortOrder#
	</cfquery>
</cfif>

<div>
	<cfscript>
		MCObject = createObject("Component","components.Match_Central.MatchCentral").init();
		BBList = MCObject.selectedMatchListByTyp(workItem);
		BBListAll = MCObject.selectedBBlist;
		
		if (NOT isDefined("distid")){
			workItemInfo = MCObject.DDMgr.getDeduction(workItem);
			distid = workItemInfo.distributor_id;
		}
		if (SESSION.FILTERdistributor){
			distributor_id = distid;
		} else {
			distributor_id = "";
			FORM.distributor_name = "";
		}
		
		pagingSortOrder = sortOrder;
		if(sortOrder EQ "ASC"){
			sortImage = "/images/up_1.gif";
			sortOrder = "DESC";
		}else{
			sortImage = "/images/down_1.gif";
			sortOrder = "ASC";
		}
		
		/* Dev Note: 71187 -  For some reason, "pagingstartrow" became -49 */
		if(pagingstartrow < 0)
		{
			pagingstartrow = 1;
		}

		pagingmaxrows = pagingmaxrows;
		pagingstartrow = pagingstartrow;
		lastRecord = pagingstartrow + pagingmaxrows - 1;
					
		if (lastRecord GT session.get_data.recordCount){
			lastRecord = session.get_data.recordCount;
		} else {
			lastRecord = pagingmaxrows + pagingstartrow - 1;
		}
		
		lastPage = int(session.get_data.recordCount/pagingmaxrows) + 1;
		pages2show = 8;
		
		PageStart = 1;
		nextPageStart = 1 + lastRecord;
		prevPageStart = pagingstartrow - pagingmaxrows;
		PageEnd = int(session.get_data.recordCount/pagingmaxrows) * pagingmaxrows + 1;
		
		NextEndCondition = pagingstartrow + pagingmaxrows - 1;
	</cfscript>

<cfoutput>
	<div style="width:200px;float:right;text-align:right;">
		#pagingstartrow# - #lastRecord# of [#session.get_data.recordCount#] Record<cfif session.get_data.recordCount GT 1>s</cfif>
	</div>

	<div style="width:150px;float:right;text-align:right;">
		Show
		<select name="maxRows" 
			id="maxRows"
			onchange="NextPrevSortPageBBmatch(1,'#sortField#','#pagingSortOrder#','BB');"
			style="height:14px;">
			<option value="25" <cfif pagingmaxrows EQ 25>selected</cfif>>25</option>
			<option value="50" <cfif pagingmaxrows EQ 50>selected</cfif>>50</option>
			<option value="100" <cfif pagingmaxrows EQ 100>selected</cfif>>100</option>
			<option value="250" <cfif pagingmaxrows EQ 250>selected</cfif>>250</option>
			<option value="500" <cfif pagingmaxrows EQ 500>selected</cfif>>500</option>
			<option value="500000" <cfif pagingmaxrows EQ 500000>selected</cfif>>All</option>
		</select>
		Records
	</div>

	<div id="accordion">
	    <div id="tab-body">
	        <div id="contents" style="display:none;">
				<table border="0" cellspacing="0" cellpadding="3" width="100%">
		        	<form name="BBFilters" id="BBFilters" style="display:inline;">
						<tr>
							<td class="header"
								style="cursor:pointer;"
						    	onmouseover="this.style.color='##CCC'"
						    	onmouseout="this.style.color='white'" 
						    	onclick="toggleDiv('contents');
										if($('contents').style.display == 'none'){
											$('tabDrop').innerHTML = '<img src=&quot;/images/up2.gif&quot;> Hide Search Filters';
										}else{
											$('tabDrop').innerHTML = '<img src=&quot;/images/down2.gif&quot;> Show Search Filters';
										}">Search Filters</td>
						</tr>
						<tr>
							<td>
								<input name="FILTERamount" 	id="FILTERamount" type="checkbox" value="true" <cfif SESSION.FILTERamount>checked="checked"</cfif>>Filter By Work Item Amount
							</td>
						</tr>
						<tr>
							<td>
								<!---D40282 : MATCH CENTRAL – LIMIT “SEARCH FILTERS” FILTER BY REMAINING BALANCE START --->
								<input name="FILTERremainingBalance"id="FILTERremainingBalance" onClick="if(this.checked == true){alert('With this option checked, the page will reload with each item \nthat is added to or removed from the match list.');}" type="checkbox" value="true" 									
									<cfif SESSION.FILTERremainingBalance OR appSettings.getDDCloseWithEqualBBAmt()>
										checked="checked"
									</cfif>
									<cfif appSettings.getDDCloseWithEqualBBAmt()>
										disabled
									</cfif>
									>
									<!---D40282 : MATCH CENTRAL – LIMIT “SEARCH FILTERS” FILTER BY REMAINING BALANCE END --->
								Filter By Remaining Balance
							</td>
						</tr>
						<!---D82085 :: JRS Upgrade 8.0 - BR6 Wildcard Search START--->
						<tr>
							<td><input name="FILTERrefnumber" id="FILTERrefnumber" type="checkbox" value="true" <cfif SESSION.FILTERrefnumber>checked="checked"	</cfif>>Filter By Reference Number</td>
						</tr>
						
						<tr>
							<td>&nbsp;&nbsp;
								Filter By <br>								
								<input name="FILTERdistributor" id="FILTERdistributor1" type="radio" value="1" <cfif SESSION.FILTERdistributor EQ 1>checked="checked"	</cfif>>Distributor
								<input name="FILTERdistributor" id="FILTERdistributor2" type="radio" value="2" <cfif SESSION.FILTERdistributor EQ 2>checked="checked"	</cfif>>Family
								<input name="FILTERdistributor" id="FILTERdistributor3" type="radio" value="0" <cfif SESSION.FILTERdistributor EQ 0>checked="checked"	</cfif>>None
							</td>
						</tr>
						<!---D82085 :: JRS Upgrade 8.0 - BR6 Wildcard Search END--->
						<tr>
							<td align="center">
								Filter By Keyword:
								<img src="/images/help_small2.gif" onclick="showToolTip('toolTip')" title="Click for help." style="cursor:pointer;">
								<br />
								<input type="text" 	name="resultsKeyword" id="resultsKeyword" 	size="30" maxlength="40" value="#SESSION.resultsKeyword#">
							</td>
						</tr>
						<tr>
							<td align="center" class="header">
								<input name="SETFILTERS" id="SETFILTERS" onclick="setItemListFilters('BB','#workItem#','#distributor_id#');" type="button" value="set filters">
								<textarea ID="MC_CreateList" NAME="MC_CreateList" ROWS="10" COLS="30" style="display:none;"></textarea>
								&nbsp; &nbsp;<input name="CREATELISTBUTTON"  id="CREATELISTBUTTON" onclick="createlist('BB','#workItem#','#distributor_id#');" type="button" value="Create List">
							</td>
						</tr>
					</form>
				</table>
	        </div>
		    <div id="tabDrop" onmouseover="this.style.color='##CCC'"  onmouseout="this.style.color='white'"
		    	onclick="
					toggleDiv('contents');
					if($('contents').style.display == 'none'){
						this.innerHTML = '<img src=&quot;/images/up2.gif&quot;> Hide Search Filters';
					}else{
						this.innerHTML = '<img src=&quot;/images/down2.gif&quot;> Show Search Filters';
					}
				">
					<img src="/images/down2.gif"> Show Search Filters
			</div>
	    </div>
	</div>
	<div id="toolTip" class="toolTip2" style="display:none;">
		Keyword searches on the following fields:<br />
		<li>#application.returned_customer_setting.shard_ship_to_label# name [Payee]</li>
		<li>#application.returned_customer_setting.shard_ship_to_label# number [Payee]</li>
		<li>Billback Number</li>
		<li>Billback Reference Number</li>
	</div>
</cfoutput>
<!--- Added the following paragraph tag for IE 10. Without it the,words "show search filters" would partially cover the word "BILLBACKS" on the header below. --->
<p></p>
<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr>
		<td style="font-size:16px;font-weight:bolder;">BILLBACKS</td>
		<td style="text-align:right;font-size:9px;font-weight:normal;">
			<cfif session.get_data.recordCount GT pagingmaxrows>
			<cfoutput>
				<cfif lastRecord NEQ pagingmaxrows>
					<a href="JavaScript:NextPrevSortPageBBmatch(#PageStart#,'#sortField#','#pagingSortOrder#','BB');" style="margin:0 5px 0 0;"><img src="/images/page_start.gif" border="0"></a>
					<a href="JavaScript:NextPrevSortPageBBmatch(#prevPageStart#,'#sortField#','#pagingSortOrder#','BB');" style="margin:0 15px 0 5px;"><img src="/images/page_prev.gif" border="0"></a>
				<cfelse>
					<span style="margin:0 5px 0 0;"><img src="/images/page_start_inactive.gif" border="0"></span>
					<span style="margin:0 15px 0 5px;"><img src="/images/page_prev_inactive.gif" border="0"></span>
				</cfif>
					
					<cfif lastPage GT 1>
						<cfif pagingstartrow EQ 1>
							[#PageStart#]
						<cfelse>
							<a href="JavaScript:NextPrevSortPageBBmatch(#PageStart#,'#sortField#','#pagingSortOrder#','BB');" style="margin:0 2px 0 2px;">#PageStart#</a>
						</cfif>

						<cfset loopFrom = ((pagingstartrow+pagingmaxrows-1)/pagingmaxrows) - pages2show>
						<cfif loopFrom LT 1>
							<cfset loopFrom = 1>
						<cfelse>
							..
						</cfif>
						<cfset loopTo = loopFrom + pages2show - 1>
						<cfif loopTo GT lastPage>
							<cfset loopTo = lastPage - 1>
						</cfif>

						<cfloop from="#loopFrom#" to="#loopTo#" index="i">
							<cfset page = i + 1>
							<cfset pageStartNum = (pagingmaxrows * i) + 1>
							<cfif pagingstartrow EQ pageStartNum>
								[#page#]
							<cfelse>
								<a href="JavaScript:NextPrevSortPageBBmatch(#pageStartNum#,'#sortField#','#pagingSortOrder#','BB');" style="margin:0 2px 0 2px;">#page#</a>
							</cfif>
						</cfloop>
						
						<cfset lPageStart = int(pagingmaxrows * lastPage - pagingmaxrows) + 1>
						<cfif page NEQ lastPage>
							.. <a href="JavaScript:NextPrevSortPageBBmatch(#lPageStart#,'#sortField#','#pagingSortOrder#','BB');" style="margin:0 2px 0 2px;">#lastPage#</a>
						</cfif>
					</cfif>
				<cfif lastRecord EQ NextEndCondition>
					<a href="JavaScript:NextPrevSortPageBBmatch(#nextPageStart#,'#sortField#','#pagingSortOrder#','BB');" style="margin:0 5px 0 15px;"><img src="/images/page_next.gif" border="0"></a>
					<a href="JavaScript:NextPrevSortPageBBmatch(#PageEnd#,'#sortField#','#pagingSortOrder#','BB');" style="margin:0 0 0 5px;"><img src="/images/page_end.gif" border="0"></a>
				<cfelse>
					<span style="margin:0 5px 0 15px;"><img src="/images/page_next_inactive.gif" border="0"></span>
					<span style="margin:0 0 0 5px;"><img src="/images/page_end_inactive.gif" border="0"></span>
				</cfif>
			</cfoutput>
			<cfelse>
				&nbsp;
			</cfif>
		</td>
	</tr>
	<tr>
		<td id="bb" style="display: none;padding-top: 5px;padding-bottom: 5px; text-align: left" colspan="2">
			<CF_smallLink title = "Add to Match List" url = "javascript:add2MatchList('BB','#matchingType#','#workItemType#');"><br>
		</td>
	</tr>
</table>

	<table border="0" cellpadding="0" cellspacing="0" width="100%">
	<cfoutput>
	<tr>
		<td>
			<table border="0" cellspacing="0" cellpadding="0" width="100%">
				<tr>
					<td class="searchHeader" style="border-bottom:0px;" width="55px"><input type="checkbox" name="checkAll" id="checkAll" onclick="selectAll(this,'BB')"> Status</td>
					<td class="searchHeader" style="border-bottom:0px;" width="100px">
						<cfif sortField EQ "BB_Code">
							<!--- Label 17705 | Changing the label BB Code to Payable No. but leaving the 
							      others to remain the same  -Anand Rao 12/15/08 --->

							<a href="JavaScript:NextPrevSortPageBBmatch(#pagingstartrow#,'BB_Code','#sortOrder#','BB');">Payable ##</a>
							<img src="#sortImage#">
						<cfelse>
							<a href="JavaScript:NextPrevSortPageBBmatch(#pagingstartrow#,'BB_Code','ASC','BB');">Payable ##</a>
						</cfif>
					</td>
					<td class="searchHeader" style="border-bottom:0px;" width="80px">
						<cfif sortField EQ "BB_Date">
							<a href="JavaScript:NextPrevSortPageBBmatch(#pagingstartrow#,'BB_Date','#sortOrder#','BB');">BB Date</a>
							<img src="#sortImage#">
						<cfelse>
							<a href="JavaScript:NextPrevSortPageBBmatch(#pagingstartrow#,'BB_Date','ASC','BB');">BB Date</a>
						</cfif>
					</td>
					<td class="searchHeader" style="border-bottom:0px;" width="130px">
						<cfif sortField EQ "BB_Reference">
							<a href="JavaScript:NextPrevSortPageBBmatch(#pagingstartrow#,'BB_Reference','#sortOrder#','BB');">BB ##</a>
							<img src="#sortImage#">
						<cfelse>
							<a href="JavaScript:NextPrevSortPageBBmatch(#pagingstartrow#,'BB_Reference','ASC','BB');">BB ##</a>
						</cfif>
					</td>
					<td class="searchHeader" style="border-bottom:0px;" width="80px">
						<cfif sortField EQ "BB_Start_Date">
							<a href="JavaScript:NextPrevSortPageBBmatch(#pagingstartrow#,'BB_Start_Date','#sortOrder#','BB');">Start</a>
							<img src="#sortImage#">
						<cfelse>
							<a href="JavaScript:NextPrevSortPageBBmatch(#pagingstartrow#,'BB_Start_Date','ASC','BB');">Start</a>
						</cfif>
					</td>
					<td class="searchHeader" style="border-bottom:0px;" width="80px">
						<cfif sortField EQ "BB_End_Date">
							<a href="JavaScript:NextPrevSortPageBBmatch(#pagingstartrow#,'BB_End_Date','#sortOrder#','BB');">End</a>
							<img src="#sortImage#">
						<cfelse>
							<a href="JavaScript:NextPrevSortPageBBmatch(#pagingstartrow#,'BB_End_Date','ASC','BB');">End</a>
						</cfif>
					</td>
					<td class="searchHeader" style="border-bottom:0px;text-align:right;">
						<cfif sortField EQ "BB_Approved_Amount">
							<a href="JavaScript:NextPrevSortPageBBmatch(#pagingstartrow#,'BB_Approved_Amount','#sortOrder#','BB');">Amount</a>
							<img src="#sortImage#">
						<cfelse>
							<a href="JavaScript:NextPrevSortPageBBmatch(#pagingstartrow#,'BB_Approved_Amount','ASC','BB');">Amount</a>
						</cfif>
					</td>
				</tr>
				<tr>
					<td class="searchHeader" width="55px">&nbsp;</td>
					<td class="searchHeader" width="390px" colspan="4">
						<cfif sortField EQ "BB_Title">
							<a href="JavaScript:NextPrevSortPageBBmatch(#pagingstartrow#,'BB_Title','#sortOrder#','BB');">BB Title</a>
							<img src="#sortImage#">
						<cfelse>
							<a href="JavaScript:NextPrevSortPageBBmatch(#pagingstartrow#,'BB_Title','ASC','BB');">BB Title</a>
						</cfif>
					</td>					
					<td class="searchHeader" colspan="2">
						<cfif sortField EQ "Name">
							<a href="JavaScript:NextPrevSortPageBBmatch(#pagingstartrow#,'Name','#sortOrder#','BB');">Payee</a>
							<img src="#sortImage#">
						<cfelse>
							<a href="JavaScript:NextPrevSortPageBBmatch(#pagingstartrow#,'Name','ASC','BB');">Payee</a>
						</cfif>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</cfoutput>
		<cfoutput query="session.get_data" maxrows="#pagingmaxrows#" startrow="#pagingstartrow#">			
			<cfscript>
				if(listFind(BBList,Billback_ID) GT 0){
					style = "rowSelected";
				} else {
					if (listFind(BBListAll,Billback_ID) GT 0){
						style = "rowSelectedAll";
					} else {
						if (currentRow MOD 2){
							style = "rowEven";
						} else {
							style = "rowOdd";
						}
					}
				}
			</cfscript>
			
			<tr id="#BB_Code#" 
				class="#style#"
				<cfif listFind(BBList,Billback_ID) EQ 0 AND listFind(BBListAll,Billback_ID) EQ 0>
					onmouseover="this.className='hover';" 
					onmouseout="this.className='#style#';"
				</cfif>
				>
				<cfif bb_is_locked>
					<cfset useLakebaseForGetLockedByName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGetLockedByName>
	<cftry>
		<cfset GetLockedByName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#bb_locked_by_user_id#",
				"select" = "name_first + ' ' + name_last as lockedbyname"
			}), "name_first + ' ' + name_last as lockedbyname"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetLockedByName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetLockedByName>
<cfquery name="GetLockedByName" datasource="#application.datasource#">
						SELECT name_first + ' ' + name_last as LockedByName
						FROM _Users
						WHERE user_id = '#bb_locked_by_user_id#'
					</cfquery>
</cfif>
				</cfif>
				<td class="searchRow" id="sel_#currentrow#" colspan="100%">
					<table border="0" cellspacing="0" cellpadding="0" width="100%">
						<tr>
							<td id="#BB_Code#col"
								width="20px"
								<cfif bb_is_locked AND NOT (bb_locked_by_user_id eq request.AccessStructure.User_ID AND BB_Locked_By_Match_Central eq 1)>
									title="Billback is Locked by (#GetLockedByName.LockedByName#)"
								<cfelse>
									<cfif listFind(BBList,Billback_ID) GT 0>
										title="Added &quot;#BB_Code#&quot; to match list."
									<cfelseif listFind(BBListAll,Billback_ID) GT 0>
										title="&quot;#BB_Code#&quot; is matched to another deduction."
									<cfelse>
										title="Add &quot;#BB_Code#&quot; to match list."
									</cfif>
								</cfif>							
								>
								<cfif bb_is_locked>
									<img src='/Images/lock.gif' />
								<cfelse>
									<cfif (listFind(BBListAll,Billback_ID) EQ 0 OR listFind(BBList,Billback_ID) GT 0) AND NOT (bb_is_locked AND NOT (bb_locked_by_user_id eq request.AccessStructure.User_ID AND BB_Locked_By_Match_Central eq 1))>								
										<input type="checkbox" name="IndividualCheckBox" value="#Billback_ID#" id="#Billback_ID#_CheckBox" onclick = "selectSingle(this, 'BB')">	
										<img src='/Images/lock.gif' style="display:none;" id="#Billback_ID#_Lock" title='Added &quot;#BB_Code#&quot; to match list.'/>								
									<cfelse>
										<input type="checkbox" name="IndividualCheckBox" value=""  disabled>
								</cfif>
								</cfif>
								<!--- <input type="hidden" name="#Billback_ID#_workItem" value="#workItem#" id="#Billback_ID#_workItem"> --->
								<input type="hidden" name="workItem" value="#workItem#" id="workItem">
								<input type="hidden" name="#Billback_ID#_Approved_Amount" value="#BB_Approved_Amount#" id="#Billback_ID#_Approved_Amount">
							</td>
							<cfset statusUrl = MCObject.getBBStatusImageString(Billback_Status_ID)>
							<td id="#bb_code#lockImage"
								width="33px" 
								style="background-image: url('#statusUrl#');background-repeat:no-repeat;background-position:center center;"
								<cfif bb_is_locked>
									title="Billback is Locked by (#GetLockedByName.LockedByName#)"
								<cfelse>
									<cfif listFind(BBList,Billback_ID) GT 0>
										title="Added &quot;#BB_Code#&quot; to match list."
									<cfelseif listFind(BBListAll,Billback_ID) GT 0>
										title="&quot;#BB_Code#&quot; is matched to another deduction."
									<cfelse>
										title="Add &quot;#BB_Code#&quot; to match list."
									</cfif>
								</cfif>
								>
							</td>
							<td width="100px">
								<CF_smallLink 
									title = "#trim(bb_code)#" 
									url = "javascript:bbPreview('/billbacks/capture/bb_preview.cfm','#billback_id#');"
									parameters = "style='font-size:10px;' title='view the details for billback #bb_code#'">
							</td>
							<td width="80px">#trim(dateformat(BB_Date, 'mm/dd/yyyy'))#</td>
							<td width="130px">#trim(BB_Reference)#</td>
							<td width="80px">#trim(dateformat(BB_Start_Date, 'm/d/yyyy'))#</td>
							<td width="80px">#trim(dateformat(BB_End_Date, 'm/d/yyyy'))#</td>
							<td align="right">#trim(dollarFormat(BB_Approved_Amount))#</td>
						</tr>
						<tr>
							<td colspan="2" width="40px">&nbsp;</td>
							<td colspan="4" width="390px">#trim(BB_Title)#</td>
							<td colspan="2">#trim(Name)#</td>
						</tr>
					</table>
				</td>
			</tr>
		</cfoutput>
	</table>
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
		<tr>
			<td style="text-align:right;font-size:9px;font-weight:normal;">
				<cfif session.get_data.recordCount GT pagingmaxrows>	
				<cfoutput>
					<cfif lastRecord NEQ pagingmaxrows>
						<a href="JavaScript:NextPrevSortPageBBmatch(#PageStart#,'#sortField#','#pagingSortOrder#','BB');" style="margin:0 5px 0 0;"><img src="/images/page_start.gif" border="0"></a>
						<a href="JavaScript:NextPrevSortPageBBmatch(#prevPageStart#,'#sortField#','#pagingSortOrder#','BB');" style="margin:0 15px 0 5px;"><img src="/images/page_prev.gif" border="0"></a>
					<cfelse>
						<span style="margin:0 5px 0 0;"><img src="/images/page_start_inactive.gif" border="0"></span>
						<span style="margin:0 15px 0 5px;"><img src="/images/page_prev_inactive.gif" border="0"></span>
					</cfif>
						<cfif lastPage GT 1>
							<cfif pagingstartrow EQ 1>
								[#PageStart#]
							<cfelse>
								<a href="JavaScript:NextPrevSortPageBBmatch(#PageStart#,'#sortField#','#pagingSortOrder#','BB');" style="margin:0 2px 0 2px;">#PageStart#</a>
							</cfif>
	
							<cfset loopFrom = ((pagingstartrow+pagingmaxrows-1)/pagingmaxrows) - pages2show>
							<cfif loopFrom LT 1>
								<cfset loopFrom = 1>
							<cfelse>
								..
							</cfif>
							<cfset loopTo = loopFrom + pages2show - 1>
							<cfif loopTo GT lastPage>
								<cfset loopTo = lastPage - 1>
							</cfif>
	
							<cfloop from="#loopFrom#" to="#loopTo#" index="i">
								<cfset page = i + 1>
								<cfset pageStartNum = (pagingmaxrows * i) + 1>
								<cfif pagingstartrow EQ pageStartNum>
									[#page#]
								<cfelse>
									<a href="JavaScript:NextPrevSortPageBBmatch(#pageStartNum#,'#sortField#','#pagingSortOrder#','BB');" style="margin:0 2px 0 2px;">#page#</a>
								</cfif>
							</cfloop>
							
							<cfset lPageStart = int(pagingmaxrows * lastPage - pagingmaxrows) + 1>
							<cfif page NEQ lastPage>
								.. <a href="JavaScript:NextPrevSortPageBBmatch(#lPageStart#,'#sortField#','#pagingSortOrder#','BB');" style="margin:0 2px 0 2px;">#lastPage#</a>
							</cfif>
						</cfif>
					<cfif lastRecord EQ NextEndCondition>
						<a href="JavaScript:NextPrevSortPageBBmatch(#nextPageStart#,'#sortField#','#pagingSortOrder#','BB');" style="margin:0 5px 0 15px;"><img src="/images/page_next.gif" border="0"></a>
						<a href="JavaScript:NextPrevSortPageBBmatch(#PageEnd#,'#sortField#','#pagingSortOrder#','BB');" style="margin:0 0 0 5px;"><img src="/images/page_end.gif" border="0"></a>
					<cfelse>
						<span style="margin:0 5px 0 15px;"><img src="/images/page_next_inactive.gif" border="0"></span>
						<span style="margin:0 0 0 5px;"><img src="/images/page_end_inactive.gif" border="0"></span>
					</cfif>
				</cfoutput>
				<cfelse>
					&nbsp;
				</cfif>
			</td>
		</tr>
	</table>
</div>