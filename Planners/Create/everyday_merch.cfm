<!------------------------------------------------------------------------------------------------------------------------------
	   File Name:  Planners\Create\everyday_merch.cfm
	Created Date:  2022 February
	  Created By:  Chris Nguyen
	 Description:  Prompt for product numbers, every unit retail, merch unit prices and uoms
------------------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Everyday Unit Retail</title>
    <style>
        .help {
            color: red;
            font-weight: bold;
        }
        div.heading {
            width: 75%;
            margin: 0 12.5%;
        }
    </style>
</head>

<body>
    <cfparam name="form.action" default="">
    <cfparam name="form.itemList" default="">

    <cfset has_valid_products = false>
    <cfset udf = createObject("component", "components.udf")>

    <cfif form.action is "validate_everyday_merch" or form.action is "save_valid_products">
        <cfset validate_everyday_merch()>
    <cfelseif form.action is "save_everyday_merch">
        <cfset save_everyday_merch()>
    <cfelse>
        <cfset input_everyday_merch()>
    </cfif>

    <cfinclude template="/common_files/focus.cfm">
</body>
</html>


<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~ input dataentry form for users to enter their product information ~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cffunction name="input_everyday_merch" output="true">
    <cfoutput>
    <form name="theForm" method="post" action="everyday_merch.cfm?#cgi.query_string#">

        <cfset application.util.struct.convertToHiddenInput( form, "action,itemList" )>

        <input type="hidden" name="action" id="action" value="validate_everyday_merch">

        <table width="75%" border=0 cellspacing=0 cellpadding=0 align="center">
            <tr>
                <td colspan="4">&nbsp;</td>
            </tr>

            <tr>
                <td>
                    Product Number  <br>
                    <span class="help">
                        (AlphaNumeric only)
                    </span>
                </td>
                <td>
                    UOM
                    <br>
                    <span class="help">
                        (CS / LB / % / CWT / DEL)
                    </span>
                </td>
                <td>
                    Everyday Unit Retail <br>
                    <span class="help">
                        (Numeric only)
                    </span>
                </td>

                <!--- only show merch unit column when its template calls for it --->
                <cfif form.merch_unit_price eq 1>
                    <td>
                        Merch Unit Price<br>
                        <span class="help">
                            (Numeric only)
                        </span>
                    </td>
                </cfif>
            </tr>

            <tr>
                <td colspan="4">
                    <textarea ID="itemList" CLASS="itemList" NAME="itemList"  ROWS="20" COLS="30" style="width:100%">#trim( form.itemList )#</textarea>
                </td>
            </tr>
        </table>

        <div style="text-align: center;margin-top:15px;">
            <button class="button recommended" id="save" type="button" title="Click to save all your products"> Save </button>
            <cfif has_valid_products>
                <button class="button" id="save_valid_products" type="button" title="Click to save the valid products and ignore the invalid ones"> Save Valid Products </button>
            </cfif>
            <button onClick="window.close();" type="button" class="button"> Close Window </button>
        </div>
    </form>
    </cfoutput>

    <script>
        document.getElementById( "save" ).addEventListener( "click", function () {
            if ( document.getElementById( "itemList" ).value.trim().length == 0 ) {
                alert( "Please enter the product information first." );
            }
            else {
                document.theForm.submit();
            }
        });

        document.getElementById( "save_valid_products" ).addEventListener( "click", function () {
            if ( document.getElementById( "itemList" ).value.trim().length == 0 ) {
                alert( "Please enter the product information first." );
            }
            else {
                document.getElementById( "action" ).value = "save_valid_products";
                document.theForm.submit();
            }
        });
    </script>
</cffunction>


<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~ validate input data, show errors when needed ~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cffunction name="validate_everyday_merch" output="true">
    <cfoutput>
    <!--- display cf_loader message --->
    #udf.cf_loader( "Saving changes, please wait..." )#

    <cfset copy_paste_table = '####'
                                    & replace( request.AccessStructure.User_ID, '-', '_', 'ALL' )
                                    & '_everyday_merch_'
                                    & form.programId >

    <cfquery datasource="#application.datasource#">
        IF OBJECT_ID( 'tempdb..#copy_paste_table#' ) IS NOT NULL
            DROP TABLE #copy_paste_table#

        IF OBJECT_ID('tempdb..##tmp_everyday_merch_program_products') IS NOT NULL
            DROP TABLE ##tmp_everyday_merch_program_products
    </cfquery>

    <cfquery datasource="#application.datasource#">
        CREATE TABLE #copy_paste_table# (
                                    Row_ID         Int          IDENTITY (1, 1)
                                    ,Product       Varchar (150)
                                    ,EveryDayPrice Varchar (50)
                                    ,MerchPrice    Varchar (50)
                                    ,UOM           Varchar (50)
                                    ,Invalid       Bit          DEFAULT ( 0 )
                                    ,Reason        Varchar (250)
                                )

        CREATE TABLE ##tmp_everyday_merch_program_products (
                                             Product_ID       UniqueIdentifier
                                            ,Product_UOM      Varchar (10)
                                            ,Net_Weight       Float
                                            ,Case_Count       Float
                                            ,Sleeves_Per_Case Float
                                            )
    </cfquery>


    <!--- save input textarea into a shared temp table --->
    <cfset total_product_rows = 0>
    <cfquery datasource="#application.datasource#">

        <cfloop index="rawdata" list="#trim( form.itemList )#" delimiters="#chr(13)#">
            -- parse a single text line into multiple columns array
            <cfscript>
                columns = rawdata.listToArray( " " & chr(9) );

                // define missing columns when needed
                param name="columns[ 1 ]" default="";
                param name="columns[ 2 ]" default="";
                param name="columns[ 3 ]" default="";
                param name="columns[ 4 ]" default="";
            </cfscript>

            <cfif columns[ 1 ].trim() neq ''>
                <cfset total_product_rows++>
                INSERT INTO #copy_paste_table#
                            (    Product
                                ,UOM
                                ,EveryDayPrice
                                ,MerchPrice
                            )

                    VALUES (  '#columns[ 1 ]#'
                                ,'#columns[ 2 ]#'
                                ,'#columns[ 3 ]#'
                                ,'#columns[ 4 ]#'
                            )
            </cfif>
        </cfloop>

    </cfquery>

    <!--- populate program products temp table --->
    <cfquery datasource="#application.datasource#">
        <cfloop list="#form.product_list#" item="product_guid">
            <cfset product_id = product_guid.replace( "-", "_", "all" )>

            INSERT INTO ##tmp_everyday_merch_program_products
                            (
                                Product_ID
                                ,Product_UOM
                                ,Net_Weight
                                ,Case_Count
                                ,Sleeves_Per_Case
                            )
                    VALUES (
                                '#product_guid#'
                                ,'#form[ "ProdUOM__"   & product_id ]#'
                                ,'#form[ "NetWeight_"  & product_id ]#'
                                ,'#form[ "Case_Count_" & product_id ]#'
                                ,'#form[ "Sleeves_Per_Case_" & product_id ]#'
                            )
        </cfloop>
    </cfquery>

    <cfquery name="qValidate" datasource="#application.datasource#">
        EXEC Planner_Merch_Copy_Paste_Validate #form.programID#, '#copy_paste_table#', #form.merch_unit_price#
    </cfquery>

    <cfset error_count = 0>
    <cfif form.action neq "save_valid_products">
        <div class="heading">
            <h4>Errors</h4>
            <cfloop query="qValidate">
                <cfif qValidate.invalid>
                    <cfset error_count++>
                    <p>Line #qValidate.Row_ID#: #qValidate.reason#</p>
                </cfif>
            </cfloop>
        </div>
    </cfif>

    <cfif error_count eq 0>
        <cfset save_everyday_merch()>
    <cfelse>
        <cfset valid_rows_count = ( total_product_rows - error_count )>
        <cfif valid_rows_count gt 0>
            <cfset has_valid_products = true>
            <div class="heading">
                <h4>#valid_rows_count# Valid Products</h4>
            </div>
        </cfif>
        <!--- allow users to make corrections --->
        <cfset input_everyday_merch()>
    </cfif>

    <script>
        // hide cf_loader message
        #udf.hide_cf_loader()#;
    </script>

    </cfoutput>
</cffunction>


<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~ save changes and bail out ~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cffunction name="save_everyday_merch" output="true" hint="Save changes in the backend database and bail out">
    <cfquery datasource="#application.datasource#">
        EXEC Planner_Merch_Copy_Paste_Save #form.programID#, '#copy_paste_table#'
    </cfquery>

    <script>
        <cfif structKeyExists( form, "parent_callBack" ) and form.parent_callBack.trim().len()>
            // call a parent page function to refresh everyday and merch
            <cfoutput>
                window.opener.#form.parent_callBack#();
            </cfoutput>
        </cfif>

        window.close();
    </script>
</cffunction>
