<style>
	TABLE.Maintable TD 
	{
		border-bottom:solid #93BEE2 1px; font-size : 10px;
	}
	#header 
	{
		font-size: 12px;
	}
	
	TABLE.HistoryLog
	{
		font-size:10px;
		font-family:Arial;
	}
	TABLE.HistoryLog TD
	{
		border: 1px solid black;
		font-family:Arial;
	}	
	
	TR.highlight{
		background-color: #EAFFEA;
		}
</style>

<cfif NOT isDefined("appSettings")>
	<cfset appSettings = CreateObject("component", "components.settings.ApplicationSettingsManager").get() />
</cfif>

<cfparam name="BBID" default="" />
<cfif isDefined("URL.BBID")>
	<cfset BBID = URL.BBID />
</cfif>
<!--- Get Billback action details of Create, RFA, Agree, Disagree, Reset, Approval, Payment Request, Payment Approved --->
<cfquery name="billbackInfo" datasource="#application.datasource#">
	SELECT bb.BB_Code, 
		u1.Name_First + ' ' + u1.Name_Last As User_Created,		bb.Created_Date, 
		u2.Name_First + ' ' + u2.Name_Last As User_RFA, 		bb.BB_Request_Approval_Date, 
		u3.Name_First + ' ' + u3.Name_Last As User_Agreed, 		bba.created_date As Date_Agreed, 
		u6.Name_First + ' ' + u6.Name_Last As User_Disagree, 	bb.BB_Disagree_Date, 
		u4.Name_First + ' ' + u4.Name_Last As User_Reset, 		bb.bb_reset_date As Date_Reset, 
		u5.Name_First + ' ' + u5.Name_Last As User_Approved, 	bbapp.Date_Approved, 
		bb.copiedbb, bb.bb_Is_Child, bb.bb_parent_id,
		u7.Name_First + ' ' + u7.Name_Last As User_Payment_Request_Prepared_by, bb.BB_Payment_Request_Prepared_Date,
		u8.Name_First + ' ' + u8.Name_Last As User_Payment_Request_Approved_by, bb.BB_Payment_Request_Approved_Date,
		u9.Name_First + ' ' + u9.Name_Last As User_BB_Reversed_By, bb.BB_Reversed_Date
		
		FROM Billback bb 
			LEFT OUTER JOIN BB_Agreed_Info bba
		ON bb.billback_id = bba.billback_id	
		AND	bba.Deleted = 0
			LEFT OUTER JOIN BB_Reset bbr
		ON bb.billback_id = bbr.billback_id
			LEFT OUTER JOIN BB_Approved bbapp
		ON bb.billback_id = bbapp.billback_id
			LEFT OUTER JOIN _Users u1
		ON bb.bb_Creator_ID = u1.User_ID
			LEFT OUTER JOIN _Users u2 
		ON bb.BB_Request_Approval_User_ID = u2.User_ID
			LEFT OUTER JOIN _Users u3
		ON bba.user_id = u3.User_ID
			LEFT OUTER JOIN _Users u4
		ON bb.bb_reset_user_id = u4.User_ID
			LEFT OUTER JOIN _Users u5
		ON bbapp.user_approved = u5.User_ID
			LEFT OUTER JOIN _Users u6
		ON bb.BB_Disagree_By = u6.User_ID
			LEFT OUTER JOIN _Users u7
		ON bb.BB_Payment_Request_Prepared_By = u7.User_ID
			LEFT OUTER JOIN _Users u8
		ON bb.BB_Payment_Request_Approved_By = u8.User_ID
			LEFT OUTER JOIN _Users u9
		ON bb.BB_Reversed_By = u9.User_ID
	WHERE bb.Billback_ID = '#bbid#'
</cfquery>
<!--- <cfquery name="bbApprovalHistory" dbtype="query" datasource="#application.datasource#">
  SELECT BBAH.BB_Approval_History_Id, BBAH.Billback_ID, BBAH.Approved_By          
  --u1.Name_First, u1.Name_Last AS Approved_By_Name, BBAH.Created_Date
  FROM BB_Approval_History BBAH
  --LEFT OUTER JOIN _Users u1
	--ON BBAH.Approved_By = u1.User_ID
WHERE BBAH.Billback_ID = '#bbid#'
</cfquery> --->

<!--- <cfquery name="bbApprovalHistory" dbtype="query" >
  SELECT BB_Approval_History_Id, Billback_ID, Approved_By          
  ,Created_date
  FROM BB_Approval_History 
WHERE Billback_ID = '#bbid#'
</cfquery> --->
<!--- If the billback is a child billback (created out of a split), get Billback action details of "Agree,Approval,Payment Request,Payment Approved" from the parent billback as 
			this information is not copied to the child billback while splitting the parent billback.
			Note: All the action information (RFA, Agree, Disagree, Reset, Approval,Payment Request, Payment Approved) is the same for parent and child billback. Only
			created_date and amount information differs. --->
<cfif billbackInfo.BB_Is_Child eq 1>
	<cfquery name="Parent_billbackInfo" datasource="#application.datasource#">
		SELECT 
			u3.Name_First + ' ' + u3.Name_Last As User_Agreed, bba.created_date As Date_Agreed, 
			u5.Name_First + ' ' + u5.Name_Last As User_Approved, bbapp.Date_Approved,
			u7.Name_First + ' ' + u7.Name_Last As User_Payment_Request_Prepared_by, bb.BB_Payment_Request_Prepared_Date, 
			u8.Name_First + ' ' + u8.Name_Last As User_Payment_Request_Approved_by, bb.BB_Payment_Request_Approved_Date,
			u9.Name_First + ' ' + u9.Name_Last As User_BB_Reversed_By, bb.BB_Reversed_Date
		FROM Billback bb 
			LEFT OUTER JOIN BB_Agreed_Info bba
		ON bb.billback_id = bba.billback_id	
		AND	bba.Deleted = 0
			LEFT OUTER JOIN BB_Approved bbapp
		ON bb.billback_id = bbapp.billback_id
			LEFT OUTER JOIN _Users u3
		ON bba.user_id = u3.User_ID
			LEFT OUTER JOIN _Users u5
		ON bbapp.user_approved = u5.User_ID
			LEFT OUTER JOIN _Users u7
		ON bb.BB_Payment_Request_Prepared_By = u7.User_ID
			LEFT OUTER JOIN _Users u8
		ON bb.BB_Payment_Request_Approved_By = u8.User_ID
			LEFT OUTER JOIN _Users u9
		ON bb.BB_Reversed_By = u9.User_ID
	WHERE bb.Billback_ID = '#billbackInfo.bb_parent_id#'
	</cfquery>
</cfif>

<cfif billbackinfo.copiedbb neq "">
	<cfquery name="CopiedBillback" datasource="#application.datasource#">
		SELECT BB_Code,BB_Title,bb_start_date,bb_end_date FROM Billback
		WHERE billback_id = '#billbackinfo.copiedbb#'
	</cfquery>
</cfif>

<cfif appSettings.getBillbackModifyAgree() EQ 1>
<cfquery name="BillbackModifyAgreedChanges" datasource="#Application.Datasource#">
	SELECT BB_ModifyAgree_ProgramChanges.BB_ModifyAgree_PrgId,
	date_changed,to_programid_list,from_programid_list,
	To_ProgramNum_List, From_ProgramNum_List,
	Name_First + ' ' + Name_Last As User_Modified,_users.user_id,
	product_id,item,
	CASE WHEN BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_id IS NULL
	THEN
	LUMP_SUM_NAME ELSE DESCRIPTION END AS
	description,
	From_BB_Rate,To_BB_Rate,
	From_BB_Prod_Qty,To_BB_Prod_Qty, BB_Prod_Type,
	BB_Product_Type_desc as discount_type_desc,
	From_BB_Prod_UOM,To_BB_Prod_UOM,U1.Unit_Of_Measure_Desc as From_Prod_UOM_Desc,
	U2.Unit_Of_Measure_Desc as To_Prod_UOM_Desc,
	case when (BB_Prod_Type <> 3) then
	case when prod_changed <> 0 then prod_changed
	when (From_BB_Rate <> To_BB_Rate OR From_BB_Prod_Qty <> To_BB_Prod_Qty 
	OR From_BB_Prod_UOM <> To_BB_Prod_UOM) 
	then 3
	else 0 end
	else 
	case when prod_changed <> 0 then prod_changed
	when From_BB_Rate <> To_BB_Rate then 4
	else 0 end
	end as ProductChanges,
	case when to_programid_list <> from_programid_list
	then 1
	else 0
	end as ProgramChanges,
	case when From_BB_Rate <> To_BB_Rate then 1 else 0 end as Rate_Changed,
	case when From_BB_Prod_Qty <> To_BB_Prod_Qty then 1 else 0 end as Volume_Changed,
	case when From_BB_Prod_UOM <> To_BB_Prod_UOM then 1 else 0 end as VolumeUOM_Changed
	FROM BB_ModifyAgree_ProgramChanges
	INNER JOIN _Users on
	_Users.User_Id = BB_ModifyAgree_ProgramChanges.User_Id
	inner join BB_ModifyAgree_ProductChanges on
	BB_ModifyAgree_ProductChanges.BB_ModifyAgree_PrgId = 
	BB_ModifyAgree_ProgramChanges.BB_ModifyAgree_PrgId
	left join BSA_Foodservice_Items_Master on
	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_id = 
	BB_ModifyAgree_ProductChanges.product_id
	LEFT JOIN  PROGRAM_LUMP_SUMS ON PROGRAM_LUMP_SUMS.PROGRAM_LUMP_SUM_ID =
	BB_ModifyAgree_ProductChanges.product_id
	inner join BB_Product_Type on
	BB_Product_Type.BB_Product_Type_Id = BB_ModifyAgree_ProductChanges.BB_Prod_Type
	left join units_of_measure U1 on 
	U1.Unit_of_measure_id = BB_ModifyAgree_ProductChanges.From_BB_Prod_UOM
	left join units_of_measure U2 on 
	U2.Unit_of_measure_id = BB_ModifyAgree_ProductChanges.To_BB_Prod_UOM
	WHERE BB_ModifyAgree_ProgramChanges.Billback_Id = '#bbid#'
	and BB_ModifyAgree_ProgramChanges.active = 0
	--and BB_ModifyAgree_ProgramChanges.BB_ModifyAgree_PrgId = 14
	order by 
	date_Changed asc,name_last,BB_ModifyAgree_ProductChanges.program_id,product_id
</cfquery>

<cfset useLakebaseForgetusersmodifyagreed = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billbackmodifyagreedchanges")>
<cfif useLakebaseForgetusersmodifyagreed>
	<cftry>
		<cfset getusersmodifyagreed = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billbackmodifyagreedchanges", {
				"select" = "bb_modifyagree_prgid,date_changed,user_modified"
			}), "bb_modifyagree_prgid,date_changed,user_modified"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetusersmodifyagreed = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetusersmodifyagreed>
<cfquery name="getusersmodifyagreed" dbtype="query">
select distinct BB_ModifyAgree_PrgId,
date_changed,User_Modified
from BillbackModifyAgreedChanges
</cfquery>
</cfif>
</cfif>

<!--- Create Query Objects --->
<cfset BillbackCreateQuery = QueryNew("Name,Action_Date")>
<cfset BillbackRFAQuery = QueryNew("Name,Action_Date")>
<cfset BillbackAgreedQuery = QueryNew("Name,Action_Date")>
<cfset BillbackDisAgreedQuery = QueryNew("Name,Action_Date")>
<cfset BillbackResetQuery = QueryNew("Name,Action_Date")>
<cfset BillbackApprovedQuery = QueryNew("Name,Action_Date")>
<cfset BillbackPaymentRequestedQuery = QueryNew("Name,Action_Date")>
<cfset BillbackPaymentApprovedQuery = QueryNew("Name,Action_Date")>
<cfset BillbackReversedQuery = QueryNew("Name,Action_Date")>


<!--- Add rows to Query Objects --->
<cfif billbackInfo.BB_Is_Child eq 1>
	<cfset billbackRecordCount = Parent_billbackInfo.recordcount />
<cfelse>
	<cfset billbackRecordCount = billbackInfo.recordcount />
</cfif>
<cfset QueryAddRow(BillbackCreateQuery, "#billbackInfo.recordcount#")>
<cfset QueryAddRow(BillbackRFAQuery, "#billbackInfo.recordcount#")>
<cfset QueryAddRow(BillbackDisAgreedQuery, "#billbackInfo.recordcount#")>
<cfset QueryAddRow(BillbackResetQuery, "#billbackInfo.recordcount#")>
<!----- D17114: HZPROD160:  Split child BB's BSA Error on History Link
Issue: When the parent billback had more than one user agreed to it, there was en event error while looking at the history page of teh child
Event Error: The row number, (2) is out of bound, while trying to set the 2nd row of the query BillbackAgreedQuery
This happened because we tried to set the 2nd row of the query BillbackAgreedQuery with teh 2nd agreed users name, but we had only initialized the query BillbackAgreedQuery with 1 row
Solution:  Initialize the query BillbackAgreedQuery with the recordcount of the Parent_billbackInfo (which will be 2 in this example) in the case of split children
------>
<cfset QueryAddRow(BillbackAgreedQuery, "#billbackRecordCount#")>
<cfset QueryAddRow(BillbackApprovedQuery, "#billbackRecordCount#")>
<cfset QueryAddRow(BillbackPaymentRequestedQuery, "#billbackRecordCount#")>
<cfset QueryAddRow(BillbackPaymentApprovedQuery, "#billbackRecordCount#")>
<cfset QueryAddRow(BillbackReversedQuery, "#billbackRecordCount#")>


<!--- Store the User and Date Info (history) of all the actions in the respective query object --->
<cfloop query="billbackInfo" startrow="1" endrow="#billbackInfo.recordcount#">
	<cfset QuerySetCell(BillbackCreateQuery,"Name",User_Created, currentrow)>
	<cfset QuerySetCell(BillbackCreateQuery,"Action_Date",Created_Date, currentrow)>

	<cfset QuerySetCell(BillbackRFAQuery,"Name",User_RFA, currentrow)>
	<cfset QuerySetCell(BillbackRFAQuery,"Action_Date",BB_Request_Approval_Date, currentrow)>

	<cfset QuerySetCell(BillbackAgreedQuery,"Name",User_Agreed, currentrow)>
	<cfset QuerySetCell(BillbackAgreedQuery,"Action_Date",Date_Agreed, currentrow)>

	<cfset QuerySetCell(BillbackDisAgreedQuery,"Name",User_Disagree, currentrow)>
	<cfset QuerySetCell(BillbackDisAgreedQuery,"Action_Date",BB_Disagree_Date, currentrow)>

	<cfset QuerySetCell(BillbackResetQuery,"Name",User_Reset, currentrow)>
	<cfset QuerySetCell(BillbackResetQuery,"Action_Date",Date_Reset, currentrow)>
	
	<cfset QuerySetCell(BillbackApprovedQuery,"Name",User_Approved, currentrow)>
	<cfset QuerySetCell(BillbackApprovedQuery,"Action_Date",Date_Approved, currentrow)>

	<cfset QuerySetCell(BillbackPaymentRequestedQuery,"Name",User_Payment_Request_Prepared_By, currentrow)>
	<cfset QuerySetCell(BillbackPaymentRequestedQuery,"Action_Date",BB_Payment_Request_Prepared_Date, currentrow)>

	<cfset QuerySetCell(BillbackPaymentApprovedQuery,"Name",User_Payment_Request_Approved_By, currentrow)>
	<cfset QuerySetCell(BillbackPaymentApprovedQuery,"Action_Date",BB_Payment_Request_Approved_Date, currentrow)>

	<cfset QuerySetCell(BillbackReversedQuery,"Name",User_BB_Reversed_By, currentrow)>
	<cfset QuerySetCell(BillbackReversedQuery,"Action_Date",BB_Reversed_Date, currentrow)>
</cfloop>

<!--- If the billback is a child billback (created out of a split), then grab the required info from the parent billback as this
			information is not copied on to the child billback on billback split. This query will overwrite the earlier query object results --->
<cfif billbackInfo.BB_Is_Child eq 1>
	<cfloop query="Parent_billbackInfo" startrow="1" endrow="#Parent_billbackInfo.recordcount#">
		<cfset QuerySetCell(BillbackAgreedQuery,"Name",User_Agreed, currentrow)>
		<cfset QuerySetCell(BillbackAgreedQuery,"Action_Date",Date_Agreed, currentrow)>

		<cfset QuerySetCell(BillbackApprovedQuery,"Name",User_Approved, currentrow)>
		<cfset QuerySetCell(BillbackApprovedQuery,"Action_Date",Date_Approved, currentrow)>

		<cfset QuerySetCell(BillbackPaymentRequestedQuery,"Name",User_Payment_Request_Prepared_By, currentrow)>
		<cfset QuerySetCell(BillbackPaymentRequestedQuery,"Action_Date",BB_Payment_Request_Prepared_Date, currentrow)>

		<cfset QuerySetCell(BillbackPaymentApprovedQuery,"Name",User_Payment_Request_Approved_By, currentrow)>
		<cfset QuerySetCell(BillbackPaymentApprovedQuery,"Action_Date",BB_Payment_Request_Approved_Date, currentrow)>

		<cfset QuerySetCell(BillbackReversedQuery,"Name",User_BB_Reversed_By, currentrow)>
		<cfset QuerySetCell(BillbackReversedQuery,"Action_Date",BB_Reversed_Date, currentrow)>
	</cfloop>
</cfif>


<!--- Get the query results for various actions (Create, RFA, Agree, Disagree, Reset, Approval, Payment Request, Payment Approved, BB Reversed)--->
<cfset useLakebaseForBillbackCreate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billbackcreatequery")>
<cfif useLakebaseForBillbackCreate>
	<cftry>
		<cfset BillbackCreate = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billbackcreatequery", {
				"name" = "neq.''
	GROUP BY Action_Date,Name",
				"order" = "action_date.desc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBillbackCreate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBillbackCreate>
<cfquery name="BillbackCreate" dbtype="query">
	SELECT *
	FROM BillbackCreateQuery
	WHERE Name IS NOT NULL
	AND NAME != ''
	GROUP BY Action_Date,Name
	ORDER BY Action_Date DESC
</cfquery>
</cfif>

<cfset useLakebaseForBillbackRFA = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billbackrfaquery")>
<cfif useLakebaseForBillbackRFA>
	<cftry>
		<cfset BillbackRFA = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billbackrfaquery", {
				"name" = "neq.''
	GROUP BY Action_Date,Name",
				"order" = "action_date.desc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBillbackRFA = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBillbackRFA>
<cfquery name="BillbackRFA" dbtype="query">
	SELECT *
	FROM BillbackRFAQuery
	WHERE Name IS NOT NULL
	AND NAME != ''
	GROUP BY Action_Date,Name
	ORDER BY Action_Date DESC
</cfquery>
</cfif>

<cfset useLakebaseForBillbackAgreed = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billbackagreedquery")>
<cfif useLakebaseForBillbackAgreed>
	<cftry>
		<cfset BillbackAgreed = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billbackagreedquery", {
				"name" = "neq.''
	GROUP BY Action_Date,Name",
				"order" = "action_date.desc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBillbackAgreed = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBillbackAgreed>
<cfquery name="BillbackAgreed" dbtype="query">
	SELECT * 
	FROM BillbackAgreedQuery
	WHERE Name IS NOT NULL
	AND NAME != ''
	GROUP BY Action_Date,Name
	ORDER BY Action_Date DESC
</cfquery>
</cfif>

<cfset useLakebaseForBillbackDisAgreed = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billbackdisagreedquery")>
<cfif useLakebaseForBillbackDisAgreed>
	<cftry>
		<cfset BillbackDisAgreed = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billbackdisagreedquery", {
				"name" = "neq.''
	GROUP BY Action_Date,Name",
				"order" = "action_date.desc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBillbackDisAgreed = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBillbackDisAgreed>
<cfquery name="BillbackDisAgreed" dbtype="query">
	SELECT *
	FROM BillbackDisAgreedQuery
	WHERE Name IS NOT NULL
	AND NAME != ''
	GROUP BY Action_Date,Name
	ORDER BY Action_Date DESC
</cfquery>
</cfif>

<cfset useLakebaseForBillbackReset = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billbackresetquery")>
<cfif useLakebaseForBillbackReset>
	<cftry>
		<cfset BillbackReset = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billbackresetquery", {
				"name" = "neq.''
	GROUP BY Action_Date,Name",
				"order" = "action_date.desc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBillbackReset = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBillbackReset>
<cfquery name="BillbackReset" dbtype="query">
	SELECT *
	FROM BillbackResetQuery
	WHERE Name IS NOT NULL
	AND NAME != ''
	GROUP BY Action_Date,Name
	ORDER BY Action_Date DESC
</cfquery>
</cfif>

<cfset useLakebaseForBillbackApproved = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billbackapprovedquery")>
<cfif useLakebaseForBillbackApproved>
	<cftry>
		<cfset BillbackApproved = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billbackapprovedquery", {
				"name" = "neq.''
	GROUP BY Action_Date,Name",
				"order" = "action_date.desc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBillbackApproved = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBillbackApproved>
<cfquery name="BillbackApproved" dbtype="query">
	SELECT *
	FROM BillbackApprovedQuery
	WHERE Name IS NOT NULL
	AND NAME != ''
	GROUP BY Action_Date,Name
	ORDER BY Action_Date DESC
</cfquery>
</cfif>

<cfset useLakebaseForBillbackPaymentRequested = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billbackpaymentrequestedquery")>
<cfif useLakebaseForBillbackPaymentRequested>
	<cftry>
		<cfset BillbackPaymentRequested = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billbackpaymentrequestedquery", {
				"name" = "neq.''
	GROUP BY Action_Date,Name",
				"order" = "action_date.desc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBillbackPaymentRequested = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBillbackPaymentRequested>
<cfquery name="BillbackPaymentRequested" dbtype="query">
	SELECT *
	FROM BillbackPaymentRequestedQuery
	WHERE Name IS NOT NULL
	AND NAME != ''
	GROUP BY Action_Date,Name
	ORDER BY Action_Date DESC
</cfquery>
</cfif>

<cfset useLakebaseForBillbackPaymentApproved = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billbackpaymentapprovedquery")>
<cfif useLakebaseForBillbackPaymentApproved>
	<cftry>
		<cfset BillbackPaymentApproved = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billbackpaymentapprovedquery", {
				"name" = "neq.''
	GROUP BY Action_Date,Name",
				"order" = "action_date.desc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBillbackPaymentApproved = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBillbackPaymentApproved>
<cfquery name="BillbackPaymentApproved" dbtype="query">
	SELECT *
	FROM BillbackPaymentApprovedQuery
	WHERE Name IS NOT NULL
	AND NAME != ''
	GROUP BY Action_Date,Name
	ORDER BY Action_Date DESC
</cfquery>
</cfif>

<cfset useLakebaseForBillbackReversed = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billbackreversedquery")>
<cfif useLakebaseForBillbackReversed>
	<cftry>
		<cfset BillbackReversed = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billbackreversedquery", {
				"name" = "neq.''
	GROUP BY Action_Date,Name",
				"order" = "action_date.desc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBillbackReversed = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBillbackReversed>
<cfquery name="BillbackReversed" dbtype="query">
	SELECT *
	FROM BillbackReversedQuery
	WHERE Name IS NOT NULL
	AND NAME != ''
	GROUP BY Action_Date,Name
	ORDER BY Action_Date DESC
</cfquery>
</cfif>

 <!---******* SHOW THE REPORT OUTPUT ******* --->
<cfset ColorBackground = "FFCE84">
<CFOUTPUT>
<HR>
<FONT SIZE="+1">Payable number:#BillbackInfo.BB_Code#</FONT>
<HR>

<cfif billbackinfo.copiedbb neq "">
<FONT SIZE="+1">Copied from Billback: #CopiedBillback.BB_Code#</FONT>
<br><strong>#CopiedBillback.BB_Title#</strong>
<br>#dateformat(CopiedBillback.bb_start_date, 'mm/dd/yyyy')# - #dateformat(CopiedBillback.bb_end_date, 'mm/dd/yyyy')#
<hr>
</cfif>
</CFOUTPUT>

<br>
<table width="100%" align="left" border="0">
<tr>
<td>
<table cellpadding="3" width="100%" align="left" cellspacing="0" border="0" class="HistoryLog">
<cfoutput>
<tr>
	<td valign="top" class="Heading" style="background-color:#ColorBackground#">Created By</td>
	<td valign="top" class="Heading" style="background-color:#ColorBackground#">RFA'd By</td>
	<td valign="top" class="Heading" style="background-color:#ColorBackground#">Agreed By</td>
	<td valign="top" class="Heading" style="background-color:#ColorBackground#">Disagreed By</td>
</tr>
</cfoutput>
<tr>
	<td valign="top"><cfif BillbackCreate.recordcount eq 0>&nbsp;</cfif><cfoutput query="BillbackCreate">#Name#&nbsp;(#Dateformat(Action_Date,"mm/dd/yy")# #Timeformat(Action_Date,"hh:mm tt")#)<br /></cfoutput></td>
	<td valign="top"><cfif BillbackRFA.recordcount eq 0>&nbsp;</cfif><cfoutput query="BillbackRFA">#Name#&nbsp;(#Dateformat(Action_Date,"mm/dd/yy")# #Timeformat(Action_Date,"hh:mm tt")#)<br /></cfoutput></td>
	<td valign="top"><cfif BillbackAgreed.recordcount eq 0>&nbsp;</cfif><cfoutput query="BillbackAgreed">#Name#&nbsp;(#Dateformat(Action_Date,"mm/dd/yy")# #Timeformat(Action_Date,"hh:mm tt")#)<br /></cfoutput></td>
	<td valign="top"><cfif BillbackDisagreed.recordcount eq 0>&nbsp;</cfif><cfoutput query="BillbackDisagreed">#Name#&nbsp;(#Dateformat(Action_Date,"mm/dd/yy")# #Timeformat(Action_Date,"hh:mm tt")#)<br /></cfoutput></td>
</tr>
</table>
</td>
</tr>

<!--- 
      Dev Notes:  21923/Anand Rao/19-Jan-2010 
      Created a new table BB_Approval_History and using it for maintaining the 
      BB Approval history, if a BB is Approved multiple times.
  ---> 
 <cfquery name="BillbackApprovalHistory" datasource="#application.datasource#">
  SELECT BBAH.BB_Approval_History_Id, BBAH.Billback_ID, BBAH.Approved_By , BBAH.Created_Date,         
  u1.Name_First + ' ' +  u1.Name_Last AS Approved_By_Name
  FROM BB_Approval_History BBAH
  LEFT OUTER JOIN _Users u1
	ON BBAH.Approved_By = u1.User_ID
  WHERE BBAH.Billback_ID = '#bbid#' 
  order by BBAH.Created_Date 
</cfquery>

<cfif (BillbackApprovalHistory.RecordCount NEQ 0)>
	<tr>
		<td>
			<table cellpadding="3" width="100%" align="left" cellspacing="0" border="0" class="HistoryLog">
			<cfoutput> 
				<tr>
					<td valign="top" class="Heading" style="background-color:#ColorBackground#">Approved By</td>
				</tr>
				<tr>
					<td valign="top">
					<ul>
						<cfif BillbackApprovalHistory.RecordCount eq 0>&nbsp;
						<cfelse>
							<cfloop query="BillbackApprovalHistory">
								<li>#BillbackApprovalHistory.Approved_By_Name#&nbsp;(#Dateformat(BillbackApprovalHistory.Created_Date,"mm/dd/yy")# #Timeformat(BillbackApprovalHistory.Created_Date,"hh:mm tt")#)</li>
							</cfloop>
						</cfif>
					</ul>
					</td>
				</tr>
			</cfoutput> 
			</table>  
		</td>
	</tr>
</cfif>


<!----/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!----/////////////////////////////////////// Reset, Payment Requested and Approved END ///////////////////////////////////////--->
<!----/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<tr>
	<td>
		<table cellpadding="3" width="100%" align="left" cellspacing="0" border="0" class="HistoryLog">
			<cfoutput>
			<tr>
				<td valign="top" class="Heading" style="background-color:#ColorBackground#">Reset By</td>
				<td valign="top" class="Heading" style="background-color:#ColorBackground#">Payment Requested By</td>
				<td valign="top" class="Heading" style="background-color:#ColorBackground#">Payment Approved By</td>
			</tr>
			</cfoutput>
			<tr>
				<td valign="top">
					<cfoutput query="BillbackReset">#Name# (#Dateformat(Action_Date,"mm/dd/yy")# #Timeformat(Action_Date,"hh:mm tt")#)&nbsp;<br></cfoutput>
					&nbsp;
				</td>
				<td valign="top">
					<cfoutput query="BillbackPaymentRequested">#Name# (#Dateformat(Action_Date,"mm/dd/yy")# #Timeformat(Action_Date,"hh:mm tt")#)&nbsp;<br></cfoutput>
					&nbsp;
				</td>
				<td valign="top">
					<cfoutput query="BillbackPaymentApproved">#Name# (#Dateformat(Action_Date,"mm/dd/yy")# #Timeformat(Action_Date,"hh:mm tt")#)&nbsp;<br></cfoutput>
					&nbsp;
				</td>
			</tr>
		</table>
	</td>
</tr>
<!----/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!----/////////////////////////////////////// Reset, Payment Requested and Approved END ///////////////////////////////////////--->
<!----/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->


<!----/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!----////////////////////////////////////////////// Reversed, Adjust and Copy ////////////////////////////////////////////////--->
<!----/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<cfset variables.objBillbackHistroy = CreateObject("component", "mvc.Models.Billback.BillbackHistoryManager") />
<cfset qGetCopyHistory 	=  variables.objBillbackHistroy.getBillbackCopyHistory(bbid) />
<cfset qGetAdjustedBy	=  variables.objBillbackHistroy.getBillbackAdjustedBy(bbid) />
<cfset qGetAdjustedData	=  variables.objBillbackHistroy.getBillbackAdjustedProgram(bbid) />
<tr>
	<td>
		<table cellpadding="3" width="100%" align="left" cellspacing="0" border="0" class="HistoryLog">
			<cfoutput>
			<tr>
				<td valign="top" class="Heading" style="background-color:#ColorBackground#">Adjusted By</td>
				<td valign="top" class="Heading" style="background-color:#ColorBackground#">Reversed By</td>
				<td valign="top" class="Heading" style="background-color:#ColorBackground#">Copied By</td>
			</tr>
			</cfoutput>
			<tr>
				<td valign="top">
					<cfoutput query="qGetAdjustedBy">#Adjusted_By# (#DateFormat(BB_Adjusted_Date, "mm/dd/yyyy")# #TimeFormat(BB_Adjusted_Date, "medium")#)&nbsp;<br></cfoutput>
					<cfoutput query="qGetAdjustedData">Original Program ##: #Old_Program_Number# &nbsp;&nbsp;&nbsp;New Program ##: #New_Program_Number#&nbsp;<br></cfoutput>
					&nbsp;
				</td>
				<td valign="top">
					<cfoutput query="BillbackReversed">#Name# (#Dateformat(Action_Date,"mm/dd/yy")# #Timeformat(Action_Date,"hh:mm tt")#)&nbsp;<br></cfoutput>
					&nbsp;
				</td>
				<td valign="top">
					<cfoutput query="qGetCopyHistory">#Copied_By# (#DateFormat(Created_Date, "mm/dd/yyyy")# #TimeFormat(Created_Date, "medium")#)&nbsp;&nbsp;&nbsp; Created #BB_Code#&nbsp;<br></cfoutput>
					&nbsp;
				</td>
			</tr>
		</table>
	</td>
</tr>
<!----/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!----////////////////////////////////////////////// Reversed, Adjust and Copy END ////////////////////////////////////////////--->
<!----/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

<cfif appSettings.getBillbackModifyAgree() EQ 1>
<tr><td>
<table border="0" width="100%" align="left" cellspacing="0" border="0" class="HistoryLog">
<cfoutput>
<tr>
	<td valign="top"  colspan="100%" class="Heading" style="background-color:#ColorBackground#">Modify Agreed By</td>
</tr>
</cfoutput>
<cfif getusersmodifyagreed.recordcount GT 0>
<cfloop query="getusersmodifyagreed">
<cfoutput>
	<tr onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<td class="underlined" width="100%">#UCASE(getusersmodifyagreed.User_Modified)#
		&nbsp;(#Dateformat(getusersmodifyagreed.Date_Changed,"mm/dd/yy")# #Timeformat(getusersmodifyagreed.Date_Changed,"hh:mm tt")#)</td>
	</tr>
</cfoutput>
<tr>
<td colspan="100%" style="border-bottom:none">
<cfsilent>
<cfquery name="checkifanychanged" dbtype="query">
select * from
BillbackModifyAgreedChanges
where (ProductChanges <> 0 OR ProgramChanges <> 0)
and BB_ModifyAgree_PrgId = #getusersmodifyagreed.BB_ModifyAgree_PrgId#
</cfquery>
</cfsilent>
<cfif checkifanychanged.recordcount GT 0>
<table width="100%" cellspacing="0" border="1">
<tr BGCOLOR="FFCE84">
		<td width="30%" style="border-left:none">WHAT</td>
		<td width="23%">FROM</td>
		<td width="23%">TO</td>
		<td width="23%" style="border-right:none">ACTION</td>
</tr>
<cfsilent>
<cfquery name="getchangedPrograms" dbtype="query">
select distinct To_ProgramNum_List, From_ProgramNum_List
from
BillbackModifyAgreedChanges
where ProgramChanges <> 0
and BB_ModifyAgree_PrgId = #getusersmodifyagreed.BB_ModifyAgree_PrgId#
</cfquery>
</cfsilent>
<cfif getchangedPrograms.recordcount GT 0>
<cfoutput>
<tr>
		<td style="border-left:none">Programs</td>
		<td>#getchangedPrograms.From_ProgramNum_List#&nbsp;</td>
		<td>#getchangedPrograms.To_ProgramNum_List#&nbsp;</td>
		<td style="border-right:none">Changed</td>
</tr>
</cfoutput>
</cfif>
<cfsilent>
<cfquery name="getchangedProducts" dbtype="query">
select distinct product_id,item,description,From_BB_Rate,To_BB_Rate,
From_BB_Prod_Qty,To_BB_Prod_Qty, BB_Prod_Type,
From_BB_Prod_UOM,To_BB_Prod_UOM, ProductChanges,
Rate_Changed,Volume_Changed,VolumeUOM_Changed,
From_Prod_UOM_Desc,To_Prod_UOM_Desc,discount_type_desc
FROM BillbackModifyAgreedChanges
where ProductChanges <> 0
and BB_ModifyAgree_PrgId = #getusersmodifyagreed.BB_ModifyAgree_PrgId#
order by item,discount_type_desc
</cfquery>
</cfsilent>
<cfif getchangedProducts.recordcount GT 0>
<tr>
		<td style="border-left:none">Products/Discount Type</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td style="border-right:none">&nbsp;</td>
</tr>
<cfloop query="getchangedProducts">
<cfsilent>
<cfset ProductChangesQuery = QueryNew("Item,Description,Type,Name,Action,From,To")>
<cfif getchangedProducts.ProductChanges EQ 1>
<cfset QueryAddRow(ProductChangesQuery)>
<cfset QuerySetCell(ProductChangesQuery,"Item",getchangedProducts.item)>
<cfset QuerySetCell(ProductChangesQuery,"Description",getchangedProducts.Description)>
<cfset QuerySetCell(ProductChangesQuery,"Type",getchangedProducts.discount_type_desc)>
<cfif getchangedProducts.BB_Prod_Type EQ 10>
<cfset QuerySetCell(ProductChangesQuery,"Name","Claim Adjustment Added")>
<cfset QuerySetCell(ProductChangesQuery,"To",dollarformat(getchangedProducts.To_BB_Rate))>
<cfelseif getchangedProducts.BB_Prod_Type NEQ 3>
<cfset QuerySetCell(ProductChangesQuery,"Name","Product Added")>
<cfelse>
<cfset QuerySetCell(ProductChangesQuery,"Name","Lumpsum Added")>
<cfset QuerySetCell(ProductChangesQuery,"To",dollarformat(getchangedProducts.To_BB_Rate))>
</cfif>
<cfset QuerySetCell(ProductChangesQuery,"Action",getchangedProducts.ProductChanges)>
</cfif>
<cfif getchangedProducts.ProductChanges EQ 2>
<cfset QueryAddRow(ProductChangesQuery)>
<cfset QuerySetCell(ProductChangesQuery,"Item",getchangedProducts.item)>
<cfset QuerySetCell(ProductChangesQuery,"Description",getchangedProducts.Description)>
<cfset QuerySetCell(ProductChangesQuery,"Type",getchangedProducts.discount_type_desc)>
<cfif getchangedProducts.BB_Prod_Type NEQ 3>
<cfset QuerySetCell(ProductChangesQuery,"Name","Product Deleted")>
<cfelse>
<cfset QuerySetCell(ProductChangesQuery,"Name","Lumpsum Deleted")>
</cfif>
<cfset QuerySetCell(ProductChangesQuery,"Action",getchangedProducts.ProductChanges)>
</cfif>
<cfif getchangedProducts.ProductChanges EQ 4>
<cfset QueryAddRow(ProductChangesQuery)><cfset QuerySetCell(ProductChangesQuery,"Description",getchangedProducts.Description)>
<cfset QuerySetCell(ProductChangesQuery,"Type",getchangedProducts.discount_type_desc)>
<cfset QuerySetCell(ProductChangesQuery,"Name","Lumpsum Changed")>
<cfset QuerySetCell(ProductChangesQuery,"Action",getchangedProducts.ProductChanges)>
<cfset QuerySetCell(ProductChangesQuery,"From",dollarformat(getchangedProducts.From_BB_Rate))>
<cfset QuerySetCell(ProductChangesQuery,"To",dollarformat(getchangedProducts.To_BB_Rate))>
</cfif>

<cfif getchangedProducts.ProductChanges NEQ 1 AND getchangedProducts.ProductChanges NEQ 2 AND getchangedProducts.ProductChanges NEQ 4>
<cfif getchangedProducts.Rate_Changed EQ 1>
<cfset QueryAddRow(ProductChangesQuery)>
<cfset QuerySetCell(ProductChangesQuery,"Item",getchangedProducts.item)>
<cfset QuerySetCell(ProductChangesQuery,"Description",getchangedProducts.Description)>
<cfset QuerySetCell(ProductChangesQuery,"Type",getchangedProducts.discount_type_desc)>
<cfset QuerySetCell(ProductChangesQuery,"Name","Rate Changed")>
<cfset QuerySetCell(ProductChangesQuery,"Action",getchangedProducts.Rate_Changed)>
<cfset QuerySetCell(ProductChangesQuery,"From",dollarformat(getchangedProducts.From_BB_Rate))>
<cfset QuerySetCell(ProductChangesQuery,"To",dollarformat(getchangedProducts.To_BB_Rate))>
</cfif>

<cfif getchangedProducts.Volume_Changed EQ 1>
<cfset QueryAddRow(ProductChangesQuery)>
<cfset QuerySetCell(ProductChangesQuery,"Item",getchangedProducts.item)>
<cfset QuerySetCell(ProductChangesQuery,"Description",getchangedProducts.Description)>
<cfset QuerySetCell(ProductChangesQuery,"Type",getchangedProducts.discount_type_desc)>
<cfset QuerySetCell(ProductChangesQuery,"Name","Volume Changed")>
<cfset QuerySetCell(ProductChangesQuery,"Action",getchangedProducts.Volume_Changed)>
<cfset QuerySetCell(ProductChangesQuery,"From",numberformat(getchangedProducts.From_BB_Prod_Qty,"___,___,___,___"))>
<cfset QuerySetCell(ProductChangesQuery,"To",numberformat(getchangedProducts.To_BB_Prod_Qty,"___,___,___,___"))>
</cfif>

<cfif getchangedProducts.VolumeUOM_Changed EQ 1>
<cfset QueryAddRow(ProductChangesQuery)>
<cfset QuerySetCell(ProductChangesQuery,"Item",getchangedProducts.item)>
<cfset QuerySetCell(ProductChangesQuery,"Description",getchangedProducts.Description)>
<cfset QuerySetCell(ProductChangesQuery,"Type",getchangedProducts.discount_type_desc)>
<cfset QuerySetCell(ProductChangesQuery,"Name","Volume UOM Changed")>
<cfset QuerySetCell(ProductChangesQuery,"Action",getchangedProducts.VolumeUOM_Changed)>
<cfset QuerySetCell(ProductChangesQuery,"From",getchangedProducts.From_Prod_UOM_Desc)>
<cfset QuerySetCell(ProductChangesQuery,"To",getchangedProducts.To_Prod_UOM_Desc)>
</cfif>
</cfif>
</cfsilent>
<cfoutput>
<cfloop query="ProductChangesQuery">
<tr>
<td valign="top" style="font-size:9px;border-left:none">
#ProductChangesQuery.item#&nbsp;#left(ProductChangesQuery.description,20)# (#ProductChangesQuery.Type#)
</td>
<td width="23%">&nbsp;#ProductChangesQuery.From#</td>
<td width="23%">&nbsp;#ProductChangesQuery.To#</td>
<td width="23%" style="border-right:none">#ProductChangesQuery.Name#</td>
</tr>
</cfloop>
</cfoutput>
</cfloop>
</cfif>
</table>
<cfelse>
No Changes
</cfif>
</td>
</tr>

</cfloop>
<cfelse>
<tr>
	<td valign="top" colspan="100%">
	None
	</td>
</tr>
</cfif>
</table>
</cfif>
</td>
</tr>
</table>
<script>
	// BSD D11544   	
    try { window.parent.dyniframesize(); } catch (err) { };
</script>
<!--- ******* END OF THE REPORT ******* --->