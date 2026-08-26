<cfcomponent>
<!--- Get all the list of distributors from the current Opr or Local Dis program to apply pullbacks, if pullbacks are already applied, check pullback_details table to get the pullback values --->
	<cffunction name="getpulllbacksapplied" output="false">
		<cfquery name="qgetpulllbacksapplied" datasource="Mccain">
		select distinct name,shr_ship_to,item,description,pullback_percent,
		pullback_from_program_rate,product_BB_volume_LB,
		Isnull(pullback_expected_dollars,0) as pullback_expected_dollars,
		ISNULL(BB_approved.Approved_Amount_Before_Pullbacks,0) as
		Approved_Amount_Before_Pullbacks,
		ISNULL(BB_approved.Pullback_applied_Amount,0) as
		total_pullbackamount_applied,
		ISNULL(BB_approved.paid_amount,0) as paid_amount 
		,contract_number,contract_title,contract_start_date,
		contract_end_date,dis_BB.BB_title as dis_BB_title, dis_BB.BB_code
		as dis_BB_code, dis_BB.BB_reference as dis_BB_reference,
		dis_BB.bb_start_date as dis_bb_start_date,dis_BB.bb_end_date as dis_bb_end_date,opr_BB.BB_title as opr_BB_title, opr_BB.BB_code as opr_BB_code, 
		opr_BB.BB_reference as opr_BB_reference, opr_BB.bb_start_date as opr_bb_start_date,opr_BB.bb_end_date as opr_bb_end_date,discount_type_desc,
		pullbacks_log.customer_id,
		pullback_applied_to_billback_id,pullback_billback_id
		from pullbacks_log
		inner join bsa_foodservice_customers on
		bsa_foodservice_customers.bsa_foodservice_customers_id = 
		pullbacks_log.customer_id
		inner join bsa_foodservice_items_master on 
		bsa_foodservice_items_master.bsa_foodservice_items_master_id = 
		pullbacks_log.product_id
		inner join contract_main on 
		contract_main.contract_number = pullbacks_log.pullback_from_program_number
		inner join billback dis_BB on dis_BB.billback_id = pullbacks_log.pullback_applied_to_billback_id
		inner join BB_approved on BB_approved.billback_id = dis_BB.billback_id
		inner join billback opr_BB on opr_BB.billback_id = pullbacks_log.pullback_billback_id
		inner join discount_type on discount_type.discount_type_id = 
		pullbacks_log.discount_type_id
		where pullback_applied = 1
		and pullbacks_log.deleted = 0
		order by name,shr_ship_to
		</cfquery>
		<cfreturn qgetpulllbacksapplied />
	</cffunction>
	
	<cffunction name="getpulllbacksunapplied" output="false">
		<cfquery name="qgetpulllbacksunapplied" datasource="Mccain">
		select distinct name,shr_ship_to,item,description,pullback_percent,
		pullback_from_program_rate,product_BB_volume_LB,
		Isnull(pullback_expected_dollars,0) as pullback_expected_dollars,
		contract_number,contract_title,contract_start_date,
		contract_end_date,opr_BB.BB_title as opr_BB_title, 
		opr_BB.BB_code as opr_BB_code, pullback_program_number,
		opr_BB.BB_reference as opr_BB_reference, opr_BB.bb_start_date as opr_bb_start_date,opr_BB.bb_end_date as opr_bb_end_date,discount_type_desc,
		pullbacks_log.customer_id,pullback_from_program_number,
		pullback_applied_to_billback_id,pullback_billback_id
		from pullbacks_log
		inner join bsa_foodservice_customers on
		bsa_foodservice_customers.bsa_foodservice_customers_id = 
		pullbacks_log.customer_id
		inner join bsa_foodservice_items_master on 
		bsa_foodservice_items_master.bsa_foodservice_items_master_id = 
		pullbacks_log.product_id
		inner join contract_main on 
		contract_main.contract_number = pullbacks_log.pullback_from_program_number
		inner join billback opr_BB on opr_BB.billback_id = pullbacks_log.pullback_billback_id
		inner join discount_type on discount_type.discount_type_id = 
		pullbacks_log.discount_type_id
		where pullback_applied = 0
		and pullbacks_log.deleted = 0
		order by name desc,shr_ship_to,pullback_from_program_number
		</cfquery>
		<cfreturn qgetpulllbacksunapplied />
	</cffunction>
</cfcomponent> 