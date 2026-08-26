

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

<title>Forge Item Search Utility</title>
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


<!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX Set up necessary vars from caller	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
<cfparam name="Discountype" default = "0">
<cfparam name="session.rebateType" default="">
<cfparam name="url.EZTemplate" default="0">
<cfparam name="url.component_id" default="0">
<cfparam name="EZButton_ProductList" default="">
<cfparam name="EzButton_Products" default="0">
<cfparam name="url.isparent" default="0">
<cfparam name="form.includeCustomersInProgram" default="0">
<!---default params for business segments--->
<CFPARAM name="url.Business_Segment_ID" default="0">
<CFPARAM name="FORM.Business_Segment_ID" default="#url.Business_Segment_ID#">
<CFPARAM name="url.businessSegmentsOn" default="0">
<CFPARAM name="form.businessSegmentsOn" default="#url.businessSegmentsOn#">
<cfparam name="Bus_Segment_Desc" default="" />
<cfparam name="URL.DTPS_Program_ID" default="0" />
<cfparam name="Form.DTPS_Program_ID" default="#URL.DTPS_Program_ID#" />
<cfparam name="Form.Bid_Rule_In_Effect" default="" />
<cfparam name="Form.Only_Show_Products_from_these_Groups" default="" />
<cfparam name="URL.CallingPage" default="Programs" />
<cfparam name="Form.CallingPage" default="#URL.CallingPage#" />
<cfparam name="Form.SudmitFormViaSubmitButton" default="0" />
<cfparam name="url.FormName" type="string" default="">
<cfset session.Group_Rebate_Type_Search_ID = 0  >

<cfif isDefined("url.formname")>
	<cfset session.rebateType = url.formname>
</cfif>

<cfparam name="form.rebateTypeSelected" default="0">
<!--- fixed price --->
<cfif isDefined("session.rebateType") and session.rebateType EQ Ucase("FixedComponents")>
	<cfset form.rebateTypeSelected = 1 >
<!--- allowance --->
<cfelseif isDefined("session.rebateType") and session.rebateType EQ Ucase("dataForm")>
	<cfset form.rebateTypeSelected = 2>
<!--- fee ---->
<cfelseif isDefined("session.rebateType") and session.rebateType EQ Ucase("MyForm")>
	<cfset form.rebateTypeSelected = 3>
<!--- growth---->
<cfelseif isDefined("session.rebateType") and  session.rebateType EQ Ucase("compProductTierRates")>
	<cfset form.rebateTypeSelected = 4> 
</cfif>

<cfparam name="url.Discountype" default = "0">

<cfset form.rebateTypeSelected = #url.Discountype#>

<cfif Discountype neq "0">
	<cfset form.rebateTypeSelected = Discountype>
</cfif>


<cfset appSettings = application.appSettingsGet>

<cfset userClassCodeInThisProductSearch = appSettings.getClassCodesOn() />

<cfset ProductMessagesComponent = createobject("component", "components.programs.Message")>

<cfparam name="form.ExistingProductList" default="">
<cfparam name="form.passed_form" default="">
<cfparam name="form.itemList" default="">
<cfparam name="URL.SelectSingleSearchResultOnly" 	default="0">
<cfparam name="URL.Return_Value_Field_Name" 		default="Product_List">
<cfparam name="URL.ExistingProductList_Field_Name" 		default="ExistingProductList">
<cfparam name="URL.ProductListToExcludeFromSelecting_Field_Name" 		default="ProductListToExcludeFromSelecting">
<cfparam name="URL.AnotherProductListToExcludeFromSelecting_Field_Name" 		default="AnotherProductListToExcludeFromSelecting">
<cfparam name="form.Prod_Name" default=""> 

<!--- <cfparam name="FORM.getCaptureGroupsOnSave" 	default="0"> --->

<cfparam name="FORM.Group_Rebate_Type_Search_ID" 	default="0">
<CFPARAM NAME="FORM.Distributor_List" 				DEFAULT="">

<cfset cacheSpan = APPLICATION.masterDataCacheSpan>
<CFPARAM NAME="UserClassCodes" default="">


<cfif appSettings.getAllowNavigate()>
	<CFINCLUDE TEMPLATE="/common_files/contracts/comparelist.cfm">
</cfif>

<cfif form.passed_form EQ "searchform">
	<cfset form.passed_form = "">
</cfif>
<!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX END Set up necessary vars END	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

<cfparam name="request.accessStructure.User_ID" type="string" default="">
<!--- <cfparam name="session.cfid" type="numeric" default="0">
<cfparam name="session.cftoken" type="numeric" default="0"> --->
<cfparam name="url.programID" type="numeric" default="0">
<cfparam name="url.discountType" type="numeric" default="0">
<cfparam name="url.FormName" type="string" default="myForm">
<cfparam name="url.StatusFilterOn" type="numeric" default="0">
<!--- opener.document.all.#URL.FormName#.#URL.Return_Value_Field_Name#.value --->

<cfscript>
	variables.settingsService = createObject("component","mvc.Models.SettingsService");
</cfscript>
						<!-- "&cfid=" & session.cfid & 
						"&cftoken=" & session.cftoken & -->
<cfscript>
	flashVarsString = 	"userID=" & request.accessStructure.User_ID &
						"&programID=" & url.programID & 
						"&discountTypeID=" & url.discountType & 
						"&formName=" & url.formName &
            "&statusFilterOn=" & url.StatusFilterOn &
						"&brand=" & variables.settingsService.getProductGroupLabels().brand & 
						"&qBrand=" & variables.settingsService.getProductGroupLabels().qBrand & 
						"&typeCode=" & variables.settingsService.getProductGroupLabels().typeCode & 
						"&typeGroup=" & variables.settingsService.getProductGroupLabels().typeGroup;
	//flashVarsString = "userID=11111&cfid=22222&cftoken=33333&programID=44444&discountTypeID=55555&brand=AAAAA&qBrand=BBBBB&typeCode=66666&typeGroup=77777;
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
		"id", "ItemSearch",
		"quality", "high",
		"bgcolor", "#869ca7",
		"name", "ItemSearch",
		"allowScriptAccess","sameDomain",
		"type", "application/x-shockwave-flash",
		"pluginspage", "http://www.adobe.com/go/getflashplayer"
	);
} else if (hasRequestedVersion) {
	// if we've detected an acceptable version
	// embed the Flash Content SWF when all tests are passed
	AC_FL_RunContent(
			"src", "ItemSearch",
			"FlashVars", "<cfoutput>#flashVarsString#</cfoutput>",
			"width", "100%",
			"height", "100%",
			"align", "middle",
			"id", "ItemSearch",
			"quality", "high",
			"bgcolor", "#869ca7",
			"name", "ItemSearch",
			"allowScriptAccess","always",
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
  	<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" name="ItemSearch"
			id="ItemSearch" width="100%" height="100%"
			codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
			<param name="movie" value="ItemSearch.swf" />
			<param name="quality" value="high" />
			<param name="bgcolor" value="#869ca7" />
			<param name="allowScriptAccess" value="always" />
			<embed src="/Flex/ItemSearch.swf" quality="high" bgcolor="#869ca7"
				width="100%" height="100%" name="ItemSearch" align="middle"
				flashVars="<cfoutput>#flashVarsString#</cfoutput>"
				play="true"
				loop="false"
				quality="high"
				allowScriptAccess="always"
				type="application/x-shockwave-flash"
				pluginspage="http://www.adobe.com/go/getflashplayer">
			</embed>
	</object>
</noscript>
<!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX END  CALL THE SWF END	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

<!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   Handle for Importing Items	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
<SCRIPT LANGUAGE="JavaScript">
	 function thisMovie(movieName) {
         if (navigator.appName.indexOf("Microsoft") != -1) {
             return window[movieName];
         } else {
             return document[movieName];
         }
     }

	function sendToActionScript(value) {
			<cfoutput>
	         	thisMovie("ItemSearch").sendToActionScript(opener.document.all.#URL.FormName#.#URL.Return_Value_Field_Name#.value);
	         </cfoutput>
	     }
  

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
			//opener.document.all.#URL.FormName#.action = 'contract_fixed_component_save.cfm';
    		if(opener.document.all.#URL.FormName#.SudmitFormViaSubmitButton)
			{
				this.document.all.SudmitFormViaSubmitButton.value = opener.document.all.#URL.FormName#.SudmitFormViaSubmitButton.value;				
			}
			
			if(opener.document.all.#URL.FormName#.Level_1)
			{
					/*append group items to list*/
					if(opener.document.all.#URL.FormName#.Level_1.value != '')
					{
							s = s + ',' + opener.document.all.#URL.FormName#.Level_1.value;
					}
			}

			opener.document.all.#URL.FormName#.#URL.Return_Value_Field_Name#.value = s
			//alert("itemlist: \n" + s);
			//alert("itemlist: \n" + opener.document.all.#URL.FormName#.Level_1.value);
			if(#form.SudmitFormViaSubmitButton# == 0)
			{
				/* MWS COMMENTED OUT for NEW 6.0 Code -> ERROR: Form.FinalUPCList not defined  */
				<!--- <cfif appSettings.getAllowNavigate()>   
				if(opener.document.all.#URL.FormName#.navigate)
				{
					<cfset listcompared1 = ListCompare(Form.FinalUPCList,Form.ExistingProductList) />
					<CFSET listcompared2 = ListCompare(Form.ExistingProductList,Form.FinalUPCList) />
					<cfif listlen(listcompared1) GT 0 OR listlen(listcompared2) GT 0>
						opener.document.all.#URL.FormName#.navigate.value = 1;
					</cfif>
				}
				if(opener.document.all.#URL.FormName#.stopnavigate)
				{
					opener.document.all.#URL.FormName#.stopnavigate.value = 1;
				}
				</cfif> --->
				opener.document.all.#URL.FormName#.submit()
			}
			else 
			{ 
				opener.document.all.#URL.FormName#.submitbutton.click();
			}
			</CFOUTPUT> 
		window.close();
		
    }
   function sendItemsall(s){
    		
    		<CFOUTPUT>
    		<!--- <cfif FORM.Importallflag EQ 1>
				<!--- compare all list with finalupclist, append those who are not in the all list but in the finalupclist --->
				<CFLOOP INDEX="ListItem" LIST="#allList#" DELIMITERS=",">
					<CFIF listfind(FORM.FinalUPCList, ListItem, ",") EQ 0>
						<CFSET FORM.FinalUPCList = listappend(FORM.FinalUPCList, ListItem, ",")>
					</CFIF>
				</CFLOOP>
				opener.document.all.#Form.ParentFormname#.#form.Return_Value_Field_Name#.value = '#FORM.FinalUPCList#' <!--- allList --->
			<cfelse> --->
				opener.document.all.#URL.FormName#.#URL.Return_Value_Field_Name#.value = s
			<!--- </cfif> --->
			
			/******* Set sort by *******/
			<!--- if(opener.document.all.#Form.ParentFormname#.Sort_By)
			{
				opener.document.all.#Form.ParentFormname#.Sort_By.value = '#Form.Sort_By#'
			} --->
			/******* Handle for allownavigate *******/
			<!--- if(#form.SudmitFormViaSubmitButton# == 0)
			{
				<cfif appSettings.getAllowNavigate()>
				if(opener.document.all.#Form.ParentFormname#.navigate)
				{
					<cfset listcompared1 = ListCompare(Form.FinalUPCList,Form.ExistingProductList)>
					<CFSET listcompared2 = ListCompare(Form.ExistingProductList,Form.FinalUPCList)>
					<cfif listlen(listcompared1) GT 0 OR listlen(listcompared2) GT 0>
						opener.document.all.#Form.ParentFormname#.navigate.value = 1;
					</cfif>
				}
				if(opener.document.all.#Form.ParentFormname#.stopnavigate)
				{
					opener.document.all.#Form.ParentFormname#.stopnavigate.value = 1;
				}
				</cfif>
				opener.document.all.#Form.ParentFormname#.submit()
			}
			else 
			{ --->
				opener.document.all.#URL.FormName#.submitbutton.click();
		<!--- 	}--->
		</CFOUTPUT> 
		window.close();
		alert("itemlist: \n" + s);
    }
</SCRIPT>
</head>
<body scroll="no">
</body>
</html>
