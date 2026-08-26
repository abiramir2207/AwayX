<CFQUERY NAME="Display_Critical" DATASOURCE="#Application.Datasource#">
	SELECT 		PM_Item_Master.PM_Item_Master_ID,
				PM_Item_Master.PM_Acct_Project,
				PM_Priority.PM_Priority_Description,
				PM_Status.PM_Status_Description,
				PM_Item_Master.PM_Value_Pounds,
				PM_Item_Master.PM_Value_Dollars,
				PM_Sponsor.PM_Sponsor_Name_Last,
				PM_Sponsor.PM_Sponsor_Name_First,
				PM_Item_Master.PM_Date_Modified,
				_Users.Name_First,
				<CFIF isdefined("URL.View_Details")>
				PM_Far.PM_Far_Description,
				PM_Phase.PM_Phase_Description,
				PM_Item_Master.PM_Support,
				PM_Item_Master.PM_Start_Date,
				PM_Item_Master.PM_End_Date,
				PM_Item_Master.PM_Ext_Budget,
				PM_Item_Master.PM_Resources,
				PM_Item_Master.PM_Actual,
				PM_Item_Master.PM_CER,
				</CFIF>
				_Users.Name_Last
			
	FROM 		PM_Priority 
	INNER JOIN PM_Item_Master ON PM_Item_Master.PM_Priority_ID = PM_Priority.PM_Priority_ID 		
	INNER JOIN PM_Status ON PM_Status.PM_Status_ID = PM_Item_Master.PM_Status_ID
	INNER JOIN PM_Sponsor ON PM_Sponsor.PM_Sponsor_ID = PM_Item_Master.PM_Sponsor_ID
	INNER JOIN _Users ON _Users.User_ID = PM_Item_Master.PM_Modified_By_ID
	<CFIF isdefined("URL.View_Details")>
	INNER JOIN PM_Far ON PM_Far.PM_Far_ID = PM_Item_Master.PM_Far_ID
	INNER JOIN PM_Phase ON PM_Phase.PM_Phase_ID = PM_Item_Master.PM_Phase_ID
	</CFIF>
	
	WHERE 	PM_Priority.PM_IsCritical = 1 
		AND PM_Item_Master.PM_Deleted=0 
		AND PM_Priority.PM_Priority_Deleted=0
		AND PM_Status.PM_Status_Deleted=0
		AND PM_Sponsor.PM_Sponsor_Deleted=0
		AND _Users.Deleted=0
	
	ORDER BY PM_Priority_Description,PM_Item_Master.PM_Acct_Project
</CFQUERY>
