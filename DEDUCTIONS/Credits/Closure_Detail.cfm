<!------ Closure_Detail.cfm ----->
<cfparam name="URL.Deduction_ID" 	default="">
<CFIF Len(URL.Deduction_ID) GT 0>
<cfset DeductionManager = CreateObject("component", "components.deduction.DeductionManager").init() /> 
<cfset AssociatedCredit = DeductionManager.getAssociatedCredits(Deduction_ID) />
<cfset qGetCurrentDeduction = DeductionManager.getDeduction(Deduction_ID) />
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Deduction - Associated Credits</title>
	<script language="JavaScript">
	function GotoDeduction(thisObj)
	{
		var sHref = thisObj.href;
		if(window.opener)
		{
			if(window.opener.parent)
			{
				window.opener.parent.location.href = sHref;
				window.close();
			}
		}
		return false;
	}
	</script>
</head>

<body>
<cfoutput>
<TABLE border="0" cellpadding="2" cellspacing="0" align="center">
<caption style="font-size:14px;font-weight:bold;">Associated Credits to Deduction [#qGetCurrentDeduction.DD_DedID_SP_Number#]<br>&nbsp;</caption>
<TR>
	<CFSET count = 0>
	<CFLOOP QUERY="AssociatedCredit">	
		<CFSET Count = Count + 1>		
		<CFIF Count LT 4>			
		<CFELSE>
			<CFSET Count = 1>
			</TR>
			<TR>			
		</CFIF>	
			<TD STYLE = "Border: solid C6FFC6 1px"><A Href="/deductions/deduction.cfm?deduction_ID=#AssociatedCredit.Deduction_ID#" OnClick="javascript: return GotoDeduction(this);"><B><B>#DD_DedID_SP_Number#</B></B></A>
			<BR>#DOLLARFORMAT(DD_Amount)# / REF: #DD_REFERENCE#</TD>
	</CFLOOP>
</TR>
</TABLE>
</cfoutput>
</body>
</html>
</CFIF>