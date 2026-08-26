<cfset UsersIP = CGI.Remote_Addr>

  <!--- Dev Notes: 23086/Anand Rao/21-May-10: User Traffic Changes --->    
 
<cfparam name="varAuditAction" default="" />
<cfparam name="varUser_Code" default="" />
<cfparam name="varUser_ID" default="" />
<cfparam name="insLoginIP" default = 0 />
<cfparam name="LoginIPstatus" default = 0 />

<cfif  (varAuditAction NEQ "" AND varUser_Code NEQ "" AND varUser_ID NEQ "")>
  <cfquery name="AddUserTransLockedOut" datasource="#application.datasource#">
  	INSERT INTO Audit_User_Transactions(Trans_Type,Trans_User_Code,Trans_IP_Address,Trans_By_User_ID,Browser)
  	VALUES
  	(
  	  <cfqueryparam value="#varAuditAction#" cfsqltype="CF_SQL_VARCHAR">,
  		<cfqueryparam value="#varUser_Code#" cfsqltype="CF_SQL_VARCHAR">,
  		<cfqueryparam value="#UsersIP#" cfsqltype="CF_SQL_VARCHAR">, 
  		<cfqueryparam value="#varUser_ID#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="#HTTP_USER_AGENT#" cfsqltype="CF_SQL_VARCHAR">
  	)
  </cfquery>
</cfif>

<cfif (insLoginIP EQ 1)>
  <cfquery name="qryRecent" datasource="#application.datasource#">
    SELECT TOP 1 User_Code,Status,DATEDIFF(mi,Date_Time, GETDATE()) AS LoginInterval FROM	LoginIP ORDER BY Date_Time DESC
  </cfquery>

 	<!--- 
				Dev Notes: D24554 /Anand Rao/27-Aug-10
				Vantage - Audit universe not refreshing 
        Make an insert into the LoginIP table only if the User_code is the same but the status is different or if it is a 
        different User_Code from the previously inserted user_code.  That way we will avoid duplicate insertion of the same
        record. Also, if the user is trying to login withing 2 mins do not insert.
	--->
   
  <cfif ( NOT qryRecent.recordcount 
        OR ((qryRecent.User_Code EQ varUser_Code) AND (qryRecent.Status NEQ LoginIPStatus)) 
        OR (qryRecent.User_Code NEQ varUser_Code) 
        OR (qryRecent.User_Code EQ varUser_Code AND qryRecent.LoginInterval GTE 2) )>
    <cfquery name="AddIP" datasource="#application.datasource#">
    	INSERT INTO LoginIP (IP_Address, User_Code, Status)
    	VALUES (	<cfqueryparam value="#UsersIP#" cfsqltype="CF_SQL_VARCHAR">, 
    				<cfqueryparam value="#varUser_Code#" cfsqltype="CF_SQL_VARCHAR">, 
    				<cfqueryparam value="#LoginIPstatus#" cfsqltype="CF_SQL_BIT">)
    </cfquery>
  </cfif>
  
</cfif>
