<!------ search_result.cfm ----->
<cfinclude template="tables_measures.cfm" />

<!------ set defaults ----->
<cfparam name="url.status" 	default="0">
<cfparam name="form.status" 	default="#url.status#">
<cfparam name="form.FP_Title" 	default="">
<cfparam name="form.Cust_Deadline" 	default="">
<cfparam name="form.isExpired" 	default="0">

<cfparam name="form.sortBy" 	default="#defaultSortBy#">
<cfparam name="form.sortOrder" 	default="#defaultSortOrder#">
<cfparam name="form.startrow" 	default="1">
<cfparam name="form.frompage" 	default="1">
<cfparam name="form.pageLength" 	default="11">
<cfset startrow = form.startrow>
<cfset frompage = form.frompage>
<cf_Number_of_Rows maxrows="#form.pageLength#">

<!------ do search ----->
<cfset fpRequestManager = CreateObject("component", "components.futures_pricing.RequestManager").init() />
<cfset stSearch = StructNew() />
<cfset stSearch.isExpired = form.isExpired />
<cfset stSearch.title = form.FP_Title />
<cfset stSearch.custDeadline = form.Cust_Deadline />
<cfif form.status>
	<cfset stSearch.status = form.status />
</cfif>
<cfset stSearch.restrictAccessUserId = request.AccessStructure.User_ID />
<cfset stSearch.getReminderCount = 1 />
<cfset stSearch.sortBy = form.sortBy />
<cfset stSearch.sortOrder = form.sortOrder />
<cfset qRequests = fpRequestManager.search(stSearch)>
<!------ do search ----->

<cfset qGetStatus = CreateObject("component", "components.futures_pricing.StatusManager").getAll() />
<cfoutput>
<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0" STYLE="margin:0; border: 0px; background-color:transparent" allowTransparency="true"><SCRIPT LANGUAGE="JavaScript">
	function showNext(thisObj)
	{
		var nextSib = thisObj.nextSibling;
		if(nextSib)
		{
			if(nextSib.style.display == "")
			{
				showHideRow(nextSib, "none");
			}
			else
			{
				showHideRow(nextSib, "");
			}
		}
	}
	
	function showHideRow(oObj, sShow)
	{
		oObj.style.display = sShow;
	}
	
	function applyToAllRows(sShow)
	{
		var tabObj = document.all.resultTable;		
		var i, rowLen, oRows;
		oRows = tabObj.rows;
		rowLen = oRows.length;
		for(i=2;i<rowLen;i+=2)
		{
			showHideRow(oRows[i], sShow);
		}
		return false;
	}
</SCRIPT>
<cfif qRequests.recordCount>
	<table cellpadding="2" cellspacing="0" class="MainTable" width="#FP_TM_TABLE_WIDTH#" id="resultTable">
	<cfloop query="qRequests" startrow="#StartRow#" endrow="#Evaluate(StartRow + MaxRows - 1)#">
		<tr valign="top" onClick="showNext(this);" onMouseOver="this.bgColor='##C6FFC6'" onMouseOut="this.bgColor='##FFFFFF'" style="cursor:hand;">
			<td width="#FP_VIEW_IMG#" valign="middle">
			<a target="_parent" href="/Futures_Pricing/view.cfm?id=#FP_Request_Master_ID#" onclick="javaScript: event.cancelBubble=true;"><IMG BORDER="0" SRC="/Images/Futures_Pricing/view_details_small.gif" WIDTH="20" HEIGHT="20" ALT="View Details" align="absmiddle"></a>
			</td>
			<td width="#FP_REMINDER#" valign="top"><cfif ReminderCount GT 0><img src="/Images/reminder_trans.gif" alt="There <cfif ReminderCount EQ 1>is<cfelse>are</cfif> #ReminderCount# reminder<cfif ReminderCount GT 1>s</cfif>"></cfif>&nbsp;
			</td>			
			<td width="#FP_STATUS#"><cfloop query="qGetStatus" endrow="#Evaluate(FP_Status_ID-1)#"><IMG BORDER="0" SRC="/Images/Futures_Pricing/done2.gif" WIDTH="15" HEIGHT="15" HSPACE="1" alt="#FP_Status_Desc#"></cfloop><cfloop query="qGetStatus" startrow="#FP_Status_ID#" endrow="4"><IMG BORDER="0" SRC="/Images/Futures_Pricing/done_not2.gif" WIDTH="15" HEIGHT="15" HSPACE="1" alt="#FP_Status_Desc#"></cfloop></td>
			<td width="#FP_TITLE#">#FP_Request_Title#</td>
			<td width="#FP_SRATE_END_DATE#">
			#DateFormat(FP_Request_Start_Date, "mm/dd/yyyy")#<br>
			#DateFormat(FP_Request_End_Date, "mm/dd/yyyy")#
			</td>
			<td width="#FP_CUST_DEADLINE#">#DateFormat(FP_Cust_Deadline_Date, "mm/dd/yyyy")#<br>&nbsp;</td>
			<td width="#FP_GOOD_UNTIL_DATE#">#DateFormat(Good_Until_Date, "mm/dd/yyyy")#<br>&nbsp;</td>
			<td width="#FP_CREATED_BY#">#Created_By_User_Name#</td>
		</tr>
		<tr bgcolor="##EEEEEE" style="display:none;" onMouseOver="this.previousSibling.bgColor='##C6FFC6'" onMouseOut="this.previousSibling.bgColor='##FFFFFF'">
			<td colspan="100%">						
				<table cellpadding="0" cellspacing="0" class="NotMainTable" width="100%">
					<tr valign="top">
					<td width="5%" rowspan="100%" valign="top">&nbsp;</td>
					<td style="border-bottom: 1px solid ##C0C0C0;" width="50%" id="header"><B>Product</B></td>
					<td style="border-bottom: 1px solid ##C0C0C0;" width="20%" id="header"><B>Volume</B></td>
					<td style="border-bottom: 1px solid ##C0C0C0;" width="15%" id="header"><B>Price/Pound</B></td>
					</tr>
					<cfset qGetProducts = CreateObject("component", "components.futures_pricing.RequestProductManager").getRequestProducts(FP_Request_Master_ID) />				
					<cfif qGetProducts.recordCount GT 0>
						<cfloop query="qGetProducts">
						<cfset uomDesc = request.app_general_functions.getUOMDesc(UOM, 0) />
						<tr>
						<td>#Description#</td>
						<td>#Volume# #uomDesc#</td>
						<td>#Final_Price# per #uomDesc#<cfif Len(Delivery_Type_Desc) Gt 0> - #Delivery_Type_Desc#</cfif></td>
						</tr>
						</cfloop>
					<cfelse>					
						<tr>
						<td colspan="100%" style="color:##ff0000;">None selected</td>
						</tr>
					</cfif>				
				</table>
			</td>
		</tr>
	</cfloop>
	</table>
	
	<!------ form for paging ----->
	<cfset formName = "frmFPSearchResult">
	<form method="post" name="#formName#">
	<cfloop collection="#form#" item="formItem">
		<cfif UCase(formItem) NEQ "FIELDNAMES">
			<input type="Hidden" name="#LCase(formItem)#" value="#Evaluate("form.#formItem#")#" />
		</cfif>
	</cfloop>
	</form>
	
	<TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="0">
	<TR>
	<TD>
	<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<CF_Next_Previous_For_Forms
		formname="#formName#"
		query="qRequests"
		maxpages="30"
		previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
		next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
		previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		addparams="">
	</DIV>
	</TD>
	<TD ALIGN="RIGHT">
		<FONT COLOR="Red" SIZE="2"><B>There <CFIF qRequests.recordcount EQ 1>is<CFELSE>are</CFIF> <CFOUTPUT>#qRequests.recordcount#</CFOUTPUT> <CFIF qRequests.recordcount EQ 1>futures pricing request<CFELSE>futures pricing requests</CFIF> that <CFIF qRequests.recordcount EQ 1>matches<CFELSE>match</CFIF> the above criteria</B></FONT>
	</TD>
	</TR>
	</TABLE>
<cfelse>
	<BR>
	<FONT COLOR="Red" SIZE="2"><B>There are no futures pricing requests that match the specified criteria</B></FONT>
</cfif>
</body>
</cfoutput>