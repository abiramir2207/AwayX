<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- The CFSILENT tag precludes any messages or output from ever reaching the browser				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <cfsilent> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Get the file that needs cleaning																 --->
<cfsavecontent variable = "var">
	<CFINCLUDE TEMPLATE="#Application.Doc_Mapping#/temp_files/contracts/contract_documents/#filename#.htm">
</cfsavecontent> 

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Clean the HTML for the PDF																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET var=replace(var, "<IMG SRC=""/images_public/logo_email_BSA.gif"">",		"",		"All")>
<CFSET var=replace(var, "<IMG SRC=""/images_public/logo_email_BSA_footer.gif"">",	"",	"All")>
<CFSET var=replace(var, "&nbsp;",					"",					"All")>
<CFSET var=replace(var, "+1",   					"+2",				"All")>
<CFSET var=replace(var, "CLASS=""Maintable""",   	"",					"All")>
<CFSET var=replace(var, "BGCOLOR=""FFFFFF""",   	"",					"All")>
<CFSET var=replace(var, "BGCOLOR=""CCFFCC""",   	"",					"All")>
<CFSET var=replace(var, "BGCOLOR=""F2F2F2""",   	"",					"All")>
<CFSET var=replace(var, "BGCOLOR=""FFCE84""",   	"",					"All")>
<CFSET var=replace(var, "BGCOLOR=""CCFFCC""",		"",					"All")>
<CFSET var=replace(var, "<HR COLOR=""Orange"">", 	"",					"All")>
<CFSET var=replace(var, " ALIGN=""right""",			" ALIGN=""left""",	"All")>
<CFSET var=replace(var, "WIDTH=""165""", 			"WIDTH=""150""",	"All")>
<CFSET var=replace(var, "TABLE BORDER=""0"" CELLSPACING=""0"" CELLPADDING=""2"" WIDTH=""95%""",   "TABLE BORDER=""1"" CELLSPACING=""0"" CELLPADDING=""1"" WIDTH=""535""","All")>
<CFSET var=replace(var, "STYLE=""border-bottom:solid black 1px; border-right:solid black 1px; border-left:solid silver 1px; border-top:solid silver 1px;""",   		"",					"All")>

	<!--- get install path --->	
	<CFSET InstallPath = APPLICATIONPATH>
	<!--- END get install path --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Create the PDF file																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CF_HTML2PDF3 
	myHTMLDOC	=	"#InstallPath#\customtags\pdf_maker\htmldoc.exe"
	mySTATPATH	=	"#InstallPath#\Common_Files\contracts\contract_documents"
	mySTATFILE	=	"#filename#"
	myOPTIONS	=	"--logoimage #InstallPath#\images_public\logo_email_BSA_footer.gif --footer .l. --left 0.50in --right 0.50in --top 0.25in --bottom 0.25in --portrait --bodyfont Helvetica --fontsize 8pt --fontspacing 1"
	myPDFPath	=	"#InstallPath#\Common_Files\contracts\contract_documents"
	myPDF		=	"#filename#.pdf"
	myOUTPUT	=	"No">
		<CFOUTPUT>
			<IMG SRC="#InstallPath#\images_public\logo_email_BSA.gif">
			<HR SIZE="1">
			#Var#
		</CFOUTPUT>
</CF_HTML2PDF3>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- </cfsilent> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
