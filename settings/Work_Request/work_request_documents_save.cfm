
<CFPARAM NAME="Form.MatchAttch" DEFAULT="">
<CFPARAM NAME="Get_Label_No.BA_Ticket_Number" DEFAULT=0>
<CFPARAM NAME="Form.DeleteAttchedFile" DEFAULT=0>
<CFPARAM NAME="Form.Work_Request_ID" DEFAULT=0>

<!--- set delete to 1--->
<cfif FORM.DeleteAttchedFile EQ 1>
	<CFQUERY NAME="delete_AttchedFile" datasource="#application.datasource#">
		update  Work_Request_Document  
		set deleted = 1
		where	Work_Request_Document_ID =  '#Form.Work_Request_Document_ID#'	
	</CFQUERY>
	<CFLOCATION URL="work_request_documents.cfm?MatchAttch=#Form.MatchAttch#" ADDTOKEN="No">
	<CFABORT>
<cfelse>

<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
		DELETE FROM Work_Request_Document  
		WHERE		Work_Request_Document				=	'#Form.Work_Request_Document#'
	</CFQUERY>
	<CFLOCATION URL="work_request_documents.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>

<CFQUERY NAME="Get_Label_No" datasource="#application.datasource#">
	Select		BA_Ticket_Number
	From		Work_Request
	Where Work_Request_ID = #Form.Work_Request_ID#
</CFQUERY>

<!--- Get user name --->
<CFQUERY name="GetUserName" datasource="#application.datasource#">
	Select	Name_First + ' ' + Name_Last as uploadedBy
	From	_Users 
	Where	User_ID = '#request.accessStructure.User_ID#'
</CFQUERY>

<cfscript>
	compWorkRequest = CreateObject("component","settings.Work_Request.WorkRequest");
</cfscript>

<CFIF Form.Work_Request_Document_ID EQ "">
	<!---Check size of file being uploaded--->
	<cfset InsertStatus = "1">
	<cfset TempDirectoryLocation = GetDirectoryFromPath(FORM.WR_Document_Location)>
	<cfset TempFileName = GetFileFromPath(FORM.WR_Document_Location)>
	<cfdirectory directory="#TempDirectoryLocation#" filter="#TempFileName#" name="Tempdirectory">
	<cfset FileSize = Tempdirectory.Size>
	<!---If they uploaded a zero length or invalid file, redirect back with error information--->
	<cfif Filesize LT 1>
	<BR><BR><BR><BR>
		<TABLE ALIGN="CENTER">
		  <TR>
	  		<TD style="font-weight:bold;">The size of the uploaded file is 0 bytes.&nbsp;&nbsp;Please upload a larger file.</TD>
		  </TR>
		</TABLE>
		<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 7000);</SCRIPT> 
		<CFABORT>	
	</cfif>	

	<CFFILE ACTION = "upload"
			FILEFIELD = "WR_Document_Location"
			DESTINATION = "#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_doc"
			NAMECONFLICT ="MakeUnique">

	<CFSET Temp_File_name = CFFILE.serverFile>
	<CFSET typeoffile = CFFILE.ContentType>
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
	
	<!--- Dev Note: Clay 9136 - Prevent invalidly named documents from saving --->	
	<cfset badstring = "()[]{}*^%$##@!~`'," />
	<cfif FindOneOf(badstring,content) NEQ 0>
	<BR><BR><BR><BR>
		<TABLE ALIGN="CENTER">
		  <TR>
	  		<TD style="font-weight:bold;">The uploaded file contains invalid characters; possibly including "()[]{}*^%$##@!~`',".&nbsp;&nbsp;Prior to upload, please rename the file.</TD>
		  </TR>
		</TABLE>
		<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 7000);</SCRIPT> 
		<CFABORT>	
	</cfif>
	<CFSET Unique_ID = createUUID()>
	<cfset sDateTime = "#DateFormat(now(), 'yyyymmdd')##timeFormat(now(), 'HHmmss')#"/>
	<CFSET Actual_File_Name = "#Replace(Unique_ID,"-","_","all")#_#Get_Label_No.BA_Ticket_Number#_#sDateTime#.#family#">
	<CFSET FilePathInApp = "#Application.Doc_Path#\Data_Files\Uploaded\settings\work_request\#Actual_file_name#">

	<CFFILE ACTION = "rename"
			SOURCE = "#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_doc\#temp_file_name#"
  			DESTINATION = "#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_Doc\#Actual_file_name#">
			
	<CFFILE ACTION = "copy"
			SOURCE = "#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_doc\#Actual_file_name#"
  			DESTINATION = "#Application.Doc_Path#\Data_Files\Uploaded\settings\work_request\#Actual_file_name#">  
<!---
<cfscript>
		stErrorPunch = StructNew();
		stErrorPunch.bNameExists = compWorkRequest.UpdatePunchlistDoc(InsertStatus,Get_Label_No.BA_Ticket_Number,Form.WR_Document_Name,Actual_file_name,request.accessStructure.User_ID,FilePathInApp,sizeoffile,Form.MatchAttch);
</cfscript>
--->
	<!--- Insert the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		SET NOCOUNT ON
		INSERT INTO		Work_Request_Document
						(		
							Work_Request_ID,
							WR_Document_Name,
							WR_Document_Location,
							Uploaded_By,
							Deleted,
							MatchAttch,
							Actual_File_Name
						)
						
		Values			(	
							'#Form.Work_Request_ID#',
							'#Form.WR_Document_Name#',
			'/Data_Files/Uploaded/settings/work_request/#Actual_file_name#',
							'#request.accessStructure.User_ID#',
							'#Form.Deleted#',
							'#Form.MatchAttch#',
							'#Actual_file_name#'
						)

		SET NOCOUNT OFF			
	</CFQUERY>
	<cfif Form.MatchAttch NEQ "" and application.oApplicationAppSettingsManager.getApplicationAppSettings().getWebserviceOn() EQ 0>
		<cfquery name="InsertToPunch_File" datasource="punchlist">
				INSERT INTO Punch_File
				(	
					Punch_ID,
					Punch_File_Name,
					Punch_File_Name_Saved_As,
					Uploaded_By,
					FilePathInApp,
					Punch_File_Size,
					MatchAttch
				)
				VALUES
				(
				'#Get_Label_No.BA_Ticket_Number#',
				'#Form.WR_Document_Name#',
				'#Actual_file_name#',
				'#GetUserName.uploadedBy#',
				'#FilePathInApp#',
				'#sizeoffile#',
				'#Form.MatchAttch#'
				)
		</cfquery>
	</cfif>
	<cfif Form.MatchAttch EQ "" and  len(#Get_Label_No.BA_Ticket_Number#) GT 0>	
		<CFIF application.oApplicationAppSettingsManager.getApplicationAppSettings().getWebserviceOn() EQ 1>
			<!--- Send to Punchlist db --->
			<!---
			<CFTHREAD ACTION="RUN" name="WR_Dec_Add_#sDateTime#" InsertStatus="#InsertStatus# BA_Ticket_Number="#Get_Label_No.BA_Ticket_Number#" WR_Document_Name="#Form.WR_Document_Name#"  Actual_file_name="#Actual_file_name#" User_ID="#request.accessStructure.User_ID#" FilePathInApp="#FilePathInApp#" sizeoffile="#sizeoffile#" MatchAttch="#Form.MatchAttch#">
				<cfinclude template="work_request_documents_save_thread.cfm">
				<!---<cflog file="WRLog" application="no" text="Insert to PunchList">--->
			</CFTHREAD>
			--->
			<cfset Punchlist_URL = "http://tools.awayx.com/components/webservices/Work_Requests.cfc?wsdl">
	
			<!--- should we replace with a periodically exeucted function like clear cache instead of executing every single time? --->
			<cfset createObject("java", "coldfusion.server.ServiceFactory").XmlRpcService.refreshWebService("#Punchlist_URL#")>
	
			<cfinvoke
			webservice="#Punchlist_URL#"
			method="InsertWorkRequestDoc"
			timeout = "300">
			<cfinvokeargument name="InsertStatus" value="#InsertStatus#" />
			<cfinvokeargument name="BA_Ticket_Number" value="#Get_Label_No.BA_Ticket_Number#" />	
			<cfinvokeargument name="WR_Document_Name" value="#Form.WR_Document_Name#" />
			<cfinvokeargument name="Actual_file_name" value="#Actual_file_name#" />
			<cfinvokeargument name="User_ID" value="#request.accessStructure.User_ID#" />
			<cfinvokeargument name="FilePathInApp" value="#FilePathInApp#" />
			<cfinvokeargument name="sizeoffile" value="#sizeoffile#" />
			<cfinvokeargument name="MatchAttch" value="#MatchAttch#" />
			</cfinvoke>		
			<!--- end send to punchlist --->
		<CFELSE>
			<!--- INSERT/UPDATE Punch_File by using DSN --->
			<cfif #InsertStatus# eq "1">
				<cfquery name="InsertToPunch_File" datasource="punchlist">
				INSERT INTO Punch_File
				(	
					Punch_ID,
					Punch_File_Name,
					Punch_File_Name_Saved_As,
					Uploaded_By,
					FilePathInApp,
					Punch_File_Size,
					MatchAttch
				)
				VALUES
				(
				'#Get_Label_No.BA_Ticket_Number#',
				'#Form.WR_Document_Name#',
				'#Actual_file_name#',
				'#GetUserName.uploadedBy#',
				'#FilePathInApp#',
				'#sizeoffile#',
				'#Form.MatchAttch#'
				)
				</cfquery>
			<cfelse>
				<cfquery name="UpdatePunch_File" datasource="punchlist">
				Update Punch_File
				set deleted = 1
				where Punch_ID = '#Get_Label_No.BA_Ticket_Number#'
				and 	Punch_File_Name ='#Form.WR_Document_Name#'
				and 	Punch_File_Name_Saved_As ='#Actual_file_name#'
				</cfquery>
			</cfif>
		</CFIF>
	<!--- end punchlist using DSN --->
	</cfif>

	<BR><BR><BR><BR>
<TABLE ALIGN="CENTER">
	<TR>
		<TD>Please wait while the file is being uploaded....</TD>
	</TR>
</TABLE>	

<CFELSE>
	<cfset InsertStatus = "0">
	<!--- Update the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		Work_Request_Document
		SET 		WR_Document_Name	 =		'#WR_Document_Name#',
					WR_Document_Location = 		'#WR_Document_Location#',
					Deleted = 		'#Deleted#'
		WHERE		Work_Request_Document_ID	=	'#Form.Work_Request_Document_ID#'
	</CFQUERY>
</CFIF>

<cfif Form.MatchAttch NEQ "">
	<CFLOCATION URL="work_request_documents.cfm?MatchAttch=#Form.MatchAttch#" ADDTOKEN="No">
<cfelse>
	<CFLOCATION URL="work_request_documents.cfm?Work_Request_ID=#Work_Request_ID#" ADDTOKEN="No">
</cfif>
<CFABORT>
</cfif>
