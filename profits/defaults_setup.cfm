<!-------------------- Added By Deepa ----------------------------------------->

<!-----<CFLOOP INDEX="i" FROM="1" TO="#struct_profit_rule_name.aa_comm_number#">
	<CFPARAM NAME="struct_profit_rule_name.sample_size_#i#" DEFAULT="0">
	<CFPARAM NAME="struct_profit_rule_name.point_in_time_#i#" DEFAULT="0">
	
	<CFLOOP INDEX="j" FROM="1" TO="4">
		<CFIF evaluate("struct_profit_rule_name.compounded_amount_calc#j#_#i#") EQ "">
			<CFSET evaluate("struct_profit_rule_name.compounded_amount_calc#j#_#i#=0")>
		</CFIF>
		
		<CFIF evaluate("struct_profit_rule_name.independent_amount_calc#j#_#i#") EQ "">
			<CFSET evaluate("struct_profit_rule_name.independent_amount_calc#j#_#i#=0")>
		</CFIF>
	</CFLOOP>

</CFLOOP>------->

	<CFLOOP INDEX="j" FROM="1" TO="4">
	
		<CFPARAM NAME="Form.final_compounded_amount_calc#j#" DEFAULT="0">
		<CFPARAM NAME="Form.final_compounded_amount_uom#j#" DEFAULT="$">
		
		<CFPARAM NAME="Form.final_independent_amount_calc#j#" DEFAULT="0">
		<CFPARAM NAME="Form.final_independent_amount_uom#j#" DEFAULT="$">
		
		<CFIF evaluate("Form.final_compounded_amount_calc#j#") EQ "">
			<CFSET evaluate("Form.final_compounded_amount_calc#j#=0")>
		</CFIF> 
		<CFIF evaluate("Form.final_independent_amount_calc#j#") EQ "">
			<CFSET evaluate("Form.final_independent_amount_calc#j#=0")>
		</CFIF> 
	</CFLOOP>


<!-------------------- End Added By Deepa ----------------------------------------->