<cfset FromAGGrid = 0>
<cfif NOT IsDefined("url.fileName") AND IsDefined("form.fileName")>
	<cfset url.fileName = form.fileName>
	<cfset FromAGGrid = 1>
</cfif>

<cfparam name="url.fileName" default="program_rates" type="string" >
<cfparam name="url.ext" default="csv" type="string" >
	<html>
	<head>
	<title>Download CSV Report</title>
	</head>
<body>
<cfset url.ext = Replace(url.ext,".", "")>

		<cfscript> 
			cr = chr(10);
			extractFileName = url.fileName &'.'& url.ext;
			extractfilepath = application.Doc_Path & "\Temp_Files\Documents\"  & extractFileName;
			if(FromAGGrid == 1){
				s = form.prodRateList;
			}
			else{
				//req = GetPageContext().getRequest();
				req = getHTTPRequestData();
				s = req.content;
			}
			
			s = replace(s,'|||',cr,"all" );
			/*writeDump(s);
			abort*/;
		</cfscript>
		<CFFILE action = "write"
				file="#extractfilepath#"
				output="#s#">
				
		<cfheader name="Content-Disposition" value="attachment; filename=#extractFileName#" >
			<cfcontent type="application/vnd.ms-excel" file="#extractfilepath#">
	
		
	<!--- Get rid of spinner --->
	<SCRIPT>
	
	window.close;
	</SCRIPT>

</body>
</html>