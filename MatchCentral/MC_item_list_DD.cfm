<cfsetting showdebugoutput="false">

<!--- PAGING AND SORTING --->
<cfparam name="initialSearch" default="true">
<cfparam name="pagingmaxrows" default="50">
<cfparam name="pagingstartrow" default="1">
<cfparam name="sortField" default="DD_Amount">
<cfparam name="sortOrder" default="DESC">
<cfparam name="session.remainBalance" default="1000000">

<!--- FILTERING --->
<cfparam name="SESSION.FILTERdistributor" default="true">
<cfparam name="SESSION.FILTERamount" default="true">
<cfparam name="SESSION.FILTERremainingBalance" default="false">
<cfparam name="SESSION.resultsKeyword" default="">

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
	if (isDefined("keyword")){
		SESSION.resultsKeyword = keyword;
	}
</cfscript>

<cfif isDefined("resetItemList")>
	<div id="waterMark" class="itemListWatermarkMargin">
		ITEM LIST<br /><font size="3">(SELECT AN ITEM FROM THE WORK LIST)</font>
	</div>
	<cfabort>
</cfif>

<cfscript>
	MCObject = createObject("Component","components.Match_Central.MatchCentral").init();
	workItemType = MCObject.getWorkItemType(workItem);
	matchingType = MCObject.getMatchingType(workItem);
	//D40282 : MATCH CENTRAL – LIMIT “SEARCH FILTERS” FILTER BY REMAINING BALANCE START
	genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init();
	appSettings = genSettingsManager.get();
	//D40282 : MATCH CENTRAL – LIMIT “SEARCH FILTERS” FILTER BY REMAINING BALANCE END
</cfscript>

<cfif initialSearch>
	<cfscript>
		FORM.Filter_Attached = 1;
		FORM.Filter_Closed = 1;
		FORM.IsParentDeduction = 1;
		FORM.MC_Shr_Ship_to = "";
		FORM.MC_Distributor_Name = "";
		FORM.MC_Shr_Bill_To = "";
		FORM.MC_Bill_To_Name = "";
		workList = MCObject.workListIDList;
		isMatchCentral = true;
		businessSegmentID = "";
				
		if (workItemType EQ "CR" OR workItemType EQ "DD"){
			if (workItemType EQ "CR"){
				SearchSource  = "MatchCentralDD";
				sortField = "DD_Amount";
				sortOrder = "DESC";
			} else if (workItemType EQ "DD"){
				SearchSource  = "MatchCentralCR";
				sortField = "DD_Amount";
				sortOrder = "ASC";
			}
			CRDInfo = MCObject.DDMgr.getDeduction(workItem);
			
			if (NOT SESSION.FILTERdistributor){
				distid = "";
				FORM.MC_Shr_Ship_to = "";
				FORM.MC_Distributor_Name = "";
				FORM.MC_Bill_To_Name = "";
				FORM.MC_Shr_Bill_To =	 "";
			} else {
				distid = CRDInfo.distributor_id;
				FORM.MC_Shr_Ship_to = CRDInfo.Shr_Ship_To;
				FORM.MC_Distributor_Name = CRDInfo.Name;
				FORM.MC_Bill_To_Name = CRDInfo.BillToName;
				FORM.MC_Shr_Bill_To =	 CRDInfo.Shr_Bill_To;
			}

			/* Business Segment ID of the Deduction's Distributor */
			businessSegmentID = CRDInfo.Dist_Business_Segment_ID;

			if (SESSION.FILTERamount){
				FORM.DDAmountFilter = CRDInfo.DD_Amount * -1;
			} else {
				FORM.DDAmountFilter = "";
			}

		}
		if (workItemType EQ "BB"){
			BBInfo = MCObject.getBBInfo(workItem);
			if (NOT SESSION.FILTERdistributor){
				distid = "";
				FORM.MC_Shr_Ship_to = "";
				FORM.MC_Distributor_Name = "";
				FORM.MC_Bill_To_Name = "";
				FORM.MC_Shr_Bill_To =	 "";
				FORM.MC_Vendor_ID = "";
				FORM.MC_Vendor_Name = "";

			} else {
				distid = BBInfo.Dist_ID;
				FORM.MC_Shr_Ship_to = BBInfo.Payee_ID;
				FORM.MC_Distributor_Name = BBInfo.Payee_Name;
				FORM.MC_Bill_To_Name = BBInfo.Bill_To_Name;
				FORM.MC_Shr_Bill_To =	 BBInfo.Shr_Bill_To;
				FORM.MC_Vendor_ID = BBInfo.MC_Vendor_ID;
				FORM.MC_Vendor_Name = BBInfo.MC_Vendor_Name;
			}

			/* Business Segment ID of the Billback's payee */			
			businessSegmentID = BBInfo.Payee_Business_Segment_ID;

			if (matchingType EQ "DD"){
				SearchSource  = "MatchCentralDD";
				sortField = "DD_Amount";
				sortOrder = "DESC";
				
				if (SESSION.FILTERamount){
					FORM.DDAmountFilter = BBInfo.BB_Approved_Amount;
				} else {
					FORM.DDAmountFilter = "";
				}
				
			} else if (matchingType EQ "CR"){
				SearchSource  = "MatchCentralCR";
				sortField = "DD_Amount";
				sortOrder = "ASC";
				matchToBB = true;
				
				if (SESSION.FILTERamount){
					FORM.DDAmountFilter = BBInfo.BB_Approved_Amount;
				} else {
					FORM.DDAmountFilter = "";
				}
								
			}
			
		}
	</cfscript>
	<cfinclude template="/deductions/search_screens/ded_search_query.cfm">
	<cfset session.get_data = get_data>

	<!--- Credits should have the biggest negative value as the first record in the display and so I am using "ASC" --->
	<cfif workItemType eq "DD" AND matchingType eq "CR">
		<cfset sortOrder = "ASC">
	</cfif>
	
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

<div>
	<cfscript>
		if (workItemType EQ "CR" OR workItemType EQ "DD"){
			amountFilter = session.remainBalance * -1;
			if (workItemType EQ "CR"){
				SQLOpr = "<=";
			} else if (workItemType EQ "DD"){
				SQLOpr = ">=";
			}
		} else if (workItemType EQ "BB"){
			amountFilter = session.remainBalance;
			SQLOpr = "<=";
		}
	</cfscript>

	<cfif isDefined('keyword')>
		<cfquery name="session.get_data" dbtype="query">
			SELECT 	#ArrayToList(session.get_data.getColumnNames())#
			FROM session.get_data
				WHERE 
					(
						(LOWER(CustomerName) 		LIKE '%#lcase(keyword)#%' AND CustomerName 		IS NOT NULL)
						OR (LOWER(Shr_ship_to) 		LIKE '%#lcase(keyword)#%' AND Shr_ship_to 		IS NOT NULL)
						OR (LOWER(Name)				LIKE '%#lcase(keyword)#%' AND Name 				IS NOT NULL)
						OR (LOWER(Shr_Bill_To) 		LIKE '%#lcase(keyword)#%' AND Shr_Bill_To 		IS NOT NULL)
						OR (LOWER(DD_Reference) 	LIKE '%#lcase(keyword)#%' AND DD_Reference 		IS NOT NULL)
						OR (LOWER(DD_Check_Number) 	LIKE '%#lcase(keyword)#%' AND DD_Check_Number 	IS NOT NULL)
					)
				<cfif SESSION.FILTERremainingBalance>
					AND DD_Amount #SQLOpr# #amountFilter#
				</cfif>
			ORDER BY #sortField# #sortOrder#
		</cfquery>
	<cfelse>
		<cfquery name="session.get_data" dbtype="query">
			SELECT 	#ArrayToList(session.get_data.getColumnNames())#
			FROM session.get_data
			<cfif SESSION.FILTERremainingBalance>
				WHERE DD_Amount #SQLOpr# #amountFilter#
			</cfif>
			ORDER BY #sortField# #sortOrder#
		</cfquery>
	</cfif>
	
	<cfscript>
		if (matchingType EQ "CR"){
			title = "CREDITS";
		} else if (matchingType EQ "DD"){
			title = "DEDUCTIONS";
		}
		
		if (NOT isDefined("distid")){
			if (workItemType EQ "BB"){
				BBInfo = MCObject.getBBInfo(workItem);
				distid = BBInfo.Dist_ID;
			} else if (workItemType EQ "CR" OR workItemType EQ "DD") {
				DDInfo = MCObject.DDMgr.getDeduction(workItem);
				distid = DDInfo.distributor_id;
			}
		}
		
		// SORTING VARS
		pagingSortOrder = sortOrder;
		if(sortOrder EQ "ASC"){
			sortImage = "/images/up_1.gif";
			sortOrder = "DESC";
		}else{
			sortImage = "/images/down_1.gif";
			sortOrder = "ASC";
		}		
		
		// PAGING VARS
		pagingmaxrows = pagingmaxrows;
		pagingstartrow = pagingstartrow;
		lastRecord = pagingstartrow + pagingmaxrows - 1;
					
		if (lastRecord GT session.get_data.recordCount){
			lastRecord = session.get_data.recordCount;
		} else {
			lastRecord = pagingmaxrows + pagingstartrow - 1;
		}
		
		PageStart = 1;
		nextPageStart = 1 + lastRecord;
		prevPageStart = pagingstartrow - pagingmaxrows;
		PageEnd = int(session.get_data.recordCount/pagingmaxrows) * pagingmaxrows + 1;
				
		NextEndCondition = pagingstartrow + pagingmaxrows - 1;
		
		lastPage = int(session.get_data.recordCount/pagingmaxrows) + 1;
		pages2show = 8;
		
		// WORK ITEM LISTS
		workList = MCObject.selectedMatchListByTyp(workItem);
		workListAll = MCObject.workListIDList & "," & MCObject.selectedDDList & "," & MCObject.selectedCRlist;
		
		// REMOVE DUPLICATES FROM THE 'ALL' LIST, TO DISPLAY PROPER FORMATTING
		for (i=1;i LTE listLen(workList);i=i+1){
			elemToDelete = listGetAt(workList,i);
			elemFound = listFind(workListAll,elemToDelete);
			if (elemFound GT 0){
				workListAll = listDeleteAt(workListAll,elemFound);
			}
		}
	</cfscript>

	<cfoutput>
		<div style="width:200px;float:right;text-align:right;">
			#pagingstartrow# - #lastRecord# of [#session.get_data.recordCount#] Record<cfif session.get_data.recordCount GT 1>s</cfif>
		</div>
	
		<div style="width:150px;float:right;text-align:right;">
			Show
			<select name="maxRows" id="maxRows" onchange="NextPrevSortPageDDmatch(1,'#sortField#','#pagingSortOrder#','DD');">
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
								<input name="FILTERamount"
									id="FILTERamount"
									type="checkbox" 
									value="true" 
									<cfif SESSION.FILTERamount>
										checked="checked"
									</cfif>>
								Filter By Work Item Amount
							</td>
						</tr>
						<tr>
							<td>
								<input name="FILTERdistributor"
									id="FILTERdistributor"
									type="checkbox" 
									value="true" 
									<cfif SESSION.FILTERdistributor>
										checked="checked"
									</cfif>>
								Filter by #application.returned_customer_setting.distributor_label_singular#
							</td>
						</tr>
						<tr>
							<td>
								
								<input name="FILTERremainingBalance"
									id="FILTERremainingBalance"
									onClick="
										if(this.checked == true){
											alert('With this option checked, the page will reload with each item \nthat is added to or removed from the match list.');
										}
									"
									type="checkbox" 
									value="true" 
									<!--- D40282 : MATCH CENTRAL – LIMIT “SEARCH FILTERS” FILTER BY REMAINING BALANCE START--->
									<cfif SESSION.FILTERremainingBalance OR appSettings.getDDCloseWithEqualBBAmt()>
										checked="checked"
									</cfif>
									<cfif appSettings.getDDCloseWithEqualBBAmt()>
										disabled
									</cfif>
									>
									<!--- D40282 : MATCH CENTRAL – LIMIT “SEARCH FILTERS” FILTER BY REMAINING BALANCE END--->
								Filter by Remaining Balance
							</td>
						</tr>
						<tr>
							<td align="center">
								Filter By Keyword:
								<img src="/images/help_small2.gif" 
									onclick="showToolTip('toolTip')"
									title="Click for help."
									style="cursor:pointer;">
								<br />
								<input type="text" 
									name="resultsKeyword" 
									id="resultsKeyword"
									size="30" 
									maxlength="40"
									value="#SESSION.resultsKeyword#">
							</td>
						</tr>
						<tr>
							<td align="center" class="header">
								<input name="SETFILTERS"
									id="SETFILTERS"
									onclick="setItemListFilters('DD','#workItem#','#distid#');"
									type="button" 
									value="set filters">
								<textarea ID="MC_CreateList" NAME="MC_CreateList" ROWS="10" COLS="30" style="display:none;"></textarea>
								&nbsp; &nbsp;<input name="CREATELISTBUTTON" onclick="createlist('DD','#workItem#','#distid#');" type="button" value="Create List">		
							</td>
						</tr>
					</form>
				</table>
	        </div>
		    <div id="tabDrop"
		    	onmouseover="this.style.color='##CCC'"
		    	onmouseout="this.style.color='white'"
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
		<li>#application.returned_customer_setting.shard_ship_to_label# name</li>
		<li>#application.returned_customer_setting.shard_ship_to_label# number</li>
		<li>#application.returned_customer_setting.billto_label# name</li>
		<li>#application.returned_customer_setting.billto_label# number</li>
		<li>Deduction Check Number</li>
		<li>#MCObject.stDeductionLabels["Reference"]#</li>
	</div>
	</cfoutput>
	
<cfquery name="vars.qSetting" datasource="#application.datasource#">
	SELECT split_billback
	  FROM _Application_Settings
</cfquery>
<cfset vars.split_billback = vars.qSetting.split_billback>
<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr>
		<td style="font-size:16px;font-weight:bolder;"><cfoutput>#title#</cfoutput></td>
		<td style="text-align:right;font-size:9px;font-weight:normal;">
			<cfif session.get_data.recordCount GT pagingmaxrows>	
			<cfoutput>
				<cfif lastRecord NEQ pagingmaxrows>
					<a href="JavaScript:NextPrevSortPageDDmatch(#PageStart#,'#sortField#','#pagingSortOrder#','DD');" style="margin:0 5px 0 0;"><img src="/images/page_start.gif" border="0"></a>
					<a href="JavaScript:NextPrevSortPageDDmatch(#prevPageStart#,'#sortField#','#pagingSortOrder#','DD');" style="margin:0 15px 0 5px;"><img src="/images/page_prev.gif" border="0"></a>
				<cfelse>
					<span style="margin:0 5px 0 0;"><img src="/images/page_start_inactive.gif" border="0"></span>
					<span style="margin:0 15px 0 5px;"><img src="/images/page_prev_inactive.gif" border="0"></span>
				</cfif>
				<cfif lastPage GT 1>
					<cfif pagingstartrow EQ 1>
						[#PageStart#]
					<cfelse>
						<a href="JavaScript:NextPrevSortPageDDmatch(#PageStart#,'#sortField#','#pagingSortOrder#','DD');" style="margin:0 2px 0 2px;">#PageStart#</a>
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
									<a href="JavaScript:NextPrevSortPageDDmatch(#pageStartNum#,'#sortField#','#pagingSortOrder#','DD');" style="margin:0 2px 0 2px;">#page#</a>
								</cfif>
							</cfloop>
							
							<cfset lPageStart = int(pagingmaxrows * lastPage - pagingmaxrows) + 1>
							<cfif page NEQ lastPage>
								.. <a href="JavaScript:NextPrevSortPageDDmatch(#lPageStart#,'#sortField#','#pagingSortOrder#','DD');" style="margin:0 2px 0 2px;">#lastPage#</a>
							</cfif>
						</cfif>
				<cfif lastRecord EQ NextEndCondition>
					<a href="JavaScript:NextPrevSortPageDDmatch(#nextPageStart#,'#sortField#','#pagingSortOrder#','DD');" style="margin:0 5px 0 15px;"><img src="/images/page_next.gif" border="0"></a>
					<a href="JavaScript:NextPrevSortPageDDmatch(#PageEnd#,'#sortField#','#pagingSortOrder#','DD');" style="margin:0 0 0 5px;"><img src="/images/page_end.gif" border="0"></a>
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
		<td id="dd" style="display: none;padding-top: 5px;padding-bottom: 5px; text-align: left" colspan="2">
			<CF_smallLink title = "Add to Match List" url = "javascript:add2MatchList('DD','#matchingType#','#workItemType#');"><br>
		</td>
	</tr>	
</table>
<cfset selectionType = "radio" />
<cfif vars.split_billback OR workItemType NEQ "BB">
	<cfset selectionType = "checkbox" />
</cfif>

	<table border="0" cellspacing="0" cellpadding="1" width="100%">
	<cfoutput>
		<tr>
			<td>
				<table border="0" cellspacing="0" cellpadding="0" width="100%">
					<tr>
						<td class="searchHeader" width="20px" style="border-bottom:0px;"><input type="checkbox" name="checkAll" id="checkAll" onclick="selectAll(this,'DD')" <cfif selectionType EQ "radio">disabled</cfif>></td>
						<td class="searchHeader" width="150px" style="border-bottom:0px;">
							<cfif sortField EQ "DD_DedID">
								<a href="javascript:NextPrevSortPageDDmatch(#pagingstartrow#,'DD_DedID','#sortOrder#','DD');">DD Number</a>
								<img src="#sortImage#">
							<cfelse>
								<a href="javascript:NextPrevSortPageDDmatch(#pagingstartrow#,'DD_DedID','ASC','DD');">DD Number</a>
							</cfif>
						</td>
						<td class="searchHeader" width="240px" style="border-bottom:0px;">
							<cfif sortField EQ "Distributor_Name">
								<a href="javascript:NextPrevSortPageDDmatch(#pagingstartrow#,'Distributor_Name','#sortOrder#','DD');">#application.returned_customer_setting.distributor_label_singular#</a>
								<img src="#sortImage#">
							<cfelse>
								<a href="javascript:NextPrevSortPageDDmatch(#pagingstartrow#,'Distributor_Name','ASC','DD');">#application.returned_customer_setting.distributor_label_singular#</a>
							</cfif>
						</td>
						
						<td class="searchHeader" width="100px" style="border-bottom:0px;">
							<cfif sortField EQ "DD_Date">
								<a href="javascript:NextPrevSortPageDDmatch(#pagingstartrow#,'DD_Date','#sortOrder#','DD');">DD Date</a>
								<img src="#sortImage#">
							<cfelse>
								<a href="javascript:NextPrevSortPageDDmatch(#pagingstartrow#,'DD_Date','ASC','DD');">DD Date</a>
							</cfif>
						</td>

						<td class="searchHeader" width="100px" style="border-bottom:0px;text-align:right;">
							<cfif sortField EQ "DD_Amount">
								<a href="javascript:NextPrevSortPageDDmatch(#pagingstartrow#,'DD_Amount','#sortOrder#','DD');">Amount</a>
								<img src="#sortImage#">
							<cfelse>
								<a href="javascript:NextPrevSortPageDDmatch(#pagingstartrow#,'DD_Amount','ASC','DD');">Amount</a>
							</cfif>
						</td>
					</tr>
	<!--- Second Row Starts --->				
					<tr>
						<td class="searchHeader" width="20px">&nbsp;</td>	

						<td class="searchHeader" width="150px">
							<cfif sortField EQ "DD_Check_Number">
								<a href="javascript:NextPrevSortPageDDmatch(#pagingstartrow#,'DD_Check_Number','#sortOrder#','DD');">Chk ##</a>
								<img src="#sortImage#">
							<cfelse>
								<a href="javascript:NextPrevSortPageDDmatch(#pagingstartrow#,'DD_Check_Number','ASC','DD');">Chk ##</a>
							</cfif>
						</td>
						
						<td class="searchHeader"  width="240px">
							<cfif sortField EQ "Broker_Name">
								<a href="javascript:NextPrevSortPageDDmatch(#pagingstartrow#,'Broker_Name','#sortOrder#','DD');">#application.returned_customer_setting.broker_label_singular#</a>
								<img src="#sortImage#">
							<cfelse>
								<a href="javascript:NextPrevSortPageDDmatch(#pagingstartrow#,'Broker_Name','ASC','DD');">#application.returned_customer_setting.broker_label_singular#</a>
							</cfif>
						</td>				

						<td class="searchHeader" width="100px">
							<cfif sortField EQ "DD_Reference">
								<a href="javascript:NextPrevSortPageDDmatch(#pagingstartrow#,'DD_Reference','#sortOrder#','DD');">#MCObject.stDeductionLabels["Reference"]#</a>
								<img src="#sortImage#">
							<cfelse>
								<a href="javascript:NextPrevSortPageDDmatch(#pagingstartrow#,'DD_Reference','ASC','DD');">#MCObject.stDeductionLabels["Reference"]#</a>
							</cfif>
						</td>
						
						<td class="searchHeader" width="100px" align="right">
							<cfif sortField EQ "Name_Last">
								<a href="javascript:NextPrevSortPageDDmatch(#pagingstartrow#,'Name_Last','#sortOrder#','DD');">Analyst</a>
								<img src="#sortImage#">
							<cfelse>
								<a href="javascript:NextPrevSortPageDDmatch(#pagingstartrow#,'Name_Last','ASC','DD');">Analyst</a>
							</cfif>
						</td>
					</tr>	
							<!--- Second Row Ends --->				
				</table>
			</td>
		</tr>
	</cfoutput>
	
	<cfoutput query="session.Get_Data" maxrows="#pagingmaxrows#" startrow="#pagingstartrow#">
		
		<cfif is_locked>
			<cfquery name="GetLockedByName" datasource="#application.datasource#">
				SELECT name_first + ' ' + name_last as LockedByName
				FROM _Users
				WHERE user_id = '#locked_by#'
			</cfquery>
		</cfif>		
		<cfscript>
			if(listFind(workList,Deduction_ID) GT 0){
				style = "rowSelected";
			} else {						
				if (listFind(workListAll,Deduction_ID) GT 0){
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
		
		<tr id="#DD_DedID#" 
			class="#style#"
			<cfif listFind(workList,Deduction_ID) EQ 0 AND listFind(workListAll,Deduction_ID) EQ 0>
				onmouseover="this.className='hover';" 
				onmouseout="this.className='#style#';"
			</cfif>
			>
			<td class="searchRow" id="sel_#currentrow#">
				<table border="0" cellspacing="0" cellpadding="0" width="100%">
					<tr>
						<td valign="top" id="#DD_DedID#col"
							width="20px"
							<cfif is_locked AND NOT (locked_by eq request.AccessStructure.User_ID AND DD_Locked_BY_Match_Central eq 1)>
								title="Deduction is Locked by (#GetLockedByName.LockedByName#)"
							<cfelse>
								<cfif listFind(workList,Deduction_ID) GT 0>
									title="Added &quot;#DD_DedID#&quot; to match list."
								<cfelseif listFind(workListAll,Deduction_ID) GT 0>
									title="&quot;#DD_DedID#&quot; is matched to another deduction."
								<cfelse>
									title="Add &quot;#DD_DedID#&quot; to match list."
								</cfif>
							</cfif>
							>
								<cfif is_locked>
									<input type="#selectionType#" name="IndividualCheckBox" value="#Deduction_ID#" id="#Deduction_ID#_CheckBox" onclick = "selectSingle(this, 'DD')" style="display:none;">	
									<img src='/Images/lock.gif' style="display:block;" id="#Deduction_ID#_Lock" title='Added &quot;#DD_DedID#&quot; to match list.'>
								<cfelse>
									<cfif (listFind(workListAll,Deduction_ID) EQ 0 OR listFind(workList,Deduction_ID) GT 0) AND NOT (is_locked AND NOT (locked_by eq request.AccessStructure.User_ID AND DD_Locked_BY_Match_Central eq 1))>								
										<input type="#selectionType#" name="IndividualCheckBox" value="#Deduction_ID#" id="#Deduction_ID#_CheckBox" onclick = "selectSingle(this, 'DD')">	
										<img src='/Images/lock.gif' style="display:none;" id="#Deduction_ID#_Lock" title='Added &quot;#DD_DedID#&quot; to match list.'>								
									<cfelse>
										<input type="#selectionType#" name="IndividualCheckBox" value=""  disabled>
								</cfif>
								</cfif>
								<input type="hidden" name="workItem" value="#workItem#" id="workItem">
								<input type="hidden" name="#Deduction_ID#_workItem" value="#workItem#" id="#Deduction_ID#_workItem">
								<input type="hidden" name="#Deduction_ID#_Approved_Amount" value="#DD_Amount#" id="#Deduction_ID#_Approved_Amount">
						</td>
						<td valign="top" width="150px">
							<CFIF SP_Number EQ ""><cfset spNum = 000><CFELSE><cfset spNum = SP_Number></CFIF>
							#trim(DD_DedID)# - #spNum#
						</td>
						<td valign="top" width="240px">#Distributor_Name#</td></td>
						<!--- <td valign="top" width="120px">#Broker_Name#&nbsp;</td> --->
						<td valign="top" width="100px">#trim(dateformat(DD_Date, 'mm/dd/yyyy'))#</td>
						<!--- <td valign="top">#trim(Name_First)# #trim(Name_Last)#</td> --->
						<td valign="top" width="100px" nowrap="true" align="right" >#trim(dollarFormat(DD_Amount))#</td>
					</tr>
					
					<tr>
						<td valign="top" width="15px">&nbsp;</td>
						<td valign="top" width="150px">#DD_Check_Number#</td>
						<td valign="top" width="240px">#Left(Broker_Name,40)#&nbsp;</td><!--- Truncate to 40 chars --->
						<td valign="top" width="100px">#DD_Reference#</td>
						<td valign="top" width="100px" align="right">#trim(Name_First)# #trim(Name_Last)#</td>						
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
						<a href="JavaScript:NextPrevSortPageDDmatch(#PageStart#,'#sortField#','#pagingSortOrder#','DD');" style="margin:0 5px 0 0;"><img src="/images/page_start.gif" border="0"></a>
						<a href="JavaScript:NextPrevSortPageDDmatch(#prevPageStart#,'#sortField#','#pagingSortOrder#','DD');" style="margin:0 15px 0 5px;"><img src="/images/page_prev.gif" border="0"></a>
					<cfelse>
						<span style="margin:0 5px 0 0;"><img src="/images/page_start_inactive.gif" border="0"></span>
						<span style="margin:0 15px 0 5px;"><img src="/images/page_prev_inactive.gif" border="0"></span>
					</cfif>

						<cfif lastPage GT 1>
							<cfif pagingstartrow EQ 1>
								[#PageStart#]
							<cfelse>
								<a href="JavaScript:NextPrevSortPageDDmatch(#PageStart#,'#sortField#','#pagingSortOrder#','DD');" style="margin:0 2px 0 2px;">#PageStart#</a>
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
									<a href="JavaScript:NextPrevSortPageDDmatch(#pageStartNum#,'#sortField#','#pagingSortOrder#','DD');" style="margin:0 2px 0 2px;">#page#</a>
								</cfif>
							</cfloop>
							
							<cfset lPageStart = int(pagingmaxrows * lastPage - pagingmaxrows) + 1>
							<cfif page NEQ lastPage>
								.. <a href="JavaScript:NextPrevSortPageDDmatch(#lPageStart#,'#sortField#','#pagingSortOrder#','DD');" style="margin:0 2px 0 2px;">#lastPage#</a>
							</cfif>
						</cfif>
					<cfif lastRecord EQ NextEndCondition>
						<a href="JavaScript:NextPrevSortPageDDmatch(#nextPageStart#,'#sortField#','#pagingSortOrder#','DD');" style="margin:0 5px 0 15px;"><img src="/images/page_next.gif" border="0"></a>
						<a href="JavaScript:NextPrevSortPageDDmatch(#PageEnd#,'#sortField#','#pagingSortOrder#','DD');" style="margin:0 0 0 5px;"><img src="/images/page_end.gif" border="0"></a>
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
<input type="hidden" name="SelectedDD" id="SelectedDD" value="">