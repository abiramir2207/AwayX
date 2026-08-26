<Cfswitch expression="#Payee_Type#">
		<CFCASE value = 1>
			<cfquery name="GetPayeeID" datasource="#application.datasource#">
		SELECT Billback_Distributor.Distributor_ID AS Payee_ID
		FROM Billback_Distributor
		WHERE Billback_Distributor.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND Deleted = 0
			</cfquery>
		</CFCASE>
		<CFCASE value = 2>
			<cfquery name="GetPayeeID" datasource="#application.datasource#">
		SELECT Billback_Operator.Operator_ID AS Payee_ID
		FROM Billback_Operator
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND Deleted = 0
			</cfquery>
		</CFCASE>
		<CFCASE value = 3>
			<cfquery name="GetPayeeID" datasource="#application.datasource#">
		SELECT Broker_ID AS Payee_ID
		FROM Billback_Broker
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND Deleted = 0
			</cfquery>
		</CFCASE>
		<CFCASE value = 4>
			<cfquery name="GetPayeeID" datasource="#application.datasource#">
		SELECT Billback_Unidentified_Payee_Id AS Payee_ID
		FROM Billback_Unidentified_Payee
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND Deleted = 0
			</cfquery>
		</CFCASE>
		<CFCASE value = 5>
			<cfquery name="GetPayeeID" datasource="#application.datasource#">
		SELECT Billback_Distributor_ID AS Payee_ID
		FROM Billback_Distributor
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND Deleted = 0
			</cfquery>
		</CFCASE>
		<CFCASE value = 6>
			<cfquery name="GetPayeeID" datasource="#application.datasource#">
		SELECT Billback_Operator_ID AS Payee_ID
		FROM Billback_Operator
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND Deleted = 0
			</cfquery>
		</CFCASE>
		<CFCASE value = 7>
			<cfquery name="GetPayeeID" datasource="#application.datasource#">
		SELECT Billback_Broker_ID AS Payee_ID
		FROM Billback_Broker
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND Deleted = 0
			</cfquery>
		</CFCASE>
	</CFSWITCH>
	 <cfset Payee_ID = GetPayeeID.Payee_ID> 