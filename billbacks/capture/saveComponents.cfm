<!---
	Name: saveComponents.cfm        
	Copyright (c) 2006 Blacksmith Applications, Inc.       
	Description:
		This template contains all logic for saving Billback components. 
--->	
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body>
	<cfset Supplied_Wddx_Packet_To_File_Map_ID = url.Supplied_Wddx_Packet_To_File_Map_ID>
	<cfset PacketCommand = "read">
	<cfinclude template="/includes/wddxpacketapi.cfm">
	<CFSET Billback = Packet.Contents>
	<cfset billbackID = url.billbackID >
	<cfset programID = url.ProgramID >

	<cfset billbackProgramManager = CreateObject("component", "components.billback.Programs.BillbackProgramsManager").init() />
	<cfset billbackProgramManager.setBillbackProgramID(programID) >
	<cfset billbackProgramManager.setBillbackID(billbackID) >
	<cfset billbackProgramRebateComps = billbackProgramManager.getBillbackProgramRebateComps() />
	<!---update the packet--->
	<cfloop index="x" from="1" to="#Billback.Programs.Count#" step="1">
		<CFSET Program = evaluate("Billback.Programs.Program_#x#")>
		<cfif Program.PROGRAM_ID eq programID>
			<!--- this is the rebate program we should update--->
			<cfif isdefined("Program.Rebate")>
				<cfloop index="idx" from="1" to="#Program.Rebate.Count#" step="1">
					<cfset currentCmpName = replace(evaluate("Program.Rebate.Component_#idx#.PROGRAM_REBATES_COMPONENT_NAME"),".","","ALL") >
					<cfset "Program.Rebate.Component_#idx#.Checked" = evaluate("url." & "Component_" & idx & "_" & replace(replace(currentCmpName," ","_","ALL"),"-","_","ALL"))>
				</cfloop>
			</cfif>
			<cfbreak>
		</cfif>
	</cfloop>
	
	<cfset PacketCommand = "write">
	<cfset Supplied_PacketContents = Billback>
	<cfinclude template="/includes/wddxpacketapi.cfm">
	<!--- update database
		  save component is intermediate stage, changes can be made at any time, therefore deleted = 1
		  once saved, new records with deleted = 0 will be inserted
		  Modified: 4/26/2006 CPM - Save is no longer an intermediate stage.
	--->
	<cfset idx = 0>
	<cfif billbackProgramManager.hasSavedSelectedComponent() >
		<cfloop query="billbackProgramRebateComps">
			<cfset idx = idx + 1 >
			<cfset useLakebaseForupdateRebateCmps = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program_rebate_component")>
<cfif useLakebaseForupdateRebateCmps>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_program_rebate_component",
			{
				"billback_id" = "eq.#billbackID#",
				"billback_program_id" = "eq.#programID#",
				"program_rebates_component_name" = "eq.#Program_Rebates_Component_Name#"
			},
			{
				"checked" = "#evaluate("url." & "Component_" & idx & "_" & replace(replace(replace(Program_Rebates_Component_Name," ","_","ALL"),"-","_","ALL"),".","","ALL"))#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateRebateCmps = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateRebateCmps>
<CFQUERY NAME="updateRebateCmps" DATASOURCE="#Application.Datasource#">
				update Billback_Program_rebate_Component
				set Checked = '#evaluate("url." & "Component_" & idx & "_" & replace(replace(replace(Program_Rebates_Component_Name," ","_","ALL"),"-","_","ALL"),".","","ALL"))#'
				where Billback_ID = '#billbackID#'
				and Billback_Program_ID = #programID#
				and Program_Rebates_Component_Name = '#Program_Rebates_Component_Name#'
				<!--- Dev Note: CPM 9710 Removed this item to allow editing of components after product save.	
				and deleted = 1
			--->
			</CFQUERY>
</cfif>
		</cfloop>
	<cfelse>
		<cfloop query="billbackProgramRebateComps">
			<cfset idx = idx + 1 >
			<CFQUERY NAME="insertRebateCmps" DATASOURCE="#Application.Datasource#">
				insert into Billback_Program_rebate_Component
				(	Billback_ID,Billback_Program_ID,Program_Rebates_Component_Name,
					Program_Rebates_Component_Name_ID,Checked,Deleted	) 
				select 	distinct '#billbackID#' as billbackID, #programID# as programID, 
						<!---Dev Note CPM 9899: Change Program_Rebates_Component_ID to Program_Rebates_Component_Name_Id and 0 as deleted to 1 as deleted--->
						Program_Rebates_Component_Name.Program_Rebates_Component_Name,
						Program_Rebates_Component.Program_Rebates_Component_Name_Id,
						'#evaluate("url." & "Component_" & idx & "_" & replace(replace(replace(Program_Rebates_Component_Name," ","_","ALL"),"-","_","ALL"),".","","ALL"))#' as Checked,
						1 as Deleted
				FROM 	Program_Rebates_Component
				inner join Program_Rebates_Component_Name
						on Program_Rebates_Component.Program_Rebates_Component_Name_ID = Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
						and Program_Rebates_Component_Name.Program_Rebates_Component_Name = '#Program_Rebates_Component_Name#'
				WHERE 	Program_Rebates_Component.Program_ID IN ( '#programID#')			
				AND		Program_Rebates_Component.Deleted = 0
			</CFQUERY>
		</cfloop>
	</cfif>
	<script>
		window.close();
	</script>
</body>
</html>
