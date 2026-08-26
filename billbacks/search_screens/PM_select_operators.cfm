
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<CFINCLUDE TEMPLATE="/Get_Access_Profile.cfm">
<!--- Dev Note: KAL; D????: Billback Workflow: Call from the Flex App --->
<cfparam name="FORM.FlexAppName" default="">
<cfif isDefined("URL.FlexAppName")>
	<cfset temp = structInsert(FORM,"FlexAppName",#URL.FlexAppName#,true) />
</cfif>
<cfparam name="FORM.ParentFormname" default="">
<cfparam name="FORM.flexModule" default="">

<cfparam name="searchoperator" default = "0">
<!--- 26298 ChrisN Feb 14 2001:
			"ShowVendorAndBBClosingMethod" controls the Default Vendor and Billback closing method dropdowns.
			Currently, it is being used only to set vendors for operators --->

<cfparam name="ShowVendorAndBBClosingMethod" default="0">
<cfparam name="Default_Vendor"               default="">
<cfparam name="Default_BB_Closing_Method"    default="">
<cfparam name="SelectSingleSearchResultOnly" default="1">    <!---26298--->
<!--- D38189::Alternate Payment Recipient --->
<cfparam name="url.alternate_payment_recipient" default="0">
<cfparam name="PageSource" default="">
<cfparam name="url.gpokey" default = "">
<cfparam name="url.zip" default = "">

<cfif url.alternate_payment_recipient>
	<cfset FORM.ParentFormname = "MyForm">
</cfif>
	<!--- D38189::Alternate Payment Recipient --->
<cfset maxColsPerRow = 4 />
<cfset currentColCount = 0/>

<cfif isdefined("url.searchoperator")>
<cfset searchoperator = url.searchoperator>
<cfelseif isdefined("form.searchoperator")>
<cfset searchoperator = form.searchoperator>
</cfif>

<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset businessSegEnabledForOperator =  businessSegManager.isEnabledForOperator()>		
	
<cfset GPO_One_Page_Program_Creation = appSettings.get_Setting('GPO_One_Page_Program_Creation') >
<cfif GPO_One_Page_Program_Creation AND PageSource EQ "AliasOperatorSearch">
	<cfset GPO_Alias_Search = 1>
<cfelse>
	<cfset GPO_Alias_Search = 0>
</cfif>

<CFIF isdefined("URL.FormName")>
	<FORM ACTION="pm_select_operators.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
		<INPUT NAME="ParentFormname" TYPE="Hidden" VALUE="<CFOUTPUT>#EncodeForHTMLAttribute(URL.FormName)#</CFOUTPUT>">
		<INPUT NAME="FinalItemList" TYPE="HIDDEN" VALUE="">
		<INPUT NAME="SelectSingleSearchResultOnly" TYPE="Hidden" VALUE="<cfoutput>#EncodeForHTMLAttribute(SelectSingleSearchResultOnly)#</cfoutput>">   <!---26298--->
		<input name="ShowVendorAndBBClosingMethod" type="hidden" value="<cfoutput>#EncodeForHTMLAttribute(ShowVendorAndBBClosingMethod)#</cfoutput>">   <!---26298--->
		<INPUT NAME="FlexAppName" TYPE="Hidden" VALUE="<cfoutput>#EncodeForHTMLAttribute(FORM.FlexAppName)#</cfoutput>">
		<cfif GPO_Alias_Search eq 1>
			<cfoutput>
				<INPUT NAME="Operator_Zip" VALUE="#left(url.zip,5)#" TYPE="Hidden">
				<INPUT NAME="GPO_Key" 		VALUE="#EncodeForHTMLAttribute(url.gpokey)#" TYPE="Hidden">
			</cfoutput>
		</cfif>
		<cfif isDefined("URL.flexModule")>
			<input name="flexModule" type="hidden" value="<cfoutput>#EncodeForHTMLAttribute(URL.flexModule)#</cfoutput>">
		</cfif>
		<INPUT NAME="PageSource" TYPE="hidden" VALUE="<cfoutput>#EncodeForHTMLAttribute(PageSource)#</cfoutput>">
	</FORM>

	<CFOUTPUT>
		<cfif URL.FormName EQ 'flex' OR PageSource eq "AliasOperatorSearch">
			<script>
				document.all.MyForm.submit();
			</script>
		<cfelse>
			<script>
				var parentForm = window.opener.document.all.#URL.FormName#;
				if(parentForm != null)
				{
					this.document.all.FinalItemList.value = parentForm.Operator_List.value;
					if(parentForm.SelectSingleSearchResultOnly)
					{
						this.document.all.SelectSingleSearchResultOnly.value = parentForm.SelectSingleSearchResultOnly.value;
					}
					document.all.MyForm.submit()
				}
				else
				{
					alert("The Data Needed From The Parent Form Isnt Available.This Window Will Close!")
					window.close();
				}
			</script>
		</cfif>
	</CFOUTPUT>
	<cfabort>
</CFIF>


<!------ Set Defaults ----->
<CFPARAM NAME="URL.CID" DEFAULT="">
<cfparam name="FORM.Market_ID" 	default="">
<cfparam name="FORM.Position_ID" 	default="">

<CFIF len(trim(URL.CID)) GT 0>

	<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
	<cfquery name="GetContractInfo" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Main
		WHERE Contract_Main_ID = '#cryp.value#'
	</cfquery>

	<!--- Do not show the tabs if the contract is approved --->
	<CFIF GetContractInfo.Contract_Status_Type_IDX GT 2>
		<script>
			history.back();
		</script>

		<CFABORT>
	</CFIF>
</CFIF>


<CFSET PAGE_TITLE="Select Program #application.returned_customer_setting.operator_label_plural#">
<CFSET GROUP="Contracts">




<CFPARAM name="FORM.button_caption"					default="continue">
<CFPARAM NAME="FORM.searchstring" DEFAULT="">
<CFPARAM NAME="FORM.SelectedITEMS" DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingitems" DEFAULT="0">
<CFPARAM NAME="FORM.LoadSavedOperators"	Default="1">
<CFPARAM NAME="FORM.SelectSingleSearchResultOnly"	Default="1">
<CFPARAM NAME="FORM.AllowImportAll"	Default="#NOT FORM.SelectSingleSearchResultOnly#">
<CFPARAM NAME="FORM.OPERATOR_NAME" DEFAULT="">
<CFPARAM NAME="FORM.OPERATOR_DBA" DEFAULT="">
<CFPARAM NAME="FORM.OPERATOR_CITY" DEFAULT="">
<CFPARAM NAME="FORM.Operator_Type" DEFAULT="">
<CFPARAM NAME="FORM.Operator_Location_Type" DEFAULT="">
<CFPARAM NAME="FORM.Operator_State" DEFAULT="">
<CFPARAM NAME="FORM.Operator_Zip" DEFAULT="">
<CFPARAM NAME="FORM.GPO_Key" DEFAULT="">
<CFPARAM NAME="FORM.Operator_Country_Code" DEFAULT="0">
<cfparam name="FORM.Operator_Number_Of_Locations" 	default="">
<cfparam name="FORM.Number_Locations_Operation" 	default="">
<cfparam name="FORM.Operator_Category" 	default="">
<cfparam name="FORM.Operator_Priority" 	default="">
<cfparam name="Form.legacy_id" 			default="">
<cfparam name="Form.BSA_Operator_ID" 	default="">
<cfparam name="form.Active_Status" default="">

<CFPARAM NAME="StartRow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">

<cf_Number_of_Rows maxrows=200>

<CFSET LegacyIdOn = application.returned_customer_setting.operator_legacy_id_on>
<!--- <cfoutput>#application.returned_customer_setting.operator_legacy_id_on#</cfoutput> --->
<CFSET FORM.LoadSavedOperators=0>

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

<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
	<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
		<CFIF listfind(FORM.FinalItemList,ListItem, ",") GT 0>
			<CFSET Form.FinalItemList = listdeleteat(FORM.FinalItemList, listfind(FORM.FinalItemList,ListItem, ","), ",")>
		</CFIF>
	</CFLOOP>
<CFELSE>
	<cfif len(trim(FORM.SelectedITEMS)) GT 0>
		<CFSET Form.FinalItemList = FORM.SelectedITEMS>
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
				function saveOperator()
				{
					getFlexApp('#FORM.FlexAppName#').saveOperator('#Form.FinalItemList#');
				}
				saveOperator();
				<cfif GPO_Alias_Search eq 0>
					window.close();
				</cfif>
			</script>
		<cfelse>
		<cfif PageSource IS "AliasOperatorSearch">
		<script>
			window.opener.getOperatorInfo('#Form.FinalItemList#',0,1);
			<cfif GPO_Alias_Search eq 0>
					window.close();
			</cfif>
		</script>
		<cfelse>
			<script>
				opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.Operator_List.value = '<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>'
				opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.submit();
				window.close()
			</script>
		</cfif>
		</cfif>
	</cfoutput>
	<cfif GPO_Alias_Search eq 0>
		<CFABORT> 
	</cfif>
</CFIF>
<cfset OprSearchSettingsManager 	= CreateObject("component", "components.settings.Labels.Labels") />
<cfset OprSearchSettings	= OprSearchSettingsManager.getOperatorsStaticSearchFieldsActive() />
<cfset OprSearchResultsColumnsDisplayAdditionalSettings = OprSearchSettingsManager.getOperatorStaticSearchFieldsDisplayStatus() />

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

	<!--- Dev Note: Drachala; D27266: Operator variable labeling START--->
	<cfset LabelComp 			    = Createobject("component", "components.settings.labels.labels").init() />
	<cfset qGetOperatorTypeLabel 	  = LabelComp.getGeneralLabels('Operator Type') />
	<cfset qGetLocationTypeLabel 	= LabelComp.getGeneralLabels('Location Type') />
	<cfset qGetOperatorCategoryLabel 	= LabelComp.getGeneralLabels('Operator Category') />
	<cfset qGetOperatorPriorityLabel 	= LabelComp.getGeneralLabels('Operator Priority') />
	<!--- Dev Note: Drachala; D27266: Operator variable labeling END--->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js"></script>   <!--26460-->
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="20" TOPMARGIN="0" onLoad="document.all.Operator_Name.focus();">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/string_functions.js, /Script/javascript/dhtml.js">
<style>
TABLE.Maintable TD
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header
{
	font-size: 12px;
}
</style>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is help file that goes with this content													 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SCRIPT language="JavaScript">
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
		// reset all non-hidden (visible) input to blank
		//$('input:visible', search_form).val( '' );
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
</SCRIPT>
	<CFOUTPUT>
<!--- D38189::Alternate Payment Recipient	 /ADDED URLVARIABLE TO FORM ACTION--->
	<FORM ACTION="PM_select_operators.cfm?CID=#URL.CID#&alternate_payment_recipient=#url.alternate_payment_recipient#" METHOD="post" NAME="MyForm" ID="MyForm">
	</CFOUTPUT>
				<input type="hidden" name="ShowVendorAndBBClosingMethod" value="<cfoutput>#ShowVendorAndBBClosingMethod#</cfoutput>">   <!---26298--->
<BR><CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

	<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
			<LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfoutput>#application.returned_customer_setting.operator_label_singular# </cfoutput>search</LEGEND>




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the list of Operator_Location_Type														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Operator_Location_Type" datasource="#application.datasource#">
Select	distinct Operator_Location_Type
From	awayX_Operator_Location_Type
--Where	deleted = 0
</CFQUERY>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the list of Operator_Type																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	 <!----------------------------------------------------------------------------
		Dev Notes: D19761 -Anand Rao 07/28/09
		Changed to query to have a where clause to look for active = 1 and
		Deleted = 0 and pick the records from awayx_Operator_type table
 ------------------------------------------------------------------------------>
<CFQUERY NAME="Get_Operator_Type" datasource="#application.datasource#">
	SELECT	Distinct Operator_Type
	FROM awayX_Operator_Type
	WHERE Active = 1 AND Deleted = 0
</CFQUERY>
<cfif application.operatorVariableAvailable>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the list of Operator_Category																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Operator_Category" datasource="#application.datasource#">
Select	Operator_Category_ID, Category_Label
From	Operator_Category
Where	deleted = 0
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the list of Operator_Category																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Operator_Priority" datasource="#application.datasource#">
Select	Operator_Priority_ID, Priority_Label
From	Operator_Priority
Where	deleted = 0
</CFQUERY>
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the states																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFQUERY NAME="Get_States" datasource="#application.datasource#">
	Select s.*, c.Country_Sort_Order
	from _states s
	join _country c on s.Country_ID = c.Country_ID
	ORDER BY  isnull(c.Country_Sort_Order, c.country_id) ASC
</CFQUERY> --->

<cfquery name="Get_States" datasource="#application.datasource#">
	SELECT DISTINCT Operator_State as State_Code, State_Name, Country_Sort_Order
	FROM BSA_Operator o
	join _States s on s.State_Code = o.Operator_State
	join _Country c on s.Country_ID = c.Country_ID
	WHERE	LEN(State_Code) > 0
	ORDER BY Country_Sort_Order, State_Name
</cfquery>



<STYLE>
	.LONGINPUT
	{
		width: 175px;
	}
	SELECT
	{
		width: 175px;
	}
</STYLE>

<!---29684 - store all selected filters in this filters structure--->
<cfscript>
	filters         = StructNew();
	filters.count   = 0;
	filters.options = ArrayNew(1);
</cfscript>

<!---------------------------------------------------------------------------------------------------------------------------->

<cffunction name="DisplaySetFilter" output="true" hint="Save & display filter option">
	<cfargument name="filterLabel" required="true">
	<cfargument name="br" required="false" default="true">
	<cfscript>
		filters.count = filters.count + 1;
		filters.options[ filters.count ] = arguments.filterLabel;
	</cfscript>
	<b><cfoutput>#filters.options[ filters.count ]#:</cfoutput></b>
	<cfif arguments.br></br></cfif>
</cffunction>

<!---------------------------------------------------------------------------------------------------------------------------->

<TABLE border="0" cellpadding="4" align="center">
<TR>

<cfloop query="OprSearchSettings">
	<cfswitch expression = "#OprSearchSettings.Field_Name#">
		<cfcase value = "Operator Name">
			<TD>
				<cfset DisplaySetFilter( application.returned_customer_setting.operator_label_singular & " Name" )>
				<INPUT CLASS="LONGINPUT" TYPE="text" NAME="Operator_Name" STYLE="font-size: 10px;" VALUE="<CFOUTPUT>#EncodeForHTMLAttribute(FORM.Operator_Name)#</CFOUTPUT>"  onkeydown="if (event.keyCode == 13) doSearch();">
			</TD>
			<cfinclude template="_incTrSeparator.cfm" />
		</cfcase>
		<cfcase value = "Doing Business As">
			<TD width="190">
				<cfset DisplaySetFilter( "Doing business as" )>
				<INPUT CLASS="LONGINPUT" TYPE="Text" NAME="Operator_DBA" MAXLENGTH="510" STYLE="font-size: 10px;" VALUE="<CFOUTPUT>#EncodeForHTMLAttribute(FORM.Operator_DBA)#</CFOUTPUT>"  onkeydown="if (event.keyCode == 13) doSearch();">
			</TD>
			<cfinclude template="_incTrSeparator.cfm" />
		</cfcase>
		<cfcase value = "City">
			<TD width="190">
				<cfset DisplaySetFilter( "City" )>
				<INPUT CLASS="LONGINPUT" TYPE="Text" NAME="Operator_City" MAXLENGTH="510" STYLE="font-size: 10px;" VALUE="<CFOUTPUT>#EncodeForHTMLAttribute(FORM.Operator_City)#</CFOUTPUT>"  onkeydown="if (event.keyCode == 13) doSearch();">
			</TD>
			<cfinclude template="_incTrSeparator.cfm" />
		</cfcase>
		<cfcase value = "State">
			<TD width="190">
				<cfset DisplaySetFilter( "State" )>
				<SELECT NAME="Operator_State" STYLE="font-size: 10px;"  onkeydown="if (event.keyCode == 13) doSearch();">
				<OPTION VALUE="" SELECTED>Select State</OPTION>
				<OPTION VALUE="All">Any State</OPTION>
				<CFOUTPUT QUERY="Get_States"><OPTION VALUE="#State_Code#" <CFIF FORM.Operator_State EQ Get_States.State_Code>selected</CFIF>>#State_Name#</OPTION></CFOUTPUT>
				</SELECT>
			</TD>
			<cfinclude template="_incTrSeparator.cfm" />
		</cfcase>
		<cfcase value="Location Type">
			<TD>
				<cfset DisplaySetFilter( qGetLocationTypeLabel.GENERAL_LABELS_LABEL )>
				<SELECT NAME="Operator_Location_Type" STYLE="font-size: 10px;"  onkeydown="if (event.keyCode == 13) doSearch();">
				<OPTION VALUE="" SELECTED>Select <cfoutput>#qGetLocationTypeLabel.GENERAL_LABELS_LABEL#</cfoutput></OPTION>
				<OPTION VALUE="All">All <cfoutput>#qGetLocationTypeLabel.GENERAL_LABELS_LABEL#</cfoutput></OPTION>
				<CFOUTPUT QUERY="Get_Operator_Location_Type"><OPTION VALUE="#Operator_Location_Type#" <CFIF FORM.Operator_Location_Type EQ Get_Operator_Location_Type.Operator_Location_Type>selected</CFIF>>#Operator_Location_Type#</OPTION></CFOUTPUT>
				</SELECT>
			</TD>
			<cfinclude template="_incTrSeparator.cfm" />
		</cfcase>
		<cfcase value="Type of Operator">
			<TD>
				<cfset DisplaySetFilter( qGetOperatorTypeLabel.GENERAL_LABELS_LABEL )>
				<SELECT NAME="Operator_Type" STYLE="font-size: 10px;"  onkeydown="if (event.keyCode == 13) doSearch();">
				<OPTION VALUE="" SELECTED>Select <CFOUTPUT>#qGetOperatorTypeLabel.GENERAL_LABELS_LABEL#</CFOUTPUT></OPTION>
				<OPTION VALUE="All">All <CFOUTPUT>#qGetOperatorTypeLabel.GENERAL_LABELS_LABEL#</CFOUTPUT></OPTION>
				<CFOUTPUT QUERY="Get_Operator_Type"><OPTION VALUE="#Operator_Type#" <CFIF FORM.Operator_Type EQ Get_Operator_Type.Operator_Type>selected</CFIF>>#Operator_Type#</OPTION></CFOUTPUT>
				</SELECT>
			</TD>
			<cfinclude template="_incTrSeparator.cfm" />
		</cfcase>
		<cfcase value="Operator Category">
			<cfif application.operatorVariableAvailable>
			<TD>
				<cfset DisplaySetFilter( qGetOperatorCategoryLabel.GENERAL_LABELS_LABEL )>
				<SELECT NAME="Operator_Category" STYLE="font-size: 10px;"  onkeydown="if (event.keyCode == 13) doSearch();">
				<OPTION VALUE="" SELECTED>Select <cfoutput>#qGetOperatorCategoryLabel.GENERAL_LABELS_LABEL#</cfoutput></OPTION>
				<OPTION VALUE="All">All <cfoutput>#qGetOperatorCategoryLabel.GENERAL_LABELS_LABEL#</cfoutput></OPTION>
				<CFOUTPUT QUERY="Get_Operator_Category"><OPTION VALUE="#Operator_Category_ID#" <CFIF FORM.Operator_Category EQ Operator_Category_ID>selected</CFIF>>#Category_Label#</OPTION></CFOUTPUT>
				</SELECT>
			</TD>
			<cfinclude template="_incTrSeparator.cfm" />
			</cfif>
		</cfcase>
		<cfcase value="Operator Priority">
			<cfif application.operatorVariableAvailable>
				<TD>
					<cfset DisplaySetFilter( qGetOperatorPriorityLabel.GENERAL_LABELS_LABEL )>
					<SELECT NAME="Operator_Priority" STYLE="font-size: 10px;"  onkeydown="if (event.keyCode == 13) doSearch();">
					<OPTION VALUE="" SELECTED>Select <cfoutput>#qGetOperatorPriorityLabel.GENERAL_LABELS_LABEL#</cfoutput>:</OPTION>
					<OPTION VALUE="All">All <cfoutput>#qGetOperatorPriorityLabel.GENERAL_LABELS_LABEL#</cfoutput>:</OPTION>
					<CFOUTPUT QUERY="Get_Operator_Priority"><OPTION VALUE="#Operator_Priority_ID#" <CFIF FORM.Operator_Priority EQ Operator_Priority_ID>selected</CFIF>>#Priority_Label#</OPTION></CFOUTPUT>
					</SELECT>
				</TD>
				<cfinclude template="_incTrSeparator.cfm" />
			</cfif>
		</cfcase>
		<cfcase value="## of Locations">
			<TD>
				<cfset DisplaySetFilter( "## Locations" )>
				<CFSET OperationList = " ,>=,<=,=">
				<SELECT NAME="Number_Locations_Operation" STYLE="width:40px;font-size: 10px;"  onkeydown="if (event.keyCode == 13) doSearch();">
				<CFOUTPUT>
				<CFLOOP list="#OperationList#" delimiters="," index="ThisItem">
					<cfset ThisItem = Trim(ThisItem)>
					<OPTION VALUE="#ThisItem#"<CFIF FORM.Number_Locations_Operation EQ ThisItem> SELECTED</CFIF>>#ThisItem#</OPTION>
				</CFLOOP>
				</CFOUTPUT>
				</SELECT>
				<INPUT onKeyUp="clenseText(this, '0123456789');" TYPE="Text" NAME="Operator_Number_Of_Locations" MAXLENGTH="8" STYLE="width:80px;font-size: 10px;" VALUE="<CFOUTPUT>#Replace(FORM.Operator_Number_Of_Locations,'-','','ALL')#</CFOUTPUT>"  onkeydown="if (event.keyCode == 13) doSearch();">
	</TD>
<cfinclude template="_incTrSeparator.cfm" />
		</cfcase>
		<cfcase value="Market">
			<cfif application.operatorVariableAvailable>
				<TD NOWRAP ALIGN="left">
					<cfset DisplaySetFilter( application.returned_customer_setting.market_label_singular )>
					<CFQUERY NAME="GetMarkets" datasource="#application.datasource#">
					SELECT Market_Name, Service_Market_ID
					FROM Service_Markets
					WHERE len(Market_Name) > 0 AND Deleted = 0
					ORDER BY Market_Name
					</CFQUERY>
					<SELECT NAME="Market_ID"  onkeydown="if (event.keyCode == 13) doSearch();">
						<OPTION VALUE="">**ALL** <CFOUTPUT>#application.returned_customer_setting.market_label_plural#</CFOUTPUT></OPTION>
						<CFOUTPUT QUERY="GetMarkets"><OPTION VALUE="#trim(Service_Market_ID)#"#IIF(trim(FORM.Market_ID) EQ Service_Market_ID, DE(" SELECTED"), DE(""))#>#trim(Market_Name)#</OPTION></CFOUTPUT>
					</SELECT>
				</TD>
				<cfinclude template="_incTrSeparator.cfm" />
			</cfif>
		</cfcase>
		<cfcase value="Position">
			<cfif application.operatorVariableAvailable>
				<TD NOWRAP ALIGN="left">
					<cfset DisplaySetFilter( "Position" )>
					<CFQUERY NAME="GetPositions" datasource="#application.datasource#">
					SELECT User_positions_ID, Position_Label
					FROM User_positions
					WHERE len(Position_Label) > 0 AND Deleted = 0
					ORDER BY Position_Label
					</CFQUERY>
					<SELECT NAME="Position_ID"  onkeydown="if (event.keyCode == 13) doSearch();">
						<OPTION VALUE="">**ALL** <CFOUTPUT>Positions</CFOUTPUT></OPTION>
						<CFOUTPUT QUERY="GetPositions"><OPTION VALUE="#trim(User_positions_ID)#"#IIF(trim(FORM.Position_ID) EQ User_positions_ID, DE(" SELECTED"), DE(""))#>#trim(Position_Label)#</OPTION></CFOUTPUT>
					</SELECT>
				</TD>
				<cfinclude template="_incTrSeparator.cfm" />
			</cfif>
		</cfcase>
		<cfcase value="Country">
			<TD NOWRAP ALIGN="left">
				<CFPARAM NAME="Form.Operator_Country_Code" DEFAULT="0">
						<!--- Country code --->
				<CFQUERY NAME="getCountry" datasource="#application.datasource#">
							SELECT distinct c.country_code, country_name, Country_id
							FROM BSA_Operator o
							Join  _Country c on o.operator_country_code = c.country_code
							where active = 1
							and deleted = 0
							ORDER BY Country_id ASC
						</CFQUERY>
						<cfset DisplaySetFilter( "Country" )>
						<CFOUTPUT>
								<SELECT NAME="Operator_Country_Code" STYLE="WIDTH:175px"  onkeydown="if (event.keyCode == 13) doSearch();">
									<OPTION SELECTED value="0">**ALL** Countries</OPTION>
										<CFLOOP QUERY="getCountry">
										<OPTION VALUE="#getCountry.Country_Code#" #IIF(trim(FORM.Operator_Country_Code) EQ trim(GetCountry.country_code), DE(" SELECTED"), DE(""))#>#getCountry.Country_Name#</OPTION>
									</CFLOOP>
									 </SELECT>
							</CFOUTPUT>

				</TD>
			<cfinclude template="_incTrSeparator.cfm" />
		</cfcase>
		<cfcase value="Operator ID">
			<cfif LegacyIdOn>
					<TD>
					<cfset DisplaySetFilter( application.returned_customer_setting.Operator_Legacy_Id_label, false )><cfset DisplayCreateList("Operator_Legacy_Id")><br/><input type="Text" name="legacy_id" maxlength="510" style="width:80px;font-size: 10px;" value="<CFOUTPUT>#FORM.legacy_id#</CFOUTPUT>"  onkeydown="if (event.keyCode == 13) doSearch();">
					</TD>
				<cfinclude template="_incTrSeparator.cfm" />
			</cfif>
		</cfcase>
		<cfcase value="BSA Operator ID">
			<TD valign="top">
					<cfset DisplaySetFilter( "BSA ID", false )><cfset DisplayCreateList("BSA_Operator_Id")>
					<input type="Text" name="BSA_Operator_id" maxlength="50" style="width:80px;font-size: 10px;" value="<CFOUTPUT>#EncodeForHTMLAttribute(FORM.BSA_Operator_id)#</CFOUTPUT>"  onkeydown="if (event.keyCode == 13) doSearch();">

			</TD>
			<cfinclude template="_incTrSeparator.cfm" />
		</cfcase>
		<cfcase value="Operator Status">
			<TD valign="top">
				<b><cfoutput>#application.returned_customer_setting.operator_label_singular# Status:</cfoutput></b></br>
				<select name="Active_Status"  onkeydown="if (event.keyCode == 13) doSearch();">
					<option value="1" <cfif form.Active_Status IS 1>selected</cfif>>Active</option>
					<option value="0" <cfif form.Active_Status IS 0>selected</cfif>>Inactive</option>
					<option value="2" <cfif form.Active_Status IS 2>selected</cfif>>Valid</option>
					<option value="3" <cfif form.Active_Status IS 3>selected</cfif>>Invalid</option>
				</select>
			</TD>
			<cfinclude template="_incTrSeparator.cfm" />
		</cfcase>
		<cfcase value = "Zip Code">
			<TD>
				<cfset DisplaySetFilter( "Zip Code" )>
				<INPUT TYPE="Text" NAME="Operator_Zip" MAXLENGTH="11" STYLE="font-size: 10px;" VALUE="<CFOUTPUT>#EncodeForHTMLAttribute(FORM.Operator_Zip)#</CFOUTPUT>"  onkeydown="if (event.keyCode == 13) doSearch();">
			</TD>
			<cfinclude template="_incTrSeparator.cfm" />
		</cfcase>	
		<cfcase value = "GPO Key">
			<cfif GPO_Alias_Search eq 1>
				<TD>
					<cfset DisplaySetFilter( "GPO Key" )>
					<INPUT TYPE="Text" NAME="GPO_Key" MAXLENGTH="25" STYLE="font-size: 10px;" VALUE="<CFOUTPUT>#EncodeForHTMLAttribute(FORM.GPO_Key)#</CFOUTPUT>"  onkeydown="if (event.keyCode == 13) doSearch();">
				</TD>
				<cfinclude template="_incTrSeparator.cfm" />
			</cfif>
		</cfcase>	
	</cfswitch>
</cfloop>
		<!--- 26298 2/15/2011 ChrisN - Added default vendor, default bill back closing method --->
		<cfif ShowVendorAndBBClosingMethod EQ 1>
			<cfinvoke component="components.billback.BillbackManager"
								method="getBillbackClosingMethods"
								returnvariable="qBillbackClosingMethods">
			</cfinvoke>

			<td><strong>Default Vendor:</strong><br />
				<select name="Default_Vendor" style="width:105px"  onkeydown="if (event.keyCode == 13) doSearch();">
					<option selected value="">**ALL** Vendors</option>
					<option VALUE="1" <cfif Default_Vendor eq 1>selected</cfif>>Yes</option>
					<option VALUE="2" <cfif Default_Vendor eq 2>selected</cfif>>No</option>
				</select>
			</td>

			<td colspan="2"><strong>Default BB Closing Method:<cfoutput>#qBillbackClosingMethods.iBillback_Closing_Method_ID#</cfoutput></strong><br />
				<select name="Default_BB_Closing_Method" style="width:160px"  onkeydown="if (event.keyCode == 13) doSearch();">
					<option selected value="">**ALL** BB Closing Methods</option>
					<cfoutput query="qBillbackClosingMethods">
						<cfif qBillbackClosingMethods.iBillback_Closing_Method_ID eq 1 OR qBillbackClosingMethods.iBillback_Closing_Method_ID eq 2>
							<option value="#qBillbackClosingMethods.iBillback_Closing_Method_ID#"
								<cfif Default_BB_Closing_Method eq qBillbackClosingMethods.iBillback_Closing_Method_ID>selected</cfif>>#qBillbackClosingMethods.vchBillback_Closing_Method_DESC#
							</option>
						</cfif>
					</cfoutput>
		<!--- Dev Note: Drachala; D27577 : Payable Settings, Default BB Closing Method add option called 'Both'  START--->
		<cfif qBillbackClosingMethods.iBillback_Closing_Method_ID eq 1 OR qBillbackClosingMethods.iBillback_Closing_Method_ID eq 2>
		<option value="both" <cfif Default_BB_Closing_Method EQ "both">SELECTED</cfif>>Both</option>
		</cfif>
		<!--- Dev Note: Drachala; D27577 : Payable Settings, Default BB Closing Method add option called 'Both'  END--->
				</select>
			</td>
		</cfif>

	<cfinclude template="_incTrSeparator.cfm" />

<!--- D25657: Planning Group Module start--->
<cfif (appSettings.getPlanningGroups()) AND isDefined("GetContractInfo") AND GetContractInfo.RecordCount GTE 1>

		<cfquery name="GetTemplateInfo" datasource="#application.datasource#">
		SELECT First_parent_ID
			FROM Program_Control_Panel_Options
			WHERE ProgramControl_Panel_Options_ID =  #GetContractInfo.ProgramType_ID#
		</cfquery>

		<cfquery name="qGetTemplateAllowProductGroupLevel" datasource="#application.datasource#">
			SELECT *
			FROM Group_Template
					WHERE Template_ID = #GetTemplateInfo.First_parent_ID#
			AND Deleted = 0
			AND Active = 1
			AND (Allow_In_Group_Search = 1
			OR Allow_In_Search = 1)
		</cfquery>

</cfif>
<!--- D25657: Planning Group Module End--->
<tr>
	<TD align="center" NOWRAP colspan="100%"><br>
		<!---<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10">--->
		<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript:doSearch();"> search <cfoutput>#application.returned_customer_setting.operator_label_plural# </cfoutput></a><FONT COLOR="#FF0000">]</FONT></B>
		<B style="margin-left:20px;"><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript: reset_Form_Fields();"> reset </a><FONT COLOR="#FF0000">]</FONT></B>
	</TD>
</tr>

</TABLE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ---><!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		
		<CFPARAM NAME="FORM.sort_Order" DEFAULT="ASC">
		<cfif GPO_Alias_Search eq 1> <!--- custom gpo --->
			<CFPARAM NAME="FORM.sort_by" DEFAULT="operator_address">
		<cfelse> <!--- default --->
			<CFPARAM NAME="FORM.sort_by" DEFAULT="Operator_Name">
		</cfif>
		
		<INPUT type="Hidden" value="<cfoutput>#FORM.sort_by#</cfoutput>" NAME="sort_by">
	<INPUT type="Hidden" value="<cfoutput>#FORM.sort_Order#</cfoutput>" NAME="sort_Order">
		<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">

	</FIELDSET>

<BR>
<cfif searchoperator EQ 0>
	<CFQUERY NAME="GetOperatorInfo" datasource="#application.datasource#">
		SELECT *
		FROM BSA_Operator
		WHERE
			<CFIF len(FORM.FinalItemList) EQ 0>
			1=2
			<CFELSE>
			BSA_Operator_ID IN(#FORM.FinalItemList#)
			</CFIF>
	</CFQUERY>
	<CFSCRIPT>
		Border="Yes";
		BorderSize=1;
		BorderColor="Blue";
		Image="/images/plus3.gif";
		ImageOpen="/images/minus3.gif";
		TitleColor="Navy";
		TitleFont="Arial";
		TitleSize=10;
		IsClosed="Yes";
		WIDTH="100%";
	</CFSCRIPT>
	<CF_openLayer
		Border="#Border#"
		BorderSize="#BorderSize#"
		BorderColor="#BorderColor#"
		Image="#Image#"
		ImageOpen="#ImageOpen#"
		Title="currently selected #application.returned_customer_setting.operator_label_plural#"
		TitleClosed="currently selected #application.returned_customer_setting.operator_label_plural#"
		TitleTooltip="Click here to toggle the view"
		TitleColor="#TitleColor#"
		TitleFont="#TitleFont#"
		TitleSize="#TitleSize#"
		IsClosed="#IsClosed#"
		Width="#width#">
			<CFIF GetOperatorInfo.recordcount GT 0>
				<TABLE border="0" cellspacing="3" cellpadding="3" align="left" WIDTH="700" BGCOLOR="white">
					<TR><CFOUTPUT QUERY="GetOperatorInfo">
						<TD NOWRAP BGCOLOR="eeeeee">#GetOperatorInfo.operator_name#<BR>#Operator_City# - #Operator_State#</TD>
						<CFIF GetOperatorInfo.currentrow mod 4><CFELSE></TR><TR></CFIF>
					</CFOUTPUT>
				</TABLE>
			<CFELSE>
				<CFIF FORM.FinalItemList EQ "ALL"><B>ALL #application.returned_customer_setting.operator_label_plural#</B><CFELSE><B>NONE</B></CFIF>
			</CFIF>
			<BR>
	</CF_openLayer>
</cfif>

<CFIF isdefined("FORM.DOSEARCH")>
	<CFSET form.searchstring = trim(form.searchstring)>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ---><!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->


<cfif len(Form.sort_by)>
	<CFSET sql_Sort_By="#Form.sort_by#">
<cfelse>
	<CFSET sql_Sort_By="Operator_Name">	
</cfif>

<CFSWITCH expression="#Form.sort_by#">
	<CFCASE value="Operator Name">
		<CFSET sql_Sort_By="Operator_Name">
	</CFCASE>
	<CFCASE value="Location Type">
		<CFSET sql_Sort_By="Operator_Location_Type">
	</CFCASE>
	<CFCASE value="City">
		<CFSET sql_Sort_By="Operator_City">
	</CFCASE>
	<CFCASE value="State">
		<CFSET sql_Sort_By="Operator_State">
	</CFCASE>
	<CFCASE value="Country Code">
		<CFSET sql_Sort_By="Operator_Country_Code">
	</CFCASE>
	<!---<CFCASE value="Number of Locations">
		<CFSET sql_Sort_By="CAST(Replace(Operator_Number_Of_Locations,'-','') AS BIGINT)">
	</CFCASE>
	<CFCASE value="Doing Business As">
		<CFSET sql_Sort_By="Operator_DBA">
	</CFCASE>--->
	<CFCASE value="Legacy Id">
		<CFSET sql_Sort_By="legacy_id">
	</CFCASE>
	<CFCASE value="Legacy Id Combo">
		<CFSET sql_Sort_By="CASE WHEN Len(BSA_Operator.legacy_id) > 0 THEN BSA_Operator.legacy_id ELSE cast(BSA_Operator.BSA_Operator_ID as varchar(100)) END">
	</CFCASE>
	<CFCASE value="Operator ID">
		<CFSET sql_Sort_By="BSA_Operator_ID">
	</CFCASE>
	<CFCASE value="Vendor ID">
		<CFSET sql_Sort_By="Default_Vendor_ID">
	</CFCASE>
	<CFCASE value="Vendor Name">
		<CFSET sql_Sort_By="Vendor_Name">
	</CFCASE>
	<CFCASE value="BB Closing Method">
		<CFSET sql_Sort_By="vchBillback_Closing_Method_Desc">
	</CFCASE>
		
</CFSWITCH>

<CFSET sql_Sort_By_Order=" ASC">
<CFIF Form.sort_Order EQ "DESC">
	<CFSET sql_Sort_By_Order=" DESC">
</CFIF>

<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve operators																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfset OFFSETStartRow = #StartRow#-1 >

<CFQUERY NAME="TheQuery" datasource="#application.datasource#">

Select	Rows_Cnt = COUNT(1) OVER(),

BSA_Operator.*

			<!---26298 Feb 16, 2011 added vendor name, bb closing method description when it is applicable --->
			<cfif ShowVendorAndBBClosingMethod EQ 1>
					,Vendor_Master.Vendor_Name, Billback_Closing_Methods.vchBillback_Closing_Method_Desc
			</cfif>
			<cfif businessSegEnabledForOperator>
				,Bus_Seg.Business_Unit_Desc
			</cfif>
			<cfif GPO_Alias_Search>
				, GPO.GPO_Key
			</cfif>
From		BSA_Operator

		 	<cfif businessSegEnabledForOperator>
				LEFT JOIN Business_Segment Bus_Seg
				ON Bus_Seg.Business_Segment_ID = BSA_Operator.Business_Segment_ID
			</cfif>
			<CFIF FORM.Position_ID NEQ "" OR FORM.Market_ID NEQ "">
			LEFT JOIN Market_ZipCode
			ON
			Market_ZipCode.Deleted = 0
			AND
			BSA_Operator.User_positions_ID IS NULL
			AND
			Market_ZipCode.ZipCode = Left(BSA_Operator.Operator_Zip, 5)
			<CFIF FORM.Market_ID NEQ "">
			AND
			Market_ZipCode.Service_Market_ID = #FORM.Market_ID#
			</CFIF>
			INNER JOIN User_Positions
			ON
			User_Positions.Deleted = 0
			AND
			(
				(
					BSA_Operator.User_Positions_ID IS NULL
					AND
					User_Positions.Service_Market_ID = Market_ZipCode.Service_Market_ID
				)
				OR
				(
					BSA_Operator.User_Positions_ID IS NOT NULL
					AND
					User_Positions.User_Positions_ID = BSA_Operator.User_Positions_ID
				)
			)
			<CFIF FORM.Position_ID NEQ "">
				AND
				User_Positions.User_Positions_ID = #FORM.Position_ID#
			</CFIF>
			<CFIF FORM.Market_ID NEQ "">
				AND
				User_Positions.Service_Market_ID = #FORM.Market_ID#
			</CFIF>
			</CFIF>

			<cfif ShowVendorAndBBClosingMethod EQ 1>       <!---26298 Feb 16, 2011 --->
				LEFT JOIN Vendor_Master ON BSA_Operator.Default_Vendor_ID = Vendor_Master.Vendor_ID
															 AND Vendor_Master.Deleted = 0  <!---26298 modified for consistency, vendor master search filters out deleted records--->
				LEFT JOIN Billback_Closing_Methods ON BSA_Operator.Default_Billback_Closing_Method_ID = Billback_Closing_Methods.iBillback_Closing_Method_ID
			</cfif>
			<cfif GPO_Alias_Search>
				INNER JOIN operator_gpo GPO
				ON GPO.Operator_GPO_ID = BSA_Operator.Operator_GPO_ID
			</cfif>
Where		0=0
			<!---30286 - if we are coming from the create list form then use this criteria only, otherwise use the rest of the logic--->
			<cfif form.passed_form NEQ "" and form.itemList NEQ "">
			  <cfif form.itemList EQ "0">     <!---invalid items was selected in create list--->
			  	AND 1 = 0
			  <cfelseif LegacyIdOn>
					AND BSA_Operator.Legacy_Id in ( #PreserveSingleQuotes(form.itemList)# )
			  <cfelse>
					AND BSA_Operator.BSA_Operator_Id in ( #PreserveSingleQuotes(form.itemList)# )
				</cfif>
				<cfif GPO_One_Page_Program_Creation EQ '1' AND GPO_Alias_Search EQ 0>
					AND   operator_type != 'GPO_Roster'
				</cfif> 
			<cfelse>
						<CFIF form.Active_Status IS NOT "">
							<cfif form.Active_Status EQ 1>
							AND BSA_Operator.deleted = 0
							AND BSA_Operator.display_code = 'A'
							<cfelseif form.Active_Status EQ 0>
							AND BSA_Operator.display_code = 'N'
							<cfelseif form.Active_Status EQ 2>
							AND BSA_Operator.Deleted = 0
							<cfelseif form.Active_Status EQ 3>
							AND BSA_Operator.Deleted = 1
							</cfif>
						<cfelse>
							<cfif (isDefined("Get_Profile_Settings.Search_Inactive_Operators_Programs") AND Get_Profile_Settings.Search_Inactive_Operators_Programs EQ 0)>
								AND BSA_Operator.deleted = 0
								AND BSA_Operator.display_code = 'A'
							</cfif>
						</CFIF>

						<CFIF Operator_State NEQ "All" AND Operator_State NEQ "">
							and
							Operator_State	=	'#Operator_State#'
						</CFIF>

						<CFIF Operator_Country_Code NEQ "0">
							and
							Operator_Country_Code	=	'#Operator_Country_Code#'
						</CFIF>

						<CFIF Operator_Type NEQ "All" AND Operator_Type NEQ "">
							and
							Operator_Type	=	'#Operator_Type#'
						</CFIF>

						<CFIF Operator_Location_Type NEQ "All" AND Operator_Location_Type NEQ "">
							and Operator_Location_Type	=	'#Operator_Location_Type#'
						</CFIF>

						<CFIF trim(Operator_Name) NEQ "">
							and
							Operator_Name 	like 	'%#Operator_Name#%'
						</CFIF>

						<CFIF trim(Operator_City) NEQ "">
							and
							Operator_City 	like 	'%#Operator_City#%'
						</CFIF>

						<CFIF trim(Operator_Zip) NEQ "">
							and
							Operator_Zip like '%#Operator_Zip#%'
						</CFIF>

					<cfif GPO_Alias_Search AND  trim(GPO_Key) NEQ "">
						and
						GPO_Key = '#GPO_Key#'
					</cfif>

						<CFIF trim(Operator_DBA) NEQ "">
							and
							Operator_DBA 	like 	'%#Operator_DBA#%'
						</CFIF>
						<CFIF trim(form.legacy_id) NEQ "">
							and
							legacy_id 	like 	'%#form.legacy_id#%'
						</CFIF>

						<CFIF trim(form.BSA_Operator_ID) NEQ "">
							and
							BSA_Operator_ID	 = <cfif isnumeric(form.BSA_Operator_ID)><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.BSA_Operator_ID#"><cfelse>''</cfif>
						</CFIF>

						<CFIF trim(FORM.Operator_Number_Of_Locations) NEQ "" AND isNumeric(Replace(FORM.Operator_Number_Of_Locations,"-","","ALL")) AND FORM.Number_Locations_Operation NEQ "">
							and
							CAST(Replace(Operator_Number_Of_Locations,'-','') AS BIGINT) #FORM.Number_Locations_Operation# #Replace(FORM.Operator_Number_Of_Locations,"-","","ALL")#
						</CFIF>

						<CFIF Operator_Category NEQ "All" AND Operator_Category NEQ "">
							and
							Operator_Category_ID	=	#Operator_Category#
						</CFIF>

						<CFIF Operator_Priority NEQ "All" AND Operator_Priority NEQ "">
							and
							Operator_Priority_ID	=	#Operator_Priority#
						</CFIF>

						<cfif not appSettings.getShowBSAOperators()>
							AND (Legacy_ID IS NOT NULL AND Len(Legacy_ID) != 0)
						</cfif>
						<cfif GPO_One_Page_Program_Creation EQ '1' AND GPO_Alias_Search EQ 0>
							AND   operator_type != 'GPO_Roster'
						</cfif> 
						<!--- 26298 2/15/2011 ChrisN - If default vendor / bb closing method is on implement the appropriate filters  --->
						<cfif ShowVendorAndBBClosingMethod EQ 1>
							<cfif form.Default_Vendor EQ 1>
								AND isnull(nullif(BSA_Operator.Default_Vendor_ID,''),0) <> 0
							<cfelseif form.Default_Vendor EQ 2>
								AND isnull(nullif(BSA_Operator.Default_Vendor_ID,''),0) = 0
							</cfif>
			 <!--- Dev Note: Drachala; D27577 : Payable Settings, Default BB Closing Method add option callled 'Both'  START--->
							<cfif (#Len(Default_BB_Closing_Method)# GT 0) AND (#Form.Default_BB_Closing_Method# EQ "Both")>
						AND BSA_Operator.Default_Billback_Closing_Method_ID IN (1,2)
					<cfelseif #Len(Default_BB_Closing_Method)#>
								AND BSA_Operator.Default_Billback_Closing_Method_ID = '#Form.Default_BB_Closing_Method#'
							</cfif>
			 <!--- Dev Note: Drachala; D27577 : Payable Settings, Default BB Closing Method add option callled 'Both'  END--->
						</cfif>
			</cfif>

ORDER BY #PreserveSingleQuotes(sql_Sort_By)# #sql_Sort_By_Order#

	OFFSET  #OFFSETStartRow# ROWS
	FETCH NEXT 200 ROWS ONLY

</CFQUERY>
<!--- 	97118: Planning Groups importing max of 200 records / Anand Rao / 16-Apr-2020
		The below query returns all the BSA_Operator_IDs to be imported when 
		"import all returned operators button is clicked". Any changes made to the 
		"TheQuery" should also be made to below query.
--->
<CFQUERY NAME="TheQueryAll" datasource="#application.datasource#">

Select	Rows_Cnt = COUNT(1) OVER(),

BSA_Operator.*

			<!---26298 Feb 16, 2011 added vendor name, bb closing method description when it is applicable --->
			<cfif ShowVendorAndBBClosingMethod EQ 1>
					,Vendor_Master.Vendor_Name, Billback_Closing_Methods.vchBillback_Closing_Method_Desc
			</cfif>
			<cfif businessSegEnabledForOperator>
				,Bus_Seg.Business_Unit_Desc
			</cfif>
			<cfif GPO_Alias_Search>
				, GPO.GPO_Key
			</cfif>
From		BSA_Operator

		 	<cfif businessSegEnabledForOperator>
				LEFT JOIN Business_Segment Bus_Seg
				ON Bus_Seg.Business_Segment_ID = BSA_Operator.Business_Segment_ID
			</cfif>
			<CFIF FORM.Position_ID NEQ "" OR FORM.Market_ID NEQ "">
			LEFT JOIN Market_ZipCode
			ON
			Market_ZipCode.Deleted = 0
			AND
			BSA_Operator.User_positions_ID IS NULL
			AND
			Market_ZipCode.ZipCode = Left(BSA_Operator.Operator_Zip, 5)
			<CFIF FORM.Market_ID NEQ "">
			AND
			Market_ZipCode.Service_Market_ID = #FORM.Market_ID#
			</CFIF>
			INNER JOIN User_Positions
			ON
			User_Positions.Deleted = 0
			AND
			(
				(
					BSA_Operator.User_Positions_ID IS NULL
					AND
					User_Positions.Service_Market_ID = Market_ZipCode.Service_Market_ID
				)
				OR
				(
					BSA_Operator.User_Positions_ID IS NOT NULL
					AND
					User_Positions.User_Positions_ID = BSA_Operator.User_Positions_ID
				)
			)
			<CFIF FORM.Position_ID NEQ "">
				AND
				User_Positions.User_Positions_ID = #FORM.Position_ID#
			</CFIF>
			<CFIF FORM.Market_ID NEQ "">
				AND
				User_Positions.Service_Market_ID = #FORM.Market_ID#
			</CFIF>
			</CFIF>

			<cfif ShowVendorAndBBClosingMethod EQ 1>       <!---26298 Feb 16, 2011 --->
				LEFT JOIN Vendor_Master ON BSA_Operator.Default_Vendor_ID = Vendor_Master.Vendor_ID
															 AND Vendor_Master.Deleted = 0  <!---26298 modified for consistency, vendor master search filters out deleted records--->
				LEFT JOIN Billback_Closing_Methods ON BSA_Operator.Default_Billback_Closing_Method_ID = Billback_Closing_Methods.iBillback_Closing_Method_ID
			</cfif>
			<cfif GPO_Alias_Search>
				INNER JOIN operator_gpo GPO
				ON GPO.Operator_GPO_ID = BSA_Operator.Operator_GPO_ID
			</cfif>
Where		0=0
			<cfif form.passed_form NEQ "" and form.itemList NEQ "">
			  <cfif form.itemList EQ "0">     <!---invalid items was selected in create list--->
			  	AND 1 = 0
			  <cfelseif LegacyIdOn>
					AND BSA_Operator.Legacy_Id in ( #PreserveSingleQuotes(form.itemList)# )
			  <cfelse>
					AND BSA_Operator.BSA_Operator_Id in ( #PreserveSingleQuotes(form.itemList)# )
				</cfif>
				<cfif GPO_One_Page_Program_Creation EQ '1' AND GPO_Alias_Search EQ 0>
					AND   operator_type != 'GPO_Roster'
				</cfif> 
			<cfelse>
						<CFIF form.Active_Status IS NOT "">
							<cfif form.Active_Status EQ 1>
							AND BSA_Operator.deleted = 0
							AND BSA_Operator.display_code = 'A'
							<cfelseif form.Active_Status EQ 0>
							AND BSA_Operator.display_code = 'N'
							<cfelseif form.Active_Status EQ 2>
							AND BSA_Operator.Deleted = 0
							<cfelseif form.Active_Status EQ 3>
							AND BSA_Operator.Deleted = 1
							</cfif>
						</CFIF>

						<CFIF Operator_State NEQ "All" AND Operator_State NEQ "">
							and
							Operator_State	=	'#Operator_State#'
						</CFIF>

						<CFIF Operator_Country_Code NEQ "0">
							and
							Operator_Country_Code	=	'#Operator_Country_Code#'
						</CFIF>

						<CFIF Operator_Type NEQ "All" AND Operator_Type NEQ "">
							and
							Operator_Type	=	'#Operator_Type#'
						</CFIF>

						<CFIF Operator_Location_Type NEQ "All" AND Operator_Location_Type NEQ "">
							and Operator_Location_Type	=	'#Operator_Location_Type#'
						</CFIF>

						<CFIF trim(Operator_Name) NEQ "">
							and
							Operator_Name 	like 	'%#Operator_Name#%'
						</CFIF>

						<CFIF trim(Operator_City) NEQ "">
							and
							Operator_City 	like 	'%#Operator_City#%'
						</CFIF>

						<CFIF trim(Operator_Zip) NEQ "">
							and
							Operator_Zip like '%#Operator_Zip#%'
						</CFIF>

					<cfif GPO_Alias_Search AND  trim(GPO_Key) NEQ "">
						and
						GPO_Key = '#GPO_Key#'
					</cfif>

						<CFIF trim(Operator_DBA) NEQ "">
							and
							Operator_DBA 	like 	'%#Operator_DBA#%'
						</CFIF>
						<CFIF trim(form.legacy_id) NEQ "">
							and
							legacy_id 	like 	'%#form.legacy_id#%'
						</CFIF>

						<CFIF trim(form.BSA_Operator_ID) NEQ "">
							and
							BSA_Operator_ID	 = <cfif isnumeric(form.BSA_Operator_ID)><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.BSA_Operator_ID#"><cfelse>''</cfif>
						</CFIF>

						<CFIF trim(FORM.Operator_Number_Of_Locations) NEQ "" AND isNumeric(Replace(FORM.Operator_Number_Of_Locations,"-","","ALL")) AND FORM.Number_Locations_Operation NEQ "">
							and
							CAST(Replace(Operator_Number_Of_Locations,'-','') AS BIGINT) #FORM.Number_Locations_Operation# #Replace(FORM.Operator_Number_Of_Locations,"-","","ALL")#
						</CFIF>

						<CFIF Operator_Category NEQ "All" AND Operator_Category NEQ "">
							and
							Operator_Category_ID	=	#Operator_Category#
						</CFIF>

						<CFIF Operator_Priority NEQ "All" AND Operator_Priority NEQ "">
							and
							Operator_Priority_ID	=	#Operator_Priority#
						</CFIF>

						<cfif not appSettings.getShowBSAOperators()>
							AND (Legacy_ID IS NOT NULL AND Len(Legacy_ID) != 0)
						</cfif>
						<cfif GPO_One_Page_Program_Creation EQ '1' AND GPO_Alias_Search EQ 0>
							AND   operator_type != 'GPO_Roster'
						</cfif> 
						<cfif ShowVendorAndBBClosingMethod EQ 1>
							<cfif form.Default_Vendor EQ 1>
								AND isnull(nullif(BSA_Operator.Default_Vendor_ID,''),0) <> 0
							<cfelseif form.Default_Vendor EQ 2>
								AND isnull(nullif(BSA_Operator.Default_Vendor_ID,''),0) = 0
							</cfif>
							<cfif (#Len(Default_BB_Closing_Method)# GT 0) AND (#Form.Default_BB_Closing_Method# EQ "Both")>
						AND BSA_Operator.Default_Billback_Closing_Method_ID IN (1,2)
					<cfelseif #Len(Default_BB_Closing_Method)#>
								AND BSA_Operator.Default_Billback_Closing_Method_ID = '#Form.Default_BB_Closing_Method#'
							</cfif>
						</cfif>
			</cfif>

ORDER BY #PreserveSingleQuotes(sql_Sort_By)# #sql_Sort_By_Order#
</CFQUERY>

<SCRIPT>
	<CFIF TheQuery.recordcount GT 0>
	    //window.onload = maxWindow;

    function maxWindow() {
        window.moveTo(0, 0);
        top.window.resizeTo(screen.availWidth, screen.availHeight);
     }	
	</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		function CA() {
			if(<CFIF TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many operators in the list below while selecting them all. Press OK If You Wish To Continue")<CFELSE>0==0</CFIF>) {
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
	<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
		<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF TheQuery.Rows_Cnt EQ 1>is<CFELSE>are</CFIF> <CFOUTPUT>&nbsp;#TheQuery.Rows_Cnt#</CFOUTPUT> <CFIF TheQuery.Rows_Cnt EQ 1><cfoutput>#lcase(application.returned_customer_setting.operator_label_singular)#</cfoutput><CFELSE><cfoutput>#lcase(application.returned_customer_setting.operator_label_plural)#</cfoutput></CFIF> that <CFIF TheQuery.Rows_Cnt EQ 1>matched<CFELSE>match</CFIF> the above criteria</LEGEND>
		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF TheQuery.recordcount GT 0>

		<CFSET showHideColumnsSetting()>

			<CFIF 0 EQ 1>
			<!--- <CFIF TheQuery.recordcount GTE 500> --->
				<FONT SIZE="3"><B>Your query returned more than 500 records. Please narrow your search.</B></FONT>
			<CFELSE>

				<TABLE border="0" cellspacing="0" cellpadding="2" align="center" CLASS="Maintable" width="100%">
					<cfif ! GPO_Alias_Search>
						<COLGROUP>
						<COL SPAN="1" WIDTH="5%">
						<COL SPAN="1" WIDTH="28%">
						<cfif LegacyIdOn>
							<COL SPAN="1" WIDTH="5%">
						</cfif>
						<COL SPAN="1" WIDTH="10%">
						<COL SPAN="1" WIDTH="10%">
						<COL SPAN="1" WIDTH="10%">
						<COL SPAN="1" WIDTH="33%">
						</COLGROUP>
					</cfif>
					<TR ID="header" BGCOLOR="#ffce84">
						<CFIF FORM.SelectSingleSearchResultOnly EQ 0><TD align="center"><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Operators"></TD><CFELSE><TD>&nbsp;</TD></CFIF>
						<cfoutput>

						<!--- 26298 Feb 15, 2011 ChrisN set up columns to be displayed --->
						<cfscript>

						if(GPO_Alias_Search){
							
							constant = {
									operator_name		= "operator_name",
									operator_name_id	= "operator_name_id",
									operator_id			= "operator_id",
									vendor_id			= "vendor_id",
									vendor_name			= "vendor_name",
									bb_closing			= "bb_closing",
									city_state			= "city_state",
									city				= "city",
									state				= "state",
									no_locations		= "no_locations",
									legacy_id_only		= "legacy_id",
									legacy_id_combo		= "legacy_id_combo",   // legacy id if exists otherwise operator id
									location_type		= "location_type",
									dba					= "doing_business_as",
									business_segment	= "#appsettings.Business_Segment_Label#",
									gpo_key = 'gpo_key',
									tier = "tier",
									operator_address = "operator_address",
									operator_address2 = "operator_address2",
									operator_zip = "operator_zip",
									operator_number_of_locations = "operator_number_of_locations",
									operator_phone = "operator_phone",
									operator_first_name = "operator_first_name",
									operator_last_name = "operator_last_name"
							};
						}else{
								constant = {
									operator_name		= "operator_name",
									operator_name_id	= "operator_name_id",
									operator_id			= "operator_id",
									vendor_id			= "vendor_id",
									vendor_name			= "vendor_name",
									bb_closing			= "bb_closing",
									city_state			= "city_state",
									city				= "city",
									state				= "state",
									no_locations		= "no_locations",
									legacy_id_only		= "legacy_id",
									legacy_id_combo		= "legacy_id_combo",   // legacy id if exists otherwise operator id
									location_type		= "location_type",
									dba					= "doing_business_as",
									business_segment	= "#appsettings.Business_Segment_Label#"
							};
						}


							// 26298 def vendor & bb closing method mode is on, shows operator name, legacy id (if none exist use operator id),
							//       vendor id, vendor name, bb closing method
							
								if(GPO_Alias_Search){
											listColumnsToShow = constant.gpo_key;
											listColumnsToShow = ListAppend(listColumnsToShow,constant.tier);
										if(LegacyIdOn){
											listColumnsToShow = ListAppend(listColumnsToShow,constant.legacy_id_only);
										}
										if(OprResults_DisplayLocationType){
											listColumnsToShow = ListAppend(listColumnsToShow,constant.location_type);
										}
											listColumnsToShow = ListAppend(listColumnsToShow,constant.operator_name_id);
											listColumnsToShow = ListAppend(listColumnsToShow,constant.operator_address);
											listColumnsToShow = ListAppend(listColumnsToShow,constant.operator_address2);
										
										if(OprResults_DisplayCity && OprResults_DisplayState){
											listColumnsToShow = ListAppend(listColumnsToShow,constant.city_state);
										}
										else if(OprResults_DisplayCity){
											listColumnsToShow = ListAppend(listColumnsToShow,constant.city);
										}
											listColumnsToShow = ListAppend(listColumnsToShow,constant.operator_zip);
											listColumnsToShow = ListAppend(listColumnsToShow,constant.operator_number_of_locations);
											listColumnsToShow = ListAppend(listColumnsToShow,constant.operator_phone);
											listColumnsToShow = ListAppend(listColumnsToShow,constant.operator_first_name);
											listColumnsToShow = ListAppend(listColumnsToShow,constant.operator_last_name);
								}else{

								listColumnsToShow = constant.operator_name_id;

							if (ShowVendorAndBBClosingMethod eq 1){
								if((LegacyIdOn || OprResults_DisplayBSAOperatorID)){
									listColumnsToShow = ListAppend(listColumnsToShow,constant.legacy_id_combo);
								}

									listColumnsToShow = ListAppend(listColumnsToShow,constant.vendor_id);
									listColumnsToShow = ListAppend(listColumnsToShow,constant.vendor_name);
									listColumnsToShow = ListAppend(listColumnsToShow,constant.bb_closing);

								if(OprResults_DisplayBusinessSegment){
									listColumnsToShow = ListAppend(listColumnsToShow,constant.business_segment);
								}
							}
							else{
								if(LegacyIdOn){
									listColumnsToShow = ListAppend(listColumnsToShow,constant.legacy_id_only);
								}


									if(GPO_One_Page_Program_Creation == 1){listColumnsToShow = ListAppend(listColumnsToShow,"operator_address");}

									if(OprResults_DisplayCity && OprResults_DisplayState){
										listColumnsToShow = ListAppend(listColumnsToShow,constant.city_state);
									}

								if(OprResults_DisplayCity && OprResults_DisplayState){
									listColumnsToShow = ListAppend(listColumnsToShow,constant.city_state);
								}


								else if(OprResults_DisplayCity){
									listColumnsToShow = ListAppend(listColumnsToShow,constant.city);
								}

								else if(OprResults_DisplayState){
									listColumnsToShow = ListAppend(listColumnsToShow,constant.state);
								}

								if(OprResults_DisplayLocationType){
									listColumnsToShow = ListAppend(listColumnsToShow,constant.location_type);
								}

									if(OprResults_DisplayBusinessSegment){
										listColumnsToShow = ListAppend(listColumnsToShow,constant.business_segment);
									}

								}
							}

							columnsToShow = listtoArray(listColumnsToShow);
							HeaderNameList   = "";
							HeaderColumnList = "";
							// this noneForNull value is displayed when Vendor ID or BB Closing Method is undefined
							noneForNull      = '<span style="color:red">--none--</span>';
						</cfscript>

						<!--- set up header lists based on the above defined columns --->
						<cfloop index="thisColumn" array="#columnsToShow#">
							<cfscript>
								// display operator name
								if ((thisColumn eq constant.operator_name_id) or (thisColumn eq constant.operator_name)) {
									HeaderNameList = ListAppend(HeaderNameList, application.returned_customer_setting.operator_label_singular & " Name");
									HeaderColumnList = ListAppend(HeaderColumnList, "Operator Name");
								}
								// display legacy id
								else if ((thisColumn eq constant.legacy_id_only) or (thisColumn eq constant.legacy_id_combo)) {
									IDlabel = application.returned_customer_setting.operator_label_singular & " ID";
									HeaderNameList = ListAppend(HeaderNameList, IDlabel);
									//Set the sort field correctly
									if (thisColumn eq constant.legacy_id_only)
										HeaderColumnList = ListAppend(HeaderColumnList, "Legacy Id");
									else if (thisColumn eq constant.legacy_id_combo)
										HeaderColumnList = ListAppend(HeaderColumnList, "Legacy Id Combo");
									else
										HeaderColumnList = ListAppend(HeaderColumnList, IDlabel);
									
								}

								// display location type
								else if (thisColumn eq constant.location_type) {
									HeaderNameList = ListAppend(HeaderNameList, "#qGetLocationTypeLabel.GENERAL_LABELS_LABEL#<br>");
									HeaderColumnList = ListAppend(HeaderColumnList, "Location Type");
								}

								// display city state
								else if (thisColumn eq constant.city_state) {
									HeaderNameList = ListAppend(HeaderNameList, "City<br/>State");
									HeaderColumnList = ListAppend(HeaderColumnList, "State");
								}

								// display city
								else if (thisColumn eq constant.city) {
									HeaderNameList = ListAppend(HeaderNameList, "City");
									HeaderColumnList = ListAppend(HeaderColumnList, "City");
								}

								// display state
								else if (thisColumn eq constant.state) {
									HeaderNameList = ListAppend(HeaderNameList, "State");
									HeaderColumnList = ListAppend(HeaderColumnList, "State");
								}


								// display number of locations
								/*else if (thisColumn eq constant.no_locations) {
									HeaderNameList = ListAppend(HeaderNameList, "Locations");
									HeaderColumnList = ListAppend(HeaderColumnList, "Number of Locations");
								}*/

								// display doing business as
								/*else if (thisColumn eq constant.dba) {
									HeaderNameList = ListAppend(HeaderNameList, "Doing Business As");
									HeaderColumnList = ListAppend(HeaderColumnList, "Doing Business As");
								}*/

								// display vendor id
								else if (thisColumn eq constant.vendor_id) {
									HeaderNameList = ListAppend(HeaderNameList, "Vendor ID");
									HeaderColumnList = ListAppend(HeaderColumnList, "Vendor ID");
								}

								// display vendor name
								else if (thisColumn eq constant.vendor_name) {
									HeaderNameList = ListAppend(HeaderNameList, "Vendor Name");
									HeaderColumnList = ListAppend(HeaderColumnList, "Vendor Name");
								}

								// display bb closing method
								else if (thisColumn eq constant.bb_closing) {
									HeaderNameList = ListAppend(HeaderNameList, "BB Closing Method");
									HeaderColumnList = ListAppend(HeaderColumnList, "BB Closing Method");
								}

								else if (thisColumn eq constant.business_segment AND application.returned_customer_setting.Business_Segments_On EQ 1) {
									HeaderNameList = ListAppend(HeaderNameList, "#appsettings.Business_Segment_Label#");
									HeaderColumnList = ListAppend(HeaderColumnList, "#appsettings.Business_Segment_Label#");
								}
								else if (thisColumn eq "operator_address") {
									HeaderNameList = ListAppend(HeaderNameList, "Address 1");
									HeaderColumnList = ListAppend(HeaderColumnList, "operator_address");
								}

							if(GPO_Alias_Search){
								
								// display gpo key
								if (thisColumn eq constant.gpo_key) {
									HeaderNameList = ListAppend(HeaderNameList, "GPO Key");
									HeaderColumnList = ListAppend(HeaderColumnList, "gpo_key");
								}								
								// display tier
								else if (thisColumn eq constant.tier) {
									HeaderNameList = ListAppend(HeaderNameList, "Tier");
									HeaderColumnList = ListAppend(HeaderColumnList, "tier");
								}
								// display operator address
								else if (thisColumn eq constant.operator_address2) {
									HeaderNameList = ListAppend(HeaderNameList, "Address 2");
									HeaderColumnList = ListAppend(HeaderColumnList, "operator_address2");
								}
								// display operator zip
								else if (thisColumn eq constant.operator_zip) {
									HeaderNameList = ListAppend(HeaderNameList, "Zip Code");
									HeaderColumnList = ListAppend(HeaderColumnList, "operator_zip");
								}
								// display operator locations
								else if (thisColumn eq constant.operator_number_of_locations) {
									HeaderNameList = ListAppend(HeaderNameList, "Top Parent Name 1");
									HeaderColumnList = ListAppend(HeaderColumnList, "operator_number_of_locations");
								}
								// display operator phone
								else if (thisColumn eq constant.operator_phone) {
									HeaderNameList = ListAppend(HeaderNameList, "Top Parent Name 2");
									HeaderColumnList = ListAppend(HeaderColumnList, "operator_phone");
								}
								// display operator first name
								else if (thisColumn eq constant.operator_first_name) {
									HeaderNameList = ListAppend(HeaderNameList, "Direct Parent Name 1");
									HeaderColumnList = ListAppend(HeaderColumnList, "operator_first_name");
								}
								// display operator last name
								else if (thisColumn eq constant.operator_last_name) {
									HeaderNameList = ListAppend(HeaderNameList, "Direct Parent Name 2");
									HeaderColumnList = ListAppend(HeaderColumnList, "operator_last_name");
								}
							}
							</cfscript>
						</cfloop>
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
							<TD ID="header" align="left">
								<A HREF="##" OnClick="javaScript: return sortByThisItem(this,'#listgetat(HeaderColumnList,Counter)#','#New_Sort_Order#');">
									<b>#this_Header#</b>
									<CFIF Len(sortImage) GT 0> <IMG BORDER="0" SRC="/Images/#sortImage#"></CFIF>
								</A>
							</TD>
							<CFSET Counter = Counter + 1>
							</CFLOOP>
						</cfoutput>
					</TR>
				<CFOUTPUT QUERY="TheQuery">
					<cfset operatorProfileWindow = "NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;">
					<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> style="cursor: pointer;">
						<TD align="center">
	<cfif searchoperator EQ 0>
						<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
							<INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Operator_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Operator_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.BSA_Operator_ID), ",")></CFIF>>
						<CFELSE>

						<cfif (LegacyIdOn AND FORM.flexModule EQ 'upload')>
						<INPUT type="Radio" NAME="SelectedITEMS" VALUE="#trim(TheQuery.Legacy_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.Legacy_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.Legacy_ID), ",")></CFIF>>
						<cfelse>
							<INPUT type="Radio" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Operator_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Operator_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.BSA_Operator_ID), ",")></CFIF>>
						</cfif>
						</CFIF>
	<cfelse>
	&nbsp;
	</cfif>

						</TD>

						<!---building table row content based on the selected columns to show--->
						<cfloop index="thisColumn" array="#columnsToShow#">
							<!---display operator name and id--->
							<cfif thisColumn eq constant.operator_name_id>
								<td NOWRAP onClick="#operatorProfileWindow#">#TheQuery.operator_name#<CFIF trim(TheQuery.legacy_id) EQ "" OR LegacyIdOn EQ 0> [#TheQuery.BSA_Operator_Id#]</cfif></td>

								<!---display operator name--->
							<cfelseif thisColumn eq constant.operator_name>
								<td NOWRAP onClick="#operatorProfileWindow#">
									#TheQuery.operator_name#
								</td>

								<!---display legacy id--->
							<cfelseif thisColumn eq constant.legacy_id_only>
								<cfif LegacyIdOn>
									<td NOWRAP onClick="#operatorProfileWindow#">
										#TheQuery.legacy_id#&nbsp;
									</td>
								</cfif>

								<!---display city state--->
							<cfelseif thisColumn eq constant.city_state>
								<td NOWRAP onClick="#operatorProfileWindow#">
									#TheQuery.Operator_City# - #TheQuery.Operator_State#&nbsp;#TheQuery.Operator_Country_Code#
								</td>

								<!---display city--->
							<cfelseif thisColumn eq constant.city>
								<td NOWRAP onClick="#operatorProfileWindow#">
									#TheQuery.Operator_City# - #TheQuery.Operator_Country_Code#
								</td>

								<!---display state --->
							<cfelseif thisColumn eq constant.state>
								<td NOWRAP onClick="#operatorProfileWindow#">
									#TheQuery.Operator_State# - #TheQuery.Operator_Country_Code#
								</td>

								<!---display location type--->
							<cfelseif thisColumn eq constant.location_type>
								<td NOWRAP onClick="#operatorProfileWindow#">
									#TheQuery.Operator_Location_Type#&nbsp;
								</td>

								<!---display number of locations--->
							<!---<cfelseif thisColumn eq constant.no_locations>
								<td NOWRAP onClick="#operatorProfileWindow#">
									#numberformat(Replace(TheQuery.Operator_Number_Of_Locations,'-','','ALL'),'_,___,___')#&nbsp;
								</td>--->

								<!---display doing business as--->
							<!---<cfelseif thisColumn eq constant.dba>
								<td onClick="#operatorProfileWindow#">
									#TheQuery.Operator_DBA#&nbsp;
								</td>--->

								<!--- display legacy_id and if none exists then display ba operator id --->
							<cfelseif thisColumn eq constant.legacy_id_combo>
								<td onClick="#operatorProfileWindow#"><cfif Len(TheQuery.legacy_id)>#TheQuery.legacy_id#<cfelse>#TheQuery.BSA_Operator_Id#</cfif>&nbsp;</td>

								<!---display vendor id--->
							<cfelseif thisColumn eq constant.vendor_id>
								<td onClick="#operatorProfileWindow#">
									<cfif Len(TheQuery.Default_Vendor_ID)>#TheQuery.Default_Vendor_ID#<cfelse>#noneForNull#</cfif>
								</td>

								<!---display bb closing method--->
							<cfelseif thisColumn eq constant.bb_closing>
								<td onClick="#operatorProfileWindow#">
									<cfif Len(TheQuery.vchBillback_Closing_Method_Desc)>#TheQuery.vchBillback_Closing_Method_Desc#<cfelse>#noneForNull#</cfif>
								</td>

							<cfelseif thisColumn eq constant.bb_closing>
								<td onClick="#operatorProfileWindow#">
									<cfif Len(TheQuery.vchBillback_Closing_Method_Desc)>#TheQuery.vchBillback_Closing_Method_Desc#<cfelse>#noneForNull#</cfif>
								</td>
							<cfelseif thisColumn eq constant.vendor_name>
								<td onClick="#operatorProfileWindow#">
									<cfif Len(TheQuery.Vendor_Name)>#TheQuery.Vendor_Name#<cfelse>#noneForNull#</cfif>
								</td>
							<cfelseif thisColumn eq constant.business_segment AND application.returned_customer_setting.Business_Segments_On EQ 1>
								<td onClick="#operatorProfileWindow#">
									<cfif Len(TheQuery.Business_Unit_Desc)>#TheQuery.Business_Unit_Desc#<cfelse>#noneForNull#</cfif>
								</td>
							<cfelseif thisColumn eq "operator_address">
									<td onClick="#operatorProfileWindow#">
										<cfif Len(TheQuery.operator_address)>#TheQuery.operator_address#<cfelse>#noneForNull#</cfif>
									</td>
							</cfif>
							
							<cfif GPO_Alias_Search>
								<cfif thisColumn eq constant.gpo_key>
									<td onClick="#operatorProfileWindow#">
										<cfif Len(TheQuery.gpo_key)>#TheQuery.gpo_key#<cfelse>#noneForNull#</cfif>
									</td>
								<cfelseif thisColumn eq constant.tier>
									<td onClick="#operatorProfileWindow#">
										<cfif Len(TheQuery.tier)>#TheQuery.tier#<cfelse>#noneForNull#</cfif>
									</td>
								<cfelseif thisColumn eq constant.operator_address2>
									<td onClick="#operatorProfileWindow#">
										<cfif Len(TheQuery.operator_address2)>#TheQuery.operator_address2#<cfelse>#noneForNull#</cfif>
									</td>
								<cfelseif thisColumn eq constant.operator_zip>
									<td onClick="#operatorProfileWindow#">
										<cfif Len(TheQuery.operator_zip)>#TheQuery.operator_zip#<cfelse>#noneForNull#</cfif>
									</td>
								<cfelseif thisColumn eq constant.operator_number_of_locations>
									<td onClick="#operatorProfileWindow#">
										<cfif Len(TheQuery.operator_number_of_locations)>#TheQuery.operator_number_of_locations#<cfelse>#noneForNull#</cfif>
									</td>
								<cfelseif thisColumn eq constant.operator_phone>
									<td onClick="#operatorProfileWindow#">
										<cfif Len(TheQuery.operator_phone)>#TheQuery.operator_phone#<cfelse>#noneForNull#</cfif>
									</td>
								<cfelseif thisColumn eq constant.operator_first_name>
									<td onClick="#operatorProfileWindow#">
										<cfif Len(TheQuery.operator_first_name)>#TheQuery.operator_first_name#<cfelse>#noneForNull#</cfif>
									</td>
								<cfelseif thisColumn eq constant.operator_last_name>
									<td onClick="#operatorProfileWindow#">
										<cfif Len(TheQuery.operator_last_name)>#TheQuery.operator_last_name#<cfelse>#noneForNull#</cfif>
									</td>
								</cfif>
							</cfif>						
						</cfloop>
					</TR>
					<cfflush>
				</CFOUTPUT>
				</TABLE>
				
<DIV ALIGN="center" STYLE="font-size: 12px; color: Red;">
<cfset queryData.recordCount = TheQuery.Rows_Cnt />

		<CF_Next_Previous_For_Forms
		formname="MyForm"
		query="queryData"
		maxpages="40"
		previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
		next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
		previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		addparams="">

</DIV>
	
			</CFIF>


		</CFIF>
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
	</SCRIPT>

<INPUT TYPE="hidden" NAME="ParentFormname" 						VALUE="<CFOUTPUT>#FORM.ParentFormname#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="FinalItemList" VALUE="<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="AlreadySelectedItems" VALUE="<CFOUTPUT>#Form.AlreadySelectedItems#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="finishedselectingitems" VALUE="0">
<INPUT TYPE="hidden" NAME="LoadSavedOperators" VALUE="0">
<INPUT TYPE="hidden" NAME="SelectSingleSearchResultOnly" VALUE="<CFOUTPUT>#Form.SelectSingleSearchResultOnly#</CFOUTPUT>">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="<CFOUTPUT>#startrow#</CFOUTPUT>">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="<CFOUTPUT>#frompage#</CFOUTPUT>">
<input type="hidden" name="searchoperator" value="<cfoutput>#searchoperator#</cfoutput>">
<INPUT TYPE="Hidden" NAME="FlexAppName" VALUE="<cfoutput>#FORM.FlexAppName#</cfoutput>">
<INPUT TYPE="hidden" NAME="passed_form">     <!---30286--->
<INPUT TYPE="hidden" NAME="itemList">        <!---30286--->
<input type="hidden" name="flexModule" value="<cfoutput>#FORM.flexModule#</cfoutput>" />
<INPUT type="hidden" name="PageSource"  VALUE="<CFOUTPUT>#PageSource#</CFOUTPUT>">
</FORM>
<cfif searchoperator EQ 0>
	<cfif TheQuery.recordcount GT 0>
	<DIV ALIGN="center">
	&nbsp;&nbsp;&nbsp;
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" onClick="javascript: finishedSearching()"> import selected <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput><CFIF AllowImportAll EQ 1>s</CFIF> </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<CFIF FORM.AllowImportAll EQ 1 AND ShowVendorAndBBClosingMethod neq 1>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: pointer;" onClick="importAllProducts(<CFOUTPUT>#TheQueryAll.recordcount#</CFOUTPUT>)"> import all returned <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: pointer;" onClick="removeAllProducts()"> remove all selected <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	</DIV>
	</CFIF>
	<BR>
	</cfif>
</cfif>

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

<cfinclude template="/Common_Files/jQuery.cfm">

<SCRIPT>
	<cfif TheQuery.recordcount GT 0>
		function importAllProducts(recordcount){
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
					document.MyForm.FinalItemList.value 	= document.MyForm.FinalItemList.value + "," + "<CFOUTPUT>#valuelist(TheQueryAll.BSA_Operator_ID)#</CFOUTPUT>";
					<!------//document.SearchForm.FinalUPCList.value 	= document.SearchForm.FinalUPCList.value + "," + "<CFOUTPUT>#whole_Product_List#</CFOUTPUT>";
					//document.SearchForm.FinalUPCList.value 	= "<CFOUTPUT>#whole_Product_List#</CFOUTPUT>";----->
				}
				else{
					document.MyForm.FinalItemList.value 	= "<CFOUTPUT>#valuelist(TheQueryAll.BSA_Operator_ID)#</CFOUTPUT>";
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
			document.all.finishedselectingitems.value = 1
			document.all.MyForm.submit();
		}
	</cfif>

		var operatorWindow = null
		function createOperator(){
			var winl = (screen.width - 435) / 2;
			var wint = (screen.height - 550) / 2;
			operatorWindow = window.open("/profiles/operators/Operator_Creation_Entry_Form_Stripped.cfm","opWindow",
		"height=500,width=660,status=no,toolbar=no,menubar=no,location=no,left="+winl+",top="+wint);
		}

		function doSearch(){
			if(operatorWindow != null) {
				if(confirm("Press OK to Close The <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Creation Window or CANCEL to Return To It.")){
					operatorWindow.close();
					restricted_Operator_Search();
				}
				else{
					operatorWindow.focus();
				}
			}
			else
			{
				restricted_Operator_Search();
			}
		}

	function restricted_Operator_Search()
	{
		var searchForm = document.MyForm;
		searchForm.startrow.value = 1;
		searchForm.frompage.value = 1;
		//searchForm.submit();
		check_Filters(searchForm);
	}
	function check_Filters(searchForm)
	{
		var any_Filter = false;

		/*load filter options into JS variable*/
		<cfset vars.availOptions = "">
		<cfloop array="#filters.options#" index="vars.thisFilter">
			<cfset vars.availOptions = vars.availOptions & "\n - " & vars.thisFilter>
		</cfloop>
		var availOptions = <cfoutput>"#vars.availOptions#"</cfoutput>;

		$("input:not([type=hidden])").each(function() {
			if($(this).val().length){
				any_Filter = true;
			}
		});
		$("select[name!='Active_Status'] option:selected").each(function () {
				// get selected value from dropdown, upper case it
				var selectedValue = $(this).val();
				if (selectedValue.length != 0 || selectedValue != 0){
						any_Filter = true;
				}
			});

		if(any_Filter)
		{
			searchForm.submit();
		}
		else
		{
			<cfif appSettings.getOperatorSearchRestrict()>
				alert("You have to select at least one of the following filters:\n" + availOptions);
			<cfelse>
			if(window.confirm("Your search may take some time as you have not selected any of the following filters.  Do you want to continue?\n" + availOptions))
			{
				searchForm.submit();
			}
			</cfif>
		}
	}

	function verifySave(){
		document.all.finishedselectingitems.value = 1;
		MyForm.submit();
	}
	function sortByThisItem(thisObj, thisSortItem, thisSortOrder)
	{
		if(thisSortItem != "nosort"){
			isSearching = 1;
			var formObj;
			formObj = document.all.MyForm;
			formObj.sort_by.value = thisSortItem;
			formObj.sort_Order.value = thisSortOrder;
			if(formObj.frompage.value.length == 0)	formObj.frompage.value = 1;
			if(formObj.startrow.value.length == 0)	formObj.startrow.value = 1;
			//formObj.submit();
			check_Filters(formObj);
			return false;

		}
	}
</SCRIPT>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="DisplayCreateList" output="true">
	<cfargument name="searchType" type="string" required="true" >   <!---either be operator_legacy_id or bsa_operator_id--->
	<b><font color="red">[</font><font color="blue"><A HREF="javascript:void(0)"  onclick="window.showModalDialog('/Common_Files/createList.cfm?passObj=#arguments.searchType#&passForm=MyForm',window,'dialogHeight:375px;dialogWidth:350px;center:yes;edge:raised'); return false;" >create list</A></font><font color="red">]</font></b>
</cffunction>

<!---
Determines search result column's visibility.
Go to "settings>application settings>Labels>Settings labels" to set visibility
--->
<cffunction name="showHideColumnsSetting" output="false">

	<cfset OprResults_DisplayCity = 0>
	<cfset OprResults_DisplayState = 0>
	<cfset OprResults_DisplayLocationType = 0>
	<cfset OprResults_DisplayBSAOperatorID = 0>
	<cfset OprResults_DisplayBusinessSegment = 0>
	<cfloop query="OprSearchResultsColumnsDisplayAdditionalSettings">
		<cfif field_name eq "City">
			<cfset OprResults_DisplayCity = 1>
		</cfif>
		<cfif field_name eq "State">
			<cfset OprResults_DisplayState = 1>
		</cfif>
		<cfif field_name eq "Location Type">
			<cfset OprResults_DisplayLocationType = 1>
		</cfif>
		<cfif field_name eq "BSA Operator ID">
			<cfset OprResults_DisplayBSAOperatorID = 1>
		</cfif>
		<cfif field_name eq "Business Segment" AND businessSegEnabledForOperator>
			<cfset OprResults_DisplayBusinessSegment = 1>
		</cfif>
	</cfloop>

</cffunction>