<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

<style>
.activate { background:url('/images/bluechrome.gif') repeat-x; }
.currentfy { float:right; }
</style>
<cfset busSegMgr.obj = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset busSegMgr.isEnabled = busSegMgr.obj.isEnabled()/>
<cfset class_list = VFManager.GVFC() />
<cfset group_list = VFManager.GVFG() />
<cfparam name="edit" default = 0>
<cfparam name="from_db" default="0">
<cfset pg_id = "">
<cfset Dist_id = "">
<cfset Pg_groups_info.Recordcount = 0>
<cfset Dist_groups_info.Recordcount = 0>
<!--- This if statement is used to pull info for selected CLASS --->
<cfif form.clicked_edit>
  <cfset one_plan_info = VFManager.PVFP(#form.clicked_edit#)>
  <cfset form.nextcommand = "new">
  <cfset form.command = "plan">
  <cfset edit = 1>
<cfif form.bsid_remove EQ 0>
  <cfset useLakebaseForPg_groups_info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vf_planning_groups")>
<cfif useLakebaseForPg_groups_info>
	<cftry>
		<cfset Pg_groups_info = application.oLakebase.toQuery(
			application.oLakebase.selectRows("vf_planning_groups", {
				"vf_plan_id" = "eq.#form.clicked_edit#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForPg_groups_info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForPg_groups_info>
<cfquery name="Pg_groups_info" datasource="#application.datasource#">
    SELECT * FROM VF_Planning_Groups WHERE VF_plan_ID = #form.clicked_edit# AND deleted = 0
  </cfquery>
</cfif>

  <cfset useLakebaseForDist_groups_info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vf_distributor_planning_groups")>
<cfif useLakebaseForDist_groups_info>
	<cftry>
		<cfset Dist_groups_info = application.oLakebase.toQuery(
			application.oLakebase.selectRows("vf_distributor_planning_groups", {
				"vf_plan_id" = "eq.#form.clicked_edit#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDist_groups_info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDist_groups_info>
<cfquery name="Dist_groups_info" datasource="#application.datasource#">
    SELECT * FROM VF_Distributor_Planning_Groups WHERE VF_plan_ID = #form.clicked_edit# AND deleted = 0
  </cfquery>
</cfif>
  
  <cfloop query="Pg_groups_info">
      <cfset pg_id = listappend(pg_id, "#Pg_groups_info.PG_Product_Category_ID#")>
    <cfset from_db = 1>
  </cfloop>
  
  <cfloop query="Dist_groups_info">
      <cfset Dist_id = listappend(Dist_id, "#Dist_groups_info.PG_Customer_Category_ID#")>
      <cfset from_db = 1>
  </cfloop> 
</cfif>
</cfif>
<!--- This if statement is used to pull info for selected CLASS --->
<cfif (form.clicked_edit) AND (Pg_groups_info.Recordcount) AND (len(form.prodpg_list))>
  <cfset form.prodpg_list = listappend(pg_id, "#form.prodpg_list#")>
</cfif>

<cfif (form.clicked_edit) AND (Pg_groups_info.Recordcount) AND (len(form.prodpg_list) EQ 0)>
  <cfset form.prodpg_list = "">
  <cfloop query = "Pg_groups_info">
  <cfset form.prodpg_list = Listappend(form.prodpg_list, "#Pg_groups_info.PG_Product_Category_ID#")>
  </cfloop>
  <cfset from_db = 1>
</cfif>

  
<cfif len(form.prodpg_list)>
  <cfset Plan_Groups = VFManager.PPG(1, 0, #form.bsid#)>
  <cfquery name="qPlanGroups" dbtype="query">
    SELECT * FROM Plan_Groups WHERE Category_Id IN (<cfqueryparam value="#trim(form.prodpg_list)#" cfsqltype="cf_sql_varchar" list="yes"/>)
  </cfquery>
</cfif>




<!--- Distributor Plannong groups START --->

<cfif (form.clicked_edit) AND (Dist_groups_info.Recordcount) AND (len(form.distpg_list))>
  <cfset form.distpg_list = listappend(pg_id, "#form.distpg_list#")>
</cfif>

<cfif (form.clicked_edit) AND (Dist_groups_info.Recordcount) AND (len(form.distpg_list) EQ 0)>
  <cfset form.distpg_list = "">
  <cfloop query = "Dist_groups_info">
  	<cfset form.distpg_list = Listappend(form.distpg_list, "#Dist_groups_info.PG_Customer_Category_ID#")>
  </cfloop>
  <cfset from_db = 1>
</cfif>

  
<cfif len(form.distpg_list)>
  <cfset Dist_Groups = VFManager.PPG(2, 0, #form.bsid#)>
  <cfquery name="qDistGroups" dbtype="query">
    SELECT * FROM Dist_Groups WHERE Category_Id IN (<cfqueryparam value="#trim(form.distpg_list)#" cfsqltype="cf_sql_varchar" list="yes"/>)
  </cfquery>
</cfif>

<!--- Distributor Plannong groups END--->




<!--- This if statement is used to Update info for selected CLASS and redirect to main page with class list--->
<cfif form.save_edit>
	<cfif len(form.prodpg_list)>
		<cfset pg_group = 1>
		<cfset list = #trim(form.prodpg_list)#>
	<cfelse>
		<cfset pg_group = 0>
		<cfset list = "">
	</cfif>
  
	<cfif len(form.distpg_list)>
		<cfset Dist_group = 1>
		<cfset Dist_list = #trim(form.distpg_list)#>
	<cfelse>
		<cfset Dist_group = 0>
		<cfset Dist_list = "">
	</cfif>
  
	<cfset dup.volumePlans = VFManager.FindDuplicatePlan(
															id                           = form.save_edit,
															classId                      = val(form.VFPlanClass),
															segmentId                    = val(form.VFPlanSegment),
															forecastLevel                = val(form.VFPlanForecast),
															productPlanningGroupList     = list,
															distributorPlanningGroupList = Dist_list
														)>

	<cfscript>
		VFManager.UVFP(
						id         = form.save_edit,
						number     = form.VFPlanNumber,
						edit       = form.save_edit,
						desc       = form.VFPlanDesc,
						class      = val(form.VFPlanClass),
						group      = val(form.VFPlanGroup),
						segment    = val(form.VFPlanSegment),
						uom        = val(form.VFPlanUOM),
						forecast   = val(form.VFPlanForecast),
						pg_group   = pg_group,
						list       = list,
						Dist_group = Dist_group,
						Dist_list  = Dist_list
					);
	</cfscript>
				
	<!---if there are duplicates display a warning message--->
	<cfif dup.volumePlans.recordCount>
		<cfinclude template="duplicate.cfm">
		<cfabort>
	<cfelse>
		<cflocation url="index.cfm?command=plan&from=plan">
	</cfif>
</cfif>

<!--- This if statement is used to Update info for selected CLASS and redirect to main page with class list--->
<!--- This if statement is used to SAVE NEW PLAN and redirect to main page with class list--->
<cfif form.clicked_save>
  <cfscript>
    VFClass  = VFManager.IVFP(form.VFPlanNumber, form.VFPlanDesc, form.VFPlanClass, form.VFPlanGroup, form.VFPlanSegment, form.VFPlanForecast, form.VFPlanUOM);
  </cfscript>
  <cflocation url="index.cfm?command=plan&from=plan" >
</cfif>
<!--- This if statement is used to SAVE NEW PLAN and redirect to main page with class list--->
<!--- This if statement is used to DELETE selected Plan and redirect to main page with Plan list--->
<cfif form.clicked_delete>
  <cfset VFManager.DVFP(#form.clicked_delete#)>
  <cflocation url="index.cfm?command=plan&from=plan" >
</cfif>

<cfif form.clicked_copy>
  <cfset New_VF_Plan_ID = VFManager.CopyVFP(#form.clicked_copy#)>
  <cflocation url="index.cfm?command=plan&from=plan&clicked_edit=#New_VF_Plan_ID#" >
</cfif>
<!--- This if statement is used to DELETE selected Plan and redirect to main page with Plan list--->
<fieldset style="padding:10px; width: 100%; border: 1px solid blue;">
  <legend style="font: bold 14px sans-serif; color: red;">Volume Plan</legend>

<cfif (form.command EQ "plan") AND (form.nextcommand EQ 0)>
<!---default to show only plans for current year--->
<cfif not structKeyExists(form, 'currentFiscalHidden')>
	<cfset form.currentFiscalHidden = 'on'>
</cfif>
<!---create hidden value for current fiscal year because unchecked value do not get posted--->
<input type="hidden" name="currentFiscalHidden">
<cfoutput>
<br>  
    <cfset plan_list = VFManager.GVFP( form.currentFiscalHidden ) />
    <a href="javascript: clickheader('plan', 'new');" style="font-weight: bold;">#ActionText("create new volume forecast plan")#</a>
	<a href="discrepancy_report.cfm;" style="font-weight: bold;">#ActionText("download discrepancy report")#</a>
	<img src="/images/help_small.gif" onmouseout="popUpTip(event,'discrepancyreport');" onmouseover="popUpTip(event,'discrepancyreport');"/>
	<div id="discrepancyreport" class="tip">
           The discrepancy report provides customers and products with sales activity that are not involved in a current volume forecast.
    </div>
<br><br>    
  <cfsavecontent variable="vars.htmlHead">
  <link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
  <style>
  .action { font-weight:bold; margin:0 3px 0 3px; }
  </style>
  </cfsavecontent>
  
  
  <cfhtmlhead text="#vars.htmlHead#">
  
  <cfscript>
    vars = StructNew();
  </cfscript>
  
  
  <table id="Planlist" class="datagrid">
  <thead>
  <tr>
      <th>Code</th>
      <th>Description</th>
      <th>Class</th>
      <th>Group</th>
    <th>Bus Segment</th>
    <th>Action</th>
  </tr>
  </thead>
  <tbody>
  
  <cfloop query="plan_list">
    <cfset useLakebaseForclass_name = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("class_list")>
<cfif useLakebaseForclass_name>
	<cftry>
		<cfset class_name = application.oLakebase.toQuery(
			application.oLakebase.selectRows("class_list", {
				"vf_class_id" = "eq.#vf_plan_class_id#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForclass_name = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForclass_name>
<cfquery name="class_name" dbtype="query">
      SELECT * FROM class_list WHERE VF_Class_ID = #vf_plan_class_id#
    </cfquery>
</cfif>
    <cfset useLakebaseForgroup_name = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("group_list")>
<cfif useLakebaseForgroup_name>
	<cftry>
		<cfset group_name = application.oLakebase.toQuery(
			application.oLakebase.selectRows("group_list", {
				"vf_group_id" = "eq.#vf_plan_group_id#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgroup_name = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgroup_name>
<cfquery name="group_name" dbtype="query">
      SELECT * FROM group_list WHERE VF_Group_ID = #vf_plan_group_id#
    </cfquery>
</cfif>
    <cfset qSegments = busSegMgr.obj.getActive( userId = request.AccessStructure.User_ID )>
    <cfset useLakebaseForbusiness_segment_name = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qsegments")>
<cfif useLakebaseForbusiness_segment_name>
	<cftry>
		<cfset business_segment_name = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qsegments", {
				"business_segment_id" = "eq.#vf_plan_segment_id#",
				"select" = "business_unit_desc"
			}), "business_unit_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForbusiness_segment_name = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForbusiness_segment_name>
<cfquery name="business_segment_name" dbtype="query" >
      SELECT Business_Unit_Desc FROM qSegments WHERE Business_Segment_ID = #vf_plan_segment_id#
    </cfquery>
</cfif>
  <tr <cfif plan_list.Detail_Record_Count eq 0>class="activate"</cfif>>
   <td>#vf_plan_number#</td>
   <td>#vf_plan_desc#</td>
   <td>#class_name.VF_Class_Desc#</td>
   <td>#group_name.VF_Group_Desc#</td>
   <td>#business_segment_name.Business_Unit_Desc#</td>
   <td><a href="javascript:edit(#VF_Plan_ID#);">#ActionText("edit")#</a>&nbsp;&nbsp;&nbsp;<a href="javascript: deleted(#VF_Plan_ID#);">#ActionText("delete")#</a>&nbsp;&nbsp;&nbsp;<a href="javascript: copy(#VF_Plan_ID#);">#ActionText("copy")#</a></td>
  </tr>
  </cfloop>
  
  </tbody>
  </table>
</cfoutput>



<script type="text/javascript">
var pgrid = $('table#Planlist').dataTable({
     "bAutoWidth": true
    ,"bPaginate": false
    ,"bSortClasses": false
    ,"bScrollCollapse": true
    ,"sDom": 'f<"currentfy">ti'
    ,"sScrollXInner": "100%"
    ,"aaSorting": [[ 0, "asc" ]] 
    ,"aoColumns": [ {"sWidth": "10%"}
                  , {"sWidth": "35%"}
                  , {"sWidth": "15%"}
                  , {"sWidth": "15%"}
                  , {"sWidth": "15%", "bSortable":true,  "bSearchable":false}
                  , {"sWidth": "20%", "bSortable":false, "bSearchable":false} ]
}).fnSetFilteringDelay();
$('div.currentfy').html("<input type='checkbox' name='currentFiscal' <cfif form.currentFiscalHidden eq 'on'>checked</cfif> onclick='reload();'>Filtered by Current Year");
$('table#Planlist tr').hover (
  function() { $(this).addClass("over"); },
  function() { $(this).removeClass("over"); }
);
reload = function() {
	  /* update hidden value for current fiscal year because unchecked value do not get posted */
    document.vforecasting.currentFiscalHidden.value = $('input[name=currentFiscal]').prop('checked') ? "on" : "off";
    document.vforecasting.command.value = "plan";
    document.vforecasting.submit();
}
$('input').bind('focus', function(){ $(this).addClass('hilight'); }).bind('blur', function(){ $(this).removeClass('hilight'); });
$('form input:visible:enabled:first').focus();
<!---new FixedHeader ( grid );--->
function edit(id){
    document.vforecasting.command.value = "EditVFPlan";
    document.vforecasting.clicked_edit.value = id;
    document.vforecasting.submit();
}
function deleted(id){
  if(confirm('Do you really want to delete the selected volume forecast plan?')){
    document.vforecasting.command.value = "DeleteVFPlan";
    document.vforecasting.clicked_delete.value = id;
    document.vforecasting.submit(); 
  }
}
function copy(id){
    document.vforecasting.command.value = "CopyVFPlan";
    document.vforecasting.clicked_copy.value = id;
    document.vforecasting.submit();
}
</script>

<cfelseif (form.command EQ "plan") AND (form.nextcommand EQ "new")>

<cfset class_list = VFManager.GVFC() />
<cfset group_list = VFManager.GVFG() />
<cfquery name="UOM_pull" datasource="#application.datasource#">
  select * from Budget_Units_of_Measure where Budget_Units_of_Measure_ID IN (1, 2, 9) ORDER BY unit_Of_Measure_Desc
</cfquery>

<cfoutput>
  <table border="0">
      <tr>
          <td id="bold">Code:</td>
          <td><input type="text" name="VFPlanNumber" value="<cfif edit AND len(one_plan_info.VF_Plan_Number)>#one_plan_info.VF_Plan_Number#<cfelse></cfif>" size="10" maxlength="10"></td>
    </tr>
      <tr>
        <td id="bold">Description:</td>
          <!---D29683 Wrap value inside quotes to get full description---> 
          <td><input type="text" name="VFPlanDesc" value="<cfif edit AND len(one_plan_info.VF_Plan_Desc)>#one_plan_info.VF_Plan_Desc#</cfif>" size="50" maxlength="50"></td>
    </tr>
    <tr>
          <td id="bold">Class:</td>
          <td>
            <select name="VFPlanClass" style="width:150px;">
              <option value="">Select</option>
        <cfloop query="class_list">
          <option value="#class_list.VF_Class_ID#" <cfif edit AND (one_plan_info.VF_Plan_Class_ID EQ class_list.VF_Class_ID)> Selected</cfif>>#class_list.VF_Class_Desc#</option>
        </cfloop>
            </select>
          </td>
    </tr>
    <tr>
          <td id="bold">Group:</td>
          <td>      
        <select name="VFPlanGroup" style="width:150px;">
              <option value="">Select</option>
        <cfloop query="group_list">
          <option value="#group_list.VF_Group_ID#" <cfif edit AND (one_plan_info.VF_Plan_Group_ID EQ group_list.VF_Group_ID)> Selected</cfif>>#group_list.VF_Group_Desc#</option>
        </cfloop>
            </select>
      </td>
    </tr>
<cfif busSegMgr.isEnabled>
  <cfset qSegments = busSegMgr.obj.getActive( userId = request.AccessStructure.User_ID )>
  <cfset useLakebaseForqSortedSegments = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qsegments")>
<cfif useLakebaseForqSortedSegments>
	<cftry>
		<cfset qSortedSegments = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qsegments", {
				"order" = "business_unit_desc.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqSortedSegments = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqSortedSegments>
<cfquery name="qSortedSegments" dbtype="query">
    SELECT  *
    FROM  qSegments
    ORDER BY BUSINESS_UNIT_DESC
  </cfquery>
</cfif>
  
    <tr>
      <td id="bold">Segment:</td>
      <td>
      <select name="VFPlanSegment" style="width:150px;">
              <option value="">Select</option>
      <cfloop query="qSortedSegments">
          <option value="#qSortedSegments.business_segment_id#" <cfif edit AND (one_plan_info.VF_Plan_Segment_ID EQ qSortedSegments.business_segment_id)> Selected</cfif>>#qSortedSegments.Business_Unit_Desc#</option>
              </cfloop>
      </select>
      </td>
    </tr
    <cfelse>
    <input type="hidden" name="VFPlanSegment" value="0">
</cfif>
    <tr>
      <td id="bold">UOM:</td>
      <td>
        <select name="VFPlanUOM" style="width:150px;">
        <option value="0">Select UOM</option>
<cfloop query="UOM_pull">
                <option value="#budget_units_of_measure_id#" <cfif edit AND (one_plan_info.VF_UOM EQ budget_units_of_measure_id)> Selected</cfif>>#unit_Of_Measure_Desc#</option>
</cfloop>
        </select>
      </td>
    </tr>
    <tr><!--- D30441:Volume Forecasting -- issues START--->
      <td id="bold">Forecast Level:</td>
      <td>
        <select name="VFPlanForecast" style="width:150px;">
          <option value="-1" <cfif edit AND (one_plan_info.Forecast_Level eq -1)> selected </cfif>>Select</option>
          <option value="0"  <cfif edit AND (one_plan_info.Forecast_Level eq 0)>  selected </cfif>>Headquarters</option>
          <option value="1"  <cfif edit AND (one_plan_info.Forecast_Level eq 1)>  selected </cfif>>#application.returned_customer_setting.zone_label_plural#</option>
          <option value="2"  <cfif edit AND (one_plan_info.Forecast_Level eq 2)>  selected </cfif>>#application.returned_customer_setting.region_label_singular#</option>
          <option value="3"  <cfif edit AND (one_plan_info.Forecast_Level eq 3)>  selected </cfif>>#application.returned_customer_setting.market_label_singular#</option>
          <option value="4"  <cfif edit AND (one_plan_info.Forecast_Level eq 4)>  selected </cfif>>#application.returned_customer_setting.distributor_label_singular#</option>
        </select>
      </td>
      </tr><!--- D30441:Volume Forecasting -- issues END--->
    <tr>
      <td colspan="2">&nbsp;</td>
    </tr>
    <!---<cfif edit>
    <tr id="mainfieldset">
      <td style="font: bold 14px sans-serif; color: red; padding:5px;">Products:</td>
    </tr>
    </cfif> --->  
    <tr>
      <td colspan=2>
		 <table>
			<tr>
        		<cfif edit>
					<td>
			        	<a href="javascript:add_prodpg()">#ActionText("add product planning group")#</a> 
			        	&nbsp;&nbsp;&nbsp;&nbsp;
					</td>
					<td>
				        <a href="javascript:add_groups()">#ActionText("add distributor planning group")#</a> 
				        &nbsp;&nbsp;&nbsp;&nbsp;
					</td>
					<td>
			        	<a href="##" id="save_plan">#ActionText("save")#</a>
			        	&nbsp;&nbsp;&nbsp;&nbsp; 
					</td>
			        <td>
						<nobr><span id="calcLink"><a href="javascript:calculate(#one_plan_info.VF_Plan_ID#);" onclick="disableLink(this)">#ActionText("calculate")#</a></span><span id="calcLinkDummy" style="display:none;">#ActionText("calculate")#</span></nobr>
					</td>
		        <cfelse>
					<td>
			        	<a href="javascript:save_plan()">#ActionText("save")#</a>
					</td>
		        </cfif>
				<td>
	        		&nbsp;&nbsp;&nbsp;&nbsp;
	        		<a href="index.cfm?command=plan&from=plan">#ActionText("return to volume forecast plan")#</a>
				</td>
			</tr>
		</table>
      </td>
    </tr>
  </table>
  <link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<cfif (edit AND isdefined("qPlanGroups"))>
<cfsavecontent variable="vars.htmlHead">

<style>
.action { font-weight:bold; margin:0 3px 0 3px; }
</style>
</cfsavecontent>
<cfhtmlhead text="#vars.htmlHead#">
<cfscript>
  vars = StructNew();
</cfscript><br>
<span style="font: bold 12px sans-serif; color: red;">Products Planning Group(s)</span>
<table id="PGroups" class="datagrid">
<thead>
<tr>
    <th>Planning Group Code</th>
    <th>Name</th>
    <th>Type</th>
    <th>Action</th>
</tr>
</thead>
<tbody>
<cfloop query="qPlanGroups">
      <tr>
         <td>#qPlanGroups.Category_Code#</td>
         <td>#qPlanGroups.Category_Name#</td>
         <td>#qPlanGroups.pg_Type_Name#</td>
         <td><a href="javascript:remove_group('#qPlanGroups.Category_ID#','1')">#actiontext("delete")#</a></td>
      </tr>
</cfloop>

</tbody>
</table>
</cfif>

<!--- Distributor Planning groups start --->
<cfif (edit AND isdefined("qDistGroups"))>

<cfsavecontent variable="vars.htmlHead">
<style>
.action { font-weight:bold; margin:0 3px 0 3px; }
</style>
</cfsavecontent>
<cfhtmlhead text="#vars.htmlHead#">
<cfscript>
  vars = StructNew();
</cfscript>
<span style="font: bold 12px sans-serif; color: red;">Distributor Planning Group(s)</span>
<table id="DistGroups" class="datagrid">
<thead>
<tr>
    <th>Planning Group Code</th>
    <th>Name</th>
    <th>Type</th>
    <th>Action</th>
</tr>
</thead>
<tbody>
<cfloop query="qDistGroups">
      <tr>
         <td>#Category_Code#</td>
         <td>#Category_Name#</td>
         <td>#pg_Type_Name#</td>
         <td><a href="javascript:remove_group('#Category_ID#', '2')">#actiontext("delete")#</a></td>
      </tr>
</cfloop>

</tbody>
</table>
</cfif>
<!--- Distributor Plannong groups end --->

<script text="javascript">
  function remove_group(id, type){
    if (type == 1) {
      var list = "#form.prodpg_list#";
      var list = list.replace(id, " ");
      document.vforecasting.prodpg_list.value = list;
      document.vforecasting.distpg_list.value = "#form.distpg_list#";
      document.vforecasting.command.value = "EditVFPlan";
      document.vforecasting.clicked_edit.value = "#form.clicked_edit#";
      document.vforecasting.bsid_remove.value = "1";
      document.vforecasting.submit();
    }
    if (type == 2){
      var list = "#form.distpg_list#";
      var list = list.replace(id, " ");
      document.vforecasting.distpg_list.value = list;
      document.vforecasting.prodpg_list.value = "#form.prodpg_list#";
      document.vforecasting.command.value = "EditVFPlan";
      document.vforecasting.clicked_edit.value = "#form.clicked_edit#";
      document.vforecasting.bsid_remove.value = "1";
      document.vforecasting.submit();
    }
  }
</script>

  </cfoutput>
</cfif> 

</fieldset>
<cfif edit>
<script type="text/javascript">
$('#mainfieldset').css('width', ($(window).width() <= 700) ? "800px" : "100%");
<!---turn off loading from db flag--->
document.vforecasting.load_fromdb.value = "0";
var groups = $('table#groupgrid').dataTable({
   "bAutoWidth": true
  ,"bPaginate": false
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  <!---,"sScrollY": "300px"             <!--- datagrid height --->--->
  ,"sDom": 'fti'
  ,"aaSorting": [[ 0, "asc" ]]     <!--- sort on product planning group column --->
  ,"aoColumns": [   null
                  ,{ "bSortable":false, "bSearchable":false }
                  ,{ "bSortable":false, "bSearchable":false }
                  ]
}).fnSetFilteringDelay();
<!---$(window).resize(function(){ groups.fnAdjustColumnSizing(); });--->
<!---forceNumeric() plug-in implementation--->
$.fn.forceNumeric = function () {
 return this.each(function () {
    $(this).keydown(function (e) {
        var key = e.which || e.keyCode;
        if (!e.shiftKey && !e.altKey && !e.ctrlKey &&
        <!---numbers--->
            ( key >= 48 && key <= 57 ) ||
        <!---Numeric keypad--->
            ( key >= 96 && key <= 105 ) ||
        <!---comma, period and minus--->
           key == 190 || key == 188 || key == 109 ||
        <!---Backspace and Tab and Enter--->
           key == 8 || key == 9 || key == 13 ||
        <!---Home and End--->
           key == 35 || key == 36 ||
        <!---left, up and right, down arrows--->
           ( key >= 37 && key <= 40 ) ||
        <!---Decimal point on numeric keypad---> 
              key == 110 ||              
        <!---Del and Ins--->
           key == 46 || key == 45) {
          return true;
        }
        return false;
    });
 });
}
$(".rate").forceNumeric();
$("input").focus( function() { $(this).parents('tr').addClass( 'over' ); } )
                 .blur( function()  { $(this).parents('tr').removeClass( 'over' ); });
<!--------------------------------------------------------------------------------------------------------------------->
function del( tr_id ) {
  groups.fnDeleteRow( $('#' + tr_id)[0] );
}
<!--------------------------------------------------------------------------------------------------------------------->
<!---include overlay processing: if checked enable overlay purchase min & uom otherwise disable them--->
function overlay_min( inclusion ) {
  <!---locate the parent tr tag--->
  var parent_tr = $( '#' + inclusion.id ).parents('tr');
  parent_tr.find('.orate').attr( 'disabled', !inclusion.checked );
  parent_tr.find('.ouom' ).attr( 'disabled', !inclusion.checked );
}
function add_prodpg() {
//set_group_list();
  document.vforecasting.prodpg_list.value = <cfoutput>"#form.prodpg_list#"</cfoutput>;
  NewWindow("/search_screens/product_planning_group.cfm?Formname=vforecasting"
              + "&FieldName=prodpg_list"
              + <cfoutput>"&Business_Segment_Id=#one_plan_info.VF_Plan_Segment_ID#"</cfoutput>
              , "groupwindow", 850, 600, "yes", "yes");
}
function add_groups() {
  // set_group_list();
  document.vforecasting.distpg_list.value = <cfoutput>"#form.distpg_list#"</cfoutput>;
  NewWindow("/search_screens/distributor_planning_group.cfm?Formname=vforecasting"
              + "&FieldName=distpg_list"
              + <cfoutput>"&Business_Segment_Id=#one_plan_info.VF_Plan_Segment_ID#"</cfoutput>
              , "groupwindow", 850, 600, "yes", "yes");
}
<!--------------------------------------------------------------------------------------------------------------------->
function save_prodpg() {
  var vars = {};
  vars.errors = 0;

  if ( vars.errors > 0 )
    showMessageWindow();
  else {
    set_group_list();
    
    document.forms[vforecasting].action = 'index.cfm';
    document.forms[vforecasting].clicked_save.value = "1";
  document.vforecasting.command.value ="plan";
    //document.forms[vforecasting].submit();
  }
}
<!--------------------------------------------------------------------------------------------------------------------->
function set_group_list() {
  <!---find all nodes (includes hidden) with g1 class, gather all id values & join them together--->
   document.forms[vforecasting].prodpg_list.value = $('.rowid', groups.fnGetNodes()).map(function() { return this.id; } ).get().join(',');
}
$('input').bind('focus', function(){ $(this).addClass('hilight'); }).bind('blur', function(){ $(this).removeClass('hilight'); });
$('form input:visible:enabled:first').focus();
<!---new FixedHeader ( groups );--->
function refresh(id, a, b)
 {
            document.vforecasting.command.value = "EditVFPlan";
          document.vforecasting.clicked_edit.value = <cfoutput>#one_plan_info.VF_Plan_ID#</cfoutput>;
          document.vforecasting.bsid.value = id; 
            document.vforecasting.submit(); 
  }
var ggrid = $('#PGroups').dataTable({
   "bAutoWidth": true
  ,"bPaginate": false
    ,"bSortClasses": false
    ,"bScrollCollapse": true
    ,"sDom": 'fti'
    ,"sScrollXInner": "700px"
    ,"aaSorting": [[ 0, "asc" ]]
    ,"aoColumns": [ {"sWidth": "200px"}
                  , {"sWidth": "200px"}
                  , {"sWidth": "200px", "bSortable":true,  "bSearchable":false}
                  , {"sWidth": "100px", "bSortable":false, "bSearchable":false} ]
}).fnSetFilteringDelay();
$('').hover (
  function() { $(this).addClass("over"); },
  function() { $(this).removeClass("over"); }
);


var submitted = 0,
   dgrid = $('#DistGroups').dataTable({
   "bAutoWidth": true
  ,"bPaginate": false
    ,"bSortClasses": false
    ,"bScrollCollapse": true
    ,"sDom": 'fti'
    ,"sScrollXInner": "100%"
    ,"aaSorting": [[ 0, "asc" ]] 
    ,"aoColumns": [{"sWidth": "200px"}
                  ,{"sWidth": "200px"}
                  ,{"sWidth": "200px", "bSortable":true,  "bSearchable":false}
                  ,{"sWidth": "100px", "bSortable":false, "bSearchable":false}]
}).fnSetFilteringDelay();
$('table#DistGroups tr').hover (
    function() { $(this).addClass("over"); },
    function() { $(this).removeClass("over"); }
);

$('input').bind('focus', function(){ $(this).addClass('hilight'); }).bind('blur', function(){ $(this).removeClass('hilight'); });
$('form input:visible:enabled:first').focus();

$('#save_plan').click( function(e) {
	if (submitted === 1) {
		e.preventDefault();
		return false;
	}
	else {
		submitted = 1;
		$(this).html("<b>[ processing... ]</b>");
		edit_plan(<cfoutput>#one_plan_info.VF_Plan_ID#</cfoutput>);
	}
});


function disableLink(oAnchor)
{
	/*oAnchor.oldonclick = oAnchor.onclick;
	oAnchor.onclick = new Function ("return false;");
	oAnchor.oldCursor = oAnchor.style.cursor;
	oAnchor.style.cursor = "default";
	oAnchor.oldTextDecoration = oAnchor.style.textDecoration;
	oAnchor.style.textDecoration = "none";
	oAnchor.style.color="gray"; */
	document.getElementById("calcLinkDummy").style.color="gray";
	document.getElementById("calcLink").style.display = 'none';
    document.getElementById("calcLinkDummy").style.display = 'block';
	// setTimeout("enableCalculate()",5000);
	
}
function enableCalculate()
{
	document.getElementById("calcLink").style.display = 'block';
    document.getElementById("calcLinkDummy").style.display = 'none';
}

</script>

</cfif>

