<CF_CRYP type="de" string="#URL.CID#" key="#request.key#">

<CFQUERY NAME="GetContractInfo" datasource="#application.datasource#">
	SELECT *
	FROM Contract_Main
	WHERE Contract_Main_ID = #cryp.value#
</CFQUERY>

<CFQUERY NAME="GetContractProducts" datasource="#application.datasource#">
	SELECT *
	FROM Contract_Products
	WHERE Contract_Main_ID = #cryp.value#
</CFQUERY>

<CFSET ColumnList = GetContractInfo.columnlist>
<CFSET Values = "">


<CFSET Structure_New = StructNew()>

<CFLOOP INDEX="ListItem" LIST="#GetContractInfo.ColumnList#" DELIMITERS=",">
	<CFSET "Structure_New.#ListItem#" = evaluate("GetContractInfo.#ListItem#")>
</CFLOOP>

<CFSET ColumnList = structkeylist(Structure_New)>

<CFSET ListOfColumnsToExclude="CONTRACT_MAIN_ID">

<cfloop index="ListItem" list="#ListOfColumnsToExclude#">
	<CFSET ColumnList = listdeleteat(ColumnList,listfind(ColumnList,listitem))>
</cfloop>

<CFSET LengthOfList = listlen(ColumnList)>

<CFQUERY NAME="SaveTemplate" datasource="#application.datasource#">
	SET NOCOUNT ON
	INSERT INTO Contract_Main
		(#ColumnList#)
	VALUES
		(
		<CFSET x = 1>
		<CFLOOP INDEX="ListItem" LIST="#ColumnList#" DELIMITERS=",">
			'#replacenocase(evaluate("Structure_New.#ListItem#"),"'", "''", 'ALL')#'<CFIF x NEQ LengthOfList>,</CFIF>
			<CFSET x = x + 1>
		</CFLOOP>
		)
		SELECT Contract_Main_ID = @@IDENTITY
		SET NOCOUNT OFF		
</CFQUERY>
<cfinclude template="contract_number_generator.cfm">
<cfquery name="UpdateContract" datasource="#application.datasource#">
	UPDATE Contract_Main
	SET 
		template = <CFIF isdefined("URL.TT")>1<CFELSE>0</CFIF>,
		Contract_Number = '<CFIF isdefined("URL.TT")>TEMPLATE<CFELSE>#generator_contract_number#</CFIF>'
	WHERE Contract_Main_ID = '#SaveTemplate.Contract_Main_ID#'
</cfquery>


<CFSET Contract_Products_Column_List = GetContractProducts.ColumnList>

<CFSET ListOfColumnsToExclude="CONTRACT_PRODUCTS_ID">

<cfloop index="ListItem" list="#ListOfColumnsToExclude#">
	<CFSET Contract_Products_Column_List = listdeleteat(Contract_Products_Column_List,listfind(Contract_Products_Column_List,listitem))>
</cfloop>

<cfloop query="GetContractProducts">
	<CFSET z = 1>
	<cfquery name="SaveProducts" datasource="#application.datasource#">
		INSERT INTO Contract_Products
		(#Contract_Products_Column_List#)
		VALUES
		(
			<cfloop index="ListItem1" list="#Contract_Products_Column_List#">
				<CFIF ListItem1 NEQ "CONTRACT_MAIN_ID"><CFSET temp = evaluate("GetContractProducts.#ListItem1#")><CFELSE><CFSET temp = SaveTemplate.Contract_Main_ID></CFIF>
				'#temp#'<CFIF z NEQ listlen(Contract_Products_Column_List)>,</CFIF><CFSET z = z + 1>
			</CFLOOP>
		)
	</cfquery>
</CFLOOP>
<CF_CRYP type="en" string="#SaveTemplate.Contract_Main_ID#" key="#request.key#">
<CFLOCATION url="contract_edit_menu.cfm?CID=#cryp.value#">






