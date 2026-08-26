
<!---Update or insert database values?--->

<Cfdump var="#form#">


<cfset useLakebaseForUpdateAllToDeleted = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("sysco_deal_sheet_programs")>
<cfif useLakebaseForUpdateAllToDeleted>
	<cftry>
		<cfset application.oLakebase.updateRows("sysco_deal_sheet_programs",
			{
				"contract_main_id" = "eq.#form.Contract_Main_ID#"
			},
			{
				"deleted" = "1",
				"deleted_date" = "#now()#",
				"deleted_by" = "#request.AccessStructure.User_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateAllToDeleted = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateAllToDeleted>
<cfquery name="UpdateAllToDeleted" datasource="#application.datasource#">
UPDATE Sysco_Deal_Sheet_Programs
SET Deleted = 1,
Deleted_Date = getdate(),
Deleted_By = '#request.AccessStructure.User_ID#'
WHERE Contract_Main_ID = #form.Contract_Main_ID#
</cfquery>
</cfif>

<cfloop index = "I"
  from = "1"
  to = "#NumberofRecords#">


<Cfif form.UseDBValues IS 1 and isDefined("RecordID_#i#") >
	
	<Cfif trim(evaluate("RecordID_#i#")) IS NOT "">
	<!---Update db values--->
	<cfquery name="UpdateSavedValues" datasource="#application.datasource#">
	UPDATE Sysco_Deal_Sheet_Programs
	SET 
	Contract_Main_ID = #form.Contract_Main_ID#,
	Supplier_CS = #evaluate("Supplier_CS_#i#")#,
	BSCC_CS = #evaluate("BSCC_CS_#i#")#,
	Total_CS = #evaluate("Total_CS_#i#")#,
	ABC_CS = #evaluate("ABC_CS_#i#")#,
	CC_CS = #evaluate("CC_CS_#i#")#,
	Original_Fixed = #evaluate("Original_Fixed_#i#")#,
	Original_Rebate = #evaluate("Original_Rebate_#i#")#,
	Product_ID = '#evaluate("Product_ID_#i#")#',
	Distributor_ID = '#evaluate("Distributor_ID_#i#")#',
	WH_Number	= '#evaluate("WH_Number_#i#")#',
	Deleted = 0,
	Updated_Date = getdate(),
	Updated_By = '#request.AccessStructure.User_ID#'
	WHERE Sysco_DS_Program_ID = '#evaluate("RecordID_#i#")#'
	</cfquery>
	
	<cfelse>
		<cfquery name="InsertSavedValues" datasource="#application.datasource#"> 
		INSERT INTO Sysco_Deal_Sheet_Programs
		(
			Contract_Main_ID,
			Supplier_CS,
			BSCC_CS,
			Total_CS,
			ABC_CS,
			CC_CS,
			Original_Fixed,
			Original_Rebate,
			Product_ID,
			Distributor_ID,
			WH_Number,
			Created_By			
		)
		VALUES
		(
			#form.Contract_Main_ID#,
			#evaluate("Supplier_CS_#i#")#,
			#evaluate("BSCC_CS_#i#")#,
			#evaluate("Total_CS_#i#")#,
			#evaluate("ABC_CS_#i#")#,
			#evaluate("CC_CS_#i#")#,
			#evaluate("Original_Fixed_#i#")#,
			#evaluate("Original_Rebate_#i#")#,
			'#evaluate("Product_ID_#i#")#',
			'#evaluate("Distributor_ID_#i#")#',
			'#evaluate("WH_Number_#i#")#',
			'#request.AccessStructure.User_ID#'
		)
		</cfquery>
	
	</CFIF>
	
	<cfelse>
	<!---Insert db values--->
		<cfquery name="InsertSavedValues" datasource="#application.datasource#"> 
		INSERT INTO Sysco_Deal_Sheet_Programs
		(
			Contract_Main_ID,
			Supplier_CS,
			BSCC_CS,
			Total_CS,
			ABC_CS,
			CC_CS,
			Original_Fixed,
			Original_Rebate,
			Product_ID,
			Distributor_ID,
			WH_Number,
			Created_By			
		)
		VALUES
		(
			#form.Contract_Main_ID#,
			#evaluate("Supplier_CS_#i#")#,
			#evaluate("BSCC_CS_#i#")#,
			#evaluate("Total_CS_#i#")#,
			#evaluate("ABC_CS_#i#")#,
			#evaluate("CC_CS_#i#")#,
			#evaluate("Original_Fixed_#i#")#,
			#evaluate("Original_Rebate_#i#")#,
			'#evaluate("Product_ID_#i#")#',
			'#evaluate("Distributor_ID_#i#")#',
			'#evaluate("WH_Number_#i#")#',
			'#request.AccessStructure.User_ID#'
		)
		</cfquery>
	
	</CFIF>

</cfloop>

<CF_CRYP type="en" string="#form.Contract_Main_ID#" key="#request.key#">
<cfset CID = cryp.value>

 <cfoutput><cflocation url="sysco_report_form.cfm?CID=#CID#"></cfoutput> 