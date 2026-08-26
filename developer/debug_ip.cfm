<!doctype html>
<html>
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="description" content="">
        <meta name="viewport" content="width=device-width, initial-scale=1">
		<title>Debugging IP Addresses | Developer Tools</title>
		<cfsavecontent variable="head_content">
        <link rel="stylesheet" type="text/css" href="https://cdn.awayx.com/base/common_files/main_style.css">
		<style>
			ul { font-size:1.25em; }
			li { height:26px; width:130px; font-size:14px; padding:10px 0 0 10px; -ms-filter:"progid:DXImageTransform.Microsoft.Alpha(Opacity=85)"; opacity:0.85; letter-spacing:0.5px; }
			li:hover { cursor:pointer; background:#D3CAE5; color:blue; -ms-filter:"progid:DXImageTransform.Microsoft.Alpha(Opacity=100)"; opacity:1;}
			p { font-size:13px; }
			.ip { font-size:14px; font-weight:bold; color:green; letter-spacing:0.75px; }
			.btn-secondary { color: #fff; background-color: #CB384A; margin2:0 50px 0 0;}
		</style>
		</cfsavecontent>
		<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
		<cfhtmlhead text="#head_content#">
    </head>
    <body>
    	<cfif not structkeyExists(url, "external_ip")>
			<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
			<script>
    		$.getJSON("http://jsonip.com/?callback=?", function (data) {
        		//alert(data.ip);
        		window.location.href = window.location.href + "?external_ip=" + data.ip;
    		});
			</script>
		<cfelse>
			<cfscript>
				factory  = createObject("java","coldfusion.server.ServiceFactory");
				debugger = factory.getDebuggingService();
				IP_List  = debugger.getIpList();
				IP_List  = listToArray(IP_List.iplist);
				arraySort(IP_List, "text");
			</cfscript>
			<h2 class="shadow secondary">Debugging IP Addresses</h2>
			<hr class="four">
			<cfoutput><p>NOTE - Your external IP address is <span class="ip shadow">#url.external_ip#</span></p></cfoutput>
			<ul>
				<cfloop from="1" to="#arrayLen(IP_List)#" index="i">
					<cfoutput><li>#IP_List[i]#</li></cfoutput>
				</cfloop>
			</ul>
			<button class="btn btn-primary" onclick="window.close();">close window</button>
    	</cfif>
    </body>
</html>
