<CFOUTPUT>
<CFSET PAGETITLE = "PRODUCT REPLACEMENT MANAGEMENT">
</CFOUTPUT>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE></TITLE>
<SCRIPT SRC="/script/javascript/string_functions.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dom_common.js"></SCRIPT>
<cfoutput><SCRIPT LANGUAGE="JavaScript" SRC="product_replacement_management.js"></SCRIPT></cfoutput>

</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Growth Component List Page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<CFPARAM NAME="url.display" 	DEFAULT="">

<CFPARAM NAME="form.display" 	DEFAULT="#url.display#">
<CFPARAM NAME="form.command" 	DEFAULT="">
<CFPARAM NAME="form.returnTo" 	DEFAULT="">
<CFPARAM NAME="form.RID" 	DEFAULT="0">

<CFPARAM NAME="form.Item_Replacement_Header_Notes" 	DEFAULT="">
<CFPARAM NAME="form.Product_List" 	DEFAULT="">

<cfset ProductReplacementManager = CreateObject("component","components.settings.ProductReplacementManager").init() />



<!---****************************** START COMMANDS ***********************************--->
<!---/////////////ADD product_replacement///////////--->
<cfif form.command eq "addEditProd">
	<cfset msgArray = ProductReplacementManager.saveProductReplacement(
			id = form.RID,
			notes = form.Item_Replacement_Header_Notes,
			productList = form.Product_List,
			userId = request.accessStructure.User_ID) />
	
	<cfif msgArray[1] NEQ "">
		<cfset sSaveMsg = msgArray[1] />
		<cfset form.display = "addEditProd" />
		<cfset form.command = "" />
	<cfelse>
		<cflocation addtoken="no" url="index.cfm" />
	</cfif>
<cfelseif form.command eq "deactivate">
	<cfset msgArray = ProductReplacementManager.deactivateProductReplacement(
			id = form.RID,
			userId = request.accessStructure.User_ID) />
	
	<cfif msgArray[1] NEQ "">
		<cfset sSaveMsg = msgArray[1] />
		<cfset form.display = "activeList" />
		<cfset form.command = "" />
	<cfelse>
		<cflocation addtoken="no" url="index.cfm" />
	</cfif>
<cfelseif form.command eq "activate">
	<cfset msgArray = ProductReplacementManager.activateProductReplacement(
			id = form.RID,
			userId = request.accessStructure.User_ID) />	
	
	<cfif msgArray[1] NEQ "">
		<cfset sSaveMsg = msgArray[1] />
		<cfset form.display = "inactiveList" />
		<cfset form.command = "" />
	<cfelse>
		<cflocation addtoken="no" url="index.cfm" />
	</cfif>
<cfelseif form.command eq "delete">
	<cfset msgArray = ProductReplacementManager.deleteProductReplacement(
			id = form.RID,
			userId = request.accessStructure.User_ID) />	
	
	<cfif msgArray[1] NEQ "">
		<cfset sSaveMsg = msgArray[1] />
		<cfset form.display = "inactiveList" />
		<cfset form.command = "" />
	<cfelse>
		<cflocation addtoken="no" url="index.cfm" />
	</cfif>
</cfif>

<!------
<cfif form.command eq "addDist">	
	<cfscript>
		stError = StructNew();
		stError.bNameExists = compAlias.addDistAlias(form.Distributor_Alias,form.Distributor_List,request.accessStructure.User_ID);

		if(stError.bNameExists NEQ 0 )
		{			
			form.display = "addDist";
		}
		
	</cfscript> 

<cfelseif form.command eq "addEditProd">	
	<cfscript>
		stError = StructNew();
		stError.bNameExists = compAlias.addEditProdAlias(form.Product_Alias,form.Product_List,request.accessStructure.User_ID);
		if(stError.bNameExists NEQ 0)
		{			
			form.display = "addEditProd";
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
----->
<!---****************************** END COMMANDS ***********************************--->


<!---****************************** START DISPLAY ***********************************--->


<cfinclude template="product_replacement_header.cfm" />

<FORM ACTION="index.cfm" METHOD="post" NAME="DataForm">

<!--switch for each action--->
<cfswitch expression="#form.display#">
	
	<cfcase value="addEditProd">
		<cfinclude template="product_replacement_add.cfm" />
	</cfcase>
	
	<cfcase value="inactiveList">
		<cfset bActive = 0 />
		<cfinclude template="product_replacement_list.cfm" />
	</cfcase>
	
	<cfdefaultcase>
		<cfset bActive = 1 />
		<cfinclude template="product_replacement_list.cfm" />
	</cfdefaultcase>

</cfswitch>	

<cfoutput>
<!---hidden form fields--->
<input name="rid" type="hidden" value="#form.RID#" />
<input name="display" type="hidden" value="#form.display#" />
<input name="command" type="hidden" value="#form.command#" />
<input name="returnTo" type="hidden" value="#form.returnTo#"/>
</cfoutput>
</FORM>

</BODY>
</HTML>
