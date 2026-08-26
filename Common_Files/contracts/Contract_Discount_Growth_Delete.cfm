<cf_cryp type="de" key="#request.key#" string="#FORM.Program_ID#">
<cfset FORM.Program_ID = cryp.value>
<cfparam name="form.EZTemplate" default="0">

<!--- lock checker --->
<cfif form.EZTemplate EQ 0>
<CFSET LockChecker_CID  = FORM.Program_ID>
<CFINCLUDE TEMPLATE="LockChecker.cfm">
</cfif>
<!--- lock checker --->

<cfif form.deletedateexclusions EQ 1>
<cfquery name="GetSettings" datasource="#application.datasource#">

	SELECT 	Program_Control_Panel_Options.Date_Exclusions_ON
	FROM 	Program_Control_Panel_Options
			INNER JOIN Contract_Main ON 
			Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
	WHERE 	Contract_Main_ID = #form.program_id#
	
</cfquery>

<cfif GetSettings.Date_Exclusions_ON EQ 1>
			<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />	
			<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(form.program_id,0)>
		<cfif form.deletedateexclusions EQ 1>
			<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
			<cfquery name="deletedateexclusions" datasource="#application.datasource#">
				update contract_main
				set deleted = 1
				where contract_main_id in (#valuelist(getDateExclusionprogramIDs.revision_program_id)#)
			</cfquery>
			<cfquery name="deletedateexclusions" datasource="#application.datasource#">
				update program_exclusions
				set deleted = 1
				where revision_program_id in (#valuelist(getDateExclusionprogramIDs.revision_program_id)#)
			</cfquery>
			</CFIF>
		</cfif>
</cfif>
</cfif>
<CFQUERY NAME="getCompInfo" datasource="#application.datasource#">
	SELECT     dbo.Contract_Products.Contract_Products_ID, dbo.Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID, 
	                      dbo.Program_Growth_Components.Program_ID, dbo.Program_Growth_Components.Program_Growth_Component_ID
	FROM         dbo.Program_Growth_Components INNER JOIN
	                      dbo.Contract_Products INNER JOIN
	                      dbo.Program_Growth_Component_Product_Data ON 
	                      dbo.Contract_Products.Contract_Products_ID = dbo.Program_Growth_Component_Product_Data.Contract_Products_ID ON 
	                      dbo.Program_Growth_Components.Program_Growth_Component_ID = dbo.Program_Growth_Component_Product_Data.Program_Growth_Component_ID
	WHERE     (dbo.Program_Growth_Components.Program_Growth_Component_ID = '#Form.Comp_ID#')
</CFQUERY>


<cfset useLakebaseForDeleteParentComponent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components")>
<cfif useLakebaseForDeleteParentComponent>
	<cftry>
		<cfset application.oLakebase.updateRows("program_growth_components",
			{ "program_growth_component_id" = "eq.#Form.Comp_ID#" },
			{ "deleted" = true }
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeleteParentComponent = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeleteParentComponent>
	<CFQUERY NAME="delete" datasource="#application.datasource#">
		UPDATE Program_Growth_Components
		SET Deleted = 1
		WHERE Program_Growth_Component_ID =  '#Form.Comp_ID#'
	</CFQUERY>
</cfif>

<CFSET CPList = valuelist(getCompInfo.Contract_Products_ID)>
<CFIF listlen(CPList) GT 0>
	<CFQUERY NAME="delete" datasource="#application.datasource#">
		UPDATE Contract_Products
		SET Deleted = 1
		WHERE Contract_Products_ID IN(#CPList#)
	</CFQUERY>

	<CFQUERY NAME="DeleteProductMargin" datasource="#application.datasource#">
		UPDATE Contract_Product_Margin
		SET Deleted = 1
		WHERE Contract_Product_ID IN(#CPList#)
	</CFQUERY>

	<CFQUERY NAME="delete" datasource="#application.datasource#">
		UPDATE Program_Growth_Component_Product_Data
		SET Deleted = 1
		WHERE Program_Growth_Component_Product_Data_ID  IN(#valuelist(getCompInfo.Program_Growth_Component_Product_Data_ID)#)
	</CFQUERY>

	<CFQUERY NAME="delete" datasource="#application.datasource#">
		UPDATE Program_Growth_Component_Product_Tier_Data
		SET Deleted = 1
		WHERE Program_Growth_Component_Product_Data_ID  IN(#valuelist(getCompInfo.Program_Growth_Component_Product_Data_ID)#)
	</CFQUERY>
</CFIF>

<CFQUERY NAME="deleteComponentTiers" datasource="#application.datasource#">
	UPDATE Program_Growth_Component_Tiers
	SET Deleted = 1
	WHERE Program_Growth_Component_ID = '#Form.Comp_ID#'
</CFQUERY>

<!---Delete targets and volume pools--->
<cfset useLakebaseForFindChildren = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components")>
<cfif useLakebaseForFindChildren>
	<cftry>
		<cfset FindChildren = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_growth_components", { "parent_id" = "eq.#Form.Comp_ID#", "select" = "program_growth_component_id" })
		)>
		<cfcatch type="any">
			<cfset useLakebaseForFindChildren = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForFindChildren>
	<cfquery name="FindChildren" datasource="#application.datasource#">
	SELECT Program_Growth_Component_ID
	FROM Program_Growth_Components
	WHERE Parent_ID = '#Form.Comp_ID#'
	</cfquery>
</cfif>

<!---If there are children, mark them all as deleted--->
<cfif FindChildren.Recordcount GT 0>
	<cfloop query="FindChildren">
			
		<CFQUERY NAME="getChildrenCompInfo" datasource="#application.datasource#">
			SELECT     dbo.Contract_Products.Contract_Products_ID, dbo.Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID, 
			                      dbo.Program_Growth_Components.Program_ID, dbo.Program_Growth_Components.Program_Growth_Component_ID
			FROM         dbo.Program_Growth_Components INNER JOIN
			                      dbo.Contract_Products INNER JOIN
			                      dbo.Program_Growth_Component_Product_Data ON 
			                      dbo.Contract_Products.Contract_Products_ID = dbo.Program_Growth_Component_Product_Data.Contract_Products_ID ON 
			                      dbo.Program_Growth_Components.Program_Growth_Component_ID = dbo.Program_Growth_Component_Product_Data.Program_Growth_Component_ID
			WHERE     (dbo.Program_Growth_Components.Program_Growth_Component_ID = '#FindChildren.Program_Growth_Component_ID#')
		</CFQUERY>
		
		
		<CFQUERY NAME="delete" datasource="#application.datasource#">
			UPDATE Program_Growth_Components
			SET Deleted = 1
			WHERE Program_Growth_Component_ID =  '#FindChildren.Program_Growth_Component_ID#'
		</CFQUERY>
		
		<CFSET CPList = valuelist(getChildrenCompInfo.Contract_Products_ID)>
		<CFIF listlen(CPList) GT 0>
			<CFQUERY NAME="delete" datasource="#application.datasource#">
				UPDATE Contract_Products
				SET Deleted = 1
				WHERE Contract_Products_ID IN(#CPList#)
			</CFQUERY>
		
			<CFQUERY NAME="DeleteProductMargin" datasource="#application.datasource#">
				UPDATE Contract_Product_Margin
				SET Deleted = 1
				WHERE Contract_Product_ID IN(#CPList#)
			</CFQUERY>
		
			<CFQUERY NAME="delete" datasource="#application.datasource#">
				UPDATE Program_Growth_Component_Product_Data
				SET Deleted = 1
				WHERE Program_Growth_Component_Product_Data_ID  IN(#valuelist(getChildrenCompInfo.Program_Growth_Component_Product_Data_ID)#)
			</CFQUERY>
		
			<CFQUERY NAME="delete" datasource="#application.datasource#">
				UPDATE Program_Growth_Component_Product_Tier_Data
				SET Deleted = 1
				WHERE Program_Growth_Component_Product_Data_ID  IN(#valuelist(getChildrenCompInfo.Program_Growth_Component_Product_Data_ID)#)
			</CFQUERY>
		</CFIF>
		
		<CFQUERY NAME="deleteComponentTiers" datasource="#application.datasource#">
			UPDATE Program_Growth_Component_Tiers
			SET Deleted = 1
			WHERE Program_Growth_Component_ID = '#FindChildren.Program_Growth_Component_ID#'
		</CFQUERY>

	
	
	</cfloop>
	
</cfif>


<!------ Start Clause Code ----->
<cfset discountTypeId = 4>
<cfset programId = Form.Program_ID>
<cfinclude template="/Clause_Library/Clause_Discount_Type_Add_Remove.cfm">
<!------ End  Clause Code ----->

<!---call SP to update program product volume --->
<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_UPD" datasource="#application.datasource#">
				
	<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#Form.Program_ID#" null="no">
				   
</cfstoredproc>

<!---call SP to update program contract quantity --->
<cfstoredproc procedure="Update_Program_Volume" datasource="#application.datasource#">

	<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#Form.Program_ID#" null="no">

</cfstoredproc>

	
 <CFLOCATION URL="#CGI.HTTP_REFERER#" addtoken="No">
<!---  <CFLOCATION URL="#CGI.HTTP_REFERER#"> --->

