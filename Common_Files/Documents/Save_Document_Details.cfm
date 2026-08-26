<!---
	Name: save_document_details.cfm
	Copyright (c) 2006 Blacksmith Applications, Inc.

	Description:
		contains save document logic
	Modified By: Clarence Morse 3/24/2006
	Purpose: enhancements for welcome letter.
--->
<CFPARAM NAME="FORM.IS_WELCOME_LETTER" DEFAULT="0">
<CFPARAM NAME="Form.bFromSettings" DEFAULT="0">
<CFPARAM NAME="FORM.BBID"		DEFAULT="">
<CFPARAM NAME="FORM.BillbackList"	DEFAULT="">
<cfparam name="FORM.FlexAppName"	DEFAULT="">
<CFPARAM NAME="FORM.IncompleteDocumentInfo" DEFAULT="0">

<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<cfset useLakebaseForDeleteAttachment = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
	<cfif useLakebaseForDeleteAttachment>
		<cftry>
			<cfset application.oLakebase.updateRows("contract_attachments",
				{ "doc_id" = "eq.#FORM.Doc_ID#" },
				{ "deleted" = true }
			)>
			<cfcatch type="any">
				<cfset useLakebaseForDeleteAttachment = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDeleteAttachment>
		<cfset useLakebaseForDelete_attachment = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
<cfif useLakebaseForDelete_attachment>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_attachments",
			{
				"doc_id" = "eq.#FORM.Doc_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDelete_attachment = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete_attachment>
<CFQUERY NAME="Delete_attachment" DATASOURCE="#application.datasource#">
			UPDATE Contract_Attachments
			SET Deleted = 1 WHERE Doc_ID = '#FORM.Doc_ID#'
		</CFQUERY>
</cfif>
	</cfif>

	<cfset useLakebaseForDeleteData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("document_details")>
	<cfif useLakebaseForDeleteData>
		<cftry>
			<cfset application.oLakebase.deleteRows("document_details", { "doc_id" = "eq.#Form.Doc_ID#" })>
			<cfcatch type="any">
				<cfset useLakebaseForDeleteData = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDeleteData>
		<cfset useLakebaseFordelete_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("document_details")>
<cfif useLakebaseFordelete_Data>
	<cftry>
		<cfset application.oLakebase.deleteRows("document_details", {
			"doc_id" = "eq.#Form.Doc_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseFordelete_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordelete_Data>
<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
			DELETE FROM Document_Details
			WHERE		Doc_ID				=	'#Form.Doc_ID#'
		</CFQUERY>
</cfif>
	</cfif>
	<CFLOCATION URL="create_Document_Details.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>



<!--- <CFIF Form.Deleted EQ 1 AND Form.Doc_ID NEQ "">
	<CFOUTPUT>
	<CFQUERY NAME="Check_bef_deleted" DATASOURCE = "#Application.Datasource#">
		SELECT * from Contract_Attachments where DOC_ID = '#FORM.Doc_ID#' and Deleted = 0
	</CFQUERY>
	<CFIF Check_bef_deleted.recordcount GT 0>
		<BR><BR><BR><BR>
		<TABLE ALIGN="CENTER">
		  <TR>
	  		<TD>This Document is part to a program. You cannot make this Document inactive.</TD>
		  </TR>
		</TABLE>
		<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 3000);</SCRIPT>
	<CFABORT>
	</CFIF>

	</CFOUTPUT>
</CFIF> --->

<!--- <CFSET search = ".">
<CFSET content = FORM.File_Path>
<CFSET family = Find(search,content)>
<CFSET length = len(FORM.File_Path)>
<CFSET right_len = length-family>
<CFSET family = right(FORM.File_Path,right_len)> --->




<CFIF Form.Doc_ID EQ "">
<!---Check size of file being uploaded--->

<cfset TempDirectoryLocation = GetDirectoryFromPath(FORM.File_Path)>
<cfset TempFileName = GetFileFromPath(FORM.File_Path)>
<cfdirectory directory="#TempDirectoryLocation#" filter="#TempFileName#" name="Tempdirectory">
<Cfset FileSize = Tempdirectory.Size>
<!---If they uploaded a zero length or invalid file, redirect back with error information--->
<Cfif Filesize LT 1>
	<BR><BR><BR><BR>
		<TABLE ALIGN="CENTER">
		  <TR>
	  		<TD style="font-weight:bold;">The size of the uploaded file is 0 bytes.&nbsp;&nbsp;Please upload a larger file.</TD>
		  </TR>
		</TABLE>
		<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 7000);</SCRIPT>
	<CFABORT>
</CFIF>

<CFFILE ACTION = "upload"
			FILEFIELD = "File_Path"
			DESTINATION = "#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_doc"
			NAMECONFLICT ="MakeUnique">

	<CFSET Temp_File_name = CFFILE.serverFile>

	<CFSET sizeoffile = CFfile.FileSize>
	<CFIF sizeoffile GT 10485760><!--- 5242880 --->
		<cffile action = "delete"
  				file = "#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_doc\#temp_file_name#">

		<BR><BR><BR><BR>
		<TABLE ALIGN="CENTER">
		  <TR>
	  		<TD style="font-weight:bold;">The size of the uploaded file is more than 10MB.&nbsp;&nbsp;Please upload a smaller file.</TD>
		  </TR>
		</TABLE>
		<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 7000);</SCRIPT>
	<CFABORT>

	</CFIF>

	<CFSET search = ".">
	<CFSET content = Temp_File_name>
	<CFSET family = Find(search,content)>
	<CFSET length = len(content)>
	<CFSET right_len = length-family>
	<CFSET family = ListLast(content, ".")>

<cffile action="upload" destination="#Application.Doc_Path#\Data_Files\Uploaded\Documents\Uploaded_Doc\" nameconflict="makeunique">

	<cfset useLakebaseForGetPosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_position_holders")>
<cfif useLakebaseForGetPosition>
	<cftry>
		<cfset GetPosition = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_position_holders", {
				"user_id" = "eq.#request.AccessStructure.user_id#",
				"user_position_type" = "eq.P",
				"deleted" = "eq.0",
				"select" = "user_positions_id"
			}), "user_positions_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetPosition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetPosition>
<CFQUERY NAME="GetPosition" DATASOURCE="#Application.Datasource#">
		SELECT 	User_Positions_ID
		FROM 	User_Position_Holders
		WHERE 	User_ID = '#request.AccessStructure.user_id#'
		AND User_Position_Type = 'P'
		AND Deleted = 0
	</CFQUERY>
</cfif>

<!--- Insert the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		SET NOCOUNT ON
		INSERT INTO		Document_Details
						(	Doc_Uni_Name,
							Doc_Title,
							Doc_Description,
							Uploaded_Date,
							Uploaded_By,
							Doc_Type,
							Doc_Family,
							Deleted,
							Doc_File_Name,
							Doc_Size,
							LastUpdated_UserId,
							User_Position_ID,
							Public_View,
							Is_Welcome_Letter
						)

		Values			(	'#cffile.serverFile#',
							'#Form.Doc_Title#',
							'#Form.Doc_Description#',
							#now()#,
							'#Form.Uploaded_By#',
							'#Form.Doc_type#',
							'#family#',
							#Form.Deleted#,
							'#Form.Doc_File_Name_Load#',
							#sizeoffile#,
							'#Form.Uploaded_By#',
							#GetPosition.User_Positions_ID#,
							<CFIF IsDefined("FORM.Doc_Public")>
							1
							<CFELSE>
							0
							</CFIF>,
							#Form.Is_Welcome_Letter#
						)
		SELECT Doc_ID = @@IDENTITY

		SET NOCOUNT OFF
	</CFQUERY>

<cfset DocId = Save_Data.Doc_ID>

<cfif len(url.Deduction_ID) AND URL.Deduction_ID NEQ '0'>
	<cfset useLakebaseForAttachDoc = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
	<cfif useLakebaseForAttachDoc>
		<cftry>
			<cfset application.oLakebase.insertRow("contract_attachments", {
				"deduction_id" = url.Deduction_ID,
				"doc_id" = DocId,
				"deleted" = false
			})>
			<cfcatch type="any">
				<cfset useLakebaseForAttachDoc = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForAttachDoc>
		<cfset useLakebaseForAttach_doc = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
<cfif useLakebaseForAttach_doc>
	<cftry>
		<cfset application.oLakebase.insertRow("contract_attachments", {
			"deduction_id" = "#url.Deduction_ID#",
			"doc_id" = "#DocId#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForAttach_doc = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAttach_doc>
<CFQUERY NAME="Attach_doc" datasource="#application.datasource#">
			INSERT INTO Contract_Attachments (	Deduction_ID,	Doc_ID )
			VALUES	( '#url.Deduction_ID#',	'#DocId#')
		</CFQUERY>
</cfif>
	</cfif>
</cfif>

	<cfif  Form.bFromSettings EQ 1>
		<script>
			window.opener.location.reload();
			window.close();
		</script>

	</cfif>

	<cfset pageName = 0 />
	<CFSET backtocreate=1>
	<CFSET URLSTRING = "">
	<CFIF isdefined("FORM.back_to_program")>
		<CFSET backtocreate=0>
		<CFOUTPUT>
		<CFSET URLSTRING = "CID=#FORM.back_to_program#">
		<CFIF isdefined("FORM.UUploaded_By")>
			<CFSET URLSTRING ="#URLSTRING#&Uploaded_By=#FORM.Uploaded_By#">
		</CFIF>
		<CFIF isdefined("FORM.UDoc_Type")>
			<CFSET URLSTRING="#URLSTRING#&Doc_Type=#FORM.UDoc_Type#">
		</CFIF>
		<CFIF isdefined("FORM.UDoc_Family")>
			<CFSET URLSTRING="#URLSTRING#&Doc_Family=#FORM.UDoc_Family#">
		</CFIF>
		<CFIF isdefined("FORM.UComp_Operator")>
			<CFSET URLSTRING="#URLSTRING#&Comp_Operator=#FORM.UComp_Operator#&From_Date=#FORM.UFrom_Date#">
		</CFIF>
		<CFIF isdefined("FORM.UTo_Date")>
			<CFSET URLSTRING="#URLSTRING#&To_Date=#FORM.UTo_Date#">
		</CFIF>
		<CFIF isdefined("FORM.UDoc_Title")>
			<CFSET URLSTRING="#URLSTRING#&Doc_Title=#FORM.UDoc_Title#">
		</CFIF>
		<CFIF isdefined("FORM.UIS_Welcome_Letter")>
			<CFSET URLSTRING="#URLSTRING#&Is_Welcome_Letter=#FORM.Is_Welcome_Letter#">
		</CFIF>

	<!--- 	 <CFLOCATION  URL="/common_files/contracts/contract_attachments.cfm?CID=#FORM.back_to_program#&search=1#URLSTRING#" ADDTOKEN="No">  --->
		</CFOUTPUT>

	</CFIF>
	<cfif structKeyExists(form,"pageName")>
	 <cfset pageName = 1 />
	</cfif>
	<BR><BR><BR><BR>
<TABLE ALIGN="CENTER">
	<TR>
		<TD>Please wait while the file is being uploaded....</TD>
	</TR>
</TABLE>

<CFOUTPUT>
<FORM Action = "#FORM.upload_referer#" METHOD = "POST" NAME = "Back_to_common_Search">
	<CFPARAM NAME="FORM.AlreadySelectedItems" 	DEFAULT="">
	<CFPARAM NAME="FORM.SelectedITEMS" 	DEFAULT="">
	<CFPARAM NAME="FORM.FinalItemList" 	DEFAULT="">
	<CFPARAM NAME="FORM.Form_Name" 	DEFAULT="">
	<CFPARAM NAME="FORM.from_common_attachment" DEFAULT="0">
	<CFPARAM NAME="FORM.search" DEFAULT="0">
	<CFPARAM NAME="FORM.Doc_type2" DEFAULT="">
	<CFPARAM NAME="FORM.Doc_Family2" DEFAULT="">
	<CFPARAM NAME="FORM.Doc_Title2" DEFAULT="">
	<CFPARAM NAME="FORM.Uploaded_By2" DEFAULT="">
	<CFPARAM NAME="FORM.Comp_Operator2" DEFAULT="">
	<CFPARAM NAME="FORM.From_Date2" DEFAULT="">
	<CFPARAM NAME="FORM.Doc_ID" DEFAULT="">
	<CFIF isdefined("FORM.To_Date2")>
	<CFPARAM NAME="FORM.To_Date2" DEFAULT="">
	</CFIF>
	<CFIF isdefined("FORM.Is_Welcome_Letter")>
	<CFPARAM NAME="FORM.Is_Welcome_Letter" DEFAULT="0">
	</CFIF>

	<INPUT TYPE="hidden" NAME="Form_Name" 			VALUE="#FORM.Form_Name#">
	<INPUT TYPE="hidden" NAME="FinalItemList" 			VALUE="#Form.FinalItemList#">
	<INPUT TYPE="hidden" NAME="AlreadySelectedItems" 	VALUE="#Form.AlreadySelectedItems#">
	<INPUT TYPE="hidden" NAME="SelectedITEMS" 	VALUE="#Form.SelectedITEMS#">
	<INPUT TYPE="hidden" NAME="search" 	VALUE="#Form.search#">
	<INPUT TYPE="hidden" NAME="Doc_type" 	VALUE="#FORM.Doc_type2#">
	<INPUT TYPE="hidden" NAME="Doc_Family" 	VALUE="#FORM.Doc_Family2#">
	<INPUT TYPE="hidden" NAME="Doc_Title" 	VALUE="#FORM.Doc_Title2#">
	<INPUT TYPE="hidden" NAME="Uploaded_By" 	VALUE="#FORM.Uploaded_By2#">
	<INPUT TYPE="hidden" NAME="Comp_Operator" 	VALUE="#FORM.Comp_Operator2#">
	<INPUT TYPE="hidden" NAME="From_Date" 	VALUE="#FORM.From_Date2#">
	<INPUT TYPE="hidden" NAME="Doc_ID" 	VALUE="#DocId#">
	<CFIF isdefined("FORM.To_Date")>
	<INPUT TYPE="hidden" NAME="To_Date" 	VALUE="#FORM.To_Date2#">
	</CFIF>
	<INPUT TYPE="hidden" NAME="Form.Is_Welcome_Letter" VALUE="#FORM.Is_Welcome_Letter#">

</FORM>
</CFOUTPUT>

	<SCRIPT LANGUAGE="JavaScript">
	var isfromcreate = "<cfoutput>#backtocreate#</cfoutput>";
	var pageName = "<cfoutput>#pageName#</cfoutput>";
	function goBackToOtherPage()
	{
        if (isfromcreate == 1)
		{
			window.location.href = "create_Document_Details.cfm";
		}
		else
		{
			if (pageName == 1)
			{
				window.location.href = "/common_files/contracts/Sales_Agreement_attachments.cfm?FromProgram=0&<cfoutput>#URLSTRING#</cfoutput>";
			}
			else
			{
			  	window.location.href = "/common_files/contracts/contract_attachments.cfm?search=1&DocId=<cfoutput>#DocId#</cfoutput>&<cfoutput>#URLSTRING#</cfoutput>"
			}
		}
	}
	function gobacktocommonsearch()
	{
		var searchform = document.Back_to_common_Search;
		searchform.submit();
	}
	  <CFIF FORM.from_common_attachment EQ "0">
		window.setTimeout('goBackToOtherPage()', 2000);
	  <CFELSE>
		window.setTimeout('gobacktocommonsearch()', 2000);
	  </CFIF>

	</SCRIPT>

<CFELSE>
<!--- Update the record --->
	<cfset useLakebaseForSaveData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("document_details")>
	<cfif useLakebaseForSaveData>
		<cftry>
			<cfset application.oLakebase.updateRows("document_details",
				{ "doc_id" = "eq.#Form.Doc_ID#" },
				{
					"doc_title" = FORM.Doc_Title,
					"doc_description" = FORM.Doc_Description,
					"uploaded_date" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
					"uploaded_by" = FORM.Uploaded_By,
					"doc_type" = FORM.Doc_Type,
					"deleted" = (Form.Deleted EQ 1),
					"lastupdated_userid" = request.AccessStructure.User_ID,
					"public_view" = (IsDefined("FORM.Doc_Public") AND FORM.Doc_Public EQ 1)
				}
			)>
			<cfcatch type="any">
				<cfset useLakebaseForSaveData = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForSaveData>
		<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
			UPDATE 		Document_Details
			SET 		Doc_Title 			=	'#FORM.Doc_Title#',
						Doc_Description		=	'#FORM.Doc_Description#',
						Uploaded_Date		=	#now()#,
						Uploaded_By			=	'#FORM.Uploaded_By#',
						Doc_Type			=	'#FORM.Doc_Type#',
						Deleted				=	#Form.Deleted#,
						LastUpdated_UserId  =   '#request.AccessStructure.User_ID#',
						Public_View			=	<CFIF IsDefined("FORM.Doc_Public")>#FORM.Doc_Public#<CFELSE>0</CFIF>
						<!--- Not being used anymore --->
						<!---
						,Is_Welcome_Letter = #Form.Is_Welcome_Letter#
						--->
			WHERE		Doc_ID				=	'#Form.Doc_ID#'
		</CFQUERY>
	</cfif>

	<!---	Dev Note: Milan (29841). If the form related to uploaded documents is being updated here, redirect the user back to "incomplete_document_info.cfm",
		so that the user can fill in related information for any other document (if required).
	--->
	<cfif FORM.IncompleteDocumentInfo EQ 1>

		<CFLOCATION URL="incomplete_document_info.cfm?FlexAppName=#FORM.FlexAppName#&BBID=#FORM.BBID#&BillbackList=#FORM.BillbackList#" ADDTOKEN="No">

	<cfelseif Form.bFromSettings EQ 1>

		<SCRIPT LANGUAGE="JavaScript">
			opener.document.FormAttach.submit();
   			window.location.href = "create_document_details.cfm?EditFromAdmin=1&RID=<cfoutput>#Form.Doc_ID#</cfoutput>"
   		</SCRIPT>
	<cfelse>
		<CFLOCATION URL="create_Document_Details.cfm" ADDTOKEN="No">
	</cfif>
	<CFABORT>
</CFIF>
