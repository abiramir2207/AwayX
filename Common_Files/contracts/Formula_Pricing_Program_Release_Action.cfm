<CF_cryp type="de" key="#request.key#" string="#FORM.Program_ID#">

<CFQUERY NAME="updateStatus" datasource="#application.datasource#">
	UPDATE Contract_Main
	SET On_Release_Contract_Status_Type_IDX = '#FORM.ON_RELEASE_CONTRACT_STATUS_TYPE_IDX#'
	WHERE Contract_Main_ID = '#cryp.value#'
</CFQUERY>

<CFLOCATION URL="Formula_Pricing_Index.cfm?CID=#FORM.Program_ID#">