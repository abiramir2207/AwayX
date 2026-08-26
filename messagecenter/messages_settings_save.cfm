
<!--- ----------------------------------------------------------------------------------------- --->
<!--- check that all fields have only whole numbers and no other characters --->
<!--- ----------------------------------------------------------------------------------------- --->

<cfif 
	(isvalid("integer", form.products_new_item_display ) NEQ true) 			or 	(form.products_new_item_display LTE 0) or
	(isvalid("integer", form.programs_too_long_rfa_value ) NEQ true) 		or 	(form.programs_too_long_rfa_value LTE 0) or
	(isvalid("integer", form.programs_too_long_rfa_display ) NEQ true) 		or 	(form.programs_too_long_rfa_display LTE 0) or
	(isvalid("integer", form.programs_backdated_value ) NEQ true) 			or 	(form.programs_backdated_value LTE 0) or
	(isvalid("integer", form.programs_backdated_value_display ) NEQ true) 	or 	(form.programs_backdated_value_display LTE 0) or
	(isvalid("integer", form.programs_reassigned_display ) NEQ true) 		or 	(form.programs_reassigned_display LTE 0) or
	(isvalid("integer", form.customers_inactive_display ) NEQ true) 		or	(form.customers_inactive_display LTE 0)
	>

<table class="notifi">
	<tr>
		<td class="notifi" style="text-align:center; padding:200px 0px 200px 0px">
			<center>Please enter only, greater than zero, whole days as values.</center>
		</td>
	</tr>
</table>

<script>
	setTimeout("window.history.back()",4000); // 3 second delay
</script>

<cfabort>

</cfif>






<!--- ----------------------------------------------------------------------------------------- --->
<!--- begining of content --->
<!--- ----------------------------------------------------------------------------------------- --->
<div class="content">

<cfparam name="show_all" 						default="0" >

<cfparam name="programs" 						default="0" >

<cfparam name="programs_too_long_rfa" 			default="0" >
<cfparam name="programs_too_long_rfa_value" 	default="0" >
<cfparam name="programs_too_long_rfa_display" 	default="0" >

<cfparam name="programs_backdated" 				default="0" >
<cfparam name="programs_backdated_value" 		default="0" >
<cfparam name="programs_backdated_value_display"default="0" >

<cfparam name="programs_reassigned" 			default="0" >

<cfparam name="products" 						default="0" >
<cfparam name="products_new_item" 				default="0" >
<cfparam name="products_new_item_display"		default="0" >

<cfparam name="customers" 						default="0" >
<cfparam name="customers_inactive" 				default="0" >
<cfparam name="customers_inactive_value"		default="0" >

<cfparam name="modified_by_user_id" 			default="#user_id#" >
<cfparam name="modified_on_date" 				default="#now()#" >


<!--- ----------------------------------------------------------------------------------------- --->
<!--- save the settings --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="save_settings" datasource="#db_connection#">
	 
UPDATE
		msg_ctr_settings

SET
		show_all						=		#show_all#,

		products						=		#products#,

		products_new_item				=		#products_new_item#,
		products_new_item_display		=		#products_new_item_display#,

		programs						=		#programs#,

		programs_too_long_rfa			=		#programs_too_long#,
		programs_too_long_rfa_value		=		#programs_too_long_rfa_value#,
		programs_too_long_rfa_display	=		#programs_too_long_rfa_display#,

		programs_backdated				=		#programs_backdated#,
		programs_backdated_value		=		#programs_backdated_value#,
		programs_backdated_value_display=		#programs_backdated_value_display#,

		programs_reassigned				=		#programs_reassigned#,
		programs_reassigned_display		=		#programs_reassigned_display#,
		
		customers						=		#customers#,
		customers_inactive				=		#customers_inactive#,
		customers_inactive_display		=		#customers_inactive_display#,

		modified_by_user_id				=		'#user_id#',
		modified_on_date				=		#CreateODBCDate(modified_on_date)#

</cfquery>


<table class="notifi">
	<tr>
		<td class="notifi" style="text-align:center; padding:200px 0px 200px 0px">
			<center>one moment please</center>
		</td>
	</tr>
</table>

 <script language="javascript" type="text/javascript">
	 setTimeout("window.location.href = 'index.cfm?id=83607-86672-50948-17728';", 1000);
 </script>







</div>