<cfsetting showDebugOutput="no">
<!doctype html>
<!---------------------------------------------------------------------------------------------------------------------
          Template: /developer/debug_info.cfm
              Date: 2018 November
            Author: Chris Nguyen
           Purpose: Manage debugging information
		Requirements: CF 11+ & Work Request 81664 (CF Admin Security)
----------------------------------------------------------------------------------------------------------------------->
<html>
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="description" content="">
        <meta name="viewport" content="width=device-width, initial-scale=1">
		<title>Manage Debugging Information | Developer Tools</title>
		<cfsavecontent variable="head_content">
        <link rel="stylesheet" type="text/css" href="https://cdn.awayx.com/base/common_files/main_style.css">
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
			input.readonly { margin: 0 10px 0 0; font-weight: bold; font-size:13px; }
			input.short { width: 100px; }
			input.long { width: 300px; }
			label.read { font-size: 11px; }
			h2.secondary { text-align: center; }
			p.notification { color:red; font-size:13px; font-weight:normal; margin-bottom:20px; letter-spacing:0.4px; text-align:center; }
			input[type="checkbox"] { vertical-align: middle; }
        </style>
        <script src="default.js?v=092025405"></script>
		</cfsavecontent>
		<cfhtmlhead text="#head_content#">
    </head>

	<cffunction name="dayDiff" output="false">
		<cfargument name="date1" required="true">
		<cfargument name="date2" required="true">

		<cfreturn dateDiff('d', dateFormat(arguments.date1,"short"), dateFormat(arguments.date2,"short"))>
	</cffunction>

	<body>
		<cfscript>
			adminObj = createObject("component", "cfide.adminapi.administrator");
			cf_admin = application.util.query.cf_admin();
			adminObj.login( cf_admin.password, cf_admin.username );
			debugger             = createObject("component", "cfide.adminapi.debugging");
			runtime              = createObject("component", "CFIDE.adminapi.runtime");
			datasource           = createObject("component", "cfide.adminapi.datasource");
			server.instance_name = runtime.getInstanceName();
			server.log_folder    = debugger.getLogProperty("logdirectory");
			server.ip            = createObject("java", "java.net.InetAddress").getLocalHost().getHostAddress();
			server.datasource    = datasource.getDatasources( application.datasource );
			notification_msg     = '';
		</cfscript>

		<cfif cgi.request_method is "post">
			<cfscript>
				if (request.accessstructure.user_rights_id neq 9999) {
					abort;
				}
			</cfscript>

			<cfif form.action is "add">
				<cfset objIP = createObject("java","coldfusion.util.IPAddressUtils")>
				<cfif objIp.validateIPv4Address( form.new_ip )>
					<cfset debugger.setIP( form.new_ip )>
					<cfset notification_msg = "✔ Success - " & form.new_ip & " has been added.">
					<cfset form.new_ip = ''>
				<cfelse>
					<cfset notification_msg = " ⚠ Sorry - " & form.new_ip & " is not a valid IP address, please reenter.">
				</cfif>

			<!--- remove IP addresses --->
			<cfelseif form.action is "remove ip">
				<cfscript>
					ip_addresses = listToArray(form.ip);
				</cfscript>
				<cfloop from="1" to="#arrayLen(ip_addresses)#" index="counter">
					<cfset debugger.deleteIP( ip_addresses[counter] )>
				</cfloop>
				<cfset notification_msg = "✔ Success - Selected IP" & (arrayLen(ip_addresses) eq 1 ? " has" : "s have") & " been removed.">

			<!--- remove log file --->
			<cfelseif form.action is "remove log">
				<cftry>
					<cffile action="rename" source="#server.log_folder#\#form.log_file#" destination="#server.log_folder#\#form.log_file#.#dateTimeFormat(now(),'yyyy m d h:nn:ss tt')#">
					<cfset notification_msg = "✔ Success - " & form.log_file & " file has been removed.">
				<cfcatch type="any">
					<cfset notification_msg = " ⚠ Sorry - " & cfcatch.message>
					<cfdump var="#cfcatch#">
				</cfcatch>
				</cftry>

			<!--- toggle cdn setting --->
			<cfelseif form.action is "update cdn">
				<cfset toggle_value = (application.util.query.get_setting("FORGE_CDN") eq "" ? "https://cdn.awayx.com/base" : "")>
				<cfquery datasource="#application.datasource#">
					UPDATE _Settings
					   SET Value = <cfoutput>'#toggle_value#'</cfoutput>
					 WHERE Input_Name = 'FORGE_CDN'
				</cfquery>
				<cfscript>
					lock timeout="30" scope="Application" type="exclusive" throwontimeout="true" {
						application.forge_cdn = toggle_value;
					}
				</cfscript>
				<cfset notification_msg = "✔ Success - CDN has been " & (toggle_value is "" ? "disabled." : "enabled.")>

			<!--- toggle debug on --->
			<cfelseif form.action is "toggle debug on">
				<cfscript>
					factory  = createObject("java","coldfusion.server.ServiceFactory");
					debugger2 = factory.getDebuggingService();
					debugger2.setEnabled(1);
					notification_msg = "✔ Success - Debugging has been enabled.";
				</cfscript>

			<!--- toggle debug off --->
			<cfelseif form.action is "toggle debug off">
				<cfscript>
					factory  = createObject("java","coldfusion.server.ServiceFactory");
					debugger2 = factory.getDebuggingService();
					debugger2.setEnabled(0);
					notification_msg = "✔ Success - Debugging has been disabled.";
				</cfscript>

			<!--- toggle sql content --->
			<cfelseif form.action is "toggle sql content">
				<cfif form.sql_cookie_setting is "sqlDumpOn">
					<!--- for performance reasons do not dump more than 300 rows --->
					<cfif isNumeric(form.sql_cookie_setting) and form.sql_cookie_setting gt 0 and form.sql_cookie_setting lt 300>
						<cfcookie name="sqlDumpOn" value="#form.sql_cookie_setting#">
					<cfelse>
						<!--- default to dump top 25 rows --->
						<cfcookie name="sqlDumpOn" value=25>
					</cfif>
					<cfset notification_msg = "✔ Success - SQL content has been enabled.">
				<cfelseif form.sql_cookie_setting is "sqlDumpOff">
					<cfcookie name="sqlDumpOn" value=0>
					<cfset notification_msg = "✔ Success - SQL content has been disabled.">
				</cfif>
			</cfif>

		</cfif>

		<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>

		<cfparam name="form.external_ip" default="">
		<cfoutput><cfparam name="url.external_ip" default="#form.external_ip#"></cfoutput>
		<!--- detect external IP address if it does not exist --->
		<cfif url.external_ip is '' and 0>
			<script>
				try {
					$.getJSON("http://jsonip.com/?callback=?", function (data) { window.location.href = window.location.href + "?external_ip=" + data.ip; });
				}
				catch (e) {
					$.getJSON("http://jsonip.com/?callback=?", function (data) { window.location.href = window.location.href + "?external_ip=" });
				}
			</script>
		<cfelse>
			<cfscript>
				IP_addresses = listToArray( debugger.getIpList() );
				arraySort(IP_addresses, "text");
			</cfscript>

			<h2 class="shadow secondary">Manage Debugging Information</h2>
			
			<hr class="four">
			<cfif len(notification_msg)>
				<p class="notification"><cfoutput>#notification_msg#</cfoutput></p>
			</cfif>
			
			<form method="post">
				<cfoutput><input type="hidden" name="external_ip" value="#url.external_ip#"></cfoutput>
				<input type="hidden" name="action">
				<input type="hidden" name="sql_cookie_setting">

				<div style="margin:10px 1% 20px 1%; text-align:center;">
					<cfoutput>
						<cfset toggle_debug = (debugger.getDebugProperty('enableDebug') ? 'off' : 'on')>
						<button class="button" onclick="toggle_debug( '#toggle_debug#' );" type="button" style="margin-left:15px;">turn #toggle_debug# debug</button>
						<cfif structKeyExists(cookie, "sqlDumpOn") and val(cookie.sqlDumpOn) gt 0>
							<button class="button" onclick="sql_content('sqlDumpOFF')" type="button" style="margin-left:15px;">turn off SQL content</button>
						<cfelse>
							<button class="button" onclick="sql_content('sqlDumpON')" type="button" style="margin-left:15px;">turn on SQL content</button>
						</cfif>
						<button class="button" onclick="update_cdn();" type="button" style="margin-left:15px;">#(application.util.query.get_setting("FORGE_CDN") eq "" ? "enable" : "disable")# CDN</button>
					</cfoutput>
				</div>

				<hr class="two" style="margin:20px 0;">
				<div style="width:45%; margin-left:4%; float:left;">				
					<!--- list existing IP addresses --->
					<h3 class="zero">IP addresses for which debugging is enabled</h3>
					<ul>
						<cfloop from="1" to="#arrayLen(IP_addresses)#" index="i">
							<cfoutput><label><li><input type="checkbox" class="ip" name="ip" value="#IP_addresses[i]#">#IP_addresses[i]#</li></label></cfoutput>
						</cfloop>
					</ul>
					
					<cfif arrayLen(IP_addresses) eq 0>
						<p style="margin-left:10px">None</p>
					<cfelse>
						<br>
						<div>
							<button class="button" onclick="remove_selected_ip();" type="button">remove selected IP</button>
						</div>
					</cfif>
				</div>

				<div style="width:45%; margin-right:4%; float:right;">
					<!--- add new IP address --->
					<div>
						<cfparam name="form.new_ip" default="">
						<cfoutput><p class="zero"><b>New IP</b> &nbsp; <input type="text" name="new_ip" value="#form.new_ip#"></p></cfoutput>
					</div>
					<br>
					<div style="margin-top:8px;">
						<button class="button" onclick="add_new_ip();" type="button">add new IP</button>
						<!--- add your own external IP address --->
						<cfif len(url.external_ip) and arrayFind(ip_addresses, url.external_ip) eq 0>
							<button class="button" onclick="add_your_ip();" type="button">add your external IP</button>
						</cfif>
					</div>
					<!--- display external IP address --->
					<cfif len(url.external_ip)>
						<br>
						<cfoutput><p>Your external IP address is <span class="ip shadow">#url.external_ip#</span></p></cfoutput>
					</cfif>
				</div>

				<div style="clear:both;"></div>

				<hr class="two" style="margin:15px 0;">
				<!--- display server information --->
				<div style="margin:10px 5%; text-align:center;">
					<!--- <h3>Server</h3> --->
					<cfoutput>
                        <cfquery name="forge" datasource="#application.datasource#">
                            SELECT TOP 1
                                LTRIM(RTRIM(Patch_Number)) As Version
                            FROM Application_Installation
                            ORDER BY Release_Version DESC
                        </cfquery>
						<p>
							<label class="read">CF Server IP</label> <input class="readonly short" value="#server.ip#" type="text" disabled>
							<label class="read">Instance</label> <input class="readonly short" value="#server.instance_name#" type="text" disabled>
							<label class="read">CF Version</label> <input class="readonly" value="#server.coldfusion.productVersion#" type="text" disabled><br>
							<!--- <label class="read">Debug Template</label> <input class="readonly" value="#debugger.getDebugProperty( 'debugTemplate' )#" type="text" disabled> --->
						</p>
						<p>
							<label class="read">Forge Version</label> <input class="readonly short" value="#forge.version#" type="text" disabled>
							<label class="read">Root Folder</label> <input class="readonly long" value="#lcase(server.coldfusion.rootdir)#" type="text" disabled>
                        </p>
                        <cfset db_server = len(server.datasource.host) 
                                                ? server.datasource.host 
                                                : replaceNocase(server.datasource.url, 'jdbc:macromedia:sqlserver:', '')>
                        <cfset db_server = replace(db_server, "//", "")>
						<p>
							<label class="read">DB Name</label> <input class="readonly short" value="#(len(server.datasource.database) ? server.datasource.database : server.datasource.name)#" type="text" disabled>
							<label class="read">DB Server</label> <input class="readonly short" value="#db_server#" type="text" disabled>
                        </p>
					</cfoutput>
				</div>
				
				<hr class="two" style="margin:20px 0;">
				<div style="margin:10px 5%; text-align:center;">
					<cfdirectory action="list" type="file" directory="#server.log_folder#" name="qDirectory" sort="name ASC">
					<!--- <cfdump var="#qDirectory#"> --->
					<select name="log_file" style2="height:24px;margin:10px;">
						<option value="">Select a log file to view</option>

						<!--- display log files updated today --->
						<cfquery name="qqToday" dbtype="query">
							SELECT * 
							  FROM qDirectory 
							  WHERE DateLastModified >= '#dateFormat(now(), 'yyyy-m-d')#'
									ORDER BY Name
						</cfquery>
						<cfif qqToday.recordCount>
							<optgroup label="Updated Today">
								<cfoutput query="qqToday">
									<option value="#qqToday.Name#">#qqToday.Name#</option>
								</cfoutput>
							</optgroup>
						</cfif>

						<!--- display log files updated yesterday --->
						<cfquery name="qqYesterday" dbtype="query">
							SELECT * 
							FROM qDirectory 
							WHERE DateLastModified >= '#dateFormat(dateadd("d", -1, now()), 'yyyy-m-d')#'
									AND DateLastModified < '#dateFormat(now(), 'yyyy-m-d')#'
									ORDER BY Name
						</cfquery>
						<cfif qqYesterday.recordCount>
							<optgroup label="Updated Yesterday">
								<cfoutput query="qqYesterday">
									<option value="#qqYesterday.Name#">#qqYesterday.Name#</option>
								</cfoutput>
							</optgroup>
						</cfif>

						<optgroup label="Updated Earlier">
							<cfoutput query="qDirectory">
								<cfif dayDiff(qDirectory.DateLastModified, now()) gt 1>
									<option value="#qDirectory.Name#">#qDirectory.Name#</option>
								</cfif>						
							</cfoutput>
						</optgroup>
					</select>
					<button class="button" onclick="view_log()" type="button" style="margin-left:15px;">view log</button>
					Enter an event error number <input type="text" size="7" name="error_number"> <button class="button error">view error</button>
				</div>

				<!--- <hr class="two" style="margin:20px 0;">
				<div style="margin:10px 5%; text-align:center;">
				</div> --->
			</form>
		</cfif>
	
        <script>       
            window.popups = [];

            $("select[name=log_file]").change(function(){
                view_log();
            });

			function view_log() {
				let file_name = $("select[name=log_file]").val();
				if (file_name > '')
					window.popups.push(popupCenter( "view_log.cfm?file_name=" + file_name, file_name, "lg", "lg" ));
			}

			function remove_log() {
				let file_name = $("select[name=log_file]").val();
				if (file_name > '') {
					$("input[name=action]").val("remove log");
					$("form").submit();
				}
			}

			function remove_selected_ip() {
				if ($("input.ip:checked").length == 0) {
					alert("Please select at least one IP address to remove.")
					return false;
				}
				else {
					$("input[name=action]").val("remove ip");
					$("form").submit();
				}
			}

			function add_new_ip() {
				if ($("input[name=new_ip]").val() == '') {
					alert("Please enter a new IP address to add.")
					return false;
				}
				else {
					$("input[name=action]").val("add");
					$("form").submit();
				}
			}

			function add_your_ip() {
				$("input[name=new_ip]").val( <cfoutput>"#url.external_ip#"</cfoutput> );
				$("input[name=action]").val("add");
				$("form").submit();
			}

			function update_cdn() {
				$("input[name=action]").val("update cdn");
				$("form").submit();
			}

			function toggle_debug( debug_state ) {
				$("input[name=action]").val( "toggle debug " + debug_state );
				$("form").submit();
			}

			function sql_content( sql_cookie_setting ) {
				$("input[name=sql_cookie_setting]").val( sql_cookie_setting );
				$("input[name=action]").val("toggle sql content");
				$("form").submit();
			}
			
			// current external IP address is not enabled, focus on new IP input
			<cfif len(url.external_ip) and arrayFind(ip_addresses, url.external_ip) eq 0>
				$("input[name=new_ip]").focus();
			</cfif>

			$("button.error").click(function() {
				let error_number = $("input[name=error_number]").val();
				window.popups.push(popupCenter( "/common_documents/Data_Files/Created/error_files/error_" + $.trim(error_number) + ".htm", "", "md", "md" ));
				return false;
			});

			setTimeout(function() {
				$("p.notification").hide();
            }, 6000 * 0.75);
            
            $(window).unload( close_popups );
		</script>
    </body>
</html>
