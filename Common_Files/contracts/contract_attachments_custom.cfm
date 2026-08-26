<!----------------------------------------------------------------------------------------------------------------------------------
	Template: /AwayX/Common_Files/contracts/contract_attachments_custom.cfm
	  Author: Tim Ford
		Date: 2022 Februrary
	 Purpose: Custom Upload documents
----------------------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<CFSET PAGE_TITLE="Attachments">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
  <style>
  #upl17 { margin: 7px 0; }
  #upl18 { font-size: 14px; }

  fieldset { margin: 9px 0; }

	table.Maintable td {
		font-size: 8pt !important;
		padding-left:4px;
	}
	table.Maintable input[type="checkbox"], table.Maintable img {
		position: relative;
		top:4px;
		margin-left: 3px;
	}
	table.Maintable tr { line-height: 18px; }

	table.dos51 { margin-top: 0px; }
	table.dos51 tr {
		line-height: 18px;
	}
	table.dos51 td {
		font-weight: bold;
	}
	table.dos51 td a, table.dos51 td font {
		font-weight: normal;
	}

		.custom-file-input::-webkit-file-upload-button {
		visibility: hidden;
	}

	.custom-file-input { width: -webkit-fill-available;}
	
	.custom-file-input::before {
		content: 'choose file';
		display: inline-block;
		border: 1px solid #999;
		padding: 5px 8px;
		white-space: nowrap;
		-webkit-user-select: none;
		cursor: pointer;
		text-shadow: 1px 1px #fff;
		font-weight: 600;
		font-size: 10pt;
		color: blue;
		width: 100px;
		height: 15px;
		border-radius: 3px;
		text-align: center;
	}

	.custom-file-input:active::before {
  		background: -webkit-linear-gradient(top, #e3e3e3, #f9f9f9);
	}
  </style>

  <!--- Dropzone.js open source library is used for the file upload --->
  <cf_include files=#arrayToList( [ "/common_files/dropzone.cfm", "/styles/ba_upload.css" ] )#>

</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onLoad="">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFPARAM NAME="URL.CID" 	DEFAULT="">
<cfparam name="file_name" default="">
<CF_CRYP type="de" string="#URL.CID#" key="#request.key#">
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "at">
<CFSET FORM.Contract_Main_ID = cryp.value>
<cfif application.programlayout EQ 1>
  <div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px">
  <CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>
<cfelse>
  <CFINCLUDE TEMPLATE="contract_status_legend.cfm">
</cfif>

<BLOCKQUOTE>
<cfif application.programlayout EQ 1>
<div id="Layer1" style="position:relative; height:430px; width:796px; z-index:1; left: 150px; top: 10px;"></cfif>

 <cfinclude template="minimal_contract_info.cfm">

 <cfinclude template="Contract_Documents_Menu.cfm">


<CFINCLUDE TEMPLATE="/Common_Files/Documents/User_Positions_Under_this_User.cfm">
<CFSET Access_Position_List = GP_Position_List_From_My_Position_Down>

<CFPARAM NAME="FORM.formcheck" 	DEFAULT="0">
<CFPARAM NAME="FORM.Doc_ID" DEFAULT="">
<CFPARAM NAME="FORM.Doc_Desc" DEFAULT="">
<CFPARAM NAME="FORM.This_Page_List" 	DEFAULT="">
<CFPARAM NAME="FORM.Form_Name" 	DEFAULT="">

<CFQUERY NAME = "drop_temp" DATASOURCE = "#Application.Datasource#">
  	IF OBJECT_ID('tempdb..##TMP_CONTRACT_ATTACHMENTS') IS NOT NULL
    DROP TABLE ##TMP_CONTRACT_ATTACHMENTS
</cfquery>
<CFQUERY NAME = "Current_sel" DATASOURCE = "#Application.Datasource#">
    IF OBJECT_ID('tempdb..##TMP_CONTRACT_ATTACHMENTS') IS NOT NULL
    DROP TABLE ##TMP_CONTRACT_ATTACHMENTS

    SELECT	Document_Details.*, Contract_Attachments.Notes
    INTO	##TMP_CONTRACT_ATTACHMENTS
    FROM    Contract_Attachments
    INNER JOIN document_details
    ON		Contract_Attachments.Doc_ID = Document_Details.Doc_ID
    AND   (
            ( Public_View = 1
    		    AND User_Position_ID IN (#Preservesinglequotes(Access_Position_List)#)
    				)
           OR Public_View = 0
          )
    LEFT JOIN Profiles_Settings PS
    ON		PS.Profiles_ID = #Request.AccessStructure.Profiles_ID#   AND PS.View_Private_Documents = 1
    WHERE   Contract_Attachments.Program_ID = '#Trim(FORM.Contract_Main_ID)#' AND Contract_Attachments.Deleted = 0
    AND     (Document_Details.Uploaded_By = '#Request.AccessStructure.User_ID#' OR  Public_View =0)

    INSERT INTO ##TMP_CONTRACT_ATTACHMENTS
    SELECT	Document_Details.*, Contract_Attachments.Notes
    FROM    Contract_Attachments
    INNER JOIN Document_Details ON Contract_Attachments.Doc_ID = Document_Details.Doc_ID
    AND   ((Public_View = 1
           AND User_Position_ID IN (#Preservesinglequotes(Access_Position_List)#)
           )OR Public_View = 0
          )
    INNER JOIN Profiles_Settings PS
    ON		PS.Profiles_ID = #Request.AccessStructure.Profiles_ID#  AND PS.View_Private_Documents = 1
    WHERE   Contract_Attachments.Program_ID = '#Trim(FORM.Contract_Main_ID)#'
    AND		Contract_Attachments.Deleted = 0
    AND		NOT EXISTS (SELECT * FROM ##TMP_CONTRACT_ATTACHMENTS
    					WHERE ##TMP_CONTRACT_ATTACHMENTS.Doc_ID = Contract_Attachments.Doc_ID)

    SELECT * FROM ##TMP_CONTRACT_ATTACHMENTS


</CFQUERY>

<CFSET Current_Selection_List = ValueList(Current_sel.doc_iD)>
<CFIF isDefined("FORM.Current_Selection_List")>
	<CFSET Current_Selection_List = FORM.Current_Selection_List>
</CFIF>



<!---- Loop thru the existing items to delete the unchecked ones ---->
<CFLOOP LIST="#FORM.This_Page_List#" INDEX="Existing_Doc_ID">
	<CFIF NOT ListFindNoCase(FORM.Doc_ID, Existing_Doc_ID, ",")>
		<CFSET Current_Selection_List_Index = ListFindNoCase(Current_Selection_List, Existing_Doc_ID, ",")>
		<CFIF Current_Selection_List_Index GT 0>
			<CFSET Current_Selection_List = ListDeleteAt(Current_Selection_List, Current_Selection_List_Index, ",")>
		</CFIF>
	</CFIF>
</CFLOOP>

<!---- Loop thru the check box to add the newly added items ---->
<CFLOOP LIST="#FORM.Doc_ID#" INDEX="Check_Doc_ID">
	<CFIF NOT ListFindNoCase(Current_Selection_List, Check_Doc_ID, ",")>
		<CFSET Current_Selection_List = ListAppend(Current_Selection_List, Check_Doc_ID, ",")>
	</CFIF>
</CFLOOP>

<CFIF FORM.formcheck EQ "1">
	<!--- There used to be a few queries here before those queries were added to a separate cfm file,
	so that file upload from flex program search tool could use the same logic.
	--->
	<cfinclude template="contract_attachments_action.cfm">
	<cflocation url="Contract_Edit_Menu.cfm?CID=#URL.CID#">
</CFIF>


<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript">
	function ConfirmDelete()
	{
		document.FormAttach.formcheck.value = "1";
		document.FormAttach.submit()
	}
	function DeleteTool(DocID,action,currentRow)
	{
		var cellObj = eval("document.all.Delete_"+currentRow);
		var trObj = eval("document.all.TR_Delete_"+currentRow);
		var deleteIdArray = new Array()
		var ArrayValue = document.all.DeleteDocList.value;

		if (document.all.DeleteDocList.value != "")
		{
			deleteIdArray = ArrayValue.split(",");
		}

		if (action == 1)
		{
			if (document.all.DeleteDocList.value == "")
			{
				document.all.DeleteDocList.value = DocID;
			}
			else
			{
				document.all.DeleteDocList.value = document.all.DeleteDocList.value +","+DocID;
			}
			action = 0;
			cellObj.innerHTML = "<A HREF=\"Javascript: DeleteTool('"+DocID+"',"+action+","+currentRow+")\"><img src='/images/undo.gif' title='Restore document' border='0' style='padding:10px'></A>";
			trObj.style.background = "c0c0c0";
		}
		else if (action == 0)
		{
			deleteIdArray = ArrayDeleteItem(deleteIdArray, DocID, ",");
            
			if (deleteIdArray.length == 0)
			{
				document.all.DeleteDocList.value = "";
			}
			for (i=0;i<deleteIdArray.length;i++)
			{
				if (i == 0)
				{
					document.all.DeleteDocList.value = deleteIdArray[i];
				}
				else
				{
					document.all.DeleteDocList.value = document.all.DeleteDocList.value +","+deleteIdArray[i];
				}
			}
			action = 1;
			cellObj.innerHTML = "<A HREF=\"Javascript: DeleteTool('"+DocID+"',"+action+","+currentRow+")\"><img src='/Images/scissor.gif' width='14' height='9' title='Remove document' border='0' style='padding:10px'></A>";
			if ((currentRow%2) == 0)
			{
				trObj.style.background = "C6FFC6";
			}
			else
			{
				trObj.style.background = "";
			}
		}

		if	(document.all.DeleteDocList.value == "")
		{
			document.all.TR_Confirm.style.display = "none";
		}
		else
		{
			document.all.TR_Confirm.style.display = "";
		}
	}
	function selectChange(thisobj)
	{
		var bShow = "none";
		if(thisobj.value == "Between")
		{
			bShow = "";
		}

		document.all.SP_To_Date.style.display = bShow;
		if(bShow == "")
		{
			//document.all.To_Date.focus();
		}
		else if(thisobj.value != "")
		{
			document.all.From_Date.focus();
		}
		else
		{
			document.all.From_Date.value = "";
		}
	}
</SCRIPT>
<SCRIPT LANGUAGE="JavaScript">
	function validate()
	{
		x=document.FormAttach;
		/*var today = new Date;
		var dateString = (today.getMonth() + 1) + "/" + today.getDate() + "/" + today.getFullYear();*/
		if (x.From_Date.value != "")
		{
			if(x.Comp_Operator.value == "")
			{
				alert("Please select comparison <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>");
				x.Comp_Operator.focus();
				return false;
			}
		}
		if (x.Comp_Operator.value == "Between")
		{
			if (x.From_Date.value == "")
			{
				alert("Please enter two date value");
				x.From_Date.focus();
				return false;
			}
			if (x.To_Date.value == "")
			{
				alert("Please enter two date values if you select BETWEEN comparison <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>");
				x.To_Date.focus();
				return false;
			}
			if(checkDate(x.To_Date.value, x.today1.value)>=1)
			{
				alert("DATE cannot be more than todays date");
				x.To_Date.focus();
				return false;
			}
			if(checkDate(x.To_Date.value,x.From_Date.value)<0)
			{
				alert("Please make the FIRST DATE less than or equal to SECOND DATE");
				x.From_Date.focus();
				return false;
			}

		}
		if(checkDate(x.From_Date.value, x.today1.value)>=1)
		{
			alert("DATE cannot be more than todays date");
			x.From_Date.focus();
			return false;
		}
		x.submit();
		return false;
	}


	function sort_by_this_order(fieldName, sOrder)
	{
		var oForm = document.FormAttach;
		oForm.SORT_BY.value = fieldName;
		oForm.SORT_ORDER.value = sOrder;
		oForm.submit();
		return false;
	}

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


	function save_Documents()
	{
		var evalNotes =  trim($('#EvaluationNotes').val());
	
		if(evalNotes == 0){
			noty({
					layout: "center", type: "error", timeout: 5000, killer: true,
					text: "Please enter a comment",
					animation: { open: { height: 'toggle' }, close: { height: 'toggle' }, easing: 'swing', speed: 50 }
				});
  		}
		else{
			document.FormAttach.formcheck.value = "1";
			document.FormAttach.EvaluationNotes.value = evalNotes;
			document.FormAttach.submit();
		}	
		
	}

	function reset_Form_Fields()
	{
		resetSelect("Doc_type");
		resetSelect("Doc_Family");
		resetSelect("Uploaded_By");
		resetSelect("Comp_Operator");
		//resetSelect("To_Date");
		//document.all.curr_symbol.selectedIndex = 0;
		document.all.To_Date.value = "";
		document.all.Doc_Title.value = "";
		document.all.Doc_Description.value = "";
		document.all.Doc_File_Name.value = "";
		resetSelect("Public_View");
		resetSelect("deleted");
		resetSelect("AttachedTo");
	}

	function resetSelect(selName)
	{
		var sObj = document.getElementById(selName);
		if(sObj)
		{
			sObj.selectedIndex = 0;
			callfireEvent(document,sObj,'Change');
		}
	}
</SCRIPT>
<!---Comp_Operator    --->
<SCRIPT SRC="/Common_Files/scripts/Date_Difference.js"></SCRIPT>



<SCRIPT>

function checkDate(dateStr1,dateStr2)
{
	var dateSplit;
	var retVal = null;
	dateSplit = dateStr1.split("/");
	if(dateSplit)
	{
		if(dateSplit.length > 2)
		{
			var date1 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
			dateSplit = dateStr2.split("/");
			if(dateSplit)
			{
				if(dateSplit.length > 2)
				{
					var date2 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
					retVal = days_between(date1, date2, true);
				}
			}
		}
	}
return retVal;
}

<!--- need to hide search documents because newly added/attached documents are not included in the page,
      we will need to refresh the page to get latest --->
function hide17() { $('#sdoc17').hide(); location.reload(); }

</SCRIPT>

<cfinclude template="/Common_Files/Documents/Document_Include.cfm" />
<cfinclude template="/Common_Files/dhx_message.cfm" />

<CFPARAM NAME="URL.SORT_BY" 	DEFAULT="">
<CFPARAM NAME="URL.SORT_ORDER" 	DEFAULT="ASC">

<CFPARAM NAME="URL.Doc_Type" 		DEFAULT="">
<CFPARAM NAME="URL.Doc_Family" 		DEFAULT="">
<CFPARAM NAME="URL.uploaded_by" 	DEFAULT="">
<CFPARAM NAME="URL.Comp_Operator" 	DEFAULT="">
<CFPARAM NAME="URL.From_Date" 		DEFAULT="">
<CFPARAM NAME="URL.To_Date" 		DEFAULT="">
<CFPARAM NAME="URL.Doc_Title" 		DEFAULT="">
<CFPARAM NAME="url.docid"            default="">
<CFPARAM NAME="URL.Doc_Description" 		DEFAULT="">
<CFPARAM NAME="URL.Doc_File_Name" 		DEFAULT="">
<CFPARAM NAME="URL.Public_View" 		DEFAULT="">
<CFPARAM NAME="URL.deleted" 		DEFAULT="">
<CFPARAM NAME="URL.AttachedTo" 		DEFAULT=0>

<CFPARAM NAME="FORM.SORT_BY" 	DEFAULT="#URL.SORT_BY#">
<CFPARAM NAME="FORM.SORT_ORDER" 	DEFAULT="#URL.SORT_ORDER#">

<CFPARAM NAME="FORM.Doc_Type" 		DEFAULT="#URL.Doc_Type#">
<CFPARAM NAME="FORM.Doc_Family" 	DEFAULT="#URL.Doc_Family#">
<CFPARAM NAME="FORM.uploaded_by" 	DEFAULT="#URL.uploaded_by#">
<CFPARAM NAME="FORM.Comp_Operator" 	DEFAULT="#URL.Comp_Operator#">
<CFPARAM NAME="FORM.From_Date" 		DEFAULT="#URL.From_Date#">
<CFPARAM NAME="FORM.To_Date" 		DEFAULT="#URL.To_Date#">
<CFPARAM NAME="FORM.Doc_Title" 		DEFAULT="#URL.Doc_Title#">
<CFPARAM NAME="FORM.Doc_Description" 	DEFAULT="#URL.Doc_Description#">
<CFPARAM NAME="FORM.Doc_File_Name" 	DEFAULT="#URL.Doc_File_Name#">
<CFPARAM NAME="FORM.Public_View" 	DEFAULT="#URL.Public_View#">
<CFPARAM NAME="FORM.deleted" 		DEFAULT="#URL.deleted#">
<CFPARAM NAME="FORM.AttachedTo" 	DEFAULT="#URL.AttachedTo#">


<!---  Use flag to choose old Flash upload vs new dropzone upload --->
<cfif application.util.query.get_setting("upload_documents_method", false) EQ "flash">

	<!--- CFFILEUPLOAD HERE --->
	<div id="upl17">
		<cffileupload
				extensionfilter   = ""
                url               = "ajax/contract_attachments.cfm?Program_ID=#FORM.Contract_Main_ID#&user=#request.AccessStructure.user_id#"
				align             = "left"
				height            = "220"
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

<form id="uploadForm" name="uploadForm" action="/Common_Files/contracts/contract_attachments_custom_action.cfm" enctype="multipart/form-data" method="post">
	<br>
	<div>
		<b>Comments:</b><br>
		<textarea id="EvaluationNotes" name="notes" STYLE="width: 600px; height: 100px"></textarea>
	</div> 
	<div>
		<br>
		<input type="file" id="evalFile" name="evalFile" class="custom-file-input" />
	</div>
	<div>
		<br>
		<a href="##" id="sdoc18"><cfoutput>#application.util.string.actionLinkFormat2( "upload document" )#</cfoutput></a>
	</div>
	 
	 <INPUT TYPE="hidden" NAME="Program_id" VALUE="<cfoutput>#FORM.Contract_Main_ID#</cfoutput>">
  </form>
</cfif>


<cfif cgi.request_method eq "post" or Current_sel.RecordCount>
	<cfset variables.formStyle = "display:inline">
<cfelse>
	<!--- Only if the user is allowed to search documents, should the document search be available. --->
	<cfif Get_Profile_Settings.Search_Documents eq 1>
	<a href="##" id="sdoc17"><cfoutput>#application.util.string.actionLinkFormat2( "search documents" )#</cfoutput></a>
	</cfif>
	<cfset variables.formStyle = "display:none">
</cfif>

<cfoutput>
<FORM ACTION="contract_attachments_custom.cfm?CID=#EncryptedCID#" METHOD="post" NAME="FormAttach" STYLE="#variables.formStyle#">

</cfoutput>
	<cfparam name="FORM.startrow"  default="1">
   <CFPARAM NAME="FORM.frompage"   DEFAULT="1">
   <cfparam name="FORM.pageLength"  default=10>
   <CFSET startrow=FORM.startrow>
   <CFSET frompage=FORM.frompage>
   <cf_Number_of_Rows maxrows="#FORM.pageLength#">
   <CFOUTPUT>
   	<INPUT TYPE="hidden" NAME="formcheck" VALUE="0">
	<INPUT TYPE="hidden" VALUE = "#Current_Selection_List#" NAME="Current_Selection_List">
   	<INPUT TYPE="hidden" VALUE = "#FORM.frompage#" NAME="frompage">
	<INPUT TYPE="hidden" VALUE = "#FORM.StartRow#" NAME="startrow">
	<INPUT TYPE="hidden" VALUE = "#FORM.SORT_BY#" NAME="SORT_BY">
	<INPUT TYPE="hidden" VALUE = "#FORM.SORT_ORDER#" NAME="SORT_ORDER">
	<INPUT TYPE="hidden" VALUE = "#FORM.Doc_Desc#" NAME="Doc_Desc">
	<INPUT TYPE="hidden" NAME="EvaluationNotes" id="EvaluationNotes">
	
	</CFOUTPUT>
	  <CFSET settoday = #DateFormat(Now(),"mm/dd/yyyy")#>
	<CFOUTPUT>
	<INPUT TYPE="hidden" NAME="today1" VALUE="#settoday#">
	</CFOUTPUT>
	<INPUT TYPE="hidden" NAME="Search" VALUE="1">

	<!--- Only if the user is allowed to search documents, should the document search be available. --->
	<cfif Get_Profile_Settings.Search_Documents eq 1>
	<FIELDSET STYLE="padding:8px; width: 780px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">document search</LEGEND>
	<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0" width="100%" class="dos51">
	
		<TR>
			<TD colspan="2">Title<br>
				<INPUT TYPE="Text" NAME="Doc_Title" VALUE=<CFOUTPUT>"#FORM.Doc_Title#"</CFOUTPUT> STYLE="WIDTH:375px;">
			</TD>
			<TD colspan="2">Description<br>
				<INPUT TYPE="Text" NAME="Doc_Description" VALUE=<CFOUTPUT>"#FORM.Doc_Description#"</CFOUTPUT> STYLE="WIDTH:375px;">
			</TD>
		</TR>
		<TR>
			<TD colspan=2>File Name<br>
				<INPUT TYPE="Text" NAME="Doc_File_Name" VALUE=<CFOUTPUT>"#FORM.Doc_File_Name#"</CFOUTPUT> STYLE="WIDTH:375px;">
			</TD>
			<CFQUERY NAME="Select_Family" DATASOURCE="#Application.Datasource#">
				SELECT DISTINCT(Doc_Family) FROM document_details WHERE Deleted = 0 order by Doc_Family
			</CFQUERY>
			<TD>Family<br>
				<SELECT NAME="Doc_Family" ID="Doc_Family" STYLE="WIDTH:185px;">
					<OPTION VALUE="" SELECTED></OPTION>
					<CFOUTPUT QUERY="Select_Family">
						<OPTION VALUE="#Doc_Family#"<CFIF FORM.Doc_Family EQ Doc_Family> SELECTED</CFIF>>#Doc_Family#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
			<CFQUERY NAME="Select_type" DATASOURCE="#Application.Datasource#">
				SELECT DISTINCT(Doc_Type) FROM document_details WHERE Deleted = 0 order by Doc_Type
			</CFQUERY>
			<TD align=left>Type<br>
				<SELECT NAME="Doc_type" ID="Doc_type" STYLE="WIDTH:185px;">
					<OPTION VALUE="" SELECTED></OPTION>
					<CFOUTPUT QUERY="Select_type">
						<OPTION VALUE="#Doc_Type#"<CFIF FORM.Doc_Type EQ Doc_Type> SELECTED</CFIF>>#Doc_Type#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
		</TR>
		<TR>
			<TD colspan = 4>
				<table width="100%">
				<tr>
					<TD>Attached To<br>
						<SELECT NAME="AttachedTo" ID="AttachedTo" STYLE="WIDTH:90px;">
							<OPTION VALUE="0"  <CFIF FORM.AttachedTo EQ 0> SELECTED</CFIF>>All</OPTION>
							<OPTION VALUE="Billback"  <CFIF FORM.AttachedTo EQ "Billback"> SELECTED</CFIF> >Billback</OPTION>
							<OPTION VALUE="Deduction"  <CFIF FORM.AttachedTo EQ "Deduction"> SELECTED</CFIF>>Deduction</OPTION>
							<OPTION VALUE="Program"  <CFIF FORM.AttachedTo EQ "Program"> SELECTED</CFIF>>Program</OPTION>
						</SELECT>
					</TD>
					<TD>Privacy<br>
						<SELECT NAME="Public_View" ID="Public_View" STYLE="WIDTH:90px;">
							<OPTION VALUE=""></OPTION>
							<OPTION VALUE="0"  <CFIF FORM.Public_View EQ 0> SELECTED</CFIF>>Not Private</OPTION>
							<OPTION VALUE="1"  <CFIF FORM.Public_View EQ 1> SELECTED</CFIF>>Private</OPTION>
						</SELECT>
					</TD>
					<TD>Availability<br>
						<SELECT NAME="deleted" ID="deleted" STYLE="WIDTH:74px;">
							<OPTION VALUE="0" <CFIF FORM.deleted EQ 0> SELECTED</CFIF>>Active</OPTION>
							<OPTION VALUE="1"  <CFIF FORM.deleted EQ 1> SELECTED</CFIF>>Inactive</OPTION>
						</SELECT>
					</TD>
					<CFQUERY NAME="Select_name" DATASOURCE="#Application.Datasource#">
						<!--- SELECT DISTINCT(Uploaded_By) FROM document_details WHERE Deleted = 0 --->
						SELECT DISTINCT Uploaded_By,Name_First,Name_Last FROM document_details
						LEFT JOIN _users ON document_details.Uploaded_By = _users.User_ID
						WHERE document_details.Deleted = 0
						ORDER BY _users.Name_Last
					</CFQUERY>
					<TD>Uploaded By<br>
						<SELECT NAME="Uploaded_By" ID="Uploaded_By" STYLE="WIDTH:140px;">
							<OPTION VALUE="" SELECTED></OPTION>
							<CFOUTPUT QUERY="Select_Name">
								<OPTION VALUE="#uploaded_by#"<!--- <CFIF isdefined("URL.Uploaded_By")><CFIF URL.Uploaded_By EQ Uploaded_By> SELECTED</CFIF></CFIF> ---><CFIF FORM.uploaded_by EQ uploaded_by> SELECTED</CFIF>>#Name_First# #Name_Last#<!--- #Uploaded_by# ---></OPTION>
							</CFOUTPUT>
						</SELECT>
					</TD>
					<TD>Uploaded Date<br>
						<SELECT NAME="Comp_Operator" ID="Comp_Operator" STYLE = "WIDTH: 95px;" ONCHANGE="javaScript: selectChange(this);">
							<OPTION VALUE = ""<CFIF FORM.Comp_Operator EQ ""> SELECTED</CFIF>>
							<OPTION VALUE = ">"<!--- <CFIF isdefined("URL.Comp_Operator")><CFIF URL.Comp_Operator EQ ">"> SELECTED</CFIF></CFIF> ---><CFIF FORM.Comp_Operator EQ ">"> SELECTED</CFIF>> greater than
							<OPTION VALUE = "<"<!--- <CFIF isdefined("URL.Comp_Operator")><CFIF URL.Comp_Operator EQ "<"> SELECTED</CFIF></CFIF> ---><CFIF FORM.Comp_Operator EQ "<"> SELECTED</CFIF>> less than
							<OPTION VALUE = "="<!--- <CFIF isdefined("URL.Comp_Operator")><CFIF URL.Comp_Operator EQ "="> SELECTED</CFIF></CFIF> ---><CFIF FORM.Comp_Operator EQ "="> SELECTED</CFIF>> equal to
							<OPTION VALUE = "Between"<!--- <CFIF isdefined("URL.Comp_Operator")><CFIF URL.Comp_Operator EQ "Between"> SELECTED</CFIF></CFIF> ---><CFIF FORM.Comp_Operator EQ "Between"> SELECTED</CFIF>>Between
						</SELECT>
					</TD>
					<TD><br>
						<CFOUTPUT>
							<CFSET default=FORM.From_date>
							<CF_EASYDATE FORMNAME="FormAttach" FIELDNAME="From_Date" FORMAT="mm/dd/yyyy" DEFAULT="#default#" FieldNameSize="6">
						</CFOUTPUT>
					</TD>
					<TD><br>
						<SPAN ID="SP_To_Date"<CFIF FORM.Comp_Operator NEQ "Between"> STYLE="display:none;"</CFIF>>
						<CFOUTPUT>
							<CFSET To_default=FORM.To_date>
							<CF_EASYDATE FORMNAME="FormAttach" FIELDNAME="To_Date" FORMAT="mm/dd/yyyy" DEFAULT="#To_default#" FieldNameSize="6">
						</CFOUTPUT>
						</SPAN>
					</TD>
				</tr>
				</table>
			</TD>
		</TR>
		<TR>
			<TD NOWRAP VALIGN="bottom" colspan=4 align="right">
			<!--- Only if the profile allows, should a user be allowed to search for documents --->
			<cfif Get_Profile_Settings.Search_Documents eq 1>
			<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
				<A HREF="#" OnClick="javascript: return validate();"><B>search documents</B></A>
				<!--- <A HREF="javascript: document.FormAttach.submit()"><B>search documents</B></A> --->
			<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
			</cfif>
 			<FONT COLOR="ff0000" SIZE="2">&nbsp;&nbsp;<B>[</B></FONT>
				<A HREF="javascript: reset_Form_Fields();"><B>reset</B></A>
			<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
			<!---  Dev Note: Milan (29841). Remove "upload" functionality from here for billbacks. --->
			<!--- <cfif Form.Form_name neq "Billback_Attachments">
			<CFOUTPUT>
			<FONT COLOR="ff0000" SIZE="2">&nbsp;&nbsp;<B>[</B></FONT>
				<A HREF="/Common_Files/Documents/create_document_details.cfm?FromProgram=1&CID=#URL.CID#<CFIF FORM.Uploaded_By NEQ "">&Uploaded_By=#FORM.Uploaded_By#</CFIF><CFIF FORM.Doc_Type NEQ "">&Doc_Type=#FORM.Doc_Type#</CFIF><CFIF FORM.Doc_Family NEQ "">&Doc_Family=#FORM.Doc_Family#</CFIF><CFIF FORM.Comp_Operator NEQ "">&Comp_Operator=#FORM.Comp_Operator#&From_Date=#FORM.From_Date#</CFIF><CFIF FORM.Comp_Operator EQ "Between">&To_Date=#FORM.To_Date#</CFIF><CFIF FORM.Doc_Title NEQ "">&Doc_Title=#FORM.Doc_Title#</CFIF><CFIF FORM.Doc_Description NEQ "">&Doc_Description=#FORM.Doc_Description#</CFIF><CFIF FORM.Doc_File_Name NEQ "">&Doc_File_Name=#FORM.Doc_File_Name#</CFIF><CFIF FORM.Public_View NEQ "">&Public_View=#FORM.Public_View#</CFIF><CFIF FORM.deleted NEQ "">&deleted=#FORM.deleted#</CFIF><CFIF FORM.AttachedTo NEQ "">&AttachedTo=#FORM.AttachedTo#</CFIF>"><B>upload documents</B></A>
			<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
			</CFOUTPUT>
			</cfif> --->
			</TD>
		</TR>
	</TABLE>
	</FIELDSET>
	</cfif>

	<!------</FORM>----->
	<FIELDSET STYLE="padding:8px; width: 780px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">currently attached document(s)</LEGEND>

	<CFIF Current_sel.recordcount GT 0>
				<!--- <TABLE border="0" cellspacing="3" cellpadding="3" align="left" WIDTH="100%" BGCOLOR="white">
					<TR><CFoutput QUERY="Current_sel">
							<TD BGCOLOR="eeeeee" WIDTH="33%"><A href="javascript: confirmation('#Doc_Uni_Name#');" TITLE="Click here to view #Doc_Title#">#Doc_Title#</A></TD><!--- #doc_title# --->
		 				<CFIF Current_sel.currentrow mod 3><CFELSE></TR><TR></CFIF>
					</CFoutput>
					</TR>
					 <tr>	<td></td></tr>
				</TABLE> --->
				<INPUT TYPE="Hidden" NAME="DeleteDocList" VALUE="">
				<TABLE ID="Table_Delete" CLASS="Maintable" WIDTH="100%" CELLPADDING="6" CELLSPACING="0">
					<!--- TABLE HEADERS --->
					<TR BGCOLOR="#FFCE84" VALIGN="bottom">

						<TD ID="header"><FONT SIZE="1"><B>DATE<br>NAME</B></FONT></TD>
						<TD ID="header" ><FONT SIZE="1"><B>FILE</B></FONT></TD>
						<TD ID="header" ><FONT SIZE="1"><B>TITLE<br>DESCRIPTION</B></FONT></TD>
						<TD ID="header" ><FONT SIZE="1"><B>COMMENTS</B></FONT></TD>
						<TD ID="header"><FONT SIZE="1"><B>TYPE<br>PRIVACY</B></FONT></TD>
						<TD ID="header"><FONT SIZE="1"><B>DELETE</B></FONT></TD>
					</TR>
					<CFOUTPUT QUERY="Current_sel">
						<!--- DATA OUTPUT --->
						<TR ID="TR_Delete_#CurrentRow#" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
						<CFQUERY NAME="User_Name" DATASOURCE="#Application.Datasource#">
								SELECT Name_First, Name_Last FROM _USERS WHERE User_ID = '#Uploaded_By#'
						</CFQUERY>
							<CFSET SIZEinMB = #Doc_size#/1024>
							<TD ID="TD1_#CurrentRow#" WIDTH="16%">#DateFormat(Uploaded_Date,"mm/dd/yyyy")#<BR>#User_Name.Name_First# #User_Name.Name_Last#&nbsp;</TD>
							 	<cfset DecodedDoc_Uni_Name = Replace(Doc_Uni_Name,"á","charE1a","ALL") />
							 	<cfset DecodedDoc_Uni_Name = Replace(DecodedDoc_Uni_Name,"é","charE9e","ALL") />
								<cfset DecodedDoc_Uni_Name = Replace(DecodedDoc_Uni_Name,"í","charEDi","ALL") />
								<cfset DecodedDoc_Uni_Name = Replace(DecodedDoc_Uni_Name,"ó","charF3o","ALL") />
								<cfset DecodedDoc_Uni_Name = Replace(DecodedDoc_Uni_Name,"ú","charFAu","ALL") />  
							
							<TD ID="TD2_#CurrentRow#" NOWRAP TITLE="File Name: #Doc_File_Name#" ID=""><A href="javascript: confirmation2('#DecodedDoc_Uni_Name#');" TITLE="Click here to view '#Doc_File_Name#'">
								<CFSET Display_Name=Left(Doc_File_Name,20)>
								<CFIF len(trim(Doc_File_Name)) GT 20>
									#LCASE(Display_Name)#...
								<CFELSEIF len(trim(Doc_File_Name)) EQ 0>
									&nbsp;
								<CFELSE>
									#LCASE(Display_Name)#
								</CFIF>
								</A><BR>#NumberFormat(SIZEinMB,"_.___")# KB&nbsp;</TD>
							<TD ID="TD3_#CurrentROw#" WIDTH="48%"><FONT color="red"><b>#Doc_Title#</b></FONT><br>Description: #Doc_Description#&nbsp;</TD>
							<TD ID="TD4_#CurrentROw#" WIDTH="58%">#Notes#</TD>
							<TD ID="TD5_#CurrentRow#" WIDTH="12%">#Doc_Type#<br><cfif #Public_View# EQ 1> Yes <cfelse> No</cfif>&nbsp;</TD>

						<TD ID="Delete_#currentRow#"><A HREF="Javascript: DeleteTool('#Doc_ID#',1,'#CurrentRow#')"><img src="/Images/scissor.gif" width="14" height="9" title="Remove entry" border="0" style="padding:10px"></A></TD>
						</TR>
						<input type="hidden" name="#replace(Doc_ID, "-", "_", "ALL")#" value="#Notes#" />
					</CFOUTPUT>
					<CFSET Display_Button = 0>
					<TR ID="TR_Confirm" <CFIF Display_Button EQ 0>STYLE="DISPLAY:NONE"</CFIF>>
						<TD COLSPAN="100%" ALIGN="Right" STYLE="border-bottom:none;"><B><FONT COLOR="Red" SIZE="2">[ </FONT><A HREF="Javascript: ConfirmDelete()">confirm delete</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B></TD>
					</TR>
				</TABLE>
	<CFELSE>
		None
	</CFIF>
	<BR>
	</FIELDSET>

	<CFIF isdefined("FORM.search") OR isdefined("URL.search")>

	<CFSWITCH EXPRESSION="#FORM.SORT_BY#">
		<CFCASE VALUE="Uploaded_Date,Doc_Title,Doc_File_Name,Doc_Description,Uploaded_By,Doc_Type,Doc_Family,Public_View" DELIMITERS=",">
			<CFSET FORM.SORT_BY = FORM.SORT_BY>
		</CFCASE>
		<CFDEFAULTCASE>
			<CFSET FORM.SORT_BY = "Doc_Title">
		</CFDEFAULTCASE>
	</CFSWITCH>

	<CFIF FORM.SORT_ORDER NEQ "DESC">
		<CFSET FORM.SORT_ORDER = "ASC">
	</CFIF>


	<CFOUTPUT>
<!---
	Dev Notes: D23320/Anand Rao/17-May-10
	  User profile setting to view private documents
--->
  <CFQUERY NAME="ret_data" DATASOURCE="#Application.Datasource#">
  IF OBJECT_ID('tempdb..##TMP_DOCUMENT_SEARCH') IS NOT NULL
  DROP TABLE ##TMP_DOCUMENT_SEARCH
  SELECT	Document_Details.*
  INTO	##TMP_DOCUMENT_SEARCH
  FROM    Document_Details
<CFIF FORM.AttachedTo NEQ 0 AND  FORM.AttachedTo NEQ "">
    INNER JOIN Contract_Attachments
    ON		Document_Details.Doc_ID  = Contract_Attachments.Doc_ID
    AND   (<cfif FORM.AttachedTo EQ "Billback">
		Contract_Attachments.billback_ID is not NULL
	<cfelseif FORM.AttachedTo EQ "Program">
		Contract_Attachments.Program_ID is not NULL
	<cfelseif FORM.AttachedTo EQ "Deduction">
		Contract_Attachments.deduction_ID  is not NULL
	<cfelse>
		Contract_Attachments.deleted = 0
	</cfif>)
</CFIF>

  LEFT JOIN Profiles_Settings PS
  ON		PS.Profiles_ID = #Request.AccessStructure.Profiles_ID#   AND PS.View_Private_Documents = 1
  WHERE
<CFIF FORM.deleted EQ 1>
	Document_Details.Deleted = 1
	and Document_Details.Deleted_Permanent = 0
<CFELSEIF FORM.deleted EQ 2>
	1=2
<CFELSE>
    Document_Details.Deleted = 0
</CFIF>

<cfif Form.Public_View EQ 1>
	AND   ( Public_View = 1   AND User_Position_ID IN (#Preservesinglequotes(Access_Position_List)#) )
<cfelseif Form.Public_View EQ 0>
	AND	Public_View = 0
<cfelse>
    AND (
          ( Public_View = 1
  		    AND User_Position_ID IN (#Preservesinglequotes(Access_Position_List)#)
  				)
         OR Public_View = 0
        )
        AND
      (Document_Details.Uploaded_By = '#Request.AccessStructure.User_ID#' OR  Public_View =0)
</cfif>
  			<CFIF FORM.Uploaded_By NEQ "">
  				AND Uploaded_By = '#FORM.Uploaded_By#'
  			</CFIF>
  			<CFIF FORM.Doc_Type NEQ "">
  				AND Doc_Type = '#FORM.Doc_Type#'
  			</CFIF>
  			<CFIF FORM.Doc_Family NEQ "">
  				AND Doc_Family = '#FORM.Doc_Family#'
  			</CFIF>
  			<CFIF FORM.Comp_Operator NEQ "">
  				<!------ AND CONVERT(Char(10),Uploaded_Date,101) #FORM.Comp_Operator# '#FORM.From_Date#'<CFIF FORM.Comp_Operator EQ "Between"> and  '#FORM.To_Date#' </CFIF> ----->
  				<CFIF FORM.Comp_Operator EQ "Between">
  				AND DATEDIFF(d, #CreateODBCDate(FORM.From_Date)#, Uploaded_Date) >= 0
  				AND DATEDIFF(d, #CreateODBCDate(FORM.To_Date)#, Uploaded_Date) <= 0
  				<CFELSE>
  				AND DATEDIFF(d, #CreateODBCDate(FORM.From_Date)#, Uploaded_Date) #FORM.Comp_Operator# 0
  				</CFIF>
  			</CFIF>
  			<CFIF FORM.Doc_Title NEQ "">
  				AND DOC_Title LIKE '%#FORM.Doc_Title#%'
  			</CFIF>
  			<CFIF URL.docid NEQ "">
  				AND DOC_ID = '#URL.docid#'
  			</CFIF>
  			<CFIF FORM.Doc_Desc NEQ "">
  				AND Doc_Description LIKE '#FORM.Doc_Desc#%'
  			</CFIF>
			<CFIF FORM.Doc_Description NEQ "">
				AND Doc_Description LIKE '%#FORM.Doc_Description#%'
			</CFIF>
			<CFIF FORM.Doc_File_Name NEQ "">
				AND Doc_File_Name LIKE '%#FORM.Doc_File_Name#%'
			</CFIF>
  			AND IS_WELCOME_LETTER = 0

<cfif  Form.Public_View  NEQ 1  AND Form.Public_View  NEQ 0>

    INSERT INTO ##TMP_DOCUMENT_SEARCH
    SELECT	Document_Details.*
    FROM    Document_Details
    <CFIF FORM.AttachedTo NEQ 0 AND  FORM.AttachedTo NEQ "">
    INNER JOIN Contract_Attachments
    ON		Document_Details.Doc_ID  = Contract_Attachments.Doc_ID
    AND   (<cfif FORM.AttachedTo EQ "Billback">
		Contract_Attachments.billback_ID is not NULL
	<cfelseif FORM.AttachedTo EQ "Program">
		Contract_Attachments.Program_ID is not NULL
	<cfelseif FORM.AttachedTo EQ "Deduction">
		Contract_Attachments.deduction_ID  is not NULL
	<cfelse>
		Contract_Attachments.deleted = 0
	</cfif>)
    </CFIF>

    INNER JOIN Profiles_Settings PS
    ON		PS.Profiles_ID = #request.accessStructure.Profiles_ID#  AND PS.View_Private_Documents = 1
    WHERE
    <CFIF FORM.deleted EQ 1>
	Document_Details.Deleted = 1
	and Document_Details.Deleted_Permanent = 0
    <CFELSEIF FORM.deleted EQ 2>
	1=2
    <CFELSE>
    Document_Details.Deleted = 0
    </CFIF>

    <cfif Form.Public_View EQ 1>
	 AND User_Position_ID IN (#Preservesinglequotes(Access_Position_List)#)
    <cfelseif Form.Public_View EQ 0>
	AND	Public_View = 0
    <cfelse>
    AND
    ((Public_View = 1
         AND User_Position_ID IN (#Preservesinglequotes(Access_Position_List)#)
         )OR Public_View = 0
        )
    </cfif>
  			<CFIF FORM.Uploaded_By NEQ "">
  				AND Uploaded_By = '#FORM.Uploaded_By#'
  			</CFIF>
  			<CFIF FORM.Doc_Type NEQ "">
  				AND Doc_Type = '#FORM.Doc_Type#'
  			</CFIF>
  			<CFIF FORM.Doc_Family NEQ "">
  				AND Doc_Family = '#FORM.Doc_Family#'
  			</CFIF>
  			<CFIF FORM.Comp_Operator NEQ "">
  				<!------ AND CONVERT(Char(10),Uploaded_Date,101) #FORM.Comp_Operator# '#FORM.From_Date#'<CFIF FORM.Comp_Operator EQ "Between"> and  '#FORM.To_Date#' </CFIF> ----->
  				<CFIF FORM.Comp_Operator EQ "Between">
  				AND DATEDIFF(d, #CreateODBCDate(FORM.From_Date)#, Uploaded_Date) >= 0
  				AND DATEDIFF(d, #CreateODBCDate(FORM.To_Date)#, Uploaded_Date) <= 0
  				<CFELSE>
  				AND DATEDIFF(d, #CreateODBCDate(FORM.From_Date)#, Uploaded_Date) #FORM.Comp_Operator# 0
  				</CFIF>
  			</CFIF>
  			<CFIF FORM.Doc_Title NEQ "">
  				AND DOC_Title LIKE '%#FORM.Doc_Title#%'
  			</CFIF>
  			<CFIF URL.docid NEQ "">
  				AND DOC_ID = '#URL.docid#'
  			</CFIF>
  			<CFIF FORM.Doc_Desc NEQ "">
  				AND Doc_Description LIKE '#FORM.Doc_Desc#%'
  			</CFIF>
			<CFIF FORM.Doc_Description NEQ "">
				AND Doc_Description LIKE '%#FORM.Doc_Description#%'
			</CFIF>
			<CFIF FORM.Doc_File_Name NEQ "">
				AND Doc_File_Name LIKE '%#FORM.Doc_File_Name#%'
			</CFIF>
  			AND IS_WELCOME_LETTER = 0
</cfif>

    SELECT DISTINCT * FROM ##TMP_DOCUMENT_SEARCH ORDER BY #FORM.SORT_BY# #FORM.SORT_ORDER#

  	</CFQUERY>

	</CFOUTPUT>



	<FIELDSET STYLE="padding:8px; width: 780px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There<CFIF ret_data.recordcount EQ 0> Are No Documents <CFELSEIF ret_data.recordcount EQ 1> Is A Document<CFELSE> Are <CFOUTPUT>#ret_data.recordcount#</CFOUTPUT> Documents</CFIF>  That Match This Criteria</LEGEND>
	
	<CFINCLUDE TEMPLATE="contract_attach_search.cfm">
	<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
		<A HREF="javascript: save_Documents();"><B>attach selected documents</B></A>
	<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>

	<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <CF_Next_Previous_For_Forms
    formname="FormAttach"
    query="ret_data"
    maxpages="40"
    previous  = "<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
    next   = "<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
    previousseries = "<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
    nextseries  = "<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
    addparams="">
   </DIV>
	<!--- Dev Note: Milan 9250 --->
	 <script language="javascript">
		function showstartingWith(sValue)
		{
			document.FormAttach.Doc_Desc.value =sValue;
			return validate();
		}
		</script>
		<TABLE CELLPADDING="2" CELLSPACING="1" BORDER="0" ALIGN="CENTER"><TR>
		<cfoutput>
			<cfloop index="LoopCount" from="65" to="90">
					<TD  class="notranslate">
						<B>
						<CFIF chr(LoopCount) EQ form.Doc_Desc>
							<FONT COLOR="FF0000">[</FONT>
						</CFIF>
						<A HREF="##" onClick="javaScript: return showstartingWith('#chr(LoopCount)#');">#chr(LoopCount)#</A>
					 <CFIF chr(LoopCount) EQ form.Doc_Desc>
						<FONT COLOR="FF0000">]</FONT></CFIF>
						</B>
					</TD>
			</cfloop>
			<cfloop index="LoopCount" from="0" to="9">
					<TD>
						<B>
						<CFIF LoopCount EQ form.Doc_Desc>
							<FONT COLOR="FF0000">[</FONT>
						</CFIF>
						<A HREF="##" onClick="javaScript: return showstartingWith('#LoopCount#');">#LoopCount#</A>
						<CFIF LoopCount EQ form.Doc_Desc>
							<FONT COLOR="FF0000">]</FONT></CFIF>
						</B>
					</TD>
			</cfloop>
					<TD>
						<B>
						<CFIF "" EQ form.Doc_Desc>
						 <FONT COLOR="FF0000">[</FONT>
						</CFIF>
						<A HREF="##" onClick="javaScript: return showstartingWith('');">ALL</A>
					 <CFIF "" EQ form.Doc_Desc>
						<FONT COLOR="FF0000">]</FONT></CFIF>
						</B>
					</TD>
	</cfoutput>
	 </TR>
	</TABLE>
	<!--- End Note: Milan 9250 --->
	</FIELDSET>
	</CFIF>
	</FORM>
</BLOCKQUOTE>
<cfif application.programlayout EQ 1></div></cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/script/javascript/jquery.noty.packaged.min.js"></script>

<script>
  $('#sdoc18').click(function() {
  
	  	var evalNotes =  trim($('#EvaluationNotes').val());
		var evalFile =  $('#evalFile').val();
	
		if(evalNotes == 0 || evalFile == ''){
			noty({
					layout: "center", type: "error", timeout: 5000, killer: true,
					text: "Please enter a comment and select a file",
					animation: { open: { height: 'toggle' }, close: { height: 'toggle' }, easing: 'swing', speed: 50 }
				});
  		}
		else{
			$('#uploadForm').submit();
		}		
  });

  function confirmation2( file ){
	if (confirm("Large files may take several minutes to open...")) {
        const file_url = '<cfoutput>#siteURL#</cfoutput>/GetDocument.cfm?FilePath=data_files/uploaded/documents/uploaded_doc/' + escape(file);
        if ($("iframe[name=export]").length == 0) {
        	$("body").append('<iframe name="export" style="opacity:0"></iframe>');
    	}
    	$("iframe[name=export]").attr("src", file_url);
	}
  }
</script>
</BODY>
</HTML>



