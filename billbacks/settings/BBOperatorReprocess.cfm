<!-----------------------------------------------------------------------------

FILE NAME:    BBOperatorReprocess.cfm
DESCRIPTION:  Reprocess file
CREATED BY:   Anand Rao
MODIFICATION HISTORY: BY    DATE    DESCRIPTION OF CHANGE

      Anand Rao 07-May-2013

------------------------------------------------------------------------------>
<style>
select.massPG, select.bpg {
  width:99%;
}
table.datagrid tr td {
  height:24px;
}
#massdiv {
  margin-left:66%;
  width:34%;
}
label {
  font-weight:bold;
  color:blue;
  cursor:hand;
}
</style>
<link rel="stylesheet" type="text/css" href="/common_files/chosen.min.css">

<cfscript>
  // set up some constants to share with the other ajax file
  variables.selectClass = "bpg";
  variables.keyDelimiter = "_";
</cfscript>

<cfif form.command EQ "OPERSAVE" and cgi.request_method eq "post">
  <cfset variables.Billback_list = "" />
  <cftry>
     <cfloop index="variables.listEntry" list="#FORM.planningGroups#">
      <cfset variables.bb_id      = listGetAt(variables.listEntry, 1, variables.keyDelimiter) /> <!--- In the planningGroups field value, the first ID is the Billback, third is PG_category_ID and the 2nd is Operator_ID --->
      <cfset variables.OperatorID = listGetAt(variables.listEntry, 2, variables.keyDelimiter) />
      <cfset variables.PGCatID    = listGetAt(variables.listEntry, 3, variables.keyDelimiter) />

      <cfset variables.Billback_list = variables.Billback_list & "'" & variables.bb_id & "'," />
      
      <cfset useLakebaseForvariables_checkOperatorExists = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_operator_category_definition")>
<cfif useLakebaseForvariables_checkOperatorExists>
	<cftry>
		<cfset variables.checkOperatorExists = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pg_operator_category_definition", {
				"pg_operator_category_id" = "eq.#variables.PGCatID#",
				"operator_group_id" = "eq.#variables.OperatorID#",
				"deleted" = "eq.0",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvariables_checkOperatorExists = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvariables_checkOperatorExists>
<cfquery name="variables.checkOperatorExists" datasource="#application.datasource#">
        SELECT 1 
         FROM PG_Operator_Category_Definition
        WHERE PG_Operator_Category_ID = '#variables.PGCatID#' 
               AND Operator_Group_ID = '#variables.OperatorID#' 
               AND Deleted = 0
      </cfquery>
</cfif>
      
      <cfif (variables.checkOperatorExists.RecordCount GT 0)>
        <cfset useLakebaseForUpdOperPG = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_operator_category_definition")>
<cfif useLakebaseForUpdOperPG>
	<cftry>
		<cfset application.oLakebase.updateRows("pg_operator_category_definition",
			{
				"pg_operator_category_id" = "eq.#variables.PGCatID#",
				"operator_group_id" = "eq.#variables.OperatorID#",
				"deleted" = "eq.0"
			},
			{
				"inclusion_exclusion" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdOperPG = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdOperPG>
<cfquery name="UpdOperPG" datasource="#application.datasource#">
          UPDATE PG_Operator_Category_Definition
             SET Inclusion_Exclusion = 1
           WHERE PG_Operator_Category_ID = '#variables.PGCatID#' AND
                  Operator_Group_ID = '#variables.OperatorID#' AND
                  Deleted = 0
        </cfquery>
</cfif>
      <cfelse>
        <cfset useLakebaseForvariables_selPGTypeID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_operator_category")>
<cfif useLakebaseForvariables_selPGTypeID>
	<cftry>
		<cfset variables.selPGTypeID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pg_operator_category", {
				"pg_operator_category_id" = "eq.#variables.PGCatID#",
				"select" = "pg_type_id"
			}), "pg_type_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvariables_selPGTypeID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvariables_selPGTypeID>
<cfquery name="variables.selPGTypeID" datasource="#application.datasource#">
          SELECT
            PG_Type_ID
          FROM
            PG_Operator_category
          WHERE
            PG_Operator_Category_ID = '#variables.PGCatID#'
        </cfquery>
</cfif>

        <cfset useLakebaseForvariables_qInsPGOperatorCategoryDefinition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_operator_category_definition")>
<cfif useLakebaseForvariables_qInsPGOperatorCategoryDefinition>
	<cftry>
		<cfset application.oLakebase.insertRow("pg_operator_category_definition", {
			"pg_operator_category_id" = "#variables.PGCatID#",
			"pg_type_id" = "#variables.selPGTypeID.PG_Type_ID#",
			"operator_group_level_id" = "0",
			"operator_group_id" = "#variables.OperatorID#",
			"inclusion_exclusion" = "1",
			"active" = "1",
			"deleted" = "0",
			"created_date" = "#now()#",
			"created_by" = "#request.AccessStructure.User_ID#",
			"include_in_other_pg" = "1",
			"is_pg" = "0"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForvariables_qInsPGOperatorCategoryDefinition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvariables_qInsPGOperatorCategoryDefinition>
<cfquery name="variables.qInsPGOperatorCategoryDefinition" datasource="#application.datasource#">
          INSERT INTO PG_Operator_Category_Definition
          (
            PG_Operator_Category_ID,
            PG_Type_ID,
            Operator_Group_Level_ID,
            Operator_Group_ID,
            Inclusion_Exclusion,
            Active,
            Deleted,
            Created_Date,
            Created_By,
            Include_In_Other_PG,
            Is_PG
          )
          VALUES
          (
            '#variables.PGCatID#',
            #variables.selPGTypeID.PG_Type_ID#,
            0,
            '#variables.OperatorID#',
            1,
            1,
            0,
            GetDate(),
            '#request.AccessStructure.User_ID#',
            1,
            0
          )
        </cfquery>
</cfif>

        <cfquery name="variables.qryPopulateTempTableForOperator" datasource="#application.datasource#">
          IF OBJECT_ID ('tempdb..##tmp_PG_View_Operator_Members') IS NOT NULL
          DROP TABLE ##tmp_PG_View_Operator_Members

          SELECT  Distinct
              PG_Type.PG_Type_ID,
              PG_Operator_Category_Definition.PG_Operator_Category_ID,
              PG_Operator_Category_Definition.Operator_Group_Level_ID,
              PG_Operator_Category_Definition.Operator_Group_ID,
              PG_Operator_Category_Definition.Inclusion_Exclusion,
              PG_Operator_Category_Definition.IS_PG,
              PG_Operator_Category.Include_In_Other_PG,
              PG_Operator_Category.PG_Operator_Category_Code,
              PG_Operator_Category.PG_Operator_Category_Name
          INTO  ##tmp_PG_View_Operator_Members
          FROM  PG_Type
          INNER JOIN  PG_Operator_Category_Definition
          ON    PG_Operator_Category_Definition.PG_Type_ID = PG_Type.PG_Type_ID
          INNER join PG_Operator_Category
          ON    PG_Operator_Category.PG_Operator_Category_ID = PG_Operator_Category_Definition.PG_Operator_Category_ID
          AND   PG_Operator_Category.Deleted = 0
          WHERE PG_Operator_Category_Definition.Deleted = 0
          AND   PG_Type.PG_Group_Type =3 --Operator
          AND   (PG_Operator_Category_Definition.PG_Operator_Category_ID IN ('#variables.PGCatID#')
          OR    PG_Operator_Category_Definition.PG_Operator_Category_ID IN (SELECT DISTINCT Operator_Group_ID FROM PG_Operator_Category_Definition WHERE  IS_PG =1 AND Deleted = 0 AND PG_Operator_Category_ID IN             ('#variables.PGCatID#')
          ))
          Order by PG_Type.PG_type_ID, PG_Operator_Category_Definition.PG_Operator_Category_ID,
              PG_Operator_Category.Include_In_Other_PG,
              PG_Operator_Category_Definition.Operator_Group_Level_ID,
              PG_Operator_Category_Definition.Operator_Group_ID

          CREATE CLUSTERED INDEX [I_tmp_PG_View_Operator_Members_C] ON [dbo].[##tmp_PG_View_Operator_Members]([Operator_Group_ID],[Operator_Group_Level_ID]) WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]
        </cfquery>
        
        <cfstoredproc procedure="USP_POPULATE_OPERATOR_PG_MEMBERS" datasource="#application.datasource#">
          <cfprocparam type="IN" CFSQLType="CF_SQL_TINYINT" dbVarName = "@View_Or_Save" value = "2" null="no">
          <cfprocresult name="qryUSPPopulateOperatorPGMembers">
        </cfstoredproc>
        
        <cfset useLakebaseForqryCaptureGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_operators")>
<cfif useLakebaseForqryCaptureGroup>
	<cftry>
		<cfset qryCaptureGroup = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_operators", {
				"is_group" = "eq.1",
				"deleted" = "eq.0",
				"operator_group_id" = "eq.#variables.PGCatID#",
				"select" = "contract_main_id"
			}), "contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryCaptureGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryCaptureGroup>
<cfquery name="qryCaptureGroup" datasource="#application.datasource#">
          SELECT DISTINCT Contract_Main_ID FROM Contract_Operators WHERE Is_Group = 1 and Deleted = 0 and Operator_Group_ID  = '#variables.PGCatID#'
        </cfquery>
</cfif>
        
        <cfif (qryCaptureGroup.RecordCount GTE 1)>
          <cfloop query ="qryCaptureGroup">
            <cfstoredproc procedure="CAPTURE_OPERATOR_GROUPS" datasource="#application.datasource#">
              <cfprocparam type="IN" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#qryCaptureGroup.Contract_Main_ID#" null="no">
            </cfstoredproc>
          </cfloop>
        </cfif>
      </cfif>   <!--- <cfif (variables.checkOperatorExists.RecordCount EQ 0)> --->
    </cfloop>
  <cfcatch>
      <cfquery name="unlockBBs" datasource="#application.datasource#">
        UPDATE  Billback_Allied 
           SET  BB_Is_Locked = 0,
                BB_Locked_By_User_ID = NULL,
                BB_Lock_Date = NULL
        WHERE Billback_ID IN
          (
            SELECT Billback_ID FROM (#PreserveSingleQuotes(variables.Billback_list)#)
          )
      </cfquery>
      <cfrethrow>
  </cfcatch>
  </cftry>
</cfif>

<input type="hidden" name="planningGroups" value="">

<cfoutput>
<cfif variables.inEditMode>
  <cfset useLakebaseForvariables_qPlanningGroups = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_operator_category")>
<cfif useLakebaseForvariables_qPlanningGroups>
	<cftry>
		<cfset variables.qPlanningGroups = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pg_operator_category", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"order" = "pg_operator_category_name.asc",
				"select" = "pg_operator_category_id,pg_operator_category_code,pg_operator_category_name"
			}), "pg_operator_category_id,pg_operator_category_code,pg_operator_category_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvariables_qPlanningGroups = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvariables_qPlanningGroups>
<cfquery name="variables.qPlanningGroups" datasource="#application.datasource#">
    SELECT PG_Operator_Category_ID,
            PG_Operator_Category_Code,
            PG_Operator_Category_Name
      FROM PG_OPERATOR_CATEGORY
     WHERE Deleted = 0 AND Active = 1
           ORDER BY PG_Operator_Category_Name
  </cfquery>
</cfif>
  <div id="massdiv">
    <label id="massApply">[ mass apply ]</label><select id="massPG" class="massPG"><option value=""></option><cfloop query="variables.qPlanningGroups"><option value="#variables.qPlanningGroups.PG_Operator_Category_ID#"> #variables.qPlanningGroups.PG_Operator_Category_Name# </option></cfloop></select>
  </div>
</cfif>

<cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( [1.5, 3, 2, 3] )>
<table width="100%" border="0" cellpadding="1" cellspacing="0" class="datagrid" id="BBDisplayTable" style='table-layout:fixed;'>
<cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
  <col width="#variables.columnPercentage#%">
</cfloop>
  <thead>
    <th>BB Code</th>
    <th>Operator</th>
    <th>Ref ##</th>
    <th>Planning Group</th>
  </thead>
  <tbody>
  </tbody>
</table>
</cfoutput>

<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/script/javascript/chosen.jquery.min.js"></script>

<script type="text/javascript">
updateSelection = function () {
  var hiddenPGs = $('input[name=planningGroups]').val();
  <!--- convert the list into an array for easy manipulation --->
  if (hiddenPGs.length == 0)
    var aplanningGroups = [];
  else
    var aplanningGroups = hiddenPGs.split(",");

  <!--- scan thru all select on the page --->
  <cfoutput>
  $('select.#variables.selectClass#').each( function() {
    var bb_operator = $(this).prop('name'),
        pg_categoryID = $(this).val(),
        index_position = 0;
        
    // locate current selected option in the array using bill back ID + operator ID
    for (index_position = 0; index_position < aplanningGroups.length; index_position++) {
      if (aplanningGroups[index_position].indexOf(bb_operator + '#variables.keyDelimiter#') !== -1)
        break;
    }
    
    // not found in the array
    if (index_position >= aplanningGroups.length) {
      index_position = -1;
    }
    // console.log('bb_operator = ' + bb_operator)
    // console.log('pg_categoryID = ' + pg_categoryID)
    // console.log('index_position = ' + index_position)
    
    // planning group option was NOT selected
    if ( pg_categoryID == '0') {
      // if it is in the array get rid of it
      if (index_position !== -1)
        aplanningGroups.splice(index_position, 1);
    }
    // planning group option WAS selected
    else {
      // not yet in the array, add it to array
      if (index_position == -1) {
        aplanningGroups.push( bb_operator + '#variables.keyDelimiter#' + pg_categoryID );
      }
      // found in array do update current array element
      else {
        aplanningGroups[index_position] = bb_operator + '#variables.keyDelimiter#' + pg_categoryID;
      }
    }
    
  });

  <!--- convert array back to a list for passing to Ajax and for usage in form action --->
  hiddenPGs = aplanningGroups.join(",");
  // console.log(hiddenPGs);
  <!--- refresh the hidden input with ALL selected rows --->
  $('input[name=planningGroups]').val( hiddenPGs );
  </cfoutput>
};


var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .61 : .45) * windowHeight;
var oprSave = $('table.datagrid').dataTable({
   "bAutoWidth": false
  ,"bPaginate": false
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  ,"sDom": 'fptipr'
  ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
  ,"aaSorting": [[ 0, "asc" ]]
  ,"sScrollY": sScrollY         <!--- data grid height --->
  ,"bPaginate": true
  ,"bServerSide": true
  ,"bProcessing": true
  ,"iDisplayLength": 100
  ,"sAjaxSource": "ajax/BBOperatorReprocess.cfm"
  ,"sServerMethod": "POST"
  ,"fnServerParams": function ( aoData ) {
            updateSelection();
            <cfoutput>
            aoData.push( { "name": "selectClass", "value": "#variables.selectClass#" } ); 
            aoData.push( { "name": "keyDelimiter", "value": "#variables.keyDelimiter#" } ); 
            aoData.push( { "name": "inEditMode", "value": #variables.inEditMode# } ); 
            aoData.push( { "name": "planningGroups", "value": $('input[name=planningGroups]').val() } );
            </cfoutput>
        }
  ,"fnDrawCallback": function () { $(<cfoutput>'.#variables.selectClass#'</cfoutput>).chosen( {  disable_search_threshold:10
                                                                                                ,placeholder_text_single:"Select a planning group" } ); 
                                   $('#massApply').click(function(){ 
                                     // copy value from mass apply box to all dropdowns below and refresh chosen ui
                                     $(<cfoutput>'.#variables.selectClass#'</cfoutput>).val( $('#massPG').val() ).trigger( 'chosen:updated' );
                                   });
                                 }
}).fnSetFilteringDelay();

$('table.datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

$('#massPG').chosen( {  disable_search_threshold:10, placeholder_text_single:"Select a planning group" } ); 

$('.save').click(function(){
 $("#command").val("OPERSAVE");
 $(this).html("saving data, please wait...");
 updateSelection();
 $('form[name=DataForm]').submit();
 return false;
});
</script>
