<!----------------------------------------------------------------------------------
Name         :  AwayX/Planners/Create/select_customers.cfm
Copyright    :  (c) 2022 Blacksmith Applications, Inc.
Created Date :  23-Feb-2022
Created By   :  Anand Rao
Description  :  Screen for picking alternate indvidual customer inside 
				the planner program
---------------------------------------------------------------------------------->

<html>
<head>
	<title>Select customer group</title>
</head>
<body>
<cfoutput>
	<cflocation URL = "/Common_Files/contracts/select_distributors_programs_popup.cfm?is_group=0&CID=#URL.CID#&plannerID=#URL.plannerID#&bEdit=#URL.bEdit#"/>
</cfoutput>
</body>
</html>
