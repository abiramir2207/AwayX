<!DOCTYPE HTML>
<cfsilent>
<!---
FILE:
FILENAME: 	billbacks/scorecard/billback_search.cfm
CREATED: 	??/??/???? - ???
EDITED:		11/24/2008 - RBL

FUNCTIONALITY:
- This template is a piece of the display billback search results puzzle...
--->
<!--- 14479 (RBL) 01/24/08 [begin] --->
<cfparam name="url.searchType" type="string" default="quick">
<!--- 14479 (RBL) 01/24/08 [end] --->


<cfparam name="url.Type_search" default="">

<cfset PAGE_TITLE=	"Billback Search">
<CFSET GROUP=		"Billbacks">
<CFPARAM NAME="Source" default="Search">
<cfparam name="CanDelete" default="0">
<CFPARAM name="form.SearchIsConductedFromOtherWindow" default="0">
<CFPARAM name="form.IFRAME_Extra_URL" default="">

<cfif form.SearchIsConductedFromOtherWindow EQ 1>
	<CFSET Form.IFRAME_Extra_URL = "?SearchIsConductedFromOtherWindow=1&a=#createuuid()#">
<cfelse>
	<CFSET Form.IFRAME_Extra_URL = "?a=#createuuid()#">
</cfif>

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<cfif application.appSettingsGet.getBillback_Module()  NEQ application.returned_customer_setting.customer_setting_error_string>
	<cfif application.appSettingsGet.getBillback_Module() NEQ 1>
		<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
	</cfif>
<cfelse>
	<!--- <B><FONT COLOR="Red"><CFOUTPUT>#application.appSettingsGet.getBillback_Module()#</CFOUTPUT></FONT></B> --->
</cfif>
</cfsilent>
<HTML>
<HEAD>
	<TITLE>Billback <cfoutput>#url.searchType# </cfoutput>Search</TITLE>
	<cfinclude template="/common_files/jQuery.cfm">
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<script>
	var globalCurrentProgramList = "";
	var massPayBillbackList = [];
	function payBillbacks()
	{
		if(massPayBillbackList.length > 0)
		{

			if(confirm("Press OK to mark selected billbacks as paid."))
			{
				document.all.approvalForm.massPayBillbackList.value = massPayBillbackList.join();
				document.all.approvalForm.submit();
			}
		}
	else
		{
		alert("Please select at least one billback to pay.")
		}
	}
	</script>
	<style>
		#act938 a { margin-left: 13px; }
		#dnload012 { display: none; }
		#uploadDocs{display: none;}
		span.summary {
			display: inline-block;
			margin-right: 25px;
		}
	</style>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif url.Type_search EQ "impBillBacks">
<SCRIPT language=JavaScript1.2 src="/common_files/scripts/demenu.js"></SCRIPT>
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
	<cfelse>
<CFINCLUDE TEMPLATE="/includes/header.cfm">
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!------
<BLOCKQUOTE>
----->

<Cfif Get_Profile_Settings.BB_Delete IS 1>
	<cfset CanDelete = 1>
</CFIF>

<style>
Table.maintable td.tableheaders
	{
		font-size:12px;
		font-weight:bold;
		border-bottom:thin #FFFFFF 0px;
	}
</style>
<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="CENTER">
<TR>
<TD>
	<TABLE WIDTH="100%" border="0">
	<TR>
		<TD ALIGN="LEFT">
			<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
		</TD>
<TD ALIGN="RIGHT" id="act938">
		<!--- 14479 (RBL) 01/24/08 [begin] --->
		<cfoutput>
			<cfif url.searchType EQ "advanced">
				<a href="#cgi.script_name#?searchType=quick">#application.util.string.actionLinkFormat2('quick search')#</a>
			<cfelse>
				<a href="#cgi.script_name#?searchType=advanced">#application.util.string.actionLinkFormat2('advanced search')#</a>
			</cfif>
			<!--- 14479 (RBL) 01/24/08 [end] --->
			<A HREF="scorecard_main.cfm?source=scorecard">#application.util.string.actionLinkFormat2('scorecard')#</A>

			<cfif Get_Profile_Settings.Mass_Billback_Pay EQ 1 AND appSettings.Mass_Pay_Billback IS NOT 0>
				<A style="cursor:pointer;" onClick="payBillbacks()">#application.util.string.actionLinkFormat2('pay selected billbacks')#</A>
			</cfif>

			<CFIF application.appSettingsGet.getBillback_Module() EQ 1 AND Get_Profile_Settings.BB_Create EQ 1 AND appSettings.getShowManualBillback()>
				<A HREF="/billbacks/capture/index.cfm">#application.util.string.actionLinkFormat2('create new')#</A>
			</CFIF>

	<CFIF appSettings.getShowAutoBillback() EQ 1 AND Get_Profile_Settings.BB_Create EQ 1>
		<cfif appSettings.getAutoBillBackType()>
			<A HREF="/billbacks/capture/INDEX.CFM?AUTOBB=2">#application.util.string.actionLinkFormat2('create auto')#</A>
		<cfelse>
			<A HREF="/billbacks/capture/INDEX.CFM?AUTOBB=1">#application.util.string.actionLinkFormat2('create auto')#</A>
		</cfif>
	</CFIF>
			<!---defaults to hidden status until search result is displayed--->
			<A id="dnload012">#application.util.string.actionlinkformat2('download data')#</A>
			<A id="uploadDocs">#application.util.string.actionlinkformat2('upload documents')#</A>
		</cfoutput>
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
		cursor:				pointer;
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
   background-color 	: dddddd;
   border-bottom		: solid 3px black;
   cursor				: pointer;
  }
  TD.headerselected
  {
   border-left			: solid 3px black;
   border-top			: solid 3px black;
   border-right			: solid 3px black;
   background-color 	: #fore_Color#;
   cursor				: pointer;
   TEXT-TRANSFORM		: uppercase;
  }
  TD.headerblank
  {
   border-bottom		: solid 3px black;
  }
  TD.headerspacer
  {
   border-bottom		: solid 3px black;
  }
  TD.headerlastone
  {
   border-left			: solid 3px black;
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

</SCRIPT>

<cfparam name="URL.SECTION_TO_OPEN" 	default=1>

<CFSET SCURL="billback_Search_Result.cfm">
<CFSET Status_List="Work In Progress,Request For App.,Approved,Paid">
<CFOUTPUT>
<CFSET i=1>

<!------ D10185 (DRK): Remove Segment Field on Billbacks if client doesn't use that feature.  ----->
<!------ check if business segment is on at the application level ----->
<cfset businessSegmentsMgr = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset businessSegmentSettings = businessSegmentsMgr.getEnabled() />
<cfset businessSegmentsOn = businessSegmentSettings.Display_Segment_In_Billbacks>

<CFINCLUDE TEMPLATE="billback_Table_Measures.cfm">

<CFINCLUDE TEMPLATE="billback_Search_Form.cfm">
<!--- D29824 New Settings.. --->
	 <script>
	 	function importbillbacks(bb_id){
			window.opener.importbillbacks(bb_id);
			self.close();
 		}
	 </script>
<!--- D29824 New Settings.. --->
<CFSET ASC_IMG="down_1.gif">
<CFSET DESC_IMG="up_1.gif">

<script>
	<cfif searchType EQ "advanced">
		document.all.Billback_Title.focus();
	<cfelse>
		document.all.Billback_Number.focus();
	</cfif>
</script>

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

		$(document).ready(function() {
		initialise();
		//Click Handler for the chkAllPaid CheckBox
		$('##chkAllPaid').click(function() {
		    var chkBox = $(this);
			var arrWork = window.massPayBillbackList;
			var arrCurrent = [];
			var arrMassPayBBNew = [];
			var arrItems = [];
			var arrItemsChecked = [];
			//get list of items on current page
			arrItems = $("##Table_Header").contents().find('.chkPaid').map(function() {
					return $(this).val();
			}).get();

			//alert(arrItems.join());

			//select/deselect all of the checkboxes in Iframe
			$("##Table_Header").contents().find('.chkPaid').attr('checked', chkBox.is( ':checked' ) );

			//remove these items on this page from master list.  could be dupes if they were addded individually OR we need to clear them anyway
			arrCurrent = $.grep(arrWork,function (item) {
			    return $.inArray(item, arrItems) == -1;
			});
			//Now add all items on this page to master list if chkAllPaid is checked
			if(chkBox.is( ':checked' )){
				arrMassPayBBNew = arrItems.concat(arrCurrent);
			}else{
				arrMassPayBBNew = arrCurrent;
			}
			// Set local var used in Form submit to masspaybillbacks.cfm
			window.massPayBillbackList = arrMassPayBBNew;
		});
	});


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

	function setStatusHref()
	{
		var aObj 	= getParentObject(event.srcElement,"A");
		aObj.target = "ScoreCardList";
		var oTable_Status = document.all.Table_Status;
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
		initialise();
		sc_URL = aObj.href;
		setSortImage(document.all.TD_BBI);
		event.cancelBubble = true;
	}

	function DeleteAll(bChecked)
	{
		var childCheckboxes = Search_Result.document.all.selectedReasons;
		if(childCheckboxes != null){
			if (childCheckboxes.length)
			{
				for(var x=0; x<childCheckboxes.length;x++){
					box = childCheckboxes[x]
					/* bChecked could be true or false.
					true or false based on browser - IE 10 and above or IE 9 and below.
					'1' as an argument below means "true", '0' means false. */
					box.checked = checkOrUncheckBeforeFireEvent(bChecked);
					/* Call the "OnClick event" on the individual checkboxes. */
					callfireEvent(document,childCheckboxes[x],'Click');
				}
			}
			else
			{
				/* bChecked could be true or false.
				true or false based on browser - IE 10 and above or IE 9 and below.
				'1' as an argument below means "true", '0' means false. */
				childCheckboxes.checked = checkOrUncheckBeforeFireEvent(bChecked);
				/* Call the "OnClick event" on the individual checkboxes. */
				callfireEvent(document,childCheckboxes,'Click');
			}
			}
		}
</SCRIPT>

	<div id="BBInfo" style="display:none;margin:0 0 5px 50%;padding:0;">
		<span id="BBCount"    class="summary"></span>
		<span id="BBClaimed"  class="summary"></span>
		<span id="BBVariance" class="summary"></span>
	</div>

	<cfset request.table_Width = 1350>

	<TABLE ID="headerTable" STYLE="display:none;" CELLPADDING="2" CELLSPACING="0" border="0" WIDTH="#table_Width#" BGCOLOR="#fore_Color#" CLASS="Maintable">

		<TR VALIGN="bottom">
			<TD CLASS="tableheaders" ID="header" width="#spacerwidth#">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" width="#SelectionWidth#">
				<cfif CanDelete EQ 1>
					<input type="checkbox" name="DeleteBillbacks" onClick="DeleteAll(this.checked);" title="Select all Billbacks on this page to delete">
				<cfelse>
					&nbsp;
				</cfif>
			</TD>
        	<!--- ID="TD_STATUS" --->
			<TD CLASS="tableheaders" ID="header" ALIGN="center" WIDTH="#Status_Width#" nowrap STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('BBSTAT');" HREF="##">STATUS</A></B><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBSTAT"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" ALIGN="center" NOWRAP WIDTH="#UPPNF_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A OnClick="javaScript: setSortHref('BBCLOSURE');" HREF="##">TYPE</A></nobr><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBCLOSURE"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></TD>
            <!--- ID="TD_BBI" --->
			<TD CLASS="tableheaders" ID="header" NOWRAP WIDTH="#Number_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;&nbsp;<A OnClick="javaScript: setSortHref('BBI');" HREF="##">PAYABLE ##</a><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBI"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#BBD_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A OnClick="javaScript: setSortHref('BBD');" HREF="##">DATE</a></nobr><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBD"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Payee_And_Title_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;PAYEE</nobr></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Date_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A OnClick="javaScript: setSortHref('BBSD');" HREF="##">START</a>&nbsp;&nbsp;</nobr><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBSD"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Amount_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A OnClick="javaScript: setSortHref('BBA');" HREF="##">$ AMOUNT&nbsp;<SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBA"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</nobr></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Analyst_And_Segment_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A OnClick="javaScript: setSortHref('BBANA');" HREF="##">ANALYST</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</nobr><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBANA"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<!--- IF BBManualSetPaidStatus --->
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="15" STYLE="font-size:8pt;font-weight:bold" valign="top">
			<cfif Get_Profile_Settings.Mass_Billback_Pay IS 1 AND appSettings.Mass_Pay_Billback IS NOT 0 AND Get_Profile_Settings.BB_Approve>
				<SPAN ID="SP_MassPayAll" title="Select all Billbacks on this page for update to Paid status"><input type="checkbox" id="chkAllPaid" class="clCheckAll"  />
				</SPAN>
			</cfif>
			</TD>

			<!----
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Dev_Width#"><b><A HREF="##">$ Deviation</a></b></TD>
			----->
			<TD CLASS="tableheaders" width="#SelectionWidth#">
				<input type="checkbox" name="uploadAll" title="Select all Billbacks on this page for documents upload">
			</TD>
		</TR>
		<TR>
        	<!--- ID="TD_STATUS" --->
			<TD CLASS="tableheaders" ID="header" width="#spacerwidth#">&nbsp;</TD>
			<TD CLASS="tableheaders" width="#SelectionWidth#" style="text-align:center;">
				<cfif CanDelete EQ 1>
					<img src='/images/ocr/trash24.png' style="height:13px;width:13px;">
				<cfelse>
					&nbsp;
				</cfif>
			</TD>
			<TD CLASS="tableheaders" ID="header" ALIGN="left" WIDTH="#Status_Width#" nowrap STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" ALIGN="center" NOWRAP WIDTH="#UPPNF_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">
			<!--- Dev Note: Clay 11061 --->
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<A OnClick="javaScript: setSortHref('BBDEVIATED');" HREF="##">
			<CFIF application.returned_customer_setting.Customer_Keyword EQ "Mccain">
			VAR
			<CFELSE>
			DEV
			</CFIF></a><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBDEVIATION"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#">	</TD>
            <!--- ID="TD_BBI" --->
			<TD CLASS="tableheaders" ID="header" NOWRAP WIDTH="#Number_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top"><cfif application.returned_customer_setting.Accounting_Specialist eq 1><A HREF="##" OnClick="javaScript: setSortHref('PP');"><B>PAYMENT PROCESSOR</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "PP"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN><cfelse>&nbsp;</cfif></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#BBD_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A OnClick="javaScript: setSortHref('BBNUM');" HREF="##">BILLBACK ##</a><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBNUM"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Payee_And_Title_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A OnClick="javaScript: setSortHref('BBT');" HREF="##">TITLE</A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBT"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Date_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A OnClick="javaScript: setSortHref('BBED');" HREF="##">END</a>&nbsp;&nbsp;<SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBED"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Amount_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			<cfif businessSegmentsOn>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Analyst_And_Segment_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('BBSE');" HREF="##">SEGMENT</a><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBSE"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<cfelse>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Analyst_And_Segment_Width#" valign="top">&nbsp;</TD>
			</cfif>
			<!--- "Paid status" checkbox cell --->
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="15">&nbsp;</TD>
			<!----
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Dev_Width#">&nbsp;</TD>
			----->
			<TD CLASS="tableheaders" width="#SelectionWidth#" style="text-align:center;">
				<img src='/images/ocr/upload-circle-24-c406be4.png' style="height:13px;width:13px;">
			</TD>
		</TR>
		<TR>
			<TD CLASS="tableheaders" ID="header" width="#spacerwidth#">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" width="#SelectionWidth#">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" ALIGN="left" WIDTH="#Status_Width#" nowrap valign="top">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" ALIGN="center" NOWRAP WIDTH="#UPPNF_Width#" valign="top">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" NOWRAP WIDTH="#Number_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#BBD_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A OnClick="javaScript: setSortHref('BBREFN');" HREF="##">REFERENCE ##</a><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBREFN"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Payee_And_Title_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Date_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Amount_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			<cfif businessSegmentsOn>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Analyst_And_Segment_Width#">&nbsp;</TD>
			<cfelse>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Analyst_And_Segment_Width#" valign="top">&nbsp;</TD>
			</cfif>
			<!--- "Paid status" checkbox cell --->
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="15">&nbsp;</TD>
			<TD CLASS="tableheaders" width="#SelectionWidth#">&nbsp;</td>
		</TR>
	</TABLE>
	<script src="/script/javascript/jquery.noty.packaged.min.js"></script>
	<script type="text/javascript">

		var intervalId = 0;

		function statusHandler()
		{
			intervalId = self.setInterval("statusDisplay()",1000);
		}

		function clearHandler()
		{
			alert("In billback_search.cfm old fn");
			document.getElementById("statusMessage").innerHTML = "";
			document.getElementById("statusMessage").style.display='none';
			clearInterval (intervalId);
		}

		function statusDisplay()
		{
			document.getElementById("statusMessage").innerHTML = "Please Wait...";
			setTimeout ('document.getElementById("statusMessage").innerHTML = ""', 500);
		}

		$('##dnload012').click(function() {
			noty( { text: "Downloading..."
		        	,layout:'topRight'
		        	,type:'information'
		        	,killer:true
		        	,timeout:3500	});
			window.open( "/Common_Files/exportAll.cfm?" + "type=billback_search"
														+ "&friendlyFileName=Billback_Search"
														+ "&savedSearch=" + document.getElementById('Table_Header').contentWindow.savedRequestFileName
			              ,"_blank"
			              ,"toolbar=no, scrollbars=no, resizable=no, top=10000, left=1, width=1, height=1");
		});

		$( 'input[name=uploadAll]' ).click( function() {
			const uploadAll = $( this );
			const frame = $( '##Table_Header' );
			// gather all selected billbacks in the upload column
			frame.contents().find( 'input.upload' ).each( function() { 
				$( this ).prop( 'checked', uploadAll.prop( 'checked' ) );
			} );
		});

		$( '##uploadDocs' ).click( function() {
			const frame = $( '##Table_Header' );

			// gather all selected billbacks in the upload column
			let selectedBBs = [];
			frame.contents().find( 'input.upload:checked' ).each( function() { 
				selectedBBs.push( $(this).parents( 'tr' ).attr( 'id' ) );
			} );
			const BillbackList = selectedBBs.join( ',' ).replace( /_/g, "-" );

			// validate for emptiness
			if ( BillbackList === '' ) {
				noty({ layout:"center", type:"error", killer:true, text: "Please select at least one billback under the last column." });
				return;
			}

			$('##UPBBList').val(BillbackList)
      			$('##UploadDocuments').submit();

			// proceed with the upload
			//window.open( "/Common_Files/documents/create_multiple_document_details.cfm?BBMassUpload=1&BillbackList="+BillbackList,"_blank","toolbar=no, scrollbars=no, resizable=no, top=0, left=1, width=500, height=500");
		});
		function target_popup(form) {
			window.open('', 'MassUpload', 'toolbar=no, scrollbars=no, resizable=no, top=0, left=1, width=500, height=500');
			form.target = 'MassUpload';
		}
	</script>
	<form name="UploadDocuments" action="/Common_Files/documents/create_multiple_document_details.cfm?BBMassUpload=1" method="post" id="UploadDocuments" onsubmit="target_popup(this)">
		<input type="hidden" name="BillbackList" value="" id="UPBBList">
		<input type="hidden" name="BBMassUpload" value="1">
	</form>

	<!--- D70951 :: ‘Please Wait’ Indicator     Release START --->
	<!---	<div id="statusMessage" style="height: 1.5em; font-size: 2em; color: red;" align="center"></div>  --->
	<div id="divWait1" class="customContainer" style="width:98%; display:none;"></div>
	<!--- D70951 :: ‘Please Wait’ Indicator     Release END --->

	<style>
		##Table_Header {
			width: #( table_Width + 18 )#px;
			height: calc(100vh - 160px);
			border: 0px;
		}
	</style>
	<iframe id="Table_Header" name="Search_Result" src="#SCURL#" frameborder="0"></iframe>
	
	</TD>
	</TR>
	</TABLE>
</CFOUTPUT>

<CFSET increaseLength = 140>
<CFSET increasePageLength = 5>
<cfset show_hide_type = 1>
<cfinclude template="/Scorecard/Show_Hide_Search_Form.cfm">
<!------
</BLOCKQUOTE>
----->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<form action="masspaybillbacks.cfm" method="post" name="approvalForm" id="approvalForm">
	<input type="Hidden" name="massPayBillbackList" value="">
</form>
<!--- candelete --->
<form action="DeleteSelectedBillbacks.cfm" method="post" name="DeleteSelected" id="DeleteSelected">
	<input type="hidden" name="BillbacksToDelete" value="">
</form>

<script type="text/javascript">
	/* set the height of the data set based on resolution */
	// document.getElementById('Table_Header').style.height = document.body.clientHeight - 290;
</script>

</BODY>
</HTML>