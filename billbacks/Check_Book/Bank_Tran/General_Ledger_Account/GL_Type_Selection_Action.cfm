
<CFDUMP VAR="#FORM#">

	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Before insert check for same bbID and delete --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFQUERY NAME="Get_GUID" DATASOURCE="#Application.Datasource#">
		SELECT 	Payment_Data_Export_1_ID 
		FROM 	Payment_Data_Export_1 
		WHERE 	<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
					Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#' AND
				<CFELSE>
					Billback_ID = <CFOUTPUT>'#FORM.BBID#'</CFOUTPUT> AND
				</CFIF> 
				Deleted=0
	</CFQUERY>
	<CFIF Get_GUID.RecordCount GT 0>
		<CFQUERY NAME="Delete_Old_Entry" DATASOURCE="#Application.Datasource#">
			UPDATE 	Payment_Data_Export_2 
			SET	 	Deleted=1 
			WHERE 	Payment_Data_Export_1_ID =<CFOUTPUT>'#Get_GUID.Payment_Data_Export_1_ID#'</CFOUTPUT> AND 
					Deleted=0
		</CFQUERY>
		<CFQUERY NAME="Delete_Old_Entry" DATASOURCE="#Application.Datasource#">
			UPDATE 	Payment_Data_Export_1 
			SET 	Deleted=1 
			WHERE 	<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
					Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#' AND
					<CFELSE>
					Billback_ID = <CFOUTPUT>'#FORM.BBID#'</CFOUTPUT> AND 
					</CFIF>
					Deleted=0	
		</CFQUERY>
	</CFIF>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFIF Not IsDefined("Pay_Multi_Billbacks_ID")>
	<CFQUERY NAME="GetBBDetails" DATASOURCE="#Application.Datasource#">
		SELECT 			BB_Reference 	BB_reference,
						Paid_Amount 	Paid_Amount,
						BB_Date 		BB_Date,
						BB_Code
		
		FROM 			Billback 
		
		INNER JOIN 		BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
		
		WHERE 			Billback.Billback_ID = '#FORM.BBID#' AND Deleted = 0
	</CFQUERY>
	</CFIF>
	<cfset useLakebaseForGetPayeeInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_transaction")>
<cfif useLakebaseForGetPayeeInfo>
	<cftry>
		<cfset GetPayeeInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("payment_transaction", {
				"payment_trans_id" = "eq.#FORM.RID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetPayeeInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetPayeeInfo>
<CFQUERY NAME="GetPayeeInfo" DATASOURCE="#Application.Datasource#">
		SELECT * FROM Payment_Transaction WHERE Payment_Trans_ID = '#FORM.RID#'
	</CFQUERY>
</cfif>
	GetPayeeInfo
	<CFDUMP VAR="#GetPayeeInfo#">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Insert Data in Payment_Data_Export_1--->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFOUTPUT>
	<CFQUERY NAME="Insert_Data" DATASOURCE="#Application.Datasource#">
		INSERT INTO Payment_Data_Export_1 	(	<CFIF Not IsDefined("Pay_Multi_Billbacks_ID")>
												Billback_ID,												
												BB_Reference,												
												BB_Date,	
												BB_Code,	
												Tot_Amount,
												<CFELSE>
												Billback_ID,
												Tot_Amount,
												Pay_Multi_Billbacks_ID,
												</CFIF>																						
												Payment_Trans_ID,
												Customer_Name,
												Address1,
												Address2,
												City,
												State,
												Zipcode					)
	
		VALUES								(	<CFIF Not IsDefined("Pay_Multi_Billbacks_ID")>
												'#FORM.BBID#',												
												'#GetBBDetails.BB_reference#',												
												'#GetBBDetails.BB_Date#',	
												'#GetBBDetails.BB_Code#',
												#GetBBDetails.Paid_Amount#,		
												<CFELSE>
												'#GetPayeeInfo.Billback_ID#',
												#GetPayeeInfo.Amount#,
												#FORM.Pay_Multi_Billbacks_ID#,
												</CFIF>													
												#FORM.RID#,
												'#GetPayeeInfo.Payee_Name#',
												'#GetPayeeInfo.Payee_Address1#',
												'#GetPayeeInfo.Payee_Address2#',
												'#GetPayeeInfo.Payee_City#',
												'#GetPayeeInfo.Payee_State#',
												'#GetPayeeInfo.Payee_Zipcode#'		)
	</CFQUERY>		
	</CFOUTPUT>
	
	<CFQUERY NAME="Get_GUID_to_Insert" DATASOURCE="#Application.Datasource#">
		SELECT 	Payment_Data_Export_1_ID	
		FROM 	PAyment_Data_Export_1 
		WHERE 	<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
					Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#' AND
				<CFELSE>
					Billback_ID = <CFOUTPUT>'#FORM.BBID#'</CFOUTPUT> AND 
				</CFIF>
				Deleted=0
	</CFQUERY>	
	Get_GUID_to_Insert
	<CFDUMP VAR="#Get_GUID_to_Insert#">
	
	<CFSET BG_Count = 0>
	<CFSET List_Count = 0>
	 <CFLOOP INDEX="Loop_List" LIST="#FORM.GL_QBrand_ID#" DELIMITERS=",">
		<CFSET List_Count = List_Count + 1>
		<CFSET QBrand_Amount = #ListGetAt(#FORM.GL_Tol_Amount#,#List_Count#,",")#>
		<CFSET BelongToBB = ListGetAt(FORM.MultiBBID,List_Count,",")>
		<CFSET ReplacedBelongToBB = REPLACE(BelongToBB,"-","_","All")>
		<CFIF QBrand_Amount NEQ 0>
			<CFSET QBrand_Amount = QBrand_Amount * 100>
			<CFSET QBrand_Amount = Round(QBrand_Amount)>
			<CFSET QBrand_Amount = QBrand_Amount / 100>
			<CFSET GL_TYPE_ID = #EVALUATE("FORM.GL_Type_#List_Count#_#ReplacedBelongToBB#")#>
		<CFOUTPUT> ---#GL_TYPE_ID# #BelongToBB#--- </CFOUTPUT>
		<cfset useLakebaseForGLDesc = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_type")>
<cfif useLakebaseForGLDesc>
	<cftry>
		<cfset GLDesc = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_type", {
				"gl_type_id" = "eq.#GL_Type_ID#",
				"select" = "gl_type_desc"
			}), "gl_type_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGLDesc = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGLDesc>
<CFQUERY NAME="GLDesc" DATASOURCE="#Application.Datasource#">
			SELECT GL_Type_Desc FROM GL_Type WHERE GL_Type_ID = '#GL_Type_ID#'
		</CFQUERY>
</cfif>		
	
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Insert Data in Payment_Data_Export_2--->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->	
		<CFOUTPUT>
		<CFQUERY NAME="Insert_Data" DATASOURCE="#Application.Datasource#">
			INSERT INTO Payment_Data_Export_2 		(	Payment_Data_Export_1_ID,
														Amount,
														GL_Type,														
														Q_Brand_ID,
														GL_Type_ID,
														Billback_ID						)
		
			VALUES									(	'#Get_GUID_to_Insert.Payment_Data_Export_1_ID#',
														#QBrand_Amount#,
														'#GLDesc.GL_Type_Desc#',														
														'#Loop_List#',
														'#GL_Type_ID#',
														'#BelongToBB#'					)	
		</CFQUERY>
		</CFOUTPUT>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

		<CFELSE>
			<CFSET FORM.GL_QBrand_ID = #ListDeleteAt(FORM.GL_QBrand_ID,#List_Count#,",")#>
			<CFSET FORM.GL_Tol_Amount = #ListDeleteAt(FORM.GL_Tol_Amount,#List_Count#,",")#>
			<CFSET List_Count = List_Count - 1>
		</CFIF>
	</CFLOOP>

	<CFOUTPUT>	
	<CFIF Isdefined("Pay_Multi_Billbacks_ID")>
	<CFLOCATION URL="View_Edit_Approve.cfm?BBID=#FORM.BBID#&Pay_Multi_Billbacks_ID=#Pay_Multi_Billbacks_ID#&Payment_Data_Export_1_ID=#Get_GUID_to_Insert.Payment_Data_Export_1_ID#&GetPaymentInfo=1" ADDTOKEN="No">
	<CFELSE>
	<CFLOCATION URL="View_Edit_Approve.cfm?BBID=#FORM.BBID#&Payment_Data_Export_1_ID=#Get_GUID_to_Insert.Payment_Data_Export_1_ID#&GetPaymentInfo=1" ADDTOKEN="No">
	</CFIF>	
	</CFOUTPUT>