<!doctype html>
<!---------------------------------------------------------------------------------------------------------------------
          Template: /developer/view_log.cfm
              Date: 2018 November
            Author: Chris Nguyen
		   Purpose: View a CF log file
		 Parameter: url.file_name = log file name and extension (e.g. exception.log)

		Requirements: CF 11+ & Work Request 81664 (CF Admin Security)
----------------------------------------------------------------------------------------------------------------------->
<html>
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="description" content="">
        <meta name="viewport" content="width=device-width, initial-scale=1">
		<cfoutput>=
		<title>#url.file_name#</title>
		</cfoutput>
		<cfsavecontent variable="head_content">
        <link rel="stylesheet" type="text/css" href="<cfoutput>#request.forge_cdn#</cfoutput>/common_files/main_style.css">
		<style>
			ul { font-size:1.25em;
				list-style-type: none;
    			margin: 0;
    			padding: 0;
			}
			input.ip {
				margin:0 10px;
			}
			li { height:26px; width:170px; font-size:14px; padding:10px 0 0 10px; -ms-filter:"progid:DXImageTransform.Microsoft.Alpha(Opacity=85)"; opacity:0.85; letter-spacing:0.5px; }
			li:hover { cursor:pointer; background:#D3CAE5; color:blue; -ms-filter:"progid:DXImageTransform.Microsoft.Alpha(Opacity=100)"; opacity:1;}
			p { font-size:13px; }
			.ip { font-size:14px; font-weight:bold; color:green; letter-spacing:0.75px; }
			.btn-secondary { color: #fff; background-color: #CB384A; margin2:0 50px 0 0;}
			button { margin-right: 15px; }
			.zero { margin: 0; padding: 0; }
			input.readonly { margin-left: 15px; font-weight: bold; font-size:13px; }
			label.read { width: 150px; display: inline-block; }
			pre {
				box-sizing: border-box;
				width: 100%;
				padding: 0;
				margin: 0;
				overflow: auto;
				overflow-y: hidden;
				font-size: 12px;
				line-height: 20px;
				background: #efefef;
				border: 1px solid #777;
				/* background: url(lines.png) repeat 0 0; */
				padding: 10px;
				color: #333;
			}
			h3 {
				background-image: linear-gradient(to top, #30cfd0 0%, #330867 100%);
				border-bottom: 1px dotted;
				border-radius: 10px;
				color: white;
				margin-right: 24px;
				margin-top: 10px;
				opacity: .90;
				padding: 10px 15px;
				position: fixed;
				right: 0;
				text-shadow: 2px 2px 2px #aaa;
				top: 0;
				z-index: 99;
			}
		</style>
		</cfsavecontent>
		<cfhtmlhead text="#head_content#">
    </head>

	<body>
		<cfscript>
			adminObj = createObject("component", "cfide.adminapi.administrator");
			cf_admin = application.util.query.cf_admin();
			adminObj.login( cf_admin.password, cf_admin.username );
			debugger = createObject("component", "cfide.adminapi.debugging");
			server.log_folder = debugger.getLogProperty("logdirectory");
			error_message = '';
		</cfscript>

		<cfparam name="url.file_name" default="">
		<cfset url.f = lcase(replace(URL.file_name, '/', '\', 'all'))>
		<cfif url.f is ''>
			<cfset file_content = "Sorry! Log file name is missing.">
		<cfelseif not fileExists(server.log_folder & '\' & url.f)>
			<cfset file_content = "Sorry! " & url.f & " is not found.">
		<cfelse>
			<cffile action="read" file="#server.log_folder & '\' & url.f#" variable="file_content">
			<cfoutput><h3>#url.f#</h3></cfoutput>
			<cfset content_length = len( file_content )>

			<!--- if the log file is big just grap the last portion --->
			<!--- the first number is the size break point (e.g. 500 * 1000 bytes)--->
			<!--- the second number is the splitting factor (e.g. 2) --->
			<cfset splits = [ [9000 * 1000, 8], [4500 * 1000, 4], [2250 * 1000, 2] ]>

			<cfloop array="#splits#" index="split">
				<cfif content_length gt split[1]>
					<cfset file_content = right(file_content, len( file_content) / split[2])>
					<cfbreak>
				</cfif>
			</cfloop>
		</cfif>

		<pre><cfoutput>#encodeForHTMLAttribute( file_content )#</cfoutput></pre>

		<script>
			// reload to get latest after some minutes
			setTimeout(function() {
				location.reload();
			}, 5 * 60 * 1000);

			setTimeout(function() {
                window.scrollTo({ top: document.body.scrollHeight, behavior: 'smooth' });
			}, 500);
        </script>
    </body>
</html>
