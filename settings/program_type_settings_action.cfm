
<cfparam name="FORM.Active" 					default="1">
<!--- basics --->
<cfparam name="FORM.Max_Duration" 				default="0">
<cfparam name="FORM.Min_Duration" 				default="0">
<cfparam name="FORM.Max_Global_Volume_Size_CS" 	default="0">
<cfparam name="FORM.Max_Global_Volume_Size_LBS" default="0">
<cfparam name="FORM.Max_Global_Volume_Size_GAL" default="0">
<cfparam name="FORM.Max_Global_Volume_Size_LTR" default="0">
<cfparam name="FORM.Min_Global_Volume_Size_CS" 	default="0">
<cfparam name="FORM.Min_Global_Volume_Size_LBS" default="0">
<cfparam name="FORM.Min_Global_Volume_Size_GAL" default="0">
<cfparam name="FORM.Min_Global_Volume_Size_LTR" default="0">
<cfparam name="FORM.Max_Global_Volume" 			default="0">
<cfparam name="FORM.Min_Global_Volume" 			default="0">
<cfparam name="FORM.Allow_Retro_Create" 		default="0">
<cfparam name="FORM.Adv_Spend" 					default="0">
<cfparam name="FORM.Growth_Inclusion" 			default="0">
<cfparam name="FORM.Auto_Renew_Option" 			default="0">
<cfparam name="FORM.Auto_Renew_Lead_Time"		default="0">
<cfparam name="FORM.Rates_By_Category" 			default="0">
<cfparam name="FORM.Rates_By_UPC" 				default="1">
<cfparam name="FORM.Controllable_Volume" 		default="0">
<cfparam name="FORM.Global_GL_Assign" 			default="0">
<cfparam name="FORM.Volume_By_UPC" 				default="0">
<cfparam name="FORM.Specify_Distributors" 		default="0">
<cfparam name="FORM.Specify_Operators" 			default="0">
<cfparam name="FORM.Specify_Brokers" 			default="0">
<cfparam name="FORM.Specify_Products" 			default="0">
<cfparam name="FORM.Program_Description"		default="">
<cfparam name="FORM.Program_Editable"			default="1">
<cfparam name="FORM.Include_Trade"				default="0">
<!--- <cfparam name="FORM.Volume_Resolution"			default="1"> --->

<CFIF FORM.Active EQ 1>
	<CFSET FORM.Program_Editable = 0>
</CFIF>

<CFIF FORM.Current_Active_State EQ 1 AND FORM.Active EQ 0 AND FORM.hiBit NEQ 3>
	<cfset useLakebaseForsaveActiveState = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForsaveActiveState>
	<cftry>
		<cfset application.oLakebase.updateRows("program_control_panel_options",
			{
				"programcontrol_panel_options_id" = "eq.#FORM.ProgramControl_Panel_Options_ID#"
			},
			{
				"active" = "0",
				"program_editable" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForsaveActiveState = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsaveActiveState>
<CFQUERY NAME="saveActiveState" datasource="#application.datasource#">
		UPDATE Program_Control_Panel_Options
		SET Active = 0, Program_Editable = 0
		WHERE ProgramControl_Panel_Options_ID = '#FORM.ProgramControl_Panel_Options_ID#'
	</CFQUERY>
</cfif>

	<cfoutput>
		<script>
			window.location.href = "program_type_settings.cfm?PageTitle=programs: programs";
		</script>
	</cfoutput>	
	<cfabort>	
	
</CFIF>


<!--- Claim/Performance requirements --->
<cfparam name="FORM.chkClaimPerfReq_1" default="0">
<cfparam name="FORM.reqClaimPerfReq_1" default="0">
<cfparam name="FORM.chkClaimPerfReq_2" default="0">
<cfparam name="FORM.reqClaimPerfReq_2" default="0">
<cfparam name="FORM.chkClaimPerfReq_3" default="0">
<cfparam name="FORM.reqClaimPerfReq_3" default="0">
<cfparam name="FORM.chkClaimPerfReq_4" default="0">
<cfparam name="FORM.reqClaimPerfReq_4" default="0">
<cfparam name="FORM.chkClaimPerfReq_5" default="0">
<cfparam name="FORM.reqClaimPerfReq_5" default="0">
<cfparam name="FORM.chkClaimPerfReq_6" default="0">
<cfparam name="FORM.reqClaimPerfReq_6" default="0">
<cfparam name="FORM.chkClaimPerfReq_7" default="0">
<cfparam name="FORM.reqClaimPerfReq_7" default="0">
<cfparam name="FORM.chkClaimPerfReq_8" default="0">
<cfparam name="FORM.reqClaimPerfReq_8" default="0">
<cfparam name="FORM.chkClaimPerfReq_9" default="0">
<cfparam name="FORM.reqClaimPerfReq_9" default="0">

<!--- Exclusion Options --->
<cfparam name="FORM.chkProgAdj_1" default="0">
<cfparam name="FORM.reqProgAdj_1" default="0">
<cfparam name="FORM.chkProgAdj_2" default="0">
<cfparam name="FORM.reqProgAdj_2" default="0">
<cfparam name="FORM.chkProgAdj_3" default="0">
<cfparam name="FORM.reqProgAdj_3" default="0">
<cfparam name="FORM.chkProgAdj_4" default="0">
<cfparam name="FORM.reqProgAdj_4" default="0">
<cfparam name="FORM.chkProgAdj_5" default="0">
<cfparam name="FORM.reqProgAdj_5" default="0">

<!--- Discount Types --->
<cfparam name = "FORM.Rebate_Basic" 		Default="0">
<cfparam name = "FORM.Rebate_Step_Wise" 	Default="0">
<cfparam name = "FORM.Rebate_Retro" 		Default="0">
<cfparam name = "FORM.Fixed_Price" 			Default="0">
<cfparam name = "FORM.Lump_Sum_Open" 		Default="0">
<cfparam name = "FORM.Lump_Sum_Timed" 		Default="0">
<cfparam name = "FORM.Lump_Sum_Growth" 		Default="0">
<cfparam name = "FORM.Delivered_Price" 		Default="0">
<cfparam name = "FORM.FOB_Price" 			Default="0">
<cfparam name = "FORM.Del_And_FOB_Price" 	Default="0">

<cfparam name = "FORM.Discount_Fixed_Prices"	Default="0">
<cfparam name = "FORM.Discount_Rebates"		 	Default="0">
<cfparam name = "FORM.Discount_Lump_Sums"	 	Default="0">
<cfparam name = "FORM.Discount_Growth"		 	Default="0">
<cfparam name = "FORM.Discount_Formula_Pricing"	Default="0">



<!--- Payment Cycle --->
<cfparam name = "FORM.PayCycleOption_1"			Default="0">
<cfparam name = "FORM.PayCycleOption_2" 		Default="0">
<cfparam name = "FORM.PayCycleOption_3"			Default="0">
<cfparam name = "FORM.PayCycleOption_4"			Default="0">
<cfparam name = "FORM.PayCycleOption_5"			Default="0">
<cfparam name = "FORM.PayCycleOption_6" 		Default="0">
<cfparam name = "FORM.PayCycleOption_7" 		Default="0">
<cfparam name = "FORM.PayCycleDefaultOption" 	Default="1">

<!--- Rate Types --->
<cfparam name = "FORM.RateTypeOption_1"			Default="0">
<cfparam name = "FORM.RateTypeOption_2" 		Default="0">
<cfparam name = "FORM.RateTypeOption_3"			Default="0">
<cfparam name = "FORM.RateTypeOption_4"			Default="0">
<cfparam name = "FORM.RateTypeOption_5"			Default="0">
<cfparam name = "FORM.RateTypeOption_6" 		Default="0">
<cfparam name = "FORM.RateTypeOption_7" 		Default="0">
<cfparam name = "FORM.RateTypeOption_8" 		Default="0">
<cfparam name = "FORM.RateTypeDefault" 			Default="1">

<!--- Communication --->
<cfparam name = "FORM.CommRecip_1"				Default="0">
<cfparam name = "FORM.CommRecip_2"	 			Default="0">
<cfparam name = "FORM.CommRecip_3"				Default="0">
<cfparam name = "FORM.CommRecip_4"				Default="0">
<cfparam name = "FORM.CommRecipDefault"			Default="1">

<CFSET FORM.CommRecip_1 = 0>
<CFSET FORM.CommRecip_2 = 0>
<CFSET FORM.CommRecip_3 = 0>
<CFSET FORM.CommRecip_4 = 0>

<!--- Claim Mechanics --->
<cfparam name = "FORM.ClaimMechOption_1" default="0">
<cfparam name = "FORM.ClaimMechOption_2" default="0">
<cfparam name = "FORM.ClaimMechOption_3" default="0">
<cfparam name = "FORM.ClaimMechOption_4" default="0">
<cfparam name = "FORM.ClaimMechDefaultOption" default="1">

<cfparam name="FORM.Max_Global_Volume_Size" default="0">
<cfparam name="FORM.Min_Global_Volume_Size" default="0">
<cfparam name="FORM.Max_Global_Volume_UOM" default="0">
<cfparam name="FORM.Min_Global_Volume_UOM" default="0">

<CFIF FORM.hiBit NEQ 3>
	<CFIF FORM.ProgramControl_panel_Options_ID EQ 0>
		<CFSET FORM.hiBit = 1>
	<CFELSE>
		<CFSET FORM.hiBit = 2>
	</CFIF>
</CFIF>


<cfswitch expression="#FORM.hiBit#">
<cfcase value="1">
	<cfquery name="saveSettings" datasource="#application.datasource#">
		INSERT INTO Program_Control_Panel_Options
			(
			Company_Main_ID,
			Generic_Type,
			Created_Type,
			Max_Duration,
			Min_Duration,
			Max_Global_Volume,
			Min_Global_Volume,
			Max_Global_Volume_Size_CS,
			Max_Global_Volume_Size_LBS,
			Max_Global_Volume_Size_GAL,
			Max_Global_Volume_Size_LTR,
			Min_Global_Volume_Size_CS,
			Min_Global_Volume_Size_LBS,
			Min_Global_Volume_Size_GAL,
			Min_Global_Volume_Size_LTR,
			Allow_Retro_Create,
			Adv_Spend,
			Growth_Inclusion,
			Auto_Renew_Option,
			Auto_Renew_Lead_Time,
			Rates_By_Category,
			Rates_By_UPC,
			Controllable_Volume,
			Global_GL_Assign,
			Volume_By_UPC,
			Specify_Distributors,
			Specify_Operators,
			Specify_Brokers,
			Specify_Products,
			Program_Description,
			Max_Duration_Length,
			Min_Duration_Length,
			Allow_Retro_Create_Max,
			Adv_Spend_Amt,
			Invoice_Billback,
			IB_Required,
			Claim_Period,
			CP_Required,
			Item_Number,
			IN_Required,
			Total_Dollar_Pound,
			TDP_Required,
			Menu_Listing,
			ML_Required,
			Branded_Point_Of_Sale,
			BPOS_Required,
			Mandated_Specification,
			MS_Required,
			Optional_Specification,
			OS_Required,
			Feature_Sheet,
			FS_Required,
			Rebate_Basic,
			Rebate_Step_Wise,
			Rebate_Retro,
			Fixed_Price,
			Lump_Sum_Open,
			Lump_Sum_Timed,
			Lump_Sum_Growth,
			Delivered_Price,
			FOB_Price,
			Del_And_FOB_Price,
			PayCycleOption_1,
			PayCycleOption_2,
			PayCycleOption_3,
			PayCycleOption_4,
			PayCycleOption_5,
			PayCycleOption_6,
			PayCycleOption_7,
			PayCycleDefaultOption,
			RateTypeOption_1,
			RateTypeOption_2,
			RateTypeOption_3,
			RateTypeOption_4,
			RateTypeOption_5,
			RateTypeOption_6,
			RateTypeOption_7,
			RateTypeOption_8,
			RateTypeDefault,
			CommRecip_1,
			CommRecip_2,
			CommRecip_3,
			CommRecip_4,
			CommRecipDefault,
			ClaimMechOption_1,
			ClaimMechOption_2,
			ClaimMechOption_3,
			ClaimMechOption_4,
			ClaimMechDefaultOption,
			Discount_Fixed_Prices,
			Discount_Rebates,
			Discount_Lump_Sums,
			Discount_Growth,
			Discount_Formula_Pricing,
			Active,
			Program_Editable,
			Include_Trade
			)
		VALUES
			(
			'#request.AccessStructure.Company_Main_ID#',
			'#FORM.selGeneric#',
			'#FORM.sel#',
			'#FORM.Max_Duration#',
			'#FORM.Min_Duration#',
			'#FORM.Max_Global_Volume#',
			'#FORM.Min_Global_Volume#',
			'#FORM.Max_Global_Volume_Size_CS#',
			'#FORM.Max_Global_Volume_Size_LBS#',
			'#FORM.Max_Global_Volume_Size_GAL#',
			'#FORM.Max_Global_Volume_Size_LTR#',
			'#FORM.Min_Global_Volume_Size_CS#',
			'#FORM.Min_Global_Volume_Size_LBS#',
			'#FORM.Min_Global_Volume_Size_GAL#',
			'#FORM.Min_Global_Volume_Size_LTR#',
			'#FORM.Allow_Retro_Create#',
			'#FORM.Adv_Spend#',
			'#FORM.Growth_Inclusion#',
			'#FORM.Auto_Renew_Option#',
			'#FORM.Auto_Renew_Lead_Time#',
			'#FORM.Rates_By_Category#',
			<CFIF FORM.Rates_By_Category EQ 1>0<CFELSE>1</CFIF>,
			'#FORM.Controllable_Volume#',
			'#FORM.Global_GL_Assign#',
			'#FORM.Volume_By_UPC#',
			'#FORM.Specify_Distributors#',
			'#FORM.Specify_Operators#',
			'#FORM.Specify_Brokers#',
			'#FORM.Specify_Products#',
			'#FORM.Program_Description#',
			'#FORM.Max_Duration_Length#',
			'#FORM.Min_Duration_Length#',
			'#FORM.Allow_Retro_Create_Max#',
			'#FORM.Adv_Spend_Amt#',
			'#FORM.chkClaimPerfReq_1#',
			'#FORM.reqClaimPerfReq_1#',
			'#FORM.chkClaimPerfReq_2#',
			'#FORM.reqClaimPerfReq_2#',
			'#FORM.chkClaimPerfReq_3#',
			'#FORM.reqClaimPerfReq_3#',
			'#FORM.chkClaimPerfReq_4#',
			'#FORM.reqClaimPerfReq_4#',
			'#FORM.chkClaimPerfReq_5#',
			'#FORM.reqClaimPerfReq_5#',
			'#FORM.chkClaimPerfReq_6#',
			'#FORM.reqClaimPerfReq_6#',
			'#FORM.chkClaimPerfReq_7#',
			'#FORM.reqClaimPerfReq_7#',
			'#FORM.chkClaimPerfReq_8#',
			'#FORM.reqClaimPerfReq_8#',
			'#FORM.chkClaimPerfReq_9#',
			'#FORM.reqClaimPerfReq_9#',
			'#FORM.Rebate_Basic#',
			'#FORM.Rebate_Step_Wise#',
			'#FORM.Rebate_Retro#',
			'#FORM.Fixed_Price#',
			'#FORM.Lump_Sum_Open#',
			'#FORM.Lump_Sum_Timed#',
			'#FORM.Lump_Sum_Growth#',
			'#FORM.Delivered_Price#',
			'#FORM.FOB_Price#',
			'#FORM.Del_And_FOB_Price#',
			'#FORM.PayCycleOption_1#',
			'#FORM.PayCycleOption_2#',
			'#FORM.PayCycleOption_3#',
			'#FORM.PayCycleOption_4#',
			'#FORM.PayCycleOption_5#',
			'#FORM.PayCycleOption_6#',
			'#FORM.PayCycleOption_7#',
			'#FORM.PayCycleDefaultOption#',
			'#FORM.RateTypeOption_1#',
			'#FORM.RateTypeOption_2#',
			'#FORM.RateTypeOption_3#',
			'#FORM.RateTypeOption_4#',
			'#FORM.RateTypeOption_5#',
			'#FORM.RateTypeOption_6#',
			'#FORM.RateTypeOption_7#',
			'#FORM.RateTypeOption_8#',
			'#FORM.RateTypeDefault#',
			'#FORM.CommRecip_1#',
			'#FORM.CommRecip_2#',
			'#FORM.CommRecip_3#',
			'#FORM.CommRecip_4#',
			'#FORM.CommRecipDefault#',
			'#FORM.ClaimMechOption_1#',
			'#FORM.ClaimMechOption_2#',
			'#FORM.ClaimMechOption_3#',
			'#FORM.ClaimMechOption_4#',
			'#FORM.ClaimMechDefaultOption#',
			'#FORM.Discount_Fixed_Prices#',
			'#FORM.Discount_Rebates#',
			'#FORM.Discount_Lump_Sums#',
			'#FORM.Discount_Growth#',
			'#FORM.Discount_Formula_Pricing#',
			'#FORM.Active#',
			'#FORM.Program_Editable#',
			'#Form.Include_Trade#'
			)
	</cfquery>
	
</cfcase>
<cfcase value="2">

	<cfquery name="updSettings" datasource="#application.datasource#">
		UPDATE Program_Control_Panel_Options
		Set Company_Main_ID				=	'#request.AccessStructure.Company_Main_ID#',
			Generic_Type				=	'#FORM.selGeneric#',
			Created_Type				=	'#FORM.sel#',
			Max_Duration 				= 	'#FORM.Max_Duration#',
			Min_Duration 				= 	'#FORM.Min_Duration#',
			Max_Global_Volume		 	=   '#FORM.Max_Global_Volume#',
			Max_Global_Volume_Size_CS 	=   '#FORM.Max_Global_Volume_Size_CS#',
			Max_Global_Volume_Size_LBS 	=   '#FORM.Max_Global_Volume_Size_LBS#',
			Max_Global_Volume_Size_GAL 	=   '#FORM.Max_Global_Volume_Size_GAL#',
			Max_Global_Volume_Size_LTR 	=   '#FORM.Max_Global_Volume_Size_LTR#',
			Min_Global_Volume		 	=   '#FORM.Min_Global_Volume#',
			Min_Global_Volume_Size_CS 	=   '#FORM.Min_Global_Volume_Size_CS#',
			Min_Global_Volume_Size_LBS 	=   '#FORM.Min_Global_Volume_Size_LBS#',
			Min_Global_Volume_Size_GAL 	=   '#FORM.Min_Global_Volume_Size_GAL#',
			Min_Global_Volume_Size_LTR 	=   '#FORM.Min_Global_Volume_Size_LTR#',
			Allow_Retro_Create 			= 	'#FORM.Allow_Retro_Create#',
			Adv_Spend 					= 	'#FORM.Adv_Spend#',
			Growth_Inclusion 			= 	'#FORM.Growth_Inclusion#',
			Auto_Renew_Option 			= 	'#FORM.Auto_Renew_Option#',
			Auto_Renew_Lead_Time		=	'#FORM.Auto_Renew_Lead_Time#',
			Rates_By_Category 			= 	'#FORM.Rates_By_Category#',
			Rates_By_UPC 				= 	<CFIF FORM.Rates_By_Category EQ 0>1<CFELSE>0</CFIF>,
			Controllable_Volume 		= 	'#FORM.Controllable_Volume#',
			Global_GL_Assign 			= 	'#FORM.Global_GL_Assign#',
			Volume_By_UPC 				= 	'#FORM.Volume_By_UPC#',
			Specify_Distributors 		= 	'#FORM.Specify_Distributors#',
			Specify_Operators 			= 	'#FORM.Specify_Operators#',
			Specify_Brokers 			= 	'#FORM.Specify_Brokers#',
			Specify_Products 			= 	'#FORM.Specify_Products#',
			Program_Description			=	'#FORM.Program_Description#',
			Max_Duration_Length 		= 	'#FORM.Max_Duration_Length#',
			Min_Duration_Length 		= 	'#FORM.Min_Duration_Length#',
			Allow_Retro_Create_Max 		= 	'#FORM.Allow_Retro_Create_Max#',
			Adv_Spend_Amt 				= 	'#FORM.Adv_Spend_Amt#',
			<!--- Volume_By_UPC_Min 			= 	'#Volume_By_UPC_Min#', --->
			<!--- --Global_GL_Assign_Choice 	= 	'#Global_GL_Assign_Choice#', --->
<!--- 			Max_Global_Volume_UOM		=	#Max_Global_Volume_UOM#,
			Min_Global_Volume_UOM		=	#Min_Global_Volume_UOM#, --->
			Invoice_Billback			=	'#FORM.chkClaimPerfReq_1#',
			IB_Required					=	'#FORM.reqClaimPerfReq_1#',
			Claim_Period				=	'#FORM.chkClaimPerfReq_2#',
			CP_Required					=	'#FORM.reqClaimPerfReq_2#',
			Item_Number					=	'#FORM.chkClaimPerfReq_3#',
			IN_Required					=	'#FORM.reqClaimPerfReq_3#',
			Total_Dollar_Pound			=	'#FORM.chkClaimPerfReq_4#',
			TDP_Required				=	'#FORM.reqClaimPerfReq_4#',
			Menu_Listing				=	'#FORM.chkClaimPerfReq_5#',
			ML_Required					=	'#FORM.reqClaimPerfReq_5#',
			Branded_Point_Of_Sale		=	'#FORM.chkClaimPerfReq_6#',
			BPOS_Required				=	'#FORM.reqClaimPerfReq_6#',
			Mandated_Specification		=	'#FORM.chkClaimPerfReq_7#',
			MS_Required					=	'#FORM.reqClaimPerfReq_7#',
			Optional_Specification		=	'#FORM.chkClaimPerfReq_8#',
			OS_Required					=	'#FORM.reqClaimPerfReq_8#',
			Feature_Sheet				=	'#FORM.chkClaimPerfReq_9#',
			FS_Required					=	'#FORM.reqClaimPerfReq_9#',
			Global_Prog_Adj				= 	'#FORM.chkProgAdj_1#',
			GPA_Required				= 	'#FORM.reqProgAdj_1#',
			adj_prod_prog				= 	'#FORM.chkProgAdj_2#',
			APP_Required				= 	'#FORM.reqProgAdj_2#',
			deduct_trade				= 	'#FORM.chkProgAdj_3#',
			DT_Required					= 	'#FORM.reqProgAdj_3#',
			pullback_trade				= 	'#FORM.chkProgAdj_4#', 
			PT_Required					=	'#FORM.reqProgAdj_4#',
			auto_deduct					= 	'#FORM.chkProgAdj_5#',
			AD_Required					=	'#FORM.reqProgAdj_5#',
			Rebate_Basic				=	'#FORM.Rebate_Basic#',
			Rebate_Step_Wise			=	'#FORM.Rebate_Step_Wise#',
			Rebate_Retro				=	'#FORM.Rebate_Retro#',
			Fixed_Price					=	'#FORM.Fixed_Price#',
			Lump_Sum_Open				=	'#FORM.Lump_Sum_Open#',
			Lump_Sum_Timed				=	'#FORM.Lump_Sum_Timed#',
			Lump_Sum_Growth				=	'#FORM.Lump_Sum_Growth#',
			Delivered_Price				=	'#FORM.Delivered_Price#',
			FOB_Price					=	'#FORM.FOB_Price#',
			Del_And_FOB_Price			=	'#FORM.Del_And_FOB_Price#',
			PayCycleOption_1			=	'#FORM.PayCycleOption_1#',
			PayCycleOption_2			=	'#FORM.PayCycleOption_2#',
			PayCycleOption_3			=	'#FORM.PayCycleOption_3#',
			PayCycleOption_4			=	'#FORM.PayCycleOption_4#',
			PayCycleOption_5			=	'#FORM.PayCycleOption_5#',
			PayCycleOption_6			=	'#FORM.PayCycleOption_6#',
			PayCycleOption_7			=	'#FORM.PayCycleOption_7#',			
			PayCycleDefaultOption		=	'#FORM.PayCycleDefaultOption#',
			RateTypeOption_1			=	'#FORM.RateTypeOption_1#',
			RateTypeOption_2			=	'#FORM.RateTypeOption_2#',
			RateTypeOption_3			=	'#FORM.RateTypeOption_3#',
			RateTypeOption_4			=	'#FORM.RateTypeOption_4#',
			RateTypeOption_5			=	'#FORM.RateTypeOption_5#',
			RateTypeOption_6			=	'#FORM.RateTypeOption_6#',
			RateTypeOption_7			=	'#FORM.RateTypeOption_7#',			
			RateTypeOption_8			=	'#FORM.RateTypeOption_8#',			
			RateTypeDefault				=	'#FORM.RateTypeDefault#',
			CommRecip_1					=	'#FORM.CommRecip_1#',
			CommRecip_2					=	'#FORM.CommRecip_2#',
			CommRecip_3					=	'#FORM.CommRecip_3#',
			CommRecip_4					=	'#FORM.CommRecip_4#',
			CommRecipDefault			=	'#FORM.CommRecipDefault#',
			ClaimMechOption_1			=	'#FORM.ClaimMechOption_1#',
			ClaimMechOption_2			=	'#FORM.ClaimMechOption_2#',
			ClaimMechOption_3			=	'#FORM.ClaimMechOption_3#',
			ClaimMechOption_4			=	'#FORM.ClaimMechOption_4#',
			ClaimMechDefaultOption		=	'#FORM.ClaimMechDefaultOption#',
			Discount_Fixed_Prices		=	'#FORM.Discount_Fixed_Prices#',
			Discount_Rebates			=	'#FORM.Discount_Rebates#',
			Discount_Lump_Sums			=	'#FORM.Discount_Lump_Sums#',
			Discount_Growth				=	'#FORM.Discount_Growth#',
			Discount_Formula_Pricing	=	'#FORM.Discount_Formula_Pricing#',
			Active						=	'#FORM.Active#',
			Program_Editable			=	'#FORM.Program_Editable#',
			Include_Trade				=	'#FORM.Include_Trade#'

			WHERE ProgramControl_Panel_Options_ID = '#FORM.ProgramControl_Panel_Options_ID#'
	</cfquery>
</cfcase>
<cfcase value="3">
	<cfset useLakebaseFordelSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseFordelSettings>
	<cftry>
		<cfset application.oLakebase.updateRows("program_control_panel_options",
			{
				"programcontrol_panel_options_id" = "eq.#FORM.ProgramControl_Panel_Options_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordelSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordelSettings>
<cfquery name="delSettings" datasource="#application.datasource#">
		UPDATE Program_Control_Panel_Options
		Set deleted = 1
		WHERE ProgramControl_Panel_Options_ID = '#FORM.ProgramControl_Panel_Options_ID#'
	</cfquery>
</cfif>
</cfcase>
</cfswitch>

<cfoutput>
	<script>
		window.location.href = "program_type_settings.cfm?PageTitle=programs: programs";
	</script>
</cfoutput>
	