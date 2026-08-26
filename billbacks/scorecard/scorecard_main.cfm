<cfsilent>
<!---
FILE:
FILENAME: 	billbacks/scorecard/scorecard_main.cfm
CREATED: 	??/??/???? - ???
EDITED:		11/17/2008 - RBL

FUNCTIONALITY:
- This template is a piece of the display billback search results puzzle...
--->
</cfsilent>

<cfheader name="Cache-Control" value="no-store">
<CFSET PAGE_TITLE=	"Billback Scorecard Detail">
<CFSET GROUP=		"Billbacks">
<cfparam name="CanDelete" default="0">
<cfparam name="url.section_to_open" 	default=1>
<cfparam name="url.program_agree_status_id" default="0">
<cfparam name="URL.Source" default="" />

<cfinclude template="/common_files/jQuery.cfm">
<!---Gets application settings--->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<cfif application.appSettingsGet.getBillback_Module() NEQ application.returned_customer_setting.customer_setting_error_string>
	<cfif application.appSettingsGet.getBillback_Module() NEQ 1>
		<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
	</cfif>
<cfelse>
	<B><FONT COLOR="Red"><CFOUTPUT>#application.appSettingsGet.getBillback_Module()#</CFOUTPUT></FONT></B>
</cfif>
<!---D43444	:: Billback scorecard alignment changes for payment request --->
<cfinclude template="/actionFormat.cfm">

<!--- unlock this users billbacks --->
<cfinclude template="unlock_billbacks.cfm">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Scorecard Detail</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

	<script>
	var massPayBillbackList = [];
	var massReleaseBillbackList = [];
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

	function releaseBillbacks()
	{
		if(massReleaseBillbackList.length > 0)
		{
			if(confirm("There are " + massReleaseBillbackList.length + " billback(s) which have been selected. Press OK to mark selected billbacks as 'Released'."))
			{
				/* "BBToBeReleasedList" exists on "\GL_Code\Gl_Code_In_Billback\Payment_Request\SC_Payment_Request_VendorOnly.cfm".
				It is the list of billbacks selected for "release".
				*/
				/* When we use "location.reload();" to select or unselect all billbacks on "\GL_Code\Gl_Code_In_Billback\Payment_Request\SC_Payment_Request_VendorOnly.cfm",
				the document.ScoreCardList.Status_Change.BBToBeReleasedList.value becomes blank, and so hwre we are reassigning the the list of selected billbacks to 
				"document.ScoreCardList.Status_Change.BBToBeReleasedList.value".
				*/
 				newBBlistStr = JSON.stringify(massReleaseBillbackList);
				newBBlistStr = newBBlistStr.replace('["','');
				newBBlistStr = newBBlistStr.replace('"]','');
				
				document.ScoreCardList.Status_Change.BBToBeReleasedList.value = newBBlistStr;
				document.ScoreCardList.Status_Change.Form_Submitted.value = 1
				document.ScoreCardList.Status_Change.submit();
			}
		}
	else
		{
		alert("Please select at least one billback to release")
		}
	}

	</script>

</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onLoad="">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


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

		<!--- 62833: Update [ pay selected billbacks ] feature to work with approved billbacks / option '3' for both RFA and Approved status /Anand Rao/08-Sep-2016--->		
		<cfif appSettings.Mass_Pay_Billback IS 1> <!--- Payment request to Paid --->
			<cfset Status_to_Show = 4>
		</cfif>
		<cfif appSettings.Mass_Pay_Billback IS 2> <!--- RFA to paid --->
			<cfset Status_to_Show = 2>
		</cfif>
		<cfif appSettings.Mass_Pay_Billback IS 3> <!--- RFA or Approved to paid --->
			<cfset Status_to_Show = 3 />
			<cfif URL.SECTION_TO_OPEN EQ 2>
				<cfset Status_to_Show = 2>
			<cfelseif URL.SECTION_TO_OPEN EQ 3>
				<cfset Status_to_Show = 3>
			</cfif>
		</cfif>
		
<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="CENTER">
<CFOUTPUT>
	<TR>
		<TD>
			<TABLE WIDTH="1250">
				<TR>
					<TD ALIGN="LEFT">
						<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
					</TD>
					<TD ALIGN="RIGHT">
							<A HREF="billback_Search.cfm">#ActionText("search billback")#</A>
						<cfif Get_Profile_Settings.Mass_Billback_Pay EQ 1 AND appSettings.Mass_Pay_Billback IS NOT 0 AND (URL.SECTION_TO_OPEN EQ Status_to_Show)>
							<A style="cursor:pointer;" onClick="payBillbacks()">#ActionText("pay selected billbacks")#</A>
						</cfif>
						<cfif appSettings.getBBPaymentRequestHoldRelease() eq 1>
							<A id="idReleaseBB" style="cursor:pointer;display:none;" onClick="releaseBillbacks()">#ActionText("release selected billbacks")#</A>
						</cfif>
						<CFIF application.appSettingsGet.getBillback_Module() EQ 1 AND Get_Profile_Settings.BB_Create EQ 1 AND appSettings.getShowManualBillback()>
							<A HREF="/billbacks/capture/index.cfm">#ActionText("create billback")#</A>
						</cfif>
						<CFIF appSettings.getShowAutoBillback() EQ 1>
							<CFIF Get_Profile_Settings.BB_Create EQ 1>
								<cfif appSettings.getAutoBillBackType()>
									<A HREF="/billbacks/capture/INDEX.CFM?AUTOBB=2"> #ActionText("create auto billback")#</A>
								<cfelse>
									<A HREF="/billbacks/capture/INDEX.CFM?AUTOBB=1"> #ActionText("create auto billback")#</A>
								</cfif>
							</CFIF>
						</CFIF>
					<!---	
						D43181 :: Route Summary
						<A HREF="/route/inbox.cfm?Route_Document_Type=1">#ActionText("inbox")#</A>
					--->
					</TD>
				</TR>
				<TR>
					<TD colspan="3">&nbsp; &nbsp; &nbsp; &nbsp;
						<IMG SRC="/Images/red.gif" WIDTH="10" HEIGHT="10" ALIGN="absmiddle">
						<FONT COLOR="Red"><B> billbacks in danger of being deducted</B></FONT>
					</TD>
				</TR>
			</TABLE>

<CFSET fore_Color="FFE083">


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
		
		/* Hide/show elements on page */
		function HideTable(TableObject1,TableObject2)
		{
	
			var TabObj1;
			var TabObj2;
				TabObj1 = eval(TableObject1);
				TabObj2 = eval(TableObject2);
	
			TabObj1.style.display='none'
			TabObj2.style.display=''
		}
	</SCRIPT>


<CFSET SCURL="scorecard_content.cfm?SECTION_TO_OPEN=#URL.SECTION_TO_OPEN#&Program_Agree_Status_ID=#Program_Agree_Status_ID#">

<CFIF LCase(application.returned_customer_setting.Show_Billback_Payment_Tab) EQ 1>
	<CFSET Payment_Request_Status_Number = 4>
<CFELSE>
	<CFSET Payment_Request_Status_Number = -1><!--- not yet implemented ---->
</CFIF>

<CFOUTPUT>
<CFSET i=0>


<cfquery name="BBStatus" datasource="#application.datasource#">
	SELECT		Billback_Status.Billback_Status_ID,
				<CFIF Get_Profile_Settings.BB_RFA_Agreed EQ 1>
					CASE
						WHEN Billback_Status.Billback_Status_ID = 2 THEN
							Program_Agree_Status.Program_Agree_Status_Desc
						ELSE Billback_Status.BB_Status_Description
					END BB_Status_Description,
				<CFELSE>
					Billback_Status.BB_Status_Description,
				</CFIF>
				ISNULL(Program_Agree_Status_ID, 0) Program_Agree_Status_ID
	FROM		Billback_Status
	LEFT JOIN 	Program_Agree_Status 
	ON  1=2 <CFIF Get_Profile_Settings.BB_RFA_Agreed EQ 1>
	OR	Billback_Status.Billback_Status_ID = 2</CFIF>
	WHERE		<CFIF LCase(application.returned_customer_setting.Show_Billback_Payment_Tab) EQ 1>
					<CFIF application.returned_customer_setting.Upload_GL_Code NEQ 1>
						Billback_Status.Billback_Status_ID NOT IN (6)
					<CFELSE>
						Billback_Status.Billback_Status_ID IN (1,2,3,4,5,6,8)
					</CFIF>
				<CFELSE>
					Billback_Status.Billback_Status_ID NOT IN  (4,6)
				</CFIF>
	ORDER BY 	Status_Order_Number
</cfquery>

<!------ D10185 (DRK): Remove Segment Field on Billbacks if client doesn't use that feature.  ----->
<!------ check if business segment is on at the application level ----->
<cfset businessSegmentsMgr = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset businessSegmentSettings = businessSegmentsMgr.getEnabled() />
<cfset businessSegmentsOn = businessSegmentSettings.Display_Segment_In_Billbacks>

<CFINCLUDE TEMPLATE="billback_Table_Measures.cfm">
<CFIF URL.SECTION_TO_OPEN EQ Payment_Request_Status_Number>
	<CFIF application.returned_customer_setting.Upload_GL_Code EQ 1>
		<CFSET SCURL="/GL_Code/GL_Code_In_Billback/Payment_Request/SC_Payment_Request.cfm?SECTION_TO_OPEN=5">
	<CFELSEIF appSettings.getVendor_Selection_Pay_Req() EQ 1 OR appSettings.getSettlement_SAP_Business()>
		<CFSET SCURL="/GL_Code/GL_Code_In_Billback/Payment_Request/SC_Payment_Request_VendorOnly.cfm?SECTION_TO_OPEN=5">
	<CFELSE>
			<CFSET SCURL="/Billbacks/Check_Book/Bank_Tran/General_Ledger_Account/Check_Issue_List.cfm?SECTION_TO_OPEN=5&Source=scorecard">
	</CFIF>
</CFIF>
<BR>
<TABLE border="0" width="#table_Width#" cellspacing="0" cellpadding="1" ID="Table_Status">
	<TR>
	 <TD CLASS="headerblank">&nbsp;</TD>
	<cfloop query="BBStatus">
	<cfset TableNum1 = "Table2">
	<cfset TableNum11 = "Table22">
	<cfset TableNum111 = "Table222">
	<cfset TableNum2 = "Table1">
	<cfset TableNum22 = "Table11">
	<cfset TableNum222 = "Table111">
		<CFSET i = i +1>
		<CFIF application.returned_customer_setting.Upload_GL_Code EQ 1 AND Billback_Status_ID EQ Payment_Request_Status_Number>
			<CFSET HrefURL = "/GL_Code/GL_Code_In_Billback/Payment_Request/SC_Payment_Request.cfm?SECTION_TO_OPEN=#Billback_Status_ID#&Program_Agree_Status_ID=#Program_Agree_Status_ID#&Source=#URL.Source#">
		<CFELSEIF (appSettings.getVendor_Selection_Pay_Req() EQ 1 OR appSettings.getSettlement_SAP_Business()) AND Billback_Status_ID EQ Payment_Request_Status_Number>
			<CFSET HrefURL = "/GL_Code/GL_Code_In_Billback/Payment_Request/SC_Payment_Request_VendorOnly.cfm?SECTION_TO_OPEN=#Billback_Status_ID#&Program_Agree_Status_ID=#Program_Agree_Status_ID#&Source=#URL.Source#">
	<cfelseif application.returned_customer_setting.Upload_GL_Code EQ 0 AND Billback_Status_ID EQ Payment_Request_Status_Number>
		<CFSET HrefURL="/Billbacks/Check_Book/Bank_Tran/General_Ledger_Account/Check_Issue_List.cfm?SECTION_TO_OPEN=#Billback_Status_ID#&Program_Agree_Status_ID=#Program_Agree_Status_ID#&Source=#URL.Source#">
		<CFELSE>
	<cfset TableNum1 = "Table1">
	<cfset TableNum11 = "Table11">
	<cfset TableNum111 = "Table111">
	<cfset TableNum2 = "Table2">
	<cfset TableNum22 = "Table22">
	<cfset TableNum222 = "Table222">
			<CFSET HrefURL = "scorecard_content.cfm?SECTION_TO_OPEN=#Billback_Status_ID#&Program_Agree_Status_ID=#Program_Agree_Status_ID#" >
		</CFIF>
		<A ID="#i#" OnClick="javaScript: setStatusHref();HideTable('#TableNum2#','#TableNum1#');HideTable('#TableNum22#','#TableNum11#');" CLASS="tablink_back" HREF="#HrefURL#">
		<TD nowrap WIDTH="92"
		<CFIF URL.SECTION_TO_OPEN EQ Billback_Status_ID AND Program_Agree_Status_ID EQ URL.Program_Agree_Status_ID>
			CLASS="headerselected"
		<CFELSE>
			CLASS="headernotselected"
		</CFIF>
		 ALIGN="center" NOWRAP ID="statusTab">
		<B>
		<A ID="#Billback_Status_ID#" OnClick="javaScript: setStatusHref(#Billback_Status_ID#);HideTable('#TableNum2#','#TableNum1#');HideTable('#TableNum22#','#TableNum11#');HideTable('#TableNum222#','#TableNum111#');" CLASS="tablink_back" HREF="#HrefURL#">
		<nobr>#LCase(BB_Status_Description)#</nobr></A></B></TD></A>

		<TD CLASS="headerspacer"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>

	</cfloop>
<TD CLASS="headerspacer" WIDTH="100%"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>

	</TR>
</TABLE>




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
			arrItems = $("##ScoreCardList").contents().find('.chkPaid').map(function() {
					return $(this).val();
			}).get();

			//select/deselect all of the checkboxes in Iframe
			$("##ScoreCardList").contents().find('.chkPaid').attr('checked', chkBox.is( ':checked' ) );
	
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
		var aObj 	= getParentObject(event.srcElement,"A");
		aObj.target = "ScoreCardList";
		aObj.href	= sc_URL + "&SORTBY=" + sortVal;


		if(sort_order < 0)
		{
			aObj.href	+= "&SORTORDER=DESC";
			orderFileName = "#DESC_IMG#";
		}
		else
		{
			aObj.href	+= "&SORTORDER=ASC";
			orderFileName = "#ASC_IMG#";
		}
		var thisCell = getParentObject(event.srcElement,"TD");
		setSortImage(thisCell);
	}

	function setSortImage(thisCell)
	{
		if($(thisCell).find('[id="SP_SP"]').get(0)){
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
	}
	
	function setStatusHref(statusID)
	{
		/*For BJF11948 Mass Delete billbacks*/
		<cfif CanDelete EQ 1>
		if (statusID != 1 && statusID != 2)
		{
			document.all.DeleteAll.style.visibility= "hidden";
		}
		else
		{
			document.all.DeleteAll.style.visibility= "visible";
		}
		</cfif>

		/* Dev Note: KAL; D27195: Display Variance on RFA */
		if (statusID != 2)
		{
			document.all.variance.style.visibility= "hidden";
		}
		else
		{
			document.all.variance.style.visibility= "visible";
		}
				
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
		//setSortImage(document.all.TD_BBI);
		event.cancelBubble = true;
	}
<!--- BJF D11948 Mass delete billbacks--->
	function DeleteAll(bChecked)
	{
		var childCheckboxes = ScoreCardList.document.all.selectedReasons;
		if(childCheckboxes != null){
			if (childCheckboxes.length)
			{
				for(var x=0; x<childCheckboxes.length;x++){
					box = childCheckboxes[x]
					box.checked = bChecked;
				}
			}
			else
			{
				childCheckboxes.checked = bChecked;
			}
			}
		}

	function ReleaseAll(bChecked)
		{
		var childCheckboxes = ScoreCardList.document.all.ApproveBB;
		if(childCheckboxes != null){
			if (childCheckboxes.length)
			{
				for(var x=0; x<childCheckboxes.length;x++){
					box = childCheckboxes[x]
					box.checked = bChecked;
				}
			}
			else
			{
				childCheckboxes.checked = bChecked;
			}
			}

		ScoreCardList.Change_To_Pay_1.style.display="";
		ScoreCardList.Change_To_Pay_2.style.display="none";

		if(bChecked == true)
		{
			ScoreCardList.document.all.Final_Signed_Paid.value = ScoreCardList.document.all.AllReleaseableBBs.value;
		}
		else
		{
			ScoreCardList.document.all.Final_Signed_Paid.value = '';
		}
		}
</SCRIPT>
	
	<!--- <CFSET Modi_Status_Width = 65> --->

	<TABLE CELLPADDING="2" CELLSPACING="0" border="0" WIDTH="#table_Width#" BGCOLOR="#fore_Color#" CLASS="Maintable">
		<TR VALIGN="bottom" ID="Table1" <cfif SECTION_TO_OPEN eq "4">style="display:none;"</cfif>>
			<TD CLASS="tableheaders" ID="header" width="#spacerwidth#">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" width="#SelectionWidth#" valign="top"><cfif CanDelete EQ 1><span id="DeleteAll"><input type="checkbox" name="DeleteBillbacks" onClick="DeleteAll(this.checked);"><cfelse>&nbsp; </cfif></TD>
			<TD CLASS="tableheaders" ID="header" WIDTH="#Status_Width#" ALIGN="center" nowrap STYLE="font-size:8pt;font-weight:bold" valign="top">STATUS</TD>
			<TD CLASS="tableheaders" ID="header" ALIGN="center" NOWRAP WIDTH="#UPPNF_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;&nbsp;&nbsp;<A OnClick="javaScript: setSortHref('BBCLOSURE');" HREF="##">TYPE</A><SPAN ID="SP_SP" <CFIF Default_Sort NEQ "BBCLOSURE"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD ID="TD_BBI" CLASS="tableheaders" NOWRAP WIDTH="#Number_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('BBI');" HREF="##">PAYABLE ##</a></B><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBI"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#BBD_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('BBD');" HREF="##">DATE</a><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBD"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Payee_And_Title_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('Pay');" HREF="##">PAYEE</a><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBD"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Date_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('BBSD');" HREF="##">START</a><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBSD"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Amount_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('BBA');" HREF="##">$ AMOUNT</a><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBA"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Analyst_And_Segment_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('BBANA');" HREF="##">ANALYST</a><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBANA"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>		
			<!--- "paid status" checkbox is on the results page. adding a cell for that. --->
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="15" valign="top">&nbsp;</TD>
		</TR>
		<TR ID="Table11" <cfif SECTION_TO_OPEN eq "4">style="display:none;"</cfif>>
			<TD CLASS="tableheaders" ID="header" width="#spacerwidth#">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" width="#SelectionWidth#">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" WIDTH="#Status_Width#" nowrap valign="top">&nbsp;</TD>
			<td CLASS="tableheaders" ID="header" ALIGN="center" WIDTH="#UPPNF_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;&nbsp;&nbsp;<A OnClick="javaScript: setSortHref('BBDEVIATED');" HREF="##"><CFIF application.returned_customer_setting.Customer_Keyword EQ "Mccain">VAR<CFELSE>DEV</CFIF></A><SPAN ID="SP_SP" <CFIF Default_Sort NEQ "BBDEVIATED"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></td>
			<TD CLASS="tableheaders" ID="header" NOWRAP WIDTH="#Number_Width#" valign="top">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#BBD_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('BBNUM');" HREF="##">BILLBACK ##</a><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBNUM"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Payee_And_Title_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('BBT');" HREF="##">TITLE</A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBT"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Date_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('BBED');" HREF="##">END</a><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBED"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Amount_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top"><span id="variance"><A OnClick="javaScript: setSortHref('BBV');" HREF="##">$ VARIANCE</a></span><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBV"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<cfif businessSegmentsOn>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Analyst_And_Segment_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('BBSE');" HREF="##">SEGMENT</a><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBSE"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<cfelse>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Analyst_And_Segment_Width#" valign="top">&nbsp;</TD>
			</cfif>
			<!--- "paid status" checkbox is on the results page. adding a cell for that. --->
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="15" valign="top">&nbsp;</TD>

		</TR>		
		<TR VALIGN="bottom"  ID="Table111" <cfif SECTION_TO_OPEN eq "4">style="display:none;"</cfif>>
			<TD CLASS="tableheaders" ID="header" width="#spacerwidth#">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" width="#SelectionWidth#">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" WIDTH="#Status_Width#" nowrap valign="top">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" ALIGN="center" NOWRAP WIDTH="#UPPNF_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			<TD ID="TD_BBI" CLASS="tableheaders" NOWRAP WIDTH="#Number_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" WIDTH="#BBD_Width#" STYLE="font-size:8pt;font-weight:bold; width=100px;" valign="top" NOWRAP><A OnClick="javaScript: setSortHref('BBREFN');" HREF="##">REFERENCE ##</a><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBREFN"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Payee_And_Title_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Date_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Amount_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			<cfif businessSegmentsOn>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Analyst_And_Segment_Width#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			<cfelse>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Analyst_And_Segment_Width#" valign="top">&nbsp;</TD>
			</cfif>
			<!--- "paid status" checkbox is on the results page. adding a cell for that. --->
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="15" valign="top">&nbsp;</TD>
		</TR>
		<TR VALIGN="bottom" ID="Table2" <cfif SECTION_TO_OPEN neq "4">style="display:none;"</cfif>>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="62" valign="top">Status</TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="62" valign="top"><A OnClick="javaScript: setSortHref('BBCLOSURE');" HREF="##">TYPE</A><SPAN ID="SP_SP" <CFIF Default_Sort NEQ "BBCLOSURE"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="TD_BBI" nowrap WIDTH="#Evaluate(PR_Number_Width - 10)#" STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('BBI');" HREF="##">PAYABLE ##</A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBI"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Evaluate(PR_BBD_Width + PR_BB_Width + 10)#" STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('BBD');" HREF="##">DATE</a><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBD"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Evaluate(PR_Title_Width + PR_Payee_Width - 5)#" STYLE="font-size:8pt;font-weight:bold" valign="top">PAYEE</TD>
			<cfif application.returned_customer_setting.Show_BB_Payment_GLCode>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Evaluate(PR_Status_Width - 15)#" STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('PR_STATUS');" HREF="##">&nbsp;STATUS</A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "PR_STATUS"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			</cfif>
			<cfif appSettings.getBBPaymentRequestHoldRelease() eq 1>
			<TD CLASS="tableheaders" ID="header" nowrap  WIDTH="#Evaluate(PR_Status_Width - 15)#" valign="top"><SPAN ID="SP_MassReleaseAll" title="Select all billbacks in 'Hold' status in all the pages for 'Release'">&nbsp;<input type="checkbox" id="chkAllHold" class="clCheckAll" value="5"  onClick="window.ScoreCardList.CheckAllReleased(this)" /></SPAN></TD>
			</cfif>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Evaluate(PR_Prepared_By - 20)#" STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('BBSD');" HREF="##">START</A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "PREP"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Evaluate(PR_Amount_Width + 20)#" STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('BBAMT');" HREF="##">&nbsp;$ AMOUNT</A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "APPR"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#PR_Approved_By#" STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('Analyst');" HREF="##">&nbsp;ANALYST</A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "Analyst"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<cfif Get_Profile_Settings.Mass_Billback_Pay IS 1 AND appSettings.Mass_Pay_Billback IS NOT 0 AND Get_Profile_Settings.BB_Approve>
			<TD CLASS="tableheaders" ID="header" nowrap  WIDTH="15" valign="top"><SPAN ID="SP_MassPayAll" title="Select all Billbacks on this page for update to Paid status">&nbsp;<input type="checkbox" id="chkAllPaid" class="clCheckAll" value="5" /></SPAN></TD>
			<cfelse>
				<input type="hidden" id="chkAllPaid" name="chkAllPaid" value="0" />
				<TD CLASS="tableheaders" ID="header" nowrap WIDTH="15" valign="top">&nbsp;</TD>
			</cfif>
		</TR>
		<TR  ID="Table22" <cfif SECTION_TO_OPEN neq "4">style="display:none;"</cfif>>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="62" valign="top">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="62" valign="top"><A OnClick="javaScript: setSortHref('BBDEVIATED');" HREF="##"><CFIF application.returned_customer_setting.Customer_Keyword EQ "Mccain">VAR<CFELSE>DEV</CFIF></strong></A><SPAN ID="SP_SP" <CFIF Default_Sort NEQ "BBDEVIATED"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Evaluate(PR_Number_Width - 10)#" valign="top">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Evaluate(PR_BBD_Width + PR_BB_Width + 10)#" STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('BBNUM');" HREF="##">BILLBACK ##</A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBNUM"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Evaluate(PR_Title_Width + PR_Payee_Width - 5)#" STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('BBT');" HREF="##">TITLE</A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBT"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<cfif application.returned_customer_setting.Show_BB_Payment_GLCode>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Evaluate(PR_Status_Width - 15)#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			</cfif>
			<cfif appSettings.getBBPaymentRequestHoldRelease() eq 1>
			<TD CLASS="tableheaders" ID="header" nowrap  WIDTH="#Evaluate(PR_Status_Width - 15)#" valign="top">&nbsp;</TD>
			</cfif>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Evaluate(PR_Prepared_By - 20)#" STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('BBED');" HREF="##">END</A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBED"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Evaluate(PR_Amount_Width + 20)#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			<cfif businessSegmentsOn>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#PR_Approved_By#" STYLE="font-size:8pt;font-weight:bold" valign="top"><A OnClick="javaScript: setSortHref('Segment');" HREF="##">&nbsp;SEGMENT</A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "Segment"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<cfelse>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#PR_Approved_By#" valign="top">&nbsp;</TD>
			</cfif>
			<!--- "paid status" checkbox is on the results page. adding a cell for that. --->
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="15" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
		</TR>
		<TR  ID="Table222" <cfif SECTION_TO_OPEN neq "4">style="display:none;"</cfif>>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="62" valign="top">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="62" valign="top">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Evaluate(PR_Number_Width - 10)#" valign="top">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Evaluate(PR_BBD_Width + PR_BB_Width + 10)#" STYLE="font-size:8pt;font-weight:bold; width=100px;" valign="top"><A OnClick="javaScript: setSortHref('BBREFN');" HREF="##">REFERENCE ##</A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BBREFN"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>			
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Evaluate(PR_Title_Width + PR_Payee_Width - 5)#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			<cfif application.returned_customer_setting.Show_BB_Payment_GLCode>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Evaluate(PR_Status_Width - 15)#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			</cfif>
			<cfif appSettings.getBBPaymentRequestHoldRelease() eq 1>
			<TD CLASS="tableheaders" ID="header" nowrap  WIDTH="#Evaluate(PR_Status_Width - 15)#" valign="top">&nbsp;</TD>
			</cfif>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Evaluate(PR_Prepared_By - 20)#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#Evaluate(PR_Amount_Width + 20)#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="#PR_Approved_By#" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
			<!--- "paid status" checkbox is on the results page. adding a cell for that. --->
			<TD CLASS="tableheaders" ID="header" nowrap WIDTH="15" STYLE="font-size:8pt;font-weight:bold" valign="top">&nbsp;</TD>
		</TR>
	</TABLE>
	<IFRAME NAME="ScoreCardList" id="ScoreCardList" SRC="#SCURL#" WIDTH="#Evaluate("#table_Width#+18")#" FRAMEBORDER="0" style="border: 0px none ##000000;"></IFRAME>
	</TD>
	</TR>
	</TABLE>
</CFOUTPUT>

<form action="masspaybillbacks.cfm" method="post" name="approvalForm" id="approvalForm">
	<input type="Hidden" name="massPayBillbackList" value="">
</form>
<form action="DeleteSelectedBillbacks.cfm" method="post" name="DeleteSelected" id="DeleteSelected">
	<input type="hidden" name="BillbacksToDelete" value="">
</form>

<script type="text/javascript">
/* set the height of the data set based on resolution */
document.getElementById('ScoreCardList').style.height = document.body.clientHeight - 180;
</script>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>