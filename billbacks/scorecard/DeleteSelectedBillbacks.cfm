
<!---BJF Deleted selected billbacks D11948--->
<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
<cfparam name="BillbacksToDelete" default="">

<cfoutput>
	
	<cfset counter = 0>
	
<table width="600" align="Center" class="maintable" cellpadding="2" cellspacing="0">
	<tr><th class="tableHeader" bgcolor="orange" colspan="100%">Billbacks you deleted</th></tr>
	<tr><td></td></tr>
	<cfloop list="#BillbacksToDelete#" index="BillbackID">
		<cfset Billback_ID = replace(BillbackID, "_", "-", "all")>
		
		<cfquery name="BillbacksToDelete" datasource="#application.datasource#">
		SELECT BB_Code, BB_Title, BB_Amount, BB_Date, Auto_Billback
		FROM Billback
		WHERE Billback_ID = '#Billback_ID#'
		</cfquery>

		<tr BGCOLOR="#IIf(counter Mod 2, DE('ffffff'), DE('C6FFC6'))#">
				<td><strong>#BillbacksToDelete.BB_Code#</strong></td>
				<td>#BillbacksToDelete.BB_Title#</td>
				<td>#lscurrencyformat(BillbacksToDelete.BB_Amount)#</td>
				<td>#dateformat(BillbacksToDelete.BB_Date, 'MM/DD/YYYY')#</td>
		</tr>
		
	<cfif BillbacksToDelete.Auto_Billback eq 1>
		<cfset URL.BBID = Billback_ID>
		<cfset IsAutoBB = 1>
			<cfinclude template="/billbacks/common/auto_bb_delete.cfm">
	<cfelse>
		<cfquery name="DeleteTheBillbacks" datasource="#application.datasource#">
			UPDATE Billback 
			SET Deleted = 1
			,Deleted_By_User_id =  '#request.AccessStructure.User_ID#'
			,Deleted_Date = getdate()
			WHERE Billback_ID = '#Billback_ID#'
		</cfquery>
		<cfstoredproc procedure="Upload_EDI_Dup_Delete" datasource="#application.datasource#">	
			<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR"	dbVarName = "@@Billback_ID" value="#Billback_ID#" null="false" />
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER"	dbVarName = "@@Upload_ID" null="true"/>
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER"	dbVarName = "@@Header_ID" null="true"/>
		</cfstoredproc>
	</cfif>
	
		<cfset counter = counter+1>
	</cfloop>
	
	<cfif listlen("BillbacksToDelete") EQ 0>
		<tr><td>You did not select any billbacks to delete.</td></tr>
	</cfif>
	
</table>
<div align="Center">
	<Table><tr><td>
<CF_button
							button_name		=	""
							button_caption	=	"return to scorecard"
							button_action	=	"/billbacks/scorecard/scorecard_main.cfm"
							button_type		=	"link"
							button_width	=	"200"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						></td><td>
<CF_button
							button_name		=	""
							button_caption	=	"return to search"
							button_action	=	"/billbacks/scorecard/billback_search.cfm"
							button_type		=	"link"
							button_width	=	"200"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						>
	</td></tr>
</div>
</cfoutput>