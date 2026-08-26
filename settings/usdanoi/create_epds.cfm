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
	<cfset useLakebaseForLastEditedBy = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("global_last_edited_by")>
<cfif useLakebaseForLastEditedBy>
	<cftry>
		<cfset application.oLakebase.updateRows("global_last_edited_by",
			{
				"global_last_edited_by_id" = "eq.1"
			},
			{
				"user_id" = "#request.AccessStructure.user_id#",
				"datetimestamp" = "#createodbcdatetime(now())#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForLastEditedBy = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForLastEditedBy>
<cfquery name="LastEditedBy" datasource="#application.datasource#">
		UPDATE Global_Last_Edited_By
		SET 
			user_id = '#request.AccessStructure.user_id#',
			DateTimeStamp = #createodbcdatetime(now())#
		WHERE Global_Last_Edited_By_ID = 1
	</cfquery>
</cfif>
	
	
	<!--- update components table --->
	<cfset useLakebaseForchk4USDAComp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_component_name")>
<cfif useLakebaseForchk4USDAComp>
	<cftry>
		<cfset chk4USDAComp = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_rebates_component_name", {
				"is_usda_noi_comp" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForchk4USDAComp = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForchk4USDAComp>
<cfquery name="chk4USDAComp" datasource="#application.datasource#">
		SELECT *
		FROM Program_Rebates_Component_Name
		WHERE Is_USDA_NOI_Comp = 1
	</cfquery>
</cfif>
			
	<cfif theBit EQ 1><!--- enabled --->
		<cfif chk4USDAComp.recordcount GT 0>
			<cfset useLakebaseForActivate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_component_name")>
<cfif useLakebaseForActivate>
	<cftry>
		<cfset application.oLakebase.updateRows("program_rebates_component_name",
			{
				"program_rebates_component_name_id" = "eq.#chk4USDAComp.Program_Rebates_Component_Name_ID#"
			},
			{
				"donot_delete" = "1",
				"active" = "1",
				"deleted" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForActivate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForActivate>
<cfquery name="Activate" datasource="#application.datasource#">
				UPDATE Program_Rebates_Component_Name
				SET Donot_Delete = 1, Active = 1, Deleted = 0
				WHERE Program_Rebates_Component_Name_ID = '#chk4USDAComp.Program_Rebates_Component_Name_ID#'
			</cfquery>
</cfif>		
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

			<cfset useLakebaseForDelete = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_component_name")>
<cfif useLakebaseForDelete>
	<cftry>
		<cfset application.oLakebase.updateRows("program_rebates_component_name",
			{
				"program_rebates_component_name_id" = "eq.#chk4USDAComp.Program_Rebates_Component_Name_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDelete = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete>
<cfquery name="Delete" datasource="#application.datasource#">
				UPDATE Program_Rebates_Component_Name
				SET Deleted = 1
				WHERE Program_Rebates_Component_Name_ID = '#chk4USDAComp.Program_Rebates_Component_Name_ID#'
			</cfquery>
</cfif>
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
	<cfset useLakebaseForSave_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("usda_noi_epds")>
<cfif useLakebaseForSave_Data>
	<cftry>
		<cfset application.oLakebase.insertRow("usda_noi_epds", {
			"name" = "#Form.Name#",
			"yield" = "#Form.Yield#",
			"raw_price" = "#Form.raw_price#",
			"uom" = "#Form.uom#",
			"notes" = "#Form.Notes#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Data>
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
</cfif>

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



