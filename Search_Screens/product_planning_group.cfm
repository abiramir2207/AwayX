<!---------------------------------------------------------------------------------------------------------------------
      Template: \Search_Screens\product_planning_group.cfm
      Date:     June 22, 2011
      Author:   Chris Nguyen
      Purpose:  Display/import product planning groups
----------------------------------------------------------------------------------------------------------------------->

<cfscript>
  attr = {};
  attr.pg_group_type = 1;
  attr.legend = "Product Planning Groups";
</cfscript>

<cfinclude template = "\search_screens\planning_group.cfm">