<!------ scorecard_main.cfm ----->
<cfheader name="Cache-Control" value="no-store">
<cfinclude template="tables_measures.cfm" />
<cfoutput>
<CFSET PAGE_TITLE="Futures Pricing">
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!------ set defaults ----->
<cfparam name="url.status" 	default="1" />
<cfset sortBy = defaultSortBy />
<cfset sortOrder = defaultSortOrder />
<CFSET ASC_IMG = "down_1.gif">
<CFSET DESC_IMG = "up_1.gif">
<CFIF sortOrder EQ "ASC">
	<CFSET currentSortImage = ASC_IMG>
<CFELSE>
	<CFSET currentSortImage = DESC_IMG>			
</CFIF>
<cfset frameName = "scorecardlist" />
<cfset formName = "frmScorecard" />

<HTML>
<HEAD>
	<TITLE>Scorecard Detail</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onload="">

<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="CENTER">
<TR>
<TD>
<TABLE WIDTH="920">
<TR>
	<TD ALIGN="LEFT">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFSET helpfilenumber= 0>
	<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	</TD>
	<TD ALIGN="RIGHT">
		<FONT SIZE="2">
		<CF_smallLink 
			title = "search futures pricing"
			url = "/Futures_Pricing/scorecard/search.cfm"
			>
		<CF_smallLink 
			title = "create new"
			url = "/Futures_Pricing/view.cfm"
			>
		</FONT>
	</TD>
</TR>
</TABLE>
<cfinclude template="scorecard_small.cfm" />
<!------ java scripts ----->
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<script language="JavaScript">
function setStatusHref(iStatus)
{
	var oTable_Status = document.all.table_status;
	var oCells = oTable_Status.rows[0].cells;
	var i;
	var thisCell = getParentObject(event.srcElement,"TD");
	if(thisCell)
	{
		for(i=0;i<oCells.length;i++)
		{
			if(oCells[i] == thisCell)
			{					
				oCells[i].className = "headerselected";
			}
			else
			{
				if(oCells[i].id)
				{
					oCells[i].className = "headernotselected";
				}
			}
		}
	}
	//initialise();
	//setSortImage(document.all.TD_CN);
	var formObj = getFormObj();
	formObj.status.value = iStatus;
	if(iStatus == 0)
	{
		formObj.isExpired.value = 1;
	}
	else
	{
		formObj.isExpired.value = 0;
	}
	initialise();//will reset the sort
	formObj.sortBy.value = sortBy;
	formObj.sortOrder.value = sortOrder;
	formObj.submit();
	setSortImage();
	event.cancelBubble = true;
	event.returnValue = false;
	return false;
}
var sortBy, sortOrder, ASC_IMG, DESC_IMG;
initialise();
function initialise()
{		
	sortBy = "#sortBy#";
	sortOrder = "#sortOrder#";
	ASC_IMG = "#ASC_IMG#";
	DESC_IMG = "#DESC_IMG#";
}
function setsorthref(sSortBy)
{
	event.returnValue = false;
	
	if(sortBy == sSortBy)
	{
		if(sortOrder == "ASC")
		{
			sortOrder = "DESC";
		}
		else
		{
			sortOrder = "ASC";
		}
	}
	else
	{
		sortOrder = "#defaultSortOrder#";
		sortBy = sSortBy;
	}
	
	var formObj = getFormObj();	
	formObj.sortBy.value = sortBy;
	formObj.sortOrder.value = sortOrder;
	formObj.submit();
	
	setSortImage();
	return false;
}

function setSortImage()
{
	var spObjs = document.all.SP_SP;
	var i;
	var tdObj, currentRowSorted;
	for(i=0;i<spObjs.length;i++)
	{
		currentRowSorted = 0;
		tdObj = getParentObject(spObjs[i],"TD");
		if(tdObj.id)
		{
			if(tdObj.id == "TD_" + sortBy)
			{
				currentRowSorted = 1;
			}
		}
		if(currentRowSorted == 1)
		{
			spObjs[i].all.S_IMG.src = "/Images/" + eval(sortOrder + "_IMG");
			spObjs[i].style.visibility = "visible";
		}
		else
		{
			spObjs[i].style.visibility = "hidden";
		}
	}	
}

function getFormObj()
{
	return document.#formName#;
}
</script>
<!------ out put tab style ----->
<cfset selectedBgColor = "##FFE083" />
<CF_tabStyle
		selectedBgColor="#selectedBgColor#"
		borderWidth="2"
		>


<!------ Get Status ----->
<cfset qGetStatus = CreateObject("component", "components.futures_pricing.StatusManager").getAll() />
<!------ show tabs ----->
<br>
<table border="0" width="#FP_TM_TABLE_WIDTH#" cellspacing="0" cellpadding="1" id="table_status">
	<tr>
	 <td class="headerspacer">&nbsp;</td>
	 <cfset QueryAddRow(qGetStatus) />
	 <cfset QuerySetCell(qGetStatus, "FP_Status_ID", 0) />
	  <cfset QuerySetCell(qGetStatus, "FP_Status_Desc", "Expired") />
	 <cfloop query="qGetStatus">
	 	<a id="#currentRow#" onclick="javascript: return setStatusHref(#FP_Status_ID#);" href="##">
		<td width="120" 
			<cfif url.status eq FP_Status_ID>
				class="headerselected" 		
			<cfelse>
				class="headernotselected" 
			</cfif>
			 align="center" nowrap id="statustab">
			<b>			
			<a id="#currentRow#" onclick="javascript: return setStatusHref(#FP_Status_ID#);" href="##">
			<nobr>#lcase(FP_Status_Desc)#</nobr>
			</a></b>
		</td>
		<cfif currentRow LT qGetStatus.recordCount>
			<td class="headerspacer"><img src="/images/fill.gif" width="1" height="1"></td>
		</cfif>
		</a>
	 </cfloop>
	<td class="headerspacer" width="100%"><img src="/images/fill.gif" width="1" height="1"></td>
	</tr>
</table>

<form name="#formName#" action="/Futures_Pricing/scorecard/search_result.cfm" method="post" target="#frameName#" style="display:inline;">
<input type="Hidden" name="status" value="#url.status#">
<input type="Hidden" name="isExpired" value="0">
<input type="Hidden" name="sortBy" value="#sortBy#">
<input type="Hidden" name="sortOrder" value="#sortOrder#">
</form>

<cfinclude template="scorecard_header.cfm" />
<CFSET SCURL="/Futures_Pricing/scorecard/search_result.cfm?status=#url.status#">

<iframe name="#frameName#" src="#scurl#" width="#evaluate("#FP_TM_TABLE_WIDTH#+18")#" height="385" frameborder="0" style="border: 0px none ##000000;"></iframe>

	
</BODY>
</HTML>
</cfoutput>