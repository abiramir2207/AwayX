<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Billback</TITLE>
	<SCRIPT language="JavaScript" src="/script/javascript/string_functions.min.js"></SCRIPT>
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<STYLE>
	input,textarea
		{
			font-size:	12px;
								
		}
</STYLE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is the Route create page  																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<CFSWITCH expression="#Route_Document_Type#">
	<CFCASE value="1">
		<cfquery name="Get_Billback_Info" datasource="#application.datasource#">
		SELECT	  	BB_Code, 
					BB_Title, 
					BB_Creator_User_Position_ID, 
					BB_Amount,
					BB_Start_Date,
					BB_End_Date
		FROM		Billback
		WHERE
		Billback.Deleted = 0
		AND
		Billback.Billback_ID = '#Document_ID#'
		</cfquery>
		
		<CFSET Billback_Payable_Number=Get_Billback_Info.BB_Code>
		<CFSET Billback_Billback_Title=Get_Billback_Info.BB_Title>

		<CFSET Route_Document_Name					=	"Billback">
		<CFSET Route_Document_ID					=	Document_ID>
		<CFSET Route_Document_Type					=	Route_Document_Type>
		<CFSET Route_Document_Number				=	Get_Billback_Info.BB_Code>
		<CFSET Route_Document_Title					=	Get_Billback_Info.BB_Title & " :: Delivery Period " & Dateformat(Get_Billback_Info.BB_Start_Date,"mm/dd/yyyy") & " To " & Dateformat(Get_Billback_Info.BB_End_Date,"mm/dd/yyyy") & " :: Billback Amount " & dollarformat(Get_Billback_Info.BB_Amount)>
	</CFCASE>
	<CFDEFAULTCASE>
		<CFABORT>
	</CFDEFAULTCASE>
</CFSWITCH>

<SCRIPT>
	 function add_Recipients(bType,thisObj)
	 {
	 	var emailObj = thisObj.form.Internal_EmailS;
		var sourceObj = thisObj.form.User_Email_Address;
		var idObj = thisObj.form.Internal_Recipient_Email_Address;
		
		var user_ID = "";
		var user_Email = "";
		
		var pipePos = 0;
		var thisVal = "";
		
		if(bType == 0)
		{
			if(sourceObj.selectedIndex > -1)
			{
				thisVal = sourceObj.value;
				pipePos = thisVal.indexOf('|');
				user_ID = thisVal.substring(0,pipePos);
				user_Email = thisVal.substring(pipePos+1, thisVal.length);
				addThisEmail(idObj,user_ID,emailObj,user_Email,sourceObj.options[sourceObj.selectedIndex].text,true);
			}
		}
		else if(bType == -1)
		{
			for(var i=0;i<sourceObj.options.length;i++)
			{
				thisVal = sourceObj.options[i].value;
				pipePos = thisVal.indexOf('|');
				user_ID = thisVal.substring(0,pipePos);
				user_Email = thisVal.substring(pipePos+1, thisVal.length);
				addThisEmail(idObj, user_ID, emailObj, user_Email, sourceObj.options[i].text, false);
			}
		}
	 }
	 
	 function delete_Recipients(bType,thisObj)
	 {
	 	var emailObj = thisObj.form.Internal_EmailS;
		var sourceObj = thisObj.form.User_Email_Address;
		var idObj = thisObj.form.Internal_Recipient_Email_Address;
		
		var user_ID = "";
		var user_Email = "";
		var oObj;
	 	if(bType == 0)
		{
			if(emailObj.selectedIndex > -1)
			{
				oObj = emailObj.options[emailObj.selectedIndex];
				user_ID = oObj.value;			
				user_Email = oObj.text;
				deleteThisEmail(idObj, user_ID, emailObj, emailObj.selectedIndex);
			}
		}
		else if(bType == -1)
		{
			if(window.confirm("Do you want to delete all the internal recepients?"))
			{
				for(var i=emailObj.options.length-1;i>=0;i--)
				{
					oObj = emailObj.options[i];
					user_ID = oObj.value;			
					user_Email = oObj.text;
					deleteThisEmail(idObj, user_ID, emailObj, i);				
				}
			}
		}
	 }
	 
	function deleteThisEmail(idObj,id,emailObj,eIndex)
	{
		emailObj.remove(eIndex);
		var idVal = idObj.value;
		var re = new RegExp(";"+id,"ig");
		
		idObj.value = idVal.replace(re, "");
	}
	
	 
	function addThisEmail(idObj,id,emailObj,val,uName,bAlert)
	{
		var eVal = emailObj.value;
		var idVal = idObj.value;
		var re = new RegExp(id,"ig");
		
			  	if(re.test(idVal))
		{
			if(bAlert)
			{
				alert(uName + " already exist");
			}
		}
		else
		{  
			idObj.value = idObj.value + ";" + id;
			if(idVal.length > 0)
			{
				addToSelect(emailObj, id , val);
			}
			else
			{				
				addToSelect(emailObj, id , val);
			}
		}
	}
	
	
	function addToSelect(sObj,sVal,sText)
	{
		var oOption = document.createElement("OPTION");
		oOption.text = sText;
		oOption.value = sVal;
		sObj.add(oOption);
	}
	
	function checklength(maxLen, thisObj)
	{
		var bStop = 0;
		var clipBoardText = "";
		switch(event.type.toLowerCase())
		{
			case "paste":
				if(window.clipboardData)
				{
					clipBoardText = window.clipboardData.getData("Text");
				}
				
				if(thisObj.value.length >= maxLen)
				{
					bStop = 1;
				}
				else if((thisObj.value.length + clipBoardText.length) >= maxLen)
				{
					 bStop = 2;
				}
			case "keypress":
				if(thisObj.value.length >= maxLen)
				{
					bStop = 1;
				}
				break;			
		}
		
		
		if(bStop == 2)
		{
			var fieldValue = thisObj.value + clipBoardText;
			fieldValue = fieldValue.substr(0, maxLen);
			
			var lastColon = fieldValue.lastIndexOf(";");
			if(lastColon > 0)
			{
				fieldValue = fieldValue.substring(0, lastColon);
			}
			thisObj.value = fieldValue;
		}
		
		if(bStop == 0)
		{
			return true;
		}
		else
		{
			window.event.returnValue = false;
			window.event.cancelBubble = true;
			return false;			
		}
	}

	function validateForm(thisForm)
	{
		var bErr = false;
		if(thisForm.Message_Body.value.length == 0)
		{
			queueMessage("Message Body cannot be empty", document.all.ERR_MSG_BODY);
			bErr = true;
		}
		else
		{
			clearQueue(document.all.ERR_MSG_BODY);
		}
		
  	//var recipients = combineEmails(document.all.Internal_Recipient_Email_Address.value, document.all.Internal_Recipient_Email_Address_2.value);  /*25704*/
	//ChromeFix
	<cfif application.appSettingsGet.External_Contacts_Option eq 0>
		var recipients_2 = jQuery('input[name=Internal_Recipient_Email_Address_2]').val();
    <cfelse>
	    var recipients_2 = jQuery('textarea[name=Internal_Recipient_Email_Address_2]').val();
	</cfif>
	var recipients = combineEmails(jQuery("textarea[name=Internal_Recipient_Email_Address]").val(),recipients_2); //ChromeFix
    if ( recipients.length == 0 ) {
			bErr = true;
  		queueMessage("Please enter at least one email address", document.all.error_Internal_Recipient_Email_Address);
  	}
  	else {
  		clearQueue(document.all.error_Internal_Recipient_Email_Address);
  	}
		
		if(bErr)
		{
			showMessageWindow();
			return  false;
		}
		else
		{
      // hide email recipient input
    	//document.all.Internal_Recipient_Email_Address.style.visibility = 'hidden';
  		// combine int email recipients & ext email recipients
    	//document.all.Internal_Recipient_Email_Address.value = recipients;//ChromeFix
		jQuery("textarea[name=Internal_Recipient_Email_Address]").hide().val(recipients);
			thisForm.submit();
			return true;
		}
	}	
</SCRIPT>
<CF_MessageWindow>
<BR>
<FORM ACTION="/Route/Send_Route_Message.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
<BLOCKQUOTE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT><SPAN CLASS="title2">Message From #Route_Document_Name# #Route_Document_Number#</SPAN></CFOUTPUT>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
<TR>
	<TD ALIGN="right" WIDTH="150"><B>Date:&nbsp;&nbsp;</B></TD>
	<TD><INPUT TYPE="text" NAME="SenderDate" SIZE="30" VALUE="#dateformat(now(), 'mmmmm d, yyyy')#" STYLE="width: 250px;border: 1px none ##000000;" READONLY></TD>
	<!--- <TD ROWSPAN="100%"><IMG SRC="/images/email.gif"></TD> --->
</TR>
<TR>
	<TD ALIGN="right"><B>From:&nbsp;&nbsp;</B></TD>
	<TD><INPUT TYPE="text" NAME="SenderAddress" SIZE="30" VALUE="#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last#" STYLE="width: 250px;border: 1px none ##000000;" READONLY></TD>
</TR>
<TR>
	<TD ALIGN="right"><B>Subject:&nbsp;&nbsp;</B></TD>
	<TD><INPUT TYPE="text" NAME="SenderSubject" SIZE="50" STYLE="width:500px;" VALUE="#Left("#Route_Document_Name# #Route_Document_Number# - #Route_Document_Title#", 255)#" maxlength="255"></TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="TOP"><SPAN ID="ERR_MSG_BODY"></SPAN>&nbsp;<B>Message Body:&nbsp;&nbsp;</B></TD>
	<TD><TEXTAREA NAME="Message_Body" COLS="75" ROWS="5" STYLE="width:500px;" onPaste="javaScript: return checklength(4000, this);" onkeyPress="javaScript: return checklength(4000, this);"></TEXTAREA></TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="TOP">&nbsp;</TD>
	<TD><INPUT TYPE="CHECKBOX" NAME="Notify_Recipient" VALUE="1" checked><B>Notify Recipient</TD>
</TR>
</TABLE>
</CFOUTPUT>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!------
<SPAN CLASS="title2">Recipients</SPAN>
----->
<HR COLOR="Orange">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif not appSettings.getBBRestrictRouteUserList()>
	<cfset intUserIDList = "">
<cfelse>
	<cfset bbPositionId = Get_Billback_Info.BB_Creator_User_Position_ID />
	<cfset lPositionsAbove = CreateObject("component", "components.geography.position").getPositionsAbove(bbPositionId, 1) /> 
	<CFQUERY DATASOURCE="#application.datasource#" NAME="Get_Users">
    Select  DISTINCT _Users.User_ID
      From  _Users
            INNER JOIN Profiles ON Profiles.Profiles_ID = _Users.Profiles_ID
            INNER JOIN User_Position_Holders ON User_Position_Holders.Deleted = 0 AND User_Position_Holders.User_ID = _Users.User_ID
            INNER JOIN User_Positions ON  User_Positions.User_Positions_ID = User_Position_Holders.User_Positions_ID
                                          AND User_Positions.User_Positions_ID IN (#PreserveSingleQuotes(lPositionsAbove)#)
     Where  _Users.User_Email <>'' AND  _Users.Deleted=0
	</CFQUERY>
	<cfset intUserIDList = QuotedValueList(Get_Users.User_ID)>
</cfif>


<!---
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>

	<TD ALIGN="right" WIDTH="150" VALIGN="TOP"><SPAN ID="ERR_RECIPIENT"></SPAN>&nbsp;<B>Recipients:&nbsp;&nbsp;</B></TD>
	<TD NOWRAP VALIGN="CENTER" ALIGN="CENTER">
	<TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0">
		<TR>
			<TD ROWSPAN="2">
			<!------<TEXTAREA NAME="Internal_EmailS" COLS="55" ROWS="9" STYLE="width:280px;" READONLY></TEXTAREA>----->
			<SELECT NAME="Internal_EmailS" STYLE="WIDTH:230" SIZE="9">
			</SELECT>
			&nbsp;
			</TD>
			<TD>
			<INPUT TYPE="BUTTON" STYLE="width:20px;" VALUE="<<" onClick="javaScript: add_Recipients(-1,this)"><BR><BR>
			<INPUT TYPE="BUTTON" STYLE="width:20px;" VALUE="<" onClick="javaScript: add_Recipients(0,this)" NAME="AddEmailButton"><BR><BR>	
			<INPUT TYPE="BUTTON" STYLE="width:20px;" VALUE=">" onClick="javaScript: delete_Recipients(0,this)"><BR><BR>
			<INPUT TYPE="BUTTON" STYLE="width:20px;" VALUE=">>" onClick="javaScript: delete_Recipients(-1,this)">
			</TD>
			<TD ROWSPAN="2">
			&nbsp;
			<SELECT NAME="User_Email_Address" STYLE="WIDTH:230" SIZE="9" ONDBLCLICK="document.all.AddEmailButton.click();">
				<CFOUTPUT QUERY="Get_Users">
					<OPTION TITLE="#User_Code#" VALUE="#User_ID#|#User_Code#">#Full_Name# (#Profiles_Desc#)<!----#RepeatString("&nbsp;",5)#(#User_Code#)----></OPTION>
				</CFOUTPUT>		
			</SELECT>
			<TEXTAREA NAME="Internal_Recipient_Email_Address" STYLE="WIDTH:200;DISPLAY:NONE" SIZE="5"></TEXTAREA>
			</TD>
		</TR>
	</TABLE>
	
	
	
	</TD>
</TR>
</TABLE>
--->

<cf_emailRecipient
    intEmails_name    = "Internal_Recipient_Email_Address"  
    intEmails_userIDs = #intUserIDList#
    company_codes     = ""  >
<BR>








<CFOUTPUT>
<INPUT NAME="Document_ID" TYPE="hidden" VALUE="#Route_Document_ID#">
<INPUT NAME="Document_Type" TYPE="hidden" VALUE="#Route_Document_Type#">
<INPUT NAME="RedirectURL" TYPE="hidden" VALUE="#RedirectURL#">
</CFOUTPUT>
<TABLE ALIGN="CENTER">
	<TR>
		<TD ALIGN="CENTER">
			<CF_button
				button_name		=	""
				button_caption	=	"send message"
				button_action	=	"validateForm(document.MyForm);"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"Click here to send..."
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold">
		</TD>
	</TR>
</TABLE>
 </BLOCKQUOTE>
</FORM>

</BODY>
</HTML>

 