<!---
  * ====================================================================================================
  *    @File: mvc\Models\Planner\IndirectAllocation.cfc
  *  @Author: Chris Nguyen
  *    @Date: 2022 May
  *
  * @Remarks:
  *
  * ====================================================================================================
--->
<cfcomponent name="Planner Indirect Allocation" displayname="Planner Indirect Allocation">

<cfscript>
    function getHeaders( where_clause ) output="false" {
        param name="arguments.where_clause" default="";

        local.max_rows = application.util.query.get_setting( "Number_Of_Years_For_Planner_Indirect_Allocation", 0 );
        if ( val( local.max_rows ) eq 0 ) {
            local.max_rows = 21;
        }

        return queryExecute( "
                                SELECT TOP #local.max_rows#
                                        Planner_Indirect_Allocation_Header_ID
                                        ,Fiscal_Year
                                        ,Distributor_Group_Level_ID
                                        ,Operator_Group_Level_ID
                                        ,Product_Group_Level_ID
                                  FROM Planner_Indirect_Allocation_Header
                                        #arguments.where_clause#
                                        ORDER BY Fiscal_Year DESC
                            "
                            ,{}, { datasource: application.datasource } );
    }


    function getDetail( header_id ) output="false" {
        return queryExecute( " EXEC Planner_Indirect_Allocation_Detail_By_ID #arguments.header_id# ", {}, { datasource: application.datasource } );
    }


    function getUploads( required numeric id ) output="false" {

        return queryExecute( "  SELECT upload.*, U.Name_First + ' ' + U.Name_Last AS Name
                                  FROM Planner_Indirect_Allocation_Upload upload
		                                INNER JOIN _USERS U ON U.user_ID = Uploaded_by
                                 WHERE Planner_Indirect_Allocation_Header_ID = #arguments.id#
                                        ORDER BY Uploaded_Date DESC
                            ", {}, { datasource: application.datasource } );
    }


    function uploadStatus( required numeric id ) output="false" {
        local.query = queryExecute( "  SELECT  Count ( 1 ) AS Detail_Count
                                              ,( SELECT  Count ( 1 )
                                                   FROM  Planner_Indirect_Allocation_Upload_Data
                                                  WHERE  Planner_Indirect_Allocation_Upload_ID = #arguments.id#
                                                            AND  Error_Message > ''
                                                ) AS Error_Count
                                        FROM  Planner_Indirect_Allocation_Upload_Data
                                        WHERE  Planner_Indirect_Allocation_Upload_ID = #arguments.id#
                            ", {}, { datasource: application.datasource } );

        return { Error_Count: local.query.error_count, Detail_Count: local.query.Detail_Count };
    }


    function getUploadByID( required numeric id ) output="false" {

        return queryExecute( "  SELECT upload.*, U.Name_First + ' ' + U.Name_Last AS Name
                                  FROM Planner_Indirect_Allocation_Upload upload
		                                INNER JOIN _USERS U ON U.user_ID = Uploaded_by
                                 WHERE Planner_Indirect_Allocation_Upload_ID = #arguments.id#
                            ", {}, { datasource: application.datasource } );
    }


    function getUploadDetail( upload_id ) output="false" {
        return queryExecute( " SELECT * FROM Planner_Indirect_Allocation_Upload_Data WHERE Planner_Indirect_Allocation_Upload_ID = #arguments.upload_id#", {}, { datasource: application.datasource } );
    }


    function getLabels( header_id ) output="false" {
        var labels   = {};
        var settings = {};

        if ( structKeyExists( arguments, "header_id" ) ) {
            var qallocation = getHeaders( 'WHERE Planner_Indirect_Allocation_Header_ID = #arguments.header_id#' );

            settings.Planner_Direct_Indirect_Allocation_Direct_Customer_Type   = qallocation.Distributor_Group_Level_ID;
            settings.Planner_Direct_Indirect_Allocation_InDirect_Customer_Type = qallocation.Operator_Group_Level_ID;
            settings.Planner_Direct_Indirect_Allocation_Product_Type           = qallocation.Product_Group_Level_ID;
        }
        else {
            settings = application.util.query.get_settings( [     "Planner_Direct_Indirect_Allocation_Direct_Customer_Type"
                                                                , "Planner_Direct_Indirect_Allocation_InDirect_Customer_Type"
                                                                , "Planner_Direct_Indirect_Allocation_Product_Type"
                                                            ], 0 );

        }

        labels.distributors = ( settings.Planner_Direct_Indirect_Allocation_Direct_Customer_Type eq 0 )
                                ? application.returned_customer_setting.distributor_label_singular
                                : createObject("component","components.customer.Group.DistributorGroupAttributeManager")
                                    .getGroupAttributeInfo( groupLevelTypeId = settings.Planner_Direct_Indirect_Allocation_Direct_Customer_Type )
                                    .Label;

        labels.operators = ( settings.Planner_Direct_Indirect_Allocation_InDirect_Customer_Type eq 0 )
                                ? application.returned_customer_setting.operator_label_singular
                                : createObject("component","components.operator.Group.OperatorGroupAttributeManager")
                                    .getOperatorGroupAttributes( groupLevelId = settings.Planner_Direct_Indirect_Allocation_InDirect_Customer_Type )
                                    .Operator_Group_Attribute_Name_Field;

        labels.products = ( settings.Planner_Direct_Indirect_Allocation_Product_Type eq 0 )
                                ? application.returned_customer_setting.Item_Label
                                : createObject("component","components.products.group.ProductGroupAttributeManager")
                                    .getProductGroupLabel( groupLevelId = settings.Planner_Direct_Indirect_Allocation_Product_Type );

        return labels;
    }
</cfscript>

</cfcomponent>
