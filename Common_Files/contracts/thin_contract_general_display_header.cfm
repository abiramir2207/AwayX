<!------ thin_contract_general_display_header.cfm ----->

<cfparam name="URL.CID" 	default="">
<cf_cryp type="de" string ="#URL.CID#" key="#request.key#">
<CFSET CSL_Contract_Main_ID = cryp.value>


<cfparam name="Sent_To_External_Client" 	default="0">
<cfparam name="GROUP_PROCESSED" 			default="0">
<cfparam name="summaryView" 				default="1">

<CFQUERY NAME="CSLGetContractInfo" datasource="#application.datasource#">
	SELECT 	PCPO.Created_Type,
        ( SELECT Count( 1 )
            FROM CONTRACT_PRODUCTS p
                 INNER JOIN PRINT_PROGRAM_CUSTOM_OPTIONS ppco ON ppco.Contract_Main_Id = p.Contract_Main_Id
                                                                 AND p.Contract_Products_Id = ppco.Contract_Products_Id
                                                                 AND ppco.Deleted = 0
           WHERE p.Contract_Main_Id = cm.Contract_Main_Id
		   		<!---  Tim Ford - 10/23/2013 Label 39712 - Update Program Summary: Commented out Is_Group = 0 --->
                --AND p.Is_Group = 0
                 AND p.Deleted = 0 ) AS custom_print,
			PCPO.BidRequestStatusOn,
			PCPO.BidRequestStatusChangePgmStatus,
			PCPO.Generic_Type,
			PCPO.revision_not_allowed,
			PCPO.copy_not_allowed,
			PCPO.pullbacks_on,
			PCPO.generic_type,
			PCPO.Release_Settlement,
			PCPO.Market_Price,
			CM.*,
			CMAD.*,
			TF.Description AS Template_Filter_Description
	FROM 	Contract_Main CM
	LEFT JOIN Contract_Main_Aux_Data CMAD
	ON		CMAD.Contract_Main_ID = CM.Contract_Main_ID
	INNER JOIN	Program_Control_Panel_Options PCPO
	ON 		CM.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID
	LEFT JOIN Template_Filters TF ON
		TF.Template_Filters_Id = CM.Template_Filters_Id
	WHERE 	CM.Contract_Main_ID = '#CSL_Contract_Main_ID#'
</CFQUERY>

<cfset ThisProgramTypeID = CSLGetContractInfo.ProgramType_ID />
<cfquery name="GetSettings" datasource="#application.datasource#">
	SELECT *
	FROM
		Program_Control_Panel_Options
	WHERE
		ProgramControl_Panel_Options_ID = '#trim(ThisProgramTypeID)#'
</cfquery>

<cfset businessSegmentsOn = 0 />

<!---create and instance of the BusinessSegmentManager--->
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfif businessSegManager.isEnabled()>
	<cfset businessSegmentsOn = 1 />
	<cfset busSegIdForProgram = businessSegManager.getSegmentIdByProgram(CSLGetContractInfo.Contract_Main_ID) />
	<cfset qGetThisBusSegment = businessSegManager.get(busSegIdForProgram) />
</cfif>

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset getprogramstatus = CreateObject("component", "components.programs.Program")>

<cfinclude template="display_view_program_header.cfm" />