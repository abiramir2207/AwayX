<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Print custom tag															
Print_Common.cfm															
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Attribute																	
Include_File_path is must													
and it should contain the path to the file which is to be included			
																			
If the include file is expecting any variable pass it as an attribute to this
custom tag.																	
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<CFSET PRINT_Expected_Attribute_List = "Include_File_path">
<CFPARAM NAME="Attributes.Include_File_path" 	DEFAULT="">
<CFPARAM NAME="Attributes.contract_number" 	DEFAULT="">

<cfset CT_File_Mapping = "">
<cfif IsDefined("Caller.Application.Doc_Mapping")>	
	<cfset CT_File_Mapping = Caller.Application.Doc_Mapping>
</cfif>

<CFIF Len(Trim(Attributes.Include_File_path)) LTE 0>
	<CFABORT>
</CFIF>
<CFLOOP COLLECTION="#Attributes#" ITEM="FormItem">
	<CFIF NOT ListFindNoCase(PRINT_Expected_Attribute_List, FormItem, ",")>
		<CFSET "#FormItem#"="#Evaluate("Attributes.#FormItem#")#">
	</CFIF>
</CFLOOP>
<cfif Attributes.contract_number NEQ "">
	<cfset url.contract_number = Attributes.contract_number>
	</cfif>

<CFSAVECONTENT VARIABLE="PRINT_FILE_CONTENT">
<cfif Right(Attributes.Include_File_path, 4) neq ".cfm">
		<CFINCLUDE TEMPLATE="#CT_File_Mapping##Attributes.Include_File_path#">
<cfelse>
	<CFINCLUDE TEMPLATE="#Attributes.Include_File_path#">
</cfif>
</CFSAVECONTENT>


<HTML>
<HEAD>
<TITLE>Print</TITLE>
</HEAD>
<BODY>
<CFOUTPUT>#PRINT_FILE_CONTENT#</CFOUTPUT>



<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
The following is the print help
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<CFINCLUDE template="/Common_Files/Printer_Friendly_Script.cfm"> 
 

</BODY>
</HTML>