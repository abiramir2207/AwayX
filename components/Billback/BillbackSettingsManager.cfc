<cfcomponent hint="Billback Settings Manager" extends="components.Base">

	<cffunction name="getSubtotalDisplaySettings">
			<cfquery name="qGetSettings" datasource="#application.datasource#">
				SELECT	Display_Product_Group_BB,Group_Claim_By_Product_Attribute,
				BB_Product_Group_Updated_By,BB_Product_Group_Updated_date,
						_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName
				FROM	General_Settings
						LEFT JOIN _Users
						ON
						_Users.Deleted = 0
						AND
						_Users.User_ID = General_Settings.BB_Product_Group_Updated_By
			</cfquery>


	<cfreturn qGetSettings>
	</cffunction>

	<cffunction name="save" output="false">
	<cfargument name="Display_Product_Group_BB" required="true" type="numeric" />
	<cfargument name="Group_Claim_By_Product_Attribute" required="true" type="numeric" />
	<cfargument name="updated_By" required="false" type="string" default="name"/>
				<cfquery name="qUpdateSettings" datasource="#application.datasource#">
					UPDATE	General_Settings
					SET		Display_Product_Group_BB = <cfqueryparam value="#arguments.Display_Product_Group_BB#" cfsqltype="CF_SQL_INTEGER">,
							Group_Claim_By_Product_Attribute = <cfqueryparam value="#arguments.Group_Claim_By_Product_Attribute#" cfsqltype="CF_SQL_INTEGER">,
							BB_Product_Group_Updated_By =  <cfqueryparam value="#arguments.updated_By#" cfsqltype="CF_SQL_VARCHAR">,
							BB_Product_Group_Updated_Date = getdate()
				</cfquery>
	</cffunction>

	<cffunction name="getSearchExpiredProgramWithin" returntype="numeric">

		<cfset var Search_Expired_Program_Within = 0 />

		<CFQUERY NAME="qGetSearchExpiredProgramWithin" DATASOURCE="#application.datasource#">
			SELECT	Search_Expired_Program_Within
			FROM	Billback_Settings
			WHERE	Billback_Settings.User_ID = '#request.AccessStructure.Company_Main_ID#'
		</CFQUERY>

		<cfif isNumeric(qGetSearchExpiredProgramWithin.Search_Expired_Program_Within)>
			<cfset Search_Expired_Program_Within = qGetSearchExpiredProgramWithin.Search_Expired_Program_Within />
		</cfif>

		<cfreturn Search_Expired_Program_Within />

	</cffunction>

	<cffunction name="saveSearchExpiredProgramWithin" returntype="void">
		<cfargument name="Search_Expired_Program_Within" required="true" type="numeric" />

		<CFQUERY NAME="qGetSearchExpiredProgramWithin" DATASOURCE="#application.datasource#">
			UPDATE	Billback_Settings
			SET		Search_Expired_Program_Within = <cfqueryparam value="#arguments.Search_Expired_Program_Within#" cfsqltype="CF_SQL_INTEGER">
			WHERE	Billback_Settings.User_ID = '#request.AccessStructure.Company_Main_ID#'
		</CFQUERY>
	</cffunction>

	<cffunction name="getAdjustment_Default" returntype="numeric">
		<cfset var Adjustment_Default = 1 />
		<CFQUERY NAME="qGetAdjustmentDefault" DATASOURCE="#application.datasource#">
			SELECT	Top 1 Adjustment_Default
			FROM	Billback_Settings
		</CFQUERY>
		<cfif isNumeric(qGetAdjustmentDefault.Adjustment_Default)>
			<cfset Adjustment_Default = qGetAdjustmentDefault.Adjustment_Default />
		</cfif>
		<cfreturn Adjustment_Default />
	</cffunction>

	<cffunction name="getDefaultSortOptions" returntype="query">
		<CFQUERY NAME="Default_sort_columns" DATASOURCE="#application.datasource#">
			SELECT	Top 1 Default_Sort_option_for_Scorecard, Default_sort_By
			FROM	Billback_Settings
		</CFQUERY>

		<cfreturn Default_sort_columns />
	</cffunction>
	<!--- 98106 - Auto Deviations to consider if bb is beyond program budget START --->
	<cffunction name="getBB_Status_for_Budget_Actual" returntype="numeric">
		<CFQUERY NAME="qBB_Status_for_Budget_Actual" DATASOURCE="#application.datasource#">
			SELECT	Top 1 BB_Status_for_Budget_Actual
			FROM	Billback_Settings
		</CFQUERY>
	<cfif qBB_Status_for_Budget_Actual.recordcount>
		<cfreturn qBB_Status_for_Budget_Actual.BB_Status_for_Budget_Actual />
	<cfelse>
		<cfreturn 5/>
	</cfif>
	</cffunction>

	<cffunction name="saveBB_Status_for_Budget_Actual" returntype="void">
		<cfargument name="BB_Status_for_Budget_Actual" required="true" type="numeric" />
		<CFQUERY NAME="qBB_Status_for_Budget_Actual" DATASOURCE="#application.datasource#">
			UPDATE	Billback_Settings
			SET BB_Status_for_Budget_Actual = <cfqueryparam value="#arguments.BB_Status_for_Budget_Actual#" cfsqltype="CF_SQL_INTEGER">
		</CFQUERY>
	</cffunction>
	<!--- 98106 - Auto Deviations to consider if bb is beyond program budget END --->

	<cffunction name="saveAdjustmentDefault" returntype="void">
		<cfargument name="Adjustment_Default" required="true" type="numeric" />
		<CFQUERY NAME="qSaveAdjustmentDefault" DATASOURCE="#application.datasource#">
			UPDATE	Billback_Settings
			SET		Adjustment_Default = <cfqueryparam value="#arguments.Adjustment_Default#" cfsqltype="CF_SQL_INTEGER">
		</CFQUERY>
	</cffunction>

	<cffunction name="saveDefaultOptions" returntype="void">
		<cfargument name="Sort_Option_for_Scorecard" required="true" type="string" />
		<cfargument name="Sort_by" required="true" type="string" />
		<cfquery name="qSaveDefaultOptions" datasource="#application.datasource#">
			UPDATE	Billback_Settings
			SET		Default_Sort_option_for_Scorecard =<cfqueryparam value="#arguments.Sort_Option_for_Scorecard#" cfsqltype="CF_SQL_VARCHAR">,
					Default_Sort_By = <cfqueryparam value="#arguments.Sort_by#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
	</cffunction>

 <!---
				Dev Notes: D24193/Anand Rao/27-Jul-10
				BB Flex Grid Select All Button & Approve Change
	--->

  <cffunction name="getBBDevColorSetting">
	<cfquery name="qGetBBDevColorSetting" datasource="#application.datasource#">
	  SELECT
		BBS.ExpBtnBgColor,
		BBS.ExpBtnFontColor,
		BBS.ClmBtnBgColor,
		  BBS.ClmBtnFontColor,
		BBS.EltBtnBgColor,
		  BBS.EltBtnFontColor,
		BBS.SelBtnBgColor,
		BBS.SelBtnFontColor,
		BBS.BtnColor_Updated_By,
		BBS.BtnColor_Updated_Date,
		_Users.Name_First + ' ' + _Users.Name_Last AS Updated_By
	  FROM
		Billback_Settings BBS
	  LEFT JOIN _Users ON
		_Users.User_ID = BBS.BtnColor_Updated_By
	</cfquery>
	<cfreturn  qGetBBDevColorSetting />
  </cffunction>

  <cffunction name="saveBillbackColorSettings" returnType="void">
	<cfargument name="ExpBgColor" required="true" type="string" />
	<cfargument name="ExpFontColor" required="true" type="string" />
	<cfargument name="ClmBgColor" required="true" type="string" />
	<cfargument name="ClmFontColor" required="true" type="string" />
	<cfargument name="EltBgColor" required="true" type="string" />
	<cfargument name="EltFontColor" required="true" type="string" />
	<cfargument name="SelBgColor" required="true" type="string" />
	<cfargument name="SelFontColor" required="true" type="string" />
	<cfargument name="Updated_By" required="true" type="string" />

	<cfquery name="qSaveAdjustmentDefault" datasource="#application.datasource#">
	  UPDATE	Billback_Settings
				SET		ExpBtnBgColor         = <cfqueryparam value="#arguments.ExpBgColor#" cfsqltype="CF_SQL_VARCHAR">,
				ExpBtnFontColor       = <cfqueryparam value="#arguments.ExpFontColor#" cfsqltype="CF_SQL_VARCHAR">,
				EltBtnBgColor         = <cfqueryparam value="#arguments.EltBgColor#" cfsqltype="CF_SQL_VARCHAR">,
				EltBtnFontColor       = <cfqueryparam value="#arguments.EltFontColor#" cfsqltype="CF_SQL_VARCHAR">,
				ClmBtnBgColor         = <cfqueryparam value="#arguments.ClmBgColor#" cfsqltype="CF_SQL_VARCHAR">,
				ClmBtnFontColor       = <cfqueryparam value="#arguments.ClmFontColor#" cfsqltype="CF_SQL_VARCHAR">,
				SelBtnBgColor         = <cfqueryparam value="#arguments.SelBgColor#" cfsqltype="CF_SQL_VARCHAR">,
				SelBtnFontColor       = <cfqueryparam value="#arguments.SelFontColor#" cfsqltype="CF_SQL_VARCHAR">,
				BtnColor_Updated_By   = <cfqueryparam value="#arguments.Updated_By#" cfsqltype="CF_SQL_VARCHAR">,
				BtnColor_Updated_Date = GetDate()
  </cfquery>
  </cffunction>

<!---
				Dev Notes: D24500/Anand Rao/19-Aug-10
				Billback Search Changes
	--->

  <cffunction name="getBBUploadedTypeLabels">
	<cfquery name="qGetBBUploadedTypeLabels" datasource="#application.datasource#">
	  SELECT
		BBS.Manual_BB_Label
		,BBS.Uploaded_Via_App_Label
		,BBS.Batch_Interface_Label
		,BBS.Auto_Pay_Label
		,BBS.Auto_Approved_Label
		,BBS.BB_Type_Labels_Updated_By
		,BBS.BB_Type_Labels_Updated_Date
		,BBS.III_Party_Xref_Enabled
		,BBS.Operator_Xref_Enabled
		,BBS.Allow_Multiple_Operator_Xref
		,BBS.USE_DFLT_PRG
		,BBS.IS_ReferenceNum
		,_Users.Name_First + ' ' + _Users.Name_Last AS Updated_By
		,BBS.III_P_Upload_One_Pgm_Per_BB
		,BBS.III_P_Upload_Load_Claim_Price
		,BBS.III_P_Upload_Alias_Uses_Eshark
		,BBS.III_P_Upload_Operator_Auto_Add
		,BBS.Sysco_EDI_Use_Program_Xref
		,BBS.USFS_EDI_Use_Program_Xref
		,BBS.Override_Use_Program_Xref
		,BBS.Sysco_Use_Mfg_Product_ID
		,BBS.Vendor_Override_For_Sysco_EDI
		,BBS.Vendor_ID
		,BBS.Vendor_Default_Closing_Method_ID
		,BBS.Enable_BB_Dup_Check
		,BBS.Same_Dollar_Amount
		,BBS.Same_Reference_Number
		,BBS.Same_Payee
		,BBS.Same_Start_End_Dates
		,BBS.Sysco_Load_Negative_Invoices_ADJ_and_PAID
		,BBS.USF_Load_Negative_Invoices_ADJ_and_PAID
		,BBS.USFS_Concat_Program_Alias_Desc
		,BBS.EDI_create_BB_per_Associated_Shipto
		,BBS.Sysco_Concat_Program_Alias_ID
		,BBS.III_P_Upload_Business_Segment
		,BBS.Third_Party_Upload_Ship_To_Column
		,BBS.III_P_Upload_Use_Closing_Method
		,BBS.III_Party_Load_Negative_Invoices_ADJ_and_PAID<!---74703--->
		,BBS.III_P_Upload_Use_Holding_Pen
	  FROM
		Billback_Settings BBS
	  LEFT JOIN _Users ON
		_Users.User_ID = BBS.BB_Type_Labels_Updated_By
	</cfquery>
	<cfreturn  qGetBBUploadedTypeLabels />
  </cffunction>

  <cffunction name="saveBBUploadedTypeLabels" returnType="void">
	<cfargument name="ManualBBLabel" required="true" type="string" />
	<cfargument name="UploadedViaAppLabel" required="true" type="string" />
	<cfargument name="BatchInterfaceLabel" required="true" type="string" />
	<cfargument name="AutoPayLabel" required="true" type="string" />
	<cfargument name="AutoApprovedLabel" required="true" type="string" />
	<cfargument name="III_party_Xref_Enabled" required="true" type="boolean" />
	<cfargument name="Operator_Xref_Enabled" required="true" type="boolean" />
	<cfargument name="Allow_Multiple_Operator_Xref" required="true" type="boolean" />
	<cfargument name="IS_ReferenceNum" required="true" type="boolean" />
	<cfargument name="BBTypeLabelsUpdatedBy" required="true" type="string" />
	<cfargument name="one_pgm_per_bb" required="true" type="boolean" />
	<cfargument name="load_claim_price" required="true" type="boolean" />
	<cfargument name="alias_uses_eshark" required="true" type="boolean" />
	<cfargument name="Operator_Auto_Add" required="true" type="boolean" />
	<cfargument name="SyscoUseProgramXref" required="true" type="boolean" />
	<cfargument name="USFSUseProgramXref" required="true" type="boolean" />
	<cfargument name="OverrideUseProgramXref" required="true" type="boolean" />
	<cfargument name="SyscoUseMfgProductID" required="true" type="boolean" />
	<cfargument name="VendorOverrideForSyscoEDI" required="true" type="boolean" />
	<cfargument name="VendorID" required="true" type="string" />
	<cfargument name="VendorDefaultClosingMethodID" required="true" type="string" />
	<cfargument name="EnableBBDupCheck" required="true" type="boolean" />
	<cfargument name="SameDollarAmount" required="true" type="boolean" />
	<cfargument name="SameReferenceNumber" required="true" type="boolean" />
	<cfargument name="SamePayee" required="true" type="boolean" />
	<cfargument name="SameStartEndDates" required="true" type="boolean" />
	<cfargument name="SyscoEDIFilterNegativeInvoices" required="true" type="boolean" />
	<cfargument name="USFoodsEDIFilterNegativeInvoices" required="true" type="boolean" />
	<cfargument name="USFSConcatProgramAliasDesc" required="true" type="boolean" />
	<cfargument name="EDICreateBBPerAssociatedShipto" required="true" type="boolean" />
	<cfargument name="SyscoConcatProgramAliasID" required="true" type="boolean" />
	<cfargument name="III_P_Upload_Business_Segment" required="true" type="boolean" />
	<cfargument name="Third_Party_Upload_Ship_To_Column" required="true" type="string" />
	<cfargument name="III_P_Upload_Use_Closing_Method" required="true" type="boolean" />
	<cfargument name="III_Party_Load_Negative_Invoices_ADJ_and_PAID" required="true" type="boolean" />
	<cfargument name="III_P_Upload_Use_Holding_Pen" required="true" type="boolean" />

   <cfif arguments.III_party_Xref_Enabled EQ "0">
		<cfset arguments.Operator_Xref_Enabled = "0" />
		<cfset arguments.Allow_Multiple_Operator_Xref = "0">
   </cfif>

	<cfquery name="qSaveAdjustmentDefault" datasource="#application.datasource#">
	  UPDATE	Billback_Settings
	  SET		Manual_BB_Label               = <cfqueryparam value="#arguments.ManualBBLabel#" cfsqltype="CF_SQL_VARCHAR">
				,Uploaded_Via_App_Label        = <cfqueryparam value="#arguments.UploadedViaAppLabel#" cfsqltype="CF_SQL_VARCHAR">
				,Batch_Interface_Label         = <cfqueryparam value="#arguments.BatchInterfaceLabel#" cfsqltype="CF_SQL_VARCHAR">
				,Auto_Pay_Label                = <cfqueryparam value="#arguments.AutoPayLabel#" cfsqltype="CF_SQL_VARCHAR">
				,Auto_Approved_Label           = <cfqueryparam value="#arguments.AutoApprovedLabel#" cfsqltype="CF_SQL_VARCHAR">
				,BB_Type_Labels_Updated_By     = <cfqueryparam value="#arguments.BBTypeLabelsUpdatedBy#" cfsqltype="CF_SQL_VARCHAR">
				,III_Party_Xref_Enabled		= <cfqueryparam value="#arguments.III_Party_Xref_Enabled#" cfsqltype="CF_SQL_BIT">
				,Operator_Xref_Enabled 		= <cfqueryparam value="#arguments.Operator_Xref_Enabled#" cfsqltype="CF_SQL_BIT">
				,Allow_Multiple_Operator_Xref	= <cfqueryparam value="#arguments.Allow_Multiple_Operator_Xref#" cfsqltype="CF_SQL_BIT">
				,IS_ReferenceNum				= <cfqueryparam value="#arguments.IS_ReferenceNum#" cfsqltype="CF_SQL_BIT">
				,BB_Type_Labels_Updated_Date   = GetDate()
				,III_P_Upload_One_Pgm_Per_BB		  = <cfqueryparam value="#arguments.one_pgm_per_bb#" cfsqltype="CF_SQL_BIT">
				,III_P_Upload_Load_Claim_Price   = <cfqueryparam value="#arguments.load_claim_price#" cfsqltype="CF_SQL_BIT">
				,III_P_Upload_Alias_Uses_Eshark	= <cfqueryparam value="#arguments.alias_uses_eshark#" cfsqltype="CF_SQL_BIT">
				,III_P_Upload_Operator_Auto_Add	= <cfqueryparam value="#arguments.Operator_Auto_Add#" cfsqltype="CF_SQL_BIT">
				,Sysco_EDI_Use_Program_Xref			= <cfqueryparam value="#arguments.SyscoUseProgramXref#" cfsqltype="CF_SQL_BIT">
				,USFS_EDI_Use_Program_Xref				= <cfqueryparam value="#arguments.USFSUseProgramXref#" cfsqltype="CF_SQL_BIT">
				,Override_Use_Program_Xref			= <cfqueryparam value="#arguments.OverrideUseProgramXref#" cfsqltype="CF_SQL_BIT">
				,Sysco_Use_Mfg_Product_ID			= <cfqueryparam value="#arguments.SyscoUseMfgProductID#" cfsqltype="CF_SQL_BIT">
				,Vendor_Override_For_Sysco_EDI		= <cfqueryparam value="#arguments.VendorOverrideForSyscoEDI#" cfsqltype="CF_SQL_BIT">
				,Vendor_ID							= <cfqueryparam value="#arguments.VendorID#" cfsqltype="CF_SQL_VARCHAR">
				,Vendor_Default_Closing_Method_ID  = <cfqueryparam value="#arguments.VendorDefaultClosingMethodID#" cfsqltype="CF_SQL_TINYINT">
				,Enable_BB_Dup_Check				= <cfqueryparam value="#arguments.EnableBBDupCheck#" cfsqltype="CF_SQL_BIT">
				,Same_Dollar_Amount				= <cfqueryparam value="#arguments.SameDollarAmount#" cfsqltype="CF_SQL_BIT">
				,Same_Reference_Number				= <cfqueryparam value="#arguments.SameReferenceNumber#" cfsqltype="CF_SQL_BIT">
				,Same_Payee						= <cfqueryparam value="#arguments.SamePayee#" cfsqltype="CF_SQL_BIT">
				,Same_Start_End_Dates				= <cfqueryparam value="#arguments.SameStartEndDates#" cfsqltype="CF_SQL_BIT">
				,Sysco_Load_Negative_Invoices_ADJ_and_PAID = <cfqueryparam value="#arguments.SyscoEDIFilterNegativeInvoices#" cfsqltype="CF_SQL_BIT">
				,USF_Load_Negative_Invoices_ADJ_and_PAID = <cfqueryparam value="#arguments.USFoodsEDIFilterNegativeInvoices#" cfsqltype="CF_SQL_BIT">
				,USFS_Concat_Program_Alias_Desc  = <cfqueryparam value="#arguments.USFSConcatProgramAliasDesc#" cfsqltype="CF_SQL_BIT"> <!---D43360 --->
				,EDI_create_BB_per_Associated_Shipto = <cfqueryparam value="#arguments.EDICreateBBPerAssociatedShipto#" cfsqltype="CF_SQL_BIT"> <!--- D44290 --->
				,Sysco_Concat_Program_Alias_ID = <cfqueryparam value="#arguments.SyscoConcatProgramAliasID#" cfsqltype="CF_SQL_BIT"> <!--- D48482 --->
				,III_P_Upload_Business_Segment	= <cfqueryparam value="#arguments.III_P_Upload_Business_Segment#" cfsqltype="CF_SQL_BIT">
				,Third_Party_Upload_Ship_To_Column	= <cfqueryparam value="#arguments.Third_Party_Upload_Ship_To_Column#" cfsqltype="CF_SQL_VARCHAR">
				,III_P_Upload_Use_Closing_Method	= <cfqueryparam value="#arguments.III_P_Upload_Use_Closing_Method#" cfsqltype="CF_SQL_BIT"> <!--- D65807 --->
				,III_Party_Load_Negative_Invoices_ADJ_and_PAID = <cfqueryparam value="#arguments.III_Party_Load_Negative_Invoices_ADJ_and_PAID#" cfsqltype="CF_SQL_BIT"><!---74703--->
				,III_P_Upload_Use_Holding_Pen	= <cfqueryparam value="#arguments.III_P_Upload_Use_Holding_Pen#" cfsqltype="CF_SQL_BIT"> <!--- 85870 --->
	</cfquery>
  </cffunction>

  <cffunction name="getIII_P_UploadSingleBBPerINV">
	<cfquery name="qGetIII_P_UploadSingleBBPerINV" datasource="#application.datasource#">
	  SELECT 	III_P_Upload_Single_BB_Per_Invoice,III_P_Upload_Single_BB_Updated_By ,III_P_Upload_Single_BB_Updated_Date,_Users.Name_First + ' ' + _Users.Name_Last AS Updated_By
	  FROM        	Billback_Settings
	  LEFT JOIN 	_Users ON   _Users.User_ID = Billback_Settings.III_P_Upload_Single_BB_Updated_By
	</cfquery>
	<cfreturn  qGetIII_P_UploadSingleBBPerINV />
  </cffunction>

  <cffunction name="saveIII_P_UploadSingleBBPerINV" returnType="void">
	<cfargument name="III_P_Upload_Single_BB_Per_Invoice" required="true" type="boolean" />
	<cfquery name="qSaveIII_P_UploadSingleBBPerINV" datasource="#application.datasource#">
		UPDATE	Billback_Settings
		SET	III_P_Upload_Single_BB_Per_Invoice = <cfqueryparam value="#arguments.III_P_Upload_Single_BB_Per_Invoice#" cfsqltype="CF_SQL_BIT">
			,III_P_Upload_Single_BB_Updated_Date   = GetDate()
			,III_P_Upload_Single_BB_Updated_By   = '#request.AccessStructure.user_id#'
	</cfquery>

	<cfif arguments.III_P_Upload_Single_BB_Per_Invoice EQ "0">
		<cfquery name="qSaveAdjustmentDefault" datasource="#application.datasource#">
			update BB_III_Upload_Default_Dist
			set deleted = 1
			,Updated_By ='#request.AccessStructure.user_id#'
			where deleted = 0
		</cfquery>
	</cfif>
  </cffunction>
<!--- 69678 :: Modify Auto Match logic to use Family and Reference only based on the Setting START---->
	<cffunction name="GetFamilyNames" access="public" returntype="any" output="false" displayname="GetFamilyNames" hint="Gets the family names.">
		<CFQUERY NAME="qGetFamilyList" DATASOURCE="#Application.Datasource#">
			SELECT *
			FROM Distributor_Family
			WHERE Deleted = 0
			ORDER BY Family_Name
		</CFQUERY>
		<cfreturn qGetFamilyList>
	</cffunction>

	<cffunction name="GetExistingFamilyNames" access="public" returntype="any" output="false" displayname="GetExistingFamilyNames" hint="Gets Existing family names.">
		<cfargument name="fromAutoMatch" required="true">
		<cfargument name="fromAutoDeviation" required="true">

		<CFQUERY NAME="qGetFamilyList" DATASOURCE="#Application.Datasource#">
			SELECT DF.Family_ID, Family, Family_Name
			FROM Auto_Match_Deviation_Family AMDF
			INNER JOIN Distributor_Family DF
			ON DF.Family_ID = AMDF.Family_ID
			AND DF.deleted = 0
			WHERE <cfif arguments.fromAutoMatch>
						Auto_Match_Family = 1
				  <cfelse>
				  	Auto_Deviation_Family = 1
				  </cfif>
		</CFQUERY>

		<cfreturn qGetFamilyList>
	</cffunction>

	<cffunction name="UpdateFamilyRecords" access="public" returntype="any" output="false" displayname="Update Family for Auto Match or Deviations" hint="Update Family.">
		<cfargument name="fromAutoMatch" required="true">
		<cfargument name="fromAutoDeviation" required="true">
		<cfargument name="familyList" required="true">

		<cfloop list="#arguments.familyList#" index="Family">

			<cfset Action_Notes="">

			<CFQUERY NAME="qCheckFamily" DATASOURCE="#Application.Datasource#">
				SELECT Auto_Match_Family, Auto_Deviation_Family
				FROM Auto_Match_Deviation_Family
				WHERE Family_ID = '#Family#'
			</CFQUERY>

			<cfif qCheckFamily.recordcount>

				<cfif arguments.fromAutoMatch and qCheckFamily.Auto_Match_Family eq 0>

					<CFQUERY NAME="qUpdateAutoMatchFamily" DATASOURCE="#Application.Datasource#">
						UPDATE Auto_Match_Deviation_Family
						SET Auto_Match_Family = 1, User_ID='#request.AccessStructure.User_ID#',Updated_Date=getdate()
						WHERE Family_ID = '#Family#'
					</CFQUERY>

					<cfset Action_Notes ="Auto Match-Updated">
				<cfelseif arguments.fromAutoDeviation and qCheckFamily.Auto_Deviation_Family eq 0>

					<CFQUERY NAME="qUpdateAutoDeviationFamily" DATASOURCE="#Application.Datasource#">
						UPDATE Auto_Match_Deviation_Family
						SET Auto_Deviation_Family = 1, User_ID='#request.AccessStructure.User_ID#',Updated_Date=getdate()
						WHERE Family_ID = '#Family#'
					</CFQUERY>

					<cfset Action_Notes ="Auto Deviation-Updated">
				</cfif>


			<cfelse>
				<!--- IF RECORD DOESN'T EXIST WE WILL INSERT THAT FAMILY WITH "Auto_Match_Family = 1" SO THAT FAMILY WILL CONSIDER IN AUTO MATCH--->
				<CFQUERY NAME="qInsertFamily" DATASOURCE="#Application.Datasource#">
					INSERT INTO Auto_Match_Deviation_Family (Family_ID,Auto_Match_Family,Auto_Deviation_Family,User_ID)
					VALUES('#Family#',<cfif arguments.fromAutoMatch>1<cfelse>0</cfif>, <cfif arguments.fromAutoDeviation>1<cfelse>0</cfif>, '#request.AccessStructure.User_ID#')
				</CFQUERY>

				<cfif arguments.fromAutoMatch>
					<cfset Action_Notes ="Auto Match-Added">
				<cfelse>
					<cfset Action_Notes ="Auto Deviation-Added">
				</cfif>

			</cfif>
			<!--- INSERT INTO HISTORY TABLE --->
			<cfif len(Action_Notes)>
				<CFQUERY NAME="qInsertIntoHistory" DATASOURCE="#Application.Datasource#">
					INSERT INTO Auto_Match_Deviation_Family_History (Family_ID,Auto_Match_Family,Auto_Deviation_Family,Action_Notes,User_ID)
					SELECT '#Family#',Auto_Match_Family,Auto_Deviation_Family,'#Action_Notes#','#request.AccessStructure.User_ID#'
					FROM Auto_Match_Deviation_Family
					WHERE Family_ID = '#Family#'
				</CFQUERY>
			</cfif>
		</cfloop>



		<CFQUERY NAME="qCheckCurrentFamily" DATASOURCE="#Application.Datasource#">
			SELECT *
			FROM Auto_Match_Deviation_Family
			WHERE Family_ID NOT IN (#listQualify(arguments.familyList,"'")#)
			AND <cfif arguments.fromAutoMatch>
					Auto_Match_Family = 1
				  <cfelse>
				  	Auto_Deviation_Family = 1
				  </cfif>
		</CFQUERY>

		<cfif qCheckCurrentFamily.recordcount>
			<cfloop query="#qCheckCurrentFamily#">
				<!--- IF FAMILY RECORD EXIST BUT NOT IN CURRENT USER SELECTED LIST THEN WE SET "Auto_Match_Family=0"--->
				<CFQUERY NAME="qUpdateFamily" DATASOURCE="#Application.Datasource#">
					UPDATE Auto_Match_Deviation_Family
					SET Updated_Date = getdate(), User_ID='#request.AccessStructure.User_ID#'
						<cfif arguments.fromAutoMatch>
							,Auto_Match_Family = 0
						<cfelse>
							,Auto_Deviation_Family = 0
						</cfif>
					WHERE Family_ID = '#Family_ID#'
				</CFQUERY>

				<cfif arguments.fromAutoMatch>
					<cfset Action_Notes ="Auto Match-Removed">
				<cfelse>
					<cfset Action_Notes ="Auto Deviation-Removed">
				</cfif>

				<CFQUERY NAME="qCheckFamily" DATASOURCE="#Application.Datasource#">
					SELECT *
					FROM Auto_Match_Deviation_Family
					WHERE Family_ID = '#Family_ID#'
					AND Auto_Match_Family = 0
					AND Auto_Deviation_Family = 0
				</CFQUERY>

				<cfif qCheckFamily.recordcount>
					<!--- IF "Auto_Match_Family=0" AND "Auto_Deviation_Family = 0" WE WILL DELETE THAT FAMILY RECORD --->
					<CFQUERY NAME="qDeleteFamilyRecord" DATASOURCE="#Application.Datasource#">
						DELETE  FROM Auto_Match_Deviation_Family
						WHERE Family_ID = '#Family_ID#'
						AND Auto_Match_Family = 0
						AND Auto_Deviation_Family = 0
					</CFQUERY>

					<cfset Action_Notes ="Record Removed">

					<CFQUERY NAME="qInsertIntoHistory" DATASOURCE="#Application.Datasource#">
						INSERT INTO Auto_Match_Deviation_Family_History (Family_ID,Auto_Match_Family,Auto_Deviation_Family,Action_Notes,User_ID)
						VALUES('#Family_ID#', 0, 0, '#Action_Notes#', '#request.AccessStructure.User_ID#')
					</CFQUERY>
				</cfif>

			</cfloop>
		</cfif>
	</cffunction>
<!--- 69678 Modify Auto Match logic to use Family and Reference only based on the Setting END--->
<!--- 76132 :: Enhancement: Set BB to Paid after Prepare Check Request --->
	<cffunction name="setBB2Paid" returntype="void">
		<cfargument name="Billback_ID" required="true">

		<cfquery name="Set_Status" datasource="#application.datasource#">
			UPDATE	Billback
			SET		Billback_Status_ID = 5,
					Paid_Date = getdate()
			WHERE 	Billback.Billback_ID = '#arguments.Billback_ID#'
		</cfquery>
	</cffunction>

</cfcomponent>