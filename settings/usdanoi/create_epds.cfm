<cfparam name="form.DeleteRecord" default="0">
<cfparam name="form.usdanoi_enabled" default="">

<cfif len(trim(form.usdanoi_enabled)) NEQ 0>
	<cfset theBit = 0>
	<cfif form.usdanoi_enabled EQ true>
		<cfset theBit = 1>
	</cfif>

	<CFQUERY NAME="update_application_usdanoi_status" datasource="#application.datasource#">
		UPDATE _Application_Settings
		SET usdanoi_enabled = #theBit#
	</CFQUERY>
	<cfquery name="LastEditedBy" datasource="#application.datasource#">
		UPDATE Global_Last_Edited_By
		SET 
			user_id = '#request.AccessStructure.user_id#',
			DateTimeStamp = #createodbcdatetime(now())#
		WHERE Global_Last_Edited_By_ID = 1
	</cfquery>
	
	
	<!--- update components table --->
	<cfquery name="chk4USDAComp" datasource="#application.datasource#">
		SELECT *
		FROM Program_Rebates_Component_Name
		WHERE Is_USDA_NOI_Comp = 1
	</cfquery>
			
	<cfif theBit EQ 1><!--- enabled --->
		<cfif chk4USDAComp.recordcount GT 0>
			<cfquery name="Activate" datasource="#application.datasource#">
				UPDATE Program_Rebates_Component_Name
				SET Donot_Delete = 1, Active = 1, Deleted = 0
				WHERE Program_Rebates_Component_Name_ID = '#chk4USDAComp.Program_Rebates_Component_Name_ID#'
			</cfquery>		
		<cfelse>
			<cfquery name="ActivateViaINSERT" datasource="#application.datasource#">
				INSERT INTO Program_Rebates_Component_Name
				(Program_Rebates_Component_Name,Is_USDA_NOI_Comp,Donot_Delete)
				VALUES
				('USDA NOI', 1,1)
			</cfquery>		
		</cfif>
	<cfelse><!--- disabled --->
			<cfquery name="MakeDeleteable" datasource="#application.datasource#">
				UPDATE Program_Rebates_Component_Name
				SET Donot_Delete = 0, Active = 0
				WHERE Program_Rebates_Component_Name_ID = '#chk4USDAComp.Program_Rebates_Component_Name_ID#'
			</cfquery>	

			<cfquery name="Delete" datasource="#application.datasource#">
				UPDATE Program_Rebates_Component_Name
				SET Deleted = 1
				WHERE Program_Rebates_Component_Name_ID = '#chk4USDAComp.Program_Rebates_Component_Name_ID#'
			</cfquery>
	</cfif>
	
	<CFLOCATION URL="index.cfm" ADDTOKEN="No">
	<CFABORT>	
</cfif>

<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
		DELETE FROM usda_noi_epds  
		WHERE		usda_noi_epds_ID			=	'#Form.usda_noi_epds_id#'
	
		UPDATE usda_noi_epds_type
		SET Deleted = 1
		WHERE usda_noi_epds_ID = '#Form.usda_noi_epds_id#'
	</CFQUERY>
	
	<CFLOCATION URL="index.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Item save data logic --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- Check for the presence of data --->
<CFIF trim(Form.Name) EQ "" OR trim(Form.Name) EQ 0>
	<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 0000);</SCRIPT> 
	<CFABORT>
</CFIF>

<CFIF Form.usda_noi_epds_id EQ "">
<!--- Insert the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO		usda_noi_epds
						(
							Name,
							Yield,
							raw_price,
							uom,
							Notes
						)
		Values			(
							'#Form.Name#',
							'#Form.Yield#',
							'#Form.raw_price#',
							'#Form.uom#',
							'#Form.Notes#'
						)
		
	</CFQUERY>

	<cfquery name="LastEditedBy" datasource="#application.datasource#">
		UPDATE Global_Last_Edited_By
		SET 
			user_id = '#request.AccessStructure.user_id#',
			DateTimeStamp = #createodbcdatetime(now())#
		WHERE Global_Last_Edited_By_ID = 1
	</cfquery>	

	<CFLOCATION URL="index.cfm" ADDTOKEN="No">
	<CFABORT>
<CFELSE>
<!--- Update the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		usda_noi_epds
		SET 		Name 			=	'#Form.Name#',
					Yield			=	'#Form.Yield#',
					Raw_Price		=	'#Form.Raw_Price#',
					uom   			=   '#Form.uom#',
					Notes			=	'#Form.Notes#'
		WHERE		usda_noi_epds_id	=	'#Form.usda_noi_epds_ID#'
	</CFQUERY>
	
	<cfquery name="LastEditedBy" datasource="#application.datasource#">
		UPDATE Global_Last_Edited_By
		SET 
			user_id = '#request.AccessStructure.user_id#',
			DateTimeStamp = #createodbcdatetime(now())#
		WHERE Global_Last_Edited_By_ID = 1
	</cfquery>
		
	<CFLOCATION URL="index.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>



