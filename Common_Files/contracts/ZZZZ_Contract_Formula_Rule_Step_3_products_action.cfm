<CFOUTPUT>
	<FORM ACTION="Contract_Formula_Rule_Step_3.cfm?CID=#URL.CID#&RID=#URL.RID#" METHOD="post" NAME="MyForm" ID="MyForm">
		<INPUT TYPE="Hidden" NAME="Sort_By" VALUE="#Form.Sort_By#">
		<INPUT TYPE="hidden" NAME="Newly_Selected_Products" ID="Newly_Selected_Products" VALUE="#FORM.Product_List#">
		<INPUT TYPE="Hidden" NAME="Update" VALUE="#Form.Update#">
	</FORM>
</CFOUTPUT>

<script>
	document.MyForm.submit();
</script>