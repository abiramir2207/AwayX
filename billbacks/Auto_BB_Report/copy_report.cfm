<!--- Spinner goes here --->
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<CFFLUSH>




<!--- Get rid of spinner --->
<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>