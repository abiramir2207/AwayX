<!---------------------------------------------------------------------------------------------------------------------
      Template: \billbacks\common\manual_reject.cfm
      Date:     2015 November
      Author:   Chris Nguyen
      Purpose:  Update database to support manual reject of a billback
	  Params:   URL.BBID - required, varchar, billback unique ID
----------------------------------------------------------------------------------------------------------------------->
<cfstoredproc procedure="BB_Manual_Reject" datasource="#application.datasource#">
	<cfprocparam cfsqltype="cf_sql_varchar" dbVarName="@Billback_ID" value="#URL.BBID#">
	<cfprocparam cfsqltype="cf_sql_varchar" dbVarName="@User_ID" value="#REQUEST.AccessStructure.User_ID#">
</cfstoredproc>

<script>
	parent.location.reload();
</script>

