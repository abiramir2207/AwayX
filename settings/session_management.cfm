<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Data Integration</TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" OnLoad="JavaScript: disableActivitySelect(document.MyForm,document.MyForm.Session_Management_Status[0].checked);">
<CFPARAM NAME="URL.pageTitle" DEFAULT="Personal Settings: Phase Queue">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET pagetitle = "SYSTEM ADMINISTRATION: Session Management">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!---Help Files--->
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<p></p>
<cfset useLakebaseForGet_Session_settings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForGet_Session_settings>
	<cftry>
		<cfset Get_Session_settings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Session_settings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Session_settings>
<cfset useLakebaseForGet_Session_Settings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForGet_Session_Settings>
	<cftry>
		<cfset Get_Session_Settings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Session_Settings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Session_Settings>
<CFQUERY NAME="Get_Session_settings" datasource="#application.datasource#" MAXROWS=1>
	SELECT		*
	FROM		General_Settings
</CFQUERY>
</cfif>
</cfif>



<cfset useLakebaseForgetUserName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetUserName>
	<cftry>
		<cfset getUserName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#Get_Session_settings.Session_Expiration_Changed_By#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserName>
<CFQUERY NAME="getUserName" datasource="#application.datasource#">
	SELECT *
	FROM _Users
	WHERE User_ID = '#Get_Session_settings.Session_Expiration_Changed_By#'
</CFQUERY>
</cfif>

<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
<TR>
<TD>
<FONT SIZE="2"><B>This setting was last updated by &nbsp;<CFOUTPUT>#getUserName.Name_First# #getUserName.Name_Last#</CFOUTPUT> on <CFOUTPUT>#dateformat(Get_Session_settings.Session_Expiration_Last_Changed_Date, 'm/d/yyy')#
#timeformat(Get_Session_settings.Session_Expiration_Last_Changed_Date, 'h:mm:ss TT')#</CFOUTPUT></B></FONT>
</TD>
</TR>
</TABLE>


<BR><BR>





Due to security considerations, if there is no browser activity, after a certain amount of time, the user session<BR>
will expire and the user will be forced to login before using the application.
<BR><BR>


<FORM ACTION="session_management_action.cfm" METHOD="post" NAME="MyForm">


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the current setting within the database												 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Session_Settings" datasource="#application.datasource#" MAXROWS="1">
	Select		Session_Expiration_Length
	From		General_Settings
</CFQUERY>
<!--- Dev Note: (WR 74707)
<cfif application.returned_customer_setting.Customer_Keyword eq "smithfield">
	<cfset Get_Session_Settings.Session_Expiration_Length = 0.0416666666667>
</cfif>
 --->
<!--- If the returned value is 1,000,000 it means that the users do not want session expiration --->
<CFIF Get_Session_Settings.Session_Expiration_Length EQ 1000000>
	<CFSET No	=	"Checked">
	<CFSET Yes	=	"">
<CFELSE>
	<CFSET No	=	"">
	<CFSET Yes	=	"Checked">
</CFIF>



<CFOUTPUT>
<TABLE>
<TR>
	<TD><INPUT TYPE="radio" NAME="Session_Management_Status" VALUE="0"#No# onClick="JavaScript: disableActivitySelect(this.form,true);"></TD>
	<TD>No, I do not want the session to expire (not recommended)</TD>
</TR>
<TR>
	<TD>
		<INPUT TYPE="radio" NAME="Session_Management_Status" VALUE="1"#Yes# onClick="JavaScript: disableActivitySelect(this.form,false);">
	</TD>
	<TD>
		Yes, I want the session to expire after
		<SELECT NAME="Inactivity_Period">
			<OPTION VALUE="#evaluate(15/(24*60))#"<CFIF evaluate(15/(24*60)) EQ Get_Session_Settings.Session_Expiration_Length> SELECTED</CFIF>>15 Minutes</OPTION>
			<OPTION VALUE="#evaluate(30/(24*60))#"<CFIF evaluate(30/(24*60)) EQ Get_Session_Settings.Session_Expiration_Length> SELECTED</CFIF>>30 Minutes</OPTION>
			<OPTION VALUE="#evaluate(45/(24*60))#"<CFIF evaluate(45/(24*60)) EQ Get_Session_Settings.Session_Expiration_Length> SELECTED</CFIF>>45 Minutes</OPTION>
			<OPTION VALUE="#evaluate(1/24)#"<CFIF evaluate(1/24) EQ Get_Session_Settings.Session_Expiration_Length> SELECTED</CFIF>>60 Minutes</OPTION>
			<OPTION VALUE="#evaluate(2/24)#"<CFIF evaluate(2/24) EQ Get_Session_Settings.Session_Expiration_Length> SELECTED</CFIF>>2 Hours</OPTION>
			<OPTION VALUE="#evaluate(3/24)#"<CFIF evaluate(3/24) EQ Get_Session_Settings.Session_Expiration_Length> SELECTED</CFIF>>3 Hours</OPTION>
			<OPTION VALUE="#evaluate(4/24)#"<CFIF evaluate(4/24) EQ Get_Session_Settings.Session_Expiration_Length> SELECTED</CFIF>>4 Hours</OPTION>
			<OPTION VALUE="#evaluate(8/24)#"<CFIF evaluate(8/24) EQ Get_Session_Settings.Session_Expiration_Length> SELECTED</CFIF>>8 Hours</OPTION>
			<OPTION VALUE="#evaluate(10/24)#"<CFIF evaluate(10/24) EQ Get_Session_Settings.Session_Expiration_Length> SELECTED</CFIF>>10 Hours</OPTION>
		</SELECT>
	</TD>
</TR>
</TABLE>
</CFOUTPUT>


</FORM>
<BR><BR><BR>


<CF_button
	button_name		=	"MyButton"
	button_caption	=	"save settings"
	button_action	=	"javascript:document.all.MyForm.submit();"
	button_type		=	"link"
	button_width	=	"100"
	button_color	=	"Navy"
	button_tip		=	""
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold">

<SCRIPT LANGUAGE="JavaSCript">
	function disableActivitySelect(thisForm,bDis)
	{
		thisForm.Inactivity_Period.disabled = bDis;
	}
</SCRIPT>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>