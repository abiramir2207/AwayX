<CFSET thisTemplate="#GetFileFromPath(GetCurrentTemplatePath())#">
<CFPARAM name="ListOfPositionsUnderSearchPosition" default="">
<CFPARAM name="ListOfPositionsUnderMine" default="">
<CFPARAM NAME="form.Show_Deleted" default="0">
<CFPARAM NAME="URL.bMarketPrice" default="0">
<CFPARAM NAME="FORM.bMarketPrice" default="#URL.bMarketPrice#">
<CFPARAM NAME="URL.Template_Filters_Id" default="0">
<CFPARAM NAME="FORM.Template_Filters_Id" default="#URL.Template_Filters_Id#">
<CFPARAM NAME="URL.DoSearchOnLoad" default="1">
<CFPARAM NAME="FORM.DoSearchOnLoad" default="#URL.DoSearchOnLoad#">
<CFPARAM NAME="URL.Template_Id" default="0">
<CFPARAM NAME="FORM.Template_Id" default="#URL.Template_Id#">
<CFPARAM NAME="URL.Position_Level" default="0" />
<CFPARAM NAME="FORM.Position_Level" default="#URL.Position_Level#" />

<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>

<CFIF isdefined("URL.FormName")>
	<CFPARAM NAME="URL.AllowImportAll"				Default="0">
	<CFPARAM NAME="URL.FieldName"					Default="User_Positions_ID">
	<CFPARAM NAME="url.showsearch" DEFAULT="1">
	<CFPARAM NAME="url.EnableListOfPositionsAboveMine" default="0">
	<CFPARAM NAME="url.Search_Level" default="-1">
	<CFPARAM NAME="url.contract_number" default="">

	<FORM ACTION="<CFOUTPUT>#thisTemplate#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm">
		<INPUT NAME="ParentFormname" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.FormName#</CFOUTPUT>">
		<INPUT NAME="FieldName" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.FieldName#</CFOUTPUT>">
		<INPUT NAME="FinalItemList" TYPE="HIDDEN" VALUE="">
		<INPUT NAME="AllowImportAll" TYPE="HIDDEN" VALUE="<CFOUTPUT>#URL.AllowImportAll#</CFOUTPUT>">
		<INPUT NAME="showsearch" TYPE="HIDDEN" VALUE="<CFOUTPUT>#URL.showsearch#</CFOUTPUT>">
		<INPUT NAME="SelectSingleSearchResultOnly" TYPE="HIDDEN" VALUE="0">
		<INPUT NAME="EnableListOfPositionsAboveMine" TYPE="HIDDEN" VALUE="<CFOUTPUT>#url.EnableListOfPositionsAboveMine#</CFOUTPUT>">
		<INPUT NAME="Search_Level" TYPE="HIDDEN" VALUE="<CFOUTPUT>#url.Search_Level#</CFOUTPUT>">
		<INPUT NAME="Disable_Position_List" TYPE="HIDDEN" VALUE="">
		<INPUT NAME="bMarketPrice" TYPE="HIDDEN" VALUE="<CFOUTPUT>#FORM.bMarketPrice#</CFOUTPUT>">
		<INPUT NAME="Template_Filters_Id" TYPE="HIDDEN" VALUE="<CFOUTPUT>#FORM.Template_Filters_Id#</CFOUTPUT>">
		<INPUT NAME="DoSearchOnLoad" TYPE="HIDDEN" Value="<cfoutput>#FORM.DoSearchOnLoad#</cfoutput>" />
		<INPUT NAME="Template_Id" TYPE="HIDDEN" VALUE="<CFOUTPUT>#FORM.Template_Id#</CFOUTPUT>">
		<INPUT NAME="Position_Level" TYPE="HIDDEN" VALUE="<CFOUTPUT>#FORM.Position_Level#</CFOUTPUT>">
		<INPUT NAME="program_id" TYPE="HIDDEN" VALUE="<CFOUTPUT>#url.contract_number#</CFOUTPUT>">
	</FORM>
	<cfif NOT FORM.bMarketPrice>
		<script>
			if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT> != null){
				this.document.all.FinalItemList.value = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.<CFOUTPUT>#URL.FieldName#</CFOUTPUT>.value
				var Search_Info_Form = window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>;
				if(Search_Info_Form.SelectSingleSearchResultOnly_Position)
				{
					this.document.all.SelectSingleSearchResultOnly.value = Search_Info_Form.SelectSingleSearchResultOnly_Position.value;
				}
				if(Search_Info_Form.EnableListOfPositionsAboveMine)
				{
					this.document.all.EnableListOfPositionsAboveMine.value = Search_Info_Form.EnableListOfPositionsAboveMine.value;
				}
				if(Search_Info_Form.Disable_Position_List)
				{
					this.document.all.Disable_Position_List.value = Search_Info_Form.Disable_Position_List.value;
				}
				document.all.MyForm.submit()
			}
			else{
				alert("The Data Needed From The Parent Form Isnt Available.This Window Will Close!")
				window.close()
			}
		</script>
	<cfelse>
		<cfscript>
			objPositionFilterManager = CreateObject("component","mvc.Models.Template.UserPositionFilterManager");
			theList = objPositionFilterManager.getUserPositionFilterList(Form.Template_Filters_Id);
		</cfscript>
		<script>
			this.document.all.FinalItemList.value = <cfoutput>'#theList#'</cfoutput>;
			document.all.MyForm.submit();
		</script>

	</cfif>

	<cfabort>
</CFIF>


<CFSET PAGE_TITLE="Select User Positions">
<CFSET GROUP="Common">


<CFPARAM name="FORM.button_caption"					default="continue">
<CFPARAM NAME="FORM.searchstring" 					DEFAULT="">
<CFPARAM NAME="FORM.SelectedITEMS" 					DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" 					DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" 			DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingitems" 		DEFAULT="0">
<CFPARAM NAME="FORM.LoadSavedResults"				Default="1">
<CFPARAM NAME="FORM.SelectSingleSearchResultOnly"	Default="0">
<CFPARAM NAME="FORM.AllowImportAll"					Default="0">
<CFPARAM NAME="FORM.showsearch"					Default="1">
<CFPARAM NAME="FORM.EnableListOfPositionsAboveMine" 	DEFAULT="0">
<CFPARAM NAME="FORM.Search_Level" 					DEFAULT="-1">
<CFPARAM NAME="FORM.Disable_Position_List" 			DEFAULT="">


<CFIF FORM.SelectSingleSearchResultOnly EQ 1>
	<CFSET FORM.AllowImportAll = 0>
</CFIF>

<CFPARAM NAME="startrow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<cf_Number_of_Rows maxrows=10>


<CFSET FORM.LoadSavedResults=0>

<CFSET listofitemstodelete = "">

<CFLOOP INDEX="ListItem" LIST="#FORM.AlreadySelectedItems#" DELIMITERS=",">
	<CFIF listfind(FORM.SelectedITEMS, ListItem, ",") EQ 0>
		<CFSET listofitemstodelete = listappend(listofitemstodelete, ListItem, ",")>
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="ListItem" LIST="#FORM.SelectedITEMS#" DELIMITERS=",">
	<CFIF listfind(Form.FinalItemList, ListItem, ",") EQ 0>
		<CFIF FORM.SelectSingleSearchResultOnly eq 1>
			<CFSET Form.FinalItemList = ListItem>
		<CFELSE>
			<CFSET Form.FinalItemList = ListAppend(Form.FinalItemList, ListItem, ",")>
		</CFIF>
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
	<CFIF listfind(FORM.FinalItemList,ListItem, ",") GT 0>
		<CFSET Form.FinalItemList = listdeleteat(FORM.FinalItemList, listfind(FORM.FinalItemList,ListItem, ","), ",")>
	</CFIF>
</CFLOOP>

<CFIF FORM.finishedselectingitems EQ 1>
	<cfif NOT FORM.bMarketPrice>
		<script>
			opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.<CFOUTPUT>#Form.FieldName#</CFOUTPUT>.value = '<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>'
			opener.document.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.submit();
			window.close()
		</script>
		<CFABORT>
	<cfelse>
		<cfparam name="form.bPositionFilterContinue" type="boolean" default="0"/>
		<cfscript>
			objPositionFilterManager = CreateObject("component","mvc.Models.Template.UserPositionFilterManager");
			theCount = objPositionFilterManager.setUserPositionFilterList(Form.Template_Filters_Id,Form.FinalItemList);
		</cfscript>
		<script>
			parent.document.getElementById('dvPosFilter').innerHTML = 'SAVED: ' + <cfoutput>#theCount#</cfoutput> + ' records';
		</script>
		<!--- If save and continue is clicked --->
		<cfif Form.bPositionFilterContinue>
			<cfset filterPageName = 'positions' />
			<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
			<cfset template = templateManager.get(form.Template_Id)>
			<cfset ID = form.Template_Id/>
			<cfset form.rdoFilter = form.Template_Filters_id />
			<!--- <cfinclude template="/program_wizard/filter/filter_page_List.cfm" />
			<cfinclude template="/program_wizard/filter/filter_Next_Page.cfm" /> --->
		</cfif>
	</cfif>
</CFIF>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="20" TOPMARGIN="0">

<cfinclude template="/common_files/programTranslate.cfm">    <!--- french translation --->

<style>
TABLE.Maintable TD
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header
{
	font-size: 12px;
}
SELECT
{
 width: 190px;
}
</style>

<CFSET Input_Select_Width = 160>
<!---BJF D10171 more powerful reset for search criteria --->
<!---  initial user position--->
<cfset useLakebaseForgetUserPosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_position_holders")>
<cfif useLakebaseForgetUserPosition>
	<cftry>
		<cfset getUserPosition = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_position_holders", {
				"user_id" = "eq.#request.AccessStructure.user_id#",
				"deleted" = "eq.0",
				"select" = "user_positions_id"
			}), "user_positions_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserPosition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserPosition>
<CFQUERY NAME="getUserPosition" datasource="#application.datasource#">
	SELECT User_Positions_ID
	FROM User_Position_Holders
	WHERE User_ID = '#request.AccessStructure.user_id#' AND Deleted = 0
</CFQUERY>
</cfif>

<cfset useLakebaseForgetUserPrimaryPosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_position_holders")>
<cfif useLakebaseForgetUserPrimaryPosition>
	<cftry>
		<cfset getUserPrimaryPosition = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_position_holders", {
				"deleted" = "eq.0",
				"user_id" = "eq.#request.AccessStructure.user_id#",
				"user_position_type" = "eq.P",
				"select" = "user_positions_id"
			}), "user_positions_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserPrimaryPosition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserPrimaryPosition>
<CFQUERY NAME="getUserPrimaryPosition" datasource="#application.datasource#">
	SELECT User_Positions_ID
	FROM User_Position_Holders
	WHERE Deleted = 0
	AND  User_ID = '#request.AccessStructure.user_id#'
	AND User_Position_Type ='P'
</CFQUERY>
</cfif>

<SCRIPT LANGUAGE="JavaScript">
	function sortByThisItem(thisObj, thisSortItem, thisSortOrder)
	{
		var formObj;
		formObj = document.all.MyForm;
		formObj.sort_by.value = thisSortItem;
		formObj.sort_Order.value = thisSortOrder;
		formObj.submit();
		return false;
	}

	function reset_Form_Fields()
	{
		document.MyForm.reset();
		document.MyForm.Zone_ID.value='';
		document.MyForm.Region_ID.value='';
		document.MyForm.Market_ID.value='';
		document.MyForm.Label.value='';
		document.MyForm.Positions.value='<cfoutput>#getUserPrimaryPosition.User_Positions_ID#</cfoutput>';

	}


</SCRIPT>


<!--- <BR><B>
<FONT SIZE="2" COLOR="Red">[</FONT>
	<FONT SIZE="2" COLOR="Blue">
	<A HREF="" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Help">
	read me first
	</A>
</FONT>
<FONT SIZE="2" COLOR="Red">]</FONT>
</B> --->

<CFPARAM NAME="Form.sort_by" 	DEFAULT="Position_Label">
<CFPARAM NAME="Form.sort_Order" 	DEFAULT="ASC">


<FORM ACTION="<CFOUTPUT>#thisTemplate#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm" STYLE="DISPLAY:INLINE">
<CFOUTPUT>
<INPUT TYPE="HIDDEN" NAME="sort_Order" VALUE="#FORM.sort_Order#">
<INPUT TYPE="HIDDEN" NAME="sort_by" VALUE="#FORM.sort_by#">
</CFOUTPUT>

<CFPARAM NAME="Form.Zone_ID" 	DEFAULT="">
<CFPARAM NAME="Form.Region_ID" 	DEFAULT="">
<CFPARAM NAME="Form.Market_ID" 	DEFAULT="">
<CFPARAM NAME="Form.Label" 	DEFAULT="">
<CFPARAM NAME="Form.Positions" 	DEFAULT="#getUserPrimaryPosition.User_Positions_ID#">
<cfif showsearch EQ 1>
<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">user position search</LEGEND>
	<TABLE BORDER="0" CELLSPACING="2" CELLPADDING="0" BGCOLOR="WhiteSmoke">
		<TR VALIGN="TOP">
		<TD>
			<B><CFOUTPUT>#application.returned_customer_setting.zone_label_plural#</CFOUTPUT></B><BR>
			<CFQUERY NAME="GetZones" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Service_Zones
			WHERE 	len(Zone_Name) > 0 AND Deleted = 0
			<cfif NOT(FORM.Search_Level eq -1 or FORM.Search_Level gte 1)>
			AND		1=2
			</cfif>
			ORDER BY Zone_Name
			</CFQUERY>
			<SELECT NAME="Zone_ID" style="width: 200px;">
				<OPTION VALUE="">**ALL** <CFOUTPUT>#application.returned_customer_setting.zone_label_plural#</CFOUTPUT></OPTION>
				<OPTION VALUE="NULL"<CFIF FORM.Zone_ID EQ "NULL"> SELECTED</CFIF>>**NO** <CFOUTPUT>#application.returned_customer_setting.zone_label_singular#</CFOUTPUT></OPTION>
				<CFOUTPUT QUERY="GetZones"><OPTION VALUE="#trim(GetZones.Service_Zone_ID)#"#IIF(trim(FORM.Zone_ID) EQ GetZones.Service_Zone_ID, DE(" SELECTED"), DE(""))#>#trim(GetZones.Zone_Name)#</OPTION></CFOUTPUT>
			</SELECT>
		</TD>
		<TD>
			<B><CFOUTPUT>#application.returned_customer_setting.region_label_singular#</CFOUTPUT></B><BR>
			<CFQUERY NAME="GetRegions" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Service_Regions
			WHERE 	len(Region_Name) > 0 AND Deleted = 0
			<cfif NOT(FORM.Search_Level eq -1 or FORM.Search_Level gte 2)>
			AND		1=2
			</cfif>
			ORDER BY Region_Name
			</CFQUERY>
			<SELECT NAME="Region_ID" style="width: 200px;">
				<OPTION VALUE="">**ALL** <CFOUTPUT>#application.returned_customer_setting.region_label_plural#</CFOUTPUT></OPTION>
				<OPTION VALUE="NULL"<CFIF FORM.Region_ID EQ "NULL"> SELECTED</CFIF>>**NO** <CFOUTPUT>#application.returned_customer_setting.region_label_singular#</CFOUTPUT></OPTION>
				<CFOUTPUT QUERY="GetRegions"><OPTION VALUE="#trim(GetRegions.Service_Region_ID)#"#IIF(trim(FORM.Region_ID) EQ getRegions.Service_Region_ID, DE(" SELECTED"), DE(""))#>#trim(GetRegions.Region_Name)#</OPTION></CFOUTPUT>
			</SELECT>
		</TD>
		<TD>
			<B><CFOUTPUT>#application.returned_customer_setting.market_label_singular#</CFOUTPUT></B><BR>
			<CFQUERY NAME="GetMarkets" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Service_Markets
			WHERE 	len(Market_Name) > 0 AND Deleted = 0
			<cfif NOT(FORM.Search_Level eq -1 or FORM.Search_Level gte 3)>
			AND		1=2
			</cfif>
			ORDER BY Market_Name
			</CFQUERY>
			<SELECT NAME="Market_ID" style="width: 200px;">
				<OPTION VALUE="">**ALL** <CFOUTPUT>#application.returned_customer_setting.market_label_plural#</CFOUTPUT></OPTION>
				<OPTION VALUE="NULL"<CFIF FORM.Market_ID EQ "NULL"> SELECTED</CFIF>>**NO** <CFOUTPUT>#application.returned_customer_setting.market_label_singular#</CFOUTPUT></OPTION>
				<CFOUTPUT QUERY="GetMarkets"><OPTION VALUE="#trim(GetMarkets.Service_Market_ID)#"#IIF(trim(FORM.Market_ID) EQ GetMarkets.Service_Market_ID, DE(" SELECTED"), DE(""))#>#trim(GetMarkets.Market_Name)#</OPTION></CFOUTPUT>
			</SELECT>
		</TD>
		<TD VALIGN="bottom"><FONT COLOR="#ff0000">&nbsp;&nbsp;&nbsp;<B>[</B></FONT><A HREF="javascript: reset_Form_Fields();"><B>reset</B></A><FONT COLOR="ff0000"><B>]</B></FONT> </TD>
		</TR>
		<TR>
			<TD>
			<B>positions under</B><BR>
			<CFQUERY NAME="GetPositions" datasource="#application.datasource#">
			SELECT 	*
			FROM 	User_Positions
			WHERE 	len(Position_Label) > 0 AND Deleted = 0
				<cfswitch expression="#FORM.Search_Level#">
					<cfcase value="0"><!--- retrive hq positions only --->
				AND		User_Positions.Service_Zone_ID IS NULL
				AND		User_Positions.Service_Region_ID IS NULL
				AND		User_Positions.Service_Market_ID IS NULL
				</cfcase>
				<cfcase value="1"><!--- retrive zone level positions only --->
				AND		User_Positions.Service_Zone_ID IS NOT NULL
				AND		User_Positions.Service_Region_ID IS NULL
				AND		User_Positions.Service_Market_ID IS NULL
				</cfcase>
				<cfcase value="2"><!--- retrive region level positions only --->
				AND		User_Positions.Service_Zone_ID IS NOT NULL
				AND		User_Positions.Service_Region_ID IS NOT NULL
				AND		User_Positions.Service_Market_ID IS NULL
				</cfcase>
				<cfcase value="3"><!--- retrive market level positions only --->
				AND		User_Positions.Service_Zone_ID IS NOT NULL
				AND		User_Positions.Service_Region_ID IS NOT NULL
				AND		User_Positions.Service_Market_ID IS NOT NULL
				</cfcase>
				</cfswitch>
			ORDER BY Position_Label
			</CFQUERY>
			<SELECT NAME="Positions" style="width: 200px;">
				<OPTION VALUE=""></OPTION>
				<CFOUTPUT QUERY="GetPositions"><OPTION VALUE="#trim(GetPositions.User_Positions_ID)#"#IIF(trim(FORM.Positions) EQ GetPositions.User_Positions_ID, DE(" SELECTED"), DE(""))#>#trim(GetPositions.Position_Label)#</OPTION></CFOUTPUT>
			</SELECT>
			</TD>
			<TD COLSPAN="2">
			<B>Label</B><BR>
			<INPUT TYPE="TEXT" NAME="Label" VALUE="<CFOUTPUT>#Form.Label#</CFOUTPUT>" STYLE="WIDTH:400px">
			</TD>
			<TD COLSPAN="2" VALIGN="bottom">
			&nbsp;&nbsp;&nbsp;<B><FONT COLOR="FF0000">[</FONT><a HREF="#" ONCLICK="document.MyForm.startrow.value=1;document.MyForm.frompage.value=1;document.MyForm.submit();return false;">search position</a><FONT COLOR="FF0000">]</FONT></B>
			</TD>
		</TR>
		<tr>
		<td VALIGN="bottom">Include deleted positions</font> <input type="checkbox" name="Show_Deleted" value="1" <Cfif form.Show_Deleted EQ 1>checked</Cfif> ></td>
		<td valign="bottom" colspan="100%">&nbsp;</td>
		</tr>
	</TABLE>
</FIELDSET>
</cfif>

<CFPARAM NAME="FORM.DOSEARCH" 	DEFAULT="Yes">

<CFIF isdefined("FORM.DOSEARCH")>

<CFSET sql_Sort_By="User_Positions.Position_Label">
<!------Number,Title,Status,Program Type,Start Date,End date----->
<CFSWITCH expression="#LCase(Form.sort_by)#">
	<CFCASE value="label">
		<CFSET sql_Sort_By="Position_Label">
	</CFCASE>
	<CFCASE value="zone">
		<CFSET sql_Sort_By="Zone_Name">
	</CFCASE>
	<CFCASE value="region">
		<CFSET sql_Sort_By="Region_Name">
	</CFCASE>
	<CFCASE value="market">
		<CFSET sql_Sort_By="Market_Name">
	</CFCASE>
	<cfdefaultcase>
		<CFSET sql_Sort_By="Position_Label">
	</cfdefaultcase>
</CFSWITCH>


<CFSET sql_Sort_By_Order=" ASC">
<CFIF Form.sort_Order EQ "DESC">
	<CFSET sql_Sort_By_Order=" DESC">
</CFIF>
<CFSET sql_Sort_By="#sql_Sort_By# #sql_Sort_By_Order#">



<CFIF FORM.EnableListOfPositionsAboveMine EQ 0>
<!--- locate those positions underneath the supplied position --->
<CFSET GP_Supplied_Position = ValueList(getUserPosition.User_Positions_ID)>
<cfset getIDList = 1 />
<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">
<!--- list of positions underneath supplied --->
<CFSET ListOfPositionsUnderMine = GP_Position_List_From_My_Position_Down>


<CFSET ListOfPositionsUnderSearchPosition = "">
<CFIF FORM.Positions NEQ "">
	<CFSET GP_Supplied_Position = FORM.Positions>
	<cfset getIDList = 1 />
	<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">
	<!--- list of positions underneath supplied --->
	<CFSET ListOfPositionsUnderSearchPosition = GP_Position_List_From_My_Position_Down>
</CFIF>
</CFIF>


<cfset positionManager = CreateObject("component", "components.geography.position").init() />
<cfset MainQuery = positionManager.getPositions(sortBy = sql_Sort_By,ignoreDeletedFlag = form.Show_Deleted, Position_Level=FORM.Position_Level) />

<cfif (FORM.DoSearchOnLoad)>

	<CFQUERY NAME="TheQuery" DBTYPE="query">
		Select		Position_Label,
					User_Positions_ID,
					Zone_Name,
					Region_Name,
					Market_Name,
					Deleted
		From		MainQuery
		Where
					1=1
					<CFIF Form.Zone_ID EQ "NULL">
					AND	Service_Zone_ID IS NULL
					<CFELSEIF Form.Zone_ID NEQ "">
					AND	Service_Zone_ID = '#Form.Zone_ID#'
					</CFIF>
					<CFIF Form.Region_ID EQ "NULL">
					AND	Service_Region_ID IS NULL
					<CFELSEIF Form.Region_ID NEQ "">
					AND	Service_Region_ID = '#Form.Region_ID#'
					</CFIF>
					<CFIF Form.Market_ID EQ "NULL">
					AND	Service_Market_ID IS NULL
					<CFELSEIF Form.Market_ID NEQ "">
					AND	Service_Market_ID = #Form.Market_ID#
					</CFIF>
					<CFIF Form.Label NEQ "">
					AND	upper(Position_Label) LIKE '#ucase(Form.Label)#%' OR upper(Position_Label) LIKE '%#ucase(Form.Label)#' OR upper(Position_Label) LIKE '%#ucase(Form.Label)#%'
					</CFIF>
					<CFIF FORM.Positions NEQ "" AND FORM.EnableListOfPositionsAboveMine EQ 0>
					AND
					(
						1=2
						<CFIF Len(ListOfPositionsUnderSearchPosition) GT 0>
						<cfif	form.Show_Deleted IS NOT 1>
						OR
						User_Positions_ID IN (#ListOfPositionsUnderSearchPosition#)
						<cfelse>
						OR
							(
								User_Positions_ID IN (#ListOfPositionsUnderSearchPosition#)
								OR
								Deleted = 1
							)
						</cfif>
						</CFIF>
					)
					</CFIF>
					<cfswitch expression="#FORM.Search_Level#">
						<cfcase value="0"><!--- retrive hq level positions only --->
						AND		Service_Zone_ID IS NULL
						AND		Service_Region_ID IS NULL
						AND		Service_Market_ID IS NULL
						</cfcase>
						<cfcase value="1"><!--- retrive zone level positions only --->
						AND		Service_Zone_ID IS NOT NULL
						AND		Service_Region_ID IS NULL
						AND		Service_Market_ID IS NULL
						</cfcase>
						<cfcase value="2"><!--- retrive region level positions only --->
						AND		Service_Zone_ID IS NOT NULL
						AND		Service_Region_ID IS NOT NULL
						AND		Service_Market_ID IS NULL
						</cfcase>
						<cfcase value="3"><!--- retrive market level positions only --->
						AND		Service_Zone_ID IS NOT NULL
						AND		Service_Region_ID IS NOT NULL
						AND		Service_Market_ID IS NOT NULL
						</cfcase>
					</cfswitch>
		Order by	#sql_Sort_By#
	</CFQUERY>
<cfelse>
	<CFQUERY NAME="TheQuery" DBTYPE="query">
		SELECT Position_Label,
					User_Positions_ID,
					Zone_Name,
					Region_Name,
					Market_Name,
					Deleted
		FROM	MainQuery
		WHERE	1= 2
	</cfquery>
</cfif>

<CFQUERY NAME="All_List" DBTYPE="query">
	Select		User_Positions_ID
	From		TheQuery
	<CFIF FORM.EnableListOfPositionsAboveMine EQ 0>
	Where
				1=2
				<CFIF Len(ListOfPositionsUnderMine) GT 0>
				OR
				User_Positions_ID IN (#ListOfPositionsUnderMine#)
				</CFIF>
	</CFIF>
</CFQUERY>


<CFQUERY NAME="Selected_List" DBTYPE="query">
	Select		Position_Label
	From		MainQuery
	Where
				1=2
				<CFIF Len(FORM.FinalItemList) Gt 0>
				OR
				User_Positions_ID IN (#FORM.FinalItemList#)
				</CFIF>
</CFQUERY>


	<BR>
	<CFSCRIPT>
	Border="Yes";
	BorderSize=1;
	BorderColor="Silver";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Navy";
	TitleFont="Arial";
	TitleSize=8;
	IsClosed="No";  // ngt
	WIDTH="100%";
	</CFSCRIPT>
	<CFSET Open_Layer_Caption = "currently selected positions">
	<CF_openLayer
		Border="#Border#"
		BorderSize="#BorderSize#"
		BorderColor="#BorderColor#"
		Image="#Image#"
		ImageOpen="#ImageOpen#"
		Title="#Open_Layer_Caption#"
		TitleClosed="#Open_Layer_Caption#"
		TitleTooltip="#Open_Layer_Caption#"
		TitleColor="#TitleColor#"
		TitleFont="#TitleFont#"
		TitleSize="#TitleSize#"
		IsClosed="#IsClosed#"
		Width="#width#">
			<CFIF Selected_List.recordcount GT 0>
				<TABLE border="0" cellspacing="1" cellpadding="2" align="left" WIDTH="685" BGCOLOR="white">
					<TR><CFoutput QUERY="Selected_List">
						<TD NOWRAP BGCOLOR="eeeeee">#Position_Label#</TD>
		 				<CFIF Selected_List.currentrow mod 3><CFELSE></TR><TR></CFIF>
					</CFoutput>
					</TR>
					 <tr>	<td></td></tr>
				</TABLE>
			<CFELSE>
				None
			</CFIF>
			<BR>
	</CF_openLayer>



	<SCRIPT>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			function CA(bcheckvalue) {
			if(arguments.length <= 0)
			{
				bcheckvalue = MyForm.allbox.checked;
			}
				if(<CFIF TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many positions in the list below while selecting them all. Press OK if you wish to continue")<CFELSE>0==0</CFIF>) {
					for (var i=0;i<MyForm.elements.length;i++)
						{
							var e = MyForm.elements[i];
							if ((e.name != 'allbox') && (e.type=='checkbox') && (e.name != 'ALLINCATEGORY')) {
								e.checked = bcheckvalue;
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
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF TheQuery.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1>Position<CFELSE>Positions</CFIF></LEGEND>
		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF TheQuery.recordcount GT 0>
		<CFIF form.showsearch NEQ 0>
			<TABLE border="0" cellspacing="0" cellpadding="3" align="center" WIDTH="685" CLASS="Maintable">

				<TR ID="header" BGCOLOR="#ffce84">
					<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
						<TD align="center"><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Programs"></TD>
					<CFELSE>
						<TD>&nbsp;</TD>
					</CFIF>
					<CFSET HeaderNameList="Label,#application.returned_customer_setting.zone_label_singular#,#application.returned_customer_setting.region_label_singular#,#application.returned_customer_setting.market_label_singular#">
					<cfoutput>
					<CFLOOP LIST="#HeaderNameList#" INDEX="this_Header" DELIMITERS=",">
					<CFSET sortImage="">
					<CFIF LCase(this_Header) EQ LCase(Form.SORT_BY)>
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
						<TD ID="header" align="left" nowrap WIDTH="25%"><A HREF="##" OnClick="javaScript: return sortByThisItem(this,'#this_Header#','#New_Sort_Order#');"><b>#this_Header#</b><CFIF Len(sortImage) GT 0> <IMG BORDER="0" SRC="/Images/#sortImage#"></CFIF></A></TD>
						</CFLOOP>
						</cfoutput>
				</TR>
			<BR>
			<CFOUTPUT QUERY="TheQuery" startrow="#StartRow#" maxrows="#MaxRows#">
				<CFSET Disable_This = false>
				<CFIF FORM.EnableListOfPositionsAboveMine EQ "0">
					<CFIF NOT ListFindNoCase(ListOfPositionsUnderMine, User_Positions_ID, ",") AND Form.Show_Deleted NEQ 1>
						<CFSET Disable_This = true>
					</CFIF>
				</CFIF>
				<CFIF ListFindNoCase(Disable_Position_List, User_Positions_ID, ",")>
					<CFSET Disable_This = true>
				</CFIF>
				<TR <CFIF Disable_This>BGCOLOR="silver"<CFELSE><CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF></CFIF>>
					<TD align="center">
						<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
							<CFIF Disable_This>
							<INPUT type="Checkbox" DISABLED>
							<CFELSE>
							<INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.User_Positions_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.User_Positions_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.User_Positions_ID), ",")></CFIF>>
							</CFIF>
						<CFELSE>
							<CFIF Disable_This>
							<INPUT type="Radio" DISABLED>
							<CFELSE>
							<INPUT type="Radio" NAME="SelectedITEMS" VALUE="#trim(TheQuery.User_Positions_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.User_Positions_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.User_Positions_ID), ",")></CFIF>>
							</CFIF>
						</CFIF>
					</TD>
					<TD NOWRAP>#TheQuery.Position_Label#&nbsp;</TD>
					<TD NOWRAP>#TheQuery.Zone_Name#&nbsp;</TD>
					<TD NOWRAP>#TheQuery.Region_Name#&nbsp;</TD>
					<TD NOWRAP>#TheQuery.Market_Name#&nbsp;</TD>
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
				addparams="">
			</DIV>



<CFELSEIF form.showsearch EQ 0>
	<TABLE border="0" align="center" WIDTH="685" CLASS="Maintable">
	<TR>
<CFOUTPUT QUERY="TheQuery" startrow="1" maxrows="#TheQuery.Recordcount#">

<TD width="33%">
<INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.User_Positions_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.User_Positions_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.User_Positions_ID), ",")></CFIF>>#TheQuery.Position_Label#&nbsp;</TD>
<CFIF TheQuery.currentrow mod 3><CFELSE></TR><TR></CFIF></CFOUTPUT>
</TR>
</TABLE>
</CFIF>

</CFIF>
</CFIF>
</FIELDSET>



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
<cfoutput>
	<INPUT TYPE="hidden" NAME="FieldName" 				VALUE="#FORM.FieldName#">
	<INPUT TYPE="hidden" NAME="ParentFormname" 			VALUE="#FORM.ParentFormname#">
	<INPUT TYPE="hidden" NAME="FinalItemList" 			VALUE="#Form.FinalItemList#">
	<INPUT TYPE="hidden" NAME="AlreadySelectedItems" 	VALUE="#Form.AlreadySelectedItems#">
	<INPUT TYPE="hidden" NAME="finishedselectingitems" 	VALUE="0">
	<INPUT TYPE="hidden" NAME="LoadSavedOperators" 		VALUE="0">
	<INPUT TYPE="Hidden" NAME="startrow" 				VALUE="#startrow#">
	<INPUT TYPE="Hidden" NAME="frompage" 				VALUE="#frompage#">
	<input type="hidden" name="button_caption" 			value="#FORM.Button_Caption#">
	<INPUT TYPE="HIDDEN" NAME="AllowImportAll" 			VALUE="#FORM.AllowImportAll#">
	<input type="hidden" id="bPositionFilterContinue" name="bPositionFilterContinue" value="0"/>
	<INPUT TYPE="HIDDEN" NAME="showsearch" 			VALUE="#FORM.showsearch#">
	<INPUT TYPE="HIDDEN" NAME="SelectSingleSearchResultOnly" 			VALUE="#FORM.SelectSingleSearchResultOnly#">
	<INPUT TYPE="HIDDEN" NAME="EnableListOfPositionsAboveMine" 			VALUE="#FORM.EnableListOfPositionsAboveMine#">
	<INPUT TYPE="HIDDEN" NAME="Search_Level" 			VALUE="#FORM.Search_Level#">
	<INPUT TYPE="HIDDEN" NAME="Disable_Position_List" 			VALUE="#FORM.Disable_Position_List#">
	<INPUT NAME="bMarketPrice" TYPE="HIDDEN" VALUE="#FORM.bMarketPrice#">
	<INPUT NAME="Template_Filters_Id" TYPE="HIDDEN" VALUE="#FORM.Template_Filters_Id#">
	<INPUT NAME="DoSearchOnLoad" TYPE="HIDDEN" Value="1" />
	<INPUT NAME="Template_Id" TYPE="HIDDEN" VALUE="#FORM.Template_Id#">
	<INPUT NAME="Position_Level" TYPE="HIDDEN" VALUE="#FORM.Position_Level#">

</cfoutput>
</FORM>
	<cfif TheQuery.recordcount GT 0>
	<DIV ALIGN="center">
	&nbsp;&nbsp;&nbsp;
	<FONT SIZE="2">
		<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" onClick="javascript: finishedSearching(); return false;"> import selected position<CFIF FORM.AllowImportAll EQ 1>s</CFIF> </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
		<CFIF FORM.AllowImportAll EQ 1>
		<FONT SIZE="2">
			<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: pointer;" onClick="importAllProducts(<CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT>); return false;"> import all returned positions </a><FONT COLOR="#FF0000">]</FONT></B>
		</FONT>
		<FONT SIZE="2">
			<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: pointer;" onClick="removeAllProducts(); return false;"> remove all selected positions </a><FONT COLOR="#FF0000">]</FONT></B>
		</FONT>
			</cfif>
		<cfif FORM.bMarketPrice>
			&nbsp;&nbsp;<CF_smallLink
				title = "Save and Continue"
				url = "##"
				parameters = "onClick=""javascript: document.getElementById('bPositionFilterContinue').value=1;finishedSearching(); return false;""">

		</cfif>
		<BR>
		</DIV>
	</cfif>


<SCRIPT>
	<cfif TheQuery.recordcount GT 0>
		function importAllProducts(recordcount){
			<!------//recordcount = <CFOUTPUT>#ListLen(whole_Product_List)#</CFOUTPUT>;----->
			if(parseInt(recordcount) == 1) pString = "Position";
			else pString = "Positions";

			if(confirm("Do you want to import all <CFOUTPUT>#All_List.RecordCount#</CFOUTPUT> records from your search?")){

	<CFIF form.showsearch NEQ 0>
				/* true or false based on browser - IE 10 and above or IE 9 and below.
				'1' as an argument below means "true". */
				document.all.allbox.checked = checkOrUncheckBeforeFireEvent(1);
				callfireEvent(document,document.all.allbox,'Click');
	</CFIF>
				document.MyForm.finishedselectingitems.value = 1;
				if(document.MyForm.FinalItemList.value.length > 0){
					document.MyForm.FinalItemList.value 	= document.MyForm.FinalItemList.value + "," + "<CFOUTPUT>#valuelist(All_List.User_Positions_ID)#</CFOUTPUT>";
				}
				else{
					document.MyForm.FinalItemList.value 	= "<CFOUTPUT>#valuelist(All_List.User_Positions_ID)#</CFOUTPUT>";
				}

				document.MyForm.submit();
			}
			else
			{

			}
		}

		function removeAllProducts(){

			if(confirm("By pressing OK all selected records will be unselected")){
			<CFIF form.showsearch NEQ 0>
				/* true or false based on browser - IE 10 and above or IE 9 and below.
				'0' as an argument below means "false". */
				document.all.allbox.checked = checkOrUncheckBeforeFireEvent(0);
				callfireEvent(document,document.all.allbox,'Click');
			<CFELSE>
				CA(false);
			</CFIF>
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
			document.all.finishedselectingitems.value = 1
			document.all.MyForm.submit();
		}
	</cfif>

</SCRIPT>

