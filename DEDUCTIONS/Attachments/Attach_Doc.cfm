<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>


<CFPARAM NAME="URL.Deduction_ID" DEFAULT="">
<CFPARAM NAME="FORM.Attachment_List" DEFAULT="">
<CFPARAM NAME="FORM.Deduction_ID" DEFAULT="#URL.Deduction_ID#">
<CFPARAM NAME="FORM.Form_Submitted" DEFAULT="0">

<cfset appSettings = application.appSettingsGet />

<!------ DEV NOTE DRK: D9450 - Reviewing and Printing the attached documents always ----->
<!--- Dev Note: CPM 11135 - Added additional columns to use for todo's --->
<cfset useLakebaseForIsLocked = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForIsLocked>
	<cftry>
		<cfset IsLocked = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"select" = "dd_dedid_sp_number,analyst_user_id,is_locked,locked_by",
				"deduction_id" = "eq.#FORM.Deduction_ID#"
			}),
			"dd_dedid_sp_number,analyst_user_id,is_locked,locked_by"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForIsLocked = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsLocked>
<CFQUERY NAME="IsLocked" DATASOURCE="#Application.Datasource#">
	SELECT DD_DedID_SP_Number, Analyst_User_ID, Is_Locked,Locked_By FROM Deductions WHERE Deduction_ID = '#FORM.Deduction_ID#'
</CFQUERY>
</cfif>

<CFIF IsLocked.Is_Locked EQ 1 AND IsLocked.Locked_By EQ request.AccessStructure.User_ID>
	<CFSET DeductionLockStatus = 1>
<CFELSE>
	<CFSET DeductionLockStatus = 0>
</CFIF>

<CFINCLUDE TEMPLATE="/Common_Files/Documents/User_Positions_Under_this_User.cfm">
<CFSET Access_Position_List = GP_Position_List_From_My_Position_Down>
<!---
	Dev Notes: D23320/Anand Rao/17-May-10
	  User profile setting to view private documents
--->
<!---
	SELECT 		Document_Details.*,
				_Users.Name_First,
				_Users.Name_Last

	FROM 		Document_Details

	INNER JOIN	Contract_Attachments ON Document_Details.Doc_ID =  Contract_Attachments.Doc_ID AND Contract_Attachments.Deleted=0
	LEFT JOIN	_Users ON _Users.User_ID = Document_Details.Uploaded_By AND _Users.Deleted=0
	WHERE 		1 = 2
				<CFIF FORM.Deduction_ID NEQ "">
					OR	(
							Contract_Attachments.Deduction_ID	=	'#FORM.Deduction_ID#'
							AND Contract_Attachments.Deleted = 0
							AND (	(	Public_View = 1
										AND User_Position_ID IN (#preserveSingleQuotes(Access_Position_List)#)
									)
										OR Public_View = 0
								)
						)
				</CFIF>
--->
<CFQUERY NAME="Select_Pre" DATASOURCE="#Application.Datasource#">


IF OBJECT_ID('tempdb..##TMP_DEDUCTION_ATTACHMENTS') IS NOT NULL
  DROP TABLE ##TMP_DEDUCTION_ATTACHMENTS
SELECT	Document_Details.*,
				_Users.Name_First,
				_Users.Name_Last
  INTO	##TMP_DEDUCTION_ATTACHMENTS
  FROM    Document_Details
	INNER JOIN	Contract_Attachments ON Document_Details.Doc_ID =  Contract_Attachments.Doc_ID AND Contract_Attachments.Deleted=0
 	LEFT JOIN	_Users ON _Users.User_ID = Document_Details.Uploaded_By AND _Users.Deleted=0
  LEFT JOIN Profiles_Settings PS
  ON		PS.Profiles_ID = #Request.AccessStructure.Profiles_ID#   AND PS.View_Private_Documents = 1
  WHERE 1=2
    <CFIF FORM.Deduction_ID NEQ "">
					OR	(
							Contract_Attachments.Deduction_ID	=	'#FORM.Deduction_ID#'
							AND Contract_Attachments.Deleted = 0
							AND (	(	Public_View = 1
										AND User_Position_ID IN (#preserveSingleQuotes(Access_Position_List)#)
									)
										OR Public_View = 0
								)
						)
				</CFIF>
    AND
      (Document_Details.Uploaded_By = '#Request.AccessStructure.User_ID#' OR  Public_View =0)
	ORDER BY Doc_Title

  INSERT INTO ##TMP_DEDUCTION_ATTACHMENTS
    SELECT	Document_Details.*,
				_Users.Name_First,
				_Users.Name_Last
    FROM    Document_Details
    INNER JOIN	Contract_Attachments ON Document_Details.Doc_ID =  Contract_Attachments.Doc_ID AND Contract_Attachments.Deleted=0
 	  LEFT JOIN	_Users ON _Users.User_ID = Document_Details.Uploaded_By AND _Users.Deleted=0
    INNER JOIN Profiles_Settings PS
    ON		PS.Profiles_ID = #request.accessStructure.Profiles_ID#  AND PS.View_Private_Documents = 1
    WHERE  1= 2
    <CFIF FORM.Deduction_ID NEQ "">
					OR	(
							Contract_Attachments.Deduction_ID	=	'#FORM.Deduction_ID#'
							AND Contract_Attachments.Deleted = 0
							AND (	(	Public_View = 1
										AND User_Position_ID IN (#preserveSingleQuotes(Access_Position_List)#)
									)
										OR Public_View = 0
								)
						)
				</CFIF>
  ORDER BY Doc_Title

    SELECT DISTINCT * FROM ##TMP_DEDUCTION_ATTACHMENTS




</CFQUERY>




<CFIF Select_Pre.Recordcount GT 0>
	<CFSET PreSelection = ValueList(Select_Pre.Doc_ID)>
</CFIF>

<CFIF FORM.Form_Submitted EQ 2>

		<CFSET FinalSelection = "">
		<CFIF Isdefined("FORM.Doc_ID")>
			<CFSET FinalSelection = FORM.Doc_ID>
		</CFIF>
		<CFIF Isdefined("FORM.Pre_Doc_ID")>
			<CFIF FinalSelection NEQ "">
				<CFSET FinalSelection = "#FinalSelection#,#FORM.Pre_Doc_ID#">
			<CFELSE>
				<CFSET FinalSelection = FORM.Pre_Doc_ID>
			</CFIF>
		</CFIF>


	<cfset useLakebaseForDeleted_All = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
<cfif useLakebaseForDeleted_All>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_attachments",
			{
				"deduction_id" = "eq.#Form.Deduction_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeleted_All = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeleted_All>
<CFQUERY NAME="Deleted_All" DATASOURCE="#Application.Datasource#">
		UPDATE 	Contract_Attachments
		SET		Deleted = 1
		WHERE 	Deduction_ID = '#Form.Deduction_ID#'
	</CFQUERY>
</cfif>


	<CFIF FinalSelection NEQ "">
	<CFLOOP INDEX="item" LIST="#FinalSelection#" DELIMITERS=",">
		<CFQUERY NAME="Insert_Data" DATASOURCE="#Application.Datasource#">
			INSERT	INTO Contract_Attachments
					(
						Deduction_ID,
						Doc_ID
					)
			VALUES
					(
						'#Form.Deduction_ID#',
						'#item#'
					)
		</CFQUERY>
	</CFLOOP>



		 <cfif appSettings.getAddTodoOnDocAttach() AND len(isLocked.Analyst_User_ID) GT 0 >
				<cfset todo_message = "Attachment added to DD## #trim(isLocked.DD_DedID_SP_Number)# on #dateformat(now(),'mm/dd/yyyy')# by #request.AccessStructure.Name_First# #request.AccessStructure.Name_Last#." />
				<CFQUERY NAME="todo_save" datasource="#application.datasource#">
				INSERT INTO todolist
				(Users_ID,Listitem_Text, Priority_Level)
				VALUES
				('#isLocked.Analyst_User_ID#', '#todo_message#', '1')
				</CFQUERY>
		</cfif>
	</CFIF>
	<BR><BR><BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">Please wait while attaching selected documents to this deduction...</FONT></B></TD>
		</TR>
	</TABLE>
	<SCRIPT language="JavaScript">
		function delayLocate()
		{
			window.location.href = "/deductions/inc_deduction_details.cfm?Deduction_ID=<CFOUTPUT>#FORM.Deduction_ID#&showScissor=#DeductionLockStatus#</CFOUTPUT>";
		}
		window.setTimeout('delayLocate()', 3000);
	</SCRIPT>

<CFELSE>

	<CFIF Select_Pre.recordcount GT 0>
		<CFIF FORM.Form_Submitted EQ 0>
			<CFSET FORM.Attachment_List = PreSelection>
			<CFSET RecentSel = "">
		<CFELSEIF FORM.Form_Submitted EQ 1>
			<CFIF FORM.Attachment_List NEQ "">
				<CFSET RecentSel = FORM.Attachment_List>
				<CFLOOP LIST="#PreSelection#" INDEX="Item">
					<CFSET PreSelectionPosition = ListFindNoCase(RecentSel,Item,",")>
					<CFIF PreSelectionPosition GT 0>
						<CFSET RecentSel = ListDeleteAt(RecentSel,PreSelectionPosition,",")>
					</CFIF>
				</CFLOOP>
			<CFELSE>
				<CFSET FORM.Attachment_List = PreSelection>
				<CFSET RecentSel = "">
			</CFIF>
		</CFIF>
	<CFELSE>
		<CFSET RecentSel = "#FORM.Attachment_List#">
	</CFIF>
	<FORM NAME="Attach_doc" ACTION="Attach_Doc.cfm" METHOD="Post">
	<INPUT TYPE="Hidden" NAME="Form_Submitted" VALUE="1">
	<CFOUTPUT>

	<INPUT TYPE="Hidden" NAME="Attachment_List" VALUE="#FORM.Attachment_List#">
	<INPUT TYPE="Hidden" NAME="Deduction_ID" VALUE="#FORM.Deduction_ID#">
	<!--- #FORM.Attachment_List# --->
	</CFOUTPUT>

	<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="100%">
		<TR>
			<TD COLSPAN="100%"><B>Previously saved :&nbsp;&nbsp;<HR COLOR="Orange"></TD>
		</TR>
		<CFIF Select_Pre.RecordCount GT 0>
		<TR BGCOLOR="FFE083">
			<TD STYLE="border-bottom:solid #C0C0C0 1px;"><INPUT TYPE="CheckBox" NAME="Select_All" onclick="javaScript: selectAll2(this);" <CFIF Select_Pre.Recordcount GT 0>CHECKED</CFIF> <CFIF DeductionLockStatus EQ 0> DISABLED</CFIF>></TD>
			<TD STYLE="border-bottom:solid #C0C0C0 1px;"><B>DATE<br>NAME</B></TD>
			<TD STYLE="border-bottom:solid #C0C0C0 1px;"><B>FILE</B></TD>
			<TD STYLE="border-bottom:solid #C0C0C0 1px;"><B>TITLE<br>DESCRIPTION</B></TD>
			<TD STYLE="border-bottom:solid #C0C0C0 1px;"><B>TYPE<br>PRIVACY</B></TD>
		</TR>
		<CFOUTPUT QUERY="Select_Pre">
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
				<TD STYLE="border-bottom:solid C0C0C0 1px;"><INPUT TYPE="CheckBox" NAME="Pre_Doc_ID" VALUE="#Doc_ID#" <CFIF ListFindNoCase(FORM.Attachment_List,Doc_ID,",") GT 0>CHECKED</CFIF> <CFIF DeductionLockStatus EQ 0> DISABLED</CFIF>></TD>
				<TD NOWRAP STYLE="border-bottom:solid C0C0C0 1px;">#DateFormat(Uploaded_Date,"mm/dd/yyyy")#<br>#Name_First# #Name_Last#</TD>
					<CFSET SIZEinMB = #Doc_size#/1048576>
					<TD NOWRAP TITLE="File Name: #Doc_File_Name#" STYLE="border-bottom:solid C0C0C0 1px;"><A href="javascript: confirmation('#Doc_Uni_Name#');" TITLE="Click here to view '#Doc_File_Name#'">
					<CFSET Display_Name=Left(Doc_File_Name,20)>
					<CFIF len(trim(Doc_File_Name)) GT 20>
						#Display_Name#...
					<CFELSEIF len(trim(Doc_File_Name)) EQ 0>
						&nbsp;
					<CFELSE>
						#Display_Name#
					</CFIF>
					</A><br>#NumberFormat(SIZEinMB,"_.___")#&nbsp;KB</TD>
					<TD STYLE="border-bottom:solid C0C0C0 1px;"><FONT color="red">#Doc_Title#</FONT><BR>Description: #Doc_Description#</TD>
					<TD STYLE="border-bottom:solid C0C0C0 1px;">#Doc_Type#<BR><cfif #Public_View# EQ 1> Yes <cfelse> No</cfif></TD>
			</TR>
		</CFOUTPUT>
		<CFELSE>
			<TR>
				<TD COLSPAN="100%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<B>None Saved.</B></TD>
			</TR>
		</CFIF>
		<CFIF DeductionLockStatus EQ 1><!------ enable attach document, only if the deduction is locked ----->
		<TR>
			<TD COLSPAN="100%"><HR COLOR="Orange"></TD>
		</TR>
		<TR>
			<TD COLSPAN="100%">
				<BR><BR><B>Recently selected :&nbsp;&nbsp;
				<B><FONT COLOR="Red">[ </FONT> <A HREF="javascript: void(0);" onclick="NewWindow('/common_files/Documents/Attach_Document.cfm?Form_Name=Attach_doc&Deduction_ID=<cfoutput>#FORM.Deduction_ID#</cfoutput>','name','810','600','Yes', 'No');return false;" >attach from list</A><FONT COLOR="Red"> ]</FONT> </B>
				<HR COLOR="Orange">
			</TD>
		</TR>
		<CFIF RecentSel NEQ "">
			<CFSET RecentSel = ListQualify(RecentSel,"'",",","All")>

			<CFQUERY NAME="GetSelDetails" DATASOURCE="#Application.Datasource#">
				SELECT 		Document_Details.*,
							_Users.Name_First,
							_Users.Name_Last

				FROM 		Document_Details

				LEFT JOIN	_USERS ON _USERS.User_ID = Document_Details.Uploaded_By AND _USERS.Deleted=0
				WHERE 		1 = 2
							<CFIF Len(RecentSel) GT 0>
							OR	(
									Doc_ID IN (#preserveSingleQuotes(RecentSel)#)
									AND (	(	Public_View = 1
												AND User_Position_ID IN (#preserveSingleQuotes(Access_Position_List)#)
											)
												OR Public_View = 0
										)
								)
							AND Document_Details.Deleted=0
							</CFIF>
			</CFQUERY>

			<TR BGCOLOR="FFE083">
				<TD STYLE="border-bottom:solid #C0C0C0 1px;"><INPUT TYPE="CheckBox" NAME="Select_All" onclick="javaScript: selectAll(this);" CHECKED></TD>
				<TD STYLE="border-bottom:solid #C0C0C0 1px;"><B>DATE<br>NAME</B></TD>
				<TD STYLE="border-bottom:solid #C0C0C0 1px;"><B>FILE</B></TD>
				<TD STYLE="border-bottom:solid #C0C0C0 1px;"><B>TITLE<br>DESCRIPTION</B></TD>
				<TD STYLE="border-bottom:solid #C0C0C0 1px;"><B>TYPE<br>PRIVACY</B></TD>
			</TR>
			<CFOUTPUT QUERY="GetSelDetails">
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
					<TD STYLE="border-bottom:solid C0C0C0 1px;"><INPUT TYPE="CheckBox" NAME="Doc_ID" VALUE="#Doc_ID#" CHECKED></TD>
					<TD NOWRAP STYLE="border-bottom:solid C0C0C0 1px;">#DateFormat(Uploaded_Date,"mm/dd/yyyy")#<br>#Name_First# #Name_Last#</TD>
					<CFSET SIZEinMB = #Doc_size#/1048576>
					<TD NOWRAP TITLE="File Name: #Doc_File_Name#" STYLE="border-bottom:solid C0C0C0 1px;"><A href="javascript: confirmation('#Doc_Uni_Name#');" TITLE="Click here to view '#Doc_File_Name#'">
					<CFSET Display_Name=Left(Doc_File_Name,20)>
					<CFIF len(trim(Doc_File_Name)) GT 20>
						#Display_Name#...
					<CFELSEIF len(trim(Doc_File_Name)) EQ 0>
						&nbsp;
					<CFELSE>
						#Display_Name#
					</CFIF>
					</A><br>#NumberFormat(SIZEinMB,"_.___")#&nbsp;KB</TD>
					<TD STYLE="border-bottom:solid C0C0C0 1px;"><FONT color="red">#Doc_Title#</FONT><BR>Description: #Doc_Description#</TD>
					<TD STYLE="border-bottom:solid C0C0C0 1px;">#Doc_Type#<BR><cfif #Public_View# EQ 1> Yes <cfelse> No</cfif></TD>
				</TR>
			</CFOUTPUT>
		<CFELSE>
			<TR>
				<TD COLSPAN="100%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<B>None Selected.</B></TD>
			</TR>
		</CFIF>
		<TR>
			<TD COLSPAN="100%"><HR COLOR="Orange"></TD>
		</TR>
		<TR>
			<TD COLSPAN="100%" ALIGN="Center"><BR><BR>
				<CF_button
					button_name	=	""
					button_caption	=	"attach documents"
					button_action	=	"Validate()"
					button_type	=	"javascript_link"
					button_width	=	"150"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight	=	"bold"
								>
			</TD>
		</TR>
		</CFIF><!------ enable attach document, only if the deduction is locked ----->
	</TABLE>
	</FORM>
</CFIF>

<cfinclude template="/Common_Files/Documents/Document_Include.cfm" />

<SCRIPT language="JavaScript">

function selectAll(thisobj)
{
	var bCheck = thisobj.checked;
	var chObjs = document.all.Doc_ID;

	if(chObjs.length)
	{
		var chObjLen = chObjs.length;
		var i;
		for(i=0;i<chObjLen;i++)
		{
			chObjs[i].checked = bCheck;
		}
	}
	else
	{
		chObjs.checked = bCheck;
	}

}

function selectAll2(thisobj)
{
	var bCheck = thisobj.checked;
	var chObjs = document.all.Pre_Doc_ID;

	if(chObjs.length)
	{
		var chObjLen = chObjs.length;
		var i;
		for(i=0;i<chObjLen;i++)
		{
			chObjs[i].checked = bCheck;
		}
	}
	else
	{
		chObjs.checked = bCheck;
	}

}


function Validate()
{
	document.all.Form_Submitted.value=2;
	document.Attach_doc.submit()
}

</SCRIPT>


</body>
</html>
