<!--- 
/**
* ColdFusion custom tag: "wddxAjax" v.1.1
  Enable ajax calls of remote cfc component within ColdFusion. Any kind of data type can be passed and returned from remote function.
  Enahanced debug.
  History:
  1.1 - Added support for multiple remote component
  The tag requires ColdFusion Server 6.0 or more. 
* Code licensed under Creative Commons Attribution-ShareAlike License      
* http://creativecommons.org/licenses/by-sa/2.0/   
* @author		Guido Bellomo (guido.bellomo@bloggers.it - http://guidone.bloggers.it)
* @version		1.0, 2006-01-10
* @param		engineURL				Required.
* @param		ajaxComponent		Required.
* @param		ieOptimization			Optional (default "true").
* @param		useSession				Optional (default "false").
* @param		debug					Optional (default "false").
* @param		className				Optional (default "wddxAjax").
 */
--->

 <!--- Check params --->
<cfif Isdefined("attributes.engineURL")>
	<cfset engineURL = attributes.engineURL>
	<cfif LCase(GetFileFromPath(engineURL)) neq "ajaxgateway.cfm">
		<cfif Right(engineURL,1) neq "/"><cfset engineURL = engineURL & "/"></cfif>
		<cfset engineURL = engineURL & "ajaxGateway.cfm">
	</cfif>
<cfelseif DirectoryExists(ExpandPath("\CustomTags\wddxAjax\wddxAjax"))>
	<cfset engineURL = "/CustomTags/wddxAjax/wddxAjax/ajaxGateway.cfm">
<cfelse>	
	<h1>wddxAjax error</h1>
	<em>engineURL</em> attributes is invalid or <em>./wddxAjax</em> directory is missing.
	<cfabort>	
</cfif> 
<cfparam name="attributes.useSession" default="false">
<cfparam name="attributes.debug" default="false">
<cfparam name="attributes.loginMethod" default="">
<cfparam name="attributes.ajaxComponent" default="">
<cfif attributes.ajaxComponent eq "">
	<h1>wddxAjax error</h1>
	<em>ajaxComponent</em> attributes is invalid.
	<cfabort>
</cfif>
<cfparam name="attributes.className" default="wddxAjax">
<cfparam name="attributes.async" default=true>

<!--- Init --->
 <cfset enginPath = ReplaceNoCase(engineURL,"ajaxgateway.cfm","")>
 
 <!--- Build JS function for ajax calls  --->
<cfif not IsDefined("request.ajaxInit")>
	<cfset request.ajaxInit = true>
	 
	<!--- If not exists, create the structure for coldfusion component <-> classname --->
	<cfif not IsDefined("Application.ajaxComponentSet")>
		<cfset Application.ajaxComponentSet  =StructNew()>
	</cfif>
	<!--- Save this component name with className --->
	<cflock scope="application" timeout="10">
		<cfif NOT structKeyExists(application.ajaxComponentSet,attributes.className)>		
			<cfset Application.ajaxComponentSet[attributes.className] = attributes.ajaxComponent/>
		</cfif>
	</cflock>
	<!--- If not exists, create the structure for login method handler <-> classname --->
	<cfif not IsDefined("Application.ajaxLoginMethodSet")>
		<cfset Application.ajaxLoginMethodSet  =StructNew()>
	</cfif>
	<cfif attributes.loginMethod neq "">
		<cflock scope="application" timeout="10">			
			<cfset Application.ajaxLoginMethodSet[attributes.className] = attributes.loginMethod>
		</cflock>
	</cfif>

	<!--- Include WDDX libraries --->
	<script src="<cfoutput>#enginPath#</cfoutput>wddx.js"></script>	
<!--- 	<script>
	  	function msieversion() {
    	var ua = window.navigator.userAgent
    	var msie = ua.indexOf ( "MSIE " )
		if ( msie > 0 )  return parseInt ( ua.substring ( msie+5, ua.indexOf ( ".", msie ) ) )
	    else return 0          
		};
	  	// Decide which Deserializer file to include (wddxDes.js or wddxDesIE.js)
  		var desFile = (msieversion() >= 4 && window.navigator.platform == 'Win32') ? 'wddxDesIE.js' : 'wddxDes.js';
  		document.write('<script language="JavaScript" src="<cfoutput>#enginPath#</cfoutput>' + desFile + '"><\/SCRIPT>');
	</script> --->
	<script src="/CustomTags/wddxAjax/wddxAjax/wddxDesIE.js"></script><!--- language="JavaScript" --->
	<script src="<cfoutput>#enginPath#</cfoutput>XHConn.js"></script>	
	<script language="javascript">
		function <cfoutput>#attributes.className#</cfoutput>() {		
			var myConn = new XHConn( <cfoutput>#(attributes.async ? true : false)#</cfoutput> );
			var callBack = null;
			var useSession = <cfoutput>#attributes.useSession#</cfoutput>;
			var debugMode = <cfoutput>#attributes.debug#</cfoutput>;
			var className = '<cfoutput>#attributes.className#</cfoutput>';
			
			this.ajaxResponse = function (oXML) {  
				if (oXML.responseText != '') {
					var Des = new WddxDeserializer();
					Des.defaultVarCase = "lower";
					evalued = Des.deserialize(oXML.responseText); 
					if (evalued == null || evalued.result == null)  {
						alert('ajaxGateway error:\nInternal component error ');
						document.write(oXML.responseText);
						}
					else 
					try {
						// Verifica che non ci sia un errore					
						if (evalued.errormessage != '') alert ('ajaxGateway error:\n' + evalued.errormessage.replace(/<br>/g,'\n'));
						// Oggetto risposta del metodo
						resultObject = evalued.result;
						callBack(resultObject);
						}
					catch(e)
						{	
						alert('ajaxGateway error:\nError in response function' );			
						}					
					}
				};
				
		this.ajaxCall = function(method,param,callback) {
			var callURL = '<cfoutput>#engineURL#</cfoutput>';
			var ajaxParameters = '';
			var wddxParam = '';
			var Ses = new WddxSerializer();
			// if use session, build url for retrieve session on ajaxEngine
			if (useSession) {
				var cfid = readCookie('CFID');
				var cftoken = readCookie('CFTOKEN');
				callURL += '?CFID=' + cfid + '&CFTOKEN=' + cftoken;
				}
			// Init
			callBack = callback;			
			ajaxParameters = 'method=' + method;
			ajaxParameters += '&param=' + Ses.serialize(param);
			if (debugMode) ajaxParameters += '&debug=true';
			// HttpRequest
			myConn.connect(callURL, "POST", ajaxParameters, this.ajaxResponse);
			}

		this.call = function(method,callback) {
			var callURL = '<cfoutput>#engineURL#</cfoutput>';
			var ajaxParameters = '';
			var wddxParam = '';
			var params = new Array();
			// Copy params in array
			if (arguments.length > 2) for (i = 2; i < arguments.length; i++) params.push(arguments[i]);
			var Ses = new WddxSerializer();
			// if use session, build url for retrieve session on ajaxEngine
			if (useSession) {
				var cfid = readCookie('CFID');
				var cftoken = readCookie('CFTOKEN');
				callURL += '?CFID=' + cfid + '&CFTOKEN=' + cftoken;
				}
			// Init
			callBack = callback;			
			ajaxParameters = 'method=' + method+'&version=2&className='+className;
			ajaxParameters += '&param=' + Ses.serialize(params);
			if (debugMode) ajaxParameters += '&debug=true';
			// HttpRequest
			myConn.connect(callURL, "POST", ajaxParameters, this.ajaxResponse);
			}			
		function writeCookie(name, value, hours) {
			var expire = "";
		  	if(hours != null) {
				expire = new Date((new Date()).getTime() + hours * 3600000);
				expire = "; expires=" + expire.toGMTString();
				}
			document.cookie = name + "=" + escape(value) + expire;
			}
		function readCookie(name) {
			var cookieValue = "";
			var search = name + "=";
			if(document.cookie.length > 0) { 
				offset = document.cookie.indexOf(search);
				if (offset != -1) { 
				  offset += search.length;
				  end = document.cookie.indexOf(";", offset);
				  if (end == -1) end = document.cookie.length;
				  cookieValue = unescape(document.cookie.substring(offset, end))
				}
			  }
			  return cookieValue;
			}							
			return this;
			}
		Ajax = <cfoutput>#attributes.className#</cfoutput>; // For compatibility
	</script> 		
 </cfif>
