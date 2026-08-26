<!------
get_Contact_Admin_Email_Address.cfm
----->
<!--- <CFSET Contact_Admin_Email_Address = "">
<CFQUERY NAME="get_Contact_Admin_Email_Address" datasource="#application.datasource#">
	SELECT 	User_Email, Name_First, Name_Last, Work_Phone_1, Work_Phone_2, Work_Phone_3, Work_Phone_Ext, Company_Main.Company_Name
	FROM 	_Users
			INNER JOIN
            Company_Main ON _Users.Company_Main_ID = Company_Main.Company_Main_ID
	WHERE Contact_Administrator = <cfqueryparam value="1" cfsqltype="CF_SQL_INTEGER">
</CFQUERY>
<CFIF get_Contact_Admin_Email_Address.recordCount GT 0>
	<CFSET Contact_Admin_Email_Address = get_Contact_Admin_Email_Address.User_Email>
<CFELSE>
	<CFQUERY NAME="get_Contact_Admin_Email_Address" datasource="#application.datasource#">
		SELECT 	User_Email, Name_First, Name_Last, Work_Phone_1, Work_Phone_2, Work_Phone_3, Work_Phone_Ext, Company_Main.Company_Name
		FROm 	_Users
				INNER JOIN
            	Company_Main ON _Users.Company_Main_ID = Company_Main.Company_Main_ID
		WHERE Is_System_Administrator = <cfqueryparam value="1" cfsqltype="CF_SQL_INTEGER">
	</CFQUERY>
	<CFIF get_Contact_Admin_Email_Address.recordCount GT 0>
		<CFSET Contact_Admin_Email_Address = get_Contact_Admin_Email_Address.User_Email>
	</CFIF>
</CFIF> --->
<CFSET Contact_Admin_Email_Address = "#application.oApplicationAppSettingsManager.getApplicationAppSettings().getDifferent_From_Address()#">