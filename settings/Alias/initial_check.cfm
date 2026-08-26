<cfset variables.qgetDistributorLevelRanking = AliasManager.getDistributorLevelRanking()>

<!--- If the ranking is not set, ask the user to do so first --->
<cfif variables.qgetDistributorLevelRanking.RecordCount eq 0>
 <div align="center" style="color:red;fontsize:14;">
  <b>PLEASE SET THE RANKING FIRST</b>
 </div>
 <cfoutput>
	<!---hidden form fields--->
	<input name="display" type="hidden" value="#form.display#" />
	<input name="command" type="hidden" value="#form.command#" />
</cfoutput>
 <cfabort>
</cfif>
