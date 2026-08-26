
<!--- --->

<!--- <SCRIPT LANGUAGE="JavaScript">
function Page_Specific_Before_Find_Code()
{
}
</SCRIPT>
<CFINCLUDE TEMPLATE="/Billbacks/Common/Find_In_Page.cfm"> --->
<CFSET CustomerQueryType = 2>
<CFIF application.returned_customer_setting.Customer_Keyword EQ "Resers">
	<CFSET CustomerQueryType = 1>
</CFIF>

<CFPARAM NAME="FORM.SORT_BY" 	DEFAULT="">
<CFPARAM NAME="FORM.SORT_ORDER" 	DEFAULT="ASC">
<cfoutput>

	<CFSWITCH EXPRESSION="#FORM.SORT_BY#">
		<CFCASE VALUE="Item,UPC,Description,Brand_Name,Net_Weight,Gross_Weight,LB_FOB_Price,CS_FOB_Price,Start_Date,End_Date" DELIMITERS=",">
			<CFSET FORM.SORT_BY = FORM.SORT_BY>
		</CFCASE>
		<CFDEFAULTCASE>
			<CFSET FORM.SORT_BY = "Description">
		</CFDEFAULTCASE>
	</CFSWITCH>
	
	<CFIF FORM.SORT_ORDER NEQ "DESC">
		<CFSET FORM.SORT_ORDER = "ASC">
	</CFIF>
	<cfif URL.Type neq 1>
		<CFQUERY NAME="Guid_List" DATASOURCE="#Application.Datasource#">
			SELECT 		Price_List_Header_Special_ID,
						<cfif CustomerQueryType EQ 1>
						Description
						<cfelseif CustomerQueryType EQ 2>
						Price_List_Description
						<cfelse>''</cfif> AS Price_List_Description
						 
			FROM 		Price_List_Header_Special
			 
			WHERE 		<cfif CustomerQueryType EQ 1>
						Ship_To = '#URL.PL_ID#'
						<cfelseif CustomerQueryType EQ 2>
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

#FORM.SORT_BY# #FORM.SORT_ORDER# 
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
					<cfif CustomerQueryType EQ 1>
					Ship_To Price_List_ID
					<cfelseif CustomerQueryType EQ 2>
					Price_List_ID
					<cfelse>		
					Price_List_ID	
					</cfif>
					
					
		FROM 		Price_List_Header_Special
		
		WHERE 		Price_List_Header_Special_ID IN <CFOUTPUT>(#PRESERVESINGLEQUOTES(ListOfGuid)#)</CFOUTPUT>
	</cfquery>
</cfif>



<cfsavecontent variable="savethis_todispaly">

<cfoutput>


<BR>

<table border="0" width="100%" align="center" cellpadding="0" cellspacing="0" HEIGHT="90" background="/Images/White_Height.gif">
	<tr height="40">
		<td VALIGN="top" height="40"></td>
		<td width="120" rowspan="2" align="center" valign="bottom" style="background-position-x:40px;background-repeat:repeat-x;"><img src="#application.returned_customer_setting.company_Logo#" title="Company" border="0">
		</td>
		<!--- <td width="10"></td> --->
	</tr>
	<tr>
		<td heigth="100%" style="color: white;font-size: 14px;">&nbsp;&nbsp;&nbsp;<b><CFIF URL.Type eq 1><u>#Get_Desc.Descp#</u> [ #URL.PL_ID# ]<CFELSE><u>#Guid_List.Price_List_Description#</u>&nbsp;&nbsp; [ #get_desc.Price_List_ID# ]</CFIF></b></td>
		<!--- <td bgcolor="black">&nbsp;</td> --->
	</tr>
</table>
<!--- <table border="0" width="800" align="center" bgcolor="black" cellpadding="0" cellspacing="0">
	<tr>
		<td style="color: white;font-size: 14px; ">&nbsp;&nbsp;&nbsp;<b><u>#Get_Desc.Descp#</u> [ #URL.PL_ID# ]</b> </td>
		<td width="100" align="right"><img src="#application.returned_customer_setting.company_Logo#" alt="" width="100" height="77" border="0"></td>
	</tr>
</table> --->


<br><br>
<!--- </cfif> --->
</cfoutput>

<cfquery name="get_St_Ed_Date_All" datasource="#Application.Datasource#">
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
			</cfif>,
			BSA_Foodservice_Items_Master.Item,
			<cfif URL.Type eq 1>				
				Price_List_Detail.Start_Date
			<cfelse>
				Price_List_Detail_special.Start_Date
			</cfif> As Sort_Date
		
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
				</cfif> 
				AND CONVERT(Char(10),Start_Date,101) <= CONVERT(Char(10),getdate(),101) 
				AND End_Date >= CONVERT(Char(10),getdate(),101)
	ORDER BY <cfif URL.Type eq 1>				
				Price_List_Detail.Start_Date
			<cfelse>
				Price_List_Detail_special.Start_Date DESC
			</cfif>
</cfquery>	


<FORM NAME="Sort_Form" ACTION="Price_List_Detail.cfm?<CFOUTPUT>PL_ID=#URL.PL_ID#&type=#URL.Type#</CFOUTPUT>" METHOD="POST">
	<CFOUTPUT>
	<INPUT TYPE="hidden" VALUE = "#FORM.SORT_BY#" NAME="SORT_BY">
	<INPUT TYPE="hidden" VALUE = "#FORM.SORT_ORDER#" NAME="SORT_ORDER">
	</CFOUTPUT>
<table border="0" width="100%" align="center" cellpadding="5" cellspacing="0">
	<tr BGCOLOR="ffce84">
		<td>&nbsp;</td>		
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td colspan="2"><b>&nbsp;&nbsp;<font color="blue"><u>CASE WEIGHT</u></font></b></td>
		<td colspan="2"><b>&nbsp;&nbsp;&nbsp;<u>FOB PRICE in $</u></b></td>
		<td>&nbsp;</td>		
	</tr>
	
<CFSET A_Header_Value_List = "Item,UPC,Description,Brand_Name,Net_Weight,Gross_Weight,LB_FOB_Price,CS_FOB_Price,Start_Date,End_Date">
<CFSET A_Header_Name_List = "#application.returned_customer_setting.item_label#,#application.returned_customer_setting.upc_label#,DESCRIPTION,BRAND,NET,GROSS,POUND,CASE,START,END">
	<tr BGCOLOR="ffce84">
		<!--- <td <!--- width="9%" --->style="border-bottom:solid 93BEE2 1px;"><b>ITEM #</b></td>
		<td <!--- width="11%"  --->style="border-bottom:solid 93BEE2 1px;"><b>UPC #</b></td>
		<td style="border-bottom:solid 93BEE2 1px;"><b>DESCRIPTION</b></td>
		<td style="border-bottom:solid 93BEE2 1px;"><b>BRAND</b></td>
		<td <!--- width="6%" ---> style="border-bottom:solid 93BEE2 1px;"><b>NET</b></td>
		<td <!--- width="6%" ---> style="border-bottom:solid 93BEE2 1px;"><b>GROSS&nbsp;&nbsp;</b></td>
		<td <!--- width="8%" ---> style="border-bottom:solid 93BEE2 1px;"><b>&nbsp;&nbsp;POUND</b></td>
		<td <!--- width="6%" ---> style="border-bottom:solid 93BEE2 1px;"><b>CASE</b></td> --->
		<CFOUTPUT>
		<CFSET Counter = 1>
		<CFLOOP LIST="#A_Header_Value_List#" INDEX="ThisHeaderItem">
			<CFSET thisSortOrder = "ASC">
			<CFSET Image_Name = "/Images/down_1.gif">
			<CFSET ThisHeaderItemName = ListGetAt(A_Header_Name_List, Counter, ",")>
			<CFIF ThisHeaderItem EQ FORM.SORT_BY>
				<CFIF FORM.SORT_ORDER EQ "ASC">
					<CFSET thisSortOrder = "DESC">
					<CFSET Image_Name = "/Images/up_1.gif">
				</CFIF>
			</CFIF>
			
			<CFIF ThisHeaderItemName NEQ "END" AND ThisHeaderItemName NEQ "BRAND">
			<TD ID="header" VALIGN="Top">
			<CFELSE>
			<BR>
			</CFIF>
			<CFIF ThisHeaderItemName NEQ "END" AND ThisHeaderItemName NEQ "Start" AND ThisHeaderItemName NEQ "POUND" AND ThisHeaderItemName NEQ "CASE">
			<A HREF="##" onClick="javaSCript: return sort_by_this_order('#ThisHeaderItem# #thisSortOrder#');"><B>#ThisHeaderItemName#</B></A><CFIF ThisHeaderItem EQ FORM.SORT_BY>&nbsp;<IMG SRC="#Image_Name#" BORDER="0"></CFIF>						
			<CFELSE>
			<B>#ThisHeaderItemName#</B>
			</CFIF>
			<CFIF ThisHeaderItemName NEQ "START" AND ThisHeaderItemName NEQ "DESCRIPTION">
			</TD>					
			</CFIF>
			<CFSET Counter = Counter + 1>
		</CFLOOP>
		</CFOUTPUT>
	</tr>
	
	<cfoutput 	query="get_all_details" startRow="1" maxRows="1">
		<cfset group_by_col =group_by> 		
	</cfoutput>
	
		
	<tr>
		<td colspan="100%" bgcolor="#C0C0C0"><cfoutput><b>#group_by_col#</b></cfoutput></td>
	</tr>	
	<cfoutput query="get_all_details">	
	<cfif group_by neq group_by_col>
		<tr>
			<td colspan="100%" bgcolor="C0C0C0"><b>#group_by#</b></td>
		</tr>
		<cfset group_by_col =group_by>
	</cfif>	
	
	<tr bgcolor="#iif(CurrentRow Mod 2, de('ffffff'), de('C6FFC6'))#">
		<td valign="Top" style="border-bottom:solid 93BEE2 1px;">#Item#</td>
		<td valign="Top" style="border-bottom:solid 93BEE2 1px;">#UPC#</td>
		<td valign="Top" style="border-bottom:solid 93BEE2 1px;">#Description#<br><b>Brand:</b> #Brand_Name#</td>
		<td valign="Top" style="border-bottom:solid 93BEE2 1px;">#NumberFormat(Net_Weight,"_.____")#</td>
		<td valign="Top" style="border-bottom:solid 93BEE2 1px;">#NumberFormat(Gross_Weight,"_.____")#&nbsp;&nbsp;</td>
		<cfquery name="get_St_Ed_Date" dbtype="query">
			SELECT	*
			FROM	get_St_Ed_Date_All
			WHERE 	' ' + Item = ' #LTRIM(RTRIM(Item))#'
			ORDER BY Sort_Date
		</cfquery>
		<td valign="Top" style="border-bottom:solid 93BEE2 1px;">&nbsp;&nbsp;$ #numberformat(get_St_Ed_Date.LB_FOB_Price,"_.____")#</td>		
		<td valign="Top" style="border-bottom:solid 93BEE2 1px;">$ #numberformat(get_St_Ed_Date.CS_FOB_Price,"_.___")#</td>
		<td valign="Top" style="border-bottom:solid 93BEE2 1px;" width="55">#DateFormat(get_St_Ed_Date.Start_Date,"mm/dd/yyyy")#<BR>#DateFormat(get_St_Ed_Date.End_Date,"mm/dd/yyyy")#</td>		
	</tr>
	</cfoutput>
</table>

</FORM>
</cfsavecontent>

<script language="JavaScript">
function sort_by_this_order(fieldName, sOrder)
{
	var oForm = document.Sort_Form;
	oForm.SORT_BY.value = fieldName;
	oForm.SORT_ORDER.value = sOrder;
	oForm.submit();
	return false;
}
</script>







	
