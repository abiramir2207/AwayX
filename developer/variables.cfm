<!---
  * ====================================================================================================
  *    @File: /developers/variables.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2018-08-24 13:10:15
  *
  * @Remarks: Display variables
  *
  *
  *
  *
  * ====================================================================================================
--->
<!doctype html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta http-equiv="X-UA-Compatible" content="ie=edge">
	<title>Inspect Variables</title>
	<style>
		div.divider {
			height: 30px;
		}
		nav {
			background-color: rgb(231, 225, 214);
			border-bottom: 1px dotted;
			margin: 5px;
			opacity: .90;
			position: fixed;
			right: 0;
			top: 0;
			z-index: 99;
		}

		ul {
			overflow: auto;
			list-style-type: none;
		}

		li {
			height: 25px;
			float: right;
			margin-right: 0px;
			border-right: 1px solid #aaa;
			padding: 0 30px;
		}

		li:last-child {
			padding-left: 0;
		}

		li:first-child {
			border-right: none;
		}

		h1 {
			text-transform: uppercase;
		}

		li a {
			text-decoration: none;
			color: #ccc;
			font: 15px/1 Helvetica, Verdana, sans-serif;
			text-transform: uppercase;

			-webkit-transition: all 0.5s ease;
			-moz-transition: all 0.5s ease;
			-o-transition: all 0.5s ease;
			-ms-transition: all 0.5s ease;
			transition: all 0.5s ease;
		}

		li a:hover {
			color: #666;
			text-decoration: none;
		}

		li.active a {
			font-weight: bold;
			color: #333;
		}
	</style>
</head>
<body>
	<nav>
		<ul>
			<cfif structKeyExists(url, "server")>
				<li><a href="#server">Server</a></li>
			</cfif>
			<cfif structKeyExists(url, "cookie")>
				<li><a href="#cookies">Cookies</a></li>
			</cfif>
			<cfif structKeyExists(url, "session")>
				<li><a href="#session">Session</a></li>
			</cfif>
			<cfif structKeyExists(url, "request")>
				<li><a href="#request">Request</a></li>
			</cfif>
			<cfif structKeyExists(url, "application")>
				<li><a href="#application">Application</a></li>
			</cfif>
		</ul>
	</nav>

	<cfif structKeyExists(url, "application")>
		<h1 id="application">Application</h1>
        <cfif isDefined("this")>
            <cfdump var="#this#" label="This">
            <br><br>
        </cfif>
		<cfdump var="#application#" top="3" expand="true" keys="5000" showUDfs="false" label="Application">
		<div class="divider"></div>
	</cfif>
	<cfif structKeyExists(url, "request")>
		<h1 id="request">Request</h1>
		<cfdump var="#request#" top="3" expand="true" keys="5000" showUDfs="false" label="Request">
		<div class="divider"></div>
	</cfif>
	<cfif structKeyExists(url, "session")>
		<h1 id="session">Session</h1>
		<cfdump var="#session#">
		<div class="divider"></div>
	</cfif>
	<cfif structKeyExists(url, "cookie")>
		<h1 id="cookies">Cookies</h1>
		<cfdump var="#cookie#" top="3" expand="true" keys="5000" showUDfs="false" label="Cookies">
		<div class="divider"></div>
	</cfif>
	<cfif structKeyExists(url, "server")>
		<h1 id="server">Server</h1>
		<cfscript>
			adminObj = createObject("component", "cfide.adminapi.administrator");
			cf_admin = application.util.query.cf_admin();
			adminObj.login( cf_admin.password, cf_admin.username );
			debugger = createObject("component", "cfide.adminapi.debugging");
			server.log_folder = debugger.getLogProperty("logdirectory");
			server.ip = createObject("java", "java.net.InetAddress").getLocalHost().getHostAddress();
		</cfscript>
		<cfdump var="#server#" top="3" expand="true" keys="5000" showUDfs="false" label="Server">
		<div class="divider"></div>
	</cfif>
</body>
</html>