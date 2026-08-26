
<form ACTION="index2.cfm?PRID=<CFOUTPUT>#FORM.PRID#</CFOUTPUT>" METHOD="POST" NAME="MyForm">
	<input type="hidden" NAME="aa_rulename" VALUE="<CFOUTPUT>#FORM.rule_name#</CFOUTPUT>">
	<input type="hidden" NAME="Newly_Selected_Products" VALUE="<CFOUTPUT>#FORM.Product_List#</CFOUTPUT>">
	<INPUT TYPE="Hidden" NAME="aa_comm_number" VALUE="<CFOUTPUT>#FORM.aa_comm_number#</CFOUTPUT>">
	<INPUT TYPE="Hidden" NAME="ThisPageFirstTimeLoading" VALUE="FALSE">
</form>

<script>
	document.MyForm.submit();
</script>