<!--
  * ==================================================================================================== 
  *  @Author: Chris Nguyen
  *    @Date: 2018-04-30 13:25:01
  * 
  * @Remarks: Retrieve custom labels for deduction account & payment account. They are displayed on:  
  *
  *				Fixed component setting (edit)
  * 			Rebate component setting (edit)
  *  
  *             general_labels[ deduction_account ] = the text label for deduction account
  *             general_labels[ payment_account ]   = the text label for payment account
  *
  * ==================================================================================================== 
-->
<cfscript>
	// general labels defined in settings - these constants are referenced in the parent .cfm file
	deduction_account = "Deduction Account";
	payment_account   = "Payment Account";
	delivery_period   = "Delivery Period";

	// pull custom labels for the above - if they are defined in settings use them otherwise use the above 
	general_labels    = application.util.query.generalLabel( deduction_account 
																& "," & payment_account
																& "," & delivery_period
															);
</cfscript>
