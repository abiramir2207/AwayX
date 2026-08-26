<cfset HTTP_REFERER_Array = listtoarray(cgi.HTTP_REFERER, "/")>
<!--- 
if a search has not been conducted prior to recieving the delete request
this code must delete directly from the contract lookup tables
otherwise
by deleting the item from the finalitemlist and returning the modified list
to the requesting page will take advantage of already existing deletion code
 --->
<cfoutput>

<cfif isdefined("FORM.listofpagefieldnames")>
	<!--- delete from list --->
	<cfscript>
		if(isdefined("form.finalitemlist")) {
			varA = listfind(form.finalitemlist, form.Other_ID);
			if(varA NEQ 0) {
				form.finalitemlist = listdeleteat(form.finalitemlist, varA);
			}
		}

		if(isdefined("form.SELECTEDITEMS")) {
			varA = listfind(form.SELECTEDITEMS, form.Other_ID);
			if(varA NEQ 0) {
				form.SELECTEDITEMS = listdeleteat(form.SELECTEDITEMS, varA);
			}
		}
	</cfscript>
<cfelse>
	<!--- delete from table --->
	<cfset targetTable = "">
	<cfset targetColumn = "">	
	<cfswitch expression="#form.type_id#">
		<cfcase value="1">
			<cfset targetTable = "Contract_Operators">
			<cfset targetColumn = "BSA_Operator_ID">
		</cfcase>
		<cfcase value="2">
			<cfset targetTable = "Contract_Distributors">
			<cfset targetColumn = "BSA_Foodservice_Customers_ID">
		</cfcase>
		<cfcase value="3">
			<cfset targetTable = "Contract_Brokers">
			<cfset targetColumn = "BSA_Foodservice_Brokers_ID">
			
		</cfcase>
	</cfswitch>
	<CF_Cryp type="de" key="#request.key#" string="#form.CID#">
	<cfif len(targetTable) NEQ 0 AND len(targetColumn) NEQ 0>
		<cfquery name="deleteItem" datasource="#application.datasource#">
			UPDATE #targetTable#
			SET Deleted = 1
			WHERE 
				#targetColumn# = '#form.Other_ID#'
				AND
				Contract_Main_ID = '#cryp.value#'
		</cfquery>
		<cfif form.type_id EQ 2>
			<!--- if distributor, delete the autobrokers ---->
			<CFQUERY NAME="" DATASOURCE="#application.datasource#">
				UPDATE	Contract_Brokers
				SET		Deleted = 1
				WHERE
						Contract_Brokers.Contract_Main_ID = #cryp.value#
						AND
						Contract_Brokers.Auto_Selection = 1
						AND
						Contract_Brokers.Deleted = 0
						AND
						EXISTS
						(
						SELECT	BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID
						FROM	BSA_Foodservice_Customers
						WHERE
							BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = '#form.Other_ID#'
							AND
							Contract_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID
						)
			</CFQUERY>
		</cfif>
	</cfif>
	
</cfif>

<form action="#HTTP_REFERER_Array[arraylen(HTTP_REFERER_Array)]#" method="post" name="myForm" id="myForm">
	<cfif isdefined("FORM.listofpagefieldnames")>
		<cfloop index="x" list="#FORM.listofpagefieldnames#">
			<input type="Hidden" name="#x#" value="#evaluate("form.#x#")#">
		</cfloop>
	<cfelse>
		
	</cfif>
</form>
</cfoutput>
<cfflush>
<script>
	document.all.myForm.submit();
</script>