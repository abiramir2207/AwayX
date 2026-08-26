<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<!--- PARSER TESTING ---> 
<!--- 
curl https://api.docparser.com/v1/ping \
   -u <secret_api_key>:
   
   curl https://api.docparser.com/v1/parsers \
   -u <secret_api_key>:

--->
<!--- 	<cfhttp method="post" url="https://api.docparser.com/v1/parsers"  result="objGet">
		<cfhttpparam type="header" name="Authorization" value="Basic da6152df5175257d3a7d8ff428d1a10aebc6213f" />
	</cfhttp>
	<cfdump
    var="#objGet#"
    label="CFHttp Response"
    /> --->
<!--- <cfhttp    method="get"    url="https://api.docparser.com/v1/parsers"     username="da6152df5175257d3a7d8ff428d1a10aebc6213f"    password=""
    result="objGet"> 
 	<cfhttpparam        type="url"        name="method"        value="Test"        />
</cfhttp> --->
 
<!--- Output the response. --->
<!--- 	curl \
  -u <secret_api_key>: \
  -F "file=@/home/your/local/file.jpdf" \
  https://api.docparser.com/v1/document/upload/<PARSER_ID> 
 --->

<cfif isdefined("FORM.file") AND FORM.file NEQ "">
	<cfdump var = "#form#" />
	<cffile action="upload" destination="#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc" 
			nameconflict="overwrite" result="variables.upload"> 
	<cfdump var="#variables.upload#">
	<cfset FileName = "#variables.upload.SERVERDIRECTORY#\#variables.upload.CLIENTFILE#" />		
	<!--- 
  username = "da6152df5175257d3a7d8ff428d1a10aebc6213f"
	  password="" --->	
	<cfdump var="#FileName#" />
	  <cfhttp   method="post"  url = "https://api.docparser.com/v1/document/upload/eqgmrlpucvhi"  result="objGet">
		<cfhttpparam type="header" name="Authorization" value="Basic da6152df5175257d3a7d8ff428d1a10aebc6213f" />
		<cfhttpparam type="file" file="#FileName#" name="file"/>
	</cfhttp>

Response from DocParser:<br>

<cfdump var="#objGet#" />   
<!--- 
curl \
  -u <secret_api_key>: \
  https://api.docparser.com/v1/results/<PARSER_ID>/<DOCUMENT_ID>
--->
<cfset record=deserializeJSON(objGet.FileContent) />
 
<cfdump var="#record#" /> <br><br>

 <cfhttp   method="post"  url = "https://api.docparser.com/v1/results/eqgmrlpucvhi/#record.id#"  result="getFileContent">
		<cfhttpparam type="header" name="Authorization" value="Basic da6152df5175257d3a7d8ff428d1a10aebc6213f" />
	</cfhttp>
File Content:<br>


<cfdump var="#getFileContent#" />
<br>
<br>
</cfif>
<html>
<head>
	<title>Doc parser testing</title>
	<script>
		function submitForm(submitter)
		{
			var thisForm = document.all.uploadFiles;
			thisForm.submit();
		}
	</script>
</head>

<body>
<br>
<br>

<div><h2>Docparser testing:</h2></div>
<br>
<br>

<strong>Upload a File to docParser:</strong><br>
<br>

	<form id="uploadFiles" name="uploadFiles" method="post" action="docparser1.cfm" ENCTYPE="multipart/form-data">
		<div><input type="file" size="150" name="file" accept=".pdf"/> </div><br>
		[<a href="#" onclick="javascript:return submitForm(this);">upload files</a>]
</body>
</html>
