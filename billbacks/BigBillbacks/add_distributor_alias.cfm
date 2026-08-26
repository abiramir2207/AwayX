<cfoutput><SCRIPT LANGUAGE="JavaScript" SRC="bigbillback.js"></SCRIPT></cfoutput>

<cfscript>
	compAlias = CreateObject("component","components.settings.AliasManagement.Alias");
	addDist = compAlias.addDistAlias(form.Distributor_Alias,form.Distributor_List,request.accessStructure.User_ID);
	
</cfscript>

<cfdump var="#addDist#">

<cfif addDist IS 0>
<!---This contains some hardcoded values from the calling parent page --->
<cfset parentField = "opener.document.all.BBBValidation.Distributor_" & form.Big_Billback_ID>

 <script LANGUAGE="JavaScript">
	<cfoutput>#parentField#</cfoutput>.style.backgroundColor = 'white';
	window.close();
	
</script> 
<cfelse>
	<cfoutput>
		<cflocation url="find_distributor.cfm?stError=1&Distributor_Alias=#form.Distributor_Alias#&Big_Billback_ID=#form.Big_Billback_ID#">
	</cfoutput>
</cfif>