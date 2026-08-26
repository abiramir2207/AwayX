<CFPARAM NAME="SelectSingleSearchResultOnly" default="0">
<cfparam NAME="URL.searchoperator" default="0">
<cfparam NAME="URL.tabSetter" default="1">

<cfmodule template="/customTags/layout.cfm"
              layoutID = "operatorManagement"
              selectedIndex = "#(url.tabSetter eq '1' ? 0 : 1)#" >

<style>
TABLE.Maintable TD
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header
{
	font-size: 12px;
}
A.tablink_back, A:Hover.tablink_back
	{
		color: 				Black;
		font-family:		Arial;
		font-size :			11px;
		font-weight:		bold;
		text-decoration:	none;
	}
A:visited.tablink_back
	{
		color: 				Black;
		font-family:		Arial;
		font-size :			11px;
		font-weight:		bold;
		text-decoration:	none;
	}
A.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px;
		font-weight:		bold;
		text-decoration:	none;
	}
A:visited.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px;
		font-weight:		bold;
		text-decoration:	none;
	}
TD.headernotselected
  {
   background-color 	: dddddd;
   border-bottom		: solid 2px black;
   cursor				: pointer;
  }
 TD.headerselected
  {
   border-left			: solid 2px black;
   border-top			: solid 2px black;
   border-right			: solid 2px black;
   background-color 	: FFE083;

   TEXT-TRANSFORM		: uppercase;
  }

  TD.headerspacer
  {
   border-bottom		: solid 2px black;
  }
</style>




   <cfif Not isDefined("profile")>
  	<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
  </cfif>

  <CFSET PAGE_TITLE="Select Program #application.returned_customer_setting.operator_label_plural#">
  <CFSET GROUP="Contracts">

<!----------------------------------------------------------------------------------------------
    I am checkking this URL.tabSetter value NEQ 2 as 2 will take the user to the Types tab and
    any other value will be taking them to the main tab "Manage"
------------------------------------------------------------------------------------------------>
<cfif URL.tabSetter NEQ 2>

  <CFPARAM name="FORM.button_caption"					default="continue">
  <CFPARAM NAME="FORM.searchstring" 					DEFAULT="">
  <CFPARAM NAME="FORM.SelectedITEMS" 					DEFAULT="">
  <CFPARAM NAME="FORM.FinalItemList" 					DEFAULT="">
  <CFPARAM NAME="FORM.AlreadySelectedItems" 			DEFAULT="">
  <CFPARAM NAME="FORM.finishedselectingitems" 		DEFAULT="0">
  <CFPARAM NAME="FORM.LoadSavedOperators"				Default="1">

  <CFPARAM NAME="FORM.OPERATOR_NAME" 					DEFAULT="">
  <CFPARAM NAME="FORM.OPERATOR_DBA" 					DEFAULT="">
  <CFPARAM NAME="FORM.OPERATOR_CITY" 					DEFAULT="">
  <CFPARAM NAME="FORM.Operator_Type" 					DEFAULT="">
  <CFPARAM NAME="FORM.Operator_Location_Type" 		DEFAULT="">
  <CFPARAM NAME="FORM.Operator_State" 				DEFAULT="">
  <CFPARAM NAME="FORM.Operator_Country_Code" 			DEFAULT="0">
  <cfparam name="FORM.Operator_Number_Of_Locations" 	default="">
  <cfparam name="FORM.Number_Locations_Operation" 	default="">
  <cfparam name="FORM.Customer_Type"					default="">
  <cfparam name="FORM.Operator_Category" 				default="">
  <cfparam name="FORM.Operator_Priority" 				default="">
  <cfparam name="FORM.Market_ID" 						default="">
  <cfparam name="FORM.Position_ID" 					default="">
  <cfparam name="form.LOADPRODUCTSFROMTHESEPROGRAMS" 	default="">
  <cfparam name="Form.legacy_id" 						default="">
  <cfparam name="Form.BSA_Operator_id" 						default="">
  <cfparam name="LegacyIdOn"							default="false">
  <cfparam name="Operator_Active"						default="1">
  <cfparam name="AllReturnedOperators" 				default = "">

  <!---default params for business segments--->
  <CFPARAM name="FORM.Business_Segment_ID" default="0">
  <CFPARAM name="form.businessSegmentsOn" default="0">

  <CFPARAM NAME="StartRow" DEFAULT="1">
  <CFPARAM NAME="frompage" DEFAULT="1">
  <cf_Number_of_Rows maxrows=25>

  <CFSET LegacyIdOn = application.returned_customer_setting.operator_legacy_id_on>
  <CFIF FORM.finishedselectingitems EQ 1>


  <!---Only do this for programs, not from setting panel--->
  </cfif>

  <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
  <cfset appSettings = genSettingsManager.get()>

  <!--- Dev Note: Drachala; D27266: Operator variable labeling START--->
  <cfset LabelComp 			    = Createobject("component", "components.settings.labels.labels").init() />
  <cfset qGetOperatorTypeLabel 	  = LabelComp.getGeneralLabels('Operator Type') />
  <cfset qGetLocationTypeLabel 	= LabelComp.getGeneralLabels('Location Type') />
  <cfset qGetOperatorCategoryLabel 	= LabelComp.getGeneralLabels('Operator Category') />
  <cfset qGetOperatorPriorityLabel 	= LabelComp.getGeneralLabels('Operator Priority') />
  <!--- Dev Note: Drachala; D27266: Operator variable labeling END--->

<!---72360 :: Add customer label for BSA ID START --->
<cfset CustomerSettingsLabels = createObject("component", "mvc.Models.SettingsService").getCustomerSettingsLabels() />
<!---72360 :: Add customer label for BSA ID END --->

  	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
  	<SCRIPT>

  		function createOperator()
  		{
  			NewWindow("/profiles/operators/Operator_Creation_Entry_Form_Stripped.cfm?<cfoutput>FinalItemList=#FinalItemList#</cfoutput>&Source=Management","CreateOperator",660,700,"yes","yes");
  			return false;
  		}

  		function editOperator(BSA_Operator_ID)
  		{
  			NewWindow("/profiles/operators/operator_creation_entry_form_stripped.cfm?OID=" + BSA_Operator_ID + "&Action=Edit&Source=Management","EditOperator",660,700,"yes","yes");
  			return false;
  		}

  		function doSearch()
  		{

  			document.all.startrow.value = 1;
  			document.all.frompage.value = 1;
  			restricted_Operator_Search();

  			return false;
  		}
  	function restricted_Operator_Search()
  	{
  		var searchForm = document.MyForm;
  		searchForm.startrow.value = 1;
  		searchForm.frompage.value = 1;
  		//searchForm.submit();
  		check_Filters(searchForm);
  	}
  	function isDefined(item) {
      	return (typeof item != 'undefined');
  	}
  	function check_Filters(searchForm)
  	{
  		if(document.all.LoadProductsFromThesePrograms.value.length != 0) {
  			searchForm.submit();
  			return;
  		}

  		var any_Filter = false;
  		var availOptions = "";
  		if(searchForm.Operator_Type.value.toUpperCase() != "ALL")
  		{
  			any_Filter = true;
  		}
  		availOptions = availOptions + "\n - Type of <CFOUTPUT>#application.returned_customer_setting.operator_label_singular#</CFOUTPUT>";
  		if(searchForm.Operator_Location_Type.value.toUpperCase() != "ALL")
  		{
  			any_Filter = true;
  		}
  		availOptions = availOptions + "\n - Location Type";
  		if(searchForm.Operator_State.value.toUpperCase() != "ALL")
  		{
  			any_Filter = true;

  		}
  		availOptions = availOptions + "\n - Country";
  		if(isDefined(searchForm.Operator_Country_Code) && searchForm.Operator_Country_Code.value != "0")
  		{
  			any_Filter = true;

  		}
  		availOptions = availOptions + "\n - State";
  		<cfif LegacyIdOn>
  		if(searchForm.legacy_id.value != "")
  		{
  			any_Filter = true;
  		}
  		availOptions = availOptions + "\n - Legacy Id";</cfif>

  		if(searchForm.BSA_Operator_id.value != "")
  		{
  			any_Filter = true;
  		}
  		availOptions = availOptions + "\n - BSA Operator Id";

  		<cfif application.operatorVariableAvailable>
  		if(searchForm.Market_ID.value != "")
  		{
  			any_Filter = true;
  		}
  		availOptions = availOptions + "\n - Market";
  		if(searchForm.Position_ID.value != "")
  		{
  			any_Filter = true;
  		}
  		availOptions = availOptions + "\n - Position";

  		if(searchForm.Operator_Category.value.toUpperCase() != "ALL")
  		{
  			any_Filter = true;
  		}
  		availOptions = availOptions + "\n - Category";
  		if(searchForm.Operator_Priority.value.toUpperCase() != "ALL")
  		{
  			any_Filter = true;
  		}
  		availOptions = availOptions + "\n - Priority";

  		</cfif>
		//bypass the confirm message
		any_Filter = true;
  		if(any_Filter)
  		{
  			searchForm.submit();
  		}
  		else
  		{

  			if(window.confirm("Your search may take some time as you have not selected any of the following filters. Do you want to continue?" + availOptions))
  			{
  				searchForm.submit();
  			}

  		}
  	}

  	function verifySave(){
  		document.all.finishedselectingitems.value = 1;
  		MyForm.submit();
  	}

  	</SCRIPT>

  <SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
  <style>
  TABLE.Maintable TD
  {
  	border-bottom:solid #93BEE2 1px; font-size : 10px;
  }
  #header
  {
  	font-size: 12px;
  }
  A.tablink_back, A:Hover.tablink_back
  	{
  		color: 				Black;
  		font-family:		Arial;
  		font-size :			11px;
  		font-weight:		bold;
  		text-decoration:	none;
  	}
  A:visited.tablink_back
  	{
  		color: 				Black;
  		font-family:		Arial;
  		font-size :			11px;
  		font-weight:		bold;
  		text-decoration:	none;
  	}
  A.tablink_fore
  	{
  		color: 				Red;
  		font-family:		Arial;
  		font-size :			11px;
  		font-weight:		bold;
  		text-decoration:	none;
  	}
  A:visited.tablink_fore
  	{
  		color: 				Red;
  		font-family:		Arial;
  		font-size :			11px;
  		font-weight:		bold;
  		text-decoration:	none;
  	}
  TD.headernotselected
    {
     background-color 	: dddddd;
     border-bottom		: solid 2px black;
     cursor				: pointer;
    }
   TD.headerselected
    {
     border-left			: solid 2px black;
     border-top			: solid 2px black;
     border-right			: solid 2px black;
     background-color 	: FFE083;

     TEXT-TRANSFORM		: uppercase;
    }

    TD.headerspacer
    {
     border-bottom		: solid 2px black;
    }
  </style>

<!---   <TABLE border="0" cellspacing="0" cellpadding="1" WIDTH="100%">
  	<TR>
  	 	<TD CLASS="headerspacer">&nbsp;</TD>

  			<TD WIDTH="120" CLASS="headerselected" ALIGN="center" NOWRAP>
  			<B>
  			Manage<!--- <A CLASS="tablink_back" HREF="select_operators.cfm?tabSetter"></A> onClick="JavaScript: return submitDataForm('active');"  Manage</A> --->
  			</B>
  			</TD>
  			</B>
  			</TD>
        <!---D20285 Types tab in Operator Management -Anand Rao, 31-Aug-09  --->
  			<cfif url.searchoperator NEQ 1><!--- if it is equal to 1 then it is a popup and from the home page --->
        <TD CLASS="headerspacer"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
  			<TD WIDTH="120" CLASS="headernotselected" ALIGN="center" NOWRAP>
  			<B>
  			<A CLASS="tablink_back" HREF="select_operators.cfm?tabSetter=2"><!--- onClick="JavaScript: return submitDataForm('inActive');"> --->Types</A>
  			</B>
  			</TD>
  			</B>
        </cfif>
  			</TD>
  			<TD CLASS="headerspacer"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
  		<TD CLASS="headerspacer" WIDTH="100%"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
  		<td CLASS="headerspacer" nowrap>&nbsp;

  		</td>
  	</TR>
  </TABLE>
  <cfif url.searchoperator EQ 0>
  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
  <CFINCLUDE TEMPLATE="/includes/header.cfm">
  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
  </cfif>
 --->

<br>
  <Font size="+2" color="Navy"><cfif url.searchoperator EQ 0>Manage<cfelse>Search</cfif> <Cfoutput>#application.returned_customer_setting.operator_label_plural#</CFOUTPUT></FONT>
  <hr width="100%" color="navy">


  <SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
   <SCRIPT LANGUAGE="JavaScript" SRC="/script/javascript/string_functions.js"> </script>
   <SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>

  <!---Allow import all or not--->
  <CFPARAM NAME="FORM.AllowImportAll"	Default="#NOT SelectSingleSearchResultOnly#">


  	<!--- <CFSET URL.Contract_Main_ID = FORM.Contract_Main_ID> --->
  	<!--- <CFINCLUDE TEMPLATE="thin_contract_general_display.cfm"> --->

  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
  <!--- This is help file that goes with this content													 --->
  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
  <SCRIPT language="JavaScript">
  function reset_Form_Fields()
  	{
  		resetSelect("Operator_Type");
  		resetSelect("Operator_Location_Type");
  		resetSelect("Operator_State");
  		resetSelect("Operator_Country_Code");
  		resetSelect("Number_Locations_Operation");
  		resetSelect("Operator_Category");
  		resetSelect("Operator_Priority");
  		resetSelect("Market_ID");
  		resetSelect("Position_ID");
  		resetSelect("Operator_Active");
  		//resetSelect("sort_by");
  		//resetSelect("sort_Order");
  		document.all.Operator_Number_Of_Locations.value = "";
  		document.all.Operator_Name.value = "";
  		document.all.Operator_DBA.value = "";
  		document.all.Operator_City.value = "";
  		//document.all.Operator_Active = 0;
  		<cfif LegacyIdOn>
  		document.all.legacy_id.value = "";</cfif>
  		document.all.BSA_Operator_id.value = "";
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

  	function deleteThisFixedPrice(FieldNameRe, prodID)
  	{
  		var trObj = document.getElementById("TR_" + FieldNameRe);
  		var trIndex = trObj.rowIndex;
  		var FINALITEMLIST = document.MyForm.FinalItemList.value;
  		var resultString = ListDeleteItem(FINALITEMLIST, ",", prodID);
  		var bDelete = true;

  		if(resultString == FINALITEMLIST)
  		{
  			resultString = ListAppendItem(FINALITEMLIST, ",", prodID);
  			bDelete = false;
  		}

  		document.MyForm.FinalItemList.value = resultString;

  		if(trObj)
  		{
  			var srcObj = event.srcElement;
  			if(bDelete)
  			{
  				propogateProperty(trObj, "style.backgroundColor", "#CCCCCC", false);
  				propogateProperty(trObj, "style.textDecoration", "line-through", true);

  				srcObj.title = "undo operator deletion";
  				srcObj.src = undodeleteImg.src;
  			}
  			else
  			{
  				var bgCol = "#eeeeee";

  				propogateProperty(trObj, "style.backgroundColor", bgCol, false);
  				propogateProperty(trObj, "style.textDecoration", "none", false);

  				srcObj.title = "delete this operator";
  				srcObj.src = deleteImg.src;
  			}
  		}
  		event.cancelBubble = true;
  	}

  	function searchPrograms() {
  		searchResults = window.showModalDialog('/common_files/contracts/program_search_for_component.cfm','','dialogHeight: 600px; dialogWidth: 940px; dialogTop: px; dialogLeft: px; edge: Raised; center: Yes; help: No; resizable: No; status: No;');
  		if(searchResults != 0 && searchResults.length != 0) {
  			document.all.LoadProductsFromThesePrograms.value = searchResults;
  			doSearch();
  		}
  	}
  </SCRIPT>

<FORM ACTION="index.cfm?searchoperator=<cfoutput>#url.searchoperator#</cfoutput>" METHOD="post" NAME="MyForm" ID="MyForm" STYLE="DISPLAY:INLINE">
  	<FIELDSET STYLE=" border: 1px solid Blue; display:table;width:98%;">
  	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> search</LEGEND>

  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
  <!--- Get the list of Operator_Location_Type														 --->
  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
  <CFQUERY NAME="Get_Operator_Location_Type" datasource="#application.datasource#">
	  Select	distinct Operator_Location_Type
	  From	awayX_Operator_Location_Type
	  where 0=0
	  <cfif form.businessSegmentsOn eq 1 and isDefined("BUSINESS_SEGMENT_ID") and application.returned_customer_setting.customer_keyword IS "conagra">
	   and Business_segment_id = #FORM.BUSINESS_SEGMENT_ID#
	  </cfif>
  </CFQUERY>
  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
  <!--- Get the list of Operator_Type																	 --->
  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
  <!-------------------------------------------------------------------------------
    Dev Notes: D19761 -Anand Rao 07/28/09
    Changed to query to have a where clause to look for active = 1 and Deleted = 0
  --------------------------------------------------------------------------------->
  <CFQUERY NAME="Get_Operator_Type" datasource="#application.datasource#">
	  SELECT	Distinct Operator_Type
	  FROM awayX_Operator_Type
	  WHERE Active = 1 AND Deleted = 0
	  <cfif form.businessSegmentsOn eq 1 and isDefined("BUSINESS_SEGMENT_ID") and application.returned_customer_setting.customer_keyword IS "conagra">
	   AND Business_segment_id = #FORM.BUSINESS_SEGMENT_ID#
	  </cfif>
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

  <!--- Development Note: KAL - Modified below query for punch code D6988 --->
  <cfquery name="Get_States" datasource="#application.datasource#">
  	SELECT DISTINCT Operator_State as State_Code, State_Name, Country_Sort_Order
  	FROM BSA_Operator o
  	join _States s on s.State_Code = o.Operator_State
  	join _Country c on s.Country_ID = c.Country_ID
  	WHERE	LEN(State_Code) > 0
  	ORDER BY Country_Sort_Order, State_Name
  </cfquery>

  <!---Get Customer types if they're there--->


  <STYLE>
  	.LONGINPUT, select, input
  	{
  		width: 96%;
      margin-top: 3px;
  	}
    #commands43 a { margin-right: 15px; }
  </STYLE>

  <TABLE width="100%" border="0" cellspacing="9">
  <TR>
  	<TD>
  		<B><CFOUTPUT>#application.returned_customer_setting.operator_label_singular#</CFOUTPUT> Name:</B><BR>
  		<INPUT CLASS="LONGINPUT" TYPE="text" NAME="Operator_Name" STYLE="font-size: 10px;" VALUE="<CFOUTPUT>#FORM.Operator_Name#</CFOUTPUT>">
  	</TD>
  	<TD>
  		<B>Doing business as:</B><BR>
  		<INPUT CLASS="LONGINPUT" TYPE="Text" NAME="Operator_DBA" MAXLENGTH="510" STYLE="font-size: 10px;" VALUE="<CFOUTPUT>#FORM.Operator_DBA#</CFOUTPUT>">
  	</TD>
  	<TD>
  		<B>City:</B><BR>
  		<INPUT CLASS="LONGINPUT" TYPE="Text" NAME="Operator_City" MAXLENGTH="510" STYLE="font-size: 10px;" VALUE="<CFOUTPUT>#FORM.Operator_City#</CFOUTPUT>">
  	</TD>
  	<TD>
  		<B>State:</B><BR>
  		<SELECT NAME="Operator_State" ID="Operator_State" STYLE="font-size: 10px;">
  		<OPTION VALUE="All" SELECTED>Select State</OPTION>
  		<OPTION VALUE="All">Any State</OPTION>
  		<CFOUTPUT QUERY="Get_States"><OPTION VALUE="#State_Code#" <CFIF FORM.Operator_State EQ Get_States.State_Code>selected</CFIF>>#State_Name#</OPTION></CFOUTPUT>
  		</SELECT>
  	</TD>
  </TR>
  <TR>
  	<TD>
  		<B><cfoutput>#qGetLocationTypeLabel.GENERAL_LABELS_LABEL#</cfoutput></B><BR>
  		<SELECT NAME="Operator_Location_Type" ID="Operator_Location_Type" STYLE="font-size: 10px;">
  		<OPTION VALUE="All" SELECTED>Select <cfoutput>#qGetLocationTypeLabel.GENERAL_LABELS_LABEL#</cfoutput></OPTION>
  		<OPTION VALUE="All">All <cfoutput>#qGetLocationTypeLabel.GENERAL_LABELS_LABEL#</cfoutput></OPTION>
  		<CFOUTPUT QUERY="Get_Operator_Location_Type"><OPTION VALUE="#Operator_Location_Type#" <CFIF FORM.Operator_Location_Type EQ Get_Operator_Location_Type.Operator_Location_Type>selected</CFIF>>#Operator_Location_Type#</OPTION></CFOUTPUT>
  		</SELECT>
  	</TD>
  	<TD>
  		<B><CFOUTPUT>#qGetOperatorTypeLabel.GENERAL_LABELS_LABEL#</CFOUTPUT>:</B><BR>
  		<SELECT NAME="Operator_Type" ID="Operator_Type" STYLE="font-size: 10px;">
  		<OPTION VALUE="All" SELECTED>Select <CFOUTPUT>#qGetOperatorTypeLabel.GENERAL_LABELS_LABEL#</CFOUTPUT></OPTION>
  		<OPTION VALUE="All">All <cfoutput>#qGetOperatorTypeLabel.GENERAL_LABELS_LABEL#</cfoutput></OPTION>
  		<CFOUTPUT QUERY="Get_Operator_Type"><OPTION VALUE="#Operator_Type#" <CFIF FORM.Operator_Type EQ Get_Operator_Type.Operator_Type>selected</CFIF>>#Operator_Type#</OPTION></CFOUTPUT>
  		</SELECT>
  	</TD>
  	<cfif application.operatorVariableAvailable>
  	<TD>
  		<B><cfoutput>#qGetOperatorCategoryLabel.GENERAL_LABELS_LABEL#</cfoutput>:</B><BR>
  		<SELECT NAME="Operator_Category" ID="Operator_Category" STYLE="font-size: 10px;">
  		<OPTION VALUE="All" SELECTED>Select <cfoutput>#qGetOperatorCategoryLabel.GENERAL_LABELS_LABEL#</cfoutput></OPTION>
  		<OPTION VALUE="All">All <cfoutput>#qGetOperatorCategoryLabel.GENERAL_LABELS_LABEL#</cfoutput></OPTION>
  		<CFOUTPUT QUERY="Get_Operator_Category"><OPTION VALUE="#Operator_Category_ID#" <CFIF FORM.Operator_Category EQ Operator_Category_ID>selected</CFIF>>#Category_Label#</OPTION></CFOUTPUT>
  		</SELECT>
  	</TD>
  	<TD>
  		<B><cfoutput>#qGetOperatorPriorityLabel.GENERAL_LABELS_LABEL#</cfoutput>:</B><BR>
  		<SELECT NAME="Operator_Priority" ID="Operator_Priority" STYLE="font-size: 10px;">
  		<OPTION VALUE="All" SELECTED>Select <cfoutput>#qGetOperatorPriorityLabel.GENERAL_LABELS_LABEL#</cfoutput></OPTION>
  		<OPTION VALUE="All">All <cfoutput>#qGetOperatorPriorityLabel.GENERAL_LABELS_LABEL#</cfoutput></OPTION>
  		<CFOUTPUT QUERY="Get_Operator_Priority"><OPTION VALUE="#Operator_Priority_ID#" <CFIF FORM.Operator_Priority EQ Operator_Priority_ID>selected</CFIF>>#Priority_Label#</OPTION></CFOUTPUT>
  		</SELECT>
  	</TD>

  </TR>
  <TR>
  	</cfif>

  	<TD>
  		<B># Locations:</B><BR>
  		<CFSET OperationList = " ,>=,<=,=">
  		<SELECT NAME="Number_Locations_Operation" ID="Number_Locations_Operation" STYLE="width:25%;font-size: 10px;">
  		<CFOUTPUT>
  		<CFLOOP list="#OperationList#" delimiters="," index="ThisItem">
  			<cfset ThisItem = Trim(ThisItem)>
  			<OPTION VALUE="#ThisItem#"<CFIF FORM.Number_Locations_Operation EQ ThisItem> SELECTED</CFIF>>#ThisItem#</OPTION>
  		</CFLOOP>
  		</CFOUTPUT>
  		</SELECT>
  		<INPUT onKeyUp="clenseText(this, '0123456789');" TYPE="Text" NAME="Operator_Number_Of_Locations" MAXLENGTH="8" STYLE="width:70%" VALUE="<CFOUTPUT>#Replace(FORM.Operator_Number_Of_Locations,'-','','ALL')#</CFOUTPUT>">
  	</TD>

  	<cfif application.operatorVariableAvailable>
  	<TD NOWRAP ALIGN="left">
  		<B><CFOUTPUT>#application.returned_customer_setting.market_label_singular#</CFOUTPUT>:</B><BR>
  		<CFQUERY NAME="GetMarkets" datasource="#application.datasource#">
  		SELECT Market_Name, Service_Market_ID
  		FROM Service_Markets
  		WHERE len(Market_Name) > 0 AND Deleted = 0
  		ORDER BY Market_Name
  		</CFQUERY>
  		<SELECT NAME="Market_ID" ID="Market_ID">
  			<OPTION VALUE="">**ALL** <CFOUTPUT>#application.returned_customer_setting.market_label_plural#</CFOUTPUT></OPTION>
  			<CFOUTPUT QUERY="GetMarkets"><OPTION VALUE="#trim(Service_Market_ID)#"#IIF(trim(FORM.Market_ID) EQ Service_Market_ID, DE(" SELECTED"), DE(""))#>#trim(Market_Name)#</OPTION></CFOUTPUT>
  		</SELECT>
  	</TD>
  	<TD NOWRAP ALIGN="left">
  		<B>Position:</B><BR>
  		<CFQUERY NAME="GetPositions" datasource="#application.datasource#">
  		SELECT User_positions_ID, Position_Label
  		FROM User_positions
  		WHERE len(Position_Label) > 0 AND Deleted = 0
  		ORDER BY Position_Label
  		</CFQUERY>
  		<SELECT NAME="Position_ID" ID="Position_ID">
  			<OPTION VALUE="">**ALL** <CFOUTPUT>Positions</CFOUTPUT></OPTION>
  			<CFOUTPUT QUERY="GetPositions"><OPTION VALUE="#trim(User_positions_ID)#"#IIF(trim(FORM.Position_ID) EQ User_positions_ID, DE(" SELECTED"), DE(""))#>#trim(Position_Label)#</OPTION></CFOUTPUT>
  		</SELECT>
  	</TD>
  	  <TD NOWRAP ALIGN="left">
  						<CFPARAM NAME="Form.Operator_Country_Code" DEFAULT="0">
  						<!--- Country code --->
  						<CFQUERY NAME="getCountry" datasource="#application.datasource#">
  							SELECT distinct c.country_code, country_name, Country_id
  							FROM BSA_Operator o
  							Join  _Country c on o.operator_country_code = c.country_code
  							where active = 1
  							ORDER BY Country_id ASC
  						</CFQUERY>
  						<strong>Country:</strong><BR>
  						<CFOUTPUT>
  								<SELECT NAME="Operator_Country_Code" ID="Operator_Country_Code" STYLE="WIDTH:175px">
  								  <OPTION SELECTED value="0">**ALL** Countries</OPTION>
  								    <CFLOOP QUERY="getCountry">
  										<OPTION VALUE="#getCountry.Country_Code#" #IIF(trim(FORM.Operator_Country_Code) EQ trim(GetCountry.country_code), DE(" SELECTED"), DE(""))#>#getCountry.Country_Name#</OPTION>
  									</CFLOOP>
  							     </SELECT>
  							</CFOUTPUT>

  	  </TD>
  	</cfif>
  	</TR>
  	<TR>
  	<!---Initialize the appliation settings--->
  <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
  <cfset appSettings = genSettingsManager.get()>
  <cfset UseCustomerType = appSettings.getCustomertype()>
  <cfset Get_CustType_Profile_Settings = profile.getCusttypeProfileSettings(request.AccessStructure.Profiles_ID, 'O')>

  	<!---Only do this if we're using customer types--->
  	<cfif UseCustomerType IS 1>

  	<TD NOWRAP ALIGN="left"><strong>Customer Type:</strong><Br>
  		<!--- <cfdump var="#Get_CustType_Profile_Settings#"> --->
  		<SELECT NAME="Customer_Type" ID="Customer_Type">
  			<option value="">**ALL TYPES**</option>
  			<cfoutput query="Get_CustType_Profile_Settings">
  				<cfif Get_CustType_Profile_Settings.PROFILE_CUSTOMER_TYPE_VALUE IS 1><option value="#Customer_Type#" <cfif Form.Customer_Type IS Customer_Type>selected</cfif>>#Customer_Type_Desc#</option></cfif>
  			</cfoutput>
  		</SELECT>
  	</td>
  	</cfif>

  	<cfif LegacyIdOn>
      <TD valign="top"><strong><cfoutput>#application.returned_customer_setting.Operator_Legacy_Id_label#</cfoutput>:</strong><BR><!--- <br> --->
  		<input type="Text" name="legacy_id" maxlength="510" value="<CFOUTPUT>#FORM.legacy_id#</CFOUTPUT>">
      </TD>
  	</cfif>
  	 <!---D39828  :: Added BSA Operator id to Operator search and Results.... --->
 	<cfif appSettings.getShowBSAOperators() EQ 1>
  	<TD valign="top">
  	    <strong><CFOUTPUT>#CustomerSettingsLabels.BSA_ID_label#</CFOUTPUT></strong><BR><!--- <br> --->
  		<input type="Text" name="BSA_Operator_id" maxlength="50" style="width:80px;font-size: 10px;" value="<CFOUTPUT>#FORM.BSA_Operator_id#</CFOUTPUT>">
  	</TD>
	<cfelse>
		<input type="hidden" name="BSA_Operator_id"  value="">
	 </cfif>
	 <!---D39828  :: Added BSA Operator id to Operator search and Results.... --->
  	<TD valign="top"><strong>Active Status</strong><br>
  		<select name="Operator_Active" ID="Operator_Active">
  			<!--- <option value="" <cfif Operator_Active IS "">selected</cfif>>All</option> --->
  			<option value="1" <cfif Operator_Active IS "1">selected</cfif>>Active only</option>
  			<option value="0" <cfif Operator_Active IS "0">selected</cfif>>Inactive only<option>
  		</select>

  	</TD>
  	</TR>
  	<TR>
  		<TD ALIGN="center" colspan="4">
  		<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10"><BR>
  		&nbsp;&nbsp;
  		<B><FONT COLOR="#FF0000">[</FONT> <a HREF="#" ONCLICK="document.all.LoadProductsFromThesePrograms.value = ''; return doSearch();">search <cfoutput>#lcase(application.returned_customer_setting.operator_label_plural)#</cfoutput></a><FONT COLOR="#FF0000"> ]</FONT></B>

  		<FONT COLOR="ff0000" > &nbsp; &nbsp; <B>[ </B></FONT>
  			<A HREF="javascript: reset_Form_Fields();"><B>reset</B></A>
  		<FONT COLOR="ff0000" ><B> ]</B></FONT>
  		<!---Show create if the business segment is dry or refridgerated, but business segments need to be on first--->

  	<cfif url.searchoperator EQ 0>
  		<cfparam name="ShowCreateOperator" default="1">
  		<cfif Get_Profile_Settings.Create_Operator_Access NEQ 1>
  			<cfset ShowCreateOperator = 0 />
  		</cfif>

  		<cfif ShowCreateOperator IS 1>
  		<B> &nbsp; &nbsp; <font COLOR="Red">[ </font><A ONCLICK="createOperator()" STYLE="cursor: pointer;">create <cfoutput>#lcase(application.returned_customer_setting.operator_label_singular)#</cfoutput></A><font COLOR="Red"> ]</font></B>
  		</cfif></cfif>
  		<!------ <BR>&nbsp;&nbsp;&nbsp;<B><FONT COLOR="##FF0000">[</FONT><a style="cursor: pointer;" onclick="searchPrograms()">get <cfoutput>#lcase(application.returned_customer_setting.operator_label_plural)#</cfoutput> by program</a><FONT COLOR="##FF0000">]</FONT></B> ----->
  	</TD>
  	</TR>
  	<cfif form.businessSegmentsOn eq 1>
      <TR>
        <td colspan="2"><cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput>:&nbsp;&nbsp;<b><cfoutput>#Bus_Segment_Desc#</cfoutput></b></td>
      </TR>
    </cfif>
  </TABLE>

  <!--- <TABLE WIDTH="100%" BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="center">
  	<TR>
  		<TD ALIGN="right">
  		<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10"><BR>
  		<cfif application.returned_customer_setting.Customer_Keyword NEQ "conagra" OR NOT LegacyIdOn>
  		<B><font COLOR="Red">[</font><A ONCLICK="createOperator()" STYLE="cursor: pointer;">create <cfoutput>#lcase(application.returned_customer_setting.operator_label_singular)#</cfoutput></A><font COLOR="Red">]</font></B></TD>
  		</cfif>
  	</TR>
  </TABLE>
   ---->


  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ---><!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


  		<CFPARAM NAME="FORM.sort_by" DEFAULT="Operator_Name">
  		<CFPARAM NAME="FORM.sort_Order" DEFAULT="ASC">
  		<cfoutput>
   		<INPUT type="Hidden" value="#FORM.sort_by#" NAME="sort_by">
  		<INPUT type="Hidden" value="#FORM.sort_Order#" NAME="sort_Order">
  		</cfoutput>
  		<INPUT TYPE="Hidden" NAME="DoSearch" VALUE="1">
  		<!---By default you only update selected values--->
  		<input type="Hidden" name="Selected" value="1">
  		<!---By default you activate the items--->
  		<input type="hidden" name="Delete_This" value="0">


  	</FIELDSET>

  <!---Active/inactive javascript--->
  <cfif url.searchoperator EQ 0>
  <SCRIPT>
  function changeSelected(Delete)
  	{
  		document.MyForm.action = 'select_operators_update.cfm';
  		document.MyForm.Selected.value = 1;
  		if(Delete == 1)
  		{
  			document.MyForm.Delete_This.value = 1;
  		}
  		else
  		{
  			document.MyForm.Delete_This.value = 0;
  		}
  		document.MyForm.submit();
  		return false;
  	}

  	function changeAll(Delete)
  	{
  		document.MyForm.action = 'select_operators_update.cfm';
  		document.MyForm.Selected.value = 0;
  		if(Delete == 1)
  		{
  			document.MyForm.Delete_This.value= 1;
  		}
  		else
  		{
  			document.MyForm.Selected.value = 0;
  		}
  		document.MyForm.submit();
  		return false;
  	}
  </SCRIPT>
  </cfif>

  <BR><BR>
  <CFIF isdefined("FORM.DoSearch") AND FORM.DoSearch IS 1>


  	<CFSET form.searchstring = trim(form.searchstring)>

  	<cfif listlen(trim(form.LoadProductsFromThesePrograms)) GT 0>
  		<cfset FORM.Position_ID = "">
  		<cfset FORM.Market_ID 	= "">
  		<cfset Operator_State = "All">
  		<cfset Operator_Country_Code = "0">
  		<cfset Operator_Type = "All">
  		<cfset Operator_Location_Type = "All">
  		<cfset Operator_Name = "">
  		<cfset Operator_City = "">
  		<cfset Operator_DBA = "">
  		<cfset FORM.Operator_Number_Of_Locations = "">
  		<cfset Operator_Category = "">
  		<cfset Operator_Priority = "">
  	</cfif>


  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ---><!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->




  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
  <!--- Retrieve operators																			 --->
  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

  <!--------------------------------------------------------------------
  Add Sort By
  ---------------------------------------------------------------------->



  <CFSET sql_Sort_By="Operator_Name">
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
  	<CFCASE value="Number of Locations">
  		<CFSET sql_Sort_By="Operator_Number_Of_Locations">
  	</CFCASE>
  	<CFCASE value="Doing Business As">
  		<CFSET sql_Sort_By="Operator_DBA">
  	</CFCASE>
  	<CFCASE value="Legacy Id">
  		<CFSET sql_Sort_By="legacy_id">
  	</CFCASE>
 <!---  D39828  :: Added BSA Operator id to Operator search and Results....  START--->
   	<CFCASE value="BSA Operator ID">
  		<CFSET sql_Sort_By="BSA_Operator_ID">
  	</CFCASE>
 <!---  D39828  :: Added BSA Operator id to Operator search and Results.... END --->
  </CFSWITCH>

  <CFSET sql_Sort_By_Order=" ASC">
  <CFIF Form.sort_Order EQ "DESC">
  	<CFSET sql_Sort_By_Order=" DESC">
  </CFIF>

  <!--------------------------------------------------------------------
  Add Sort By
  ---------------------------------------------------------------------->

  <CFQUERY NAME="TheQuery" datasource="#application.datasource#">


  	Select	distinct *

  From		BSA_Operator
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
  Where		0 = 0
  			<cfif FORM.Operator_Active EQ 1>
  				AND BSA_Operator.Deleted = 0
				AND BSA_Operator.Display_Code = 'A'
  			</cfif>
  			<cfif FORM.Operator_Active EQ 0>
  			<!--- We are not using deleted = 1, because we need to show deleted operators in the billback section --->
  				-- AND BSA_Operator.display_code = 'N'
  				AND (BSA_Operator.Deleted = 1 OR BSA_Operator.Display_Code = 'N')
  			</cfif>
  			<CFIF Operator_State NEQ "All">
  				and
  				Operator_State	=	'#Operator_State#'
  			</CFIF>
  			<CFIF Operator_Country_Code NEQ "0">
  				and
  				Operator_Country_Code	=	'#Operator_Country_Code#'
  			</CFIF>

  			<CFIF Operator_Type NEQ "All">
  				and
  				Operator_Type	=	'#Operator_Type#'
  			</CFIF>

  			<CFIF Operator_Location_Type NEQ "All">
  				and
  				Operator_Location_Type	=	'#Operator_Location_Type#'
  			</CFIF>

  			<CFIF trim(Operator_Name) NEQ "">
  				and
  				Operator_Name 	like 	'%#Operator_Name#%'
  			</CFIF>

  			<CFIF trim(Operator_City) NEQ "">
  				and
  				Operator_City 	like 	'%#Operator_City#%'
  			</CFIF>

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
  				BSA_Operator_ID	 =	<cfif isnumeric(form.BSA_Operator_ID)><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.BSA_Operator_ID#"><cfelse>''</cfif>
  			</CFIF>

  			<CFIF trim(FORM.Operator_Number_Of_Locations) NEQ "" AND isNumeric(Replace(FORM.Operator_Number_Of_Locations,"-","","ALL")) AND FORM.Number_Locations_Operation NEQ "">
  				and
  				CAST(Replace(Operator_Number_Of_Locations,'-','') AS BIGINT) #FORM.Number_Locations_Operation# #Replace(FORM.Operator_Number_Of_Locations,"-","","ALL")#
  			</CFIF>

  			<cfif not appSettings.getShowBSAOperators()>
  				AND (Legacy_ID IS NOT NULL OR Len(Legacy_ID) != 0)
  			</cfif>

  			<CFIF Operator_Category NEQ "All" AND Operator_Category NEQ "">
  				and
  				Operator_Category_ID	=	#Operator_Category#
  			</CFIF>

  			<CFIF Operator_Priority NEQ "All" AND Operator_Priority NEQ "">
  				and
  				Operator_Priority_ID	=	#Operator_Priority#
  			</CFIF>

  			<!---Limits to customer types--->
  			<cfif UseCustomerType IS 1>
  				<cfif len(trim(Customer_Type)) IS NOT 0>
  				AND #Customer_Type# = 1
  				</cfif>

  			</cfif>




  --ORDER BY 	Operator_Name
  ORDER BY #sql_Sort_By# #sql_Sort_By_Order#

  </CFQUERY>

  <SCRIPT>
  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
  		function CA() {
  			if(<CFIF TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> in the list below while selecting them all. Press OK if you wish to continue")<CFELSE>0==0</CFIF>) {
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
  		function setThisSortItem(sortVal, sortOrder)
  		{
  			event.returnValue = false;
  			//document.MyForm.reset();
  			/*
  			var SelObj = document.all.sort_by;
  			var next_Index = Get_Select_Index(SelObj, sortVal);
  			if(next_Index >=0)
  			{
  				SelObj.selectedIndex = next_Index;
  				SelObj = document.all.sort_Order;
  				SelObj.selectedIndex = Get_Select_Index(SelObj, sortOrder);
  				document.MyForm.submit();
  			} */
  			var OprForm = document.MyForm;
  			OprForm.sort_by.value = sortVal;
  			OprForm.sort_Order.value = sortOrder;
  			OprForm.submit();
  		}
  </SCRIPT>
  <SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
  <cfif url.searchoperator EQ 0>

  <cfset enableActivateAllReturedForMaxCount = 50 />
  <cfset enableActivateAllRetured = 1 />
  <cfset activateAllExtraMessage = " onClick=""javascript: return changeAll('0');""" />
  <cfif TheQuery.recordCount GT enableActivateAllReturedForMaxCount>
  	<cfset enableActivateAllRetured = 0 />
  	<cfset activateAllExtraMessage = " title=""This option is not avaiable if the number of records returned is more than #enableActivateAllReturedForMaxCount#""" />
  </cfif>

<cfoutput>
<div id="commands43">
  <a href="##" onclick="javascript:return changeSelected('1');">#application.util.string.actionLinkFormat2("deactivate selected")#</a>
  <a href="##" onclick="javascript:return changeSelected('0');">#application.util.string.actionLinkFormat2("activate selected")#</a>
  <a href="##" onclick="javascript:return changeAll('1');">#application.util.string.actionLinkFormat2("deactivate all returned")#</a>
  <a href="##" #activateAllExtraMessage#>#application.util.string.actionLinkFormat2("activate all returned")#</a>
</div>
</cfoutput>
  <cfif enableActivateAllRetured>
  	<cfset AllReturnedOperators = "">
  </cfif>

  </cfif>


  <FIELDSET STYLE="padding:8px; width:100%; border: 1px solid Blue;margin-top:10px;">
  	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF TheQuery.recordcount EQ 1>is<CFELSE>are</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1><cfoutput>#lcase(application.returned_customer_setting.operator_label_singular)#</cfoutput><CFELSE><cfoutput>#lcase(application.returned_customer_setting.operator_label_plural)#</cfoutput></CFIF> that <CFIF TheQuery.recordcount EQ 1>matched<CFELSE>match</CFIF> the above criteria</LEGEND>
  		<CFSET FORM.AlreadySelectedItems = "">

  <CFIF TheQuery.recordcount GT 0>

  	<!---
  			 <CFIF TheQuery.recordcount GTE 500>
  				<FONT SIZE="+1"><B>Your query returned more than 500 records. Please narrow your search.</B></FONT>
  			<CFELSE>
  	---><!---Location<BR>Type--->
  				<TABLE border="0" cellspacing="0" cellpadding="2" align="center" CLASS="Maintable" width="100%">
  					<TR ID="header" BGCOLOR="#ffce84" VALIGN="top">

  						<cfif searchoperator EQ 0><TD align="center">
  						<CFIF SelectSingleSearchResultOnly EQ 0>
  						<INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all #application.returned_customer_setting.operator_label_plural#"><cfelse>&nbsp;</cfif></TD></cfif>
  						<CFSET Header_Display_List = "#application.returned_customer_setting.operator_label_singular#">
  						<CFSET Header_Value_List = "Operator Name">
  						<cfif LegacyIdOn>
  							<CFSET Header_Display_List = ListAppend(Header_Display_List, "#application.returned_customer_setting.Operator_Legacy_Id_label#", ",")>
  							<CFSET Header_Value_List = ListAppend(Header_Value_List, "Legacy Id", ",")>
  						</cfif>
 	<!--- D39828  :: Added BSA Operator id to Operator search and Results.... START --->
	<cfif appSettings.getShowBSAOperators() EQ 1>
		<CFSET Header_Display_List = ListAppend(Header_Display_List, "#CustomerSettingsLabels.BSA_ID_label#",",")>
		<CFSET Header_Value_List =  ListAppend(Header_Value_List,"BSA Operator ID", ",")>
	 </cfif>
	<!---  D39828  :: Added BSA Operator id to Operator search and Results.... END --->
  						<cfif searchoperator EQ 0>
  						<CFSET Header_Display_List = ListAppend(Header_Display_List, "#qGetLocationTypeLabel.GENERAL_LABELS_LABEL#<br>,City:State,## of<BR>Locations,Doing Business As,Active,&nbsp;  ", ",")>
  						<CFSET Header_Value_List = ListAppend(Header_Value_List, "Location Type,City:State,Number of Locations,Doing Business As,Active, ", ",")>
  						<cfelse>
  						<CFSET Header_Display_List = ListAppend(Header_Display_List, "#qGetLocationTypeLabel.GENERAL_LABELS_LABEL#<br>,City:State,## of<BR>Locations,Doing Business As")>
  						<CFSET Header_Value_List = ListAppend(Header_Value_List, "Location Type,City:State,Number of Locations,Doing Business As")>
  						</cfif>

  						<CFSET Counter = 1>
  						<CFOUTPUT>
  						<CFLOOP LIST="#Header_Display_List#" INDEX="This_Header" DELIMITERS=",">
  							<CFSET This_Value = ListGetAt(Header_Value_List, Counter, ",")>
  							<TD ID="header"><B>
  							<CFSET Counter_1 = 1>
  							<CFLOOP LIST="#This_Header#" INDEX="Each_Token" DELIMITERS=":">
  								<CFSET This_Value_Token = ListGetAt(This_Value, Counter_1, ":")>
  								<CFIF Counter_1 GT 1>
  								<BR>/
  								</CFIF>
  								<CFSET Next_Sort_Item = This_Value_Token>
  								<CFSET Next_Sort_Order = "ASC">
  								<CFSET Img_String = "">
  								<CFIF CompareNoCase(This_Value_Token, FORM.sort_by) EQ 0><!--- current sort --->
  									<CFIF FORM.sort_Order EQ "ASC"><!--- current sort --->
  										<CFSET Next_Sort_Order = "DESC">
  										<CFSET Img_String = "<IMG SRC=""/Images/down_1.gif"">">
  									<CFELSE>
  										<CFSET Img_String = "<IMG SRC=""/Images/up_1.gif"">">
  									</CFIF>
  								</CFIF>
  								<CFIF Trim(Next_Sort_Item) NEQ "">
  								<A HREF="##" onClick="javaScript:return setThisSortItem('#Next_Sort_Item#', '#Next_Sort_Order#');">
  								</CFIF>
  								#Each_Token#
  								<CFIF Trim(Next_Sort_Item) NEQ "">
  								</A> #Img_String#
  								</CFIF>
  								<CFSET Counter_1 = Counter_1 + 1>
  							</CFLOOP>
  							</B></TD>
  							<CFSET Counter = Counter + 1>
  						</CFLOOP>
  						</CFOUTPUT>
  					</TR>

  				<CFOUTPUT QUERY="TheQuery" startrow="#StartRow#" maxrows="#MaxRows#">

  				<cfset AllReturnedOperators = ListAppend(AllReturnedOperators,TheQuery.BSA_Operator_ID)>
  					<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> style="cursor: pointer;">
  						<cfif searchoperator EQ 0>
  						<TD align="center">
  						<CFIF SelectSingleSearchResultOnly EQ 0>
  							<INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Operator_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Operator_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.BSA_Operator_ID), ",")></CFIF>>
  						<CFELSE>
  							<INPUT type="Radio" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Operator_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Operator_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.BSA_Operator_ID), ",")></CFIF>>
  						</CFIF>
  						</TD></cfif>
  						<TD NOWRAP onClick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;">#TheQuery.operator_name#<CFIF trim(TheQuery.legacy_id) EQ ""> [#TheQuery.BSA_Operator_Id#]</cfif></TD>
  						<cfif LegacyIdOn>
  							<TD NOWRAP onClick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;">#TheQuery.legacy_id#&nbsp;</TD>
  						</cfif>
						<!--- D39828  :: Added BSA Operator id to Operator search and Results.... START --->
							<cfif appSettings.getShowBSAOperators() EQ 1>
  							<TD NOWRAP onClick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;">#bsa_operator_id#&nbsp;</TD>
							</cfif>
						<!---  D39828  :: Added BSA Operator id to Operator search and Results.... END --->
  						<!--- <TD>#TheQuery.operator_type#&nbsp;</TD> --->
  						<TD NOWRAP onClick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;">#TheQuery.Operator_Location_Type#&nbsp;</TD>
  						<TD NOWRAP onClick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;">#TheQuery.Operator_City#<BR>#TheQuery.Operator_State#&nbsp;#TheQuery.Operator_Zip#&nbsp;#Ucase(TheQuery.Operator_Country_Code)#<br>#TheQuery.Operator_Phone#</TD>
  						<TD NOWRAP onClick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;">#numberformat(Replace(TheQuery.Operator_Number_Of_Locations,"-","","ALL"),'_,___,___')#&nbsp;</TD>
  						<TD onClick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;">#TheQuery.Operator_DBA#&nbsp;</TD>
  		<cfif searchoperator EQ 0>
  				<td><Cfif TheQuery.Deleted IS 1>Inactive<cfelse>Active</CFIF></td>
  				<td><CF_smallLink
  	title = "edit operator"
  	url = "##"
  	parameters = "onClick=""javascript: return editOperator('#trim(TheQuery.BSA_Operator_ID)#');"""
  	></td></cfif>
  	 				</TR>
  					<!---<cfflush>--->
  				</CFOUTPUT>
  				</TABLE>

  				<HR COLOR="Orange" SIZE="2">
  				<DIV ALIGN="center" STYLE="font-size: 12px; color: Red;">
  					<CF_Next_Previous_For_Forms
  					formname="MyForm"
  					query="TheQuery"
  					maxpages="40"
  					previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
  					next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
  					previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
  					nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
  					addparams="">
  				</DIV>
  				<HR COLOR="Orange" SIZE="2">
  		<!---	</CFIF>--->


  		</CFIF>
  	</FIELDSET>
  </CFIF>

  <CFPARAM name="TheQuery.Recordcount" default="0">
  	<SCRIPT>
  		function resetform() {
  			document.all.LoadProductsFromThesePrograms.value = '';
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
  <cfoutput>
  <INPUT TYPE="hidden" NAME="FinalItemList" VALUE="#Form.FinalItemList#">
  <INPUT TYPE="hidden" NAME="AlreadySelectedItems" VALUE="#Form.AlreadySelectedItems#">
  <INPUT TYPE="hidden" NAME="finishedselectingitems" VALUE="0">
  <INPUT TYPE="hidden" NAME="LoadSavedOperators" VALUE="0">
  <INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
  <INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
  <INPUT TYPE="Hidden" NAME="LoadProductsFromThesePrograms"  		VALUE="#form.LoadProductsFromThesePrograms#">
  <input type="Hidden" NAME="SelectSingleSearchResultOnly" value="#SelectSingleSearchResultOnly#">
  <input type="hidden" name="AllReturnedOperators" value="#AllReturnedOperators#">
  </cfoutput>
  </FORM>

  </BLOCKQUOTE></BLOCKQUOTE>
  <!--- <SCRIPT>
  	//load the name of the select boxes to hide
  	findselectboxes()
  </SCRIPT> --->
  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
  <CFINCLUDE TEMPLATE="/includes/footer.cfm">
  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


  <!--- delete other section --->
  <cfif application.programlayout EQ 1></div></cfif>

  <cfelse>
  <!---- TAB SEPARATOR TYPES TAB starts here ---->

    <CFQUERY NAME="getOperatorType" datasource="#application.datasource#">
      SELECT	BSA_Operator_Type_ID,
              Operator_Type,
              Business_Segment_ID,
              Active,
              Deleted,
              Created_Date,
              Updated_Date,
              Last_Edited_By,
              Is_Default
      FROM	Awayx_Operator_Type
      WHERE Deleted = 0
      ORDER BY Operator_Type
    </CFQUERY>

    <CFQUERY NAME="getUserName" datasource="#application.datasource#">
      SELECT  TOP 1 _Users.Name_First, _Users.Name_Last, Awayx_Operator_Type.Updated_Date
      FROM _Users
      INNER JOIN Awayx_Operator_Type  ON _Users.User_ID = Awayx_Operator_Type.Last_Edited_By
      WHERE User_ID = (SELECT Top 1 Last_Edited_By FROM Awayx_Operator_Type WHERE Active = 1 AND DELETED = 0 ORDER BY Updated_Date DESC) ORDER BY                Awayx_Operator_Type.Updated_Date DESC

    </CFQUERY>

  	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

  <cfif (getUserName.RecordCount EQ 1 AND (getUserName.Updated_Date NEQ "" OR LEN(getUserName.Updated_Date)GT 0))>
   <br>
   <cfoutput>
  <div style="padding:0 0 0 10;">
    <TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
      <TR>
        <TD>
        	&nbsp;&nbsp;<FONT SIZE="2"><B>The settings were last updated on #dateformat(getUserName.Updated_Date, 'mm/dd/yyyy')# #timeformat(getUserName.Updated_Date, 'hh:mm:ss TT')# by #getUserName.Name_First# #getUserName.Name_Last#</B></FONT>	</TD>
        </TD>
      </TR>
    </TABLE>
    </div>
  </cfoutput>
</cfif>
<!---  Main Code  --->
 <br>
 <TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="750">
		<TR>
			<TD VALIGN="top">

				<SPAN CLASS="title2">Stored Records</SPAN>
				<HR COLOR="Blue" SIZE="1">

				<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" WIDTH="200" CLASS="Maintable">
					<TR>
						<TD NOWRAP WIDTH="100%"><SPAN STYLE="font-size: 12px;"><B>Operator Type</B></SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN></TD>
						<TD>&nbsp; </TD>
					</TR>
					<CFOUTPUT QUERY="getOperatorType">
					<TR>
						<TD NOWRAP><A HREF="select_operators.cfm?OPID=#BSA_Operator_Type_ID#&tabSetter=2">#Operator_Type#</A> &nbsp;&nbsp;</TD>
						<TD NOWRAP>
							<cfif Active EQ 1>
							<IMG SRC="/images/yes_small.gif" TITLE="active record...">
							<cfelse>
							<IMG SRC="/images/no_small.gif" TITLE="inactive record...">
							</cfif>
						</TD>
						<TD>
							<!--- <cfif Is_Default IS 1>
							default
							<cfelse>
							&nbsp;
							</cfif> --->
						</TD>
					</TR>
					</CFOUTPUT>
				</TABLE>
  			<BR>
				<IMG SRC="/images/yes_small.gif" BORDER="0" ALT="" ALIGN="middle"> - active record<BR>
				<IMG SRC="/images/no_small.gif" BORDER="0" ALT="" ALIGN="middle"> - inactive record

			</TD>
			<TD VALIGN="top">

				<SPAN CLASS="title2">Edit Record</SPAN>
				<HR COLOR="Blue" SIZE="1">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for the ID of the item passed --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFPARAM NAME="URL.OPID" DEFAULT="0">
<CFPARAM NAME="getOperatorType.BSA_Operator_Type_ID" default="0">
<CFPARAM NAME="getOperatorType.Operator_Type" default="">
<CFPARAM NAME="getOperatorType.Business_Segment_ID" default="0">
<CFPARAM NAME="getOperatorType.Active" default="1">
<CFPARAM NAME="getOperatorType.Deleted" default="0">
<CFPARAM NAME="getOperatorType.Created_Date" default="">
<CFPARAM NAME="getOperatorType.Updated_Date" default="">
<CFPARAM NAME="getOperatorType.Last_Edited_By" default="">
<CFPARAM NAME="getOperatorType.Is_Default" default="0">

<CFQUERY NAME="GetItem" datasource="#application.datasource#">
	SELECT	*
	FROM Awayx_Operator_Type
	WHERE		BSA_Operator_Type_ID	= '#URL.OPID#'
</CFQUERY>
<link rel="stylesheet" type="text/css" media="screen" href="/Script/javascript/Ajax_JS/jquery.suggest.css" />
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>

<SCRIPT language="JavaScript">
function alert_and_delete()
{
	var confirmdelete = confirm("Click OK to permanently delete this data. You won't be able to undo this change...");
	if (confirmdelete == true)
	{
		document.all.DeleteRecord.value= 1;
		document.all.frmOperators.submit();
	}

}
function Validate()
{
	var Submit_OK = 1;
	if (document.all.Operator_Type.value == "")
	{
		alert("Please enter an Operator Type");
		document.all.Operator_Type.focus();
		Submit_OK=0;
		return;
	}
	if (Submit_OK == 1)
	{
		document.all.frmOperators.submit()
	}
}

</SCRIPT>

			<FORM action="save_operator_type.cfm" method="post" name="frmOperators">
				<table cellspacing="5" cellpadding="0">
					<tr>
						<td valign="top" ALIGN="right"><B>Operator Type</B></TD>
						<td valign="top">
							<cfoutput>
								<input size="40" name="Operator_Type" value="#GetItem.Operator_Type#" maxlength="35">
							</cfoutput>
						</td>
					</tr>
          <tr>
						<td valign="top" align="right"><B>Availability</B></TD>
						<td valign="top">
  						<!--- Is this record deleted? --->
  						<cfif GetItem.Active EQ 0>
  							<cfset active="">
  							<cfset inactive=" CHECKED">
    					<cfelse>
  							<cfset active=" CHECKED">
  							<cfset inactive="">
    					</cfif>
  						<cfoutput>
  						<input type="radio" value="1" name="Active" #active#>Active
  						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  						<input type="radio" value="0" name="Active" #inactive#>Inactive
  						</CFOUTPUT>
						</td>
					</tr>
          <!--- No Default is required --->
					<!--- <tr>
						<td valign="top" align="right"><strong>Default</strong></td>
						<td valign="top">
							<input type="CheckBox" value="1" name="Is_Default" <CFIF GetItem.Is_Default EQ 1>checked</CFIF>>Yes
						</td>
					</tr> --->
					<tr>
						<td valign="top" align="right"></td>
						<td valign="top">
							<font color="#ff0000" size="2"><b>[</b></font>
							<a href="javascript: Validate()"><b>save data</B></A>
							<font color="#ff0000" size="2"><b>]</b></font>
						  <input type="hidden" name="DeleteRecord" value="0">
              <input type="hidden" name="BSA_Operator_Type_ID" value="<cfoutput>#URL.OPID#</cfoutput>">
							<cfif GetItem.Deleted EQ 0>
  							<font COLOR="#ff0000" SIZE="2"><b>[</b></font>
  									<A HREF="javascript: alert_and_delete();"><B>delete data</B></A>
  							<font color="#ff0000" SIZE="2"><B>]</B></font>
							</cfif>
						</td>
					</tr>
				</table>
			</FORM>
			</td>
		</tr>
	</table>

  <B>
  <FONT COLOR="#ff0000" SIZE="2">&nbsp;&nbsp;<B>[</B></FONT>
  	<A HREF="select_operators.cfm?tabSetter=2"><B>create new entry</B></A>
  <FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
  </B>

  </cfif>

  </cfmodule>