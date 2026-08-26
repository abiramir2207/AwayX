<!----------------------------------------------------------------------------------
Name         :	index.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	04/07/2017
Created By   : 	Tim Ford
Description  : 	Mass Program Load
---------------------------------------------------------------------------------->

<cfsilent>

</cfsilent>
<!DOCTYPE HTML>
<html>
<head>
	<cfsavecontent variable="head_content">
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<cf_include files="/common_files/datatable.css, /styles/css-loader.css">
		<style>
			.right { float: right; }
			.header1 { margin: 10px 0; width: 100%; box-sizing: border-box;}
			div.header2 { margin-bottom:10px; }
			.header2 a { margin-right: 25px; }
			.locked, .info { margin-left:30px; font-weight2:bold; font-size:1em; color:white; padding:5px 20px;  letter-spacing:0.75px; border:2px solid orange; }
			div#msg55 { font-size: 1.15em; letter-spacing:0.9px; }
			div#msg55 p { font-size: 1.35em; margin:20px; padding:20px; background-color: #BDE5F8; letter-spacing:0.9px; }
			button { cursor: pointer; }
			table.datagrid { table-layout: fixed; width:94%; }
			table.datagrid td { height: 20px; overflow: hidden; }
			thead th { text-align:left; }
			thead th > input { width:70%; }
			body { padding:0; margin:0; }
			form { margin:0; padding:0; border2:1px solid blue;}
			div.header {
			  height: 30px;
			  margin:0;
			  background-image:
			    linear-gradient(
			      to right,
			       #010281, #A7CAF2
			    );
			 	color: white;
				font-size: 14px;
				font-weight: bold;
				letter-spacing: 0.75px;
			 	padding:8px 0 0 8px;
			}
			div.header > button { margin:6px 10px; }
			div.page_title { float2:right; margin:8px;
			 	color: white;
				font-size: 14px;
				font-weight: bold;
				letter-spacing: 0.75px;
			}
			div.action { margin:10px; }
			div.action > a { margin:0 15px; }
			th.case, td.case, th.uom, th.promo, td.uom, td.promo, th.blend, td.blend, th.tmargin, td.tmargin { text-align: right !important; }
			th.cb, td.cb { text-align:center; }
			input.case, input.promo, input.blend, input.tmargin { width:100px; text-align: right; }
			select.uom { width:50px; }
			div#content { margin:10px 5px; border2:1px solid red;}
			div.save { display:inline-block; margin-left: 30px; position: relative; top:-4px; }
			a.default { margin:0 30px; }

			div#loader { font-size:16px; text-align: center; height:100%; margin-top:27%; }
			#saveLink{
				position:fixed;
				right:-23px;
				bottom:5px;
				border2:2px solid red;
			}
		</style>
	</cfsavecontent>
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>

<body>
<cfset jQueryUI.widgets = "tooltip">
<cfinclude template="/common_files/jQuery.cfm">
<form name="upload_file" method="post">
	<input type="hidden" name="action" id="action" value="#form.action#">
	<div class="header">
		MASS PROGRAM LOAD
	</div>

	<cfif cgi.request_method eq "post">
		<cfif form.action eq "import">
			<cfset import_from_excel()>
		</cfif>
	<cfelse>
		<cfscript>
		</cfscript>
	</cfif>


	<div class="action">
	<cfoutput>
		<a class='action' id="import" href="import.cfm">#application.util.string.actionLinkFormat('upload program files')#</a>
	</cfoutput>
	</div>
</form>

<cfinclude template="/common_files/dataTables2.cfm">

<script>
	$("#export").click(function(){
		show_loader("EXPORTING NUC TARGETS, PLEASE WAIT...", -3000);
		window.location.href = "export.cfm";
	});
</script>
<cfinclude template="/common_files/focus.cfm">     <!--- 47143 --->
</body>
</html>