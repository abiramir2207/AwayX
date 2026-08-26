<!doctype html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Document</title>
</head>
<body>
<cfsilent>
<!---------------------------------------------------------------------------------------------------------------------
      Template:
      Date:     2015 March
      Author:   Chris Nguyen
      Purpose:  Open file content

      Parameters:

            Type = Excel | PDF
            FileName = file name and file extension
            WebServerPath = expanded path of the file without the file name and file extension
----------------------------------------------------------------------------------------------------------------------->
<cfset variables.webServerFullPath = replace( url.webServerPath, '\', '/', 'all' ) & '/' & url.fileName>
</cfsilent>
<cfif url.type eq 'xls'>
    <cfheader name="Content-Disposition" value="attachment; filename=#url.fileName#">
    <cfcontent type="application/vnd.ms-excel"  file="#variables.webServerFullPath#">
</cfif>
</body>
</html>
