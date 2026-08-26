<cfset CustTypeManager = CreateObject("component", "components.programs.business_segment.customertypemanager") />

<cfset savecustomertype = CustTypeManager.save(form.customer_type_id,form.Customer_Type_Desc) />

<CFlocation url="customer_type_list.cfm">