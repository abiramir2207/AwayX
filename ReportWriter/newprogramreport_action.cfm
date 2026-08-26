<CFPARAM NAME="Form.rStatus" DEFAULT="-1">
<CFPARAM NAME="Form.rFamilys" DEFAULT="">
<CFPARAM NAME="Form.rBuyingGroups" DEFAULT="">
<CFPARAM NAME="Form.rDistributors" DEFAULT="">
<CFPARAM NAME="Form.rBrokers" DEFAULT="">
<CFPARAM NAME="Form.rRegions" DEFAULT="">
<CFPARAM NAME="Form.rZones" DEFAULT="">
<CFPARAM NAME="Form.rFilter" DEFAULT="">
<CFPARAM NAME="Form.rFilterItems" DEFAULT="">
<CFPARAM NAME="Form.StartDate" DEFAULT="">
<CFPARAM NAME="Form.EndDate" DEFAULT="">
<CFPARAM NAME="Form.SortBy" DEFAULT="">
<CFPARAM NAME="Form.pBrands" DEFAULT="">
<CFPARAM NAME="Form.pTypeCodes" DEFAULT="">
<CFPARAM NAME="Form.pTypeGroups" DEFAULT="">
<CFPARAM NAME="Form.pQBrands" DEFAULT="">
<CFPARAM NAME="returnval" DEFAULT="">

<cfset OrderByList="">
	<cfif Len(SortBy) GT 0>
		<cfloop index="i" list="#SortBy#" delimiters=",">
			<cfif i NEQ "-1">
			<cfif i is "program">
					<cfset orderby = "dbo.Program_Span_Info.contract_number">
				<cfelseif i is "customer">
					<cfset orderby = "Cust_Des">
			</cfif>		
			<cfif NOT ListFindNoCase(OrderByList,orderby,",")>		
				<cfset OrderByList=ListAppend(OrderByList,orderby,",")>
			</cfif>
			</cfif>
		</cfloop>
	<!--- <cfelse>
		<cfset OrderByList="dbo.Program_Span_Info.contract_number,Cust_Des"> --->
	</cfif>

<cfif Len(Trim(Form.rStatus)) EQ "">
		<CFSET Form.rStatus = "-1">
</cfif>

<CFIF Form.rStatus EQ "-1">
	<CFSET Form.rStatus = "4,5,6,7">
</CFIF>
	
<cfif Len(Trim(Form.rGenericTypes)) EQ "">
		<CFSET Form.rGenericTypes = "-1">
</cfif>

<cfset V = "V_#request.AccessStructure.User_Id#">

<CFSET V1 = #Replace(V, '-',"",'all')#>

<cfset sSelect="dbo.Program_Span_Info.Contract_Main_ID, dbo.Program_Span_Info.Contract_Number, dbo.Invoice_Header.Invoice_Date, CAST(dbo.Invoice_Detail.Pounds_Invoiced AS FLOAT)as Pounds_Invoiced, CAST(dbo.Invoice_Detail.LB_Unit_Price AS FLOAT) as Unit_Price, dbo.Program_Span_Info.Approval_Start_Date, dbo.Program_Span_Info.Approval_End_Date, dbo.Program_Span_Info.Contract_Status_Type_Desc,dbo.Program_Span_Info.Contract_Title, dbo.Program_Span_Info.Generic_Type, dbo.Program_Span_Final.Item_Des, dbo.Program_Span_Final.Cust_Des">

<cfset sWhereClause="(Contract_Status_Type_IDX IN (#Form.rStatus#))">

<cfset OrderByList = "Contract_Status_Type_Desc,Generic_Type,#OrderByList#">
	<cfif #ListContains(OrderByList, "Cust_Des")# IS 0>
		<cfset OrderByList=ListAppend(OrderByList,"Cust_Des",",")>
	</cfif>
	<cfif #ListContains(OrderByList, "dbo.Program_Span_Info.contract_number")# IS 0>
		<cfset OrderByList=ListAppend(OrderByList,"dbo.Program_Span_Info.contract_number",",")>
	</cfif>

<CFIF Form.rGenericTypes NEQ "-1">
	<cfset sWhereClause = "#sWhereClause# AND (Generic_Type_ID IN (#Form.rGenericTypes#))">
</CFIF>
<cfset Find_Customer_Position = #ListContains(OrderByList, "Cust_Des")#>

<cfif rFamilys NEQ "">
<cfif rFamilys NEQ "-1">
	<cfset sWhereClause="#sWhereClause# and	(dbo.Program_Span_Final.family_ID='#FORM.rFamilys#')">	
</cfif>
<cfset sSelect="#sSelect#,dbo.Program_Span_Final.Family_Name">	
<cfif Find_Customer_Position GT 0>
	<cfset OrderByList = #ListInsertAt(OrderByList, #Find_Customer_Position#, "Family_Name")#>
</cfif>
</CFIF>


<cfif rBuyingGroups NEQ "">		
		<cfif rBuyingGroups NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	(dbo.Program_Span_Final.Buying_Id='#FORM.rBuyingGroups#')">			
		</cfif>
		<cfset sSelect="#sSelect#,dbo.Program_Span_Final.Buying_Name">
		<cfif Find_Customer_Position GT 0>
	<cfset OrderByList = #ListInsertAt(OrderByList, #Find_Customer_Position#, "Buying_Name")#>
		</cfif>
</cfif>

<cfif rDistributors NEQ "">		
		<cfif rDistributors NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	dbo.Program_Span_Final.Customer_Id='#FORM.rDistributors#'">			
		</cfif>
</cfif>


<cfif pQBrands NEQ "">
<cfif pQBrands NEQ "-1">
	<cfset sWhereClause="#sWhereClause# and	(dbo.Program_Span_Final.Q_Brand_ID='#FORM.pQBrands#')">	
</cfif>
<cfset sSelect="#sSelect#,dbo.Program_Span_Final.Q_Brand_Desc">	
	<cfset OrderByList = #ListAppend(OrderByList, "Q_Brand_Desc",",")#>
</CFIF>

<cfif pTypeGroups NEQ "">		
		<cfif pTypeGroups NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	(dbo.Program_Span_Final.Type_Group_Desc_ID='#FORM.pTypeGroups#')">			
		</cfif>
		<cfset sSelect="#sSelect#,dbo.Program_Span_Final.Type_Group_Desc">
	<cfset OrderByList = #ListAppend(OrderByList, "Type_Group_Desc",",")#>
</cfif>

<cfif pBrands NEQ "">		
		<cfif pBrands NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	(dbo.Program_Span_Final.Type_Code_Desc_ID='#FORM.pBrands#')">			
		</cfif>
		<cfset sSelect="#sSelect#,dbo.Program_Span_Final.Type_Code_Desc">
	<cfset OrderByList = #ListAppend(OrderByList, "Type_Code_Desc",",")#>
</cfif>

<cfif pTypeCodes NEQ "">		
		<cfif pTypeCodes NEQ "-1">
			<cfset sWhereClause="#sWhereClause# and	(dbo.Program_Span_Final.Brand_ID='#FORM.pTypeCodes#')">			
		</cfif>
		<cfset sSelect="#sSelect#,dbo.Program_Span_Final.Brand_Name">
	<cfset OrderByList = #ListAppend(OrderByList, "Brand_Name",",")#>
</cfif>

<CFQUERY NAME="getReport5" datasource="#application.datasource#">
SELECT DISTINCT 
                      TOP 100 PERCENT #sSelect#
FROM         dbo.Program_Span_Info INNER JOIN
                      dbo.Program_Span_Final ON dbo.Program_Span_Info.Contract_Main_ID = dbo.Program_Span_Final.Contract_Main_ID INNER JOIN
                      dbo.Invoice_Header ON dbo.Invoice_Header.BSA_Foodservice_Customers_ID = dbo.Program_Span_Final.Customer_Id INNER JOIN
                      dbo.Invoice_Detail ON dbo.Invoice_Header.Invoice_Header_ID = dbo.Invoice_Detail.Invoice_Header_ID AND 
                      dbo.Program_Span_Final.Product_Id = dbo.Invoice_Detail.BSA_Foodservice_Items_Master_ID
WHERE     (dbo.Program_Span_Info.Contract_Main_ID IN
                          (SELECT     contract_main_id
                            FROM          dbo.Program_Span_Info
                            WHERE      ((Approval_Start_Date BETWEEN '#Form.StartDate#' AND '#Form.EndDate#') OR
                                                   (Approval_End_Date BETWEEN '#Form.StartDate#' AND '#Form.EndDate#') OR
                                                   (Approval_Start_Date < '#Form.StartDate#') AND (Approval_End_Date > '#Form.EndDate#')))) AND #PreserveSingleQuotes(sWhereClause)# AND (dbo.Invoice_Header.Invoice_Header_ID IN
                          (SELECT     Invoice_Header_ID
                            FROM          dbo.Invoice_Header
                            WHERE      ((dbo.Invoice_Header.Invoice_Date >= '#Form.StartDate#') AND (dbo.Invoice_Header.Invoice_Date <= '#Form.EndDate#'))))
ORDER BY #OrderByList#, dbo.Invoice_Header.Invoice_Date
</cfquery>


<CFOUTPUT><SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
		<br><br><br>
		<center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
		<br><br><br>
		</SPAN>
		<SCRIPT LANGUAGE="JavaScript">
			document.body.onload=new Function ("hideWaitMessage();");
			function hideWaitMessage()
			{
				document.all.PleaseWaitMessage.style.display="none";
			}
</SCRIPT></CFOUTPUT>

<cfset myArray = ArrayNew(1)>

<cfoutput query="getReport5">
	<cfscript>
		myArray[getReport5.currentrow] 		= StructNew();
		myArray[getReport5.currentrow].Contract_Status 	= getReport5.Contract_Status_Type_Desc;
		myArray[getReport5.currentrow].Generic_Type 	= getReport5.Generic_Type;
		myArray[getReport5.currentrow].Contract_Number 	= getReport5.Contract_Number;
		myArray[getReport5.currentrow].contract_title 	= getReport5.contract_title;
		myArray[getReport5.currentrow].cust_des 		= getReport5.cust_des;
	</cfscript>
</cfoutput>

<cfparam name="CS_var" default="">
<cfparam name="GT_var" default="">

<cfloop index="i" from="1" to="#ArrayLen(myArray)#">
<cfoutput>	
<cfif CS_var NEQ "#myArray[i].Contract_Status#">
<cfset CS_var = #myArray[i].Contract_Status#>
<h2>#myArray[i].Contract_Status#</h2>
	<cfloop index="i" from="1" to="#ArrayLen(myArray)#">
		<cfif GT_var NEQ "#myArray[i].Generic_Type#">
			<cfset GT_var = #myArray[i].Generic_Type#>
			<h3>#myArray[i].Generic_Type#</h3>
		</cfif>
	</cfloop>
</cfif>
</cfoutput>
</cfloop>












<!--- <cfset listlen = #ListLen(OrderByList)#>
<cfset groupbylist = Replace(#OrderByList#, "dbo.Program_Span_Info.contract_number", "contract_number", "all")>
<cfset currentpos = 1>
<cfoutput query="getReport5" group="#ListGetAt(groupbylist,1,",")#">
<cfset currentpos = 1>

	<cfif listlen GT currentpos>
	<cfset currentVal = Evaluate(ListGetAt(groupbylist,currentpos,","))>
	</cfif>
	<h2>#currentVal#</h2>
<cfset currentpos = 2>
<cfoutput group="#ListGetAt(groupbylist,currentpos,",")#">
<cfset currentpos = 2>
<cfif listlen GT currentpos>
	<cfset currentVal = Evaluate(ListGetAt(groupbylist,currentpos,","))>
</cfif>
<h3>#currentVal#</h3>

 <cfset currentpos = 3>
<cfswitch expression="#ListGetAt(groupbylist,currentpos,",")#">
	<cfcase value="contract_number">
	<cfoutput group="#ListGetAt(groupbylist,currentpos,",")#">
		<cfset currentpos = 3>
		<h4>#contract_title#</h4>
	</cfoutput>
	</cfcase>
	<cfcase value="cust_des">
	<cfoutput group="#ListGetAt(groupbylist,currentpos,",")#">
		<cfset currentpos = 3>
		<h4>#cust_des#</h4>
	</cfoutput>
	</cfcase>
	<cfcase value="buying_name">
	<cfoutput group="#ListGetAt(groupbylist,currentpos,",")#">
		<cfset currentpos = 3>
		<h4>#buying_name#</h4>
	</cfoutput>
	</cfcase>
	<cfcase value="family_name">
	<cfoutput group="#ListGetAt(groupbylist,currentpos,",")#">
		<cfset currentpos = 3>
		<h4>#family_name#</h4>
	</cfoutput>
	</cfcase>
</cfswitch>
<cfset currentpos = 4>
<cfswitch expression="#ListGetAt(groupbylist,currentpos,",")#">
	<cfcase value="contract_number">
	<cfoutput group="#ListGetAt(groupbylist,currentpos,",")#">
		<cfset currentpos = 4>
		<h4>#contract_title#</h4>
	</cfoutput>
	</cfcase>
	<cfcase value="cust_des">
	<cfoutput group="#ListGetAt(groupbylist,currentpos,",")#">
		<cfset currentpos = 4>
		<h4>#cust_des#</h4>
	</cfoutput>
	</cfcase>
</cfswitch>
</cfoutput>
</cfoutput> --->









<!--- <cfset currentpos = 1>

<cfoutput query="getReport5" group="#ListGetAt(groupbylist,currentpos,",")#">
	<h3>#evaluate(ListGetAt(groupbylist,currentpos,","))#</h3>
	
<cfoutput group="#ListGetAt(groupbylist,(currentpos+1),",")#">
	<h3>#evaluate(ListGetAt(groupbylist,(currentpos+1),","))#</h3>
	
<cfif listlen LT 5>
<cfoutput group="#ListGetAt(groupbylist,(currentpos+2),",")#">
	<h4>#evaluate(ListGetAt(groupbylist,(currentpos+2),","))#</h4>
<cfoutput group="#ListGetAt(groupbylist,(currentpos+3),",")#">
	<h4>#evaluate(ListGetAt(groupbylist,(currentpos+3),","))#</h4>
	     <cfoutput><TABLE border="1">
			<TR>
				<TD nowrap>
					#Item_Des#
				</TD>
				<TD nowrap>
					#Pounds_Invoiced# lbs
				</TD>
				<TD nowrap>
				<CFSET amount = (#Pounds_Invoiced# * #Unit_Price#)>
					#amount#
				</TD>
				<TD nowrap>
					#Invoice_Date#
				</TD>
			</TR>
		</TABLE>
     </cfoutput>
</cfoutput>
</cfoutput>
</cfif>
<cfif listlen GTE 5>
<cfoutput group="#ListGetAt(groupbylist,(currentpos+2),",")#">
	<h3>#evaluate(ListGetAt(groupbylist,(currentpos+2),","))#</h3>
<cfoutput group="#ListGetAt(groupbylist,(currentpos+3),",")#">
	<h4>#evaluate(ListGetAt(groupbylist,(currentpos+3),","))#</h4>
<cfoutput group="#ListGetAt(groupbylist,(currentpos+4),",")#">
	<h4>#evaluate(ListGetAt(groupbylist,(currentpos+4),","))#</h4>
     <cfoutput>
	<TABLE border="1">
			<TR>
				<TD nowrap>
					#Item_Des#
				</TD>
				<TD nowrap>
					#Pounds_Invoiced# lbs
				</TD>
				<TD nowrap>
				<CFSET amount = (#Pounds_Invoiced# * #Unit_Price#)>
					#amount#
				</TD>
				<TD nowrap>
					#Invoice_Date#
				</TD>
			</TR>
		</TABLE>
     </cfoutput>
</cfoutput>
</cfoutput>
</cfoutput>
</cfif>
	  	
</cfoutput>
</cfoutput>
 --->

<cfflush>

