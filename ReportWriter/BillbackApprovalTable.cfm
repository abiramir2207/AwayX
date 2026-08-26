<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
	<title>Billback Approval Table</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
		<br><br><br>
		<center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
		<br><br><br>
		<cfflush>
	</SPAN>
	<link href="/Common_Files/main_style.css" media="screen" rel="stylesheet" type="text/css">
</head>
<body leftmargin="0" rightmargin="0" topmargin="0" bottommargin="0">
<cfparam name="Form.Sort_By" 		default="BB_Code">
<cfparam name="Form.Sort_Order" 	default="ASC">
<cfparam name="Form.approvalForm" 	default="0">
<SCRIPT LANGUAGE="JavaScript">
	document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>
<cfif isDefined("url") and Not StructIsEmpty(url)>
	<cfloop collection="#url#" item="thisItem">
		<cfset "form.#thisItem#" = evaluate("url.#thisItem#") />
	</cfloop>
</cfif>
<form name="frmBillbackApproval" id="frmBillbackApproval" action="BillbackApprovalTable.cfm" method="post">
	<cfset MAXLEN = 36 />
	<cfset thisReportName = "billbackApproval" />
	<CFSET billbackMan = CreateObject("component", "components.billback.BillbackManager").init(thisReportName) />  
	<cfset formName = "frmBillbackApproval">
 <table border="0" cellpadding="2" cellspacing="1" CLASS="Maintable" bordercolor="111111" width="100%" id="AutoNumber1"> 
 	<tr BGCOLOR="FFE083">			
	  <cfoutput>
			<CF_Sort_Column_Headers
				formName  = "#formName#"
				sortByFieldName = "sort_by"
				sortOrderFieldName = "sort_order"
				currentSortBy = "#form.sort_by#"
				currentSortOrder = "#form.sort_order#"
				sortByList = "#billbackMan.getReportHeaderSortByList()#"
			>
		</cfoutput>
	  </tr>
	  <cfset rnQry = billbackMan.getBillbackApprovalResultSet(form) />
	 <cfoutput query="rnQry" group="UserID">
		  <tr>
			<td colspan="9" bgcolor="cococo" height="19"><font color="000000" size="2" face="Courier"><strong>Approved By:&nbsp; #UserID#</font></strong></td>
		  </tr>
		  <cfset qryGetGroupItems = billbackMan.GetGroupItems(rnQry,UserID)/>
		  <cfloop query="qryGetGroupItems">
		  <tr>
			<cfloop list="#billbackMan.getReportHeadersAttributes()#" index="thisAttribute">
				<td height="19" nowrap bordercolor="FFFFFF" title="#evaluate(thisAttribute)#">
					<cfif isDate(evaluate(thisAttribute))>
						#DateFormat(evaluate(thisAttribute), "mm-dd-yyyy")#
					<cfelseif IsNumeric(evaluate(thisAttribute))>
						<cfif evaluate(thisAttribute) lt 0><font color="red"></cfif>$#trim(NumberFormat(evaluate(thisAttribute),'_________.__'))#<cfif evaluate(thisAttribute) lt 0></font></cfif>
					<cfelse>
						<cfif len(evaluate(thisAttribute)) gt MAXLEN>
							#Left(evaluate(thisAttribute), MAXLEN)#
						<cfelse>
							#evaluate(thisAttribute)#
						</cfif>
					</cfif>
				</td>
			</cfloop>
		  </tr>
		  </cfloop>
	  </cfoutput>
	</table>
	<cfoutput>
	<INPUT TYPE="HIDDEN" ID="sort_by" NAME="sort_by" VALUE="#Form.Sort_By#">
	<INPUT TYPE="HIDDEN" ID="sort_order" NAME="sort_order" VALUE="#Form.Sort_Order#">
	<INPUT TYPE="HIDDEN" ID="approvalForm" NAME="approvalForm" value="#Form.approvalForm#">
	<cfloop collection="#form#" item="thisItem">
		<cfif thisItem neq "sort_by" and thisItem neq "sort_order">
			<INPUT TYPE="HIDDEN" ID="#trim(thisItem)#" NAME="#trim(thisItem)#" value="#evaluate("form.#thisItem#")#">
		</cfif>
	</cfloop>
	</cfoutput>
</form>
</body>
</html>

