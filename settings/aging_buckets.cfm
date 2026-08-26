<BODY BGCOLOR="Whitesmoke">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=32>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BR><BR>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFSET helpfilenumber=25>
<CFINCLUDE TEMPLATE="/help_files/help_link.cfm">
 ---><!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<script>
	function userWantsToSave(){
		document.all.theForm.submit();
	}

</script>

<cfset useLakebaseForgetBuckets = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_aging_buckets")>
<cfif useLakebaseForgetBuckets>
	<cftry>
		<cfset getBuckets = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deduction_aging_buckets", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetBuckets = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetBuckets>
<cfquery name="getBuckets" datasource="#application.datasource#">
	SELECT *
	FROM Deduction_Aging_Buckets
</cfquery>
</cfif>

<CFIF getBuckets.recordcount EQ 0>

<CFELSE>
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated on <CFOUTPUT>#dateformat(getBuckets.Last_Updated, 'm/d/yyy')# #timeformat(getBuckets.Last_Updated, 'h:mm:ss TT')#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
	<BR>
</CFIF>
<br>
<B>
Enter Labels And Ranges For The Deduction Aging
</B>
<BR><BR>
<form action="aging_buckets_action.cfm" method="post" name="theForm" id="theForm">

<style type="text/css">
		body, table, td
		{font-family: Arial; font-size: 12px;}
		.data
		{font-size: 12px; font-weight: bold}
		select, TEXTAREA
		{width:	200px;font-size: 10px;}
		TEXTAREA
		{width:	400px;font-size: 10px;}

		TABLE.Maintable TD
		{border-bottom:solid #93BEE2 1px; font-size : 10px;}

		Maintable
		{cellspacing: 0;}

		header
		{font-size: 12px;}
		
		.inputBox {
			width = 30px;
		}
</style>


<table CLASS="Maintable" border="0" cellspacing="0" cellpadding="1" width="300">
	<TR VALIGN="bottom" BGCOLOR="FFCE84">
		<TD id="header">&nbsp;</TD>
		<TD id="header"><b>Bucket Label</b></TD>
		<TD id="header"><b>Start</b></TD>
		<TD id="header"><b>End</b></TD>
	</TR>
	<cfoutput query="getBuckets">
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			<TD>Age Bucket #currentrow#:</TD>
			<TD><input name="Bucket_#currentrow#_Label" value="#Bucket_Label#" type="Text"></TD>
			<TD><input name="Bucket_#currentrow#_Start" value="#Start_Range#" type="Text" class="inputBox"></TD>
			<TD><input name="Bucket_#currentrow#_End" value="#End_Range#" type="Text" class="inputBox"></TD>
		</TR>
	</cfoutput>
	
	<cfoutput>
	<cfloop index="LoopCount" from="#evaluate("#getBuckets.recordcount#+1")#" to="5" step="1">
		<TR BGCOLOR="#IIf(LoopCount Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			<TD>Age Bucket #LoopCount#:</TD>
			<TD><input name="Bucket_#LoopCount#_Label" type="Text"></TD>
			<TD><input name="Bucket_#LoopCount#_Start" type="Text" class="inputBox"></TD>
			<TD><input name="Bucket_#LoopCount#_End" type="Text" class="inputBox"></TD>
		</TR>
	</cfloop>
	</cfoutput>
</table>
</form>
<input type="Button" value="save" onclick="userWantsToSave()">


</BODY>
