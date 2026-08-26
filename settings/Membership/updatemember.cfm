<!----
	Name: updatemember.cfm 
	Created By:   Dinesh Rachala :: 03/04/2013     
	Copyright (c) 2013 Blacksmith Applications, Inc.       
 	Description:
	Usage: Used to update customer group members table.
---->

<!--- REMOVE --->
<cfif form.remove>
	 
	<cftransaction>	
<cfif form.previousMemberId>
		<cfquery name="updateMemberStartDate" datasource="#application.datasource#">
				UPDATE customer_group_members
				SET end_date = '#form.updateEndDate#'
				WHERE customer_group_members_id = #form.previousMemberId#
				AND customer_group_type = '#form.groupType#'	
		</cfquery>
</cfif>
		<cfquery name="deleteMember" datasource="#application.datasource#">
				UPDATE  customer_group_members
				SET deleted = 1
				WHERE customer_group_members_id = '#form.currentMemberId#'
				AND customer_group_type = '#form.groupType#'
		</cfquery>
		
	</cftransaction>
<!--- UPDATE --->	
<cfelseif form.update>

	<cftransaction>		

		<cfquery name="updateMemberStartDate" datasource="#application.datasource#">
				UPDATE customer_group_members
				SET start_date = '#form.startDate#'
				WHERE customer_group_members_id = '#form.currentMemberId#'
				AND customer_group_type = '#form.groupType#'
		</cfquery>
<cfif form.previousMemberId>
		<cfquery name="updateMemberEndDate" datasource="#application.datasource#">
				UPDATE customer_group_members
				SET end_date = DATEADD(day,-1,#dateformat(form.startDate, "yyyy-mm-dd hh:mm:ss")#)
				WHERE customer_group_members_id = '#form.previousMemberId#'
				AND customer_group_type = '#form.groupType#'
		</cfquery>
</cfif>
	</cftransaction>
		
</cfif>
<script>
	window.parent.TINY.box.hide();
</script>