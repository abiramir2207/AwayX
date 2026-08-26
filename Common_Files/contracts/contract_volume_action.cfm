<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Contract - Volume</title>
</head>

<body>

<CFSET Program_Volume = CreateObject("component", "components.programs.volume.ContractVolume")>

<CFPARAM NAME="Form.Program_ID" 	DEFAULT="">
<CFPARAM NAME="URL.Program_ID" 		DEFAULT="#Form.Program_ID#">
<CFPARAM NAME="FORM.Product_List" 	DEFAULT="">
<CFIF Form.Program_ID NEQ "" AND IsNumeric(Form.Program_ID)>
	<CFSET D_Temp = Program_Volume.Load_Basic_Information(Form.Program_ID)>
	<CFSET Total_Volume = Program_Volume.save_product_volume(FORM.Product_List)>
	<CFPARAM NAME="FORM.Save_Program_Volume" 	DEFAULT="0">
	<CFIF FORM.Save_Program_Volume EQ "1">
		<CFSET D_Temp = Program_Volume.save_program_volume(Total_Volume)>
	</CFIF>
</CFIF>

<CFPARAM NAME="URL.context" 	DEFAULT="">
<CF_Cryp type="en" key="#request.key#" string ="#Form.Program_ID#">
<CFSET CID = cryp.value>

<CFPARAM NAME="URL.context" 	DEFAULT="">
<CFIF URL.context EQ "profit_analysis">
	<CFSET Goto_URL = "contract_profit_analysis.cfm?CID=#CID#&FID=#Program_Volume.FID#">
<CFELSE>
	<CFSET Goto_URL = "Contract_Volume.cfm?#Program_Volume.pass_url#">
</CFIF>
<CFLOCATION ADDTOKEN="No" URL="#Goto_URL#">
</body>
</html>
