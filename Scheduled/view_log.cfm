<!doctype html>
<!---------------------------------------------------------------------------------------------------------------------
          Template: /scheduled/view_log.cfm
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
		<title>View Log</title>
		<cfsavecontent variable="head_content">
        <!--- <link rel="stylesheet" type="text/css" href="https://cdn.awayx.com/base/common_files/main_style.css"> --->
		<style>
			body {
				font-family: Consolas, "Andale Mono WT", "Andale Mono", "Lucida Console", "Lucida Sans Typewriter", "DejaVu Sans Mono", "Bitstream Vera Sans Mono", "Liberation Mono", "Nimbus Mono L", Monaco, "Courier New", Courier, monospace;				
			}
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
				background: #efefef;
				border: 1px solid #777;
				box-sizing: border-box;
				color: #333;
				font-size: 12px;
				line-height: 20px;
				margin: 0;
				overflow-x: auto;
				overflow-y: hidden;
				overflow: auto;
				padding: 0;
				padding: 10px;
				white-space: pre-wrap;
				width: 100%;
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
div.mark {
  position:fixed;
  bottom:50px;
  right:5px;
  text-align: right;
}
input[name=mark_text]{
  width:75px;
  height: 18px;
	outline: none;
	border-color: #9ecaed;
	box-shadow: 0 0 10px #9ecaed;
	background-color: #FFFE9D;
}
mark {
  background: yellow;
}
mark.current {
  background: orange;
}
		</style>
		</cfsavecontent>
		<cfhtmlhead text="#head_content#">
    </head>

	<body>
		<cfparam name="url.f" default="">
		<cfset url.f = lcase(replace(URL.f, '/', '\', 'all'))>
		<cfif url.f is ''>
			<cfset file_content = "Sorry! Log file name is missing.">
		<cfelseif not fileExists(url.f)>
			<cfset file_content = "Sorry! " & url.f & " is not found.">
		<cfelse>
			<cffile action="read" file="#url.f#" variable="file_content">					
			<cfoutput><h3>#listLast(url.f, '\')#</h3></cfoutput>
			<cfset content_length = len( file_content )>

			<cfparam name="url.tail" default="1">
			<cfif url.tail eq '1'>
				<!--- if the log file is big just grap the last portion --->
				<!--- the first number is the log file size break point (e.g. 9000 * 1000 bytes)--->
				<!--- the second number is the splitting factor (e.g. 8) --->
				<cfset splits = [ [9000 * 1000, 8], [4500 * 1000, 4], [2250 * 1000, 2] ]>
				
				<cfloop array="#splits#" index="split">
					<cfif content_length gt split[1]>
						<cfset file_content = right(file_content, len( file_content) / split[2])>
						<cfbreak>
					</cfif>
				</cfloop>
			</cfif>
		</cfif>

		<pre><cfoutput>#encodeForHTMLAttribute( file_content )#</cfoutput></pre>

		<script>
			window.scrollTo(0, document.body.scrollHeight);   // go to the bottom
			
			<cfif url.tail eq '1'>
				// reload to get latest after some minutes
				setTimeout(function() {
					location.reload();
				}, 5 * 60 * 1000);
			</cfif>
		</script>
	</body>
</html>
