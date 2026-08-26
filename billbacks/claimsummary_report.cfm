<cfinclude template="/script/cf/string_functions.cfm" />
<cfsilent>
<cfset appSettings = application.appSettingsGet />
<cfset variables.theImage = ".." & Replace(appSettings.getLoginPageLogoPath(),"\","/","All") />
<cfset variables.bbRate = 0 />
<cfset variables.approved_amount = 0 />
<cfset variables.approved_amount_total = 0 />
<cfset variables.claimed_amount_total = 0 />
<cfset variables.variance_total = 0 />
<cfset variables.bDivestedNote = 0 />
<!--- <cfimage source="#variables.theImage#" name="myImage" action="read" /> --->
<!--- Turn on antialiasing. --->
<!---
<cfset ImageSetAntialiasing(myImage)>
<cfset ImageScaleToFit(myImage,75,75,"highestPerformance")> 
--->
<!--- Display the modified image in a browser. --->
<cfset variables.claimSummaryLabels = createObject("component", "components.products.Group.AttributeManager").getAllClaimSummary(true) />
<cfset variables.thisPayeeObj = CreateObject("component", "components.Billback.BillbackSummaryManager").init(url.Billback_ID) >
<cfset variables.getPayeeInfo = variables.thisPayeeObj.getPayeeInfo() />
<cfset variables.showVendorInfo = false />
<cfset variables.endPage = "" />
<cfset variables.currentPage = "" />
<cfquery name="pageHeaderValues" datasource="#application.datasource#">
SELECT	  	isnull(Billback_Program.Program_ID,'') AS ProgramID,
				isNull(Billback.Claim_Cases, 0.00) as Claim_Cases,
				isNull(Billback.Claim_Pounds, 0.00) as Claim_Pounds,
				isNull(Billback.BB_Amount, 0.00) as BB_Amount,
				Uploaded_Billback,
				Billback.*,
				Billback_Allied.BB_Is_Locked,
				Billback_Allied.BB_Locked_By_User_ID, 
				Billback_Status.BB_Status_Description,
				Billback_Settings.Auto_Approve_Amount,
				Billback_Settings.Auto_Approve_On
	FROM		Billback
				INNER JOIN Billback_Settings ON 1 = 1
				LEFT JOIN Billback_Allied ON 
				Billback_Allied.Billback_ID = Billback.Billback_ID
				LEFT JOIN Billback_Program ON
				Billback_Program.billback_id = 	Billback.billback_id 
				AND Billback_program.deleted = 0
				LEFT JOIN   Billback_Status ON 
				Billback_Status.Billback_Status_ID = Billback.Billback_Status_ID
	WHERE		Billback.Deleted = 0 
	AND			Billback.Billback_ID = '#url.Billback_ID#'
</cfquery>
<cfquery name="ReportQuery" datasource="#application.datasource#">
SELECT	DISTINCT
	Billback_Product.Billback_Product_ID, 
	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, 
	Billback_Product.BB_Product_Quantity, 
	Units_Of_Measure.Unit_Of_Measure_Desc,
	contract_main.contract_main_id,
	Billback_Program.program_id, 
	BSA_Foodservice_Items_Master.Is_Divested,
	CASE
	WHEN Billback_Product.BB_Product_UOM = 1 THEN
		ISNULL(BB_Item_Final_Detail.Expected_rate_CS, 0)
	ELSE
		ISNULL(BB_Item_Final_Detail.Expected_rate_LB, 0)
	END AS Expected_Rate,
	CASE
	WHEN Billback_Product.BB_Product_UOM = 1 THEN
	ISNULL(cast(Billback_Product_Detail.BB_Rate as float), 0)
	ELSE
	ISNULL(cast(Billback_Product_Detail.BB_Rate as float), 0)
	END AS Billback_Rate,
	CASE
	WHEN Billback_Product.BB_Product_UOM = 1 THEN
	ISNULL(BB_Item_Final_Detail.Paid_Rate_CS, 0)
	ELSE
	ISNULL(BB_Item_Final_Detail.Paid_Rate_LB, 0)
	END AS Approved_Rate,
	CASE
	WHEN Billback_Product.BB_Product_UOM = 1 THEN
	ISNULL(cast(Billback_Product.BB_Product_Quantity as float), 0)
	ELSE
	ISNULL(cast(Billback_Product.BB_Product_Quantity as float), 0)
	END AS Item_BB_Volume,
	CASE
	WHEN Billback_Product.BB_Product_UOM = 1 THEN
	ISNULL(BB_Item_Final.Item_E_Volume_CS, 0)
	ELSE
	ISNULL(BB_Item_Final.Item_E_Volume_LB, 0)
	END AS Item_E_Volume,
	CASE
	WHEN Billback_Product.BB_Product_UOM = 1 THEN
	ISNULL(BB_Item_Final.Item_Volume_Paid_CS, 0)
	ELSE
	ISNULL(BB_Item_Final.Item_Volume_Paid_LB, 0)
	END AS Item_Approved_Volume,
	ISNULL(CASE
	WHEN Billback_Product.BB_Product_UOM = 1 THEN
	ISNULL(BB_Item_Final.Item_Volume_Paid_CS, 0)
	ELSE
	ISNULL(BB_Item_Final.Item_Volume_Paid_LB, 0)/net_weight
	END,0) AS Item_Approved_Volume_CS,
	ISNULL(CASE
	WHEN Billback_Product.BB_Product_UOM = 2 THEN
	ISNULL(BB_Item_Final.Item_Volume_Paid_LB, 0)
	ELSE
	ISNULL(BB_Item_Final.Item_Volume_Paid_CS, 0)* net_weight
	END,0) AS Item_Approved_Volume_LB,
	ISNULL(CASE
	WHEN Billback_Product.BB_Product_UOM = 1 THEN
	ISNULL(BB_Item_Final.Item_E_Volume_CS, 0)
	ELSE
	ISNULL(BB_Item_Final.Item_E_Volume_CS, 0)/net_weight
	END,0) AS Item_Expected_Volume_CS,
	ISNULL(CASE
	WHEN Billback_Product.BB_Product_UOM = 2 THEN
	ISNULL(BB_Item_Final.Item_E_Volume_LB, 0)
	ELSE
	ISNULL(BB_Item_Final.Item_E_Volume_CS, 0)* net_weight
	END,0) AS Item_Expected_Volume_LB,
	ISNULL(CASE WHEN Billback_Product.BB_Product_UOM = 1 THEN
	ISNULL(cast(Billback_Product.BB_Product_Quantity as float), 0) ELSE 
	ISNULL(cast(Billback_Product.BB_Product_Quantity as float), 	0)/net_weight END,0) AS Item_BB_Volume_CS,
	ISNULL(CASE WHEN Billback_Product.BB_Product_UOM = 2 THEN 
	ISNULL(cast(Billback_Product.BB_Product_Quantity as float), 0) ELSE 
	ISNULL(cast(Billback_Product.BB_Product_Quantity as float), 0)* net_weight END,0) AS Item_BB_Volume_LB,
	CASE 
		WHEN Billback_Program.Program_ID IS NULL THEN
			Billback_Program.BB_Program_Title
		ELSE
			Contract_Main.Contract_Title
	END AS Program_Title,
	
	CASE 
	WHEN Billback_Program.Program_ID IS NULL THEN
		Billback_Program.BB_Program_Number
	ELSE
		Contract_Main.Contract_Number
	END AS Program_Number
	,CASE 
	WHEN Billback_Product.Product_ID IS NULL THEN
		Billback_Product.BB_Unknown_Product_Item_Number
	ELSE
		BSA_Foodservice_Items_Master.Item
	END AS Item_Number
	,CASE 
	WHEN Billback_Product.Product_ID IS NULL THEN
		Billback_Product.BB_Unknown_Product_Description
	ELSE
		BSA_Foodservice_Items_Master.Description
	END AS Description,
	Billback_Product_Detail.BB_Product_Type_ID, 
	BB_Rate,
	BB_Code, 
	Billback_Product.Distributor_id, 
	c.name, 
	c.ship_to,
	Billback.BB_Reference,
	Billback_Product.Product_Type_ID,
	BB_Fixed_Product_Rate.Invoice_Price_CS,
	BB_Fixed_Product_Rate.Program_Product_Price_CS

FROM		Billback
INNER JOIN	Billback_Program 
ON 		Billback_Program.Billback_ID = Billback.Billback_ID 
AND		Billback_Program.Deleted = 0
LEFT JOIN	Contract_Main 
ON 		Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
LEFT JOIN	Billback_Product -- claimed info at product level
ON 		Billback_Product.Billback_ID = Billback_Program.Billback_ID 
AND		Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID 
AND		Billback_Product.Deleted = 0
LEFT JOIN	BSA_Foodservice_Items_Master
ON 		BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID
LEFT JOIN	Units_of_Measure 
ON 		Units_of_Measure.Unit_Of_Measure_ID = Billback_Product.BB_Product_UOM
LEFT JOIN	Billback_Product_Detail  -- claimed info at product - discount type level
ON 		Billback_Product_Detail.Billback_ID = Billback_Product.Billback_ID 
AND		Billback_Product_Detail.BB_Product_Type_ID IN (1,2,10,11) 
AND		Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID 
AND		Billback_Product_Detail.Deleted = 0 
AND		Billback_Product_Detail.BB_Rate IS NOT NULL 
AND		LEN(Billback_Product_Detail.BB_Rate) > 0 
AND		ISNUMERIC(Billback_Product_Detail.BB_Rate) = 1 
AND		CAST(Billback_Product_Detail.BB_Rate AS Float) <> 0			
LEFT JOIN	BB_Item_Final  -- approved/paid info at product level
ON 		BB_Item_Final.Billback_ID = Billback_Product_Detail.Billback_ID 
AND		BB_Item_Final.Billback_Program_ID = Billback_Program.Billback_Program_ID 
AND		BB_Item_Final.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID 
AND 		BB_Item_Final.Deleted = 0
LEFT JOIN	BB_Item_Final_Detail -- approved/paid info at product - discount type level
ON 		BB_Item_Final_Detail.BB_Item_Final_ID = BB_Item_Final.BB_Item_Final_ID 
AND		BB_Item_Final_Detail.BB_Product_Type = Billback_Product_Detail.BB_Product_Type_ID 
AND		BB_Item_Final_Detail.Deleted = 0
LEFT JOIN   	BSA_Foodservice_customers C 
ON 		C.BSA_Foodservice_Customers_ID =  Billback_Product.Distributor_id
Left Join BB_Fixed_Product_Rate on
BB_Fixed_Product_Rate.Billback_Product_ID = Billback_Product.Billback_Product_ID
AND	BB_Fixed_Product_Rate.BB_Product_Type_ID = 1
And BB_Fixed_Product_Rate.BB_Product_Type_ID = Billback_Product_Detail.BB_Product_Type_ID
AND	BB_Fixed_Product_Rate.Deleted = 0
WHERE		Billback.Billback_ID = '#url.billback_id#'		
ORDER BY 	BSA_Foodservice_Items_Master.Is_Divested,c.ship_to, Billback_Product.Product_Type_ID,	
		item_number, Billback_Product_Detail.BB_Product_Type_ID
</cfquery>
<cfset useLakebaseForGetVendorId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_approved")>
<cfif useLakebaseForGetVendorId>
	<cftry>
		<cfset GetVendorId = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_approved", {
				"billback_id" = "eq.#url.Billback_ID#",
				"select" = "vendor_master_id"
			}), "vendor_master_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetVendorId = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetVendorId>
<cfquery name="GetVendorId" DATASOURCE="#application.datasource#">
   Select Vendor_master_ID 
   From BB_Approved 
   Where Billback_ID = '#url.Billback_ID#'
</cfquery>
</cfif>
<!--- Get the ERP ID of all the entries related to this billback from the Forge_ERP_Mapping table --->
<cfquery name="getERPInfo" DATASOURCE="#application.datasource#">
   SELECT DISTINCT ERP.Program_Number,BSAFIM.Item,ERP.Deal_ID
	 FROM Forge_ERP_Mapping ERP
	 INNER JOIN Billback_Program  BP
	 ON  ERP.Program_ID = BP.Program_ID
	 LEFT JOIN	Billback_Product BPR
	 ON  BPR.Product_ID = ERP.Product_ID 
	 LEFT JOIN BSA_Foodservice_Items_Master BSAFIM
	 ON BSAFIM.BSA_Foodservice_Items_Master_ID = BPR.Product_ID
	 WHERE bp.Billback_ID = '#url.Billback_ID#' 
	 AND BP.Deleted = 0 
	 AND ERP.Deal_ID IS NOT NULL 
	 AND ERP.Deleted = 0
	 AND BPR.Billback_Program_ID = BP.Billback_Program_ID 
	 AND BPR.Product_Type_ID = ERP.Discount_Type_ID 
	 AND BPR.Distributor_ID = ERP.Distributor_ID
	 AND BPR.Deleted = 0
</cfquery>	
<!--- <cfquery name="getCsrSettings" datasource="#application.datasource#">
 	Select Csr_Path,Csr_Days_To_Store,Csr_Address_Label
    From General_Settings
 </cfquery> --->
<cfif GetVendorId.Vendor_Master_ID neq "">
 <cfset variables.showVendorInfo = true />
  
  <cfquery name="VendorInfo" DATASOURCE="#application.datasource#">
	Select Vendor_Name,Vendor_Master.Vendor_ID,Active_Code,
		   Address_1,Address_2,City,State,Zipcode
	From   Vendor_Master
	Where  Vendor_Master_ID = <cfqueryparam cfsqltype="cf_sql_char" value="#GetVendorId.Vendor_master_ID#" /> 
  </cfquery>
</cfif>
</cfsilent>

<!--- Give the user the option to either SAVE or OPEN file --->
<cfheader name="Content-Disposition" value="attachment; filename=ClaimSummaryReport.pdf">
<cfcontent type="application/pdf">

<cfdocument format="pdf" orientation="landscape" margintop=".90" marginleft=".15" overwrite="false" <!--- filename="#getCsrSettings.Csr_Path#\#DateFormat(now(), 'mmddyyyy')#_#url.billback_id#.pdf" --->>
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
body {
	background: #ffffff;
	margin:0;
	padding:0;
	font-family: "Century Gothic";
	font-size: .6em;
}
.csrPageHeaderLabel {
	font-family: "Century Gothic";
	font-size: 8.5pt;
	font-weight: bold;
}

#notes {
	position: relative;
	bottom: -15px;
}

hr {
    left: 0;
	border: none 0; 
	border-top: 1px solid #000;
}

.csrPageHeader {
	font-family: "Century Gothic";
	font-size: 6.5pt;
 	font-weight: bold;
 	border-top: 1px solid #000;
 	border-bottom: 1px solid #000;
	vertical-align: top;
	text-align: center;
}

.csrPageHeaderData {
	font-family: "Century Gothic";
	font-size: .9em;
	font-weight: normal;
	vertical-align: bottom;
}

.csrDetailData {
	font-family: "Century Gothic";
	font-size: 5.5pt;
	text-align: center;
	vertical-align: top;
}

#csrBlank {
 clear: both;
}

td {
 padding: 3px;
}
</style>
</head>
<body>
<cfoutput>
<cfdocumentitem type="header">
<style type="text/css">
##csrAddress {
	position: absolute;
	top: 18px;
	right: 25px;
}
img {
	position: absolute;
	right: 250px;
	top: 0px;
}

.csrTitle {
	font-family: "Century Gothic";
	font-size: 13pt;
	font-weight: bold;
}

##csrTitlePos {
  left: 5px;
  top: 30px;
}

.csrAddressHeading {
	font-family: "Century Gothic";
	font-size: 11pt;
 	font-weight: normal;
}
</style>
<div id="csrTitlePos" class="csrTitle">#variables.claimSummaryLabels.Client_Label[1]#</div>
<!--- <cfimage source="#myImage#" action="writeToBrowser" /> ---><div id="csrAddress"><div align="center"> <span class="csrAddressHeading">#Replace(appsettings.getLettersAddress(), chr(13) & chr(10),"<br />", "All")#</span></div></div>
</cfdocumentitem>
<cfdocumentitem type="footer">
<style type="text/css">
##pageNum {
	 position: absolute;
	 bottom: .5em;
	 right: 20px;
  }
.footerTxt {
	font-family: "Century Gothic";
	font-size: 7.0pt;
	font-style: italic;
	text-align: left;
}
##footer {
	position: absolute;
	bottom: .5em;
	width: 300px;
}
</style>
<cfset variables.endPage = cfdocument.totalpagecount />
<cfset variables.currentPage = cfdocument.currentpagenumber />
<div id="footer"><span class="footerTxt">Printed on: #DateFormat(now(), "mm/dd/yyyy")#<span></div>
<div id="pageNum"><span class="footerTxt">Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#<span></div>
</cfdocumentitem>
<div id="csrBlank">&nbsp;</div>
<table width="750" cellpadding="2" cellspacing="2">
  <tr>
   <td class="csrPageHeaderLabel"><cfif NOT variables.claimSummaryLabels.deleted[2]><NOBR>#variables.claimSummaryLabels.Client_Label[2]#: <span class="csrPageHeaderData">&nbsp;#pageHeaderValues.referenceNum#</span><cfelse>&nbsp;</NOBR></cfif></td>
   <td class="csrPageHeaderLabel"><cfif NOT variables.claimSummaryLabels.deleted[3]><NOBR>#variables.claimSummaryLabels.Client_Label[3]#: <span class="csrPageHeaderData">&nbsp;#pageHeaderValues.BB_Code#</span><cfelse>&nbsp;</NOBR></cfif></td>
   <td class="csrPageHeaderLabel"><cfif NOT variables.claimSummaryLabels.deleted[6]><NOBR>#variables.claimSummaryLabels.Client_Label[6]#: <span class="csrPageHeaderData">&nbsp;#pageHeaderValues.BB_Reference#</span><cfelse>&nbsp;</NOBR></cfif></td>
   <td class="csrPageHeaderLabel"><cfif NOT variables.claimSummaryLabels.deleted[9]><NOBR>#variables.claimSummaryLabels.Client_Label[9]#:  <cfif variables.showVendorInfo><span class="csrPageHeaderData">&nbsp;#VendorInfo.Vendor_ID#</span></cfif><cfelse>&nbsp;</NOBR></cfif></td>
   <td class="csrPageHeaderLabel"><cfif NOT variables.claimSummaryLabels.deleted[10]><NOBR>#variables.claimSummaryLabels.Client_Label[10]#: <cfif variables.showVendorInfo><span class="csrPageHeaderData">#VendorInfo.Vendor_Name#</span></cfif><cfelse>&nbsp;</NOBR></cfif></td>
  </tr>
  <tr>
   <td class="csrPageHeaderLabel"><cfif NOT variables.claimSummaryLabels.deleted[4]><NOBR>#variables.claimSummaryLabels.Client_Label[4]#: <span class="csrPageHeaderData">&nbsp;#variables.getPayeeInfo.Payee_ShipTo#</span><cfelse>&nbsp;</NOBR></cfif></td>
   <td class="csrPageHeaderLabel"><cfif NOT variables.claimSummaryLabels.deleted[5]><NOBR>#variables.claimSummaryLabels.Client_Label[5]#: <span class="csrPageHeaderData">&nbsp;#variables.getPayeeInfo.Payee_Name#</span><cfelse>&nbsp;</NOBR></cfif></td>
   <td class="csrPageHeaderLabel">&nbsp;</td>
   <td class="csrPageHeaderLabel"><cfif NOT variables.claimSummaryLabels.deleted[7]><NOBR>#variables.claimSummaryLabels.Client_Label[7]#: <span class="csrPageHeaderData">&nbsp;#DateFormat(pageHeaderValues.BB_Start_Date, "mm/dd/yyyy")#</span><cfelse>&nbsp;</NOBR></cfif></td>
   <td class="csrPageHeaderLabel"><cfif NOT variables.claimSummaryLabels.deleted[8]><NOBR>#variables.claimSummaryLabels.Client_Label[8]#: <span class="csrPageHeaderData">&nbsp;#DateFormat(pageHeaderValues.BB_End_Date, "mm/dd/yyyy")#</span><cfelse>&nbsp;</NOBR></cfif></td>
  </tr>
</table>
<table width="750" cellpadding="0" cellspacing="0" border="0">
 <tbody>
  <tr>
   <td height="15"></td>
  </tr>
  <tr>
   <cfif variables.claimSummaryLabels.deleted[11]>
   <cfelse> 
	<td class="csrPageHeader" style="text-align: left">Item Description<br />#Replace(variables.claimSummaryLabels.Client_Label[11],chr(13),"<br />", "All")#</td>
   </cfif>
   <cfif variables.claimSummaryLabels.deleted[12]>
   <cfelse> 
    <td class="csrPageHeader">#Replace(variables.claimSummaryLabels.Client_Label[12],chr(13) & chr(10),"<br />", "All")#</td>
   </cfif>
   <cfif variables.claimSummaryLabels.deleted[13]>
   <cfelse>
    <td class="csrPageHeader">#Replace(variables.claimSummaryLabels.Client_Label[13],chr(13) & chr(10),"<br />", "All")#</td>
   </cfif>
   <cfif variables.claimSummaryLabels.deleted[14]>
   <cfelse>   
    <td class="csrPageHeader">#Replace(variables.claimSummaryLabels.Client_Label[14],chr(13) & chr(10),"<br />", "All")#</td>
   </cfif>
   <cfif variables.claimSummaryLabels.deleted[15]>
   <cfelse>
    <td class="csrPageHeader">#Replace(variables.claimSummaryLabels.Client_Label[15],chr(13) & chr(10),"<br />", "All")#</td>
   </cfif>
   <cfif variables.claimSummaryLabels.deleted[16]>
   <cfelse>
    <td class="csrPageHeader">#Replace(variables.claimSummaryLabels.Client_Label[16],chr(13) & chr(10),"<br />", "All")#</td>
   </cfif>
   <cfif variables.claimSummaryLabels.deleted[17]>
   <cfelse>
    <td class="csrPageHeader">#Replace(variables.claimSummaryLabels.Client_Label[17],chr(13) & chr(10),"<br />", "All")#</td>
   </cfif>
   <cfif variables.claimSummaryLabels.deleted[18]>
   <cfelse>
    <td class="csrPageHeader">#Replace(variables.claimSummaryLabels.Client_Label[18],chr(13) & chr(10),"<br />", "All")#</td>
   </cfif>
   <cfif variables.claimSummaryLabels.deleted[19] AND variables.claimSummaryLabels.deleted[20]>
   <cfelse>
    <td class="csrPageHeader"> <cfif variables.claimSummaryLabels.deleted[20] eq 0>#Replace(variables.claimSummaryLabels.Client_Label[20],chr(13) & chr(10),"<br />", "All")#</cfif> <cfif variables.claimSummaryLabels.deleted[19] eq 0 AND variables.claimSummaryLabels.deleted[20] eq 0><br /></cfif> <cfif variables.claimSummaryLabels.deleted[19] eq 0>#Replace(variables.claimSummaryLabels.Client_Label[19],chr(13) & chr(10),"<br />", "All")#</cfif></td>
   </cfif>
   <cfif variables.claimSummaryLabels.deleted[22] AND variables.claimSummaryLabels.deleted[24]>
   <cfelse>
    <td class="csrPageHeader"><cfif variables.claimSummaryLabels.deleted[24] eq 0>#Replace(variables.claimSummaryLabels.Client_Label[24],chr(13) & chr(10),"<br />", "All")#</cfif> <cfif variables.claimSummaryLabels.deleted[22] EQ 0 AND variables.claimSummaryLabels.deleted[24] EQ 0><br /></cfif> <cfif variables.claimSummaryLabels.deleted[22] eq 0>#Replace(variables.claimSummaryLabels.Client_Label[22],chr(13) & chr(10),"<br />", "All")#</cfif> </td>
   </cfif>
   <cfif variables.claimSummaryLabels.deleted[23]>
   <cfelse>
    <td class="csrPageHeader">#Replace(variables.claimSummaryLabels.Client_Label[23],chr(13) & chr(10),"<br />", "All")#</td>
   </cfif>
  </tr>
</cfoutput>

  <cfoutput query="ReportQuery"><!---  group="BSA_Foodservice_Items_Master_ID" ----------- Ana removing it for label 17451 --->
   <cfif BB_Rate neq "">
    <cfset variables.bbRate = BB_Rate />
   </cfif>
   <cfif Approved_Rate neq "" and Item_Approved_Volume neq "">
    <cfset variables.Approved_Amount = Approved_Rate * Item_Approved_Volume />
   </cfif>
    <cfif variables.bbRate neq "" and variables.Approved_Amount neq "">
     <cfset variables.varianceAmt = variables.bbRate - variables.Approved_Amount />
   </cfif>
   <cfset variables.approved_amount_total = variables.approved_amount_total +  variables.Approved_Amount />
   <cfset variables.claimed_amount_total = variables.claimed_amount_total + variables.bbRate />
   <cfset variables.variance_total = variables.claimed_amount_total - variables.approved_amount_total  />
  <tr>
   <cfif variables.claimSummaryLabels.deleted[11]>
   <cfelse> 
	<td class="csrDetailData" style="text-align: left">#Left(Description,25)#
		<cfif Is_Divested EQ 1> <cfset variables.bDivestedNote = 1 />*</cfif>
		<br />#item_number#</td>
   </cfif>
   <cfif variables.claimSummaryLabels.deleted[12]>
   <cfelse> 
    <td class="csrDetailData"><cfif Invoice_Price_CS neq "">$#Trim(NumberFormat(Invoice_Price_CS, "__.__"))#</cfif></td>
   </cfif>
	 <cfif variables.claimSummaryLabels.deleted[13]>
	 <cfelse>
   <td class="csrDetailData"><cfif Program_Product_Price_CS neq "">$#Trim(NumberFormat(Program_Product_Price_CS, "__.__"))#</cfif></td>
	 </cfif>
	 <cfif variables.claimSummaryLabels.deleted[14]>
	 <cfelse>
   <td class="csrDetailData">$#Trim(NumberFormat(Approved_Rate, "__.__"))#</td>
	 </cfif>
	 <cfif variables.claimSummaryLabels.deleted[15]>
	 <cfelse>
   <td class="csrDetailData">#Trim(NumberFormat(Item_BB_Volume_CS,"____,__.__"))#/#Trim(NumberFormat(Item_BB_Volume_LB,"____,__.__"))#</td>
	 </cfif>
	 <cfif variables.claimSummaryLabels.deleted[16]>
	 <cfelse>
   <td class="csrDetailData">$#Trim(NumberFormat(variables.Approved_Amount, "__.__"))#</td>
	 </cfif>
	 <cfif variables.claimSummaryLabels.deleted[17]>
	 <cfelse>
   <td class="csrDetailData">$#Trim(NumberFormat(variables.bbRate, "__.__"))#</td>
	 </cfif>
	 <cfif variables.claimSummaryLabels.deleted[18]>
	 <cfelse>
   <td class="csrDetailData">$#Trim(NumberFormat(variables.varianceAmt, "__.__"))#</td>
	 </cfif>
	 <cfif variables.claimSummaryLabels.deleted[19] AND variables.claimSummaryLabels.deleted[20]>
	 <cfelse>
   <td class="csrDetailData"><cfif variables.claimSummaryLabels.deleted[20] eq 0>#name#</cfif><cfif variables.claimSummaryLabels.deleted[19] eq 0 AND variables.claimSummaryLabels.deleted[20] eq 0><br /></cfif><cfif variables.claimSummaryLabels.deleted[19] eq 0>#ship_to#</cfif></td>
	 </cfif>
	 <cfif variables.claimSummaryLabels.deleted[22] AND variables.claimSummaryLabels.deleted[24]>
	 <cfelse>
   <td class="csrDetailData"><cfif variables.claimSummaryLabels.deleted[24] EQ 0>#Left(Program_Title,18)#</cfif><cfif variables.claimSummaryLabels.deleted[22] EQ 0 AND variables.claimSummaryLabels.deleted[24] EQ 0><br /></cfif><cfif variables.claimSummaryLabels.deleted[22] EQ 0>#Program_Number#</cfif></td>
	 </cfif>
	 <cfif variables.claimSummaryLabels.deleted[23]>
	 <cfelse>
   <td class="csrDetailData">#BB_Code#</td>
	 </cfif>
  </tr>
 </cfoutput>
 <cfoutput>
  <tr>
  <td colspan="8">&nbsp;</td>
  </tr>
  <tr>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	<td class="csrDetailData"><strong>Totals:</strong></td>
	<td class="csrDetailData"><strong>$#Trim(NumberFormat(variables.approved_amount_total, "__.__"))#</strong></td>
	<td class="csrDetailData"><strong>$#Trim(NumberFormat(variables.claimed_amount_total, "__.__"))#</strong></td>
	<td class="csrDetailData"><strong>
	 <cfif variables.variance_total lt 0>
	 #NegativeFormat(amount=variables.variance_total,isCurrency=1)#
	 <cfelse>	
	 $#Trim(NumberFormat(variables.variance_total, "__.__"))#
	</cfif>
	</strong>
	</td>
   </tr>
</cfoutput>
</tbody>
</table>
  <cfif variables.bDivestedNote EQ 1>&nbsp;&nbsp;&nbsp;* - indicates the item is divested<br><br></cfif>
 
  
<!--- If the ERP Label Exists (start) --->
<cfif variables.claimSummaryLabels.deleted[21] eq 0>
<cfoutput>
#Replace(variables.claimSummaryLabels.Client_Label[21],chr(13) & chr(10),"<br />", "All")#
</cfoutput>
<br />
<cfoutput query="getERPInfo">
<CFSET ShowNewLine = 1>
<!--- If the Program and Item in the previous record are the same. The purpose of doing this is to 
      show differenr deal ID's for a program/Item combinatiopn on the same row 
--->
<CFIF Program_Number eq Program_Number[currentrow -1] AND Item eq Item[currentrow -1]>
	<CFSET ShowNewLine = 0>
</CFIF>
<CFIF ShowNewLine EQ 1 AND getERPInfo.currentrow neq 1><BR /></CFIF>
<CFIF ShowNewLine EQ 1>Program_Number:&nbsp;#Program_Number#.&nbsp;Item:&nbsp;#Item#:&nbsp;</CFIF><CFIF ShowNewLine EQ 0>;&nbsp;</CFIF>#Deal_ID#
</cfoutput>
</cfif>
<!--- If the ERP Label Exists (end)--->
<cfoutput>
<cfif variables.currentPage eq variables.endPage>
 <div id="notes">
	<hr width="720" align="left" />
	Notes:<br />
   <span class="csrDetailData">#pageHeaderValues.BB_Creator_Notes#</span>
 </div>
</cfif>
</cfoutput>
 </body>
</html>
</cfdocument>