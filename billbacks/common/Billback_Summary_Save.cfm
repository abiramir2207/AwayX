<!---------------------------------------------------
This Page gets the Content for Billback Summary
and saves it to a file
and return the file name
---------------------------------------------------->

<!---------------------------------------------------
<CFINCLUDE TEMPLATE="Billback_Summary_Save.cfm">
input variable : Billback_ID
	Which is the uniqueidentifier that represents a Billback
input variable : Billback_HTML_File_Path
	App Relative Path to the Saved HTML File
---------------------------------------------------->

<STYLE TYPE="text/css">
	<CFINCLUDE TEMPLATE="/Common_Files/main_Style.css">
</style>
	
<cfset ShowButtons = 1>

<cfif isDefined("url.Referrer") and url.Referrer IS "Payment">
	<cfset url.Billback_ID = Billback_ID>
	<CFSAVECONTENT VARIABLE="Billback_Summary_Content">
		
		<CFINCLUDE TEMPLATE="../approval/payment_display.cfm">
	</CFSAVECONTENT>
<cfelseif isDefined("url.Referrer") and url.Referrer IS "Deviation">
	<cfset url.BBID = Billback_ID>
	<cfset url.SHOW_FAX_EMAIL_VERSION = 1>
	<CFSAVECONTENT VARIABLE="Billback_Summary_Content">		
		<CFINCLUDE TEMPLATE="/Billbacks/Deviation/Deviation.cfm">
	</CFSAVECONTENT>
	
	<CFSET Billback_Summary_Content = ReplaceNoCase(Billback_Summary_Content, "<DIV ID=""Total_BB_Deviation"" STYLE=""display: inline;color:Red;"">$</DIV>", "<DIV STYLE=""display: inline;color:Red;"">#DollarFormat(Total_Billback_Deviation)#</DIV>")>
	<CFSET Billback_Summary_Content = ReplaceNoCase(Billback_Summary_Content, "<DIV ID=""Total_BB_Deviation_Percent"" STYLE=""display: inline;color:Red;"">%</DIV>", "<DIV STYLE=""display: inline;color:Red;"">#NumberFormat(Total_Billback_Deviation_Percent,"_.__")#%</DIV>")>
	
<cfelse>
<cfset url.show_email_version = 1>
	<CFSAVECONTENT VARIABLE="Billback_Summary_Content">
		<CFINCLUDE TEMPLATE="../capture/Billback_Summary_Content.cfm">
		<!--- <BR><BR><BR>
		<CFINCLUDE TEMPLATE="/Common_Files/Email_Footer.cfm"> --->
	</CFSAVECONTENT>
</cfif>

<!------ DEV NOTE DRK D9471 - removeforemail is a dummy tag in the summary content page 
so that we can remove this edit link on email/fax/print etc., please don't remove ----->
<cfset baseFunctions = CreateObject("component", "components.Base") />
<CFSET Billback_Summary_Content = baseFunctions.stripHTMLTag(Billback_Summary_Content, "script") />	
<CFSET Billback_Summary_Content = baseFunctions.stripHTMLTag(Billback_Summary_Content, "removeforemail") />


<!--- Date/Time stamp construction to be used in the naming scheme of the file --->
<CFSET datetimestamp="#numberformat(month(now()),'00')##numberformat(day(now()),'00')##numberformat(year(now()),'0000')##numberformat(hour(now()),'00')##numberformat(minute(now()),'00')##numberformat(second(now()),'00')#">

<!--- Build file name --->
<CFSET filename_email	=	"#Billback_Payable_Number#_#datetimestamp#_#gettickcount()#">

<CFSET Billback_HTML_File_Path="\temp_files\billback\HTML_Billbacks\#filename_email#.htm">

<!--- create usable directory information --->
<CFSET The_File_Location = Application.Doc_path & Billback_HTML_File_Path>
<!--- end create usable directory information --->	

<!--- Build complete path --->
<CFSET completepath=The_File_Location>


<!--- Save the file to the server --->
<cffile action="write" file="#completepath#" output="#Billback_Summary_Content#">


<!------ Get application settings ----->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>


<!--- Get the Recipient Emails --->
<CFQUERY NAME="Get_Recipient_Emails" datasource="#application.datasource#">
	SELECT 
	CASE
	---------When Payee is a Known Distributor----------------------------------
		WHEN Billback.Billback_Payee_Type_ID=1 THEN  
			<cfif NOT appSettings.getDistributorMultiPosition()>Customers_Brokers.E_Mail + ',' + </cfif>_Users.User_Email
	---------When Payee is a Known Broker----------------------------------
		WHEN Billback.Billback_Payee_Type_ID=3 THEN 
			BSA_Foodservice_Brokers.E_Mail + ',' + _Users.User_Email
	---------When Payee is Unidentified or Operator----------------------------------
		ELSE 
			_Users.User_Email
	
	END AS EMail_Address
	,
	CASE
	---------When Payee is a Known Distributor----------------------------------
		WHEN Billback.Billback_Payee_Type_ID=1 THEN  
			<cfif NOT appSettings.getDistributorMultiPosition()>'1' + Customers_Brokers.FAX_1 + Customers_Brokers.FAX_2 + Customers_Brokers.FAX_3 + ',' + </cfif>'1' + _Users.Work_Fax_1 + _Users.Work_Fax_2 + _Users.Work_Fax_3
	---------When Payee is a Known Broker----------------------------------
		WHEN Billback.Billback_Payee_Type_ID=3 THEN 
			'1' + BSA_Foodservice_Brokers.FAX_1 + BSA_Foodservice_Brokers.FAX_2 + BSA_Foodservice_Brokers.FAX_3 + ',' + '1' + _Users.Work_Fax_1 + _Users.Work_Fax_2 + _Users.Work_Fax_3
	---------When Payee is Unidentified or Operator----------------------------------
		ELSE 
			'1' + _Users.Work_Fax_1 + _Users.Work_Fax_2 + _Users.Work_Fax_3
	
	END AS Fax_Number
	FROM 
	Billback
	INNER JOIN
	_Users
	ON 
	Billback.BB_Creator_ID = _Users.User_ID
	------------------------------------------------------------------------- 
		LEFT JOIN 
			(
			Billback_Distributor
			LEFT JOIN 
				BSA_Foodservice_Customers
				ON 
				(Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID)				
			<cfif NOT appSettings.getDistributorMultiPosition()>
			INNER JOIN BSA_Foodservice_Brokers Customers_Brokers
				ON
				(BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID = Customers_Brokers.BSA_Foodservice_Brokers_ID)
			</cfif>
			)			
		ON
		(
		(Billback_Distributor.Billback_ID = Billback.Billback_ID)
		AND
		(Billback.Billback_Payee_Type_ID = 1)
		AND
		(Billback_Distributor.Deleted = 0)
		)
	
	-------------------------------------------------------------------------
		LEFT JOIN 
			(
			Billback_Broker
			LEFT JOIN
			BSA_Foodservice_Brokers
			ON
			(Billback_Broker.Broker_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID)
			)
		ON
		(
		(Billback_Broker.Billback_ID = Billback.Billback_ID)
		AND
		(Billback.Billback_Payee_Type_ID = 3)
		AND
		(Billback_Broker.Deleted = 0)
		)
	-------------------------------------------------------------------------
	WHERE
	Billback.Deleted = 0
	AND
	Billback.Billback_Status_ID = 1
	AND
	NOT (Billback.Billback_Payee_Type_ID IS NULL)
	
	AND
	(
		(
		NOT(Billback_Distributor.Billback_ID IS NULL) AND Billback.Billback_Payee_Type_ID = 1
		)		
		OR
		(
		NOT(Billback_Broker.Billback_ID IS NULL) AND Billback.Billback_Payee_Type_ID = 3
		)	
		OR
		(Billback.Billback_Payee_Type_ID = 2)
		OR
		(Billback.Billback_Payee_Type_ID >= 4)
	)
	AND
	Billback.Billback_ID = '#Billback_ID#'
</CFQUERY>
<!--- Clean the email list: replace commas with semi-colons and if the first is blank, remove it --->
<CFSET Billback_Recipient_Email_Address=rereplace(valuelist(Get_Recipient_Emails.EMail_Address), ",+", "; ", "All")>
<CFIF left(Billback_Recipient_Email_Address,1) EQ ";">
	<CFSET Billback_Recipient_Email_Address=mid(Billback_Recipient_Email_Address,3, len(Billback_Recipient_Email_Address))>
</CFIF>

<!--- Clean the fax list: replace commas with semi-colons and if the first is blank, remove it --->
<CFSET Billback_Fax_Numbers=rereplace(valuelist(Get_Recipient_Emails.Fax_Number), ",+", "; ", "All")>
<CFIF left(Billback_Fax_Numbers,1) EQ ";">
	<CFSET Billback_Fax_Numbers=mid(Billback_Fax_Numbers,3, len(Billback_Fax_Numbers))>
</CFIF>