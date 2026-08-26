<html>
<head>

</head>
<body>
<cfsavecontent variable="displayresults">
	<cfinclude template="#Application.Doc_Mapping##form.filepath##form.letter_name#">
</cfsavecontent>
<cfloop index = "form_name"  list = "#form.fieldnames#">
<cfif FindNoCase("delete", form_name ,1) >
<cfif #evaluate(form_name)# EQ 1>
	 <cfset displayresults = REReplaceNoCase(displayresults,"<tr id=""#form_name#"" bDelete=""0"">(.*?)</tr>","","ALL")> 
</cfif>
</cfif>
<cfif FindNoCase("custprodnum", form_name ,1) >
<cfif #evaluate(form_name)# NEQ "">
	 <cfset displayresults = REReplaceNoCase(displayresults,"<td ID=""Test"" name=""#form_name#"" align=""left"">(.*?)</td>","<td ID=""Test"" name=""#form_name#"" align=""left"">#evaluate(form_name)#</td>","ALL")> 
</cfif>
</cfif>
</cfloop> 


<cfset filename = REReplaceNoCase(form.letter_name,"system_generated_(.*)", "","ALL")>
<cfset filepath = REReplaceNoCase(form.filepath,"#form.contractId#/", "","ALL")>
<cfparam name="operator_name" default="">
<cfparam name="distributor_name" default="">
<cfparam name="distributor_id" default="">

<!--- <cfoutput>#displayresults#</cfoutput> --->


<CF_Writing_Email_Attachment		Naming_Format="#filename#_#dateformat(now(),"mm_dd_yyyy")#_#timeformat(now(),"hh_mm_sstt")#"
						File_Extension="html"
						Relative_Path="#filepath#"
						iscustomerletter = "1"
						isletter_system_generated = "1"
						folder_name="#form.contractId#"
						Output_Content="#displayresults#"
						addNewLine="No"
						Return_File_Name="fName"
						Return_Letter_Name="lname">
						
						

						
<cfif form.letter_id NEQ "">
	<cfset useLakebaseForgetletterdetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_letters")>
<cfif useLakebaseForgetletterdetails>
	<cftry>
		<cfset getletterdetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_letters", {
				"program_letters_id" = "eq.#form.letter_id#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetletterdetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetletterdetails>
<cfquery name="getletterdetails" datasource="#application.datasource#">
					select * from Program_Letters
					where Program_Letters_id = #form.letter_id#
	</cfquery>
</cfif>
	<cfif getletterdetails.recordcount GT 0>
		<cfset operator_name = getletterdetails.operator_name>
		<cfset distributor_name = getletterdetails.distributor_name>
		<cfset distributor_id = getletterdetails.distributor_id>
	</cfif>
</cfif>

<cfquery name="qInsertLetterSettings" datasource="#application.datasource#">
					INSERT INTO	Program_Letters
					(Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,distributor_id,created_by,system_generated)
					values
				(#form.contractId#,#form.letter_type#,'#lname#','#fName#','#operator_name#','#distributor_name#',
<cfif distributor_id NEQ "">'#distributor_id#'<cfelse>NULL</cfif>,'#request.AccessStructure.user_id#',2)
				</cfquery>
<cfoutput>
<cfinclude template="include_display_letters.cfm">
<form name="FrmAction" target="mywindowname" action="#includeLettersFilename#?CID=#FORM.contractId#" method="post"></form>
</cfoutput>
	<script>
	FrmAction.submit();
	window.close();
	</script>
</body>
</html>
