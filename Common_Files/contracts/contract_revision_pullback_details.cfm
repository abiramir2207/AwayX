<!---
	Copyright (c)2009 Blacksmith Applications, Inc.       
	Filename:		AwayX/Common_Files/contracts/contract_revision_pullback_details.cfm
	Created:		8/19/2009
	Developer:		kvangapalli
	Description:		calls another file which updates the pullback details of a revision
	Usage:			AwayX/Common_Files/contracts/contract_layered_Approve_Action.cfm
	Tip:			This code below was casuing a issue with mass approve via email.
				Moved the CFThread call to this file as it was throwing an error "routines cannot be called twice in a template" 
	Modified		Milan Mushran
	Modified Date		1/7/2011
	Issue			"routines cannot be called twice from different templates" error was still happening.
--->
<cfinclude template ="call_contract_revision_pullback_details.cfm">
