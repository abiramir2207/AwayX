<CFIF isdefined("URL.FormName")>
	<FORM ACTION="pm_select_distributors.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
		<INPUT NAME="ParentFormname" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.FormName#</CFOUTPUT>">
		<INPUT NAME="FinalItemList" TYPE="HIDDEN" VALUE="">
	</FORM>
	<script>
		if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT> != null){
			this.document.all.FinalItemList.value = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.Distributor_List.value
			document.all.MyForm.submit()
		}
		else{
			alert("The Data Needed From The Parent Form Isnt Available.This Window Will Close!")
			window.close()
		}
	</script>
	<cfabort>
</CFIF>


<CFPARAM NAME="FORM.DOSEARCH" DEFAULT="0">
<CFPARAM NAME="URL.CID" DEFAULT="">

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

<CFSET PAGE_TITLE="Select Program #application.returned_customer_setting.distributor_label_plural#">
<CFSET GROUP="Contracts">



<CFPARAM name="FORM.button_caption"					default="continue">
<CFPARAM NAME="FORM.searchstring" DEFAULT="">
<CFPARAM NAME="FORM.SelectedITEMS" DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingitems" DEFAULT="0">
<CFPARAM NAME="FORM.LoadSavedDistributors"	Default="1">

<CFPARAM NAME="startrow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<CFPARAM NAME="mxRowCount" DEFAULT=10>
<cf_Number_of_Rows maxrows="#mxRowCount#">


<CFSET FORM.LoadSavedDistributors=0>
<CFIF FORM.LoadSavedDistributors EQ 1>
	<cfquery name="CheckForExistingDistributors" datasource="#application.datasource#">
		SELECT 	*
		FROM Contract_Distributors
		WHERE Contract_Main_ID = '#cryp.value#' AND deleted = 0
	</cfquery>		
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

<CFIF listlen(FORM.FinalItemList) GT 0>
	<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
		
		<CFSET LocationOfItemToDelete = listfind(FORM.FinalItemList,ListItem, ",")>
		<CFIF LocationOfItemToDelete GT 0>
			<CFSET Form.FinalItemList = listdeleteat(FORM.FinalItemList, listfind(FORM.FinalItemList,ListItem, ","), ",")>
		</CFIF>
		
	</CFLOOP>
</CFIF>

<CFIF FORM.finishedselectingitems EQ 1>
	<script>
		opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.Distributor_List.value = '<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>'
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


<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>




	<FORM ACTION="PM_select_distributors.cfm?CID=<CFOUTPUT>#URL.CID#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm">
<BR><B>
<FONT SIZE="2" COLOR="Red">[</FONT>
	<FONT SIZE="2" COLOR="Blue">
	<A HREF="/help_files/manual/projects/new.cfm#Distributors" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Project Summary">
	read me first
	</A>
</FONT>
<FONT SIZE="2" COLOR="Red">]</FONT>
</B>
	<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput> search</LEGEND>
			<TABLE>
				<TR>
					<TD COLSPAN="2"><!--- Family Name --->
						<span ID="searchItemLabel"><CFOUTPUT>#application.returned_customer_setting.family_name_label_singular#</CFOUTPUT></span><BR>
						<cfquery name="GetFamilyNames" datasource="#application.datasource#">
							SELECT *
							FROM Distributor_Family
							WHERE Deleted = 0
							ORDER BY Family_Name
						</cfquery>
						<CFPARAM NAME="FORM.Family_Name" DEFAULT="0">
						<SELECT NAME="Family_Name" style="width: 200px;">
							<OPTION VALUE="0">**ALL** <CFOUTPUT>#application.returned_customer_setting.family_name_label_plural#</CFOUTPUT></OPTION>
							<CFOUTPUT QUERY="GetFamilyNames"><OPTION VALUE="#trim(GetFamilyNames.Family_ID)#"#IIF(trim(FORM.Family_Name) EQ trim(GetFamilyNames.Family_ID), DE(" SELECTED"), DE(""))#>#trim(GetFamilyNames.Family_Name)#</OPTION></CFOUTPUT>
						</SELECT>					
					</TD>
					<TD><!--- Buying Groups --->
						<span ID="searchItemLabel"><CFOUTPUT>#application.returned_customer_setting.buying_group_label_singular#</CFOUTPUT></span><BR>
						<cfquery name="GetBuyingGroups" datasource="#application.datasource#">
							SELECT *
							FROM Distributor_Buying_Groups
							WHERE Deleted = 0
							ORDER BY Buying_Group_Name
						</cfquery>
						<CFPARAM NAME="FORM.Buying_Group" DEFAULT="0">
						<SELECT NAME="Buying_Group" style="width: 200px;">
							<OPTION VALUE="0">**ALL** <CFOUTPUT>#application.returned_customer_setting.buying_group_label_plural#</CFOUTPUT></OPTION>
							<CFOUTPUT QUERY="GetBuyingGroups"><OPTION VALUE="#trim(GetBuyingGroups.Buying_Group_ID)#"#IIF(trim(FORM.Buying_Group) EQ trim(GetBuyingGroups.Buying_Group_ID), DE(" SELECTED"), DE(""))#>#trim(GetBuyingGroups.Buying_Group_Name)#</OPTION></CFOUTPUT>
						</SELECT>					
					</TD>
					<TD><!--- Line Of Biz --->
						<span ID="searchItemLabel"><CFOUTPUT>#application.returned_customer_setting.lob_label_singular#</CFOUTPUT></span><BR>
						<cfquery name="GetLinesOfBiz" datasource="#application.datasource#">
							SELECT *
							FROM Line_Of_Business
							WHERE Deleted = 0
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
						<CFPARAM NAME="FORM.Distributor_Status" DEFAULT="A">
						<SELECT NAME="Distributor_Status">
							<option VALUE="A" <CFIF FORM.Distributor_Status EQ "A">SELECTED</CFIF>>Active</option>
							<!--- <option VALUE="N" <CFIF FORM.Distributor_Status EQ "N">SELECTED</CFIF>>Inactive</option> --->
						</SELECT>
					</TD>
				</TR>
				<TR>
					<TD COLSPAN="2"><!--- Zone --->
						<span ID="searchItemLabel"><CFOUTPUT>#application.returned_customer_setting.zone_label_singular#</CFOUTPUT></span><BR>
						<CFQUERY NAME="GetZones" datasource="#application.datasource#">
						SELECT *
						FROM Service_Zones
						WHERE len(Zone_Name) != 0 AND Deleted = 0
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
						WHERE len(Region_Name) != 0 AND Deleted = 0
						ORDER BY Region_Name
						</CFQUERY>
						<CFPARAM NAME="FORM.Region_ID" DEFAULT="0">
						<SELECT NAME="Region_ID" style="width: 200px;">
							<OPTION VALUE="0">**ALL** <CFOUTPUT>#application.returned_customer_setting.region_label_plural#</CFOUTPUT></OPTION>
							<CFOUTPUT QUERY="GetRegions"><OPTION VALUE="#trim(GetRegions.Service_Region_ID)#"#IIF(trim(FORM.Region_ID) EQ getRegions.Service_Region_ID, DE(" SELECTED"), DE(""))#>#trim(GetRegions.Region_Name)#</OPTION></CFOUTPUT>
						</SELECT>	
					</TD>					
					<!--- Get Foodservice Line Of Business ID --->
					<CFQUERY NAME="GetFoodserviceLOBID" datasource="#application.datasource#">
						SELECT Line_Of_Business_ID FROM Line_Of_Business WHERE Line_Of_Business IN (#ListQualify(application.returned_customer_setting.Line_Business_Default, "'", ",")#)
					</CFQUERY>
					<TD><!--- Brokers --->
						<span ID="searchItemLabel"><CFOUTPUT>#application.returned_customer_setting.broker_label_singular#</CFOUTPUT></span><BR>
						<cfquery name="GetBrokers" datasource="#application.datasource#">
							SELECT *
							FROM BSA_Foodservice_Brokers
							WHERE  ACTIVE_CODE = 'A' AND Line_Of_Business_ID = '#GetFoodserviceLOBID.Line_Of_Business_ID#' AND Deleted = 0
							ORDER BY Broker_Name
						</cfquery>
						<CFPARAM NAME="FORM.Broker" DEFAULT="0">
						<SELECT NAME="Broker" style="width: 200px;">
							<OPTION VALUE="0">**ALL** <CFOUTPUT>#application.returned_customer_setting.broker_label_plural#</CFOUTPUT></OPTION>
							<CFOUTPUT QUERY="GetBrokers"><OPTION VALUE="#trim(GetBrokers.BSA_Foodservice_Brokers_ID)#"#IIF(trim(FORM.Broker) EQ trim(GetBrokers.BSA_Foodservice_Brokers_ID), DE(" SELECTED"), DE(""))#>#trim(GetBrokers.Broker_Name)#</OPTION></CFOUTPUT>
						</SELECT>	
					</TD>					
			</TR>
			<TR>
				<TD NOWRAP ALIGN="left">
					Sort By<BR>
					<CFSET sort_By_List="Name,Ship To,Address,City,State,Zip Code,Broker,Family,Buying Group">
					<CFSET sort_By_List_Display="Name,Ship To,Address,City,State,Zip Code,#application.returned_customer_setting.broker_label_singular#,#application.returned_customer_setting.family_name_label_singular#,#application.returned_customer_setting.buying_group_label_singular#">
					
					<CFPARAM NAME="FORM.sort_by" DEFAULT="#Trim(ListFirst(sort_By_List))#">
					<CFOUTPUT>
					<CFSET sort_By_List_Display_Sorted=ListSort(sort_By_List_Display,"Text")>
					<SELECT ID="sort_by" NAME="sort_by">					
					<CFLOOP LIST="#sort_By_List_Display_Sorted#" INDEX="thisItem" DELIMITERS=",">
						<CFSET thisItem=Trim(thisItem)>
						<CFSET thisItemValue = ListGetAt(sort_By_List, ListFindNoCase(sort_By_List_Display, thisItem, ","), ",")>
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
					<TD COLSPAN="2" NOWRAP>
						Name<BR><INPUT TYPE="Text" NAME="searchstring" STYLE="WIDTH:405px" SIZE="57"<CFIF len(trim(FORM.searchstring)) GT 0>VALUE="<CFOUTPUT>#trim(FORM.searchstring)#</CFOUTPUT>"</CFIF>>
				<!------<INPUT TYPE="Submit" VALUE="search">----->
						<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">
					</TD>
					<TD ALIGN="left" NOWRAP>
					<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10"><BR>
					&nbsp;&nbsp;
					<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript:document.MyForm.submit();">search <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput></a><FONT COLOR="#FF0000">]</FONT></B>
					</TD>
			</TR>

			</TABLE>
				
	</FIELDSET>

	<CFQUERY NAME="GetDistInfo" datasource="#application.datasource#">
		SELECT *
		FROM BSA_Foodservice_Customers
		WHERE BSA_Foodservice_Customers_ID <CFIF FORM.FinalItemList EQ 0>IS NULL<CFELSEIF listlen(FORM.FinalItemList) GT 0>IN(#listqualify(FORM.FinalItemList, "'", ",")#)<CFELSE>!= BSA_Foodservice_Customers_ID</CFIF> AND deleted = 0
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
	<CFSET Open_Layer_Caption = "currently selected dictributors">
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
						<TD NOWRAP BGCOLOR="eeeeee" STYLE="cursor: hand;" onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#GetDistInfo.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');"">#GetDistInfo.name#</TD>
		 				<CFIF GetDistInfo.currentrow mod 4><CFELSE></TR><TR></CFIF>
					</CFOUTPUT>	
				</TABLE>
			<CFELSE>
				<CFIF FORM.FinalItemList EQ 0>ALL <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput><CFELSE>NONE</CFIF>
			</CFIF>
			<BR>
	</CF_openLayer>

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
	<CFCASE value="Zip Code">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Customers.ZipCode">
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
SELECT     dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID, dbo.BSA_Foodservice_Customers.Name, 
                      dbo.BSA_Foodservice_Customers.Address_1, dbo.BSA_Foodservice_Customers.City, dbo.BSA_Foodservice_Customers.State, 
                      dbo.BSA_Foodservice_Customers.ZipCode, dbo.Distributor_Family.Family_Name, dbo.BSA_Foodservice_Customers.Ship_To, 
                      dbo.BSA_Foodservice_Customers.Active_Code, dbo.BSA_Foodservice_Brokers.Broker_Name, dbo.Service_Zones.Zone_Name, 
                      dbo.Service_Regions.Region_Name, dbo.Distributor_Buying_Groups.Buying_Group_Name,  dbo.BSA_Foodservice_Customers.Shr_Ship_To
FROM         dbo.BSA_Foodservice_Customers INNER JOIN
                      dbo.Distributor_Family ON dbo.BSA_Foodservice_Customers.Family_ID = dbo.Distributor_Family.Family_ID INNER JOIN
                      dbo.Distributor_Buying_Groups ON 
                      dbo.BSA_Foodservice_Customers.Buying_Group_ID = dbo.Distributor_Buying_Groups.Buying_Group_ID INNER JOIN
                      dbo.Line_Of_Business ON dbo.BSA_Foodservice_Customers.Line_Of_Business_ID = dbo.Line_Of_Business.Line_Of_Business_ID INNER JOIN
                      dbo.BSA_Foodservice_Brokers ON 
                      dbo.BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID = dbo.BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID INNER
                       JOIN
                      dbo.Service_Regions ON dbo.BSA_Foodservice_Brokers.Service_Region_ID = dbo.Service_Regions.Service_Region_ID INNER JOIN
                      dbo.Service_Zones ON dbo.BSA_Foodservice_Brokers.Service_Zone_ID = dbo.Service_Zones.Service_Zone_ID
		WHERE
			0 = 0 AND dbo.BSA_Foodservice_Customers.DELETED = 0 
		
		<!--- family name --->
		<CFIF FORM.Family_Name NEQ 0>
			AND dbo.BSA_Foodservice_Customers.Family_ID = '#FORM.Family_Name#'
		</CFIF>

		<!--- buying group --->
		<CFIF FORM.Buying_Group NEQ 0>
			AND dbo.BSA_Foodservice_Customers.Buying_Group_ID = '#FORM.Buying_Group#'
		</CFIF>
		
		<!--- Line Of Business --->
		<CFIF FORM.Line_Of_Biz NEQ 0>
			AND dbo.BSA_Foodservice_Customers.Line_Of_Business_ID = '#FORM.Line_Of_Biz#'
		</CFIF>

		<!--- Distributor Status --->
		<CFIF FORM.Distributor_Status NEQ 0>
			AND dbo.BSA_Foodservice_Customers.Active_Code = '#FORM.Distributor_Status#'
		</CFIF>
		
		<!--- Zone --->
		<CFIF FORM.Zone_ID NEQ 0>
			AND dbo.BSA_Foodservice_Brokers.Service_Zone_ID = '#FORM.Zone_ID#'
		</CFIF>

		<!--- Region --->
		<CFIF FORM.Region_ID NEQ 0>
			AND dbo.BSA_Foodservice_Brokers.Service_Region_ID = '#FORM.Region_ID#'
		</CFIF>
		
		<!--- Broker --->
		<CFIF FORM.Broker NEQ 0>
			AND dbo.BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = '#FORM.Broker#'
		</CFIF>

<!--- 		<CFIF FORM.State NEQ 0>
			AND BSA_Foodservice_Customers.state = '#FORM.State#'
		</CFIF>
 --->
<!--- 		<CFIF FORM.Market_Area NEQ 0>
			AND BSA_Foodservice_Brokers.Market_Area = '#FORM.Market_Area#'
		</CFIF>
 --->		
		<CFIF len(trim(FORM.searchstring)) GT 0>
		AND
		(
			(
				dbo.BSA_Foodservice_Customers.Name = '#form.searchstring#'
				OR
				dbo.BSA_Foodservice_Customers.Name LIKE '%#form.searchstring#'
				OR
				dbo.BSA_Foodservice_Customers.Name LIKE '#form.searchstring#%'
				OR
				dbo.BSA_Foodservice_Customers.Name LIKE '%#form.searchstring#%'
			)
			OR
			(
				dbo.BSA_Foodservice_Customers.City = '#form.searchstring#'
				OR
				dbo.BSA_Foodservice_Customers.City LIKE '%#form.searchstring#'
				OR
				dbo.BSA_Foodservice_Customers.City LIKE '#form.searchstring#%'
				OR
				dbo.BSA_Foodservice_Customers.City LIKE '%#form.searchstring#%'
			)
			OR
			(
				dbo.Distributor_Family.Family_Name = '#form.searchstring#'
				OR
				dbo.Distributor_Family.Family_Name LIKE '%#form.searchstring#'
				OR
				dbo.Distributor_Family.Family_Name LIKE '#form.searchstring#%'
				OR
				dbo.Distributor_Family.Family_Name LIKE '%#form.searchstring#%'
			)
			<CFIF isnumeric(form.searchstring)>
			OR
			(
				dbo.BSA_Foodservice_Customers.Shr_Family = '#form.searchstring#'
				OR
				dbo.BSA_Foodservice_Customers.Shr_Family LIKE '%#form.searchstring#'
				OR
				dbo.BSA_Foodservice_Customers.Shr_Family LIKE '#form.searchstring#%'
				OR
				dbo.BSA_Foodservice_Customers.Shr_Family LIKE '%#form.searchstring#%'
			)
			</CFIF>
			OR
			(
				dbo.BSA_Foodservice_Brokers.Broker_Name = '#form.searchstring#'
				OR
				dbo.BSA_Foodservice_Brokers.Broker_Name LIKE '%#form.searchstring#'
				OR
				dbo.BSA_Foodservice_Brokers.Broker_Name LIKE '#form.searchstring#%'
				OR
				dbo.BSA_Foodservice_Brokers.Broker_Name LIKE '%#form.searchstring#%'
			)
		)
		</CFIF>
		--order by name
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
				if(<CFIF TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> in the list below while selecting them all. Press OK If You Wish To Continue")<CFELSE>0==0</CFIF>) {
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
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF TheQuery.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput><CFELSE><cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput></CFIF> That <CFIF TheQuery.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Above Criteria</LEGEND>
		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF TheQuery.recordcount GT 0>
			<TABLE border="0" cellspacing="0" cellpadding="3" align="center" WIDTH="675" CLASS="Maintable">
				<TR ID="header" BGCOLOR="#ffce84">
					<TD align="center"><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Distributors"></TD>
					<!--- <TD>Ship-to #</TD> --->
					<TD align="left" ID="header"><B>Name /<cfoutput>#application.returned_customer_setting.shard_ship_to_label#</cfoutput></B></TD>
					<TD ID="header"><B>Address</B></TD>
					<!--- <TD ID="header"><B>Buying Group</B></TD> --->
					<TD ID="header"><B>Broker</B></TD>
					<!--- <TD>Shared Family Code</TD> --->
					<TD ID="header"><B>Family / Buying Group</B></TD>
					<!--- <TD ALIGN="center">Status</TD> --->
				</TR>
			
			<CFOUTPUT QUERY="TheQuery" startrow="#StartRow#" maxrows="#MaxRows#">
				<!--- <cf_cryp type="en" string="#TheQuery.BSA_Foodservice_Customers_ID#" key="#request.key#"> --->
				<TR STYLE="cursor:hand;" <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
					<TD align="center"><INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Foodservice_Customers_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.BSA_Foodservice_Customers_ID), ",")></CFIF>></TD>
					<!--- <TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#cryp.value#','name','400','450','Yes', 'No');return false;">#TheQuery.Ship_To#&nbsp;</TD> --->
					<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#TheQuery.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;" NOWRAP>#TheQuery.Name#<BR>#TheQuery.Shr_Ship_To#&nbsp;</TD>
					<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#TheQuery.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;">#TheQuery.Address_1#<BR>#TheQuery.City#,#TheQuery.State# #TheQuery.ZipCode#&nbsp;</TD>
					<!--- <TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#TheQuery.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;" >#TheQuery.Buying_Group_Name#&nbsp;</TD> --->
					<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#TheQuery.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;" >#TheQuery.Broker_Name#&nbsp;</TD>
					<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#TheQuery.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;" NOWRAP>#TheQuery.Family_Name#<BR>#TheQuery.Buying_Group_Name#&nbsp;</TD>
					<!--- <TD NOWRAP onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#cryp.value#','name','400','450','Yes', 'No');return false;">&nbsp;(#TheQuery.Active_Code#)<cfif TheQuery.Active_Code EQ "A">Active<cfelse>Inactive</cfif>&nbsp;</TD> --->
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
<INPUT TYPE="hidden" NAME="ParentFormname" 						VALUE="<CFOUTPUT>#FORM.ParentFormname#</CFOUTPUT>">	
<INPUT TYPE="hidden" NAME="FinalItemList" ID="FinalItemList" VALUE="<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="AlreadySelectedItems" ID="AlreadySelectedItems" VALUE="<CFOUTPUT>#Form.AlreadySelectedItems#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="finishedselectingitems" VALUE="0">
<INPUT TYPE="hidden" NAME="LoadSavedDistributors" VALUE="0">
<input type="hidden" name="button_caption" value="<CFOUTPUT>#FORM.Button_Caption#</CFOUTPUT>">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="<CFOUTPUT>#startrow#</CFOUTPUT>">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="<CFOUTPUT>#frompage#</CFOUTPUT>">
<INPUT TYPE="Hidden" NAME="editcurrentweight" VALUE="0">

<!---<br>
 <cfinclude template="select_forms_buttons.cfm"> --->

</FORM>

	<cfif TheQuery.recordcount GT 0>
	<DIV ALIGN="center">
	&nbsp;&nbsp;&nbsp;
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" onClick="javascript: finishedSearching()"> import selected <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput> </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>

	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: hand;" onClick="importAllProducts(<CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT>)"> import all returned <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput> </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: hand;" onClick="removeAllProducts()"> remove all selected <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput> </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>	
	</DIV>
	<BR>
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