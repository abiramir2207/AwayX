<!----
diLog_Include.cfm
---->
<CFPARAM NAME="DI_IncludeFile" DEFAULT="true">

<CFSET addExtra="">

<CFIF NOT isDefined("DICommon_IncludeFile")>
	<CFINCLUDE template="diCommon.cfm">
</CFIF>


<CFPARAM NAME="URL.pageTitle" DEFAULT="Personal Settings: Data Integration Log">
<CFPARAM name="diTextFileCreationTime" default="">


<CFSET logRestrictedFieldList="created_date,err_number,err_message,err_column">


<CFSET logTableIDFields="">
<CFSET logTables = "">
<CFSET logCategory = "">
<CFSET logItems = "">
<CFSET originalDB = "">

<CFSWITCH EXPRESSION="#LCase(application.returned_customer_setting.customer_keyword)#">
	<CFCASE VALUE="conagra">
	
		<CFSET logTableIDFields = ListAppend(logTableIDFields, "zone1,region,lob,broker_id", ",")>
		<CFSET logTables 	= ListAppend(logTables, "Log_CF_Zone,Log_CF_Region,Log_CF_LOB,Log_CF_Broker", ",")>
		<CFSET logCategory 	= ListAppend(logCategory, "Brokers,Brokers,Brokers,Brokers", ",")>
		<CFSET logItems 	= ListAppend(logItems, "Zone,Region,LOB,Broker", ",")>
		<CFSET originalDB 	= ListAppend(originalDB, "Service_Zones,Service_Regions,Line_Of_Business,BSA_Foodservice_Brokers", ",")>
		
		<CFSET logTableIDFields = ListAppend(logTableIDFields, "buy_group_id,custid,family,shared_billto,shared_shipto,Original_Shared_Ship_To,Order_Number:Invoice_Version:Item", ",")>
		<CFSET logTables 	= ListAppend(logTables, "Log_CF_Buying_Group,Log_CF_Custid,Log_CF_Family,Log_CF_BillTo,Log_CF_ShipTo,LOG_CF_Invoice_Header,LOG_CF_Invoice_Detail", ",")>
		<CFSET logCategory 	= ListAppend(logCategory, "Distributors,Distributors,Distributors,Distributors,Distributors,Distributors,Distributors", ",")>
		<CFSET logItems 	= ListAppend(logItems, "Buying_Group,Custid,Family,BillTo,ShipTo,Invoice_Header,Invoice_Detail", ",")>
		<CFSET originalDB 	= ListAppend(originalDB, "Distributor_Buying_Groups,Distributor_Customer_ID,Distributor_Family,Distributor_Bill_To,BSA_Foodservice_Customers,Invoice_Header,Invoice_Detail", ",")>
		
		<CFSET logTableIDFields = ListAppend(logTableIDFields, "label,type_group,type,q_brand,item:lob,item", ",")>
		<CFSET logTables 	= ListAppend(logTables, "Log_CF_Label,Log_CF_Type_Group,Log_CF_Type,Log_CF_QBrand,Log_CF_Q_Brand_Desc,Log_CF_Item", ",")>
		<CFSET logCategory 	= ListAppend(logCategory, "Products,Products,Products,Products,Products,Products", ",")>
		<CFSET logItems 	= ListAppend(logItems, "Label,Type_Group,Type,QBrand,Q_Brand_Desc,Item", ",")>
		<CFSET originalDB 	= ListAppend(originalDB, "Brand,Type_Group_Desc,Type_Code_Desc,Q_Brand_Desc,Product_Q_Brand_Desc,BSA_Foodservice_Items_Master", ",")>
		
		
		
		<CFSET LogZoneListFields="zone_name">
		<CFSET LogRegionListFields="region_name">
		<CFSET LogLOBListFields="lob_name">
		<CFSET LogBrokerListFields="name,region_name,zone_name,lob_name">
		<CFSET LogBuying_GroupListFields="name">
		<CFSET LogCustidListFields="custid_name">
		<CFSET LogFamilyListFields="family_name">
		<CFSET LogBillToListFields="shared_billto,name">
		<CFSET LogShipToListFields="shared_shipto,name,primary_broker">
		<CFSET LogInvoice_HeaderListFields="Invoice_Version,Original_Shared_Ship_To">
		<CFSET LogInvoice_DetailListFields="Order_Number,Invoice_Version">
		<CFSET LogLabelListFields="label_name">
		<CFSET LogType_GroupListFields="type_group_name">
		<CFSET LogTypeListFields="type_name">
		<CFSET LogQBrandListFields="q_brand_name">
		<CFSET LogQ_Brand_DescListFields="item,lob,q_brand_desc">
		<CFSET LogItemListFields="item,description,case_upc">
		
		
		
		<CFSET LogZoneFields="zone1,zone_name,created_date">
		<CFSET DBZoneFields="zone_number,zone_name,created_date">
		<CFSET DBZoneSQL="SELECT #DBZoneFields# FROM Service_Zones WHERE zone_number='--id--'">
		
		<CFSET LogRegionFields="region,region_name,created_date">
		<CFSET DBRegionFields="region_number,region_name,created_date">
		<CFSET DBRegionSQL="SELECT #DBRegionFields# FROM Service_Regions WHERE region_number='--id--'">
		
		<CFSET LogLOBFields="lob,lob_name,created_date">
		<CFSET DBLOBFields="line_of_business,line_of_business_name,created_date">
		<CFSET DBLOBSQL="SELECT #DBLOBFields# FROM Line_Of_Business WHERE line_of_business='--id--'">
		
		
		<CFSET LogBrokerFields="broker_id,name,created_date,active_code,address1,address2,city,state,zip,phone,contact_name,lob,lob_name,region,region_name,zone1,zone_name">
		<CFSET DBBrokerFields="cfb.broker_shard,cfb.broker_name,cfb.created_date,cfb.active_code,cfb.address,cfb.address_2,cfb.city,cfb.state,cfb.zip,cfb.phone_number,cfb.account_exec,lob.Line_Of_Business,lob.Line_Of_Business_Name,sr.Region_Number,sr.Region_Name,sz.Zone_Number,sz.Zone_Name">
		<CFSET DBBrokerSQL="SELECT #DBBrokerFields# FROM BSA_Foodservice_Brokers cfb,Line_Of_Business lob,Service_Regions sr,Service_Zones sz WHERE broker_shard='--id--' and lob.Line_Of_Business_ID=cfb.Line_Of_Business_ID and sr.Service_Region_ID=cfb.Service_Region_ID and sz.Service_Zone_ID=cfb.Service_Zone_ID">
		
		
		<CFSET LogBuying_GroupFields="buy_group_id,name,active_code,contact_name,address1,address2,city,state,zip,phone,created_date">
		<CFSET DBBuying_GroupFields="buying_group,buying_group_name,active_code,primary_contact,address1,address2,city,state,zip,phone,created_date">
		
		<CFSET DBBuying_GroupSQL="SELECT #DBBuying_GroupFields# FROM Distributor_Buying_Groups WHERE buying_group='--id--'">
		
		
		<CFSET LogCustidFields="custid,custid_name,created_date">
		<CFSET DBCustidFields="custid,custid_name,created_date">
		<CFSET DBCustidSQL="SELECT #DBCustidFields# FROM Distributor_Customer_ID WHERE custid='--id--'">
		
		
		<CFSET LogFamilyFields="family,family_name,created_date">
		<CFSET DBFamilyFields="family,family_name,created_date">
		<CFSET DBFamilySQL="SELECT #DBFamilyFields# FROM Distributor_Family WHERE family='--id--'">
		
		
		<CFSET LogBillToFields="shared_billto,name,active_code,address1,address2,city,state,zip,phone,legacy_billto,created_date">
		<CFSET DBBillToFields="shr_bill_to,name,active_code,address1,address2,city,state,zip,phone,bill_to,created_date">
		<CFSET DBBillToSQL="SELECT #DBBillToFields# FROM Distributor_Bill_To WHERE shr_bill_to='--id--'">
		
		
		<CFSET LogShipToFields="shared_shipto,name,address1,address2,city,state,zip,phone,created_date,legacy_shipto,active_code,sales_type,default_ship_plant,primary_lob,primary_broker,primary_buy_group,custid,custid_name,family,family_name,shared_billto">
		<CFSET DBShipToFields="cfc.shr_ship_to,cfc.name,cfc.address_1,cfc.address_2,cfc.city,cfc.state,cfc.zipcode,cfc.phone,cfc.created_date,cfc.ship_to,cfc.active_code,cfc.sales_type,cfc.plant,lob.Line_Of_Business,cfb.Broker_Shard,bg.Buying_Group,c.custid,c.custid_name,f.family,f.family_name,bt.shr_bill_to">
		<CFSET DBShipToSQL="SELECT #DBShipToFields# FROM BSA_Foodservice_Customers cfc,Line_Of_Business lob,BSA_Foodservice_Brokers cfb,Distributor_Buying_Groups bg,Distributor_Customer_ID c,Distributor_Family f,Distributor_Bill_To bt WHERE shr_ship_to='--id--' and  lob.Line_Of_Business_ID=cfc.Line_Of_Business_ID and cfc.BSA_Foodservice_Brokers_ID=cfb.BSA_Foodservice_Brokers_ID and bg.Buying_Group_ID=cfc.Buying_Group_ID and c.Customer_ID=cfc.Customer_ID and f.Family_ID=cfc.Family_ID and bt.Distributor_Bill_To_ID=cfc.Distributor_Bill_To_ID">
		
		
		
		<CFSET LogInvoice_HeaderFields="Order_Number,Invoice_Version,Original_Shared_Ship_To,Fiscal_Year,Fiscal_Period,Fiscal_Week,Current_Shared_Ship_To,Ship_plant,Order_date,ship_Date,Invoice_Date,Delivery_Date,Scheduled_Ship_date,Shared_Invoice_Number,Purchase_order,Shared_Order_Number,Deliver,Invoice_Credit_Flag,Sales_Type,Order_Type,order_Status,Manual_Bill_Flag">
		<CFSET DBInvoice_HeaderFields="Order_Number,Invoice_Version,Original_Shared_Ship_To,Fiscal_Year,Fiscal_Period,Fiscal_Week,Current_Shared_Ship_To,Ship_plant,Order_date,ship_Date,Invoice_Date,Delivery_Date,Scheduled_Ship_date,Shared_Invoice_Number,Purchase_order,Shared_Order_Number,Deliver,Invoice_Credit_Flag,Sales_Type,Order_Type,order_Status,Manual_Bill_Flag">
		<CFSET DBInvoice_HeaderSQL="SELECT #DBInvoice_HeaderFields# FROM Invoice_Header WHERE Original_Shared_Ship_To='--id--'">
		
		
		<CFSET LogInvoice_DetailFields="Order_Number,Invoice_version,Item,Fiscal_Year,Fiscal_Period,Fiscal_Week,Line,Ship_Plant,Current_Shared_Ship_To,Current_Prime_Broker,Buy_Group,Current_LOB,Order_Status,Invoice_Date,Original_Q_Brand,Original_Q_Brand_Description,Original_Shared_Ship_To,MFG_Plant,Prime_Plant,Original_Prime_Broker,Secondary_Broker,Trade_Mktg,Cases_Ordered,Cases_Invoiced,Pounds_Ordered,Pounds_Invoiced,Customer_Requested_Cases,Gross_Weight,Price_Unit_of_Measure,Unit_Price,Sales_Dollars,Off_Invoice_Dollars,Trade_Dollars,Fixed_Cost,Variable_Cost,Freight_Revenue,Freight_Expense,Primary_Broker_Commission,Secondary_Broker_Commission,Buy_Group_Commission,Actual_Deduction_Dollars,Deduction_Reason">
		<CFSET DBInvoice_DetailFields="Order_Number,Invoice_version,Item,Fiscal_Year,Fiscal_Period,Fiscal_Week,Line,Ship_Plant,Current_Shared_Ship_To,Current_Prime_Broker,Buy_Group,Current_LOB,Order_Status,Invoice_Date,Original_Q_Brand,Original_Q_Brand_Description,Original_Shared_Ship_To,MFG_Plant,Prime_Plant,Original_Prime_Broker,Secondary_Broker,Trade_Mktg,Cases_Ordered,Cases_Invoiced,Pounds_Ordered,Pounds_Invoiced,Customer_Requested_Cases,Gross_Weight,Price_Unit_of_Measure,Unit_Price,Sales_Dollars,Off_Invoice_Dollars,Trade_Dollars,Fixed_Cost,Variable_Cost,Freight_Revenue,Freight_Expense,Primary_Broker_Commission,Secondary_Broker_Commission,Buy_Group_Commission,Actual_Deduction_Dollars,Deduction_Reason">
		<CFSET DBInvoice_DetailSQL="SELECT #DBInvoice_DetailFields# FROM Invoice_Detail WHERE Order_Number='--id--' and Invoice_Version='--id1--' and Item='--id2--'">
		
		
		<CFSET LogLabelFields="label,label_name,created_date">
		<CFSET DBLabelFields="brand,brand_name,created_date">
		<CFSET DBLabelSQL="SELECT #DBLabelFields# FROM Brand WHERE brand='--id--'">
		
		
		<CFSET LogType_GroupFields="type_group,type_group_name,created_date">
		<CFSET DBType_GroupFields="type_group_legacy,type_group_desc,created_date">
		<CFSET DBType_GroupSQL="SELECT #DBType_GroupFields# FROM Type_Group_Desc WHERE type_group_legacy='--id--'">
		
		
		<CFSET LogTypeFields="type,type_name,created_date">
		<CFSET DBTypeFields="type_code_desc,type_code_legacy,created_date">
		<CFSET DBTypeSQL="SELECT #DBTypeFields# FROM Type_Code_Desc WHERE type_code_desc='--id--'">
		
		
		<CFSET LogQBrandFields="q_brand,q_brand_name,created_date">
		<CFSET DBQBrandFields="q_brand_legacy,q_brand,created_date">
		<CFSET DBQBrandSQL="SELECT #DBQBrandFields# FROM Q_Brand_Desc WHERE q_brand_legacy='--id--'">
		
		
		<CFSET LogQ_Brand_DescFields="item,lob,category_lob,category_no,category_desc,prod_category,disp_sequence,created_date">
		<CFSET DBQ_Brand_DescFields="item,lob,category_lob,category_no,category_desc,prod_category,disp_sequence,created_date">
		<CFSET DBQ_Brand_DescSQL="SELECT #DBQ_Brand_DescFields# FROM Product_Q_Brand_Desc WHERE LOB='--id1--' and item='--id--'">
		
		
		<CFSET LogItemFields="item,active_code,description,style,style_name,sales_group,sales_country,created_date,prime_lob,type,type_name,type_group,type_group_name,label_name,Category,Category_Name,item_class">
		<CFSET DBItemFields="cfi.item,cfi.active_code,cfi.description,cfi.style,cfi.style_name,cfi.sales_group,cfi.sales_country,cfi.created_date,lob.Line_Of_Business,tc.type_code_legacy,tc.type_code_desc,tg.type_group_legacy,tg.type_group_desc,b.brand_name,c.Category,c.Category_Name,cfi.item_class">
		<CFSET DBItemSQL="SELECT #DBItemFields# FROM BSA_Foodservice_Items_Master cfi, Line_Of_Business lob,Type_Code_Desc tc,Type_Group_Desc tg,Brand b,Category c WHERE item='--id--' and lob.Line_Of_Business_ID=cfi.Line_Of_Business_ID and tc.Type_Code_Desc_ID=cfi.Type_Code_Desc_ID and tg.Type_Group_Desc_ID=cfi.Type_Group_Desc_ID and b.Brand_ID=cfi.Brand_ID and c.Category_ID=cfi.Category_ID">
		

		<CFSET Weekly_log_Max_Count = 5>
		
		<CFSET Weekly_Log_Exclude_list = logItems>
		
	</CFCASE>

	<CFCASE VALUE="resers">
		<!------231.
		<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/settings/dataintegration/diLog.cfm?PageTitle=SYSTEM ADMINISTRATION: Data Integration" TARGET="mainwindow">data integration</A><BR>----->
		<CFSET logTableIDFields = ListAppend(logTableIDFields, "broker_shard,Salesperson_Number", ",")>		
		<CFSET logTables 	= ListAppend(logTables, "Log_CF_Broker,Log_CF_Markets", ",")>
		<CFSET logCategory 	= ListAppend(logCategory, "Brokers,Brokers", ",")>
		<CFSET logItems 	= ListAppend(logItems, "Broker,Market", ",")>
		<CFSET originalDB 	= ListAppend(originalDB, "BSA_Foodservice_Brokers,Service_Markets", ",")>
		
		<CFSET logTableIDFields = ListAppend(logTableIDFields, "Buying_Group,family,Shr_Bill_To,ship_to,Original_Shared_Ship_To,Order_Number:Invoice_Version:Item", ",")>		
		<CFSET logTables 	= ListAppend(logTables, "Log_CF_Buying_Group,Log_CF_Family,Log_CF_BillTo,Log_CF_ShipTo,LOG_CF_Invoice_Header,LOG_CF_Invoice_Detail", ",")>
		<CFSET logCategory 	= ListAppend(logCategory, "Distributors,Distributors,Distributors,Distributors,Distributors,Distributors", ",")>
		<CFSET logItems 	= ListAppend(logItems, "Buying_Group,Family,BillTo,ShipTo,Invoice_Header,Invoice_Detail", ",")>
		<CFSET originalDB 	= ListAppend(originalDB, "Distributor_Buying_Groups,Distributor_Family,Distributor_Bill_To,BSA_Foodservice_Customers,Invoice_Header,Invoice_Detail", ",")>
		
		<CFSET logTableIDFields = ListAppend(logTableIDFields, "type_group_legacy,Type_Code_Legacy,q_brand,item", ",")>		
		<CFSET logTables 	= ListAppend(logTables, "Log_CF_Type_Group,Log_CF_Type,Log_CF_QBrand,Log_CF_Item", ",")>
		<CFSET logCategory 	= ListAppend(logCategory, "Products,Products,Products,Products", ",")>
		<CFSET logItems 	= ListAppend(logItems, "Type_Group,Type,QBrand,Item", ",")>
		<CFSET originalDB 	= ListAppend(originalDB, "Type_Group_Desc,Type_Code_Desc,Q_Brand_Desc,BSA_Foodservice_Items_Master", ",")>
		
		<CFSET logTableIDFields = ListAppend(logTableIDFields, "Price_List_ID:Item_Number,Ship_To:Item_Number,Price_List_ID,Ship_To", ",")>
		<CFSET logTables 	= ListAppend(logTables, "Log_CF_Price_List_Detail,Log_CF_Price_List_Detail_Special,Log_CF_Price_List_Header,Log_CF_Price_List_Header_Special", ",")>
		<CFSET logCategory 	= ListAppend(logCategory, "Price_List,Price_List,Price_List,Price_List", ",")>
		<CFSET logItems 	= ListAppend(logItems, "Price_List_Detail,Price_List_Detail_Special,Price_List_Header,Price_List_Header_Special", ",")>
		<CFSET originalDB 	= ListAppend(originalDB, "Price_List_Detail,Price_List_Detail_Special,Price_List_Header,Price_List_Header_Special", ",")>
		
		
		<CFSET LogBrokerListFields="Broker_Name">
		<CFSET LogMarketListFields="Market_Name">		
		
		<CFSET LogBuying_GroupListFields="buying_group_name">
		<CFSET LogFamilyListFields="family_name">
		<CFSET LogBillToListFields="Shr_Bill_To,name">
		<CFSET LogShipToListFields="Ship_To,name,Std_Broker">
		<CFSET LogInvoice_HeaderListFields="Invoice_Version,Original_Shared_Ship_To">
		<CFSET LogInvoice_DetailListFields="Order_Number,Invoice_Version">
		
		<CFSET LogLabelListFields="label_name">
		<CFSET LogType_GroupListFields="Type_Group_Legacy">
		<CFSET LogTypeListFields="Type_Code_Desc">
		<CFSET LogQBrandListFields="Q_Brand">
		<!------<CFSET LogQ_Brand_DescListFields="item,lob,q_brand_desc">----->
		<CFSET LogItemListFields="item,description">
		<CFSET LogPrice_List_DetailListFields="Price_List_ID">
		<CFSET LogPrice_List_Detail_SpecialListFields="Ship_To,Item_Number">
		<CFSET LogPrice_List_HeaderListFields="Price_List_ID">
		<CFSET LogPrice_List_Header_SpecialListFields="Ship_To,Description">
		
		
		<!---- almost done ---->
		<CFSET LogBrokerFields="broker_id,name,created_date,active_code,address1,address2,city,state,zip,phone,contact_name">
		<CFSET DBBrokerFields="cfb.broker_shard,cfb.broker_name,cfb.created_date,cfb.active_code,cfb.address,cfb.address_2,cfb.city,cfb.state,cfb.zip,cfb.phone_number,cfb.account_exec">
		<CFSET DBBrokerSQL="SELECT #DBBrokerFields# FROM BSA_Foodservice_Brokers cfb,Line_Of_Business lob,Service_Regions sr,Service_Zones sz WHERE broker_shard='--id--' and lob.Line_Of_Business_ID=cfb.Line_Of_Business_ID and sr.Service_Region_ID=cfb.Service_Region_ID and sz.Service_Zone_ID=cfb.Service_Zone_ID">
		<CFSET Original_DB_ID_Broker="BSA_Foodservice_Brokers_ID">
		<CFSET Original_DB_Weekly_Log_Fields_Broker="broker_shard,broker_name">
		
		<CFSET LogMarketFields="Market_Name">
		<CFSET DBMarketFields="Market_Name">
		<CFSET DBMarketSQL="SELECT #DBMarketFields# FROM Service_Markets WHERE Salesperson_Number = '--id--'">
		<CFSET Original_DB_ID_Market="Service_Market_ID">
		<CFSET Original_DB_Weekly_Log_Fields_Market="Market_Name">
		
		
		<CFSET LogBuying_GroupFields="buy_group_id,buying_group_name,active_code,contact_name,address1,address2,city,state,zip,phone,created_date">
		<CFSET DBBuying_GroupFields="buying_group,buying_group_name,active_code,primary_contact,address1,address2,city,state,zip,phone,created_date">
		<CFSET DBBuying_GroupSQL="SELECT #DBBuying_GroupFields# FROM Distributor_Buying_Groups WHERE buying_group='--id--'">
		<CFSET Original_DB_ID_Buying_Group="Buying_Group_ID">
		<CFSET Original_DB_Weekly_Log_Fields_Buying_Group="buying_group,buying_group_name">
		
		
		<CFSET LogFamilyFields="family,family_name,created_date">
		<CFSET DBFamilyFields="family,family_name,created_date">
		<CFSET DBFamilySQL="SELECT #DBFamilyFields# FROM Distributor_Family WHERE family='--id--'">
		<CFSET Original_DB_ID_Family="Family_ID">
		<CFSET Original_DB_Weekly_Log_Fields_Family="family,family_name">
		
		
		<CFSET LogBillToFields="shared_billto,name,active_code,address1,address2,city,state,zip,phone,legacy_billto,created_date">
		<CFSET DBBillToFields="shr_bill_to,name,active_code,address1,address2,city,state,zip,phone,bill_to,created_date">
		<CFSET DBBillToSQL="SELECT #DBBillToFields# FROM Distributor_Bill_To WHERE shr_bill_to='--id--'">
		<CFSET Original_DB_ID_BillTo="Distributor_Bill_To_ID">
		<CFSET Original_DB_Weekly_Log_Fields_BillTo="shr_bill_to,name,address1,city,state,zip">
		
		<!---- almost done ---->
		<CFSET LogShipToFields="ship_to,name,address1,address2,city,state,zip,phone,created_date,legacy_shipto,active_code,sales_type,default_ship_plant,primary_lob,primary_broker,primary_buy_group,custid,custid_name,family,family_name,shared_billto">
		<CFSET DBShipToFields="cfc.shr_ship_to,cfc.name,cfc.address_1,cfc.address_2,cfc.city,cfc.state,cfc.zipcode,cfc.phone,cfc.created_date,cfc.ship_to,cfc.active_code,cfc.sales_type,cfc.plant,lob.Line_Of_Business,cfb.Broker_Shard,bg.Buying_Group,c.custid,c.custid_name,f.family,f.family_name,bt.shr_bill_to">
		<CFSET DBShipToSQL="SELECT #DBShipToFields# FROM BSA_Foodservice_Customers cfc,Line_Of_Business lob,BSA_Foodservice_Brokers cfb,Distributor_Buying_Groups bg,Distributor_Customer_ID c,Distributor_Family f,Distributor_Bill_To bt WHERE shr_ship_to='--id--' and  lob.Line_Of_Business_ID=cfc.Line_Of_Business_ID and cfc.BSA_Foodservice_Brokers_ID=cfb.BSA_Foodservice_Brokers_ID and bg.Buying_Group_ID=cfc.Buying_Group_ID and c.Customer_ID=cfc.Customer_ID and f.Family_ID=cfc.Family_ID and bt.Distributor_Bill_To_ID=cfc.Distributor_Bill_To_ID">
		<CFSET Original_DB_ID_ShipTo="BSA_Foodservice_Customers_ID">
		<CFSET Original_DB_Weekly_Log_Fields_ShipTo="shr_ship_to,name,address_1,address_2">
		
		
		<CFSET LogInvoice_HeaderFields="Order_Number,Invoice_Version,Original_Shared_Ship_To,Fiscal_Year,Fiscal_Period,Fiscal_Week,Current_Shared_Ship_To,Ship_plant,Order_date,ship_Date,Invoice_Date,Delivery_Date,Scheduled_Ship_date,Shared_Invoice_Number,Purchase_order,Shared_Order_Number,Deliver,Invoice_Credit_Flag,Sales_Type,Order_Type,order_Status,Manual_Bill_Flag">
		<CFSET DBInvoice_HeaderFields="Order_Number,Invoice_Version,Original_Shared_Ship_To,Fiscal_Year,Fiscal_Period,Fiscal_Week,Current_Shared_Ship_To,Ship_plant,Order_date,ship_Date,Invoice_Date,Delivery_Date,Scheduled_Ship_date,Shared_Invoice_Number,Purchase_order,Shared_Order_Number,Deliver,Invoice_Credit_Flag,Sales_Type,Order_Type,order_Status,Manual_Bill_Flag">
		<CFSET DBInvoice_HeaderSQL="SELECT #DBInvoice_HeaderFields# FROM Invoice_Header WHERE Original_Shared_Ship_To='--id--'">
		<CFSET Original_DB_ID_Invoice_Header="Invoice_Header_ID">
		<CFSET Original_DB_Weekly_Log_Fields_Invoice_Header="Order_Number,Invoice_Version,Original_Shared_Ship_To">
		
		
		<CFSET LogInvoice_DetailFields="Order_Number,Invoice_version,Item,Fiscal_Year,Fiscal_Period,Fiscal_Week,Line,Ship_Plant,Current_Shared_Ship_To,Current_Prime_Broker,Buy_Group,Current_LOB,Order_Status,Invoice_Date,Original_Q_Brand,Original_Q_Brand_Description,Original_Shared_Ship_To,MFG_Plant,Prime_Plant,Original_Prime_Broker,Secondary_Broker,Trade_Mktg,Cases_Ordered,Cases_Invoiced,Pounds_Ordered,Pounds_Invoiced,Customer_Requested_Cases,Gross_Weight,Price_Unit_of_Measure,Unit_Price,Sales_Dollars,Off_Invoice_Dollars,Trade_Dollars,Fixed_Cost,Variable_Cost,Freight_Revenue,Freight_Expense,Primary_Broker_Commission,Secondary_Broker_Commission,Buy_Group_Commission,Actual_Deduction_Dollars,Deduction_Reason">
		<CFSET DBInvoice_DetailFields="Order_Number,Invoice_version,Item,Fiscal_Year,Fiscal_Period,Fiscal_Week,Line,Ship_Plant,Current_Shared_Ship_To,Current_Prime_Broker,Buy_Group,Current_LOB,Order_Status,Invoice_Date,Original_Q_Brand,Original_Q_Brand_Description,Original_Shared_Ship_To,MFG_Plant,Prime_Plant,Original_Prime_Broker,Secondary_Broker,Trade_Mktg,Cases_Ordered,Cases_Invoiced,Pounds_Ordered,Pounds_Invoiced,Customer_Requested_Cases,Gross_Weight,Price_Unit_of_Measure,Unit_Price,Sales_Dollars,Off_Invoice_Dollars,Trade_Dollars,Fixed_Cost,Variable_Cost,Freight_Revenue,Freight_Expense,Primary_Broker_Commission,Secondary_Broker_Commission,Buy_Group_Commission,Actual_Deduction_Dollars,Deduction_Reason">
		<CFSET DBInvoice_DetailSQL="SELECT #DBInvoice_DetailFields# FROM Invoice_Detail WHERE Order_Number='--id--' and Invoice_Version='--id1--' and Item='--id2--'">
		<CFSET Original_DB_ID_Invoice_Detail="Invoice_Detail_ID">
		<CFSET Original_DB_Weekly_Log_Fields_Invoice_Detail="Order_Number,Invoice_version,Item">
		
		
		<CFSET LogLabelFields="label,label_name,created_date">
		<CFSET DBLabelFields="brand,brand_name,created_date">
		<CFSET DBLabelSQL="SELECT #DBLabelFields# FROM Brand WHERE brand='--id--'">
		<CFSET Original_DB_ID_Label="Brand_ID">
		<CFSET Original_DB_Weekly_Log_Fields_Label="brand,brand_name">
		
		
		<CFSET LogType_GroupFields="type_group,type_group_name,created_date">
		<CFSET DBType_GroupFields="type_group_legacy,type_group_desc,created_date">
		<CFSET DBType_GroupSQL="SELECT #DBType_GroupFields# FROM Type_Group_Desc WHERE type_group_legacy='--id--'">
		<CFSET Original_DB_ID_Type_Group="Type_Group_ID">
		<CFSET Original_DB_Weekly_Log_Fields_Type_Group="type_group_legacy,type_group_desc">
		
		
		<CFSET LogTypeFields="type,type_name,created_date">
		<CFSET DBTypeFields="type_code_desc,type_code_legacy,created_date">
		<CFSET DBTypeSQL="SELECT #DBTypeFields# FROM Type_Code_Desc WHERE type_code_desc='--id--'">
		<CFSET Original_DB_ID_Type="Type_Code_ID">
		<CFSET Original_DB_Weekly_Log_Fields_Type="type_code_desc,type_code_legacy">
		
		
		<CFSET LogQBrandFields="q_brand,q_brand_name,created_date">
		<CFSET DBQBrandFields="q_brand_legacy,q_brand,created_date">
		<CFSET DBQBrandSQL="SELECT #DBQBrandFields# FROM Q_Brand_Desc WHERE q_brand_legacy='--id--'">
		<CFSET Original_DB_ID_QBrand="Q_Brand_ID">
		<CFSET Original_DB_Weekly_Log_Fields_QBrand="q_brand_legacy,q_brand">
		
		
		<!------<CFSET LogQ_Brand_DescFields="item,lob,category_lob,category_no,category_desc,prod_category,disp_sequence,created_date">
		<CFSET DBQ_Brand_DescFields="item,lob,category_lob,category_no,category_desc,prod_category,disp_sequence,created_date">
		<CFSET DBQ_Brand_DescSQL="SELECT #DBQ_Brand_DescFields# FROM Product_Q_Brand_Desc WHERE LOB='--id1--' and item='--id--'">
		<CFSET Original_DB_ID_Q_Brand_Desc="Q_Brand_Desc">
		<CFSET Original_DB_Weekly_Log_Fields_Q_Brand_Desc="item,lob">----->
		
		
		<CFSET LogItemFields="item,active_code,description,style,style_name,sales_group,sales_country,created_date,prime_lob,type,type_name,type_group,type_group_name,label_name,Category,Category_Name,item_class">
		<CFSET DBItemFields="cfi.item,cfi.active_code,cfi.description,cfi.style,cfi.style_name,cfi.sales_group,cfi.sales_country,cfi.created_date,lob.Line_Of_Business,tc.type_code_legacy,tc.type_code_desc,tg.type_group_legacy,tg.type_group_desc,b.brand_name,c.Category,c.Category_Name,cfi.item_class">
		<CFSET DBItemSQL="SELECT #DBItemFields# FROM BSA_Foodservice_Items_Master cfi, Line_Of_Business lob,Type_Code_Desc tc,Type_Group_Desc tg,Brand b,Category c WHERE item='--id--' and lob.Line_Of_Business_ID=cfi.Line_Of_Business_ID and tc.Type_Code_Desc_ID=cfi.Type_Code_Desc_ID and tg.Type_Group_Desc_ID=cfi.Type_Group_Desc_ID and b.Brand_ID=cfi.Brand_ID and c.Category_ID=cfi.Category_ID">
		<CFSET Original_DB_ID_Item="BSA_Foodservice_Items_Master_ID">
		<CFSET Original_DB_Weekly_Log_Fields_Item="item,description,upc">
		

		<CFSET LogPrice_List_DetailFields="Price_List_ID">
		<CFSET DBPrice_List_DetailFields="Price_List_ID">
		<CFSET DBPrice_List_DetailSQL="SELECT #DBPrice_List_DetailFields# FROM Price_List_Detail WHERE Price_List_ID='--id--' and Item_Number='--id2--'">
		<CFSET Original_DB_ID_Price_List_Detail="Price_List_Detail_ID">
		<CFSET Original_DB_Weekly_Log_Fields_Price_List_Detail="Price_List_ID,Item_Number,Start_Date,End_Date">
		
		<CFSET LogPrice_List_Detail_SpecialFields="Ship_To,Item_Number">
		<CFSET DBPrice_List_Detail_SpecialFields="Ship_To,Item_Number">
		<CFSET DBPrice_List_Detail_SpecialSQL="SELECT #DBPrice_List_Detail_SpecialFields# FROM Price_List_Detail_Special WHERE Ship_To='--id--' and Item_Number='--id2--'">
		<CFSET Original_DB_ID_Price_List_Detail_Special="Price_List_Detail_Special_ID">
		<CFSET Original_DB_Weekly_Log_Fields_Price_List_Detail_Special="Ship_To,Item_Number">
		
		
		<CFSET LogPrice_List_HeaderFields="Price_List_ID">
		<CFSET DBPrice_List_HeaderFields="Price_List_ID">
		<CFSET DBPrice_List_HeaderSQL="SELECT #DBPrice_List_HeaderFields# FROM Price_List_Header WHERE Price_List_ID='--id--'">
		<CFSET Original_DB_ID_Price_List_Header="Price_List_Header_ID">
		<CFSET Original_DB_Weekly_Log_Fields_Price_List_Header="Price_List_ID">
		
		
		<CFSET LogPrice_List_Header_SpecialFields="Ship_To,Description">
		<CFSET DBPrice_List_Header_SpecialFields="Ship_To,Description">
		<CFSET DBPrice_List_Header_SpecialSQL="SELECT #DBPrice_List_Header_SpecialFields# FROM Price_List_Header_Special WHERE Ship_To='--id--'">
		<CFSET Original_DB_ID_Price_List_Header_Special="Price_List_Header_Special_ID">
		<CFSET Original_DB_Weekly_Log_Fields_Price_List_Header_Special="Ship_To,Description">
		
		<CFSET Weekly_log_Max_Count = 5>
		
		<CFSET Weekly_Log_Exclude_list = "Invoice_Header,Invoice_Detail">		
	</CFCASE>
</CFSWITCH>












<!----<CFSET lookForFields="name,desc">--->
<CFSET lookForFields="">

<CFSCRIPT>

/*
logTables="";
logItems="";
originalDB="";
originalDBIDFIelds="";

addLogItemEntry("Log_CF_Zone","Zone","Service_Zones","zone_number");
addLogItemEntry("Log_CF_Region","Region","Service_Regions","region_number");
addLogItemEntry("Log_CF_LOB","LOB","Line_Of_Business","line_of_business");
addLogItemEntry("Log_CF_Broker","Broker","BSA_Foodservice_Brokers","region_shard");
addLogItemEntry("Log_CF_Buying_Group","Buying_Group","Distributor_Buying_Groups","buying_group");
addLogItemEntry("Log_CF_Custid","Custid","Distributor_Customer_ID","custid");
addLogItemEntry("Log_CF_Family","Family","Distributor_Family","family");
addLogItemEntry("Log_CF_BillTo","BillTo","Distributor_Bill_To","shr_bill_to");
addLogItemEntry("Log_CF_ShipTo","ShipTo","BSA_Foodservice_Customers","ship_to");
addLogItemEntry("Log_CF_Label","Label","Brand","brand");
addLogItemEntry("Log_CF_Type_Group","Type_Group","Type_Group_Desc","type_group_desc");
addLogItemEntry("Log_CF_Type","Type","Type_Code_Desc","type_code_desc");
addLogItemEntry("Log_CF_QBrand","QBrand","Q_Brand_Desc","q_brand");
addLogItemEntry("Log_CF_Q_Brand_Desc","Q_Brand_Desc","Product_Q_Brand_Desc","item");
addLogItemEntry("Log_CF_Item","Item","BSA_Foodservice_Items_Master","item");
*/

function addLogItemEntry(alogTables,alogItems,aoriginalDB,aoriginalDBIDFIelds)
{
	logTables = ListAppend(logTables,alogTables,",");
	logItems = ListAppend(logItems,alogItems,",");
	originalDB = ListAppend(originalDB,aoriginalDB,",");
	originalDBIDFIelds = ListAppend(originalDBIDFIelds,aoriginalDBIDFIelds,",");
}
</CFSCRIPT>

<!------------------------
JavaScript code for showing the Error Messages using client side pop up
---------------------------->
<SCRIPT LANGUAGE="JavaScript">
var arrErrors = new Array();
var arrSpans = new Array();
function addError(sErr,sSpan)
{
	var arLen = arrErrors.length;
	arrErrors[arLen] = sErr; 
	arrSpans[arLen] = sSpan;
}

function showError()
{
	var arLen = arrErrors.length;
	if(arLen > 0)
	{
		for(i=0;i<arLen;i++)
		{
			queueMessage(arrErrors[i], eval("document.all." + arrSpans[i]));
		}
		showMessageWindow();
	}
}

</SCRIPT>
<!------------------------
End JavaScript code for showing the Error Messages using client side pop up
---------------------------->
<CFSCRIPT>
function writeToErrorMessage(strError,spName)
{
	WriteOutput("<script language=""JavaScript"">");
	WriteOutput("addError('#strError#','#spName#')");
	WriteOutput("</script>");
}
</CFSCRIPT>