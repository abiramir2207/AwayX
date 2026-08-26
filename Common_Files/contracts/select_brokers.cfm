<CFSET PAGE_TITLE="Select Program #application.returned_customer_setting.broker_label_plural#">
<CFSET GROUP="Contracts">

<CFPARAM NAME="URL.CID" DEFAULT="">
<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
<CFSET FORM.Contract_Main_ID = cryp.value>

<CFPARAM name="FORM.button_caption"					default="continue">
<CFPARAM NAME="FORM.searchstring" DEFAULT="">
<CFPARAM NAME="FORM.SelectedITEMS" DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingitems" DEFAULT="0">
<CFPARAM NAME="FORM.LoadSavedBrokers"	Default="1">
<cfparam name="form.LOADPRODUCTSFROMTHESEPROGRAMS" default="">

<cfset appSettings = application.appsettingsGet>

<!---//////////////////////////////////////Business Segment Section/////////////////////////////////////--->

<!---default params for business segments--->
<CFPARAM name="FORM.Business_Segment_ID" default="0">
<CFPARAM name="form.businessSegmentsOn" default="0">

<!---check to see if the business segment components exist before we run this--->
<!---check whether the directory exists or not--->
<cfset theDir = "#request.app_general_functions.get_Application_Path()#\components\programs\business_segment\" />
<cfif DirectoryExists(theDir)>
	<!---if the directory exists then check the file--->
	<cfset theFile = "#theDir#BusinessSegmentManager.cfc" />
	<!---it the file exists then we can create the component--->
	<cfif FileExists(theFile)>
		<!---create and instance of the BusinessSegmentManager--->
		<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<cfif businessSegManager.isEnabled()>
			<cfset form.businessSegmentsOn = 1 />
			<cfset busSegIdForProgram = businessSegManager.getSegmentIdByProgram(FORM.Contract_Main_ID) />
			<cfset form.Business_Segment_Id = trim(busSegIdForProgram) />
			<!---get the desctiption to display--->
			<cfset qGetThisBusSegment = businessSegManager.get(busSegIdForProgram) />
			<cfset Bus_Segment_Desc = qGetThisBusSegment.Business_Unit_Desc />
		</cfif>
	</cfif>
</cfif>

<cfif form.businessSegmentsOn eq 1 and isDefined("FORM.BUSINESS_SEGMENT_ID") and ((FORM.BUSINESS_SEGMENT_ID EQ 3) or (FORM.BUSINESS_SEGMENT_ID EQ 5)) and application.returned_customer_setting.customer_keyword IS "conagra">
		<cfset FORM.BUSINESS_SEGMENT_ID = 1>
</cfif>


<!---//////////////////////////////////////End Business Segment Section/////////////////////////////////////--->

<CFPARAM NAME="startrow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<cf_Number_of_Rows maxrows=25>



<CFIF FORM.LoadSavedBrokers EQ 1>
	<cfquery name="CheckForExistingBrokers" datasource="#application.datasource#">
		SELECT 	cbrk.*, brk.Broker_Name
		FROM Contract_Brokers cbrk, BSA_Foodservice_Brokers brk
		WHERE cbrk.BSA_Foodservice_Brokers_ID = brk.BSA_Foodservice_Brokers_ID
			AND cbrk.Contract_Main_ID = '#cryp.value#'
			AND cbrk.Deleted = 0
			AND brk.Deleted = 0
			AND cbrk.Auto_Selection = 0
		ORDER BY brk.Broker_Name, cbrk.BSA_Foodservice_Brokers_ID
	</cfquery>
	<CFSET FORM.button_caption = "save">
	<CFSET FORM.FinalItemList = valuelist(CheckForExistingBrokers.BSA_Foodservice_Brokers_ID)>
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

<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
	<CFIF listfind(FORM.FinalItemList,ListItem, ",") GT 0>
		<CFSET Form.FinalItemList = listdeleteat(FORM.FinalItemList, listfind(FORM.FinalItemList,ListItem, ","), ",")>
	</CFIF>
</CFLOOP>

<CFIF FORM.finishedselectingitems EQ 1>

	<!--- lock checker --->
	<CFSET LockChecker_CID  = FORM.Contract_Main_ID>
	<CFINCLUDE TEMPLATE="LockChecker.cfm">
	<!--- lock checker --->

	<cfquery name="CheckForExistingBrokers" datasource="#application.datasource#">
		SELECT 	*
		FROM Contract_Brokers
		WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#' AND Deleted = 0
		<CFIF listlen(FORM.FinalItemList) GT 0>
			AND
			BSA_Foodservice_Brokers_ID NOT IN(#replace(listqualify(FORM.FinalItemList, "'", ","), '"', "'", "ALL")#)
		</CFIF>
	</cfquery>

	<cfset useLakebaseFordeletedCurrentBrokers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_brokers")>
<cfif useLakebaseFordeletedCurrentBrokers>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_brokers",
			{
				"contract_main_id" = "eq.#Form.Contract_Main_ID#",
				"auto_selection" = "eq.0"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeletedCurrentBrokers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeletedCurrentBrokers>
<CFQUERY NAME="deletedCurrentBrokers" datasource="#application.datasource#">
		UPDATE Contract_Brokers
		SET Deleted = 1
		WHERE Contract_Main_ID = '#Form.Contract_Main_ID#' AND Auto_Selection = 0
	</CFQUERY>
</cfif>

	<CFLOOP INDEX="ListBroker_ID" LIST="#trim(FORM.FinalItemList)#" DELIMITERS=",">
		<cfquery name="SaveBroker" datasource="#application.datasource#">
			INSERT INTO Contract_Brokers
			(BSA_Foodservice_Brokers_ID, Contract_Main_ID)
			VALUES
			(<CFIF ListBroker_ID EQ 0>NULL<cfelse>'#ListBroker_ID#'</CFIF>, '#FORM.Contract_Main_ID#')
		</cfquery>
	</CFLOOP>

	<CFQUERY name = "get_Auto_Broker" datasource = "#Application.datasource#">
			SELECT BSA_Foodservice_Brokers.*
			FROM BSA_Foodservice_Brokers
				INNER JOIN Contract_Brokers
					ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Contract_Brokers.BSA_Foodservice_Brokers_ID
				WHERE Contract_Brokers.Contract_Main_ID = '#cryp.value#'
					AND Contract_Brokers.Deleted = 0
					AND Contract_Brokers.Auto_Selection = 1
	</CFQUERY>
	<cfset FORM.FinalItemList = listappend(FORM.FinalItemList,valuelist(get_Auto_Broker.BSA_Foodservice_Brokers_ID))>

	<cfquery name="CheckForExistingBrokers_reset" datasource="#application.datasource#">
		SELECT 	*
		FROM Contract_Brokers
		WHERE Contract_Main_ID = '#cryp.value#' AND Deleted = 0
		<CFIF listlen(FORM.FinalItemList) GT 0>
			AND
			BSA_Foodservice_Brokers_ID NOT IN(#replace(listqualify(FORM.FinalItemList, "'", ","), '"', "'", "ALL")#)
		</CFIF>
	</cfquery>

	<CFIF CheckForExistingBrokers_reset.Recordcount EQ 0>
		<!--- REDIRECTOR --->
		<cfset useLakebaseForgetContractProgramID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForgetContractProgramID>
	<cftry>
		<cfset getContractProgramID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#Form.Contract_Main_ID#",
				"select" = "programtype_id"
			}), "programtype_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetContractProgramID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetContractProgramID>
<cfquery name="getContractProgramID" datasource="#application.datasource#">
			SELECT ProgramType_ID
			FROM Contract_Main
			WHERE Contract_Main_ID = '#Form.Contract_Main_ID#'
		</cfquery>
</cfif>
		<CFSET redirector_Program_ID = getContractProgramID.ProgramType_ID>
		<CFSET redirector_FromPage_ID = 3>
		<cfinclude template="internal_redirector_based_on_settings.cfm">
		<CFLOCATION url="redirect.cfm?destination=#redirector_NextLocation#&CID=#URL.CID#">
	<CFELSE>
		<cflocation url="Contract_Edit_Menu.cfm?CID=#URL.CID#">
	</CFIF>
</CFIF>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT type="text/javascript">
		function AutoSearch()
		{
			document.all.SearchFieldSet.style.display = "none";
		}
	</SCRIPT>

</HEAD>

<cfif appsettings.getRemoveBrokerSelection()>
	<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" OnLoad="javascript:AutoSearch()">
<cfelse>
	<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
</cfif>

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
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFSET CSL_Contract_Main_ID = FORM.Contract_Main_ID>
<CFSET CSL_CallingPageCode = "br">
<cfif application.programlayout EQ 1>
<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px">
  <CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>
<cfelse>
<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
</cfif>
<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
 <SCRIPT LANGUAGE="JavaScript" SRC="/script/javascript/string_functions.js"> </script>
 <SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>
 <SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>

<SCRIPT language="JavaScript">
function reset_Form_Fields()
	{
		resetSelect("Zone_ID");
		resetSelect("Region_ID");
		resetSelect("Line_Of_Biz");
		resetSelect("Broker_Status");
		resetSelect("sort_by");
		resetSelect("sort_Order");

		document.all.searchstring.value = "";
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
		var FormValue = FINALITEMLIST;
		var bDelete = true;

		var valueArray = prodID.split(",");

			for(var i=0; i<valueArray.length; i++){
				var resultString = ListDeleteItem(FINALITEMLIST, ",", valueArray[i]);
				FINALITEMLIST = resultString;
			}
		var resultString2 = FINALITEMLIST;

		if(resultString2 == FormValue) {
			for(var i=0; i<valueArray.length; i++){
				resultString = ListAppendItem(FINALITEMLIST, ",", valueArray[i]);
				FINALITEMLIST = resultString;
			}
			bDelete = false;
		}

		document.MyForm.FinalItemList.value = FINALITEMLIST;

		if(trObj)
		{
			var srcObj = event.srcElement;
			if(bDelete)
			{
				propogateProperty(trObj, "style.backgroundColor", "#CCCCCC", false);
				propogateProperty(trObj, "style.textDecoration", "line-through", true);

				srcObj.title = "undo broker deletion";
				srcObj.src = undodeleteImg.src;
			}
			else
			{
				var bgCol = "#eeeeee";

				propogateProperty(trObj, "style.backgroundColor", bgCol, false);
				propogateProperty(trObj, "style.textDecoration", "none", false);

				srcObj.title = "delete this broker";
				srcObj.src = deleteImg.src;
			}
		}
		event.cancelBubble = true;
	}

	function searchPrograms() {
		searchResults = window.showModalDialog('/common_files/contracts/program_search_for_component.cfm','','dialogHeight: 600px; dialogWidth: 940px; dialogTop: px; dialogLeft: px; edge: Raised; center: Yes; help: No; resizable: No; status: No;');
		if(searchResults != 0 && searchResults.length != 0) {
			document.all.LoadProductsFromThesePrograms.value = searchResults;
			document.all.startrow.value = 1; document.all.frompage.value = 1;
			document.MyForm.submit();
		}
	}

</SCRIPT>



<BLOCKQUOTE><BLOCKQUOTE>
	<!---
	<CFSET URL.Contract_Main_ID = FORM.Contract_Main_ID>
	<CFINCLUDE TEMPLATE="thin_contract_general_display.cfm">
	--->
	<cfif application.programlayout EQ 1>
<div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 60px; top: 10px;"></cfif>
<CFSET helpfilenumber=4>
<cfinclude template="minimal_contract_info.cfm">

	<table border="0">
		<tr>
			<cfif appSettings.getFlexBrokerSearch()>
			<td nowrap="true">
			<CF_smallLink 
				title = "search #application.returned_customer_setting.Broker_label_plural#" 
				url = "##"
				parameters = "onClick=""javascript: return showDstributorSearchWindow();"""
				enabled	= "1">
			</td>
			</cfif>
		</tr>
	</table>
	<FORM ACTION="select_brokers.cfm?CID=<CFOUTPUT>#URL.CID#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm" STYLE="DISPLAY:INLINE">
	<cfif appSettings.getFlexBrokerSearch() eq 0>
	<Div id="dvSearchFields" style="display:block;">
	<cfelse>
	<Div id="dvSearchFields" style="display:none;">
	</cfif>
	<FIELDSET STYLE="padding:8px; width: 500px; border: 1px solid Blue;display:table;" ID="SearchFieldSet">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfoutput>#application.returned_customer_setting.broker_label_singular#</cfoutput> search</LEGEND>
			<table>
				<TR>
					<TD COLSPAN="2"><!--- Zone --->
						<cfoutput><span ID="searchItemLabel">#application.returned_customer_setting.zone_label_singular#</span><BR></cfoutput>
						<CFQUERY NAME="GetZones" datasource="#application.datasource#">
						SELECT *
						FROM Service_Zones
						WHERE len(Zone_Name) != 0 AND Deleted = 0
						<cfif application.returned_customer_setting.customer_keyword NEQ "conagra" AND (isDefined("form.Business_Segment_ID") and form.Business_Segment_ID IS NOT 0)>
							and Business_segment_id = <cfqueryparam value="#FORM.Business_Segment_ID#" cfsqltype="cf_sql_integer">
						</cfif>
						ORDER BY Zone_Name
						</CFQUERY>
						<CFPARAM NAME="FORM.Zone_ID" DEFAULT="0">
						<SELECT NAME="Zone_ID" style="width: 200px;">
							<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.zone_label_plural#</OPTION></cfoutput>
							<CFOUTPUT QUERY="GetZones"><OPTION VALUE="#trim(GetZones.Service_Zone_ID)#"#IIF(trim(FORM.Zone_ID) EQ GetZones.Service_Zone_ID, DE(" SELECTED"), DE(""))#>#trim(GetZones.Zone_Name)#</OPTION></CFOUTPUT>
						</SELECT>
					</TD>
					<TD><!--- Regions --->
						<cfoutput><span ID="searchItemLabel">#application.returned_customer_setting.region_label_singular#</span><BR></cfoutput>
						<CFQUERY NAME="GetRegions" datasource="#application.datasource#">
						SELECT *
						FROM Service_Regions
						WHERE len(Region_Name) != 0 AND Deleted = 0
						<cfif application.returned_customer_setting.customer_keyword NEQ "conagra" AND (isDefined("form.Business_Segment_ID") and form.Business_Segment_ID IS NOT 0)>
							and Business_segment_id = <cfqueryparam value="#FORM.Business_Segment_ID#" cfsqltype="cf_sql_integer">
						</cfif>
						ORDER BY Region_Name
						</CFQUERY>
						<CFPARAM NAME="FORM.Region_ID" DEFAULT="0">
						<SELECT NAME="Region_ID" style="width: 200px;">
							<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.region_label_plural#</OPTION></cfoutput>
							<CFOUTPUT QUERY="GetRegions"><OPTION VALUE="#trim(GetRegions.Service_Region_ID)#"#IIF(trim(FORM.Region_ID) EQ getRegions.Service_Region_ID, DE(" SELECTED"), DE(""))#>#trim(GetRegions.Region_Name)#</OPTION></CFOUTPUT>
						</SELECT>
					</TD>
					<TD><!--- Line Of Biz --->
						<cfoutput><span ID="searchItemLabel">#application.returned_customer_setting.lob_label_singular#</span><BR></cfoutput>
						<cfquery name="GetLinesOfBiz" datasource="#application.datasource#">
							SELECT *
							FROM Line_Of_Business
							WHERE len(Line_Of_Business_Name) != 0
							<cfif application.returned_customer_setting.customer_keyword NEQ "conagra" AND (isDefined("form.Business_Segment_ID") and form.Business_Segment_ID IS NOT 0)>
								and Business_segment_id = <cfqueryparam value="#FORM.Business_Segment_ID#" cfsqltype="cf_sql_integer">
							</cfif>
							ORDER BY Line_Of_Business_Name
						</cfquery>
						<CFSET First_Time = NOT Isdefined("FORM.Line_Of_Biz")>
						<CFPARAM NAME="FORM.Line_Of_Biz" DEFAULT="0">
						<SELECT NAME="Line_Of_Biz" style="width: 200px;">
							<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.lob_label_plural#</OPTION></cfoutput>
							<CFOUTPUT QUERY="GetLinesOfBiz">
							<CFIF Line_Of_Business EQ "#ListFirst(application.returned_customer_setting.Line_Business_Default,",")#" AND First_Time>
								<CFSET FORM.Line_Of_Biz = GetLinesOfBiz.Line_Of_Business_ID>
							</CFIF>
                                <OPTION VALUE="#GetLinesOfBiz.Line_Of_Business_ID#" <cfif form.Line_Of_Biz eq GetLinesOfBiz.Line_Of_Business_ID>selected</cfif>>#trim(GetLinesOfBiz.Line_Of_Business_Name)#</OPTION>
                            </CFOUTPUT>
						</SELECT>
					</TD>
					<TD><!--- Active/Inactive --->
						<span ID="searchItemLabel">Status</span><BR>
						<CFPARAM NAME="FORM.Broker_Status" DEFAULT="A">
						<SELECT NAME="Broker_Status">
							<option VALUE="A" <CFIF FORM.Broker_Status EQ "A">SELECTED</CFIF>>Active</option>
							<!--- <option VALUE="N" <CFIF FORM.Broker_Status EQ "N">SELECTED</CFIF>>Inactive</option> --->
						</SELECT>
					</TD>
				</TR>
				<TR>
					<TD NOWRAP ALIGN="left">
					Sort By<BR>
					<CFSET sort_By_List="Name,Address,City,State,Postal Code">
					<CFPARAM NAME="FORM.sort_by" DEFAULT="#Trim(ListFirst(sort_By_List))#">
					<CFOUTPUT>
					<CFSET sort_By_List=ListSort(sort_By_List,"Text")>
					<SELECT ID="sort_by" NAME="sort_by">
					<CFLOOP LIST="#sort_By_List#" INDEX="thisItem">
						<CFSET thisItem=Trim(thisItem)>
						<OPTION VALUE="#thisItem#"<CFIF thisItem EQ FORM.sort_by> SELECTED</CFIF>>#thisItem#</OPTION>
					</CFLOOP>
					</SELECT>
					</CFOUTPUT>
					</TD>
					<TD NOWRAP ALIGN="left">
					Order<BR>
					<CFPARAM NAME="FORM.sort_Order" DEFAULT="ASC1">
					<SELECT ID="sort_Order" NAME="sort_Order">
						<OPTION VALUE="ASC"<CFIF FORM.sort_Order EQ "ASC"> SELECTED</CFIF>>Ascending</OPTION>
						<OPTION VALUE="DESC"<CFIF FORM.sort_Order EQ "DESC"> SELECTED</CFIF>>Descending</OPTION>
					</SELECT>
					</TD>
					<TD NOWRAP ALIGN="left" COLSPAN="2">
						Name<BR>
						<INPUT TYPE="Text" NAME="searchstring" STYLE="WIDTH:405px" SIZE="64"<CFIF len(trim(FORM.searchstring)) GT 0>VALUE="<CFOUTPUT>#trim(FORM.searchstring)#</CFOUTPUT>"</CFIF>>
					</TD>
					<!------<TD NOWRAP ALIGN="left">
						<BR>
						<INPUT TYPE="Submit" VALUE="search">
					</TD>----->
					<TD ALIGN="left" NOWRAP>
					<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10"><BR>
					&nbsp;&nbsp;
					<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javaScript: return doSearchNow();">search <cfoutput>#lcase(application.returned_customer_setting.broker_label_plural)#</cfoutput></a><FONT COLOR="#FF0000">]</FONT></B>
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript: reset_Form_Fields();">reset</a><FONT COLOR="#FF0000">]</FONT></B><BR>
					<!--- <cfif NOT ListFindNoCase("Brokerage", CSLGetContractInfo.Generic_Type) >
						<BR>&nbsp;&nbsp;&nbsp;<B><FONT COLOR="##FF0000">[</FONT><a style="cursor: pointer;" onclick="searchPrograms()">get <cfoutput>#lcase(application.returned_customer_setting.broker_label_plural)#</cfoutput> by program</a><FONT COLOR="##FF0000">]</FONT></B>
					</cfif> ---> <!--- Not Brokerage --->
					</TD>
				</TR>
				<!---if business segements are on then display--->
				<cfif form.businessSegmentsOn eq 1>
				<tr>
					<td colspan="100%"><cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput>:&nbsp;&nbsp;<b><cfoutput>#Bus_Segment_Desc#</cfoutput></b></td>
				</tr>
				</cfif>
			</table>

		<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">
	</FIELDSET>
	</DIV>
	
	<script language="JavaScript">
	<cfoutput>
	function doSearchNow()
	{
		//add restricted search
		var oSearchForm = document.MyForm;
		var any_Filter = false;
		var availOptions = "";
		if(oSearchForm.Line_Of_Biz.value != "0")
		{
			any_Filter = true;
		}
		availOptions = availOptions + "\n - #application.returned_customer_setting.lob_label_plural#";
		if(!any_Filter)
		{
			alert("you have to select atleast one of the following filters" + availOptions);
		}
		else
		{
			oSearchForm.startrow.value = 1;
			oSearchForm.frompage.value = 1;
			oSearchForm.submit();
		}
		return false;
	}
	</cfoutput>
	function showDstributorSearchWindow() 
		{
			<cfoutput>var sURL = "/Flex/search/BrokerSearchFx.cfm?Formname=MyForm&programId=#FORM.Contract_Main_ID#</cfoutput>";			
				NewWindow(sURL, "BrokerSearchWindow", 1024, 715, "yes", "yes");
	
		}
		<!--
		function ReverseContentDisplay(d) {
		if(d.length < 1) { return; }
		if(document.getElementById(d).style.display == "none") { document.getElementById(d).style.display = "block"; }
		else { document.getElementById(d).style.display = "none"; }
		}
		//-->
		
	</script>
	<CFQUERY NAME="GetBrokerInfoMaster" datasource="#application.datasource#">
		SELECT *
		FROM BSA_Foodservice_Brokers
		WHERE BSA_Foodservice_Brokers_ID <CFIF FORM.FinalItemList EQ 0>IS NULL<CFELSEIF listlen(FORM.FinalItemList) GT 0>IN(#listqualify(FORM.FinalItemList, "'", ",")#)<CFELSE>!= BSA_Foodservice_Brokers_ID</CFIF>
		AND deleted = 0
	</CFQUERY>

	<cfset useLakebaseForGetBrokerName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getbrokerinfomaster")>
<cfif useLakebaseForGetBrokerName>
	<cftry>
		<cfset GetBrokerName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getbrokerinfomaster", {
				"select" = "broker_name"
			}), "broker_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBrokerName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBrokerName>
<CFQUERY name="GetBrokerName" dbtype="query">
		SELECT DISTINCT Broker_Name
		FROM GetBrokerInfoMaster
	</CFQUERY>
</cfif>
	<CFOUTPUT>
	<FIELDSET STYLE="padding:8px; width: 800px; border: 1px solid Blue;margin-top:10px;display:table;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">currently selected <cfoutput>#application.returned_customer_setting.broker_label_plural#</cfoutput></LEGEND>
			<CFIF GetBrokerInfoMaster.recordcount GT 0>
				<TABLE border="0" cellspacing="3" cellpadding="3" align="left" WIDTH="775" BGCOLOR="white">
					<TR height="22">
					<CFLOOP QUERY="GetBrokerName">
						<cfset useLakebaseForGetBrokerInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getbrokerinfomaster")>
<cfif useLakebaseForGetBrokerInfo>
	<cftry>
		<cfset GetBrokerInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getbrokerinfomaster", {
				"broker_name" = "eq.#GetBrokerName.Broker_name#",
				"select" = "bsa_foodservice_brokers_id,broker_name"
			}), "bsa_foodservice_brokers_id,broker_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBrokerInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBrokerInfo>
<CFQUERY name="GetBrokerInfo" dbtype="query">
							SELECT BSA_Foodservice_Brokers_ID, Broker_name
							FROM GetBrokerInfoMaster
							WHERE Broker_Name = '#GetBrokerName.Broker_name#'
						</CFQUERY>
</cfif>
							<cfloop query="GetBrokerInfo">
								<cfset brokerList = valueList(GetBrokerInfo.BSA_Foodservice_Brokers_ID,",")>
							</cfloop>
						<cfset ScreenedBroker = listGetAt(Replace(brokerList,"-","_", "ALL"),1,",")>
						<td NOWRAP BGCOLOR="eeeeee" ID="TR_#ScreenedBroker#">
							<img src="/images/scissor.gif" title="click here to delete this broker" border="0" onclick="deleteThisFixedPrice('#ScreenedBroker#', '#brokerList#')" STYLE="cursor: pointer;">
							&nbsp;&nbsp;#GetBrokerName.broker_name#
						</td>
		 				<CFIF GetBrokerName.currentrow mod 4><CFELSE></TR><TR></CFIF>
					</CFLOOP>
				</TABLE>
			<CFELSE>
				<CFIF FORM.FinalItemList EQ 0>ALL <cfoutput>#application.returned_customer_setting.broker_label_plural#</cfoutput><CFELSE>NONE</CFIF>
			</CFIF>
			<BR>
	</FIELDSET>
	</CFOUTPUT>
	<CFQUERY name = "get_Auto_Broker" datasource = "#Application.datasource#">
			SELECT BSA_Foodservice_Brokers.* FROM BSA_Foodservice_Brokers
				INNER JOIN Contract_Brokers
				ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Contract_Brokers.BSA_Foodservice_Brokers_ID
				WHERE Contract_Brokers.Contract_Main_ID = <cfqueryparam value="#cryp.value#" cfsqltype="cf_sql_integer">
				AND Contract_Brokers.Deleted = 0
				AND Contract_Brokers.Auto_Selection = 1
	</CFQUERY>


<CFIF Get_Auto_Broker.recordcount GT 0>
<BR>
<BR>
	<FIELDSET STYLE="padding:8px; width: 800px; border: 1px solid Blue;display:table;" ID="AutoBrokerDisplay">
		<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Automated Broker Selection</LEGEND>
			<TABLE border="0" cellspacing="3" cellpadding="3" align="left" WIDTH="775" BGCOLOR="white">
				<TR><CFOUTPUT QUERY="Get_Auto_Broker">

					<TD NOWRAP BGCOLOR="eeeeee">#Get_Auto_Broker.broker_name#</TD>
		 			<CFIF Get_Auto_Broker.currentrow mod 4><CFELSE></TR><TR></CFIF>
					</CFOUTPUT>
				</TABLE>
	</FIELDSET>
</CFIF>

<br><br>

<!--- <cfinclude template="select_forms_buttons.cfm"> --->
	<TABLE>
		<TR>
			<TD>
				<CF_button
					button_name		=	""
					button_caption	=	"save"
					button_action	=	"document.all.finishedselectingitems.value = 1; MyForm.submit();"
					button_type		=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</TD>
		</TR>
	</TABLE>



<CFPARAM name="FORM.DOSEARCH" default="0">
<CFPARAM name="FORM.SORT_BY" default="Name">
<CFPARAM name="FORM.SORT_ORDER" default="ASC">
<CFIF isdefined("FORM.DOSEARCH")>
<cfsilent>
<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->


<CFSET sql_Sort_By="dbo.BSA_Foodservice_Brokers.Broker_Name">
<CFSWITCH expression="#Form.sort_by#">
	<CFCASE value="Name">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Brokers.Broker_Name">
	</CFCASE>
	<CFCASE value="ID">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Brokers.Broker_Shard">
	</CFCASE>
	<CFCASE value="Address">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Brokers.Address">
	</CFCASE>
	<CFCASE value="City">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Brokers.City">
	</CFCASE>
	<CFCASE value="State">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Brokers.State">
	</CFCASE>
	<CFCASE value="Postal Code">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Brokers.Zip">
	</CFCASE>
	<CFCASE value="Region">
		<CFSET sql_Sort_By="dbo.Service_Regions.Region_Name">
	</CFCASE>
	<CFCASE value="Zone">
		<CFSET sql_Sort_By="dbo.Service_Zones.Zone_Name">
	</CFCASE>
</CFSWITCH>

<CFSET sql_Sort_By_Order=" ASC">
<CFIF Form.sort_Order EQ "DESC">
	<CFSET sql_Sort_By_Order=" DESC">
</CFIF>

<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->
<!--- search by program --->
<cfif listlen(trim(form.LoadProductsFromThesePrograms)) GT 0>
	<cfset FORM.Zone_ID = "0">
	<cfset FORM.Region_ID = "0">
	<cfset FORM.Line_Of_Biz = "0">
	<cfset FORM.searchstring = "">
	<cfset FORM.Broker_Status = "0">
</cfif>

	<CFSET form.searchstring = trim(form.searchstring)>

	<cfif appsettings.getRemoveBrokerSelection() EQ 0 AND Form.DOSEARCH IS 1>
		<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
		SELECT       Distinct Broker_Name, ''' + Broker_Name + ''' As Broker,
		<!--- Some clients may not have value in Broker_legcy_Shard, in that case use Broker_Shard --->
					CASE WHEN ISNULL(Broker_legcy_Shard, '') <> '' THEN Broker_legcy_Shard
					ELSE Broker_Shard
					END as Broker_ID,
					CASE WHEN ISNULL(Broker_legcy_Shard, '') <> '' THEN 'Broker_legcy_Shard'
					ELSE 'Broker_Shard'
					END as Use_Broker_ID_Field,
					Address,City,State,Zip
		FROM         dbo.BSA_Foodservice_Brokers Br
	    
	  where Br.deleted = 0
	  And   Br.Service_Region_ID is not null
	  And   Br.Service_Zone_ID is not null
			<CFIF FORM.Broker_Status NEQ 0>
				AND Br.Active_Code = '#FORM.Broker_Status#'
			</CFIF>

			<CFIF FORM.Zone_ID NEQ 0>
				AND
				Br.Service_Zone_ID = '#FORM.Zone_ID#'
			</CFIF>

			<CFIF FORM.Region_ID NEQ 0>
				AND
				Br.Service_Region_ID = '#FORM.Region_ID#'
			</CFIF>

			<CFIF FORM.Line_Of_Biz NEQ 0>
				AND
				Br.Line_Of_Business_ID = '#FORM.Line_Of_Biz#'
			</CFIF>

			<CFIF len(trim(FORM.searchstring)) GT 0>
			AND
			(
				(
					Br.Broker_Name = '#form.searchstring#'
					OR
					Br.Broker_Name LIKE '%#form.searchstring#'
					OR
					Br.Broker_Name LIKE '#form.searchstring#%'
					OR
					Br.Broker_Name LIKE '%#form.searchstring#%'
				)
			)
			</CFIF>

	      <cfif form.businessSegmentsOn eq 1 and form.Business_Segment_ID neq 0>
		AND	br.Business_Segment_ID = #form.Business_Segment_ID#
      </cfif>
	 <cfif listlen(trim(form.LOADPRODUCTSFROMTHESEPROGRAMS)) GT 0>
			and
			br.BSA_Foodservice_Brokers_ID IN(SELECT BSA_Foodservice_Brokers_ID FROM Contract_Brokers WHERE Contract_Main_ID IN(#form.LOADPRODUCTSFROMTHESEPROGRAMS#))
	</cfif>
			ORDER BY  #ReplaceNoCase(sql_Sort_By, "dbo.BSA_Foodservice_Brokers","Br")#  #sql_Sort_By_Order#
		</CFQUERY>
	<cfelse>
		<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
				SELECT 	BSA_Foodservice_Brokers.*, '' AS Zone_Name, '' AS Region_Name,
				<!--- Some clients may not have value in Broker_legcy_Shard, in that case use Broker_Shard --->
						CASE WHEN ISNULL(Broker_legcy_Shard, '') <> '' THEN Broker_legcy_Shard
						ELSE Broker_Shard
						END as Broker_ID,
						CASE WHEN ISNULL(Broker_legcy_Shard, '') <> '' THEN 'Broker_legcy_Shard'
						ELSE 'Broker_Shard'
						END as Use_Broker_ID_Field
				FROM 	Contract_Distributors
				INNER JOIN BSA_Foodservice_Customers
					ON Contract_Distributors.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
				INNER JOIN BSA_Foodservice_Brokers
					ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID
				WHERE 	Contract_Distributors.Contract_Main_ID = <cfqueryparam value="#cryp.value#" cfsqltype="cf_sql_integer">
				AND Contract_Distributors.Deleted = 0
				AND BSA_Foodservice_Brokers.Deleted = 0
		</CFQUERY>
	</cfif>
	
	</cfsilent>
	<SCRIPT>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			function CA() {
				if(<CFIF TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many brokers in the list below while selecting them all. Press OK if you wish to continue")<CFELSE>0==0</CFIF>) {
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
			var SelObj = document.all.sort_by;
			var next_Index = Get_Select_Index(SelObj, sortVal);
			if(next_Index >=0)
			{
				SelObj.selectedIndex = next_Index;
				SelObj = document.all.sort_Order;
				SelObj.selectedIndex = Get_Select_Index(SelObj, sortOrder);
				document.MyForm.submit();
			}
		}
	</SCRIPT>
	<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
	<BR>
	<cfif appSettings.getFlexBrokerSearch() eq 0>
	<Div id="dvSearchResults" style="display:block;">
	<cfelse>
	<Div id="dvSearchResults" style="display:none;">
	</cfif>
	<FIELDSET STYLE="padding:8px; width: 600px; border: 1px solid Blue;display:table;">
	    <cfoutput>
		<cfif appsettings.getRemoveBrokerSelection()>
			<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF TheQuery.recordcount EQ 1>is<CFELSE>are</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1>#lcase(application.returned_customer_setting.broker_label_singular)#<CFELSE>#lcase(application.returned_customer_setting.broker_label_plural)#</CFIF> that <CFIF TheQuery.recordcount EQ 1>matched<CFELSE>match</CFIF> the program #lcase(application.returned_customer_setting.distributor_label_plural)#</LEGEND>
		<cfelse>
			<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF TheQuery.recordcount EQ 1>is<CFELSE>are</CFIF>
			<CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT>
			<CFIF TheQuery.recordcount EQ 1>#lcase(application.returned_customer_setting.broker_label_singular)#
			<CFELSE>#lcase(application.returned_customer_setting.broker_label_plural)#</CFIF> that
			<CFIF TheQuery.recordcount EQ 1>matched<CFELSE>match</CFIF> the above criteria</LEGEND>
		</cfif>
		</cfoutput>

		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF TheQuery.recordcount GT 0>
			<TABLE border="0" cellspacing="0" cellpadding="5" align="center" WIDTH="775" CLASS="Maintable">
				<TR ID="header" BGCOLOR="#ffce84" VALIGN="top">
					<TD align="center"><cfif NOT variables.bHideFromLSAutoPay>
											<INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Brokers">
										<cfelse>
											&nbsp;<cfset FORM.FinalItemList = "">
										</cfif>
					</TD>

					<cfif appsettings.getRemoveBrokerSelection() EQ 0>
						<CFSET Header_Display_List = "#application.returned_customer_setting.broker_label_singular# Name:ID,Address">
						<CFSET Header_Value_List = "Name:ID,Address">
					<cfelse>
	 					<CFSET Header_Display_List = "#application.returned_customer_setting.broker_label_singular# Name:ID,Address">
						<CFSET Header_Value_List = "Name:ID,Address">
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
							<!------<BR>----->/
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
							<A HREF="void(0);" onClick="javaScript:return setThisSortItem('#Next_Sort_Item#', '#Next_Sort_Order#');">
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
					<!---
					<cfoutput>
						<TD align="left" NOWRAP ID="header">
							<B>#application.returned_customer_setting.broker_label_singular# Name / ID</B>
						</TD>
					</cfoutput>
						<TD align="left" ID="header">
							<B>Address</B>
						</TD>
					<cfoutput>
						<TD align="left" ID="header">
							<B>#application.returned_customer_setting.region_label_singular# / #application.returned_customer_setting.zone_label_singular#</B>
						</TD>
					</cfoutput>
					--->
				</TR>

			<cfset theList = "" />
			<CFLOOP QUERY="TheQuery">
				<cfquery name="getAllReturnedBrokers" datasource="#application.datasource#">
				  Select BSA_Foodservice_Brokers_ID,Address,ADDRESS_2,City,State,Zip,Country_Code
				  From   BSA_Foodservice_Brokers
				  Where
					<cfif TheQuery.Use_Broker_ID_Field EQ "Broker_legcy_Shard">
					Broker_legcy_Shard = '#TheQuery.Broker_ID#'
					<cfelse>
					Broker_Shard = '#TheQuery.Broker_ID#'
					</cfif>
				  AND deleted = 0
				</cfquery>
				<cfset theList = listAppend(theList,valueList(getAllReturnedBrokers.BSA_Foodservice_Brokers_ID),",") />
			</CFLOOP>

			<CFOUTPUT QUERY="TheQuery" startrow="#StartRow#" maxrows="#MaxRows#">
			<cfquery name="getTheseBrokers" datasource="#application.datasource#">
			  Select BSA_Foodservice_Brokers_ID,Address,ADDRESS_2,City,State,Zip,Country_Code
			  From   BSA_Foodservice_Brokers
			  Where  
				<cfif TheQuery.Use_Broker_ID_Field EQ "Broker_legcy_Shard">
				Broker_legcy_Shard = '#TheQuery.Broker_ID#'
				<cfelse>
				Broker_Shard = '#TheQuery.Broker_ID#'
				</cfif>
				AND deleted = 0
			</cfquery>
				<cfloop query="getTheseBrokers">
					<cfset brokerList = valueList(getTheseBrokers.BSA_Foodservice_Brokers_ID)>
				</cfloop>

			 	<CFSET ID = getTheseBrokers.BSA_Foodservice_Brokers_ID />
				<!--- <cf_cryp string="#TheQuery.BSA_Foodservice_Brokers_ID#" type="en" key="#request.key#"> --->

				<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
					<TD align="center">
						<cfif NOT variables.bHideFromLSAutoPay>
							<INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#brokerList#" style="cursor: pointer;"
								<CFIF listfind(FORM.FinalItemList, trim(getTheseBrokers.BSA_Foodservice_Brokers_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(getTheseBrokers.BSA_Foodservice_Brokers_ID), ",")></CFIF>
								<CFLOOP QUERY = "get_Auto_Broker">
				 					<CFIF ID EQ get_Auto_Broker.BSA_Foodservice_Brokers_ID>CHECKED <cfif appsettings.getRemoveBrokerSelection() EQ 0>DISABLED</cfIF> </CFIF>
								</CFLOOP>
							>
						<cfelse>
							<INPUT TYPE="Radio" NAME="SelectedITEMS" VALUE="#brokerList#" style="cursor: pointer;">
						</cfif>
					</TD>
					<TD NOWRAP>#Broker_Name#</TD>
					<TD NOWRAP>#getTheseBrokers.Address#<BR><cfif len(trim(getTheseBrokers.address_2))>#getTheseBrokers.ADDRESS_2#<BR></cfif>#getTheseBrokers.City#,#getTheseBrokers.State# #getTheseBrokers.Zip#&nbsp;#getTheseBrokers.Country_Code#</TD>
				</TR>
			</CFOUTPUT>
			</TABLE>

			<HR COLOR="Orange" SIZE="2" width="775">
			<DIV ALIGN="center" STYLE="font-size: 12px; color: Red;width:775">
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
			<HR COLOR="Orange" SIZE="2" width="775">
		</CFIF>
	</FIELDSET>

</CFIF>

	<CFPARAM name="TheQuery.Recordcount" default="0">
	<SCRIPT>
		function resetform() {
			document.all.LoadProductsFromThesePrograms.value = "";
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

		findselectboxes();
	</SCRIPT>
<cfoutput>
<INPUT TYPE="hidden" NAME="Business_Segment_ID" VALUE="#FORM.Business_Segment_ID#">
<INPUT TYPE="hidden" NAME="businessSegmentsOn" VALUE="#form.businessSegmentsOn#">
<INPUT TYPE="hidden" NAME="FinalItemList" VALUE="#Form.FinalItemList#">
<INPUT TYPE="hidden" NAME="AlreadySelectedItems" VALUE="#Form.AlreadySelectedItems#">
<INPUT TYPE="hidden" NAME="finishedselectingitems" VALUE="0">
<INPUT TYPE="hidden" NAME="LoadSavedBrokers" VALUE="0">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
<input type="hidden" name="button_caption" value="#FORM.Button_Caption#">
<INPUT TYPE="Hidden" NAME="LoadProductsFromThesePrograms"  		VALUE="#form.LoadProductsFromThesePrograms#">
</cfoutput>
</FORM>

<cfif TheQuery.recordcount GT 0>
	<FIELDSET STYLE="padding:8px; width: 800; border: none;">
	<DIV ALIGN="center">
		<FONT SIZE="2">
			<B><FONT COLOR="#FF0000">[</FONT>
			<a HREF="#" onClick="javascript: finishedSearching()"> import selected <cfoutput>#lcase(application.returned_customer_setting.broker_label_plural)#</cfoutput> </a>
			<FONT COLOR="#FF0000">]</FONT></B>
		</FONT>

		<FONT SIZE="2">
			<B><FONT COLOR="#FF0000">[</FONT>
			<a HREF="#" STYLE="cursor: pointer;" onClick="importAllProducts(<CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT>)"> import all returned <cfoutput>#lcase(application.returned_customer_setting.broker_label_plural)#</cfoutput> </a>
			<FONT COLOR="#FF0000">]</FONT></B>
		</FONT>

		<FONT SIZE="2">
			<B><FONT COLOR="#FF0000">[</FONT>
			<a HREF="#" STYLE="cursor: pointer;" onClick="removeAllProducts()"> remove all selected <cfoutput>#lcase(application.returned_customer_setting.broker_label_plural)#</cfoutput> </a>
			<FONT COLOR="#FF0000">]</FONT></B>
		</FONT>
	</DIV>
	</FIELDSET>
	<BR>
</cfif>
</Div> <!--- end dvSearchResults --->
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
					document.MyForm.FinalItemList.value 	= document.MyForm.FinalItemList.value + "," + "<CFOUTPUT>#theList#</CFOUTPUT>";
				}
				else{
					document.MyForm.FinalItemList.value 	= "<CFOUTPUT>#theList#</CFOUTPUT>";
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
				document.MyForm.submit();
			}
			else
			{

			}
		}

		function finishedSearching() {
			document.all.finishedselectingitems.value = 1;
			document.all.MyForm.submit();
		}
	</cfif>
</SCRIPT>

</BLOCKQUOTE></BLOCKQUOTE>
<cfif application.programlayout EQ 1></div></cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- delete other section --->
<cfset opdisbro.CID = URL.CID>
<cfinclude template="delete_op_dis_bro_include.cfm">
<!--- delete other section --->
