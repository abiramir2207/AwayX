<!---
	Name: create_document_details.cfm
	Copyright (c) 2006 Blacksmith Applications, Inc.
	Description:
		document management screen
	Usage:
		used in contracts and settings
	Modified By: Clarence Morse 3/24/2006
	Purpose: enhancements for welcome letter.
--->
<!---
Label 42223 - Unable to upload documents to Billbacks:
	Modified code to bypass the layout menu and use the upload link from version 6.2 only when coming from Billback documents.
	Users were not able to upload and attach documents to Billbacks as expected
--->
<cfparam name="layoutId" default="manageDocuments" />
<cfparam name="Deduction_ID" default="" />
<cfparam name="url.Deduction_ID" default="#Deduction_ID#" />
<CFPARAM NAME="FORM.Form_Name" 	DEFAULT="">
<cfif FORM.Form_Name eq "Billback_Attachments">
	<cfset layoutId = "" />
</cfif>

<!---D40191	Improper styles on upload documents page (from program) START --->
<CFIF NOT isdefined("URL.FromProgram")>
<cfmodule template="/customTags/layout.cfm"
							layoutID = "#layoutId#"
							selectedIndex = "1" >
</CFIF>
<!---D40191	Improper styles on upload documents page (from program) END --->
<!--- Dev Note: KAL - D7443: This stops the [get help] from displaying twice  --->
<CFSET GetHelpURL =1>

<CFPARAM NAME="URL.RID" DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" 	DEFAULT="">
<CFPARAM NAME="FORM.SelectedITEMS" 	DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" 	DEFAULT="">
<CFPARAM NAME="FORM.from_common_attachment" DEFAULT="0">
<CFPARAM NAME="FORM.search" DEFAULT="0">
<CFPARAM NAME="FORM.Doc_type" DEFAULT="">
<CFPARAM NAME="FORM.Doc_Family" DEFAULT="">
<CFPARAM NAME="FORM.Doc_Title" DEFAULT="">
<CFPARAM NAME="FORM.Uploaded_By" DEFAULT="">
<CFPARAM NAME="FORM.Comp_Operator" DEFAULT="">
<CFPARAM NAME="FORM.From_Date" DEFAULT="">
<CFIF isdefined("FORM.To_Date")>
<CFPARAM NAME="FORM.To_Date" DEFAULT="">
</CFIF>
<CFPARAM NAME="Form.Is_Welcome_Letter" DEFAULT="0">
<CFPARAM NAME="FORM.Doc_Description" 	DEFAULT="">
<CFPARAM NAME="FORM.Doc_File_Name" 	DEFAULT="">
<CFPARAM NAME="FORM.Public_View" 	DEFAULT="">
<CFPARAM NAME="FORM.deleted" 		DEFAULT="0">
<CFPARAM NAME="FORM.AttachedTo" 	DEFAULT="">
<CFPARAM NAME="URL.bFromSettings" 	DEFAULT="0">
<CFPARAM NAME="URL.EditFromAdmin" 	DEFAULT="0">
<CFPARAM NAME="URL.BBID"		DEFAULT="">
<CFPARAM NAME="URL.BillbackList"	DEFAULT="">
<cfparam name="URL.FlexAppName"		DEFAULT="">
<CFPARAM NAME="URL.IncompleteDocumentInfo"	DEFAULT="0">
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<cfparam name="url.project" default="0">

<CFIF isdefined("URL.FromProgram")>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET Help_URL="/help_files/manual/createprogram/page2.cfm">
<CFPARAM NAME="URL.CID" 	DEFAULT="">
<CF_CRYP type="de" string="#URL.CID#" key="#request.key#">
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "at">
<cfif URL.FromProgram is 1>
<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 5; left: 10px; top: 0px">
<CFINCLUDE TEMPLATE="/common_files/contracts/contract_status_legend.cfm">
</div>
<cfelse>
<CFINCLUDE TEMPLATE="/common_files/contracts/sales_agreement_status_legend.cfm">
</cfif>
<BLOCKQUOTE>
<BLOCKQUOTE>

<CFELSEIF FORM.Form_Name NEQ "">

<CFELSE>

	<CFIF URL.bFromSettings EQ 1 and URL.EditFromAdmin EQ 0>
		<cfset pageName = "Document Upload" />
		<!--- <CFINCLUDE TEMPLATE="/Common_Files/Documents/Attach_Document_header.cfm"> --->
	</CFIF>
</CFIF>
<cfif URL.EditFromAdmin EQ 1>
	<cfset URL.bFromSettings = 1>
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFINCLUDE TEMPLATE="User_Positions_Under_this_User.cfm">

<cfquery name="qGetAccess_Position_List" datasource="#application.datasource#">
	#PreserveSingleQuotes(GP_Position_List_From_My_Position_Down)#
</cfquery>

<CFSET Access_Position_List = ValueList(qGetAccess_Position_List.Below_User_Positions_ID)>

<CFQUERY NAME="GetPosition" DATASOURCE="#Application.Datasource#">
	SELECT 	User_Positions_ID

	FROM 	User_Position_Holders

	WHERE 	User_ID = '#request.AccessStructure.user_id#' AND
			Deleted = 0
</CFQUERY>
<CFSET UserPositionID = GetPosition.User_Positions_ID>
<!---Tim Ford: Label 24072: Get_Doc_Details query was slowing down the upload documents page. --->
<cfif URL.bFromSettings eq 2>
	<cfset useLakebaseForGetDocDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("document_details")>
	<cfif useLakebaseForGetDocDetails>
		<cftry>
			<cfset getDocDetailsFilter = { "order" = "doc_title.asc" }>
			<cfif isdefined("URL.FromProgram")>
				<cfset getDocDetailsFilter["is_welcome_letter"] = "eq.false">
			</cfif>
			<cfset Get_Doc_Details = application.oLakebase.toQuery(
				application.oLakebase.selectRows("document_details", getDocDetailsFilter)
			)>
			<cfcatch type="any">
				<cfset useLakebaseForGetDocDetails = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForGetDocDetails>
		<CFQUERY NAME="Get_Doc_Details" datasource="#application.datasource#">
			Select		*
			From		Document_Details
			Where 1 = 1
			<CFIF isdefined("URL.FromProgram")>
			AND Is_Welcome_Letter = 0
			</CFIF>
			Order by	Doc_Title
		</CFQUERY>
	</cfif>
</cfif>

<cfset useLakebaseForGetLastUpdatedDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("document_details")>
<cfif useLakebaseForGetLastUpdatedDetails>
	<cftry>
		<cfset getLastUpdatedFilter = { "order" = "uploaded_date.desc", "limit" = "1" }>
		<cfif URL.RID NEQ "">
			<cfset getLastUpdatedFilter["doc_id"] = "eq.#URL.RID#">
		</cfif>
		<cfset Get_LastUpdated_Details = application.oLakebase.toQuery(
			application.oLakebase.selectRows("document_details", getLastUpdatedFilter)
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetLastUpdatedDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetLastUpdatedDetails>
	<CFQUERY NAME="Get_LastUpdated_Details" datasource="#application.datasource#">
		Select		TOP 1 *
		From		Document_Details
		<CFIF URL.RID NEQ "">
		Where		Doc_ID = '#URL.RID#'
		</CFIF>
		Order by	Uploaded_Date Desc
	</CFQUERY>
</cfif>

<CFIF Get_LastUpdated_Details.Recordcount GT 0>
<CFQUERY NAME="getUserName" datasource="#application.datasource#">
	SELECT _Users.Name_First + ' ' + _Users.Name_Last AS User_FullName
	FROM _Users
	WHERE User_ID = '#Get_LastUpdated_Details.LastUpdated_UserId#'
</CFQUERY>
</CFIF>
	<!--- Dev Note:43575 - Remove "Last updated by" information.
	<CFIF IsDefined("getUserName")>
	<TABLE BGCOLOR="White" BORDERCOLOR="Orange" BORDER="1" CELLPADDING="3" CELLSPACING="0" align="center">
	<tr>
		<td>
	<FONT SIZE="2">
		<B>This <cfif url.RID NEQ "">file <cfelse> setting</cfif> was last updated on
			<CFOUTPUT>#dateformat(Get_LastUpdated_Details.Uploaded_Date, 'm/d/yyy')# #timeformat(Get_LastUpdated_Details.Uploaded_Date, 'h:mm:ss TT')#</CFOUTPUT> by
			<CFOUTPUT>#getUserName.User_FullName#</CFOUTPUT></B>
	</FONT>
		</td>
	</tr>
	</table>
	</CFIF>
	--->

<cfif url.project EQ 0 and application.programlayout EQ 1>
<div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 60px; top: 0px;">
</cfif>
	<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" WIDTH="750">


		<TR>
			<!---<cfif variables.bFromSettings eq 1>---> <!---23692: won't dispaly below table on settings/Upload Document page--->
			<cfif URL.bFromSettings eq 2>
			<TD VALIGN="top">

				<SPAN CLASS="title2">Stored Documents</SPAN>
				<HR COLOR="Blue" SIZE="1">
				<DIV STYLE="width:290px; <CFIF Get_Doc_Details.recordcount GT 10>height:330px;</CFIF> overflow:auto;">
			<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" <CFIF Get_Doc_Details.recordcount GT 10>WIDTH="273" <CFELSE>WIDTH="288"</CFIF>  CLASS="Maintable">

					<TR>
						<TD WIDTH="60%"><SPAN STYLE="font-size: 12px;"><B>Title</B></SPAN></TD>
						<TD NOWRAP ><SPAN STYLE="font-size: 12px;"><B>Size(KB)&nbsp;&nbsp;</B></SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN></TD>
					</TR>
					<!--- <CFOUTPUT>#GP_Position_List_From_My_Position_Down#</CFOUTPUT> --->
					<CFSET IsViewable = 0>
					<CFOUTPUT QUERY="Get_Doc_Details">
					<CFIF Public_View EQ 1>
						<CFSET IsViewable = LISTFIND(Access_Position_List,Get_Doc_Details.User_Position_ID,",")>
					</CFIF>
					<CFSET SIZEinMB = Doc_size/1024>

					<CFIF Public_View EQ 0 OR IsViewable NEQ 0>
					<TR>
						<TD WIDTH="60%"><CFIF not isdefined("URL.FromProgram") AND FORM.Form_Name EQ ""><A HREF="create_Document_Details.cfm?RID=#Doc_ID#">#Doc_Title#&nbsp;(#Doc_Type#)</A><CFELSE>#Doc_Title#&nbsp;(#Doc_Type#)</CFIF></TD>
						<TD NOWRAP>&nbsp;&nbsp;&nbsp;#numberformat(SIZEinMB,"_.___")#&nbsp;</TD>
						<TD NOWRAP>&nbsp;&nbsp;&nbsp;&nbsp;
								<CFIF Deleted EQ 0>
								<IMG SRC="/images/yes_small.gif" TITLE="active record...">
								<CFELSE>
								<IMG SRC="/images/no_small.gif" TITLE="inactive record...">
								</CFIF>
						</TD>
					</TR>
					</CFIF>
					</CFOUTPUT>

				</TABLE>
				</DIV>
				<BR>

				<IMG SRC="/images/yes_small.gif" BORDER="0" ALT="" ALIGN="middle"> - active record<BR>
				<IMG SRC="/images/no_small.gif" BORDER="0" ALT="" ALIGN="middle"> - inactive record

			</TD>
			</cfif>
			<TD VALIGN="top" WIDTH="60%">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for the ID of the item passed --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFPARAM NAME="Get_Item.Doc_ID" DEFAULT="">
<CFPARAM NAME="Get_Item.Doc_Uni_Name" DEFAULT="">
<CFPARAM NAME="Get_Item.File_Name" DEFAULT="">
<CFPARAM NAME="Get_Item.Doc_Description" DEFAULT="">
<CFPARAM NAME="Get_Item.Uploaded_Date" DEFAULT="">
<CFPARAM NAME="Get_Item.Uploaded_By" DEFAULT="">
<CFPARAM NAME="Get_Item.Doc_Type" DEFAULT="">
<CFPARAM NAME="Get_Item.Doc_Family" DEFAULT="">
<CFPARAM NAME="Get_Item.Public_View" DEFAULT="">
<CFPARAM NAME="Get_Item.Is_Welcome_Letter" DEFAULT="0">

<CFPARAM NAME="Get_Item.Deleted" DEFAULT="">

			<SPAN CLASS="title2"><CFIF URL.RID NEQ "">Edit<CFELSE>Add</CFIF> Document</SPAN>
			<HR COLOR="Blue" SIZE="1">

<cfset useLakebaseForGetItem = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("document_details")>
<cfif useLakebaseForGetItem>
	<cftry>
		<cfif URL.RID NEQ "">
			<cfset getItemFilter = { "doc_id" = "eq.#URL.RID#" }>
			<cfif isdefined("URL.FromProgram")>
				<cfset getItemFilter["is_welcome_letter"] = "eq.false">
			</cfif>
			<cfset Get_Item = application.oLakebase.toQuery(
				application.oLakebase.selectRows("document_details", getItemFilter)
			)>
		<cfelse>
			<cfset Get_Item = application.oLakebase.toQuery([])>
		</cfif>
		<cfcatch type="any">
			<cfset useLakebaseForGetItem = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetItem>
	<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
		Select		*
		From		document_details
		<CFIF URL.RID NEQ "">
		Where		Doc_ID = '#URL.RID#'
			<CFIF isdefined("URL.FromProgram")>
			AND Is_Welcome_Letter = 0
			</CFIF>
		<CFELSE>
		where 1 = 2
		</CFIF>
	</CFQUERY>
</cfif>

<SCRIPT language="JavaScript">
function alert_and_delete()
{
	var confirmdelete = confirm("Click OK to permanently delete this data. You won't be able to undo this change...");
	if (confirmdelete == true)
	{
		document.all.DeleteRecord.value=1;
		document.MyForm.submit();
	}

}
function validate()
{
	var rid = "<cfoutput>#URL.RID#</cfoutput>";
	x = document.MyForm;
	error = 0;
	if (rid == 0)
	{
		if (x.File_Path.value == "")
		{
			queueMessage("File can't be empty. Please enter some value", document.all.ERR_FILE);
			error = 1;
		}
		{
			clearQueue(document.all.ERR_FILE);
		}
	}
	if (x.Doc_Title.value == "")
	{
		//alert("Title can't be empty. Please, enter some value");
		//x.Doc_Title.focus();
		queueMessage("Title can't be empty. Please enter some value", document.all.ERR_TITLE);
		error = 1;
	}
	else
	{
		clearQueue(document.all.ERR_TITLE);
	}
	if (x.Doc_Description.value == "")
	{
		//alert("Title can't be empty. Please, enter some value");
		//x.Doc_Description.focus();
		queueMessage("Description can't be empty. Please enter some value", document.all.ERR_DESC);
		error = 1;
	}
	else
	{
		clearQueue(document.all.ERR_DESC);
	}
	if (error == 0)
	{
		var upload = "<cfoutput>#url.rid#</cfoutput>";

		if (upload == "")
		{
			var upload_confirm = confirm("Large files may take several minutes to upload...");
			if (upload_confirm == true)
			{
				document.MyForm.submit();
			}
		}
		else
		{
			document.MyForm.submit();
		}
	}
	else
	{
		showMessageWindow();
	}
}
function autofill()
{
	var x = document.MyForm.File_Path.value;
	var len = x.length;
	var position = x.lastIndexOf("\\");
	var filename=x.substr(position+1,len);
	document.all.Doc_File.value = filename;
	document.all.Doc_File_Name_Load.value = filename;
}
var spinnerwind;
function confirmation()
{
	var view_confirm = confirm("Large files may take several minutes to open...");
	if (view_confirm == true)
	{
		NewWindow('<CFOUTPUT>#application.HTTPVar##CGI.server_name#</CFOUTPUT>/GetDocument.cfm?FilePath=data_files/uploaded/documents/uploaded_doc/<cfoutput>#ReReplace(ReReplace(Get_Item.Doc_Uni_Name,"##","&##35;","ALL"),"'","&##39;","ALL")#</cfoutput>', 'name', '800', '600', 'Yes', 'Yes',false,'yes');
		}
}
<CFOUTPUT>
<CFSET Doc_Description_Length = 350>
function CheckLength()
{
	var x=document.MyForm.Doc_Description.value;

	//////Trim extra white space
	var re = /\s+/ig;
	document.MyForm.Doc_Description.value = x.replace(re," ");
	//////Trim extra white space

	x=document.MyForm.Doc_Description.value;

	var len = x.length;
	if (len > #Doc_Description_Length#)
	{
		var trunc_length = confirm("The size of Description is more than 350 characters. Press OK to truncate and save OR press cancel to modify it")
		if (trunc_length == true)
		{
			y=x.substr(0,#Doc_Description_Length#);
			document.MyForm.Doc_Description.value=y;
		}
		else
		{
			document.MyForm.Doc_Description.focus();
		}

	}

}
</CFOUTPUT>
</SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>

<CFOUTPUT>
			<FORM ACTION="Save_Document_Details.cfm?Deduction_ID=#url.Deduction_ID#" METHOD="post" NAME="MyForm" ENCTYPE="multipart/form-data">
				<INPUT TYPE="hidden" NAME="Form_Name" 			VALUE="#FORM.Form_Name#">
				<INPUT TYPE="hidden" NAME="FinalItemList" 			VALUE="#Form.FinalItemList#">
				<INPUT TYPE="hidden" NAME="AlreadySelectedItems" 	VALUE="#Form.AlreadySelectedItems#">
				<INPUT TYPE="hidden" NAME="SelectedITEMS" 	VALUE="#Form.SelectedITEMS#">
				<INPUT TYPE="hidden" NAME="upload_referer" 	VALUE="#CGI.http_referer#">
				<INPUT TYPE="hidden" NAME="from_common_attachment" 	VALUE="#FORM.from_common_attachment#">
				<INPUT TYPE="hidden" NAME="search" 	VALUE="#FORM.search#">
				<INPUT TYPE="hidden" NAME="Doc_type2" 	VALUE="#FORM.Doc_type#">
				<INPUT TYPE="hidden" NAME="Doc_Family2" 	VALUE="#FORM.Doc_Family#">
				<INPUT TYPE="hidden" NAME="Uploaded_By2" 	VALUE="#FORM.Uploaded_By#">
				<INPUT TYPE="hidden" NAME="Doc_Title2" 	VALUE="#FORM.Doc_Title#">
				<INPUT TYPE="hidden" NAME="Comp_Operator2" 	VALUE="#FORM.Comp_Operator#">
				<INPUT TYPE="hidden" NAME="From_Date2" 	VALUE="#FORM.From_Date#">
				<INPUT TYPE="hidden" NAME="Doc_Description2"	VALUE="#FORM.Doc_Description#">
				<INPUT TYPE="hidden" NAME="Doc_File_Name2" 	VALUE="#FORM.Doc_File_Name#">
				<INPUT TYPE="hidden" NAME="Public_View2" 	VALUE="#FORM.Public_View#">
				<INPUT TYPE="hidden" NAME="deleted2" 	VALUE="#FORM.deleted#">
				<INPUT TYPE="hidden" NAME="AttachedTo2" 	VALUE="#FORM.AttachedTo#">
				<INPUT TYPE="hidden" NAME="bFromSettings" 	VALUE="#URL.bFromSettings#">
				<INPUT TYPE="hidden" NAME="BBID" 		VALUE="#URL.BBID#">
				<INPUT TYPE="hidden" NAME="BillbackList" 	VALUE="#URL.BillbackList#">
				<INPUT TYPE="hidden" NAME="FlexAppName" 	VALUE="#URL.FlexAppName#">
				<INPUT TYPE="hidden" NAME="IncompleteDocumentInfo" VALUE="#URL.IncompleteDocumentInfo#">


				<CFIF isdefined("FORM.To_Date")>
				<INPUT TYPE="hidden" NAME="To_Date2" 	VALUE="#FORM.To_Date#">
				</CFIF>
				<CFIF isdefined("FORM.Is_Welcome_Letter2")>
					<input type="hidden" name="is_welcome_letter2" value="#Form.is_welcome_letter#">
				</CFIF>
				</CFOUTPUT>
				<CFOUTPUT>
				<CFIF isdefined("URL.FromProgram")>

					<INPUT TYPE="hidden" NAME="back_to_program" VALUE="#URL.CID#">
					<cfif URL.FromProgram eq 0>
					  <INPUT TYPE="hidden" NAME="pageName" VALUE="1">
				    </cfif>
					<CFIF isdefined("URL.Uploaded_By")>
						<INPUT TYPE="hidden" NAME="UUploaded_By" VALUE="#URL.Uploaded_By#">
					</CFIF>
					<CFIF isdefined("URL.Doc_Type")>
						<INPUT TYPE="hidden" NAME="UDoc_Type" VALUE="#URL.Doc_Type#">
					</CFIF>
					<CFIF isdefined("URL.Doc_Family")>
						<INPUT TYPE="hidden" NAME="UDoc_Family" VALUE="#URL.Doc_Family#">
					</CFIF>
					<CFIF isdefined("URL.Comp_Operator")>
						<INPUT TYPE="hidden" NAME="UComp_Operator" VALUE="#URL.Comp_Operator#">
					</CFIF>
					<CFIF isdefined("URL.From_Date")>
						<INPUT TYPE="hidden" NAME="UFrom_Date" VALUE="#URL.From_Date#">
					</CFIF>
					<CFIF isdefined("URL.To_Date")>
						<INPUT TYPE="hidden" NAME="UTo_Date" VALUE="#URL.To_Date#">
					</CFIF>
					<CFIF isdefined("URL.Doc_Title")>
						<INPUT TYPE="hidden" NAME="UDoc_Title" VALUE="#URL.Doc_Title#">
					</CFIF>
					<!--- Dev Note: Clay 9254: Welcome Letter Control   --->
					<CFIF isdefined("URL.Is_Welcome_Letter")>
						<INPUT TYPE="hidden" NAME="UIs_Welcome_Letter" VALUE="#URL.Is_Welcome_Letter#">
					</CFIF>
				</CFIF>
				<INPUT TYPE="hidden" NAME="Doc_ID" VALUE="#Get_Item.Doc_ID#"><!--- #request.AccessStructure.Name_First# #request.AccessStructure.Name_Last# --->
				<INPUT TYPE="hidden" NAME="Uploaded_By" VALUE="<CFIF Get_Item.Uploaded_By EQ "">#request.AccessStructure.User_ID#<CFELSE>#Get_Item.Uploaded_By#</CFIF>" MAXLENGTH="50">
				</CFOUTPUT>
				<TABLE CELLSPACING="5" CELLPADDING="0">
					<CFIF URL.RID NEQ "">
					<TR>
						<TD VALIGN="top" ALIGN="right" NOWRAP>

						</TD>
					</TR>
					</CFIF>

					<Cfif isDefined("url.Error")>
					<TR>
						<TD VALIGN="top" ALIGN="right" NOWRAP><SPAN ID="ERR_FILE"></SPAN>&nbsp;</TD>
						<CFOUTPUT>
						<TD VALIGN="top"><cfif url.Error IS 1><Font color="red"><strong>The file you uploaded was not a valid file, or did not have any data. Please select the file you wish to upload using the browse button below.</strong></FONT></cfif></TD>
						</CFOUTPUT>
					</TR>

					</CFIF>

					<CFIF URL.RID EQ "">
					<TR>
						<TD VALIGN="top" ALIGN="right" NOWRAP><SPAN ID="ERR_FILE"></SPAN>&nbsp;<B>Select Upload File </B></TD>
						<CFOUTPUT>
						<TD VALIGN="top"><INPUT SIZE="45" TYPE="file" NAME="File_Path" onChange="javascript: autofill()"></TD>
						</CFOUTPUT>
					</TR>
					</CFIF>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>File Name</B></TD>
						<CFOUTPUT>
						<TD VALIGN="top"><INPUT SIZE="45" NAME="Doc_File" VALUE="#ReReplace(ReReplace(Get_Item.Doc_Uni_Name,"##","&##35;","ALL"),"'","&##39;","ALL")#" MAXLENGTH="50" READONLY DISABLED>
										<INPUT TYPE="hidden" NAME="Doc_File_Name_Load" VALUE="#ReReplace(ReReplace(Get_Item.Doc_Uni_Name,"##","&##35;","ALL"),"'","&##39;","ALL")#">
						<CFIF Get_Item.Doc_TITLE NEQ "">
							<FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
							<A href="javascript: confirmation(); "  TITLE="Click on this link to view this document"><B>view</b></A>
							<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
						</CFIF>
						</TD></CFOUTPUT>

					</TR>

					<TR>
						<TD VALIGN="top" ALIGN="right"><SPAN ID="ERR_TITLE"></SPAN>&nbsp;<B>Title</B></TD>
						<CFOUTPUT>
						<TD VALIGN="top"><INPUT SIZE="45" NAME="Doc_Title" VALUE="#Get_Item.Doc_Title#" MAXLENGTH="45">

						</TD>
						</CFOUTPUT>
					</TR>


					<!--- Dev Note: CPM 8275 --->
					<!--- Function: Implementing use of application switch to set document privacy flag default setting. --->

					<cfset PrivacyOff = application.oApplicationAppSettingsManager.getApplicationAppSettings().getUploadDocumentPrivacyOff()>

					<cfif PrivacyOff EQ 0>
						<CFSET PublicChecked = "Checked">
					<cfelse>
						<CFSET PublicChecked = "">
					</cfif>


					<cfif Get_Item.RecordCount GT 0>
						<CFIF Get_Item.Public_View EQ 0>
							<CFSET PublicChecked = "">
						<CFELSE>
							<CFSET PublicChecked = "Checked">
						</CFIF>
					</cfif>
					<!--- End Dev Note: CPM 8275 --->
					<TR>
						<TD VALIGN="Top" ALIGN="Right"><SPAN ID="ERR_PUBLIC"></SPAN>&nbsp;<B>Private</B></TD>
						<CFOUTPUT>
						<TD VALIGN="Top"><CFOUTPUT><INPUT TYPE="CheckBox" NAME="Doc_Public" VALUE="1" #PublicChecked#></CFOUTPUT></TD>
						</CFOUTPUT>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"><SPAN ID="ERR_DESC"></SPAN>&nbsp;<B>Description</B></TD>
						<CFOUTPUT>
						<TD VALIGN="top"><TEXTAREA COLS="47" ROWS="6" NAME="Doc_Description" ONBLUR="Javascript: CheckLength()" <!---onPaste="javaScript: return textareaChecklength(#Doc_Description_Length#, this);"  onkeyPress="javaScript: return textareaChecklength(#Doc_Description_Length#, this);" --->>#Get_Item.Doc_Description#</TEXTAREA></TD> <!--- <INPUT SIZE="45" NAME="Doc_Description" VALUE="#Get_Item.Doc_Description#" MAXLENGTH="50"> --->
						</CFOUTPUT>
					</TR>
					<!--- <TR>
						<TD VALIGN="top" ALIGN="right"><B>Uploaded By</B></TD>
						<CFOUTPUT>
						<TD VALIGN="top"><INPUT SIZE="45" NAME="Uploaded_By" VALUE="#Get_Item.Uploaded_By##request.AccessStructure.Name_First# #request.AccessStructure.Name_Last#" MAXLENGTH="50">
						</CFOUTPUT>
					</TR> --->
					<cfset useLakebaseForListDocType2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("document_type")>
					<cfif useLakebaseForListDocType2>
						<cftry>
							<cfset List_Doc_Type = application.oLakebase.toQuery(
								application.oLakebase.selectRows("document_type", { "deleted" = "eq.false" })
							)>
							<cfcatch type="any">
								<cfset useLakebaseForListDocType2 = false>
							</cfcatch>
						</cftry>
					</cfif>
					<cfif NOT useLakebaseForListDocType2>
						<CFQUERY NAME = "List_Doc_Type" DATASOURCE = "#Application.Datasource#">
							SELECT * from Document_Type WHERE Deleted = 0
						</CFQUERY>
					</cfif>
					<TR>
						<TD VALIGN="top" ALIGN="right" NOWRAP><B>Document Type</B></TD>
						<TD VALIGN="top">
						<CFPARAM NAME="FORM.Doc_Type" DEFAULT="Cover Letter">

							<SELECT NAME="Doc_Type" style="WIDTH:258px;">
							<CFOUTPUT QUERY="List_Doc_Type">
								<OPTION VALUE="#Doc_Type#" <CFIF List_Doc_Type.Doc_type EQ Get_Item.Doc_Type>SELECTED<CFELSEIF List_Doc_Type.Doc_type EQ FORM.Doc_Type>SELECTED</CFIF> >#Doc_type#</OPTION>
							</CFOUTPUT>
							</SELECT>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Availability</B></TD>
						<TD VALIGN="top">
						<!--- Is this record deleted? --->
						<CFIF Get_Item.Deleted EQ 0 OR Get_Item.Deleted EQ "">
							<CFSET active=" CHECKED">
							<CFSET inactive="">
						<CFELSE>
							<CFSET active="">
							<CFSET inactive=" CHECKED">
						</CFIF>

						<CFOUTPUT>
						<INPUT TYPE="radio" VALUE="0" NAME="Deleted"#active#>Active
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<INPUT TYPE="radio" VALUE="1" NAME="Deleted"#inactive#<CFIF isdefined("URL.FromProgram") OR FORM.Form_Name NEQ ""> DISABLED</CFIF>>Inactive
						</CFOUTPUT>

						</TD>
					</TR>

					<!--- This app setting has been removed --->
					<!---
					<cfif appSettings.getWelcomeLetterOn()>
					<!--- Dev Note: Clay 9254: Add Welcome Letter  --->
					<TR title="Documents of this type are not viewable or searchable in program document management views.">
						<TD VALIGN="top" ALIGN="right"><B>Welcome Letter</B></TD>
						<TD VALIGN="top">

						<!--- Is this record deleted? --->
						<CFIF Get_Item.Is_Welcome_Letter EQ 0 OR len(Get_Item.Is_Welcome_Letter) EQ 0>
							<CFSET active="">
							<CFSET inactive=" CHECKED">
						<CFELSE>
							<CFSET active=" CHECKED">
							<CFSET inactive="">
						</CFIF>
						<CFOUTPUT>
						<INPUT TYPE="radio" VALUE="1" NAME="Is_Welcome_Letter" #active# <CFIF isdefined("URL.FromProgram") OR FORM.Form_Name NEQ ""> DISABLED</CFIF>>On
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<INPUT TYPE="radio" VALUE="0" NAME="Is_Welcome_Letter" #inactive# <CFIF isdefined("URL.FromProgram") OR FORM.Form_Name NEQ ""> DISABLED</CFIF> >Off
						</CFOUTPUT>
						</TD>
					</TR>
					<!--- End Dev Note: Clay 9254 --->
					</cfif>
					--->

					<TR>
						<TD VALIGN="top" ALIGN="right"></TD>
						<TD VALIGN="top">
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: validate();"><B>save data</B></A>
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>

							<INPUT TYPE="hidden" NAME="DeleteRecord" VALUE="0">
							<CFIF Get_Item.Deleted EQ 1>
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: alert_and_delete();"><B>delete data</B></A><!--- HREF="javascript: document.MyForm.submit() href="#" ONCLICK="document.all.DeleteRecord.value=1;document.MyForm.submit();"--->
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
							</CFIF>
							<cfif URL.EditFromAdmin EQ 1>
								<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT><A HREF="javascript: window.close();"><B>close</B></A><FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
							</CFIF>

							<CFIF URL.RID EQ "">
							<FONT COLOR="#ff0000" SIZE="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>file size limit: 10MB</b>
							<FONT COLOR="#ff0000" SIZE="2">
							</CFIF>

							<!--- (*) A disabled "inactive" choice indicates that there is at least one active project that has this status. Thus, the user will not be able to make this status inactive. --->


						</TD>
					</TR>
				</TABLE>

			</FORM>
			<CFOUTPUT>

			<FORM Action="#CGI.http_referer#" METHOD="POST" NAME="Back_to_common_Search">
			<INPUT TYPE="hidden" NAME="Form_Name" VALUE="#FORM.Form_Name#">
			<INPUT TYPE="hidden" NAME="FinalItemList" VALUE="#Form.FinalItemList#">
			<INPUT TYPE="hidden" NAME="AlreadySelectedItems" VALUE="#Form.AlreadySelectedItems#">
			<INPUT TYPE="hidden" NAME="SelectedITEMS" VALUE="#Form.SelectedITEMS#">

			<INPUT TYPE="hidden" NAME="search" VALUE="#Form.search#">

			<INPUT TYPE="hidden" NAME="Doc_type" VALUE="#FORM.Doc_type#">
			<INPUT TYPE="hidden" NAME="Doc_Family" VALUE="#FORM.Doc_Family#">
			<INPUT TYPE="hidden" NAME="Doc_Title" VALUE="#FORM.Doc_Title#">
			<INPUT TYPE="hidden" NAME="Uploaded_By" VALUE="#FORM.Uploaded_By#">
			<INPUT TYPE="hidden" NAME="Comp_Operator" VALUE="#FORM.Comp_Operator#">
			<INPUT TYPE="hidden" NAME="From_Date" VALUE="#FORM.From_Date#">
			<CFIF isdefined("FORM.To_Date")>
				<INPUT TYPE="hidden" NAME="To_Date" VALUE="#FORM.To_Date#">
			</CFIF>
			<INPUT TYPE="hidden" NAME="Is_Welcome_Letter" VALUE="#Form.Is_Welcome_Letter#">
			<INPUT TYPE="hidden" NAME="Doc_Description"	VALUE="#FORM.Doc_Description#">
			<INPUT TYPE="hidden" NAME="Doc_File_Name" 	VALUE="#FORM.Doc_File_Name#">
			<INPUT TYPE="hidden" NAME="Public_View" 	VALUE="#FORM.Public_View#">
			<INPUT TYPE="hidden" NAME="deleted" 	VALUE="#FORM.deleted#">
			<INPUT TYPE="hidden" NAME="AttachedTo" 	VALUE="#FORM.AttachedTo#">

			</FORM>
			</CFOUTPUT>
			</TD>
		</TR>
	</TABLE>
<CFOUTPUT>
<SCRIPT language="JavaScript">
	function gobacktocommonsearch()
	{
		var searchform = document.Back_to_common_Search;
		if (searchform.Doc_type.value == ""  &&  searchform.Doc_Family.value == ""  &&  searchform.Doc_Title.value == ""  &&  searchform.Uploaded_By.value == ""  &&  searchform.Comp_Operator.value == ""   &&  searchform.From_Date.value == ""  &&  searchform.Doc_Description.value == ""  &&  searchform.Doc_File_Name.value == "" &&  ( searchform.AttachedTo.value == "0" || searchform.AttachedTo.value == ""))
		{
			searchform.deleted.value = "2";
		}
		searchform.submit();
	}
</SCRIPT>
</CFOUTPUT>
<!---
<CFIF isdefined("URL.FromProgram")>
<CFOUTPUT>
		<CFSET URLSTRING = "">
		<CFIF isdefined("URL.Uploaded_By")>
			<CFSET URLSTRING ="&Uploaded_By=#URL.Uploaded_By#">
		</CFIF>
		<CFIF isdefined("URL.Doc_Type")>
			<CFSET URLSTRING="#URLSTRING#&Doc_Type=#URL.Doc_Type#">
		</CFIF>
		<CFIF isdefined("URL.Doc_Family")>
			<CFSET URLSTRING="#URLSTRING#&Doc_Family=#URL.Doc_Family#">
		</CFIF>
		<CFIF isdefined("URL.Comp_Operator")>
			<CFSET URLSTRING="#URLSTRING#&Comp_Operator=#URL.Comp_Operator#&From_Date=#URL.From_Date#">
		</CFIF>
		<CFIF isdefined("URL.To_Date")>
			<CFSET URLSTRING="#URLSTRING#&To_Date=#URL.To_Date#">
		</CFIF>
		<CFIF isdefined("URL.Doc_Title")>
			<CFSET URLSTRING="#URLSTRING#&Doc_Title=#URL.Doc_Title#">
		</CFIF>
		<!---  <CFLOCATION  URL="/common_files/contracts/contract_attachments.cfm?CID=#FORM.back_to_program#&search=1#URLSTRING#" ADDTOKEN="No">  --->

 <B>
<FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="/common_files/contracts/contract_attachments.cfm?CID=#URL.CID#&search=1#URLSTRING#"><B>back to documents</B></A>
<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
</B>
</CFOUTPUT>
</BLOCKQUOTE>
</BLOCKQUOTE>
<CFELSEIF FORM.Form_Name NEQ "">
--->
<cfif FORM.Form_Name NEQ "">
<BR><BR><BR><B>
<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="#" ONCLICK="javascript:gobacktocommonsearch()"><B>back to search tool</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>

<cfelseif URL.bFromSettings>
<!--- Removed by 23692
<cfelseif variables.bFromSettings>
<B>
<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="create_Document_Details.cfm"><B>create new entry</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>
--->
<B>
<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="create_Document_Type.cfm"><B>update document type list</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>
</CFIF>




<CF_MessageWindow>
<cfif url.project eq 0 and application.programlayout EQ 1>
</div></cfif>
<CFIF isdefined("URL.FromProgram")>
<CFINCLUDE TEMPLATE = "/includes/footer.cfm">
</CFIF>
<!---
D40191	Improper styles on upload documents page (from program)
</cfmodule>
--->
