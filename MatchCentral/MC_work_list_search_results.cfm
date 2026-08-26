<cfsetting showdebugoutput="false">
<cfparam name="initialSearch" default="true">
<cfparam name="pagingmaxrows" default="50">
<cfparam name="pagingstartrow" default="1">

<cfscript>
	genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init();
	appSettings = genSettingsManager.get();
	MCObject = createObject("Component","components.Match_Central.MatchCentral").init();
</cfscript>

<!--- Queries and search data --->
<cfswitch expression="#typ#">
	<cfcase value="DD">
		<cfif isdefined('form.createList') AND len(form.createList)>
			<cfset form.ddnum = form.createList>
		</cfif>
		<cfparam name="sortField" default="DD_DedID">
		<cfparam name="sortOrder" default="ASC">
		<cfif initialSearch>
			<cfscript>
				SearchSource = "MatchCentralDD";
				FORM.DD_Number = ddnum;
				FORM.Analyst_User_ID = analystid;
				FORM.Distributor = Distributor;
				FORM.Distributor_Name = Distributor_Name;
					FORM.DD_Ref = DD_Ref;
				FORM.Broker_Name = Broker_Name;
				FORM.Check_No = Check_No;
				FORM.Filter_Closed = 1;
				FORM.IsParentDeduction = 1;
				FORM.Filter_Attached = 1;
				DDList = MCObject.workListIDList;
				businessSegmentID = "";
			</cfscript>
			<cfinclude template="/deductions/search_screens/ded_search_query.cfm">
			<cfset session.get_data = get_data>
		</cfif>
		<cfset filterField = "DD_Amount">
	</cfcase>
	<cfcase value="BB">
		<cfif isdefined('form.createList') AND len(form.createList)>
			<cfset form.bb_code = form.createList>
		</cfif>
		<cfparam name="sortField" default="BB_Code">
		<cfparam name="sortOrder" default="ASC">
		<cfif initialSearch>
			<cfscript>
				genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init();
				appSettings = genSettingsManager.get();
				source = "Deductions";
				default_sort = "BBA";
				default_sort_order = "DESC";
				ExcludeLockedBillbacks = 1;
				Status_List = "Approved,Payment Request";
				CallingBBSearchFromDD = 1;
				MATCHCentral = true;
				//HideAllSplitBB = true;
				filterAmount = false;

				FORM.BB_Closing_Method = "2";
				FORM.DOSEARCH = 1;
				FORM.source = source;
				FORM.soldToNo = soldToNo;
				FORM.Distributor_Name = Distributor_Name;
				FORM.Payable_Number = bb_code;
				FORM.Billback_Number = Billback_Number;
				FORM.ReferenceNum = ReferenceNum;
				FORM.Billback_Title = bb_title;

				URL.SECTION_TO_OPEN = 1;
			</cfscript>

			<cfinclude template="/billbacks/scorecard/billback_search_result.cfm">
			<cfinclude template="/billbacks/scorecard/billback_status_tool_tip.cfm" />

			<cfset session.get_data = variables.qBillbackSearchResults>
		</cfif>
		<cfscript>
			BBList = MCObject.workListIDList;
			BBListAll = MCObject.selectedBBlist & "," & BBList;
			filterField = "BB_Approved_Amount";
		</cfscript>
	</cfcase>
	<cfcase value="CR">
		<cfif isdefined('form.createList') AND len(form.createList)>
			<cfset form.ddnum = form.createList>
		</cfif>
		<cfparam name="sortField" default="DD_DedID">
		<cfparam name="sortOrder" default="ASC">
		<cfif initialSearch>
			<cfscript>
				SearchSource = "MatchCentralCR";
				FORM.DD_Number = ddnum;
				FORM.Analyst_User_ID = analystid;
				FORM.Distributor = Distributor;
				FORM.Distributor_Name = Distributor_Name;
				FORM.DD_Ref = DD_Ref;
				FORM.Broker_Name = Broker_Name;
				FORM.Check_No = Check_No;
				FORM.Filter_Closed = 1;
				FORM.IsParentDeduction = 1;
				FORM.Filter_Attached = 1;
				DDList = MCObject.workListIDList;
			</cfscript>
			<cfinclude template="/deductions/search_screens/ded_search_query.cfm">
			<cfset session.get_data = get_data>
		</cfif>
		<cfset filterField = "DD_Amount">
	</cfcase>
</cfswitch>

<cfif not isDefined("session.get_data")>
	<h2 style="text-align:center;">
		<h2 style="text-align:center;">Your search session has expired.</h2>
		<h3 style="text-align:center;">Please reload the item list by resubmitting your search.</h3>
		<h5 style="text-align:center;">
			Note: Your session expires when the alloted time set on the server has passed
			before you try and select an option. The default time is approximately 20
			minutes. These sessions expire for server performance purposes.
		</h5>
	</h2>
	<cfabort>
</cfif>

<cfquery name="session.get_data" dbtype="query">
	SELECT #ArrayToList(session.get_data.getColumnNames())#
	FROM session.get_data
	<cfif isDefined("amtFilter")>
		WHERE #filterField# <= #amtFilter#
	</cfif>
	ORDER BY #sortField# #sortOrder#
</cfquery>

<cfscript>
	pagingSortOrder = sortOrder;
	if(sortOrder EQ "ASC"){
		sortImage = "/images/up_1.gif";
		sortOrder = "DESC";
	}else{
		sortImage = "/images/down_1.gif";
		sortOrder = "ASC";
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

	DDList = MCObject.workListIDList;
</cfscript>

<cfoutput>
<table border="0">
<tr>
	<td style="text-align:left;width:400px;font-weight:normal;">
		<cfoutput>
		<span id="dd" style="display: none;">
			<a href="javascript:add2WorkList('DD','DD','BB');">#application.util.string.actionLinkFormat(' Match to Billbacks ')#</a>
			<CFIF appSettings.getDDAllowNegativeAmountCredits()>&nbsp;
				<a href="javascript:add2WorkList('DD','DD','CR')">#application.util.string.actionLinkFormat('Match to Credits')#</a>
			</CFIF>
		</span>
		<span id="bb" style="display: none;">
			<a href="javascript:add2WorkList('BB','BB','DD')">#application.util.string.actionLinkFormat(' Match to Deductions ')#</a>
			<CFIF appSettings.getDDAllowNegativeAmountCredits() AND appSettings.getAllowBillbackToCreditMatching()>&nbsp;
				<a href="javascript:add2WorkList('BB','BB','CR')">#application.util.string.actionLinkFormat('Match to Credits')#</a>
			</CFIF>
		</span>
		<span id="cr" style="display: none;">
			<a href="javascript:add2WorkList('CR','CR','DD')">#application.util.string.actionLinkFormat(' Match to Deductions ')#</a>
			<CFIF appSettings.getAllowBillbackToCreditMatching()>&nbsp;
				<a href="javascript:add2WorkList('CR','CR','BB')">#application.util.string.actionLinkFormat('Match to Billbacks')#</a>
			</CFIF>
		</span>
		</cfoutput>
	</td>
	<td style="width:200px;text-align:right;">
		#pagingstartrow# - #lastRecord# of [#session.get_data.recordCount#] Record<cfif session.get_data.recordCount GT 1>s</cfif>
	</td>
	<td style="width:150px;ext-align:right;">
		Show 	<select name="maxRows" id="maxRows" onchange="NextPrevSortPage(1,'#sortField#','#pagingSortOrder#','#typ#');" style="z-index:1000;">
					<option value="25" <cfif pagingmaxrows EQ 25>selected</cfif>>25</option>
					<option value="50" <cfif pagingmaxrows EQ 50>selected</cfif>>50</option>
					<option value="100" <cfif pagingmaxrows EQ 100>selected</cfif>>100</option>
					<option value="250" <cfif pagingmaxrows EQ 250>selected</cfif>>250</option>
					<option value="500" <cfif pagingmaxrows EQ 500>selected</cfif>>500</option>
					<option value="500000" <cfif pagingmaxrows EQ 500000>selected</cfif>>All</option>
				</select> Records
	</td>
</tr>
<tr>
	<td style="text-align:right;font-size:9px;font-weight:normal;text-align: right;" colspan="3">
		<cfif session.get_data.recordCount GT pagingmaxrows>

			<cfif lastRecord NEQ pagingmaxrows>
				<a href="JavaScript:NextPrevSortPage(#PageStart#,'#sortField#','#pagingSortOrder#','#typ#');" style="margin:0 5px 0 0;"><img src="/images/page_start.gif" border="0"></a>
				<a href="JavaScript:NextPrevSortPage(#prevPageStart#,'#sortField#','#pagingSortOrder#','#typ#');" style="margin:0 15px 0 5px;"><img src="/images/page_prev.gif" border="0"></a>
			<cfelse>
				<span style="margin:0 5px 0 0;"><img src="/images/page_start_inactive.gif" border="0"></span>
				<span style="margin:0 15px 0 5px;"><img src="/images/page_prev_inactive.gif" border="0"></span>
			</cfif>

			<cfif lastPage GT 1>
				<cfif pagingstartrow EQ 1>
					[#PageStart#]
				<cfelse>
					<a href="JavaScript:NextPrevSortPage(#PageStart#,'#sortField#','#pagingSortOrder#','#typ#');" style="margin:0 2px 0 2px;">#PageStart#</a>
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
									<a href="JavaScript:NextPrevSortPage(#pageStartNum#,'#sortField#','#pagingSortOrder#','#typ#');" style="margin:0 2px 0 2px;">#page#</a>
								</cfif>
							</cfloop>

							<cfset lPageStart = int(pagingmaxrows * lastPage - pagingmaxrows) + 1>
							<cfif page NEQ lastPage>
								.. <a href="JavaScript:NextPrevSortPage(#lPageStart#,'#sortField#','#pagingSortOrder#','#typ#');" style="margin:0 2px 0 2px;">#lastPage#</a>
							</cfif>
						</cfif>

				<cfif lastRecord EQ NextEndCondition>
				<a href="JavaScript:NextPrevSortPage(#nextPageStart#,'#sortField#','#pagingSortOrder#','#typ#');" style="margin:0 5px 0 15px;"><img src="/images/page_next.gif" border="0"></a>
				<a href="JavaScript:NextPrevSortPage(#PageEnd#,'#sortField#','#pagingSortOrder#','#typ#');" style="margin:0 0 0 5px;"><img src="/images/page_end.gif" border="0"></a>
			<cfelse>
				<span style="margin:0 5px 0 15px;"><img src="/images/page_next_inactive.gif" border="0"></span>
				<span style="margin:0 0 0 5px;"><img src="/images/page_end_inactive.gif" border="0"></span>
			</cfif>

		<cfelse>
			&nbsp;
		</cfif>
		</td>
	</tr>
</table>
</cfoutput>
<cfswitch expression="#typ#">
	<cfcase value="DD">
		<table border="0" cellspacing="0" cellpadding="1" width="100%">
			<cfoutput>
			<tr>
				<td class="searchHeader" width="15px" style="border-bottom:0px;"><input type="checkbox" name="checkAll" id="checkAll" onclick="selectAll(this,'#typ#')"></td>
				<td class="searchHeader" width="150px" style="border-bottom:0px;">
					<cfif sortField EQ "DD_DedID">
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'DD_DedID','#sortOrder#','DD');">DD Number</a>
						<img src="#sortImage#">
					<cfelse>
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'DD_DedID','ASC','DD');">DD Number</a>
					</cfif>
				</td>
				<td class="searchHeader" width="240px" style="border-bottom:0px;">
					<cfif sortField EQ "Distributor_Name">
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'Distributor_Name','#sortOrder#','DD');">#application.returned_customer_setting.distributor_label_singular#</a>
						<img src="#sortImage#">
					<cfelse>
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'Distributor_Name','ASC','DD');">#application.returned_customer_setting.distributor_label_singular#</a>
					</cfif>
				</td>

				<td class="searchHeader" width="100px" style="border-bottom:0px;">
					<cfif sortField EQ "DD_Date">
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'DD_Date','#sortOrder#','DD');">DD Date</a>
						<img src="#sortImage#">
					<cfelse>
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'DD_Date','ASC','DD');">DD Date</a>
					</cfif>
				</td>
				<td class="searchHeader" width="100px" style="text-align:right;border-bottom:0px;">
					<cfif sortField EQ "DD_Amount">
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'DD_Amount','#sortOrder#','DD');">Amount</a>
						<img src="#sortImage#">
					<cfelse>
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'DD_Amount','ASC','DD');">Amount</a>
					</cfif>
				</td>
			</tr>
			<!--- Second Row Header Start --->
			<tr>
				<td class="searchHeader" width="15px">&nbsp;</td>
				<td class="searchHeader" width="150px">
					<cfif sortField EQ "DD_Check_Number">
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'DD_Check_Number','#sortOrder#','DD');">Chk ##</a>
						<img src="#sortImage#">
					<cfelse>
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'DD_Check_Number','ASC','DD');">Chk ##</a>
					</cfif>
				</td>
				<td class="searchHeader" width="240px">
					<cfif sortField EQ "Broker_Name">
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'Broker_Name','#sortOrder#','DD');">#application.returned_customer_setting.broker_label_singular#</a>
						<img src="#sortImage#">
					<cfelse>
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'Broker_Name','ASC','DD');">#application.returned_customer_setting.broker_label_singular#</a>
					</cfif>
				</td>
				<td class="searchHeader" width="100px">
					<cfif sortField EQ "DD_Reference">
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'DD_Reference','#sortOrder#','DD');">#MCObject.stDeductionLabels["Reference"]#</a>
						<img src="#sortImage#">
					<cfelse>
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'DD_Reference','ASC','DD');">#MCObject.stDeductionLabels["Reference"]#</a>
					</cfif>
				</td>
				<td class="searchHeader" width="100px" align="right">
					<cfif sortField EQ "Name_Last">
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'Name_Last','#sortOrder#','DD');">Analyst</a>
						<img src="#sortImage#">
					<cfelse>
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'Name_Last','ASC','DD');">Analyst</a>
					</cfif>
				</td>

			</tr>
			<!--- Second Row Header End --->
			</cfoutput>
				<cfoutput query="session.Get_Data" maxrows="#pagingmaxrows#" startrow="#pagingstartrow#">

					<cfif is_locked>
						<cfset useLakebaseForGetLockedByName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGetLockedByName>
	<cftry>
		<cfset GetLockedByName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#locked_by#",
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
							WHERE user_id = '#locked_by#'
						</cfquery>
</cfif>
					</cfif>

					<cfscript>
						if(listFind(DDList,Deduction_ID) GT 0){
							style = "rowSelected";
						} else {
							if (currentRow MOD 2){
								style = "rowEven";
							} else {
								style = "rowOdd";
							}
						}
					</cfscript>
				<tr id="#Deduction_ID#" class="#style#" onmouseover="this.className='hover';" onmouseout="this.className='#style#';">
					<td colspan="100%" class="searchRow">
						<table cellpadding="0" cellspacing="0" border="0" width="100%">
							<tr>
								<cfif is_locked>
									<cfset statusUrl = "/Images/lock.gif">
									<cfset hoverTitle = "Deduction is Locked by (#GetLockedByName.LockedByName#)">
								<cfelseif listFind(DDList,Deduction_ID) GT 0>
									<cfset statusUrl = "/Images/lock.gif">
									<cfset hoverTitle = "Added &quot;#DD_DedID#&quot; to work list.">
								<cfelse>
									<cfset statusUrl = "/Images/workListAdd.gif">
									<cfset hoverTitle = "Add &quot;#DD_DedID#&quot; to work list.">
								</cfif>
								<td valign="top" id="lockedStatus#currentrow#" width="15px" title="#hoverTitle#">
									<cfif is_locked>
										<img src="/Images/lock.gif"/>
									<cfelse>
										<img src="/Images/lock.gif" id="#Deduction_ID#_Lock" style="display: none" />
										<input type="checkbox" name="IndividualCheckBox" value="#Deduction_ID#" id="#Deduction_ID#_CheckBox" onclick = "selectSingle(this, '#typ#')">
									</cfif>
								</td>
								<td valign="top" width="150px">#DD_DedID_SP_Number#</td>
								<td valign="top" width="240px">#Left(Distributor_Name,40)#</td></td><!--- Truncate to 40 chars --->
								<td valign="top" width="100px">#trim(dateformat(DD_Date, 'mm/dd/yyyy'))#</td>
								<td valign="top" width="100px" align="right" nowrap="true">#dollarFormat(DD_Amount)#</td>
							</tr>
							<!--- Second Row Start --->
							<tr>
								<td valign="top" width="15px">&nbsp;</td>
								<td valign="top" width="150px">#DD_Check_Number#</td>
								<td valign="top" width="240px">#Left(Broker_Name,40)#&nbsp;</td><!--- Truncate to 40 chars --->
								<td valign="top" width="100px">#DD_Reference#</td>
								<td valign="top" width="100px" align="right">#trim(Name_First)# #trim(Name_Last)#</td>
							</tr>
							<!--- Second Row End --->
						</table>
					</td>
				</tr>
				</cfoutput>
		</table>
	</cfcase>
	<cfcase value="BB">
		<table border="0" cellpadding="0" cellspacing="0" width="100%">
			<cfoutput>
			<tr>
				<td>
					<table border="0" cellspacing="0" cellpadding="0" width="100%">
						<tr>
							<td class="searchHeader" style="border-bottom:0px;" width="55px"><input type="checkbox" name="checkAll" id="checkAll" onclick="selectAll(this,'#typ#')"> Status</td>
							<td class="searchHeader" style="border-bottom:0px;" width="100px">
							<!--- Label 17705 | Changing the label BB Code to Payable No. but leaving the
							      others to remain the same  -Anand Rao 12/15/08 --->
								<cfif sortField EQ "BB_Code">
									<a href="JavaScript:NextPrevSortPage(#pagingstartrow#,'BB_Code','#sortOrder#','BB');">Payable ##</a>
									<img src="#sortImage#">
								<cfelse>
									<a href="JavaScript:NextPrevSortPage(#pagingstartrow#,'BB_Code','ASC','BB');">Payable ##</a>
								</cfif>
							</td>
							<td class="searchHeader" style="border-bottom:0px;" width="80px">
								<cfif sortField EQ "BB_Date">
									<a href="JavaScript:NextPrevSortPage(#pagingstartrow#,'BB_Date','#sortOrder#','BB');">BB Date</a>
									<img src="#sortImage#">
								<cfelse>
									<a href="JavaScript:NextPrevSortPage(#pagingstartrow#,'BB_Date','ASC','BB');">BB Date</a>
								</cfif>
							</td>
							<td class="searchHeader" style="border-bottom:0px;" width="110px">
								<cfif sortField EQ "BB_Reference">
									<a href="JavaScript:NextPrevSortPage(#pagingstartrow#,'BB_Reference','#sortOrder#','BB');">BB ##</a>
									<img src="#sortImage#">
								<cfelse>
									<a href="JavaScript:NextPrevSortPage(#pagingstartrow#,'BB_Reference','ASC','BB');">BB ##</a>
								</cfif>
							</td>
							<td class="searchHeader" style="border-bottom:0px;" width="80px">
								<cfif sortField EQ "BB_Start_Date">
									<a href="JavaScript:NextPrevSortPage(#pagingstartrow#,'BB_Start_Date','#sortOrder#','BB');">Start</a>
									<img src="#sortImage#">
								<cfelse>
									<a href="JavaScript:NextPrevSortPage(#pagingstartrow#,'BB_Start_Date','ASC','BB');">Start</a>
								</cfif>
							</td>
							<td class="searchHeader" style="border-bottom:0px;" width="80px">
								<cfif sortField EQ "BB_End_Date">
									<a href="JavaScript:NextPrevSortPage(#pagingstartrow#,'BB_End_Date','#sortOrder#','BB');">End</a>
									<img src="#sortImage#">
								<cfelse>
									<a href="JavaScript:NextPrevSortPage(#pagingstartrow#,'BB_End_Date','ASC','BB');">End</a>
								</cfif>
							</td>
							<td class="searchHeader" style="border-bottom:0px;text-align:right;">
								<cfif sortField EQ "BB_Approved_Amount">
									<a href="JavaScript:NextPrevSortPage(#pagingstartrow#,'BB_Approved_Amount','#sortOrder#','BB');">Amount</a>
									<img src="#sortImage#">
								<cfelse>
									<a href="JavaScript:NextPrevSortPage(#pagingstartrow#,'BB_Approved_Amount','ASC','BB');">Amount</a>
								</cfif>
							</td>
						</tr>
						<tr>
							<td class="searchHeader" width="55px">&nbsp;</td>
							<td class="searchHeader" colspan="4">
								<cfif sortField EQ "BB_Title">
									<a href="JavaScript:NextPrevSortPage(#pagingstartrow#,'BB_Title','#sortOrder#','BB');">BB Title</a>
									<img src="#sortImage#">
								<cfelse>
									<a href="JavaScript:NextPrevSortPage(#pagingstartrow#,'BB_Title','ASC','BB');">BB Title</a>
								</cfif>
							</td>
							<td class="searchHeader" colspan="2">
								<cfif sortField EQ "Name">
									<a href="JavaScript:NextPrevSortPage(#pagingstartrow#,'Name','#sortOrder#','BB');">Payee</a>
									<img src="#sortImage#">
								<cfelse>
									<a href="JavaScript:NextPrevSortPage(#pagingstartrow#,'Name','ASC','BB');">Payee</a>
								</cfif>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			</cfoutput>
			<cfoutput query="session.get_data" maxrows="#pagingmaxrows#" startrow="#pagingstartrow#">
				<cfscript>
					if (listFind(BBListAll,Billback_ID) GT 0){
						style = "rowSelected";
					} else {
						if (currentRow MOD 2){
							style = "rowEven";
						} else {
							style = "rowOdd";
						}
					}
				</cfscript>

				<tr id="#BB_Code#" class="#style#" <cfif listFind(BBListAll,Billback_ID) EQ 0>onmouseover="this.className='hover';" onmouseout="this.className='#style#';"</cfif>>
					<cfif bb_is_locked>
						<cfquery name="GetLockedByName" datasource="#application.datasource#">
							SELECT name_first + ' ' + name_last as LockedByName
							FROM _Users
							WHERE user_id = '#bb_locked_by_user_id#'
						</cfquery>
					</cfif>
					<td class="searchRow" id="sel_#currentrow#" colspan="100%">
						<table border="0" cellspacing="0" cellpadding="0" width="100%">
							<tr>
								<td valign="top" id="#BB_Code#col" width="20px"
									<cfif bb_is_locked>
										title="Billback is Locked by (#GetLockedByName.LockedByName#)"
									<cfelse>
										<cfif listFind(BBListAll,Billback_ID) GT 0>
											title="&quot;#BB_Code#&quot; is matched to a deduction."
										<cfelse>
											title="Add &quot;#BB_Code#&quot; to match list."
										</cfif>
									</cfif>
									>
									<cfif bb_is_locked>
										<img src="/Images/lock.gif"/>
									<cfelse>
										<img src="/Images/lock.gif" id="#Billback_ID#_Lock" style="display: none" />
										<input type="checkbox" name="IndividualCheckBox" value="#Billback_ID#" id="#Billback_ID#_CheckBox" onclick = "selectSingle(this, '#typ#')">
									</cfif>
								</td>
								<cfset statusUrl = MCObject.getBBStatusImageString(Billback_Status_ID)>
								<td valign="top" id="#bb_code#statusImage" width="33px" style="background-image: url('#statusUrl#');background-repeat:no-repeat;background-position:center center;">
								</td>
								<td valign="top" width="100px">
									<CF_smallLink
										title = "#trim(bb_code)#"
										url = "javascript:bbPreview('/billbacks/capture/bb_preview.cfm','#billback_id#');"
										parameters = "style='font-size:10px;' title='view the details for billback #bb_code#'">
								</td>
								<td valign="top" width="80px">#trim(dateformat(BB_Date, 'mm/dd/yyyy'))#</td>
								<td valign="top" width="110px">#trim(BB_Reference)#</td>
								<td valign="top" width="80px">#trim(dateformat(BB_Start_Date, 'm/d/yyyy'))#</td>
								<td valign="top" width="80px">#trim(dateformat(BB_End_Date, 'm/d/yyyy'))#</td>
								<td valign="top" align="right">#trim(dollarFormat(BB_Approved_Amount))#</td>
							</tr>
							<tr>
								<td valign="top" colspan="2" width="40px">&nbsp;</td>
								<td valign="top" colspan="4" width="370px">#trim(BB_Title)#</td>
								<td valign="top" colspan="2">#trim(Name)#</td>
							</tr>
						</table>
					</td>
				</tr>
			</cfoutput>
		</table>
	</cfcase>
	<cfcase value="CR">
		<table border="0" cellspacing="0" cellpadding="1" width="100%">
			<cfoutput>
			<tr>
				<td class="searchHeader" width="15px" style="border-bottom:0px;"><input type="checkbox" name="checkAll" id="checkAll" onclick="selectAll(this,'#typ#')"></td>
				<td class="searchHeader" width="150px" style="border-bottom:0px;">
					<cfif sortField EQ "DD_DedID">
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'DD_DedID','#sortOrder#','CR');">DD Number</a>
						<img src="#sortImage#">
					<cfelse>
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'DD_DedID','ASC','CR');">DD Number</a>
					</cfif>
				</td>
				<td class="searchHeader" width="240px" style="border-bottom:0px;">
					<cfif sortField EQ "Distributor_Name">
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'Distributor_Name','#sortOrder#','DD');">#application.returned_customer_setting.distributor_label_singular#</a>
						<img src="#sortImage#">
					<cfelse>
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'Distributor_Name','ASC','DD');">#application.returned_customer_setting.distributor_label_singular#</a>
					</cfif>
				</td>

				<td class="searchHeader" width="100px" style="border-bottom:0px;">
					<cfif sortField EQ "DD_Date">
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'DD_Date','#sortOrder#','CR');">DD Date</a>
						<img src="#sortImage#">
					<cfelse>
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'DD_Date','ASC','CR');">DD Date</a>
					</cfif>
				</td>

				<td class="searchHeader" width="100px" style="text-align:right;border-bottom:0px;">
					<cfif sortField EQ "DD_Amount">
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'DD_Amount','#sortOrder#','CR');">Amount</a>
						<img src="#sortImage#">
					<cfelse>
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'DD_Amount','ASC','CR');">Amount</a>
					</cfif>
				</td>
			</tr>
			<!--- Second Row Header Start --->
			<tr>
				<td class="searchHeader" width="15px">&nbsp;</td>

				<td class="searchHeader" width="150px">
					<cfif sortField EQ "DD_Check_Number">
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'DD_Check_Number','#sortOrder#','DD');">Chk ##</a>
						<img src="#sortImage#">
					<cfelse>
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'DD_Check_Number','ASC','DD');">Chk ##</a>
					</cfif>
				</td>
				<td class="searchHeader" width="240px">
					<cfif sortField EQ "Broker_Name">
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'Broker_Name','#sortOrder#','DD');">#application.returned_customer_setting.broker_label_singular#</a>
						<img src="#sortImage#">
					<cfelse>
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'Broker_Name','ASC','DD');">#application.returned_customer_setting.broker_label_singular#</a>
					</cfif>
				</td>
				<td class="searchHeader" width="100px">
					<cfif sortField EQ "DD_Reference">
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'DD_Reference','#sortOrder#','DD');">#MCObject.stDeductionLabels["Reference"]#</a>
						<img src="#sortImage#">
					<cfelse>
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'DD_Reference','ASC','DD');">#MCObject.stDeductionLabels["Reference"]#</a>
					</cfif>
				</td>
				<td class="searchHeader" width="100px" align="right">
					<cfif sortField EQ "Name_Last">
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'Name_Last','#sortOrder#','CR');">Analyst</a>
						<img src="#sortImage#">
					<cfelse>
						<a href="javascript:NextPrevSortPage(#pagingstartrow#,'Name_Last','ASC','CR');">Analyst</a>
					</cfif>
				</td>
			</tr>
			<!--- Second Row Header End --->
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
						if(listFind(DDList,Deduction_ID) GT 0){
							style = "rowSelected";
						} else {
							if (currentRow MOD 2){
								style = "rowEven";
							} else {
								style = "rowOdd";
							}
						}
					</cfscript>

					<tr id="#Deduction_ID#" class="#style#" onmouseover="this.className='hover';" onmouseout="this.className='#style#';">
						<!---- Added by Anand for similarity ---->
						<td colspan="100%" class="searchRow">
						<table cellpadding="0" cellspacing="0" border="0" width="100%">
							<tr>
						<cfif is_locked>
							<cfset statusUrl = "/Images/lock.gif">
							<cfset hoverTitle = "Deduction is Locked by (#GetLockedByName.LockedByName#)">
						<cfelseif listFind(DDList,Deduction_ID) GT 0>
							<cfset statusUrl = "/Images/lock.gif">
							<cfset hoverTitle = "Added &quot;#DD_DedID#&quot; to work list.">
						<cfelse>
							<cfset statusUrl = "/Images/workListAdd.gif">
							<cfset hoverTitle = "Add &quot;#DD_DedID#&quot; to work list.">
						</cfif>
						<td valign="top" id="lockedStatus#currentrow#" width="15px" 	title="#hoverTitle#">
							<cfif is_locked>
								<img src="/Images/lock.gif"/>
							<cfelse>
								<img src="/Images/lock.gif" id="#Deduction_ID#_Lock" style="display: none" />
								<input type="checkbox" name="IndividualCheckBox" value="#Deduction_ID#" id="#Deduction_ID#_CheckBox" onclick = "selectSingle(this, '#typ#')">
							</cfif>
						</td>
						<td  width="150px">#DD_DedID_SP_Number#</td>
						<td valign="top" width="240px">#Left(Distributor_Name,40)#</td><!--- Truncate to 40 chars --->
						<!--- td valign="top" width="120px">#Broker_Name#&nbsp;</td --->
						<td valign="top" width="100px">#trim(dateformat(DD_Date, 'mm/dd/yyyy'))#</td>
						<td valign="top" width="100px" align="right" nowrap="true">#dollarFormat(DD_Amount)#</td>
					</tr>
					<!--- Second Row Start --->
					<tr>
						<td valign="top" width="15px">&nbsp;</td>
						<td valign="top" width="150px">#DD_Check_Number#</td>
						<td valign="top" width="240px">#Left(Broker_Name,40)#&nbsp;</td><!--- Truncate to 40 chars --->
						<td valign="top" width="100px">#DD_Reference#</td>
						<td valign="top" width="100px" align="right">#trim(Name_First)# #trim(Name_Last)#</td>
					</tr>
					<!--- Second Row End --->
					</table>
				</td>
			</tr>
			</cfoutput>
		</table>
	</cfcase>
</cfswitch>

<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr>
		<td style="text-align:right;font-size:9px;font-weight:normal;">
			<cfif session.get_data.recordCount GT pagingmaxrows>
			<cfoutput>
				<cfif lastRecord NEQ pagingmaxrows>
					<a href="JavaScript:NextPrevSortPage(#PageStart#,'#sortField#','#pagingSortOrder#','#typ#');" style="margin:0 5px 0 0;"><img src="/images/page_start.gif" border="0"></a>
					<a href="JavaScript:NextPrevSortPage(#prevPageStart#,'#sortField#','#pagingSortOrder#','#typ#');" style="margin:0 15px 0 5px;"><img src="/images/page_prev.gif" border="0"></a>
				<cfelse>
					<span style="margin:0 5px 0 0;"><img src="/images/page_start_inactive.gif" border="0"></span>
					<span style="margin:0 15px 0 5px;"><img src="/images/page_prev_inactive.gif" border="0"></span>
				</cfif>
						<cfif lastPage GT 1>
							<cfif pagingstartrow EQ 1>
								[#PageStart#]
							<cfelse>
								<a href="JavaScript:NextPrevSortPage(#PageStart#,'#sortField#','#pagingSortOrder#','#typ#');" style="margin:0 2px 0 2px;">#PageStart#</a>
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
									<a href="JavaScript:NextPrevSortPage(#pageStartNum#,'#sortField#','#pagingSortOrder#','#typ#');" style="margin:0 2px 0 2px;">#page#</a>
								</cfif>
							</cfloop>

							<cfset lPageStart = int(pagingmaxrows * lastPage - pagingmaxrows) + 1>
							<cfif page NEQ lastPage>
								.. <a href="JavaScript:NextPrevSortPage(#lPageStart#,'#sortField#','#pagingSortOrder#','#typ#');" style="margin:0 2px 0 2px;">#lastPage#</a>
							</cfif>
						</cfif>
				<cfif lastRecord EQ NextEndCondition>
					<a href="JavaScript:NextPrevSortPage(#nextPageStart#,'#sortField#','#pagingSortOrder#','#typ#');" style="margin:0 5px 0 15px;"><img src="/images/page_next.gif" border="0"></a>
					<a href="JavaScript:NextPrevSortPage(#PageEnd#,'#sortField#','#pagingSortOrder#','#typ#');" style="margin:0 0 0 5px;"><img src="/images/page_end.gif" border="0"></a>
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