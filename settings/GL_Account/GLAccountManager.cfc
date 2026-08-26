<cfcomponent displayname="GLAccountManager" hint="GL Account Manager" extends="components.Base">

	<cffunction name="init" returntype="GLAccountManager" output="false">
		<cfreturn this />
	</cffunction>

	<cffunction name="getComp" output="false" returntype="query">
		<cfargument name="GL_Account_ID" type="numeric" required="false" default="0" />	
		
		<cfset useLakebaseForqGetGLAccountInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_account")>
<cfif useLakebaseForqGetGLAccountInfo>
	<cftry>
		<cfset qGetGLAccountInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_account", {
				"gl_account_id" = "eq.#arguments.GL_Account_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetGLAccountInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetGLAccountInfo>
<cfquery name="qGetGLAccountInfo" datasource="#application.datasource#">
		SELECT *
		FROM GL_Account
		WHERE GL_Account_ID = '#arguments.GL_Account_ID#'
		</cfquery>
</cfif>
		
		<cfreturn qGetGLAccountInfo />
		
	</cffunction>
	
	<cffunction name="getActive" output="false" returntype="query">
		<cfargument name="sortBy" type="string" required="true" />
		<cfset var GetActiveGLs = "" />
		
		<cfquery name="GetActiveGLs" datasource="#application.datasource#">
		SELECT *
		FROM GL_Account
		WHERE Deleted = 0
		AND Is_Active = 1
		Order By #arguments.sortBy#
		</cfquery>
		
		<cfreturn GetActiveGLs />
		
	</cffunction>
	
	<cffunction name="getInActive" output="false" returntype="query">
		<cfargument name="sortBy" type="string" required="true" />
		<cfset var GetInActiveGLs = "" />
		
		<cfquery name="GetInActiveGLs" datasource="#application.datasource#">
		SELECT *
		FROM GL_Account
		WHERE Deleted = 0
		AND Is_Active = 0
		Order By #arguments.sortBy#
		</cfquery>
		
		<cfreturn GetInActiveGLs />
		
	</cffunction>
	
	<cffunction name="addComp" output="false" returntype="string">
		<cfargument name="GL_Account" type="string" required="false" default="" />	
		<cfargument name="GL_Account_Desc" type="string" required="false" default="" />
		<cfargument name="Start_Date" type="date" required="false" default="now()" />
		<cfargument name="End_Date" type="date" required="false" default="now()" />
		<cfargument name="User_ID" type="string" required="false" default="0" />
		<cfargument name="discountComponents" type="string" required="false" default="" />

		<cfquery name="InsertGL" datasource="#application.datasource#">
			INSERT INTO GL_Account
			(
				GL_Account,
				GL_Account_Desc,
				Start_Date,
				End_Date,
				Is_Active,
				Created_By,
				Created_Date,
				Last_Updated_By,
				Last_Updated_Date
			)
			VALUES
			(
				<cfqueryparam value="#arguments.GL_Account#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#arguments.GL_Account_Desc#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#arguments.Start_Date#" cfsqltype="CF_SQL_DATE">,
				<cfqueryparam value="#arguments.End_Date#" cfsqltype="CF_SQL_DATE">,
				1,
				<cfqueryparam value="#arguments.User_ID#" cfsqltype="CF_SQL_NVARCHAR">,
				getdate(),
				<cfqueryparam value="#arguments.User_ID#" cfsqltype="CF_SQL_NVARCHAR">,
				getdate()
			)

			SELECT @@Identity GL_Account_ID
		</cfquery>

		/* Delete and insert components selected in GL_Component_Mapping table */
		<cfset temp = this.UpdateGLComponent(InsertGL.GL_Account_ID, arguments.discountComponents) />
		
		<cfreturn InsertGL.GL_Account_ID />
		
	</cffunction>
	
	<cffunction name="editComp" output="false" returntype="string">
		
		<cfargument name="GL_Account_ID" type="numeric" required="false" default="" />	
		<cfargument name="GL_Account" type="string" required="false" default="" />	
		<cfargument name="GL_Account_Desc" type="string" required="false" default="" />
		<cfargument name="Start_Date" type="date" required="false" default="now()" />
		<cfargument name="End_Date" type="date" required="false" default="now()" />
		<cfargument name="User_ID" type="string" required="false" default="0" />	
		<cfargument name="discountComponents" type="string" required="false" default="" />

		<cfquery name="Update_Components" datasource="#application.datasource#">
			UPDATE GL_Account
			SET GL_Account = <cfqueryparam value="#arguments.GL_Account#" cfsqltype="CF_SQL_VARCHAR">,
				GL_Account_Desc = <cfqueryparam value="#arguments.GL_Account_Desc#" cfsqltype="CF_SQL_VARCHAR">,
				Start_Date = <cfqueryparam value="#arguments.Start_Date#" cfsqltype="CF_SQL_DATE">,
				End_Date = <cfqueryparam value="#arguments.End_Date#" cfsqltype="CF_SQL_DATE">,
				Last_Updated_By = <cfqueryparam value="#arguments.User_ID#" cfsqltype="CF_SQL_NVARCHAR">,
				Last_Updated_Date = getdate()
			WHERE Gl_Account_ID = <cfqueryparam value="#arguments.GL_Account_ID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		/* Delete and insert components selected in GL_Component_Mapping table */
		<cfset temp = this.UpdateGLComponent(arguments.Gl_Account_ID, arguments.discountComponents) />		

		<cfreturn arguments.GL_Account_ID />
		
	</cffunction>

	<cffunction name="UpdateGLComponent" output="false" returntype="void">

		<cfargument name="GL_Account_ID" type="numeric"  required="true" />
		<cfargument name="discountComponents" type="string" required="false" default="" />

		<!--- if components are selected add in GL_Component_Mapping table --->
		<cfquery name="DeleteGLComponent" datasource="#application.datasource#">
			DELETE FROM GL_Component_Mapping
			WHERE GL_Account_ID = <cfqueryparam value="#arguments.GL_Account_ID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfif len(arguments.discountComponents)>			
			<cfloop list="#arguments.discountComponents#" index="discountComponentId" delimiters="," >
				<cfquery name="InsertGLComponent" datasource="#application.datasource#">
					INSERT INTO GL_Component_Mapping
					(
						GL_Account_ID,
						Discount_Type_ID,
						Component_Name_ID
					)
					VALUES
					(
						<cfqueryparam value="#arguments.GL_Account_ID#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#listFirst(discountComponentId, '-')#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#listLast(discountComponentId, '-')#" cfsqltype="CF_SQL_VARCHAR">
					)		
				</cfquery>
			</cfloop>
		</cfif>

	</cffunction>

	
	<cffunction name="activate" output="false" returntype="string">
		
		<cfargument name="GL_Account_ID" type="string" required="false" default="" />	
		<cfargument name="User_ID" type="string" required="false" default="0" />	
		
		<cfquery name="Activate_GL" datasource="#application.datasource#">
		UPDATE GL_Account
		SET Is_Active = 1,
			Activated_Date = getdate(),
			Activated_By = <cfqueryparam value="#request.accessstructure.user_id#" cfsqltype="CF_SQL_VARCHAR">,
			Last_Updated_By = <cfqueryparam value="#request.accessstructure.user_id#" cfsqltype="CF_SQL_VARCHAR">,
			Last_Updated_Date = getdate()
		WHERE Gl_Account_ID IN (#arguments.GL_Account_ID#)
		</cfquery>
				
		<cfreturn arguments.GL_Account_ID />
		
	</cffunction>
	
	<cffunction name="deactivate" output="false" returntype="string">
		
		<cfargument name="GL_Account_ID" type="string" required="false" default="" />	
		<cfargument name="User_ID" type="string" required="false" default="0" />	
		
		<cfquery name="Activate_GL" datasource="#application.datasource#">
		UPDATE GL_Account
		SET Is_Active = 0,
			Last_Updated_Date = getdate(),
			Last_Updated_By = <cfqueryparam value="#request.accessstructure.user_id#" cfsqltype="CF_SQL_VARCHAR">
		WHERE Gl_Account_ID IN (#arguments.GL_Account_ID#)
		</cfquery>		
				
		<cfreturn arguments.GL_Account_ID />
		
	</cffunction>
	

	<cffunction name="getGLAccountComponents" output="false" returntype="query">
		<cfargument name="GL_Account_ID" type="string" required="false" default="0" />
		<cfargument name="discountTypeList" type="string" required="false" default="1,2,3,4" />

		<cfquery name="qGetGLAccountComponents" datasource="#application.datasource#">
		 DECLARE @Tmp_All_GL_Components TABLE (
			Component_ID INT,
			Component_Name NVARCHAR(100),
			External_ID NVARCHAR(100),
			Discount_Type_ID INT,
			Discount_Type_Desc NVARCHAR(100),
			Selected INT
			)

		 	/* loop thru discount types and get selected and non selected components */
			<cfloop list="#arguments.discountTypeList#" index="discountTypeId">	
					<cfswitch expression="#discountTypeId#">
						
						<cfcase value="1"> <!------ Fixed ----->
								INSERT INTO @Tmp_All_GL_Components (Component_ID, Component_Name, External_ID, Discount_Type_ID, Discount_Type_Desc, Selected)
								SELECT Program_Fixed_Component_Name_ID Component_ID,
									Program_Fixed_Component_Name Component_Name,
									External_ID,
									DT.Discount_Type_ID,
									DT.Discount_Type_Desc,
									ISNULL(isNumeric(GLCM.GL_Component_Mapping_ID), 0)
								FROM Program_Fixed_Component_Name Components
								INNER JOIN Discount_Type DT
									ON DT.Discount_Type_ID = <cfqueryparam value="#discountTypeId#" cfsqltype="cf_sql_integer" />
									AND DT.Deleted = 0
								LEFT JOIN GL_Component_Mapping GLCM
									ON Components.Program_Fixed_Component_Name_ID = GLCM.Component_Name_ID
										AND GLCM.Discount_Type_ID =  <cfqueryparam value="#discountTypeId#" cfsqltype="cf_sql_integer" />
										AND GLCM.GL_Account_ID = <cfqueryparam value="#arguments.GL_Account_ID#" cfsqltype="cf_sql_integer" />
								WHERE Components.Deleted = 0
								ORDER BY Program_Fixed_Component_Name  ASC --D45619
						</cfcase>

						<cfcase value="2"> <!------ Rebate ----->
							INSERT INTO @Tmp_All_GL_Components (Component_ID, Component_Name, External_ID, Discount_Type_ID, Discount_Type_Desc, Selected)
							SELECT Program_Rebates_Component_Name_ID Component_ID,
								Program_Rebates_Component_Name Component_Name,
								External_ID,
								DT.Discount_Type_ID,
								DT.Discount_Type_Desc,
								ISNULL(isNumeric(GLCM.GL_Component_Mapping_ID), 0)
							FROM Program_Rebates_Component_Name Components
							INNER JOIN Discount_Type DT
								ON DT.Discount_Type_ID = <cfqueryparam value="#discountTypeId#" cfsqltype="cf_sql_integer" />
								AND DT.Deleted = 0
							LEFT JOIN GL_Component_Mapping GLCM
								ON Components.Program_Rebates_Component_Name_ID = GLCM.Component_Name_ID
									AND GLCM.Discount_Type_ID =  <cfqueryparam value="#discountTypeId#" cfsqltype="cf_sql_integer" />
									AND GLCM.GL_Account_ID = <cfqueryparam value="#arguments.GL_Account_ID#" cfsqltype="cf_sql_integer" />
							WHERE Components.Deleted = 0
							ORDER BY Program_Rebates_Component_Name ASC --D45619
						</cfcase>

						<cfcase value="3"> <!------ Lump Sum ----->
							INSERT INTO @Tmp_All_GL_Components (Component_ID, Component_Name, External_ID, Discount_Type_ID, Discount_Type_Desc, Selected)
							SELECT Program_Lump_Sum_Name_ID Component_ID,
								Program_Lump_Sum_Name Component_Name,
								External_ID,
								DT.Discount_Type_ID,
								DT.Discount_Type_Desc,
								ISNULL(isNumeric(GLCM.GL_Component_Mapping_ID), 0)
							FROM Program_Lump_Sum_Name Components
							INNER JOIN Discount_Type DT
								ON DT.Discount_Type_ID = <cfqueryparam value="#discountTypeId#" cfsqltype="cf_sql_integer" />
								AND DT.Deleted = 0
							LEFT JOIN GL_Component_Mapping GLCM
								ON Components.Program_Lump_Sum_Name_ID = GLCM.Component_Name_ID
									AND GLCM.Discount_Type_ID =  <cfqueryparam value="#discountTypeId#" cfsqltype="cf_sql_integer" />
									AND GLCM.GL_Account_ID = <cfqueryparam value="#arguments.GL_Account_ID#" cfsqltype="cf_sql_integer" />
							WHERE Components.Deleted = 0
							ORDER BY Program_Lump_Sum_Name ASC --D45619
						</cfcase>

						<cfcase value="4"> <!------ Growth ----->
							INSERT INTO @Tmp_All_GL_Components (Component_ID, Component_Name, External_ID, Discount_Type_ID, Discount_Type_Desc, Selected)
							SELECT Program_Growth_Components_Name_ID Component_ID,
								Program_Growth_Components_Name Component_Name,
								External_ID,
								DT.Discount_Type_ID,
								DT.Discount_Type_Desc,
								ISNULL(isNumeric(GLCM.GL_Component_Mapping_ID), 0)
							FROM Program_Growth_Components_Name Components
							INNER JOIN Discount_Type DT
								ON DT.Discount_Type_ID = <cfqueryparam value="#discountTypeId#" cfsqltype="cf_sql_integer" />
								AND DT.Deleted = 0
							LEFT JOIN GL_Component_Mapping GLCM
								ON Components.Program_Growth_Components_Name_ID = GLCM.Component_Name_ID
									AND GLCM.Discount_Type_ID =  <cfqueryparam value="#discountTypeId#" cfsqltype="cf_sql_integer" />
									AND GLCM.GL_Account_ID = <cfqueryparam value="#arguments.GL_Account_ID#" cfsqltype="cf_sql_integer" />
							WHERE Components.Deleted = 0
							ORDER BY Program_Growth_Components_Name ASC --D45619
						</cfcase>
					</cfswitch>			
			</cfloop>

			SELECT Component_ID,
						 Component_Name,
						 External_ID,
						 Discount_Type_ID,
						 Discount_Type_Desc,
						 Selected
			FROM @Tmp_All_GL_Components
			ORDER BY Discount_Type_ID
		</cfquery>
		
		<cfreturn qGetGLAccountComponents />
	</cffunction>
	
</cfcomponent>	
