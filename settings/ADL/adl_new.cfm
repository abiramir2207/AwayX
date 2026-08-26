<!---
  * ====================================================================================================
  *    @File: /settings/ADL/adl_new.cfm
  *  @Author: Sharon Harris
  *    @Date: April 2021
  *
  * @Remarks: Create New Authorized Distribution List
  *
  * ====================================================================================================
--->

<cfset duplicate_found_in_save = 0>

<cfif cgi.request_method is "post">
    <cfset useLakebaseForqADL = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("authorized_distribution_list_header")>
<cfif useLakebaseForqADL>
	<cftry>
		<cfset qADL = application.oLakebase.toQuery(
			application.oLakebase.selectRows("authorized_distribution_list_header", {
				"distributor_group_id" = "eq.#form.adl_customer#",
				"title" = "eq.#form.adl_title#",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqADL = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqADL>
<cfquery name="qADL" datasource="#application.datasource#">
		SELECT 	1
		FROM 	Authorized_Distribution_List_Header
		WHERE 	Distributor_Group_ID = '#form.adl_customer#'
		AND 	Title = '#form.adl_title#'
    </cfquery>
</cfif>

    <cfif qADL.recordCount and form.overwrite neq "1">
        <cfset duplicate_found_in_save = 1>
    <cfelse>
        <cfset createObject("component", "mvc.models.settings.ADLManager").saveADLHeader(customer=form.adl_customer,title=form.adl_title) />

        <script>
            // remove create new tab & iframe
            parent.delete_new_tab();
            // reload the ADL list
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
            * { box-sizing: border-box; margin: 0; padding: 0; }
			html { background-color: white; }
            body { padding: 10px; }
            .hidden { display: none; }
            label {
                display: inline-block;
                width: 125px;
                text-align: right;
				font-size: 12px;
                margin-right: 10px;
            }
            div.new { margin: 20px; }
			select, input[type="text"] { height: 18px; 	border: 1px solid #97999B; border-radius: .15rem; padding: 0 3px; }
            div#actions { margin-left: 145px; }

        </style>
        <cf_include files="/styles/tabnav-2020.css">
	</cfsavecontent>
	<cfhtmlhead text="#application.util.string.compress( styles )#">


	<cfscript>
		param name="form.adl_title"    default="";
		param name="form.adl_customer" default="";

		adl_cfc                        = createObject("component", "mvc.models.settings.ADLManager");
		Setting_ADL_customer_dimension = adl_cfc.getDistributorGroupType();
		sDistributorGroupLabel         = adl_cfc.getDistributorGroupLabel();

        qDistributorGroupTypes = queryExecute( "
                                                    SELECT Group_Desc, Group_Guid, Group_Number
                                                      FROM All_Customer_Group_Types
                                                     WHERE Distributor_Group_Level_ID = 2
                                                            AND Deleted = 0
                                                            AND EXISTS (
                                                                            SELECT 1
                                                                              FROM All_Customer_Group_Type_Members m
                                                                                        INNER JOIN BSA_Foodservice_Customers c
                                                                                            ON c.BSA_Foodservice_Customers_ID = m.BSA_Foodservice_Customers_ID
                                                                             WHERE m.Distributor_Group_ID = All_Customer_Group_Types.Group_GUID
                                                                                    AND m.Distributor_Group_Level_ID = All_Customer_Group_Types.Distributor_Group_Level_ID
                                                                                    AND c.Retail_Customer = 1
                                                                        )
                                                     ORDER BY Group_Desc
                                                "
                                                ,[], {datasource = application.datasource});
	</cfscript>


<!--- <cfinclude template="/developer/dev_tools.cfm"> --->

    <form method="post" name="create_new">
		<input type="hidden" name="overwrite" value="0">

		<cfoutput>
			<div class="new">
				<label for="adl_title">Title</label>
				<input type="text" name="adl_title" id="adl_title" value="#form.adl_title#">
			</div>

			<div class="new">
				<cfif Setting_ADL_customer_dimension NEQ 0>
					<label for="adl_customer">#sDistributorGroupLabel#</label>
					<select name="adl_customer" id="adl_customer" style="min-width:125px;">
						<cfloop query="qDistributorGroupTypes">
						<option <cfif form.adl_customer eq qDistributorGroupTypes.Group_Guid>selected</cfif>
                        value="#qDistributorGroupTypes.Group_Guid#">#qDistributorGroupTypes.Group_Desc# ( #qDistributorGroupTypes.Group_Number# )</option>
						</cfloop>
					</select>
				<!---
				This ssection needs new logic
				<cfelse>
					<label for="adl_customer">Group</label>
					<input type="text" name="adl_customer" id="adl_customer" value="#form.adl_customer#">	--->
				</cfif>
			</div>

		</cfoutput>
    </form>

    <div id="actions">
        <button class="button create recommended">Create List</button>
        <button class="button cancel">Cancel</button>
    </div>

    <cf_include files="/common_files/jQuery.cfm">
    <cfinclude template="/common_files/jQueryUI.cfm">

    <script>

        $("button.cancel").click(function(){
            parent.delete_new_tab();
        });

        $("button.create").click(function(){
            let errors = [];

            if (errors.length) {
                alert( errors.join("\n") );
                return false;
            }

            $("form[name=create_new]").submit();
        });

		<cfif duplicate_found_in_save>
            alert("A list already exists for the fiscal year and division.\nPlease go to the main page, find the fiscal year/division\n and edit the existing target.");
        </cfif>

    </script>

    <cfinclude template="/common_files/focus.cfm">
</body>
</html>