<!--- 
Creator/Developer: Ana Shankar
Label: D14324
Notes: 
	1)This file form a pipe delimited Product and product detail values and 
	pass that as a set of param to the procedure Billback_Products_Insert.
	2)Commas and Pipes are very sensitive in this page and 
	the procedure so please be careful with them while working on this page
	3)As of now this page is good for BBs created with not more than 500 products 
	--Paul cofirmed that there will not be a BB with more than 500 products before I started working on this modification
	4)But if we need to process more than 500 please 
		- search for Param451_500 and copy paste the line and modify the variable name accordingly in this page
		- Do the same thing in the procedure Billback_Products_Insert	
 --->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<CFOUTPUT>
<BR><BR>
<CFQUERY NAME="GetStatus" DATASOURCE="#Application.Datasource#">
	SELECT Billback_Status_ID FROM Billback WHERE Billback_ID = '#FORM.Billback_ID#'
</CFQUERY>
<CFIF GetStatus.Billback_Status_ID GTE 3> 
	<!--- 17302 - Redirect to Summary --->
	<CFSET Billback_Status_ID = GetStatus.Billback_Status_ID>
	<CFSET BB_ID_TO_Redirect = FORM.Billback_ID>
	<CFINCLUDE TEMPLATE = "BB_Summary_Redirect.cfm">
	<CFABORT>
</CFIF>

<!--- D22543 - Prevent updates while deviation Run all is in progress - Grid could cause this issue as it opens in popup --->

<CFPARAM NAME="In_Progress_Check_BBID" default="">
<CFPARAM NAME="PageName_InProgress" default="">
<CFPARAM NAME="Progress_Type" default="0">

<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js">

<CFSET In_Progress_Check_BBID = FORM.Billback_ID>
<CFSET PageName_InProgress = "Programs">
<CFSET Progress_Type = 1>	
<CFINCLUDE TEMPLATE = "BB_In_Progress_Check.cfm">

<CFPARAM NAME="TotalRebate" DEFAULT="0" />
<CFPARAM NAME="RebateUpdateAllowed" DEFAULT="0" />

<!--- Ana: D15311 -- Set the Deviation Ran Details --->
<cfquery name="ClearDev" datasource="#application.datasource#">
	UPDATE 	Billback 
	SET 	Deviation_Ran_Date = NULL,
			Auto_Deviation_On = NULL,
			Deviation_Ran_By = NULL
	WHERE	Billback_ID = '#Billback_ID#'
</cfquery>
<!--- If the profile and program template allow rebate update and the program has rebate as a discount type --->
 <cfif RebateUpdateAllowed eq 1>
		<cfif TotalRebate neq 0 AND Form.Billback_ID neq 0>
				<cfquery name="updBBAmount" datasource="#application.datasource#">
					UPDATE Billback
					SET BB_Amount = '#TotalRebate#'
					WHERE Billback_ID = '#FORM.Billback_ID#'
				</cfquery>
		</cfif>
 </cfif>

<CFQUERY NAME="getPayeeType" DATASOURCE="#Application.Datasource#">
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SELECT Billback_Payee_Type_ID, Uploaded_Billback, Billback.BB_Deviations_Override_Price as BB_Level_Deviations_Override_Price_Flag
	FROM Billback 
	WHERE Billback_ID = '#FORM.Billback_ID#' AND Deleted = 0
</CFQUERY>

	<CFQUERY name="getDistributorID" DATASOURCE="#Application.Datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			
		SELECT 	DISTINCT Distributor_ID 
		FROM 	BillBack_Distributor_List 
		WHERE 	Billback_ID = '#FORM.Billback_ID#' AND 
				Deleted = 0
	</CFQUERY>

	<CFSET Distributor_List = VALUELIST(getDistributorID.Distributor_ID)>

<!--- distributor payee --->
<CFIF getPayeeType.Billback_Payee_Type_ID EQ 1>
	<CFQUERY name="getPayeeID" DATASOURCE="#Application.Datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			
		SELECT 	Distributor_ID 
		FROM 	Billback_Distributor 
		WHERE 	Billback_ID = '#FORM.Billback_ID#' AND 
				Deleted = 0
	</CFQUERY>	
	<Cfif NOT listcontains(Distributor_List, getPayeeID.Distributor_ID)>
		<CFSET Distributor_List = listappend(Distributor_List, getPayeeID.Distributor_ID)>
	</CFIF>

		
</CFIF>

<cfif Distributor_List eq "">
	<cfset Distributor_List = "00000000-0000-0000-0000-000000000000" />
</cfif>

<CFQUERY name="qCreateTempTable" DATASOURCE="#Application.Datasource#">
	IF OBJECT_ID('tempdb..##Temp_Billback_Product_Info') IS NOT NULL
	DROP TABLE ##Temp_Billback_Product_Info
</CFQUERY>

<CFQUERY name="qCreateTempTable" DATASOURCE="#Application.Datasource#">
	CREATE TABLE ##Temp_Billback_Product_Info
	(
		Billback_ID UniqueIdentifier,
		Program_ID Int,
		Product_ID UniqueIdentifier,
		Distributor_ID UniqueIdentifier,
		UOM Int,
		Volume Varchar(50),
		Fixed Varchar(50),
		Rebate Varchar(50),
		Growth Varchar(50),
		Formula Varchar(50),
		ClaimAdj Varchar(50),
		Bid Varchar(50),
		Billback_Program_ID UniqueIdentifier,
		Billback_Product_ID UniqueIdentifier,
		BS_Var_2 Varchar(50),
		User_Picked_UOM  Int,
		User_Entered_Quantity Varchar(100)
	)
</CFQUERY>

<!--- Program_Product_Count and  Program_Product_paramCount should be declared outside both the loops--->
<CFSET Program_Product_Count = 0>
<cfset UOM_List = "1,2,3,x" /> <!--- 1=CS, 2=LB, 3=EA/%(Not used, but declare just in case) x is a lace holder for '' empty string.    new items do not have UOM concatenated in the form field names--->

<cfquery name="LookForExistingProgram" datasource="#Application.Datasource#">
	SELECT	Program_ID,Discount_List,Billback_Program_ID,Contract_Number
	FROM	Billback_Program
	INNER JOIN Contract_Main ON Contract_Main.Contract_main_ID = Billback_Program.Program_ID
	WHERE 	Billback_ID = '#FORM.Billback_ID#' AND Program_ID NOT IN (#FORM.Program_List#)
	AND		Billback_Program.Deleted = 0
	ORDER BY Contract_Number
</cfquery>
<cfif LookForExistingProgram.RecordCount GTE 1>
	<cfset ProgramLeftOut = ValueList(LookForExistingProgram.Program_ID) />
	<cfset templist = ListAppend(FORM.Program_List, ProgramLeftOut, ",")>
	<cfset FORM.Program_List = templist />
</cfif>
<CFSET Program_Count = 0>
<CFLOOP LIST = "#FORM.Program_List#" INDEX = "ThisProgram">
	<!--- Need to put a loop her over programs to handle multiple programs --->
	<CFSET Program_Count = Program_Count + 1>
	<CFSET Product_Count = 0>
	<cfif isdefined("Product_List_#ThisProgram#")>
	<!--- Product loop --->
	<CFSET ThisProgram_Distributor_List = Distributor_List><!--- EVALUATE("Distributor_List_#ThisProgram#")> --->
	<CFLOOP LIST = "#ThisProgram_Distributor_List#" INDEX = "ThisDistributor">
		<CFSET ThisProgram_Products_List = EVALUATE("Product_List_#ThisProgram#")>
		<CFSET Replaced_Distributor_ID = REPLACE(ThisDistributor,"-","_","All")>
		
		<CFLOOP LIST = "#ThisProgram_Products_List#" INDEX = "ThisProduct"><!--- LoopCount --->		
			<cfloop list = "#UOM_List#" index = "ThisUOM">
				<!--- Place holder for empty string.  New items do not have UOM conctaeneted in Form Field names --->
				<cfif ThisUOM eq 'x'>
					<cfset ThisUOM = ''/>
				</cfif>
				<CFSET Replaced_Product_ID = REPLACE(ThisProduct,"-","_","All")>
				<!--- <CFSET Product_Count = Product_Count+1> --->
				<!--- <CFSET Product_Count_Location = FIND("|",ThisProduct,1)> --->
				<!--- <CFSET Product_Count = LEFT(ThisProduct,Product_Count_Location - 1)> --->
				<!--- <CFSET ThisProduct = RIGHT(ThisProduct,LEN(ThisProduct) - Product_Count_Location)> --->

				<CFIF IsDefined("FORM.UOM_#ThisProgram#__#Replaced_Product_ID#__#Replaced_Distributor_ID#_#ThisUOM#") AND ThisProgram_Products_List NEQ "">
					<CFSET Program_Product_Count = Program_Product_Count+1>
				
					<CFSET UOM = EVALUATE("FORM.UOM_#ThisProgram#__#Replaced_Product_ID#__#Replaced_Distributor_ID#_#ThisUOM#")>
					<CFSET Volume = EVALUATE("FORM.Volume_#ThisProgram#__#Replaced_Product_ID#__#Replaced_Distributor_ID#_#ThisUOM#")>
					
					<CFSET UserPickedUOM = EVALUATE("FORM.UOM_#ThisProgram#__#Replaced_Product_ID#__#Replaced_Distributor_ID#_#ThisUOM#")>
					<CFSET UserEnteredQuantity = EVALUATE("FORM.Volume_#ThisProgram#__#Replaced_Product_ID#__#Replaced_Distributor_ID#_#ThisUOM#")>
					<!--- Fixed --->
					<CFIF IsDefined("FORM.Discount1_#ThisProgram#__#Replaced_Product_ID#__#Replaced_Distributor_ID#_#ThisUOM#")>
						<CFSET Fixed = EVALUATE("FORM.Discount1_#ThisProgram#__#Replaced_Product_ID#__#Replaced_Distributor_ID#_#ThisUOM#")>
					<CFELSE>
						<CFSET Fixed = "">
					</CFIF>
				
					<!--- Rebate --->
					<CFIF IsDefined("FORM.Discount2_#ThisProgram#__#Replaced_Product_ID#__#Replaced_Distributor_ID#_#ThisUOM#")>
						<CFSET Rebate = EVALUATE("FORM.Discount2_#ThisProgram#__#Replaced_Product_ID#__#Replaced_Distributor_ID#_#ThisUOM#")>
					<CFELSE>
						<CFSET Rebate = "">
					</CFIF>
					
					<!--- Growth --->
					<CFIF IsDefined("FORM.Discount4_#ThisProgram#__#Replaced_Product_ID#__#Replaced_Distributor_ID#_#ThisUOM#")>
						<CFSET Growth = EVALUATE("FORM.Discount4_#ThisProgram#__#Replaced_Product_ID#__#Replaced_Distributor_ID#_#ThisUOM#")>
					<CFELSE>
						<CFSET Growth = "">
					</CFIF>
					
					<CFSET Formula = ""><!--- EVALUATE("FORM.Discount5_#ThisProgram#__#Replaced_Product_ID#__#Replaced_Distributor_ID#")>  --->
					<!--- Formula --->
					<CFIF IsDefined("FORM.Discount5_#ThisProgram#__#Replaced_Product_ID#__#Replaced_Distributor_ID#")>
						<CFSET Formula = EVALUATE("FORM.Discount5_#ThisProgram#__#Replaced_Product_ID#__#Replaced_Distributor_ID#")>
					<CFELSE>
						<CFSET Formula = "">
					</CFIF>
					<!--- Bid --->
					<CFIF IsDefined("FORM.Discount11_#ThisProgram#__#Replaced_Product_ID#__#Replaced_Distributor_ID#_#ThisUOM#")>
						<CFSET Bid = EVALUATE("FORM.Discount11_#ThisProgram#__#Replaced_Product_ID#__#Replaced_Distributor_ID#_#ThisUOM#")>
					<CFELSE>
						<CFSET Bid = "">
					</CFIF>
					
					<!--- ClaimAdj --->
					<CFIF IsDefined("FORM.Discount10_#ThisProgram#__#Replaced_Product_ID#__#Replaced_Distributor_ID#_#ThisUOM#")>
						<CFSET ClaimAdjust = EVALUATE("FORM.Discount10_#ThisProgram#__#Replaced_Product_ID#__#Replaced_Distributor_ID#_#ThisUOM#")>
					<CFELSE>
						<CFSET ClaimAdjust = "">
					</CFIF>
		
					<cfif (UOM NEQ "" AND UOM EQ 6)>
						<cfset UOM = 2 />
						<cfif (Volume NEQ "")>
							<cfset Volume = Volume*100 />
						</cfif>	
					</cfif>
		
					<CFQUERY name="qInsertIntoTempTable" DATASOURCE="#Application.Datasource#">
						INSERT INTO ##Temp_Billback_Product_Info
						(
							Billback_ID, Program_ID, Product_ID, Distributor_ID,
							UOM, Volume, Fixed, Rebate,
							Growth, Formula, ClaimAdj, Bid,
							User_Picked_UOM, User_Entered_Quantity
						)
						VALUES
						(
							'#FORM.Billback_ID#', #ThisProgram#, '#ThisProduct#', '#ThisDistributor#',
							#UOM#, '#Volume#', '#Fixed#', '#Rebate#', 
							'#Growth#', '#Formula#', '#ClaimAdjust#', '#Bid#'
							,'#UserPickedUOM#','#UserEnteredQuantity#'
						)
					</CFQUERY>
				</CFIF>
			</cfloop><!--- END UOM Loop--->	
		</CFLOOP>
	</CFLOOP>
	<!--- Product list is defined --->
	</cfif>
</CFLOOP>
<!--- End Product Loop --->
<!--- ------------------Param151_200 #Param151_200#----1#ParamValue#1 Ana------------------------ --->
<!--- End Program Loop --->

<!--- ------------------#Program_Product_paramCount#---Param151_200 #Param151_200# Ana------------------------ --->
<CFSET Program_Product_Count = 0>


<CFQUERY NAME="CheckCopied" DATASOURCE="#Application.Datasource#">
	SELECT * FROM Billback WHERE Billback_ID = '#FORM.Billback_ID#'	
</CFQUERY>
<CFIF CheckCopied.CopiedBB NEQ "">
	<CFQUERY NAME="UpdateBit" DATASOURCE="#Application.Datasource#">
		UPDATE Billback 
		SET VolumeRateSaved = 1
		WHERE Billback_ID = '#FORM.Billback_ID#'
	</CFQUERY>
</CFIF>

<!--- 
#FORM.Billback_ID#<BR><BR>#Param1_50#<BR><BR>#Param51_100#<BR><BR>#Param101_150#<BR><BR>#Param151_200#<BR><BR>
EXEC Billback_Products_Insert '#FORM.Billback_ID#','#Param1_50#','#Param51_100#','#Param101_150#','#Param151_200#','#Param201_250#','#Param251_300#','#Param301_350#','#Param351_400#','#Param401_450#','#Param451_500#'
 --->

<!--- Milan (14963) - Update the LumpSum Amounts for the various LumpSum Components --->
<cfloop collection="#form#" item="ItemName">
	<cfif Left(ItemName,13) eq "LumpsumcompID">
		<cfset Billback_Program_Lumpsum_Component_ID = 	replace(replaceNoCase(ItemName,"LumpsumcompID_",""), "_", "-", "ALL") />
		<cfif val(Form[ItemName]) eq 0>
			<cfquery name="UpdateLS" datasource="#application.datasource#">
			 UPDATE Billback_Program_Lumpsum_Component
			 SET Deleted = 1
			 WHERE Billback_Program_Lumpsum_Component_ID = '#Billback_Program_Lumpsum_Component_ID#'
			</cfquery>
		<cfelse>
			<cfquery name="UpdateLS" datasource="#application.datasource#">
			 UPDATE Billback_Program_Lumpsum_Component
			 SET Amount = '#Form[ItemName]#'
			 WHERE Billback_Program_Lumpsum_Component_ID = '#Billback_Program_Lumpsum_Component_ID#'
			 AND Deleted = 0
			</cfquery>
		</cfif>
	</cfif>
</cfloop>
<!--- 
	GET all the products from the Billback_product data and reinsert them into the ##Temp_Billback_Product_Info 
	table after checking if they do not exist
--->
<!--- <cfquery NAME="getProductData" DATASOURCE="#Application.Datasource#">
SELECT 
DISTINCT 	Billback_Product.BB_Unknown_Product_Item_Number Item, 
						            Billback_Product.BB_Unknown_Product_Item_Number UPC, 
									Billback_Product.BB_Unknown_Product_Description Description, 
									'1' Net_Weight, 
									Billback_Product.BB_Product_UOM,
									BSA_Foodservice_Customers.Name,
									BSA_Foodservice_Customers.Ship_To,
									BSA_Foodservice_Customers.Shr_Ship_To,
									BSA_Foodservice_Customers.City,
									BSA_Foodservice_Customers.State,
									 'Unknown' Brand_Name,
									Billback_Product.Billback_Product_ID AS Product_ID,
									 
									ISNULL(BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID, '00000000-0000-0000-0000-000000000000') AS Customer_ID,
									CASE 
										WHEN Billback_Distributor_List.Distributor_ID IS NOT NULL THEN
											0
										WHEN Billback_Distributor_List.Distributor_ID IS NULL THEN
											1
									END AS HideCustomerRestrictions, 
									3 AS IsProductOnProgram,
									0 AS Is_Divested,
									Billback_Product.Billback_Product_ID,
									Billback_Program.Program_ID
						FROM    	Billback_Program 
						
						INNER JOIN	Billback_Product ON Billback_Product.Billback_ID = Billback_Program.Billback_ID AND 
									Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID AND 
									/* Billback_Program.Program_ID = <!--- #Program_ID#--->  AND */
									Billback_Product.Deleted = 0 
									/* AND Product_Type_ID = 3 */ AND
									Billback_Program.Billback_ID = '#FORM.Billback_ID#' AND 
									Billback_Program.Deleted = 0 

						LEFT JOIN 	Billback_Distributor ON Billback_Distributor.Billback_ID = Billback_Program.Billback_ID AND			
								 	Billback_Distributor.Deleted = 0
						LEFT JOIN 	Billback_Distributor_List ON Billback_Distributor_List.Billback_ID = Billback_Program.Billback_ID AND
								 	Billback_Distributor_List.Deleted = 0 AND 
								 	Billback_Distributor_List.Distributor_ID = Billback_Product.Distributor_ID
						LEFT JOIN BSA_Foodservice_Customers 
						ON
						(
						BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = IsNull(Billback_Distributor_List.Distributor_ID,Billback_Distributor.Distributor_ID) 
						)					
				   		ORDER BY Is_Divested, BSA_Foodservice_Customers.Ship_To, IsProductOnProgram, Item, UPC, Description
</cfquery>
--->
<!--- START:: 63746: SABERT: ERROR TRACKING CODE START // REMOVE AFTER ISSUE IS FOUND AND ADDRESSED --->
<!---
<cfquery NAME="TABLE_Create" DATASOURCE="#Application.Datasource#">
	DECLARE	@Created_Date datetime
	SET @Created_Date = getdate()
	
	IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Sabert_Billback_Program_Form_Dump')
	CREATE TABLE Sabert_Billback_Program_Form_Dump
	(
		[Sabert_Billback_Program_Form_Dump_ID] INT IDENTITY (1, 1) NOT NULL ,
		[Billback_ID] [UNIQUEIDENTIFIER] NULL,
		[XMLForm] [varchar](max),
		[Created_Date] [DATETIME] NULL CONSTRAINT [DF_Sabert_Billback_Program_Form_Dump_Created_Date]  DEFAULT (GETDATE()),
	)
	
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Sabert_Temp_Billback_Product_Info_Before_Update')
	CREATE TABLE Sabert_Temp_Billback_Product_Info_Before_Update(
	[Sabert_Temp_Billback_Product_Info_ID] [INT] IDENTITY(1,1) NOT NULL,
	[Billback_ID] [UNIQUEIDENTIFIER] NULL,
	[Program_ID] [INT] NULL,
	[Product_ID] [UNIQUEIDENTIFIER] NULL,
	[Distributor_ID] [UNIQUEIDENTIFIER] NULL,
	[UOM] [INT] NULL,
	[Volume] [VARCHAR](50) NULL,
	[Fixed] [VARCHAR](50) NULL,
	[Rebate] [VARCHAR](50) NULL,
	[Growth] [VARCHAR](50) NULL,
	[Formula] [VARCHAR](50) NULL,
	[ClaimAdj] [VARCHAR](50) NULL,
	[Bid] [VARCHAR](50) NULL,
	[Billback_Program_ID] [UNIQUEIDENTIFIER] NULL,
	[Billback_Product_ID] [UNIQUEIDENTIFIER] NULL,
	[Created_Date] [DATETIME] NULL CONSTRAINT [DF_Sabert_Temp_Billback_Product_Info_Before_Update_Created_Date]  DEFAULT (GETDATE())
  )
 
 INSERT INTO Sabert_Temp_Billback_Product_Info_Before_Update
(	   [Billback_ID]
      ,[Program_ID]
      ,[Product_ID]
      ,[Distributor_ID]
      ,[UOM]
      ,[Volume]
      ,[Fixed]
      ,[Rebate]
      ,[Growth]
      ,[Formula]
      ,[ClaimAdj]
      ,[Bid]
      ,[Billback_Program_ID]
      ,[Billback_Product_ID]
	  ,[Created_Date])
SELECT DISTINCT
		'#FORM.Billback_ID#' AS Billback_ID
      ,Billback_Program.Program_ID
      ,Billback_Product.Product_ID
      ,Billback_Product.Distributor_ID
      ,Billback_Product.BB_Product_UOM
      ,Billback_Product.BB_Product_Quantity
      ,CASE 
	  	WHEN BPD.BB_Product_Type_ID = 1
		THEN BPD.BB_RATE
		ELSE NULL 
	  	END AS Fixed
      ,CASE 
	  	WHEN BPD.BB_Product_Type_ID = 2
		THEN BPD.BB_RATE
		ELSE NULL 
	  	END AS Rebate
      ,CASE 
	  	WHEN BPD.BB_Product_Type_ID = 4
		THEN BPD.BB_RATE
		ELSE NULL 
	  	END AS Growth
      ,CASE 
	  	WHEN BPD.BB_Product_Type_ID = 5
		THEN BPD.BB_RATE
		ELSE NULL 
	  	END AS Formula
      ,CASE 
	  	WHEN BPD.BB_Product_Type_ID = 10
		THEN BPD.BB_RATE
		ELSE NULL 
	  	END AS ClaimAdj
      ,CASE 
	  	WHEN BPD.BB_Product_Type_ID = 11
		THEN BPD.BB_RATE
		ELSE NULL 
	  	END AS Bid
      ,Billback_Program.Billback_Program_ID
      ,Billback_Product.Billback_Product_ID
	  ,@Created_Date
FROM Billback_Program 
	 INNER JOIN Billback_Product ON Billback_Product.Billback_ID = Billback_Program.Billback_ID AND Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID AND  
	 Billback_Product.Deleted = 0 
	 AND Billback_Program.Billback_ID = '#FORM.Billback_ID#' 
	 AND Billback_Program.Deleted = 0 
	 INNER join Billback_Product_Detail BPD
							ON BPD.Billback_Product_ID = Billback_Product.Billback_Product_ID
	 LEFT JOIN Billback_Distributor ON Billback_Distributor.Billback_ID = Billback_Program.Billback_ID AND Billback_Distributor.Deleted = 0 
	 LEFT JOIN Billback_Distributor_List ON Billback_Distributor_List.Billback_ID = Billback_Program.Billback_ID AND Billback_Distributor_List.Deleted = 0 AND 
	 Billback_Distributor_List.Distributor_ID = Billback_Product.Distributor_ID 
	 LEFT JOIN BSA_Foodservice_Customers 
	 ON ( BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = IsNull(Billback_Distributor_List.Distributor_ID,Billback_Distributor.Distributor_ID) ) 
	 -- ORDER BY Is_Divested, BSA_Foodservice_Customers.Ship_To, IsProductOnProgram, Item, UPC, Description
</cfquery>	
	<cfset strXMLForm = "" /> --->
	<!---- CREATE  AN XML STRUCTURE OF THE FORM DATA THAT WAS SUBMITTED --->
<!---	<cfloop index="i" list="#Form.FieldNames#" delimiters=",">
		<cfset strXMLForm = strXMLForm & "<" & #i# & ">" & #Form[i]# & "</" & #i# & "> 
		" >
	</cfloop>
	<cfquery NAME="TABLE_Create" DATASOURCE="#Application.Datasource#">	
		DECLARE @Created_Date datetime
		SET @Created_Date = getdate()
		
		INSERT INTO Sabert_Billback_Program_Form_Dump 
		(
			Billback_ID, 
			XMLForm,
			Created_Date
		)
		VALUES
		(
			'#FORM.Billback_ID#',
			'#strXMLForm#',
			@Created_Date
		)
	</cfquery> --->
 <!--- END :: 63746: SABERT: ERROR TRACKING CODE START // REMOVE AFTER ISSUE IS FOUND --->

 

<CFQUERY NAME="GetDetailInfo" DATASOURCE="#Application.Datasource#">
	EXEC Billback_Products_Insert '#FORM.Billback_ID#'
</CFQUERY>

<CFQUERY name="qCreateTempTable" DATASOURCE="#Application.Datasource#">
	IF OBJECT_ID('tempdb..##Temp_Billback_Product_Info') IS NOT NULL
	DROP TABLE ##Temp_Billback_Product_Info
</CFQUERY>

<!--- 77469	Display Dist Channel at BB_Program Distributor Level   [ CF work ] /Anand/19-Jun-2018 --->
<cfif (appSettings.get_Setting('BB_Display_Dist_Channel_Per_Program_Distributor'))>
	<cfquery name="qInsBB_DC" datasource="#Application.Datasource#">
		EXEC Billback_Distribution_Channel_Insert '#FORM.Billback_ID#'
	</cfquery>
</cfif>

<!---
Rules for deleting entries from BB_Item_Invoice_Level
For client who do not allow editing of claimed amount and claimed quantity, only delete for WIP/RFA billbacks which are not third party upload 
For client who allow editing of claimed amount and claimed quantity, delete for any WIP/RFA billbacks		
--->
<cfif 
	NOT(
		(getPayeeType.Uploaded_Billback EQ 3 
	 	AND (application.oApplicationAppSettingsManager.getApplicationAppSettings().getBB_Upload_III_P_Qty_Amt_Editable() EQ 0 OR getPayeeType.BB_Level_Deviations_Override_Price_Flag EQ 1))
		OR 
		(getPayeeType.Uploaded_Billback EQ 2 
	 	AND (application.oApplicationAppSettingsManager.getApplicationAppSettings().getEditableClaimedDollarsQuantity() EQ 0 OR getPayeeType.BB_Level_Deviations_Override_Price_Flag EQ 1))
	 	)>
	<cfquery name="qDeleteGridTableEntries" datasource="#application.datasource#">
		DELETE FROM BB_Item_Invoice_Level
		WHERE Billback_ID = '#FORM.Billback_ID#'
	</cfquery>
</cfif>

<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
	 <br><br><br>
	 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
	 <br><br><br>
	</SPAN>
<!--- <CFDUMP VAR = "#FORM#"> --->

</CFOUTPUT>

<!--- D22543 - Prevent updates while deviation Run all is in progress - Grid could cause this issue as it opens in popup --->

<CFPARAM NAME="In_Progress_Check_BBID" default="">
<CFPARAM NAME="PageName_InProgress" default="">
<CFPARAM NAME="Progress_Type" default="0">

<CFSET In_Progress_Check_BBID = FORM.Billback_ID>
<CFSET PageName_InProgress = "Programs">
<CFSET Progress_Type = 2>	
<CFINCLUDE TEMPLATE = "BB_In_Progress_Check.cfm">

<cfset local_bbid = FORM.Billback_ID>
<cfinclude template="bb_menu_stats.cfm">
<cfoutput>
<script>
	//callfireEvent(window.parent.document,window.parent.summary_tab,'Click');
	window.parent.location.href="/billbacks/capture/INDEX.CFM?bbid=#FORM.Billback_ID#&SetLock=1";
</script>
</cfoutput>

