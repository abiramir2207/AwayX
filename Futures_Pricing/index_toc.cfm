<cfoutput>
	<script language="JavaScript">		
		function printEmailFax(thisObj)
		{
			var pagePhase = 1;
			var innerFrame = window.right;
			if(innerFrame)
			{
				var pagePhaseObj = innerFrame.document.all.pagePhase;
				if(pagePhaseObj)
				{
					pagePhase = pagePhaseObj.value;
				}
			}
			//alert(pagePhase);
			NewWindow(thisObj.href + "&pagePhase=" + pagePhase, 'emailRequest', 800, 600, 'yes', 'yes');return false;
			return false;
		}
	</script>
	<TABLE BORDER="0" CELLPADDING="0" STYLE="border-collapse: collapse" WIDTH="100%">
		<TR>
			<TD>
			<A HREF="index.cfm" TARGET="_self"><IMG BORDER="0" SRC="/Images/Futures_Pricing/main_folder.gif" WIDTH="25" HEIGHT="23"></A></TD>
			<TD>&nbsp;
			</TD>
			<TD WIDTH="100%">&nbsp;
			<input type="Hidden" id="statusId" value="#statusId#">
			</TD>
		</TR>
		<cfset statusImgList = "request,materials,procurement,calculator,calculator" />
		<cfinclude template="common/common.cfm" />
		<!------ get status form db ----->
		<cfset qAllStatus = CreateObject("component", "components.futures_pricing.StatusManager").getAll() />
		<!--- <cfset notesExist = CreateObject("component", "components.futures_pricing.NoteManager").getNotesExist(fpRequest.getId()) /> --->
		<!---get note count--->
		<cfset noteCount = CreateObject("component", "components.futures_pricing.NoteManager").getNoteCount(fpRequest.getId(), request.AccessStructure.user_id) />
		<!---get reminder count--->
		<cfset reminderCount = CreateObject("component", "components.futures_pricing.ReminderManager").getReminderCount(request.AccessStructure.user_id, url.id) />
		
		<cfloop query="qAllStatus">
		
			<cfset pagePhase = FP_Status_ID />
			<cfif statusId EQ pagePhase AND fpRequest.getGroupUserAccess(pagePhase)>
				<cfset pageURL = "handler.cfm?command=#ListGetAt(statusCECommandList, pagePhase)#&id=#url.id#">
			<cfelse>
				<cfset pageURL = "handler.cfm?command=#ListGetAt(statusDCommandList, pagePhase)#&id=#url.id#">			
			</cfif>
			<cf_index_toc_section 
					url = "#pageURL#"
					image = "/Images/Futures_Pricing/#ListGetAt(statusImgList, pagePhase)#.gif"
					text = "#FP_Status_Desc#"
					enabled = "#(statusId GTE pagePhase) AND (statusId GT pagePhase OR (statusId EQ 5 AND fpRequest.getPricingStatusId() GT 1) OR fpRequest.getGroupUserAccess(pagePhase))#"
					>
			
		</cfloop>
		
		<!------ Documents ----->
		<cfset pageURL = "handler.cfm?command=ceDocuments&id=#url.id#" />
		<cf_index_toc_section 
			url = "#pageURL#"
			image = "/Images/Futures_Pricing/attachment.gif"
			text = "documents"
			parameters = "onClick=""javascript: NewWindow(this.href , 'request_documents' , 800 , 600 , 'yes' , 'yes'); return false;"""
			enabled = "#url.id NEQ 0#"
		>
		<!---Notes--->
		<cfset pageURL = "handler.cfm?command=dNotes&id=#url.id#" />
		<cf_index_toc_section 
			url = "#pageURL#"
			image = "/Images/Futures_Pricing/notes.gif"
			text = "notes (#noteCount#)"
			parameters = "onClick=""javascript: NewWindow(this.href , 'notes' , 600 , 500 , 'yes' , 'yes'); return false;"""
			enabled = "#url.id NEQ 0#"
		>
		<!--- showDataExist="#notesExist#" --->
		<!---Reminders--->
		<cfset pageURL = "handler.cfm?command=dReminder&id=#url.id#" />
		<cf_index_toc_section 
				url = "#pageURL#"
				image = "/Images/Futures_Pricing/reminder.gif"
				text = "reminders (#reminderCount#)"
				parameters = "onClick=""javascript: NewWindow(this.href , 'reminders' , 600 , 500 , 'yes' , 'yes'); return false;"""
				enabled = "#url.id NEQ 0#"
				>
		<cfset pageURL = "print_fax_email.cfm?mode=email&id=#url.id#">
		<cf_index_toc_section 
				url = "#pageURL#"
				image = "/Images/Futures_Pricing/email.gif"
				text = "email"
				enabled = "#url.id NEQ 0#"
				parameters = "onClick=""javascript: return printEmailFax(this);"""
				>				
		<cfset pageURL = "print_fax_email.cfm?mode=fax&id=#url.id#">
		<cf_index_toc_section 
				url = "#pageURL#"
				image = "/Images/Futures_Pricing/fax.gif"
				text = "fax"
				enabled = "#url.id NEQ 0#"
				parameters = "onClick=""javascript: return printEmailFax(this);"""
				>
		<cfset pageURL = "print_fax_email.cfm?mode=print&id=#url.id#">
		<cf_index_toc_section 
				url = "#pageURL#"
				image = "/Images/Futures_Pricing/printer.gif"
				text = "print"
				enabled = "#url.id NEQ 0#"
				parameters = "onClick=""javascript: return printEmailFax(this);"""				
				>
		
		<!--- Marketing Users --->
		<cfset groupId = 2>
		<cfset pageURL = "handler.cfm?command=ceSelectUser&groupId=#groupId#&id=#url.id#" />
		<cf_index_toc_section 
			url = "#pageURL#"
			image = "/Images/Futures_Pricing/user.gif"
			text = "Marketing Users"
			parameters = "onClick=""javascript: NewWindow(this.href , 'marketing_users' , 600 , 500 , 'yes' , 'yes'); return false;"""
			enabled = "#statusId GTE groupId AND fpRequest.getGroupUserAccess(groupId-1)#"
		>
		<!--- Procurement Users --->
		<cfset groupId = 3>
		<cfset pageURL = "handler.cfm?command=ceSelectUser&groupId=#groupId#&id=#url.id#" />		
		<cf_index_toc_section 
			url = "#pageURL#"
			image = "/Images/Futures_Pricing/user.gif"
			text = "Procurement Users"
			parameters = "onClick=""javascript: NewWindow(this.href , 'marketing_users' , 600 , 500 , 'yes' , 'yes'); return false;"""
			enabled = "#statusId GTE groupId AND fpRequest.getGroupUserAccess(groupId-1)#"
			last = "1"
		>
</TABLE>

<BR>

<CENTER>
<CF_smallLink 
	title = "deal sheet"
	url = "handler.cfm?command=dealSheet&id=#url.id#"
	enabled = "#url.id NEQ 0#"
	parameters = " target=""right"""
	>
<BR>
<CF_smallLink 
	title = "scorecard"
	url = "index.cfm"
	>
<BR>
<CF_smallLink 
	title = "search"
	url = "scorecard/search.cfm"
	>
</CENTER>
</cfoutput>
