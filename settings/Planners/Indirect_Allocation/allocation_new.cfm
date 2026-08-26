<!---
  * ====================================================================================================
  *    @File: settings\Planners\Indirect_Allocation\allocation_new.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2022 May
  *
  * @Remarks: Create new fiscal year allocation
  *
  * ====================================================================================================
--->
<cfset duplicate_found_in_save = 0>

<cfif cgi.request_method is "post">
    <cfquery name="qAllocation" datasource="#application.datasource#">
        SELECT 1
          FROM Planner_Indirect_Allocation_Header
         WHERE Fiscal_year = #form.fiscal_year#
    </cfquery>

    <cfif qAllocation.recordCount and form.overwrite neq "1">
        <cfset duplicate_found_in_save = 1>
    <cfelse>
        <cfquery datasource="#application.datasource#">
            INSERT INTO Planner_Indirect_Allocation_Header
                        ( Fiscal_Year
                            , Distributor_Group_Level_ID
                            , Operator_Group_Level_ID
                            , Product_Group_Level_ID
                            )
                VALUES ( #form.fiscal_year#
                            , #application.util.query.get_setting( "Planner_Direct_Indirect_Allocation_Direct_Customer_Type", 0 )#
                            , #application.util.query.get_setting( "Planner_Direct_Indirect_Allocation_InDirect_Customer_Type", 0 )#
                            , #application.util.query.get_setting( "Planner_Direct_Indirect_Allocation_Product_Type", 0 )#
                        )
        </cfquery>

        <script>
            // remove create new tab & iframe
            parent.delete_new_tab();
            // reload the targets list
            parent.location.reload();
        </script>
        <cfabort>
    </cfif>
</cfif>

<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <cfsavecontent variable="styles">
        <style>
            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }
            body {
                padding: 10px;
            }
            .hidden {
                display: none;
            }
            label {
                display: inline-block;
                width: 125px;
                text-align: right;
                font-weight: bold;
                margin-right: 10px;
            }
            div.new {
                margin: 20px;
            }
            div#actions {
                margin-left: 145px;
            }
            input.date {
                background: white;
                width: 80px;
            }
        </style>
        <cf_include files="/styles/tabnav-2020.css">
    </cfsavecontent>
    <cfhtmlhead text="#application.util.string.compress( styles )#">

    <cfscript>
        param name="form.fiscal_year" default="";
        targets_cfc            = createObject("component", "mvc.models.planner.plannerTargets");
        qFiscalYears           = targets_cfc.getFiscalYears();
    </cfscript>

    <form method="post" name="create_new">
        <input type="hidden" name="overwrite" value="0">

        <cfoutput>
        <div class="new">
            <label>Fiscal Year</label>
            <cfset years = []>
            <cfset start_year = dateAdd('yyyy', -5, now())>
            <cfloop from="1" to="9" index="counter">
                <cfset years[ counter ] = year( dateAdd('yyyy', counter, start_year) )>
            </cfloop>
            <select name="fiscal_year">
                <option></option>
                <cfparam name="form.fiscal_year" default="">
                <cfloop from="1" to="#arrayLen(years)#" index="counter">
                    <option <cfif form.fiscal_year eq years[ counter ]> selected </cfif> >#years[ counter ]#</option>
                </cfloop>
            </select>
        </div>
        </cfoutput>
    </form>

    <div id="actions">
        <button class="button create recommended">Create Allocation</button>
        <button class="button cancel">Cancel</button>
    </div>

    <cf_include files="/common_files/jQuery.cfm, /common_files/dhx_message.cfm">

    <script>
        $("button.cancel").click(function(){
            parent.delete_new_tab();
        });

        $("button.create").click(function(){
            let errors = [];

            if ($("select[name=fiscal_year]").val() == '')
                errors.push("Please select a fiscal year.");

            if (errors.length) {
                dhx_alert( errors.join("<br>") );
                return false;
            }

            $("form[name=create_new]").submit();
        });

        <cfif duplicate_found_in_save>
            dhx_alert("An allocation already exists for the fiscal year.<br>Please go to the main allocation page, find the fiscal year\<br> and edit the existing allocation.");
        </cfif>
    </script>

    <cfinclude template="/common_files/focus.cfm">
</body>
</html>