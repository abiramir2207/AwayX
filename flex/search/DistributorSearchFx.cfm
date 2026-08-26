

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
var requiredMajorVersion = 9;
// Minor version of Flash required
var requiredMinorVersion = 0;
// Minor version of Flash required
var requiredRevision = 28;
// -----------------------------------------------------------------------------
// -->
</script>
</head>

<body scroll="no">
<!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX Set up necessary vars from caller	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
<cfparam name="url.FormName" type="string" default="MyForm">
<cfparam name="url.Return_Value_Field_Name" type="string" default="FinalItemList">
<cfparam name="URL.SelectSingleSearchResultOnly" 	default="0">
<cfparam name="FORM.Group_Rebate_Type_Search_ID" 	default="0">
<CFPARAM NAME="FORM.Distributor_List" 				DEFAULT="">
<cfparam name="request.accessStructure.User_ID" type="string" default="">
<cfparam name="url.programID" type="numeric" default="0">
<cfset cacheSpan = APPLICATION.masterDataCacheSpan>
<cfset objTemplate = createobject("component", "components.programs.template.TemplateManager") />
<cfset variables.one_distributor = objTemplate.getProgramTemplate(url.programId).one_distributor />
<!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX END Set up necessary vars END	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
<cfif variables.one_distributor eq 1>
	<cfset variables.one_distributor = 'true' />
<cfelse>
	<cfset variables.one_distributor = '' />
</cfif>
<cfscript>
	flashVarsString = 	"userID=" & request.accessStructure.User_ID &
						"&programID=" & url.programID &
						"&oneDistSelection=" & variables.one_distributor;
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

	AC_FL_RunContent(
		"src", "playerProductInstall",
		"FlashVars", "MMredirectURL="+MMredirectURL+'&MMplayerType='+MMPlayerType+'&MMdoctitle='+MMdoctitle+"",
		"width", "100%",
		"height", "100%",
		"align", "middle",
		"id", "DistributorSearch",
		"quality", "high",
		"bgcolor", "#869ca7",
		"name", "DistributorSearch",
		"allowScriptAccess","sameDomain",
		"type", "application/x-shockwave-flash",
		"pluginspage", "http://www.adobe.com/go/getflashplayer"
	);
} else if (hasRequestedVersion) {
	// if we've detected an acceptable version
	// embed the Flash Content SWF when all tests are passed
	AC_FL_RunContent(
			"src", "DistributorSearch",
			"FlashVars", "<cfoutput>#flashVarsString#</cfoutput>",
			"width", "100%",
			"height", "100%",
			"align", "middle",
			"id", "DistributorSearch",
			"quality", "high",
			"bgcolor", "#869ca7",
			"name", "DistributorSearch",
			"allowScriptAccess","sameDomain",
			"type", "application/x-shockwave-flash",
			"pluginspage", "http://www.adobe.com/go/getflashplayer"
	);
  } else {  // flash is too old or we can't detect the plugin
    var alternateContent = 'Alternate HTML content should be placed here. '
  	+ 'This content requires the Adobe Flash Player. '
   	+ '<a href=http://www.adobe.com/go/getflash/>Get Flash</a>';
    document.write(alternateContent);  // insert non-flash content
  }
//
</script>

<noscript>
  	<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" name="DistributorSearch"
			id="DistributorSearch" width="100%" height="100%"
			codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
			<param name="movie" value="DistributorSearch.swf" />
			<param name="quality" value="high" />
			<param name="bgcolor" value="#869ca7" />
			<param name="allowScriptAccess" value="sameDomain" />
			<embed src="/Flex/DistributorSearch.swf" quality="high" bgcolor="#869ca7"
				width="100%" height="100%" name="DistributorSearch" align="middle"
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
        	if(i != arrItems.length) //include the comma
        		{s +=  arrItems[i] + ",";}
            else
            	{s +=  arrItems[i];}
        }
        //alert("itemlist: \n" + s);
        sendItems(s);
    }
    function sendItems(s){
    		<CFOUTPUT>
    		opener.document.all.deletedateexclusions.value = 0;
			opener.document.all.finishedselectingitems.value = 1;
			opener.document.all.#URL.FormName#.#URL.Return_Value_Field_Name#.value = s;
			opener.document.all.#URL.FormName#.submit();
			</CFOUTPUT> 
		window.close();
		
    }

</SCRIPT>
</body>
</html>
