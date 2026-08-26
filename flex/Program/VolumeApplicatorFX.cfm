<!-----------------------------------------------------------------------------

FILE NAME:		VolumeApplicatorFX.cfm
DESCRIPTION: This file displays the flex tool for the volume applicator
CREATED BY:		???
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
Anand Rao 06-Jun-09 Created 

Arguments:
 contract_Main_ID returns to calling page
------------------------------------------------------------------------------> 

 
<!--- <CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<CFPARAM NAME="URL.packetId" 	DEFAULT="">
 --->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
 
<html>
<head>
	<title>Volume Applicator</title>
  <!--  BEGIN Browser History required section -->
<link rel="stylesheet" type="text/css" href="history/history.css" />
<!--  END Browser History required section -->
<script language="javascript">
  function fnRefreshParent()
  {
    //window.opener.location.href = window.opener.location.href;
    window.opener.location.href = '/Common_Files/Contracts/Contract_Edit_Menu.cfm?CID=<cfoutput>#URL.CID#</cfoutput>&editMode=1&FromVolumeApplicator=1';
    window.close(); 
  }
</script>

</head>
 
<cfif URL.Program_ID NEQ "">
<CFQUERY NAME="Get_Program_Details" DATASOURCE="#application.datasource#">
			SELECT	
          Generic_Type.Generic_Type_ID, 
					Program_Control_Panel_Options.Generic_Type,
					Program_Control_Panel_Options.Zero_Volume,
					Contract_Main.Contract_Number,
					Contract_Main.Contract_Title,
					Contract_Main.Contract_Quantity_UOM_IDX,
					ISNULL(Contract_Main.Contract_Quantity, 0) as Contract_Quantity,
					CONVERT(VARCHAR(10), Contract_Main.Contract_Start_Date, 101) AS Contract_Start_Date,
					CONVERT(VARCHAR(10), Contract_Main.Contract_End_Date, 101) AS Contract_End_Date,
          (DateDiff(day,Contract_Main.Contract_Start_Date, Contract_Main.Contract_End_Date)+1) as Contract_Span,          
					Contract_Main_Aux_Data.Forecast_ID,
					Program_Control_Panel_Options.Volume_Cap,
          CASE WHEN ((Program_Control_Panel_Options.Generic_Type = 'Operator-Deviated Pricing') OR
					(Program_Control_Panel_Options.Generic_Type = 'Operator Direct or HQ Programs'))
					THEN 'TRUE'
					ELSE 'FALSE'
					END AS bOpType          
			FROM	Contract_Main
					INNER JOIN 	Contract_Main_Aux_Data
					ON
					Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID
					INNER JOIN Program_Control_Panel_Options
					ON
					Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
					INNER JOIN Generic_Type
					ON
					Generic_Type.Generic_Type = Program_Control_Panel_Options.Generic_Type					
			WHERE
					Contract_Main.Contract_Main_ID = #URL.Program_ID#
		</CFQUERY>

  <cfset Contract_Span				= 0 />
  <cfset vchAppAreaTitle   = "[" & Get_Program_Details.Contract_Number &  "] - " & Get_Program_Details.Contract_Title />
  <cfset vchAppAreaKeyword = "Program" />
  <cfset vchAreaStartDate  = DateFormat(Get_Program_Details.Contract_Start_Date, "mm/dd/yyyy") />
  <cfset vchAreaEndDate    = DateFormat(Get_Program_Details.Contract_End_Date, "mm/dd/yyyy") />
  <cfif isDate(Get_Program_Details.Contract_Start_Date) and isDate(Get_Program_Details.Contract_End_Date)>
				<cfset Contract_Span				= DateDiff("d", Get_Program_Details.Contract_Start_Date, Get_Program_Details.Contract_End_Date) + 1>
			</cfif>  
  <cfset vchAreaSpanDays   = Contract_Span & " days" />
 
</CFIF>

<cfscript>
		flashVarsString = 	"userID=" & request.accessStructure.User_ID &
              "&profileID=" & request.AccessStructure.Profiles_ID & 
              "&appAreaTitle=" & Replace(Replace(vchAppAreaTitle, "'", "", "ALL"), '"', '',"ALL") &
							"&appAreaKeyword=" & vchAppAreaKeyword &
							"&appAreaStartDate=" & vchAreaStartDate &
 							"&appAreaEndDate=" & vchAreaEndDate &
							"&appAreaSpanDays=" & vchAreaSpanDays &
              "&appProgramID=" & #URL.Program_ID#;
              
	</cfscript>
<!---   <cfoutput>#flashVarsString#</cfoutput>  
  <cfabort> --->
 
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
	var MMredirectURL = window.location;
    document.title = document.title.slice(0, 47) + " - Flash Player Installation";
    var MMdoctitle = document.title;
 
	AC_FL_RunContent(
		"src", "/flex/playerProductInstall",
		"FlashVars", "MMredirectURL="+MMredirectURL+'&MMplayerType='+MMPlayerType+'&MMdoctitle='+MMdoctitle+"",
		"width", "100%",
		"height", "100%",
		"align", "middle",
		"id", "VolumeApplicator",
		"quality", "high",
		"bgcolor", "#869ca7",
		"name", "VolumeApplicator",
		"allowScriptAccess","sameDomain",
		"type", "application/x-shockwave-flash",
		"pluginspage", "http://www.adobe.com/go/getflashplayer"
	);
} else if (hasRequestedVersion) {
	// if we've detected an acceptable version
	// embed the Flash Content SWF when all tests are passed
	AC_FL_RunContent(
			"src", "/flex/Program/VolumeApplicator",
      "FlashVars", "<cfoutput>#flashVarsString#</cfoutput>",
			"width", "100%",
			"height", "100%",
			"align", "middle",
			"id", "VolumeApplicator",
			"quality", "high",
			"bgcolor", "#869ca7",
			"name", "VolumeApplicator",
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
  	<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
			id="VolumeApplicator" width="100%" height="100%"
			codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
			<param name="movie" value="VolumeApplicator.swf" />
			<param name="quality" value="high" />
			<param name="bgcolor" value="#869ca7" />
			<param name="allowScriptAccess" value="sameDomain" />
			<embed src="/flex/Program/VolumeApplicator.swf" quality="high" bgcolor="#869ca7"
				width="100%" height="100%" name="VolumeApplicator" align="middle"
				play="true"
				loop="false"
				quality="high"
				allowScriptAccess="sameDomain"
				type="application/x-shockwave-flash"
				pluginspage="http://www.adobe.com/go/getflashplayer">
			</embed>
	</object>
</noscript>
</body>
</html>
<cfinclude template="/mvc/Models/Program/Volume/VolumeApplicator.cfc" />
