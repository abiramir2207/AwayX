<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>data purging</TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFPARAM NAME="URL.pageTitle" DEFAULT="Personal Settings: data purging">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET pagetitle = "SYSTEM ADMINISTRATION: DATA PURGING">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=38>
<CFINCLUDE TEMPLATE="/help_files/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
 --->


<cfparam name="gg" default="">
<CFQUERY NAME="Get_maxSettings" datasource="#application.datasource#">
		Select		max(Purge_Log_Settings_id) as gg
		From		Purge_Log_Settings
		</CFQUERY>
<cfset cont = Get_maxSettings.gg>
<CFQUERY NAME="Get_PreviousSettings" datasource="#application.datasource#">
		Select		* 
		From		Purge_Log_Settings
		where Purge_Log_Settings_id = '#cont#'
		</CFQUERY>

<CFQUERY NAME="Get_Settings" datasource="#application.datasource#">
		Select		*
		From		_Users
		Where		User_ID		=		'#Get_PreviousSettings.User_ID#'
</CFQUERY>

<CFSET fPhase_1_Period="">
<CFSET fPhase_1_Message="">
<CFSET fPhase_1_Email_Address="">
<CFSET fPhase_2_Period="">
<CFSET fPhase_2_Message="">
<CFSET fPhase_2_Email_Address="">



<SCRIPT LANGUAGE="JavaScript">
function verifyData() {
	
	
	//ValidEmail1 = checkMultipleEmail(document.all.Email_Address1); CHROMEFIX
	ValidEmail1 = checkMultipleEmail(jQuery("textarea[name=Email_Address1]").val());
	
	if(ValidEmail1!=true)	
	{
	 	//alert("Invalid Phase 1 E-mail Address '" + ValidEmail1 + "' ! Please re-enter.")		
		queueMessage("Invalid Phase 1 E-mail Address " + ValidEmail1 + " ! Please re-enter.", document.all.error_Email_Address1);
	}
	else
	{
		clearQueue(document.all.error_Email_Address1);
	}

	//ValidEmail2 = checkMultipleEmail(document.all.Email_Address2); CHROMEFIX
	ValidEmail2 = checkMultipleEmail(jQuery("textarea[name=Email_Address2]").val());
	if(ValidEmail2!=true)
	{
		//alert("Invalid Phase 2 E-mail Address '" + ValidEmail2 + "' ! Please re-enter.")
		queueMessage("Invalid Phase 2 E-mail Address " + ValidEmail2 + " ! Please re-enter.", document.all.error_Email_Address2);
	}
	else
	{
		clearQueue(document.all.error_Email_Address2);
	}

	if(ValidEmail1==true && ValidEmail2==true)
	{
		document.MyForm.submit();
		//alert("submit");
	}
	else
	{
		showMessageWindow();
	}
}


function checkEmail(email) {
  if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(email)){
    return (true)
  }
  return (false)
}


function checkMultipleEmail(emailTextBox) 
{
  var separator = ";";
  //var emails2 = emailTextBox.value.split(separator); CHROMEFIX
  var emails2 = emailTextBox.split(separator);
  
  var anyEmail = false;
	for(var i=0; i<emails2.length; i++) 
	{
		//alert("-" + emails2[i] + "-");
		//alert("=" + emails2[i].replace(/(^ )|( $)/g, "") + "=");
    	//emails2[i] = emails2[i].replace(/ /g, ""); //trim spaces
		emails2[i] = emails2[i].replace(/(^ )|( $)/g, ""); //trim spaces
		
    	tempEmail = checkEmail(emails2[i])
		if(!tempEmail) {return emails2[i]} 		
	}
	return true
 }
</script>
<BR><BR>
<CFIF Get_PreviousSettings.recordcount EQ 0>
<CFELSE>
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated By &nbsp;<CFOUTPUT>#Get_Settings.Name_First# #Get_Settings.Name_Last#</CFOUTPUT> on <CFOUTPUT>#dateformat(Get_PreviousSettings.Purge_Settings_Date, 'm/d/yyy')# 
	#timeformat(Get_PreviousSettings.Purge_Settings_Date, 'h:mm:ss TT')#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
	<BR>
	<CFSET fPhase_1_Period=Get_PreviousSettings.Phase_1_Period>
	<CFSET fPhase_1_Message=Get_PreviousSettings.Phase_1_Message>
	<CFSET fPhase_1_Email_Address=Get_PreviousSettings.Phase_1_Email_Address>
	<CFSET fPhase_2_Period=Get_PreviousSettings.Phase_2_Period>
	<CFSET fPhase_2_Message=Get_PreviousSettings.Phase_2_Message>
	<CFSET fPhase_2_Email_Address=Get_PreviousSettings.Phase_2_Email_Address>
</CFIF>

<FORM ACTION="Purge_Settings_Action.cfm" METHOD="post" name="MyForm">

<SPAN CLASS="title2">Phase I</SPAN>
<HR COLOR="Orange">

Expired contracts are eligible for the purging process only if both of the following criteria are satisfied:<BR> [A] there are no unpaid billbacks in the
database associated with the program, and,<BR> [B] all associated deductions in the database have been cleared.<BR>
The first phase of the process moves eligible programs and all associated billbacks and deductions to an &quot;inactive&quot; state. Inactive programs and
all associated data remain in the production database but are not available for viewing or reporting.<BR><BR>

	<B> Set to inactive all records that are expired for more than </B>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<SELECT size="1" name="D1">
			<OPTION VALUE="6" 
			<CFIF fPhase_1_Period EQ "6">
			SELECTED
			</CFIF>
			>6 Months</OPTION>
			<OPTION VALUE="9" 
			<CFIF fPhase_1_Period EQ "9">
			SELECTED
			</CFIF>>9 Months</OPTION>
			<OPTION VALUE="12" 
			<CFIF fPhase_1_Period EQ "12">
			SELECTED
			</CFIF>>12 Months</OPTION>
		</SELECT>	
	<BR>
	<BR>
	<B> Set the Email Message to be alerted with </B>
	<BR>
	<TEXTAREA COLS="80" ROWS="3" NAME="Email_Message1"><CFOUTPUT>#fPhase_1_Message#</CFOUTPUT></TEXTAREA>
	<BR>
	<BR>
	<span id="error_Email_Address1"></span><B> Set the Email Address(s) </B> &nbsp;&nbsp;&nbsp; Separate with <B>( ; )</B> if more then one Email Address
	<BR>
	<TEXTAREA COLS="80" ROWS="2" NAME="Email_Address1"><CFOUTPUT>#fPhase_1_Email_Address#</CFOUTPUT></TEXTAREA>
	<BR>
	<BR>

<SPAN CLASS="title2">Phase II</SPAN>
<HR COLOR="Orange">
The second phase is -- purging -- actually removes the program and all associated billbacks and deductions from the database. An alert will be sent to
the System Administrator 4 weeks in advance to provide an opportunity to capture the data scheduled for purging on a CD, tape, or other alternative
storage method. Once the data has been purged, it can not be rolled back into the production database.The inactive state is an interim step prior to the
actual purge which provide a painless avenue to &quot;roll back&quot; the records should business needs dictate continued access to the data.<BR><BR>

	<br>

    <B> Purge all records that have been inactive for more than </B>
	
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<SELECT size="1" name="D2">
			<OPTION VALUE="6" 
			<CFIF fPhase_2_Period EQ "6">
			SELECTED
			</CFIF>
			>6 Months</OPTION>
			<OPTION VALUE="9" 
			<CFIF fPhase_2_Period EQ "9">
			SELECTED
			</CFIF>>9 Months</OPTION>
			<OPTION VALUE="12" 
			<CFIF fPhase_2_Period EQ "12">
			SELECTED
			</CFIF>>12 Months</OPTION>
		</SELECT>	
	<BR>
	<BR>
	<B> Set the Email Message to be alerted with </B>
	<BR>
	<TEXTAREA COLS="80" ROWS="3" NAME="Email_Message2"><CFOUTPUT>#fPhase_2_Message#</CFOUTPUT></TEXTAREA>
	<BR>
	<BR>
	<span id="error_Email_Address2"></span><B> Set the Email Address(s) </B> &nbsp;&nbsp;&nbsp; Separate with <B>( ; )</B> if more then one Email Address
	<BR>
	<TEXTAREA COLS="80" ROWS="2" NAME="Email_Address2"><CFOUTPUT>#fPhase_2_Email_Address#</CFOUTPUT></TEXTAREA>
	<BR>
	<BR>

<BR><BR>
<INPUT TYPE="hidden" NAME="User_ID" VALUE="<CFOUTPUT>#request.AccessStructure.User_ID#</CFOUTPUT>"> 
 <!----<INPUT TYPE="button" VALUE="Save Settings" onclick="verifyData()"> --->
 <DIV ALIGN="center">
			<CF_BUTTON
			BUTTON_NAME		=	""
			BUTTON_CAPTION	=	"save settings"
			BUTTON_ACTION	=	"javascript:verifyData();"
			BUTTON_TYPE		=	"link"
			BUTTON_WIDTH	=	"150"
			BUTTON_COLOR	=	"Navy"
			BUTTON_TIP		=	""
			FONT_COLOR		=	"White"
			FONT_SIZE		=	"12"
			FONT_WEIGHT		=	"bold">
		</DIV>

</FORM>
<CF_MessageWindow>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>