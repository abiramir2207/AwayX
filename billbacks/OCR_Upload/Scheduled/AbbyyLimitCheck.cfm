<!--- <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
 
<html>
<head>
	<title>..::Abbyy Page Quota Alert::..</title>
</head>

<body> --->
<!--- Check how many pages were processed between the start of this months quota and now --->
<cfquery name="qGetTotalPages" datasource="#application.datasource#">
DECLARE 
	@AbbyyMonth INT,
	@AbbyyDate INT,
	@AbbyyYear INT,
	@curMonth INT,
	@curYear INT,
	@curDate INT,
	@ABBYYInstallDate DATETIME,
	@StartDate DATETIME,
	@EndDate DATETIME
	
	SELECT @ABBYYInstallDate = value FROM _Settings WHERE Input_Name = 'ABBYY_Install_Date'
	
		SET @AbbyyMonth = MONTH(@ABBYYInstallDate)
		SET @AbbyyYear  = YEAR(@ABBYYInstallDate)
		SET @AbbyyDate   = DAY(@ABBYYInstallDate)
		SET @curYear		= YEAR(GETDATE())
		SET @curMonth 		= MONTH(GETDATE())
		
		SET @StartDate = CAST(CONCAT(CAST(@curYear AS VARCHAR(4)), '-', CAST(@curMonth AS VARCHAR(2)), '-',CAST(@AbbyyDate AS VARCHAR(2))) AS DATE)
		SET @EndDate = DATEADD(MONTH,1,@StartDate)
		IF(ISNULL(@ABBYYInstallDate,'') != '' AND @ABBYYInstallDate != '' )
		BEGIN   
		SELECT SUM(Pages_Extracted) AS  TotalPages_Extracted, 
			   CONVERT(varchar, @StartDate, 101) AS QuotaStart, 
			   CONVERT(varchar, @EndDate, 101) AS QuotaEnd
		 
			/* OUL.pages_extracted,OUL.OCR_Upload_Date,* */
			
			FROM dbo.OCR_Upload_Log OUL
		INNER JOIN dbo.OCR_Template_Settings OTS ON OTS.OCR_Template_Settings_ID = OUL.OCR_Template_Settings_ID
		WHERE 
		 OCR_Upload_Date BETWEEN @StartDate AND @EndDate
		 AND 
		  OTS.OCR_Code IN 
		('GFS_CA_TRADE',
		'GFS_CA_OPR',
		'SYSCO_OT2_OT4_OT6',
		'SYSCO_TT2_TT4_TT6')
 
	END
	ELSE
	SELECT '' AS Pages_Extracted
  	 
</cfquery>

<cfdump var="#qGetTotalPages#" />
<!--- Check if the No of Pages is greater than 9000 and if the email was not already sent for this month    --->


<cfif (qGetTotalPages.TotalPages_Extracted NEQ "" AND qGetTotalPages.TotalPages_Extracted GT 18000)>

	<cfquery name="qNotificationSent" datasource="#application.datasource#">
		DECLARE 
		@AbbyyMonth INT,
		@AbbyyDate INT,
		@AbbyyYear INT,
		@curMonth INT,
		@curYear INT,
		@curDate INT,
		@ABBYYInstallDate DATETIME,
		@StartDate DATETIME,
		@EndDate DATETIME
		
		SELECT @ABBYYInstallDate = value FROM _Settings WHERE Input_Name = 'ABBYY_Install_Date'
		IF(ISNULL(@ABBYYInstallDate,'') != '' AND @ABBYYInstallDate != '' )
			BEGIN
				SET @AbbyyMonth = MONTH(@ABBYYInstallDate)
				SET @AbbyyYear  = YEAR(@ABBYYInstallDate)
				SET @AbbyyDate  = DAY(@ABBYYInstallDate)
				SET @curYear	= YEAR(GETDATE())
				SET @curMonth 	= MONTH(GETDATE())
				
				SET @StartDate = CAST(CONCAT(CAST(@curYear AS VARCHAR(4)), '-',CAST(@curMonth AS VARCHAR(2)), '-',CAST(@AbbyyDate AS VARCHAR(2))) AS DATE)
				SET @EndDate = DATEADD(MONTH,1,@StartDate)
		
				SELECT 	
					ABBYY_Quota_Notification_id,
					Email_Sent,
					Created_Date,
					@StartDate as QuotaStart,
					@EndDate as QuotaEnd
				FROM 
					ABBYY_Quota_Notification	
				WHERE 
					Created_Date BETWEEN @StartDate AND @EndDate
			END
	</cfquery>

<cfdump var="#qNotificationSent#" />
	<cfif (isDefined("qNotificationSent") and qNotificationSent.RecordCount EQ 0)>
			<cfset remainingPages = 20000 - qGetTotalPages.TotalPages_Extracted />
			<cfmail to="#toEmail#" from="#fromEmail#" type="HTML" subject="CIA-Error: Abbyy page limit is reaching on '#qDBName.DBName#'">
				#remainingPages# pages remain before #DateFormat(qGetTotalPages.QuotaEnd,"mm/dd/yyyy")#. Please work withNupur Patelto see if Abbyy license can be updated. 
				<br><br>
				- CIA Team
			</cfmail>
			<cfset useLakebaseForqInsertQuotaNotificaiton = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("abbyy_quota_notification")>
<cfif useLakebaseForqInsertQuotaNotificaiton>
	<cftry>
		<cfset application.oLakebase.insertRow("abbyy_quota_notification", {
			"email_sent" = "1",
			"created_date" = "#now()#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsertQuotaNotificaiton = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsertQuotaNotificaiton>
<cfquery name="qInsertQuotaNotificaiton" datasource="#application.datasource#">
				INSERT INTO 
					ABBYY_Quota_Notification (Email_Sent,Created_Date)
					VALUES
					(
						1,
						GetDate()
					)
			</cfquery>
</cfif>
	</cfif>
</cfif>

<!--- 
</body>
</html>
 --->