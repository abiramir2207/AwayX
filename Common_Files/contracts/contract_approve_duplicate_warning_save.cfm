
<cfsavecontent variable="dupWarningMessage">
	<br><br>
	WARNING, The same program already exists.
	<CFIF IsDefined("URL.DupContractIDList")>
		<cfparam name="PageName" default="Duplicate Program">
		<cfset ProgramManager = CreateObject("component","components.programs.Program") />
		<cfset qProgramInfo = ProgramManager.getProgramInfo(ContractMainID) />
		<cfset ContractControlID = qProgramInfo.programtype_id >
		<cfset dupTemplateManager = CreateObject("component","components.programs.template.DuplicateTemplateManager").init(ContractControlID,'#trim(PageName)#') />
		<cfset getDefintion = dupTemplateManager.getDupProgramDefinition()>
		<CFSET DuplicateProgramIDList = DupContractIDList>
		<STYLE>
		TABLE.underline TD 
		{
			border-bottom:solid #C0C0C0 1px; 
		}
		</STYLE>
		<CFQUERY NAME="GetContractDetails" DATASOURCE="#Application.Datasource#">
			SELECT * FROM Contract_Main WHERE Contract_main_ID IN (#DuplicateProgramIDList#)
		</CFQUERY>
		<CFOUTPUT>
		<BR><BR>
		<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" STYLE="Border: 2px Solid Navy;" CLASS="underline">
			<TR BGCOLOR="FFE083">
				<TD><B>CONTRACT NUMBER</B></TD>
				<TD><B>CONTRACT TITLE</B></TD>
			</TR>
			<CFLOOP QUERY="GetContractDetails">
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
				<TD ALIGN="Center"><B>#contract_number#</B></TD>
				<TD>#contract_title#</TD>
			</TR>
			</CFLOOP>			
		</TABLE>
		
		 <BR><BR>
		Duplicate Reason: 
		<CFSET CommaCount = 0>
		<CFLOOP QUERY="getDefintion">
			<CFIF Item NEQ 1 AND IsChecked EQ 1>
				<CFSET CommaCount = CommaCount + 1>
				<CFIF CommaCount NEQ 1>,</CFIF>Matching <CFOUTPUT>#Item_Name#</CFOUTPUT>
			</CFIF>
		</CFLOOP> 
		
		<BR><BR>
		</CFOUTPUT>
	<CFELSE>
	<br>The program that matches your program is <cfoutput>[#form.check_contract_number#]: #form.check_contract_title#</cfoutput>
	<br>
	</CFIF>
	Would you like to email the owner of existing program to make modification?
</cfsavecontent>
