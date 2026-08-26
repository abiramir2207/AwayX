<cfheader name="Cache-Control" value="no-store">
<CFSET PAGE_TITLE=	"Scorecard">
<CFSET GROUP=		"Programs">

<CFPARAM name="form.businessSegmentsOn" default="0">


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


<CFIF request.Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 0>
	<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
</CFIF>

<!--- unlock this users contracts --->
<cfquery name="unlockTheirPrograms" datasource="#application.datasource#">
	UPDATE Contract_Main
	Set Contract_Is_Locked = 0
	WHERE Contract_Locked_By_User_ID = '#request.AccessStructure.User_ID#' and DELETED = 0 and Flagged_As_Purged = 0
</cfquery>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Scorecard Detail</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<script language="JavaScript">
    function openNewWindow(URLtoOpen, windowName, windowFeatures) {
        newWindow=window.open(URLtoOpen, windowName.replace(/\s/g, ''), windowFeatures);
    }
</script>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onLoad="">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!------
<BLOCKQUOTE>
----->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<cfset userManager = CreateObject("component", "components.user.UserManager") />


<CFSET fore_Color="FFE083">

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

var globalCurrentProgramList = "";
function approveSelectedProgram() {
	if(globalCurrentProgramList.length > 0) {

		if(confirm("Press OK to approve the selected programs.")){
			document.all.massApprovalProgramList.value = globalCurrentProgramList;
			document.all.approvalForm.submit();
		}
	}
	else{
		alert("Please select at least one program Ready For Approval first.")
	}


}

</SCRIPT>

<!---  Used to keep the users last search in memory
	- Param the session -> Param the URL to eq the session...If URL exixts, it will override session
	- then set the session to the Current URL so it will persist		MWS perf scorecard--->
<CFPARAM NAME="Session.SECTION_TO_OPEN" DEFAULT="1">
<CFPARAM NAME="Session.AGREE_ID" 		DEFAULT="2">
<CFPARAM NAME="Session.SHEXP" 			DEFAULT="">


<CFPARAM NAME="URL.SECTION_TO_OPEN" DEFAULT="#Session.SECTION_TO_OPEN#">
<CFPARAM NAME="URL.AGREE_ID" 		DEFAULT="#Session.AGREE_ID#">
<CFPARAM NAME="URL.SHEXP" 			DEFAULT="#Session.SHEXP#">

<CFSET Session.SECTION_TO_OPEN	=	URL.SECTION_TO_OPEN>
<CFSET Session.AGREE_ID 		=	URL.AGREE_ID>
<CFSET Session.SHEXP 			=	URL.SHEXP>

<!--- END This holds the users last request in session memory--->

<CFSET SCURL="scorecard3.cfm?SECTION_TO_OPEN=#URL.SECTION_TO_OPEN#&AGREE_ID=#URL.AGREE_ID#&SHEXP=#URL.SHEXP#">

<CFSET Status_List = "Work In Progress">

<cfif request.Get_Profile_Settings.RFA_Agreed EQ 1 or request.Get_Profile_Settings.RFA_Agreed EQ 2>
	<CFSET Status_List = ListAppend(Status_List, "Under Review", ",")>
	<CFSET Status_List = ListAppend(Status_List, "Pending App.", ",")>
<cfelse>
	<CFSET Status_List = ListAppend(Status_List, "Request For App.", ",")>
	<CFSET Status_List = ListAppend(Status_List, " ", ",")>
</cfif>
<CFSET Status_List = ListAppend(Status_List, "Pre Active,Active,Expiring,Expired,Lost", ",")>

<cfif request.Get_Profile_Settings.Read_Only_Catalog_Access EQ 1>
	<CFSET Status_List = ListAppend(Status_List, "Catalog", ",")>
</cfif>

<CFINCLUDE TEMPLATE="Tables_Measures.cfm">


<CFINCLUDE TEMPLATE="unlock_programs.cfm">
	<!---<CFSET qPrograms=get_This_Status_Programs>--->
<CFINCLUDE TEMPLATE="display_Program_List_Flsh.cfm">

<!------
</BLOCKQUOTE>
----->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<form action="massapproval.cfm" method="post" name="approvalForm" id="approvalForm">
	<input type="Hidden" name="massApprovalProgramList" value="">
</form>
</BODY>
</HTML>



