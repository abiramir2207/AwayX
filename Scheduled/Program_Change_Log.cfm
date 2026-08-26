<!------ Program_Change_Log.cfm ----->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!---Gets application settings--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset labelnotes = appSettings.getLabelNotes()>

<cfsavecontent variable="programChangeReport">
<html>
<head>
	<title>Scheduled Change Log</title>
	
	<style>
	TABLE.ChangeLog
	{
		font-size:12px;
	}
	TABLE.ChangeLog TD
	{
		border: 1px solid black;
	}
	TD.itemHeading
	{
		background-color:ffdead;
		font-weight:bold;
	}
	TABLE.ChangeLogNoBorder
	{
		font-size:12px;
	}
	TABLE.ChangeLogNoBorder TD
	{
		border: none;
	}
	.sp_0
	{
		color:red;
	}
	.sp_1
	{
		color:blue;
	}
	.sp_2
	{
		color:green;
	}
	</style>
</head>

<body>

<cfset qGetChangeLog = CreateObject("component", "components.programs.changeLog").init() />
<cfset qGetChangedPrograms = qGetChangeLog.getChangedPrograms() />

<cfscript>
//0=delete, 1=add, 2=change (color code)
function displayChange(sStr, iCount, color_code)
{
	if(iCount GT 0)
	{
		WriteOutput("<br>");
	}
	WriteOutput("<span class=sp_" & color_code & ">" & sStr & "</span>");
	return (iCount  + 1);
}

function displayLumpSum(qLumpSum1, qLumpSum2)
{
	var currentRow = 1;
	var deleteFromSecond = 0;
	var sAction = 0;
	var iCount = 0;
	var secondIndex = 1;
	var secondRecordCount = qLumpSum2.RecordCount;
	for (; currentRow lte qLumpSum1.RecordCount;currentRow = currentRow + 1)
	{
		secondRecordCount = (qLumpSum2.RecordCount - secondIndex) + 1;
		deleteFromSecond = 0;
		if(secondRecordCount EQ 0)
		{
			sAction = "add";
		}
		else if(qLumpSum1["Lump_Sum_Amount"][currentRow] EQ qLumpSum2["Lump_Sum_Amount"][secondIndex])
		{
			sAction = "nochange";
			deleteFromSecond = 1;
		}
		else if((qLumpSum1.RecordCount - currentRow) LT secondRecordCount)
		{
			sAction = "change";
			deleteFromSecond = 1;
		}
		else
		{
			sAction = "add";
		}
		
		displayLumpChnage(qLumpSum1, qLumpSum2, currentRow, secondIndex, sAction);
		
		if(deleteFromSecond)
		{
			secondIndex = secondIndex + 1;
		}	
		
	}
	// Display deleted
	for (; secondIndex lte qLumpSum2.RecordCount;secondIndex = secondIndex + 1)
	{
		displayLumpChnage(qLumpSum1, qLumpSum2, currentRow, secondIndex, "delete");
	}
	
}

function displayLumpChnage(qLumpSum1, qLumpSum2, currentRow, secondIndex, sAction)
{
		WriteOutput("<TR valign=""top"">");
		WriteOutput("<TD>&nbsp;</TD>");
		WriteOutput("<TD>");
		
		Second_Product_List = "";
		if(sAction NEQ "add")
		{
			WriteOutput("<B>" & qLumpSum2["Program_Lump_Sum_Name"][secondIndex] & " (" & qLumpSum2["Lump_Sum_Amount"][secondIndex] & ")</B>");
			qGetLumpProducts1 = qGetChangeLog.getLumpProducts(qLumpSum2["Program_Lump_Sum_ID"][secondIndex]);
			Second_Product_List = ValueList(qGetLumpProducts1.MaterialID);
			displayLumpProducts(qGetLumpProducts1);
		}
		
		WriteOutput("&nbsp;</TD>");
		WriteOutput("<TD>");
		
		First_Product_List = "";
		if(sAction NEQ "delete")
		{
			WriteOutput("<B>" & qLumpSum1["Program_Lump_Sum_Name"][currentRow] & " (" & qLumpSum1["Lump_Sum_Amount"][currentRow] & ")</B>");
			qGetLumpProducts2 = qGetChangeLog.getLumpProducts(qLumpSum1["Program_Lump_Sum_ID"][currentRow]);
			First_Product_List = ValueList(qGetLumpProducts2.MaterialID);
			displayLumpProducts(qGetLumpProducts2);
		}
		
		productChanged = 0;
		if(Second_Product_List NEQ First_Product_List AND sAction NEQ "add" AND sAction NEQ "delete")
		{
			productChanged = 1;
		}
		WriteOutput("&nbsp;</TD>");
		WriteOutput("<TD>");
		iCount = 0;
		if(sAction EQ "add")
		{
			iCount = displayChange("Added", iCount, 1);
		}
		else if(sAction EQ "change")
		{
			iCount = displayChange("Amount Changed", iCount, 2);
		}
		else if(sAction EQ "delete")
		{
			iCount = displayChange("Deleted", iCount, 0);
		}
		
		if(productChanged)
		{
			iCount = displayChange("Product(s) Changed", iCount, 2);
		}
				
		WriteOutput("&nbsp;</TD>");
		WriteOutput("</TR>");
}

function displayLumpProducts(qLumpProducts)
{
	var currentRow = 1;
	for (; currentRow lte qLumpProducts.RecordCount;currentRow = currentRow + 1)
	{
		WriteOutput("<br>" & qLumpProducts["Item"][currentRow] & " " & qLumpProducts["Description"][currentRow]);
	}
}

function displayRebate(productItemId, productName, rebateId)
{
	var currentRow = 1;
	var rateArray = ArrayNew(1);
	ArrayAppend(rateArray, 0);
	ArrayAppend(rateArray, 0);
	ArrayAppend(rateArray, 0);
	ArrayAppend(rateArray, 0);
	
	WriteOutput(productItemId & " " & productName);
	qGetRebateRates = qGetChangeLog.getRebateRates(rebateId);
	if(qGetRebateRates.recordCount)
	{
		WriteOutput("<br>");		
		for (; currentRow lte qGetRebateRates.RecordCount;	currentRow = currentRow + 1)
		{
			WriteOutput(qGetRebateRates["Rate"][currentRow] & " " & qGetRebateRates["UOM"][currentRow] & " ");			
			thisRate = StructNew();
			rateArray[qGetRebateRates["Unit_Of_Measure_ID"][currentRow]] = rateArray[qGetRebateRates["Unit_Of_Measure_ID"][currentRow]] + qGetRebateRates["Rate"][currentRow];			
		}
	}
	return rateArray;
}

function checkRateDifference(rateArray1, rateArray2)
{
	var rateDiff = 0;
	var thisArrayLen = ArrayLen(rateArray1);
	if(thisArrayLen NEQ ArrayLen(rateArray2))
	{
		rateDiff = 1;
	}
	else
	{
		for(i=1; i LTE thisArrayLen;i=i+1)
		{
			if(rateArray1[i] NEQ rateArray2[i])
			{
				rateDiff = 1;
				break;
			}
		}
	}
	return rateDiff;
}

function checkGrowthDifference(rateQuery1, rateQuery2, currentRow, diffArray)
{
	if(rateQuery1.recordCount)
	{
		if(NOT diffArray[1]) //no need to check difference if already different
		{
			if(rateQuery1["Range_Start"][currentRow] NEQ rateQuery2["Range_Start"][currentRow]
					OR
					rateQuery1["Range_End"][currentRow] NEQ rateQuery2["Range_End"][currentRow])
			{
				diffArray[1] = diffArray[1] OR 1;
			}
		}
		if(NOT diffArray[2]) //no need to check difference if already different
		{
			if(rateQuery1["First_Rate"][currentRow] NEQ rateQuery2["First_Rate"][currentRow]
					OR
					rateQuery1["First_UOM"][currentRow] NEQ rateQuery2["First_UOM"][currentRow])
			{
				diffArray[2] = 1;
			}
		}
	}	
	return diffArray;
}
</cfscript>
<cfif qGetChangedPrograms.recordCount>
<cfoutput><h4>#DateFormat(Now(), "mm/dd/yyyy")# #TimeFormat(Now(), "hh:mm:ss tt")#</h4></cfoutput>
<cfloop query="qGetChangedPrograms">
	<cfoutput>
	<TABLE cellpadding="2" cellspacing="0" width="80%" class="ChangeLog"<CFIF currentRow NEQ 1> style="page-break-before: always;"</CFIF>>	
	<CAPTION align="left" style="font-size:14px;font-weight:bold;background-color:eeeeee">[#Contract_Number#] #Contract_Title#</CAPTION>
	<THEAD>
		<TR bgcolor="eeeeee">
		<TH align="left">Sales person responsible</TH>
		<TH align="left" colspan="3">#Child_SP#</TH>
		</TR>
		<cfif Manual_Cancel>
		<TR bgcolor="eeeeee">
		<TH align="left" colspan="5" style="color:red;">Program has been cancelled</TH>
		</TR>
		<TR bgcolor="eeeeee">
		<TH align="left">Program cancelled by</TH>
		<TH align="left" colspan="4">#Cancelled_By_User#</TH>
		</TR>
		<TR bgcolor="eeeeee">
		<TH align="left">Program cancelled on</TH>
		<TH align="left" colspan="4">#DateFormat(Cancelled_Date, "mm/dd/yyyy")#</TH>
		</TR>
		<cfelse>
		<TR bgcolor="eeeeee">
		<TH align="left">Span</TH>
		<TH align="left" colspan="3">#DateFormat(Contract_Start_Date, "mm/dd/yyyy")# - #DateFormat(Contract_End_Date, "mm/dd/yyyy")#</TH>
		</TR>
		<TR bgcolor="eeeeee">
		<TH align="left">Change Effective Date</TH>
		<TH align="left" colspan="3">#DateFormat(Eff_Date, "mm/dd/yyyy")#</TH>
		</TR>
		<TR>
		<TH>&nbsp;</TH>
		<TH>From</TH>
		<TH>To</TH>
		<TH width="150">&nbsp;</TH>
		</TR>		
		</cfif>
	</THEAD>
	<cfif NOT Manual_Cancel>
	<!------ Show Program level changes ----->
	<TR valign="top">
		<TD><B>Approved By</B></TD>
		<TD>#Parent_Approver#&nbsp;</TD>
		<TD>#Child_Approver#&nbsp;</TD>
		<TD>&nbsp;</TD>
	</TR>
	<!------ Show Program Title ----->
	<TR valign="top">
		<TD><B>Title</B></TD>
		<TD>#Parent_Contract_Title#&nbsp;</TD>
		<TD>#Contract_Title#&nbsp;</TD>
		<TD>
		<cfif Contract_Title NEQ Parent_Contract_Title><cfset iCount = displayChange("Change", 0, 2) /></cfif>
		&nbsp;</TD>
	</TR>
	<!------ Show End Dates ----->
	<cfif DateDiff("d", Contract_End_Date, Parent_End_Date)>
	<TR valign="top">
		<TD><B>End Date</B></TD>
		<TD>#DateFormat(Parent_End_Date, "mm/dd/yyyy")#&nbsp;</TD>
		<TD>#DateFormat(Contract_End_Date, "mm/dd/yyyy")#&nbsp;</TD>
		<TD>
		<cfif DateDiff("d", Contract_End_Date, Parent_End_Date)><cfset iCount = displayChange("Change", 0, 2) /></cfif>
		&nbsp;</TD>
	</TR>
	</cfif>
	<!------ Show Program Notes ----->
	<TR valign="top">
		<TD><B>#labelnotes#</B></TD>
		<TD>#Parent_Notes#&nbsp;</TD>
		<TD>#Notes#&nbsp;</TD>
		<TD>
		<cfif Notes NEQ Parent_Notes><cfset iCount = displayChange("Change", 0, 2) /></cfif>
		&nbsp;</TD>
	</TR>
	<!------ If program volume is fifferent ----->
	<cfif 	(Parent_Contract_Quantity NEQ Child_Contract_Quantity)
				OR			 
				(Parent_Contract_Quantity_UOM NEQ Child_Contract_Quantity_UOM)
				>
	<TR valign="top">
		<TD>Program Quantity</TD>
		<TD>#Parent_Contract_Quantity# #Child_Contract_Quantity_UOM#</TD>
		<TD>#Child_Contract_Quantity# #Parent_Contract_Quantity_UOM#</TD>
		<TD>
			<cfset iCount = displayChange("Change", 0, 2) />&nbsp;
		</TD>
	</TR>
	</cfif>
	
	<!------ If operator is in template ----->
	<cfif Specify_Operators>
		<!------ Get operator info ----->		
		<cfset qGetOperator1 = qGetChangeLog.getOperatorsRemoved(Child_Contract_Main_ID, Parent_Contract_Main_ID, 0) />
		<cfset qGetOperator2 = qGetChangeLog.getOperatorsRemoved(Parent_Contract_Main_ID, Child_Contract_Main_ID, 1) />
		<cfif qGetOperator1.recordCount OR qGetOperator2.recordCount>
		<TR valign="top">
			<TD colspan="100%" class="itemHeading">#application.returned_customer_setting.operator_label_singular#</TD>
		</TR>
		</cfif>
		<cfloop from="1" to="2" index="serialNum">
			<cfset qGetOperator = Evaluate("qGetOperator#serialNum#")>
			<cfloop query="qGetOperator">
			<TR valign="top">
				<TD>&nbsp;</TD>
				<TD>
				<cfif serialNum EQ 1>#Parent_Name#<cfelse>#Child_Name#</cfif>&nbsp;
				</TD>
				<TD>
				<cfif serialNum EQ 1>#Child_Name#<cfelse>#Parent_Name#</cfif>&nbsp;
				</TD>
				<TD>
					<cfset iCount = 0>
					<cfif (serialNum EQ 1 AND Deleted) OR (serialNum EQ 2 AND Added)>
						<cfset iCount = displayChange("Deleted", iCount, 0) />
					</cfif>
					<cfif (serialNum EQ 1 AND Added) OR (serialNum EQ 2 AND Deleted)>
						<cfset iCount = displayChange("Added", iCount, 1) />
					</cfif>
					<cfif Change>
						<cfset iCount = displayChange("Changed", iCount, 2) />
					</cfif>&nbsp;
				</TD>
			</TR>
			</cfloop>
		</cfloop>
		
	</cfif>
	
	
	<!------ If Distributor is in template ----->
	<cfif Specify_Distributors>
		<!------ Get Distributor info ----->
		<cfset qGetDistributor1 = qGetChangeLog.getDistributorsRemoved(Child_Contract_Main_ID, Parent_Contract_Main_ID, 0) />
		<cfset qGetDistributor2 = qGetChangeLog.getDistributorsRemoved(Parent_Contract_Main_ID, Child_Contract_Main_ID, 1) />
		<cfif qGetDistributor1.recordCount OR qGetDistributor2.recordCount >
		<TR valign="top">
			<TD colspan="100%" class="itemHeading">#application.returned_customer_setting.distributor_label_singular#</TD>
		</TR>
		</cfif>
		
		<cfloop from="1" to="2" index="serialNum">
			<cfset qGetDistributor = Evaluate("qGetDistributor#serialNum#")>
			<cfloop query="qGetDistributor">
			<TR valign="top">
				<TD>&nbsp;</TD>
				<TD>
				<cfif serialNum EQ 1><cfif Parent_ID NEQ "">#Parent_Name# (#Parent_Weight#%)</cfif><cfelse><cfif Child_ID NEQ "">#Child_Name# (#Child_Weight#%)</cfif></cfif>&nbsp;
				</TD>
				<TD>
				<cfif serialNum EQ 1><cfif Child_ID NEQ "">#Child_Name# (#Child_Weight#%)</cfif><cfelse><cfif Parent_ID NEQ "">#Parent_Name# (#Parent_Weight#%)</cfif></cfif>&nbsp;
				</TD>
				<TD>
					<cfset iCount = 0>
					<cfif (serialNum EQ 1 AND Deleted) OR (serialNum EQ 2 AND Added)>
						<cfset iCount = displayChange("Deleted", iCount, 0) />
					</cfif>
					<cfif (serialNum EQ 1 AND Added) OR (serialNum EQ 2 AND Deleted)>
						<cfset iCount = displayChange("Added", iCount, 1) />
					</cfif>
					<cfif Change>
						<cfset iCount = displayChange("Weight Changed", iCount, 2) />
					</cfif>&nbsp;
				</TD>
			</TR>
			</cfloop>
		</cfloop>
		
	</cfif>
	
	
	<!------ If Specify_Brokers is in template ----->
	<cfif Specify_Brokers>
		<!------ Get Broker info ----->
		
		<cfset qGetBroker1 = qGetChangeLog.getBrokersRemoved(Child_Contract_Main_ID, Parent_Contract_Main_ID, 0) />
		<cfset qGetBroker2 = qGetChangeLog.getBrokersRemoved(Parent_Contract_Main_ID, Child_Contract_Main_ID, 1) />
		<cfif qGetBroker1.recordCount OR qGetBroker1.recordCount>
		<TR valign="top">
			<TD colspan="100%" class="itemHeading">#application.returned_customer_setting.broker_label_singular#</TD>
		</TR>
		</cfif>
		<cfloop from="1" to="2" index="serialNum">
			<cfset qGetBroker = Evaluate("qGetBroker#serialNum#")>
			<cfloop query="qGetBroker">
			<TR valign="top">
				<TD>&nbsp;</TD>
				<TD>
				<cfif serialNum EQ 1>#Parent_Name#<cfelse>#Child_Name#</cfif>
				&nbsp;</TD>
				<TD>
				<cfif serialNum EQ 1>#Child_Name#<cfelse>#Parent_Name#</cfif>
				&nbsp;</TD>
				<TD>
					<cfset iCount = 0>
					<cfif (serialNum EQ 1 AND Deleted) OR (serialNum EQ 2 AND Added)>
						<cfset iCount = displayChange("Deleted", iCount, 0) />
					</cfif>
					<cfif (serialNum EQ 1 AND Added) OR (serialNum EQ 2 AND Deleted)>
						<cfset iCount = displayChange("Added", iCount, 1) />
					</cfif>
					<cfif Change>
						<cfset iCount = displayChange("Changed", iCount, 2) />
					</cfif>&nbsp;
				</TD>
			</TR>
			</cfloop>
		</cfloop>
		
	</cfif>
	
	<!------ Off-Invoice ----->
	<cfif Generic_Type EQ "Distributor Off-Invoice">
		<cfset qGetOffInvoice1 = qGetChangeLog.getOffInvoiceRemoved(Child_Contract_Main_ID, Parent_Contract_Main_ID, 0) />
		<cfset qGetOffInvoice2 = qGetChangeLog.getOffInvoiceRemoved(Parent_Contract_Main_ID, Child_Contract_Main_ID, 1) />
		<cfif qGetOffInvoice1.recordCount OR qGetOffInvoice2.recordCount>
		<TR valign="top">
			<TD colspan="100%" class="itemHeading">Off Invoice</TD>
		</TR>
		</cfif>
		
		<cfloop from="1" to="2" index="serialNum">
			<cfset qGetOffInvoice = Evaluate("qGetOffInvoice#serialNum#")>
			<cfloop query="qGetOffInvoice">
			<TR valign="top">
				<TD>&nbsp;</TD>
				<TD>
				<cfif serialNum EQ 1>
					<cfif Second_ID NEQ "">#Second_Name# (#Second_Rate# #Second_UOM#)</cfif>
				<cfelse>
					<cfif First_ID NEQ "">#First_Name# (#First_Rate# #First_UOM#)</cfif>
				</cfif>
				&nbsp;</TD>
				<TD>
				<cfif serialNum EQ 1>
					<cfif First_ID NEQ "">#First_Name# (#First_Rate# #First_UOM#)</cfif>
				<cfelse>
					<cfif Second_ID NEQ "">#Second_Name# (#Second_Rate# #Second_UOM#)</cfif>
				</cfif>
				&nbsp;</TD>
				<TD>
					<cfset iCount = 0>
					<cfif (serialNum EQ 1 AND Deleted) OR (serialNum EQ 2 AND Added)>
						<cfset iCount = displayChange("Deleted", iCount, 0) />
					</cfif>
					<cfif (serialNum EQ 1 AND Added) OR (serialNum EQ 2 AND Deleted)>
						<cfset iCount = displayChange("Added", iCount, 1) />
					</cfif>
					<cfif Change>
						<cfset iCount = displayChange("Rate Changed", iCount, 2) />
					</cfif>&nbsp;
				</TD>
			</TR>
			</cfloop>
		</cfloop>
		
	</cfif>
	
	<!------ Bid Request ----->
	<cfif Generic_Type EQ "Bid Request">
		<cfset qGetBidRequest1 = qGetChangeLog.getBidRequestRemoved(Child_Contract_Main_ID, Parent_Contract_Main_ID, 0) />
		<cfset qGetBidRequest2 = qGetChangeLog.getBidRequestRemoved(Parent_Contract_Main_ID, Child_Contract_Main_ID, 1) />
		<cfif qGetBidRequest1.recordCount OR qBidRequest2.recordCount>
		<TR valign="top">
			<TD colspan="100%" class="itemHeading">Proposal</TD>
		</TR>
		</cfif>
		<cfloop from="1" to="2" index="serialNum">
			<cfset qGetBidRequest = Evaluate("qGetBidRequest#serialNum#")>
			<cfloop query="qGetBidRequest">
			<TR valign="top">
				<TD>&nbsp;</TD>
				<TD>
				<cfif serialNum EQ 1>
					<cfif Second_ID NEQ "">#Second_Name# (#Second_Price# #Second_UOM#)</cfif>
				<cfelse>
					<cfif First_ID NEQ "">#First_Name# (#First_Price# #First_UOM#)</cfif>
				</cfif>
				&nbsp;</TD>
				<TD>
				<cfif serialNum EQ 1>
					<cfif First_ID NEQ "">#First_Name# (#First_Price# #First_UOM#)</cfif>
				<cfelse>
					<cfif Second_ID NEQ "">#Second_Name# (#Second_Price# #Second_UOM#)</cfif>
				</cfif>
				&nbsp;</TD>
				<TD>
					<cfset iCount = 0>
					<cfif (serialNum EQ 1 AND Deleted) OR (serialNum EQ 2 AND Added)>
						<cfset iCount = displayChange("Deleted", iCount, 0) />
					</cfif>
					<cfif (serialNum EQ 1 AND Added) OR (serialNum EQ 2 AND Deleted)>
						<cfset iCount = displayChange("Added", iCount, 1) />
					</cfif>
					<cfif Change>
						<cfset iCount = displayChange("Rate Changed", iCount, 2) />
					</cfif>&nbsp;
				</TD>
			</TR>
			</cfloop>
		</cfloop>
		
	</cfif>
		
	<!------ Fixed Price ----->
	<cfif Discount_Fixed_Prices>
		
		<!------ Get Fixed info ----->
		<cfset qGetFixed1 = qGetChangeLog.getFixedRemoved(Child_Contract_Main_ID, Parent_Contract_Main_ID, 0) />
		<cfset qGetFixed2 = qGetChangeLog.getFixedRemoved(Parent_Contract_Main_ID, Child_Contract_Main_ID, 1) />
		
		<cfif qGetFixed1.recordCount OR qGetFixed2.recordCount>
		<TR valign="top">
			<TD colspan="100%" class="itemHeading">Fixed Price</TD>
		</TR>
		</cfif>
		
		<cfloop from="1" to="2" index="serialNum">
			<cfset qGetFixed = Evaluate("qGetFixed#serialNum#")>
			<cfloop query="qGetFixed">
			<TR valign="top">
				<TD>&nbsp;</TD>
				<TD>
				<cfif serialNum EQ 1>
					<cfif Second_ID NEQ "">#Second_Item_ID# #Second_Name# (#Second_Price# #Second_UOM#)</cfif>
				<cfelse>
					<cfif First_ID NEQ "">#First_Item_ID# #First_Name# (#First_Price# #First_UOM#)</cfif>
				</cfif>
				&nbsp;</TD>
				<TD>
				<cfif serialNum EQ 1>
					<cfif First_ID NEQ "">#First_Item_ID# #First_Name# (#First_Price# #First_UOM#)</cfif>
				<cfelse>
					<cfif Second_ID NEQ "">#Second_Item_ID# #Second_Name# (#Second_Price# #Second_UOM#)</cfif>
				</cfif>
				&nbsp;</TD>
				<TD>
					<cfset iCount = 0>
					<cfif (serialNum EQ 1 AND Deleted) OR (serialNum EQ 2 AND Added)>
						<cfset iCount = displayChange("Deleted", iCount, 0) />
					</cfif>
					<cfif (serialNum EQ 1 AND Added) OR (serialNum EQ 2 AND Deleted)>
						<cfset iCount = displayChange("Added", iCount, 1) />
					</cfif>
					<cfif Change>
						<cfset iCount = displayChange("Price Changed", iCount, 2) />
					</cfif>&nbsp;
				</TD>
			</TR>
			</cfloop>
		</cfloop>
	</cfif>
	
	<!------ Rebate ----->
	
	
	<cfif Discount_Rebates>
		
		<!------ Get pricing Levels ----->
		<cfset qGetPricingLevels = qGetChangeLog.getPricingLevels(Child_Contract_Main_ID, Parent_Contract_Main_ID) />
		<cfset Val_Child_Contract_Main_ID = Child_Contract_Main_ID>
		<cfset Val_Parent_Contract_Main_ID = Parent_Contract_Main_ID>
		
		<cfloop query="qGetPricingLevels">
			
			<TR valign="top"><TD colspan="100%" class="itemHeading">#Application.RebateLabel#
			<cfif qGetPricingLevels.recordCount GT 1>
			 - #Pricing_Level_Label#<!------ Pricing_Level_ID ----->
			</cfif>
			</TD></TR>
			
			<cfset qGetRebate1 = qGetChangeLog.getRebateRemoved(Val_Child_Contract_Main_ID, Val_Parent_Contract_Main_ID, 0, Pricing_Level_ID) />
			<cfset qGetRebate2 = qGetChangeLog.getRebateRemoved(Val_Parent_Contract_Main_ID, Val_Child_Contract_Main_ID, 1, Pricing_Level_ID) />
			<cfloop from="1" to="2" index="serialNum">
				<cfset qGetRebate = Evaluate("qGetRebate#serialNum#")>
				<cfloop query="qGetRebate">
				<TR valign="top">
					<TD>&nbsp;</TD>
					<TD>
					<cfset rateArray1 = ArrayNew(1)>
					<cfset rateArray2 = ArrayNew(1)>
					<cfif serialNum EQ 1>
						<cfif Second_ID NEQ "">
							<cfset rateArray1 = displayRebate(Second_Item_ID, Second_Name, Second_Rebate_ID)>
						</cfif>
					<cfelse>
						<cfif First_ID NEQ "">
							<cfset rateArray1 = displayRebate(First_Item_ID, First_Name, First_Rebate_ID)>						
						</cfif>
					</cfif>
					<!------ show rates ----->					
					
					&nbsp;</TD>
					<TD>
					<cfif serialNum EQ 1>
						<cfif First_ID NEQ "">
							<cfset rateArray2 = displayRebate(First_Item_ID, First_Name, First_Rebate_ID)>
						</cfif>
					<cfelse>
						<cfif Second_ID NEQ "">
							<cfset rateArray2 = displayRebate(Second_Item_ID, Second_Name, Second_Rebate_ID)>
						</cfif>
					</cfif>
					&nbsp;</TD>					
					<TD>
						<cfset RateChanged = checkRateDifference(rateArray1, rateArray2)>
						<cfset iCount = 0>
						<cfif (serialNum EQ 1 AND Deleted) OR (serialNum EQ 2 AND Added)>
							<cfset iCount = displayChange("Deleted", iCount, 0) />
						</cfif>
						<cfif (serialNum EQ 1 AND Added) OR (serialNum EQ 2 AND Deleted)>
							<cfset iCount = displayChange("Added", iCount, 1) />
						</cfif>
						<cfif (Change OR RateChanged) AND NOT Added AND NOT Deleted>
							<cfset iCount = displayChange("Rate Changed", iCount, 2) />
						</cfif>&nbsp;
					</TD>
				</TR>
				</cfloop>
			</cfloop>
			
		</cfloop>
		
		
	</cfif>
	
	
	
	<!------ Lump sum  ----->
	<cfif Discount_Lump_Sums>		
		<!------ Get lumpsum Info ----->		
		<cfset qGetAllLumpSumNames = qGetChangeLog.getAllLumpSumNames(Child_Contract_Main_ID, Parent_Contract_Main_ID) />
		
		<cfif qGetAllLumpSumNames.recordCount>
		<TR valign="top">
			<TD colspan="100%" class="itemHeading">#Application.LumpsumLabel#</TD>
		</TR>
		</cfif>
		
		<cfset Val_Child_Contract_Main_ID = Child_Contract_Main_ID>
		<cfset Val_Parent_Contract_Main_ID = Parent_Contract_Main_ID>
		<cfloop query="qGetAllLumpSumNames">
			<cfset qGetThisLumpSum1 = qGetChangeLog.getThisLumpSum(Val_Child_Contract_Main_ID, Program_Lump_Sum_Name_ID) />
			<cfset qGetThisLumpSum2 = qGetChangeLog.getThisLumpSum(Val_Parent_Contract_Main_ID, Program_Lump_Sum_Name_ID) />
			<cfset displayLumpSum(qGetThisLumpSum1, qGetThisLumpSum2) />
			
		</cfloop>
		
	</cfif>
	<!------ Growth ----->
	<cfif Discount_Growth>
		<!------ Get Growth Info ----->
		
		<cfset qGetAllGrowthProducts1 = qGetChangeLog.getAllGrowthProducts(Child_Contract_Main_ID, Parent_Contract_Main_ID, 0) />
		<cfset qGetAllGrowthProducts2 = qGetChangeLog.getAllGrowthProducts(Parent_Contract_Main_ID, Child_Contract_Main_ID, 1) />
		
		<cfif qGetAllGrowthProducts1.recordCount OR qGetAllGrowthProducts2.recordCount>
		<TR valign="top">
			<TD colspan="100%" class="itemHeading">Growth</TD>
		</TR>
		</cfif>
		
		<cfset Val_Child_Contract_Main_ID = Child_Contract_Main_ID>
		<cfset Val_Parent_Contract_Main_ID = Parent_Contract_Main_ID>
		
		<cfloop from="1" to="2" index="serialNum">
			<cfset qGetAllGrowthProducts = Evaluate("qGetAllGrowthProducts#serialNum#")>
			<cfloop query="qGetAllGrowthProducts">
			<TR valign="top">
				<TD>&nbsp;</TD>
				<TD style="font-weight:bold;">
				<cfif serialNum EQ 1>
					<cfif Second_ID NEQ "">#Second_Item_ID# #Second_Name#</cfif>
				<cfelse>
					<cfif First_ID NEQ "">#First_Item_ID# #First_Name#</cfif>
				</cfif>
				&nbsp;</TD>
				<TD style="font-weight:bold;">
				<cfif serialNum EQ 1>
					<cfif First_ID NEQ "">#First_Item_ID# #First_Name#</cfif>
				<cfelse>
					<cfif Second_ID NEQ "">#Second_Item_ID# #Second_Name#</cfif>
				</cfif>
				&nbsp;</TD>
				<TD>
					<cfset iCount = 0>					
					<cfif (serialNum EQ 1 AND Deleted) OR (serialNum EQ 2 AND Added)>
						<cfset iCount = displayChange("Deleted", iCount, 0) />
					</cfif>
					<cfif (serialNum EQ 1 AND Added) OR (serialNum EQ 2 AND Deleted)>
						<cfset iCount = displayChange("Added", iCount, 1) />
					</cfif>
					&nbsp;
				</TD>
			</TR>
			
			<cfset qGetGrowthProductRates1 = qGetChangeLog.getGrowthProductRates(BSA_Foodservice_Items_Master_ID, First_Program_ID) />
			<cfset qGetGrowthProductRates2 = qGetChangeLog.getGrowthProductRates(BSA_Foodservice_Items_Master_ID, Second_Program_ID) />
			<cfset changeArray = ArrayNew(1)>
			<cfset ArrayAppend(changeArray, 0)>
			<cfset ArrayAppend(changeArray, 0)>
			
			<cfif serialNum EQ 1>
				<cfset qGetProductRates1 = Evaluate("qGetGrowthProductRates2")>
				<cfset qGetProductRates2 = Evaluate("qGetGrowthProductRates1")>
			<cfelse>		
				<cfset qGetProductRates1 = Evaluate("qGetGrowthProductRates1")>
				<cfset qGetProductRates2 = Evaluate("qGetGrowthProductRates2")>
			</cfif>
			
			<cfset useLoop = 2>
			<cfif qGetProductRates1.recordCount GT qGetProductRates2.recordCount>
				<cfset useLoop = 1>
			</cfif>
			<TR valign="top">
				<TD>&nbsp;</TD>
				<TD>
					<table class="ChangeLogNoBorder" border="0" cellpadding="2" cellspacing="0">
					<cfloop query="qGetProductRates1">
						<tr>
						<td align="right">#Range_Start#</td>
						<td> - </td>
						<td align="right">#Range_End#</td>
						<td>(#First_Rate# #First_UOM#)</td>
						</tr>
						<cfif useLoop EQ 1>
							<cfset changeArray = checkGrowthDifference(qGetProductRates2, qGetProductRates1, currentRow, changeArray) />
						</cfif>						
					</cfloop>
					</table>
				</TD>
				<TD>
					<table class="ChangeLogNoBorder" border="0" cellpadding="2" cellspacing="0">
					<cfloop query="qGetProductRates2">
						<tr>
						<td align="right">#Range_Start#</td>
						<td> - </td>
						<td align="right">#Range_End#</td>
						<td>(#First_Rate# #First_UOM#)</td>
						</tr>
						<cfif useLoop EQ 2>
							<cfset changeArray = checkGrowthDifference(qGetProductRates1, qGetProductRates2, currentRow, changeArray) />
						</cfif>
					</cfloop>
					</table>
				</TD>
				<TD>				
				<cfset iCount = 0>
				<cfif changeArray[1]>
					<cfset iCount = displayChange("Targets Changed", iCount, 2)>
				</cfif>
				<cfif changeArray[2]>
					<cfset iCount = displayChange("Rate Changed", iCount, 2)>
				</cfif>
				&nbsp;</TD>
			</TR>
			</cfloop>
		</cfloop>
	</cfif>		
	
	<!------ TODO: Formula Pricing ----->
		
	</cfif>
	</cfoutput>
	</TABLE>
	
	<cfset qGetChangeLog.updateProgramSentStatus(Child_Contract_Main_ID, Manual_Cancel) />
	
	</cfloop>
	</cfif>


</body>
</html>
</cfsavecontent>


<cfif qGetChangedPrograms.recordCount GT 0>
	
	<cfset dirNameOnly = "Program_Change_Log_Reports">
	<cfset dirName = ExpandPath(dirNameOnly)>
	<cfif NOT DirectoryExists(dirName)>
		<cfdirectory action="create" directory="#dirName#">
	</cfif>
	
	<cfparam name="request.AccessStructure.USER_ID" 	default="0000000000">
	<cfset toEmail = "" />
	<cfset toEmail = ListAppend(toEmail, "dkunnath@bigredflame.com", ";") />
	<!------ 
	<cfset toEmail = ListAppend(toEmail, "J.R.Houchin@conagrafoods.com", ";") />
	<cfset toEmail = ListAppend(toEmail, "Joel.Hilgemann@conagrafoods.com", ";") />
	<cfset toEmail = ListAppend(toEmail, "amcclelland@bigredflame.com", ";") />
	<cfset toEmail = ListAppend(toEmail, "", ";") />
	 ----->
	
	<CF_Writing_Email_Attachment
		Naming_Format = "Program_Change_Log_Report_#DateFormat(Now(), "mmddyyyy")#"
		File_Extension = "html"
		Relative_Path = "/Scheduled/#dirNameOnly#"
		Output_Content = "#programChangeReport#"
		Return_File_Name = "Saved_File_Path"
		addNewLine = "No"
		>
		
	<cfmail to = "#toEmail#"
			from = "dkunnath@bigredflame.com"
	      	subject = "Program Change Log Report"		
			>
			Program change log initiated from #CGI.SERVER_NAME# on #DateFormat(Now(), "mm/dd/yyyy")# #TimeFormat(Now(), "hh:mm:ss tt")#
			<cfmailparam file="#Saved_File_Path#" />
	</cfmail>
	
	<center>
	<span style="fonr-weight:bold;font-size:14px;">
	The report has been emailed to <cfoutput>#toEmail#</cfoutput>
	</span>
	</center>
	
<cfelse>

	<center>
	<span style="fonr-weight:bold;font-size:14px;">
	There is nothing to report.
	</span>
	</center>

</cfif>

