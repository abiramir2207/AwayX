<!-----------------------------------------------------------------------------

FILE NAME:		customerFilter.cfm
DESCRIPTION:	This is the 
CREATED BY:		17-Jan-2011
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
      			Anand Rao	  17-Jan-2011	Created the file
------------------------------------------------------------------------------> 
<!--- Data insertion script based on the settings during the template creation --->
 
<cfquery name="qryCreateFilters" datasource="#application.datasource#">
	IF(SELECT Count(*) FROM Group_Template WHERE Template_ID = #FirstParentID# AND Deleted = 0  AND PG_Group_Type=2) = 0
      BEGIN                              
            INSERT  INTO Group_Template ( Template_ID , Group_level_ID, PG_Group_Type,Allow_In_Search,Allow_In_Group_Search,Active, Deleted, Created_Date, Created_By, Updated_From, PG_Flag)
            SELECT DISTINCT #FirstParentID#, Distributor_Group_Level_ID,2 AS PG_Group_Type,
										 /* 
										  	30525: New template, 'in group search' default OFF/Anand Rao/21-Feb-2012 
											changed the default to be "0"
										  */	
                                         /* CASE WHEN Distributor_Group_Level.Active = 1 THEN 1  
                                                 ELSE 0
                                          END AS Allow_In_Group_Search,       
                                          CASE WHEN Distributor_Group_Level.Search_Filter_On = 1 THEN 1  
                                                 ELSE 0
                                          END AS Allow_In_Search, */
										  0 AS Allow_In_Search,
										  0 AS Allow_In_Group_Search,
                                          1 AS Active, 0 AS Deleted,  Created_Date, '#REQUEST.AccessStructure.User_ID#', 'Template Creation' , 																					
																					CASE WHEN Distributor_Group_Level_ID >= 2000 THEN 1
																						ELSE 0 
																					END AS PG_Flag
            FROM  Distributor_Group_Level
            WHERE Deleted = 0
            AND   (Search_Filter_ON = 1 OR Active = 1)
      END
</cfquery>

<!--- <cfparam name="form.bCustFilterContinue" type="boolean" default="0"/> --->
<cfset PGManager = CreateObject("component", "components.settings.PlanningGroups.PlanningGroupsManager").init() /> 
<cfset TemplateManager = CreateObject("component", "components.programs.template.TemplateManager").init() /> 
<cfset maxDDinDistSearch = PGManager.fnMaxItemsOnDistSearch() />
<cfset DistGroupDataManager = CreateObject("component", "components.customer.Group.DataManager").init() />

<cfif (isDefined("FORM.bSubmit") AND FORM.bSubmit EQ "1")>

<!--- TODO : Check to make sure that whatever the user checked has atleast one record in the customer_group_template_selection --->
 
<cfset bSuccess = TemplateManager.fnSaveFilterCustomers(
                   UserID = REQUEST.AccessStructure.User_ID,
                   stForm = FORM) />
  
  <cfif bSuccess NEQ "">
    <cfoutput>
      <script>
        alert("#bsuccess#");
        </script>
    </cfoutput>                     
  </cfif>                   
 
</cfif>
<!--- If save and continue is clicked --->
<!--- <cfif Form.bCustFilterContinue>
	<cfinclude template="/program_wizard/filter/filter_Next_Page.cfm" />
</cfif> --->
<!--- 
  Distributor_Group_Level Table values:
  Business Segment - 1, Family - 2, Buying Group - 3, Line of Business - 4, Market - 23, Region -	24, Zone - 25
  The below function takes (Active, Include list, exclude List)
  So, we pick only the above values for the dropdown 
---> 

<cfquery name="qryDistList" datasource="#application.datasource#">
  SELECT DISTINCT(Distributor_Group_Level_ID) FROM Distributor_Group_Level WHERE Active= 1 AND Deleted = 0 AND Distributor_Group_Level_ID NOT IN (23, 24, 25)
</cfquery>
 
<cfset qGetTopLevelGroupsList = DistGroupDataManager.getDistributorLevelsAll(1, "#ValueList(qryDistList.Distributor_Group_Level_ID)#", "") />

<!--- This is the First_Parent_ID  --->
<!--- Template_ID = 526<br>
PgGroupType = 1 (1- Product;2-Customer )<br>
Template_Filters_ID = '5'  --->


<!--- <cfset Template_ID ='526'>
<cfset Template_Filters_ID = '5' /> --->

<cfset Template_ID = FirstParentID />
<cfset Template_Filters_ID = editTemplateFilter.Template_Filters_Id />
<!--- 
  1 - Product
  2 - Customer
  3 - Operator
--->
<cfset cusPGGroupType = 2 />
 
<cfset qryGetGroupTemplateByTemplateID = PGManager.fnGetGroupTemplateByTemplateID(Template_ID,cusPGGroupType)/>
<SCRIPT LANGUAGE="JavaScript" SRC="/settings/Planning_groups/_planning_groups.js"></SCRIPT>
 
<!--- <form name="DataForm" action="" method="post"> --->
<!--- Dev Note: drachala; D28820: Template filters tab has no margins  START             
             Added/Changed:  style="margin: 10px;" to create space around filters table --->
<!--- D29688:Program Wizard Filters page (change table width from 620 to 700--->
<table width="700" cellpadding="2" cellspacing="0" bordercolor="93BEE2" style="margin: 10px;">
	<tr bgcolor="FFCE8">
		<td colspan="100%" bgcolor="FFC99"><font size="2px;"><b><cfoutput>#application.returned_customer_setting.Distributor_Label_Singular#</cfoutput> Filters</b></font></td>
	</tr>
  <tr bgcolor="ecfab4" style="height:20px">
    <td style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;"><b>Attribute<!--- Group Level Name ---></b></td>
    <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;">
		<input type="checkbox" id="check_all_chkBoxFiltersDist_" onclick="checkAll('Customer', 'chkBoxSearchDist_', this.checked);"><b>Field in Search</b>
	</td>
    <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;">
	
			<cfif (AllowDistributorGroupSearch EQ 0)>
				<input type="checkbox" disabled>
			<cfelse>
				<input type="checkbox" id="check_all_chkBoxFiltersDist_" onclick="checkAll('Customer', 'chkBoxGroupDist_', this.checked);">
			</cfif>	<b>In Group Search<!--- Allow as Group Selection ---></b>&nbsp;&nbsp;
	</td>
	  <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;">
			<!--- Comment by dinesh as per karen suggestion 
				:  REMOVE THE SELECT ALL CHECKBOX TO THE LEFT OF THE ‘ALLOW FILTERS’ COLUMN HEADER NAME.   WE WILL NOT LET THEM MASS SELECT ALL THE CHECKBOXES FOR ‘ALLOW FILTERS’.   
				THIS SHOULD ALSO ADDRESS ISSUE YOU MENTION ABOUT NOT STOPPING THEM AFTER 4 WHEN USER ‘SELECT ALL’.  
			<input type="checkbox" id="check_all_chkBoxFilters_" onclick="checkAll('Customer', 'chkBoxFilters_', this.checked);"> ---><b>Allow Filters</b>
		</td>       
    <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;border-right:1px solid ##93BEE2;">
		<b>Filters</b>
	</td>
  </tr>
  <cfoutput>	
  <cfset varAdditionalData= ""/>
  <cfloop Query = "qGetTopLevelGroupsList">
    <cfset bAllowInSearch = 0 />
    <cfset bAllowInGroupSearch = 0 />
    <cfset bAllowFilter = 0 />   
    
    <cfloop query = "qryGetGroupTemplateByTemplateID">
      <cfif qGetTopLevelGroupsList.Distributor_Group_Level_ID EQ  qryGetGroupTemplateByTemplateID.Group_Level_ID>
        <cfset bAllowInSearch = qryGetGroupTemplateByTemplateID.Allow_In_Search />
        <cfset bAllowInGroupSearch = qryGetGroupTemplateByTemplateID.Allow_In_Group_Search />
         <cfset bAllowFilter = qryGetGroupTemplateByTemplateID.Allow_Filter />        
      </cfif>
      
    </cfloop>
		<cfset displayRec = 0 />
		
		<cfif (qGetTopLevelGroupsList.IS_PG EQ 1) AND (qryGetGroupTemplateByTemplateID.RecordCount GTE 1 AND (bAllowInSearch EQ 1 OR bAllowInGroupSearch EQ 1 OR bAllowFilter EQ 1))>		
			<cfset displayRec = 1 />
		<cfelseif (qGetTopLevelGroupsList.IS_PG EQ 0)>
		 	<cfset displayRec = 1 />
		</cfif>
<!--- Dev Note: drachala; D29686: Program Wizard and Segement Filters for Distributor  START
Added/Changed: Checking if IsSystem if do to display all filters--->
<cfif (qGetTopLevelGroupsList.IS_PG EQ 1) AND (displayRec EQ 0) AND (PGManager.IsSystemCheck(cusPGGroupType, qGetTopLevelGroupsList.Distributor_Group_Level_ID))>
		<cfset displayRec = 1 />
</cfif>

<!--- End Dev Note: drachala; D29686: Program Wizard and Segement Filters for Distributor  --->
 	<cfif displayRec EQ 1>	
			
	      <tr>
	        <td style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">#qGetTopLevelGroupsList.Group_Level_Desc#<cfif (qGetTopLevelGroupsList.IS_PG EQ 1)> <b>[PGP]</b></cfif></td>
	        <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">
	          <input type="Checkbox" name="chkBoxSearchDist_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#_" ID="chkBoxSearchDist_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#_" 
	          <cfif (bAllowInSearch EQ 1)>checked</cfif> value="#qGetTopLevelGroupsList.Distributor_Group_Level_ID#" group="Customer"/>
	        </td>
	        <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">
	        <input type="Checkbox" name="chkBoxGroupDist_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#_" ID="chkBoxGroupDist_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#_" 
	            <cfif (bAllowInGroupSearch EQ 1)>checked</cfif> value="#qGetTopLevelGroupsList.Distributor_Group_Level_ID#" <cfif (AllowDistributorGroupSearch EQ 0)>disabled title="Select #application.returned_customer_setting.Distributor_Label_Plural# by Groups is OFF, hence disabled"</cfif> group="Customer"/>
							<!--- Added so the page won't throw an error --->
							<cfif (AllowDistributorGroupSearch EQ 0) and (bAllowInGroupSearch EQ 1)>
							   <input type="hidden" name="chkBoxGroupDist_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#_" ID="chkBoxGroupDist_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#_" 
	            		 value="#qGetTopLevelGroupsList.Distributor_Group_Level_ID#" group="Customer"/>
							</cfif>
	        </td>
			<td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">
	
		<!--- Dev Note: Drachala; D27736: Display alert if template has Allow Filters checked but no records selected START---> 
		<!--- Added Check_filters function --->      
	          <input type="Checkbox" name="chkBoxFiltersDist_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#_" ID="chkBoxFiltersDist_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#_" 
	            <cfif (bAllowFilter EQ 1)>checked</cfif> value="#qGetTopLevelGroupsList.Distributor_Group_Level_ID#" group="Customer" ID2="Customer" onclick="fnTemplateFiltersSave();fnCheckMaxNoofDDsInDistSearch(this);toggleFieldDisplay('chkBoxFiltersDist_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#_','withoutLinkCustomer_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#','withLinkCustomer_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#');" />
	        </td> 
		<!--- Dev Note: Drachala; D27736: Display alert if template has Allow Filters checked but no records selected END--->       
	        <td style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-right:1px solid ##93BEE2;">
	        <b>
	            <div id="withLinkCustomer_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#" <cfif bAllowFilter EQ 0>style="display:none;"</cfif> align="center">          
	             [ 
							 <cfif LockedBy_Current_User EQ 1>
							 	<a href="##" onclick="javascript:selectCusFiltersPopup(#qGetTopLevelGroupsList.Distributor_Group_Level_ID#,#Template_ID#,#Template_Filters_ID#);return false;">
							 <cfelse>
							 	<a href="##" onclick="javascript:alert('Template should be in edit mode to Select Filters!');return false;">
							 </cfif>
							 Select Filters</a> ] 
	            </div>
	            <div id="withoutLinkCustomer_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#" <cfif bAllowFilter EQ 1>style="display:none;"</cfif> align="center" title="Check Allow Filters to Select Filters">          
	              [ Check Filters ]
	            </div>
	      </b>
	        </td>        
	      </tr>
	 
<cfelse><!--- cfelse for <cfif displayRec EQ 1> --->
		<cfsavecontent variable = "varAdditionalData">
		#varAdditionalData#
 		<tr>
	        <td style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">#qGetTopLevelGroupsList.Group_Level_Desc# <cfif (qGetTopLevelGroupsList.IS_PG EQ 1)> <b>[PGP]</b></cfif></td>
	        <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">
	          <input type="Checkbox" name="chkBoxSearchDist_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#_" ID="chkBoxSearchDist_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#_" 
	          <cfif (bAllowInSearch EQ 1)>checked</cfif> value="#qGetTopLevelGroupsList.Distributor_Group_Level_ID#" group="Customer"/>
	        </td>
	        <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">
	        <input type="Checkbox" name="chkBoxGroupDist_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#_" ID="chkBoxGroupDist_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#_" 
	            <cfif (bAllowInGroupSearch EQ 1)>checked</cfif> value="#qGetTopLevelGroupsList.Distributor_Group_Level_ID#" <cfif (AllowDistributorGroupSearch EQ 0)>disabled title="Select #application.returned_customer_setting.Distributor_Label_Plural# by Groups is OFF, hence disabled"</cfif> group="Customer"/>
							<!--- Added so the page won't throw an error --->
							<cfif (AllowDistributorGroupSearch EQ 0) and (bAllowInGroupSearch EQ 1)>
							   <input type="hidden" name="chkBoxGroupDist_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#_" ID="chkBoxGroupDist_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#_" 
	            		 value="#qGetTopLevelGroupsList.Distributor_Group_Level_ID#" group="Customer"/>
							</cfif>
	        </td>
			<td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">
	
		<!--- Dev Note: Drachala; D27736: Display alert if template has Allow Filters checked but no records selected START---> 
		<!--- Added Check_filters function --->      
	          <input type="Checkbox" name="chkBoxFiltersDist_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#_" ID="chkBoxFiltersDist_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#_" 
	            <cfif (bAllowFilter EQ 1)>checked</cfif> value="#qGetTopLevelGroupsList.Distributor_Group_Level_ID#" group="Customer" ID2="Customer" onclick="fnTemplateFiltersSave();fnCheckMaxNoofDDsInDistSearch(this);toggleFieldDisplay('chkBoxFiltersDist_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#_','withoutLinkCustomer_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#','withLinkCustomer_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#');" />
	        </td> 
		<!--- Dev Note: Drachala; D27736: Display alert if template has Allow Filters checked but no records selected END--->       
	        <td style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-right:1px solid ##93BEE2;">
	        <b>
	            <div id="withLinkCustomer_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#" <cfif bAllowFilter EQ 0>style="display:none;"</cfif> align="center">          
	             [ 
							 <cfif LockedBy_Current_User EQ 1>
							 	<a href="##" onclick="javascript:selectCusFiltersPopup(#qGetTopLevelGroupsList.Distributor_Group_Level_ID#,#Template_ID#,#Template_Filters_ID#);return false;">
							 <cfelse>
							 	<a href="##" onclick="javascript:alert('Template should be in edit mode to Select Filters!');return false;">
							 </cfif>
							 Select Filters</a> ] 
	            </div>
	            <div id="withoutLinkCustomer_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#" <cfif bAllowFilter EQ 1>style="display:none;"</cfif> align="center" title="Check Allow Filters to Select Filters">          
	              [ Check Filters ]
	            </div>
	      </b>
	        </td>        
	      </tr>
 
		</cfsavecontent> 
	 
	</cfif>			
</cfloop> 
 </cfoutput>

</table>
 
 <fieldset id="border_2" style="border-width:0; border-color:; border-style:solid; width:650"> 
     <legend> 
      <span> 
        <img id="image_2" src="/images/plus2.gif" onclick="switchlayer(2,'Collapse','Expand',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" border="0" alt="" style="cursor:pointer"> 
        
       <font face="Arial"> 
         <span id="title_2" onclick="switchlayer(2,'Collapse','Expand',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" style="cursor:pointer;color:00773c">
          <span title="Click here to toggle the view">
			      <font color="navy">Additional <cfoutput>#application.returned_customer_setting.Distributor_Label_Singular#</cfoutput> Attributes</font>
          </span> 
         </span> 
       </font> 
     </legend> 
    <div id="lyrgroup_2" style="display:none; visibility:inherit; z-index:5; margin-left:5; margin-right:5; margin-top:5; margin-bottom:8;"> 

      <div id="masterContainer">   
      <!---- START: Contents Go Here --->
<table width="700" cellpadding="2" cellspacing="0" bordercolor="93BEE2" style="margin:5px;">
  <tr bgcolor="ecfab4" style="height:20px">
    <td style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;"><b>Attribute<!--- Group Level Name ---></b></td>
    <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;">
		<input type="checkbox" id="check_all_chkBoxFiltersDist_" onclick="checkAll('Customer', 'chkBoxSearchDist_', this.checked);"><b>Field in Search</b>
	</td>
    <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;">
	
			<cfif (AllowDistributorGroupSearch EQ 0)>
				<input type="checkbox" disabled>
			<cfelse>
				<input type="checkbox" id="check_all_chkBoxFiltersDist_" onclick="checkAll('Customer', 'chkBoxGroupDist_', this.checked);">
			</cfif>	<b>In Group Search<!--- Allow as Group Selection ---></b>&nbsp;&nbsp;
	</td>
	  <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;">
			<!--- Comment by dinesh as per karen suggestion 
				:  REMOVE THE SELECT ALL CHECKBOX TO THE LEFT OF THE ‘ALLOW FILTERS’ COLUMN HEADER NAME.   WE WILL NOT LET THEM MASS SELECT ALL THE CHECKBOXES FOR ‘ALLOW FILTERS’.   
				THIS SHOULD ALSO ADDRESS ISSUE YOU MENTION ABOUT NOT STOPPING THEM AFTER 4 WHEN USER ‘SELECT ALL’.  
			<input type="checkbox" id="check_all_chkBoxFilters_" onclick="checkAll('Customer', 'chkBoxFilters_', this.checked);"> ---><b>Allow Filters</b>
		</td>       
    <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;border-right:1px solid ##93BEE2;">
		<b>Filters</b>
	</td>
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


<input type="hidden" name="groupLevelId" value="" group="Customer"/>
<input type="hidden" name="SelectedFilterGroups" value="" group="Customer"/>
<!--- <input type="hidden" name="bSubmit" value="0" />
<input type="hidden" id="bCustFilterContinue" name="bCustFilterContinue" value="0"/> --->
<cfoutput>
  <!--- <input type="hidden" name="TemplateID" <cfif isDefined("Template_ID") AND Template_ID NEQ "">value="#Template_ID#"<cfelse>value=""</cfif> />
  <input type="hidden" name="PgGroupType" <cfif isDefined("PgGroupType") AND PgGroupType NEQ "">value="#PgGroupType#"<cfelse>value=""</cfif> />
  <input type="hidden" name="TemplateFiltersID" <cfif isDefined("Template_Filters_ID") AND Template_Filters_ID NEQ "">value="#Template_Filters_ID#"<cfelse>value=""</cfif> /> --->
<input type="hidden" name="cusPGGroupType" <cfif isDefined("cusPGGroupType") AND cusPGGroupType NEQ "">value="#cusPGGroupType#"<cfelse>value=""</cfif> group="Customer"/>	
</cfoutput>
<!--- </form> --->
<cfoutput>
<script language="javascript">
function selectCusFiltersPopup(GroupID,TemplateID,TemplateFiltersID)
{
  var actionFrm = document.DataForm;
  var lsValsToDel = "";
  var sURL = "";
  actionFrm.groupLevelId.value=GroupID;
  sURL = "/Search_Screens/DistributorGroup_Search.cfm?fromfilters=1&PageSource=PGFilters&CurrentTemplateID=#ID#&groupLevelId=" + GroupID + "&TemplateID=" + TemplateID + "&FormName=DataForm&FieldName=SelectedFilterGroups&TemplateFiltersID=" + TemplateFiltersID;
  NewWindow(sURL, 'Select_filters', 1000, 800, 'yes', 'yes');
}

function fnCheckMaxNoofDDsInDistSearch(obj)
{

  var maxNoDDs = "#maxDDinDistSearch#";
  var checkedDDs = 0;
  <cfloop query ="qGetTopLevelGroupsList">
		<cfset bAllowInSearch = 0 />
    <cfset bAllowInGroupSearch = 0 />
    <cfset bAllowFilter = 0 />   
    <cfloop query = "qryGetGroupTemplateByTemplateID">
      <cfif qGetTopLevelGroupsList.Distributor_Group_Level_ID EQ  qryGetGroupTemplateByTemplateID.Group_Level_ID>
        <cfset bAllowInSearch = qryGetGroupTemplateByTemplateID.Allow_In_Search />
        <cfset bAllowInGroupSearch = qryGetGroupTemplateByTemplateID.Allow_In_Group_Search />
         <cfset bAllowFilter = qryGetGroupTemplateByTemplateID.Allow_Filter />        
      </cfif>
    </cfloop>
		<cfset displayRec = 0 />
		
		<cfif (qGetTopLevelGroupsList.IS_PG EQ 1) AND (bAllowInSearch EQ 1 OR bAllowInGroupSearch EQ 1)>
			<cfset displayRec = 1 />
		<cfelseif (qGetTopLevelGroupsList.IS_PG EQ 0)>
		 	<cfset displayRec = 1 />
		</cfif>
	 
	 	<cfif displayRec EQ 1>				
	   if( eval("document.all.chkBoxFiltersDist_#qGetTopLevelGroupsList.Distributor_Group_Level_ID#_.checked") == true)
	   {
	    checkedDDs = checkedDDs + 1;
	   }
		</cfif> 
  </cfloop>

  if (checkedDDs > maxNoDDs)
  {
  alert("Only a maximum of #maxDDinDistSearch# filters are allowed!!")
  obj.checked = false;
  }
 
}
</script>
</cfoutput>
<hr width="720" style="color:800000;margin-left:5px;" align="left" /> 