<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Save to database the settings from the prior screen											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFIF Form.up_sv EQ 0>
	<CFQUERY NAME="Insert_Data" datasource="#application.datasource#">
		INSERT INTO _Users_Settings
			(
				Prefered_UOM, 
				Prefered_UOM_Date_Updated,
				user_id
			)
		VALUES
			(
				#Prefered_UOM#, 
				#Date_Updated#,
				'#request.AccessStructure.User_ID#'
			)
	</CFQUERY>
<CFELSE>
	<CFQUERY NAME="Update_Data" datasource="#application.datasource#">
		Update 	_Users_Settings
		Set		Prefered_UOM				= 		#Prefered_UOM#,
				Prefered_UOM_Date_Updated	=		#Date_Updated#
		Where	user_id 					=		'#request.AccessStructure.User_ID#'
	</CFQUERY>
</CFIF>




<CFLOCATION URL="preferences_form.cfm?ID=#createuuid()#" ADDTOKEN="No">






