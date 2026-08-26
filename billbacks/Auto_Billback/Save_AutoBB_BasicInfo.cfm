<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFIF FORM.BBID NEQ "">
	<CFQUERY NAME="UpdateData" DATASOURCE="#Application.Datasource#">
		UPDATE 	BillBack
		
		SET 	BB_Title 					= <cfqueryparam value="#FORM.BB_Title#" cfsqltype="CF_SQL_VARCHAR">,
				BB_Date 					= <cfqueryparam value="#FORM.BB_Date#" cfsqltype="CF_SQL_DATE">,
				BB_Start_Date			 	= <cfqueryparam value="#FORM.BB_Start_Date#" cfsqltype="CF_SQL_DATE">,
				BB_End_Date					= <cfqueryparam value="#FORM.BB_End_Date#" cfsqltype="CF_SQL_VARCHAR">,
				BB_Reference				= <cfqueryparam value="#FORM.BB_Reference#" cfsqltype="CF_SQL_VARCHAR">,
				BB_Creator_Notes			= <cfqueryparam value="#FORM.BB_Creator_Notes#" cfsqltype="CF_SQL_LONGVARCHAR">,
				BB_Code						= <cfqueryparam value="#FORM.BB_Code#" cfsqltype="CF_SQL_VARCHAR">,
				Billback_Payee_Type_ID		= 1,
				BB_UP						= 0,
				BB_PNF						= 0,
				Comments					= <cfqueryparam value="#FORM.comments#" cfsqltype="CF_SQL_LONGVARCHAR">,
				Auto_Billback				= 1
				
		WHERE 	Billback_ID = <cfqueryparam value="#FORM.BBID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>
	<CFSET Billback_ID = FORM.BBID>
<CFELSE>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Get the user position for this user																	 --->	
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	<cfset userPositionId = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.User_ID) />
	<CFQUERY NAME="InsertData" DATASOURCE="#Application.Datasource#">
		INSERT INTO 
		
		BillBack	(	BB_Title,
						BB_Date,
						BB_Start_Date,
						BB_End_Date,
						BB_Reference,
						BB_Creator_ID,
						BB_Creator_Notes,
						BB_Code,
						BB_Creator_User_Position_ID,
						Billback_Status_ID,
						Billback_Payee_Type_ID,
						BB_UP,
						BB_PNF,
						Comments,
						Auto_Billback					)
						
		VALUES		(	<cfqueryparam value="#FORM.BB_Title#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#FORM.BB_Date#" cfsqltype="CF_SQL_DATE">,
						<cfqueryparam value="#FORM.BB_Start_Date#" cfsqltype="CF_SQL_DATE">,
						<cfqueryparam value="#FORM.BB_End_Date#" cfsqltype="CF_SQL_DATE">,
						<cfqueryparam value="#FORM.BB_Reference#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#FORM.BB_Creator_Notes#" cfsqltype="CF_SQL_LONGVARCHAR">,
						<cfqueryparam value="#FORM.BB_Code#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#userPositionId#" cfsqltype="CF_SQL_INTEGER">,
						1,
						1,
						0,
						0,
						<cfqueryparam value="#FORM.comments#" cfsqltype="CF_SQL_LONGVARCHAR">,
						1			)
	</CFQUERY>	
	<CFSET Billback_ID = InsertData.Billback_ID>
	
	<CFIF len(trim(Billback_ID)) GT 0>
		<cfquery name="UnlockLockedBillbacks" datasource="#Application.Datasource#">
			UPDATE 
				Billback_Allied
			SET 
				BB_Is_Locked 			= 0,
				BB_Locked_By_User_ID 	= <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
				BB_Lock_Date 			= GetDate()
			WHERE 
				BB_Is_Locked = 1
				AND
				BB_Locked_By_User_ID 	= <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
				AND
				Billback_ID <>  <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
				AND BB_Locked_By_Match_Central = 0
		</cfquery>
	
	
		<cfquery name="ToggleLockStatus" datasource="#Application.Datasource#">
			UPDATE 
				Billback_Allied
			SET 
				BB_Is_Locked 			= 1,
				BB_Locked_By_User_ID 	= <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
				BB_Lock_Date 			= GetDate()
			WHERE 
				Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
	
	</cfif>
</CFIF>



<CFLOCATION URL="AutoBB_Distributor_Program_Form.cfm?BBID=#Billback_ID#" ADDTOKEN="No">

</body>
</html>
