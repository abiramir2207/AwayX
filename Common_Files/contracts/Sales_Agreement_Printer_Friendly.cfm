<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Printer Friendly Program View</TITLE>
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is the printer friendly page	--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Decode the Program ID that comes from the URL.ID variable --->
<cfparam name="url.bgimage" default="0"> 
<cfparam name="ProgramType" default="">
<cfparam name="Type" default="">
<cf_cryp	type = "de" string = "#URL.ID#" key = "#request.key#">
<CFSET Program_Number=cryp.value>
<!--- Even though this variable ("ExportProgram") is not required, I have added it anyway --->
<CFIF ProgramType EQ "ExportProgram">
<CFSAVECONTENT VARIABLE="ProgramDocument">
<!--- Include the private (Internal) file --->
	<cfif Type eq "Internal">
		<CFINCLUDE TEMPLATE="#Application.Doc_Mapping#\temp_files\contracts\contract_documents\Export_Programs_View_Private_#Program_Number#.htm">
<!--- Include the public (External) file --->
	<cfelseif Type eq "External">
		<CFINCLUDE TEMPLATE="#Application.Doc_Mapping#\temp_files\contracts\contract_documents\Export_Programs_View_Public_#Program_Number#.htm">
	</cfif>
	<!--- Show the Print Command Option box --->
		<CFINCLUDE template="/Common_Files/Printer_Friendly_Script.cfm">
</CFSAVECONTENT>
		<CFOUTPUT>#ProgramDocument#</CFOUTPUT>
</CFIF>
<BR>

</BODY>
</HTML>
 