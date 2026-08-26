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

<CFSAVECONTENT VARIABLE="ProgramDocument">
		<CFINCLUDE TEMPLATE="#Application.Doc_Mapping#\temp_files\contracts\contract_documents\#URL.ID#">

	<!--- Show the Print Command Option box --->
		<CFINCLUDE template="/Common_Files/Printer_Friendly_Script.cfm">
</CFSAVECONTENT>
		<CFOUTPUT>#ProgramDocument#</CFOUTPUT>
<BR>

</BODY>
</HTML>
 