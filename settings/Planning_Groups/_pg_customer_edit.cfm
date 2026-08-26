<!-----------------------------------------------------------------------------

FILE NAME:		_pg_customer_Edit.cfm
DESCRIPTION:
CREATED BY:		10-Aug-2010
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

      			Anand Rao	  10-Aug-2010	Created the file
------------------------------------------------------------------------------>
<cfparam name="url.Is_System" default="0" >
<cfset qryGetPGCustomerCategoryByID = PGManager.fnGetPGCustomerCategoryByID(FORM.PGCustomerCategoryID) />
<cfset DistGroupDataManager = CreateObject("component", "components.customer.Group.DataManager").init() />
<cfset bDistPayeeExist = PGManager.checkDistributorPayeeExists(FORM.PGCustomerCategoryID)>
<cfset bVendorPayeeExist = PGManager.checkVendorPayeeExists(FORM.PGCustomerCategoryID)>

<cfset bDistPayeeNotExistOnPG = PGManager.checkDistributorPayeeOnPGNotPGMember(FORM.PGCustomerCategoryID)>
<cfset bVendorPayeeNotExistOnPG = PGManager.checkVendorPayeeOnPGNotPGMember(FORM.PGCustomerCategoryID)>

<cfif FORM.OrderBy EQ "ASC">
	<cfset newOrderBy = "DESC">
<cfelse>
	<cfset newOrderBy = "ASC">
</cfif>

<cfset vOrderByField = "Group_Name" />
<cfif FORM.OrderByField NEQ "">
 	<cfset vOrderByField = FORM.OrderByField />
</cfif>
<cfset vSearchKeyword = "" />
<cfif FORM.MemSearchKeyword NEQ "">
	<cfset vSearchKeyword = FORM.MemSearchKeyword />
</cfif>

<cfparam name="Form.Distributor_id" default="">
<cfparam name="Form.Vendor_ID" default="">
<cfparam name="Form.BusinessSegmentID" default="0">
<cfparam name="Selected_Distributor" default="">
<cfparam name="Selected_Vendor" default="">
<cfparam name="Selected_Vendor_Master_ID" default="">

<!--- If the "distributor" payee exists.
It will exist when the user selects a distributor from the popup page OR an already selected distributor stored in the db. --->
<CFIF Form.Distributor_id NEQ "" OR qryGetPGCustomerCategoryByID.Distributor_id NEQ "">
	<CFQUERY NAME="Dist_Search_Result" DATASOURCE = "#Application.Datasource#">
		SELECT	BSA_Foodservice_Customers_ID, Name, Ship_To, Shr_Ship_To, Business_Segment_ID
		FROM 	BSA_Foodservice_Customers
		<cfif Form.Distributor_id neq "">
		WHERE	BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = '#Form.Distributor_id#'
		<cfelseif qryGetPGCustomerCategoryByID.Distributor_id neq "">
		WHERE	BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = '#qryGetPGCustomerCategoryByID.Distributor_id#'
		</cfif>
		AND		BSA_Foodservice_Customers.Deleted = 0
		AND		BSA_Foodservice_Customers.Active_Code = 'A'
		ORDER BY Name
	</CFQUERY>
	<cfset FORM.BusinessSegmentID = Dist_Search_Result.Business_Segment_ID />	
	<!--- Get the distributor's name --->
	<!--- <CFSET Selected_Distributor=ValueList(Dist_Search_Result.Name)> --->
	<!--- D47749: Customer Planning Group - Need Payee Nbr displayed/ Anand Rao / 22-Jan-2015 --->
	<cfif Dist_Search_Result.Ship_To EQ "" AND Dist_Search_Result.Shr_Ship_To EQ "" >
		<CFSET Selected_Distributor = Dist_Search_Result.Name>
	<cfelse>
		<cfif appSettings.get_Setting('Display_Distributor_ID') eq '1'>
			<cfset Selected_Distributor = Dist_Search_Result.Name & " (" & Dist_Search_Result.Shr_Ship_To & ")" >
		<cfelse>
			<cfset Selected_Distributor = Dist_Search_Result.Name & " (" & Dist_Search_Result.Ship_To & ")" >
		</cfif>
	</cfif>

	<!--- Store "distributor_id" in the "Form.distributor_id" variable. This is needed when the distributor value comes from the db.--->
	<CFSET Form.distributor_id = Dist_Search_Result.BSA_Foodservice_Customers_ID>
</cfif>

<!--- If the "vendor" payee exists.
It will exist when the user selects a vendor from the popup page OR an already selected vendor stored in the db. --->
<CFIF Form.Vendor_ID NEQ "" OR qryGetPGCustomerCategoryByID.Vendor_Master_ID NEQ "">
	<CFQUERY NAME="GetVendorID" DATASOURCE = "#Application.Datasource#">
		SELECT Vendor_Master_ID, Vendor_ID, Vendor_Name
		FROM Vendor_Master
		<cfif Form.Vendor_ID neq "">
		WHERE Vendor_ID = '#Vendor_ID#'
		<cfelseif qryGetPGCustomerCategoryByID.Vendor_Master_ID neq "">
		WHERE	Vendor_Master_ID = '#qryGetPGCustomerCategoryByID.Vendor_Master_ID#'
		</cfif>
	</CFQUERY>
	<!--- Get the vendor's name --->
	<!--- D47749: Customer Planning Group - Need Payee Nbr displayed/ Anand Rao / 22-Jan-2015 --->
	<cfif GetVendorID.Vendor_ID EQ "">
		<CFSET Selected_Vendor = GetVendorID.Vendor_Name>
	<cfelse>
		<CFSET Selected_Vendor = GetVendorID.Vendor_Name & " (" & GetVendorID.Vendor_ID & ")" >
	</cfif>
	<!--- Get the vendor_master_Id too. The popup page only returns the vendor_id and we need to insert
	"Vendor_Master_ID" in the "PG_Customer_Category" table.
	--->
	<CFSET Selected_Vendor_Master_ID = GetVendorID.Vendor_Master_ID>
</CFIF>

<!---
  Distributor_Group_Level Table values:
  Business Segment - 1, Family - 2, Buying Group - 3, Line of Business - 4, Market - 23, Region -	24, Zone - 25
  The below function takes (Active, Include list, exclude List)
  So, we pick only the above values for the dropdown
--->

<cfquery name="qryDistList" datasource="#application.datasource#">
  SELECT DISTINCT(Distributor_Group_Level_ID) FROM Distributor_Group_Level WHERE Active= 1 AND Deleted = 0
</cfquery>

<cfset qGetTopLevelGroupsList = DistGroupDataManager.getDistributorLevels(1, "#ValueList(qryDistList.Distributor_Group_Level_ID)#", "") />
<cfset lsPGmembersList = "" />
<cfset qGetSystemPGTypes = PGManager.fnGetSystemPGTypes("2") />
<cfset lstSystemPGTypes = ValueList(qGetSystemPGTypes.PG_Type_ID) />

<style>
.Orangline
{
	border-right: 2px solid orange;
	/* width:400 px; */
}
.topLine
{
	border-top: 2px solid a85400;
	/* width:400 px; */
}
.disable{
	pointer-events:none;
	background-color: #edeef2;
	border: 1px solid #edeef2;
	color: #c4c5c7;
}
#t1044 td { padding-left: 3px; }
</style>
<!--- <cfset qryTemplateList = CreateObject("component","components.programs.template.TemplateManager").getAllTemplates() /> --->
<cfset qryTemplateList = CreateObject("component","components.programs.template.TemplateManager").getAllTemplatesForPGWithFilters('#New_Sort_Order#') />

<cfoutput>
	<cfif qryGetPGCustomerCategoryByID.Name_First NEQ "">
		<table bgcolor="White" style="border-color:Orange;border-style:solid;" cellpadding="3" cellspacing="0"  align="center" width="600">
	  	<tr>
	    	<td>
	      	<cfoutput>
	    	  	<font size="2"><b>The settings were last updated on #dateformat(qryGetPGCustomerCategoryByID.Updated_Date, 'mm/dd/yyyy')# #timeformat(qryGetPGCustomerCategoryByID.Updated_Date, 'hh:mm:ss TT')# by #qryGetPGCustomerCategoryByID.Name_First# #qryGetPGCustomerCategoryByID.Name_Last#</b></font>
	        </cfoutput>
	      </td>
	    </tr>
	  </table>
	</cfif>
	<cfif NOT isDefined("SESSION.qryGrpDistPack")>
  	<cfset SESSION.qryGrpDistPack = QueryNew("GroupLevel_ID, GroupLevel_Name, Group_Number, Group_Dist_ID, Description, Inc_Exc, IsPG, Business_Unit_Desc")>
	</cfif>


<input type="hidden" name="Distributor_List" value="">
<input type="hidden" name="DistributorListToExcludeFromSelecting" value="">
<input type="hidden" name="PG_Effective_Date_ON" value="#appSettings.get_Setting('PG_Eff_Date_Distributor')#">
<input type="hidden" name="PG_Effective_Date_Upload_Download" value="#appSettings.get_Setting('PG_Effective_Date_Upload_Download')#">

<cfif isDefined("FORM.GroupLevel_Name") AND FORM.GroupLevel_Name NEQ "">
  <input type="hidden" name="GroupLevel_Name" value="#FORM.GroupLevel_Name#" />
<cfelse>
  <input type="hidden" name="GroupLevel_Name" value="" />
</cfif>

<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">#application.returned_customer_setting.Distributor_Label_Singular# Planning Group Information</LEGEND>
 	<br>
	<table width="100%" border="0" cellpadding="4" cellspacing="4" cols="groups" rules="groups" bordercolor="a85400">
		<!--- If either the distributor payee or vendor payee is not selected or either of the two are not members of the planning group. --->
		<cfif appsettings.getPayeeFromPlanningGroups() eq 1 AND (bDistPayeeExist eq 0 OR bVendorPayeeExist eq 0 OR bDistPayeeNotExistOnPG eq 1 OR bVendorPayeeNotExistOnPG eq 1)>
		<tr>
  		<td colspan="2">
		<span style="color:red">
		<cfif bDistPayeeExist eq 0 OR bVendorPayeeExist eq 0>
		The configuration for this environment relies upon a Vendor and/or Distributor for Auto Pay processing involving planning groups.  If this planning group will be used for Auto Pay programs,
		it is recommended that you select both a Vendor and a Customer to identify the Payee of future Auto Pay records.
		<br />
		</cfif>
		<!---- Only when the payee actually exists, then check wthether the payee is not a member of the planning group.--->
		<cfif bDistPayeeExist eq 1 AND bDistPayeeNotExistOnPG eq 1><br />Note:The distributor payee does not exist as a member of the planning group.</cfif>
		<cfif bVendorPayeeExist eq 1 AND bVendorPayeeNotExistOnPG eq 1><br />Note:The vendor payee does not exist as a member of the planning group.</cfif>
		</span>
		</td>
 		</tr>
		</cfif>
		<tr>
  		<td colspan="2" height="6px;"> <font color="red" size="5">*</font> - Required Field</td>
 		</tr>
 <cfif appSettings.get_Setting('PG_Eff_Date_Product') eq '1' OR appSettings.get_Setting('PG_Eff_Date_Distributor') eq '1' OR appSettings.get_Setting('PG_Eff_Date_Operator') eq '1'>
  <tr>
    <td align="right"  width="30%">PG Number:</td>
    <td>#qryGetPGCustomerCategoryByID.PG_Number_Sequence#</td>
  </tr>
</cfif>
  	<tr>
    	<td align="right"  width="30%">
      	<strong>Planning Group Code: </strong>
    	</td>
    	<td>
        <input <cfif url.Is_System>class="disable"</cfif> tye="text" name="planningGroupCode" size="8" maxlength="20" <cfif (isDefined("FORM.planningGroupCode") AND FORM.planningGroupCode NEQ "")>value="#FORM.planningGroupCode#"<cfelse>value="#qryGetPGCustomerCategoryByID.PG_Customer_Category_Code#"</cfif>>
    	</td>
  	</tr>
  	<tr>
    	<td align="right"  width="30%" <!--- class="Orangline" --->>
      	<strong>Planning Group Name<font color="red" size="2">*</font>: </strong>
    	</td>
    	<td>
      	<input <cfif url.Is_System>class="disable"</cfif> tye="text" name="planningGroupName" size="60" maxlength="50" <cfif (isDefined("FORM.planningGroupName") AND FORM.planningGroupName NEQ "")>value="#FORM.planningGroupName#"<cfelse>value="#qryGetPGCustomerCategoryByID.PG_Customer_Category_Name#"</cfif>>
    	</td>
  	</tr>

  <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START--->
<cfif isBusinessSegEnabledForDistributor>
   <tr>
    <td align="right"  width="30%" <!--- class="Orangline" --->>
      <strong>#appSettings.getbusiness_segment_label()#<font color="red" size="2">*</font>: </strong>
    </td>
    <td>
      <input <cfif url.Is_System>class="disable"</cfif> tye="text" name="Business_Unit_Desc" size="25" value="#qryGetPGCustomerCategoryByID.Business_Unit_Desc#" readonly>
    </td>
  </tr>
  <cfset bsid = #qryGetPGCustomerCategoryByID.Business_Segment_Id#>
    <cfelse>
  <input type="hidden" name="business_segment" value="0">
  <cfset bsid = 0/>
</cfif>
 <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->

  	<tr>
    	<td align="right"  width="30%">
      	<strong>Type Name: </strong>
    	</td>
    	<td>
      <!---
      	The parameter passed:
      	1= Product
      	2= Customer
      	3= Operator
    	--->
				<cfset qGetActivePGTypeByGrpType = PGManager.fnGetActivePGTypesByGrpType("2") />
      	<select name="selTypeName" id="selTypeName" <cfif url.Is_System>class="disable"</cfif> >
        	<option value="0">Select a PG Type</option>
        	<cfloop query="qGetActivePGTypeByGrpType">
          	<option value="#qGetActivePGTypeByGrpType.PG_Type_ID#" <cfif (isDefined("FORM.SelTypeName") AND FORM.SeltypeName EQ qGetActivePGTypeByGrpType.PG_Type_ID)>selected<cfelseif qryGetPGCustomerCategoryByID.PG_Type_ID EQ qGetActivePGTypeByGrpType.PG_Type_ID>selected</cfif>>#qGetActivePGTypeByGrpType.PG_Type_Name#</option>
        	</cfloop>
      	</select>
    	</td>
  	</tr>
<cfif ((appSettings.get_Setting('PG_Eff_Date_Distributor') EQ '1') AND (appSettings.get_Setting('PG_Effective_Date_Upload_Download') NEQ '1'))>
  <tr>
    <td align="right"  width="30%">
      <strong>Effective Dates<font color="red" size="2">*</font>: <img src="/images/help_small.gif" title="The effective date is not a functional value in  FORGE and does not affect dates applied within programs, claims or reporting.  It is purely an attribute to facilitate communication with other systems."/></strong>
    </td>
    <td>
      Start Date <input type="text" name="PG_Effective_Start_Date" size="15" maxlength="10" <cfif (isDefined("FORM.PG_Effective_Start_Date") AND FORM.PG_Effective_Start_Date NEQ "")>value="#FORM.PG_Effective_Start_Date#"<cfelse>value="#dateformat(qryGetPGCustomerCategoryByID.PG_Effective_Start_Date,'mm/dd/yyyy')#"</cfif>>
	  End Date <input type="text" name="PG_Effective_End_Date" size="15" maxlength="10" <cfif (isDefined("FORM.PG_Effective_End_Date") AND FORM.PG_Effective_End_Date NEQ "")>value="#FORM.PG_Effective_End_Date#"<cfelse>value="#dateformat(qryGetPGCustomerCategoryByID.PG_Effective_End_Date,'mm/dd/yyyy')#"</cfif>>
   </td>
  </tr>
<cfelse>
	<input type="hidden" name="PG_Effective_Start_Date" <cfif (isDefined("FORM.PG_Effective_Start_Date") AND FORM.PG_Effective_Start_Date NEQ "")>value="#FORM.PG_Effective_Start_Date#"<cfelse>value="#dateformat(qryGetPGCustomerCategoryByID.PG_Effective_Start_Date,'mm/dd/yyyy')#"</cfif> />
	<input type="hidden" name="PG_Effective_End_Date" <cfif (isDefined("FORM.PG_Effective_End_Date") AND FORM.PG_Effective_End_Date NEQ "")>value="#FORM.PG_Effective_End_Date#"<cfelse>value="#dateformat(qryGetPGCustomerCategoryByID.PG_Effective_End_Date,'mm/dd/yyyy')#"</cfif> />
</cfif>

	  <!--- 34007 --->
	  <tr>
	  		<cfinclude template="removeMembers.cfm">
	  		<cfparam name="FORM.bCaptureRemoves" default="#qryGetPGCustomerCategoryByID.Capture_Removes#">
	  		<td><input <cfif url.Is_System>class="disable"</cfif> type="checkbox" name="bCaptureRemoves" <cfif FORM.bCaptureRemoves EQ "1">checked</cfif> value="1"></td>
	  </tr>
		<tr style="display:none">
    	<td align="right">
      	<strong>Include in other PG:</strong>
    	</td>
    	<td>
      	<input <cfif url.Is_System>class="disable"</cfif> type="checkbox" name="bIncludeInOthers" id="bIncludeInOthers" value="1" <cfif (isDefined("FORM.bIncludeInOthers") AND FORM.bIncludeInOthers EQ "1")>checked<cfelseif qryGetPGCustomerCategoryByID.Include_In_Other_PG EQ 1>checked</cfif> > <!--- onclick="displayRow('trPlanningGroups','bIncludeInOthers');"   --->
    	</td>
  	</tr>
		<tr>
    	<td align="right">
      	<strong>Include in other PG:</strong>
    	</td>
    	<td>
      	<input <cfif url.Is_System>class="disable"</cfif> type="checkbox" name="dummybIncludeInOthers" id="dummybIncludeInOthers" value="1" <cfif (isDefined("FORM.bIncludeInOthers") AND FORM.bIncludeInOthers EQ "1")>checked<cfelseif qryGetPGCustomerCategoryByID.Include_In_Other_PG EQ 1>checked</cfif>  disabled> <!--- onclick="displayRow('trPlanningGroups','bIncludeInOthers');"   --->
    	</td>
  	</tr>

    <tr>
      <td align="right">
        <strong>Master Data Groups Only:</strong>
      </td>
      <td>
        <input <cfif url.Is_System>class="disable"</cfif> type="checkbox" name="bMasterGroupOnly" id="bMasterGroupOnly" value="1"
              <cfif qryGetPGCustomerCategoryByID.Is_Master_Group EQ "1">checked</cfif> >
      </td>
    </tr>
   <cfif appsettings.getPayeeFromPlanningGroups() eq 1>
   <tr>
   <td align="right">
	 <strong>#application.returned_customer_setting.distributor_label_singular#:</strong>
   </td>
   <td>
	<Input <cfif url.Is_System>class="disable"</cfif> type="text" id="distributor_name" name="distributor_name" value="#Selected_Distributor#" readonly="1" size="40">
	<!--- We need to pass this to the action page as "PG_Customer_Category" table requires the GUID. --->
	<Input type="hidden" id="distributor_id" name="distributor_id" value="#form.distributor_id#">
	<cfif Get_Profile_Settings.Planning_Groups_Create EQ 2>
		<strong><span style="color:red">[ </span><a <cfif url.Is_System>class="disable"</cfif> href="##" onClick="searchDistributor();">select payee</a><span style="color:red">  ]</span></strong>
		<strong><span style="color:red">[ </span><a <cfif url.Is_System>class="disable"</cfif> href="##" onClick="deletePayeeDistributor();return false;">delete payee</a><span style="color:red">  ]</span></strong>
	</cfif>
   </td>
   </tr>
   <tr>
   <td align="right">
	 <strong>Vendor:</strong>
   </td>
   <td>
	<Input type="text" id="vendorName" name="vendorName" value="#Selected_Vendor#" readonly="1" size="40">
	<Input type="hidden" id="vendor_id" name="vendor_id" value="#form.vendor_id#">
	<!--- We need to pass this to the action page as "PG_Customer_Category" table requires the GUID. --->
	<Input type="hidden" id="vendor_master_id" name="vendor_master_id" value="#Selected_Vendor_Master_ID#">
	<cfif Get_Profile_Settings.Planning_Groups_Create EQ 2>
		<strong><span style="color:red">[ </span><a  href="##" onClick="searchVendor();">select payee</a><span style="color:red">  ]</span></strong>
		<strong><span style="color:red">[ </span><a  href="##" onClick="deletePayeeVendor();return false;">delete payee</a><span style="color:red">  ]</span></strong>
	</cfif>
   </td>
   </tr>
   </cfif>
  	<tr>
  		<td colspan="100%">
				<fieldset id="border_20" style="border-width:0; border-color:; border-style:solid; width:100%">
     			<legend>
      			<span>
        			<img id="image_20" src="/images/plus2.gif" onclick="switchlayer(20,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" border="0" title="" style="cursor:pointer">
     					<font face="Arial">
      					<b style="font-size:9pt">
       						<span id="title_20" onclick="switchlayer(20,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" style="color:00773c;cursor:pointer">
         					<span title="Click here to toggle the view">
		     						Edit Existing Members
         					</span>
       						</span>
      					</b>
     					</font>
     					</legend>
						<cfif (URL.EEMExpanded)>
							<cfset dspMembers = "block" />
						<cfelse>
							<cfset dspMembers = "none" />
						</cfif>
    				<div id="lyrgroup_20" style="display:#dspMembers#; visibility:inherit; z-index:5; margin-left:5; margin-right:5; margin-top:5; margin-bottom:8;">
     				<div id="masterContainer">

      <!--- Contents go here start--->
          <cfstoredproc procedure="Get_Customer_Group_Info_For_PG" datasource="#application.datasource#">
	          <cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@PG_Customer_Category_ID" value="#qryGetPGCustomerCategoryByID.PG_Customer_Category_ID#" null="no">
			  <cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Keyword" value="#vSearchKeyword#" null="no">
	          <cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@OrderByField" value="#vOrderByField#" null="no">
  	          <cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@OrderBy" value="#Form.OrderBy#" null="no">
            <cfprocresult name="qryPGCustomerCategoryDefinitionByID">
          </cfstoredproc>
          <!--- <cfif qryPGCustomerCategoryDefinitionByID.RecordCount EQ 0>
         No Members Found!!
        <cfelse> --->
		<table width="100%" cellpadding="2"><tr><td align="left">
		 <input type="text" name="memberSearchKW" id="memberSearchKW" value="#vSearchKeyword#" >

		 <CF_smallLink
    			title = "Search"
    			url = "##"
    			parameters = "onClick=""javascript:getSearchURL('1');return false;"""
				mouseovernotes = "Searches the Group/#application.returned_customer_setting.distributor_label_singular# and Account fields"
    		>
		 <CF_smallLink
    			title = "Clear"
    			url = "##"
    			parameters = "onClick=""javascript:getSearchURL('2');return false;"""
				mouseovernotes = "Clears the Group/#application.returned_customer_setting.distributor_label_singular# search text and search results"
    		>
		<cfif ((appSettings.get_Setting('PG_Eff_Date_Distributor') eq '1') AND (appSettings.get_Setting('PG_Effective_Date_Upload_Download') EQ '1'))>			
			<CF_smallLink
	   				title = "Download"
	    			url = "##"
					parameters = "onClick=""javascript:window.open('PG_Download_Eff_Dates.cfm?fileParam=Download&PGType=2&PG_Category_ID=#qryGetPGCustomerCategoryByID.PG_Customer_Category_ID#&Keyword=#vSearchKeyword#&OrderByField=#vOrderByField#&OrderBy=#Form.OrderBy#','Download','450','200');return false;"""
					mouseovernotes = "Download the top level members with the Effective Start Date and End Dates"
			>
			<CF_smallLink
	  				title = "Upload"
	   			url = "##"
				parameters = "onClick=""javascript:window.open('PG_Upload_Eff_Dates.cfm?fileParam=Upload&PGType=2&PG_Category_ID=#qryGetPGCustomerCategoryByID.PG_Customer_Category_ID#','Upload','width=600,height=200,location=1,status=1,scrollbars=1,resizable=1');return false;"""
				mouseovernotes = "Upload the top level members with the Effective Start Date and end Dates"
	  			>
		</cfif>
		</td></tr></table>
 <cfif qryPGCustomerCategoryDefinitionByID.RecordCount GTE 12>
	<div id="masterContainer" style="position:relative;overflow:scroll;height:330px;">
</cfif>
       <table width="99%" bgcolor="##ffffce" border="1" borderColor="800040" cellpadding="2" id="t1044" cellspacing="1"><!--- bgcolor="b0ffb0"  --->
          <tr bgcolor="##cc9999">
           <td id="header" WIDTH="4%" rowspan="1">
  			    <NOBR>
  				  <img name="IMG_Delete_Scissor_Existing" bDelete="true" sMessage="delete all #application.returned_customer_setting.distributor_label_plural# in this page" src="/images/scissor.gif" title="delete all #application.returned_customer_setting.distributor_label_plural# in this page" border="0" onclick="if(confirm('Please confirm that you would like to DELETE all checked #application.returned_customer_setting.distributor_label_plural#!')){fnDeleteAllList('#valueList(qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID)#','tr_cusExisting_','2');};" style="cursor:pointer;">
  			    </NOBR>
  		    </td>

            <td width="22%" style="font-weight:bold;font-size:8pt">
				<strong>
					<a href="index.cfm?type=customer&subtype=edit&ID=#qryGetPGCustomerCategoryByID.PG_Customer_Category_ID#&OrderByField=Group_Name&OrderBy=#newOrderBy#&EEMExpanded=true&memSearchKeyword=#memSearchKeyword#">Group/#application.returned_customer_setting.distributor_label_singular# <cfif vOrderByField EQ "Group_Name" ><cfif FORM.OrderBy EQ "ASC"><img src="#ASC_IMG#"/><cfelse><img src="#DESC_IMG#"/></cfif> </cfif>

			</a><!--- Name ---></strong>
			</td>
			<td width="20%" style="font-weight:bold;font-size:8pt">
              <strong><a href="index.cfm?type=customer&subtype=edit&ID=#qryGetPGCustomerCategoryByID.PG_Customer_Category_ID#&OrderByField=Group_Desc&OrderBy=#newOrderBy#&EEMExpanded=true&memSearchKeyword=#memSearchKeyword#">Attribute<cfif vOrderByField EQ "Group_Desc" ><cfif FORM.OrderBy EQ "ASC"><img src="#ASC_IMG#"/><cfelse><img src="#DESC_IMG#"/></cfif> </cfif>
			  <!--- Group/#application.returned_customer_setting.distributor_label_singular# Type ---></a></strong>
            </td>
            <td width="20%" style="font-weight:bold;font-size:8pt">
				<strong><a href="index.cfm?type=customer&subtype=edit&ID=#qryGetPGCustomerCategoryByID.PG_Customer_Category_ID#&OrderByField=Group_Number&OrderBy=#newOrderBy#&EEMExpanded=true&memSearchKeyword=#memSearchKeyword#">Account
			<cfif vOrderByField EQ "Group_Number" ><cfif FORM.OrderBy EQ "ASC"><img src="#ASC_IMG#"/><cfelse><img src="#DESC_IMG#"/></cfif> </cfif>
			<!--- Group/#application.returned_customer_setting.distributor_label_singular# Number --->
			</strong></td>
						<cfif isBusinessSegEnabledForDistributor>
							<td width="20%" style="font-weight:bold;font-size:8pt"><strong>#appsettings.Business_Segment_Label#</strong></td>
						</cfif>
            <td width="15%" style="font-weight:bold;font-size:8pt"><strong>Include/Exclude</strong></td>
			<cfif (appSettings.get_Setting('PG_Eff_Date_Distributor') eq '1')>
				<td width="6%" style="font-weight:bold;font-size:8pt"><strong><nobr>&nbsp;Start Date&nbsp;</nobr></strong></td>
				<td width="6%"style="font-weight:bold;font-size:8pt"><strong><nobr>&nbsp;End Date&nbsp;</strong></nobr></td>
			</cfif>
          </tr>

          <cfif qryPGCustomerCategoryDefinitionByID.RecordCount EQ 0>
            <tr><td colspan="100%">No Members Found!!</td></tr>
          </cfif>

          <cfloop query = "qryPGCustomerCategoryDefinitionByID">
          <cfif qryPGCustomerCategoryDefinitionByID.Is_PG EQ 1>
            <cfif lsPGmembersList EQ "">
              <cfset lsPGmembersList = qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID  />
            <cfelse>
              <cfset lsPGmembersList = lsPGmembersList & "," & qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID  />
            </cfif>
          </cfif>
					<cfset recStriked = 0>
					<cfloop index = "toStrikeItem" list = "#FORM.DelMarkedInExisting#"  delimiters = ",">
						<cfif toStrikeItem EQ qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID>
							<cfset 	recStriked = 1 />
						</cfif>
					</cfloop>
					<cfif recStriked EQ 1>
            <tr id="tr_cusExisting_#qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID#" style="text-decoration:line-through;background-color:bbbbbb">
            <td width="15">
              <img bDelete="false" name="IMG_Delete_Scissor_Existing"  src="/images/undo.gif"  title="click here to delete this row" border="0" onclick="fnDeleteThisPGMemberRecord('#qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID#', 'tr_cusExisting_#qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID#','2');" style="cursor:pointer;">
  			    </td>

				<td>
					<cfif ((qryPGCustomerCategoryDefinitionByID.Distributor_Group_Level_ID LT 2000) AND qryPGCustomerCategoryDefinitionByID.Group_Desc NEQ "Customer")>
				  		<!--- <a href="##" onclick="NewWindow('/Common_Files/contracts/Groups/group_items.cfm?Group_ID=#qryPGCustomerCategoryDefinitionByID.Product_Group_ID#&Group_Level_ID=#qryPGProductCategoryDefinitionByID.Distributor_Group_Level_ID#', 'Group_Items', 800, 600, 'yes', 'yes');">
	 	  				#qryPGCustomerCategoryDefinitionByID.Group_Name#</a>&nbsp; --->
						#Trim(qryPGCustomerCategoryDefinitionByID.Group_Name)#&nbsp;
					<cfelseif (qryPGCustomerCategoryDefinitionByID.Distributor_Group_Level_ID GTE 2000 AND  qryPGCustomerCategoryDefinitionByID.Group_Desc NEQ "Customer")>
						<a href="##" onclick="NewWindow('/settings/Planning_Groups/Customer_PG_Info.cfm?ID=#qryPGCustomerCategoryDefinitionByID.Product_Group_ID#&calledFrom=custAddEdit', 'Group_Items', 800, 600, 'yes', 'yes');"> #Trim(qryPGCustomerCategoryDefinitionByID.Group_Name)#</a>&nbsp;
					<cfelse>
						#Trim(qryPGCustomerCategoryDefinitionByID.Group_Name)#&nbsp;
					</cfif>
				</td>

						<td>#Trim(qryPGCustomerCategoryDefinitionByID.Group_Desc)#&nbsp;</td>
            <td><cfif qryPGCustomerCategoryDefinitionByID.Group_Number EQ "">&nbsp;<cfelse>#qryPGCustomerCategoryDefinitionByID.Group_Number#</cfif></td>
						<cfif isBusinessSegEnabledForDistributor>
							<td>#qryPGCustomerCategoryDefinitionByID.Business_Unit_Desc#&nbsp;</td>
						</cfif>
            <td>
							<nobr>
              <input type="radio" name="rdoIncExc_#Replace(qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID,'-','_','ALL')#" value="1"
              <cfif (isDefined("FORM.rdoIncExc_#Replace(qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID,'-','_','ALL')#") AND evaluate("FORM.rdoIncExc_" & Replace(qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID,'-','_','ALL')) EQ 1)>checked
              <cfelseif (qryPGCustomerCategoryDefinitionByID.Inclusion_Exclusion)>checked
              </cfif>> Include
                <input type="radio" name="rdoIncExc_#Replace(qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID,'-','_','ALL')#" value="0"
             <cfif (isDefined("FORM.rdoIncExc_#Replace(qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID,'-','_','ALL')#") AND evaluate("FORM.rdoIncExc_" & Replace(qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID,'-','_','ALL')) EQ 0)>checked
              <cfelseif NOT (qryPGCustomerCategoryDefinitionByID.Inclusion_Exclusion)>checked
              </cfif>>  Exclude
							</nobr>
            </td>
			<cfif (appSettings.get_Setting('PG_Eff_Date_Distributor') eq '1')>
				<td>&nbsp;#dateformat(qryPGCustomerCategoryDefinitionByID.PG_Effective_Start_Date, 'mm/dd/yyyy')#&nbsp;</td>
				<td>&nbsp;#dateformat(qryPGCustomerCategoryDefinitionByID.PG_Effective_End_Date, 'mm/dd/yyyy')#&nbsp;</td>
			</cfif>
          </tr>
          <cfelse>
            <tr id="tr_cusExisting_#qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID#" bgcolor="eeeeee">
            <td width="15">
              <img bDelete="true" name="IMG_Delete_Scissor_Existing"  src="/images/scissor.gif"  title="click here to delete this row" border="0" onclick="fnDeleteThisPGMemberRecord('#qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID#', 'tr_cusExisting_#qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID#','2', 1);" style="cursor:pointer;">
  			    </td>
            				<td>
					<cfif ((qryPGCustomerCategoryDefinitionByID.Distributor_Group_Level_ID LT 2000) AND qryPGCustomerCategoryDefinitionByID.Group_Desc NEQ "Customer")>
				  		<!--- <a href="##" onclick="NewWindow('/Common_Files/contracts/Groups/group_items.cfm?Group_ID=#qryPGCustomerCategoryDefinitionByID.Product_Group_ID#&Group_Level_ID=#qryPGProductCategoryDefinitionByID.Distributor_Group_Level_ID#', 'Group_Items', 800, 600, 'yes', 'yes');">
	 	  				#qryPGCustomerCategoryDefinitionByID.Group_Name#</a>&nbsp; --->
						#Trim(qryPGCustomerCategoryDefinitionByID.Group_Name)#&nbsp;
					<cfelseif (qryPGCustomerCategoryDefinitionByID.Distributor_Group_Level_ID GTE 2000 AND  qryPGCustomerCategoryDefinitionByID.Group_Desc NEQ "Customer")>
						<a href="##" onclick="NewWindow('/settings/Planning_Groups/Customer_PG_Info.cfm?ID=#qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID#&calledFrom=custAddEdit', 'Group_Items', 800, 600, 'yes', 'yes');"> #Trim(qryPGCustomerCategoryDefinitionByID.Group_Name)#</a>&nbsp;
					<cfelse>
						#Trim(qryPGCustomerCategoryDefinitionByID.Group_Name)#&nbsp;
					</cfif>
				</td>
    				<td>#Trim(qryPGCustomerCategoryDefinitionByID.Group_Desc)#&nbsp;</td>
            <td><cfif qryPGCustomerCategoryDefinitionByID.Group_Number EQ "">&nbsp;<cfelse>#qryPGCustomerCategoryDefinitionByID.Group_Number#</cfif></td>
						<cfif isBusinessSegEnabledForDistributor>
							<td>#qryPGCustomerCategoryDefinitionByID.Business_Unit_Desc#&nbsp;</td>
						</cfif>
            <td>
							<nobr>
              <input type="radio" name="rdoIncExc_#Replace(qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID,'-','_','ALL')#" value="1"
              <cfif (isDefined("FORM.rdoIncExc_#Replace(qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID,'-','_','ALL')#") AND evaluate("FORM.rdoIncExc_" & Replace(qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID,'-','_','ALL')) EQ 1)>checked
              <cfelseif (qryPGCustomerCategoryDefinitionByID.Inclusion_Exclusion)>checked
              </cfif>> Include
                <input type="radio" name="rdoIncExc_#Replace(qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID,'-','_','ALL')#" value="0"
             <cfif (isDefined("FORM.rdoIncExc_#Replace(qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID,'-','_','ALL')#") AND evaluate("FORM.rdoIncExc_" & Replace(qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID,'-','_','ALL')) EQ 0)>checked
              <cfelseif NOT (qryPGCustomerCategoryDefinitionByID.Inclusion_Exclusion)>checked
              </cfif>> Exclude
							</nobr>
            </td>
			<cfif (appSettings.get_Setting('PG_Eff_Date_Distributor') eq '1')>
				<td>
				<input type="text" name="PG_Effective_Start_Date_#Replace(qryPGCustomerCategoryDefinitionByID.PG_Customer_Category_Definition_ID,'-','_','ALL')#" size="12" maxlength="10"
				  <cfif (isDefined("qryPGCustomerCategoryDefinitionByID.PG_Effective_Start_Date")
				  AND qryPGCustomerCategoryDefinitionByID.PG_Effective_Start_Date NEQ "" AND (qryPGCustomerCategoryDefinitionByID.PG_Effective_Start_Date  NEQ "1900-01-01 00:00:00.000")
				  )>
				value="#dateformat(qryPGCustomerCategoryDefinitionByID.PG_Effective_Start_Date,'mm/dd/yyyy')#"
				 <cfelse>value="#dateformat(qryGetPGCustomerCategoryByID.PG_Effective_Start_Date,'mm/dd/yyyy')#"  
				</cfif> class="EffDate">
 				</td>
				<td>
				<input type="text" name="PG_Effective_End_Date_#Replace(qryPGCustomerCategoryDefinitionByID.PG_Customer_Category_Definition_ID,'-','_','ALL')#" size="12" maxlength="10"
				   <cfif (isDefined("qryPGCustomerCategoryDefinitionByID.PG_Effective_End_Date")
				  AND qryPGCustomerCategoryDefinitionByID.PG_Effective_End_Date NEQ "" AND (qryPGCustomerCategoryDefinitionByID.PG_Effective_End_Date  NEQ "1900-01-01 00:00:00.000")
				  )>
				value="#dateformat(qryPGCustomerCategoryDefinitionByID.PG_Effective_End_Date,'mm/dd/yyyy')#"
				 <cfelse>value="#dateformat(qryGetPGCustomerCategoryByID.PG_Effective_End_Date,'mm/dd/yyyy')#"  
				</cfif> class="EffDate">
				</td>
			</cfif>
          </tr>
          </cfif>
          </cfloop>
          </table>
      <!--- </cfif> --->
	   <cfif qryPGCustomerCategoryDefinitionByID.RecordCount GTE 12>
	</div>
	</cfif>
      <!--- Contents go here END ---->
      </div>
    </div>
</fieldset>
    </td>
  </tr>
<tr>
	<td colspan = "2">
	<fieldset id="border_22" style="border-width:0; border-color:; border-style:solid; width:650">
  	<legend>
    	<span>
      	<img id="image_22" src="/images/plus2.gif" onclick="switchlayer(22,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" border="0" title="" style="cursor:pointer">

       <font face="Arial">
        <b style="font-size:9pt">
         <span id="title_22" onclick="switchlayer(22,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" style="color:00773c;cursor:pointer">
          <span title="Click here to toggle the view">
			     Add New Members
          </span>
         </span>
        </b>
       </font>
     </legend>
    <div id="lyrgroup_22" style="display:none; visibility:inherit; z-index:5; margin-left:5; margin-right:5; margin-top:5; margin-bottom:8;">
			<div id="masterContainer">
      	<table border="0" width="95%">
     			<tr>
    				<td align="left"> <strong>Groups/#application.returned_customer_setting.distributor_label_plural#</strong></td>
				    <td><input type="radio" name="rdoIncExc" value="1"> Include <input type="radio" name="rdoIncExc" value="0"> Exclude </td>
				  </tr>
  	  			<tr>
    				<td align="left"  width="100px" nowrap valign="top"><strong>Search #application.returned_customer_setting.distributor_label_plural#:</strong></td>
        			<td>
        			<cfif isDefined("application.returned_customer_setting.group_deals") AND application.returned_customer_setting.group_deals EQ 1>
      	  			<cfset addGroupLabel = "add groups" />

                <!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
                    31191 - added logic to update options in Search Products dropdown
                            based on "include in other pg" & "master groups only"
                ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
                <cfset cust = structNew()>
                <cfset cust.blank = "<option value=''>Select Group...</option>">
                <cfset cust.all = cust.blank>
                <cfset cust.master = cust.blank>
                <cfset cust.system = cust.blank>
                <cfset cust.masterSystem = cust.blank>

                <!--- Save options for master groups into cust.master,
                      Save options for master group & system pg into cust.masterSystem
                      Save options for all into cust.all
                      These variables will be converted into js variables
                      so they can be used dynamically in jQuery--->
                <cfloop query="qGetTopLevelGroupsList">
                  <cfset cust.option = "<option value='#qGetTopLevelGroupsList.Distributor_Group_Level_ID#'>#qGetTopLevelGroupsList.Group_Level_Desc#</option>">

                  <!--- master group indicator --->
                  <cfif qGetTopLevelGroupsList.Is_PG eq 0>
                    <cfset cust.master = cust.master & cust.option>
                    <cfset cust.masterSystem = cust.masterSystem & cust.option>
                  </cfif>

                  <!--- system planning group indicator --->
                  <cfif ListFind(lstSystemPGTypes, qGetTopLevelGroupsList.Distributor_Group_Level_ID)>
                    <cfset cust.system = cust.system & cust.option>
                    <!---<cfset cust.master = cust.master & cust.option>Drachala D32628 Segment Planning Groups Unavailable REMOVED IT AGAIN FOR LABEL 37056--->
                    <!--- if this option is not master add it to the mastersystem list --->
                    <cfif qGetTopLevelGroupsList.Is_PG neq 0>
                      <cfset cust.masterSystem = cust.masterSystem & cust.option>
                    </cfif>
                  </cfif>

                  <cfset cust.all = cust.all & cust.option>
                </cfloop>


          			<div id="WithPG">
  								<select name="GroupLevel1" id="GroupLevel1">
                    <!--- 31191 - populate options dynamically by jQuery in \settings\Planning_Groups\index.cfm --->
  								</select>
          			</div>
			          &nbsp;

				<cfset extraParameter = " onClick=""javascript:showDistGroupSearchWindow('/Search_Screens/DistributorGroup_Search.cfm?IncludeIOPGFlag=1&ExcludeDistID=#FORM.PGCustomerCategoryID#&groupLevelId=', 'Allow_Dist_group&Business_Segment_Id=#bsid#',document.DataForm);return false;""" />
  		 		<CF_smallLink
  					title = "add group"
  					url = "##"
  					parameters = "#extraParameter#"
  					>
        <input type="hidden" name="GroupLevel" value="#FORM.GroupLevel#" />
      <cfelse>
        <input type="hidden" name="GroupLevel" value="" />
      </cfif>

      <cfset addDistributorLabel = "add  " />

  		<CF_smallLink
  			title = "add #application.returned_customer_setting.distributor_label_singular#"
  			url = "##"
  			parameters = "onClick=""javascript:showDistSearchWindow(#bsid#);return false;"""
  		>
 </td>
 </tr>
 </table>

  </div>
    </div>
</fieldset>
    </td>
  </tr>
  <tr>
  	<td colspan="2" align="right">
	  </td>
  </tr>
  <tr>
  	<td colspan="2">
<!--- INCLUDE LIST STARTS --->

 <fieldset id="border_2" style="border-width:0; border-color:; border-style:solid; width:650">
     <legend>
      <span>
        <img id="image_2" src="/images/plus2.gif" onclick="switchlayer(2,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" border="0" title="" style="cursor:pointer">
       	<font face="Arial">
        <b style="font-size:9pt">
         <span id="title_2" onclick="switchlayer(2,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" style="cursor:pointer;color:00773c">
          <span title="Click here to toggle the view">
			      Newly Added Include List
          </span>
         </span>
        </b>
       </font>
     </legend>
    <div id="lyrgroup_2" style="display:none; visibility:inherit; z-index:5; margin-left:5; margin-right:5; margin-top:5; margin-bottom:8;">

      <div id="masterContainer">
      <!--- Contents go here start--->

 <!---- Preparing the values for display---->
<cfif isDefined("FORM.Allow_Dist_Group") AND Len(FORM.Allow_Dist_Group) GT 0 AND FORM.GroupLevel NEQ "">
<cfset DistGroupDataManager = CreateObject("component", "components.customer.Group.DataManager").init() />
<!---
  Distributor_Group_Level Table values:
  Business Segment - 1, Family - 2, Buying Group - 3, Line of Business - 4, Market - 23, Region -	24, Zone - 25
  The below function takes (Active, Include list, exclude List)
  So, we pick only the above values for the dropdown
--->
<cfset qGetTopLevelGroups   = DistGroupDataManager.getDistributorLevels(1, "#FORM.GroupLevel#", "") />
<cfset DistGroupManager     = CreateObject("component", "components.programs.distributors.DistributorGroupManager").init() />
<cfset DistGroupDataManager = CreateObject("component", "components.customer.Group.DataManager").init() />


		<cfset DistributorGroupAttributeManager = CreateObject("component", "components.customer.group.DistributorGroupAttributeManager").init() />
		<cfset stGetGroupAttributeInfo = DistributorGroupAttributeManager.getGroupAttributeInfo(groupLevelTypeId = FORM.GroupLevel) />
		<cfset GetGroupValues = DistributorGroupAttributeManager.getDistributorGroupValues(
								DistributorGroupAttributeInfo 	= stGetGroupAttributeInfo,
								businessSegmentId				= 0,
								cachedwithin					= CreateTimeSpan(0, 0, 0, 0)) />

  <cfif (Find("-",FORM.Allow_Dist_Group) EQ 0)>
    <cfset AllowDistGroupType = "iInt" />
  <cfelse>
    <cfset AllowDistGroupType = "sString" />
  </cfif>

  <cfquery name="qryDistributorGroupList" dbType = "query">
     <cfif AllowDistGroupType EQ "sString">
      SELECT * FROM GetGroupValues WHERE Group_ID in ('#Replace(FORM.Allow_Dist_Group,",","','","ALL")#')
    <cfelse>
      SELECT * FROM GetGroupValues WHERE Group_ID in (#FORM.Allow_Dist_Group#)
    </cfif>
   </cfquery>
   <cfset  FORM.Allow_Dist_Group = "" />
</cfif>

     <!--- START BLOCK TO ADD INDIVIDUAL DISTRIBUTOR GROUP --->
     <cfif (isDefined("qryDistributorGroupList") AND	qryDistributorGroupList.RecordCount GTE 1 AND isDefined("FORM.rdoIncExc"))>
      <cfset sesCount = SESSION.qryGrpDistPack.RecordCount  />
      <cfset rCount = SESSION.qryGrpDistPack.RecordCount + 1  />
      <cfset iCounter = 1 />
      <cfloop query="qryDistributorGroupList">
        <cfset recExists = 0 />
        <cfloop query="SESSION.qryGrpDistPack">
          <cfif SESSION.qryGrpDistPack.Group_Dist_ID EQ qryDistributorGroupList.Group_ID AND SESSION.qryGrpDistPack.Inc_Exc EQ FORM.rdoIncExc>
            <cfset recExists = 1 />
            <cfbreak />
          </cfif>
        </cfloop>
        <cfif recExists EQ 0>
          <cfloop query = "qryPGCustomerCategoryDefinitionByID">
            <cfif qryPGCustomerCategoryDefinitionByID.Distributor_Group_ID EQ qryDistributorGroupList.Group_ID AND qryPGCustomerCategoryDefinitionByID.Inclusion_Exclusion EQ FORM.rdoIncExc>
              <cfset recExists = 1 />
              <script>
                alert('Group Name: #qryPGCustomerCategoryDefinitionByID.Group_Name# already exists in the Members list!');
              </script>
              <cfbreak />
            </cfif>
          </cfloop>
        </cfif>

        <cfif recExists EQ 0>
          <cfset newRow =  QueryAddRow(SESSION.qryGrpDistPack,1) />
          <cfset temp = QuerySetCell(SESSION.qryGrpDistPack, "GroupLevel_ID", FORM.GroupLevel, SESSION.qryGrpDistPack.recordCount) />
          <cfset temp = QuerySetCell(SESSION.qryGrpDistPack, "GroupLevel_Name", qGetTopLevelGroups.Group_Level_Desc, SESSION.qryGrpDistPack.recordCount) />
		  <cfset temp = QuerySetCell(SESSION.qryGrpDistPack, "Group_Number", qryDistributorGroupList.Group_Number, SESSION.qryGrpDistPack.recordCount) />
          <cfset temp = QuerySetCell(SESSION.qryGrpDistPack, "Group_Dist_ID", qryDistributorGroupList.Group_ID, SESSION.qryGrpDistPack.recordCount) />
          <cfset temp = QuerySetCell(SESSION.qryGrpDistPack, "Description", qryDistributorGroupList.Group_Name, SESSION.qryGrpDistPack.recordCount) />
          <cfset temp = QuerySetCell(SESSION.qryGrpDistPack, "Inc_Exc", FORM.rdoIncExc, SESSION.qryGrpDistPack.recordCount) />
          <cfset temp = QuerySetCell(SESSION.qryGrpDistPack, "IsPG", qGetTopLevelGroups.Is_PG, SESSION.qryGrpDistPack.recordCount) />
					<cfset temp = QuerySetCell(SESSION.qryGrpDistPack, "Business_Unit_Desc", "", SESSION.qryGrpDistPack.recordCount) />
          <cfset iCounter  = iCounter + 1 />
        </cfif>
      </cfloop>
     </cfif>
     <!--- END BLOCK TO ADD INDIVIDUAL DISTRIBUTOR GROUP --->

     <!--- START BLOCK TO ADD INDIVIDUAL DISTRIBUTORS --->
<cfif isDefined("FORM.Distributor_List") AND Len(FORM.Distributor_List) GT 0 >
 	  <cfquery name="qDistributorList" datasource="#application.datasource#">
		SELECT 	BSA_Foodservice_Customers.*,
				Distributor_Group_Distributor.Distributor_Group_Level_ID
				<cfif isBusinessSegEnabledForDistributor>
					,Bus_Seg.Business_Unit_Desc
				</cfif>
		FROM 	BSA_Foodservice_Customers
				LEFT OUTER JOIN Distributor_Group_Distributor ON
				BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Distributor_Group_Distributor.Distributor_ID
				AND Distributor_Group_Distributor.Deleted = 0
			<cfif isBusinessSegEnabledForDistributor>
				LEFT JOIN Business_Segment Bus_Seg
				ON Bus_Seg.Business_Segment_ID = BSA_Foodservice_Customers.Business_Segment_ID
			</cfif>
		WHERE
				BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID <CFIF Len(FORM.Distributor_List) EQ 0>IS NULL<CFELSEIF listlen(FORM.Distributor_List) GT 0>IN(#listqualify(FORM.Distributor_List, "'", ",")#)<CFELSE>!= BSA_Foodservice_Customers_ID</CFIF>
  </cfquery>
</cfif>
<!--- <cfdump var="#qDistributorList#" /> --->
 <cfset FORM.Distributor_List  = "" />
      <cfif isDefined("qDistributorList") AND qDistributorList.RecordCount GT 0 AND isDefined("FORM.rdoIncExc")>
        <cfset sesCount = SESSION.qryGrpDistPack.RecordCount  />
        <cfset rCount = SESSION.qryGrpDistPack.RecordCount + 1  />
        <cfset iCounter = 1 />
        <cfloop query="qDistributorList">
        <cfset recExists = 0 />
				<cfset BusinessSegment = ""/>
				<cfif (isDefined("qDistributorList.Business_Unit_Desc") AND qDistributorList.Business_Unit_Desc NEQ "")>
					<cfset BusinessSegment = qDistributorList.Business_Unit_Desc />
				</cfif>
          <cfloop query="SESSION.qryGrpDistPack">
            <cfif isDefined("SESSION.qryGrpDistPack.Group_Dist_ID") AND SESSION.qryGrpDistPack.Group_Dist_ID EQ qDistributorList.BSA_FoodService_Customers_ID AND SESSION.qryGrpDistPack.Inc_Exc EQ FORM.rdoIncExc>
              <cfset recExists = 1 />
              <cfbreak />
            </cfif>
            </cfloop>
            <cfif recExists EQ 0>
              <cfset newRow =  QueryAddRow(SESSION.qryGrpDistPack,1) />

			  <!--- D47749: Customer Planning Group - Need Payee Nbr displayed/ Anand Rao / 22-Jan-2015 --->

			  <cfset DistName = "" />
			  <cfif (isDefined("qDistributorList.Ship_To") and qDistributorList.Ship_To NEQ "") OR (isDefined("qDistributorList.Shr_Ship_To") and qDistributorList.Shr_Ship_To NEQ "")>
					<cfif appSettings.get_Setting('Display_Distributor_ID') eq '1'>
						<cfset shipto = qDistributorList.Shr_Ship_To>
					<cfelse>
						<cfset shipto = qDistributorList.Ship_To>
					</cfif>
			  	<cfset DistName = qDistributorList.Name  & " (" & shipto & ")" />
			  <cfelse>
			  	<cfset DistName = qDistributorList.Name   />
			  </cfif>

              <cfset temp = QuerySetCell(SESSION.qryGrpDistPack, "GroupLevel_ID", 0, SESSION.qryGrpDistPack.recordCount) />
              <cfset temp = QuerySetCell(SESSION.qryGrpDistPack, "Group_Dist_ID", qDistributorList.BSA_FoodService_Customers_ID, SESSION.qryGrpDistPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpDistPack, "Description", DistName , SESSION.qryGrpDistPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpDistPack, "Inc_Exc", FORM.rdoIncExc, SESSION.qryGrpDistPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpDistPack, "IsPG", 0, SESSION.qryGrpDistPack.recordCount) />
							<cfset temp = QuerySetCell(SESSION.qryGrpDistPack, "Business_Unit_Desc", BusinessSegment, SESSION.qryGrpDistPack.recordCount) />
              <cfset iCounter  = iCounter + 1 />
            </cfif>
        </cfloop>
        <cfset FORM.Distributor_List  = "" />
      </cfif>
         <!--- END BLOCK TO ADD INDIVIDUAL DISTRIBUTORS --->
			<table cellpadding="2" cellspacing="1" width="100%" border="1" bordercolor="979797">
      	<tr>
          <td id="header" WIDTH="5%" rowspan="1">
  			    <NOBR>
  				  <img name="IMG_Delete_Scissor_Include" bDelete="true" sMessage="delete all #application.returned_customer_setting.distributor_label_plural# in this page" src="/images/scissor.gif" title="delete all #application.returned_customer_setting.distributor_label_plural# in this page" border="0" onclick="if(confirm('Please confirm that you would like to DELETE all checked #application.returned_customer_setting.distributor_label_plural#!')){fnDeleteAllList('#valueList(SESSION.qryGrpDistPack.Group_Dist_ID)#','tr_cusAddInc_','1');};" style="cursor:pointer;">
  			    </NOBR>
  		    </td>
      		<td width="15%">
      		  <b>Group/#application.returned_customer_setting.distributor_label_singular# </b>
      		</td>
          <td width="25%">
            <strong>Attribute<!--- Group Level Name ---></strong>
          </td>
          <td width="35%">
            <strong>Name</strong>
          </td>
					<cfif isBusinessSegEnabledForDistributor>
			   		<td width="20%" rowspan="1">
			   			<b>#appsettings.Business_Segment_Label#</b>&nbsp;
			   		</td>
					</cfif>
          </tr>
    <!--- START LISTING THE GROUPS --->
  <cfif (isDefined("SESSION.qryGrpDistPack") AND SESSION.qryGrpDistPack.RecordCount GTE 1)>
        <cfloop query="SESSION.qryGrpDistPack">
        <!--- INDIVIDUAL DISTRIBUITOR LISTING--->
       <cfif SESSION.qryGrpDistPack.Description NEQ "" AND  SESSION.qryGrpDistPack.GroupLevel_ID EQ "0" AND SESSION.qryGrpDistPack.Inc_Exc EQ 1>
					<cfset recStriked = 0>
					<cfloop index = "delItem" list = "#FORM.DelMarkedInInclude#"  delimiters = ",">
						<cfif delItem EQ SESSION.qryGrpDistPack.Group_Dist_ID>
							<cfset 	recStriked = 1 />
						</cfif>
					</cfloop>
					<cfif recStriked EQ 1>
          <tr id="tr_cusAddInc_#SESSION.qryGrpDistPack.Group_Dist_ID#" style="text-decoration:line-through;background-color:bbbbbb">
            <td width="15">
  				    <img bDelete="false" name="IMG_Delete_Scissor_Include"  src="/images/undo.gif"  title="click here to undelete this #application.returned_customer_setting.distributor_label_singular#" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpDistPack.Group_Dist_ID#', 'tr_cusAddInc_#SESSION.qryGrpDistPack.Group_Dist_ID#','1');" style="cursor:pointer;">
  			    </td>
            <td>Distributor</td>
            <td>N/A</td>
  				  <td>#SESSION.qryGrpDistPack.Description#</td>
						<cfif isBusinessSegEnabledForDistributor>
				   		<td>#SESSION.qryGrpDistPack.Business_Unit_Desc#&nbsp;</td>
						</cfif>
          </tr>
        <cfelse>
          <tr id="tr_cusAddInc_#SESSION.qryGrpDistPack.Group_Dist_ID#" bgcolor="eeeeee">
            <td width="15">
  				    <img bDelete="true" name="IMG_Delete_Scissor_Include"  src="/images/scissor.gif"  title="click here to delete this #application.returned_customer_setting.distributor_label_singular#" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpDistPack.Group_Dist_ID#', 'tr_cusAddInc_#SESSION.qryGrpDistPack.Group_Dist_ID#','1');" style="cursor:pointer;">
  			    </td>
            <td>Distributor</td>
            <td>N/A</td>
  				  <td>#SESSION.qryGrpDistPack.Description#</td>
						<cfif isBusinessSegEnabledForDistributor>
				   		<td>#SESSION.qryGrpDistPack.Business_Unit_Desc#&nbsp;</td>
						</cfif>
          </tr>
        </cfif>
          </cfif>
        </cfloop>
      </cfif>

<cfif (isDefined("SESSION.qryGrpDistPack") AND SESSION.qryGrpDistPack.RecordCount GTE 1)>
        <cfloop query="SESSION.qryGrpDistPack">
        <!--- GROUP DISTRIBUITOR LISTING--->
       <cfif SESSION.qryGrpDistPack.Description NEQ "" AND  SESSION.qryGrpDistPack.GroupLevel_ID NEQ "0" AND SESSION.qryGrpDistPack.Inc_Exc EQ 1>
					<cfset recStriked = 0>
					<cfloop index = "delItem" list = "#FORM.DelMarkedInInclude#"  delimiters = ",">
						<cfif delItem EQ SESSION.qryGrpDistPack.Group_Dist_ID>
							<cfset 	recStriked = 1 />
						</cfif>
					</cfloop>
					<cfif recStriked EQ 1>
          <tr id="tr_cusAddInc_#SESSION.qryGrpDistPack.Group_Dist_ID#" style="text-decoration:line-through;background-color:bbbbbb">
            <td width="15">
              <img bDelete="false" name="IMG_Delete_Scissor_Include"  src="/images/undo.gif"  title="click here to undelete this #application.returned_customer_setting.distributor_label_singular#" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpDistPack.Group_Dist_ID#', 'tr_cusAddInc_#SESSION.qryGrpDistPack.Group_Dist_ID#','1');" style="cursor:pointer;">
  			    </td>
            <td><cfif (SESSION.qryGrpDistPack.Group_Number NEQ "")>#SESSION.qryGrpDistPack.Group_Number#<cfelse>Distributor Group</cfif></td>
            <td>#SESSION.qryGrpDistPack.GroupLevel_Name#</td>
  				  <td>#SESSION.qryGrpDistPack.Description#</td>
						<cfif isBusinessSegEnabledForDistributor>
				   		<td>#SESSION.qryGrpDistPack.Business_Unit_Desc#&nbsp;</td>
						</cfif>
          </tr>
         <cfelse>
          <tr id="tr_cusAddInc_#SESSION.qryGrpDistPack.Group_Dist_ID#" bgcolor="eeeeee">
            <td width="15">
              <img bDelete="true" name="IMG_Delete_Scissor_Include"  src="/images/scissor.gif"  title="click here to delete this #application.returned_customer_setting.distributor_label_singular#" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpDistPack.Group_Dist_ID#', 'tr_cusAddInc_#SESSION.qryGrpDistPack.Group_Dist_ID#','1');" style="cursor:pointer;">
  			    </td>
            <td><cfif (SESSION.qryGrpDistPack.Group_Number NEQ "")>#SESSION.qryGrpDistPack.Group_Number#<cfelse>Distributor Group</cfif></td>
            <td>#SESSION.qryGrpDistPack.GroupLevel_Name#</td>
  				  <td>#SESSION.qryGrpDistPack.Description#</td>
						<cfif isBusinessSegEnabledForDistributor>
				   		<td>#SESSION.qryGrpDistPack.Business_Unit_Desc#&nbsp;</td>
						</cfif>
          </tr>
         </cfif>
          </cfif>
        </cfloop>
<cfelse>
  <tr>
    <td colspan="100%"  align="center"><strong>No new Members were added!</strong></td>
  </tr>
 </cfif>

    <!--- END LISTING THE INDIVIDUAL DISTRIBUTORS --->
      </table>
      <!--- Contents go here END --->
      </div>
    </div>
</fieldset>

<!--- INCLUDE LIST ENDS --->

<!--- EXCLUDE LIST STARTS --->
 <fieldset id="border_3" style="border-width:0; border-color:; border-style:solid; width:650">
     <legend>
      <span>
        <img id="image_3" src="/images/plus2.gif" onclick="switchlayer(3,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" border="0" title="" style="cursor:pointer">

       <font face="Arial">
        <b style="font-size:9pt">
         <span id="title_3" onclick="switchlayer(3,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" style="color:00773c;cursor:pointer;">
          <span title="Click here to toggle the view">
			      Newly Added Exclude List
          </span>
         </span>
        </b>
       </font>
     </legend>
    <div id="lyrgroup_3" style="display:none; visibility:inherit; z-index:5; margin-left:5; margin-right:5; margin-top:5; margin-bottom:8;">

      <div id="masterContainer">
      <table cellpadding="2" cellspacing="1" width="100%" border="1" bordercolor="##979797">
          <tr>
          <td id="header" WIDTH="5%" rowspan="1">
  			    <NOBR>
  				  <img name="IMG_Delete_Scissor_Exclude" bDelete="true" sMessage="delete all #application.returned_customer_setting.distributor_label_plural# in this page" src="/images/scissor.gif" title="delete all #application.returned_customer_setting.distributor_label_plural# in this page" border="0" onclick="if(confirm('Please confirm that you would like to DELETE all checked #application.returned_customer_setting.distributor_label_plural#!')){fnDeleteAllList('#valueList(SESSION.qryGrpDistPack.Group_Dist_ID)#','tr_cusAddExc_','0');};" style="cursor:pointer;">
  			    </NOBR>
  		    </td>
          <td width="15%">
      		  <b>Group/#application.returned_customer_setting.distributor_label_singular#</b>
      		</td>
          <td width="25%">
            <strong>Attribute<!--- Group Level Name ---></strong>
          </td>
          <td width="35%">
            <strong>Name</strong>
          </td>
					<cfif isBusinessSegEnabledForDistributor>
			   		<td width="20%" rowspan="1">
			   			<b>#appsettings.Business_Segment_Label#</b>&nbsp;
			   		</td>
					</cfif>
         </tr>

    <cfif (isDefined("SESSION.qryGrpDistPack") AND SESSION.qryGrpDistPack.RecordCount GTE 1)>
        <cfloop query="SESSION.qryGrpDistPack">
       <cfif SESSION.qryGrpDistPack.Description NEQ "" AND  SESSION.qryGrpDistPack.GroupLevel_ID EQ "0" AND SESSION.qryGrpDistPack.Inc_Exc EQ 0>
					<cfset recStriked = 0>
					<cfloop index = "delItem" list = "#FORM.DelMarkedInExclude#"  delimiters = ",">
						<cfif delItem EQ SESSION.qryGrpDistPack.Group_Dist_ID>
							<cfset 	recStriked = 1 />
						</cfif>
					</cfloop>
					<cfif recStriked EQ 1>
          <tr id="tr_cusAddExc_#SESSION.qryGrpDistPack.Group_Dist_ID#" style="text-decoration:line-through;background-color:bbbbbb">
            <td width="15">
  				    <img bDelete="false" name="IMG_Delete_Scissor_Exclude"  src="/images/undo.gif"  title="click here to undelete this #application.returned_customer_setting.distributor_label_singular#" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpDistPack.Group_Dist_ID#', 'tr_cusAddExc_#SESSION.qryGrpDistPack.Group_Dist_ID#','0');" style="cursor:pointer;">
  			    </td>
            <td>Distributor</td>
            <td>N/A</td>
  				  <td>#SESSION.qryGrpDistPack.Description#</td>
						<cfif isBusinessSegEnabledForDistributor>
				   		<td>#SESSION.qryGrpDistPack.Business_Unit_Desc#&nbsp;</td>
						</cfif>
          </tr>
          <cfelse>
           <tr id="tr_cusAddExc_#SESSION.qryGrpDistPack.Group_Dist_ID#" bgcolor="eeeeee">
            <td width="15">
  				    <img bDelete="true" name="IMG_Delete_Scissor_Exclude"  src="/images/scissor.gif"  title="click here to delete this #application.returned_customer_setting.distributor_label_singular#" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpDistPack.Group_Dist_ID#', 'tr_cusAddExc_#SESSION.qryGrpDistPack.Group_Dist_ID#','0');" style="cursor:pointer;">
  			    </td>
            <td>Distributor</td>
            <td>N/A</td>
  				  <td>#SESSION.qryGrpDistPack.Description#</td>
						<cfif isBusinessSegEnabledForDistributor>
				   		<td>#SESSION.qryGrpDistPack.Business_Unit_Desc#&nbsp;</td>
						</cfif>
          </tr>
          </cfif>
          </cfif>
        </cfloop>
      </cfif>

			<cfif (isDefined("SESSION.qryGrpDistPack") AND SESSION.qryGrpDistPack.RecordCount GTE 1)>
        <cfloop query="SESSION.qryGrpDistPack">
       <cfif SESSION.qryGrpDistPack.Description NEQ "" AND  SESSION.qryGrpDistPack.GroupLevel_ID NEQ "0" AND SESSION.qryGrpDistPack.Inc_Exc EQ 0>
					<cfset recStriked = 0>
					<cfloop index = "delItem" list = "#FORM.DelMarkedInExclude#"  delimiters = ",">
						<cfif delItem EQ SESSION.qryGrpDistPack.Group_Dist_ID>
							<cfset 	recStriked = 1 />
						</cfif>
					</cfloop>
					<cfif recStriked EQ 1>
          <tr id="tr_cusAddExc_#SESSION.qryGrpDistPack.Group_Dist_ID#" style="text-decoration:line-through;background-color:bbbbbb">
            <td width="15">
  				    <img bDelete="false" name="IMG_Delete_Scissor_Exclude"  src="/images/undo.gif"  title="click here to undelete this #application.returned_customer_setting.distributor_label_singular#" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpDistPack.Group_Dist_ID#', 'tr_cusAddExc_#SESSION.qryGrpDistPack.Group_Dist_ID#','0');" style="cursor:pointer;">
  			    </td>
           <td><cfif (SESSION.qryGrpDistPack.Group_Number NEQ "")>#SESSION.qryGrpDistPack.Group_Number#<cfelse>Distributor Group</cfif></td>
            <td>#SESSION.qryGrpDistPack.GroupLevel_Name#</td>
  				  <td>#SESSION.qryGrpDistPack.Description#</td>
						<cfif isBusinessSegEnabledForDistributor>
				   		<td>#SESSION.qryGrpDistPack.Business_Unit_Desc#&nbsp;</td>
						</cfif>
          </tr>
         <cfelse>
          <tr id="tr_cusAddExc_#SESSION.qryGrpDistPack.Group_Dist_ID#" bgcolor="eeeeee">
            <td width="15">
  				    <img bDelete="true" name="IMG_Delete_Scissor_Exclude"  src="/images/scissor.gif"  title="click here to delete this #application.returned_customer_setting.distributor_label_singular#" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpDistPack.Group_Dist_ID#', 'tr_cusAddExc_#SESSION.qryGrpDistPack.Group_Dist_ID#','0');" style="cursor:pointer;">
  			    </td>
           <td><cfif (SESSION.qryGrpDistPack.Group_Number NEQ "")>#SESSION.qryGrpDistPack.Group_Number#<cfelse>Distributor Group</cfif></td>
            <td>#SESSION.qryGrpDistPack.GroupLevel_Name#</td>
  				  <td>#SESSION.qryGrpDistPack.Description#</td>
						<cfif isBusinessSegEnabledForDistributor>
				   		<td>#SESSION.qryGrpDistPack.Business_Unit_Desc#&nbsp;</td>
						</cfif>
          </tr>
         </cfif>
          </cfif>
        </cfloop>
<cfelse>
  <tr>
    <td colspan="100%" align="center"><strong>No new Members were added!</strong></td>
  </tr>
      </cfif>
    </table>
      <!--- Contents go here --->
      </div>
    </div>
</fieldset>
<!--- EXCLUDE LIST ENDS --->
       </td>
    </tr>
	<tr align="center">
		<td align="center" colspan="2">
			<table>
				<tr>
					<td>
					<CF_button
					button_name		=	"View Micro Members"
					button_caption	=	"View Micro Members"
					button_action	=	"fnViewMicroMembers('2','#qryGetPGCustomerCategoryByID.PG_Customer_Category_ID#','#lsPGmembersList#');"
					button_type		=	"javascript_link"
					button_width	=	"175"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
					>
					</td>
					<td>
					<cfif Get_Profile_Settings.Planning_Groups_Create EQ 2>
						<div id="displaylink" >
						  <CF_button
							button_name		=	"Save"
							button_caption	=	"Save"
							button_action	=	"hideSaveLink('hide');saveEditCPG('2','#appsettings.getPayeeFromPlanningGroups()#', 'save_table');"
							button_type		=	"javascript_link"
							button_width	=	"175"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
							>
						</div>
					</cfif>
					<div id="hidelink" STYLE="DISPLAY:NONE">
						<strong><font color="red"><strong>[</strong></font><font color="c9c9c9"> Save </font><font color="red"><strong>]</strong></font></strong>
					</div>

					<!---
					  <CF_smallLink
					title = "View Micro Members"
					url = "##"
					parameters = "onClick=""javascript:fnViewMicroMembers('2','#qryGetPGCustomerCategoryByID.PG_Customer_Category_ID#','#lsPGmembersList#');return false;"""
					>
					<CF_smallLink
						title = "Save"
						url = "##"
						parameters = "onClick=""javascript:saveEditCPG('2','#appsettings.getPayeeFromPlanningGroups()#');this.enabled=false;return false;"""
					>
					--->
					</td>
				</tr>
			</table>
		</td>
	</tr>
  </table>
</div>
</div>
</fieldset>

<!--- Planning Group whole box--->
</td>
</tr>

</table>

 <br>

  <input type="hidden" name="DelMarkedInInclude" id="DelMarkedInInclude" value="#FORM.DelMarkedInInclude#" />
  <input type="hidden" name="DelMarkedInExclude" id="DelMarkedInExclude" value="#FORM.DelMarkedInExclude#" />
  <input type="hidden" name="DelMarkedInExisting" id="DelMarkedInExisting" value="#FORM.DelMarkedInExisting#" />
  <input type="hidden" name="pageAction2" value="CustomerEditSave" />
  <input type="hidden" name="Allow_Dist_group" id="Allow_Dist_group" <cfif isDefined("FORM.Allow_Dist_group")>value="#FORM.Allow_Dist_group#"<cfelse>value=""</cfif>>
	<input type="hidden" name="bSubmit" value="0" />
  <cfif FORM.display EQ "add">
      <input type="hidden" name="DistributorRefresh" value = "0" />
  </cfif>
	<script>
	///////////////////////////////////   Update Component //////////////////////////////////////////


  function deleteThisDistributor(FieldNameRe, prodID, bgCol, GroupID)//,realGroupLevelId
	{
			var srcObj = event.srcElement;
			var trObj = getParentObject(srcObj, "tr");
			var trIndex = trObj.rowIndex;
			var FINALDISTLIST = document.DataForm.Distributor_List.value;
      var FINALGROUPLIST = document.DataForm.Allow_Dist_group.value;
			var resultString = ListDeleteItem(FINALDISTLIST, ",", prodID);
      var grpResultString = ListDeleteItem(FINALGROUPLIST, ",", GroupID);
			var bDelete = true;
			var objGroupLevel;
 			var itemCount = FINALDISTLIST.split(",");
      var groupCount = FINALGROUPLIST.split(",");

      if (prodID != "")
      {
        if (resultString == FINALDISTLIST)
        {
          resultString = ListAppendItem(FINALDISTLIST, ",", prodID);
          bDelete = false;
        }
      }
      if (GroupID != "")
      {
        if (grpResultString == FINALGROUPLIST)
        {
          grpResultString = ListAppendItem(FINALGROUPLIST, ",", GroupID);
          bDelete = false;
        }
      }
		 	document.DataForm.Distributor_List.value = resultString;
		  document.DataForm.Allow_Dist_group.value = grpResultString;
			var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";
			if(trObj)
			{
			  if(bDelete)
				{
					trObj.height = trObj.offsetHeight;
					//trObj.cells[trObj.cells.length-1].innerHTML = empty_String;
					propogateProperty(trObj, "style.backgroundColor", "##DDDDDD", false);
					propogateProperty(trObj, "style.textDecoration", "line-through", true);
					srcObj.title = "Deleted";
					srcObj.src = undodeleteImg.src;
				}
 				else
				{
					propogateProperty(trObj, "style.backgroundColor", "##eeeeee", false);
					propogateProperty(trObj, "style.textDecoration", "none", false);
					// unDeleteProduct(prodCompId);//prodCompId=contract_product_id
					srcObj.title = "delete this Distributor";
					srcObj.src = deleteImg.src;
					propogateProperty(trObj, "style.backgroundColor", "FFFFFF", false, true);
			 	}
				srcObj.bDelete = !bDelete;
				trObj.bDelete = (bDelete?1:0);
				}
		}


	function deletePayeeDistributor()
	{
		document.all.distributor_id.value = '';
		document.all.distributor_name.value = '';
	}

	function deletePayeeVendor()
	{
		document.all.vendor_id.value = '';
		document.all.vendor_master_id.value = '';
		document.all.vendorName.value = '';
	}

  	function getParentObject(thisObj, tagName)
	  {
		  if(thisObj.tagName.toLowerCase() == tagName.toLowerCase())
		  {
			  return thisObj;
		  }
		  else if(thisObj.tagName.toLowerCase() == "body")
		  {
			  return null;
		  }
		  else
		  {
			  return getParentObject(thisObj.parentElement, tagName);
		  }
	  }

	function getSearchURL(searchMode)
	{

		if (searchMode == "1")
		{
			var txtSearch = document.getElementById('memberSearchKW').value;
		}
		else
		{
			document.getElementById('memberSearchKW').value = "";
			var txtSearch = document.getElementById('memberSearchKW').value;
		}

		location.href="index.cfm?type=customer&subtype=edit&ID=#qryGetPGCustomerCategoryByID.PG_Customer_Category_ID#&OrderByField=#vOrderByField#&OrderBy=#newOrderBy#&EEMExpanded=true&memSearchKeyword=" + txtSearch;
	}
	searchVendor =  function()
	{
		NewWindow('/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?RebateRecipient_On=0&Formname=DataForm&ReloadForm=1&FieldName=vendor_id&PageSource=CustomerPlanningGroups&lsBusinessSegmentID=#FORM.BusinessSegmentID#', 'VendorSearch', '800', '600', 'yes', 'yes')
	}

	searchDistributor =  function()
	{
		NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?RebateRecipient_On=1&Formname=DataForm&ReloadForm=1&FieldName=distributor_id&SelectSingleSearchResultOnly=1&PageSource=CustomerPlanningGroups'", "searchwindow", "800", "600", "yes", "yes")
	}
  </script>
</cfoutput>
