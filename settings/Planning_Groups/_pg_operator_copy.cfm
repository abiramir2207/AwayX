<!DOCTYPE HTML>
<html lang="en">
<head>
 <meta http-equiv="content-type" content="text/html; charset=utf-8">
 <title>Copy <cfoutput>#application.returned_customer_setting.Operator_Label_Singular#</cfoutput> Planning Group</title>
</head>
<body>
<cfset PGManager = CreateObject("component", "components.settings.PlanningGroups.PlanningGroupsManager").init() />
<cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />
<cfset OprGroupDataManager = CreateObject("component", "components.operator.Group.DataManager") />

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
<cfset ProductManager = CreateObject("component", "components.products.ProductManager") />

<!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START--->
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset isBusinessSegEnabledForDistributor = businessSegManager.isEnabledForDistributor()>
<cfset isBusinessSegEnabledForProduct = businessSegManager.isEnabledForProduct() />
<cfset qGetBusSegments = businessSegManager.getActive() />
<!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->

<cfparam name="url.status" default="">

<!--- D43632 :: Duplicate planning groups START--->
<cfparam name="errorlist" default="">
<cfparam name="form.save" default="0">
<cfparam name="FORM.PG_Effective_Start_Date" default="">
<cfparam name="FORM.PG_Effective_End_Date" default="">

<cfinclude template="/Common_Files/jQuery.cfm">
<!--- D43632 :: Duplicate planning groups END--->
<!--- D43632 :: Duplicate planning groups --->
<cfif isdefined("form.save") AND form.save>

	<cfquery name="qNameCheck" datasource="#application.datasource#">
      SELECT PG_Operator_Category_Name
	  FROM PG_Operator_Category
	  WHERE PG_Operator_Category_Name = '#trim(FORM.planningGroupName)#' AND Deleted = 0
     </cfquery>
<!--- D43632 :: Duplicate planning groups START--->
 	<cfif qNameCheck.recordcount>
		<cfset errorlist = listappend(errorlist, 'Planning Group Name already exists.')>
	</cfif>
     <cfif len(trim(form.planningGroupName)) EQ 0>
		<cfset errorlist = listappend(errorlist, 'Planning Group Name cannot be empty.')>
	 </cfif>
     <cfif form.selTypeName EQ 0>
		<cfset errorlist = listappend(errorlist, 'Please select an option for Type Name.')>
	 </cfif>

	 <cfif len(errorlist) GT 0>
		<script type="text/javascript">
			alert(<cfoutput>"#replace(errorlist,',','\n','ALL')#"</cfoutput>);
			window.history.back();
		</script>
		<cfabort>
	 </cfif>
 <!--- D43632 :: Duplicate planning groups END--->

		<cfif NOT isdefined("FORM.bIncludeInOthers")>
			<cfset FORM.bIncludeInOthers = 0>
		</cfif>
		<cfif NOT isdefined("FORM.bCaptureRemoves")>
			<cfset FORM.bCaptureRemoves = 0>
		</cfif>
		<cfif form.status EQ 'ACTIVE'>
			<cfset active = 1>
		<cfelseif form.status EQ 'INACTIVE'>
			<cfset active = 0>
		</cfif>
	<cfparam name="form.business_segment" default="0" >
<cftransaction>
<!---D81389 Tyson - System generated number for Planning Groups --->
<cfif appSettings.get_Setting('PG_Eff_Date_Product') eq '1' OR appSettings.get_Setting('PG_Eff_Date_Distributor') eq '1' OR appSettings.get_Setting('PG_Eff_Date_Operator') eq '1'>
  <cfset PG_Number_Sequence = CreateObject("component", "components.settings.PlanningGroups.PlanningGroupsManager").PGSequenceNumber()/>
<cfelse>
  <cfset PG_Number_Sequence = ''>
</cfif>
		<cfquery name="qInsPGOperator" datasource="#application.datasource#">
			  DECLARE @PG_Operator_Category_ID VARCHAR (50)
		      SET @PG_Operator_Category_ID = NEWID()
		      INSERT INTO PG_Operator_Category
		      (
		        PG_Operator_Category_ID,
		        PG_Type_ID,
		        PG_Operator_Category_Code,
		        PG_Operator_Category_Name,
		        Active,
		        Deleted,
		        Created_By,
		        Include_In_Other_PG,
		        Is_Master_Group,
				Capture_Removes
        <cfif appSettings.get_Setting('PG_Eff_Date_Product') eq '1'>
				,PG_Effective_Start_Date
				,PG_Effective_End_Date
				</cfif>
				,PG_Number_Sequence
		      )
		      VALUES
		      (
		        @PG_Operator_Category_ID,
		        #trim(FORM.selTypeName)#,
		        '#trim(FORM.planningGroupCode)#',
		        '#trim(FORM.planningGroupName)#',
		        #trim(active)#,
		        0,
		        '#trim(REQUEST.AccessStructure.User_ID)#',
		        '#trim(FORM.bIncludeInOthers)#',
		        <cfif isdefined("form.bMasterGroupOnly")>1<cfelse>0</cfif>       <!---31191--->
				,'#FORM.bCaptureRemoves#'
				<cfif appSettings.get_Setting('PG_Eff_Date_Product') eq '1'>
					,<cfqueryparam value="#Form.PG_Effective_Start_Date#" cfsqltype="cf_sql_date"/>
					,<cfqueryparam value="#Form.PG_Effective_End_Date#" cfsqltype="cf_sql_date"/>
				</cfif>
					,<cfqueryparam value="#PG_Number_Sequence#" cfsqltype="cf_sql_bigint" null="yes" />
		      )
		       SELECT PG_Operator_Category_ID = @PG_Operator_Category_ID
		</cfquery>

	    <cfquery name="qInsPGCustomerCategoryDefinition" datasource="#application.datasource#">
   		 INSERT INTO PG_Operator_Category_Definition
	      (
	        PG_Operator_Category_ID,
	        PG_Type_ID,
	        Operator_Group_Level_ID,
	        Operator_Group_ID,
	        Inclusion_Exclusion,
	        Active,
	        Deleted,
	        Created_By,
	        Include_In_Other_PG,
	        Is_PG
	      )
	      SELECT
	      	'#trim(qInsPGOperator.PG_Operator_Category_ID)#' as PG_Operator_Category_ID,
	        #trim(FORM.selTypeName)# as PG_Type_ID,
	        Operator_Group_Level_ID,
	        Operator_Group_ID,
	        Inclusion_Exclusion,
	        Active,
	        Deleted,
	        '#trim(REQUEST.AccessStructure.User_ID)#' as Created_By,
	        #trim(FORM.bIncludeInOthers)# as Include_In_Other_PG,
	        Is_PG
	        FROM PG_Operator_Category_Definition
	        WHERE PG_Operator_Category_ID = '#form.PG_Operator_Category_ID#'
       		AND	  Deleted = 0
       		AND	  Active = #trim(active)#
	    </cfquery>
<!---  D37056 No Members Found - TEST JEN & FSD All Distributors  START--->
 <cfquery name="qryPopulateTempTableForOperator" datasource="#application.datasource#">
		IF OBJECT_ID ('tempdb..##tmp_PG_View_Operator_Members') IS NOT NULL
		DROP TABLE ##tmp_PG_View_Operator_Members

		SELECT	Distinct
				PG_Type.PG_Type_ID,
				PG_Operator_Category_Definition.PG_Operator_Category_ID,
				PG_Operator_Category_Definition.Operator_Group_Level_ID,
				PG_Operator_Category_Definition.Operator_Group_ID,
				PG_Operator_Category_Definition.Inclusion_Exclusion,
				PG_Operator_Category_Definition.IS_PG,
				PG_Operator_Category.Include_In_Other_PG,
				PG_Operator_Category.PG_Operator_Category_Code,
				PG_Operator_Category.PG_Operator_Category_Name
		INTO	##tmp_PG_View_Operator_Members
		FROM	PG_Type
		INNER JOIN	PG_Operator_Category_Definition
		ON		PG_Operator_Category_Definition.PG_Type_ID = PG_Type.PG_Type_ID
		INNER join PG_Operator_Category
		ON		PG_Operator_Category.PG_Operator_Category_ID = PG_Operator_Category_Definition.PG_Operator_Category_ID
		AND		PG_Operator_Category.Deleted = 0
		WHERE	PG_Operator_Category_Definition.Deleted = 0
		AND		PG_Type.PG_Group_Type =3 --Operator
		AND		(PG_Operator_Category_Definition.PG_Operator_Category_ID IN ('#trim(qInsPGOperator.PG_Operator_Category_ID)#')
		OR		PG_Operator_Category_Definition.PG_Operator_Category_ID IN (SELECT DISTINCT Operator_Group_ID FROM PG_Operator_Category_Definition WHERE  IS_PG =1 AND Deleted = 0 AND PG_Operator_Category_ID IN ('#trim(qInsPGOperator.PG_Operator_Category_ID)#' )
		))
		Order by PG_Type.PG_type_ID, PG_Operator_Category_Definition.PG_Operator_Category_ID,
				PG_Operator_Category.Include_In_Other_PG,
				PG_Operator_Category_Definition.Operator_Group_Level_ID,
				PG_Operator_Category_Definition.Operator_Group_ID

		CREATE CLUSTERED INDEX [I_tmp_PG_View_Operator_Members_C] ON [dbo].[##tmp_PG_View_Operator_Members]([Operator_Group_ID],[Operator_Group_Level_ID]) WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]

  </cfquery>
    <cfstoredproc procedure="USP_POPULATE_Operator_PG_MEMBERS" datasource="#application.datasource#">
	    <cfprocparam type="In" CFSQLType="CF_SQL_TINYINT" dbVarName = "@View_Or_Save" value = "2" null="no">
      <cfprocresult name="qryUSPPopulateOperatorPGMembers">
    </cfstoredproc>
 </cftransaction>
<!---  D37056 No Members Found - TEST JEN & FSD All Distributors END --->
   <script type="text/javascript">
   	window.opener.document.forms[0].submit();
   	window.close();
   </script>
<cfelse>
<cfset qryGetPGOperatorCategoryByID = PGManager.fnGetPGOperatorCategoryByID(URL.PGProductCatID) />
<cfoutput>
	<form name="copy_planning_group" action="_pg_operator_copy.cfm" method="post">
	<FIELDSET STYLE="padding:10px; width: 500px; border: 1px solid Blue;">
		<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">#application.returned_customer_setting.Operator_Label_Singular# Planning Group Information</LEGEND>
	 <table width="500" border="1" cellpadding="5" cellspacing="0" cols="groups" rules="groups" bordercolor="a85400">
		<tr><td colspan="2" height="6px;"> <font color="red" size="5">*</font> - Required Field</td></tr>
  	<tr>
    	<td align="right"  width="30%"><strong>Planning Group Code: </strong></td>
    	<td><input tye="text" name="planningGroupCode" size="8" maxlength="20" value=" "></td>
  	</tr>
  	<tr>
    	<td align="right"  width="30%"><strong>Planning Group Name<font color="red" size="2">*</font>: </strong></td>
    	<td><input tye="text" name="planningGroupName" size="25" maxlength="50" value=" "></td>
  	</tr>
  	<tr>
    	<td align="right"  width="30%"><strong>Type Name: </strong></td>
    	<td><cfset qGetActivePGTypeByGrpType = PGManager.fnGetActivePGTypesByGrpType("3") />
      	<select name="selTypeName" id="selTypeName"  >
        	<option value="0">Select a PG Type</option>
        	<cfloop query="qGetActivePGTypeByGrpType">
          	<option value="#qGetActivePGTypeByGrpType.PG_Type_ID#" <cfif #qryGetPGOperatorCategoryByID.PG_TYPE_ID# EQ #qGetActivePGTypeByGrpType.PG_Type_ID#>SELECTED</cfif>>#qGetActivePGTypeByGrpType.PG_Type_Name#</option>
        	</cfloop>
      	</select>
    	</td>
  	</tr>
	  <!--- 34007 --->
<cfif appSettings.get_Setting('PG_Eff_Date_Product') eq '1'>
  <tr>
    <td align="right"  width="30%">
      <strong>Effective Date<font color="red" size="2">*</font>: <img src="/images/help_small.gif" title="The effective date is not a functional value in  FORGE and does not affect dates applied within programs, claims or reporting.  It is purely an attribute to facilitate communication with other systems."/></strong>
    </td>
 <td>
      Start Date <input type="text" name="PG_Effective_Start_Date" size="15" maxlength="10" <cfif (isDefined("FORM.PG_Effective_Start_Date") AND FORM.PG_Effective_Start_Date NEQ "")>value="#FORM.PG_Effective_Start_Date#"<cfelse>value="#dateformat(qryGetPGOperatorCategoryByID.PG_Effective_Start_Date,'MM/DD/YYYY')#"</cfif>>
	  End Date <input type="text" name="PG_Effective_End_Date" size="15" maxlength="10" <cfif (isDefined("FORM.PG_Effective_End_Date") AND FORM.PG_Effective_End_Date NEQ "")>value="#FORM.PG_Effective_End_Date#"<cfelse>value="#dateformat(qryGetPGOperatorCategoryByID.PG_Effective_End_Date,'MM/DD/YYYY')#"</cfif>>
   </td>
 </tr>
</cfif>
	  <tr>
	  		<cfinclude template="removeMembers.cfm">
	  		<cfparam name="FORM.bCaptureRemoves" default="#qryGetPGOperatorCategoryByID.Capture_Removes#">
	  		<td><input type="checkbox" name="bCaptureRemoves" <cfif FORM.bCaptureRemoves EQ "1">checked</cfif> value="1"></td>
	  </tr>
		<tr>
    	<td align="right"><strong>Include in other PG:</strong></td>
    	<td>
      	<input type="checkbox" name="bIncludeInOthers" id="bIncludeInOthers" value="1" <cfif qryGetPGOperatorCategoryByID.Include_In_Other_PG>checked</cfif>>
    	</td>
  	</tr>
    <tr>
      <td align="right"><strong>Master Data Groups Only:</strong></td>
      <td><input type="checkbox" name="bMasterGroupOnly" value="1" id="bMasterGroupOnly" <cfif #qryGetPGOperatorCategoryByID.Is_Master_group#>CHECKED</cfif>></td>
    </tr>
	<tr>
		<td colspan="2" align="right">
				<input type="hidden" name="PG_Operator_Category_ID" value="#qryGetPGOperatorCategoryByID.PG_OPERATOR_CATEGORY_ID#">
				<input type="hidden" name="status" value="#url.status#">
				<!--- D43632 :: Duplicate planning groups START--->
				<input type="hidden" name="save" value="0">
				<a onclick="submitform();" id="submit">#application.util.string.actionLinkFormat2('Save')#</a>
				<!--- D43632 :: Duplicate planning groups END--->
				<a onclick="resetform();">#application.util.string.actionLinkFormat2('Clear')#</a>
		</td>
	</tr>
	</table>

	</form>
</cfoutput>
<!--- D43632 :: Duplicate planning groups START--->
<script>
function submitform(){
	document.copy_planning_group.save.value = '1';
	$( '#submit' ).replaceWith( "Please Wait..." );
	document.copy_planning_group.submit();
}
function resetform(){
	document.getElementById('copy_planning_group').reset();
}
</script>
<!--- D43632 :: Duplicate planning groups END--->
</cfif>
</body>
</html>
