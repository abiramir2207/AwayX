<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<title>OnBase Document Viewer</title>
	</head>
	<body>
	<cfscript>
		appSettings = application.appsettingsGet;
		bHasDoc = false;
		DocUrl = application.HTTPVar & cgi.SERVER_NAME & "/common_documents/Temp_Files/Deduction/erpDocs/";
		
		//oDeductionDAO 	= createObject('component','mvc.Models.Deduction.DeductionDAO');
		oDeductionDAO 	= createObject('component','components.deduction.DeductionManager');
		ostring 		= createObject('component','components.util.string');
		
		qDeduction 	= oDeductionDAO.getDeduction(Url.Deduction_Id);
		//random num for file name -> security
		num = Rand("SHA1PRNG") * 1000000000000;
		session.erpDocNum = num;
		//guid string for xtra security
		ddGuid = replace(Url.Deduction_Id,'-','','all');
		//now create fileNames
		desc = qDeduction.DD_DedId;
		fileName = '#desc#_#ddGuid#_#num#.tmp';
		fileNamePdf = '#desc#_#ddGuid#_#num#.pdf';
		//set after cfhttp call
		onBaseName = '';
		onBaseType = '';
		//Locations
		filePath = '#Application.Doc_Path#\Temp_Files\Deduction\erpDocs\';
		fileUrlPath = '/common_Documents/Temp_Files/Deduction/erpDocs/';
		//URL.qs = UrlEncodedFormat(URL.qs);
	</cfscript>

	<!--- Call OnBase to get the Doc---------------------------------------------------->
	<cfhttp method="GET" url="#appSettings.getErpDeductionDocPath()#documents/Document.aspx?qs=#URL.qs#" path="#filePath#" file="#fileName#" resolveUrl="true" timeout="120" />

	<!---<cfoutput>#appSettings.getErpDeductionDocPath()#documents/Document.aspx?qs=#URL.qs#</cfoutput> <cfdump var="#cfhttp#"><cfabort>--->

	<cfscript>
		if(isdefined('cfhttp.Responseheader') && cfhttp.MimeType NEQ "application/pdf"){
			if(isStruct(cfhttp.Responseheader)){
				if(structKeyExists(cfhttp.Responseheader,'content-disposition')){
					onBaseName = cfhttp.Responseheader['content-disposition'];
					//onBaseName = listLast(onBaseName,';' );
					onBaseName = replace(onBaseName,'attachment; filename=','');
					onBaseType = listLast(onBaseName,'.' );
				}
				
			}
		}
	</cfscript>

	<!--- Determine the typy of file we just got and hen display it
			* first we rename it from .tmp to the correct extension
			* then PDF is displayed in line while .xlsx and .doc require links --->
	<cfif fileExists('#filePath##fileName#') >
		<cftry>
			<!--- PDF DISPLAY INLINE------------------------------------>
			<cfif cfhttp.MimeType EQ "application/pdf">
				<!--- http call may not complete or partial file gets written, so check first --->
				<cfif IsPDFFile('#filePath##fileName#')>
					<cfset bHasDoc = true />
					<cffile action="rename" destination="#filePath##fileNamePdf#" source="#filePath##fileName#" >
					<cfcontent type="#cfhttp.MimeType#" file="#filePath##fileNamePdf#" />
				</cfif>
			
			<!--- WORD DOC -------------------------------------------->
			<cfelseif cfhttp.MimeType EQ "application/msword">
				<cfset bHasDoc = true />
				<cfset fileNameDoc = replace(fileName,'tmp',onBaseType) >
				<cffile action="rename" destination="#filePath##fileNameDoc#" source="#filePath##fileName#">
				<div align="center">
				<h3>
				<span style="color:#800000;">Your Word Doc has been located.</span>
					<p></p>
					<cfoutput>
						<!---<a href="ErpDocDownload.cfm?&type=#onBaseType#&Deduction_Id=#URL.Deduction_Id#" target="_blank"><strong>Download</strong></a> Word Doc.--->
						<a href="##" onclick="window.open('ErpDocDownload.cfm?&type=#onBaseType#&Deduction_Id=#URL.Deduction_Id#','erpDocDownload','location=1,status=1,scrollbars=1,resizable=1,width=100,height=100');return false;" >
							<strong>Download</strong></a> Word Doc.	
					</cfoutput>
					
					<p></p>
				</h3>
				</div>
				
			<!--- EXCEL DOC ------------------------------------------->	
			<cfelseif cfhttp.MimeType EQ "application/vnd.ms-excel">
				<cfset bHasDoc = true />
				<cfset fileNameXl = replace(fileName,'tmp',onBaseType) >
				<cffile action="rename" destination="#filePath##fileNameXl#" source="#filePath##fileName#">
				<div align="center">
				<h3>
				<span style="color:#800000;">Your Excel Doc has been located.</span>
					<p></p>
					<cfoutput>
						<!---<a href="ErpDocDownload.cfm?type=#onBaseType#&Deduction_Id=#URL.Deduction_Id#"  target="_blank"><strong>Download</strong></a> Excel Doc.--->
						<a href="##" onclick="window.open('ErpDocDownload.cfm?type=#onBaseType#&Deduction_Id=#URL.Deduction_Id#','erpDocDownload','location=1,status=1,scrollbars=1,resizable=1,width=100,height=100');return false;" >
							<strong>Download</strong></a> Excel Doc.
					</cfoutput>
					<p></p>
				</h3>
				</div>
			<!---  CATCH ALL ------------------------------->
			<cfelse>
				<cfset bHasDoc = true />
				<cfset fileNameXl = replace(fileName,'tmp',onBaseType) >
				<cffile action="rename" destination="#filePath##fileNameXl#" source="#filePath##fileName#">
				<div align="center">
				<h3>
					<cfoutput>
				<span style="color:##800000;">Your "#onBaseType#" file has been located.</span>
					<p></p>
					
						<!---<a href="ErpDocDownload.cfm?type=#onBaseType#&Deduction_Id=#URL.Deduction_Id#"  target="_blank"><strong>Download</strong></a> Excel Doc.--->
						<a href="##" onclick="window.open('ErpDocDownload.cfm?type=#onBaseType#&Deduction_Id=#URL.Deduction_Id#','erpDocDownload','location=1,status=1,scrollbars=1,resizable=1,width=100,height=100');return false;" >
							<strong>Download</strong></a> #onBaseType# Doc.
					</cfoutput>
					<p></p>
				</h3>
				</div>
			</cfif><!--- mimeType elseif --->
			<cfcatch>
				<cflog text="ERP: could not display file  returned from OnBase #filePath##fileName# :: #cfcatch.Message# :: #cfcatch.Detail#" >
				<cfset bHasDoc = false />
			</cfcatch>
		</cftry>
	</cfif> <!--- filexists --->

	<!--- If we still do not have a valid pdf --->
	<cfif bHasDoc EQ false>
		<table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0">
		    <tr>
		        <td style="text-align: center; vertical-align: middle;" width="100%" height="50%">
		        	<h2 style="color:#800000;" width="100%" height="100%">OnBase did not return a valid <cfoutput>"#cfhttp.MimeType#"</cfoutput> file.</h2>
					<!---<p><cfoutput>#appSettings.getErpDeductionDocPath()#documents/Document.aspx?qs=#URL.qs#</cfoutput></p>--->
					<a href="##" onclick="parent.reSubmit();">Try Again</a>
		        </td>
		    </tr>
		</table>
		
		<!--- if file exists, then we know we failed the isPDF() check. Try to delete non pdf file. --->
		<cfif fileExists('#filePath##fileName#')>
			<cflog text="ERP Did not return a pdf from #appSettings.getErpDeductionDocPath()#documents/Document.aspx?#URL.qs#" >
			<cftry>
				<!--- <cffile action="delete" file="#filePath##fileName#"> --->
				<cfcatch>
					<cflog text="ERP: could not delete pdf #filePath##fileName# :: #cfcatch.Message# :: #cfcatch.Detail#" >
				</cfcatch>
			</cftry>
		<cfelse><!--- else file does not exist.  http call did not complete succesfully --->
			<cflog text="ERP Error: #cfhttp.FileContent# at URL #appSettings.getErpDeductionDocPath()#documents/Document.aspx?#URL.qs#" >
		</cfif>
	</cfif>
	</body>
</html>
