<cfcomponent hint="ApprovalGroupManager" extends="components.Base">

	<cfset this.productGroupAttributeManager 				= CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />

	<cfset this.approvalGroupType = StructNew() />
	<cfset this.approvalGroupType.prodHierLevel 		= 0>
	<cfset this.approvalGroupType.tableName 			= "">
	<cfset this.approvalGroupType.IDField 				= "">
	<cfset this.approvalGroupType.NameField 			= "">
	<cfset this.approvalGroupType.Label 				= "">
	<cfset this.approvalGroupType.productGroupIDField	= "">
	<cfset this.approvalGroupType.groupType				= "">
	<cfset this.approvalGroupType.groupLevelId			= 0>
	<cfset this.approvalGroupType.programGroupsViewName	= "">

 	<cfscript>
		this.DataValidationInfo = StructNew();
		this.DataValidationInfo.ValidData = ArrayNew(1);
		this.DataValidationInfo.InValidData = ArrayNew(1);
		this.DataValidationInfo.DuplicateData = ArrayNew(1);
		this.DataValidationInfo.ValidListData = ArrayNew(1);
	</cfscript>
	<cffunction name="init" output="false" returntype="components.settings.ApprovalGroupManager">

		<cfreturn this />

	</cffunction>

	<cffunction name="getGroupTypeInfo" output="false" returntype="struct">
		<cfargument name="productGroupLevelId" type="numeric" required="false" default="0" />

		<cfif arguments.productGroupLevelId EQ 0><!------ If nothing is passed in, get the approval group type from customer settings ----->
			<cfset this.approvalGroupType.groupType			= application.returned_customer_setting.approval_on_type_code>

			<cfset this.approvalGroupType					= this.productGroupAttributeManager.getGroupTypeInfo(approvalLevelTypeId = this.approvalGroupType.groupType) />
		<cfelse>
			<cfset this.approvalGroupType					= this.productGroupAttributeManager.getGroupTypeInfo(groupLevelId = arguments.productGroupLevelId) />
		</cfif>

		<cfreturn this.approvalGroupType/>

	</cffunction>

	<cffunction name="getGroupAccessValues" output="false" returntype="query">

		<cfargument name="groupId" type="string" required="false" default="" />
		<cfargument name="profileId" type="string" required="false" default="" />

		<cfif this.approvalGroupType.tableName EQ "">
			<cfset this.getGroupTypeInfo() />
		</cfif>

		<cfquery name="qGetGroupAccessValues" datasource="#application.datasource#">
			SELECT	#this.approvalGroupType.NameField# As Group_Name, #this.approvalGroupType.IDField# As Group_ID,
					Group_Level_Access_Rights.Group_Approval_Rights_ID Group_Level_Access_Rights_ID,
					Group_Level_Access_Rights.User_Profile_Id,
					Group_Level_Access_Rights.Group_ID_Approval Group_Approve,
					Group_Level_Access_Rights.Group_ID_Margin Group_Approve_Margin,
					Group_Level_Access_Rights.Group_ID_Margin_Operator Group_ID_Margin_Operator,
					Group_Level_Access_Rights.Group_ID_Spend_Dollar Group_Approve_Spend,
					Group_Level_Access_Rights.Group_ID_List_Price Group_ID_List_Price
			FROM	#this.approvalGroupType.tableName#
					LEFT JOIN Group_Approval_Rights Group_Level_Access_Rights
					ON
					Group_Level_Access_Rights.Deleted = 0
					AND Group_Level_Access_Rights.Group_ID = #this.approvalGroupType.tableName#.#this.approvalGroupType.IDField#
					AND Group_Level_Access_Rights.Group_Type = #this.approvalGroupType.groupType#
					<cfif arguments.profileId NEQ "">
					AND Group_Level_Access_Rights.User_Profile_Id = #arguments.profileId#
					<cfelse>AND 1=2
					</cfif>
			WHERE	0 = 0
					<cfif this.approvalGroupType.prodHierLevel GT 0>
					AND Product_Hierarchy_Level = #this.approvalGroupType.prodHierLevel#
					</cfif>
					<cfif arguments.groupId NEQ "">
					AND #this.approvalGroupType.IDField# = '#arguments.groupId#'
					</cfif>
					AND #this.approvalGroupType.tableName#.Deleted = 0
			Order By #this.approvalGroupType.NameField#
		</cfquery>

		<cfreturn qGetGroupAccessValues>

	</cffunction>

	<cffunction name="getApprovalGroups" output="false" returntype="query">

		<cfargument name="groupList" required="false" type="string" default="">
		<cfargument name="ExcludeItemID" required="false" type="string" default="">
		<cfargument name="IncludeIOPGFlag" required="false" default="0">
		<cfargument name="BusinessSegmentId" required="false" default="0" >

		<cfif this.approvalGroupType.tableName EQ "">
			<cfset this.getGroupTypeInfo() />
		</cfif>

			<cfset qGetApprovalGroups = this.productGroupAttributeManager.getProductGroupValues(
																	productGroupType = this.approvalGroupType,
																	groupList = arguments.groupList,
																	ExcludeItemID = arguments.ExcludeItemID,
																	IncludeIOPGFlag = arguments.IncludeIOPGFlag,
                                                                    BusinessSegmentId = arguments.BusinessSegmentId
																	) />

		<cfreturn qGetApprovalGroups>

	</cffunction>

	<cffunction name="getTemplateAllowApprovalGroups" output="false" returntype="query">

		<cfargument name="templateId" required="true" type="numeric">

		<cfset useLakebaseForqGetTemplateAllowApprovalGroups = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("template_allow_approval_group")>
<cfif useLakebaseForqGetTemplateAllowApprovalGroups>
	<cftry>
		<cfset qGetTemplateAllowApprovalGroups = application.oLakebase.toQuery(
			application.oLakebase.selectRows("template_allow_approval_group", {
				"deleted" = "eq.0",
				"program_type_id" = "eq.#arguments.templateId#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetTemplateAllowApprovalGroups = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetTemplateAllowApprovalGroups>
<cfquery name="qGetTemplateAllowApprovalGroups" datasource="#application.datasource#">
			SELECT	*
			FROM	Template_Allow_Approval_Group
			WHERE	Template_Allow_Approval_Group.Deleted = 0
					AND Template_Allow_Approval_Group.Program_Type_ID = #arguments.templateId#
		</cfquery>
</cfif>

		<cfreturn qGetTemplateAllowApprovalGroups>

	</cffunction>

	<cffunction name="getApprovalGroupsAccessRFAPrograms" output="true" returntype="string">

		<cfargument name="profileId" required="true" type="numeric">

		<cfsavecontent variable="returnValue">
		SELECT	DISTINCT #this.approvalGroupType.programGroupsViewName#.Contract_Main_ID
		FROM	#this.approvalGroupType.programGroupsViewName#
		WHERE	User_Profile_Id = #arguments.profileId#
		</cfsavecontent>

		<cfreturn returnValue>

	</cffunction>

	<cffunction name="getApprovalGroupsAccessRFAProgramsForProfile" output="true" returntype="string">

		<cfargument name="programId" required="true" type="numeric">

		<cfsavecontent variable="returnValue">
		SELECT	DISTINCT User_Profile_Id
		FROM	#this.approvalGroupType.programGroupsViewName#
		WHERE	Contract_Main_ID = #arguments.programId#
		</cfsavecontent>

		<cfreturn returnValue>

	</cffunction>


		<cffunction name="GetProfileAllowApprovalGroups" output="false" returntype="query">

		<cfargument name="profile_id" required="true" type="numeric">

		<cfset useLakebaseForqGetProfileAllowApprovalGroups = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("group_approval_rights")>
<cfif useLakebaseForqGetProfileAllowApprovalGroups>
	<cftry>
		<cfset qGetProfileAllowApprovalGroups = application.oLakebase.toQuery(
			application.oLakebase.selectRows("group_approval_rights", {
				"deleted" = "eq.0",
				"user_profile_id" = "eq.#arguments.profile_id#",
				"group_id_approval" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProfileAllowApprovalGroups = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProfileAllowApprovalGroups>
<cfquery name="qGetProfileAllowApprovalGroups" datasource="#application.datasource#">
			SELECT	*
			FROM	Group_Approval_Rights
			WHERE	Group_Approval_Rights.Deleted = 0
					AND Group_Approval_Rights.user_profile_id = #arguments.profile_id#
					AND Group_Approval_Rights.Group_ID_Approval = 0
		</cfquery>
</cfif>

		<cfreturn qGetProfileAllowApprovalGroups>

	</cffunction>


	<cffunction name="fnSet" access="public">
		<cfargument name="Category" 	type="string" required="true">
		<cfargument name="Object" 		type="string" required="true">
		<cfswitch expression="#arguments.Category#">
			<cfcase value="Invalid">
				<cfscript>
					ArrayAppend(this.DataValidationInfo.InValidData, Object);
				</cfscript>
			</cfcase>
			<cfcase value="Duplicate">
				<cfscript>
					ArrayAppend(this.DataValidationInfo.DuplicateData, Object);
				</cfscript>
			</cfcase>
			<cfcase value="Valid">
				<cfscript>
					ArrayAppend(this.DataValidationInfo.ValidData, Object);
				</cfscript>
			</cfcase>
			<cfcase value="ValidList">
				<cfscript>
					ArrayAppend(this.DataValidationInfo.ValidListData, Object);
				</cfscript>
			</cfcase>
		</cfswitch>
	</cffunction>

	<cffunction name="fnGet" access="public" returntype="any">
	<cfargument name="retVal" 	type="string" required="true">
		<cfif arguments.retVal EQ 1>
			<cfreturn this.DataValidationInfo.ValidData />
		<cfelse>
			<cfreturn this.DataValidationInfo />
		</cfif>
	</cffunction>

</cfcomponent>

