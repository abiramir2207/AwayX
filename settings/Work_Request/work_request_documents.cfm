
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>

	<title>Work Request Documents</title>
<SCRIPT language="JavaScript">
var spinnerwind;
var file_name;
function OpenDoc(file)
{
	file_name = file;
	var view_confirm = confirm("Large files may take several minutes to open.");
	if (view_confirm == true)
	{
		NewWindow(file_name, 'WRDoc', '800', '600','yes','yes',false,'yes');  
	}
}

</SCRIPT>
</head>

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- Dev Note: KAL - D7443: This stops the [get help] from displaying twice  --->
<CFSET GetHelpURL =1> 

<CFPARAM NAME="URL.Work_Request_ID" DEFAULT=0>
<CFPARAM NAME="URL.MatchAttch" DEFAULT="">
<CFPARAM NAME="URL.Work_Request_Document_ID" default="">
<CFPARAM NAME="FORM.WR_Document_Name" DEFAULT="">
<CFPARAM NAME="FORM.WR_Document_Description" DEFAULT="">
<CFPARAM NAME="FORM.WR_Document_Location" DEFAULT="">
<CFPARAM NAME="FORM.Uploaded_By" DEFAULT="">
<CFPARAM NAME="FORM.Uploaded_Date" DEFAULT="">
<CFPARAM NAME="FORM.Deleted" DEFAULT="">
<CFPARAM NAME="URL.DeleteWorkReqDec" default="0">
<CFPARAM NAME="FORM.DeleteAttchedFile" DEFAULT=0>
<CFPARAM NAME="SaveDisabled"  DEFAULT="">
<body>

<!--- delete attached Document for a work request :: start--->
<cfif URL.DeleteWorkReqDec eq 1 AND len(URL.Work_Request_Document_ID) GT 0>
	<CFQUERY NAME="getDeletedWR_AttachedDoc" datasource="#application.datasource#">
		select BA_Ticket_Number,WR_Document_Name,Actual_File_Name,Work_Request.Work_Request_ID
		from Work_Request_Document
		inner join Work_Request on Work_Request.Work_Request_ID = Work_Request_Document.Work_Request_ID
		and Work_Request_Document_ID = #URL.Work_Request_Document_ID#
	</CFQUERY>
	<CFQUERY NAME="DeleteWR_AttachedDoc" datasource="#application.datasource#">
		update 	Work_Request_Document
		set 	Deleted = 1,
		Deleted_By = '#request.accessStructure.User_ID#'
		where 	Work_Request_Document_ID = #URL.Work_Request_Document_ID#
	</CFQUERY>
	<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getWebserviceOn() EQ 1>
			<cfset Punchlist_URL = "http://tools.awayx.com/components/webservices/Work_Requests.cfc?wsdl">
			<cfset createObject("java", "coldfusion.server.ServiceFactory").XmlRpcService.refreshWebService("#Punchlist_URL#")>
	
			<cfinvoke
			webservice="#Punchlist_URL#"
			method="DeleteAttachedDocWR"
			timeout = "300">
			<cfinvokeargument name="BA_Ticket_Number" value="#getDeletedWR_AttachedDoc.BA_Ticket_Number#" />	
			<cfinvokeargument name="WR_Document_Name" value="#getDeletedWR_AttachedDoc.WR_Document_Name#" />
			<cfinvokeargument name="Actual_file_name" value="#getDeletedWR_AttachedDoc.Actual_File_Name#" />
			<cfinvokeargument name="User_ID" value="#request.accessStructure.User_ID#" />
			</cfinvoke>		
			
	<cfelse>
			<cfquery name="DeleteWR_AttachedDoc_Punch" datasource="punchlist">
				Update 	Punch_File
				set 	deleted = 1,
						Deleted_By = '#request.accessStructure.User_ID#'
				where 	Punch_ID = '#getDeletedWR_AttachedDoc.BA_Ticket_Number#'
				and 	Punch_File_Name ='#getDeletedWR_AttachedDoc.WR_Document_Name#'
				and 	Punch_File_Name_Saved_As ='#getDeletedWR_AttachedDoc.Actual_File_Name#'
			</cfquery>	
	</cfif> 
	<CFLOCATION URL="work_request_documents.cfm?Work_Request_ID=#getDeletedWR_AttachedDoc.Work_Request_ID#" ADDTOKEN="No">
	<CFABORT>
</cfif>
<!--- delete attached Document for a work request :: end--->

<CFSET URL.PageTitle="Work Request Documents">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFQUERY NAME="PunchID" datasource="#application.datasource#">
	Select	BA_Ticket_Number
	From	Work_Request
	Where 	Work_Request_ID = #Work_Request_ID#
</CFQUERY>

<cfif URL.MatchAttch NEQ "">
	<CFQUERY NAME="Get_Doc_Details" datasource="#application.datasource#">
		Select	*
		From	Work_Request_Document
		Where 	MatchAttch = '#MatchAttch#'
		And deleted = 0
		Order by	WR_Document_Name
	</CFQUERY>
<cfelse> 
	<CFQUERY NAME="Get_Doc_Details" datasource="#application.datasource#">
		Select		*
		From		Work_Request_Document
		Where 	Work_Request_ID = #Work_Request_ID#
		And 	deleted = 0
		Order by	WR_Document_Name
	</CFQUERY>
	<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="750">
		<TR><TD><b><cfif URL.MatchAttch EQ "">Work Request:  #<cfoutput>#PunchID.BA_Ticket_Number#</cfoutput></cfif></b></TD></TR>
	</TABLE>
</cfif>

<cfif  (PunchID.BA_Ticket_Number  EQ "" OR  PunchID.BA_Ticket_Number  EQ 0) and URL.Work_Request_ID GT 0>
	<cfset SaveDisabled  = "disabled">
</cfif>	

<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="750">
		<TR>
			<TD VALIGN="top">

				<SPAN CLASS="title2">Stored Documents</SPAN>
				<HR COLOR="Blue" SIZE="1">
				<DIV STYLE="width:290px; <CFIF Get_Doc_Details.recordcount GT 10>height:330px;</CFIF> overflow:auto;">
				<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" <CFIF Get_Doc_Details.recordcount GT 10>WIDTH="273" <CFELSE>WIDTH="288"</CFIF>  CLASS="Maintable">
					<TR>
						<TD WIDTH="60%"><SPAN STYLE="font-size: 12px;"><B>File</B></SPAN></TD>
						
						<TD STYLE="font-size:11px;"  nowrap>
							<B>Saved By</b><BR>
							<b>Date</b>
						</TD>
						
						<TD NOWRAP>&nbsp;</TD>
					</TR>
         	<!--- 
        				Dev Notes: D24468/Anand Rao/17-Aug-10
        				URL on email notifications
        	--->  
          <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
        
			<cfset siteURL = application.HTTPVar & CGI.SERVER_NAME />
					
					<cfoutput query="Get_Doc_Details">
					<TR>
						<TD WIDTH="60%"><A HREF="" onclick="OpenDoc('#siteURL#/GetDocument.cfm?FilePath=#WR_Document_Location#');return false;">#WR_Document_Name# &nbsp;</A></TD>
						<TD NOWRAP>
							<cfquery name="CreatedUserInfo" datasource="#application.datasource#">
								SELECT Name_First, Name_Last FROM _Users WHERE User_ID = '#Uploaded_By#'
							</cfquery>
							#CreatedUserInfo.Name_First# #CreatedUserInfo.Name_Last#<BR>#DateFormat(Uploaded_Date, 'MM/DD/YYYY')#
						</TD>
									
						<cfif URL.MatchAttch NEQ "">
							<TD ><A HREF=""  onclick="alert_and_delete_AttchedFile('#Work_Request_Document_ID#','#WR_Document_Name#');return false;"><img src="/images/no_small.gif" TITLE="Delete Fille #WR_Document_Name# " BORDER="0"></a></TD>
						<cfelse>
							<TD ><A HREF="work_request_documents.cfm?Work_Request_Document_ID=#Work_Request_Document_ID#&DeleteWorkReqDec=1"><img src="/images/no_small.gif" TITLE="Delete Fille #WR_Document_Name# " BORDER="0"></a></TD>
						</cfif>
					</TR>
					</cfoutput>
					
				</TABLE>
				</DIV>
				<BR>
			</TD>
			<TD VALIGN="top" WIDTH="60%">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for the ID of the item passed --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				

<CFPARAM NAME="Get_Item.Work_Request_ID" DEFAULT="0">
<CFPARAM NAME="Get_Item.Work_Request_Document_ID" DEFAULT="">
<CFPARAM NAME="Get_Item.WR_Document_Name" DEFAULT="">
<CFPARAM NAME="Get_Item.WR_Document_Location" DEFAULT="">
<CFPARAM NAME="Get_Item.Uploaded_By" DEFAULT="">
<CFPARAM NAME="Get_Item.Uploaded_Date" DEFAULT="">
<CFPARAM NAME="Get_Item.Deleted" DEFAULT="">


			<SPAN CLASS="title2"><CFIF URL.Work_Request_Document_ID NEQ "">Edit<CFELSE>Add</CFIF> Document</SPAN>
			<HR COLOR="Blue" SIZE="1">
<cfif URL.MatchAttch NEQ "">
<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
	Select		*
	From		work_request_document
	<CFIF URL.Work_Request_Document_ID NEQ "">
	Where		MatchAttch = '#MatchAttch#'
	and deleted = 0	
	<CFELSE>
	where 1 = 2
	</CFIF>
</CFQUERY>
<cfelse>
<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
	Select		*
	From		work_request_document
	<CFIF URL.Work_Request_Document_ID NEQ "">
	Where		Work_Request_Document_ID = '#URL.Work_Request_Document_ID#'
	and deleted = 0	
	<CFELSE>
	where 1 = 2
	</CFIF>
</CFQUERY>
</cfif>
<SCRIPT language="JavaScript">
function alert_and_delete_AttchedFile(Work_Request_Document_ID,WR_Document_Name)
{
	if (MyForm.MatchAttch.value !="")
	{
		var confirmdeletefile = confirm("Click OK to delete this attached file...");
		if (confirmdeletefile == true)
		{
			var strIDs = Work_Request_Document_ID;
			var strFileName = WR_Document_Name;
			window.opener.FilesHandlerDelete( strFileName );
		}
		document.all.DeleteAttchedFile.value=1;
		document.all.Work_Request_Document_ID.value=strIDs;
		document.MyForm.submit();
	}
			
}
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
	var rid = "<cfoutput>#URL.Work_Request_Document_ID#</cfoutput>";
	x = document.MyForm;
	error = 0;
	if (rid == 0)
	{
		if (x.WR_Document_Location.value == "")
		{
			queueMessage("Please select a file to upload.", document.all.ERR_FILE);
			error = 1;
		}
		{
			clearQueue(document.all.ERR_FILE);
		}
	}
	if (x.WR_Document_Name.value == "")
	{
		//alert("Title can't be empty. Please, enter some value");
		//x.Doc_Title.focus();
		queueMessage("Title can't be empty. Please enter a title.", document.all.ERR_TITLE);
		error = 1;
	}
	else
	{
		clearQueue(document.all.ERR_TITLE);
	}
	
	if (error == 0)
	{	
		var upload = "<cfoutput>#url.Work_Request_Document_ID#</cfoutput>";
		
		if (upload == "")
		{
			var upload_confirm = confirm("Large files may take several minutes to upload.");
			if (upload_confirm == true)
			{
				if (MyForm.MatchAttch.value !="")
				{
					var strIDs = MyForm.WR_DocumentName.value;
					window.opener.FilesHandler( strIDs );
				}
				document.MyForm.submit();	
			}
		}
		else
		{
			if (MyForm.MatchAttch.value !="")
			{
				var strIDs = MyForm.WR_DocumentName.value;
				window.opener.FilesHandler( strIDs );
			}
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
	var x = document.MyForm.WR_Document_Location.value;
	var len = x.length;
	var position = x.lastIndexOf("\\");
	var filename=x.substr(position+1,len);	
	document.all.WR_Document_Name.value = filename;
	document.all.WR_DocumentName.value = filename;
}	
var spinnerwind;
function confirmation()
{
	var view_confirm = confirm("Large files may take several minutes to open.");
	if (view_confirm == true)
	{
		NewWindow('<CFOUTPUT>#application.HTTPVar##CGI.server_name#</CFOUTPUT>/GetDocument.cfm?FilePath=/common_documents/data_files/uploaded/settings/work_request/<cfoutput>#ReReplace(ReReplace(Get_Item.WR_Document_Name,"##","&##35;","ALL"),"'","&##39;","ALL")#</cfoutput>', 'name', '800', '600', 'Yes', 'Yes',false,'yes');
	}
}

</SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>

				
			<FORM ACTION="work_request_documents_save.cfm" METHOD="post" NAME="MyForm" ENCTYPE="multipart/form-data" <!--- ONSUBMIT="return validate();" --->>

			<cfoutput><CFPARAM NAME="Get_Item.Work_Request_Document_ID" DEFAULT="">
			<INPUT TYPE="hidden" NAME="Work_Request_Document_ID" 		VALUE="#Get_Item.Work_Request_Document_ID#">
			<INPUT TYPE="hidden" NAME="MatchAttch" 		VALUE="#MatchAttch#">
			</cfoutput>

				
				<TABLE CELLSPACING="5" CELLPADDING="0">
					<CFIF URL.Work_Request_Document_ID NEQ "">
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
					
					<CFIF URL.Work_Request_Document_ID EQ "">
					<TR>
						<TD VALIGN="top" ALIGN="right" NOWRAP><SPAN ID="ERR_FILE"></SPAN>&nbsp;<B>Select Upload File </B></TD>
						<CFOUTPUT>
						<TD VALIGN="top"><INPUT SIZE="45" TYPE="file" NAME="WR_Document_Location" onchange="javascript: autofill()" #SaveDisabled#></TD>						
						</CFOUTPUT>
					</TR>
					</CFIF>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>File Name</B></TD>								
						<CFOUTPUT>
						<TD VALIGN="top"> <INPUT SIZE="45" NAME="WR_DocumentName" VALUE="#ReReplace(ReReplace(Get_Item.WR_Document_Name,"##","&##35;","ALL"),"'","&##39;","ALL")#" MAXLENGTH="50" READONLY DISABLED>  
									<INPUT TYPE="hidden" NAME="WR_Document_Name" VALUE="#ReReplace(ReReplace(Get_Item.WR_Document_Name,"##","&##35;","ALL"),"'","&##39;","ALL")#"> 	 				
						<CFIF Get_Item.WR_Document_Name NEQ "">						
							<FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
							<A href="javascript: confirmation(#WR_Document_Location#); "  TITLE="Click on this link to view this document"><B>view</b></A>
							<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
						</CFIF>						
						</TD></CFOUTPUT>
						
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
						<INPUT TYPE="radio" VALUE="1" NAME="Deleted"#inactive#>Inactive 
						</CFOUTPUT>

						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"></TD>
						<TD VALIGN="top">
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
								<cfif  (PunchID.BA_Ticket_Number  EQ "" OR  PunchID.BA_Ticket_Number  EQ 0) and URL.Work_Request_ID GT 0>
									<B>save data</B>
								<cfelse>
									<A HREF="javascript: validate();"><B>save data</B></A>
								</cfif>
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
							
							<INPUT TYPE="hidden" NAME="DeleteRecord" VALUE="0">
							<INPUT TYPE="hidden" NAME="DeleteAttchedFile" VALUE="0">
							<CFIF Get_Item.Deleted EQ 1>
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: alert_and_delete();"><B>delete data</B></A>
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>

							</CFIF>

							<CFIF URL.Work_Request_Document_ID EQ "">
							<FONT COLOR="#ff0000" SIZE="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>file size limit: 10MB</b>
							</FONT>
							</CFIF>
							<cfoutput><input type="hidden" name="Work_Request_ID" value="#Work_Request_ID#"></cfoutput>
						</TD>
					</TR>
					<cfif  (PunchID.BA_Ticket_Number  EQ "" OR  PunchID.BA_Ticket_Number  EQ 0) and URL.Work_Request_ID GT 0>
						<TR>
						<TD  ALIGN="center" colspan=2>
						<font color=#0000A0><b>Blacksmith is in the process of assigning a request ## to your record. Please modify this request later.</b></font>
						</TD>
						</TR>
					</cfif>
				</TABLE>
				
			</FORM>
			<CFOUTPUT>

			<FORM Action="#CGI.http_referer#" METHOD="POST" NAME="Back_to_common_Search">
<!--- 			<INPUT TYPE="hidden" NAME="Form_Name" VALUE="#FORM.Form_Name#">	
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
			<INPUT TYPE="hidden" NAME="Is_Welcome_Letter" VALUE="#Form.Is_Welcome_Letter#">		 --->
			</FORM>
			</CFOUTPUT>
			</TD>
		</TR>
	</TABLE>
	
<SCRIPT language="JavaScript">
	function gobacktocommonsearch()
	{
		var searchform = document.Back_to_common_Search;
		searchform.submit();
	}
</SCRIPT>	



  

<CF_MessageWindow>

</body>
</html>

