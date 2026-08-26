<!-----------------------------------------------------------------------------

FILE NAME:		itemFilter.cfm
DESCRIPTION:	This is the 
CREATED BY:		17-Jan-2011
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
      			Anand Rao	  17-Jan-2011	Created the file
------------------------------------------------------------------------------> 
 
<!--- Data insertion script based on the settings during the template creation --->
<cfquery name="qryCreateFilters" datasource="#application.datasource#">
IF(SELECT Count(*) FROM Group_Template WHERE Template_ID = #FirstParentID# AND Deleted = 0 AND PG_Group_Type =1) = 0
      BEGIN                              
            INSERT  INTO Group_Template ( Template_ID , Group_level_ID, PG_Group_Type,Allow_In_Search,Allow_In_Group_Search,Active, Deleted, Created_Date, Created_By, Updated_From, PG_Flag)
            SELECT DISTINCT #FirstParentID#, Product_Group_Level_ID,1 as PG_Group_Type, 
										  /* 
										  	30525: New template, 'in group search' default OFF/Anand Rao/21-Feb-2012 
										  	changed the default to be "0"
										  */	
                                          /* CASE WHEN Product_Group_level.Active = 1 THEN 1  
                                                 ELSE 0
                                          END AS Allow_In_Group_Search,       
                                          CASE WHEN Product_Group_level.Search_Filter_on = 1 THEN 1  
                                                 ELSE 0
                                          END AS Allow_In_Search, */
										  0 AS Allow_In_Search, 
										  0 AS Allow_In_Group_Search,
                                          1 AS Active, 0 as Deleted,  Created_Date, '#REQUEST.AccessStructure.User_ID#', 'Template Creation' , 
																					CASE WHEN Product_Group_Level_ID >= 2000 THEN 1
																						ELSE 0 
																					END AS PG_Flag
            FROM  Product_Group_Level
            WHERE Deleted = 0
            AND   (Search_Filter_ON = 1 OR Active = 1)
      END
</cfquery>

<!--- <cfparam name="form.bItemFilterContinue" type="boolean" default="0"/> --->

<cfset PGManager = CreateObject("component", "components.settings.PlanningGroups.PlanningGroupsManager").init() /> 
<cfset TemplateManager = CreateObject("component", "components.programs.template.TemplateManager").init() /> 

<cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />

<cfset qGetTopLevelGroups = GroupDataManager.getProductGroupsData() />

<cfset maxDDinProdSearch = PGManager.fnMaxItemsOnProdSearch() />

<cfif (isDefined("FORM.bSubmit") AND FORM.bSubmit EQ "1")>
  <cfset bSuccess = TemplateManager.fnSaveFilterProducts(
                   UserID = REQUEST.AccessStructure.User_ID,
                   stForm = FORM) />
 <cfif bSuccess NEQ "">
    <cfoutput>
      <script>
        alert("#bSuccess#");
        </script>
    </cfoutput>                     
  </cfif>                            
</cfif>

<!--- If save and continue is clicked --->
<!--- <cfif Form.bItemFilterContinue>
	<cfinclude template="/program_wizard/filter/filter_Next_Page.cfm" />
</cfif> --->

<cfset Template_ID = FirstParentID />
<cfset Template_Filters_ID = editTemplateFilter.Template_Filters_Id />
<!--- 
  1 - Product
  2 - Customer
  3 - Operator
--->
<cfset itemPGGroupType = 1 />

<cfset qryGetGroupTemplateByTemplateID = PGManager.fnGetGroupTemplateByTemplateID(Template_ID,itemPGGroupType)/>
<SCRIPT LANGUAGE="JavaScript" SRC="/settings/Planning_groups/_planning_groups.js"></SCRIPT>
<!--- <form name="DataForm" action="" method="post">    ,Template_Filters_ID --->
<!--- Dev Note: drachala; D28820: Template filters tab has no margins  START             
             Added/Changed:  style="margin: 10px;" to create space around filters table --->
<!--- D29688:Program Wizard Filters page (change table width from 620 to 700--->
 

<table width="700"  cellpadding="2" cellspacing="0" bordercolor="93BEE2" style="margin:10px;">
	<tr bgcolor="FFCE8">
		<td colspan="100%" bgcolor="FFC99"><font size="2px;"><b><cfoutput>#application.returned_customer_setting.Item_Label#</cfoutput> Filters</b></font></td>
	</tr>
  <tr bgcolor="ecfab4" style="height:20px">
    <td style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;"><b>Attribute</b></td>
    <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;">
	   <input type="checkbox" id="check_all_chkBoxSearchProd_" onclick="checkAll('Item', 'chkBoxSearchProd_', this.checked);"><b>Field in Search</b>&nbsp;&nbsp;
	</td>
    <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;">
		
	<cfif (AllowProductGroupSearch EQ 0)>
		<input type="checkbox" disabled>
	<cfelse>
		<input type="checkbox" id="check_all_chkBoxGroupProd_" onclick="checkAll('Item', 'chkBoxGroupProd_', this.checked);">
	</cfif><b>In Group Search</b>&nbsp;&nbsp;
	</td>
    <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;">
		<!---Comment by dinesh as per karen suggestion 
			:  REMOVE THE SELECT ALL CHECKBOX TO THE LEFT OF THE ‘ALLOW FILTERS’ COLUMN HEADER NAME.   WE WILL NOT LET THEM MASS SELECT ALL THE CHECKBOXES FOR ‘ALLOW FILTERS’.   
			THIS SHOULD ALSO ADDRESS ISSUE YOU MENTION ABOUT NOT STOPPING THEM AFTER 4 WHEN USER ‘SELECT ALL’.  
			 <input type="checkbox" id="check_all_chkBoxFilters_" onclick="checkAll('Item', 'chkBoxFilters_', this.checked);"> ---><b>Allow Filters</b>&nbsp;&nbsp;
	</td>
    <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;border-right:0px solid ##93BEE2;"><b>Filters</b></td>
	<td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;border-right:1px solid ##93BEE2;"><b>Prg Vol By Attribute</b></td>
  </tr>
  <cfoutput>
  <cfset varAdditionalData= ""/> 
  <cfloop Query = "qGetTopLevelGroups">
    <cfset bAllowInSearch = 0 />
    <cfset bAllowInGroupSearch = 0 />
    <cfset bAllowFilter = 0 />
	<cfset bPrgVolByAttribute = 0 />
    
    <cfloop query = "qryGetGroupTemplateByTemplateID">
      <cfif qGetTopLevelGroups.Product_Group_Level_ID EQ  qryGetGroupTemplateByTemplateID.Group_Level_ID>
        <cfset bAllowInSearch = qryGetGroupTemplateByTemplateID.Allow_In_Search />
        <cfset bAllowInGroupSearch = qryGetGroupTemplateByTemplateID.Allow_In_Group_Search />
        <cfset bAllowFilter = qryGetGroupTemplateByTemplateID.Allow_Filter />
		<cfset bPrgVolByAttribute = qryGetGroupTemplateByTemplateID.Prg_Vol_By_Attribute />
      </cfif>
      
    </cfloop> 
		<cfset displayRec = 0 />
		<!--- 29900:  Program Templates,  filter page changes/Anand Rao/11-Jan-2012 --->		
		<cfif (qGetTopLevelGroups.IS_PG EQ 1) AND (qryGetGroupTemplateByTemplateID.RecordCount GTE 1 AND (bAllowInSearch EQ 1 OR bAllowInGroupSearch EQ 1 OR bPrgVolByAttribute EQ 1 OR  bAllowFilter EQ 1))>
			<cfset displayRec = 1 />
		<cfelseif (qGetTopLevelGroups.IS_PG EQ 0)>
		 	<cfset displayRec = 1 />
		</cfif>
<!--- Dev Note: drachala; D29686: Program Wizard and Segement Filters for Distributor  START
Added/Changed: Checking if IsSystem if do to display all filters--->
<!--- <cfif (qGetTopLevelGroupsList.IS_PG EQ 1) AND (displayRec EQ 0) AND (PGManager.IsSystemCheck(itemPGGroupType, qGetTopLevelGroupsList.Product_Group_Level_ID))> --->
<cfif (qGetTopLevelGroups.IS_PG EQ 1) AND (displayRec EQ 0) AND (PGManager.IsSystemCheck(itemPGGroupType, qGetTopLevelGroups.Product_Group_Level_ID))>
		<cfset displayRec = 1 />
</cfif>
<!--- End Dev Note: drachala; D29686: Program Wizard and Segement Filters for Distributor  --->
 
	 <cfif displayRec EQ 1>
      <tr>
        <td style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">#qGetTopLevelGroups.Group_Level_Desc#<cfif (qGetTopLevelGroups.IS_PG EQ 1)> <b>[PGP]</b></cfif><!--- (#qGetTopLevelGroups.Product_Group_Level_ID#) ---></td>
        <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">
          <input type="Checkbox" name="chkBoxSearchProd_#qGetTopLevelGroups.Product_Group_Level_ID#_" ID="chkBoxSearchProd_#qGetTopLevelGroups.Product_Group_Level_ID#_" 
          <cfif (bAllowInSearch EQ 1)>checked</cfif> value="#qGetTopLevelGroups.Product_Group_Level_ID#" group="Item"/>
        </td>
        <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">
          <input type="Checkbox" name="chkBoxGroupProd_#qGetTopLevelGroups.Product_Group_Level_ID#_" ID="chkBoxGroupProd_#qGetTopLevelGroups.Product_Group_Level_ID#_" 
		  	<cfif (AllowProductGroupSearch EQ 0)>
			  	 <cfif application.appSettingsGet.getTemplateMultipleProductAttrGroups() EQ 1 AND Template.Active EQ 1>
				   	   disabled title="The Template is active so Product Group selections can not be modified."
				 <cfelse>
			  			disabled title="Select #application.returned_customer_setting.Item_Label# by Groups is OFF"
				  </cfif>
			</cfif>
            <cfif (bAllowInGroupSearch EQ 1)>checked</cfif> value="#qGetTopLevelGroups.Product_Group_Level_ID#" group="Item" />
						
						<!--- Added so the page won't throw an error --->
						<cfif (AllowProductGroupSearch EQ 0) and (bAllowInGroupSearch EQ 1)>
						   <input type="hidden" name="chkBoxGroupProd_#qGetTopLevelGroups.Product_Group_Level_ID#_" ID="chkBoxGroupProd_#qGetTopLevelGroups.Product_Group_Level_ID#_" 
            		 value="#qGetTopLevelGroups.Product_Group_Level_ID#" group="Item"/>
						</cfif>
        </td>
        <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">

	<!--- Dev Note: Drachala; D27736: Display alert if template has Allow Filters checked but no records selected START--->
	<!--- Added item_check_filters function --->       
          <input type="Checkbox" name="chkBoxFiltersProd_#qGetTopLevelGroups.Product_Group_Level_ID#_" ID="chkBoxFiltersProd_#qGetTopLevelGroups.Product_Group_Level_ID#_" 
            <cfif (bAllowFilter EQ 1)>checked</cfif> value="#qGetTopLevelGroups.Product_Group_Level_ID#" ID2="Item" group="Item" onclick="fnTemplateFiltersSave();fnCheckMaxNoofDDsInProdSearch(this);toggleFieldDisplay('chkBoxFiltersProd_#qGetTopLevelGroups.Product_Group_Level_ID#_','withoutLinkItem_#qGetTopLevelGroups.Product_Group_Level_ID#','withLinkItem_#qGetTopLevelGroups.Product_Group_Level_ID#');" />
        </td>
	<!--- Dev Note: Drachala; D27736: Display alert if template has Allow Filters checked but no records selected START--->
        <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-right:0px solid ##93BEE2;">
          <b>
            <div id="withLinkItem_#qGetTopLevelGroups.Product_Group_Level_ID#" <cfif bAllowFilter EQ 0>style="display:none;"</cfif> align="center">          
             [ 
						  <cfif LockedBy_Current_User EQ 1>
						 		<a href="##" onclick="javascript:selectItemFiltersPopup(#qGetTopLevelGroups.Product_Group_Level_ID#,#Template_ID#,#Template_Filters_ID#);return false;">
							<cfelse>
						 		<a href="##" onclick="javascript:alert('Template should be in edit mode to Select Filters!');return false;">
						 	</cfif>
								Select Filters</a> ] 
            </div>
            <div id="withoutLinkItem_#qGetTopLevelGroups.Product_Group_Level_ID#" <cfif bAllowFilter EQ 1>style="display:none;"</cfif> align="center" title="Check Allow Filters to Select Filters">          
              [ Check Filters ]
            </div>
            </b>
        </td>  
		<td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-right:1px solid ##93BEE2;">
			 <input type="Checkbox" name="chkBoxPrgVolByAttribute_#qGetTopLevelGroups.Product_Group_Level_ID#_"  ID="chkBoxPrgVolByAttribute_#qGetTopLevelGroups.Product_Group_Level_ID#_" 
			  <cfif (bPrgVolByAttribute EQ 1)>checked</cfif> value="#qGetTopLevelGroups.Product_Group_Level_ID#" />
		</td>		      
      </tr>
<cfelse><!--- cfelse for <cfif displayRec EQ 1> --->
		<cfsavecontent variable = "varAdditionalData">
		#varAdditionalData#
		 <tr>
        <td style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">#qGetTopLevelGroups.Group_Level_Desc#<cfif (qGetTopLevelGroups.IS_PG EQ 1)> <b>[PGP]</b></cfif><!--- (#qGetTopLevelGroups.Product_Group_Level_ID#) ---></td>
        <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">
          <input type="Checkbox" name="chkBoxSearchProd_#qGetTopLevelGroups.Product_Group_Level_ID#_" ID="chkBoxSearchProd_#qGetTopLevelGroups.Product_Group_Level_ID#_" 
          <cfif (bAllowInSearch EQ 1)>checked</cfif> value="#qGetTopLevelGroups.Product_Group_Level_ID#" group="Item"/>
        </td>
        <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">
          <input type="Checkbox" name="chkBoxGroupProd_#qGetTopLevelGroups.Product_Group_Level_ID#_" ID="chkBoxGroupProd_#qGetTopLevelGroups.Product_Group_Level_ID#_" 
            <cfif (bAllowInGroupSearch EQ 1)>checked</cfif> value="#qGetTopLevelGroups.Product_Group_Level_ID#" 
						<cfif (AllowProductGroupSearch EQ 0)>disabled title="Select #application.returned_customer_setting.Item_Label# by Groups is OFF, hence disabled"</cfif> group="Item"/>
						
						<!--- Added so the page won't throw an error --->
						<cfif (AllowProductGroupSearch EQ 0) and (bAllowInGroupSearch EQ 1)>
						   <input type="hidden" name="chkBoxGroupProd_#qGetTopLevelGroups.Product_Group_Level_ID#_" ID="chkBoxGroupProd_#qGetTopLevelGroups.Product_Group_Level_ID#_" 
            		 value="#qGetTopLevelGroups.Product_Group_Level_ID#" group="Item"/>
						</cfif>
        </td>
        <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">

	<!--- Dev Note: Drachala; D27736: Display alert if template has Allow Filters checked but no records selected START--->
	<!--- Added item_check_filters function --->       
          <input type="Checkbox" name="chkBoxFiltersProd_#qGetTopLevelGroups.Product_Group_Level_ID#_" ID="chkBoxFiltersProd_#qGetTopLevelGroups.Product_Group_Level_ID#_" 
            <cfif (bAllowFilter EQ 1)>checked</cfif> value="#qGetTopLevelGroups.Product_Group_Level_ID#" ID2="Item" group="Item" onclick="fnTemplateFiltersSave();fnCheckMaxNoofDDsInProdSearch(this);toggleFieldDisplay('chkBoxFiltersProd_#qGetTopLevelGroups.Product_Group_Level_ID#_','withoutLinkItem_#qGetTopLevelGroups.Product_Group_Level_ID#','withLinkItem_#qGetTopLevelGroups.Product_Group_Level_ID#');" />
        </td>
	<!--- Dev Note: Drachala; D27736: Display alert if template has Allow Filters checked but no records selected START--->
        <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-right:0px solid ##93BEE2;">
          <b>
            <div id="withLinkItem_#qGetTopLevelGroups.Product_Group_Level_ID#" <cfif bAllowFilter EQ 0>style="display:none;"</cfif> align="center">          
             [ 
						  <cfif LockedBy_Current_User EQ 1>
						 		<a href="##" onclick="javascript:selectItemFiltersPopup(#qGetTopLevelGroups.Product_Group_Level_ID#,#Template_ID#,#Template_Filters_ID#);return false;">
							<cfelse>
						 		<a href="##" onclick="javascript:alert('Template should be in edit mode to Select Filters!');return false;">
						 	</cfif>
								Select Filters</a> ] 
            </div>
            <div id="withoutLinkItem_#qGetTopLevelGroups.Product_Group_Level_ID#" <cfif bAllowFilter EQ 1>style="display:none;"</cfif> align="center" title="Check Allow Filters to Select Filters">          
              [ Check Filters ]
            </div>
            </b>
        </td>  
		<td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-right:1px solid ##93BEE2;">
			 <input type="Checkbox" name="chkBoxPrgVolByAttribute_#qGetTopLevelGroups.Product_Group_Level_ID#_"  ID="chkBoxPrgVolByAttribute_#qGetTopLevelGroups.Product_Group_Level_ID#_" 
			  <cfif (bPrgVolByAttribute EQ 1)>checked</cfif> value="#qGetTopLevelGroups.Product_Group_Level_ID#" />
		</td>		      
      </tr>
	</cfsavecontent> 			  
	 </cfif>
</cfloop> 
</cfoutput>

</table>
<fieldset id="border_1" style="border-width:0; border-color:; border-style:solid; width:650"> 
     <legend> 
      <span> 
        <img id="image_1" src="/images/plus2.gif" onclick="switchlayer(1,'Collapse','Expand',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" border="0" alt="" style="cursor:pointer"> 
        
       <font face="Arial"> 
         <span id="title_1" onclick="switchlayer(1,'Collapse','Expand',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" style="cursor:pointer;color:00773c">
          <span title="Click here to toggle the view">
			      <font color="navy">Additional <cfoutput>#application.returned_customer_setting.Item_Label#</cfoutput> Attributes</font>
          </span> 
         </span> 
       </font> 
     </legend> 
    <div id="lyrgroup_1" style="display:none; visibility:inherit; z-index:5; margin-left:5; margin-right:5; margin-top:5; margin-bottom:8;"> 

      <div id="masterContainer">   
      <!---- START: Contents Go Here --->
	<table width="700" cellpadding="2" cellspacing="0" bordercolor="93BEE2" style="margin:5px;">
  	<tr bgcolor="ecfab4" style="height:20px">
    <td style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;"><b>Attribute</b></td>
    <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;">
	   <input type="checkbox" id="check_all_chkBoxSearchProd_" onclick="checkAll('Item', 'chkBoxSearchProd_', this.checked);"><b>Field in Search</b>&nbsp;&nbsp;
	</td>
    <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;">
		
	<cfif (AllowProductGroupSearch EQ 0)>
		<input type="checkbox" disabled>
	<cfelse>
		<input type="checkbox" id="check_all_chkBoxGroupProd_" onclick="checkAll('Item', 'chkBoxGroupProd_', this.checked);">
	</cfif><b>In Group Search</b>&nbsp;&nbsp;
	</td>
    <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;">
		<!---Comment by dinesh as per karen suggestion 
			:  REMOVE THE SELECT ALL CHECKBOX TO THE LEFT OF THE ‘ALLOW FILTERS’ COLUMN HEADER NAME.   WE WILL NOT LET THEM MASS SELECT ALL THE CHECKBOXES FOR ‘ALLOW FILTERS’.   
			THIS SHOULD ALSO ADDRESS ISSUE YOU MENTION ABOUT NOT STOPPING THEM AFTER 4 WHEN USER ‘SELECT ALL’.  
			 <input type="checkbox" id="check_all_chkBoxFilters_" onclick="checkAll('Item', 'chkBoxFilters_', this.checked);"> ---><b>Allow Filters</b>&nbsp;&nbsp;
	</td>
    <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;border-right:0px solid ##93BEE2;"><b>Filters</b></td>
	<td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;border-right:1px solid ##93BEE2;"><b>Prg Vol By Attribute</b></td>
  </tr>
	  
		<cfif varAdditionalData EQ "">
			<tr>
				<td colspan="100%" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:0px solid ##93BEE2;border-right:1px solid ##93BEE2;text-align:center;"><strong>No Additional Attribute records found!</strong></td>
			</tr>
		<cfelse>
			<cfoutput>#varAdditionalData#</cfoutput>
		</cfif>
		
</table>	 
      <!---- END: Contents Go Here --->
      </div>
    </div>
</fieldset> 

<br>

      <!---- END: Contents Go Here --->
	  
 
<input type="hidden" name="groupLevelId" value="" group="Item"/>
<input type="hidden" name="SelectedFilterGroups" value="" group="Item"/>
<!--- <input type="hidden" name="bSubmit" value="0" />
<input type="hidden" id="bItemFilterContinue" name="bItemFilterContinue" value="0"/> --->
<cfoutput>
  <!--- <input type="hidden" name="TemplateID" <cfif isDefined("Template_ID") AND Template_ID NEQ "">value="#Template_ID#"<cfelse>value=""</cfif> />
  <input type="hidden" name="PgGroupType" <cfif isDefined("PgGroupType") AND PgGroupType NEQ "">value="#PgGroupType#"<cfelse>value=""</cfif> />
  <input type="hidden" name="TemplateFiltersID" <cfif isDefined("Template_Filters_ID") AND Template_Filters_ID NEQ "">value="#Template_Filters_ID#"<cfelse>value=""</cfif> />   --->
	
 <input type="hidden" name="itemPGGroupType" group="Item" <cfif isDefined("itemPGGroupType") AND itemPGGroupType NEQ "">value="#itemPGGroupType#"<cfelse>value=""</cfif> />	
</cfoutput>
<!--- </form> --->

<cfoutput>
<script language="javascript">
function selectItemFiltersPopup(GroupID,TemplateID,TemplateFiltersID)
{
  var actionFrm = document.DataForm;
  var lsValsToDel = "";
  var sURL = "";
  actionFrm.groupLevelId.value=GroupID;
  sURL = "/Search_Screens/ApprovalGroup_Search.cfm?PageSource=PGFilters&CurrentTemplateID=#ID#&groupLevelId=" + GroupID + "&TemplateID=" + TemplateID + "&FormName=DataForm&FieldName=SelectedFilterGroups&TemplateFiltersID=" + TemplateFiltersID;
  NewWindow(sURL, 'Select_filters', 1000, 800, 'yes', 'yes');
}

<!--- 
function fnTemplateFiltersSave()
{
  var actionFrm = document.DataForm;
  actionFrm.bSubmit.value = "1";
  actionFrm.submit();
} --->

function fnCheckMaxNoofDDsInProdSearch(obj)
{

  var maxNoDDs = "#maxDDinProdSearch#";
  var checkedDDs = 0;
  <cfloop query ="qGetTopLevelGroups">
 		<cfset bAllowInSearch = 0 />
    <cfset bAllowInGroupSearch = 0 />
    <cfset bAllowFilter = 0 />
    
    <cfloop query = "qryGetGroupTemplateByTemplateID">
      <cfif qGetTopLevelGroups.Product_Group_Level_ID EQ  qryGetGroupTemplateByTemplateID.Group_Level_ID>
        <cfset bAllowInSearch = qryGetGroupTemplateByTemplateID.Allow_In_Search />
        <cfset bAllowInGroupSearch = qryGetGroupTemplateByTemplateID.Allow_In_Group_Search />
        <cfset bAllowFilter = qryGetGroupTemplateByTemplateID.Allow_Filter />
      </cfif>
      
    </cfloop> 
		<cfset displayRec = 0 />
		
		<cfif (qGetTopLevelGroups.IS_PG EQ 1) AND (bAllowInSearch EQ 1 OR bAllowInGroupSearch EQ 1)>
			<cfset displayRec = 1 />
		<cfelseif (qGetTopLevelGroups.IS_PG EQ 0)>
		 	<cfset displayRec = 1 />
		</cfif>
	 
	 <cfif displayRec EQ 1>	
	
   if( eval("document.all.chkBoxFiltersProd_#qGetTopLevelGroups.Product_Group_Level_ID#_.checked") == true)
   {
    checkedDDs = checkedDDs + 1;
   }
	 </cfif>		 
  </cfloop>

  if (checkedDDs > maxNoDDs)
  {
  alert("Only a maximum of #maxDDinProdSearch# filters are allowed!!")
  obj.checked = false;
  }
 
}
</script>
</cfoutput>

<hr width="720" style="color:800000;margin-left:5px;" align="left" /> 