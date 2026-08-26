<cfoutput>
<!--- Send the below info to  _Application_settings.BA_Support_Email --->
<CFIF application.oApplicationAppSettingsManager.getApplicationAppSettings().getWebserviceOn() EQ 0>
<cfquery name="CleanUpWR" datasource="punchlist">
delete from  Punch_Work_Request_History
where (Punch_Desc = '0' or Punch_Desc = '' OR Punch_Desc is NULL)
and (Punch_Status_ID	= 0 or Punch_Status_ID = '' OR Punch_Status_ID is NULL)
and (Punch_Priority_ID	=0 or Punch_Priority_ID = '' OR Punch_Priority_ID is NULL)
and (Punch_Function_ID	=0 or Punch_Function_ID = '' OR Punch_Function_ID is NULL)
and (Punch_Type_ID	=0 or Punch_Type_ID = '' OR Punch_Type_ID is NULL)
and (Punch_Title	= '0'	 or Punch_Title = '' OR Punch_Title is NULL)
and (Punch_ErrorID = '0'	or (Punch_ErrorID = ''	and len(Punch_ErrorID_bf) <=1) OR Punch_ErrorID is NULL)
and (Punch_Related_to	= '0'	or (Punch_Related_to = '' and len(Punch_Related_to_bf) <=1) OR Punch_Related_to is NULL)
and (Work_Request_URL  = '0'		or Work_Request_URL = '' OR Work_Request_URL is NULL)
and (ExpectedBehavior	 = '0'	or (ExpectedBehavior = '' and len(ExpectedBehavior_bf) <=1) OR ExpectedBehavior is NULL)
and (AssociatedTo	  = '0'	or (AssociatedTo = '' and len(AssociatedTo_bf) <=1) OR AssociatedTo is NULL)
and (Punch_Priority_BA_ID = 0	or Punch_Priority_BA_ID = '' OR Punch_Priority_BA_ID is NULL)
and (Punch_Release_Notes  = '0' or (Punch_Release_Notes = '' and len(Punch_Release_Notes_bf) <=1) OR Punch_Release_Notes is NULL)
and (Punch_UserID  = '0' or (Punch_UserID = '' and len(Punch_UserID_bf) <=1) OR Punch_UserID is NULL)
and (Notes_FromAppWR = '0' or Notes_FromAppWR = '' OR Notes_FromAppWR is NULL)
</cfquery>

<cfquery name="GetWRHistory" datasource="punchlist">
    select  Punch_Work_Request_History.*,
        Punch_Status.Punch_Status_Desc,
        Punch_Function.Punch_Function_Desc,
        Punch_Type.Punch_Type_Desc,
        Punch_Priority.Punch_Priority_Desc,
        Punch_Priority_BA.Punch_Priority_BA_Desc,
        Punch_Status_bf.Punch_Status_Desc as Punch_Status_Desc_bf,
        Punch_Function_bf.Punch_Function_Desc as Punch_Function_Desc_bf,
        Punch_Type_bf.Punch_Type_Desc as Punch_Type_Desc_bf,
        Punch_Priority_bf.Punch_Priority_Desc as Punch_Priority_Desc_bf,
        Punch_Priority_BA_bf.Punch_Priority_BA_Desc as Punch_Priority_BA_Desc_bf

        from Punch_Work_Request_History
        LEFT JOIN Punch_Status 	ON Punch_Work_Request_History.Punch_Status_ID = Punch_Status.Punch_Status_ID
        LEFT JOIN Punch_Function  ON Punch_Work_Request_History.Punch_Function_ID = Punch_Function.Punch_Function_ID
        LEFT JOIN Punch_Type ON Punch_Work_Request_History.Punch_Type_ID = Punch_Type.Punch_Type_ID
        LEFT JOIN Punch_Priority ON Punch_Work_Request_History.Punch_Priority_ID = Punch_Priority.Punch_Priority_ID
        LEFT JOIN Punch_Priority_BA ON Punch_Work_Request_History.Punch_Priority_BA_ID = Punch_Priority_BA.Punch_Priority_BA_ID
        LEFT JOIN Punch_Status Punch_Status_bf ON Punch_Work_Request_History.Punch_Status_ID_bf = Punch_Status_bf.Punch_Status_ID
        LEFT JOIN Punch_Function  Punch_Function_bf  ON Punch_Work_Request_History.Punch_Function_ID_bf = Punch_Function_bf.Punch_Function_ID
        LEFT JOIN Punch_Type Punch_Type_bf  ON Punch_Work_Request_History.Punch_Type_ID_bf = Punch_Type_bf.Punch_Type_ID
        LEFT JOIN Punch_Priority Punch_Priority_bf  ON Punch_Work_Request_History.Punch_Priority_ID_bf = Punch_Priority_bf.Punch_Priority_ID
        LEFT JOIN Punch_Priority_BA Punch_Priority_BA_bf  ON Punch_Work_Request_History.Punch_Priority_BA_ID_bf = Punch_Priority_BA_bf.Punch_Priority_BA_ID
        where Punch_ID = '#PunchInformation.Punch_ID#'
        and EmailToClient_Status  = 1
        and Punch_ID > 0
        order by Punch_Last_Updated DESC

</cfquery>

<CFQUERY NAME="Get_App_Notes" datasource="punchlist">
		select 	Notes,Requesting_URL
		from 	Punch_Work_Request
		where Punch_ID = '#PunchInformation.Punch_ID#'
		and Punch_ID > 0
</CFQUERY>

<CFQUERY NAME="Get_WR_Document" datasource="punchlist">
		select *
		from Punch_file
		where Punch_ID = '#PunchInformation.Punch_ID#'
		and Punch_ID > 0
		and deleted = 0
		and  FilePathInApp is not NULL
</CFQUERY>
<CFELSE>
	<CFQUERY NAME="Get_WR_Document" datasource="#application.datasource#">
		Select	*
		From	Work_Request_Document
		Where 	Work_Request_ID = #Work_Request_ID_Mail#
		And 	deleted = 0
		Order by	WR_Document_Name
	</CFQUERY>
</CFIF>

<cfif #SupportEmail.BA_Support_Email# eq "">
	<set SupportEmail.BA_Support_Email = "remote_events@bigredflame.com">
</cfif>
<!--- Send Email --->
    <cfmail TO		=	"#SupportEmail.BA_Support_Email#"
            FROM	=	"#application.oApplicationAppSettingsManager.getApplicationAppSettings().getDifferent_From_Address()#"
            replyto =   "#GetUserInfo.User_Email#"
            SUBJECT	=	"#emailSubjet#"
            TYPE	=	"html"
	>
	<p></p>
	<TABLE ALIGN=center BORDER=1 CELLSPACING=0 CELLPADDING=5 WIDTH="90%" BGCOLOR="white" BACKGROUND="white" BORDERCOLOR="maroon" >
		<tr>
			<td style ="border-bottom:solid ##93BEE2 1px; font-size : 12px; font-family:Century Gothic,Arial,Helvetica,sans-serif;"colspan =3 bgcolor="##CCCCCC">
					<FONT color="maroon"><b> Work Request: ###PunchInformation.Punch_ID#</b></font>
			</td>
		</tr>
		<tr>
			<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;" colspan =3 >
				#emailSubjetDetails#
			</td>
		</tr>
		<tr>
		<td>
			<TABLE ALIGN=center BORDER=0 CELLSPACING=0 CELLPADDING=5  BGCOLOR="white" WIDTH="100%" BACKGROUND="white">
			<tr>
					<td style ="border-bottom:solid ##330000 2px; font-size : 12px; font-family:Century Gothic;" colspan =3 valign="bottom" >
						<FONT color="maroon"><b> Details: </b></font>
					</td>
			</tr>
			<tr>
				<td   style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;"  valign="top" WIDTH="20%" bgcolor="##CCCCCC"> URL</td>
				<td   style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;"   colspan =2>#PunchInformation.Work_Request_URL# &nbsp;</td>
			</tr>
			<tr>
				<td   style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;"  valign="top" WIDTH="20%" bgcolor="##CCCCCC"> WR Created In</td>
				<td   style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;"   colspan =2>#Get_App_Notes.Requesting_URL# &nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic;"   valign="top" WIDTH="20%" bgcolor="##CCCCCC"> Issue Title</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;"   colspan =2>#PunchInformation.Punch_Title# &nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;"   valign="top" WIDTH="20%" bgcolor="##CCCCCC"> Status</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;"   colspan =2>#PunchInformation.Punch_Status_Desc# &nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;"   valign="top" WIDTH="20%" bgcolor="##CCCCCC"> Description</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;"   colspan =2> #PunchInformation.Punch_Desc# &nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" WIDTH="20%" bgcolor="##CCCCCC" NOWRAP> Expected Behavior</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" colspan =2>#PunchInformation.ExpectedBehavior# &nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" WIDTH="20%" bgcolor="##CCCCCC" NOWRAP> Notes</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" colspan =2>#Get_App_Notes.Notes# &nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" WIDTH="20%" bgcolor="##CCCCCC"> User</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" colspan =2> #PunchInformation.Punch_UserID# &nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" WIDTH="20%" bgcolor="##CCCCCC"> Prog/BB/DD/Int</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" colspan =2>  #PunchInformation.AssociatedTo# &nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" WIDTH="20%" bgcolor="##CCCCCC"> Error Event ##</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" colspan =2> #PunchInformation.Punch_ErrorID# &nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" WIDTH="20%" bgcolor="##CCCCCC" NOWRAP> Client Reference Number</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" colspan =2> #PunchInformation.Punch_Related_to# &nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" WIDTH="20%" bgcolor="##CCCCCC"> Priority</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" colspan =2>#PunchInformation.Punch_Priority_Desc# &nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" WIDTH="20%" bgcolor="##CCCCCC" NOWRAP> Area of Application Affected</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" colspan =2>#PunchInformation.Punch_Function_Desc# &nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" WIDTH="20%" bgcolor="##CCCCCC"> Request Type</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" colspan =2>#PunchInformation.Punch_Type_Desc# &nbsp;</td>
			</tr>
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" WIDTH="20%" bgcolor="##CCCCCC"> Release Notes</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" colspan =2>#PunchInformation.Punch_Release_Notes# &nbsp;</td>
			</tr>
			<!---
			<tr>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" WIDTH="20%" bgcolor="##CCCCCC"> Notes</td>
				<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" colspan =2>#PunchInformation.Notes_FromAppWR# &nbsp;</td>
			</tr>
			--->
			<tr>
				<td style ="border-bottom:solid ##330000 2px; font-size : 12px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" colspan =3 valign="bottom" >
					<FONT  color="maroon"><b> History:</b></font>
				</td>
			</tr>
			<cfif GetWRHistory.recordcount GT 0>
				<tr><td colspan =3>
				<table cellpadding="0" BGCOLOR="white" WIDTH="100%" BACKGROUND="white">
					<tr>
						<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top"  bgcolor="##CCCCCC" WIDTH="15%" colspan=2 NOWRAP> Field Name</td>
						<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top"  bgcolor="##CCCCCC" WIDTH="25%" NOWRAP> Old Value</td>
						<td style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;  font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top"  bgcolor="##CCCCCC"> New Value</td>
					</tr>
					<cfset i = #GetWRHistory.recordcount# >
					<cfloop QUERY ="GetWRHistory">
					<tr>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size : 10px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="bottom"  colspan=4 height="30px">
						   <font color=maroon>Changes ###i#:  &nbsp;Date:   #DateFormat(GetWRHistory.Punch_Last_Updated, 'mm/dd/yyyy')# #timeFormat(GetWRHistory.Punch_Last_Updated, 'h:mm tt')# EST  &nbsp;Changer: #GetWRHistory.Punch_Last_UpdatedBy# </font>
						</td>
					</tr>

					<cfif #GetWRHistory.Work_Request_URL# NEQ "0" and  #GetWRHistory.Work_Request_URL# NEQ "">
					<tr><td>&nbsp;&nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" > URL</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" >#GetWRHistory.Work_Request_URL_bf# &nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" >#GetWRHistory.Work_Request_URL# &nbsp;</td>
					</tr>
					</cfif>

					<cfif #GetWRHistory.Punch_Title# NEQ "0" and  #GetWRHistory.Punch_Title# NEQ "">
					<tr><td>&nbsp;&nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" NOWRAP> Issue Title</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" >#GetWRHistory.Punch_Title_bf# &nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" >#GetWRHistory.Punch_Title# &nbsp;</td>
					</tr>
					</cfif>

					<cfif #GetWRHistory.Punch_Status_ID# NEQ 0 and #GetWRHistory.Punch_Status_ID# NEQ "">
					<tr><td>&nbsp;&nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" WIDTH="15%"> Status</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" WIDTH="25%" NOWRAP>#GetWRHistory.Punch_Status_Desc_bf# &nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" >#GetWRHistory.Punch_Status_Desc# &nbsp;</td>
					</tr>
					</cfif>


					<cfif #GetWRHistory.Punch_Desc# NEQ "0" and #GetWRHistory.Punch_Desc# NEQ "">
					<tr><td>&nbsp;&nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" WIDTH="15%"> Description</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" WIDTH="25%"> #GetWRHistory.Punch_Desc_bf# &nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" > #GetWRHistory.Punch_Desc# &nbsp;</td>
					</tr>
					</cfif>

					<cfif #GetWRHistory.ExpectedBehavior# EQ "" and #GetWRHistory.ExpectedBehavior_bf# EQ "">
					<cfelse>
					<cfif #GetWRHistory.ExpectedBehavior# NEQ "0" >
					<tr><td>&nbsp;&nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" NOWRAP WIDTH="15%"> Expected Behavior</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" WIDTH="25%">#GetWRHistory.ExpectedBehavior_bf# &nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" ><cfif #GetWRHistory.ExpectedBehavior# eq "NothingEmpty">&nbsp;<cfelse>#GetWRHistory.ExpectedBehavior#</cfif>&nbsp;</td>
					</tr>
					</cfif>
					</cfif>
					<cfif #GetWRHistory.Punch_UserID# EQ "" and #GetWRHistory.Punch_UserID_bf# EQ "">
					<cfelse>
					<cfif #GetWRHistory.Punch_UserID# NEQ "0" >
					<tr><td>&nbsp;&nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" > User</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" > #GetWRHistory.Punch_UserID_bf# &nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" > #GetWRHistory.Punch_UserID# &nbsp;</td>
					</tr>
					</cfif>
					</cfif>

					<cfif #GetWRHistory.AssociatedTo# EQ "" and #GetWRHistory.AssociatedTo_bf# EQ "">
					<cfelse>
					<cfif #GetWRHistory.AssociatedTo# NEQ "0" >
					<tr><td>&nbsp;&nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" > Prog/BB/DD/Int</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;"  NOWRAP>  #GetWRHistory.AssociatedTo_bf# &nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" >  #GetWRHistory.AssociatedTo# &nbsp;</td>
					</tr>
					</cfif>
					</cfif>

					<cfif #GetWRHistory.Punch_ErrorID# EQ "" and #GetWRHistory.Punch_ErrorID_bf# EQ "">
					<cfelse>
					<cfif #GetWRHistory.Punch_ErrorID# NEQ "0" >
					<tr><td>&nbsp;&nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" NOWRAP> Error Event ##</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" > #GetWRHistory.Punch_ErrorID_bf# &nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" > #GetWRHistory.Punch_ErrorID# &nbsp;</td>
					</tr>
					</cfif>
					</cfif>

					<cfif #GetWRHistory.Punch_Related_to# EQ "" and #GetWRHistory.Punch_Related_to_bf# EQ "">
					<cfelse>
					<cfif #GetWRHistory.Punch_Related_to# NEQ "0" >
					<tr><td>&nbsp;&nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" NOWRAP> Client Reference Number</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" > #GetWRHistory.Punch_Related_to_bf# &nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" > #GetWRHistory.Punch_Related_to# &nbsp;</td>
					</tr>
					</cfif>
					</cfif>
					<cfif #GetWRHistory.Punch_Priority_ID# NEQ 0 and #GetWRHistory.Punch_Priority_ID# NEQ "">
					<tr><td>&nbsp;&nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" > Priority</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" >#GetWRHistory.Punch_Priority_Desc_bf# &nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" >#GetWRHistory.Punch_Priority_Desc# &nbsp;</td>
					</tr>
					</cfif>

					<cfif #GetWRHistory.Punch_Priority_BA_ID# NEQ 0 and #GetWRHistory.Punch_Priority_BA_ID# NEQ "">
					<tr><td>&nbsp;&nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" NOWRAP> BA Priority</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;"  NOWRAP>#GetWRHistory.Punch_Priority_BA_Desc_bf# &nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" >#GetWRHistory.Punch_Priority_BA_Desc# &nbsp;</td>
					</tr>
					</cfif>

					<cfif #GetWRHistory.Punch_Function_ID# NEQ 0 and #GetWRHistory.Punch_Function_ID# NEQ "">
					<tr><td>&nbsp;&nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" NOWRAP> Area of Application Affected</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;"  NOWRAP>#GetWRHistory.Punch_Function_Desc_bf# &nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" >#GetWRHistory.Punch_Function_Desc# &nbsp;</td>
					</tr>
					</cfif>

					<cfif #GetWRHistory.Punch_Type_ID# NEQ 0 and #GetWRHistory.Punch_Type_ID# NEQ "">
					<tr><td>&nbsp;&nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" NOWRAP> Request Type</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" >#GetWRHistory.Punch_Type_Desc_bf# &nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" >#GetWRHistory.Punch_Type_Desc# &nbsp;</td>
					</tr>
					</cfif>

					<cfif #GetWRHistory.Punch_Release_Notes# EQ "" and #GetWRHistory.Punch_Release_Notes_bf# EQ "">
					<cfelse>
					<cfif #GetWRHistory.Punch_Release_Notes# NEQ "0" >
					<tr><td>&nbsp;&nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" NOWRAP WIDTH="15%"> Release Notes</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;"  WIDTH="25%">#GetWRHistory.Punch_Release_Notes_bf# &nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" ><cfif #GetWRHistory.Punch_Release_Notes# eq "NothingEmpty">&nbsp;<cfelse>#GetWRHistory.Punch_Release_Notes#</cfif> &nbsp;</td>
					</tr>
					</cfif>
					</cfif>

					<cfif #GetWRHistory.Notes_FromAppWR# NEQ '0' and #GetWRHistory.Notes_FromAppWR# NEQ "">
					<tr><td>&nbsp;&nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" valign="top" > Notes</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" >#GetWRHistory.Notes_FromAppWR_bf# &nbsp;</td>
						<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" >#GetWRHistory.Notes_FromAppWR# &nbsp;</td>

					</tr>
				</cfif>
				<cfset i = i-1 >
				</cfloop>
				</table>
				</td></tr>
			<cfelse>
				<tr>
					<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px;" colspan =3 >---</td>
				</tr>
			</cfif>
			<tr>
				<td style ="border-bottom:solid ##330000 2px; font-size : 12px; font-family:Century Gothic,Arial,Helvetica,sans-serif;" colspan=3 valign="bottom" >
					<FONT  color="maroon"><b> Attachments:</b></font>
				</td>
			</tr>
			<cfif Get_WR_Document.recordcount GT 0>
				<cfloop QUERY ="Get_WR_Document">
				<tr>
					<td colspan=3 style ="border-bottom:solid ##93BEE2 1px; font-size: 11px;">&nbsp;&nbsp;#Get_WR_Document.Punch_File_Name#</td>
				</tr>
				</cfloop>
			<cfelse>
				<tr>
					<td style ="border-bottom:solid ##CCCCCC 1px; font-size: 11px;" colspan =3 >---</td>
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
<tr>

<table width="95%" border="0" align="center" cellpadding="2" cellspacing="0" bordercolor="111111" style="border-collapse: collapse">
  <tr>
    <td  align="center">
	<SPAN STYLE="background-color:FFFFFF;color:navy; font-size:10pt; padding: 5px;"><a href="http://#PunchInformation.Work_Request_URL#">#PunchInformation.Work_Request_URL#</a> &nbsp;-</SPAN>
	<font size="2">Contract Management services provided by #Application.CompanyNameFull# - <a href="#application.CompanyWebsiteURL#">#application.CompanyWebsite#</a></font></td>
  </tr>
</table>


</cfmail>
</cfoutput>
