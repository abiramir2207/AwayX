

<CFDUMP VAR="#FORM#">
<!--- <CFLOCATION URL="AutoBB_Distributor_Program_Form.cfm?BBID=#FORM.BBID#" ADDTOKEN="No"> --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the profile for this user																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFSET ProfileID =  Get_Profile_Settings.Profiles_ID>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFIF FORM.BBID NEQ "">
	<CFQUERY NAME="UpdateData" DATASOURCE="#Application.Datasource#">
		UPDATE 	BillBack
		
		SET 	Billback_Payee_Type_ID		= '1',
				BB_UP						= '0',
				BB_PNF						= '0'				
				
		WHERE 	Billback_ID = <cfqueryparam value="#FORM.BBID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>
	<CFSET Billback_ID = FORM.BBID>
</CFIF>

<!--- Distributor --->
<CFQUERY NAME="DelPreDist" DATASOURCE="#Application.Datasource#">
	UPDATE 	Billback_Distributor 
	
	SET 	Deleted = '1'
	
	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>


<CFQUERY NAME="InsertDistributor" DATASOURCE="#Application.Datasource#">
	INSERT INTO 
	
	Billback_Distributor (	Billback_ID,
							Distributor_ID,								
							BB_Distributor_Notes		)
							
	VALUES				(	<cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,
							<cfqueryparam value="#FORM.Distributor_List#" cfsqltype="CF_SQL_VARCHAR">,
							<cfqueryparam value="#FORM.NotesOnDistributor#" cfsqltype="CF_SQL_LONGVARCHAR">	)
</CFQUERY>


<!--- Programs --->
<CFQUERY NAME="DeleteExisting" DATASOURCE="#Application.Datasource#">
	UPDATE 	Billback_Program
	SET		Deleted = 1
	WHERE	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>

<CFLOOP LIST ="#FORM.Program_List#" INDEX="Item">
	<CFQUERY NAME="InsertPrograms" DATASOURCE="#Application.Datasource#">
		INSERT INTO 
		Billback_Program 	( 	Billback_ID,
								Program_ID		)
								
		VALUES				(	<cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#Item#" cfsqltype="CF_SQL_INTEGER">)
								
	</CFQUERY>		
</CFLOOP>

<CFSET IncludedInAuto_Distributor_Program_ActionCFM = 1>
<CFINCLUDE Template = "Auto_BB_Amount_Cal.cfm">
<!--- <CFLOCATION URL="Auto_BB_Amount_Cal.cfm?Billback_ID=#FORM.BBID#" ADDTOKEN="No"> --->