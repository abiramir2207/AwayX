<!-----

file:			/report_writer/program_claim_rates_report_select_distributor.cfm
called from: 	/report_writer/program_claim_rates_report.cfm

---->
<cfoutput>
<head>
	<title>Program claim rates report - select distributor</title>
	
	<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
	
	<script language="javascript">
		function includeAllDistributorsInReport()
		{
			document.frmSelectDistributor.selectAllDistributors.value = 1;
			document.frmSelectDistributor.submit();
		}
		function includeSeletedDistributorsInReport()
		{
			var chObj = document.frmSelectDistributor.distributorList;
			if(chObj)
			{
				if (Any_Object_Checked(chObj))
				{
					document.frmSelectDistributor.selectAllDistributors.value = 0;
					document.frmSelectDistributor.submit();
				}
				else
				{
					alert("Please select at least one #lcase(application.returned_customer_setting.distributor_label_singular)#");
				}
			}
		}
	</script>
</head>
<body>

<form action="" method="post" name="frmSelectDistributor">

<input type="hidden" name="command" value="generateReport">
<input type="hidden" name="selectAllDistributors" value="0">
<input type="hidden" name="EffectiveDate" value="#form.EffectiveDate#">
<input type="hidden" name="report_type" value="#form.report_type#">
<cfif IsDefined("FORM.report_program_id_list")>
	<input type="hidden" name="report_program_id_list" value="#FORM.report_program_id_list#">
<cfelse>
<!--- This will happen is case the user comes from the LeftNAV link on the program --->
	<input type="hidden" name="report_program_id_list" value="#FORM.Program_ID#">
</cfif>

<span style="font-size:12px;font-weight:bold;">
select the #lcase(application.returned_customer_setting.distributor_label_plural)# that need to be included in the report.
</span>
<br>
<table>
<tr>
	<td>
		<CF_smallLink 
			title = "include selected #lcase(application.returned_customer_setting.distributor_label_plural)#" 
			url = "##"
			parameters = " onClick=""javascript: includeSeletedDistributorsInReport();return false;"""		
		>
	</td>
	<td>
		<CF_smallLink 
			title = "include all #lcase(application.returned_customer_setting.distributor_label_plural)#" 
			url = "##"
			parameters = " onClick=""javascript: includeAllDistributorsInReport();return false;"""		
		>
	</td>
</tr>
</table>

<table cellpadding="0" cellspacing="2">	
<tr valign="top" bgcolor="F2F2F2">

	
<CFLOOP QUERY="getDistributors">
	<!---handle what gets passed to the distributor profile popup based on groups--->
	<td width="1%"><input type="checkbox" value="#BSA_Foodservice_Customers_ID#" name="distributorList"
	<cfif getDistributors.recordcount eq 1>checked</cfif>></td>
	<TD WIDTH="33%" VALIGN="top">
		<FONT SIZE="1">
		#ucase(trim(getDistributors.Name))#<cfif Len(Shr_Ship_To)><br>(#Shr_Ship_To#)</cfif>
		</font>
	</TD>
	<CFIF getDistributors.CURRENTROW MOD 3><CFELSE></tr><tr bgcolor="F2F2F2" valign="top"></CFIF>
</CFLOOP>
</tr>
</table>
</form>

</body>
</cfoutput>