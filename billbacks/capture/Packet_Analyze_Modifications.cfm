<CFSET ExistingBillback = Billback>
<CFSET LoadBillbackID = Billback.Billback_ID>
<CFSET Billback = "">
<cfinclude template="load_billback_to_struct.cfm">

<CFSET OriginalBillback	= Billback>
<CFSET Billback = "">

<CFDUMP var="#ExistingBillback#">
<BR>
<CFDUMP var="#OriginalBillback#">

<CFSET Bilback_Program_ID_List_New 								= "">
<CFSET Bilback_Program_ID_List_Original 						= "">
<CFSET Bilback_Program_Index_To_Add_To_Billback 				= "">
<CFSET Bilback_Program_Index_To_Add_To_Billback_Returned_Keys 	= "">

<!--- loop through existing billback  --->
<cfloop index="x" from="1" to="#ExistingBillback.Programs.Count#" step="1">
	<CFSET Program = "">
	<CFSET Program = evaluate("ExistingBillback.Programs.Program_#x#")>
	
	<CFIF isdefined("Program.BILLBACK_PROGRAM_ID")>
	<!--- add to existing list --->
		<CFSET Bilback_Program_ID_List_New = listappend(Bilback_Program_ID_List_New,Program.BILLBACK_PROGRAM_ID)>
	<CFELSE>
	<!--- record index of program to add --->
		<CFSET Bilback_Program_Index_To_Add_To_Billback = listappend(Bilback_Program_Index_To_Add_To_Billback, x)>
	</CFIF>
</CFLOOP>

<!--- [array index][existing program index][product index] --->
<CFSET addtheseproducts = ArrayNew(3)>
<!--- [array index][original program index][product index] --->
<CFSET deletetheseproducts = ArrayNew(3)>

<!--- loop through original billback  --->
<cfloop index="x" from="1" to="#OriginalBillback.Programs.Count#" step="1">
	<CFSET Program = "">
	<CFSET Program = evaluate("OriginalBillback.Programs.Program_#x#")>
	
	<CFIF isdefined("Program.BILLBACK_PROGRAM_ID")><!--- add to existing list --->
		<CFSET Bilback_Program_ID_List_Original = listappend(Bilback_Program_ID_List_Original,Program.BILLBACK_PROGRAM_ID)>
	</CFIF>
</CFLOOP>

<CF_List_Compare List1="#Bilback_Program_ID_List_New#" List2="#Bilback_Program_ID_List_Original#">
<CFSET Billback_Program_Id_List_To_Delete = listqualify(LC_Results2, "'")>

<!--- Delete Program --->
<CFIF listlen(Billback_Program_Id_List_To_Delete) GT 0>
	<cfquery name="DeleteBillbackPrograms" datasource="#Application.Datasource#">
		UPDATE Billback_Program
		SET Deleted = 1
		WHERE
			BillBack_Program_ID IN(#PreserveSingleQuotes(Billback_Program_Id_List_To_Delete)#)  AND Deleted = 0
	</cfquery>

	<cfquery name="DeletedProductIDs" datasource="#Application.Datasource#">
		SELECT Billback_Product_ID
		FROM Billback_Product
		WHERE
			BillBack_Program_ID IN(#PreserveSingleQuotes(Billback_Program_Id_List_To_Delete)#) AND Deleted = 0
	</cfquery>
	
	<cfquery name="DeleteBillbackProgramProducts" datasource="#Application.Datasource#">
		UPDATE Billback_Product
		SET Deleted = 1
		WHERE
			BillBack_Program_ID IN(#PreserveSingleQuotes(Billback_Program_Id_List_To_Delete)#) AND Deleted = 0
	</cfquery>	
	
	
	<CFSET ListOfProductIDS = listqualify(valuelist(DeletedProductIDs.Billback_Product_ID), "'")>
	<CFIF listlen(ListOfProductIDS) GT 0>
		<cfquery name="DeleteBillbackProgramProductDetail" datasource="#Application.Datasource#">
			UPDATE Billback_Product_Detail
			SET Deleted = 1
			WHERE
				BillBack_Product_ID IN(#PreserveSingleQuotes(ListOfProductIDS)#) AND Deleted = 0
		</cfquery>
	</CFIF>
</CFIF>

<!--- Add Program --->
<CFIF listlen(Bilback_Program_Index_To_Add_To_Billback) GT 0>
	<cfloop index="BillbackStructIndex" list="#Bilback_Program_Index_To_Add_To_Billback#">
		<CFSET Program = "">
		<CFSET Program = evaluate("ExistingBillback.Programs.Program_#BillbackStructIndex#")>
		<CFSET InsertProgram = QueryNew("Blah")>
		<cfswitch expression="#Program.Program_Type_ID#">
				<CFCASE value="1"> <!--- known Program --->
					<cfset useLakebaseForInsertProgram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForInsertProgram>
	<cftry>
		<cfset application.oLakebase.insertRow("billback_program", {
			"billback_id" = "#ExistingBillback.Billback_ID#",
			"program_id" = "#Program.Program_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertProgram = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertProgram>
<cfquery name="InsertProgram" datasource="#Application.Datasource#">
						INSERT INTO Billback_Program
						(
							Billback_ID,
							Program_ID
						)
						VALUES
						(
							'#ExistingBillback.Billback_ID#',
							'#Program.Program_ID#'
						)
					</cfquery>
</cfif>
					<CFSET Bilback_Program_Index_To_Add_To_Billback_Returned_Keys = listappend(Bilback_Program_Index_To_Add_To_Billback_Returned_Keys,InsertProgram.Billback_Program_ID)>
				</CFCASE>
				<CFCASE value="2"> <!--- unknown Program --->
					<cfquery name="InsertProgram" datasource="#Application.Datasource#">
						INSERT INTO Billback_Program
						(
							Billback_ID,
							Program_ID,
							BB_Program_Number,
							BB_Program_Title,
							BB_Program_Notes
						)
						VALUES
						(
							'#ExistingBillback.Billback_ID#',
							'#Program.Program_ID#',
							'#Program.Program_Number#',
							'#Program.Program_Title#',
							'#Program.Program_Notes#'
						)
					</cfquery>
					<CFSET Bilback_Program_Index_To_Add_To_Billback_Returned_Keys = listappend(Bilback_Program_Index_To_Add_To_Billback_Returned_Keys,InsertProgram.Billback_Program_ID)>
				</CFCASE>
			</CFSWITCH>
	</CFLOOP>
</CFIF>




<!--- <cfabort> --->