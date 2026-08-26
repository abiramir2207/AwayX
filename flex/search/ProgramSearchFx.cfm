<CFSET PAGE_TITLE=	"Program Search">
<CFSET GROUP=		"Programs">

<cfif NOT IsDefined("URL.FormName")>
	<CFINCLUDE TEMPLATE="/includes/header.cfm">
</cfif>
<!--- First pass the complete path to the function, which will give us a dynamic url based on file modified date. Then we can strip of the path and the file extension.
This will give us a unique url whenever the file gets modified and this will prevent caching.
--->
<cfset swf_file_Name =  ReplaceNoCase(ReplaceNoCase(application.util.io.fileSource('/flex/search/SearchProgramMain.swf'),'.swf',''),'/flex/search/','')>


<cfif IsDefined("URL.FormName")>
	<cfif URL.FormName neq "reassign_program" and URL.FormName neq "frmModifyPreactivePrograms">
		<!--- Do not include the header when accessing program search from "Reassign Program" or "Modify Preactive program StartDates" 
			as program search is that case becomes a popup page.
		--->
		<CFINCLUDE TEMPLATE="/includes/header.cfm">
	</cfif>
</cfif>

<!-- saved from url=(0014)about:internet -->
<html lang="en">

<!-- 
Smart developers always View Source. 

This application was built using Adobe Flex, an open source framework
for building rich Internet applications that get delivered via the
Flash Player or to desktops via Adobe AIR. 

Learn more about Flex at http://flex.org 
// -->

<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<!--  BEGIN Browser History required section -->
<link rel="stylesheet" type="text/css" href="/flex/history/history.css" />
<!--  END Browser History required section -->

<title></title>
<script src="/flex/AC_OETags.js" language="javascript"></script>

<cfoutput>
<script>
function RedirectToSessionExpiredPage()
{
	window.location.href = '/session_expired.cfm?id=#request.accessStructure.User_ID#&FromFlex=1';
}

var openedWindows = [];
/* Since multiple program windows can now be open, once a user edits a program, we need to make sure that no more than
one program can be editable at a time. "addWindowToList" adds the program to an array to keep track of programs in edit status.
*/
function addWindowToList(child_window)
{
	openedWindows.push(child_window);
}
/* Since multiple program windows can now be open, once a user edits a program, we need to make sure that no more than
one program can be editable at a time. "removeWindowFromList" removes the program from an array to keep track of programs in edit status.
*/
function removeWindowFromList(child_window)
{
	for(i=0;i<openedWindows.length;i++){
		if (openedWindows[i] == child_window){
			openedWindows.splice(i,1);
		}
	}
}

function showReport(data)
{
/* Cannot pass values through a URL, because we need to pass a huge number programs as a comma-delimited list. URL has a max size restriction. */
//window.open("/ReportWriter/program_claim_rates_report.cfm?REPORT_PROGRAM_ID_LIST="+data.REPORT_PROGRAM_ID_LIST+"&REPORT_TYPE="+data.REPORT_TYPE+"&FromFlex=1","win","height=600,width=900,toolbar=no,scrollbars=yes,resizable=yes");
/* Open a popup with a blank URL. */
window.open("","claimrates","height=600,width=900,toolbar=no,scrollbars=yes,resizable=yes");
window.frmReport.Report_Program_ID_List.value = data.Report_Program_ID_List;
window.frmReport.Report_Type.value = data.Report_Type;
/*Set the target of the blank window to be the form name. This way on form submission,we can submit the form data to the pop-up page. */
window.frmReport.target="claimrates";
window.frmReport.submit();
}

function showReleaseSettlement(data)
{
/* Cannot pass values through a URL, because we may need to pass a huge number programs as a comma-delimited list. URL has a max size restriction. */
/* Open a popup with a blank URL. */
window.open("","releaseSettlement","height=150,width=380,toolbar=no,scrollbars=yes,resizable=yes");

window.frmReleaseSettlement.ListContractMainID.value = data.ListContractMainID;

/*Set the target of the blank window to be the form name. This way on form submission,we can submit the form data to the pop-up page. */
window.frmReleaseSettlement.target="releaseSettlement";
window.frmReleaseSettlement.submit();
}

function editSelectedProgramStatus(data)
{
/* Cannot pass values through a URL, because we need to pass a huge number programs as a comma-delimited list. URL has a max size restriction. */
/* Open a popup with a blank URL. */
window.open("","masseditstatus","height=600,width=900,toolbar=no,scrollbars=yes,resizable=yes");
window.editStatusForm.massEditStatusList.value = data.massEditStatusList;
/*Set the target of the blank window to be the form name. This way on form submission,we can submit the form data to the pop-up page. */
window.editStatusForm.target="masseditstatus";
window.editStatusForm.submit();
}
</script>
<!--- 
This form is used to send list of programs from flex to CF as a form variable. 
Note: showReport() function (above) gets called while generating reports from flex.
This function then takes the data from flex and uses the form below to send data to the pop-up page.
--->
<form name="frmReport" action="/ReportWriter/program_claim_rates_report.cfm" method="post">
  <input type="hidden" name="Report_Program_ID_List">
  <input type="hidden" name="Report_Type">
  <input type="hidden" name="FromFlex" value="1">
</form>

<form name="frmReleaseSettlement" action="/common_files/contracts/release_settlement.cfm" method="post">
  <input type="hidden" name="ListContractMainID">
   <input type="hidden" name="FromFlex" value="1">
</form>

<form action="/Scorecard/masseditstatus.cfm" method="post" name="editStatusForm" id="editStatusForm">
	<input type="Hidden" name="massEditStatusList" value="" />
	<input type="Hidden" name="FromFlex" value="1" />
</form>
</cfoutput>

<!--  BEGIN Browser History required section -->
<script src="/flex/history/history.js" language="javascript"></script>
<!--  END Browser History required section -->

<style>
body { margin: 0px; overflow:hidden }
</style>
<script language="JavaScript" type="text/javascript">
<!--
// -----------------------------------------------------------------------------
// Globals
// Major version of Flash required
var requiredMajorVersion = 10;
// Minor version of Flash required
var requiredMinorVersion = 0;
// Minor version of Flash required
var requiredRevision = 0;
// -----------------------------------------------------------------------------
// -->
</script>
</head>


<body scroll="no">
	
	<!--- Dinesh Rachala for LABEL  D26667   START --->
	<CFPARAM NAME="URL.FormName"                DEFAULT="reassign_program">
	<CFPARAM NAME="URL.ReturnFieldName"				Default="Contract_Main_ID">
	<CFPARAM NAME="URL.AllowImportAll"				Default="0">
	<CFPARAM NAME="URL.Display_Deleted_Programs" 	default="0">
	<CFPARAM NAME="URL.Fieldname"					Default="Contract_Number">
	<CFPARAM NAME="URL.importlist_type"				Default="">
	<CFPARAM NAME="URL.display_type"				Default="0">
	
	
	
	<CFPARAM NAME="URL.Creating_User_Position"    Default="0">
	<CFPARAM NAME="URL.Include_work_in_progress_below_me"  Default="0">
	
	
	<!--- Dinesh Rachala for LABEL  D26667   END --->
	
	
	
<cfparam name="request.accessStructure.User_ID" type="string" default="">
<cfparam name="status" type="string" default="">
<cfparam name="reload" type="string" default="">


<cfset cacheSpan = APPLICATION.masterDataCacheSpan>


<cfscript>
	flashVarsString = 	"userID=" & request.accessStructure.User_ID &
						"&status=" & status & 
						"&reload=" & reload &
						"&importlist_type=" & importlist_type &
						"&Creating_User_Position=" & Creating_User_Position &
						"&Include_work_in_progress_below_me=" & Include_work_in_progress_below_me;
</cfscript>
<!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   CALL THE SWF (Flash Player version check -> then call)	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
<script language="JavaScript" type="text/javascript">

// Version check for the Flash Player that has the ability to start Player Product Install (6.0r65)
var hasProductInstall = DetectFlashVer(6, 0, 65);

// Version check based upon the values defined in globals
var hasRequestedVersion = DetectFlashVer(requiredMajorVersion, requiredMinorVersion, requiredRevision);

if ( hasProductInstall && !hasRequestedVersion ) {
	// DO NOT MODIFY THE FOLLOWING FOUR LINES
	// Location visited after installation is complete if installation is required
	var MMPlayerType = (isIE == true) ? "ActiveX" : "PlugIn";
	var MMredirectURL = window.location;
    document.title = document.title.slice(0, 47) + " - Flash Player Installation";
    var MMdoctitle = document.title;

/*
	AC_FL_RunContent(
		"src", "playerProductInstall",
		"FlashVars", "MMredirectURL="+MMredirectURL+'&MMplayerType='+MMPlayerType+'&MMdoctitle='+MMdoctitle+"",
		"width", "100%",
		"height", "100%",
		"align", "middle",
		"id", "SearchProgramMain",
		"quality", "high",
		"bgcolor", "#869ca7",
		"name", "SearchProgramMain",
		"allowScriptAccess","sameDomain",
		"type", "application/x-shockwave-flash",
		"pluginspage", "http://www.adobe.com/go/getflashplayer"
	);
*/
	/* It seems like "playerProductInstall.swf" was not being fired for older flash players. I am sending all the users
		 to the download flash site without calling any flash file "playerProductInstall.swf".
	*/
	 var alternateContent ='This content requires the latest version of the Adobe Flash Player. '
   	+ '<a href=http://www.adobe.com/go/getflash/ target=_blank>Get Flash</a>';
    document.write(alternateContent);  // insert non-flash content*/



} else if (hasRequestedVersion) {
	// if we've detected an acceptable version
	// embed the Flash Content SWF when all tests are passed
	AC_FL_RunContent(
			"src", <cfoutput>#swf_file_Name#</cfoutput>,
			"FlashVars", "<cfoutput>#flashVarsString#</cfoutput>",
			"width", "100%",
			"height", "100%",
			"align", "middle",
			"id", "SearchProgramMain",
			"quality", "high",
			"bgcolor", "#869ca7",
			"name", "SearchProgramMain",
			"allowScriptAccess","sameDomain",
			"type", "application/x-shockwave-flash",
			"pluginspage", "http://www.adobe.com/go/getflashplayer"
	);
  } else {  // flash is too old or we can't detect the plugin
    var alternateContent = 'This content requires the Adobe Flash Player. '
   	+ '<a href=http://www.adobe.com/go/getflash/ target=_blank>Get Flash</a>';
    document.write(alternateContent);  // insert non-flash content
  }
// 
</script>




<noscript>
  	<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
			id="SearchProgramMain" width="100%" height="100%"
			codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
			<param name="movie" value="SearchProgramMain.swf" />
			<param name="quality" value="high" />
			<param name="bgcolor" value="#869ca7" />
			<param name="allowScriptAccess" value="sameDomain" />
			<embed src="/Flex/search/SearchProgramMain.swf?label=85600" quality="high" bgcolor="#869ca7"
				width="100%" height="100%" name="SearchProgramMain" align="middle"
				flashVars="<cfoutput>#flashVarsString#</cfoutput>"
				play="true"
				loop="false"
				quality="high"
				allowScriptAccess="sameDomain"
				type="application/x-shockwave-flash"
				pluginspage="http://www.adobe.com/go/getflashplayer">
			</embed>
	</object>
</noscript>
<!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX END  CALL THE SWF END	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

<!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   Handle for Importing Items	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
<SCRIPT LANGUAGE="JavaScript">
  function finishedSearching(arrItems) {
        // Get value of fname and lname properties.
        var s = "";
        // Iterate over embedded object's properties.
        for (i=0; i<arrItems.length; i++) {
        	
        	if(i < arrItems.length) //include the comma
        		
        		{s +=  arrItems[i] + ",";}
            else
            	{s +=  arrItems[i];}
            	}
        //     alert("itemlist: \n" + s);
        sendItems(s);
        
    }
    function sendItems(s){
   			<CFOUTPUT>

			//opener.document.all.finishedselectingitems.value = 1;
			opener.document.all.#URL.Formname#.#URL.Fieldname#.value = s;
			
			if(opener.document.all.#URL.Formname#.display_type)
			{
				opener.document.all.#URL.Formname#.display_type.value = #URL.display_type#;
			}
			opener.document.all.#URL.Formname#.#URL.Fieldname#.value = s;

			//opener.document.all.#URL.Formname#.#URL.ReturnFieldname#.value = s;			
			opener.document.#URL.Formname#.submit();
			</CFOUTPUT>  
		window.close();
		
    }

</SCRIPT>



</body>
</html>