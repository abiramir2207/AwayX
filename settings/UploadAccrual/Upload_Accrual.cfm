<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<CFPARAM name="url.title" default="">
<CFPARAM NAME="URL.StartRow" DEFAULT="1">
<CFPARAM NAME="URL.frompage" DEFAULT="1">

<CFPARAM NAME="FORM.StartRow" DEFAULT="#URL.StartRow#">
<CFPARAM NAME="FORM.frompage" DEFAULT="#URL.frompage#">
<CFPARAM NAME="FORM.TITLE" DEFAULT="url.Title">

<CFSET StartRow = FORM.StartRow>
<CFSET frompage = FORM.frompage>
<cf_Number_of_Rows maxrows=12>


	<CFPARAM NAME="URL.RID" DEFAULT="">
	<CFPARAM NAME="FORM.WorkSheetName" DEFAULT="Sheet1">
	
<SCRIPT language="JavaScript">			
	function ViewFile(file)
	{
		var file_path;
		file_path = file;
		NewWindow('<CFOUTPUT>#application.HTTPVar##CGI.server_name#</CFOUTPUT>/GetDocument.cfm?FilePath=' + file_path, 'namewwwwww', '800', '600', 'Yes', 'Yes');	
	}	
</SCRIPT>

	<CFQUERY NAME="Get_Gl_Code" datasource="#application.datasource#">
		SELECT		 Accrual_Upload.*,
					Name_First,
					Name_last 
					
		FROM		Accrual_Upload 
		INNER JOIN	_Users ON _Users.User_ID = Accrual_Upload.Uploaded_By
		
		ORDER BY	Accrual_Upload_ID DESC
	</CFQUERY>
	<!--- <BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><FONT COLOR="red" SIZE="2"><B>The most recent uploaded version of the below listed file will be committed nightly.</B></FONT></TD>
		</TR>
	</TABLE> --->
	<BR>
	<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="750">
		<TR>
			<TD VALIGN="top">
	
				<SPAN CLASS="title2">Stored Records</SPAN>
				<HR COLOR="Blue" SIZE="1">
	
				<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" WIDTH="200" CLASS="Maintable">
					<TR>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Uploaded By</B>&nbsp;&nbsp;</SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Uploaded Date</B>&nbsp;&nbsp;</SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Fiscal Year</B></SPAN>&nbsp;&nbsp;</TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>File Type Uploaded</B></SPAN>&nbsp;&nbsp;</TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN>&nbsp;&nbsp;</TD>
						
					</TR>
					<CFSET RemoveThis = "#application.Doc_Mapping#/">
					<CFOUTPUT QUERY="Get_Gl_Code"  startrow="#StartRow#" maxrows="#MaxRows#">
					<TR>
						<CFSET FilePathThis = REPlaCE(fileLocation,RemoveThis,"")>
						<TD NOWRAP style="border-bottom: none">#Name_First# #Name_last# </TD>
						<TD NOWRAP style="border-bottom: none">#dateformat(Get_Gl_Code.Created_date, 'MM/DD/YYYY')# #timeformat(Get_Gl_Code.Created_date, 'H:MM tt')#</TD>
						<TD	ALIGN="Center" style="border-bottom: none">#Fiscal_Year#&nbsp;</TD>
						<TD	ALIGN="Center" style="border-bottom: none"><cfif datediff('d', Get_GL_Code.Created_Date, now()) LT 90><A href="javascript: ViewFile('#FilePathThis#');" TITLE="Program Start: #dateformat(Get_Gl_Code.Start_Date, 'MM/DD/YYYY')# Program End: #dateformat(Get_GL_Code.End_Date, 'MM/DD/YYYY')#" ><cfelse><a TITLE="Program Start: #dateformat(Get_Gl_Code.Start_Date, 'MM/DD/YYYY')# Program End: #dateformat(Get_GL_Code.End_Date, 'MM/DD/YYYY')#" disabled></cfif>#File_Type#</a>&nbsp;</TD>
						<TD NOWRAP ALIGN="Center" style="border-bottom: none">
								<CFIF Accrual_Process_Status_ID EQ 1>
								<IMG SRC="/images/yes_small.gif" TITLE="active record...">
								<CFELSEIF Accrual_Process_Status_ID EQ 0>
								<IMG SRC="/images/no_small.gif" TITLE="inactive record...">
								<CFELSE>
								<IMG SRC="/images/reminder_trans.gif" TITLE="in process...">
								</CFIF>
						</TD>
						
					</TR>
					<!--- <tr>
						<td>Program Start:</td>
						<td>#dateformat(Get_Gl_Code.Start_Date, 'MM/DD/YYYY')#</td>
						<td>Program End:</td>
						<td>#dateformat(Get_GL_Code.End_Date, 'MM/DD/YYYY')#</td>
						<td>&nbsp; </td>
					</tr> --->
					</CFOUTPUT>
				</TABLE>
	
				<BR>
	
				<IMG SRC="/images/yes_small.gif" BORDER="0" TITLE="" ALIGN="middle"> - Uploaded<BR>
				<IMG SRC="/images/no_small.gif" BORDER="0" TITLE="" ALIGN="middle"> - Not Uploaded<BR>
				<IMG SRC="/images/reminder_trans.gif" border="0" align="middle"> - In Process<br>
				
				
				<TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="0">
	<TR>
	<TD>
	<CF_Next_Previous_For_Forms
	formname="MyForm"
	query="Get_Gl_Code"
	maxpages="30"
	previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
	next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
	previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	firstseries		=	"<IMG SRC=""/images/first_series.gif"" ALIGN=""middle"" BORDER=""0"">"	
	lastseries		=	"<IMG SRC=""/images/last_series.gif"" ALIGN=""middle"" BORDER=""0"">"		
	addparams="">
	</TD>
	
	</TR>
	
	<form name="MyForm" action="upload_accrual.cfm" method="post">
	<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
<INPUT TYPE="Hidden" NAME="title" VALUE="#title#">
	</form>
	
	</TABLE>
				
			</TD>
			<TD VALIGN="top">
	
	
				<SPAN CLASS="title2">Add files</SPAN>
				<HR COLOR="Blue" SIZE="1">
	
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<!--- Retrieve the data for the ID of the item passed --->
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				
	
				
					<FORM ACTION="Upload_Accrual_Action.cfm" METHOD="post" NAME="SubmitFile" ENCTYPE="multipart/form-data">
					
					<TABLE CELLSPACING="5" CELLPADDING="0">
						
						<tr><td colspan="2"><font color="navy" size="2">You must add all four files before you can upload the data.</font></td></tr>

						<tr><td colspan="2">
						<p></p><cfoutput>
						<a href="doc_formatting_example.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;"><img src="/images/doc.gif" border="0"> Read instructions on how to format these files</a><br>
						<a href="ACCRUAL_HEADER.xls" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;"><img src="/images/doc.gif" border="0"> See a sample Accrual file</a><br>
						<a href="ACCRUAL_DETAIL.xls" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;"><img src="/images/doc.gif" border="0"> See a sample Accrual Item file</a></cfoutput>
						</td></tr>
									
						<TR>
							<TD VALIGN="top"><B>Start Date:</B></TD>
							<TD VALIGN="top"><CF_EASYDATE FORMNAME="SubmitFile" FIELDNAME="Start_Date" FORMAT="mm/dd/yyyy" DEFAULT=""></TD>
						</TR>
						<TR>
							<TD VALIGN="top"><B>End Date:</B></TD>
							<TD VALIGN="top"><CF_EASYDATE FORMNAME="SubmitFile" FIELDNAME="End_Date" FORMAT="mm/dd/yyyy" DEFAULT=""></TD>
						</TR>
						<TR>
							<TD VALIGN="top"><B>Fiscal Year:</B></TD>
							<TD VALIGN="top">
							<CFOUTPUT>
							<CFIF URL.RID EQ "">							
								<SELECT NAME="Fiscal_Year">
									<OPTION VALUE="#right(YEAR(DateAdd("yyyy",-1,now())), 2)#">#YEAR(DateAdd("yyyy",-1,now()))#</OPTION>
									<OPTION VALUE="#right(YEAR(now()), 2)#" SELECTED>#YEAR(now())#</OPTION>
									<OPTION VALUE="#right(YEAR(DateAdd("yyyy",1,now())), 2)#">#YEAR(DateAdd("yyyy",1,now()))#</OPTION>
									<OPTION VALUE="#right(YEAR(DateAdd("yyyy",2,now())), 2)#">#YEAR(DateAdd("yyyy",2,now()))#</OPTION>
									<OPTION VALUE="#right(YEAR(DateAdd("yyyy",3,now())), 2)#">#YEAR(DateAdd("yyyy",3,now()))#</OPTION>
								</SELECT> 									
							<CFELSE>
								#Get_Item.Fiscal_Year#
							</CFIF>
							</CFOUTPUT>										
							</TD>
						</TR>				
										
						<TR>
							<TD VALIGN="top" NOWRAP><SPAN ID="ERR_FILE"></SPAN><b>Accrual:</B></TD>
							<CFOUTPUT>
							<TD VALIGN="top"><INPUT SIZE="45" TYPE="file" NAME="AccrualFile" onblur="showLink()"></TD>						
							</CFOUTPUT>
						</TR>	
						<TR>
							<TD VALIGN="top">&nbsp; Work Sheet Name:</TD>
							<TD VALIGN="top"><CFOUTPUT><INPUT TYPE="Text" NAME="AccrualWorkSheetName" onblur="showLink()" value="TRADEWINDS_ACCRUAL"></CFOUTPUT></TD>
						</TR>		
						
						<TR>
							<TD VALIGN="top" NOWRAP><SPAN ID="ERR_FILE"></SPAN><B>Accrual Items:</B></TD>
							<CFOUTPUT>
							<TD VALIGN="top"><INPUT SIZE="45" TYPE="file" NAME="AccrualItemFile" onblur="showLink()"></TD>						
							</CFOUTPUT>
						</TR>	
						<TR>
							<TD VALIGN="top">&nbsp;Work Sheet Name:</B></TD>
							<TD VALIGN="top"><CFOUTPUT><INPUT TYPE="Text" NAME="AccrualItemWorkSheetName" onblur="showLink()" value="ACCRUAL_ITEM_DIM"></CFOUTPUT></TD>
						</TR>		
						
						
						
						<TR>
							<TD VALIGN="top" NOWRAP><SPAN ID="ERR_FILE"></SPAN><B>CDP:</B></TD>
							<CFOUTPUT>
							<TD VALIGN="top"><INPUT SIZE="45" TYPE="file" NAME="CDPFile" onblur="showLink()"></TD>						
							</CFOUTPUT>
						</TR>	
						 <TR>
							<TD VALIGN="top">&nbsp;Work Sheet Name:</TD>
							<TD VALIGN="top"><CFOUTPUT><INPUT TYPE="Text" NAME="CDPWorkSheetName" onblur="showLink()" value="TRADEWINDS_SHELTER"></CFOUTPUT></TD>
						</TR>	 
						
						<TR>
							<TD VALIGN="top" NOWRAP><SPAN ID="ERR_FILE"></SPAN><B>CDP Items:</B></TD>
							<CFOUTPUT>
							<TD VALIGN="top"><INPUT SIZE="45" TYPE="file" NAME="CDPItemFile" onblur="showLink()"></TD>						
							</CFOUTPUT>
						</TR>	
						<TR>
							<TD VALIGN="top">&nbsp;Work Sheet Name:</TD>
							<TD VALIGN="top"><CFOUTPUT><INPUT TYPE="Text" NAME="CDPItemWorkSheetName" onblur="showLink()" onfocus="showLink()" value="SHELTER_ITEM_DIM"></CFOUTPUT></TD>
						</TR>	 
																
						
						<TR id="uploadlink" style="display: none">
							<TD VALIGN="top" ALIGN="Right">
							<!--- <B>	
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
								<A HREF="index.cfm?Show_Tab=3"><B>create new entry</B></A>
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>&nbsp;&nbsp;
							</B> --->&nbsp; 
							</TD>
							<TD VALIGN="top">								
								<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
										<A HREF="javascript: validate()"><B>upload data</B></A>
								<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
									
													
							</TD>						
						</TR>
				
					</TABLE>				
				</FORM>				
			</TD>
		</TR>
	</TABLE>
	
	
	<SCRIPT SRC="/Common_Files/scripts/Date_Difference.js"></SCRIPT>
	 
	<SCRIPT language="JavaScript">	
	
	function checkDate(dateStr1,dateStr2)
	{
	 	var dateSplit; 
	 	var retVal = null;
		dateSplit = dateStr1.split("/"); 
		if(dateSplit.length > 2)
	 	{
	 	 	var date1 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
	  		dateSplit = dateStr2.split("/");
	  		if(dateSplit.length > 2)
	  		{
	   			var date2 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
	   			retVal = days_between(date1, date2, true);
	  		}
	 	}
	 	return retVal;
	}		
	
	function showLink()
	{	var bDisplay = "";
		
		if(document.SubmitFile.Start_Date.value.length > 0 && document.SubmitFile.End_Date.value.length > 0 && document.SubmitFile.AccrualFile.value.length > 0 && document.SubmitFile.AccrualItemFile.value.length > 0 && document.SubmitFile.CDPFile.value.length > 0 && document.SubmitFile.CDPItemFile.value.length > 0)
		{
			document.all.uploadlink.style.display = bDisplay;
		}
	}
	
	function validate()
	{
		if(confirm("The data you are uploading will replace any previous data for the same fiscal year. Are you sure you want to continue?")) 
		{
			document.SubmitFile.submit()
		}
		
	}
	</SCRIPT>


</body>
</html>
