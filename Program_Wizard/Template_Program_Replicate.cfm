<!--- initialize product id mapping array --->
		<!---Get Program Span--->
	<cfquery name="getTemplateSettings" datasource="#application.datasource#">
	SELECT *
	FROM Program_Control_Panel_Options
	WHERE ProgramControl_Panel_Options_ID = '#NewID#'
	</cfquery>
		<CFSET Contract_Products_ID_Mapping = ArrayNew(2)>
		<CFSET Contract_Products_ID_TO_Lump_Sum_Component_ID_Mapping = ArrayNew(2)>
		<!--- END initialize product id mapping array --->

		<!--- Save products --->
		<CFSET ListOfColumsToIgnore="CONTRACT_MAIN_ID,CONTRACT_PRODUCTS_ID,DELETED,CREATOR_ID,DATE_CREATED,DISCOUNT_VALUE,EDITOR_ID,PRICING_RULE,PRODUCT_UPC">
		<CFSET ThisStructureLevel = Program.Products>
		<CFIF ThisStructureLevel.recordcount GT 0>
			<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
				<CFSET FieldList = "">
				<CFSET DataValueList = "">
				
				<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
					<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
						<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
						<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
						<CFSET stringToEscape = DataItemForTheList>
						<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(34),"&##34","ALL")> <!--- Double Quotes --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
						<CFSET DataItemForTheList = stringToEscape>
						<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
					</CFIF>
				</CFLOOP>
				
				<!--- save data query --->
				<CFQUERY NAME="saveProduct" datasource="#application.datasource#">
					INSERT INTO #ThisStructureLevel.Master_Table#
					(#FieldList#,Contract_Main_ID)
					VALUES
					(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#getTemplateSettings.EZ_Contract_Id#)
				</CFQUERY>
				
				<!--- map old contract product_id to new one --->
				<CFSET Contract_Products_ID_Mapping[ArrayLen(Contract_Products_ID_Mapping)+1][1] = evaluate("ThisStructureLevel.Contract_Products_ID_#LoopCount#")>
				<CFSET Contract_Products_ID_Mapping[ArrayLen(Contract_Products_ID_Mapping)][2] = saveProduct.Contract_Products_ID>
				<!--- end map old contract product_id to new one --->
			</CFLOOP>	
		</CFIF>
		<!--- END save --->
	
	<cfif getTemplateSettings.Discount_Fixed_Prices EQ 1>
		<CFIF appSettings.getfixedcomponents_on()>
		
			<!--- intialize component mapping array --->
			<CFSET Program_Fixed_Component_ID_Mapping = ArrayNew(2)>
			<!--- end intialize component mapping array --->			

			<!--- save fixed components --->
			<CFSET ListOfColumsToIgnore="PROGRAM_ID,DELETED,PROGRAM_FIXED_COMPONENT_ID,CREATED_DATE">
			<CFSET ThisStructureLevel = Program.Fixed_Price_Components>
			<CFIF ThisStructureLevel.recordcount GT 0>
				<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
					<CFSET FieldList = "">
					<CFSET DataValueList = "">
					
					<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
						<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
							<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
							<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
							<CFSET stringToEscape = DataItemForTheList>
							<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
							<CFSET stringToEscape = Replace(stringToEscape,chr(34),"&##34","ALL")> <!--- Double Quotes --->
							<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
							<CFSET DataItemForTheList = stringToEscape>
							<cfif NOT Len(Trim(DataItemForTheList))>
								<cfset DataItemForTheList = "NULL" />
							</cfif>
							<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
						</CFIF>
					</CFLOOP>
					
					<!--- save data query --->
					<CFQUERY NAME="saveFixedComponents" datasource="#application.datasource#">
						INSERT INTO #ThisStructureLevel.Master_Table#
						(#FieldList#,Program_ID)
						VALUES
						<!----(#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,#Renewed_Program_ID#)---->
						(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#getTemplateSettings.EZ_Contract_Id#)
						SELECT Program_Fixed_Component_ID = @@IDENTITY
					</CFQUERY>

					<!--- map old lump sum component id to new one --->
					<CFSET Program_Fixed_Component_ID_Mapping[ArrayLen(Program_Fixed_Component_ID_Mapping)+1][1] = evaluate("ThisStructureLevel.PROGRAM_FIXED_COMPONENT_ID_#LoopCount#")>
					<CFSET Program_Fixed_Component_ID_Mapping[ArrayLen(Program_Fixed_Component_ID_Mapping)][2] = saveFixedComponents.Program_Fixed_Component_ID>
					<!--- end map old lump sum component id to new one --->
				</CFLOOP>
			
			</CFIF>
			<!--- END save --->
		
			<!--- save fixed component Products --->
	
			<CFSET ListOfColumsToIgnore="PROGRAM_ID,CONTRACT_PRODUCTS_ID,DELETED,PROGRAM_FIXED_PRICE_PRODUCT_DATA_ID,PROGRAM_FIXED_COMPONENT_ID">
			<CFSET ThisStructureLevel = Program.Products.FIXED_PRICE_PRODUCTS>
			<CFIF ThisStructureLevel.recordcount GT 0>
				<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
					<CFSET FieldList = "">
					<CFSET DataValueList = "">
					
					<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
						<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
							<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
							<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
							<CFSET stringToEscape = DataItemForTheList>
							<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
							<CFSET stringToEscape = Replace(stringToEscape,chr(34),"&##34","ALL")> <!--- Double Quotes --->
							<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
							<CFSET DataItemForTheList = stringToEscape>
							<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
						</CFIF>
					</CFLOOP>
					
					<!--- Find Mapped Contract_Product_ID --->
					<!--- Find Mapped Contract_Product_ID --->
					<CFSET Old_Contract_Product_ID = evaluate("ThisStructureLevel.Contract_Products_ID_#LoopCount#")>
					<CFSET Mapped_product_ID = "">
					<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Contract_Products_ID_Mapping)#" STEP="1">
						<CFIF Old_Contract_Product_ID EQ Contract_Products_ID_Mapping[ArrayPositionCount][1]>
							<CFSET Mapped_product_ID = Contract_Products_ID_Mapping[ArrayPositionCount][2]>
						</CFIF>
					</CFLOOP>
					<!--- END Mapped Contract_Product_ID --->

					<!--- Find Mapped Component --->
					<CFSET Old_Program_Fixed_Component_ID = evaluate("ThisStructureLevel.PROGRAM_FIXED_COMPONENT_ID_#LoopCount#")>
					<CFSET Mapped_Program_Fixed_Component_ID = "">
					<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Program_Fixed_Component_ID_Mapping)#" STEP="1">
						<CFIF Old_Program_Fixed_Component_ID EQ Program_Fixed_Component_ID_Mapping[ArrayPositionCount][1]>
							<CFSET Mapped_Program_Fixed_Component_ID = Program_Fixed_Component_ID_Mapping[ArrayPositionCount][2]>
							<CFBREAK>
						</CFIF>
					</CFLOOP>
					<!--- END Mapped Contract_Product_ID --->

					<!--- save data query --->
					<CFQUERY NAME="saveFixedProducts" datasource="#application.datasource#">
						INSERT INTO #ThisStructureLevel.Master_Table#
						<!---(Contract_Products_ID,PROGRAM_LUMP_SUM_ID)--->
						(#FieldList#,Program_id, Contract_Products_ID,PROGRAM_FIXED_COMPONENT_ID)
						VALUES
						(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#getTemplateSettings.EZ_Contract_Id#, #Mapped_product_ID#,'#Mapped_Program_Fixed_Component_ID#')
						<!---(#Mapped_product_ID#,'#Mapped_Lump_Sum_ID#')--->
					</CFQUERY>
				</CFLOOP>	
			</CFIF>
			<!--- END save --->
								
		<CFELSE>

			<!--- save Fixed Price Products --->
			<CFSET ListOfColumsToIgnore="CONTRACT_MAIN_ID,DELETED,CONTRACT_PRODUCTS_ID,PROGRAM_FIXED_PRICE_PRODUCT_DATA_ID,PROGRAM_ID">
			<CFSET ThisStructureLevel = Program.Products.FIXED_PRICE_PRODUCTS>
			<CFIF ThisStructureLevel.recordcount GT 0>
				<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
					<CFSET FieldList = "">
					<CFSET DataValueList = "">
					
					<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
						<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
							<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
							<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
							<CFSET stringToEscape = DataItemForTheList>
							<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
							<CFSET stringToEscape = Replace(stringToEscape,chr(34),"&##34","ALL")> <!--- Double Quotes --->
							<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
							<CFSET DataItemForTheList = stringToEscape>
							<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
						</CFIF>
					</CFLOOP>
					
					<!--- Find Mapped Contract_Product_ID --->
					<CFSET Old_Contract_Product_ID = evaluate("ThisStructureLevel.Contract_Products_ID_#LoopCount#")>
					<CFSET Mapped_product_ID = "">
					<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Contract_Products_ID_Mapping)#" STEP="1">
						<CFIF Old_Contract_Product_ID EQ Contract_Products_ID_Mapping[ArrayPositionCount][1]>
							<CFSET Mapped_product_ID = Contract_Products_ID_Mapping[ArrayPositionCount][2]>
						</CFIF>
					</CFLOOP>
					<!--- END Mapped Contract_Product_ID --->

					<!--- save data query --->
					<CFQUERY NAME="saveFixedPriceProducts" datasource="#application.datasource#">
						INSERT INTO #ThisStructureLevel.Master_Table#
						(#FieldList#,Program_ID,Contract_Products_ID)
						VALUES
						(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#getTemplateSettings.EZ_Contract_Id#, #Mapped_product_ID#)
					</CFQUERY>
				</CFLOOP>	
			</CFIF>
			<!--- END save ---> 
		
		</CFIF>
</cfif>

<!--- Bid Request --->

<cfif getTemplateSettings.Discount_BidRequest EQ 1>
		<CFIF appSettings.getBidRequestComponentsOn()>
		
			<!--- intialize component mapping array --->
			<CFSET Program_BidRequest_Component_ID_Mapping = ArrayNew(2)>
			<!--- end intialize component mapping array --->			

			<!--- save fixed components --->
			<CFSET ListOfColumsToIgnore="PROGRAM_ID,DELETED,PROGRAM_BIDREQUEST_COMPONENT_ID,CREATED_DATE">
			<CFSET ThisStructureLevel = Program.BidRequest_Components>
			<CFIF ThisStructureLevel.recordcount GT 0>
				<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
					<CFSET FieldList = "">
					<CFSET DataValueList = "">
					
					<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
						<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
							<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
							<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
							<CFSET stringToEscape = DataItemForTheList>
							<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
							<CFSET stringToEscape = Replace(stringToEscape,chr(34),"&##34","ALL")> <!--- Double Quotes --->
							<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
							<CFSET DataItemForTheList = stringToEscape>
							<cfif NOT Len(Trim(DataItemForTheList))>
								<cfset DataItemForTheList = "NULL" />
							</cfif>
							<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
						</CFIF>
					</CFLOOP>
					
					<!--- save data query --->
					<CFQUERY NAME="saveBidRequestComponents" datasource="#application.datasource#">
						INSERT INTO #ThisStructureLevel.Master_Table#
						(#FieldList#,Program_ID)
						VALUES
						(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#getTemplateSettings.EZ_Contract_Id#)
						SELECT Program_BidRequest_Component_ID = @@IDENTITY
					</CFQUERY>

					<!--- map old BidRequestcomponent id to new one --->
					<CFSET Program_BidRequest_Component_ID_Mapping[ArrayLen(Program_BidRequest_Component_ID_Mapping)+1][1] = evaluate("ThisStructureLevel.PROGRAM_BidRequest_COMPONENT_ID_#LoopCount#")>
					<CFSET Program_BidRequest_Component_ID_Mapping[ArrayLen(Program_BidRequest_Component_ID_Mapping)][2] = saveBidRequestComponents.Program_BidRequest_Component_ID>
					<!--- end map old lump sum component id to new one --->
				</CFLOOP>
			
			</CFIF>
			<!--- END save --->
		
			<!--- save BidRequest component Products --->
	
			<CFSET ListOfColumsToIgnore="PROGRAM_ID,CONTRACT_PRODUCTS_ID,DELETED,PROGRAM_BID_REQUEST_PRODUCT_ID,PROGRAM_BIDREQUEST_COMPONENT_ID,CREATED_DATE">
			<CFSET ThisStructureLevel = Program.Products.BidRequest_PRODUCTS>
			<CFIF ThisStructureLevel.recordcount GT 0>

				<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
					<CFSET FieldList = "">
					<CFSET DataValueList = "">
					
					<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
						<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
							<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
							<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
							<CFSET stringToEscape = DataItemForTheList>
							<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
							<CFSET stringToEscape = Replace(stringToEscape,chr(34),"&##34","ALL")> <!--- Double Quotes --->
							<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
							<CFSET DataItemForTheList = stringToEscape>
							<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
						</CFIF>
					</CFLOOP>
					
					<!--- Find Mapped Contract_Product_ID --->
					<!--- Find Mapped Contract_Product_ID --->
					<CFSET Old_Contract_Product_ID = evaluate("ThisStructureLevel.Contract_Products_ID_#LoopCount#")>
					<CFSET Mapped_product_ID = "">
					<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Contract_Products_ID_Mapping)#" STEP="1">
						<CFIF Old_Contract_Product_ID EQ Contract_Products_ID_Mapping[ArrayPositionCount][1]>
							<CFSET Mapped_product_ID = Contract_Products_ID_Mapping[ArrayPositionCount][2]>
						</CFIF>
					</CFLOOP>
					<!--- END Mapped Contract_Product_ID --->

					<!--- Find Mapped Component --->
					<CFSET Old_Program_BidRequest_Component_ID = evaluate("ThisStructureLevel.PROGRAM_BidRequest_COMPONENT_ID_#LoopCount#")>
					<CFSET Mapped_Program_BidRequest_Component_ID = "">
					<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Program_BidRequest_Component_ID_Mapping)#" STEP="1">
						<CFIF Old_Program_BidRequest_Component_ID EQ Program_BidRequest_Component_ID_Mapping[ArrayPositionCount][1]>
							<CFSET Mapped_Program_BidRequest_Component_ID = Program_BidRequest_Component_ID_Mapping[ArrayPositionCount][2]>
							<CFBREAK>
						</CFIF>
					</CFLOOP>
					<!--- END Mapped Contract_Product_ID --->

					<!--- save data query --->
					<CFQUERY NAME="saveBidRequestProducts" datasource="#application.datasource#">
						INSERT INTO #ThisStructureLevel.Master_Table#
						<!---(Contract_Products_ID,PROGRAM_LUMP_SUM_ID)--->
						(#FieldList#,Program_id, Contract_Products_ID,PROGRAM_BidRequest_COMPONENT_ID)
						VALUES
						(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#getTemplateSettings.EZ_Contract_Id#, #Mapped_product_ID#,'#Mapped_Program_BidRequest_Component_ID#')
						<!---(#Mapped_product_ID#,'#Mapped_Lump_Sum_ID#')--->
					</CFQUERY>
				</CFLOOP>	
			</CFIF>
			<!--- END save --->
								
		<CFELSE>
			<!--- save BidRequest Products --->
			<CFSET ListOfColumsToIgnore="CONTRACT_MAIN_ID,DELETED,CONTRACT_PRODUCTS_ID,PROGRAM_BID_REQUEST_PRODUCT_ID,PROGRAM_ID,CREATED_DATE">
			<CFSET ThisStructureLevel = Program.Products.BidRequest_PRODUCTS>
			<CFIF ThisStructureLevel.recordcount GT 0>
				<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
					<CFSET FieldList = "">
					<CFSET DataValueList = "">
					
					<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
						<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
							<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
							<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
							<CFSET stringToEscape = DataItemForTheList>
							<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
							<CFSET stringToEscape = Replace(stringToEscape,chr(34),"&##34","ALL")> <!--- Double Quotes --->
							<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
							<CFSET DataItemForTheList = stringToEscape>
							<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
						</CFIF>
					</CFLOOP>
					
					<!--- Find Mapped Contract_Product_ID --->
					<CFSET Old_Contract_Product_ID = evaluate("ThisStructureLevel.Contract_Products_ID_#LoopCount#")>
					<CFSET Mapped_product_ID = "">
					<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Contract_Products_ID_Mapping)#" STEP="1">
						<CFIF Old_Contract_Product_ID EQ Contract_Products_ID_Mapping[ArrayPositionCount][1]>
							<CFSET Mapped_product_ID = Contract_Products_ID_Mapping[ArrayPositionCount][2]>
						</CFIF>
					</CFLOOP>
					<!--- END Mapped Contract_Product_ID --->

					<!--- save data query --->
					<CFQUERY NAME="saveBidRequestProducts" datasource="#application.datasource#">
						INSERT INTO #ThisStructureLevel.Master_Table#
						(#FieldList#,Program_ID,Contract_Products_ID)
						VALUES
						(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#getTemplateSettings.EZ_Contract_Id#, #Mapped_product_ID#)
					</CFQUERY>
				</CFLOOP>	
			</CFIF>
			<!--- END save ---> 
		
		</CFIF>
</cfif>

			<!--- save Off Invoice Products --->
<cfif getTemplateSettings.Generic_Type IS "Distributor Off-Invoice">

			<!--- intialize component mapping array --->
			<CFSET Program_OffInvoice_Component_ID_Mapping = ArrayNew(2)>
			<!--- end intialize component mapping array --->			

			<!--- save off-invoice components --->
			<CFSET ListOfColumsToIgnore="PROGRAM_ID,DELETED,PROGRAM_OFFINVOICE_COMPONENT_ID,CREATED_DATE">
			<CFSET ThisStructureLevel = Program.Program_OffInvoice_Component>
			<CFIF ThisStructureLevel.recordcount GT 0>
				<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
					<CFSET FieldList = "">
					<CFSET DataValueList = "">
					
					<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
						<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
							<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
							<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
							<CFSET stringToEscape = DataItemForTheList>
							<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
							<CFSET stringToEscape = Replace(stringToEscape,chr(34),"&##34","ALL")> <!--- Double Quotes --->
							<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
							<CFSET DataItemForTheList = stringToEscape>
							<cfif NOT Len(Trim(DataItemForTheList))>
								<cfset DataItemForTheList = "NULL" />
							</cfif>
							<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
						</CFIF>
					</CFLOOP>
					
					<!--- save data query --->
					<CFQUERY NAME="saveOffInvoiceComponents" datasource="#application.datasource#">
						INSERT INTO #ThisStructureLevel.Master_Table#
						(#FieldList#,Program_ID)
						VALUES
						<!----(#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,#Renewed_Program_ID#)---->
						(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#getTemplateSettings.EZ_Contract_Id#)
						SELECT Program_OffInvoice_Component_ID = @@IDENTITY
					</CFQUERY>

					<!--- map old lump sum component id to new one --->
					<CFSET Program_OffInvoice_Component_ID_Mapping[ArrayLen(Program_OffInvoice_Component_ID_Mapping)+1][1] = evaluate("ThisStructureLevel.PROGRAM_OFFINVOICE_COMPONENT_ID_#LoopCount#")>
					<CFSET Program_OffInvoice_Component_ID_Mapping[ArrayLen(Program_OffInvoice_Component_ID_Mapping)][2] = saveOffInvoiceComponents.Program_OffInvoice_Component_ID>
					<!--- end map old lump sum component id to new one --->
				</CFLOOP>
			
			</CFIF>
			<!--- END save --->

		<CFSET ListOfColumsToIgnore="PROGRAM_ID,CREATED_DATE,DELETED_BY,CONTRACT_PRODUCTS_ID,DELETED,PROGRAM_OFFINVOICE_PRODUCT_DATA_ID,PROGRAM_OFFINVOICE_COMPONENT_ID">
		<CFSET ThisStructureLevel = Program.Products.OffInvoice_Products>
		<CFIF ThisStructureLevel.recordcount GT 0>
			<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
				<CFSET FieldList = "">
				<CFSET DataValueList = "">
				
				<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
					<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
						<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
						<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
						<CFSET stringToEscape = DataItemForTheList>
						<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(34),"&##34","ALL")> <!--- Double Quotes --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
						<CFSET DataItemForTheList = stringToEscape>
						<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
					</CFIF>
				</CFLOOP>
				
				<!--- Find Mapped Contract_Product_ID --->
				<CFSET Old_Contract_Product_ID = evaluate("ThisStructureLevel.Contract_Products_ID_#LoopCount#")>
				<CFSET Mapped_product_ID = "">
				<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Contract_Products_ID_Mapping)#" STEP="1">
					<CFIF Old_Contract_Product_ID EQ Contract_Products_ID_Mapping[ArrayPositionCount][1]>
						<CFSET Mapped_product_ID = Contract_Products_ID_Mapping[ArrayPositionCount][2]>
					</CFIF>
				</CFLOOP>
				<!--- END Mapped Contract_Product_ID --->
				
				<!--- Find Mapped Component --->
				<CFSET Old_Program_OffInvoice_Component_ID = evaluate("ThisStructureLevel.PROGRAM_OFFINVOICE_COMPONENT_ID_#LoopCount#")>
				<CFSET Mapped_Program_OffInvoice_Component_ID = "">
				<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Program_OffInvoice_Component_ID_Mapping)#" STEP="1">
					<CFIF Old_Program_OffInvoice_Component_ID EQ Program_OffInvoice_Component_ID_Mapping[ArrayPositionCount][1]>
						<CFSET Mapped_Program_OffInvoice_Component_ID = Program_OffInvoice_Component_ID_Mapping[ArrayPositionCount][2]>
						<CFBREAK>
					</CFIF>
				</CFLOOP>
				<!--- End Find Mapped Component --->		
			
				<!--- save data query --->
				<CFQUERY NAME="saveOffInvoiceProducts" datasource="#application.datasource#">
					INSERT INTO #ThisStructureLevel.Master_Table#
					(#FieldList#,Program_ID,Contract_Products_ID, Program_OffInvoice_Component_ID)
					VALUES
					(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#getTemplateSettings.EZ_Contract_Id#, #Mapped_product_ID#, #Mapped_Program_OffInvoice_Component_ID#)
				</CFQUERY>
			</CFLOOP>
		</CFIF>
		<!--- END save --->	
</cfif>

<CFIF getTemplateSettings.Discount_Lump_Sums EQ 1>
		<!--- intialize component mapping array --->
		<CFSET Lump_Sum_Component_ID_Mapping = ArrayNew(2)>
		<!--- end intialize component mapping array --->			

		<!--- save lump sums --->
		<CFSET ListOfColumsToIgnore="PROGRAM_ID,DELETED,PROGRAM_LUMP_SUM_ID,PROGRAM_LUMPS_SUM_EXT_ID">
		<CFSET ThisStructureLevel = Program.LUMP_SUM_COMPONENTS>
		<CFIF ThisStructureLevel.recordcount GT 0>
			<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
				<CFSET FieldList = "">
				<CFSET DataValueList = "">
				
				<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
					<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
						<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
						<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
						<CFSET stringToEscape = DataItemForTheList>
						<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(34),"&##34","ALL")> <!--- Double Quotes --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
						<CFSET DataItemForTheList = stringToEscape>
						<cfif NOT Len(Trim(DataItemForTheList))>
							<cfset DataItemForTheList = "NULL" />
						</cfif>
						<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
					</CFIF>
				</CFLOOP>
				
				<!--- save data query --->
				<CFQUERY NAME="saveLumpSumComponents" datasource="#application.datasource#">
					INSERT INTO #ThisStructureLevel.Master_Table#
					(#FieldList#,Program_ID)
					VALUES
					<!----(#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,#Renewed_Program_ID#)---->
					(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#getTemplateSettings.EZ_Contract_Id#)
				</CFQUERY>

				<!--- map old lump sum component id to new one --->
				<CFSET Lump_Sum_Component_ID_Mapping[ArrayLen(Lump_Sum_Component_ID_Mapping)+1][1] = evaluate("ThisStructureLevel.PROGRAM_LUMP_SUM_ID_#LoopCount#")>
				<CFSET Lump_Sum_Component_ID_Mapping[ArrayLen(Lump_Sum_Component_ID_Mapping)][2] = saveLumpSumComponents.Program_Lump_Sum_ID>
				<!--- end map old lump sum component id to new one --->
			</CFLOOP>
			
		</CFIF>
		<!--- END save --->

		<!--- save lump products Products --->
		<CFSET ListOfColumsToIgnore="CONTRACT_PRODUCTS_ID,DELETED,PROGRAM_LUMP_SUM_PRODUCT_DATA_ID,PROGRAM_LUMP_SUM_ID,CREATED_DATE">
		<CFSET ThisStructureLevel = Program.LUMP_SUM_COMPONENTS.PRODUCTS>
		<CFIF ThisStructureLevel.recordcount GT 0>
			<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
				<CFSET FieldList = "">
				<CFSET DataValueList = "">
				
				<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
					<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
						<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
						<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
						<CFSET stringToEscape = DataItemForTheList>
						<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(34),"&##34","ALL")> <!--- Double Quotes --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
						<CFSET DataItemForTheList = stringToEscape>
						<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
					</CFIF>
				</CFLOOP>
				
				<!--- Find Mapped Contract_Product_ID --->
				<CFSET Old_Contract_Product_ID = evaluate("ThisStructureLevel.Contract_Products_ID_#LoopCount#")>
				<CFSET Mapped_product_ID = "">
				<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Contract_Products_ID_Mapping)#" STEP="1">
					<CFIF Old_Contract_Product_ID EQ Contract_Products_ID_Mapping[ArrayPositionCount][1]>
						<CFSET Mapped_product_ID = Contract_Products_ID_Mapping[ArrayPositionCount][2]>
						<CFBREAK>
					</CFIF>
				</CFLOOP>
				<!--- END Mapped Contract_Product_ID --->

				<!--- Find Mapped Component --->
				<CFSET Old_Lump_Sum_ID = evaluate("ThisStructureLevel.PROGRAM_LUMP_SUM_ID_#LoopCount#")>
				<CFSET Mapped_Lump_Sum_ID = "">
				<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Lump_Sum_Component_ID_Mapping)#" STEP="1">
					<CFIF Old_Lump_Sum_ID EQ Lump_Sum_Component_ID_Mapping[ArrayPositionCount][1]>
						<CFSET Mapped_Lump_Sum_ID = Lump_Sum_Component_ID_Mapping[ArrayPositionCount][2]>
						<CFBREAK>
					</CFIF>
				</CFLOOP>
				<!--- END Mapped Contract_Product_ID --->

				<!--- save data query --->
				<CFQUERY NAME="saveLumpSumProducts" datasource="#application.datasource#">
					INSERT INTO #ThisStructureLevel.Master_Table#
					<!---(Contract_Products_ID,PROGRAM_LUMP_SUM_ID)--->
					(#FieldList#, Contract_Products_ID,PROGRAM_LUMP_SUM_ID)
					VALUES
					(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#, #Mapped_product_ID#,'#Mapped_Lump_Sum_ID#')
					<!---(#Mapped_product_ID#,'#Mapped_Lump_Sum_ID#')--->
				</CFQUERY>
			</CFLOOP>
		</CFIF>
		<!--- END save --->
		
		<!--- save lump products Distributors --->
		<CFSET ListOfColumsToIgnore="DELETED,PROGRAM_LUMP_SUM_DISTRIBUTOR_ID,PROGRAM_ID,PROGRAM_LUMP_SUM_ID,CREATED_DATE">
		<CFSET ThisStructureLevel = Program.LUMP_SUM_COMPONENTS.DISTRIBUTORS>
		<CFIF ThisStructureLevel.recordcount GT 0>
			<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
				<CFSET FieldList = "">
				<CFSET DataValueList = "">
				
				<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
					<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
						<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
						<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
						<CFSET stringToEscape = DataItemForTheList>
						<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(34),"&##34","ALL")> <!--- Double Quotes --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
						<CFSET DataItemForTheList = stringToEscape>
						<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
					</CFIF>
				</CFLOOP>
				
				<!--- Find Mapped Component --->
				<CFSET Old_Lump_Sum_ID = evaluate("ThisStructureLevel.PROGRAM_LUMP_SUM_ID_#LoopCount#")>
				<CFSET Mapped_Lump_Sum_ID = "">
				<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Lump_Sum_Component_ID_Mapping)#" STEP="1">
					<CFIF Old_Lump_Sum_ID EQ Lump_Sum_Component_ID_Mapping[ArrayPositionCount][1]>
						<CFSET Mapped_Lump_Sum_ID = Lump_Sum_Component_ID_Mapping[ArrayPositionCount][2]>
						<CFBREAK>
					</CFIF>
				</CFLOOP>
				<!--- END Mapped Contract_Product_ID --->

				<cfif Mapped_Lump_Sum_ID NEQ ""><!------ D10206: If Mapped_Lump_Sum_ID = blank, that mean this component does not exist, or was deleted, so no need to insert the distributor ----->
					<!--- save data query --->
					<CFQUERY NAME="saveLumpSumProducts" datasource="#application.datasource#">
						INSERT INTO #ThisStructureLevel.Master_Table#
						<!---(Contract_Products_ID,PROGRAM_LUMP_SUM_ID)--->
						(#FieldList#, Program_ID, PROGRAM_LUMP_SUM_ID)
						VALUES
						(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#, #getTemplateSettings.EZ_Contract_Id#, '#Mapped_Lump_Sum_ID#')
						<!---(#Mapped_product_ID#,'#Mapped_Lump_Sum_ID#')--->
					</CFQUERY>
				</cfif>
			</CFLOOP>
		</CFIF>
		<!--- END save --->	
</cfif>

<CFIF getTemplateSettings.Discount_Growth EQ 1>
		<!--- intialize Growth component mapping array --->
		<CFSET Growth_Component_ID_Mapping = ArrayNew(2)>
		<!--- end intialize Growth component mapping array --->	
						
		<!--- save Growth Component --->
		<CFSET ListOfColumsToIgnore="DELETED,PROGRAM_GROWTH_COMPONENT_ID,PROGRAM_ID,GROWTH_COMPONENT_NAME_ID,PARENT_ID">
		<CFSET ThisStructureLevel = Program.GROWTH_COMPONENTS>
		<CFIF ThisStructureLevel.recordcount GT 0>
			
			<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
				<CFSET FieldList = "">
				<CFSET DataValueList = "">
				
				<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
					<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
						<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
						<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
						<CFSET stringToEscape = DataItemForTheList>
						<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(34),"&##34","ALL")> <!--- Double Quotes --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
						<CFSET DataItemForTheList = stringToEscape>
						<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
					</CFIF>
				</CFLOOP>

				<!--- Dev Note: Clay 10186: Fix for Separate Volume Pools in Growth   --->
				<!--- Find Growth Component Parent ID --->
				<CFSET Old_Growth_Component_Parent_ID = evaluate("ThisStructureLevel.PARENT_ID_#LoopCount#")>
				<CFSET Mapped_Growth_Component_PARENT_ID = "">
				<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Growth_Component_ID_Mapping)#" STEP="1">
					<CFIF Old_Growth_Component_PARENT_ID EQ Growth_Component_ID_Mapping[ArrayPositionCount][1]>
						<CFSET Mapped_Growth_Component_PARENT_ID = Growth_Component_ID_Mapping[ArrayPositionCount][2]>
					</CFIF>
				</CFLOOP>
				<!--- END Find Growth Component Parent ID --->


				<!--- save data query --->
				<CFQUERY NAME="saveGrowthComponent" datasource="#application.datasource#">
					INSERT INTO #ThisStructureLevel.Master_Table#
					(#FieldList#,Program_ID,Parent_ID)
					VALUES
					<!--- (#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,#Renewed_Program_ID#) --->
					(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#getTemplateSettings.EZ_Contract_Id#,<CFIF len(Mapped_Growth_Component_PARENT_ID) NEQ 0>'#Mapped_Growth_Component_PARENT_ID#'<cfelse>NULL</cfif>)
				</CFQUERY>
				<!--- map old lump sum component id to new one --->
				<CFSET Growth_Component_ID_Mapping[ArrayLen(Growth_Component_ID_Mapping)+1][1] = evaluate("ThisStructureLevel.PROGRAM_GROWTH_COMPONENT_ID_#LoopCount#")>
				<CFSET Growth_Component_ID_Mapping[ArrayLen(Growth_Component_ID_Mapping)][2] = saveGrowthComponent.A_ID>
				<!--- end map old lump sum component id to new one --->						
			</CFLOOP>	
		</CFIF>
		<!--- END save --->
		
		<!--- intialize Growth component Tier mapping array --->
		<CFSET Growth_Component_Tier_ID_Mapping = ArrayNew(2)>
		<!--- end intialize Growth component Tier mapping array --->	
		
		<!--- save Growth Component Tiers --->
		<CFSET ListOfColumsToIgnore="PROGRAM_GROWTH_COMPONENT_ID,PROGRAM_GROWTH_COMPONENT_TIER_ID,PROGRAM_ID,DELETED">
		<CFSET ThisStructureLevel = Program.GROWTH_COMPONENTS.TIERS>
		<CFIF ThisStructureLevel.recordcount GT 0>
			<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
				<CFSET FieldList = "">
				<CFSET DataValueList = "">
				
				<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
					<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
						<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
						<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
						<CFSET stringToEscape = DataItemForTheList>
						<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(34),"&##34","ALL")> <!--- Double Quotes --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
						<CFSET DataItemForTheList = stringToEscape>
						<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
					</CFIF>
				</CFLOOP>
				
				<!--- Find Growth Component ID --->
				<CFSET Old_Growth_Component_ID = evaluate("ThisStructureLevel.PROGRAM_GROWTH_COMPONENT_ID_#LoopCount#")>
				<CFSET Mapped_Growth_Component_ID = "">
				<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Growth_Component_ID_Mapping)#" STEP="1">
					<CFIF Old_Growth_Component_ID EQ Growth_Component_ID_Mapping[ArrayPositionCount][1]>
						<CFSET Mapped_Growth_Component_ID = Growth_Component_ID_Mapping[ArrayPositionCount][2]>
					</CFIF>
				</CFLOOP>
				<!--- END Mapped Contract_Product_ID --->

				<!--- save data query --->
				<CFQUERY NAME="saveGrowthComponentTiers" datasource="#application.datasource#">
					INSERT INTO #ThisStructureLevel.Master_Table#
					(#FieldList#,Program_ID,PROGRAM_GROWTH_COMPONENT_ID)
					VALUES
					(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#getTemplateSettings.EZ_Contract_Id#, '#Mapped_Growth_Component_ID#')
				</CFQUERY>
				<!--- map old lump sum component Tier id to new one --->
				<CFSET Growth_Component_Tier_ID_Mapping[ArrayLen(Growth_Component_Tier_ID_Mapping)+1][1] = evaluate("ThisStructureLevel.PROGRAM_GROWTH_COMPONENT_TIER_ID_#LoopCount#")>
				<CFSET Growth_Component_Tier_ID_Mapping[ArrayLen(Growth_Component_Tier_ID_Mapping)][2] = saveGrowthComponentTiers.INS_Program_Growth_Component_Tier_ID>
				<!--- end map old lump sum component Tier id to new one --->	
			</CFLOOP>	
		</CFIF>
		<!--- END save --->

		<!--- init PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID mapping array ---> 				
		<CFSET PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID_Mapping = ArrayNew(2)>
		<!--- end init PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID mapping array ---> 				
		
		<!--- save Growth Component Tier Products --->
		<CFSET ListOfColumsToIgnore="CONTRACT_PRODUCTS_ID,DELETED,PROGRAM_GROWTH_COMPONENT_ID,PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID">
		<CFSET ThisStructureLevel = Program.GROWTH_COMPONENTS.TIERS.TIER_PRODUCTS>
		<CFIF ThisStructureLevel.recordcount GT 0>
			<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
				<CFSET FieldList = "">
				<CFSET DataValueList = "">
				
				<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
					<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
						<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
						<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
						<CFSET stringToEscape = DataItemForTheList>
						<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(34),"&##34","ALL")> <!--- Double Quotes --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
						<CFSET DataItemForTheList = stringToEscape>
						<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
					</CFIF>
				</CFLOOP>
				
				<!--- Find Mapped Contract_Product_ID --->
				<CFSET Old_Contract_Product_ID = evaluate("ThisStructureLevel.Contract_Products_ID_#LoopCount#")>
				<CFSET Mapped_product_ID = "">
				<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Contract_Products_ID_Mapping)#" STEP="1">
					<CFIF Old_Contract_Product_ID EQ Contract_Products_ID_Mapping[ArrayPositionCount][1]>
						<CFSET Mapped_product_ID = Contract_Products_ID_Mapping[ArrayPositionCount][2]>
						<CFBREAK>
					</CFIF>
				</CFLOOP>
				<!--- END Mapped Contract_Product_ID --->

				<!--- Find Growth Component ID --->
				<CFSET Old_Growth_Component_ID = evaluate("ThisStructureLevel.PROGRAM_GROWTH_COMPONENT_ID_#LoopCount#")>
				<CFSET Mapped_Growth_Component_ID = "">
				<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Growth_Component_ID_Mapping)#" STEP="1">
					<CFIF Old_Growth_Component_ID EQ Growth_Component_ID_Mapping[ArrayPositionCount][1]>
						<CFSET Mapped_Growth_Component_ID = Growth_Component_ID_Mapping[ArrayPositionCount][2]>
					</CFIF>
				</CFLOOP>
				<!--- END Growth Component ID --->
				
				<!--- save data query --->
				<!--- <CFIF isdefined("saveGrowthComponentProducts")> --->
					<CFQUERY NAME="saveGrowthComponentProducts" datasource="#application.datasource#">
						INSERT INTO #ThisStructureLevel.Master_Table#
						(#FieldList#,CONTRACT_PRODUCTS_ID,PROGRAM_GROWTH_COMPONENT_ID)
						VALUES
						(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,'#Mapped_product_ID#','#Mapped_Growth_Component_ID#')
					</CFQUERY>
					<!--- save product mapping --->
					<CFSET PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID_Mapping[ArrayLen(PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID_Mapping)+1][1] = evaluate("ThisStructureLevel.PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID_#LoopCount#")>
					<CFSET PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID_Mapping[ArrayLen(PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID_Mapping)][2] = saveGrowthComponentProducts.Program_Growth_Component_Product_Data_ID>
				<!--- </CFIF> --->
				<!--- end save product mapping --->
			</CFLOOP>
		</CFIF>
		<!--- END save --->		

		<!--- save product_tier rates data --->
		<CFSET ListOfColumsToIgnore="DELETED,PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID,PROGRAM_GROWTH_COMPONENT_PRODUCT_TIER_DATA_ID,PROGRAM_GROWTH_COMPONENT_TIER_ID">
		<CFSET ThisStructureLevel = Program.GROWTH_COMPONENTS.TIERS.TIER_PRODUCTS.PRODUCT_TIER_DATA>
		<CFIF ThisStructureLevel.recordcount GT 0>
			<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
				<CFSET FieldList = "">
				<CFSET DataValueList = "">
				
				<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
					<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
						<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
						<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
						<CFSET stringToEscape = DataItemForTheList>
						<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(34),"&##34","ALL")> <!--- Double Quotes --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
						<CFSET DataItemForTheList = stringToEscape>
						<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
					</CFIF>
				</CFLOOP>
				
				<!--- FIND PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID --->
				<CFSET OLD_PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID = evaluate("ThisStructureLevel.PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID_#LoopCount#")>
				<CFSET Mapped_PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID = "">
				<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID_Mapping)#" STEP="1">
					<CFIF OLD_PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID EQ PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID_Mapping[ArrayPositionCount][1]>
						<CFSET Mapped_PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID = PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID_Mapping[ArrayPositionCount][2]>
					</CFIF>
				</CFLOOP>
				<!--- FIND PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID --->

				<!--- FIND PROGRAM_GROWTH_COMPONENT_PRODUCT_TIER_DATA_ID --->
				<CFSET OLD_Growth_Component_Tier_ID_Mapping  = evaluate("ThisStructureLevel.PROGRAM_GROWTH_COMPONENT_TIER_ID_#LoopCount#")>
				<CFSET Mapped_Growth_Component_Tier_ID_Mapping = "">
				<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Growth_Component_Tier_ID_Mapping)#" STEP="1">
					<CFIF OLD_Growth_Component_Tier_ID_Mapping EQ Growth_Component_Tier_ID_Mapping[ArrayPositionCount][1]>
						<CFSET Mapped_Growth_Component_Tier_ID_Mapping = Growth_Component_Tier_ID_Mapping[ArrayPositionCount][2]>
					</CFIF>
				</CFLOOP>
				<!--- FIND PROGRAM_GROWTH_COMPONENT_PRODUCT_TIER_DATA_ID --->						

				<!--- save data query --->
				<!--- If a tier has been removed, Do not look for that tier to copy --->
			<cfif Mapped_Growth_Component_Tier_ID_Mapping neq "">
				<CFQUERY NAME="saveproduct_tier_data" datasource="#application.datasource#">
					INSERT INTO #ThisStructureLevel.Master_Table#
					(#FieldList#,PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID,PROGRAM_GROWTH_COMPONENT_TIER_ID)
					VALUES
					(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,'#Mapped_PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID#','#Mapped_Growth_Component_Tier_ID_Mapping#')
				</CFQUERY>
			</cfif>
			</CFLOOP>
		</CFIF>
		<!--- END save --->
</cfif>	
		
<CFIF getTemplateSettings.Discount_Formula_Pricing EQ 1>
		<!--- save pricing formula periods --->
		<!------<CFSET ListOfColumsToIgnore="PROGRAM_FORMULA_PRICING_PERIOD_ID,PROGRAM_ID">----->
		<CFSET ListOfColumsToIgnore="PROGRAM_FORMULA_PRICING_PERIOD_ID,PROGRAM_ID,PROCESS_BY_SYSTEM,CREATED_BY_SYSTEM,IS_CURRENT_PERIOD">
		<CFSET ThisStructureLevel = Program.FORMULA_PRICING.PERIODS>
		<CFIF ThisStructureLevel.recordcount GT 0>
			<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
				<CFSET FieldList = "">
				<CFSET DataValueList = "">
				
				<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
					<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
						<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
						<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
						<CFSET stringToEscape = DataItemForTheList>
						<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(34),"&##34","ALL")> <!--- Double Quotes --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
						<CFSET DataItemForTheList = stringToEscape>
						<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
					</CFIF>
				</CFLOOP>

				<!--- save data query --->
				<CFQUERY NAME="savePricingPeriods" datasource="#application.datasource#">
					INSERT INTO #ThisStructureLevel.Master_Table#
					(#FieldList#,Program_ID)
					VALUES
					(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#getTemplateSettings.EZ_Contract_Id#)
				</CFQUERY>
			</CFLOOP>	
		</CFIF>
		<!--- END save --->

		<!--- intialize formula pricing rule ID mapping array --->
		<CFSET Program_Formula_Pricing_Rule_ID_Mapping = ArrayNew(2)>
		<!--- end intialize formula pricing rule ID mapping array --->	
		
		
		<!--- save pricing formula rules --->
		<CFSET ListOfColumsToIgnore="DELETED,PROGRAM_FORMULA_PRICING_RULE_MAPPED_ID,PROGRAM_ID">
		<CFSET ThisStructureLevel = Program.FORMULA_PRICING.PROGRAMRULES>
		<CFIF ThisStructureLevel.recordcount GT 0>
			<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
				<CFSET FieldList = "">
				<CFSET DataValueList = "">
				
				<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
					<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
						<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
						<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
						<CFSET stringToEscape = DataItemForTheList>
						<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(34),"&##34","ALL")> <!--- Double Quotes --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
						<CFSET DataItemForTheList = stringToEscape>
						<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
					</CFIF>
				</CFLOOP>

				<!--- save data query --->
				<CFQUERY NAME="savePricingRules" datasource="#application.datasource#">
					INSERT INTO #ThisStructureLevel.Master_Table#
					(#FieldList#,Program_ID)
					VALUES
					(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#getTemplateSettings.EZ_Contract_Id#)
				</CFQUERY>

				<!--- map old rule id to new one --->
				<CFSET Program_Formula_Pricing_Rule_ID_Mapping[ArrayLen(Program_Formula_Pricing_Rule_ID_Mapping)+1][1] = evaluate("ThisStructureLevel.Program_Formula_Pricing_Rule_Mapped_ID_#LoopCount#")>
				<CFSET Program_Formula_Pricing_Rule_ID_Mapping[ArrayLen(Program_Formula_Pricing_Rule_ID_Mapping)][2] = savePricingRules.Program_Formula_Pricing_Rule_Mapped_ID>
				<!--- end map old rule id to new one --->	

				
			</CFLOOP>	
		</CFIF>
		<!--- END save --->
		
		<!--- save Formula Pricing Products --->
		<CFSET ListOfColumsToIgnore="DELETED,PROGRAM_ID,CONTRACT_PRODUCT_ID,PROGRAM_FORMULA_PRICING_RULE_ID,PROGRAM_FORMULA_PRICING_RULE_PRODUCT_ID">
		<CFSET ThisStructureLevel = Program.FORMULA_PRICING.PRODUCTS>
		<CFIF ThisStructureLevel.recordcount GT 0>
			<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
				<CFSET FieldList = "">
				<CFSET DataValueList = "">
				
				<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
					<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
						<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
						<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
						<CFSET stringToEscape = DataItemForTheList>
						<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(34),"&##34","ALL")> <!--- Double Quotes --->
						<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
						<CFSET DataItemForTheList = stringToEscape>
						<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
					</CFIF>
				</CFLOOP>
			
				<!--- FIND Rule ID --->
				<CFSET OLD_PROGRAM_FORMULA_PRICING_RULE_ID = evaluate("ThisStructureLevel.PROGRAM_FORMULA_PRICING_RULE_ID_#LoopCount#")>
				<CFSET Mapped_PROGRAM_FORMULA_PRICING_RULE_ID = "">
				<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Program_Formula_Pricing_Rule_ID_Mapping)#" STEP="1">
					<CFIF OLD_PROGRAM_FORMULA_PRICING_RULE_ID EQ Program_Formula_Pricing_Rule_ID_Mapping[ArrayPositionCount][1]>
						<CFSET Mapped_PROGRAM_FORMULA_PRICING_RULE_ID = Program_Formula_Pricing_Rule_ID_Mapping[ArrayPositionCount][2]>
					</CFIF>
				</CFLOOP>						

				<!--- Find Mapped Contract_Product_ID --->
				<CFSET Old_Contract_Product_ID = evaluate("ThisStructureLevel.Contract_Product_ID_#LoopCount#")>
				<CFSET Mapped_product_ID = "">
				<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Contract_Products_ID_Mapping)#" STEP="1">
					<CFIF Old_Contract_Product_ID EQ Contract_Products_ID_Mapping[ArrayPositionCount][1]>
						<CFSET Mapped_product_ID = Contract_Products_ID_Mapping[ArrayPositionCount][2]>
					</CFIF>
				</CFLOOP>
				<!--- END Mapped Contract_Product_ID --->

				<!--- save data query --->
				<CFQUERY NAME="saveFormulaPricingProducts" datasource="#application.datasource#">
					INSERT INTO #ThisStructureLevel.Master_Table#
					(#FieldList#,Program_ID,Contract_Product_ID,PROGRAM_FORMULA_PRICING_RULE_ID)
					VALUES
					(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#getTemplateSettings.EZ_Contract_Id#,#Mapped_product_ID#,'#Mapped_PROGRAM_FORMULA_PRICING_RULE_ID#')
				</CFQUERY>
			</CFLOOP>	
		</CFIF>
</cfif>

<CFIF getTemplateSettings.Discount_Rebates EQ 1>
	<cfscript>
	
		rebate = createObject("component","components.programs.rebates.Rebate");
		
		//if we are coming from trade planner then we have to handle this differently
		if (isDefined("form.bIsFromTradePlan") and form.bIsFromTradePlan)
		{
			//get the data packet
			//rebateData = rebate.getWddxDataFromFile(form.tpFileName);
			rebateData = rebate.loadFromDB(programID=Program_ID_To_Replicate);
			//commit to database
			if (ArrayLen(rebateData.aProd))
			{
				rebateData.programId = getTemplateSettings.EZ_Contract_Id;
				rebate.commit(rebateData=rebateData,dontCallSP=1);
			}
		}
		
		else
		{
			rebateData = rebate.loadFromDB(programID=Program_ID_To_Replicate);
			// Kal Dev Note : 8575
			if (ArrayLen(rebateData.aProd))
			{
				rebateData.programId = getTemplateSettings.EZ_Contract_Id;
				rebate.commit(rebateData=rebateData,cacheData=0,dontCallSP=1);
			}
		}
		
	</cfscript>
</cfif>

	<cfstoredproc procedure="SP_CAPTURE_ALL_FOR_GROUPS" datasource="#application.datasource#">
								
		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#getTemplateSettings.EZ_Contract_Id#" null="no">
					
	</cfstoredproc>
