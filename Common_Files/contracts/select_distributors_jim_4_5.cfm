<CFSET PAGE_TITLE="Create New Contract - 4 of 6">
<CFSET GROUP="Contracts">

<CFPARAM NAME="URL.CID" DEFAULT="">
<CFPARAM NAME="URL.RO" DEFAULT="0">

<CFPARAM name="FORM.button_caption"					default="continue">

<CFIF len(trim(URL.CID)) GT 0 AND URL.RO EQ 1>
		<CF_CRYP type="de" string="#URL.CID#" key="#request.key#">
		<cfquery name="CheckForExistingDistributors" datasource="#application.datasource#">
			SELECT 	Distributor_IDs
			FROM Contract_Main
			WHERE Contract_Main_ID = '#cryp.value#'
		</cfquery>		
	<CFSET FORM.button_caption = "save">

	<CFIF listfind(CheckForExistingDistributors.Distributor_IDs, 0, ",") EQ 0>
		<CFSET FORM.FinalItemList = valuelist(CheckForExistingDistributors.Distributor_IDs)>	
	</CFIF>

	<CFSET FORM.Contract_Main_ID = cryp.value>
</CFIF>



<CFPARAM NAME="FORM.searchstring" DEFAULT="">
<CFPARAM NAME="FORM.SelectedITEMS" DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingitems" DEFAULT="0">
<CFPARAM NAME="FORM.Contract_Main_ID" DEFAULT="">

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
		<CFSET Form.FinalItemList = listdeleteat(FORM.FinalItemList, listfind(FORM.FinalItemList,ListItem, ","), ",")>
	</CFLOOP>
	


<CFIF FORM.finishedselectingitems EQ 1>

		<cfquery name="CheckForExistingDistributors" datasource="#application.datasource#">
			SELECT 	Distributor_IDs
			FROM Contract_Main
			WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#'
		</cfquery>		


		<CFIF isdefined("FORM.ALLINCATEGORY")><CFSET FORM.FinalItemList = "ALL"><CFELSE><CFIF listfind(FORM.FinalItemList, "ALL") NEQ 0><CFSET FORM.FinalItemList = listdeleteat(FORM.FinalItemList,listfind(FORM.FinalItemList, "ALL"),",")></CFIF></CFIF>
		<CFIF len(trim(FORM.FinalItemList)) EQ 0><CFSET FORM.FinalItemList = "0"></CFIF>


		<CFQUERY NAME="SaveDistributors" datasource="#application.datasource#">
			UPDATE Contract_MAIN
			SET Distributor_IDs = '#FORM.FinalItemList#'
			WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#'
		</CFQUERY>		

	<CF_CRYP type="en" string="#FORM.Contract_Main_ID#" key="#request.key#">	
	<CFIF CheckForExistingDistributors.Distributor_IDs EQ 0>
		<CFLOCATION url="redirect.cfm?destination=select_Products.cfm&CID=#cryp.value#">	
	<CFELSE>
		<cflocation url="Contract_Edit_Menu.cfm?CID=#cryp.value#">
	</CFIF>

	

</CFIF>



<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

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
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFIF len(FORM.Contract_Main_ID) GT 0><CFSET temp = FORM.Contract_Main_ID></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "di"> 
<CFINCLUDE TEMPLATE="contract_status_legend.cfm">


<BLOCKQUOTE><BLOCKQUOTE>
<!--- 
	<CFSET URL.Contract_Main_ID = FORM.Contract_Main_ID>
	<CFINCLUDE TEMPLATE="thin_contract_general_display.cfm">
	--->
<CFSET helpfilenumber=5>
<cfinclude template="minimal_contract_info.cfm">



	<FORM ACTION="select_distributors.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
	<FIELDSET STYLE="padding:8px; width: 800px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">distributor search</LEGEND>
			<TABLE>
				<TR>
					<TD>
						<cfquery name="GetFamilyNames" datasource="#application.datasource#">
							SELECT DISTINCT Family_Name
							FROM BSA_Foodservice_Customers
						</cfquery>
						<CFPARAM NAME="FORM.Family_Name" DEFAULT="0">
						<SELECT NAME="Family_Name" style="width: 200px;">
							<OPTION VALUE="0">**ALL** Family Names</OPTION>
							<CFOUTPUT QUERY="GetFamilyNames"><OPTION VALUE="#trim(GetFamilyNames.Family_Name)#"#IIF(trim(FORM.Family_Name) EQ trim(GetFamilyNames.Family_Name), DE(" SELECTED"), DE(""))#>#trim(GetFamilyNames.Family_Name)#</OPTION></CFOUTPUT>
						</SELECT>					
					</TD>
					<TD>
						<cfquery name="GetBrokers" datasource="#application.datasource#">
							SELECT DISTINCT Broker_Legcy_Shard, Broker_Name
							FROM BSA_Foodservice_Brokers
							ORDER BY Broker_Name
						</cfquery>
						<CFPARAM NAME="FORM.Broker" DEFAULT="0">
						<SELECT NAME="Broker" style="width: 190px;">
							<OPTION VALUE="0">**ALL** Brokers</OPTION>
							<CFOUTPUT QUERY="GetBrokers"><OPTION VALUE="#trim(GetBrokers.Broker_Legcy_Shard)#"#IIF(trim(FORM.Broker) EQ trim(GetBrokers.Broker_Legcy_Shard), DE(" SELECTED"), DE(""))#>#trim(GetBrokers.Broker_Name)#</OPTION></CFOUTPUT>
						</SELECT>	
					</TD>
					<TD>
						<cfquery name="GetStates" datasource="#application.datasource#">
							SELECT DISTINCT State
							FROM BSA_Foodservice_Customers
						</cfquery>
						<CFPARAM NAME="FORM.State" DEFAULT="0">
						<SELECT NAME="State" style="width: 182px;">
							<OPTION VALUE="0">**ALL** States</OPTION>
							<CFOUTPUT QUERY="GetStates"><OPTION VALUE="#trim(GetStates.state)#"#IIF(trim(FORM.state) EQ trim(GetStates.state), DE(" SELECTED"), DE(""))#><CFIF len(trim(GetStates.state)) EQ 0>Sate Not Specified<CFELSE>#trim(GetStates.state)#</CFIF></OPTION></CFOUTPUT>
						</SELECT>					
					</TD>
					<TD>
						<cfquery name="GetBrokers" datasource="#application.datasource#">
							SELECT DISTINCT Market_Area, Broker_Legcy_Shard, Broker_Name
							FROM BSA_Foodservice_Brokers
							ORDER BY Market_Area
						</cfquery>
						<CFPARAM NAME="FORM.Market_Area" DEFAULT="0">
						<SELECT NAME="Market_Area" style="width: 190px;">
							<OPTION VALUE="0">**ALL** Broker Market Areas</OPTION>
							<CFOUTPUT QUERY="GetBrokers"><OPTION VALUE="#trim(GetBrokers.Market_Area)#"#IIF(trim(FORM.Market_Area) EQ trim(GetBrokers.Market_Area), DE(" SELECTED"), DE(""))#>#trim(GetBrokers.Market_Area)#</OPTION></CFOUTPUT>
						</SELECT>					
					</TD>
				</TR>

			</TABLE>
				Search String: <INPUT TYPE="Text" NAME="searchstring" SIZE="57"<CFIF len(trim(FORM.searchstring)) GT 0>VALUE="<CFOUTPUT>#trim(FORM.searchstring)#</CFOUTPUT>"</CFIF>>
				<INPUT TYPE="Submit" VALUE="search">
				<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">
	</FIELDSET>

	<CFQUERY NAME="GetDistInfo" datasource="#application.datasource#">
		SELECT *
		FROM BSA_Foodservice_Customers
		WHERE BSA_Foodservice_Customers_ID IN(<CFIF len(FORM.FinalItemList) EQ 0 OR FORM.FinalItemList EQ "ALL">0<CFELSE>#FORM.FinalItemList#</CFIF>)
	</CFQUERY>
	<FIELDSET STYLE="padding:8px; width: 800px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">currently selected <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput></LEGEND>
			<CFIF GetDistInfo.recordcount GT 0>
				<TABLE border="0" cellspacing="3" cellpadding="3" align="left" WIDTH="100%" BGCOLOR="white">
					<TR><CFOUTPUT QUERY="GetDistInfo">
						<TD NOWRAP BGCOLOR="eeeeee">#GetDistInfo.Name#</TD>
		 				<CFIF GetDistInfo.currentrow mod 4><CFELSE></TR><TR></CFIF>
					</CFOUTPUT>	
				</TABLE>
			<CFELSE>
				<CFIF FORM.FinalItemList EQ "ALL">ALL DISTRIBUTORS<CFELSE>NONE</CFIF>
			</CFIF>
			<BR>
	</FIELDSET>

<BR>

<INPUT TYPE="checkbox" NAME="ALLINCATEGORY" VALUE="1"  <CFIF FORM.FinalItemList EQ "ALL">checked</CFIF>>SELECT ALL DISTRIBUTORS

<cfinclude template="select_forms_buttons.cfm">

<CFIF isdefined("FORM.DOSEARCH")>
	<CFSET form.searchstring = trim(form.searchstring)>
	<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
SELECT dbo.BSA_Foodservice_Brokers.*, 
    dbo.BSA_Foodservice_Customers.*
FROM dbo.BSA_Foodservice_Brokers INNER JOIN
    dbo.BSA_Foodservice_Customers ON 
    dbo.BSA_Foodservice_Brokers.Broker_Legcy_Shard = dbo.BSA_Foodservice_Customers.Std_Broker
		WHERE
			0 = 0 AND dbo.BSA_Foodservice_Customers.DELETED = 0 
		<CFIF FORM.Family_Name NEQ 0>
			AND dbo.BSA_Foodservice_Customers.Family_Name = '#FORM.Family_Name#'
		</CFIF>

		<CFIF FORM.Broker NEQ 0>
			AND BSA_Foodservice_Customers.std_broker = '#FORM.Broker#'
		</CFIF>

		<CFIF FORM.State NEQ 0>
			AND BSA_Foodservice_Customers.state = '#FORM.State#'
		</CFIF>

		<CFIF FORM.Market_Area NEQ 0>
			AND BSA_Foodservice_Brokers.Market_Area = '#FORM.Market_Area#'
		</CFIF>
		
		<CFIF len(trim(FORM.searchstring)) GT 0>
		AND
		(
			(
				Name = '#form.searchstring#'
				OR
				Name LIKE '%#form.searchstring#'
				OR
				Name LIKE '#form.searchstring#%'
				OR
				Name LIKE '%#form.searchstring#%'
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
				Family_Name = '#form.searchstring#'
				OR
				Family_Name LIKE '%#form.searchstring#'
				OR
				Family_Name LIKE '#form.searchstring#%'
				OR
				Family_Name LIKE '%#form.searchstring#%'
			)
			<CFIF isnumeric(form.searchstring)>
			OR
			(
				Shr_Family = '#form.searchstring#'
				OR
				Shr_Family LIKE '%#form.searchstring#'
				OR
				Shr_Family LIKE '#form.searchstring#%'
				OR
				Shr_Family LIKE '%#form.searchstring#%'
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
		order by name
	</CFQUERY>
	<SCRIPT>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			function CA() {
				if(<CFIF TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many distributors in the list below while selecting them all. Press OK If You Wish To Continue")<CFELSE>0==0</CFIF>) {
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


	<FIELDSET STYLE="padding:8px; width: 800; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF TheQuery.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1>#application.returned_customer_setting.distributor_label_singular#<CFELSE>#application.returned_customer_setting.distributor_label_plural#</CFIF> That <CFIF TheQuery.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Above Criteria</LEGEND>
		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF TheQuery.recordcount GT 0>
			<TABLE border="0" cellspacing="0" cellpadding="0" align="center" WIDTH="100%" CLASS="Maintable">
				<TR ID="header" BGCOLOR="#ffce84">
					<TD align="center"><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Distributors"></TD>
					<TD>Ship-to #</TD>
					<TD align="left">Distributor Name</TD>
					<TD>City</TD>
					<TD ALIGN="center">State</TD>
					<!--- <TD>Shared Family Code</TD> --->
					<TD>Family Name</TD>
				</TR>
			<CFOUTPUT QUERY="TheQuery">
				<cf_cryp type="en" string="#TheQuery.BSA_Foodservice_Customers_ID#" key="#request.key#">
				<TR STYLE="cursor:hand;" <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
					<TD align="center"><INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Foodservice_Customers_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.BSA_Foodservice_Customers_ID), ",")></CFIF>></TD>
					<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#cryp.value#','name','400','450','Yes', 'No');return false;">#TheQuery.Ship_To#</TD>
					<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#cryp.value#','name','400','450','Yes', 'No');return false;" NOWRAP>#TheQuery.Name#</TD>
					<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#cryp.value#','name','400','450','Yes', 'No');return false;">#TheQuery.City#</TD>
					<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#cryp.value#','name','400','450','Yes', 'No');return false;" ALIGN="center">#TheQuery.State#</TD>
					<!--- <TD>#TheQuery.Shr_Family#</TD> --->
					<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#cryp.value#','name','400','450','Yes', 'No');return false;">#TheQuery.Family_Name#&nbsp;</TD>
 				</TR>
			</CFOUTPUT>
			</TABLE>
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
	findselectboxes()	
		
	</SCRIPT>
<INPUT TYPE="hidden" NAME="FinalItemList" VALUE="<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="AlreadySelectedItems" VALUE="<CFOUTPUT>#Form.AlreadySelectedItems#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="finishedselectingitems" VALUE="0">
<INPUT TYPE="hidden" NAME="Contract_Main_ID" VALUE="<CFOUTPUT>#FORM.Contract_Main_ID#</CFOUTPUT>">



<input type="hidden" name="button_caption" value="<CFOUTPUT>#FORM.Button_Caption#</CFOUTPUT>">

<br>
<!--- <cfinclude template="select_forms_buttons.cfm"> ---></FORM>
</BLOCKQUOTE></BLOCKQUOTE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
