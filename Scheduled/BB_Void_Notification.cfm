<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">

 <CFQUERY NAME="GetBBVoid" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT Billback.Billback_ID,
				BB_Code, 
				BB_title,
				BB_Date,
				BB_Void_Date,
				Approved_By,
				Approved_Date, 
				Name_First, 
				Name_Last, 
				User_Email 
				
	FROM 		Billback 
	INNER JOIN	Gl_Code_Allocation ON Gl_Code_Allocation.Billback_ID = Billback.Billback_ID AND Allocation_Saved = 1 AND Gl_Code_Allocation.Deleted = 0
	INNER JOIN 	_users ON _users.User_ID = Gl_Code_Allocation.Approved_By
	WHERE 		Billback_Status_ID = 8 AND BB_Void_Multiplier < 0 AND 
				BB_Void_Notification_Sent = 0 AND Billback.Deleted = 0 AND
				User_Email IS NOT NULL AND LEN(User_Email) > 0
</CFQUERY>

<CFOUTPUT>
<CFLOOP QUERY="GetBBVoid">	
	<CF_EMAILWRAPPER TO		=	"#User_Email#"
        FROM		=	"#Contact_Admin_Email_Address#"
        SUBJECT		=	"Billback Payment Void Notification"
		TYPE		=	"html" 
		messagetype="1" 
		generatedby="1" 
		apparea="3" >
		
		<TABLE WIDTH="100%">		
		<TR VALIGN="top">
		<TD>
		Check passed for the Billback <B>#BB_Code#</B> "#BB_title#, #DATEFORMAT(BB_Date,"mm/dd/yyyy")#" became VOID and this billback has been set to "APPROVED - VOID" status on #DATEFORMAT(BB_Void_Date,"mm/dd/yyyy")#.
		</TD>
		</TR>		
		</TABLE>	
	</CF_EMAILWRAPPER>
	
	<cfset useLakebaseForUpdateSentBit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForUpdateSentBit>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#Billback_ID#"
			},
			{
				"bb_void_notification_sent" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateSentBit = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateSentBit>
<CFQUERY NAME="UpdateSentBit" DATASOURCE="#Application.Datasource#">
		UPDATE Billback
		SET BB_Void_Notification_Sent = 1
		WHERE Billback_ID = '#Billback_ID#'
	</CFQUERY>
</cfif>		
</CFLOOP>
</CFOUTPUT> 


