<cfparam name="CID" default="">
<cfparam name="Export_Sales_Agreement_ID" default="">
<cfparam name="Action" default="">
<cfparam name="Form.product_list" default="">
<cfparam name="Form.Export_Is_Sales_Agreement" default="">
<cfparam name="Form.Export_Sticker_Type"  default="0">
<cfparam name="Form.Export_Sales_Agreement_Name" default="">
<cfparam name="Form.Export_ASI_Contract_Number" default="">
<cfparam name="Form.start_date" default="">
<cfparam name="Form.end_date" default="">
<cfparam name="Form.Export_Agreement_Validity" default="">
<cfparam NAME="Form.Export_Distributor_ID" default="">
<cfparam NAME="Form.Export_Distributor" default="">
<cfparam NAME="Form.Export_Shr_Bill_To" default="">
<cfparam name="Form.Export_Terms_of_Sale" default="">
<cfparam name="Form.Export_Named_Place" default="">
<cfparam name="Form.Export_Mexico_Port" default="">
<cfparam name="Form.Export_Origin" default="">
<cfparam name="Form.Export_Destination_Country" default="">
<cfparam name="Form.Export_Pallet_Indicator" default="">
<cfparam name="Form.Export_Pallet_Type" default="">
<cfparam NAME="Form.Distributor_List" default="">
<cfparam NAME="Form.Export_Shr_Ship_To" default="">
<cfparam NAME="Form.Export_Invoice_Terms_Desc" default="">
<cfparam NAME="Form.Export_Invoice_Terms" default="">
<cfparam NAME="Form.Export_Freight_Cost" default="">
<cfparam NAME="Form.Export_Additional_Freight_Cost" default="">
<cfparam NAME="Form.Export_Inland_Fuel_Surcharge" default="">
<cfparam NAME="Form.Export_Additional_Inland_Fuel_Surcharge" default="">
<cfparam NAME="Form.Export_Ocean_Fuel_Surcharge" default="">
<cfparam NAME="Form.Export_Additional_Ocean_Fuel_Surcharge" default="">
<cfparam NAME="Form.Export_Internal_Notes" default="">
<cfparam NAME="Form.Export_Special_Conditions" default="">
<cfparam NAME="Form.Export_Notify_Party" default="">
<cfparam name="Form.Is_A_Revision" default="0">

<cfif Action neq "">

<cf_cryp type="de" key="#request.key#" string="#CID#">

<cfif len(CID) NEQ 0>
	<cfset Export_Sales_Agreement_ID = cryp.value>
</cfif>

<!--- Get the current user's position ID--->
<cfset This_User_Position_ID = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.User_ID)>

<cftransaction>

	<cfinclude template="Sales_Agreement_Number_Generator.cfm">
		
		<!--- Add a new contract on Revise/Copy (Add certain fields on these actions) --->
	  <cfquery name="InsertExportSalesAgreement" datasource="#application.datasource#">
		SET NOCOUNT ON

		INSERT INTO Export_Sales_Agreement(Export_Sales_Agreement_Name,Export_Sales_Agreement_Number,Export_ASI_Contract_Number<cfif action eq "Copy">,Export_Start_Date</cfif>
		,Export_End_Date,Creator_ID,Creating_User_Position_ID,Contract_Status_Type_IDX,Revision_Version,Parent_Revised_Export_Sales_Agreement_ID
		,Revision_of_Export_Sales_Agreement_ID,Is_A_Revision,Export_Agreement_Validity,Export_Distributor_ID,Export_Invoice_Terms<cfif action eq "Copy">,Export_Terms_of_Sale
		,Export_Named_Place,Export_Mexico_Port,Export_Origin,Export_Destination_Country,Export_Pallet_Indicator,Export_Pallet_Type</cfif>,Export_Is_Sales_Agreement
		,Export_Freight_Cost,Export_Additional_Freight_Cost,Export_Inland_Fuel_Surcharge,Export_Additional_Inland_Fuel_Surcharge,Export_Ocean_Fuel_Surcharge
		,Export_Additional_Ocean_Fuel_Surcharge,Export_Stickering_Cost_ID,Export_Internal_Notes,Export_Special_Conditions,Export_Notify_Party)

		<!--- For Offers (not sales agreements), 'End date' can be null --->
		VALUES('#Export_Sales_Agreement_Name#',<cfif action eq "Copy">'#generator_contract_number#'<cfelseif action eq "Revise">NULL</cfif>
		,'#Form.Export_ASI_Contract_Number#'<cfif action eq "Copy">,'#Start_Date#'</cfif>,<CFIF IsDefined("End_Date")><CFIF IsDate(End_Date)>'#End_Date#'<CFELSE>NULL</CFIF><CFELSE>NULL</CFIF>,'#request.AccessStructure.User_ID#','#This_User_Position_ID#'
		,1<cfif action eq "Copy">,1<cfelseif action eq "Revise">,NULL</cfif>
		,NULL<cfif action eq "Revise">,'#Export_Sales_Agreement_ID#'<cfelse>,NULL</cfif>
		<cfif action eq "Revise">,1<cfelse>,0</cfif>,#Export_Agreement_Validity#,<CFIF Export_Distributor_ID neq "">'#Export_Distributor_ID#'<CFELSE>NULL</CFIF>,'#Export_Invoice_Terms#'
		<!--- For Revision, we dont want to insert these values from the form, as these values have to be the parent program values --->
		<cfif action eq "Copy">,'#Export_Terms_of_Sale#','#Export_Named_Place#','#Export_Mexico_Port#','#Export_Origin#','#Export_Destination_Country#',#Export_Pallet_Indicator#,'#Export_Pallet_Type#'</cfif>
		,#Export_Is_Sales_Agreement#,'#val(Export_Freight_Cost)#','#val(Export_Additional_Freight_Cost)#','#val(Export_Inland_Fuel_Surcharge)#'
		,'#val(Export_Additional_Inland_Fuel_Surcharge)#','#val(Export_Ocean_Fuel_Surcharge)#','#val(Export_Additional_Ocean_Fuel_Surcharge)#','#Export_Sticker_Type#'
		,'#Trim(Export_Internal_Notes)#','#Trim(Export_Special_Conditions)#','#Trim(Export_Notify_Party)#')

		SELECT Export_Sales_Agreement_ID = @@IDENTITY
		SET NOCOUNT OFF
		</cfquery>
	
	<!--- Get the new sales agreement id --->
	<cfset New_Export_Sales_Agreement_ID = InsertExportSalesAgreement.Export_Sales_Agreement_ID>

	<!--- Get the data for the program to be copied/revised --->
	<cfquery name="SelectExportSalesAgreement" datasource="#application.datasource#">
		SELECT Export_Freight_Cost,Export_Additional_Freight_Cost,Export_Inland_Fuel_Surcharge,Export_Additional_Inland_Fuel_Surcharge
		,Export_Ocean_Fuel_Surcharge,Export_Additional_Ocean_Fuel_Surcharge,Export_Stickering_Cost_ID,Export_Internal_Notes
		,Export_Special_Conditions,Export_Notify_Party
		<cfif action eq "Revise"> 
		,Export_Sales_Agreement_Number,Revision_Version + 1 As Revision_Version
			,CASE Revision_Version
				WHEN 1 THEN
					'#Export_Sales_Agreement_ID#'
				ELSE
				Parent_Revised_Export_Sales_Agreement_ID
			END
				As Parent_Revised_Export_Sales_Agreement_ID
		,Export_Start_Date,Export_Terms_of_Sale,Export_Named_Place,Export_Mexico_Port,Export_Origin,Export_Destination_Country
		,Export_Pallet_Indicator,Export_Pallet_Type
		</cfif>

		FROM Export_Sales_Agreement
		WHERE Export_Sales_Agreement_ID =  '#Export_Sales_Agreement_ID#'
	</cfquery>

<cfif action eq "Revise"> 

	<!--- Update the new contract with the old contract values --->
	<cfquery name="InsertExportSalesAgreement" datasource="#application.datasource#">
<!--- For both revision and copy, get these values from the parent program --->
	UPDATE Export_Sales_Agreement
		SET Export_Sales_Agreement_Number = '#SelectExportSalesAgreement.Export_Sales_Agreement_Number#'
		,Revision_Version = '#SelectExportSalesAgreement.Revision_Version#'
		,Parent_Revised_Export_Sales_Agreement_ID =  '#SelectExportSalesAgreement.Parent_Revised_Export_Sales_Agreement_ID#'
		,Export_Start_Date = '#SelectExportSalesAgreement.Export_Start_Date#'
		,Export_Terms_of_Sale = '#SelectExportSalesAgreement.Export_Terms_of_Sale#'
		,Export_Named_Place = '#SelectExportSalesAgreement.Export_Named_Place#'
		,Export_Mexico_Port = '#SelectExportSalesAgreement.Export_Mexico_Port#'
		,Export_Origin = '#SelectExportSalesAgreement.Export_Origin#'
		,Export_Destination_Country = '#SelectExportSalesAgreement.Export_Destination_Country#'
		,Export_Pallet_Indicator = '#SelectExportSalesAgreement.Export_Pallet_Indicator#'
		,Export_Pallet_Type = '#SelectExportSalesAgreement.Export_Pallet_Type#'
	WHERE Export_Sales_Agreement_ID = '#New_Export_Sales_Agreement_ID#'
	</cfquery>
</cfif>

		<!--- If its a revison, delete the parent program --->
		<cfif action eq "Revise">
			<cfquery name="UpdateExportSalesAgreement" datasource="#application.datasource#">
				UPDATE Export_Sales_Agreement
				SET Deleted = 1
				WHERE Export_Sales_Agreement_ID = '#Export_Sales_Agreement_ID#'
			</cfquery>
		</cfif>

			<cfloop list="#StructKeyList(form)#" index="key"> 
				<cfif Left(key,16) eq "Export_Cost_Desc">
				<cfset Cost_Number = RemoveChars(key,1,find("_",key,16))>
				<cfif Evaluate("Export_Cost_Desc_"&Cost_Number) neq "" AND Evaluate("Export_Cost_Desc_"&Cost_Number) neq 0>
						<cfquery name="InsertExportCost" datasource="#application.datasource#">
							INSERT INTO Export_Cost(Export_Sales_Agreement_ID,Export_Cost_Desc,Export_Cost,Export_Additional_Cost,Show_Order_Sequence)
							VALUES('#New_Export_Sales_Agreement_ID#','#Evaluate("Export_Cost_Desc_"&Cost_Number)#','#val(Evaluate("Export_Cost_"&Cost_Number))#','#val(Evaluate("Export_Additional_Cost_"&Cost_Number))#','#Cost_Number#')
						</cfquery>
					</cfif>
				</cfif>
	
				<cfif Left(key,21) eq "Export_Misc_Cost_Desc">
				<cfset Cost_Number = RemoveChars(key,1,find("_",key,21))>
				<cfif Evaluate("Export_Misc_Cost_Desc_"&Cost_Number) neq "" AND Evaluate("Export_Misc_Cost_Desc_"&Cost_Number) neq 0>
						<cfquery name="UpdateExportSalesAgreement" datasource="#application.datasource#">
							INSERT INTO Export_Misc_Cost(Export_Sales_Agreement_ID,Export_Misc_Cost_Desc,Export_Misc_Cost,Show_Order_Sequence)
							VALUES('#New_Export_Sales_Agreement_ID#','#Evaluate("Export_Misc_Cost_Desc_"&Cost_Number)#','#val(Evaluate("Export_Misc_Cost_"&Cost_Number))#','#Cost_Number#')
						</cfquery>
					</cfif>
				</cfif>
			</cfloop> 

		<cfif ListLen(form.product_List) GT 0>
			<cfloop list="#form.Product_List#" index="i">
			<CFSET FieldNameEnd = replace(i,"-","_","ALL")>
			
			<!--- Since Notes are added for every individual product, we get the notes for the existing products (if any) and then add that
						notes to the newly added products --->
			<cfquery name="SelectExportNotes" datasource="#application.datasource#">
				SELECT Export_Notes 
				FROM Export_Products
				WHERE Export_Sales_Agreement_ID = '#Export_Sales_Agreement_ID#'
				AND BSA_Foodservice_Items_Master_ID ='#i#'
				AND Deleted = 0
			</cfquery>

				<cfquery name="InsertExportProducts" datasource="#application.datasource#">
				SET NOCOUNT ON

				INSERT INTO Export_Products (BSA_Foodservice_Items_Master_ID,Export_Sales_Agreement_ID,Export_Target_Net_Sales_Price,Export_Sale_Unit_Price
				,Export_Sticker,Export_Sticker_Rate,Export_Origin_Relocation_Cost,Export_Accrual,Export_Charge,Export_Estimated_Net_Sales_Price,Export_End_User
				,Export_Required_Volume,Export_Volume_Limit,Export_Net_Loadability)
				VALUES('#i#',#New_Export_Sales_Agreement_ID#,'#val(Evaluate("Export_Target_Net_Sales_Price_#FieldNameEnd#"))#','#val(Evaluate("Export_Sale_Unit_Price_#FieldNameEnd#"))#'
				,<cfif IsDefined("Export_Sticker_#FieldNameEnd#")>#val(Evaluate("Export_Sticker_#FieldNameEnd#"))#<cfelse>0</cfif>,'#val(Evaluate("Export_Sticker_Rate_#FieldNameEnd#"))#','#val(Evaluate("Export_Origin_Relocation_Cost_#FieldNameEnd#"))#'
				,'#val(Evaluate("Export_Accrual_#FieldNameEnd#"))#','#val(Evaluate("Export_Charge_#FieldNameEnd#"))#','#val(Evaluate("Export_Estimated_Net_Sales_Price_#FieldNameEnd#"))#'
				,'#Evaluate("Export_End_User_#FieldNameEnd#")#',#Evaluate("Export_Required_Volume_#FieldNameEnd#")#,'#Evaluate("Export_Volume_Limit_#FieldNameEnd#")#'
				,'#val(Evaluate("Export_Net_Loadability_#FieldNameEnd#"))#')

				SELECT Export_Product_ID = @@IDENTITY
				SET NOCOUNT OFF
				</cfquery>

			<cfset Export_Product_ID = InsertExportProducts.Export_Product_ID>

			<cfquery name="UpdateExportNotes" datasource="#application.datasource#">
				UPDATE Export_Products 
				SET Export_Notes = '#SelectExportNotes.Export_Notes#'
				WHERE Export_Sales_Agreement_ID = '#New_Export_Sales_Agreement_ID#'
				AND BSA_Foodservice_Items_Master_ID = '#i#'
				AND Deleted = 0
			</cfquery>
			</cfloop>
		</cfif>
		
</cftransaction>

<!--- Unlock the current user's locked programs --->
<cfquery name="unlockTheirPrograms" datasource="#application.datasource#">
	UPDATE Export_Sales_Agreement
	SET	Sales_Agreement_Is_Locked = 0 
	WHERE Sales_Agreement_Locked_By_User_ID = '#request.AccessStructure.User_ID#' 
	AND Deleted = 0 
</cfquery>

<!--- Lock the new created program --->
<cfquery NAME="lockContractFromOtherUsers" datasource="#application.datasource#">
	UPDATE Export_Sales_Agreement
	SET Sales_Agreement_Is_Locked = 1
	,Sales_Agreement_Locked_By_User_ID = '#request.AccessStructure.User_ID#'
	,Sales_Agreement_Lock_Date = #createodbcdatetime(Now())#
	WHERE Export_Sales_Agreement_ID = '#New_Export_Sales_Agreement_ID#'
</cfquery>

	<CF_CRYP type="en" string="#New_Export_Sales_Agreement_ID#" key="#request.key#">

	<cflocation url="Sales_Agreement.cfm?CID=#cryp.value#">

</cfif>
