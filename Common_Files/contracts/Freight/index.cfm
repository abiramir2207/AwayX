<!---- set defaults ----->

<CFPARAM NAME="url.mode" 		DEFAULT="edit">
<CFPARAM NAME="form.mode" 		DEFAULT="#url.mode#">
<CFPARAM NAME="url.command" 	DEFAULT="#form.mode#">
<CFPARAM NAME="form.command" 	DEFAULT="#url.command#">
<CFPARAM NAME="URL.cid" 	DEFAULT="">
<CFPARAM NAME="form.cid" 	DEFAULT="#url.cid#">

<!---- encrypt program id ----->
<CF_CRYP type="de" string="#form.cid#" key="#request.key#">
<CFIF len(form.cid) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "freightPage"> 
<CFSET FORM.Contract_Main_ID = cryp.value>

<CFSET PAGE_TITLE="Program Freight Information">

<!---- components ----->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<cfset objProgram = CreateObject("component", "components.programs.Program") />
<cfset objProgramFreight = CreateObject("component", "components.freight.ProgramFreight").init() />
<cfset objFreightBracketSetting = CreateObject("component","components.freight.FreightBracketSetting") />
<cfset objFreightBracketSetting.getFreightSettings()  />

<cfif NOT isDefined("Get_Profile_Settings")>
	<cfinclude template="/get_access_profile.cfm" />
</cfif>

<cfif form.command eq "print">
	<cfset form.mode = "summary" />
</cfif>

<cfif ListFindNocase("edit,view,summary,excel", form.command) NEQ 0
		OR ListFindNocase("edit,view,summary,excel", form.mode) NEQ 0
			>
	<cfset qProgramInfo = objProgram.getProgramInfo(programId = FORM.Contract_Main_ID) />
	<cfset qProgramDistributorFreight = objProgramFreight.getProgramDistributorFreight(programID = FORM.Contract_Main_ID) />	

	<!---- check profile settings and set the mode/command appropriately ----->
	<cfif form.mode eq "edit" or form.command eq "edit">
		<cfif 	Get_Profile_Settings.Freight_View_Create neq 2
			OR 	qProgramInfo.Contract_Status_Type_IDX gte 3
			OR	qProgramInfo.Freight_Approved eq 1>
			<cfset form.mode =  "view" />
			<cfset form.command =  "view" />
		</cfif>
	</cfif>
	<cfif form.mode eq "view" or form.command eq "view"
		or form.mode eq "summary" or form.command eq "summary">
		<cfif Get_Profile_Settings.Freight_View_Create eq 0>
			<cfset form.mode =  "none" />
			<cfset form.command =  "none" />
		</cfif>
	</cfif>

</cfif>

<cfif form.command eq "excel">
		<cfheader name="Content-Disposition" value="attachment;filename=Program_Freight.xls">
	<cfcontent type="application/msexcel" />
	<cfinclude template="program_freight_excel.cfm" />
	<cfabort>
</cfif>

<CF_MessageWindow>
<HTML>
<HEAD>
	<TITLE><cfoutput>#PAGE_TITLE#</cfoutput></TITLE>
<cfif form.command neq "summary">
	<SCRIPT LANGUAGE="JavaScript" SRC="program_freight.js"></SCRIPT>
	<SCRIPT LANGUAGE="JavaScript" SRC="/script/javascript/string_functions.js"></SCRIPT>
	<SCRIPT LANGUAGE="JavaScript" SRC="/script/javascript/date_functions.js"></SCRIPT>
	
</cfif>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="program_freight.css">
</HEAD>
<BODY>
<cfif ListFindNocase("edit,view", form.command) NEQ 0>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif application.programlayout EQ 1>
<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px">
  	<CFINCLUDE TEMPLATE="/common_files/contracts/contract_status_legend.cfm"></div>
<cfelse>
	<CFINCLUDE TEMPLATE="/common_files/contracts/contract_status_legend.cfm">
</cfif>
<BLOCKQUOTE>
<cfif application.programlayout EQ 1>

<div id="Layer1" style="position:relative; height:430px; width:800px; z-index:1; left: 100px; top: 10px;">
</cfif>
<cfinclude template="/common_files/contracts/minimal_contract_info.cfm">
</cfif>
<cfoutput>
<FORM ACTION="index.cfm?CID=#FORM.CID#" METHOD="post" NAME="ProgramFreightForm" style="display:inline;">
</cfoutput>
	<cfswitch expression="#form.command#">
		<cfcase value="edit">
			<cfinclude template="program_freight_edit.cfm" />
		</cfcase>
		<cfcase value="view">
			<cfinclude template="program_freight_view.cfm" />
		</cfcase>
		<cfcase value="summary">
			<cfinclude template="program_freight_view.cfm" />
		</cfcase>
		<cfcase value="popup">
			<cfinclude template="program_freight_view.cfm" />
		</cfcase>
		<cfcase value="print">
			<cfsetting showdebugoutput="false">
			<cfinclude template="program_freight_view.cfm" />
			<cfinclude template="/Common_Files/Printer_Friendly_Script.cfm">
		</cfcase>
		<cfcase value="save">
			<cfinvoke
				component="components.freight.ProgramFreight"
				method="setProgramDistributorFreight">
			
					<cfinvokeargument name="formValues" value="#form.fieldnames#">
					<cfinvokeargument name="ProgramID" value="#FORM.Contract_Main_ID#">
					<cfinvokeargument name="Distributor_List" value="#FORM.Distributor_List#">
					<cfinvokeargument name="freightNotes" value="#FORM.Freight_Notes#">

			</cfinvoke>
				<cflocation url="index.cfm?CID=#form.cid#" />
		</cfcase>		
		<cfcase value="approve">
			<cfif Get_Profile_Settings.Approve_Freight_Programs eq 1>
				<cfset objProgramFreight.approveFreight(
							programID = FORM.Contract_Main_ID,
							userId = request.AccessStructure.User_ID) />
				<cflocation url="index.cfm?CID=#form.cid#" />
			<cfelse>
				<cfoutput>
					<div style="color:red; font-weight:bold;">
					<br><br>You do not have access to approve freight
					</div>
				</cfoutput>
			</cfif>
		</cfcase>
		<cfcase value="save-approve">
			<cfinvoke
				component="components.freight.ProgramFreight"
				method="setProgramDistributorFreight">
			
					<cfinvokeargument name="formValues" value="#form.fieldnames#">
					<cfinvokeargument name="ProgramID" value="#FORM.Contract_Main_ID#">
					<cfinvokeargument name="Distributor_List" value="#FORM.Distributor_List#">
					<cfinvokeargument name="freightNotes" value="#FORM.Freight_Notes#">

			</cfinvoke>
			<cfif Get_Profile_Settings.Approve_Freight_Programs eq 1>
				<cfset objProgramFreight.approveFreight(
							programID = FORM.Contract_Main_ID,
							userId = request.AccessStructure.User_ID) />
				<cflocation url="index.cfm?CID=#form.cid#" />
			<cfelse>
				<cfoutput>
					<div style="color:red; font-weight:bold;">
					<br><br>You do not have access to approve freight
					</div>
				</cfoutput>
			</cfif>
		</cfcase>
		<cfcase value="approve-reset">
			<cfset objProgramFreight.resetFreightApproval(
						programID = FORM.Contract_Main_ID,
						userId = request.AccessStructure.User_ID, 
						comments = 'Reset Approval') />
			<cflocation url="index.cfm?CID=#form.cid#" />
		</cfcase>
		<cfcase value="refresh-data">
			<cfset objProgramFreight.PopulateProgramDistributorFreight(
						programID = FORM.Contract_Main_ID,
						ReCalculateAll = 1) />
			<cflocation url="index.cfm?CID=#form.cid#" />
		</cfcase>
		<cfcase value="none">
			<cfoutput>
				<div style="color:red; font-weight:bold;">
				<br><br>You do not have access to this section.
				</div>
			</cfoutput>
		</cfcase>
		<cfdefaultcase>
			<cfoutput>
			<div style="color:red; font-weight:bold;">
			<br><br>Command "#form.command#" is under construction
			</div>
			</cfoutput>
		</cfdefaultcase>
	</cfswitch>
	
	<cfoutput>
	<input name="mode" type="hidden" value="" />
	<input name="command" type="hidden" value="#form.command#" />
	<input name="cid" type="hidden" value="#form.cid#" />
	</cfoutput>
</FORM>
<cfif ListFindNocase("edit,view", form.command) NEQ 0>
<cfif application.programlayout EQ 1></div></cfif>
</BLOCKQUOTE>
<cfif application.programlayout EQ 1></div></cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</cfif>
</BODY>
</HTML>
	