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

<title>Rates</title>
<CFPARAM NAME="URL.CID" DEFAULT="">

<cfif URL.CID NEQ "" >
	<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
	<cfset url.programID = cryp.value />
</cfif>
<cfquery name="GetSettings" datasource="#application.datasource#">
	SELECT
			Contract_Main.Template_Filters_Id
	FROM Contract_Main
<!---	INNER JOIN	Program_Control_Panel_Options PCPO ON 
		Contract_Main.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID--->
	WHERE Contract_Main_ID = <cfqueryparam value="#url.ProgramId#" cfsqltype="cf_sql_integer">
</cfquery>

<cfset variables.TemplateFiltersID = 0 />
<cfif GetSettings.RecordCount>
	<cfset variables.TemplateFiltersID = GetSettings.Template_Filters_Id />
</cfif>

<cfparam name="url.programID" 	type="integer" default="0" />
<cfparam name="url.bMarketPrice" type="integer" default="0" />
<cfparam name="url.StatusFilterOn" 	type="integer" 	default="1" />
<cfparam name="url.ID" 	type="integer" 	default="0" />
<cfparam name="url.TemplateFiltersID" 	type="integer" 	default="#variables.TemplateFiltersID#" />


<cfscript>
		objMarketPriceManager	= CreateObject("component","mvc.Models.Template.MarketPriceManager");
		iMPId = objMarketPriceManager.getProgramActiveMPList(url.programID);
		appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
		url.StatusFilterOn = appSettings.getSearchInactiveProductsInPrograms();
		flashVarsString =	"userID=" & request.accessStructure.User_ID &
							"&programID=" & url.programID & 
							"&bMarketPrice=" & url.bMarketPrice &
           	 				"&statusFilterOn=" & url.StatusFilterOn &
           	 				"&templateFilterId=" & url.TemplateFiltersID &
           	 				"&iMpId=" & iMPId;
         /**************************************************************************************************************************************************
         		D35295 (7.1) ::  decide which version of "rates Grid"" to use.  New appsetting drives Group creation off of Template setting Allow_In_Group_Search.
         		It also allows for using these new groups in the rates grid For Fixed and Rebate components including Market Pricing.
         		Rates Grid Flex Project was copied from "ContractMain" into "Forge"".  Both Projects use same Backend Code (remote object destinations).
		 		The original ContractMain version does not have new changes and will minimize potential issues when existing rates Grid users eventually upgrade to 7.1
		 ******************************************************************************************************************************/
        if(application.appSettingsGet.getTemplateMultipleProductAttrGroups() OR programID EQ '111994'){
        	ContractMainSwfPath = '/flex/ContractMain';
        	//ContractMainSwfPath = '/flex/Program/ContractMain';
        }
        else{
        //	ContractMainSwfPath = '/flex/Program/ContractMain';
		ContractMainSwfPath = '/flex/ContractMain';
        }
</cfscript>
<!--- <cfdump var = '#url#' /> 
<cfabort>--->
<!---<cfdump var="#flashVarsString#" /><cfabort>--->
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
var requiredMinorVersion = 0;
// Minor version of Flash required
var requiredRevision = 0;
// -----------------------------------------------------------------------------
// -->
</script>
</head>

<body scroll="no">
<script language="JavaScript" type="text/javascript">
<!--
// Version check for the Flash Player that has the ability to start Player Product Install (6.0r65)
var hasProductInstall = DetectFlashVer(6, 0, 65);

// Version check based upon the values defined in globals
var hasRequestedVersion = DetectFlashVer(requiredMajorVersion, requiredMinorVersion, requiredRevision);

if ( hasProductInstall && !hasRequestedVersion ) {
	// DO NOT MODIFY THE FOLLOWING FOUR LINES
	// Location visited after installation is complete if installation is required
	var MMPlayerType = (isIE == true) ? "ActiveX" : "PlugIn";
	var MMredirectURL = encodeURI(window.location);
    document.title = document.title.slice(0, 47) + " - Flash Player Installation";
    var MMdoctitle = document.title;

	AC_FL_RunContent(
		"src", "playerProductInstall",
		"FlashVars", "MMredirectURL="+MMredirectURL+'&MMplayerType='+MMPlayerType+'&MMdoctitle='+MMdoctitle+"",
		"width", "100%",
		"height", "100%",
		"align", "middle",
		"id", "ContractMain",
		"quality", "high",
		"bgcolor", "#869ca7",
		"name", "ContractMain",
		"allowScriptAccess","sameDomain",
		"type", "application/x-shockwave-flash",
		"pluginspage", "http://www.adobe.com/go/getflashplayer"
	);
} else if (hasRequestedVersion) {
	// if we've detected an acceptable version
	// embed the Flash Content SWF when all tests are passed
	// "src", "/flex/Program/ContractMain",  MOVED TO /FLEX in 7.1 Groups update D35295
	AC_FL_RunContent(
			"src", "<cfoutput>#ContractMainSwfPath#</cfoutput>",
			"FlashVars", "<cfoutput>#flashVarsString#</cfoutput>",
			"width", "100%",
			"height", "100%",
			"align", "middle",
			"id", "ContractMain",
			"quality", "high",
			"bgcolor", "#869ca7",
			"name", "ContractMain",
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
// -->
</script>
<noscript>
	<!--- <embed src="/flex/Program/ContractMain.swf" quality="high" bgcolor="#869ca7" --->
  	<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
			id="ContractMain" width="100%" height="100%"
			codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
			<param name="movie" value="<cfoutput>#ContractMainSwfPath#.swf</cfoutput>" />
			<param name="quality" value="high" />
			<param name="bgcolor" value="#869ca7" />
			<param name="allowScriptAccess" value="sameDomain" />
			<embed src="/flex/ContractMain.swf" quality="high" bgcolor="#869ca7"
				width="100%" height="100%" name="ContractMain" align="middle"
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

<cfset location = '/Common_Files/Contracts/Contract_Edit_Menu.cfm?CID=#URL.CID#&editMode=1&FromFlex=1' />
<!--- Comment for label D26730  by Dinesh  <cfif !bMarketPrice>
  <cfset location = '/Common_Files/Contracts/Contract_Edit_Menu.cfm?CID=#URL.CID#&editMode=1&FromFlex=1' />
<cfelse>
  <cfset location = '/Program_Wizard/filter/marketPrice.cfm?programID=#URL.programID#&ID=#URL.ID#&tfId=#URL.tfId#' />
</cfif> Comment for label D26730  by Dinesh--->

<!--- Added for label D26730  by Dinesh this closes pop-up flex if it's from market price if not it will redirect to the same page--->
<SCRIPT LANGUAGE="JavaScript">
<cfoutput>
   function closeCompProdRateEdit()
	{
<cfif bMarketPrice>
 window.close();
<cfelse>
  window.location.href = '#location#';
</cfif>
    }
</cfoutput>
</SCRIPT>
<!--- label D26730  by Dinesh --->

</body>
</html>
