


<cfoutput>
	<cfif URL.Type neq 1>
		<CFQUERY NAME="Guid_List" DATASOURCE="#Application.Datasource#">
			SELECT 		Price_List_Header_Special_ID,
						<cfif application.returned_customer_setting.Customer_Keyword EQ "Resers">
						Description
						<cfelseif application.returned_customer_setting.Customer_Keyword EQ "conagra">
						Price_List_Description
						<cfelse>''</cfif> AS Price_List_Description
						 
			FROM 		Price_List_Header_Special 
			WHERE 		<cfif application.returned_customer_setting.Customer_Keyword EQ "Resers">
						Ship_To = '#URL.PL_ID#'
						<cfelseif application.returned_customer_setting.Customer_Keyword EQ "conagra">
						Price_List_ID ='#URL.PL_ID#'	
						<cfelse>		
						Price_List_ID ='#URL.PL_ID#'		
						</cfif>					
		</CFQUERY>
		<CFSET ListOfGuid = VALUELIST(Guid_List.Price_List_Header_Special_ID)>
		<CFSET ListOfGuid = LISTQUALIFY(ListOfGuid,"'",",","All")> 
	</cfif>
<cfquery name="get_all_details" datasource="#Application.Datasource#">
SELECT  DISTINCT <cfif URL.Type eq 1>
		<!--- 
		Price_List_Detail.Start_Date 					Start_Date,
		Price_List_Detail.End_Date 						End_Date, 
		--->
		<!--- 
		Price_List_Detail.LB_FOB_Price 					LB_FOB_Price,
		Price_List_Detail.CS_FOB_Price 					CS_FOB_Price, 
		--->
		<cfelse>
		<!--- 
		Price_List_Detail_special.Start_Date 			Start_Date,
		Price_List_Detail_special.End_Date 				End_Date, 
		--->
		<!--- 
		Price_List_Detail_special.LB_FOB_Price 			LB_FOB_Price,
		Price_List_Detail_special.CS_FOB_Price 			CS_FOB_Price, 
		--->
		</cfif>
		<cfif application.returned_customer_setting.approval_criteria_table EQ "Type_code_Desc">
		Type_Code_Desc.Type_Code_Desc 					group_by,
		<cfelseif application.returned_customer_setting.approval_criteria_table EQ "Type_Group_Desc">
		Type_Group_Desc.Type_Group_Desc 				group_by,
		</cfif>
		BSA_Foodservice_Items_Master.Item 			Item,
		BSA_Foodservice_Items_Master.UPC 			UPC,
		BSA_Foodservice_Items_Master.Description 	Description,
		Brand.Brand_Name 								Brand_Name,
		BSA_Foodservice_Items_Master.Net_Weight 	Net_Weight,
		BSA_Foodservice_Items_Master.Gross_Weight 	Gross_Weight			
	
FROM 		<cfif URL.Type eq 1>Price_List_Detail<cfelse>Price_List_Detail_special</cfif> 
<cfif URL.Type eq 1>
INNER JOIN	BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID= Price_List_Detail.Product_ID
<cfelse>
INNER JOIN	BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID= Price_List_Detail_special.Product_ID
</cfif>
INNER JOIN 	Brand ON Brand.Brand_ID=BSA_Foodservice_Items_Master.Brand_ID
INNER JOIN	Type_Code_Desc ON Type_Code_Desc.Type_Code_Desc_ID=BSA_Foodservice_Items_Master.Type_Code_Desc_ID
INNER JOIN	Type_Group_Desc ON Type_Group_Desc.Type_Group_Desc_ID = BSA_Foodservice_Items_Master.Type_Group_Desc_ID

WHERE 		<cfif URL.Type eq 1>
			Price_List_ID = '#URL.PL_ID#' AND Price_List_Detail.Active_Code = 'A'
			<cfelse>
			Price_List_Header_Special_ID IN (#PRESERVESINGLEQUOTES(ListOfGuid)#) AND Price_List_Detail_special.Active_Code = 'A'
			</cfif> AND 
			CONVERT(Char(10),Start_Date,101) <= CONVERT(Char(10),getdate(),101) AND 
			End_Date >= CONVERT(Char(10),getdate(),101)
			
ORDER BY 	<cfif application.returned_customer_setting.approval_criteria_table EQ "Type_code_Desc">		
				Type_Code_Desc.Type_Code_Desc, 
			<cfelseif application.returned_customer_setting.approval_criteria_table EQ "Type_Group_Desc">
				Type_Group_Desc.Type_Group_Desc,
			</cfif>
			#URL.SORT_BY# #URL.SORT_ORDER#
</cfquery>
</cfoutput>


<cfif URL.Type eq 1>
	<cfquery name="get_desc" datasource="#Application.datasource#">
		SELECT 		Price_List_Description Descp
						
		FROM 		Price_List_Header
		
		WHERE 		Price_List_ID=<CFOUTPUT>'#URL.PL_ID#'</CFOUTPUT>
	</cfquery>
<cfelse>
	<cfquery name="get_desc" datasource="#Application.datasource#">
		SELECT 		Description Descp,
					<cfif application.returned_customer_setting.Customer_Keyword EQ "Resers">
					Ship_To Price_List_ID
					<cfelseif application.returned_customer_setting.Customer_Keyword EQ "conagra">
					Price_List_ID
					<cfelse>		
					Price_List_ID	
					</cfif>
					
		FROM 		Price_List_Header_Special
		
		WHERE 		Price_List_Header_Special_ID IN <CFOUTPUT>(#PRESERVESINGLEQUOTES(ListOfGuid)#)</CFOUTPUT>
	</cfquery>
</cfif>
<cfsavecontent variable="savethis_todispaly">
<STYLE>
<CFINCLUDE TEMPLATE="/Common_Files/Main_Style.css">
TABLE.BORDERTHIS TD
{
border-bottom:solid #93BEE2 1px; 
}
</STYLE>
<cfoutput>
<cfif isdefined("URL.nottodispaly")>
	<cfif isdefined("print")>
	
	<table border="0" width="95%" align="center" cellpadding="0" cellspacing="0">
		<tr>
			<td style="font-size: 14px; ">&nbsp;&nbsp;&nbsp;<b><CFIF URL.Type eq 1><u>#Get_Desc.Descp#</u> [ #URL.PL_ID# ]<CFELSE><u>#Guid_List.Price_List_Description#</u>&nbsp;&nbsp; [ #get_desc.Price_List_ID# ]</CFIF></b></td>
			<td width="100" align="right"><img src="#application.returned_customer_setting.company_Logo#" alt="" width="100" height="77" border="0"></td>
		</tr>
	</table>	
	<cfelse>
	<table border="0" width="95%" align="center" cellpadding="0" cellspacing="0">
		<tr>
			<td style="font-size: 14px; ">&nbsp;&nbsp;&nbsp;<b><CFIF URL.Type eq 1><u>#Get_Desc.Descp#</u> [ #URL.PL_ID# ]<CFELSE><u>#Guid_List.Price_List_Description#</u>&nbsp;&nbsp; [ #get_desc.Price_List_ID# ]</CFIF></b></td>
			<td align="right"><font color="red" size="4"><b>#application.returned_customer_setting.company_Name#&nbsp;&nbsp;</b></font></td>
		</tr>
	</table>
	</cfif>
<br><br>
<cfelse>

<table border="0" width="95%" align="center" bgcolor="black" cellpadding="0" cellspacing="0">
	<tr>
		<td style="color: white;font-size: 14px; ">&nbsp;&nbsp;&nbsp;<b><CFIF URL.Type eq 1><u>#Get_Desc.Descp#</u> [ #URL.PL_ID# ]<CFELSE><u>#Guid_List.Price_List_Description#</u>&nbsp;&nbsp; [ #get_desc.Price_List_ID# ]</CFIF></b> </td>
		<td width="100" align="right"><img src="#application.returned_customer_setting.company_Logo#" alt="" width="100" height="77" border="0"></td>
	</tr>
</table>


<br><br>
</cfif>
</cfoutput>


<table border="0" width="95%" align="center" cellpadding="5" cellspacing="0" class="BORDERTHIS">
	<tr BGCOLOR="ffce84">
		<td style="Border-bottom:none;">&nbsp;</td>
		<td style="Border-bottom:none;">&nbsp;</td>
		<td style="Border-bottom:none;">&nbsp;</td>
		<td style="Border-bottom:none;" colspan="2"><b>&nbsp;&nbsp;<u>CASE WEIGHT</u></b></td>
		<td style="Border-bottom:none;" colspan="2"><b>&nbsp;&nbsp;&nbsp;<u>FOB PRICE in $</u></b></td>
		<td style="Border-bottom:none;">&nbsp;</td>
	</tr>
	<tr BGCOLOR="ffce84">
		<td valign="Top"><b><cfoutput>#application.returned_customer_setting.item_label#</cfoutput> #</b></td>
		<td valign="Top"><b><cfoutput>#application.returned_customer_setting.upc_label#</cfoutput> #</b></td>
		<td valign="Top"><b>DESCRIPTION</b><BR><b>BRAND</b></td>
		<td valign="Top"><b>NET</b></td>
		<td valign="Top"><b>GROSS&nbsp;&nbsp;</b></td>
		<td valign="Top"><b>&nbsp;&nbsp;POUND</b></td>
		<td valign="Top"><b>CASE</b></td>
		<td valign="Top"><b>START<BR>END</b></td>
	</tr>
	<cfoutput 	query="get_all_details" startRow="1" maxRows="1">		
		<cfset group_by_col =group_by> 									
	</cfoutput>
	<tr>
		<td colspan="100%" bgcolor="#C0C0C0" <cfif isdefined("print") or isdefined("Fax")>style="border-bottom:none"</cfif>><cfoutput><b>#group_by_col#</b></cfoutput></td>
	</tr>
	<cfoutput query="get_all_details">	
	<cfif group_by neq group_by_col>
		<tr>
			<td colspan="100%" bgcolor="C0C0C0" <cfif isdefined("print") or isdefined("Fax")>style="border-bottom:none"</cfif>><b>#group_by#</b></td>
		</tr>
		<cfset group_by_col =group_by>
	</cfif>	
	<tr bgcolor="#iif(CurrentRow Mod 2, de('ffffff'), de('C6FFC6'))#">
		<td valign="Top" <cfif isdefined("print") or isdefined("Fax")>style="border-bottom:none"</cfif>>#Item#</td>
		<td valign="Top" <cfif isdefined("print") or isdefined("Fax")>style="border-bottom:none"</cfif>>#UPC#</td>
		<td valign="Top" <cfif isdefined("print") or isdefined("Fax")>style="border-bottom:none"</cfif>>#Description#<BR><b>Brand: </b>#Brand_Name#</td>
		<td valign="Top" <cfif isdefined("print") or isdefined("Fax")>style="border-bottom:none"</cfif>>#NumberFormat(Net_Weight,"_.____")#</td>
		<td valign="Top" <cfif isdefined("print") or isdefined("Fax")>style="border-bottom:none"</cfif>>#NumberFormat(Gross_Weight,"_.____")#&nbsp;&nbsp;</td>
<cfquery name="get_St_Ed_Date" datasource="#Application.Datasource#">
	SELECT  <cfif URL.Type eq 1>	
			Price_List_Detail.LB_FOB_Price 					LB_FOB_Price,
			Price_List_Detail.CS_FOB_Price 					CS_FOB_Price,				
			CONVERT(char(10),Price_List_Detail.Start_Date,101)					Start_Date,
			CONVERT(char(10),Price_List_Detail.End_Date,101)						End_Date 
			<cfelse>
			Price_List_Detail_special.LB_FOB_Price 			LB_FOB_Price,
			Price_List_Detail_special.CS_FOB_Price 			CS_FOB_Price,
			CONVERT(char(10),Price_List_Detail_special.Start_Date,101)			Start_Date,
			CONVERT(char(10),Price_List_Detail_special.End_Date,101)				End_Date 
			</cfif>
		
	FROM 		<cfif URL.Type eq 1>Price_List_Detail<cfelse>Price_List_Detail_special</cfif> 
	
	<cfif URL.Type eq 1>
	INNER JOIN	BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID= Price_List_Detail.Product_ID
	<cfelse>
	INNER JOIN	BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID= Price_List_Detail_special.Product_ID
	</cfif>
	
	WHERE 		<cfif URL.Type eq 1>
				Price_List_ID = '#URL.PL_ID#' AND Price_List_Detail.Active_Code = 'A'
				<cfelse>
				Price_List_Header_Special_ID IN (#PRESERVESINGLEQUOTES(ListOfGuid)#) AND Price_List_Detail_special.Active_Code = 'A'
				</cfif> AND 
				CONVERT(Char(10),Start_Date,101) <= CONVERT(Char(10),getdate(),101) AND 
				End_Date >= CONVERT(Char(10),getdate(),101) AND BSA_Foodservice_Items_Master.Item = '#Item#'
	ORDER BY <cfif URL.Type eq 1>				
				Price_List_Detail.Start_Date
			<cfelse>
				Price_List_Detail_special.Start_Date DESC
			</cfif>
</cfquery>		
		<td valign="Top" <cfif isdefined("print") or isdefined("Fax")>style="border-bottom:none"</cfif>>&nbsp;&nbsp;$ #numberformat(get_St_Ed_Date.LB_FOB_Price,"_.____")#</td>
		<td valign="Top" <cfif isdefined("print") or isdefined("Fax")>style="border-bottom:none"</cfif>>$ #numberformat(get_St_Ed_Date.CS_FOB_Price,"_.___")#</td>
		<td valign="Top" <cfif isdefined("print") or isdefined("Fax")>style="border-bottom:none"</cfif> width="55">#DateFormat(get_St_Ed_Date.Start_Date,"mm/dd/yyyy")#<BR>#DateFormat(get_St_Ed_Date.End_Date,"mm/dd/yyyy")#</td>
	</tr>
	</cfoutput>
</table>
</cfsavecontent>

