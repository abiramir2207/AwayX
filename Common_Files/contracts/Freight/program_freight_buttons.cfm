<!----
program_freight_buttons.cfm
------>
<!--- Dev Note: KAL; 11/10/2010; D25227: Freight Adjustment 
	If freight is adjusted, then user cannot approve freight without freight adjustment approval setting.
--->
<cfset variables.approveFreightAdjustmentFlag = 1 />
<cfif objProgramFreight.verifyFreightAdjustment(contract_main_ID)>
	<cfif NOT Get_Profile_Settings.Approve_Freight_Adjustment_Programs>
		<cfset variables.approveFreightAdjustmentFlag = 0 />		
	</cfif>
</cfif>

<cfif form.command eq "edit">

	<!------- SAVE --------->
	<CF_smallLink 
		title = "save" 
		url = "##"
		parameters = "onClick=""javascript: return submitForm('save');return false;"""
	>
	<!--- if freight is at item level hide these columns --->
	<cfif NOT objFreightBracketSetting.bFREIGHT_VERSION_ITEM >
		<!------- VIEW --------->
		<CF_smallLink 
			title = "view" 
			url = "##"
			parameters = "onClick=""javascript: return submitForm('view');return false;"""
		>
	</cfif>
	<cfif 	(qProgramInfo.contract_status_type_idx eq 1 OR qProgramInfo.contract_status_type_idx eq 2)
		and	qProgramInfo.Freight_Approved eq 0>
			
		<!------- refresh freight data --------->
		<CF_smallLink 
			title = "refresh freight data" 
			url = "##"
			parameters = "onClick=""javascript: return submitForm('refresh-data');return false;"""
		>
	
	</cfif>

</cfif>

<cfif ListFindNocase("edit,view", form.command) NEQ 0>
	
	<!------- PRINT --------->
	<CF_smallLink 
		title = "print" 
		url = "##"
		parameters = "onClick=""javascript: return submitForm('print');return false;"""
	>
	
	<!------- EXPORT TO EXCEL --------->
	<CF_smallLink 
		title = "export to excel" 
		url = "##"
		parameters = "onClick=""javascript: return submitForm('excel');return false;"""
	>

	<cfif 	(qProgramInfo.contract_status_type_idx eq 1 OR qProgramInfo.contract_status_type_idx eq 2)
		and	qProgramInfo.Freight_Approval_Required eq 1
		and	Get_Profile_Settings.Approve_Freight_Programs eq 1>
	
		<cfif qProgramInfo.contract_status_type_idx eq 2 AND qProgramInfo.Freight_Approved eq 0 AND variables.approveFreightAdjustmentFlag eq 1>
	
			<cfif form.command eq "edit">
		
				<!------- APPROVE --------->
				<CF_smallLink 
					title = "save and approve" 
					url = "##"
					parameters = "onClick=""javascript: return submitForm('save-approve');return false;"""
				>
			
			<cfelseif form.command eq "view">
		
				<!------- APPROVE --------->
				<cfif isDefined("zeroFreight") and zeroFreight eq 1>
					<CF_smallLink 
						title = "approve" 
						url = "##"
						parameters = "onClick=""javascript: if(window.confirm('There are some rows with zero freight.\nDo you want to continue?')){submitForm('approve');}return false;"""
					>
				<cfelse>
					<CF_smallLink 
						title = "approve" 
						url = "##"
						parameters = "onClick=""javascript: submitForm('approve');return false;"""
					>
				</cfif>
			
			</cfif>
		
		</cfif>
	
		<cfif qProgramInfo.Freight_Approved eq 1>
		
			<!------- RESET APPROVAL --------->
			<CF_smallLink 
				title = "reset" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('approve-reset');return false;"""
			>
		
		</cfif>
	
	</cfif>

</cfif>

<cfif ListFindNocase("print,popup", form.command) NEQ 0>
	<CF_smallLink 
		title = "close window" 
		url = "##"
		parameters = "onClick=""javascript: window.close();return false;"""
	>
</cfif>