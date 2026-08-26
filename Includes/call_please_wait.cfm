<!------ /includes/call_please_wait.cfm ----->
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
	<br><br><br>
	<center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
	<br><br><br>
</SPAN>
<CFFLUSH>
<SCRIPT>
	document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>