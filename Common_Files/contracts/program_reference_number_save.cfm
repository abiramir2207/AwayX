<!-----
		Name: 			program_reference_number_save.cfm
               			Copyright (c) 2006 Blacksmith Applications, Inc.
		Created:
						03/21/2006
						Deepa Kunnath
		Last Modified:
						03/21/2006
						Deepa Kunnath
		Description:
                       	This page will save the program reference number into the database.
					   	Will be FORM posted from program_reference_number_edit_frame.cfm.

		Parameters:
                       Form.Program_ID - Program ID
					   Form.Contract_Reference_Number - New Program Reference Number
					   Form.CID - encrypted program ID
		Usage:
                       program_reference_number_edit_save.cfm
----->

<cfparam name="Form.Program_ID" 	default="">
<cfparam name="Form.CID" 	default="">
<cfparam name="Form.Contract_Reference_Number" 	default="">
<cfif IsNumeric(Form.Program_ID)>

	<cfset program = CreateObject("component", "components.programs.program") />
	<cfset program.saveContractReferenceNumber(programId = Form.Program_ID, sContractReferenceNumber = Form.Contract_Reference_Number) />

	<cfif Form.CID NEQ "" >
		<!------ Refresh the view program page to display the new program reference number ----->
		<script language="JavaScript">
			<!------ set editMode = 0 so that the view program page will be refreshed ----->
			<cfoutput>
				window.opener.location.href = "contract_edit_menu.cfm?CID=#Form.CID#&editMode=0";
			</cfoutput>
			window.close();
		</script>
	</cfif>

</cfif>