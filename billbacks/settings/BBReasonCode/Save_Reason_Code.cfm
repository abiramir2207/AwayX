<!--- 
##	codeType rquired  -- defaults to dd
##	dd = DD_reason_code table -- Deductions and Billback reason codes live in this table
##	PC = PC_reason_code table -- Profit Center
##	GL = GL_Reason_Code table -- General Ledger
## --->
<cfif isdefined("codeType")>
	<CFPARAM NAME="FORM.Show_Operator" DEFAULT="0">
	
	<!--- Delete record --->
	<CFIF FORM.DeleteRecord EQ 1>
		<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
			DELETE FROM #codeType#_Reason_Code  
			WHERE		#codeType#_Reason_Code_ID			=	'#Form.Reason_Code_ID#'
		</CFQUERY>
		<CFLOCATION URL="create_Reason_Code.cfm?codeType=#codeType#" ADDTOKEN="No">
		<CFABORT>
	</CFIF>
	
	<CFIF Form.Reason_Code_ID EQ "">
	<!--- Insert the record --->
		<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
			INSERT INTO		#codeType#_Reason_Code
							(#codeType#_Reason_Code,#codeType#_Reason_Code_Description,Need_Approval,Deleted,Show_Operator)
			Values			('#FORM.Reason_Code#','#Form.Reason_Code_Description#','#Form.Need_Approval#',#Form.Deleted#,#FORM.Show_Operator#)
		</CFQUERY>
		<CFLOCATION URL="create_Reason_Code.cfm?codeType=#codeType#" ADDTOKEN="No">
		<CFABORT>
	<CFELSE>
	<!--- Update the record ---><cfoutput><cfset name = codeType&"_Reason_Code"></cfoutput>
		<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
			UPDATE 		<cfoutput>#codeType#</cfoutput>_Reason_Code
			
			SET 		<cfoutput>#codeType#</cfoutput>_Reason_Code		=	'#FORM.Reason_Code#',
						<cfoutput>#codeType#</cfoutput>_Reason_Code_Description 	=	'#Form.Reason_Code_Description#',
						Need_Approval				=	'#Form.Need_Approval#',
						Deleted						=	#Form.Deleted#,
						Show_Operator				=	#FORM.Show_Operator#
			WHERE		<cfoutput>#codeType#</cfoutput>_Reason_Code_ID				=	'#Form.Reason_Code_ID#'
		</CFQUERY>
		<CFLOCATION URL="create_Reason_Code.cfm?codeType=#codeType#" ADDTOKEN="No">
		<CFABORT>
	</CFIF>
<cfelse><!--- no codeType...go back --->
<CFLOCATION URL="create_Reason_Code.cfm" ADDTOKEN="No">
</cfif>