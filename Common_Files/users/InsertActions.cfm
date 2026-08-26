<CFSWITCH EXPRESSION="#Form.Document_ID#">
	
	<CFCASE VALUE="UserGeneralInfo">
		
		<CFSET IDGENERATOR_GENERATEDIDVARIABLENAME = "Generated.Users_ID"> 
		<CFPARAM NAME="IDGENERATOR_DESTINATIONTABLE" DEFAULT="_Users"> 
		<CFPARAM NAME="IDGENERATOR_DESTINATIONFIELD" DEFAULT="User_ID"> 
		<CFINCLUDE TEMPLATE="../keyGenerator.cfm">

		<CFQUERY NAME="CreateUser" datasource="#application.datasource#" DBTYPE="ODBC">
			INSERT INTO _Users
			(
				User_ID,
				Name_First,
				Name_Last,
				Title,
				Work_Address_1,
				Work_Address_2,
				Work_City,
				Work_State,
				Work_Zip,
				Work_Phone,
				Company_Main_ID,
				Access_Level,
				User_Email,
				User_Rights_ID
			)
			VALUES
			(
				'#Generated.Users_ID#',
				'#Form.User_Name_First#',
				'#Form.User_Name_Last#',
				'#Form.User_Title#',
				'#Form.User_Work_Address_1#',
				'#Form.User_Work_Address_2#',
				'#Form.User_Work_City#',
				'#Form.User_Work_State#',
				'#Form.User_Work_Zip#',
				'(#Form.User_Work_Phone_1#)#Form.User_Work_Phone_2##Form.User_Work_Phone_3#',
				'#Form.Company_Main_ID#',
				'R',
				'#FORM.emailaddress#',
				'#FORM.User_Rights_ID#'
			)
		</CFQUERY>
		
		<CFLOCATION URL="user_login_info.cfm?User_ID=#Generated.Users_ID#" ADDTOKEN="No">		
	</CFCASE>

</CFSWITCH>