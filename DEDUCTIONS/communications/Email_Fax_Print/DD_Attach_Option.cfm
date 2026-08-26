<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
  <script type="text/javascript" src="/script/javascript/string_functions.min.js"></script>  <!--25704-->
</head>

<body>

<STYLE>
TABLE.underline TD 
{
	border-bottom:solid #C0C0C0 1px;
}
</STYLE>

<cfset genFunctions = CreateObject("component", "components.Base") />

<CFPARAM NAME="FORM.Form_Submitted" DEFAULT="">

<!--- 
	DEV NOTE: DAA; D16328
	ADDED BECAUSE A CF ERROR WAS POPPING UP LOOKING FOR THIS VARIABLE
	PROBLEM COULD NOT BE REPLICATED IN DEVELOPMENT AND TESTING
 --->
<CFPARAM NAME="URL.FROM" DEFAULT="">
<!--- **** END ****  DEV NOTE: DAA; D16328 --->

<!--- 
	D41185 :: Prod Event 2201
	added because a cf error was popping up looking for  variable DISP
	problem could not be replicated in development and testing
 --->
<CFPARAM NAME="Disp" DEFAULT="">
<CFPARAM NAME="Func" DEFAULT="">
<!---D41185 END --->
<cfquery name="getBillbackIds" datasource="#application.datasource#">
		SELECT 	Billback.Billback_ID, Billback.BB_Title, Billback.BB_Date, Billback.BB_Start_Date, Billback.BB_End_Date, Billback.BB_Amount, Billback.BB_Reference, Billback.BB_Code, Billback.Billback_Status_ID, Billback_Status.BB_Status_Description, ISNull(BB_Approved.Paid_Amount, 0) AS BB_Approved_Amount,
				BB_Approved.Vendor_Master_ID
		FROM Billback
		INNER JOIN Billback_Status ON Billback_Status.Billback_Status_ID = Billback.Billback_Status_ID
		INNER JOIN DD_Closure_Detail ON DD_Closure_Detail.DD_Closure_ID = Billback.Billback_ID AND DD_Closure_Detail.Deleted = 0
		LEFT JOIN BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
		WHERE Deduction_ID = '#URL.Deduction_ID#'
</cfquery>
<cfset useLakebaseForGet_Ded_Details = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForGet_Ded_Details>
<cftry>
<cfset Get_Ded_Details = application.oLakebase.toQuery(
application.oLakebase.selectRows("deductions", {
"deduction_id" = "eq.#URL.Deduction_ID#"
})
)>
<cfcatch type="any">
<cfset useLakebaseForGet_Ded_Details = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Ded_Details><CFQUERY NAME="Get_Ded_Details" DATASOURCE="#Application.Datasource#">
	SELECT <CFIF FORM.Form_Submitted EQ "">Top 1</CFIF>* FROM Deductions WHERE Deduction_ID = '#URL.Deduction_ID#'
</CFQUERY>
</cfif>

<CFQUERY NAME="Have_children" DATASOURCE="#Application.Datasource#">
	SELECT <CFIF FORM.Form_Submitted EQ "">Top 2</CFIF>* FROM Deductions WHERE DD_DedID = '#Get_Ded_Details.DD_DedID#' AND Deleted=0
</CFQUERY>
<CFQUERY NAME="Actions_Taken" DATASOURCE="#application.datasource#">
	SELECT 		<CFIF FORM.Form_Submitted EQ "">
				Top 1
				</CFIF>
				DD_Ded_Actions.*, 
				DD_Stage_Description,
				Name_First,
				Name_Last 
								
	FROM 		DD_Ded_Actions
	INNER JOIN 	DD_Stage ON DD_Stage.DD_Stage_ID = DD_Ded_Actions.DD_Stage_ID
	INNER JOIN	_Users ON _Users.User_ID = DD_Ded_Actions.Completed_By
	
	WHERE 		Deduction_ID = '#Deduction_ID#'
	
	ORDER BY 	DD_Ded_Actions.Date_Completed DESC
</CFQUERY>

<CFQUERY NAME="ListNotes" DATASOURCE="#application.datasource#">
	SELECT 		<CFIF FORM.Form_Submitted EQ "">
				Top 1
				</CFIF>
				DD_Notes.*,
				Name_First,
				Name_Last
				 
	FROM 		DD_Notes	
	INNER JOIN	_Users ON _Users.User_ID = DD_Notes.DD_Note_By
	
	WHERE 		Deduction_ID = '#Deduction_ID#' AND DD_Notes.Deleted = 0		
		
	ORDER BY 	DD_Note_Date DESC
</CFQUERY>

<CFQUERY NAME="GetReminders" DATASOURCE="#Application.Datasource#">
	SELECT 		<CFIF FORM.Form_Submitted EQ "">Top 1</CFIF>* 
	
	FROM 		DD_Reminders	
	INNER JOIN 	DD_Reminder_Type ON DD_Reminder_Type.DD_Reminder_Type_ID = DD_Reminders.DD_Reminder_Type
	
	WHERE 		Deduction_ID = '#Deduction_ID#'
	
	ORDER BY 	DD_Reminders.DD_Reminder_Date ASC
</CFQUERY>



<CFQUERY NAME="Invoice_Detail" DATASOURCE="#application.datasource#">
	SELECT 		<CFIF FORM.Form_Submitted EQ "">Top 1</CFIF>
				Invoice_Header.Invoice_Header_ID, 
				Invoice_Header.Shared_Invoice_Number,
				(Invoice_Header.Invoice_Version + '-' + Invoice_Header.Order_Number) AS Invoice_Number
				
	FROM 		DD_Relationships			
	INNER JOIN 	Invoice_Header ON DD_Relationships.DD_Key_To_Relationship = Invoice_Header.Invoice_Header_ID
				
	WHERE 		DD_Relationship_Type_ID = 3 AND
				Deduction_ID = '#Deduction_ID#'
</CFQUERY>

<CFQUERY NAME="Adjustments_Det" DATASOURCE="#Application.Datasource#">
	SELECT 		<CFIF FORM.Form_Submitted EQ "">Top 1</CFIF>* 
	
	FROM 		DD_Relationships
	INNER JOIN 	BB_Adjustment ON BB_Adjustment.BB_Adjustment_ID = DD_Relationships.DD_Key_to_Relationship
	
	WHERE 		DD_Relationship_Type_ID = 1 AND
				DD_Relationships.Deduction_ID = '#Deduction_ID#'
</CFQUERY>

<CFQUERY NAME="Exclusion_Disp" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT DD_Relationships.DD_Relationship_Type_ID, 
				BB_Program_Exclusion.BB_Program_Exclusion_ID,  
				BB_Program_Exclusion.Date_Applied, 
				(select sum(BB_Product_Exclusion.Dollar_Amount) from BB_Product_Exclusion WHERE BB_Product_Exclusion.BB_Program_Exclusion_ID = DD_Relationships.DD_Key_to_Relationship) AS Exclusion_Amount 
				
	FROM 		DD_Relationships
	INNER JOIN 	BB_Product_Exclusion ON BB_Product_Exclusion.BB_Program_Exclusion_ID = DD_Relationships.DD_Key_to_Relationship
	INNER JOIN 	BB_Program_Exclusion ON BB_Program_Exclusion.BB_Program_Exclusion_ID = DD_Relationships.DD_Key_to_Relationship
	
	WHERE 		DD_Relationship_Type_ID = 2 AND
				DD_Relationships.Deduction_ID = '#Deduction_ID#'
</CFQUERY>

<CFQUERY NAME="GetCalls" DATASOURCE="#Application.Datasource#">
	SELECT 		<CFIF FORM.Form_Submitted EQ "">Top 1</CFIF>* 
	
	FROM 		DD_Call_Log
	INNER JOIN	_Users ON _Users.User_ID = DD_Call_Log.Person_Who_Called
	
	WHERE 		Deduction_ID = '#Deduction_ID#' AND
		 		DD_Call_Log.Deleted = 0
</CFQUERY>

<CFQUERY NAME="GetEmail_Det" DATASOURCE="#Application.Datasource#">
	SELECT 		<CFIF FORM.Form_Submitted EQ "">Top 1</CFIF>
				Message_Log_ID,
				Message_To,
				Message_From,
				Message_Subject,	
				Message_Log.Created_Date,			
				Name_First,
				Name_Last
	
	FROM 		Message_Log 	
	INNER JOIN	_Users On _Users.User_Id = Message_Log.User_Id
	
	WHERE		Message_Type_Id = 1 AND 
				App_Area_ID = 13 AND 
				App_Area_Identifier = '#Deduction_ID#' 
				
	ORDER BY 	Message_Log.Created_Date DESC
</CFQUERY>


<CFQUERY NAME="GetFax_Det" DATASOURCE="#Application.Datasource#">
	SELECT 		<CFIF FORM.Form_Submitted EQ "">Top 1</CFIF>
				Message_Log_ID,
				Message_To,
				Message_From,
				Message_Subject,	
				Message_Log.Created_Date,			
				Name_First,
				Name_Last
	
	FROM 		Message_Log 	
	INNER JOIN	_Users On _Users.User_Id = Message_Log.User_Id
	
	WHERE		Message_Type_Id = 2 AND 
				App_Area_ID = 13 AND 
				App_Area_Identifier = '#Deduction_ID#' 
				
	ORDER BY 	Message_Log.Created_Date DESC
</CFQUERY>


<CFINCLUDE TEMPLATE="/Common_Files/Documents/User_Positions_Under_this_User.cfm">
<CFSET Access_Position_List = GP_Position_List_From_My_Position_Down>

<CFQUERY NAME="mail_Documents" DATASOURCE = "#Application.Datasource#">
	SELECT 		contract_Attachments.doc_id,
				Doc_Uni_Name,
				doc_title,
				Doc_Description,
				Uploaded_Date,
				Uploaded_By,
				Doc_Type,
				Doc_File_Name,
				Doc_Size 

	FROM 		contract_Attachments
	INNER JOIN 	Document_Details ON contract_Attachments.Doc_ID = Document_Details.Doc_ID 				
				AND	(	
						(	Public_View = 1
							AND User_Position_ID IN (#preserveSingleQuotes(Access_Position_List)#)
						) 						
						OR Public_View = 0	
					)
	WHERE 		contract_Attachments.Deduction_ID = '#Deduction_ID#' 
	AND			contract_Attachments.deleted=0
</CFQUERY>


<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/script/javascript/string_validations.js"></SCRIPT>
<!--- <CFDUMP VAR="#URL#"> --->

<!--- <CFDUMP VAR="#URL#"> --->
<CFIF FORM.Form_Submitted EQ "">
<FORM NAME="Comm_Options" ACTION="DD_Attach_Option.cfm?Deduction_ID=<CFOUTPUT>#URL.Deduction_ID#</CFOUTPUT>" METHOD="POST">
<INPUT TYPE="Hidden" NAME="Form_Submitted" VALUE="0">
<CFOUTPUT><INPUT TYPE="Hidden" NAME="Comm_Type" VALUE="#URL.FROM#"></CFOUTPUT>

<CFIF URL.From NEQ "Print">
	<CFINCLUDE Template="Email_Body.cfm">
</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2"><CFIF URL.From NEQ "Print">Pick Attachments<CFELSE>Pick from List</CFIF></SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="100%" CLASS="underline">
	<TR>
		<TD><INPUT TYPE="Checkbox" class="item" NAME="DD_Details" VALUE="1"><B>Deduction Details</B></TD>	
		<TD><INPUT TYPE="CheckBox" class="item" NAME="DD_Notes" VALUE="1" <CFIF ListNotes.recordcount EQ 0>Disabled</CFIF>><B>Notes</B></TD>	
		<TD><INPUT TYPE="CheckBox" class="item" NAME="DD_Adjust" VALUE="1" <CFIF Adjustments_Det.recordcount EQ 0>Disabled</CFIF>><B>Adjustments</B></TD>		
		<TD><INPUT TYPE="CheckBox" class="item" NAME="Email_details" VALUE="1" <CFIF GetEmail_Det.recordcount EQ 0>Disabled</CFIF>><B>Email Log</B></TD>
	</TR>
	<TR  BGCOLOR="C6FFC6">
		<TD><INPUT TYPE="CheckBox" class="item" NAME="Split_Info" VALUE="1" <CFIF Have_children.recordcount EQ 1>Disabled</CFIF>><B>Split Info</B></TD>
		<TD><INPUT TYPE="CheckBox" class="item" NAME="DD_Reminders" VALUE="1" <CFIF GetReminders.recordcount EQ 0>Disabled</CFIF>><B>Reminders</B></TD>
		<TD><INPUT TYPE="CheckBox" class="item" NAME="BB_Details" VALUE="1" <CFIF Get_Ded_Details.DD_Closure_ID EQ "" or Get_Ded_Details.DD_Closure_Type neq 1>Disabled</CFIF>><B>Billback Info</B></TD>
		<TD><INPUT TYPE="CheckBox" class="item" NAME="Fax_Details" VALUE="1" <CFIF GetFax_Det.recordcount EQ 0>Disabled</CFIF>><B>Fax Log</B><!--- <INPUT TYPE="CheckBox" NAME="Print_Info" VALUE="1"><B>Print Info</B> ---></TD>		
	</TR> 
	<TR>
		<TD><INPUT TYPE="CheckBox" class="item" NAME="DD_Actions" VALUE="1" <CFIF Actions_Taken.recordcount EQ 0>Disabled</CFIF>><B>Actions taken</B></TD>
		<TD><INPUT TYPE="CheckBox" class="item" NAME="DD_Exclusion" VALUE="1" <CFIF Exclusion_Disp.recordcount EQ 0>Disabled</CFIF>><B>Exclusions</B></TD>
		<TD><INPUT TYPE="CheckBox" class="item" NAME="Invoice_Info" VALUE="1" <CFIF Invoice_Detail.recordcount EQ 0>Disabled</CFIF>><B>Invoice Info</B></TD>
		<TD><INPUT TYPE="CheckBox" class="item" NAME="CallLog_Info" VALUE="1" <CFIF GetCalls.recordcount EQ 0>Disabled</CFIF>><B>Call Log</B></TD>		
	</TR>		
	
	<tr>
		<td><input type="CheckBox" class="item" name="Rebill_Info" value="1" <cfif Get_Ded_Details.dd_status neq 7>Disabled</cfif>><b>Rebill Info</b></td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>		
</TABLE>


<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="100%" CLASS="underline">
	<CFIF mail_Documents.recordcount GT 0>
	<TR><TD colspan="5" align="center" STYLE="font-size: 11px; font-weight: bold;" >To print attachments, view the document and click print from the browser window</TD></TR>
	<TR >
		<TD BGCOLOR="#ffce84">&nbsp;</TD>
		<TD ID="headed" STYLE="font-size: 11px; font-weight: bold;" BGCOLOR="#ffce84">Date / Name</TD>
		<TD ID="header" STYLE="font-size: 11px; font-weight: bold;" BGCOLOR="#ffce84">File</TD>
		<TD STYLE="font-size: 11px; font-weight: bold;" BGCOLOR="#ffce84">Title / Description</TD>
		<TD STYLE="font-size: 11px; font-weight: bold;" BGCOLOR="#ffce84">Type</TD>
	</TR>
	</CFIF>
		<CFOUTPUT QUERY="Mail_Documents">
		<cfset useLakebaseForget_userName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForget_userName>
<cftry>
<cfset get_userName = application.oLakebase.toQuery(
application.oLakebase.selectRows("_users", {
"select" = "name_first,name_last",
"user_id" = "eq.#Uploaded_By#"
}),
"name_first,name_last"
)>
<cfcatch type="any">
<cfset useLakebaseForget_userName = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForget_userName><CFQUERY NAME="get_userName" DATASOURCE="#Application.Datasource#">
			SELECT 		Name_First,
						Name_Last
			FROM		_users
			WHERE 		User_ID = '#Uploaded_By#'
		</CFQUERY>
</cfif>
		<cfset ShowAttachCheckBox = comparenocase(URL.FROM, "print")/>
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">				
		<TD ALIGN="right"  VALIGN="TOP"><INPUT TYPE="Checkbox" NAME="Doc_ID" VALUE="#Doc_ID#" <CFIF ShowAttachCheckBox EQ 0>disabled</CFIF>>&nbsp;&nbsp;</TD>
		 <TD WIDTH="125" VALIGN="TOP">#dateFormat(Uploaded_Date,"mm/dd/yyyy")#<BR>#get_userName.Name_First# #get_userName.Name_Last#</TD>
		<CFSET SIZEinKB = #Doc_Size#/1024>
		<TD VALIGN="TOP"><A href="javascript: confirmation('#Doc_Uni_Name#');" TITLE="Click here to view '#Doc_File_Name#'">#Doc_File_Name#</A>&nbsp;&nbsp;<br>#numberFormat(SIZEinKB,"_.___")# KB</TD>
		<TD VALIGN="TOP"><FONT COLOR="red">#Doc_Title#</FONT>&nbsp;&nbsp;<br>Description: #Doc_Description#</TD>
		<TD NOWRAP VALIGN="TOP">#Doc_Type#</TD>
		</TR>
	</CFOUTPUT>
</TABLE>

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
	<TR>
		<TD COLSPAN="100%" ALIGN="Center" STYLE="border-bottom:None"><BR>
		<CFIF URL.From EQ "Email">
			<CFSET Disp = "Send Email">
			<CFSET Func = "confirmCompletionEmail()">
		<CFELSEIF URL.From EQ "Fax">
			<CFSET Disp = "Send Fax">
			<CFSET Func = "confirmCompletion()">
		<CFELSEIF URL.From EQ "Print">
			<CFSET Disp = "Print">
			<CFSET Func = "Validate()">
		</CFIF>
			<CF_button
				button_name		=	""
				button_caption	=	"#Disp#"
				button_action	=	"#Func#"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold">
		</TD>
	</TR>
</TABLE>
</FORM>
<CFELSE>

	<CFSET MailParam = "">
	<CFSET PrintList = "">
	<CFSET MailParamDesc = "">
	<cfset PrinterFriendly = 1>
	
	<!--- Deduction details--->
	<CFIF isdefined("FORM.DD_Details")>
		<CFSAVECONTENT VARIABLE="DD_Details_cont">			
			<CFINCLUDE template="/deductions/inc_deduction_details.cfm">
		</CFSAVECONTENT>
		<CFSET DD_Details_cont = genFunctions.stripHTMLTag(DD_Details_cont, "script") />	
		<CFIF FORM.Comm_Type NEQ "Print">
			<CFMODULE template="/CustomTags/Writing_Email_Attachment.cfm"
	  				Naming_Format="Deduction_Details_#Get_Ded_Details.DD_DedID#_#Get_Ded_Details.Sp_Number#"				
					Relative_Path="\Temp_Files\Deduction\"
					Output_Content="#DD_Details_cont#"				
					Return_File_Name="fName">
			<CFSET MailParam = "#MailParam##fName#,">	
			<CFSET MailParamDesc = "#MailParamDesc#Deduction details,">			
		</CFIF>
	</CFIF>
	
	<!--- Split Info --->
	<CFIF Isdefined("FORM.Split_Info")>
		<CFSAVECONTENT VARIABLE="Split_Info_cont">
			<CFINCLUDE Template="/deductions/Split/Split_Result.cfm">
		</CFSAVECONTENT>
		<CFSET Split_Info_cont = genFunctions.stripHTMLTag(Split_Info_cont, "script") />	
		<CFIF FORM.Comm_Type NEQ "Print">
			<CFMODULE template="/CustomTags/Writing_Email_Attachment.cfm"
	  				Naming_Format="Deduction_Split_Info_#Get_Ded_Details.DD_DedID#_#Get_Ded_Details.Sp_Number#"				
					Relative_Path="\Temp_Files\Deduction\"
					Output_Content="#Split_Info_cont#"				
					Return_File_Name="fName">
			<CFSET MailParam = "#MailParam##fName#,">		
			<CFSET MailParamDesc = "#MailParamDesc#Split info,,">	
		</CFIF>
	</CFIF>
	
	<!--- Actions taken --->
	<CFIF Isdefined("FORM.DD_Actions")>
		
		<CFSAVECONTENT VARIABLE="DD_Actions_Cont">
			<CFINCLUDE Template="Inc_Comm_Header.cfm">
			<br>
			<B>COMPLETED ACTIONS</B>
			<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" CLASS="underline">			
				<TR BGCOLOR="FFE083">
					<TD><B>DATE</B></TD>
					<TD WIDTH="10">&nbsp;</TD>
					<TD WIDTH="10"><B>ACTIONS</B></TD>
					<TD>&nbsp;</TD>
					<TD><B>COMPLETED BY</B></TD>
				</TR>
				<CFOUTPUT QUERY="Actions_Taken">
				<TR BGCOLOR="#IIf(currentrow Mod 2,DE('ffffff'), DE('C6FFC6'))#">
					<TD>#DateFormat(Date_Completed,"mm/dd/yyyy")#</TD>
					<TD>&nbsp;</TD>
					<TD>#DD_Stage_Description#</TD>
					<TD>&nbsp;</TD>
					<TD>#Name_First# #Name_Last#</TD>
				</TR>
				</CFOUTPUT>
			</TABLE>
		</CFSAVECONTENT>
		<CFIF FORM.Comm_Type NEQ "Print">
			<CFMODULE template="/CustomTags/Writing_Email_Attachment.cfm"
	  				Naming_Format="Deduction_Actions_Taken_#Get_Ded_Details.DD_DedID#_#Get_Ded_Details.Sp_Number#"				
					Relative_Path="\Temp_Files\Deduction\"
					Output_Content="#DD_Actions_Cont#"				
					Return_File_Name="fName">
			<CFSET MailParam = "#MailParam##fName#,">	
			<CFSET MailParamDesc = "#MailParamDesc#Actions taken,">		
		</CFIF>
	</CFIF>
	
	<!--- Reminders --->
	<CFIF Isdefined("FORM.DD_Reminders")>
		<CFSAVECONTENT VARIABLE="DD_Reminders_Cont">
			<CFINCLUDE Template="Inc_Comm_Header.cfm">
			<BR>
			<B>REMINDER</B>
			<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" CLASS="underline">
				<TR BGCOLOR="FFE083">
					<TD><B>DATE</B></TD>
					<TD><B>TYPE</B></TD>
					<TD><B>MESSAGE</B></TD>
					<TD><B>MAIL TO</B></TD>
					<TD><B>MAIL SENT</B></TD>
				</TR>
				<CFOUTPUT QUERY="GetReminders">
				<TR BGCOLOR="#IIf(currentrow Mod 2,DE('ffffff'), DE('C6FFC6'))#">
					<TD>#DateFormat(DD_Reminder_Date,"mm/dd/yyyy")#</TD>
					<TD>#DD_Type_Name#</TD>
					<TD>#DD_Reminder#</TD>
					<TD><CFIF Email_Reminder EQ 1>#request.AccessStructure.User_Email#<CFIF Others_to_Email NEQ "">;#Others_to_Email#</CFIF></CFIF> </TD>
					<TD><CFIF Reminder_Sent EQ 1>Yes<CFELSE>No</CFIF></TD>
				</TR>
				</CFOUTPUT>
			</TABLE>
		</CFSAVECONTENT>
		<CFIF FORM.Comm_Type NEQ "Print">
			<CFMODULE template="/CustomTags/Writing_Email_Attachment.cfm"
	  				Naming_Format="Deduction_Reminder_#Get_Ded_Details.DD_DedID#_#Get_Ded_Details.Sp_Number#"				
					Relative_Path="\Temp_Files\Deduction\"
					Output_Content="#DD_Reminders_Cont#"				
					Return_File_Name="fName">
			<CFSET MailParam = "#MailParam##fName#,">	
			<CFSET MailParamDesc = "#MailParamDesc#Reminder,">				
		</CFIF>		
	</CFIF>
	
	<!--- Notes added --->
	<CFIF Isdefined("FORM.DD_Notes")>
			
		<CFSAVECONTENT VARIABLE="DD_Notes_Cont">			
			<CFINCLUDE Template="Inc_Comm_Header.cfm"><BR>
			<B>NOTES</B>
			<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" CLASS="underline">
				<TR BGCOLOR="FFE083">
					<TD><B>DATE</B></TD>
					<TD WIDTH="10">&nbsp;</TD>
					<TD WIDTH="10"><B>NOTES</B></TD>
					<TD>&nbsp;</TD>
					<TD><B>ADDED BY</B></TD>
				</TR>
				<CFOUTPUT QUERY="ListNotes">
				<TR BGCOLOR="#IIf(currentrow Mod 2,DE('ffffff'), DE('C6FFC6'))#">
					<TD>#DateFormat(DD_Note_Date,"mm/dd/yyyy")#</TD>
					<TD>&nbsp;</TD>
					<TD>#DD_Note#</TD>
					<TD>&nbsp;</TD>
					<TD>#Name_First# #Name_Last#</TD>
				</TR>
				</CFOUTPUT>
			</TABLE>		
		</CFSAVECONTENT>
		<CFIF FORM.Comm_Type NEQ "Print">
			<CFMODULE template="/CustomTags/Writing_Email_Attachment.cfm"
	  				Naming_Format="Deduction_Notes_#Get_Ded_Details.DD_DedID#_#Get_Ded_Details.Sp_Number#"				
					Relative_Path="\Temp_Files\Deduction\"
					Output_Content="#DD_Notes_Cont#"				
					Return_File_Name="fName">
			<CFSET MailParam = "#MailParam##fName#,">		
			<CFSET MailParamDesc = "#MailParamDesc#Notes,">		
		</CFIF>
	</CFIF>
	
	<!--- Invoice Info --->
	<CFIF Isdefined("FORM.Invoice_Info")>
		
		<CFPARAM NAME="URL.Invoice_Header_ID" DEFAULT="#Invoice_Detail.Invoice_Header_ID#">
		<CFPARAM NAME="URL.Invoice_Number" DEFAULT="#Invoice_Detail.Invoice_Number#">
		<CFPARAM NAME="URL.Print" DEFAULT="1">
		<CFSAVECONTENT VARIABLE="Invoice_Info_Cont">
			<CFINCLUDE Template="Inc_Comm_Header.cfm">
			<CFINCLUDE Template="/Search_Screens/Invoice/invoice_detail.cfm">				
		</CFSAVECONTENT>
		<CFSET Invoice_Info_Cont = genFunctions.stripHTMLTag(Invoice_Info_Cont, "script") />
		<CFIF FORM.Comm_Type NEQ "Print">
			<CFMODULE template="/CustomTags/Writing_Email_Attachment.cfm"
	 				Naming_Format="Deduction_Invoice_Info_#Get_Ded_Details.DD_DedID#_#Get_Ded_Details.Sp_Number#"				
				Relative_Path="\Temp_Files\Deduction\"
				Output_Content="#Invoice_Info_Cont#"				
				Return_File_Name="fName">			
			<CFSET MailParam = "#MailParam##fName#,">	
			<CFSET MailParamDesc = "#MailParamDesc#Invoice info,">			
		</CFIF>
	</CFIF>
	
	<!--- Billback attached --->
	<CFIF Isdefined("FORM.BB_Details")>	
		<CFPARAM NAME="URL.Billback_ID" DEFAULT="">	
		<CFPARAM NAME="URL.DontShowEFP" DEFAULT="">
		<cfset variables.detailsCounter = 0 />
		<cfset variables.bbIdList = valueList(getBillbackIds.Billback_id) />
		<cfloop list="#variables.bbIdList#" index="bbIds">
		<cfset variables.detailsCounter = variables.detailsCounter + 1 />	
		<CFSET URL.Billback_ID = bbIds />
		<CFSAVECONTENT VARIABLE="BB_Details_Cont_#variables.detailsCounter#">
			<CFINCLUDE Template="/deductions/billback_details.cfm">
		</CFSAVECONTENT>
	
		<CFSET BB_Details_Cont = genFunctions.stripHTMLTag("#evaluate('BB_Details_Cont_#variables.detailsCounter#')#", "script") />
		<CFSET BB_Details_Cont = genFunctions.stripHTMLTag(BB_Details_Cont, "a") />

		

		</cfloop>
		<!--- <CFOUTPUT>#BB_Details_Cont#</CFOUTPUT> --->
		<CFIF FORM.Comm_Type NEQ "Print">
			<CFMODULE template="/CustomTags/Writing_Email_Attachment.cfm"
		  				Naming_Format="Deduction_BillBack_Info_#Get_Ded_Details.DD_DedID#_#Get_Ded_Details.Sp_Number#"				
						Relative_Path="\Temp_Files\Deduction\"
						Output_Content="#BB_Details_Cont#"				
						Return_File_Name="fName">
			<CFSET MailParam = "#MailParam##fName#,">	
			<CFSET MailParamDesc = "#MailParamDesc#Billback info,">		
		</CFIF>
	</CFIF>
	
	<!--- Adjustment --->
	<CFIF Isdefined("FORM.DD_Adjust")>		
		<CFPARAM NAME="URL.ID" DEFAULT="">		
		<CFPARAM NAME="URL.Type" DEFAULT="">
		<CFPARAM NAME="URL.dontshowwait" DEFAULT="">

		<CFSAVECONTENT VARIABLE="Final_Adjust_Disp">
			<CFINCLUDE Template="Inc_Comm_Header.cfm">
		</CFSAVECONTENT>
		
		<CFOUTPUT QUERY="Adjustments_Det">
			<CFSET URL.Type = DD_Relationship_Type_ID>
			<CFSET URL.ID = BB_Adjustment_ID>			
			<CFSAVECONTENT VARIABLE="DD_Adjust_Cont">
				<CFINCLUDE Template="/deductions/search_screens/adjustment_exclusions_detail.cfm">		
			</CFSAVECONTENT>
			<CFSET Final_Adjust_Disp = "#Final_Adjust_Disp# #DD_Adjust_Cont#">		
			<!--- #Final_Adjust_Disp# --->
		</CFOUTPUT>	
		<CFSET Final_Adjust_Disp = genFunctions.stripHTMLTag(Final_Adjust_Disp, "script") />	
		<CFIF FORM.Comm_Type NEQ "Print">	
			<CFMODULE template="/CustomTags/Writing_Email_Attachment.cfm"
	  				Naming_Format="Adjustment_Details_Of_Deduction_#Get_Ded_Details.DD_DedID#_#Get_Ded_Details.Sp_Number#"				
					Relative_Path="\Temp_Files\Deduction\"
					Output_Content="#Final_Adjust_Disp#"				
					Return_File_Name="fName">
			<CFSET MailParam = "#MailParam##fName#,">	
			<CFSET MailParamDesc = "#MailParamDesc#Adjustments,">			
		</CFIF>
	</CFIF>
	
	<!--- Exclusion --->
	<CFIF Isdefined("FORM.DD_Exclusion")>
		
		<CFPARAM NAME="URL.ID" DEFAULT="">		
		<CFPARAM NAME="URL.Type" DEFAULT="">
		<CFPARAM NAME="URL.dontshowwait" DEFAULT="">
		
		<CFSAVECONTENT VARIABLE="Final_Exlusion_Disp">
			<CFINCLUDE Template="Inc_Comm_Header.cfm">
		</CFSAVECONTENT>
		
		<CFOUTPUT QUERY="Exclusion_Disp">
			<CFSET URL.ID = BB_Program_Exclusion_ID>
			<CFSET URL.Type = DD_Relationship_Type_ID>
			<CFSAVECONTENT VARIABLE="DD_Exclusion_Cont">
				<CFINCLUDE Template="/deductions/search_screens/adjustment_exclusions_detail.cfm">
			</CFSAVECONTENT>
			<CFSET Final_Exlusion_Disp = "#Final_Exlusion_Disp# #DD_Exclusion_Cont#">				
		</CFOUTPUT>		
		<CFSET Final_Exlusion_Disp = genFunctions.stripHTMLTag(Final_Exlusion_Disp, "script") />	
		<CFIF FORM.Comm_Type NEQ "Print">
			<CFMODULE template="/CustomTags/Writing_Email_Attachment.cfm"
	  				Naming_Format="Exclusion_Details_Of_Deduction_#Get_Ded_Details.DD_DedID#_#Get_Ded_Details.Sp_Number#"				
					Relative_Path="\Temp_Files\Deduction\"
					Output_Content="#Final_Exlusion_Disp#"				
					Return_File_Name="fName">
			<CFSET MailParam = "#MailParam##fName#,">	
			<CFSET MailParamDesc = "#MailParamDesc#Exclusions,">		
		</CFIF>
	</CFIF>
	
	<!--- Email Sent --->
	<CFIF isdefined("FORM.Email_Details")>	
		<CFSAVECONTENT VARIABLE="Email_Details_cont">
		<CFINCLUDE Template="Inc_Comm_Header.cfm">
		<BR>
		<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" CLASS="underline">
			<TR  BGCOLOR="FFE083">
				<TD><B>DATE</B></TD>
				<TD><B>FROM ANALYST</B></TD>				
				<TD><B>TO</B></TD>
				<TD><B>SUBJECT</B></TD>
				<TD><B>ATTACHMENTS</B></TD>
			</TR>
			<CFOUTPUT QUERY="GetEmail_Det">
			<TR  BGCOLOR="#IIf(currentrow Mod 2,DE('ffffff'), DE('C6FFC6'))#">
				<TD>#DateFormat(Created_Date,"mm/dd/yyyy")#</TD>
				<TD NOWRAP>#Name_First# #Name_Last#</TD>
				<TD>#Message_To#</TD>
				<TD>#Message_Subject#&nbsp;</TD>
				<cfset useLakebaseForGet_Attach = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("message_attachment")>
<cfif useLakebaseForGet_Attach>
<cftry>
<cfset Get_Attach = application.oLakebase.toQuery(
application.oLakebase.selectRows("message_attachment", {
"select" = "attachment_desc",
"message_log_id" = "eq.#Message_Log_ID#"
}),
"attachment_desc"
)>
<cfcatch type="any">
<cfset useLakebaseForGet_Attach = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Attach><CFQUERY NAME="Get_Attach" DATASOURCE="#Application.Datasource#">
					SELECT 	Attachment_Desc 
					FROM 	Message_Attachment 
					WHERE 	Message_Log_ID = '#Message_Log_ID#'
				</CFQUERY>
</cfif>
				<TD>
					<CFIF Get_Attach.Recordcount GT 0>
						<CFLOOP QUERY="Get_Attach">
							#Attachment_Desc#<BR>
						</CFLOOP>
					<CFELSE>
						No Attachments
					</CFIF>
				</TD>
			</TR>	
			</CFOUTPUT>		
		</TABLE>	
		</CFSAVECONTENT>	
		
		<CFIF FORM.Comm_Type NEQ "Print">
			<CFMODULE template="/CustomTags/Writing_Email_Attachment.cfm"
	  				Naming_Format="Deduction_Actions_Taken_#Get_Ded_Details.DD_DedID#_#Get_Ded_Details.Sp_Number#"				
					Relative_Path="\Temp_Files\Deduction\"
					Output_Content="#Email_Details_cont#"				
					Return_File_Name="fName">
			<CFSET MailParam = "#MailParam##fName#,">	
			<CFSET MailParamDesc = "#MailParamDesc#Email Sent,">		
		</CFIF>
	</CFIF>
	
	<!--- Fax sent --->
	<CFIF isdefined("FORM.Fax_Details")>	
		<CFSAVECONTENT VARIABLE="Fax_Details_cont">
		<CFINCLUDE Template="Inc_Comm_Header.cfm">
		<BR>
		<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" CLASS="underline">
			<TR  BGCOLOR="FFE083">
				<TD><B>DATE</B></TD>
				<TD><B>ANALYST</B></TD>
				<!--- <TD><B>FROM</B></TD> --->
				<TD><B>TO</B></TD>
				<TD><B>SUBJECT</B></TD>
				<TD><B>ATTACHMENTS</B></TD>
			</TR>
			<CFOUTPUT QUERY="GetFax_Det">
			<TR  BGCOLOR="#IIf(currentrow Mod 2,DE('ffffff'), DE('C6FFC6'))#">
				<TD VALIGN="Top">#DateFormat(Created_Date,"mm/dd/yyyy")#</TD>
				<TD  VALIGN="Top" NOWRAP>#Name_First# #Name_Last#</TD>
				<!--- <TD>#Message_From#</TD> --->
				<CFSET search = "~">
				<CFSET Sent_To = Find(search,Message_To)>
				<CFSET Sent_To = Sent_To - 1>
				<CFSET Sent_To = Left(Message_To,Sent_To)>	
				<!--- 
				<CFSET length = len(Message_To)>
				<CFSET length = length-Sent_To>							
				 --->
				<TD VALIGN="Top">#Sent_To#</TD>
				<TD VALIGN="Top">#Message_Subject#&nbsp;</TD>
				<CFQUERY NAME="Get_Attach" DATASOURCE="#Application.Datasource#">
					SELECT 	Attachment_Desc 
					FROM 	Message_Attachment 
					WHERE 	Message_Log_ID = '#Message_Log_ID#' AND Attachment_Desc <> 'Cover Sheet'
				</CFQUERY>
				<TD VALIGN="Top">
					<CFIF Get_Attach.Recordcount GT 0>
						<CFLOOP QUERY="Get_Attach">
							#Attachment_Desc#<BR>
						</CFLOOP>
					<CFELSE>
						No Attachments
					</CFIF>
				</TD>
			</TR>	
			</CFOUTPUT>		
		</TABLE>	
		</CFSAVECONTENT>	
				
		<CFIF FORM.Comm_Type NEQ "Print">
			<CFMODULE template="/CustomTags/Writing_Email_Attachment.cfm"
	  				Naming_Format="Deduction_Actions_Taken_#Get_Ded_Details.DD_DedID#_#Get_Ded_Details.Sp_Number#"				
					Relative_Path="\Temp_Files\Deduction\"
					Output_Content="#Fax_Details_cont#"				
					Return_File_Name="fName">
			<CFSET MailParam = "#MailParam##fName#,">		
			<CFSET MailParamDesc = "#MailParamDesc#Fax sent,">	
		</CFIF>
	</CFIF>
	
	
	<!--- Call Log --->
	<CFIF IsDefined("FORM.CallLog_Info")>
		
		<CFSAVECONTENT VARIABLE="CallLog_Info_Cont">
			<CFINCLUDE Template="Inc_Comm_Header.cfm">
			<B>CALL LOG</B>
			<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" CLASS="underline">
				<TR BGCOLOR="FFE083">
					<TD><B>DATE</B></TD>				
					<TD NOWRAP><B>PERSON CALLED</B></TD>
					<TD><B>CALL NOTES</B></TD>
					<TD><B>CALLED BY</B></TD>
				</TR>
				 <CFOUTPUT QUERY="GetCalls">
				 <TR BGCOLOR="#IIf(currentrow Mod 2,DE('ffffff'), DE('C6FFC6'))#">
				 	<TD>#DateFormat(Call_Date,"mm/dd/yyyy")#</TD>
					<TD>#Person_Called#</TD>
					<TD>#Call_Synopsis#</TD>
					<TD NOWRAP>#Name_First# #Name_Last#</TD>
				 </TR>
				 </CFOUTPUT>
			</TABLE>
		</CFSAVECONTENT>
		
		<CFIF FORM.Comm_Type NEQ "Print">
			<CFMODULE template="/CustomTags/Writing_Email_Attachment.cfm"
	  				Naming_Format="CallLog_Info_Of_Deduction_#Get_Ded_Details.DD_DedID#_#Get_Ded_Details.Sp_Number#"				
					Relative_Path="\Temp_Files\Deduction\"
					Output_Content="#CallLog_Info_Cont#"				
					Return_File_Name="fName">
			<CFSET MailParam = "#MailParam##fName#,">			
			<CFSET MailParamDesc = "#MailParamDesc#Call log,">	
		</CFIF>
	</CFIF>
	
	<CFIF structKeyExists(form, "Rebill_Info")>
		<CFSAVECONTENT VARIABLE="Rebill_Info_Cont">
			<cfquery name="qRebill" datasource="#application.datasource#">
				 SELECT b.Rebill_Package_Title
				       ,a.Rebill_Message_Df
				       ,a.Rebill_Message_AddOn 
				       ,c.DD_Reason_Code
				   FROM DD_Rebill_Integration a
				        INNER JOIN dbo.DD_Rebill_Package_Hdr b ON a.DD_Rebill_Package_Hrd_ID = b.DD_Rebill_Package_Hdr_ID
				        LEFT JOIN dbo.DD_Reason_Code c ON c.DD_Reason_Code_ID = a.DD_Reason_Code_ID
				  WHERE a.Deduction_Id = '#Deduction_Id#' AND a.Deleted = 0
			</cfquery>
			<!---if deduction header or deduction detail are not included --->
			<cfif not isDefined("Get_Details") and not isdefined("FORM.DD_Details")>
				<CFINCLUDE Template="Inc_Comm_Header.cfm"><br>
			</cfif>			
			<B>REBILL INTEGRATION</B><hr>
			<TABLE style='table-layout:fixed;width:80%;margin:0 10%;'>
			 <col width="25%">
			 <col width="75%">
				<CFOUTPUT>
				<TR>
					<TD><B>Rebill Package:</B></TD>				
				 	<TD>#qRebill.Rebill_Package_Title#</TD>
				</TR>
				<TR>
					<TD><B>Reason Code:</B></TD>
				 	<TD>#qRebill.DD_Reason_Code#</TD>
				</TR>
				<TR>
					<TD valign="top"><B>Default Message:</B></TD>
				 	<TD>#qRebill.Rebill_Message_Df#</TD>
				</TR>
				<TR>
					<TD valign="top"><B>AddOn Message:</B></TD>
				 	<TD>#qRebill.Rebill_Message_AddOn#</TD>
				</TR>
			 </CFOUTPUT>
				</TABLE>
		</CFSAVECONTENT>
		
		<CFIF FORM.Comm_Type NEQ "Print">
			<CFMODULE template="/CustomTags/Writing_Email_Attachment.cfm"
	  				Naming_Format="Rebill_Info_Of_Deduction_#Get_Ded_Details.DD_DedID#_#Get_Ded_Details.Sp_Number#"				
					Relative_Path="\Temp_Files\Deduction\"
					Output_Content="#Rebill_Info_Cont#"				
					Return_File_Name="fName">
			<CFSET MailParam = "#MailParam##fName#,">			
			<CFSET MailParamDesc = "#MailParamDesc#Rebill Info,">	
		</CFIF>
	</CFIF>

	<!--- Dev Note: KAL; 9449 --->
	<!--- Attachment --->
	<CFIF IsDefined("FORM.Doc_ID")>
		<cfset useLakebaseForGetAttachments = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("document_details")>
<cfif useLakebaseForGetAttachments>
<cftry>
<cfset GetAttachments = application.oLakebase.toQuery(
application.oLakebase.selectRows("document_details", {
"select" = "doc_uni_name,doc_title",
"doc_id" = "in.(#FORM.Doc_ID#)"
}),
"doc_uni_name,doc_title"
)>
<cfcatch type="any">
<cfset useLakebaseForGetAttachments = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetAttachments><CFQUERY NAME="GetAttachments" DATASOURCE = "#Application.Datasource#">
			SELECT 		Doc_Uni_Name,
							doc_title 
			FROM		Document_Details
			WHERE 		1=2 
						<CFIF isdefined("FORM.Doc_ID")> 
							OR Doc_ID IN (#ListQualify(FORM.Doc_ID, "'", ",")#)
						</CFIF> 
		</CFQUERY>
</cfif>
		<CFSET Record_Count = 0>
		<CFOUTPUT QUERY="GetAttachments">
			<CFIF FILEEXISTS("#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#")>
				<CFSET Record_Count = Record_Count + 1>
				<CFSET search = ".">
				<CFSET content = Doc_Uni_Name>
				<!--- <CFSET File_Extension = Find(search,content)>
				<CFSET length = len(content)>
				<CFSET right_len = length-File_Extension>
				<CFSET File_Extension = right(content,right_len)> --->
				<CFSET File_Extension = ListLast(content, ".")>
				
				<CFMODULE template="/CustomTags/Naming_Email_Attachments.cfm" 
							Title="#Doc_Title#" 
							Relative_Src_File_Path="data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#"  
							Relative_Dest_Dir_Path ="Temp_Files\Program\Documents" 
							Return_Variable_Name="Dis_File_Name"
							File_Extension="#File_Extension#">
				
					<CFSET MailParam = "#MailParam##Dis_File_Name#,">		
					<CFSET MailParamDesc = "#MailParamDesc#Attachment-#doc_title#,">					
			</CFIF>			
		</CFOUTPUT>
	</CFIF>
	
	<CFOUTPUT>
	<CFIF FORM.Comm_Type EQ "Email">
		<cfmodule template="/CustomTags/EmailWrapper.cfm"
			TO					=	"#FORM.Send_To#"
	        FROM				=	"#request.AccessStructure.User_Email#"
	        SUBJECT				=	"#Form.Sendersubject#"
			TYPE				=	"html" 
			MESSAGETYPE			="1" 
			GENERATEDBY			="3" 
			APPAREA				="13" 
			USERID				="#request.AccessStructure.user_id#"
			APP_AREA_IDENTIFIER	="#Deduction_ID#" >		
			
			<TABLE WIDTH="100%">
			<TR VALIGN="top">
			<TD>
			#Form.Message_Body#
			</TD>
			</TR>
			</TABLE>
			<CFSET LoopCount = 0>
			<CFLOOP LIST="#MailParam#" INDEX="Item">
				<CFSET LoopCount = LoopCount + 1>
				<CFSET Descrption = ListGetAt(MailParamDesc,LoopCount,",")>				
				<cfmodule template="/CustomTags/EmailWrapperParam.cfm" file = "#Item#" store="yes" desc="#Descrption#"> 
			</CFLOOP>
		</cfmodule>
		
	<CFELSEIF FORM.Comm_Type EQ "Fax">		
		<CFSAVECONTENT VARIABLE = "Cover_sheet"> 
			<TABLE CELLPADDING="5" CELLSPACING="15" BORDER="0"  width="95%">
			 <TR>
			  <TD NOWRAP ALIGN="Right" COLSPAN="4">
			  <b>
			  <font face="Arial" size="5">#application.returned_customer_setting.Company_Name#</font></b>  
			  </TD>
			 </TR>
			 <TR>
			  <TD COLSPAN="4" style="border-bottom-style: solid; border-bottom-width: 4" valign="top"></TD>
			 </TR>
			 <TR>
			  <TD STYLE="FONT:72px;" COLSPAN="4" valign="top"><font face="Arial"><b>
			        <br>
			        F a x<br>
			&nbsp;</b></font></TD>
			 </TR>
			 <TR>
			  <TD width="75" rowspan="6" valign="top">&nbsp;</TD> 
			  <TD ROWSPAN="6" valign="top">&nbsp;</TD>
			  <TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">Date:</font></B></TD>
			  <TD WIDTH="100%" STYLE="FONT:16px;" valign="top">
			        <font face="Arial">
			        <span style="font-size: 13pt">#FORM.SenderDate# </span></font></TD>  
			 </TR>
			 <TR>
			  <TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">From:</font></B></TD>
			  <TD STYLE="FONT:16px;" width="100%" valign="top">
			        <font face="Arial">
			        <span style="font-size: 13pt">#FORM.Senderaddress#</span></font></TD>
			 </TR>
			 <TR>
			 	<TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">Deduction:</font></B></TD>
				 <TD STYLE="FONT:16px;" width="100%" valign="top">
			        <font face="Arial">
			        <span style="font-size: 13pt">#Get_Ded_Details.DD_DedID# - <CFIF Get_Ded_Details.SP_Number EQ "">000<CFELSE>#Get_Ded_Details.SP_Number#</CFIF></span></font></TD>
			 </TR>
			 <TR>
			  <TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">Subject:</font></B></TD>
			  <TD STYLE="FONT:16px;" width="100%" valign="top">
			        <font face="Arial">
			        <span style="font-size: 13pt">#FORM.Sendersubject#</span></font></TD>
			 </TR>
			 <TR>
			  <TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">Message:</font></B></TD>
			  <TD STYLE="FONT:16px;" width="100%" valign="top">
			        <font face="Arial">
			        <span style="font-size: 13pt">#Form.Message_Body#</span></font></TD>  
			 </TR>
			
			 <TR>
			  <TD VALIGN="top" STYLE="FONT:16px;">&nbsp;</TD>
			  <TD STYLE="FONT:16px;" width="100%" valign="top"><br>
			        <br>
			        <br>
			        <br>
			        <br>
			        <br>
			        <br>
			        <br>
			        <br>
			        <br>
			        <br>
			        <br>
			
			&nbsp;</TD>  
			 </TR>
			</TABLE> 
			<CFINCLUDE TEMPLATE="/Common_Files/Email_Footer.cfm">
		</CFSAVECONTENT>
		<CFSET datetimestamp="#numberformat(month(now()),'00')##numberformat(day(now()),'00')##numberformat(year(now()),'0000')##numberformat(hour(now()),'00')##numberformat(minute(now()),'00')##numberformat(second(now()),'00')#">
		<CFSET filename_email	=	"#datetimestamp#_#gettickcount()#">
		<CFSET CS_HTML_File_Path="\Temp_Files\deduction\CS_#filename_email#.html">


		<CFFILE action = "write"
				file="#Application.Doc_Path##CS_HTML_FILE_Path#"
				output="#Cover_sheet#">    		
		
		<CFSET Fax_Numbers_List="">
		<CFLOOP INDEX="Item" LIST="#Form.Fax_Number#" DELIMITERS=";">
			<CFSET Fax_Numbers_List=item&"~FR="&AccessStructure.Name_First&"_"&AccessStructure.Name_Last&"@Faxmail.com"&";"&Fax_Numbers_List>
		</CFLOOP>

		
		<cfmodule template="/CustomTags/EmailWrapper.cfm"
			TO					="#Fax_Numbers_List#"
	        FROM				="chainlink@awayx.com" 
			SUBJECT				="#Form.SenderSubject#"
			MESSAGETYPE			="2"
			GENERATEDBY			="3" 
			APPAREA				="13" 
			USERID				="#request.AccessStructure.user_id#"
			APP_AREA_IDENTIFIER	="#Deduction_ID#">
			<cfmodule template="/CustomTags/EmailWrapperParam.cfm" FILE="#Application.Doc_Path##CS_HTML_FILE_Path#" store="yes" Desc = "Cover Sheet">
				<CFSET LoopCount = 0>
				<CFLOOP LIST="#MailParam#" INDEX="Item">
					<CFSET LoopCount = LoopCount + 1>
					<CFSET Descrption = ListGetAt(MailParamDesc,LoopCount,",")>				
					<CFMODULE template="/CustomTags/EmailWrapperParam.cfm" file = "#Item#" store="yes" desc="#Descrption#"> 
				</CFLOOP>			
			</cfmodule>
		</cfmodule> 
	<CFELSEIF FORM.Comm_Type EQ "Print">
		<CFSET PageBreakCount = 0>
		<CFIF isdefined("FORM.DD_Details")>
			<CFSET PageBreakCount = PageBreakCount + 1>
			<CFIF PageBreakCount GT 1>
				<div class="pageBreakBefore"></div>
			</CFIF>
			<BR><BR><BR><BR>
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD>#DD_Details_cont#</TD>
				</TR>
			</TABLE>
					
		</CFIF>
		
		<CFIF Isdefined("FORM.Split_Info")>
			<CFSET PageBreakCount = PageBreakCount + 1>
			<CFIF PageBreakCount GT 1>
				<div class="pageBreakBefore"></div>
			</CFIF>
			<BR><BR><BR><BR>
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD>#Split_Info_cont#</TD>
				</TR>
			</TABLE>
			
		</CFIF>
		
		<CFIF Isdefined("FORM.DD_Actions")>
			<CFSET PageBreakCount = PageBreakCount + 1>
			<CFIF PageBreakCount GT 1>
				<div class="pageBreakBefore"></div>
			</CFIF>
			<BR><BR><BR><BR>
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD>#DD_Actions_Cont#</TD>
				</TR>
			</TABLE>
			
		</CFIF>
		
		<CFIF Isdefined("FORM.DD_Notes")>
			<CFSET PageBreakCount = PageBreakCount + 1>
			<CFIF PageBreakCount GT 1>
				<div class="pageBreakBefore"></div>
			</CFIF>
			<BR><BR><BR><BR>
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD>#DD_Notes_Cont#</TD>
				</TR>
			</TABLE>
			
		</CFIF>
		
		
		<CFIF Isdefined("FORM.DD_Reminders")>
			<CFSET PageBreakCount = PageBreakCount + 1>
			<CFIF PageBreakCount GT 1>
				<div class="pageBreakBefore"></div>
			</CFIF>
			<BR><BR><BR><BR>
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD>#DD_Reminders_Cont#</TD>
				</TR>
			</TABLE>
			
		</CFIF>
		
		
		<CFIF Isdefined("FORM.Invoice_Info")>
			<CFSET PageBreakCount = PageBreakCount + 1>
			<CFIF PageBreakCount GT 1>
				<div class="pageBreakBefore"></div>
			</CFIF>
			<BR><BR><BR><BR>
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD>#Invoice_Info_Cont#</TD>
				</TR>
			</TABLE>
			
		</CFIF>
		
		<CFIF Isdefined("FORM.BB_Details")>	
			<cfset variables.detailsCounter2 = 0 />
			<cfloop list="#variables.bbIdList#" index="bbIds2">
			<cfset variables.detailsCounter2 = variables.detailsCounter2 + 1 />
			<CFSET PageBreakCount = PageBreakCount + 1>
			<CFIF PageBreakCount GT 1>
				<div class="pageBreakBefore"></div>
			</CFIF>
			<BR><BR><BR><BR>
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD>#Evaluate("BB_Details_Cont_"&variables.detailsCounter2)#</TD>
				</TR>
			</TABLE>
		</cfloop>
		</CFIF>
		
		<CFIF Isdefined("FORM.DD_Adjust")>
			<CFSET PageBreakCount = PageBreakCount + 1>
			<CFIF PageBreakCount GT 1>
				<div class="pageBreakBefore"></div>
			</CFIF>
			<BR><BR><BR><BR>
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD>#Final_Adjust_Disp#</TD>
				</TR>
			</TABLE>
			
		</CFIF>
		
		<CFIF Isdefined("FORM.DD_Exclusion")>
			<CFSET PageBreakCount = PageBreakCount + 1>
			<CFIF PageBreakCount GT 1>
				<div class="pageBreakBefore"></div>
			</CFIF>
			<BR><BR><BR><BR>
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD>#Final_Exlusion_Disp#</TD>
				</TR>
			</TABLE>			
		</CFIF>
		
		<CFIF Isdefined("FORM.Email_details")>
			<CFSET PageBreakCount = PageBreakCount + 1>
			<CFIF PageBreakCount GT 1>
				<div class="pageBreakBefore"></div>
			</CFIF>
			<BR><BR><BR><BR>
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD>#Email_Details_cont#</TD>
				</TR>
			</TABLE>
		</CFIF>
		
		<CFIF isdefined("FORM.Fax_Details")>
			<CFSET PageBreakCount = PageBreakCount + 1>
			<CFIF PageBreakCount GT 1>
				<div class="pageBreakBefore"></div>
			</CFIF>
			<BR><BR><BR><BR>
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD>#Fax_Details_cont#</TD>
				</TR>
			</TABLE>
		</CFIF>
		
		<CFIF IsDefined("FORM.CallLog_Info")>
			<CFSET PageBreakCount = PageBreakCount + 1>
			<CFIF PageBreakCount GT 1>
				<div class="pageBreakBefore"></div>
			</CFIF>
			<BR><BR><BR><BR>
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD>#CallLog_Info_Cont#</TD>
				</TR>
			</TABLE>
			
		</CFIF>
		
		
		<cfif structKeyExists(form, "Rebill_Info")>
			<CFSET PageBreakCount = PageBreakCount + 1>
			<CFIF PageBreakCount GT 1>
				<div class="pageBreakBefore"></div>
			</CFIF>
			<BR><BR><BR><BR>
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD>#Rebill_Info_Cont#</TD>
				</TR>
			</TABLE>
		</cfif>		
		
		<CFINCLUDE template="/Common_Files/Printer_Friendly_Script.cfm">
	</CFIF>
	</CFOUTPUT>
	<CFIF FORM.Comm_Type NEQ "Print">
		<br><br><br><br><br><br>
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
			<TR>
				<TD><B><FONT COLOR="Red" SIZE="3">Please wait while sending <CFIF FORM.Comm_Type EQ "Email">email<CFELSE>fax</CFIF>...</FONT></B></TD>
			</TR>
		</TABLE>	
		<cfset useLakebaseForIsLocked = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForIsLocked>
<cftry>
<cfset IsLocked = application.oLakebase.toQuery(
application.oLakebase.selectRows("deductions", {
"select" = "is_locked,locked_by",
"deduction_id" = "eq.#URL.Deduction_ID#"
}),
"is_locked,locked_by"
)>
<cfcatch type="any">
<cfset useLakebaseForIsLocked = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForIsLocked><CFQUERY NAME="IsLocked" DATASOURCE="#Application.Datasource#">
			SELECT Is_Locked,Locked_By FROM Deductions WHERE Deduction_ID = '#URL.Deduction_ID#'
		</CFQUERY>
</cfif>
		
		<CFIF IsLocked.Is_Locked EQ 1 AND IsLocked.Locked_By EQ "#request.AccessStructure.User_ID#">
			<CFSET DeductionLockStatus = 1>
		<CFELSE>
			<CFSET DeductionLockStatus = 0>
		</CFIF>
		
		<SCRIPT language="JavaScript">
			function delayLocate()
			{
				window.location.href = "/deductions/inc_deduction_Details.cfm?Deduction_ID=<CFOUTPUT>#URL.Deduction_ID#</CFOUTPUT>&showScissor=<CFOUTPUT>#DeductionLockStatus#</CFOUTPUT>";
			}
			
			window.setTimeout('delayLocate()', 2000);
			
		</SCRIPT>
	</CFIF>
</CFIF>


<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
<SCRIPT language="JavaScript" src="/script/javascript/string_validations.js"></SCRIPT>
	

<cfinclude template="/Common_Files/Documents/Document_Include.cfm" />

<SCRIPT language="JavaScript">
function Validate()
{
	if ( $('.item:checked').length ) {
		submitprint();	
	}
	else	{
		alert("Please select at least one option from the above list.")		
	}
}

function submitprint()
{
	document.Comm_Options.Form_Submitted.value = 1;
	document.Comm_Options.submit()
}

//Email validations

var ErrorCount = 0;
function confirmCompletionEmail()
{

	var ErrorCount = 0;

	if(document.all.SenderAddress.value.length == 0)	
	{ 
		ErrorCount++;
		queueMessage("You must enter your email address", document.all.error_SenderAddress);
	}	
	else
	{			
		clearQueue(document.all.error_SenderAddress);
	}
	
	if(document.all.SenderSubject.value.length == 0)
	{			
		ErrorCount++;
		queueMessage("You must enter a subject", document.all.error_SenderSubject);
	}
	else
	{			
		clearQueue(document.all.error_SenderSubject);
	}	
	
	//ChromeFix
	//  var recipients = combineEmails(document.all.Send_To.value, document.all.Send_To_2.value);
	//ChromeFix
	<cfif application.appSettingsGet.External_Contacts_Option eq 0>
		var recipients_2 = jQuery('input[name=Send_To_2]').val();
    <cfelse>
	    var recipients_2 = jQuery('textarea[name=Send_To_2]').val();
	</cfif>
	var recipients = combineEmails(jQuery("textarea[name=Send_To]").val(),recipients_2); //ChromeFix
	if ( recipients.length == 0 )   /*25704*/
	{
		ErrorCount++;
		queueMessage("You must enter at least one email address", document.all.error_Send_To);
	}
	else
	{
		clearQueue(document.all.error_Send_To);
	}
		
<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0) 
	{
  	// hide email recipient input
  	/// document.all.Send_To.style.visibility = 'hidden';  //ChromeFix
	jQuery("textarea[name=Send_To]").hide();
	// combine int email recipients & ext email recipients  //ChromeFix
	jQuery("textarea[name=Send_To]").val(recipients);
		//Email.submit()
		document.Comm_Options.Form_Submitted.value = 1;
		document.Comm_Options.submit()
		
	}
	else 
	{
		showMessageWindow()
	}	
}
</SCRIPT>
<!--- <CF_MessageWindow>	 --->
	



<SCRIPT language="JavaScript">
// Fax Validations
var ErrorCount = 0;
function confirmCompletion()
{

	var ErrorCount = 0;

		if(document.all.SenderAddress.value.length == 0)	
		{ 
			ErrorCount++;
			queueMessage("You must enter your email address", document.all.error_SenderAddress);
		}
		else
		{			
			clearQueue(document.all.error_SenderAddress);
		}		
			
		
		 if(document.all.SenderSubject.value.length == 0)
		{			
			ErrorCount++;
			queueMessage("You must enter a subject", document.all.error_SenderSubject);
		}
		else
		{			
			clearQueue(document.all.error_SenderSubject);
		}	
		if(document.all.Fax_Number.value.length == 0)
		{
			ErrorCount++;
			queueMessage("You must enter at least one fax number", document.all.error_Fax_Number);
		}
		else
		{
			clearQueue(document.all.error_Fax_Number);
		}
		
<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0) 
	{
		//Fax.submit()
	document.Comm_Options.Form_Submitted.value = 1;
	document.Comm_Options.submit()
		
	}
	else 
	{
		showMessageWindow()
	}	
}

</SCRIPT>
<CFMODULE template="/CustomTags/MessageWindow.cfm">

<!---if emailing then skip loading jQuery (already loaded to support external contacts) --->
<cfif URL.From NEQ "Email">
	<cfmodule template="/common_files/jQuery.cfm">
</cfif>	
</body>
</html>
