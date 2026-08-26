<!------ PM_Copy.cfm ------>
<CFPARAM NAME="URL.RID" 	DEFAULT="">
<CFSET SOURCE_PM_Item_Master_ID = URL.RID>
<CFSET DEST_PM_Item_Master_ID = "">

<CFSET PM_Acct_Project = "Deepas Copy">
<CFSET Copy_Success = False>

<CFIF Len(SOURCE_PM_Item_Master_ID) EQ 36>
<CFTRANSACTION ACTION="BEGIN">
	<CFTRY>
		<CFQUERY NAME="Main_Insert" DATASOURCE="#application.datasource#">
		INSERT INTO PM_Item_Master
		(
			PM_Acct_Project, PM_Priority_ID, PM_Status_ID, PM_Phase_ID,
			PM_Start_Date, PM_End_Date, PM_Value_Pounds, PM_Value_Dollars,
			PM_Far_ID, PM_Sponsor_ID, PM_Resources, PM_Support, PM_Ext_Budget, PM_CER,
			PM_Actual, PM_Created_By_ID, PM_Modified_By_ID
		)
		SELECT	
			CASE 
				WHEN Len(PM_Acct_Project) < 3000 THEN
					'Copy of ' + PM_Acct_Project
				ELSE
					PM_Acct_Project
			END AS PM_Acct_Project				
			, PM_Priority_ID, PM_Status_ID, PM_Phase_ID,
			PM_Start_Date, PM_End_Date, PM_Value_Pounds, PM_Value_Dollars,
			PM_Far_ID, PM_Sponsor_ID, PM_Resources, PM_Support, PM_Ext_Budget, PM_CER,
			PM_Actual, '#request.AccessStructure.User_ID#', '#request.AccessStructure.User_ID#'
		FROM	PM_Item_Master
		WHERE
			PM_Item_Master_ID = '#SOURCE_PM_Item_Master_ID#'
		</CFQUERY>
		
		<CFSET DEST_PM_Item_Master_ID = Main_Insert.PM_Item_Master_ID>
		
		<CFOUTPUT>#Main_Insert.PM_Item_Master_ID#</CFOUTPUT>
		
		<CFQUERY NAME="Insert_Owners" DATASOURCE="#application.datasource#">
		INSERT INTO PM_Owner_Position
				(PM_Item_Master_ID, User_Positions_ID)
		SELECT	'#DEST_PM_Item_Master_ID#', User_Positions_ID
		FROM	PM_Owner_Position
		WHERE
			PM_Item_Master_ID = '#SOURCE_PM_Item_Master_ID#'
	
		</CFQUERY>
		
		<CFQUERY NAME="Insert_TypeGroups" DATASOURCE="#application.datasource#">
		INSERT INTO PM_Qbrands
				(PM_Item_Master_ID, Q_Brand_ID)
		SELECT	'#DEST_PM_Item_Master_ID#', Q_Brand_ID
		FROM	PM_Qbrands
		WHERE
			PM_Item_Master_ID = '#SOURCE_PM_Item_Master_ID#'
		</CFQUERY>
		
		<CFQUERY NAME="Insert_Brokers" DATASOURCE="#application.datasource#">
		INSERT INTO PM_Brokers
				(PM_Item_Master_ID, BSA_Foodservice_Brokers_ID)
		SELECT	'#DEST_PM_Item_Master_ID#', BSA_Foodservice_Brokers_ID
		FROM	PM_Brokers
		WHERE
			PM_Item_Master_ID = '#SOURCE_PM_Item_Master_ID#'
		</CFQUERY>
		
		<CFQUERY NAME="Insert_Distributors" DATASOURCE="#application.datasource#">
		INSERT INTO PM_Distributors
				(PM_Item_Master_ID, BSA_Foodservice_Customers_ID)
		SELECT	'#DEST_PM_Item_Master_ID#', BSA_Foodservice_Customers_ID
		FROM	PM_Distributors
		WHERE
			PM_Item_Master_ID = '#SOURCE_PM_Item_Master_ID#'
		</CFQUERY>
		
		<CFQUERY NAME="Insert_Operators" DATASOURCE="#application.datasource#">
		INSERT INTO PM_Operators
				(PM_Item_Master_ID, BSA_Operator_ID)
		SELECT	'#DEST_PM_Item_Master_ID#', BSA_Operator_ID
		FROM	PM_Operators
		WHERE
			PM_Item_Master_ID = '#SOURCE_PM_Item_Master_ID#'
		</CFQUERY>
		
		<CFQUERY NAME="Insert_Programs" DATASOURCE="#application.datasource#">
		INSERT INTO PM_Programs
				(PM_Item_Master_ID, PM_Contract_Number)
		SELECT	'#DEST_PM_Item_Master_ID#', PM_Contract_Number
		FROM	PM_Programs
		WHERE
			PM_Item_Master_ID = '#SOURCE_PM_Item_Master_ID#'
		</CFQUERY>
		
		<CFQUERY NAME="Insert_Attachments" DATASOURCE="#application.datasource#">
		INSERT INTO Contract_Attachments
				(Project_ID, Doc_ID)
		SELECT	'#DEST_PM_Item_Master_ID#', Doc_ID
		FROM	Contract_Attachments
		WHERE
			Project_ID = '#SOURCE_PM_Item_Master_ID#'
			AND
			Deleted = 0
	
		</CFQUERY>
		<CFTRANSACTION ACTION="COMMIT">
		<CFSET Copy_Success = True>
		<CFCATCH>
			<CFTRANSACTION ACTION="ROLLBACK">
			<CFRETHROW>
		</CFCATCH>
	</CFTRY>	
</CFTRANSACTION>
</CFIF>
<CFIF Copy_Success AND DEST_PM_Item_Master_ID NEQ "">
	<CFPARAM NAME="URL.FID" 	DEFAULT="">
	<CFLOCATION ADDTOKEN="No" URL="PM_Lock.cfm?LOCK_RID=#DEST_PM_Item_Master_ID#&FID=#URL.FID#">
<CFELSE>
	<CFLOCATION ADDTOKEN="No" URL="#CGI.HTTP_REFERER#">
</CFIF>