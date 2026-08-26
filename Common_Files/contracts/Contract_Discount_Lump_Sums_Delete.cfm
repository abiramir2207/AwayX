<cfset Encryp_Program_ID = FORM.Program_ID>
<cf_cryp type="de" key="#request.key#" string="#FORM.Program_ID#">
<cfset FORM.Program_ID = cryp.value>
<cfparam name="form.EZTemplate" default="0">

<!--- lock checker --->
<cfif form.EZTemplate EQ 0>
<CFSET LockChecker_CID  = FORM.Program_ID>
<CFINCLUDE TEMPLATE="LockChecker.cfm">
</cfif> 
<!--- lock checker --->
<cfif form.deletedateexclusions EQ 1>
<cfquery name="GetSettings" datasource="#application.datasource#">

	SELECT 	Program_Control_Panel_Options.Date_Exclusions_ON
	FROM 	Program_Control_Panel_Options
			INNER JOIN Contract_Main ON 
			Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
	WHERE 	Contract_Main_ID = #form.program_id#
	
</cfquery>

<cfif GetSettings.Date_Exclusions_ON EQ 1>
			<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />	
			<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(form.program_id,0)>
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
<CFTRANSACTION ACTION="BEGIN">

	<CFQUERY NAME="deleteProducts" datasource="#application.datasource#">
		UPDATE 	Contract_Products
		SET 	Deleted = 1
		WHERE 	Contract_Main_ID = #FORM.Program_ID#
		AND		Product_Type_ID = 3
		AND		Contract_Products_ID IN 
				(
					SELECT Contract_Products_ID 
					FROM Program_Lump_Sum_Product_Data
					WHERE Program_Lump_Sum_ID = '#FORM.Component_ID#'
				)
	</CFQUERY>
	
	<CFQUERY NAME="deletecomponent" datasource="#application.datasource#">
		UPDATE 	Program_Lump_Sums
		SET 	Deleted = 1
		WHERE 	Program_Lump_Sum_ID = '#FORM.Component_ID#'
	</CFQUERY>
	
	<CFQUERY NAME="deletecomponentproducts" datasource="#application.datasource#">
		UPDATE 	Program_Lump_Sum_Product_Data
		SET 	Deleted = 1
		WHERE 	Program_Lump_Sum_ID = '#FORM.Component_ID#'
	</CFQUERY>
	
	<!--- delete lump sum distributor --->
	<CFQUERY NAME="deletecomponentdistributors" datasource="#application.datasource#">
		UPDATE 	Program_Lump_Sum_Distributor
		SET 	Deleted = 1
		WHERE 	Program_Lump_Sum_ID = '#FORM.Component_ID#'
	</CFQUERY>
	
	<!---call SP to update program product volume --->
	<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_UPD" datasource="#application.datasource#">
				
		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#Form.Program_ID#" null="no">
				   
	</cfstoredproc>

	<!---call SP to update program contract quantity --->
	<cfstoredproc procedure="Update_Program_Volume" datasource="#application.datasource#">

		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#Form.Program_ID#" null="no">

	</cfstoredproc>

<cftransaction action="commit" />

</CFTRANSACTION>

<!------ Start Clause Code ----->
<cfset discountTypeId = 3>
<cfset programId = cryp.value>
<cfinclude template="/Clause_Library/Clause_Discount_Type_Add_Remove.cfm">
<!------ End  Clause Code ----->

<cfset locateBackTo = "Contract_Discount_Lump_Sums.cfm?CID=#Encryp_Program_ID#&EZTemplate=#form.EZTemplate#" />

<CFLOCATION URL="#locateBackTo#">