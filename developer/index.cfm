<cfsetting showDebugOutput="no">
<!doctype html>
<cfsilent>
<!---------------------------------------------------------------------------------------------------------------------
          Template: /developer/index.cfm
              Date: 2017 February
            Author: Chris Nguyen
           Purpose: Display developer tools
		Requirements: CF 11+ & Work Request 81664 (CF Admin Security)
----------------------------------------------------------------------------------------------------------------------->
</cfsilent>
<html>
    <head>
		<meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="description" content="">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Developer Tools</title>
		<cfsavecontent variable="head_content">
        <style>
			body { background-image:url(6EEx8v.png);background-repeat:repeat; }
			h2 { color:#2200CC; font-size:16px; letter-spacing:0.75px; margin:5px; opacity: 0.8; }
			ul { font-size:1.25em; list-style:none; padding:0 10px; }
			li { height:21px; width:90%; font-size:14px; margin:5px 0; padding: 3px 9px; opacity:0.8; letter-spacing:0.25px; }
			li:hover { cursor:pointer; background:#D3CAE5; color:blue; opacity:1; }
			img { margin-right:10px; position:relative; top:2px; }
			.close { margin:20px 20px 20px 40px; }
			.btn-secondary { color: #fff; background-color: #CB384A; margin2:0 24px 0 0;}
			#footer { position: fixed; left: 0; bottom: 0; width: 100%; display:flex; justify-content: space-around; margin-bottom: 15px; }
        </style>
		<link rel="stylesheet" type="text/css" href="https://cdn.awayx.com/base/common_files/main_style.css">
		<link rel="stylesheet" type="text/css" href="https://cdn.awayx.com/base/styles/css-loader.css">
		</cfsavecontent>
		<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
		<cfhtmlhead text="#head_content#">
    </head>

    <cfsilent>
    <cfscript>
        if (request.accessstructure.user_rights_id neq 9999) {
            abort;
        }
    	param name="form.action" default="";
		factory  = createObject("java","coldfusion.server.ServiceFactory");
		debugger = factory.getDebuggingService();
        if (structKeyExists(url, "sqlDumpOn")) {
            debugger.setEnabled(1);
        }
    	else if (cgi.request_method eq "post") {
    		if (form.action eq "cfdebug_on") {
    			debugger.setEnabled(1);
    		}
    		else if (form.action eq "cfdebug_off") {
    			debugger.setEnabled(0);
    		}
    		else if (form.action eq "restart_mail") {
				MailSpoolService = factory.mailSpoolService;
				MailSpoolService.stop();
				MailSpoolService.start();
			}
    		sleep(1500);
    	}
    </cfscript>
    <cfif form.action eq "clear_cache">
		<cfobjectcache action="CLEAR">
    </cfif>
    </cfsilent>

	<body>
		<cfset server_ip = createObject("java", "java.net.InetAddress").getLocalHost().getHostAddress()>
    	<h2 class="shadow secondary"><img src="iconmonstr-wrench-24-24.png" title=<cfoutput>"Server IP  #server_ip#  - ColdFusion  #replace(server.coldfusion.productVersion,",",".","all")# "</cfoutput>> Developer Tools</h2>
    	<hr class="four">

        <cfif structKeyExists(url, "sqlDumpOn")>
            <!--- for performance reasons do not dump more than 300 rows --->
            <cfif isNumeric(url.sqlDumpOn) and url.sqlDumpOn gt 0 and url.sqlDumpOn lt 300>
                <cfcookie name="sqlDumpOn" value="#url.sqlDumpOn#">
            <cfelse>
                <!--- default to dump top 25 rows --->
                <cfcookie name="sqlDumpOn" value=25>
            </cfif>
        <cfelseif structKeyExists(url, "sqlDumpOff")>
            <cfcookie name="sqlDumpOn" value=0>
        </cfif>

        <!--- <cfdump var="#cookie#"> --->

    	<!--- <cfdump var="#server#"> --->

    	<form name="tool" method="post">
    	<input name="action" type="hidden">
    	<ul>
    		<!--- <cfif debugger.isEnabled()>
				<li action="cfdebug_off"><img src="iconmonstr-debug-off.png"> Turn OFF ColdFusion debug</li>
    		<cfelse>
    			<li action="cfdebug_on"><img src="iconmonstr-debug-on.png"> Turn ON ColdFusion debug</li>
    		</cfif>
            <cfif structKeyExists(cookie, "sqlDumpOn") and val(cookie.sqlDumpOn) gt 0>
                <li action="sqldump_off"><img src="iconmonstr-debug-off.png"> Turn OFF SQL content </li>
            <cfelse>
                <li action="sqldump_on"><img src="iconmonstr-debug-on.png"> Turn ON SQL content </li>
            </cfif> --->
            <li action="view_event_errors"><img src="iconmonstr-note-38-16.png"> Event Errors</li>
    		<li action="query_database"><img src="iconmonstr-database.png"> Query Database</li>
            <li action="view_db_schema"><img src="iconmonstr-database-6-16.png"> Database Tables</li>
            <li action="list_procedures"><img src="iconmonstr-database-6-16.png"> Database Procedures</li>
			<li action="excel_info"><img src="iconmonstr-file.png"> Excel Information</li>
            <li action="_settings"><img src="iconmonstr-control-panel.png"> Settings</li>
    		<li action="debug_info"><img src="iconmonstr-computer-7-16.png"> CF Debugging </li>
			<li action="variables"><img src="iconmonstr-eye-6-16.png"> CF Variables </li>
    		<li action="resetutil"><img src="iconmonstr-control-panel.png"> Refresh Application Utility</li>
    		<li action="upgrade"><img src="iconmonstr-refresh.png"> Run Upgrade Utility</li>
    		<li action="restart_mail"><img src="iconmonstr-email.png"> Restart Mail Server</li>
    		<li action="clear_cache"><img src="iconmonstr-synchronization.png"> Clear Cache</li>
    		<li action="clear_temp_files"><img src="iconmonstr-file.png"> Clear Temp Files</li>
			<li action="clear_program_files"><img src="iconmonstr-note.png"> Clear Program Files</li>
			<li action="auditing"><img src="iconmonstr-eye-6-16.png"> Auditing</li>

			<cfset ocr_upload_on = application.util.query.get_setting("OCR_Upload_ON", 0)>
			<cfif ocr_upload_on is "1" or ocr_upload_on is "on">
				<li action="OCRUploadInfo"><img src="iconmonstr-info-10-16.png">Get CIA Upload Info</li>
				<li action="OCRTesting"><img src="iconmonstr-bug-12-16.png">CIA Regression Testing</li>
			</cfif>
    	</ul>
    	</form>

    	<div id="footer">
    		<!--- <hr class="four"> --->
			<!--- <button class="btn btn-secondary" onclick='NewWindow("https://confluence.awayx.com/display/PD/Daily+Priorities");return false;'>daily priorities</button> --->
    	    <button class="btn btn-primary"   onclick="close_popups(); return false;">close popups</button>
			<button class="btn btn-secondary" onclick='window.popups.push(NewWindow("file_explorer/index.cfm")); return false'>file explorer</button>
			<button class="btn btn-secondary" onclick='window.popups.push(NewWindow("https://confluence.awayx.com/display/PD/SQL+Snippets")); return false'>sql snippets</button>
			<!--- <button class="btn btn-secondary" onclick='NewWindow("http://tools.awayx.com/punchlist/client_list.cfm?stageprod=s"); return false'>stage sites</button> --->
    	</div>
        <script src="default.js?v=092025405"></script>
        <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
        <script>
            window.popups = [];

        	$("li").click(function(){
        		var action = $(this).attr("action");
        		if (action == "clear_temp_files") {
                    window.popups.push(popupCenter("/settings/clear_temp_files.cfm", "Clear Temp Files", "sm", "sm"))
        			return false;
        		}
        		else if (action == "clear_program_files") {
        			window.popups.push(popupCenter("/scheduled/clear_program_files.cfm", "Clear Temp Files", "sm", "sm"));
        			return false;
        		}
        		else if (action == "debug_info") {
        			window.popups.push(popupCenter("debug_info.cfm", "Manage Debugging Information", "lg", "md"));
        			return false;
        		}
        		else if (action == "query_database") {
        			window.popups.push(popupCenter("queryDatabase.cfm", "", "lg", "lg"));
        			return false;
        		}
        		else if (action == "resetutil") {
        			$("form[name=tool]").attr("action", "index.cfm?resetUtil=1");
        		}
        		else if (action == "upgrade") {
        			window.popups.push(popupCenter("/scheduled/upgrade.cfm", "Upgrade Utility", "sm", "sm"));
        			return false;
        		}
                else if (action == "view_db_schema") {
                    window.popups.push(popupCenter("view_db_schema.cfm", "View Database Tables", "sm", "lg"));
                    return false;
                }
                else if (action == "list_procedures") {
                    window.popups.push(popupCenter("list_procedures.cfm", "View Database Procedures", "md", "lg"));
                    return false;
                }
                else if (action == "view_event_errors") {
                    window.popups.push(popupCenter("view_event_errors.cfm", "View Event Errors", "sm", "lg"));
                    return false;
                }
                else if (action == "sqldump_on") {
                    window.location = <cfoutput>"//#cgi.server_name#/#cgi.script_name#?sqlDumpON"</cfoutput>;
                    return;
                }
                else if (action == "sqldump_off") {
                    window.location = <cfoutput>"//#cgi.server_name#/#cgi.script_name#?sqlDumpOFF"</cfoutput>;
                    return;
                }
                else if (action == "_settings") {
                    window.popups.push(popupCenter("_settings.cfm", "Maintain _Settings", "lg"));
                    return;
                }
				else if (action == "OCRUploadInfo") {
        			window.popups.push(popupCenter("/billbacks/OCR_Upload/scheduled/UploadID_Info.cfm", "OCR Upload ID Info", "md", "md"));
        			return false;
        		}
				else if (action == "OCRTesting") {
        			window.popups.push(popupCenter("/billbacks/OCR_Upload/scheduled/OCR_Testing.cfm?UID=<cfoutput>#request.AccessStructure.user_id#</cfoutput>", "OCR Upload Testing", "md", "md"));
        			return false;
        		}
				else if (action == "variables") {
        			window.popups.push(popupCenter("variables.cfm?application&request&session&cookie&server", "Inspect Variables", "lg", "lg"));
        			return false;
        		}
                else if (action == "excel_info") {
                    window.popups.push(popupCenter("excel_info.cfm", "Excel Information", "md", "lg"));
                    return false;
                }
                else if (action == "auditing") {
                    window.popups.push(popupCenter("v2/_auditing.cfm", "Auditing", "md", "lg"));
                    return false;
                }
        		show_loader( $(this).text().toUpperCase() + ", PLEASE WAIT...");
        		$("input[name=action]").val(action);
        		$("form[name=tool]").submit();
            });

            $(window).unload( close_popups );
        </script>

        <cfset request.focusHiLightOff = 1>
    </body>
</html>