<!-- Development Note: KAL - D6973 -->
<CFPARAM NAME="FORM.SORT_BY" 	DEFAULT="Region_Name">
<CFPARAM NAME="FORM.SORT_ORDER" 	DEFAULT="ASC">
<CFSET Sorting_Order = "#FORM.SORT_BY# #FORM.SORT_ORDER#">

<CFQUERY NAME="getMarketAreas" datasource="#application.datasource#">
	SELECT 	* 
	FROM 	Service_Regions
	WHERE Deleted = 0
	Order By #Sorting_Order#
</CFQUERY>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<CFSET PageTitle="#ucase(application.returned_customer_setting.region_label_singular)# MAINTENANCE">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGETITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT SRC="/script/javascript/string_functions.js">
		<!--- <CFINCLUDE TEMPLATE="/script/javascript/string_functions.js"> --->
	</SCRIPT>
	<SCRIPT>
		function deleteMarket(ID, displayString) {
			if(confirm("Press OK to Delete " + displayString)){
				document.all.deletedMArea.Market_Area_ID.value = ID;
				document.all.deletedMArea.submit();
			}
		}
		
		var editingInProgress = false;
		var oTDbackup = "";
		var oTDRegionNumberBackup = ""
		var oTDactivecell = new Object();
		var oTDactiveRegionNumbercell = new Object();
		
		function editMarketArea(oTDwithstring){
			if(!editingInProgress){
				editingInProgress = true;
				oTDbackup = oTDwithstring.innerHTML;
				oTDactivecell = oTDwithstring;
				oTDactiveRegionNumbercell = eval('document.all.Region_Number_'+oTDactivecell.getAttribute('Market_Area_ID'))
				oTDRegionNumberBackup = oTDactiveRegionNumbercell.innerHTML;
				

				//onkeyup=\"clenseText(this, '0213456789')\"  D29637: removed this validation as we are saving this field as NVARCHAR
				formattedText=oTDactivecell.innerHTML;
				formattedText=formattedText.replace("\"","&#34;");
				formattedText=formattedText.replace("\'","&#39;");
				oTDactivecell.innerHTML = "<INPUT TYPE=\"TEXT\" NAME=\"UPDATED_MARKET_AREA_DESCRIPTION\" MARKET_AREA_ID=\""+oTDactivecell.getAttribute('Market_Area_ID')+"\" VALUE=\"" + formattedText + "\" SIZE=\"40\" MAXLENGTH=\"40\"><BR><FONT COLOR=\"Red\"><B>[</B></FONT><a onclick=\"saveChanges()\"  STYLE=\"cursor: pointer;\"><B>save</B></a><FONT COLOR=\"Red\"><B>]</B></FONT>&nbsp;<FONT COLOR=\"Red\"><B>[</B></FONT><a onclick=\"restoreOldTD()\"  STYLE=\"cursor: pointer;\"><B>cancel</B></a><FONT COLOR=\"Red\"><B>]</B></FONT>"
				oTDactiveRegionNumbercell.innerHTML = "<input name=\"UPDATE_REGION_NUMBER\" type=text size=10 maxlength=50 value=\""+oTDactiveRegionNumbercell.innerHTML+"\">"
			}
			else {
				if(confirm("Currently Another <cfoutput>#application.returned_customer_setting.region_label_singular# Is Being Modified Press OK to Save Changes To It Or CANCEL To Edit The Selected #application.returned_customer_setting.region_label_singular#</cfoutput>")) {
					saveChanges();
				}
				else {
					restoreOldTD();
					editMarketArea(oTDwithstring)
				}
			}
		}

		function restoreOldTD(){
			oTDactivecell.innerHTML = oTDbackup
			oTDactiveRegionNumbercell.innerHTML = oTDRegionNumberBackup
			editingInProgress = false;
		}
		
		function saveChanges() {
			if(trim(document.all.UPDATED_MARKET_AREA_DESCRIPTION.value).length != 0 && trim(document.all.UPDATE_REGION_NUMBER.value).length){
				document.all.saveMAChanges.Market_Area_ID.value		=	document.all.UPDATED_MARKET_AREA_DESCRIPTION.getAttribute('MARKET_AREA_ID')
				document.all.saveMAChanges.New_Description.value 	=	document.all.UPDATED_MARKET_AREA_DESCRIPTION.value
				document.all.saveMAChanges.New_Region_Number.value 	=	document.all.UPDATE_REGION_NUMBER.value
				document.all.saveMAChanges.submit();			
			}
			else {
				alert("Enter Text Both The <cfoutput>#application.returned_customer_setting.region_label_singular#</cfoutput> Name Box and <cfoutput>#application.returned_customer_setting.region_label_singular#</cfoutput> Number Box.")
			}			
		}
		
		function saveNewMarket(){
			if(trim(document.all.new_market_Area.value).length != 0 && trim(document.all.new_region_number.value).length){
				document.all.newMarket.Market_Description.value 	=	document.all.new_market_Area.value
				document.all.newMarket.Region_Number.value 	=	document.all.new_region_number.value
				document.all.newMarket.submit();
			}
			else {
				alert("Enter Text Both The <cfoutput>#application.returned_customer_setting.region_label_singular#</cfoutput> Name Box and <cfoutput>#application.returned_customer_setting.region_label_singular#</cfoutput> Number Box.")
			}
		}
		
		// Development Note: KAL - 06/2005;  Added/Modified below lines: D6973
		function sortBy(sVal, sOrder)
		{
			var searchFrm = document.TheForm;
			searchFrm.SORT_BY.value = sVal;
			searchFrm.SORT_ORDER.value = sOrder;
			searchFrm.submit();
			return false;
		}		
	</SCRIPT>
</HEAD>

<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFQUERY NAME="lasteditedby" datasource="#application.datasource#" MAXROWS="1">
SELECT *
FROM Service_Regions_Last_Edited_By_Data
ORDER BY datestamp desc
</CFQUERY>

<CFIF lasteditedby.recordcount EQ 0>
<CFELSE>
	<CFQUERY NAME="getUserName" datasource="#application.datasource#">
		SELECT *
		FROM _Users
		WHERE User_ID = '#lasteditedby.User_ID#'
	</CFQUERY>

	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated By &nbsp;<CFOUTPUT>#getUserName.Name_First# #getUserName.Name_Last#</CFOUTPUT> on <CFOUTPUT>#dateformat(lasteditedby.datestamp, 'm/d/yyy')# 
	#timeformat(lasteditedby.datestamp, 'h:mm:ss TT')#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
</CFIF>

<BR><BR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
</style>


<SPAN CLASS="title2">Add New <cfoutput>#application.returned_customer_setting.region_label_singular#</cfoutput></SPAN>
<hr COLOR="orange" WIDTH="100%" ALIGN="left">
<TABLE WIDTH="830" CELLPADDING="3" CELLSPACING="0">
	<TR BGCOLOR="#FFCE84" VALIGN="bottom">
		<TD ID="header"><B><cfoutput>#application.returned_customer_setting.region_label_singular#</cfoutput> Name</B></TD>
		<TD ID="header"><B><cfoutput>#application.returned_customer_setting.region_label_singular#</cfoutput> Number</B></TD>
	</TR>
	<TR>
		<TD STYLE="font-size: 10px;"><INPUT TYPE="text" NAME="new_market_Area" SIZE="40" MAXLENGTH="255"></TD>
		<TD STYLE="font-size: 10px;" align="left"><INPUT TYPE="text" NAME="new_region_number" SIZE="10" MAXLENGTH="50">&nbsp;&nbsp;<FONT COLOR="Red"><B>[</B></FONT><a onclick="saveNewMarket()" STYLE="cursor: pointer;"><B>add</B></a><FONT COLOR="Red"><B>]</B></FONT></TD>
	</TR>
</TABLE>

<BR>
<SPAN CLASS="title2">Existing <cfoutput>#application.returned_customer_setting.region_label_plural#</cfoutput></SPAN>
<hr COLOR="orange" WIDTH="100%" ALIGN="left">
<TABLE CLASS="Maintable" WIDTH="830" CELLPADDING="3" CELLSPACING="0">
<!--- Development Note: KAL - 06/2005;  Added/Modified below lines: D6973 --->
<CFOUTPUT>
	<!--- TABLE HEADERS --->
	<TR BGCOLOR="##FFCE84" VALIGN="bottom">
	<FORM ACTION="region_maintenance.cfm" METHOD="post" NAME="TheForm" ID="TheForm">
		
		<INPUT TYPE="Hidden" NAME="SORT_BY" VALUE="#FORM.SORT_BY#">
		<INPUT TYPE="Hidden" NAME="SORT_ORDER" VALUE="#FORM.SORT_ORDER#">
		<CFSET Display_List = "#application.returned_customer_setting.region_label_singular#,#application.returned_customer_setting.region_label_singular# Number, ">
		<CFSET Sort_By_List = "Region_Name,Region_Number, ">
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
			
			<TD ID="header">
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
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<TD VALIGN="bottom" ID="MarketArea_#replace(Service_Region_ID,"-","_","ALL")#" STYLE="font-size: 10px;" Market_Area_ID="#replace(Service_Region_ID,"-","_","ALL")#" Region_Number="#trim(Region_Number)#"NOWRAP>#getMarketAreas.Region_Name#</TD>
			<TD ID="Region_Number_#replace(Service_Region_ID,"-","_","ALL")#">#Region_Number#<cfif Region_Number EQ "">&nbsp;</cfif></TD>
			<TD VALIGN="bottom" ID="" NOWRAP STYLE="font-size: 10px;"><FONT COLOR="Red"><B>[</B></FONT><a onclick="editMarketArea(document.all.MarketArea_#replace(Service_Region_ID,"-","_","ALL")#)" STYLE="cursor: pointer;"><B>edit</B></a><FONT COLOR="Red"><B>]</B></FONT>&nbsp;<FONT COLOR="Red"><B>[</B></FONT><a onclick="deleteMarket('#replace(Service_Region_ID,"-","_","ALL")#', '#replace(replace(getMarketAreas.Region_Name, "'", "\'", "ALL"), chr(34), "\'\'", "ALL")#')" STYLE="cursor: pointer;"><B>delete</B></a><FONT COLOR="Red"><B>]</B></FONT></TD>
		</TR>	
	</CFOUTPUT>
</TABLE>

<FORM ACTION="region_maintenance_Queries.cfm" METHOD="post" NAME="deletedMArea" ID="deletedMArea">
	<INPUT TYPE="Hidden" NAME="Market_Area_ID" VALUE="">
	<INPUT TYPE="Hidden" NAME="Delete" VALUE="1">
</FORM>
<FORM ACTION="region_maintenance_Queries.cfm" METHOD="post" NAME="saveMAChanges" ID="saveMAChanges">
	<INPUT TYPE="Hidden" NAME="Market_Area_ID" VALUE="">
	<INPUT TYPE="Hidden" NAME="New_Description" VALUE="">
	<INPUT TYPE="Hidden" NAME="New_Region_Number" VALUE="">
	<INPUT TYPE="Hidden" NAME="Update" VALUE="1">
</FORM>
<FORM ACTION="region_maintenance_Queries.cfm" METHOD="post" NAME="newMarket" ID="newMarket">
	<INPUT TYPE="Hidden" NAME="Market_Description" VALUE="">
	<INPUT TYPE="Hidden" NAME="Region_Number" VALUE="">
	<INPUT TYPE="Hidden" NAME="Insert" VALUE="1">
</FORM>

</BODY>
</HTML>
