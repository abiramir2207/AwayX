<!------inc_login_form.cfm----->
<CFPARAM NAME="FORM.token" 	DEFAULT="">
<CFPARAM NAME="URL.token" 	DEFAULT="#FORM.token#">
<CFSET FORM.token = URL.token />
<INPUT TYPE="HIDDEN" NAME="token" VALUE="<CFOUTPUT>#EncodeForHTMLAttribute(URL.token)#</CFOUTPUT>">