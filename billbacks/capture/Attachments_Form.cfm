<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
	<style>
		#upl17 { margin: 7px 0; }
		#upl18 { font-size: 14px; }
		table.Maintable td {
			font-size: 8pt !important;
		}
		table.Maintable tr { line-height: 18px; }
	</style>

	<!--- Dropzone.js open source library is used for the file upload --->
	<cf_include files=#arrayToList( [ "/common_files/dropzone.cfm", "/styles/ba_upload.css" ] )#>

</head>

<!--- http://artemis2/billbacks/capture/attachments_form.cfm?bbid=7f7eae37-cdce-4115-9444-81568cfa213a --->
<body>
<!--- When the request is for multiple billbacks, then we just pass the first billback_id from the list of ID's as BBID and the whole list of billback_ID as "billbackList".
      The purpose of having a BBID is so that already existing code works. In this scenario, we do not show already saved billbacks as the list of documents will differ from
      billback to billback. So, a user only sees the billbacks added in that session which gets added to all the selected billbacks from flex. Deleting is allowed only from
      a single billback.
--->
<cfparam name="URL.BillbackList" default="">
<!--- Dev Note: - Call from the Flex App --->
<cfparam name="FORM.FlexAppName" default="">
<cfif isDefined("URL.FlexAppName")>
	<cfset temp = structInsert(FORM,"FlexAppName",#URL.FlexAppName#,true) />
</cfif>

<CFINCLUDE TEMPLATE="/Common_Files/Documents/User_Positions_Under_this_User.cfm">
<CFSET Access_Position_List = GP_Position_List_From_My_Position_Down>
<!---
	Dev Notes: D23320/Anand Rao/17-May-10
	  User profile setting to view private documents
--->
<CFQUERY NAME="Display_Attach" DATASOURCE="#Application.Datasource#">
/* 	SELECT 	Contract_Attachments.Doc_ID,
			Doc_Uni_Name,
			Doc_Title,
			Doc_Description,
			Uploaded_Date,
			Uploaded_BY,
			Doc_Type,
			Doc_File_Name,
			Doc_Size
	FROM Document_Details
	INNER JOIN Contract_Attachments ON Document_Details.Doc_ID = Contract_Attachments.Doc_ID
	WHERE 1=2 	<!--- CFIF URL.BBID NEQ "">
					 OR (	Contract_Attachments.Billback_ID = '#URL.BBID#'
							AND Contract_Attachments.Deleted = 0
							AND (	(	Public_View = 1
										AND User_Position_ID IN (#preserveSingleQuotes(Access_Position_List)#)
									)
										OR Public_View = 0
								)
						)
				</CFIF ---->
	ORDER BY Doc_Title
  */

IF OBJECT_ID('tempdb..##TMP_BILLBACK_ATTACHMENTS') IS NOT NULL
  DROP TABLE ##TMP_BILLBACK_ATTACHMENTS
SELECT	Document_Details.*
  INTO	##TMP_BILLBACK_ATTACHMENTS
  FROM    Document_Details
  INNER JOIN Contract_Attachments ON Document_Details.Doc_ID = Contract_Attachments.Doc_ID
  LEFT JOIN Profiles_Settings PS
  ON		PS.Profiles_ID = #Request.AccessStructure.Profiles_ID#   AND PS.View_Private_Documents = 1
  WHERE 1=2
    <CFIF URL.BBID NEQ "">
					 OR (	Contract_Attachments.Billback_ID = '#URL.BBID#'
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

  INSERT INTO ##TMP_BILLBACK_ATTACHMENTS
    SELECT	Document_Details.*
    FROM    Document_Details
   INNER JOIN Contract_Attachments ON Document_Details.Doc_ID = Contract_Attachments.Doc_ID
    INNER JOIN Profiles_Settings PS
    ON		PS.Profiles_ID = #request.accessStructure.Profiles_ID#  AND PS.View_Private_Documents = 1
    WHERE  1= 2
    <CFIF URL.BBID NEQ "">
					 OR (	Contract_Attachments.Billback_ID = '#URL.BBID#'
							AND Contract_Attachments.Deleted = 0
							AND (	(	Public_View = 1
										AND User_Position_ID IN (#preserveSingleQuotes(Access_Position_List)#)
									)
										OR Public_View = 0
								)
						)
				</CFIF>
  ORDER BY Doc_Title

    SELECT DISTINCT * FROM ##TMP_BILLBACK_ATTACHMENTS
</CFQUERY>

<!----<CFSET Form.Attachment_List=ValueList(Display_Attach.Doc_ID)>--->

<!--- If the request is for multiple billbacks, then do not use the list of already saved billbacks as the document list will vary from billback to billback. --->
<CFIF URL.BillbackList eq "">
	<CFPARAM NAME="Form.Attachment_List" DEFAULT="#ValueList(Display_Attach.Doc_ID)#">
<CFELSE>
	<CFPARAM NAME="Form.Attachment_List" DEFAULT="">
</CFIF>


<CFIF Form.Attachment_List NEQ "">
	<CFQUERY NAME="New_Attachments" datasource="#application.datasource#">
		SELECT	*
		FROM	Document_Details
		WHERE	1=2
		<CFIF Len(Form.Attachment_List) GT 0>
			OR 	(
					Document_Details.Doc_ID IN (#ListQualify(FORM.Attachment_List, "'", ",")#)
					AND (	(	Public_View = 1
								AND User_Position_ID IN (#preserveSingleQuotes(Access_Position_List)#)
							)
								OR Public_View = 0
						)
				)
		</CFIF>
			ORDER BY 	Doc_Title
	</CFQUERY>
<cfelse>
	<CFSET New_Attachments = QueryNew("Doc_ID")>
</cfif>

<SCRIPT language = "javascript">
function toaction()
{
	document.Billback_Attachments.action="Attachments_Action.cfm";
	document.Billback_Attachments.submit();
	return false;
}
 <!--- need to hide search documents because newly added/attached documents are not included in the page,
       we will need to refresh the page to get latest --->
 function hide17() { $('#sdoc17').hide(); location.reload(); }
</SCRIPT>

<!--- Diplay Attached Documents --->
<cfset bDocViewer = 0/>
<cfif application.appSettingsGet.get_Setting('BB_Doc_Server_Folder') NEQ ''>
	<cfset bDocViewer = 1/> <!--- LOOK FOR FILES IN DOC SERVER --->
</cfif>
<cfinclude template="/Common_Files/Documents/Document_Include.cfm" />


<CFSET InfoBar_BBID = URL.BBID />
<cfinclude template="billback_load_infobar.cfm" />
<cfinclude template="/Common_Files/dhx_message.cfm" />

<!---  Use flag to choose old Flash upload vs new dropzone upload --->
<!---  WR 95957 SAH: Also, GM will still use the old Flash for thier initial 8.1 Billbacks so keep the old Flash upload for that for now --->
<cfif (application.util.query.get_setting("upload_documents_method", false) EQ "flash") OR 
	  ( (application.util.query.get_setting("GM_BB_upload_documents_method", false) EQ "flash") AND (FORM.FlexAppName EQ "BillbackMain") )>
<!--- CFFILEUPLOAD HERE --->
	<div id="upl17" style="height:250px;overflow:auto">
		<cffileupload
				extensionfilter   = ""
				url               = "ajax/attachments_form.cfm?BBID=#URL.BBID#"
				align             = "left"
				height            = "240"
				width             = "440"
				title             = "Upload documents"
				addbuttonlabel    = "add documents"
				clearbuttonlabel  = "clear"
				deletebuttonlabel = "remove"
				uploadbuttonlabel = "upload"
				onUploadComplete  = "hide17"
				maxfileselect     = "7"
				maxuploadsize     = "10">
		</cffileupload>
	</div>
<cfelse>
<!--- Replace the Flash upload with a javaScript one based on the dropzone.js library --->
	<br>
	<div id="upl18">
		<!------------- Dropzone area ------------->
		<div id="myDropId" class="dropzone dz-clickable">
			<div class="dz-message">
				<img class='ba-dz-message' src='/Images/cloud_343540.svg'>
				&nbsp; Drop documents here or <span style="color:blue">click to upload</span>			
			</div>
		</div>

		<!------------- File list Results area ------------->
		<div class="upl-table" id="previews">      
			<!--- upload result gets put here via shared template --->
		</div>
	</div> <!-- #upl18 -->
	
    <!------------- Dropzone setup ------------->
    <script>
		 setupDropzone(
			"ajax/attachments_form.cfm?BBID=<cfoutput>#URL.BBID#</cfoutput>",	//upload url 
			hide17,	//callback after acknowledging completion
			20,		// max files
			19);	// max size MiB
			
     </script>
</cfif> <!--- end of Dropzone upload --->


<FORM NAME="Billback_Attachments" Action="Attachments_FORM.cfm?BBID=<CFOUTPUT>#URL.BBID#&BillbackList=#URL.BillbackList#&FlexAppName=#FORM.FlexAppName#</CFOUTPUT>" Method="post">


<CFOUTPUT>
<INPUT TYPE="Hidden" ID="Attachment_List" NAME="Attachment_List" VALUE="<cfif isDefined("Form.Attachment_List")>#Form.Attachment_List#</cfif>">
<INPUT TYPE="hidden" NAME="BBID" VALUE="#URL.BBID#">
<INPUT TYPE="hidden" NAME="BillbackList" VALUE="#URL.BillbackList#">
<INPUT TYPE="Hidden" NAME="FlexAppName" VALUE="#FORM.FlexAppName#">

</CFOUTPUT>
<CFIF Display_Attach.recordcount GT 0>
<INPUT TYPE="hidden" NAME="update_state" VALUE="1">
<CFELSE>

<INPUT TYPE="hidden" NAME="update_state" VALUE="0">
</CFIF>
	<TABLE align="center" border="0" width="100%" CELLSPACING="0">
	<!--- Only if the user is allowed to search documents, should the document search be available. --->
	<cfif Get_Profile_Settings.Search_Documents eq 1>
	<TR>
		<TD><br><b>Search documents to attach:</b>&nbsp;&nbsp;&nbsp;&nbsp;
			<B><CFOUTPUT>
			<FONT COLOR="Red">[</FONT>
				<A HREF="/common_files/Documents/Attach_Document.cfm?Form_Name=Billback_Attachments&BillbackList=#URL.BillbackList#&disableUpload=1" id="sdoc17">search documents</A>
			<FONT COLOR="Red">]</FONT>
			</CFOUTPUT></B>
			<cfif application.appSettingsGet.getBillbackFileUploadType() EQ 3 AND CGI.SERVER_NAME CONTAINS 'KRAFT' AND Get_Profile_Settings.Browse_BBDoc_Server_Files EQ 1 >
				<B><CFOUTPUT>
				<FONT COLOR="Red">[</FONT> <!--- LOOK FOR FILES IN DOC SERVER --->
					<A HREF="/common_files/Documents/BrowseBBDocsGet.cfm" onClick="NewWindow(this.href,'attach_win','810','600','Yes', 'No');return false;" >browse documents</A>
				<FONT COLOR="Red">]</FONT>
				</CFOUTPUT></B>
			</cfif>
			<!--- Dev Note: 29841 - Remove the "upload" functionality. We now have "multiple file upload" functionality. --->
			<!---
			<B><CFOUTPUT>
			<FONT COLOR="Red">[</FONT>
				<A HREF="/common_files/documents/create_multiple_document_details.cfm?BBID=#URL.BBID#&BillbackList=#URL.BillbackList#&AttachDoc=1" onClick="NewWindow(this.href,'attach_win','810','600','Yes', 'No');return false;" >upload documents</A>
			<FONT COLOR="Red">]</FONT>
			</CFOUTPUT></B>
			--->
			<hr color="orange">
		</TD>
	</TR>
	</cfif>

	<CFSET Saved_Attachment_List = ValueList(Display_Attach.Doc_ID, ",")>

	<!--- If the request is for multiple billbacks, then do not show "previously saved billbacks" --->
	<cfif URL.BillbackList eq "">
	<TR>
		<TD COLSPAN="100%"><SPAN STYLE="font-size: 12px; font-weight: bold;">Previously saved</TD>
	</TR>
	<TR>
		<TD COLSPAN="100%">
			<TABLE align="center" border="0" width="95%" CLASS="maintable" CELLSPACING="0">
			<CFIF Display_Attach.recordcount GT 0>

				<TR BGCOLOR="#ffce84">
					<TD>&nbsp;</TD>
					<TD ID="headed" STYLE="font-size: 11px; font-weight: bold;">Date / Name</TD>
					<TD ID="header" STYLE="font-size: 11px; font-weight: bold;">File</TD>
					<TD STYLE="font-size: 11px; font-weight: bold;">Title / Description</TD>
					<TD STYLE="font-size: 11px; font-weight: bold;">Type</TD>
				</TR>

			<CFELSE>
				<TR>
					<TD>None Selected</TD>
				</TR>
			</CFIF>

			<CFIF isDefined("Form.Attachment_List")>
				<CFSET Recently_Selected_Attach_List = Form.Attachment_List>
			<CFELSE>
				<CFSET Recently_Selected_Attach_List = Saved_Attachment_List>
			</CFIF>

			<CFOUTPUT QUERY = "Display_Attach">
			<cfset useLakebaseForUser_Name = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForUser_Name>
	<cftry>
		<cfset User_Name = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#Uploaded_By#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUser_Name = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUser_Name>
<CFQUERY NAME="User_Name" DATASOURCE="#Application.Datasource#">
				SELECT Name_First, Name_Last FROM _USERS WHERE User_ID = '#Uploaded_By#'
			</CFQUERY>
</cfif>
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
					<TD WIDTH="3%"><INPUT TYPE="Checkbox" NAME="Doc_ID" VALUE="#Doc_ID#"<CFIF ListFindNoCase(Recently_Selected_Attach_List, Doc_ID, ",")>CHECKED</CFIF>></TD>
					<TD WIDTH="13%">#DateFormat(Uploaded_Date,"mm/dd/yyyy")#<br>#User_Name.Name_First# #User_Name.Name_Last#</TD>
					<CFSET SIZEinMB = #Doc_size#/1048576>
					<!--- CHECK THE DOC SERVER FOR THE FILE FIRST.  MAYBE ONLY DO THIS FOR UPLOADED BB's AND USE OLD LOGIC FOR REGULAR BB's --->
					<cfset variables.Uni_Name = Doc_Uni_Name/>
					<cfif trim(variables.Uni_Name) eq ''>
						<cfset variables.Uni_Name = Doc_File_Name/>
					</cfif>							<!--- OLD:   href="javascript: confirmation('#Doc_Uni_Name#');"--->
					<TD NOWRAP TITLE="File Name: #Doc_File_Name#">
						<cfif bDocViewer eq 1>
							<A href="javascript: confirmDocServerGet('#Doc_File_Name#','#Doc_Uni_Name#');" TITLE="Click here to view '#Doc_File_Name#'">
						<cfelse>
							<A href="javascript: confirmation('#variables.Uni_Name#');" TITLE="Click here to view '#Doc_File_Name#'x#variables.Uni_Name#x">
						</cfif>
						<CFSET Display_Name=Left(Doc_File_Name,20)>
						<CFIF len(trim(Doc_File_Name)) GT 20>
							#LCASE(Display_Name)#...
						<CFELSEIF len(trim(Doc_File_Name)) EQ 0>
							&nbsp;
						<CFELSE>
							#LCASE(Display_Name)#
						</CFIF>
						</A><br>#numberFormat(SIZEinMB,"_.___")# KB</TD>
					<TD WIDTH="58%"><FONT COLOR="red">#Doc_Title#</FONT><BR>Description: #Doc_Description# :: #Doc_File_Name#,#Doc_Uni_Name#</TD>
					<TD WIDTH="12%">#Doc_Type#</TD>
				</TR>
			</CFOUTPUT>
			</TABLE>
		</TD>
	</TR>
	<TR>
		<TD colspan="100%"><hr color="orange"></TD>
	</TR>
	</cfif>

	<TR>
		<TD COLSPAN="100%">
			<SPAN STYLE="font-size: 12px; font-weight: bold;"><BR>Recently selected</SPAN> <FONT COLOR="Red">(not yet saved)</FONT>
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="100%">
			<TABLE align="center" border="0" width="95%" CLASS="maintable" CELLSPACING="0" >
			<CFPARAM NAME="displaynone" DEFAULT="">
			<CFPARAM NAME="FORM.Attachment_List" DEFAULT="">
			<CFLOOP INDEX="item" LIST="#Form.Attachment_List#">
			<CFIF NOT ListFindNoCase(Saved_Attachment_List, item, ",")>
				<CFSET displaynone = 0>
				<TR BGCOLOR="#ffce84">
					<TD>&nbsp;</TD>
					<TD STYLE="font-size: 11px; font-weight: bold;">Date / Name</TD>
					<TD STYLE="font-size: 11px; font-weight: bold;">File</TD>
					<TD STYLE="font-size: 11px; font-weight: bold;">Title / Description</TD>
					<TD STYLE="font-size: 11px; font-weight: bold;">Type</TD>
				</TR>
				<CFBREAK>
			</CFIF>
			</CFLOOP>
			<CFIF displaynone EQ "">
				<TR>
					<TD>None selected</TD>
				</TR>
			</CFIF>
			<CFSET count=0>
			<CFLOOP INDEX="item" LIST="#Form.Attachment_List#">
			<CFIF NOT ListFindNoCase(Saved_Attachment_List, item, ",")>
				<cfset useLakebaseForGet_Document_Selected = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("new_attachments")>
<cfif useLakebaseForGet_Document_Selected>
	<cftry>
		<cfset Get_Document_Selected = application.oLakebase.toQuery(
			application.oLakebase.selectRows("new_attachments", {
				"doc_id" = "eq.#Item#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Document_Selected = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Document_Selected>
<CFQUERY NAME="Get_Document_Selected" DBTYPE="query">
					Select		*
					From		New_Attachments
					Where		Doc_ID	=	'#Item#'
				</CFQUERY>
</cfif>
			<CFOUTPUT QUERY="Get_Document_Selected">
				<CFSET count = count + 1>
				<TR BGCOLOR="#IIf(count Mod 2, DE('ffffff'), DE('C6FFC6'))#">
					<TD WIDTH="3%"><INPUT TYPE="Checkbox" NAME="Doc_ID" VALUE="#Doc_ID#" CHECKED></TD>
					<CFQUERY NAME="User_Name" DATASOURCE="#Application.Datasource#">
						SELECT Name_First, Name_Last FROM _USERS WHERE User_ID = '#Uploaded_By#'
					</CFQUERY>
					<TD WIDTH="13%">#DateFormat(Uploaded_Date,"mm/dd/yyyy")#<br>#User_Name.Name_First# #User_Name.Name_Last#</TD>
					<CFSET SIZEinMB = #Doc_size#/1024>
					<TD NOWRAP TITLE="File Name: #Doc_File_Name#"><A href="javascript: confirmation('#Doc_Uni_Name#');" TITLE="Click here to view '#Doc_File_Name#'">
						<CFSET Display_Name=Left(Doc_File_Name,20)>
						<CFIF len(trim(Doc_File_Name)) GT 20>
							#LCASE(Display_Name)#...
						<CFELSEIF len(trim(Doc_File_Name)) EQ 0>
							&nbsp;
						<CFELSE>
							#LCASE(Display_Name)#
						</CFIF>
						</A><br>#NumberFormat(SIZEinMB,"_.___")#&nbsp;KB</TD>
					<TD WIDTH="58%"><FONT COLOR="red">#Doc_Title#</FONT><BR>Description: #Doc_Description#</TD>
					<TD WIDTH="12%">#Doc_Type#</TD>
				</TR>
			</CFOUTPUT>
			</CFIF>
			</CFLOOP>
			</TABLE>
		</TD>
	</TR>
	<TR>
		<TD colspan="100%"><hr color="orange"></TD>
	</TR>

	<TR>
		<TD colspan="100%" align="center"><BR><BR>
						<CF_button
							button_name		=	""
							button_caption	=	"save documents"
							button_action	=	"javaScript: return toaction()"
							button_type		=	"javascript_link"
							button_width	=	"100"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						>
		</TD>
	</TR>
</TABLE>

</FORM>


<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/script/javascript/jquery.noty.packaged.min.js"></script>

<!--- BSD 11544 --->

<script>
 try { window.parent.dyniframesize(); } catch (err) { };

 $('#sdoc17').click(function() {
  	<cfif Get_Profile_Settings.Search_Documents eq 1>
 		NewWindow(this.href, 'attach_win', '810', '600', 'Yes', 'No');
 	<cfelse>
        noty( {  text: "Sorry! You do not have sufficient permissions to use this option.<br>Please contact your Administrator."
                ,type: 'alert'
                ,buttons: [  { text:'Close Message', addClass:'btn-primary', onClick:function($noty) {  $noty.close(); } } ]
                ,layout: 'bottom' });
  	</cfif>
  	return false;
 });
</script>

</body>
</html>
