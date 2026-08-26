<!---This file is a printable report on bid requests generated from the bid reqeust search screen--->
<cfparam name="url.command" default="" />

<!---default parameters--->
<CFPARAM name="businessSegmentsOn" default="0">

<!---check to see if the business segment components exist before we run this--->
<!---check whether the directory exists or not--->
<cfset theDir = "#request.app_general_functions.get_Application_Path()#\components\programs\business_segment\" />
<cfif DirectoryExists(theDir)>
	<!---if the directory exists then check the file--->
	<cfset theFile = "#theDir#BusinessSegmentManager.cfc" />
	<!---it the file exists then we can create the component--->
	<cfif FileExists(theFile)>
		<!---create and instance of the BusinessSegmentManager--->
		<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<cfif businessSegManager.isEnabled()>
			<cfset businessSegmentsOn = 1 />
		</cfif>
	</cfif>
</cfif>

<cfquery name="GetInfo" datasource="#application.datasource#">
	SELECT	DISTINCT 
		Contract_Main.Contract_Main_ID, 
		Contract_Main.Contract_Number, 
		Contract_Main.Contract_Title, 
		Contract_Main.Contract_Start_Date, 
		Contract_Main.Contract_End_Date, 
		Contract_Main.Contract_Status_Type_IDX, 
		Contract_Main.Contract_Is_Locked,
		<cfif businessSegmentsOn EQ 1>
		Contract_Main.Business_Segment_ID,
		</cfif>
		Contract_Main.Contract_Quantity, 
		Contract_Main.Contract_Reference_Number, 
		Contract_Main.Contract_Locked_By_User_ID, 
		Contract_Main.Contract_Quantity_UOM_IDX,
		Units_of_Measure.Unit_Of_Measure_Desc, 
		Units_of_Measure.Abbreviation, 
		Bid_Request_Status.Status_Desc,
		Program_Bid_Request.Open_Date,
		Program_Bid_Request.Date_Needed,
		Program_Bid_Request.Bid_Request_Status_ID,
		 _Users.Name_First, 
		 _Users.Name_Last,
		 Approval_date, 
		 Broker_Approved_Date, 
		 Revision_of_Contract_Main_ID, 
		 Is_A_Revision, 
		<cfif businessSegmentsOn EQ 1>
			Business_Segment.Business_Unit_Desc
		<cfelse>
			'' As Business_Unit_Desc
		</cfif>, 
		
		<!----Gets accrual information--->		
		isnull(( 		
			SELECT SUM(Allowance * 
			CASE
				WHEN Program_Bid_Request_Product.UOM = 1 THEN
					Program_Product_Volume.Volume_CS
				ELSE
					Program_Product_Volume.Volume_LB
			END
			) 
			FROM Program_Bid_Request_Product
				INNER JOIN Contract_Products ON
				Contract_Products.Deleted = 0
				AND Contract_Products.Contract_Products_ID = Program_Bid_Request_Product.Contract_Products_ID
				INNER JOIN Program_Product_Volume ON
				Program_Product_Volume.Program_ID = Contract_Main.Contract_Main_ID
				AND 	Program_Product_Volume.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
				AND 	Program_Product_Volume.Deleted = 0
				WHERE	Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
				AND		Program_Bid_Request_Product.Deleted = 0
				AND 	Program_Bid_Request_Product.Won = 1			
			
		) * (datediff(d, Contract_Start_Date, Contract_End_Date) + 1) / 7,0)
		
		 AS TotalAllowance	,
		 <!----Gets revenue information--->
		 <!----Gets accrual information--->		
		isnull(( 		
			SELECT SUM((Allowance + Price) * 
			CASE
				WHEN Program_Bid_Request_Product.UOM = 1 THEN
					Program_Product_Volume.Volume_CS
				ELSE
					Program_Product_Volume.Volume_LB
			END
			) 
			FROM Program_Bid_Request_Product
				INNER JOIN Contract_Products ON
				Contract_Products.Deleted = 0
				AND Contract_Products.Contract_Products_ID = Program_Bid_Request_Product.Contract_Products_ID
				INNER JOIN Program_Product_Volume ON
				Program_Product_Volume.Program_ID = Contract_Main.Contract_Main_ID
				AND 	Program_Product_Volume.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
				AND 	Program_Product_Volume.Deleted = 0
				WHERE	Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
				AND		Program_Bid_Request_Product.Deleted = 0
				AND 	Program_Bid_Request_Product.Won = 1			
			
		) * (datediff(d, Contract_Start_Date, Contract_End_Date) + 1) / 7,0)
		
		 AS TotalRevenue	,
		 	isnull(( 		
			SELECT SUM((Price) * 
			CASE
				WHEN Program_Bid_Request_Product.UOM = 1 THEN
					Program_Product_Volume.Volume_CS
				ELSE
					Program_Product_Volume.Volume_LB
			END
			) 
			FROM Program_Bid_Request_Product
				INNER JOIN Contract_Products ON
				Contract_Products.Deleted = 0
				AND Contract_Products.Contract_Products_ID = Program_Bid_Request_Product.Contract_Products_ID
				INNER JOIN Program_Product_Volume ON
				Program_Product_Volume.Program_ID = Contract_Main.Contract_Main_ID
				AND 	Program_Product_Volume.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
				AND 	Program_Product_Volume.Deleted = 0
				WHERE	Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
				AND		Program_Bid_Request_Product.Deleted = 0
				AND 	Program_Bid_Request_Product.Won = 1			
			
		) * (datediff(d, Contract_Start_Date, Contract_End_Date) + 1) / 7,0)
		
		 AS NetRevenue	,
		 <!---End accrual information--->
		
		( SELECT 	Count(*)
			FROM	Program_Bid_Request_Product
			WHERE	Program_Bid_Request_Product.Program_ID = Contract_Main.Contract_Main_ID
					AND	Program_Bid_Request_Product.Deleted = 0
					AND Won = 1
		) AS Won_Products,
		( SELECT 	Count(*)
			FROM	Program_Bid_Request_Product
			WHERE	Program_Bid_Request_Product.Program_ID = Contract_Main.Contract_Main_ID
					AND	Program_Bid_Request_Product.Deleted = 0
					AND Won = 0
		) AS Lost_Products,
		
		( SELECT 	Count(*)
			FROM	Program_Bid_Request_Product
			WHERE	Program_Bid_Request_Product.Program_ID = Contract_Main.Contract_Main_ID
					AND	Program_Bid_Request_Product.Deleted = 0
		) AS All_Products,
				
		( SELECT 	Count(*)
			FROM 	Contract_Operators
			WHERE	Contract_Operators.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND Contract_Operators.Deleted = 0
		) AS Number_of_Operators,
		
				( SELECT 	SUM(price)
			FROM	Program_Bid_Request_Product
			WHERE	Program_Bid_Request_Product.Program_ID = Contract_Main.Contract_Main_ID
					AND	Program_Bid_Request_Product.Deleted = 0
		) AS Total_Net
		
		
FROM Contract_Main
	INNER JOIN Program_Bid_Request 
	ON Program_Bid_Request.Program_ID = Contract_Main.Contract_Main_ID
	AND Program_Bid_Request.Deleted = 0
	INNER JOIN Bid_Request_Status
	ON Bid_Request_Status.Bid_Request_Status_ID = Program_Bid_Request.Bid_Request_Status_ID
	AND Bid_Request_Status.Deleted = 0
	INNER JOIN	Units_of_Measure 
	ON Contract_Main.Contract_Quantity_UOM_IDX = Units_of_Measure.Unit_Of_Measure_ID	
	LEFT JOIN _Users 
	ON 	((Contract_Main.Broker_User_ID = _Users.User_ID)
		AND
		((Contract_Main.Broker_User_ID = _Users.User_ID) AND (Contract_Status_Type_IDX = 2))
		OR
		((Contract_Main.Approved_By_User_ID = _Users.User_ID) AND (Contract_Status_Type_IDX >= 4))
		) 
	<cfif businessSegmentsOn EQ 1>
		LEFT JOIN Business_Segment
		ON
		Business_Segment.Deleted = 0
		AND
		Business_Segment.Business_Segment_ID = Contract_Main.Business_Segment_ID
	</cfif>
					
WHERE Contract_Main_ID IN (#ProgramList#)
ORDER BY #url.SortBy#
</cfquery>

<CFSET PAGE_TITLE= "Proposal Report">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT SRC="/script/javascript/DHTML_Tooltip_Code.js"></SCRIPT>
</HEAD>

<cfset TotalAccrual = 0>
<cfset TotalPending = 0>
<cfset TotalWon = 0>

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5" ONLOAD="">

<cfif url.command eq "print">
	<CFINCLUDE template="/Common_Files/Printer_Friendly_Script.cfm">
</cfif>

<!---filter for email and fax--->
<cfif not ListFindNoCase("print,email,fax", url.command)>

	<SCRIPT LANGUAGE="JavaScript">
		document.body.onload=new Function ("popupInit();")
		
		
		function initTheTooltip()
		{
			popUp(-1)
		}
			
	</SCRIPT>
	
	<DIV ID="divTooltip" STYLE="position:absolute;visibility:hidden;background-color: F5F5DC; z-index: 5000;width:230;height:50;border:1px solid black;">
	<TABLE CELLPADDING="2" CELLPADDING="0" BORDER="0">
			<TR>
				<TD>
					<IMG SRC="/images/wip.gif" ALT="Work in progress.">&nbsp;Work In Progress
				</TD>
				<TD>
					<IMG SRC="/images/rfa.gif" ALT="Ready For Approval.">&nbsp;Ready For Approval
				</TD>
			</TR>
			<TR>
				<TD>
					<IMG SRC="/images/preactive.gif" ALT="pre-active.">&nbsp;Pre-Active
				</TD>
				<TD>
					<IMG SRC="/images/active.gif" ALT="Active.">&nbsp;Active
				</TD>
			</TR>
			<TR>
				<TD>
					<IMG SRC="/images/expiring.gif" ALT="Expiring">&nbsp;Expiring
				</TD>
				<TD>
					<IMG SRC="/images/expired.gif" ALT="Expired">&nbsp;Expired
				</TD>
			</TR>
			<TR>
			<TD>
				<IMG SRC="/images/not_allowed.gif" ALT="Rejected/Lost">&nbsp;Rejected/Lost
			</TD>
		</TR>
		</TABLE>
	</DIV>

</cfif>
<table width="100%">
	<tr>
		<td><font color="#000080" size="+1"><b>Proposal Report</b></font></td>
	</tr>

</table>
<hr color="#000080">
<!---filter for email and fax--->
<cfif not ListFindNoCase("print,email,fax", url.command)>
	<FONT SIZE="2">
		<B><FONT COLOR="FF0000">[</FONT><a href="javascript:window.close();"> close </a><FONT COLOR="FF0000">]</FONT></B>
	</FONT>
	<br><br>
</cfif>

<TABLE border="0" WIDTH="100%" cellspacing="0" cellpadding="2" CLASS="Maintable">

	<TR ID="header" BGCOLOR="#FFCE84">
		<td align="left" ID="header">&nbsp;</td>
		<td align="left" ID="header" valign="top"><b>Contract Number</b></td>
		<td align="left" ID="header" valign="top"><b>Contract Title</b></td>
		
		<td align="left" id="header" valign="top"><b>Operators/<br>Products</b></td>
	
		<td align="left" ID="header" valign="top"><b>Start/End Date</b></td>
		<td align="left" ID="header" valign="top"><b>Needed/<br>Open Date</b></td>
		<td align="left" ID="header" valign="top"><b>Bid<br>Status</b></td>
		<!--- <td align="left" ID="header" valign="top"><b>Per Unit<br>Allowance</b></td> --->
		<td align="left" ID="header" valign="top"><b>QTY</b></td>
		<td align="left" id="header" valign="top"><b>Gross<Br> Sales</b></td>
		<td align="left" id="header" valign="top"><b>Net<Br> Sales</b></td>
		<td align="left" id="header" valign="top"><b>Cost %</b></td>
		<td align="left" id="header" valign="top"><b>Commit</b></td>
	</tr>
	
<CFOUTPUT QUERY="GetInfo">

	<!---calculate periodic value--->
	<cfset ProgramSpanInDays = datediff('d', Contract_Start_Date, Contract_End_Date) + 1>
	<cfset DailyVolume = Contract_Quantity/ProgramSpanInDays>
	
	<!---Gets--->
	<cfset defaultUOT = CreateObject("component", "components.volume.uotManager").getDefaultVolumeUOT(request.AccessStructure.company_main_Id)>

	<cfif NOT defaultUOT.getMultiplier()>
		<cfset defaultUOT.setMultiplier(ProgramSpanInDays) />
	</cfif>
	<!---calculate periodic value--->

	<!---The periodic value to display--->
	<cfset DisplayValue = DailyVolume * defaultUOT.getMultiplier()>
	<cfset TotalAccrual = TotalAccrual + TotalAllowance>
	
	<cfif GetInfo.Bid_Request_Status_ID IS 2 OR GetInfo.Bid_Request_Status_ID IS 3>
		<cfset TotalWon = TotalWon + TotalAllowance>
	</cfif>
	<cfif GetInfo.Bid_Request_Status_ID IS 1>
		<cfset TotalPending = TotalPending + TotalAllowance>
	</cfif>
	
	<cfparam name="margPerc" default="0" />
	<cfparam name="NetDollars" default="0" />
	<!---The margin percent (the volume * rebate) / (the volume * cost) * 100 --->
	<cfset TheVolume = Contract_Quantity>
	<cfset RebateDollars = TheVolume * TotalAllowance />
	<cfset cost = TheVolume * TotalRevenue />
	<cfset NetDollars = Contract_Quantity * TotalAllowance>
	<!---guard against zero's--->
	<cfif cost eq 0>
		<cfset margPerc = 0 />
	<cfelse>
		<cfset margPerc = RebateDollars / cost * 100 />
	</cfif>

	<!---If only one distributor get distributor information--->
	<cfif Number_Of_Operators IS 1>
		<cfquery name="GetOperatorIfOne" datasource="#application.datasource#">
		SELECT Operator_Name
		FROM BSA_Operator
			INNER JOIN Contract_Operators
			ON Contract_Operators.BSA_Operator_ID = BSA_Operator.BSA_Operator_ID
			AND Contract_Operators.Contract_Main_ID = '#GetInfo.Contract_Main_ID#'
			AND Contract_Operators.Deleted = 0
		WHERE BSA_Operator.Deleted = 0
		</cfquery>
	</cfif>
	
	<cf_cryp string="#GetInfo.Contract_Main_ID#" type="en" key="#request.key#">

	<TR <CFIF currentrow mod 2>BGCOLOR="ccffcc"<CFELSE>BGCOLOR="FFFFFF"</CFIF> VALIGN="TOP">

		<TD NOWRAP ALIGN="left">
			<!---filter for email and fax--->
			<cfif not ListFindNoCase("print,email,fax", url.command)>
				<CFSWITCH EXPRESSION="#GetInfo.Contract_Status_Type_IDX#">
					<CFCASE VALUE="1">
						<!--- WIP --->
						<IMG SRC="/images/wip.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
					</CFCASE>
					<CFCASE VALUE="2">
						<!--- Ready For Approval --->
						<IMG SRC="/images/rfa.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
					</CFCASE>
					<CFCASE VALUE="4">
						<!--- Preactive Programs --->
						<IMG SRC="/images/preactive.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
					</CFCASE>
					<CFCASE VALUE="5">
						<!--- Active Programs --->
						<IMG SRC="/images/active.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
					</CFCASE>
					<CFCASE VALUE="6">
						<!--- Expiring --->
						<CFSET diff=DATEDIFF("d", dateformat(now(), 'm/d/yyyy'), dateformat(Contract_End_Date, 'm/d/yyyy'))>
						<IMG SRC="/images/expiring.gif"<!--- ALT="Contract expires in #diff# days."---> onmouseover="initTheTooltip('')" onmouseout="popOut()">
					</CFCASE>
					<CFCASE VALUE="7">
						<!--- Archived/Expired --->
						<IMG SRC="/images/expired.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
					</CFCASE>
					<CFCASE VALUE="8">
					<!--- Rejected/Lost --->
					<IMG SRC="/images/not_allowed.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
				</CFCASE>																		
				</CFSWITCH>
			<cfelse>
				&nbsp;
			</cfif>
		</TD>						
		<!---Contract Information--->
		<TD NOWRAP>
			<CF_CRYP type="en" key="#request.key#" string="#GetInfo.contract_main_id#">
			<CFSET CID = cryp.value>
			<FONT SIZE="2" COLOR="Red"><B>[</B></FONT>
			#Contract_Number#
			<FONT SIZE="2" COLOR="Red"><B>]</B></FONT>
		</TD>
				
		<TD TITLE="#Contract_Title#">
			<cfset Title_Len = 50>
			<CFIF Contract_Reference_Number NEQ "">
				<CFSET Ref_Num_Len=len(Contract_Reference_Number) + 5>
			<CFELSE>
				<CFSET Ref_Num_Len=0>
			</CFIF>
			<CFIF Ref_Num_Len GTE Title_Len>
				<CFSET Title_Len=Ref_Num_Len+2>
			</CFIF>
			<CFSET display_Title=Left(Contract_Title,Title_Len-Ref_Num_Len)>
			<CFIF LEN(display_Title) LT Len(Contract_Title)>
				<CFSET display_Title="#display_Title#...">
			</CFIF>
			#display_Title#<CFIF Contract_Reference_Number NEQ "">&nbsp;( #Contract_Reference_Number# )</CFIF>
			<br>
			#Business_Unit_Desc#
		</TD>
		
		<td><cfif Number_of_Operators IS 1>#GetOperatorIfOne.Operator_Name#<cfelse>#Number_of_Operators#</cfif><Br> <Cfif GetInfo.Bid_Request_Status_ID IS 3>Won:&nbsp;#Won_Products#&nbsp;Lost:&nbsp;#Lost_Products#<cfelse>Products: #All_Products#</CFIF></td>
		
		<TD NOWRAP>
			#DateFormat(GetInfo.Contract_Start_Date,"mm/dd/yyyy")#<BR>#DateFormat(GetInfo.Contract_End_Date,"mm/dd/yyyy")#
		</TD>	
		<TD NOWRAP>
			#DateFormat(GetInfo.Date_Needed,"mm/dd/yyyy")#<BR>#DateFormat(GetInfo.Open_Date,"mm/dd/yyyy")#
		</TD>
		<TD NOWRAP ALIGN="left">						
			#GetInfo.Status_Desc#
		</TD>
		
<!--- 		<!---Per unit allowance--->
		<td align="right"><cfif isNumeric(TotalAllowance)>#lscurrencyformat(TotalAllowance)#<cfelse>N/A</cfif></td> --->
		
		<!---Quantity--->	
		<TD NOWRAP align="right">
			#numberformat(Contract_Quantity, '_,___,___,___,___')# #Abbreviation#&nbsp;
		</TD>
		<!---Quantity * price list--->
		<TD NOWRAP align="right">
			#lscurrencyformat(TotalRevenue)# &nbsp;
		</TD>
		
		<!---Quantity * fixed price offered--->
		<TD NOWRAP align="right">
			#lscurrencyformat(NetRevenue)#&nbsp;
		</TD>

		<!---Dollar committed--->
		<td align="right">#NumberFormat(margPerc, "_.__")#%</td>
		<td><cfif isNumeric(NetDollars)>#lscurrencyformat(TotalAllowance)#<cfelse>N/A</cfif></td>
		
	</tr>
</CFOUTPUT>

<!---Breaks down by business unit if there's more than one--->
<!--- <cfif businessSegmentsOn EQ 1>
	
	<cfset useLakebaseForHowManyBUs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getinfo")>
<cfif useLakebaseForHowManyBUs>
	<cftry>
		<cfset HowManyBUs = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getinfo", {
				"select" = "business_segment_id,business_unit_desc"
			}), "business_segment_id,business_unit_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForHowManyBUs = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForHowManyBUs>
<cfquery name="HowManyBUs" dbtype="query">
	SELECT DISTINCT Business_Segment_ID, Business_Unit_Desc FROM GetInfo
	</cfquery>
</cfif>
	
	<!---There's more than one business unit--->
	<cfif HowManyBUs.Recordcount GT 1>
	
	<cfoutput query="HowManyBUs">
	
		<!---Total won--->
		<cfquery name="BU_Won" dbtype="query">
		SELECT SUM(TotalAllowance) AS Amount_Won, SUM(TotalRevenue) AS Revenue_Won 
		FROM GetInfo 
		WHERE Business_Segment_ID = #Business_Segment_ID# 
		AND (Bid_Request_Status_ID  = 2 OR Bid_Request_Status_ID  = 3)
		AND TotalAllowance != 0
		</cfquery>
		
		<!---Total pending--->
		<cfquery name="BU_Pending" dbtype="query">
		SELECT SUM(TotalAllowance) AS Amount_Pending, SUM(TotalRevenue) AS Revenue_Pending FROM GetInfo WHERE Business_Segment_ID = #Business_Segment_ID# AND Bid_Request_Status_ID  = 1
		AND TotalAllowance != 0
		</cfquery>
		
		<cfif BU_Won.Recordcount GT 0>
			<cfset BUWon = BU_Won.Amount_Won>
			<cfset BURevenueWon = BU_Won.Revenue_Won>
		<cfelse>
			<cfset BUWon = 0>
			<cfset BURevenueWon = 0>
		</cfif>
				
		<cfif BU_Pending.Recordcount GT 0>
			<cfset BUPending = BU_Pending.Amount_Pending>
			<cfset BURevenuePending = BU_Pending.Revenue_Pending>
		<cfelse>
			<cfset BUPending = 0>
			<cfset BURevenuePending = BU_Pending.Revenue_Pending>
		</cfif>
		
		<cfif NOT isnumeric(BUWon)>
			<cfset BUWON = 0>
		</cfif>
		<cfif NOT isnumeric(BUPending)>
			<cfset BUPending = 0>
		</cfif>
		<cfif NOT isnumeric(BURevenueWon)>
			<cfset BURevenueWon = 0>
		</cfif>
		<cfif NOT isnumeric(BURevenuePending)>
			<cfset BURevenuePending = 0>
		</cfif>
						
		<cfset BUPossible = BUWon + BUPending>
		<cfset BUPossibleRevenue = BURevenueWon + BURevenuePending>
			
		<cfif BURevenuePending IS NOT 0>
			<cfset PendingPercent = (BUPending / BURevenuePending) * 100>
		<cfelse>
			<cfset PendingPercent = 0>
		</cfif>
		<cfif BURevenueWon IS NOT 0>
			<cfset WonPercent = (BUWon / BURevenueWon) * 100>
		<cfelse>
			<cfset WonPercent = 0>
		</cfif>
		
		
		<cfif BUPossibleRevenue IS NOT 0>
			<cfset PossiblePercent = (BUPossible / BUPossibleRevenue) * 100>
		<cfelse>
			<cfset PossiblePercent = 0>
		</cfif>
		
		<tr bgcolor="CCFFFF">
			<Td colspan="10">&nbsp; </TD>
			<td colspan="2"><strong>#Business_Unit_Desc#</strong></td>
		</tr>
		<tr>
			<Td colspan="10" align="right">Pending:<br>Committed:<br>Possible:</TD>
			<td colspan="1" align="right">#lscurrencyformat(BUPending)#<Br>#lscurrencyformat(BUWon)#<Br>#lscurrencyformat(BUPossible)#</td>
			<td colspan="1" align="right">#numberformat(PendingPercent, '___.__')#%<Br>#numberformat(WonPercent, '___.__')#%<Br>#numberformat(PossiblePercent, '___.__')#%

<!--- <p>Revenue</p>
Pending&nbsp; #BUPending# - #BURevenuePending#<Br>
Won&nbsp;#BURevenueWon#<br>
Possible&nbsp;#BUPossibleRevenue#<br> --->
</td>
		</tr>
		
	</cfoutput>	
		
		<!---Total Possible--->
	
		<tr><Td colspan="100%"><hr color="navy"></td></tr>
	</cfif>
</cfif> --->

<!---handle for class code if it's on --->
<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getClasscodesOn()>
	<cfquery name="qGetProductClassCode" datasource="#application.datasource#">
		SELECT	Class_Code.Class_Code_Desc,
				Class_Code.Class_Code_ID,
				Program_Bid_Request.Bid_Request_Status_ID,
				Program_Bid_Request_Product.Allowance,
				Program_Bid_Request_Product.Price,
				Program_Bid_Request_Product.UOM,
				Program_Bid_Request_Product.Won,
				DateDiff(d, Contract_Start_Date, Contract_End_Date) / 7 as Date_Span,
				CASE Program_Bid_Request_Product.UOM
					WHEN 1 THEN ISNULL(Program_Product_Volume.Volume_CS, 0)
					ELSE ISNULL(Program_Product_Volume.Volume_LB, 0)
					END AS Volume
		FROM	Contract_Main
				INNER JOIN Contract_Products ON
				Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
				AND Contract_Products.Deleted = 0
				INNER JOIN Program_Bid_Request_Product ON
				Program_Bid_Request_Product.Contract_Products_ID = Contract_Products.Contract_Products_ID
				AND Program_Bid_Request_Product.Deleted = 0
				INNER JOIN Program_Bid_Request ON
				Program_Bid_Request.Program_ID = Contract_Main.Contract_Main_ID
				AND Program_Bid_Request.Deleted = 0
				INNER JOIN BSA_Foodservice_Items_Master ON 
				BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
				AND BSA_Foodservice_Items_Master.Deleted = 0
				INNER JOIN Class_Code ON
				Class_Code.Class_Code_ID = BSA_Foodservice_Items_Master.Class_Code_ID
				AND Class_Code.Deleted = 0
				INNER JOIN Program_Product_Volume ON
				Program_Product_Volume.Program_ID = Contract_Main.Contract_Main_ID
				AND Program_Product_Volume.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
				AND Program_Product_Volume.Deleted = 0
		WHERE	Contract_Main.Deleted = 0
		AND		Contract_Main.Contract_Main_ID IN (#ProgramList#)
		
		GROUP BY 	Class_Code.Class_Code_ID,
					Class_Code.Class_Code_Desc,
					Program_Bid_Request.Bid_Request_Status_ID,
					Program_Bid_Request_Product.Allowance,
					Program_Bid_Request_Product.Price,
					Program_Bid_Request_Product.UOM,
					Program_Bid_Request_Product.Won,
					Contract_Main.Contract_Start_Date,
					Contract_Main.Contract_End_Date,
					Program_Product_Volume.Volume_CS,
					Program_Product_Volume.Volume_LB
	
	</cfquery>

	<!---group by class code--->
	<cfoutput query="qGetProductClassCode" group="Class_Code_ID">
		<!---get pending records--->
		<cfquery name="qGetPending" dbtype="query">
			SELECT	SUM(((Allowance + Price) * Volume) * Date_Span) as Pending,
					SUM(Allowance) as Pending_Allowance
			FROM	qGetProductClassCode
			WHERE	Class_Code_ID = #Class_Code_ID#
			AND		Bid_Request_Status_ID = 1
		</cfquery>
		<!---get committed records--->
		<cfquery name="qGetCommitted" dbtype="query">
			SELECT	SUM(((Allowance + Price) * Volume) * Date_Span) as Committed,
					SUM(Allowance) as Committed_Allowance
			FROM	qGetProductClassCode
			WHERE	Class_Code_ID = #Class_Code_ID#
			AND		Bid_Request_Status_ID IN (2,3)
			AND		Won = 1
		</cfquery>
		
		<cfset pending = Val(qGetPending.Pending) />
		<cfset committed = Val(qGetCommitted.Committed)  />
		<cfset possible = committed + pending />
		<!---handle for dividing by zero--->
		<cfif pending>
			<cfset pendingPerc = (Val(qGetPending.Pending_Allowance) / Val(pending)) * 100 />
		<cfelse>
			<cfset pendingPerc = 0 />
		</cfif>
		<cfif committed>
			<cfset committedPerc = (Val(qGetCommitted.Committed_Allowance) / Val(committed)) * 100 />
		<cfelse>
			<cfset committedPerc = 0  />
		</cfif>
		<cfif possible and committed>
			<cfset possiblePerc = possible / committed />
		<cfelse>
			<cfset possiblePerc = 0  />
		</cfif>
		<tr bgcolor="CCFFFF">
			<Td colspan="10">&nbsp;</TD>
			<td colspan="2"><strong>#Class_Code_Desc#</strong></td>
		</tr>
		<tr>
			<Td colspan="10" align="right">Pending:<br>Committed:<br>Possible:</TD>
			<td colspan="1" align="right">#lscurrencyformat(pending)#<Br>#lscurrencyformat(committed)#<Br>#lscurrencyformat(possible)#</td>
			<td colspan="1" align="right">#numberformat(pendingPerc, '___.__')#%<Br>#numberformat(committedPerc, '___.__')#%<Br>#numberformat(possiblePerc, '___.__')#%</td>
		</tr>
		
	</cfoutput>
</cfif><!---end class code--->

<!---Total won--->
		<cfquery name="Total_Won" dbtype="query">
		SELECT SUM(TotalAllowance) AS Amount_Won, SUM(TotalRevenue) AS Revenue_Won 
		FROM GetInfo 
		WHERE (Bid_Request_Status_ID  = 2 OR Bid_Request_Status_ID  = 3)
		AND TotalAllowance != 0
		</cfquery>
		
		<!---Total pending--->
		<cfquery name="Total_Pending" dbtype="query">
		SELECT SUM(TotalAllowance) AS Amount_Pending, SUM(TotalRevenue) AS Revenue_Pending 
		FROM GetInfo WHERE  Bid_Request_Status_ID  = 1
		AND TotalAllowance != 0
		</cfquery>
		
		<cfif Total_Won.Recordcount GT 0>
			<cfset TotalWon = Total_Won.Amount_Won>
			<cfset TotalRevenueWon = Total_Won.Revenue_Won>
		<cfelse>
			<cfset TotalWon = 0>
			<cfset TotalRevenueWon = 0>
		</cfif>
				
		<cfif Total_Pending.Recordcount GT 0>
			<cfset TotalPending = Total_Pending.Amount_Pending>
			<cfset TotalRevenuePending = Total_Pending.Revenue_Pending>
		<cfelse>
			<cfset TotalPending = 0>
			<cfset TotalRevenuePending = Total_Pending.Revenue_Pending>
		</cfif>
		
		<!---Makes sure everything is numeric before adding--->
		
		<cfif NOT isNumeric(TotalWon)>
			<Cfset TotalWon = 0>
		</cfif>
		<cfif NOT isNumeric(TotalPending)>
			<Cfset TotalPending = 0>
		</cfif>
		<cfif NOT isNumeric(TotalRevenueWon)>
			<Cfset TotalRevenueWon = 0>
		</cfif>
		<cfif NOT isNumeric(TotalRevenuePending)>
			<Cfset TotalRevenuePending = 0>
		</cfif>
		
		<cfset TotalPossible = TotalWon + TotalPending>
		<cfset TotalPossibleRevenue = TotalRevenueWon + TotalRevenuePending>
				
		
		<cfif TotalRevenuePending IS NOT 0>
			<cfset TotalPendingPercent = (TotalPending / TotalRevenuePending) * 100>
		<cfelse>
			<cfset TotalPendingPercent = 0>
		</cfif>
		<cfif TotalRevenueWon IS NOT 0>
			<cfset TotalWonPercent = (TotalWon / TotalRevenueWon) * 100>
		<cfelse>
			<cfset TotalWonPercent = 0>
		</cfif>
		<cfif TotalPossibleRevenue IS NOT 0>
			<cfset TotalPossiblePercent = (TotalPossible / TotalPossibleRevenue) * 100>
		<cfelse>
			<cfset TotalPossiblePercent = 0>
		</cfif>
<cfoutput>
	<tr>
		<Td colspan="10" align="right" class="tableheaders">&nbsp;Total awarded:</td>
		<td colspan="1" align="right" class="tableheaders">#LSCurrencyFormat(TotalWon)#</td>
		<td colspan="1" align="right" class="tableheaders">#numberformat(TotalWonPercent, '___.__')#%</td>
	</tr>
	<tr>
		<Td colspan="10" align="right" class="tableheaders">&nbsp;Total pending:</td>
		<td colspan="1" align="right" class="tableheaders">#LSCurrencyFormat(TotalPending)#</td>
		<td colspan="1" align="right" class="tableheaders">#numberformat(TotalPendingPercent, '___.__')#%</td>
	</tr>
	<tr>
		<Td colspan="10" align="right" class="tableheaders">&nbsp;Total possible:</td>
		<td colspan="1" align="right" class="tableheaders">#LSCurrencyFormat(TotalAccrual)#</td>
		<td colspan="1" align="right" class="tableheaders">#numberformat(TotalPossiblePercent, '___.__')#%</td>
	</tr>
</cfoutput>
</TABLE>

<cfoutput>
<cfif not ListFindNoCase("print,email,fax", url.command)>

<FONT SIZE="2">
	<B><FONT COLOR="FF0000">[</FONT><a href="javascript:window.close();"> close </a><FONT COLOR="FF0000">]</FONT></B>
</FONT>
<br><br>

<table>
	<tr>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"print"
				button_action	=	"window.location.href='index.cfm?#cgi.QUERY_STRING#&command=print'"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	"Print page"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>				
		</TD>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"email"
				button_action	=	"window.location.href='email_fax.cfm?#cgi.QUERY_STRING#&command=email'"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	"Prepare an email contents"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>				
		</TD>
	<!--- DEV NOTE: DAA; D15409    REMOVE FAX LINK
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"fax"
				button_action	=	"window.location.href='email_fax.cfm?#cgi.QUERY_STRING#&command=fax'"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	"Prepare the contents of a fax to be sent"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>				
		</TD>
	 --->
	</tr>
</table>
</cfif>

</cfoutput>

</BODY>
</HTML>