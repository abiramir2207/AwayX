<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">

<cfparam name="form.clicked_save" default="0">
<cfparam name="form.load_fromdb"  default="1">
<cfparam name="url.id" 	          default="0">

<cfinvoke component="components.programs.business_segment.BusinessSegmentManager"
    		     method="isEnabled"
     returnVariable="busSegMgr.isEnabled">
</cfinvoke>

<cfscript>
  templateManager = CreateObject("component","components.programs.template.TemplateManager").init();
  template = templateManager.get(url.id);
  Action = "edit";
  pageName = "budget";
  Created_Type = template.getCreatedType();
  Generic_Type = template.getGenericType();
  Active = template.getActive();

  vars = StructNew();
  if ( busSegMgr.isEnabled ) {
   appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
  }
  formlabels = {};
  formlabels.code  = "Code:";
  formlabels.desc  = "Description:";
  formlabels.class = "Class:";
  formlabels.group = "Group:";
  formlabels.segment = "Segment:";
  formlabels.contribution_factor_type = "Budget Type:";
  pagetitle = "PROGRAM WIZARD: BUDGET";
	pageName = "budget";
</cfscript>


<!--------------------------------------------------------------------------------------------------------------------->
<cfquery name="vars.qBudgets" datasource="#application.datasource#">
  SELECT b.Budget_ID
         , b.Budget_Code
         , b.Budget_Desc
         , b.Active
         , b.Budget_Status
         , b.Budget_Dollar
         , b.Committed_Dollar
         , b.Actual_Dollar
         , bcft.Contribution_Factor_Type
         , bcft.Budget_Contribution_Factor_Type_ID
         , bc.Budget_Class_Desc
         , bg.Budget_Group_Desc
         , bs.Business_Unit_Desc
    FROM Budget_Template_Mappings btm
         INNER JOIN Budget b ON b.Budget_ID = btm.Budget_ID AND b.Deleted = 0 AND b.Active = 1
		         <cfif busSegMgr.isEnabled and appSettings.getFilterBusinessSegments()>
			         AND b.Business_Segment_Id IN ( SELECT Business_Segment_Id
			                                        FROM Template_Business_Segment
			                                       WHERE Template_Id = <cfqueryparam value="#template.getID()#" cfsqltype="cf_sql_integer">
			                                             AND Deleted = 0 )
		         </cfif>
            LEFT JOIN Budget_Class bc ON b.Budget_Class_ID = bc.Budget_Class_ID
            LEFT JOIN Budget_Contribution_Factor_Type bcft ON b.Budget_Contribution_Factor_Type_ID = bcft.Budget_Contribution_Factor_Type_ID
            LEFT JOIN Budget_Group bg ON b.Budget_Group_ID = bg.Budget_Group_ID
            LEFT JOIN Business_Segment bs ON b.business_segment_id = bs.business_segment_id
   WHERE Template_First_Parent_ID = <cfqueryparam value="#template.getFirstParentID()#" cfsqltype="cf_sql_integer">

</cfquery>

<!--------------------------------------------------------------------------------------------------------------------->
	<table id="budgets" class="datagrid">
	<thead>
		<cfoutput>	
			<tr>
				 <th style="font-size:11px;">#columnLabel(formlabels.code)#</th>
				 <th style="font-size:11px;">#columnLabel(formlabels.desc)#</th>
				 <th style="font-size:11px;">#columnLabel(formlabels.class)#</th>
				 <th style="font-size:11px;">#columnLabel(formlabels.group)#</th>
				 <th style="font-size:11px;">#columnLabel(formlabels.contribution_factor_type)#</th>
				 <cfif busSegMgr.isEnabled><th style="font-size:11px;">#appSettings.getbusiness_segment_label()#</th></cfif>
				 <th style="font-size:11px;">Budget</th>
				 <th style="font-size:11px;">Committed</th>
				 <th style="font-size:11px;">Actual</th>
			</tr>
		</cfoutput>	
	</thead>
	<tbody>
	<cfoutput query="vars.qBudgets">
		<tr id="tr_#Budget_ID#">
			<td>#budget_code#</td><td>#budget_desc#</td>
			<td>#Budget_Class_Desc#</td><td>#Budget_Group_Desc#&nbsp;</td>
			<td>#Contribution_Factor_Type#</td>
			<cfif busSegMgr.isEnabled><td>#Business_Unit_Desc#</td></cfif>
			<td class=dollar>#DollarFormat(Budget_Dollar)#</td>
			<td class=dollar>#DollarFormat(Committed_Dollar)#</td>
			<td class=dollar>#DollarFormat(Actual_Dollar)#</td>
		</tr>
	</cfoutput>
	</tbody>
	</table>

<!--------------------------------------------------------------------------------------------------------------------->
<cffunction name="columnLabel" output="false">
  <cfargument name="customLabel" required="true">

  <cfreturn Replace(arguments.customLabel, ':', '')>
</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript">
var budget_form = "budget_form";
<cfif busSegMgr.isEnabled>
  var column_sizes = ["0%", "8%", "30%", "8%", "8%", "10%", "10%", "8%", "10%", "8%"];
<cfelse>
  var column_sizes = ["0%", "8%", "40%", "8%", "8%", "10%", "0%",  "8%", "10%", "8%"];
</cfif>
var grid = $('#budgets').dataTable({
	"bAutoWidth": true
	,"bPaginate": false
	,"bSortClasses": false
	,"bFilter": false
	,"bScrollCollapse": true
	,"sDom": 'ft'
	,"sScrollXInner": "100%"
	,"sScrollY": "300px",
	,"aaSorting": [[ 1, "asc" ]]
  	,"aoColumns": [
                    {"sWidth": column_sizes[1]}
                  , {"sWidth": column_sizes[2]}
                  , {"sWidth": column_sizes[3]}
                  , {"sWidth": column_sizes[4]}
                  , {"sWidth": column_sizes[5]}
                  <cfif busSegMgr.isEnabled>, {"sWidth": column_sizes[6]}</cfif>
                  , {"sWidth": column_sizes[7], "sType":"currency", "bSearchable":false }
                  , {"sWidth": column_sizes[8], "sType":"currency", "bSearchable":false }
                  , {"sWidth": column_sizes[9], "sType":"currency", "bSearchable":false }
                  ]
,"aoColumnDefs": [    ]
}).fnSetFilteringDelay();
$('table#budgets tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
</script>