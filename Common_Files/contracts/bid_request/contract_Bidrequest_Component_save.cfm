<!--- <cfdump var="#form#">
<cfabort>  --->



 <cf_cryp type="de" key="#request.key#" string="#FORM.Program_ID#">
 <cfset encryp_program_id = FORM.Program_ID>
 <cfparam name="form.deletedateexclusions" default="0">
 <cfparam name="form.EZTemplate" default="0">
 
 <cfset FORM.Program_ID = '#cryp.value#'>
<!--- lock checker --->
<cfif form.EZTemplate EQ 0>
<CFSET LockChecker_CID  = cryp.value>
<CFINCLUDE TEMPLATE="/common_files/contracts/LockChecker.cfm">
</cfif>
<!--- lock checker --->
<cfif form.deletedateexclusions EQ 1>
<CFQUERY NAME = "Date_exclusion_settings" datasource="#Application.Datasource#">
			SELECT   
			Date_Exclusions_ON
			FROM 
			 Contract_Main
			 INNER JOIN Program_Control_Panel_Options
			 ON
			 Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
			WHERE Contract_Main.Contract_Main_ID =  #Form.Contract_Main_ID#
</CFQUERY>
<cfif Date_exclusion_settings.Date_Exclusions_ON EQ 1>
			<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />	
			<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(Form.Contract_Main_ID,0)>
		<cfif form.deletedateexclusions EQ 1>
			<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
			<cfquery name="deletedateexclusions" datasource="#application.datasource#">
				update contract_main
				set deleted = 1
				where contract_main_id in (#valuelist(getDateExclusionprogramIDs.revision_program_id)#)
			</cfquery>
			<cfquery name="deletedateexclusions" datasource="#application.datasource#">
				update program_exclusions
				set deleted = 1
				where revision_program_id in (#valuelist(getDateExclusionprogramIDs.revision_program_id)#)
			</cfquery>
			</CFIF>
		</cfif>
</cfif>
</cfif>
<!--- Delete all the existing instances --->
<CFTRANSACTION ACTION="BEGIN">
<cfset useLakebaseFordeletecontractproducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseFordeletecontractproducts>
	<cftry>
		<cfset application.oLakebase.deleteRows("contract_products", {
			"contract_main_id" = "eq.#FORM.Program_ID#",
			"product_type_id" = "eq.10"
		})>
		<cfcatch type="any">
			<cfset useLakebaseFordeletecontractproducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeletecontractproducts>
<CFQUERY NAME="deletecontractproducts" datasource="#application.datasource#">
	DELETE FROM contract_products
	where contract_main_id = '#FORM.Program_ID#'
	and Product_Type_ID = 10
</CFQUERY>
</cfif>

<cfset useLakebaseFordeletebidrequestproductdata = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bid_request_product")>
<cfif useLakebaseFordeletebidrequestproductdata>
	<cftry>
		<cfset application.oLakebase.deleteRows("program_bid_request_product", {
			"program_id" = "eq.#FORM.Program_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseFordeletebidrequestproductdata = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeletebidrequestproductdata>
<CFQUERY NAME="deletebidrequestproductdata" datasource="#application.datasource#">
	DELETE FROM Program_Bid_Request_Product
	where Program_ID = '#FORM.Program_ID#'
</CFQUERY>
</cfif>

<cfset useLakebaseFordeletebidrequestcomponentdata = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bidrequest_component")>
<cfif useLakebaseFordeletebidrequestcomponentdata>
	<cftry>
		<cfset application.oLakebase.deleteRows("program_bidrequest_component", {
			"program_id" = "eq.#FORM.Program_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseFordeletebidrequestcomponentdata = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeletebidrequestcomponentdata>
<CFQUERY NAME="deletebidrequestcomponentdata" datasource="#application.datasource#">
	DELETE FROM Program_Bidrequest_Component
	where Program_ID = '#FORM.Program_ID#'
</CFQUERY>
</cfif>

<!--- End Delete all the existing instances --->
<CFSET insertproductids = "">
<cfif form.EZTemplate EQ 0>
<cfset qProgram = CreateObject("component", "components.programs.program").getProgramInfo(Form.Program_ID) />
<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
<cfset weeklyVolume = ProductGroupManager.getPerProductVolume(Form.Program_ID, qProgram) />
</cfif>
<cfloop from="1" to="#ListLen(form.BIDREQUESTCOMPONENTLIST)#" index="i">
	<cfset temp_comp_id = ListGetAt(form.BIDREQUESTCOMPONENTLIST,i)>
	<cfset bidrequest_comp_id = Left(temp_comp_id,(Find("_",temp_comp_id)-1))>
	<cfset bidrequest_comp_paid_to = Mid(temp_comp_id,(Find("_",temp_comp_id)+1),len(temp_comp_id))>
	<CFQUERY NAME="addNewBidrequestCategory" datasource="#application.datasource#">
	SET NOCOUNT ON
	INSERT INTO Program_Bidrequest_Component
	(Program_Bidrequest_Component_Name_ID, Program_Bidrequest_Component_Paid_To,Program_ID)
	VALUES
	('#bidrequest_comp_id#', '#bidrequest_comp_paid_to#', '#FORM.Program_ID#')
SELECT Program_Bidrequest_Component_ID = @@IDENTITY
SET NOCOUNT OFF
	</CFQUERY>
	
	<cfset Program_Bidrequest_Component_ID = addNewBidrequestCategory.Program_Bidrequest_Component_ID>
	
	<cfloop from="1" to="#ListLen(form.PRODUCT_LIST)#" index="j">
	<cfset product_id = ListGetAt(form.PRODUCT_LIST,j)>
	<cfset useLakebaseForgetcontractproducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForgetcontractproducts>
	<cftry>
		<cfset getcontractproducts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"contract_main_id" = "eq.#FORM.Program_ID#",
				"product_type_id" = "eq.10",
				"deleted" = "eq.0",
				"bsa_foodservice_items_master_id" = "eq.#product_id#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetcontractproducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetcontractproducts>
<CFQUERY NAME="getcontractproducts" datasource="#application.datasource#">
	SELECT * FROM
	Contract_Products
	where 
	Contract_Main_ID = '#FORM.Program_ID#'
	AND product_type_id = 10
	AND deleted = 0
	AND BSA_Foodservice_Items_Master_ID = '#product_id#'
	</CFQUERY>
</cfif>
	
	<cfif getcontractproducts.recordcount EQ 0>
	<cfparam name="form.Prod_Default_#replace(product_id, "-", "_", "ALL")#" default="0">
	<CFQUERY NAME="addBidrequestcontractproducts" datasource="#application.datasource#">
	SET NOCOUNT ON
	INSERT INTO Contract_Products
			(BSA_Foodservice_Items_Master_ID, Contract_Main_ID, Product_Type_ID <cfif form.EZTemplate EQ 1>,EZButton_On_Default</cfif>)
			VALUES
			('#product_id#', '#FORM.Program_ID#', 10<cfif form.EZTemplate EQ 1>,#evaluate("Prod_Default_#replace(product_id, "-", "_", "ALL")#")#</cfif>)
SELECT contract_products_ID = @@IDENTITY
SET NOCOUNT OFF
	</CFQUERY>
	<CFSET contract_product_id = addBidrequestcontractproducts.contract_products_ID>
	<CFELSE>
	<cfset contract_product_id = getcontractproducts.contract_products_ID>
	</cfif>
<cfparam name="Bidrequest_C#bidrequest_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_RATE" default="0">
	<CFQUERY NAME="InsertNewProduct" datasource="#application.datasource#">
			INSERT INTO Program_Bid_Request_Product
			(Program_ID, Contract_Products_ID, Price, UOM,Program_Bidrequest_Component_ID,Bid_Request_Spec_ID, Won)
			VALUES
			('#FORM.Program_ID#', '#contract_product_id#', <CFIF evaluate("Bidrequest_C#bidrequest_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_RATE") EQ "">'0'<CFELSE>'#evaluate("Bidrequest_C#bidrequest_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_RATE")#'</CFIF>, #evaluate("Bidrequest_C#bidrequest_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_UOM")#, #Program_bidrequest_Component_ID#,#evaluate("Bid_Request_Spec_ID_#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#")#, '#evaluate("Bid_Request_Status_ID_#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#")#')
	</CFQUERY>
	<!--- </cfif> --->
	</cfloop>
	
	
</cfloop>
	
<cfif form.EZTemplate EQ 0>
	<!---call SP to update program product volume --->
	<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_UPD" datasource="#application.datasource#">
		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#Form.Program_ID#" null="no">	   
	</cfstoredproc>
</cfif>

<cfset useLakebaseForgetProgramType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForgetProgramType>
	<cftry>
		<cfset getProgramType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#FORM.Program_ID#",
				"select" = "programtype_id"
			}), "programtype_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetProgramType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetProgramType>
<CFQUERY NAME="getProgramType" datasource="#application.datasource#">
	SELECT ProgramType_ID
	FROM Contract_Main 
	WHERE Contract_Main_ID = #FORM.Program_ID#
</CFQUERY>
</cfif>


<!------ Start Clause Code ----->
<cfif form.EZTemplate EQ 0>
<cfset discountTypeId = 10>
<cfset programId = FORM.Program_ID>
<cfset templateId = getProgramType.ProgramType_ID>
<cfset addClauseMode = FORM.Product_List NEQ "">
<cfinclude template="/Clause_Library/Clause_Discount_Type_Add_Remove.cfm">
<!------ End  Clause Code ----->

<CFSET redirector_Program_ID = getProgramType.ProgramType_ID>
<CFSET redirector_FromPage_ID = 10>
<cfinclude template="/Common_Files/contracts/internal_redirector_based_on_settings.cfm">

<CFLOCATION url="/Common_Files/contracts/redirect.cfm?destination=#redirector_NextLocation#&CID=#encryp_program_id#">		
<cfelse>
<script>window.close();</script>
</cfif>

<!--- <cfset locateBackTo = "/Common_Files/contracts/Contract_Discount_Rebates.cfm.cfm?CID=#encryp_program_id#" />

<cflocation URL="#locateBackTo#"> --->
	