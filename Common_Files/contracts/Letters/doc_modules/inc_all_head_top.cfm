<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/inc_all_head_top.cfm
CREATED: 		12/19/2007 - RBL
EDITED:			02/15/2008 - RBL

FUNCTIONALITY:
- This include template generates the top most code for the HTML version ONLY of the Deal Letters v2...
ACTION: Q - the cfoutput may actually be needed in this particular include, leave.
--->

<!--- These parameters are required for this template to process correctly --->
<!--- na --->
</cfsilent>

<cfsetting showdebugoutput="no">
<!DOCTYPE HTML PUBLIC "-//W3C//Dtd HTML 4.01 Transitional//EN">
<html>
<head>
<title><cfoutput>#application.appsettingsget.letterssubject# #application.returned_customer_setting.operator_label_singular# Program-#application.returned_customer_setting.distributor_label_singular#Details</cfoutput></title>