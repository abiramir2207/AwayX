<!-----------------------------------------------------------------------------

FILE NAME:		operatorFilter.cfm
DESCRIPTION:	
CREATED BY:		08-Feb-2011
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
      			Anand Rao	  08-Feb-2011	Created the file
------------------------------------------------------------------------------> 

<!--- Data insertion script based on the settings during the template creation --->
 
 <cfquery name="qryCheckFilters" datasource="#application.datasource#">
IF( SELECT Count(*) FROM Group_Template WHERE Template_ID = #FirstParentID# AND Deleted = 0  AND PG_Group_Type = 3) = 0
      BEGIN                              
            INSERT  INTO Group_Template ( Template_ID , Group_level_ID, PG_Group_Type,Allow_In_Search,Allow_In_Group_Search,Active, Deleted, Created_Date,Created_By, Updated_From, PG_Flag)
            SELECT DISTINCT #FirstParentID#, Operator_Group_Level_ID,3 as PG_Group_Type,
										  /* 
										  	30525: New template, 'in group search' default OFF/Anand Rao/21-Feb-2012 
											changed the default to be "0"
										  */	
                                          /* CASE WHEN Operator_Group_Level.Active = 1 THEN 1  
                                                 ELSE 0
                                          END AS Allow_In_Group_Search,
                                          CASE WHEN Operator_Group_Level.Search_Filter_on = 1 THEN 1  
                                                 ELSE 0
                                          END AS Allow_In_Search, */
									   	  0 AS Allow_In_Search,
										  0 AS Allow_In_Group_Search,
                                          1 AS Active, 0 as Deleted,  Created_Date, '#REQUEST.AccessStructure.User_ID#','Template Creation' , 
																					CASE WHEN Operator_Group_Level_ID >= 2000 THEN 1
																						ELSE 0 
																					END AS PG_Flag
            FROM  Operator_Group_Level
            WHERE Deleted = 0
            AND     (Search_Filter_ON = 1 OR Active = 1)
      END
</cfquery>  
 

<cfset PGManager = CreateObject("component", "components.settings.PlanningGroups.PlanningGroupsManager").init() /> 
<!--- <cfparam name="form.bOprFilterContinue" type="boolean" default="0"/> --->
 
<cfset TemplateManager = CreateObject("component", "components.programs.template.TemplateManager").init() /> 
<cfset maxDDinOprSearch = PGManager.fnMaxItemsOnOprSearch() />
<cfset OprGroupDataManager = CreateObject("component", "components.operator.Group.DataManager").init() />

<cfif (isDefined("FORM.bSubmit") AND FORM.bSubmit EQ "1")>

<!--- TODO : Check to make sure that whatever the user checked has atleast one record in the customer_group_template_selection --->
 <cfset bSuccess = TemplateManager.fnSaveFilterOperators(
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
<!--- <cfif Form.bOprFilterContinue>
	<cfinclude template="/program_wizard/filter/filter_Next_Page.cfm" />
</cfif> --->
<!--- 
  Distributor_Group_Level Table values:
  Business Segment - 1, Family - 2, Buying Group - 3, Line of Business - 4, Market - 23, Region -	24, Zone - 25
  The below function takes (Active, Include list, exclude List)
  So, we pick only the above values for the dropdown 
---> 

<cfquery name="qryOprList" datasource="#application.datasource#">
  SELECT DISTINCT(Operator_Group_Level_ID) FROM Operator_Group_Level WHERE Active= 1 AND Deleted = 0 
</cfquery>
 
<cfset qGetTopLevelGroupsList = OprGroupDataManager.getOperatorLevelsAll(1, "#ValueList(qryOprList.Operator_Group_Level_ID)#", "") />
<cfset Template_ID = FirstParentID />
<cfset Template_Filters_ID = editTemplateFilter.Template_Filters_Id />
<!--- 
  1 - Product
  2 - Customer
  3 - Operator
--->
<cfset oprPgGroupType = 3 />

<cfset qryGetGroupTemplateByTemplateID = PGManager.fnGetGroupTemplateByTemplateID(Template_ID,oprPgGroupType)/>
<SCRIPT LANGUAGE="JavaScript" SRC="/settings/Planning_groups/_planning_groups.js"></SCRIPT>
<!--- <form name="DataForm" action="" method="post"> --->
<!--- Dev Note: drachala; D28820: Template filters tab has no margins  START             
             Added/Changed:  style="margin: 10px;" to create space around filters table --->
<!--- D29688:Program Wizard Filters page (change table width from 620 to 700--->
<table width="700" cellpadding="2" cellspacing="0" bordercolor="93BEE2" style="margin: 10px;">
	<tr bgcolor="FFCE8">
		<td colspan="100%" bgcolor="FFC99"><font size="2px;"><b><cfoutput>#application.returned_customer_setting.Operator_Label_Singular#</cfoutput> Filters</b></font></td>
	</tr>
  <tr bgcolor="ecfab4" style="height:20px">
    <td style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;"><b>Attribute</b></td>
    <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;"><b>Field in Search</b></td>
    <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;"><b>In Group Search</b></td>
	  <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;"><b>Allow Filters</b></td>       
    <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;border-right:1px solid ##93BEE2;"><b>Filters</b></td>
  </tr>
  <cfoutput>
  <cfset varAdditionalData= ""/>
  <cfloop Query = "qGetTopLevelGroupsList">
    <cfset bAllowInSearch = 0 />
    <cfset bAllowInGroupSearch = 0 />
    <cfset bAllowFilter = 0 />   
    
    <cfloop query = "qryGetGroupTemplateByTemplateID">
      <cfif qGetTopLevelGroupsList.Operator_Group_Level_ID EQ  qryGetGroupTemplateByTemplateID.Group_Level_ID>
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
<cfif (qGetTopLevelGroupsList.IS_PG EQ 1) AND (displayRec EQ 0) AND (PGManager.IsSystemCheck(oprPgGroupType, qGetTopLevelGroupsList.Operator_Group_Level_ID))>
		<cfset displayRec = 1 />
</cfif>
<!--- End Dev Note: drachala; D29686: Program Wizard and Segement Filters for Distributor  --->
	 <cfif displayRec EQ 1>		
      <tr>
        <td style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">#qGetTopLevelGroupsList.Group_Level_Desc#<cfif (qGetTopLevelGroupsList.IS_PG EQ 1)> <b>[PGP]</b></cfif></td>
        <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">
          <input type="Checkbox" name="chkBoxSearchOpr_#qGetTopLevelGroupsList.Operator_Group_Level_ID#_" ID="chkBoxSearchOpr_#qGetTopLevelGroupsList.Operator_Group_Level_ID#_" 
          <cfif (bAllowInSearch EQ 1)>checked</cfif> value="#qGetTopLevelGroupsList.Operator_Group_Level_ID#" />
        </td>
        <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">
          <input type="Checkbox" name="chkBoxGroupOpr_#qGetTopLevelGroupsList.Operator_Group_Level_ID#_" ID="chkBoxGroupOpr_#qGetTopLevelGroupsList.Operator_Group_Level_ID#_" 
            <cfif (bAllowInGroupSearch EQ 1)>checked</cfif> value="#qGetTopLevelGroupsList.Operator_Group_Level_ID#" />
        </td>
		<td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">
    <!--- TODO: put a confirmation message to let the user know that the filters will be erased if, he chose to uncheck the checkbox --->        
          <input type="Checkbox" name="chkBoxFiltersOpr_#qGetTopLevelGroupsList.Operator_Group_Level_ID#_" ID="chkBoxFiltersOpr_#qGetTopLevelGroupsList.Operator_Group_Level_ID#_" 
            <cfif (bAllowFilter EQ 1)>checked</cfif> value="#qGetTopLevelGroupsList.Operator_Group_Level_ID#" onclick="fnCheckMaxNoofDDsInOprSearch(this);toggleFieldDisplay('chkBoxFiltersOpr_#qGetTopLevelGroupsList.Operator_Group_Level_ID#_','withoutLinkOperator_#qGetTopLevelGroupsList.Operator_Group_Level_ID#','withLinkOperator_#qGetTopLevelGroupsList.Operator_Group_Level_ID#');" />
        </td>        
        <td style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-right:1px solid ##93BEE2;">
        <strong>
            <div id="withLinkOperator_#qGetTopLevelGroupsList.Operator_Group_Level_ID#" <cfif bAllowFilter EQ 0>style="display:none;"</cfif> align="center">          
             <b>[
						 <cfif LockedBy_Current_User EQ 1> 
						 		<a href="##" onclick="javascript:selectOprFiltersPopup(#qGetTopLevelGroupsList.Operator_Group_Level_ID#,#Template_ID#,#Template_Filters_ID#);return false;">
						  <cfelse>
						 		<a href="##" onclick="javascript:alert('Template should be in edit mode to Select Filters!');return false;">
						 	</cfif>
						 Select Filters</a> ] 
						 </b>
            </div>
            <div id="withoutLinkOperator_#qGetTopLevelGroupsList.Operator_Group_Level_ID#" <cfif bAllowFilter EQ 1>style="display:none;"</cfif> align="center" title="Check Allow Filters to Select Filters">          
              <b> [ Check Filters ]</b>
            </div>
            </strong>
        </td>        
      </tr>
	<cfelse><!--- cfelse for <cfif displayRec EQ 1> --->
		<cfsavecontent variable = "varAdditionalData">
			#varAdditionalData#
			<tr>
	        <td style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">#qGetTopLevelGroupsList.Group_Level_Desc#<cfif (qGetTopLevelGroupsList.IS_PG EQ 1)> <b>[PGP]</b></cfif></td>
	        <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">
	          <input type="Checkbox" name="chkBoxSearchOpr_#qGetTopLevelGroupsList.Operator_Group_Level_ID#_" ID="chkBoxSearchOpr_#qGetTopLevelGroupsList.Operator_Group_Level_ID#_" 
	          <cfif (bAllowInSearch EQ 1)>checked</cfif> value="#qGetTopLevelGroupsList.Operator_Group_Level_ID#" />
	        </td>
	        <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">
	          <input type="Checkbox" name="chkBoxGroupOpr_#qGetTopLevelGroupsList.Operator_Group_Level_ID#_" ID="chkBoxGroupOpr_#qGetTopLevelGroupsList.Operator_Group_Level_ID#_" 
	            <cfif (bAllowInGroupSearch EQ 1)>checked</cfif> value="#qGetTopLevelGroupsList.Operator_Group_Level_ID#" />
	        </td>
			<td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;">
	    <!--- TODO: put a confirmation message to let the user know that the filters will be erased if, he chose to uncheck the checkbox --->        
	          <input type="Checkbox" name="chkBoxFiltersOpr_#qGetTopLevelGroupsList.Operator_Group_Level_ID#_" ID="chkBoxFiltersOpr_#qGetTopLevelGroupsList.Operator_Group_Level_ID#_" 
	            <cfif (bAllowFilter EQ 1)>checked</cfif> value="#qGetTopLevelGroupsList.Operator_Group_Level_ID#" onclick="fnCheckMaxNoofDDsInOprSearch(this);toggleFieldDisplay('chkBoxFiltersOpr_#qGetTopLevelGroupsList.Operator_Group_Level_ID#_','withoutLinkOperator_#qGetTopLevelGroupsList.Operator_Group_Level_ID#','withLinkOperator_#qGetTopLevelGroupsList.Operator_Group_Level_ID#');" />
	        </td>        
	        <td style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-right:1px solid ##93BEE2;">
	        <strong>
	            <div id="withLinkOperator_#qGetTopLevelGroupsList.Operator_Group_Level_ID#" <cfif bAllowFilter EQ 0>style="display:none;"</cfif> align="center">          
	             [
							 <cfif LockedBy_Current_User EQ 1> 
							 		<a href="##" onclick="javascript:selectOprFiltersPopup(#qGetTopLevelGroupsList.Operator_Group_Level_ID#,#Template_ID#,#Template_Filters_ID#);return false;">
							  <cfelse>
							 		<a href="##" onclick="javascript:alert('Template should be in edit mode to Select Filters!');return false;">
							 	</cfif>
							 Select Filters</a> ] 
	            </div>
	            <div id="withoutLinkOperator_#qGetTopLevelGroupsList.Operator_Group_Level_ID#" <cfif bAllowFilter EQ 1>style="display:none;"</cfif> align="center" title="Check Allow Filters to Select Filters">          
	             <b>[ Check Filters ]</b>
	            </div>
	            </strong>
	        </td>        
	      </tr>	  
		</cfsavecontent> 	  
	</cfif>			
</cfloop> 
</cfoutput>

</table>

<fieldset id="border_3" style="border-width:0; border-color:; border-style:solid; width:650"> 
     <legend> 
      <span> 
        <img id="image_3" src="/images/plus2.gif" onclick="switchlayer(3,'Collapse','Expand',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" border="0" alt="" style="cursor:pointer"> 
        
       <font face="Arial"> 
         <span id="title_3" onclick="switchlayer(3,'Collapse','Expand',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" style="cursor:pointer;color:00773c">
          <span title="Click here to toggle the view">
			     <font color="navy">Additional <cfoutput>#application.returned_customer_setting.Operator_Label_Singular#</cfoutput> Attributes</font>
          </span> 
         </span> 
       </font> 
     </legend> 
    <div id="lyrgroup_3" style="display:none; visibility:inherit; z-index:5; margin-left:5; margin-right:5; margin-top:5; margin-bottom:8;"> 

      <div id="masterContainer">   
      <!---- START: Contents Go Here --->
	<table width="700" cellpadding="2" cellspacing="0" bordercolor="93BEE2" style="margin: 10px;">
	  <tr bgcolor="ecfab4" style="height:20px">
    	<td style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;"><b>Attribute</b></td>
	    <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;"><b>Field in Search</b></td>
    	<td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;"><b>In Group Search</b></td>
		  <td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;"><b>Allow Filters</b></td>       
    	<td align="center" style="border-bottom:1px solid ##93BEE2;border-left:1px solid ##93BEE2;border-top:1px solid ##93BEE2;border-right:1px solid ##93BEE2;"><b>Filters</b></td>
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


<input type="hidden" name="groupLevelId" value="" />
<input type="hidden" name="SelectedFilterGroups" value="" />
<!--- <input type="hidden" name="bSubmit" value="0" />
<input type="hidden" id="bOprFilterContinue" name="bOprFilterContinue" value="0"/> --->
<cfoutput>

  <input type="hidden" name="oprPGGroupType" <cfif isDefined("oprPGGroupType") AND oprPGGroupType NEQ "">value="#oprPGGroupType#"<cfelse>value=""</cfif> />

</cfoutput>

<!--- </form> --->
<cfoutput>
<script language="javascript">
function selectOprFiltersPopup(GroupID,TemplateID,TemplateFiltersID)
{
  var actionFrm = document.DataForm;
  var lsValsToDel = "";
  var sURL = "";
  actionFrm.groupLevelId.value=GroupID;
  sURL = "/Search_Screens/OperatorGroup_Search.cfm?PageSource=PGFilters&groupLevelId=" + GroupID + "&TemplateID=" + TemplateID + "&FormName=DataForm&FieldName=SelectedFilterGroups&TemplateFiltersID=" + TemplateFiltersID;
  NewWindow(sURL, 'Select_filters', 1000, 800, 'yes', 'yes');
}

<!--- 
/* function fnTemplateFiltersSave()
{ 
  var actionFrm = document.DataForm;
  actionFrm.bSubmit.value = "1";
  actionFrm.submit();
} 
*/
--->

function fnCheckMaxNoofDDsInOprSearch(obj)
{

  var maxNoDDs = "#maxDDinOprSearch#";
  var checkedDDs = 0;
  <cfloop query ="qGetTopLevelGroupsList">
		<cfset bAllowInSearch = 0 />
    <cfset bAllowInGroupSearch = 0 />
    <cfset bAllowFilter = 0 />   
    <cfloop query = "qryGetGroupTemplateByTemplateID">
      <cfif qGetTopLevelGroupsList.Operator_Group_Level_ID EQ  qryGetGroupTemplateByTemplateID.Group_Level_ID>
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
	   if( eval("document.all.chkBoxFiltersOpr_#qGetTopLevelGroupsList.Operator_Group_Level_ID#_.checked") == true)
	   {
	    checkedDDs = checkedDDs + 1;
	   }
	 </cfif>	
  </cfloop>

  if (checkedDDs > maxNoDDs)
  {
  alert("Only a maximum of #maxDDinOprSearch# filters are allowed!!")
  obj.checked = false;
  }
 
}

</script>
</cfoutput>
<hr width="720" style="color:800000;margin-left:5px;" align="left" /> 