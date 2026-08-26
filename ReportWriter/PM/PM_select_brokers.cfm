<CFIF isdefined("URL.FormName")>
	<FORM ACTION="pm_select_brokers.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
		<INPUT NAME="ParentFormname" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.FormName#</CFOUTPUT>">
		<INPUT NAME="FinalItemList" TYPE="HIDDEN" VALUE="">
	</FORM>
	<script>
		if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT> != null){
			this.document.all.FinalItemList.value = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.Broker_List.value
			document.all.MyForm.submit()
		}
		else{
			alert("The Data Needed From The Parent Form Isnt Available.This Window Will Close!")
			window.close()
		}
	</script>
	<cfabort>
</CFIF>

<!------<cfparam name="URL.FormName" 	default="">
<cfparam name="Form.ParentFormname" 	default="#URL.FormName#">----->

<CFSET PAGE_TITLE="Select Program Brokers">
<CFSET GROUP="Contracts">


<CFPARAM name="FORM.button_caption"					default="continue">
<CFPARAM NAME="FORM.searchstring" DEFAULT="">
<CFPARAM NAME="FORM.SelectedITEMS" DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingitems" DEFAULT="0">
<CFPARAM NAME="FORM.LoadSavedBrokers"	Default="1">

<CFPARAM NAME="mxRowCount" DEFAULT="10">
<CFPARAM NAME="startrow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<cf_Number_of_Rows maxrows="#mxRowCount#">

	
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

<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
	<CFIF listfind(FORM.FinalItemList,ListItem, ",") GT 0>
		<CFSET Form.FinalItemList = listdeleteat(FORM.FinalItemList, listfind(FORM.FinalItemList,ListItem, ","), ",")>
	</CFIF>
</CFLOOP>

<CFIF FORM.finishedselectingitems EQ 1>
	<script>
		opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.Broker_List.value = '<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>'
		opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.submit()
		window.close()		
	</script>
	<CFABORT>
</CFIF>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="20" TOPMARGIN="0">

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




	<!--- 
	<CFSET URL.Contract_Main_ID = FORM.Contract_Main_ID>
	<CFINCLUDE TEMPLATE="thin_contract_general_display.cfm">
	--->

<!------<cfinclude template="minimal_contract_info.cfm">----->


	<FORM ACTION="pm_select_brokers.cfm" METHOD="post" NAME="MyForm" ID="MyForm">

<BR><B>
<FONT SIZE="2" COLOR="Red">[</FONT>
	<FONT SIZE="2" COLOR="Blue">
	<A HREF="/help_files/manual/projects/new.cfm#Brokers" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Project Summary">
	read me first
	</A>
</FONT>
<FONT SIZE="2" COLOR="Red">]</FONT>
</B>

	<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">broker search</LEGEND>
			<table>
				<TR>
					<TD COLSPAN="2"><!--- Zone --->
						<span ID="searchItemLabel"><CFOUTPUT>#application.returned_customer_setting.zone_label_singular#</CFOUTPUT></span><BR>
						<CFQUERY NAME="GetZones" datasource="#application.datasource#">
						SELECT *
						FROM Service_Zones
						WHERE len(Zone_Name) > 0
						AND Deleted = 0
						ORDER BY Zone_Name
						</CFQUERY>
						<CFPARAM NAME="FORM.Zone_ID" DEFAULT="0">
						<SELECT NAME="Zone_ID" style="width: 200px;">
							<OPTION VALUE="0">**ALL** <CFOUTPUT>#application.returned_customer_setting.zone_label_plural#</CFOUTPUT></OPTION>
							<CFOUTPUT QUERY="GetZones"><OPTION VALUE="#trim(GetZones.Service_Zone_ID)#"#IIF(trim(FORM.Zone_ID) EQ GetZones.Service_Zone_ID, DE(" SELECTED"), DE(""))#>#trim(GetZones.Zone_Name)#</OPTION></CFOUTPUT>
						</SELECT>	
					</TD>
					<TD><!--- Regions --->
						<span ID="searchItemLabel"><CFOUTPUT>#application.returned_customer_setting.region_label_singular#</CFOUTPUT></span><BR>
						<CFQUERY NAME="GetRegions" datasource="#application.datasource#">
						SELECT *
						FROM Service_Regions
						WHERE len(Region_Name) > 0
						AND Deleted = 0
						ORDER BY Region_Name
						</CFQUERY>
						<CFPARAM NAME="FORM.Region_ID" DEFAULT="0">
						<SELECT NAME="Region_ID" style="width: 200px;">
							<OPTION VALUE="0">**ALL** <CFOUTPUT>#application.returned_customer_setting.region_label_plural#</CFOUTPUT></OPTION>
							<CFOUTPUT QUERY="GetRegions"><OPTION VALUE="#trim(GetRegions.Service_Region_ID)#"#IIF(trim(FORM.Region_ID) EQ getRegions.Service_Region_ID, DE(" SELECTED"), DE(""))#>#trim(GetRegions.Region_Name)#</OPTION></CFOUTPUT>
						</SELECT>	
					</TD>
					<TD><!--- Line Of Biz --->
						<span ID="searchItemLabel"><CFOUTPUT>#application.returned_customer_setting.lob_label_singular#</CFOUTPUT></span><BR>
						<cfquery name="GetLinesOfBiz" datasource="#application.datasource#">
							SELECT *
							FROM Line_Of_Business
							WHERE len(Line_Of_Business_Name) > 0
							AND Deleted = 0
							ORDER BY Line_Of_Business_Name
						</cfquery>
						<CFSET First_Time = NOT Isdefined("FORM.Line_Of_Biz")>
						<CFPARAM NAME="FORM.Line_Of_Biz" DEFAULT="0">
						<SELECT NAME="Line_Of_Biz" style="width: 200px;">
							<OPTION VALUE="0">**ALL** <CFOUTPUT>#application.returned_customer_setting.lob_label_plural#</CFOUTPUT></OPTION>
							<CFOUTPUT QUERY="GetLinesOfBiz">
							<CFIF Line_Of_Business EQ "#ListFirst(application.returned_customer_setting.Line_Business_Default,",")#" AND First_Time>
								<CFSET FORM.Line_Of_Biz = GetLinesOfBiz.Line_Of_Business_ID>
							</CFIF><OPTION VALUE="#trim(GetLinesOfBiz.Line_Of_Business_ID)#"#IIF(trim(FORM.Line_Of_Biz) EQ trim(GetLinesOfBiz.Line_Of_Business_ID), DE(" SELECTED"), DE(""))#>#trim(GetLinesOfBiz.Line_Of_Business_Name)#</OPTION></CFOUTPUT>
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
					<CFSET sort_By_List="Name,ID,Address,City,State,Postal Code,Region,Zone">
					<CFSET sort_By_List_Display="Name,ID,Address,City,State,Postal Code,#application.returned_customer_setting.region_label_singular#,#application.returned_customer_setting.zone_label_singular#">
					
					<CFPARAM NAME="FORM.sort_by" DEFAULT="#Trim(ListFirst(sort_By_List))#">
					<CFOUTPUT>
					<CFSET sort_By_List_Display_Sorted=ListSort(sort_By_List_Display,"Text")>
					
					<SELECT ID="sort_by" NAME="sort_by">
					<CFLOOP LIST="#sort_By_List_Display_Sorted#" INDEX="thisItem">
						<CFSET thisItem=Trim(thisItem)>
						<CFSET thisItemValue=ListGetAt(sort_By_List, ListFindNoCase(sort_By_List_Display, thisItem, ","), ",")>
						<OPTION VALUE="#thisItemValue#"<CFIF thisItemValue EQ FORM.sort_by> SELECTED</CFIF>>#thisItem#</OPTION>
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
					<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript:document.MyForm.submit();">search brokers</a><FONT COLOR="#FF0000">]</FONT></B>
					</TD>
			</table>		
			
			
		<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">
	</FIELDSET>


	<CFQUERY NAME="GetBrokerInfo" datasource="#application.datasource#">
		SELECT *
		FROM BSA_Foodservice_Brokers
		WHERE BSA_Foodservice_Brokers_ID <CFIF FORM.FinalItemList EQ 0>IS NULL<CFELSEIF listlen(FORM.FinalItemList) GT 0>IN(#listqualify(FORM.FinalItemList, "'", ",")#)<CFELSE>!= BSA_Foodservice_Brokers_ID</CFIF>


	</CFQUERY>
	
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
	<CFSET Open_Layer_Caption = "currently selected brokers">
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
			<CFIF GetBrokerInfo.recordcount GT 0>
				<TABLE border="0" cellspacing="3" cellpadding="3" align="left" WIDTH="700" BGCOLOR="white">
					<TR><CFOUTPUT QUERY="GetBrokerInfo">
						<TD NOWRAP BGCOLOR="eeeeee" STYLE="cursor: hand;" onclick="NewWindow('/Profiles/Brokers/Broker_profile.cfm?BID=#GetBrokerInfo.BSA_Foodservice_Brokers_ID#','name','400','450','Yes', 'No');"">#GetBrokerInfo.broker_name#</TD>
		 				<CFIF GetBrokerInfo.currentrow mod 4><CFELSE></TR><TR></CFIF>
					</CFOUTPUT>	
				</TABLE>
			<CFELSE>
				<CFIF FORM.FinalItemList EQ 0>ALL BROKERS<CFELSE>NONE</CFIF>
			</CFIF>
			<BR>
		</CF_openLayer>

<br>


<CFIF isdefined("FORM.DOSEARCH")>

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
SELECT     dbo.Service_Zones.Zone_Name AS Zone_Name, dbo.Service_Regions.Region_Name AS Region_name, dbo.BSA_Foodservice_Brokers.*
FROM         dbo.BSA_Foodservice_Brokers INNER JOIN
                      dbo.Service_Regions ON dbo.BSA_Foodservice_Brokers.Service_Region_ID = dbo.Service_Regions.Service_Region_ID INNER JOIN
                      dbo.Service_Zones ON dbo.BSA_Foodservice_Brokers.Service_Zone_ID = dbo.Service_Zones.Service_Zone_ID
		WHERE
			0 = 0
			AND dbo.BSA_Foodservice_Brokers.DELETED = 0 AND dbo.BSA_Foodservice_Brokers.Active_Code = '#FORM.Broker_Status#'
		<CFIF FORM.Zone_ID NEQ 0>
			AND
			dbo.BSA_Foodservice_Brokers.Service_Zone_ID = '#FORM.Zone_ID#'
		</CFIF> 

		<CFIF FORM.Region_ID NEQ 0>
			AND
			dbo.BSA_Foodservice_Brokers.Service_Region_ID = '#FORM.Region_ID#'
		</CFIF> 

		<CFIF FORM.Line_Of_Biz NEQ 0>
			AND
			dbo.BSA_Foodservice_Brokers.Line_Of_Business_ID = '#FORM.Line_Of_Biz#'
		</CFIF> 
				
		<CFIF len(trim(FORM.searchstring)) GT 0>
		AND
		(
			(
				dbo.BSA_Foodservice_Brokers.Broker_Name = 'form.searchstring'
				OR
				dbo.BSA_Foodservice_Brokers.Broker_Name LIKE '%#form.searchstring#'
				OR
				dbo.BSA_Foodservice_Brokers.Broker_Name LIKE '#form.searchstring#%'
				OR
				dbo.BSA_Foodservice_Brokers.Broker_Name LIKE '%#form.searchstring#%'
			)
		)
		</CFIF>
		
		--Order By dbo.BSA_Foodservice_Brokers.Broker_Name
		ORDER BY #sql_Sort_By# #sql_Sort_By_Order#
	</CFQUERY>
	
	<CFIF StartRow GT TheQuery.RecordCount>
		<CFSET startrow = 1>
		<CFSET frompage = 1>
		<cf_Number_of_Rows maxrows="#mxRowCount#">
	</CFIF>
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
					<TD align="center"><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Brokers"></TD>
					<TD align="left" NOWRAP ID="header"><B>Name / ID</B></TD>
					<!--- <TD align="left">Broker Name</TD> --->
					<TD align="left" ID="header"><B>Address</B></TD>
<!--- 					<TD align="left" NOWRAP>Market Area Name</TD> --->
					<TD align="left" ID="header"><B>Region / Zone</B></TD>
					<!--- <TD align="left">Zone</TD> --->
				</TR>

			<CFOUTPUT QUERY="TheQuery" startrow="#StartRow#" maxrows="#MaxRows#">
				<cf_cryp string="#TheQuery.BSA_Foodservice_Brokers_ID#" type="en" key="#request.key#">

				<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> style="cursor: hand;">
					<TD align="center"><INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Foodservice_Brokers_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Foodservice_Brokers_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.BSA_Foodservice_Brokers_ID), ",")></CFIF>></TD>
					<TD NOWRAP ONCLICK="NewWindow('/Profiles/Brokers/Broker_profile.cfm?BID=#TheQuery.BSA_Foodservice_Brokers_ID#','name','400','450','Yes', 'No');">#TheQuery.Broker_Name#<BR>#TheQuery.Broker_Shard#&nbsp;</TD>
					<TD NOWRAP ONCLICK="NewWindow('/Profiles/Brokers/Broker_profile.cfm?BID=#TheQuery.BSA_Foodservice_Brokers_ID#','name','400','450','Yes', 'No');">#Address#<BR><cfif len(trim(address_2))>#ADDRESS_2#<BR></cfif>#City#,#State# #Zip#&nbsp;</TD>
					<TD NOWRAP ONCLICK="NewWindow('/Profiles/Brokers/Broker_profile.cfm?BID=#TheQuery.BSA_Foodservice_Brokers_ID#','name','400','450','Yes', 'No');">#TheQuery.Region_Name#<BR>#TheQuery.Zone_Name#&nbsp;</TD>
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
<INPUT TYPE="Hidden" NAME="startrow" VALUE="<CFOUTPUT>#startrow#</CFOUTPUT>">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="<CFOUTPUT>#frompage#</CFOUTPUT>">
<input type="hidden" name="button_caption" value="<CFOUTPUT>#FORM.Button_Caption#</CFOUTPUT>">
</FORM>
	<cfif TheQuery.recordcount GT 0>
	<DIV ALIGN="center">
	&nbsp;&nbsp;&nbsp;
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" onClick="javascript: finishedSearching()"> import selected brokers </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>

	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: hand;" onClick="importAllProducts(<CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT>)"> import all returned brokers </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: hand;" onClick="removeAllProducts()"> remove all selected brokers </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<BR>	
	</DIV>
	</cfif> 


<SCRIPT>
	<cfif TheQuery.recordcount GT 0>
		function importAllProducts(recordcount){
			<!------//recordcount = <CFOUTPUT>#ListLen(whole_Product_List)#</CFOUTPUT>;----->
			if(parseInt(recordcount) == 1) pString = "Product";
			else pString = "Products";
			
			if(confirm("Do you want to import all " + recordcount + " records from your search?")){
				document.all.allbox.checked = true;
				document.all.allbox.fireEvent("onclick");
				
				document.MyForm.finishedselectingitems.value = 1;
				if(document.MyForm.FinalItemList.value.length > 0){
					document.MyForm.FinalItemList.value 	= document.MyForm.FinalItemList.value + "," + "<CFOUTPUT>#valuelist(TheQuery.BSA_Foodservice_Brokers_ID)#</CFOUTPUT>";
					<!------//document.SearchForm.FinalUPCList.value 	= document.SearchForm.FinalUPCList.value + "," + "<CFOUTPUT>#whole_Product_List#</CFOUTPUT>";
					//document.SearchForm.FinalUPCList.value 	= "<CFOUTPUT>#whole_Product_List#</CFOUTPUT>";----->
				}
				else{
					document.MyForm.FinalItemList.value 	= "<CFOUTPUT>#valuelist(TheQuery.BSA_Foodservice_Brokers_ID)#</CFOUTPUT>";
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
				document.all.allbox.checked = false;
				document.all.allbox.fireEvent("onclick");
				
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

