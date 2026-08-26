
<!--- D32285 : Manually Set BB Status to Paid 			................................................................. --->

<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
<cfparam name="form.massPayBillbackList" default="">

<cfquery name="GetBillbackData" datasource="#application.datasource#">
	SELECT * FROM Billback WHERE Billback_ID IN (#ListQualify(form.massPayBillbackList,"'","," )#)
</cfquery>
<cfset counter = 0>
<table width="600" align="Center" class="maintable" cellpadding="2" cellspacing="0">
	<tr><th class="tableHeader" bgcolor="orange" colspan="100%">Billbacks Paid</th></tr>
	<tr><td></td></tr>
	<cfloop query="GetBillbackData">
		<Cfif GetBillbackData.Billback_Status_ID IS 2>
			<!---If it's not approved, approve it --->
				
			<!---This is the main "it was approved" table --->
			<cfquery name="InsertBBApprovedInfo" datasource="#application.datasource#">
			INSERT INTO BB_Approved
			(
				Billback_ID,
				Paid_Amount,
				Approved_Amount,
				BB_Amount,
				Expected_Amount,
				Authorized_Amount,
				Date_Approved,
				User_Approved,
				Actual_Approved_Amt
			)
			VALUES
			(
				'#Billback_ID#',
				'#BB_Amount#',
				'#BB_Amount#',
				'#BB_Amount#',
				0,
				'#BB_Amount#',
				#now()#,
				'#request.AccessStructure.User_ID#',
				'#BB_Amount#'
			)
			</cfquery>
			
			<!---Update appropriate billback statuses --->
			<cfquery name="UpdateBillbacks" datasource="#application.datasource#">
			UPDATE Billback
			SET Billback_Status_ID = 5,
				BB_Payment_Request_Approved = 1,
				BB_Payment_Request_Approved_By = '#request.AccessStructure.User_ID#',
				BB_Payment_Request_Approved_Date = getdate(),
				Paid_Date = getdate(),
				Payment_Notes = 'This billback was paid using the mass payment feature'
			WHERE Billback_ID = '#Billback_ID#'
			</cfquery>
			
			<!---NOTE: this is a bare bones approach. There is supplementary stuff (like running deviations, sending emails, checking for correct payment etc. that was not needed for the client this was written for and was not implemented. This should not be use for a client with robust billback processing.) --->
		
		<cfelseif (GetBillbackData.Billback_Status_ID IS 3 OR GetBillbackData.Billback_Status_ID IS 4)>
			<!---Update appropriate billback statuses --->
			<cfquery name="UpdateBillbacks" datasource="#application.datasource#">
			UPDATE Billback
			SET Billback_Status_ID = 5,
				BB_Payment_Request_Approved = 1,
				BB_Payment_Request_Approved_By = '#request.AccessStructure.User_ID#',
				BB_Payment_Request_Approved_Date = getdate(),
				Paid_Date = getdate()
			WHERE Billback_ID = '#Billback_ID#'
			</cfquery>
		</CFIF>
		<Cfif GetBillbackData.Billback_Status_ID IS 2 OR GetBillbackData.Billback_Status_ID IS 3 OR GetBillbackData.Billback_Status_ID IS 4 >
			<cfset useLakebaseForBillbacksToPay = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForBillbacksToPay>
	<cftry>
		<cfset BillbacksToPay = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#Billback_ID#",
				"select" = "bb_code,bb_title,bb_amount,bb_date,auto_billback"
			}), "bb_code,bb_title,bb_amount,bb_date,auto_billback"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBillbacksToPay = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBillbacksToPay>
<cfquery name="BillbacksToPay" datasource="#application.datasource#">
				SELECT BB_Code, BB_Title, BB_Amount, BB_Date, Auto_Billback
				FROM Billback
				WHERE Billback_ID = '#Billback_ID#'
			</cfquery>
</cfif>
		
			<cfoutput>
            	<tr BGCOLOR="#IIf(counter Mod 2, DE('ffffff'), DE('C6FFC6'))#">
						<td><strong>#BillbacksToPay.BB_Code#</strong></td>
						<td>#BillbacksToPay.BB_Title#</td>
						<td>#lscurrencyformat(BillbacksToPay.BB_Amount)#</td>
						<td>#dateformat(BillbacksToPay.BB_Date, 'MM/DD/YYYY')#</td>
				</tr>
            </cfoutput>
		</cfif>
		<cfset counter = counter+1>
	</cfloop>
	<cfif listlen("form.massPayBillbackList") EQ 0>
		<tr><td>You did not select any billbacks to pay.</td></tr>
	</cfif>
	
</table>
<!---Show the billbacks that were approved/paid --->

<cfset returntocallingpage = cgi.http_referer>

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
							font_weight		=	"bold">
						</td><td>
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
							font_weight		=	"bold">
	</td></tr></Table>
</div>

<!---<cflocation url="#returntocallingpage#">--->