<cfoutput>
		<cfset FixedPrice = getProducts.Fixed_Case>
		<cfset ProductID = getProducts.BSA_Foodservice_Items_Master_ID>
		
		<cfquery name="GetWarehouseAllowances" datasource="#application.datasource#">
				
		SELECT DISTINCT Default_WH, WH_Order, Sysco_Deal_Sheet_Geography.WH_Number, Sysco_Deal_Sheet_Geographic_Adjustment.BSA_Foodservice_Items_Master_ID, Sysco_Deal_Sheet_Geography.WH_Number, Sysco_Deal_Sheet_Geography.WH_Desc, 
		Sysco_Deal_Sheet_Geographic_Adjustment.Adjustment_Amount,
		Sysco_Deal_Sheet_Geographic_Adjustment.Effective_Date
		FROM Sysco_Deal_Sheet_Geographic_Adjustment
			INNER JOIN Sysco_Deal_Sheet_Geography 
			ON Sysco_Deal_Sheet_Geography.Sysco_Deal_Sheet_Geography_ID = Sysco_Deal_Sheet_Geographic_Adjustment.Sysco_Deal_Sheet_Geography_ID
			AND Sysco_Deal_Sheet_Geography.Deleted = 0
		WHERE Sysco_Deal_Sheet_Geographic_Adjustment.BSA_Foodservice_Items_Master_ID = '#ItemID#'
		AND 
		(
			Sysco_Deal_Sheet_Geography.WH_Number = '#Distributor_Warehouse#'
			OR 
			(
			(
			Sysco_Deal_Sheet_Geography.WH_Number <> '#Distributor_Warehouse#'
			AND Sysco_Deal_Sheet_Geography.Default_WH = 1
			AND Sysco_Deal_Sheet_Geography.WH_Order = 1
			)
			AND Exists
			(
			SELECT * FROM Sysco_Deal_Sheet_Geographic_Adjustment AS ShowSecondDefaultAdj 
			INNER JOIN Sysco_Deal_Sheet_Geography ShowSecondDefault_Geography
			ON ShowSecondDefault_Geography.Sysco_Deal_Sheet_Geography_ID = ShowSecondDefaultAdj.Sysco_Deal_Sheet_Geography_ID
			AND ShowSecondDefault_Geography.Deleted = 0
			WHERE 	ShowSecondDefaultAdj.BSA_Foodservice_Items_Master_ID = Sysco_Deal_Sheet_Geographic_Adjustment.BSA_Foodservice_Items_Master_ID
			AND	ShowSecondDefaultAdj.Adjustment_Amount IS NOT Null
			AND	ShowSecondDefaultAdj.Adjustment_Amount <> 0
			AND 	ShowSecondDefault_Geography.WH_Number = '#Distributor_Warehouse#'
			)
			)
			OR 
			(
			(
			Sysco_Deal_Sheet_Geography.WH_Number <> '#Distributor_Warehouse#'
			AND Sysco_Deal_Sheet_Geography.Default_WH = 1
			AND Sysco_Deal_Sheet_Geography.WH_Order = 2
			)
			AND Exists
			(
			SELECT * FROM Sysco_Deal_Sheet_Geographic_Adjustment AS ShowSecondDefaultAdj 
			INNER JOIN Sysco_Deal_Sheet_Geography ShowSecondDefault_Geography
			ON ShowSecondDefault_Geography.Sysco_Deal_Sheet_Geography_ID = ShowSecondDefaultAdj.Sysco_Deal_Sheet_Geography_ID
			AND ShowSecondDefault_Geography.Deleted = 0
			WHERE 	ShowSecondDefaultAdj.BSA_Foodservice_Items_Master_ID = Sysco_Deal_Sheet_Geographic_Adjustment.BSA_Foodservice_Items_Master_ID
			AND	ShowSecondDefaultAdj.Adjustment_Amount IS NOT Null
			AND	ShowSecondDefaultAdj.Adjustment_Amount <> 0
			AND 	ShowSecondDefault_Geography.WH_Number = '#Distributor_Warehouse#'
			)
			AND Exists
			(
			SELECT * FROM Sysco_Deal_Sheet_Geographic_Adjustment AS ShowSecondDefaultAdj 
			INNER JOIN Sysco_Deal_Sheet_Geography ShowSecondDefault_Geography
			ON ShowSecondDefault_Geography.Sysco_Deal_Sheet_Geography_ID = ShowSecondDefaultAdj.Sysco_Deal_Sheet_Geography_ID
			AND ShowSecondDefault_Geography.Deleted = 0
			WHERE 	ShowSecondDefaultAdj.BSA_Foodservice_Items_Master_ID = Sysco_Deal_Sheet_Geographic_Adjustment.BSA_Foodservice_Items_Master_ID
			AND	ShowSecondDefaultAdj.Adjustment_Amount IS NOT Null
			AND	ShowSecondDefaultAdj.Adjustment_Amount <> 0
			AND 	ShowSecondDefault_Geography.WH_Number <> '#Distributor_Warehouse#'
			AND 	ShowSecondDefault_Geography.Default_WH = 1
			AND 	ShowSecondDefault_Geography.WH_Order = 1
			)
			)
		)
		
		UNION
		
		SELECT DISTINCT Default_WH, WH_Order, Sysco_Deal_Sheet_Geography.WH_Number, '#ItemID#', Sysco_Deal_Sheet_Geography.WH_Number, Sysco_Deal_Sheet_Geography.WH_Desc, 
		0,
		getDate()
		FROM 	Sysco_Deal_Sheet_Geography 
		WHERE	Sysco_Deal_Sheet_Geography.Deleted = 0
		AND 
		(
			Sysco_Deal_Sheet_Geography.WH_Number = '#Distributor_Warehouse#'
			/* return only if this item does not have a record for WH_Number = '#Distributor_Warehouse#' */
			AND NOT Exists
			(
			SELECT * FROM Sysco_Deal_Sheet_Geographic_Adjustment AS ShowSecondDefaultAdj 
			INNER JOIN Sysco_Deal_Sheet_Geography ShowSecondDefault_Geography
			ON ShowSecondDefault_Geography.Sysco_Deal_Sheet_Geography_ID = ShowSecondDefaultAdj.Sysco_Deal_Sheet_Geography_ID
			AND ShowSecondDefault_Geography.Deleted = 0
			WHERE 	ShowSecondDefaultAdj.BSA_Foodservice_Items_Master_ID = '#ItemID#'
			AND 	ShowSecondDefault_Geography.WH_Number = '#Distributor_Warehouse#'
			)
			
		
		
			OR 
			(
			(
			Sysco_Deal_Sheet_Geography.WH_Number <> '#Distributor_Warehouse#'
			AND Sysco_Deal_Sheet_Geography.Default_WH = 1
			AND Sysco_Deal_Sheet_Geography.WH_Order = 1
			)
			/* return only if this item does have a record for WH_Number = '#Distributor_Warehouse#'
			and does not have a record for order=1*/
			AND Exists
			(
			SELECT * FROM Sysco_Deal_Sheet_Geographic_Adjustment AS ShowSecondDefaultAdj 
			INNER JOIN Sysco_Deal_Sheet_Geography ShowSecondDefault_Geography
			ON ShowSecondDefault_Geography.Sysco_Deal_Sheet_Geography_ID = ShowSecondDefaultAdj.Sysco_Deal_Sheet_Geography_ID
			AND ShowSecondDefault_Geography.Deleted = 0
			WHERE 	ShowSecondDefaultAdj.BSA_Foodservice_Items_Master_ID = '#ItemID#'
			AND	ShowSecondDefaultAdj.Adjustment_Amount <> 0
			AND	ShowSecondDefaultAdj.Adjustment_Amount IS NOT Null
			AND 	ShowSecondDefault_Geography.WH_Number = '#Distributor_Warehouse#'
			)
			AND NOT Exists
			(
			SELECT * FROM Sysco_Deal_Sheet_Geographic_Adjustment AS ShowSecondDefaultAdj 
			INNER JOIN Sysco_Deal_Sheet_Geography ShowSecondDefault_Geography
			ON ShowSecondDefault_Geography.Sysco_Deal_Sheet_Geography_ID = ShowSecondDefaultAdj.Sysco_Deal_Sheet_Geography_ID
			AND ShowSecondDefault_Geography.Deleted = 0
			WHERE 	ShowSecondDefaultAdj.BSA_Foodservice_Items_Master_ID = '#ItemID#'
			AND 	ShowSecondDefault_Geography.WH_Number <> '#Distributor_Warehouse#'
			AND 	ShowSecondDefault_Geography.Default_WH = 1
			AND 	ShowSecondDefault_Geography.WH_Order = 1
			)
			)
		
		
			OR 
			(
			(
			Sysco_Deal_Sheet_Geography.WH_Number <> '#Distributor_Warehouse#'
			AND Sysco_Deal_Sheet_Geography.Default_WH = 1
			AND Sysco_Deal_Sheet_Geography.WH_Order = 2
			)
			/* return only if this item does have a record for WH_Number = '#Distributor_Warehouse#' 
			and does have a not null record for order=1
			and does have any record for order=2*/
			AND Exists
			(
			SELECT * FROM Sysco_Deal_Sheet_Geographic_Adjustment AS ShowSecondDefaultAdj 
			INNER JOIN Sysco_Deal_Sheet_Geography ShowSecondDefault_Geography
			ON ShowSecondDefault_Geography.Sysco_Deal_Sheet_Geography_ID = ShowSecondDefaultAdj.Sysco_Deal_Sheet_Geography_ID
			AND ShowSecondDefault_Geography.Deleted = 0
			WHERE 	ShowSecondDefaultAdj.BSA_Foodservice_Items_Master_ID = '#ItemID#'
			AND	ShowSecondDefaultAdj.Adjustment_Amount <> 0
			AND	ShowSecondDefaultAdj.Adjustment_Amount IS NOT Null
			AND 	ShowSecondDefault_Geography.WH_Number = '#Distributor_Warehouse#'
			)
			AND Exists
			(
			SELECT * FROM Sysco_Deal_Sheet_Geographic_Adjustment AS ShowSecondDefaultAdj 
			INNER JOIN Sysco_Deal_Sheet_Geography ShowSecondDefault_Geography
			ON ShowSecondDefault_Geography.Sysco_Deal_Sheet_Geography_ID = ShowSecondDefaultAdj.Sysco_Deal_Sheet_Geography_ID
			AND ShowSecondDefault_Geography.Deleted = 0
			WHERE 	ShowSecondDefaultAdj.BSA_Foodservice_Items_Master_ID = '#ItemID#'
			AND	ShowSecondDefaultAdj.Adjustment_Amount IS NOT Null
			AND	ShowSecondDefaultAdj.Adjustment_Amount <> 0
			AND 	ShowSecondDefault_Geography.WH_Number <> '#Distributor_Warehouse#'
			AND 	ShowSecondDefault_Geography.Default_WH = 1
			AND 	ShowSecondDefault_Geography.WH_Order = 1
			)
			AND NOT Exists
			(
			SELECT * FROM Sysco_Deal_Sheet_Geographic_Adjustment AS ShowSecondDefaultAdj 
			INNER JOIN Sysco_Deal_Sheet_Geography ShowSecondDefault_Geography
			ON ShowSecondDefault_Geography.Sysco_Deal_Sheet_Geography_ID = ShowSecondDefaultAdj.Sysco_Deal_Sheet_Geography_ID
			AND ShowSecondDefault_Geography.Deleted = 0
			WHERE 	ShowSecondDefaultAdj.BSA_Foodservice_Items_Master_ID = '#ItemID#'
			AND 	ShowSecondDefault_Geography.WH_Number <> '#Distributor_Warehouse#'
			AND 	ShowSecondDefault_Geography.Default_WH = 1
			AND 	ShowSecondDefault_Geography.WH_Order = 2
			)
			)
		)

		</cfquery>
		
		
		
		<Cfset BSCC_Amount = getProducts.BSCC_Amount>
		<Cfset OC_Amount = getProducts.OC_Amount>
		
		<Cfset Fixed_Case = getProducts.Fixed_Case>
		<Cfset Invoice_Amount = getProducts.Invoice_Amount>
		<cfset Volume = getProducts.Volume_CS>
		<cfset SUPC = getProducts.SUPC>
		<cfset Item = getProducts.Item>
		<cfset Pack_Size = getProducts.Pack_Size>
		<cfset Item_Desc = getProducts.Item_Desc>
		
		<Cfloop query="GetWarehouseAllowances">
	
		 <cfset "BSCC_CS_#i#" = BSCC_Amount>
		 <cfset "ABC_CS_#i#" = OC_Amount>
		 <cfset "FixedPrice_#i#" = Fixed_Case>
		 <cfset "CC_CS_#i#" = "0.00">
			 	
		<input type="hidden" name="Original_Fixed_#i#" value="#Fixed_Case#">
		<input type="hidden" name="Original_Rebate_#i#" value="0">
		<input type="hidden" name="Product_ID_#i#" value="#ItemID#">
		<input type="hidden" name="Distributor_ID_#i#" value="#DistributorID#">
		<input type="hidden" name="WH_Number_#i#" value="#GetWarehouseAllowances.WH_Number#">
		 
		 <Cfif len(trim(Invoice_Amount)) IS 0>
		 	<cfset InvoiceAmount = 0>		
		<cfelse>
			<cfset InvoiceAmount = Invoice_Amount >
		 </CFIF>
		
			<cfset "Total2_CS_#i#"   =  InvoiceAmount - evaluate("FixedPrice_#i#")  + .001>

		
			<Cfif len(trim(GetWarehouseAllowances.Adjustment_Amount)) IS 0 OR NOT isNumeric(GetWarehouseAllowances.Adjustment_Amount)>
				<cfset AdjustmentAmount = 0>
			<CFELSE>
				<cfset AdjustmentAmount = GetWarehouseAllowances.Adjustment_Amount>
			</CFIF>
			
		<Cfset Adjustment_Cases = AdjustmentAmount*getProducts.Net_Weight>
		 <!---   <Cfif len(trim(Adjustment_Cases)) GT 0>
			  	<cfset "Total2_CS_#i#"   =  evaluate("Total2_CS_#i#") + Adjustment_Cases>
		   </CFIF> --->
		   
		   <cfset "Total_CS_#i#"    =  evaluate("Total2_CS_#i#") - evaluate("ABC_CS_#i#")>
		   <cfset "Supplier_CS_#i#" =  evaluate("Total_CS_#i#") - evaluate("BSCC_CS_#i#")>
		   <cfset "CC_CS_#i#" = evaluate("FixedPrice_#i#") + Adjustment_Cases>
		   
		   <cfif blnSubmit IS 1>
		   <Cfif i LTE NumberofRecords>
		   	<cfset "Total_CS_#i#" = evaluate("form.Total_CS_#i#")>
			<cfset "Supplier_CS_#i#" = evaluate("form.Supplier_CS_#i#")>
			<cfset "ABC_CS_#i#" = evaluate("form.ABC_CS_#i#")>
			<cfset "CC_CS_#i#" = evaluate("form.CC_CS_#i#")>
			<cfset "Total2_CS_#i#" = evaluate("form.Total2_CS_#i#")>
			<cfset "BSCC_CS_#i#" = evaluate("form.BSCC_CS_#i#")>
			</cfif>
		   </cfif>
			
			<cfif blnSubmit IS 0 AND UseDBValues IS 1>
		  <!---Set the values to the database values--->
		  
		   <cfquery name="ValuesForThisProduct" dbtype="query">
			SELECT * FROM SavedValues
			WHERE Distributor_ID = '#DistributorID#'
			AND Product_ID = '#ProductID#'
			AND Original_Fixed = #FixedPrice#
			AND WH_Number LIKE '%#GetWarehouseAllowances.WH_Number#%' 
			</cfquery>
			
			<Cfif ValuesForThisProduct.Recordcount GT 0>
			
			<!--- <cfdump var="#ValuesForThisProduct#"> --->
			<cfset "Supplier_CS_#i#" = ValuesForThisProduct.Supplier_CS>
		   	 <cfset "BSCC_CS_#i#" = ValuesForThisProduct.BSCC_CS>
			 <cfset "ABC_CS_#i#" = ValuesForThisProduct.ABC_CS>
			 <cfset "FixedPrice_#i#" = ValuesForThisProduct.Original_Fixed>
			 <cfset "CC_CS_#i#" = ValuesForThisProduct.CC_CS>
			  <cfset "Total_CS_#i#"    = evaluate("Total2_CS_#i#") - evaluate("ABC_CS_#i#")>
			<input type="hidden" name="RecordID_#i#" value="#ValuesForThisProduct.Sysco_DS_Program_ID#">
		  	</CFIF>
		  </cfif>
		
			 
			 <tr> 
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF">&nbsp;</TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"><cfif Volume NEQ "">
#trim(numberformat(Volume,"___,___,___,___,___,___.__"))#&nbsp; 
</cfif>&nbsp;  </TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center">#SUPC#&nbsp;</TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center">#Item#&nbsp; </td>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center">#Pack_Size#&nbsp;</TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center">#trim(GetWarehouseAllowances.WH_Desc)#&nbsp; </TD>
            <TD STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center">#Item_Desc#&nbsp; </td>

			
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"><CF_formatnumber
	number = "#evaluate("CC_CS_#i#")#" 
	decimals = "2"
	showcurrency = 1
>&nbsp; <input type="hidden" name="CC_CS_#i#" value="#evaluate("CC_CS_#i#")#"></TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"> 
			  <cfset replacedProductID = Replace(BSA_Foodservice_Items_Master_ID, "-", "_", "all") />
              <cfif form.generatexlsreport EQ 0 and CanEditProgram>			
			  <input type="hidden" name="Line_Number_Info_#i#" value="#replacedProductID#" discountType="1">
              <input type="text" name="Supplier_CS_#i#" value="<CF_formatnumber
	number = "#evaluate("Supplier_CS_#i#")#" 
	decimals = "2"
	showcurrency = 0
>" STYLE="WIDTH:50px;"  ONKEYUP="clenseText(this,'0123456789.');" onChange="this.value = formatToDeciamalPlaces(this.value,2);" onBlur="addvalues2(#i#, 1);">
                <cfelse>
               <CF_formatnumber
	number = "#evaluate("Supplier_CS_#i#")#" 
	decimals = "2"
	showcurrency = 1
>  &nbsp; </cfif> </TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"> 
              <cfif form.generatexlsreport EQ 0 and CanEditProgram>
                <input type="text" name="BSCC_CS_#i#" value="<CF_formatnumber
	number = "#evaluate("BSCC_CS_#i#")#" 
	decimals = "2"
	showcurrency = 0
>" STYLE="WIDTH:50px;" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,2);" onBlur="addvalues(#i#, 1);">
                <cfelse>
				<CF_formatnumber
	number = "#evaluate("BSCC_CS_#i#")#" 
	decimals = "2"
	showcurrency = 1
></cfif> </TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"> 
              <cfif form.generatexlsreport EQ 0 and CanEditProgram>
                <input type="text" name="Total_CS_#i#" value="<CF_formatnumber
	number = "#evaluate("Total_CS_#i#")#" 
	decimals = "2"
	showcurrency = 0
>" STYLE="WIDTH:50px;" readonly>
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
>" STYLE="WIDTH:50px;" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,2);" onBlur="addtotals(#i#, 1);">
                <cfelse>
				<CF_formatnumber
	number = "#evaluate("ABC_CS_#i#")#" 
	decimals = "2"
	showcurrency = 1
>
            </cfif> </TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"> 
              <cfif form.generatexlsreport EQ 0 and CanEditProgram>
                <input type="text" name="Total2_CS_#i#" value=" <CF_formatnumber
	number = "#evaluate("Total2_CS_#i#")#" 
	decimals = "2"
	showcurrency = 0
>" STYLE="WIDTH:50px;" readonly >

                <cfelse>
               <CF_formatnumber
	number = "#evaluate("Total2_CS_#i#")#" 
	decimals = "2"
	showcurrency = 1
>
            </cfif> </TD>
			
			<!--- <Td>#i#</TD> --->
          </TR>
			<!------ Get the variable for tracking which line # corresponds to which product, this will be used in the javascript ----->			
			<cfparam name="FORMVARSFORJS.#FORMVARSFORJS_FIXEDSTART#_#replacedProductID#" 	default="">
			<cfset Current_LineNumbers = Evaluate("FORMVARSFORJS.#FORMVARSFORJS_FIXEDSTART#_#replacedProductID#") />
			<cfset "FORMVARSFORJS.#FORMVARSFORJS_FIXEDSTART#_#replacedProductID#" = ListAppend(Current_LineNumbers, i, ",") />
		
          <cfset i=i+1>
		
        </cfloop>
		</cfoutput>