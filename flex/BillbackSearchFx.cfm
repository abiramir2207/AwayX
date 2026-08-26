<CFSET PAGE_TITLE=	"Billback Search">
<CFSET GROUP=		"Billbacks">

<CFINCLUDE TEMPLATE="/includes/header.cfm">

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
var requiredMajorVersion = 10;
// Minor version of Flash required
var requiredMinorVersion = 2;
// Minor version of Flash required
var requiredRevision = 152;
// -----------------------------------------------------------------------------
// -->
</script>
</head>

<body scroll="no">

<cfparam name="request.accessStructure.User_ID" type="string" default="">
<cfparam name="status" type="string" default="">

<cfset cacheSpan = APPLICATION.masterDataCacheSpan>

<cfscript>
	flashVarsString = 	"userID=" & request.accessStructure.User_ID &
				"&status=" & status;
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
		"id", "BillbackMain",
		"quality", "high",
		"bgcolor", "#869ca7",
		"name", "BillbackMain",
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
			"src", "BillbackMain",
			"FlashVars", "<cfoutput>#flashVarsString#</cfoutput>",
			"width", "100%",
			"height", "100%",
			"align", "middle",
			"id", "BillbackMain",
			"quality", "high",
			"bgcolor", "#869ca7",
			"name", "BillbackMain",
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
			id="Billback" width="100%" height="100%"
			codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
			<param name="movie" value="BillbackMain.swf" />
			<param name="quality" value="high" />
			<param name="bgcolor" value="#869ca7" />
			<param name="allowScriptAccess" value="sameDomain" />
			<embed src="/flex/BillbackMain.swf" quality="high" bgcolor="#869ca7"
				width="100%" height="100%" name="SearchBillbackMain" align="middle"
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

</body>
</html>
