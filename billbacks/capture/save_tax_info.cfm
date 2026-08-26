<!--- 41801: Billback_Sales_Tax/Anand/20-Mar-2014 --->
<CFPARAM NAME="AddTax" DEFAULT="0">
<CFPARAM name="Form.TaxCode_1" DEFAULT="">
<CFPARAM name="Form.TaxCode_2" DEFAULT="">
<CFPARAM name="Form.TaxCode_3" DEFAULT="">

	<cfif Form.TaxCode_1 EQ "">
		<cfset Form.TaxCode_1 = 0 />
	</cfif>	
	<cfif Form.TaxCode_2 EQ "">
		<cfset Form.TaxCode_2 = 0 />
	</cfif>	
	<cfif Form.TaxCode_3 EQ "">
		<cfset Form.TaxCode_3 = 0 />
	</cfif>	

<!--- If any of the 3 tax types have a valid tax amount. --->
<cfif Form.TaxCode_1 GT 0 OR Form.TaxCode_2 GT 0 OR Form.TaxCode_3 GT 0>

	<cfset useLakebaseForBBTaxInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_tax_info")>
	<cfif useLakebaseForBBTaxInfo>
		<cftry>
			<cfset BBTaxInfo = application.oLakebase.toQuery(
				application.oLakebase.selectRows("bb_tax_info", { "billback_id" = "eq.#Billback_ID#", "deleted" = "eq.false" })
			)>
			<cfcatch type="any">
				<cfset useLakebaseForBBTaxInfo = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForBBTaxInfo>
		<cfquery name="BBTaxInfo" datasource="#Application.Datasource#">
			SELECT * FROM BB_Tax_Info WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
		</cfquery>
	</cfif>

	<cfif (BBTaxInfo.RecordCount EQ 0)>
		<cfset useLakebaseForAddBillbacksalesTax = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_tax_info")>
		<cfif useLakebaseForAddBillbacksalesTax>
			<cftry>
				<!--- unlike SQL Server, the Lakebase dbo.bb_tax_info.deleted column has no DEFAULT,
				      so it must be set explicitly here to avoid leaving it NULL. --->
				<cfset application.oLakebase.insertRow("bb_tax_info", {
					"billback_id" = Billback_ID,
					"tax_code_1_id" = Form.TaxCode_1,
					"tax_allowance_code_1" = Form.TaxCode_1,
					"tax_code_1_domestic_amount" = Form.TaxAmount_1,
					"tax_code_1_foreign_amount" = Form.TaxAmount_1,
					"tax_code_2_id" = Form.TaxCode_2,
					"tax_allowance_code_2" = Form.TaxCode_2,
					"tax_code_2_domestic_amount" = Form.TaxAmount_2,
					"tax_code_2_foreign_amount" = Form.TaxAmount_2,
					"tax_code_3_id" = Form.TaxCode_3,
					"tax_allowance_code_3" = Form.TaxCode_3,
					"tax_code_3_domestic_amount" = Form.TaxAmount_3,
					"tax_code_3_foreign_amount" = Form.TaxAmount_3,
					"created_by" = request.AccessStructure.User_ID,
					"deleted" = false
				})>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForAddBillbacksalesTax = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForAddBillbacksalesTax>
			<cfquery name="AddBillbacksalesTax" datasource="#Application.Datasource#">
				INSERT INTO BB_Tax_Info(
				Billback_ID,
				Tax_Code_1_ID,
				Tax_Allowance_Code_1,
				Tax_Code_1_Domestic_Amount,
				Tax_Code_1_Foreign_Amount,
				<!---Tax_Code_1_Domestic_Taxable_Amount,
				Tax_Code_1_Foreign_Taxable_Amount,--->
				Tax_Code_2_ID,
				Tax_Allowance_Code_2,
				Tax_Code_2_Domestic_Amount,
				Tax_Code_2_Foreign_Amount,
				<!---Tax_Code_2_Domestic_Taxable_Amount,
				Tax_Code_2_Foreign_Taxable_Amount,--->
				Tax_Code_3_ID,
				Tax_Allowance_Code_3,
				Tax_Code_3_Domestic_Amount,
				Tax_Code_3_Foreign_Amount,
				<!---Tax_Code_3_Domestic_Taxable_Amount,
				Tax_Code_3_Foreign_Taxable_Amount,--->
				Created_By)

				VALUES(
				'#Billback_ID#',
				'#Form.TaxCode_1#',
				'#Form.TaxCode_1#',
				#Form.TaxAmount_1#,
				#Form.TaxAmount_1#,
				<!---#Form.TaxableAmount_1#,
				#Form.TaxableAmount_1#,--->
				'#Form.TaxCode_2#',
				'#Form.TaxCode_2#',
				#Form.TaxAmount_2#,
				#Form.TaxAmount_2#,
				<!---#Form.TaxableAmount_2#,
				#Form.TaxableAmount_2#,--->
				'#Form.TaxCode_3#',
				'#Form.TaxCode_3#',
				#Form.TaxAmount_3#,
				#Form.TaxAmount_3#,
				<!---#Form.TaxableAmount_3#,
				#Form.TaxableAmount_3#,--->
				'#request.AccessStructure.User_ID#')
			</cfquery>
		</cfif>
	<cfelse>
		<cfset useLakebaseForUpdateBillbacksalesTax = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_tax_info")>
		<cfif useLakebaseForUpdateBillbacksalesTax>
			<cftry>
				<cfset application.oLakebase.updateRows("bb_tax_info",
					{ "billback_id" = "eq.#Billback_ID#" },
					{
						"tax_code_1_id" = Form.TaxCode_1,
						"tax_allowance_code_1" = Form.TaxCode_1,
						"tax_code_1_domestic_amount" = Form.TaxAmount_1,
						"tax_code_1_foreign_amount" = Form.TaxAmount_1,
						"tax_code_2_id" = Form.TaxCode_2,
						"tax_allowance_code_2" = Form.TaxCode_2,
						"tax_code_2_domestic_amount" = Form.TaxAmount_2,
						"tax_code_2_foreign_amount" = Form.TaxAmount_2,
						"tax_code_3_id" = Form.TaxCode_3,
						"tax_allowance_code_3" = Form.TaxCode_3,
						"tax_code_3_domestic_amount" = Form.TaxAmount_3,
						"tax_code_3_foreign_amount" = Form.TaxAmount_3,
						"last_updated_by" = request.AccessStructure.User_ID,
						"last_updated_on" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss")
					}
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForUpdateBillbacksalesTax = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUpdateBillbacksalesTax>
			<cfquery name="AddBillbacksalesTax" datasource="#Application.Datasource#">
				UPDATE BB_Tax_Info
				SET Tax_Code_1_ID 						= #Form.TaxCode_1#,
					Tax_Allowance_Code_1 				= '#Form.TaxCode_1#',
					Tax_Code_1_Domestic_Amount 			= #Form.TaxAmount_1#,
					Tax_Code_1_Foreign_Amount 			= #Form.TaxAmount_1#,
					<!---Tax_Code_1_Domestic_Taxable_Amount 	= #Form.TaxableAmount_1#,
					Tax_Code_1_Foreign_Taxable_Amount 	= #Form.TaxableAmount_1#,--->
					Tax_Code_2_ID 						= #Form.TaxCode_2#,
					Tax_Allowance_Code_2 				= '#Form.TaxCode_2#',
					Tax_Code_2_Domestic_Amount 			= #Form.TaxAmount_2#,
					Tax_Code_2_Foreign_Amount 			= #Form.TaxAmount_2#,
					<!---Tax_Code_2_Domestic_Taxable_Amount 	= #Form.TaxableAmount_2#,
					Tax_Code_2_Foreign_Taxable_Amount 	= #Form.TaxableAmount_2#,--->
					Tax_Code_3_ID 						= #Form.TaxCode_3#,
					Tax_Allowance_Code_3 				= '#Form.TaxCode_3#',
					Tax_Code_3_Domestic_Amount 			= #Form.TaxAmount_3#,
					Tax_Code_3_Foreign_Amount 			= #Form.TaxAmount_3#,
					<!---Tax_Code_3_Domestic_Taxable_Amount 	= #Form.TaxableAmount_3#,
					Tax_Code_3_Foreign_Taxable_Amount 	= #Form.TaxableAmount_3#,--->
					Last_Updated_By = '#request.AccessStructure.User_ID#',
					Last_Updated_On = GetDate()
				WHERE
					Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
		</cfif>
	</cfif>	<!--- <cfif (BBTaxInfo.RecordCount EQ 0)> --->

		<cfquery name="updatepaymentnotes" datasource="#application.datasource#" >
		UPDATE Billback
		SET TotalTaxAmount = #FORM.TotalTaxAmount#
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
</cfif>

<cfif AddTax eq 1>
	<cflocation url="/billbacks/approval/BB_Sales_Tax.cfm?BBID=#Billback_ID#&AddTax=1">
</cfif>