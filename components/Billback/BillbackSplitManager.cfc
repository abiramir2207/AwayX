<!---
Name: 			BillbackSplitManager.cfc
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:	N/A
Created By:		N/A
Description:	This file is responsible for splitting Billback data.  
--->

<cfcomponent hint="Billback Split Manager" extends="components.Base">
	
	<cffunction name="init" output="false" returntype="components.billback.BillbackSplitManager">
		<cfreturn this />
	</cffunction>

	<cffunction name="getExistingSplitChildren" access="public" returntype="query">
		<cfargument name="billbackID" Required="true" type="string">
		
		<CFQUERY NAME="Get_Parent_Details" DATASOURCE="#Application.Datasource#">
			SELECT 	ISNULL(BB_Parent_ID, Billback_ID) as  BB_Parent_ID
			FROM 	Billback 
			WHERE 	Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>
		
		<CFQUERY NAME="Get_All_Children" DATASOURCE="#Application.Datasource#">
			SELECT 		Billback.*,  BB_Approved.Paid_Amount
			FROM 		Billback 
			LEFT JOIN 	BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
			WHERE 		BB_Parent_ID = <cfqueryparam value="#Get_Parent_Details.BB_Parent_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND			Billback.Deleted = 0
			ORDER BY 	BB_Split_Number
		</CFQUERY>
		
		<cfreturn Get_All_Children />
		
	</cffunction>

	<cffunction name="SplitBillback" access="public" returntype="string">
		<cfargument name="billbackID" Required="true" type="string">
		<cfargument name="form" Required="true" type="struct">
		<cfargument name="splitCount" Required="true" type="numeric">
		<cfargument name="existingChildCount" Required="true" type="numeric">
		<cfargument name="payeeID" required="false" type="string" default="" />
		<cfargument name="autoReconcile" required="false" type="boolean" default="0" />
		<cfscript>
			
			var strPayeeID	= "";
			var amtTotal = 0;
			var amtToApply = 0;
			var rateToApply = 1;
			//assign local variables
			strPayeeID = trim(arguments.payeeID);
			LoopTill = arguments.splitCount;
			/*Auto reconcile does not leave a "remainder split".  Take the remainder an prorate it into the
			 splits created for the DD's getting closed
			*/
			if(autoReconcile){
				LoopTill = arguments.splitCount - 1;
				//calculate the Auto reconcile Update.  we reverse it since we are updating splits to create no remainder.
				amtToApply = evaluate('FORM.Amt_Child_#arguments.splitCount#') * -1;
				//get tot
				for (i=1;i LTE LoopTill;i=i+1) {
					amtTotal = amtTotal + Form['Amt_Child_#i#'];
				}
				rateToApply = amtTotal/(amtTotal-amtToApply);
				//calc how much to prorate each split
				for (i=1;i LTE LoopTill;i=i+1) {
					rate = Form['Amt_Child_#i#']/amtTotal;//we need a multiplier to adjust detail records
					Form['Rate_Child_#i#'] = rate;
					//Form['Amt_Child_Old_#i#'] = FORM['Amt_Child_#i#'];
					//Form['Amt_Child_#i#'] = evaluate('FORM.Amt_Child_#i#') + (amtToApply * rate);
				}
				Form['Amt_Total'] = amtTotal;
				//Form['Arguments'] = Arguments;
				
		//	writedump(var=Form,output='c:\dump.log');
		//	writedump(var=Local,output='c:\dump.log');
			/* abort;
			*/
			}
			
		</cfscript>

		<CFQUERY NAME="getThisUserPosition" datasource="#application.datasource#">
			SELECT 	User_Positions_ID
			FROM 	User_Position_Holders
			WHERE 	User_ID = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND 	User_Position_Type = 'P' AND  DELETED = 0
		</CFQUERY>
		<CFSET This_User_Position_ID = getThisUserPosition.User_Positions_ID>
		
		<!--- if auto reconcile we need to update the original (parent)  BB amounts to equal the sum of theselected DD's --->
		<cfif autoReconcile>
			<!--- update BB Amount --->
			<!---<CFQUERY NAME="qUpdBBAmt" DATASOURCE="#Application.Datasource#">
				UPDATE Billback 
				SET BB_Amount = Cast(#amtTotal# AS DECIMAL(16,4))
				WHERE 	Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR">
			</CFQUERY>--->
			<CFQUERY NAME="qUpdBBApproveAmt" DATASOURCE="#Application.Datasource#">
				UPDATE BB_Approved 
				SET
					Paid_Amount = Cast(#amtTotal# AS DECIMAL(16,4)),
					Approved_Amount = Cast(#amtTotal# AS DECIMAL(16,4))
					--,BB_Amount = Cast(#amtTotal# AS DECIMAL(16,4))
				WHERE 	Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR">
			</CFQUERY>
			<!--- Update Item data --->
				<CFQUERY NAME="qUpdBBItemFinAmt" DATASOURCE="#Application.Datasource#">
					UPDATE BIF
					SET	--Item_BB_Volume_CS = Item_BB_Volume_CS * #rateToApply#,
						--Item_BB_Volume_LB = Item_BB_Volume_LB * #rateToApply#,
						--Item_E_Volume_CS = Item_E_Volume_CS *  #rateToApply#,
						--Item_E_Volume_LB = Item_E_Volume_LB *  #rateToApply#,
						Item_Volume_Approved_CS = Item_Volume_Approved_CS * #rateToApply#,
						Item_Volume_Approved_LB = Item_Volume_Approved_LB * #rateToApply#,
						Item_Volume_Paid_CS = Item_Volume_Paid_CS * #rateToApply#,
						Item_Volume_Paid_LB = Item_Volume_Paid_LB * #rateToApply#,
						Item_Total_Paid = Item_Total_Paid * #rateToApply#
					FROM BB_Item_Final BIF
					WHERE BIF.Billback_ID =  <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR"> AND
							BIF.Deleted = 0
				</CFQUERY>
		</cfif>
		<!--- END Auto reconcile --->
		<CFQUERY NAME="Get_Billback_Columns" DATASOURCE="#Application.Datasource#">
			SELECT 		column_name 
			FROM 		information_schema.columns 
			WHERE 		table_name = 'Billback' AND
						column_name NOT IN ('Created_Date','Billback_ID','deleted','Check_number')			
		</CFQUERY>		
		<CFSET Column_List = VALUELIST(Get_Billback_Columns.column_name)>		
		<CFSET Column_List_Len = LISTLEN(Column_List,",")>		
		
		<CFQUERY NAME="Get_BB_Values" DATASOURCE="#Application.Datasource#">
			SELECT 	* 
			FROM 	Billback 
			WHERE 	Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>
		<CFQUERY NAME="Get_BB_Approved_Values" DATASOURCE="#Application.Datasource#">
			SELECT 	* 
			FROM 	BB_Approved
			WHERE 	Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>
		<cfif strPayeeID EQ "">
			<cfset strPayeeID = Get_BB_Approved_Values.Vendor_Master_ID />
		</cfif>
		<CFIF Get_BB_Values.BB_Is_Child NEQ 1>
			<CFSET Parent_ID = Get_BB_Values.Billback_ID>
		<CFELSE>
			<CFSET Parent_ID = Get_BB_Values.BB_Parent_ID>
		</CFIF>
		
		<CFSET AliveChildCount = arguments.existingChildCount />
		
		<CFSET ResetParentReasonCode = 0>
		<CFLOOP INDEX="LoopCount" FROM="1" TO="#LoopTill#">		
			
			<CFIF Isdefined("FORM.IsDeleted_#Loopcount#")>	
				<CFPARAM NAME="FORM.Closing_method_#LoopCount#" DEFAULT="1">		
				<CFSET CurLoopCount = 0>
				<CFSET CurColLoopCount = 0>			
				<CFIF EVALUATE("FORM.IsCreated_#Loopcount#") EQ 1>			
					<CFIF EVALUATE("FORM.IsDeleted_#Loopcount#") EQ 0>					
						<CFSET AliveChildCount = AliveChildCount + 1>									
						<CFOUTPUT>
 
	 
	
		<!--- <cftry> --->
		
						<CFQUERY NAME="Insert_Data" DATASOURCE="#Application.Datasource#">
							INSERT INTO 
							Billback 	(
											<CFLOOP LIST="#Column_List#" INDEX="Count">
												<CFSET CurColLoopCount = CurColLoopCount + 1>																								
												<CFIF Count NEQ "Billback_ID" AND Count NEQ "Created_Date" AND Count NEQ "Deleted" AND Count NEQ "check_number" AND Count NEQ "Billback_ID_Int"><!---  --->
													<CFIF CurColLoopCount NEQ Column_List_Len>
														#Count#,
													<CFELSE>
														#Count#
													</CFIF>													
												</CFIF>
											</CFLOOP>	
										)
							VALUES		(
											<CFLOOP LIST="#Column_List#" INDEX="Count">
												<CFSET CurLoopCount = CurLoopCount + 1>	
												<CFIF Count NEQ "Billback_ID" AND Count NEQ "Created_Date" AND Count NEQ "Deleted" AND Count NEQ "check_number" AND Count NEQ "Billback_ID_Int"><!---   --->												
													<CFIF Count NEQ "BB_Code" AND Count NEQ "BB_Amount" AND Count NEQ "BB_Creator_ID" AND Count NEQ "BB_Creator_User_Position_ID" AND Count NEQ "BB_Is_Child" AND Count NEQ "BB_Parent_ID" AND Count NEQ "BB_Split_Number" AND Count NEQ "BB_Split_Reason" AND Count NEQ "BB_BBID_Split_Number" AND Count NEQ "BB_Split_Date" AND Count NEQ "BB_Closing_Method">
														<CFIF EVALUATE("Get_BB_Values.#Count#") EQ "">
															NULL<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF> 
														<CFELSE>
															<cfqueryparam value="#EVALUATE("Get_BB_Values.#Count#")#" cfsqltype="CF_SQL_VARCHAR">	
															<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF> 
														</CFIF>													
													<CFELSE>
														<CFIF Count EQ "BB_Code">
															<CFIF LoopCount GT 9>
																<CFSET SPNUM = AliveChildCount>
															<CFELSE>
																<CFSET SPNUM = "0#AliveChildCount#">															
															</CFIF>
															
															<cfif (Get_BB_Values.Original_BB_Code EQ "")>
																<cfset vCode = Get_BB_Values.BB_Code />
																<cfset vCodeLen = len(vCode) />
																<cfif right(vCode,3) EQ "-00">
																	<cfset BBCode = Left(vCode,vCodeLen-3) />
																<cfelse>
																	<cfset BBCode = vCode />
																</cfif>
															<cfelse>
																<cfset BBCode = Get_BB_Values.Original_BB_Code />	
															</cfif>
															
															'#TRIM(BBCode)#-#TRIM(SPNum)#'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
														<CFELSEIF Count EQ "BB_Amount">
															'#EVALUATE("FORM.Amt_Child_#LoopCount#")#'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
														<CFELSEIF Count EQ "BB_Creator_ID">
															'#request.AccessStructure.User_ID#'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
														<CFELSEIF Count EQ "BB_Creator_User_Position_ID"> 														
															'#This_User_Position_ID#'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
														<CFELSEIF Count EQ "BB_Is_Child">
															'1'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
														<CFELSEIF Count EQ "BB_Parent_ID">	
															'#Parent_ID#'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>																												
														<CFELSEIF Count EQ "BB_Split_Number">
															<CFIF LoopCount GT 9>
																'#AliveChildCount#'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
															<CFELSE>
																'0#AliveChildCount#'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>															
															</CFIF>
														<CFELSEIF Count EQ "BB_Split_Reason">
															<cfqueryparam value="#EVALUATE("FORM.Split_Reason_#LoopCount#")#" cfsqltype="CF_SQL_VARCHAR">
															<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
														<CFELSEIF Count EQ "BB_Split_Date">
															getdate()<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
														<CFELSEIF Count EQ "BB_Closing_Method">	
															#EVALUATE("FORM.Closing_method_#LoopCount#")#<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>				
														
														<cfelseif COUNT EQ "BB_Title">
														<cfqueryparam value="#Get_BB_Values.BB_Title#" cfsqltype="CF_SQL_VARCHAR">		
														
														<cfelseif COUNT EQ "BB_Creator_Notes ">
															<cfqueryparam value="#Get_BB_Values.BB_Creator_Notes#" cfsqltype="CF_SQL_VARCHAR">	
																								
														<CFELSEIF Count EQ "BB_BBID_Split_Number">
															<CFIF LoopCount GT 9>
																<CFSET SPNUM = AliveChildCount>
															<CFELSE>
																<CFSET SPNUM = "0#AliveChildCount#">															
															</CFIF>
															'#TRIM(Get_BB_Values.BB_Code)#-#TRIM(SPNum)#'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
														</CFIF>
													</CFIF>																																																		
												</CFIF>
											</CFLOOP>
										)
						</CFQUERY>
						
					<!---	<cfcatch>
						 
							<Cfdump var="#cfcatch.message#" output="C:\temp\Before_splitbbCall.txt" />	
							<Cfdump var="#cfcatch.type#" output="C:\temp\Before_splitbbCall.txt" />
							<Cfdump var="#cfcatch.Detail#" output="C:\temp\Before_splitbbCall.txt" />
							<Cfdump var="#cfcatch.SQLSTATE#" output="C:\temp\Before_splitbbCall.txt" />							
							    
						</cfcatch>
</cftry>				--->		
						</CFOUTPUT>		
						<CFSET NewBBID = "">
						<CFSET NewBBID = Insert_Data.Billback_ID>	
					</CFIF>			
				<CFELSE>
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<!--- FOR EDIT --->				
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				
					<CFQUERY NAME="Update_Child" DATASOURCE="#Application.Datasource#">
						UPDATE 	Billback
						SET		BB_Amount 			= 	<cfqueryparam value="#EVALUATE("FORM.Amt_Child_#LoopCount#")#" cfsqltype="CF_SQL_FLOAT">,
								BB_Split_Reason		=	<cfqueryparam value="#EVALUATE("FORM.Split_Reason_#LoopCount#")#" cfsqltype="CF_SQL_VARCHAR">,	
								BB_Closing_Method	=	<cfqueryparam value="#EVALUATE("FORM.Closing_method_#LoopCount#")#" cfsqltype="CF_SQL_INTEGER">,
								Deleted				=	<CFIF EVALUATE("FORM.IsDeleted_#Loopcount#") EQ 1>'1'<CFELSE>'0'</CFIF>
								
						WHERE 	Billback_ID			= 	<cfqueryparam value="#EVALUATE("FORM.Child_UUID_#LoopCount#")#" cfsqltype="CF_SQL_VARCHAR">
					</CFQUERY>	
					
					<CFIF EVALUATE("FORM.IsDeleted_#Loopcount#") EQ 1>
						<CFQUERY NAME="DeleteFromApp" DATASOURCE="#Application.Datasource#">
							DELETE FROM BB_Approved WHERE Billback_ID = <cfqueryparam value="#EVALUATE("FORM.Child_UUID_#LoopCount#")#" cfsqltype="CF_SQL_VARCHAR">
						</CFQUERY>		
						<CFQUERY NAME="DeleteFromPayee" DATASOURCE="#Application.Datasource#">
							DELETE FROM Billback_Distributor WHERE Billback_ID = <cfqueryparam value="#EVALUATE("FORM.Child_UUID_#LoopCount#")#" cfsqltype="CF_SQL_VARCHAR">
						</CFQUERY>		
						<CFQUERY NAME="DeleteFromPayee" DATASOURCE="#Application.Datasource#">
							DELETE FROM Billback_Operator WHERE Billback_ID = <cfqueryparam value="#EVALUATE("FORM.Child_UUID_#LoopCount#")#" cfsqltype="CF_SQL_VARCHAR">
						</CFQUERY>		
						<CFQUERY NAME="DeleteFromPayee" DATASOURCE="#Application.Datasource#">
							DELETE FROM Billback_Broker WHERE Billback_ID = <cfqueryparam value="#EVALUATE("FORM.Child_UUID_#LoopCount#")#" cfsqltype="CF_SQL_VARCHAR">
						</CFQUERY>
						<CFQUERY NAME="DeleteFromPayee" DATASOURCE="#Application.Datasource#">
							DELETE FROM Billback_Unidentified_Payee WHERE Billback_ID = <cfqueryparam value="#EVALUATE("FORM.Child_UUID_#LoopCount#")#" cfsqltype="CF_SQL_VARCHAR">
						</CFQUERY>
						<CFQUERY NAME="DeleteFromSplitItem" DATASOURCE="#Application.Datasource#">
							DELETE FROM BB_Item_Final_Split WHERE Billback_ID = <cfqueryparam value="#EVALUATE("FORM.Child_UUID_#LoopCount#")#" cfsqltype="CF_SQL_VARCHAR">
						</CFQUERY>
						<cfset ChildUUIDToDelete = EVALUATE("FORM.Child_UUID_#LoopCount#")>
						<cfset useLakebaseForDeleteFromTaxInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_tax_info")>
						<cfif useLakebaseForDeleteFromTaxInfo>
							<cftry>
								<cfset application.oLakebase.deleteRows("bb_tax_info", { "billback_id" = "eq.#ChildUUIDToDelete#" })>
								<cfcatch type="any">
									<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
									<cfset useLakebaseForDeleteFromTaxInfo = false>
								</cfcatch>
							</cftry>
						</cfif>
						<cfif NOT useLakebaseForDeleteFromTaxInfo>
							<CFQUERY NAME="DeleteFromTaxInfo" DATASOURCE="#Application.Datasource#">
								DELETE FROM BB_Tax_Info WHERE Billback_ID = <cfqueryparam value="#ChildUUIDToDelete#" cfsqltype="CF_SQL_VARCHAR">
							</CFQUERY>
						</cfif>
					</CFIF>
				<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
				</CFIF>
			</CFIF>
			
			<CFIF ISDefined("NewBBID") AND NewBBID NEQ "">
				<CFQUERY NAME="InsertBB_Approved" DATASOURCE="#Application.Datasource#">
					INSERT INTO
					BB_Approved	(	Billback_ID,
									Paid_Amount,
									Vendor_Master_ID,
									Adjustment_Created		)
					VALUES		(	<cfqueryparam value="#NewBBID#" cfsqltype="CF_SQL_VARCHAR">,
									<cfqueryparam value="#EVALUATE("FORM.Amt_Child_#LoopCount#")#" cfsqltype="CF_SQL_FLOAT">,
									<cfqueryparam value="#strPayeeID#" cfsqltype="cf_sql_varchar" null="#strPayeeID EQ ""#">,
									0				)
				</CFQUERY>
				<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
				<!--- Payee Info insert --->
				<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
				<CFSET PayeeType = Get_BB_Values.Billback_Payee_Type_ID>
				<CFIF PayeeType EQ 1 OR PayeeType EQ 5>
					<CFQUERY NAME="Get_Payee_Columns" DATASOURCE="#Application.Datasource#">
						SELECT 		column_name 
						FROM 		information_schema.columns 
						WHERE 		table_name = 'Billback_Distributor' AND
									column_name NOT IN ('Billback_Distributor_ID','Created_Date','Deleted') 			
					</CFQUERY>	
				<CFELSEIF PayeeType EQ 2 OR PayeeType EQ 6>
					<CFQUERY NAME="Get_Payee_Columns" DATASOURCE="#Application.Datasource#">
						SELECT 		column_name 
						FROM 		information_schema.columns 
						WHERE 		table_name = 'Billback_Operator' AND
									column_name NOT IN ('Billback_Operator_ID','Created_Date','Deleted')			
					</CFQUERY>
				<CFELSEIF PayeeType EQ 3 OR PayeeType EQ 7>
					<CFQUERY NAME="Get_Payee_Columns" DATASOURCE="#Application.Datasource#">
						SELECT 		column_name 
						FROM 		information_schema.columns 
						WHERE 		table_name = 'Billback_Broker' AND
									column_name NOT IN ('Billback_Broker_ID','Created_Date','Deleted')	 			
					</CFQUERY>
				<CFELSEIF PayeeType EQ 4>
					<CFQUERY NAME="Get_Payee_Columns" DATASOURCE="#Application.Datasource#">
						SELECT 		column_name 
						FROM 		information_schema.columns 
						WHERE 		table_name = 'Billback_Unidentified_Payee' AND
									column_name NOT IN ('Billback_Unidentified_Payee_ID','Created_Date','Deleted')	 			
					</CFQUERY>
				</CFIF>
				
				<CFSET Payee_Column_List = VALUELIST(Get_Payee_Columns.column_name)>		
				<CFSET Payee_Column_List_Len = LISTLEN(Payee_Column_List,",")>
				<CFSET PayeeColLoopCount = 0>
				<CFSET PayeeValueLoopCount = 0>
				
				<CFIF PayeeType EQ 1 OR PayeeType EQ 5>
				
					<CFQUERY NAME="Parent_Payee_Data" DATASOURCE="#Application.Datasource#">
						SELECT * FROM Billback_Distributor WHERE Billback_ID = '#Parent_ID#'
					</CFQUERY>
					
					<CFQUERY NAME="InsertPayeeData" DATASOURCE="#Application.Datasource#">
						INSERT INTO 
						Billback_Distributor	(
													<CFLOOP LIST="#Payee_Column_List#" INDEX="PayeeCount">
														<CFSET PayeeColLoopCount = PayeeColLoopCount + 1>
														<CFIF PayeeCount NEQ "Billback_Distributor_ID" AND PayeeCount NEQ "Created_Date" AND PayeeCount NEQ "Deleted">
															<CFIF PayeeColLoopCount NEQ Payee_Column_List_Len>
																#PayeeCount#,
															<CFELSE>
																#PayeeCount#
															</CFIF>
														</CFIF>
													</CFLOOP>
												)
						VALUES					(
													<CFLOOP LIST="#Payee_Column_List#" INDEX="PayeeCount">
														<CFSET PayeeValueLoopCount = PayeeValueLoopCount + 1>
														<CFIF PayeeCount NEQ "Billback_Distributor_ID" AND PayeeCount NEQ "Created_Date" AND PayeeCount NEQ "Deleted">
															<CFIF PayeeCount NEQ "Billback_ID">
																<CFIF EVALUATE("Parent_Payee_Data.#PayeeCount#") EQ "">
																	NULL<CFIF PayeeValueLoopCount NEQ Payee_Column_List_Len>,</CFIF>	
																<CFELSE>
																	<cfqueryparam value="#EVALUATE("Parent_Payee_Data.#PayeeCount#")#" cfsqltype="CF_SQL_VARCHAR">
																	<CFIF PayeeValueLoopCount NEQ Payee_Column_List_Len>,</CFIF>
																</CFIF>
															<CFELSE>
																<CFIF PayeeCount EQ "Billback_ID">
																	'#NewBBID#'<CFIF PayeeValueLoopCount NEQ Payee_Column_List_Len>,</CFIF>
																</CFIF>
															</CFIF>
														</CFIF>
													</CFLOOP>
												)
					</CFQUERY>	
				<CFELSEIF PayeeType EQ 2 OR PayeeType EQ 6>
					<CFQUERY NAME="Parent_Payee_Data" DATASOURCE="#Application.Datasource#">
						SELECT * FROM Billback_Operator WHERE Billback_ID = <cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR">
					</CFQUERY>
					
					<CFQUERY NAME="InsertPayeeData" DATASOURCE="#Application.Datasource#">
						INSERT INTO 
						Billback_Operator		(
													<CFLOOP LIST="#Payee_Column_List#" INDEX="PayeeCount">
														<CFSET PayeeColLoopCount = PayeeColLoopCount + 1>
														<CFIF PayeeCount NEQ "Billback_Operator_ID" AND PayeeCount NEQ "Created_Date" AND PayeeCount NEQ "Deleted">
															<CFIF PayeeColLoopCount NEQ Payee_Column_List_Len>
																#PayeeCount#,
															<CFELSE>
																#PayeeCount#
															</CFIF>
														</CFIF>
													</CFLOOP>
												)
						VALUES					(
													<CFLOOP LIST="#Payee_Column_List#" INDEX="PayeeCount">
														<CFSET PayeeValueLoopCount = PayeeValueLoopCount + 1>
														<CFIF PayeeCount NEQ "Billback_Operator_ID" AND PayeeCount NEQ "Created_Date" AND PayeeCount NEQ "Deleted">
															<CFIF PayeeCount NEQ "Billback_ID">
																<CFIF EVALUATE("Parent_Payee_Data.#PayeeCount#") EQ "">
																	NULL<CFIF PayeeValueLoopCount NEQ Payee_Column_List_Len>,</CFIF>	
																<CFELSE>
																	<cfqueryparam value="#EVALUATE("Parent_Payee_Data.#PayeeCount#")#" cfsqltype="CF_SQL_VARCHAR">
																	<CFIF PayeeValueLoopCount NEQ Payee_Column_List_Len>,</CFIF>
																</CFIF>
															<CFELSE>
																<CFIF PayeeCount EQ "Billback_ID">
																	'#NewBBID#'<CFIF PayeeValueLoopCount NEQ Payee_Column_List_Len>,</CFIF>
																</CFIF>
															</CFIF>
														</CFIF>
													</CFLOOP>
												)
					</CFQUERY>
				<CFELSEIF PayeeType EQ 3 OR PayeeType EQ 7>
					<CFQUERY NAME="Parent_Payee_Data" DATASOURCE="#Application.Datasource#">
						SELECT * FROM Billback_Broker WHERE Billback_ID = <cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR">
					</CFQUERY>
					
					<CFQUERY NAME="InsertPayeeData" DATASOURCE="#Application.Datasource#">
						INSERT INTO 
						Billback_Broker		(
													<CFLOOP LIST="#Payee_Column_List#" INDEX="PayeeCount">
														<CFSET PayeeColLoopCount = PayeeColLoopCount + 1>
														<CFIF PayeeCount NEQ "Billback_Broker_ID" AND PayeeCount NEQ "Created_Date" AND PayeeCount NEQ "Deleted">
															<CFIF PayeeColLoopCount NEQ Payee_Column_List_Len>
																#PayeeCount#,
															<CFELSE>
																#PayeeCount#
															</CFIF>
														</CFIF>
													</CFLOOP>
												)
						VALUES					(
													<CFLOOP LIST="#Payee_Column_List#" INDEX="PayeeCount">
														<CFSET PayeeValueLoopCount = PayeeValueLoopCount + 1>
														<CFIF PayeeCount NEQ "Billback_Broker_ID" AND PayeeCount NEQ "Created_Date" AND PayeeCount NEQ "Deleted">
															<CFIF PayeeCount NEQ "Billback_ID">
																<CFIF EVALUATE("Parent_Payee_Data.#PayeeCount#") EQ "">
																	NULL<CFIF PayeeValueLoopCount NEQ Payee_Column_List_Len>,</CFIF>	
																<CFELSE>
																	<cfqueryparam value="#EVALUATE("Parent_Payee_Data.#PayeeCount#")#" cfsqltype="CF_SQL_VARCHAR">
																	<CFIF PayeeValueLoopCount NEQ Payee_Column_List_Len>,</CFIF>
																</CFIF>
															<CFELSE>
																<CFIF PayeeCount EQ "Billback_ID">
																	'#NewBBID#'<CFIF PayeeValueLoopCount NEQ Payee_Column_List_Len>,</CFIF>
																</CFIF>
															</CFIF>
														</CFIF>
													</CFLOOP>
												)
					</CFQUERY>
				<CFELSEIF PayeeType EQ 4>
					<CFQUERY NAME="Parent_Payee_Data" DATASOURCE="#Application.Datasource#">
						SELECT * FROM Billback_Unidentified_Payee WHERE Billback_ID = <cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR">
					</CFQUERY>
					
					<CFQUERY NAME="InsertPayeeData" DATASOURCE="#Application.Datasource#">
						INSERT INTO 
						Billback_Unidentified_Payee		(
													<CFLOOP LIST="#Payee_Column_List#" INDEX="PayeeCount">
														<CFSET PayeeColLoopCount = PayeeColLoopCount + 1>
														<CFIF PayeeCount NEQ "Billback_Unidentified_Payee_ID" AND PayeeCount NEQ "Created_Date" AND PayeeCount NEQ "Deleted">
															<CFIF PayeeColLoopCount NEQ Payee_Column_List_Len>
																#PayeeCount#,
															<CFELSE>
																#PayeeCount#
															</CFIF>
														</CFIF>
													</CFLOOP>
												)
						VALUES					(
													<CFLOOP LIST="#Payee_Column_List#" INDEX="PayeeCount">
														<CFSET PayeeValueLoopCount = PayeeValueLoopCount + 1>
														<CFIF PayeeCount NEQ "Billback_Unidentified_Payee_ID" AND PayeeCount NEQ "Created_Date" AND PayeeCount NEQ "Deleted">
															<CFIF PayeeCount NEQ "Billback_ID">
																<CFIF EVALUATE("Parent_Payee_Data.#PayeeCount#") EQ "">
																	NULL<CFIF PayeeValueLoopCount NEQ Payee_Column_List_Len>,</CFIF>	
																<CFELSE>	
																	<cfqueryparam value="#EVALUATE("Parent_Payee_Data.#PayeeCount#")#" cfsqltype="CF_SQL_VARCHAR">
																	<CFIF PayeeValueLoopCount NEQ Payee_Column_List_Len>,</CFIF>
																</CFIF>
															<CFELSE>
																<CFIF PayeeCount EQ "Billback_ID">
																	'#NewBBID#'<CFIF PayeeValueLoopCount NEQ Payee_Column_List_Len>,</CFIF>
																</CFIF>
															</CFIF>
														</CFIF>
													</CFLOOP>
												)
					</CFQUERY>
				</CFIF>
				<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
				
				
				<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
				<!--- Program Insertion --->
				<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		
				<CFQUERY NAME="Get_Prog_Columns" DATASOURCE="#Application.Datasource#">
					SELECT 		column_name 
					FROM 		information_schema.columns 
					WHERE 		table_name = 'Billback_Program' AND
								column_name NOT IN ('Billback_Program_ID','Created_Date','Deleted','LumpSum_Amt')
				</CFQUERY>
				
				<CFSET Prog_Column_List = VALUELIST(Get_Prog_Columns.column_name)>		
				<CFSET Prog_Column_List_Len = LISTLEN(Prog_Column_List,",")>
				<CFSET ProgColLoopCount = 0>
				<CFSET ProgValueLoopCount = 0>
			
				
				<CFQUERY NAME="Parent_Prog_Data" DATASOURCE="#Application.Datasource#">
					SELECT * FROM Billback_Program WHERE Billback_ID = '#Parent_ID#' AND Billback_Program.Deleted = 0
				</CFQUERY>
								
				<CFQUERY NAME="InsertProgData" DATASOURCE="#Application.Datasource#">
					INSERT INTO 
					Billback_Program		(
												<CFLOOP LIST="#Prog_Column_List#" INDEX="ProgCount">
													<CFSET ProgColLoopCount = ProgColLoopCount + 1>
													<CFIF ProgCount NEQ "Billback_Program_ID" AND ProgCount NEQ "Created_Date" AND ProgCount NEQ "Deleted">
														<CFIF ProgColLoopCount NEQ Prog_Column_List_Len>
															#ProgCount#,
														<CFELSE>
															#ProgCount#
														</CFIF>
													</CFIF>
												</CFLOOP>
											)
					VALUES					(
												<CFLOOP LIST="#Prog_Column_List#" INDEX="ProgCount">
													<CFSET ProgValueLoopCount = ProgValueLoopCount + 1>
													<CFIF ProgCount NEQ "Billback_Program_ID" AND ProgCount NEQ "Created_Date" AND ProgCount NEQ "Deleted">
														<CFIF ProgCount NEQ "Billback_ID">
															<CFIF EVALUATE("Parent_Prog_Data.#ProgCount#") EQ "">
																NULL<CFIF ProgValueLoopCount NEQ Prog_Column_List_Len>,</CFIF>	
															<CFELSE>	
																'#EVALUATE("Parent_Prog_Data.#ProgCount#")#'<CFIF ProgValueLoopCount NEQ Prog_Column_List_Len>,</CFIF>
															</CFIF>
														<CFELSE>
															<CFIF ProgCount EQ "Billback_ID">
																'#NewBBID#'<CFIF ProgValueLoopCount NEQ Prog_Column_List_Len>,</CFIF>
															</CFIF>
														</CFIF>
													</CFIF>
												</CFLOOP>
											)
				</CFQUERY>
				<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
				<CFSET NewBBID = "">

			<CFELSEIF IsDefined("FORM.Child_UUID_#LoopCount#")>
				<CFQUERY NAME="UpdatePaidAmt" DATASOURCE="#Application.Datasource#">
					UPDATE 	BB_Approved
					SET 	Paid_Amount = <cfqueryparam value="#EVALUATE("FORM.Amt_Child_#LoopCount#")#" cfsqltype="CF_SQL_FLOAT">
					WHERE 	Billback_ID = <cfqueryparam value="#EVALUATE("FORM.Child_UUID_#LoopCount#")#" cfsqltype="CF_SQL_VARCHAR">
				</CFQUERY>
				<CFIF application.returned_customer_setting.Show_Fund_Settings EQ 1 AND application.returned_customer_setting.Upload_GL_Code EQ 1>
					<CFQUERY NAME="Check_Paid_Allocated_Amt" DATASOURCE="#Application.Datasource#">
						SELECT 		Top 1 BB_Approved.Paid_Amount,
									GL_Code_Fixed_Fund_Allocation_Cal.Approved_Amount,
									GL_Code_Allocation.Allocation_Saved,
									GL_Code_Allocation.Payment_Requested
									
						FROM 		BB_Approved
						LEFT JOIN	GL_Code_Fixed_Fund_Allocation_Cal ON GL_Code_Fixed_Fund_Allocation_Cal.Billback_ID = BB_Approved.Billback_ID AND GL_Code_Fixed_Fund_Allocation_Cal.Deleted = 0
						LEFT JOIN 	GL_Code_Allocation ON GL_Code_Allocation.Billback_ID = BB_Approved.Billback_ID AND GL_Code_Allocation.Deleted = 0
						WHERE 		BB_Approved.Billback_ID = <cfqueryparam value="#EVALUATE("FORM.Child_UUID_#LoopCount#")#" cfsqltype="CF_SQL_VARCHAR">
					</CFQUERY>
					
					<CFIF Check_Paid_Allocated_Amt.Paid_Amount NEQ Check_Paid_Allocated_Amt.Approved_Amount AND Check_Paid_Allocated_Amt.Allocation_Saved EQ 1 AND Check_Paid_Allocated_Amt.Payment_Requested EQ 0>
						<CFQUERY NAME="UpdateTempTable" DATASOURCE="#Application.Datasource#">
							UPDATE 	GL_Code_Item_Allocation_Cal
							SET 	Deleted = 1
							WHERE 	Billback_ID = <cfqueryparam value="#EVALUATE("FORM.Child_UUID_#LoopCount#")#" cfsqltype="CF_SQL_VARCHAR"> AND
									Deleted = 0
						</CFQUERY>
						
						<CFQUERY NAME="UpdateTempTable" DATASOURCE="#Application.Datasource#">
							UPDATE 	GL_Code_Fixed_Fund_Allocation_Cal
							SET 	Deleted = 1
							WHERE 	Billback_ID = <cfqueryparam value="#EVALUATE("FORM.Child_UUID_#LoopCount#")#" cfsqltype="CF_SQL_VARCHAR"> AND
									Deleted = 0
						</CFQUERY>
						
						<CFQUERY NAME="UpdateTable" DATASOURCE="#Application.Datasource#">
							UPDATE 	Gl_Code_Allocation
							SET 	Deleted = 1
							WHERE 	Billback_ID = <cfqueryparam value="#EVALUATE("FORM.Child_UUID_#LoopCount#")#" cfsqltype="CF_SQL_VARCHAR"> AND
									Deleted = 0
						</CFQUERY>
					</CFIF>	
				</CFIF>			
			</CFIF>			
		</CFLOOP>

		<CFQUERY NAME="GetParentInfo" DATASOURCE="#Application.Datasource#">
			SELECT 		ROUND(ISNULL(LumpSum_Amt,0),0) LumpSum_Amt,
						LumpSum_Only,
						BB_Approved.Paid_Amount
			FROM 		Billback_Program 	
			INNER JOIN 	BB_Approved ON BB_Approved.Billback_ID = Billback_Program.Billback_ID		
			WHERE 		Billback_Program.Billback_ID = <cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND 		Billback_Program.Deleted = 0
		</CFQUERY>
		<CFQUERY NAME="EligibleChildren" DATASOURCE="#Application.Datasource#">
			SELECT 		Billback.Billback_ID,
						BB_Approved.Paid_Amount 
			FROM 		Billback 
			INNER JOIN 	Billback_Program ON Billback_Program.Billback_ID = Billback.Billback_ID
			INNER JOIN	Billback_Allied ON Billback_Allied.Billback_ID = Billback.Billback_ID
			INNER JOIN 	BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
			WHERE 		Billback.BB_parent_ID = <cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
						Billback.Billback_Status_ID NOT IN (4,5,7) AND
						( 	Billback_Allied.BB_Is_Locked <> 1 OR 
							(	Billback_Allied.BB_Is_Locked = 1 AND 
								BB_Locked_By_User_ID = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
							)
						) AND
						Billback.Deleted = 0
			AND 		Billback_Program.Deleted = 0
		</CFQUERY>

		<CFSET EligibleBBList = VALUELIST(EligibleChildren.Billback_ID)>	
		
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!--- Claim Adjustment for Split --->
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->		
		<CFQUERY NAME="ParentCA" DATASOURCE="#Application.Datasource#">
			SELECT 		Billback_Product.Product_ID,
						Billback_Product.Billback_Product_ID,
						Billback_Product.BB_Product_Quantity,
						Billback_Product_Detail.BB_Rate

			FROM 		Billback_Product 
			INNER JOIN 	Billback_product_Detail ON Billback_product_Detail.Billback_ID = Billback_product.Billback_ID AND
						Billback_product_Detail.Billback_product_ID = Billback_product.Billback_product_ID AND		
						BB_product_Type_ID = 10 AND Billback_product_Detail.Deleted = 0 AND 
						(BB_rate IS NOT NULL OR LEN(BB_rate) > 0)
			WHERE 		Billback_Product.Billback_ID = <cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
						Billback_Product.Deleted = 0

		</CFQUERY>
		
		<CFIF ParentCA.RecordCount GT 0>
			<CFLOOP QUERY="ParentCA">
				<CFSET PProduct_ID = Product_ID>
				<CFSET PBillback_Product_ID = Billback_Product_ID>
				<CFSET PBB_Product_Quantity = BB_Product_Quantity>

				<CFQUERY NAME="UpdatePrevious" DATASOURCE="#Application.Datasource#">
					UPDATE Billback_Split_Claim_Adjust
					SET Deleted = 1
					WHERE Billback_ID IN (#LISTQUALIFY(EligibleBBList,"'",",","All")#)
				</CFQUERY>
				
				<CFLOOP QUERY = "EligibleChildren">
					<CFSET SplitQuantity = ((Paid_Amount * PBB_Product_Quantity) / GetParentInfo.Paid_Amount)>
					<CFQUERY NAME="" DATASOURCE="#Application.Datasource#">
						INSERT INTO 
						Billback_Split_Claim_Adjust	(	Billback_ID,
														BB_Parent_ID,
														Product_ID,
														Parent_Billback_Product_ID,
														Parent_Quantity,
														Split_Quantity				)
														
						VALUES						(	<cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,
														<cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR">,
														<cfqueryparam value="#PProduct_ID#" cfsqltype="CF_SQL_VARCHAR">,
														<cfqueryparam value="#PBillback_Product_ID#" cfsqltype="CF_SQL_VARCHAR">,
														<cfqueryparam value="#PBB_Product_Quantity#" cfsqltype="CF_SQL_FLOAT">,
														ROUND('#SplitQuantity#',0)		)
					</CFQUERY>
				</CFLOOP>
								
				<CFQUERY NAME="GetCASum" DATASOURCE="#Application.Datasource#">
					SELECT 	SUM(CAST(Split_Quantity AS decimal(20,0))) TotSplitCA
					FROM 	Billback_Split_Claim_Adjust
					WHERE 	BB_Parent_ID = <cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
							Deleted = 0 AND 
							Product_ID = <cfqueryparam value="#PProduct_ID#" cfsqltype="CF_SQL_VARCHAR">
				</CFQUERY>
				<CFSET DiffCAAmt = PBB_Product_Quantity - GetCASum.TotSplitCA>
				<CFIF DiffCAAmt GT 0>										
					<CFQUERY NAME="MakeUpDiff" DATASOURCE="#Application.Datasource#">
					 	UPDATE Billback_Split_Claim_Adjust
						SET Split_Quantity = CAST(Split_Quantity AS Decimal(20,0)) + <cfqueryparam value="#DiffCAAmt#" cfsqltype="CF_SQL_FLOAT">
						WHERE Billback_Split_Claim_Adjust_ID = (	SELECT 	TOP 1 Billback_Split_Claim_Adjust_ID FROM Billback_Split_Claim_Adjust
																	WHERE 	Split_Quantity = (	SELECT MAX(CAST(Split_Quantity AS Decimal(20,0))) FROM Billback_Split_Claim_Adjust
																									WHERE Billback_ID IN (#LISTQUALIFY(EligibleBBList,"'",",","All")#) AND
																									Product_ID = <cfqueryparam value="#PProduct_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
																									Deleted = 0	
																								) AND
														
																	Billback_ID IN (#LISTQUALIFY(EligibleBBList,"'",",","All")#) AND
																	Product_ID = <cfqueryparam value="#PProduct_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
																	Deleted = 0	
																) 
					</CFQUERY>
				</CFIF>								
			</CFLOOP>
		</CFIF>
		<!--- End Claim Adjustment for Split vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!--- Calculate Claimed and Approved Volume --->
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<CFQUERY NAME="ParentClaimedVolume" DATASOURCE="#Application.Datasource#">
			SELECT 	SUM(CAST((ISNULL(Billback_Product.BB_Product_Quantity, 0)) AS decimal(20,0))) AS ParentClaimed
			FROM 	Billback_Product
			WHERE 	Billback_Product.Billback_ID = <cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
					Billback_Product. Deleted = 0
		</CFQUERY>
		
		<CFQUERY NAME="ParentApprovedVolume" DATASOURCE="#Application.Datasource#">
			SELECT 	SUM(CAST((ISNULL(BB_Item_Final.Item_Volume_Paid_CS, 0)) AS decimal(20,0))) AS ParentApproved
			FROM 	BB_Item_Final
			WHERE 	BB_Item_Final.Billback_ID = <cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
					BB_Item_Final. Deleted = 0
		</CFQUERY>
		
		<CFSET VolApproved = 0>
		<CFIF ParentApprovedVolume.ParentApproved NEQ "">
			<CFSET VolApproved = ParentApprovedVolume.ParentApproved>
		</CFIF>
		
		<CFQUERY NAME="CAQ" DATASOURCE="#Application.Datasource#">
			SELECT 		SUM(CAST((ISNULL(Billback_Product.BB_Product_Quantity,0)) AS decimal(20,0))) AS CAQuantity
						
			FROM 		Billback_Product 
			INNER JOIN 	Billback_product_Detail ON Billback_product_Detail.Billback_ID = Billback_product.Billback_ID AND
						Billback_product_Detail.Billback_product_ID = Billback_product.Billback_product_ID AND		
						BB_product_Type_ID = 10 AND Billback_product_Detail.Deleted = 0 AND 
						(BB_rate IS NOT NULL OR LEN(BB_rate) > 0)
			LEFT JOIN 	BB_Item_FInal ON BB_Item_FInal.Billback_ID = Billback_Product.Billback_ID AND
						BB_Item_FInal.Billback_Product_ID = Billback_Product.Billback_Product_ID AND
				 		BB_Item_FInal.Deleted = 0
			WHERE 		Billback_Product.Billback_ID = <cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
						Billback_Product.Deleted = 0 AND BB_Item_FInal.BB_Item_FInal_ID IS NULL
		</CFQUERY>
		
		<CFIF CAQ.CAQuantity NEQ "">
			<CFSET VolApproved = VolApproved + CAQ.CAQuantity>
		</CFIF>
		
		<CFLOOP QUERY="EligibleChildren">
			<CFIF ParentClaimedVolume.ParentClaimed NEQ "" and IsDefined("GetParentInfo.Paid_Amount") AND GetParentInfo.Paid_Amount NEQ "">
				<CFQUERY NAME="UpdateClaimed" DATASOURCE="#Application.Datasource#">
					UPDATE Billback
					SET BB_Split_Claimed_Volume = ROUND(((#Paid_Amount# * #ParentClaimedVolume.ParentClaimed#) / #GetParentInfo.Paid_Amount#),0)  
					WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
				</CFQUERY>	
				
				<CFQUERY NAME="UpdateApproved" DATASOURCE="#Application.Datasource#">
					UPDATE BB_Approved
					SET BB_Split_Approved_Volume = ROUND(((#Paid_Amount# * #VolApproved#) / #GetParentInfo.Paid_Amount#),0)  
					WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
				</CFQUERY>	
			 </CFIF>
		</CFLOOP>

		<CFIF ParentClaimedVolume.ParentClaimed NEQ "">
			<CFQUERY NAME="SplitTotClaimed" DATASOURCE="#Application.Datasource#">
				SELECT 	SUM(CAST((ISNULL(BB_Split_Claimed_Volume, 0)) AS decimal(20,0))) Tot_Split_Claimed 
				FROM 	Billback 
				WHERE 	Billback_ID IN ( SELECT Billback_ID FROM Billback WHERE BB_Parent_ID = <cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0) AND
						Deleted = 0
			</CFQUERY>
			
			<CFIF SplitTotClaimed.Tot_Split_Claimed NEQ ParentClaimedVolume.ParentClaimed>
				<CFSET ClaimedDiffMakeUp = ParentClaimedVolume.ParentClaimed - SplitTotClaimed.Tot_Split_Claimed>
				
				<CFQUERY NAME="MakeUpDiff" DATASOURCE="#Application.Datasource#">
				 	UPDATE Billback
					SET BB_Split_Claimed_Volume = CAST(BB_Split_Claimed_Volume AS Decimal(20,0)) + #ClaimedDiffMakeUp#
					WHERE Billback_ID = (	SELECT 	TOP 1 Billback_ID FROM Billback
											WHERE 	BB_Split_Claimed_Volume = (	SELECT MAX(BB_Split_Claimed_Volume) FROM Billback
																			WHERE Billback_ID IN (#LISTQUALIFY(EligibleBBList,"'",",","All")#) AND
																			Deleted = 0	
																		) AND
													
													Billback_ID IN (#LISTQUALIFY(EligibleBBList,"'",",","All")#) AND
													Deleted = 0	
												) 
				</CFQUERY>
			</CFIF>

			<CFQUERY NAME="SplitTotApproved" DATASOURCE="#Application.Datasource#">
				SELECT 	SUM(CAST((ISNULL(BB_Split_Approved_Volume, 0)) AS decimal(20,0))) Tot_Split_Approved 
				FROM 	BB_Approved 
				WHERE 	Billback_ID IN ( SELECT Billback_ID FROM Billback WHERE BB_Parent_ID = <cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0) 
			</CFQUERY>
			
			<CFIF SplitTotApproved.Tot_Split_Approved NEQ VolApproved>
				<CFSET ApprovedDiffMakeUp = VolApproved - SplitTotApproved.Tot_Split_Approved>
				
				<CFQUERY NAME="MakeUpDiff" DATASOURCE="#Application.Datasource#">
				 	UPDATE BB_Approved
					SET BB_Split_Approved_Volume = CAST(BB_Split_Approved_Volume AS Decimal(20,0)) + #ApprovedDiffMakeUp#
					WHERE Billback_ID = (	SELECT 	TOP 1 Billback_ID FROM BB_Approved
											WHERE 	BB_Split_Approved_Volume = (	SELECT MAX(BB_Split_Approved_Volume) FROM BB_Approved
																			WHERE Billback_ID IN (#LISTQUALIFY(EligibleBBList,"'",",","All")#)
																		) AND												
													Billback_ID IN (#LISTQUALIFY(EligibleBBList,"'",",","All")#)
												) 
				</CFQUERY>
			</CFIF>
		</CFIF>
		<!--- vvvvvvvvvvvvvvvvvv End Calculate Claimed and Approved Volume vvvvvvvvvvvvvvvvvvvvvv --->
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!--- LumpSum Amt update for split --->
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		
		<CFIF isDefined("GetParentInfo.LumpSum_Amt") AND GetParentInfo.LumpSum_Amt NEQ "" AND GetParentInfo.LumpSum_Amt GT 0>
						
			<CFIF GetParentInfo.LumpSum_Only NEQ 1>				
				<CFLOOP QUERY="EligibleChildren">
					<CFQUERY NAME="UpdateLumpAmt" DATASOURCE="#Application.Datasource#">
						UPDATE Billback_Program
						SET LumpSum_Amt = ROUND(((#Paid_Amount# * #GetParentInfo.LumpSum_Amt#) / #GetParentInfo.Paid_Amount#),0)  
						WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
					</CFQUERY>	
				</CFLOOP>
				
				<CFQUERY NAME="SplitTotLump" DATASOURCE="#Application.Datasource#">
					SELECT 	SUM(ISNULL(LumpSum_Amt,0)) Allocated_Lumpsum
					FROM 	Billback_Program 
					WHERE 	Billback_ID IN ( SELECT Billback_ID FROM Billback WHERE BB_Parent_ID = <cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0) AND
							Deleted = 0
				</CFQUERY>
				
				<CFIF SplitTotLump.Allocated_Lumpsum NEQ GetParentInfo.LumpSum_Amt>
					<CFSET DiffMakeUp = GetParentInfo.LumpSum_Amt - SplitTotLump.Allocated_Lumpsum>
						
					<CFQUERY NAME="MakeUpDiff" DATASOURCE="#Application.Datasource#">
					 	UPDATE Billback_Program
						SET LumpSum_Amt = LumpSum_Amt + #DiffMakeUp#
						WHERE Billback_Program_ID = (	SELECT TOP 1 Billback_Program_ID FROM Billback_Program
														WHERE 	LumpSum_Amt = (	SELECT MAX(LumpSum_Amt) FROM Billback_Program 
																				WHERE Billback_ID IN (#LISTQUALIFY(EligibleBBList,"'",",","All")#) AND
																				Deleted = 0	
																				) AND
																Billback_ID IN (#LISTQUALIFY(EligibleBBList,"'",",","All")#) AND
																Deleted = 0
													) 
					</CFQUERY>
				</CFIF>
			<CFELSE>
				<CFLOOP QUERY="EligibleChildren">
					<CFQUERY NAME="UpdateLumpAmt" DATASOURCE="#Application.Datasource#">
						UPDATE 	Billback_Program 
						SET 	Lumpsum_Amt = <cfqueryparam value="#Paid_Amount#" cfsqltype="CF_SQL_FLOAT">
						WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
								Deleted = 0						
					</CFQUERY>
				</CFLOOP>				
			</CFIF>
		</CFIF>
		<!--- vvvvvvvvvvvvvvvvv End Lump Amt update for splitvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!--- vvvvvvvvv Common item level amount calculation vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<CFIF application.returned_customer_setting.Show_Fund_Settings EQ 0 OR application.returned_customer_setting.Upload_GL_Code EQ 0>		
			<CFSET Billback_ID = Parent_ID>
			<CFSET FromCommomSplitInsert = 1>
			<CFQUERY NAME="CheckIsChild" DATASOURCE="#Application.Datasource#">
				SELECT 		* 
				FROM 		Billback 
				INNER JOIN 	BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
				WHERE 		Billback.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			</CFQUERY>				
			<CFQUERY NAME="GetProgramList" DATASOURCE="#Application.Datasource#">
				SELECT 		Billback_Program.Program_ID
				FROM 		Billback_Program 
				
				WHERE 		Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
							Billback_Program.Deleted = 0
			</CFQUERY>
			<CFSET Program_List = VALUELIST(GetProgramList.Program_ID)>
			<CFSET CheckIsChild.BB_Is_Child = 0>
			<CFQUERY NAME="DeletePreviousEntry" DATASOURCE="#Application.Datasource#">
				DELETE FROM GL_Code_Item_Allocation_Cal WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
			</CFQUERY>
			<CFINCLUDE TEMPLATE="/GL_Code/GL_Code_IN_Billback/Item_Allocation_Cal.cfm">
			<CFQUERY NAME="GetAllocatedAmt" DATASOURCE="#Application.Datasource#">
				SELECT * FROM GL_Code_Item_Allocation_Cal WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
			</CFQUERY>
			<CFQUERY NAME="InsertSplitAllocationData" DATASOURCE="#Application.Datasource#">
				INSERT INTO 
				BB_Item_Final_Split (	Billback_ID,
										Product_ID,
										Program_ID,
										Approved_Amount	)
				
				SELECT 					Billback_ID,
										Product_ID,
										Program_ID,
										SUM(Approved_Amount) 
				FROM 					GL_Code_Item_Allocation_Cal 
				WHERE 					Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
				GROUP BY 				Billback_ID,Product_ID,Program_ID
			</CFQUERY>
			
		</CFIF>
		<!--- vvvvvvvvvvvvvvv End Common item level amount calculation vvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<cfreturn Parent_ID />
		
	</cffunction>
		
</cfcomponent>