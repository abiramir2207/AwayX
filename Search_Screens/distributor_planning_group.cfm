<!---------------------------------------------------------------------------------------------------------------------
      Template: \Search_Screens\distributor_planning_group.cfm
      Date:     June 22, 2011
      Author:   Chris Nguyen
      Purpose:  Display/import distributor planning groups
----------------------------------------------------------------------------------------------------------------------->

<cfscript>
  attr = {};
  attr.pg_group_type = 2;
  attr.legend = "Distributor Planning Groups";
</cfscript>

<cfinclude template = "\search_screens\planning_group.cfm">