<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<title>OnBase Document Viewer</title>
	</head>
	<body>
	<cfparam name="URL.type" default="" >
	<cfdump var="#session#">
	<cfif isDefined("session.erpDocNum")>
		<cfscript>
			appSettings = application.appsettingsGet;
			DocUrl = application.HTTPVar & cgi.SERVER_NAME & "/common_documents/Temp_Files/Deduction/erpDocs/";
			
			//oDeductionDAO 	= createObject('component','mvc.Models.Deduction.DeductionDAO');
			oDeductionDAO 	= createObject('component','components.deduction.DeductionManager');
			ostring 		= createObject('component','components.util.string');
			
			qDeduction 	= oDeductionDAO.getDeduction(Url.Deduction_Id);
			
			ddGuid = replace(Url.Deduction_Id,'-','','all');
			num = session.erpDocNum;
			//now create fileNames
			desc = qDeduction.DD_DedId;
			//now create fileNames
			fileNameToDisplay = '#desc#.#URL.type#';
			//on server
			fName = '#desc#_#ddGuid#_#num#.#URL.type#';

			//Locations
			filePath = '#Application.Doc_Path#\Temp_Files\Deduction\erpDocs\';
			fileUrlPath = '/common_Documents/Temp_Files/Deduction/erpDocs/';
			//URL.qs = UrlEncodedFormat(URL.qs);
		</cfscript>
		
		<cfheader name="Content-Disposition" value="attachment; filename=#fileNameToDisplay#" >
		
		<cfif URL.type contains "doc">
			<cfcontent type="application/msword" file="#filePath##fName#">
		<cfelse>
			<cfcontent type="application/vnd.ms-excel" file="#filePath##fName#">
		</cfif>
	<cfelse>
		<h2>INVALID REQUEST</h2>
	</cfif>

	</body>
</html>