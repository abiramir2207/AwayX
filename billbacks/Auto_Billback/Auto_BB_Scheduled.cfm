
<CFQUERY NAME="deletePre" DATASOURCE="#Application.Datasource#">
	UPDATE 	Billback_Auto_Scheduled_Creation
	SET 	Deleted = 1
	WHERE 	Scheduled_Auto_BB = 1 AND 
			Auto_BB_Created = 0 AND 
			Deleted = 0 AND 
			DATEDIFF(d,created_Date,getdate()) = 0
</CFQUERY>

<CFQUERY NAME="EligibleProg" DATASOURCE="#Application.Datasource#">
	EXEC AUTO_BB_ELIGIBLE_PROGRAM_INSERT
</CFQUERY>

<CFQUERY NAME="CheckAny" DATASOURCE="#Application.Datasource#">
	SELECT 	TOP 1 *

	FROM 	Billback_Auto_Scheduled_Creation 
	
	WHERE 	Scheduled_Auto_BB = 1 AND 
			Auto_BB_Created = 0 AND 
			Deleted = 0 AND 
			DATEDIFF(d,created_Date,getdate()) = 0
</CFQUERY>

<CFIF CheckAny.RecordCount GT 0>
	<CFQUERY NAME="InsertBillBackDetails" DATASOURCE="#Application.Datasource#">
		EXEC Auto_BB_Creation
	</CFQUERY>
	
	<CFQUERY NAME="EligibleBB" DATASOURCE="#Application.Datasource#">
		SELECT 	Billback_ID,Discount_Type_ID 
		FROM 	Billback_Auto_Scheduled_Creation 
		WHERE 	Scheduled_Auto_BB = 1 AND 
				Auto_BB_Created = 0 AND 
				Deleted = 0 AND 
				DATEDIFF(d,created_Date,getdate()) = 0
	</CFQUERY>
	<CFSET FromScheduledAutoBB = 1>

	<CFLOOP QUERY="EligibleBB">		
		
		<CFQUERY NAME="GetDistri" DATASOURCE="#Application.Datasource#">
			SELECT 	* 
			FROM 	Billback_Distributor 
			WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> 
			AND 	Deleted = 0
		</CFQUERY>	
		<CFSET FORM.Distributor_List = "">
		<CFSET FORM.Distributor_List = GetDistri.Distributor_ID>
		<CFIF Discount_Type_ID EQ 2>
			<CFINCLUDE TEMPLATE="Auto_BB_Sche_Rebate.cfm">
		<CFELSEIF Discount_Type_ID EQ 4>
			<CFINCLUDE TEMPLATE="Auto_BB_Sche_Rebate.cfm">
		</CFIF>
		
		
		

		<!--- Delete all Billback_Product_Detail entries and Billback_product entries (if necessary) that has 0 rate --->
		<CFQUERY NAME="GetRateZero" DATASOURCE="#Application.Datasource#">
			SELECT 	DISTINCT 	Billback_Product_ID
			FROM 				Billback_Product_Detail 
			WHERE 				Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND					CAST(BB_Rate AS Float) <= 0
			AND					Deleted = 0
		</CFQUERY>
		
		<CFQUERY NAME="DeleteAllRateZeros" DATASOURCE="#Application.Datasource#">
			UPDATE 	Billback_Product_Detail
			
			SET 	Deleted = 1
			
			WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND		CAST(BB_Rate AS Float) <= '0'
			AND		Deleted = 0
		</CFQUERY>
		
		
		<CFLOOP QUERY="GetRateZero">	
			<CFQUERY NAME="CheckOtherProductTypeFortheSameID" DATASOURCE="#Application.Datasource#">
				SELECT 	* 
				
				FROM 	Billback_Product_Detail 
				
				WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
				AND		Billback_Product_ID = <cfqueryparam value="#Billback_Product_ID#" cfsqltype="CF_SQL_VARCHAR">
				AND		Deleted = 0
			</CFQUERY>
		
		
			<CFIF CheckOtherProductTypeFortheSameID.RecordCount EQ 0>
				<CFQUERY NAME="DeleteThisProductFromBBProduct" DATASOURCE="#Application.Datasource#">
					UPDATE 	Billback_Product
					
					SET 	Deleted = 1
					
					WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
					AND		Billback_Product_ID = <cfqueryparam value="#Billback_Product_ID#" cfsqltype="CF_SQL_VARCHAR">
					AND		Deleted = 0
				</CFQUERY>
			</CFIF>	
		</CFLOOP>
		
		
		<!--- Check for volume Zero and less than zero --->
		<CFQUERY NAME="GetZeroVolume" DATASOURCE="#Application.Datasource#">
			SELECT  Billback_Product_ID
			FROM    Billback_Product
			WHERE  	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND		(CAST(BB_Product_Quantity as Float) <= '0')
			AND		Deleted = 0
		</CFQUERY>
		<CFSET ProductsWithZeroVol = VALUELIST(GetZeroVolume.Billback_Product_ID)>
		<CFIF ProductsWithZeroVol NEQ "">
			<CFQUERY NAME="DeleteFromDetails" DATASOURCE="#Application.Datasource#">
				UPDATE 	Billback_Product_Detail
				
				SET 	Deleted = 1
				
				WHERE 	Billback_Product_ID IN (	SELECT  Billback_Product_ID
													FROM    Billback_Product
													WHERE  	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
															(CAST(BB_Product_Quantity as Float) <= '0') AND
															Deleted = 0										) AND 
						Deleted = 0 
			</CFQUERY>
			
			<CFQUERY NAME="DeleteFrom" DATASOURCE="#Application.Datasource#">
				Update Billback_Product
				
				SET Deleted = 1
				
				WHERE 	Billback_Product_ID IN (	SELECT  Billback_Product_ID
													FROM    Billback_Product
													WHERE  	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
															(CAST(BB_Product_Quantity as Float) <= '0') AND
															Deleted = 0										) AND 
						Deleted = 0 
			</CFQUERY>
		</CFIF>
		
		
		
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!--- Product Hierarchy Details --->
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		
		<CFQUERY NAME="getGroupLevelBB" DATASOURCE="#Application.Datasource#">
			SELECT 		aaa.GroupLevelBB
			
			FROM 		Billback_Program 
			INNER JOIN 	Contract_Main ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
			INNER JOIN 	Program_Latest_Template_ID ON Program_Latest_Template_ID.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
			INNER JOIN 	Program_Control_Panel_Options aaa ON aaa.ProgramControl_Panel_Options_ID = Program_Latest_Template_ID.Latest
			WHERE 		Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND 		Billback_Program.Deleted = 0	
		</CFQUERY>
		
		<CFIF getGroupLevelBB.GroupLevelBB EQ 1>
			<CFQUERY NAME="SetPHBB" DATASOURCE="#Application.Datasource#">
				UPDATE 	Billback_Program
				SET 	Display_Product_Hierarchy = 1
				WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
				AND 	Deleted = 0
			</CFQUERY>
			<CFQUERY NAME="UpdateDeleted" DATASOURCE="#Application.Datasource#">
				UPDATE 	Billback_Product
				SET 	Deleted = 1
				WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
						Deleted = 0 AND
						Billback_Product_ID NOT IN ( 	SELECT DISTINCT Billback_Product_ID 
														FROM Billback_Product_Detail 
														WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0 
													)
			</CFQUERY>
			<CFQUERY NAME="GetHierarchy" DATASOURCE="#Application.Datasource#">
				UPDATE 	Billback_Product
				SET 	Product_Hierarchy_ID = (SELECT Product_Hierarchy_ID FROM BSA_Foodservice_Items_Master WHERE BSA_Foodservice_Items_Master_ID = Product_ID)
				WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Billback_Product.Deleted = 0
			</CFQUERY>
			
			<CFQUERY NAME="GetDistinctPG" DATASOURCE="#Application.Datasource#">
				SELECT 	DISTINCT Product_Hierarchy_ID
				FROM 	Billback_Product 
				WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
			</CFQUERY>
			
			<CFLOOP QUERY="GetDistinctPG">
				<CFIF Product_Hierarchy_ID NEQ "">
					<CFQUERY NAME="Updatevolume" DATASOURCE="#Application.Datasource#">
						UPDATE 	Billback_Product
						SET 	Product_Hierarchy_Volume = (	SELECT 	SUM(Cast(BB_product_Quantity AS FLoat)) 
																FROM 	Billback_Product 
																WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
																		Deleted = 0 AND 
																		Product_Hierarchy_ID = <cfqueryparam value="#Product_Hierarchy_ID#" cfsqltype="CF_SQL_VARCHAR">	)
						WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
								Deleted = 0 AND 
								Product_Hierarchy_ID = <cfqueryparam value="#Product_Hierarchy_ID#" cfsqltype="CF_SQL_VARCHAR">
					</CFQUERY>
					
					<CFQUERY NAME="UpdatePHRate" DATASOURCE="#Application.Datasource#">
						UPDATE 	Billback_Product_Detail
						SET 	Product_Hierarchy_Rate = (	SELECT  SUM(CAST(BB_Rate AS Float)) 
															FROM 	Billback_Product_Detail
															WHERE 	Deleted = 0 AND 
																	Billback_Product_ID IN (	SELECT 	Billback_Product_ID 
																								FROM 	Billback_Product 
																								WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
																										Deleted = 0 AND 
																										Product_Hierarchy_ID = <cfqueryparam value="#Product_Hierarchy_ID#" cfsqltype="CF_SQL_VARCHAR">
																							) 
															)
						WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
								Deleted = 0 AND 
								Billback_Product_ID IN (	SELECT 	Billback_Product_ID 
															FROM 	Billback_Product 
															WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
																	Deleted = 0 AND 
																	Product_Hierarchy_ID = <cfqueryparam value="#Product_Hierarchy_ID#" cfsqltype="CF_SQL_VARCHAR">
														)
					</CFQUERY>
				</CFIF>
			</CFLOOP>
		</CFIF>
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!--- End Product Hierarchy Details --->
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		
		
		<CFQUERY NAME="BBCreated" DATASOURCE="#Application.Datasource#">
			UPDATE Billback_Auto_Scheduled_Creation
			SET Auto_BB_Created = 1
			WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>
		
		
	</CFLOOP>
</CFIF>

