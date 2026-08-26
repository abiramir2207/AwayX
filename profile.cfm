<!--- 
	Do not use this code in the production environment
	It appears that the creation of the cookie on line 69
	Destroys the cookie that was created when the user
	first log-on.
	Frank
--->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Gets the profile of the current user and creates a WDDX package with it						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Get the Profile settings for the current user --->
<CFQUERY NAME="Get_Profile_Settings" datasource="#application.datasource#">
	Select	_Users.Profiles_ID,
			Profiles_Settings.*
	From	_Users,
			Profiles_Settings
	Where	_Users.User_ID					=	'99AA39FB-33C4-4B3B-93541AB232D1A4F9'
			AND
			Profiles_Settings.Profiles_ID	=	_Users.Profiles_ID
</CFQUERY>

<!--- Create a structure here to hold the variables. --->
<CFSET ProfileStructure=StructNew()>
<!--- Build structure elements with the profile information --->
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Cont_Prog_Approval_Rights'				, Get_Profile_Settings.Cont_Prog_Approval_Rights, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Cont_Prog_Minimum_Lineitem_Margin'		, Get_Profile_Settings.Cont_Prog_Minimum_Lineitem_Margin, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Cont_Prog_Maximum_Lineitem_Margin'		, Get_Profile_Settings.Cont_Prog_Maximum_Lineitem_Margin, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Cont_Prog_View_Margins'					, Get_Profile_Settings.Cont_Prog_View_Margins, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Pay_Bill_Approval_Rights'				, Get_Profile_Settings.Pay_Bill_Approval_Rights, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Pay_Bill_Minimum_Aggregate_Deviation'	, Get_Profile_Settings.Pay_Bill_Minimum_Aggregate_Deviation, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Pay_Bill_Maximum_Aggregate_Deviation'	, Get_Profile_Settings.Pay_Bill_Maximum_Aggregate_Deviation, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Pay_Bill_View_Expected_Rate'			, Get_Profile_Settings.Pay_Bill_View_Expected_Rate, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Pay_Ded_Approval_Rights'				, Get_Profile_Settings.Pay_Ded_Approval_Rights, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Pay_Ded_Minimum_Deduction_Amount'		, Get_Profile_Settings.Pay_Ded_Minimum_Deduction_Amount, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Pay_Ded_Maximum_Deduction_Amount'		, Get_Profile_Settings.Pay_Ded_Maximum_Deduction_Amount, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Pda_Download'							, Get_Profile_Settings.Pda_Download, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Pda_Upload'								, Get_Profile_Settings.Pda_Upload, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Rep_Run_Reports'						, Get_Profile_Settings.Rep_Run_Reports, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Com_Tools_CreateEdit_Pricing_Formula'	, Get_Profile_Settings.Com_Tools_CreateEdit_Pricing_Formula, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Com_Tools_View_Pricing_Formula'			, Get_Profile_Settings.Com_Tools_View_Pricing_Formula, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Com_Tools_View_Market_Data'				, Get_Profile_Settings.Com_Tools_View_Market_Data, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Use_Set_User_Password'					, Get_Profile_Settings.Use_Set_User_Password, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Use_Set_Email_Message'					, Get_Profile_Settings.Use_Set_Email_Message, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Use_Set_Tickler'						, Get_Profile_Settings.Use_Set_Tickler, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Comm_Fax'								, Get_Profile_Settings.Comm_Fax, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Comm_Email'								, Get_Profile_Settings.Comm_Email, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Comm_Print'								, Get_Profile_Settings.Comm_Print, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Admin_Data_Purging'						, Get_Profile_Settings.Admin_Data_Purging, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Admin_Data_Exceptions'					, Get_Profile_Settings.Admin_Data_Exceptions, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Admin_Data_Integ_Schedule'				, Get_Profile_Settings.Admin_Data_Integ_Schedule, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Admin_Profile_Maintenance'				, Get_Profile_Settings.Admin_Profile_Maintenance, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Admin_AddDelete_Users'					, Get_Profile_Settings.Admin_AddDelete_Users, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Ctr_Pnl_Programs'						, Get_Profile_Settings.Ctr_Pnl_Programs, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Ctr_Pnl_Payables'						, Get_Profile_Settings.Ctr_Pnl_Payables, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Ctr_Pnl_Commod_Pricing'					, Get_Profile_Settings.Ctr_Pnl_Commod_Pricing, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Admin_Control_Panels'					, Get_Profile_Settings.Admin_Control_Panels, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Commodity_Settings'						, Get_Profile_Settings.Commodity_Settings, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Report_Scheduler'						, Get_Profile_Settings.Report_Scheduler, True)>
<CFSET Variables.Temp = StructInsert(ProfileStructure, 'Geographic_Access'						, Get_Profile_Settings.Geographic_Access, True)>

<!--- Serialize packet --->
<CFWDDX ACTION="CFML2WDDX" INPUT="#ProfileStructure#" OUTPUT="myPacket2">

<!--- Create cookie with contents of the WDDX packet --->
<CFCOOKIE NAME="User_Profile" VALUE="#myPacket2#">

<!--- Deserialize WDDX profile packet that lives in the cookie --->
<CFWDDX ACTION="WDDX2CFML" INPUT="#cookie.User_Profile#" OUTPUT="ProfileStructure">

<CFOUTPUT>#Cookie.User_Profile#</CFOUTPUT>
