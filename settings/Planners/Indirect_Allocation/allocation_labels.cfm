<!---
  * ====================================================================================================
  *    @File: settings\Planners\Indirect_Allocation\allocation_labels.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2022 May
  *
  * @Remarks: Edit planner indirect allocation
  *
  * ====================================================================================================
--->
<cfscript>
    if ( isDefined( "qallocation" ) eq false ) {
        allocation_cfc = createObject("component", "mvc.models.planner.IndirectAllocation");
        qallocation    = allocation_cfc.getHeaders( 'WHERE Planner_Indirect_Allocation_Header_ID = #URL.id#' );
    }

    labels.distributors = ( qallocation.Distributor_Group_Level_ID eq 0 )
                            ? application.returned_customer_setting.distributor_label_singular
                            : createObject("component","components.customer.Group.DistributorGroupAttributeManager").getGroupAttributeInfo(groupLevelTypeId = qallocation.Distributor_Group_Level_ID).Label;
    labels.operators = ( qallocation.Operator_Group_Level_ID eq 0 )
                            ? application.returned_customer_setting.operator_label_singular
                            : createObject("component","components.operator.Group.OperatorGroupAttributeManager").getOperatorGroupAttributes(groupLevelId = qallocation.Operator_Group_Level_ID).Operator_Group_Attribute_Name_Field;
    labels.products = ( qallocation.Product_Group_Level_ID eq 0 )
                            ? application.returned_customer_setting.Item_Label
                            : createObject("component","components.products.group.ProductGroupAttributeManager").getProductGroupLabel(groupLevelId = qallocation.Product_Group_Level_ID);
</cfscript>
