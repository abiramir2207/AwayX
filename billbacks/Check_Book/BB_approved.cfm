<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<!--- <cfset key= hash("abcdefgh")>
<cfset form.Debit_Account_No ="33780965">
<CFOUTPUT>#form.Debit_Account_No#</CFOUTPUT><br>  

<cf_cryp type="en" key="#request.key#" string="#form.Debit_Account_No#">
<CFSET form.Debit_Account_No = cryp.value>
 <CFOUTPUT>#form.Debit_Account_No#</CFOUTPUT>  --->



<!--- <cfset p_key= hash("abcdefgh")>
<cfset password ="33780965">
<CFOUTPUT>#password#</CFOUTPUT><br> 

<cf_cryp type="en" key="#p_key#" string="#password#">
<CFSET en_password = cryp.value>
<CFOUTPUT>#en_password#</CFOUTPUT>
<BR>
<cf_cryp type="de" key="#p_key#" string="#en_password#">
<CFSET de_password = cryp.value>
<CFOUTPUT>#de_password#</CFOUTPUT>
<BR> 
 --->

<!--- <cf_cryp type="en" key="#request.key#" string="#password#">
<CFSET en_password = cryp.value>
<CFOUTPUT>#en_password#</CFOUTPUT>
 ---><BR>




<cfset useLakebaseForApproval = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_approved")>
<cfif useLakebaseForApproval>
	<cftry>
		<cfset Approval = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_approved", {
				"select" = "billback_id"
			}), "billback_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForApproval = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForApproval>
<CFQUERY name = "Approval" datasource="awayx">
	SELECT BillBack_ID from bb_approved
</CFQUERY>
</cfif>


	
<CFFORM Action = "trans_create1.cfm" method = "post">
Select Billback ID :
<CFSELECT name = "billback_id" display="Billback_ID" query = "approval" value="billback_ID"></CFSELECT>
<BR><BR><BR>
<input type = "hidden" name = "new_bb_check" value = "1">
<input type = "submit" value = "Approved">
</CFFORM>
</body>
</html>
