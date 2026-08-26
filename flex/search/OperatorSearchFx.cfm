<html lang="en">

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

	<!---  BEGIN Browser History required section --->
	<link rel="stylesheet" type="text/css" href="/flex/history/history.css" />
	<!---  END Browser History required section --->
	
	<title></title>
	<script src="/flex/AC_OETags.js" language="javascript"></script>
	
	<!---  BEGIN Browser History required section --->
	<script src="/flex/history/history.js" language="javascript"></script>
	<!---  END Browser History required section --->
	
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
	<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX Set up necessary vars from caller	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cfset appSettings = application.appSettingsGet>
	
	<!--- Default params for business segment --->
	<CFPARAM name="url.businessSegmentsOn" 		default="0">
	<CFPARAM name="form.businessSegmentsOn" 	default="#url.businessSegmentsOn#">
	<CFPARAM name="url.Business_Segment_ID" 	default="0">
	<CFPARAM name="form.Business_Segment_ID" 	default="#url.Business_Segment_ID#">
	
	<!--- Program ID --->
	<cfparam name="url.programID" 				default="0"					type="numeric" >
	<cfparam name="form.programID" 				default="#url.programID#" 	type="numeric" >
	
	<!--- User ID --->
	<cfparam name="request.accessStructure.User_ID"	default=""	type="string" >
	
	<!--- Form Defaults --->
	<cfparam name="url.formname" 						default="MyForm" />
	<cfparam name="form.formname" 						default="#URL.formname#" />
	<cfparam name="form.AlreadySelectedItems" 			default="form.FinalItemList">
	<cfparam name="form.FinalItemList" 					default="FinalItemList">
	<cfparam name="url.FinalItemList" 					default="#form.FinalItemList#">
	<cfparam name="url.SelectSingleSearchResultOnly" 	default="0">
	
	
	<cfset cacheSpan = APPLICATION.masterDataCacheSpan>

	<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX END Set up necessary vars END	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	
	
	<cfscript>
		flashVarsString = 	"userID=" & request.accessStructure.User_ID &
							"&programID=" & url.programID &
							"&businessSegmentsOn=" & url.businessSegmentsOn &
							"&businessSegmentID=" & url.Business_Segment_ID &
							"&preSelected=" & url.preSelected;
	</cfscript>
	

	<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   CALL THE SWF (Flash Player version check -> then call)	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
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
			"id", "OperatorSearch",
			"quality", "high",
			"bgcolor", "#869ca7",
			"name", "OperatorSearch",
			"allowScriptAccess","sameDomain",
			"type", "application/x-shockwave-flash",
			"pluginspage", "http://www.adobe.com/go/getflashplayer"
		);
	} 
	else if (hasRequestedVersion) {
		// if we've detected an acceptable version
		// embed the Flash Content SWF when all tests are passed
		AC_FL_RunContent(
				"src", "OperatorSearch",
				"FlashVars", "<cfoutput>#flashVarsString#</cfoutput>",
				"width", "100%",
				"height", "100%",
				"align", "middle",
				"id", "OperatorSearch",
				"quality", "high",
				"bgcolor", "#869ca7",
				"name", "OperatorSearch",
				"allowScriptAccess","sameDomain",
				"type", "application/x-shockwave-flash",
				"pluginspage", "http://www.adobe.com/go/getflashplayer"
		);
	} 
	else {  // flash is too old or we can't detect the plugin
	    var alternateContent = 'Alternate HTML content should be placed here. '
	  	+ 'This content requires the Adobe Flash Player. '
	   	+ '<a href=http://www.adobe.com/go/getflash/>Get Flash</a>';
	    document.write(alternateContent);  // insert non-flash content
	}
	//
	</script>

	<noscript>
	  	<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" name="OperatorSearch"
				id="OperatorSearch" width="100%" height="100%"
				codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
				<param name="movie" value="OperatorSearch.swf" />
				<param name="quality" value="high" />
				<param name="bgcolor" value="#869ca7" />
				<param name="allowScriptAccess" value="sameDomain" />
				<embed src="OperatorSearch.swf" quality="high" bgcolor="#869ca7"
					width="100%" height="100%" name="OperatorSearch" align="middle"
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
	<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX END  CALL THE SWF END	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->

	<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   Handle for Importing Items	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<SCRIPT LANGUAGE="JavaScript">
		function finishedSearching(arrItems) {
	        var s = "";
	        // Iterate over embedded object's properties.
	        for (i=0; i<arrItems.length; i++) {
	        	if(i >=1) //include the comma
	        		{s +=  "," + arrItems[i];}
	            else
	            	{s +=  arrItems[i];}
	        }
	        sendItems(s);
	    }
	    
	    function sendItems(s){
	    	<cfoutput>
				opener.document.all.finishedselectingitems.value = 1;
				opener.document.all.#url.formname#.#url.FinalItemList#.value = s;
				opener.document.all.#url.formname#.submit();
			</cfoutput> 
			window.close();
			
	    }

	</SCRIPT>
</body>
</html>
