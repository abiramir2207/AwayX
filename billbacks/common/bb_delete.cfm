<!------
bb_delete.cfm
----->
<cfparam name="IsAutoBB" default="0">

<cfset variables.Action = "Delete" />


<script>
/* Do not let the user click on the "Delete" link twice. */
if(parent.document.all.delete_tab){
parent.document.all.delete_tab.disabled = true;
}
</script>

<cfinclude template="Delete_Reset.cfm">