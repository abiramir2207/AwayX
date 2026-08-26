<!doctype html>
<html>
<head>
	<TITLE>Printer Friendly Program View</TITLE>
	<cfsavecontent variable="head_content">
		<style>
			body {
				box-sizing: border-box;
				padding: 10px;
				width: 800px;
			}
		</style>
	</cfsavecontent>
	<cfhtmlhead text="#head_content#">
</head>
<body>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is the printer friendly page																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Decode the Program ID that comes from the URL.TID variable --->
<cfparam name="url.bgimage" default="0"> 
<cf_cryp	type = "de" string = "#URL.ID#" key = "#request.key#">
<CFSET Program_Number=cryp.value>

<CFINCLUDE TEMPLATE="#Application.Doc_Mapping#/temp_files/contracts/contract_documents/#Program_Number#.htm"><BR>
<CFINCLUDE template="/Common_Files/Printer_Friendly_Script.cfm"> 
</body>
</html>