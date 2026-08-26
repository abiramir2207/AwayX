<!--- ----------------------------------------------------------------------------------------- --->
<CFPARAM NAME="content" DEFAULT='xxxxxxxxxxxxx'>
<CFPARAM NAME="primarycolor" DEFAULT='##ffa500'>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- unless it is uses a specific color, this will be it for the charts --->
<cfset primarycolor="##2d9dff">


<cfswitch expression="#content#">

    <cfcase value="27251464714966096215018589478188">
		<cfset page_name="Total Invoices Processed">
		<cfset data_field="invoices_processed_count">
	</cfcase>

    <cfcase value="45568534524436135648186757688533">
		<cfset page_name="Total Dollars Processed">
		<cfset data_field="dollars_processed_total">
	</cfcase>

    <cfcase value="83383662199107988683933154394379">
		<cfset page_name="Dollars Processed Off Invoice">
		<cfset data_field="dollars_processed_off_invoice">
	</cfcase>

    <cfcase value="44251709366036422873906987835441">
		<cfset page_name="Dollars Processed Billback">
		<cfset data_field="dollars_processed_billback">
	</cfcase>

    <cfcase value="64496065404382576131220545894677">
		<cfset page_name="Average Dollars per Billback">
		<cfset data_field="dollars_processed_avg_per_billback">
	</cfcase>

    <cfcase value="68992132496321383440838589234418">
		<cfset page_name="Average Number of Line Items per Billback">
		<cfset data_field="avg_count_items_per_invoice">
	</cfcase>


    <cfcase value="79276942499215024465167292390306">
		<cfset page_name="Discrepancy: Invoices with disprepancy >0">
		<cfset data_field="discrepancy_invoices">
	</cfcase>

    <cfcase value="52223300440575879209296854847383">
		<cfset page_name="Discrepancy:Total discrepancy dollars">
		<cfset data_field="discrepancy_total_dollars">
	</cfcase>

    <cfcase value="28058019805677983043027481003584">
		<cfset page_name="Discrepancy: Dollars as % of total billback dollars">
		<cfset data_field="discrepancy_dollars_as_percent">
	</cfcase>

    <cfcase value="96584561334820676041942072593055">
		<cfset page_name="Deduction days outstanding">
		<cfset data_field="deduction_days_outstanding">
	</cfcase>

    <cfcase value="14861127198521465868954826336496">
		<cfset page_name="Cycle Time - Created to Paid">
		<cfset data_field="cycle_time_created_to_paid">
	</cfcase>

    <cfcase value="85309939245394706795463161903757">
		<cfset page_name="Cycle Time - Performance End to Paid">
		<cfset data_field="cycle_time_end_to_paid">
	</cfcase>

    <cfcase value="28925981445625825062079391940251">
		<cfset page_name="Payment Type - Check">
		<cfset data_field="payment_type_check">
	</cfcase>

    <cfcase value="21014311315907368110293248688226">
		<cfset page_name="Payment Type - Deduction">
		<cfset data_field="payment_type_deduction">
	</cfcase>

    <cfcase value="23007111898819874628340698836933">
		<cfset page_name="Payment Type - AT">
		<cfset data_field="payment_type_at">
	</cfcase>

    <cfcase value="51971847421630836604852211730804">
		<cfset page_name="Entry Type - EDI">
		<cfset data_field="payment_type_at">
	</cfcase>

    <cfcase value="57400554671981952676017695668982">
		<cfset page_name="Entry Type - eInvoice">
		<cfset data_field="entry_type_einvoice">
	</cfcase>

    <cfcase value="46633024967030533087337972740629">
		<cfset page_name="Entry Type - Manual">
		<cfset data_field="entry_type_manual">
	</cfcase>

	
    <cfdefaultcase>
		<cfset page_name="Total Invoices Processed">
		<cfset data_field="invoices_processed_count">
		<cfset primarycolor="##ffa500">
	</cfdefaultcase>

</cfswitch>