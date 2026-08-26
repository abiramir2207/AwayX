<!------ delete_program.cfm ----->
<cfoutput>

<cfinclude template="/includes/call_please_wait.cfm" />

<cfset referer = CGI.HTTP_REFERER />
<cfparam name="url.CID" 	default="">

<!------ check whether the referer is scorecard or program search ----->
<cfset refereredFile = ListLast(referer, "/") />
<cfset refereredFile = ListFirst(refereredFile, "?") />

<cfset programSearchFileList = "program_Search_Result.cfm,scorecard3.cfm" />

<cfset bErr = false>
<cfset showMsg = "">

<!------ <cfif ListFindNoCase(programSearchFileList, refereredFile, ",")> ----->
<cfif 1 EQ 1>

	<cfif Len(URL.CID) GT 0>
	
		<cf_cryp type="de" string ="#URL.CID#" key="#request.key#">
		
		<CFSET programId = cryp.value>

		<cfset program = CreateObject("component", "components.programs.program") />
		
		<!------ <cftransaction action="BEGIN">
		
			<cftry> ----->
		
				<cfset qProgram = program.getProgramInfo(programId) />
				<cfset programDesc = "[#qProgram.Contract_Number#] #qProgram.Contract_Title#" />
				
				<!------ lock the program ----->
				<cfset lockReturnValue = program.setLockStatus(programId, 1, request.AccessStructure.User_ID) />
				<cfif lockReturnValue EQ 1>
				
					<!------ delete program ----->
					<cfset deleteProgramId = programId>
					<cfsilent>
					<cfinclude template="/scorecard/delete_program_common.cfm">
					</cfsilent>
					
					<cfif deleteSuccess>
					
						<script language="JavaScript">
						
							reLoadSearchPage();
							
							function reLoadSearchPage()
							{
								var thisOpener = window.opener;
								if(thisOpener)
								{
									//thisOpener.getthisPage(thisOpener.document.MyForm);
									window.opener.parent.location.href='/manufacturers/home.cfm';
								}
							}
							
						</script>
						
						<cfset showMsg = "Program #programDesc# has been deleted successfully" />
					
					<cfelse>
					
						<cfset showMsg = "Program #programDesc# couldn't be deleted" />
						<cfset bErr = true>
					
					</cfif>
					
					<!------ unlock program ----->			
					<cfset program.setLockStatus(programId, 0)>
					
				<cfelseif lockReturnValue EQ 2>
				
					<cfset showMsg = "Program not found" />
					
				<cfelseif lockReturnValue EQ 3>
				
					<cfset showMsg = "This program #programDesc# is locked by someone else" />
				
				</cfif>
				
				<!------ <cftransaction action="COMMIT">
				
				<cfcatch>
				
					<cftransaction action="ROLLBACK">
					<cfrethrow>
				
				</cfcatch>
			
			</cftry>
		
		</cftransaction> ----->
		
	</cfif>
	
<cfelse>

	<cfset showMsg = "You are not authorized to view this page =#refereredFile#=" />
	<cfset bErr = true>

</cfif>

<cfif Len(showMsg)>

	<cfif bErr>
		<cfset fontColor = "red" />
	<cfelse>
		<cfset fontColor = "blue" />
	</cfif>
	<br><br><br>
	<div align="center" style="font-weight:bold;font-size:14px;color:#fontColor#;">#showMsg#</div>
	
</cfif>

<br><br>
<div align="center">
<CF_smallLink 
	title = "close window" 
	url = "##"
	parameters = "onClick=""JavaScript: window.close();"""
>
</div>
</cfoutput>