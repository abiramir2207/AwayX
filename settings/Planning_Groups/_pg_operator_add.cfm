<!-----------------------------------------------------------------------------

FILE NAME:		_pg_operator_add.cfm
DESCRIPTION:
CREATED BY:		25-Jan-2010
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

      			Anand Rao	  25-Jan-2010	Created the file
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
<!---
 <cfquery name="qryOprList" datasource="#application.datasource#">
  SELECT DISTINCT(Operator_Group_Level_ID) FROM Operator_Group_Level WHERE Active= 1 AND Deleted = 0
</cfquery> --->

<!--- <cfset qGetTopLevelGroupsList = DistGroupDataManager.getDistributorLevels(1, "1,2,3,23,24,25", "") /> --->

<!--- <cfset qGetTopLevelGroupsList = OprGroupDataManager.getOperatorLevels(1, "#ValueList(qryOprList.Operator_Group_Level_ID)#", "") /> --->


<cfoutput>

<!--- Check to see if there is a query named qryGrpProdPack in the SESSION scope,
      if not create one --->

<!--- Check if the SESSION query exists and create one, if it does not --->
<cfif NOT isDefined("SESSION.qryGrpOperatorPack")>
  <cfset SESSION.qryGrpOperatorPack = QueryNew("GroupLevel_ID,PG_Operator_Category_Code,Operator_ID, Operator_Name, Operator_City, Operator_State, Operator_Location_Type, Inc_Exc, IsPG, Business_Unit_Desc")>
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

<!--- <input type="hidden" name="Product_List" value="">  --->
<input type="hidden" name="Operator_List" value="">
<!--- <input type="hidden" name="ProductListToExcludeFromSelecting" value=""> --->
<input type="hidden" name="PG_Effective_Date_ON" value="#appSettings.get_Setting('PG_Eff_Date_Operator')#">

<cfif isDefined("FORM.GroupLevel_Name") AND GroupLevel_Name NEQ "">
  <input type="hidden" name="GroupLevel_Name" value="#FORM.GroupLevel_Name#" />
<cfelse>
  <input type="hidden" name="GroupLevel_Name" value="" />
</cfif>


<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">#application.returned_customer_setting.Operator_Label_Singular# Planning Group Information</LEGEND>
    <table  border="1" width="782"  cellpadding="5" cellspacing="0"  rules="groups" bordercolor="800000" style="border-radius:5px;">
		<!------ external id ----->
  <table width="768" border="0" cellpadding="5" cellspacing="0" rules="groups" bordercolor="800000">
    <tr>
    <td>
    <font color="red" size="5">*</font> - Required Field
 <table width="100%" border="0" cellpadding="4" cellspacing="4" cols="groups" rules="groups" bordercolor="a85400">
 <tr>
  <td colspan="2" height="6px;"></td>
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
  <tr>
    <td align="right"  width="30%">
      <strong>Type Name<font color="red" size="2">*</font>:</strong>
    </td>
    <td>
    <!---
      1= Product
      2= Customer
      3= Operator
    --->
     <!---  <cfset qGetActivePGTypeByGrpType = CreateObject("component","components.settings.PlanningGroups.PlanningGroupsManager").fnGetActivePGTypesByGrpType("1") />    --->
      <cfset qGetActivePGTypeByGrpType = PGManager.fnGetActivePGTypesByGrpType("3") />
      <select name="selTypeName" id="selTypeName">
        <option value="0">Select a PG Type</option>
        <cfloop query="qGetActivePGTypeByGrpType">
          <option value="#qGetActivePGTypeByGrpType.PG_Type_ID#" <cfif (isDefined("FORM.SelTypeName") AND FORM.SeltypeName EQ qGetActivePGTypeByGrpType.PG_Type_ID)>selected</cfif>>#qGetActivePGTypeByGrpType.PG_Type_Name#</option>
        </cfloop>
      </select>
    </td>
  </tr>
 <cfif appSettings.get_Setting('PG_Eff_Date_Operator') eq '1'>
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
      <input type="checkbox" name="bIncludeInOthers" id="bIncludeInOthers" value="1" <cfif isDefined("FORM.bIncludeInOthers") AND FORM.bIncludeInOthers EQ "1">checked</cfif> >
    </td>
  </tr>
  <tr>
    <td align="right">
      <strong>Master Data Groups Only:</strong>
    </td>
    <td>
      <cfparam name="form.bMasterGroupOnly" default="1">    <!---31191--->
      <input type="checkbox" name="bMasterGroupOnly" id="bMasterGroupOnly" value="1"
            <cfif FORM.bMasterGroupOnly EQ "1">checked</cfif> >
    </td>
  </tr>
  <tr>
    <td align="right">
      <strong>For #appSettings.getPullbackLabel()#:</strong>
    </td>
    <td>
      <input type="checkbox" name="For_Recapture" id="For_Recapture" value="1" <cfif isDefined("FORM.For_Recapture") AND  FORM.For_Recapture EQ "1">checked</cfif>>
    </td>
  </tr>

<!---   <tr id="RadioEnable" <cfif isBusinessSegEnabledForOperator AND(isdefined("form.business_segment") AND (#form.business_segment# EQ 0 OR #form.business_segment# EQ ""))>style="display:none;"</cfif>> --->

  <cfscript>
    // determine if operator groups is feasible
    enable_operator_groups = true;

    if (businessSegManager.isEnabled()) {
        enable_operator_groups = isBusinessSegEnabledForOperator ? true: false;
    }

    // determine which tr section is visible
    if (enable_operator_groups) {
        radio_enable_css  = "";
        radio_disable_css = "style='display:none'";
    }
    else {
        radio_enable_css  = "style='display:none'";
        radio_disable_css = "";
    }
  </cfscript>

  <tr id="RadioEnable" #radio_enable_css#>
    <td align="right"> <strong>Groups/#application.returned_customer_setting.Operator_Label_Plural#:</strong></td>
    <td><input type="radio" name="rdoIncExc" value="1"<cfif isdefined("FORM.rdoIncExc") AND FORM.rdoIncExc EQ 1>CHECKED</cfif>> Include <input type="radio" name="rdoIncExc" value="0" <cfif isdefined("FORM.rdoIncExc") AND FORM.rdoIncExc EQ 0>CHECKED</cfif>> Exclude </td>
  </tr>

  <tr id="RadioDisable" #radio_disable_css#>
    <td align="right"> <strong>Groups/#application.returned_customer_setting.Operator_Label_Plural#:</strong></td>
    <td><input type="radio" name="rdoIncExc" value="1"<cfif (isDefined("FORM.rdoIncExc") AND FORM.rdoIncExc EQ 1)> CHECKED</cfif> disabled> Include <input type="radio" name="rdoIncExc" value="0" <cfif (isDefined("FORM.rdoIncExc") AND FORM.rdoIncExc EQ 0)> CHECKED</cfif>  disabled> Exclude </td>
  </tr>



  <tr>
    <td align="right" width="30%" valign="top">  <!--- class="Orangline"  --->
          <strong>Search #application.returned_customer_setting.Operator_Label_Plural#:</strong>
        </td>
        <td>
        <cfif isDefined("application.returned_customer_setting.group_deals") AND application.returned_customer_setting.group_deals EQ 1>
        <cfset qGetTopLevelGroups = PGManager.fnGetOprPGByTypeID() />
		<cfset qGetSystemPGTypes = PGManager.fnGetSystemPGTypes("3") />
		<cfset lstSystemPGTypes = ValueList(qGetSystemPGTypes.PG_Type_ID) />
      	  <cfset addGroupLabel = "add groups" />

          <!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
              31191 - added logic to update options in Search Operators dropdown
                      based on "include in other pg" & "master groups only"
          ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
          <cfset oprt = structNew()>
          <cfset oprt.blank = "<option value=''>Select Group...</option>">
          <cfset oprt.all = oprt.blank>
          <cfset oprt.master = oprt.blank>
          <cfset oprt.system = oprt.blank>
          <cfset oprt.masterSystem = oprt.blank>

          <!--- Save options for master groups into oprt.master,
                Save options for master group & system pg into oprt.masterSystem
                Save options for all into oprt.all
                These variables will be converted into js variables
                so they can be used dynamically in jQuery--->
          <cfloop query="qGetTopLevelGroups">
            <cfset oprt.option = "<option value='#qGetTopLevelGroups.Operator_Group_Level_ID#'>#qGetTopLevelGroups.Group_Level_Desc#</option>">

            <!--- master group indicator --->
            <cfif qGetTopLevelGroups.Is_PG eq 0>
              <cfset oprt.master = oprt.master & oprt.option>
              <cfset oprt.masterSystem = oprt.masterSystem & oprt.option>
            </cfif>

            <!--- system planning group indicator --->
            <cfif ListFind(lstSystemPGTypes, qGetTopLevelGroups.Operator_Group_Level_ID)>
              <cfset oprt.system = oprt.system & oprt.option>
              <!---<cfset oprt.master = oprt.master & oprt.option>Drachala D32628 Segment Planning Groups Unavailable REMOVED IT AGAIN FOR LABEL 37056--->
              <!--- if this option is not master add it to the mastersystem list --->
              <cfif qGetTopLevelGroups.Is_PG neq 0>
                <cfset oprt.masterSystem = oprt.masterSystem & oprt.option>
              </cfif>
            </cfif>

            <cfset oprt.all = oprt.all & oprt.option>
          </cfloop>

          <div id="WithPG">
    				<select name="GroupLevel1" id="GroupLevel1">
              <!--- 31191 - populate options dynamically by jQuery in \settings\Planning_Groups\index.cfm --->
    				</select>
          </div>

<cfset extraParameter = " onClick=""javascript:showSearchWindow('/Search_Screens/OperatorGroup_Search.cfm?IncludeIOPGFlag=1&oprRefresh=1&groupLevelId=', 'Allow_Operator_Group',document.DataForm);return false;""" />

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
      <cfset addOperatorLabel = "add " & application.returned_customer_setting.Operator_Label_Plural  />

  		<CF_smallLink
  			title = "#addOperatorLabel#"
  			url = "##"
  			parameters = "onClick=""javascript:showOperatorSearchWindow();return false;"""
  		><!--- return showProductSearchWindow --->
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
         <span id="title_2" onclick="switchlayer(2,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" style="color:00773c;cursor:pointer">
          <span  title="Click here to toggle the view">
			      Include List
          </span>
         </span>
        </b>
       </font>
     </legend>
    <div id="lyrgroup_2" style="display:none; visibility:inherit; z-index:5; margin-left:5; margin-right:5; margin-top:5; margin-bottom:8;">

      <div id="masterContainer">

      <!--- Contents go here start--->

      <cfif Len(FORM.Operator_List) GT 0 >
        <cfset qOperatorData = PGManager.fnGetOperatorData(FORM.Operator_List) />
      </cfif>

		<cfset OperatorGroupAttributeManager = CreateObject("component", "components.operator.group.OperatorGroupAttributeManager").init() />

     <cfif Len(FORM.Allow_Operator_Group) GT 0>
        <cfset qGetApprovalGroups = OperatorGroupAttributeManager.getOperatorGroupAttributesMultiple(groupLevelTypeId = FORM.Allow_Operator_Group, bActive = 1)>
      </cfif>
 <cfset FORM.Allow_Operator_Group = "" />
  <cfif (isDefined("qGetApprovalGroups") AND	qGetApprovalGroups.RecordCount GTE 1)>
      <cfset sesCount = SESSION.qryGrpOperatorPack.RecordCount  />
      <cfset rCount = SESSION.qryGrpOperatorPack.RecordCount + 1  />
      <cfset iCounter = 1 />
      <cfloop query="qGetApprovalGroups">
        <cfset recExists = 0 />
        <cfloop query="SESSION.qryGrpOperatorPack">
          <cfif SESSION.qryGrpOperatorPack.Operator_ID EQ qGetApprovalGroups.PG_Operator_Category_ID AND SESSION.qryGrpOperatorPack.Inc_Exc EQ frmRdoIncExcVal>
            <cfset recExists = 1 />
            <cfbreak />
          </cfif>
        </cfloop>
        <cfif recExists EQ 0>
          <cfset bIsPG = 0 />
          <cfloop query="qGetTopLevelGroups">
            <cfif qGetTopLevelGroups.Group_Level_Desc EQ FORM.GroupLevel_Name AND qGetTopLevelGroups.Operator_Group_Level_ID EQ FORM.GroupLevel>
              <cfset bIsPG = qGetTopLevelGroups.Is_PG />
            </cfif>
          </cfloop>
          <cfset newRow =  QueryAddRow(SESSION.qryGrpOperatorPack,1) /><!--- BSA_Operator_ID, Operator_Name, Operator_City, Operator_State, Operator_Location_Type, Inc_Exc, IsPG --->
              <cfset temp = QuerySetCell(SESSION.qryGrpOperatorPack, "GroupLevel_ID", FORM.GroupLevel, SESSION.qryGrpOperatorPack.recordCount) />
							<cfset temp = QuerySetCell(SESSION.qryGrpOperatorPack, "PG_Operator_Category_Code", qGetApprovalGroups.PG_Operator_Category_Code, SESSION.qryGrpOperatorPack.recordCount) />
              <cfset temp = QuerySetCell(SESSION.qryGrpOperatorPack, "Operator_ID", qGetApprovalGroups.PG_Operator_Category_ID, SESSION.qryGrpOperatorPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpOperatorPack, "Operator_Name", qGetApprovalGroups.PG_Operator_Category_Name, SESSION.qryGrpOperatorPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpOperatorPack, "Operator_City", "", SESSION.qryGrpOperatorPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpOperatorPack, "Operator_State", "", SESSION.qryGrpOperatorPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpOperatorPack, "Operator_Location_Type", "N/A", SESSION.qryGrpOperatorPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpOperatorPack, "Inc_Exc", frmRdoIncExcVal, SESSION.qryGrpOperatorPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpOperatorPack, "IsPG", 1, SESSION.qryGrpOperatorPack.recordCount) />
							<cfset temp = QuerySetCell(SESSION.qryGrpOperatorPack, "Business_Unit_Desc", "", SESSION.qryGrpOperatorPack.recordCount) />
          <cfset iCounter  = iCounter + 1 />
        </cfif>
      </cfloop>
     </cfif>

       <cfif (isDefined("qOperatorData") AND qOperatorData.RecordCount GT 0)>
        <cfset sesCount = SESSION.qryGrpOperatorPack.RecordCount  />
        <cfset rCount = SESSION.qryGrpOperatorPack.RecordCount + 1  />
        <cfset iCounter = 1 />
        <cfloop query="qOperatorData">
        <cfset recExists = 0 />
				<cfset BusinessSegment = ""/>
				<cfif (isDefined("qOperatorData.Business_Unit_Desc") AND qOperatorData.Business_Unit_Desc NEQ "")>
					<cfset BusinessSegment = qOperatorData.Business_Unit_Desc />
				</cfif>
          <cfloop query="SESSION.qryGrpOperatorPack">
            <cfif SESSION.qryGrpOperatorPack.Operator_ID EQ qOperatorData.BSA_Operator_ID AND SESSION.qryGrpOperatorPack.Inc_Exc EQ frmRdoIncExcVal>
              <cfset recExists = 1 />
              <cfbreak />
            </cfif>
            </cfloop>
            <cfif recExists EQ 0>
              <cfset newRow =  QueryAddRow(SESSION.qryGrpOperatorPack,1) /><!--- BSA_Operator_ID, Operator_Name, Operator_City, Operator_State, Operator_Location_Type, Inc_Exc, IsPG --->
              <cfset temp = QuerySetCell(SESSION.qryGrpOperatorPack, "GroupLevel_ID", 0, SESSION.qryGrpOperatorPack.recordCount) />
							<cfset temp = QuerySetCell(SESSION.qryGrpOperatorPack, "PG_Operator_Category_Code", "", SESSION.qryGrpOperatorPack.recordCount) />
              <cfset temp = QuerySetCell(SESSION.qryGrpOperatorPack, "Operator_ID", qOperatorData.BSA_Operator_ID, SESSION.qryGrpOperatorPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpOperatorPack, "Operator_Name", qOperatorData.Operator_Name, SESSION.qryGrpOperatorPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpOperatorPack, "Operator_City", qOperatorData.Operator_City, SESSION.qryGrpOperatorPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpOperatorPack, "Operator_State", qOperatorData.Operator_State, SESSION.qryGrpOperatorPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpOperatorPack, "Operator_Location_Type", qOperatorData.Operator_Location_Type, SESSION.qryGrpOperatorPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpOperatorPack, "Inc_Exc", frmRdoIncExcVal, SESSION.qryGrpOperatorPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpOperatorPack, "IsPG", 0, SESSION.qryGrpOperatorPack.recordCount) />
							<cfset temp = QuerySetCell(SESSION.qryGrpOperatorPack, "Business_Unit_Desc", BusinessSegment, SESSION.qryGrpOperatorPack.recordCount) />
              <cfset iCounter  = iCounter + 1 />
            </cfif>
        </cfloop>
      </cfif>

			<table cellpadding="2" cellspacing="1" width="100%" border="1" bordercolor="979797">
      	<tr>
          <td id="header" WIDTH="3%" rowspan="1">
  			    <NOBR>
  				  <img name="IMG_Delete_Scissor_Include"  bDelete="true" sMessage="delete all records in this page" src="/images/scissor.gif" title="delete all records in this page" border="0" onclick="if(confirm('Please confirm that you would like to DELETE all checked products!')){fnDeleteAllList('#valueList(SESSION.qryGrpOperatorPack.Operator_ID)#','tr_operatorAddInc_','1');};" style="cursor:pointer;">
  			    </NOBR>
  		    </td>
      		<td width="20%" rowspan="1">
      			<b>Group/#application.returned_customer_setting.Operator_Label_Singular# Description<!--- Category ---></b>
      		</td>
					<td width="20%" rowspan="1">
      			<b>Group/#application.returned_customer_setting.Operator_Label_Singular# Number</b>
      		</td>
      		<td width="20%" rowspan="1">
      		  <b>Group/#application.returned_customer_setting.Operator_Label_Singular# Name </b>
      		</td>
					<cfif isBusinessSegEnabledForOperator>
			   		<td width="20%" rowspan="1">
			   			<b>#appsettings.Business_Segment_Label#</b>&nbsp;
			   		</td>
					</cfif>
         </tr>

    <cfif (isDefined("SESSION.qryGrpOperatorPack") AND SESSION.qryGrpOperatorPack.RecordCount GTE 1 AND isDefined("SESSION.qryGrpOperatorPack.Operator_Name"))>
       <cfloop query="SESSION.qryGrpOperatorPack">
       <cfif SESSION.qryGrpOperatorPack.Operator_Name NEQ ""  AND SESSION.qryGrpOperatorPack.Inc_Exc EQ 1>
					<cfset recStriked = 0>
					<cfloop index = "delItem" list = "#FORM.DelMarkedInInclude#"  delimiters = ",">
						<cfif delItem EQ SESSION.qryGrpOperatorPack.Operator_ID>
							<cfset 	recStriked = 1 />
						</cfif>
					</cfloop>
					<cfif recStriked EQ 1>

        <tr id="tr_operatorAddInc_#SESSION.qryGrpOperatorPack.Operator_ID#"  style="text-decoration:line-through;background-color:bbbbbb">
          <td width="15">
  				   <img bDelete="false" name="IMG_Delete_Scissor_Include"  src="/images/undo.gif"  title="click here to undelete this product" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpOperatorPack.Operator_ID#', 'tr_operatorAddInc_#SESSION.qryGrpOperatorPack.Operator_ID#','1');" style="cursor:pointer;">
  			  </td>
             <td>#application.returned_customer_setting.Operator_Label_Singular#</td>
              <td><cfif SESSION.qryGrpOperatorPack.PG_Operator_Category_Code EQ "">#SESSION.qryGrpOperatorPack.Operator_ID#<cfelse>#SESSION.qryGrpOperatorPack.PG_Operator_Category_Code#</cfif></td>
						 	<td>#SESSION.qryGrpOperatorPack.Operator_Name#</td>
							<cfif isBusinessSegEnabledForOperator>
					   		<td>#SESSION.qryGrpOperatorPack.Business_Unit_Desc#&nbsp;</td>
							</cfif>
	        </tr>
       <cfelse>
         <tr id="tr_operatorAddInc_#SESSION.qryGrpOperatorPack.Operator_ID#" bgcolor="eeeeee">
          <td width="15">
  				   <img bDelete="true" name="IMG_Delete_Scissor_Include"  src="/images/scissor.gif"  title="click here to delete this product" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpOperatorPack.Operator_ID#', 'tr_operatorAddInc_#SESSION.qryGrpOperatorPack.Operator_ID#','1');" style="cursor:pointer;">
  			  </td>
              <td>
                <cfif SESSION.qryGrpOperatorPack.IsPG EQ 0>
                  #application.returned_customer_setting.Operator_Label_Singular#
                <cfelse>
                  Planning Group
                </cfif>
              </td>
							<td><cfif SESSION.qryGrpOperatorPack.PG_Operator_Category_Code EQ "">#SESSION.qryGrpOperatorPack.Operator_ID#<cfelse>#SESSION.qryGrpOperatorPack.PG_Operator_Category_Code#</cfif></td>
              <td>#SESSION.qryGrpOperatorPack.Operator_Name#</td>
							<cfif isBusinessSegEnabledForOperator>
					   		<td>#SESSION.qryGrpOperatorPack.Business_Unit_Desc#&nbsp;</td>
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
         <span id="title_3" onclick="switchlayer(3,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" style="color:00773c;cursor:pointer">
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
  				  <img  name="IMG_Delete_Scissor_Exclude" bDelete="true" sMessage="delete all records in this page" src="/images/scissor.gif" title="delete all records in this page" border="0" onclick="if(confirm('Please confirm that you would like to DELETE all checked products!')){fnDeleteAllList('#valueList(SESSION.qryGrpOperatorPack.Operator_ID)#','tr_prodAddExc_','0');};" style="cursor:pointer;">
  			    </NOBR>
  		    </td>
      		<td width="20%" rowspan="1">
      		  <b>Group/#application.returned_customer_setting.Operator_Label_Singular# Description<!--- Category ---></b>
      		</td>
      		<td width="20%" rowspan="1">
      		 	<b>Group/#application.returned_customer_setting.Operator_Label_Singular# Number</b>
      		</td>
					<td width="20%" rowspan="1">
      		 	<b>Group/#application.returned_customer_setting.Operator_Label_Singular# Name </b>
      		</td>
					<cfif isBusinessSegEnabledForOperator>
			   		<td width="20%" rowspan="1">
			   			<b>#appsettings.Business_Segment_Label#</b>&nbsp;
			   		</td>
					</cfif>
			  </tr>
          <cfif (isDefined("SESSION.qryGrpOperatorPack") AND SESSION.qryGrpOperatorPack.RecordCount GTE 1 AND isDefined("SESSION.qryGrpOperatorPack.Operator_Name"))>
           <cfloop query="SESSION.qryGrpOperatorPack">
          <cfif SESSION.qryGrpOperatorPack.Operator_Name NEQ "" AND SESSION.qryGrpOperatorPack.Inc_Exc EQ 0>
					<cfset recStriked = 0>
					<cfloop index = "delItem" list = "#FORM.DelMarkedInExclude#"  delimiters = ",">
						<cfif delItem EQ SESSION.qryGrpOperatorPack.Operator_ID>
							<cfset 	recStriked = 1 />
						</cfif>
					</cfloop>
					<cfif recStriked EQ 1>

          <tr id="tr_prodAddExc_#SESSION.qryGrpOperatorPack.Operator_ID#" style="text-decoration:line-through;background-color:bbbbbb">
          <td width="15">
            <img bDelete="false" name="IMG_Delete_Scissor_Exclude" src="/images/undo.gif" title="click here to undelete this product" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpOperatorPack.Operator_ID#', 'tr_prodAddExc_#SESSION.qryGrpOperatorPack.Operator_ID#','0');" style="cursor:pointer;">
  			  </td>
          <td>
                <cfif SESSION.qryGrpOperatorPack.IsPG EQ 0>
                  #application.returned_customer_setting.Operator_Label_Singular#
                <cfelse>
                  Planning Group
                </cfif> </td>
							<td><cfif SESSION.qryGrpOperatorPack.PG_Operator_Category_Code EQ "">#SESSION.qryGrpOperatorPack.Operator_ID#<cfelse>#SESSION.qryGrpOperatorPack.PG_Operator_Category_Code#</cfif></td>
              <td>#SESSION.qryGrpOperatorPack.Operator_Name#</td>
							<cfif isBusinessSegEnabledForOperator>
					   		<td>#SESSION.qryGrpOperatorPack.Business_Unit_Desc#&nbsp;</td>
							</cfif>
        </tr>
        <cfelse>
            <tr id="tr_prodAddExc_#SESSION.qryGrpOperatorPack.Operator_ID#" bgcolor="eeeeee">
          <td width="15">
           	  <img bDelete="true" name="IMG_Delete_Scissor_Exclude"  src="/images/scissor.gif"  title="click here to delete this product" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpOperatorPack.Operator_ID#', 'tr_prodAddExc_#SESSION.qryGrpOperatorPack.Operator_ID#','0');" style="cursor:pointer;">
  			  </td>
					<td>
                <cfif SESSION.qryGrpOperatorPack.IsPG EQ 0>
                  #application.returned_customer_setting.Operator_Label_Singular#
                <cfelse>
                  Planning Group
                </cfif>
              </td>
							<td><cfif SESSION.qryGrpOperatorPack.PG_Operator_Category_Code EQ "">#SESSION.qryGrpOperatorPack.Operator_ID#<cfelse>#SESSION.qryGrpOperatorPack.PG_Operator_Category_Code#</cfif></td>
              <td>#SESSION.qryGrpOperatorPack.Operator_Name#</td>
							<cfif isBusinessSegEnabledForOperator>
					   		<td>#SESSION.qryGrpOperatorPack.Business_Unit_Desc#&nbsp;</td>
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
  			parameters = "onClick=""javascript:saveAddOPG('1');return false;"""
  		>
      &nbsp;&nbsp;&nbsp;&nbsp;
      <CF_smallLink
  			title = "Save & Quit"
  			url = "##"
  			parameters = "onClick=""javascript:saveAddOPG('2');return false;"""
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
  <input type="hidden" name="Allow_Operator_Group" value="#FORM.Allow_Operator_Group#">
	<input type="hidden" name="bSubmit" value="0" />
  <input type="hidden" name="SelectSingleSearchResultOnly" value="0" />

  <cfif FORM.display EQ "add">
      <input type="hidden" name="operatorRefresh" value = "0" />
  </cfif>
	<script>
	///////////////////////////////////   Update Component //////////////////////////////////////////

  function deleteThisProduct(FieldNameRe, prodID, bgCol, GroupID)//,realGroupLevelId
	{
			var srcObj = event.srcElement;
			var trObj = getParentObject(srcObj, "tr");
			var trIndex = trObj.rowIndex;
			var FINALITEMLIST = document.DataForm.Operator_List.value;
      var FINALGROUPLIST = document.DataForm.Allow_Operator_Group.value;
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
		 	document.DataForm.Operator_List.value = resultString;
		  document.DataForm.Allow_Operator_Group.value = grpResultString;
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
