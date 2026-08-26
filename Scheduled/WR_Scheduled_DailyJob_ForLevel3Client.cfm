<cfparam name="qGetID45StatusName.Punch_Status_Desc" default="4 - Dev Asgn">

<!--- ---------------------------------daily job to update the data in work_request table --------------------------------- --->

<cfquery name="qGetWebserviceOn" datasource="#application.datasource#">
	select WebserviceOn
	from _application_settings
</cfquery>

<CFIF qGetWebserviceOn.WebserviceOn eq 0>

	<cfquery name="qGetTop100WRs" datasource="#application.datasource#">
		select 	top 100 BA_Ticket_Number
		from 	work_request
		where 	len(BA_Ticket_Number) > 0
		and 	Deleted = 0
		order by Work_Request_ID DESC
	</cfquery>
	<cfset top100WRs = ValueList(qGetTop100WRs.BA_Ticket_Number,",")>

	
	<cfif qGetTop100WRs.recordcount GT 0>
		<!--- ---------------------------------update change_Code BEGIN--------------------------------- --->
		<cfquery name="qGetPunch_Changed_FilesWRs" datasource="punchlist">
			select Punch_ID
			from Punch
			where punch_deleted = 0
			and len(Punch_Changed_Files) > 8
			and Punch_Changed_Files not like '%N/A %'
			and Punch_Changed_Files not like '% N/A%'
			and Punch_ID in (#top100WRs#)
		</cfquery>
		<cfset Punch_Changed_FilesWRs = ValueList(qGetPunch_Changed_FilesWRs.Punch_ID,",")>

		<cfif qGetPunch_Changed_FilesWRs.recordcount GT 0>
			<cfquery name="updateWRschange_Code" datasource="#application.datasource#">
				update	work_request
				set 	Code_change = 1 	
				where 	BA_Ticket_Number in (#Punch_Changed_FilesWRs#)
			</cfquery>
		</cfif>
			update Code_change = 1 for below WRs:<br>
			<cfoutput>#Punch_Changed_FilesWRs#</cfoutput><br><br>
	
		<!--- ---------------------------------update change_Code END--------------------------------- --->

		<!--- ---------------------------------update Status BEGIN--------------------------------- --->
		<!--- select * from Punch_status order by Punch_Status_Desc
			1   1 - Open
			40  2 - Level 1 Review
			45  5 - Dev Asgn
			3   Complete
			22  Declined
			23  Duplicate
		---> 
		<!--- -------------------------1   1 - Open ------------------------- --->
		<cfquery name="qGetPunchComplete" datasource="punchlist">
			select Punch_ID, Punch_Release_Notes
			from Punch
			where punch_deleted = 0
			and punch_status_ID = 3
			and Punch_ID in (#top100WRs#)
		</cfquery>
		<cfset PunchComplete = ValueList(qGetPunchComplete.Punch_ID,",")>

		<cfif qGetPunchComplete.recordcount GT 0>
			<cfquery name="updatePunchComplete" datasource="#application.datasource#">
				update	work_request
				set 	Item_Status = 'Complete' 	
				where 	BA_Ticket_Number in (#PunchComplete#)
			</cfquery>			
		</cfif>
			update work_request.Item_Status = Complete  punch_status_ID = 3 for below WRs:<br>
			<cfoutput>#PunchComplete#</cfoutput><br><br>
		
		<!--- -------------------------22  Declined ------------------------- --->
		<cfquery name="qGetPunchDeclined" datasource="punchlist">
			select Punch_ID, Punch_Release_Notes
			from Punch
			where punch_deleted = 0
			and punch_status_ID = 22
			and Punch_ID in (#top100WRs#)
		</cfquery>
		<cfset PunchDeclined = ValueList(qGetPunchDeclined.Punch_ID,",")>

		<cfif qGetPunchDeclined.recordcount GT 0>
			<cfquery name="updatePunchDeclined" datasource="#application.datasource#">
				update	work_request
				set 	Item_Status = 'Declined' 	
				where 	BA_Ticket_Number in (#PunchDeclined#)
			</cfquery>			
		</cfif>
			update work_request.Item_Status = Declined  punch_status_ID = 22 for below WRs:<br>
			<cfoutput>#PunchDeclined#</cfoutput><br><br>

		<!--- -------------------------23  Duplicate ------------------------- --->
		<cfquery name="qGetPunchDuplicate" datasource="punchlist">
			select Punch_ID, Punch_Release_Notes
			from Punch
			where punch_deleted = 0
			and punch_status_ID = 23
			and Punch_ID in (#top100WRs#)
		</cfquery>
		<cfset PunchDuplicate = ValueList(qGetPunchDuplicate.Punch_ID,",")>

		<cfif qGetPunchDuplicate.recordcount GT 0>
			<cfquery name="updatePunchDuplicate" datasource="#application.datasource#">
				update	work_request
				set 	Item_Status = 'Duplicate' 	
				where 	BA_Ticket_Number in (#PunchDuplicate#)
			</cfquery>			
		</cfif>
			update work_request.Item_Status = Duplicate  punch_status_ID = 23 for below WRs:<br>
			<cfoutput>#PunchDuplicate#</cfoutput><br><br>

		<!--- -------------------------45  4 - Dev Asgn ------------------------- --->
		<cfquery name="qGetPunchDevAsgn" datasource="punchlist">
			select Punch_ID, Punch_Release_Notes
			from Punch
			where punch_deleted = 0
			and punch_status_ID = 45
			and Punch_ID in (#top100WRs#)
		</cfquery>
		<cfset PunchDevAsgn = ValueList(qGetPunchDevAsgn.Punch_ID,",")>

		<cfquery name="qGetID45StatusName" datasource="punchlist">
			select Punch_Status_Desc
			from Punch_status
			where Punch_status_ID = 45
		</cfquery>

		<cfif qGetPunchDevAsgn.recordcount GT 0>
			<cfquery name="updatePunchComplete" datasource="#application.datasource#">
				update	work_request
				set 	Item_Status = '#qGetID45StatusName.Punch_Status_Desc#' 	
				where 	BA_Ticket_Number in (#PunchDevAsgn#)
			</cfquery>			
		</cfif>
			update work_request.Item_Status = 4 - Dev Asgn  punch_status_ID = 45 for below WRs:<br>
			<cfoutput>#PunchDevAsgn#</cfoutput><br><br>

		<!--- ---------------------------------   update Status END--------------------------------- --->

		<!--- ---------------------------------update Release_Notes BEGIN--------------------------------- --->
		<cfif qGetPunchComplete.recordcount GT 0>
			<cfoutput  QUERY="qGetPunchComplete">
				<cfquery name="updatePunchReleaseNote" datasource="#application.datasource#">
					update	work_request
					set 	Release_Notes ='#qGetPunchComplete.Punch_Release_Notes#'
					where 	BA_Ticket_Number = '#qGetPunchComplete.Punch_ID#'
					and 	Release_Notes is NULL
				</cfquery>
			</cfoutput>			
		</cfif>
			update Release_Notes for  WRs.<br>
		<!--- ---------------------------------   update Release_Notes END--------------------------------- --->

		<!--- ---------------------------------update Stage Built Date BEGIN--------------------------------- --->
		<cfif qGetPunchComplete.recordcount GT 0>
			<cfquery name="updatebuiltOnStage" datasource="#application.datasource#">
				update work_request
				set builtOnStage = builtOnProd
				where builtOnStage is NULL
				and builtOnProd is not NULL
			</cfquery>
		</cfif>
			update Release_Notes for  WRs.<br>
		<!--- ---------------------------------  update Stage Built Date End --------------------------------- --->

	</cfif>
	Done!
</CFIF> <!--- end of <cfif qGetWebserviceOn.WebserviceOn eq 0> --->

