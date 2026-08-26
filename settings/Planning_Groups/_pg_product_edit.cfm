<!-----------------------------------------------------------------------------

FILE NAME:		_pg_product_edit.cfm
DESCRIPTION:	This is a file that will allow the user to edit the Product PG
CREATED BY:		10-Aug-2010
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

      			Anand Rao	  12-Nov-2010	Created the file
------------------------------------------------------------------------------>
<cfset qryGetPGProductCategoryByID = PGManager.fnGetPGProductCategoryByID(FORM.PGProductCategoryID) />

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
<cfset lsPGmembersList = "" />

<cfoutput>
  <cfif qryGetPGProductCategoryByID.Name_First NEQ "">
    <table bgcolor="White" style="border-color:Orange;border-style:solid;" cellpadding="3" cellspacing="0"  align="center" width="600">
      <tr>
        <td>
          <cfoutput>
    	      <font size="2"><b>The settings were last updated on #dateformat(qryGetPGProductCategoryByID.Updated_Date, 'mm/dd/yyyy')# #timeformat(qryGetPGProductCategoryByID.Updated_Date, 'hh:mm:ss TT')# by #qryGetPGProductCategoryByID.Name_First# #qryGetPGProductCategoryByID.Name_Last#</b></font>
          </cfoutput>
        </td>
      </tr>
    </table>
 </cfif>
<!--- Check to see if there is a query named qryGrpProdPack in the SESSION scope,
      if not create one --->

<cfif NOT isDefined("SESSION.qryGrpProdPack")>
  <cfset SESSION.qryGrpProdPack = QueryNew("GroupLevel_ID, GroupLevel_Name, GroupLevel_Number, Group_Product_ID, Item_No, Description, Inc_Exc, IsPG, Business_Unit_Desc")>
  <!--- <cfset SESSION.qryGrpProdPack = qryGrpProdPack /> --->
</cfif>
<cfif isDefined("FORM.rdoIncExc")>
  <cfset frmRdoIncExcVal = FORM.rdoIncExc />
  <cfset temp = StructDelete(FORM,"rdoIncExc" ) />
<cfelse>
  <cfset frmRdoIncExcVal = 1 />
</cfif>


<input type="hidden" visible="false" name="ExistingProductList" value="">
<input type="hidden" name="Product_List" value="">
<input type="hidden" name="ProductListToExcludeFromSelecting" value="">
<input type="hidden" name="PG_Effective_Date_ON" value="#appSettings.get_Setting('PG_Eff_Date_Product')#">
<input type="hidden" name="PG_Effective_Date_Upload_Download" value="#appSettings.get_Setting('PG_Effective_Date_Upload_Download')#">


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
 <table width="100%" border="0" cellpadding="4" cellspacing="4" cols="groups" rules="groups" bordercolor="a85400">
 <tr>
  <td colspan="2" height="6px;"></td>
 </tr>
 <cfif appSettings.get_Setting('PG_Eff_Date_Product') eq '1' OR appSettings.get_Setting('PG_Eff_Date_Distributor') eq '1' OR appSettings.get_Setting('PG_Eff_Date_Operator') eq '1'>
  <tr>
    <td align="right"  width="30%">PG Number:</td>
    <td>#qryGetPGProductCategoryByID.PG_Number_Sequence#</td>
  </tr>
</cfif>
  <tr>
    <td align="right"  width="30%">
      <strong>Planning Group Code: </strong>
    </td>
    <td>
      <input type="text" name="planningGroupCode" size="8" maxlength="20" <cfif (isDefined("FORM.planningGroupCode") AND FORM.planningGroupCode NEQ "")>value="#FORM.planningGroupCode#"<cfelse>value="#qryGetPGProductCategoryByID.PG_Product_Category_Code#"</cfif>>
    </td>
  </tr>
  <tr>
    <td align="right"  width="30%">
      <strong>Planning Group Name<font color="red" size="2">*</font>: </strong>
    </td>
    <td>
      <input type="text" name="planningGroupName" size="60" maxlength="50" <cfif (isDefined("FORM.planningGroupName") AND FORM.planningGroupName NEQ "")>value="#FORM.planningGroupName#"<cfelse>value="#qryGetPGProductCategoryByID.PG_Product_Category_Name#"</cfif>>
    </td>
  </tr>

  <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START--->
  <cfif isBusinessSegEnabledForProduct>
   <tr>
    <td align="right"  width="30%">
      <strong>#appSettings.getbusiness_segment_label()#<font color="red" size="2">*</font>: </strong>
    </td>
    <td>
      <input type="text" name="Business_Unit_Desc" size="25" value="#qryGetPGProductCategoryByID.Business_Unit_Desc#" readonly>
	  <!--- Dev Note: Drachala; D27886: cannot convert the value undefined to a boolean START--->
	  	<!--- Those event errors are generating because #qryGetPGProductCategoryByID.Business_Segment_Id# is NULL--->
      <cfif len(qryGetPGProductCategoryByID.Business_Segment_Id) GT 0>
	  	<cfset bsid = #qryGetPGProductCategoryByID.Business_Segment_Id#>
	  <cfelse>
	    <cfset bsid = 0>
	  </cfif>
	  <!--- Dev Note: Drachala; D27886: cannot convert the value undefined to a boolean END--->
   </td>
    <cfelse>
  <input type="hidden" name="business_segment" value="0">
  <cfset bsid = 0/>
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
     <!---  <cfset qGetActivePGTypeByGrpType = CreateObject("component","components.settings.PlanningGroups.PlanningGroupsManager").fnGetActivePGTypesByGrpType("1") />    --->
      <cfset qGetActivePGTypeByGrpType = PGManager.fnGetActivePGTypesByGrpType("1") />
      <select name="selTypeName" id="selTypeName">
        <option value="0">Select a PG Type</option>
        <cfloop query="qGetActivePGTypeByGrpType">
          <option value="#qGetActivePGTypeByGrpType.PG_Type_ID#" <cfif (isDefined("FORM.SelTypeName") AND FORM.SeltypeName EQ qGetActivePGTypeByGrpType.PG_Type_ID)>selected<cfelseif qryGetPGProductCategoryByID.PG_Type_ID EQ qGetActivePGTypeByGrpType.PG_Type_ID>selected</cfif>>#qGetActivePGTypeByGrpType.PG_Type_Name#</option>
        </cfloop>
      </select>
    </td>
  </tr>
<cfif ((appSettings.get_Setting('PG_Eff_Date_Product') EQ '1') AND (appSettings.get_Setting('PG_Effective_Date_Upload_Download') NEQ '1'))>
  <tr>
    <td align="right"  width="30%">
      <strong>Effective Date<font color="red" size="2">*</font>: <img src="/images/help_small.gif" title="The effective date is not a functional value in  FORGE and does not affect dates applied within programs, claims or reporting.  It is purely an attribute to facilitate communication with other systems."/></strong>
    </td>
 <td>
      Start Date <input type="text" name="PG_Effective_Start_Date" size="15" maxlength="10" <cfif (isDefined("FORM.PG_Effective_Start_Date") AND FORM.PG_Effective_Start_Date NEQ "")>value="#FORM.PG_Effective_Start_Date#"<cfelse>value="#dateformat(qryGetPGProductCategoryByID.PG_Effective_Start_Date,'MM/DD/YYYY')#"</cfif>>
	  End Date <input type="text" name="PG_Effective_End_Date" size="15" maxlength="10" <cfif (isDefined("FORM.PG_Effective_End_Date") AND FORM.PG_Effective_End_Date NEQ "")>value="#FORM.PG_Effective_End_Date#"<cfelse>value="#dateformat(qryGetPGProductCategoryByID.PG_Effective_End_Date,'MM/DD/YYYY')#"</cfif>>
   </td>
 </tr>
<cfelse>
	<input type="hidden" name="PG_Effective_Start_Date" <cfif (isDefined("FORM.PG_Effective_Start_Date") AND FORM.PG_Effective_Start_Date NEQ "")>value="#FORM.PG_Effective_Start_Date#"<cfelse>value="#dateformat(qryGetPGProductCategoryByID.PG_Effective_Start_Date,'MM/DD/YYYY')#"</cfif> />
	<input type="hidden" name="PG_Effective_End_Date" <cfif (isDefined("FORM.PG_Effective_End_Date") AND FORM.PG_Effective_End_Date NEQ "")>value="#FORM.PG_Effective_End_Date#"<cfelse>value="#dateformat(qryGetPGProductCategoryByID.PG_Effective_End_Date,'MM/DD/YYYY')#"</cfif> />
 
</cfif>
<!--- 34007 --->
  <tr>
			<cfinclude template="removeMembers.cfm">
  		<cfparam name="FORM.bCaptureRemoves" default="#qryGetPGProductCategoryByID.Capture_Removes#">
  		<td><input type="checkbox" name="bCaptureRemoves" <cfif FORM.bCaptureRemoves EQ "1">checked</cfif> value="1"></td>
  </tr>
<tr style="display:none">
    <td align="right">
      <strong>Include in other PG:</strong>
    </td>
    <td>
      <input type="checkbox" name="bIncludeInOthers" value="1" id="bIncludeInOthers" <cfif (isDefined("FORM.bIncludeInOthers") AND FORM.bIncludeInOthers EQ "1")>checked<cfelseif qryGetPGProductCategoryByID.Include_In_Other_PG EQ 1>checked</cfif>>
    </td>
  </tr>
  <tr>
    <td align="right">
      <strong>Include in other PG:</strong>
    </td>
    <td>
      <input type="checkbox" name="dummybIncludeInOthers" value="1" id="dummybIncludeInOthers" <cfif (isDefined("FORM.bIncludeInOthers") AND FORM.bIncludeInOthers EQ "1")>checked<cfelseif qryGetPGProductCategoryByID.Include_In_Other_PG EQ 1>checked</cfif> disabled>
    </td>
  </tr>

  <tr>
    <td align="right">
      <strong>Master Data Groups Only:</strong>
    </td>
    <td>
      <!--- <cfparam name="form.bMasterGroupOnly" default="1"> --->
      <input type="checkbox" name="bMasterGroupOnly" id="bMasterGroupOnly" value="1" <cfif qryGetPGProductCategoryByID.Is_master_group eq 1>checked</cfif>>
    </td>
  </tr>

 <tr>
  <td colspan="100%">
 <fieldset id="border_20" style="border-width:0; border-color:; border-style:solid; width:680">
     <legend>
        <img id="image_20" src="/images/plus2.gif" onclick="switchlayer(20,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" border="0" title="" style="cursor:pointer">

       <font face="Arial">
	        <b style="font-size:9pt">
		         <span id="title_20" onclick="switchlayer(20,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" style="cursor:pointer;color:00773c;">
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

	<cfstoredproc procedure="Get_Product_Group_Info_For_PG" datasource="#application.datasource#">
	  	<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@PG_Product_Category_ID" value = "#qryGetPGProductCategoryByID.PG_Product_Category_ID#" null="no">
	  	<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Keyword" value="#vSearchKeyword#" null="no">
	  	<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@OrderByField" value="#vOrderByField#" null="no">
	  	<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@OrderBy" value="#Form.OrderBy#" null="no">
	 	<cfprocresult name="qryPGProductCategoryDefinitionByID">
	</cfstoredproc>


		<table width="750" cellpadding="2" border="0"><tr><td align="left">
		 <input type="text" name="memberSearchKW" id="memberSearchKW" value="#vSearchKeyword#" >

		 <CF_smallLink
    			title = "Search"
    			url = "##"
    			parameters = "onClick=""javascript:getSearchURL('1');return false;"""
				mouseovernotes = "Searches the Group/#application.returned_customer_setting.Item_Label# and Account fields"
    		>
		 <CF_smallLink
    			title = "Clear"
    			url = "##"
    			parameters = "onClick=""javascript:getSearchURL('2');return false;"""
				mouseovernotes = "Clears the Group/#application.returned_customer_setting.Item_Label# search text and search results"
    		>
		<cfif ((appSettings.get_Setting('PG_Eff_Date_Product') eq '1') AND (appSettings.get_Setting('PG_Effective_Date_Upload_Download') EQ '1'))>						
			<CF_smallLink
	   				title = "Download"
	    			url = "##"
					parameters = "onClick=""javascript:window.open('PG_Download_Eff_Dates.cfm?fileParam=Download&PGType=1&PG_Category_ID=#qryGetPGProductCategoryByID.PG_Product_Category_ID#&Keyword=#vSearchKeyword#&OrderByField=#vOrderByField#&OrderBy=#Form.OrderBy#','Download','450','200');return false;"""
					mouseovernotes = "Download the top level members with the Effective Start Date and End Dates"
			    			>
			<CF_smallLink
	  				title = "Upload"
	   			url = "##"
				parameters = "onClick=""javascript:window.open('PG_Upload_Eff_Dates.cfm?fileParam=Upload&PGType=1&PG_Category_ID=#qryGetPGProductCategoryByID.PG_Product_Category_ID#','Upload','width=600,height=200,location=1,status=1,scrollbars=1,resizable=1');return false;"""
				mouseovernotes = "Upload the top level members with the Effective Start Date and end Dates"
	  			>	
		</cfif>
		</td></tr></table>
	<cfif qryPGProductCategoryDefinitionByID.RecordCount GTE 12>
		 <div id="masterContainer" style="position:relative;overflow:scroll;height:330px;">
	</cfif>
	<table bgcolor="##ffffce" border="1" borderColor="800040" cellpadding="1" cellspacing="1" width="770"><!--- bgcolor="b0ffb0"  --->
		  <tr bgcolor="##cc9999">
			<td id="header" WIDTH="5%" rowspan="1"><img bDelete="true" name="IMG_Delete_Scissor_Existing"  sMessage="delete all #application.returned_customer_setting.distributor_label_plural# in this page" src="/images/scissor.gif" title="delete all #application.returned_customer_setting.distributor_label_plural# in this page" border="0" onclick="if(confirm('Please confirm that you would like to DELETE all checked products!')){fnDeleteAllList('#valueList(qryPGProductCategoryDefinitionByID.Product_Group_ID)#','tr_prodExisting_','2');};" style="cursor:pointer;"></td>
			<td width="23%" style="font-weight:bold;font-size:8pt"><a href="index.cfm?type=product&subtype=edit&ID=#qryGetPGProductCategoryByID.PG_Product_Category_ID#&OrderByField=Group_Desc&OrderBy=#newOrderBy#&EEMExpanded=true&memSearchKeyword=#memSearchKeyword#">Group/#application.returned_customer_setting.Item_Label# Description<cfif vOrderByField EQ "Group_Desc" ><cfif FORM.OrderBy EQ "ASC"><img src="#ASC_IMG#"/><cfelse><img src="#DESC_IMG#"/></cfif> </cfif></td>
			<td width="20%" style="font-weight:bold;font-size:8pt"><a href="index.cfm?type=product&subtype=edit&ID=#qryGetPGProductCategoryByID.PG_Product_Category_ID#&OrderByField=Group_Number&OrderBy=#newOrderBy#&EEMExpanded=true&memSearchKeyword=#memSearchKeyword#">Group/#application.returned_customer_setting.Item_Label# Number<cfif vOrderByField EQ "Group_Number" ><cfif FORM.OrderBy EQ "ASC"><img src="#ASC_IMG#"/><cfelse><img src="#DESC_IMG#"/></cfif> </cfif></td>
			<td width="20%" style="font-weight:bold;font-size:8pt"><a href="index.cfm?type=product&subtype=edit&ID=#qryGetPGProductCategoryByID.PG_Product_Category_ID#&OrderByField=Group_Name&OrderBy=#newOrderBy#&EEMExpanded=true&memSearchKeyword=#memSearchKeyword#">Group/#application.returned_customer_setting.Item_Label# Name<cfif vOrderByField EQ "Group_Name" ><cfif FORM.OrderBy EQ "ASC"><img src="#ASC_IMG#"/><cfelse><img src="#DESC_IMG#"/></cfif> </cfif></td>
		<cfif isBusinessSegEnabledForProduct>
			<td width="20%" style="font-weight:bold;font-size:8pt"><strong>#appsettings.Business_Segment_Label#</strong></td>
		</cfif>
			<td width="15%" style="font-weight:bold;font-size:8pt"><strong>Include/Exclude</strong></td>
			<cfif appSettings.get_Setting('PG_Eff_Date_Product') eq '1'>
						<td width="6%" style="font-weight:bold;font-size:8pt"><strong><nobr>&nbsp;Start Date&nbsp;</nobr></strong></td>
						<td width="6%"style="font-weight:bold;font-size:8pt"><strong><nobr>&nbsp;End Date&nbsp;</strong></nobr></td>
			</cfif>
		 </tr>
	   <cfif qryPGProductCategoryDefinitionByID.RecordCount EQ 0>
         <tr><td colspan="100%">No Members Found!!</td></tr>
      </cfif>
	<cfloop query = "qryPGProductCategoryDefinitionByID">
            <cfif lsPGmembersList EQ "">
              <cfset lsPGmembersList = qryPGProductCategoryDefinitionByID.Product_Group_ID  />
            <cfelse>
              <cfset lsPGmembersList = lsPGmembersList & "," & qryPGProductCategoryDefinitionByID.Product_Group_ID  />
            </cfif>
					<cfset recStriked = 0>
					<cfloop index = "toStrikeItem" list = "#FORM.DelMarkedInExisting#"  delimiters = ",">
						<cfif toStrikeItem EQ qryPGProductCategoryDefinitionByID.Product_Group_ID>
							<cfset 	recStriked = 1 />
						</cfif>
					</cfloop>
			<cfif recStriked EQ 1>
          	<tr id="tr_prodExisting_#qryPGProductCategoryDefinitionByID.Product_Group_ID#" style="text-decoration:line-through;background-color:bbbbbb">
            	<td width="15"><img bDelete="false" name="IMG_Delete_Scissor_Existing"  src="/images/undo.gif"  title="click here to delete this row" border="0" onclick="fnDeleteThisPGMemberRecord('#qryPGProductCategoryDefinitionByID.Product_Group_ID#', 'tr_prodExisting_#qryPGProductCategoryDefinitionByID.Product_Group_ID#','2');" style="cursor:pointer;"></td>
            	<td><cfif qryPGProductCategoryDefinitionByID.Group_Number EQ "">&nbsp;<cfelse>#qryPGProductCategoryDefinitionByID.Group_Number#</cfif> </td>
            	<td>#Trim(qryPGProductCategoryDefinitionByID.Group_Desc)#&nbsp;</td>
				<td>
					<cfif ((qryPGProductCategoryDefinitionByID.Product_Group_Level_ID LT 2000) AND qryPGProductCategoryDefinitionByID.Group_Desc NEQ "Product")>
				  		<a href="##" onclick="NewWindow('/Common_Files/contracts/Groups/group_items.cfm?Group_ID=#qryPGProductCategoryDefinitionByID.Product_Group_ID#&Group_Level_ID=#qryPGProductCategoryDefinitionByID.Product_Group_Level_ID#', 'Group_Items', 800, 600, 'yes', 'yes');">
	 	  					#qryPGProductCategoryDefinitionByID.Group_Name#
	 	  				</a>&nbsp;
					<cfelseif (qryPGProductCategoryDefinitionByID.Product_Group_Level_ID GTE 2000 AND  qryPGProductCategoryDefinitionByID.Group_Desc NEQ "Product")>
						<a href="##" onclick="NewWindow('/settings/Planning_Groups/Product_PG_Info.cfm?ID=#qryPGProductCategoryDefinitionByID.Product_Group_ID#&calledFrom=prodAddEdit', 'Group_Items', 800, 600, 'yes', 'yes');"> #Trim(qryPGProductCategoryDefinitionByID.Group_Name)#</a>&nbsp;
					<cfelse>
						#Trim(qryPGProductCategoryDefinitionByID.Group_Name)#&nbsp;
					</cfif>
				</td>
			<cfif isBusinessSegEnabledForProduct>
				<td>#qryPGProductCategoryDefinitionByID.Business_Unit_Desc#&nbsp;</td>
			</cfif>
            	<td>
            		<nobr>
	              		<input type="radio" name="rdoIncExc_#Replace(qryPGProductCategoryDefinitionByID.Product_Group_ID,'-','_','ALL')#" value="1"
	              		<cfif (isDefined("FORM.rdoIncExc_#Replace(qryPGProductCategoryDefinitionByID.Product_Group_ID,'-','_','ALL')#") AND evaluate("FORM.rdoIncExc_" & Replace(qryPGProductCategoryDefinitionByID.Product_Group_ID,'-','_','ALL')) EQ 1)>checked
	              		<cfelseif (qryPGProductCategoryDefinitionByID.Inclusion_Exclusion)>checked
	              		</cfif>> Include
	                	<input type="radio" name="rdoIncExc_#Replace(qryPGProductCategoryDefinitionByID.Product_Group_ID,'-','_','ALL')#" value="0"
			             <cfif (isDefined("FORM.rdoIncExc_#Replace(qryPGProductCategoryDefinitionByID.Product_Group_ID,'-','_','ALL')#") AND evaluate("FORM.rdoIncExc_" & Replace(qryPGProductCategoryDefinitionByID.Product_Group_ID,'-','_','ALL')) EQ 0)>checked
			              <cfelseif NOT (qryPGProductCategoryDefinitionByID.Inclusion_Exclusion)>checked
			              </cfif>>  Exclude
					</nobr>
            	</td>
				<cfif appSettings.get_Setting('PG_Eff_Date_Product') eq '1'>
					<td>&nbsp;#dateformat(qryPGProductCategoryDefinitionByID.PG_Effective_Start_Date, 'mm/dd/yyyy')#&nbsp;</td>
					<td>&nbsp;#dateformat(qryPGProductCategoryDefinitionByID.PG_Effective_End_Date, 'mm/dd/yyyy')#&nbsp;</td>
				</cfif>
          </tr>
          <cfelse>
          <tr id="tr_prodExisting_#qryPGProductCategoryDefinitionByID.Product_Group_ID#" bgcolor="eeeeee">
		        <td width="15"><img bDelete="true" name="IMG_Delete_Scissor_Existing"  src="/images/scissor.gif"  title="click here to delete this row" border="0" onclick="fnDeleteThisPGMemberRecord('#qryPGProductCategoryDefinitionByID.Product_Group_ID#', 'tr_prodExisting_#qryPGProductCategoryDefinitionByID.Product_Group_ID#','2');" style="cursor:pointer;"></td>
		        <td>#Trim(qryPGProductCategoryDefinitionByID.Group_Desc)#</td>
		        <td><cfif qryPGProductCategoryDefinitionByID.Group_Number EQ "">&nbsp;<cfelse>#qryPGProductCategoryDefinitionByID.Group_Number#</cfif> </td>
		        <td>
					<cfif ((qryPGProductCategoryDefinitionByID.Product_Group_Level_ID LT 2000) AND qryPGProductCategoryDefinitionByID.Group_Desc NEQ "Product")>
				  		<a href="##" onclick="NewWindow('/Common_Files/contracts/Groups/group_items.cfm?Group_ID=#qryPGProductCategoryDefinitionByID.Product_Group_ID#&Group_Level_ID=#qryPGProductCategoryDefinitionByID.Product_Group_Level_ID#', 'Group_Items', 800, 600, 'yes', 'yes');">
		  					#qryPGProductCategoryDefinitionByID.Group_Name#
		  				</a>&nbsp;
					<cfelseif (qryPGProductCategoryDefinitionByID.Product_Group_Level_ID GTE 2000 AND  qryPGProductCategoryDefinitionByID.Group_Desc NEQ "Product")>
						<a href="##" onclick="NewWindow('/settings/Planning_Groups/Product_PG_Info.cfm?ID=#qryPGProductCategoryDefinitionByID.Product_Group_ID#&calledFrom=prodAddEdit', 'Group_Items', 800, 600, 'yes', 'yes');"> #Trim(qryPGProductCategoryDefinitionByID.Group_Name)#</a>&nbsp;
					<cfelse>
						#Trim(qryPGProductCategoryDefinitionByID.Group_Name)#&nbsp;
					</cfif>
				</td>
			<cfif isBusinessSegEnabledForProduct>
				<td>#qryPGProductCategoryDefinitionByID.Business_Unit_Desc#&nbsp;</td>
			</cfif>
	            <td><nobr>
		              <input type="radio" name="rdoIncExc_#Replace(qryPGProductCategoryDefinitionByID.Product_Group_ID,'-','_','ALL')#" value="1"
		              <cfif (isDefined("FORM.rdoIncExc_#Replace(qryPGProductCategoryDefinitionByID.Product_Group_ID,'-','_','ALL')#") AND evaluate("FORM.rdoIncExc_" & Replace(qryPGProductCategoryDefinitionByID.Product_Group_ID,'-','_','ALL')) EQ 1)>checked
		              <cfelseif (qryPGProductCategoryDefinitionByID.Inclusion_Exclusion)>checked
		              </cfif>> Include
		                <input type="radio" name="rdoIncExc_#Replace(qryPGProductCategoryDefinitionByID.Product_Group_ID,'-','_','ALL')#" value="0"
		             <cfif (isDefined("FORM.rdoIncExc_#Replace(qryPGProductCategoryDefinitionByID.Product_Group_ID,'-','_','ALL')#") AND evaluate("FORM.rdoIncExc_" & Replace(qryPGProductCategoryDefinitionByID.Product_Group_ID,'-','_','ALL')) EQ 0)>checked
		              <cfelseif NOT (qryPGProductCategoryDefinitionByID.Inclusion_Exclusion)>checked
		              </cfif>>  Exclude
					</nobr>
	            </td>
				 <cfif appSettings.get_Setting('PG_Eff_Date_Product') eq '1'>
					<td>
					<input type="text" name="PG_Effective_Start_Date_#Replace(qryPGProductCategoryDefinitionByID.PG_Product_Category_Definition_ID,'-','_','ALL')#" size="12" maxlength="10"
					  <cfif (isDefined("qryPGProductCategoryDefinitionByID.PG_Effective_Start_Date")
					  AND qryPGProductCategoryDefinitionByID.PG_Effective_Start_Date NEQ "" AND (qryPGProductCategoryDefinitionByID.PG_Effective_Start_Date  NEQ "1900-01-01 00:00:00.000")
					  )>
					value="#dateformat(qryPGProductCategoryDefinitionByID.PG_Effective_Start_Date,'MM/DD/YYYY')#"
					 <cfelse>value="#dateformat(qryGetPGProductCategoryByID.PG_Effective_Start_Date,'MM/DD/YYYY')#"  
					</cfif> class="EffDate">
	 				</td>
					<td>
					<input type="text" name="PG_Effective_End_Date_#Replace(qryPGProductCategoryDefinitionByID.PG_Product_Category_Definition_ID,'-','_','ALL')#" size="12" maxlength="10"
					   <cfif (isDefined("qryPGProductCategoryDefinitionByID.PG_Effective_End_Date")
					  AND qryPGProductCategoryDefinitionByID.PG_Effective_End_Date NEQ "" AND (qryPGProductCategoryDefinitionByID.PG_Effective_End_Date  NEQ "1900-01-01 00:00:00.000")
					  )>
					value="#dateformat(qryPGProductCategoryDefinitionByID.PG_Effective_End_Date,'MM/DD/YYYY')#"
					 <cfelse>value="#dateformat(qryGetPGProductCategoryByID.PG_Effective_End_Date,'MM/DD/YYYY')#"  
					</cfif> class="EffDate">
					</td>
				</cfif>
          </tr>
          </cfif>
	</cfloop>
           </table>
     <!---  </cfif> --->
	<cfif qryPGProductCategoryDefinitionByID.RecordCount GTE 12>
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
         <span id="title_22" onclick="switchlayer(22,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" style="cursor:pointer;color:00773c;">
          <span  title="Click here to toggle the view">
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
          <td align="left"> <strong>Groups/#application.returned_customer_setting.Item_Label#s</strong></td>
          <td>
					<input type="radio" name="rdoIncExc" value="1"> Include <input type="radio" name="rdoIncExc" value="0"> Exclude  </td>
  </tr>
  <tr>
    <td align="left" width="100px" nowrap valign="top">
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
              <!---<cfset prod.master = prod.master & prod.option>Drachala D32628 Segment Planning Groups Unavailable REMOVED IT AGAIN FOR LABEL 37056 --->
              <!--- if this option is not master add it to the mastersystem list --->
              <cfif qGetTopLevelGroups.Is_PG neq 0>
                <cfset prod.masterSystem = prod.masterSystem & prod.option>
              </cfif>
            </cfif>

            <cfset prod.all = prod.all & prod.option>
          </cfloop>

  				<div id="WithPG">
    				<select name="GroupLevel1" id="GroupLevel1">
              <!--- 31191 - populate options dynamically by jQuery in \settings\Planning_Groups\index.cfm --->
    				</select>
          </div>

<!--- There was a return in before  showSearchWindow --->
  			<cfset extraParameter = " onClick=""javascript:showSearchWindow('/Search_Screens/ApprovalGroup_Search.cfm?IncludeIOPGFlag=1&ExcludeItemID=#FORM.PGProductCategoryID#&groupLevelId=', 'Allow_Approval_group&Business_Segment_Id=#bsid#',document.DataForm);return false;""" />
 		 		<CF_smallLink
  					title = "add group"
  					url = "##"
  					parameters = "#extraParameter#"
  					>
        <input type="hidden" name="GroupLevel"  value="#FORM.GroupLevel#" />
      <cfelse>
        <input type="hidden" name="GroupLevel" value="" />
      </cfif>
      <cfset addProductLabel = "add #application.returned_customer_setting.Item_Label#s" />

  		<CF_smallLink
  			title = "#addProductLabel#"
  			url = "##"
  			parameters = "onClick=""javascript:showProductSearchWindow(#bsid#);return false;"""
  		><!--- return showProductSearchWindow --->
    </td>
    </tr>
</table>
  </div>
    </div>
</fieldset>
    </td>
  </tr>
  <tr>
    <td colspan="2">

<!--- INCLUDE LIST STARTS --->

 <fieldset id="border_2" style="border-width:0; border-color:; border-style:solid; width:710">
     <legend>
        <img id="image_2" src="/images/plus2.gif" onclick="switchlayer(2,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" border="0" title="" style="cursor:pointer">
       <font face="Arial">
	        <b style="font-size:9pt">
		         <span id="title_2" onclick="switchlayer(2,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" style="color:00773c;cursor:pointer">
			          <span  title="Click here to toggle the view">
						      Newly Added Include List
			          </span>
		         </span>
	        </b>
       </font>
     </legend>


      <cfif isDefined("FORM.product_List") AND Len(FORM.product_List) GT 0 >
      <cfset qProductList = ProductManager.getproducts(FORM.product_List) />
      </cfif>
      <cfif Len(FORM.Allow_Approval_group) GT 0>
        <cfset approvalGroupManager.getGroupTypeInfo(FORM.GroupLevel)/>
  			<cfset qGetApprovalGroups = approvalGroupManager.getApprovalGroups(FORM.Allow_Approval_group)>
      </cfif>
			<cfset FORM.Allow_Approval_group = "" />

     <cfif (isDefined("qGetApprovalGroups") AND	qGetApprovalGroups.RecordCount GTE 1)>
      <cfset sesCount = SESSION.qryGrpProdPack.RecordCount  />
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
              <cfif appSettings.get_Setting('Display_Item_No') eq '1'>
              	<cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "Group_Product_ID", qProductList.BSA_FoodService_Items_Master_ID, SESSION.qryGrpProdPack.recordCount)>
              <cfelse>
              	<cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "Group_Product_ID", '', SESSION.qryGrpProdPack.recordCount)>
              </cfif>
              <cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "Item_No", qProductList.Item, SESSION.qryGrpProdPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "Description", qProductList.Description, SESSION.qryGrpProdPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "Inc_Exc", frmRdoIncExcVal, SESSION.qryGrpProdPack.recordCount)>
              <cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "IsPG", 0, SESSION.qryGrpProdPack.recordCount) />
			  <cfset temp = QuerySetCell(SESSION.qryGrpProdPack, "Business_Unit_Desc", BusinessSegment, SESSION.qryGrpProdPack.recordCount) />
              <cfset iCounter  = iCounter + 1 />
            </cfif>
        </cfloop>
      </cfif>

<!--- INCLUDE LIST --->
<div id="lyrgroup_2" style="display:none; visibility:inherit; z-index:5; margin-left:5; margin-right:5; margin-top:5; margin-bottom:8;">
<div id="masterContainer">
<!--- Contents go here start--->
<table cellpadding="2" cellspacing="1" width="100%" border="1" bordercolor="979797">
  <tr>
  	<td id="header" WIDTH="3%" rowspan="1"><img name="IMG_Delete_Scissor_Include" bDelete="true" sMessage="delete all records in this page" src="/images/scissor.gif" title="delete all records in this page" border="0" onclick="if(confirm('Please confirm that you would like to DELETE all checked products!')){fnDeleteAllList('#valueList(SESSION.qryGrpProdPack.Group_Product_ID)#','tr_prodAddInc_','1');};" style="cursor:pointer;"></td>
	<td width="20%" rowspan="1"><b>Group<cfif appSettings.get_Setting('Display_Item_No') eq '1'>/#application.returned_customer_setting.Item_Label#</cfif> Number </b></td>
	<td width="30%" rowspan="1"><b>Group<cfif appSettings.get_Setting('Display_Item_No') eq '1'>/#application.returned_customer_setting.Item_Label#</cfif> Description</b></td>
	<td width="30%" rowspan="1"><b>Group<cfif appSettings.get_Setting('Display_Item_No') eq '1'>/#application.returned_customer_setting.Item_Label#</cfif> Name</b>&nbsp;</td>
<cfif isBusinessSegEnabledForProduct>
	<td width="20%" rowspan="1"><b>#appsettings.Business_Segment_Label#</b>&nbsp;</td>
</cfif>
 </tr>
<cfif (isDefined("SESSION.qryGrpProdPack") AND SESSION.qryGrpProdPack.RecordCount GTE 1 AND isDefined("SESSION.qryGrpProdPack.GroupLevel_Name"))>
	<cfloop query="SESSION.qryGrpProdPack">
       <cfif SESSION.qryGrpProdPack.Description NEQ "" AND SESSION.qryGrpProdPack.Item_No EQ "" AND SESSION.qryGrpProdPack.Inc_Exc EQ 1>
			<cfset recStriked = 0>
			<cfloop index = "delItem" list = "#FORM.DelMarkedInInclude#"  delimiters = ",">
				<cfif delItem EQ SESSION.qryGrpProdPack.Group_Product_ID>
					<cfset 	recStriked = 1 />
				</cfif>
			</cfloop>
		<cfif recStriked EQ 1>
	       	<tr id="tr_prodAddInc_#SESSION.qryGrpProdPack.Group_Product_ID#" style="text-decoration:line-through;background-color:bbbbbb">
				<td  width="3%"><img bDelete="false" name="IMG_Delete_Scissor_Include"  src="/images/undo.gif"  title="click here to undelete this product" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpProdPack.Group_Product_ID#', 'tr_prodAddInc_#SESSION.qryGrpProdPack.Group_Product_ID#','1');" style="cursor:pointer;"></td>
	  			<td><cfif (SESSION.qryGrpProdPack.GroupLevel_Number NEQ "")>#SESSION.qryGrpProdPack.GroupLevel_Number#<cfelse>Group <cfif appSettings.get_Setting('Display_Item_No') eq '1'>#application.returned_customer_setting.Item_Label#</cfif></cfif></td>
	          	<td>Level 1/#SESSION.qryGrpProdPack.GroupLevel_Name#</td>
	          	<td>#SESSION.qryGrpProdPack.Description#</td>
			<cfif isBusinessSegEnabledForProduct>
	   			<td>#SESSION.qryGrpProdPack.Business_Unit_Desc#&nbsp;</td>
			</cfif>
	        </tr>
       <cfelse>
	         <tr id="tr_prodAddInc_#SESSION.qryGrpProdPack.Group_Product_ID#" bgcolor="eeeeee">
	          	<td width="3%"><img bDelete="true" name="IMG_Delete_Scissor_Include"  src="/images/scissor.gif"  title="click here to delete this product" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpProdPack.Group_Product_ID#', 'tr_prodAddInc_#SESSION.qryGrpProdPack.Group_Product_ID#','1');" style="cursor:pointer;"></td>
	  			<td bgcolor="eeeeee"><cfif (SESSION.qryGrpProdPack.GroupLevel_Number NEQ "")>#SESSION.qryGrpProdPack.GroupLevel_Number#<cfelse>Group <cfif appSettings.get_Setting('Display_Item_No') eq '1'>#application.returned_customer_setting.Item_Label#</cfif></cfif></td>
	          	<td bgcolor="eeeeee">Level 1/#SESSION.qryGrpProdPack.GroupLevel_Name#</td>
	          	<td bgcolor="eeeeee">#SESSION.qryGrpProdPack.Description#</td>
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
		<cfif SESSION.qryGrpProdPack.Description NEQ "" AND SESSION.qryGrpProdPack.Item_No NEQ "" AND (SESSION.qryGrpProdPack.GroupLevel_ID EQ "" OR SESSION.qryGrpProdPack.GroupLevel_ID EQ 0) AND SESSION.qryGrpProdPack.Inc_Exc EQ 1>
			<cfset recStriked = 0>
			<cfloop index = "delItem" list = "#FORM.DelMarkedInInclude#"  delimiters = ",">
				<cfif delItem EQ SESSION.qryGrpProdPack.Group_Product_ID>
					<cfset 	recStriked = 1 />
				</cfif>
			</cfloop>
		<cfif recStriked EQ 1>
           <tr id="tr_prodAddInc_#SESSION.qryGrpProdPack.Group_Product_ID#" style="text-decoration:line-through;background-color:bbbbbb">
				<td width="3%"><img  name="IMG_Delete_Scissor_Include" src="/images/undo.gif" bDelete="false" title="click here to undelete this product" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpProdPack.Group_Product_ID#', 'tr_prodAddInc_#SESSION.qryGrpProdPack.Group_Product_ID#','1');" style="cursor:pointer;"></td>
				<td><cfif appSettings.get_Setting('Display_Item_No') eq '1'>#SESSION.qryGrpProdPack.Item_No#<cfelse>&nbsp;N/A</cfif></td>
				<td>Product</td>
				<td>#SESSION.qryGrpProdPack.Description#</td>
			<cfif isBusinessSegEnabledForProduct>
				<td>#SESSION.qryGrpProdPack.Business_Unit_Desc#&nbsp;</td>
			</cfif>
          </tr>
        <cfelse>
          <tr id="tr_prodAddInc_#SESSION.qryGrpProdPack.Group_Product_ID#" bgcolor="eeeeee">
				<td width="3%"><img  name="IMG_Delete_Scissor_Include" src="/images/scissor.gif" bDelete="true" title="click here to delete this product" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpProdPack.Group_Product_ID#', 'tr_prodAddInc_#SESSION.qryGrpProdPack.Group_Product_ID#','1');" style="cursor:pointer;"></td>
	  			<td><cfif appSettings.get_Setting('Display_Item_No') eq '1'>#SESSION.qryGrpProdPack.Item_No#<cfelse>&nbsp;N/A</cfif></td>
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
<!--- Contents go here END ---->
</div>
</div>
</fieldset>


<!--- INCLUDE LIST ENDS --->

<!--- EXCLUDE LIST STARTS --->
 <fieldset id="border_3" style="border-width:0; border-color:; border-style:solid; width:710">
     <legend>
	        <img id="image_3" src="/images/plus2.gif" onclick="switchlayer(3,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" border="0" title="" style="cursor:pointer">
	       <font face="Arial">
		        <b style="font-size:9pt">
			         <span id="title_3" onclick="switchlayer(3,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" style="color:00773c;cursor:pointer">
			          	<span title="Click here to toggle the view">Newly Added Exclude List</span>
			         </span>
		        </b>
	       </font>
     </legend>

<div id="lyrgroup_3" style="display:none; visibility:inherit; z-index:5; margin-left:5; margin-right:5; margin-top:5; margin-bottom:8;">
<div id="masterContainer">
<table cellpadding="2" cellspacing="1" width="100%" border="1" bordercolor="##979797">
	<tr>
		<td id="header" WIDTH="3%" rowspan="1"><img name="IMG_Delete_Scissor_Exclude" bDelete="true" sMessage="delete all records in this page" src="/images/scissor.gif" title="delete all records in this page" border="0" onclick="if(confirm('Please confirm that you would like to DELETE all checked products!')){fnDeleteAllList('#valueList(SESSION.qryGrpProdPack.Group_Product_ID)#','tr_prodAddExc_','0');};" style="cursor:pointer;"></td>
		<td width="20%" rowspan="1"><b>Group<cfif appSettings.get_Setting('Display_Item_No') eq '1'>/#application.returned_customer_setting.Item_Label#</cfif> Number </b></td>
		<td width="30%" rowspan="1"><b>Group<cfif appSettings.get_Setting('Display_Item_No') eq '1'>/#application.returned_customer_setting.Item_Label#</cfif> Description</b></td>
		<td width="30%" rowspan="1"><b>Group<cfif appSettings.get_Setting('Display_Item_No') eq '1'>/#application.returned_customer_setting.Item_Label#</cfif> Name</b>&nbsp;</td>
	<cfif isBusinessSegEnabledForProduct>
		<td width="20%" rowspan="1"><b>#appsettings.Business_Segment_Label#</b>&nbsp;</td>
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
					<td>	<img bDelete="false" name="IMG_Delete_Scissor_Exclude"  src="/images/undo.gif"  title="click here to undelete this product" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpProdPack.Group_Product_ID#', 'tr_prodAddExc_#SESSION.qryGrpProdPack.Group_Product_ID#','0');" style="cursor:pointer;"></td>
					<td><cfif (SESSION.qryGrpProdPack.GroupLevel_Number NEQ "")>#SESSION.qryGrpProdPack.GroupLevel_Number#<cfelse>Group <cfif appSettings.get_Setting('Display_Item_No') eq '1'>#application.returned_customer_setting.Item_Label#</cfif></cfif></td>
	          		<td>Level 1/#SESSION.qryGrpProdPack.GroupLevel_Name#</td>
	          		<td>#SESSION.qryGrpProdPack.Description#</td>
				<cfif isBusinessSegEnabledForProduct>
		   			<td>#SESSION.qryGrpProdPack.Business_Unit_Desc#&nbsp;</td>
				</cfif>
	        	</tr>
			<cfelse>
				<tr id="tr_prodAddExc_#SESSION.qryGrpProdPack.Group_Product_ID#" bgcolor="eeeeee">
					  <td width="3%"><img bDelete="true" name="IMG_Delete_Scissor_Exclude"  src="/images/scissor.gif"  title="click here to delete this product" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpProdPack.Group_Product_ID#', 'tr_prodAddExc_#SESSION.qryGrpProdPack.Group_Product_ID#','0');" style="cursor:pointer;"></td>
					  <td bgcolor="eeeeee"><cfif (SESSION.qryGrpProdPack.GroupLevel_Number NEQ "")>#SESSION.qryGrpProdPack.GroupLevel_Number#<cfelse>Group <cfif appSettings.get_Setting('Display_Item_No') eq '1'>#application.returned_customer_setting.Item_Label#</cfif></cfif></td>
		  			  <td bgcolor="eeeeee">Level 1/#SESSION.qryGrpProdPack.GroupLevel_Name#</td>
		  			  <td bgcolor="eeeeee">#SESSION.qryGrpProdPack.Description#</td>
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
		            <td width="3%"><img  name="IMG_Delete_Scissor_Exclude" src="/images/undo.gif" bDelete="false" title="click here to undelete this product" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpProdPack.Group_Product_ID#', 'tr_prodAddExc_#SESSION.qryGrpProdPack.Group_Product_ID#','0');" style="cursor:pointer;"></td>
		  			<td><cfif appSettings.get_Setting('Display_Item_No') eq '1'>#SESSION.qryGrpProdPack.Item_No#<cfelse>&nbsp;N/A</cfif></td>
		            <td>Product</td>
				    <td>#SESSION.qryGrpProdPack.Description#</td>
				<cfif isBusinessSegEnabledForProduct>
		   			<td>#SESSION.qryGrpProdPack.Business_Unit_Desc#&nbsp;</td>
				</cfif>
	          </tr>
         <cfelse>
	          <tr id="tr_prodAddExc_#SESSION.qryGrpProdPack.Group_Product_ID#" bgcolor="eeeeee">
					<td width="3%"><img  name="IMG_Delete_Scissor_Exclude" src="/images/scissor.gif" bDelete="true" title="click here to delete this product" border="0" onclick="fnDeleteThisPGMemberRecord('#SESSION.qryGrpProdPack.Group_Product_ID#', 'tr_prodAddExc_#SESSION.qryGrpProdPack.Group_Product_ID#','0');" style="cursor:pointer;"></td>
					<td><cfif appSettings.get_Setting('Display_Item_No') eq '1'>#SESSION.qryGrpProdPack.Item_No#<cfelse>&nbsp;N/A</cfif></td>
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
    <td align="center">
<table>
		<tr>
			<td>
				<CF_button
					button_name		=	"View Micro Members"
					button_caption	=	"View Micro Members"
					button_action	=	"fnViewMicroMembers('1','#qryGetPGProductCategoryByID.PG_Product_Category_ID#','#lsPGmembersList#');return false;"
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
								button_action	=	"hideSaveLink('hide');saveEditPPG('2');return false;"
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
			</td>
		</tr>
	</table>

      <!--- <CF_smallLink
  			title = "View Micro Members"
  			url = "##"
  			parameters = "onClick=""javascript:fnViewMicroMembers('1','#qryGetPGProductCategoryByID.PG_Product_Category_ID#','#lsPGmembersList#');return false;"""
  		>
      <CF_smallLink
  			title = "Save"
  			url = "##"
  			parameters = "onClick=""javascript:saveEditPPG('2');return false;"""
  		> --->
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
  <input type="hidden" name="DelMarkedInExisting" id="DelMarkedInExisting" value="#FORM.DelMarkedInExisting#" />
  <input type="hidden" name="Allow_Approval_group" id="Allow_Approval_group"value="#FORM.Allow_Approval_group#">
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
		location.href="index.cfm?type=product&subtype=edit&ID=#qryGetPGProductCategoryByID.PG_Product_Category_ID#&OrderByField=#vOrderByField#&OrderBy=#newOrderBy#&EEMExpanded=true&memSearchKeyword=" + txtSearch;
	}

  </script>

</cfoutput>
