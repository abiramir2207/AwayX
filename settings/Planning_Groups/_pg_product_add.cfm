<!-----------------------------------------------------------------------------

FILE NAME:		_pg_product_add.cfm
DESCRIPTION:
CREATED BY:		10-Aug-2010
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

      			Anand Rao	  10-Aug-2010	Created the file
------------------------------------------------------------------------------>

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

<!--- Check to see if there is a query named qryGrpProdPack in the SESSION scope,
      if not create one --->

<cfif NOT isDefined("SESSION.qryGrpProdPack")>
  <cfset SESSION.qryGrpProdPack = QueryNew("GroupLevel_ID, GroupLevel_Name, GroupLevel_Number, Group_Product_ID, Item_No, Description, Inc_Exc, IsPG, Business_Unit_Desc")>
  <!--- <cfset SESSION.qryGrpProdPack = qryGrpProdPack /> --->
</cfif>

<input type="hidden" name="rdoIncExcDup" <cfif isDefined("FORM.rdoIncExc")>value="#FORM.rdoIncExc#"<cfelseif isDefined("FORM.rdoIncExcDup")>value="#FORM.rdoIncExcDup#"</cfif>>

<cfif isDefined("FORM.rdoIncExc") AND FORM.rdoIncExc EQ 1>
  <cfset frmRdoIncExcVal = 1/>
  <cfset temp = StructDelete(FORM,"rdoIncExc" ) />
<Cfelseif isDefined("FORM.rdoIncExc") AND FORM.rdoIncExc EQ 0>
  <cfset frmRdoIncExcVal = 0/>
  <cfset temp = StructDelete(FORM,"rdoIncExc" ) />
<cfelseif isDefined("FORM.rdoIncExcDup")>
  <cfset frmRdoIncExcVal = FORM.rdoIncExcDup />
<cfelse>
  <cfset frmRdoIncExcVal = 0 />
</cfif>

<input type="hidden" visible="false" name="ExistingProductList" value="">
<input type="hidden" name="Product_List" value="">
<input type="hidden" name="ProductListToExcludeFromSelecting" value="">
<input type="hidden" name="PG_Effective_Date_ON" value="#appSettings.get_Setting('PG_Eff_Date_Product')#">

<cfif isDefined("FORM.GroupLevel_Name") AND GroupLevel_Name NEQ "">
  <input type="hidden" name="GroupLevel_Name" value="#FORM.GroupLevel_Name#" />
<cfelse>
  <input type="hidden" name="GroupLevel_Name" value="" />
</cfif>

<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">#application.returned_customer_setting.Item_Label# Planning Group Information</LEGEND>
    <table  border="1" width="782"  cellpadding="5" cellspacing="0"  rules="groups" bordercolor="800000" style="border-radius:5px;">
		<!------ external id ----->

 <table width="768" border="0" cellpadding="5" cellspacing="0" rules="groups" bordercolor="800000">
    <tr>
    <td>
    <font color="red" size="5">*</font> - Required Field
 <table width="100%" border="0" cellpadding="4" cellspacing="4" cols="groups" rules="groups" bordercolor="a85400">   <!--- 30923 --->
 <tr>
  <td colspan="2" height="6px;"></td>
 </tr>
  <tr>
    <td align="right"  width="30%">
      <strong>Planning Group Code: </strong>
    </td>
    <td>
      <input tye="text" name="planningGroupCode" size="8" maxlength="20" <cfif (isDefined("FORM.planningGroupCode") AND FORM.planningGroupCode NEQ "")>value="#FORM.planningGroupCode#"</cfif>>
    </td>
  </tr>
  <tr>
    <td align="right"  width="30%">
      <strong>Planning Group Name<font color="red" size="2">*</font>: </strong>
    </td>
    <td>
      <input tye="text" name="planningGroupName" size="60" maxlength="50" <cfif (isDefined("FORM.planningGroupName") AND FORM.planningGroupName NEQ "")>value="#FORM.planningGroupName#"</cfif>>
    </td>
  </tr>


  <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START--->

  <cfif isBusinessSegEnabledForProduct>
  <tr>
    <td align="right"  width="30%">
      <strong>#appSettings.getbusiness_segment_label()#<font color="red" size="2">*</font>:</strong>
    </td>
    <td>
	 <select name="business_segment_sel" onchange="enableField(document.DataForm.business_segment_sel.options[document.DataForm.business_segment_sel.selectedIndex].text);"<cfif (isDefined("FORM.business_segment") AND FORM.business_segment NEQ 0)>DISABLED</cfif>>
      	<option value="0">Select a #appSettings.getbusiness_segment_label()#</option>
		<cfloop QUERY="qGetBusSegments">
		<option value="#trim(BUSINESS_SEGMENT_ID)#" <cfif (isDefined("FORM.business_segment") AND FORM.business_segment EQ #BUSINESS_SEGMENT_ID#)>SELECTED Disabled</cfif>>#Business_Unit_Desc#</option>
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
      <strong>Type Name<font color="red" size="2">*</font>:</strong>
    </td>
    <td>
    <!---
      1= Product
      2= Customer
    --->
      <cfset qGetActivePGTypeByGrpType = PGManager.fnGetActivePGTypesByGrpType("1") />
      <select name="selTypeName" id="selTypeName" <cfif isBusinessSegEnabledForProduct AND (isdefined("form.business_segment") AND #form.business_segment# EQ 0)>disabled="true"</cfif>>
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
      <strong>Effective Date<font color="red" size="2">*</font>: <img src="/images/help_small.gif" title="The effective date is not a functional value in  FORGE and does not affect dates applied within programs, claims or reporting.  It is purely an attribute to facilitate communication with other systems."/></strong>
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

  <tr>
    <td align="right">
      <strong>Include in other PG:</strong>
    </td>
    <td>
      <input type="checkbox" name="bIncludeInOthers" id="bIncludeInOthers" value="1" <cfif isBusinessSegEnabledForProduct AND(isdefined("form.business_segment") AND #form.business_segment# EQ 0)>disabled="true"</cfif> <cfif isDefined("FORM.bIncludeInOthers") AND FORM.bIncludeInOthers EQ "1">checked</cfif> > <!---  onclick="displayRow('trPlanningGroups','bIncludeInOthers');" --->
    </td>
  </tr>

  <tr>
    <td align="right">
      <strong>Master Data Groups Only:</strong>
    </td>
    <td>
      <cfparam name="form.bMasterGroupOnly" default="1">
      <input type="checkbox" name="bMasterGroupOnly" id="bMasterGroupOnly" value="1" <cfif isBusinessSegEnabledForProduct AND (isdefined("form.business_segment") AND form.business_segment EQ 0)>disabled="true"</cfif> <cfif FORM.bMasterGroupOnly EQ "1">checked</cfif> >
    </td>
  </tr>

 <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START--->
  <tr id="RadioEnable" <cfif isBusinessSegEnabledForProduct AND(isdefined("form.business_segment") AND #form.business_segment# EQ 0)>style="display:none;"</cfif>>
    <td align="right"> <strong>Groups/#application.returned_customer_setting.item_label#</strong></td>
    <td><input type="radio" name="rdoIncExc" value="1"> Include <input type="radio" name="rdoIncExc" value="0"> Exclude </td>
  </tr>

  <tr id="RadioDisable" <cfif isBusinessSegEnabledForProduct AND(isdefined("form.business_segment") AND #form.business_segment# EQ 0)><cfelse>style="display:none;"</cfif>>
    <td align="right"> <strong>Groups/#application.returned_customer_setting.item_label#</strong></td>
    <td><input type="radio" name="rdoIncExc1" value="1" disabled> Include <input type="radio" name="rdoIncExc1" value="0" disabled> Exclude </td>
  </tr>
 <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->
  <tr>
    <td align="right" width="30%" valign="top">
          <strong>Search #application.returned_customer_setting.Item_Label#s:</strong>
        </td>
        <td>
        <cfif isDefined("application.returned_customer_setting.group_deals") AND application.returned_customer_setting.group_deals EQ 1>
        <cfset qGetTopLevelGroups = GroupDataManager.getProductGroupsData() />
		<cfset qGetSystemPGTypes = PGManager.fnGetSystemPGTypes("1") />
		<cfset lstSystemPGTypes = ValueList(qGetSystemPGTypes.PG_Type_ID) />
      	  <cfset addGroupLabel = "add groups" />

          <!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
              31191 - added logic to update options in Search Products dropdown
                      based on "include in other pg" & "master groups only"
          ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
          <cfset prod = structNew()>
          <cfset prod.blank = "<option value=''>Select Group...</option>">
          <cfset prod.all = prod.blank>
          <cfset prod.master = prod.blank>
          <cfset prod.system = prod.blank>
          <cfset prod.masterSystem = prod.blank>

          <!--- Save options for master groups into prod.master,
                Save options for master group & system pg into prod.masterSystem
                Save options for all into prod.all
                These variables will be converted into js variables
                so they can be used dynamically in jQuery--->
          <cfloop query="qGetTopLevelGroups">
            <cfset prod.option = "<option value='#qGetTopLevelGroups.Product_Group_Level_ID#'>#qGetTopLevelGroups.Group_Level_Desc#</option>">

            <!--- master group indicator --->
            <cfif qGetTopLevelGroups.Is_PG eq 0>
              <cfset prod.master = prod.master & prod.option>
              <cfset prod.masterSystem = prod.masterSystem & prod.option>
            </cfif>

            <!--- system planning group indicator --->
            <cfif ListFind(lstSystemPGTypes, qGetTopLevelGroups.Product_Group_Level_ID)>
              <cfset prod.system = prod.system & prod.option>
              <!---<cfset prod.master = prod.master & prod.option>Drachala D32628 Segment Planning Groups Unavailable REMOVED IT AGAIN FOR LABEL 37056--->
              <!--- if this option is not master add it to the mastersystem list --->
              <cfif qGetTopLevelGroups.Is_PG neq 0>
                <cfset prod.masterSystem = prod.masterSystem & prod.option>
              </cfif>
            </cfif>

            <cfset prod.all = prod.all & prod.option>
          </cfloop>

          <div id="WithPG">
    				<select name="GroupLevel1" id="GroupLevel1" <cfif isBusinessSegEnabledForProduct AND (structkeyexists(form, "business_segment") AND form.business_segment EQ 0)>disabled="true"</cfif>>
              <!--- 31191 - populate options dynamically by jQuery in \settings\Planning_Groups\index.cfm --->
    				</select>
          </div>

<!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START Modified added URL variable Business Segment Id--->
<cfset extraParameter = " onClick=""javascript:showSearchWindow('/Search_Screens/ApprovalGroup_Search.cfm?IncludeIOPGFlag=1&prodRefresh=1&groupLevelId=', 'Allow_Approval_group&Business_Segment_Id='+document.DataForm.business_segment.value,document.DataForm);return false;""" />
<!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->

<!--- There was a return in before  showSearchWindow --->
  		 		<CF_smallLink
  					title = "add group"
  					url = "##"
  					parameters = "#extraParameter#"
  					>
        <input type="hidden" name="GroupLevel" value="#FORM.GroupLevel#" />
      <cfelse>
        <input type="hidden" name="GroupLevel" value="" />
      </cfif>
      <cfset addProductLabel = "add #application.returned_customer_setting.Item_Label#s" />
 <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START modified javascript passing business segment id value.--->
  		<CF_smallLink
  			title = "#addProductLabel#"
  			url = "##"
  			parameters = "onClick=""javascript:showProductSearchWindow(document.DataForm.business_segment.value);return false;"""
  		>
  <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->
    </td>
    </tr>
    <tr>
    <td colspan="2" align="right">

    </td>
    </tr>
    <tr>
      <td colspan="2">


<!--- INCLUDE LIST STARTS --->

 <fieldset id="border_2" style="border-width:0; border-color:; border-style:solid; width:710">
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

      <cfif Len(FORM.product_List) GT 0 >
      <cfset qProductList = ProductManager.getproducts(FORM.product_List) />
      </cfif>
      <cfif Len(FORM.Allow_Approval_group) GT 0>
        <cfif FORM.GroupLevel EQ "">
          <cfif FORM.GroupLevel1 NEQ "">
            <cfset FORM.GroupLevel = FORM.GroupLevel1 />
          <cfelseif FORM.GroupLevel2 NEQ "">
            <cfset FORM.GroupLevel = FORM.GroupLevel2 />
          </cfif>
        </cfif>
        <cfif FORM.GroupLevel NEQ "">
          <cfset approvalGroupManager.getGroupTypeInfo(FORM.GroupLevel)/>
  			</cfif>
        <cfset qGetApprovalGroups = approvalGroupManager.getApprovalGroups(FORM.Allow_Approval_group)>
      </cfif>
 <cfset FORM.Allow_Approval_group = "" />
     <cfif (isDefined("qGetApprovalGroups") AND	qGetApprovalGroups.RecordCount GTE 1)>
      <cfset sesCount = SESSION.qryGrpProdPack.RecordCount  />
     <!---  <cfset newRow =  QueryAddRow(SESSION.qryGrpProdPack,qGetApprovalGroups.recordCount) /> --->
      <cfset rCount = SESSION.qryGrpProdPack.RecordCount + 1  />
      <cfset iCounter = 1 />
      <cfloop query="qGetApprovalGroups">
        <cfset recExists = 0 />
        <cfloop query="SESSION.qryGrpProdPack">
          <cfif SESSION.qryGrpProdPack.Group_Product_ID EQ qGetApprovalGroups.Group_ID AND SESSION.qryGrpProdPack.Inc_Exc EQ frmRdoIncExcVal>
            <cfset recExists = 1 />
            <cfbreak />
          </cfif>
        </cfloop>
        <cfif recExists EQ 0>
          <cfset bIsPG = 0 />
          <cfloop query="qGetTopLevelGroups">
            <cfif qGetTopLevelGroups.Group_Level_Desc EQ FORM.GroupLevel_Name AND qGetTopLevelGroups.Product_Group_Level_ID EQ FORM.GroupLevel>
              <cfset bIsPG = qGetTopLevelGroups.Is_PG />
            </cfif>
          </cfloop>
          <cfset newRow =  QueryAddRow(SESSION.qryGrpProdPack,1) />
          <cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "GroupLevel_ID", FORM.GroupLevel, SESSION.qryGrpProdPack.recordCount) />
          <cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "Group_Product_ID", qGetApprovalGroups.Group_ID, SESSION.qryGrpProdPack.recordCount) />
		  <cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "GroupLevel_Number", qGetApprovalGroups.Group_Number, SESSION.qryGrpProdPack.recordCount) />
          <cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "Description", qGetApprovalGroups.Group_Name, SESSION.qryGrpProdPack.recordCount) />
          <cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "GroupLevel_Name",FORM.GroupLevel_Name, SESSION.qryGrpProdPack.recordCount) />
          <cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "Inc_Exc", frmRdoIncExcVal, SESSION.qryGrpProdPack.recordCount) />
          <cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "IsPG", bIsPG, SESSION.qryGrpProdPack.recordCount) />
					<cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "Business_Unit_Desc", "", SESSION.qryGrpProdPack.recordCount) />
          <cfset iCounter  = iCounter + 1 />
        </cfif>
      </cfloop>
     </cfif>

      <cfif (isDefined("qProductList") AND qProductList.RecordCount GT 0)>
        <cfset sesCount = SESSION.qryGrpProdPack.RecordCount  />
       <!---  <cfset newRow =  QueryAddRow(SESSION.qryGrpProdPack,qProductList.recordCount) /> --->
        <cfset rCount = SESSION.qryGrpProdPack.RecordCount + 1  />
        <cfset iCounter = 1 />
        <cfloop query="qProductList">
        <cfset recExists = 0 />
				<cfset BusinessSegment = ""/>
				<cfif (isDefined("qProductList.Business_Unit_Desc") AND qProductList.Business_Unit_Desc NEQ "")>
					<cfset BusinessSegment = qProductList.Business_Unit_Desc />
				</cfif>
          <cfloop query="SESSION.qryGrpProdPack">
            <cfif SESSION.qryGrpProdPack.Group_Product_ID EQ qProductList.BSA_FoodService_Items_Master_ID AND SESSION.qryGrpProdPack.Inc_Exc EQ frmRdoIncExcVal>
              <cfset recExists = 1 />
              <cfbreak />
            </cfif>
            </cfloop>
            <cfif recExists EQ 0>
              <cfset newRow =  QueryAddRow(SESSION.qryGrpProdPack,1) />
              <cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "GroupLevel_ID", 0, SESSION.qryGrpProdPack.recordCount) />
              <cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "Group_Product_ID", qProductList.BSA_FoodService_Items_Master_ID, SESSION.qryGrpProdPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "Item_No", qProductList.Item, SESSION.qryGrpProdPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "Description", qProductList.Description, SESSION.qryGrpProdPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "Inc_Exc", frmRdoIncExcVal, SESSION.qryGrpProdPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "IsPG", 0, SESSION.qryGrpProdPack.recordCount) />
							<cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "Business_Unit_Desc", BusinessSegment, SESSION.qryGrpProdPack.recordCount) />
              <cfset iCounter  = iCounter + 1 />
            </cfif>
        </cfloop>
      </cfif>

			<table cellpadding="2" cellspacing="1" width="100%" border="1" bordercolor="979797">
       <tr>
	       <td id="header" WIDTH="3%" rowspan="1">
			    <NOBR>
				  <img name="IMG_Delete_Scissor_Include" bDelete="true" sMessage="delete all records in this page" src="/images/scissor.gif" title="delete all records in this page" border="0" onclick="if(confirm('Please confirm that you would like to DELETE all checked products!')){fnDeleteAllList('#valueList(SESSION.qryGrpProdPack.Group_Product_ID)#','tr_prodAddInc_','1');};" style="cursor:pointer;">
			    </NOBR>
		    </td>
				<td width="20%" rowspan="1">
	   		  <b>Group/#application.returned_customer_setting.Item_Label# Number </b>
	   		</td>
	   		<td width="30%" rowspan="1">
	   		  <b>
	           Group/#application.returned_customer_setting.Item_Label#  Description
	         </b>
	   		</td>
	   		<td width="30%" rowspan="1">
	   			<b>Group/#application.returned_customer_setting.Item_Label# Name</b>&nbsp;
	   		</td>
				<cfif isBusinessSegEnabledForProduct>
		   		<td width="20%" rowspan="1">
		   			<b>#appsettings.Business_Segment_Label#</b>&nbsp;
		   		</td>
				</cfif>
      </tr>
    <cfif (isDefined("SESSION.qryGrpProdPack") AND SESSION.qryGrpProdPack.RecordCount GTE 1 AND isDefined("SESSION.qryGrpProdPack.GroupLevel_Name"))>
       <cfloop query="SESSION.qryGrpProdPack">
       <cfif SESSION.qryGrpProdPack.Description NEQ "" AND SESSION.qryGrpProdPack.Item_No EQ "" AND SESSION.qryGrpProdPack.Inc_Exc EQ 1>
          <!--- <cfif (FindNoCase(SESSION.qryGrpProdPack.Group_Product_ID,FORM.DelMarkedInInclude) GT 0)>  --->
					<cfset recStriked = 0>
					<cfloop index = "delItem" list = "#FORM.DelMarkedInInclude#"  delimiters = ",">
						<cfif delItem EQ SESSION.qryGrpProdPack.Group_Product_ID>
							<cfset 	recStriked = 1 />
						</cfif>
					</cfloop>
					<cfif recStriked EQ 1>

        <tr id="tr_prodAddInc_#SESSION.qryGrpProdPack.Group_Product_ID#"  style="text-decoration:line-through;background-color:bbbbbb">
          <td width="15">
  				   <img bDelete="false" name="IMG_Delete_Scissor_Include"  src="/images/undo.gif"  title="click here to undelete this product" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpProdPack.Group_Product_ID#', 'tr_prodAddInc_#SESSION.qryGrpProdPack.Group_Product_ID#','1');" style="cursor:pointer;">
  			  </td>
  				<td><cfif (SESSION.qryGrpProdPack.GroupLevel_Number NEQ "")>#SESSION.qryGrpProdPack.GroupLevel_Number#<cfelse>Group #application.returned_customer_setting.Item_Label#</cfif></td>
          <td>Level 1/#SESSION.qryGrpProdPack.GroupLevel_Name#</td>
          <td>#SESSION.qryGrpProdPack.Description#</td>
				<cfif isBusinessSegEnabledForProduct>
		   		<td>#SESSION.qryGrpProdPack.Business_Unit_Desc#&nbsp;</td>
				</cfif>
        </tr>
       <cfelse>
         <tr id="tr_prodAddInc_#SESSION.qryGrpProdPack.Group_Product_ID#" bgcolor="eeeeee">
          <td width="15">
  				   <img bDelete="true" name="IMG_Delete_Scissor_Include"  src="/images/scissor.gif"  title="click here to delete this product" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpProdPack.Group_Product_ID#', 'tr_prodAddInc_#SESSION.qryGrpProdPack.Group_Product_ID#','1');" style="cursor:pointer;">
  			  </td>
   				<td><cfif (SESSION.qryGrpProdPack.GroupLevel_Number NEQ "")>#SESSION.qryGrpProdPack.GroupLevel_Number#<cfelse>Group #application.returned_customer_setting.Item_Label#</cfif></td>
          <td>Level 1/#SESSION.qryGrpProdPack.GroupLevel_Name#</td>
          <td>#SESSION.qryGrpProdPack.Description#</td>
					<cfif isBusinessSegEnabledForProduct>
			   		<td>#SESSION.qryGrpProdPack.Business_Unit_Desc#&nbsp;</td>
					</cfif>
        </tr>
        </cfif>
        </cfif>
      </cfloop>
    </cfif>

<!--- <cfif isDefined("qProductList") AND qProductList.RecordCount GT 0> --->
  <cfif (isDefined("SESSION.qryGrpProdPack") AND SESSION.qryGrpProdPack.RecordCount GTE 1)>
    <cfloop query="SESSION.qryGrpProdPack">
       <cfif SESSION.qryGrpProdPack.Description NEQ "" AND SESSION.qryGrpProdPack.Item_No NEQ "" AND SESSION.qryGrpProdPack.GroupLevel_ID EQ "0" AND SESSION.qryGrpProdPack.Inc_Exc EQ 1>
     <!---    <cfif (FindNoCase(SESSION.qryGrpProdPack.Group_Product_ID,FORM.DelMarkedInInclude) GT 0)> --->
		 					<cfset recStriked = 0>
					<cfloop index = "delItem" list = "#FORM.DelMarkedInInclude#"  delimiters = ",">
						<cfif delItem EQ SESSION.qryGrpProdPack.Group_Product_ID>
							<cfset 	recStriked = 1 />
						</cfif>
					</cfloop>
					<cfif recStriked EQ 1>
           <tr id="tr_prodAddInc_#SESSION.qryGrpProdPack.Group_Product_ID#" style="text-decoration:line-through;background-color:bbbbbb">
            <td width="15">
  				    <img  name="IMG_Delete_Scissor_Include" src="/images/undo.gif" bDelete="false" title="click here to undelete this product" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpProdPack.Group_Product_ID#', 'tr_prodAddInc_#SESSION.qryGrpProdPack.Group_Product_ID#','1');" style="cursor:pointer;">
   			    </td>
  				  <td>#SESSION.qryGrpProdPack.Item_No#</td>
            <td><!--- Level 2/ --->Product</td>
  				  <td>#SESSION.qryGrpProdPack.Description#</td>
						<cfif isBusinessSegEnabledForProduct>
				   		<td>#SESSION.qryGrpProdPack.Business_Unit_Desc#&nbsp;</td>
						</cfif>
          </tr>
        <cfelse>
          <tr id="tr_prodAddInc_#SESSION.qryGrpProdPack.Group_Product_ID#" bgcolor="eeeeee">
            <td width="15">
  				    <img  name="IMG_Delete_Scissor_Include" src="/images/scissor.gif" bDelete="true" title="click here to delete this product" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpProdPack.Group_Product_ID#', 'tr_prodAddInc_#SESSION.qryGrpProdPack.Group_Product_ID#','1');" style="cursor:pointer;">
  			    </td>
  				  <td>
            #SESSION.qryGrpProdPack.Item_No#</td>
            <td><!--- Level 2/ --->Product</td>
  				  <td>#SESSION.qryGrpProdPack.Description#</td>
						<cfif isBusinessSegEnabledForProduct>
				   		<td>#SESSION.qryGrpProdPack.Business_Unit_Desc#&nbsp;</td>
						</cfif>
          </tr>
          </cfif>
          </cfif>
        </cfloop>
      </cfif>
    </table>
      <!--- Contents go here END ---->
      </div>
    </div>
</fieldset>


<!--- INCLUDE LIST ENDS --->

<!--- EXCLUDE LIST STARTS --->
 <fieldset id="border_3" style="border-width:0; border-color:; border-style:solid; width:710">
     <legend>
      <span>
        <img id="image_3" src="/images/plus2.gif" onclick="switchlayer(3,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" border="0" title="" style="cursor:pointer">

       <font face="Arial">
        <b style="font-size:9pt">
         <span id="title_3" onclick="switchlayer(3,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" style="cursor:pointer;color:00773c">
          <span  title="Click here to toggle the view">
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
          <td id="header" WIDTH="3%" rowspan="1">
  			    <NOBR>
  				  <img name="IMG_Delete_Scissor_Exclude" bDelete="true" sMessage="delete all records in this page" src="/images/scissor.gif" title="delete all records in this page" border="0" onclick="if(confirm('Please confirm that you would like to DELETE all checked products!')){fnDeleteAllList('#valueList(SESSION.qryGrpProdPack.Group_Product_ID)#','tr_prodAddExc_','0');};" style="cursor:pointer;">
  			    </NOBR>
  		    </td>
					<td width="20%" rowspan="1">
      		  <b>Group/#application.returned_customer_setting.Item_Label# Number </b>
      		</td>
      		<td width="30%" rowspan="1">
      		  <b>
              Group/#application.returned_customer_setting.Item_Label#  Description
            </b>
      		</td>
      		<td width="30%" rowspan="1">
      			<b>Group/#application.returned_customer_setting.Item_Label# Name</b>&nbsp;
      		</td>
					<cfif isBusinessSegEnabledForProduct>
			   		<td width="20%" rowspan="1">
			   			<b>#appsettings.Business_Segment_Label#</b>&nbsp;
			   		</td>
					</cfif>
         </tr>
         <cfif (isDefined("SESSION.qryGrpProdPack") AND SESSION.qryGrpProdPack.RecordCount GTE 1 AND isDefined("SESSION.qryGrpProdPack.GroupLevel_Name"))>
       <cfloop query="SESSION.qryGrpProdPack">
       <cfif SESSION.qryGrpProdPack.Description NEQ "" AND SESSION.qryGrpProdPack.Item_No EQ "" AND Inc_Exc EQ 0>
					<cfset recStriked = 0>
					<cfloop index = "delItem" list = "#FORM.DelMarkedInExclude#"  delimiters = ",">
						<cfif delItem EQ SESSION.qryGrpProdPack.Group_Product_ID>
							<cfset 	recStriked = 1 />
						</cfif>
					</cfloop>
					<cfif recStriked EQ 1>
					<tr id="tr_prodAddExc_#SESSION.qryGrpProdPack.Group_Product_ID#" style="text-decoration:line-through;background-color:bbbbbb">
          <td width="15">
            <img bDelete="false" name="IMG_Delete_Scissor_Exclude" src="/images/undo.gif" title="click here to undelete this product" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpProdPack.Group_Product_ID#', 'tr_prodAddExc_#SESSION.qryGrpProdPack.Group_Product_ID#','0');" style="cursor:pointer;">
  			  </td>
  				<td><cfif (SESSION.qryGrpProdPack.GroupLevel_Number NEQ "")>#SESSION.qryGrpProdPack.GroupLevel_Number#<cfelse>Group #application.returned_customer_setting.Item_Label#</cfif>&nbsp;</td>
          <td>Level 1/#SESSION.qryGrpProdPack.GroupLevel_Name#&nbsp;</td>
          <td>#SESSION.qryGrpProdPack.Description#&nbsp;</td>
					<cfif isBusinessSegEnabledForProduct>
			   		<td>#SESSION.qryGrpProdPack.Business_Unit_Desc#&nbsp;</td>
					</cfif>
				</tr>
        <cfelse>
            <tr id="tr_prodAddExc_#SESSION.qryGrpProdPack.Group_Product_ID#" bgcolor="eeeeee">
          <td width="15">
           	  <img bDelete="true" name="IMG_Delete_Scissor_Exclude"  src="/images/scissor.gif"  title="click here to delete this product" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpProdPack.Group_Product_ID#', 'tr_prodAddExc_#SESSION.qryGrpProdPack.Group_Product_ID#','0');" style="cursor:pointer;">
  			  </td>
  				<td><cfif (SESSION.qryGrpProdPack.GroupLevel_Number NEQ "")>#SESSION.qryGrpProdPack.GroupLevel_Number#<cfelse>Group #application.returned_customer_setting.Item_Label#</cfif></td>
          <td>Level 1/#SESSION.qryGrpProdPack.GroupLevel_Name# </td>
          <td>#SESSION.qryGrpProdPack.Description#</td>
					<cfif isBusinessSegEnabledForProduct>
			   		<td>#SESSION.qryGrpProdPack.Business_Unit_Desc#&nbsp;</td>
					</cfif>
        </tr>
        </cfif>

        </cfif>
      </cfloop>
    </cfif>

    <cfif (isDefined("SESSION.qryGrpProdPack") AND SESSION.qryGrpProdPack.RecordCount GTE 1)>
        <cfloop query="SESSION.qryGrpProdPack">
       <cfif SESSION.qryGrpProdPack.Description NEQ "" AND SESSION.qryGrpProdPack.Item_No NEQ "" AND (SESSION.qryGrpProdPack.GroupLevel_ID EQ "" OR SESSION.qryGrpProdPack.GroupLevel_ID EQ 0) AND SESSION.qryGrpProdPack.Inc_Exc EQ 0>
					<cfset recStriked = 0>
					<cfloop index = "delItem" list = "#FORM.DelMarkedInExclude#"  delimiters = ",">
						<cfif delItem EQ SESSION.qryGrpProdPack.Group_Product_ID>
							<cfset 	recStriked = 1 />
						</cfif>
					</cfloop>
					<cfif recStriked EQ 1>
           <tr id="tr_prodAddExc_#SESSION.qryGrpProdPack.Group_Product_ID#" style="text-decoration:line-through;background-color:bbbbbb">
              <td width="15">
    				    <img bDelete="false" name="IMG_Delete_Scissor_Exclude"  src="/images/undo.gif"  title="click here to undelete this product" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpProdPack.Group_Product_ID#', 'tr_prodAddExc_#SESSION.qryGrpProdPack.Group_Product_ID#','1');" style="cursor:pointer;">
    			    </td>
     				  <td>#SESSION.qryGrpProdPack.Item_No#</td>
              <td>Product</td>
    				  <td>#SESSION.qryGrpProdPack.Description#</td>
							<cfif isBusinessSegEnabledForProduct>
					   		<td>#SESSION.qryGrpProdPack.Business_Unit_Desc#&nbsp;</td>
							</cfif>
            </tr>
           <cfelse>
            <tr id="tr_prodAddExc_#SESSION.qryGrpProdPack.Group_Product_ID#" bgcolor="eeeeee">
              <td width="15">
    				    <img bDelete="true" name="IMG_Delete_Scissor_Exclude"  src="/images/scissor.gif"  title="click here to delete this product" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpProdPack.Group_Product_ID#', 'tr_prodAddExc_#SESSION.qryGrpProdPack.Group_Product_ID#','1');" style="cursor:pointer;">
    			    </td>
     				  <td>#SESSION.qryGrpProdPack.Item_No#</td>
              <td>Product</td>
    				  <td>#SESSION.qryGrpProdPack.Description#</td>
							<cfif isBusinessSegEnabledForProduct>
					   		<td>#SESSION.qryGrpProdPack.Business_Unit_Desc#&nbsp;</td>
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
</table>
      </td>
    </tr>
    <tr>
    <td align="right">

    <CF_smallLink
  			title = "Save & Add another Planning Group"
  			url = "##"
  			parameters = "onClick=""javascript:saveAddPPG('1','#isBusinessSegEnabledForProduct#');return false;"""
  		>
      &nbsp;&nbsp;&nbsp;&nbsp;

      <CF_smallLink
  			title = "Save & Quit"
  			url = "##"
  			parameters = "onClick=""javascript:saveAddPPG('2','#isBusinessSegEnabledForProduct#');return false;"""
  		>

    </td>
    </tr>

    </table>

<!--- Planning Group whole box--->

</td>
</tr>

</table>
</fieldset>
 <br>


  <input type="hidden" name="DelMarkedInInclude" id="DelMarkedInInclude" value="#FORM.DelMarkedInInclude#" />
  <input type="hidden" name="DelMarkedInExclude" id="DelMarkedInExclude" value="#FORM.DelMarkedInExclude#" />

  <input type="hidden" name="Allow_Approval_group" value="#FORM.Allow_Approval_group#">
	<input type="hidden" name="bSubmit" value="0" />
  <cfif FORM.display EQ "add">
      <input type="hidden" name="productRefresh" value = "0" />
  </cfif>
	<script>
	///////////////////////////////////   Update Component //////////////////////////////////////////


  function deleteThisProduct(FieldNameRe, prodID, bgCol, GroupID)//,realGroupLevelId
	{
			var srcObj = event.srcElement;
			var trObj = getParentObject(srcObj, "tr");
			var trIndex = trObj.rowIndex;
			var FINALITEMLIST = document.DataForm.Product_List.value;
      var FINALGROUPLIST = document.DataForm.Allow_Approval_group.value;
			var resultString = ListDeleteItem(FINALITEMLIST, ",", prodID);
      var grpResultString = ListDeleteItem(FINALGROUPLIST, ",", GroupID);
			var bDelete = true;
			var objGroupLevel;
 			var itemCount = FINALITEMLIST.split(",");
      var groupCount = FINALGROUPLIST.split(",");

      if (prodID != "")
      {
        if (resultString == FINALITEMLIST)
        {
          resultString = ListAppendItem(FINALITEMLIST, ",", prodID);
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
		 	document.DataForm.Product_List.value = resultString;
		  document.DataForm.Allow_Approval_group.value = grpResultString;
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
					srcObj.title = "delete this product";
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
  </script>

</cfoutput>
