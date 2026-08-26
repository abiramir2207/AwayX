<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8">
	<cfsavecontent variable="head_content">
		<style>
			div#msg55 p {
				font-size: 1.35em;
				margin:20px;
				padding:20px;
				background-color: #BDE5F8;
				letter-spacing:0.9px;
			}
			.red {
				color:red;
			}
			.name {
				color:#678a00
			}
		</style>
		<cf_include files="/common_files/jQuery.cfm, /common_files/impromptu.css, /Script/javascript/jquery-impromptu.3.1.min.js">
	</cfsavecontent>
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
	<cf_include files="/styles/css-loader.css">
</head>
<!-----------------------------------------------------------------------------

FILE NAME:		index.cfm
DESCRIPTION:
CREATED BY:		Anand Rao/09-Sep-2010
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	09-Sep-2010	Created

------------------------------------------------------------------------------>
<cfoutput>
<cfset PageTitle = "PLANNING GROUPS">
</cfoutput>

<cfajaximport tags="cfwindow,cfform,cfgrid" >

<CFSET ASC_IMG="/images/down_1.gif">
<CFSET DESC_IMG="/images/up_1.gif">

<cfparam name="FORM.New_Sort_Order" default="DESC" />
<cfparam name="FORM.sort_by" default="DESC" />
<cfparam name="FORM.templateExpanded" default="0" />
<cfparam name="FORM.PG_Effective_Start_Date" default="">
<cfparam name="FORM.PG_Effective_End_Date" default="">

<cfset PGManager = CreateObject("component", "components.settings.PlanningGroups.PlanningGroupsManager").init() />
<cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />
<cfset OprGroupDataManager = CreateObject("component", "components.operator.Group.DataManager") />

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
<cfset ProductManager = CreateObject("component", "components.products.ProductManager") />

<!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START--->
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset isBusinessSegEnabledForDistributor = businessSegManager.isEnabledForDistributor()>
<cfset isBusinessSegEnabledForProduct = businessSegManager.isEnabledForProduct() />
<cfset isBusinessSegEnabledForOperator = businessSegManager.isEnabledForOperator()>
<cfset qGetBusSegments = businessSegManager.getActive() />
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js, _planning_groups.js,/Script/javascript/dom_common.js">
<cfmodule template="/customTags/include.cfm" file_to_include="/script/javascript/string_functions.js, /Common_Files/Delete_Functions.js">

<script>
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

function showSearchWindow(sUrl, FieldName,dataForm)
	{
  // Check to make sure that the radio button to either Include or Exclude is selected.
  var bChecker = '';
  var selVal = 0;

  rdoIncExcLen = document.DataForm.rdoIncExc.length;
  rdoSelected = '';

if (document.DataForm.bIncludeInOthers.checked && $('select[name="GroupLevel2"]').length)    /*D31573*/
  {
     selVal = document.DataForm.GroupLevel2.options[document.DataForm.GroupLevel2.selectedIndex].value;
     document.DataForm.GroupLevel_Name.value = document.DataForm.GroupLevel2.options[document.DataForm.GroupLevel2.selectedIndex].text;
  }
  else
  {
     selVal = document.DataForm.GroupLevel1.options[document.DataForm.GroupLevel1.selectedIndex].value;
     document.DataForm.GroupLevel_Name.value = document.DataForm.GroupLevel1.options[document.DataForm.GroupLevel1.selectedIndex].text;
  }
  document.DataForm.GroupLevel.value =  selVal;
  for (i = 0; i <rdoIncExcLen; i++) {
    if (document.DataForm.rdoIncExc[i].checked)
    {
      rdoSelected = document.DataForm.rdoIncExc[i].value
    }
  }
  if (rdoSelected == '')
  {
    alert("Select Include or Exclude!");
    return false;
  }

  if (document.DataForm.selTypeName.selectedIndex == 0)
  {
    alert("Select a Type Name!");
    return false;
  }

  bChecker = selVal;
  if (bChecker == '')
  {
      alert("Pick a Group!");
      return false;
  }
  else
  {
  	<cfoutput>
      //dataForm.submit();
  		NewWindow(sUrl + selVal +  '&FormName=DataForm&FieldName=' + FieldName , 'select_restrict_group_level_value' , 1000 , 800 , 'yes' , 'yes');
  		return false;
  	</cfoutput>
    }
	}

function showDistGroupSearchWindow(sUrl, FieldName,dataForm)
	{
   // Check to make sure that the radio button to either Include or Exclude is selected.
   //
   var bChecker = '';
   var selVal = 0;
  rdoIncExcLen = document.DataForm.rdoIncExc.length;
  rdoSelected = '';

  if (document.DataForm.bIncludeInOthers.checked && $('select[name="GroupLevel2"]').length)
  {
     selVal = document.DataForm.GroupLevel2.options[document.DataForm.GroupLevel2.selectedIndex].value;
     document.DataForm.GroupLevel_Name.value = document.DataForm.GroupLevel2.options[document.DataForm.GroupLevel2.selectedIndex].text;
  }
  else
  {
     selVal = document.DataForm.GroupLevel1.options[document.DataForm.GroupLevel1.selectedIndex].value;
     document.DataForm.GroupLevel_Name.value = document.DataForm.GroupLevel1.options[document.DataForm.GroupLevel1.selectedIndex].text;
  }

  document.DataForm.GroupLevel.value =  selVal;
  for (i = 0; i <rdoIncExcLen; i++) {
    if (document.DataForm.rdoIncExc[i].checked)
    {
      rdoSelected = document.DataForm.rdoIncExc[i].value
    }
  }

if (rdoSelected == '')
  {
    alert("Select Include or Exclude!");
    return false;
  }

	if (document.DataForm.selTypeName.selectedIndex == 0)
	{
	  alert("Select a Type Name!");
	  return false;
	}

  bChecker = selVal;
  if (bChecker == '')
  {
      alert("Pick a Group!");
      return false;
  }
  else
  {
  	<cfoutput>
   		NewWindow(sUrl + selVal + '&FormName=DataForm&FieldName=' + FieldName , 'select_restrict_group_level_value' , 1000 , 800 , 'yes' , 'yes');
  		return false;
  	</cfoutput>
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

  function callSpinner()
  {
  	show_loader( "LOADING... PLEASE WAIT...", 1000 );
  }
</script>
<!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START--->

<script>
function enableField(bsvalue){

	if(document.forms["DataForm"]["business_segment_sel"].value != 0)
	{

		    var alert_user = confirm("You have selected "  +bsvalue+  " as <cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput>\nDid you select the correct <cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput>?\nYou will not be able to change the segment if you click 'OK'");

		    if (alert_user)
			{
				document.DataForm.business_segment_sel.disabled=true;
				document.DataForm.business_segment.value= document.DataForm.business_segment_sel.value;
				document.getElementById('RadioEnable').style.display ='block';
        		document.getElementById('RadioDisable').style.display ='none';
		/*      document.DataForm.rdoIncExcYes.disabled = false;
        document.DataForm.rdoIncExcNo.disabled = false; */
        document.DataForm.selTypeName.disabled=false;
				document.DataForm.bIncludeInOthers.disabled=false;
				document.DataForm.bMasterGroupOnly.disabled=false;
				document.DataForm.rdoIncExc.disabled=false;
				document.DataForm.GroupLevel1.disabled=false;
				/*document.DataForm.GroupLevel2.disabled=false;*/
			}
			else{
				document.forms["DataForm"]["business_segment_sel"].selectedIndex = 0;
			}

	}
	if(document.forms["DataForm"]["business_segment_sel"].value == 0)
	{
		document.DataForm.selTypeName.disabled=true;
		document.DataForm.bIncludeInOthers.disabled=true;
		document.DataForm.bMasterGroupOnly.disabled=true;
		document.DataForm.rdoIncExc.disabled=true;
		document.DataForm.GroupLevel1.disabled=true;
		document.DataForm.GroupLevel2.disabled=true;
	}

}

 </script>
 <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->
<cfif isDefined("FORM.New_Sort_Order") AND FORM.New_Sort_Order EQ "ASC">
	  <cfset New_Sort_Order="DESC">
		<cfset sortImage="down_1.gif">
<cfelse>
		<cfset New_Sort_Order="ASC">
		<cfset sortImage="up_1.gif">
</cfif>

<BODY BGCOLOR="Whitesmoke">
<!--- <CFINCLUDE TEMPLATE="/settings/settings_title.cfm"> --->
<CFPARAM NAME="FORM.display" 	DEFAULT="active">
<CFPARAM NAME="FORM.display_type" 	DEFAULT="Type">
<CFPARAM NAME="FORM.command" 	DEFAULT="">
<CFPARAM NAME="FORM.returnTo" 	DEFAULT="">
<CFPARAM NAME="FORM.pageAction2" DEFAULT ="">
<CFPARAM NAME="FORM.PGTypeID" DEFAULT ="">
<CFPARAM NAME="FORM.PGProductCategoryID" DEFAULT ="">
<CFPARAM NAME="FORM.PGCustomerCategoryID" DEFAULT ="">
<CFPARAM NAME="FORM.PGOperatorCategoryID" DEFAULT ="">

<CFPARAM NAME="FORM.DelMarkedInInclude" DEFAULT ="">
<CFPARAM NAME="FORM.DelMarkedInExclude" DEFAULT ="">
<CFPARAM NAME="FORM.DelMarkedInExisting" DEFAULT ="">

<CFPARAM NAME="FORM.Allow_Approval_group" DEFAULT ="">
<CFPARAM NAME="FORM.Allow_Operator_Group" DEFAULT ="">
<cfparam name="form.business_segment" default="0"/>
<cfparam name="FORM.OrderByField" default="Group_Name">
<cfparam name="FORM.OrderBy" default="ASC">
<cfparam name="FORM.MemSearchKeyword" default="">
<cfparam name="FORM.TmpltSearchKeyword" default="">
<cfparam name="URL.OrderByField" default="">
<cfparam name="URL.OrderBy" default="ASC">
<cfparam name="URL.EEMExpanded" default="false">
<cfparam name="URL.memSearchKeyword" default="">
<cfparam name="URL.tmpltSearchKeyword" default="">
<cfparam name="URL.TemplateExpanded" default="false" />

<cffunction name="member_alert" output="false" hint="Returns group member alert message after save takes place.">
    <cfargument name="PGType" required="true">
    <cfargument name="GroupID" required="true">
    <cfargument name="groupName" required="false" default="#form.planningGroupName#">

    <cfscript>
        // find number of members in the group
        local.count = PGManager.membersCount(arguments.PGType, arguments.GroupID);
        // return alert message
        return (  "<span class=name>" & replace(arguments.groupName, '"', ' ', "all") & "</span>"
                & " saved successfully with "
                & (local.count eq 0
                      ? "<span class=red>zero</span> members.<br><br><span class=red><u>ATTENTION</u>:</span> &nbsp;It is not generally expected that a group resolves to <span class=red>zero</span> members."
                      : "<span class=name>" & local.count & "</span> members.") );
    </cfscript>
</cffunction>

<!--- Check for the different saves --->
<cfif form.command eq "exportMembers">
    <cfinclude template="exportByGroups.cfm">
    <cfset form.command = "">
</cfif>


<cfif isDefined("FORM.typepageAction2") AND FORM.typepageAction2 EQ "TypeAddSave" AND FORM.isDefined("FORM.TypeRefresh") AND FORM.TypeRefresh EQ "0">
<cfscript>
    stError = StructNew();
    stError.bNameExists = PGManager.fnAddPGType(
     UserID = REQUEST.AccessStructure.User_ID,
     stForm = FORM
     );
	</cfscript>
  <cfif (stError.bNameExists EQ "1")>
    <script>alert("Name already Exists");</script>
    <cfelse>
      <cfset FORM.pageAction2 = "" />
      <cfset FORM.Display_Type = "Type" />
      <cfset FORM.Display = "Active" />
  </cfif>
</cfif>

<!--- START: PG Type Edit Save Section --->

<cfif isDefined("FORM.pageAction2") AND FORM.pageAction2 EQ "TypeEditSave" AND FORM.isDefined("FORM.TypeRefresh") AND FORM.TypeRefresh EQ "0">
<cfscript>
    stError = StructNew();
    stError.bNameExists = PGManager.fnEditPGType(
     UserID = REQUEST.AccessStructure.User_ID,
     stForm = FORM
     );
	</cfscript>
	<cfset FORM.TypeID = "" />
	<cfset FORM.TypeName = "" />
  <cfloop index="colName" list="#FORM.fieldnames#">
    <cfif (FindNoCase("chkBoxSearch_",colName) NEQ 0)>
      <cfset temp = StructDelete(FORM, colName) />
    </cfif>
     <cfif (FindNoCase("chkBoxGroup_",colName) NEQ 0)>
       <cfset temp = StructDelete(FORM, colName) />
     </cfif>
  </cfloop>
	<cfset FORM.rdoTypeCategory= ""/>
  <cfif (stError.bNameExists EQ "1")>
    <script>alert("Name already Exists");</script>
    <cfelse>
      <cfset FORM.pageAction2 = "" />
      <cfset FORM.Display_Type = "Type" />
      <cfset FORM.Display = "Active" />
  </cfif>
</cfif>
<!--- END: PG Type Edit Save Section --->

<cfif isDefined("FORM.pageAction2") AND FORM.pageAction2 EQ "ProductAddSave">
  <cfscript>
    stError = StructNew();
    stError.bNameExists = PGManager.fnAddProductPG(
     UserID = REQUEST.AccessStructure.User_ID,
     stForm = FORM,
     stSession = SESSION
     );

	PGCategoryID = PGManager.getPGCategoryID(1,form.PlanningGroupName);
	</cfscript>
  <cfif (stError.bNameExists EQ "1")>
    <script>alert("Name already Exists");</script>
		<!--- <cfset FORM.display = "edit" /> --->
  <cfelse>
    <script>
      $.prompt( <cfoutput>"#member_alert("1", PGCategoryID)#" </cfoutput> );
    </script>
    <cfif isDefined("FORM.pageAfterSave") AND FORM.pageAfterSave EQ "2">
      <cfset FORM.Display_Type = "Product" />
      <cfset FORM.Display = "Active" />
    <cfelseif isDefined("FORM.pageAfterSave") AND FORM.pageAfterSave EQ "1">
      <cfset FORM.Display_Type = "Product" />
      <cfset FORM.Display = "Add" />
    </cfif>

        <cfset FORM.PGTypeID = "" />
        <cfset FORM.Allow_Approval_Group = "" />
        <cfset FORM.bIncludeInOthers = "0" />
        <cfset FORM.Product_List  = "" />
        <cfset FORM.GroupLevel = "" />
        <cfset FORM.GroupLevel_Name = "" />
        <cfset FORM.PGTypeID  = "" />
        <cfset FORM.PlanningGroupCode = "" />
        <cfset FORM.PlanningGroupName = "" />
        <cfset FORM.selCustomerPG = "" />

		<cfset FORM.business_segment    = "0" />

        <cfset FORM.selTypeName    = "" />
        <cfset FORM.pageAction2 = "" />
        <cfset FORM.PageAfterSave = "" />
        <cfloop index="colName" list="#FORM.fieldnames#">
          <cfif (FindNoCase("CHKBOXTEMPLATE_",colName) NEQ 0)>
            <cfset temp = StructDelete(FORM, colName) />
          </cfif>
		  <!--- When deleting the CHKBOXTEMPLATE_ field also delete the FILTERSID_ field --->
          <cfif (FindNoCase("FILTERSID_",colName) NEQ 0)>
            <cfset temp = StructDelete(FORM, colName) />
          </cfif>
        </cfloop>
        <cfif isDefined("SESSION.qryGrpProdPack")>
          <cfset tempvariable = StructDelete(SESSION,"qryGrpProdPack")>
        </cfif>
  </cfif>
</cfif>

<cfif isDefined("FORM.pageAction2") AND FORM.pageAction2 EQ "ProductEditSave">
  <cfscript>
    stError = StructNew();
    stError.bNameExists = PGManager.fnEditProductPG(
     UserID = REQUEST.AccessStructure.User_ID,
     stForm = FORM,
     stSession = SESSION
     );
	</cfscript>
  <cfif (stError.bNameExists EQ "1")>
    <script>alert("Name already Exists");</script>
  <cfelse>
    <script>
      $.prompt( <cfoutput>"#member_alert("1", form.PGProductCategoryID)#" </cfoutput> );
    </script>
    <cfif isDefined("FORM.pageAfterSave") AND FORM.pageAfterSave EQ "2">
      <cfset FORM.Display_Type = "Product" />
      <cfset FORM.Display = "Active" />
    <cfelseif isDefined("FORM.pageAfterSave") AND FORM.pageAfterSave EQ "1">
      <cfset FORM.Display_Type = "Product" />
      <cfset FORM.Display = "Add" />
    </cfif>

        <cfset FORM.PGTypeID = "" />
        <cfset FORM.Allow_Approval_Group = "" />
        <cfset FORM.bIncludeInOthers = "0" />
        <cfset FORM.Product_List  = "" />
        <cfset FORM.GroupLevel = "" />
        <cfset FORM.GroupLevel_Name = "" />
        <cfset FORM.PGTypeID  = "" />
        <cfset FORM.PlanningGroupCode = "" />
        <cfset FORM.PlanningGroupName = "" />
        <cfset FORM.selCustomerPG = "" />
        <cfset FORM.selTypeName    = "" />
        <cfset FORM.pageAction2 = "" />
        <cfset FORM.PageAfterSave = "" />
        <cfloop index="colName" list="#FORM.fieldnames#">
          <cfif (FindNoCase("CHKBOXTEMPLATE_",colName) NEQ 0)>
            <cfset temp = StructDelete(FORM, colName) />
          </cfif>
		  <!--- When deleting the CHKBOXTEMPLATE_ field also delete the FILTERSID_ field --->
          <cfif (FindNoCase("FILTERSID_",colName) NEQ 0)>
            <cfset temp = StructDelete(FORM, colName) />
          </cfif>
        </cfloop>
        <cfif isDefined("SESSION.qryGrpProdPack")>
          <cfset tempvariable = StructDelete(SESSION,"qryGrpProdPack")>
        </cfif>
  </cfif>
</cfif>
<!--- customer Save --->
<cfif isDefined("FORM.pageAction2") AND FORM.pageAction2 EQ "CustomerAddSave">

<cfscript>
    stError = StructNew();
    stError.bNameExists = PGManager.fnAddCustomerPG(
     UserID = REQUEST.AccessStructure.User_ID,
     stForm = FORM,
      stSession = SESSION
     );

	 PGCategoryID = PGManager.getPGCategoryID(2,form.PlanningGroupName);
	</cfscript>
   <cfif (stError.bNameExists EQ "1")>
    <script>alert("Name already Exists");</script>
		<!--- <cfset FORM.display = "edit" /> --->
    <cfelse>
      <script>
        $.prompt( <cfoutput>"#member_alert("2", PGCategoryID)#" </cfoutput> );
      </script>
      <cfif isDefined("FORM.pageAfterSave") AND FORM.pageAfterSave EQ "2">
        <cfset FORM.Display_Type = "Customer" />
        <cfset FORM.Display = "Active" />

      <cfelseif isDefined("FORM.pageAfterSave") AND FORM.pageAfterSave EQ "1">
        <cfset FORM.Display_Type = "Customer" />
        <cfset FORM.Display = "Add" />
        <!--- Reset the form fields after save --->
      </cfif>
        <!---
          If this part is reached then the save was successful and hence we will
          clear out all the FORM Data that is not needed.
        --->
        <cfset FORM.PGTypeID = "" />
        <cfset FORM.Allow_Dist_Group = "" />
        <cfset FORM.bIncludeInOthers = "0" />
        <cfset FORM.DistributorGroups_List = "" />
        <cfset FORM.Distributor_List  = "" />
        <cfset FORM.GroupLevel = "" />
        <cfset FORM.GroupLevel_Name = "" />
        <cfset FORM.PGTypeID  = "" />
        <cfset FORM.PlanningGroupCode = "" />
        <cfset FORM.PlanningGroupName = "" />
        <cfset FORM.selCustomerPG = "" />

		<cfset FORM.business_segment    = "0" />

        <cfset FORM.selTypeName    = "" />
        <cfset FORM.pageAction2 = "" />
        <cfset FORM.PageAfterSave = "" />
        <cfloop index="colName" list="#FORM.fieldnames#">
          <cfif (FindNoCase("CHKBOXTEMPLATE_",colName) NEQ 0)>
            <cfset temp = StructDelete(FORM, colName) />
          </cfif>
		  <!--- When deleting the CHKBOXTEMPLATE_ field also delete the FILTERSID_ field --->
          <cfif (FindNoCase("FILTERSID_",colName) NEQ 0)>
            <cfset temp = StructDelete(FORM, colName) />
          </cfif>
        </cfloop>
        <cfif isDefined("SESSION.qryGrpDistPack") >
        <cfset tempvariable = StructDelete(SESSION,"qryGrpDistPack")>
      </cfif>
  </cfif>
</cfif>

<cfif isDefined("FORM.pageAction2") AND FindNoCase("CustomerEditSave",FORM.pageAction2) AND isDefined("FORM.pageAfterSave") AND FORM.pageAfterSave NEQ "">

<cfscript>
    stError = StructNew();
    stError.bNameExists = PGManager.fnEditCustomerPG(
     UserID = REQUEST.AccessStructure.User_ID,
     stForm = FORM,
     stSession = SESSION
     );
	</cfscript>
   <cfif (stError.bNameExists EQ "1")>
    <script>alert("Name already Exists");</script>
		<!--- <cfset FORM.display = "edit" /> --->
    <cfelse>
      <script>
        $.prompt( <cfoutput>"#member_alert("2", form.PGCustomerCategoryID)#" </cfoutput> );
      </script>
      <cfif isDefined("FORM.pageAfterSave") AND FORM.pageAfterSave EQ "2">
        <cfset FORM.Display_Type = "Customer" />
        <cfset FORM.Display = "Active" />
      <cfelseif isDefined("FORM.pageAfterSave") AND FORM.pageAfterSave EQ "1">
        <cfset FORM.Display_Type = "Customer" />
        <cfset FORM.Display = "Add" />
        <!--- Reset the form fields after save --->
      </cfif>
        <!---
          If this part is reached then the save was successful and hence we will
          clear out all the FORM Data that is not needed.
        --->
        <cfset FORM.PGTypeID = "" />
        <cfset FORM.Allow_Dist_Group = "" />
        <cfset FORM.bIncludeInOthers = "0" />
        <cfset FORM.DistributorGroups_List = "" />
        <cfset FORM.Distributor_List  = "" />
        <cfset FORM.GroupLevel = "" />
        <cfset FORM.GroupLevel_Name = "" />
        <cfset FORM.PGTypeID  = "" />
        <cfset FORM.PlanningGroupCode = "" />
        <cfset FORM.PlanningGroupName = "" />
        <cfset FORM.selCustomerPG = "" />
        <cfset FORM.selTypeName    = "" />
        <cfset FORM.pageAction2 = "" />
        <cfset FORM.PageAfterSave = "" />
        <cfloop index="colName" list="#FORM.fieldnames#">
          <cfif (FindNoCase("CHKBOXTEMPLATE_",colName) NEQ 0)>
            <cfset temp = StructDelete(FORM, colName) />
          </cfif>
		  <!--- When deleting the CHKBOXTEMPLATE_ field also delete the FILTERSID_ field --->
          <cfif (FindNoCase("FILTERSID_",colName) NEQ 0)>
            <cfset temp = StructDelete(FORM, colName) />
          </cfif>
        </cfloop>
        <cfif isDefined("SESSION.qryGrpDistPack") >
        <cfset tempvariable = StructDelete(SESSION,"qryGrpDistPack")>
      </cfif>
  </cfif>
</cfif>

<!--- *********************** Operator Save Starts *********************** --->

<cfif isDefined("FORM.pageAction2") AND FORM.pageAction2 EQ "OperatorAddSave">
  <cfscript>
    stError = StructNew();
    stError.bNameExists = PGManager.fnAddOperatorPG(
     UserID = REQUEST.AccessStructure.User_ID,
     stForm = FORM,
     stSession = SESSION
     );

	 PGCategoryID = PGManager.getPGCategoryID(3,form.PlanningGroupName);
	</cfscript>
  <cfif (stError.bNameExists EQ "1")>
    <script>alert("Name already Exists");</script>
  <cfelse>
    <script>
      $.prompt( <cfoutput>"#member_alert("3", PGCategoryID)#" </cfoutput> );
    </script>
    <cfif isDefined("FORM.pageAfterSave") AND FORM.pageAfterSave EQ "2">
      <cfset FORM.Display_Type = "Operator" />
      <cfset FORM.Display = "Active" />
    <cfelseif isDefined("FORM.pageAfterSave") AND FORM.pageAfterSave EQ "1">
      <cfset FORM.Display_Type = "Operator" />
      <cfset FORM.Display = "Add" />
    </cfif>

        <cfset FORM.PGTypeID = "" />
        <cfset FORM.Allow_Operator_Group = "" />
        <cfset FORM.bIncludeInOthers = "0" />
        <cfset FORM.Operator_List  = "" />
        <cfset FORM.GroupLevel = "" />
        <cfset FORM.GroupLevel_Name = "" />
        <cfset FORM.PlanningGroupCode = "" />
        <cfset FORM.PlanningGroupName = "" />
        <cfset FORM.selCustomerPG = "" />
        <cfset FORM.selTypeName    = "" />
        <cfset FORM.pageAction2 = "" />
        <cfset FORM.PageAfterSave = "" />
        <cfloop index="colName" list="#FORM.fieldnames#">
          <cfif (FindNoCase("CHKBOXTEMPLATE_",colName) NEQ 0)>
            <cfset temp = StructDelete(FORM, colName) />
          </cfif>
		  <!--- When deleting the CHKBOXTEMPLATE_ field also delete the FILTERSID_ field --->
          <cfif (FindNoCase("FILTERSID_",colName) NEQ 0)>
            <cfset temp = StructDelete(FORM, colName) />
          </cfif>
        </cfloop>
        <cfif isDefined("SESSION.qryGrpOperatorPack")>
          <cfset tempvariable = StructDelete(SESSION,"qryGrpOperatorPack")>
        </cfif>
  </cfif>
</cfif>

<cfif isDefined("FORM.pageAction2") AND FORM.pageAction2 EQ "OperatorEditSave">
  <cfscript>
    stError = StructNew();
    stError.bNameExists = PGManager.fnEditOperatorPG(
     UserID = REQUEST.AccessStructure.User_ID,
     stForm = FORM,
     stSession = SESSION
     );
	</cfscript>
  <cfif (stError.bNameExists EQ "1")>
    <script>alert("Name already Exists");</script>
		<!--- <cfset FORM.display = "edit" /> --->
  <cfelse>
    <script>
      $.prompt( <cfoutput>"#member_alert("3", form.PGOperatorCategoryID)#" </cfoutput> );
    </script>
    <cfif isDefined("FORM.pageAfterSave") AND FORM.pageAfterSave EQ "2">
      <cfset FORM.Display_Type = "Operator" />
      <cfset FORM.Display = "Active" />
    <cfelseif isDefined("FORM.pageAfterSave") AND FORM.pageAfterSave EQ "1">
      <cfset FORM.Display_Type = "Operator" />
      <cfset FORM.Display = "Add" />
    </cfif>

        <cfset FORM.Allow_Operator_Group = "" />
        <cfset FORM.bIncludeInOthers = "0" />
        <cfset FORM.Operator_List  = "" />
        <cfset FORM.GroupLevel = "" />
        <cfset FORM.GroupLevel_Name = "" />
        <cfset FORM.PGTypeID  = "" />
        <cfset FORM.PlanningGroupCode = "" />
        <cfset FORM.PlanningGroupName = "" />
        <cfset FORM.selCustomerPG = "" />
        <cfset FORM.selTypeName    = "" />
        <cfset FORM.pageAction2 = "" />
        <cfset FORM.PageAfterSave = "" />
        <cfloop index="colName" list="#FORM.fieldnames#">
          <cfif (FindNoCase("CHKBOXTEMPLATE_",colName) NEQ 0)>
            <cfset temp = StructDelete(FORM, colName) />
          </cfif>
		  <!--- When deleting the CHKBOXTEMPLATE_ field also delete the FILTERSID_ field --->
          <cfif (FindNoCase("FILTERSID_",colName) NEQ 0)>
            <cfset temp = StructDelete(FORM, colName) />
          </cfif>
        </cfloop>
        <cfif isDefined("SESSION.qryGrpOperatorPack")>
          <cfset tempvariable = StructDelete(SESSION,"qryGrpOperatorPack")>
        </cfif>
  </cfif>
</cfif>

<!--- ************************* Operator Save Ends ************************* --->

<!---****************************** END DISPLAY ***********************************--->


<cfparam name ="url.type" default="">
<cfparam name ="url.deactivate" default="0">
<cfparam name ="url.activate" default="0">
<cfparam name ="url.deleted" default="0">
<cfparam name ="url.subtype" default="">
<cfif url.type EQ "Product" AND len(url.subtype) EQ 0>
	<cfset FORM.display_type = "Product">
	<cfset form.display = "Active">
<cfelseif url.type EQ "Product" AND  url.subtype EQ "edit" >
	<cfset FORM.display_type = "Product">
	<cfset FORM.display = "Edit">
	<cfset FORM.PGProductCategoryID = #trim(url.ID)#>
	<cfset FORM.OrderByField = #Trim(URL.OrderByField)# />
	<cfset FORM.OrderBy		 = #Trim(URL.OrderBy)# />
	<cfset FORM.MemSearchKeyword = #Trim(URL.memSearchKeyword)# />
</cfif>

<cfif url.type EQ "Type" AND len(url.subtype) EQ 0>
	<cfset FORM.display_type = "Type">
	<cfset form.display = "Active">
<cfelseif url.type EQ "Type" AND  url.subtype EQ "edit" >
	<cfset FORM.display_type = "Type">
	<cfset FORM.display = "Edit">
	<cfset FORM.PGTypeID = #trim(url.ID)#>
	<cfset FORM.TmpltSearchKeyword = #trim(URL.tmpltSearchKeyword)#>
	<cfset Form.TemplateExpanded = "#URL.TemplateExpanded#">
</cfif>

<cfif url.type EQ "Customer" AND len(url.subtype) EQ 0>
	<cfset FORM.display_type = "Customer">
	<cfset form.display = "Active">
<cfelseif url.type EQ "Customer" AND  url.subtype EQ "edit" >
	<cfset FORM.display_type = "Customer">
	<cfset FORM.display = "Edit">
	<cfset FORM.PGCustomerCategoryID = #trim(url.ID)#>
	<cfset FORM.OrderByField = #Trim(URL.OrderByField)# />
	<cfset FORM.OrderBy		 = #Trim(URL.OrderBy)# />
	<cfset FORM.MemSearchKeyword = #Trim(URL.memSearchKeyword)# />
</cfif>

<cfif url.type EQ "Operator" AND len(url.subtype) EQ 0>
	<cfset FORM.display_type = "Operator">
	<cfset form.display = "Active">
<cfelseif url.type EQ "Operator" AND  url.subtype EQ "edit" >
	<cfset FORM.display_type = "Operator">
	<cfset FORM.display = "Edit">
	<cfset FORM.PGOperatorCategoryID = #trim(url.ID)#>
	<cfset FORM.OrderByField = #Trim(URL.OrderByField)# />
	<cfset FORM.OrderBy		 = #Trim(URL.OrderBy)# />
	<cfset FORM.MemSearchKeyword = #Trim(URL.memSearchKeyword)# />
</cfif>

<!--- D33532:Planning Group Research tools --->
<cfif url.type EQ "Research" AND len(url.subtype) GT 0>
	<cfset FORM.display_type = "Research">
	<cfset FORM.display = #trim(url.subtype)#>
</cfif>
<!--- D33532:Planning Group Research tools --->

<cfinclude template="_pg_header.cfm" />
<FORM ACTION="index.cfm" METHOD="post" NAME="DataForm" id="df32">
<input type="hidden" name="pg_type18" value="">
<input type="hidden" name="checkBoxName" value="">

<cfscript>
	PGManager = CreateObject("component","components.settings.PlanningGroups.PlanningGroupsManager");
</cfscript>
<!--- <cfdump var="#form#"> --->
<cfif FORM.command EQ "deActType">
  <cfif isDefined("FORM.chkPGTypeID")>
	  <cfscript>
		  PGManager.deactivateType(FORM.chkPGTypeID);
	  </cfscript>
	  <cflocation url="index.cfm">
  <cfelse>
    <cfif (isDefined("FORM.PGTypeID") AND FORM.PGTypeID NEQ "")>
	    <cfscript>
		    PGManager.deactivateType(FORM.PGTypeID);
	    </cfscript>
	  <cflocation url="index.cfm">
    </cfif>
  </cfif>
<cfelseif FORM.command EQ "actType">
  <cfif isDefined("FORM.chkPGTypeID")>
	  <cfscript>
  	  PGManager.activateType(FORM.chkPGTypeID);
	  </cfscript>
	  <cflocation url="index.cfm">
  <cfelse>
    <cfif (isDefined("FORM.PGTypeID") AND FORM.PGTypeID NEQ "")>
  	  <cfscript>
		    PGManager.activateType(FORM.PGTypeID);
	    </cfscript>
	  <cflocation url="index.cfm">
    </cfif>
  </cfif>
<cfelseif (FORM.command EQ "delType" AND  isDefined("FORM.PGTypeID") AND FORM.PGTypeID NEQ "")>
  	<cfscript>
		  PGManager.delType(FORM.PGTypeID);
	  </cfscript>
	  <cflocation url="index.cfm">
<cfelseif (FORM.command EQ "actProduct")>
  <cfif isDefined("FORM.chkPGProductCatID")>
      <cfscript>
    	  PGManager.activateProductPG(FORM.chkPGProductCatID);
    	</cfscript>
    <cfelse>
      <cfif (isDefined("FORM.PGProductCatID") AND FORM.PGProductCatID NEQ "")>
      	<cfscript>
    		  PGManager.activateProductPG(FORM.PGProductCatID);
    	  </cfscript>
      </cfif>
   </cfif>

<cfelseif (FORM.command EQ "deActProduct")>
  <cfif isDefined("FORM.chkPGProductCatID")>
      <cfscript>
    	  PGManager.deActivateProductPG(FORM.chkPGProductCatID);
    	</cfscript>
    <cfelse>
      <cfif (isDefined("FORM.PGProductCatID") AND FORM.PGProductCatID NEQ "")>
      	<cfscript>
    		  PGManager.deActivateProductPG(FORM.PGProductCatID);
    	  </cfscript>
      </cfif>
   </cfif>
<cfelseif (FORM.command EQ "delProductPG" AND isDefined("FORM.PGProductCatID") AND FORM.PGProductCatID NEQ "")>
  	<cfscript>
		  PGManager.delProductPG(FORM.PGProductCatID);
	  </cfscript>

<cfelseif (FORM.command EQ "actCustomer")>
  <cfif isDefined("FORM.chkPGCustomerCatID")>
    <cfscript>
  	  PGManager.activateCustomerPG(FORM.chkPGCustomerCatID);
  	</cfscript>
  <cfelse>
    <cfif (isDefined("FORM.PGCustomerCatID") AND FORM.PGCustomerCatID NEQ "")>
    	<cfscript>
  		  PGManager.activateCustomerPG(FORM.PGCustomerCatID);
  	  </cfscript>
    </cfif>
 </cfif>
<cfelseif (FORM.command EQ "deActCustomer")>
  <cfif isDefined("FORM.chkPGCustomerCatID")>
    <cfscript>
  	  PGManager.deActivateCustomerPG(FORM.chkPGCustomerCatID);
  	</cfscript>
  <cfelse>
    <cfif (isDefined("FORM.PGCustomerCatID") AND FORM.PGCustomerCatID NEQ "")>
    	<cfscript>
  		  PGManager.deActivateCustomerPG(FORM.PGCustomerCatID);
  	  </cfscript>
    </cfif>
 </cfif>
<cfelseif (FORM.command EQ "delCustomerPG" AND isDefined("FORM.PGCustomerCatID") AND FORM.PGCustomerCatID NEQ "")>
  	<cfscript>
		  PGManager.delCustomerPG(FORM.PGCustomerCatID);
	  </cfscript>

<!--- Operator function --->
    <cfelseif (FORM.command EQ "actOperator")>
  <cfif isDefined("FORM.chkPGOperatorCatID")>
    <cfscript>
  	  PGManager.activateOperatorPG(FORM.chkPGOperatorCatID);
  	</cfscript>
  <cfelse>
    <cfif (isDefined("FORM.PGOperatorCatID") AND FORM.PGOperatorCatID NEQ "")>
    	<cfscript>
  		  PGManager.activateOperatorPG(FORM.PGOperatorCatID);
  	  </cfscript>
    </cfif>
 </cfif>
<cfelseif (FORM.command EQ "deActOperator")>
  <cfif isDefined("FORM.chkPGOperatorCatID")>
    <cfscript>
  	  PGManager.deActivateOperatorPG(FORM.chkPGOperatorCatID);
  	</cfscript>
  <cfelse>
    <cfif (isDefined("FORM.PGOperatorCatID") AND FORM.PGOperatorCatID NEQ "")>
    	<cfscript>
  		  PGManager.deActivateOperatorPG(FORM.PGOperatorCatID);
  	  </cfscript>
    </cfif>
 </cfif>
<cfelseif (FORM.command EQ "delOperatorPG" AND isDefined("FORM.PGOperatorCatID") AND FORM.PGOperatorCatID NEQ "")>
  	<cfscript>
		  PGManager.delOperatorPG(FORM.PGOperatorCatID);
	  </cfscript>

</cfif>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cfparam name="form.display" default="">
<cfif form.display eq "add">
	<style>
		table td {
			padding:3px 6px 3px 3px;
		}
		div#WithPG {
			margin-bottom: 4px;
		}
		div#WithPG + span {
			display: inline-block;
			margin-right: 15px;
		}
		fieldset#border_2, fieldset#border_3 {
			margin-bottom: 10px;
		}
	</style>
</cfif>

<cfif FORM.display_Type EQ "Type">
  <cfswitch expression="#FORM.display#">
    <cfcase value="add">
			<cfif isDefined("FORM.TypeRefresh") AND FORM.TypeRefresh EQ "0">
				<cfset FORM.TypeID = "" />
				<cfset FORM.TypeName = "" />
			  <cfloop index="colName" list="#FORM.fieldnames#">
			    <cfif (FindNoCase("chkBoxSearch_",colName) NEQ 0)>
			      <cfset temp = StructDelete(FORM, colName) />
			    </cfif>
			     <cfif (FindNoCase("chkBoxGroup_",colName) NEQ 0)>
			       <cfset temp = StructDelete(FORM, colName) />
			     </cfif>
			  </cfloop>
				<cfset FORM.rdoTypeCategory= ""/>
			</cfif>

  		<cfinclude template="_pg_type_add.cfm" />
  	</cfcase>
    <cfcase value="active,inactive">
      <cfif isDefined("SESSION.qryGrpProdPack") >
        <cfset tempvariable = StructDelete(SESSION,"qryGrpProdPack")>
      </cfif>
      <cfif isDefined("SESSION.qryGrpDistPack") >
        <cfset tempvariable = StructDelete(session,"qryGrpDistPack")>
      </cfif>
      <cfif isDefined("SESSION.qryGrpOperatorPack") >
        <cfset tempvariable = StructDelete(session,"qryGrpOperatorPack")>
      </cfif>
      		<cfif #FORM.display# EQ "Active">
				<cfset active = 1>
			<cfelseif #FORM.display# EQ "InActive">
				<cfset active = 0>
			</cfif>
     <div style="margin:10px;">
     <cfinclude template="Type_PG.cfm" />
	 </div>
      <!---<cfinclude template="_pg_type_display.cfm" />--->
  	</cfcase>
    <cfcase value="edit">
  		<cfinclude template="_pg_type_edit.cfm" />
  	</cfcase>
  </cfswitch>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cfelseif FORM.display_Type EQ "Product">
<cfset qGetTopLevelGroups = GroupDataManager.getProductGroupsData() />
<cfswitch expression="#FORM.display#">
	<cfcase value="active,inActive">
    <cfif isDefined("SESSION.qryGrpProdPack") >
      <cfset tempvariable = StructDelete(SESSION,"qryGrpProdPack")>
    </cfif>
    <cfif isDefined("SESSION.qryGrpDistPack") >
      <cfset tempvariable = StructDelete(session,"qryGrpDistPack")>
    </cfif>
    <cfif isDefined("SESSION.qryGrpOperatorPack") >
      <cfset tempvariable = StructDelete(session,"qryGrpOperatorPack")>
    </cfif>

		<!---<cfinclude template="_pg_product_display.cfm" />--->
			<cfif #FORM.display# EQ "Active">
				<cfset active = 1>
			<cfelseif #FORM.display# EQ "InActive">
				<cfset active = 0>
			</cfif>
		<div style="margin:10px;">
	 	 <cfinclude template="product_pg.cfm"/>
		</div>
	</cfcase>
  <cfcase value="add">
    <cfset FORM.PGClassificationID = "" />
    <cfif (NOT isDefined("FORM.productRefresh"))> <!--- OR (isDefined("FORM.productRefresh") AND FORM.productRefresh EQ "0") --->
      <cfset FORM.PGTypeID = "" />
      <cfset FORM.Allow_Approval_Group = "" />
      <cfset FORM.Allow_Operator_Group = "" />
      <cfset FORM.bIncludeInOthers = "0" />
      <cfset FORM.DistributorGroups_List = "" />
      <cfset FORM.Distributor_List  = "" />
      <cfset FORM.GroupLevel = "" />
      <cfset FORM.GroupLevel_Name = "" />
      <cfset FORM.PGTypeID  = "" />
      <cfset FORM.PlanningGroupCode = "" />
      <cfset FORM.PlanningGroupName = "" />
      <cfset FORM.selCustomerPG = "" />
      <cfset FORM.selTypeName    = "" />
      <cfloop index="colName" list="#FORM.fieldnames#">
        <cfif (FindNoCase("CHKBOXTEMPLATE_",colName) NEQ 0)>
          <cfset temp = StructDelete(FORM, colName) />
        </cfif>
		  <!--- When deleting the CHKBOXTEMPLATE_ field also delete the FILTERSID_ field --->
          <cfif (FindNoCase("FILTERSID_",colName) NEQ 0)>
            <cfset temp = StructDelete(FORM, colName) />
          </cfif>
      </cfloop>

      <cfset FORM.TEMPLATE_SELECT = ""/>
      <cfset FORM.PRODUCT_LIST = ""/>
      <cfset FORM.PGTypeID = ""/>
      <cfset FORM.GROUPLEVEL = ""/>
      <cfset FORM.ALLOW_APPROVAL_GROUP = ""/>
      <cfset FORM.ALLOW_OPERATOR_GROUP = "" />
      <cfset FORM.productRefresh = "1" />
      <cfset StructDelete(Session, "FormData")>
    </cfif>
  	<cfinclude template="_pg_product_add.cfm" />
	</cfcase>
	<cfcase value="edit">
  <cfset FORM.PGClassificationID = "" />
    <cfif (NOT isDefined("FORM.productRefresh"))> <!--- OR (isDefined("FORM.productRefresh") AND FORM.productRefresh EQ "0") --->
      <cfset FORM.TEMPLATE_SELECT = ""/>
      <cfset FORM.PGTypeID = ""/>
      <cfif NOT isDefined("FORM.GROUPLEVEL")>
        <cfset FORM.GroupLevel = "" />
      </cfif>
      <cfif NOT isDefined("FORM.ALLOW_APPROVAL_GROUP")>
        <cfset FORM.ALLOW_APPROVAL_GROUP = "" />
      </cfif>
      <cfif NOT isDefined("FORM.PRODUCT_LIST")>
        <cfset FORM.PRODUCT_LIST = "" />
      </cfif>
      <cfset FORM.productRefresh = "1" />
      <cfset StructDelete(Session, "FormData")>
    </cfif>
		<cfinclude template="_pg_product_edit.cfm" />
	</cfcase>
</cfswitch>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cfelseif FORM.display_Type EQ "Customer">

<cfswitch expression="#FORM.display#">
	<cfcase value="active,inActive">
    <cfif isDefined("SESSION.qryGrpProdPack") >
      <cfset tempvariable = StructDelete(SESSION,"qryGrpProdPack")>
    </cfif>
    <cfif isDefined("SESSION.qryGrpDistPack") >
      <cfset tempvariable = StructDelete(session,"qryGrpDistPack")>
    </cfif>
      <cfif isDefined("SESSION.qryGrpOperatorPack") >
        <cfset tempvariable = StructDelete(session,"qryGrpOperatorPack")>
      </cfif>

      		<cfif #FORM.display# EQ "Active">
				<cfset active = 1>
			<cfelseif #FORM.display# EQ "InActive">
				<cfset active = 0>
			</cfif>
		<div style="margin:10px;">
	 	<cfinclude template="customer_pg.cfm"/>
		</div>
		<!---<cfinclude template="_pg_customer_display.cfm" />--->
	</cfcase>
  <cfcase value="add">
    <cfif (NOT isDefined("FORM.DistributorRefresh"))>
      <cfset FORM.PGTypeID = "" />
      <cfset FORM.Allow_Dist_Group = "" />
      <cfset FORM.bIncludeInOthers = "0" />
      <cfset FORM.DistributorGroups_List = "" />
      <cfset FORM.Distributor_List  = "" />
      <cfset FORM.GroupLevel = "" />
      <cfset FORM.GroupLevel_Name = "" />
      <cfset FORM.PGTypeID  = "" />
      <cfset FORM.PlanningGroupCode = "" />
      <cfset FORM.PlanningGroupName = "" />
      <cfset FORM.selCustomerPG = "" />
      <cfset FORM.selTypeName    = "" />
      <cfloop index="colName" list="#FORM.fieldnames#">
        <cfif (FindNoCase("CHKBOXTEMPLATE_",colName) NEQ 0)>
          <cfset temp = StructDelete(FORM, colName) />
        </cfif>
  		<!--- When deleting the CHKBOXTEMPLATE_ field also delete the FILTERSID_ field --->
        <cfif (FindNoCase("FILTERSID_",colName) NEQ 0)>
          <cfset temp = StructDelete(FORM, colName) />
        </cfif>
      </cfloop>
      <cfset FORM.TEMPLATE_SELECT = ""/>
      <cfset FORM.PRODUCT_LIST = ""/>
      <cfset FORM.GROUPLEVEL = ""/>
      <cfset FORM.ALLOW_DIST_GROUP = ""/>
      <cfset FORM.productRefresh = "1" />
      <cfset StructDelete(Session, "FormData")>
    </cfif>
  	<cfinclude template="_pg_customer_add.cfm" />
	</cfcase>
	<cfcase value="edit">
      <cfset FORM.TEMPLATE_SELECT = ""/>
      <cfset FORM.PRODUCT_LIST = ""/>
     <cfif NOT isDefined("FORM.GROUPLEVEL")>
        <cfset FORM.GroupLevel = "" />
      </cfif>
      <cfif NOT isDefined("FORM.ALLOW_DIST_GROUP")>
        <cfset FORM.ALLOW_DIST_GROUP = "" />
      </cfif>
      <cfset FORM.productRefresh = "1" />
      <cfset FORM.DistributorRefresh = "1" />
      <cfset StructDelete(Session, "FormData")>

		<cfinclude template="_pg_customer_edit.cfm" />
	</cfcase>
</cfswitch>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cfelseif FORM.display_Type EQ "Operator">
    <cfif isDefined("SESSION.qryGrpProdPack") >
      <cfset tempvariable = StructDelete(SESSION,"qryGrpProdPack")>
    </cfif>
    <cfif isDefined("SESSION.qryGrpDistPack") >
      <cfset tempvariable = StructDelete(session,"qryGrpDistPack")>
    </cfif>
<cfswitch expression="#FORM.display#">
  <cfcase value="active,inActive">
       		<cfif #FORM.display# EQ "Active">
				<cfset active = 1>
			<cfelseif #FORM.display# EQ "InActive">
				<cfset active = 0>
			</cfif>
			<div style="margin:10px;">
  	  			<cfinclude template="operator_pg.cfm"/>
			</div>
		<!---<cfinclude template="_pg_operator_display.cfm" />--->
	</cfcase>

  <cfcase value="add">
    <cfset FORM.PGTypeID = "" />
    <cfif (NOT isDefined("FORM.operatorRefresh"))>
 			<cfset FORM.PGTypeID = "" />
      <cfset FORM.Allow_Operator_Group = "" />
      <cfset FORM.bIncludeInOthers = "0" />
      <cfset FORM.Operator_List  = "" />
      <cfset FORM.GroupLevel = "" />
      <cfset FORM.GroupLevel_Name = "" />
      <cfset FORM.PGTypeID  = "" />
      <cfset FORM.PlanningGroupCode = "" />
      <cfset FORM.PlanningGroupName = "" />
      <cfset FORM.selCustomerPG = "" />
			<cfset FORM.GroupLevel1 = "" />
			<cfset FORM.GroupLevel2 = "" />
      <cfset FORM.selTypeName    = "" />

		  <cfset FORM.TEMPLATE_SELECT = ""/>
      <cfset FORM.PRODUCT_LIST = ""/>
      <cfset FORM.PGTypeID = ""/>
      <cfset FORM.GROUPLEVEL = ""/>
      <cfset FORM.Allow_Operator_Group = ""/>
      <cfset FORM.productRefresh = "1" />
      <cfset FORM.operatorRefresh = "1" />
      <cfset StructDelete(Session, "FormData")>
    </cfif>
  	<cfinclude template="_pg_operator_add.cfm" />
	</cfcase>
	<cfcase value="edit">
      <cfset FORM.TEMPLATE_SELECT = ""/>
     <cfif NOT isDefined("FORM.GROUPLEVEL")>
        <cfset FORM.GroupLevel = "" />
      </cfif>
      <cfif NOT isDefined("FORM.ALLOW_DIST_GROUP")>
        <cfset FORM.ALLOW_DIST_GROUP = "" />
      </cfif>
      <cfif NOT isDefined("FORM.Operator_List")>
        <cfset FORM.Operator_List = "" />
      </cfif>
      <cfset FORM.productRefresh = "1" />
      <cfset FORM.DistributorRefresh = "1" />
      <cfset FORM.OperatorRefresh = "1" />
      <cfset StructDelete(Session, "FormData")>
		<cfinclude template="_pg_operator_edit.cfm" />
	</cfcase>
</cfswitch>
<!--- D33532:Planning Group Research tools --->
<cfelseif FORM.display_Type EQ "Research">
<cfswitch expression="#FORM.display#">
	<cfcase value="membership">
		<div style="margin:10px;">
			<cfinclude template="pg_no_members.cfm">
		</div>
	</cfcase>
	<cfcase value="volume">
		<div style="margin:10px;">
			<cfinclude template="volume_forecast_duplicates.cfm">
		</div>
	</cfcase>
	<cfcase value="accrual">
		<div style="margin:10px;">
			<cfinclude template="accrual_budget_duplicates.cfm">
		</div>
	</cfcase>
	<cfcase value="segment">
		<div style="margin:10px;">
			<cfinclude template="Program_Segment_Aligment.cfm">
		</div>
	</cfcase>
</cfswitch>
<!--- D33532:Planning Group Research tools --->
</cfif>
<cfoutput>
<!---hidden FORM fields--->



<input name="display" type="hidden" value="#FORM.display#" />
<input name="display_type" type="hidden" value="#FORM.display_type#" />
<input name="command" type="hidden" value="#FORM.command#" />
<input name="pageAction2" type="hidden" value="#FORM.pageAction2#" />

<input type="hidden" name="pageAfterSave" value="" />

<INPUT type="Hidden" name="sort_by" value="#FORM.sort_by#">
<!---<INPUT type="Hidden" name="sort_Order" value="#FORM.sort_Order#">  --->
<INPUT type="Hidden" name="New_Sort_Order" value="#New_Sort_Order#">
<INPUT type="Hidden" name="templateExpanded" value="#FORM.templateExpanded#">


<cfif isDefined("FORM.PGTypeID")>
  <cfif (FORM.PGTypeID EQ "") AND IsDefined("FORM.SelTypeName") AND FORM.SelTypeName NEQ "0">
    <input name="PGTypeID" type="hidden" value="#FORM.SelTypeName#" />
  <cfelse>
    <input name="PGTypeID" type="hidden" value="#FORM.PGTypeID#" />
  </cfif>
<cfelse>
  <input name="PGTypeID" type="hidden" value="" />
</cfif>

<cfif isDefined("FORM.PGProductCategoryID") AND FORM.PGProductCategoryID NEQ "">
  <input name="PGProductCategoryID" type="hidden" value="#FORM.PGProductCategoryID#" />
<cfelse>
  <input name="PGProductCategoryID" type="hidden" value="" />
</cfif>

<cfif isDefined("FORM.PGCustomerCategoryID") AND FORM.PGCustomerCategoryID NEQ "">
  <input name="PGCustomerCategoryID" type="hidden" value="#FORM.PGCustomerCategoryID#" />
<cfelse>
  <input name="PGCustomerCategoryID" type="hidden" value="" />
</cfif>
<cfif isDefined("FORM.PGOperatorCategoryID") AND FORM.PGOperatorCategoryID NEQ "">
  <input name="PGOperatorCategoryID" type="hidden" value="#FORM.PGOperatorCategoryID#" />
<cfelse>
  <input name="PGOperatorCategoryID" type="hidden" value="" />
</cfif>

<input name="returnTo" type="hidden" value="#FORM.returnTo#"/>
</cfoutput>
</FORM>

<!--- post to an intermediate page where it displays a processing message and resubmit the form (defined in _planning_groups.js & stored in form.actualPage) --->
<!--- <form name="exportByGroupsForm" action="/common_files/processing.cfm?gathering" method="post" style="display:none;"> </form> --->



<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  31191 - added logic to update options in Search Products dropdown
          based on "include in other pg" & "master groups only"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cfif FORM.display_Type EQ "Product">
  <cfif (FORM.display eq "add" or FORM.display eq "edit") and IsDefined("prod.masterSystem")>
    <!--- <cfinclude template="/common_files/jQuery.cfm"> --->
    <script>
      var refreshProducts = function () {
        var new_options = '';

        <!--- when "include in other pg" is checked - show master only --->
        if ($('#bIncludeInOthers').is(':checked')) {
          new_options = prod_master;
        }
        <!--- when "include in other pg" is unchecked &
              "master groups only" is checked - show master & system pg --->
        else if ($('#bMasterGroupOnly').is(':checked')) {
          new_options = prod_masterSystem;
        }
        <!--- when "include in other pg" is unchecked &
              "master groups only" is unchecked - show all  --->
        else {
          new_options = prod_all;
        }

        $('#GroupLevel1 option').remove();          // delete existing options
        $(new_options).appendTo('#GroupLevel1');      // add new options
      }

      <!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        prod.all ( product options for all )
        prod.master ( master product groups only )
        prod.system ( system planning groups only )
        prod.masterSystem ( master groups & system planning groups )
          are defined in:
            1. \settings\Planning_Groups\_pg_product_add.cfm
            2. \settings\Planning_Groups\_pg_product_edit.cfm
        Convert these into js variables so they can be used in refreshProducts()
      :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
      <cfoutput>
      var #toScript(prod.all, "prod_all")#;
      var #toScript(prod.master, "prod_master")#;
      var #toScript(prod.system, "prod_system")#;
      var #toScript(prod.masterSystem, "prod_masterSystem")#;
      </cfoutput>

      refreshProducts();    <!--- display initial options for Search Products --->
      <!--- when either "include in other pg" or "master groups only" is changed
            update the options in Search Products dropdown --->
      $('#bIncludeInOthers, #bMasterGroupOnly').change( function(e) { refreshProducts(); });
    </script>
  </cfif>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cfelseif FORM.display_Type EQ "Customer">
  <cfif (FORM.display eq "add" or FORM.display eq "edit") and IsDefined("cust.masterSystem")>
    <!--- <cfinclude template="/common_files/jQuery.cfm"> --->
    <script>
      var refreshCustomers = function () {
        var new_options = '';

        <!--- when "include in other pg" is checked - show master only --->
        if ($('#bIncludeInOthers').is(':checked')) {
          new_options = cust_master;

        }
        <!--- when "include in other pg" is unchecked &
              "master groups only" is checked - show master & system pg --->
        else if ($('#bMasterGroupOnly').is(':checked')) {
          new_options = cust_masterSystem;
        }
        <!--- when "include in other pg" is unchecked &
              "master groups only" is unchecked - show all  --->
        else {
          new_options = cust_all;
        }

        //console.log('new_options=' + new_options);

        $('#GroupLevel1 option').remove();          // delete existing options
        $(new_options).appendTo('#GroupLevel1');      // add new options
      }

      <!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        cust.all ( distributor options for all )
        cust.master ( master distributor groups only )
        cust.system ( system planning groups only )
        cust.masterSystem ( master groups & system planning groups )
          are defined in:
            1. \settings\Planning_Groups\_pg_customer_add.cfm
            2. \settings\Planning_Groups\_pg_customer_edit.cfm
        Convert these into js variables so they can be used in refreshCustomers()
      :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
      <cfoutput>
      var #toScript(cust.all, "cust_all")#;
      var #toScript(cust.master, "cust_master")#;
      var #toScript(cust.system, "cust_system")#;
      var #toScript(cust.masterSystem, "cust_masterSystem")#;
      </cfoutput>

      refreshCustomers();    <!--- display initial options for Search Distributors --->
      <!--- when either "include in other pg" or "master groups only" is changed
            update the options in Search Products dropdown --->
      $('#bIncludeInOthers, #bMasterGroupOnly').change( function(e) { refreshCustomers(); });
    </script>
  </cfif>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cfelseif FORM.display_Type EQ "Operator">
  <cfif (FORM.display eq "add" or FORM.display eq "edit") and IsDefined("oprt.masterSystem")>
    <!--- <cfinclude template="/common_files/jQuery.cfm"> --->
    <script>
      var refreshOperators = function () {
        var new_options = '';

        <!--- when "include in other pg" is checked - show master only --->
        if ($('#bIncludeInOthers').is(':checked')) {
          new_options = oprt_master;
        }
        <!--- when "include in other pg" is unchecked &
              "master groups only" is checked - show master & system pg --->
        else if ($('#bMasterGroupOnly').is(':checked')) {
          new_options = oprt_masterSystem;
        }
        <!--- when "include in other pg" is unchecked &
              "master groups only" is unchecked - show all  --->
        else {
          new_options = oprt_all;
        }

        //console.log('new_options=' + new_options);

        $('#GroupLevel1 option').remove();          // delete existing options
        $(new_options).appendTo('#GroupLevel1');      // add new options
      }

      <!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        oprt.all ( distributor options for all )
        oprt.master ( master distributor groups only )
        oprt.system ( system planning groups only )
        oprt.masterSystem ( master groups & system planning groups )
          are defined in:
            1. \settings\Planning_Groups\_pg_operator_add.cfm
            2. \settings\Planning_Groups\_pg_operator_edit.cfm
        Convert these into js variables so they can be used in refreshOperators()
      :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
      <cfoutput>
      var #toScript(oprt.all, "oprt_all")#;
      var #toScript(oprt.master, "oprt_master")#;
      var #toScript(oprt.system, "oprt_system")#;
      var #toScript(oprt.masterSystem, "oprt_masterSystem")#;
      </cfoutput>

      refreshOperators();    <!--- display initial options for Search Distributors --->
      <!--- when either "include in other pg" or "master groups only" is changed
            update the options in Search Products dropdown --->
      $('#bIncludeInOthers, #bMasterGroupOnly').change( function(e) { refreshOperators(); });

    </script>
  </cfif>
</cfif>
<cfset jQueryUI.version = "1.8.23">
<cfinclude template="/common_files/jQuery.cfm">

<script>
	$('input[name=PG_Effective_Start_Date]').datepicker();
	$('input[name=PG_Effective_End_Date]').datepicker();
 	$( ".EffDate" ).datepicker();
</script>
<cfset request.focusHiLightOff = true>
<cf_include files="/script/javascript/jquery.noty.packaged.min.js">
</body>
</html>
