
<CFSET PageTitle="#application.CompanyName#: encrypt tool">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=31>
<CFINCLUDE TEMPLATE="/help_files/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
 --->

<FORM ACTION="encrypt_tool_action.cfm" METHOD="post">



<B>Please enter the string to be Encrypted:</B><BR><BR>
	<INPUT TYPE="text" NAME="Password_Clear">







	<BR><BR><BR>
	<INPUT TYPE="submit" NAME="View Hash">
	
	<BR><BR><BR>
	
	<CFPARAM NAME="EID" DEFAULT="">
	<CFIF EID NEQ "">
	Encrypted string:<BR>
	<INPUT TYPE="text" NAME="nnnnnnnnnnnn" VALUE="<CFOUTPUT>#EID#</CFOUTPUT>" SIZE="38" READONLY STYLE="font-size:12pt; font-weight:bold; color:red; background:yellow;">
	<CFELSE>
		
</CFIF>
	


	
	
	
</FORM>

