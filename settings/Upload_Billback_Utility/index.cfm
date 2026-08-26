<!---  
       Name:          index.cfm           
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.       
       Created Date:  3/30/2007
       Created By:    cmorse
       Label:		  11367
       Description:   
--->
<CFOUTPUT>
	<CFPARAM NAME="URL.Show_Tab" DEFAULT="1">
	<cfparam name="FORM.showTab" default="#URL.Show_Tab#">
	<CFPARAM NAME="URL.filetype" DEFAULT="">
	<CFPARAM name="form.item_number" default="">
	<CFPARAM NAME="URL.StartRow" DEFAULT="1">
	<CFPARAM NAME="URL.frompage" DEFAULT="1">
	<CFPARAM NAME="FORM.StartRow" DEFAULT="#URL.StartRow#">
	<CFPARAM NAME="FORM.frompage" DEFAULT="#URL.frompage#">
</CFOUTPUT>
<!--- HANDLE FORM SUBMISSION FROM UPLOAD_HISTORY.CFM --->
<cfif FORM.showTab NEQ URL.Show_Tab> 
	<cfset URL.Show_Tab = FORM.showTab>
</cfif>

<!--- URL.TAB_TITLE has error_legend appended when a dynamic fourth column is requested (history or details). --->
<cfparam name="url.tab_title" default="Error Legend">
<cfif url.tab_title NEQ "Error Legend">
	<cfset url.tab_title = url.tab_title & ",Error Legend">
</cfif>

<!--- This section is all of the tabbed navigation code --->
<cfset Step_List="Upload Interface Files,Pending Uploads,Upload History,Purge Log,Upload Settings,#url.tab_title#">


<cfmodule template="/customTags/layout.cfm" 
							layoutID = "uploadPayables" 
							Step_List = "#Step_List#"
							jQueryNoConflict = ""
							selectedIndex = "#(URL.Show_Tab - 1)#" >

<!--- The header file includes all styles and javascript markup for interactive portions of the page. --->
	<!--- D29947 Update billback upload for SO/DC --->
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get(1, 2, 1)>
	<!--- D29947 Update billback upload for SO/DC --->
	
<cfinclude template="header.cfm" />

<cffunction name="JSDateFormat" output="false">

	<cfargument name="dDate" type="string" required="true">

	<cfreturn "#Month(arguments.dDate)#/#Day(arguments.dDate)#/#Year(arguments.dDate)#" />
	
</cffunction>

<!---<CFOUTPUT>
<CFSET i = 1>
<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0" WIDTH="100%" ALIGN="Center" ID="Table_Tab">
	<TR>			
	 	<TD class="headerblank">&nbsp;</TD>		
	 	<cfloop list="#Step_List#" index="thisIndex">
			<a ID="#i#" OnClick="javaScript: Change_Tab();" class="tablink_back" href="index.cfm?Show_Tab=#i#">			
	 		<cfif Len(Trim(thisIndex)) GT 0>	
	 			<TD width="100"
			<cfif URL.Show_Tab EQ i>
				class="headerselected" 		
			<cfelse>
				class="headernotselected" 
			</cfif>
				<cfif i NEQ 5>
		 		align="center" nowrap ID="PL_Type">
				<a ID="#i#" OnClick="javaScript: Change_Tab();" class="tablink_back" href="index.cfm?Show_Tab=#i#"><B><nobr>#LCase(thisIndex)#</nobr></B></a>				
				</TD></a>
		 		<cfif (i-1) lt Len(Step_List)>
					<td class="headerspacer"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></td>
				</cfif>
				</cfif>
			</cfif>
			<CFSET i = i + 1>
		</cfloop>
	<td class="headerspacer" width="100%"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></td>
	</TR>
</TABLE>
</CFOUTPUT>
--->
<!--- Todo: Create Custom Tag for simple tab navigation --->

<!--- Include content as needed --->
<CFIF URL.Show_Tab EQ 1>
	<cfinclude template="upload_file.cfm" />
<CFELSEIF URL.Show_Tab EQ 2>
	<cfinclude template="pending_uploads.cfm" />
<CFELSEIF URL.Show_Tab EQ 3>
<!--- 	<cfinclude template="upload_history.cfm" /> --->
	<cfinclude template="upload_history_ag.cfm" />
<CFELSEIF URL.Show_Tab EQ 4>
	<cfinclude template="purge_log.cfm">
<CFELSEIF URL.Show_Tab EQ 5>
	<cfset variables.src = "upload_settings" />
	<cfinclude template="upload_settings.cfm">
<CFELSEIF URL.Show_Tab EQ 6>
  <!--- 
		The sixth tab changes depending on what template is currently displayed
			a) upload detail is there for when a user inadvertently clicks the upload detail tab when it's active.'
			b) billbacks is available to display the billback associated with a history item.
			c) error legend contains all upload error messages and codes.
   --->
  <cfif url.tab_title EQ "Upload Detail,Error Legend">
    <cfinclude template="upload_detail2.cfm" />
  <cfelseif url.tab_title EQ "Billbacks,Error Legend">
    <cfinclude template="generated_billbacks.cfm">
  <cfelseif url.tab_title EQ "Error Legend">
  	<cfinclude template="error_legend.cfm">
  </cfif>
<CFELSEIF URL.Show_Tab EQ 7>
	<cfinclude template="error_legend.cfm">
<CFELSEIF URL.Show_Tab EQ 9>	
	<cfinclude template="upload_file_action.cfm" />
</CFIF>

<!---</body>
</html>
--->
</cfmodule>