<!--- Dev Note: KAL; D????: Billback Workflow: Call from the Flex App --->
<cfparam name="FORM.FlexAppName" default="">
<cfparam name="FORM.Type" default="">

<cfif isDefined("URL.FlexAppName")>
	<cfset temp = structInsert(FORM,"FlexAppName",#URL.FlexAppName#,true) />
</cfif>
<cfif isDefined("URL.Type")>
	<cfset temp1 = structInsert(FORM,"Type",#URL.Type#,true) />
</cfif>
<CFPARAM NAME="URL.RebateRecipient_On" DEFAULT="0">
<CFPARAM NAME="URL.ignoreMasterDeleted" DEFAULT="0">
<cfparam name="form.passed_form" 	default="">
<cfparam name="form.itemList" 		default="">
<CFPARAM NAME="URL.Distributor_Bill_To_ID" DEFAULT="">
<cfparam name="URL.FieldName" 	default="Distributor_List">
<cfparam name="url.SelectSingleSearchResultOnly" default = "1">
<cfparam name="url.Business_Segment_Id" default = "0">
<cfparam name="URL.AllowSingleResultAutoSelect" default = "1">

<cfparam name="form.Dist_Name" default="">
<cfset sort_By_List = "Name" />
<cfparam name="FORM.sort_by" default = "#sort_By_List#" />
<cfparam name="FORM.Sort_Order" default = "ASC" />
<CFPARAM NAME="FORM.Distributor_Status" DEFAULT="A">
<CFPARAM NAME="Form.Ship_To" 	DEFAULT="">
<CFPARAM NAME="FORM.State" DEFAULT="0">
<CFPARAM NAME="FORM.Country_Code" DEFAULT="0">



<cfparam  NAME="form.Family_Name" default="0">
<cfparam  NAME="form.Buying_Group" default="0">
<cfparam  NAME="form.Cust_Id" default="0">
<cfparam  NAME="form.Line_Of_Biz" default="0">
<cfparam  NAME="form.Zone_ID" default="0">
<cfparam  NAME="form.Region_ID" default="0">
<cfparam  NAME="form.Broker" default="0">
<cfparam  NAME="form.Country_Code" default="0">
<cfparam  NAME="form.State" default="0">
<cfparam  NAME="form.Distributor_Status" default="">
<cfparam  NAME="form.Default_Vendor" default="">
<cfparam  NAME="form.Default_BB_Closing_Method" default="">
<cfparam  NAME="form.ShowBillToSearchFields" default="0">
<cfparam  NAME="Form.BillTo_Number" default="" />
<cfparam  NAME="Form.BillTo_Name" default="" />

<cfif isDefined("URL.AllowImportAll") AND URL.AllowImportAll EQ 1>
	<cfparam name="form.AllowImportAll" default="1">
<cfelse>
	<cfparam name="form.AllowImportAll" default="0">
</cfif>
<!--- "ShowVendorAndBBClosingMethod" is used to show or not show Default Vendor and Billback closing method dropdowns.
Currently, it is being used only to set vednors for distributors --->
<cfparam name="ShowVendorAndBBClosingMethod" default="0">
<cfparam name="Default_Vendor" default="">
<cfparam name="Default_BB_Closing_Method" default="">
<cfparam name="PageSource" default="">
<cfparam name="ReloadForm" default="1">
<cfparam name="showPlanningGroups" default="0">

<cfset maxColsPerRow = 4 />
<cfset currentColCount = 0/>
<!--- Pass these in the url for pactiv --->
<cfparam name="BusinessSegment" default="0">
<cfparam name="LineofBusiness" default="0">

<cfparam name="URL.ShowActiveDistributorsOnly" default="0">

<script src="/debug.js"></script>
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js">

<cfif form.passed_form NEQ "" and form.itemList NEQ "">
	<cfset form.itemList = #trim(replace(ListQualify(form.itemList, "'", ",", "ALL"), "''", "'", "ALL"))# >
</cfif>
<CFINCLUDE TEMPLATE="/Get_Access_Profile.cfm">
<cfif URL.ShowActiveDistributorsOnly EQ 0>
	<cfset URL.ShowActiveDistributorsOnly = JavaCast("int", !Get_Profile_Settings.Search_Inactive_Distributors_Programs) />
</cfif>
<CFIF isdefined("URL.FormName")>
	<FORM ACTION="pm_select_distributors.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
	<cfoutput>
		<INPUT TYPE="hidden" name="BusinessSegment" value="#BusinessSegment#">
		<INPUT TYPE="hidden" name="LineofBusiness" value="#LineofBusiness#">
		<INPUT TYPE="hidden" name="ShowActiveDistributorsOnly" value="#EncodeForHTMLAttribute(URL.ShowActiveDistributorsOnly)#">
		<INPUT TYPE="hidden" name="Business_Segment_Id" value="#EncodeForHTMLAttribute(url.Business_Segment_Id)#">
		<input type="hidden" name="Single_Result_AutoSelect" value="#EncodeForHTMLAttribute(URL.AllowSingleResultAutoSelect)#">
	 </cfoutput>
		<INPUT NAME="ParentFormname" TYPE="Hidden" VALUE="<CFOUTPUT>#EncodeForHTMLAttribute(URL.FormName)#</CFOUTPUT>">
		<INPUT NAME="SelectSingleSearchResultOnly" TYPE="Hidden" VALUE="<cfoutput>#EncodeForHTMLAttribute(url.SelectSingleSearchResultOnly)#</cfoutput>">
		<cfif isDefined("url.OnlyDistributorsUnderMe")>
		<INPUT NAME="OnlyDistributorsUnderMe" Type="Hidden" value="<cfoutput>#EncodeForHTMLAttribute(URL.OnlyDistributorsUnderMe)#</cfoutput>">
		<cfelse>
		<input name="OnlyDistributorsUnderMe" type="hidden" value="0">
		</cfif>
		<INPUT NAME="FinalItemList" TYPE="HIDDEN" VALUE="">
		<INPUT NAME="FieldName" TYPE="HIDDEN" VALUE="<cfoutput>#EncodeForHTMLAttribute(URL.FieldName)#</cfoutput>">
		<CFOUTPUT>
		<INPUT NAME="Distributor_Bill_To_ID" TYPE="HIDDEN" VALUE="#EncodeForHTMLAttribute(URL.Distributor_Bill_To_ID)#">
		<INPUT NAME="RebateRecipient_On" TYPE="HIDDEN" VALUE="#EncodeForHTMLAttribute(URL.RebateRecipient_On)#">
		<INPUT NAME="ignoreMasterDeleted" TYPE="HIDDEN" VALUE="#EncodeForHTMLAttribute(URL.ignoreMasterDeleted)#">
		<INPUT TYPE="hidden" NAME="Dist_Name" value="#Dist_Name#">
		<INPUT NAME="AllowImportAll" TYPE="HIDDEN" VALUE="#AllowImportAll#">
		<INPUT TYPE="Hidden" NAME="ShowVendorAndBBClosingMethod" VALUE="#ShowVendorAndBBClosingMethod#">
		<INPUT TYPE="Hidden" NAME="PageSource" VALUE="#PageSource#">
		<INPUT TYPE="Hidden" NAME="ReloadForm" VALUE="#ReloadForm#">
		<INPUT TYPE="Hidden" NAME="FlexAppName" VALUE="#EncodeForHTMLAttribute(FORM.FlexAppName)#">
		<INPUT TYPE="Hidden" NAME="ShowBillToSearchFields" VALUE="0">
        <INPUT TYPE="Hidden" NAME="Type" VALUE="#EncodeForHTMLAttribute(FORM.Type)#">
        <cfparam name="url.parent_ShipTo" default="">   <input type="hidden" name="parent_ShipTo" value="#EncodeForHTMLAttribute(url.parent_ShipTo)#">
		</CFOUTPUT>
	</FORM>
	<cfif URL.FormName EQ 'flex'>
		<script>
			document.all.MyForm.submit();
		</script>
    <cfelse>
        <!--- <cfabort> --->
		<script>
			if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT> != null) {
				// save parent path name into a new form element
				const parent_url = new URL( window.opener.location.href );
				const parent_pathname = document.createElement( "input" );

				parent_pathname.type  = "hidden";
				parent_pathname.name  = "parent_pathname";
				parent_pathname.value = parent_url.pathname;

				document.MyForm.appendChild( parent_pathname );

				var parentForm = window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>;
				<cfif PageSource NEQ "AliasDistributorSearch" AND PageSource NEQ "ProgramRatesGrid">
				    this.document.all.FinalItemList.value = parentForm.<cfoutput>#encodeForJavaScript(URL.FieldName)#</cfoutput>.value
				</cfif>

				// allow deduction page to use multiple distributors search result
				if ( parent_url.pathname.toLowerCase().indexOf("/deductions/index1.cfm") !== -1 ) {
					document.MyForm.SelectSingleSearchResultOnly.value = 0;
				}
				else if ( parentForm.SelectSingleSearchResultOnly ) {
					this.document.all.SelectSingleSearchResultOnly.value = parentForm.SelectSingleSearchResultOnly.value;
				}


				if(parentForm.ShowBillToSearchFields)
				{
					this.document.all.ShowBillToSearchFields.value = parentForm.ShowBillToSearchFields.value;
				}

				document.all.MyForm.submit()
			}
			else{
				alert("The Data Needed From The Parent Form Isn't Available. This Window Will Close!")
				window.close()
			}
		</script>
	</cfif>
	<cfabort>
</CFIF>

<CFPARAM NAME="FORM.DOSEARCH" DEFAULT="0">
<CFPARAM NAME="URL.CID" DEFAULT="">

<CFIF len(trim(URL.CID)) GT 0>
	<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">

	<cfset useLakebaseForGetContractInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetContractInfo>
	<cftry>
		<cfset GetContractInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#cryp.value#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetContractInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetContractInfo>
<cfquery name="GetContractInfo" Datasource="#application.datasource#">
		SELECT *
		FROM Contract_Main
		WHERE Contract_Main_ID = '#cryp.value#'
	</cfquery>
</cfif>

	<!--- Do not show the tabs if the contract is approved --->
	<CFIF GetContractInfo.Contract_Status_Type_IDX GT 2>
		<script>
			history.back();
		</script>
		<CFABORT>
	</CFIF>
</CFIF>

<CFSET PAGE_TITLE="Select Distributors">
<CFSET GROUP="Contracts">

<CFPARAM name="FORM.button_caption"	default="continue">
<CFPARAM NAME="FORM.searchstring" DEFAULT="">
<CFPARAM NAME="FORM.SelectedITEMS" DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingitems" DEFAULT="0">
<CFPARAM NAME="FORM.LoadSavedDistributors"	Default="1">
<CFPARAM NAME="FORM.SelectSingleSearchResultOnly"	Default="#url.SelectSingleSearchResultOnly#">
<CFPARAM NAME="FORM.OnlyDistributorsUnderMe" Default="0">

<cfif isDefined("URL.AllowImportAll") AND URL.AllowImportAll EQ 1>
	<CFPARAM NAME="FORM.AllowImportAll"	Default="1">
<cfelse>
	<CFPARAM NAME="FORM.AllowImportAll"	Default="0">
</cfif>

<CFPARAM NAME="FORM.Distributor_Bill_To_ID" DEFAULT="">
<CFPARAM NAME="FORM.RebateRecipient_On" DEFAULT="0">
<CFPARAM NAME="FORM.ignoreMasterDeleted" DEFAULT="0">
<cfif Left(application.returned_customer_setting.customer_keyword, 1) NEQ "M" AND Right(application.returned_customer_setting.customer_keyword, 1) NEQ "N">
	<cfset FORM.OnlyDistributorsUnderMe = 0 />
</cfif>
<!---Sets it so that this only allows the user to select one distributor--->
<!------<CFSET FORM.SelectSingleSearchResultOnly = 1>----->

<cfset DistSearchSettingsManager = CreateObject("component", "components.settings.Labels.Labels") />
<cfset DistSearchSettings		 = DistSearchSettingsManager.getDistributorStaticSearchFieldsActive() />
<cfset DistSearchResultsColumnsDisplaySettings = DistSearchSettingsManager.getDistributorSearchFieldsDisplayStatus() />
<cfset DistSearchResultsColumnsDisplayAdditionalSettings = DistSearchSettingsManager.getDistributorStaticSearchFieldsDisplayStatus() />

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<!--- Turn on Planning group options only when appsetting is ON and the user does not visit from any flex application --->
<cfif appSettings.getPlanningGroups()>
  <cfif Form.FlexAppName eq "">
	<cfset showPlanningGroups = 0>       <!---29684 - exclude pg fields when not called from program search--->
  <cfelse>
	<cfset showPlanningGroups = 0>
  </cfif>
<cfelse>
	<cfset showPlanningGroups = 0>
</cfif>


<!---Only allows selection of distributors under my position--->
<cfif isDefined("FORM.OnlyDistributorsUnderMe")>
<cfif FORM.OnlyDistributorsUnderMe EQ 1>
	<CFSET FORM.OnlyDistributorsUnderMe = 1>
<cfelse>
	<CFSET FORM.OnlyDistributorsUnderMe = 0>
</cfif>
</cfif>
<!--- <cfoutput>#Form.OnlyDistributorsUnderMe#</cfoutput> --->

<CFPARAM NAME="startrow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<cf_Number_of_Rows maxrows=200>

<!---If there are existing saved distributors--->
<CFSET FORM.LoadSavedDistributors=0>
<CFIF FORM.LoadSavedDistributors EQ 1>
	<cfset useLakebaseForCheckForExistingDistributors = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_distributors")>
<cfif useLakebaseForCheckForExistingDistributors>
	<cftry>
		<cfset CheckForExistingDistributors = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_distributors", {
				"contract_main_id" = "eq.#cryp.value#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckForExistingDistributors = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckForExistingDistributors>
<cfquery name="CheckForExistingDistributors" Datasource="#application.datasource#">
		SELECT 	*
		FROM Contract_Distributors
		WHERE Contract_Main_ID = '#cryp.value#' AND deleted = 0
	</cfquery>
</cfif>
	<CFSET FORM.button_caption = "save">
	<CFSET FORM.FinalItemList = valuelist(CheckForExistingDistributors.BSA_Foodservice_Customers_ID)>
</CFIF>

<CFSET listofitemstodelete = "">
<CFLOOP INDEX="ListItem" LIST="#FORM.AlreadySelectedItems#" DELIMITERS=",">
	<CFIF listfind(FORM.SelectedITEMS, ListItem, ",") EQ 0>
		<CFSET listofitemstodelete = listappend(listofitemstodelete, ListItem, ",")>
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="ListItem" LIST="#FORM.SelectedITEMS#" DELIMITERS=",">
	<CFIF listfind(Form.FinalItemList, ListItem, ",") EQ 0>
		<CFSET Form.FinalItemList = listappend(FinalItemList, ListItem, ",")>
	</CFIF>
</CFLOOP>

<!---If only searching for a single result--->
<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
	<CFIF listlen(FORM.FinalItemList) GT 0>
		<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
			<CFSET LocationOfItemToDelete = listfind(FORM.FinalItemList,ListItem, ",")>
			<CFIF LocationOfItemToDelete GT 0>
				<CFSET Form.FinalItemList = listdeleteat(FORM.FinalItemList, listfind(FORM.FinalItemList,ListItem, ","), ",")>
			</CFIF>
		</CFLOOP>
	</CFIF>
<CFELSE>
	<cfif len(trim(FORM.SelectedITEMS)) GT 0>
		<CFSET Form.FinalItemList = FORM.SelectedITEMS>
    <!--- parent is redistribution do not reset the previous selection --->
    <cfelseif PageSource neq "redistribution">
		<CFSET Form.FinalItemList = "">
	</cfif>
</CFIF>

<CFIF FORM.finishedselectingitems EQ 1>
	<cfoutput>
		<cfif FORM.PARENTFORMNAME EQ 'flex'>
			<!--- implement call to externalinterface --->
			<script>
				// This function returns the appropriate reference,
				// depending on the browser.
				function getFlexApp(appName)
				{
				  if (navigator.appName.indexOf ("Microsoft") !=-1)
				  {
				    return opener.window[appName];
				  }
				  else
				  {
				    return opener.document[appName];
				  }
				}
				<cfif FORM.Type EQ "">
					function saveDistributor()
					{
					  getFlexApp('#encodeForJavaScript(FORM.FlexAppName)#').saveDistributor('#encodeForJavaScript(Form.FinalItemList)#');
					}
					saveDistributor();
				<cfelseif FORM.Type EQ "payee">
					function appendPayee()
					{
					  getFlexApp('#encodeForJavaScript(FORM.FlexAppName)#').appendPayee('#encodeForJavaScript(Form.FinalItemList)#');
					}
					appendPayee();
				</cfif>
				window.close();
			</script>
        <cfelse>
            <script>
			<cfif PageSource NEQ "AliasDistributorSearch" AND PageSource NEQ "ProgramRatesGrid">
				opener.document.all.#encodeForJavaScript(Form.ParentFormname)#.#encodeForJavaScript(Form.FieldName)#.value = '#encodeForJavaScript(Form.FinalItemList)#'
            </cfif>
				<!--- Start - Dev Note - Milan (20466) I copied the code below from search_screens/popup_search.cfm" --->
				<cfif PageSource IS "ProgramDistributorSearch">
				    window.opener.ShowPayeeInfo.style.display = "";
                    if(opener.document.all.#Form.ParentFormname#)
                    {
                        if (opener.document.all.#Form.ParentFormname#.AlreadySelectedVendor.value == 1
                        && (document.getElementById("window.opener.ShowPayeeSearch")))
                        {
                            window.opener.ShowPayeeSearch.style.display = "none";
                        }
                        callfireEvent(opener.document,opener.document.all.#encodeForJavaScript(Form.ParentFormname)#.Vendor_ID,'Change')
                    }
				</cfif>
				<cfif PageSource IS "AliasDistributorSearch">
					window.opener.getDistributorInfo('#encodeForJavaScript(Form.FinalItemList)#',1,1);
				<cfelseif PageSource IS "ProgramRatesGrid">
					window.opener.getDistributorInfo('#encodeForJavaScript(Form.FinalItemList)#',1);
				</cfif>

				<cfif PageSource IS "bbCorrections2020">
					opener.document.all.#encodeForJavaScript(Form.ParentFormname)#.shipTo.value = '#encodeForJavaScript(form.selected_ship_to)#';
				</cfif>
                <!--- update ship-to input on parent page --->
                <cfif structKeyExists(form, "parent_ShipTo") and form.parent_ShipTo gt ''>
                    let ship_to = opener.document.getElementsByName('#encodeForJavaScript(form.parent_ShipTo)#');
                    for (let i=0; i < ship_to.length; i++) {
                        ship_to[i].value = '#encodeForJavaScript(form.selected_ship_to)#';
                    }
                </cfif>

				<!--- End - I copied the code below from search_screens/popup_search.cfm" --->
				if(#ReloadForm# == 1)
				{
					opener.document.all.#encodeForJavaScript(Form.ParentFormname)#.submit();
                }

				window.close()
			</script>
		</cfif>
	</cfoutput>
	<CFABORT>
</CFIF>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT>
		function sortByThisItem(thisObj, thisSortItem, thisSortOrder)
		{
			isSearching = 1;
			var formObj;
			formObj = document.all.MyForm;
			formObj.sort_by.value = thisSortItem;
			formObj.sort_Order.value = thisSortOrder;
			if(formObj.frompage.value.length == 0)	formObj.frompage.value = 1;
			if(formObj.startrow.value.length == 0)	formObj.startrow.value = 1;
			formObj.submit();
			return false;
		}
	</SCRIPT>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="10" RIGHTMARGIN="10" TOPMARGIN="0" onLoad="if(document.all.searchstring){document.all.searchstring.focus();}">

<style>
TABLE.Maintable TD
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header
{
	font-size: 10px;
}
</style>


<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>

<!------ Business Segemnts ----->
<cfparam name="form.Business_Segment_Id" 	default="">
<cfparam name="form.businessSegmentsOn" 	default="0">
<!--- Start if not pactiv --->
	<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfif businessSegManager.isEnabledForDistributor()>
	<!--- Added "form.Business_Segment_ID eq 0" for WR 72405 --->
	<cfif form.Business_Segment_ID eq "" OR form.Business_Segment_ID eq 0>
		<cfset form.businessSegmentsOn = 1 />
		<cfset qGetBusSegments = businessSegManager.getActive(request.AccessStructure.User_ID) />
		<cfset form.Business_Segment_Id = ValueList(qGetBusSegments.Business_Segment_Id) />
	<cfelse>
		<cfset form.businessSegmentsOn = 1 />
	</cfif>
</cfif>
<!--- End if not pactiv --->
<cfif form.BusinessSegment neq "" and form.BusinessSegment neq "0">
	<cfset form.Business_Segment_Id = form.BusinessSegment />
</cfif>

<cfset objBillbackManager = CreateObject("component","components.billback.BillbackManager") />
<cfset qBillbackClosingMethods = objBillbackManager.getBillbackClosingMethods()>

<cfset Lookup_BS_General_Dropdowns = 0>
<cfif Left(application.returned_customer_setting.customer_keyword, 1) EQ "M" AND Right(application.returned_customer_setting.customer_keyword, 1) EQ "N">
	<cfset Lookup_BS_General_Dropdowns = 1>
</cfif>

<!---End queries limiting distributor list by permission--->
    <FORM ACTION="PM_select_distributors.cfm?CID=<CFOUTPUT>#URL.CID#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm">
	    <cfoutput>
        <!--- optional ship-to element on parent page --->
        <cfparam name="form.parent_ShipTo" default="">  
        <input type="hidden" name="parent_ShipTo" value="#EncodeForHTMLAttribute(form.parent_ShipTo)#">
        <!--- include selected ship-to value in posting form --->
        <input type="hidden" name="selected_ship_to">
        <INPUT NAME="OnlyDistributorsUnderMe" Type="Hidden" value="#EncodeForHTMLAttribute(FORM.OnlyDistributorsUnderMe)#">
		<INPUT TYPE="hidden" name="BusinessSegment" value="#EncodeForHTMLAttribute(BusinessSegment)#">
		<INPUT TYPE="hidden" name="LineofBusiness" value="#EncodeForHTMLAttribute(LineofBusiness)#">
		<INPUT TYPE="hidden" name="ShowActiveDistributorsOnly" value="#EncodeForHTMLAttribute(Form.ShowActiveDistributorsOnly)#">
		<INPUT TYPE="hidden" name="Business_Segment_Id" value="#EncodeForHTMLAttribute(Form.Business_Segment_Id)#">
		<input type="hidden" name="Single_Result_AutoSelect" value="#EncodeForHTMLAttribute(FORM.Single_Result_AutoSelect)#">
        <INPUT TYPE="Hidden" NAME="Distributor_Bill_To_ID" VALUE="#EncodeForHTMLAttribute(FORM.Distributor_Bill_To_ID)#">
        <INPUT TYPE="Hidden" NAME="RebateRecipient_On" VALUE="#EncodeForHTMLAttribute(FORM.RebateRecipient_On)#">
        <INPUT TYPE="Hidden" NAME="ignoreMasterDeleted" VALUE="#EncodeForHTMLAttribute(FORM.ignoreMasterDeleted)#">
        <INPUT TYPE="hidden" NAME="Dist_Name" value="#EncodeForHTMLAttribute(Dist_Name)#">
        <INPUT TYPE="hidden" NAME="AllowImportAll" value="#EncodeForHTMLAttribute(AllowImportAll)#">
        <INPUT TYPE="Hidden" NAME="ShowVendorAndBBClosingMethod" VALUE="#EncodeForHTMLAttribute(ShowVendorAndBBClosingMethod)#">
        <INPUT TYPE="Hidden" NAME="PageSource" VALUE="#EncodeForHTMLAttribute(PageSource)#">
        <INPUT TYPE="Hidden" NAME="ReloadForm" VALUE="#EncodeForHTMLAttribute(ReloadForm)#">
        </CFOUTPUT>
		<cfif isDefined("URL.AllowImportAll") AND URL.AllowImportAll EQ 1>
			<INPUT NAME="AllowImportAll" TYPE="HIDDEN" VALUE="1">
		</cfif>
<BR><CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">


<INPUT TYPE="Hidden" NAME="DOSEARCH" 	VALUE="1">
<INPUT TYPE="hidden" NAME="passed_form"	VALUE="<cfoutput>#EncodeForHTMLAttribute(form.passed_form)#</cfoutput>">
<INPUT TYPE="hidden" NAME="itemList" 	VALUE="<cfoutput>#EncodeForHTMLAttribute(form.itemList)#</cfoutput>">

<cfset sort_by_present = 0 />
	<cfset sort_order_present = 0 />
<cfif ShowVendorAndBBClosingMethod eq 1>
	<cfset sort_By_List="Name,Vendor ID,Vendor Name,BB Closing Method">
<cfelse>
	<cfset sort_By_List="Name,Ship To,Address,City,State,Postal Code,Country Code,Broker,Family,Buying Group,Customer Id">
</cfif>
<cfif ShowVendorAndBBClosingMethod eq 1>
	<cfset original_sort_By_Display_List="Name,Vendor ID,Vendor Name,BB Closing Method">
<cfelse>
	<cfset original_sort_By_Display_List="Name,Ship To,Address,City,State,Postal Code,Country Code">
	<cfset original_sort_By_Display_List = ListAppend(original_sort_By_Display_List, "#application.returned_customer_setting.broker_label_singular#", ",")>
	<cfset original_sort_By_Display_List = ListAppend(original_sort_By_Display_List, "#application.returned_customer_setting.family_name_label_singular#", ",")>
	<cfset original_sort_By_Display_List = ListAppend(original_sort_By_Display_List, "#application.returned_customer_setting.buying_group_label_singular#", ",")>
</cfif>



	<FIELDSET STYLE="padding:8px; border: 1px solid Blue;display:table;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput> search</LEGEND>
			<!---29684: get all distributor search fields from labels - settings--->
	    <cfset vars.qSearchField = DistSearchSettingsManager.getDistributorSearchFields()>
	    <!---<cfdump var="#vars.qSearchField#">--->
					<cfquery name="GetLinesOfBiz" Datasource="#application.datasource#">
						SELECT *
						FROM Line_Of_Business
						WHERE Deleted = 0
						<cfif form.businessSegmentsOn AND Lookup_BS_General_Dropdowns EQ 1>
							<cfif Len(FORM.BUSINESS_SEGMENT_ID) GT 0>
							and Business_segment_id IN (#FORM.BUSINESS_SEGMENT_ID#)
							<cfelse>
								<cfif application.returned_customer_setting.Business_Segments_On EQ 1>
									and 1 = 1
								<cfelse>
									and 1=2
								</cfif>
							</cfif>
						</cfif>
						ORDER BY Line_Of_Business_Name
					</cfquery>
			<TABLE border="0" align="center" cellspacing="4">
			<tr>
			<!---29684: loop to display search fields defined in labels settings--->
			<cfloop query="vars.qSearchField">
<!-------------------------------------------------------- Family ------------------------------------------------------------>
				<cfif vars.qSearchField.Distributor_Group_Level_Id eq "2">
					<TD>
						<span ID="searchItemLabel"><strong><CFOUTPUT>#application.returned_customer_setting.family_name_label_plural#</CFOUTPUT></strong></span><BR>
						<cfquery name="GetFamilyNames" Datasource="#application.datasource#">
							SELECT *
							FROM Distributor_Family
							WHERE Deleted = 0
							<cfif form.businessSegmentsOn>
								<cfif Len(FORM.BUSINESS_SEGMENT_ID) GT 0>
								and Business_segment_id IN (#FORM.BUSINESS_SEGMENT_ID#)
								<cfelse>
									<cfif application.returned_customer_setting.Business_Segments_On EQ 1>
										and 1 = 1
									<cfelse>
										and 1=2
									</cfif>
								</cfif>
							</cfif>
							ORDER BY Family_Name
						</cfquery>
						<CFPARAM NAME="FORM.Family_Name" DEFAULT="0">
						<SELECT NAME="Family_Name" style="width: 200px;" onkeydown="if (event.keyCode == 13) doSearchNow();">
							<OPTION VALUE="0">**ALL** <CFOUTPUT>#application.returned_customer_setting.family_name_label_plural#</CFOUTPUT></OPTION>
							<CFOUTPUT QUERY="GetFamilyNames"><OPTION VALUE="#trim(GetFamilyNames.Family_ID)#"#IIF(trim(FORM.Family_Name) EQ trim(GetFamilyNames.Family_ID), DE(" SELECTED"), DE(""))#>#trim(GetFamilyNames.Family_Name)#</OPTION></CFOUTPUT>
						</SELECT>
					</TD>
					<cfinclude template="_incTrSeparator.cfm" />

				<!--- Buying Groups --->
<!-------------------------------------------------------- Buying Group ------------------------------------------------------>
				<cfelseif vars.qSearchField.Distributor_Group_Level_Id eq "3">
					<TD>
						<span ID="searchItemLabel"><strong><CFOUTPUT>#application.returned_customer_setting.buying_group_label_plural#</CFOUTPUT></strong></span><BR>
						<cfquery name="GetBuyingGroups" Datasource="#application.datasource#">
							SELECT *
							FROM Distributor_Buying_Groups
							WHERE Deleted = 0
							<cfif form.businessSegmentsOn>
								<cfif Len(FORM.BUSINESS_SEGMENT_ID) GT 0>
								and Business_segment_id IN (#FORM.BUSINESS_SEGMENT_ID#)
								<cfelse>
									<cfif application.returned_customer_setting.Business_Segments_On EQ 1>
										and 1 = 1
									<cfelse>
										and 1=2
									</cfif>
								</cfif>
							</cfif>
							ORDER BY Buying_Group_Name
						</cfquery>
						<CFPARAM NAME="FORM.Buying_Group" DEFAULT="0">
						<SELECT NAME="Buying_Group" style="width: 200px;" onkeydown="if (event.keyCode == 13) doSearchNow();">
							<OPTION VALUE="0">**ALL** <CFOUTPUT>#application.returned_customer_setting.buying_group_label_plural#</CFOUTPUT></OPTION>
							<CFOUTPUT QUERY="GetBuyingGroups"><OPTION VALUE="#trim(GetBuyingGroups.Buying_Group_ID)#"#IIF(trim(FORM.Buying_Group) EQ trim(GetBuyingGroups.Buying_Group_ID), DE(" SELECTED"), DE(""))#>#trim(GetBuyingGroups.Buying_Group_Name)#</OPTION></CFOUTPUT>
						</SELECT>
					</TD>
					<cfinclude template="_incTrSeparator.cfm" />

				<!---Cust ID --->
<!-------------------------------------------------------- Customer ID ------------------------------------------------------->
				<cfelseif vars.qSearchField.Distributor_Group_Level_Id eq "5">
					<CFPARAM NAME="FORM.Cust_Id" DEFAULT="0">
					<cfif appSettings.getcustid_on() EQ 1>
						<TD>
							<cfoutput><span ID="searchItemLabel"><strong>#application.returned_customer_setting.Customer_Id_Label#</strong></span><BR></cfoutput>
							<cfquery name="GetCustIds" datasource="#application.datasource#">
								SELECT *
								FROM Distributor_Customer_ID
								WHERE Deleted = 0
								and Custid_Name IS NOT NULL
								ORDER BY Custid_Name
							</cfquery>

							<SELECT NAME="Cust_Id" style="width: 200px;"  onkeydown="if (event.keyCode == 13) doSearchNow();">
								<cfoutput>
									<OPTION VALUE="0">
										**ALL** #application.returned_customer_setting.Customer_Id_Label#
									</OPTION>
								</cfoutput>
								<CFOUTPUT QUERY="GetCustIds">
									<OPTION
										VALUE="#trim(GetCustIds.Customer_ID)#"
										#IIF(trim(FORM.Cust_Id) EQ trim(GetCustIds.Customer_ID), DE(" SELECTED"), DE(""))#>
											#trim(GetCustIds.Custid_Name)#
									</OPTION>
								</CFOUTPUT>
							</SELECT>
						</TD>
						<cfinclude template="_incTrSeparator.cfm" />
					</cfif>

<!-------------------------------------------------------- Line Of Biz ------------------------------------------------------->
				<cfelseif vars.qSearchField.Distributor_Group_Level_Id eq "4">
					<CFSET First_Time = NOT Isdefined("FORM.Line_Of_Biz")>
					<CFPARAM NAME="FORM.Line_Of_Biz" DEFAULT="0">
					<cfif application.returned_customer_setting.lob_search_switch EQ 1>
					<TD>
						<span ID="searchItemLabel"><CFOUTPUT><strong>#application.returned_customer_setting.lob_label_singular#</strong></CFOUTPUT></span><BR>
						<SELECT NAME="Line_Of_Biz" style="width: 200px;"  onkeydown="if (event.keyCode == 13) doSearchNow();">
						<!--- If there's only one LOB automatically select it so it won't give you the "you must select" popup --->
						<CFIF GetLinesOfBiz.Recordcount EQ 1>
							<cfoutput>
								<OPTION
									VALUE="#trim(GetLinesOfBiz.Line_Of_Business_ID)#"
									#IIF(trim(FORM.Line_Of_Biz) EQ trim(GetLinesOfBiz.Line_Of_Business_ID), DE(" SELECTED"), DE(""))#>
										#trim(GetLinesOfBiz.Line_Of_Business_Name)#
								</OPTION>
							</CFOUTPUT>
						<CFELSE>
								<OPTION VALUE="0">
									**ALL** <CFOUTPUT>#application.returned_customer_setting.lob_label_plural#</CFOUTPUT>
								</OPTION>
							<CFOUTPUT QUERY="GetLinesOfBiz">
								<CFIF Line_Of_Business EQ "#ListFirst(application.returned_customer_setting.Line_Business_Default,",")#" AND First_Time>
									<CFSET FORM.Line_Of_Biz = GetLinesOfBiz.Line_Of_Business_ID>
								</CFIF>
									<OPTION
										VALUE="#trim(GetLinesOfBiz.Line_Of_Business_ID)#"
										#IIF(trim(FORM.Line_Of_Biz) EQ trim(GetLinesOfBiz.Line_Of_Business_ID), DE(" SELECTED"), DE(""))#>
											#trim(GetLinesOfBiz.Line_Of_Business_Name)#
									</OPTION>
							</CFOUTPUT>
						</CFIF>
						</SELECT>
					</TD>
					<cfinclude template="_incTrSeparator.cfm" />
					</cfif>

<!-------------------------------------------------------- Zone -------------------------------------------------------------->
				<cfelseif vars.qSearchField.Distributor_Group_Level_Id eq "25">
					<TD>
						<span ID="searchItemLabel"><CFOUTPUT><strong>#application.returned_customer_setting.zone_label_singular#</strong></CFOUTPUT></span><BR>
						<CFQUERY NAME="GetZones" Datasource="#application.datasource#">
						SELECT *
						FROM Service_Zones
						WHERE len(Zone_Name) != 0 AND Deleted = 0
						<cfif (businessSegManager.isEnabled()) AND (appsettings.getPositionFieldsFilterOnProgramSegment()) AND (FORM.BUSINESS_SEGMENT_ID NEQ 0)><!--- D28618: Position Drop Down Fields filtered based on Program Business Segment  Modified IF Statement--->
							<cfif Len(FORM.BUSINESS_SEGMENT_ID) GT 0>
							and Business_segment_id IN (#FORM.BUSINESS_SEGMENT_ID#)
							</cfif>
						</cfif>
						ORDER BY Zone_Name
						</CFQUERY>
						<CFPARAM NAME="FORM.Zone_ID" DEFAULT="0">
						<SELECT NAME="Zone_ID" style="width: 200px;"  onkeydown="if (event.keyCode == 13) doSearchNow();">
							<OPTION VALUE="0">**ALL** <CFOUTPUT>#application.returned_customer_setting.zone_label_plural#</CFOUTPUT></OPTION>
							<CFOUTPUT QUERY="GetZones"><OPTION VALUE="#trim(GetZones.Service_Zone_ID)#"#IIF(trim(FORM.Zone_ID) EQ GetZones.Service_Zone_ID, DE(" SELECTED"), DE(""))#>#trim(GetZones.Zone_Name)#</OPTION></CFOUTPUT>
						</SELECT>
					</TD>
					<cfinclude template="_incTrSeparator.cfm" />

<!-------------------------------------------------------- Region ------------------------------------------------------------>
				<cfelseif vars.qSearchField.Distributor_Group_Level_Id eq "24">
					<TD>
						<span ID="searchItemLabel"><CFOUTPUT><strong>#application.returned_customer_setting.region_label_singular#</strong></CFOUTPUT></span><BR>
						<CFQUERY NAME="GetRegions" Datasource="#application.datasource#">
						SELECT *
						FROM Service_Regions
						WHERE len(Region_Name) != 0 AND Deleted = 0
						<cfif (businessSegManager.isEnabled()) AND (appsettings.getPositionFieldsFilterOnProgramSegment()) AND (FORM.BUSINESS_SEGMENT_ID NEQ 0)><!--- D28618: Position Drop Down Fields filtered based on Program Business Segment  Modified IF Statement--->
							<cfif Len(FORM.BUSINESS_SEGMENT_ID) GT 0>
							and Business_segment_id IN (#FORM.BUSINESS_SEGMENT_ID#)
							<cfelse>
									<cfif application.returned_customer_setting.Business_Segments_On EQ 1>
										and 1 = 1
									<cfelse>
										and 1=2
									</cfif>
							</cfif>
						</cfif>
						ORDER BY Region_Name
						</CFQUERY>
						<CFPARAM NAME="FORM.Region_ID" DEFAULT="0">
						<SELECT NAME="Region_ID" style="width: 200px;"  onkeydown="if (event.keyCode == 13) doSearchNow();">
							<OPTION VALUE="0">**ALL** <CFOUTPUT>#application.returned_customer_setting.region_label_plural#</CFOUTPUT></OPTION>
							<CFOUTPUT QUERY="GetRegions"><OPTION VALUE="#trim(GetRegions.Service_Region_ID)#"#IIF(trim(FORM.Region_ID) EQ getRegions.Service_Region_ID, DE(" SELECTED"), DE(""))#>#trim(GetRegions.Region_Name)#</OPTION></CFOUTPUT>
						</SELECT>
					</TD>
				<cfinclude template="_incTrSeparator.cfm" />

<!-------------------------------------------------------- Market ------------------------------------------------------------>
				<cfelseif vars.qSearchField.Distributor_Group_Level_Id eq "23">
		<!--- Get Foodservice Line Of Business ID --->
					<cfquery name="GetFirstDefaultBiz" dbtype="query">
						SELECT Line_Of_Business_ID
						FROM GetLinesOfBiz
						WHERE Line_Of_Business = '#TRIM(ListFirst(application.returned_customer_setting.Line_Business_Default,","))#'
						union
						SELECT Line_Of_Business_ID
						FROM GetLinesOfBiz
						WHERE Line_Of_Business = '#lJUSTIFY(ListFirst(application.returned_customer_setting.Line_Business_Default,","),10)#'
					</cfquery>
					<TD>
		<!--- Brokers --->
						<span ID="searchItemLabel"><CFOUTPUT><strong>#application.returned_customer_setting.broker_label_singular#</strong></CFOUTPUT></span><BR>
						<cfquery name="GetAllBrokers" Datasource="#application.datasource#">
							SELECT *
							FROM BSA_Foodservice_Brokers
							WHERE  	ACTIVE_CODE = 'A'
									AND Line_Of_Business_ID = '#GetFirstDefaultBiz.Line_Of_Business_ID#'
									AND Deleted = 0
									<cfif (businessSegManager.isEnabled()) AND (appsettings.getPositionFieldsFilterOnProgramSegment()) AND (FORM.BUSINESS_SEGMENT_ID NEQ 0)><!--- D28618: Position Drop Down Fields filtered based on Program Business Segment  Modified IF Statement--->
										<cfif Len(FORM.BUSINESS_SEGMENT_ID) GT 0>
										and Business_segment_id IN (#FORM.BUSINESS_SEGMENT_ID#)
										<cfelse>
											<cfif application.returned_customer_setting.Business_Segments_On EQ 1>
												and 1 = 1
											<cfelse>
												and 1=2
											</cfif>
										</cfif>
									</cfif>
							ORDER BY Broker_Name
						</cfquery>

						<cfquery name="GetBrokers" dbtype="query">
							SELECT DISTINCT Broker_Name
							FROM GetAllBrokers
						</cfquery>

						<CFPARAM NAME="FORM.Broker" DEFAULT="0">
						<SELECT NAME="Broker" style="width: 200px;"  onkeydown="if (event.keyCode == 13) doSearchNow();">
							<OPTION VALUE="0">**ALL** <CFOUTPUT>#application.returned_customer_setting.broker_label_plural#</CFOUTPUT></OPTION>
							<CFOUTPUT QUERY="GetBrokers">
								<cfset useLakebaseForGetBrokerIDs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getallbrokers")>
<cfif useLakebaseForGetBrokerIDs>
	<cftry>
		<cfset GetBrokerIDs = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getallbrokers", {
				"broker_name" = "eq.#GetBrokers.Broker_Name#",
				"order" = "broker_name.asc",
				"select" = "bsa_foodservice_brokers_id"
			}), "bsa_foodservice_brokers_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBrokerIDs = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBrokerIDs>
<cfquery name="GetBrokerIDs" dbtype="query">
									SELECT BSA_Foodservice_Brokers_ID
									FROM GetAllBrokers
									WHERE Broker_Name = '#GetBrokers.Broker_Name#'
									ORDER BY Broker_Name
								</cfquery>
</cfif>
								<cfset IDList = valueList(GetBrokerIDs.BSA_Foodservice_Brokers_ID)>
								<OPTION
									VALUE="#trim(IDList)#"
									#IIF(trim(FORM.Broker) EQ trim(IDList), DE(" SELECTED"), DE(""))#>
										#trim(GetBrokers.Broker_Name)#
								</OPTION>
							</CFOUTPUT>
						</SELECT>
					</TD>
					<cfinclude template="_incTrSeparator.cfm" />

<!-------------------------------------------------------- Planning Group ---------------------------------------------------->
				<cfelseif vars.qSearchField.Is_PG>
					<cfif showPlanningGroups>
						<cfif isDefined("GetTemplateInfo.First_Parent_ID")>
							<cfset FirstParentID = GetTemplateInfo.First_Parent_ID />
						<cfelse>
							<cfset FirstParentID = 0 />
						</cfif>
						<cfset DistGroupDataManager = CreateObject("component", "components.customer.Group.DataManager").init() />
						<cfset qGetTopLevelGroups = DistGroupDataManager.getDistributorLevels(
																						bActive = 1,
																						allowList = "",
																						disAllowList = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25",
																						Template_ID = "#FirstParentID#",
																						allowInSearch = 1
																						) />

						<cfloop query="qGetTopLevelGroups">
							<cfif qGetTopLevelGroups.Distributor_Group_Level_Id eq vars.qSearchField.Level_ID>
								<TD>
								<cfset DistributorAttributeDropDownName = "Distributor_Attribute_#Distributor_Group_Level_Type_ID#" />
								<!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START Added Business Segment ID--->
								<cfset groupDropDownBusinessSegmentFilter = 0 />
								<cfif Is_PG and form.businessSegmentsOn>
									<cfset groupDropDownBusinessSegmentFilter = Form.Business_Segment_Id />
								</cfif>

								<CFPARAM NAME="FORM.#DistributorAttributeDropDownName#" DEFAULT="0">
									<cfmodule 	template="/Customtags/DistributorGroupDropDown.cfm"
												groupLevelType = "#Distributor_Group_Level_Type_ID#"
												dropDownName = "#DistributorAttributeDropDownName#"
												selectedValue = "#Evaluate("FORM.#DistributorAttributeDropDownName#")#"
												cachedwithin="#APPLICATION.masterDataCacheSpan#"
											  	businessSegmentId="#groupDropDownBusinessSegmentFilter#"
			                  					FirstParentID = "#FirstParentID#"
												/>
							   <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END --->
								</TD>
								<cfinclude template="_incTrSeparator.cfm" />
							</cfif>
						</cfloop>
					</cfif>
					<!--- Planning group display ends --->

<!-------------------------------------------------------- Sort By ----------------------------------------------------------->
				<cfelseif vars.qSearchField.Field_Name eq "Sort By">
					<TD NOWRAP ALIGN="left">
					<strong>Sort By</strong><BR>

					<CFPARAM NAME="FORM.sort_by" DEFAULT="#Trim(ListFirst(sort_By_List))#">
					<CFOUTPUT>
					<CFSET sorted_sort_By_List=ListSort(original_sort_By_Display_List,"Text")>
					<SELECT ID="sort_by" NAME="sort_by"  onkeydown="if (event.keyCode == 13) doSearchNow();">
					<CFLOOP LIST="#sorted_sort_By_List#" INDEX="thisItem">
						<CFSET thisItem=Trim(thisItem)>
						<CFSET itemIndex=ListFindNoCase(original_sort_By_Display_List, thisItem, ",")>
						<CFSET thisItemValue = ListGetAt(sort_By_List, itemIndex, ",")>
						<cfif thisItemValue neq "Broker" or NOT appSettings.getDistributorMultiPosition()>
							<OPTION VALUE="#thisItemValue#"<CFIF thisItemValue EQ FORM.sort_by> SELECTED</CFIF>>#thisItem#</OPTION>
						</cfif>
					</CFLOOP>
					</SELECT>
					</CFOUTPUT>
					<cfset sort_by_present = 1 />
					</TD>
					<cfinclude template="_incTrSeparator.cfm" />

<!-------------------------------------------------------- Order ------------------------------------------------------------->
				<cfelseif vars.qSearchField.Field_Name eq "Order">
					<TD NOWRAP ALIGN="left">
					<strong>Order</strong><BR>
					<CFPARAM NAME="FORM.sort_Order" DEFAULT="ASC1">
					<SELECT ID="sort_Order" NAME="sort_Order" onkeydown="if (event.keyCode == 13) doSearchNow();">
						<OPTION VALUE="ASC"<CFIF FORM.sort_Order EQ "ASC"> SELECTED</CFIF>>Ascending</OPTION>
						<OPTION VALUE="DESC"<CFIF FORM.sort_Order EQ "DESC"> SELECTED</CFIF>>Descending</OPTION>
					</SELECT>
					<cfset sort_order_present = 1 />
					</TD>
					<cfinclude template="_incTrSeparator.cfm" />

<!-------------------------------------------------------- Name -------------------------------------------------------------->
				<cfelseif vars.qSearchField.Field_Name eq "Name">
					<TD><strong>Name</strong><br>
					<INPUT TYPE="Text" NAME="searchstring" STYLE="WIDTH:200px" SIZE="37" <CFIF len(trim(FORM.searchstring)) GT 0>VALUE="<CFOUTPUT>#trim(FORM.searchstring)#</CFOUTPUT>"</CFIF>  onkeydown="if (event.keyCode == 13) doSearchNow();">
					</TD>

					<cfinclude template="_incTrSeparator.cfm" />

<!-------------------------------------------------------- Ship To ----------------------------------------------------------->
				<cfelseif vars.qSearchField.Field_Name eq "Ship To">
 					<TD nowrap>
								<span ID="searchItemLabel"><cfoutput><strong>#application.returned_customer_setting.shard_ship_to_label#</strong></cfoutput></span>
								<B>
									<FONT COLOR="Red">[</FONT>
									<FONT COLOR="Blue"><A HREF="javascript:void(0)"  onclick="window.showModalDialog('/Common_Files/createList.cfm?passObj=Customers&passForm=MyForm',window,'dialogHeight:375px;dialogWidth:350px;center:yes;edge:raised'); return false;" >create list</A></FONT>
									<FONT COLOR="Red">]</FONT>
								</B><br>
								<INPUT SIZE="7" TYPE="TEXT" NAME="Ship_To" VALUE="<CFOUTPUT>#Form.Ship_To#</CFOUTPUT>"  onkeydown="if (event.keyCode == 13) doSearchNow();">

					</TD>
					<cfinclude template="_incTrSeparator.cfm" />

<!-------------------------------------------------------- Country ----------------------------------------------------------->
				<cfelseif vars.qSearchField.Field_Name eq "Country">
					<TD>
						<!--- Country code --->
						<CFQUERY NAME="getCountry" datasource="#application.datasource#">
							SELECT distinct c.country_code, country_name, Country_id
							FROM BSA_Foodservice_Customers bc
							Join  _Country c on bc.country_code = c.country_code
							<cfif appsettings.getShowExportPrograms()>
							 Inner Join Export_Lookup_Destination_Country On Export_Lookup_Destination_Country.country_code = c.country_code
							<cfelse>
							where active = 1
							</cfif>
							ORDER BY Country_id ASC
						</CFQUERY>
						<strong>Country</strong><BR>
						<CFOUTPUT>
								<SELECT NAME="Country_Code" STYLE="WIDTH:115px"  onkeydown="if (event.keyCode == 13) doSearchNow();">
								  <OPTION SELECTED value="0">**ALL** Countries</OPTION>
								    <CFLOOP QUERY="getCountry">
										<OPTION VALUE="#getCountry.Country_Code#" #IIF(trim(FORM.country_code) EQ trim(GetCountry.country_code), DE(" SELECTED"), DE(""))#>#getCountry.Country_Name#</OPTION>
									</CFLOOP>
							     </SELECT>
							</CFOUTPUT>

					</TD>
					<cfinclude template="_incTrSeparator.cfm" />

<!-------------------------------------------------------- State ------------------------------------------------------------->
				<cfelseif vars.qSearchField.Field_Name eq "State">
					<TD>
						<cfquery name="GetStates" datasource="#application.datasource#">
							SELECT DISTINCT State, State_Name, Country_Sort_Order
							FROM BSA_Foodservice_Customers c
							join _States s on s.State_Code =  c.state
							join _Country on s.Country_ID = _Country.Country_ID
							WHERE	LEN(State) > 0
							ORDER BY Country_Sort_Order, State
						</cfquery>

						<span ID="searchItemLabel"><strong>State</strong></span><BR>
						<SELECT NAME="State" STYLE="WIDTH:115px"  onkeydown="if (event.keyCode == 13) doSearchNow();">
							<OPTION VALUE="0">**ALL** States</OPTION>
							<CFOUTPUT QUERY="GetStates"><OPTION VALUE="#trim(GetStates.state)#"#IIF(trim(FORM.state) EQ trim(GetStates.state), DE(" SELECTED"), DE(""))#><CFIF len(trim(GetStates.state)) EQ 0>Sate Not Specified<CFELSE>#trim(GetStates.state_name)#</CFIF></OPTION></CFOUTPUT>
						</SELECT>
					</TD>
					<cfinclude template="_incTrSeparator.cfm" />

<!-------------------------------------------------------- Status ------------------------------------------------------------->
				<cfelseif vars.qSearchField.Field_Name eq "Status">
					<TD>
						<!--- Active/Inactive --->
						<span ID="searchItemLabel"><strong>Status</strong></span><BR>
						<SELECT NAME="Distributor_Status"  onkeydown="if (event.keyCode == 13) doSearchNow();">
							<CFIF Form.ShowActiveDistributorsOnly NEQ 1>
							<option VALUE="B" <CFIF FORM.Distributor_Status EQ "B">SELECTED</CFIF>>**All** Status</option>
							</CFIF>
							<option VALUE="A" <CFIF FORM.Distributor_Status EQ "A">SELECTED</CFIF>>Active</option>
							<CFIF Form.ShowActiveDistributorsOnly NEQ 1>
							<option VALUE="N" <CFIF FORM.Distributor_Status EQ "N">SELECTED</CFIF>>Inactive</option>
							<option VALUE="V" <CFIF FORM.Distributor_Status EQ "V">SELECTED</CFIF>>Valid</option>
							<option VALUE="I" <CFIF FORM.Distributor_Status EQ "I">SELECTED</CFIF>>Invalid</option>
							</CFIF>
						</SELECT>
					</TD>
					<cfinclude template="_incTrSeparator.cfm" />
				</cfif>
			</cfloop>    <!---end of vars.qSearchField loop--->

					<CFIF ShowVendorAndBBClosingMethod EQ 1>
							<TD>
								Default Vendor<br />
								<SELECT NAME="Default_Vendor" STYLE="WIDTH:105px"  onkeydown="if (event.keyCode == 13) doSearchNow();">
								  <OPTION SELECTED value="">**ALL** Vendors</OPTION>
									<OPTION VALUE="1" <CFIF Default_Vendor eq 1>SELECTED</cfif>>Yes</OPTION>
									<OPTION VALUE="2" <CFIF Default_Vendor eq 2>SELECTED</cfif>>No</OPTION>
							  </SELECT>
							</TD>
							<cfinclude template="_incTrSeparator.cfm" />
							<TD colspan="2">
								Default BB Closing Method<br />
								<SELECT NAME="Default_BB_Closing_Method" STYLE="WIDTH:160px"  onkeydown="if (event.keyCode == 13) doSearchNow();">
								  <OPTION SELECTED value="">**ALL** BB Closing Methods</OPTION>
									<cfoutput query="qBillbackClosingMethods">
										<cfif qBillbackClosingMethods.iBillback_Closing_Method_ID eq 1 OR qBillbackClosingMethods.iBillback_Closing_Method_ID eq 2>
											<option value="#iBillback_Closing_Method_ID#" <CFIF Default_BB_Closing_Method eq iBillback_Closing_Method_ID>SELECTED</cfif>>#vchBillback_Closing_Method_DESC#</option>
										</cfif>
									</cfoutput>
									<!--- Dev Note: Drachala; D27577 : Payable Settings, Default BB Closing Method add option callled 'Both'  START--->
									<cfif qBillbackClosingMethods.iBillback_Closing_Method_ID eq 1 OR qBillbackClosingMethods.iBillback_Closing_Method_ID eq 2>
									<option value="both" <cfif Default_BB_Closing_Method EQ "both">SELECTED</cfif>>Both</option>
									</cfif>
									<!--- Dev Note: Drachala; D27577 : Payable Settings, Default BB Closing Method add option callled 'Both'  END--->
							  </SELECT>
							</TD>
					</CFIF>

						<CFIF form.ShowBillToSearchFields EQ 1>
							<TD>
								<strong><cfoutput>#application.returned_customer_setting.BillTo_Label#</cfoutput> Number</strong><br />
								<INPUT NAME="BillTo_Number" TYPE="text" VALUE="<CFOUTPUT>#Form.BillTo_Number#</CFOUTPUT>"  onkeydown="if (event.keyCode == 13) doSearchNow();">

							</TD>
							<cfinclude template="_incTrSeparator.cfm" />
							<TD colspan="2">
								<strong><cfoutput>#application.returned_customer_setting.BillTo_Label#</cfoutput> Name</strong><br />
								<INPUT NAME="BillTo_Name" TYPE="text" VALUE="<CFOUTPUT>#Form.BillTo_Name#</CFOUTPUT>"  onkeydown="if (event.keyCode == 13) doSearchNow();">
							</TD>
						</CFIF>

					</TR>
					<TR>
					<TD ALIGN="center" NOWRAP colspan="100%">
					<!--- <IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10"> ---><BR>
					<!--- &nbsp;&nbsp; --->
					<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript: return doSearchNow();"> search <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)# </cfoutput></a><FONT COLOR="#FF0000">]</FONT></B>

					&nbsp;&nbsp;&nbsp;&nbsp;
					<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript: reset_Form_Fields();"> reset </a><FONT COLOR="#FF0000">]</FONT></B>
					</TD>
			</TR>
			</TABLE>

		<!--- D29781: Distributor Search and Sorting/Anand Rao/03-Jan-2012
			 if the Sort_by/sort_order is not included we will be adding a dummy sort_by and sort_order with
			 a display set to 0 so that the user cannot see this and also the script will work for sorting
			 the data.
		--->
<cfoutput>
			<cfif sort_by_present EQ 0>
				<CFSET sorted_sort_By_List=ListSort(original_sort_By_Display_List,"Text")>
					<SELECT ID="sort_by" NAME="sort_by" style="width:0px;display:none;"  onkeydown="if (event.keyCode == 13) doSearchNow();">
					<CFLOOP LIST="#sorted_sort_By_List#" INDEX="thisItem">
						<CFSET thisItem=Trim(thisItem)>
						<CFSET itemIndex=ListFindNoCase(original_sort_By_Display_List, thisItem, ",")>
						<CFSET thisItemValue = ListGetAt(sort_By_List, itemIndex, ",")>
						<cfif thisItemValue neq "Broker" or NOT appSettings.getDistributorMultiPosition()>
							<OPTION VALUE="#thisItemValue#"<CFIF thisItemValue EQ FORM.sort_by> SELECTED</CFIF>>#thisItem#</OPTION>
						</cfif>
					</CFLOOP>
					</SELECT>
			</cfif>
			<cfif sort_order_present EQ 0>
				<select id="sort_Order" name="sort_Order" style="width:0px;display:none;"  onkeydown="if (event.keyCode == 13) doSearchNow();">
					<option value="ASC"<cfif FORM.sort_Order EQ "ASC"> SELECTED</cfif>>Ascending</option>
					<option value="DESC"<cfif FORM.sort_Order EQ "DESC"> SELECTED</cfif>>Descending</option>
				</select>
			</cfif>
		</cfoutput>
		<!--- END: D29781: Distributor Search and Sorting/Anand Rao/03-Jan-2012  --->
	</FIELDSET>

	<script language="JavaScript">
	<cfoutput>
	function doSearchNow() {
		processingPopUpDisplay('div.customContainer'); //D51575
		//add restricted search
		var any_Filter   = false;
		var availOptions = "";

		//reset the hidden value used to communicate with createList

		$("input[name=passed_form]").val('');
		$("input[name=itemList]").val('');

		//D30246 : JS error on distributor search tool START
		if ($('input[name=Line_Of_Biz]').length) {
			<cfif (application.returned_customer_setting.lob_search_switch EQ 1)>
				if ( $('input[name=Line_Of_Biz]').val() != "0") {
					any_Filter = true;
				}
				availOptions = availOptions + "\n - #application.returned_customer_setting.lob_label_plural#";
			<cfelseif application.returned_customer_setting.lob_search_switch EQ 0>
				any_Filter = true;
			</cfif>
		}
		else {
			any_Filter = true;
		}

		//D30246 : JS error on distributor search tool END
		if (!any_Filter) {
			alert("You have to select at least one of the following filters" + availOptions);
		}
		else {
			$("input[name=startrow]").val(1);
			$("input[name=frompage]").val(1);
			$("form[name=MyForm]").submit();
		}
		return false;
	}
	</cfoutput>
	</script>


	<CFQUERY NAME="GetDistInfo" DATASOURCE="#application.datasource#">
		SELECT *
		FROM BSA_Foodservice_Customers
		WHERE BSA_Foodservice_Customers_ID <CFIF FORM.FinalItemList EQ 0>IS NULL<CFELSEIF listlen(FORM.FinalItemList) GT 0>IN(#listqualify(FORM.FinalItemList, "'", ",")#)<CFELSE>!= BSA_Foodservice_Customers_ID</CFIF> AND deleted = 0
    </CFQUERY>

<!------	<FIELDSET STYLE="padding:2px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">currently selected <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput></LEGEND>
		----->
		<CFSCRIPT>
		Border="Yes";
		BorderSize=1;
		BorderColor="Silver";
		Image="/images/plus3.gif";
		ImageOpen="/images/minus3.gif";
		TitleColor="Navy";
		TitleFont="Arial";
		TitleSize=8;
		IsClosed="No";
		WIDTH="100%";
	</CFSCRIPT>
	<CFSET Open_Layer_Caption = "currently selected #lcase(application.returned_customer_setting.distributor_label_plural)#">
		<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"
				BorderColor="#BorderColor#"
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Hide #Open_Layer_Caption#"
				TitleClosed="Show #Open_Layer_Caption#"
				TitleTooltip="#Open_Layer_Caption#"
				TitleColor="#TitleColor#"
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="Yes"
				Width="#width#">
			<CFIF GetDistInfo.recordcount GT 0>
				<TABLE border="0" cellspacing="3" cellpadding="3" align="left" WIDTH="700" BGCOLOR="white">
					<TR><CFOUTPUT QUERY="GetDistInfo">
						<TD NOWRAP BGCOLOR="eeeeee" STYLE="cursor: hand;" onClick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#GetDistInfo.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');">#GetDistInfo.name#</TD>
		 				<CFIF GetDistInfo.currentrow mod 4><CFELSE></TR><TR></CFIF>
					</CFOUTPUT>
				</TABLE>
			<CFELSE>
				<CFIF FORM.FinalItemList EQ 0>ALL <CFOUTPUT>#application.returned_customer_setting.distributor_label_plural#</CFOUTPUT><CFELSE>NONE</CFIF>
			</CFIF>
			<BR>
		</CF_openLayer>
	<!------</FIELDSET>----->

<br>


<CFIF FORM.DOSEARCH EQ 1>

<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->

<CFSET sql_Sort_By="Name">
<CFSWITCH expression="#Form.sort_by#">
	<CFCASE value="Name">
		<CFSET sql_Sort_By="Name">
	</CFCASE>
	<CFCASE value="Ship To">
		<CFSET sql_Sort_By="Shr_Ship_To">
	</CFCASE>
	<CFCASE value="Address">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Customers.Address_1">
	</CFCASE>
	<CFCASE value="City">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Customers.City">
	</CFCASE>
	<CFCASE value="State">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Customers.State">
	</CFCASE>
	<CFCASE value="Postal Code">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Customers.ZipCode">
	</CFCASE>
	<CFCASE value="Country Code">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Customers.Country_code">
	</CFCASE>
	<CFCASE value="Broker">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Brokers.Broker_Name">
	</CFCASE>
	<CFCASE value="Family">
		<CFSET sql_Sort_By="dbo.Distributor_Family.Family_Name">
	</CFCASE>
	<CFCASE value="Buying Group">
		<CFSET sql_Sort_By="dbo.Distributor_Buying_Groups.Buying_Group_Name">
	</CFCASE>
	<CFCASE value="Customer Id">
		<CFSET sql_Sort_By="dbo.Distributor_Customer_ID.Custid_Name">
	</CFCASE>
	<CFCASE value="Vendor Id">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Customers.Default_Vendor_ID">
	</CFCASE>
	<CFCASE value="Vendor Name">
		<CFSET sql_Sort_By="dbo.Vendor_Master.Vendor_Name">
	</CFCASE>
	<CFCASE value="BB Closing Method">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Customers.Default_Billback_Closing_Method_ID">
	</CFCASE>
</CFSWITCH>

<CFSET sql_Sort_By_Order=" ASC">
<CFIF Form.sort_Order EQ "DESC">
	<CFSET sql_Sort_By_Order=" DESC">
</CFIF>

<!--- If passing it in the url for Pactiv--->
<CFIF LineofBusiness NEQ 0>
	<CFSET FORM.Line_Of_Biz = LineofBusiness>
</CFIF>
<CFIF Form.ShowActiveDistributorsOnly EQ 1>
	<CFSET FORM.Distributor_Status = "A" />
</CFIF>
<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->

	<!---Queries that only need to be run if limiting the results to Distributors the user has permission to see--->
	<cfif FORM.OnlyDistributorsUnderMe IS 1>
		<!---Gets the current user's position--->
		<CFQUERY NAME="getUserPosition" DATASOURCE="#application.datasource#">
			SELECT 	User_Positions_ID
			FROM 	User_Position_Holders
			WHERE 	User_ID = '#request.AccessStructure.user_id#'
			AND 	Deleted = 0
		</CFQUERY>
	</cfif>

	<CFSET form.searchstring = trim(form.searchstring)>
	<CFQUERY NAME="TheQuery" DATASOURCE="#application.datasource#">
		DECLARE @Get_Marktets_Below_Me table
		(
		  Service_Market_ID	nvarchar(50)	NOT NULL
		)

		<cfif FORM.OnlyDistributorsUnderMe IS 1>

			INSERT INTO @Get_Marktets_Below_Me (Service_Market_ID)
			SELECT DISTINCT Service_Market_ID FROM V_Markets_Below_Me WHERE User_Positions_ID IN (#valueList(getUserPosition.User_Positions_ID)#)

		</cfif>

		SELECT     	DISTINCT BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID, BSA_Foodservice_Customers.Name,
					BSA_Foodservice_Customers.Address_1, BSA_Foodservice_Customers.City, BSA_Foodservice_Customers.State,
					BSA_Foodservice_Customers.ZipCode, BSA_Foodservice_Customers.Country_Code, Distributor_Family.Family_Name, BSA_Foodservice_Customers.Ship_To,
					BSA_Foodservice_Customers.Active_Code,
					<cfif form.businessSegmentsOn>
					Business_Segment.Business_Unit_Desc,
					</cfif>
					<cfif NOT appSettings.getDistributorMultiPosition()>
					BSA_Foodservice_Brokers.Broker_Name, Service_Zones.Zone_Name, Service_Regions.Region_Name,
					</cfif>
					Distributor_Buying_Groups.Buying_Group_Name,  BSA_Foodservice_Customers.Shr_Ship_To,
					BSA_Foodservice_Customers.Default_Vendor_ID,
					BSA_Foodservice_Customers.Default_Billback_Closing_Method_ID,
					Vendor_Master.Vendor_Name,
					Billback_Closing_Methods.vchBillback_Closing_Method_Desc
		FROM		BSA_Foodservice_Customers
					INNER JOIN	Distributor_Family ON BSA_Foodservice_Customers.Family_ID = Distributor_Family.Family_ID
					INNER JOIN	Distributor_Buying_Groups ON BSA_Foodservice_Customers.Buying_Group_ID = Distributor_Buying_Groups.Buying_Group_ID
					INNER JOIN	Line_Of_Business ON BSA_Foodservice_Customers.Line_Of_Business_ID = Line_Of_Business.Line_Of_Business_ID
					<cfif form.businessSegmentsOn>
					Inner Join Business_Segment On Business_Segment.deleted = 0 AND Business_Segment.Business_Segment_ID = BSA_Foodservice_Customers.Business_Segment_ID
					<cfif Len(FORM.BUSINESS_SEGMENT_ID) GT 0 and FORM.BUSINESS_SEGMENT_ID neq "0">
					and Business_Segment.Business_segment_id IN (#FORM.BUSINESS_SEGMENT_ID#)
					<cfelse>
						<cfif application.returned_customer_setting.Business_Segments_On EQ 1>
							and 1 = 1
						<cfelse>
							and 1=2
						</cfif>
					</cfif>
					</cfif>
					<cfif appSettings.getDistributorMultiPosition()>
					LEFT JOIN Market_Distributor ON Market_Distributor.Deleted = 0 AND Market_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
					LEFT JOIN Service_Markets ON Service_Markets.Service_Market_ID = Market_Distributor.Service_Market_ID
					</cfif>

					LEFT
					 JOIN	BSA_Foodservice_Brokers ON
					<cfif appSettings.getDistributorMultiPosition()>
					Service_Markets.Service_Market_ID = BSA_Foodservice_Brokers.Service_Market_ID
					<cfelse>
					BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
					</cfif>
					LEFT JOIN	Service_Regions ON
					<cfif appSettings.getDistributorMultiPosition()>
					Service_Markets.Service_Region_ID = Service_Regions.Service_Region_ID
					<cfelse>
					BSA_Foodservice_Brokers.Service_Region_ID = Service_Regions.Service_Region_ID
					</cfif>
					LEFT JOIN	Service_Zones ON Service_Regions.Service_Zone_ID = Service_Zones.Service_Zone_ID
					LEFT JOIN Distributor_Customer_ID	ON Distributor_Customer_ID.Customer_ID = BSA_Foodservice_Customers.Customer_ID
					LEFT JOIN Vendor_Master ON BSA_Foodservice_Customers.Default_Vendor_ID = Vendor_Master.Vendor_ID
 			 	                              AND Vendor_Master.Deleted = 0  <!---26298 modified for consistency, vendor master search filters out deleted records--->
					LEFT JOIN Billback_Closing_Methods ON BSA_Foodservice_Customers.Default_Billback_Closing_Method_ID = Billback_Closing_Methods.iBillback_Closing_Method_ID

					<cfif showPlanningGroups>
 					<cfif isDefined("qGetTopLevelGroups")>
						<cfset counter = 0 />
						<cfloop query="qGetTopLevelGroups">
    					<!--- TODO only do the below for PG_Flag = 1  put a if checking here --->
							<cfset counter = counter + 1 />
              <cfif (qGetTopLevelGroups.IS_PG EQ 1)>
							  <cfset DistributorAttributeDropDownName = "Distributor_Attribute_#Distributor_Group_Level_Type_ID#" />
  							<CFIF isDefined("FORM.#DistributorAttributeDropDownName#")>
  								<cfset DistributorAttributeDropDownValue = Evaluate("FORM.#DistributorAttributeDropDownName#") />
    								<cfif DistributorAttributeDropDownValue NEQ "" AND DistributorAttributeDropDownValue NEQ "0">
                    INNER JOIN PG_Customer_Members PGCM#Counter# ON PGCM#Counter#.PG_Type_ID = #Distributor_Group_Level_Type_ID#
                    AND PGCM#Counter#.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
                    AND PGCM#Counter#.Deleted = 0
                    AND PGCM#Counter#.PG_Customer_Category_ID = '#DistributorAttributeDropDownValue#'
    								</cfif>
  							</CFIF>
              </cfif><!--- checking for IS_PG Ends--->
						</cfloop>
						</cfif>
</cfif>
				<CFIF form.ShowBillToSearchFields EQ 1>
					INNER JOIN Distributor_Bill_To ON Distributor_Bill_To.Distributor_Bill_To_ID = BSA_Foodservice_Customers.Distributor_Bill_To_ID
				</CFIF>
		WHERE		0 = 0
					<!---
					<cfif NOT (IsDefined("form.ignoreMasterDeleted") AND form.ignoreMasterDeleted EQ 1)>
					AND dbo.BSA_Foodservice_Customers.DELETED = 0
					</cfif>
					 --->
					<!--- Distributor Status --->
					<CFIF FORM.Distributor_Status EQ "A">
						AND dbo.BSA_Foodservice_Customers.Active_Code = 'A' AND dbo.BSA_Foodservice_Customers.DELETED = 0
					<CFELSEIF FORM.Distributor_Status EQ "N">
						AND NOT (dbo.BSA_Foodservice_Customers.Active_Code = 'A' AND dbo.BSA_Foodservice_Customers.DELETED = 0)
					<CFELSEIF FORM.Distributor_Status EQ "V">
						AND dbo.BSA_Foodservice_Customers.Deleted = 0
					<CFELSEIF FORM.Distributor_Status EQ "I">
						AND dbo.BSA_Foodservice_Customers.Deleted = 1
					<CFELSEIF FORM.Distributor_Status EQ "B">
						AND (dbo.BSA_Foodservice_Customers.Active_Code IN ('A','N'))
					</CFIF>
					<CFIF FORM.Distributor_Bill_To_ID NEQ "">
						AND BSA_Foodservice_Customers.Distributor_Bill_To_ID = '#FORM.Distributor_Bill_To_ID#'
					</CFIF>

					<!---If limited by distributors they can see--->
					<cfif FORM.OnlyDistributorsUnderMe IS 1 and FORM.Distributor_Status NEQ "N">
						<cfif appsettings.getDistributorMultiPosition()>
								AND	Service_Markets.Service_Market_ID IN (SELECT Service_Market_ID FROM @Get_Marktets_Below_Me)
						<cfelse>
							AND	BSA_Foodservice_Brokers.Service_Market_ID IN (SELECT Service_Market_ID FROM @Get_Marktets_Below_Me)
						</cfif>
					</cfif>

						<cfif Form.Dist_Name neq "">
						AND BSA_Foodservice_Customers.Name LIKE '#Form.Dist_Name#%'
						</cfif>
					<!---If we are coming from the create list form then use this criteria only,
					otherwise use the rest of the logic--->
					<cfif form.passed_form NEQ "" and form.itemList NEQ "">
						AND (
									dbo.BSA_Foodservice_Customers.Shr_Ship_To in ( #PreserveSingleQuotes(form.itemList)# )
									OR
									dbo.BSA_Foodservice_Customers.Ship_To in ( #PreserveSingleQuotes(form.itemList)# )
								)
					<cfelse>

						<CFIF Len(Trim(Form.Ship_To)) GT 0>
							AND (dbo.BSA_Foodservice_Customers.Shr_Ship_To LIKE '%#Form.Ship_To#%'
								OR dbo.BSA_Foodservice_Customers.Ship_To LIKE '%#Form.Ship_To#%'
								OR dbo.BSA_Foodservice_Customers.Keyword_Search LIKE '%#Form.Ship_To#%'
								)
						</CFIF>

						<!--- family name --->
						<CFIF FORM.Family_Name NEQ 0>
							AND dbo.BSA_Foodservice_Customers.Family_ID = '#FORM.Family_Name#'
						</CFIF>

						<!--- buying group --->
						<CFIF FORM.Buying_Group NEQ 0>
							AND dbo.BSA_Foodservice_Customers.Buying_Group_ID = '#FORM.Buying_Group#'
						</CFIF>
						<!--- Cust ID --->
						<CFIF FORM.Cust_Id NEQ 0>
							AND dbo.Distributor_Customer_ID.Customer_ID = '#FORM.Cust_Id#'
						</CFIF>


						<!--- Line Of Business --->
						<CFIF FORM.Line_Of_Biz NEQ 0 AND FORM.Line_Of_Biz NEQ "">
							AND dbo.BSA_Foodservice_Customers.Line_Of_Business_ID = '#FORM.Line_Of_Biz#'
						</CFIF>

						<!--- Zone --->
						<CFIF FORM.Zone_ID NEQ 0>
							AND dbo.Service_Zones.Service_Zone_ID = '#FORM.Zone_ID#'
						</CFIF>

						<!--- Region --->
						<CFIF FORM.Region_ID NEQ 0>
							AND dbo.Service_Regions.Service_Region_ID = '#FORM.Region_ID#'
						</CFIF>

						<!--- Broker --->
						<CFIF FORM.Broker NEQ 0>
							AND dbo.BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID IN (#ListQualify(FORM.Broker, "'", ",", "ALL")#)
						</CFIF>

						<CFIF FORM.State NEQ 0>
							AND BSA_Foodservice_Customers.state = '#FORM.State#'
						</CFIF>
						<CFIF FORM.Country_code NEQ 0>
							AND BSA_Foodservice_Customers.Country_Code = '#FORM.Country_Code#'
						</CFIF>

						<CFIF len(trim(FORM.searchstring)) GT 0>
							AND
							(
								BSA_Foodservice_Customers.Name LIKE '%#form.searchstring#%'
								<!---
								OR
								BSA_Foodservice_Customers.City LIKE '%#form.searchstring#%'
								--->
								OR
								Distributor_Family.Family_Name LIKE '%#form.searchstring#%'
								<CFIF isnumeric(form.searchstring)>
									OR
									BSA_Foodservice_Customers.Shr_Family LIKE '%#form.searchstring#%'
								</CFIF>
								OR
								BSA_Foodservice_Customers.Keyword_Search LIKE '%#form.searchstring#%'
								<!---
								<cfif NOT appSettings.getDistributorMultiPosition()>
								OR BSA_Foodservice_Brokers.Broker_Name LIKE '%#form.searchstring#%'
								</cfif>
								--->
							)
						</CFIF>

						<!--- If any vendor exist for a distributor --->
						<CFIF Default_Vendor eq "1">
						AND isnull(nullif(BSA_Foodservice_Customers.Default_Vendor_ID,''),0) <> 0
						<!--- If any vendor does not exist for a distributor --->
						<CFELSEIF Default_Vendor eq "2">
						AND isnull(nullif(BSA_Foodservice_Customers.Default_Vendor_ID,''),0) = 0
						</CFIF>
<!--- Dev Note: Drachala; D27577 : Payable Settings, Default BB Closing Method add option callled 'Both'  START--->
						<CFIF (Default_BB_Closing_Method neq "") AND (Default_BB_Closing_Method neq "both")>
						AND BSA_Foodservice_Customers.Default_Billback_Closing_Method_ID = '#Form.Default_BB_Closing_Method#'
						<CFELSEIF (Default_BB_Closing_Method neq "") AND (Default_BB_Closing_Method eq "both")>
						AND BSA_Foodservice_Customers.Default_Billback_Closing_Method_ID IN(1,2)
						</CFIF>
<!--- Dev Note: Drachala; D27577 : Payable Settings, Default BB Closing Method add option callled 'Both'  END--->
						<cfif Form.Dist_Name neq "">
						AND BSA_Foodservice_Customers.Name LIKE '#Form.Dist_Name#%'
						</cfif>

					</cfif>
					<cfif showPlanningGroups>
						<cfif isDefined("qGetTopLevelGroups")>
							<cfloop query="qGetTopLevelGroups">
	            <!--- TODO only if PG_Flag = 0 then do this loop put a if condition checking here   --->
	              <cfif (qGetTopLevelGroups.IS_PG EQ 0)>
								  <cfset DistributorAttributeDropDownName = "Distributor_Attribute_#Distributor_Group_Level_Type_ID#" />
								  <CFIF isDefined("FORM.#DistributorAttributeDropDownName#")>
									  <cfset DistributorAttributeDropDownValue = Evaluate("FORM.#DistributorAttributeDropDownName#") />
									  <cfif DistributorAttributeDropDownValue NEQ "" AND DistributorAttributeDropDownValue NEQ "0">
	                	 AND BSA_Foodservice_Customers.#Distributor_Group_Attribute_Master_ID_Field# = '#DistributorAttributeDropDownValue#'
									  </cfif>
								  </CFIF>
	              </cfif>
							</cfloop>
							</cfif>
						</cfif>

					<CFIF form.ShowBillToSearchFields EQ 1>
						<CFIF len(trim(FORM.BillTo_Number)) GT 0>
							AND Distributor_Bill_To.Shr_Bill_To LIKE '%#trim(FORM.BillTo_Number)#%'
						</CFIF>
						<CFIF len(trim(FORM.BillTo_Name)) GT 0>
							AND Distributor_Bill_To.Name LIKE '%#trim(FORM.BillTo_Name)#%'
						</CFIF>
					</CFIF>

		ORDER BY #sql_Sort_By# #sql_Sort_By_Order#
	</CFQUERY>

	<SCRIPT>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			function CA() {
				if(1==1) {
					for (var i=0;i<MyForm.elements.length;i++)
						{
							var e = MyForm.elements[i];
							if ((e.name != 'allbox') && (e.type=='checkbox') && (e.name != 'ALLINCATEGORY')) {
								e.checked = MyForm.allbox.checked;
							}
						}
				//toggleRowColors()
				}
				else {
					document.all.allbox.checked = false;
				}
			}
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	</SCRIPT>

	<CFIF TheQuery.recordcount>
		<div style="margin:0 0 10px 5px;">
			<a href="#" onClick="javascript:finishedSearching()"><cfoutput>#application.util.string.actionLinkFormat2( "save" )#</cfoutput></a>
		</div>
	</cfif>

<!--- D51575 :: 'Please Wait' Indicator    8.0 Release START --->
<div class="customContainer" style="display:none;width:100%;"></div>
<!--- D51575 :: 'Please Wait' Indicator    8.0 Release END --->


	<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF TheQuery.recordcount EQ 1>Is<CFELSE>are</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1><cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput><CFELSE><cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput></CFIF> that <CFIF TheQuery.recordcount EQ 1>matched<CFELSE>match</CFIF> the above criteria</LEGEND>
		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF TheQuery.recordcount GT 0>
			<TABLE border="0" <cfif ShowVendorAndBBClosingMethod eq 1>width="700"</cfif>cellspacing="0" cellpadding="3" align="center" CLASS="Maintable">
				<TR ID="header" BGCOLOR="#ffce84">
					<CFIF FORM.SelectSingleSearchResultOnly EQ 0><TD align="center"><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Distributors"></TD><CFELSE><td>&nbsp;</td></CFIF>
				<cfoutput>

				<cfset InitHeader()>

				<CFSET Counter = 1>
				<CFLOOP LIST="#HeaderNameList#" INDEX="this_Header" DELIMITERS=",">
				<CFSET sortImage="">
				<CFIF listgetat(HeaderColumnList,Counter) EQ Form.SORT_BY>
					<CFIF FORM.SORT_ORDER EQ "DESC">
						<CFSET New_Sort_Order="ASC">
						<CFSET sortImage="up_1.gif">
					<CFELSE>
						<CFSET New_Sort_Order="DESC">
						<CFSET sortImage="down_1.gif">
					</CFIF>
					<CFELSE>
						<CFSET New_Sort_Order="ASC">
					</CFIF>
					<TD ID="header" align="left" NOWRAP><A HREF="##" OnClick="javaScript: return sortByThisItem(this,'#listgetat(HeaderColumnList,Counter)#','#New_Sort_Order#');"><b>#this_Header#</b><CFIF Len(sortImage) GT 0> <IMG BORDER="0" SRC="/Images/#sortImage#"></CFIF></A></TD>
					<CFSET Counter = Counter + 1>
					</CFLOOP>
				</cfoutput>
<!--- 					<TD align="left" ID="header"><B>Name / Ship To</B></TD>
					<TD ID="header"><B>Address</B></TD>
					<TD ID="header"><B>Broker</B></TD>
					<TD ID="header"><B>Family / Buying Group</B></TD> --->
				</TR>

			<CFOUTPUT QUERY="TheQuery" startrow="#StartRow#" maxrows="#MaxRows#">
				<TR STYLE="cursor:pointer;" <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
                    <cfset local.ship_to = appSettings.get_Setting('Display_Distributor_ID') eq '1'
                                                ? TheQuery.Shr_Ship_To
                                                : TheQuery.Ship_To>
					<cfif FORM.PageSource EQ "redistribution">
						<cfset local.ship_to = TheQuery.Ship_To />
					</cfif>








                    <!--- ShowVendorAndBBClosingMethod eq 0 -- When we are calling this page to assign default vendor and bilback closing method, the checkboxes need to be checked for already selected distributors --->
					<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
						<TD align="center">
							<INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Foodservice_Customers_ID)#" ship_to="#local.ship_to#"
							<CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0>
								<CFIF ShowVendorAndBBClosingMethod eq 0>
									CHECKED
								</CFIF>
								<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.BSA_Foodservice_Customers_ID), ",")>
							</CFIF>
							>
						</TD>
					<CFELSE>
						<TD align="center"><INPUT type="Radio" NAME="SelectedITEMS" ship_to="#local.ship_to#" <cfif PageSource IS "ProgramDistributorSearch">VALUE="#trim(TheQuery.BSA_Foodservice_Customers_ID)#"<cfelse>VALUE="#trim(TheQuery.BSA_Foodservice_Customers_ID)#"</cfif> <CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0>
						CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.BSA_Foodservice_Customers_ID), ",")></CFIF>></TD>
					</CFIF>









					<TD onClick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#TheQuery.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;" NOWRAP>#TheQuery.Name#
                        <BR>#local.ship_to#&nbsp;</TD>
					<cfif ShowVendorAndBBClosingMethod eq 1>
						<TD align="left"><cfif TheQuery.Default_Vendor_ID neq "">#TheQuery.Default_Vendor_ID#<cfelse><span style="color:red">--none--</span></cfif></TD>
						<TD align="left"><cfif TheQuery.Vendor_Name neq "">#TheQuery.Vendor_Name#<cfelse><span style="color:red">--none--</span></cfif></TD>
						<TD align="left"><cfif TheQuery.vchBillback_Closing_Method_Desc neq "">#TheQuery.vchBillback_Closing_Method_Desc#<cfelse><span style="color:red">--none--</span></cfif></TD>
					<cfelse>
					<cfif DistResults_DisplayAddress>
					<TD onClick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#TheQuery.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;">#TheQuery.Address_1#<BR>#TheQuery.City#,#TheQuery.State# #TheQuery.ZipCode#&nbsp;#Ucase(TheQuery.Country_Code)#</TD>
					</cfif>
					<cfif NOT appSettings.getDistributorMultiPosition() AND DistResults_DisplayBroker>
					<TD onClick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#TheQuery.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;" >#TheQuery.Broker_Name#&nbsp;</TD>
					</cfif>
					<cfif DistResults_DisplayFamily OR DistResults_DisplayBuyingGroup>
					<TD onClick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#TheQuery.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;" NOWRAP><cfif DistResults_DisplayFamily>#TheQuery.Family_Name#<BR></cfif><cfif DistResults_DisplayBuyingGroup>#TheQuery.Buying_Group_Name#</cfif>&nbsp;</TD>
					</cfif>
 				   <cfif form.businessSegmentsOn AND DistResults_DisplayBusinessSegment>
		             <td align="center">#TheQuery.Business_Unit_Desc#&nbsp;</td>
					</cfif>
					</cfif>
					</TR>
			</CFOUTPUT>
			</TABLE>

			<DIV ALIGN="center" STYLE="font-size: 12px; color: Red;">
			<CF_Next_Previous_For_Forms
				formname="MyForm"
				query="TheQuery"
				maxpages="40"
				previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
				next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
				previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				addparams=""
			>
		</CFIF>
		<script language="javascript">
		function showstartingWith(sValue)
		{
			document.MyForm.Dist_Name.value =sValue;
			doSearchNow();
		}
		</script>
		<tr>
		<TABLE CELLPADDING="2" CELLSPACING="1" BORDER="0" ALIGN="CENTER"><TR>
		<cfoutput>
			<cfloop index="LoopCount" from="65" to="90">
					<TD>
						<B>
						<CFIF chr(LoopCount) EQ form.Dist_Name>
							<FONT COLOR="FF0000">[</FONT>
						</CFIF>
						<A HREF="##" onClick="javaScript: return showstartingWith('#chr(LoopCount)#');">#chr(LoopCount)#</A>
					 <CFIF chr(LoopCount) EQ form.Dist_Name>
						<FONT COLOR="FF0000">]</FONT></CFIF>
						</B>
					</TD>
			</cfloop>
			<cfloop index="LoopCount" from="0" to="9">
					<TD>
						<B>
						<CFIF LoopCount EQ form.Dist_Name>
							<FONT COLOR="FF0000">[</FONT>
						</CFIF>
						<A HREF="##" onClick="javaScript: return showstartingWith('#LoopCount#');">#LoopCount#</A>
						<CFIF LoopCount EQ form.Dist_Name>
							<FONT COLOR="FF0000">]</FONT></CFIF>
						</B>
					</TD>
			</cfloop>
					<TD>
						<B>
						<CFIF "" EQ form.Dist_Name>
						 <FONT COLOR="FF0000">[</FONT>
						</CFIF>
						<A HREF="##" onClick="javaScript: return showstartingWith('');">ALL</A>
					 <CFIF "" EQ form.Dist_Name>
						<FONT COLOR="FF0000">]</FONT></CFIF>
						</B>
					</TD>
	</cfoutput>
	 </TR>
	</TABLE>
	</tr>
	</FIELDSET>

</CFIF>
	<CFPARAM name="TheQuery.Recordcount" default="0">
	<SCRIPT>
		function resetform() {
			document.all.FinalItemList.value = 0;
			document.all.AlreadySelectedItems.value = 0;

			<CFIF TheQuery.Recordcount GT 0>
				document.all.SelectedITEMS.value = 0;
				for(var x=0; x<document.all.MyForm.elements.length;x++) {
					document.all.MyForm.elements[x].checked = false
				}

			</CFIF>
			document.all.MyForm.submit();
		}
	//load the name of the select boxes to hide
	//findselectboxes()

	</SCRIPT>
<INPUT TYPE="hidden" NAME="ParentFormname" 						VALUE="<CFOUTPUT>#EncodeForHTMLAttribute(FORM.ParentFormname)#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="FieldName" 						VALUE="<CFOUTPUT>#EncodeForHTMLAttribute(FORM.FieldName)#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="FinalItemList" ID="FinalItemList" VALUE="<CFOUTPUT>#EncodeForHTMLAttribute(Form.FinalItemList)#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="AlreadySelectedItems" ID="AlreadySelectedItems" VALUE="<CFOUTPUT>#EncodeForHTMLAttribute(Form.AlreadySelectedItems)#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="finishedselectingitems" VALUE="0">
<INPUT TYPE="hidden" NAME="LoadSavedDistributors" VALUE="0">
<input type="hidden" name="button_caption" value="<CFOUTPUT>#EncodeForHTMLAttribute(FORM.Button_Caption)#</CFOUTPUT>">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="<CFOUTPUT>#EncodeForHTMLAttribute(startrow)#</CFOUTPUT>">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="<CFOUTPUT>#EncodeForHTMLAttribute(frompage)#</CFOUTPUT>">
<INPUT TYPE="Hidden" NAME="editcurrentweight" VALUE="0">
<INPUT TYPE="Hidden" NAME="SelectSingleSearchResultOnly" VALUE="<CFOUTPUT>#EncodeForHTMLAttribute(Form.SelectSingleSearchResultOnly)#</CFOUTPUT>">
<INPUT TYPE="Hidden" NAME="FlexAppName" VALUE="<cfoutput>#EncodeForHTMLAttribute(FORM.FlexAppName)#</cfoutput>">
<INPUT TYPE="Hidden" NAME="Type" VALUE="<cfoutput>#EncodeForHTMLAttribute(FORM.Type)#</cfoutput>">
<INPUT TYPE="Hidden" NAME="ShowBillToSearchFields" VALUE="<cfoutput>#EncodeForHTMLAttribute(FORM.ShowBillToSearchFields)#</cfoutput>">


</FORM>

	<cfif TheQuery.recordcount GT 0>
	<DIV ALIGN="center">
	&nbsp;&nbsp;&nbsp;
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" onClick="javascript: finishedSearching()"> import selected <cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput><CFIF FORM.AllowImportAll EQ 1>s</CFIF> </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<CFIF FORM.AllowImportAll EQ 1>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: hand;" onClick="importAllProducts(<CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT>)"> import all returned <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput> </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: hand;" onClick="removeAllProducts()"> remove all selected <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput> </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	</DIV>
	</CFIF>
	<BR>
	</cfif>

<cfinclude template="/Common_Files/jQuery.cfm">
<!--- D51575 :: 'Please Wait' Indicator    8.0 Release START --->
<cfinclude template="/Common_Files/noty.cfm">
<!--- D51575 :: 'Please Wait' Indicator    8.0 Release END --->
<SCRIPT>
	function reset_Form_Fields()
	{
		var search_form = $("form[name='MyForm']");
		$('select', search_form).each(function() {
				if ( $(this).attr('id') === 'sort_by' ) {}
				else {
					$(this).val( $('option:first', $(this)).val() )  // reset select dropdown with default 1st option
								 .trigger('change');                       // trigger onchange event
				}
		});
		// reset all text boxes to blank
		$('input[type="text"]', search_form).each(function() { $(this).val( '' ); });
	}

	function resetSelect(selName)
	{
		var sObj = document.getElementById(selName);
		if(sObj)
		{
			sObj.selectedIndex = 0;
			callfireEvent(document,sObj,'Change');
		}
	}

	<!--- Dont call finishedSearching() when coming from Settings/Payables/Auto Approve Settings --->
	<cfif TheQuery.recordcount EQ 1>
	<cfset ship_to_one_record = Val(TheQuery.Shr_Ship_To)>
	</cfif>

	<cfif TheQuery.recordcount EQ 1 and ParentFormname neq "autoApproveForm" and Trim(ship_to_one_record) EQ Form.Ship_To and FORM.Single_Result_AutoSelect EQ "1">
		document.MyForm.SelectedITEMS.checked = 1;
		finishedSearching();
	</cfif>

	<cfif TheQuery.recordcount GT 0>
		function importAllProducts(recordcount){
			processingPopUpDisplay('div.customContainer'); //D51575
			<!------//recordcount = <CFOUTPUT>#ListLen(whole_Product_List)#</CFOUTPUT>;----->
			if(parseInt(recordcount) == 1) pString = "Product";
			else pString = "Products";

			if(confirm("Do you want to import all " + recordcount + " records from your search?")){
				/* true or false based on browser - IE 10 and above or IE 9 and below.
				'1' as an argument below means "true". */
				document.all.allbox.checked = checkOrUncheckBeforeFireEvent(1);

				callfireEvent(document,document.all.allbox,'Click');

				document.MyForm.finishedselectingitems.value = 1;
				if(document.MyForm.FinalItemList.value.length > 0){
					document.MyForm.FinalItemList.value 	= document.MyForm.FinalItemList.value + "," + "<CFOUTPUT>#valuelist(TheQuery.BSA_Foodservice_Customers_ID)#</CFOUTPUT>";
					<!------//document.SearchForm.FinalUPCList.value 	= document.SearchForm.FinalUPCList.value + "," + "<CFOUTPUT>#whole_Product_List#</CFOUTPUT>";
					//document.SearchForm.FinalUPCList.value 	= "<CFOUTPUT>#whole_Product_List#</CFOUTPUT>";----->
				}
				else{
					document.MyForm.FinalItemList.value 	= "<CFOUTPUT>#valuelist(TheQuery.BSA_Foodservice_Customers_ID)#</CFOUTPUT>";
					<!------//document.SearchForm.FinalUPCList.value 	= "<CFOUTPUT>#whole_Product_List#</CFOUTPUT>";----->
				}

				document.MyForm.submit();
			}
			else
			{

			}
		}

		function removeAllProducts(){

			if(confirm("By pressing OK all selected records will be unselected")){
				/* true or false based on browser - IE 10 and above or IE 9 and below.
				'0' as an argument below means "false". */
				document.all.allbox.checked = checkOrUncheckBeforeFireEvent(0);

				callfireEvent(document,document.all.allbox,'Click');

				document.MyForm.finishedselectingitems.value = 0;
				document.MyForm.FinalItemList.value 	= "";
				document.MyForm.AlreadySelectedItems.value 	= "";
			}
			else
			{

			}
		}

		function finishedSearching() {
            // locate selected ship-to attribute
            let selected_ship_to = $("input[type=radio]:checked").attr("ship_to");
            // save selected ship-to value into a hidden input
            $("input[name=selected_ship_to]").val( selected_ship_to );
			processingPopUpDisplay('div.customContainer'); //D51575
			document.all.finishedselectingitems.value = 1
			document.all.MyForm.submit();
		}
	</cfif>

	//alert( $('#tb0103').width() + ' ' + $(window).height() );
	window.resizeTo( Math.max($(window).width(),910), Math.max($(window).height(),600) );
</SCRIPT>

<cfscript>
function isNextRow(maxCols, currCols)
{
	if(currCols LTE 1)
	{
		//WriteOutput(currCols & " " & maxCols & " " & "<br>");
		return 0;
	}
	else
	{
		//WriteOutput(currCols & " " & maxCols & " " & (not(currCols) mod maxCols) & "<br>");
		return (not(currCols) mod maxCols);
	}
}
</cfscript>

<cffunction name="InitHeader" output="false">
<cfset showHideColumnsSetting()>

	<CFSET HeaderNameList = "">
	<CFSET HeaderColumnList = "">

	<cfif ShowVendorAndBBClosingMethod eq 1>
		<CFSET HeaderNameList = ListAppend(HeaderNameList, "Name/#application.returned_customer_setting.shard_ship_to_label#")>
		<CFSET HeaderColumnList = ListAppend(HeaderColumnList, "Name")>

		<CFSET HeaderNameList = ListAppend(HeaderNameList, "Vendor ID")>
		<CFSET HeaderColumnList = ListAppend(HeaderColumnList, "Vendor ID")>

		<CFSET HeaderNameList = ListAppend(HeaderNameList, "Vendor Name")>
		<CFSET HeaderColumnList = ListAppend(HeaderColumnList, "Vendor Name")>

		<CFSET HeaderNameList = ListAppend(HeaderNameList, "BB Closing Method")>
		<CFSET HeaderColumnList = ListAppend(HeaderColumnList, "BB Closing Method")>
	<cfelse>
		<CFSET HeaderNameList = ListAppend(HeaderNameList, "Name/#application.returned_customer_setting.shard_ship_to_label#")>
		<CFSET HeaderColumnList = ListAppend(HeaderColumnList, "Name")>

		<CFIF DistResults_DisplayAddress eq 1>
			<CFSET HeaderNameList = ListAppend(HeaderNameList, "Address")>
			<CFSET HeaderColumnList = ListAppend(HeaderColumnList, "Address")>
		</CFIF>

		<cfif NOT appSettings.getDistributorMultiPosition() AND DistResults_DisplayBroker EQ 1>
			<CFSET HeaderNameList = ListAppend(HeaderNameList, "#application.returned_customer_setting.broker_label_singular#")>
			<CFSET HeaderColumnList = ListAppend(HeaderColumnList, "Broker")>
		</cfif>

		<cfif DistResults_DisplayFamily AND DistResults_DisplayBuyingGroup>
			<CFSET HeaderNameList = ListAppend(HeaderNameList, "#application.returned_customer_setting.family_name_label_singular# / <br /> #application.returned_customer_setting.buying_group_label_singular#")>
			<CFSET HeaderColumnList = ListAppend(HeaderColumnList, "Family")>
		<cfelseif DistResults_DisplayFamily>
			<CFSET HeaderNameList = ListAppend(HeaderNameList, "#application.returned_customer_setting.family_name_label_singular#")>
			<CFSET HeaderColumnList = ListAppend(HeaderColumnList, "Family")>
		<cfelseif DistResults_DisplayBuyingGroup>
			<CFSET HeaderNameList = ListAppend(HeaderNameList, "#application.returned_customer_setting.buying_group_label_singular#")>
			<CFSET HeaderColumnList = ListAppend(HeaderColumnList, "Buying Group")>
		</cfif>

		<cfif form.businessSegmentsOn AND DistResults_DisplayBusinessSegment>
		<CFSET HeaderNameList = ListAppend(HeaderNameList, "#appsettings.GETBUSINESS_SEGMENT_LABEL()#")>
		<CFSET HeaderColumnList = ListAppend(HeaderColumnList, "business_segments")>
		</cfif>
	</cfif>
</cffunction>

<!---
Determines search result column's visibility.
Go to "settings>application settings>Labels>Settings labels" to set visibility
--->
<cffunction name="showHideColumnsSetting" output="false">
	<!--- Address --->
	<cfset DistResults_DisplayAddress = 0>
	<cfloop query="DistSearchResultsColumnsDisplayAdditionalSettings">
		<cfif field_name eq "Address">
			<cfset DistResults_DisplayAddress = 1>
		</cfif>
	</cfloop>

	<cfset DistResults_DisplayBroker = 0>
	<cfset DistResults_DisplayFamily = 0>
	<cfset DistResults_DisplayBuyingGroup = 0>
	<cfset DistResults_DisplayBusinessSegment = 0>
	<cfloop query="DistSearchResultsColumnsDisplaySettings">
		<!--- Broker  --->
		<cfif Group_Level_Desc_Internal eq "Broker">
			<cfset DistResults_DisplayBroker = 1>
		</cfif>
		<!--- Family --->
		<cfif Group_Level_Desc_Internal eq "Family">
			<cfset DistResults_DisplayFamily = 1>
		</cfif>
		<!--- Buying Group --->
		<cfif Group_Level_Desc_Internal eq "Buying Group">
			<cfset DistResults_DisplayBuyingGroup = 1>
		</cfif>
		<!--- Business Segment --->
		<cfif Group_Level_Desc_Internal eq "Business Segment">
			<cfset DistResults_DisplayBusinessSegment = 1>
		</cfif>
	</cfloop>

</cffunction>
