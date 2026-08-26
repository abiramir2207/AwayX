<CFIF isdefined("URL.FormName")>
	<FORM ACTION="pm_select_brokers.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
		<INPUT NAME="ParentFormname" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.FormName#</CFOUTPUT>">
		<INPUT NAME="FinalItemList" TYPE="HIDDEN" VALUE="">
		<INPUT NAME="SelectSingleSearchResultOnly" TYPE="Hidden" VALUE="1">
	</FORM>
	<script>
		<CFOUTPUT>
		var parentForm = window.opener.document.all.#URL.FormName#;
		if(parentForm != null){
			this.document.all.FinalItemList.value = parentForm.Broker_List.value;
			if(parentForm.SelectSingleSearchResultOnly)
			{
				this.document.all.SelectSingleSearchResultOnly.value = parentForm.SelectSingleSearchResultOnly.value;
			}
			document.all.MyForm.submit();
		}
		else{
			alert("The Data Needed From The Parent Form Isnt Available.This Window Will Close!");
			window.close();
		}
		</CFOUTPUT>
	</script>
	<cfabort>
</CFIF>

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<CFSET PAGE_TITLE="Select Program Brokers">
<CFSET GROUP="Contracts">


<CFPARAM name="FORM.button_caption"					default="continue">
<CFPARAM NAME="FORM.searchstring" DEFAULT="">
<CFPARAM NAME="FORM.SelectedITEMS" DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingitems" DEFAULT="0">
<CFPARAM NAME="FORM.LoadSavedBrokers"	Default="1">
<CFPARAM NAME="FORM.SelectSingleSearchResultOnly"	Default="0">
<!---TSF: Label 9343 - Check to make sure that FORM.SelectSingleSearchResultOnly is numeric so the default param for FORM.AllowImportAll won't throw an error--->
<cfif not isNumeric(FORM.SelectSingleSearchResultOnly)>
	<cfset FORM.SelectSingleSearchResultOnly = 0 />
</cfif>
<CFPARAM NAME="FORM.AllowImportAll"	Default="#NOT FORM.SelectSingleSearchResultOnly#">

<CFPARAM NAME="startrow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<cf_Number_of_Rows maxrows=10>

	
<CFSET FORM.LoadSavedBrokers=0>

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
	<script>
		opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.Broker_List.value = '<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>'
		opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.submit()
		window.close()		
	</script>
	<CFABORT>
</CFIF>

<!------ Business Segemnts ----->
<cfparam name="form.Business_Segment_Id" 	default="">
<cfparam name="form.businessSegmentsOn" 	default="0">
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfif businessSegManager.isEnabled()>
	<cfset form.businessSegmentsOn = 1 />
	<cfset qGetBusSegments = businessSegManager.getActive(request.AccessStructure.User_ID) />
	<cfset form.Business_Segment_Id = ValueList(qGetBusSegments.Business_Segment_Id) />
</cfif>


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

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="3" TOPMARGIN="0">

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

<!------<CFINCLUDE TEMPLATE="contract_status_legend.cfm">----->

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
</SCRIPT>
	<!--- 
	<CFSET URL.Contract_Main_ID = FORM.Contract_Main_ID>
	<CFINCLUDE TEMPLATE="thin_contract_general_display.cfm">
	--->

<!------<cfinclude template="minimal_contract_info.cfm">----->


	<FORM ACTION="pm_select_brokers.cfm" METHOD="post" NAME="MyForm" ID="MyForm">

<BR><CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

	<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">broker search</LEGEND>
			<table>
				<TR>
					<TD COLSPAN="2"><!--- Zone --->
						<span ID="searchItemLabel">Zone</span><BR>
						<CFQUERY NAME="GetZones" datasource="#application.datasource#">
						SELECT *
						FROM Service_Zones
						WHERE len(Zone_Name) > 0
						<!--- If we open this page from the "Create Project" page --->
						 <cfif IsDefined("ParentFormName")>
							 <cfif ParentFormName eq 'PM_Create_Form'>
							 and deleted = 0
							 </cfif>
						 </cfif>
						 <cfif form.businessSegmentsOn>
								<cfif application.returned_customer_setting.customer_keyword NEQ "conagra" AND (isDefined("form.Business_Segment_ID") and form.Business_Segment_ID IS NOT 0)>
								and Business_segment_id IN (#FORM.BUSINESS_SEGMENT_ID#)
								</cfif>
							</cfif>
						ORDER BY Zone_Name
						</CFQUERY>
						<CFPARAM NAME="FORM.Zone_ID" DEFAULT="0">
						<SELECT NAME="Zone_ID" id="Zone_ID" style="width: 200px;"  onkeydown="if (event.keyCode == 13) doSearchNow();">
							<OPTION VALUE="0">**ALL** Zones</OPTION>
							<CFOUTPUT QUERY="GetZones"><OPTION VALUE="#trim(GetZones.Service_Zone_ID)#"#IIF(trim(FORM.Zone_ID) EQ GetZones.Service_Zone_ID, DE(" SELECTED"), DE(""))#>#trim(GetZones.Zone_Name)#</OPTION></CFOUTPUT>
						</SELECT>	
					</TD>
					<TD><!--- Regions --->
						<span ID="searchItemLabel">Region</span><BR>
						<CFQUERY NAME="GetRegions" datasource="#application.datasource#">
						SELECT *
						FROM Service_Regions
						WHERE len(Region_Name) > 0
						<!--- If we open this page from the "Create Project" page --->
							<cfif IsDefined("ParentFormName")>
							 <cfif ParentFormName eq 'PM_Create_Form'>
							 and deleted = 0
							 </cfif>
						  </cfif>
							<cfif form.businessSegmentsOn>
								<cfif application.returned_customer_setting.customer_keyword NEQ "conagra" AND (isDefined("form.Business_Segment_ID") and form.Business_Segment_ID IS NOT 0)>
								and Business_segment_id IN (#FORM.BUSINESS_SEGMENT_ID#)
								</cfif>
							</cfif>
						ORDER BY Region_Name
						</CFQUERY>
						<CFPARAM NAME="FORM.Region_ID" DEFAULT="0">
						<SELECT NAME="Region_ID" id="Region_ID" style="width: 200px;"  onkeydown="if (event.keyCode == 13) doSearchNow();">
							<OPTION VALUE="0">**ALL** Regions</OPTION>
							<CFOUTPUT QUERY="GetRegions"><OPTION VALUE="#trim(GetRegions.Service_Region_ID)#"#IIF(trim(FORM.Region_ID) EQ getRegions.Service_Region_ID, DE(" SELECTED"), DE(""))#>#trim(GetRegions.Region_Name)#</OPTION></CFOUTPUT>
						</SELECT>	
					</TD>
					
					<TD>
					<cfif application.returned_customer_setting.lob_search_switch EQ 1>
					<!--- Line Of Biz --->
						<span ID="searchItemLabel"><CFOUTPUT>#application.returned_customer_setting.lob_label_singular#</CFOUTPUT></span><BR>
						<cfquery name="GetLinesOfBiz" datasource="#application.datasource#">
							SELECT *
							FROM Line_Of_Business
							WHERE len(Line_Of_Business_Name) > 0
							<cfif form.businessSegmentsOn>
								<cfif application.returned_customer_setting.customer_keyword NEQ "conagra" AND (isDefined("form.Business_Segment_ID") and form.Business_Segment_ID IS NOT 0)>
								and Business_segment_id IN (#FORM.BUSINESS_SEGMENT_ID#)								
								</cfif>
							</cfif>
							ORDER BY Line_Of_Business_Name
						</cfquery>
						<CFSET First_Time = NOT Isdefined("FORM.Line_Of_Biz")>
						<CFPARAM NAME="FORM.Line_Of_Biz" DEFAULT="0">
						<SELECT NAME="Line_Of_Biz" id="Line_Of_Biz" style="width: 200px;" onkeydown="if (event.keyCode == 13) doSearchNow();">
							<OPTION VALUE="0">**ALL** <CFOUTPUT>#application.returned_customer_setting.lob_label_singular#</CFOUTPUT></OPTION>
							<CFOUTPUT QUERY="GetLinesOfBiz">
							<!--- Tim Ford - 07/16/2013: Label 38339 - Need to fix BB Payee Search for Brokers: Removed code so the LOB defaults to all
							<CFIF Line_Of_Business EQ "#ListFirst(application.returned_customer_setting.Line_Business_Default,",")#" AND First_Time>
								<CFSET FORM.Line_Of_Biz = GetLinesOfBiz.Line_Of_Business_ID>
							</CFIF>
							--->
							<OPTION VALUE="#trim(GetLinesOfBiz.Line_Of_Business_ID)#"#IIF(trim(FORM.Line_Of_Biz) EQ trim(GetLinesOfBiz.Line_Of_Business_ID), DE(" SELECTED"), DE(""))#>#trim(GetLinesOfBiz.Line_Of_Business_Name)#</OPTION></CFOUTPUT>
						</SELECT>		
					</CFIF>
					</TD>
					
					<TD ALIGN="Left"><!--- Active/Inactive --->
						<span ID="searchItemLabel">Status</span><BR>
						<CFPARAM NAME="FORM.Broker_Status" DEFAULT="A">
						<SELECT NAME="Broker_Status" id="Broker_Status" onkeydown="if (event.keyCode == 13) doSearchNow();">
							<option VALUE="A" <CFIF FORM.Broker_Status EQ "A">SELECTED</CFIF>>Active</option>
							<option VALUE="N" <CFIF FORM.Broker_Status EQ "N">SELECTED</CFIF>>Inactive</option>
							<option VALUE="V" <CFIF FORM.Broker_Status EQ "V">SELECTED</CFIF>>Valid</option>
							<option VALUE="I" <CFIF FORM.Broker_Status EQ "I">SELECTED</CFIF>>Invalid</option>
						</SELECT>
					</TD>							
				</TR>
				<TR>
					<TD NOWRAP ALIGN="left">
					Sort By<BR>
					<CFSET sort_By_List="Name,ID,Address,City,State,Postal Code,Region,Zone">
					<CFPARAM NAME="FORM.sort_by" DEFAULT="#Trim(ListFirst(sort_By_List))#">
					<CFOUTPUT>
					<CFSET sort_By_List=ListSort(sort_By_List,"Text")>
					<SELECT ID="sort_by" NAME="sort_by" onkeydown="if (event.keyCode == 13) doSearchNow();">
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
					<SELECT ID="sort_Order" NAME="sort_Order" onkeydown="if (event.keyCode == 13) doSearchNow();">
						<OPTION VALUE="ASC"<CFIF FORM.sort_Order EQ "ASC"> SELECTED</CFIF>>Ascending</OPTION>
						<OPTION VALUE="DESC"<CFIF FORM.sort_Order EQ "DESC"> SELECTED</CFIF>>Descending</OPTION>
					</SELECT>
					</TD>
					<TD NOWRAP ALIGN="left" COLSPAN="2">
						Name<BR>
						<INPUT TYPE="Text" NAME="searchstring" STYLE="WIDTH:405px" SIZE="64"<CFIF len(trim(FORM.searchstring)) GT 0>VALUE="<CFOUTPUT>#trim(FORM.searchstring)#</CFOUTPUT>"</CFIF> onkeydown="if (event.keyCode == 13) doSearchNow();">
					</TD>
					<!------<TD NOWRAP ALIGN="left">
						<BR>
						<INPUT TYPE="Submit" VALUE="search">
					</TD>----->
				
					<TD ALIGN="left" NOWRAP>
					<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10"><BR>
					<!--- &nbsp;&nbsp; --->
					<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript: return doSearchNow();">search brokers</a><FONT COLOR="#FF0000">]</FONT></B>
					<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript: reset_Form_Fields();">reset</a><FONT COLOR="#FF0000">]</FONT></B>
					</TD>
				
			</table>		
			
			
		<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">
	</FIELDSET>

	<script language="JavaScript">
	<cfoutput>
	function doSearchNow()
	{
		//add restricted search
		var oSearchForm = document.MyForm;
		var any_Filter = true;
		var availOptions = "";
		var LOBSwitchOn = "#application.returned_customer_setting.lob_search_switch#";
		
		if (LOBSwitchOn == 1)
		{
			if(oSearchForm.Line_Of_Biz.value != 0)
			{
				any_Filter = true;
			}
			availOptions = availOptions + "\n - #application.returned_customer_setting.lob_label_plural#";
		}
		else
		{
			any_Filter = true;
		}
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
	</script>
	
	<CFQUERY NAME="GetBrokerInfo" datasource="#application.datasource#">
		SELECT *
		FROM BSA_Foodservice_Brokers
		WHERE BSA_Foodservice_Brokers_ID <CFIF FORM.FinalItemList EQ 0>IS NULL<CFELSEIF listlen(FORM.FinalItemList) GT 0>IN(#listqualify(FORM.FinalItemList, "'", ",")#)<CFELSE>!= BSA_Foodservice_Brokers_ID</CFIF>
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
		Title="currently selected brokers"  
		TitleClosed="currently selected brokers"  
		TitleTooltip="Click here to toggle the view"  
		TitleColor="#TitleColor#"  
		TitleFont="#TitleFont#"
		TitleSize="#TitleSize#"
		IsClosed="#IsClosed#"
		Width="#width#">
	
			<CFIF GetBrokerInfo.recordcount GT 0>
				<TABLE border="0" cellspacing="3" cellpadding="3" align="left" WIDTH="700" BGCOLOR="white">
					<TR><CFOUTPUT QUERY="GetBrokerInfo">
						<TD NOWRAP BGCOLOR="eeeeee" STYLE="cursor: pointer;" onClick="NewWindow('/Profiles/Brokers/Broker_profile.cfm?BID=#GetBrokerInfo.BSA_Foodservice_Brokers_ID#','name','400','450','Yes', 'No');">#GetBrokerInfo.broker_name#</TD>
		 				<CFIF GetBrokerInfo.currentrow mod 4><CFELSE></TR><TR></CFIF>
					</CFOUTPUT>	
				</TABLE>
			<CFELSE>
				<CFIF FORM.FinalItemList EQ 0>ALL BROKERS<CFELSE>NONE</CFIF>
			</CFIF>
	</CF_openLayer>


<CFIF isdefined("FORM.DOSEARCH")>
<CFPARAM NAME="FORM.Line_Of_Biz" DEFAULT="0">
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

	<CFSET form.searchstring = trim(form.searchstring)>
	<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
		SELECT DISTINCT	
				--Service_Zones.Zone_Name AS Zone_Name, 
				--Service_Regions.Region_Name AS Region_name,
				BSA_Foodservice_Brokers.Broker_Name,
				--BSA_Foodservice_Brokers.Broker_Shard,
				BSA_Foodservice_Brokers.Broker_Legcy_Shard,
				BSA_Foodservice_Brokers.address,
				BSA_Foodservice_Brokers.address_2,
				BSA_Foodservice_Brokers.city,
				BSA_Foodservice_Brokers.state,
				BSA_Foodservice_Brokers.zip,
				BSA_Foodservice_Brokers.country_code
		FROM 	BSA_Foodservice_Brokers 
				<!--- D18678: Users should be able to search for payee who don't belong in the tree, we are adding a new profile switch that will enable users to search payee from any position --->
				<!--- when Get_Profile_Settings.BB_Add_Payee_Any_Position = 1 we will do a left join on region and zone --->	
				<cfif FORM.Broker_Status EQ "N" OR Get_Profile_Settings.BB_Add_Payee_Any_Position EQ 1>
				LEFT JOIN Service_markets ON Service_markets.Service_market_ID = BSA_Foodservice_Brokers.Service_market_ID
				LEFT JOIN dbo.Service_Regions ON dbo.Service_markets.Service_Region_ID = dbo.Service_Regions.Service_Region_ID 
				LEFT JOIN dbo.Service_Zones ON dbo.Service_Regions.Service_Zone_ID = dbo.Service_Zones.Service_Zone_ID
				<cfelse>
				INNER JOIN Service_markets ON Service_markets.Service_market_ID = BSA_Foodservice_Brokers.Service_market_ID
				INNER JOIN dbo.Service_Regions ON dbo.Service_markets.Service_Region_ID = dbo.Service_Regions.Service_Region_ID 
				INNER JOIN dbo.Service_Zones ON dbo.Service_Regions.Service_Zone_ID = dbo.Service_Zones.Service_Zone_ID
				</cfif> 
		WHERE	0 = 0
		
		<CFIF FORM.Zone_ID NEQ 0>
		AND 	BSA_Foodservice_Brokers.Service_Zone_ID = '#FORM.Zone_ID#'
		</CFIF> 
		
		<CFIF FORM.Region_ID NEQ 0>
		AND 	BSA_Foodservice_Brokers.Service_Region_ID = '#FORM.Region_ID#'
		</CFIF> 
		
		<CFIF FORM.Line_Of_Biz NEQ 0>
		AND 	BSA_Foodservice_Brokers.Line_Of_Business_ID = '#FORM.Line_Of_Biz#'
		</CFIF> 
		
		<CFIF FORM.Broker_Status EQ "A">						
		AND 	BSA_Foodservice_Brokers.Active_Code = 'A' AND BSA_Foodservice_Brokers.DELETED = 0
		<CFELSEIF FORM.Broker_Status EQ "N">	
		AND 	NOT(BSA_Foodservice_Brokers.Active_Code = 'A' AND BSA_Foodservice_Brokers.DELETED = 0)
		<CFELSEIF FORM.Broker_Status EQ "V">	
		AND 	BSA_Foodservice_Brokers.DELETED = 0
		<CFELSEIF FORM.Broker_Status EQ "I">	
		AND 	BSA_Foodservice_Brokers.DELETED = 1
		</CFIF>
		
		<CFIF len(trim(FORM.searchstring)) GT 0>
		AND
		(
			(
				BSA_Foodservice_Brokers.Broker_Name = 'form.searchstring'
				OR
				BSA_Foodservice_Brokers.Broker_Name LIKE '%#form.searchstring#'
				OR
				BSA_Foodservice_Brokers.Broker_Name LIKE '#form.searchstring#%'
				OR
				BSA_Foodservice_Brokers.Broker_Name LIKE '%#form.searchstring#%'
			)
		)
		</CFIF>
		
		--Order By dbo.BSA_Foodservice_Brokers.Broker_Name
		ORDER BY #sql_Sort_By# #sql_Sort_By_Order#
	</CFQUERY>
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
	</SCRIPT>	
	<BR>

	<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF TheQuery.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1>Broker<CFELSE>Brokers</CFIF> That <CFIF TheQuery.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Above Criteria</LEGEND>
		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF TheQuery.recordcount GT 0>
			<TABLE border="0" cellspacing="0" cellpadding="3" align="center" WIDTH="685" CLASS="Maintable">
				<TR ID="header" BGCOLOR="#ffce84">
					<CFIF FORM.SelectSingleSearchResultOnly EQ 0><TD align="center"><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Brokers"></TD><CFELSE><TD>&nbsp;</TD></CFIF>
					<cfoutput>
					<!--- DEV NOTE: DAA D16421
					<CFSET HeaderNameList = "Name / ID,Address,Region / Zone">
					<CFSET HeaderColumnList = "Name,Address,Region">
					 --->
					<CFSET HeaderNameList = "Name / ID,Address">
					<CFSET HeaderColumnList = "Name,Address">
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
						<TD ID="header" align="left"><A HREF="##" OnClick="javaScript: return sortByThisItem(this,'#listgetat(HeaderColumnList,Counter)#','#New_Sort_Order#');"><b>#this_Header#</b><CFIF Len(sortImage) GT 0> <IMG BORDER="0" SRC="/Images/#sortImage#"></CFIF></A></TD>
						<CFSET Counter = Counter + 1>
						</CFLOOP>
					</cfoutput>
<!--- 					<TD align="left" NOWRAP ID="header"><B>Name / ID</B></TD>
					<TD align="left" ID="header"><B>Address</B></TD>
					<TD align="left" ID="header"><B>Region / Zone</B></TD> --->
				</TR>
			
			<cfif listGetAt(Server.ColdFusion.ProductVersion,1,",") GTE 8>
				<cfajaximport tags="cfwindow"></cfajaximport>
			</cfif>
			
			<CFOUTPUT QUERY="TheQuery" startrow="#StartRow#" maxrows="#MaxRows#">
				<cfquery name="BrokerID" datasource="#application.datasource#">
					SELECT 	BSA_Foodservice_Brokers_ID
					FROM 	BSA_Foodservice_Brokers
					WHERE 	Broker_Name = '#TheQuery.Broker_Name#'
					AND		Broker_Legcy_Shard = '#TheQuery.Broker_Legcy_Shard#'
				</cfquery>
				
				<cf_cryp string="#BrokerID.BSA_Foodservice_Brokers_ID#" type="en" key="#request.key#">

				<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> style="cursor: pointer;">
					<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
						<TD align="center"><INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(BrokerID.BSA_Foodservice_Brokers_ID)#" <CFIF listfind(FORM.FinalItemList, trim(BrokerID.BSA_Foodservice_Brokers_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(BrokerID.BSA_Foodservice_Brokers_ID), ",")></CFIF>></TD>
					<CFELSE>
						<TD align="center"><INPUT type="Radio" NAME="SelectedITEMS" VALUE="#trim(BrokerID.BSA_Foodservice_Brokers_ID)#" <CFIF listfind(FORM.FinalItemList, trim(BrokerID.BSA_Foodservice_Brokers_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(BrokerID.BSA_Foodservice_Brokers_ID), ",")></CFIF>></TD>						
					</CFIF>
					
					<cfif listGetAt(Server.ColdFusion.ProductVersion,1,",") LT 8>
						<TD NOWRAP ONCLICK="NewWindow('/Profiles/Brokers/Broker_profile.cfm?BID=#BrokerID.BSA_Foodservice_Brokers_ID#','name','400','450','Yes', 'No');">#TheQuery.Broker_Name#<BR>#TheQuery.Broker_Legcy_Shard#&nbsp;</TD>
						<TD NOWRAP ONCLICK="NewWindow('/Profiles/Brokers/Broker_profile.cfm?BID=#BrokerID.BSA_Foodservice_Brokers_ID#','name','400','450','Yes', 'No');">#Address#<BR><cfif len(trim(address_2))>#ADDRESS_2#<BR></cfif>#City#,#State# #Zip#&nbsp;#Country_Code#</TD>
					<cfelse>
						<TD NOWRAP ONCLICK="ColdFusion.Window.create('Win#currentrow#','Broker Profile','/Profiles/Brokers/Broker_profile.cfm?BID=#BrokerID.BSA_Foodservice_Brokers_ID#',{height:450,width:400,modal:true,draggable:true,center:true,initshow:true});">#TheQuery.Broker_Name#<BR>#TheQuery.Broker_Legcy_Shard#&nbsp;</TD>
						<TD NOWRAP ONCLICK="ColdFusion.Window.create('Win1#currentrow#','Broker Profile','/Profiles/Brokers/Broker_profile.cfm?BID=#BrokerID.BSA_Foodservice_Brokers_ID#',{height:450,width:400,modal:true,draggable:true,center:true,initshow:true});">#Address#<BR><cfif len(trim(address_2))>#ADDRESS_2#<BR></cfif>#City#,#State# #Zip#&nbsp;#Country_Code#</TD>
					</cfif>
					<!--- DEV NOTE: DAA D16421 <TD NOWRAP ONCLICK="NewWindow('/Profiles/Brokers/Broker_profile.cfm?BID=#BrokerID.BSA_Foodservice_Brokers_ID#','name','400','450','Yes', 'No');">#TheQuery.Region_Name#<BR>#TheQuery.Zone_Name#&nbsp;</TD> --->
 				</TR>
			</CFOUTPUT>
			</TABLE>
			
			

			<DIV ALIGN="center" STYLE="font-size: 12px; color: Red;">
				<CF_Next_Previous_For_Forms
					formname="MyForm"
					query="TheQuery"
					maxpages="40"
					previous		=	"<IMG SRC='/images/previous.gif' ALIGN='middle' BORDER='0'>"
					next			=	"<IMG SRC='/images/next.gif' ALIGN='middle' BORDER='0'>"
					previousseries	=	"<IMG SRC='/images/previous_series.gif' ALIGN='middle' BORDER='0'>"
					nextseries		=	"<IMG SRC='/images/next_series.gif' ALIGN='middle' BORDER='0'>"
					addparams="">
			</DIV>

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
		
		//findselectboxes();
	</SCRIPT>
<INPUT TYPE="hidden" NAME="ParentFormname" 						VALUE="<CFOUTPUT>#FORM.ParentFormname#</CFOUTPUT>">	
<INPUT TYPE="hidden" NAME="FinalItemList" VALUE="<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="AlreadySelectedItems" VALUE="<CFOUTPUT>#Form.AlreadySelectedItems#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="finishedselectingitems" VALUE="0">
<INPUT TYPE="hidden" NAME="LoadSavedOperators" VALUE="0">
<INPUT TYPE="hidden" NAME="SelectSingleSearchResultOnly" VALUE="<CFOUTPUT>#Form.SelectSingleSearchResultOnly#</CFOUTPUT>">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="<CFOUTPUT>#startrow#</CFOUTPUT>">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="<CFOUTPUT>#frompage#</CFOUTPUT>">
<input type="hidden" name="button_caption" value="<CFOUTPUT>#FORM.Button_Caption#</CFOUTPUT>">
</FORM>
	<cfif TheQuery.recordcount GT 0>
	<DIV ALIGN="center">
	&nbsp;&nbsp;&nbsp;
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" onClick="javascript: finishedSearching()"> import selected broker<CFIF FORM.AllowImportAll EQ 1>s</CFIF> </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<CFIF FORM.AllowImportAll EQ 1>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: pointer;" onClick="importAllProducts(<CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT>)"> import all returned brokers </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: pointer;" onClick="removeAllProducts()"> remove all selected brokers </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<BR>	
	</DIV>
	</CFIF>
	</cfif> 


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
					document.MyForm.FinalItemList.value 	= document.MyForm.FinalItemList.value + "," + "<CFOUTPUT>#valuelist(BrokerID.BSA_Foodservice_Brokers_ID)#</CFOUTPUT>";
					<!------//document.SearchForm.FinalUPCList.value 	= document.SearchForm.FinalUPCList.value + "," + "<CFOUTPUT>#whole_Product_List#</CFOUTPUT>";
					//document.SearchForm.FinalUPCList.value 	= "<CFOUTPUT>#whole_Product_List#</CFOUTPUT>";----->
				}
				else{
					document.MyForm.FinalItemList.value 	= "<CFOUTPUT>#valuelist(BrokerID.BSA_Foodservice_Brokers_ID)#</CFOUTPUT>";
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
</SCRIPT>

