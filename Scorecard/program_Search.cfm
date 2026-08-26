<!--- <cfoutput>#url.position#</cfoutput> --->

<CFSET PAGE_TITLE=	"Program Search">
<CFSET GROUP=		"Programs">

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFIF Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 0>
	<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
</CFIF>

<CFPARAM name="form.businessSegmentsOn" default="0">
<CFPARAM name="form.SearchIsConductedFromOtherWindow" default="0">
<CFPARAM name="form.IFRAME_Extra_URL" default="">
<cfparam name="variables.showPendingAccept" default="0" />
<CFPARAM name="form.Report_Type" default="0">
<cfparam name="url.type" default="htm">


<cfif form.SearchIsConductedFromOtherWindow EQ 1>
	<CFSET Form.IFRAME_Extra_URL = "?ShowCheckBoxes=1&SearchIsConductedFromOtherWindow=1&a=#createuuid()#">
<cfelse>
	<CFSET Form.IFRAME_Extra_URL = "?a=#createuuid()#">
</cfif>
<cfparam name="url.searchType" 	default="0"><!------ 0=quick search, 1=advanced search ----->
<cfif url.searchType EQ 0>
	<cfset url.programSearchType = "quick">
<cfelseif url.searchType EQ 1>
	<cfset url.programSearchType = "advanced">
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

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Scorecard Detail</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onLoad="">
<!--- Dinesh Rachala LABEL 26667 added this if to customize header search bar in pop-up window	--->
<cfif url.type EQ 'htm'>
<cfset form.SearchIsConductedFromOtherWindow = 1>
</cfif>

<cfif form.SearchIsConductedFromOtherWindow EQ 0>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</cfif>


<!--- Dinesh Rachala LABEL 26667 added this if to customize header search bar in pop-up window --->
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
<TD ALIGN="LEFT">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
</TD>
<TD ALIGN="RIGHT">
<cfoutput>
	<script language="JavaScript">
	function ChangeSearchType(searchType)
	{
		var oForm = document.SearchForm;
		oForm.action = "program_search.cfm?type=#url.type#&searchType=" + searchType;
		oForm.target = "_self";
		oForm.submit();
		return false;
	}
	</script>

</cfoutput>


		<cfif ( url.type EQ 'htm') AND (url.searchType EQ 1)>
			<CF_smallLink
				title = "quick search"
				url = "hihi.cfm"
				parameters = "onClick=""javaScript:ChangeSearchType('0');return false;"""
			>

		<cfelseif  ( url.type EQ 'htm') AND (url.searchType EQ 0)>
			<CF_smallLink
				title = "advanced search"
				url = "hihi.cfm"
				parameters = "onClick=""javaScript:ChangeSearchType('1');return false;"""
			>
		</cfif>



<cfif form.SearchIsConductedFromOtherWindow EQ 0>

<cfsilent>
<!---Gets application settings--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset userManager = CreateObject("component", "components.user.UserManager") />
<cfset variables.getAllTemplateSettings = CreateObject("component", "components.programs.template.TemplateManager").init().getAll()/>
 <cfloop query="variables.getAllTemplateSettings">
  <cfif BidRequestStatusOn eq 1 and BidRequestStatusChangePgmStatus eq 1>
  	<cfset variables.showPendingAccept = 1 />
  </cfif>
 </cfloop>
</cfsilent>


<!--- 14479 (RBL) 01/24/08 [begin] --->
<cfparam name="url.programSearchType" type="string" default="quick">
<!--- 14479 (RBL) 01/24/08 [end] --->

<B>		<FONT SIZE="2">
		<cfif url.searchType EQ 1>
			<CF_smallLink
				title = "quick search"
				url = "hihi.cfm"
				parameters = "onClick=""javaScript:ChangeSearchType('0');return false;"""
			>

		<cfelse>
			<CF_smallLink
				title = "advanced search"
				url = "hihi.cfm"
				parameters = "onClick=""javaScript:ChangeSearchType('1');return false;"""
			>
		</cfif>



<!--- Dinesh Rachala LABEL 26667 added this if to customize header search bar in pop-up window --->
		<cfif url.type EQ 'htm'>

		<cfelse>



		<CF_smallLink
			title = "scorecard"
			url = "scorecard1.cfm"
		>
		<cfif Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 1 AND (appSettings.getUserNumberRestrict() EQ 0 OR userManager.getUserNumberExists(request.AccessStructure.User_ID) EQ 1)>
			<CF_smallLink
				title = "create new"
				url = "/common_files/select_new_program_type.cfm"
			>
		</cfif>
		<cfif Get_Profile_Settings.Mass_RFA_Program_Approve EQ 1>
		<span id="MassApproveID" style="display:none">
		<CF_smallLink
			title = "approve selected programs"
			url = "##"
			parameters = "onClick=""window.frames.Search_Result.approveSelectedProgram();"""
		>
		</span>
		</cfif>
		<cfif variables.showPendingAccept eq 1>
		<span id="EditStatusID" style="display:none">
		<CF_smallLink
			title = "edit status"
			url = "##"
			parameters = "onClick=""window.frames.Search_Result.editSelectedProgramStatus();"""
		>
		</span>
		</cfif>
		<cfif appSettings.getProgramClaimRatesReportAvailable()>
		<span id="ClaimReportID" style="display:none">
		<CF_smallLink
			title = "claim rates report"
			url = "##"
			parameters = "onClick=""window.frames.Search_Result.getReport('1');"""
		>
		</span>
		</cfif>
		<cfif appSettings.getShowPricingReport()>
		<span id="PricingReportID" style="display:none">
		<CF_smallLink
			title = "pricing report"
			url = "##"
			parameters = "onClick=""window.frames.Search_Result.getReport('2');"""
		>
		</span>
		</cfif>
		<CF_smallLink
			title = "print the results"
			url = "##"
			parameters = "onClick=""javaScript:printresults('Print');"""
		>

		</cfif>
		</FONT>
</B>
</cfif>
<!--- Dinesh Rachala LABEL 26667 added this if to customize header search bar in pop-up window --->
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

/* It seems this functions is not being used */
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
function printresults(varprint)
			{
				//window.parent.SearchForm.submit;

				if (varprint == "Print")
				{
var openerForm = SearchForm;
openerForm.action = "printresults.cfm?page=programsearch"; // servlet, jsp, html, etc...
openerForm.method = "post";
openerForm.target = "blank";
openerForm.submit();
openerForm.action = "program_Search_result.cfm";
openerForm.target = "Search_Result";
			}
			}

</SCRIPT>
<!------
<FONT COLOR="Red" SIZE="2"><CENTER><B><I>To find an item, hit Ctrl+F and a dialog box opens which allows you to enter your search string</I></B></CENTER></FONT>
----->
<!------
<TABLE ALIGN="RIGHT">
<TR>
<TD>
<FORM OnSubmit="javaScript: return findThisText(this.find_Text.value);">
<INPUT TYPE="TEXT" ID="find_Text" NAME="find_Text" VALUE=""><INPUT TYPE="SUBMIT" ID="b_find_Text" NAME="b_find_Text" VALUE="Find">
</FORM>
</TD>
<TR>
</TABLE>
----->
<cfparam name="URL.SECTION_TO_OPEN" 	default=1>
<cfparam name="URL.SHEXP" 	default="">
<CFSET SCURL="scorecard3.cfm?SECTION_TO_OPEN=#URL.SECTION_TO_OPEN#&SHEXP=#URL.SHEXP#">
<CFSET Status_List="Work In Progress,Request For App., ,Pre Active,Active,Expiring,Expired">
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
			sort_order = -1;
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
		/* Find the id of "SP_SP" on the cell passed to this function. */
		var thisSPObj = $(thisCell).find('[id="SP_SP"]').get(0);

		/* Find all the instances of id "SP_SP" on the document. */
		var spObjs = $(document).find('[id="SP_SP"]');

		var i;
		for(i=0;i<spObjs.length;i++)
		{
			if(spObjs[i] == thisSPObj)
			{
				$(spObjs[i]).find('[id="S_IMG"]').attr("src", "/Images/" + orderFileName);
				$(spObjs[i]).attr("style", "visibility: visible");
			}
			else
			{
				$(spObjs[i]).attr("style", "visibility: hidden");
			}
		}
	}




</SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>


	<TABLE CELLPADDING="2" CELLSPACING="0" border="0" ALIGN="CENTER">
	<TR><TD ALIGN="LEFT">
	<!--- dinesh for Label D26891  --->
	<cfif isdefined("url.Creating_User_Position")>
	<cfset position = #url.Creating_User_Position#>
	<cfset Include_work_in_progress_below_me = #url.Include_work_in_progress_below_me#>
	</cfif>
	<!--- dinesh for Label D26891 & D26891   --->
	<!--- Dinesh Rachala LABEL 26667 & D26891  START --->
<!--- This JavaScript function is used to collect the Contact_Number
     from the child window(include file) and pass those values to Javascript function
	 in Parent Window(Reassing Program) --->
<script>
function reassigns(s)
{
window.opener.ParentWindowFunction(s);
self.close();
}
</script>
<!--- Dinesh Rachala LABEL 26667 & D26891  END --->

	<CFINCLUDE TEMPLATE="program_Search_Form.cfm">


	<TABLE STYLE="display:none;" ID="Table_Header" CELLPADDING="2" CELLSPACING="1" border="0" WIDTH="#table_Width#" BGCOLOR="#fore_Color#" CLASS="Maintable" style="height:36px;">
		<TR align="left">

			<cfif form.SearchIsConductedFromOtherWindow EQ 1>
				<TD CLASS="tableheaders"><input type="Checkbox" name="chkAll" onClick="this.document.Search_Result.chkAllBxs(this.checked)"></TD>
			<cfelseif structKeyExists(url,"fromHomePage")>
				<TD CLASS="tableheaders">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>
			</cfif>

			<TD <!---width="#Status_Width#"---> CLASS="tableheaders" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('ST');"><B>STATUS</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "ST"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#DESC_IMG#"></SPAN></TD>
			<TD width="#Number_Width#" CLASS="tableheaders" ID="TD_CN" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('CN');"><B>PROGRAM</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "CN"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#DESC_IMG#"></SPAN></TD>
			<TD width="#Type_Width#" CLASS="tableheaders" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('PT');"><B>TYPE</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "PT"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#DESC_IMG#"></SPAN></TD>
			<TD width="#Title_Width#" CLASS="tableheaders" valign="top">
			<TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="0" CLASS="Maintable">
			<TR>
				<TD STYLE="border-bottom:thin ##FFFFFF 0px;" CLASS="tableheaders" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('CT');"><B>TITLE</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "CT"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#ASC_IMG#"></SPAN></TD>
				<TD<CFIF URL.SECTION_TO_OPEN LTE 1> STYLE="border-bottom:thin ##FFFFFF 0px;visibility:hidden" <CFELSE>STYLE="border-bottom:thin ##FFFFFF 0px;" </CFIF> ID="TD_Approved" CLASS="tableheaders" ALIGN="CENTER" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('AD');"><B>REQUEST/APPROVED DATE</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "AD"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#ASC_IMG#"></SPAN></TD>
			</TR>
			</TABLE>
			</TD>
			<!--- Dev Note: Milan; D6320. Show  neither "operator" nor "distributor" on the scorecard --->
			<CFIF appSettings.getProgramScoreCard() NEQ 0>
			<TD width="#Operator_Width#" CLASS="tableheaders" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('CO');"><B>#UCASE(application.returned_customer_setting.operator_label_singular)#</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "CO"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			</CFIF>
			<TD width="#Evaluate(SD_Width+ED_Width)#" CLASS="tableheaders" valign="top">
			<TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="0">
			<TR>
			<TD <!---width="#SD_Width#"---> CLASS="tableheaders" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('SD');"><B>START</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "SD"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD <!---width="#ED_Width#"---> CLASS="tableheaders" valign="top">&nbsp;</TD>
			</TR>
			</TABLE>
			</TD>
			<!------<TD width="#SD_Width#" CLASS="tableheaders"><A HREF="##" OnClick="javaScript: setSortHref('SD');"><B>Start</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "SD"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#ASC_IMG#"></SPAN></TD>
			<TD width="#ED_Width#" CLASS="tableheaders"><A HREF="##" OnClick="javaScript: setSortHref('ED');"><B>End</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "ED"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#ASC_IMG#"></SPAN></TD>----->
			<TD width="#Quantity_Width#" CLASS="tableheaders" valign="top"><B>QUANTITY</B></TD>
			<cfif form.businessSegmentsOn eq 1>
				<TD width="#BusSeg_Width#" CLASS="tableheaders" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('BUS_SEG');"><B>SEGMENT</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BUS_SEG"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			</cfif>
			<cfif appSettings.getpaymenthistoryon()><TD width="#SCISSOR_Width#" CLASS="tableheaders">&nbsp;</TD></cfif>
			<TD width="#SCISSOR_Width#" CLASS="tableheaders">&nbsp;</TD>
		</TR>
		<TR>
			<cfif application.returned_customer_setting.Accounting_Specialist eq 1>
				<TD width="#SCISSOR_Width#" CLASS="tableheaders">&nbsp;</TD>
				<TD width="#SCISSOR_Width#" CLASS="tableheaders">&nbsp;</TD>
				<TD width="#Type_Width#" CLASS="tableheaders" valign="top">
					<A HREF="##" OnClick="javaScript: setSortHref('PP');">
						<B>PAYMENT PROCESSOR</B>
					</A>
					<SPAN ID="SP_SP"<CFIF Default_Sort NEQ "PP"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN>
				</TD>
				<TD CLASS="tableheaders">&nbsp;

				</TD>
			<!--- Dev Note: Milan; D8539. Show only "operator" on the scorecard (The original label is 6320, but I had forgotten to add this here with that label) --->
			<cfif appSettings.getProgramScoreCard() EQ 1>
					<TD CLASS="tableheaders" valign="top">
						<A HREF="##" OnClick="javaScript: setSortHref('OP');">#UCASE(application.returned_customer_setting.operator_label_singular)# ##</A>
						<SPAN ID="SP_SP"<CFIF Default_Sort NEQ "OP"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN>
					</TD>
			</cfif>
		<!--- Dev Note: Milan; D8539. Show  "operator" and "distributor" on the scorecard (The original label is 6320,  but I had forgotten to add this here with that label) --->
			<cfif appSettings.getProgramScoreCard() EQ 2>
					<TD CLASS="tableheaders" valign="top">
						<A HREF="##" OnClick="javaScript: setSortHref('DI');">#UCASE(application.returned_customer_setting.distributor_label_singular)#</A>
						<SPAN ID="SP_SP"<CFIF Default_Sort NEQ "DI"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN>
					</TD>
			</cfif>
			</cfif>
			<!--- There is one less column to account for, if application.returned_customer_setting.Accounting_Specialist is zero (No Distributor or Operator column) --->
			<cfif application.returned_customer_setting.Accounting_Specialist eq 0>
				<cfif appSettings.getProgramScoreCard() eq 0>
				<!--- Note:(42385) It was colspan=4 earlier. I changed it to colspan="5" for Conagra. The header columns "END" and "AMOUNT" were one column misaligned to the left. --->
					<TD colspan="5" CLASS="tableheaders">
				<cfelseif appSettings.getProgramScoreCard() EQ 2>
					<TD colspan="4" CLASS="tableheaders">
					<TD CLASS="tableheaders" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('DI');"><B>#UCASE(application.returned_customer_setting.distributor_label_singular)#</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "DI"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
				<cfelse>
					<TD colspan="5" CLASS="tableheaders">
				</cfif>
			</cfif>
			<TD CLASS="tableheaders" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('ED');"><B>END</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "ED"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD width="#Quantity_Width#" CLASS="tableheaders" valign="top"><B>AMOUNT</B></TD>
		</tr>
	</TABLE>
<IFRAME ID="Search_Result" NAME="Search_Result" SRC="/scorecard/program_Search_Result.cfm#form.IFRAME_Extra_URL#" WIDTH="#Evaluate("#table_Width#+18")#" HEIGHT="639" FRAMEBORDER="0" style="border: 0px none ##000000;display:none;"></IFRAME>




<!--- 	<cfif form.SearchIsConductedFromOtherWindow EQ 1>
	<B><FONT COLOR="##FF0000">[</FONT><a style="cursor: pointer;" onClick="importProducts();">import from selected programs</a><FONT COLOR="##FF0000">]</FONT></B>
	&nbsp;&nbsp;
	<B><FONT COLOR="##FF0000">[</FONT><a style="cursor: pointer;" onClick="importAll()">import all from selected programs</a><FONT COLOR="##FF0000">]</FONT></B>
	</cfif> --->


<cfif isdefined('form.id_value')>
<cfoutput>#form.id_value#</cfoutput>
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