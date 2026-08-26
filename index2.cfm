
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- detect if the user agent is from safari but NOT from chrome ----------------------------- --->
<!--- Dev Note: KAL; 10/10/2012; D34349#: SSO login from iPad for dashboards  --->
<!--- Commented this code so the regular forge login page displays.
<CFIF FindNoCase('safari','#CGI.HTTP_USER_AGENT#') GREATER THAN 0 AND FindNoCase('Chrome','#CGI.HTTP_USER_AGENT#') LESS THAN 1>
  <CFSET browser = 'Safari'>
  <cfinclude template="index2_for_safari.cfm">
  <cfabort>
</CFIF>
 --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->

<cfheader name="Cache-Control" value="no-store">
<cfheader name="pragma" value="no-cache">
<cfparam name="error" default="">
<cfparam name="url.closewindow" default="N0">
<cfparam name="url.id" default="">
<cfparam name="form.id" default="">
<cfif isDefined("url.id") and Len(url.id)>
  <cfset form.id = EncodeForHTMLAttribute(url.id)/>
</cfif>

<cfif url.closewindow EQ "yes">
  <script>
    window.close();
  </script>
  <cfabort>
</cfif>
<cfquery name="qGetCustKey" datasource="#application.datasource#">
  select customer_keyword from customer_settings
</cfquery>
<cfquery name="GetSingleSignOnInfo" datasource="#application.datasource#">
  SELECT SingleSign_On, SSL_On
  FROM _application_settings
</cfquery>

<cfif GetSingleSignOnInfo.SingleSign_On EQ 0 AND NOT isdefined("session.AccessStructureExternal")>
  <!--- ColdFusion 2018+ blocks <cfcookie> from directly clearing the reserved
        CFID/CFTOKEN cookie names (this code predates that restriction, see
        the 2012 dev note above) -- guarded so it degrades gracefully on
        modern CF instead of hard-failing the whole page. --->
  <cftry>
    <cfcookie name="CFID" expires="now" domain=".awayx.com">
    <cfcookie name="CFTOKEN" expires="now" domain=".awayx.com">
    <cfcookie name="CFID" expires="now" >
    <cfcookie name="CFTOKEN" expires="now" >
    <cfcatch type="any"></cfcatch>
  </cftry>
</cfif>

<cfset isHttps = false>

<cfif CGI.SERVER_NAME EQ "BSA.blacksmithapps.com" or CGI.SERVER_NAME EQ "BSA.awayx.com">
  <cfset isHttps = true>
</cfif>

<cfif GetSingleSignOnInfo.SSL_On IS 1>
  <cfset isHttps = true>
</cfif>

<!--- The two checks above only recognize specific hardcoded production
      hostnames or a DB flag as "HTTPS" -- neither reflects the actual
      request scheme, so any other host reached over HTTPS (e.g. local dev)
      falls through to false and setFormAction() emits a plain http:// form
      action, which browsers block as mixed content from an https:// page.
      CGI.SERVER_PORT_SECURE is the standard CGI variable for this. --->
<cfif CGI.SERVER_PORT_SECURE EQ "1">
  <cfset isHttps = true>
</cfif>

<!--- SSO variables --->
<cfif (GetSingleSignOnInfo.SingleSign_On EQ 1 and isdefined("CGI.HTTP_SMUSER") and CGI.HTTP_SMUSER NEQ "")>
  <!--- PACTIV  SSO --->
  <cfset LogonId = CGI.HTTP_SMUSER />
<cfelseif (GetSingleSignOnInfo.SingleSign_On EQ 2
			and isdefined("CGI.HTTP_UPN") and CGI.HTTP_UPN NEQ ""
         	and isdefined("CGI.HTTP_EMAILADDRESS") and CGI.HTTP_EMAILADDRESS NEQ "") >
  <!--- SSO ADFS--->
  <cfset LogonId = CGI.HTTP_UPN />
  <cfset LogonEmail = CGI.HTTP_EMAILADDRESS />
</cfif>

<!--- SSO ON [PACTIV/ADFS] --->
<cfif GetSingleSignOnInfo.SingleSign_On and isdefined("LogonId") >
  <!--- <cfset LogonId ="gvegulla1"> --->
  <cfparam name="form.token" default="">
  <cfinclude template="/Common_Files/inc_login_form.cfm">
  <cfinclude template="enter.cfm">
<cfelse> <!--- login form --->
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
  <html>
    <head>
      <title><cfoutput>#application.CompanyName#</cfoutput></title>
      <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
      <meta name="robots" content="noindex">
	  <style>

		.header_right{
			height:98px;
			/* width:606px; */
			width: 500px;
			/* border-bottom: 1px solid #990509; */
			border-bottom: 2px solid var(--clr-mystic);
			margin-inline-start:auto;
			margin-inline-end:auto;
			padding-bottom: 10px;

			display: flex;
            justify-content: end;
            align-items: end;
		}
	  </style>
    </head>

    <cfparam name="error" default="">
    <body onload="checkVersion();" bgcolor="#ffffff" text="black" link="blue" vlink="blue" alink="red" leftmargin="0" topmargin="0" marginwidth=0 marginheight=0>

      <cfset appSettings = application.appSettingsGet>
      <cfif appSettings.getDisableAutoLogIn()>
        <cfset frmKey = DateFormat(now(),"ddmmyyyy")&"_"&timeformat(now(),"hhmmss")>
      <cfelse>
        <cfset frmKey = 0>
      </cfif>

      <script type="text/javascript">
        function Is (){
          var checkFor = "MSIE";
          var MSIEIndex = navigator.appVersion.indexOf(checkFor);
          this.version = parseFloat(navigator.appVersion.substring(MSIEIndex + checkFor.length, (navigator.appVersion.length)));
        }

		 function setOffset()
	   {
			var	tzo = this.getTimeZoneOffSetInUTC();
			var	useDst = this.useDST();

		    document.MyForm.timeZoneOffset.value = tzo;
		    document.MyForm.useDayLightSavingsTime.value = useDst;
		}
 		/* Get the difference in minutes between UTC and the time zone where the user is accessing the application */
	   function getTimeZoneOffSetInUTC()
	   {
		   var today = new Date();
		   var UTCDiff = today.getTimezoneOffset();
		  /*if( this.useDaylightSavingsTime()){
			   UTCDiff = UTCDiff - 60;
		   }*/
		   return UTCDiff;
	   }

	   /* Returns whether the user timezone uses Daylight Savings Time */
	   function useDST(){
		   //crete a winter date and sumer date
		   var bUseDST;
		   var now = new Date();
		   var winter = new Date(now.getFullYear(),01,01);
		   var summer = new Date(now.getFullYear(),07,01);
		   //get offsets
		   var winterOffset = winter.getTimezoneOffset();
		   var summerOffset = summer.getTimezoneOffset();

		   if(winterOffset == summerOffset){
			   bUseDST = false;
		   }
		   else{
			   bUseDST = true;
		   }
		   return bUseDST;
	   }

        function setFormAction(){
          <cfif isHttps>
            <cfoutput>document.MyForm.action = "https://" + location.hostname + "/enter.cfm";</cfoutput>
          <cfelse>
            <cfoutput>document.MyForm.action = "http://" + location.hostname + "/enter.cfm";</cfoutput>
          </cfif>
        }
        function checkVersion(){
	    	var is = new Is();
	    	if(is.version < 5.5)
	          {
	            window.location.href = '/getie.cfm';
	          }
	        else
	          {
	            document.all.bodyText.style.display='';
	            <cfif appSettings.getDisableAutoLogIn()>
	              <cfoutput>document.MyForm.u#frmKey#.focus();</cfoutput>
	            <cfelse>
	              <cfoutput>document.MyForm.User_Code.focus();</cfoutput>
	            </cfif>

	         	setFormAction();
	    		}
	  		setOffset();
        }
       /* function addbookmark(){
          window.external.AddFavorite(location.href, document.title);
        }*/

		function addbookmark()
	 	{
	       	var url = location.href;
	       	var title = document.title;
			if(typeof window.sidebar != 'undefined'){
				window.sidebar.addPanel(title, url, "");
	            } else if(document.all){
	            	window.external.AddFavorite(url, title);
				} else if(window.opera && window.print){
	            	alert('Press ctrl+D to bookmark (Command+D for macs) after you click Ok');
				} else if(window.chrome){
	            	alert('Press ctrl+D to bookmark (Command+D for macs) after you click Ok');
				}
		}
       /* function addssobookmark(){
          var ssoUrl = document.getElementById('ssourl');
          window.external.AddFavorite(ssoUrl, document.title);
        }
		*/
		function addssobookmark()
	 	{
	       	var ssoUrl = document.getElementById('ssourl');
			// var url = location.href;
	       	var title = document.title;
			if(typeof window.sidebar != 'undefined'){
				window.sidebar.addPanel(title, ssoUrl, "");
	            } else if(document.all){
	            	window.external.AddFavorite(ssoUrl, title);
				} else if(window.opera && window.print){
	            	alert('Press ctrl+D to bookmark (Command+D for macs) after you click Ok');
				} else if(window.chrome){
	            	alert('Press ctrl+D to bookmark (Command+D for macs) after you click Ok');
				}
		}
        function setU(){
          <cfoutput>document.MyForm.u.value = document.MyForm.u#frmKey#.value;</cfoutput>
        }
        function setP(pObject,theKey){
          var theString = pObject.value;
          var length  = theString.length;
          if (theKey > 31 && theKey < 128)
          {
            var realkey = String.fromCharCode(theKey)
            <cfoutput>document.MyForm.p.value = document.MyForm.p.value.substr(0,length) + realkey</cfoutput>;
          }
        }
        function maskP(pObject,theKey){
        if (theKey > 31 && theKey < 128)
          {
          var theString = pObject.value;
          var length  = theString.length;
            <cfoutput>document.MyForm.p#frmKey#.value = ''</cfoutput>;
            for (var x = 1; x <= length; x++)
            {
              <cfoutput>document.MyForm.p#frmKey#.value = document.MyForm.p#frmKey#.value + '#chr(248)#'</cfoutput>;
            }
          }
        }
        function finalize(){ <!---//in case the user hit the backspace as the last key prior to submit--->
          <cfoutput>document.MyForm.p.value = document.MyForm.p.value.substr(0,document.MyForm.p#frmKey#.value.length);</cfoutput>
        }
      </script>

      <span id="bodyText">
        <br><br><br>
        <table width=784 BORDER=0 cellpadding=0 CELLSPACING=0 align="CENTER"  valign="top">
          <tr>
            <td valign="top">
            </td>
            <td valign="top">
			  <!--- Client Logo --->
              <img src="<cfoutput>#appSettings.getLoginPageLogoPath()#</cfoutput>"  alt=""><br />
			 
            </td>
            <td valign="top">
              <div class="header_right">
				<!--- Telus Logo --->
				<img height="16" src="/images/logon_telus/TELUS_Trade_Promotion_Management_Logo.svg">
			  </div>
			  <p style="color:red; text-align:center;">
                <cfoutput>#EncodeForHTML(application.util.string.stripHTML(error))#</cfoutput>
              </p>
              <form action="index2.cfm" method="post" name="MyForm" id="MyForm" <cfif appSettings.getDisableAutoLogIn()>autocomplete="OFF"  onSubmit="finalize();"</cfif>>
                <table border="0" cellspacing="0" cellpadding="6" align="center" width="500" >
                  <tr>
                    <td align="right">
						<font size="+1" FACE="Arial, Helvetica, sans-serif" color="#2C2E30">User Code</font>
						<!--- <font size="+1" FACE="Arial, Helvetica, sans-serif" color="#990000">User Code</font> --->
                    </td>
                    <td align="left">
                      <cfif appSettings.getDisableAutoLogIn()>
                        <input type="Text" onChange="setU();" name="u<cfoutput>#frmKey#</cfoutput>" size="13" maxlength="50" class="input_textbox_input">
                      <cfelse>
                        <input type="Text" name="User_Code" size="13" maxlength="50" class="input_textbox_input">
                      </cfif>
                    </td>
                    <td>&nbsp;</td>
                  </tr>
                  <tr>
                    <td align="right">
						<font size="+1" FACE="Arial, Helvetica, sans-serif" color="#2C2E30">Password</font>
						<!--- <font size="+1" FACE="Arial, Helvetica, sans-serif" color="#990000">Password</font> --->
                    </td>
                    <td align="left">
                      <cfif appSettings.getDisableAutoLogIn()>
                        <cfoutput><input type="password" onKeyPress="setP(this,window.event.keyCode);" onKeyUp="maskP(this,window.event.keyCode);" name="p#frmKey#" size="13" class="input_textbox_input"></cfoutput>
                      <cfelse>
                        <input type="password" name="User_Password" size="13" class="input_textbox_input">
                      </cfif>
                    </td>
                    <td>&nbsp;</td>
                  </tr>
                  <tr>
                    <td align="right"></td>
                    <td valign="top">
                      <a href="javascript:addbookmark()"><img src="/Images/POSITION_TREE/folder-closed.gif" border="0"></a>&nbsp;&nbsp;
                      <font size="2" FACE="Arial, Helvetica, sans-serif" color="#2C2E30">Bookmark Application</font>
                    </td>
                    <td></td>
                  </tr>
                  <tr>
                    <td align="right"></td>
                    <td><input type="image" name="Button" src="/Images/Logon_Blacksmith/logon.gif"></td>
                    <td>&nbsp;</td>
                  </tr>
                  <!--- D25717: KAL 06/10/2012: Single Sign On --->
                  <cfif GetSingleSignOnInfo.SingleSign_On EQ 2>
                  <tr>
                    <td class="sso" align="right">&nbsp;</td>
                    <td class="sso">
                      <a id="ssourl" href="/Shibboleth.sso/Login?entityID=http://ssologin.stage.awayx.com/adfs/services/trust&target=https://<CFOUTPUT>#CGI.HTTP_HOST#</CFOUTPUT>/index2.cfm">
                        <img border="0" src="/Images/Logon_Blacksmith/sso_logon.gif"/>
                      </a>
                    </td>
                    <td class="sso">&nbsp;</td>
                  </tr>
                  <tr>
                    <td align="right"></td>
                    <td valign="top">
                      <a href="javascript:addssobookmark()"><img src="/Images/POSITION_TREE/folder-closed.gif" border="0"></a>&nbsp;&nbsp;
                      <font size="2" FACE="Arial, Helvetica, sans-serif" color="#2C2E30">Bookmark Application</font>
                    </td>
                    <td></td>
                  </tr>
                  </cfif>
                  <tr>
                    <td COLSPAN="3" align="left">
                      <!--- Dev Note: Milan; 10012; 9879 --->
                      <cfif appSettings.getConfidentialityAgreementStatus() eq 0>
                        <cfoutput>#appSettings.getLoginAndPasswordChangeMsg()#</cfoutput>
                      <cfelse>
                        <br/><br/><br/><br/>
                      </cfif>
                      <p><span style="color:#CCCCCC;font-family:Arial,Helvetica,sans-serif;font-size:smaller"><CFINCLUDE TEMPLATE="/includes/copyright.cfm"></span></p>
                      <!--- End Dev Note: Milan; 10012; 9879  --->
                    </td>
                  </tr>
                </table>
                <cfinclude template="/Common_Files/inc_login_form.cfm">
                <cfoutput>
                  <input type="hidden" name="token" value="">
                  <input type="hidden" name="u" value="">
                  <input type="hidden" name="p" value="">
                  <input type="hidden" name="id" value="#EncodeForHTMLAttribute(form.id)#">
                  <input type="hidden" name="frmKey" value="#EncodeForHTMLAttribute(frmKey)#">
		  <input type="hidden" name="timeZoneOffset" value="">
                  <input type="hidden" name="useDayLightSavingsTime" value="">
                </cfoutput>
              </form>
            </td>
          </tr>
          <tr>
            <td>
              <img src="/images/Logon_Blacksmith/index_07.gif" width=38 heigth=104 alt="">
            </td>
            <td align="center">
              <cfif isHttps>
                <cfoutput>
                <script src=https://seal.verisign.com/getseal?host_name=#CGI.HTTP_HOST#&size=S&use_flash=NO&use_transparent=YES&lang=en></script>
                </cfoutput>
              </cfif>
            </td>
            <td align="center">&nbsp;</td>
          </tr>
        </table>
      </span>

    </body>

  </html>
</cfif>