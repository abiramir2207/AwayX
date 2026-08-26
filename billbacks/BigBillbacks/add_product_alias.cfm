<cfoutput><SCRIPT LANGUAGE="JavaScript" SRC="bigbillback.js"></SCRIPT></cfoutput>

<cfscript>
	compAlias = CreateObject("component","components.settings.AliasManagement.Alias");
	addProd = compAlias.addProdAlias(form.Product_Alias,form.Product_List,request.accessStructure.User_ID);
	
</cfscript>

<cfif addProd IS 0>
<!---This contains some hardcoded values from the calling parent page --->
<cfset parentField = "opener.document.all.BBBValidation.Product_" & form.Big_Billback_ID>

 <script LANGUAGE="JavaScript">
	<cfoutput>#parentField#</cfoutput>.style.backgroundColor = 'white';
	window.close();
	
</script> 
<cfelse>
	<cfoutput>
		<cflocation url="find_product.cfm?stError=1&Product_Alias=#form.Product_Alias#&Big_Billback_ID=#form.Big_Billback_ID#">
	</cfoutput>
</cfif>