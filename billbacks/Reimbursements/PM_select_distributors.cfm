

<script src="/debug.js"></script>

<CFIF isdefined("URL.FormName")>
	<FORM ACTION="pm_select_distributors.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
		<INPUT NAME="ParentFormname" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.FormName#</CFOUTPUT>">
		
		<cfif isDefined("url.OnlyDistributorsUnderMe")>
		<INPUT NAME="OnlyDistributorsUnderMe" Type="Hidden" value="<cfoutput>#URL.OnlyDistributorsUnderMe#</cfoutput>">
		<cfelse>
		<input name="OnlyDistributorsUnderMe" type="hidden" value="0">
		</cfif>
		<cfif isDefined("url.Program_List")>
		<input type="hidden" name="Program_List" value="<cfoutput>#url.Program_List#</cfoutput>">
		<cfelse>
		<input type="hidden" name="Program_List" value="0">
		</cfif>
		<INPUT NAME="FinalItemList" TYPE="HIDDEN" VALUE="">
	</FORM>
	<script>
		if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT> != null){
			this.document.all.FinalItemList.value = window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.all.Distributor_List.value
			document.all.MyForm.submit()
		}
		else{
			alert("The Data Needed From The Parent Form Isn't Available. This Window Will Close!")
			window.close()
		}
	</script>
	<cfabort>
</CFIF>

<CFPARAM NAME="Form.Ship_To" 	DEFAULT="">
<CFPARAM NAME="FORM.DOSEARCH" 	DEFAULT="0">
<CFPARAM NAME="URL.CID" 		DEFAULT="">


<CFIF len(trim(URL.CID)) GT 0>
	<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">

	<cfquery name="GetContractInfo" Datasource="#application.datasource#">
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

<CFSET PAGE_TITLE="Select Program Distributors">
<CFSET GROUP="Contracts">



<CFPARAM name="FORM.button_caption"	default="continue">
<CFPARAM NAME="FORM.searchstring" DEFAULT="">
<CFPARAM NAME="FORM.SelectedITEMS" DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingitems" DEFAULT="0">
<CFPARAM NAME="FORM.LoadSavedDistributors"	Default="1">
<CFPARAM NAME="FORM.SelectSingleSearchResultOnly"	Default="0">
<CFPARAM NAME="FORM.OnlyDistributorsUnderMe" Default="1">
<CFPARAM NAME="FORM.AllowImportAll"	Default="0">
<CFPARAM NAME="Program_List" Default="0">

<!---Sets it so that this only allows the user to select one distributor--->
<CFSET FORM.SelectSingleSearchResultOnly = 1>

<!---Only allows selection of distributors under my position--->
<cfif isDefined("FORM.OnlyDistributorsUnderMe")>
<cfif FORM.OnlyDistributorsUnderMe EQ 1>
	<CFSET FORM.OnlyDistributorsUnderMe = 1>
<cfelse>
	<CFSET FORM.OnlyDistributorsUnderMe = 0>
</cfif>
</cfif>
<!--- <cfoutput>#Form.OnlyDistributorsUnderMe#</cfoutput> --->

<CFPARAM NAME="startrow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<cf_Number_of_Rows maxrows=10>

<!---If there are existing saved distributors--->
<CFSET FORM.LoadSavedDistributors=0>
<CFIF FORM.LoadSavedDistributors EQ 1>
	<cfquery name="CheckForExistingDistributors" Datasource="#application.datasource#">
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

<!---If only searching for a single result--->
<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
	<CFIF listlen(FORM.FinalItemList) GT 0>
		<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
			<CFSET LocationOfItemToDelete = listfind(FORM.FinalItemList,ListItem, ",")>
			<CFIF LocationOfItemToDelete GT 0>
				<CFSET Form.FinalItemList = listdeleteat(FORM.FinalItemList, listfind(FORM.FinalItemList,ListItem, ","), ",")>
			</CFIF>
		</CFLOOP>
	</CFIF>
<CFELSE>
	<cfif len(trim(FORM.SelectedITEMS)) GT 0>
		<CFSET Form.FinalItemList = FORM.SelectedITEMS>
	</cfif>
</CFIF>


<CFIF FORM.finishedselectingitems EQ 1>
	<cfif len(trim(Form.FinalItemList)) GT 0>
	<script>
		opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.Distributor_List.value = '<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>'
		opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.submit()
		window.close()		
	</script>
	<CFABORT>
	<cfelse>
	<div align="Center">
	<Font color="red"><strong>You must select a <cfoutput>#application.returned_customer_setting.distributor_label_singular#</strong></cfoutput>.</FONT></div>
	</cfif>
</CFIF>


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
<INPUT NAME="OnlyDistributorsUnderMe" Type="Hidden" value="<cfoutput>#FORM.OnlyDistributorsUnderMe#</cfoutput>">
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
	    <cfoutput><LEGEND STYLE="font: bold 14px sans-serif; color: Red;">#lcase(application.returned_customer_setting.distributor_label_singular)# search</LEGEND></cfoutput>
			<TABLE>
				<TR>
					<TD COLSPAN="2"><!--- Family Name --->
						<span ID="searchItemLabel">Family Name</span><BR>
						<cfquery name="GetFamilyNames" Datasource="#application.datasource#">
							SELECT *
							FROM Distributor_Family
							WHERE Deleted = 0
							ORDER BY Family_Name
						</cfquery>
						<CFPARAM NAME="FORM.Family_Name" DEFAULT="0">
						<SELECT NAME="Family_Name" style="width: 200px;">
							<OPTION VALUE="0">**ALL** Family Names</OPTION>
							<CFOUTPUT QUERY="GetFamilyNames"><OPTION VALUE="#trim(GetFamilyNames.Family_ID)#"#IIF(trim(FORM.Family_Name) EQ trim(GetFamilyNames.Family_ID), DE(" SELECTED"), DE(""))#>#trim(GetFamilyNames.Family_Name)#</OPTION></CFOUTPUT>
						</SELECT>					
					</TD>
					<TD><!--- Buying Groups --->
						<span ID="searchItemLabel">Buying Groups</span><BR>
						<cfquery name="GetBuyingGroups" Datasource="#application.datasource#">
							SELECT *
							FROM Distributor_Buying_Groups
							WHERE Deleted = 0
							ORDER BY Buying_Group_Name
						</cfquery>
						<CFPARAM NAME="FORM.Buying_Group" DEFAULT="0">
						<SELECT NAME="Buying_Group" style="width: 200px;">
							<OPTION VALUE="0">**ALL** Buying Groups</OPTION>
							<CFOUTPUT QUERY="GetBuyingGroups"><OPTION VALUE="#trim(GetBuyingGroups.Buying_Group_ID)#"#IIF(trim(FORM.Buying_Group) EQ trim(GetBuyingGroups.Buying_Group_ID), DE(" SELECTED"), DE(""))#>#trim(GetBuyingGroups.Buying_Group_Name)#</OPTION></CFOUTPUT>
						</SELECT>					
					</TD>
					<TD><!--- Line Of Biz --->
						<span ID="searchItemLabel">Line Of Business</span><BR>
						<cfquery name="GetLinesOfBiz" Datasource="#application.datasource#">
							SELECT *
							FROM Line_Of_Business
							WHERE Deleted = 0
							ORDER BY Line_Of_Business_Name
						</cfquery>
						<CFSET First_Time = NOT Isdefined("FORM.Line_Of_Biz")>
						<CFPARAM NAME="FORM.Line_Of_Biz" DEFAULT="0">
						<SELECT NAME="Line_Of_Biz" style="width: 200px;">
							<OPTION VALUE="0">**ALL** Lines Of Business</OPTION>
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
						<span ID="searchItemLabel">Zone</span><BR>
						<CFQUERY NAME="GetZones" Datasource="#application.datasource#">
						SELECT *
						FROM Service_Zones
						WHERE len(Zone_Name) != 0 AND Deleted = 0
						ORDER BY Zone_Name
						</CFQUERY>
						<CFPARAM NAME="FORM.Zone_ID" DEFAULT="0">
						<SELECT NAME="Zone_ID" style="width: 200px;">
							<OPTION VALUE="0">**ALL** Zones</OPTION>
							<CFOUTPUT QUERY="GetZones"><OPTION VALUE="#trim(GetZones.Service_Zone_ID)#"#IIF(trim(FORM.Zone_ID) EQ GetZones.Service_Zone_ID, DE(" SELECTED"), DE(""))#>#trim(GetZones.Zone_Name)#</OPTION></CFOUTPUT>
						</SELECT>	
					</TD>
					<TD><!--- Regions --->
						<span ID="searchItemLabel">Region</span><BR>
						<CFQUERY NAME="GetRegions" Datasource="#application.datasource#">
						SELECT *
						FROM Service_Regions
						WHERE len(Region_Name) != 0 AND Deleted = 0
						ORDER BY Region_Name
						</CFQUERY>
						<CFPARAM NAME="FORM.Region_ID" DEFAULT="0">
						<SELECT NAME="Region_ID" style="width: 200px;">
							<OPTION VALUE="0">**ALL** Regions</OPTION>
							<CFOUTPUT QUERY="GetRegions"><OPTION VALUE="#trim(GetRegions.Service_Region_ID)#"#IIF(trim(FORM.Region_ID) EQ getRegions.Service_Region_ID, DE(" SELECTED"), DE(""))#>#trim(GetRegions.Region_Name)#</OPTION></CFOUTPUT>
						</SELECT>	
					</TD>					
					<!--- Get Foodservice Line Of Business ID --->
					<cfquery name="GetFirstDefaultBiz" dbtype="query">
						SELECT Line_Of_Business_ID
						FROM GetLinesOfBiz
						WHERE Line_Of_Business = '#ListFirst(application.returned_customer_setting.Line_Business_Default,",")#'
					</cfquery>
					<TD><!--- Brokers --->
						<span ID="searchItemLabel">Broker</span><BR>
						<cfquery name="GetBrokers" Datasource="#application.datasource#">
							SELECT *
							FROM BSA_Foodservice_Brokers
							WHERE  ACTIVE_CODE = 'A' AND Line_Of_Business_ID = '#GetFirstDefaultBiz.Line_Of_Business_ID#' AND Deleted = 0
							ORDER BY Broker_Name
						</cfquery>
						<CFPARAM NAME="FORM.Broker" DEFAULT="0">
						<SELECT NAME="Broker" style="width: 200px;">
							<OPTION VALUE="0">**ALL** Brokers</OPTION>
							<CFOUTPUT QUERY="GetBrokers"><OPTION VALUE="#trim(GetBrokers.BSA_Foodservice_Brokers_ID)#"#IIF(trim(FORM.Broker) EQ trim(GetBrokers.BSA_Foodservice_Brokers_ID), DE(" SELECTED"), DE(""))#>#trim(GetBrokers.Broker_Name)#</OPTION></CFOUTPUT>
						</SELECT>	
					</TD>					
			</TR>
			<TR>
				<TD NOWRAP ALIGN="left">
					Sort By<BR>
					<CFSET sort_By_List="Name,Ship To,Address,City,State,Postal Code,Broker,Family,Buying Group">
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
					<TD COLSPAN="2" NOWRAP>
						Name<BR><INPUT TYPE="Text" NAME="searchstring" STYLE="WIDTH:405px" SIZE="57"<CFIF len(trim(FORM.searchstring)) GT 0>VALUE="<CFOUTPUT>#trim(FORM.searchstring)#</CFOUTPUT>"</CFIF>>
				<!------<INPUT TYPE="Submit" VALUE="search">----->
						<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">
					</TD>
					<TD ALIGN="left" NOWRAP>
	<cfoutput>#application.returned_customer_setting.shard_ship_to_label#</cfoutput><BR><INPUT SIZE="7" TYPE="TEXT" NAME="Ship_To" VALUE="<CFOUTPUT>#Form.Ship_To#</CFOUTPUT>">
					</TD>
			</TR>
			<TR>
				<TD>
					<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10"><BR>
					<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript:document.MyForm.submit();">search <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput></a><FONT COLOR="#FF0000">]</FONT></B>
				</TD>
			</TR>

			</TABLE>
				
	</FIELDSET>

	<CFQUERY NAME="GetDistInfo" DATASOURCE="#application.datasource#">
		SELECT *
		FROM BSA_Foodservice_Customers
		WHERE BSA_Foodservice_Customers_ID <CFIF FORM.FinalItemList EQ 0>IS NULL<CFELSEIF listlen(FORM.FinalItemList) GT 0>IN(#listqualify(FORM.FinalItemList, "'", ",")#)<CFELSE>!= BSA_Foodservice_Customers_ID</CFIF> AND deleted = 0
	</CFQUERY>

	
	<FIELDSET STYLE="padding:2px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">currently selected <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput></LEGEND>
			<CFIF GetDistInfo.recordcount GT 0>
				<TABLE border="0" cellspacing="3" cellpadding="3" align="left" WIDTH="700" BGCOLOR="white">
					<TR><CFOUTPUT QUERY="GetDistInfo">
						<TD NOWRAP BGCOLOR="eeeeee" STYLE="cursor: pointer;" onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#GetDistInfo.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');"">#GetDistInfo.name#</TD>
		 				<CFIF GetDistInfo.currentrow mod 4><CFELSE></TR><TR></CFIF>
					</CFOUTPUT>	
				</TABLE>
			<CFELSE>
				<CFIF FORM.FinalItemList EQ 0>ALL DISTRIBUTORS<CFELSE>NONE</CFIF>
			</CFIF>
			<BR>
	</FIELDSET>

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
	<CFCASE value="Postal Code">
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
	<CFQUERY NAME="TheQuery" DATASOURCE="#application.datasource#">
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
		WHERE 0 = 0 
		
			<cfif Program_List NEQ 0>
			AND dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN
				(
				SELECT BSA_Foodservice_Customers_ID 
				FROM Contract_Distributors
				WHERE Contract_Main_ID = #Program_List#
				)
			</cfif>
			
			AND dbo.BSA_Foodservice_Customers.DELETED = 0 
			<!---If limited by distributors they can see--->
		<!--- 	<cfif FORM.OnlyDistributorsUnderMe IS 1>
				<cfif listlen(DistributorList) GT 0>
			AND dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN
			(#preservesinglequotes(DistributorList)#)
				<cfelse>
				<!---If they don't have any distributors in the list they have permission to see, this query fails no matter what--->
				AND 0 = 1
				</cfif>
			</cfif> --->
		
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
 
	 	<CFIF Len(Trim(Form.Ship_To)) GT 0>
			AND dbo.BSA_Foodservice_Customers.Shr_Ship_To LIKE '%#Form.Ship_To#%'
		</CFIF>
 
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
	<SCRIPT>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			function CA() {
				if(<CFIF TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> in the list below while selecting them all. Press OK If You Wish To Continue")<CFELSE>0==0</CFIF>) {
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
					<CFIF FORM.SelectSingleSearchResultOnly EQ 0><TD align="center"><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Distributors"></TD><CFELSE><td>&nbsp;</td></CFIF>
									<cfoutput>
				<CFSET HeaderNameList = "Name / #application.returned_customer_setting.shard_ship_to_label#,Address,Broker,Family / Buying Group">
				<CFSET HeaderColumnList = "Name,Address,Broker,Family">
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
					<TD ID="header" align="left"><A HREF="##" OnClick="javaScript: return sortByThisItem(this,'#listgetat(HeaderColumnList,Counter)#','#New_Sort_Order#');">#this_Header#<CFIF Len(sortImage) GT 0> <IMG BORDER="0" SRC="/Images/#sortImage#"></CFIF></A></TD>
					<CFSET Counter = Counter + 1>
					</CFLOOP>
				</cfoutput>

<!--- 					<TD align="left" ID="header"><B>Name / Ship To</B></TD>
					<TD ID="header"><B>Address</B></TD>
					<TD ID="header"><B>Broker</B></TD>
					<TD ID="header"><B>Family / Buying Group</B></TD> --->

				</TR>
			
			<CFOUTPUT QUERY="TheQuery" startrow="#StartRow#" maxrows="#MaxRows#">
				<TR STYLE="cursor:pointer;" <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
					<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
						<TD align="center"><INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Foodservice_Customers_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.BSA_Foodservice_Customers_ID), ",")></CFIF>></TD>
					<CFELSE>
						<TD align="center"><INPUT type="Radio" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Foodservice_Customers_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.BSA_Foodservice_Customers_ID), ",")></CFIF>></TD>
					</CFIF>
					<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#TheQuery.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;" NOWRAP>#TheQuery.Name#<BR>#TheQuery.Shr_Ship_To#&nbsp;</TD>
					<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#TheQuery.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;">#TheQuery.Address_1#<BR>#TheQuery.City#,#TheQuery.State# #TheQuery.ZipCode#&nbsp;</TD>
					<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#TheQuery.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;" >#TheQuery.Broker_Name#&nbsp;</TD>
					<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#TheQuery.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;" NOWRAP>#TheQuery.Family_Name#<BR>#TheQuery.Buying_Group_Name#&nbsp;</TD>
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
<INPUT TYPE="hidden" NAME="ParentFormname" VALUE="<CFOUTPUT>#FORM.ParentFormname#</CFOUTPUT>">	
<INPUT TYPE="hidden" NAME="FinalItemList" ID="FinalItemList" VALUE="<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="AlreadySelectedItems" ID="AlreadySelectedItems" VALUE="<CFOUTPUT>#Form.AlreadySelectedItems#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="finishedselectingitems" VALUE="0">
<INPUT TYPE="hidden" NAME="LoadSavedDistributors" VALUE="0">
<input type="hidden" name="button_caption" value="<CFOUTPUT>#FORM.Button_Caption#</CFOUTPUT>">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="<CFOUTPUT>#startrow#</CFOUTPUT>">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="<CFOUTPUT>#frompage#</CFOUTPUT>">
<INPUT TYPE="Hidden" NAME="editcurrentweight" VALUE="0">
<INPUT TYPE="Hidden" NAME="Program_List" value="<cfoutput>#Program_List#</cfoutput>">

<!---<br>
 <cfinclude template="select_forms_buttons.cfm"> --->

</FORM>

	<cfif TheQuery.recordcount GT 0>
	<DIV ALIGN="center">
	&nbsp;&nbsp;&nbsp;
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" onClick="javascript: finishedSearching()"> import selected <cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput><CFIF FORM.AllowImportAll EQ 1>s</CFIF> </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<CFIF FORM.AllowImportAll EQ 1>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: pointer;" onClick="importAllProducts(<CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT>)"> import all returned <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput> </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: pointer;" onClick="removeAllProducts()"> remove all selected <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput> </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>	
	</DIV>
	</CFIF>
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