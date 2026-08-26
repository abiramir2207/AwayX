<!--
  * ====================================================================================================
  *  @Author: Chris Nguyen
  *    @Date: 2018-03-16 12:00:04
  *
  * @Remarks: A collection of JavaScript functions that are operated using database settings
  *
  * ====================================================================================================
-->

<script>
function multi_select( dropdowns ) {
	// returns a dropdowns selector that can use multiselect() plugin, excludes large dropdowns due to performance problems
	//
	// dropdowns input parameter is an array of jquery selectors
	// 			e.g. <select id="corp_parent"> </select>  <select id="operator"> </select>
	//
	//					multi_select( [ "#corp_parent", "#operator" ] ).multiselect();
	//
	var jquery_selects = [],
		// pull an optional limit of number of options in select dropdown from database - this limit is only updatable by developers
		select_max_options_for_jquery = <cfoutput>#val(application.util.query.get_Setting("select_max_options_for_jquery", false))#</cfoutput>;

	// setting is not defined use a default limit of 1,000 options
	if (select_max_options_for_jquery == 0)
		select_max_options_for_jquery = 1000;

	for (var i = 0; i <= dropdowns.length; i++) {
		// insert dropdowns with a feasible number of options into an array
		if ($(dropdowns[i] + " option").length < select_max_options_for_jquery)
			jquery_selects.push( dropdowns[i] );
	}

	// combine all elements in the array and pass the list back
	return jquery_selects.join(",");
}
</script>
