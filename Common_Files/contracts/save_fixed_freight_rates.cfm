<cfparam name="form.contract_main_id" default="0">
<cfparam name="form.product_list" default="">
<cfparam name="form.distributor_list" default="">
<cfparam name="form.editproduct" default="0">
<cfparam name="form.parentformname" default="">


<CFTRANSACTION ACTION="BEGIN">
<cfif not structKeyExists(form,'newComponent') or (structKeyExists(url, 'deleteComponent'))>
<CFQUERY NAME="deletefixedfreightdata" datasource="#application.datasource#">
	UPDATE Program_Fixed_Freight_Rates
	set deleted = 1
	<cfif structKeyExists(url,'deleteComponent') and structKeyExists(url,'componentId')>
		where Program_ID = #url.programId#
		and Component_Name_Id = #url.componentId#
		<cfif structKeyExists(url, "paidTo")>
		 and Paid_To = #url.paidTo#
		<cfelse>
		 and Paid_To = #form.paidTo#
		</cfif>
	 <cfelse>
	   where Program_ID = #FORM.contract_main_id#
	</cfif>
	<cfif form.editproduct EQ 1>
	and product_id in (#ListQualify(form.Product_List, "'", ",")#)
	</cfif>
</CFQUERY>
</cfif>

<cfif len(form.product_list) NEQ 0 and len(form.distributor_list) NEQ 0>
	<cfloop from="1" to="#ListLen(form.distributor_list)#" index="i">
	<cfset distributor_id = ListGetAt(form.distributor_list,i)>
	<cfset recustomer_id = replace(distributor_id, "-", "_", "ALL")>
		<cfloop from="1" to="#ListLen(form.PRODUCT_LIST)#" index="j">
		<cfset product_id = ListGetAt(form.PRODUCT_LIST,j)>
		<cfset reproduct_id = replace(product_id, "-", "_", "ALL")>
		<cfparam name="form.freight_C#recustomer_id#_P#reproduct_id#" default="0">
		<cfparam name="form.delv_prc_#recustomer_id#_#reproduct_id#" default="0">
		<cfif not len(trim(evaluate("form.freight_C#recustomer_id#_P#reproduct_id#")))>
			<cfset "form.freight_C#recustomer_id#_P#reproduct_id#" = 0 />
		</cfif>
		<cfset fob_price = 0>
		<cfset fob_price = evaluate("form.delv_prc_#recustomer_id#_#reproduct_id#") - evaluate("form.freight_C#recustomer_id#_P#reproduct_id#")>
	
	<CFQUERY NAME="getFreightProduct" datasource="#application.datasource#">
			SELECT Program_Fixed_Freight_id
			FROM Program_Fixed_Freight_Rates
			Where Program_ID = #FORM.contract_main_id#
			And   Component_Name_Id = '#form.component_id#'
			And   Product_Id = '#product_id#'
			AND   Customer_Id = '#distributor_id#'
			And   Deleted = 0
			<cfif structKeyExists(url, "paidTo")>
				 and Paid_To = #url.paidTo#
			<cfelse>
				 and Paid_To = #form.paidTo#
			</cfif>
	</CFQUERY>
	
	<!--- <cfif structKeyExists(form,'newComponent') and form.newComponent is 1> --->
	<cfif getFreightProduct.recordcount EQ 0>
		<CFQUERY NAME="InsertNewProduct" datasource="#application.datasource#">
					INSERT INTO Program_Fixed_Freight_Rates
						(Program_ID, 
						Product_Id, 
						Customer_Id, 
						Component_Name_Id,
						Delivered_Price,
						Freight_Rate,
						Freight_UOM,
						FOB_Price,
						Paid_To)
					VALUES
						(#FORM.contract_main_id#, 
						'#product_id#', 
						'#distributor_id#', 
						'#form.component_id#',
						<CFIF evaluate("form.delv_prc_#recustomer_id#_#reproduct_id#") EQ "">'0'<CFELSE>#evaluate("form.delv_prc_#recustomer_id#_#reproduct_id#")#</CFIF>,
						<CFIF evaluate("form.freight_C#recustomer_id#_P#reproduct_id#") EQ "">'0'<CFELSE>#evaluate("form.freight_C#recustomer_id#_P#reproduct_id#")#</CFIF>, 
						2, 
						#fob_price#,
						<cfif structKeyExists(url, "paidTo")>
		 				#url.paidTo#
					    <cfelse>
		 				#form.paidTo#
						</cfif>)
			</CFQUERY>
		<cfelse>	
			 <cfquery name="updateFreightByComponent" datasource="#application.datasource#">
			 	UPDATE Program_Fixed_Freight_Rates
			    Set Delivered_Price = <CFIF evaluate("form.delv_prc_#recustomer_id#_#reproduct_id#") EQ "">'0'<CFELSE>#evaluate("form.delv_prc_#recustomer_id#_#reproduct_id#")#</CFIF>,
					Freight_Rate = 	 <CFIF evaluate("form.freight_C#recustomer_id#_P#reproduct_id#") EQ "">'0'<CFELSE>#evaluate("form.freight_C#recustomer_id#_P#reproduct_id#")#</CFIF>, 
					Freight_UOM = 2,
					FOB_Price = #fob_price#
				Where Program_Fixed_Freight_id = #getFreightProduct.Program_Fixed_Freight_id#
			 </cfquery>
		</cfif>	
		</cfloop>
	</cfloop>
</cfif>

<CFTRANSACTION ACTION="COMMIT">
			
</CFTRANSACTION>

<script>
<cfif not structKeyExists(url, 'deleteComponent')>
<cfif form.parentformname NEQ "">
opener.document.all.<CFOUTPUT>#form.parentformname#</CFOUTPUT>.submit();	
<cfelse>
<!--- Dev Note: Milan (15274) When the user applied freight to the individual products and then clicked on save, the message popped
     up saying "freight rates are not applied. I have commented this out so that we do not see that message. The parent page needs
			to refresh in this case too --->
<!---<cfif form.editproduct EQ 0>--->
if(window.opener){
opener.document.all.FixedComponents.submit();
}
<!---</cfif>--->
</cfif>
</cfif>
window.close();
</script>