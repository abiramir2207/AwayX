<!------DI_CUST_SETTING_NAME.CFM----->
<CFPARAM NAME="Attributes.DI_keyword" 	DEFAULT="">
<CFPARAM NAME="Attributes.ReturnField" 	DEFAULT="Return_Keyword">
<CFSET Return_Keyword="">
<CFSET DI_keyword = Attributes.DI_keyword>

<CFSWITCH EXPRESSION="#DI_keyword#">
	<CFCASE VALUE="Broker">
		<CFSET Return_Keyword="#application.returned_customer_setting.broker_label_singular#">
	</CFCASE>
	<CFCASE VALUE="LOB">
		<CFSET Return_Keyword="#application.returned_customer_setting.lob_label_singular#">
	</CFCASE>
	<CFCASE VALUE="Zone">
		<CFSET Return_Keyword="#application.returned_customer_setting.zone_label_singular#">
	</CFCASE>
	<CFCASE VALUE="Region">
		<CFSET Return_Keyword="#application.returned_customer_setting.region_label_singular#">
	</CFCASE>
	<CFCASE VALUE="Market">
		<CFSET Return_Keyword="#application.returned_customer_setting.market_label_singular#">
	</CFCASE>	
	<CFCASE VALUE="Buying_Group">
		<CFSET Return_Keyword="#application.returned_customer_setting.buying_group_label_singular#">
	</CFCASE>
	<CFCASE VALUE="Custid">
		<CFSET Return_Keyword=DI_keyword>
	</CFCASE>
	<CFCASE VALUE="Family">
		<CFSET Return_Keyword="#application.returned_customer_setting.family_name_label_singular#">
	</CFCASE>
	<CFCASE VALUE="BillTo">
		<CFSET Return_Keyword=DI_keyword>
	</CFCASE>
	<CFCASE VALUE="ShipTo">
		<CFSET Return_Keyword="#application.returned_customer_setting.distributor_label_singular#">
	</CFCASE>
	<CFCASE VALUE="Invoice_Header">
		<CFSET Return_Keyword="Invoice Header">
	</CFCASE>
	<CFCASE VALUE="Invoice_Detail">
		<CFSET Return_Keyword="Invoice Detail">
	</CFCASE>
	<CFCASE VALUE="Label">
		<CFSET Return_Keyword=DI_keyword>
	</CFCASE>
	<CFCASE VALUE="Type_Group">
		<CFSET Return_Keyword="#application.returned_customer_setting.type_group_label_singular#">
	</CFCASE>
	<CFCASE VALUE="Type">
		<CFSET Return_Keyword="#application.returned_customer_setting.type_code_label_singular#">
	</CFCASE>
	<CFCASE VALUE="QBrand">
		<CFSET Return_Keyword="#application.returned_customer_setting.q_brand_label_singular#">
	</CFCASE>
	<CFCASE VALUE="Q_Brand_Desc">
		<CFSET Return_Keyword="QBrand Desc">
	</CFCASE>
	<CFCASE VALUE="Item">
		<CFSET Return_Keyword=DI_keyword>
	</CFCASE>
	<CFCASE VALUE="Price_List_Detail">
		<CFSET Return_Keyword="Price List Detail">
	</CFCASE>
	<CFCASE VALUE="Price_List_Detail_Special">
		<CFSET Return_Keyword="Price List Detail Special">
	</CFCASE>
	<CFCASE VALUE="Price_List_Header">
		<CFSET Return_Keyword="Price List Header">
	</CFCASE>
	<CFCASE VALUE="Price_List_Header_Special">
		<CFSET Return_Keyword="Price List Header Special">
	</CFCASE>
</CFSWITCH>
<CFSET "Caller.#Attributes.ReturnField#"=Return_Keyword>