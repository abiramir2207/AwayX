<!---------------------------------------------------------------------------------------------------------------------
      Template: \CustomTags\layout.cfm
      Date:     2012 July
      Author:   Chris Nguyen
      Purpose:  Layout template for web pages.
                This displays Forge heading with user name, timestamp & home page icons on the right side.
                It loads jQuery, displays horizontal menu below Forge heading.

      Remarks:  'layoutID' parameter identifies values to be used on page title and on horizontal menu.

	                For new layoutID you will need to:

	                a.  Specify page title & put it in 'page_title' variable
	                b.  Specify menu links & put them in 'menus' array of structures
	                      * text = required, string value to be displayed in the menu
	                      * href = required only when onclick is not defined
	                      * onclick = required only when href is not defined

	              'selectedIndex' optional parameter - identifies the current selected option, use this when href is
	                 not available and onclick is used. It is a numeric value and is a JavaScript array index
	                 ( e.g. for 1st position pass 0, 2nd position pass in 1 )
---------------------------------------------------------------------------------------------------------------------->
<cfif thisTag.executionMode is "start"><!DOCTYPE HTML>
<html>
<head>
<cfif attributes.layoutID eq "reProcess">
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</cfif>
<cfsilent>
<cfparam name="attributes.layoutID" default="">                 <!---value is required--->
<cfparam name="attributes.selectedIndex" default="">            <!---value is required when onclick is used and href is not--->
<cfparam name="attributes.jQueryNoConflict" default="">         <!---pass any non-blank value to resolve conflicts with prototype.js --->

<cfswitch expression="#attributes.layoutID#">
  <!--------------------------------->
  <!--- settings - default vendor --->
  <!--------------------------------->
  <cfcase value="defaultVendor">
    <cfset menus = [  { text="#application.returned_customer_setting.operator_label_plural#", href='/settings/default_vendor/operators.cfm' }
                     ,{ text="#application.returned_customer_setting.distributor_label_plural#", href='/settings/default_vendor/distributors.cfm' }
                   ]>
    <cfset page_title = "DEFAULT VENDOR & BB CLOSING METHOD">
  </cfcase>
  <!----------------------------------->
  <!--- settings - price protection --->
  <!----------------------------------->
  <cfcase value="priceProtection">
    <cfset menus = [  { text="Create Job", href="price_protection_index.cfm" }
                     ,{ text="Jobs Scheduled", href="price_protection_index.cfm?type=1" }
                     ,{ text="Jobs Successful", href="price_protection_index.cfm?type=2" }
                     ,{ text="Jobs Failed", href="price_protection_index.cfm?type=3" }
                   ]>
    <cfset page_title = "PRICE PROTECTION">
    <cfparam name="url.type" default="">
    <cfswitch expression="#url.type#">
      <cfcase value="1">
        <cfset attributes.selectedIndex = 1>
      </cfcase>
      <cfcase value="2">
        <cfset attributes.selectedIndex = 2>
      </cfcase>
      <cfcase value="3">
        <cfset attributes.selectedIndex = 3>
      </cfcase>
      <cfdefaultcase>
        <cfset attributes.selectedIndex = 0>
      </cfdefaultcase>
    </cfswitch>
  </cfcase>
  <!----------------------------->
  <!--- settings - membership --->
  <!----------------------------->
  <cfcase value="membership">
    <cfset menus = [  { text="buying group", href="#ajaxlink('#cgi.script_name#?display_type=1')#" }
                     ,{ text="#application.returned_customer_setting.family_name_label_singular#", href="#ajaxlink('#cgi.script_name#?display_type=2')#" }
                   ]>
    <cfset page_title = "MEMBERSHIP">
  </cfcase>
  <!----------------------------------->
  <!--- settings - manage documents --->
  <!----------------------------------->
  <cfcase value="manageDocuments">
    <cfset menus = [  { text="Search", href="/Common_Files/Documents/Attach_Document.cfm?bFromSettings=1" }
                     ,{ text="Upload", href="/Common_Files/Documents/create_document_details.cfm?bFromSettings=1" }
                   ]>
    <cfset page_title = "MANAGE DOCUMENTS">
  </cfcase>
  <!----------------------------------->
  <!--- settings - edit master data --->
  <!----------------------------------->
  <cfcase value="editMasterData">
    <cfset menus = [  { text="Product", href="/settings/edit_master_data/index.cfm?type=Product" }
                     ,{ text="Distributor", href="/settings/edit_master_data/index.cfm?type=Distributor" }
                   ]>
    <cfset page_title = "EDIT MASTER DATA">
  </cfcase>
  <!--------------------------------------->
  <!--- settings - application settings --->
  <!--------------------------------------->
  <cfcase value="applicationSettings">
    <cfscript>
      menus = [  { text="settings", href="app_settings.cfm?command=Settings1" } ];
      attributes.selectedIndex = form.command eq "Settings1" ? 0 : attributes.selectedIndex;
    </cfscript>

    <cfif request.AccessStructure.User_Rights_ID EQ 9999>
      <cfset arrayAppend(menus, { text="internal settings", href="app_settings.cfm?command=Settings2" })>
      <cfset attributes.selectedIndex = form.command eq "Settings2" ? 1 : attributes.selectedIndex>
    </cfif>

    <cfscript>
      arrayAppend(menus, { text="approval settings", href="app_settings.cfm?command=Settings3" });
      attributes.selectedIndex = form.command eq "Settings3" ? 2 : attributes.selectedIndex;
    </cfscript>

    <cfif NOT Application.oApplicationAppSettingsManager.getApplicationAppSettings().LDAP_SSO_Enabled>
      <cfset arrayAppend(menus, { text="password settings", href="app_settings.cfm?command=Settings4" })>
      <cfset attributes.selectedIndex = form.command eq "Settings4" ? arrayLen(menus) - 1 : attributes.selectedIndex>
    </cfif>

    <cfif Application.oApplicationAppSettingsManager.getApplicationAppSettings().ApprovalViaEmail>
      <cfset arrayAppend(menus, { text="approval via email", href="app_settings.cfm?command=ApprovalViaEmail" })>
      <cfset attributes.selectedIndex = form.command eq "ApprovalViaEmail" ? arrayLen(menus) - 1 : attributes.selectedIndex>
    </cfif>

    <cfscript>
      arrayAppend(menus, { text="report settings", href="app_settings.cfm?command=Settings5" });
      attributes.selectedIndex = form.command eq "Settings5" ? arrayLen(menus) - 1 : attributes.selectedIndex;

      arrayAppend(menus, { text="labels", href="app_settings.cfm?command=LabelMaster" });
      attributes.selectedIndex = form.command eq "LabelMaster" ? arrayLen(menus) - 1 : attributes.selectedIndex;
    </cfscript>

    <cfif Application.oApplicationAppSettingsManager.getApplicationAppSettings().LDAP_SSO_Enabled
       OR Application.oApplicationAppSettingsManager.getApplicationAppSettings().singlesign_on eq 2>
      <cfset arrayAppend(menus, { text="LDAP/SSO settings", href="app_settings.cfm?command=LDAPSettings" })>
      <cfset attributes.selectedIndex = form.command eq "LDAPSettings" ? arrayLen(menus) - 1 : attributes.selectedIndex>
    </cfif>

    <cfset page_title = "APPLICATION GENERAL SETTINGS">
  </cfcase>
  <!------------------------------------------->
  <!--- settings - volume forecast settings --->
  <!------------------------------------------->
  <cfcase value="volumeForecastSettings">
    <cfset menus = [  { text="class", onClick="JavaScript: return clickheader('class', 0);" }
                     ,{ text="group", onClick="JavaScript: return clickheader('group', 0);"  }
                     ,{ text="labels", onClick="JavaScript: return clickheader('labels', 0);"  }
                     ,{ text="plan", onClick="JavaScript: return clickheader('plan', 0);"  }
                     ,{ text="inv. research", onClick="JavaScript: return clickheader('research', 0);"  }
                   ]>
    <cfset page_title = "VOLUME FORECAST">
  </cfcase>
  <!------------------------------------>
  <!--- settings - business segments --->
  <!------------------------------------>
  <cfcase value="businessSegments">
    <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
    <cfset appSettings = genSettingsManager.get()>
    <cfset menus = [  { text="Enable", onClick="JavaScript: return submitForm('dEnable');" }
                     ,{ text="Active #appSettings.getbusiness_segment_label()#", onClick="JavaScript: return submitForm('dActiveBusinessSegment');"  }
                     ,{ text="InActive #appSettings.getbusiness_segment_label()#", onClick="JavaScript: return submitForm('dInActiveBusinessSegment');"  }
                   ]>
    <cfset page_title = "SEGMENTS">
  </cfcase>
  <!------------------------------------>
  <!--- settings - rebate components --->
  <!------------------------------------>
  <cfcase value="rebateComponents">
    <cfset menus = [  { text="Active", onClick="JavaScript: return submitDataForm('active', 1);" }
                     ,{ text="Inactive", onClick="JavaScript: return submitDataForm('inactive', 2);"  }
                     ,{ text="Add New", onClick="JavaScript: return submitDataForm('add', 3);"  }
                     ,{ text="Business Rules", onClick="JavaScript: return submitDataForm('busRule', 4);"  }
                   ]>
    <!---display edit tab if in edit mode--->
    <cfif form.display eq "edit">
        <cfset arrayAppend(menus, { text="Edit Component", onClick="JavaScript: return submitDataForm('update', 5);"  })>
    </cfif>
    <cfset page_title = "#Application.RebateLabel# COMPONENTS">
  </cfcase>
  <!-------------------------------------->
  <!--- settings - operator management --->
  <!-------------------------------------->
  <cfcase value="operatorManagement">
    <cfset menus = [  { text="Manage", href="select_operators.cfm?tabSetter=1" }
                     ,{ text="Types", href="select_operators.cfm?tabSetter=2" }
                   ]>
    <cfset page_title = "OPERATOR MANAGEMENT">
  </cfcase>
  <!-------------------------------------------->
  <!--- settings - margin - items to exclude --->
  <!-------------------------------------------->
  <cfcase value="marginItemsToExclude">
    <cfset menus = [  { text="Active", onClick="JavaScript: return submitDataForm('active', 1);" }
                     ,{ text="Inactive", onClick="JavaScript: return submitDataForm('inactive', 2);"  }
                     ,{ text="Add New", onClick="JavaScript: return submitDataForm('add', 3);"  }
                   ]>
    <cfset page_title = "MARGIN - ITEMS TO EXCLUDE">
  </cfcase>
  <!-------------------------------------->
  <!--- settings - lump sum components --->
  <!-------------------------------------->
  <cfcase value="lumpSumComponents">
    <cfset menus = [  { text="Active", onClick="JavaScript: return submitDataForm('active', 1);" }
                     ,{ text="Inactive", onClick="JavaScript: return submitDataForm('inactive', 2);"  }
                     ,{ text="Add New", onClick="JavaScript: return submitDataForm('add', 3);"  }
                     ,{ text="Sample Labels", onClick="JavaScript: return submitDataForm('labelSample', 4);"  }
                   ]>
    <cfset page_title = "#Application.LumpsumLabel# COMPONENTS">
  </cfcase>
  <!------------------------------------>
  <!--- settings - growth components --->
  <!------------------------------------>
  <cfcase value="growthComponents">
    <cfset menus = [  { text="Active", onClick="JavaScript: return submitDataForm('active', 1);" }
                     ,{ text="Inactive", onClick="JavaScript: return submitDataForm('inactive', 2);"  }
                     ,{ text="Add New", onClick="JavaScript: return submitDataForm('add', 3);"  }
                   ]>
    <cfset page_title = "GROWTH COMPONENTS">
  </cfcase>
  <!------------------------------>
  <!--- settings - gl accounts --->
  <!------------------------------>
  <cfcase value="glAccounts">
    <cfset menus = [  { text="Active", onClick="JavaScript: return submitDataForm('active', 1);" }
                     ,{ text="Inactive", onClick="JavaScript: return submitDataForm('inactive', 2);"  }
                     ,{ text="Add New", onClick="JavaScript: return submitDataForm('add', 3);"  }
                   ]>
 <!---D42774 --->
<cfoutput>
	<cfset page_title = "#trim(ucase(Application.GLAccountLabel))#S">
</cfoutput>
<!---D42774 --->
  </cfcase>
  <!----------------------------------->
  <!--- settings - freight settings --->
  <!----------------------------------->
  <cfcase value="freightSettings">
    <cfset menus = [  { text="Brackets", href="index.cfm?Action=AddFreightBracket" }
                     ,{ text="Upload OBF", href="index.cfm?Action=UploadOBF" }
                   ]>
    <cfset page_title = "FREIGHT SETTINGS">
  </cfcase>
  <!---------------------------------->
  <!--- settings - formula pricing --->
  <!---------------------------------->
  <cfcase value="formulaPricing">
    <cfset menus = [  { text="Pricing Rules", href="index.cfm" }
                     ,{ text="Inactive Rules", href="index.cfm?active=false" }
                     ,{ text="Add New", href="Formula_Price_Step1.cfm" }
                   ]>
    <cfif attributes.FORMULA_PAGE_NAME EQ 4>
      <cfset arrayAppend( menus, { text="Programs", href="Formula_Price_Programs.cfm?RID=#URL.RID#" } )>
    </cfif>
    <CFIF attributes.FORMULA_PAGE_NAME EQ 5>
      <cfset arrayAppend( menus, { text="Edit Rule", href="Formula_Price_Step1.cfm?RID=#URL.RID#" } )>
    </cfif>
    <cfset page_title = "FORMULA PRICING">
  </cfcase>
  <!----------------------------------->
  <!--- settings - fixed components --->
  <!----------------------------------->
  <cfcase value="fixedComponents">
    <cfset menus = [  { text="Active", onClick="JavaScript: return submitDataForm('active', 1);" }
                     ,{ text="Inactive", onClick="JavaScript: return submitDataForm('inactive', 2);"  }
                     ,{ text="Add New", onClick="JavaScript: return submitDataForm('add', 3);"  }
                     ,{ text="Business Rules", onClick="JavaScript: return submitDataForm('busRule', 4);"  }
                   ]>
    <cfif form.display eq "edit">
      <cfset arrayAppend(menus, { text="Edit Component", onClick="JavaScript: return submitDataForm('update', 5);"  })>
    </cfif>

    <cfset page_title = "FIXED COMPONENTS">
  </cfcase>
  <!--------------------------------------->
  <!--- settings - discount identifiers --->
  <!--------------------------------------->
  <cfcase value="discountIdentifiers">
    <cfset menus = [  { text="Active", onClick="JavaScript: return submitDataForm('active', 1);" }
                     ,{ text="Inactive", onClick="JavaScript: return submitDataForm('inactive', 2);"  }
                     ,{ text="Add New", onClick="JavaScript: return submitDataForm('add', 3);"  }
                   ]>
    <cfset page_title = "DISCOUNT IDENTIFICATION CODES">
  </cfcase>
  <!--------------------------->
  <!--- settings - currency --->
  <!--------------------------->
  <cfcase value="currency">
    <cfset menus = [  { text="Active", onClick="JavaScript: return submitDataForm('active', 1);" }
                     ,{ text="Inactive", onClick="JavaScript: return submitDataForm('inactive', 2);"  }
                     ,{ text="Add New", onClick="JavaScript: return submitDataForm('add', 3);"  }
                   ]>
    <cfset page_title = "CURRENCY">
  </cfcase>
  <!------------------------------------->
  <!--- settings - competitive data   --->
  <!------------------------------------->
  <cfcase value="competitiveData">
		<cfset LabelComp = Createobject("component", "components.settings.labels.labels").init() />
		<cfset qGetWonByLabel 	= LabelComp.getGeneralLabels('Won By') />
		<cfset qGetCategoryLabel 	= LabelComp.getGeneralLabels('Category') />
		<cfset qGetPackageLabel 	= LabelComp.getGeneralLabels('Package') />
		<cfset qGetSourceLabel		= LabelComp.getGeneralLabels('Source') />
		<cfset qGetSourceTypeLabel	= LabelComp.getGeneralLabels('Source Type') />

    <cfset menus = [  { text="#qGetWonByLabel.General_Labels_Label#", href="/settings/competitive_data/competitive_data.cfm" }
                     ,{ text="#qGetCategoryLabel.General_Labels_Label#", href="/settings/competitive_data/competitive_data_category.cfm" }
                     ,{ text="#qGetPackageLabel.General_Labels_Label#", href="/settings/competitive_data/competitive_data_package.cfm" }
                     ,{ text="#qGetSourceLabel.General_Labels_Label#", href="/settings/competitive_data/competitive_data_source.cfm" }
                     ,{ text="#qGetSourceTypeLabel.General_Labels_Label#", href="/settings/competitive_data/competitive_data_source_type.cfm" }
                   ]>
    <cfset page_title = "COMPETITIVE DATA">
	</cfcase>
  <!---------------------------------->
  <!--- settings - claim mechanics --->
  <!---------------------------------->
  <cfcase value="claimMechanics">
    <cfset menus = [  { text="Active", onClick="JavaScript: return submitDataForm('active', 1);" }
                     ,{ text="Inactive", onClick="JavaScript: return submitDataForm('inactive', 2);"  }
                     ,{ text="Add New", onClick="JavaScript: return submitDataForm('add', 3);"  }
                   ]>
    <cfset page_title = "CLAIM MECHANICS">
	</cfcase>
  <!-------------------------->
  <!--- settings - budgets --->
  <!-------------------------->
  <cfcase value="budgets">
    <cfset menus = [   { text="class", onclick="javascript: return clickheader('listbudgetclass', 0);" }
											,{ text="group", onclick="javascript: return clickheader('listBudgetGroup', 0);" }
											,{ text="labels", onclick="javascript: return clickheader('listBudgetLabel', 0);" }
											,{ text="adj types", onclick="javascript: return clickheader('listAdjustmentTypes', 0);" }
									 ]>
		<cfset profile = CreateObject("component","components.user.Profile").init()>
		<cfset Get_Profile_Settings = profile.getProfileSettings(request.AccessStructure.Profiles_ID)>
		<cfif ( Get_Profile_Settings.Budgets_Actual_Adjustment )>
			<cfset arrayAppend(menus, {text="act adj", onclick="javascript: return clickheader('listActAdjustment', 0);"})>
		</cfif>
		<!---need the current budget id in the form structure (required passed in value)--->
		<cfif attributes.budget_id eq 0>
			<cfset arrayAppend(menus, {text="budget", onclick="javascript: return clickheader('listBudget', 0);"})>
		<cfelse>
				
			  <!---query the db to find out the budget type--->
			  <cfquery name="qBudgetType" datasource="#application.datasource#">
			      SELECT Budget_Contribution_Factor_Type_Id
			             , Overlays
			             , Overlay_Recapture
			             , Recapture
			        FROM Budget
			       WHERE Budget.Budget_Id = <cfqueryparam value="#attributes.Budget_Id#" cfsqltype="cf_sql_integer">
			  </cfquery>
			<CFIF Get_Profile_Settings.Create_Budget eq 0  and qBudgetType.Budget_Contribution_Factor_Type_ID eq "2">
				<cfset arrayAppend(menus, {text="budget", onclick="javascript: return clickheader('listBudget', 0);"})>
			<CFELSE>
			  	<cfset menus = []>
			  <!---special handling for accrual budget: add accrual tabs based on the budget type saved
			       in the db, do not show these tabs when users switch the budget type to accrual and
			       have not clicked the save button (they may click the other tabs w/o clicking save on
			       budget page)--->
			  <cfif qBudgetType.Budget_Contribution_Factor_Type_ID eq "1">
					<cfset arrayAppend(menus, {text="budget", onclick="javascript: return clickheader('editFixed', 0);"})>
			  <cfelseif qBudgetType.Budget_Contribution_Factor_Type_ID eq "2">
			    <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
			    <cfscript>
			      // assign budget tab to editing accrual budget
			      arrayAppend(menus, {text="budget", onclick="javascript: return clickheader('editAccrual', 0);"});
			      arrayAppend(menus, {text="#lcase(application.returned_customer_setting.Distributor_Label_Plural)#", onclick="javascript: return clickheader('editDistributors', 0);"});
			      arrayAppend(menus, {text="products", onclick="javascript: return clickheader('editProducts', 0);"});
			      if ( ( qBudgetType.Recapture eq 1 ) or ( qBudgetType.Overlay_Recapture eq 1 ) or ( qBudgetType.Overlays eq 1 ) )
			      	arrayAppend(menus, {text="advanced", onclick="javascript: return clickheader('editRecaptures', 0);"});
			      	arrayAppend(menus, {text="accrual adj", onclick="javascript: return clickheader('listAdjustments', 0);"});
			    </cfscript>
			  <cfelseif qBudgetType.Budget_Contribution_Factor_Type_ID eq "3">
					<cfset arrayAppend(menus, {text="budget", onclick="javascript: return clickheader('editVariable', 0);"})>
			  </cfif>
				<cfset arrayAppend(menus, {text="templates", onclick="javascript: return clickheader('templates', 0);"})>
			</CFIF>
		</cfif>
			<!---D42242 :: Create links w/in the application for client to run report to see Orphaned BB's and Programs--->
			<cfset arrayAppend(menus, {text="research", onclick="javascript: return clickheader('research', 0);"})>
			<!---D42242 :: Create links w/in the application for client to run report to see Orphaned BB's and Programs--->
    <cfset page_title = "PROGRAMS: BUDGETS">

		<!---determine current selected option based on command in the form structure  (required passed in value)--->
		<cfloop from=1 to="#arrayLen(menus)#" index="menusIndex">
			<cfif menus[menusIndex].onclick contains ( "'" & attributes.command & "'")>
				<cfset attributes.selectedIndex = menusIndex - 1>
				<cfbreak>
			</cfif>
		</cfloop>
    <cfset request.menus = menus>
	</cfcase>
  <!------------------------------------->
  <!--- settings - vendor management  --->
  <!------------------------------------->
  <cfcase value="vendorManagement">
    <cfset menus = [  { text="Vendor Xref", href="index.cfm?tabvalue=listvendorxref" }
                     ,{ text="Vendor Master", href="index.cfm?tabvalue=listvendormaster" }
                   ]>
    <cfset page_title = "VENDOR MANAGEMENT">
	</cfcase>
  <!---------------------------------->
  <!--- settings - upload payables --->
  <!---------------------------------->
  <cfcase value="uploadPayables">
    <cfset menus = []>
    <cfset menuIdx = 0>
    <cfloop list="#attributes.Step_List#" index="thisStep">
    	<cfset menuIdx = menuIdx + 1>
    	<cfset arrayAppend(menus, { text=thisStep, href="index.cfm?Show_Tab=#menuIdx#"
    	<!---, onclick="javaScript: Change_Tab();" --->
    	})>
    </cfloop>
    <cfset page_title = "BILLBACK UPLOAD UTILITY">
	</cfcase>

  <!--------------------------------->
  <!--- settings - rebill package --->
  <!--------------------------------->
  <cfcase value="rebillPackage">
    <cfset menus = [  { text="Active", onClick="JavaScript: return submitDataForm('active', 1);" }
                     ,{ text="Inactive", onClick="JavaScript: return submitDataForm('inactive', 2);"  }
                     ,{ text="Add New", onClick="JavaScript: return submitDataForm('add', 3);"  }
                     ,{ text="Variable Size", onClick="JavaScript: return submitDataForm('varsize', 4);"  }
                     ,{ text="Rebill Settings", onClick="JavaScript: return submitDataForm('rebillSettings', 5);"  }
                   ]>
    <cfset page_title = "REBILL PACKAGES">
	</cfcase>
  <!---------------------------->
  <!--- settings - reprocess --->
  <!---------------------------->
  <cfcase value="reProcess">
    <cfset menus = [  { text="Program", onClick="JavaScript: return submitDataForm('program', 1);" }
                     ,{ text="Operator", onClick="JavaScript: return submitDataForm('operator', 2);"  }
                   ]>
    <cfset page_title = "RE-PROCESS">
	</cfcase>

  <!--------------------------------------->
  <!--- settings - deduction assignment --->
  <!--------------------------------------->
  <cfcase value="deductionAssignment">
    <!--- pulled logic from \deductions\assignment\index.cfm --->
		<cfif application.returned_customer_setting.DD_Assignment_Based_On_Customer EQ 1>
			<cfset Step_List="View,Analyst,Default">
		<cfelse>
			<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
			<cfset appSettings = genSettingsManager.get()>
			<cfif appSettings.getDDAssignmentBasedOnShrShipto()>
				<cfset Step_List="View,Analyst,Market,Customer,Supervisor,Default,Assign Supervisor">
			<cfelse>
				<cfset Step_List="View,Analyst,Market,Family,Supervisor,Default,Assign Supervisor">
			</cfif>
		</cfif>

    <cfset menus = []>
    <cfset menuIdx = 0>
    <cfloop list="#Step_List#" index="thisStep">
    	<cfset menuIdx = menuIdx + 1>
    	<cfset arrayAppend(menus, { text=thisStep, href="index2.cfm?Show_Step=#menuIdx#" })>
    </cfloop>
    <cfset page_title = "DEDUCTION ASSIGNMENT">
	</cfcase>
  <!--------------------------------------->
  <!--- settings - billback assignment  --->
  <!--------------------------------------->
  <cfcase value="billBackAssignment">
    <cfset menus = [  { text="View", href="index.cfm?command=view" }
                     ,{ text="Analyst", href="index.cfm?command=analyst" }
                     ,{ text="Assign Market", href="index.cfm?command=market" }
                     ,{ text="Assign #LCase(application.returned_customer_setting.distributor_label_singular)#", href="index.cfm?command=distributor" }
                     ,{ text="Assign #LCase(application.returned_customer_setting.operator_label_singular)#", href="index.cfm?command=operator" }
                     ,{ text="Supervisor", href="index.cfm?command=supervisor" }
                     ,{ text="Assign Supervisor", href="index.cfm?command=assign-supervisor" }
                     ,{ text="Director", href="index.cfm?command=director" }
                     ,{ text="Assign Director", href="index.cfm?command=assign-director" }
                   ]>
    <cfset page_title = "BILLBACK ASSIGNMENT">
	</cfcase>

  <!--------------------------->
  <!--- settings - auto pay --->
  <!--------------------------->
  <cfcase value="autoPay">
    <cfset menus = [  { text="Settings", href="index1.cfm?command=Settings" }
                     ,{ text="Auto Pay Report", href="index1.cfm?command=AutoPayReport" }
                   ]>
    <cfset page_title = "MANAGE AUTO PAY">
	</cfcase>
  <!----------------------------------->
  <!--- settings - alias management --->
  <!----------------------------------->
  <cfcase value="aliasManagement">
    <cfset menus = [  { text="Search Aliases", onClick="JavaScript: return submitDataForm('search', 1);" }
                     ,{ text="Add New Product Alias", onClick="JavaScript: return submitDataForm('addProd', 2);"  }
                     ,{ text="Add New #application.returned_customer_setting.distributor_label_singular# Alias", onClick="JavaScript: return submitDataForm('addDist', 3);"  }
                   ]>
    <cfset page_title = "ALIAS MANAGEMENT">
	</cfcase>

  <!------------------------------>
  <!--- vendor batching layout --->
  <!------------------------------>
  <cfcase value="vendorBatching">
  	<cfset billbackLabels = createObject("component", "mvc.Models.SettingsService").getBBLabels() />
    <cfset menus = [  { text=billBackLabels["Vendor"], href='/gl_code/vendor_management/vendorBatching.cfm' }
                     ,{ text=billBackLabels["Billback"], href='/gl_code/vendor_management/billBackBatching.cfm' }
                   ]>
    <cfset page_title = billBackLabels["Vendor"] & " Batching">
	</cfcase>
  <!-------------------------------->
  <!--- profit model xref layout --->
  <!-------------------------------->
  <cfcase value="profit-models-xref">
  	<cfset jQueryUI.version = "1.8.23">
    <cfset menus = [  { text="Settings", href='/settings/prof_model_xref/settings.cfm' }
                     ,{ text="Planning Groups", href='/settings/prof_model_xref/pgtypes.cfm' }
                     ,{ text=application.returned_customer_setting.Item_Label & ' to ' & application.returned_customer_setting.Operator_Label_Singular & ' Group',  href='/settings/prof_model_xref/item.cfm'  }
                     ,{ text=application.returned_customer_setting.Operator_Label_Singular & ' to ' & application.returned_customer_setting.Distributor_Label_Singular & ' Group', href='/settings/prof_model_xref/operator.cfm' }
                   ]>
    <cfset page_title = "Profitability Model Xref">
	</cfcase>

  <!------------------------------------------>
  <!--- profit model classification layout --->
  <!------------------------------------------>
  <cfcase value="profit-models-classification">
  	<cfset jQueryUI.version = "1.8.23">
    <cfset menus = [  { text="Classification", href='/settings/prof_model_classification/listClassification.cfm' }
                     ,{ text=application.returned_customer_setting.Operator_Label_Singular, href='/settings/prof_model_classification/operator.cfm' }
                     ,{ text='Template', href='/settings/prof_model_classification/template.cfm' }
                   ]>
    <cfset page_title = "Profitability Model Classification">
	</cfcase>
  <!------------------------------------>
  <!--- profit model excludes layout --->
  <!------------------------------------>
  <cfcase value="profitability-models">
  	<cfset jQueryUI.version = "1.8.23">
    <cfset menus = [  { text=application.returned_customer_setting.Item_Label, href='/settings/prof_model_excludes/item.cfm'         }
                     ,{ text=application.returned_customer_setting.Distributor_Label_Singular,  href='/settings/prof_model_excludes/distributor.cfm'  }
                     ,{ text=application.returned_customer_setting.Operator_Label_Singular,     href='/settings/prof_model_excludes/operator.cfm'     }
                     ,{ text='Template',     href='/settings/prof_model_excludes/template.cfm'     }
                   ]>
    <cfset page_title = "Profitability Model Excludes">
	</cfcase>

  <!------------------------------>
  <!--- volume forecast layout --->
  <!------------------------------>
  <cfcase value="volume-forecast">
    <cfset page_title = "Volume Forecast">
    <cfset menus = [  { text='Volume Forecast List',     href='/common_files/volume/listVF.cfm'              }
                     ,{ text='Volume Forecast Summary',  href='/common_files/volume/summary/forecast.cfm'    }
                     ,{ text='Distributor Summary',      href='/common_files/volume/summary/distributors.cfm'}
                     ,{ text='Planning Group Summary',   href='/common_files/volume/summary/pg.cfm'          }
                   ]>
    <cfloop array="#menus#" index="item">
    	<cfif cgi.script_name eq item.href>
    		<cfset page_title = item.text>
    	</cfif>
    </cfloop>
  </cfcase>
  <cfdefaultcase>   <!--- we should never reach to here --->
    <cfset page_title = "Untitled">
    <cfset menus = []>
  </cfdefaultcase>
</cfswitch>
</cfsilent>
<title><cfoutput>#page_title#</cfoutput></title>

<!--- load jQueryUI to take care of popup calendars ( datepicker() ) --->
<cfif structKeyExists(attributes, "jQueryUI")>
  <cfset jQueryUI.version = attributes.jQueryUI>
</cfif>

<cfinclude template="/common_files/jQuery.cfm">

<!--- styles for horizontal menu options --->
<style>
  #hMenU {list-style:none;background:url(/Images/gradient.jpg) #a7caf2 no-repeat;color:#FFF;line-height:30px !important;margin:0;padding:0;}
  #hMenU li {display:inline;padding:0 4.5px;}
  #hMenU a:link,#hMenU a:visited,#hMenU a:hover,#hMenU a:active {font-weight:700;font-size:1.25em;color:#FFF;padding:0 8px 2px;margin-left:8px; text-decoration:none;}
  #hMenU a:hover,#hMenU a.selected {background-color:#FFF;color:#000;}

	#toPtiTle table, #toPtiTle td {border-style:none;}
</style>
</head>

<!--------------------------------------------------------------------------------------------------------------------->

<body>

<cfif structKeyExists(attributes, 'margin')>
  <div style="margin:<cfoutput>#attributes.margin#</cfoutput>">
</cfif>

<!--- display Forge heading with environment name, page title, user name, timestamp and home page icons on the right side --->
<cfswitch expression="#attributes.layoutID#">
  <!--------------------->
  <!--- common layout --->
  <!--------------------->
  <cfcase value="vendorBatching,aliasManagement,autoPay,billBackAssignment,deductionAssignment,reProcess,rebillPackage,uploadPayables,vendorManagement,budgets,claimMechanics,competitiveData,currency,discountIdentifiers,fixedComponents,formulaPricing,freightSettings,glAccounts,growthComponents,lumpSumComponents,marginItemsToExclude,operatorManagement,rebateComponents,businessSegments,volumeForecastSettings,applicationSettings,editMasterData,manageDocuments,membership,priceProtection,defaultVendor">
		<cfinclude template="/helpsystem/help_link.cfm">
		<table border="0" cellpadding="2" cellspacing="0" width="100%" id="toPtiTle">
			<tr>
				<td align="left" bgcolor="#A7CAF2" width="100%" height="25" style="background-image: url(/Images/gradient.jpg); background-repeat:no-repeat;">
					<cfoutput><span style="color:white; font-size:14px; font-weight: bold; padding-left:5px; letter-spacing:1.75px">#ucase(page_title)#</span></cfoutput>
				</td>
			</tr>
		</table>
	</cfcase>
  <!------------------------------------------>
  <!--- profit model classification layout --->
  <!------------------------------------------>
  <cfcase value="profit-models-classification,profitability-models,profit-models-xref">
		<form action="/common_files/csv.cfm" method ="post" id="csv_form">
		  <input type="hidden" name="csv_text" id="csv_text">
		  <input type="hidden" name="csv_file_name" id="csv_file_name" value="export.csv">
		</form>
		<cfoutput>
		<table border="0" cellpadding="2" cellspacing="0" width="100%">
			<tr>
				<td align="left" bgcolor="##A7CAF2" width="100%" height="25" style="background-image: url(/Images/gradient.jpg); background-repeat:no-repeat;">
					<span style="color:white; font-size:14px; font-weight: bold; padding-left:5px; letter-spacing:1.75px">#ucase(page_title)#</span>
				</td>
			</tr>
		</table>
		</cfoutput>
	</cfcase>
  <!------------------------------>
  <!--- volume forecast layout --->
  <!------------------------------>
  <cfcase value="volume-forecast">
		<cfinclude template="/includes/header.cfm">
	</cfcase>
</cfswitch>

<!------------------------------->
<!--- display horizontal menu --->
<!------------------------------->
<ul id="hMenU">
  <cfset menuCnt = 0>
  <cfloop array=#menus# index="menuItem">
    <cfset menuCnt = menuCnt + 1>
    <cfoutput>
    <li <cfif attributes.layoutID eq "uploadPayables"> style="line-height:30px;" </cfif>  >
    	<cfif menuCnt gt 1> | </cfif>
    	<a <cfif structKeyExists(menuItem, 'onclick')> onclick="#menuItem.onclick#" </cfif>
    			<cfif structKeyExists(menuItem, 'href')> href="#menuItem.href#" <cfelse> href="##" </cfif>
    			<cfif attributes.layoutID eq "uploadPayables"> style="font-size:1em;" </cfif>  > #lcase(menuItem.text)#	</a>
    </li></cfoutput>
  </cfloop>
</ul>

<!--------------------------------------------------------------------------------------------------------------------->
<div id="layoutBody">

<cfelse>

 <!--- main content from parent code is displayed here --->

</div>   <!---id="layoutBody"--->
<!--------------------------------------------------------------------------------------------------------------------->

 <!--- footer section --->
 <div id="layoutFoot" style='margin-top:10px;'>
 <cfswitch expression="#attributes.layoutID#">
   <!--- volume forecast layout --->
   <cfcase value="volume-forecast">
    <!--- display disclaimer for summaries --->
  	<cfif cgi.script_name contains "summary">
	 	<p>Note: The summarized values in this summary vary from the other summaries due to rounding logic that is imbedded at the detail level of each level of aggregation.</p>
		</cfif>
   </cfcase>
 </cfswitch>
</div>


<cfif structKeyExists(attributes, 'margin')>
  </div>   <!--- style="margin:#attributes.margin#"> --->
</cfif>


<!---Resolve conflicts on pages with other plugins such as prototype.js--->
<cfif len(attributes.jQueryNoConflict)>
   <!------------------------------------------------------------------------------------------------------->
   <!--- *** NOTES: changes made to this section need to carry over to the section in <cfelse> below *** --->
   <!------------------------------------------------------------------------------------------------------->
	 <script>
   var $j = jQuery.noConflict();
   $j(function(){
     var $menuSelected = 0;
     <cfif len(attributes.selectedIndex)>
       $menuSelected = $j('#hMenU li:eq(<cfoutput>#attributes.selectedIndex#</cfoutput>) a');
       $menuSelected.addClass( 'selected' );
     <cfelse>
       /* find selected option & then highlight it */
       $j('#hMenU li a[href]').each(function() {
         if ( $j(this).attr('href').toLowerCase() === <cfoutput>'#cgi.script_name#'.toLowerCase()</cfoutput>) {
           $menuSelected = $(this);
           $menuSelected.addClass( 'selected' );
           return false;
         }
       });
     </cfif>

     _pleaseWait = function() {
       $j('#layoutBody, .fixedHeader').hide();
       $j('#layoutFoot').html('Processing request, please wait... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">');
     }

     $j('#hMenU a').click( function() {
       // remove fixed header elements
       // hide page body, display a waiting message while new page content is being loaded
       $menuSelected.removeClass( 'selected' );
       _pleaseWait();
     });

     // preload image for quicker display
     var image = $j('<img />').attr('src', '/Images/ajax-loader.gif');
   });
	 </script>

<cfelse>  <!---cfif len(attributes.jQueryNoConflict)--->

   <!----------------------------------------------------------------------------------------------------->
	 <!--- *** NOTES: changes made to this section need to carry over to the section in <cfif> above *** --->
   <!----------------------------------------------------------------------------------------------------->
	 <script>
   $(function(){
  	 var $menuSelected = 0;
  	 <cfif len(attributes.selectedIndex)>
  	 	 $menuSelected = $('#hMenU li:eq(<cfoutput>#attributes.selectedIndex#</cfoutput>) a');
  	 	 $menuSelected.addClass( 'selected' );
  	 <cfelse>
  		 /* find selected option & then highlight it */
  		 $('#hMenU li a[href]').each(function() {
  		   if ( $(this).attr('href').toLowerCase() === <cfoutput>'#cgi.script_name#'.toLowerCase()</cfoutput>) {
  		     $menuSelected = $(this);
  		     $menuSelected.addClass( 'selected' );
  		     return false;
  		   }
  		 });
  	 </cfif>

  	 _pleaseWait = function() {
  		 $('#layoutBody, .fixedHeader').hide();
  		 $('#layoutFoot').html('Processing request, please wait... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">');
  	 }

  	 $('#hMenU a').click( function() {
  		 // remove fixed header elements
  		 // hide page body, display a waiting message while new page content is being loaded
  	   if ( $menuSelected ) {
  	     $menuSelected.removeClass( 'selected' );
  	 	 }
  	   _pleaseWait();
  	 });

  	 // preload image for quicker display
  	 var image = $('<img />').attr('src', '/Images/ajax-loader.gif');
   });
	 </script>
</cfif>  <!---cfif len(attributes.jQueryNoConflict)--->
</body>
</html>
</cfif>     <!--- if thisTag.executionMode is "start" --->
