<cf_cryp type="de" key="#request.key#" string="#FORM.Program_ID#">


<cfparam name="form.Claim_Mechanics" default="0">
<cfparam name="form.Component_Paid_To" default="0">
<cfparam name="form.deletedateexclusions" default="0">
<cfparam name="form.payment_locked" default="0">
<cfparam name="form.RedirectPath" default="">
<cfparam name="form.new_lump_sum_amount" default="">
<cfparam name="form.new_lump_sum_volume" default="">
<cfparam name="form.EZTemplate" default="0">
<cfparam name="form.GL_Account_ID" default="0">
<cfparam name="form.Split_For_Auto_Pay" default="0">
<cfparam name="form.Vendor_ID" default="0">
<cfparam name="form.amount_each_period" default="0">
<cfparam name="form.periodCount" default="0">
<!--- D37295 Kraft Equipment LS set up --->
<cfparam name="form.quantity" default="0">
<cfparam name="form.Vendor_Master_ID" default="0">
<cfparam name="form.bvendorOnlyProgram" default="0">

<!--- We Need a valid paid_to (default to distributor) --->
<cfif form.Component_Paid_To EQ 0>
	<cfset form.Component_Paid_To = 1 />
</CFif>


<cfquery name="GetSettings" datasource="#application.datasource#">
	SELECT Program_Control_Panel_Options.* 
	FROM Program_Control_Panel_Options
	INNER JOIN Contract_Main ON 
		Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
	WHERE Contract_Main_ID = '#cryp.value#'
</cfquery>

<!--- Dev Note: WR 78635 - If "vendor" is a payee on the template, the "paid to" should be distributor.  --->
<cfset objProgram = CreateObject("component", "components.programs.program") />
<cfset form.bvendorOnlyProgram = objProgram.IsVendorOnlyPayeeOnTemplate(GetSettings.ProgramControl_Panel_Options_ID)>

<cfif form.bvendorOnlyProgram eq 1>
	<cfset form.Component_Paid_To = 1 />
</CFif>

<!--- lock checker --->
<cfif form.EZTemplate EQ 0>
	<CFSET LockChecker_CID  = cryp.value>
	<CFINCLUDE TEMPLATE="LockChecker.cfm">
</cfif>
<cfif getsettings.EZButton_On EQ 1 and form.EZTemplate EQ 0>
	<cfset EzButton_Disable = 1>
<cfelse>
	<cfset EzButton_Disable = 0>
</cfif>
<cfif EzButton_Disable EQ 1>
	<cfset EZProgramManager = CreateObject("component", "components.programs.EZButton_programManager") />	
	<cfset GetEZButtonDefaultComp = EZProgramManager.getLumpsumEZComponents(getsettings.EZ_Contract_Id,FORM.Program_Lump_Sum_Name_ID)>
	<cfif GetEZButtonDefaultComp.recordcount GT 0>
		<cfset FORM.new_lump_sum_amount = GetEZButtonDefaultComp.Lump_Sum_Amount>
		<cfset FORM.new_lump_sum_volume = GetEZButtonDefaultComp.Lump_Sum_Volume>
		<cfset form.Claim_Mechanics = GetEZButtonDefaultComp.Claim_Mechanics>
	</cfif>
</cfif>

<!--- lock checker --->
<cfif form.deletedateexclusions EQ 1>
	<CFQUERY NAME = "Date_exclusion_settings" datasource="#Application.Datasource#">
		SELECT Date_Exclusions_ON
		FROM Contract_Main
		INNER JOIN Program_Control_Panel_Options ON
			Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
		WHERE Contract_Main.Contract_Main_ID = '#cryp.value#'
	</CFQUERY>
	<cfif Date_exclusion_settings.Date_Exclusions_ON EQ 1>
		<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />	
		<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(cryp.value,0)>
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
<cfset this.lumpSumCompId = "" />

<cfset useLakebaseForGetComponentInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sum_name")>
<cfif useLakebaseForGetComponentInfo>
	<cftry>
		<cfset GetComponentInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_lump_sum_name", {
				"program_lump_sum_name_id" = "eq.#FORM.Program_Lump_Sum_Name_ID#",
				"select" = "external_id"
			}), "external_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetComponentInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetComponentInfo>
<cfquery name="GetComponentInfo" datasource="#application.datasource#">
	SELECT External_ID
	FROM Program_Lump_Sum_Name
	WHERE Program_Lump_Sum_Name_ID = '#FORM.Program_Lump_Sum_Name_ID#'
</cfquery>
</cfif>

<cfset useLakebaseForGetVendorMasterId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vendor_master")>
<cfif useLakebaseForGetVendorMasterId>
	<cftry>
		<cfset GetVendorMasterId = application.oLakebase.toQuery(
			application.oLakebase.selectRows("vendor_master", { "vendor_id" = "eq.#form.Vendor_ID#", "deleted" = "eq.0", "select" = "vendor_master_id" }),
			"Vendor_Master_Id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetVendorMasterId = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetVendorMasterId>
	<cfquery name="GetVendorMasterId" datasource="#application.datasource#">
		SELECT Vendor_Master_Id
		FROM Vendor_Master
		WHERE Vendor_ID = '#form.Vendor_ID#' AND
			Deleted = 0
	</cfquery>
</cfif>
<cfif GetVendorMasterId.RecordCount>
	<cfset Vendor_GUID = GetVendorMasterId.Vendor_Master_Id />
<cfelse><!--- When payee is distributor we will not find entry in Vendor_Master, but GUID will be in FORM.vendor_Master_ID --->
	<cfset Vendor_GUID = FORM.Vendor_Master_Id />
</cfif>

<cfset Form.new_lump_sum_description = Replace(Form.new_lump_sum_description, """", " ", "all") />
<cfset Form.new_lump_sum_description = Replace(Form.new_lump_sum_description, "'", " ", "all") />
<CFIF FORM.UPDATE EQ 0>
	<CFQUERY NAME="addNewLumpSumCategory" datasource="#application.datasource#">
		SET NOCOUNT ON
		
		INSERT INTO Program_Lump_Sums
		(	Program_Lump_Sum_Name_ID,
			Lump_Sum_Description,
			Lump_Sum_Amount,
			Lump_Sum_Volume,
			Program_ID,
			Claim_Mechanics,
			Component_Paid_To,
			Current_Program_ID,
			GL_Account_ID,
			Component_External_ID,
			Vendor_Master_Id,
			Split_For_Auto_Pay,
			Amount_Each_Payment,
			Payment_Count,
			Quantity<!--- D37295 Kraft Equipment LS set up --->
		)
		VALUES
		(
			'#FORM.Program_Lump_Sum_Name_ID#',
			'#FORM.new_lump_sum_description#',
			'#FORM.new_lump_sum_amount#',
			'#Form.new_lump_sum_volume#',
			'#cryp.value#',
			'#form.Claim_Mechanics#',
			#form.Component_Paid_To#,
			'#cryp.value#',
			'#form.GL_Account_ID#',
			'#GetComponentInfo.External_ID#',
			<cfif len(Vendor_GUID) EQ 36>
				'#Vendor_GUID#',
			<cfelse>
				null,
			</cfif>
			'#form.Split_For_Auto_Pay#',
			'#form.amount_each_period#',
			'#form.periodCount#',
			'#form.quantity#'<!--- D37295 Kraft Equipment LS set up --->
		)
		
		SELECT Program_Lump_Sum_ID = @@IDENTITY
		SET NOCOUNT OFF
	</CFQUERY>
	<cfif GetSettings.Generic_Type EQ "LSAutoPay">
		<!--- update vendor selection --->
		
	</cfif>
	
	<cfset this.lumpSumCompId = addNewLumpSumCategory.Program_Lump_Sum_ID />
	
<CFELSE>
	<CFQUERY NAME="updateLumpSum" datasource="#application.datasource#">
		UPDATE 	Program_Lump_Sums
		SET
				<cfif FORM.Program_Lump_Sum_Name_ID neq 0 and FORM.Program_Lump_Sum_Name_ID neq "">Program_Lump_Sum_Name_ID =	'#FORM.Program_Lump_Sum_Name_ID#',</cfif>
				Lump_Sum_Description	=	'#FORM.new_lump_sum_description#',
				Lump_Sum_Amount			=	'#FORM.new_lump_sum_amount#',
				Lump_Sum_Volume			=	'#new_lump_sum_volume#',
				Claim_Mechanics			= 	'#FORM.Claim_Mechanics#',
				Component_Paid_To 		=    #form.Component_Paid_To#,
				GL_Account_ID			= 	'#form.GL_Account_ID#',
				Component_External_ID	= 	'#GetComponentInfo.External_ID#',
				Split_For_Auto_Pay		= 	'#form.Split_For_Auto_Pay#',
				<!--- guid = 36 --->
				Vendor_Master_Id		=	<cfif len(Vendor_GUID) EQ 36>'#Vendor_GUID#'<cfelse>null</cfif>,
				Amount_Each_Payment = '#form.amount_each_period#',
				Payment_Count = '#form.periodCount#',
				Quantity = '#form.quantity#'<!--- D37295 Kraft Equipment LS set up --->
		WHERE 	Program_Lump_Sum_ID 	= 	'#FORM.component_id#'
	</CFQUERY>
	
	<cfset this.lumpSumCompId = FORM.component_id />
	
</CFIF>

<!------ Start Clause Code ----->
<cfset discountTypeId = 3>
<cfset programId = cryp.value>
<cfinclude template="/Clause_Library/Clause_Discount_Type_Add_Remove.cfm">
<!------ End  Clause Code ----->

<!---get the Program_Lumps_Sum_Ext_Id from Program_Lump_Sums because this is the id we're going to store--->
<cfset useLakebaseForqGetLmpSmEctId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sums")>
<cfif useLakebaseForqGetLmpSmEctId>
	<cftry>
		<cfset qGetLmpSmEctId = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_lump_sums", {
				"deleted" = "eq.0",
				"program_lump_sum_id" = "eq.#this.lumpSumCompId#",
				"select" = "program_lumps_sum_ext_id"
			}), "program_lumps_sum_ext_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetLmpSmEctId = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetLmpSmEctId>
<cfquery name="qGetLmpSmEctId" datasource="#application.datasource#">
	SELECT 	Program_Lumps_Sum_Ext_Id
	FROM	Program_Lump_Sums
	WHERE	Deleted = 0
	AND		Program_Lump_Sum_ID = '#this.lumpSumCompId#'
</cfquery>
</cfif>
<!---se the lump sum ext id--->
<cfset this.lumpSumExtId = qGetLmpSmEctId.Program_Lumps_Sum_Ext_Id />

<!---set the comp id for revision--->
<cfset useLakebaseForqUpdateRevisionCompId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sums")>
<cfif useLakebaseForqUpdateRevisionCompId>
	<cftry>
		<cfset application.oLakebase.updateRows("program_lump_sums",
			{
				"program_lump_sum_id" = "eq.#this.lumpSumCompId#"
			},
			{
				"lump_revision_comp_id" = "#this.lumpSumExtId#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdateRevisionCompId = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdateRevisionCompId>
<CFQUERY NAME="qUpdateRevisionCompId" datasource="#application.datasource#">
	UPDATE 	Program_Lump_Sums
	SET		Lump_Revision_Comp_ID = #this.lumpSumExtId#
	WHERE 	Program_Lump_Sum_ID 	= '#this.lumpSumCompId#'
</CFQUERY>
</cfif>

<!------ update discount type payment cycle ----->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfif appSettings.getPaymentCycleAtDiscountType()>

	<cfparam name="FORM.PaymentCycle" 	default="0">
	<cfset paymentCycleManager = CreateObject("component", "components.programs.PaymentCycleManager").init() />
	<cfif form.payment_locked EQ 0>
		<cfset paymentCycleManager.savePaymentCycle(programId, 3, FORM.PaymentCycle, this.lumpSumExtId, form.payment_locked) />
	</cfif>
	
</cfif>

<cfif isDefined("form.FromPopup")>
	<cfif form.FromPopup EQ 1>
	<script>
	window.opener.location.reload();
	window.close();
	</script>
	<cfabort>
	</cfif>
</cfif>

<cfif form.RedirectPath EQ "">
	<cfset locateBackTo = "Contract_Discount_Lump_Sums.cfm?CID=#FORM.Program_ID#&EZTemplate=#form.EZtemplate#" />
<cfelse>
	<cfset locateBackTo = "Contract_Discount_Lump_Sums_Margin.cfm?CID=#FORM.Program_ID#&marginedit_saved=1" />
</cfif>

<cfif GetSettings.Discount_Lump_Sums_Item_Mandated IS NOT 1>
	<CFLOCATION URL="#locateBackTo#">
<cfelse>
	<CFIF FORM.UPDATE EQ 0>
		<cfset FORM.Program_Lump_Sum_ID = addNewLumpSumCategory.Program_Lump_Sum_ID>
		
	<cfelse>
		<cflocation URL="#locateBackTo#">
	</cfif>
</cfif>

