<cfheader name="Cache-Control" value="no-store">
<CFSET PAGE_TITLE=	"Scorecard">
<CFSET GROUP=		"Programs">

<CFPARAM name="form.businessSegmentsOn" default="0">
<cfparam name="variables.showPendingAccept" default="0" />

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

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFIF Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 0>
	<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
</CFIF>

<!--- unlock this users contracts --->
<cfstoredproc procedure="USP_Contract_Lock_Unlock" datasource="#application.datasource#">
	<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@User_ID" value="#request.AccessStructure.User_ID#">
	<cfprocparam type="In" cfsqltype="cf_sql_bit" dbVarName="@Unlock" value="1">
	<cfprocparam type="In" cfsqltype="cf_sql_bit" dbVarName="@Lock" value="0">
	<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Lock_Program_ID" value="0">
	<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Lock_Program_Number" value="">
	<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Unlock_Program_ID" value="0">
	<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Unlock_Program_Number" value="">
</cfstoredproc>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Scorecard Detail</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<cfinclude template="/common_files/jQuery.cfm">

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onLoad="">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!------
<BLOCKQUOTE>
----->

<style>
Table.maintable td.tableheaders
	{
		font-size:10px;
		font-weight:bold;
		border-bottom:thin #FFFFFF 0px; 
	}
</style>
<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="CENTER">
<TR>
<TD>
<TABLE WIDTH="920">
<TR>
<TD ALIGN="LEFT">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFSET helpfilenumber= 2>
	<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</TD>
<TD ALIGN="RIGHT">
<!---Gets application settings--->
<!--- <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() /> --->
<!--- <cfset appSettings = genSettingsManager.get()> --->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<cfset userManager = CreateObject("component", "components.user.UserManager") />
<!--- BSD: 11953 This only displays the Pending Accept tab if there is at lease one program
      with Proposal status on and Proposal Status Affects Program Status is on  --->
<cfset variables.getAllTemplateSettings = CreateObject("component", "components.programs.template.TemplateManager").init().getAll()/>
 <cfloop query="variables.getAllTemplateSettings">
  <cfif BidRequestStatusOn eq 1 and BidRequestStatusChangePgmStatus eq 1>
  	<cfset variables.showPendingAccept = 1 />
  </cfif>
 </cfloop>

<B>
		<FONT SIZE="1" COLOR="Red">[</FONT>
			<FONT SIZE="1" COLOR="Blue">
				<cfif appSettings.getFlexProgramSearch() EQ 1>
					<A HREF="/Scorecard/program_Search.cfm?type=html" TITLE="search for a program">Search program</A>
				<cfelseif (appSettings.getFlexProgramSearch() EQ 2) OR (appSettings.getFlexProgramSearch() EQ 3)>
					<A HREF="/flex/search/ProgramSearchFx.cfm" TITLE="Search Program">search program</A>
				<cfelseif (appSettings.getFlexProgramSearch() EQ 4) OR (appSettings.getFlexProgramSearch() EQ 5)>
					<A HREF="/programs/program_search.cfm" TITLE="Search Program">search program</A>
				</cfif>
			</FONT>
		<FONT SIZE="1" COLOR="Red">]</FONT>
		<cfif Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 1 AND (appSettings.getUserNumberRestrict() EQ 0 OR userManager.getUserNumberExists(request.AccessStructure.User_ID) EQ 1)>
		<FONT SIZE="1" COLOR="Red">[</FONT>
			<FONT SIZE="1" COLOR="Blue">
				
					<A HREF="/common_files/select_new_program_type.cfm" TITLE="Create New">
						create new
					</A>
				
			</FONT>
		<FONT SIZE="1" COLOR="Red">]</FONT>
		</cfif>
		
		<cfif Get_Profile_Settings.Mass_RFA_Program_Approve EQ 1>
		<FONT SIZE="1" COLOR="Red">[</FONT>
			<FONT SIZE="1" COLOR="Blue">
				
					<A style="cursor:pointer;" onClick="approveSelectedProgram()" title="Approve Selected Programs">
						approve selected programs
					</A>
				
			</FONT>
		<FONT SIZE="1" COLOR="Red">]</FONT>
		</cfif>
		<cfif variables.showPendingAccept eq 1>
		<FONT SIZE="1" COLOR="Red">[</FONT>
			<FONT SIZE="1" COLOR="Blue">
				
					<A style="cursor:pointer;" onClick="editSelectedProgramStatus()" title="Edit Status">
						edit status
					</A>
				
			</FONT>
		<FONT SIZE="1" COLOR="Red">]</FONT>
		
		</cfif>	
	<FONT SIZE="1" COLOR="##FF0000">[</FONT><font color="Blue" size="1"><b><A HREF="##" onClick="NewWindow(sc_URL + '&printresults=1','help','900','650','Yes', 'Yes');return false;" title="Print the Results">print the results</a></b></font><B><FONT SIZE="2" COLOR="##FF0000">]</FONT>
</B>
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
		font-size :			10px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:visited.tablink_back
	{
		color: 				Black;
		font-family:		Arial;
		font-size :			10px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			10px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:visited.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			10px; 
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

var globalcurrentProgramList = "";
function approveSelectedProgram() {
	if(globalcurrentProgramList.length > 0) {
	
		if(confirm("Press OK to approve the selected programs.")){
			document.all.massApprovalProgramList.value = globalcurrentProgramList;
			document.all.approvalForm.submit();
		}
	}
	else{
		alert("Please select at least one program Ready For Approval first.")
	}
	
	
}

var globalcurrentStatusList = "";
function editSelectedProgramStatus() {
	if(globalcurrentStatusList.length > 0) {
	
		if(confirm("Press OK to change the selected programs status.")){
			document.all.massEditStatusList.value = globalcurrentStatusList;
			document.all.editStatusForm.submit();
		}
	}
	else{
		alert("Please select at least one program to change the proposal status.")
	}
	
	
}

var globalcurrentClaimRatesReportProgramList = "";
function getClaimRatesReport() 
{
	if(globalcurrentClaimRatesReportProgramList.length > 0) 
	{
			NewWindow("about:blank", "claim_rates_report", "500", "300", "Yes", "No");
			document.all.claim_rates_report_program_id_list.value = globalcurrentClaimRatesReportProgramList;
			document.all.claimRatesReportForm.submit();
	}
	else
	{
		alert("Please select at least one program to report against.")
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
<cfparam name="URL.AGREE_ID" 	default="2">
<CFPARAM name="url.title" default = "">

<CFSET SCURL="scorecard3.cfm?SECTION_TO_OPEN=#URL.SECTION_TO_OPEN#&AGREE_ID=#URL.AGREE_ID#&SHEXP=#URL.SHEXP#">

<CFSET Status_List = "Work In Progress">

<cfif Get_Profile_Settings.RFA_Agreed EQ 1 or Get_Profile_Settings.RFA_Agreed EQ 2>
	<CFSET Status_List = ListAppend(Status_List, "Under Review", ",")>
	<CFSET Status_List = ListAppend(Status_List, "Pending App.", ",")>
<cfelse>
	<CFSET Status_List = ListAppend(Status_List, "Request For App.", ",")>
	<CFSET Status_List = ListAppend(Status_List, " ", ",")>
</cfif>
<CFSET Status_List = ListAppend(Status_List, "Pre Active,Active,Expiring,Expired,Lost", ",")>

<cfif Get_Profile_Settings.Read_Only_Catalog_Access EQ 1>
	<CFSET Status_List = ListAppend(Status_List, "Catalog", ",")>
</cfif>

<!------ getStatus ----->
<cfquery name="qGetStatus" datasource="#application.datasource#">
	SELECT	Contract_Status_Types.Contract_Status_Type_ID,Contract_Status_Order,
			<cfif Get_Profile_Settings.RFA_Agreed EQ 1 or Get_Profile_Settings.RFA_Agreed EQ 2>
			CASE 
			WHEN Contract_Status_Types.Contract_Status_Type_ID = 2 THEN Program_Agree_Status.Program_Agree_Status_Desc
			ELSE Contract_Status_Types.Contract_Status_Type_Desc
			END Contract_Status_Type_Desc,
			<cfelse>
			Contract_Status_Types.Contract_Status_Type_Desc,
			</cfif>
			ISNULL(Program_Agree_Status_ID, 0) Program_Agree_Status_ID
	FROM	Contract_Status_Types
			LEFT JOIN Program_Agree_Status
			ON  1=2
			<cfif Get_Profile_Settings.RFA_Agreed EQ 1 OR Get_Profile_Settings.RFA_Agreed EQ 2>
			OR	Contract_Status_Types.Contract_Status_Type_ID = 2
			</cfif>
	WHERE	Contract_Status_Types.Contract_Status_Type_ID <> 3
	<!--- BSD: 11953 This only displays the Pending Accept tab if there is at lease one program
      with Proposal status on and Proposal Status Affects Program Status is on --->
	<cfif variables.showPendingAccept eq 0>
	AND     Contract_Status_Types.Contract_Status_Type_ID <> 10
	</cfif>
	
	<cfif appSettings.getPgmPostApprovalStatus() EQ 1>
	<cfset ProgramPostApprovalStatusManager = CreateObject("component", "components.programs.ProgramPostApprovalStatusManager").init() />
	<cfset arProgramPostApprovalStatusAccessForUserProfile = ProgramPostApprovalStatusManager.getSelectedProfileProgramPostApprovalStatusArray(request.AccessStructure.Profiles_ID) />
	<cfset  arLen = ArrayLen(arProgramPostApprovalStatusAccessForUserProfile) />
	UNION
	SELECT	#ProgramPostApprovalStatusManager.getFakeStatusIdForProgramPostApprovalStatus()# AS Contract_Status_Type_ID,  
					10 As Contract_Status_Order,
					Program_Post_Approval_Status.Program_Post_Approval_Status_Desc As Contract_Status_Type_Desc,
					Program_Post_Approval_Status.Program_Post_Approval_Status_ID Program_Agree_Status_ID
	FROM	Program_Post_Approval_Status			
	WHERE	Program_Post_Approval_Status.Deleted = 0
	<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getPgmPostApprovalStatusType() EQ 1><!------ ignore id=2 if appsettings value=1 ----->
	AND		Program_Post_Approval_Status.Program_Post_Approval_Status_ID <> 2
	</cfif>
	</cfif>
	
	ORDER BY Contract_Status_Order, Contract_Status_Type_ID, Program_Agree_Status_ID
</cfquery>

<cfif Get_Profile_Settings.Read_Only_Catalog_Access EQ 1>
	<cfset QueryAddRow(qGetStatus) />
	<cfset QuerySetCell(qGetStatus, "Contract_Status_Type_ID", 9) />
	<cfset QuerySetCell(qGetStatus, "Contract_Status_Type_Desc", "Catalog") />
	<cfset QuerySetCell(qGetStatus, "Program_Agree_Status_ID", 0) />
</cfif>

<CFOUTPUT>
<CFSET i=1>

<CFINCLUDE TEMPLATE="Tables_Measures.cfm">

<BR>
<TABLE border="0" width="#table_Width#" cellspacing="0" cellpadding="1" ID="Table_Status">
	<TR>
	 <TD CLASS="headerblank">&nbsp;</TD>
<!------ 
<CFLOOP LIST="#Status_List#" INDEX="thisIndex">
	<CFIF Len(Trim(thisIndex)) GT 0>
		<A ID="#i#" OnClick="javaScript: setStatusHref();" CLASS="tablink_back" HREF="scorecard3.cfm?a=#createuuid()#&SECTION_TO_OPEN=#i#&AGREE_ID=#URL.AGREE_ID#<CFIF i EQ 7>&SHEXP=true</CFIF>">
		<TD nowrap WIDTH="92" 
		<CFIF URL.SECTION_TO_OPEN EQ i>
			CLASS="headerselected" 		
		<CFELSE>
			CLASS="headernotselected" 
		</CFIF>
		 ALIGN="center" NOWRAP ID="statusTab">
		<B>			
		<A ID="#i#" OnClick="javaScript: setStatusHref();" CLASS="tablink_back" HREF="scorecard3.cfm?a=#createuuid()#&SECTION_TO_OPEN=#i#<CFIF i EQ 7>&SHEXP=true</CFIF>">
		<nobr>#LCase(thisIndex)#</nobr></A></B></TD></A>
		<CFIF (i-1) LT Len(Status_List)>
		<TD CLASS="headerspacer"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
		</CFIF>
	</CFIF>
<CFSET i=i+1>
</CFLOOP> 
----->
	<cfloop query="qGetStatus">
		<A ID="#i#" OnClick="javaScript: setStatusHref();" CLASS="tablink_back" HREF="scorecard3.cfm?a=#createuuid()#&SECTION_TO_OPEN=#Contract_Status_Type_ID#&AGREE_ID=#Program_Agree_Status_ID#<CFIF Contract_Status_Type_ID EQ 7>&SHEXP=true</CFIF>">
		<TD nowrap width="72" ALIGN="center" ID="statusTab"
			<CFIF URL.SECTION_TO_OPEN EQ Contract_Status_Type_ID AND (Contract_Status_Type_ID NEQ 2 OR Program_Agree_Status_ID EQ URL.AGREE_ID)>
				CLASS="headerselected" 		
			<CFELSE>
				CLASS="headernotselected" 
			</CFIF>
		>
		<B>			
		<A ID="#Contract_Status_Type_ID#" OnClick="javaScript: setStatusHref();" CLASS="tablink_back" HREF="scorecard3.cfm?a=#createuuid()#&SECTION_TO_OPEN=#Contract_Status_Type_ID#&AGREE_ID=#Program_Agree_Status_ID#<CFIF Contract_Status_Type_ID EQ 7>&SHEXP=true</CFIF>" title="Click to view #LCase(Contract_Status_Type_Desc)# programs">
		<nobr>#LCase(Contract_Status_Type_Desc)#</nobr></A></B></TD></A>
		<CFIF (Contract_Status_Type_ID-1) LT qGetStatus.recordCount or Contract_Status_Type_ID eq 10>
		<TD CLASS="headerspacer"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
		</CFIF>
	</cfloop>
<TD CLASS="headerspacer" WIDTH="100%"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
<!------
<TD WIDTH="90%" CLASS="remaining">&nbsp;</TD>
----->
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
	var title;
	
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
		//alert(document.MyForm.title.value);
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
		
		if(window.ScoreCardList.MyForm)
		{
			if(window.ScoreCardList.MyForm.title.value)
			{
			title = window.ScoreCardList.MyForm.title.value;
			aObj.href	= sc_URL + "&SORTBY=" + sortVal + "&title=" + title;
			}
			else
			{
			aObj.href	= sc_URL + "&SORTBY=" + sortVal;
			}
		}
		else
		{
			return false;
		}
		
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
		return false;
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
		if(aObj.id)
		{
			if(aObj.id <= 1)
			{
				document.all.TD_Approved.style.visibility = "hidden";
				<cfif appSettings.get_Requester_Approver()>
				document.all.TD_Approver.style.visibility = "hidden";
				</cfif>
				<cfif appSettings.get_Requester_Approver_Position()>
				document.all.TD_Approver_Position.style.visibility = "hidden";
				</cfif>
			}
			else
			{
				document.all.TD_Approved.style.visibility = "visible";
				<cfif appSettings.get_Requester_Approver()>
				document.all.TD_Approver.style.visibility = "visible";
				</cfif>
				<cfif appSettings.get_Requester_Approver_Position()>
				document.all.TD_Approver_Position.style.visibility = "visible";
				</cfif>
			}
		}
		setSortImage(document.all.TD_CN);	
		event.cancelBubble = true;
	}
	
</SCRIPT>




	<TABLE CELLPADDING="2" CELLSPACING="0" border="0" WIDTH="#table_Width#" BGCOLOR="#fore_Color#" CLASS="Maintable">
		<TR align="left">
			<TD width="#Status_Width#" CLASS="tableheaders" valign="top"><B>STATUS</B></TD>
			<TD width="#Number_Width#" CLASS="tableheaders" ID="TD_CN" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('CN');"><B>PROGRAM</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "CN"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD width="#Type_Width#" CLASS="tableheaders" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('PT');"><B>TYPE</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "PT"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD width="#Title_Width#" CLASS="tableheaders" valign="top">
			<TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="0" CLASS="Maintable"  valign="top" BORDER="0">
			<TR>
				<TD STYLE="border:none;" CLASS="tableheaders" WIDTH="29%" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('CT');"><B>TITLE</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "CT"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>				
					<cfif appSettings.getProgramScoreCard() NEQ 0><cfset CellAlign="center"><cfelse><cfset CellAlign="left"></cfif>							
				<cfif appSettings.get_Requester_Approver_Position() eq 1 OR appSettings.get_Requester_Approver() eq 1>
				<cfset CellID = "TD_Approved">
				<cfelse>
				<cfset CellID = "TD_Approver">
				</cfif>
				<TD valign="top"<CFIF URL.SECTION_TO_OPEN LTE 1> STYLE="visibility:hidden"</CFIF> ID="#CellID#" STYLE="border-bottom:thin ##FFFFFF 0px;" CLASS="tableheaders" ALIGN="#CellAlign#"><cfif appSettings.get_Requester_Approver_Position() OR appSettings.get_Requester_Approver()><A HREF="##" OnClick="javaScript: setSortHref('AD');"><B>REQUEST/APPROVED DATE</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "AD"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN><cfelse>&nbsp;</cfif></TD>
			</TR>
			</TABLE>
			</TD>
				<!--- Dev Note: Milan; D6320. Show  neither "operator" nor "distributor" on the scorecard --->
			<CFIF appSettings.getProgramScoreCard() NEQ 0>
			<TD width="#Operator_Width#" CLASS="tableheaders" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('CO');"><B><cfoutput>#UCASE(application.returned_customer_setting.operator_label_singular)#</cfoutput></B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "CO"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			</CFIF>
			<TD width="#Evaluate(SD_Width+ED_Width)#" CLASS="tableheaders">
			<TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="0" BORDER="0">
			<TR>
			<TD <!---width="#SD_Width#"---> CLASS="tableheaders" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('SD');"><B>START</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "SD"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD <!---width="#ED_Width#"---> CLASS="tableheaders" valign="top">&nbsp;</TD>
			</TR>
			</TABLE>
			</TD>
			<TD width="#Quantity_Width#" CLASS="tableheaders" valign="top"><B>QUANTITY</B></TD>
			<cfif form.businessSegmentsOn eq 1>
				<TD width="#BusSeg_Width#" CLASS="tableheaders" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('BUS_SEG');"><B>SEGMENT</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "BUS_SEG"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			</cfif>
			<cfif appSettings.getpaymenthistoryon()><TD width="#SCISSOR_Width#" CLASS="tableheaders">&nbsp;</TD></cfif>
			<TD width="#SCISSOR_Width#" CLASS="tableheaders">&nbsp;</TD>
		</TR>
		
		<TR align="left">
			<TD width="#Status_Width#" CLASS="tableheaders" valign="top">&nbsp;</TD>
			<TD width="#Number_Width#" CLASS="tableheaders" valign="top">&nbsp;</TD>
			<TD width="#Type_Width#" CLASS="tableheaders" valign="top"><cfif application.returned_customer_setting.Accounting_Specialist eq 1><A HREF="##" OnClick="javaScript: setSortHref('PP');"><B>PAYMENT PROCESSOR</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "PP"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN><cfelse>&nbsp;</cfif></TD>
			<TD width="#Title_Width#" CLASS="tableheaders" valign="top">
			<TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="0" CLASS="Maintable"  valign="top" border="0">
			<TR>
				<cfif appSettings.get_Requester_Approver()><TD STYLE="border:none;" CLASS="tableheaders" WIDTH="31%" valign="top">&nbsp;</TD></cfif>
				<cfif appSettings.getProgramScoreCard() NEQ 0 AND appSettings.get_Requester_Approver()><cfset CellAlign="center"><cfelse><cfset CellAlign="left"></cfif>
				<cfif appSettings.get_Requester_Approver_Position() eq 1 OR appSettings.get_Requester_Approver() eq 1>
				<cfset CellID = "TD_Approver">
				<cfelse>
				<cfset CellID = "TD_Approved">
				</cfif>
				<TD valign="top" <CFIF URL.SECTION_TO_OPEN LTE 1> STYLE="visibility:hidden"</CFIF> ID="#CellID#" STYLE="border-bottom:thin ##FFFFFF 0px;" CLASS="tableheaders" ALIGN="#CellAlign#"><cfif appSettings.get_Requester_Approver_Position() eq 0 AND appSettings.get_Requester_Approver() eq 0><A HREF="##" OnClick="javaScript: setSortHref('AD');"><B>REQUEST/APPROVED DATE</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "AD"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN><cfelseif appSettings.get_Requester_Approver()><A HREF="##" OnClick="javaScript: setSortHref('RA');"><B>REQUESTER/APPROVER</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "RA"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN><cfelse>&nbsp;</cfif></TD>				
			</TR>
			</TABLE>
			</TD>


			<!--- Dev Note: Milan; D6320. Show only "operator" on the scorecard --->
			<cfif appSettings.getProgramScoreCard() EQ 1>
			<TD width="#Operator_Width#" CLASS="tableheaders" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('OP');">#UCASE(application.returned_customer_setting.operator_label_singular)# ##</A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "OP"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			</cfif>
			<!--- Dev Note: Milan; D6320. Show  "operator" and "distributor" on the scorecard --->
			<cfif appSettings.getProgramScoreCard() EQ 2>
			<TD width="#Operator_Width#" CLASS="tableheaders" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('DI');">#UCASE(application.returned_customer_setting.distributor_label_singular)#</A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "DI"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			</cfif>
			<TD width="#Evaluate(SD_Width+ED_Width)#" CLASS="tableheaders">
			<TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="0">
			<TR>
			<TD width="#SD_Width#" CLASS="tableheaders" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('ED');"><B>END</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "ED"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
			<TD width="#ED_Width#" CLASS="tableheaders" valign="top">&nbsp;</TD>
			</TR>
			</TABLE>
			</TD>
			<TD width="#Quantity_Width#" CLASS="tableheaders" valign="top"><B>AMOUNT</B></TD>
			<cfif form.businessSegmentsOn eq 1>
				<TD width="#BusSeg_Width#" CLASS="tableheaders" valign="top">&nbsp;</TD>
			</cfif>
			<cfif appSettings.getpaymenthistoryon()><TD width="#SCISSOR_Width#" CLASS="tableheaders">&nbsp;</TD></cfif>
			<TD width="#SCISSOR_Width#" CLASS="tableheaders">&nbsp;</TD>
		</TR>
		<cfif appSettings.get_Requester_Approver_Position()>
		<tr>
			<TD width="#SCISSOR_Width#" CLASS="tableheaders">&nbsp;</TD>
			<TD width="#SCISSOR_Width#" CLASS="tableheaders">&nbsp;</TD>
			<TD width="#Type_Width#" CLASS="tableheaders">&nbsp;</TD>
			<TD width="#Title_Width#" CLASS="tableheaders">
				
					<TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="0" CLASS="Maintable" BORDER="0">
						<TR>
								<TD STYLE="border:none;" CLASS="tableheaders" WIDTH="23%">&nbsp;</TD>			
								<cfif appSettings.getProgramScoreCard() NEQ 0><cfset CellAlign="center"><cfelse><cfset CellAlign="left"></cfif>
								<TD valign="top"<CFIF URL.SECTION_TO_OPEN LTE 1> STYLE="visibility:hidden"</CFIF> ID="TD_Approver_Position" STYLE="border-bottom:thin ##FFFFFF 0px;" CLASS="tableheaders" ALIGN="#CellAlign#"><A HREF="##" OnClick="javaScript: setSortHref('AP');"><B>REQUESTER/APPROVER POSITION</B></A><SPAN ID="SP_SP"<CFIF Default_Sort NEQ "AP"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\#Current_Image#"></SPAN></TD>
						</TR>
					</TABLE>
				
			</TD>
		</tr>
		</cfif>
		
	</TABLE>

	<IFRAME NAME="ScoreCardList" id="ScoreCardList" SRC="#SCURL#&a=#createuuid()#" WIDTH="#Evaluate("#table_Width#+18")#" HEIGHT="425" FRAMEBORDER="0" style="border: 0px none ##000000;"></IFRAME>
	</TD>
	</TR>
	</TABLE>
</CFOUTPUT>	
<!------
</BLOCKQUOTE>
----->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<form action="massapproval.cfm" method="post" name="approvalForm" id="approvalForm">
	<input type="Hidden" name="massApprovalProgramList" value="">
</form>

<!--- BSD: Added for Mass Update on Proposal Status --->
<form action="masseditstatus.cfm" method="post" name="editStatusForm" id="editStatusForm">
	<input type="Hidden" name="massEditStatusList" value="" />
	
</form>
<form action="/reportwriter/program_claim_rates_report.cfm" method="post" name="claimRatesReportForm" id="claimRatesReportForm" target="claim_rates_report">
	<input type="Hidden" name="claim_rates_report_program_id_list" value="">
</form>

</BODY>
</HTML>



