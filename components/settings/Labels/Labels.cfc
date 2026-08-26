<cfcomponent displayname="GeneralLabelTool" output="false" extends="components.Base">

<!--- COMPONENT INITIALIZE --->

<cffunction name="init"
			returntype="components.settings.labels.labels"
			output="false">

	<cfset this.txtFilePath = expandPath("\common_documents\Data_Files\Uploaded\settings\LanguageFiles")>

	<!--- Make sure directory EXISTS --->
	<cfif NOT directoryExists(this.txtFilePath)>
		<cfdirectory action = "create" directory = "#this.txtFilePath#">
		<cfscript>
			this.txtFilePath = expandPath("\common_documents\Data_Files\Uploaded\settings\LanguageFiles");
		</cfscript>
	</cfif>

	<cfset this.dsn = Application.Datasource>

	<cfreturn this />
</cffunction>
<!--- COLUMN LABELS --->

<cffunction name="GetTables"
			access="public"
			returntype="any"
			output="false"
			displayname="GetColNames"
			hint="Gets all the tables in the DB.">

	<cfquery name="getTables" datasource="#this.dsn#">
		SELECT TABLE_NAME
		FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_TYPE = 'BASE TABLE'
			AND TABLE_NAME NOT LIKE '%@%'
			AND TABLE_NAME NOT LIKE '_A%'
			AND TABLE_NAME NOT LIKE '_C%'
			AND TABLE_NAME NOT LIKE '_S%'
			AND TABLE_NAME NOT LIKE '_U%'
			AND TABLE_NAME NOT LIKE 'ZZ%'
			AND TABLE_NAME NOT LIKE '%Z_%'
			AND TABLE_NAME NOT LIKE '%HEINZ%'
			AND TABLE_NAME NOT LIKE '%SIMPLOT%'
			AND TABLE_NAME NOT LIKE '%CONAGRA%'
			AND TABLE_NAME NOT LIKE '%SABERT%'
			AND TABLE_NAME NOT LIKE '%ECKRICH%'
			AND TABLE_NAME NOT LIKE '%FOSTER%'
			AND TABLE_NAME NOT LIKE '%CRUCIBLE%'
			AND TABLE_NAME NOT LIKE '%TEMP%'
			AND TABLE_NAME NOT LIKE '%TMP%'
		ORDER BY TABLE_NAME
	</cfquery>
	<cfreturn getTables>
</cffunction>

<cffunction name="GetColNames"
			access="public"
			returntype="any"
			output="false"
			displayname="GetColNames"
			 hint="Gets the column names.">

	<cfargument name="tblName" required="true" default="" type="string">
	<cfquery name="getColNames" datasource="#this.dsn#">
		SELECT TOP 0 *
		FROM #arguments.tblName#
	</cfquery>
	<cfreturn getColNames>
</cffunction>

<cffunction name="GetColLabels"
			access="public"
			returntype="any"
			output="false"
			displayname="GetColLabels"
			hint="Gets the Labels if they exist.">

	<cfargument name="tblName" required="true" default="" type="string">
	<cfquery name="getLabels" datasource="#this.dsn#">
		SELECT *
		FROM Table_Column_Labels
		WHERE Table_Name = '#arguments.tblName#'
		ORDER BY Sequence
	</cfquery>
	<cfreturn getLabels>
</cffunction>

<cffunction name="modifyColLabels"
			access="public"
			returntype="any"
			output="false"
			displayname="insertLabels"
			hint="Inserts new label names.">

	<cfif FORM.actionEdit EQ 0>
		<cfquery name="Deleteallpriorrecords" datasource="#this.dsn#">
			DELETE FROM Table_Column_Labels
			WHERE Table_Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.tblName#">
		</cfquery>
	</cfif>

	<cfloop from="1" to="#FORM.colCount#" index="i">

		<cfif i LT 10>
			<cfset activeSequence = '000' & i>
		<cfelseif i GTE 10 AND i LT 100>
			<cfset activeSequence = '00' & i>
		<cfelseif i GTE 100 AND i LT 1000>
			<cfset activeSequence = '0' & i>
		<cfelseif i GTE 1000 AND i LT 10000>
			<cfset activeSequence = i>
		</cfif>

		<cfset dbColName = evaluate("#'FORM.'&'dbColName_'&'#activeSequence#'#")>
		<cfset defaultColName = evaluate("#'FORM.'&'defaultColName_'&'#activeSequence#'#")>
		<cfset customColName = evaluate("#'FORM.'&'customColName_'&'#activeSequence#'#")>

		<cfparam name="FORM.active_#activeSequence#" default="0">
			<cfif evaluate("FORM.active_#activeSequence#") NEQ 0>
				<cfset active = 1>
			<cfelse>
				<cfset active = 0>
				<cfset inactiveSequence = '99999'>
			</cfif>


		<cfif FORM.actionEdit EQ 1>
			<cfset ID = evaluate("#'FORM.'&'ID_'&'#activeSequence#'#")>
			<cfquery name="insertLabels" datasource="#this.dsn#">
				UPDATE Table_Column_Labels
				SET Default_Col_Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#defaultColName#">
					,Custom_Col_Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#customColName#">
					,Active = <cfqueryparam cfsqltype="cf_sql_bit" value="#active#">
					<cfif evaluate("FORM.active_#activeSequence#") EQ 0>
						,Sequence = <cfqueryparam cfsqltype="cf_sql_varchar" value="#inactiveSequence#">
					</cfif>
				WHERE Table_Column_Labels_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ID#">
			</cfquery>
		<cfelse>
			<cfquery name="insertLabels" datasource="#this.dsn#">
				INSERT INTO Table_Column_Labels
				(
					Table_Name,
					DB_Col_Name,
					Default_Col_Name,
					Custom_Col_Name,
					Active,
					Sequence,
					Deleted
				)
				VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.tblName#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#dbColName#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#defaultColName#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#customColName#">,
					<cfqueryparam cfsqltype="cf_sql_bit" value="#active#">,
				<cfif evaluate("FORM.active_#activeSequence#") NEQ 0>
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#activeSequence#">,
				<cfelse>
					<cfqueryparam cfsqltype="cf_sql_integer" value="#inactiveSequence#">,
				</cfif>
					<cfqueryparam cfsqltype="cf_sql_bit" value="0">
				)
			</cfquery>
		</cfif>
	</cfloop>

</cffunction>
<!--- END:: COLUMN LABELS --->

<!--- PRICING LEVEL LABELS --->

<cffunction name="GetPricingLevel"
				access="public"
				returntype="query"
				output="false"
				displayname="GetPricingLevel"
				hint="Gets all program summary labels">

		<cfquery name="getPricingLevels" datasource="#this.dsn#">
			SELECT *
			FROM pricing_level
		</cfquery>

		<cfreturn getPricingLevels>

</cffunction>

<cffunction name="ModifyPricingLevels"
				access="public"
				returntype="any"
				output="false"
				displayname="ModifyPricingLevels"
				hint="Updates Pricing_Level table">

	<cfloop from="1" to="#FORM.loopCnt#" index="i">
		<cfif #evaluate('FORM.labelDesc#i#')# NEQ "">
			<cfquery name="editPriceLevel" datasource="#this.dsn#">
				UPDATE Pricing_Level
				SET
					pricing_level_label = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.labelName#i#')#">
					,pricing_level_desc = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.labelDesc#i#')#">
					,pricing_External_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.extId#i#')#">
				WHERE
					pricing_level_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.pricing_level_id#i#')#">
			</cfquery>
		</cfif>
	</cfloop>

</cffunction>
<!--- END:: PRICING LEVEL LABELS --->

<!--- PROGRAM SUMMARY LABELS --->

<cffunction name="GetProgramLabels"
				access="public"
				returntype="query"
				output="false"
				displayname="GetProgramLabels"
				hint="Gets all program summary labels">

	<cfargument name="LabelSetName" required="true" type="string">
	<cfargument name="HideInActive" required="true" type="boolean">

		<cfquery name="getLabels" datasource="#this.dsn#">
			SELECT *
			FROM Program_Summary_Labels a
				<cfif isDefined("arguments.LabelSetName") and arguments.LabelSetName NEQ "">
					INNER JOIN Program_Summary_Label_Sets b ON a.Program_summary_Labels_ID = b.Program_summary_Labels_ID
						AND b.Label_Set_Name = '#arguments.LabelSetName#'
						AND b.Deleted = 0
					<cfif arguments.HideInActive>
						AND b.Active = 1
					</cfif>
				</cfif>
			ORDER BY BA_Label ASC
		</cfquery>

		<cfreturn getLabels>

</cffunction>

<cffunction name="GetProgramLabelSetNames"
				access="public"
				returntype="query"
				output="false"
				displayname="GetProgramLabelSetNames"
				hint="Gets all program summary label set names">

	<cfargument name="templateID" default="0" type="numeric" required="false">

		<cfquery name="getLabelSetNames" datasource="#this.dsn#">
			SELECT DISTINCT a.Label_Set_Name
			FROM Program_Summary_Label_Sets a
				<cfif arguments.templateID NEQ 0>
					INNER JOIN Program_Control_Panel_Options b ON a.Label_Set_Name = b.Label_Set_Default
					AND b.ProgramControl_Panel_Options_ID = #arguments.templateID#
				</cfif>
			WHERE a.deleted = 0
			ORDER BY a.Label_Set_Name
		</cfquery>

		<cfreturn getLabelSetNames>

</cffunction>

<cffunction name="GetProgramLabelSetBySetName"
				access="public"
				returntype="query"
				output="false"
				displayname="GetProgramLabels"
				hint="Gets all custom program summary labels by set name">

	<cfargument name="LabelSetName" required="true" type="string">
	<cfargument name="programSummaryLabelsID" required="false" type="numeric">

		<cfquery name="getLabelsFromSetName" datasource="#this.dsn#">
			SELECT *
			FROM Program_Summary_Label_Sets
			WHERE Label_Set_Name = '#arguments.LabelSetName#'
				<cfif isDefined("arguments.programSummaryLabelsID")>
					AND program_summary_labels_id = #arguments.programSummaryLabelsID#
				</cfif>
			AND deleted = 0
		</cfquery>

		<cfreturn getLabelsFromSetName>

</cffunction>

<cffunction name="DeleteProgramLabelSet"
				access="public"
				returntype="string"
				output="false"
				displayname="GetProgramLabels"
				hint="Deletes a program summary label set">

	<cfargument name="LabelSetName" required="false" type="string">

		<cfset notice = "Label set (#arguments.LabelSetName#) deleted successfully.">

		<cfquery name="deleteLabelSet" datasource="#this.dsn#">
			UPDATE Program_Summary_Label_Sets
			SET deleted = 1
			WHERE Label_Set_Name = '#arguments.LabelSetName#'
		</cfquery>

		<!--- UPDATE ALL TEMPLATES THAT USE THE LABEL SET THAT IS GETTING DELETED --->
		<cfquery name="renameLabelSet2" datasource="#this.dsn#">
			UPDATE Program_Control_Panel_Options
			SET Label_Set_Default = NULL
			WHERE Label_Set_Default = '#arguments.LabelSetName#'
		</cfquery>

		<cfreturn notice>

</cffunction>

<cffunction name="RenameProgramLabelSet"
				access="public"
				returntype="string"
				output="false"
				displayname="GetProgramLabels"
				hint="Renames a program summary label set">

	<cfargument name="LabelSetName" required="true" type="string">
	<cfargument name="LabelSetNameNew" required="true" type="string">

		<cfset notice = "Label set (#arguments.LabelSetName#) renamed successfully to (#arguments.LabelSetNameNew#).">

		<cfquery name="renameLabelSet" datasource="#this.dsn#">
			UPDATE Program_Summary_Label_Sets
			SET Label_Set_Name ='#arguments.LabelSetNameNew#'
			WHERE Label_Set_Name = '#arguments.LabelSetName#'
		</cfquery>

		<!--- UPDATE ALL TEMPLATES THAT USE THE LABEL SET THAT IS GETTING RENAMED --->
		<cfquery name="renameLabelSet2" datasource="#this.dsn#">
			UPDATE Program_Control_Panel_Options
			SET Label_Set_Default ='#arguments.LabelSetNameNew#'
			WHERE Label_Set_Default = '#arguments.LabelSetName#'
		</cfquery>

		<cfreturn notice>

</cffunction>

<cffunction name="ModifyProgramLabels"
				access="public"
				returntype="string"
				output="false"
				displayname="ModifyProgramLabels"
				hint="Updates Program_Summary_Labels table">



	<cfloop list="#FORM.loopCnt#" index="i">
		<cfif #evaluate('FORM.customlabel#i#')# NEQ "" OR LEN(FORM.labelSetName)>

			<!--- Check to see if this field exist and needs to be edited or inserted. --->
			<cfset chkForLabel = GetProgramLabelSetBySetName(FORM.labelSetName,evaluate('FORM.program_summary_labels_id#i#'))>

			<cfif chkForLabel.recordcount>
				<cfquery name="modifyProgramLabels" datasource="#this.dsn#">
					UPDATE Program_Summary_Label_Sets
					SET
						Custom_Label = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.customlabel#i#')#">
						<cfif isDefined("FORM.active#i#")>
							,Active = <cfqueryparam cfsqltype="cf_sql_bit" value="#evaluate('FORM.active#i#')#">
						<cfelse>
							,Active = 0
						</cfif>
						<cfif isDefined("FORM.delete#i#")>
							,Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="#evaluate('FORM.delete#i#')#">
						<cfelse>
							,Deleted = 0
						</cfif>
							,Item_Language_Code = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.ItemDescriptions#">
					WHERE program_summary_labels_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.program_summary_labels_id#i#')#">
						AND Label_Set_Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.labelSetName')#">
				</cfquery>
			<cfelse>
				<cfquery name="insertProgramLabels" datasource="#this.dsn#">
					INSERT INTO Program_Summary_Label_Sets
						(
							program_summary_labels_id
							,Label_Set_Name
							,Custom_Label
							,Item_Language_Code
						)
					VALUES
						(
							<cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('FORM.program_summary_labels_id#i#')#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.labelSetName')#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.customlabel#i#')#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.ItemDescriptions#">
						)
				</cfquery>
			</cfif>
		<cfelse>
			<cfquery name="deleteProgramLabels" datasource="#this.dsn#">
				DELETE FROM Program_Summary_Label_Sets
				WHERE program_summary_labels_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('FORM.program_summary_labels_id#i#')#">
					AND Label_Set_Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.labelSetName')#">
			</cfquery>
		</cfif>
	</cfloop>

	<cfif isDefined("FORM.ItemDescriptions")>
		<cfquery name="modifyProgramLabels" datasource="#this.dsn#">
			UPDATE Program_Summary_Label_Sets
			SET
				<cfif FORM.ItemDescriptions EQ "Default" OR FORM.ItemDescriptions EQ "">
					Item_Language_Code = NULL
				<cfelse>
					Item_Language_Code = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.ItemDescriptions#">
				</cfif>
			WHERE Label_Set_Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.labelSetName#">
		</cfquery>
	</cfif>

	<cfset notice = "Label set (#FORM.labelSetName#) updated successfully.">

	<cfreturn notice>

</cffunction>

<cffunction name="CreateProgramLabels"
				access="public"
				returntype="string"
				output="false"
				displayname="ModifyProgramLabels"
				hint="Create Program_Summary_Labels sets">

	<cfloop list="#FORM.loopCnt#" index="i">
		<cfif #evaluate('FORM.customlabel#i#')# NEQ "" OR LEN(FORM.labelSetName)>
			<cfquery name="insertprogramLabels" datasource="#this.dsn#">
				INSERT INTO Program_Summary_Label_Sets
					(
						program_summary_labels_id
						,Label_Set_Name
						,Custom_Label
					)
				VALUES
					(
						<cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('FORM.program_summary_labels_id#i#')#">
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.labelSetName')#">
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.customlabel#i#')#">
					)
			</cfquery>
		</cfif>
	</cfloop>

	<cfset notice = "Label set (#FORM.labelSetName#) created successfully.">

	<cfreturn notice>

</cffunction>

<cffunction name="CreateNewLabel"
				access="public"
				returntype="string"
				output="false"
				displayname="CreateNewLabel"
				hint="Create a new label for the specified label set">

	<cfargument name="labelSet" required="true" type="string">
	<cfargument name="BALabel" required="true" type="string">
	<cfargument name="CustomLabel" required="false" default="" type="string">
	<cfargument name="ItemDescriptions" required="false" default="" type="string">

	<cfquery name="insertBALabel" datasource="#this.dsn#">
		SET NOCOUNT ON
		INSERT INTO Program_Summary_Labels
			(
				BA_Label
			)
		VALUES
			(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.BALabel#">
			)
		SELECT Program_Summary_Labels_ID = @@IDENTITY
		SET NOCOUNT OFF
	</cfquery>

	<cfif arguments.CustomLabel NEQ "">
		<cfquery name="insertCustomLabel" datasource="#this.dsn#">
			INSERT INTO Program_Summary_Label_Sets
				(
					program_summary_labels_id
					,Label_Set_Name
					,Custom_Label
					,Item_Language_Code
				)
			VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_integer" value="#insertBALabel.program_summary_labels_id#">
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.labelSet#">
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CustomLabel#">
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ItemDescriptions#">
				)
		</cfquery>
	</cfif>

	<cfset notice = "Creation of new label for label set (#arguments.labelSet#) was successful.">

	<cfreturn notice>

</cffunction>

<cffunction name="GetItemLangDescCode"
				access="public"
				returntype="string"
				output="false"
				displayname="GetItemLangDescCode"
				hint="Gets the item language description code.">

	<cfargument name="LangCode" default="0" type="string" required="false">

		<cfquery name="getLangCode" datasource="#this.dsn#">
			SELECT DISTINCT Item_Language_Code
			FROM Program_Summary_Label_Sets
			WHERE Item_Language_Code = '#arguments.LangCode#' AND deleted = 0
			ORDER BY Item_Language_Code
		</cfquery>

		<cfreturn getLangCode.Item_Language_Code>

</cffunction>

<cffunction name="replaceWords"
				access="public"
				returntype="string"
				output="true"
				displayname="replaceWords"
				hint="Replaces word in a string using a label set">

	<cfargument name="contentStr" required="true" type="string">
	<cfargument name="labelset" required="true" type="query">

		<cfset content = arguments.contentStr>
		<cfset labelset = arguments.labelset>

		<cfset carriageReturn = chr(10)>
		<cfset tabCharacter = chr(13)>

		<!--- SCRIPT TO REMOVE STYLE TAGS FROM STRING AND PLACE THEM INTO A VARIABLE --->
		<cfset styleTagStr = "">
		<cfset str = content>
		<cfloop index="i" from="1" to="10">
			<cfset strLen = len(str)>
			<cfset tagPos = REFind("</style>",str) + 8>

			<cfif tagPos LT 20 or tagPos GT 2000>
				<cfbreak>
			<cfelse>
				<cfset "str#i#" = removechars(str,tagPos,strLen)>

				<cfset str = removechars(str,1,tagPos)><!--- string without style tags --->
				<cfset styleTagStr = styleTagStr & evaluate("str#i#")><!--- variable containing style tags --->
			</cfif>
		</cfloop>

		<!--- OUTPUT STRING WITHOUT STYLE TAGS --->
		<cfset content = str>

		<!--- TWO VERSIONS OF TAG REPLACEMENT, CF8 ADDED THE reMatchNoCase() FUNCTION WHICH CREATES AN ARRAY FROM A REGULAR EXPRESSION AUTOMATICALLY.
				OLDER VERSIONS NEED A COMBINATION OF FUNCTIONS TO GET THE SAME RESULT, DOWNSIDE IS THAT PERFORMANCE SUFFERS A BIT. --->
		<cfif listGetAt(server.coldfusion.productversion,1,",") LT 8>
			<cfset htmlTags = arrayNew(1)>
			<cfloop index="i" from="1" to="10000">
				<cfset htmlTagSTRUCT = REFindNoCase("<[^>]*>", str, 1, true)><!--- OLD REGEX:  <[^>]*(>|$)  --->
				<cfif htmlTagSTRUCT.pos[1] GT 0>
					<cfset arrayAppend(htmlTags,Mid(str, htmlTagSTRUCT.pos[1], htmlTagSTRUCT.len[1]))>
					<cfset str = removeChars(str,1,htmlTagSTRUCT.pos[1] + htmlTagSTRUCT.len[1]-1)>
				<cfelse>
					<cfbreak>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset htmlTags = reMatchNoCase("<[^>]*>", str)><!--- OLD REGEX:  <[^>]*(>|$)  --->
		</cfif>

		<!--- CONVERT TO LIST FOR LOOP --->
		<cfset htmlTags = ArrayToList(htmlTags,"||")>

		<!--- LOOP AND REPLACE TAGS WITH A UNIQUE ID --->
		<cfset row = 0>
		<cfloop list="#htmlTags#" index="tag" delimiters="||">
			<cfset row = row + 1>
			<cfset tagReplacement = " X#row#Y "> <!--- spaces are intentional in this variable, please do not remove --->
			<cfset content = replaceNoCase(content,tag,tagReplacement,"all")>
		</cfloop>


		<!--- LABEL SET REWORDING LOGIC --->
			<!--- REPLACE ANY PART OF THE CONTENT STRING WITH THE CUSTOM LABEL IF IT EXISTS. --->
			<!--- ALL PHRASES MUST BE CHANGED FIRST AS A PHRASE COULD CHANGE IF THE WORDS WERE DONE FIRST. --->
			<!--- CHANGE ALL PHRASES FIRST --->
			<cfloop query="labelset">
				<cfif labelset.custom_label NEQ "" AND listlen(ba_label," ") GT 1>
					<cfset regExStr1 = "\b" & ba_label & "\b">
					<cfset content = REReplace(content,regExStr1,labelset.custom_label,"all")>
				</cfif>
			</cfloop>

			<!--- CHANGE SINGULAR WORDS --->
			<cfloop query="labelset">
				<cfif labelset.custom_label NEQ "" AND listlen(ba_label," ") EQ 1>
					<cfset regExStr2 = "\b" & ba_label & "\b">
					<cfset content = REReplace(content,regExStr2,labelset.custom_label,"all")>
				</cfif>
			</cfloop>

			<!---
				SET LABEL SET NAME TO A VARIABLE.  SOME RECORDS IN THE QUERY SEE THIS AS AN EMPTY STRING,
				SO A LOOP IS NEEDED TO FIND THE FIRST INSTANCE OF THE NAME AND SET IT TO THE VARIABLE
				AND THEN BREAK OUT OF THE LOOP
			 --->
			<cfloop query="labelset">
				<cfif labelset.label_Set_Name NEQ "">
					<cfset labelSetName = labelset.label_Set_Name>
					<cfbreak>
				</cfif>
			</cfloop>

			<!--- CHECK TO SEE (PRIVATE METHOD) IF A LANGUAGE CODE EXISTS FOR THE CURRENT LABEL SET --->
			<cfset langCode = GetItemLanguageCodeByLabelSetName(labelSetName)>
			<cfif langCode NEQ "NONE">

				<!--- GET QUERY OF TEXT TO CHANGE --->
				<cfset qDescriptions = LoadDecriptions(langCode)>

				<cfloop query="qDescriptions">
					<cfset content = REReplace(content,oldDesc,newDesc,"all")>
				</cfloop>

			</cfif>

		<!--- REPLACE EACH UNIQUE ID WITH IT'S ORIGINAL TAG --->
		<cfset row = 0>
		<cfloop list="#htmlTags#" index="tag" delimiters="||">
			<cfset row = row + 1>
			<cfset tagReplacement = " X#row#Y "> <!--- spaces are intentional in this variable, please do not remove --->
			<cfset content = replaceNoCase(content,tagReplacement,tag,"all")>
		</cfloop>


			<!--- ADD STYLE TAGS BACK TO STRING --->
			<cfset content = styleTagStr & content>

		<!--- END: LABEL SET REWORDING LOGIC --->
	<cfreturn content>

</cffunction>
<!--- END:: PROGRAM SUMMARY LABELS --->

<!--- PROGRAM SUMMARY ITEM LANGUAGE LABELS --->

<cffunction name="GetItemLanguageCode"
				access="public"
				returntype="query"
				output="false"
				displayname="GetProgramLabels"
				hint="Gets all program summary labels">

	<cfquery name="itemLangCodes" datasource="#this.dsn#">
		SELECT DISTINCT Language_Code
		FROM Program_Summary_Label_Items
		WHERE Deleted = 0
	</cfquery>

	<cfreturn itemLangCodes>

</cffunction>

<cffunction name="GetItemLanguageDescByCode"
				access="public"
				returntype="query"
				output="false"
				displayname="GetProgramLabels"
				hint="Gets all custom program summary labels by set name">

	<cfargument name="LangCode" required="true" type="string">

		<cfquery name="getLabelsFromSetName" datasource="#this.dsn#">
			SELECT *
			FROM Program_Summary_Label_Items
			WHERE Language_Code = '#arguments.LangCode#'
				AND deleted = 0
		</cfquery>

		<cfreturn getLabelsFromSetName>

</cffunction>

<cffunction name="GetItemLanguageCodeByLabelSetName"
				access="private"
				returntype="string"
				output="false"
				displayname="GetItemLanguageCodeByLabelSetName"
				hint="Gets the language code based on label set name">

	<cfargument name="labelSetName" required="true" default="" type="string">

	<cfquery name="qGetLanguageCode" datasource="#this.dsn#">
		SELECT DISTINCT a.Language_Code
		FROM Program_Summary_Label_Items a
			INNER JOIN Program_Summary_Label_Sets b ON a.Language_Code = b.Item_Language_Code
		WHERE b.Label_Set_Name = '#arguments.labelSetName#'
			AND a.Deleted = 0
			AND b.Deleted = 0
	</cfquery>

	<cfif qGetLanguageCode.recordcount>
		<cfset langCode = qGetLanguageCode.Language_Code>
	<cfelse>
		<cfset langCode = "NONE">
	</cfif>

	<cfreturn langCode>

</cffunction>

<cffunction name="DeleteItemLanguageCode"
				access="public"
				returntype="string"
				output="false"
				displayname="GetProgramLabels"
				hint="Deletes a program summary label set">

	<cfargument name="LangCode" required="false" type="string">

		<cfset notice = "Language code (#arguments.LangCode#) deleted successfully.">

		<cfquery name="deleteLabelSet" datasource="#this.dsn#">
			UPDATE Program_Summary_Label_Items
			SET deleted = 1
			WHERE Language_Code = '#arguments.LangCode#'
		</cfquery>

		<cfreturn notice>

</cffunction>

<cffunction name="RenameItemLanguageCode"
				access="public"
				returntype="string"
				output="false"
				displayname="GetProgramLabels"
				hint="Renames a program summary label set">

	<cfargument name="LangCodeName" required="true" type="string">
	<cfargument name="LangCodeNameNew" required="true" type="string">

		<cfset notice = "Item Language Code (#arguments.LangCodeName#) renamed successfully to (#arguments.LangCodeNameNew#).">

		<cfquery name="renameLabelSet" datasource="#this.dsn#">
			UPDATE Program_Summary_Label_Items
			SET Language_Code ='#arguments.LangCodeNameNew#'
			WHERE Language_Code = '#arguments.LangCodeName#'
		</cfquery>

		<cfreturn notice>

</cffunction>

<cffunction name="ModifyItemLanguageCode"
				access="public"
				returntype="string"
				output="false"
				displayname="ModifyProgramLabels"
				hint="Updates Program_Summary_Labels table">

	<cfloop list="#FORM.loopCnt#" index="i">
		<cfif #evaluate('FORM.ItemNumber#i#')# NEQ "">
			<cfquery name="modifyLangCode" datasource="#this.dsn#">
				UPDATE Program_Summary_Label_Items
				SET
					Item_Number = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.ItemNumber#i#')#">
					,Item_Description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.ItemDescription#i#')#">
					<cfif isDefined("FORM.active#i#")>
						,Active = <cfqueryparam cfsqltype="cf_sql_bit" value="#evaluate('FORM.active#i#')#">
					<cfelse>
						,Active = 0
					</cfif>
					<cfif isDefined("FORM.delete#i#")>
						,Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="#evaluate('FORM.delete#i#')#">
					<cfelse>
						,Deleted = 0
					</cfif>
				WHERE program_summary_label_item_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('FORM.program_summary_label_item_id#i#')#">
					AND Language_Code = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.LangCode#">
			</cfquery>
		<cfelse>
			<cfquery name="deleteProgramLabels" datasource="#this.dsn#">
				DELETE FROM Program_Summary_Label_Items
				WHERE program_summary_label_item_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('FORM.program_summary_label_item_id#i#')#">
					AND Language_Code = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.LangCode#">
			</cfquery>
		</cfif>
	</cfloop>

	<cfset notice = "Language code (#FORM.LangCode#) updated successfully.">

	<cfreturn notice>

</cffunction>

<cffunction name="CreateItemLanguageCode"
				access="public"
				returntype="string"
				output="false"
				displayname="CreateItemLanguageCode"
				hint="Create Program_Summary_Label_Items codes">

	<cfloop list="#FORM.loopCnt#" index="i">
		<cfif #evaluate('FORM.ItemNumber#i#')# NEQ "">
			<cfquery name="insertLanguageCodes" datasource="#this.dsn#">
				INSERT INTO Program_Summary_Label_Items
					(
						Language_Code
						,Item_Number
						,Item_Description
					)
				VALUES
					(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.LangCode')#">
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.ItemNumber#i#')#">
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.ItemDescription#i#')#">
					)
			</cfquery>
		</cfif>
	</cfloop>

	<cfset notice = "Language code (#FORM.LangCode#) created successfully.">

	<cfreturn notice>

</cffunction>

<cffunction name="CreateNewItemDesc"
				access="public"
				returntype="string"
				output="false"
				displayname="CreateNewLabel"
				hint="Create a new label for the specified label set">

	<cfargument name="LangCode" required="true" type="string">
	<cfargument name="ItemNumber" required="true" type="string">
	<cfargument name="ItemDescription" required="true" type="string">

	<cfquery name="insertNewCode" datasource="#this.dsn#">
		INSERT INTO Program_Summary_Label_Items
			(
				Language_Code,
				Item_Number,
				Item_Description
			)
		VALUES
			(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LangCode#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ItemNumber#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ItemDescription#">
			)
	</cfquery>

	<cfset notice = "Creation of new item description for language code (#arguments.LangCode#) was successful.">

	<cfreturn notice>

</cffunction>

<cffunction name="ReadLangFile"
				access="public"
				returntype="any"
				output="true"
				displayname="readLanguageTxt"
				hint="Read the text file to populate the DB table with alternate names.">

	<cfset CR = chr(10)>
	<cfset TC = chr(13)>

	<cfdirectory action="list" sort="datelastmodified DESC" filter="*.txt" directory="#this.txtFilePath#" name="LangFileDir">

	<cffile action="read" file="#this.txtFilePath#\#LangFileDir.Name#" variable="LangFile">

	<cfset langFileStr = replace(LangFile,CR,";","ALL")>

	<cfloop list="#langFileStr#" index="dataRow" delimiters=";">
		<cfset itemNum = trim(listGetAt(dataRow,1,"|"))>
		<cfset langCode = trim(listGetAt(dataRow,2,"|"))>
		<cfset itemDesc = trim(listGetAt(dataRow,3,"|"))>

			<cfquery datasource="#this.dsn#">
				IF NOT EXISTS(SELECT ITEM_NUMBER FROM Program_Summary_Label_Items WHERE ITEM_NUMBER = '#itemNum#')
				BEGIN
					INSERT INTO Program_Summary_Label_Items
					(
						Language_Code
						,Item_Number
						,Item_Description
					)
					VALUES
					(
						<cfqueryparam value="#langCode#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#itemNum#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#itemDesc#" cfsqltype="cf_sql_varchar">
					)
				END
			</cfquery>
	</cfloop>

	<cfquery name="itemLabels" datasource="#this.dsn#">
		SELECT *
		FROM Program_Summary_Label_Items
		ORDER BY ITEM_DESCRIPTION
	</cfquery>

	<cfreturn itemLabels>

</cffunction>

<cffunction name="LoadDecriptions"
				access="private"
				returntype="query"
				output="false"
				displayname="LoadDecriptions"
				hint="Gets and array of item descriptions that will be used in the word replacement in the display program pages">

	<cfargument name="languageCode" required="true" default="" type="string">

	<cfquery name="itemDescriptions" datasource="#this.dsn#">
		SELECT a.Item_Description as newDesc, b.Description as oldDesc
		FROM Program_Summary_Label_Items a
			INNER JOIN BSA_Foodservice_Items_Master b ON a.Item_Number = b.Item
		WHERE a.Language_Code = '#arguments.languageCode#'
			AND a.Deleted = 0
			AND b.Deleted = 0
	</cfquery>

	<cfreturn itemDescriptions>

</cffunction>
<!--- END:: PROGRAM SUMMARY ITEM LANGUAGE LABELS --->
<!--- DEV NOTE: DAA; D16743 ---- REMOVED AND MOVED TO CUSTOMER SETTINGS LABELS --->
<!--- PRODUCT GROUP LEVEL LABELS --->
<!--- code commented STARTED here --->

<cffunction name="getAllProductAttributes"
			access="public"
			output="false"
			returntype="Query">

<cfargument name="hideInActive" required="false" default="0" type="boolean">

	 <cfset var allProductAttributes = "" />

		<cfquery name="allProductAttributes" datasource="#this.dsn#">
			SELECT Product_Group_Level_ID,
					Group_Internal_Label,
					Group_Level_Desc,
					-- Group_Level_Desc_Plural,
					Convert(varchar,Created_Date,101) as Created_Date,
					Search_Filter_On,
					Display_In_Search_Results,
					Active,
					List_order,
					Deleted
			FROM   Product_Group_Level
			WHERE  deleted = 0
				<cfif arguments.hideInActive>
					AND active = 1
				</cfif>
			order by List_order
		</cfquery>

    <cfreturn allProductAttributes />

</cffunction>

<cffunction name="getProductLabelByGroupLevelID"
				access="public"
				returntype="string"
				output="false"
				displayname="getProductLabelByTypeID">
	<cfargument name="groupLevelID" required="true" type="numeric">
	<cfargument name="plural" required="false" default="0" type="boolean">

	<cfquery name="local.prdLabel" datasource="#this.dsn#">
		SELECT group_level_desc           <!--- 57305 --->
		  FROM Product_Group_Level
		 WHERE Product_Group_Level_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.groupLevelID#">
	</cfquery>

	<cfreturn local.prdLabel.group_level_desc>
</cffunction>

<cffunction name="ModifyProductGroupLevelLabels"
				access="public"
				returntype="any"
				output="false"
				displayname="ModifyProductGroupLevelLabels"
				hint="Updates Product_Group_Level table">
	<cfset allProdSearchFields = this.getAllProductStaticSearchFields() />
	<cfloop from="1" to="#FORM.loopCnt#" index="i">
      <cfif (NOT isDefined("FORM.productLabel#i#"))>
        <cfset prodVal= "" />
      <cfelse>
        <cfset prodVal="#evaluate('FORM.productLabel#i#')#" />
      </cfif>
		  <cfif isDefined("FORM.boxProdActive#i#")>
          <cfset bActive = "#evaluate('FORM.boxProdActive#i#')#" />
       <cfelse>
          <cfset bActive = 0 />
       </cfif>
      <cfif (prodVal NEQ "")> <!--- customlabelsingular --->
				<cfquery name="insProductLevels" datasource="#this.dsn#">
          UPDATE Product_Group_Level
          SET
            group_level_desc = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.ProductLabel#i#')#">
      ,List_Order = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.ProductListOrder#i#')#">
            <cfif isDefined("FORM.boxProd#i#")>
					    ,Search_Filter_on = <cfqueryparam cfsqltype="cf_sql_bit" value="#evaluate('FORM.boxProd#i#')#">
             <cfelse>
              ,Search_Filter_on = 0
            </cfif>
            <cfif isDefined("FORM.boxDisplayProdSearch#i#")>
              ,Display_In_Search_Results = <cfqueryparam cfsqltype="cf_sql_bit" value="#evaluate('FORM.boxDisplayProdSearch#i#')#">
             <cfelse>
              ,Display_In_Search_Results = 0
            </cfif>
		  
					    ,Active = #bActive#
          WHERE product_group_level_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('FORM.prodID#i#')#">
				</cfquery>
        <!---------------------------------------------------------------------------
          Dev Notes: D18971
            We need to update the Product_Group_Attribute Table alone with the
            Active Status as these two tables are tied by the Product_group_level_id
            -Anand Rao/13-May-09
         --------------------------------------------------------------------------->
        <cfquery name="insProductLevels2" datasource="#this.dsn#">
          UPDATE Product_Group_Attribute
          SET
            Active = #bActive#
          WHERE product_group_level_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('FORM.prodID#i#')#">
        </cfquery>
			</cfif>

<!--- START: 29392/Anand Rao/05-Dec-2011 --->
		<cfloop query ="allProdSearchFields">
	 		<cfif (isDefined("FORM.ProdListOrder#i#_#allProdSearchFields.Search_Settings_ID#"))>
			<cfquery name="UpdSearchSettings" datasource="#this.dsn#">
				UPDATE Search_settings
				SET
			<cfif isDefined("FORM.boxStaticProd#i#_#allProdSearchFields.Search_Settings_ID#")>
				Display_In_Search = <cfqueryparam cfsqltype="cf_sql_bit" value="#evaluate('FORM.boxStaticProd#i#_#allProdSearchFields.Search_Settings_ID#')#">
			<cfelse>
				Display_In_Search = 0
			</cfif>
			<cfif isDefined("FORM.boxDisplayAdditionalProdSearch#i#_#allProdSearchFields.Search_Settings_ID#")>
				,Display_In_Search_Results = <cfqueryparam cfsqltype="cf_sql_bit" value="#evaluate('FORM.boxDisplayAdditionalProdSearch#i#_#allProdSearchFields.Search_Settings_ID#')#">
			<cfelse>
				,Display_In_Search_Results = 0
			</cfif>

				,List_Order = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.ProdListOrder#i#_#allProdSearchFields.Search_Settings_ID#')#">
			WHERE Search_settings_ID = #allProdSearchFields.Search_Settings_ID#
			</cfquery>

			</cfif>
		</cfloop>
		<!--- END: 29392/Anand Rao/05-Dec-2011 --->


	</cfloop>


</cffunction>
<!--- END:: PRODUCT GROUP LEVEL LABELS --->

<!--- DISTRIBUTOR GROUP LEVEL LABELS --->

<cffunction name="getAllDistributorAttributes"
			access="public"
			output="false"
			returntype="Query">

	<cfargument name="excludeList" required="false" Default="" type="string">

	 <cfset var allDistributorAttributes = "" />

		 <cfquery name="allDistributorAttributes" datasource="#this.dsn#">
			Select Distributor_Group_Level_ID,
					Group_Level_Desc,
					-- Group_Level_Desc_Plural,
					Convert(varchar,Created_Date,101) as Created_Date,
					Active,
					Search_Filter_On,
					Display_In_Search_Results,
					Group_Level_Desc_Internal,
					List_order,
          				Deleted
			From   Distributor_Group_Level
			Where  Deleted = 0
			<cfif len(arguments.excludeList)>
			AND Distributor_Group_Level_ID NOT IN ( <cfqueryparam value="#arguments.excludeList#" cfsqltype="CF_SQL_INTEGER" list="yes" /> )
			</cfif>
		  </cfquery>

    <cfreturn allDistributorAttributes />

</cffunction>

<cffunction name="getAllDistributorStaticSearchFields"
			access="public"
			output="false"
			returntype="Query">

	 <cfset var allDistributorStaticSearchFields = "" />

		 <cfquery name="allDistributorStaticSearchFields" datasource="#Application.Datasource#">
			SELECT 	Search_Settings_ID,
				 	Type_ID,
					Field_Name,
					Display_In_Search,
					Display_In_Search_Results,
					List_Order,
					Created_Date,
					Deleted
			FROM
					Search_Settings
			WHERE
					Type_ID = 2 AND Deleted = 0
			ORDER BY
					List_Order
		  </cfquery>

    <cfreturn allDistributorStaticSearchFields />

</cffunction>

<cffunction name="getDistributorStaticSearchFieldsActive"
			access="public"
			output="false"
			returntype="Query">

	 <cfset var distributorStaticSearchFieldsActive = "" />

		 <cfquery name="distributorStaticSearchFieldsActive" datasource="#Application.Datasource#">
			SELECT 	Search_Settings_ID,
				 	Type_ID,
					Field_Name,
					Display_In_Search,
					List_Order,
					Created_Date,
					Deleted
	        , Distributor_Group_Level_Id = 0
			    , Is_PG = 0
			FROM
					Search_Settings
			WHERE
					Type_ID = 2 AND Display_In_Search = 1 AND Deleted = 0
			ORDER BY
					List_Order
		  </cfquery>

    <cfreturn distributorStaticSearchFieldsActive />

</cffunction>

<cffunction name="getDistributorSearchFields"
			access="public"
			output="false"
			returntype="Query">
		<cfargument name="includeGroups" required="false" default="" hint="list of distributor group levels (group_level_desc_internal) to be included">   <!---31309--->
	 	<cfset var loc = StructNew() />
		<cfquery name="loc.qFields" datasource="#Application.Datasource#">
			SELECT Field_Name
			       , Distributor_Group_Level_Id = 0
			       , List_Order
			       , Is_PG = 0
			  FROM Search_Settings
			 WHERE Type_Id = 2
			       AND Deleted = 0
			       AND Display_In_Search = 1
			UNION
			SELECT Group_Level_desc_Internal
			       , Distributor_Group_Level_Id
			       , List_Order
			       , Is_PG
			  FROM Distributor_Group_Level
			 WHERE Deleted = 0
			       AND Search_Filter_On = 1
			       AND Active = 1
			       <cfif len(arguments.includeGroups)>    <!---31309 allowed market, region, zone to be included in search from program--->
			       	AND Group_Level_desc_Internal IN ( <cfqueryparam value="#arguments.includeGroups#" cfsqltype="cf_sql_varchar" list="yes"> )
			       </cfif>
			 ORDER BY List_Order
		</cfquery>
    <cfreturn loc.qFields />
</cffunction>

<cffunction name="getDistributorSearchFieldsDisplayStatus"
			access="public"
			output="false"
			returntype="Query">

	<cfset var DistributorSearchFieldsDisplayStatus = "" />

		<cfquery name="DistributorSearchFieldsDisplayStatus" datasource="#Application.Datasource#">
			SELECT Distributor_Group_Level_ID,
					Group_Level_Desc_Internal,
					Convert(varchar,Created_Date,101) as Created_Date,
					Display_In_Search_Results,
					Active,
					Deleted
			FROM
					Distributor_Group_Level
			WHERE	display_In_Search_Results = 1
			AND	deleted = 0
		</cfquery>

	<cfreturn DistributorSearchFieldsDisplayStatus />

</cffunction>

<cffunction name="getDistributorStaticSearchFieldsDisplayStatus"
			access="public"
			output="false"
			returntype="Query">

	<cfset var distributorStaticSearchFieldsDisplayStatus = "" />

		<cfquery name="distributorStaticSearchFieldsDisplayStatus" datasource="#Application.Datasource#">
			SELECT 	Search_Settings_ID,
				 	Type_ID,
					Field_Name,
					Created_Date,
					Deleted,
					Display_In_Search_Results
			FROM
					Search_Settings
			WHERE	Type_ID = 2 
			AND	Display_In_Search_Results = 1 
			AND	Deleted = 0
		</cfquery>

	<cfreturn distributorStaticSearchFieldsDisplayStatus />

</cffunction>

<cffunction name="getAllProductStaticSearchFields"
			access="public"
			output="false"
			returntype="Query">

	 <cfset var allProductStaticSearchFields = "" />
	 <cfset var RemoveUPC= 1>

		 <cfquery name="allProductStaticSearchFields" datasource="#Application.Datasource#">
			SELECT 	Search_Settings_ID,
				 	Type_ID,
					Field_Name,
					Display_In_Search,
					Display_In_Search_Results,
					List_Order,
					Created_Date,
					Deleted
			FROM
					Search_Settings
			WHERE
					Type_ID = 1 AND Deleted = 0

			<cfif application.returned_customer_setting.type_code_show_column NEQ application.returned_customer_setting.customer_setting_error_string>
				<cfif application.returned_customer_setting.type_code_show_column EQ 1>
					<cfset RemoveUPC = 0>
				</cfif>
			</cfif>
			<cfif RemoveUPC eq 1>
			AND Field_Name != 'UPC'
			</cfif>

			ORDER BY
					List_Order
		  </cfquery>

    <cfreturn allProductStaticSearchFields />

</cffunction>

<cffunction name="getProductStaticSearchFieldsActive"
			access="public"
			output="false"
			returntype="Query">

	 <cfset var productStaticSearchFieldsActive = "" />

		 <cfquery name="productStaticSearchFieldsActive" datasource="#Application.Datasource#">
			SELECT 	Search_Settings_ID,
				 	Type_ID,
					Field_Name,
					Display_In_Search,
					List_Order,
					Created_Date,
					Deleted
			FROM
					Search_Settings
			WHERE
					Type_ID = 1 AND Display_In_Search = 1 AND Deleted = 0
			ORDER BY
					List_Order
		  </cfquery>

	<cfreturn productStaticSearchFieldsActive />

</cffunction>

<cffunction name="getProductSearchFieldsDisplayStatus"
			access="public"
			output="false"
			returntype="Query">

	<cfset var ProductSearchFieldsDisplayStatus = "" />

		<cfquery name="ProductSearchFieldsDisplayStatus" datasource="#Application.Datasource#">
			SELECT Product_Group_Level_ID,
					Group_Internal_Label,
					Group_Level_Desc,
					Convert(varchar,Created_Date,101) as Created_Date,
					Display_In_Search_Results,
					Active,
					Deleted
			FROM
					Product_Group_Level
			WHERE	display_In_Search_Results = 1
			AND	deleted = 0
		</cfquery>

	<cfreturn ProductSearchFieldsDisplayStatus />

</cffunction>

<cffunction name="getProductStaticSearchFieldsDisplayStatus"
			access="public"
			output="false"
			returntype="Query">

	<cfset var ProductStaticSearchFieldsDisplayStatus = "" />

		<cfquery name="ProductStaticSearchFieldsDisplayStatus" datasource="#Application.Datasource#">
			SELECT 	Search_Settings_ID,
				 	Type_ID,
					Field_Name,
					Created_Date,
					Deleted,
					Display_In_Search_Results
			FROM
					Search_Settings
			WHERE	Type_ID = 1 
			AND	Display_In_Search_Results = 1 
			AND	Deleted = 0
		</cfquery>

	<cfreturn ProductStaticSearchFieldsDisplayStatus />

</cffunction>

<cffunction name="getAllOperatorAttributes"
			access="public"
			output="false"
			returntype="Query">

	 <cfset var allOperatorAttributes = "" />

		 <cfquery name="allOperatorAttributes" datasource="#this.dsn#">
			SELECT Operator_Group_Level_ID,
					Group_Level_Desc,
					-- Group_Level_Desc_Plural,
					Convert(varchar,Created_Date,101) as Created_Date,
					Active,
					Search_Filter_On,
					Group_Level_Desc_Internal,
					List_order,
          			Deleted
			From   Operator_Group_Level
			Where  Deleted = 0
		  </cfquery>

    <cfreturn allOperatorAttributes />

</cffunction>

<cffunction name="getAllOperatorStaticSearchFields"
			access="public"
			output="false"
			returntype="Query">

	 <cfset var allOperatorStaticSearchFields = "" />

		 <cfquery name="allOperatorStaticSearchFields" datasource="#Application.Datasource#">
			SELECT 	Search_Settings_ID,
				 	Type_ID,
					Field_Name,
					Display_In_Search,
					Display_In_Search_Results,
					List_Order,
					Created_Date,
					Deleted
			FROM
					Search_Settings
			WHERE
					Type_ID = 3 AND Deleted = 0
			ORDER BY
					List_Order
		  </cfquery>

    <cfreturn allOperatorStaticSearchFields />
</cffunction>

<cffunction name="getOperatorsStaticSearchFieldsActive"
			access="public"
			output="false"
			returntype="Query">

	 <cfset var operatorStaticSearchFieldsActive = "" />

		 <cfquery name="operatorStaticSearchFieldsActive" datasource="#Application.Datasource#">
			SELECT 	Search_Settings_ID,
				 	Type_ID,
					Field_Name,
					Display_In_Search,
					List_Order,
					Created_Date,
					Deleted
		      ,Operator_Group_Level_Id = 0
	        ,Is_PG = 0
			FROM
					Search_Settings
			WHERE
					Type_ID = 3 AND Display_In_Search = 1 AND Deleted = 0
			ORDER BY
					List_Order
		  </cfquery>

    <cfreturn operatorStaticSearchFieldsActive />

</cffunction>

	<cffunction name="getOperatorStaticSearchFieldsDisplayStatus"
				access="public"
				output="false"
				returntype="Query">

		<cfset var operatorStaticSearchFieldsDisplayStatus = "" />

			<cfquery name="operatorStaticSearchFieldsDisplayStatus" datasource="#Application.Datasource#">
				SELECT 	Search_Settings_ID,
						Type_ID,
						Field_Name,
						Created_Date,
						Deleted,
						Display_In_Search_Results
				FROM
						Search_Settings
				WHERE	Type_ID = 3 
				AND	Display_In_Search_Results = 1 
				AND	Deleted = 0
			</cfquery>

		<cfreturn operatorStaticSearchFieldsDisplayStatus />

	</cffunction>

	<cffunction name="getOperatorSearchFields"
			access="public"
			output="false"
			returntype="Query">
	 	<cfset var loc = StructNew() />
		<cfquery name="loc.qFields" datasource="#Application.Datasource#">
			SELECT Field_Name
			       , Operator_Group_Level_Id = 0
			       , List_Order
			       , Is_PG = 0
			  FROM Search_Settings
			 WHERE Type_Id = 3
			       AND Deleted = 0
			       AND Display_In_Search = 1
			UNION
			SELECT Group_Level_desc_Internal
			       , Operator_Group_Level_Id
			       , List_Order
			       , Is_PG
			  FROM Operator_Group_Level
			 WHERE Deleted = 0
			       AND Search_Filter_On = 1
			       AND Active = 1
			 ORDER BY List_Order
		</cfquery>
    <cfreturn loc.qFields />
</cffunction>

<cffunction name="ModifyDistributorGroupLevelLabels"
				access="public"
				returntype="any"
				output="false"
				displayname="ModifyDistributorGroupLevelLabels"
				hint="Updates Distributor_Group_Level table">

	<cfset allDistSearchFields = this.getAllDistributorStaticSearchFields() />
	<cfloop from="1" to="#FORM.loopCnt#" index="i">
  <cfif (NOT isDefined("FORM.distLabel#i#"))>
        <cfset distVal= "" />
      <cfelse>
        <cfset distVal="#evaluate('FORM.distLabel#i#')#" />
      </cfif>

		<cfif distVal NEQ "">
			<cfquery name="insDistributorLevels" datasource="#this.dsn#">
				UPDATE Distributor_Group_Level
				SET
				group_level_desc = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.DistLabel#i#')#">
				,List_order = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.DistListOrder#i#')#">
				<cfif isDefined("FORM.boxDist#i#")>
				,Search_Filter_on = <cfqueryparam cfsqltype="cf_sql_bit" value="#evaluate('FORM.boxDist#i#')#">
				<cfelse>
				,Search_Filter_on = 0
				</cfif>
				<cfif isDefined("FORM.boxDisplayDistSearch#i#")>
				,Display_In_Search_Results = <cfqueryparam cfsqltype="cf_sql_bit" value="#evaluate('FORM.boxDisplayDistSearch#i#')#">
				<cfelse>
				,Display_In_Search_Results = 0
				</cfif>
				<cfif isDefined("FORM.boxDistActive#i#")>
				,Active = <cfqueryparam cfsqltype="cf_sql_bit" value="#evaluate('FORM.boxDistActive#i#')#">
				<cfelse>
				,Active = 0
		</cfif>
		WHERE distributor_group_level_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('FORM.DistID#i#')#">
			</cfquery>
		</cfif>
		<!--- START: 29392/Anand Rao/05-Dec-2011 --->
		<cfloop query ="allDistSearchFields">
	 		<cfif (isDefined("FORM.DistListOrder#i#_#allDistSearchFields.Search_Settings_ID#"))>
			<cfquery name="UpdSearchSettings" datasource="#this.dsn#">
				UPDATE Search_settings
				SET
			<cfif isDefined("FORM.boxStaticDist#i#_#allDistSearchFields.Search_Settings_ID#")>
				Display_In_Search = <cfqueryparam cfsqltype="cf_sql_bit" value="#evaluate('FORM.boxStaticDist#i#_#allDistSearchFields.Search_Settings_ID#')#">
			<cfelse>
				Display_In_Search = 0
			</cfif>
			<cfif isDefined("FORM.boxDisplayAdditionalDistSearch#i#_#allDistSearchFields.Search_Settings_ID#")>
				,Display_In_Search_Results = <cfqueryparam cfsqltype="cf_sql_bit" value="#evaluate('FORM.boxDisplayAdditionalDistSearch#i#_#allDistSearchFields.Search_Settings_ID#')#">
			<cfelse>
				,Display_In_Search_Results = 0
			</cfif>

				,List_Order = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.DistListOrder#i#_#allDistSearchFields.Search_Settings_ID#')#">
			WHERE Search_settings_ID = #allDistSearchFields.Search_Settings_ID#
			</cfquery>

			</cfif>
		</cfloop>
		<!--- END: 29392/Anand Rao/05-Dec-2011 --->

	</cfloop>
</cffunction>

<cffunction name="modifyOperatorSearchSettings"
				access="public"
				returntype="any"
				output="false"
				displayname="modifyOperatorSearchSettings"
				hint="Updates Search_Settings table">
	<cfset allOprSearchFields = this.getAllOperatorStaticSearchFields() />

 <!--- There was a conflict with the distributor, hence this start at 1000 --->
		<cfloop from="1000" to="#1000+FORM.loopCnt#" index="i">
       <!--- START: D30185:Label Settings, PG and Operator Search Tool/Anand Rao/26-Jan-2012 --->
	 <cfif (NOT isDefined("FORM.oprLabel#i#"))>
        <cfset oprVal= "" />
      <cfelse>
        <cfset oprVal="#evaluate('FORM.oprLabel#i#')#" />
      </cfif>

		<cfif oprVal NEQ "">
			<cfquery name="updOperatorLevels" datasource="#this.dsn#">
				UPDATE Operator_Group_Level
				SET
				group_level_desc = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.oprLabel#i#')#">
				,List_order = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.OprListOrder#i#')#">
				<cfif isDefined("FORM.boxOpr#i#")>
				,Search_Filter_on = <cfqueryparam cfsqltype="cf_sql_bit" value="#evaluate('FORM.boxOpr#i#')#">
				<cfelse>
				,Search_Filter_on = 0
				</cfif>
				<cfif isDefined("FORM.boxOprActive#i#")>
				,Active = <cfqueryparam cfsqltype="cf_sql_bit" value="#evaluate('FORM.boxOprActive#i#')#">
				<cfelse>
				,Active = 0
				</cfif>
				WHERE Operator_group_level_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('FORM.OprID#i#')#">
			</cfquery>
		</cfif>
		<!--- END: D30185:Label Settings, PG and Operator Search Tool/Anand Rao/26-Jan-2012 --->

<!--- START: 29392/Anand Rao/05-Dec-2011 --->
		<cfloop query ="allOprSearchFields">
	 		<cfif (isDefined("FORM.OprListOrder#i#_#allOprSearchFields.Search_Settings_ID#"))>
			<cfquery name="UpdSearchSettings" datasource="#this.dsn#">
				UPDATE Search_settings
				SET
			<cfif isDefined("FORM.boxStaticOpr#i#_#allOprSearchFields.Search_Settings_ID#")>
				Display_In_Search = <cfqueryparam cfsqltype="cf_sql_bit" value="#evaluate('FORM.boxStaticOpr#i#_#allOprSearchFields.Search_Settings_ID#')#">
			<cfelse>
				Display_In_Search = 0
			</cfif>
			<cfif isDefined("FORM.boxDisplayAdditionalOprSearch#i#_#allOprSearchFields.Search_Settings_ID#")>
				,Display_In_Search_Results = <cfqueryparam cfsqltype="cf_sql_bit" value="#evaluate('FORM.boxDisplayAdditionalOprSearch#i#_#allOprSearchFields.Search_Settings_ID#')#">
			<cfelse>
				,Display_In_Search_Results = 0
			</cfif>
					,List_Order = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.OprListOrder#i#_#allOprSearchFields.Search_Settings_ID#')#">
				WHERE Search_settings_ID = #allOprSearchFields.Search_Settings_ID#
			</cfquery>
			</cfif>
		</cfloop>
		<!--- END: 29392/Anand Rao/05-Dec-2011 --->
	</cfloop>

</cffunction>
<!--- END:: DISTRIBUTOR GROUP LEVEL LABELS --->
<!--- code commented ENDED here --->

<!--- AUTO PAY LABELS --->

<cffunction name="GetAutoPayColNames"
			access="public"
			returntype="any"
			output="false"
			displayname="GetColNames"
			hint="Gets the column names.">

	<cfargument name="tblType" required="true" default="" type="string">
	<cfquery name="getColNames" datasource="#this.dsn#">
		SELECT TOP 0 *
		FROM #arguments.tblType#
	</cfquery>
	<cfreturn getColNames>
</cffunction>

<cffunction name="GetAutoPayLabels"
			access="public"
			returntype="any"
			output="false"
			displayname="GetLabels"
			hint="Gets the Labels if they exist.">
	<cfargument name="tableCode" required="true" default="" type="string">
	<cfquery name="getLabels" datasource="#this.dsn#">
		SELECT *
		FROM BB_Auto_Report_Export_Labels
		WHERE Table_Code = '#arguments.tableCode#'
		ORDER BY Sequence
	</cfquery>
	<cfreturn getLabels>
</cffunction>

<cffunction name="modifyAutoPayLabels"
			access="public"
			returntype="any"
			output="false"
			displayname="insertLabels"
			hint="Inserts new label names.">

	<cfif FORM.actionEdit EQ 0>
		<cfquery name="Deleteallpriorrecords" datasource="#this.dsn#">
			DELETE FROM BB_Auto_Report_Export_Labels
			WHERE Table_Code = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.tableCode#">
		</cfquery>
	</cfif>

	<cfloop from="1" to="#FORM.colCount#" index="i">

		<cfif i LT 10>
			<cfset activeSequence = '000' & i>
		<cfelseif i GTE 10 AND i LT 100>
			<cfset activeSequence = '00' & i>
		<cfelseif i GTE 100 AND i LT 1000>
			<cfset activeSequence = '0' & i>
		<cfelseif i GTE 1000 AND i LT 10000>
			<cfset activeSequence = i>
		</cfif>

		<cfset dbColName = evaluate("#'FORM.'&'dbColName_'&'#activeSequence#'#")>
		<cfset defaultColName = evaluate("#'FORM.'&'defaultColName_'&'#activeSequence#'#")>
		<cfset customColName = evaluate("#'FORM.'&'customColName_'&'#activeSequence#'#")>

		<cfparam name="FORM.active_#activeSequence#" default="0">
			<cfif evaluate("FORM.active_#activeSequence#") NEQ 0>
				<cfset active = 1>
			<cfelse>
				<cfset active = 0>
				<cfset inactiveSequence = '99999'>
			</cfif>


		<cfif FORM.actionEdit EQ 1>
			<cfset ID = evaluate("#'FORM.'&'ID_'&'#activeSequence#'#")>
			<cfquery name="insertLabels" datasource="#this.dsn#">
				UPDATE BB_Auto_Report_Export_Labels
				SET Default_Col_Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#defaultColName#">
					,Custom_Col_Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#customColName#">
					,Active = <cfqueryparam cfsqltype="cf_sql_bit" value="#active#">
					<cfif evaluate("FORM.active_#activeSequence#") EQ 0>
						,Sequence = <cfqueryparam cfsqltype="cf_sql_varchar" value="#inactiveSequence#">
					</cfif>
				WHERE BB_Auto_Report_Export_Labels_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ID#">
			</cfquery>
		<cfelse>
			<cfquery name="insertLabels" datasource="#this.dsn#">
				INSERT INTO BB_Auto_Report_Export_Labels
				(
					Table_Code,
					DB_Col_Name,
					Default_Col_Name,
					Custom_Col_Name,
					Active,
					Sequence,
					Deleted
				)
				VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.tableCode#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#dbColName#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#defaultColName#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#customColName#">,
					<cfqueryparam cfsqltype="cf_sql_bit" value="#active#">,
				<cfif evaluate("FORM.active_#activeSequence#") NEQ 0>
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#activeSequence#">,
				<cfelse>
					<cfqueryparam cfsqltype="cf_sql_integer" value="#inactiveSequence#">,
				</cfif>
					<cfqueryparam cfsqltype="cf_sql_bit" value="0">
				)
			</cfquery>
		</cfif>
	</cfloop>

	<cfset message = "Labels successfully updated for '" & FORM.tableName & "'">
	<cfreturn message>
</cffunction>
<!--- END:: AUTO PAY LABELS --->

<!--- CUSTOMER SETTINGS LABELS --->

<cffunction name="GetCustomerSettingsLabels"
			access="public"
			returntype="any"
			output="true"
			displayname="GetCustSettings"
			hint="Gets the customer settings table labels.">

	 <!-------------------------------------------------------------------------
    Dev Notes: D18971
      I am adding a list of columns that are excluded from the customer_settings table as they come
      from elsewhere.
      -Anand Rao/13-May-09
  --------------------------------------------------------------------------->
	<!--- <cfquery name="getCols" datasource="#this.dsn#">
		SELECT COLUMN_NAME,DATA_TYPE
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'Customer_Settings'
			-- AND COLUMN_NAME LIKE '%LABEL%' /* OLDER VERSION */
		ORDER BY COLUMN_NAME
	</cfquery>

	<cfset colList = valueList(getCols.COLUMN_NAME)> --->

	<cfquery name="qGetCustomerSettings" datasource="#this.dsn#">
		SELECT *
		FROM Customer_Settings
	</cfquery>

	<cfreturn qGetCustomerSettings>
</cffunction>

<cffunction name="modifyCustomerSettings"
			access="public"
			returntype="string"
			output="false"
			displayname="modifyCustomerSettings"
			hint="Updates Customer_Settings table">
	<cfquery name="modifyCustomerSettings" datasource="#this.dsn#">
	  UPDATE Customer_Settings
	  SET 	 <cfloop from="1" to="#FORM.loopCnt#" index="i">
	          	<cfif (NOT isDefined("FORM.data#i#"))>
	            	<cfset val= "0" />
	          	<cfelse>
	            	<cfset val="#Evaluate('FORM.data#i#')#" />
	          	</cfif>
				<cfif i NEQ 1>,</cfif>#evaluate('FORM.columnName#i#')# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#val#">
			</cfloop>
  	</cfquery>

  <!-------------------------------------------------------------------------
      Dev Notes: D18971
        This updates the left out columns from the above update
        as these columns have moved into Product section and Distributor
        sections.
        -Anand Rao/14-May-09
  --------------------------------------------------------------------------->
  	<cfquery name="modifyCustomerSettings2" datasource="#this.dsn#">
		Update 	Customer_Settings
		Set 	type_group_label_plural     = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.type_group_label_plural#">,
		        q_brand_label_plural        = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.q_brand_label_plural#">,
		        type_code_label_plural      = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.type_code_label_plural#">,
		        FamilyName_label_plural     = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.FamilyName_label_plural#">,
		        buying_group_label_plural   = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.buying_group_label_plural#">,
		        type_group_label_singular   = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Evaluate('Form.#FORM.type_group_label_singular_field#')#">,
		        q_brand_label_singular      = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Evaluate('Form.#FORM.q_brand_label_singular_field#')#">,
		        type_code_label_singular    = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Evaluate('Form.#FORM.type_code_label_singular_field#')#">,
		        FamilyName_label            = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Evaluate('Form.#FORM.FamilyName_label_field#')#">,
		        buying_group_label_singular = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Evaluate('Form.#FORM.buying_group_label_singular_field#')#">
	</cfquery>


	<cfset notice = "Label set (Customer Settings) updated successfully.">

	<cfreturn notice>

</cffunction>
<!--- END:: CUSTOMER SETTINGS LABELS --->

<!--- GENERAL LABELS --->

<cffunction name="GetGeneralLabels"
	access="public"
	returntype="query"
	output="false"
	displayname="GetGeneralLabels"
	hint="Gets all general labels">

	<cfargument name="labelDescription" required="no" default="" />
	<cfargument name="labelsID" 		required="no" default="" />

	<cfset var var_labelDescription = "" />
	<cfset var var_labelID 			= "" />
	<cfset var_labelDescription 	= arguments.labelDescription />
	<cfset var_labelID 				= arguments.labelsID />

	<cfquery name="getGeneralLabels" datasource="#this.dsn#">
		SELECT 	General_Labels_ID,
				General_Labels_Desc,
				General_Labels_Label =
				CASE
					WHEN General_Labels_Label IS NULL OR LEN(LTRIM(RTRIM(General_Labels_Label))) = 0 THEN General_Labels_Desc
					ELSE General_Labels_Label
				END
		FROM 	General_Labels
		WHERE	0 = 0
		<cfif len(trim(var_labelDescription))>
		AND		General_Labels_Desc = <cfqueryparam value="#trim(var_labelDescription)#" cfsqltype="CF_SQL_VARCHAR" />
		</cfif>
		<cfif len(trim(var_labelID))>
		AND		General_Labels_ID = <cfqueryparam value="#trim(var_labelID)#" cfsqltype="CF_SQL_INTEGER" />
		</cfif>
		ORDER BY General_Labels_Desc
	</cfquery>

	<cfreturn getGeneralLabels>

</cffunction>

<cffunction name="ModifyGeneralLabels"
	access="public"
	returntype="any"
	output="false"
	displayname="ModifyGeneralLabels"
	hint="Updates General_Labels table">

	<cfloop from="1" to="#FORM.loopCnt#" index="i">
		<cfif evaluate('FORM.labelName#i#') NEQ "">
			<cfquery name="editGeneralLabels" datasource="#this.dsn#">
				UPDATE 	General_Labels
				SET		General_Labels_Label = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.labelName#i#')#">
				WHERE 	General_Labels_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.General_Labels_ID#i#')#">
			</cfquery>
			<!--- D36632  --->
			<cfquery name="PullGeneralLabels" datasource="#this.dsn#">
					SELECT General_Labels_desc, General_Labels_Label
					FROM General_Labels
					WHERE 	General_Labels_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.General_Labels_ID#i#')#">
					AND General_Labels_desc IN ('Case Abbr Singular','Case Abbr Plural', 'Pound Abbr Singular', 'Pound Abbr Plural', 'Pound Plural','Pound Singular','Case Plural','Case Singular')
			</cfquery>
			<cfif PullGeneralLabels.recordcount>
			    <cfquery name="UpdateUOMLabels" datasource="#this.dsn#">
				    UPDATE Units_of_Measure
				    SET 	<cfif (PullGeneralLabels.General_Labels_desc EQ "Case Abbr Singular") OR (PullGeneralLabels.General_Labels_desc EQ "Pound Abbr Singular")>
				    						Abbreviation_Singular = '#PullGeneralLabels.General_Labels_Label#'
				    		<cfelseif (PullGeneralLabels.General_Labels_desc EQ "Case Abbr Plural") OR (PullGeneralLabels.General_Labels_desc EQ "Pound Abbr Plural")>
				    						Abbreviation = '#PullGeneralLabels.General_Labels_Label#'
				    		<cfelseif (PullGeneralLabels.General_Labels_desc EQ "Case Plural") OR (PullGeneralLabels.General_Labels_desc EQ "Pound Plural")>
				    					   Unit_of_Measure_Desc = '#PullGeneralLabels.General_Labels_Label#'
				    		<cfelseif (PullGeneralLabels.General_Labels_desc EQ "Case Singular") OR (PullGeneralLabels.General_Labels_desc EQ "Pound Singular")>
				    						Unit_of_Measure_Desc_singular = '#PullGeneralLabels.General_Labels_Label#'
							</cfif>
				    WHERE Unit_of_Measure_ID = <cfif (PullGeneralLabels.General_Labels_desc EQ "Case Abbr Singular") OR (PullGeneralLabels.General_Labels_desc EQ "Case Abbr Plural")  OR (PullGeneralLabels.General_Labels_desc EQ "Case Plural") OR (PullGeneralLabels.General_Labels_desc EQ "Case Singular")> 1
																		    <cfelseif (PullGeneralLabels.General_Labels_desc EQ "Pound Abbr Singular") OR (PullGeneralLabels.General_Labels_desc EQ "Pound Abbr Plural") OR (PullGeneralLabels.General_Labels_desc EQ "Pound Plural") OR (PullGeneralLabels.General_Labels_desc EQ "Pound Singular")> 2
																		    </cfif>
			    </cfquery>
				  <cfif PullGeneralLabels.General_Labels_desc EQ "Case Singular">
			     		<cfset Application.UOMCaseSingular = PullGeneralLabels.General_Labels_Label>
				  <cfelseif PullGeneralLabels.General_Labels_desc EQ "Case Plural">
			     		<cfset Application.UOMCasePlural = PullGeneralLabels.General_Labels_Label>
				  <cfelseif PullGeneralLabels.General_Labels_desc EQ "Pound Singular">
			     		<cfset Application.UOMPoundSingular = PullGeneralLabels.General_Labels_Label>
				  <cfelseif PullGeneralLabels.General_Labels_desc EQ "Pound Plural">
			     		<cfset Application.UOMPoundPlural = PullGeneralLabels.General_Labels_Label>
			     <cfelseif PullGeneralLabels.General_Labels_desc EQ "Case Abbr Plural">
			     		<cfset Application.UOMCaseAbrPlural = PullGeneralLabels.General_Labels_Label>
			     <cfelseif PullGeneralLabels.General_Labels_desc EQ "Case Abbr Singular">
			    	 	<cfset Application.UOMCaseAbrSingular = PullGeneralLabels.General_Labels_Label>
			     <cfelseif PullGeneralLabels.General_Labels_desc EQ "Pound Abbr Plural">
			     		<cfset Application.UOMPoundAbrPlural =PullGeneralLabels.General_Labels_Label>
			     <cfelseif PullGeneralLabels.General_Labels_desc EQ "Pound Abbr Singular">
			     		<cfset Application.UOMPoundAbrSingular =PullGeneralLabels.General_Labels_Label>
			     </cfif>
			</cfif>
			<!--- D36632  --->
		</cfif>
	</cfloop>

</cffunction>
<!--- END:: GENERAL LABELS --->

<!--- BillBack Lables --->
<!--- Dev Note: Drachala; D27872: Add new Billback Lables START--->
	<cffunction name="GetBillBackLabels"
	access="remote"
	returntype="query"
	output="false"
	displayname="GetBillBackLabels"
	hint="Gets all billback labels">

	<cfargument name="labelDescription" required="no" default="" />
	<cfargument name="labelsID" 		required="no" default="" />

	<cfset var var_labelDescription = "" />
	<cfset var var_labelID 			= "" />
	<cfset var_labelDescription 	= arguments.labelDescription />
	<cfset var_labelID 				= arguments.labelsID />

	<cfquery name="getBillBackLabels" datasource="#application.datasource#">
		SELECT 	Billback_Labels_ID,
				Billback_Labels_Desc,
				Billback_Labels_Label =
				CASE
					WHEN Billback_Labels_Label IS NULL OR LEN(LTRIM(RTRIM(Billback_Labels_Label))) = 0 THEN Billback_Labels_Desc
					ELSE Billback_Labels_Label
				END
		FROM 	Billback_Labels
		WHERE	0 = 0
		<cfif len(trim(var_labelDescription))>
		AND		Billback_Labels_Desc = <cfqueryparam value="#trim(var_labelDescription)#" cfsqltype="CF_SQL_VARCHAR" />
		</cfif>
		<cfif len(trim(var_labelID))>
		AND		Billback_Labels_ID = <cfqueryparam value="#trim(var_labelID)#" cfsqltype="CF_SQL_INTEGER" />
		</cfif>
	</cfquery>

	<cfreturn getBillBackLabels>

</cffunction>

<cffunction name="ModifyBillbackLabels"
	access="public"
	returntype="any"
	output="false"
	displayname="ModifyBillbackLabels"
	hint="Updates Billback_Labels table">

	<cfloop from="1" to="#FORM.loopCnt#" index="i">
		<cfif evaluate('FORM.labelName#i#') NEQ "">
			<cfquery name="editBillbackLabels" datasource="#this.dsn#">
				UPDATE 	Billback_Labels
				SET		Billback_Labels_Label = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.labelName#i#')#">
				WHERE 	Billback_Labels_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.BillBack_Labels_ID#i#')#">
			</cfquery>

			<cfset label_desc  = evaluate('form.billback_labels_desc#i#')>

			<cfif label_desc eq "Tax Type 1" OR label_desc eq "Tax Type 2" OR label_desc eq "Tax Type 3">

				<!--- -The last letter of the billback label description related to labels for tax matches with the BB_Tax_Main_ID.
				So, label description of "Tax Type 1" is equivalent to  BB_Tax_Main_ID = 1 and so on.
				--->
				<cfset taxID = Right(label_desc,1)>

				<cfquery name="editBillbackLabels" datasource="#this.dsn#">
					UPDATE 	BB_Tax_Main
					SET		Tax_Allowance_Code = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.labelName#i#')#">
					WHERE 	BB_Tax_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#taxID#">
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>

</cffunction>
<!--- Dev Note: Drachala; D27872: Add new Billback Lables END--->

<!--- DEDUCTION LABELS --->

<cffunction name="GetDeductionLabels"
	access="public"
	returntype="query"
	output="false"
	displayname="GetDeductionLabels"
	hint="Gets all deduction labels">

	<cfargument name="labelDescription" required="no" default="" />
	<cfargument name="labelsID" 		required="no" default="" />

	<cfset var var_labelDescription = "" />
	<cfset var var_labelID 			= "" />
	<cfset var_labelDescription 	= arguments.labelDescription />
	<cfset var_labelID 				= arguments.labelsID />

	<cfquery name="getDeductionLabels" datasource="#this.dsn#">
		SELECT 	Deduction_Labels_ID,
				Deduction_Labels_Desc,
				Deduction_Labels_Label =
				CASE
					WHEN Deduction_Labels_Label IS NULL OR LEN(LTRIM(RTRIM(Deduction_Labels_Label))) = 0 THEN Deduction_Labels_Desc
					ELSE Deduction_Labels_Label
				END
		FROM 	Deduction_Labels
		WHERE	0 = 0
		<cfif len(trim(var_labelDescription))>
		AND		Deduction_Labels_Desc = <cfqueryparam value="#trim(var_labelDescription)#" cfsqltype="CF_SQL_VARCHAR" />
		</cfif>
		<cfif len(trim(var_labelID))>
		AND		Deduction_Labels_ID = <cfqueryparam value="#trim(var_labelID)#" cfsqltype="CF_SQL_INTEGER" />
		</cfif>
	</cfquery>

	<cfreturn getDeductionLabels>

</cffunction>

<cffunction name="GetDeductionLabelsStruct"
	access="public"
	returntype="struct"
	output="false"
	displayname="GetDeductionLabelsStruct"
	hint="Gets all deduction labels and return a struct">

	<cfargument name="labelDescription" required="no" default="" />
	<cfargument name="labelsID" 		required="no" default="" />

	<cfset var var_stDeductionLabels 			= StructNew() />
	<cfset var var_qGetDeductionLabels 			= "" />

	<cfset var_qGetDeductionLabels = this.GetDeductionLabels(arguments.labelDescription, arguments.labelsID) />

	<cfloop query="var_qGetDeductionLabels">
		<cfset StructInsert(var_stDeductionLabels, Deduction_Labels_Desc, Deduction_Labels_Label) />
	</cfloop>

	<cfreturn var_stDeductionLabels />

</cffunction>

<cffunction name="ModifyDeductionLabels"
	access="public"
	returntype="any"
	output="false"
	displayname="ModifyDeductionLabels"
	hint="Updates General_Labels table">

	<cfloop from="1" to="#FORM.loopCnt#" index="i">
		<cfif evaluate('FORM.labelName#i#') NEQ "">
			<cfquery name="editDeductionLabels" datasource="#this.dsn#">
				UPDATE 	Deduction_Labels
				SET		Deduction_Labels_Label = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.labelName#i#')#">
				WHERE 	Deduction_Labels_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.Deduction_Labels_ID#i#')#">
			</cfquery>
		</cfif>
	</cfloop>

</cffunction>
<!--- END:: DEDUCTION LABELS --->

<!--- SETTINGS LABELS 28006--->
<!--- Group_Template: PG_Group_Type: 1 - Product;  2 - Customer; 3 - Operator --->

<cffunction name="getActiveTemplateSettingLabel" access="public" output="false" returntype="Query">
	<cfargument name="PGGroupType" type="string" required="true" />

	<cfquery name="qActiveTemplateSettingLabel" datasource="#application.datasource#">
		SELECT distinct GROUP_LEVEL_ID
		FROM Group_Template
		inner join Program_Control_Panel_Options on Program_Control_Panel_Options.First_Parent_ID = Group_Template.Template_ID and Program_Control_Panel_Options.IsDominant =1
		WHERE Group_Template.Deleted = 0
		AND Group_Template.Active = 1
		AND PG_Group_Type = <cfqueryparam value="#arguments.PGGroupType#" cfsqltype="cf_sql_varchar"/>
		AND ( Allow_In_Search <> 0  or  Allow_In_Group_Search <> 0  or  Allow_Filter <> 0)
		AND GROUP_LEVEL_ID in (
		<cfif #arguments.PGGroupType# eq 3>
			select Operator_Group_Level_ID
          			from   Operator_Group_Level
			where  Operator_Group_Level.Deleted = 0
			and Operator_Group_Level.Active =1
		</cfif>
		<cfif #arguments.PGGroupType# eq 2>
			select Distributor_Group_Level_ID
          			from   Distributor_Group_Level
			where  Distributor_Group_Level.Deleted = 0
			and Distributor_Group_Level.Active =1
		</cfif>
		<cfif #arguments.PGGroupType# eq 1>
			select Product_Group_Level_ID
          			from   Product_Group_Level
			where  Product_Group_Level.deleted = 0
			and Product_Group_Level.Active =1
		</cfif>
		)
		ORDER BY GROUP_LEVEL_ID
	</cfquery>

	<cfreturn qActiveTemplateSettingLabel>
</cffunction>

<cffunction name="getTemplatesSettingLabel" access="public" output="false" returntype="Query">
	<cfargument name="GROUP_LEVEL_ID" required="true" type="numeric" />
	<cfargument name="PGGroupType" type="string" required="true" />
	<cfquery name="qGetTemplatesSettingLabel" datasource="#application.datasource#">
		SELECT Generic_Type,Created_Type,Program_Description,First_Parent_ID
		FROM	Program_Control_Panel_Options
		WHERE 	Program_Control_Panel_Options.Deleted = 0
		AND 	Program_Control_Panel_Options.Active = 1
		AND	Program_Control_Panel_Options.IsDominant =1
		AND	First_Parent_ID in(select Template_ID
						from Group_Template
						where Group_Template.Deleted = 0
						and Group_Template.Active = 1
						and GROUP_LEVEL_ID = #arguments.GROUP_LEVEL_ID#
						and PG_Group_Type = <cfqueryparam value="#arguments.PGGroupType#" cfsqltype="cf_sql_varchar"/>)
		ORDER BY Generic_Type,Created_Type,Program_Description
	</cfquery>

	<cfreturn qGetTemplatesSettingLabel>
</cffunction>

<!--- Remove selected Grouo(s) as a filter from the template --->
<cffunction name="updateGroupTemplateSettings" access="public" output="false" returntype="void">
	<cfargument name="PGGroupType" type="numeric"  required="true" />
	<cfargument name="GroupLevelID" type="numeric" required="true"  />
	<cfargument name="firstParentIDList" type="string"  required="true" />

	<cfquery name="qGetTemplatesSettingLabel" datasource="#application.datasource#">
	UPDATE Group_Template
		SET Allow_In_Search = 0,
		Allow_In_Group_Search = 0,
		Allow_Filter = 0
	FROM Group_Template
	INNER JOIN Program_Control_Panel_Options
	ON Group_Template.Template_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
	WHERE Group_Template.PG_Group_Type = <cfqueryparam value="#arguments.PGGroupType#" cfsqltype="cf_sql_integer">
	AND Group_Template.Group_Level_ID = <cfqueryparam value="#arguments.GroupLevelID#" cfsqltype="cf_sql_integer">
	AND Program_Control_Panel_Options.First_Parent_ID IN (<cfqueryparam value="#arguments.firstParentIDList#" cfsqltype="cf_sql_integer" list="true">)
	</cfquery>

</cffunction>
<!--- END:: SETTINGS LABELS --->
<!--- 29856	labels for Fixed Price, Rebate, Lump Sum, Growth START --->

<cffunction name="getDiscountTypes" access="public" returntype="Query">
	<cfquery name="qdiscounttypes" datasource="#application.datasource#" >
		SELECT *
		FROM Discount_Type
		WHERE Discount_Type_ID IN(1,2,3,4)
		AND Deleted = 0
		ORDER BY Discount_Type_Desc
	</cfquery>
	<cfreturn qdiscounttypes>
</cffunction>

<cffunction name="saveDiscountTypes" access="public" returmtype="any" output="false" hint="Updates Deduction Types">
	<cfloop from="1" to="#FORM.loopCnt#" index="i">
		<cfif evaluate('FORM.discountTypeName_#i#') NEQ "">
		<cfquery name="qdiscounttypes" datasource="#application.datasource#" >
			UPDATE Discount_Type
			SET Discount_Type_Desc = <cfqueryparam value="#evaluate('FORM.discountTypeName_#i#')#" cfsqltype="cf_sql_varchar">
			WHERE Discount_Type_ID = <cfqueryparam value="#evaluate('FORM.discountTypeID_#i#')#"   cfsqltype="cf_sql_integer" >
		</cfquery>
		</cfif>
	</cfloop>
</cffunction>
<!--- 29856	labels for Fixed Price, Rebate, Lump Sum, Growth END --->

<!--- 47665 Dashboard LABELS START--->
<cffunction name="GetDashboardLabels"
	access="public"
	returntype="query"
	output="false"
	displayname="GetDashboardLabels"
	hint="Gets all Dashboard labels">

	<cfargument name="labelDescription" required="no" default="" />
	<cfargument name="labelsID" 	required="no" default="" />

	<cfset var var_labelDescription = "" />
	<cfset var var_labelID 			= "" />
	<cfset var_labelDescription 	= arguments.labelDescription />
	<cfset var_labelID 		= arguments.labelsID />

	<cfquery name="qDashboardLabels" datasource="#this.dsn#">
		SELECT 	Dashboard_Labels_ID,
				Dashboard_Labels_Desc,
				Dashboard_Labels_Singular =
				CASE
					WHEN Dashboard_Labels_Singular IS NULL OR LEN(LTRIM(RTRIM(Dashboard_Labels_Singular))) = 0 THEN Dashboard_Labels_Desc
					ELSE Dashboard_Labels_Singular
				END
				,Dashboard_Labels_Plural =
				CASE
					WHEN Dashboard_Labels_Plural IS NULL OR LEN(LTRIM(RTRIM(Dashboard_Labels_Plural))) = 0 THEN Dashboard_Labels_Desc
					ELSE Dashboard_Labels_Plural
				END
		FROM 	Dashboard_Labels
		WHERE	0 = 0
		<cfif len(trim(var_labelDescription))>
		AND		Dashboard_Labels_Desc = <cfqueryparam value="#trim(var_labelDescription)#" cfsqltype="CF_SQL_VARCHAR" />
		</cfif>
		<cfif len(trim(var_labelID))>
		AND		Dashboard_Labels_ID = <cfqueryparam value="#trim(var_labelID)#" cfsqltype="CF_SQL_INTEGER" />
		</cfif>
	</cfquery>

	<cfreturn qDashboardLabels>
</cffunction>

<cffunction name="ModifyDashboardLabels"
	access="public"
	returntype="any"
	output="false"
	displayname="ModifyDashboardLabels"
	hint="Updates Dashboard_Labels table">

	<cfloop from="1" to="#FORM.loopCnt#" index="i">
		<cfif evaluate('FORM.Dashboard_Labels_Singular_#i#') NEQ "">
			<cfquery name="editDashboardLabels" datasource="#this.dsn#">
				UPDATE 	Dashboard_Labels
				SET	 Dashboard_Labels_Singular = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.Dashboard_Labels_Singular_#i#')#">
					,Dashboard_Labels_Plural = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.Dashboard_Labels_Plural_#i#')#">
				WHERE 	Dashboard_Labels_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.Dashboard_Labels_ID_#i#')#">
			</cfquery>
		</cfif>
	</cfloop>

</cffunction>
<!--- 47665 END:: Dashboard LABELS --->

<!--- 63670 Program Letters LABELS START--->
<cffunction name="GetProgramLettersLabels"
	access="public"
	returntype="query"
	output="false"
	displayname="GetProgramLettersLabels"
	hint="Gets all Program Letters labels">

	<cfargument name="labelDescription" required="no" default="" />
	<cfargument name="labelsID" 	required="no" default="" />

	<cfset var var_labelDescription = "" />
	<cfset var var_labelID 			= "" />
	<cfset var_labelDescription 	= arguments.labelDescription />
	<cfset var_labelID 		= arguments.labelsID />

	<cfquery name="qProgramLettersLabels" datasource="#this.dsn#">
		SELECT 	Program_Letters_Labels_ID,
				Program_Letters_Labels_Desc,
				Program_Letters_Labels_Label =
				CASE
					WHEN Program_Letters_Labels_Label IS NULL OR LEN(LTRIM(RTRIM(Program_Letters_Labels_Label))) = 0 THEN Program_Letters_Labels_Desc
					ELSE Program_Letters_Labels_Label
				END
		FROM 	Program_Letters_Labels
		WHERE	0 = 0
		<cfif len(trim(var_labelDescription))>
		AND		Program_Letters_Labels_Desc = <cfqueryparam value="#trim(var_labelDescription)#" cfsqltype="CF_SQL_VARCHAR" />
		</cfif>
		<cfif len(trim(var_labelID))>
		AND		Program_Letters_Labels_ID = <cfqueryparam value="#trim(var_labelID)#" cfsqltype="CF_SQL_INTEGER" />
		</cfif>
		ORDER BY Program_Letters_Labels_Desc
	</cfquery>

	<cfreturn qProgramLettersLabels>
</cffunction>

<cffunction name="ModifyProgramLettersLabels"
	access="public"
	returntype="any"
	output="false"
	displayname="ModifyProgramLettersLabels"
	hint="Updates Program_Letters_Labels table">

	<cfloop from="1" to="#FORM.loopCnt#" index="i">
		<cfif evaluate('FORM.labelName#i#') NEQ "">
			<cfquery name="editProgramLettersLabels" datasource="#this.dsn#">
				UPDATE 	Program_Letters_Labels
				SET	 Program_Letters_Labels_Label = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.labelName#i#')#">
				WHERE 	Program_Letters_Labels_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('FORM.Program_Letters_Labels_ID#i#')#">
			</cfquery>
		</cfif>
	</cfloop>

</cffunction>
<!--- 63670 END:: Program Letters LABELS --->

<!--- 64600: Planner Labels START--->
<cffunction name="GetPlannerLabels"
	access="public"
	returntype="query"
	output="false"
	displayname="GetPlannerLabels"
	hint="Gets all Planner labels">

	<cfargument name="labelDescription" required="no" default="" />
	<cfargument name="labelsID" 	required="no" default="" />

	<cfquery name="local.qPlannerLabels" datasource="#this.dsn#">
		SELECT 	Planner_Labels_ID,
				Planner_Labels_Desc,
				Planner_Labels_Singular =
				CASE
					WHEN Planner_Labels_Singular IS NULL OR LEN(LTRIM(RTRIM(Planner_Labels_Singular))) = 0 THEN Planner_Labels_Desc
					ELSE Planner_Labels_Singular
				END
				,Planner_Labels_Plural =
				CASE
					WHEN Planner_Labels_Plural IS NULL OR LEN(LTRIM(RTRIM(Planner_Labels_Plural))) = 0 THEN Planner_Labels_Desc
					ELSE Planner_Labels_Plural
				END
		FROM 	Planner_Labels
		WHERE	0 = 0
		<cfif len(trim(arguments.labelDescription))>
		AND		Planner_Labels_Desc = <cfqueryparam value="#trim(arguments.labelDescription)#" cfsqltype="CF_SQL_VARCHAR" />
		</cfif>
		<cfif len(trim(arguments.labelsID))>
		AND		Planner_Labels_ID = <cfqueryparam value="#trim(arguments.labelsID)#" cfsqltype="CF_SQL_INTEGER" />
		</cfif>
	</cfquery>

	<cfreturn qPlannerLabels>
</cffunction>

<cffunction name="ModifyPlannerLabels"
	access="public"
	returntype="any"
	output="false"
	displayname="ModifyPlannerLabels"
	hint="Updates Planner_Labels table">

	<cfloop from="1" to="#FORM.loopCnt#" index="i">
		<cfif FORM["Planner_Labels_Singular_#i#"] NEQ "">

			<cfset local.plannerLabelSingular = FORM["Planner_Labels_Singular_#i#"] />
			<cfset local.plannerLabelPlural   = FORM["Planner_Labels_Plural_#i#"] />
			<cfset local.plannerLabelID       = FORM["Planner_Labels_ID_#i#"] />

			<cfquery name="local.editPlannerLabels" datasource="#this.dsn#">
				UPDATE 	Planner_Labels
				SET	 	Planner_Labels_Singular = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.plannerLabelSingular#">,
						Planner_Labels_Plural = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.plannerLabelPlural#">
				WHERE 	Planner_Labels_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.plannerLabelID#">
			</cfquery>
		</cfif>
	</cfloop>

</cffunction>
<!--- 64600 END:: Planner Labels --->

<cffunction name="plannerLabels" returntype="query" output="false">
	<cfscript>
		local.qLabels      = GetPlannerLabels();
		local.column_names = [];
		local.bsa_terms    = valueList( local.qLabels.planner_labels_desc );   // list of all bsa internal terms (e.g. operator, distributor)
	</cfscript>

	<!--- create plural columns, singular columns & add to array --->
	<cfloop list="#local.bsa_terms#" index="local.bsa_term">
	    <cfscript>
	    	// remove white spaces, colons
	        local.cleaned_name = replace( replace(local.bsa_term, " ", "_", "all"), ":", "_", "all" );

	        arrayAppend(local.column_names, local.cleaned_name & "_plural");
	        arrayAppend(local.column_names, local.cleaned_name & "_singular");
	    </cfscript>
	</cfloop>

	<!--- create query with plural/singular columns --->
	<cfset local.query = queryNew( arrayToList( local.column_names ) )>
	<cfset queryAddRow( local.query )>

	<!--- gather plural/singular values --->
	<cfoutput query="local.qLabels">
	    <cfscript>
	        local.cleaned_name = replace( replace(local.qLabels.planner_labels_desc, " ", "_", "all"), ":", "_", "all" );
	        
	        querySetCell( local.query, local.cleaned_name & "_plural", local.qLabels.Planner_Labels_Plural );
	        querySetCell( local.query, local.cleaned_name & "_singular", local.qLabels.Planner_Labels_Singular );
	    </cfscript>
	</cfoutput>

	<cfreturn local.query>
</cffunction>
</cfcomponent>