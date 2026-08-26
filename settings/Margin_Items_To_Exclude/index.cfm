<!-----------------------------------------------------------------------------

FILE NAME:		index.cfm
DESCRIPTION:	This page will get the control and display the page based on the
              different parameters.
CREATED BY:		Anand Rao/11-Aug-2010
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	11-Aug-2010	Created

------------------------------------------------------------------------------>
<cfsilent>
<CFPARAM NAME="URL.display"   DEFAULT="active">
<CFPARAM NAME="FORM.display"  DEFAULT="#url.display#">
<CFPARAM NAME="FORM.command"  DEFAULT="">
<CFPARAM NAME="FORM.returnTo"   DEFAULT="">

<cfset selectedIndex = 99>
<cfswitch expression="#form.display#">
  <cfcase value="active">    <cfset selectedIndex = 0>  </cfcase>
  <cfcase value="inActive">  <cfset selectedIndex = 1>  </cfcase>
  <cfcase value="add">       <cfset selectedIndex = 2>  </cfcase>
</cfswitch>
</cfsilent>

<cfmodule template="/customTags/layout.cfm"
              layoutID = "marginItemsToExclude"
              selectedIndex = "#selectedIndex#" >

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfquery name="qDiscountTypes" datasource="#application.datasource#">
SELECT Discount_Type_ID  FROM Discount_Type WHERE Deleted = 0
</cfquery>


<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>
<SCRIPT SRC="/script/javascript/string_functions.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="_margin_exclusion.js"></SCRIPT>
<script>
  function showProductSearchWindow()
  {
		var bSelectedAllProducts = false;
		var groupLevel = 0;
    	var sURL = "/Flex/search/ItemSearchFx.cfm?Formname=DataForm";

		NewWindowTopLeft(sURL, "productwindow", 1000, 715, "yes", "yes")
	}

	function showProductSearchWindow_old()
	{
		var bSelectedAllProducts = false;
		var groupLevel = 0;
    	var sURL = "/Common_Files/contracts/product_Select_V1.cfm?Formname=DataForm";
		NewWindowTopLeft(sURL, "productwindow_old", 1000, 700, "yes", "yes")
	}

	function showGroupSearchWindow()
	{
		NewWindow("/Common_Files/contracts/Groups/index.cfm?formName=DataForm&programId=0", "productwindow", 800, 600, "yes", "yes");
		return false;
	}

	function showSearchWindow(sUrl, FieldName,bChecker,dataForm)
	{
	    if (bChecker == '')
	    {
	      alert("Pick a Group from the left!");
	      return false;
	    }
	    else
	    {
	  		NewWindow(sUrl + '&FormName=DataForm&FieldName=' + FieldName , 'select_restrict_group_level_value' , 1000 , 800 , 'yes' , 'yes');
	  		return false;
	    }
	}

  function checkAllProd()
  {
	  var elemColctn = document.DataForm.getElementsByTagName("input");

  	for (var i = 0; i<elemColctn.length; i++)
  	{
  		if ((elemColctn[i].name.indexOf('prodChkBx') > -1))
  		{
  			if (elemColctn.prodCheck.checked)
  				elemColctn[i].checked = true;
  			else
  				elemColctn[i].checked = false;
      }
    }
  }

</script>


<cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />
<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
<cfset qGetTopLevelGroups = GroupDataManager.getProductGroupsData() />

<cfset ProductManager = CreateObject("component", "components.products.ProductManager") />

<cfscript>
	ExcludeItemsManager = CreateObject("component","components.settings.ExcludeItemsManager");
</cfscript>

<cfset operatingGroupManager = CreateObject("component","components.Operating_Group.OperatingGroupManager").init() />
<cfset operatingGroupOn = operatingGroupManager.operatingGroupOn() />
<cfset operatingGroupLevel = operatingGroupManager.componentMapLevel() />
<cfset allowanceCodeManager = CreateObject("component","components.Operating_Group.AllowanceCodeManager").init() />

<cfset application.oController.getObject(path="mvc.Models.Program.CreditTypeManager",name="CreditTypeManager",bReload= 0) />
<cfset application.oController.getObject(path="mvc.Models.Settings.FOBPriceIndicatorManager",name="FOBPriceIndicatorManager",bReload= 0) />


<cfif FORM.command eq "addExclusionItems">

  <cfif NOT isDefined("FORM.IncludeOnVolume")>
    <cfset FORM.IncludeOnVolume = 0 />
  </cfif>
	<cfscript>
      stError = StructNew();
      stError.bNameExists     = ExcludeItemsManager.AddItemsExclude(
      UserID                  = REQUEST.AccessStructure.user_id,
      MarginItemExclusionCode = FORM.MarginItemExclusionCode,
      MarginItemExclusionName = FORM.MarginItemExclusionName,
      IncludeOnVolume         = FORM.IncludeOnVolume,
      ProductList             = FORM.Product_List,
      GroupLevel              = FORM.GroupLevel,
      GroupList               = FORM.Allow_Approval_group,
      TemplateList            = FORM.Template_Select
    );
	</cfscript>

  <cfif (stError.bNameExists EQ "1")>
    <cfset FORM.display = "add" />
    <script>alert("Name already exists!");</script>
  </cfif>
<!---/////////////DEACTIVATE SELECTED LIST ///////////--->
<cfelseif FORM.command eq "deactSel">

	<cfscript>
		ExcludeItemsManager.deactivate(FORM.CID);
	</cfscript>

<!---/////////////DEACTIVATE SINGLE SELECTED //////////--->
<cfelseif FORM.command eq "deact">

	<cfscript>
		ExcludeItemsManager.deactivate(FORM.MarginItemExclusionID);
	</cfscript>

<!---/////////////ACTIVATE SELECTED LIST  ///////////--->
<cfelseif FORM.command eq "actSel">

	<cfscript>
		ExcludeItemsManager.activate(FORM.CID);
	</cfscript>

<!---/////////////ACTIVATE SINGLE SELECTED  ///////////--->
<cfelseif FORM.command eq "act">

	<cfscript>
		ExcludeItemsManager.activate(FORM.MarginItemExclusionID);
	</cfscript>

<!---///////////// DELETE SELECTED COMPONENT ///////////--->
<cfelseif FORM.command eq "delete">

	<cfscript>
    ExcludeItemsManager.delete(FORM.MarginItemExclusionID);
	</cfscript>

<!---/////////////UPDATE COMPONENT///////////--->
<cfelseif FORM.command eq "updateExclusionItems">
	<cfif NOT isDefined("FORM.IncludeOnVolume")>
    <cfset FORM.IncludeOnVolume = 0 />
  </cfif>
	<cfscript>
    stError = StructNew();
    stError.bNameExists       = ExcludeItemsManager.updateItemsExclude(
      UserID                  = REQUEST.AccessStructure.user_id,
      MarginItemExclusionCode = FORM.MarginItemExclusionCode,
      MarginItemExclusionName = FORM.MarginItemExclusionName,
      IncludeOnVolume         = FORM.IncludeOnVolume,
      ProductList             = FORM.Product_List,
      GroupLevel              = FORM.GroupLevel,
      GroupList               = FORM.Allow_Approval_group,
      TemplateList            = FORM.Template_Select,
      MarginItemExclusionID   = FORM.MarginItemExclusionID
    );
  </cfscript>

  <cfif (stError.bNameExists EQ "1")>
    <script>alert("Name already Exists");</script>
		<cfset FORM.display = "edit" />
  </cfif>

</cfif>

<cfset FORM.command = "" />

<!---****************************** START DISPLAY ***********************************--->

<!---/////////////DISPLAY ACTIVE///////////--->
<cfif FORM.display eq "active">

	<cfscript>
		qGetActiveExcludeItems = ExcludeItemsManager.getActiveItemsExclude();
	</cfscript>

<!---/////////////DISPLAY INACTIVE///////////--->
<cfelseif FORM.display eq "inActive">

	<cfscript>
		qGetActiveExcludeItems = ExcludeItemsManager.getInActiveItemsExclude();
	</cfscript>

<!---/////////////DISPLAY EDIT///////////--->
<cfelseif FORM.display eq "edit">

	<cfscript>
    qMarginItemExclusion          =  ExcludeItemsManager.getActiveItemsExcludeOnID(FORM.MarginItemExclusionID);
    qMarginItemExclusionProducts  =  ExcludeItemsManager.getItemExclusionProducts(FORM.MarginItemExclusionID);
    qMarginItemExclusionGroups    =  ExcludeItemsManager.getItemExclusionGroups(FORM.MarginItemExclusionID);
    qMarginItemExclusionTemplates =  ExcludeItemsManager.getItemExclusionTemplates(FORM.MarginItemExclusionID);
	</cfscript>
</cfif>

<!---****************************** END DISPLAY ***********************************--->

<FORM ACTION="index.cfm" METHOD="post" NAME="DataForm">

<!--switch for each action--->
<cfswitch expression="#FORM.display#">
	<cfcase value="active">
		<cfinclude template="_margin_exclusion_display.cfm" />
	</cfcase>

	<cfcase value="inActive">
		<cfinclude template="_margin_exclusion_display.cfm" />
	</cfcase>

	<cfcase value="add">
		<cfset FORM.MarginItemExclusionID = "" />
		<cfif (NOT isDefined("FORM.productRefresh"))> <!--- OR (isDefined("FORM.productRefresh") AND FORM.productRefresh EQ "0") --->
			<cfset FORM.TEMPLATE_SELECT = ""/>
			<cfset FORM.PRODUCT_LIST = ""/>
			<cfset FORM.MARGINITEMEXCLUSIONCODE= "" />
			<cfset FORM.MARGINITEMEXCLUSIONID = ""/>
			<cfset FORM.MARGINITEMEXCLUSIONNAME = ""/>
			<cfset FORM.GROUPLEVEL = ""/>
			<cfset FORM.ALLOW_APPROVAL_GROUP = ""/>
			<cfset FORM.productRefresh = "1" />
			<cfset StructDelete(Session, "FormData")>
		</cfif>
		<cfinclude template="_margin_exclusion_add.cfm" />
	</cfcase>
	<cfcase value="edit">
		<cfinclude template="_margin_exclusion_add.cfm" />
	</cfcase>
</cfswitch>

<cfoutput>
<!---hidden FORM fields--->

<input name="display" type="hidden" value="#FORM.display#" />
<input name="command" type="hidden" value="#FORM.command#" />
<!--- <input name="compId" type="hidden" value="" /> --->
<cfif isDefined("FORM.MarginItemExclusionID")>
  <input name="MarginItemExclusionID" type="hidden" value="#FORM.MarginItemExclusionID#" />
<cfelse>
  <input name="MarginItemExclusionID" type="hidden" value="" />
</cfif>
<input name="returnTo" type="hidden" value="#FORM.returnTo#"/>
</cfoutput>
</FORM>

</cfmodule>