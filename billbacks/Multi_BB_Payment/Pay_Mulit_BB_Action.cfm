



<CFQUERY NAME="UNLockBBNotInFinalBB" DATASOURCE="#Application.Datasource#">
	UPDATE 	Billback_Allied
	
	SET		BB_Is_Locked = 0,
			BB_Locked_By_User_ID = NULL
			
	WHERE	Billback_ID NOT IN (#LISTQUALIFY(FORM.Billback_ID,"'",",","All")#) AND
			BB_Locked_By_User_ID = '#request.AccessStructure.User_ID#' AND
			BB_Is_Locked = 1
			AND BB_Locked_By_Match_Central = 0
</CFQUERY> 

<CFQUERY NAME="Insert_Master" DATASOURCE="#Application.Datasource#">
	INSERT INTO 
	
	Pay_Multi_Billbacks	(	<CFIF FORM.PayeeType EQ 1>
								Distributor_ID
							<CFELSEIF FORM.PayeeType EQ 2>
								Operator_ID
							<CFELSEIF FORM.PayeeType EQ 3>
								Broker_ID
							</CFIF>,
							Billback_Payee_Type_ID,
							Created_By					)		
	
	VALUES				(	<CFIF FORM.PayeeType EQ 1>
								'#FORM.Distributor_List#'
							<CFELSEIF FORM.PayeeType EQ 2>
								'#FORM.Operator_List#'
							<CFELSEIF FORM.PayeeType EQ 3>
								'#FORM.Broker_List#'
							</CFIF>,
							#FORM.PayeeType#,
							'#request.AccessStructure.User_ID#'	)					
</CFQUERY>

<CFQUERY NAME="GetID" DATASOURCE="#Application.Datasource#">
	SELECT 	MAX(Pay_Multi_Billbacks_ID) Pay_Multi_Billbacks_ID
	
	FROM	Pay_Multi_Billbacks

	WHERE 	Created_By = '#request.AccessStructure.User_ID#' AND
			<CFIF FORM.PayeeType EQ 1>
				Distributor_ID = '#FORM.Distributor_List#'
			<CFELSEIF FORM.PayeeType EQ 2>
				Operator_ID = '#FORM.Operator_List#'
			<CFELSEIF FORM.PayeeType EQ 3>
				Broker_ID = '#FORM.Broker_List#'
			</CFIF>AND
			Deleted = 0
</CFQUERY>

<CFSET PayMultiBillbacksID = GetID.Pay_Multi_Billbacks_ID>


<CFSET UnSuccessBB = "">
<CFSET SUMBBAmount = 0>
<CFSET UnSuccessCount = 0>
<CFLOOP LIST="#FORM.FinalBB#" INDEX="Item">	
	<CFSET BBAmount = 0>
	
	<CFQUERY NAME="GetBBAmount" DATASOURCE="#Application.Datasource#">
		SELECT 		BB_Approved.*,
					BB_Is_Locked,
					BB_Locked_By_User_ID,
					BB_Code
					 
		FROM 		BB_Approved 
		
		INNER JOIN	Billback_Allied ON Billback_Allied.Billback_ID = BB_Approved.Billback_ID
		INNER JOIN	Billback ON Billback.Billback_ID = BB_Approved.Billback_ID
		
		WHERE 		BB_Approved.Billback_ID = '#Item#'
	</CFQUERY>
	
	
	<CFIF GetBBAmount.BB_Is_Locked EQ 0 OR (GetBBAmount.BB_Is_Locked EQ 1 AND GetBBAmount.BB_Locked_By_User_ID EQ request.AccessStructure.User_ID)>
		
		<CFQUERY NAME="LockBB" DATASOURCE="#Application.Datasource#">
			UPDATE 	Billback_Allied
			
			SET 	BB_Is_Locked = 1,
					BB_Locked_By_User_ID = '#request.AccessStructure.User_ID#',
					BB_Lock_Date = #now()#
					
			WHERE 	Billback_ID = '#Item#'
		</CFQUERY>
		
		<CFSET BBPaidAmount = GetBBAmount.Paid_Amount>
		<CFSET SUMBBAmount = SUMBBAmount + BBPaidAmount>
		<cfset useLakebaseForInsert_List = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pay_multi_billbacks_list")>
<cfif useLakebaseForInsert_List>
	<cftry>
		<cfset application.oLakebase.insertRow("pay_multi_billbacks_list", {
			"pay_multi_billbacks_id" = "#PayMultiBillbacksID#",
			"billback_id" = "#Item#",
			"paid_amount" = "#BBPaidAmount#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsert_List = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsert_List>
<CFQUERY NAME="Insert_List" DATASOURCE="#Application.Datasource#">
			INSERT INTO 
			
			Pay_Multi_Billbacks_List	(	Pay_Multi_Billbacks_ID,
											Billback_ID,
											Paid_Amount				)
											
			VALUES						(	'#PayMultiBillbacksID#',
											'#Item#',
											'#BBPaidAmount#'			)
		</CFQUERY>
</cfif>
	<CFELSE>
		<CFSET UnSuccessCount = UnSuccessCount + 1>
		<CFIF UnSuccessCount EQ 1>
			<CFSET UnSuccessBB = GetBBAmount.BB_Code>
		<CFELSE>
			<CFSET UnSuccessBB = "#UnSuccessBB#,#GetBBAmount.BB_Code#">
		</CFIF>		
	</CFIF>
</CFLOOP>



<cfset useLakebaseForUpdateTotBBAmount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pay_multi_billbacks")>
<cfif useLakebaseForUpdateTotBBAmount>
	<cftry>
		<cfset application.oLakebase.updateRows("pay_multi_billbacks",
			{
				"pay_multi_billbacks_id" = "eq.#PayMultiBillbacksID#",
				"deleted" = "eq.0"
			},
			{
				"total_paid_amount" = "#SUMBBAmount#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateTotBBAmount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateTotBBAmount>
<CFQUERY NAME="UpdateTotBBAmount" DATASOURCE="#Application.Datasource#">
	UPDATE 	Pay_Multi_Billbacks
	
	SET		Total_Paid_Amount = '#SUMBBAmount#'
	
	WHERE 	Pay_Multi_Billbacks_ID = '#PayMultiBillbacksID#' AND
			Deleted = 0
</CFQUERY>
</cfif>

<FORM NAME="PassBillback" ACTION="/billbacks/Check_Book/Trans_Create1.cfm" METHOD="POST">
	<INPUT TYPE="Hidden" NAME="new_bb_check" VALUE="1">
	<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="Billback_ID" VALUE="#FORM.FinalBB#">
	<INPUT TYPE="Hidden" NAME="Pay_Multi_Billbacks_ID" VALUE="#PayMultiBillbacksID#">
	</CFOUTPUT>	
</FORM>

<SCRIPT language="JavaScript">
passBB();
function passBB()
{	
	var AnyUnSuccess = "<CFOUTPUT>#UnSuccessBB#</CFOUTPUT>";
	var MultiID="<CFOUTPUT>#PayMultiBillbacksID#</CFOUTPUT>";
	if (AnyUnSuccess != "")
	{//Billback "Whatever" is currently locked, and will not be part of this payment request. Do you want to continue without it?

		if(confirm("Billback "+ AnyUnSuccess +" is currently locked, and will not be part of this payment request. Do you want to continue without it?"))
		{
			document.PassBillback.submit()
		} 
		else
		{			
			//setTimeout("history.back();", 0000);
			window.location.href = "Distributor_And_BB_Form.cfm?Unlock=1&PayMultiID=";
		}
	}
	else
	{
		document.PassBillback.submit()
	}
}
</SCRIPT>


