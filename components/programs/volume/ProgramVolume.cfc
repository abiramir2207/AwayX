<!------ ProgramVolume.cfc
components.programs.volume.ProgramVolume
----->
<cfcomponent displayname="Contract Volume" hint="Contract Volume">

	<!---TSF: Modification Bid Request--->
	<cfset this.programId = 0 />
	<cfset this.programProductVolume = ArrayNew(1) />
	<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
	<cfset DistributorGroupManager = CreateObject("component", "components.programs.distributors.DistributorGroupManager").init() />
	<cfset GroupDataManager = CreateObject("component","components.products.Group.DataManager").init() />

	<!--- programId setter --->
	<cffunction name="setProgramId" access="public" output="false">
		<cfargument name="programId" required="true" default="" />
		<cfset this.programId = arguments.programId />
	</cffunction>
	<!--- programId getter --->
	<cffunction name="getProgramId" access="public" output="false">
		<cfreturn this.programId />
	</cffunction>

	<!--- programProductVolume setter --->
	<cffunction name="setProgramProductVolume" access="public" output="false">
		<cfargument name="programProductVolume" required="true" default="" type="components.programs.volume.ProgramProductVolume" />
		<cfset ArrayAppend(this.programProductVolume, arguments.programProductVolume) />
	</cffunction>
	<!--- programProductVolume getter --->
	<cffunction name="getProgramProductVolume" access="public" output="false">
		<cfreturn this.programProductVolume />
	</cffunction>

   	<!----------------- Load_Basic_Information() -------------------->
   	<cffunction name="Load_Basic_Information" output="true" hint="load with Basic Information values">
		<cfargument name="Program_ID" type="numeric" required="true" default="">
		<cfargument name="companyId" type="string" required="false" default="">

		<cfsilent>

		<cfset this.Program_ID = arguments.Program_ID>

		<CFQUERY NAME="Get_Program_Details" DATASOURCE="#application.datasource#">
			SELECT	Generic_Type.Generic_Type_ID,
					Program_Control_Panel_Options.Generic_Type,
					Program_Control_Panel_Options.Zero_Volume,
					Contract_Main.Contract_Number,
					Contract_Main.Contract_Title,
					Contract_Main.Contract_Quantity_UOM_IDX,
					ISNULL(Contract_Main.Contract_Quantity, 0) as Contract_Quantity,
					Contract_Main.Contract_Start_Date, Contract_Main.Contract_End_Date,
					Contract_Main_Aux_Data.Forecast_ID,
					Program_Control_Panel_Options.Volume_Cap,
					Program_Control_Panel_Options.BidRequestStatusOn,
					Program_Control_Panel_Options.ItemMarked_Lost_Program_Volume_Automation
			FROM	Contract_Main
					INNER JOIN 	Contract_Main_Aux_Data
					ON
					Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID
					INNER JOIN Program_Control_Panel_Options
					ON
					Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
					INNER JOIN Generic_Type
					ON
					Generic_Type.Generic_Type = Program_Control_Panel_Options.Generic_Type
			WHERE
					Contract_Main.Contract_Main_ID = #this.Program_ID#
		</CFQUERY>

			<!----- Program Info ----->
			<cfset this.Contract_Number 			= Get_Program_Details.Contract_Number>
			<cfset this.Contract_Title 				= Get_Program_Details.Contract_Title>
			<cfset this.Contract_Start_Date 		= Get_Program_Details.Contract_Start_Date>
			<cfset this.Contract_End_Date 			= Get_Program_Details.Contract_End_Date>
			<cfif isDate(this.Contract_Start_Date) and isDate(this.Contract_End_Date)>
				<cfset this.Contract_Span				= DateDiff("d", this.Contract_Start_Date, this.Contract_End_Date) + 1>
			</cfif>
			<cfset this.UOM 						= Get_Program_Details.Contract_Quantity_UOM_IDX>
			<cfset this.Contract_Quantity			= Get_Program_Details.Contract_Quantity>
			<cfset this.Forecast_ID					= Get_Program_Details.Forecast_ID>
			<cfset this.Volume_Cap					= Get_Program_Details.Volume_Cap>
			<cfset this.Zero_Volume					= Get_Program_Details.Zero_Volume>
			<cfif this.Forecast_ID EQ "" OR NOT IsNumeric(this.Forecast_ID)>
				<CFSET this.Forecast_ID = 0>
			</cfif>

			<CFIF Get_Program_Details.Generic_Type_ID EQ 1 OR Get_Program_Details.Generic_Type_ID EQ 5>
				<cfset this.Can_Do_Forecast = true>
				<cfset this.Can_Do_Forecast_String = "">
				<cfif ProductGroupManager.isAllProductProgram(this.Program_ID)>
					<cfset this.Can_Do_Forecast = false>
				<cfelse>
					<cfif DistributorGroupManager.isAllDistributorProgram(this.Program_ID)>
						<cfset this.Can_Do_Forecast = false>
					</cfif>
				</cfif>
			<CFELSE>
				<cfset this.Can_Do_Forecast = false>
				<cfset this.Can_Do_Forecast_String = "Volume forecast cannot be done for '#Get_Program_Details.Generic_Type#' programs">
			</CFIF>

			<CFIF Get_Program_Details.Generic_Type_ID EQ 3 OR Get_Program_Details.Generic_Type_ID EQ 4>
				<cfset this.Can_Do_Claim_Forecast = 1>
			<cfelse>
				<cfset this.Can_Do_Claim_Forecast = 0>
			</CFIF>
			<cfset this.BidRequestStatusOn 			= Get_Program_Details.BidRequestStatusOn>
			<cfset this.ItemMarked_Lost_Program_Volume_Automation 	= Get_Program_Details.ItemMarked_Lost_Program_Volume_Automation>

			<CFSET this.Window_Max_Width = 700>

			<cfset key = request.app_general_functions.GenerateKey()>
			<CF_Cryp type="en" key="#request.key#" string ="#this.Program_ID#">
			<CFSET this.Encrypted_Program_ID 	= cryp.value>

			<cfset this.defaultUOT	= CreateObject("component", "components.volume.uotManager").getDefaultVolumeUOT(arguments.companyId)>

			<CFSET objVolumeApplicator = CreateObject("component", "components.volume.VolumeApplicator")>

		</cfsilent>

   	</cffunction>

	<cffunction name="loadVolumInfoToPacket" output="true" hint="loadVolumInfoToPacket">
		<cfargument name="extraProductList" type="string" required="false" default="">
		<cfargument name="byGroups" type="string" required="false" default="0">
		<cfargument name="useAllowList" type="numeric" required="false" default="0">
		<cfargument name="allowList" type="string" required="false" default="">
		<cfargument name="ShowItemsOnly" type="numeric" required="false" default="0">

		<cfsilent>

		<CFSET this.Packet_ID = "">
		<CFSET this.Volume_Packet_Builder = CreateObject("component", "components.volume.BuildVolumePacket")>
		<CFSET Packet_ID = this.Volume_Packet_Builder.init(this.Packet_ID, 1)>

		<CFSET this.Volume_Packet_Builder.setAppAreaId(1, this.Program_ID)>
		<CFSET this.Volume_Packet_Builder.setUom(this.uom)>
		<CFSET this.Volume_Packet_Builder.setForecastId(this.Forecast_ID)>
		<CFSET this.Volume_Packet_Builder.setAppAreaDates(this.Contract_Start_Date, this.Contract_End_Date)>
		<CFSET this.Volume_Packet_Builder.setAvgQuantityApplicator(this.Contract_Quantity, 1)>
		<CFSET this.Volume_Packet_Builder.setAppAreaTitle("[#this.Contract_Number#] - #this.Contract_Title#")>
		<CFSET this.Volume_Packet_Builder.setAppAreaReturnToFile("/Common_Files/contracts/contract_volume.cfm")>
		<cfset this.Volume_Packet_Builder.setSaveTotalQuantity(1)>
		<cfset this.Volume_Packet_Builder.setCanDoForecast(this.Can_Do_Forecast)>
		<cfset this.Volume_Packet_Builder.setCanDoForecastString(this.Can_Do_Forecast_String)>
		<cfset this.Volume_Packet_Builder.setCanDoClaimForecast(this.Can_Do_Claim_Forecast)>
		<cfset this.Volume_Packet_Builder.setVolumeUOT(this.defaultUOT.getId()) />
		<cfset this.Volume_Packet_Builder.setZeroVolume(this.Zero_Volume) />
		<!---if we allow zero volume then we don't need to get zero volume counts--->
		<cfif not this.Volume_Packet_Builder.getZeroVolume()>
			<cfset this.Volume_Packet_Builder.setProductsWithZeroVolume(this.Get_Null_Volume_Product_List().RecordCount) />
		</cfif>
		<cfset this.Volume_Packet_Builder.setVolumeMultiplier(this.defaultUOT.getMultiplier()) />

		<cfset this.Volume_Packet_Builder.setShowVolumeCap(this.Volume_Cap) />
		<cfset this.Volume_Packet_Builder.setVolumeAtGroupLevel(arguments.byGroups) />
		<cfset businessSegmentID = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager").getSegmentIdByProgram(this.Program_ID) />
		<cfset this.Volume_Packet_Builder.setAllProductsSelected(ProductGroupManager.isAllProductProgram(this.Program_ID))>

		<cfset useLakebaseForGet_Ditributors = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_distributors")>
<cfif useLakebaseForGet_Ditributors>
	<cftry>
		<cfset Get_Ditributors = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_distributors", {
				"contract_main_id" = "eq.#this.Program_ID#",
				"deleted" = "eq.0",
				"select" = "bsa_foodservice_customers_id,distributor_group_level_id,distributor_group_id"
			}), "bsa_foodservice_customers_id,distributor_group_level_id,distributor_group_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Ditributors = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Ditributors>
<CFQUERY NAME="Get_Ditributors" DATASOURCE="#application.datasource#">
			SELECT	Contract_Distributors.BSA_Foodservice_Customers_ID,
					Contract_Distributors.Distributor_Group_Level_ID,
					Contract_Distributors.Distributor_Group_ID
			FROM	Contract_Distributors
			WHERE
					Contract_Distributors.Contract_Main_ID = #this.Program_ID#
					AND
					Contract_Distributors.Deleted = 0
		</CFQUERY>
</cfif>
		<CFSET this.Volume_Packet_Builder.addDistributors(ValueList(Get_Ditributors.BSA_Foodservice_Customers_ID, ","))>
		<cfset useLakebaseForqGetLevel_1_Distributors = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_ditributors")>
<cfif useLakebaseForqGetLevel_1_Distributors>
	<cftry>
		<cfset qGetLevel_1_Distributors = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_ditributors", {
				"distributor_group_level_id" = "eq.1",
				"select" = "distributor_group_id"
			}), "distributor_group_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetLevel_1_Distributors = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetLevel_1_Distributors>
<cfquery name="qGetLevel_1_Distributors" dbtype="query">
			SELECT	Distributor_Group_ID
			FROM	Get_Ditributors
			WHERE	Distributor_Group_Level_ID = 1
		</cfquery>
</cfif>
		<cfset Distributor_Level_1 = ValueList(qGetLevel_1_Distributors.Distributor_Group_ID) />
		<cfset this.Volume_Packet_Builder.setAllProductsSelected(ProductGroupManager.isAllProductProgram(this.Program_ID))>
		<cfif Distributor_Level_1 EQ 1>
			<CFSET this.Volume_Packet_Builder.setAllDistributorsSelected(1)>
		</cfif>
		<!---get operators--->
		<cfset useLakebaseForGet_Operators = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_operators")>
<cfif useLakebaseForGet_Operators>
	<cftry>
		<cfset Get_Operators = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_operators", {
				"contract_main_id" = "eq.#this.Program_ID#",
				"deleted" = "eq.0",
				"select" = "bsa_operator_id"
			}), "bsa_operator_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Operators = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Operators>
<CFQUERY NAME="Get_Operators" DATASOURCE="#application.datasource#">
			SELECT	Contract_Operators.BSA_Operator_ID
			FROM	Contract_Operators
			WHERE	Contract_Operators.Contract_Main_ID = #this.Program_ID#
			AND		Contract_Operators.Deleted = 0
		</CFQUERY>
</cfif>
		<CFSET this.Volume_Packet_Builder.addOperators(ValueList(Get_Operators.BSA_Operator_ID, ","))>

		<CFSET Get_Product_List(Not_In_Forecast=0,
						Load_Individual_Volume=1,
						extraProductList=arguments.extraProductList,
						byGroups=arguments.byGroups,
						useAllowList=arguments.useAllowList,
						allowList=arguments.allowList,
						ShowItemsOnly = arguments.ShowItemsOnly)>
		<cfset this.Volume_Packet_Builder.setMainProductsQuery(Get_Distinct_Products)>

		<CFLOOP QUERY="Get_Distinct_Products">
			<CFSET Product_Volume 	= this.GetProductVolume(BSA_Foodservice_Items_Master_ID, this.UOM)>
			<cfset qProductVolumeCapInfo = this.getProductVolumeCapInfo(BSA_Foodservice_Items_Master_ID) />

			<cfparam name="groupName" default="" />
			<cfparam name="groupId" default="" />
			<cfparam name="isPartOfGroup" default="" />

			<!---- add product id and volume ----->
			<CFSET this.Volume_Packet_Builder.addProduct(BSA_Foodservice_Items_Master_ID, Product_Volume, qProductVolumeCapInfo.Volume_Cap, groupName, groupId, Is_Group, isPartOfGroup)>

		</CFLOOP>

		<cfif this.Volume_Packet_Builder.forecastGood()>
			<cfset this.Volume_Packet_Builder.setAction("list")>
		</cfif>

		<CFSET this.Packet_ID = this.Volume_Packet_Builder.saveVolumePacket()>

		</cfsilent>

	</cffunction>

	<cffunction name="Goto_Forecast" output="true" hint="Goto_Forecast">
		<cfargument name="extraProductList" type="string" required="false" default="">
		<cfargument name="byGroups" type="string" required="false" default="0">

		<cfset this.loadVolumInfoToPacket(arguments.extraProductList, arguments.byGroups)>

		<cflocation url="/Common_Files/Volume/Volume_Applicator.cfm?packetId=#this.Packet_ID#" addtoken="No">
	</cffunction>

	<cffunction name="Goto_Forecast_Details" output="true" hint="Goto_Forecast_Details">
		<cfargument name="productId" type="string" required="true" default="">

		<CFSET this.Packet_ID = "">
		<CFSET Volume_Packet_Builder = CreateObject("component", "components.volume.BuildVolumePacket")>
		<CFSET Packet_ID = Volume_Packet_Builder.init(this.Packet_ID, 1)>

		<CFSET Volume_Packet_Builder.setAppAreaId(1, this.Program_ID)>
		<CFSET Volume_Packet_Builder.setForecastId(this.Forecast_ID)>

		<CFQUERY NAME="Get_Ditributors" DATASOURCE="#application.datasource#">
			SELECT	Contract_Distributors.BSA_Foodservice_Customers_ID
			FROM	Contract_Distributors
			WHERE
					Contract_Distributors.Contract_Main_ID = #this.Program_ID#
					AND
					Contract_Distributors.Deleted = 0
		</CFQUERY>
		<CFSET D_TEMP = Volume_Packet_Builder.addDistributors(ValueList(Get_Ditributors.BSA_Foodservice_Customers_ID, ","))>

		<CFSET D_TEMP = Get_Product_List()>
		<CFLOOP QUERY="Get_Distinct_Products">
			<CFSET Product_Volume 	= this.GetProductVolume(BSA_Foodservice_Items_Master_ID, this.UOM)>
			<!---- add product id and volume ----->
			<CFSET D_TEMP = Volume_Packet_Builder.addProduct(BSA_Foodservice_Items_Master_ID, Product_Volume)>
		</CFLOOP>

		<CFSET this.Packet_ID = Volume_Packet_Builder.saveVolumePacket()>

		<cflocation url="/Common_Files/Volume/Volume_Forcast_Detail.cfm?packetId=#this.Packet_ID#&PID=#arguments.productId#" addtoken="No">
	</cffunction>

	<cffunction name="Save_From_Forecast" output="true" hint="Save_From_Forecast">
		<cfargument name="Packet_ID" type="string" required="true" default="">

		<cfsilent>

		<CFSET this.Packet_ID = arguments.Packet_ID>

		<CFSET Volume_Packet_Builder = CreateObject("component", "components.volume.BuildVolumePacket")>
		<CFSET Packet_ID = Volume_Packet_Builder.init(this.Packet_ID, 0)>

		<cfset this.volumePacket 	= Volume_Packet_Builder.getVolumePacket()>
		<cfset this.Program_ID 		= this.volumePacket.appAreaId>
		<cfset this.Contract_Span 	= this.volumePacket.appAreaSpan>
		<cfset this.volumeMultiplier = this.volumePacket.volumeMultiplier />
		<cfset currentVolumeMultiplier = this.volumeMultiplier>
		<cfset Is_Group = 0 />

		<cfif NOT this.volumeMultiplier>
			<cfset this.volumeMultiplier = this.Contract_Span />
		</cfif>
		</cfsilent>
		<cfif this.volumePacket.volumeAction EQ "apply">

			<cfsilent>
			<cfset prodArray = this.volumePacket.products>
			<cfset prodLen = ArrayLen(prodArray)>

			<cfset Total_Volume 		= 0>
			<CFSET WeeklyVolume_POUND 	= 0>
			<CFSET WeeklyVolume_CASE 	= 0>

			<cfloop index="i" from="1" to="#prodLen#">
				<cfset This_Product = prodArray[i].productId>
				<cfset This_Product_Is_Group = prodArray[i].isGroup>
				<cfset This_Volume 	= prodArray[i].productVolume>
				<cfset This_NetWeight = prodArray[i].netweight>
				<cfset productUOMId = 2 />
				<cfif Trim(prodArray[i].ProductUOM) NEQ "LB">
					<cfset productUOMId = 1 />
				</cfif>
				<cfset Volume_Cap = prodArray[i].productVolumeCap>
				<!------
				<cfif NOT isNumeric(Volume_Cap)>
					<cfset Volume_Cap = "NULL">
				</cfif>
				----->

				<CFIF IsNumeric(This_Volume)>
					<cfset Volume_In_UOT 	= This_Volume>

					<cfif NOT this.volumePacket.allProductsSelected OR prodArray[i].productGroupLevel EQ 1>
						<CFSET Total_Volume = Total_Volume + This_Volume>
					</cfif>
					<CFSET This_Volume = This_Volume  * (7 / this.volumeMultiplier)>
					<!---<CFSET This_Volume = Trim(NumberFormat(This_Volume, "__.___"))>--->

					<CFIF this.volumePacket.UOM EQ 1><!--- cases --->
						<CFSET WeeklyVolume_CASE = This_Volume>
						<CFSET WeeklyVolume_POUND = This_Volume * This_NetWeight>
					</CFIF>

					<CFIF this.volumePacket.UOM EQ 2><!--- pounds --->
						<CFSET WeeklyVolume_POUND = This_Volume>
						<CFSET WeeklyVolume_CASE = This_Volume / This_NetWeight>
					</CFIF>
				<CFELSE>
					<cfset Volume_In_UOT 	= This_Volume>
					<CFSET This_Volume = "NULL">
					<CFSET WeeklyVolume_POUND 	= "NULL">
					<CFSET WeeklyVolume_CASE 	= "NULL">
				</CFIF>

				<CFQUERY NAME="Delete_Volume" DATASOURCE="#application.datasource#">

					DELETE	FROM Program_Product_Volume
					WHERE 	Program_ID = '#this.Program_ID#'
					AND		BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#This_Product#" cfsqltype="CF_SQL_VARCHAR">

				</CFQUERY>

				<!---------- Insert Global Volume Rule ------------>
				<CFQUERY NAME="Get_Global_Volume" DATASOURCE="#application.datasource#">

					INSERT INTO	Program_Product_Volume
						(BSA_Foodservice_Items_Master_ID, Program_ID, Volume_LB, Volume_CS, Volume_Cap, Volume_Cap_UOM, Is_Group)
					VALUES
						(<cfqueryparam value="#This_Product#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#this.Program_ID#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#WeeklyVolume_POUND#" cfsqltype="CF_SQL_FLOAT" null="#NOT isNumeric(WeeklyVolume_POUND)#">,
						<cfqueryparam value="#WeeklyVolume_CASE#" cfsqltype="CF_SQL_FLOAT" null="#NOT isNumeric(WeeklyVolume_CASE)#">,
						<cfqueryparam value="#Volume_Cap#" cfsqltype="CF_SQL_FLOAT" null="#NOT isNumeric(Volume_Cap)#">,
						<cfqueryparam value="#productUOMId#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#This_Product_Is_Group#" cfsqltype="CF_SQL_BIT">)

				</CFQUERY>

				<!------ If this is a group, we have to divide up and save volume for products  ----->
				<!---handle for groups--->
				<cfif This_Product_Is_Group>

					<!---get a count--->
					<CFQUERY NAME="qGetCount" DATASOURCE="#application.datasource#">

						SELECT 	COUNT(DISTINCT Program_Product_Volume.BSA_Foodservice_Items_Master_ID) AS Count
						FROM 	Program_Product_Volume
								INNER JOIN Contract_Products ON
								Contract_Products.BSA_Foodservice_Items_Master_ID = Program_Product_Volume.BSA_Foodservice_Items_Master_ID
								AND Contract_Products.Product_Group_ID = '#This_Product#'
								AND Contract_Products.Deleted = 0
								AND Contract_Products.Contract_Main_ID = #this.Program_ID#
						WHERE 	Program_Product_Volume.Deleted = 0
						AND 	Program_Product_Volume.Program_ID = #this.Program_ID#
						AND 	Program_Product_Volume.Is_Group = 0

					</CFQUERY>

					<!---handle for zero--->
					<cfif qGetCount.RecordCount AND qGetCount.Count>

						<!---------- Update for all group items ------------>
						<CFQUERY NAME="qUpdateGroupItems" DATASOURCE="#application.datasource#">
							UPDATE	Program_Product_Volume
							SET
									<CFIF this.volumePacket.UOM EQ 1><!--- cases --->
									Volume_LB = (#WeeklyVolume_CASE# / #qGetCount.Count#) * CAST(BSA_Foodservice_Items_Master.Net_Weight AS Float),
									Volume_CS = #WeeklyVolume_CASE# / #qGetCount.Count#,
									<CFELSE>
									Volume_LB = #WeeklyVolume_POUND# / #qGetCount.Count#,
									Volume_CS = (#WeeklyVolume_POUND# / #qGetCount.Count#) / CAST(BSA_Foodservice_Items_Master.Net_Weight AS Float),
									</CFIF>
									Volume_Cap = #Volume_Cap#,
									Volume_Cap_UOM = #productUOMId#,
									Updated_Date = getdate()
							FROM 	Program_Product_Volume
									INNER JOIN Contract_Products ON
									Contract_Products.BSA_Foodservice_Items_Master_ID = Program_Product_Volume.BSA_Foodservice_Items_Master_ID
									AND Contract_Products.Product_Group_ID = '#This_Product#'
									AND Contract_Products.Deleted = 0
									AND Contract_Products.Contract_Main_ID = #this.Program_ID#
									INNER JOIN BSA_Foodservice_Items_Master
									ON	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
							WHERE 	Program_Product_Volume.Deleted = 0
							AND 	Program_Product_Volume.Program_ID = #this.Program_ID#
							AND 	Program_Product_Volume.Is_Group = 0
						</CFQUERY>
					</cfif>
				</cfif>
			</cfloop>

			<cfif NOT this.volumePacket.bVolumeAtGroupLevel><!--- if the user is applying volume at item level --->
				<cfset bIsGroupDeal = CreateObject("component", "components.products.group.DataManager").isGroupDeal(this.Program_ID) />
				<cfif bIsGroupDeal>
					<!--- sum the volume at item level to set the group level volume --->
					<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_GROUP_VOLUME_UPDATE" datasource="#application.datasource#">

						<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName="@Program_ID" value="#this.Program_ID#" null="no">

					</cfstoredproc>
				</cfif>
			</cfif>

			<cfif this.volumePacket.saveTotalVolume>
				<cfset Total_Volume = Total_Volume * (this.Contract_Span / this.volumeMultiplier) />
				<CFSET D_Temp = this.save_program_volume(Total_Volume)>
			</cfif>

			</cfsilent>

			<script language="JavaScript">

				function replace(string,text,by)
				{
					// Replaces text with by in string
					var strLength = string.length, txtLength = text.length;
					if ((strLength == 0) || (txtLength == 0)) return string;

					var i = string.indexOf(text);
					if ((!i) && (text != string.substring(0,txtLength))) return string;
					if (i == -1) return string;

					var newstr = string.substring(0,i) + by;

					if (i+txtLength < strLength)
						newstr += replace(string.substring(i+txtLength,strLength),text,by);

					return newstr;
				}

				if(window.opener)
				{
					//this is to tell the opener not to use the cached file
					var mode = replace(window.opener.location.href.substring(),'editMode=1','editMode=0');
					window.opener.location.replace(mode);
					//window.opener.location.reload();
				}
			</script>
		</cfif><!---End this.volumePacket.volumeAction --->

		<!------ save forcastId ----->
		<cfset useLakebaseForSaveForecastID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main_aux_data")>
<cfif useLakebaseForSaveForecastID>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main_aux_data",
			{
				"contract_main_id" = "eq.#this.Program_ID#"
			},
			{
				"forecast_id" = "#this.volumePacket.forecastId#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSaveForecastID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSaveForecastID>
<CFQUERY NAME="SaveForecastID" DATASOURCE="#application.datasource#">
			UPDATE	Contract_Main_Aux_Data
			SET		Forecast_ID = #this.volumePacket.forecastId#
			WHERE
					Contract_Main_Aux_Data.Contract_Main_ID = #this.Program_ID#
		</CFQUERY>
</cfif>
			<script language="JavaScript">
				window.close();
			</script>
	</cffunction>

	<!----------------- save_program_volume() -------------------->
   	<cffunction name="save_program_volume" output="false" hint="save_program_volume">
		<cfargument name="Program_Volume" type="numeric" required="true" default="">
		<CFSET Program_Volume = Arguments.Program_Volume>
		<CFSET DailyContractQuantity = Program_Volume / this.Contract_Span>

		<cfset useLakebaseForSave_Program_Volume = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForSave_Program_Volume>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"contract_main_id" = "eq.#this.Program_ID#"
			},
			{
				"contract_quantity" = "#Program_Volume#",
				"contract_daily_volume" = "#DailyContractQuantity#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Program_Volume = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Program_Volume>
<CFQUERY NAME="Save_Program_Volume" DATASOURCE="#application.datasource#">
			UPDATE	Contract_Main
			SET		Contract_Quantity = #Program_Volume#,
					Contract_Daily_Volume = #DailyContractQuantity#
			WHERE
					Contract_Main_ID = #this.Program_ID#
		</CFQUERY>
</cfif>

		<cfif this.volumePacket.allProductsSelected>
			<!------ update all products with avg volume ----->
			<cfset ProductGroupManager.updateOtherAvgProductVolume(this.Program_ID) />
		</cfif>

	</cffunction>

	<cffunction name="Get_Product_List" output="true" hint="Get_Product_List">
		<cfargument name="Not_In_Forecast" type="numeric" required="false" default="0">
		<cfargument name="Load_Individual_Volume" type="numeric" required="false" default="1">
		<cfargument name="extraProductList" type="string" required="false" default="">
		<cfargument name="byGroups" type="string" required="false" default="0">
		<cfargument name="useAllowList" type="numeric" required="false" default="0">
		<cfargument name="allowList" type="string" required="false" default="">
		<cfargument name="ShowItemsOnly" type="numeric" required="false" default="0">

		<cfsilent>

		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Items_Master.Item">
		<CFSET SORT_BY = "Item">
		<CFSET SORT_ORDER = "ASC">
		<CFSWITCH expression="#SORT_BY#">
			<CFCASE value="Item">
				<CFSET sql_Sort_By="BSA_Foodservice_Items_Master.Item">
			</CFCASE>
			<CFCASE value="UPC">
				<CFSET sql_Sort_By="BSA_Foodservice_Items_Master.UPC">
			</CFCASE>
			<CFCASE value="Description">
				<CFSET sql_Sort_By="BSA_Foodservice_Items_Master.Description">
			</CFCASE>
		</CFSWITCH>
		<CFIF SORT_ORDER NEQ "ASC">
			<CFSET SORT_ORDER = "DESC">
		</CFIF>
		<CFSET sql_Sort_By = "#sql_Sort_By# #SORT_ORDER#">

		<cfparam name="tableName" default="Type_Code_Desc" />
		<cfparam name="NameField" default="Type_Code_Desc" />
		<cfparam name="IDField" default="Type_Code_Desc_ID" />

		<!---if it's not get by groups then get which group types to group by--->
		<cfif arguments.byGroups EQ 0 AND arguments.ShowItemsOnly eq 0>
			<cfset getGroupTypes = CreateObject("component","components.products.Group.GroupManager").getGroupByGroupType() />
			<cfset tableName = getGroupTypes.tableName  />
			<cfset NameField = getGroupTypes.NameField />
			<cfset IDField = getGroupTypes.IDField />
		</cfif>

		<CFQUERY NAME="Get_Distinct_Products" DATASOURCE="#application.datasource#">
			IF OBJECT_ID('tempdb..##Hier_Temp_Tabl_') IS NOT NULL
			DROP TABLE ##Hier_Temp_Tabl_
			<!---TSF - Label 17509: Add parent names to the product hierarchy display --->
			SELECT	DISTINCT
					CASE
						WHEN Product_Hierarchy_4.Parent_Product_Hierarchy_ID IS NOT NULL THEN
							RTRIM(Product_Hierarchy_5.Product_Hierarchy_Name) + ' \ ' + RTRIM(Product_Hierarchy_4.Product_Hierarchy_Name) + ' \ ' + RTRIM(Product_Hierarchy_3.Product_Hierarchy_Name) + ' \ ' + RTRIM(Product_Hierarchy_2.Product_Hierarchy_Name) + ' \ ' + RTRIM(Product_Hierarchy_1.Product_Hierarchy_Name) + ' \ ' + Product_Hierarchy.Product_Hierarchy_Name
						WHEN Product_Hierarchy_3.Parent_Product_Hierarchy_ID IS NOT NULL THEN
							RTRIM(Product_Hierarchy_4.Product_Hierarchy_Name) + ' \ ' + RTRIM(Product_Hierarchy_3.Product_Hierarchy_Name) + ' \ ' + RTRIM(Product_Hierarchy_2.Product_Hierarchy_Name) + ' \ ' + RTRIM(Product_Hierarchy_1.Product_Hierarchy_Name) + ' \ ' + Product_Hierarchy.Product_Hierarchy_Name
						WHEN Product_Hierarchy_2.Parent_Product_Hierarchy_ID IS NOT NULL THEN
							RTRIM(Product_Hierarchy_3.Product_Hierarchy_Name) + ' \ ' + RTRIM(Product_Hierarchy_2.Product_Hierarchy_Name) + ' \ ' + RTRIM(Product_Hierarchy_1.Product_Hierarchy_Name) + ' \ ' + Product_Hierarchy.Product_Hierarchy_Name
						WHEN Product_Hierarchy_1.Parent_Product_Hierarchy_ID IS NOT NULL THEN
							RTRIM(Product_Hierarchy_2.Product_Hierarchy_Name) + ' \ ' + RTRIM(Product_Hierarchy_1.Product_Hierarchy_Name) + ' \ ' + Product_Hierarchy.Product_Hierarchy_Name
						WHEN Product_Hierarchy.Parent_Product_Hierarchy_ID IS NOT NULL THEN
							RTRIM(Product_Hierarchy_1.Product_Hierarchy_Name) + ' \ ' + Product_Hierarchy.Product_Hierarchy_Name
						ELSE Product_Hierarchy.Product_Hierarchy_Name
					END AS Product_Hierarchy_Name,
					Product_Hierarchy.Product_Hierarchy_ID
			INTO	##Hier_Temp_Tabl_
			FROM	Product_Hierarchy
					LEFT OUTER JOIN Product_Hierarchy Product_Hierarchy_1
					ON Product_Hierarchy_1.Product_Hierarchy_ID = Product_Hierarchy.Parent_Product_Hierarchy_ID

					LEFT OUTER JOIN Product_Hierarchy Product_Hierarchy_2
					ON Product_Hierarchy_2.Product_Hierarchy_ID = Product_Hierarchy_1.Parent_Product_Hierarchy_ID

					LEFT OUTER JOIN Product_Hierarchy Product_Hierarchy_3
					ON Product_Hierarchy_3.Product_Hierarchy_ID = Product_Hierarchy_2.Parent_Product_Hierarchy_ID

					LEFT OUTER JOIN Product_Hierarchy Product_Hierarchy_4
					ON Product_Hierarchy_4.Product_Hierarchy_ID = Product_Hierarchy_3.Parent_Product_Hierarchy_ID

					LEFT OUTER JOIN Product_Hierarchy Product_Hierarchy_5
					ON Product_Hierarchy_5.Product_Hierarchy_ID = Product_Hierarchy_4.Parent_Product_Hierarchy_ID

			WHERE	Product_Hierarchy.Deleted = 0
			AND		Product_Hierarchy.Product_Hierarchy_ID IN (SELECT DISTINCT Product_Group_ID FROM Contract_Products WHERE Deleted = 0 AND Is_Group = 1 AND Contract_Main_ID = #this.Program_ID#)
			ORDER BY Product_Hierarchy_Name

			SELECT     	DISTINCT
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
						BSA_Foodservice_Items_Master.Item,
						BSA_Foodservice_Items_Master.UPC,
                      	CASE
							WHEN EXISTS (SELECT ##Hier_Temp_Tabl_.Product_Hierarchy_ID FROM ##Hier_Temp_Tabl_ WHERE ##Hier_Temp_Tabl_.Product_Hierarchy_ID IS NOT NULL) THEN
							##Hier_Temp_Tabl_.Product_Hierarchy_Name
							ELSE BSA_Foodservice_Items_Master.Description
						END
						AS Description,
						BSA_Foodservice_Items_Master.Inventory_UM ProductUOM,
						CAST(BSA_Foodservice_Items_Master.Net_Weight AS Float) as Net_Weight,
						0 as forecastVolume,
						0 as doneForecast,
						<cfif arguments.byGroups EQ 0 AND arguments.ShowItemsOnly eq 0>
							#tableName#.#NameField# as groupName,
							BSA_Foodservice_Items_Master.#IDField# as groupId,
							BSA_Foodservice_Items_Master.#IDField# as isPartOfGroup,
						</cfif>
						Contract_Products.Is_Group
			FROM		Contract_Products
						LEFT OUTER JOIN ##Hier_Temp_Tabl_
						ON CAST(##Hier_Temp_Tabl_.Product_Hierarchy_ID AS NVARCHAR(50)) = Contract_Products.Product_Group_ID
						INNER JOIN	BSA_Foodservice_Items_Master ON
                      	Contract_Products.BSA_Foodservice_Items_Master_ID = dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
						<cfif arguments.byGroups EQ 0 AND arguments.ShowItemsOnly eq 0>
							INNER JOIN #tableName# ON
							#tableName#.#IDField# = BSA_Foodservice_Items_Master.#IDField#
						</cfif>
			WHERE 		Contract_Products.Contract_Main_ID = #this.Program_ID#
						AND Contract_Products.Deleted = 0
						<cfif arguments.useAllowList eq 1>
							<cfif arguments.allowList eq "">
							AND 1=2
							<cfelse>
							AND Contract_Products.BSA_Foodservice_Items_Master_ID IN (<cfqueryparam list="true" cfsqltype="cf_sql_varchar" value="#arguments.allowList#">)
							</cfif>
						</cfif>
						<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getPgmGrpLevel3IsExclusion()>
						AND	ISNULL(Contract_Products.Pricing_Level_ID, 0) NOT IN (3)
						</cfif>
						<CFIF Arguments.Not_In_Forecast EQ 1>
						AND
						NOT EXISTS
						(
							SELECT	Product_ID
							FROM	Forecast_Volume
							WHERE
									Contract_Products.Contract_Main_ID = Forecast_Volume.Program_ID
									AND
									Contract_Products.BSA_Foodservice_Items_Master_ID = Forecast_Volume.Product_ID
						)
						</CFIF>

						<!---display by groups if we are getting by groups--->
						<cfif arguments.byGroups NEQ 0>
						AND
						(
							<!------ Group ----->
							(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
							OR
							<!------ Product ----->
							(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
						)
						<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getPgmGrpLevel3IsExclusion()>
						AND	ISNULL(Contract_Products.Pricing_Level_ID, 0) NOT IN (2)
						</cfif>
						<cfelse>
							AND Contract_Products.Is_Group = 0
						</cfif>

			<cfif arguments.extraProductList EQ "">
			ORDER BY <cfif arguments.byGroups EQ 0 AND arguments.ShowItemsOnly eq 0>#tableName#.#NameField#,</cfif> #sql_Sort_By#
			<cfelse>
			ORDER BY <cfif arguments.byGroups EQ 0 AND arguments.ShowItemsOnly eq 0>#tableName#.#NameField#,</cfif> BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.UPC, BSA_Foodservice_Items_Master.Description
			</cfif>
			<cfif arguments.extraProductList NEQ "">
			UNION
			SELECT     	DISTINCT
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
						BSA_Foodservice_Items_Master.Item,
						BSA_Foodservice_Items_Master.UPC,
                      	BSA_Foodservice_Items_Master.Description,
						CAST(BSA_Foodservice_Items_Master.Net_Weight AS Float) as Net_Weight,
						0 as forecastVolume,
						0 as doneForecast,
						<cfif arguments.byGroups EQ 0 AND arguments.ShowItemsOnly eq 0>
							'' as groupName,
							'' as groupId,
							0 as isPartOfGroup,
						</cfif>
						0 as Is_Group
			FROM		BSA_Foodservice_Items_Master
            WHERE
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID IN (#ListQualify(arguments.extraProductList, "'", ",")#)
						AND
						BSA_Foodservice_Items_Master.Deleted = 0
						AND
						BSA_Foodservice_Items_Master.Active_Code = 'A'
			</cfif>

			DROP TABLE ##Hier_Temp_Tabl_

		</CFQUERY>

		<CFIF Arguments.Load_Individual_Volume EQ 1>

			<!------------- Global Volume ---------------->
			<CFQUERY NAME="Get_Global_Volume" DATASOURCE="#application.datasource#">
				SELECT		CAST(dbo.Program_Product_Volume.<cfif this.UOM EQ 2>Volume_LB<cfelse>Volume_CS</cfif> AS FLOAT) Volume,
							Program_Product_Volume.BSA_Foodservice_Items_Master_ID,
							isnull(Volume_Cap,0) AS Volume_Cap,
							Is_Group,
							Volume_LB as Group_LB,
							Volume_CS as Group_CS
				FROM		Program_Product_Volume
				WHERE
						Program_Product_Volume.Deleted = 0
						AND
						Program_Product_Volume.Program_ID = #this.Program_ID# AND len(Volume_LB) > 0
			</CFQUERY>

		</CFIF>

	</cfsilent>

	</cffunction>

  <!---------------------------------------------------------------------------
    This function replaces the function View_Program_Product_List and is called
    from contract_volume.cfm - Anand Rao/21-Jul-09
  ---------------------------------------------------------------------------->
  <cffunction name="fnProgramVolumeResult" output="true" hint="Show_Product_List">
   	<cfargument name="programID" type="numeric" required="false" default="0">
	<!--- Create the output in Itext --->
	<cfargument name="Itext" type="numeric" required="false" default="0">
	<!--- "We need to pass "document" for "Itext" to work --->
	<cfargument name="document" type="any" required="false">
	<cfargument name="bPreDefinedPageBreaks" type="boolean" required="false">
	<cfargument name="bidExcludeLostItems" required="false" default="0">
	<cfargument name="bShowVolumeSummary" required="false" default="3">

	<cfset bShowProgramVolume = 0>
	<cfset bShowAnnualVolume = 0>

	<!--- BOTH - PROGRAM VOLUME AND ANNUAL VOLUME --->
	<cfif arguments.bShowVolumeSummary eq 3>
		<cfset bShowProgramVolume = 1>
		<cfset bShowAnnualVolume = 1>
	<!--- ANNUAL VOLUME --->
	<cfelseif arguments.bShowVolumeSummary eq 2>
		<cfset bShowProgramVolume = 0>
		<cfset bShowAnnualVolume = 1>
	<!--- PROGRAM VOLUME--->
	<cfelseif arguments.bShowVolumeSummary eq 1>
		<cfset bShowProgramVolume = 1>
		<cfset bShowAnnualVolume = 0>
	</cfif>

		<cfsilent>
  		<cfset Volume_Col_Min_Width = 80 />
        <CFQUERY NAME="GetVolumeInfo" DATASOURCE="#application.datasource#">
  				SELECT		Program_Product_Volume.BSA_Foodservice_Items_Master_ID,
                    Program_Product_Volume.Volume_LB,
                    Program_Product_Volume.Volume_CS,
                    -- Program_Product_Volume.Program_Product_Volume_ID,
                    -- Program_Product_Volume.Volume_UOT_ID,
                    -- Program_Product_Volume.Volume,
                    -- Program_Product_Volume.Volume_Cap,
                    -- Program_Product_Volume.Volume_Cap_UOM,
                    -- Program_Product_Volume.Volume_Multiplier,
                    -- Program_Product_Volume.Is_Group,
                    -- Program_Product_Volume.Dynamic_Static_Groups,
                    -- Program_Product_Volume.Created_Date,
                    -- Program_Product_Volume.Updated_Date,
                    -- Program_Product_Volume.Net_Dollar,
                    -- Program_Product_Volume.Original_Net_Dollar,
                    -- Program_Product_Volume.Original_Volume_LB,
                    -- Program_Product_Volume.Original_Volume_CS,
                    BSA_Foodservice_Items_Master.item,
                    BSA_Foodservice_Items_Master.description,
                    BSA_Foodservice_Items_Master.Net_Weight
  				FROM		Program_Product_Volume
          INNER JOIN BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Program_Product_Volume.BSA_Foodservice_Items_Master_ID
  				WHERE
  						Program_Product_Volume.Deleted = 0
  					  AND
  						Program_Product_Volume.Program_ID = #this.Program_ID# AND len(Program_Product_Volume.Volume_LB) > 0
						AND Program_Product_Volume.Is_Group = 0
						AND EXISTS ( SELECT 1
			                     FROM CONTRACT_PRODUCTS cp
			                    WHERE cp.Contract_Main_Id = PROGRAM_PRODUCT_VOLUME.Program_Id
			                          AND cp.Deleted = 0
			                          AND cp.bsa_FoodService_Items_Master_Id = PROGRAM_PRODUCT_VOLUME.bsa_FoodService_Items_Master_Id )
          ORDER BY BSA_Foodservice_Items_Master.item
  			</CFQUERY>

	<CFIF #arguments.bidExcludeLostItems# EQ 1>
		<CFQUERY NAME="getBidLostItems" DATASOURCE="#application.datasource#">
			SELECT  distinct   PROGRAM_PRODUCT_BID_INFO.PRODUCT_ID
		    	FROM	PROGRAM_BID_REQUEST
			INNER JOIN PROGRAM_PRODUCT_BID_INFO
			ON		PROGRAM_PRODUCT_BID_INFO.Program_ID = PROGRAM_BID_REQUEST.Program_ID
			AND		PROGRAM_PRODUCT_BID_INFO.WON =0
			AND		PROGRAM_PRODUCT_BID_INFO.DELETED = 0
			WHERE	PROGRAM_BID_REQUEST.PROGRAM_ID = '#this.Program_ID#'
			AND		PROGRAM_BID_REQUEST.BID_REQUEST_STATUS_ID != 1
			AND		PROGRAM_BID_REQUEST.Deleted = 0
		</CFQUERY>
		<cfset bidLostItems = ValueList(getBidLostItems.PRODUCT_ID,",")>
	</CFIF>
  		  <cfset prodLen = GetVolumeInfo.RecordCount>
  		  <cfif prodLen EQ 0>
  			  <cfreturn>
  		  </CFIF>

  		<cfset programManager = CreateObject("component", "components.programs.ProgramManager") />
  		<cfset programDetails = CreateObject("component", "mvc.Models.Program.Volume.VolumeApplicator") />
      		<cfset qryProgramDetails = programDetails.getProgramDetails(this.Program_ID,request.AccessStructure.User_ID) />
		</cfsilent>

		<!--- If the requested out out is in Itext --->
		<cfif arguments.Itext eq 1>

		<!--- In the "inc_all_code_libraries.cfm", we are opening a document to create a pdf file. "DoNotIncludeThis" skips
		      a few lines of code on that file.
		--->
		<cfset DoNotIncludeThis = 1>
		<cfinclude template="/common_files/contracts/Letters/doc_modules/inc_all_code_libraries.cfm">

		<!--- If Program volume and Annual volume options are ON, add columns for both.
		Note: Both "Program volume" and "Annual volume" have 2 columns each.
		--->
		<cfif bShowProgramVolume eq 1 AND bShowAnnualVolume eq 1>
			<cfset colNum = 6>
			<cfset colNumHeader = 4>
			<cfset percentWidth = "19,33,12,12,12,12">
		<!--- Either "Program volume" or "Annual volume" option is ON --->
		<cfelse>
			<cfset colNum = 4>
			<cfset colNumHeader = 2>
			<cfset percentWidth = "30,46,12,12">
		</cfif>

		<!--- Initialize the table --->
		<cfset tableVolume = PdfPTable.init( javacast("int",#colNum#) )>
		<cfset tableVolume.setWidthPercentage(100)>

		<!--- Set the length of the array as big as the number of columns in the table --->
		<cfset jArr = arrObj.newInstance(jClass, #colNum#)>

		<!--- The first index of the array in JAVA starts with 0. Here different indexes are being assigned a value.  These values
		  will be used as the width of the columns in the table.
		--->
		<cfset elementPosition = -1>
		<cfloop list="#percentWidth#" index="i">
			<cfset elementPosition = elementPosition + 1>
			<cfset arrObj.setInt(jArr, #elementPosition#, #i#)>
		</cfloop>

		<!--- Set the width of the Volume table --->
		<cfset tableVolume.setWidths(jArr)>

		<!--- If template setting "BA Pre-defined page breaks" is ON, Go to a new page --->
		<cfif arguments.bPreDefinedPageBreaks>
			<cfset document.newPage()>
		<cfelse>
			<cfset document.add(chunk.init(chr(13) & chr(10)))>
		</cfif>

		<!--- Section Heading --->
		<cfset arguments.document.add(chunk.init("Program Volume", GothicBold_Font_Bold_Brown_Nine))>

		<cfset Blank_Cells = PdfPCell.init(phrase.init(""))>
		<cfset Blank_Cells.setColspan( javacast("int", colNumHeader) )>
		<cfset Blank_Cells.setBorder(Rectangle.NO_BORDER)>
		<cfset tableVolume.addCell(Blank_Cells)>

		<cfset Span_Date_Heading = PdfPCell.init(phrase.init("#qryProgramDetails.Contract_Start_Date# - #qryProgramDetails.Contract_End_Date# (#qryProgramDetails.Contract_Span#)", GothicBold_Font_Bold_Black_Eight))>
		<cfset Span_Date_Heading.setColspan( javacast("int", 2) )>
		<cfset Span_Date_Heading.setBorder(Rectangle.NO_BORDER)>
		<cfset tableVolume.setHorizontalAlignment(PdfPCell.ALIGN_CENTER)>
		<cfset tableVolume.addCell(Span_Date_Heading)>

		<!--- row ends here --->

		<cfset Item_Number_Heading = PdfPCell.init(phrase.init("Item No", GothicBold_Font_Bold_Black_Eight))>
		<cfset Item_Number_Heading.setColspan( javacast("int", 1) )>
		<cfset Item_Number_Heading.setBorder(Rectangle.NO_BORDER)>
		<cfset tableVolume.addCell(Item_Number_Heading)>

		<cfset Item_Description_Heading = PdfPCell.init(phrase.init("Description", GothicBold_Font_Bold_Black_Eight))>
		<cfset Item_Description_Heading.setColspan( javacast("int", 1) )>
		<cfset Item_Description_Heading.setBorder(Rectangle.NO_BORDER)>
		<cfset tableVolume.addCell(Item_Description_Heading)>

		<cfif bShowAnnualVolume eq 1>
			<cfset Annual_Volume_Heading = PdfPCell.init(phrase.init("Annual Volume", GothicBold_Font_Bold_Black_Eight))>
			<cfset Annual_Volume_Heading.setColspan( javacast("int", 2) )>
			<cfset Annual_Volume_Heading.setBorder(Rectangle.NO_BORDER)>
			<cfset Annual_Volume_Heading.setHorizontalAlignment(ELEMENT.ALIGN_CENTER)>
			<cfset tableVolume.addCell(Annual_Volume_Heading)>
		</cfif>

		<cfif bShowProgramVolume eq 1>
			<cfset Program_Volume_Heading = PdfPCell.init(phrase.init("#this.defaultUOT.getDesc()# Volume", GothicBold_Font_Bold_Black_Eight))>
			<cfset Program_Volume_Heading.setColspan( javacast("int", 2) )>
			<cfset Program_Volume_Heading.setBorder(Rectangle.NO_BORDER)>
			<cfset Program_Volume_Heading.setHorizontalAlignment(ELEMENT.ALIGN_CENTER)>
			<cfset tableVolume.addCell(Program_Volume_Heading)>
		</cfif>

		<cfset Blank_Cells = PdfPCell.init(phrase.init(""))>
		<cfset Blank_Cells.setColspan( javacast("int", 2) )>
		<cfset Blank_Cells.setBorder(Rectangle.NO_BORDER)>
		<cfset tableVolume.addCell(Blank_Cells)>

		<cfif bShowAnnualVolume eq 1>
			<cfset Annual_Volume_Case_Heading = PdfPCell.init(phrase.init("#Application.UOMCaseSingular#", GothicBold_Font_Bold_Black_Eight))>
			<cfset Annual_Volume_Case_Heading.setColspan( javacast("int", 1) )>
			<cfset Annual_Volume_Case_Heading.setBorder(Rectangle.NO_BORDER)>
			<cfset Annual_Volume_Case_Heading.setHorizontalAlignment(ELEMENT.ALIGN_RIGHT)>
			<cfset tableVolume.addCell(Annual_Volume_Case_Heading)>

			<cfset Annual_Volume_Pound_Heading = PdfPCell.init(phrase.init("#Application.UOMPoundSingular#", GothicBold_Font_Bold_Black_Eight))>
			<cfset Annual_Volume_Pound_Heading.setColspan( javacast("int", 1) )>
			<cfset Annual_Volume_Pound_Heading.setBorder(Rectangle.NO_BORDER)>
			<cfset Annual_Volume_Pound_Heading.setHorizontalAlignment(ELEMENT.ALIGN_RIGHT)>
			<cfset tableVolume.addCell(Annual_Volume_Pound_Heading)>
		</cfif>

		<cfif bShowProgramVolume eq 1>
			<cfset Program_Volume_Case_Heading = PdfPCell.init(phrase.init("#Application.UOMCaseSingular#", GothicBold_Font_Bold_Black_Eight))>
			<cfset Program_Volume_Case_Heading.setColspan( javacast("int", 1) )>
			<cfset Program_Volume_Case_Heading.setBorder(Rectangle.NO_BORDER)>
			<cfset Program_Volume_Case_Heading.setHorizontalAlignment(ELEMENT.ALIGN_RIGHT)>
			<cfset tableVolume.addCell(Program_Volume_Case_Heading)>

			<cfset Program_Volume_Pound_Heading = PdfPCell.init(phrase.init("#Application.UOMPoundSingular#", GothicBold_Font_Bold_Black_Eight))>
			<cfset Program_Volume_Pound_Heading.setColspan( javacast("int", 1) )>
			<cfset Program_Volume_Pound_Heading.setBorder(Rectangle.NO_BORDER)>
			<cfset Program_Volume_Pound_Heading.setHorizontalAlignment(ELEMENT.ALIGN_RIGHT)>
			<cfset tableVolume.addCell(Program_Volume_Pound_Heading)>
		</cfif>

		<cfelse>
		<!--- start the output in HTML --->
		<STYLE>
			TABLE.VOlumeMaintable TD
			{
				border:none;
				font-size : 10px;
			}
			<!---
			TABLE.VOlumeMaintable
			{
				page-break-before: always;
			}
			--->
		</STYLE>
		<TABLE CLASS="VOlumeMaintable" border="0" cellspacing="1" cellpadding="2" WIDTH="100%" BGCOLOR="##ffce84">
		<CAPTION align="left"><B><FONT SIZE="2" COLOR="Navy">Program Volume</FONT></B><HR COLOR="Navy"></CAPTION>
		<THEAD>

		<tr valign="top" bgcolor="White">
      <td colspan="2"></td>
      <td colspan="2"></td>
  		<td colspan="2" ID="header" ALIGN="center" STYLE="border:none;">
		  	<B>#qryProgramDetails.Contract_Start_Date# - #qryProgramDetails.Contract_End_Date# (#qryProgramDetails.Contract_Span#)</B>
      </td>
		</TR>

		<tr bgcolor="##ffce84" valign="bottom">
			<td rowspan="2" align="left" ID="header">
        <B>
				  Item ##
				</B>
				</td>
			<td rowspan="2" align="left" ID="header">
			<B>Description</B>
			</td>
			<td colspan="2" STYLE="border-bottom:2px solid black;" align="center" ID="header"><B>Annual Volume</B></td>
			<td colspan="2" STYLE="border-bottom:2px solid black;" align="center" ID="header"><B>#this.defaultUOT.getDesc()# Volume</B></td>
  	</TR>
		<TR ID="header" BGCOLOR="##ffce84" VALIGN="bottom">
      <td ALIGN="right" ID="header"><B>#Application.UOMCaseSingular#</B></td>
			<td ALIGN="right" ID="header"><B>#Application.UOMPoundSingular#</B></td>
      <td ALIGN="right" ID="header"><B>#Application.UOMCaseSingular#</B></td>
			<td ALIGN="right" ID="header"><B>#Application.UOMPoundSingular#</B></td>
		</TR>
		</THEAD>
	</cfif>

    <cfset iCount=0 />
    <cfset SumAnnualvolumeCS = 0 />
    <cfset SumAnnualvolumeLB = 0 />
    <cfset SumUOTVolumeCS = 0 />
    <cfset SumUOTVolumeLB = 0 />
    <cfset SumExcludeLostUOTVolumeCS = 0 />
    <cfset SumExcludeLostUOTVolumeLB = 0 />
    <cfset SumExcludeLostAnnualvolumeCS = 0 />
    <cfset SumExcludeLostAnnualvolumeLB = 0 />
    <cfloop query="GetVolumeInfo">
      <cfset AnnualvolumeCS = objVolumeApplicator.RoundVolume((Volume_CS/7)*365) />
      <cfset UOTVolumeCS = objVolumeApplicator.RoundVolume((Volume_CS/7) * qryProgramDetails.Contract_Span) />
      <cfset SumAnnualvolumeCS += AnnualvolumeCS />
      <cfset SumUOTVolumeCS += UOTVolumeCS />
      <cfset AnnualvolumeLB    = objVolumeApplicator.RoundVolume((Volume_LB/7)*365) />
      <cfset UOTVolumeLB       = objVolumeApplicator.RoundVolume((Volume_LB/7) * qryProgramDetails.Contract_Span) />
      <cfset SumAnnualvolumeLB += AnnualvolumeLB />
      <cfset SumUOTVolumeLB    += UOTVolumeLB />
      <cfset bidLostItemsAsterisk = "" />
      <cfif  #arguments.bidExcludeLostItems# EQ 1 and  getBidLostItems.recordcount GT 0>
      	<cfif listFindNoCase(#bidLostItems#, #GetVolumeInfo.BSA_Foodservice_Items_Master_ID#) GT 0>
		<cfset bidLostItemsAsterisk = " &nbsp;&nbsp; <font color=red> *</font>" />
	<cfelse>
	      <cfset SumExcludeLostUOTVolumeCS = SumExcludeLostUOTVolumeCS+UOTVolumeCS />
	      <cfset SumExcludeLostUOTVolumeLB = SumExcludeLostUOTVolumeLB+UOTVolumeLB />
	      <cfset SumExcludeLostAnnualvolumeCS = SumExcludeLostAnnualvolumeCS+AnnualvolumeCS />
	      <cfset SumExcludeLostAnnualvolumeLB = SumExcludeLostAnnualvolumeLB+AnnualvolumeLB />
      	</cfif>
      </cfif>

      <cfset iCount += 1 />

	  <!--- If the requested output is in Itext --->
	  <cfif arguments.Itext eq 1>

		<!---- Volume Data content --->
		<cfset Item_Number = PdfPCell.init(phrase.init("#GetVolumeInfo.ITEM#", GothicNormal_font_Bold_Black_Eight))>
		<cfset Item_Number.setColspan( javacast("int", 1) )>
		<cfset Item_Number.setBorder(Rectangle.NO_BORDER)>

		<!---Alternate coloring --->
		<cfif GetVolumeInfo.currentRow MOD 2 eq 1>
			<cfset Item_Number.setBackgroundColor(textColorWhite)>
		<cfelse>
			<cfset Item_Number.setBackgroundColor(textColorLightGray)>
		</cfif>

		<cfset tableVolume.addCell(Item_Number)>

		<cfset Item_Description = PdfPCell.init(phrase.init("#GetVolumeInfo.Description#", GothicNormal_font_Bold_Black_Eight))>
		<cfset Item_Description.setColspan( javacast("int", 1) )>
		<cfset Item_Description.setBorder(Rectangle.NO_BORDER)>

		<!---Alternate coloring --->
		<cfif GetVolumeInfo.currentRow MOD 2 eq 1>
			<cfset Item_Description.setBackgroundColor(textColorWhite)>
		<cfelse>
			<cfset Item_Description.setBackgroundColor(textColorLightGray)>
		</cfif>

		<cfset tableVolume.addCell(Item_Description)>

		<cfif bShowAnnualVolume eq 1>
			<cfset Annual_Volume_Case = PdfPCell.init(phrase.init("#objVolumeApplicator.FormatVolume(AnnualvolumeCS)#", GothicNormal_font_Bold_Black_Eight))>
			<cfset Annual_Volume_Case.setColspan( javacast("int", 1) )>
			<cfset Annual_Volume_Case.setBorder(Rectangle.NO_BORDER)>
			<cfset Annual_Volume_Case.setHorizontalAlignment(ELEMENT.ALIGN_RIGHT)>

			<!---Alternate coloring --->
			<cfif GetVolumeInfo.currentRow MOD 2 eq 1>
				<cfset Annual_Volume_Case.setBackgroundColor(textColorWhite)>
			<cfelse>
				<cfset Annual_Volume_Case.setBackgroundColor(textColorLightGray)>
			</cfif>

			<cfset tableVolume.addCell(Annual_Volume_Case)>

			<cfset Annual_Volume_Pound = PdfPCell.init(phrase.init("#objVolumeApplicator.FormatVolume(AnnualvolumeLB)#", GothicNormal_font_Bold_Black_Eight))>
			<cfset Annual_Volume_Pound.setColspan( javacast("int", 1) )>
			<cfset Annual_Volume_Pound.setBorder(Rectangle.NO_BORDER)>
			<cfset Annual_Volume_Pound.setHorizontalAlignment(ELEMENT.ALIGN_RIGHT)>

			<!---Alternate coloring --->
			<cfif GetVolumeInfo.currentRow MOD 2 eq 1>
				<cfset Annual_Volume_Pound.setBackgroundColor(textColorWhite)>
			<cfelse>
				<cfset Annual_Volume_Pound.setBackgroundColor(textColorLightGray)>
			</cfif>

			<cfset tableVolume.addCell(Annual_Volume_Pound)>
		</cfif>

		<cfif bShowProgramVolume eq 1>
			<cfset Program_Volume_Case = PdfPCell.init(phrase.init("#objVolumeApplicator.FormatVolume(UOTVolumeCS)#", GothicNormal_font_Bold_Black_Eight))>
			<cfset Program_Volume_Case.setColspan( javacast("int", 1) )>
			<cfset Program_Volume_Case.setBorder(Rectangle.NO_BORDER)>
			<cfset Program_Volume_Case.setHorizontalAlignment(ELEMENT.ALIGN_RIGHT)>

			<!---Alternate coloring --->
			<cfif GetVolumeInfo.currentRow MOD 2 eq 1>
				<cfset Program_Volume_Case.setBackgroundColor(textColorWhite)>
			<cfelse>
				<cfset Program_Volume_Case.setBackgroundColor(textColorLightGray)>
			</cfif>

			<cfset tableVolume.addCell(Program_Volume_Case)>

			<cfset Program_Volume_Pound = PdfPCell.init(phrase.init("#objVolumeApplicator.FormatVolume(UOTVolumeLB)#", GothicNormal_font_Bold_Black_Eight))>
			<cfset Program_Volume_Pound.setColspan( javacast("int", 1) )>
			<cfset Program_Volume_Pound.setBorder(Rectangle.NO_BORDER)>
			<cfset Program_Volume_Pound.setHorizontalAlignment(ELEMENT.ALIGN_RIGHT)>

			<!---Alternate coloring --->
			<cfif GetVolumeInfo.currentRow MOD 2 eq 1>
				<cfset Program_Volume_Pound.setBackgroundColor(textColorWhite)>
			<cfelse>
				<cfset Program_Volume_Pound.setBackgroundColor(textColorLightGray)>
			</cfif>

			<!--- Add the table to the pdf document --->
			<cfset tableVolume.addCell(Program_Volume_Pound)>
		</cfif>

		<cfelse>
		<!--- If the requested output is in HTML --->
    	<tr VALIGN="middle"  <CFIF iCount mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
				<td NOWRAP ID="TD_Item">
          <div  style="HEIGHT:20;vertical-align:middle;padding-top:3px;padding-bottom:3px;">
					  #GetVolumeInfo.ITEM#
          </div>
			  </td>
				<td id="TD_Description" >
          #GetVolumeInfo.Description#  #bidLostItemsAsterisk#
        </td>
        <td id="TD_Annual_CS" align="right">
          <div CLASS="DIV_HIDE_OVERFLOW" STYLE="WIDTH:#Volume_Col_Min_Width#;">
            #objVolumeApplicator.FormatVolume(AnnualvolumeCS)#
          </DIV>
        </td>
        <td id="TD_Annual_LB" align="right">
          <div CLASS="DIV_HIDE_OVERFLOW" STYLE="WIDTH:#Volume_Col_Min_Width#;">
            #objVolumeApplicator.FormatVolume(AnnualvolumeLB)#
          </DIV>
        </td>
        <td id="TD_Program_CS" align="right">
          <div CLASS="DIV_HIDE_OVERFLOW" STYLE="WIDTH:#Volume_Col_Min_Width#;">
            #objVolumeApplicator.FormatVolume(UOTVolumeCS)#
          </div>
        </td>
        <td id="TD_Program_LB" align="right">
          <DIV CLASS="DIV_HIDE_OVERFLOW" STYLE="WIDTH:#Volume_Col_Min_Width#;">
            #objVolumeApplicator.FormatVolume(UOTVolumeLB)#
          </DIV>
        </td>
      </tr>
	</cfif>
    </cfloop>

	<!--- If the requested output is in Itext --->
	<cfif arguments.Itext eq 1>

		<cfset BlankRow = PdfPCell.init(phrase.init(""))>
		<cfset BlankRow.setColspan( javacast("int", #colNum#) )>
		<cfset BlankRow.setBorder(Rectangle.NO_BORDER)>
		<!--- Add 2 blank rows --->
		<cfset tableVolume.addCell(BlankRow)>
		<cfset tableVolume.addCell(BlankRow)>


		<cfset Blank_Cells = PdfPCell.init(phrase.init(""))>
		<cfset Blank_Cells.setColspan( javacast("int", 1) )>
		<cfset Blank_Cells.setBorder(Rectangle.NO_BORDER)>
		<cfset tableVolume.addCell(Blank_Cells)>

		<!--- Volume Total --->
		<cfset Total_Volume_Heading = PdfPCell.init(phrase.init("Total volume:", GothicBold_Font_Bold_Black_Eight))>
		<cfset Total_Volume_Heading.setColspan( javacast("int", 1) )>
		<cfset Total_Volume_Heading.setBorder(Rectangle.NO_BORDER)>
		<cfset Total_Volume_Heading.setHorizontalAlignment(ELEMENT.ALIGN_RIGHT)>
		<cfset tableVolume.addCell(Total_Volume_Heading)>

		<cfif bShowAnnualVolume eq 1>
			<cfset Annual_Volume_Case_Total = PdfPCell.init(phrase.init("#objVolumeApplicator.FormatVolume(SumAnnualvolumeCS)#", GothicNormal_font_Bold_Black_Eight))>
			<cfset Annual_Volume_Case_Total.setColspan( javacast("int", 1) )>
			<cfset Annual_Volume_Case_Total.setBorder(Rectangle.NO_BORDER)>
			<cfset Annual_Volume_Case_Total.setHorizontalAlignment(ELEMENT.ALIGN_RIGHT)>
			<cfset tableVolume.addCell(Annual_Volume_Case_Total)>

			<cfset Annual_Volume_Pound_Total = PdfPCell.init(phrase.init("#objVolumeApplicator.FormatVolume(SumAnnualvolumeLB)#", GothicNormal_font_Bold_Black_Eight))>
			<cfset Annual_Volume_Pound_Total.setColspan( javacast("int", 1) )>
			<cfset Annual_Volume_Pound_Total.setBorder(Rectangle.NO_BORDER)>
			<cfset Annual_Volume_Pound_Total.setHorizontalAlignment(ELEMENT.ALIGN_RIGHT)>
			<cfset tableVolume.addCell(Annual_Volume_Pound_Total)>
		</cfif>

		<cfif bShowProgramVolume eq 1>
			<cfset Program_Volume_Case_Total = PdfPCell.init(phrase.init("#objVolumeApplicator.FormatVolume(SumUOTVolumeCS)#", GothicNormal_font_Bold_Black_Eight))>
			<cfset Program_Volume_Case_Total.setColspan( javacast("int", 1) )>
			<cfset Program_Volume_Case_Total.setBorder(Rectangle.NO_BORDER)>
			<cfset Program_Volume_Case_Total.setHorizontalAlignment(ELEMENT.ALIGN_RIGHT)>
			<cfset tableVolume.addCell(Program_Volume_Case_Total)>

			<cfset Program_Volume_Pound_Total = PdfPCell.init(phrase.init("#objVolumeApplicator.FormatVolume(SumUOTVolumeLB)#", GothicNormal_font_Bold_Black_Eight))>
			<cfset Program_Volume_Pound_Total.setColspan( javacast("int", 1) )>
			<cfset Program_Volume_Pound_Total.setBorder(Rectangle.NO_BORDER)>
			<cfset Program_Volume_Pound_Total.setHorizontalAlignment(ELEMENT.ALIGN_RIGHT)>
			<cfset tableVolume.addCell(Program_Volume_Pound_Total)>
		</cfif>

	<cfelse>
	<!--- If the requested output is in HTML --->
    <tr bgcolor="##FFFFFF" >
      <td colspan="2" align="right" ID="header"><strong>Total Volume:</strong></td>
      <td ID="header" align="right"><strong>#objVolumeApplicator.FormatVolume(SumAnnualvolumeCS)#</strong></td>
      <td ID="header" align="right"><strong>#objVolumeApplicator.FormatVolume(SumAnnualvolumeLB)#</strong></td>
      <td ID="header" align="right"><strong>#objVolumeApplicator.FormatVolume(SumUOTVolumeCS)#</strong></td>
      <td ID="header" align="right"><strong>#objVolumeApplicator.FormatVolume(SumUOTVolumeLB)#</strong></td>
    </tr>
    <cfif  #arguments.bidExcludeLostItems# EQ 1 and  getBidLostItems.recordcount GT 0>
	<tr bgcolor="##FFFFFF" >
		<td colspan="2" align="right" ID="header"><strong>Total Volume Excluding Lost Items:</strong></td>
		<td ID="header" align="right"><strong>#objVolumeApplicator.FormatVolume(SumExcludeLostAnnualvolumeCS)#</strong></td>
		<td ID="header" align="right"><strong>#objVolumeApplicator.FormatVolume(SumExcludeLostAnnualvolumeLB)#</strong></td>
		<td ID="header" align="right"><strong>#objVolumeApplicator.FormatVolume(SumExcludeLostUOTVolumeCS)#</strong></td>
		<td ID="header" align="right"><strong>#objVolumeApplicator.FormatVolume(SumExcludeLostUOTVolumeLB)#</strong></td>
	</tr>
    </cfif>
  </table>
	<cfif  #arguments.bidExcludeLostItems# EQ 1 and  getBidLostItems.recordcount GT 0>
		<div style="text-align:right;"> <font color=red>* </font>Lost Item</div>
	</cfif>
  </cfif>

	<!--- If the request is in Itext, Add the table to the pdf document --->
	<cfif arguments.Itext eq 1>
   		<cfset document.add(tableVolume)>
	</cfif>

   	</cffunction>





	<cffunction name="View_Program_Product_List" output="true" hint="Show_Product_List">
		<cfargument name="byGroups" type="string" required="false" default="0">
		<cfargument name="useAllowList" type="numeric" required="false" default="0">
		<cfargument name="allowList" type="string" required="false" default="">
		<cfargument name="ShowItemsOnly" type="numeric" required="false" default="0">

		<cfsilent>
		<cfset this.loadVolumInfoToPacket(extraProductList="", byGroups=arguments.byGroups, useAllowList=arguments.useAllowList, allowList=arguments.allowList, ShowItemsOnly=arguments.ShowItemsOnly)>
		<CFSET this.Load_Forecast_Summary()>

		<cfset prodArray = this.Volume_Packet_Builder.volumePacket.products>

		<cfset prodLen = ArrayLen(prodArray)>
		<CFIF prodLen EQ 0>
			<CFRETURN>
		</CFIF>

		<cfset showAnnualVolume = 1>
		<cfif this.Volume_Packet_Builder.volumePacket.showVolumeCap>
			<cfset showAnnualVolume = 0>
		</cfif>

		<cfset programHasGroups = 0 >

		<cfset programManager = CreateObject("component", "components.programs.ProgramManager") />

		<!---if the program has groups then check to make sure we have a distributor--->
		<cfif programManager.programHasGroups(this.Program_ID) eq 1>
			<cfset programHasGroups = 1 />
		</cfif>
		</cfsilent>
		<SCRIPT LANGUAGE="JavaScript">
		function Show_Forecast_Details(Product_ID)
		{
			event.returnValue = false;
			NewWindow('/Common_Files/Volume/Volume_Forcast_Detail.cfm?PID=' + Product_ID + '&packetId=#this.Packet_ID#&action=forecastDetail', 'Forecast_Detail','750','600','Yes', 'Yes')
		}
		</SCRIPT>
		<STYLE>
			TABLE.VOlumeMaintable TD
			{
				border:none;
				font-size : 10px;
			}
			<!---
			TABLE.VOlumeMaintable
			{
				page-break-before: always;
			}
			--->
		</STYLE>
		<TABLE CLASS="VOlumeMaintable" border="0" cellspacing="1" cellpadding="2" WIDTH="100%" BGCOLOR="##ffce84">
		<CAPTION align="left"><B><FONT SIZE="2" COLOR="Navy">Program Volume</FONT></B><HR COLOR="Navy"></CAPTION>
		<THEAD>
		<cfif NOT this.defaultUOT.getMultiplier() OR this.Previous_Forecast>
		<TR VALIGN="top" BGCOLOR="White">
			<td colspan="2"></td>
			<CFIF this.Previous_Forecast>
			<td colspan="2" ID="header" ALIGN="center" STYLE="border:none;">
			<B>#DateFormat(this.Forecast_From_Date, "mm/dd/yyyy")# - #DateFormat(this.Forecast_To_Date, "mm/dd/yyyy")# (#this.Forecast_Span#)</B>
			</td>
			</CFIF>
			<cfif showAnnualVolume>
			<td colspan="2"></td>
			</cfif>
			<td colspan="10" ID="header" ALIGN="center" STYLE="border:none;">
			<cfif NOT this.defaultUOT.getMultiplier()>
			<B>#DateFormat(this.Contract_Start_Date, "mm/dd/yyyy")# - #DateFormat(this.Contract_End_Date, "mm/dd/yyyy")# (#this.Contract_Span#)</B>
			</cfif>
			</td>
		</TR>
		</cfif>
		<TR BGCOLOR="##ffce84" VALIGN="bottom">
			<td ROWSPAN="2" align="left" ID="header"><B>
				Item ##
				<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>
				<B>/</B><BR>
				UPC
				</cfif></cfif></B>
				</td>
			<td ROWSPAN="2" align="left" ID="header">
			<B>Description</B>
			</td>
			<CFIF this.Previous_Forecast>
			<td colspan="2" STYLE="border-bottom:2px solid black;" align="center" ID="header"><B>Historical Volume</B></td>
			</CFIF>
			<cfif showAnnualVolume>
			<td colspan="2" STYLE="border-bottom:2px solid black;" align="center" ID="header"><B>Annual Volume</B></td>
			</cfif>
			<td colspan="2" STYLE="border-bottom:2px solid black;" align="center" ID="header"><B>#this.defaultUOT.getDesc()# Volume</B></td>
			<cfif this.Volume_Packet_Builder.volumePacket.showVolumeCap>
			<td colspan="1" STYLE="border-bottom:2px solid black;" align="center" ID="header"><B>#this.defaultUOT.getDesc()# Cap</B></td>
			</cfif>
		</TR>
		<TR ID="header" BGCOLOR="##ffce84" VALIGN="bottom">
			<CFIF this.Previous_Forecast>
				<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 1>
					<td align="center" ID="header" colspan =2><B>#Application.UOMCaseSingular#</B></td>
				<cfelseif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 2>
					<td align="center" ID="header" colspan =2><B>#Application.UOMPoundSingular#</B></td>
				<cfelse>
					<td ALIGN="right" ID="header"><B>#Application.UOMCaseSingular#</B></td>
					<td ALIGN="right" ID="header"><B>#Application.UOMPoundSingular#</B></td>
				</cfif>
			</CFIF>
			<cfif showAnnualVolume>
				<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 1>
					<td align="center" ID="header" colspan =2><B>#Application.UOMCaseSingular#</B></td>
				<cfelseif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 2>
					<td align="center" ID="header" colspan =2><B>#Application.UOMPoundSingular#</B></td>
				<cfelse>
					<td ALIGN="right" ID="header"><B>#Application.UOMCaseSingular#</B></td>
					<td ALIGN="right" ID="header"><B>#Application.UOMPoundSingular#</B></td>
				</cfif>
			</cfif>
			<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 1>
				<td align="center" ID="header" colspan =2><B>#Application.UOMCaseSingular#</B></td>
			<cfelseif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 2>
				<td align="center" ID="header" colspan =2><B>#Application.UOMPoundSingular#</B></td>
			<cfelse>
				<td ALIGN="right" ID="header"><B>#Application.UOMCaseSingular#</B></td>
				<td ALIGN="right" ID="header"><B>#Application.UOMPoundSingular#</B></td>
			</cfif>
			<cfif this.Volume_Packet_Builder.volumePacket.showVolumeCap>
			<td ALIGN="right" ID="header"></td>
			</cfif>
		</TR>
		</THEAD>

		<cfsilent>
		<CFSET Forecast_Total_CS = 0>
		<CFSET Forecast_Total_LB = 0>
		<CFSET Annual_Total_CS = 0>
		<CFSET Annual_Total_LB = 0>
		<CFSET Program_Total_CS = 0>
		<CFSET Program_Total_LB = 0>
		<CFSET Volume_Col_Min_Width = 80>

		<cfset anyGroupLevel_1 = this.Volume_Packet_Builder.volumePacket.allProductsSelected />
		<cfset p = 1 />
		<cfset n = 1 />

		</cfsilent>

		<!---handle the loop differently for groups--->
		<cfif programHasGroups>

			<cfset count = 1 />

			<cfloop index="i" from="1" to="#prodLen#">

				<cfsilent>
				<cfif i lt prodLen>
					<cfset n = i + 1 />
				</cfif>

				<cfif i gt 1>
					<cfset p = i - 1 />
				</cfif>

				<cfset BSA_Foodservice_Items_Master_ID 		= prodArray[i].productId>
				<cfset Net_Weight 							= prodArray[i].netWeight>
				<cfset Description 							= prodArray[i].description>
				<cfset Item		 							= prodArray[i].item>
				<cfset UPC		 							= prodArray[i].upc>
				<cfset productVolume 						= prodArray[i].productVolume>
				<cfset productGroupLevel 					= prodArray[i].productGroupLevel>
				<cfset forecastVolume 						= prodArray[i].forecastVolume>
				<cfset doneForecast							= prodArray[i].doneForecast>
				<cfset groupName							= prodArray[i].groupName>
				<cfset groupId								= prodArray[i].groupId>
				<cfset prevGroupId							= prodArray[p].groupId>
				<cfset nextGroupId							= prodArray[n].groupId>
				<!---verify if it's part of a group or not--->
				<cfif trim(prodArray[i].isPartOfGroup) neq "">
					<cfset isPartOfGroup = 1 >
				<cfelse>
					<cfset isPartOfGroup = 0 >
				</cfif>

				<cfif isPartOfGroup eq 1 and (groupId neq nextGroupId or i eq prodLen)>

					<cfset Description 							= prodArray[i].groupName>
					<cfset Item		 							= "Group Item">
					<cfset UPC		 							= "">

				</cfif>

				<CFSET FieldNameEnd = request.app_general_functions.replaceHyphen(BSA_Foodservice_Items_Master_ID)>
				<CFSET Input_CS_Name = "Product_Volume_#FieldNameEnd#_CS">
				<CFSET Input_LB_Name = "Product_Volume_#FieldNameEnd#_LB">

				<CFSET Forecast_Volume_CS = "Forecast_Volume_#FieldNameEnd#_CS">
				<CFSET Forecast_Volume_LB = "Forecast_Volume_#FieldNameEnd#_LB">

				<CFSET Err_PS_CS_Name = "error_Vol_#FieldNameEnd#_cs">
				<CFSET Err_PS_LB_Name = "error_Vol_#FieldNameEnd#_lb">

				</cfsilent>

				<cfif isPartOfGroup eq 0 or (groupId neq nextGroupId or i eq prodLen)>
					<TR VALIGN="top" <CFIF count mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> <CFIF this.Previous_Forecast AND NOT doneForecast> TITLE="This product is not part of the forecast"</CFIF>>
						<td NOWRAP ID="TD_Item">
							#ITEM#
							<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
								<cfif application.returned_customer_setting.upc_switch EQ 1>
									<BR>#UPC#
								</cfif>
							</cfif>
						</td>
						<td ID="TD_Description">#Description#</td>
				</cfif>

					<CFSILENT>
					<CFSET Annual_Volume_CS = 0>
					<CFSET Annual_Volume_LB = 0>
					<cfif isPartOfGroup eq 1 and groupId neq prevGroupId or i eq 1>

						<CFSET Annual_Volume_Group_CS = 0>
						<CFSET Annual_Volume_Group_LB = 0>
						<CFSET Forecast_Volume_Group_CS = 0>
						<CFSET Forecast_Volume_Group_LB = 0>
						<CFSET This_Volume_Group_CS = 0>
						<CFSET This_Volume_Group_LB = 0>

					</cfif>

					<CFIF this.Previous_Forecast>
						<CFIF this.UOM EQ 1>
							<CFSET Forecast_Volume_CS 	= forecastVolume>
							<CFSET Forecast_Volume_LB 	= objVolumeApplicator.ConvertToUOM(Forecast_Volume_CS, 2, Net_Weight)>
						<CFELSE>
							<CFSET Forecast_Volume_LB 	= forecastVolume>
							<CFSET Forecast_Volume_CS 	= objVolumeApplicator.ConvertToUOM(Forecast_Volume_LB, 1, Net_Weight)>
						</CFIF>
						<cfif isPartOfGroup eq 1 and IsNumeric(Forecast_Volume_Group_CS)>
							<CFSET Forecast_Volume_Group_CS = Forecast_Volume_Group_CS + Val(Forecast_Volume_CS)>
							<CFSET Forecast_Volume_Group_LB = Forecast_Volume_Group_LB + Val(Forecast_Volume_LB)>
						</cfif>
					<CFELSE>
						<CFSET Forecast_Volume_CS = 0>
						<CFSET Forecast_Volume_LB = 0>
					</CFIF>

					<CFIF this.UOM EQ 1><!---- program UOM is CS ---->

						<CFPARAM NAME="FORM.#Input_CS_Name#" 	DEFAULT="#productVolume#">

						<CFSET This_Volume_CS 					= Evaluate("FORM.#Input_CS_Name#")>
						<CFPARAM NAME="FORM.#Input_LB_Name#" 	DEFAULT="#objVolumeApplicator.ConvertToUOM(This_Volume_CS, 2, Net_Weight)#">
						<CFSET This_Volume_LB 					= Evaluate("FORM.#Input_LB_Name#")>

						<cfif isPartOfGroup eq 1>
							<CFSET This_Volume_Group_CS = This_Volume_Group_CS + This_Volume_CS>
							<CFSET This_Volume_Group_LB = This_Volume_Group_LB + This_Volume_LB>
						</cfif>

						<CFIF IsNumeric(This_Volume_CS)>
							<CFSET Annual_Volume_CS 			= ConvertToAnnualVolume(This_Volume_CS)>
							<CFSET Annual_Volume_LB 			= ConvertToAnnualVolume(This_Volume_LB)>
							<cfif isPartOfGroup eq 1>
								<CFSET Annual_Volume_Group_CS = Annual_Volume_Group_CS + Annual_Volume_CS>
								<CFSET Annual_Volume_Group_LB = Annual_Volume_Group_LB + Annual_Volume_LB>
							</cfif>
						</CFIF>

					<CFELSE><!---- program UOM is LB ---->

						<CFPARAM NAME="FORM.#Input_LB_Name#" 	DEFAULT="#productVolume#">

						<CFSET This_Volume_LB 					= Evaluate("FORM.#Input_LB_Name#")>
						<CFPARAM NAME="FORM.#Input_CS_Name#" 	DEFAULT="#objVolumeApplicator.ConvertToUOM(This_Volume_LB, 1, Net_Weight)#">
						<CFSET This_Volume_CS 					= Evaluate("FORM.#Input_CS_Name#")>
						<CFSET Annual_Volume_CS 				= ConvertToAnnualVolume(This_Volume_CS)>
						<CFSET Annual_Volume_LB 				= ConvertToAnnualVolume(This_Volume_LB)>

						<cfif isPartOfGroup eq 1 AND IsNumeric(This_Volume_Group_CS)>
							<cfif This_Volume_CS eq "">
								<cfset This_Volume_CS = 0 >
							</cfif>

							<cfif Annual_Volume_CS eq "">
								<cfset Annual_Volume_CS = 0 >
							</cfif>
							<CFSET This_Volume_Group_CS = This_Volume_Group_CS + This_Volume_CS>
							<CFSET This_Volume_Group_LB = This_Volume_Group_LB + This_Volume_LB>

							<CFSET Annual_Volume_Group_CS = Annual_Volume_Group_CS + Annual_Volume_CS>
							<CFSET Annual_Volume_Group_LB = Annual_Volume_Group_LB + Annual_Volume_LB>
						</cfif>

					</CFIF>
					<!------ Volume Cap ----->
					<CFSET Form_Name_Volume_Cap = "Volume_Cap_#FieldNameEnd#">
					<cfparam name="FORM.#Form_Name_Volume_Cap#" 	default="# prodArray[i].productVolumeCap#">
					<cfset productVolumeCap = Evaluate("FORM.#Form_Name_Volume_Cap#") />

					</CFSILENT>
					<CFIF this.Previous_Forecast and (isPartOfGroup eq 0 or (groupId neq nextGroupId or i eq prodLen))>
						<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 1>
						<td align="center" ID="TD_Forecast_CS"  colspan=2>
						<CFIF doneForecast>
							<cfif isPartOfGroup eq 0>
								<A HREF="void(0);" onclick="javaScript: return Show_Forecast_Details('#BSA_Foodservice_Items_Master_ID#');">
									<DIV>#objVolumeApplicator.FormatVolume(Forecast_Volume_CS)#</DIV>
								</A>
							<cfelse>
								<DIV>#objVolumeApplicator.FormatVolume(Forecast_Volume_Group_CS)#</DIV>
							</cfif>
						</CFIF>&nbsp;
						</td>
						<cfelseif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 2>
						<td align="center" ID="TD_Forecast_LB"  colspan=2>
						<CFIF doneForecast>
							<cfif isPartOfGroup eq 0>
								<A HREF="void(0);" onclick="javaScript: return Show_Forecast_Details('#BSA_Foodservice_Items_Master_ID#');">
								<DIV>#objVolumeApplicator.FormatVolume(Forecast_Volume_LB)#</DIV>
								</A>
							<cfelse>
								<DIV>#objVolumeApplicator.FormatVolume(Forecast_Volume_Group_LB)#</DIV>
							</cfif>
						</CFIF>&nbsp;
						</td>
						<cfelse>
						<td ALIGN="right" ID="TD_Forecast_CS" WIDTH="#Volume_Col_Min_Width#">
						<CFIF doneForecast>
							<cfif isPartOfGroup eq 0>
								<A HREF="void(0);" onclick="javaScript: return Show_Forecast_Details('#BSA_Foodservice_Items_Master_ID#');">
									<DIV>#objVolumeApplicator.FormatVolume(Forecast_Volume_CS)#</DIV>
								</A>
							<cfelse>
								<DIV>#objVolumeApplicator.FormatVolume(Forecast_Volume_Group_CS)#</DIV>
							</cfif>
						</CFIF>&nbsp;
						</td>
						<td ALIGN="right" ID="TD_Forecast_LB" WIDTH="#Volume_Col_Min_Width#">
						<CFIF doneForecast>
							<cfif isPartOfGroup eq 0>
								<A HREF="void(0);" onclick="javaScript: return Show_Forecast_Details('#BSA_Foodservice_Items_Master_ID#');">
								<DIV>#objVolumeApplicator.FormatVolume(Forecast_Volume_LB)#</DIV>
								</A>
							<cfelse>
								<DIV>#objVolumeApplicator.FormatVolume(Forecast_Volume_Group_LB)#</DIV>
							</cfif>
						</CFIF>&nbsp;
						</td>
						</cfif>
					</CFIF>
					<cfif showAnnualVolume and (isPartOfGroup eq 0 or (groupId neq nextGroupId or i eq prodLen))>
						<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 1>
						<td align="center" ID="TD_Annual_CS"  colspan=2><DIV CLASS="DIV_HIDE_OVERFLOW" STYLE="WIDTH:#Volume_Col_Min_Width#px;" ID="annual_cs_#FieldNameEnd#"><cfif isPartOfGroup eq 0>#objVolumeApplicator.FormatVolume(Annual_Volume_CS)#<cfelse>#objVolumeApplicator.FormatVolume(Annual_Volume_Group_CS)#</cfif></DIV>&nbsp;</td>
						<cfelseif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 2>
						<td align="center" ID="TD_Annual_LB"  colspan=2><DIV CLASS="DIV_HIDE_OVERFLOW" STYLE="WIDTH:#Volume_Col_Min_Width#px;" ID="annual_lb_#FieldNameEnd#"><cfif isPartOfGroup eq 0>#objVolumeApplicator.FormatVolume(Annual_Volume_LB)#<cfelse>#objVolumeApplicator.FormatVolume(Annual_Volume_Group_LB)#</cfif></DIV>&nbsp;</td>
						<cfelse>
						<td ALIGN="right" ID="TD_Annual_CS" WIDTH="#Volume_Col_Min_Width#"><DIV CLASS="DIV_HIDE_OVERFLOW" STYLE="WIDTH:#Volume_Col_Min_Width#px;" ID="annual_cs_#FieldNameEnd#"><cfif isPartOfGroup eq 0>#objVolumeApplicator.FormatVolume(Annual_Volume_CS)#<cfelse>#objVolumeApplicator.FormatVolume(Annual_Volume_Group_CS)#</cfif></DIV>&nbsp;</td>
						<td ALIGN="right" ID="TD_Annual_LB" WIDTH="#Volume_Col_Min_Width#"><DIV CLASS="DIV_HIDE_OVERFLOW" STYLE="WIDTH:#Volume_Col_Min_Width#px;" ID="annual_lb_#FieldNameEnd#"><cfif isPartOfGroup eq 0>#objVolumeApplicator.FormatVolume(Annual_Volume_LB)#<cfelse>#objVolumeApplicator.FormatVolume(Annual_Volume_Group_LB)#</cfif></DIV>&nbsp;</td>
						</cfif>
					</cfif>

					<cfif isPartOfGroup eq 0 or (groupId neq nextGroupId or i eq prodLen)>
						<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 1>
							<td align="center" ID="TD_Program_CS"  colspan=2>
								<cfif isPartOfGroup eq 0>#objVolumeApplicator.FormatVolume(This_Volume_CS)#<cfelse>#objVolumeApplicator.FormatVolume(This_Volume_Group_CS)#</cfif>
							</td>
						<cfelseif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 2>
							<td align="center" ID="TD_Program_LB"  colspan=2>
								<cfif isPartOfGroup eq 0>#objVolumeApplicator.FormatVolume(This_Volume_LB)#<cfelse>#objVolumeApplicator.FormatVolume(This_Volume_Group_LB)#</cfif>
							</td>
						<cfelse>
							<td ALIGN="right" ID="TD_Program_CS" WIDTH="#Volume_Col_Min_Width#">
								<cfif isPartOfGroup eq 0>#objVolumeApplicator.FormatVolume(This_Volume_CS)#<cfelse>#objVolumeApplicator.FormatVolume(This_Volume_Group_CS)#</cfif>
							</td>
							<td ALIGN="right" ID="TD_Program_LB" WIDTH="#Volume_Col_Min_Width#">
								<cfif isPartOfGroup eq 0>#objVolumeApplicator.FormatVolume(This_Volume_LB)#<cfelse>#objVolumeApplicator.FormatVolume(This_Volume_Group_LB)#</cfif>
							</td>
						</cfif>
							<cfif this.Volume_Packet_Builder.volumePacket.showVolumeCap>
								<td ALIGN="right" ID="TD_Program_LB" WIDTH="#Volume_Col_Min_Width#">
									<cfif isNumeric(productVolumeCap)>
										#objVolumeApplicator.FormatVolume(productVolumeCap)#
									<cfelse>
										&nbsp;
									</cfif>
								</td>
							</cfif>

						</TR>

					</cfif>
				<cfsilent>
				<cfif anyGroupLevel_1 AND productGroupLevel EQ 1>
					<CFIF IsNumeric(Forecast_Volume_CS)>
						<CFSET Forecast_Total_CS 	= objVolumeApplicator.RoundVolume(Forecast_Volume_CS)>
					</CFIF>
					<CFIF IsNumeric(Forecast_Volume_LB)>
						<CFSET Forecast_Total_LB 	= objVolumeApplicator.RoundVolume(Forecast_Volume_LB)>
					</CFIF>
					<CFIF IsNumeric(Annual_Volume_CS)>
						<CFSET Annual_Total_CS 		= objVolumeApplicator.RoundVolume(Annual_Volume_CS)>
					</CFIF>
					<CFIF IsNumeric(Annual_Volume_LB)>
						<CFSET Annual_Total_LB 		= objVolumeApplicator.RoundVolume(Annual_Volume_LB)>
					</CFIF>
					<CFIF IsNumeric(This_Volume_CS)>
						<CFSET Program_Total_CS 	= This_Volume_CS>
					</CFIF>
					<CFIF IsNumeric(This_Volume_LB)>
						<CFSET Program_Total_LB 	= This_Volume_LB>
					</CFIF>
				<cfelseif NOT anyGroupLevel_1>
					<CFIF IsNumeric(Forecast_Volume_CS)>
						<CFSET Forecast_Total_CS 	= Forecast_Total_CS + objVolumeApplicator.RoundVolume(Forecast_Volume_CS)>
					</CFIF>
					<CFIF IsNumeric(Forecast_Volume_LB)>
						<CFSET Forecast_Total_LB 	= Forecast_Total_LB + objVolumeApplicator.RoundVolume(Forecast_Volume_LB)>
					</CFIF>
					<CFIF IsNumeric(Annual_Volume_CS)>
						<CFSET Annual_Total_CS 		= Annual_Total_CS + objVolumeApplicator.RoundVolume(Annual_Volume_CS)>
					</CFIF>
					<CFIF IsNumeric(Annual_Volume_LB)>
						<CFSET Annual_Total_LB 		= Annual_Total_LB + objVolumeApplicator.RoundVolume(Annual_Volume_LB)>
					</CFIF>
					<CFIF IsNumeric(This_Volume_CS)>
						<CFSET Program_Total_CS 	= Program_Total_CS + This_Volume_CS>
					</CFIF>
					<CFIF IsNumeric(This_Volume_LB)>
						<CFSET Program_Total_LB 	= Program_Total_LB + This_Volume_LB>
					</CFIF>
				</cfif>

				<cfif groupId neq nextGroupId>
					<cfset count = count + 1 />
				</cfif>
				</cfsilent>
			</CFLOOP>

		<cfelse>

			<cfloop index="i" from="1" to="#prodLen#">

				<cfsilent>
				<cfif i gt 1>
					<cfset n = i - 1 />
				</cfif>

				<cfset BSA_Foodservice_Items_Master_ID 		= prodArray[i].productId>
				<cfset Net_Weight 							= prodArray[i].netWeight>
				<cfset Description 							= prodArray[i].description>
				<cfset Item		 							= prodArray[i].item>
				<cfset UPC		 							= prodArray[i].upc>
				<cfset productVolume 						= prodArray[i].productVolume>
				<cfset productGroupLevel 					= prodArray[i].productGroupLevel>
				<cfset forecastVolume 						= prodArray[i].forecastVolume>
				<cfset doneForecast							= prodArray[i].doneForecast>
				<cfset groupName							= prodArray[i].groupName>
				<cfset groupId								= prodArray[i].groupId>
				<cfset prevGroupId							= prodArray[n].groupId>

				<!---verify if it's part of a group or not--->
				<cfif trim(prodArray[i].isPartOfGroup) neq "">
					<cfset isPartOfGroup = 1 >
				<cfelse>
					<cfset isPartOfGroup = 0 >
				</cfif>

				<CFSET FieldNameEnd = request.app_general_functions.replaceHyphen(BSA_Foodservice_Items_Master_ID)>
				<CFSET Input_CS_Name = "Product_Volume_#FieldNameEnd#_CS">
				<CFSET Input_LB_Name = "Product_Volume_#FieldNameEnd#_LB">

				<CFSET Forecast_Volume_CS = "Forecast_Volume_#FieldNameEnd#_CS">
				<CFSET Forecast_Volume_LB = "Forecast_Volume_#FieldNameEnd#_LB">

				<CFSET Err_PS_CS_Name = "error_Vol_#FieldNameEnd#_cs">
				<CFSET Err_PS_LB_Name = "error_Vol_#FieldNameEnd#_lb">
				</cfsilent>
				<TR VALIGN="top" <CFIF i mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> <CFIF this.Previous_Forecast AND NOT doneForecast> TITLE="This product is not part of the forecast"</CFIF>>
					<td NOWRAP ID="TD_Item">
						#ITEM#
						<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
							<cfif application.returned_customer_setting.upc_switch EQ 1>
								<BR>#UPC#
							</cfif>
						</cfif>
					</td>
					<td ID="TD_Description">#Description#</td>
					<CFSILENT>
					<CFSET Annual_Volume_CS = "">
					<CFSET Annual_Volume_LB = "">
					<CFIF this.Previous_Forecast>
						<CFIF this.UOM EQ 1>
							<CFSET Forecast_Volume_CS 	= forecastVolume>
							<CFSET Forecast_Volume_LB 	= objVolumeApplicator.ConvertToUOM(Forecast_Volume_CS, 2, Net_Weight)>
						<CFELSE>
							<CFSET Forecast_Volume_LB 	= forecastVolume>
							<CFSET Forecast_Volume_CS 	= objVolumeApplicator.ConvertToUOM(Forecast_Volume_LB, 1, Net_Weight)>
						</CFIF>
					<CFELSE>
						<CFSET Forecast_Volume_CS = 0>
						<CFSET Forecast_Volume_LB = 0>
					</CFIF>

					<CFIF this.UOM EQ 1><!---- program UOM is CS ---->

						<CFPARAM NAME="FORM.#Input_CS_Name#" 	DEFAULT="#productVolume#">

						<CFSET This_Volume_CS 					= Evaluate("FORM.#Input_CS_Name#")>
						<CFPARAM NAME="FORM.#Input_LB_Name#" 	DEFAULT="#objVolumeApplicator.ConvertToUOM(This_Volume_CS, 2, Net_Weight)#">
						<CFSET This_Volume_LB 					= Evaluate("FORM.#Input_LB_Name#")>
						<CFIF This_Volume_CS NEQ 0 AND IsNumeric(This_Volume_CS)>
							<CFSET Annual_Volume_CS 			= ConvertToAnnualVolume(This_Volume_CS)>
							<CFSET Annual_Volume_LB 			= ConvertToAnnualVolume(This_Volume_LB)>
						</CFIF>

					<CFELSE><!---- program UOM is LB ---->

						<CFPARAM NAME="FORM.#Input_LB_Name#" 	DEFAULT="#productVolume#">

						<CFSET This_Volume_LB 					= Evaluate("FORM.#Input_LB_Name#")>
						<CFPARAM NAME="FORM.#Input_CS_Name#" 	DEFAULT="#objVolumeApplicator.ConvertToUOM(This_Volume_LB, 1, Net_Weight)#">
						<CFSET This_Volume_CS 					= Evaluate("FORM.#Input_CS_Name#")>
						<CFSET Annual_Volume_CS 				= ConvertToAnnualVolume(This_Volume_CS)>
						<CFSET Annual_Volume_LB 				= ConvertToAnnualVolume(This_Volume_LB)>

					</CFIF>
					<!------ Volume Cap ----->
					<CFSET Form_Name_Volume_Cap = "Volume_Cap_#FieldNameEnd#">
					<cfparam name="FORM.#Form_Name_Volume_Cap#" 	default="# prodArray[i].productVolumeCap#">
					<cfset productVolumeCap = Evaluate("FORM.#Form_Name_Volume_Cap#") />

					</CFSILENT>
					<CFIF this.Previous_Forecast>
						<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 1>
							<td align="center" ID="TD_Forecast_CS"  colspan=2><CFIF doneForecast><A HREF="void(0);" onclick="javaScript: return Show_Forecast_Details('#BSA_Foodservice_Items_Master_ID#');"><DIV CLASS="DIV_HIDE_OVERFLOW" STYLE="WIDTH:#Volume_Col_Min_Width#";>#objVolumeApplicator.FormatVolume(Forecast_Volume_CS)#</DIV></A></CFIF>&nbsp;</td>
						<cfelseif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 2>
							<td align="center" ID="TD_Forecast_LB"  colspan=2><CFIF doneForecast><A HREF="void(0);" onclick="javaScript: return Show_Forecast_Details('#BSA_Foodservice_Items_Master_ID#');"><DIV>#objVolumeApplicator.FormatVolume(Forecast_Volume_LB)#</DIV></A></CFIF>&nbsp;</td>
						<cfelse>
							<td ALIGN="right" ID="TD_Forecast_CS" WIDTH="#Volume_Col_Min_Width#"><CFIF doneForecast><A HREF="void(0);" onclick="javaScript: return Show_Forecast_Details('#BSA_Foodservice_Items_Master_ID#');"><DIV>#objVolumeApplicator.FormatVolume(Forecast_Volume_CS)#</DIV></A></CFIF>&nbsp;</td>
							<td ALIGN="right" ID="TD_Forecast_LB" WIDTH="#Volume_Col_Min_Width#"><CFIF doneForecast><A HREF="void(0);" onclick="javaScript: return Show_Forecast_Details('#BSA_Foodservice_Items_Master_ID#');"><DIV>#objVolumeApplicator.FormatVolume(Forecast_Volume_LB)#</DIV></A></CFIF>&nbsp;</td>
						</cfif>
					</CFIF>
					<cfif showAnnualVolume>
						<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 1>
						<td align="center" ID="TD_Annual_CS"  colspan=2><DIV CLASS="DIV_HIDE_OVERFLOW" STYLE="WIDTH:#Volume_Col_Min_Width#;" ID="annual_cs_#FieldNameEnd#">#objVolumeApplicator.FormatVolume(Annual_Volume_CS)#</DIV>&nbsp;</td>
						<cfelseif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 2>
						<td align="center" ID="TD_Annual_LB"  colspan=2><DIV CLASS="DIV_HIDE_OVERFLOW" STYLE="WIDTH:#Volume_Col_Min_Width#px;" ID="annual_lb_#FieldNameEnd#">#objVolumeApplicator.FormatVolume(Annual_Volume_LB)#</DIV>&nbsp;</td>
						<cfelse>
						<td ALIGN="right" ID="TD_Annual_CS" WIDTH="#Volume_Col_Min_Width#"><DIV CLASS="DIV_HIDE_OVERFLOW" STYLE="WIDTH:#Volume_Col_Min_Width#px;" ID="annual_cs_#FieldNameEnd#">#objVolumeApplicator.FormatVolume(Annual_Volume_CS)#</DIV>&nbsp;</td>
						<td ALIGN="right" ID="TD_Annual_LB" WIDTH="#Volume_Col_Min_Width#"><DIV CLASS="DIV_HIDE_OVERFLOW" STYLE="WIDTH:#Volume_Col_Min_Width#px;" ID="annual_lb_#FieldNameEnd#">#objVolumeApplicator.FormatVolume(Annual_Volume_LB)#</DIV>&nbsp;</td>
						</cfif>
					</cfif>
					<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 1>
					<td align="center" ID="TD_Program_CS"  colspan=2>
					#objVolumeApplicator.FormatVolume(This_Volume_CS)#</td>
					<cfelseif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 2>
					<td align="center" ID="TD_Program_LB"  colspan=2>
					#objVolumeApplicator.FormatVolume(This_Volume_LB)#</td>
					<cfelse>
					<td ALIGN="right" ID="TD_Program_CS" WIDTH="#Volume_Col_Min_Width#">
					#objVolumeApplicator.FormatVolume(This_Volume_CS)#</td>
					<td ALIGN="right" ID="TD_Program_LB" WIDTH="#Volume_Col_Min_Width#">
					#objVolumeApplicator.FormatVolume(This_Volume_LB)#</td>
					</cfif>
					<cfif this.Volume_Packet_Builder.volumePacket.showVolumeCap>
					<td ALIGN="right" ID="TD_Program_LB" WIDTH="#Volume_Col_Min_Width#">
					<cfif isNumeric(productVolumeCap)>#objVolumeApplicator.FormatVolume(productVolumeCap)#<cfelse>&nbsp;</cfif></td>
					</cfif>
				</TR>
				<cfsilent>
				<cfif anyGroupLevel_1 AND productGroupLevel EQ 1>
					<CFIF IsNumeric(Forecast_Volume_CS)>
						<CFSET Forecast_Total_CS 	= objVolumeApplicator.RoundVolume(Forecast_Volume_CS)>
					</CFIF>
					<CFIF IsNumeric(Forecast_Volume_LB)>
						<CFSET Forecast_Total_LB 	= objVolumeApplicator.RoundVolume(Forecast_Volume_LB)>
					</CFIF>
					<CFIF IsNumeric(Annual_Volume_CS)>
						<CFSET Annual_Total_CS 		= objVolumeApplicator.RoundVolume(Annual_Volume_CS)>
					</CFIF>
					<CFIF IsNumeric(Annual_Volume_LB)>
						<CFSET Annual_Total_LB 		= objVolumeApplicator.RoundVolume(Annual_Volume_LB)>
					</CFIF>
					<CFIF IsNumeric(This_Volume_CS)>
						<CFSET Program_Total_CS 	= This_Volume_CS>
					</CFIF>
					<CFIF IsNumeric(This_Volume_LB)>
						<CFSET Program_Total_LB 	= This_Volume_LB>
					</CFIF>
				<cfelseif NOT anyGroupLevel_1>
					<CFIF IsNumeric(Forecast_Volume_CS)>
						<CFSET Forecast_Total_CS 	= Forecast_Total_CS + objVolumeApplicator.RoundVolume(Forecast_Volume_CS)>
					</CFIF>
					<CFIF IsNumeric(Forecast_Volume_LB)>
						<CFSET Forecast_Total_LB 	= Forecast_Total_LB + objVolumeApplicator.RoundVolume(Forecast_Volume_LB)>
					</CFIF>
					<CFIF IsNumeric(Annual_Volume_CS)>
						<CFSET Annual_Total_CS 		= Annual_Total_CS + objVolumeApplicator.RoundVolume(Annual_Volume_CS)>
					</CFIF>
					<CFIF IsNumeric(Annual_Volume_LB)>
						<CFSET Annual_Total_LB 		= Annual_Total_LB + objVolumeApplicator.RoundVolume(Annual_Volume_LB)>
					</CFIF>
					<CFIF IsNumeric(This_Volume_CS)>
						<CFSET Program_Total_CS 	= Program_Total_CS + This_Volume_CS>
					</CFIF>
					<CFIF IsNumeric(This_Volume_LB)>
						<CFSET Program_Total_LB 	= Program_Total_LB + This_Volume_LB>
					</CFIF>
				</cfif>
				</cfsilent>
			</CFLOOP>

		</cfif>

			<tr VALIGN="top" BGCOLOR="##FFFFFF">
				<td ID="header" align="right" COLSPAN="2"><B>Total volume :</B>&nbsp;&nbsp;</td>
				<CFIF this.Previous_Forecast>
					<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 1>
						<td ID="header" align="center" colspan =2><B>#objVolumeApplicator.FormatVolume(Forecast_Total_CS)#</B></td>
					<cfelseif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 2>
						<td ID="header" align="center" colspan =2><B>#objVolumeApplicator.FormatVolume(Forecast_Total_LB)#</B></td>
					<cfelse>
						<td ID="header" ALIGN="right"><B>#objVolumeApplicator.FormatVolume(Forecast_Total_CS)#</B></td>
						<td ID="header" ALIGN="right"><B>#objVolumeApplicator.FormatVolume(Forecast_Total_LB)#</B></td>
					</cfif>
				</CFIF>
				<cfif showAnnualVolume>
					<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 1>
						<td ID="header" align="center" colspan =2><B>#objVolumeApplicator.FormatVolume(Annual_Total_CS)#</B></td>
					<cfelseif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 2>
						<td ID="header" align="center" colspan =2><B>#objVolumeApplicator.FormatVolume(Annual_Total_LB)#</B></td>
					<cfelse>
						<td ID="header" ALIGN="right"><B>#objVolumeApplicator.FormatVolume(Annual_Total_CS)#</B></td>
						<td ID="header" ALIGN="right"><B>#objVolumeApplicator.FormatVolume(Annual_Total_LB)#</B></td>
					</cfif>
				</cfif>
				<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 1>
					<td ID="header" align="center" colspan =2><B>#objVolumeApplicator.FormatVolume(Program_Total_CS)#</B></td>
				<cfelseif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewProgramVolumeUOM() EQ 2>
					<td ID="header" align="center" colspan =2><B>#objVolumeApplicator.FormatVolume(Program_Total_LB)#</B></td>
				<cfelse>
					<td ID="header" ALIGN="right"><B>#objVolumeApplicator.FormatVolume(Program_Total_CS)#</B></td>
					<td ID="header" ALIGN="right"><B>#objVolumeApplicator.FormatVolume(Program_Total_LB)#</B></td>
				</cfif>
				<cfif this.Volume_Packet_Builder.volumePacket.showVolumeCap>
				<td ID="header" ALIGN="right">&nbsp;</td>
				</cfif>
			</tr>
		</TABLE>


   	</cffunction>

	<!--- text format --->
	<cffunction name="View_Program_Product_List_Txt" output="true" hint="Show_Product_List"><cfsilent>
		<cfset this.loadVolumInfoToPacket()>
		<CFSET this.Load_Forecast_Summary()>
		<cfset NewLine = Chr(13) & Chr(10)>
		<cfset prodArray = this.Volume_Packet_Builder.volumePacket.products>
		<cfset prodLen = ArrayLen(prodArray)>
		<CFSET claimHandle = CreateObject("component", "components.reports.claim")>
		<CFIF prodLen EQ 0>
			<CFRETURN>
		</CFIF>
		<cfset showAnnualVolume = 1>
		<cfif this.Volume_Packet_Builder.volumePacket.showVolumeCap>
			<cfset showAnnualVolume = 0>
		</cfif></cfsilent>
		<cfoutput>#NewLine##NewLine##NewLine#Program Volume#NewLine#</cfoutput><cfif NOT this.defaultUOT.getMultiplier() OR this.Previous_Forecast><cfif NOT this.defaultUOT.getMultiplier()><cfoutput>#DateFormat(this.Contract_Start_Date, "mm/dd/yyyy")# - #DateFormat(this.Contract_End_Date, "mm/dd/yyyy")# (#this.Contract_Span#)#NewLine##NewLine#</cfoutput></cfif></cfif><CFOUTPUT>#RepeatString("-",130)##NewLine#</CFOUTPUT><cfoutput>#claimHandle.TextAlignLeft(12,"Item##")#</cfoutput><cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><cfoutput>#claimHandle.TextAlignLeft(12,"UPC")#</cfoutput></cfif></cfif><cfoutput>#claimHandle.TextAlignLeft(18,"DESCRIPTION")#</cfoutput><cfif showAnnualVolume><cfoutput>#claimHandle.TextAlignLeft(28,"Annual Volume")#</cfoutput></cfif><cfoutput>#claimHandle.TextAlignLeft(28,"#this.defaultUOT.getDesc()#Volume")#</cfoutput><cfoutput>#NewLine##claimHandle.TextAlignLeft(12,'')##claimHandle.TextAlignLeft(12,'')##claimHandle.TextAlignLeft(18,'')#</cfoutput><cfif showAnnualVolume><cfoutput>#claimHandle.TextAlignLeft(14,Application.UOMCaseSingular)#</cfoutput><cfoutput>#claimHandle.TextAlignLeft(14,Application.UOMPoundSingular)#</cfoutput></cfif><cfoutput>#claimHandle.TextAlignLeft(14,"Case")#</cfoutput><cfoutput>#claimHandle.TextAlignLeft(14,"Pound")#</cfoutput><cfoutput>#NewLine#</cfoutput><cfsilent>

		<CFSET Forecast_Total_CS = 0>
		<CFSET Forecast_Total_LB = 0>
		<CFSET Annual_Total_CS = 0>
		<CFSET Annual_Total_LB = 0>
		<CFSET Program_Total_CS = 0>
		<CFSET Program_Total_LB = 0>
		<CFSET Volume_Col_Min_Width = 80>

		<cfset anyGroupLevel_1 = this.Volume_Packet_Builder.volumePacket.allProductsSelected />

		</cfsilent><cfloop index="i" from="1" to="#prodLen#"><cfsilent>
			<cfset BSA_Foodservice_Items_Master_ID 	= prodArray[i].productId>
			<cfset Net_Weight 							= prodArray[i].netWeight>
			<cfset Description 							= prodArray[i].description>
			<cfset Item		 							= prodArray[i].item>
			<cfset UPC		 							= prodArray[i].upc>
			<cfset productVolume 						= prodArray[i].productVolume>
			<cfset productGroupLevel 					= prodArray[i].productGroupLevel>
			<cfset forecastVolume 						= prodArray[i].forecastVolume>
			<cfset doneForecast							= prodArray[i].doneForecast>

			<CFSET FieldNameEnd = request.app_general_functions.replaceHyphen(BSA_Foodservice_Items_Master_ID)>
			<CFSET Input_CS_Name = "Product_Volume_#FieldNameEnd#_CS">
			<CFSET Input_LB_Name = "Product_Volume_#FieldNameEnd#_LB">

			<CFSET Forecast_Volume_CS = "Forecast_Volume_#FieldNameEnd#_CS">
			<CFSET Forecast_Volume_LB = "Forecast_Volume_#FieldNameEnd#_LB">

			<CFSET Err_PS_CS_Name = "error_Vol_#FieldNameEnd#_cs">
			<CFSET Err_PS_LB_Name = "error_Vol_#FieldNameEnd#_lb">
			</cfsilent>
					<cfoutput>#claimHandle.TextAlignLeft(12,ITEM)#</cfoutput>
					<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>
					<cfoutput>#claimHandle.TextAlignLeft(12,UPC)#</cfoutput>
					</cfif></cfif>
					<cfif Len(Trim(Description)) LT 15>
						<cfset Desc = Trim(Description)>
					<cfelse>
					<cfset Desc = Left(Trim(Description),15)>
					</cfif>
				<cfoutput>#claimHandle.TextAlignLeft(18,TRIM(Desc))#</cfoutput>
				<CFSILENT>
				<CFSET Annual_Volume_CS = "">
				<CFSET Annual_Volume_LB = "">
				<CFIF this.Previous_Forecast>
					<CFIF this.UOM EQ 1>
						<CFSET Forecast_Volume_CS 	= forecastVolume>
						<CFSET Forecast_Volume_LB 	= objVolumeApplicator.ConvertToUOM(Forecast_Volume_CS, 2, Net_Weight)>
					<CFELSE>
						<CFSET Forecast_Volume_LB 	= forecastVolume>
						<CFSET Forecast_Volume_CS 	= objVolumeApplicator.ConvertToUOM(Forecast_Volume_LB, 1, Net_Weight)>
					</CFIF>
				<CFELSE>
					<CFSET Forecast_Volume_CS = 0>
					<CFSET Forecast_Volume_LB = 0>
				</CFIF>

				<CFIF this.UOM EQ 1><!---- program UOM is CS ---->

					<CFPARAM NAME="FORM.#Input_CS_Name#" 	DEFAULT="#productVolume#">

					<CFSET This_Volume_CS 					= Evaluate("FORM.#Input_CS_Name#")>
					<CFPARAM NAME="FORM.#Input_LB_Name#" 	DEFAULT="#objVolumeApplicator.ConvertToUOM(This_Volume_CS, 2, Net_Weight)#">
					<CFSET This_Volume_LB 					= Evaluate("FORM.#Input_LB_Name#")>
					<CFIF This_Volume_CS NEQ 0 AND IsNumeric(This_Volume_CS)>
						<CFSET Annual_Volume_CS 			= ConvertToAnnualVolume(This_Volume_CS)>
						<CFSET Annual_Volume_LB 			= ConvertToAnnualVolume(This_Volume_LB)>
					</CFIF>

				<CFELSE><!---- program UOM is LB ---->

					<CFPARAM NAME="FORM.#Input_LB_Name#" 	DEFAULT="#productVolume#">

					<CFSET This_Volume_LB 					= Evaluate("FORM.#Input_LB_Name#")>
					<CFPARAM NAME="FORM.#Input_CS_Name#" 	DEFAULT="#objVolumeApplicator.ConvertToUOM(This_Volume_LB, 1, Net_Weight)#">
					<CFSET This_Volume_CS 					= Evaluate("FORM.#Input_CS_Name#")>
					<CFSET Annual_Volume_CS 				= ConvertToAnnualVolume(This_Volume_CS)>
					<CFSET Annual_Volume_LB 				= ConvertToAnnualVolume(This_Volume_LB)>

				</CFIF>
				<!------ Volume Cap ----->
				<CFSET Form_Name_Volume_Cap = "Volume_Cap_#FieldNameEnd#">
				<cfparam name="FORM.#Form_Name_Volume_Cap#" 	default="# prodArray[i].productVolumeCap#">
				<cfset productVolumeCap = Evaluate("FORM.#Form_Name_Volume_Cap#") />

				</CFSILENT>
				<cfif showAnnualVolume>
	<cfoutput>#claimHandle.TextAlignLeft(14,TRIM(objVolumeApplicator.FormatVolume(Annual_Volume_CS)))#</cfoutput>	<cfoutput>#claimHandle.TextAlignLeft(14,TRIM(objVolumeApplicator.FormatVolume(Annual_Volume_LB)))#</cfoutput>
				</cfif>
<cfoutput>#claimHandle.TextAlignLeft(14,TRIM(objVolumeApplicator.FormatVolume(This_Volume_CS)))#</cfoutput>	<cfoutput>#claimHandle.TextAlignLeft(14,TRIM(objVolumeApplicator.FormatVolume(This_Volume_LB)))#</cfoutput>
			<cfif anyGroupLevel_1 AND productGroupLevel EQ 1>
				<CFIF IsNumeric(Forecast_Volume_CS)>
					<CFSET Forecast_Total_CS 	= objVolumeApplicator.RoundVolume(Forecast_Volume_CS)>
				</CFIF>
				<CFIF IsNumeric(Forecast_Volume_LB)>
					<CFSET Forecast_Total_LB 	= objVolumeApplicator.RoundVolume(Forecast_Volume_LB)>
				</CFIF>
				<CFIF IsNumeric(Annual_Volume_CS)>
					<CFSET Annual_Total_CS 		= objVolumeApplicator.RoundVolume(Annual_Volume_CS)>
				</CFIF>
				<CFIF IsNumeric(Annual_Volume_LB)>
					<CFSET Annual_Total_LB 		= objVolumeApplicator.RoundVolume(Annual_Volume_LB)>
				</CFIF>
				<CFIF IsNumeric(This_Volume_CS)>
					<CFSET Program_Total_CS 	= objVolumeApplicator.RoundVolume(This_Volume_CS)>
				</CFIF>
				<CFIF IsNumeric(This_Volume_LB)>
					<CFSET Program_Total_LB 	= This_Volume_LB>
				</CFIF>
			<cfelseif NOT anyGroupLevel_1>
				<CFIF IsNumeric(Forecast_Volume_CS)>
					<CFSET Forecast_Total_CS 	= Forecast_Total_CS + objVolumeApplicator.RoundVolume(Forecast_Volume_CS)>
				</CFIF>
				<CFIF IsNumeric(Forecast_Volume_LB)>
					<CFSET Forecast_Total_LB 	= Forecast_Total_LB + objVolumeApplicator.RoundVolume(Forecast_Volume_LB)>
				</CFIF>
				<CFIF IsNumeric(Annual_Volume_CS)>
					<CFSET Annual_Total_CS 		= Annual_Total_CS + objVolumeApplicator.RoundVolume(Annual_Volume_CS)>
				</CFIF>
				<CFIF IsNumeric(Annual_Volume_LB)>
					<CFSET Annual_Total_LB 		= Annual_Total_LB + objVolumeApplicator.RoundVolume(Annual_Volume_LB)>
				</CFIF>
				<CFIF IsNumeric(This_Volume_CS)>
					<CFSET Program_Total_CS 	= Program_Total_CS + objVolumeApplicator.RoundVolume(This_Volume_CS)>
				</CFIF>
				<CFIF IsNumeric(This_Volume_LB)>
					<CFSET Program_Total_LB 	= Program_Total_LB + This_Volume_LB>
				</CFIF>
			</cfif><cfoutput>#NewLine#</cfoutput>
		</CFLOOP>
			<CFOUTPUT>#RepeatString("-",90)##NewLine##claimHandle.TextAlignLeft(42,"Total volume :")#</CFOUTPUT>
				<cfif showAnnualVolume>
	<cfoutput>#claimHandle.TextAlignLeft(14,TRIM(objVolumeApplicator.FormatVolume(Annual_Total_CS)))#</cfoutput>	<cfoutput>#claimHandle.TextAlignLeft(14,TRIM(objVolumeApplicator.FormatVolume(Annual_Total_LB)))#</cfoutput>
				</cfif>	<cfoutput>#claimHandle.TextAlignLeft(14,TRIM(objVolumeApplicator.FormatVolume(Program_Total_CS)))#</cfoutput>	<cfoutput>#claimHandle.TextAlignLeft(14,TRIM(objVolumeApplicator.FormatVolume(Program_Total_LB)))#</cfoutput>
   	</cffunction>

	<!----------------- Load_Forecast_Summary() -------------------->
	<cffunction name="Load_Forecast_Summary" output="true" hint="Show_Forecast_Small_Menu">
		<cfargument name="Show_Details" type="numeric" required="false" default="0">

		<cfset this.Previous_Forecast			= false>

		<CFQUERY NAME="Get_Forecast_Summary" DATASOURCE="#application.datasource#">
			SELECT	Forecast_ID, Forecast_From_Date, Forecast_To_Date, Forecast_Update_Date, Forecast_Overage, Forecast_Overage_UOM, _Users.Name_First + ' ' + _Users.Name_Last AS Forecast_User_Name
			FROM	Forecast
					INNER JOIN _Users
					ON
					_Users.User_ID = Forecast.Forecast_Update_User_ID
			WHERE
					Forecast.Forecast_ID = #this.Forecast_ID#
					AND
					Forecast.Deleted = 0
		</CFQUERY>
		<CFIF Get_Forecast_Summary.RecordCount GT 0>
			<cfset this.Previous_Forecast			= true>
			<cfset this.Load_From_Forecast			= true>
			<CFSET this.Forecast_From_Date 			= Get_Forecast_Summary.Forecast_From_Date>
			<CFSET this.Forecast_To_Date 			= Get_Forecast_Summary.Forecast_To_Date>
			<CFSET this.Forecast_User_Name 			= Get_Forecast_Summary.Forecast_User_Name>
			<CFSET this.Forecast_Update_Date		= Get_Forecast_Summary.Forecast_Update_Date>
			<CFSET this.Forecast_Span				= DateDiff("d", this.Forecast_From_Date, this.Forecast_To_Date) + 1>
		</CFIF>
   	</cffunction>

 	<!----------------- getProductVolumeCapInfo() -------------------->
   	<cffunction name="getProductVolumeCapInfo" output="false" hint="Get product volume cap">
		<cfargument name="Product_ID" type="string" required="true">

		<cfquery name="qProductVolumeCapInfo" dbtype="query">
			SELECT		Volume_Cap
			FROM		Get_Global_Volume
			WHERE
						BSA_Foodservice_Items_Master_ID = '#arguments.Product_ID#'
		</cfquery>

		<cfif not qProductVolumeCapInfo.recordCount>
			<cfset QueryAddRow(qProductVolumeCapInfo) />
			<cfset QuerySetCell(qProductVolumeCapInfo, "Volume_Cap", 0) />
		</cfif>

		<cfreturn qProductVolumeCapInfo />

	</cffunction>


	 <!----------------- GetProductVolume() -------------------->
   	<cffunction name="GetProductVolume" output="true" hint="Get product volume out of any one of the discount types">
		<cfargument name="Product_ID" type="string" required="true" default="">
		<cfset product_volume = 0>

		<!------------- Global Volume ---------------->
		<cfset useLakebaseForThis_Global_Volume = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_global_volume")>
<cfif useLakebaseForThis_Global_Volume>
	<cftry>
		<cfset This_Global_Volume = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_global_volume", {
				"bsa_foodservice_items_master_id" = "eq.#Product_ID#",
				"select" = "volume"
			}), "volume"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForThis_Global_Volume = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForThis_Global_Volume>
<CFQUERY NAME="This_Global_Volume" DBTYPE="query">
			SELECT		Volume
			FROM		Get_Global_Volume
			WHERE
						BSA_Foodservice_Items_Master_ID = '#Product_ID#'
		</CFQUERY>
</cfif>


		<cfset product_volume = 0>

		<cfset product_volume = this.Get_Larger_Volume(This_Global_Volume, product_volume)>

		<CFIF IsNumeric(product_volume)>
			<cfif this.defaultUOT.getMultiplier()>
				<cfset product_volume = product_volume * (this.defaultUOT.getMultiplier()/7)>
			<cfelse>
				<cfset product_volume = product_volume * (this.Contract_Span/7)>
			</cfif>
		</CFIF>

		<!---<cfset product_volume = Round(product_volume) />--->

		<cfreturn product_volume/>
	</cffunction>

	<!----------------- Get_Larger_Volume() -------------------->
   	<cffunction name="Get_Larger_Volume" output="false" hint="Get_Larger_Volume">
		<cfargument name="Query_Volume" type="query" required="true" default="">
		<cfargument name="Current_Volume" type="numeric" required="true" default="">
		<cfset product_volume = Arguments.Current_Volume>
		<cfset Query_Volume = Arguments.Query_Volume>
		<CFIF Query_Volume.RecordCount GT 0>
			<CFIF Query_Volume.Volume GT product_volume>
				<CFSET product_volume = Query_Volume.Volume>
			</CFIF>
		</CFIF>
		<cfreturn product_volume>
	</cffunction>

	<!----------------- Check_Any_NULL_Volume() -------------------->
   	<cffunction name="Check_Any_NULL_Volume" output="true" hint="Check_Any_NULL_Volume">
		<cfargument name="ContractIDs" type="string" required="false" default="">

		<CFIF arguments.ContractIDs eq "">
			<CFSET this.Null_Volume_Products = this.Get_Null_Volume_Product_List()>
		<CFELSE>
			<CFSET this.Null_Volume_Products = this.Get_Null_Volume_Product_List(ContractIDs=arguments.ContractIDs)>
		</CFIF>
		<CFSET All_Proper_Volume = true>
		<CFIF this.Null_Volume_Products.RecordCount GT 0>
			<CFSET All_Proper_Volume = false>
		</CFIF>
		<CFRETURN All_Proper_Volume>
	</cffunction>

	<cffunction name="Get_Null_Volume_Product_List" output="true" hint="Get_Null_Volume_Product_List">
		<cfargument name="Check_Not_Null" type="numeric" required="false" default="0">
		<cfargument name="ContractIDs" type="string" required="false" default="">

		<CFQUERY NAME="Null_Volume_Product_List" DATASOURCE="#application.datasource#">
            IF OBJECT_ID('tempdb..##tmp_prod_with_nonzero_rate') IS NOT NULL
            DROP TABLE ##tmp_prod_with_nonzero_rate

            CREATE TABLE ##tmp_prod_with_nonzero_rate (bsa_foodservice_items_master_id uniqueidentifier)

            DECLARE @contract_main_id int
            <CFIF arguments.ContractIDs eq "">
			SET @contract_main_id = #this.Program_ID#
			<CFELSE>
			SET @contract_main_id = #ListFirst(arguments.ContractIDs)#
			</CFIF>
            -- Temp table ##tmp_prod_with_nonzero_rate will be populated in SP Program_Products_Non_Zero_Rate
            EXEC Program_Products_Non_Zero_Rate @contract_main_id

			SELECT     	DISTINCT
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
			FROM		Contract_Products
						INNER JOIN	BSA_Foodservice_Items_Master ON
                      	Contract_Products.BSA_Foodservice_Items_Master_ID = dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
						LEFT JOIN Program_Product_Volume
						ON	Program_Product_Volume.Deleted = 0
						AND Program_Product_Volume.Program_ID = Contract_Products.Contract_Main_ID
						AND Program_Product_Volume.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
						AND Program_Product_Volume.Is_Group = 0
			<CFIF arguments.ContractIDs eq "">
			WHERE 		Contract_Products.Contract_Main_ID = #this.Program_ID#
			<CFELSE>
			WHERE 		Contract_Products.Contract_Main_ID IN (#arguments.ContractIDs#)
			</CFIF>
						AND dbo.Contract_Products.Deleted = 0
						AND Contract_Products.Is_Group = 0
						AND Contract_Products.Include_In_Margin = 1
			AND EXISTS (select 1 from ##tmp_prod_with_nonzero_rate t where t.bsa_foodservice_items_master_id = contract_products.BSA_Foodservice_Items_Master_ID)
			<CFIF Arguments.Check_Not_Null EQ 0>
			AND (len(Program_Product_Volume.Volume_LB) <= 0  OR Program_Product_Volume.Volume_LB IS NULL OR Program_Product_Volume.Volume_LB = '0')
			AND (len(Program_Product_Volume.Volume_CS) <= 0  OR Program_Product_Volume.Volume_CS IS NULL OR Program_Product_Volume.Volume_CS = '0')
			<CFELSE>
			(
				AND (len(Program_Product_Volume.Volume_LB) > 0 AND Program_Product_Volume.Volume_LB IS NOT NULL AND IsNumeric(Program_Product_Volume.Volume_LB) = 1)
				AND (len(Program_Product_Volume.Volume_CS) > 0 AND Program_Product_Volume.Volume_CS IS NOT NULL AND IsNumeric(Program_Product_Volume.Volume_CS) = 1)
				AND Program_Product_Volume.Is_Group = 0
			)
			</CFIF>

						<!---
						AND
						(
							<!------ Group ----->
							(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
							OR
							<!------ Product ----->
							(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
						) --->
		</CFQUERY>
		<CFRETURN Null_Volume_Product_List>
	</cffunction>

	<!----------------- Get_Total_Program_Volume() -------------------->
   	<cffunction name="Get_Total_Program_Volume" output="true" hint="Get_Total_Program_Volume">
		<CFSET Total_Volume = 0>

		<CFSET Get_Product_List()>
		<CFLOOP QUERY="Get_Distinct_Products">
			<CFSET Product_Volume 	= this.GetProductVolume(BSA_Foodservice_Items_Master_ID, this.UOM)>
			<CFSET Total_Volume = Total_Volume + Product_Volume>
		</CFLOOP>
		<CFRETURN Total_Volume>
	</cffunction>

	<!----------------- ConvertToAnnualVolume() -------------------->
   	<cffunction name="ConvertToAnnualVolume" output="false" hint="ConvertToAnnualVolume">
		<cfargument name="Program_Volume" type="string" required="true" default="">
		<CFSET Return_Annual_Volume = "">
		<cfset volumeStoredSpan = this.Contract_Span>
		<cfif this.defaultUOT.getMultiplier()>
				<cfset volumeStoredSpan =this.defaultUOT.getMultiplier()>
		</cfif>
		<CFIF IsNumeric(volumeStoredSpan) AND volumeStoredSpan GT 0 AND IsNumeric(Arguments.Program_Volume)>
			<CFSET Return_Annual_Volume = (Arguments.Program_Volume / volumeStoredSpan) * 365>
		</CFIF>
		<cfreturn Return_Annual_Volume>
	</cffunction>

	<!----------------- convertToDefaultVolumeUOT() -------------------->
   	<cffunction name="convertToDefaultVolumeUOT" output="false" hint="convertToProgramVolume">
		<cfargument name="Volume" type="string" required="true" default="">
		<cfargument name="currentUOT" type="numeric" required="true" default="">

		<CFSET Return_Volume = 0>
		<CFIF IsNumeric(Arguments.Volume) AND Arguments.currentUOT NEQ 0>
			<CFSET Return_Volume = Arguments.Volume * (this.defaultUOT.getMultiplier() / Arguments.currentUOT)>
		</CFIF>
		<cfreturn Return_Volume>
	</cffunction>

	<!----------------- loadProgramProductVolume() -------------------->
   	<cffunction name="loadProgramProductVolume" output="false">

		<cfargument name="programId" type="numeric" required="true" default="">

		<cfset useLakebaseForqGetProgramProdVol = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_product_volume")>
<cfif useLakebaseForqGetProgramProdVol>
	<cftry>
		<cfset qGetProgramProdVol = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_product_volume", {
				"deleted" = "eq.0",
				"program_id" = "eq.#arguments.programId#",
				"select" = "program_product_volume_id,program_id,bsa_foodservice_items_master_id,volume_lb,volume_cs"
			}), "program_product_volume_id,program_id,bsa_foodservice_items_master_id,volume_lb,volume_cs"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProgramProdVol = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProgramProdVol>
<cfquery name="qGetProgramProdVol" datasource="#application.datasource#">
			SELECT	Program_Product_Volume_ID,
					Program_ID,
					BSA_Foodservice_Items_Master_ID,
					Volume_LB,
					Volume_CS
					<!------ ,
					Volume_Multiplier,
					Volume ----->
			FROM	Program_Product_Volume
			WHERE	Deleted = 0
			AND		Program_ID = #arguments.programId#
		</cfquery>
</cfif>

		<cfloop query="qGetProgramProdVol">

			<cfset ProgramProdVolume = CreateObject("component", "components.programs.volume.ProgramProductVolume") />
			<cfset ProgramProdVolume.setId(Program_Product_Volume_ID) />
			<cfset ProgramProdVolume.setProgramId(Program_ID) />
			<cfset ProgramProdVolume.setItemMasterId(BSA_Foodservice_Items_Master_ID) />
			<cfset ProgramProdVolume.setVolumeLB(Volume_LB) />
			<cfset ProgramProdVolume.setVolumeCS(Volume_CS) />
			<!------ <cfset ProgramProdVolume.setMultiplier(Volume_Multiplier) />
			<cfset ProgramProdVolume.setVolume(Volume) /> ----->

			<cfset this.setProgramProductVolume(ProgramProdVolume) />

		</cfloop>

		<cfreturn this />

	</cffunction>

	<!----------------- saveProgramProductVolume() -------------------->
   	<cffunction name="saveProgramProductVolume" output="false">

		<cfargument name="programVolume" type="components.programs.volume.ProgramVolume" required="true" default="">

		<!---set the program products array--->
		<cfset aProgramProductVolume = arguments.programVolume.getProgramProductVolume() />

		<!---loop over each product and insert with new program id--->
		<cfloop from="1" to="#ArrayLen(aProgramProductVolume)#" index="indx">

			<!---check to see if product exists--->
			<cfquery name="qCheckProduct" datasource="#application.datasource#">
				SELECT 	BSA_Foodservice_Items_Master_ID
				FROM
						Program_Product_Volume
				WHERE
						Program_ID = #this.getProgramId()#
				AND 	Deleted = 0
				AND 	BSA_Foodservice_Items_Master_ID = '#trim(aProgramProductVolume[indx].getItemMasterId())#'
			</cfquery>

			<!---------- Save Global Volume Rule ------------>
			<cfif qCheckProduct.RecordCount>

				<!---------- Update Global Volume Rule ------------>
				<CFQUERY NAME="Get_Global_Volume" DATASOURCE="#application.datasource#">
					UPDATE	Program_Product_Volume
					SET
							Volume_LB = '#trim(aProgramProductVolume[indx].getVolumeLB())#',
							Volume_CS = '#trim(aProgramProductVolume[indx].getVolumeCS())#',
							Updated_Date = getdate()
							<!------ ,
							Volume_Multiplier = #trim(aProgramProductVolume[indx].getMultiplier())#,
							Volume = '#trim(aProgramProductVolume[indx].getVolume())#' ----->
					WHERE
							Program_ID = #this.getProgramId()#
					AND 	Deleted = 0
					AND 	BSA_Foodservice_Items_Master_ID = '#trim(aProgramProductVolume[indx].getItemMasterId())#'
				</CFQUERY>

			<cfelse>

				<!---------- Insert Global Volume Rule ------------>
				<cfset useLakebaseForqInsertPrgmProds = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_product_volume")>
<cfif useLakebaseForqInsertPrgmProds>
	<cftry>
		<cfset application.oLakebase.insertRow("program_product_volume", {
			"program_id" = "#arguments.programVolume.getProgramId()#",
			"bsa_foodservice_items_master_id" = "#trim(aProgramProductVolume[indx].getItemMasterId())#",
			"volume_lb" = "#trim(aProgramProductVolume[indx].getVolumeLB())#",
			"volume_cs" = "#trim(aProgramProductVolume[indx].getVolumeCS())#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsertPrgmProds = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsertPrgmProds>
<cfquery name="qInsertPrgmProds" datasource="#application.datasource#">
					INSERT INTO Program_Product_Volume
						(Program_ID, BSA_Foodservice_Items_Master_ID, Volume_LB, Volume_CS
						<!------ , Volume_Multiplier, Volume ----->
						)
					VALUES
						(
							#arguments.programVolume.getProgramId()#,
							'#trim(aProgramProductVolume[indx].getItemMasterId())#',
							'#trim(aProgramProductVolume[indx].getVolumeLB())#',
							'#trim(aProgramProductVolume[indx].getVolumeCS())#'
							<!------ ,
							#trim(aProgramProductVolume[indx].getMultiplier())#,
							'#trim(aProgramProductVolume[indx].getVolume())#' ----->
						)
				</cfquery>
</cfif>

			</cfif>

		</cfloop>
	</cffunction>

	<cffunction name="isVolumeApplied" returntype="boolean" output="false" access="public" hint="to check if there's any non zero volume count">
		<cfif this.nonZeroVolCount() GT 0>
 			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>

	<cffunction name="nonZeroVolCount" returntype="numeric" output="false" access="public" hint="to check program_product_volume table to see if there's any volume > 0">
		<CFQUERY NAME="GetNonZeroVolCount" DATASOURCE="#application.datasource#">
			SELECT count(*) as nonZeroVolCount
			FROM	Program_Product_Volume
			WHERE	Program_Product_Volume.Deleted = 0
			AND		Program_Product_Volume.Program_ID = #this.Program_ID#
			AND 	Volume_LB > 0
		</CFQUERY>
		<cfreturn GetNonZeroVolCount.nonZeroVolCount />
	</cffunction>

	<cffunction name="processGroups" output="false" hint="Function will check to see if any groups need to be processed based on volume.">

		<cfargument name="programID" required="true" />

		<cfset programManager = CreateObject("component", "components.programs.ProgramManager") />

		<!---if the program has groups then check to make sure we have a distributor--->
		<cfif programManager.programHasGroups(arguments.programID) eq 1>

			<cfquery name="qCheckGroupProcessed" datasource="#application.datasource#">

				SELECT  Group_Processed
				FROM	Contract_Main
				WHERE	Deleted = 0
				AND 	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.programID#" />

			</cfquery>

			<!---if the groups need to be processed then set Volume_Good to false--->
			<cfif qCheckGroupProcessed.Group_Processed eq 1>

				<cfstoredproc procedure="SP_CAPTURE_ALL_FOR_GROUPS" datasource="#application.datasource#">

					<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#arguments.programID#" null="no">
					<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@@Default_One_Case" value = "0" null="no">

				</cfstoredproc>

				<!---if app settings is on then call the stored procedure to divide the volume based on program volume, number of products and program span--->
				<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getDivideProgramVolumeForGroups() eq 1>
					<cfstoredproc procedure="SP_DIVIDE_PROGRAM_VOLUME" datasource="#application.datasource#">
						<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#arguments.programID#" null="no">
					</cfstoredproc>
				</cfif>

				<cfset useLakebaseForqFlagGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqFlagGroup>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"deleted" = "eq.0",
				"contract_main_id" = "eq.#arguments.programID#"
			},
			{
				"group_processed" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqFlagGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqFlagGroup>
<cfquery name="qFlagGroup" datasource="#application.datasource#">

					UPDATE	Contract_Main
					SET		Group_Processed = 0
					WHERE	Deleted = 0
					AND 	Contract_Main_ID = #arguments.programID#

				</cfquery>
</cfif>

				<cfreturn 1 />

			</cfif>

		</cfif>

		<cfreturn 0 />

	</cffunction>

	<!--- Dev Note: KAL; 8337 --->
	<!--- Averaging the contract_quantity as the program volume with atleast 1 UOM and then the Contract Quantity is adjusted --->
	<cffunction name="AssignACase" output="false" hint="Function will apply atleast 1 UOM to all products and then the program volume is adjusted">
		<cfargument name="programID" required="true" />

		<cfstoredproc procedure="SP_DIVIDE_PROGRAM_VOLUME" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#arguments.programID#" null="no">
		</cfstoredproc>

	</cffunction>

	<!--- Distributing the program volume to the first n products --->
	<cffunction name="SplitProgVol" output="false" hint="Function will divide the program volume among the products in the group">
		<cfargument name="programID" required="true" />

		<cfstoredproc procedure="Group_Prods_Split_Calc" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#arguments.programID#" null="no">
		</cfstoredproc>

	</cffunction>


	<cffunction name="getProgramQty" output="false" hint="Function will return the total program volume in cases and pounds once volume is applied, specially usefull for groups">
		<cfargument name="programID" required="true" />
		<cfargument name="program_Span" required="true" />
		<cfargument name="VolumeUOTID" required="true" />
		<cfargument name="bidExcludeLostFromVolumeAuto" required="false" default="0" />

		<!--- Get the Weekly volume in Cases. The Program_Product_Volume table stores the weekly volume --->
		<cfquery name="getProductVolume" datasource="#application.datasource#">

			IF OBJECT_ID('tempdb..##tmp_pgm_prod_distinct_list') IS NOT NULL
			DROP TABLE ##tmp_pgm_prod_distinct_list

			SELECT	DISTINCT BSA_FoodService_Items_Master_ID
			INTO  	##tmp_pgm_prod_distinct_list
			FROM	CONTRACT_PRODUCTS
			WHERE 	Contract_Main_Id = '#arguments.programID#'
			AND     Deleted = 0


			SELECT	IsNull(Sum( Cast( IsNull( Volume_cs, 0 ) AS FLOAT) ), 0) As Program_Quantity_Cases,
					ISNULL(sum(ISNULL(CAST(volume_Lb as float),0)),0) As Program_Quantity_lbs,
					ISNULL(Sum( Cast( IsNull( Volume_cs, 0 ) * #arguments.program_Span# / 7 AS DECIMAL( 20, 0 )) ), 0) As Calculated_Quantity_Cases,
					ISNULL(Sum( Cast( Cast( IsNull( volume_Lb, 0 ) * #arguments.program_Span# / 7 AS DECIMAL( 20, 2 )) AS DECIMAL( 20, 0 )) ), 0) As Calculated_Quantity_Pounds
			FROM	Program_Product_Volume
					inner join ##tmp_pgm_prod_distinct_list cp on cp.BSA_FoodService_Items_Master_ID = Program_Product_Volume.BSA_FoodService_Items_Master_ID
			WHERE	Program_ID = '#arguments.programID#'
			AND		Program_Product_Volume.Deleted = 0
			AND		Program_Product_Volume.Is_Group = 0
			<!---
			SELECT IsNull(Sum( Cast( IsNull( Volume_cs, 0 ) AS FLOAT) ), 0) As Program_Quantity_Cases,    <!---312020--->
					ISNULL(sum(ISNULL(CAST(volume_Lb as float),0)),0) As Program_Quantity_lbs,
					ISNULL(Sum( Cast( IsNull( Volume_cs, 0 ) * #arguments.program_Span# / 7 AS DECIMAL( 20, 0 )) ), 0) As Calculated_Quantity_Cases  <!---31869 - use whole values to match with calculation on view volume & edit volume--->
			FROM 	Program_Product_Volume
			WHERE 	Program_ID = '#arguments.programID#'
			AND		Deleted = 0
			AND		Is_Group = 0
      AND EXISTS ( SELECT 1
                      FROM CONTRACT_PRODUCTS cp
                     WHERE cp.Contract_Main_Id = Program_Product_Volume.Program_Id
                           AND cp.Deleted = 0
                           AND cp.bsa_FoodService_Items_Master_Id = Program_Product_Volume.bsa_FoodService_Items_Master_Id )
			--->
			<cfif #arguments.bidExcludeLostFromVolumeAuto# eq 1>
				AND Program_Product_Volume.BSA_Foodservice_Items_Master_ID not in (
				SELECT  distinct   PROGRAM_PRODUCT_BID_INFO.PRODUCT_ID
				FROM	PROGRAM_BID_REQUEST
				INNER JOIN PROGRAM_PRODUCT_BID_INFO
				ON		PROGRAM_PRODUCT_BID_INFO.Program_ID = PROGRAM_BID_REQUEST.Program_ID
				AND		PROGRAM_PRODUCT_BID_INFO.WON =0 -- LOST ITEMS
				AND		PROGRAM_PRODUCT_BID_INFO.DELETED = 0
				WHERE	PROGRAM_BID_REQUEST.PROGRAM_ID = '#arguments.programID#'
				AND		PROGRAM_BID_REQUEST.BID_REQUEST_STATUS_ID != 1
				AND		PROGRAM_BID_REQUEST.Deleted = 0)
			</cfif>

			IF OBJECT_ID('tempdb..##tmp_pgm_prod_distinct_list') IS NOT NULL
			DROP TABLE ##tmp_pgm_prod_distinct_list

		</cfquery>

		<cfset ProgVolStruct = StructNew()>
		<cfset StructInsert(ProgVolStruct, "VolumeUOTCases", 0)>
		<cfset StructInsert(ProgVolStruct, "VolumeUOTlbs", 0)>
		<cfset StructInsert(ProgVolStruct, "ProgramQtgCases", 0)>
		<cfset StructInsert(ProgVolStruct, "ProgramQtglbs", 0)>

		<cfif getProductVolume.Program_Quantity_Cases neq 0>

			<!--- Convert the weekly volume into program volume --->
			<cfset Program_Qtg_Cases = getProductVolume.Calculated_Quantity_Cases>            <!---31869 use whole values--->
			<cfset Program_Qtg_lbs	 = getProductVolume.Calculated_Quantity_Pounds />

			<cfset Volume_UOT_Cases = 0>
			<cfset Volume_UOT_lbs = 0>

			<!--- Get the volume for various time periods --->

			<!--- volume for the program period span --->
				<cfif arguments.VolumeUOTID eq 1>
					<cfset Volume_UOT_Cases = Program_Qtg_Cases>
					<cfset Volume_UOT_lbs = Program_Qtg_lbs>

				<!--- daily volume --->
				<cfelseif arguments.VolumeUOTID eq 2>
					<cfset Volume_UOT_Cases = 	round(Program_Qtg_Cases/program_Span)>
					<cfset Volume_UOT_lbs 	=	round(Program_Qtg_lbs/program_Span)>

				<!--- weekly volume --->
				<cfelseif arguments.VolumeUOTID eq 3>
					<cfset Volume_UOT_Cases = 	round(getProductVolume.Program_Quantity_Cases)>
					<cfset Volume_UOT_lbs 	=	round(getProductVolume.Program_Quantity_lbs)>

				<!--- monthly volume --->
				<cfelseif arguments.VolumeUOTID eq 4>
					<cfset Volume_UOT_Cases = 	round((Program_Qtg_Cases/program_Span) * 30)>
					<cfset Volume_UOT_lbs 	=	round((Program_Qtg_lbs/program_Span) * 30)>

				<!--- quarterly volume --->
				<cfelseif arguments.VolumeUOTID eq 5>
					<cfset Volume_UOT_Cases = 	round((Program_Qtg_Cases/program_Span) * 90)>
					<cfset Volume_UOT_lbs 	=	round((Program_Qtg_lbs/program_Span) * 90)>

				<!--- annual volume --->
				<cfelseif arguments.VolumeUOTID eq 6>
					<cfset Volume_UOT_Cases = 	round((Program_Qtg_Cases/program_Span) * 365)>
					<cfset Volume_UOT_lbs 	= 	round((Program_Qtg_lbs/program_Span) * 365)>
				</cfif>

				<cfset ProgVolStruct.VolumeUOTCases = Volume_UOT_Cases>
				<cfset ProgVolStruct.VolumeUOTlbs =Volume_UOT_lbs>
				<cfset ProgVolStruct.ProgramQtgCases =Program_Qtg_Cases>
				<cfset ProgVolStruct.ProgramQtglbs =Program_Qtg_lbs>

		</cfif>
		<cfreturn ProgVolStruct>
	</cffunction>
	<!--- End Note: KAL; 8337 --->

<!--- D37069 :: View Programs - Cases and Dollars for all effective versions START --->
<cffunction name="getTotalProgramQty" output="false" hint="Function will return the total program volume in cases and pounds once volume is applied FOR ALL VERSIONS">
		<cfargument name="ContractNumber" required="true" />
		<cfargument name="VolumeUOTID" required="true" />
		<cfargument name="bidExcludeLostFromVolumeAuto" required="False" default="0" />
		<cfargument name="programID" required="False" default="0" />

		<cfquery name="getProductVolume" datasource="#application.datasource#">
				SELECT 	IsNull(Sum( Cast( IsNull( Volume_cs, 0 ) AS FLOAT) ), 0) As Program_Quantity_Cases,
								ISNULL(sum(ISNULL(CAST(volume_Lb as float),0)),0) As Program_Quantity_lbs,
								ISNULL(CAST(SUM(CAST((v.Volume_CS * CAST(DATEDIFF(D, CM.Effective_Start_Date, CM.Effective_End_Date) + 1 as decimal(20, 4)) / 7.00) as Decimal(20, 0))) as Decimal(20, 0)), 0) as Calculated_Quantity_Cases,
								ISNULL(CAST(SUM(CAST(CAST((v.Volume_LB * CAST(DATEDIFF(D, CM.Effective_Start_Date, CM.Effective_End_Date) + 1 as decimal(20, 4)) / 7.00) as Decimal(20, 2)) as Decimal(20, 0))) as Decimal(20, 0)), 0) as Calculated_Quantity_LB
				FROM  Contract_Main CM
				INNER JOIN Program_Product_Volume v
									ON          v.Program_ID = CM.Contract_Main_ID
									AND         v.Deleted = 0
									AND         v.Is_Group = 0
									AND         EXISTS (
																		SELECT      1
																		FROM  Contract_Products CP
																		WHERE CP.Contract_Main_ID = v.Program_ID
																		AND         CP.BSA_Foodservice_Items_Master_ID = v.BSA_Foodservice_Items_Master_ID
																		AND         CP.Deleted = 0
																)
				<cfif #arguments.bidExcludeLostFromVolumeAuto# eq 1>
				AND v.BSA_Foodservice_Items_Master_ID not in (
				SELECT  distinct   PROGRAM_PRODUCT_BID_INFO.PRODUCT_ID
				FROM	PROGRAM_BID_REQUEST
				INNER JOIN PROGRAM_PRODUCT_BID_INFO
				ON		PROGRAM_PRODUCT_BID_INFO.Program_ID = PROGRAM_BID_REQUEST.Program_ID
				AND		PROGRAM_PRODUCT_BID_INFO.WON =0 -- LOST ITEMS
				AND		PROGRAM_PRODUCT_BID_INFO.DELETED = 0
				WHERE	PROGRAM_BID_REQUEST.PROGRAM_ID = '#arguments.programID#'
				AND		PROGRAM_BID_REQUEST.BID_REQUEST_STATUS_ID != 1
				AND		PROGRAM_BID_REQUEST.Deleted = 0)
				</cfif>
				WHERE CM.Contract_Number = '#arguments.ContractNumber#'
				AND         CM.Approved = 1
				AND         CM.Effective_Start_Date IS NOT NULL
				GROUP BY CM.Contract_Number
		</cfquery>

		<cfset ProgTotalVolStruct = StructNew()>
		<cfset StructInsert(ProgTotalVolStruct, "VolumeUOTCases", 0)>
		<cfset StructInsert(ProgTotalVolStruct, "VolumeUOTlbs", 0)>
		<cfset StructInsert(ProgTotalVolStruct, "ProgramQtgCases", 0)>
		<cfset StructInsert(ProgTotalVolStruct, "ProgramQtglbs", 0)>

		<cfif getProductVolume.Program_Quantity_Cases neq 0 AND getProductVolume.recordcount>

			<!--- Convert the weekly volume into program volume --->
			<cfset Program_Qtg_Cases = getProductVolume.Calculated_Quantity_Cases>
			<cfset Program_Qtg_lbs	 = getProductVolume.Calculated_Quantity_LB>

			<cfset Volume_UOT_Cases = 0>
			<cfset Volume_UOT_lbs = 0>

			<!--- Get the volume for various time periods --->

			<!--- volume for the program period span --->
				<cfif arguments.VolumeUOTID eq 1>
					<cfset Volume_UOT_Cases = Program_Qtg_Cases>
					<cfset Volume_UOT_lbs = Program_Qtg_lbs>

				<!--- daily volume --->
				<cfelseif arguments.VolumeUOTID eq 2>
					<cfset Volume_UOT_Cases = 	round(Program_Qtg_Cases/program_Span)>
					<cfset Volume_UOT_lbs 	=	round(Program_Qtg_lbs/program_Span)>

				<!--- weekly volume --->
				<cfelseif arguments.VolumeUOTID eq 3>
					<cfset Volume_UOT_Cases = 	round(getProductVolume.Program_Quantity_Cases)>
					<cfset Volume_UOT_lbs 	=	round(getProductVolume.Program_Quantity_lbs)>

				<!--- monthly volume --->
				<cfelseif arguments.VolumeUOTID eq 4>
					<cfset Volume_UOT_Cases = 	round((Program_Qtg_Cases/program_Span) * 30)>
					<cfset Volume_UOT_lbs 	=	round((Program_Qtg_lbs/program_Span) * 30)>

				<!--- quarterly volume --->
				<cfelseif arguments.VolumeUOTID eq 5>
					<cfset Volume_UOT_Cases = 	round((Program_Qtg_Cases/program_Span) * 90)>
					<cfset Volume_UOT_lbs 	=	round((Program_Qtg_lbs/program_Span) * 90)>

				<!--- annual volume --->
				<cfelseif arguments.VolumeUOTID eq 6>
					<cfset Volume_UOT_Cases = 	round((Program_Qtg_Cases/program_Span) * 365)>
					<cfset Volume_UOT_lbs 	= 	round((Program_Qtg_lbs/program_Span) * 365)>
				</cfif>

				<cfset ProgTotalVolStruct.VolumeUOTCases = Volume_UOT_Cases>
				<cfset ProgTotalVolStruct.VolumeUOTlbs =Volume_UOT_lbs>
				<cfset ProgTotalVolStruct.ProgramQtgCases =Program_Qtg_Cases>
				<cfset ProgTotalVolStruct.ProgramQtglbs =Program_Qtg_lbs>

		</cfif>
		<cfreturn ProgTotalVolStruct>
	</cffunction>

	<cffunction name="getTotalTradeSpend" output="false" hint="Function will return the total trade spend FOR ALL VERSIONS" access="remote">
		<cfargument name="ContractNumber" required="true" />

		<cfquery name="getTradeSpend" datasource="#application.datasource#">
					SELECT      ISNULL(CAST(
												SUM(ISNULL(Program_Spend_Non_Lumpsum, 0))
												+
												SUM(ISNULL((CASE
																WHEN TradeSpend.Effective_End_Date = TradeSpend.Max_Effective_End_Date
																	THEN TradeSpend.Program_Spend_Lumpsum
																	ELSE 0
																END), 0))
												as DECIMAL(20, 2)),0) AS program_spend
					FROM  (
					            SELECT      CM.Effective_End_Date,
					                        Max_Effective_End_Date = MAX(CM.Effective_End_Date) OVER(PARTITION BY CM.Contract_Number),
					                        Program_Spend_Non_Lumpsum = (aux.Program_Spend_Non_Lumpsum
					                        *
					                        CAST(
					                        CAST(DATEDIFF(D, CM.Effective_Start_Date, CM.Effective_End_Date) + 1 as decimal(20, 4))
					                        / CAST(DATEDIFF(D, CM.Contract_Start_Date, CM.Contract_End_Date) + 1 as decimal(20, 4))
					                        as decimal(20, 4)
					                        )),
					                        aux.Program_Spend_Lumpsum
					            FROM  Contract_Main CM
					            INNER JOIN Contract_Main_Aux_Data aux
					            ON          aux.Contract_Main_ID = CM.Contract_Main_ID
					            WHERE CM.Contract_Number = '#arguments.ContractNumber#'
					            AND         CM.Approved = 1
					            AND         CM.Effective_Start_Date IS NOT NULL
					) as TradeSpend
		</cfquery>

			<cfreturn getTradeSpend>

	</cffunction>
	<!--- D37069 :: View Programs - Cases and Dollars for all effective versions END --->
</cfcomponent>