<CFSET PAGE_TITLE=	"Proposal Search">
<CFSET GROUP=		"Programs">

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFIF Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 0>
	<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
</CFIF>

<CFPARAM name="form.businessSegmentsOn" default="0">
<CFPARAM name="form.SearchIsConductedFromOtherWindow" default="0">
<CFPARAM name="form.IFRAME_Extra_URL" default="">

<cfif form.SearchIsConductedFromOtherWindow EQ 1>
	<CFSET Form.IFRAME_Extra_URL = "?ShowCheckBoxes=1&SearchIsConductedFromOtherWindow=1">
</cfif>

<!---check to see if the business segment components exist before we run this--->
<!---check whether the directory exists or not--->
<cfset theDir = "#request.app_general_functions.get_Application_Path()#\components\programs\business_segment\" />
<cfif DirectoryExists(theDir)>
	<!---if the directory exists then check the file--->
	<cfset theFile = "#theDir#BusinessSegmentManager.cfc" />
	<!---it the file exists then we can create the component--->
	<cfif FileExists(theFile)>
		<!---create and instance of the BusinessSegmentManager--->
		<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<cfif businessSegManager.isEnabled()>
			<cfset form.businessSegmentsOn = 1 />
		</cfif>
	</cfif>
</cfif>


<!----defaults--->
<CFSET table_Width=910>

<CFSET Status_Width=60>
<CFSET Number_Width=90>
<CFSET Type_Width=140>
<CFSET Title_Width=375>
<CFSET SD_Width=45>
<CFSET ED_Width=45>
<CFSET Quantity_Width=80>
<CFSET BusSeg_Width=65>
<CFSET SCISSOR_Width=10>

<CFSET Title_Len=60>
<CFSET Type_Len=28>

<CFSET Default_Sort = "CT">
<CFSET Default_Sort_Order = "ASC">

<CFSET User_Position_Operator_List = "Created By, Requesting Approval,Approved By">
<!---end default--->

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
		font-size:12px;
		font-weight:bold;
		border-bottom:thin #FFFFFF 0px; 
	}
</style>
<!---
<TABLE WIDTH="915" ALIGN="CENTER">
<TR>
<TD ALIGN="LEFT">
 <B>
		<FONT SIZE="2" COLOR="Red">[</FONT>
			<FONT SIZE="2" COLOR="Blue">
				<CFOUTPUT>
					<A HREF="/help_files/manual/program/programsearch/index.cfm" onclick="NewWindow(this.href,'help','625','500','Yes', 'Yes');return false;" TITLE="Instructions...">
						read me first
					</A>
				</CFOUTPUT>
			</FONT>
		<FONT SIZE="2" COLOR="Red">]</FONT>
		</B> &nbsp; 
</TD>
<TD ALIGN="RIGHT">
<cfif form.SearchIsConductedFromOtherWindow EQ 0>
<B>
		<FONT SIZE="2" COLOR="Red">[</FONT>
			<FONT SIZE="2" COLOR="Blue">
				
					<A HREF="scorecard1.cfm">
						scorecard
					</A>
				
			</FONT>
		<FONT SIZE="2" COLOR="Red">]</FONT>
		<FONT SIZE="2" COLOR="Red">[</FONT>
			<FONT SIZE="2" COLOR="Blue">
				
					<A HREF="/common_files/select_new_program_type.cfm">
						create new
					</A>
				
			</FONT>
		<FONT SIZE="2" COLOR="Red">]</FONT>
</B>
</cfif>
</TD>
</TR>
</TABLE>
--->
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
		cursor:				pointer;		
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
<cfparam name="URL.SHEXP" 	default="">
<CFSET SCURL="bid_request_summary.cfm?SECTION_TO_OPEN=#URL.SECTION_TO_OPEN#&SHEXP=#URL.SHEXP#">
<CFSET Status_List="Pending,Won,Split,Lost">
<CFOUTPUT>
<CFSET i=1>

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
	
	
	var sc_URL = "#SCURL#";
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
	
	<CFINCLUDE TEMPLATE="/search_screens/bid_request/bid_Request_Search_Form.cfm">


	<TABLE STYLE="display:none;" ID="Table_Header" CELLPADDING="2" CELLSPACING="1" border="0" WIDTH="#table_Width#" BGCOLOR="#fore_Color#" CLASS="Maintable">
		<TR align="left">
			<!---Program Status--->
			<TD width="#Status_Width#" CLASS="tableheaders"><A HREF="##" OnClick="javaScript: setSortHref('ST');"><B>Status</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "ST"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#DESC_IMG#"></SPAN></TD>
			<!---Bid status--->
			<TD width="#Status_Width#" CLASS="tableheaders" nowrap><A HREF="##" OnClick="javaScript: setSortHref('BS');"><B>Bid Status</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "ST"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#DESC_IMG#"></SPAN></TD>
			<!---Program Number--->
			<TD width="#Type_Width#" CLASS="tableheaders"><A HREF="##" OnClick="javaScript: setSortHref('PT');"><B>Type</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "PT"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#DESC_IMG#"></SPAN></TD>

			<TD width="#Title_Width#" CLASS="tableheaders">
			<TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="0" CLASS="Maintable">
			<TR>
				<!---Program Title--->
				<TD STYLE="border-bottom:thin ##FFFFFF 0px;" CLASS="tableheaders"><A HREF="##" OnClick="javaScript: setSortHref('CT');"><B>Title</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "CT"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#ASC_IMG#"></SPAN></TD>				
				<TD<CFIF URL.SECTION_TO_OPEN LTE 1> STYLE="visibility:hidden"</CFIF> ID="TD_Approved" STYLE="border-bottom:thin ##FFFFFF 0px;" CLASS="tableheaders" ALIGN="CENTER"><A HREF="##" OnClick="javaScript: setSortHref('AD');"><B>Request/Approved Date</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "AD"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#ASC_IMG#"></SPAN></TD>				
			</TR>
			</TABLE>
			</TD>
			
			<!---Start and end dates for program--->
			<TD width="#Evaluate(SD_Width+ED_Width)#" CLASS="tableheaders">
			<TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="0">
			<TR>
			<TD width="#SD_Width#" CLASS="tableheaders"><A HREF="##" OnClick="javaScript: setSortHref('SD');"><B>Start</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "SD"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD width="#ED_Width#" CLASS="tableheaders"><A HREF="##" OnClick="javaScript: setSortHref('ED');"><B>End</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "ED"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			</TR>
			</TABLE>
			</TD>
			
			<!---Open and needed by dates--->
			<TD width="#Evaluate(SD_Width+ED_Width)#" CLASS="tableheaders">
			<TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="0">
			<TR>
			<TD width="#SD_Width#" CLASS="tableheaders"><A HREF="##" OnClick="javaScript: setSortHref('OP');"><B>Open</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "OP"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD width="#ED_Width#" CLASS="tableheaders"><A HREF="##" OnClick="javaScript: setSortHref('NB');"><B>Need</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "NB"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			</TR>
			</TABLE>
			</TD>
			
			<!------<TD width="#SD_Width#" CLASS="tableheaders"><A HREF="##" OnClick="javaScript: setSortHref('SD');"><B>Start</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "SD"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#ASC_IMG#"></SPAN></TD>
			<TD width="#ED_Width#" CLASS="tableheaders"><A HREF="##" OnClick="javaScript: setSortHref('ED');"><B>End</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "ED"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#ASC_IMG#"></SPAN></TD>----->
			<TD width="#Quantity_Width#" CLASS="tableheaders"><B>Quantity</B></TD>
			<cfif form.businessSegmentsOn eq 1>
				<TD width="#BusSeg_Width#" CLASS="tableheaders"><A HREF="##" OnClick="javaScript: setSortHref('BUS_SEG');"><B>Segment</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BUS_SEG"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			</cfif>
			<TD width="#SCISSOR_Width#" CLASS="tableheaders">&nbsp;</TD>
		</TR>
	</TABLE>
	
	<IFRAME ID="Search_Result" NAME="Search_Result" SRC="/search_screens/bid_request/bid_request_Search_Result.cfm#form.IFRAME_Extra_URL#" WIDTH="#Evaluate("#table_Width#+18")#" HEIGHT="439" FRAMEBORDER="0" style="border: 0px none ##000000;display:none;"></IFRAME>
	<cfif form.SearchIsConductedFromOtherWindow EQ 1>
	<B><FONT COLOR="##FF0000">[</FONT><a style="cursor: pointer;" onclick="importProducts();">import from selected programs</a><FONT COLOR="##FF0000">]</FONT></B>
	&nbsp;&nbsp;
	<B><FONT COLOR="##FF0000">[</FONT><a style="cursor: pointer;" onclick="importAll()">import all from selected programs</a><FONT COLOR="##FF0000">]</FONT></B>
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



