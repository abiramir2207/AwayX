<cfsetting enablecfoutputonly="true" showdebugoutput="false">
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cftry>
	<cffile action="uploadall" destination="#Application.Doc_Path#\Data_Files\Uploaded\settings\upload_margin_targets\" nameconflict="overwrite" result="upload_result">
	<cfoutput>#serializeJSON({STATUS=200, MESSAGE='Passed'})#</cfoutput>
	<cfcatch type="any" >
		<cfoutput>#serializeJSON({STATUS=500, MESSAGE="Failed"})#</cfoutput>
	</cfcatch>
</cftry>

<cfsilent>

<cfloop from="1" to="#arrayLen(upload_result)#" index="array_index">

	<cfquery name="qSave" datasource="#application.datasource#">
			SET NOCOUNT ON

			INSERT INTO	Margin_Targets_Upload_Doc_Details(
								Doc_Name,
								Doc_Size,
								Doc_Full_Name,
								Uploaded_By
							)
			VALUES	(
				     '#upload_result[ array_index ].serverFileName#',
				     '#upload_result[ array_index ].fileSize#',
				     '#upload_result[ array_index ].serverFile#',
						'#request.AccessStructure.user_id#'
					)

			SELECT @@Identity AS newId
			SET NOCOUNT OFF
	</cfquery>
	<cfset docId = qSave.newId>

	<cfset uploadedFile = "#Application.Doc_Path#\Data_Files\Uploaded\settings\upload_margin_targets\#upload_result[ array_index ].serverFile#">


	<cfspreadsheet action="read" src="#uploadedFile#" query="data" headerrow="1" excludeHeaderRow ="true">

		<cfset fileProcessed = 1>

		<cfloop query="data">

			<cfset reason = ''>
			<cfset error = 0>

			<!--- DOES ITEM EXIST --->
			<cfquery name="checkItem" datasource="#application.datasource#">
					SELECT 1
					FROM BSA_Foodservice_Items_Master
					WHERE Item = '#data.item#'
					AND Deleted = 0
			</cfquery>

			<cfif ! checkItem.recordcount>
					<cfset reason = reason & 'Item does not exist in system.'>
					<cfset error = 1>
			</cfif>

			<!--- RATE CHECK START--->
			<cfif len(data.Net_Sales_Target_Value) EQ 0 AND len(data.Net_Sales_Floor_Value) EQ 0 AND len(data.GM_Target_Value) EQ 0 AND len(data.GM_Floor_Value) EQ 0>
						<cfset reason = reason & 'Rate Fields cannot be empty.'>
						<cfset error = 1>
			</cfif>

			<cfif len(data.Net_Sales_Target_Value)>

				<cfif ! isNumeric(data.Net_Sales_Target_Value)>
						<cfset reason = 'Net Sales Target not numeric.'>
						<cfset error = 1>
				<cfelseif  len(ListGetAt( ( data.Net_Sales_Target_Value & ".0"), 2, "." )) GT appSettings.get_Setting('Decimal_display_for_LB')>
						<cfset reason = 'Net Sales Target cannot have more than #appSettings.get_Setting('Decimal_display_for_LB')# decimal places.'>
						<cfset error = 1>
				</cfif>


			<cfelse>
				<cfset data.Net_Sales_Target_Value = '0.0'>
			</cfif>

			<cfif len(data.Net_Sales_Floor_Value)>

				<cfif ! isNumeric(data.Net_Sales_Floor_Value)>
						<cfset reason = reason & 'Net Sales Floor not numeric.'>
						<cfset error = 1>				
				<cfelseif len(ListGetAt( ( data.Net_Sales_Floor_Value & ".0"), 2, "." )) GT appSettings.get_Setting('Decimal_display_for_LB')>
						<cfset reason = reason & 'Net Sales Floor cannot have more than #appSettings.get_Setting('Decimal_display_for_LB')# decimal places.'>
						<cfset error = 1>
				</cfif>


			<cfelse>
				<cfset data.Net_Sales_Floor_Value = '0.0'>
			</cfif>

			<cfif len(data.GM_Target_Value)>

			<cfif ! isNumeric(data.GM_Target_Value)>
					<cfset reason = reason & 'GM Target not numeric.'>
					<cfset error = 1>
			<cfelseif len(ListGetAt( ( data.GM_Target_Value & ".0"), 2, "." )) GT appSettings.get_Setting('Decimal_display_for_LB')>
					<cfset reason = reason & 'GM Target price cannot have more than #appSettings.get_Setting('Decimal_display_for_LB')# decimal places.'>
					<cfset error = 1>
			</cfif>

			<cfelse>
				<cfset data.GM_Target_Value = '0.0'>
			</cfif>

		<cfif len(data.GM_Floor_Value)>

			<cfif ! isNumeric(data.GM_Floor_Value)>
					<cfset reason = reason & 'GM Floor price not numeric.'>
					<cfset error = 1>
			<cfelseif len(ListGetAt( ( data.GM_Floor_Value & ".0"), 2, "." )) GT appSettings.get_Setting('Decimal_display_for_LB')>
					<cfset reason = reason & 'GM Floor price cannot have more than #appSettings.get_Setting('Decimal_display_for_LB')# decimal places.'>
					<cfset error = 1>
			</cfif>

			<cfelse>
				<cfset data.GM_Floor_Value = '0.0'>
			</cfif>
			<!--- RATE CHECK END--->

			<!--- DISTRIBUTOR CHANNEL EXIST --->
			<cfset useLakebaseForcheckDC = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("business_segment")>
<cfif useLakebaseForcheckDC>
	<cftry>
		<cfset checkDC = application.oLakebase.toQuery(
			application.oLakebase.selectRows("business_segment", {
				"bs_var_2" = "eq.#data.Distribution_Channel#",
				"deleted" = "eq.0",
				"active" = "eq.1",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheckDC = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheckDC>
<cfquery name="checkDC" datasource="#application.datasource#">
					SELECT 1
					FROM Business_Segment
					WHERE BS_Var_2 = '#data.Distribution_Channel#'
					AND Deleted = 0
					AND Active = 1
			</cfquery>
</cfif>

			<cfif ! checkDC.recordcount>
					<cfset reason = reason & 'Distributor channel is not valid.'>
					<cfset error = 1>
			</cfif>

			<cfif error> <!--- HAVE ERRORS --->

				<cfquery name="insertErrorReason" datasource="#application.datasource#">
					INSERT INTO Margin_Targets_Upload_Doc_Error_Details (doc_id, item, Distribution_Channel, Net_Sales_Target_Value, Net_Sales_Floor_Value, GM_Target_Value, GM_Floor_Value, reason)
					VALUES (#docId#,'#item#', '#Distribution_Channel#', '#Net_Sales_Target_Value#', '#Net_Sales_Floor_Value#', '#GM_Target_Value#', '#GM_Floor_Value#','#reason#')
				</cfquery>

				<cfquery name="updateDocTable" datasource="#application.datasource#">
					UPDATE Margin_Targets_Upload_Doc_Details
					SET Success = 0
					WHERE Doc_ID = #docId#
				</cfquery>

				<cfset fileProcessed = 0>

			<cfelse><!--- NO ERRORS --->

				<cfquery name="updateErrorReason" datasource="#application.datasource#">
					DELETE FROM Margin_Targets_Upload_Doc_Error_Details WHERE doc_id = #docId# AND item = '#item#'
				</cfquery>

			</cfif>


		</cfloop>
<!--- MOVE FILES --->
		<cfif fileProcessed>

				<cfquery name="updateDocTable" datasource="#application.datasource#">
					UPDATE Margin_Targets_Upload_Doc_Details
					SET Success = 1
					WHERE Doc_ID = #docId#
				</cfquery>

			<cfloop query="data">

				<cfif len(data.Net_Sales_Target_Value) EQ 0>
					<cfset data.Net_Sales_Target_Value = '0.0'>
				</cfif>
				<cfif len(data.Net_Sales_Floor_Value) EQ 0>
					<cfset data.Net_Sales_Floor_Value = '0.0'>
				</cfif>
				<cfif len(data.GM_Target_Value) EQ 0>
					<cfset data.GM_Target_Value = '0.0'>
				</cfif>
				<cfif len(data.GM_Floor_Value) EQ 0>
					<cfset data.GM_Floor_Value = '0.0'>
				</cfif>

				<cfquery name="getBSAID" datasource="#application.datasource#">
					SELECT BSA.BSA_Foodservice_Items_Master_ID, BSA.Type_Code_Desc_ID, TCD.Type_Code_Desc, BSA.Type_Group_Desc_ID, TGD.Type_Group_Desc
					FROM BSA_Foodservice_Items_Master BSA
					LEFT JOIN Type_Code_Desc TCD
					ON TCD.Type_Code_Desc_ID = BSA.Type_Code_Desc_ID
					LEFT JOIN Type_Group_Desc TGD
					ON TGD.Type_Group_Desc_ID = BSA.Type_Group_Desc_ID
					WHERE item = '#item#'
				</cfquery>

				<cfset useLakebaseForcheckItemExist = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("margin_targets_upload")>
<cfif useLakebaseForcheckItemExist>
	<cftry>
		<cfset checkItemExist = application.oLakebase.toQuery(
			application.oLakebase.selectRows("margin_targets_upload", {
				"item" = "eq.#item#",
				"bsa_foodservice_items_master_id" = "eq.#getBSAID.BSA_Foodservice_Items_Master_ID#",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheckItemExist = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheckItemExist>
<cfquery name="checkItemExist" datasource="#application.datasource#">
				SELECT 1
				FROM Margin_Targets_Upload
				WHERE item = '#item#'
				AND BSA_Foodservice_Items_Master_ID = '#getBSAID.BSA_Foodservice_Items_Master_ID#'
				</cfquery>
</cfif>

			<cfif checkItemExist.recordcount>
				<cfquery name="updateItem" datasource="#application.datasource#">
				UPDATE Margin_Targets_Upload
				SET Distribution_Channel = '#Distribution_Channel#'
						, Net_Sales_Target_Value = '#Net_Sales_Target_Value#'
						, Net_Sales_Floor_Value =  '#Net_Sales_Floor_Value#'
						, GM_Target_Value = '#GM_Target_Value#'
						, GM_Floor_Value =	 '#GM_Floor_Value#'
						, Updated_by = '#request.AccessStructure.user_id#'
						, Updated_Date = getdate()
				WHERE Item = '#item#'
				AND BSA_Foodservice_Items_Master_ID = '#getBSAID.BSA_Foodservice_Items_Master_ID#'
				</cfquery>
			<cfelse>
					<cfquery name="insertItem" datasource="#application.datasource#">
					INSERT INTO Margin_Targets_Upload(
						BSA_Foodservice_Items_Master_ID
						, item
						, Type_Code_Desc_ID
						, Type_Code_Desc
						, Type_Group_Desc_ID
						, Type_Group_Desc
						, Distribution_Channel
						, Net_Sales_Target_Value
						, Net_Sales_Floor_Value
						, GM_Target_Value
						, GM_Floor_Value, created_by
						)
					VALUES (
						  '#getBSAID.BSA_Foodservice_Items_Master_ID#'
						, '#item#'
						, '#getBSAID.Type_Code_Desc_ID#'
						, '#getBSAID.Type_Code_Desc#'
						, '#getBSAID.Type_Group_Desc_ID#'
						, '#getBSAID.Type_Group_Desc#'
						, '#Distribution_Channel#'
						, '#Net_Sales_Target_Value#'
						, '#Net_Sales_Floor_Value#'
						, '#GM_Target_Value#'
						, '#GM_Floor_Value#'
						, '#request.AccessStructure.user_id#'
						)
				</cfquery>
			</cfif>
		</cfloop>
	</cfif>

</cfloop>
</cfsilent>
