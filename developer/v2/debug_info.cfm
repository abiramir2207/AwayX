<cfprocessingdirective pageencoding="utf-8">
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
        <link rel="stylesheet" type="text/css" href="<cfoutput>#request.forge_cdn#</cfoutput>/common_files/main_style.css">
        <style>
            body {
                background-color: white;
            }
			ul { font-size:1.25em;
				list-style-type: none;
    			margin: 0;
    			padding: 0;
			}
			input.ip {
				margin:0 10px;
			}
			li { width:170px; font-size:14px; padding:10px 0 0 10px; }
			/* li:hover { cursor:pointer; background:#D3CAE5; color:blue; -ms-filter:"progid:DXImageTransform.Microsoft.Alpha(Opacity=100)"; opacity:1;} */
			p { font-size:13px; }
			.ip { font-size:14px; font-weight:bold; color:green; letter-spacing:0.75px; }
			.btn-secondary { color: #fff; background-color: #CB384A; margin2:0 50px 0 0;}
			button { margin-right: 15px; }
			.zero { margin: 0; padding: 0; }
			input.readonly { margin: 0 10px 0 0; font-weight: bold; font-size:13px; }
			input.short { width: 120px; }
			input.long { width: 250px; }
			input.longest { width: 400px; }
			label.read { font-size: 11px; width: 70px; display: inline-block; margin-bottom: 15px; }
			h2.secondary { text-align: center; }
			p.notification { color:red; font-size:13px; font-weight:normal; margin-bottom:20px; letter-spacing:0.4px; text-align:center; }
			input[type="checkbox"] { vertical-align: middle; }
			li.ip { width: 225px; }
			select {
				border-radius: 4px;
				width: 200px;
			}
			option,optgroup { padding: 3px; }
			table.cfdump_struct {
				margin: 0 auto;
			}
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
            public function cf_admin() output="false" {
				var cap = ( () => {
										try {
											// attempt to pull ag-Grid license from Library mapping location
											var library_udf = new Library.Static_UDF();
											return library_udf.cfDebug();
										}
										catch ( any e ) {
											// Library mapping failed, possibly due to its mapping not yet built
											// use the classic method to get the credential
											return application.util.query.get_setting( "CF_Admin_Password", 0 );
										}
									} )();

                return { username: "admin",
                         password: decrypt( cap, application.util.query.get_setting("GenerateSecretKey_AES_128", 0), "AES", "base64" )
                };
            }
        </cfscript>

		<cfquery name="browsers" datasource="#application.datasource#">
			DECLARE @FROM_DATE DATE
			DECLARE @Chrome FLOAT
			DECLARE @IE FLOAT
			DECLARE @TOTAL FLOAT
			DECLARE @POPULARITY FLOAT

			SET @FROM_DATE = '2021/1/1'

			/* count number of Chrome browsers */
			SELECT  @Chrome = Count(Browser)
			FROM  Audit_User_Transactions
			WHERE  Trans_Type = 'LOGOFF'
					AND ( Browser LIKE '%Chrome%' )
					AND Trans_DateTime >= @FROM_DATE

			/* count number of IE browsers */
			SELECT  @IE = Count(Browser)
			FROM  Audit_User_Transactions
			WHERE  Trans_Type = 'LOGOFF'
					AND ( NOT Browser LIKE '%Chrome%' )
					AND Trans_DateTime >= @FROM_DATE

			SET @TOTAL = @Chrome + @IE
			SET @POPULARITY = Cast(@Chrome / @TOTAL AS Float)

			SELECT Format(@Chrome, '0,##') AS Chrome,
					FORMAT(@POPULARITY, '0%') AS Chrome_Popularity,
					Format(@IE, '0,##') AS IE
		</cfquery>

		<cfquery name="resolutions" datasource="#application.datasource#">
			<cfscript>
				screen_resolution = queryExecute( " SELECT 1 AS Value
													  FROM INFORMATION_SCHEMA.COLUMNS
													 WHERE TABLE_NAME = 'Audit_User_Transactions' AND COLUMN_NAME = 'Screen_Resolution'"
													 , {}, { datasource: application.datasource } );
			</cfscript>
			<cfif screen_resolution.recordCount eq 0>
				SELECT '' AS Screen_Resolution
						, 0 AS Count
						, Format( 0, 'N2' ) + '%' AS Popularity
					FROM  Audit_User_Transactions
					WHERE  1 = 0
			<cfelse>
				DECLARE @Resolution_Count Int

				SELECT @Resolution_Count = Count(*)
					FROM Audit_User_Transactions
					WHERE Screen_Resolution IS NOT NULL AND Screen_Resolution > ''

				SELECT Screen_Resolution
						, Count ( Screen_Resolution ) AS Count
						, Format( Cast( Count( Screen_Resolution ) AS Float ) / Cast(@Resolution_Count AS Float) * 100.00, 'N2' ) + '%' AS Popularity
					FROM  Audit_User_Transactions
					WHERE  Screen_Resolution IS NOT NULL AND Screen_Resolution > ''
							GROUP BY Screen_Resolution
							ORDER BY Count(Screen_Resolution) DESC
			</cfif>
		</cfquery>



		<cfscript>
			adminObj = createObject("component", "cfide.adminapi.administrator");
			cf_admin = cf_admin();
			if ( adminObj.login( cf_admin.password, cf_admin.username ) ) {
				debugger             = createObject("component", "cfide.adminapi.debugging");
				runtime              = createObject("component", "CFIDE.adminapi.runtime");
				datasource           = createObject("component", "cfide.adminapi.datasource");
				server.instance_name = runtime.getInstanceName();
				server.log_folder    = debugger.getLogProperty("logdirectory");
				server.ip            = createObject("java", "java.net.InetAddress").getLocalHost().getHostAddress();
				server.datasource    = datasource.getDatasources( application.datasource );
			}
			else {
				server.instance_name = "";
				server.log_folder    = "";
				server.ip            = "";
				server.datasource    = { host:"", url="" };
			}
			notification_msg     = '';


			mf         = createObject("java", "java.lang.management.ManagementFactory")
			memBean    = mf.getMemoryMXBean()
			heapMem    = memBean.getHeapMemoryUsage()
			nonHeapMem = memBean.getNonHeapMemoryUsage()

			jv_runtime  = createObject("java", "java.lang.Runtime").getRuntime()
			// runtime     = createObject("java","java.lang.Runtime").getRuntime()
			freeMemory  = jv_runtime.freeMemory() / 1024 / 1024
			totalMemory = jv_runtime.totalMemory() / 1024 / 1024
			maxMemory   = jv_runtime.maxMemory() / 1024 / 1024

			percentFreeAllocated = Round((freeMemory / totalMemory) * 100)
			percentAllocated     = Round((totalMemory / maxMemory ) * 100)

		</cfscript>

		<cfif cgi.request_method is "post">
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
				<cfset toggle_value = (application.util.query.get_setting("FORGE_CDN") eq "" ? "<cfoutput>#request.forge_cdn#</cfoutput>" : "")>
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
			<cfscript>
				if ( isDefined( "debugger" ) ) {
					IP_addresses = listToArray( debugger.getIpList() );
					arraySort(IP_addresses, "text");
				}
				else {
					IP_addresses = [];
				}
			</cfscript>

			<!--- <h2 class="shadow secondary">Manage Debugging Information</h2> --->
			<cfif len(notification_msg)>
				<p class="notification"><cfoutput>#notification_msg#</cfoutput></p>
			</cfif>

			<form method="post">
				<cfoutput><input type="hidden" name="external_ip" value="#url.external_ip#"></cfoutput>
				<input type="hidden" name="action">
				<input type="hidden" name="sql_cookie_setting">

				<div style="margin:10px 1% 20px 1%; text-align:center;">
					<cfoutput>
						<cfif ( isDefined( "debugger" ) )>
							<cfset toggle_debug = (debugger.getDebugProperty('enableDebug') ? 'off' : 'on')>
							<button class="button" onclick="toggle_debug( '#toggle_debug#' );" type="button" style="margin-left:15px;">turn #toggle_debug# debug</button>
							<cfscript>
								if ( debugger.getDebugProperty( "debugTemplate" ) neq "forge.cfm" ) {
									forge_cfm = server.coldfusion.rootdir & "\wwwroot\WEB-INF\debug\forge.cfm";
									// avoid file create permission issue
									try {
										if ( ! fileExists( forge_cfm ) ) {
											fileWrite( forge_cfm, '<cfinclude template="/library/forge.cfm">' );
										}
									}
									catch ( any e ) {
									}
									if ( fileExists( forge_cfm ) ) {
										// switch to Blacksmith custom debugging format on a stand-alone popup
										debugger.setDebugProperty( "debugTemplate", "forge.cfm" );
									}
								}
							</cfscript>
						</cfif>
						<cfif structKeyExists(cookie, "sqlDumpOn") and val(cookie.sqlDumpOn) gt 0>
							<button class="button" onclick="sql_content('sqlDumpOFF')" type="button" style="margin-left:15px;">turn off SQL content</button>
						<cfelse>
							<button class="button" onclick="sql_content('sqlDumpON')" type="button" style="margin-left:15px;">turn on SQL content</button>
						</cfif>
						<!--- <button class="button result" type="button" style="margin-left:15px;">cfquery results builder</button> --->
						<!--- <button class="button" onclick="update_cdn();" type="button" style="margin-left:15px;">#(application.util.query.get_setting("FORGE_CDN") eq "" ? "enable" : "disable")# CDN</button> --->
					</cfoutput>
				</div>

				<main style="display:flex; justify-content:center;">
				<div style="width:27%;">
					<cfif ( isDefined( "debugger" ) )>
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
					</cfif>
				</div>

				<div style="width:27%;">
					<cfif ( isDefined( "debugger" ) )>
						<!--- add new IP address --->
						<div>
							<cfparam name="form.new_ip" default="">
							<cfoutput><p class="zero">Your IP Address &nbsp; <b style="letter-spacing:0.5px;font-size:14px;">#cgi.remote_addr#</b></p></cfoutput>
						</div>
						<br>
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
					</cfif>
				</div>

				<!---
				<div style="width:27%;">
					<b style="font-size:1.17em">Developer IP Addresses</b>
					<ul style="margin-top:10px;">
						<cfscript>
							qIPs = queryExecute( "
												SELECT Value
													FROM _Settings
													WHERE Input_Name = 'Developer_IPs'
												",
												{}, { datasource: application.datasource } );
							for ( ip in listToArray( qIPs.Value ) ) {
								writeOutput( "#ip#<br>" );
							}
						</cfscript>
					</ul>
				</div>
				--->
				</main>

				<hr class="two" style="margin:20px 0 10px 0;">

				<main style="display:flex; justify-content:center;">
					<cfoutput>
					<!--- display server information --->
					<div style="margin:10px;width:255px">
						<h3>ColdFusion</h3>
						<label class="read">IP</label> <input class="readonly short" value="#server.ip#" type="text" disabled> <br>
						<label class="read">Instance</label> <input class="readonly short" value="#server.instance_name#" type="text" disabled> <br>
						<label class="read">Version</label> <input class="readonly short" value="#server.coldfusion.productVersion#" type="text" disabled><br>
						<label class="read">Debug</label> <input class="readonly short" value="#debugger.getDebugProperty( 'debugTemplate' )#" type="text" disabled> <br>
						Web Site Root <br><br>
						<input class="readonly long" value="#lcase(replace(expandPath('/Application.cfc'),'Application.cfc', ''))#" type="text" disabled> <br>
						<br><br>
						<label class="read">CF Root</label> <input class="readonly long" value="#lcase(server.coldfusion.rootdir)#" type="text" disabled>
					</div>
					<div style="margin:5px;">
						<h3>SQL</h3>
						<cfscript>
							db_server = len(server.datasource.host)
												? server.datasource.host
												: replaceNocase(server.datasource.url, 'jdbc:macromedia:sqlserver:', '');

							db_server = replace(db_server, "//", "");
							db_server = replaceNoCase(db_server, ";AlwaysReportTriggerResults=true;jdbcbehavior=0", "");
							db_server = replaceNoCase(db_server, ":1433", "");
						</cfscript>

						<label class="read">Data Source</label> <input class="readonly short" value="#(len(server.datasource.database) ? server.datasource.database : server.datasource.name)#" type="text" disabled><br>
						<label class="read">Database IP</label> <input class="readonly long" value="#db_server#" type="text" disabled>
					</div>
					</cfoutput>

					<div style="margin:5px;">
						<h3>CF Logs</h3>
						<cfdirectory action="list" type="file" directory="#server.log_folder#" name="qDirectory" sort="name ASC">
						<select name="log_file" style="margin-bottom:10px;width:150px;" size="18">
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
						<!--- <br> <button class="button" onclick="view_log()" type="button" style="margin-left:15px;">view log</button> --->
					</div>

					<div style="margin:5px;">
						<h3>CF Debug</h3>
						<cfdirectory action="list" type="file" directory="#expandPath( '/common_documents/temp_files/ngt/' )#" name="qDirectory" sort="datelastmodified DESC">

						<select name="debug_file" style="margin:0 10px 10px 10px;width:280px;" size="18">
							<!--- display log files updated today --->
							<cfquery name="qqToday" dbtype="query">
								SELECT *
								FROM qDirectory
								WHERE DateLastModified >= '#dateFormat(now(), 'yyyy-m-d')#'
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
							</cfquery>
							<cfif qqYesterday.recordCount>
								<optgroup label="Updated Yesterday">
									<cfoutput query="qqYesterday">
										<option value="#qqYesterday.Name#">#qqYesterday.Name#</option>
									</cfoutput>
								</optgroup>
							</cfif>

							<cfif qDirectory.recordCount>
								<optgroup label="Updated Earlier">
									<cfoutput query="qDirectory">
										<cfif dayDiff(qDirectory.DateLastModified, now()) gt 1>
											<option value="#qDirectory.Name#">#qDirectory.Name#</option>
										</cfif>
									</cfoutput>
								</optgroup>
							</cfif>
						</select>
						<!--- <br> <button class="button" onclick="view_debug()" type="button" style="margin-left:15px;">view debug</button> --->
					</div>

					<!--- <div style="margin:5px;width:215px">
						<h3>Chrome, MS Edge</h3>
						<p>
							<cfoutput>
								Used <b>#browsers.Chrome#</b> times since Jan 1, 2021<br><br>
								<b>#browsers.Chrome_Popularity#</b> popularity
							</cfoutput>
						</p>

						<cfif resolutions.recordCount eq 0>
							<h3 style="margin-top:30px;">Popular Screen Resolutions (coming soon)</h3>
						<cfelse>
							<h3 style="margin-top:30px;">Popular Screen Resolutions</h3>
							<ul>
								<cfoutput query="resolutions" maxrows="3">
									<li>#resolutions.popularity# with #resolutions.screen_resolution#</li>
								</cfoutput>
							</ul>
						</cfif>
					</div> --->

				</main>
				<!--- <hr class="two" style="margin:20px 0 10px 0;"> --->

				<div style="display:flex;">
					<!--- <div style="width:35%;padding-left:95px;font-size:12px;">
						<cfoutput>
								<h3>Heap Memory</h3>
								#numberFormat( round( heapMem.getUsed() / 1024 / 1024 ), ",") # MB In Use<br>
								(#numberFormat( round( heapMem.getCommitted() / 1024 / 1024 ), ",")# MB Committed, #numberFormat( round( heapMem.getMax() / 1024 / 1024 ), "," )# Max Allowed Size)<br>

								<h3>Non Heap Memory (PermGen & Code Cache)</h3>
								#numberFormat( round( nonHeapMem.getUsed() / 1024 / 1024 ), ",")# MB In Use
								(#numberFormat( round( nonHeapMem.getCommitted() / 1024 / 1024 ), ",")# MB Committed, #numberFormat( round( nonHeapMem.getMax() / 1024 / 1024 ), "," )# Max Allowed Size)

								<h3>Summary</h3>
								Free Allocated Memory &nbsp; #numberFormat( round( freeMemory ), "," )# MB<br>
								Total Memory Allocated &nbsp; #numberFormat( round(totalMemory), "," )# MB<br><br>
								<!--- Max Memory Available to JVM &nbsp; <b>#numberFormat( round(maxMemory), "," )# MB</b><br><br> --->

								% of Free Allocated Memory &nbsp; <b>#percentFreeAllocated#%</b><br>
								% of Available Memory Allocated &nbsp; #percentAllocated#%<br>
						</cfoutput>
					</div> --->
					<div style="width:65%;margin:0 auto;">
						<cfscript>
							applicationInstance = createObject( "component", "Application" );
							writeDump( var=( structSortLowerCase( applicationInstance ) ), showUDFs=false, label="Application Properties" );
						</cfscript>
					</div>
				</div>

				<!--- <hr class="two" style="margin:20px 0 10px 0;"> --->

					<style>
						table.cfdump_query td {
							font-family: "MonoLisa", "Source Code Pro Semibold", Inconsolata, Arial, sans-serif !important;
							font-size: 12px;
						}
						table.cfdump_struct, table.cfdump_query {
							border-radius: 6px !important;
						}
						table.cfdump_struct td, table.cfdump_struct th {
							padding: 5px !important;
						}
					</style>
			</form>

			<!--- <cfparam name="form.action" default=""> <cfif form.action is "toggle sql content"> <cfdump var="#cookie#"> </cfif> --->

        <script>
            window.popups = [];

            $("select[name=log_file]").change(function(){
                view_log();
            });

			function view_log() {
				let file_name = $("select[name=log_file]").val();
				if (file_name > '')
					window.open( "view_log.cfm?file_name=" + file_name, file_name );
			}

            $("select[name=debug_file]").change(function(){
                view_debug();
            });

			function view_debug() {
				let file_name = $("select[name=debug_file]").val();
				if (file_name > '')
					window.open( "/common_documents/temp_files/ngt/" + file_name, file_name );
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

			setTimeout(function() {
									$("p.notification").hide();
            						}, 6000 * 0.75);

            $(window).unload( close_popups );
		</script>
    </body>

	<cfscript>
        // Below function sorts deep level structs & convert keys to lowercase
        function structSortLowerCase( given_struct, need_sorted_keys = 1 ) {
            if ( isNull( given_struct ) ) {
                return javacast( "null", "" );
            }

            if ( isStruct( given_struct ) ) {
                // sort all keys in the given struct
                if ( need_sorted_keys ) {
                    given_struct = structToSorted( given_struct, "text", "asc" );
                }

                // lowecase the keys
                structEach( given_struct, function( key, value ) {
                                                                    given_struct[ "#lcase(key)#" ] = isNull( value )
                                                                                                        ? javacast( "null", "" )
                                                                                                        : value;
                                                                    } );

                // make a recursive call on all values
                return structMap(given_struct, function( key, value ) {
                                                                        return structSortLowerCase( isNull( value )
                                                                                                        ? javacast( "null", "" )
                                                                                                        : value );
                                                                        } );
            }

            if ( isArray( given_struct ) ) {
                // make a recursive call on all values
                return arrayMap( given_struct, function ( value ) {
                                                                    return structSortLowerCase( isNull( value )
                                                                                                    ? javacast( "null", "" )
                                                                                                    : value );
                                                                    } );
            }

            return given_struct;
        }
	</cfscript>

</html>
