<cfoutput>

<cfinclude template="scorecard/scorecard_main.cfm" />
<cfabort>

<SCRIPT LANGUAGE="JavaScript">
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
<cfset fpRequestManager = CreateObject("component", "components.futures_pricing.RequestManager").init() />
<cfset stSearch = StructNew() />
<cfset stSearch.isExpired = 0 />
<cfset qRequests = fpRequestManager.search(stSearch)>

<CF_smallLink 
	title = "new"
	url = "view.cfm"
	parameters=" target=""mywindowname"""
	>
<br><br>
<cf_smallLink
		title="expand all"
		url="##"
		parameters=" onClick=""javaScript: return applyToAllRows('');"""
		>
&nbsp;&nbsp;
<cf_smallLink
		title="collapse all"
		url="##"
		parameters=" onClick=""javaScript: return applyToAllRows('none');"""
		>
<br>
<!------ 
<table cellpadding="2" cellspacing="0" class="MainTable" width="90%" id="resultTable">
<caption align="right">Count = #qRequests.recordCount#</caption>
<colgroup>
	<col span="1" width="2%"></col>
	<col span="1" width="50%"></col>
	<col span="2" width="15%"></col>
	<col span="1" width="18%"></col>
</colgroup>
<thead>
	<tr valign="top" bgcolor="##FFCE84">		
		<td id="header">&nbsp;</td>
		<td id="header"><B>Description</B></td>
		<td id="header"><B>Start Date/<br>End Date</B></td>
		<td id="header"><B>Deadline</B></td>
		<td id="header"><B>Status</B></td>
		<td id="header">&nbsp;</td>
	</tr>
</thead>
<cfloop query="qRequests">
	<tr valign="top" onClick="showNext(this);" onMouseOver="this.bgColor='##C6FFC6'" onMouseOut="this.bgColor='##FFFFFF'" style="cursor:hand;">
		<td>&nbsp;</td>
		<td>#FP_Request_Title#</td>
		<td>
		#DateFormat(FP_Request_Start_Date, "mm/dd/yyyy")#<br>
		#DateFormat(FP_Request_End_Date, "mm/dd/yyyy")#
		</td>
		<td>#DateFormat(FP_Cust_Deadline_Date, "mm/dd/yyyy")#&nbsp;</td>
		<td>#RepeatString("<IMG BORDER=""0"" SRC=""/Images/Futures_Pricing/done2.gif"" WIDTH=""15"" HEIGHT=""15"" HSPACE=""1"">", (FP_Status_ID-1))##RepeatString("<IMG BORDER=""0"" SRC=""/Images/Futures_Pricing/done_not2.gif"" WIDTH=""15"" HEIGHT=""15"" HSPACE=""1"">", (4-FP_Status_ID+1))#</td>
		<td width="15%" valign="top">&nbsp;&nbsp;<a href="view.cfm?id=#FP_Request_Master_ID#" onclick="javaScript: event.cancelBubble=true;"><IMG BORDER="0" SRC="/Images/Futures_Pricing/view_details.gif" WIDTH="20" HEIGHT="20" ALT="View Details"></a></td>
	</tr>
	<tr bgcolor="##EEEEEE" style="display:none;" onMouseOver="this.previousSibling.bgColor='##C6FFC6'" onMouseOut="this.previousSibling.bgColor='##FFFFFF'">
		<td colspan="100%">						
			<table cellpadding="0" cellspacing="0" class="NotMainTable" width="100%">
				<tr valign="top">
				<td width="15%" rowspan="100%" valign="top">&nbsp;&nbsp;<a href="view.cfm?id=#FP_Request_Master_ID#"><IMG BORDER="0" SRC="/Images/Futures_Pricing/view_details.gif" WIDTH="40" HEIGHT="40" ALT="View Details"></a></td>
				<td style="border-bottom: 1px solid ##C0C0C0;" width="50%" id="header"><B>Product</B></td>
				<td style="border-bottom: 1px solid ##C0C0C0;" width="20%" id="header"><B>Volume</B></td>
				<td style="border-bottom: 1px solid ##C0C0C0;" width="15%" id="header"><B>Price/Pound</B></td>
				</tr>
				<cfset qGetProducts = CreateObject("component", "components.futures_pricing.RequestProductManager").getRequestProducts(FP_Request_Master_ID) />				
				<cfif qGetProducts.recordCount GT 0>
					<cfloop query="qGetProducts">
					<tr>
					<td>#Description#</td>
					<td>#Volume# #request.app_general_functions.getUOMDesc(UOM)#</td>
					<td></td>
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
 ----->
<cfinclude template="scorecard/scorecard_small.cfm" />


</cfoutput>