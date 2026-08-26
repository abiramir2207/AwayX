<cfoutput>

		 <!---Rebate logic--->
		  <cfif trim(getProducts.Rebate_Case) IS NOT "">
		  
		 	<!--- <cfif i IS 2>
			<cfoutput>#i#</cfoutput>
			<cfdump var="#variables#">
			
				<Cfabort>
			</cfif> --->
		  	<cfset "FixedPrice_#i#" = "0.0000">
		     <!---CC always null for rebate--->
			  <cfset "CC_CS_#i#" = "0.0000">
			  <!---far right is total amount offered in program--->
		  	  <cfset "Total2_CS_#i#"   = getProducts.Rebate_Case>
			  <cfset "Total_CS_#i#"    =  evaluate("Total2_CS_#i#") - evaluate("ABC_CS_#i#")>
		  	  <cfset "Supplier_CS_#i#" =  evaluate("Total_CS_#i#") - evaluate("BSCC_CS_#i#")>
		  <cfelse>
		  	<cfset "Rebate_Case_#i#" = "0.0000">
		  </cfif>
		
		  
		 
		  <cfif blnSubmit IS 0 AND UseDBValues IS 1>
		  
		   <cfquery name="ValuesForThisProduct" dbtype="query">
			SELECT * FROM SavedValues
			WHERE Distributor_ID = '#DistributorID#'
			AND Product_ID = '#getProducts.BSA_Foodservice_Items_Master_ID#'
			AND Original_Rebate = #getProducts.Rebate_Case# 
			</cfquery>
			
			<!--- <cfdump var="#ValuesForThisProduct#"> --->
		  	<Cfif ValuesForThisProduct.Recordcount GT 0>
			<cfset "Supplier_CS_#i#" = ValuesForThisProduct.Supplier_CS>
		   	 <cfset "BSCC_CS_#i#" = ValuesForThisProduct.BSCC_CS>
			 <cfset "ABC_CS_#i#" = ValuesForThisProduct.ABC_CS>
			 <cfset "FixedPrice_#i#" = ValuesForThisProduct.Original_Fixed>
			 <cfset "CC_CS_#i#" = ValuesForThisProduct.CC_CS>
			 <cfif trim(getProducts.Rebate_Case) IS NOT "">
			 	<cfset "Total2_CS_#i#"   = getProducts.Rebate_Case>
			 <cfelse>
			 	<cfset "Total2_CS_#i#"   = 0>
			 </cfif>
			 <cfset "Total_CS_#i#"    =  evaluate("Total2_CS_#i#") - evaluate("ABC_CS_#i#")>
		
			<input type="hidden" name="RecordID_#i#" value="#ValuesForThisProduct.Sysco_DS_Program_ID#">
			
			</CFIF>
		  </cfif>
		<cfset "Rebate_Case_#i#" = getProducts.Rebate_Case>
		
		<input type="hidden" name="Original_Fixed_#i#" value="0">
		<input type="hidden" name="Original_Rebate_#i#" value="#evaluate("Rebate_Case_#i#")#">
		<input type="hidden" name="Product_ID_#i#" value="#ItemID#">
		<input type="hidden" name="Distributor_ID_#i#" value="#DistributorID#">
		<input type="hidden" name="WH_Number_#i#" value="">
		
		<tr> 
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF">&nbsp;</TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"><cfif getProducts.volume_cs NEQ ""><CF_formatnumber
	number = "#getProducts.volume_cs#" 
	decimals = "2"
	showcurrency = 0
>
&nbsp; 
</cfif>&nbsp;  </TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center">#getProducts.SUPC#&nbsp;</TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center">#getProducts.Item#&nbsp; </td>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center">#getProducts.Pack_Size#&nbsp;</TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center">ALL &nbsp; </TD>
            <TD STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center">#getProducts.Item_Desc#&nbsp; </td>

			
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"><CF_formatnumber
	number = "#evaluate("CC_CS_#i#")#" 
	decimals = "2"
	showcurrency = 1
>&nbsp; <input type="hidden" name="CC_CS_#i#" value="#evaluate("CC_CS_#i#")#"></TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center">
				<cfset replacedProductID = Replace(BSA_Foodservice_Items_Master_ID, "-", "_", "all") />
              <cfif form.generatexlsreport EQ 0 and CanEditProgram>
			  	<input type="hidden" name="Line_Number_Info_#i#" value="#replacedProductID#" discountType="2">
                <input type="text" name="Supplier_CS_#i#" value="<CF_formatnumber
	number = "#evaluate("Supplier_CS_#i#")#" 
	decimals = "2"
	showcurrency = 0
> " STYLE="WIDTH:50px;" ONKEYUP="clenseText(this,'0123456789.');" onChange="this.value = formatToDeciamalPlaces(this.value,2)" onBlur="addvalues2(#i#, 1);">
                <cfelse>
				<CF_formatnumber
	number = "#evaluate("Supplier_CS_#i#")#" 
	decimals = "2"
	showcurrency = 1
> &nbsp; </cfif> </TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"> 
              <cfif form.generatexlsreport EQ 0 and CanEditProgram>
                <input type="text" name="BSCC_CS_#i#" value="<CF_formatnumber
	number = "#evaluate("BSCC_CS_#i#")#" 
	decimals = "2"
	showcurrency = 0
> " STYLE="WIDTH:50px;" ONKEYUP="clenseText(this,'0123456789.');" onChange="this.value = formatToDeciamalPlaces(this.value,2)" onBlur="addvalues(#i#, 1);">
                <cfelse>
				<CF_formatnumber
	number = "#evaluate("BSCC_CS_#i#")#" 
	decimals = "2"
	showcurrency =1
> </cfif> </TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"> 
              <cfif form.generatexlsreport EQ 0 and CanEditProgram>
                <input type="text" name="Total_CS_#i#" value=" <CF_formatnumber
	number = "#evaluate("Total_CS_#i#")#" 
	decimals = "2"
	showcurrency = 0
> " STYLE="WIDTH:50px;" readonly>
                <cfelse>
                <CF_formatnumber
	number = "#evaluate("Total_CS_#i#")#" 
	decimals = "2"
	showcurrency = 1
> 
              </cfif> </TD>
            <TD  >&nbsp;</TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"> 
              <cfif form.generatexlsreport EQ 0 and CanEditProgram>
                <input type="text" name="ABC_CS_#i#" value="<CF_formatnumber
	number = "#evaluate("ABC_CS_#i#")#" 
	decimals = "2"
	showcurrency = 0
>" STYLE="WIDTH:50px;" ONKEYUP="clenseText(this,'0123456789.');" onChange="this.value = formatToDeciamalPlaces(this.value,2)" onBlur="addtotals(#i#, 1);">
                <cfelse>
				 <CF_formatnumber
	number = "#evaluate("ABC_CS_#i#")#" 
	decimals = "2"
	showcurrency = 1
>  </cfif> </TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"> 
              <cfif form.generatexlsreport EQ 0 and CanEditProgram>
                <input type="text" name="Total2_CS_#i#" value=" <CF_formatnumber
	number = "#evaluate("Total2_CS_#i#")#" 
	decimals = "2"
	showcurrency = 0
> " STYLE="WIDTH:50px;" readonly >
                <cfelse>
               <CF_formatnumber
	number = "#evaluate("Total2_CS_#i#")#" 
	decimals = "2"
	showcurrency = 1
></cfif> </TD>
<!--- <Td>#i#</TD> --->
          </TR>
		<!------ Get the variable for tracking which line # corresponds to which product, this will be used in the javascript ----->			
		<cfparam name="FORMVARSFORJS.#FORMVARSFORJS_REBATESTART#_#replacedProductID#" 	default="">
		<cfset Current_LineNumbers = Evaluate("FORMVARSFORJS.#FORMVARSFORJS_REBATESTART#_#replacedProductID#") />
		<cfset "FORMVARSFORJS.#FORMVARSFORJS_REBATESTART#_#replacedProductID#" = ListAppend(Current_LineNumbers, i, ",") />
</cfoutput>