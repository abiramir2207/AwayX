
<STYLE>
TABLE.UNUNDERLINED TD 
{
	border-bottom:none; 
}
</STYLE>
<cfsilent>

<CFQUERY NAME="GetARDetails3" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT 	Billback_Program.A_R,
							Billback_Program.AR_From_Fiscal_Year
										
	FROM 		Billback_Program 
	<!--- 
	INNER JOIN 	Contract_Main ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
	INNER JOIN 	Program_Latest_Template_ID ON Program_Latest_Template_ID.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
	INNER JOIN 	Program_Control_Panel_Options aaa ON aaa.ProgramControl_Panel_Options_ID = Program_Latest_Template_ID.Latest
	 --->
	WHERE 		Billback_ID = '#Billback_ID#' AND Billback_Program.Deleted = 0 AND
				(Billback_Program.Allocation_Method = 3 OR ISNULL(Billback_Program.LumpSum_Amt,0) <> 0)
	ORDER BY 	Billback_Program.AR_From_Fiscal_Year,Billback_Program.A_R
</CFQUERY>

<CFQUERY NAME="CheckSaved" DATASOURCE="#Application.Datasource#">
	SELECT Top 1 *
	FROM GL_Code_Allocation
	WHERE Billback_ID = '#Billback_ID#' AND
			Allocation_Method = 3 AND
			Deleted = 0
</CFQUERY>
</cfsilent>
<CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center" CLASS="UNDERLINED" WIDTH="700" ID="ForToolTip">
<FORM NAME="FundSave" ACTION="Display_Fund_Allocation_Action.cfm" METHOD="POST">
<CFIF IsDefined("Deduction_ID")>
	<INPUT TYPE="Hidden" NAME="Deduction_ID" VALUE="#Deduction_ID#">
</CFIF>
<INPUT TYPE="Hidden" NAME="Billback_ID" VALUE="#Billback_ID#">
<INPUT TYPE="Hidden" NAME="FundSubmit" VALUE="1">
	<tr bgcolor="04AE7B">
		<TD COLSPAN="3"><B><FONT SIZE="2" COLOR="Navy">FUND ALLOCATION:</FONT></B></TD>
		<TD ALIGN="Right">
			<CFIF CheckSaved.RecordCount GT 0>
				<B><FONT SIZE="2" COLOR="Red">[ </FONT><CFIF IsDefined("Deduction_ID")><A HREF="Allocation_Layout.cfm?Billback_ID=#Billback_ID#&Deduction_ID=#Deduction_ID#">Back to allocation summary</A><CFELSE><A HREF="Allocation_Layout.cfm?Billback_ID=#Billback_ID#">Back to allocation summary</A></CFIF><FONT SIZE="2" COLOR="Red"> ]</FONT></B>&nbsp;&nbsp;
			<CFELSE>
				&nbsp;&nbsp;
			</CFIF>
		</TD>
	</TR>

	<CFSET ThisRecordCount = 0>
	<CFLOOP QUERY="GetARDetails3">
		<cfsilent>
		<CFSET ThisRecordCount = ThisRecordCount + 1>
		<CFQUERY NAME="GetProgramForEachAR3" DATASOURCE="#Application.Datasource#">
			SELECT 		Billback_Program.Program_ID
			FROM 		Billback_Program 
			<!--- 
			INNER JOIN 	Contract_Main ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
			INNER JOIN 	Program_Latest_Template_ID ON Program_Latest_Template_ID.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
			INNER JOIN 	Program_Control_Panel_Options aaa ON aaa.ProgramControl_Panel_Options_ID = Program_Latest_Template_ID.Latest 
			 --->
			WHERE 		Billback_ID = '#Billback_ID#' AND 
						Billback_Program.A_R = '#A_R#' AND 
						Billback_Program.AR_From_Fiscal_Year = '#AR_From_Fiscal_Year#' AND 
						(Billback_Program.Allocation_Method = 3  OR ISNULL(Billback_Program.LumpSum_Amt,0) <> 0)AND
						Billback_Program.Deleted = 0
		</CFQUERY>
		<CFSET Program_List = VALUELIST(GetProgramForEachAR3.Program_ID)>

		<CFQUERY NAME="DistinctARFYFund" DATASOURCE="#Application.Datasource#">
			SELECT 		DISTINCT	GL_Code_Fixed_Fund_Allocation_Cal.A_R,
									GL_Code_Fixed_Fund_Allocation_Cal.Fiscal_Year,
									GL_Code_Activation.A_R_DESCRIPTION
									
			FROM 		GL_Code_Fixed_Fund_Allocation_Cal 
			
			INNER JOIN 	GL_Code_Activation ON GL_Code_Activation.A_R = GL_Code_Fixed_Fund_Allocation_Cal.A_R AND
						GL_Code_Activation.Fiscal_Year = GL_Code_Fixed_Fund_Allocation_Cal.Fiscal_year AND
						GL_Code_Activation.Current_Active_Data = 1 AND
						GL_Code_Activation.Deleted = 0
						
			WHERE 		Billback_ID = '#Billback_ID#' AND 
						Program_ID IN (#Program_List#) AND 
						Allocation_Method = 3 AND
						GL_Code_Fixed_Fund_Allocation_Cal.Deleted = 0
			ORDER BY 	GL_Code_Fixed_Fund_Allocation_Cal.Fiscal_Year,GL_Code_Fixed_Fund_Allocation_Cal.A_R
		</CFQUERY>
		</cfsilent>
		<CFLOOP QUERY="DistinctARFYFund">			
			<TR>
				<TD COLSPAN="100%" STYLE="border-bottom: none">
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
						<TR>
							<TD STYLE="border-bottom: none">
								<B>A_R:</B><BR>
								<B>Fiscal_Year:</B>&nbsp;&nbsp;
							</TD>		
							<TD STYLE="border-bottom: none">
								#A_R# - #A_R_DESCRIPTION#<BR>
								#Fiscal_Year#
							</TD>				
						</TR>				
					</TABLE>
				</TD>
			</TR>
			<cfsilent>
			<CFQUERY NAME="GetProgramsFund" DATASOURCE="#Application.Datasource#">
				SELECT 	DISTINCT Program_ID
				FROM	GL_Code_Fixed_Fund_Allocation_Cal
				WHERE 	Billback_ID = '#Billback_ID#' AND 
						Program_ID IN (#Program_List#) AND 
						Allocation_Method = 3 AND
						A_R = '#A_R#' AND
						Fiscal_Year = '#Fiscal_Year#' AND
						Deleted = 0
			</CFQUERY>
		
			<CFSET SameARProgs = VALUELIST(GetProgramsFund.Program_ID)>
			<CFSET AppendVar = VALUELIST(GetProgramsFund.Program_ID,"_")>
			<CFIF Not IsDefined("AppendVar_List")>
				<CFSET AppendVar_List = TRIM(AppendVar)>
			<CFELSE>
				<CFSET AppendVar_List = "#AppendVar_List#,#TRIM(AppendVar)#">
			</CFIF>		
			<CFSET DistAR = A_R>
			<CFSET DISTFY = Fiscal_Year>		
			<CFSET TotBBAmountFund = 0>
			
			<CFQUERY NAME="ProgramDetailsForFund" DATASOURCE="#Application.Datasource#">
				SELECT 		DISTINCT Contract_Title,Contract_Number
				FROM 		Contract_Main 
				WHERE		Contract_Main_ID IN (#SameARProgs#)
			</CFQUERY>
			
			<CFLOOP QUERY="GetProgramsFund">
				<CFQUERY NAME="GetBBAmountFund" DATASOURCE="#Application.Datasource#">
					SELECT 	Top 1 * 
					FROM 	GL_Code_Fixed_Fund_Allocation_Cal
					WHERE 	Billback_ID = '#Billback_ID#' AND 
							Program_ID = #Program_ID# AND 
							Allocation_Method = 3 AND
							A_R = '#DistAR#' AND
							Fiscal_Year = '#DISTFY#' AND
							Deleted = 0
				</CFQUERY>
				
				<CFSET TotBBAmountFund = TotBBAmountFund + GetBBAmountFund.Approved_Amount>

			</CFLOOP>
			</cfsilent>
			<INPUT TYPE="Hidden" NAME="TotAmountOF_#AppendVar#" VALUE="#TotBBAmountFund#">
			<TR>
				<TD COLSPAN="100%" STYLE="border-bottom: none">
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">					
						<TR BGCOLOR="FFE083">
							<TD><B>Program ##</B></TD>
							<TD><B>Program Title</B></TD>						
						</TR>
						<CFLOOP QUERY="ProgramDetailsForFund">
						<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
							<TD><B>#Contract_Number#</B></TD>
							<TD>#Contract_Title#</TD>						
						</TR>
						</CFLOOP>
						<TR >
							<TD STYLE="border-bottom: none" <CFOUTPUT>ID="TotalStatus_#AppendVar#</CFOUTPUT>"></TD>
							<TD ALIGN="Right" STYLE="border-bottom: none"><B><FONT COLOR="Red" SIZE="2">Total Amount to be Fund Allocated: #DollarFormat(TotBBAmountFund)#</FONT></B></TD>
						</TR>
					</TABLE>
				</TD>
			</TR>
			
			<TR BGCOLOR="FFE083">	
				<TD><B>Fund</B></TD>
				<TD><B>Fund Description</B></TD>		
				<TD><B>SCOA</B></TD>				
				<TD><B>$ Amount</B></TD>
			</TR>
			<cfsilent>
			<CFQUERY NAME="FundDistinctFund" DATASOURCE="#Application.Datasource#">
				Create Table ##Temp_LS_Products
				(Product_ID uniqueidentifier NULL)

				INSERT INTO ##Temp_LS_Products (Product_ID)
				select 	product_id 
				from billback_product 
				where billback_id = '#Billback_ID#' and 
				billback_product.deleted = 0 

				IF (SELECT Count(*) FROM ##Temp_LS_Products) = 0
				BEGIN
					INSERT INTO ##Temp_LS_Products (Product_ID)
					select 		BSA_Foodservice_Items_Master_ID 
					From 		PROGRAM_LUMP_SUM_PRODUCT_DATA 
					inner join 	BILLBACK_PROGRAM_LUMPSUM_COMPONENT on BILLBACK_PROGRAM_LUMPSUM_COMPONENT.PROGRAM_LUMP_SUM_ID = PROGRAM_LUMP_SUM_PRODUCT_DATA.PROGRAM_LUMP_SUM_ID 
					inner join 	CONTRACT_PRODUCTS on CONTRACT_PRODUCTS.CONTRACT_PRODUCTS_ID = PROGRAM_LUMP_SUM_PRODUCT_DATA.CONTRACT_PRODUCTS_ID AND 
								billback_id = '#Billback_ID#'
				END
				
				
				IF (SELECT Count(*) FROM ##Temp_LS_Products) = 0
				BEGIN
					INSERT INTO ##Temp_LS_Products (Product_ID)
					select 	BSA_Foodservice_Items_Master_ID 
					from 	contract_products 
					/*inner join billback_program on 
					Contract_products.contract_main_id = billback_program.program_id */
					WHERE 	--billback_id = '#Billback_ID#' AND 
							Contract_products.contract_main_id IN (#SameARProgs#) AND
							contract_products.product_type_id = 3 and 
							Contract_products.deleted = 0
				END
				
				IF (SELECT Count(*) FROM ##Temp_LS_Products) = 0
				BEGIN
					INSERT INTO ##Temp_LS_Products (Product_ID)
					select 	BSA_Foodservice_Items_Master_ID 
					from 	contract_products 
					--inner join billback_program on Contract_products.contract_main_id = billback_program.program_id AND
					WHERE	Contract_products.contract_main_id IN (#SameARProgs#) AND
							--billback_id = '#Billback_ID#' and 
							Contract_products.deleted = 0
				END
				
				Create Table ##Temp_LS_Fund_Number
				(Fund_Number varchar(50) NOT NULL)
				
				INSERT INTO ##Temp_LS_Fund_Number (Fund_Number)
				SELECT 		DISTINCT Fund_Number FROM ##Temp_LS_Products
				INNER JOIN 	bsa_foodservice_items_master ON bsa_foodservice_items_master.bsa_foodservice_items_master_ID = ##Temp_LS_Products.Product_ID
				INNER JOIN 	GL_CODE_PRO_GROUP_MAPPING ON GL_CODE_PRO_GROUP_MAPPING.PROD_GRP = bsa_foodservice_items_master.PROD_GRP AND
							GL_CODE_PRO_GROUP_MAPPING.DELETED = 0 AND
							GL_CODE_PRO_GROUP_MAPPING.Fiscal_Year = '#DISTFY#' AND
							GL_CODE_PRO_GROUP_MAPPING.Active_Data = 1 
				INNER JOIN 	GL_Code_Activation ON GL_CODE_ACTIVATION.PRODUCT_GROUP = GL_CODE_PRO_GROUP_MAPPING.PREF_PROD_GRP AND
							GL_Code_Activation.Current_Active_Data = 1 AND 
							GL_Code_Activation.deleted = 0 AND 
							GL_Code_Activation.Fiscal_Year = '#DISTFY#' AND 
							GL_Code_Activation.A_R = '#DistAR#' AND GL_Code_Activation.Fund_Number IS NOT NULL
				
				
				SELECT 		DISTINCT GL_Code_Fixed_Fund_Allocation_Cal.Fund_Number 
				FROM 		GL_Code_Fixed_Fund_Allocation_Cal 
				INNER JOIN 	##Temp_LS_Fund_Number ON ##Temp_LS_Fund_Number.Fund_Number = GL_Code_Fixed_Fund_Allocation_Cal.Fund_Number AND
							GL_Code_Fixed_Fund_Allocation_Cal.Billback_ID = '#Billback_ID#' AND
							GL_Code_Fixed_Fund_Allocation_Cal.Program_ID IN (#SameARProgs#) AND 
							GL_Code_Fixed_Fund_Allocation_Cal.Allocation_Method = 3 AND 
							GL_Code_Fixed_Fund_Allocation_Cal.A_R = '#DistAR#' AND 
							GL_Code_Fixed_Fund_Allocation_Cal.Fiscal_Year = '#DISTFY#' AND 
							GL_Code_Fixed_Fund_Allocation_Cal.Deleted = 0
				
				
				DROP TABLE ##Temp_LS_Products
				DROP TABLE ##Temp_LS_Fund_Number
			</CFQUERY>
			<CFSET FundNumber_List = VALUELIST(FundDistinctFund.Fund_Number)>
			</cfsilent>
			<INPUT TYPE="Hidden" NAME="Fund_List_Input_#AppendVar#" VALUE="#FundNumber_List#">
			<CFSET CheckPercentTot = 0>
			<CFLOOP QUERY="FundDistinctFund">				
			<cfsilent>
				<CFQUERY NAME="GetARFund" DATASOURCE="#Application.Datasource#">
					SELECT 		*											
					
					FROM GL_Code_Activation
								
					WHERE 		A_R = '#DistAR#' AND
								Fiscal_Year = '#DISTFY#' AND
								Fund_Number = '#Fund_Number#' AND
								Current_Active_Data = 1 AND
								deleted = 0
				</CFQUERY>
				<CFQUERY NAME="GetSavedAlloc" DATASOURCE="#Application.Datasource#">
					SELECT  SUM(ISNULL(Allocated_Amount,0)) AS Allocated_Fund_Amount
					FROM Gl_Code_Allocation 
					WHERE Billback_ID = '#Billback_ID#' AND
						DELETED = 0 AND
						ISNULL(Allocated_Amount,0) > 0 AND
						Fund_Number = '#Fund_Number#'
				</CFQUERY>
			</cfsilent>	
				<cfif getarfund.recordcount NEQ 0>
					<CFSET SOCA_Fund = "#GetARFund.COMPANY#-#GetARFund.LOCATION#-#GetARFund.COST_CENTER#-#GetARFund.NATURAL_ACCT#-#GetARFund.CHANNEL#-#GetARFund.PRODUCT_GROUP#-#GetARFund.FUND_NUMBER#">
					<cfif GetSavedAlloc.Allocated_Fund_Amount EQ 0>
						<cfset fundAmount = ''/>
					<cfelse>
						<cfset fundAmount = GetSavedAlloc.Allocated_Fund_Amount/>
					</cfif>
					<!--- #CurrentRow# TotBBAmountFund - #TotBBAmountFund#; SOCA_Fund - #SOCA_Fund#; Fund_Number - #Fund_Number#; A_R - #DistAR#; FIscal_Year - #DISTFY# <BR><BR> --->			
					<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">				
						<TD>#Fund_Number#</TD> <!--- ONMOUSEOVER="Javascript: ToolTip(#CurrentRow#,'#AppendVar#','#ThisRecordCount#')" --->
						<TD>#GetARFund.Description#</TD>
						<TD>#SOCA_Fund#</TD><!--- ONMOUSEOVER="Javascript: ToolTip(#CurrentRow#,'#AppendVar#','#ThisRecordCount#')" --->					
						<TD><INPUT TYPE="TEXT" NAME="Allocated_Amount_For_#AppendVar#_#Fund_Number#" SIZE="10" ONKEYUP="Javascript: clenseText(this,'-.0123456789'); SumUp();" value="#fundAmount#"></TD> <!--- ONMOUSEOVER="Javascript: ToolTip(#CurrentRow#,'#AppendVar#','#ThisRecordCount#')" --->
					</TR>
				</cfif>
			</CFLOOP>		
			<TR>
				<TD COLSPAN="2" STYLE="border-bottom: none" ID="TotalStatus2_#AppendVar#"></TD>
				<TD ALIGN="Right" STYLE="border-bottom: none"><B>Total:</B><span id="error_Total_#AppendVar#"></span></TD>
				<TD STYLE="border-bottom: none" ID="DispTot_#AppendVar#"><B></B></TD>
			</TR>
		</CFLOOP>
		<TR>
			<TD COLSPAN="100%"><HR COLOR="Navy"></TD>
		</TR>
	</CFLOOP>
	<INPUT TYPE="Hidden" NAME="Program_List_Input" VALUE="#AppendVar_List#">
	<TR>
		<TD COLSPAN="4" STYLE="border-bottom: none" ALIGN="Right">
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" CLASS="UNUNDERLINED">
				<TR>
					<TD>
						<CF_button
							button_name	=	""
							button_caption	=	"save fund allocation"
							button_action	=	"CheckSumSubmit()"
							button_type		=	"javascript_link"
							button_width	=	"150"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
										>
					</TD>
				</TR>
			</TABLE>	
		</TD>			
	</TR>		
	
</FORM>
</TABLE>
</CFOUTPUT>

<SCRIPT LANGUAGE="JavaScript" SRC="../../script/javascript/string_functions.js"></SCRIPT>

<SCRIPT language="JavaScript">
function SumUp()
{ 	
	var FundList = "<CFOUTPUT>#FundNumber_List#</CFOUTPUT>";
	var ActualTot = "<CFOUTPUT>#TotBBAmountFund#</CFOUTPUT>";
	var varAppend = "<CFOUTPUT>#AppendVar_List#</CFOUTPUT>";
	var holdDiff;
	var FundNo; 	
	var progTot;
	var totAmount = 0;
	var FundArray = new Array();
	var vAppArray = new Array();	
	FundArray = FundList.split(",");
	vAppArray = varAppend.split(",");
	
	for (i=0; i<vAppArray.length; i++)
	{
		progTot = 0;
		totAmount = 0;
		progTot = eval("document.all.TotAmountOF_"+vAppArray[i]+".value");		
		for (j=0; j<FundArray.length; j++)
		{				
			FundNo = eval("document.all.Allocated_Amount_For_"+vAppArray[i]+"_"+FundArray[j]+".value");
			//alert(FundNo)
			if (FundNo != "" && FundNo != 0)
			{
				totAmount = totAmount + parseFloat(FundNo);			
				//alert(totAmount)
			}	
			//alert()	
		}
		totAmount = Math.round(totAmount*100)/100;
		progTot = Math.round(progTot*100)/100;
		TDObj = eval("document.all.DispTot_"+vAppArray[i]);
		StatusTDObj = eval("document.all.TotalStatus_"+vAppArray[i]);
		StatusTDObj2 = eval("document.all.TotalStatus2_"+vAppArray[i]);		
		TDObj.innerHTML = "<B>$ " + totAmount + "</B>";			
		if (totAmount < progTot)
		{						
			holdDiff = progTot - totAmount;
			holdDiff = Math.round(holdDiff*100)/100;
			StatusTDObj.innerHTML = "<B>ADD&nbsp;&nbsp;&nbsp;&nbsp; $ " + holdDiff + "</B>";	
			StatusTDObj.style.color = "E600FF";
			StatusTDObj2.innerHTML = "<B>ADD&nbsp;&nbsp;&nbsp;&nbsp; $ " + holdDiff + "</B>";	
			StatusTDObj2.style.color = "E600FF";
		}	
		else if (totAmount > progTot)
		{
			holdDiff = totAmount - progTot;		
			holdDiff = Math.round(holdDiff*100)/100;
			StatusTDObj.innerHTML = "<B>SUBTRACT&nbsp;&nbsp;&nbsp;&nbsp; $ " + holdDiff + "</B>";	
			StatusTDObj.style.color = "E600FF";
			StatusTDObj2.innerHTML = "<B>SUBRACT&nbsp;&nbsp;&nbsp;&nbsp; $ " + holdDiff + "</B>";	
			StatusTDObj2.style.color = "E600FF";
		}
		else if (totAmount = progTot)
		{
			StatusTDObj.innerHTML = "";
			StatusTDObj2.innerHTML = "";
		}
	}	
}

// Fix this
/*function ToolTip(rowNumber,varAppend,listIndex)
{
	
	var addPreviousRow = rowNumber + 4;
	var trObj = document.all.ForToolTip.rows[addPreviousRow];	
	var trTitle = "";		
	//commonFuncToFindTot();
	var FundList = "<CFOUTPUT>#FundNumber_List#</CFOUTPUT>";
	var ActualTot = "<CFOUTPUT>#TotBBAmountFund#</CFOUTPUT>";
	var holdDiff;
	var totAmount = 0;
	var FundArray = new Array();
	var FundNo; 
	FundArray = FundList.split(",");
		
	for (i=0; i<FundArray.length; i++)
	{				
		FundNo = eval("document.all.Allocated_Amount_For_"+FundArray[i]+".value");
		if (FundNo != "" && FundNo != 0)
		{
			totAmount = totAmount + parseFloat(FundNo);			
		}		
	} 
	if (totAmount < ActualTot)
	{
		holdDiff = ActualTot - totAmount;
		trTitle = "ADD: $"+holdDiff;		
	}	
	else if (totAmount > ActualTot)
	{
		holdDiff = totAmount - ActualTot;	
		trTitle = "SUBRACT: $"+holdDiff;	
	}
	else if (totAmount = ActualTot)
	{
		trTitle = "";
	}	
	trObj.title = trTitle;	
}*/

function CheckSumSubmit()
{
	var submit_ok = 1;
	var FundList = "<CFOUTPUT>#FundNumber_List#</CFOUTPUT>";
	var ActualTot = "<CFOUTPUT>#TotBBAmountFund#</CFOUTPUT>";
	var varAppend = "<CFOUTPUT>#AppendVar_List#</CFOUTPUT>";
	var holdDiff;
	var FundNo;
	var totAmount = 0;
	var ErrorCount = 0;
	var FundArray = new Array();	
	var vAppArray = new Array();	 	
	FundArray = FundList.split(",");
	vAppArray = varAppend.split(",");
		
	for (i=0; i<vAppArray.length; i++)
	{
		progTot = 0;
		totAmount = 0;
		progTot = eval("document.all.TotAmountOF_"+vAppArray[i]+".value");		
		for (j=0; j<FundArray.length; j++)
		{				
			FundNo = eval("document.all.Allocated_Amount_For_"+vAppArray[i]+"_"+FundArray[j]+".value");
			//alert(FundNo)
			if (FundNo != "" && FundNo != 0)
			{
				totAmount = totAmount + parseFloat(FundNo);			
				//alert(totAmount)
			}	
			//alert()	
		} 
		totAmount = Math.round(totAmount*100)/100;
		progTot = Math.round(progTot*100)/100;
		error_oSpan = eval("document.all.error_Total_"+vAppArray[i]);
		if (totAmount < progTot)
		{
			holdDiff = progTot - totAmount;
			holdDiff = Math.round(holdDiff*100)/100;
			ErrorCount++;
			error_text = "Please add $"+ holdDiff;							
			queueMessage(error_text, error_oSpan);			
			submit_ok = 0;		
		}	
		else if (totAmount > progTot)
		{
			holdDiff = totAmount - progTot;		
			holdDiff = Math.round(holdDiff*100)/100;
			ErrorCount++;
			error_text = "Please subtract $"+ holdDiff;						
			queueMessage(error_text, error_oSpan);	
			//alert("Please subtract $"+ holdDiff + " and try again.");
			submit_ok = 0;
		}
		else
		{
			clearQueue(error_oSpan);
		}
	}
	if (submit_ok == 1)
	{
		document.all.FundSave.submit()
	}
	else
	{
		showMessageWindow()
	}
}
</SCRIPT> 
<CF_MessageWindow>
<script>
	try { window.parent.dyniframesize(); } catch (err) { };
</script>