<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>xxxxxxxxxxxxxxxxxxxxxxxxx</TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the user settings from the database to be used by all tabs								 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Settings" datasource="#application.datasource#">
Select		*
From		_Users_Settings
Where		User_ID		=		'#request.AccessStructure.User_ID#'
</CFQUERY>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the date that this setting was updated													 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_This_Date" datasource="#application.datasource#">
Select	Alert_Date_Updated
From	_Users_Settings
Where	User_ID		=		'#request.AccessStructure.User_ID#'
</CFQUERY>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=27>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<FORM ACTION="/settings/alerts_action.cfm" METHOD="post" NAME="MyForm">

<!--- Set the update/save flag that will be passed to the next page --->
<CFIF Get_Settings.recordcount EQ 0>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="0">
<CFELSE>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="1">
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated on <CFOUTPUT>#dateformat(Get_This_Date.Alert_Date_Updated, 'm/d/yyy')# #timeformat(Get_This_Date.Alert_Date_Updated, 'h:mm:ss TT')#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
	<BR>
</CFIF>


<B>
You have the ability to receive via e-mail alerts <BR>informing you of the contracts that are about to
expire within a window that you select.
</B>
<BR>

<script LANGUAGE="JavaScript">
function ToggleBoxes(button_value)
	{
		if(button_value == 0)
			{
				eval(
					document.all.Alert_in_30.disabled						= true, 
					document.all._30days.disabled							= true, 
					document.all._45days.disabled							= true, 
					document.all._60days.disabled							= true, 
					document.all._90days.disabled							= true, 
					document.all.Alert_in_45.disabled						= true, 
					document.all.Alert_in_60.disabled						= true, 
					document.all.Alert_in_90.disabled						= true, 
					//document.all.Alert_Expiration_Message.disabled			= true, 
					jQuery("textarea[name=Alert_Expiration_Message]").disabled	= true, 
					//document.all.Alert_Expiration_Email_Address.disabled	= true,
					jQuery("textarea[name=Alert_Expiration_Email_Address]").disabled	= true, 
					document.all.Send_this_alert.disabled					= true,
					document.all.To_this_email.disabled						= true,
					document.all.MyForm.flag.value						= 0
					)
			}
		else
			{
				eval(
					document.all.Alert_in_30.disabled						= false,
					document.all._30days.disabled							= false,
					document.all._45days.disabled							= false,
					document.all._60days.disabled							= false,
					document.all._90days.disabled							= false,
					document.all.Alert_in_45.disabled						= false,
					document.all.Alert_in_60.disabled						= false,
					document.all.Alert_in_90.disabled						= false,
					//document.all.Alert_Expiration_Message.disabled			= false,
					jQuery("textarea[name=Alert_Expiration_Message]").disabled	= false, 
					//document.all.Alert_Expiration_Email_Address.disabled	= false,
					jQuery("textarea[name=Alert_Expiration_Email_Address]").disabled	= false, 
					document.all.Send_this_alert.disabled					= false,
					document.all.To_this_email.disabled						= false,
					document.all.MyForm.flag.value						= 1
					)
			}
	}
</SCRIPT>

	<INPUT TYPE="radio" VALUE="0" NAME="alert"  ONCLICK="ToggleBoxes(0)" 		<CFIF Get_Settings.recordcount EQ 0>CHECKED</CFIF>>
	<INPUT TYPE="text" NAME="No_Alert" VALUE="Don't alert me if a contract is about to expire." SIZE="40" STYLE="font-size: 12px; font-weight: bold; border: 0; background:FFFFFF;" READONLY>
	
	<BR>

	<INPUT TYPE="radio" NAME="alert"  ONCLICK="ToggleBoxes(1)" VALUE="1" <CFIF Get_Settings.recordcount EQ 1>CHECKED</CFIF>>
	<INPUT TYPE="text" NAME="Yes_Alert" VALUE="Alert me if a contract is about to expire within..." SIZE="45" STYLE="font-size: 12px; font-weight: bold; border: 0; background:FFFFFF;"  READONLY>

<TABLE BORDER="0" CELLPADDING="0">
<TR>
	<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>
	<TD>

	<CFOUTPUT>
		<INPUT TYPE="checkbox" NAME="Alert_in_30" VALUE="1"	<CFIF Get_Settings.Alert_in_30 EQ 1> CHECKED</CFIF> DISABLED>
		<INPUT TYPE="text" NAME="_30days" VALUE="30 Days" SIZE="8" STYLE="font-size: 12px; font-weight: bold; border: 0; background:FFFFFF;" READONLY DISABLED>

		<INPUT TYPE="checkbox" NAME="Alert_in_45" VALUE="1"	<CFIF Get_Settings.Alert_in_45 EQ 1> CHECKED</CFIF>  DISABLED>
		<INPUT TYPE="text" NAME="_45days" VALUE="45 Days" SIZE="8" STYLE="font-size: 12px; font-weight: bold; border: 0; background:FFFFFF;" READONLY DISABLED>

		<INPUT TYPE="checkbox" NAME="Alert_in_60" VALUE="1"	<CFIF Get_Settings.Alert_in_60 EQ 1> CHECKED</CFIF>  DISABLED>
		<INPUT TYPE="text" NAME="_60days" VALUE="60 Days" SIZE="8" STYLE="font-size: 12px; font-weight: bold; border: 0; background:FFFFFF;" READONLY DISABLED>

		<INPUT TYPE="checkbox" NAME="Alert_in_90" VALUE="1"	<CFIF Get_Settings.Alert_in_90 EQ 1> CHECKED</CFIF>    DISABLED>
		<INPUT TYPE="text" NAME="_90days" VALUE="90 Days" SIZE="8" STYLE="font-size: 12px; font-weight: bold; border: 0; background:FFFFFF;" READONLY DISABLED>
	</CFOUTPUT>

	<BR><BR>
	<INPUT TYPE="text" NAME="Send_this_alert" VALUE="Send this alert message..." SIZE="32" STYLE="font-size: 12px; font-weight: bold; border: 0; background:FFFFFF;" READONLY DISABLED>
	<BR>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- If the settings table has email information, use it, otherwise get the default email address	 --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ---> 
	<TEXTAREA COLS="80" ROWS="3" NAME="Alert_Expiration_Message" DISABLED><CFOUTPUT>#Get_Settings.Alert_Expiration_Message#</CFOUTPUT></TEXTAREA>
	<BR>

	<INPUT TYPE="text" NAME="To_this_email" VALUE="To this e-mail address:" SIZE="32" STYLE="font-size: 12px; font-weight: bold; border: 0; background:FFFFFF;" READONLY DISABLED>
	<BR>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- If the settings table has email information, use it, otherwise get the default email address	 --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ---> 
	<TEXTAREA COLS="80" ROWS="3" NAME="Alert_Expiration_Email_Address" DISABLED><CFOUTPUT>#Get_Settings.Alert_Expiration_Email_Address#</CFOUTPUT></TEXTAREA>
	<BR>

	<B>If you need to send alerts to more than one address, enter them separated<BR>
	with a comma (,). How the text wraps within the text box, is purely cosmetic.</B>
	
	<BR>

	<INPUT TYPE="hidden" NAME="flag" VALUE="0">
	<INPUT TYPE="hidden" NAME="Date_Updated" VALUE="<CFOUTPUT>#now()#</CFOUTPUT>">
	<INPUT TYPE="submit" VALUE="Save Preferences...">
	
</TD>
</TR>
</TABLE>
	
</FORM>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



