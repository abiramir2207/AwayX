<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\distributors.cfm
      Date:     June 10, 2011
      Author:   Chris Nguyen
      Purpose:  Add/Edit distributors for an accrual budget
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="form.distpg_list"      default="">     <!---distributor planning groups list--->
<cfparam name="form.distindv_list"    default="">     <!---individual distributors list--->
<cfparam name="form.show_dpg"         default="1">    <!---show/hide distributor planning groups indicator--->
<cfparam name="form.ExistingDistPGList" default="">
<cfparam name="form.cutDistPG" default="">
<cfparam name="form.ExistingIndvDistList" default="">
<cfparam name="form.cutIndvDist" default="">

<cfsavecontent variable="vars.htmlHead">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<link rel="stylesheet" type="text/css" href="/common_files/impromptu.css">
<style>
.action { font-weight:bold; }
.fieldset2 { padding:1%; border:0 none; border-top:#cccccc 1px solid; width:98%}
.legend2 { margin:0.5em; padding:0 1.5em; background:transparent; color:#003366; font-size:1.1em; font-weight:bold; }
.legend2 a { font-size:8pt; margin-left:10px; }
</style>
</cfsavecontent>
<cfhtmlhead text="#vars.htmlHead#">

<cfif form.clicked_save eq "1">
  <cfset saveDistributors()>
  <script type="text/javascript">
    <!---place the next tab command here--->
    document.forms[budget_form].command.value = "editProducts";
    <!---turn loading from db flag on for next tab--->
    document.forms[budget_form].load_fromdb.value  = "1";
    <!---close this page--->
    document.forms[budget_form].submit();
  </script>
</cfif>

<cfif form.load_fromdb eq "1">
  <cfset loadDistributors()>
</cfif>

<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="actionFormat.cfm">
<!--------------------------------------------------------------------------------------------------------------------->

<div style="margin:0px">
<fieldset id="mainfieldset" style="padding:1%; width:98%; border: 1px solid blue;">
  <legend style="font: bold 14px sans-serif; color: red;">Budget - Distributors</legend>

<cfoutput>
<!----- selected distributors & distributor planning groups are saved in these hidden form elements ----->
<input type="hidden" name="distpg_list"     value="#form.distpg_list#" />
<input type="hidden" name="distindv_list"   value="#form.distindv_list#" />
<input type="hidden" name="show_dpg"        value="#form.show_dpg#" />    <!---show/hide distributor planning groups indicator--->

<input type="hidden" name="ExistingDistPGList" value="#form.distpg_list#" />
<input type="hidden" name="cutDistPG" value="" />
<input type="hidden" name="ExistingIndvDistList" value="#form.distindv_list#" />
<input type="hidden" name="cutIndvDist" value="" />

<!--------------------------------------------------------------------------------------------------------------------->

<cfquery name="qBudget" datasource="#application.datasource#">
    SELECT Budget_desc
           , Budget_Code
           , Business_Segment_ID
      FROM Budget
     WHERE Budget.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
</cfquery>
<cfscript>
   vars = {};
   form.Budget_Code  = qBudget.Budget_Code;
   form.Budget_desc  = qBudget.Budget_desc;
</cfscript>

<!--- form.distpg_list = comma-delimited list of all selected groups --->
<cfquery name="qGroups" Datasource="#application.datasource#">
  SELECT pgt.pg_Type_Id
         , pgt.pg_Type_Code
         , pgt.pg_Type_Name
         , pg_Customer_Category_Id
         , pg_Customer_Category_Code
         , pg_Customer_Category_Name
    FROM pg_Customer_Category pgcc
         INNER JOIN pg_type pgt ON pgcc.pg_Type_Id = pgt.pg_Type_Id
   WHERE <cfif Len(form.distpg_list)>
           pgcc.pg_Customer_Category_Id IN ( <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.distpg_list#" list="true"> )
         <cfelse>
           1 = 0
         </cfif>
</cfquery>

<!--------------------------------------------------------------------------------------------------------------------->

<cfinclude template="displayBudgetHeading.cfm">
<cfset displayBudgetHeading( form.Budget_Id )>

 <cfset vars.hide = LCase(ActionText("hide"))>
 <cfset vars.show = LCase(ActionText("show"))>
 <cfif form.show_dpg eq 1>
   <cfset vars.action = vars.hide>
 <cfelse>
   <cfset vars.action = vars.show>
 </cfif>

<fieldset class="fieldset2">
<legend class="legend2">Distributor Planning Groups <a href="##" id="animate">#vars.action#</a></legend>

<div id="dpg">
<!----- add distributor link & datagrid ----->
<div id="position" style="margin-top:5px">
  <CFIF Get_Profile_Settings.Create_Budget eq 0 >
    #LCase(ActionText("add distributor planning groups"))#
    #LCase(ActionText("save"))#
  <CFELSE>
    <a href="javascript:add_groups()">#LCase(ActionText("add distributor planning groups"))#</a>
    <a href="javascript:savedistributors()" style="margin:30px">#LCase(ActionText("save"))#</a>
  </CFIF>
<a href="javascript:window.location='index.cfm?bySearch=#url.bySearch#&byClassIDs=#url.byClassIDs#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#url.byGroupIDs#&byBudgetTypeIDs=#url.byBudgetTypeIDs#&bySegmentIDs=#url.bySegmentIDs#'">#LCase(ActionText("return to budgets list"))#</a>
</div>
</cfoutput>

<div style="width:99%;margin-top:10px;clear:both">
<table class="datagrid" id="groupgrid">
<thead><tr>
<cfoutput><th><nobr><img id="scissorAllPG" bDelete="true" sMessage="delete all checked distributor pg" src="/images/scissor.gif" title="delete all checked distributor pg" border="0" onclick="deleteAllDistributorPGOptions();"
                     style="cursor: pointer;">
					 <input name="distPGCheck" type="checkbox" onClick="checkDistPGBoxes();" checked></nobr> <!--- 'distPGCheck','distPGChkBx' --->
					 </th>
</cfoutput>
<th>Planning Group Code</th> <th>Name</th> <th>Type</th> <!--- <th>Action</th> ---><th>Members</th></tr></thead>
<tbody>
<cfsetting enablecfoutputonly="true" >
<cfloop query="qGroups">
<cfoutput><tr id=#qGroups.CurrentRow#></cfoutput>
<cfoutput>
		<td>
		<CFIF Get_Profile_Settings.Create_Budget eq 0 >
		<span class="imgDeleteScissor">
			<img bDelete="true" name="IMG_Delete_Scissor"  src="/images/scissor.gif"
	                	title="click here to delete this distributor pg" border="0"
	                    style="cursor: pointer;">
				</span> 
		<cfelse>
			<nobr>
				<span class="imgDeleteScissor">
	            	<img bDelete="true" name="IMG_Delete_Scissor"  src="/images/scissor.gif"
	                	title="click here to delete this distributor pg" border="0"
	                    onclick="deleteDistPG('#qGroups.CurrentRow#','#qGroups.pg_Customer_Category_Id#')"
	                    style="cursor: pointer;">
				</span>  <input name="distPGChkBx_#qGroups.CurrentRow#" type="checkbox" value="#qGroups.CurrentRow#" tabindex="-1" checked>
			</nobr>
			</cfif>
		</td>										 
</cfoutput>
<cfoutput><td>#qGroups.pg_Customer_Category_Code#</td></cfoutput>
<cfoutput><td>#qGroups.pg_Customer_Category_Name#</td></cfoutput>
<cfoutput><td>#qGroups.pg_Type_Name#</td></cfoutput>
<!--- <cfoutput><td class="g1" id=#qGroups.PG_Customer_Category_ID#><CFIF Get_Profile_Settings.Create_Budget eq 0 >#ActionText("delete")#<CFELSE><a href="javascript:deleteDistPG('#qGroups.CurrentRow#','#qGroups.pg_Customer_Category_Id#')" class="action">#ActionText("delete")#</a></CFIF></td></cfoutput> --->
<cfoutput><td class="g1">&nbsp;<a href="##" onclick="javascript:fnViewMicroMembers(2,'#qGroups.PG_Customer_Category_ID#','');"><img src="/images/on_the_program_item.gif" border="0"></a></td></cfoutput>
<cfoutput></tr></cfoutput>
</cfloop>
<cfsetting enablecfoutputonly="false" >
</tbody>
</table>
</div>

</div>  <!---dpg--->
</fieldset>

<!--------------------------------------------------------------------------------------------------------------------->
<fieldset class="fieldset2">
<cfoutput>
<legend class="legend2">#application.returned_customer_setting.Distributor_Label_Plural#</legend>
<div id="position" style="margin-top:5px">
  <CFIF Get_Profile_Settings.Create_Budget eq 0 >
    #LCase(ActionText("add " & application.returned_customer_setting.Distributor_Label_Plural))#
    #LCase(ActionText("save"))#
  <CFELSE>
    <a href="javascript:add_distributors()">#LCase(ActionText("add " & application.returned_customer_setting.Distributor_Label_Plural))#</a>
    <a href="javascript:savedistributors()" style="margin:30px">#LCase(ActionText("save"))#</a>
  </CFIF>
 <a href="javascript:window.location='index.cfm?bySearch=#url.bySearch#&byClassIDs=#url.byClassIDs#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#url.byGroupIDs#&byBudgetTypeIDs=#url.byBudgetTypeIDs#&bySegmentIDs=#url.bySegmentIDs#'">#LCase(ActionText("return to budgets list"))#</a>
</div>
</cfoutput>

<!--- form.distindv_list = comma-delimited list of all selected distributors --->
<cfquery name="qDistributors" Datasource="#application.datasource#">
  SELECT   Name
         , Family_Name
         , Bsa_FoodService_Customers_Id
         , Address_1
         , City
         , State
         , ZipCode
         , Shr_Ship_To
    FROM Bsa_FoodService_Customers
   WHERE
        <cfif Len(form.distindv_list)>
          Bsa_FoodService_Customers_Id IN ( <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.distindv_list#" list="true"> )
        <cfelse>
          1 = 0
        </cfif>
</cfquery>

<div style="width:100%;margin-top:10px;clear:both">
<table class="datagrid" id="distgrid">
<cfsetting enablecfoutputonly="true" >
<cfoutput><thead></cfoutput>
<cfoutput><tr></cfoutput>
<cfoutput><th><nobr><img id="scissorAllDist" bDelete="true" sMessage="delete all checked distributors" src="/images/scissor.gif" title="delete all checked distributors" border="0"
                     onclick="deleteAllDistributorsOptions();"
                     style="cursor: pointer;">
					 <input name="distCheck" type="checkbox" onClick="checkDistBoxes();" checked></nobr>
					 
					 </th>
</cfoutput>					 
<cfoutput><th>#CapFirst(application.returned_customer_setting.Shard_Ship_To_Label)#</th></cfoutput>
<cfoutput><th>Distributor Name</th></cfoutput>
<cfoutput><th>Address</th></cfoutput>
<cfoutput><th>#application.returned_customer_setting.family_name_label_singular#</th></cfoutput>
<!--- <cfoutput><th>Action</th></cfoutput> --->
<cfoutput></tr></cfoutput>
<cfoutput></thead></cfoutput>
<cfoutput><tbody></cfoutput>
<cfloop query="qDistributors">
<cfoutput><tr id=d#qDistributors.CurrentRow#></cfoutput>
<cfoutput>
		<td>
			<nobr>
				<span class="imgDeleteScissor">
	            	<img bDelete="true" name="IMG_Delete_Scissor"  src="/images/scissor.gif"
	                	title="click here to delete this distributor" border="0"
	                    onclick="deleteThisDist('#qDistributors.CurrentRow#','#qDistributors.Bsa_FoodService_Customers_Id#');"
	                    style="cursor: pointer;">
				</span>  <input name="distChkBx_#qDistributors.CurrentRow#" type="checkbox" value="#qDistributors.CurrentRow#" tabindex="-1" checked>
			</nobr>
		</td>										 
</cfoutput>
<cfoutput><td>#qDistributors.Shr_Ship_To#</td></cfoutput>
 <cfoutput><td>#trim(qDistributors.Name)#</td><td>#(trim(qDistributors.Address_1) & '<br>' & trim(qDistributors.City) & ' ' & trim(qDistributors.State) & ' ' & trim(qDistributors.ZipCode))#</td></cfoutput>
 <cfoutput><td>#trim(qDistributors.Family_Name)#</td></cfoutput>
 <!--- <cfoutput><td class="d1" id=#qDistributors.Bsa_FoodService_Customers_Id#><a href="javascript:deleteThisDist('#qDistributors.CurrentRow#','#qDistributors.Bsa_FoodService_Customers_Id#');" class="action">#ActionText("delete")#</a></td></cfoutput> --->
<cfoutput></tr></cfoutput>
</cfloop>
<cfsetting enablecfoutputonly="false" >
</tbody>
</table>
</div>
</fieldset>  <!---distributors--->
</fieldset>
</div>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="loadDistributors" output="false">
  <cfset var vars = {}>
  <cfquery name="vars.distributors" datasource="#application.datasource#">
      SELECT Distributor_Group_ID
        FROM Budget_Distributor
       WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
              AND Distributor_Group_Level_ID = 0
              AND Deleted = 0
  </cfquery>
  <cfset form.distindv_list = ValueList(vars.distributors.Distributor_Group_ID)>

  <cfquery name="vars.groups" datasource="#application.datasource#">
      SELECT Distributor_Group_ID
        FROM Budget_Distributor
       WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
              AND Distributor_Group_Level_ID <> 0
              AND Deleted = 0
  </cfquery>
  <cfset form.distpg_list = ValueList(vars.groups.Distributor_Group_ID)>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="saveDistributors" output="false">
  <cfset var vars = {}>

 <!---   Before1: <cfdump var="#form#" /> --->
<cfif (Trim(Replace(form.DistPG_List,",","","ALL")) EQ "")>
	<cfset form.DistPG_List = form.ExistingDistPGList />
</cfif>
<cfif (Trim(Replace(form.distindv_list,",","","ALL")) EQ "")>
	<cfset form.distindv_list = form.ExistingIndvDistList />
</cfif>
 <!---  Before2: <cfdump var="#form#" /> --->
	<cfif (form.cutDistPG NEQ "")>
	  	<cfset cutDistPGLen = ListLen(form.cutDistPG, ",") />
		<cfloop index = "IDDistPG" list="#form.cutDistPG#"  delimiters=",">
			<cfset form.distpg_list = Replace(form.distpg_list, IDDistPG, "","ALL") />
		</cfloop>
	  </cfif>
	  <cfset form.distpg_list = Replace(form.distpg_list, ",,", ",","ALL") /> 
	  
	 <cfif (form.cutIndvDist NEQ "")>
	  	<cfset cutIndvDistLen = ListLen(form.cutIndvDist, ",") />
		<cfloop index = "IDDist" list="#form.cutIndvDist#"  delimiters=",">
			<cfset form.distindv_list = Replace(form.distindv_list, IDDist, "","ALL") />
		</cfloop>
	  </cfif>
	  <cfset form.distindv_list = Replace(form.distindv_list, ",,", ",","ALL") />  
   
<!--- After: <cfdump var="#form#" /><cfabort> --->
  <cftransaction>
  <!---remove distributors no longer needed--->
<cfloop index = "ID" list="#form.cutIndvDist#"  delimiters=",">  
	<cfif ID NEQ "">  
	  <cfquery name="vars.removals" datasource="#application.datasource#">
	    UPDATE Budget_Distributor
	       SET Deleted = 1
	     WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
	              AND Distributor_Group_Level_ID = 0
			 <!--- <cfif Len( form.distindv_list )>
	              AND NOT Distributor_Group_ID IN ( <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.distindv_list#" list="true"> )
	           </cfif> --->
			    <cfif Len( ID )>
	            AND Distributor_Group_ID IN ( '#ID#' )
	           </cfif>
	  </cfquery>
	</cfif>
 </cfloop>	  
  <!----- Save selected distributors ----->
  <cfloop list="#form.distindv_list#" index="vars.distributor_id">
    <!---does the row exist? if it does is it flagged as deleted?--->
    <cfquery name="vars.rowExists" datasource="#application.datasource#">
      SELECT Deleted
        FROM Budget_Distributor
       WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
              AND Distributor_Group_Level_ID = 0
              AND Distributor_Group_ID = <cfqueryparam value="#vars.distributor_id#" cfsqltype="cf_sql_varchar">
    </cfquery>
    <!---row does not exist, create one--->
    <cfif vars.rowExists.recordCount eq 0>
      <cfquery name="vars.saveRow" datasource="#application.datasource#">
        INSERT INTO  Budget_Distributor
          ( Budget_ID
          , Distributor_Group_Level_ID
          , Distributor_Group_ID
          )
          VALUES
          ( <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
          , 0
          , <cfqueryparam value="#vars.distributor_id#" cfsqltype="cf_sql_varchar">
          )
      </cfquery>
    <!---row was previously flagged as deleted--->
    <cfelseif vars.rowExists.Deleted eq "1">
      <cfquery name="vars.undelete" datasource="#application.datasource#">
        UPDATE Budget_Distributor
           SET Deleted = 0
         WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
                  AND Distributor_Group_Level_ID = 0
                  AND Distributor_Group_ID = <cfqueryparam value="#vars.distributor_id#" cfsqltype="cf_sql_varchar">
      </cfquery>
    </cfif>
  </cfloop>
  
  <!---remove groups no longer needed--->
<cfloop index = "ID" list="#form.cutDistPG#"  delimiters=",">  
	<cfif ID NEQ "">  
	  <cfquery name="vars.removals" datasource="#application.datasource#">
	    UPDATE Budget_Distributor
	       SET Deleted = 1
	     WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
	              AND Distributor_Group_Level_ID <> 0
	           <!--- <cfif Len( form.distpg_list )>
	              AND NOT Distributor_Group_ID IN ( <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.distpg_list#" list="true"> )
	           </cfif> --->
			    <cfif Len( ID )>
	            AND Distributor_Group_ID IN ( '#ID#' )
	           </cfif>
	  </cfquery>
	</cfif>
 </cfloop>
  <!----- Save selected groups ----->
  <cfloop list="#form.distpg_list#" index="vars.group_id">
    <!---does the row exist? if it does is it flagged as deleted?--->
    <cfquery name="vars.rowExists" datasource="#application.datasource#">
      SELECT Deleted
        FROM Budget_Distributor
       WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
              AND Distributor_Group_Level_ID <> 0
              AND Distributor_Group_ID = <cfqueryparam value="#vars.group_id#" cfsqltype="cf_sql_varchar">
    </cfquery>
    <cfquery name="vars.PG_Customer_Category" datasource="#application.datasource#">
      SELECT PG_Type_ID
        FROM PG_Customer_Category
       WHERE PG_Customer_Category_ID = <cfqueryparam value="#vars.group_id#" cfsqltype="cf_sql_varchar">
    </cfquery>
    <!---row does not exist, create one--->
    <cfif vars.rowExists.recordCount eq 0> 8
      <cfquery name="vars.saveRow" datasource="#application.datasource#">
        INSERT INTO  Budget_Distributor
          ( Budget_ID
          , Distributor_Group_Level_ID
          , Distributor_Group_ID
          )
          VALUES
          ( <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
          , <cfqueryparam value="#vars.PG_Customer_Category.PG_Type_ID#" cfsqltype="cf_sql_integer">
          , <cfqueryparam value="#vars.group_id#" cfsqltype="cf_sql_varchar">
          )
      </cfquery>
    <!---row was previously flagged as deleted--->
    <cfelseif vars.rowExists.Deleted eq "1">
      <cfquery name="vars.undelete" datasource="#application.datasource#">
        UPDATE Budget_Distributor
           SET Deleted = 0
         WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
                  AND Distributor_Group_Level_ID = <cfqueryparam value="#vars.PG_Customer_Category.PG_Type_ID#" cfsqltype="cf_sql_integer">
                  AND Distributor_Group_ID = <cfqueryparam value="#vars.group_id#" cfsqltype="cf_sql_varchar">
      </cfquery>
    </cfif>
  </cfloop>
  <cfquery name="vars.saveRow" datasource="#application.datasource#">
    <cfinclude template="last_update.cfm">       <!--- 36874 --->
  </cfquery>
  <cfinclude template="validateAccrual.cfm">
  </cftransaction>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<!---<script type="text/javascript" src="/Script/javascript/jquery.dataTables.min.js"></script>--->
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<!---<script type="text/javascript" src="/Script/javascript/jquery.cfjs.min.js"></script>--->

<script type="text/javascript">
<!--- turn off loading from db flag --->
document.forms[budget_form].load_fromdb.value  = "0";
<cfif form.show_dpg eq '0'>
  <!---needs to show and then hide immediately otherwise the table would not be fully expanded 100%--->
  $('#dpg').hide( 2 );
</cfif>
var distributors = $('table#distgrid').dataTable({
	 "bAutoWidth": true
	,"bPaginate": false
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  ,"sDom": 'ftiS'
  ,"sScrollXInner": "100%"         <!--- value should equal to total of all aoColumns --->
  ,"sScrollY": "300px"             <!--- datagrid height --->
  ,"aaSorting": [[ 0, "asc" ]]
  ,"aoColumns": [  {"sWidth": "4%", "bSortable":false, "bSearchable":false}
  				  , {"sWidth": "25%"}
                  , {"sWidth": "25%"}
                  , {"sWidth": "25%"}
                  //, {"sWidth": "23%"}
                  , {"sWidth": "21%", "bSortable":false, "bSearchable":false} ]
}).fnSetFilteringDelay();
var groups = $('table#groupgrid').dataTable({
	 "bAutoWidth": true
	,"bPaginate": false
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  ,"sDom": 'fti'
  ,"sScrollXInner": "100%"          <!--- value should equal to total of all aoColumns --->
  ,"sScrollY": "300px"              <!--- datagrid height --->
  ,"aaSorting": [[ 0, "asc" ]]      <!--- sort on 1st column --->
  ,"aoColumns": [   {"sWidth": "4%", "bSortable":false, "bSearchable":false}
  				  ,	{"sWidth": "20%"}
                  , {"sWidth": "28%"}
                  , {"sWidth": "28%"}
				  //, {"sWidth": "10%", "bSortable":false, "bSearchable":false} 
                  , {"sWidth": "10%", "bSortable":false, "bSearchable":false} ]
}).fnSetFilteringDelay();
// $('table#groupgrid tr,table#distgrid tr').hover (  function() { $(this).addClass("over"); },  function() { $(this).removeClass("over"); });
$('table#groupgrid tbody, table#distgrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
<!--------------------------------------------------------------------------------------------------------------------->
function add_distributors() {
  <!--- refresh the distributors list --->
  set_distributor_list();
	NewWindow("/billbacks/search_screens/PM_select_distributors.cfm?Formname=" + budget_form
	            + "&FieldName=distindv_list&SelectSingleSearchResultOnly=0&OnlyDistributorsUnderMe=0"
	            + <cfoutput>"&Business_Segment_Id=#qBudget.Business_Segment_ID#"</cfoutput>,
	            "distributorwindow", 850, 600, "yes", "yes");
}
function add_groups() {
  <!--- refresh the groups list --->
  set_group_list();
	NewWindow("/search_screens/distributor_planning_group.cfm?Formname=" + budget_form
	            + <cfoutput>"&Business_Segment_Id=#qBudget.Business_Segment_ID#"</cfoutput>
	            + "&FieldName=distpg_list", "groupwindow", 850, 600, "yes", "yes");
}
<!--------------------------------------------------------------------------------------------------------------------->
function d1( tr_id ) {
  distributors.fnDeleteRow( $('#' + tr_id)[0] );
}
function g1( tr_id ) {
  groups.fnDeleteRow( $('#' + tr_id)[0] );
}
<!--------------------------------------------------------------------------------------------------------------------->
function hideshow() {
  <!---currently shown hide it now--->
  if (document.forms[budget_form].show_dpg.value == 1) {
    $('#dpg').hide(400);
    $('#hideshow_dpg').html(<cfoutput>"#vars.show#"</cfoutput>);
    document.forms[budget_form].show_dpg.value = 0;
  }
  else {
    <!---currently hidden show it now--->
    $('#dpg').show(400);
    $('#hideshow_dpg').html(<cfoutput>"#vars.hide#"</cfoutput>);
    document.forms[budget_form].show_dpg.value = 1;
  }
}
<!--------------------------------------------------------------------------------------------------------------------->
function savedistributors() {
  <!---update lists of selected rows--->
  set_distributor_list();
  set_group_list();
  <!--- bring back all rows including hidden ones to save --->
  distributors.fnFilter('');
  groups.fnFilter('');
  <cfoutput>
  document.forms[budget_form].action = 'index.cfm?bySearch=#url.bySearch#&byClassIDs=#url.byClassIDs#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#url.byGroupIDs#&byBudgetTypeIDs=#url.byBudgetTypeIDs#&bySegmentIDs=#url.bySegmentIDs#';
  </cfoutput>
  document.forms[budget_form].clicked_save.value = "1";
  document.forms[budget_form].submit();
}
<!--------------------------------------------------------------------------------------------------------------------->
function set_distributor_list() {
  <!---find all nodes (includes hidden) with d1 class, gather all id values & join them together--->
  document.forms[budget_form].distindv_list.value = $('.d1', distributors.fnGetNodes()).map(function() { return this.id; } ).get().join(',');
}
function set_group_list() {
  <!---find all nodes (includes hidden) with g1 class, gather all id values & join them together--->
  document.forms[budget_form].distpg_list.value = $('.g1', groups.fnGetNodes()).map(function() { return this.id; } ).get().join(',');
}
$('#animate').click(function () {
 if (document.forms[budget_form].show_dpg.value == 1) {
   $('#animate').html( <cfoutput>"#vars.show#"</cfoutput> );
   document.forms[budget_form].show_dpg.value = 0;
 }
 else {
   $('#animate').html( <cfoutput>"#vars.hide#"</cfoutput> );
   document.forms[budget_form].show_dpg.value = 1;
 }
 $('#dpg').animate({ opacity:'toggle', height:'toggle' }, 'slow');
});

/*  
 	D111339 - Budget setting page - modifications
	 	- By default the distributor planning group section should be set to 'show'.
*/
//$("#animate").trigger("click");   // hide distributor planning groups so users can see the list of distributors
 
function checkDistPGBoxes()
{
	var elemColctn = document.forms[budget_form].getElementsByTagName("input");
	for (var i = 0; i<elemColctn.length; i++)
	{
		if ((elemColctn[i].name.indexOf('distPGChkBx') > -1))
		{
			if (elemColctn.distPGCheck.checked)
				elemColctn[i].checked = true;
			else
				elemColctn[i].checked = false;
        }
    }
}
function checkDistBoxes()
{
	var elemColctn = document.forms[budget_form].getElementsByTagName("input");
	for (var i = 0; i<elemColctn.length; i++)
	{
		if ((elemColctn[i].name.indexOf('distChkBx') > -1))
		{
			if (elemColctn.distCheck.checked)
				elemColctn[i].checked = true;
			else
				elemColctn[i].checked = false;
        }
    }
}


function deleteAllDistributorPGOptions()
{
		var sHtml;
		var bAllowOptionB = 0;
		var scissorObj = event.srcElement;
		var bDelete = scissorObj.getAttribute('bDelete');

		// $('input[type=checkbox]').attr('checked');
		var checked = $("#groupgrid input[type=checkbox]:checked").length; 

		if (checked == '0')
		{
			var elemColctn = document.forms[budget_form].getElementsByTagName("input");
			for (var i = 0; i<elemColctn.length; i++)
			{
				if ((elemColctn[i].name.indexOf('distPGChkBx_') > -1))
				{
						elemColctn[i].checked = true;
		        }
		    }
		}
		
		<cfif qGroups.RecordCount EQ 0>
			$.prompt('There are no distributor PGs to delete' );
			return;
		</cfif>

		if( bDelete == 'true'){ 

			sHtml = 'Delete all checked Distributor PGs?';
			
			$.prompt(sHtml,
				{
				buttons: {"Yes":1,Cancel:0 }
				,callback: function(save, m, f){
					if(save == 1){
						//Only deletes checked products
						deleteAllDistPG('distPGChkBx_', scissorObj);  
					}
 
					else {
						return false;
					}
				}
			});
		}
		else { // Only one option

			if(bDelete == 'true') {sHtml = 'Delete all checked distributor PGs?';}
			else  {sHtml = 'Undelete all checked distributor PGs?';}

				$.prompt(sHtml,
				{
				buttons: {"Yes":1, Cancel:0 }
				,callback: function(save, m, f){
					if(save == 1){
						//Only deletes checked products
						deleteAllDistPG('distChkBx_', scissorObj); 
					}
					else {
						return false;
					}
				}
			}); 
		}

}

function deleteAllDistPG(chNameStart, scissorObj)
{
	var checkCheckbox = 'false';
	// set_group_list();
	var FINALITEMLIST = document.BudgetForm.distpg_list.value;
	
	 var itemCount = FINALITEMLIST.split(",");
	if(chNameStart)
	{
		checkCheckbox = 'true';
	}
	
 
	var deleteObjs = document.getElementsByName("IMG_Delete_Scissor");
	var i, deleteObjLen;
	var bDelete = scissorObj.getAttribute('bDelete');
	var deletedProdCount = 0;

	deleteObjLen = deleteObjs.length;

	if(deleteObjLen)
	{
		for(i=0;i<deleteObjLen;i++)
		{
			if(bDelete + "" == deleteObjs[i].getAttribute('bDelete') + "")
			{
				if(bDelete == 'false' || checkCheckbox == 'false' || checkboxIsChecked(chNameStart, deleteObjs[i]))
				{
					/* Count how many products are checked for deletion. */
					deletedProdCount = deletedProdCount + 1;
				}
			}
		}
	}
	if(deleteObjLen)
	{
		for(i=deleteObjLen-1;i>=0;i--)
		{
			if(bDelete + "" == deleteObjs[i].getAttribute('bDelete') + "")
			{
				if(bDelete == 'false' || checkCheckbox == 'false' || checkboxIsChecked(chNameStart, deleteObjs[i]))
				{
					deleteObjs[i].click();
				}
			}
		}
	}
	else
	{
		if(bDelete + "" == deleteObjs.getAttribute('bDelete') + "")
		{
			if(bDelete == 'false' || checkCheckbox == 'false' || checkboxIsChecked(chNameStart, deleteObjs))
			{
				deleteObjs.click();
			}
		}
	}
	if(bDelete == 'true')
	{
		scissorObj.title = "undo " + scissorObj.getAttribute('sMessage');
		scissorObj.src = undodeleteImg.src;
	}
	else
	{
		scissorObj.title = scissorObj.getAttribute('sMessage');
		scissorObj.src = deleteImg.src;
	}
	/* The reason why "bDelete" is a string and not a boolean is because "setAttribute" can only set a string value and not a boolean. */
	scissorObj.setAttribute('bDelete',(bDelete == 'true'?'false':'true'));
}	

	function deleteDistPG(curRow,pgCatID)
	{
		var srcObj = event.srcElement;
		var trObj = getParentObject(srcObj, "tr");
		var trIndex = trObj.rowIndex;
		var FINALITEMLIST = document.forms[budget_form].distpg_list.value;
		var TOTALITEMLIST = document.forms[budget_form].ExistingDistPGList.value;
		var CurCutItems = document.forms[budget_form].cutDistPG.value;
		var itemCount = FINALITEMLIST.split(",");
		var bDelete = srcObj.getAttribute('bDelete');
		var resultString = FINALITEMLIST;

		var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";
		 		
		if(trObj){
			if(bDelete == 'true'){
				trObj.height = trObj.offsetHeight;
					trObj.setAttribute('bgcolor', 'DDDDDD');
				propogateProperty(trObj, "style.textDecoration", "line-through", true);

				srcObj.title = "Deleted";
				srcObj.src = undodeleteImg.src;
				CurCutItems = ListAppendItem(CurCutItems, ",", pgCatID);
				resultString = ListDeleteItem(FINALITEMLIST, ",", pgCatID);	
			}	
			else{
				trObj.setAttribute('bgcolor', 'FFFFFF');
				propogateProperty(trObj, "style.textDecoration", "none", false);
				srcObj.title = "delete this distributor PG";
				srcObj.src = deleteImg.src;
				CurCutItems = ListDeleteItem(CurCutItems, ",", pgCatID)
				resultString = ListAppendItem(FINALITEMLIST, ",", pgCatID);
			}
			srcObj.setAttribute('bDelete',(bDelete == 'true'?'false':'true'));
			trObj.setAttribute('bDelete',(bDelete == 'true'?1:0));
			}
		document.forms[budget_form].cutDistPG.value = CurCutItems;
		document.forms[budget_form].distpg_list.value = resultString;
		document.forms[budget_form].ExistingDistPGList.value = resultString;

	}

	function deleteAllDistributorsOptions()
	{
		var sHtml;
		var bAllowOptionB = 0;
		var scissorObj = event.srcElement;
		var bDelete = scissorObj.getAttribute('bDelete');
		var checked = $("#distgrid input[type=checkbox]:checked").length; 
		if (checked == '0')
		{
			var elemColctn = document.forms[budget_form].getElementsByTagName("input");
			for (var i = 0; i<elemColctn.length; i++)
			{
				if ((elemColctn[i].name.indexOf('distChkBx_') > -1))
				{
						elemColctn[i].checked = true;
		        }
		    }
		}
		
		<cfif qDistributors.RecordCount EQ 0>
			$.prompt('There are no distributors to delete' );
			return;
		</cfif>

		if( bDelete == 'true'){ // bAllowOptionB = 1 and Action=Delete - Option  A and Option B // bAllowOptionB &&
			sHtml = 'Delete all checked Distributors?';
			$.prompt(sHtml,
				{
				buttons: {"Yes":1,Cancel:0 }
				,callback: function(save, m, f){
					if(save == 1){
						//Only deletes checked products
						deleteAllIndvDist('distChkBx_', scissorObj); // 
					}
 
					else {
						return false;
					}
				}
			});
		}
		else { // Only one option
			if(bDelete == 'true') {sHtml = 'Delete all checked distributors?';}
			else  {sHtml = 'Undelete all checked distributors?';}
				$.prompt(sHtml,
				{
				buttons: {"Yes":1, Cancel:0 }
				,callback: function(save, m, f){
					if(save == 1){
						//Only deletes checked products
						deleteAllIndvDist('distChkBx_', scissorObj); 
					}
					else {
						return false;
					}
				}
			}); 
		}

}

function deleteAllIndvDist(chNameStart, scissorObj)
{
	var checkCheckbox = 'false';
	var FINALITEMLIST = document.BudgetForm.distindv_list.value;
	if(chNameStart)
	{
		checkCheckbox = 'true';
	}
	
	var deleteObjs = document.getElementsByName("IMG_Delete_Scissor");
	var i, deleteObjLen;
	var bDelete = scissorObj.getAttribute('bDelete');
	var deletedProdCount = 0;
	deleteObjLen = deleteObjs.length;
	/* if(deleteObjLen)
	{
		for(i=0;i<deleteObjLen;i++)
		{
			if(bDelete + "" == deleteObjs[i].getAttribute('bDelete') + "")
			{
				if(bDelete == 'false' || checkCheckbox == 'false' || checkboxIsChecked(chNameStart, deleteObjs[i]))
				{
					/* Count how many products are checked for deletion. * /
					deletedProdCount = deletedProdCount + 1;
				}
			}
		}
	} */
	if(deleteObjLen)
	{
		for(i=deleteObjLen-1;i>=0;i--)
		{
			if(bDelete + "" == deleteObjs[i].getAttribute('bDelete') + "")
			{
				if(bDelete == 'false' || checkCheckbox == 'false' || checkboxIsChecked(chNameStart, deleteObjs[i]))
				{
					deleteObjs[i].click();
				}
			}
		}
	}
	else
	{
		if(bDelete + "" == deleteObjs.getAttribute('bDelete') + "")
		{
			if(bDelete == 'false' || checkCheckbox == 'false' || checkboxIsChecked(chNameStart, deleteObjs))
			{
				deleteObjs.click();
			}
		}
	}
	if(bDelete == 'true')
	{
		scissorObj.title = "undo " + scissorObj.getAttribute('sMessage');
		scissorObj.src = undodeleteImg.src;
	}
	else
	{
		scissorObj.title = scissorObj.getAttribute('sMessage');
		scissorObj.src = deleteImg.src;
	}
	/* The reason why "bDelete" is a string and not a boolean is because "setAttribute" can only set a string value and not a boolean. */
	scissorObj.setAttribute('bDelete',(bDelete == 'true'?'false':'true'));
}	
	
	function deleteThisDist(curRow,DistID)
	{
		var srcObj = event.srcElement;
		var trObj = getParentObject(srcObj, "tr");
		var trIndex = trObj.rowIndex;
		var FINALITEMLIST = document.forms[budget_form].distindv_list.value;
		var TOTALITEMLIST = document.forms[budget_form].ExistingIndvDistList.value;
		var CurCutItems = document.forms[budget_form].cutIndvDist.value;
		var itemCount = FINALITEMLIST.split(",");
		var bDelete = srcObj.getAttribute('bDelete');
		var resultString = FINALITEMLIST;
		var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";
			 		
		if(trObj){
			if(bDelete == 'true'){
				trObj.height = trObj.offsetHeight;
				trObj.setAttribute('bgcolor', 'DDDDDD');
				propogateProperty(trObj, "style.textDecoration", "line-through", true);
				srcObj.title = "Deleted";
				srcObj.src = undodeleteImg.src;
				CurCutItems = ListAppendItem(CurCutItems, ",", DistID);
				resultString = ListDeleteItem(FINALITEMLIST, ",", DistID);	
			}	
			else{
				trObj.setAttribute('bgcolor', 'FFFFFF');
				propogateProperty(trObj, "style.textDecoration", "none", false);
				srcObj.title = "delete this distributor";
				srcObj.src = deleteImg.src;
				CurCutItems = ListDeleteItem(CurCutItems, ",", DistID)
				resultString = ListAppendItem(FINALITEMLIST, ",", DistID);
				}
			srcObj.setAttribute('bDelete',(bDelete == 'true'?'false':'true'));
			trObj.setAttribute('bDelete',(bDelete == 'true'?1:0));
		}
		document.forms[budget_form].cutIndvDist.value = CurCutItems;
		document.forms[budget_form].distindv_list.value = resultString;
		document.forms[budget_form].ExistingIndvDistList.value = resultString;
	}
</script>





