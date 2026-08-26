<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the date/time stamps for the message history for this contract							 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForGet_Message_History = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_message_history")>
<cfif useLakebaseForGet_Message_History>
	<cftry>
		<cfset Get_Message_History = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_message_history", {
				"contract_main_id" = "eq.#cryp.value#",
				"order" = "message_date.asc",
				"select" = "message_date"
			}), "message_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Message_History = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Message_History>
<CFQUERY NAME="Get_Message_History" datasource="#application.datasource#">
Select distinct
			Contract_Message_History.Message_date
From		Contract_Message_History
Where		Contract_Main_ID	=	'#cryp.value#'
Order by	Message_date
</CFQUERY>
</cfif>



<CFIF Get_Message_History.recordcount NEQ 0>

<CF_openLayer 
	Border="yes"  
	BorderSize="1"  
	BorderColor="orange"  
	Image="/images/hand.gif"
	Title="Contract Message Traffic"  
	TitleClosed="Contract Message Traffic"  
	TitleTooltip="Contract Message Traffic"  
	TitleFont="font"  
	TitleColor="Navy"  
	TitleSize="12"  
	IsClosed="Yes"  
	Width="750">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Loop through the list of date/time stamps														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFLOOP INDEX="datestamp" LIST="#valuelist(Get_Message_History.Message_date)#">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get details for each of the items... --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFQUERY NAME="Get_Details" datasource="#application.datasource#">
		Select		Contract_Message_History.*,
					_Users.Name_First,
					_Users.Name_Last
		From		Contract_Message_History,
					_Users
		Where		Contract_Main_ID	=	'#cryp.value#'
					and
					Contract_Message_History.User_ID	=	_Users.User_ID
					and
					Message_Date		= 	'#datestamp#'
		Order by	Message_date
	</CFQUERY>
	<TABLE BORDER="1" CELLPADDING="2" CELLSPACING="0" WIDTH="100%">
		<TR BGCOLOR="Orange">
			<TD WIDTH="150"><B>Date</B></TD>
			<TD WIDTH="125"><B>From Who...</B></TD>
			<TD WIDTH="50"><B>What</B></TD>
			<TD WIDTH="200"><B>To Whom...</B></TD>
		</TR>
		<CFOUTPUT QUERY="Get_Details" GROUP="Message_date">
			<TR>
				<TD VALIGN="Top" ROWSPAN="100%">#dateformat(Message_date, 'mm/dd/yyy')# - #timeformat(Message_date, 'h:mm:ss TT')#</TD>
				<CFOUTPUT>
				<TD>#Name_First# #Name_Last#</TD>
				<TD>#Message_Type#</TD>
				<TD>#Address_Fax_Number#</TD>
			</TR>
		</CFOUTPUT>
	</CFOUTPUT>
	</TABLE>
</CFLOOP>
</CF_openLayer>


</CFIF>


























 
 