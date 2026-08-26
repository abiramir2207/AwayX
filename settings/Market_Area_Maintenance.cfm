<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
<TITLE><CFOUTPUT>#ucase(application.returned_customer_setting.market_label_singular)# AREA MAINTENANCE</CFOUTPUT></TITLE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	.header {font-size: 12px;}
	.odd { background-color: #ffffff }
	.even { background-color: #C6FFC6 }
	.edit { margin-right:10px; }
	.add { margin-left:10px; }
</style>

</HEAD>
<BODY>
<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
<!-- Development Note: KAL - D6973 -->
<CFPARAM NAME="FORM.SORT_BY" 	DEFAULT="Market_Name">
<CFPARAM NAME="FORM.SORT_ORDER" 	DEFAULT="ASC">
<CFSET Sorting_Order = "#FORM.SORT_BY# #FORM.SORT_ORDER#">

<cfset useLakebaseForgetMarketAreas = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("service_markets")>
<cfif useLakebaseForgetMarketAreas>
	<cftry>
		<cfset getMarketAreas = application.oLakebase.toQuery(
			application.oLakebase.selectRows("service_markets", {
				"deleted" = "eq.0",
				"order" = "#sorting_order#.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetMarketAreas = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetMarketAreas>
<CFQUERY NAME="getMarketAreas" datasource="#application.datasource#">
	SELECT *
	FROM 	Service_Markets
	WHERE 	DELETED = 0
	ORDER BY #Sorting_Order#
</CFQUERY>
</cfif>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

	<SCRIPT>
		function addMarket()
		{
			if(NewMarketAreafrm.new_market_Area.value=='')
				{
					alert("Please make an entry.");
				}
				else{
					saveNewMarket();
				}
		}

		function deleteMarket(ID, displayString) {
			if(confirm("Press OK to Delete " + displayString)){
				document.all.deletedMArea.Market_Area_ID.value = ID;
				document.all.deletedMArea.submit();
			}
		}

		var editingInProgress = false;
		var oTDbackup         = {id:null, name:null, id_html:"", name_html:""};
		var oTDactivecell     = new Object();

		function editMarketArea(oTDwithstring, formattedText, Market_Number,Service_Region_ID){
			if(!editingInProgress){
				editingInProgress = true;
				oTDactivecell = oTDwithstring;
				oTDactiveRegionNumbercell = eval('document.all.Market_Number_'+oTDactivecell.getAttribute('Market_Area_ID'))
				var Funcname = "saveChanges(\'"+Market_Number+"\',\'"+Service_Region_ID+"\')";
				// save existing td literal string values prior to converting them to input tags
				oTDbackup.name      = oTDactivecell;
				oTDbackup.name_html = oTDactivecell.innerHTML;
				oTDbackup.id        = oTDactiveRegionNumbercell;
				oTDbackup.id_html   = oTDactiveRegionNumbercell.innerHTML;
				oTDactivecell.innerHTML = "<INPUT TYPE=\"TEXT\" NAME=\"UPDATED_MARKET_AREA_DESCRIPTION\" MARKET_AREA_ID=\""+oTDactivecell.getAttribute('Market_Area_ID')+"\" VALUE=\"" + formattedText + "\" SIZE=\"60\" MAXLENGTH=\"100\"><BR><FONT COLOR=\"Red\"><B>[</B></FONT><a onclick=\""+Funcname+"\"  STYLE=\"cursor: pointer;\"><B>save</B></a><FONT COLOR=\"Red\"><B>]</B></FONT>&nbsp;&nbsp;&nbsp;<FONT COLOR=\"Red\"><B>[</B></FONT><a onclick=\"restoreOldTD()\"  STYLE=\"cursor: pointer;\"><B>cancel</B></a><FONT COLOR=\"Red\"><B>]</B></FONT>"
				oTDactiveRegionNumbercell.innerHTML = "<input name=\"UPDATE_REGION_NUMBER\" <!--- DEV NOTE: DAA; D15469:: onkeyup=\"clenseText(this, '0213456789')\" --->  type=text size=15 maxlength=60 value=\""+oTDactiveRegionNumbercell.innerHTML+"\">"
			}
			else {
				if(confirm("Currently Another <cfoutput>#application.returned_customer_setting.market_label_singular#</cfoutput> Area Is Being Modified Press OK to Save Changes To It Or CANCEL To Edit The Selected <cfoutput>#application.returned_customer_setting.market_label_singular#</cfoutput> Area")) {
					saveChanges(Market_Number,Service_Region_ID);
				}
				else {
					restoreOldTD();
					editMarketArea(oTDwithstring, formattedText)
				}
			}
		}

		function restoreOldTD(){
			// restore existing td input tags back to literal string values
			oTDbackup.name.innerHTML = oTDbackup.name_html;
			oTDbackup.id.innerHTML   = oTDbackup.id_html;
			editingInProgress        = false;
		}

		function saveChanges(Market_Number,Service_Region_ID) {
			document.all.saveMAChanges.Market_Area_ID.value		=	document.all.UPDATED_MARKET_AREA_DESCRIPTION.getAttribute('MARKET_AREA_ID')
			document.all.saveMAChanges.New_Description.value	=	document.all.UPDATED_MARKET_AREA_DESCRIPTION.value
			document.all.saveMAChanges.Market_Number.value		=	document.all.UPDATE_REGION_NUMBER.value
			document.all.saveMAChanges.Service_Region_ID.value	=	Service_Region_ID
			// form submission takes time so hide the list to avoid multiple clickings & then display a saving message
			$('table.Maintable').hide();
		    noty( { text: "Saving changes...", layout:'center', type:'information' });
			document.all.saveMAChanges.submit();
		}

		function saveNewMarket(){
			if(trim(document.all.Market_Description.value).length == 0){
				document.all.newMarket.Market_Description.value 	=	document.all.new_market_Area.value;
				document.all.newMarket.Market_Number.value 	= trim(document.all.new_market_number.value);
				document.all.newMarket.submit();
			}
			else {
				alert("Enter Text In The <cfoutput>#application.returned_customer_setting.market_label_singular#</cfoutput> Area Name Box.")
			}
		}

		// Development Note: KAL - 06/05;  Added/Modified below lines: D6973
		function sortBy(sVal, sOrder)
		{
			var searchFrm = document.TheForm;
			searchFrm.SORT_BY.value = sVal;
			searchFrm.SORT_ORDER.value = sOrder;
			searchFrm.submit();
			return false;
		}
	</SCRIPT>
<cfset useLakebaseForlasteditedby = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("service_markets_last_edited_by_data")>
<cfif useLakebaseForlasteditedby>
	<cftry>
		<cfset lasteditedby = application.oLakebase.toQuery(
			application.oLakebase.selectRows("service_markets_last_edited_by_data", {
				"order" = "datestamp.desc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlasteditedby = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlasteditedby>
<CFQUERY NAME="lasteditedby" datasource="#application.datasource#" MAXROWS="1">
SELECT *
FROM Service_Markets_Last_Edited_By_Data
ORDER BY datestamp desc
</CFQUERY>
</cfif>

<CFIF lasteditedby.recordcount EQ 0>
<CFELSE>
	<cfset useLakebaseForgetUserName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetUserName>
	<cftry>
		<cfset getUserName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#lasteditedby.User_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserName>
<CFQUERY NAME="getUserName" datasource="#application.datasource#">
		SELECT *
		FROM _Users
		WHERE User_ID = '#lasteditedby.User_ID#'
	</CFQUERY>
</cfif>

	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated By &nbsp;<CFOUTPUT>#getUserName.Name_First# #getUserName.Name_Last#</CFOUTPUT> on <CFOUTPUT>#dateformat(lasteditedby.datestamp, 'm/d/yyy')#
	#timeformat(lasteditedby.datestamp, 'h:mm:ss TT')#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
</CFIF>
<br>
<SPAN CLASS="title2">Add New <cfoutput>#application.returned_customer_setting.market_label_singular#</cfoutput> Area</SPAN>
<hr COLOR="orange" WIDTH="100%" ALIGN="left">
<form name="NewMarketAreafrm">
<TABLE WIDTH="830" CELLPADDING="3" CELLSPACING="0">
	<TR BGCOLOR="#FFCE84" VALIGN="bottom">
		<TD class="header"><B><cfoutput>#application.returned_customer_setting.market_label_singular#</cfoutput> Area Name</B></TD>
		<TD class="header"><B><cfoutput>#application.returned_customer_setting.market_label_singular#</cfoutput> Number</B></TD>

	</TR>
	<TR>
		<TD STYLE="font-size: 10px;"><INPUT TYPE="text" NAME="new_market_Area" SIZE="60" MAXLENGTH="100"></TD>
		<TD STYLE="font-size: 10px;" align="left"><INPUT TYPE="text" NAME="new_market_number" SIZE="15" MAXLENGTH="60">
		<a class="add" onClick="addMarket();" STYLE="cursor: pointer;"><cfoutput>#application.util.string.actionLinkFormat2("add")#</cfoutput></a></TD>

	</TR>
</TABLE>
</form>

<SPAN CLASS="title2">Existing <cfoutput>#application.returned_customer_setting.market_label_singular#</cfoutput> Areas</SPAN>
<hr COLOR="orange" WIDTH="100%" ALIGN="left">
<cfsavecontent variable="variables.table_content">
<TABLE CLASS="Maintable" WIDTH="830" CELLPADDING="3" CELLSPACING="0">
<!--- Development Note: KAL - 06/2005;  Added/Modified below lines: D6973 --->
<CFOUTPUT>
	<!--- TABLE HEADERS --->
	<TR BGCOLOR="##FFCE84" VALIGN="bottom">
	<FORM ACTION="Market_Area_Maintenance.cfm" METHOD="post" NAME="TheForm" ID="TheForm">

		<INPUT TYPE="Hidden" NAME="SORT_BY" VALUE="#FORM.SORT_BY#">
		<INPUT TYPE="Hidden" NAME="SORT_ORDER" VALUE="#FORM.SORT_ORDER#">
		<CFSET Display_List = "#application.returned_customer_setting.market_label_singular# Area ##,#application.returned_customer_setting.market_label_singular# Area, ">
		<CFSET Sort_By_List = "Market_Number,Market_Name, ">
		<CFSET Item_Pos = 0 >
		<CFSET Counter = 0 >

		<CFLOOP LIST="#Sort_By_List#" INDEX="This_Header_Item">
			<CFSET This_Sort_Order = "ASC">
			<CFSET This_Img = "down_1.gif">
			<!--- Development Note: KAL - Used reverse direction for arrows
			as it gets changed below (reversed) before displaying --->

			<CFIF LCase(This_Header_Item) EQ LCase(FORM.SORT_BY)>
				<CFSET Counter = ListFindNoCase(Sort_By_List, This_Header_Item)>
				<CFIF FORM.SORT_ORDER EQ "ASC">
					<CFSET This_Sort_Order = "DESC">
					<CFSET This_Img = "up_1.gif">
				</CFIF>
			</CFIF>
			<CFSET Item_Pos = Item_Pos+1>
			<CFSET Sort_Header = ListGetAt(Display_List, Item_Pos, ",")>

			<TD class="header">
			<cfif Len(trim(Sort_Header)) GT 0>
				<A HREF="##" onClick="javaScript:return sortBy('#This_Header_Item#','#This_Sort_Order#');"><B>#Sort_Header#</B>
				 <CFIF Counter EQ Item_Pos ><IMG SRC="/Images/#This_Img#" BORDER="0"></CFIF></A>
			</cfif>&nbsp;
			</TD>
		</CFLOOP>
	</FORM>
	</TR>
</CFOUTPUT>
	<!--- TABLE DATA QUERY --->
	<CFOUTPUT QUERY="getMarketAreas">
		<!--- DATA OUTPUT --->
		<cfset variables.tr_class = (getMarketAreas.currentRow mod 2 ? "odd" : "even")>
		<TR class="#variables.tr_class#">
        	<!--- D17601 RBL [begin] 11/24/08 (removed 2 &nbsp; @ end of each form field values) --->
			<TD VALIGN="top" STYLE="font-size: 10px;" ID="Market_Number_#Service_Market_ID#" NOWRAP>#trim(getMarketAreas.Market_Number)#</TD>
			<TD width="70%" VALIGN="top" ID="MarketArea_#Service_Market_ID#" STYLE="font-size: 10px;" Market_Area_ID="#Service_Market_ID#" NOWRAP>#getMarketAreas.Market_Name#</TD>
            <!--- D17601 RBL [end] 11/24/08 --->
			<cfset clean_Market_Name = getMarketAreas.Market_Name />
			<cfset clean_Market_Name = Replace(clean_Market_Name, """", "\""") />
			<cfset clean_Market_Name = Replace(clean_Market_Name, "'", "\'") />
			<TD>
				<a class="edit" onClick="editMarketArea(document.all.MarketArea_#Service_Market_ID#, '#clean_Market_Name#','#Market_Number#','#Service_Region_ID#')" style="cursor:pointer;">#application.util.string.actionLinkFormat2("edit")#</a>
				<a onClick="deleteMarket(#Service_Market_ID#, '#clean_Market_Name#')" style="cursor:pointer;">#application.util.string.actionLinkFormat2("delete")#</a>
			</TD>
		</TR>
	</CFOUTPUT>
</TABLE>
</cfsavecontent>
<cfoutput>#application.util.string.compress( variables.table_content )#</cfoutput>

<FORM ACTION="Market_Area_Queries.cfm" METHOD="post" NAME="deletedMArea" ID="deletedMArea">
	<INPUT TYPE="Hidden" NAME="Market_Area_ID" VALUE="">
	<INPUT TYPE="Hidden" NAME="Delete" VALUE="1">
</FORM>
<FORM ACTION="Market_Area_Queries.cfm" METHOD="post" NAME="saveMAChanges" ID="saveMAChanges">
	<INPUT TYPE="Hidden" NAME="Market_Area_ID" VALUE="">
	<INPUT TYPE="Hidden" NAME="Market_Number" VALUE="">
	<INPUT TYPE="Hidden" NAME="Service_Region_ID" VALUE="">
	<INPUT TYPE="Hidden" NAME="New_Description" VALUE="">
	<INPUT TYPE="Hidden" NAME="Update" VALUE="1">
</FORM>
<FORM ACTION="Market_Area_Queries.cfm" METHOD="post" NAME="newMarket" ID="newMarket">
	<INPUT TYPE="Hidden" NAME="Market_Description" VALUE="">
	<INPUT TYPE="Hidden" NAME="Market_Number" value="">
	<INPUT TYPE="Hidden" NAME="Insert" VALUE="1">
</FORM>
<cfinclude template="/common_files/jQuery.cfm">
<script src="/script/javascript/jquery.noty.packaged.min.js"></script>
<cfinclude template="/common_files/focus.cfm">
</BODY>
</HTML>