<!--- bbtest.cfm --->
<!--- 1 --->
<!--- c:\users\kvangapalli\work\awayx\billbacks\approval\payment.cfm --->
<!--- <cfinclude template   = "/billbacks/approval/payment_confirmation.cfm?bbid=f02f2d9c-f3e7-4fb0-b2b8-49058efd665a" > --->

<!--- 2 --->
<!--- bb-1480427-00 --->
<!--- <cfparam name = "url.billback_id" default="f02f2d9c-f3e7-4fb0-b2b8-49058efd665a" />
<cfquery name  = "getforminfo" datasource="#application.datasource#">
	select billback_payee_type_id, billback_status_id, bb_amount, totaltaxamount, scheduled_auto_bb, bb_amount
	from billback
where billback_id  = <cfqueryparam value="#billback_id#" cfsqltype="cf_sql_varchar">
</cfquery>

<cfset form.adjustment_created    = 0 >
<cfset form.approvedtotal         = getforminfo.bb_amount>
<cfset form.billback_amount_total = getforminfo.bb_amount />
<cfset form.billback_amount_total = getforminfo.bb_amount>
<cfset form.billback_id           = url.billback_id />
<cfset form.e_amount_total        = getforminfo.bb_amount />
<cfset form.payment_amount        = getforminfo.bb_amount />
<cfset form.rate_paid_type        = "a" />
<cfset form.scheduled_auto_bb     = getforminfo.scheduled_auto_bb>
<cfinclude template               = "/billbacks/approval/payment_confirmation.cfm" > --->

<!--- 3 --->
<!--- 2A551B03-23F8-42C6-8644-C41DF9BCE831	BB-1000205-00 --->
<cfset url.BBID="4B56F201-50FD-4836-ADDE-C66B9CE278FE" />
<cfset url.type="BB" />
<cfset request.ACCESSSTRUCTURE.USER_ID ="786AF903-C27E-B5CF-20BC4AE2F89EA421" />
<cfparam name="request.AccessStructure.Profiles_ID"  default="35" />
<cfinclude template="/get_access_profile.cfm">

<cfinclude template   = "/billbacks/scorecard/ajax/pay_claimed_expected.cfm" >

