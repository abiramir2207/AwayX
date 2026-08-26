<!------
bb_delete2.cfm
----->
<CFSET delete_This_Billback = 1>

<CFIF NOT isDefined("FORM.deleteBillback")>
	<CFSET delete_This_Billback = 0>
</CFIF>

<cfparam name="form.removepullbacksapplied" default="1">

<CFSET tempString = CGI.HTTP_REFERER>
<CFSET tempString = reverse(tempString)>

<CFSET tempString = listtoarray(tempString, "/")>
<CFSET tempString = tempString[1]>
<CFSET tempString = reverse(tempString)>

<CFIF listlen(tempString, "?") GT 1>
	<CFSET tempString = listtoarray(tempString, "?")>
	<CFSET tempString = tempString[1]>
</CFIF>
<CFSET HTTP_REFERER_FileName = tempString>


<CFIF lcase(HTTP_REFERER_FileName) NEQ lcase("bb_delete.cfm")>
	<CFSET delete_This_Billback = 0>
</CFIF>

<CFIF NOT isDefined("FORM.Billback_ID")>
	<CFSET delete_This_Billback = 0>
</CFIF>

<CFIF delete_This_Billback>
	<cfset useLakebaseForBB_Info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForBB_Info>
	<cftry>
		<cfset BB_Info = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#Billback_ID#",
				"deleted" = "eq.0",
				"select" = "bb_code,bb_title,billback_status_id,bb_payment_request_sent,bb_received_ack_type,bb_approved_void_ack_type"
			}), "bb_code,bb_title,billback_status_id,bb_payment_request_sent,bb_received_ack_type,bb_approved_void_ack_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBB_Info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBB_Info>
<CFQUERY name="BB_Info" datasource="#Application.Datasource#">
		SELECT	BB_Code, BB_Title, Billback_Status_ID,
				BB_Payment_Request_Sent,BB_Received_Ack_Type,BB_Approved_Void_Ack_Type
		FROM	Billback
		WHERE	Billback.Billback_ID = '#Billback_ID#' AND
				Billback.Deleted = 0
	</CFQUERY>
</cfif>
	<CENTER>
		<FONT COLOR="#FF0000" SIZE="+1">
		<CFSET AllowDeleted = 1>
		<CFIF BB_Info.Billback_Status_ID EQ 4 AND (BB_Info.BB_Payment_Request_Sent EQ 1 AND BB_Info.BB_Received_Ack_Type NEQ 2)>
			<CFSET AllowDeleted = 0>
			This billback has been interfaced to the accounting system, Can't delete this.					
		</CFIF> 
		</FONT>
		<BR>
		<BR>	
	</CENTER>
	<CFIF AllowDeleted EQ 0>
	<CFABORT>
	<CFELSE>
		<cfif IsAutoBB eq 0>
			<cfset CreateObject("component", "components.billback.BillbackManager").deleteBillback(FORM.Billback_ID, request.AccessStructure.User_ID) />
		<cfelse>
			<cfinclude template ="auto_bb_delete.cfm">
		</cfif>
		<cfif form.removepullbacksapplied EQ 1>
		<cfset CreateObject("component","components.programs.pullbacks.PullbackManager") .deleteBillbackPullbacks(FORM.Billback_ID) />
		</cfif>
		
		
		<SCRIPT LANGUAGE="JavaScript">
			window.parent.location.href = "/billbacks/scorecard/scorecard_main.cfm";
		</SCRIPT>
	</CFIF>
</CFIF>

<CFIF NOT delete_This_Billback>
	<SCRIPT LANGUAGE="JavaScript">
		history.back();
	</SCRIPT>
</CFIF>