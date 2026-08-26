

<CFPARAM NAME="CSL_Contract_Main_ID" DEFAULT="">
<CF_CRYP type="de" string="#URL.CID#" key="#request.key#" return="CSLDeCID">
<CFSET CSL_Contract_Main_ID = URL.CID>
<CF_CRYP type="en" string="#CSL_Contract_Main_ID#" key="#request.key#" return="CSLEncCID">

<CFPARAM NAME="CSL_CallingPageCode" DEFAULT="">

<CFQUERY NAME="CSLGetContractInfo" datasource="#application.datasource#">
	SELECT *
	FROM Contract_Main
	WHERE Contract_Main_ID = '#CSLDeCID.value#'
</CFQUERY>

<CFQUERY NAME="CSLGetProducts" datasource="#application.datasource#">
SELECT *
FROM Contract_products
WHERE Contract_Main_ID = '#CSLDeCID.value#' AND Contract_Main_ID <> 0
</CFQUERY>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Untitled</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->




<BR>
<CF_TAB_GROUP2 Width="95%">
	
	<CF_TAB_ITEM2 
		Title="view contract" 
		ToolTip="xxxxxxxxxxxxxxxxxxxxxxxx"
		URLVariableName="CID"
		URLVariableValue="#URL.CID#">
		<CFINCLUDE TEMPLATE="/common_files/contracts/contract_edit_menu.cfm">
	</CF_TAB_ITEM2>

	<CFIF CSLGetContractInfo.RecordCount EQ 0><CFSET image="no"><CFELSE><CFSET image="yes"></CFIF>
	<CF_TAB_ITEM2 
		Title="<IMG SRC=""/images/#image#_small.gif"" BORDER=""0"" ALT=""""> basic info" 
		ToolTip="xxxxxxxxxxxxxxxxxxxxxxxxxxx"
		URLVariableName="CID"
		URLVariableValue="#URL.CID#">
		<CFINCLUDE TEMPLATE="/common_files/contracts/contract_create_1_form.cfm">
	</CF_TAB_ITEM2>
	
	<CFIF CSLGetContractInfo.Operator_ID EQ 0 OR len(CSLGetContractInfo.Operator_ID) EQ 0><CFSET image="no"><CFELSE><CFSET image="yes"></CFIF>
	<CF_TAB_ITEM2 Title="<IMG SRC=""/images/#image#_small.gif"" BORDER=""0"" ALT=""""> <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput>" 
		ToolTip="xxxxxxxxxxxxxxxxxxxxxxxxxxx"
		URLVariableName="CID"
		URLVariableValue="#URL.CID#"
		>
		

		<CFINCLUDE TEMPLATE="/common_files/contracts/select_operators.cfm">
	</CF_TAB_ITEM2>

	<CFIF CSLGetContractInfo.broker_IDs EQ 0 OR len(CSLGetContractInfo.broker_IDs) EQ 0><CFSET image="no"><CFELSE><CFSET image="yes"></CFIF>
	<CF_TAB_ITEM2 Title="<IMG SRC=""/images/#image#_small.gif"" BORDER=""0"" ALT=""""> brokers" 
		ToolTip="xxxxxxxxxxxxxxxxxxxxxxxxxxx"
		URLVariableName="CID"
		URLVariableValue="#URL.CID#">
		<CFINCLUDE TEMPLATE="/common_files/contracts/select_brokers.cfm">
	</CF_TAB_ITEM2>

	<CFIF CSLGetContractInfo.distributor_IDs EQ 0 OR len(CSLGetContractInfo.distributor_IDs) EQ 0><CFSET image="no"><CFELSE><CFSET image="yes"></CFIF>	
	<CF_TAB_ITEM2 Title="<IMG SRC=""/images/#image#_small.gif"" BORDER=""0"" ALT=""""> <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput>" 
		ToolTip="xxxxxxxxxxxxxxxxxxxxxxxxxxx"
		URLVariableName="CID"
		URLVariableValue="#URL.CID#">
		<CFINCLUDE TEMPLATE="/common_files/contracts/select_distributors.cfm">
	</CF_TAB_ITEM2>

	<CFIF CSLGetProducts.Recordcount EQ 0><CFSET image="no"><CFELSE><CFSET image="yes"></CFIF>	
	<CF_TAB_ITEM2 Title="<IMG SRC=""/images/#image#_small.gif"" BORDER=""0"" ALT=""""> products" 
		ToolTip="xxxxxxxxxxxxxxxxxxxxxxxxxxx"
		URLVariableName="CID"
		URLVariableValue="#URL.CID#">
		<CFINCLUDE TEMPLATE="/common_files/contracts/select_products.cfm1">
	</CF_TAB_ITEM2>
	<CFOUTPUT>
	<CF_TAB_ITEM2 Title="<IMG SRC=""/images/#image#_small.gif"" BORDER=""0"" ALT=""""> #Application.RebateLabel#" 
		ToolTip="xxxxxxxxxxxxxxxxxxxxxxxxxxx"
		URLVariableName="CID"
		URLVariableValue="#URL.CID#">
		<CFINCLUDE TEMPLATE="/common_files/contracts/contract_products_rebate_entry.cfm">
	</CF_TAB_ITEM2>
</CFOUTPUT>
</CF_TAB_GROUP2>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>


