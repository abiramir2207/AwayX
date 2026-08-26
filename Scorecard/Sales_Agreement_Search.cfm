<CFSET PAGE_TITLE=	"Agreement Search">
<CFSET GROUP=		"Agreements">

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFIF Get_Profile_Settings.Create_Export_Agreements EQ 0 AND Get_Profile_Settings.Create_Approve_Export_Agreements EQ 0>
	<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
</CFIF>

<CFPARAM name="form.SearchIsConductedFromOtherWindow" default="0">
<CFPARAM name="form.IFRAME_Extra_URL" default="">

<cfif form.SearchIsConductedFromOtherWindow EQ 1>
	<CFSET Form.IFRAME_Extra_URL = "?ShowCheckBoxes=1&SearchIsConductedFromOtherWindow=1&a=#createuuid()#">
<cfelse>
	<CFSET Form.IFRAME_Extra_URL = "?a=#createuuid()#">
</cfif>
<cfparam name="url.searchType" 	default="0"><!------ 0=quick search, 1=advanced search ----->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Scorecard Detail</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onload="">

<cfif form.SearchIsConductedFromOtherWindow EQ 0>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</cfif>

<style>
Table.maintable td.tableheaders
	{
		font-size:8pt;
		font-weight:bold;
		border-bottom:thin #FFFFFF 0px; 
	}
</style>

<TABLE WIDTH="915" ALIGN="CENTER">
<TR>
<TD ALIGN="RIGHT">
<script language="JavaScript">
function ChangeSearchType(searchType)
{
	var oForm = document.SearchForm;
	oForm.action = "Sales_Agreement_search.cfm?searchType=" + searchType;
	oForm.target = "_self";
	oForm.submit();
	return false;
}
</script>
<cfif form.SearchIsConductedFromOtherWindow EQ 0>
<cfsilent>
<!---Gets application settings--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset userManager = CreateObject("component", "components.user.UserManager") />
</cfsilent>
</cfif>
</TD>
</TR>
</TABLE>
<CFSET fore_Color="FFE083">

<CFOUTPUT>
<STYLE TYPE="text/css">
TD.foreground
	{
		border-left :		1px solid Gray;
		border-right :		1px solid Gray;
		border-top :		1px solid Gray;
		color: 				Black;
		BACKGROUND-COLOR: 	FFCE84;
	}
TD.background
	{
		border-left:		1px solid Gray;
		border-right:		1px solid Gray;
		border-top :		1px solid Gray;
		border-bottom:		1px solid Gray;
		color: 				White;
		cursor:				hand;		
		BACKGROUND-COLOR: 	WhiteSmoke;
	}
TD.Filler
	{
		border-left:		1px solid White;
		border-bottom:		1px solid Gray;
		color: 				White;
	}
A.tablink_back, A:Hover.tablink_back
	{
		color: 				Black;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:visited.tablink_back
	{
		color: 				Black;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:visited.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
	
	
	
	TD.headernotselected
  {
   background-color : dddddd;
   border-bottom: solid 3px black;
  }
  TD.headerselected
  {
   border-left: solid 3px black;
   border-top: solid 3px black;
   border-right: solid 3px black;
   background-color : #fore_Color#;
  }
  TD.headerblank
  {
   border-bottom: solid 3px black;
  }
  TD.headerspacer
  {
   border-bottom: solid 3px black;
  }
  TD.headerlastone
  {
   border-left: solid 3px black;
  }

</STYLE>
</CFOUTPUT>
<SCRIPT LANGUAGE="JavaScript">
var oRange;
var sBookMark;
var first = true;
var n=0;
var oldValue = "";
function findThisText(find_Value)
{	
	if(window.ScoreCardList)
	{						
		findInPage(window.ScoreCardList,find_Value);
    } 
	return false;
}

function findInPage(wObj,str) 
{
	var txt, i, found;
	if (str == "") return false; 
	if(oldValue != str) 
	{	
		n = 0 ;
	}
	oldValue = str;
	txt = wObj.document.body.createTextRange();

	// Find the nth match from the top of the page.
	for (i = 0; i <= n && (found = txt.findText(str)) != false; i++) 
	{
		txt.moveStart("character", 1);
		txt.moveEnd("textedit");
	}
	
	// If found, mark it and scroll it into view.
	if (found) 
	{
		txt.moveStart("character", -1);
		txt.findText(str);
		txt.select();
		txt.scrollIntoView();
		n++;
	} 
	else 
	{
		// Start over at the top of the page and find first match.
		if (n > 0) 
		{
			n = 0;
			findInPage(wObj,str);
		} 
		else 
		{
			// Not found anywhere, give message.
			alert("Not found.");
		}
	}
return false;
}

function checkFrame(){
	oIframe = document.all.Search_Result;
	if(oIframe.style.display.length != 0) {
		alert("Please conduct a search first.")
		return false;
	}
	
	return true;
}

function importProducts() {
	if(checkFrame()) {
		document.all.PL_ImportProducts.value=1;
		document.Search_Result.navigate(0,0);	
	}
}

function importAll() {
	if(checkFrame()) {
		document.all.chkAll.checked = false;
		document.all.chkAll.fireEvent("onclick");

		document.all.PL_PreSubmit.value = "";
		document.all.PL_PostSubmit.value = "";
		document.all.PL_AllProductList.value = document.Search_Result.document.all.ImportAllList.value;
		document.all.PL_ImportProducts.value=0;
		document.all.PL_ImportAllProducts.value=1;
		document.Search_Result.navigate(0,0);
	}
}


<cfif form.SearchIsConductedFromOtherWindow EQ 1>
	window.returnValue = "";
</cfif>
</SCRIPT>

<cfparam name="URL.SECTION_TO_OPEN" 	default=1>
<!---<cfparam name="URL.SHEXP" 	default="">
<CFSET SCURL="scorecard3.cfm?SECTION_TO_OPEN=#URL.SECTION_TO_OPEN#&SHEXP=#URL.SHEXP#">
<CFSET Status_List="Work In Progress,Request For App., ,Pre Active,Active,Expiring,Expired">
--->
<CFOUTPUT>
<CFSET i=1>

<CFINCLUDE TEMPLATE="Tables_Measures.cfm">

<CFSET ASC_IMG="down_1.gif">
<CFSET DESC_IMG="up_1.gif">

<SCRIPT LANGUAGE="javaScript">
	function getParentObject(thisObj, tagName)
	{
		if(thisObj.tagName.toLowerCase() == tagName.toLowerCase())
		{
			return thisObj;
		}
		else if(thisObj.tagName.toLowerCase() == "body")
		{
			return null;
		}
		else
		{
			return getParentObject(thisObj.parentElement, tagName);
		}
	}
	
	
	<!---var sc_URL = "#SCURL#";--->
	var sortBy;
	var sort_order;
	var orderFileName;
	
	initialise();
	
	function initialise()
	{		
		sortBy = "#Default_Sort#";
		<CFIF Default_Sort_Order EQ "ASC">
			sort_order = 1;
			<CFSET Current_Image = ASC_IMG>
		<CFELSE>
			sort_order = 0;
			<CFSET Current_Image = DESC_IMG>			
		</CFIF>				
		orderFileName = "#Current_Image#";
	}
	function setSortHref(sortVal)
	{
		if(sortBy == sortVal)
		{
			sort_order *= -1;
		}
		else
		{
			sort_order = 1;
			sortBy = sortVal;
		}
		var SORTORDER;
		
		if(sort_order < 0)
		{
			SORTORDER = "DESC";
			orderFileName = "#DESC_IMG#";
		}
		else
		{
			SORTORDER = "ASC";
			orderFileName = "#ASC_IMG#";
		}
		
		document.SearchForm.sort_by.value = sortVal;
		document.SearchForm.sort_Order.value = SORTORDER;
		
		var thisCell = getParentObject(event.srcElement,"TD");		
		setSortImage(thisCell);

		document.SearchForm.submit();
	}
	
	function setSortImage(thisCell)
	{
		
		var thisSPObj = thisCell.all.SP_SP;
		var spObjs = document.all.SP_SP;
		var i;
		for(i=0;i<spObjs.length;i++)
		{
			if(spObjs[i] == thisSPObj)
			{
				spObjs[i].all.S_IMG.src = "/Images/" + orderFileName;
				spObjs[i].style.visibility = "visible";
			}
			else
			{
				spObjs[i].style.visibility = "hidden";
			}
		}	
	}
	

</SCRIPT>



	<TABLE CELLPADDING="2" CELLSPACING="0" border="0" ALIGN="CENTER">
	<TR><TD ALIGN="LEFT">
	
	<CFINCLUDE TEMPLATE="Sales_Agreement_Search_Form.cfm">

	<TABLE STYLE="display:none;" ID="Table_Header" CELLPADDING="2" CELLSPACING="1" border="0" WIDTH="910" BGCOLOR="#fore_Color#" CLASS="Maintable">
		<TR align="left">
			<TD CLASS="tableheaders" width="10%" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('ST');"><B>STATUS</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "ST"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#DESC_IMG#"></SPAN></TD>
			<TD width="22%"  CLASS="tableheaders" ID="TD_CN" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('CN');"><B>AGREEMENT</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "CN"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#DESC_IMG#"></SPAN></TD>
			<TD width="22%"  CLASS="tableheaders" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('CT');"><B>TITLE</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "CT"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#ASC_IMG#"></SPAN></TD>
			<TD width="22%"  CLASS="tableheaders" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('DI');">#UCASE(application.returned_customer_setting.distributor_label_singular)#</A>		<SPAN ID="SP_SP"<CFIF Default_Sort NEQ "DI"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD width="24%"  CLASS="tableheaders" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('SD');"><B>START</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "SD"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN>
			<br /><A HREF="##" OnClick="javaScript: setSortHref('ED');"><B>END</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "ED"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
		</TR>
	</TABLE>
	
	<IFRAME ID="Search_Result" NAME="Search_Result" SRC="/scorecard/program_Search_Result.cfm#form.IFRAME_Extra_URL#" WIDTH="#Evaluate("#table_Width#+18")#" HEIGHT="439" FRAMEBORDER="0" style="border: 0px none ##000000;display:none;"></IFRAME>
	<cfif form.SearchIsConductedFromOtherWindow EQ 1>
	<B><FONT COLOR="##FF0000">[</FONT><a style="cursor: hand;" onclick="importProducts();">import from selected programs</a><FONT COLOR="##FF0000">]</FONT></B>
	&nbsp;&nbsp;
	<B><FONT COLOR="##FF0000">[</FONT><a style="cursor: hand;" onclick="importAll()">import all from selected programs</a><FONT COLOR="##FF0000">]</FONT></B>
	</cfif>
	</TD>
	</TR>
	</TABLE>
</CFOUTPUT>	 
<CFSET increaseLength = 129>
<CFSET increasePageLength = 4>
<cfset show_hide_type = 2>
<CFINCLUDE TEMPLATE="/scorecard/Show_Hide_Search_Form.cfm">

<cfif form.SearchIsConductedFromOtherWindow EQ 0>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</cfif>
</BODY>
</HTML>