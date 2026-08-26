<!-----------------------------------------------------------------------------

FILE NAME:		_pg_customer_add.cfm
DESCRIPTION:
CREATED BY:		10-Aug-2010
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

      			Anand Rao	  10-Aug-2010	Created the file
------------------------------------------------------------------------------>
<cfset DistGroupDataManager = CreateObject("component", "components.customer.Group.DataManager").init() />

<!---
  Distributor_Group_Level Table values:
  Business Segment - 1, Family - 2, Buying Group - 3, Line of Business - 4, Market - 23, Region -	24, Zone - 25
  The below function takes (Active, Include list, exclude List)
  So, we pick only the above values for the dropdown
--->
<cfparam name="Form.Distributor_id" default="">
<cfparam name="Form.Vendor_ID" default="">
<cfparam name="Form.VendorMasterID" default="">
<cfparam name="Form.BusinessSegmentID" default="0">
<cfparam name="Selected_Distributor" default="">
<cfparam name="Selected_Vendor" default="">
<cfparam name="Selected_Vendor_Master_ID" default="">

<!--- If the "distributor" payee exists.
It will exist when the user selects a distributor from the popup page. --->
<CFIF Form.Distributor_id NEQ "">
	<cfset useLakebaseForDist_Search_Result = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForDist_Search_Result>
	<cftry>
		<cfset Dist_Search_Result = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"bsa_foodservice_customers_id" = "eq.#Form.Distributor_id#",
				"deleted" = "eq.0",
				"active_code" = "eq.A",
				"order" = "name.asc",
				"select" = "bsa_foodservice_customers_id,name,ship_to,business_segment_id"
			}), "bsa_foodservice_customers_id,name,ship_to,business_segment_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDist_Search_Result = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDist_Search_Result>
<CFQUERY NAME="Dist_Search_Result" DATASOURCE = "#Application.Datasource#">
		SELECT	BSA_Foodservice_Customers_ID, Name, Ship_To, Business_Segment_ID
		FROM 	BSA_Foodservice_Customers
		WHERE	BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = '#Form.Distributor_id#'
		AND		BSA_Foodservice_Customers.Deleted = 0
		AND		BSA_Foodservice_Customers.Active_Code = 'A'
		ORDER BY Name
	</CFQUERY>
</cfif>
	<cfset FORM.BusinessSegmentID = Dist_Search_Result.Business_Segment_ID />
	<!--- Get the distributor's name --->
	<!--- D47749: Customer Planning Group - Need Payee Nbr displayed/ Anand Rao / 22-Jan-2015 --->
	<cfif Dist_Search_Result.Ship_To EQ "">
		<CFSET Selected_Distributor = Dist_Search_Result.Name>
	<cfelse>
		<CFSET Selected_Distributor = Dist_Search_Result.Name & " (" & Dist_Search_Result.Ship_To & ")" >
	</cfif>

</cfif>

<!--- If the "vendor" payee exists.
It will exist when the user selects a vendor from the popup page. --->
<CFIF Form.Vendor_ID NEQ "">
	<cfset useLakebaseForGetVendorID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vendor_master")>
<cfif useLakebaseForGetVendorID>
	<cftry>
		<cfset GetVendorID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("vendor_master", {
				"vendor_id" = "eq.#Vendor_ID#",
				"select" = "vendor_master_id,vendor_id,vendor_name"
			}), "vendor_master_id,vendor_id,vendor_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetVendorID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetVendorID>
<CFQUERY NAME="GetVendorID" DATASOURCE = "#Application.Datasource#">
		SELECT Vendor_Master_ID, Vendor_ID, Vendor_Name
		FROM Vendor_Master
		WHERE Vendor_ID = '#Vendor_ID#'
	</CFQUERY>
</cfif>
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
<cfquery name="qryDistList" datasource="#application.datasource#">
  SELECT DISTINCT(Distributor_Group_Level_ID) FROM Distributor_Group_Level WHERE Active= 1 AND Deleted = 0
</cfquery>

<!--- <cfset qGetTopLevelGroupsList = DistGroupDataManager.getDistributorLevels(1, "1,2,3,23,24,25", "") /> --->

<cfset qGetTopLevelGroupsList = DistGroupDataManager.getDistributorLevels(1, "#ValueList(qryDistList.Distributor_Group_Level_ID)#", "") />
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

</style>
<!--- <cfset qryTemplateList = CreateObject("component","components.programs.template.TemplateManager").getAllTemplates() /> --->
<cfset qryTemplateList = CreateObject("component","components.programs.template.TemplateManager").getAllTemplatesForPGWithFilters('#New_Sort_Order#') />
<cfoutput>

<!---   <cfif isDefined("SESSION.qryGrpDistPack") >
  <cfset tempvariable = StructDelete(session,"qryGrpDistPack")>
</cfif>   --->

<cfif NOT isDefined("SESSION.qryGrpDistPack")>
  <cfset SESSION.qryGrpDistPack = QueryNew("GroupLevel_ID, GroupLevel_Name, Group_Number, Group_Dist_ID, Description, Inc_Exc, IsPG, Business_Unit_Desc")>
  <!--- <cfset SESSION.qryGrpDistPack = qryGrpDistPack /> --->
</cfif>

<!--- <input type="hidden" name="pageSource" value="PGCustomerAdd"> --->
<!--- #Distributor_List# --->
<input type="hidden" name="Distributor_List" value="">
<input type="hidden" name="DistributorListToExcludeFromSelecting" value="">
<input type="hidden" name="PG_Effective_Date_ON" value="#appSettings.get_Setting('PG_Eff_Date_Distributor')#">

<cfif isDefined("FORM.GroupLevel_Name") AND FORM.GroupLevel_Name NEQ "">
  <input type="hidden" name="GroupLevel_Name" value="#FORM.GroupLevel_Name#" />
<cfelse>
  <input type="hidden" name="GroupLevel_Name" value="" />
</cfif>

<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">#application.returned_customer_setting.Distributor_Label_Singular# Planning Group Information</LEGEND>
    <br>
 <table width="100%" border="0" cellpadding="4" cellspacing="4" cols="groups" rules="groups" bordercolor="a85400">
 <tr>
  <td colspan="2" height="6px;"> <font color="red" size="5">*</font> - Required Field</td>
 </tr>
  <tr>
    <td align="right"  width="30%" <!--- class="Orangline" --->>
      <strong>Planning Group Code: </strong>
    </td>
    <td>
        <input tye="text" name="planningGroupCode" size="8" maxlength="20" <cfif (isDefined("FORM.planningGroupCode") AND FORM.planningGroupCode NEQ "")>value="#FORM.planningGroupCode#"</cfif>>
    </td>
  </tr>
  <tr>
    <td align="right"  width="30%" <!--- class="Orangline" --->>
      <strong>Planning Group Name<font color="red" size="2">*</font>: </strong>
    </td>
    <td>
      <input tye="text" name="planningGroupName" size="60" maxlength="50" <cfif (isDefined("FORM.planningGroupName") AND FORM.planningGroupName NEQ "")>value="#FORM.planningGroupName#"</cfif>>
    </td>
  </tr>

  <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START--->

  <cfif isBusinessSegEnabledForDistributor>
  <tr>
    <td align="right"  width="30%" <!--- class="Orangline" --->>
      <strong>#appSettings.getbusiness_segment_label()#<font color="red" size="2">*</font>:</strong>
    </td>
    <td>
	 <select name="business_segment_sel" onchange="enableField(document.DataForm.business_segment_sel.options[document.DataForm.business_segment_sel.selectedIndex].text);" <cfif (isDefined("FORM.business_segment") AND #form.business_segment# NEQ 0 )>DISABLED</cfif>>
      	<option value="0">Select a #appSettings.getbusiness_segment_label()#</option>
		<cfloop QUERY="qGetBusSegments">
		<option value="#BUSINESS_SEGMENT_ID#" <cfif (isDefined("FORM.business_segment") AND FORM.business_segment EQ #BUSINESS_SEGMENT_ID#)>SELECTED Disabled</cfif>>#Business_Unit_Desc#</option>
		</cfloop>
      </select>
	 <input type="hidden" name="business_segment" <cfif (isDefined("FORM.business_segment") AND FORM.business_segment NEQ "")>value="#FORM.business_segment#"</cfif>>
	</td>
  </tr>
    <cfelse>
  <input type="hidden" name="business_segment" value="0">
  </cfif>
  <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->

  <tr>
    <td align="right"  width="30%">
      <strong>Type Name:</strong>
    </td>
    <td>
        <!---
      The parameter passed:
      1= Product
      2= Customer
      3= Operator
    --->
     <cfset qGetActivePGTypeByGrpType = PGManager.fnGetActivePGTypesByGrpType("2") />
      <select name="selTypeName" id="SelTypeName" <cfif isBusinessSegEnabledForDistributor AND(isdefined("form.business_segment") AND #form.business_segment# EQ 0)>disabled="true"</cfif>>
        <option value="0">Select a PG Type</option>
        <cfloop query="qGetActivePGTypeByGrpType">
          <option value="#qGetActivePGTypeByGrpType.PG_Type_ID#" <cfif (isDefined("FORM.SelTypeName") AND FORM.SeltypeName EQ qGetActivePGTypeByGrpType.PG_Type_ID)>selected</cfif>>#qGetActivePGTypeByGrpType.PG_Type_Name#</option>
        </cfloop>
      </select>
     </td>
  </tr>
<cfif appSettings.get_Setting('PG_Eff_Date_Product') eq '1'>
  <tr>
    <td align="right"  width="30%">
      <strong>Effective Dates<font color="red" size="2">*</font>: <img src="/images/help_small.gif" title="The effective date is not a functional value in  FORGE and does not affect dates applied within programs, claims or reporting.  It is purely an attribute to facilitate communication with other systems."/></strong>
    </td>
    <td>
      Start Date <input type="text" name="PG_Effective_Start_Date" size="15" maxlength="10" <cfif (isDefined("FORM.PG_Effective_Start_Date") AND FORM.PG_Effective_Start_Date NEQ "")>value="#FORM.PG_Effective_Start_Date#"<cfelse>value=""</cfif>>
      End Date <input type="text" name="PG_Effective_End_Date" size="15" maxlength="10" <cfif (isDefined("FORM.PG_Effective_End_Date") AND FORM.PG_Effective_End_Date NEQ "")>value="#FORM.PG_Effective_End_Date#"<cfelse>value=""</cfif>>
  </td>
  </tr>
</cfif>
  <!--- 34007 --->
  <tr>
  		<cfinclude template="removeMembers.cfm">
  		<cfparam name="FORM.bCaptureRemoves" default="">
  		<td><input type="checkbox" name="bCaptureRemoves" <cfif FORM.bCaptureRemoves EQ "1">checked</cfif> value="1"></td>
  </tr>
  <cfif appsettings.getPayeeFromPlanningGroups() eq 1>
  <tr>
   <td align="right">
	 <strong>Vendor:</strong>
   </td>
   <td>
	<Input type="text" name="vendorName" value="#Selected_Vendor#" readonly="1" size="40">
	<Input type="hidden" name="vendor_id" value="#form.vendor_id#">
	<!--- We need to pass this to the action page as "PG_Customer_Category" table requires the GUID. --->
	<Input type="hidden" name="vendor_master_id" value="#Selected_Vendor_Master_ID#">
	<strong><span style="color:red">[ </span><a href="##" onClick="searchVendor();">select payee</a><span style="color:red">  ]</span></strong>
   </td>
   </tr>
   <tr>
   <td align="right">
	 <strong>#application.returned_customer_setting.distributor_label_singular#:</strong>
   </td>
   <td>
	<Input type="text" name="distributor_name" value="#Selected_Distributor#" readonly="1" size="40">
	<!--- We need to pass this to the action page as "PG_Customer_Category" table requires the GUID. --->
	<Input type="hidden" name="distributor_id" value="#form.distributor_id#">
	<strong><span style="color:red">[ </span><a href="##" onClick="searchDistributor();">select payee</a><span style="color:red">  ]</span></strong>
   </td>
   </tr>
   </cfif>
   <tr>
    <td align="right">
      <strong>Include in other PG:</strong>
    </td>
    <td>
      <input type="checkbox" name="bIncludeInOthers" id="bIncludeInOthers" value="1" <cfif isBusinessSegEnabledForDistributor AND(isdefined("form.business_segment") AND form.business_segment EQ 0)>disabled="true" </cfif> <cfif (isDefined("FORM.bIncludeInOthers") AND FORM.bIncludeInOthers EQ "1")>checked</cfif> >      <!--- onclick="displayRow('trPlanningGroups','bIncludeInOthers');"  --->
    </td>
  </tr>

  <tr>
    <td align="right">
      <strong>Master Data Groups Only:</strong>
    </td>
    <td>
      <cfparam name="form.bMasterGroupOnly" default="1">    <!---31191--->
      <input type="checkbox" name="bMasterGroupOnly" id="bMasterGroupOnly" value="1"
            <cfif isBusinessSegEnabledForDistributor AND (isdefined("form.business_segment") AND form.business_segment EQ 0)>disabled="true"</cfif>
            <cfif FORM.bMasterGroupOnly EQ "1">checked</cfif> >
    </td>
  </tr>

  <tr id="RadioEnable" <cfif isBusinessSegEnabledForDistributor AND(isdefined("form.business_segment") AND (#form.business_segment# EQ 0 OR #form.business_segment# EQ""))>style="display:none;"</cfif>>
    <td align="right"> <strong>Groups/#application.returned_customer_setting.distributor_label_plural#:</strong></td>
    <td><input type="radio" name="rdoIncExc" value="1"<cfif isdefined("FORM.rdoIncExc") AND FORM.rdoIncExc EQ 1>CHECKED</cfif>> Include <input type="radio" name="rdoIncExc" value="0" <cfif isdefined("FORM.rdoIncExc") AND FORM.rdoIncExc EQ 0>CHECKED</cfif>> Exclude </td>
  </tr>

  <tr id="RadioDisable" <cfif isBusinessSegEnabledForDistributor AND(isdefined("form.business_segment") AND #form.business_segment# EQ 0)><cfelse>style="display:none;"</cfif>>
    <td align="right"> <strong>Groups/#application.returned_customer_setting.distributor_label_plural#:</strong></td>
    <td><input type="radio" name="rdoIncExc1" value="1"<cfif (isDefined("FORM.rdoIncExc") AND FORM.rdoIncExc EQ 1)> CHECKED</cfif> disabled> Include <input type="radio" name="rdoIncExc1" value="0" <cfif (isDefined("FORM.rdoIncExc") AND FORM.rdoIncExc EQ 0)> CHECKED</cfif>  disabled> Exclude </td>
  </tr>

  <tr>
    <td align="right" width="30%" valign="top">
          <strong>Search #application.returned_customer_setting.distributor_label_plural#:</strong>
        </td>
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
  				<select name="GroupLevel1" id="GroupLevel1" <cfif isBusinessSegEnabledForDistributor AND(isdefined("form.business_segment") AND #form.business_segment# EQ 0)>disabled="true"</cfif>>
            <!--- 31191 - populate options dynamically by jQuery in \settings\Planning_Groups\index.cfm --->
  				</select>
          </div>

  			 <!--- <cfset extraParameter = " onClick=""javascript: return showDistGroupSearchWindow('/Search_Screens/DistributorGroup_Search.cfm?groupLevelId=' + document.DataForm.GroupLevel.options[GroupLevel.selectedIndex].value, 'Allow_Dist_group',document.DataForm.GroupLevel.options[GroupLevel.selectedIndex].value,document.DataForm);""" />   --->
<cfset extraParameter = " onClick=""javascript: return showDistGroupSearchWindow('/Search_Screens/DistributorGroup_Search.cfm?IncludeIOPGFlag=1&groupLevelId=', 'Allow_Dist_group&Business_Segment_Id='+document.DataForm.business_segment.value,document.DataForm);return false;""" />
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
  			parameters = "onClick=""javascript:showDistSearchWindow(document.DataForm.business_segment.value);return false;"""
  		>
     </td>
    </tr>
    <tr>
    <td colspan="2" align="right">
      		<!--- <CF_smallLink
  			title = "Add Planning Group"
  			url = "##"
  			parameters = "onClick=""javascript: return showXXXXX();"""
  		>
      &nbsp;&nbsp;&nbsp;&nbsp; --->
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
			      Include List
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
<cfset qGetTopLevelGroups = DistGroupDataManager.getDistributorLevels(1, "#FORM.GroupLevel#", "") />
<cfset DistGroupManager = CreateObject("component", "components.programs.distributors.DistributorGroupManager").init() />
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
   <!---  <cfset FORM.ExistingDistributorList = "" /> --->
</cfif>

     <!--- START BLOCK TO ADD INDIVIDUAL DISTRIBUTOR GROUP --->
     <cfif (isDefined("qryDistributorGroupList") AND	qryDistributorGroupList.RecordCount GTE 1 AND isDefined("FORM.rdoIncExc"))>
     <cfset sesCount = SESSION.qryGrpDistPack.RecordCount  />
     <!---  <cfset newRow =  QueryAddRow(SESSION.qryGrpDistPack,qGetApprovalGroups.recordCount) /> --->
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
				<cfif (isBusinessSegEnabledForDistributor)>
					,Bus_Seg.Business_Unit_Desc
				</cfif>
		FROM 	BSA_Foodservice_Customers
				LEFT OUTER JOIN Distributor_Group_Distributor ON
				BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Distributor_Group_Distributor.Distributor_ID
				AND Distributor_Group_Distributor.Deleted = 0
			<cfif (isBusinessSegEnabledForDistributor)>
				LEFT JOIN Business_Segment Bus_Seg
				ON Bus_Seg.Business_Segment_ID = BSA_Foodservice_Customers.Business_Segment_ID
			</cfif>
		WHERE
				BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID <CFIF Len(FORM.Distributor_List) EQ 0>IS NULL<CFELSEIF listlen(FORM.Distributor_List) GT 0>IN(#listqualify(FORM.Distributor_List, "'", ",")#)<CFELSE>!= BSA_Foodservice_Customers_ID</CFIF>
  </cfquery>
</cfif>
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
			  <cfif (isDefined("qDistributorList.Ship_To") and qDistributorList.Ship_To NEQ "")>
			  	<cfset DistName = qDistributorList.Name  & " (" & qDistributorList.Ship_To & ")" />
			  <cfelse>
			  	<cfset DistName = qDistributorList.Name   />
			  </cfif>

              <cfset temp = QuerySetCell(SESSION.qryGrpDistPack, "GroupLevel_ID", 0, SESSION.qryGrpDistPack.recordCount) />
              <!--- <cfset temp = QuerySetCell(SESSION.qryGrpDistPack, "GroupLevel_Name", qGetTopLevelGroups.Group_Level_Desc, SESSION.qryGrpDistPack.recordCount) />    --->
              <cfset temp = QuerySetCell(SESSION.qryGrpDistPack, "Group_Dist_ID", qDistributorList.BSA_FoodService_Customers_ID, SESSION.qryGrpDistPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpDistPack, "Description", qDistributorList.Name, SESSION.qryGrpDistPack.recordCount)>
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
				<cfif (isBusinessSegEnabledForDistributor)>
		   		<td width="20%" rowspan="1">
		   			<b>#appsettings.Business_Segment_Label#</b>&nbsp;
		   		</td>
				</cfif>
          </tr>

    <!--- START LISTING THE GROUPS --->
  <cfif (isDefined("SESSION.qryGrpDistPack") AND SESSION.qryGrpDistPack.RecordCount GTE 1)>
      <!---   <cfloop query="qProductList"> --->
        <cfloop query="SESSION.qryGrpDistPack">
        <!--- INDIVIDUAL DISTRIBUITOR LISTING--->
       <cfif SESSION.qryGrpDistPack.Description NEQ "" AND  SESSION.qryGrpDistPack.GroupLevel_ID EQ "0" AND SESSION.qryGrpDistPack.Inc_Exc EQ 1>
          <!--- <cfif (FindNoCase(SESSION.qryGrpDistPack.Group_Dist_ID,FORM.DelMarkedInInclude) GT 0)>  --->
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
						<cfif (isBusinessSegEnabledForDistributor)>
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
						<cfif (isBusinessSegEnabledForDistributor)>
				   		<td>#SESSION.qryGrpDistPack.Business_Unit_Desc#&nbsp;</td>
						</cfif>
          </tr>
        </cfif>
          </cfif>
        </cfloop>
      </cfif>

<cfif (isDefined("SESSION.qryGrpDistPack") AND SESSION.qryGrpDistPack.RecordCount GTE 1)>
      <!---   <cfloop query="qProductList"> --->
        <cfloop query="SESSION.qryGrpDistPack">
        <!--- GROUP DISTRIBUITOR LISTING--->
       <cfif SESSION.qryGrpDistPack.Description NEQ "" AND  SESSION.qryGrpDistPack.GroupLevel_ID NEQ "0" AND SESSION.qryGrpDistPack.Inc_Exc EQ 1>
         <!--- <cfif (FindNoCase(SESSION.qryGrpDistPack.Group_Dist_ID,FORM.DelMarkedInInclude) GT 0)> --->
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
						<cfif (isBusinessSegEnabledForDistributor)>
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
						<cfif (isBusinessSegEnabledForDistributor)>
				   		<td>#SESSION.qryGrpDistPack.Business_Unit_Desc#&nbsp;</td>
						</cfif>
          </tr>
         </cfif>
        </cfif>
        </cfloop>
      </cfif>

    <!--- END LISTING THE INDIVIDUAL DISTRIBUTORS --->
      </table>
      <!--- Contents go here END ---->
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
         <span id="title_3" onclick="switchlayer(3,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" style="cursor:pointer;color:00773c">
          <span title="Click here to toggle the view">
			      Exclude List
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
					<cfif (isBusinessSegEnabledForDistributor)>
			   		<td width="20%" rowspan="1">
			   			<b>#appsettings.Business_Segment_Label#</b>&nbsp;
			   		</td>
					</cfif>
         </tr>

    <cfif (isDefined("SESSION.qryGrpDistPack") AND SESSION.qryGrpDistPack.RecordCount GTE 1)>
       <cfloop query="SESSION.qryGrpDistPack">
       <cfif SESSION.qryGrpDistPack.Description NEQ "" AND  SESSION.qryGrpDistPack.GroupLevel_ID EQ "0" AND SESSION.qryGrpDistPack.Inc_Exc EQ 0>
          <!--- <cfif (FindNoCase(SESSION.qryGrpDistPack.Group_Dist_ID,FORM.DelMarkedInExclude) GT 0)> --->
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
						<cfif (isBusinessSegEnabledForDistributor)>
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
						<cfif (isBusinessSegEnabledForDistributor)>
				   		<td>#SESSION.qryGrpDistPack.Business_Unit_Desc#&nbsp;</td>
						</cfif>
          </tr>
          </cfif>
          </cfif>
        </cfloop>
      </cfif>

<cfif (isDefined("SESSION.qryGrpDistPack") AND SESSION.qryGrpDistPack.RecordCount GTE 1)>
      <!---   <cfloop query="qProductList"> --->
        <cfloop query="SESSION.qryGrpDistPack">
       <cfif SESSION.qryGrpDistPack.Description NEQ "" AND  SESSION.qryGrpDistPack.GroupLevel_ID NEQ "0" AND SESSION.qryGrpDistPack.Inc_Exc EQ 0>
          <!--- <cfif (FindNoCase(SESSION.qryGrpDistPack.Group_Dist_ID,FORM.DelMarkedInExclude) GT 0)> --->
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
						<cfif (isBusinessSegEnabledForDistributor)>
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
						<cfif (isBusinessSegEnabledForDistributor)>
				   		<td>#SESSION.qryGrpDistPack.Business_Unit_Desc#&nbsp;</td>
						</cfif>
          </tr>

         </cfif>

          </cfif>
        </cfloop>
      </cfif>
    </table>
      <!--- Contents go here --->
      </div>
    </div>
</fieldset>
<!--- EXCLUDE LIST ENDS --->
      </td>
    </tr>
    <tr>
    <td align="right" colspan="2">
    <CF_smallLink
  			title = "Save & Add another Planning Group"
  			url = "##"
  			parameters = "onClick=""javascript:saveAddCPG('1','#isBusinessSegEnabledForDistributor#','#appsettings.getPayeeFromPlanningGroups()#');return false;"""
  		>
      &nbsp;&nbsp;&nbsp;&nbsp;
     <CF_smallLink
  			title = "Save & Quit"
  			url = "##"
  			parameters = "onClick=""javascript:saveAddCPG('2','#isBusinessSegEnabledForDistributor#','#appsettings.getPayeeFromPlanningGroups()#');return false;"""
  		>
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
  <input type="hidden" name="Allow_Dist_group" value="#FORM.Allow_Dist_group#">
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
