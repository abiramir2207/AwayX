<!------ display_group_no_products.cfm ----->
<cfoutput>
<script language="javascript">
function OpenProductsMessageWindow(ImportCriteria)
{
		<cfif ProductMessages.Message_Settings eq 1>
				winprops = 'height=175,width=250,top=300,left=350,scrollbars=no,resizable=no,toolbar=no,directories=no,location=no,status=no,menubar=no,titlebar=no'
				window.open("/Product_Add_Confirmation_Message.cfm?Program_ID=#PROGRAMID#&Discountype=#Discountype#&ImportCriteria="+ImportCriteria,"ProductMessageWindow",winprops);
		<cfelse>
			submitForm(ImportCriteria);
		</cfif>
}
</script>
<font color="##000066" size="4">The following groups do not have any products associated with it</font> 
<hr color="navy">

<cfloop query="qGetGroupsWithNoProducts">
#Group_level_Desc#<br>
</cfloop>

<br><br>
<CF_smallLink 
	title = "import groups" 
	url = "##"
	parameters = "onClick=""javascript: OpenProductsMessageWindow('import');"""
>

<CF_smallLink 
	title = "change selection" 
	url = "##"
	parameters = "onClick=""javascript: cancelImport();"""
>

<CF_smallLink 
	title = "cancel" 
	url = "##"
	parameters = "onClick=""javascript: window.close();"""
>
<!------ persist the input variables ----->
<cfif groupCombinationOn>
<cfloop query="qGetGroupCombinationDefinitionDetail">		
	<cfparam name="FORM.Group_Combination_Member_#Product_Group_Level_Type#" 	default="">
	<input type="Hidden" name="Group_Combination_Member_#Product_Group_Level_Type#" value="#Evaluate("FORM.Group_Combination_Member_#Product_Group_Level_Type#")#">
</cfloop>
</cfif>
</cfoutput>
