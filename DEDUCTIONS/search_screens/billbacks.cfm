<cfsilent>
<!---
FILE:
FILENAME: 	DEDUCTIONS/search_screens/billbacks.cfm
CREATED: 	??/??/???? - ???
EDITED:		11/17/2008 - RBL

FUNCTIONALITY:
- This template is a piece of the display billback search results puzzle...
--->
</cfsilent>
<CFSET PAGE_TITLE=	"Billback Search">
<CFSET GROUP=		"Billbacks">
<CFSET Source="Deductions">
<CFPARAM NAME="finishedsearching" default="0">
<CFPARAM NAME="finishedselecting" default="0">
<CFPARAM NAME="Done" default="0">
<CFPARAM NAME="DoSearch" default="0">
<CFPARAM NAME="form.currentBillbackList" default="" />
<CFPARAM NAME="form.selectedItemValue" default="0" />
<CFPARAM NAME="form.sort_by"  default="BBT"/>
<CFPARAM NAME="Default_Sort"  default="#form.sort_by#"/>
<CFPARAM NAME="form.sort_Order" default="DESC" />
<CFPARAM NAME="Default_Sort_Order"  default="#form.sort_Order#"/>

<!--- D17544 RBL 11/17/08 [begin]
this is duplicitious but not sure where else it surfaces... RBL --->
<cfparam name="url.searchType" type="string" default="quick">
<!--- D17544 RBL 11/17/08 [end] --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<CFIF Done IS 1>
<!---Submit the form--->

	<!---Parse into type & ID--->
	<CFIF appSettings.getMultiple_BB_Per_Deduction()>
		<cfset Billback_ID = replace(Form.currentBillbackList, '_', '-', "all")>
	<CFELSE>
		<cfset Billback_ID = replace(selectedReasons, '_', '-', "all")>
	</CFIF>
	<cfinclude template="/Deductions/save_billback_association.cfm" />

	<cfoutput>
	<script>
		window.opener.location.href = "/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#"
		window.close()
	</script>
	</cfoutput>
	<cfabort>

</CFIF>

<!--- We have a new checkbox to filter on bill to / distributor  --->
<cfif DoSearch IS 0 AND len(Trim(Distributor_ID)) GT 0 AND appSettings.getDD_Restrict_ShipTo_For_BB() IS 1>
<cfset useLakebaseForDistributorName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForDistributorName>
	<cftry>
		<cfset DistributorName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"select" = "name",
				"bsa_foodservice_customers_id" = "eq.#Distributor_ID#"
			}),
			"name"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDistributorName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDistributorName>
<cfquery name="DistributorName" datasource="#application.datasource#">
SELECT Name
FROM BSA_Foodservice_Customers
WHERE BSA_Foodservice_Customers_ID = '#Distributor_ID#'
</cfquery>
</cfif>

<cfset Form.Distributor_Name = DistributorName.Name>
<cfset Highlight = 1>
</cfif>

<cfif application.appSettingsGet.getBillback_Module() NEQ application.returned_customer_setting.customer_setting_error_string>
	<cfif application.appSettingsGet.getBillback_Module() NEQ 1>
		<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
	</cfif>
<cfelse>
	<B><FONT COLOR="Red"><CFOUTPUT>#application.appSettingsGet.getBillback_Module()#</CFOUTPUT></FONT></B>
</cfif>


<!--- <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"> --->
<!DOCTYPE HTML>
<HTML>
<HEAD>
	<TITLE>Billback Search</TITLE>
	<!--- <LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css"> --->
</HEAD>

<BODY>
<CFSET fore_Color="FFE083">

<CFOUTPUT>
<STYLE TYPE="text/css">
table##bb_search_result {
	margin: 0 auto;
	width: 1250px;
}
Table.maintable td.tableheaders {
	font-size:12px;
	font-weight:bold;
	border-bottom:thin ##FFFFFF 0px;
}
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
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
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
<CFSET ExcludeLockedBillbacks = 1>
<CFSET SCURL="/billbacks/scorecard/billback_Search_Result.cfm">
<CFSET Status_List="Work In Progress,Request For App.,Approved,Paid">
<CFOUTPUT>
<CFSET i=1>

<CFSET CallingBBSearchFromDD = 1>

<!------ D10185 (DRK): Remove Segment Field on Billbacks if client doesn't use that feature.  ----->
<!------ check if business segment is on at the application level ----->
<cfset businessSegmentsOn = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager").isEnabled() />

<CFINCLUDE TEMPLATE="/billbacks/scorecard/billback_Table_Measures.cfm">

<CFINCLUDE TEMPLATE="/billbacks/scorecard/billback_Search_Form.cfm">


<CFSET ASC_IMG="down_1.gif">
<CFSET DESC_IMG="up_1.gif">

<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
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
		// alert("sortby = " + sortBy + "sortVal = " + sortVal);
		/*
		if(sortBy == sortVal)
		{
			sort_order = -1;
		}
		else
		{
			sort_order = 1;
			sortBy = sortVal;
		}
		*/
		var SORTORDER;
		// if(SORTORDER == "ASC")
		if(sort_order == 1)
		{
			SORTORDER = "DESC";
			orderFileName = "#DESC_IMG#";
		}
		else
		{
			SORTORDER = "ASC";
			orderFileName = "#ASC_IMG#";
		}
		//alert("sortVal = " + sortVal + "SortOrder = " + SORTORDER);
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
	function selectAll(){

			if(window.checkallReasons != null){
				for(var x=0; x<checkallReasons.length;x++){
					box = getFirstChild(checkallReasons[x])
					box.checked = document.all.checkall.checked
				}
			}
		}


		function finishedSearching() {
			if (Any_Object_Checked(document.all.selectedReasons))
			{
				document.ReturnResults.Done.value = 1;
				document.ReturnResults.submit();
				<CFIF appSettings.getMultiple_BB_Per_Deduction()>
					enableDisableTD(false);
				</cfif>
			}
			else
			{
				alert("Please pick a billback to add to the deduction and try again.")
			}
		}

function enableDisableTD(bEnable)
{
	var spEnabledObj = document.all.SP_ASSOCIATE_MULTIPLE_BB_ENABLED;
	var spDisabledObj = document.all.SP_ASSOCIATE_MULTIPLE_BB_DISABLED;
	if(bEnable)
	{
		spEnabledObj.style.display = "";
		spDisabledObj.style.display = "none";
	}
	else
	{
		spEnabledObj.style.display = "none";
		spDisabledObj.style.display = "";
	}


}
 <CFIF appSettings.getMultiple_BB_Per_Deduction()>
function checkAll(){
			if(window.selectedReasons != null){

				if(selectedReasons.length)
				{

					for(var x=0; x<selectedReasons.length;x++){
						box = getFirstChild(selectedReasons[x])
						// If Select All is checked
								if(document.CheckAll.selectAll.checked == 1){
						// If the individual bilback checkbox is not already selected
									if(! box.checked){
						// Check that Checkbox
										box.checked = document.CheckAll.selectAll.checked;
										}
										}
										// If Select All is unchecked and in the individual check box is already selected
										else{
										if(box.checked){
										box.checked = document.CheckAll.selectAll.checked;
									}
								}
						//box.fireEvent("onclick");

					}
				}
				else
				{
					box = getFirstChild(selectedReasons)
					box.checked = document.CheckAll.selectAll.checked;
					//box.fireEvent("onclick");
				}

				addRemoveBillback();    // refresh available amount
			}
		}

</cfif>

</SCRIPT>

<form name="CheckAll">
	<TABLE CELLPADDING="2" CELLSPACING="0" border="0" id="bb_search_result" BGCOLOR="#fore_Color#" CLASS="Maintable">

		<TR VALIGN="bottom">
			<TD CLASS="tableheaders" width="#spacerwidth#">&nbsp;</TD>
			<TD CLASS="tableheaders" width="#SelectionWidth#"><cfif Source Is "Deductions"><CFIF appSettings.getMultiple_BB_Per_Deduction() AND source EQ "Deductions"><input type="checkbox" name="selectAll"  id="SelectAll" onclick="checkAll();" ><cfelse>&nbsp;</cfif><cfelse>&nbsp;</cfif></TD>
			<TD CLASS="tableheaders" ALIGN="center" WIDTH="#Status_Width#"   nowrap><A OnClick="javaScript: setSortHref('BBSTAT');" HREF="##">Status</A><SPAN ID="SP_SP" <CFIF Default_Sort NEQ "BBSTAT"> STYLE="VISIBILITY:HIDDEN"</CFIF> >&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ALIGN="center" NOWRAP WIDTH="#UPPNF_Width#" >&nbsp;&nbsp;&nbsp;<A OnClick="javaScript: setSortHref('BBCLOSURE');" HREF="##">Type</A><SPAN ID="SP_SP"  <CFIF Default_Sort NEQ "BBCLOSURE"> STYLE="VISIBILITY:HIDDEN"</CFIF> >&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" NOWRAP WIDTH="#Number_Width#" ><A OnClick="javaScript: setSortHref('BBI');" HREF="##">Payable ##</a><SPAN ID="SP_SP" <CFIF Default_Sort NEQ "BBI"> STYLE="VISIBILITY:HIDDEN"</CFIF> >&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" nowrap WIDTH="#BBD_Width#" ><A OnClick="javaScript: setSortHref('BBD');" HREF="##">Date</a><SPAN ID="SP_SP" <CFIF Default_Sort NEQ "BBD"> STYLE="VISIBILITY:HIDDEN"</CFIF> >&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" nowrap WIDTH="#Payee_And_Title_Width#" >Payee<SPAN ID="SP_SP" <CFIF Default_Sort NEQ "Pay"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" nowrap WIDTH="#Date_Width#" ><A OnClick="javaScript: setSortHref('BBSD');" HREF="##">Start</a><SPAN ID="SP_SP" <CFIF Default_Sort NEQ "BBSD"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" nowrap WIDTH="#Amount_Width#" ><A OnClick="javaScript: setSortHref('BBA');" HREF="##">$ Amount</a><SPAN ID="SP_SP" <CFIF Default_Sort NEQ "BBA"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" nowrap WIDTH="#Analyst_And_Segment_Width#"><A OnClick="javaScript: setSortHref('BBANA');" HREF="##">ANALYST</a><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBANA"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<!--- "paid status" checkbox is on the results page. adding a cell for that. --->
			<TD CLASS="tableheaders" nowrap WIDTH="15" valign="top">&nbsp;</TD>
		</TR>
		<TR>
			<TD CLASS="tableheaders" width="#spacerwidth#">&nbsp;</TD>
			<TD CLASS="tableheaders" width="#SelectionWidth#">&nbsp;</TD>
			<TD CLASS="tableheaders" ALIGN="center" WIDTH="#Status_Width#" nowrap>&nbsp;</TD>
			<TD CLASS="tableheaders" ALIGN="center" WIDTH="#UPPNF_Width#">&nbsp;&nbsp;&nbsp;<A OnClick="javaScript: setSortHref('BBDEVIATED');" HREF="##"><CFIF application.returned_customer_setting.Customer_Keyword EQ "Mccain">Var<CFELSE>Dev</CFIF></A><SPAN ID="SP_SP" <CFIF Default_Sort NEQ "BBDEVIATED"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></td>
			<TD CLASS="tableheaders" NOWRAP WIDTH="#Number_Width#">&nbsp;</TD>
			<TD CLASS="tableheaders" nowrap WIDTH="#BBD_Width#"><A OnClick="javaScript: setSortHref('BBNUM');" HREF="##">Billback ##</a><SPAN ID="SP_SP" <CFIF Default_Sort NEQ "BBNUM"> STYLE="VISIBILITY:HIDDEN"</CFIF> >&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" nowrap WIDTH="#Payee_And_Title_Width#"><A OnClick="javaScript: setSortHref('BBT');" HREF="##">Title</A><SPAN ID="SP_SP" <CFIF Default_Sort NEQ "BBT"> STYLE="VISIBILITY:HIDDEN"</CFIF> >&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" nowrap WIDTH="#Date_Width#"><A OnClick="javaScript: setSortHref('BBED');" HREF="##">End</a><SPAN ID="SP_SP" <CFIF Default_Sort NEQ "BBED"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" nowrap WIDTH="#Amount_Width#">&nbsp;</TD>
			<cfif businessSegmentsOn>
			<TD CLASS="tableheaders" nowrap WIDTH="#Analyst_And_Segment_Width#"><A OnClick="javaScript: setSortHref('BBSE');" HREF="##">SEGMENT</a><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBSE"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<cfelse>
			<TD CLASS="tableheaders" nowrap WIDTH="#Analyst_And_Segment_Width#" valign="top">&nbsp;</TD>
			</cfif>
			<!--- "paid status" checkbox is on the results page. adding a cell for that. --->
			<TD CLASS="tableheaders" nowrap WIDTH="15" valign="top">&nbsp;</TD>
		</TR>
		<TR VALIGN="bottom">
			<TD CLASS="tableheaders" width="#spacerwidth#">&nbsp;</TD>
			<TD CLASS="tableheaders" width="#SelectionWidth#">&nbsp;</TD>
			<TD CLASS="tableheaders" ALIGN="center" WIDTH="#Status_Width#" nowrap>&nbsp;</TD>
			<TD CLASS="tableheaders" ALIGN="center" WIDTH="#UPPNF_Width#">&nbsp;</td>
			<TD CLASS="tableheaders" NOWRAP WIDTH="#Number_Width#">&nbsp;</TD>
			<TD CLASS="tableheaders" WIDTH="#BBD_Width#"  valign="top" NOWRAP STYLE="width=100px;"><A OnClick="javaScript: setSortHref('BBREFN');" HREF="##">Reference ##</a><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBREFN"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" nowrap WIDTH="#Payee_And_Title_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			<TD CLASS="tableheaders" nowrap WIDTH="#Date_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			<TD CLASS="tableheaders" nowrap WIDTH="#Amount_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			<cfif businessSegmentsOn>
			<TD CLASS="tableheaders" nowrap WIDTH="#Analyst_And_Segment_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			<cfelse>
			<TD CLASS="tableheaders" nowrap WIDTH="#Analyst_And_Segment_Width#" valign="top">&nbsp;</TD>
			</cfif>
			<!--- "paid status" checkbox is on the results page. adding a cell for that. --->
			<TD CLASS="tableheaders" nowrap WIDTH="15" valign="top">&nbsp;</TD>
		</TR>
	</TABLE>

	<input type="hidden" id="divWait1">
	<input type="hidden" id="dnload012">
</form>

	</TD>
	</TR>
	</TABLE>

<!--- Please Wait Indicator --->
<div class="customContainer" style="display:none;margin-left:250px;"></div>
<!--- Please Wait Indicator --->	

	<CFSET FORM.Source="Deductions">
	<CFSET FORM.DOSEARCH = 1>
	<script type="text/javascript">

		var intervalId = 0;

		function statusHandler()
		{
			intervalId = self.setInterval("statusDisplay()",1000);
		}

		function clearHandler()
		{
			document.getElementById("statusMessage").innerHTML = "";
			document.getElementById("statusMessage").style.display='none';
			clearInterval (intervalId);
		}

		function statusDisplay()
		{
			document.getElementById("statusMessage").innerHTML = "Please Wait...";
			setTimeout ('document.getElementById("statusMessage").innerHTML = ""', 500);
		}

	</script>
	<div id="statusMessage" style="height: 1.5em; font-size: 2em; color: red;" align="center"></div>

	<cfinclude template="#SCURL#">
</CFOUTPUT>

<CFSET increaseLength = 164>
<CFSET increasePageLength = 5>


<cfinclude template="/Scorecard/Show_Hide_Search_Form.cfm">

<script type="text/javascript" src="/script/javascript/numeral.min.js"></script>
<script>
var starting_avail_amt  = <cfoutput>#(GetDeductionDetails.DD_Amount - form.selectedItemValue)#</cfoutput>;
function calculate_Available_Amount() {
	// total up all selected billbacks
	var checked_bb_total = 0;
	jQuery('input[name=selectedReasons]:checked').each(function(){
		checked_bb_total = checked_bb_total + numeral( jQuery(this).attr("bb_amount") );
	})
	return (starting_avail_amt - checked_bb_total);
}

function addRemoveBillback(thisObj) {
	<cfif source EQ "deductions" AND appSettings.getMultiple_BB_Per_Deduction()>
		// call from individual checkbox
		if (arguments.length > 0) {
				var thisAmount = parseFloat(thisObj.getAttribute('BB_Amount'));
				if (thisObj.checked)
					addToSelectedList(thisObj, thisAmount);
				else
					removefromSelectedList(thisObj, thisAmount);
		}
		// call from checkAll()
		else
			jQuery('input[name=selectedReasons]').each(function(){
				var  thisObj = jQuery(this)[0]
				     ,thisAmount = parseFloat(thisObj.getAttribute('BB_Amount'));
				if (thisObj.checked)
					addToSelectedList(thisObj, thisAmount);
				else
					removefromSelectedList(thisObj, thisAmount);
			});
	</cfif>

	var color = 'black'
		,avail_amt = <cfoutput>#GetDeductionDetails.DD_Amount#</cfoutput> - document.all.SearchForm.selectedItemValue.value;
		/* 81623 - Unable to add a BB to a deduction b/c the 'add to deduction' link is greyed out
			Commenting the below as this is causing an issue when checking and enabling the "add to Deduction link" 
		*/
		//avail_amt = numeral(avail_amt).format('0,0.00');
	avail_amt = Math.round((avail_amt + Number.EPSILON) * 100) / 100;	
	if (avail_amt == 0)
		color = 'blue';
	else if (avail_amt < 0)
		color = 'red';
	jQuery('#SP_DISPLAY_DIFF').text( numeral(avail_amt).format("($0,0.00)") ).css("color", color);

	<cfif appSettings.getDDCloseWithEqualBBAmt()>
	    if(avail_amt == 0)
	<cfelse>
		if(avail_amt >= 0)
	</cfif>
			enableDisableTD(true);
		else
			enableDisableTD(false);
}
</script>