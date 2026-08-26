<cfif rReportOutputType EQ "h">
<CFOUTPUT>
<html>
<head><title>#UCase(ReplaceNoCase(reportType,"_"," ","All"))# REPORT</title></head>
<style type="text/css">
.Title2
{
	color: Navy;
	font-size: 14px;
	font-weight: bold;
}
td
{
	font-size: 9px;
}
thead	
{
display: table-header-group;
}

tfoot	
{
display: table-footer-group;
}
</style>
<style type="text/css" media="print">
thead	
{
display: table-header-group;
}

tfoot	
{
display: table-footer-group;
}
TABLE
{
	background-image: none;
}
</style>
<body>
</CFOUTPUT>
</cfif>
<cfif isDefined("srqueryname")>
	<cfset srQuery=Evaluate(srqueryname)>
	<cfif srQuery.recordCount GT 0>		
		<CFSET totalColumns=10>
		<cfif rReportOutputType EQ "h">
		<CFOUTPUT><SPAN CLASS="title2">#UCase(ReplaceNoCase(reportType,"_"," ","All"))# REPORT created on #DateFormat(Now(),"mm/dd/yyyy")# #TimeFormat(Now(),"hh:mm:ss tt")#</SPAN><cfif Len(reportDescription) GT 0><BR><b>(#UCase(reportDescription)#)</b></cfif><BR><font color="red">*(NPL) - No Price List available</font><BR><BR></CFOUTPUT>
		</cfif>
		<cfif srNotCSV>
		<cfoutput><TABLE BORDER="1" CELLPADDING="0" CELLSPACING="0" BGCOLOR="cccccc"><colgroup><col span="2" width="200"></col></colgroup></cfoutput>
		</cfif>
		<cfif srNotCSV><CFOUTPUT><thead><TR ALIGN=CENTER></CFOUTPUT></cfif>
		<cfif reportType EQ "Product_Based_Margin_Analysis">
			<cfif srNotCSV><CFOUTPUT><td>Product</td><td colspan="3">Program</td></CFOUTPUT><cfelse><CFOUTPUT>Product##,Description,Program##,Description</CFOUTPUT></cfif>
		<cfelse>
			<cfif srNotCSV><CFOUTPUT><td>Program</td><td colspan="3">Product</td></CFOUTPUT><cfelse><CFOUTPUT>Program##,Description,Product##,Description</CFOUTPUT></cfif>
		</cfif>
		<cfif srNotCSV><CFOUTPUT><td width="60"> Margin </td></CFOUTPUT><cfelse><CFOUTPUT>,Margin</CFOUTPUT></cfif>
		<cfif reportFormatType NEQ 1>
		<cfif srNotCSV>
			<CFOUTPUT><td>Program Rate Per LB</td><td>Adjusted Cost</td><td>Current Cost</td><td>Cost Adjustments</td><td width="100">#application.returned_customer_setting.Trade_Label# Adjustments</td></CFOUTPUT>
		<cfelse><CFOUTPUT>,Program Rate Per LB,Adjusted Cost,Current Cost,Adjustments,#application.returned_customer_setting.Trade_Label# Adjustments</CFOUTPUT></cfif>
		</cfif>
		<cfif srNotCSV><CFOUTPUT></tr></thead></CFOUTPUT><cfelse><CFOUTPUT>#chr(13)##chr(10)#</CFOUTPUT></cfif>
		


		<cfif reportType EQ "Product_Based_Margin_Analysis">
			<cfset groupOrder="Item,Contract_Number">
		<cfelse>
			<cfset groupOrder="Contract_Number,Item">
		</cfif>
		
		<cfset Item_Dist_Start_Row=1>		
		<cfset mainTitle="">
		<cfset mainTitle1="">
		<cfoutput query="srQuery" group="#ListGetAt(groupOrder,1,",")#"><cfsilent>
			<!-----------------------  Show First Row Item/Program  ------------------------------------>
			</cfsilent><cfif reportType EQ "Product_Based_Margin_Analysis"><cfsilent>
				</cfsilent><cfif srNotCSV><tr bgcolor="ffe4b5"><td colspan="#totalColumns#">[#srQuery.Item#] #srQuery.Description#</td></tr></cfif><cfsilent>
				<cfset mainTitle1="Product [#srQuery.Item#] #Replace(srQuery.Description,"""","&quot;","All")#">				
			</cfsilent><cfelse><cfsilent>
				</cfsilent><cfif srNotCSV><tr bgcolor="ffe4b5"><td colspan="#totalColumns#">[#srQuery.Contract_Number#] #srQuery.Contract_Title# (#srQuery.Contract_Status_Type_Desc#)</td></tr></cfif><cfsilent>
				<cfset mainTitle1="Program [#srQuery.Contract_Number#] #Replace(srQuery.Contract_Title,"""","&quot;","All")#">
			</cfsilent></cfif><cfsilent>
				<!-----------------------  End First Row Item/Program  ------------------------------------>
				<!-----------------------  Show Second Row Program/Item  ------------------------------------>
				</cfsilent><cfoutput group="#ListGetAt(groupOrder,2,",")#"><cfsilent>
				</cfsilent><cfif reportType EQ "Product_Based_Margin_Analysis"><cfsilent>
					</cfsilent><cfif srNotCSV><tr bgcolor="FFC0CB" valign="top"><td width="#totalColumns#">&nbsp;</td><td colspan="5">[#srQuery.Contract_Number#] #srQuery.Contract_Title# (#srQuery.Contract_Status_Type_Desc#)</td><cfelse>#srQuery.Item#,#Replace(ReplaceList(srQuery.Description,"#chr(13)#,#chr(10)#"," , "),","," ","All")#,#srQuery.Contract_Number#,#Replace(ReplaceList(srQuery.Contract_Title,"#chr(13)#,#chr(10)#"," , "),","," ","All")#</cfif><cfsilent>
					<cfset mainTitle="#mainTitle1##chr(10)##chr(13)#Program [#srQuery.Contract_Number#] #Replace(srQuery.Contract_Title,"""","&quot;","All")#">
					</cfsilent><cfelse><cfsilent>
					<cfset mainTitle="#mainTitle1##chr(10)##chr(13)#Product [#srQuery.Item#] #Replace(srQuery.Description,"""","&quot;","All")#">
					</cfsilent><cfif srNotCSV><tr bgcolor="FFC0CB" valign="top"><td width="#totalColumns#">&nbsp;</td><td colspan="5">[#srQuery.Item#] #srQuery.Description#</td><cfelse>#srQuery.Contract_Number#,#Replace(ReplaceList(srQuery.Contract_Title,"#chr(13)#,#chr(10)#"," , "),","," ","All")#,#srQuery.Item#,#Replace(ReplaceList(srQuery.Description,"#chr(13)#,#chr(10)#"," , "),","," ","All")#</cfif><cfsilent>
				</cfsilent></cfif><cfif NOT srNotCSV>,#srQuery.MarginPerLB#</cfif><cfsilent>
				</cfsilent><cfif reportFormatType NEQ 1><cfsilent>
				</cfsilent><!------<cfif srNotCSV><td title="Rate/LB">#numberformat(srQuery.ratePerLB,'$(___,___,___,___,___.___')#</td><cfelse>,#srQuery.ratePerLB#</cfif>-----><cfif NOT srNotCSV>,#srQuery.ratePerLB#</cfif><cfif srNotCSV><td title="Adjusted Cost">&nbsp;#numberformat(srQuery.ACC,'$(___,___,___,___,___.___')#</td><td title="Current Cost">&nbsp;#numberformat(srQuery.ICC,'$(___,___,___,___,___.___')#</td><td title="Cost Adjustments">&nbsp;#numberformat(srQuery.NCA,'$(___,___,___,___,___.___')#</td><td title="#application.returned_customer_setting.Trade_Label# Adjustments">&nbsp;#numberformat(srQuery.TPA,'$(___,___,___,___,___.___')#</td><cfelse>,#srQuery.ACC#,#srQuery.ICC#,#srQuery.NCA#,#srQuery.TPA#</cfif><cfsilent>
				</cfsilent></cfif><cfsilent>
				</cfsilent><cfif srNotCSV></tr><cfelse>#chr(10)#</cfif><cfsilent>
				<!----------------------- Show marign as next row ---------------------------->
				</cfsilent><cfif srNotCSV><cfoutput group="Product_Type_ID">
				<tr bgcolor="ffffff" valign="top"><td width="#totalColumns#">&nbsp;</td><td colspan="3">
				<cfswitch expression="#srQuery.Product_Type_ID#">
				<cfcase value="1">Fixed</cfcase>
				<cfcase value="2">#Application.RebateLabel#</cfcase>
				<cfcase value="4">Growth</cfcase>
				<cfcase value="5">Formula Pricing</cfcase>
				</cfswitch>
				</td><td><cfif srQuery.MarginPerLB NEQ "">&nbsp;#numberformat(srQuery.MarginPerLB,'$(___,___,___,___,___.___')#<cfelse><font color="red">NPL<sup><font size="3">*</font></sup></font></cfif></td>				
				<cfif reportFormatType NEQ 1><td title="Rate/LB">&nbsp;#numberformat(srQuery.ratePerLB,'$(___,___,___,___,___.___')#</td><td colspan="#Evaluate("#totalColumns#-6")#"></td></cfif>
				</tr>
				</cfoutput></cfif><cfsilent>
				
				<!----------------------- End Show marign as next row ---------------------------->
				
				<!-----------------------  End Second Row Program/Item  ------------------------------------>
				<!-----------------------  Show Third Row Program Margin Details  ------------------------------------>

				</cfsilent><cfif reportFormatType EQ 3><cfif srQuery.Include_Trade EQ 1><cfsilent>
				<cfset thisContract_Number=srQuery.Contract_Number>
				<cfset thisItem=srQuery.Item>
				<cfset callTradeDetails=true>
				</cfsilent><!------<cfif getDistributor_Trade.recordCount GTE Item_Dist_Start_Row>-----><cfsilent>
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
					Start the next cfoutput query=""						
					To show the trade programs and the distributors			
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
					<cfset Item_Dist_Start_Row=srQuery.currentRow>
					</cfsilent><cfif srNotCSV><CFMODULE template="MarginTradeProgram_Distributors.cfm"></cfif><cfsilent>
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
					End 												    
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
				</cfsilent><!------</cfif>-----></cfif></cfif><cfsilent>
				</cfsilent></cfoutput>
		</cfoutput>
		<cfif srNotCSV>
		<cfoutput></TABLE></cfoutput>
		</cfif>
		
	<cfelse>	
		<cfif rReportOutputType EQ "h">
		<TABLE BGCOLOR="Orange" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
		<TR BGCOLOR="White">
		<TD>		
		<CFOUTPUT><FONT SIZE="2"><B>
		Report is Empty
		</B></CFOUTPUT>
		</TD>
		</TD>
		</TR>
		</TABLE>
		<cfelse>		
		<cfoutput>Report is Empty</cfoutput>
		</cfif>
	</cfif>
<cfelse>
<cfoutput>SysError - Queryname is required field</cfoutput>
</cfif>
<cfif (rReportOutputType EQ "h")>
	</body></html>
</cfif>