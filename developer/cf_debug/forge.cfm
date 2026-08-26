<!---
**
* CF5 Debugging Output
*
* Copyright (c) 2001 Macromedia.  All Rights Reserved.
* DO NOT REDISTRIBUTE THIS SOFTWARE IN ANY WAY WITHOUT THE EXPRESSED
* WRITTEN PERMISSION OF MACROMEDIA.
--->

<cfif IsDebugMode()>
<cfsilent>
<cfif cgi.query_string contains "sqlDumpOn">
	<!--- for performance reasons do not dump more than 300 rows --->
	<cfif isNumeric(url.sqlDumpOn) and url.sqlDumpOn gt 0 and url.sqlDumpOn lt 300>
		<cfcookie name="sqlDumpOn" value="#url.sqlDumpOn#">
	<cfelse>	
		<!--- default to dump top 25 rows --->
		<cfcookie name="sqlDumpOn" value=25>
	</cfif>
<cfelseif cgi.query_string contains "sqlDumpOff">
	<cfcookie name="sqlDumpOn" value=0>
</cfif>

<cfset startTime = getTickCount()>
<cfscript>
	formEncoding = getEncoding("FORM");
	urlEncoding = getEncoding("URL");

	setEncoding("FORM", formEncoding);
	setEncoding("URL", urlEncoding);
</cfscript>
</cfsilent>

<!--- Localized strings --->
<cfset undefined = "">

	<!--- Use the debugging service to check options --->
	<cftry>
		<cfobject action="CREATE" type="JAVA" class="coldfusion.server.ServiceFactory" name="factory">
		<cfset cfdebugger = factory.getDebuggingService()>
		<cfcatch type="Any"></cfcatch>
	</cftry>

	<!--- Load the debugging service's event table --->
	<cfset qEvents = cfdebugger.getDebugger().getData()>

<!--- <cfdump var="#qEvents#" abort="true"> --->

	<!--- Produce the filtered event queries --->
	<!--- EVENT: Templates --->
	<cftry>
		<cfquery dbType="query" name="cfdebug_templates" debug="false">
			SELECT template, parent, Sum(endTime - StartTime) AS et
			FROM qEvents
			WHERE type = 'Template'
			GROUP BY template, parent
			ORDER BY et DESC
		</cfquery>
		<cfscript>
			if (cfdebug_templates.recordCount eq 1 and not len(trim(cfdebug_templates.et))) {
				querySetCell(
					cfdebug_templates,
					"et",
					"0",
					1
				);
			}
		</cfscript>
		<cfcatch type="Any">
			<cfscript>
				cfdebug_templates = queryNew('template, parent, et');
			</cfscript>
		</cfcatch>
	</cftry>


	<!--- EVENT: SQL Queries --->
	<cftry>
		<cfquery dbType="query" name="cfdebug_queries" debug="false">
			SELECT *, (endTime - startTime) AS executionTime
			FROM qEvents
			WHERE type = 'SqlQuery'
		</cfquery>
		<cfscript>
			if (cfdebug_queries.recordCount eq 1 and not len(trim(cfdebug_queries.executionTime))) {
				querySetCell(
					cfdebug_queries,
					"executionTime",
					"0",
					1
				);
			}
		</cfscript>
		<cfcatch type="Any">
			<cfscript>
				cfdebug_queries = queryNew(
					'ATTRIBUTES, BODY, CACHEDQUERY, CATEGORY, DATASOURCE, ENDTIME, EXECUTIONTIME, LINE, MESSAGE, NAME, PARENT, PRIORITY, RESULT, ROWCOUNT, STACKTRACE, STARTTIME, TEMPLATE, TIMESTAMP, TYPE, URL, et'
				);
			</cfscript>
		</cfcatch>
	</cftry>


	<!--- EVENT: Object Queries --->
	<cftry>
		<cfquery dbType="query" name="cfdebug_cfoql" debug="false">
			SELECT *, (endTime - startTime) AS executionTime
			FROM qEvents
			WHERE type = 'ObjectQuery'
		</cfquery>
		<cfscript>
			if (cfdebug_cfoql.recordCount eq 1 and not len(trim(cfdebug_cfoql.executionTime))) {
				querySetCell(
					cfdebug_cfoql,
					"executionTime",
					"0",
					1
				);
			}
		</cfscript>
		<cfcatch type="Any">
			<cfscript>
				cfdebug_cfoql = queryNew(
					'ATTRIBUTES, BODY, CACHEDQUERY, CATEGORY, DATASOURCE, ENDTIME, EXECUTIONTIME, LINE, MESSAGE, NAME, PARENT, PRIORITY, RESULT, ROWCOUNT, STACKTRACE, STARTTIME, TEMPLATE, TIMESTAMP, TYPE, URL'
				);
			</cfscript>
		</cfcatch>
	</cftry>

	<!--- EVENT: Stored Procedures --->
	<cftry>
		<cfquery dbType="query" name="cfdebug_storedproc" debug="false">
			SELECT *, (endTime - startTime) AS executionTime
			FROM qEvents
			WHERE type = 'StoredProcedure'
		</cfquery>
		<cfscript>
			if (cfdebug_storedproc.recordCount eq 1 and not len(trim(cfdebug_storedproc.executionTime))) {
				querySetCell(
					cfdebug_storedproc,
					"executionTime",
					"0",
					1
				);
			}
		</cfscript>
		<cfcatch type="Any">
			<cfscript>
				cfdebug_storedproc = queryNew(
					'ATTRIBUTES, BODY, CACHEDQUERY, CATEGORY, DATASOURCE, ENDTIME, EXECUTIONTIME, LINE, MESSAGE, NAME, PARENT, PRIORITY, RESULT, ROWCOUNT, STACKTRACE, STARTTIME, TEMPLATE, TIMESTAMP, TYPE, URL'
				);
			</cfscript>
		</cfcatch>
	</cftry>

	<!--- EVENT: Trace Points --->
	<cftry>
		<cfquery dbType="query" name="cfdebug_trace" debug="false">
			SELECT *
			FROM qEvents
			WHERE type = 'Trace'
		</cfquery>
		<cfcatch type="Any">
			<cfscript>
				cfdebug_trace = queryNew(
					'ATTRIBUTES, BODY, CACHEDQUERY, CATEGORY, DATASOURCE, ENDTIME, EXECUTIONTIME, LINE, MESSAGE, NAME, PARENT, PRIORITY, RESULT, ROWCOUNT, STACKTRACE, STARTTIME, TEMPLATE, TIMESTAMP, TYPE, URL'
				);
			</cfscript>
		</cfcatch>
	</cftry>

	<!--- EVENT: CFTimer Points --->
	<cftry>
		<cfquery dbType="query" name="cfdebug_timer" debug="false">
			SELECT *
			FROM qEvents
			WHERE type = 'CFTimer'
		</cfquery>
		<cfcatch type="Any">
			<cfscript>
				cfdebug_timer = queryNew(
					'ATTRIBUTES, BODY, CACHEDQUERY, CATEGORY, DATASOURCE, ENDTIME, EXECUTIONTIME, LINE, MESSAGE, NAME, PARENT, PRIORITY, RESULT, ROWCOUNT, STACKTRACE, STARTTIME, TEMPLATE, TIMESTAMP, TYPE, URL'
				);
			</cfscript>
		</cfcatch>
	</cftry>

	<!--- EVENT: Locking Warning Points --->
	<cftry>
		<cfquery dbType="query" name="cfdebug_lock" debug="false">
			SELECT *
			FROM qEvents
			WHERE type = 'LockWarning'
		</cfquery>
		<cfcatch type="Any">
			<cfscript>
				cfdebug_lock = queryNew(
					'ATTRIBUTES, BODY, CACHEDQUERY, CATEGORY, DATASOURCE, ENDTIME, EXECUTIONTIME, LINE, MESSAGE, NAME, PARENT, PRIORITY, RESULT, ROWCOUNT, STACKTRACE, STARTTIME, TEMPLATE, TIMESTAMP, TYPE, URL'
				);
			</cfscript>
		</cfcatch>
	</cftry>

	<!--- EVENT: Exceptions --->
	<cftry>
		<cfquery dbType="query" name="cfdebug_ex" debug="false">
			SELECT *
			FROM qEvents
			WHERE type = 'Exception'
		</cfquery>
		<cfcatch type="Any">
			<cfscript>
				cfdebug_ex = queryNew(
					'ATTRIBUTES, BODY, CACHEDQUERY, CATEGORY, DATASOURCE, ENDTIME, EXECUTIONTIME, LINE, MESSAGE, NAME, PARENT, PRIORITY, RESULT, ROWCOUNT, STACKTRACE, STARTTIME, TEMPLATE, TIMESTAMP, TYPE, URL'
				);
			</cfscript>
		</cfcatch>
	</cftry>


	<!--- Establish Section Display Flags --->
	<cfparam name="displayDebug" default="false" type="boolean"><!--- ::	display the debug time 	:: --->
	<cfparam name="bGeneral" default="false" type="boolean">
	<cfparam name="bFoundExecution" default="false" type="boolean">
	<cfparam name="bFoundTemplates" default="false" type="boolean">
	<cfparam name="bFoundExceptions" default="false" type="boolean">
	<cfparam name="bFoundSQLQueries" default="false" type="boolean">
	<cfparam name="bFoundObjectQueries" default="false" type="boolean">
	<cfparam name="bFoundStoredProc" default="false" type="boolean">
	<cfparam name="bFoundTrace" default="false" type="boolean">
	<cfparam name="bFoundTimer" default="false" type="boolean">
	<cfparam name="bFoundLocking" default="false" type="boolean">
	<cfparam name="bFoundScopeVars" default="false" type="boolean">

	<cftry>
		<cfscript>
	        // no longer doing template query at the top since we have tree and summary mode
			bFoundTemplates = cfdebugger.check("Template");

			if (bFoundTemplates) {
				displayDebug = true;
			}

			if (isDefined("cfdebugger.settings.general") and cfdebugger.settings.general) {
				bGeneral = true; displayDebug = true;
			}

			if (IsDefined("cfdebug_ex") AND cfdebug_ex.recordCount GT 0) {
				bFoundExceptions = true; displayDebug = true;
			} else {
				bFoundExceptions = false;
			}

			if (IsDefined("cfdebug_queries") AND cfdebug_queries.RecordCount GT 0) {
				bFoundSQLQueries = true; displayDebug = true;
			} else {
				bFoundSQLQueries = false;
			}

			if (IsDefined("cfdebug_cfoql") AND cfdebug_cfoql.RecordCount GT 0) {
				bFoundObjectQueries = true; displayDebug = true;
			} else {
				bFoundObjectQueries = false;
			}

			if (IsDefined("cfdebug_storedproc") AND cfdebug_storedproc.RecordCount GT 0) {
				bFoundStoredProc = true; displayDebug = true;
			} else {
				bFoundStoredProc = false;
			}

			if (IsDefined("cfdebug_trace") AND cfdebug_trace.recordCount GT 0) {
				bFoundTrace = true; displayDebug = true;
			} else {
				bFoundTrace = false;
			}

			if (IsDefined("cfdebug_timer") AND cfdebug_timer.recordCount GT 0) {
				bFoundTimer = true; displayDebug = true;
			} else {
				bFoundTimer = false;
			}

			if (IsDefined("cfdebug_lock") AND cfdebug_lock.recordCount GT 0) {
				bFoundLocking = true; displayDebug = true;
			} else {
				bFoundLocking = false;
			}

			if (IsDefined("cfdebugger") AND cfdebugger.check("Variables")) {
				bFoundScopeVars = true; displayDebug = true;
			} else {
				bFoundScopeVars = false;
			}
		</cfscript>
		<cfcatch type="Any"></cfcatch>
	</cftry>



<cfsetting enablecfoutputonly="Yes">
<cfsavecontent variable="debug_content">
<cfif displayDebug>
<cfoutput>
<!--- </td></td></td></th></th></th></tr></tr></tr></table></table></table></a></abbrev></acronym></address></applet></au></b></banner></big></blink></blockquote></bq></caption></center></cite></code></comment></del></dfn></dir></div></div></dl></em></fig></fn></font></form></frame></frameset></h1></h2></h3></h4></h5></h6></head></i></ins></kbd></listing></map></marquee></menu></multicol></nobr></noframes></noscript></note></ol></p></param></person></plaintext></pre></q></s></samp></script></select></small></strike></strong></sub></sup></table></td></textarea></th></title></tr></tt></u></ul></var></wbr></xmp> --->
<style type="text/css">
.cfdebug
{
	color:##333;
	background-color:white;
	font-family: "Source Code Pro Semibold", Inconsolata, Arial, sans-serif;
	font-size:small
}

.cfdebuglge
{
	color:##333;
	background-color:white;
	font-family: "Source Code Pro Semibold", Inconsolata, Arial, sans-serif;
	font-size: 15px;
	text-shadow: 4px 4px 4px ##aaa;
	letter-spacing: 0.25px;
	text-transform: uppercase;
}

a.cfdebuglink {color:blue; background-color:white }
hr.two {
    border: 0;
    height: 1px;
    margin: 10px 0;
    background-image: linear-gradient(to right, rgba(0, 0, 0, 0), rgba(0, 0, 0, 0.75), rgba(0, 0, 0, 0));
}
hr.four {
    height: 12px;
    border: 0;
    box-shadow: inset 0 12px 12px -12px rgba(0, 0, 0, 0.5);
}
hr.six {
    border: 0;
    height: 0px;
    border-top: 1px solid rgba(0, 0, 0, 0.1);
    border-bottom: 1px solid rgba(255, 255, 255, 0.3);
}
hr.eight {
    padding: 0;
    border: none;
    border-top: medium double ##333;
    color: ##333;
    text-align: center;
    width: 800px !important;
}
hr.eight:after { 
	content: "§"; 
	display: inline-block; 
	position: relative; 
	top: -0.7em; 
	font-size: 1.5em; 
	padding: 0 0.25em; 
	background: white; 
}
i {
	font-style: normal;
}
i.red {
	color: red;
	font-weight: bold;
}
div##sql_queries {
	text-align: left;
}
code.param {
	margin-left: 25px;
}
code, pre {
	font-size: 13px;
	font-family: "Source Code Pro Semibold", Inconsolata, Arial, sans-serif;
	width: 1200px;
}
code.red {
	color: red;
	font-size: 14px;
	font-weight: bold;	
	text-decoration: normal;
}
code.red:before {
	content: " [ ATTENTION ] ";
}
table.cfdump_query td {
	font-family: "Source Code Pro Semibold", Inconsolata, Arial, sans-serif !important;	
	font-size: 12px;
}
table.cfdump_struct, table.cfdump_query {
	border-radius: 6px !important;	
	margin-left: 25px;
}
table.cfdump_struct td, table.cfdump_struct th {
	padding: 5px !important;
}

pre code {
	letter-spacing: 0.5px;
	line-height: 1.35;
	border-radius: 8px;
	margin-left: 25px;
}
.hljs-keyword,
.hljs-selector-tag {
  font-weight: bold;
  text-transform: uppercase;
}
b.varhdr {
	font-size: 14px;
	letter-spacing: 0.75px;
	text-decoration: underline;
}
a.grp {
	color: blue;
	cursor: pointer;
	text-decoration: none;
}
##scope_vars, ##sql_queries, ##debug_info, ##exe_time {
	display: none;
}

p.cfdebug {
	padding: 7px 0;
	margin: 5px 0;
	text-align: left;
}
pre {
	padding: 5px 0px;
	margin: 5px 0;
	text-align: left;
}
b.query {
	color: black;
	font-weight: bold;
}
td.struct, td.query {
	text-transform: lowercase;
}
th.query, th.struct {
	font-size: 10px;
	font-weight: bold;
	letter-spacing: 0.65px;
}
##return-to-top {
    position: fixed;
    bottom: 20px;
    right: 20px;
    background: rgb(0, 0, 0);
    background: rgba(0, 0, 0, 0.7);
    width: 50px;
    height: 50px;
    display: block;
    text-decoration: none;
    -webkit-border-radius: 35px;
    -moz-border-radius: 35px;
    border-radius: 35px;
    display: none;
    -webkit-transition: all 0.3s linear;
    -moz-transition: all 0.3s ease;
    -ms-transition: all 0.3s ease;
    -o-transition: all 0.3s ease;
    transition: all 0.3s ease;
}
##return-to-top i {
    color: ##fff;
    margin: 0;
    position: relative;
    left: 16px;
    top: 13px;
    font-size: 19px;
    -webkit-transition: all 0.3s ease;
    -moz-transition: all 0.3s ease;
    -ms-transition: all 0.3s ease;
    -o-transition: all 0.3s ease;
    transition: all 0.3s ease;
}
##return-to-top:hover {
    background: rgba(0, 0, 0, 0.9);
}
##return-to-top:hover i {
    color: ##fff;
    top: 5px;
}
td.cfdebug {
	text-align: left;
}
</style>
<!---  include CF debug styles with type attribute to differentiate with CF injected styles for each cfdump --->
<style type="text/css"> table.cfdump_wddx, table.cfdump_xml, table.cfdump_struct, table.cfdump_varundefined, table.cfdump_array, table.cfdump_query, table.cfdump_cfc, table.cfdump_object, table.cfdump_binary, table.cfdump_udf, table.cfdump_udfbody, table.cfdump_udfarguments { font-size: xx-small; font-family: verdana, arial, helvetica, sans-serif; cell-spacing: 2px; } table.cfdump_wddx th, table.cfdump_xml th, table.cfdump_struct th, table.cfdump_varundefined th, table.cfdump_array th, table.cfdump_query th, table.cfdump_cfc th, table.cfdump_object th, table.cfdump_binary th, table.cfdump_udf th, table.cfdump_udfbody th, table.cfdump_udfarguments th { text-align: left; color: white; padding: 5px; } table.cfdump_wddx td, table.cfdump_xml td, table.cfdump_struct td, table.cfdump_varundefined td, table.cfdump_array td, table.cfdump_query td, table.cfdump_cfc td, table.cfdump_object td, table.cfdump_binary td, table.cfdump_udf td, table.cfdump_udfbody td, table.cfdump_udfarguments td { padding: 3px; background-color: ##ffffff; vertical-align : top; } table.cfdump_wddx { background-color: ##000000; } table.cfdump_wddx th.wddx { background-color: ##444444; } table.cfdump_xml { background-color: ##888888; } table.cfdump_xml th.xml { background-color: ##aaaaaa; } table.cfdump_xml td.xml { background-color: ##dddddd; } table.cfdump_struct { background-color: ##0000cc ; } table.cfdump_struct th.struct { background-color: ##4444cc ; } table.cfdump_struct td.struct { background-color: ##ccddff; } table.cfdump_varundefined { background-color: ##CC3300 ; } table.cfdump_varundefined th.varundefined { background-color: ##CC3300 ; } table.cfdump_varundefined td.varundefined { background-color: ##ccddff; } table.cfdump_array { background-color: ##006600 ; } table.cfdump_array th.array { background-color: ##009900 ; } table.cfdump_array td.array { background-color: ##ccffcc ; } table.cfdump_query { background-color: ##884488 ; } table.cfdump_query th.query { background-color: ##aa66aa ; } table.cfdump_query td.query { background-color: ##ffddff ; } table.cfdump_cfc { background-color: ##ff0000; } table.cfdump_cfc th.cfc{ background-color: ##ff4444; } table.cfdump_cfc td.cfc { background-color: ##ffcccc; } table.cfdump_object { background-color : ##ff0000; } table.cfdump_object th.object{ background-color: ##ff4444; } table.cfdump_binary { background-color : ##eebb00; } table.cfdump_binary th.binary { background-color: ##ffcc44; } table.cfdump_binary td { font-size: x-small; } table.cfdump_udf { background-color: ##aa4400; } table.cfdump_udf th.udf { background-color: ##cc6600; } table.cfdump_udfarguments { background-color: ##dddddd; cell-spacing: 3; } table.cfdump_udfarguments th { background-color: ##eeeeee; color: ##000000; } </style>			        

<table class="cfdebug" bgcolor="white" style="width:100%">
<tr>
	<td>
</cfoutput>
</cfif>



<!--- <cfdump var="#cgi#"> --->

<!----------------------->
<!--- Scope Variables --->
<!------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfif bFoundScopeVars>
	<cfoutput>
	<hr class="two"/>
	<p class="cfdebug">
		<b class="cfdebuglge"><a name="cfdebug_scopevars" class="grp" div="scope_vars">Scope Variables <i>&##9658;</i></a></b>
	</p>
	<div id="scope_vars">
	<cftry>
		<cfif IsDefined("FORM") AND IsStruct(FORM) AND StructCount(FORM) GT 0 AND cfdebugger.check("FormVar")>
			<pre><b class="varhdr">Form Fields</b><!--- #sortedScope(form)# ---></pre>
			<cfdump var="#form#" top="3" expand="true" keys="5000" showUDfs="false" label="Form">
		</cfif>
	<cfcatch type="Any"></cfcatch>
	</cftry>

	<cftry>
		<cfif IsDefined("URL") AND IsStruct(URL) AND StructCount(URL) GT 0 AND cfdebugger.check("URLVar")>
			<pre><b class="varhdr">URL Parameters</b><!--- #sortedScope(url)# ---></pre>
			<cfdump var="#url#" top="3" expand="true" keys="500" showUDfs="false" label="URL">
		</cfif>
	<cfcatch type="Any"></cfcatch>
	</cftry>

	<cftry>
		<cfif IsDefined("REQUEST") AND IsStruct(REQUEST) AND StructCount(REQUEST) GT 0 AND cfdebugger.check(
			"RequestVar"
		)>
			<pre><b class="varhdr">Request Parameters</b><!--- #sortedScope(request)# ---></pre>
			<cfdump var="#request#" top="3" expand="true" keys="5000" showUDfs="false" label="Request">
		</cfif>
	<cfcatch type="Any"></cfcatch>
	</cftry>

	<cftry>
		<cfif IsDefined("SESSION") AND IsStruct(SESSION) AND StructCount(SESSION) GT 0 AND cfdebugger.check(
			"SessionVar"
		)>
			<pre><b class="varhdr">Session Variables</b><!--- #sortedScope(session)# ---></pre>
			<cfdump var="#session#" top="3" expand="false" keys="100" showUDfs="false" label="Session">
		</cfif>
	<cfcatch type="Any"></cfcatch>
	</cftry>

	<cftry>
		<cfif IsDefined("COOKIE") AND IsStruct(COOKIE) AND StructCount(COOKIE) GT 0 AND cfdebugger.check("CookieVar")>
			<pre><b class="varhdr">Cookie Variables</b><!--- #sortedScope(cookie)# ---></pre>
			<cfdump var="#cookie#" top="3" expand="false" keys="5000" showUDfs="false" label="Cookie">
		</cfif>
	<cfcatch type="Any"></cfcatch>
	</cftry>

	<cftry>
		<cfif IsDefined("APPLICATION") AND IsStruct(APPLICATION) AND StructCount(APPLICATION) GT 0 AND cfdebugger.check(
			"ApplicationVar"
		)>
			<pre><b class="varhdr">Application Variables</b><!--- #sortedScope(application)# ---></pre>
			<cfdump var="#application#" top="3" expand="false" keys="100" showUDfs="false" label="Application">
		</cfif>
	<cfcatch type="Any"></cfcatch>
	</cftry>

	<cftry>
		<cfif IsDefined("CGI") AND IsStruct(CGI) AND StructCount(CGI) GT 0 AND cfdebugger.check("CGIVar")>
			<pre><b class="varhdr">CGI Variables</b>
			<!--- #sortedScope(cgi)# ---></pre>
			<cfdump var="#cgi#" top="3" expand="false" keys="500" showUDfs="false" label="CGI">
		</cfif>
		<cfcatch type="Any"></cfcatch>
	</cftry>

	<cftry>
		<cfif IsDefined("CLIENT") AND IsStruct(CLIENT) AND StructCount(CLIENT) GT 0 AND cfdebugger.check("ClientVar")>
			<pre><b class="varhdr">Client Variables</b><!--- #sortedScope(client)# ---></pre>
			<cfdump var="#client#" top="3" expand="false" keys="100" showUDfs="false" label="Client">
		</cfif>
	<cfcatch type="Any"></cfcatch>
	</cftry>

	<cftry>
		<cfif IsDefined("SERVER") AND IsStruct(SERVER) AND StructCount(SERVER) GT 0 AND cfdebugger.check("ServerVar")>
			<pre><b class="varhdr">Server Variables</b><!--- #sortedScope(server)# ---></pre>
			<cfdump var="#server#" top="3" expand="false" keys="100" showUDfs="false" label="Server">
		</cfif>
	<cfcatch type="Any"></cfcatch>
	</cftry>
	</div>
	</cfoutput>
</cfif>


<!--------------------->
<!---  SQL Queries  --->
<!------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfoutput>
<cfif bFoundSQLQueries>
  <!--- <cfdump var="#session#">  <cfdump var="#cgi#"> --->
	<cftry>
	<hr class="two"/>
	<p class="cfdebug">
		<b class="cfdebuglge"><a name="cfdebug_sql" class="grp" div="sql_queries"> SQL Queries <i>&##9658;</i> </a></b>
	</p>
	<div id="sql_queries">
		<cfif 1>
			<cfquery name="cfdebug_queries" dbtype="query">
				SELECT *, UPPER( Name ) AS Name_In_Caps
				  FROM cfdebug_queries
				  ORDER BY Name_In_Caps
			</cfquery>
		</cfif>
		<cfloop from="1" to="2" index="loop_counter">
			<cfloop query="cfdebug_queries">
				<cfset warning_css = ((max(cfdebug_queries.executionTime, 0) gt 999)
										? "red" 
										: "")>
				
				<cfif IsDefined("cfdebug_queries.rowcount") AND IsNumeric(cfdebug_queries.rowcount)>
					<cfset records_count = max(cfdebug_queries.rowcount, 0)>
				<cfelseif IsDefined("cfdebug_queries.result.recordCount")>
					<cfset records_count = cfdebug_queries.result.recordCount>
				<cfelse>
					<cfset records_count = -1>
				</cfif>
				
				<cfset warning_css = (records_count gt 999 
										? "red" 
										: warning_css)>

				<cfif loop_counter eq 1>
					<!--- if there is no performance problem skip this --->
					<cfif warning_css neq "red">
						<cfcontinue>
					</cfif>
				<cfelse>
					<!--- if there is a performance problem skip this --->
					<cfif warning_css is "red">
						<cfcontinue>
					</cfif>
				</cfif>

				<code class="#warning_css#"><b class="query">#cfdebug_queries.name#</b> (<!--- datasource=#cfdebug_queries.datasource# &##8226; ---> <i><!--- time= --->#numberFormat(
					max(cfdebug_queries.executionTime, 0),
					",_"
				) # ms </i>&##8226; <i>#numberFormat(records_count, ",_")# record<cfif records_count gt 1>s</cfif></i>
					<cfif cfdebug_queries.cachedquery>&##8226; cached query</cfif> ) in #lcase(
						cfdebug_queries.template
					)# <!--- @ #TimeFormat(cfdebug_queries.timestamp, "HH:mm:ss.SSS")# ---></code><br />
				<pre><code>#htmleditformat(rtrim(cfdebug_queries.body))#
				</code></pre>

				<cfif arrayLen(cfdebug_queries.attributes) GT 0>
				    <code class=""><!--- Query Parameter Value(s) -<br /> --->

				    <cfloop index="x" from=1 to="#arrayLen(cfdebug_queries.attributes)#">
		        		<cfset thisParam = #cfdebug_queries.attributes[cfdebug_queries.currentRow][x]#>
		        		<cfset wrapper = structKeyExists(thisParam, "sqlType") and thisParam.sqlType contains "char"
		        							? "'"
		        							: "">
				        &nbsp; &nbsp; &nbsp; &nbsp; parameter ###x#<!--- <cfif StructKeyExists(thisParam, "sqlType")>(#thisParam.sqlType#)</cfif> ---> = #wrapper#<cfif StructKeyExists(
							thisParam,
							"value"
						)>#htmleditformat(thisParam.value)#</cfif>#wrapper#<br/>
				    </cfloop>
				    </code><br>
				</cfif>
				<cfif (isDefined("cookie.sqlDumpOn") and cookie.sqlDumpOn gte 1) or cgi.query_string contains "sqlDumpOn">
					<cfif isQuery(cfdebug_queries.result) and records_count gt 0> 					
						<cfdump var="#cfdebug_queries.result#" top="#cookie.sqlDumpon#" metainfo="false" label="#cfdebug_queries.name#"><br>
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>
	<cfcatch type="Any">
		<!--- Error reporting query event --->
	</cfcatch>
	</cftry>
	</div>
</cfif>

<!-------------------->
<!--- Stored Procs --->
<!------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfif bFoundStoredProc and 0>
<cftry>
<p class="cfdebug"><hr class="two"/><b class="cfdebuglge"><a name="cfdebug_storedproc">Stored Procedures</a></b></p>
<p class="cfdebug">
<cfloop query="cfdebug_storedproc">
<!--- Output stored procedure details, remember, include result (output params) and attributes (input params) columns --->
<code><b>#cfdebug_storedproc.name#</b> (<!--- Datasource=#cfdebug_storedproc.datasource#, Time= ---> #numberFormat(
	Max(cfdebug_storedproc.executionTime, 0),
	",_"
)# ms ) in #cfdebug_storedproc.template# <!--- @ #TimeFormat(cfdebug_storedproc.timestamp, "HH:mm:ss.SSS")# ---></code><br />
    <table border=0 cellpadding=0 cellspacing=0>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <td>
            <table border=1 cellpadding=2 cellspacing=2>
            <tr bgcolor="gray"><td colspan="5" align="center"><font color="white">parameters</font></td></tr>
            <tr><td><code><i>type</i></code></td><td><code><i>CFSQLType</i></code></td><td><code><i>value</i></code></td><td><code><i>variable</i></code></td><td><code><i>dbVarName</i></code></td></tr>



            <cfloop index="x" from=1 to="#arrayLen(cfdebug_storedproc.attributes)#">
            <cfset thisParam = #cfdebug_storedproc.attributes[cfdebug_storedproc.currentRow][x]#>
            <tr>
                <td>&nbsp;<code><cfif StructKeyExists(thisParam, "type")>#thisParam.type#</cfif></code></td>
                <td>&nbsp;<code><cfif StructKeyExists(thisParam, "sqlType")>#thisParam.sqlType#</cfif></code></td>
                <td>&nbsp;<code><cfif StructKeyExists(thisParam, "value")>#htmleditformat(thisParam.value)#</cfif> <cfif thisParam.type eq "out"><i style="color:red">#evaluate(
					thisParam.variable
				)#</i></cfif></code></td>
                <td>&nbsp;<code><cfif StructKeyExists(thisParam, "variable")>#thisParam.variable# = #CFDebugSerializable(
					thisParam.variable
				)#</cfif></code></td>
                <td>&nbsp;<code><cfif StructKeyExists(thisParam, "dbVarName")>#thisParam.dbVarName#</cfif></code></td>
            </tr>


            </cfloop>


            </table>
        </td>
    </tr>
    <tr><td>&nbsp;</td><td>&nbsp;</td></tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <td>
            <table border=1 cellpadding=2 cellspacing=2>
            <tr bgcolor="gray"><td colspan="5" align="center"><font color="white">resultsets</font></td></tr>
            <tr><td><code><i>name</i></code></td><td><code><i>resultset</i></code></td></tr>

            <cfloop index="x" from=1 to="#arrayLen(cfdebug_storedproc.result)#">
            <cfset thisParam = #cfdebug_storedproc.result[cfdebug_storedproc.currentRow][x]#>
            <tr>
                <td>&nbsp;<code><cfif StructKeyExists(thisParam, "name")>#thisParam.name#</cfif></code></td>
                <td>&nbsp;<code><cfif StructKeyExists(thisParam, "resultSet")>#thisParam.resultSet#</cfif></code></td>
            </tr>
            </cfloop>
            </table>
        </td>
    </tr>
    </table>



    <!--- Dump stored procedure contents Ben Forta tip . Ajas Aug 22,06--->
	<cfif 0>
		<cfloop index="x" from=1 to="#arrayLen(cfdebug_storedproc.result)#">
		<cfset thisParam = #cfdebug_storedproc.result[cfdebug_storedproc.currentRow][x]#>
		<cfif StructKeyExists(thisParam, "name")>
			<br /><b> *** COLUMNS FROM THE STORED PROCEDURE *** SQL Name : <i style="color:red"><cfdump var="#cfdebug_storedproc.NAME#"></i> --- CFPROCRESULT Name : <i style="color:red">#thisParam.name#</i> --- 					    RESULTSET No :  <i style="color:red"><cfdump var="#thisParam.resultSet#"></i>
			</b>
			<br /><br />
			<cfdump var="#evaluate(thisParam.name)#">
			<br /><b>*****************************************************************************************
				  </b>
			<br /> <br />

		<cfelse><br />
				 <b>*****************************************************************************************
				 </b>
				 <br /> <br />
		</cfif>
		</cfloop>
		<!--- End of Dump stored procedure contents Ben Forta tip . Ajas Aug 22,06--->
	</cfif>
</cfloop>
</p>
	<cfcatch type="Any">
		<!--- Error reporting stored proc event --->
	</cfcatch>
</cftry>
</cfif>


<!------------------------------->
<!---  Debugging Information  --->
<!------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfif bGeneral>
<cfoutput>
	<cftry>
		<hr class="two"/>
		<p class="cfdebug">
		<b class="cfdebuglge"><a name="cfdebug_top" class="grp" div="debug_info">Debugging Information <i>&##9658;</i></a></b>
		<div id="debug_info">
		<table class="cfdebug">
		<tr>
			<td class="cfdebug" nowrap>#server.coldfusion.productname# #server.coldfusion.productlevel#</td>
			<td class="cfdebug">#server.coldfusion.productversion#</td>
		</tr>
		<tr>
			<td class="cfdebug" nowrap> Template </td>
			<td class="cfdebug">#xmlFormat(CGI.Script_Name)#</td>
		</tr>
		<tr>
			<td class="cfdebug" nowrap> Time Stamp </td>
			<td class="cfdebug">#DateFormat(Now())# #TimeFormat(Now())#</td>
		</tr>
		<tr>
			<td class="cfdebug" nowrap> Locale </td>
			<td class="cfdebug">#GetLocale()#</td>
		</tr>
		<tr>
			<td class="cfdebug" nowrap> User Agent </td>
			<td class="cfdebug">#CGI.HTTP_USER_AGENT#</td>
		</tr>
		<tr>
			<td class="cfdebug" nowrap> Remote IP </td>
			<td class="cfdebug">#CGI.REMOTE_ADDR#</td>
		</tr>
		<tr>
			<td class="cfdebug" nowrap> Host Name </td>
			<td class="cfdebug">#CGI.REMOTE_HOST#</td>
		</tr>
		</table>
		</div>
		</p>
		<cfcatch type="Any"></cfcatch>
	</cftry>
</cfoutput>
</cfif>

<!------------------------------------------->
<!--- Template Stack and Executions Times --->
<!------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfif bFoundTemplates>
  	<!--- Total Execution Time of all top level pages --->
  	<cfquery dbType="query" name="cfdebug_execution" debug="false">
      	SELECT (endTime - startTime) AS executionTime
      	FROM qEvents
      	WHERE type = 'ExecutionTime'
  	</cfquery>
	<!--- ::
		in the case that no execution time is recorded.
		we will add a value of -1 so we know that a problem exists but the template continues to run properly.
		:: --->
	<cfif not cfdebug_execution.recordCount>
		<cfscript>
			queryAddRow(cfdebug_execution);
			querySetCell(cfdebug_execution, "executionTime", "-1");
		</cfscript>
	</cfif>


  	<cfquery dbType="query" name="cfdebug_top_level_execution_sum" debug="false">
  		SELECT sum(endTime - startTime) AS executionTime
	  	FROM qEvents
  		WHERE type = 'Template' AND parent = ''
  	</cfquery>

    <!--- File not found will not produce any records when looking for top level pages --->
    <cfif cfdebug_top_level_execution_sum.recordCount and len(trim(cfdebug_top_level_execution_sum.executionTime[1])) gt 0>
        <cfset time_other = Max(
			cfdebug_execution.executionTime - val(cfdebug_top_level_execution_sum.executionTime),
			0
		)>
        <cfoutput>
			<style type="text/css">
            .template
            {	color: black;
				font-family: "Source Code Pro Semibold", Inconsolata, Arial, sans-serif;
            	font-weight: normal; }
            .template_overage
            {	color: red;
            	background-color: white;
				font-family: "Source Code Pro Semibold", Inconsolata, Arial, sans-serif;
            	font-weight: bold; }
            </style>
       		<hr class="two"/>
       		<p class="cfdebug"><b class="cfdebuglge"><a name="cfdebug_execution" class="grp" div="exe_time">Execution Time <i>&##9658;</i></a></b></p>
       		<div id="exe_time">
            <a name="cfdebug_templates">
        </cfoutput>

        <cfif cfdebugger.settings.template_mode EQ "tree">
            <cfset a = arrayNew(1)>
            <cfloop query="qEvents">
               <cfscript>
                    // only want templates, IMQ of SELECT * ...where type = 'template' will result
                    // in cannot convert the value "" to a boolean for cachedquery column
                    // SELECT stacktrace will result in Query Of Queries warning_css error.
                    // Failed to get meta_data for columnqEvents.stacktrace .
                    // Was told I need to define meta data for debugging event table similar to <cfldap>
                    if (qEvents.type eq "template") {
						st = structNew();
                        st.StackTrace = qEvents.stackTrace;
                        st.template = qEvents.template;
                        st.startTime = qEvents.starttime;
                        st.endTime = qEvents.endtime;
                        st.parent = qEvents.parent;
                        st.line = qEvents.line;

                        arrayAppend(a, st);
					}
               </cfscript>
            </cfloop>
            <cfset qTree = queryNew("template,templateId,parentId,duration,line")>
            <cfloop index="i" from="1" to="#arrayLen(a)#">
                <cfset childidList = "">
                <cfset parentidList = "">
                <cfloop index="x" from="#arrayLen(a[i].stacktrace.tagcontext)#" to="1" step="-1">
                    <cfscript>
                        if (a[i].stacktrace.tagcontext[x].id NEQ "CF_INDEX") {
							// keep appending the line number from the template stack to form a unique id
                            childIdList = listAppend(childIdList, a[i].stacktrace.tagcontext[x].line);
                            if (x eq 1) {
								//parentIdList = listAppend(parentIdList, a[i].stacktrace.tagcontext[x].template);
								raw_trace = a[i].stacktrace.tagcontext[x].raw_trace;
                                findFunctionPrefix = "$func"; // set prefix to account for length and position since CF doesn't have RegEx lookbehind assertion
                                findFunction = ReFindNoCase(
									"(?=\" & findFunctionPrefix & ").*(?=\.runFunction\()",
									raw_trace,
									1,
									true
								);
                                if (findFunction.len[1] NEQ 0 AND findFunction.pos[1] NEQ 0) {
									// get function name from raw_trace to allow for proper application.cfc tree rendering
                                    parentfunction = Trim(
										Mid(
											raw_trace,
											findFunction.pos[1] + Len(findFunctionPrefix),
											findFunction.len[1] - Len(findFunctionPrefix)
										)
									);
                                    // append the function name (pulled from raw_trace) to the cfc template for tree root comparison.
                                    parentIdList = listAppend(
										parentIdList,
										a[i].stacktrace.tagcontext[x].template & " | " & lcase(parentfunction)
									);
								} else {
									parentIdList = listAppend(parentIdList, a[i].stacktrace.tagcontext[x].template);
								}
							} else {
								parentIdList = listAppend(parentIdList, a[i].stacktrace.tagcontext[x].line);
							}
						}
                    </cfscript>
                </cfloop>

                <cfscript>
                    // template is the last part of the unique id...12,5,17,c:\wwwroot\foo.cfm
                    // if we don't remove the "CFC[" prefix, then the parentId and childId relationship
                    // will be all wrong
                    startToken = "CFC[ ";
                    //endToken = " | ";
					endToken = "(";
                    thisTemplate = a[i].template;
                    startTokenIndex = FindNoCase(startToken, thisTemplate, 1);
                    if (startTokenIndex NEQ 0) {
						endTokenIndex = FindNoCase(endToken, thisTemplate, startTokenIndex);
                        thisTemplate = Trim(Mid(thisTemplate, Len(startToken), endTokenIndex - Len(startToken)));
					}
                    childIdList = listAppend(childIdList, thisTemplate);

                    queryAddRow(qTree);
                    querySetCell(qTree, "template", a[i].template);
                    querySetCell(qTree, "templateId", childIdList);
                    querySetCell(qTree, "parentId", parentIdList);
                    querySetCell(qTree, "duration", a[i].endtime - a[i].starttime);
                    querySetCell(qTree, "line", a[i].line);
                </cfscript>
            </cfloop>

            <cfset stTree = structNew()>
            <cfloop query="qTree">
                <cfscript>
                // empty parent assumed to be top level with the exception of application.cfm
                if (len(trim(parentId)) eq 0) {
					parentId = 0;
				}
                    stTree[parentId] = structNew();
                    stTree[parentId].templateId = qTree.templateId;
                    stTree[parentId].template = qTree.template;
                    stTree[parentId].duration = qTree.duration;
                    stTree[parentId].line = qTree.line;
                    stTree[parentId].children = arrayNew(1);
                </cfscript>
            </cfloop>
            <cfloop query="qTree">
                <cfscript>
                    stTree[templateId] = structNew();
                    stTree[templateId].templateId = qTree.templateId;
                    stTree[templateId].template = qTree.template;
                    stTree[templateId].duration = qTree.duration;
                    stTree[templateId].line = qTree.line;
                    stTree[templateId].children = arrayNew(1);
                </cfscript>
            </cfloop>
            <cfloop query="qTree">
                <cfscript>
                    arrayAppend(stTree[parentId].children, stTree[templateId]);
                </cfscript>
            </cfloop>

            <cfquery dbType="query" name="topNodes" debug="false">
                SELECT parentId, templateid
                FROM qTree
                WHERE parentId = ''
            </cfquery>


            <cfoutput>
            <cfloop query="topNodes">
                #drawTree(
					stTree,
					- 1,
					topNodes.templateid,
					cfdebugger.settings.template_highlight_minimum
				)#
            </cfloop>
            </cfoutput>
            <cfoutput><p class="template">
                (#time_other# ms) STARTUP, PARSING, COMPILING, LOADING, &amp; SHUTDOWN<br />
                (#cfdebug_execution.executionTime# ms) TOTAL EXECUTION TIME<br />
                <font color="red"><span class="template_overage">red = over #cfdebugger.settings.template_highlight_minimum# ms execution time</span></font>
                </p></cfoutput>
        <cfelse>
        	<cftry>
                <cfquery dbType="query" name="cfdebug_templates_summary" debug="false">
	                SELECT  template, Sum(endTime - startTime) AS totalExecutionTime, count(template) AS instances
	                FROM qEvents
	                WHERE type = 'Template'
	                group by template
	                order by totalExecutionTime DESC
                </cfquery>
                <cfoutput>

                <table border="1" cellpadding="2" cellspacing="0" class="cfdebug">
                <tr>
					<td class="cfdebug" align="center"><b>Total Time</b></td>
					<td class="cfdebug" align="center"><b>Avg Time</b></td>
					<td class="cfdebug" align="center"><b>Count</b></td>
					<td class="cfdebug"><b>Template</b></td>
				</tr>

                </cfoutput>
                <cftry>
                    <cfoutput>
                    <cfloop query="cfdebug_templates_summary">
                        <cfset templateOutput = template>
                        <cfset templateAverageTime = Round(totalExecutionTime / instances)>

                        <cfif template EQ ExpandPath(cgi.script_name)>
                            <cfset templateOutput = "<img src='#getpageContext().getRequest().getContextPath()#/CFIDE/debug/images/topdoc.gif' alt='top level' border='0'> " &
                                "<b>" & template & "</b>">
							 <cfif templateAverageTime GT cfdebugger.settings.template_highlight_minimum>
                                <cfset templateOutput = "<font color='red'><span class='template_overage'>" & template & "</span></font>">
                                <cfset templateAverageTime = "<font color='red'><span class='template_overage'>" & templateAverageTime & "</span></font>">
								<cfset totalTime = "<font color='red'><span class='template_overage'>" & totalExecutionTime & "</span></font>">
                            </cfif>
                        <cfelse>
                            <cfif templateAverageTime GT cfdebugger.settings.template_highlight_minimum>
                                <cfset templateOutput = "<font color='red'><span class='template_overage'>" & template & "</span></font>">
                                <cfset templateAverageTime = "<font color='red'><span class='template_overage'>" & templateAverageTime & "</span></font>">
								<cfset totalTime = "<font color='red'><span class='template_overage'>" & totalExecutionTime & "</span></font>">
                            </cfif>
                        </cfif>

                        <tr>
							<cfif isDefined("totalTime") and len(trim(totalTime))>
								<td align="right" class="cfdebug" nowrap>#totalTime# ms</td>
								<cfset totalTime = "">
							<cfelse>
    	                        <td align="right" class="cfdebug" nowrap>#totalExecutionTime# ms</td>
							</cfif>
                            <td align="right" class="cfdebug" nowrap>#templateAverageTime# ms</td>
                            <td align="center" class="cfdebug" nowrap>#instances#</td>
                            <td align="left" class="cfdebug" nowrap>#templateOutput#</td>
                        </tr>
                    </cfloop>
                    </cfoutput>
                <cfcatch type="Any"></cfcatch>
                </cftry>
                <cfoutput>
                <tr>
					<td align="right" class="cfdebug" nowrap><i>#time_other# ms</i></td><td colspan=2>&nbsp;</td>
                    <td align="left" class="cfdebug"><i>STARTUP, PARSING, COMPILING, LOADING, &amp; SHUTDOWN</i></td>
				</tr>
                <tr>
					<td align="right" class="cfdebug" nowrap><i>#cfdebug_execution.executionTime# ms</i></td><td colspan=2>&nbsp;</td>
                    <td align="left" class="cfdebug"><i>TOTAL EXECUTION TIME</i></td>
				</tr>
                </table>
                <font color="red"><span class="template_overage">red = over #cfdebugger.settings.template_highlight_minimum# ms average execution time</span></font>
                </a>
            	</div>  <!--- id="exe_time"> --->
            	</cfoutput>
        	<cfcatch type="Any"></cfcatch>

        	</cftry>
        </cfif> <!--- template_mode = summary--->
    <cfelse>
        <p class="cfdebug"><hr class="two"/><b class="cfdebuglge"><a name="cfdebug_execution">Execution Time</a></b></p>
        <a name="cfdebug_templates">
        No top level page was found.
        </a>
    </cfif> <!--- if top level templates are available --->
</cfif>

<!------------------>
<!--- Exceptions --->
<!------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfif bFoundExceptions>
<cftry>
<cfoutput>
	<p class="cfdebug"><hr class="two"/><b class="cfdebuglge"><a name="cfdebug_exceptions">Exceptions</a></b></p>
	<cfloop query="cfdebug_ex">
	    <div class="cfdebug">#TimeFormat(cfdebug_ex.timestamp, "HH:mm:ss.SSS")# - #cfdebug_ex.name# <cfif FindNoCase(
			"Exception",
			cfdebug_ex.name
		) EQ 0>Exception</cfif> - in #cfdebug_ex.template# : line #cfdebug_ex.line#</div>
	    <cfif IsDefined("cfdebug_ex.message") AND Len(Trim(cfdebug_ex.message)) GT 0>
	    <pre>
	    #cfdebug_ex.message#
	    </pre>
	    </cfif>
	</cfloop>
</cfoutput>
	<cfcatch type="Any">
		<!--- Error reporting an exception event entry. --->
	</cfcatch>
</cftry>
</cfif>


<!--------------->
<!--- CFTimer --->
<!------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfif bFoundTimer>
<p class="cfdebug"><hr class="two"/><b class="cfdebuglge"><a name="cfdebug_timer">CFTimer Times</a></b></p>
<p class="cfdebug">

<cfloop query="cfdebug_timer">
    <cftry>
    	<img src='#getpageContext().getRequest().getContextPath()#/CFIDE/debug/images/#Replace(
			cfdebug_timer.priority,
			" ",
			"%20"
		)#_16x16.gif' alt="#cfdebug_timer.priority# type">
		 [#val(cfdebug_timer.endTime) - val(cfdebug_timer.startTime)#ms] <i>#cfdebug_timer.message#</i><br />
    	<cfcatch type="Any"></cfcatch>
    </cftry>
</cfloop>
</p>
</cfif>


<!--------------->
<!--- Tracing --->
<!------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfif bFoundTrace>
<p class="cfdebug"><hr class="two"/><b class="cfdebuglge"><a name="cfdebug_trace">Trace Points</a></b></p>
<p class="cfdebug">

<cfset firstTrace = true>
<cfset prevDelta = 0>
<cfloop query="cfdebug_trace">
    <cfset deltaFromRequest = Val(cfdebug_trace.endTime)>
    <cfset deltaFromLast = Val(deltaFromRequest - prevDelta)>
    <cftry>
    	<img src='#getpageContext().getRequest().getContextPath()#/CFIDE/debug/images/#Replace(
			cfdebug_trace.priority,
			" ",
			"%20"
		)#_16x16.gif' alt="#cfdebug_trace.priority# type"> [#TimeFormat(cfdebug_trace.timestamp, "HH:mm:ss.lll")# #cfdebug_trace.template# @ line: #cfdebug_trace.line#] [#deltaFromRequest# ms (<cfif firstTrace>1st trace<cfelse>#deltaFromLast# ms</cfif>)] - <cfif #cfdebug_trace.category# NEQ "">[#cfdebug_trace.category#]</cfif> <cfif #cfdebug_trace.result# NEQ "">[#cfdebug_trace.result#]</cfif> <i>#cfdebug_trace.message#</i><br />
    	<cfcatch type="Any"></cfcatch>
    </cftry>
    <cfset prevDelta = deltaFromRequest>
    <cfset firstTrace = false>
</cfloop>
</p>
</cfif>

<cfset duration = getTickCount() - startTime>
<cfif displayDebug>
	<br/>
	<font size="-1" class="cfdebug"><i>Debug Rendering Time: #duration# ms</i></font><br />

	</td>
</tr>
</table>
</cfif>
<link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet">
<a href="javascript:" id="return-to-top"><i class="fa fa-chevron-up" aria-hidden="true"></i></a>
</cfoutput>
</cfsavecontent>
<cfsetting enablecfoutputonly="No">

<!---  CF injected styles & script for each cfdump - remove the duplicate code --->
<cfsavecontent variable="duplicate_code"><style>


	table.cfdump_wddx,
	table.cfdump_xml,
	table.cfdump_struct,
	table.cfdump_varundefined,
	table.cfdump_array,
	table.cfdump_query,
	table.cfdump_cfc,
	table.cfdump_object,
	table.cfdump_binary,
	table.cfdump_udf,
	table.cfdump_udfbody,
	table.cfdump_udfarguments {
		font-size: xx-small;
		font-family: verdana, arial, helvetica, sans-serif;
		cell-spacing: 2px;
	}

	table.cfdump_wddx th,
	table.cfdump_xml th,
	table.cfdump_struct th,
	table.cfdump_varundefined th,
	table.cfdump_array th,
	table.cfdump_query th,
	table.cfdump_cfc th,
	table.cfdump_object th,
	table.cfdump_binary th,
	table.cfdump_udf th,
	table.cfdump_udfbody th,
	table.cfdump_udfarguments th {
		text-align: left;
		color: white;
		padding: 5px;
	}

	table.cfdump_wddx td,
	table.cfdump_xml td,
	table.cfdump_struct td,
	table.cfdump_varundefined  td,
	table.cfdump_array td,
	table.cfdump_query td,
	table.cfdump_cfc td,
	table.cfdump_object td,
	table.cfdump_binary td,
	table.cfdump_udf td,
	table.cfdump_udfbody td,
	table.cfdump_udfarguments td {
		padding: 3px;
		background-color: #ffffff;
		vertical-align : top;
	}

	table.cfdump_wddx {
		background-color: #000000;
	}
	table.cfdump_wddx th.wddx {
		background-color: #444444;
	}


	table.cfdump_xml {
		background-color: #888888;
	}
	table.cfdump_xml th.xml {
		background-color: #aaaaaa;
	}
	table.cfdump_xml td.xml {
		background-color: #dddddd;
	}

	table.cfdump_struct {
		background-color: #0000cc ;
	}
	table.cfdump_struct th.struct {
		background-color: #4444cc ;
	}
	table.cfdump_struct td.struct {
		background-color: #ccddff;
	}

	table.cfdump_varundefined {
		background-color: #CC3300 ;
	}
	table.cfdump_varundefined th.varundefined {
		background-color: #CC3300 ;
	}
	table.cfdump_varundefined td.varundefined {
		background-color: #ccddff;
	}

	table.cfdump_array {
		background-color: #006600 ;
	}
	table.cfdump_array th.array {
		background-color: #009900 ;
	}
	table.cfdump_array td.array {
		background-color: #ccffcc ;
	}

	table.cfdump_query {
		background-color: #884488 ;
	}
	table.cfdump_query th.query {
		background-color: #aa66aa ;
	}
	table.cfdump_query td.query {
		background-color: #ffddff ;
	}


	table.cfdump_cfc {
		background-color: #ff0000;
	}
	table.cfdump_cfc th.cfc{
		background-color: #ff4444;
	}
	table.cfdump_cfc td.cfc {
		background-color: #ffcccc;
	}


	table.cfdump_object {
		background-color : #ff0000;
	}
	table.cfdump_object th.object{
		background-color: #ff4444;
	}

	table.cfdump_binary {
		background-color : #eebb00;
	}
	table.cfdump_binary th.binary {
		background-color: #ffcc44;
	}
	table.cfdump_binary td {
		font-size: x-small;
	}
	table.cfdump_udf {
		background-color: #aa4400;
	}
	table.cfdump_udf th.udf {
		background-color: #cc6600;
	}
	table.cfdump_udfarguments {
		background-color: #dddddd;
		cell-spacing: 3;
	}
	table.cfdump_udfarguments th {
		background-color: #eeeeee;
		color: #000000;
	}

</style> <script language="javascript">


// for queries we have more than one td element to collapse/expand
	var expand = "open";

	dump = function( obj ) {
		var out = "" ;
		if ( typeof obj == "object" ) {
			for ( key in obj ) {
				if ( typeof obj[key] != "function" ) out += key + ': ' + obj[key] + '<br>' ;
			}
		}
	}


	cfdump_toggleRow = function(source) {
		//target is the right cell
		if(document.all) target = source.parentElement.cells[1];
		else {
			var element = null;
			var vLen = source.parentNode.childNodes.length;
			for(var i=vLen-1;i>0;i--){
				if(source.parentNode.childNodes[i].nodeType == 1){
					element = source.parentNode.childNodes[i];
					break;
				}
			}
			if(element == null)
				target = source.parentNode.lastChild;
			else
				target = element;
		}
		//target = source.parentNode.lastChild ;
		cfdump_toggleTarget( target, cfdump_toggleSource( source ) ) ;
	}

	cfdump_toggleXmlDoc = function(source) {

		var caption = source.innerHTML.split( ' [' ) ;

		// toggle source (header)
		if ( source.style.fontStyle == 'italic' ) {
			// closed -> short
			source.style.fontStyle = 'normal' ;
			source.innerHTML = caption[0] + ' [short version]' ;
			source.title = 'click to maximize' ;
			switchLongToState = 'closed' ;
			switchShortToState = 'open' ;
		} else if ( source.innerHTML.indexOf('[short version]') != -1 ) {
			// short -> full
			source.innerHTML = caption[0] + ' [long version]' ;
			source.title = 'click to collapse' ;
			switchLongToState = 'open' ;
			switchShortToState = 'closed' ;
		} else {
			// full -> closed
			source.style.fontStyle = 'italic' ;
			source.title = 'click to expand' ;
			source.innerHTML = caption[0] ;
			switchLongToState = 'closed' ;
			switchShortToState = 'closed' ;
		}

		// Toggle the target (everething below the header row).
		// First two rows are XMLComment and XMLRoot - they are part
		// of the long dump, the rest are direct children - part of the
		// short dump
		if(document.all) {
			var table = source.parentElement.parentElement ;
			for ( var i = 1; i < table.rows.length; i++ ) {
				target = table.rows[i] ;
				if ( i < 3 ) cfdump_toggleTarget( target, switchLongToState ) ;
				else cfdump_toggleTarget( target, switchShortToState ) ;
			}
		}
		else {
			var table = source.parentNode.parentNode ;
			var row = 1;
			for ( var i = 1; i < table.childNodes.length; i++ ) {
				target = table.childNodes[i] ;
				if( target.style ) {
					if ( row < 3 ) {
						cfdump_toggleTarget( target, switchLongToState ) ;
					} else {
						cfdump_toggleTarget( target, switchShortToState ) ;
					}
					row++;
				}
			}
		}
	}

	cfdump_toggleTable = function(source) {

		var switchToState = cfdump_toggleSource( source ) ;
		if(document.all) {
			var table = source.parentElement.parentElement ;
			for ( var i = 1; i < table.rows.length; i++ ) {
				target = table.rows[i] ;
				cfdump_toggleTarget( target, switchToState ) ;
			}
		}
		else {
			var table = source.parentNode.parentNode ;
			for ( var i = 1; i < table.childNodes.length; i++ ) {
				target = table.childNodes[i] ;
				if(target.style) {
					cfdump_toggleTarget( target, switchToState ) ;
				}
			}
		}
	}

	cfdump_toggleSource = function( source ) {
		if ( source.style.fontStyle == 'italic' || source.style.fontStyle == null) {
			source.style.fontStyle = 'normal' ;
			source.title = 'click to collapse' ;
			return 'open' ;
		} else {
			source.style.fontStyle = 'italic' ;
			source.title = 'click to expand' ;
			return 'closed' ;
		}
	}

	cfdump_toggleTarget = function( target, switchToState ) {
		if ( switchToState == 'open' )	target.style.display = '' ;
		else target.style.display = 'none' ;
	}

	// collapse all td elements for queries
	cfdump_toggleRow_qry = function(source) {
		expand = (source.title == "click to collapse") ? "closed" : "open";
		if(document.all) {
			var nbrChildren = source.parentElement.cells.length;
			if(nbrChildren > 1){
				for(i=nbrChildren-1;i>0;i--){
					target = source.parentElement.cells[i];
					cfdump_toggleTarget( target,expand ) ;
					cfdump_toggleSource_qry(source);
				}
			}
			else {
				//target is the right cell
				target = source.parentElement.cells[1];
				cfdump_toggleTarget( target, cfdump_toggleSource( source ) ) ;
			}
		}
		else{
			var target = null;
			var vLen = source.parentNode.childNodes.length;
			for(var i=vLen-1;i>1;i--){
				if(source.parentNode.childNodes[i].nodeType == 1){
					target = source.parentNode.childNodes[i];
					cfdump_toggleTarget( target,expand );
					cfdump_toggleSource_qry(source);
				}
			}
			if(target == null){
				//target is the last cell
				target = source.parentNode.lastChild;
				cfdump_toggleTarget( target, cfdump_toggleSource( source ) ) ;
			}
		}
	}

	cfdump_toggleSource_qry = function(source) {
		if(expand == "closed"){
			source.title = "click to expand";
			source.style.fontStyle = "italic";
		}
		else{
			source.title = "click to collapse";
			source.style.fontStyle = "normal";
		}
	}

</script></cfsavecontent>
<cfscript>
	// debug_content = application.util.string.compress( debug_content );

	// remove duplicate code
	debug_content = replaceNoCase(debug_content, duplicate_code, "", "all");
</cfscript>
<cfoutput>#debug_content#</cfoutput>
</cfif>


<cfscript>
//UDF - Handle output of complex data types.
function CFDebugSerializable(variable) {
	var ret = "";
try {
	if (IsSimpleValue(variable)) {
		ret = xmlFormat(variable);
	} else {
		if (IsStruct(variable)) {
			ret = ("Struct (" & StructCount(variable) & ")");
		} else if (IsArray(variable)) {
			ret = ("Array (" & ArrayLen(variable) & ")");
		} else if (IsQuery(variable)) {
			ret = ("Query (" & variable.RecordCount & ")");
		} else {
			ret = ("Complex type");
		}
	}
} catch ("any" ex) {
	ret = "undefined";
}
    return ret;
}
// UDF - tree writing
function drawNode(
	nTree,
	indent,
	id,
	highlightThreshold
) {
	var templateOuput = "";
    if (nTree[id].duration GT highlightThreshold) {
		templateOutput = "<font color='red'><span class='template_overage'>(#nTree[id].duration#ms) " & nTree[id].template & " @ line " & #nTree[id].line# & "</span></font><br>";
	} else {
		templateOutput = "<span class='template'>(#nTree[id].duration#ms) " & nTree[id].template & " @ line " & #nTree[id].line# & "</span><br>";
	}
    writeOutput(
		repeatString("&nbsp;&nbsp;&middot;", indent + 1) & " <img src='#getpageContext().getRequest().getContextPath()#/CFIDE/debug/images/arrow.gif' alt='arrow' border='0'><img src='#getpageContext().getRequest()
			.getContextPath()#/CFIDE/debug/images/endDoc.gif' alt='top level' border='0'> " & templateOutput
	);
    return "";
}

function drawTree(
	tree,
	indent,
	id,
	highlightThreshold
) {
	var alength = 1;
    var i = 1;
    var templateOuput = "";

	if (structKeyExists(tree, id)) {
		// top level nodes (application.cfm,cgi.script_name,etc) have a -1 parent line number
	    if (tree[id].line EQ -1) {
			if (Tree[id].duration GT highlightThreshold) {
				writeoutput(
					"<img src='#getpageContext().getRequest().getContextPath()#/CFIDE/debug/images/topdoc.gif' alt='top level' border='0'> " & "<font color='red'><span class='template_overage'><b>(#Tree[id].duration#ms) " & Tree[id].template & "</b></span></font><br>"
				);
			} else {
				writeoutput(
					"<img src='#getpageContext().getRequest().getContextPath()#/CFIDE/debug/images/topdoc.gif' alt='top level' border='0'> " & "<span class='template'><b>(#Tree[id].duration#ms) " & Tree[id].template & "</b></span><br>"
				);
			}
		} else {
			if (Tree[id].duration GT highlightThreshold) {
				templateOutput = "<font color='red'><span class='template_overage'>(#Tree[id].duration#ms) " & Tree[id].template & " @ line " & #Tree[id].line# & "</span></font><br>";
			} else {
				templateOutput = "<span class='template'>(#Tree[id].duration#ms) " & Tree[id].template & " @ line " & #Tree[id].line# & "</span><br>";
			}
	        writeoutput(
				repeatString("&nbsp;&nbsp;&middot;", indent + 1) & " <img src='#getpageContext().getRequest()
					.getContextPath()#/CFIDE/debug/images/arrow.gif' alt='arrow' border='0'><img src='#getpageContext().getRequest()
						.getContextPath()#/CFIDE/debug/images/parentDoc.gif' alt='top level' border='0'> " & templateOutput
			);
		}

	    if (isArray(tree[id].children) and arrayLen(tree[id].children)) {
			alength = arrayLen(tree[id].children);
	        for (i = 1; i lte alength; i = i + 1) {
				if (isArray(tree[id].children[i].children) and arrayLen(tree[id].children[i].children) gt 0) {
					drawTree(
						tree,
						indent + 1,
						tree[id].children[i].templateid,
						highlightThreshold
					);
				} else {
					drawNode(
						tree,
						indent + 1,
						tree[id].children[i].templateid,
						highlightThreshold
					);
				}
			}
		} else {
			// single template, no includes?
	        //drawNode(tree, indent + 1, tree[id].template, highlightThreshold);
		}
	}
    return "";
}
</cfscript>

<!--- use light color on even days --->
<cfset light_colors = (day(now()) mod 2 eq 0)>   
<cfif light_colors>
	<cfset hl_colors = [
		"default.css",
		"foundation.css",
		"arduino-light.css",
		"atelier-cave-light.css",
		"atelier-dune-light.css",
		"atelier-estuary-light.css",
		"atelier-forest-light.css",
		"atelier-heath-light.css",
		"atelier-lakeside-light.css",
		"atelier-plateau-light.css",
		"atelier-savanna-light.css",
		"atelier-seaside-light.css",
		"atelier-sulphurpool-light.css",
		"atom-one-light.css",
		"gruvbox-light.css",
		"kimbie.light.css",
		"paraiso-light.css",
		"qtcreator_light.css",
		"solarized-light.css"
	]>
<cfelse>	
	<cfset hl_colors = [
		"darcula.css",
		"dark.css",
		"monokai-sublime.css",
		"rainbow.css",
		"zenburn.css",
		"atelier-cave-dark.css",
		"atelier-dune-dark.css",
		"atelier-estuary-dark.css",
		"atelier-forest-dark.css",
		"atelier-heath-dark.css",
		"atelier-lakeside-dark.css?fav",
		"atelier-plateau-dark.css",
		"atelier-savanna-dark.css",
		"atelier-seaside-dark.css",
		"atelier-sulphurpool-dark.css",
		"atom-one-dark.css",
		"gruvbox-dark.css",
		"kimbie.dark.css",
		"paraiso-dark.css",
		"qtcreator_dark.css",
		"solarized-dark.css"
	]>
</cfif>

<cfset hl_color = hl_colors[randRange(1, arrayLen(hl_colors), "SHA1PRNG")]>
<cfset hl_color = "darcula.css">
<cfset hl_color = "monokai-sublime.css">
<cfoutput><link rel="stylesheet" href="https://cdn.awayx.com/base/script/javascript/highlight/9.12/#hl_color#"></cfoutput>
<script src="https://cdn.awayx.com/base/script/javascript/highlight/9.12/highlight.sql.js"></script>

<cfinclude template="/common_files/jQuery.cfm">

<script>
	hljs.initHighlightingOnLoad();
	jQuery.noConflict();
	jQuery("a.grp").click(function() {
		// get the div associated with this section
		var div = jQuery( "#" + jQuery(this).attr( "div" ) );
		div.toggle();
		
		if ( div.is(":visible") ) {
			// show collapsed icon
			jQuery(this).find("i").html("<i>&#9650;</i>");
		}
		else {
			// show expand icon
			jQuery(this).find("i").html("<i>&#9658;</i>");
		}
	});
	// $("a.grp").each(function() { $( "#" + $(this).attr( "div" ) ).toggle(); });
	/* return to top */
	jQuery(window).scroll(function() {
	    if (jQuery(this).scrollTop() >= 50) {        
	        jQuery('#return-to-top').fadeIn(200);    
	    } else {
	        jQuery('#return-to-top').fadeOut(200);   
	    };
	});
	jQuery('#return-to-top').click(function() {      
	    jQuery('body,html').animate({
	        scrollTop : 0                       
	    }, 500);
	});
	cfdump_toggleRow = function() {
	};
</script>

<script language="javascript">


// for queries we have more than one td element to collapse/expand
	var expand = "open";

	dump = function( obj ) {
		var out = "" ;
		if ( typeof obj == "object" ) {
			for ( key in obj ) {
				if ( typeof obj[key] != "function" ) out += key + ': ' + obj[key] + '<br>' ;
			}
		}
	}


	cfdump_toggleRow = function(source) {
		//target is the right cell
		if(document.all) target = source.parentElement.cells[1];
		else {
			var element = null;
			var vLen = source.parentNode.childNodes.length;
			for(var i=vLen-1;i>0;i--){
				if(source.parentNode.childNodes[i].nodeType == 1){
					element = source.parentNode.childNodes[i];
					break;
				}
			}
			if(element == null)
				target = source.parentNode.lastChild;
			else
				target = element;
		}
		//target = source.parentNode.lastChild ;
		cfdump_toggleTarget( target, cfdump_toggleSource( source ) ) ;
	}

	cfdump_toggleXmlDoc = function(source) {

		var caption = source.innerHTML.split( ' [' ) ;

		// toggle source (header)
		if ( source.style.fontStyle == 'italic' ) {
			// closed -> short
			source.style.fontStyle = 'normal' ;
			source.innerHTML = caption[0] + ' [short version]' ;
			source.title = 'click to maximize' ;
			switchLongToState = 'closed' ;
			switchShortToState = 'open' ;
		} else if ( source.innerHTML.indexOf('[short version]') != -1 ) {
			// short -> full
			source.innerHTML = caption[0] + ' [long version]' ;
			source.title = 'click to collapse' ;
			switchLongToState = 'open' ;
			switchShortToState = 'closed' ;
		} else {
			// full -> closed
			source.style.fontStyle = 'italic' ;
			source.title = 'click to expand' ;
			source.innerHTML = caption[0] ;
			switchLongToState = 'closed' ;
			switchShortToState = 'closed' ;
		}

		// Toggle the target (everething below the header row).
		// First two rows are XMLComment and XMLRoot - they are part
		// of the long dump, the rest are direct children - part of the
		// short dump
		if(document.all) {
			var table = source.parentElement.parentElement ;
			for ( var i = 1; i < table.rows.length; i++ ) {
				target = table.rows[i] ;
				if ( i < 3 ) cfdump_toggleTarget( target, switchLongToState ) ;
				else cfdump_toggleTarget( target, switchShortToState ) ;
			}
		}
		else {
			var table = source.parentNode.parentNode ;
			var row = 1;
			for ( var i = 1; i < table.childNodes.length; i++ ) {
				target = table.childNodes[i] ;
				if( target.style ) {
					if ( row < 3 ) {
						cfdump_toggleTarget( target, switchLongToState ) ;
					} else {
						cfdump_toggleTarget( target, switchShortToState ) ;
					}
					row++;
				}
			}
		}
	}

	cfdump_toggleTable = function(source) {

		var switchToState = cfdump_toggleSource( source ) ;
		if(document.all) {
			var table = source.parentElement.parentElement ;
			for ( var i = 1; i < table.rows.length; i++ ) {
				target = table.rows[i] ;
				cfdump_toggleTarget( target, switchToState ) ;
			}
		}
		else {
			var table = source.parentNode.parentNode ;
			for ( var i = 1; i < table.childNodes.length; i++ ) {
				target = table.childNodes[i] ;
				if(target.style) {
					cfdump_toggleTarget( target, switchToState ) ;
				}
			}
		}
	}

	cfdump_toggleSource = function( source ) {
		if ( source.style.fontStyle == 'italic' || source.style.fontStyle == null) {
			source.style.fontStyle = 'normal' ;
			source.title = 'click to collapse' ;
			return 'open' ;
		} else {
			source.style.fontStyle = 'italic' ;
			source.title = 'click to expand' ;
			return 'closed' ;
		}
	}

	cfdump_toggleTarget = function( target, switchToState ) {
		if ( switchToState == 'open' )	target.style.display = '' ;
		else target.style.display = 'none' ;
	}

	// collapse all td elements for queries
	cfdump_toggleRow_qry = function(source) {
		expand = (source.title == "click to collapse") ? "closed" : "open";
		if(document.all) {
			var nbrChildren = source.parentElement.cells.length;
			if(nbrChildren > 1){
				for(i=nbrChildren-1;i>0;i--){
					target = source.parentElement.cells[i];
					cfdump_toggleTarget( target,expand ) ;
					cfdump_toggleSource_qry(source);
				}
			}
			else {
				//target is the right cell
				target = source.parentElement.cells[1];
				cfdump_toggleTarget( target, cfdump_toggleSource( source ) ) ;
			}
		}
		else{
			var target = null;
			var vLen = source.parentNode.childNodes.length;
			for(var i=vLen-1;i>1;i--){
				if(source.parentNode.childNodes[i].nodeType == 1){
					target = source.parentNode.childNodes[i];
					cfdump_toggleTarget( target,expand );
					cfdump_toggleSource_qry(source);
				}
			}
			if(target == null){
				//target is the last cell
				target = source.parentNode.lastChild;
				cfdump_toggleTarget( target, cfdump_toggleSource( source ) ) ;
			}
		}
	}

	cfdump_toggleSource_qry = function(source) {
		if(expand == "closed"){
			source.title = "click to expand";
			source.style.fontStyle = "italic";
		}
		else{
			source.title = "click to collapse";
			source.style.fontStyle = "normal";
		}
	}
</script>

<cffunction name="sortedScope" output="false">
    <cfargument name="scope">
    <cfset retVal = "">
    <cfset keys = structKeyArray(scope)>
    <cfset arraySort(keys, "text")>
    <cfloop index="x" from=1 to="#arrayLen(keys)#">
    	<cfset keyName = keys[x]>
        <cfset retVal = retVal & keyName & "=">
           <cftry>
    		    <cfset keyValue = CFDebugSerializable(scope[keyname])>
    		<cfcatch>
    			<cfset keyValue = "undefined">
           	</cfcatch>
      	    </cftry>
        <cfset retVal = retVal & keyValue & Chr(13) & Chr(10)>
    </cfloop>
    <cfreturn retVal>
</cffunction>
