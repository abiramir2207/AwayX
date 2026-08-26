<CFIF NOT isdefined("URL.RD")>
	<CFQUERY NAME="SaveGeneralContractInfo" datasource="#application.datasource#">
		SET NOCOUNT ON
		INSERT INTO Contract_Main
		(
			Contract_Number,
			Contract_Reference_Number,
			Contract_Title,
			Broker_IDs,
			Contract_Start_Date,
			Contract_End_Date,
			Contract_Quantity,
			Contract_Quantity_UOM_IDX,
			Discount_Type_ID,
			Dist_Brand_Eligibility,
			Deleted,
			contract_status_type_IDX,
			fixed_rebate_amount,
			Author_ID,
			Owner_Company_ID
		)
		VALUES
		(
			'#FORM.Contract_Number#',
			'#FORM.Contract_Reference_Number#',
			'#FORM.Contract_Title#',
			'#FORM.brokers_ValueList#',
			'#FORM.start_date#',
			'#FORM.end_date#',
			'#FORM.Quantity#',
			'#FORM.Contract_Quantity_UOM_IDX#',
			<CFIF FORM.FRA_GNFP EQ 1>1<CFELSE>'#FORM.DEV_FOB#'</CFIF>,
			'#FORM.DIST_EL#',
			0,
			1,
			'#FORM.fixed_rebate_amount#',
			'#request.AccessStructure.User_ID#',
			'#request.AccessStructure.Company_Main_ID#'
		)
		SELECT Contract_Main_ID = @@IDENTITY
		SET NOCOUNT OFF
	</CFQUERY>
	
	
<!--- 	<CFLOOP INDEX="ITEM_UPC" LIST="#FORM.Products_ValueList#" DELIMITERS=",">
		<CFQUERY NAME="SaveProduct" datasource="#application.datasource#">
			INSERT INTO Contract_Products
			(Contract_Main_ID, Product_UPC, Discount_Value)
			VALUES
			('#SaveGeneralContractInfo.Contract_Main_ID#', '#Replace(ITEM_UPC, '_', '-', 'ALL')#', '#evaluate("Form.Discount_Value_#ITEM_UPC#")#')
		</CFQUERY>
	</CFLOOP> --->
	<CFLOCATION url="select_products.cfm?Contract_Main_ID=#SaveGeneralContractInfo.Contract_Main_ID#">
<CFELSE>
	<CFLOCATION url="Contract_Create_3_form.cfm?Contract_Main_ID=#FORM.Contract_Main_ID#">
</CFIF>

