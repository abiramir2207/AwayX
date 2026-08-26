

<cfset AdjustHomePath = ''/><!--- can set a default dir here [DEPRECATED]]  --->
<cfset docServer = 'https://pittfs.awayx.com/'/>
<cfset fpath = '/common_documents/Temp_Files/Billback/Document/'/> <!--- path that documents are saved to after coming from doc server '/common_documents/Temp_Files/Billback/Document/'   'ram:///' --->
<!--- <cfset certPath = 'D:\inc\BlacksmithClientAuth.pfx'/> deprecated --->
<cfset certPw = 'Black5m1th!'/> <!--- need to encrypt !! use cfinclude --->
<cfset templateName = 'browseBBDocs2.cfm'/>

<cfparam name="url.sort" default="type ASC">
<cfparam name="form.sort" default="#url.sort#">
<cfparam name="url.dir" default="">
<cfparam name="form.dir" default="#url.dir#">
<cfparam name="url.txtFileName" default="">
<cfparam name="form.txtFileName" default="#url.txtFileName#">
<cfparam name="url.fileUnique" default="">

<cfparam name="url.sortName" default="">
<cfparam name="url.sortDate" default="">
<cfparam name="url.sortType" default="">
<cfparam name="url.sortSize" default="">
<!--- USED to get files.  requires url.txtFileName to have a value. --->
<cfparam name="url.getFile" default="0">


<cfset url.dir = form.dir />
<cfset url.sort = form.sort />
<cfset url.txtFileName = form.txtFileName />
<cfif not isDefined("Get_Profile_Settings")>
	<cfinclude template="/get_access_profile.cfm" />
</cfif>

<cfif right(url.dir,4) EQ ".txt" OR 
	right(url.dir,4) EQ ".htm" OR 
	right(url.dir,4) EQ ".xls" OR 
	right(url.dir,5) EQ ".xlsx" OR 
	right(url.dir,4) EQ ".pdf" OR 
	right(url.dir,5) EQ ".docx" OR 
	right(url.dir,4) EQ ".doc" OR
	right(url.dir,4) EQ ".msg">
	
	<!---  <cfdump var="#url#"/><cfabort> --->
	<cfset fname = listLast(url.dir,'/') />
<cftry>
		<!--- #application.appSettingsGet.get_Setting('BB_Doc_Server_Folder')# --->
	<cfhttp method="GET" url="#docServer#Pittsburgh/#application.appSettingsGet.get_Setting('BB_Doc_Server_Folder')##URLEncodedFormat('#url.dir#')#" timeout="30"  path="#ExpandPath("#fpath#")#" file="#fname#" throwonerror="true" >  <!--- --->
	<!---	<cfhttpparam type="header" name="Accept-Encoding" value="*" />
		<cfhttpparam type="Header" name="TE" value="deflate;q=0">--->
	</cfhttp>
<cfcatch>
	<cfdump var="#cfcatch#"/><cfabort>
</cfcatch>

</cftry>
<!---	
	<cfoutput>#docServer##url.dir# :: #ExpandPath("#fpath#")##fname#   #fpath##fname#</cfoutput>
	<cfabort>--->
	<cfheader name="Content-Disposition" value="attachment; filename=#fname#" >
	<cfcontent type="#cfhttp.Mimetype#" file="#ExpandPath("#fpath#")##fname#" deletefile="false" >
</cfif>
<cfif application.appSettingsGet.getBillbackFileUploadType() EQ 3 AND (Get_Profile_Settings.Browse_BBDoc_Server_Files or url.getFile EQ 1)>

    <cfset attachments_http_time_out_in_seconds = application.util.query.get_Setting("attachments_http_time_out_in_seconds", 0)>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!---  default to use 90 seconds time-out when optional setting is missing or invalid  --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfif val(attachments_http_time_out_in_seconds) eq 0 or !isNumeric(attachments_http_time_out_in_seconds)>
        <cfset attachments_http_time_out_in_seconds = 90>
    </cfif>

	<!--- browseBBDocs.cfm --->
	<cfhttp method="GET" url="#docServer##templateName#" timeout="#attachments_http_time_out_in_seconds#"> <!---   --->
		<cfhttpparam type="url" name="sort" value="#url.sort#" >
		<cfhttpparam type="url" name="dir" value="#url.dir#" >
		<cfhttpparam type="url" name="txtFileName" value="#url.txtFileName#" >
		<cfhttpparam type="url" name="getFile" value="#url.getFile#" >
		<cfhttpparam type="url" name="sortName" value="#url.sortName#" >
		<cfhttpparam type="url" name="sortDate" value="#url.sortDate#" >
		<cfhttpparam type="url" name="sortType" value="#url.sortType#" >
		<cfhttpparam type="url" name="sortSize" value="#url.sortSize#" >
		<cfhttpparam type="url" name="home" value="#application.appSettingsGet.get_Setting('BB_Doc_Server_Folder')#" >
	</cfhttp>
<cfelse>
<!--- 	<cfset http.Filecontent = ''/> --->
</cfif>

<cfif url.getFile EQ 1 >
		<!--- CHECK FOR A MANUALLY UPLOADED FILE FIRST--->
		<cfset siteURL = application.HTTPVar & CGI.SERVER_NAME />
		<cfif url.FileUnique NEQ "">
			<cfoutput>
				<cfset filePath = 'data_files/uploaded/documents/uploaded_doc/#url.FileUnique#'/>
				<!---<cfoutput>#filePath#</cfoutput>--->
				<cfinclude template='/getDocument.cfm'/>
			</cfoutput>
		</cfif>
	<!--- KREEP GOING --->
	<cfset DOCFILENAME = ArrayNew(1)/>
	<cfif structkeyexists(cfhttp.responseHeader,"set-cookie")>
		<cfset response = cfhttp.responseHeader["set-cookie"] />
		<!---<cfdump var="#cfhttp#"/>--->
		<cfif isStruct(response) eq false>
			<cfset struct = structnew() />
			<cfset struct["1"] = response />
			<cfset response = struct />
		</cfif>
		<cfset i = 1>
		<cfloop collection='#response#' item="x">
			<cfset s = listfirst(response[x],';')/>
		    <cfif Left(s,11) eq "DOCFILENAME">
				<cfset DOCFILENAME[i] = URLDECODE(replace(s,'DOCFILENAME=','')) />
				<cfset i++>
			</cfif>
		</cfloop>
	</cfif>
	<cfif ArrayLen(DOCFILENAME) eq 1>
		<cfset url.dir = DOCFILENAME[1] />
		<cfif right(url.dir,4) EQ ".txt" OR 
				right(url.dir,4) EQ ".htm" OR 
				right(url.dir,4) EQ ".xls" OR 
				right(url.dir,5) EQ ".xlsx" OR 
				right(url.dir,4) EQ ".pdf" OR 
				right(url.dir,5) EQ ".docx" OR 
				right(url.dir,4) EQ ".doc" OR
				right(url.dir,4) EQ ".msg">
			<cfset fname = listLast(url.dir,'/') />
			<!---<cfoutput>#docServer#Pittsburgh#URLEncodedFormat("#url.dir#")#</cfoutput>--->
				<!--- #application.appSettingsGet.get_Setting('BB_Doc_Server_Folder')# --->
			<!---<cfdump var="#docServer#Pittsburgh/#URLEncodedFormat('#url.dir#')#"/><cfabort>--->
			<cfhttp method="GET" url="#docServer#Pittsburgh/#application.appSettingsGet.get_Setting('BB_Doc_Server_Folder')##replace(URLEncodedFormat('#url.dir#'),'%2F','/','all')#" timeout="30" path="#ExpandPath("#fpath#")#" file="#fname#"> <!---  --->
			<!---<cfdump var="#cfhttp#"/><cfabort>--->
			<cfheader name="Content-Disposition" value="attachment; filename=""#fname#""" >
			<cfcontent type="#cfhttp.Mimetype#" file="#ExpandPath("#fpath##fname#")#" deletefile="false">
		<cfelse>
		</cfif>
	<cfelseif ArrayLen(DOCFILENAME) GT 1> <!--- more than one file located on doc server --->
		<cfset s = cfhttp.FileContent /><!--- remove form variables --->
		<cfset s = REPLACE(s,'type="text"','type="hidden"','All') />
		<cfset s = REPLACE(s,'type="submit"','type="hidden"','All') />
		<cfoutput>#ArrayLen(DOCFILENAME)# Documents Found Named <b>"#Replace(DOCFILENAME[1],'/','')#"</b></cfoutput>
		<cfoutput>#s#</cfoutput> <!--- show list of returned files --->
	<cfelse>
	    <p align="center">
		<span style="FONT-SIZE: 12pt; FONT-FAMILY: 'Century Gothic'; font-weight:bold">
			File not found. [<span style="FONT-SIZE: 11pt; FONT-FAMILY: 'Century Gothic'; font-weight:normal; color='red' "><cfoutput>#txtFileName#</cfoutput></span>]
		</span>
		</p>
	</cfif>
</cfif>

<cfif url.getFile EQ 0 ><!--- Display HTML (Directory listings) returned from Doc Server --->
	<cfoutput>#cfhttp.FileContent#</cfoutput>
</cfif>
