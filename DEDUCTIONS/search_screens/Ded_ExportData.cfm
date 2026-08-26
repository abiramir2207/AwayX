
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">
<cfcontent type="text/plain">
<cfheader name="Content-Disposition" value="attachment;filename=DeductionData.csv">
 
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />

 <cfset FieldNames = "">
 <!--- These fields are shown only under this condition. Make a list of these fields and append in the "HeaderList" variable --->
<cfif application.returned_customer_setting.DD_Show_IsTrade_Box_and_Associate_a_Program EQ 0>
	<cfif businessSegManager.isEnabled()>
		<cfset FieldNames = ListAppend(FieldNames,"Business Unit")>
		<cfset FieldNames = ListAppend(FieldNames,"Business Unit Desc")>
		<cfset FieldNames = ListAppend(FieldNames,"Operating Unit")>
		<cfset FieldNames = ListAppend(FieldNames,"Operating Unit Desc")>
		<cfset FieldNames = ListAppend(FieldNames,"#application.returned_customer_setting.q_brand_label_singular#")>
		<cfset FieldNames = ListAppend(FieldNames,"#application.returned_customer_setting.q_brand_label_singular# Legacy")>
		<cfset FieldNames = ListAppend(FieldNames,",")>
	</cfif>
</cfif>

<!---26491 get the labels for dd type, user ref 1/2--->
<cfset stDeductionLabels = createObject("component", "components.settings.Labels.Labels").init().GetDeductionLabelsStruct() />
<!--- There is a comma after the "FieldNames" variable (see above) and so there is no need to add a comma here --->
<!---D42846 :: Deduction tool upgrades
Added Notes,Invoice Number --->
<CFSET HeaderList = "Deduction Number,Amount,Date,Status,Analyst,#stDeductionLabels['Action']#,Invoice Number,Notes,Comments,#stDeductionLabels['Action']# Date,#stDeductionLabels['Reference']#,Supervisor,#stDeductionLabels['Customer Reference']#,Credit,#application.returned_customer_setting.shard_ship_to_label# Name,#application.returned_customer_setting.shard_ship_to_label#,#stDeductionLabels['Classification']#,Check Num,Balance,#stDeductionLabels['Reason Code']#,#FieldNames# #application.returned_customer_setting.operator_label_singular#,Closed Date,Closed By,#application.returned_customer_setting.billto_label# Name,#application.returned_customer_setting.billto_label#,#application.returned_customer_setting.broker_label_singular# Name,#application.returned_customer_setting.broker_label_singular# Shard,#application.returned_customer_setting.family_name_label_singular# Name,#application.returned_customer_setting.family_name_label_singular# Number,#application.returned_customer_setting.zone_label_singular# Name,#application.returned_customer_setting.zone_label_singular# Number,#application.returned_customer_setting.region_label_singular# Name,#application.returned_customer_setting.region_label_singular# Number,#application.returned_customer_setting.market_label_singular#">
<!---26491 added dd type, user reference 1/2--->
<cfoutput>#HeaderList#,#csvFormat(stDeductionLabels["Deduction Type"])#,#csvFormat(stDeductionLabels["User Ref 1"])#,#csvFormat(stDeductionLabels["User Ref 2"])#</cfoutput>
<cfsilent>
<CFINCLUDE TEMPLATE="Ded_Search_Query.cfm">
</cfsilent>
<CFLOOP QUERY="Get_Data">

<!---D42846 :: Deduction tool upgrades --->	
	<!---Get Recent Note--->
<cfset useLakebaseForDD_Notes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_notes")>
<cfif useLakebaseForDD_Notes>
<cftry>
<cfset DD_Notes = application.oLakebase.toQuery(
application.oLakebase.selectRows("dd_notes", {
"select" = "dd_note",
"deleted" = "eq.0",
"deduction_id" = "eq.#Deduction_ID#",
"order" = "dd_note_date.desc",
"limit" = "1"
}),
"dd_note"
)>
<cfcatch type="any">
<cfset useLakebaseForDD_Notes = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForDD_Notes><cfquery name="DD_Notes" datasource="#application.datasource#">
	SELECT TOP 1 DD_Note
	FROM 	DD_Notes
	WHERE 	DD_Notes.deleted = 0
	AND 	Deduction_ID = '#Deduction_ID#'
	ORDER BY DD_Note_Date DESC
</cfquery>
</cfif>
	
	<cfoutput>#Chr(13)##chr(10)#</CFOUTPUT>
	<cfoutput>#DD_DedID_SP_Number#,</cfoutput>
	<cfoutput>#DD_Amount#,</cfoutput>
	<cfoutput>#DATEFORMAT(DD_Date,"mm/dd/yyyy")#,</cfoutput>
	<cfoutput>#DD_Status_Description#,</cfoutput>
	<cfoutput>#Name_First# #Name_last#,</cfoutput>
	<cfoutput>#DD_Stage_Description#,</cfoutput>
	<!---D42846 :: Deduction tool upgrades --->	
	<cfoutput>#DD_Invoice_Number#,</cfoutput>
	<cfoutput>#REReplace(DD_Notes.DD_Note,"[^0-9A-Za-z ]","","all")#,</cfoutput>
	<!---D42846 :: Deduction tool upgrades --->	
	<cfoutput>#Replace(Comments, ",", "", "All")#,</cfoutput>
	<cfoutput>#DateFormat(Date_Completed,"mm/dd/yyyy")#,</cfoutput>
	<cfoutput>#Replace(DD_Reference, ",", "", "All")#,</cfoutput>
	<cfoutput><cfif Supervisor_FirstName neq "">#Supervisor_FirstName# #Supervisor_LastName#<cfelse><cfif Is_Supervisor EQ 1>#Name_First# #Name_last#<cfelse>#DefaultSupervisor.Name_First# #DefaultSupervisor.Name_Last#</cfif></cfif>,</cfoutput>
	<cfoutput>#Replace(DD_Customer_RefNo, ",", "", "All")#,</cfoutput>
	

 <CFIF len(trim(Get_Data.DD_Closure_ID)) GT 0 AND Get_Data.DD_Closure_Type IS 5>
		<cfset useLakebaseForAssociatedCredit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForAssociatedCredit>
<cftry>
<cfset AssociatedCredit = application.oLakebase.toQuery(
application.oLakebase.selectRows("deductions", {
"select" = "dd_dedid_sp_number",
"deduction_id" = "eq.#Get_Data.DD_Closure_ID#"
}),
"dd_dedid_sp_number"
)>
<cfcatch type="any">
<cfset useLakebaseForAssociatedCredit = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForAssociatedCredit><CFQUERY NAME="AssociatedCredit" DATASOURCE="#Application.Datasource#">
		 SELECT DD_DedID_SP_Number FROM Deductions WHERE Deduction_ID = '#Get_Data.DD_Closure_ID#'
				</CFQUERY>
</cfif>
		<CFIF AssociatedCredit.RecordCount GT 0>
				<cfoutput>#DD_DedID_SP_Number#,</cfoutput>
		<CFELSE>
				<cfoutput>,</cfoutput>
		</CFIF>
<CFELSE>
				<cfoutput>,</cfoutput>
 </CFIF>
<CFIF Distributor_ID NEQ "">
		<cfset useLakebaseForCri_Distri = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForCri_Distri>
<cftry>
<cfset Cri_Distri = application.oLakebase.toQuery(
application.oLakebase.selectRows("bsa_foodservice_customers", {
"select" = "name,ship_to",
"bsa_foodservice_customers_id" = "eq.#Distributor_ID#"
}),
"name,ship_to"
)>
<cfcatch type="any">
<cfset useLakebaseForCri_Distri = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForCri_Distri><CFQUERY NAME="Cri_Distri" DATASOURCE="#Application.Datasource#">
			SELECT NAME,Ship_To FROM BSA_Foodservice_Customers WHERE BSA_Foodservice_Customers_ID = '#Distributor_ID#'
		</CFQUERY>
</cfif>
<cfoutput>#Replace(Cri_Distri.NAME, ",", "","All")#, #Cri_Distri.Ship_To#,</cfoutput>
<CFELSE>
<cfoutput>,,</cfoutput>
</CFIF>
	<cfoutput>#Replace(DD_Classification_Desc, ",", "", "All")#,</cfoutput>
	<cfoutput>#Replace(DD_Check_Number, ",", "", "All")#,</cfoutput>
<CFQUERY NAME="GetParentBalance" DATASOURCE="#Application.Datasource#">
SELECT Sum(DD_Amount) As ParentBalance FROM deductions
WHERE dd_parent_Id = '#Deduction_ID#'
AND deduction_id not in 
			(SELECT deduction_id 
					FROM Deductions
					WHERE DD_Status = 4
					AND DD_Closure_Sent = 1)
</CFQUERY>
	<cfoutput>#val(GetParentBalance.ParentBalance)#,</cfoutput>
	<cfoutput>#DD_Reason_Code_Description#,</cfoutput>
<CFIF application.returned_customer_setting.DD_Show_IsTrade_Box_and_Associate_a_Program EQ 1>
	<CFIF businessSegManager.isEnabled()>
			<CFIF Business_Segment_ID NEQ "">
				<cfset useLakebaseForGetBusSeg = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("business_segment")>
<cfif useLakebaseForGetBusSeg>
<cftry>
<cfset GetBusSeg = application.oLakebase.toQuery(
application.oLakebase.selectRows("business_segment", {
"select" = "business_unit_id,business_unit_desc",
"business_segment_id" = "eq.#Business_Segment_ID#"
}),
"business_unit_id,business_unit_desc"
)>
<cfcatch type="any">
<cfset useLakebaseForGetBusSeg = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetBusSeg><CFQUERY NAME="GetBusSeg" DATASOURCE="#Application.Datasource#">
					SELECT Business_Unit_ID,Business_Unit_Desc FROM Business_Segment WHERE Business_Segment_ID = '#Business_Segment_ID#'
				</CFQUERY>
</cfif>
				<CFOUTPUT>#GetBusSeg.Business_Unit_ID#, #GetBusSeg.Business_Unit_Desc#,</CFOUTPUT>
			<CFELSE>
				<CFOUTPUT>, ,</CFOUTPUT>
			</CFIF>
	</CFIF>
</CFIF>
	<CFIF application.returned_customer_setting.DD_Show_IsTrade_Box_and_Associate_a_Program EQ 1>
		<CFIF businessSegManager.isEnabled()>
			<CFIF Operating_Unit_ID NEQ "">
				<cfset useLakebaseForGetOpUnit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("operating_unit")>
<cfif useLakebaseForGetOpUnit>
<cftry>
<cfset GetOpUnit = application.oLakebase.toQuery(
application.oLakebase.selectRows("operating_unit", {
"select" = "operating_unit_description,code",
"operating_unit_id" = "eq.#Operating_Unit_ID#"
}),
"operating_unit_description,code"
)>
<cfcatch type="any">
<cfset useLakebaseForGetOpUnit = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetOpUnit><CFQUERY NAME="GetOpUnit" DATASOURCE="#Application.Datasource#">
					SELECT Operating_unit_Description,Code FROM Operating_Unit WHERE Operating_Unit_ID = '#Operating_Unit_ID#'
				</CFQUERY>
</cfif>
				<CFOUTPUT>#GetOpUnit.Code#, #GetOpUnit.Operating_unit_Description#,</CFOUTPUT>
			<CFELSE>
				<CFOUTPUT>, ,</CFOUTPUT>
			</CFIF>
		</CFIF>
	</CFIF>
	<CFIF application.returned_customer_setting.DD_Show_IsTrade_Box_and_Associate_a_Program EQ 1>
		<CFIF businessSegManager.isEnabled()>
			<CFIF Q_Brand_ID NEQ "">
				<cfset useLakebaseForGetQBrand = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("q_brand_desc")>
<cfif useLakebaseForGetQBrand>
<cftry>
<cfset GetQBrand = application.oLakebase.toQuery(
application.oLakebase.selectRows("q_brand_desc", {
"select" = "q_brand,q_brand_legacy",
"q_brand_id" = "eq.#Q_Brand_ID#"
}),
"q_brand,q_brand_legacy"
)>
<cfcatch type="any">
<cfset useLakebaseForGetQBrand = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetQBrand><CFQUERY NAME="GetQBrand" DATASOURCE="#Application.Datasource#">
					SELECT Q_Brand,Q_Brand_Legacy FROM Q_Brand_Desc WHERE Q_Brand_ID = '#Q_Brand_ID#'
				</CFQUERY>
</cfif>
				<cfoutput>#Trim(GetQBrand.Q_Brand)#, #Trim(GetQBrand.Q_Brand_Legacy)#,</cfoutput>
			<CFELSE>
			<CFOUTPUT>, ,</CFOUTPUT>
			</CFIF>
		</CFIF>
	</CFIF>
	<CFIF DD_Operator_ID NEQ "">
		<cfset useLakebaseForGetOperator = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_operator")>
<cfif useLakebaseForGetOperator>
<cftry>
<cfset GetOperator = application.oLakebase.toQuery(
application.oLakebase.selectRows("dd_operator", {
"select" = "dd_operator_name",
"dd_operator_id" = "eq.#DD_Operator_ID#"
}),
"dd_operator_name"
)>
<cfcatch type="any">
<cfset useLakebaseForGetOperator = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetOperator><CFQUERY NAME="GetOperator" DATASOURCE="#Application.Datasource#">
			SELECT DD_Operator_Name FROM DD_Operator WHERE DD_Operator_ID = '#DD_Operator_ID#'
		</CFQUERY>
</cfif>
		<CFOUTPUT>#GetOperator.DD_Operator_Name#</CFOUTPUT>
	</CFIF>
	<CFOUTPUT>,</CFOUTPUT>
	<CFOUTPUT>#DATEFORMAT(DD_Date_Closed,"mm/dd/yyyy")#,</CFOUTPUT>
	<CFIF DD_Closed_By NEQ "">
		<cfset useLakebaseForGetName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGetName>
<cftry>
<cfset GetName = application.oLakebase.toQuery(
application.oLakebase.selectRows("_users", {
"select" = "name_first,name_last",
"user_id" = "eq.#DD_Closed_By#",
"deleted" = "eq.0"
}),
"name_first,name_last"
)>
<cfcatch type="any">
<cfset useLakebaseForGetName = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetName><CFQUERY NAME="GetName" DATASOURCE="#Application.Datasource#">
			SELECT Name_First, Name_Last FROM _Users WHERE User_ID = '#DD_Closed_By#' AND Deleted = 0
		</CFQUERY>
</cfif>
		<CFOUTPUT>#GetName.Name_First# #GetName.Name_Last#</CFOUTPUT>
	</CFIF>
	<CFOUTPUT>,</CFOUTPUT>

	<CFOUTPUT>#Replace(Name, ",", "", "All")#,</CFOUTPUT>
	<CFOUTPUT>#Replace(Shr_Bill_To, ",", "", "All")#,</CFOUTPUT>
	<CFOUTPUT>#Replace(Broker_Name, ",", "", "All")#,</CFOUTPUT>
	<CFOUTPUT>#Broker_Shard#,</CFOUTPUT>
	<CFOUTPUT>#Replace(Family_Name, ",", "", "All")#,</CFOUTPUT>
	<CFOUTPUT>#Family#,</CFOUTPUT>
	<CFOUTPUT>#Replace(Zone_Name, ",", "", "All")#,</CFOUTPUT>
	<CFOUTPUT>#Zone_Number#,</CFOUTPUT>
	<CFOUTPUT>#Replace(Region_Name, ",", "", "All")#,</CFOUTPUT>
	<CFOUTPUT>#Region_Number#,</CFOUTPUT>
	<CFSET ReplacedMarket = REPLACE(Market_Name,","," -","All")>
	
	<!--- Label D26840--->
	<CFSET Get_Data.DeductionType_Desc = REPLACE(Get_Data.DeductionType_Desc,",","","All")>
	<CFSET Get_Data.DD_User_Reference1 = REPLACE(Get_Data.DD_User_Reference1,",","","All")>
	<CFSET Get_Data.DD_User_Reference2 = REPLACE(Get_Data.DD_User_Reference2,",","","All")>
	
  <!---26491 added dd type, user reference 1/2--->
	<CFOUTPUT>#ReplacedMarket#,</CFOUTPUT>	
	<CFOUTPUT>#csvFormat(Get_Data.DeductionType_Desc)#,</CFOUTPUT>	
	<CFOUTPUT>#csvFormat(Get_Data.DD_User_Reference1)#,</CFOUTPUT>	
	<CFOUTPUT>#csvFormat(Get_Data.DD_User_Reference2)#</CFOUTPUT>	

	
</CFLOOP>

<!--- <CFQUERY NAME="InsertData" DATASOURCE="#Application.Datasource#">
	INSERT INTO 
	DD_Export_Search	(	DD_DedID_SP_Number,
							DD_Check_Number,
							DD_Amount_Operator,
							DD_Amount,
							DD_Amount2,
							DD_Date_Operator,
							DD_Date,
							DD_Date2,
							Tier_Number,
							DD_Status_ID,
							Analyst_User_ID,
							DD_Stage_ID,
							DD_Reason_Code_ID,
							Business_Segment_ID,
							Q_Brand_ID,
							DD_Operator_ID,
							DD_Date_Closed_Operator,
							DD_Date_Closed,
							DD_Date_Closed2,
							Distributor_ID,
							Broker_ID,
							Family_ID,
							Distributor_Bill_To_ID,
							Service_Zone_ID,
							Service_Region_ID,
							Service_Market_ID,
							Line_Of_Business_ID,
							Sort_By,
							Sort_Order,
							DD_Export_Status_ID,
							Created_By					)
							
	VALUES				(	<CFIF FORM.DD_Number NEQ "">
							'#FORM.DD_Number#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.Check_No NEQ "">
							'#FORM.Check_No#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.Check_No NEQ "">
							'#FORM.Check_No#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.DD_Amount NEQ "">
							'#FORM.DD_Amount#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.DD_To_Amount NEQ "">
							'#FORM.DD_To_Amount#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.Date_Operator NEQ "">
							'#FORM.Date_Operator#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.Date_Time NEQ "">
							'#FORM.Date_Time#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.To_Date_Time NEQ "">
							'#FORM.To_Date_Time#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.DD_Aging NEQ "">
							'#FORM.DD_Aging#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.DD_Status NEQ "">
							'#FORM.DD_Status#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.Analyst_User_ID NEQ "">
							'#FORM.Analyst_User_ID#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.DD_Stage_ID NEQ "">
							'#FORM.DD_Stage_ID#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.DD_Reason_Code_ID NEQ "">
							'#FORM.DD_Reason_Code_ID#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.Business_Segment_ID NEQ "">
							'#FORM.Business_Segment_ID#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.Q_Brand_ID NEQ "">
							'#FORM.Q_Brand_ID#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.DD_Operator_ID NEQ "">
							'#FORM.DD_Operator_ID#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.ClDate_Operator NEQ "">
							'#FORM.ClDate_Operator#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.ClDate_Time NEQ "">
							'#FORM.ClDate_Time#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.ClTo_Date_Time NEQ "">
							'#FORM.ClTo_Date_Time#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.Distributor_List NEQ "">
							'#FORM.Distributor_List#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.Broker_List NEQ "">
							'#FORM.Broker_List#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.Family_ID NEQ "">
							'#FORM.Family_ID#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.Distributor_Bill_To_ID NEQ "">
							'#FORM.Distributor_Bill_To_ID#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.Service_Zone_ID NEQ "">
							'#FORM.Service_Zone_ID#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.Service_Region_ID NEQ "">
							'#FORM.Service_Region_ID#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.Service_Market_ID NEQ "">
							'#FORM.Service_Market_ID#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.LINE_OF_BUSINESS_ID NEQ "">
							'#FORM.LINE_OF_BUSINESS_ID#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.SORT_BY NEQ "">
							'#FORM.SORT_BY#',
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF FORM.SORT_ORDER NEQ "">
							'#FORM.SORT_ORDER#',
							<CFELSE>
							NULL,
							</CFIF>							
							1,
							'#request.AccessStructure.User_ID#'		)
</CFQUERY>

<CFOUTPUT>#InsertData.DD_Export_Search_ID#</CFOUTPUT>
 --->
</body>
<cffunction name="csvFormat"  
        access="private"  
        output="false" hint="Returned csv friendly string that can be used in csv file">  
  <cfargument name="aString"
          required="true"
          type="String" hint="" />
  <cfreturn Replace(arguments.aString, ",", "", "all")>
</cffunction>
</html>
