
<!--- OCRUploadDAO  = CreateObject("component","components.Billback.OCRUploadDAO"); --->
<cfcomponent hint="Data Access for CIA Data">
	
	<cffunction name="gdata" returntype="query">		
 		<cfquery name="qGetData" datasource="#application.datasource#">
			SELECT * FROM 
				OCR_Upload_Log OUL
				INNER JOIN OCR_Template_Settings OTS /* was LEFT JOIN before*/
				ON OTS.OCR_Template_Settings_ID = OUL.OCR_Template_Settings_ID 
				AND OTS.Deleted = 0
			
			WHERE 
					OUL.Deleted = 0	AND	
					(OUL.OCR_Step = '1') /* OR OCR_Step = '2.CF_Error' */
			ORDER BY
					OUL.OCR_Upload_Date DESC 
		</cfquery>
		<cfreturn qGetData>
	</cffunction>
	
	<cffunction name="updUploadLogStatus" returntype="void">
		<cfargument name="step" required="true" type="String" default='2.CF_Error'/>
		<cfargument name="uploadStatus" required="true" type="String"/>
		<cfargument name="devStatus" required="true" type="String"/>
		<cfargument name="uploadId" required="true" type="numeric"/>
		<cfargument name="DB_Input_FileName" required="false" type="String" default=""/>
		<cfquery name="updateOCRUploadLogStatus" datasource="#application.datasource#">
			UPDATE OCR_Upload_Log 
			SET 
				OCR_Step = '#arguments.step#',
				OCR_Upload_Status = '#arguments.uploadStatus#',
				Debug_Dev_Status = '#arguments.devStatus#'
				<cfif len(DB_Input_FileName) GT 0>
					,DB_Input_FileName = '#arguments.DB_Input_FileName#'
				</cfif>
			WHERE OCR_Upload_ID = #arguments.uploadId#
		</cfquery>
	</cffunction>
	
	<cffunction name="updUploadLogStatusConverted" returntype="void">
		<cfargument name="uploadId" required="true" type="numeric"/>
		<cfargument name="fName" required="false" type="String" default=""/>
		<cfscript>
			//handle .xlsb
			var iLen = len(fName);
			if(right(fName,1) == 'b'){
				fname = left(fname, iLen-1);
			}
		</cfscript>
		<cfquery name="updateOCRUploadLogStatus" datasource="#application.datasource#">
			UPDATE OCR_Upload_Log 
			SET 
				File_Name = case Right(File_Name,1)
							when 'b' then replace(File_Name,'.xlsb','.xlsx')
							else replace(File_Name,'.xls','.xlsx')
							end
			WHERE OCR_Upload_ID = #arguments.uploadId#
		</cfquery>
	</cffunction>

	<cffunction name="updOCR_Trackmax1_Excel_Format_NumberFormats" returntype="void">
		<cfargument name="uploadId" required="true" type="numeric"/>
		
		<cfquery name="updateItemAmount" datasource="#application.datasource#">
			UPDATE OCR_Trackmax1_Excel_Format 
			SET Item_Amount = CAST(CAST(Item_Amount AS FLOAT) AS DECIMAL(18,4)) 
			where  OCR_Upload_ID = #arguments.uploadId# 
					AND Item_Amount like '%E%' 
					AND isnumeric(Item_Amount) = 1
		</cfquery>

		<cfquery name="updateItemQuantity" datasource="#application.datasource#">
			UPDATE OCR_Trackmax1_Excel_Format 
			SET Item_Quantity = CAST(CAST(Item_Quantity AS FLOAT) AS DECIMAL(18,4)) 
			where  OCR_Upload_ID = #arguments.uploadId# 
					AND Item_Quantity like '%E%' 
					AND isnumeric(Item_Quantity) = 1
		</cfquery>
	</cffunction>

	<cffunction name="insOCR_PFG_Operator_PDF_Excel_Format" returntype="void">

		<cfquery name="qInsOCR_PFG_Operator_PDF_Excel_Format" datasource="#application.datasource#">
		INSERT INTO  OCR_PFG_Operator_PDF_Excel_Format (
									Distributor_Location,
									Invoice_Number,
									Invoice_Date,
									Start_Date,
									End_Date,
									MFG_Info,
									Program_Info,
									Item_Row_ID,
									Item,
									Item_Description,
									Item_UPC,
									Item_Vendor,
									Item_Contract_ID,
									Item_Invoice,
									---Item_Brand,
									Item_Quantity,
									Item_Avg_Each,
									Item_Allowance,
									Item_Amount,
									Item_T,
									Total_Quantity,
									Total_Avg_Each,
									Total_Allowance,
									Total_Amount,
									Total_Invoice_Items,
									Page_Count,
									--OCR_PFG_Operator_PDF_Excel_Format_ID,
									OCR_Input_FileName_Raw,
									DB_OCR_Source_Code_FileName,
									OCR_Upload_ID,
									OCR_Source,
									BB_Claim_Source_XREF_ID,
									OCR_Template_Settings_ID,
									DB_OCR_Source_Code,
									OCR_FILE_CAPTURE_ID,
									Is_debug,
									Source,
									Vendor_Number,
									Program_Number,
									Customer_Reference,
									Payee_TYPE,
									Distributor_ID,
									Operator_ID,
									Closing_Method,
									Billback_Date,
									BB_Start_Date,
									BB_End_Date,
									Item_Number,
									Item_Volume_Qty,
									Item_Dollar_Amount,
									Associated_Distributor_ID,
									UOM,
									Trade_Indicator,
									Lump_Sum_Indicator,
									File_Name,
									Component_Name,
									Unknown,
									Upload_File_Name,
									Cust_Desc,
									Address,
									State,
									User_Input_Amount,
									Sum_Item_Dollar_Amount,
									Invalid,
									Invalid_Amount,
									Err_Msg,
									Err_Column,
									Err_Number,
									BA_Format_Validation,
									BA_Format_Validate_Date,
									BB_Upload_ID,
									Reviewed_Date,
									Reviewed_By,
									Reviewed_Notes,
									Updated_Date,
									Updated_By,
									Deleted,
									Created_Date,
									OCR_Code ) 
								SELECT 
									Distributor_Location,
									Invoice_Number,
									Invoice_Date,
									Start_Date,
									End_Date,
									MFG_Info,
									Program_Info,-- (select top 1 Program_Info from ##Tmp_OCR_PFG_Operator_PDF_Excel_Format Where MFG_Info = T.MFG_Info) AS Program_Info, 
									Item_Row_ID,
									Item,
									Item_Description,
									Item_UPC,
									Item_Vendor,
									Item_Contract_ID,
									Item_Invoice,
									--Item_Brand,
									Item_Quantity,
									Item_Avg_Each,
									Item_Allowance,
									Item_Amount,
									Item_T,
									Total_Quantity,
									Total_Avg_Each,
									Total_Allowance,
									Total_Amount,
									Total_Invoice_Items,
									Page_Count,
									--OCR_PFG_Operator_PDF_Excel_Format_ID,
									OCR_Input_FileName_Raw,
									DB_OCR_Source_Code_FileName,
									OCR_Upload_ID,
									OCR_Source,
									BB_Claim_Source_XREF_ID,
									OCR_Template_Settings_ID,
									DB_OCR_Source_Code,
									OCR_FILE_CAPTURE_ID,
									Is_debug,
									Source,
									Vendor_Number,
									Program_Number,
									Customer_Reference,
									Payee_TYPE,
									Distributor_ID,
									Operator_ID,
									Closing_Method,
									Billback_Date,
									BB_Start_Date,
									BB_End_Date,
									Item_Number,
									Item_Volume_Qty,
									Item_Dollar_Amount,
									Associated_Distributor_ID,
									UOM,
									Trade_Indicator,
									Lump_Sum_Indicator,
									File_Name,
									Component_Name,
									Unknown,
									Upload_File_Name,
									Cust_Desc,
									Address,
									State,
									User_Input_Amount,
									Sum_Item_Dollar_Amount,
									Invalid,
									Invalid_Amount,
									Err_Msg,
									Err_Column,
									Err_Number,
									BA_Format_Validation,
									BA_Format_Validate_Date,
									BB_Upload_ID,
									Reviewed_Date,
									Reviewed_By,
									Reviewed_Notes,
									Updated_Date,
									Updated_By,
									Deleted,
									Created_Date,
									OCR_Code
								FROM ##Tmp_OCR_PFG_Operator_PDF_Excel_Format T
		</cfquery>
		<!--- <cfdump var = "#qInsOCR_PFG_Operator_PDF_Excel_Format#"><cfabort > --->
		<cfreturn />
	</cffunction>

	<!--- CONVERT TO TRACKMAX1 --->
	<cffunction name="insOCR_Trackmax1_From_PFG_Operator_PDF_Tmp" returntype="void">

		<cfquery name="qInsOCR_PFG_Operator_PDF_Excel_Format" datasource="#application.datasource#">
						INSERT INTO  OCR_Trackmax1_Excel_Format (
									Distributor_Location, -- Map it to Distributor_Location
									Customer_Reference_number,
									End_Date, -- Map it to End_Date
									Invoice_Date, -- Map it to Invoice_Date
									Item_Amount, -- Map it to Item_Amount
									Item_Description, -- Map it to Item_Description
									Item_DID, -- [Item_number] Map it to Item
									item_customer_name, -- [Item_Operator_ID] Map it to item_customer_name. 
									Item_Quantity, --[Item_Qty] Map it to Item_Quantity
									Item_Row_Number, -- [Item_Row] Map it to Item_Row_ID
									Page_Count, /*-- Map it to Page_Count*/
									Start_Date, /*-- Map it to Start_Date*/
									
									/* OCR SETTING FIELDS */
									OCR_Upload_ID,
									OCR_Input_FileName_Raw, -- Populate pdf filename
									DB_OCR_Source_Code_FileName, -- Populate pdf filename
									OCR_Source, -- 'PFG',
									BB_Claim_Source_XREF_ID,
									OCR_Template_Settings_ID,
									DB_OCR_Source_Code,
									OCR_Code ) 
								SELECT 
									Distributor_Location, -- Map it to Distributor_Location
									Invoice_Number,
									End_Date, -- Map it to End_Date
									Invoice_Date, -- Map it to Invoice_Date
									Item_Amount, -- Map it to Item_Amount
									Item_Description, -- Map it to Item_Description
									Item, -- [Item_number] Map it to Item
									Program_Info, -- [Item_Operator_ID] Map it to Program_Info. 
									Item_Quantity, --[Item_Qty] Map it to Item_Quantity
									Item_Row_ID, -- [Item_Row] Map it to Item_Row_ID
									Page_Count, /*-- Map it to Page_Count*/
									Start_Date, /*-- Map it to Start_Date*/
									
									/* OCR SETTING FIELDS */
									OCR_Upload_ID,
									OCR_Input_FileName_Raw, -- Populate pdf filename
									DB_OCR_Source_Code_FileName, -- Populate pdf filename
									OCR_Source, -- 'PFG',
									BB_Claim_Source_XREF_ID,
									OCR_Template_Settings_ID,
									DB_OCR_Source_Code,
									OCR_Code
								FROM ##Tmp_OCR_PFG_Operator_PDF_Excel_Format T
		</cfquery>
		<!--- <cfdump var = "#qInsOCR_PFG_Operator_PDF_Excel_Format#"><cfabort > --->
		<cfreturn />
	</cffunction>
	
	<cffunction name="insTmpOCR_PFG_Operator_PDF_Excel_Format" returntype="void">
		<cfargument name="arr" required="true" type="Array"/>
		<cfargument name="q" required="true" type="query"/>
		
		<cfset var a = arguments.Arr />
		<cfset var itemDesc = ''/>
		<cfset var customer_reference = ListFirst(arguments.q.File_Name,".") />
		<cfset this.createTmpOCR_PFG_Operator_PDF_Excel_Format() />
		<cfloop index = "i" from = "12" to = "#ARRAYLEN(a)#"><!--- item level data starts at 12 --->
		<cfquery name="qInsTmpOCR_PFG_Operator_PDF_Excel_Format" datasource="#application.datasource#">
						INSERT INTO ##Tmp_OCR_PFG_Operator_PDF_Excel_Format (
									Distributor_Location,
									--Invoice_Number,
									Invoice_Date,
									Start_Date,
									End_Date,
									MFG_Info,
									Program_Info,
									Item_Row_ID,
									Item,
									Item_Description,
									Item_UPC,
									Item_Vendor,
									Item_Contract_ID,
									Item_Invoice,
									--Item_Brand,
									Item_Quantity,
									Item_Avg_Each,
									Item_Allowance,
									Item_Amount,
									Item_T,
									Total_Quantity,
									Total_Avg_Each,
									Total_Allowance,
									Total_Amount,
									Total_Invoice_Items,
									Page_Count,
									OCR_PFG_Operator_PDF_Excel_Format_ID,
									OCR_Input_FileName_Raw,
									DB_OCR_Source_Code_FileName,
									OCR_Upload_ID,
									OCR_Source,
									BB_Claim_Source_XREF_ID,
									OCR_Template_Settings_ID,
									DB_OCR_Source_Code,
									OCR_FILE_CAPTURE_ID,
									Is_debug,
									Source,
									Vendor_Number,
									Program_Number,
									Customer_Reference,
									Payee_TYPE,
									Distributor_ID,
									Operator_ID,
									Closing_Method,
									Billback_Date,
									BB_Start_Date,
									BB_End_Date,
									Item_Number,
									Item_Volume_Qty,
									Item_Dollar_Amount,
									Associated_Distributor_ID,
									UOM,
									Trade_Indicator,
									Lump_Sum_Indicator,
									File_Name,
									Component_Name,
									Unknown,
									Upload_File_Name,
									Cust_Desc,
									Address,
									State,
									User_Input_Amount,
									Sum_Item_Dollar_Amount,
									Invalid,
									Invalid_Amount,
									Err_Msg,
									Err_Column,
									Err_Number,
									BA_Format_Validation,
									BA_Format_Validate_Date,
									BB_Upload_ID,
									Reviewed_Date,
									Reviewed_By,
									Reviewed_Notes,
									Updated_Date,
									Updated_By,
									Deleted,
									Created_Date,
									OCR_Code
						)
						VALUES
						(
									'#a[i][6]#',-- Distributor_Location
									---'#ListFirst(arguments.q.File_Name,'.')#',--Invoice_Number
									'#a[i][15]#',--Invoice_Date
									'#a[i][16]#',--Start_Date
									'#a[i][17]#',--End_Date
									'#a[i][8]#',--MFG_Info -> we just use this to update Program_Info
									'#a[i][7]#',--Program_Info
									'#i#',--Item_Row_ID
									'#a[i][5]#',  ---CAST('#a[i][5]#' as VARCHAR(50)),--Item -> mfg item + pack size + desc
									'#a[i][3]#',--Item_Description -> pack size + desc
									'#a[i][4]#',--Item_UPC
									'',--Item_Vendor
									'',--Item_Contract_ID
									'',--Item_Invoice
									--'',--Item_Brand
									'#a[i][10]#',--Item_Quantity
									'',--Item_Avg_Each
									'#a[i][13]#',--Item_Allowance
									'#a[i][14]#',--Item_Amount  extended
									'',--Item_T
									'#a[i][19]#',--Total_Quantity ""Vendor Total"
									'',--Total_Avg_Each
									'',--Total_Allowance XXXX Not needed  #a[i][14]#
									'#a[i][20]#',--Total_Amount  Vendor Totals
									'',--Total_Invoice_Items
									'#a[i][18]#',--Page_Count
									'',--OCR_PFG_Operator_PDF_Excel_Format_ID
									'#arguments.q.File_Name#',--OCR_Input_FileName_Raw
									'#arguments.q.File_Name#',--DB_OCR_Source_Code_FileName
									'#arguments.q.OCR_Upload_ID#',--OCR_Upload_ID
									'PFG',--OCR_Source
									'#arguments.q.BB_Claim_Source_XREF_ID#',--BB_Claim_Source_XREF_ID
									'#arguments.q.OCR_Template_Settings_ID#',--OCR_Template_Settings_ID
									'#arguments.q.DB_OCR_Source_Code#',--DB_OCR_Source_Code
									'',--OCR_FILE_CAPTURE_ID
									'',--Is_debug
									'',--Source
									'',--Vendor_Number
									'',--Program_Number
									'#customer_reference#',--Customer_Reference
									'',--Payee_TYPE
									'',--Distributor_ID
									'',--Operator_ID
									'',--Closing_Method
									'',--Billback_Date
									'',--BB_Start_Date
									'',--BB_End_Date
									'',--Item_Number
									'',--Item_Volume_Qty
									'',--Item_Dollar_Amount
									'',--Associated_Distributor_ID
									'',--UOM
									'',--Trade_Indicator
									'',--Lump_Sum_Indicator
									'',--File_Name
									'',--Component_Name
									'',--Unknown
									'#arguments.q.File_Name#',--Upload_File_Name
									'',--Cust_Desc
									'',--Address
									'',--State
									'',--User_Input_Amount
									'',--Sum_Item_Dollar_Amount
									'',--Invalid
									'',--Invalid_Amount
									'',--Err_Msg
									'',--Err_Column
									'',--Err_Number
									'',--BA_Format_Validation
									'',--BA_Format_Validate_Date
									'',--BB_Upload_ID
									'',--Reviewed_Date
									'',--Reviewed_By
									'',--Reviewed_Notes
									'',--Updated_Date
									'',--Updated_By
									'',--Deleted
									getdate(),--Created_Date
									'#arguments.q.OCR_Code#'--OCR_Code
						)
		</cfquery>
		</cfloop>
	</cffunction>
	
	<cffunction name="insTmpOCR_PFG_Operator_PDF_Excel_Format_SructData" returntype="void">
		<cfargument name="arr" required="true" type="Array"/>
		<cfargument name="q" required="true" type="query"/>
		<cfset var a = arguments.Arr />
		<cfset var itemDesc = ''/>
		<cfset var st = structNew()/>
		<cfset this.createTmpOCR_PFG_Operator_PDF_Excel_Format() />
		<cfloop index = "i" from = "1" to = "#ARRAYLEN(a)#"><!--- item level data starts at 12 --->
		<cfset st = a[i]/>
		<cfset sItem = st.item/>

		<cfset payeeType = '' />
		<cfif structkeyexists(st,'payeeType')>
			<cfset payeeType = st.payeeType />
		</cfif>
		<cfquery name="qInsTmpOCR_PFG_Operator_PDF_Excel_Format" datasource="#application.datasource#">
						INSERT INTO ##Tmp_OCR_PFG_Operator_PDF_Excel_Format (
									Distributor_Location,
									Invoice_Number,
									Invoice_Date,
									Start_Date,
									End_Date,
									MFG_Info,
									Program_Info,
									Item_Row_ID,
									Item,
									Item_Description,
									Item_UPC,
									Item_Vendor,
									Item_Contract_ID,
									Item_Invoice,
									--Item_Brand,
									Item_Quantity,
									Item_Avg_Each,
									Item_Allowance,
									Item_Amount,
									Item_T,
									Total_Quantity,
									Total_Avg_Each,
									Total_Allowance,
									Total_Amount,
									Total_Invoice_Items,
									Page_Count,
									OCR_PFG_Operator_PDF_Excel_Format_ID,
									OCR_Input_FileName_Raw,
									DB_OCR_Source_Code_FileName,
									OCR_Upload_ID,
									OCR_Source,
									BB_Claim_Source_XREF_ID,
									OCR_Template_Settings_ID,
									DB_OCR_Source_Code,
									OCR_FILE_CAPTURE_ID,
									Is_debug,
									Source,
									Vendor_Number,
									Program_Number,
									Customer_Reference,
									Payee_TYPE,
									Distributor_ID,
									Operator_ID,
									Closing_Method,
									Billback_Date,
									BB_Start_Date,
									BB_End_Date,
									Item_Number,
									Item_Volume_Qty,
									Item_Dollar_Amount,
									Associated_Distributor_ID,
									UOM,
									Trade_Indicator,
									Lump_Sum_Indicator,
									File_Name,
									Component_Name,
									Unknown,
									Upload_File_Name,
									Cust_Desc,
									Address,
									State,
									User_Input_Amount,
									Sum_Item_Dollar_Amount,
									Invalid,
									Invalid_Amount,
									Err_Msg,
									Err_Column,
									Err_Number,
									BA_Format_Validation,
									BA_Format_Validate_Date,
									BB_Upload_ID,
									Reviewed_Date,
									Reviewed_By,
									Reviewed_Notes,
									Updated_Date,
									Updated_By,
									Deleted,
									Created_Date,
									OCR_Code
						)
						VALUES
						(
									'#st['LOCATION']#',-- Distributor_Location
									'#st['INVOICENUMBER']#',--Invoice_Number
									'#st['INVDATE']#',--Invoice_Date
									'#st['INVSTARTDATE']#',--Start_Date
									'#st['INVENDDATE']#',--End_Date
									'#st['OPRNUMBER']#',--MFG_Info -> we just use this to update Program_Info
									'#st['programInfo']#',--Program_Info
									'#i#',--Item_Row_ID
									'#st.item#',  --Item -> mfg item + pack size + desc
									'#st['ITEMDESC']#',--Item_Description -> pack size + desc
									'',--Item_UPC
									'',--Item_Vendor
									'',--Item_Contract_ID
									'',--Item_Invoice
									--'',--Item_Brand
									'#st['QUANTITY']#',--Item_Quantity
									'',--Item_Avg_Each
									'#st['ITEMALLOWANCE']#',--Item_Allowance
									'#st['TOTALALLOWANCE']#',--Item_Amount  extended
									'',--Item_T
									'#st['TotalInvoiceQuantity']#',--Total_Quantity ""Vendor Total"
									'',--Total_Avg_Each
									'#st['TOTALALLOWANCE']#',--Total_Allowance XXXX Not needed
									'#st['TOTALINVOICEAMOUNT']#',--Total_Amount  Vendor Totals
									'',--Total_Invoice_Items
									'',--Page_Count
									'',--OCR_PFG_Operator_PDF_Excel_Format_ID
									'#arguments.q.File_Name#',--OCR_Input_FileName_Raw
									'#arguments.q.File_Name#',--DB_OCR_Source_Code_FileName
									'#arguments.q.OCR_Upload_ID#',--OCR_Upload_ID
									'#arguments.q.Source_Code#',--OCR_Source
									'#arguments.q.BB_Claim_Source_XREF_ID#',--BB_Claim_Source_XREF_ID
									'#arguments.q.OCR_Template_Settings_ID#',--OCR_Template_Settings_ID
									'#arguments.q.DB_OCR_Source_Code#',--DB_OCR_Source_Code
									'',--OCR_FILE_CAPTURE_ID
									'',--Is_debug
									'',--Source
									'',--Vendor_Number
									'',--Program_Number
									'#ListFirst(arguments.q.File_Name,'.')#',--Customer_Reference
									'#payeeType#',--Payee_TYPE
									'',--Distributor_ID
									'',--Operator_ID
									'',--Closing_Method
									'',--Billback_Date
									'',--BB_Start_Date
									'',--BB_End_Date
									'',--Item_Number
									'',--Item_Volume_Qty
									'',--Item_Dollar_Amount
									'',--Associated_Distributor_ID
									'',--UOM
									'',--Trade_Indicator
									'',--Lump_Sum_Indicator
									'',--File_Name
									'',--Component_Name
									'',--Unknown
									'#arguments.q.File_Name#',--Upload_File_Name
									'',--Cust_Desc
									'',--Address
									'',--State
									'',--User_Input_Amount
									'',--Sum_Item_Dollar_Amount
									'',--Invalid
									'',--Invalid_Amount
									'',--Err_Msg
									'',--Err_Column
									'',--Err_Number
									'',--BA_Format_Validation
									'',--BA_Format_Validate_Date
									'',--BB_Upload_ID
									'',--Reviewed_Date
									'',--Reviewed_By
									'',--Reviewed_Notes
									'',--Updated_Date
									'',--Updated_By
									'',--Deleted
									getdate(),--Created_Date
									'#arguments.q.OCR_Code#'  --OCR_Code
						)
		</cfquery>
		</cfloop>
		<cfif arguments.q.OCR_Code EQ 'PFG_OT2'>
			<cfquery name="qUpdDateTmpOCR_PFG_Operator_PDF_Excel_Format" datasource="#application.datasource#">
							Update ##Tmp_OCR_PFG_Operator_PDF_Excel_Format
							Set Start_Date = (SELECT Min(cast(Invoice_Date as date)) FROM ##Tmp_OCR_PFG_Operator_PDF_Excel_Format), --- Min Invoice_Date
								 End_Date = (SELECT Max(cast(Invoice_Date as date)) FROM ##Tmp_OCR_PFG_Operator_PDF_Excel_Format),  --- Max Invoice_Date
								 Invoice_Date = CAST(DATEADD(DAY, (DATEDIFF(DAY, 0, (SELECT Max(cast(Invoice_Date as date)) FROM ##Tmp_OCR_PFG_Operator_PDF_Excel_Format)) / 7) * 7 + 7, 0) AS DATE) --- Monday after End_Date
			</cfquery>
		</cfif>
		
		<cfif arguments.q.OCR_Code EQ 'Shamrock_OT1'>
			<cfquery name="qUpdDateTmpOCR_PFG_Operator_PDF_Excel_Format" datasource="#application.datasource#">
							Update ##Tmp_OCR_PFG_Operator_PDF_Excel_Format
							Set Start_Date = (SELECT Min(cast(Start_Date as date)) FROM ##Tmp_OCR_PFG_Operator_PDF_Excel_Format), --- Min Invoice_Date
								 End_Date = (SELECT Max(cast(End_Date as date)) FROM ##Tmp_OCR_PFG_Operator_PDF_Excel_Format)  --- Max Invoice_Date
			</cfquery>
		</cfif>
		<cfif arguments.q.OCR_Code EQ 'Foodbuy_OT1' OR arguments.q.OCR_Code EQ 'Foodbuy_OT2'>
			<cfquery name="qUpdDateTmpOCR_PFG_Operator_PDF_Excel_Format" datasource="#application.datasource#">
							Update ##Tmp_OCR_PFG_Operator_PDF_Excel_Format
							Set Invoice_Date = (SELECT cast(Invoice_Date as date) FROM OCR_User_Input WHERE OCR_Upload_Id = '#arguments.q.OCR_Upload_ID#')
			</cfquery>
		</cfif>
		<cfif arguments.q.OCR_Code EQ 'Sodexo_OT1'>
			<cfquery name="qUpdDateTmpOCR_PFG_Operator_PDF_Excel_Format" datasource="#application.datasource#">
							Update ##Tmp_OCR_PFG_Operator_PDF_Excel_Format
							Set Invoice_Date = (SELECT cast(Invoice_Date as date) FROM OCR_User_Input WHERE OCR_Upload_Id = '#arguments.q.OCR_Upload_ID#'),
								Invoice_Number = (SELECT Invoice_Number FROM OCR_User_Input WHERE OCR_Upload_Id = '#arguments.q.OCR_Upload_ID#')
			</cfquery>
		</cfif>

		<cfif arguments.q.OCR_Code EQ 'Sodexo_OT2'>
			<cfquery name="qUpdDateTmpOCR_PFG_Operator_PDF_Excel_Format" datasource="#application.datasource#">
							Update ##Tmp_OCR_PFG_Operator_PDF_Excel_Format
							Set Invoice_Date = (SELECT cast(Invoice_Date as date) FROM OCR_User_Input WHERE OCR_Upload_Id = '#arguments.q.OCR_Upload_ID#'),
							Start_Date = (SELECT cast(Start_Date as date) FROM OCR_User_Input WHERE OCR_Upload_Id = '#arguments.q.OCR_Upload_ID#'),
							End_Date = (SELECT cast(End_Date as date) FROM OCR_User_Input WHERE OCR_Upload_Id = '#arguments.q.OCR_Upload_ID#')
			</cfquery>
		</cfif>
	</cffunction>
	
	<cffunction name="createTmpOCR_PFG_Operator_PDF_Excel_Format" returntype="void">
		
		<cfquery name="qDrpTmpOCR_PFG_Operator_PDF_Excel_Format" datasource="#application.datasource#">
				IF object_id('tempdb..##Tmp_OCR_PFG_Operator_PDF_Excel_Format') IS NOT NULL	 
	                 DROP TABLE ##Tmp_OCR_PFG_Operator_PDF_Excel_Format
		</cfquery>

		<cfquery name="qTmpOCR_PFG_Operator_PDF_Excel_Format" datasource="#application.datasource#">
		

			CREATE TABLE ##Tmp_OCR_PFG_Operator_PDF_Excel_Format
			(
				
				[Distributor_Location] 		[varchar](max),
				[Invoice_Number] 		[varchar](max),
				[Invoice_Date] 		[varchar](max),
				[Start_Date] 		[varchar](max),
				[End_Date] 		[varchar](max),
				[MFG_Info] 		[varchar](max),
				[Program_Info] 		[varchar](max),
				[Item_Row_ID] 		[varchar](max),
				[Item] 		[varchar](max),
				[Item_Description] 		[varchar](max),
				[Item_UPC] 		[varchar](max),
				[Item_Vendor] 		[varchar](max),
				[Item_Contract_ID] 		[varchar](max),
				[Item_Invoice] 		[varchar](max),
				--[Item_Brand] 		[varchar](max),
				[Item_Quantity] 		[varchar](max),
				[Item_Avg_Each] 		[varchar](max),
				[Item_Allowance] 		[varchar](max),
				[Item_Amount] 		[varchar](max),
				[Item_T] 		[varchar](max),
				[Total_Quantity] 		[varchar](max),
				[Total_Avg_Each] 		[varchar](max),
				[Total_Allowance] 		[varchar](max),
				[Total_Amount] 		[varchar](max),
				[Total_Invoice_Items] 		[varchar](max),
				[Page_Count] 		[varchar](max),
				[OCR_PFG_Operator_PDF_Excel_Format_ID] 		[varchar](max),
				[OCR_Input_FileName_Raw] 		[varchar](max),
				[DB_OCR_Source_Code_FileName] 		[varchar](max),
				[OCR_Upload_ID] 		[varchar](max),
				[OCR_Source] 		[varchar](max),
				[BB_Claim_Source_XREF_ID] 		[varchar](max),
				[OCR_Template_Settings_ID] 		[varchar](max),
				[DB_OCR_Source_Code] 		[varchar](max),
				[OCR_FILE_CAPTURE_ID] 		[varchar](max),
				[Is_debug] 		[varchar](max),
				[Source] 		[varchar](max),
				[Vendor_Number] 		[varchar](max),
				[Program_Number] 		[varchar](max),
				[Customer_Reference] 		[varchar](max),
				[Payee_TYPE] 		[varchar](max),
				[Distributor_ID] 		[varchar](max),
				[Operator_ID] 		[varchar](max),
				[Closing_Method] 		[varchar](max),
				[Billback_Date] 		[varchar](max),
				[BB_Start_Date] 		[varchar](max),
				[BB_End_Date] 		[varchar](max),
				[Item_Number] 		[varchar](max),
				[Item_Volume_Qty] 		[varchar](max),
				[Item_Dollar_Amount] 		[varchar](max),
				[Associated_Distributor_ID] 		[varchar](max),
				[UOM] 		[varchar](max),
				[Trade_Indicator] 		[varchar](max),
				[Lump_Sum_Indicator] 		[varchar](max),
				[File_Name] 		[varchar](max),
				[Component_Name] 		[varchar](max),
				[Unknown] 		[varchar](max),
				[Upload_File_Name] 		[varchar](max),
				[Cust_Desc] 		[varchar](max),
				[Address] 		[varchar](max),
				[State] 		[varchar](max),
				[User_Input_Amount] 		[varchar](max),
				[Sum_Item_Dollar_Amount] 		[varchar](max),
				[Invalid] 		[varchar](max),
				[Invalid_Amount] 		[varchar](max),
				[Err_Msg] 		[varchar](max),
				[Err_Column] 		[varchar](max),
				[Err_Number] 		[varchar](max),
				[BA_Format_Validation] 		[varchar](max),
				[BA_Format_Validate_Date] 		[varchar](max),
				[BB_Upload_ID] 		[varchar](max),
				[Reviewed_Date] 		[varchar](max),
				[Reviewed_By] 		[varchar](max),
				[Reviewed_Notes] 		[varchar](max),
				[Updated_Date] 		[varchar](max),
				[Updated_By] 		[varchar](max),
				[Deleted] 		[varchar](max),
				[Created_Date] 		[varchar](max),
				[OCR_Code]		[varchar](max)		
			)
		</cfquery>
	</cffunction>
	
	<cffunction name="insOCR_Trackmax1_Excel_Format" returntype="void">

		<cfquery name="qInsOCR_Trackmax1_Excel_Format" datasource="#application.datasource#">
		INSERT INTO  OCR_Trackmax1_Excel_Format (
									Trackmax1_Address,
									Customer_Reference_Number,
									Distributor_Location,
									Document_ID,
									End_Date,
									Grand_Total_Amount,
									Grand_Total_Charges,
									Grand_Total_Description,
									Grand_Total_Quantity,
									Grand_Total_Weight,
									Header_Amount_Match,
									Invoice_Date,
									Item_Amount,
									Item_Brand,
									Item_Customer_ID,
									Item_Customer_Name,
									Item_Description,
									Item_DID,
									Item_Inv_Date,
									Item_Inv_number,
									Item_Pack_Size,
									Item_Product_ID,
									Item_Program_Amount,
									Item_Quantity,
									Item_Row_Number,
									Item_Total_Charges,
									Item_Total_Weight,
									Item_UPC,
									Location_Subtotal_Amount,
									Location_Subtotal_Charges,
									Location_Subtotal_Description,
									Location_Subtotal_Quantity,
									Location_Subtotal_Weight,
									Processed_At,
									Program_Information,
									Start_Date,
									Subtotal_Amount,
									Subtotal_Charges,
									Subtotal_Description,
									Subtotal_Quantity,
									Subtotal_Weight,
									Uploaded_At,
									OCR_Input_FileName_Raw,
									DB_OCR_Source_Code_FileName,
									OCR_Upload_ID,
									OCR_Source,
									BB_Claim_Source_XREF_ID,
									OCR_Template_Settings_ID,
									DB_OCR_Source_Code,
									OCR_FILE_CAPTURE_ID,
									Is_debug,
									Source,
									Vendor_Number,
									Program_Number,
									Customer_Reference,
									Payee_TYPE,
									Distributor_ID,
									Operator_ID,
									Closing_Method,
									Billback_Date,
									BB_Start_Date,
									BB_End_Date,
									Item_Number,
									Item_Volume_Qty,
									Item_Dollar_Amount,
									Associated_Distributor_ID,
									UOM,
									Trade_Indicator,
									Lump_Sum_Indicator,
									File_Name,
									Component_Name,
									Unknown,
									Upload_File_Name,
									Cust_Desc,
									Address,
									State,
									User_Input_Amount,
									Sum_Item_Dollar_Amount,
									--Invalid,
									--Invalid_Amount,
									--Err_Msg,
									--Err_Column,
									--Err_Number,
									--BA_Format_Validation,
									--BA_Format_Validate_Date,
									--BB_Upload_ID,
									--Reviewed_Date,
									--Reviewed_By,
									--Reviewed_Notes,
									--Updated_Date,
									--Updated_By,
									--Deleted,
									--Created_Date,
									--Page_Count,
									OCR_Code ) 
								SELECT 
									Trackmax1_Address,
									Customer_Reference_Number,
									Distributor_Location,
									Document_ID,
									End_Date,
									Grand_Total_Amount,
									Grand_Total_Charges,
									Grand_Total_Description,
									Grand_Total_Quantity,
									Grand_Total_Weight,
									Header_Amount_Match,
									Invoice_Date,
									Item_Amount,
									Item_Brand,
									Item_Customer_ID,
									Item_Customer_Name,
									Item_Description,
									Item_DID,
									Item_Inv_Date,
									Item_Inv_number,
									Item_Pack_Size,
									Item_Product_ID,
									Item_Program_Amount,
									Item_Quantity,
									Item_Row_Number,
									Item_Total_Charges,
									Item_Total_Weight,
									Item_UPC,
									Location_Subtotal_Amount,
									Location_Subtotal_Charges,
									Location_Subtotal_Description,
									Location_Subtotal_Quantity,
									Location_Subtotal_Weight,
									Processed_At,
									Program_Information,
									Start_Date,
									Subtotal_Amount,
									Subtotal_Charges,
									Subtotal_Description,
									Subtotal_Quantity,
									Subtotal_Weight,
									Uploaded_At,
									OCR_Input_FileName_Raw,
									DB_OCR_Source_Code_FileName,
									OCR_Upload_ID,
									OCR_Source,
									BB_Claim_Source_XREF_ID,
									OCR_Template_Settings_ID,
									DB_OCR_Source_Code,
									OCR_FILE_CAPTURE_ID,
									Is_debug,
									Source,
									Vendor_Number,
									Program_Number,
									Customer_Reference,
									Payee_TYPE,
									Distributor_ID,
									Operator_ID,
									Closing_Method,
									Billback_Date,
									BB_Start_Date,
									BB_End_Date,
									Item_Number,
									Item_Volume_Qty,
									Item_Dollar_Amount,
									Associated_Distributor_ID,
									UOM,
									Trade_Indicator,
									Lump_Sum_Indicator,
									File_Name,
									Component_Name,
									Unknown,
									Upload_File_Name,
									Cust_Desc,
									Address,
									State,
									User_Input_Amount,
									Sum_Item_Dollar_Amount,
									--Invalid,
									--Invalid_Amount,
									--Err_Msg,
									--Err_Column,
									--Err_Number,
									--BA_Format_Validation,
									--BA_Format_Validate_Date,
									--BB_Upload_ID,
									--Reviewed_Date,
									--Reviewed_By,
									--Reviewed_Notes,
									--Updated_Date,
									--Updated_By,
									--Deleted,
									--Created_Date,
									--Page_Count,
									OCR_Code
								FROM ##Tmp_OCR_Trackmax1_Excel_Format T
		</cfquery>
		<!--- <cfdump var = "#qInsOCR_PFG_Operator_PDF_Excel_Format#"><cfabort > --->
		<cfreturn />
	</cffunction>
	
	<cffunction name="insTmp_OCR_Trackmax1_Excel_Format" returntype="void">
		<cfargument name="arr" required="true" type="Array"/>
		<cfargument name="q" required="true" type="query"/>
		<cfset var a = arguments.Arr />
		<cfset var itemDesc = ''/>
		<cfset var st = structNew()/>
		<cfset this.createTmp_OCR_Trackmax1_Excel_Format() />
		<cfloop index = "i" from = "1" to = "#ARRAYLEN(a)#"><!--- item level data starts at 12 --->
		<cfset st = a[i]/>
		<cfquery name="qInsTmpOCR_Trackmax1_Excel_Format" datasource="#application.datasource#">
						INSERT INTO ##Tmp_OCR_Trackmax1_Excel_Format (
							--Trackmax1_Address,
							Customer_Reference_Number,
							Distributor_Location,
							Document_ID,
							End_Date,
							--Grand_Total_Amount,
							--Grand_Total_Charges,
							--Grand_Total_Description,
							--Grand_Total_Quantity,
							--Grand_Total_Weight,
							--Header_Amount_Match,
							Invoice_Date,
							Item_Amount,
							--Item_Brand,
							--Item_Customer_ID,
							Item_Customer_Name,
							Item_Description,
							Item_DID,
							--Item_Inv_Date,
							Item_Inv_number,
							Item_Pack_Size,
							Item_Product_ID,
							Item_Program_Amount,
							Item_Quantity,
							Item_Row_Number,
							Item_Total_Charges,
							Item_Total_Weight,
							Item_UPC,
							--Location_Subtotal_Amount,
							--Location_Subtotal_Charges,
							--Location_Subtotal_Description,
							--Location_Subtotal_Quantity,
							--Location_Subtotal_Weight,
							--Processed_At,
							Program_Information,
							Start_Date,
							--Subtotal_Amount,
							--Subtotal_Charges,
							--Subtotal_Description,
							--Subtotal_Quantity,
							--Subtotal_Weight,
							--Uploaded_At,
							OCR_Input_FileName_Raw,
							DB_OCR_Source_Code_FileName,
							OCR_Upload_ID,
							OCR_Source,
							BB_Claim_Source_XREF_ID,
							OCR_Template_Settings_ID,
							DB_OCR_Source_Code,
							--OCR_FILE_CAPTURE_ID,
							Is_debug,
							--Source,
							--Vendor_Number,
							--Program_Number,
							--Customer_Reference,
							--Payee_TYPE,
							--Distributor_ID,
							--Operator_ID,
							--Closing_Method,
							--Billback_Date,
							--BB_Start_Date,
							--BB_End_Date,
							--Item_Number,
							--Item_Volume_Qty,
							--Item_Dollar_Amount,
							--Associated_Distributor_ID,
							--UOM,
							--Trade_Indicator,
							--Lump_Sum_Indicator,
							--File_Name,
							--Component_Name,
							--Unknown,
							--Upload_File_Name,
							--Cust_Desc,
							--Address,
							--State,
							--User_Input_Amount,
							--Sum_Item_Dollar_Amount,
							--Invalid,
							--Invalid_Amount,
							--Err_Msg,
							--Err_Column,
							--Err_Number,
							--BA_Format_Validation,
							--BA_Format_Validate_Date,
							--BB_Upload_ID,
							--Reviewed_Date,
							--Reviewed_By,
							--Reviewed_Notes,
							--Updated_Date,
							--Updated_By,
							--Deleted,
							--Created_Date,
							--Page_Count,
							OCR_Code		
						)
						VALUES
						(
							--'',  --Trackmax1_Address
							'#st['invoiceNumber']#',  --Customer_Reference_Number
							'#st['location']#',  --Distributor_Location
							'',  --Document_ID
							'#st['invEndDate']#',  --End_Date
							--'',  --Grand_Total_Amount
							--'',  --Grand_Total_Charges
							--'',  --Grand_Total_Description
							--'',  --Grand_Total_Quantity
							--'',  --Grand_Total_Weight
							--'',  --Header_Amount_Match
							'#st['invDate']#',  --Invoice_Date
							'#st['totalAllowance']#',  --Item_Amount
							--'',  --Item_Brand
							--'',  --Item_Customer_ID
							'#st['programInfo']#',  --Item_Customer_Name
							'#st['ITEMDESC']#',  --Item_Description
							'#st['ITEM']#',  --Item_DID
							--'',  --Item_Inv_Date
							'#st['invoiceNumber']#',--'',  --Item_Inv_number
							'#st['packSize']#',  --Item_Pack_Size
							'#st['ITEM']#',  --Item_Product_ID
							'#st['totalAllowance']#',  --Item_Program_Amount
							'#st['quantity']#',  --Item_Quantity
							'#i#',  --Item_Row_Number
							'#st['itemTotalCharges']#',  --Item_Total_Charges
							'#st['itemTotalWeight']#',  --Item_Total_Weight
							'#st['ITEM']#',  --Item_UPC
							--'',  --Location_Subtotal_Amount
							--'',  --Location_Subtotal_Charges
							--'',  --Location_Subtotal_Description
							--'',  --Location_Subtotal_Quantity
							--'',  --Location_Subtotal_Weight
							--'',  --Processed_At
							'',  --Program_Information
							'#st['invStartDate']#',  --Start_Date
							--'',  --Subtotal_Amount
							--'',  --Subtotal_Charges
							--'',  --Subtotal_Description
							--'',  --Subtotal_Quantity
							--'',  --Subtotal_Weight
							--'',  --Uploaded_At
							'#arguments.q.File_Name#',--OCR_Input_FileName_Raw
							'#arguments.q.File_Name#',--DB_OCR_Source_Code_FileName
							'#arguments.q.OCR_Upload_ID#',--OCR_Upload_ID
							'PFG',--OCR_Source
							'#arguments.q.BB_Claim_Source_XREF_ID#',--BB_Claim_Source_XREF_ID
							'#arguments.q.OCR_Template_Settings_ID#',--OCR_Template_Settings_ID
							'#arguments.q.DB_OCR_Source_Code#',--DB_OCR_Source_Code
							--'',  --OCR_FILE_CAPTURE_ID
							'0',  --Is_debug
							--'',  --Source
							--'',  --Vendor_Number
							--'',  --Program_Number
							--'',  --Customer_Reference
							--'',  --Payee_TYPE
							--'',  --Distributor_ID
							--'',  --Operator_ID
							--'',  --Closing_Method
							--'',  --Billback_Date
							--'',  --BB_Start_Date
							--'',  --BB_End_Date
							--'',  --Item_Number
							--'',  --Item_Volume_Qty
							--'',  --Item_Dollar_Amount
							--'',  --Associated_Distributor_ID
							--'',  --UOM
							--'',  --Trade_Indicator
							--'',  --Lump_Sum_Indicator
							--'',  --File_Name
							--'',  --Component_Name
							--'',  --Unknown
							--'',  --Upload_File_Name
							--'',  --Cust_Desc
							--'',  --Address
							--'',  --State
							--'',  --User_Input_Amount
							--'',  --Sum_Item_Dollar_Amount
							--'',  --Invalid
							--'',  --Invalid_Amount
							--'',  --Err_Msg
							--'',  --Err_Column
							--'',  --Err_Number
							--'',  --BA_Format_Validation
							--'',  --BA_Format_Validate_Date
							--'',  --BB_Upload_ID
							--'',  --Reviewed_Date
							--'',  --Reviewed_By
							--'',  --Reviewed_Notes
							--'',  --Updated_Date
							--'',  --Updated_By
							--'',  --Deleted
							--'',  --Created_Date
							--'',  --Page_Count
							'#arguments.q.OCR_Code#'  --OCR_Code
									
						)
		</cfquery>
		</cfloop>
	</cffunction>
	
	<cffunction name="createTmp_OCR_Trackmax1_Excel_Format" returntype="void">
		
		<cfquery name="qDrpTmpOCR_Trackmax1_Excel_Format" datasource="#application.datasource#">
				IF object_id('tempdb..##Tmp_OCR_Trackmax1_Excel_Format') IS NOT NULL	 
	                 DROP TABLE ##Tmp_OCR_Trackmax1_Excel_Format
		</cfquery>

		<cfquery name="qTmp_OCR_Trackmax1_Excel_Format" datasource="#application.datasource#">
		

			CREATE TABLE ##Tmp_OCR_Trackmax1_Excel_Format
			(
				
				[Trackmax1_Address] 		[varchar](max),
				[Customer_Reference_Number] 		[varchar](max),
				[Distributor_Location] 		[varchar](max),
				[Document_ID] 		[varchar](max),
				[End_Date] 		[varchar](max),
				[Grand_Total_Amount] 		[varchar](max),
				[Grand_Total_Charges] 		[varchar](max),
				[Grand_Total_Description] 		[varchar](max),
				[Grand_Total_Quantity] 		[varchar](max),
				[Grand_Total_Weight] 		[varchar](max),
				[Header_Amount_Match] 		[varchar](max),
				[Invoice_Date] 		[varchar](max),
				[Item_Amount] 		[varchar](max),
				[Item_Brand] 		[varchar](max),
				[Item_Customer_ID] 		[varchar](max),
				[Item_Customer_Name] 		[varchar](max),
				[Item_Description] 		[varchar](max),
				[Item_DID] 		[varchar](max),
				[Item_Inv_Date] 		[varchar](max),
				[Item_Inv_number] 		[varchar](max),
				[Item_Pack_Size] 		[varchar](max),
				[Item_Product_ID] 		[varchar](max),
				[Item_Program_Amount] 		[varchar](max),
				[Item_Quantity] 		[varchar](max),
				[Item_Row_Number] 		[varchar](max),
				[Item_Total_Charges] 		[varchar](max),
				[Item_Total_Weight] 		[varchar](max),
				[Item_UPC] 		[varchar](max),
				[Location_Subtotal_Amount] 		[varchar](max),
				[Location_Subtotal_Charges] 		[varchar](max),
				[Location_Subtotal_Description] 		[varchar](max),
				[Location_Subtotal_Quantity] 		[varchar](max),
				[Location_Subtotal_Weight] 		[varchar](max),
				[Processed_At] 		[varchar](max),
				[Program_Information] 		[varchar](max),
				[Start_Date] 		[varchar](max),
				[Subtotal_Amount] 		[varchar](max),
				[Subtotal_Charges] 		[varchar](max),
				[Subtotal_Description] 		[varchar](max),
				[Subtotal_Quantity] 		[varchar](max),
				[Subtotal_Weight] 		[varchar](max),
				[Uploaded_At] 		[varchar](max),
				[OCR_Trackmax1_Excel_Format_ID]	[int] IDENTITY(1,1) NOT NULL,
				[OCR_Input_FileName_Raw] 		[varchar](max),
				[DB_OCR_Source_Code_FileName] 		[varchar](max),
				[OCR_Upload_ID] 		[varchar](max),
				[OCR_Source] 		[varchar](max),
				[BB_Claim_Source_XREF_ID] 		[varchar](max),
				[OCR_Template_Settings_ID] 		[varchar](max),
				[DB_OCR_Source_Code] 		[varchar](max),
				[OCR_FILE_CAPTURE_ID] 		[varchar](max),
				[Is_debug] 		[varchar](max),
				[Source] 		[varchar](max),
				[Vendor_Number] 		[varchar](max),
				[Program_Number] 		[varchar](max),
				[Customer_Reference] 		[varchar](max),
				[Payee_TYPE] 		[varchar](max),
				[Distributor_ID] 		[varchar](max),
				[Operator_ID] 		[varchar](max),
				[Closing_Method] 		[varchar](max),
				[Billback_Date] 		[varchar](max),
				[BB_Start_Date] 		[varchar](max),
				[BB_End_Date] 		[varchar](max),
				[Item_Number] 		[varchar](max),
				[Item_Volume_Qty] 		[varchar](max),
				[Item_Dollar_Amount] 		[varchar](max),
				[Associated_Distributor_ID] 		[varchar](max),
				[UOM] 		[varchar](max),
				[Trade_Indicator] 		[varchar](max),
				[Lump_Sum_Indicator] 		[varchar](max),
				[File_Name] 		[varchar](max),
				[Component_Name] 		[varchar](max),
				[Unknown] 		[varchar](max),
				[Upload_File_Name] 		[varchar](max),
				[Cust_Desc] 		[varchar](max),
				[Address] 		[varchar](max),
				[State] 		[varchar](max),
				[User_Input_Amount] 		[varchar](max),
				[Sum_Item_Dollar_Amount] 		[varchar](max),
				[Invalid] 		[varchar](max),
				[Invalid_Amount] 		[varchar](max),
				[Err_Msg] 		[varchar](max),
				[Err_Column] 		[varchar](max),
				[Err_Number] 		[varchar](max),
				[BA_Format_Validation] 		[varchar](max),
				[BA_Format_Validate_Date] 		[varchar](max),
				[BB_Upload_ID] 		[varchar](max),
				[Reviewed_Date] 		[varchar](max),
				[Reviewed_By] 		[varchar](max),
				[Reviewed_Notes] 		[varchar](max),
				[Updated_Date] 		[varchar](max),
				[Updated_By] 		[varchar](max),
				[Deleted] 		[varchar](max),
				[Created_Date] 		[varchar](max),
				[Page_Count] 		[varchar](max),
				[OCR_Code]		[varchar](max)
					
			)
		</cfquery>
	</cffunction>

	<cffunction name="ins_OCR_Aramark_Excel_Format" returntype="void">

		<cfquery name="qInsOCR_Aramark_Excel_Format" datasource="#application.datasource#">
		INSERT INTO  OCR_Trackmax1_Excel_Format (
								Distributor_Location,		------ DIST_DC_NAME,
								item_customer_name,
								Item_Brand,
								Item_DID ,					------- DIST_PROD_ID,
								Item_Description, 			------- PROD_DESC,
								UOM,
								Item_Quantity, 				-------- PKG,
								Item_Amount, 				------- ALLOWANCE,
								Start_Date, 				------BB_Start_Date,
								End_Date,    				------BB_End_Date,
								Program_Information,
								Payee_Type_IND,

								Source,

								OCR_Input_FileName_Raw,
								DB_OCR_Source_Code_FileName,
								OCR_Upload_ID,
								OCR_Source,
								BB_Claim_Source_XREF_ID,
								OCR_Template_Settings_ID,
								DB_OCR_Source_Code,
								Is_debug,
								OCR_Code
								) 
							SELECT 
								DIST_DC_NAME,
								'Aramark_CA',
								BRAND_NAME,
								DIST_PROD_ID,
								PROD_DESC,
								UOM1,
								PKG,
								ALLOWANCE,
								BB_Start_Date,
								BB_End_Date,
								Alias_Program_Desc,
								'O',

								Source,

								OCR_Input_FileName_Raw,
								DB_OCR_Source_Code_FileName,
								OCR_Upload_ID,
								OCR_Source,
								BB_Claim_Source_XREF_ID,
								OCR_Template_Settings_ID,
								DB_OCR_Source_Code,
								Is_debug,
								OCR_Code
							FROM ##Tmp_OCR_Aramark_Excel_Format T
		</cfquery>
		<!--- <cfdump var = "#qInsOCR_PFG_Operator_PDF_Excel_Format#"><cfabort > --->
		<cfreturn />
	</cffunction>

	<cffunction name="insTmp_OCR_Aramark_Excel_Format" returntype="void">
		<cfargument name="arr" required="true" type="Array"/>
		<cfargument name="q" required="true" type="query"/>
		<cfset var a = arguments.Arr />
		<cfset var itemDesc = ''/>
		<cfset var st = structNew()/>
		<cfset this.createTmp_OCR_Aramark_Excel_Format() />
		<cfloop index = "i" from = "1" to = "#ARRAYLEN(a)#"><!--- item level data starts at 12 --->
		<cfset st = a[i]/>
		<cfquery name="qInsTmp_OCR_Aramark_Excel_Format" datasource="#application.datasource#">
						INSERT INTO ##Tmp_OCR_Aramark_Excel_Format (
								DIST_DC_NAME,
								BRAND_NAME,
								DIST_PROD_ID,
							--  MFG_PROD_ID,
								PROD_DESC,
								PACKAGING,
								UOM1,
								PKG,
							    PKG_RATE_BASIS,
							--	WT,
							--	WT_RATE_BASIS,
								VOL,
							--	VOL_RATE_BASIS,
								SPEND,
							--	DIST_MARGIN,
							--	ADJ_SPEND,
							--	RATE,
							--	RATE_BASIS,
								ALLOWANCE,
								-- Calc_Invoice_Number,
								-- Calc_Billback_Date,
								 Calc_BB_Start_Date,
								 Calc_BB_End_Date,
								 Alias_Distributor_ID,
								 Alias_Distributor_Desc,
								 Alias_Item_ID,
								 Alias_Item_Desc,
								 Alias_Program_ID,
								 Alias_Program_Desc,
								-- OCR_Aramark_Excel_Format_ID,
								
								-- OCR_FILE_CAPTURE_ID,

								Source,
								-- Vendor_Number,
								 Program_Number,
								-- Customer_Reference,
								-- Payee_TYPE,
								-- Distributor_ID,
								-- Operator_ID,
								-- Closing_Method,
								-- Billback_Date,
								 BB_Start_Date,
								BB_End_Date,
								-- Item_Number,
								-- Item_Volume_Qty,
								-- Item_Dollar_Amount,
								-- Associated_Distributor_ID,
								-- UOM,
								-- Trade_Indicator,
								-- Lump_Sum_Indicator,
								-- File_Name,
								-- Component_Name,
								-- Unknown,
								-- Upload_File_Name,
								-- Cust_Desc,
								-- Address,
								-- State,
								-- User_Input_Amount,
								-- Sum_Item_Dollar_Amount,
								-- Invalid,
								-- Invalid_Amount,
								-- Err_Msg,
								-- Err_Column,
								-- Err_Number,
								-- BA_Format_Validation,
								-- BA_Format_Validate_Date,
								-- BB_Upload_ID,
								-- Reviewed_Date,
								-- Reviewed_By,
								-- Reviewed_Notes,
								-- Updated_Date,
								-- Updated_By,
								-- Deleted,
								-- Created_Date,

								OCR_Input_FileName_Raw,
								DB_OCR_Source_Code_FileName,
								OCR_Upload_ID,
								OCR_Source,
								BB_Claim_Source_XREF_ID,
								OCR_Template_Settings_ID,
								DB_OCR_Source_Code,
								Is_debug,
								OCR_Code		
						)
						VALUES
						(

								'#st['location']#', --DIST_DC_NAME,
								'#st['brand']#', --BRAND_NAME,
								'#st['item']#', -- DIST_PROD_ID,
								--MFG_PROD_ID,
								'#st['itemDesc']#', --PROD_DESC,
								'#st['packSize']#', --PACKAGING,
								'#st['Unit']#', --UOM1,
								'#st['quantity']#', -- PKG,
								'#st['Unit']#', --  PKG_RATE_BASIS,
								--	WT,
								--	WT_RATE_BASIS,
								'#st['quantity']#', -- VOL,
								--	VOL_RATE_BASIS,
								'#st['itemTotalCharges']#', --SPEND,
								--	DIST_MARGIN,
								--	ADJ_SPEND,
								--	RATE,
								--	RATE_BASIS,
								'#st['ITEMALLOWANCE']#', --ALLOWANCE,
								-- Calc_Invoice_Number,
								-- Calc_Billback_Date,
								'#st['start']#',-- Calc_BB_Start_Date,
								'#st['end']#',-- Calc_BB_End_Date,
								'#st['location']#', -- Alias_Distributor_ID,
								'#st['location']#', -- Alias_Distributor_Desc,
								'#st['item']#', -- Alias_Item_ID,
								'#st['itemDesc']#', -- Alias_Item_Desc,
								'#arguments.q.Source_Code#',---'st['PlanName']', -- Alias_Program_ID,
								'#st['PlanName']#', -- Alias_Program_Desc,
								-- OCR_Aramark_Excel_Format_ID,
								
								-- OCR_FILE_CAPTURE_ID,

								'#arguments.q.Source_Code#',-- Source,
								-- Vendor_Number,
								'#arguments.q.Source_Code#',-- Program_Number,
								-- Customer_Reference,
								-- Payee_TYPE,
								-- Distributor_ID,
								 --Operator_ID
								-- Closing_Method,
								-- Billback_Date,
								'#st['start']#',-- BB_Start_Date,
								'#st['end']#',-- BB_End_Date,
								-- Item_Number,
								-- Item_Volume_Qty,
								-- Item_Dollar_Amount,
								-- Associated_Distributor_ID,
								-- UOM,
								-- Trade_Indicator,
								-- Lump_Sum_Indicator,
								-- File_Name,
								-- Component_Name,
								-- Unknown,
								-- Upload_File_Name,
								-- Cust_Desc,
								-- Address,
								-- State,
								-- User_Input_Amount,
								-- Sum_Item_Dollar_Amount,
								-- Invalid,
								-- Invalid_Amount,
								-- Err_Msg,
								-- Err_Column,
								-- Err_Number,
								-- BA_Format_Validation,
								-- BA_Format_Validate_Date,
								-- BB_Upload_ID,
								-- Reviewed_Date,
								-- Reviewed_By,
								-- Reviewed_Notes,
								-- Updated_Date,
								-- Updated_By,
								-- Deleted,
								-- Created_Date,
							'#arguments.q.File_Name#',--OCR_Input_FileName_Raw
							'#arguments.q.File_Name#',--DB_OCR_Source_Code_FileName
							'#arguments.q.OCR_Upload_ID#',--OCR_Upload_ID
							'#arguments.q.Source_Code#',--OCR_Source
							'#arguments.q.BB_Claim_Source_XREF_ID#',--BB_Claim_Source_XREF_ID
							'#arguments.q.OCR_Template_Settings_ID#',--OCR_Template_Settings_ID
							'#arguments.q.DB_OCR_Source_Code#',--DB_OCR_Source_Code
							'0',  --Is_debug
							'#arguments.q.OCR_Code#'  --OCR_Code
									
						)
		</cfquery>
		</cfloop>
	</cffunction>
	
	<cffunction name="createTmp_OCR_Aramark_Excel_Format" returntype="void">
		
		<cfquery name="qDrpTmpOCR_Aramark_Excel_Format" datasource="#application.datasource#">
				IF object_id('tempdb..##Tmp_OCR_Aramark_Excel_Format') IS NOT NULL	 
	                 DROP TABLE ##Tmp_OCR_Aramark_Excel_Format
		</cfquery>

		<cfquery name="qTmp_OCR_Aramark_Excel_Format" datasource="#application.datasource#">
		

			CREATE TABLE ##Tmp_OCR_Aramark_Excel_Format
			(
				[DIST_DC_NAME]		[varchar](max),
				[BRAND_NAME]		[varchar](max),
				[DIST_PROD_ID]		[varchar](max),
				[MFG_PROD_ID]		[varchar](max),
				[PROD_DESC]		[varchar](max),
				[PACKAGING]		[varchar](max),
				[UOM1]		[varchar](max),
				[PKG]		[varchar](max),
				[PKG_RATE_BASIS]		[varchar](max),
				[WT]		[varchar](max),
				[WT_RATE_BASIS]		[varchar](max),
				[VOL]		[varchar](max),
				[VOL_RATE_BASIS]		[varchar](max),
				[SPEND]		[varchar](max),
				[DIST_MARGIN]		[varchar](max),
				[ADJ_SPEND]		[varchar](max),
				[RATE]		[varchar](max),
				[RATE_BASIS]		[varchar](max),
				[ALLOWANCE]		[varchar](max),
				[Calc_Invoice_Number]		[varchar](max),
				[Calc_Billback_Date]		[varchar](max),
				[Calc_BB_Start_Date]		[varchar](max),
				[Calc_BB_End_Date]		[varchar](max),
				[Alias_Distributor_ID]		[varchar](max),
				[Alias_Distributor_Desc]		[varchar](max),
				[Alias_Item_ID]		[varchar](max),
				[Alias_Item_Desc]		[varchar](max),
				[Alias_Program_ID]		[varchar](max),
				[Alias_Program_Desc]		[varchar](max),
				[OCR_Aramark_Excel_Format_ID]		[varchar](max),
				[OCR_Input_FileName_Raw]		[varchar](max),
				[DB_OCR_Source_Code_FileName]		[varchar](max),
				[OCR_Upload_ID]		[varchar](max),
				[OCR_Source]		[varchar](max),
				[BB_Claim_Source_XREF_ID]		[varchar](max),
				[OCR_Template_Settings_ID]		[varchar](max),
				[DB_OCR_Source_Code]		[varchar](max),
				[OCR_FILE_CAPTURE_ID]		[varchar](max),
				[Is_debug]		[varchar](max),
				[OCR_Code]		[varchar](max),
				[Source]		[varchar](max),
				[Vendor_Number]		[varchar](max),
				[Program_Number]		[varchar](max),
				[Customer_Reference]		[varchar](max),
				[Payee_TYPE]		[varchar](max),
				[Distributor_ID]		[varchar](max),
				[Operator_ID]		[varchar](max),
				[Closing_Method]		[varchar](max),
				[Billback_Date]		[varchar](max),
				[BB_Start_Date]		[varchar](max),
				[BB_End_Date]		[varchar](max),
				[Item_Number]		[varchar](max),
				[Item_Volume_Qty]		[varchar](max),
				[Item_Dollar_Amount]		[varchar](max),
				[Associated_Distributor_ID]		[varchar](max),
				[UOM]		[varchar](max),
				[Trade_Indicator]		[varchar](max),
				[Lump_Sum_Indicator]		[varchar](max),
				[File_Name]		[varchar](max),
				[Component_Name]		[varchar](max),
				[Unknown]		[varchar](max),
				[Upload_File_Name]		[varchar](max),
				[Cust_Desc]		[varchar](max),
				[Address]		[varchar](max),
				[State]		[varchar](max),
				[User_Input_Amount]		[varchar](max),
				[Sum_Item_Dollar_Amount]		[varchar](max),
				[Invalid]		[varchar](max),
				[Invalid_Amount]		[varchar](max),
				[Err_Msg]		[varchar](max),
				[Err_Column]		[varchar](max),
				[Err_Number]		[varchar](max),
				[BA_Format_Validation]		[varchar](max),
				[BA_Format_Validate_Date]		[varchar](max),
				[BB_Upload_ID]		[varchar](max),
				[Reviewed_Date]		[varchar](max),
				[Reviewed_By]		[varchar](max),
				[Reviewed_Notes]		[varchar](max),
				[Updated_Date]		[varchar](max),
				[Updated_By]		[varchar](max),
				[Deleted]		[varchar](max),
				[Created_Date]		[varchar](max)
			
			)
		</cfquery>
	</cffunction>
</cfcomponent>