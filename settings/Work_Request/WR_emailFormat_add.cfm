<CFIF application.oApplicationAppSettingsManager.getApplicationAppSettings().getWebserviceOn() EQ 0>

<cfquery name="CleanUpWR" datasource="punchlist">
	delete from  Punch_Work_Request_History
	where (Punch_Desc = '0' or Punch_Desc = '' OR Punch_Desc is NULL)
	and (Punch_Status_ID	= 0 or Punch_Status_ID = '' OR Punch_Status_ID is NULL)
	and (Punch_Priority_ID	=0 or Punch_Priority_ID = '' OR Punch_Priority_ID is NULL)
	and (Punch_Function_ID	=0 or Punch_Function_ID = '' OR Punch_Function_ID is NULL)
	and (Punch_Type_ID	=0 or Punch_Type_ID = '' OR Punch_Type_ID is NULL)
	and (Punch_Title	= '0'	 or Punch_Title = '' OR Punch_Title is NULL)
	and (Punch_ErrorID = '0'	or Punch_ErrorID = ''	OR Punch_ErrorID is NULL)
	and (Punch_Related_to	= '0'	or Punch_Related_to = '' OR Punch_Related_to is NULL)
	and (Work_Request_URL  = '0'		or Work_Request_URL = '' OR Work_Request_URL is NULL)
	and (ExpectedBehavior	 = '0'	or ExpectedBehavior = '' OR ExpectedBehavior is NULL)
	and (AssociatedTo	  = '0'	or AssociatedTo = '' OR AssociatedTo is NULL)
	and (Punch_Priority_BA_ID = 0	or Punch_Priority_BA_ID = '' OR Punch_Priority_BA_ID is NULL)
	and (Punch_Release_Notes  = '0' or Punch_Release_Notes = '' OR Punch_Release_Notes is NULL)
	and (Punch_UserID  = '0' or Punch_UserID = '' OR Punch_UserID is NULL)
	and (Notes_FromAppWR = '0' or Notes_FromAppWR = '' OR Notes_FromAppWR is NULL)
</cfquery>

<CFQUERY NAME="Get_WR_Document" datasource="punchlist">
		select Punch_File_Name as WR_Document_Name,*
		from Punch_file
		where Punch_ID = '#Punch_ID#'
		and deleted = 0
		and Punch_ID > 0
		and  FilePathInApp is not NULL
</CFQUERY>
<CFELSE>
	<cfoutput>
	<CFQUERY NAME="Get_WR_Document" datasource="#application.datasource#">
		Select	*
		From	Work_Request_Document
		Where 	Work_Request_ID = #InsertWorkRequest.Work_Request_ID#
		And 	deleted = 0
		Order by	WR_Document_Name
	</CFQUERY>
	</cfoutput>
</CFIF>
<cfoutput>
<cfif #emailTo# eq "">
	<set emailTo = "remote_events@bigredflame.com">
</cfif>
<!--- Send Email --->
		<cfmail TO		=	"#emailTo#"
				FROM	=	"#application.oApplicationAppSettingsManager.getApplicationAppSettings().getDifferent_From_Address()#"
				replyto	=	"#emailFrom#"
				SUBJECT	=	"Work Request ###Punch_ID# - #arguments.Work_Title# - #arguments.Installation_URL#"
				TYPE	=	"html"
		>
	<p></p>
	<TABLE ALIGN=center BORDER=1 CELLSPACING=0 CELLPADDING=5 WIDTH="90%" BGCOLOR="white" BACKGROUND="white" BORDERCOLOR="maroon" >
		<tr>
			<td style ="border-bottom:solid ##93BEE2 1px; font-size : 25px;"colspan =2  bgcolor="##CCCCCC">
				<FONT SIZE="2" color="maroon"><b> Work Request: ###Punch_ID#</b></font>
			</td>
		</tr>
		<tr>
			<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;"colspan =2 >
				#emailSubjetDetails#
			</td>
		</tr>
		<tr>
		<td>
		<TABLE ALIGN=center BORDER=0 CELLSPACING=0 CELLPADDING=5  BGCOLOR="white" WIDTH="100%" BACKGROUND="white">
			<tr>
				<td style ="border-bottom:solid ##330000 2px; font-size : 20px;"colspan =2 valign="bottom" >
					<FONT SIZE="2" color="maroon"><b> Details: </b></font>
				</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;" valign="top" WIDTH="20%" bgcolor="##CCCCCC"> URL</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;">#arguments.URLEnvironment#&nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;" valign="top" WIDTH="20%" bgcolor="##CCCCCC"> WR Created In</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;">#arguments.Installation_URL#&nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;" valign="top" WIDTH="20%" bgcolor="##CCCCCC"> Issue Title</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;">#arguments.Work_Title#&nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;" valign="top" WIDTH="20%" bgcolor="##CCCCCC"> Description</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;"> #arguments.CurrentBehavior#&nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;" valign="top" WIDTH="20%" bgcolor="##CCCCCC" NOWRAP> Expected Behavior</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;">#arguments.ExpectedBehavior#&nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;" valign="top" WIDTH="20%" bgcolor="##CCCCCC" NOWRAP> Notes</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;">&nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;" valign="top" WIDTH="20%" bgcolor="##CCCCCC"> User</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;"> #arguments.UserInfo#&nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;" valign="top" WIDTH="20%" bgcolor="##CCCCCC"> Prog/BB/DD/Int</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;">  #arguments.ProgBBDDIDs#&nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;" valign="top" WIDTH="20%" bgcolor="##CCCCCC"> Error Event ##</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;"> #arguments.ErrorEvent#&nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;" valign="top" WIDTH="20%" bgcolor="##CCCCCC" NOWRAP> Client Reference Number</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;"> #arguments.Client_Reference_Number#&nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;" valign="top" WIDTH="20%" bgcolor="##CCCCCC"> Priority</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;">#arguments.Client_Priority#&nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;" valign="top" WIDTH="20%" bgcolor="##CCCCCC" NOWRAP> Area of Application Affected</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;">#arguments.App_Area#&nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;" valign="top" WIDTH="20%" bgcolor="##CCCCCC"> Request Type</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;">#arguments.Request_Type#&nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##330000 2px; font-size : 20px;"colspan =2 valign="bottom" >
					<FONT SIZE="2" color="maroon"><b> History:</b></font>
				</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;" colspan =2 >---</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##330000 2px; font-size : 20px;"colspan =2 valign="bottom" >
					<FONT SIZE="2" color="maroon"><b> Attachments:</b></font>
				</td>
			</tr>
			<cfif Get_WR_Document.recordcount GT 0>
				<cfloop QUERY ="Get_WR_Document">
				<tr>
				<td colspan=2 style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;">#Get_WR_Document.WR_Document_Name#</td>
				</tr>
				</cfloop>
			<cfelse>
				<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;" colspan =2 >---</td>
				</tr>
			</cfif>
			<!---
			<tr>
				<td valign="top">Requesting User Contact Info</td>
				<td>
					#GetUserInfo.Name_First# #GetUserInfo.Name_Last# (#GetUserInfo.User_Code#)<Br>
					<A href="mailto:#GetUserInfo.User_Email#">#GetUserInfo.User_Email#</A><br>
					#GetUserInfo.Work_Phone_1#-#GetUserInfo.Work_Phone_2#-#GetUserInfo.Work_Phone_3#<br>
				</td>
			</tr>
			--->
		</TABLE>
		</td>
		</tr>
	</TABLE>
	<p></p>
	<table width="95%" border="0" align="center" cellpadding="2" cellspacing="0" bordercolor="111111" style="border-collapse: collapse">
  		<tr>
   		 	<td  align="center">
			<SPAN STYLE="background-color:FFFFFF;color:navy; font-size:10pt; padding: 5px;"><a href="http://#arguments.Installation_URL#">#arguments.Installation_URL#</a> &nbsp;-</SPAN>
				<font size="2">Contract Management services provided by #Application.CompanyNameFull# - <a href="#application.CompanyWebsiteURL#">#application.CompanyWebsite#</a></font></td>
		 </tr>
	</table>
</cfmail>
</cfoutput>