<cftransaction>
	<!---What are the names to enter?--->
	
	<cfquery name="DeleteExistingLSNames" datasource="#application.datasource#">
	Delete From Program_Lump_Sum_Name
	WHERE active = 0
	</cfquery> 
		
	<cfquery name="GetAllDistinctExistingLSNames" datasource="#application.datasource#">
	INSERT INTO Program_Lump_Sum_Name
		(
			Program_Lump_Sum_Name,
			Deleted,
			Active,
			CreatedDate
		)
	SELECT DISTINCT Lump_Sum_Name, 0, 0, GetDate()
	FROM Program_Lump_Sums 
	</cfquery> 

	
	<!---Now match the lump sum entries with name to their appropriate id number--->
	
	<cfquery name="InsertIDsforNames" datasource="#application.datasource#">
	UPDATE Program_Lump_Sums
	SET Program_Lump_Sum_Name_ID = (Select Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID FROM Program_Lump_Sum_Name WHERE Program_Lump_Sum_Name.Program_Lump_Sum_Name = Program_Lump_Sums.Lump_Sum_Name)
	</cfquery>

</cftransaction>


	
	
	<!--- 
	
	<cfquery name="GetAllDistinctExistingLSNames" datasource="#application.datasource#">
	SELECT DISTINCT Lump_Sum_Name
	FROM Program_Lump_Sums 
	</cfquery>
	
	<!---stick them into the name table as inactive--->
	<cfloop query="GetAllDistinctExistingLSNames">
		<cfquery name="InsertIntoOptions" datasource="#application.datasource#">
		INSERT INTO Program_Lump_Sum_Name
		(
			Program_Lump_Sum_Name,
			Deleted,
			Active,
			CreatedDate
		)
		VALUES	
		(
			'#Lump_Sum_Name#',
			0,
			0,
			#Now()#
		)
		</cfquery>
	</cfloop>--->