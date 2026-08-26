<!------ scorecard_main.cfm ----->
<cfheader name="Cache-Control" value="no-store">
<cfinclude template="tables_measures.cfm" />
<cfoutput>

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
			title = "futures pricing scorecard"
			url = "/Futures_Pricing/scorecard/scorecard_main.cfm"
			>
		<CF_smallLink 
			title = "create new"
			url = "/Futures_Pricing/view.cfm"
			>
		</FONT>
	</TD>
</TR>
</TABLE>

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

function doSearchNow()
{
	var formObj = getFormObj();	
	formObj.submit();
	return false;
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


<form name="#formName#" action="/Futures_Pricing/scorecard/search_result.cfm" method="post" target="#frameName#" style="display:inline;">
<table cellpadding="2" cellspacing="0" border="0" width="#FP_TM_TABLE_WIDTH#" BGCOLOR="WhiteSmoke">
<tr>
	<td>
		<B>Title</B><br>
		<input type="Text" name="FP_Title" value="" style="width:200px;" />
	</td>
	<td>
		<B>Status</B><br>
		<cfset qGetStatus = CreateObject("component", "components.futures_pricing.StatusManager").getAll() />
		<select name="status" style="width:200px;">
			<option value="0">All Status</option>
		<cfloop query="qGetStatus">		
			<option value="#FP_Status_ID#">#FP_Status_Desc#</option>
		</cfloop>
		</select>
	</td>
	<td>
		&nbsp;<br>
		<input type="Checkbox" name="isExpired" value="1"><B>Show Expired</B>
	</td>	
	<td>
		<B>Cust Deadline</B><br>
		<CF_EASYDATE 
				FORMNAME="#formName#" 
				FIELDNAME="Cust_Deadline" 
				FORMAT="mm/dd/yyyy" 
				DEFAULT="">
	</td>
	<td>
		<cf_smallLink
			title="reset"
			url="##"
			parameters=" onClick=""JavaScript: getFormObj().reset(); return false;"""
			>
		&nbsp;&nbsp;&nbsp;
		<cf_smallLink
			title="search"
			url="##"
			parameters=" onClick=""JavaScript: return doSearchNow();"""
			>
	</td>
</tr>
</table>
<input type="Hidden" name="sortBy" value="#sortBy#">
<input type="Hidden" name="sortOrder" value="#sortOrder#">
</form>

<cfinclude template="scorecard_header.cfm" />
<CFSET SCURL="/Futures_Pricing/scorecard/search_result.cfm">

<iframe name="#frameName#" src="#scurl#" width="#evaluate("#FP_TM_TABLE_WIDTH#+18")#" height="385" frameborder="0" style="border: 0px none ##000000;"></iframe>

	
</BODY>
</HTML>
</cfoutput>