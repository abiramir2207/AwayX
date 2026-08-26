<cfcomponent>
	
	<cfset this.groups = ArrayNew(1) />
	<cfset this.lProductIds = "" />
	<cfset this.discountType = "" />
	
	<cffunction name="init" output="false">
	
		<cfreturn this />
		
	</cffunction>
	
	<!--- groups setter --->
	<cffunction name="setGroups" access="public" output="false">
		<cfargument name="groups" required="true" default="" type="components.products.Group.Group" />
		<cfset ArrayAppend(this.groups, arguments.groups) />
	</cffunction>
	<!--- groups getter --->
	<cffunction name="getGroups" access="public" output="false">
		<cfargument name="element" required="false" default="" />
		<!---if element was passed then get for that element--->
		<cfif trim(arguments.element) neq "">
			<cfreturn this.groups[arguments.element] />
		<cfelse>
			<cfreturn this.groups />
		</cfif>
		
	</cffunction>
	
	<!--- lProductIds setter --->
	<cffunction name="setLProductIds" access="public" output="false">
		<cfargument name="lProductIds" required="true" default="" />
		<cfset this.lProductIds = arguments.lProductIds />
	</cffunction>
	<!--- lProductIds getter --->
	<cffunction name="getLProductIds" access="public" output="false">
		<cfreturn this.lProductIds />
	</cffunction>
	
	<!--- discountType setter --->
	<cffunction name="setDiscountType" access="public" output="false">
		<cfargument name="discountType" required="true" default="" />
		<cfset this.discountType = arguments.discountType />
	</cffunction>
	<!--- discountType getter --->
	<cffunction name="getDiscountType" access="public" output="false">
		<cfreturn this.discountType />
	</cffunction>
	
	<cffunction name="set" output="false">
	
		<cfargument name="groupData" type="struct" required="false" default="" />
    <cfargument name="FirstParentID" type="string" required="false" />

		<!---decrypt the program id--->
		<CF_Cryp type="de" key="#request.app_general_functions.GenerateKey()#" string="#arguments.groupData.program_id#">
		<cfset tmpProgramId = cryp.value />
		
		<cfset DataManager = CreateObject("component", "components.products.Group.DataManager") />
		
		<!---temporary product list--->
		<cfset lTmpProducts = "" />
		
		
		<!---loop over the list of group products for each level--->
		<cfloop index="i" from="1" to="#request.AccessStructure.numberOfProductGroupLevels#">
			
			<cfloop index="indx" list="#Evaluate("arguments.groupData.Level_#i#")#">
			
				<cfset stripProdGoupId = request.app_general_functions.replaceHyphen(indx) />
				
				<cfset qProductsByGroups = DataManager.getByProductGroupData(
        prodGroupLevelId = Evaluate("arguments.groupData.GroupLevel_#i#"), 
        prodGroupId = indx, 
        programId= tmpProgramId,
        FirstParentID = arguments.FirstParentID
        ) /> 
				 
				<!---loop over each group product and populate Group object--->
				<cfloop query="qProductsByGroups">
				
					<!---set is a group--->
					<cfset "form.Is_Group_#stripProdGoupId#" = 1 />
					
					<!---initialize group object--->
					<cfset oGroup = CreateObject("component", "components.products.Group.Group") />
					<cfset oGroup.setProductGroupId(Product_Group_ID) />
					<cfset oGroup.setGroupLevelId(Evaluate("arguments.groupData.GroupLevel_#i#")) />
					<cfset oGroup.setGroupLevelDesc(Group_Level_Desc) />
					<cfset oGroup.setProductGroupLevelType(Product_Group_Level_Type) />
					<cfset oGroup.setHierarchyLevel(Hierarchy_Level) />
					<cfset oGroup.setPricingLevel(i) />
					<cfif Product_Group_Level_Type eq 2 and isdefined("Unit_Of_Measure_ID") > <!--- Dev Note: KAL; 9817; Event Error: Variable Unit_Of_Measure_ID is undefined ---> 
						<cfset oGroup.setUom(Unit_Of_Measure_ID) /> <!--- Dev Note: KAL; New template settings for Group UOM selections --->
					</cfif>
	
					<cfset oGroup.setTempItemMasterId() />
					
					<cfset lTmpProducts = ListAppend(lTmpProducts, oGroup.getTempItemMasterId()) />
					
					<cfset this.setGroups(oGroup) />
				
				</cfloop>
	
			</cfloop>
		
		</cfloop>
		
		<cfset this.setLProductIds(lTmpProducts) />
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getProductGroups" output="false">
	
		<cfargument name="filterGroups" required="false" default="" />
		
		<!---get the product groups and populate group object with data--->
		<cfset qProductGroups = CreateObject("component", "components.products.Group.DataManager").getProductGroupsData(filterGroups=arguments.filterGroups) />
		
		<cfloop query="qProductGroups">
			
			<!---initialize group object--->
			<cfset oGroup = CreateObject("component", "components.products.Group.Group") />
			<cfset oGroup.setGroupLevelId(Product_Group_Level_ID) />
			<cfset oGroup.setGroupLevelDesc(Group_Level_Desc) />
			<cfset oGroup.setProductGroupLevelType(Product_Group_Level_Type) />
			<cfset oGroup.setHierarchyLevel(Hierarchy_Level) />
			
			<cfset this.setGroups(oGroup) />
			
		</cfloop>
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getByProductGroup" output="false">
	
		<cfargument name="prodGroupLevelId" required="false" default="" />
		<cfargument name="prodGroupId" required="false" default="" />
		<cfargument name="bGetProducts" required="false" default="" />
		<cfargument name="programId" required="false" default="" />
		
		<!---create instance of the data manager--->
		<cfset DataManager = CreateObject("component", "components.products.Group.DataManager").init() />
		<cfset qProductsByGroups = DataManager.getByProductGroupData(arguments.prodGroupLevelId, arguments.prodGroupId) />
		<cfloop query="qProductsByGroups">
		
			<!---initialize group object--->
			<cfset oGroup = CreateObject("component", "components.products.Group.Group") />
			<cfset oGroup.setProductGroupId(Product_Group_ID) />
			<cfset oGroup.setGroupLevelId(arguments.prodGroupLevelId) />
			<cfset oGroup.setGroupLevelDesc(Group_Level_Desc) />
			<cfset oGroup.setProductGroupLevelType(Product_Group_Level_Type) />
			<cfset oGroup.setHierarchyLevel(Hierarchy_Level) />
			<cfset oGroup.setParentHierarchyId(Parent_Hierarchy_ID) />
			
			<!---if the bGetProducts flag is on then get the products for this group--->
			<cfif arguments.bGetProducts eq 1>
			
				<cfset qGetItemsGroup = DataManager.getItemsInGroup(Product_Group_ID, arguments.prodGroupLevelId, arguments.programId) />
				
				<cfloop query="qGetItemsGroup">
				
					<!---initialize group product object--->
					<cfset oGroupProd = CreateObject("component", "components.products.Group.GroupProduct") />
					<cfset oGroupProd.setItem(Item) />
					<cfset oGroupProd.setUpc(UPC) />
					<cfset oGroupProd.setDesc(Description) />
					
					<cfset oGroup.setGroupProduct(oGroupProd) />
					
				</cfloop>
				
			</cfif>
			
			<cfset this.setGroups(oGroup) />
			
		</cfloop>
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getProgramGroups" output="false">
	
		<cfargument name="programId" required="true" type="numeric">
	
		<!---create instance of the data manager--->
		<cfset DataManager = CreateObject("component", "components.products.Group.DataManager").init() />
		<cfset qProgramGroups = DataManager.getGroupsForProgram(arguments.programId) />
		
		<!---loop over the program groups and set group ojects for each one--->
		<cfloop query="qProgramGroups">
		
			<!---get all group data, including items/products/sku's for this program--->
			<cfset groupObj = this.getByProductGroup(Product_Group_Level_ID, Product_Group_ID, 1) />
			<cfset this.setGroups(groupObj.getGroups(1)) />
			
		</cfloop>
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getGroupByGroupType" output="false">
		
		<cfset groupTypeStruct = StructNew() />
		
		<cfset useLakebaseForqGetGroupType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForqGetGroupType>
	<cftry>
		<cfset qGetGroupType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "group_by_group_type"
			}), "group_by_group_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetGroupType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetGroupType>
<cfquery name="qGetGroupType" datasource="#application.datasource#">
			
			SELECT	Group_By_Group_Type
			FROM	_Application_Settings
			
		</cfquery>
</cfif>
		
		<cfset this.groupTypeVal = qGetGroupType.Group_By_Group_Type />
		
		<cfswitch expression="#this.groupTypeVal#">						
			<cfcase value="2">
				<!------ product hierarchy ----->
				<cfset groupTypeStruct.tableName 			= "Product_Hierarchy">
				<cfset groupTypeStruct.IDField 			= "Product_Hierarchy_ID">
				<cfset groupTypeStruct.NameField 			= "Product_Hierarchy_Name">
			</cfcase>
			<cfcase value="3">
				<!------ type group ----->
				<cfset groupTypeStruct.tableName 			= "Type_Group_Desc">
				<cfset groupTypeStruct.IDField 			= "Type_Group_Desc_ID">
				<cfset groupTypeStruct.NameField 			= "Type_Group_Desc">
			</cfcase>
			<cfcase value="4">
				<!------ class code ----->
				<cfset groupTypeStruct.tableName 			= "Class_Code">
				<cfset groupTypeStruct.IDField 			= "Class_Code_UUID">
				<cfset groupTypeStruct.NameField 			= "Class_Code_Desc">
			</cfcase>
			<cfcase value="5">
				<!------ q brand ----->
				<cfset groupTypeStruct.tableName 			= "Q_Brand_Desc">
				<cfset groupTypeStruct.IDField 			= "Q_Brand_ID">
				<cfset groupTypeStruct.NameField 			= "Q_Brand">
			</cfcase>
			<cfcase value="6">
				<!------ type code ----->
				<cfset groupTypeStruct.tableName 			= "Type_Code_Desc">
				<cfset groupTypeStruct.IDField 			= "Type_Code_Desc_ID">
				<cfset groupTypeStruct.NameField 			= "Type_Code_Desc">
			</cfcase>
			<cfcase value="7">
				<!------ brand ----->
				<cfset groupTypeStruct.tableName 			= "Brand">
				<cfset groupTypeStruct.IDField 			= "Brand_ID">
				<cfset groupTypeStruct.NameField 			= "Brand_Name">
			</cfcase>
			<cfcase value="8">
				<!------ product group ----->
				<cfset groupTypeStruct.tableName 			= "BSA_Product_Group">
				<cfset groupTypeStruct.IDField 			= "BSA_Product_Group_ID">
				<cfset groupTypeStruct.NameField 			= "Product_Group_Desc">
			</cfcase>
		</cfswitch>
		
		<cfreturn groupTypeStruct />
		
	</cffunction>
	
</cfcomponent>