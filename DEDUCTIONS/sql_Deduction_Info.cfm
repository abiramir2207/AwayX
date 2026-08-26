<cfif isDefined("Deduction_ID")>

<CFIF LEFT(application.returned_customer_setting.Customer_Keyword,1) EQ "H"><!--- "H" --->
	<cfset useLakebaseForClosureSuccess = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForClosureSuccess>
		<cftry>
			<cfset ClosureSuccess = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions", {
					"deduction_id" = "eq.#Deduction_ID#"
				})
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForClosureSuccess = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForClosureSuccess>
	<CFQUERY NAME="ClosureSuccess" DATASOURCE="#Application.Datasource#">
		SELECT * FROM Deductions WHERE Deduction_ID = <cfqueryparam value='#Deduction_ID#'>
	</CFQUERY>
	</cfif>

	<CFIF ClosureSuccess.DD_Status EQ 4 AND ClosureSuccess.DD_Closure_Type EQ 1 AND ClosureSuccess.DD_Closure_ID NEQ "" AND ClosureSuccess.DD_Closure_BBPaid NEQ 1>
		<cfset useLakebaseForSetBackCLosureInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
		<cfif useLakebaseForSetBackCLosureInfo>
			<cftry>
				<cfset application.oLakebase.updateRows("deductions",
					{ "deduction_id" = "eq.#Deduction_ID#" },
					{
						"dd_date_closed" = javaCast("null", ""),
						"dd_closed_by" = javaCast("null", ""),
						"dd_resolution_code" = javaCast("null", ""),
						"dd_status" = 2,
						"dd_closure_method" = 1
					}
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForSetBackCLosureInfo = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForSetBackCLosureInfo>
		<CFQUERY NAME="SetBackCLosureInfo" DATASOURCE="#Application.Datasource#">
			UPDATE 	Deductions
			SET 	DD_Date_Closed = NULL,
					DD_Closed_By = NULL,
					DD_Resolution_Code = NULL,
					DD_Status = 2,
					DD_Closure_Method = 1
			WHERE 	Deduction_ID = <cfqueryparam value='#Deduction_ID#'>
		</CFQUERY>
		</cfif>
	</CFIF>
</CFIF>

<CFINCLUDE TEMPLATE="/Common_Files/Documents/User_Positions_Under_this_User.cfm">
<CFSET Access_Position_List = GP_Position_List_From_My_Position_Down>

<cfquery name="Deduction_Info" datasource="#application.datasource#">
	/* 61142 - Optimized query to run from 11 seconds to less than 1 second in AF production */
	DECLARE @attachment_count INT
	SELECT  @attachment_count = COUNT(*)
	FROM    Contract_Attachments
	INNER JOIN Document_Details
	        ON Document_Details.Doc_ID = Contract_Attachments.Doc_ID
	WHERE   Contract_Attachments.Deduction_ID = <cfqueryparam value="#Deduction_ID#">
	        AND Contract_Attachments.Deleted = <cfqueryparam value=0>
	        AND ( ( Document_Details.Public_View = <cfqueryparam value=1>
	                AND Document_Details.User_Position_ID IN ( SELECT	DISTINCT
	                                                                    Positions_Below_Me.Below_User_Positions_ID
	                                                           FROM     Positions_Below_Me
	                                                           WHERE    Positions_Below_Me.User_Positions_ID IN ( #preserveSingleQuotes(Access_Position_List)# ) ) )
	              OR Document_Details.Public_View = <cfqueryparam value=0> )

			SELECT Deductions.*,
       CASE
           WHEN Deductions.DD_Status = 4
           THEN ISNULL(DATEDIFF(d, Deductions.DD_Date, Deductions.DD_Date_Closed), 0)
           ELSE ISNULL(DATEDIFF(d, Deductions.DD_Date, GETDATE()), 0)
       END AS DD_Age,
       Distributor_Bill_To.Name,
       Distributor_Bill_To.Shr_Bill_To,
       Distributor_Bill_To.Address1,
       Distributor_Bill_To.Address2,
       Distributor_Bill_To.City,
       Distributor_Bill_To.State,
       Distributor_Bill_To.Zip,
       Distributor_Bill_To.Phone,
       Distributor_Bill_To.Shr_Bill_To,
       BSA_Foodservice_Brokers.Broker_Name,
       BSA_Foodservice_Brokers.Account_Exec,
       BSA_Foodservice_Brokers.Address,
       BSA_Foodservice_Brokers.Address_2,
       BSA_Foodservice_Brokers.City AS Broker_City,
       BSA_Foodservice_Brokers.State AS Broker_State,
       BSA_Foodservice_Brokers.Zip AS Broker_Zip,
       BSA_Foodservice_Brokers.Phone_1,
       BSA_Foodservice_Brokers.Phone_2,
       BSA_Foodservice_Brokers.Phone_3,
       BSA_Foodservice_Brokers.Phone_Ext,
       BSA_Foodservice_Brokers.Fax_Number,
       DD_Stage.DD_Stage_Description,
       BSA_Foodservice_Brokers.Active_Code AS Broker_Active_Code,
       BSA_Foodservice_Brokers.Deleted AS Broker_Deleted,
       CASE
           WHEN BSA_Foodservice_Customers.Shr_Ship_To IS NULL
           THEN Distributor_Bill_To.Name
           ELSE BSA_Foodservice_Customers.Name
       END AS ShipToName,
		BSA_Foodservice_Customers.Shr_Ship_To,
		@attachment_count AS attachment_count,
		DD_Classification.DD_Classification_Desc,
		DD_Classification.DD_Classification_ID,
		DD_Classification.GL_Account_Code,
		DD_Rebill_Integration.Rebill_Ack_Status,
		<!--- Ana D19384 Rebill Interface Data --->
		DD_Rebill_Integration.Rebill_Number,
		_Users.Name_First + ' ' + _Users.Name_Last Rebilled_By,
		DD_Rebill_Integration.Created_Date Rebilled_Date,
		CONVERT(Char(10),DD_Rebill_Integration.Rebill_Sent_On,101) Rebill_Sent_On,
		CONVERT(Char(10),DD_Rebill_Integration.Rebill_Ack_On,101) Rebill_Ack_On
		, Deduction_Type.DeductionType_Desc         <!---26487--->
		,	CASE
	   WHEN Deductions.DD_Status = 2
	   THEN
			   CASE
			   WHEN Deductions.DD_Rejected = 1 THEN '( Reject )'
			   WHEN Deductions.Is_Write_Off = 1 THEN '( Write-Off )'
			   ELSE DD_Status.DD_Status_Description END

	   WHEN Deductions.DD_Status = 3 OR Deductions.DD_Status = 4
	   THEN
			   CASE
			   WHEN Deductions.DD_Rejected = 1 THEN '( Reject )'
			   WHEN Deductions.Is_Write_Off = 1 THEN '( Write-Off )'
			   WHEN Deductions.Is_Last_Status_Rebill = 1 THEN '( Rebill )'
			   ELSE DD_Status.DD_Status_Description END
		ELSE
       DD_Status.DD_Status_Description
	   END AS DDStatus,
	   Deductions.DD_Resolution_Code,
	   ISNULL(DD_Reason_Code.DD_Reason_Code_Description, '') as DD_Reason_Code_Description,
	   Deductions.DD_Accounting_Date,
	   Deductions.DD_Check_Amount
	FROM 	Deductions
		LEFT JOIN Distributor_Bill_To ON Distributor_Bill_To.Distributor_Bill_To_ID = Deductions.Distributor_Bill_To_ID
		LEFT JOIN BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID
		LEFT JOIN BSA_Foodservice_Brokers ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Deductions.Broker_ID
		LEFT JOIN DD_Stage ON DD_Stage.DD_Stage_ID = Deductions.DD_Stage
		LEFT JOIN DD_Classification ON DD_Classification.DD_Classification_ID = Deductions.DD_Classification_ID
		LEFT JOIN DD_Rebill_Integration ON DD_Rebill_Integration.Deduction_ID = Deductions.Deduction_ID AND DD_Rebill_Integration.Deleted = 0
		LEFT JOIN _Users ON _Users.User_ID = DD_Rebill_Integration.Rebill_By
		LEFT JOIN Deduction_Type ON Deductions.DeductionType_ID = Deduction_Type.DeductionType_ID    <!---26487--->
		INNER JOIN DD_Status ON DD_Status_ID =  Deductions.DD_Status
		LEFT JOIN DD_Reason_Code
		ON DD_Reason_Code.DD_Reason_Code_ID = Deductions.DD_Resolution_Code
	WHERE Deductions.Deduction_ID = <cfqueryparam value="#Deduction_ID#">
</cfquery>
<!--- D31887: Not able to close deduction as non-trade START--->
<cfset useLakebaseForCheckForChild = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForCheckForChild>
	<cftry>
		<cfset CheckForChild = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"dd_parent_id" = "eq.#Deduction_Info.Deduction_ID#",
				"dd_ischild" = "eq.1",
				"deduction_id" = "neq.#Deduction_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForCheckForChild = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckForChild>
<CFQUERY NAME="CheckForChild" DATASOURCE="#Application.Datasource#">
	SELECT * FROM Deductions WHERE DD_parent_ID = <cfqueryparam value='#Deduction_Info.Deduction_ID#'> AND DD_IsChild = <cfqueryparam value=1> AND Deduction_ID <> <cfqueryparam value='#Deduction_ID#'> AND Deleted = <cfqueryparam value=0>
</CFQUERY>
</cfif>
<!---	SELECT * FROM Deductions WHERE DD_DedID = '#Deduction_Info.DD_DedID#' AND DD_IsChild = 1 AND Deduction_ID <> '#Deduction_ID#' AND Deleted = 0--->
<!--- D31887: Not able to close deduction as non-trade END--->
<!--- Reopen Logic --->
<CFSET ClosedAndReopenedOnSameDay = 0>
<CFSET ReOpenLogic_ShowLinks = 0>
<CFIF Deduction_Info.DD_Date_Closed NEQ "" AND Deduction_Info.DD_ReOpened_On NEQ "">
	<CFIF DATEDIFF("d",Deduction_Info.DD_Date_Closed,Deduction_Info.DD_ReOpened_On) EQ 0>
		<CFSET ClosedAndReopenedOnSameDay = 1>
	</CFIF>
</CFIF>

<CFIF
	(Deduction_Info.ReOpened EQ 1 AND Deduction_Info.DD_Reopened_Sent EQ 1 AND Deduction_Info.Ack_received_Reopen EQ 1) OR
	<!---D42284 :: Rebill vs closed deduction reopened --->
	<!--- D44454:: Re opened DD/Anand Rao/21-Aug-2014/Changed the application setting to check for  ON --->
	(Deduction_Info.ReOpened EQ 1 AND application.appSettingsGet.getDD_Reopen_Interface() EQ 1) OR
	(Deduction_Info.ReOpened EQ 0 AND Deduction_Info.DD_Reopened_Sent EQ 0 AND Deduction_Info.Ack_received_Reopen EQ 0)>
	<CFSET ReOpenLogic_ShowLinks = 1>
</CFIF>
<!--- End Reopen Logic --->


<cfelse>
No deduction was selected.
<cfabort>
</cfif>

<cfset stDeductionLabels = createObject("component", "components.settings.Labels.Labels").init().GetDeductionLabelsStruct() />
