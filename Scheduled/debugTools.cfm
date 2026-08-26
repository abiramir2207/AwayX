<!doctype html>
<!---------------------------------------------------------------------------------------------------------------------
          Template: /scheduled/debugTools.cfm
              Date: 2018 December
            Author: Chris Nguyen
           Purpose: Debug Tools
----------------------------------------------------------------------------------------------------------------------->
<cfprocessingdirective pageencoding="utf-8">
<html>
<head>
	<meta charset="UTF-8">
	<title>Debug Tools</title>
	<style>
		/* CSS Normalize */
		article,aside,details,figcaption,figure,footer,header,hgroup,nav,section,summary{display:block;}audio,canvas,video{display:inline-block;}audio:not([controls]){display:none;height:0;}[hidden]{display:none;}html{font-family:sans-serif;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;}a:focus{outline:thin dotted;}a:active,a:hover{outline:0;}h1{font-size:2em;}abbr[title]{border-bottom:1px dotted;}b,strong{font-weight:700;}dfn{font-style:italic;}mark{background:#ff0;color:#000;}code,kbd,pre,samp{font-family:monospace, serif;font-size:1em;}pre{white-space:pre-wrap;word-wrap:break-word;}q{quotes:\201C \201D \2018 \2019;}small{font-size:80%;}sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline;}sup{top:-.5em;}sub{bottom:-.25em;}img{border:0;}svg:not(:root){overflow:hidden;}fieldset{border:1px solid silver;margin:0 2px;padding:.35em .625em .75em;}button,input,select,textarea{font-family:inherit;font-size:100%;margin:0;}button,input{line-height:normal;}button,html input[type=button],/* 1 */
		input[type=reset],input[type=submit]{-webkit-appearance:button;cursor:pointer;}button[disabled],input[disabled]{cursor:default;}input[type=checkbox],input[type=radio]{box-sizing:border-box;padding:0;}input[type=search]{-webkit-appearance:textfield;-moz-box-sizing:content-box;-webkit-box-sizing:content-box;box-sizing:content-box;}input[type=search]::-webkit-search-cancel-button,input[type=search]::-webkit-search-decoration{-webkit-appearance:none;}textarea{overflow:auto;vertical-align:top;}table{border-collapse:collapse;border-spacing:0;}body,figure{margin:0;}legend,button::-moz-focus-inner,input::-moz-focus-inner{border:0;padding:0;}

		/* Box-sizing border-box */
		* { -moz-box-sizing: border-box; -webkit-box-sizing: border-box; box-sizing: border-box; }

		body {
			font: 14px Arial, sans-serif;
			background-image: linear-gradient(to right, #3ab5b0 0%, #3d99be 51%, #56317a 100%);
		}
		fieldset {
			background-color: #FCFFF5;
			border: 2px solid #ddd;
			border-radius: 16px;
			box-shadow: 0 0 20px #333;
			margin: 17px 20px;
			width: 250px;
		}
		legend {
			letter-spacing:0.85px;
			font: 18px "Poiret One", Verdana, Arial, sans-serif;
			font-weight: 600;
			background-color: #A7A37E;
			border-radius: 8px;
			color: white;
			font-weight: bold;
			letter-spacing: 1px;
			padding: 7px 10px;
		}
		ul {
			list-style-type: none;
			margin: 0;
			padding: 0;
		}
		li {
			color: black;
			height: 28px;
		}
		a, a:visited, a:focus {
			color: #333;
			text-decoration: none;
			padding: 2px 15px 3px 15px;
			opacity: .8;
		}
		a:hover {
			background-color: gold;
			color: black;
			opacity: 1;
		}

		.container {
			display: flex;
			flex-flow: row wrap;
			justify-content: space-around;
			align-items: flex-start;
		}

		fieldset {
			flex: 0 0 auto;
		}
		.fav {
			color: blue !important;
			opacity: 1;
			font-weight: bolder;
		}
		.fav::after {
			content: " ♥";
		}
		a {
			background-image: linear-gradient(to right, #FFF 50%, #fee603 50%);
			background-position: 0;
			background-size: 200%;
			transition: all 0.35s;
		}
		a:hover {
			background-position: -100%;
		}
		hr.divider {
			/* width: 90%; */
			border: 0;
			height: 1px;
			margin: 10px 0;
			background-image: linear-gradient(to right, rgba(0, 0, 0, 0), rgba(0, 0, 0, 0.75), rgba(0, 0, 0, 0));
		}
		button.view {
			cursor: pointer;
			background-color: #edeef2;
			border-radius: 5px;
			border: 1px solid #d8d9dd;
			box-sizing: border-box;
			box-shadow: 0px 2px 4px -1px rgba(86, 87, 96, 0.3);
			color: #343540;
			font-size: 11px;
			font-weight: 500;
			height: 20px;
			margin: 0 5px;
			padding: 0px 10px 0 10px;
		}
			button.view:hover {
				color: #406be4;
				background-color: #fff;
			}
	</style>
</head>

<!-------------------------------------------------------------------------------------------------------------------->

<cffunction name="renderMenu" output="true">
	<cfargument name="menu_options" hint="Menu options array of arrays">
	<cfargument name="sorting" required="false" default="true" hint="Pass true to sort by menu text">

	<cfsilent>
		<cfset local.delimiter = '|'>
		<cfoutput>
			<cfif arguments.sorting>
				<cfscript>
					arraySort(arguments.menu_options, function (current_element, next_element) {
						return comparenocase(current_element[1], next_element[1]);
					});				
				</cfscript>
			</cfif>
			<cfsavecontent variable="local.menu">
				<ul>
					<cfloop from="1" to="#arrayLen(arguments.menu_options)#" index="local.counter">
						<cfset local.option = arguments.menu_options[ local.counter ]>
						<!--- option[1] = text option + text class (optional, delimiter = '|') --->
						<!--- option[2] = href --->
						<cfif local.option[1] gt ''> 
							<li>
								<cfif local.option[2] eq "html">
									#local.option[1]#
								<cfelse>
									<a target="_blank" href="#local.option[2]#" 
									<cfif listLen(local.option[1], local.delimiter) gt 1>
										class="#listGetAt(local.option[1], 2, local.delimiter)#"
									</cfif>
									>#listFirst(local.option[1], local.delimiter)#</a>
								</cfif>
							</li>
						</cfif>
					</cfloop>
				</ul>
			</cfsavecontent>
		</cfoutput>
	</cfsilent>
	<!--- remove extra white space & display --->
	<cfoutput>#reReplace(local.menu, "\s{2,}|#chr(13)#|#chr(9)#|\n|\r", " ", "ALL" )#</cfoutput>
</cffunction>

<!-------------------------------------------------------------------------------------------------------------------->

<body>
	<cfscript>
		adminObj = createObject("component", "cfide.adminapi.administrator");
		if ( !adminObj.login(decrypt('Y+Slto8jcQ0mHos5wRtdOw==','pS5TTzlv0us673kAx6z95g==',"AES","base64"),decrypt('LmRhfPby99FUT9P4jj/jAQ==','pS5TTzlv0us673kAx6z95g==',"AES","base64")) ) {
			access_denied = true;
		}
		else {
			access_denied     = false;
			debugger          = createObject("component", "cfide.adminapi.debugging");
			server.log_folder = debugger.getLogProperty("logdirectory");
		}
	</cfscript>

	<cfif access_denied>
		<p style="margin:35% 0;text-align:center;font-size:1.5em;">Sorry! Unexpected problem has occurred in accessing admin features. (error 152)</p>
		<cfabort>
	</cfif>

	<cffunction name="dayDiff" output="false">
		<cfargument name="date1" required="true">
		<cfargument name="date2" required="true">

		<cfreturn dateDiff('d', dateFormat(arguments.date1,"short"), dateFormat(arguments.date2,"short"))>
	</cffunction>

	<div class="container">

		<!--------------->
		<!--- CF LOGS --->
		<!--------------->
		<cfdirectory action="list" type="file" directory="#server.log_folder#" name="qDirectory" sort="name ASC">

		<cfset cf_logs = []>
		<!--- display log files updated today --->
		<cfquery name="qqToday" dbtype="query">
			SELECT * 
			  FROM qDirectory 
			 WHERE DateLastModified >= '#dateFormat(now(), 'yyyy-m-d')#'
		</cfquery>

		<cfif qqToday.recordCount>
			<cfset arrayAppend(cf_logs, [ "<b style='margin-left:10px;color:##CCC'>Updated Today</b>", "html" ])>
			<cfoutput query="qqToday">
				<cfset arrayAppend(cf_logs, [ qqToday.Name & "|log", "view_log.cfm?f=#server.log_folder#/#qqToday.Name#" ])>
			</cfoutput>
			<cfset arrayAppend(cf_logs, [ "<hr class='divider'>", "html" ])>
		</cfif>

		<!--- display log files updated yesterday --->
		<cfquery name="qqYesterday" dbtype="query">
			SELECT * 
			  FROM qDirectory 
			 WHERE DateLastModified >= '#dateFormat(dateadd("d", -1, now()), 'yyyy-m-d')#'
			  		AND DateLastModified < '#dateFormat(now(), 'yyyy-m-d')#'
		</cfquery>

		<cfif qqYesterday.recordCount>
			<cfset arrayAppend(cf_logs, [ "<b style='margin-left:10px;color:##CCC'>Updated Yesterday</b>", "html" ])>
			<cfoutput query="qqYesterday">
					<cfset arrayAppend(cf_logs, [ qqYesterday.Name & "|log", "view_log.cfm?f=#server.log_folder#/#qqYesterday.Name#" ])>
			</cfoutput>
			<cfset arrayAppend(cf_logs, [ "<hr class='divider'>", "html" ])>
		</cfif>

		<!--- display log files updated before yesterday --->
		<cfoutput query="qDirectory">
			<cfif dayDiff(qDirectory.DateLastModified, now()) gt 1>
				<cfset arrayAppend(cf_logs, [ qDirectory.Name & "|log", "view_log.cfm?f=#server.log_folder#/#qDirectory.Name#" ])>
			</cfif>
		</cfoutput>

		<fieldset>
			<legend align="center">CF Logs</legend>
			<div style="font-size:8px;padding:9px 9px 15px 9px;">
				<label><input type="checkbox" name="tail" id="tail" checked style="position:relative;top:2px;"> Display only the last part of log file for better speed</label>
			</div>
			<cfset renderMenu( cf_logs, 0 )>
		</fieldset>

		<!-------------------->
		<!--- EVENT ERRORS --->
		<!-------------------->
		<cfset qErrors = directoryList(expandPath("/common_documents/Data_Files/Created/error_files"), false, "query", "error_*.htm", "DateLastModified DESC")>
		<cfset event_errors = []>
		<!--- display today's errors --->
		<cfquery name="qqToday" dbtype="query">
			SELECT * 
			  FROM qErrors 
			 WHERE DateLastModified >= '#dateFormat(now(), 'yyyy-m-d')#'
		</cfquery>
		<cfif qqToday.recordCount>
			<cfset arrayAppend(event_errors, [ "<b style='margin-left:10px;color:##CCC'>Created Today</b>", "html" ])>
			<cfoutput query="qqToday">
				<cfset error_number = replace(replace(qqToday.Name, "error_", ""), ".htm", "")>
				<cfset arrayAppend(event_errors, [  error_number & "|error", "/common_documents/Data_Files/Created/error_files/#qqToday.Name#" ])>
			</cfoutput>
			<cfset arrayAppend(event_errors, [ "<hr class='divider'>", "html" ])>
		</cfif>

		<!--- display yesterday's errors --->
		<cfquery name="qqYesterday" dbtype="query">
			SELECT * 
			  FROM qErrors 
			 WHERE DateLastModified >= '#dateFormat(dateadd("d", -1, now()), 'yyyy-m-d')#'
			  		AND DateLastModified < '#dateFormat(now(), 'yyyy-m-d')#'
		</cfquery>
		<cfif qqYesterday.recordCount>
			<cfset arrayAppend(event_errors, [ "<b style='margin-left:10px;color:##CCC'>Created Yesterday</b>", "html" ])>
			<cfoutput query="qqYesterday">
				<cfset error_number = replace(replace(qqYesterday.Name, "error_", ""), ".htm", "")>
				<cfset arrayAppend(event_errors, [  error_number & "|error", "/common_documents/Data_Files/Created/error_files/#qqYesterday.Name#" ])>
			</cfoutput>
			<cfset arrayAppend(event_errors, [ "<hr class='divider'>", "html" ])>
		</cfif>

		<!--- display errors within the last 7 days --->
		<cfquery name="qqSevenDays" dbtype="query">
			SELECT * 
			  FROM qErrors 
			 WHERE DateLastModified < '#dateFormat(dateadd("d", -1, now()), 'yyyy-m-d')#'
			  		AND DateLastModified > '#dateFormat(dateadd("d", -7, now()), 'yyyy-m-d')#'
		</cfquery>
		<cfif qqSevenDays.recordCount>
			<cfoutput query="qqSevenDays">
				<cfset error_number = replace(replace(qqSevenDays.Name, "error_", ""), ".htm", "")>
				<cfset arrayAppend(event_errors, [ error_number & "|error", "/common_documents/Data_Files/Created/error_files/#qqSevenDays.Name#" ])>
			</cfoutput>
		</cfif>

		<fieldset>
			<legend align="center">Event Errors</legend>
			<div style="font-size:10px;padding:9px 9px 15px 9px;">
				<p>Enter the error number</p> <input type="text" name="error_number">
				<button class="view">view</button>
			</div>
			<cfset renderMenu( event_errors, 0 )>
		</fieldset>

	</div>

	<cfif structKeyExists(cgi, "cf_template_path")>
		<!--- self delete this file to avoid security issues --->
		<cffile action="delete" file="#cgi.cf_template_path#">
	</cfif>

	<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
	<script>
		function popupInCenter(url, title, w, h) {
			w = 1366;
			h = 768;
			title = title || "_popup_" + Math.random().toString(36).substring(7);
			var left = Math.floor( ( screen.availWidth  - w ) / 2 )
				,top = Math.floor( ( screen.availHeight - h ) / 2 );
			return window.open(url, title, 'toolbar=no, location=no, directories=no, status=no, menubar=no, copyhistory=no, scrollbars=yes, resizable=yes, width='+w+', height='+h+', top='+top+', left='+left);
		}

		
		$("a.log").click(function(){
			popupInCenter( $(this).attr("href") 
							+ "&tail=" + (document.getElementById('tail').checked ? 1 : 0)
						);
			return false;
		});

		$("a.error").click(function(){
			popupInCenter( $(this).attr("href") );
			return false;
		});

		$("button.view").click(function() {
			let error_number = $("input[name=error_number]").val();
			popupInCenter( "/common_documents/Data_Files/Created/error_files/error_" + $.trim(error_number) + ".htm" );
			return false;
		});
	</script>

</body>
</html>
