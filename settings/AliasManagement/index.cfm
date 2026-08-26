<cfsilent>
<CFPARAM NAME="form.display" 	DEFAULT="search">
<CFPARAM NAME="form.command" 	DEFAULT="">
<CFPARAM NAME="form.returnTo" DEFAULT="">
<CFPARAM NAME="form.compID" 	DEFAULT="">

<cfswitch expression="#form.display#">
	<cfcase value="search">   <cfset selectedIndex = 0> </cfcase>
	<cfcase value="addProd">		<cfset selectedIndex = 1> </cfcase>
	<cfcase value="addDist">		<cfset selectedIndex = 2> </cfcase>
	<cfdefaultcase>        		<cfset selectedIndex = 0> </cfdefaultcase>
</cfswitch>	
</cfsilent>
<cfmodule template="/customTags/layout.cfm" layoutID = "aliasManagement" selectedIndex = "#selectedIndex#" helpLink = "yes">
<CFOUTPUT>
<CFSET PAGETITLE = "ALIAS MANAGEMENT">
</CFOUTPUT>
<SCRIPT SRC="/script/javascript/string_functions.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dom_common.js"></SCRIPT>
<cfoutput><SCRIPT LANGUAGE="JavaScript" SRC="alias_management.js"></SCRIPT></cfoutput>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Growth Component List Page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<cfscript>
	compAlias = CreateObject("component","components.settings.AliasManagement.Alias");
</cfscript>


<!---****************************** START COMMANDS ***********************************--->
<!---/////////////ADD ALIAS///////////--->
<cfif form.command eq "addDist">	
	<cfscript>
		stError = StructNew();
		stError.bNameExists = compAlias.addDistAlias(form.Distributor_Alias,form.Distributor_List,request.accessStructure.User_ID);

		if(stError.bNameExists NEQ 0 )
		{			
			form.display = "addDist";
		}
		
	</cfscript> 

<cfelseif form.command eq "addProd">	
	<cfscript>
		stError = StructNew();
		stError.bNameExists = compAlias.addProdAlias(form.Product_Alias,form.Product_List,request.accessStructure.User_ID);
		if(stError.bNameExists NEQ 0)
		{			
			form.display = "addProd";
		}
		
	</cfscript> 

<!---/////////////DELETE SELECTED ALIAS///////////--->
<cfelseif form.command eq "deleteDistributorAlias">
		
 	<cfscript>
		compAlias.deleteDistributorAlias(form.compId);
	</cfscript> 

<!---/////////////DELETE SELECTED ALIAS///////////--->
<cfelseif form.command eq "deleteProductAlias">
		
 	<cfscript>
		compAlias.deleteProductAlias(form.compId);
	</cfscript> 
	
<!---/////////////DELETE SELECTED ALIAS///////////--->
<cfelseif form.command eq "editDist">
		
 	<cfscript>
			compAlias.update(1,form.Distributor_Alias,form.Distributor_List,request.accessStructure.User_ID,form.compId);	
	</cfscript> 
	
<!---/////////////DELETE SELECTED ALIAS///////////--->
<cfelseif form.command eq "editProd">
		
 	<cfscript>

	compAlias.update(2,form.Product_Alias,form.Product_List,request.accessStructure.User_ID,form.compId);
	</cfscript> 
		
</cfif>


	
<cfset form.command = "" />

<!---****************************** END COMMANDS ***********************************--->


<!---****************************** START DISPLAY ***********************************--->


<!---<cfinclude template="alias_header.cfm" />--->

<FORM ACTION="index.cfm" METHOD="post" NAME="DataForm">

<!--switch for each action--->
<cfswitch expression="#form.display#">
	
	<cfcase value="search">
		<cfinclude template="alias_search.cfm" />
	</cfcase>

	<cfcase value="addProd">
		<cfinclude template="alias_prod_add.cfm" />
	</cfcase>
	
	<cfcase value="addDist">
		<cfinclude template="alias_dist_add.cfm" />
	</cfcase>
	
	<cfdefaultcase>
		<cfinclude template="alias_search.cfm" />
	</cfdefaultcase>

</cfswitch>	

<cfoutput>
<!---hidden form fields--->
<input name="compId" type="hidden" value="#form.compId#" />
<input name="display" type="hidden" value="#form.display#" />
<input name="command" type="hidden" value="#form.command#" />
<input name="returnTo" type="hidden" value="#form.returnTo#"/>
</cfoutput>
</FORM>

</cfmodule>