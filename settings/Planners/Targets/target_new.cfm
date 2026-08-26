<!---
  * ==================================================================================================== 
  *    @File: \settings\planners\targets\target_new.cfm
  *  @Author: Chris Nguyen
  *    @Date: July 2020
  * 
  * @Remarks: Create New Planner Target
  *
  * ==================================================================================================== 
--->
<cfset duplicate_found_in_save = 0>

<cfif cgi.request_method is "post">
    <cfset useLakebaseForqTarget = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planner_target_header")>
<cfif useLakebaseForqTarget>
	<cftry>
		<cfset qTarget = application.oLakebase.toQuery(
			application.oLakebase.selectRows("planner_target_header", {
				"fiscal_year" = "eq.#form.fiscal_year#",
				"main_distributor_group_id" = "eq.#form.main_distributor_group_id#",
				"invoice_start_date" = "eq.#form.invoice_start_date#",
				"invoice_end_date" = "eq.#form.invoice_end_date#",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqTarget = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqTarget>
<cfquery name="qTarget" datasource="#application.datasource#">
        SELECT 1
          FROM Planner_Target_Header
         WHERE fiscal_year = #form.fiscal_year#
                    AND Main_Distributor_Group_ID = '#form.main_distributor_group_id#'
                    AND Invoice_Start_Date = '#form.invoice_start_date#'
                    AND Invoice_End_Date = '#form.invoice_end_date#'
    </cfquery>
</cfif>

    <cfif qTarget.recordCount and form.overwrite neq "1">
        <cfset duplicate_found_in_save = 1>
    <cfelse>
        <cfquery datasource="#application.datasource#">
            EXEC Planner_Target_Create 
                        @fiscal_year = #form.fiscal_year#
                        ,@Main_Distributor_Group_ID = '#form.main_distributor_group_id#'
                        ,@Invoice_Start_Date = '#form.invoice_start_date#'
                        ,@Invoice_End_Date = '#form.invoice_end_date#'
                        ,@User_ID = '#request.AccessStructure.User_ID#'
                        ,@Overwrite = #form.overwrite#
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
        param name="form.Main_Distributor_Group_ID" default="";
        param name="form.invoice_start_date" default="";
        param name="form.invoice_end_date" default="";

        targets_cfc            = createObject("component", "mvc.models.planner.plannerTargets");
        qFiscalYears           = targets_cfc.getFiscalYears();
        qDistributorGroupTypes = targets_cfc.getDistributorGroupTypes();
    </cfscript>

    <p>Fill in fields below to generate initial Target values</p>

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
                <!--- <cfloop query="qFiscalYears">
                    <option <cfif form.fiscal_year eq qFiscalYears.Planner_Year>selected</cfif>>#qFiscalYears.Planner_Year#</option>
                </cfloop> --->
                <cfloop from="1" to="#arrayLen(years)#" index="counter">
                    <option>#years[ counter ]#</option>
                </cfloop>
            </select>
        </div>

        <div class="new"><label>#targets_cfc.getDistributorGroupLabel()#</label> 
            <select name="main_distributor_group_id">
                <option></option>
                <cfloop query="qDistributorGroupTypes">
                    <option <cfif form.main_distributor_group_id eq qDistributorGroupTypes.Group_Guid>selected</cfif>
                        value="#qDistributorGroupTypes.Group_Guid#">#qDistributorGroupTypes.Group_Desc# ( #qDistributorGroupTypes.Group_Number# )</option>
                </cfloop>
            </select>
        </div>

        <cfset timeframe_help = "The start and end dates represent the timeframe to gather invoices for calculating the initial target values.">
        <p>#timeframe_help#</p>
        <div class="new">
            <label>Start Date</label> <input type="text" class="date" name="invoice_start_date" readonly="readonly" value="#form.invoice_start_date#">
        </div>
        <div class="new"><label>End Date</label> <input type="text" class="date" name="invoice_end_date" readonly="readonly" value="#form.invoice_end_date#"></div>
    </cfoutput>    
    </form>

    <div id="actions">
        <button class="button create recommended">Create Target</button>
        <button class="button cancel">Cancel</button>
    </div>

    <cf_include files="/common_files/jQuery.cfm">
    <cfset jQueryUI.widgets = "full">
    <cfinclude template="/common_files/jQueryUI.cfm">

    <script>
        $(".date").datepicker({
            changeMonth: true
			,changeYear: true
            ,showButtonPanel: false
            ,maxDate: '0'
            ,onClose: function(selectedDate) {
                if ($(this).attr("name") == "invoice_start_date") {
                    $("input[name=invoice_end_date]").datepicker( "option", "minDate", selectedDate );
                }
                else {
                    $("input[name=invoice_start_date]").datepicker( "option", "maxDate", selectedDate );
                }
            }
        });

        $("button.cancel").click(function(){
            parent.delete_new_tab();
        });

        $("button.create").click(function(){
            let errors = [];

            if ($("select[name=fiscal_year]").val() == '') 
                errors.push("Please select a fiscal year.");
            if ($("select[name=main_distributor_group_id]").val() == '') 
                <cfoutput>errors.push("Please select a #targets_cfc.getDistributorGroupLabel()#.")</cfoutput>;
            if ($("input[name=invoice_start_date]").val() == '') 
                errors.push("Please enter an invoice start date.");
            if ($("input[name=invoice_end_date]").val() == '') 
                errors.push("Please enter an invoice end date.");

            if (errors.length) {
                alert( errors.join("\n") );
                return false;
            }

            $("form[name=create_new]").submit();
        });

        <cfif duplicate_found_in_save>
            alert("A target already exists for the fiscal year and division.\nPlease go to the main Target page, find the fiscal year/division\n and edit the existing target.");
            // if (confirm("Target exists already. Do you wish to overwrite?")) {
            //     $("input[name=overwrite]").val(1);
            //     $("form[name=create_new]").submit();
            // }
        </cfif>
    </script>

    <cfinclude template="/common_files/focus.cfm">
</body>
</html>