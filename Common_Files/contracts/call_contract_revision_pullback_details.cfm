<!---
	Copyright (c)2009 Blacksmith Applications, Inc.       
	Filename:		AwayX/Common_Files/contracts/call_contract_revision_pullback_details.cfm
	Created:		8/19/2009
	Developer:		Milan Mushran
	Description:	        Updates the pullback details of a reviison
	Usage:			AwayX/Common_Files/contracts/contract_revision_pullback_details.cfm
	Tip:			This code below was casuing a issue with mass approve.
				Moved the CFThread call to a CFC as it was throwing an error "routines cannot be called twice in different template" 
--->
<cfscript>
Program_Manager = application.oController.getObject(path="mvc.Models.Program.ProgramManager");
Program_Manager.Call_Pullback_Details_For_CorpRevisions(CSLGetContractInfo.contract_main_id);
</cfscript>