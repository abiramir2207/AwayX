<cfsilent>
<!--------------------------------------------------------
Start Search Form
--------------------------------------------------------->
<CFSET Form_Field_Width = "210">
<cfparam name="form.PL_Final" 		default="">
<cfparam name="form.PL_PreSubmit" 	default="">
<cfparam name="form.PL_PostSubmit" 	default="">

<cfparam name="form.currentProgramList" default="">
<cfparam name="form.currentStatusList" default="">
<cfparam name="form.currentStatusList2" default="">
<cfparam name="form.currentReportProgramList" default="">
<!--- <cfparam name="form.SearchIsConductedFromOtherWindow" default="0"> --->

<!--- 14479 (RBL) 01/24/08 [begin] --->
<!--- this is duplicitious but not sure where else it surfaces... RBL --->
<cfparam name="url.programSearchType" type="string" default="quick">
<!--- 14479 (RBL) 01/24/08 [end] --->

<cfset discountIdentifierManager = CreateObject("component","components.programs.discount_identifier.discountidentifier")>
<cfif NOT isDefined("genSettingsManager") OR NOT isDefined("appSettings")>
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
</cfif>
	<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
	<cfset ProductGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />
	<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init()>
</cfsilent>

<STYLE>
	select,input,td b
	{
		font-size : 10px;
		font-family:"Century Gothic", Verdana, Arial;
	}
</STYLE>

<!--- SELECT
{
  font-size : 10px;
  WIDTH:<CFOUTPUT>#Form_Field_Width#</CFOUTPUT>px;
} --->

<cfparam name="FILTER_BUSINESS_SEGMENT_ID" default="0">
<cfif isDefined("BUSINESS_SEGMENT_ID")>
	<CFSET FILTER_BUSINESS_SEGMENT_ID = FORM.BUSINESS_SEGMENT_ID>
</cfif>
<CFSET Layer_ID = 9999>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>

<SCRIPT LANGUAGE="JavaScript">
	var bNoPrevSearch = true;
	function showSearchResult(bchangeMode, pageNum)
	{
	var ReportType = 0;

		document.SearchForm.startrow.value = pageNum;
		if(arguments.length > 2)
		{
			document.SearchForm.frompage.value = arguments[2];
		}
		var searhFormHideImg = document.all.image_<CFOUTPUT>#Layer_ID#</CFOUTPUT>;
		if(bchangeMode)
		{
			document.SearchForm.title.value = "";
			searhFormHideImg.click();
		}

		if(document.SearchForm.Report_Type)
		{
			ReportType = document.SearchForm.Report_Type.options[document.SearchForm.Report_Type.options.selectedIndex].value;

				if(ReportType == 1){
					if(document.getElementById("ClaimReportID")){
						document.getElementById("ClaimReportID").style.display = '';
					}
					if(document.getElementById("PricingReportID")){
						document.getElementById("PricingReportID").style.display = 'none';
					}
					if(document.getElementById("MassApproveID")){
						document.getElementById("MassApproveID").style.display = 'none';
					}
					if(document.getElementById("EditStatusID")){
						document.getElementById("EditStatusID").style.display = 'none';
					}
				}
				else if(ReportType == 2){
					if(document.getElementById("PricingReportID")){
						document.getElementById("PricingReportID").style.display = '';
					}
					if(document.getElementById("ClaimReportID")){
						document.getElementById("ClaimReportID").style.display = 'none';
					}
					if(document.getElementById("MassApproveID")){
						document.getElementById("MassApproveID").style.display = 'none';
					}
					if(document.getElementById("EditStatusID")){
						document.getElementById("EditStatusID").style.display = 'none';
					}
				}
				else{
					if(document.getElementById("PricingReportID")){
						document.getElementById("PricingReportID").style.display = 'none';
					}
					if(document.getElementById("ClaimReportID")){
						document.getElementById("ClaimReportID").style.display = 'none';
					}
					if(document.getElementById("MassApproveID")){
						document.getElementById("MassApproveID").style.display = '';
					}
					if(document.getElementById("EditStatusID")){
						document.getElementById("EditStatusID").style.display = '';
					}
				}
		}
				if(window.frames.Search_Result.MyForm){
						/* If the report type changes (pricing to claim rates or vice-versa, clear the previously selected programs) */
				 if(window.frames.Search_Result.MyForm.ReportType){
					 if(ReportType != window.frames.Search_Result.MyForm.ReportType.value){
						document.SearchForm.currentReportProgramList.value = ''
					}
					else{
						/* This is the variable which holds the list of program id's for the reports (claim rates and pricing) */
						document.SearchForm.currentReportProgramList.value = window.frames.Search_Result.MyForm.currentReportProgramList.value;
					}
				 }
				}

		document.SearchForm.submit();
		bNoPrevSearch = false;
	}

	function disableSelect(sel1, sel2, findProperVal)
	{
		var selInd = 0;
		if(findProperVal)
		{
			selInd = Get_Select_Index(sel2, sel1.value);
			sel2.selectedIndex = selInd;
		}
		else
		{
			if(sel1.selectedIndex > 0)
			{
				sel2.selectedIndex = selInd;
			}
		}
	}

	function dist_lookup_Pick(index,thisObj)
	{
		switch(index)
		{
			case 1:
				disableDiv("SP_Family_Name",false,false);
				disableDiv("SP_Buying_Group",true,false);
				disableDiv("SP_Distributor_Name",true,false);
				break;
			case 2:
				disableDiv("SP_Family_Name",true,false);
				disableDiv("SP_Buying_Group",false,false);
				disableDiv("SP_Distributor_Name",true,false);
				break;
			case 3:
				disableDiv("SP_Family_Name",true,false);
				disableDiv("SP_Buying_Group",true,false);
				disableDiv("SP_Distributor_Name",false,false);
				break;
			default:
		}

	}

	function start_End_Date(start_D,thisObj)
	{
		var spName;
		if(start_D == 1)
		{
			spName = "SP_Start_date";
		}
		else
		{
			spName = "SP_End_date";
		}
		var bDis = (thisObj.selectedIndex == 0)? true: false;
		disableDiv(spName,bDis,false);
	}

	function disable_start_End_Date()
	{
		start_End_Date(1,document.all.Start_date_Operator);
		start_End_Date(2,document.all.End_date_Operator);
		document.all.Start_date.style.fontSize=10;
		document.all.End_date.style.fontSize=10;
	}

	function RS_Start_End_Date(start_D,thisObj)
	{
		var spName;
		if(start_D == 1)
		{
			spName = "RS_SP_Start_date";
		}
		else
		{
			spName = "RS_SP_End_date";
		}
		var bDis = (thisObj.selectedIndex == 0)? true: false;
		disableDiv(spName,bDis,false);
	}

	function RS_Disable_Start_End_Date()
	{
		RS_Start_End_Date(1,document.all.RS_Start_date_Operator);
		RS_Start_End_Date(2,document.all.RS_End_date_Operator);
		document.all.RS_Start_date.style.fontSize=10;
		document.all.RS_End_date.style.fontSize=10;
	}

/* Dev Note: Milan; 9864. This function is being used to "reset" a form */
	function ClearFields()
	{
		for(i=0; i<document.SearchForm.elements.length; i++)
		{
		/* For single select boxes */
				if(SearchForm.elements[i].type =='select-one')
				{
					SearchForm.elements[i].value = SearchForm.elements[i].options[0].value;
				}
		/* For text boxes */
						if(SearchForm.elements[i].type =='text')
						{
						/* Not for date fields - Date fields are disabled instead by "disable_start_End_Date" function above */
							if(SearchForm.elements[i].name != 'Start_date'  && SearchForm.elements[i].name != 'End_date')
							{
								SearchForm.elements[i].value = '';
							}
						}
		  }
	  }
	 //document.body.onload=new Function ("dist_lookup_Pick(3,document.all.SearchForm.elements[0]);disable_start_End_Date();")
	 document.body.onload=new Function ("disable_start_End_Date();<cfif appSettings.getReleaseSettlement()>RS_Disable_Start_End_Date();</cfif>")
</SCRIPT>

<STYLE>
	.sectionHead
	{
		font-weight:bold;
		font-size:15px;
		color:red;
		border-bottom:2px solid #0000CD;
	}
</STYLE>
<cfoutput>
<FORM STYLE="margin-bottom: 0px;margin-top: 0px;" ACTION="/scorecard/program_Search_Result.cfm#form.IFRAME_Extra_URL#" METHOD="post" NAME="SearchForm" ID="SearchForm" TARGET="Search_Result">

<!--- dinesh for Label D26891  --->
<cfif isdefined("position")>
<input type="hidden" value="#position#" name="from_position">
<input type="hidden" value="#Include_work_in_progress_below_me#" name="Include_work_in_progress_below_me">
</cfif>
<!--- dinesh for Label D26891  --->
<input type="hidden" name="type" value="#url.type#">
</cfoutput>


<CFSCRIPT>
	Border="Yes";
	BorderSize=0;
	BorderColor="";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Navy";
	TitleFont="Arial";
	TitleSize=10;
	IsClosed="No";
	WIDTH="100%";
</CFSCRIPT>
	<CFQUERY NAME="Get_User_Positions" DATASOURCE="#application.datasource#">
		SELECT	User_Positions_ID, Position_Label
		FROM	User_Positions
		WHERE
				len(Position_Label) <> 0
				AND
				Deleted = 0
				AND
				(
					User_Positions.Service_Market_ID IS NULL
					OR EXISTS
					(
						SELECT  *
						FROM 	Service_Markets
						WHERE
								Deleted = 0
								AND
								Service_Markets.Service_Market_ID = User_Positions.Service_Market_ID
					)
				)
				AND
				(
					User_Positions.Service_Region_ID IS NULL
					OR EXISTS
					(
						SELECT  *
						FROM 	Service_Regions
						WHERE
								Deleted = 0
								AND
								Service_Regions.Service_Region_ID = User_Positions.Service_Region_ID
					)
				)
				AND
				(
					User_Positions.Service_Zone_ID IS NULL
					OR EXISTS
					(
						SELECT  *
						FROM 	Service_Zones
						WHERE
								Deleted = 0
								AND
								Service_Zones.Service_Zone_ID = User_Positions.Service_Zone_ID
					)
				)
		ORDER BY Position_Label
	</CFQUERY>
	<CFQUERY NAME="Get_Users_And_Positions" DATASOURCE="#application.datasource#" cachedwithin="#APPLICATION.userDataCacheSpan#">
		SELECT	User_Positions_ID, _Users.Name_First + ' ' +  _Users.Name_Last AS User_Name
		FROM	_Users
				INNER JOIN User_Position_Holders
				ON
				User_Position_Holders.User_ID = _Users.User_ID
				AND
				User_Position_Holders.Deleted = 0
				AND User_Position_Holders.User_Position_Type = 'P'
		WHERE
				_Users.Deleted = 0
				AND
				Len(_Users.Name_First) > 0
				AND
				Len(_Users.Name_Last) > 0
		<!---Don't show BSA users --->
	<cfif appSettings.getHide_BSA_Users() IS 1 AND request.AccessStructure.User_Rights_ID NEQ 9999>
	AND (_Users.User_Rights_ID IS NULL
	OR _Users.User_Rights_ID != 9999)
	</cfif>
		ORDER BY _Users.Name_First
	</CFQUERY>

<cfscript>

function isNextRow(maxCols, currCols)
{
	if(currCols LTE 1)
	{
		return 0;
	}
	else
	{
		return (not(currCols) mod maxCols);
	}
}

</cfscript>
<cfset maxColsPerRow = 4/>
<!--- 14479 (RBL) 01/24/08 [begin] {added #uCase(url.programSearchType)#} --->
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"
	BorderColor="#BorderColor#"
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Hide Program #uCase(url.programSearchType)# Search Form"
	TitleClosed="Show Program #uCase(url.programSearchType)# Search Form"
	TitleTooltip="Click here to toggle the view"
	TitleColor="#TitleColor#"
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#"
	layerid="#Layer_ID#">
  <!--- 14479 (RBL) 01/24/08 [end] {added #uCase(url.programSearchType)#} --->

	<CFSET Date_Operators=" ,Greater_Or_Equal,Equal,Less_Or_Equal">
	<CFSET Date_Operator_Symbols=" ,>=,=,<=">
	<TABLE BORDER="0" CELLSPACING="2" WIDTH="<CFOUTPUT>#table_Width#</CFOUTPUT>" CELLPADDING="0">
	<!--- <input type="hidden" name="SearchIsConductedFromOtherWindow" value="#form.SearchIsConductedFromOtherWindow#"> --->
	<!---////////////////////////////////////////////////PROGRAM///////////////////////////////////////////////////--->
		<TR VALIGN="TOP">
			<TD COLSPAN="100%" CLASS="sectionHead">Program</TD>
		</TR>
		<TR VALIGN="TOP">
			<TD WIDTH="30" ROWSPAN="2">&nbsp;</TD>
			<TD>
			<span ID="searchItemLabel"><B>Program Title</B></span><BR>
				<CFPARAM NAME="FORM.Program_Title" DEFAULT="">
				<CFOUTPUT>
				<INPUT TYPE="Text" NAME="Program_Title" STYLE="WIDTH:#Form_Field_Width#px;" SIZE="64"<CFIF len(trim(FORM.Program_Title)) GT 0>VALUE="#trim(FORM.Program_Title)#"</CFIF>>
				</CFOUTPUT>
			</TD>
			<TD>
			<span ID="searchItemLabel"><B>Program Number</B></span><BR>
				<CFPARAM NAME="FORM.Program_Number" DEFAULT="">
				<CFOUTPUT>
				<INPUT TYPE="Text" NAME="Program_Number" STYLE="WIDTH:#Form_Field_Width#px;" <CFIF len(trim(FORM.Program_Number)) GT 0>VALUE="#trim(FORM.Program_Number)#"</CFIF>>
				</CFOUTPUT>
			</TD>
			<TD>
			<cfif discountIdentifierManager.discountIdentifierOn()>
				<span ID="searchItemLabel"><B>Discount Identifier</B></span><BR>
				<CFPARAM NAME="FORM.Discount_Identifier" DEFAULT="0">
				<cfset qDiscountIdentifiers = discountIdentifierManager.getActive(useCache=1)>
        <cfoutput>
				<SELECT NAME="Discount_Identifier" STYLE="WIDTH:#Form_Field_Width#px;">
					<OPTION VALUE="0">**ALL** Discount Identifier</OPTION>
					<cfloop query="qDiscountIdentifiers"><OPTION VALUE="#trim(Discount_Identifier_ID)#"#IIF(trim(FORM.Discount_Identifier) EQ Discount_Identifier_ID, DE(" SELECTED"), DE(""))#>#trim(Discount_Identifier_Desc)#</OPTION></cfloop>
				</SELECT>
        </cfoutput>
			<cfelse>
				<span ID="searchItemLabel"><B>Program Generic Type</B></span><BR>
				<CFPARAM NAME="FORM.Generic_Type" DEFAULT="0">
				<cfset useLakebaseForGet_Generic_Types = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("generic_type")>
<cfif useLakebaseForGet_Generic_Types>
	<cftry>
		<cfset Get_Generic_Types = application.oLakebase.toQuery(
			application.oLakebase.selectRows("generic_type", {
				"order" = "generic_type.asc",
				"select" = "generic_type"
			}), "generic_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Generic_Types = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Generic_Types>
<CFQUERY NAME="Get_Generic_Types" DATASOURCE="#application.datasource#">
				Select	Generic_Type
				From 	Generic_Type
				Order By Generic_Type
				</CFQUERY>
</cfif>
        <cfoutput>
          <SELECT NAME="Generic_Type" STYLE="WIDTH:#Form_Field_Width#px;">
            <OPTION VALUE="0">**ALL** Generic Type</OPTION>
            <cfloop query="Get_Generic_Types"><OPTION VALUE="#trim(Generic_Type)#"#IIF(trim(FORM.Generic_Type) EQ Generic_Type, DE(" SELECTED"), DE(""))#>#trim(ReReplaceNoCase(Generic_Type, "trade", application.returned_customer_setting.Trade_Label))#</OPTION></cfloop>
          </SELECT>
        </cfoutput>
			</cfif>
			</TD>
			<TD>
			<span ID="searchItemLabel"><B>Program Status</B></span><BR>
				<CFQUERY NAME="Get_Status" DATASOURCE="#application.datasource#" cachedwithin="#CreateTimeSpan(0, 12, 0, 0)#">
					Select	Contract_Status_Type_ID,Contract_Status_Type_Desc
					From 	Contract_Status_Types
					Where
						Contract_Status_Type_ID <> 3
					<cfif programManager.getIsBidFeatureOn() eq 0>
					AND Contract_Status_Type_ID NOT IN (8,10)
					</cfif>
					Order By Contract_Status_Type_ID
					</CFQUERY>
					<CFPARAM NAME="FORM.Status" DEFAULT="-1">
          <cfoutput>
					<SELECT NAME="Status" STYLE="WIDTH:#Form_Field_Width#px;">
						<OPTION VALUE="-1">**ALL** Status</OPTION>
						<OPTION VALUE="0">**ALL** Non-expired Status</OPTION>
						<cfloop query="Get_Status"><OPTION VALUE="#trim(Get_Status.Contract_Status_Type_ID)#"#IIF(trim(FORM.Status) EQ Get_Status.Contract_Status_Type_ID, DE(" SELECTED"), DE(""))#>#trim(Get_Status.Contract_Status_Type_Desc)#</OPTION></cfloop>
					</SELECT>
          </cfoutput>
					<!------ <br><b style="color:red;font-size:10px;">**All** Status will not include expired programs</b> ----->
			</TD>
		</TR>
		<TR>
			<TD>
			<span ID="searchItemLabel"><B>Start Date</B></span><BR>
				<CFOUTPUT>
				<TABLE CELLPADDING="0" CELLSPACING="0">
				<TR><TD>
				<CFPARAM NAME="FORM.Start_date_Operator" DEFAULT="">
				<SELECT OnChange="JavaScript: start_End_Date(1,this);" NAME="Start_date_Operator" ID="Start_date_Operator" STYLE="WIDTH:45px">
					<CFSET cnt=0>
					<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
						<CFSET cnt=cnt+1>
						<OPTION VALUE="#Trim(thisOperator)#"<CFIF FORM.Start_date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
					</CFLOOP>
				</SELECT>
				</TD>
				<TD>
				<CFPARAM NAME="FORM.Start_date" DEFAULT="#Now()#">
				<SPAN ID="SP_Start_date">
				<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="Start_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.Start_date#">
				</SPAN>
				</TD>
			</TR></TABLE>
				</CFOUTPUT>
			</TD>
			<TD>
			<span ID="searchItemLabel"><B>End Date</B></span><BR>
			<CFOUTPUT>
			<TABLE CELLPADDING="0" CELLSPACING="0">
				<TR><TD>
				<CFPARAM NAME="FORM.End_date_Operator" DEFAULT="">
				<SELECT OnChange="JavaScript: start_End_Date(2,this);" NAME="End_date_Operator" ID="End_date_Operator" STYLE="WIDTH:45px">
					<CFSET cnt=0>
					<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
						<CFSET cnt=cnt+1>
						<OPTION VALUE="#Trim(thisOperator)#"<CFIF FORM.End_date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
					</CFLOOP>
				</SELECT>
				</TD>
				<TD>
				<CFPARAM NAME="FORM.End_date" DEFAULT="#Now()#">
				<SPAN ID="SP_End_date">
				<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="End_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.End_date#">
				</SPAN>
				</TD>
			</TR></TABLE>
			</CFOUTPUT>
			</TD>
			<cfset colsCount = 2>
			<cfif form.businessSegmentsOn EQ 1>
			<cfset colsCount = colsCount + 2>
			<TD>
				<span ID="searchItemLabel"><B><cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput></B></span><BR>
				<!---get the list of business segments--->
				<cfset qGetBusSegments = businessSegManager.getActive(request.AccessStructure.User_ID) />
				<select name="Business_Segment_ID">
					<option value="0">**ALL** <cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput></option>
					<cfoutput query="qGetBusSegments">
						<option value="#Business_Segment_ID#">#Business_Unit_Desc#</option>
					</cfoutput>
				</select>
			</TD>
			<TD>
				<cfoutput>
				<span ID="searchItemLabel"><B>Legacy Deal ID</B></span><BR>
				<INPUT TYPE="Text" NAME="Legacy_Deal_ID" STYLE="WIDTH:#Form_Field_Width#px;" SIZE="64">
				</cfoutput>
			</TD>
			</cfif>
			<cfif colsCount GTE 4>
				</TR><TR><TD WIDTH="30" ROWSPAN="2">&nbsp;</TD>
				<cfset colsCount = 0 />
			</cfif>
			<cfif Get_Profile_Settings.Read_Only_Catalog_Access EQ 1>
			<cfset colsCount ++ />
			<TD>
				<cfoutput>
				<span ID="searchItemLabel"><B>Search Result (catalog)</B></span><BR>
				<SELECT name="readOnlyCatalogSearch" STYLE="WIDTH:#Form_Field_Width#px;">
					<OPTION value="0">Programs</OPTION>
					<OPTION value="1">Catalog</OPTION>
					<OPTION value="2">Both</OPTION>
				</SELECT>
				</cfoutput>
			</TD>
			</cfif>
			<cfset TemplateList =  TemplateManager.getAll()>
			<cfset colsCount ++ />
			<TD>
				<span ID="programTemplate"><B>Program Template</B></span><BR>
				<SELECT name="Template_Name" STYLE="WIDTH:<cfoutput>#Form_Field_Width#</cfoutput>px;">
					<OPTION value="0">**ALL** Templates</OPTION>
					<cfoutput query ="TemplateList">
						<OPTION value="#Created_Type#">#Created_Type#</OPTION>
					</cfoutput>
				</SELECT>
			</TD>
			<!--- DEV NOTE: KAL; D38689: Add Conditions drop down field to Advance Program Search --->
			<!--- Conditions --->
			<cfif colsCount GTE 4></TR><TR><TD WIDTH="30" ROWSPAN="2">&nbsp;</TD></cfif>
			<cfset colsCount ++ />
			<td>
				<cfoutput>
				<span ID="conditions"><B>Conditions</B></span><BR>
				<SELECT name="conditions" STYLE="WIDTH:#Form_Field_Width#px;">
					<OPTION value="0">Select Conditions</OPTION>
					<OPTION value="Auto_Renewed">Auto Renewed</OPTION>
					<OPTION value="Cancelled">Cancelled</OPTION>
					<OPTION value="Doc_Attached">Doc Attached</OPTION>
					<OPTION value="Not_Cancelled">Not Cancelled</OPTION>
					<OPTION value="Revision">Revision</OPTION>
				</SELECT>
				</cfoutput>
			</td>

			<cfif url.searchType EQ 1 AND appSettings.getGL_Account_On()>
				<cfif colsCount GTE 4></TR><TR><TD WIDTH="30" ROWSPAN="2">&nbsp;</TD></cfif>
				<cfset colsCount ++ />
				<td>
					<cfoutput>
						<span ID="searchItemLabel"><B><cfoutput>#Application.GLAccountLabel#</cfoutput></B></span><BR><!---D42774 --->
						<INPUT TYPE="Text" NAME="GL_Account" STYLE="WIDTH:#Form_Field_Width#px;" SIZE="64">
					</cfoutput>
				</td>
			</cfif>
		</TR>

		<!---////////////////////////////////////////////////PRODUCTS///////////////////////////////////////////////////--->
		<cfoutput>
		<TR VALIGN="TOP">
			<TD COLSPAN="100%" CLASS="sectionHead">Product</TD>
		</TR>
		<TR VALIGN="TOP">
			<TD>&nbsp;</TD>
			<TD>
				<span ID="searchItemLabel"><B>ITEM</B></span>
				<BR>
				<CFPARAM NAME="FORM.item_number" DEFAULT="">
				<INPUT NAME="item_number" VALUE="#FORM.item_number#" STYLE="WIDTH:#Form_Field_Width#px">
			</TD>
			<TD>
				<span ID="searchItemLabel"><B>UPC</B></span>
				<BR>
				<CFPARAM NAME="FORM.UPC" DEFAULT="">
				<INPUT NAME="UPC" VALUE="#FORM.UPC#" STYLE="WIDTH:#Form_Field_Width#px">
			</TD>
			<TD>
				<span ID="searchItemLabel"><B>Description</B></span><BR>
				<CFPARAM NAME="FORM.description" DEFAULT="">
				<INPUT NAME="description" VALUE="#FORM.description#" STYLE="WIDTH:#Form_Field_Width#px">
			</TD>
			<cfif url.searchType EQ 1>
			<TD>
				<CFQUERY NAME="qGetBrands" datasource="#application.datasource#">
					SELECT 	Brand_ID,
							Brand_Name
					FROM 	Brand
					WHERE 	len(brand_name) !=0
					AND 	Deleted = 0
					ORDER BY Brand_Name
				</CFQUERY>
				<cfset sBrandLabel = ProductGroupAttributeManager.getProductGroupLabel(groupLevelId=13) />
				<span ID="searchItemLabel"><B>#sBrandLabel#</B></span>
				<BR>
				<CFPARAM NAME="FORM.Brand_ID" DEFAULT="0">
				<SELECT NAME="Brand_ID" STYLE="WIDTH:#Form_Field_Width#px">
					<OPTION VALUE="0">**ALL** #sBrandLabel#</OPTION>
					<CFLOOP QUERY="qGetBrands">
						<OPTION VALUE="#Brand_ID#" <cfif Brand_ID eq form.Brand_ID>selected</cfif>>#Brand_Name#</OPTION>
					</CFLOOP>
				</SELECT>
			</TD>
			</cfif>
		</TR>
		<cfif url.searchType EQ 1>
		<TR VALIGN="TOP">
		<TD>&nbsp;</TD>
				<CFQUERY NAME="qGettypecodes" datasource="#application.datasource#">
					SELECT 	Type_Code_Desc_ID,
							Type_Code_Desc
					FROM 	Type_Code_Desc
					WHERE 	len(Type_Code_Desc) !=0
					AND 	Deleted = 0
					ORDER BY Type_Code_Desc
				</CFQUERY>


        <TD> <span id="searchItemLabel"><b>#application.returned_customer_setting.type_code_label_singular#</b></span>
          <br> <cfparam name="FORM.Type_Code_Desc_ID" default="0"> <select name="Type_Code_Desc_ID">
            <option value="0">**ALL** #application.returned_customer_setting.type_code_label_plural#</option>
            <cfloop query="qGettypecodes">
              <option value="#Type_Code_Desc_ID#" <cfif Type_Code_Desc_ID eq form.Type_Code_Desc_ID>selected</cfif>>#Type_Code_Desc#</option>
            </cfloop>
          </select> </TD>
		</TR>
		</cfif>
		</cfoutput>
		<cfset currentColCount = 0/>
		<!---////////////////////////////////////////////////CUSTOMER///////////////////////////////////////////////////--->
		<TR VALIGN="TOP">
			<TD COLSPAN="100%" CLASS="sectionHead">Customer</TD>
		</TR>
		<TR VALIGN="TOP">
			<TD>&nbsp;</TD>
			<TD>
			<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.distributor_label_singular# Name</B></span><BR></cfoutput>
			<CFOUTPUT>
			<CFPARAM NAME="FORM.Distributor_Name" DEFAULT="">
			<SPAN ID="SP_Distributor_Name">
			<INPUT NAME="Distributor_Name" ID="Distributor_Name" VALUE="#FORM.Distributor_Name#" STYLE="WIDTH:#Form_Field_Width#px">
			</SPAN>
			</CFOUTPUT>
			</TD>
			<cfset currentColCount = currentColCount + 1 />
			<cfif isNextRow(maxColsPerRow, currentColCount)>
			</TR>
			<TR valign="top">
			<TD>&nbsp;</TD>
			</cfif>
			<TD>
			<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.shard_ship_to_label#</B></span><BR></cfoutput>
			<CFOUTPUT>
			<CFPARAM NAME="FORM.Distributor_shipto" DEFAULT="">
			<SPAN ID="SP_Distributor_shipto">
			<INPUT NAME="Distributor_shipto" ID="Distributor_shipto" VALUE="#FORM.Distributor_shipto#" STYLE="WIDTH:#Form_Field_Width#px">
			</SPAN>
			</CFOUTPUT>
			</TD>
			<cfset currentColCount = currentColCount + 1 />
			<cfif url.searchType EQ 1>
				<cfif isNextRow(maxColsPerRow, currentColCount)>
				</TR>
				<TR valign="top">
				<TD>&nbsp;</TD>
				</cfif>
				<TD>
				<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.buying_group_label_singular#</B></span><BR></cfoutput>
				<cfquery name="GetBuyingGroups" datasource="#application.datasource#" cachedwithin="#APPLICATION.masterDataCacheSpan#">
					SELECT *
					FROM Distributor_Buying_Groups
					WHERE Deleted = 0
					AND	Active_Code = 'A'
					AND Buying_Group_Name<> ''
					ORDER BY Buying_Group_Name
				</cfquery>
				<CFPARAM NAME="FORM.Buying_Group" DEFAULT="0">
				<SPAN ID="SP_Buying_Group">
				<SELECT NAME="Buying_Group">
					<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.buying_group_label_plural#</OPTION></cfoutput>
					<CFOUTPUT QUERY="GetBuyingGroups"><OPTION VALUE="#trim(GetBuyingGroups.Buying_Group_ID)#"#IIF(trim(FORM.Buying_Group) EQ trim(GetBuyingGroups.Buying_Group_ID), DE(" SELECTED"), DE(""))#>#trim(GetBuyingGroups.Buying_Group_Name)#</OPTION></CFOUTPUT>
				</SELECT>
				</SPAN>
				</TD>
				<cfset currentColCount = currentColCount + 1 />
			</cfif>
			<cfif url.searchType EQ 1>
				<cfif isNextRow(maxColsPerRow, currentColCount)>
				</TR>
				<TR valign="top">
				<TD>&nbsp;</TD>
				</cfif>
				<TD>
				<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.family_name_label_singular#</B></span><BR></cfoutput>
				<cfset useLakebaseForGetFamilyNames = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_family")>
<cfif useLakebaseForGetFamilyNames>
	<cftry>
		<cfset GetFamilyNames = application.oLakebase.toQuery(
			application.oLakebase.selectRows("distributor_family", {
				"deleted" = "eq.0",
				"family_name" = "neq.",
				"order" = "family_name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetFamilyNames = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetFamilyNames>
<cfquery name="GetFamilyNames" datasource="#application.datasource#" cachedwithin="#APPLICATION.masterDataCacheSpan#">
					SELECT *
					FROM Distributor_Family
					WHERE Deleted = 0
					AND Family_Name <> ''
					ORDER BY Family_Name
				</cfquery>
</cfif>
				<CFPARAM NAME="FORM.Family_Name" DEFAULT="0">
				<SPAN ID="SP_Family_Name">
				<SELECT NAME="Family_Name">
					<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.family_name_label_plural#</OPTION></cfoutput>
					<CFOUTPUT QUERY="GetFamilyNames"><OPTION VALUE="#trim(GetFamilyNames.Family_ID)#"#IIF(trim(FORM.Family_Name) EQ trim(GetFamilyNames.Family_ID), DE(" SELECTED"), DE(""))#>#trim(GetFamilyNames.Family_Name)#</OPTION></CFOUTPUT>
				</SELECT>
				</SPAN>
				</TD>
				<cfset currentColCount = currentColCount + 1 />
			</cfif>

			<cfif isNextRow(maxColsPerRow, currentColCount)>
			</TR>
			<TR valign="top">
			<TD>&nbsp;</TD>
			</cfif>
			<TD>
			<span ID="searchItemLabel"><B><CFOUTPUT>#application.returned_customer_setting.operator_label_singular#</CFOUTPUT> Name</B></span><BR>
			<CFOUTPUT>
			<CFPARAM NAME="FORM.Operator_Name" DEFAULT="">
			<INPUT NAME="Operator_Name" ID="Operator_Name" VALUE="#FORM.Operator_Name#" STYLE="WIDTH:#Form_Field_Width#px;">
			</CFOUTPUT>
			</TD>
			<!--- Dev Note: Milan; 8497.--->
			<TD>
			<span ID="searchItemLabel"><B><CFOUTPUT>#application.returned_customer_setting.operator_label_singular# ##</CFOUTPUT></B></span><BR>
			<CFOUTPUT>
			<CFPARAM NAME="FORM.Operator_Number" DEFAULT="">
			<INPUT NAME="Operator_Number" ID="Operator_Number" VALUE="#FORM.Operator_Number#" STYLE="WIDTH:#Form_Field_Width#px;">
			</CFOUTPUT>
			</TD>
			<!--- End Note: Milan; 8497. --->
		</TR>

		<!---////////////////////////////////////////////////GEOGRAPHY///////////////////////////////////////////////////--->
		<cfif NOT appSettings.getDistributorMultiPosition() AND url.searchType EQ 1>
		<TR VALIGN="TOP">
			<TD COLSPAN="100%" CLASS="sectionHead">Geography</TD>
		</TR>
		<TR>
			<TD>&nbsp;</TD>
			<TD>
			<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.zone_label_singular#</B></span><BR></cfoutput>
			<CFQUERY NAME="GetZones" DATASOURCE="#application.datasource#" cachedwithin="#APPLICATION.masterDataCacheSpan#">
			SELECT Service_Zone_ID, Zone_Name
			FROM Service_Zones
			WHERE Deleted = 0
			AND len(Zone_Name) > 0
			ORDER BY Zone_Name
			</CFQUERY>
			<CFPARAM NAME="FORM.Service_Zone_ID" DEFAULT="0">
			<SELECT NAME="Service_Zone_ID">
				<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.zone_label_plural#</OPTION></cfoutput>
				<CFOUTPUT QUERY="GetZones"><OPTION VALUE="#trim(Service_Zone_ID)#"#IIF(trim(FORM.Service_Zone_ID) EQ Service_Zone_ID, DE(" SELECTED"), DE(""))#>#trim(Zone_Name)#</OPTION></CFOUTPUT>
			</SELECT>
			</TD>
			<TD>
			<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.region_label_singular#</B></span><BR></cfoutput>
			<CFQUERY NAME="GetRegions" DATASOURCE="#application.datasource#" cachedwithin="#APPLICATION.masterDataCacheSpan#">
			SELECT Service_Region_ID, Region_Name
			FROM Service_Regions
			WHERE Deleted = 0
			AND len(Region_Name) > 0
			ORDER BY Region_Name
			</CFQUERY>
			<CFPARAM NAME="FORM.Service_Region_ID" DEFAULT="0">
			<cfset RegionIDList = "" />
			<SELECT NAME="Service_Region_ID">
				<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.region_label_plural#</OPTION></cfoutput>
				<CFOUTPUT QUERY="GetRegions" GROUP="Region_Name">
					<cfoutput>
						<cfset RegionIDList = listAppend(RegionIDList,trim(GetRegions.Service_Region_ID))>
					</cfoutput>
		<OPTION VALUE="#ListQualify(RegionIDList,"'",",","ALL")#" #IIF(trim(FORM.Service_Region_ID) EQ RegionIDList, DE("SELECTED"), DE(""))#><!--- ' --->
						#trim(Region_Name)#
		</OPTION>

					<cfset RegionIDList = "" />
				</CFOUTPUT>
			</SELECT>
			</TD>
			<cfif appsettings.getRemoveMarketFromPgmSearchPage() EQ 0>
			<TD>
			<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.market_label_singular#</B></span><BR></cfoutput>
			<CFQUERY NAME="GetMarkets" DATASOURCE="#application.datasource#" cachedwithin="#APPLICATION.masterDataCacheSpan#">
			SELECT Service_Market_ID, Market_Name
			FROM Service_Markets
			WHERE Deleted = 0
			AND len(Market_Name) > 0
			ORDER BY Market_Name
			</CFQUERY>
			<CFPARAM NAME="FORM.Service_Market_ID" DEFAULT="0">
			<SELECT NAME="Service_Market_ID">
				<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.market_label_plural#</OPTION></cfoutput>
				<CFOUTPUT QUERY="GetMarkets"><OPTION VALUE="#trim(Service_Market_ID)#"#IIF(trim(FORM.Service_Market_ID) EQ Service_Market_ID, DE(" SELECTED"), DE(""))#>#trim(Market_Name)#</OPTION></CFOUTPUT>
			</SELECT>
			</TD>
			</cfif>
			<TD>
			<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.broker_label_singular#</B></span><BR></cfoutput>
			<CFQUERY NAME="GetBrokers" DATASOURCE="#application.datasource#" cachedwithin="#APPLICATION.masterDataCacheSpan#">
			SELECT BSA_Foodservice_Brokers_ID, Broker_Name
			FROM broker_active
			WHERE len(Broker_Name) > 0
			ORDER BY Broker_Name
			</CFQUERY>
			<CFPARAM NAME="FORM.Broker_ID" DEFAULT="0">
			<cfset BrokerIDList = "">
			<SELECT NAME="Broker_ID">
				<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.broker_label_plural#</OPTION></cfoutput>
				<!--- GROUP BROKERS BY NAME TO DISPLAY THEM ONLY ONCE IN THE SEARCH TOOL --->
				<CFOUTPUT QUERY="GetBrokers" group="Broker_Name">
					<!--- CREATE LIST OF ID'S THAT SHARE A COMMON BROKER NAME FOR USING IN THE SEARCH QUERY --->
					<cfoutput>
						<cfset BrokerIDList = listAppend(BrokerIDList,trim(GetBrokers.BSA_Foodservice_Brokers_ID))>
					</cfoutput>
					<OPTION VALUE="#ListQualify(BrokerIDList,"'",",","ALL")#" <cfif BrokerIDList EQ FORM.Broker_ID>SELECTED</cfif>><!--- ' --->
						#trim(GetBrokers.Broker_Name)#
					</OPTION>
					<!---' CLEAR IDLIST VARIABLE TO ALLOW CREATION OF A NEW LIST FOR THE NEXT BROKER NAME IN THE LOOP --->
					<cfset BrokerIDList = "">
				</CFOUTPUT>
			</SELECT>

			</TD>
		</TR>
		</cfif>

		<cfset currentColCount = 0/>
		<!---////////////////////////////////////////////////OWNERSHIP///////////////////////////////////////////////////--->
		<cfif url.searchType EQ 1>
		<TR VALIGN="TOP">
			<TD COLSPAN="100%" CLASS="sectionHead">Ownership</TD>
		</TR>
		<TR>
			<TD>&nbsp;</TD>
			<cfif NOT appSettings.getDistributorMultiPosition()>
			<TD>
			<!------ user position -------->
				<span ID="searchItemLabel"><B>Program</B></span><BR>
				<SELECT ID="User_Position_Operator" NAME="User_Position_Operator">
					<CFLOOP LIST="#User_Position_Operator_List#" INDEX="This_Op">
						<CFOUTPUT><OPTION VALUE="#Trim(This_Op)#">#This_Op#</OPTION></CFOUTPUT>
					</CFLOOP>
				</SELECT>
			</TD>
			<cfset currentColCount = currentColCount + 1 />
			<cfif isNextRow(maxColsPerRow, currentColCount)>
			</TR>
			<TR valign="top"><TD>&nbsp;</TD>
			</cfif>
			<TD>
				<span ID="searchItemLabel"><B><CFOUTPUT>User Position of</CFOUTPUT><!--- User Position ---></B></span><BR>
				<SELECT NAME="User_Position_Of" onChange="javaScript: disableSelect(this, this.form.User_Position, true);">
					<OPTION VALUE="" SELECTED>**ALL** Users</OPTION>
					<CFOUTPUT QUERY="Get_Users_And_Positions"><OPTION VALUE="#trim(User_Positions_ID)#">#trim(User_Name)#</OPTION></CFOUTPUT>
				</SELECT>
				<B>or</B>
			</TD>
			<cfset currentColCount = currentColCount + 1 />
			<cfif isNextRow(maxColsPerRow, currentColCount)>
			</TR>
			<TR valign="top"><TD>&nbsp;</TD>
			</cfif>
			<TD>
				<span ID="searchItemLabel"><B><CFOUTPUT>User Position</CFOUTPUT><!--- User Position ---></B></span><BR>
				<SELECT NAME="User_Position" onChange="javaScript: disableSelect(this, this.form.User_Position_Of, false);" STYLE="WIDTH:#Form_Field_Width#px">
					<OPTION VALUE="" SELECTED>**ALL** User Positions</OPTION>
					<CFOUTPUT QUERY="Get_User_Positions"><OPTION VALUE="#trim(User_Positions_ID)#">#trim(Position_Label)#</OPTION></CFOUTPUT>
				</SELECT>
			</TD>
			<cfset currentColCount = currentColCount + 1 />
			</cfif>
			<cfif  application.returned_customer_setting.Responsible_Person EQ 1>
			<cfsilent><cfset qUsers = CreateObject("component", "components.user.UserManager").search() /></cfsilent>
			<cfif isNextRow(maxColsPerRow, currentColCount)>
			</TR>
			<TR valign="top"><TD>&nbsp;</TD>
			</cfif>
			<TD>
				<span ID="searchItemLabel"><B><CFOUTPUT>Responsible Sales Person</CFOUTPUT><!--- User Position ---></B></span><BR>
				<SELECT NAME="Responsible_Sales_Person">
					<OPTION VALUE="" SELECTED>**ALL** Users</OPTION>
					<CFOUTPUT QUERY="qUsers"><OPTION VALUE="#trim(User_ID)#">#trim(User_Full_Name)#</OPTION></CFOUTPUT>
				</SELECT>
			</TD>
			<cfset currentColCount = currentColCount + 1 />
			</cfif>


		<cfif application.returned_customer_setting.Accounting_Specialist eq 1>
			<cfif isNextRow(maxColsPerRow, currentColCount)>
			</TR>
			<TR valign="top">
			<TD>&nbsp;</TD>
			</cfif>
			<!---get payment processors--->
			<cfset qPaymentProcessor = CreateObject("component", "components.settings.AccountingSpecialists.AccountingSpecialists").get() />
			<TD colspan="100%">
				<span ID="searchItemLabel"><B>Payment Processor</B></span><BR>
				<SELECT NAME="PP_User_ID">
					<OPTION VALUE="" SELECTED>**ALL** Payment Processors</OPTION>
					<CFOUTPUT QUERY="qPaymentProcessor"><OPTION VALUE="#trim(User_ID)#">#trim(Name)#</OPTION></CFOUTPUT>
				</SELECT>
			</TD>

		</cfif>
		</tr>
		</cfif>

		<!--- ///////////////////////////// Release Settlement ///////////////////////////////////// --->
		<cfif appSettings.getReleaseSettlement()>
		<TR VALIGN="TOP">
			<TD COLSPAN="100%" CLASS="sectionHead">Release Settlement</TD>
		</TR>
		<TR>
			<TD>&nbsp;</TD>
			<TD nowrap>
				<span ID="searchItemLabel"><B>Release Start Date</B></span><BR>
				<CFOUTPUT>
				<TABLE CELLPADDING="0" CELLSPACING="0">
				<TR>
					<TD>
					<CFPARAM NAME="FORM.RS_Start_date_Operator" DEFAULT="">
					<SELECT OnChange="JavaScript: RS_Start_End_Date(1,this);" NAME="RS_Start_date_Operator" ID="RS_Start_date_Operator" STYLE="WIDTH:45px">
						<CFSET cnt=0>
						<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
							<CFSET cnt=cnt+1>
							<OPTION VALUE="#Trim(thisOperator)#"<CFIF FORM.Start_date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
						</CFLOOP>
					</SELECT>
					</TD>
					<TD>
					<CFPARAM NAME="FORM.RS_Start_date" DEFAULT="#Now()#">
					<SPAN ID="RS_SP_Start_date">
					<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="RS_Start_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.RS_Start_date#">
					</SPAN>
					</TD>
				</TR>
				</TABLE>
				</CFOUTPUT>
			</TD>
			<TD nowrap>
				<span ID="searchItemLabel"><B>Release End Date</B></span><BR>
				<CFOUTPUT>
				<TABLE CELLPADDING="0" CELLSPACING="0">
					<TR><TD>
					<CFPARAM NAME="FORM.RS_End_date_Operator" DEFAULT="">
					<SELECT OnChange="JavaScript: RS_Start_End_Date(2,this);" NAME="RS_End_date_Operator" ID="RS_End_date_Operator" STYLE="WIDTH:45px">
						<CFSET cnt=0>
						<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
							<CFSET cnt=cnt+1>
							<OPTION VALUE="#Trim(thisOperator)#"<CFIF FORM.End_date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
						</CFLOOP>
					</SELECT>
					</TD>
					<TD>
					<CFPARAM NAME="FORM.RS_End_date" DEFAULT="#Now()#">
					<SPAN ID="RS_SP_End_date">
					<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="RS_End_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.RS_End_date#">
					</SPAN>
					</TD>
				</TR></TABLE>
				</CFOUTPUT>
			</TD>
			<TD nowrap>
				<span ID="searchItemLabel"><B><CFOUTPUT>Released By</CFOUTPUT><!--- User Position ---></B></span><BR>
				<SELECT NAME="RS_User_Position_Of" onChange="javaScript: disableSelect(this, this.form.RS_User_Position, true);">
					<OPTION VALUE="" SELECTED>**ALL** Users</OPTION>
					<OPTION VALUE="AUTO">AUTO</OPTION>
					<CFOUTPUT QUERY="Get_Users_And_Positions"><OPTION VALUE="#trim(User_Positions_ID)#">#trim(User_Name)#</OPTION></CFOUTPUT>
				</SELECT>
				<B>or</B>
			</TD>
			<TD nowrap>
				<span ID="searchItemLabel"><B><CFOUTPUT>Released By (User Position)</CFOUTPUT><!--- User Position ---></B></span><BR>
				<SELECT NAME="RS_User_Position" onChange="javaScript: disableSelect(this, this.form.RS_User_Position_Of, false);" STYLE="WIDTH:#Form_Field_Width#px">
					<OPTION VALUE="" SELECTED>**ALL** User Positions</OPTION>
					<OPTION VALUE="AUTO">AUTO</OPTION>
					<CFOUTPUT QUERY="Get_User_Positions"><OPTION VALUE="#trim(User_Positions_ID)#">#trim(Position_Label)#</OPTION></CFOUTPUT>
				</SELECT>
			</TD>
			<TD>&nbsp;</TD>
		</TR>

		</cfif>

		<cfif appSettings.getProgramClaimRatesReportAvailable() OR appSettings.getShowPricingReport()>
		<TR VALIGN="TOP">
			<TD COLSPAN="100%" CLASS="sectionHead">Report</TD>
		</TR>
		<TR VALIGN="TOP">
			<TD WIDTH="30" ROWSPAN="2">&nbsp;</TD>
			<TD>
			<span ID="searchItemLabel"><B>Report List</B></span><BR>
			<CFPARAM NAME="FORM.Report_Type" DEFAULT="0">
			<SELECT NAME="Report_Type">
					<OPTION VALUE="0">Select a Report</OPTION>
				<cfif appSettings.getProgramClaimRatesReportAvailable()>
					<OPTION VALUE="1">Claim Rates</OPTION>
				</cfif>
				<cfif appSettings.getShowPricingReport()>
					<OPTION VALUE="2">Pricing</OPTION>
				</cfif>
				</SELECT>
			</TD>
		</TR>
		</cfif>

		<TR>
			<TD COLSPAN="100%" align="right">
			<CFOUTPUT>
			<span ID="searchItemLabel"><B></B></span><BR>
			<INPUT TYPE="HIDDEN" NAME="sort_by" VALUE="#Default_Sort#">
			<INPUT TYPE="HIDDEN" NAME="sort_Order" VALUE="#Default_Sort_Order#">
			<INPUT TYPE="HIDDEN" NAME="startrow" VALUE="1">
			<INPUT TYPE="HIDDEN" NAME="frompage" VALUE="1">
			<INPUT TYPE="HIDDEN" NAME="pageLength" VALUE="100">
			<INPUT TYPE="HIDDEN" NAME="title" value="">
			<INPUT TYPE="HIDDEN" NAME="DOSEARCH" VALUE="1">

			<INPUT TYPE="HIDDEN" NAME="PL_Final" 		VALUE="#form.PL_Final#">
			<INPUT TYPE="HIDDEN" NAME="PL_PreSubmit" 	VALUE="#form.PL_PreSubmit#">
			<INPUT TYPE="HIDDEN" NAME="PL_PostSubmit" 	VALUE="#form.PL_PostSubmit#">
			<INPUT TYPE="HIDDEN" NAME="PL_ImportProducts" 		VALUE="0">
			<INPUT TYPE="HIDDEN" NAME="PL_ImportAllProducts" 	VALUE="0">
			<INPUT TYPE="HIDDEN" NAME="PL_AllProductList" 		VALUE="">

			<INPUT TYPE="Hidden" NAME="currentProgramList" VALUE="#form.currentProgramList#">
			<INPUT TYPE="hidden" NAME="currentStatusList" VALUE="#form.currentStatusList#">
			<INPUT TYPE="hidden" NAME="currentStatusList2" VALUE="#form.currentStatusList2#">
			<INPUT TYPE="hidden" NAME="currentReportProgramList" VALUE="#form.currentReportProgramList#">
			<INPUT TYPE="hidden" NAME="ReportType" VALUE="#form.report_type#">

			</CFOUTPUT>
			&nbsp;&nbsp;
			<FONT size="1" COLOR="FF0000">[</FONT> <a HREF="#" ONCLICK="javascript:ClearFields();disable_start_End_Date();">reset form</a> <FONT size="1" COLOR="FF0000">]</FONT>
			&nbsp;&nbsp;
            <FONT size="1" COLOR="#FF0000">[</FONT> <a HREF="#" ONCLICK="javascript:showSearchResult(true, 1);">search programs</a> <FONT size="1" COLOR="#FF0000">]</FONT>

			</TD>
		</TR>
		<TR VALIGN="TOP">
			<TD COLSPAN="100%">&nbsp;</TD>
		</TR>
	</TABLE>
</CF_openLayer>
</FORM>

<CFPARAM name="form.SearchIsConductedFromOtherWindow" default="0">
<cfif form.SearchIsConductedFromOtherWindow EQ 0>
<SCRIPT LANGUAGE="JavaScript">
	document.all.Program_Title.focus();
	findselectboxes();
</SCRIPT>
</cfif>

<!--- Dinesh Rachala LABEL 26667 & D26891   START--->
<!-- This JavaScript function will collect the Contact_Number
     from child window(Program_Search_results) and send those values to parent page of this window which is program_search.cfm -->
<script>
function reassign(s)
{
reassigns(s);
}
</script>
<!--- Dinesh Rachala LABEL 26667 & D26891   END--->
<!--------------------------------------------------------
End Search Form
--------------------------------------------------------->
