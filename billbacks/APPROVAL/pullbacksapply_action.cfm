<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<cfparam name="form.Dis_BB_Id" default="">
<cfparam name="form.pullback_billback_ids" default="">
<cfparam name="form.unapplypullbacks" default="0">
<cfparam name="form.pullback_billback_growth_ids" default="">

<cfquery name="CheckIfSplit" datasource="#application.datasource#">
	SELECT *
	FROM Billback 
	WHERE Billback_ID = <cfqueryparam value="#form.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>

<CFIF form.Dis_BB_Id NEQ "" and (form.pullback_billback_growth_ids NEQ "" or form.pullback_billback_ids NEQ "")>
		<cfquery name="getDisBBcontractnumber" datasource="#application.datasource#">
				select contract_number
				from billback 
				inner join billback_program on billback_program.billback_id = billback.billback_id 
				inner join contract_main on contract_main.contract_main_id = billback_program.program_id 
				where billback.billback_id = <cfqueryparam value="#form.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<CFTRANSACTION ACTION="Begin">
			
		<cfquery name="updatebillbacknpullbacklogtable" datasource="#application.datasource#">
								declare @totalpullbackamount decimal(20, 4),
								@rebatecompcount int
								SET @totalpullbackamount = 0
								SET @rebatecompcount = 0
								
								<!--- If there are mutliple components added to the current Dis corp BB, we need to distribute the pullback amount evenly among the components in the pullback log table, so get the number of rebate componets in this BB --->
								<!--- Duplicate netry in pullback log table handle below, thus don't need rebate componetn count check
								select @rebatecompcount = count(*) 
								from	Billback_Program_Rebate_Component
								where billback_id = <CFIF CheckIfSplit.BB_Is_Child EQ 1><cfqueryparam value="#CheckIfSplit.BB_Parent_ID#" cfsqltype="CF_SQL_VARCHAR"><CFELSE><cfqueryparam value="#form.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR"></CFIF>
								and deleted = 0
								and Billback_Program_Rebate_Component.checked = 'true'
								 --->
		
				<CFIF form.pullback_billback_ids NEQ "">
						<CFLOOP  list="#form.pullback_billback_ids#" index="thisBB">
							<cfset pullback_BB_Id = Left(thisBB,36) />
							<cfset Pullback_Discount_Id = Mid(thisBB,38,1) />
							<cfset Pullback_BB_Product_Id = Mid(thisBB,40,36) />
							<cfset Pullback_BB_Customer_Id = Mid(thisBB,40+37,36) />
							<cfset PullbackAmount = "form.pullback_billback_#replace(thisBB,'-','_','ALL')#_amount" />
							<cfset PullbackRate = "form.pullback_billback_#replace(thisBB,'-','_','ALL')#_rate" />
							<cfset BudgetRecaptureAmount = "form.pullback_billback_#replace(thisBB,'-','_','ALL')#_budget" />
							
							<CFIF form.unapplypullbacks eq 0>
								<cfset PullbackVolume = evaluate("form.pullback_billback_#replace(thisBB,'-','_','ALL')#_volume") />
								<cfif PullbackVolume eq 0><!--- avoid divide by zero error --->
									<cfset PullbackVolume = 1 />
								</cfif>
							</CFIF>
		
							
						<!--- Sum up the pullback amount for each product in the loop --->
						<!--- SET @totalpullbackamount = @totalpullbackamount + #evaluate(PullbackAmount)# --->
					
							<!--- if you applying the pullbacks, update the pullback log table with current Dis Corp BB id for the selected pullback line items and the pullbackamount and the rate at which it is calculated. ---> 
							<CFIF form.unapplypullbacks eq 0>
										update pullbacks_log
										set pullback_applied = 1,
										pullback_applied_to_billback_id = '#form.Dis_BB_Id#',
										pullback_applied_by = '#request.AccessStructure.user_id#',
										pullback_applied_date = getdate(),
										pullback_expected_dollars = cast(#evaluate(PullbackAmount)# * cast(Product_BB_Volume_LB as decimal(20, 2)) / #PullbackVolume# as decimal(20, 2)),
										pullback_from_program_rate = #evaluate(PullbackRate)#,
										Budget_Recapture_Amount = cast(#evaluate(BudgetRecaptureAmount)# * cast(Product_BB_Volume_LB as decimal(20, 2)) / #PullbackVolume# as decimal(20, 2))
										from pullbacks_log 
										<!--- if the discount type is rebate, the pullback amount is distributed evenly on the selected components of this BB --->
										<CFIF Pullback_Discount_Id EQ 2>
										inner join Billback_Program_Rebate_Component on
										Billback_Program_Rebate_Component.billback_id = <CFIF CheckIfSplit.BB_Is_Child EQ 1>'#CheckIfSplit.BB_Parent_ID#'<CFELSE>'#form.Dis_BB_Id#'</CFIF>
										and pullbacks_log.component_id = Billback_Program_Rebate_Component.Program_Rebates_Component_name_id
										and Billback_Program_Rebate_Component.deleted = 0
										and Billback_Program_Rebate_Component.checked = 'true'
										</CFIF>
										where pullbacks_log.pullback_billback_id = '#pullback_BB_Id#'
										and pullbacks_log.product_id = '#Pullback_BB_Product_Id#'
										and pullbacks_log.customer_id = '#Pullback_BB_Customer_Id#'
										and pullbacks_log.pullback_from_program_number = '#getDisBBcontractnumber.contract_number#'
										and pullbacks_log.discount_type_id = '#Pullback_Discount_Id#'
										and pullbacks_log.deleted = 0
										and pullbacks_log.pullback_applied = 0
										<!--- 
										if you are unapplying the pullback, remove the Dis Corp Id and pulback amount dollars for the applied pullbacks --->
							<CFELSE>
										update pullbacks_log
										set pullback_applied = 0,
										pullback_applied_to_billback_id = NULL,
										pullback_unapplied_by = '#request.AccessStructure.user_id#',
										pullback_unapplied_date = getdate(),
										pullback_expected_dollars = 0,
										pullback_from_program_rate = 0
										from pullbacks_log 
										<CFIF Pullback_Discount_Id EQ 2>
												inner join Billback_Program_Rebate_Component on
												Billback_Program_Rebate_Component.billback_id = <CFIF CheckIfSplit.BB_Is_Child EQ 1>'#CheckIfSplit.BB_Parent_ID#'<CFELSE>'#form.Dis_BB_Id#'</CFIF>
												and pullbacks_log.component_id = Billback_Program_Rebate_Component.Program_Rebates_Component_name_id
												and Billback_Program_Rebate_Component.deleted = 0
												and Billback_Program_Rebate_Component.checked = 'true'
										</CFIF>
									where pullbacks_log.pullback_billback_id = '#pullback_BB_Id#'
									and pullbacks_log.product_id = '#Pullback_BB_Product_Id#'
									and pullbacks_log.customer_id = '#Pullback_BB_Customer_Id#'
									and pullbacks_log.pullback_from_program_number = '#getDisBBcontractnumber.contract_number#'
									and pullbacks_log.discount_type_id = '#Pullback_Discount_Id#'
									and pullback_applied_to_billback_id = '#form.Dis_BB_Id#'
									and pullbacks_log.deleted = 0
									and pullbacks_log.pullback_applied = 1
							</CFIF> 
						</CFLOOP>
					</CFIF>
		
		<!--- Growth Calulation is done seperatley. The growth amount is distributed using volume weighted avg calcucation for all the available items on this BB --->
					<CFIF form.pullback_billback_growth_ids NEQ "">
						<CFLOOP  list="#form.pullback_billback_growth_ids#" index="thisGrowthBB">
									<cfset PullbackGrowthAmount = "form.growthamount_#replace(thisGrowthBB,'-','_','ALL')#" />
									<cfset PullbackGrowthVolume = "form.growthvolume_#replace(thisGrowthBB,'-','_','ALL')#" />
									
									<!--- SET @totalpullbackamount = @totalpullbackamount + #evaluate(PullbackGrowthAmount)# --->
									
									<CFIF form.unapplypullbacks eq 0>
											update pullbacks_log
											set pullback_applied = 1,
											pullback_applied_to_billback_id = <cfqueryparam value="#form.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">,
											pullback_applied_by = <cfqueryparam value="#request.AccessStructure.user_id#" cfsqltype="CF_SQL_VARCHAR">,
											pullback_applied_date = getdate(),
											pullback_expected_dollars = isnull((((product_BB_volume_LB * isnull(pullback_percent,0))/100) * #evaluate(PullbackGrowthAmount)#)/#evaluate(PullbackGrowthVolume)#,0)
											from pullbacks_log 
											inner join billback_product on
											billback_product.billback_id = <CFIF CheckIfSplit.BB_Is_Child EQ 1><cfqueryparam value="#CheckIfSplit.BB_Parent_ID#" cfsqltype="CF_SQL_VARCHAR"><CFELSE><cfqueryparam value="#form.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR"></CFIF>
											and billback_product.product_id = pullbacks_log.product_id
											inner join billback_product_detail on
											billback_product_detail.billback_product_id = billback_product.billback_product_id
											and billback_product_detail.BB_product_type_id = pullbacks_log.discount_type_id 
											where
											pullbacks_log.pullback_billback_id = <cfqueryparam value="#thisGrowthBB#" cfsqltype="CF_SQL_VARCHAR">
											and pullbacks_log.pullback_from_program_number = <cfqueryparam value="#getDisBBcontractnumber.contract_number#" cfsqltype="CF_SQL_VARCHAR">
											and pullbacks_log.discount_type_id = 4
											and pullbacks_log.deleted = 0
											and pullbacks_log.pullback_applied = 0
									
									<CFELSE>
										
											update pullbacks_log
											set pullback_applied = 0,
											pullback_applied_to_billback_id = NULL,
											pullback_unapplied_by = '#request.AccessStructure.user_id#',
											pullback_unapplied_date = getdate(),
											pullback_expected_dollars = 0,
											pullback_from_program_rate = 0
											from pullbacks_log 
											inner join billback_product on
											billback_product.billback_id = <CFIF CheckIfSplit.BB_Is_Child EQ 1><cfqueryparam value="#CheckIfSplit.BB_Parent_ID#" cfsqltype="CF_SQL_VARCHAR"><CFELSE><cfqueryparam value="#form.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR"></CFIF>
											and billback_product.product_id = pullbacks_log.product_id
											inner join billback_product_detail on
											billback_product_detail.billback_product_id = billback_product.billback_product_id
											and billback_product_detail.BB_product_type_id = pullbacks_log.discount_type_id 
											where
											pullbacks_log.pullback_billback_id = <cfqueryparam value="#thisGrowthBB#" cfsqltype="CF_SQL_VARCHAR">
											and pullbacks_log.pullback_from_program_number = <cfqueryparam value="#getDisBBcontractnumber.contract_number#" cfsqltype="CF_SQL_VARCHAR">
											and pullbacks_log.discount_type_id = 4
											and pullback_applied_to_billback_id = <cfqueryparam value="#form.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
											and pullbacks_log.deleted = 0
											and pullbacks_log.pullback_applied = 1
											
									</CFIF>
						</CFLOOP>
					</CFIF>
				
					declare @distributorcount int
					<!--- check if this BB has any pullbacks applied --->
					select 	@distributorcount = count(*),
							@totalpullbackamount = ISNULL(SUM(Pullback_Expected_Dollars), 0)
					from pullbacks_log
					where pullback_applied_to_billback_id = <cfqueryparam value="#form.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
					and deleted = 0
					and pullback_applied = 1
					
					set @totalpullbackamount = isnull(@totalpullbackamount, 0)
		
		<!--- if you are applying the pullbacks, subtract the pullback amount from the paid amount and save the pullback amount --->
					<CFIF form.unapplypullbacks eq 0>
							update BB_Approved
							set Approved_Amount_Before_Pullbacks = case when ISNULL(Approved_Amount_Before_Pullbacks,0) = 0 then paid_amount else Approved_Amount_Before_Pullbacks end,
							Pullback_applied_Amount = @totalpullbackamount,
							paid_amount = case when ISNULL(Approved_Amount_Before_Pullbacks,0) = 0 then paid_amount else Approved_Amount_Before_Pullbacks end - @totalpullbackamount,
							BB_pullbacks_applied = 1
							where BB_Approved.Billback_ID = '#form.Dis_BB_Id#'
					<CFELSE>
							update BB_Approved
							set Pullback_applied_Amount = @totalpullbackamount,
							paid_amount = case when ISNULL(Approved_Amount_Before_Pullbacks,0) = 0 then paid_amount else Approved_Amount_Before_Pullbacks end - @totalpullbackamount,
							BB_pullbacks_applied = case when @distributorcount > 0 then 1 else 0 end
							where BB_Approved.Billback_ID = '#form.Dis_BB_Id#'
					</CFIF>
		
					<CFIF CheckIfSplit.BB_Is_Child EQ 1>
					
					<!--- Find pullback for all splits --->
					select 	@distributorcount = count(*),
							@totalpullbackamount = ISNULL(SUM(Pullback_Expected_Dollars), 0)
					from pullbacks_log
					where pullback_applied_to_billback_id in (select billback_id from billback where deleted = 0 and BB_Parent_ID = '#CheckIfSplit.BB_Parent_ID#')
					and deleted = 0
					and pullback_applied = 1
					
					set @totalpullbackamount = isnull(@totalpullbackamount, 0)
					
					<CFIF form.unapplypullbacks eq 0>
							update BB_Approved
							set Approved_Amount_Before_Pullbacks = case when ISNULL(Approved_Amount_Before_Pullbacks,0) = 0 then paid_amount else Approved_Amount_Before_Pullbacks end,
							Pullback_applied_Amount = @totalpullbackamount,
							paid_amount = case when ISNULL(Approved_Amount_Before_Pullbacks,0) = 0 then paid_amount else Approved_Amount_Before_Pullbacks end - @totalpullbackamount,
							BB_pullbacks_applied = 1
							where BB_Approved.Billback_ID = <cfqueryparam value="#CheckIfSplit.BB_Parent_ID#" cfsqltype="CF_SQL_VARCHAR">
					<CFELSE>
							update BB_Approved
							set Pullback_applied_Amount = @totalpullbackamount,
							paid_amount = case when ISNULL(Approved_Amount_Before_Pullbacks,0) = 0 then paid_amount else Approved_Amount_Before_Pullbacks end - @totalpullbackamount,
							BB_pullbacks_applied = case when @distributorcount > 0 then 1 else 0 end
							where BB_Approved.Billback_ID = <cfqueryparam value="#CheckIfSplit.BB_Parent_ID#" cfsqltype="CF_SQL_VARCHAR">
					</CFIF>
					</CFIF>

		</cfquery>
		
			<CFQUERY NAME="DeletePre" DATASOURCE="#Application.Datasource#">
				UPDATE BB_AllowanceCode_Allocation 
				SET Deleted = 1 
				WHERE Billback_ID = <cfqueryparam value="#form.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
			</CFQUERY>
			
			<CFQUERY NAME="DelPre" DATASOURCE="#Application.Datasource#">
				UPDATE BB_AllowanceCode_Allocation_Summary 
				SET Deleted = 1 
				WHERE Billback_ID = <cfqueryparam value="#form.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
			</CFQUERY>

	<!--- D35392: GM Pullback Log entries--->	
			<CFQUERY NAME="GetBBReportID" DATASOURCE="#Application.Datasource#">	
				SELECT BB_Auto_Report_ID 
				FROM BB_Auto_Program_Pay_Period
				WHERE Billback_ID = <cfqueryparam value="#form.Dis_BB_Id#" cfsqltype="CF_SQL_VARCHAR">
				AND Deleted = 0
			</CFQUERY>

<cfstoredproc procedure="BB_Auto_Report_Extract_PullBack_Reload" datasource="#application.datasource#">
	<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER " dbVarName = "@BB_Auto_Report_ID" value = "#GetBBReportID.BB_Auto_Report_ID#" null="no">
	<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR " dbVarName = "@Billback_ID" value = "#form.Dis_BB_Id#" null="no">
</cfstoredproc> 	
	<!--- D35392: GM Pullback Log entries--->
			
		<CFTRANSACTION action = "commit">
			
		</CFTRANSACTION>

		<CFIF NOT ISDefined("FORM.ForSplitRemovePullBack")>
				<SCRIPT>
					opener.location.reload(true);
					self.close();
				</SCRIPT>
		<CFELSE>
				<SCRIPT>
					window.location.href = "Split_BB.cfm?Billback_ID=<CFOUTPUT>#Dis_BB_Id#</CFOUTPUT>";
				</SCRIPT>
		</CFIF>

<CFELSE>
		Invalid Billback ID. Pullbacks Not applied.
</CFIF>
