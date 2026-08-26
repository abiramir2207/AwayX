<!------ fp_nightly_process.cfm ----->
<cfoutput>
<!------ Get settings values ----->
<cfset fpSettingsManager = CreateObject("component", "components.futures_pricing.SettingsManager").init() />
<cfset fpSettings = fpSettingsManager.get()>

<!---send reminders--->
<cfset CreateObject("component", "components.futures_pricing.ReminderManager").runReminders() />

<!------ 
send mail about each request which  has 
a customer deadline arriving 
or
and the first offer good until date is arriving
----->
<cfset fpRequestManager = CreateObject("component", "components.futures_pricing.RequestManager").init() />
<cfset qGetEmailRequests = fpRequestManager.emailRequests(fpSettings.getNotifyCustDeadlineLeadTime(), fpSettings.getNotifyOfferGoodUntilLeadTime())>

<cfloop query="qGetEmailRequests">
	<!------ get user emails concerned for this request ----->
	<!------ <cfset requestUsersList = "dkunnath@bigredflame.com;tford@bigredflame.com"> ----->
	<cfset requestUsersList = "dkunnath@bigredflame.com">
	<cfset requestUsersList = fpRequestManager.getRequestUserEmails(FP_Request_Master_ID, FP_Status_ID) />
	
	<cfset SendcustDeadlineEmail = 0>
	<cfset SendgoodUntilEmail = 0>
	<cfif CustDeadlineDaysLeft LTE fpSettings.getNotifyCustDeadlineLeadTime() AND NOT CustDeadlineMailSent>
		<cfset SendcustDeadlineEmail = 1>
	</cfif>
	<cfif GoodUntilDaysLeft LTE fpSettings.getNotifyOfferGoodUntilLeadTime() AND isNumeric(GoodUntilDaysLeft) AND NOT OfferGoodUntilMailSent>
		<cfset SendgoodUntilEmail = 1>
	</cfif>
	<cfif SendcustDeadlineEmail OR SendgoodUntilEmail>
		<!------ send mail ----->		
		<cfsavecontent variable="EmailContents">
		Futures Pricing Request <B>'#FP_Request_Title#'</B><br>
		<cfif SendcustDeadlineEmail AND Isnumeric(CustDeadlineDaysLeft)>
			The customer deadline date is <B>#DateFormat(FP_Cust_Deadline_Date, "mm/dd/yyyy")#</B> which 
			<cfif CustDeadlineDaysLeft EQ 0>
				is today.
			<cfelseif  CustDeadlineDaysLeft GT 0>
				is only <font color="red"><B>#CustDeadlineDaysLeft#</B></font> day(s) away.
			<cfelse>
				was <font color="red"><B>#Abs(CustDeadlineDaysLeft)#</B></font> day(s) back.
			</cfif>
			<br>
		</cfif>
		<cfif SendgoodUntilEmail AND isNumeric(GoodUntilDaysLeft)>
			The first offer good until date is <B>#DateFormat(Good_Until_Date, "mm/dd/yyyy")#</B> which 
			<cfif GoodUntilDaysLeft EQ 0>
				is today.
			<cfelseif  GoodUntilDaysLeft GT 0>
				is only <font color="red"><B>#GoodUntilDaysLeft#</B></font> day(s) away.
			<cfelse>
				was <font color="red"><B>#Abs(GoodUntilDaysLeft)#</B></font> day(s) back.
			</cfif><br>
			The request will get expired 
			<cfif GoodUntilDaysLeft GTE 0>
			on <B>#DateFormat(Good_Until_Date, "mm/dd/yyyy")#</B>
			<cfelse>
			today
			</cfif>
			
		</cfif>
		</cfsavecontent>
		<cfset fromEmail = "NotificationService@#CGI.SERVER_NAME#">
		<cfset subjectEmail = "Futures Pricing Request '#FP_Request_Title#'">
		<!------ <cf_EmailWrapper 
			to="#requestUsersList#" 
			from="#fromEmail#" 
			subject="#subjectEmail#" 
			type="HTML"
			messagetype="1" 
			generatedby="1" 
			apparea="3">
			
			#EmailContents#
			
		</cf_EmailWrapper> ----->
		<cfset fpRequestManager.setMailSent(FP_Request_Master_ID, SendcustDeadlineEmail, SendgoodUntilEmail)>
		To: #requestUsersList#<br>
		From: #fromEmail#<br>
		Subject: #subjectEmail#<br>
		#EmailContents#
		<hr>		
	</cfif>
	<cfif GoodUntilDaysLeft LT 0 AND isNumeric(GoodUntilDaysLeft)>
		<!------ Expire the request ----->
		<cfset fpRequestManager.setExpired(FP_Request_Master_ID, 1)>
		<br><br>Futures Pricing Request <B>'#FP_Request_Title#'</B>: expired<br>
	</cfif>
</cfloop>

<!------ 
if customer deadline is over, exp
or
and the first offer good until date is arriving
----->
</cfoutput>