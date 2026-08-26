<!---
  * ====================================================================================================
  *    @File: Common_Files\savePlannerProductGroupList.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2021 February
  *
  * @Remarks: Validate, save planner product groups from create list option
  *
  * ====================================================================================================
--->

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create List</title>
</head>
<body>
    <style>
        .ValidCategory{
            background-color:#FFDEAD;
            border-top: 2px solid #808080;
            border-bottom: 2px solid #808080;
            font-size:14;
            font-weight:bold;
        }
        .InValidCategory{
            background-color:#FA8072;
            border-top: 2px solid #808080;
            border-bottom: 2px solid #808080;
            font-size:14;
            font-weight:bold;
        }
        .InvalidSummary{
            font-size:12;
            font-weight:bold;
            text-decoration:underline;
        }
        TABLE.Maintable TD{
            font-size : 10px;
        }
        a.continue {
            margin-right: 15px;
        }
    </style>
<cfparam name=" url.passForm" default="">

<cfif  url.passForm EQ 'planner_operators'>
    <cfscript>
        planner_obj = createObject("component", "mvc.models.planner.plannermanager");
        qOperators  = planner_obj.getPlannerOperators( url.template_id );
    </cfscript>
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~ gather valid Operators based on input criteria ~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfquery name="qValidGroups" dbtype="query">
        SELECT *
          FROM qOperators
                    WHERE 1 = 0
                            <cfloop list="#form.passedItemList#" item="OperatorID">
                                <cfif form.match_type contains "partial">
                                    OR ( LOWER(BSA_OPERATOR_ID) LIKE '%#trim( lCase(OperatorID) )#%' )
                                <cfelse>
                                    OR ( LOWER(BSA_OPERATOR_ID) = '#trim( lCase(OperatorID) )#' )
                                </cfif>
                            </cfloop>
    </cfquery>
<cfelse>
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~ pull all product groups based on product group level & planner ID ~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfscript>
        planner_template_manager = createObject( "component", "mvc.Models.Planner.PlannerTemplateManager" );
        planner_product_groups   = planner_template_manager.getPlannerProductGroups( url.group_level_id, val( url.plannerID ) );
	</cfscript>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~ gather valid product groups based on input criteria ~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfquery name="qValidGroups" dbtype="query">
        SELECT *
          FROM planner_product_groups
                    WHERE 1 = 0
                            <cfloop list="#form.passedItemList#" item="product_group">
                                <cfif form.match_type contains "partial">
                                    OR ( LOWER(Group_Number) LIKE '%#trim( lCase(product_group) )#%' )
                                <cfelse>
                                    OR ( LOWER(Group_Number) = '#trim( lCase(product_group) )#' )
                                </cfif>
                            </cfloop>
    </cfquery>
</cfif>
<!--- <cfinclude template="/developer/dev_tools.cfm"> --->

    <cfoutput>
    <div align="center">
        <table border="0" cellspacing="5" cellpadding="5" width="300">
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- ~~~~~~~~~ Valid Records ~~~~~~~~~~ --->
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
			<tr HEIGHT="10">
				<td width="80%" align="left" class="ValidCategory" bgcolor="##009900" >
					Valid Records
				</td>
				<td width="20%" align="right" class="ValidCategory">#qValidGroups.recordCount#</td>
			</tr>
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- ~~~~~~~~~ InValid Records ~~~~~~~~~~ --->
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
			<tr HEIGHT="10">
				<td width="80%" align="left" class="InValidCategory">
                    Invalid Records<BR>
                    <cfset invalid_records = 0>
					<table align="right" class="Maintable">
                        <cfloop list="#form.passedItemList#" item="product_group">
                            <cfquery name="qIsValid" dbtype="query">
                                SELECT *
                                  FROM qValidGroups
                                    <cfif form.match_type contains "partial">
                                        WHERE LOWER(<cfif  url.passForm EQ 'planner_operators'>BSA_OPERATOR_ID<cfelse>Group_Number</cfif>) LIKE '%#trim( lCase(product_group) )#%'
                                    <cfelse>
                                        WHERE LOWER(<cfif  url.passForm EQ 'planner_operators'>BSA_OPERATOR_ID<cfelse>Group_Number</cfif>) = '#trim( lCase(product_group) )#'
                                    </cfif>
                            </cfquery>
                            <cfif qIsValid.recordCount eq 0>
                                <cfset invalid_records = invalid_records + 1>
                                <tr>
                                    <td>#product_group#</td>
                                </tr>
                            </cfif>
                        </cfloop>
					</table>
				</td>
  				<td width="20%" align="right" class="InValidCategory">#( invalid_records )#</td>
			</tr>

            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- ~~~~~~~~~ Duplicate Records ~~~~~~~~~~ --->
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <tr HEIGHT="10">
                <cfscript>
                    unique_groups = listRemoveDuplicates(form.passedItemList, ",", true);
                </cfscript>
				<td width="80%" align="left" class="InValidCategory">Duplicate Records</td>
				<td width="20%" align="right" class="InValidCategory">#( listLen(form.passedItemList) - listLen(unique_groups) )#</td>
			</tr>

            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- ~~~~~~~~~ Total Records ~~~~~~~~~~ --->
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <tr HEIGHT="10">
				<td width="80%" align="left" class="ValidCategory">Total Records</td>
				<td width="20%" align="right" class="ValidCategory">#(qValidGroups.recordCount + invalid_records)#</td>
			</tr>
        </table>


        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~ Actions ~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <div>
            <a class="continue" href="">#application.util.string.linkFormat("Continue")#</a>
            <a href="createListForm.cfm?passObj=ProductGroup&plannerID=#url.plannerID#&group_level_id=#url.group_level_id#&callback=import_from_create_list&textareadata=#form.passedItemList#&passForm=#url.passForm#&template_id=#url.template_id#">#application.util.string.linkFormat("Back")#</a>
        </div>
    </div>
    </cfoutput>


    <cfinclude template="/common_files/jQuery.cfm">
    <script>
        'use strict;'

        $("a.continue").click(function(){
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- ~~~~~~~~~ execute parent call back function when valid records exist ~~~~~~~~~~ --->
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
   <cfif (url.passForm eq 'planner_operators')>
		<cfloop query ="qValidGroups">
			window.parent.opener.jQuery("input[value="+<cfoutput>#qValidGroups.BSA_OPERATOR_ID# </cfoutput>+"]").prop("checked", true);
		</cfloop>
	<cfelse>
            <cfif url.callback gt '' and qValidGroups.recordCount>
                <cfoutput>window.opener.#url.callback#("#valueList(qValidGroups.group_id)#");</cfoutput>
            </cfif>
    </cfif>
            window.close();
        });
    </script>

    <cfinclude template="/common_files/focus.cfm">
</body>
</html>