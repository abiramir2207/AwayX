<!DOCTYPE HTML>
<html>
<title>Qualifications</title>
<head>
<style type="text/css">
  #fs727 { margin:0; padding:0 0px 0 0; border:0 none; border-top:1px solid; width:100%; clear:both; }
  #fs727 legend { margin:3px 0 0 0; padding:0 5px; font-weight:bold; font-size:16px; }
  #hdr727 { font:bold 20px "Times New Roman"; color:red; margin:0; float:left;}
  #tp727 { font:normal 12px; float:right; position:relative; top:10px; }
</style>
</head>
<body>
<cfinclude template="/common_files/programTranslate.cfm">    <!--- french translation --->
<cfset jQuery.version ="1.12.4">
<cfinclude template="/Common_Files/jQuery.cfm">
<!---
	Copyright (c)2013 Blacksmith Applications, Inc.
	Filename:		C:\Work\base\AwayX\Common_Files\contracts\qualifications.cfm
	Created:		4/24/2013
	Developer:		drachala
	Usage:			This file provide an option for user to store information regarding program qualifications
--->

<CFSET URL.PageTitle="Qualifications">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!---<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfparam name="form.blnsubmit" default="0" >
<cfparam name="url.Program_ID" default="0" >
<cfparam name="Form.DeleteDocList" default="" >
<cfparam name="url.DisAllowAccessBasedOnLockStatus" default="0">

<cfset url.Program_Qualification_ID = url.Program_ID>

<cfinclude template="/Common_Files/Documents/Document_Include.cfm" />

<!---get program info--->
<cfset program = CreateObject("component", "components.programs.Program") />
<cfset qGetProgramInfo = program.getProgramInfo(url.Program_ID) />

<cfquery name="variables.qQualifications" datasource="#application.datasource#">
		SELECT	a.*
		        ,b.Answer_Required
		  FROM	program_qualifications a
		        INNER JOIN Qualification_Template_Mapping b ON a.Program_Qualification_Id = b.Program_Qualification_Id
																   AND b.Template_Id = <cfoutput>#qGetProgramInfo.ProgramControl_Panel_Options_Id#</cfoutput>
																   AND b.Is_Included = 1
																   AND b.Deleted = 0
		 WHERE	a.deleted = 0 AND a.isactive = 1
		 		/* display_sequence was added in 2018 jun 28 - default is null */
				ORDER BY b.Display_Sequence, a.Type DESC
</cfquery>
<!--- If the user deletes the attached documents, delete the documents. --->
<cfif form.DeleteDocList neq "">
	<cfset useLakebaseForUpdateDel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
	<cfif useLakebaseForUpdateDel>
		<cftry>
			<cfset application.oLakebase.updateRows("contract_attachments",
				{ "program_id" = "eq.#url.Program_Qualification_ID#", "doc_id" = "in.(#form.DeleteDocList#)" },
				{ "deleted" = true }
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForUpdateDel = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUpdateDel>
	<CFQUERY NAME="update_del" DATASOURCE="#Application.Datasource#">
		UPDATE Contract_Attachments
			SET deleted = 1
		WHERE Program_ID = '#url.Program_Qualification_ID#'
		AND Doc_ID in (#ListQualify(form.DeleteDocList,"'")#)
	</CFQUERY>
	</cfif>
<cfelse>

<!--- This is called when the user clicks on the "save" link to save the form data. --->
<cfif form.blnsubmit>
  <cfoutput query="variables.qQualifications">

  	<cfquery name="checkrecords" datasource="#application.datasource#" >
  		SELECT *
  		FROM Program_Qualifications_Info
  		WHERE program_id = #url.Program_ID#
  		AND deleted = 0
  		AND Program_Qualification_ID = '#trim(variables.qQualifications.Program_Qualification_ID)#'
  	</cfquery>

  	<!---trim off extra characters--->
  	<cfset form[ variables.qQualifications.qualification_name ] = application.util.string.fullLeft( form[ variables.qQualifications.qualification_name ], application.util.query.columnMaxLength( "Program_Qualifications_Info.Value" ))>

  	<cfif checkrecords.recordcount>
  					<cfquery name="Updaterecords" datasource="#application.datasource#">
  						UPDATE Program_Qualifications_Info
  						SET value ='#form[qualification_name]#',
  								updated_by ='#request.AccessStructure.User_ID#',
  								Date_Updated = getdate()
  						WHERE Program_Qualification_ID = '#trim(variables.qQualifications.Program_Qualification_ID)#'
  						AND program_id = #url.Program_ID#
  					</cfquery>
  		<cfelse>
  					<cfquery name="Insertrecords" datasource="#application.datasource#" >
  						INSERT INTO Program_Qualifications_Info
  											(Program_Qualification_ID
  											,program_id
  											,value
  											,updated_by)
  						VALUES ('#trim(variables.qQualifications.Program_Qualification_ID)#'
  										,#url.Program_ID#
  										,'#form[qualification_name]#'
  										,'#request.AccessStructure.User_ID#')
  					</cfquery>
  	</cfif>

	<!--- 	Tim Ford - 01/28/2015: WR 47770 - QUALIFICATIONS -- WHEN EDIT/CREATE OPTION TO SAVE VALUE IN OPERATOR MASTER FIELDS
			If this qualification is flagged to store the value selected then save the value to the Operator_Type field in BSA_Operator --->
	<cfset bStoreOperatorType = form[Replace(Program_Qualification_ID, '-', '_', 'ALL') & "_Store_Operator_Type"] />

	<cfif bStoreOperatorType eq 1>

		<cfquery name="qUpdateBSAOperatorType" datasource="#application.datasource#">
			UPDATE	BSA_Operator
			SET		BSA_Operator.Operator_Type = '#form[qualification_name]#'
			FROM	BSA_Operator
					INNER JOIN Contract_Operators ON Contract_Operators.BSA_Operator_ID = BSA_Operator.BSA_Operator_ID AND Contract_Operators.Deleted = 0
			WHERE	Contract_Main_ID = '#url.Program_ID#'
			AND		BSA_Operator.Deleted = 0

		</cfquery>

	</cfif>

  </cfoutput>

   </cfif>

</cfif>


<!--- get "program qualification" info --->
<cfset qGetProgramQualificationDocs = program.getProgramQualificationDocs(url.Program_ID) />

<cfset useLakebaseForGet_LastUpdated_Details = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_qualifications_info")>
<cfif useLakebaseForGet_LastUpdated_Details>
	<cftry>
		<cfset Get_LastUpdated_Details = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_qualifications_info", {
				"program_id" = "eq.#url.Program_ID#",
				"deleted" = "eq.0",
				"order" = "date_updated.desc",
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_LastUpdated_Details = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_LastUpdated_Details>
<CFQUERY NAME="Get_LastUpdated_Details" datasource="#application.datasource#">
	SELECT		TOP 1 *
	FROM			Program_Qualifications_Info
	WHERE		program_id = #url.Program_ID#
	AND 			deleted = 0
	ORDER BY	Date_Updated DESC
</CFQUERY>
</cfif>

<CFIF Get_LastUpdated_Details.Recordcount GT 0>
	<cfset useLakebaseForgetUserName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetUserName>
	<cftry>
		<cfset getUserName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#Get_LastUpdated_Details.Updated_By#",
				"select" = "name_last as user_fullname"
			}), "name_last as user_fullname"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserName>
<CFQUERY NAME="getUserName" datasource="#application.datasource#">
		SELECT 	_Users.Name_First + ' ' + _Users.Name_Last AS User_FullName
		FROM 	_Users
		WHERE 	User_ID = '#Get_LastUpdated_Details.Updated_By#'
	</CFQUERY>
</cfif>
</CFIF>


<cfoutput>
<!---heading--->
<div id="hdr727">#application.returned_customer_setting.company_name#</div>
<div id="tp727"><b>Template:</b> #qGetProgramInfo.Created_Type#</div>
<fieldset id="fs727">
<legend>#qGetProgramInfo.Contract_Number#</legend>
</cfoutput>

 <!--- Call this when the user clicks on "save" link, and not while deleting attached documents. --->
<cfif cgi.request_method eq "post" and form.DeleteDocList eq "">
  <div class="success" style="height:15px;margin-top:15px;">
    <p>Your changes have been saved succesfully.</p>
  </div>
<cfelse>
 &nbsp; <IMG src="/images/ico-info.gif"> * Indicates required selection/answer<br>
 <cfoutput>
  <cfif get_lastupdated_details.recordcount gt 0 AND get_lastupdated_details.date_updated neq "">
		<table bgcolor="white" style="border-color:Orange;border-style:solid;" cellpadding="3" cellspacing="0" align="center">
			<tr>
					<td>
						<font size="2"><b>This was last updated on #dateformat(get_lastupdated_details.date_updated, 'm/d/yyy')# #timeformat(get_lastupdated_details.date_updated, 'h:mm:ss tt')#  by  #getusername.user_fullname#</b></font>
					</td>
			</tr>
		</table>
  </cfif>
 </cfoutput>

	<cfoutput>
  <form name="qualifications" action="qualifications.cfm?Program_ID=#url.Program_ID#" method="post" style="margin:0;padding:0">
  </cfoutput>
  <table cellspacing="5" border="0" style="width:100%">
<cfif  ! DisAllowAccessBasedOnLockStatus>
		<tr>
			<td colspan="3">
				<cf_button
					button_name	=	""
					button_caption	=	"save"
					button_action	=	"return SubmitForm();"
					button_type	=	"javascript_link"
					button_width	=	"75"
					button_color	=	"navy"
					button_tip	=	""
					font_color	=	"white"
					font_size		=	"12"
					font_weight	=	"bold"
				>
			</td>
		</tr>
	</cfif>
  		<cfoutput query="variables.qQualifications">

  		<tr>
  			<cfquery name="get_info" datasource="#application.datasource#" >
  				SELECT *
  				FROM Program_Qualifications_Info
  				WHERE program_id = #url.Program_ID#
  				AND deleted = 0
  				AND Program_Qualification_ID = '#trim(variables.qQualifications.Program_Qualification_ID)#'
  			</cfquery>
  			<cfset variables.required = ( variables.qQualifications.Answer_Required ? "required" : "" )>
  			<td valign=top style="width:200px;">#qualification_name# <cfif len(variables.required)><span style="color:red;font-weight: bold;font-size: 16px;">*</span><cfelse>&nbsp;</cfif></td>
  			<td>
  					<cfif type EQ 1>
  							<textarea name="#qualification_name#" rows="5" cols="75" style="width:98%" #variables.required#>#get_info.value#</textarea>
  					<cfelseif type EQ 2>
  							<cfset values = #variables.qQualifications.value#>
  							<select name="#qualification_name#" #variables.required# style="width:98%">
  											<option value="">Select an option</option>
  									<cfloop from="1" to="#listlen(values)#" index="i">
  											<option value="#listgetat(value, i)#" <cfif '#get_info.value#' EQ #listgetat(value, i)#>SELECTED</cfif>>#listgetat(value, i)#</option>
  									</cfloop>
  							</select>
  					</cfif>
					<INPUT TYPE="hidden" NAME="#Replace(Program_Qualification_ID, '-', '_', 'ALL')#_Store_Operator_Type" VALUE="#Store_Operator_Type#">
  			</td>
  		</tr>
  		</cfoutput>

		<!--- Dev Note: 44401 (Milan Mushran) - Add the program qualification document feature. --->
		<cfif qGetProgramInfo.Program_Qualifications_Doc_Attach_Req eq 1>
			<cfoutput><INPUT TYPE="Hidden" NAME="NumberOfDocs" VALUE="#qGetProgramQualificationDocs.Recordcount#"></cfoutput>
			<tr>
				<td colspan="3">Documents: <cfoutput>#qGetProgramInfo.Program_Qualifications_Doc_Msg#</cfoutput></td>
			</tr>
			<tr>
				<!--- This include file is used to upload documents. --->
				<td colspan="3" style="padding-left:1px;"><cfinclude template="/common_files/documents/create_multiple_document_details.cfm"></td>
			</tr>
			<tr>
				<td colspan="3" valign="top">
					<FIELDSET STYLE="padding:8px;  border: 1px solid Blue;">
						<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">currently attached document(s)</LEGEND>
						<CFIF qGetProgramQualificationDocs.recordcount GT 0>
							<INPUT TYPE="Hidden" NAME="DeleteDocList" VALUE="">
							<TABLE ID="Table_Delete" CLASS="Maintable" WIDTH="100%" CELLPADDING="3" CELLSPACING="0">
								<!--- TABLE HEADERS --->
								<TR BGCOLOR="#FFCE84" VALIGN="bottom">
									<TD ID="header"><FONT SIZE="1"><B>DELETE</B></FONT></TD>
									<TD ID="header"><FONT SIZE="1"><B>DATE<br>NAME</B></FONT></TD>
									<TD ID="header" ><FONT SIZE="1"><B>FILE</B></FONT></TD>
								</TR>
								<CFOUTPUT QUERY="qGetProgramQualificationDocs">
									<!--- DATA OUTPUT --->
									<TR ID="TR_Delete_#CurrentRow#" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
										<CFSET SIZEinMB = #Doc_size#/1024>
										<TD ID="Delete_#currentRow#"><A HREF="Javascript: DeleteTool('#Doc_ID#',1,'#CurrentRow#')"><img src="/Images/scissor.gif" height="9" title="Remove entry" border="0"></A></TD>
										<TD ID="TD1_#CurrentRow#">#DateFormat(Uploaded_Date,'mm/dd/yyyy')#<BR>#fullName#&nbsp;</TD>
										<TD ID="TD2_#CurrentRow#" NOWRAP TITLE="File Name: #Doc_File_Name#" ID=""><A href="javascript: confirmation('#Doc_Uni_Name#');" TITLE="Click here to view '#Doc_File_Name#'">
										<CFSET Display_Name=Left(Doc_File_Name,20)>
										<CFIF len(trim(Doc_File_Name)) GT 20>
											#LCASE(Display_Name)#...
										<CFELSEIF len(trim(Doc_File_Name)) EQ 0>
											&nbsp;
										<CFELSE>
											#LCASE(Display_Name)#
										</CFIF>
										</A><BR>#NumberFormat(SIZEinMB,'_.___')# KB&nbsp;</TD>
									</TR>
								</CFOUTPUT>
								<TR ID="TR_Confirm" STYLE="DISPLAY:NONE">
									<TD COLSPAN="100%" ALIGN="left" STYLE="border-bottom:none;">
										<B><FONT COLOR="Red" SIZE="2">[</FONT>
										<A HREF="Javascript: ConfirmDelete()">confirm delete</A>
										<FONT COLOR="Red" SIZE="2"> ]</FONT></B>
									</TD>
								</TR>
							</TABLE>
						<CFELSE>
							None
						</CFIF>
						<BR>
					</FIELDSET>
				</td>
			</tr>
		</cfif>
		<input type="hidden" name="blnsubmit" value="0">
		<cfif  ! DisAllowAccessBasedOnLockStatus>
		<tr>
			<td colspan="3">
				<cf_button
					button_name	=	""
					button_caption	=	"save"
					button_action	=	"return SubmitForm();"
					button_type	=	"javascript_link"
					button_width	=	"75"
					button_color	=	"navy"
					button_tip	=	""
					font_color	=	"white"
					font_size		=	"12"
					font_weight	=	"bold"
				>
			</td>
		</tr>
	</cfif>
  </table>
  </form>
  </fieldset>
</cfif>

<script>
function SubmitForm(){
  var emptyInput = 0;

  $('textarea[required], select[required]').each(function() {
    if ( $(this).val() == "" || $(this).val() == "0") {
      $(this).addClass("hilight");
      emptyInput++;
    }
  });

  if ( emptyInput > 0 ) {
    alert("Required fields were not filled, please make the changes and try again.");
    return false;
  }
	document.qualifications.blnsubmit.value = 1;

	/* If "document attachment" feature exists */
	if(document.qualifications.NumberOfDocs){
		/* If there is at least one attached document. */
		if(document.qualifications.NumberOfDocs.value > 0)
		{
			qualifications.submit();
		}
		else{
			alert('Please attach at least one document');
		}
	}
	else{
			qualifications.submit();
	}
}

 <!--- Call this when the user clicks on "save" link, and not while deleting attached documents. --->
<cfif cgi.request_method eq "post" and form.DeleteDocList eq "">
  // wait for a short moment, hide save success message and close window
  setTimeout(function() {
    $("div.success").hide('slow');

	var str = 	window.opener.parent.location.href;
	var res = str.replace("&pop019=qualifications", "");
	window.opener.parent.location.href = res;

	//window.opener.location.reload(false);//D43479
    window.close();
  }, 1750);
</cfif>

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
		cellObj.innerHTML = "<A HREF=\"Javascript: DeleteTool('"+DocID+"',"+action+","+currentRow+")\"><img src='/images/undo.gif' title='Restore document' border='0'></A>";
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
		cellObj.innerHTML = "<A HREF=\"Javascript: DeleteTool('"+DocID+"',"+action+","+currentRow+")\"><img src='/Images/scissor.gif' width='14' height='9' title='Remove document' border='0'></A>";
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


function ConfirmDelete()
{
	alert('It may take a few seconds to delete the documents');
	document.qualifications.submit();
}

</script>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
</body>
</html>
