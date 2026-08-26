<!--
  * ====================================================================================================
  *    @File: \common_Files\contracts\layered_approval_include_T_js.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2018-06-15 06:42:29
  *
  * @Remarks: - This file supports margin_display_style of 'custom_t'
  *           - Changes made to this file would need to carry over to the other layered_approval_include_js.cfm
  *				( to support the other margin_display_style = 'blacksmith' )
  *
  *
  *
  * ====================================================================================================
-->
<cfinclude template="/common_files/dhx_windows.cfm">
<cfoutput>
	<cfparam name="form.product_group_level_id"   default="0">
	<cfparam name="form.product_group_level_list" default="">

	<form name="refresh" action="#cgi.http_url#" method="post">
		<input type="hidden" name="product_group_level_id"   value="#form.product_group_level_id#">
		<input type="hidden" name="product_group_level_list" value="#form.product_group_level_list#">
	</form>
</cfoutput>
<script src="/script/javascript/table2csv.js?d"></script>
<script>
let jsdebug = 0;   <!---  set this value to zero to turn off js debug console feature --->
let $j = jQuery.noConflict();
if (jsdebug) {
	console.clear();
}
getCSVData = function() {
	$j('input[name=csv_file_name]').val( <cfoutput>'#(url.verticalPNL neq "" ? "vertical_pnl_" : "margin_")#'</cfoutput>
																		 + Math.random().toString(36).slice(2)  // append an arbitrary unique substring
																		 + ".csv");

	let csv_value=$j('#tbl-container table, #tbl-container2 table, #GridView1, #GridView1Copy')
									.table2CSV( {  csvExclude: 'csvExclude'         // filter out elements with csvExclude class
													,delivery: 'value'        // popup, value
													<cfif url.verticalPNL eq "">
														,findTBODY: '> tbody > tr.csv'  // only select TR with ".csv" class
													<cfelse>
														,findTHEAD: "tr#GridView1HeaderCopy"
													</cfif>
		                          } );
	$j("#csv_text").val(csv_value);
	$j("#csv_form").submit();
}

<cfif url.verticalPNL neq "">         <!---  44017  --->
  function gridviewScroll() {
      let  gridWidth = $j(window).width() - 40
          ,gridHeight = $j(window).height() - 70;

      gridView1 = $j('#GridView1').gridviewScroll({
            width: gridWidth,
            height: gridHeight,
            railcolor: "#F0F0F0",
            barcolor: "#CDCDCD",
            barhovercolor: "#606060",
            bgcolor: "#F0F0F0",
            freezesize: 3,
            arrowsize: 30,
            varrowtopimg: "/Images/arrowvt.png",
            varrowbottomimg: "/Images/arrowvb.png",
            harrowleftimg: "/Images/arrowhl.png",
            harrowrightimg: "/Images/arrowhr.png",
            headerrowcount: 2,
            railsize: 16,
            barsize: 18
        });
  }

  $j('table').on('change', 'input', function() { $j(this).addClass('changed') });

  $j('input[type=text], input.numeric').forceNumeric();

	stringToNumeric = function( str ) {
		<!---  avoid JS error when expected parameter is not a string --->
		if ( typeof str !== 'string' )
			return 0;

		return numeral().unformat( str );
	};

  <!---  these functions are for elements on \common_files\contracts\layered_program_approval.cfm file --->
	/**************************************************************************
	***  CALCULATE WHAT-IF  ***************************************************
	***************************************************************************/
  let page_view = "<cfoutput>#(url.detail7 eq 'show' ? 'detail' : 'compact')#</cfoutput>";

  $j(document).ready(function(){

    numeral.defaultFormat('($0,0.0000)');  <!--- default to dollar format --->

	$j("#save_vertical_pnl").click(function(){
		show_loader("SAVING CHANGES, PLEASE WAIT...");
		$j('input[name=next_page_url]').val( document.URL );
      	$j("input[disabled=disabled]").removeAttr("disabled");
		$j("input.numeric").each(function(){
			/* locate old input hidden element */
			let old_input_name = "old_" + $j(this).attr("name");
			let old_input = $j("input[name=" + old_input_name + "]");
			/* compare old and new if no change was made remove them */
			if (numeral( $j(this).val() ).value() == numeral( old_input.val() ).value()) {
				$j(this)[0].removeAttribute("name");
				old_input[0].removeAttribute("name");
			}
		});
		dedupElements( "input" );
		$j("input[name=action]").val("save");
		$j('form[name=MyForm]').submit();
	});

	$j("#update_to_system_values").click(function(){
		show_loader("UPDATING, PLEASE WAIT...");
		$j('input[name=next_page_url]').val( document.URL );
      	$j("input[disabled=disabled]").removeAttr("disabled");
		$j("input.numeric").each(function(){
			/* locate old input hidden element */
			let old_input_name = "old_" + $j(this).attr("name");
			let old_input = $j("input[name=" + old_input_name + "]");
			$j(this)[0].removeAttribute("name");
			old_input[0].removeAttribute("name");
		});
		$j("input[name=action]").val("update_to_system_values");
		$j('form[name=MyForm]').submit();
	});

    $j('#save38').click(function(){
		$j('form[name=MyForm]').hide();
		noty( { text: "Saving data..."
		        ,layout:'topLeft'
		        ,type:'information'
		        ,killer:true
		      });

      	$j("input[name=action]").val("save");
      	$j("input[name=next_page_url]").val( document.URL );

      	<!--- need to enable read-only inputs to avoid event errors --->
      	$j("input[disabled=disabled]").removeAttr("disabled");
      	$j('form[name=MyForm]').submit();
    });

    $j('#calc38').click(function(){
      <!---  hide body to provide visual indication that calculation is taking place --->
      $j('body').hide();

      calculate();

      <!--- show body to provide visual indication that calculation is done --->
      $j('body').show(400);
    });    <!---  $('#calc38').click(function(){ --->

	<cfif url.verticalPNL eq '2'>
		calculate();
	</cfif>

	 gridviewScroll();

});

let dollarFormat2 = "($0,0.00)";

calculate = function() {
	<!---  count total number of non-group products --->
	let productsCount = 0;

	<cfif isDefined("getAllProductMargins") and isQuery(getAllProductMargins)>
		productsCount = <cfoutput>#getAllProductMargins.recordCount#</cfoutput>;
	</cfif>

	<!--- $j('th.prod82').each(function(){		productsCount++;	}); --->
	let avolume = 0, adisc = 0, anet_sales = 0, adisc_percent = 0, atrade = 0;
	let alist_price = 0, acost = 0, aamt_plus = 0;
	let aopr_inc = 0, acash_disc = 0;

	<!---
	// looping thru all products: the suffix in each element name for each product is the record number
	// for first product the element names are:
	//              cost_1, subcost_1 (class name because of multiple subcosts), disc_amount_1
	//             ,list_price_1, disc_percent_1, net_sales_1
	//             ,trade_1, amt_plus_1, opr_income_1, opr_margin_1
	--->
	for(let idx=1; idx <= productsCount; idx++) {
	   	/*********************
	  	**  COST  ************
	  	**********************/
		let cost = 0;
		<!---  calculate cost total based on individual subcosts with same suffix number --->
		$j('input[class~=subcost_' + idx + ']').each(function(){
				let subcost = stringToNumeric( $j(this).val() );
				cost       += +subcost;
			$j(this).val( numeral( subcost ).format() );
		});

		$j('#cost_' + idx).text( numeral(cost).format() );

		/***************
		**  DISCOUNT
		****************/
		let  olist_price     = $j('input[name=list_price_'  + idx + ']')
		    ,ofixed_price    = $j('input[name=fixed_price_' + idx + ']')
		    ,orebate         = $j('input[name=rebate_'      + idx + ']')
		    ,ogrowth         = $j('input[name=growth_'      + idx + ']')
		    ,olump_sum       = $j('input[name=lump_sum_'    + idx + ']')
		    ,otrade_cash_disc        = $j('input[name=trade_cash_disc_'        + idx + ']')
		    ,otrade_other_allowances = $j('input[name=trade_other_allowances_' + idx + ']')
		    ,odistributor_trade      = $j('input[name=distributor_trade_'      + idx + ']')
		    ,ocash_disc              = $j('input[name=cash_disc_'              + idx + ']')

		    ,list_price      = stringToNumeric( olist_price.val() )
		    ,fixed_price     = stringToNumeric( ofixed_price.val() )
		    ,rebate          = stringToNumeric( orebate.val() )
		    ,growth          = stringToNumeric( ogrowth.val() )
		    ,lump_sum        = stringToNumeric( olump_sum.val() )

		    ,trade_cash_disc        = stringToNumeric( otrade_cash_disc.val() )
		    ,trade_other_allowances = stringToNumeric( otrade_other_allowances.val() )
		    ,distributor_trade      = stringToNumeric( odistributor_trade.val() )
		    ,trade           = trade_cash_disc + trade_other_allowances + distributor_trade

		    ,cash_disc       = stringToNumeric( ocash_disc.val() )
		    ,disc_amount     = (fixed_price > 0 ? list_price - fixed_price : 0) + rebate + growth + lump_sum;

		olist_price.val( numeral(list_price).format() );
		ofixed_price.val( numeral(fixed_price).format() );
		orebate.val( numeral(rebate).format() );
		ogrowth.val( numeral(growth).format() );
		olump_sum.val( numeral(lump_sum).format() );

		otrade_cash_disc.val( numeral(trade_cash_disc).format() );
		otrade_other_allowances.val( numeral(trade_other_allowances).format() );
		odistributor_trade.val( numeral(distributor_trade).format() );

		ocash_disc.val( numeral(cash_disc).format() );

		<!--- on detail view all elements are displayed so we have to refresh with the calculated values --->
		if (page_view == "detail") {
			$j('#disc_' + idx).text( numeral(disc_amount).format() );
			$j('#trade_' + idx).text( numeral(trade).format() );
		}
		else {
			<!--- on compact view detail elements are not displayed so we have to override calculated values with values on the display --->
			disc_amount = stringToNumeric($j('#disc_' + idx).text());
			trade       = stringToNumeric($j('#trade_' + idx).text());
		}

		/***************
		**  DISCOUNT %
		****************/
		let disc_percent = (list_price == 0 ? 0 : ( disc_amount /  list_price ));
		$j('#disc_percent_' + idx).text( numeral(disc_percent).format('(0,.0%)') );

		/*********************
		**  NET SALES   ******
		**********************/
		let  amt_plus_obj = $j('input[name=amt_plus_' + idx + ']')
			,amt_plus     = stringToNumeric( amt_plus_obj.val() )
			,net_sales    = list_price - disc_amount - trade - amt_plus - cash_disc;

		$j('#net_sales_' + idx).text( numeral(net_sales).format( dollarFormat2 ) );

		amt_plus_obj.val( numeral(amt_plus).format() );

		/*********************
		**  OPR INCOME  ******
		**********************/
		let  opr_inc = net_sales - cost
		    ,opr_margin = (list_price == 0 ? 0 : opr_inc / list_price);

		$j('#opr_inc_' + idx).text( numeral(opr_inc).format( dollarFormat2 ) );
		$j('#opr_margin_' + idx).text( numeral(opr_margin).format('(0,%)') );

		/*************
		**  CSA ******
		**************/
		let uom_prefix  = ($j('input[name=cases_' + idx + '_Copy]').length ? 'cases_' : 'lbs_')
		   ,volume_obj  = $j('input[name=' + uom_prefix + idx + '_Copy]')   <!---  gridviewScroll changed the name of elements on 2nd row --->
		   ,volume      = stringToNumeric( volume_obj.val() )
		   ,csa         = disc_amount * volume;

		$j('#csa_' + idx).text( numeral(csa).format('($0,0') );
		$j('input[name=' + uom_prefix + idx + '_Copy]').val( numeral(volume).format('(0,0.00') );

		<!---  do not delete this debug section, just change the first value to 0 to turn off debug logic --->
		if (1 && idx == 1 && jsdebug) {
			console.log('product idx = ' + idx);
					console.log('      volume          = ' + numeral(volume).format('0,0.00') );
   					console.log('      list_price      = ' + numeral(list_price).format() );
   					console.log('      fixed_price     = ' + numeral(fixed_price).format() );
   					console.log('      rebate          = ' + numeral(rebate).format() );
   					console.log('      growth          = ' + numeral(growth).format() );
   					console.log('      lump_sum        = ' + numeral(lump_sum).format() );
   					console.log('      disc_amount     = ' + numeral(disc_amount).format() );
   					console.log('      disc_percent    = ' + disc_percent);

					console.log('      amt_plus        = ' + numeral(amt_plus).format() );
					console.log('      net_sales       = ' + numeral(net_sales).format() );
					console.log('      opr_inc         = ' + numeral(opr_inc).format() );
					console.log('      trade           = ' + numeral(trade).format() );
					console.log('      trade_cash_disc = ' + numeral(trade_cash_disc).format() );
					console.log('      trade_other_allowances = ' + numeral(trade_other_allowances).format() );

					console.log('      opr_margin   = ' + opr_margin);
					console.log('      csa          = ' + numeral(csa).format() );
		}
	}   <!---  for(let idx=0; idx < productsCount; idx++) --->

	<!---  count total number of group products --->
	let groupsCount = $j('th.grp82').length;

	<!---
	// ****************************************
	// PERFORM CALCULATIONS FOR GROUP PRODUCTS
	// **************************************** --->
	for(let idx=1; idx <= groupsCount; idx++) {

		let gvolume = 0, gdisc = 0, gnet_sales = 0, gdisc_percent = 0, gtrade = 0;
		let glist_price = 0, gcost = 0, gamt_plus = 0;
		let gopr_inc = 0, gcash_disc = 0;

		let uom_prefix = ($j('input.gcases_' + idx).length ? 'gcases_' : 'glbs_');

		$j('input.' + uom_prefix + idx).each(function(){
			<!---
			// ********************************************************************************************************
			// special handling: gridViewScroll() clones the elements on 2nd row, adds "_Copy" suffix to element names
			// ******************************************************************************************************** --->
			if ( $j.FindNoCase("_Copy", $j(this).attr("name") ) ) {
					let volume        = stringToNumeric( $j(this).val() );
					let name          = $j(this).attr("name");
					let record_number = $j.ListGetAt(name, 2, "_");
					let list_price    = $j('input[name=list_price_' + record_number + ']').val();
					let discount      = $j('#disc_' + record_number).text();
		  			let disc_percent  = $j('#disc_percent_' + record_number).text();
					let cost          = $j('#cost_' + record_number).text();
					let net_sales     = $j('#net_sales_' + record_number).text();
					let trade         = $j('#trade_' + record_number).text();
					let amt_plus      = $j('input[name=amt_plus_' + record_number + ']').val();
					let opr_inc       = $j('#opr_inc_' + record_number).text();
					let cash_disc     = $j('input[name=cash_disc_' + record_number + ']').val();

					<!---  keep track of totals for later group value calculations --->
					gvolume           += +volume;
					glist_price       += (volume * stringToNumeric(list_price));
					gdisc             += (volume * stringToNumeric(discount));
					gdisc_percent     += (volume * stringToNumeric(disc_percent));
					gtrade            += (volume * stringToNumeric(trade));
					gamt_plus         += (volume * stringToNumeric(amt_plus));
					gnet_sales        += (volume * stringToNumeric(net_sales));
					gcost             += (volume * stringToNumeric(cost));
					gopr_inc          += (volume * stringToNumeric(opr_inc));
					gcash_disc        += (volume * stringToNumeric(cash_disc));

					<!---  do not delete this debug section, just change the first value to 0 to turn off debug logic --->
		      if (1 && idx == 1 && jsdebug) {
		      	console.log('record_number = ' + record_number);
						console.log('      name         = ' + name );
						console.log('      volume       = ' + numeral(volume).format('0,0.00'));
						console.log('      gvolume      = ' + numeral(gvolume).format('0,0.00'));
						console.log('      list_price   = ' + list_price);
						console.log('      glist_price  = ' + numeral(glist_price).format());
						console.log('      discount     = ' + discount);
						console.log('      gdisc        = ' + numeral(gdisc).format());
						console.log('      disc_percent = ' + disc_percent);
						console.log('      gdisc_percent= ' + numeral(gdisc_percent).format());
						console.log('      trade        = ' + trade);
						console.log('      gtrade       = ' + numeral(gtrade).format());
						console.log('      amt_plus     = ' + amt_plus);
						console.log('      gamt_plus    = ' + numeral(gamt_plus).format());
						console.log('      net_sales    = ' + net_sales);
						console.log('      gnet_sales   = ' + numeral(gnet_sales).format());
						console.log('      cost         = ' + cost);
						console.log('      gcost        = ' + numeral(gcost).format());
						console.log('      opr_inc      = ' + opr_inc);
						console.log('      gopr_inc     = ' + numeral(gopr_inc).format());
		      }
			}    <!---  if ( $j.FindNoCase("_Copy", $j(this).attr("name") ) ) --->
		});    <!---  $j('input.gcases_' + idx).each(function(){ --->

		<!--- keep track of totals for summary calculations --->
		avolume       += gvolume;
		alist_price   += glist_price;
		adisc         += gdisc;
		acost         += gcost;
		anet_sales    += gnet_sales;
		adisc_percent += gdisc_percent;
		atrade        += gtrade;
		aamt_plus     += gamt_plus;
		aopr_inc      += gopr_inc;
		acash_disc    += gcash_disc;

	<!--- calculate group values based on group totals --->
		glist_price   = (gvolume == 0 ? 0 : glist_price   / gvolume);
		gdisc         = (gvolume == 0 ? 0 : gdisc         / gvolume);
		gcost         = (gvolume == 0 ? 0 : gcost         / gvolume);
		gnet_sales    = (gvolume == 0 ? 0 : gnet_sales    / gvolume);
		gdisc_percent = (gvolume == 0 ? 0 : gdisc_percent / gvolume);
		gtrade        = (gvolume == 0 ? 0 : gtrade        / gvolume);
		gamt_plus     = (gvolume == 0 ? 0 : gamt_plus     / gvolume);
		gopr_inc      = (gopr_inc   == 0 ? 0 : gopr_inc     / gvolume);
		gcash_disc    = (gcash_disc == 0 ? 0 : gcash_disc   / gvolume);

		<!---  do not delete this debug section, just change the first value to 0 to turn off debug logic --->
		if (0 && idx == 3 && jsdebug) {
			console.log('group idx = ' + idx);
					console.log('      gvolume       = ' + numeral(gvolume).format('0,0.00'));
					console.log('      glist_price  = ' + numeral(glist_price).format());
					console.log('      gdisc        = ' + numeral(gdisc).format());
					console.log('      gdisc_percent= ' + gdisc_percent);
					console.log('      gcost        = ' + numeral(gcost).format());
					console.log('      gnet_sales   = ' + numeral(gnet_sales).format());
					console.log('      gtrade       = ' + numeral(gtrade).format());
					console.log('      gamt_plus    = ' + numeral(gamt_plus).format());
					console.log('      gopr_inc     = ' + numeral(gopr_inc).format());
		}

		<!---
		// ********************************************************************************************************
		// special handling: gridViewScroll() adds div.GridCellDiv to first 2 rows in the body
		// ******************************************************************************************************** --->
		$j('#gcases_'        + idx + '  div.GridCellDiv').text( numeral(gvolume).format('(0,0.00') );
		$j('#glbs_'          + idx + '  div.GridCellDiv').text( numeral(gvolume).format('(0,0.00') );
		$j('#glist_price_'   + idx).text( numeral(glist_price).format() );

		$j('#gdisc_'         + idx).text( numeral(gdisc).format() );
		$j('#gdisc_percent_' + idx).text( numeral(gdisc_percent).format('(0,.0%)') );
		$j('#gcost_'         + idx).text( numeral(gcost).format() );
		$j('#gnet_sales_'    + idx).text( numeral(gnet_sales).format( dollarFormat2 ) );
		$j('#gtrade_'        + idx).text( numeral(gtrade).format() );
		$j('#gamt_plus_'     + idx).text( numeral(gamt_plus).format() );
		$j('#gopr_inc_'      + idx).text( numeral(gopr_inc).format( dollarFormat2 ) );

		let gopr_margin = (glist_price == 0 ? 0 : gopr_inc / glist_price);
		$j('#gopr_margin_'   + idx).text( numeral(gopr_margin).format('(0,%)') );

		let gcsa = gdisc * gvolume;
		$j('#gcsa_'          + idx).text( numeral(gcsa).format('($0,0') );

		$j('#gcash_disc_'    + idx).text( numeral(gcash_disc).format() );

		if (0 && jsdebug) {
			console.log('group idx = ' + idx);
					console.log('      avolume       = ' + numeral(avolume).format('0,0.00'));
					console.log('      alist_price  = ' + numeral(alist_price).format());
					console.log('      adisc        = ' + numeral(adisc).format());
					console.log('      adisc_percent= ' + gdisc_percent);
					console.log('      acost        = ' + numeral(acost).format());
					console.log('      anet_sales   = ' + numeral(anet_sales).format());
					console.log('      atrade       = ' + numeral(atrade).format());
					console.log('      aamt_plus    = ' + numeral(aamt_plus).format());
					console.log('      aopr_inc     = ' + numeral(aopr_inc).format());
		}
	}    <!---  for(let idx=1; idx <= groupsCount; idx++) { --->

	<!---
	// ********************************************************************************************************
	// SUMMARY VALUES
	// ********************************************************************************************************
	// special handling: gridViewScroll() adds div.GridCellDiv to first 2 rows in the body
	// ******************************************************************************************************** --->

	let sfmt = '($0,0)';

	$j('#acases  div.GridCellDiv').text( numeral(avolume).format('(0,0.00') );
	$j('#albs    div.GridCellDiv').text( numeral(avolume).format('(0,0.00') );
	$j('#alist_price').text( numeral(alist_price).format(sfmt) );

	let ulist_price = (avolume == 0 ? 0 : alist_price / avolume);
	$j('#ulist_price').text( numeral(ulist_price).format() );

	$j('#adisc').text( numeral(adisc).format(sfmt) );
	let udisc = (avolume == 0 ? 0 : adisc / avolume);
	$j('#udisc').text( numeral(udisc).format() );

	<!--- trade --->
	$j('#atrade').text( numeral(atrade).format(sfmt) );
	let utrade = (avolume == 0 ? 0 : atrade / avolume);
	$j('#utrade').text( numeral(utrade).format() );

	<!--- net sales --->
	$j('#anet_sales').text( numeral(anet_sales).format(sfmt) );
	let unet_sales = (avolume == 0 ? 0 : anet_sales / avolume);
	$j('#unet_sales').text( numeral(unet_sales).format() );

	<!--- cost --->
	$j('#acost').text( numeral(acost).format(sfmt) );
	let ucost = (avolume == 0 ? 0 : acost / avolume);
	$j('#ucost').text( numeral(ucost).format() );

	<!--- calculate summary values based on summary totals --->
	adisc_percent = (alist_price == 0 ? 0 : adisc / alist_price);

	$j('#adisc_percent').text( numeral(adisc_percent).format('(0,.0%)') );
	$j('#aamt_plus').text( numeral(aamt_plus).format(sfmt) );

	let aopr_margin = (alist_price == 0 ? 0 : aopr_inc / alist_price);

	$j('#aopr_inc').text( numeral(aopr_inc).format(sfmt) );

	let uopr_inc = (avolume == 0 ? 0 : aopr_inc / avolume);
	$j('#uopr_inc').text( numeral(uopr_inc).format() );

	$j('#aopr_margin').text( numeral(aopr_margin).format('(0,%)') );

	let acsa = adisc;
	$j('#acsa').text( numeral(acsa).format(sfmt) );

	$j('#acash_disc').text( numeral(acash_disc).format(sfmt) );
	let ucash_disc = (avolume == 0 ? 0 : acash_disc / avolume);
	$j('#ucash_disc').text( numeral(ucash_disc).format() );
};

	$j('#reset38').click(function() {
		$j('form[name=MyForm]').hide();

		noty( { text: "Resetting data..."
		        ,layout:'topLeft'
		        ,type:'information'
		        ,killer:true
		      });
      	$j("input[name=action]").val("reset");

		let newURL = <cfoutput>"/common_files/contracts/layered_margin_calculation.cfm?"
									+ "CID=#URL.CID#"
									+ "&duplicateprogram=0"
									+ "&MarginRequestAction="
									+ "&displayPreviousVersionMargin=0"
									+ "&margin_version=current"
									+ "&verticalPNL=#url.verticalPNL#"</cfoutput>;
      	$j("input[name=next_page_url]").val( newURL );

      	$j('form[name=MyForm]').submit();
	});

  $j('#close82').click(function() { window.close(); });
  $j('#export82').click(function() { getCSVData(); });

  $j('#showProducts').click(function() {
	$j('form[name=MyForm]').hide();
	noty( { text: "Processing..."
	        ,layout:'topLeft'
	        ,type:'information'
	        ,killer:true
	      });

  	<!--- remove previous show/hide parameter & append it back with an opposite value --->
  	let newURL = removeParam('showProducts', window.location.href) + '&showProducts=' + <cfoutput>'#(url.showProducts eq "1" ? "0" : "1")#'</cfoutput>;
  	    newURL = newURL.replace("#", "");

   	$j("input[name=action]").val("reset");
  	window.location = newURL;
  });


  $j('#moreless').click(function() {

	$j('form[name=MyForm]').hide();
	noty( { text: "Processing..."
	        ,layout:'topLeft'
	        ,type:'information'
	        ,killer:true
	      });

  	<!--- remove previous detail7 parameter & append it back with an opposite value --->
  	let newURL = removeParam('detail7', window.location.href) + '&detail7=' + <cfoutput>'#(url.detail7 eq "show" ? "hide" : "show")#'</cfoutput>;
  	    newURL = newURL.replace("#", "");

	<cfif url.verticalPNL eq '2'>
		$j('input[name=next_page_url]').val( newURL );
      	$j("input[disabled=disabled]").removeAttr("disabled");

		$j('form[name=MyForm]').submit();
	<cfelse>
		window.location = newURL;
	</cfif>
  });
  <!--- </cfsavecontent>  --->

	<!--- reduce white spaces in the above JS code & hide logic from nosy end-users --->
	<!--- <cfoutput>#application.util.string.compress( variables.jsContent )#</cfoutput> --->

	function removeParam(key, sourceURL) { //remove a pair of URL parameter key & URL paramater value from a query string
    let rtn = sourceURL.split("?")[0],
        param,
        params_arr = [],
        queryString = (sourceURL.indexOf("?") !== -1) ? sourceURL.split("?")[1] : "";
    if (queryString !== "") {
        params_arr = queryString.split("&");
        for (let i = params_arr.length - 1; i >= 0; i -= 1) {
            param = params_arr[i].split("=")[0];
            if (param === key) {
                params_arr.splice(i, 1);
            }
        }
        rtn = rtn + "?" + params_arr.join("&");
    }
    return rtn;
	}

  function displayComponentCostDetails( product_id ) {
    <cfoutput> NewWindow('Contract_Trade_Analysis.cfm'
    	                     + '?ItemId=' + product_id
    	                     + '&CID=#URL.CID#'
    	                     + '&margin_type=1&TPA_TYPE=1', 'componentcostdetails', '800', '600', 'Yes', 'Yes'); </cfoutput>
  }
</cfif>

<!--- display notification messages at the bottom --->
<cfoutput>
<cfloop from="1" to="#arrayLen(variables.noty.Message)#" index="variables.idx">
    <cfif len(variables.noty.Message[ variables.idx ])>
      noty( { text: "<cfoutput>#variables.noty.Message[ variables.idx ]#</cfoutput>"
              ,type:'information'
              <cfif variables.noty.timeout[ variables.idx ] gt 0>
                  ,timeout: #variables.noty.timeout[ variables.idx ]#
              </cfif>
              ,layout:'bottom'
              ,closeWith: ['click']
            });
    </cfif>
</cfloop>
</cfoutput>

<cfif url.verticalPNL eq "2">
	$j('textarea[name=whatif_notes]').maxlength( {max:1000} );
</cfif>

function submitMarginForm()
{
	$j('form[name=MyForm]').fadeOut(350);

	<cfoutput>
	let newURL = "layered_approval_include.cfm?groupCheckStatusChange=1"
	                        + "&CID=#URL.CID#"
	                        + "&duplicateprogram=#duplicateprogram#"
							+ "&verticalPNL=#url.verticalPNL#"
							+ "&showProducts=#url.showProducts#"
							+ "&detail7=#url.detail7#"
							+ "&fixed_type=#url.fixed_type#"
                            <cfif isDefined("MarginCalculatedDate")>
                            	+ "&MarginCalculatedDate=#MarginCalculatedDate#"
                            </cfif>;
	</cfoutput>

	<cfif url.verticalPNL eq "">
		$j('form[name=MyForm]').attr("action", newURL);

	<cfelseif url.verticalPNL eq "1">
		noty( { text: "Processing..."
		        ,layout:'topLeft'
		        ,type:'information'
		        ,killer:true
		      });
		$j('form[name=MyForm]').attr("action", newURL);

	<cfelseif url.verticalPNL eq "2">
		noty( { text: "Processing..."
		        ,layout:'topLeft'
		        ,type:'information'
		        ,killer:true
		      });
   		$j("input[name=action]").val("apply all");
		$j('input[name=next_page_url]').val( newURL );
	</cfif>

   	$j("input[disabled=disabled]").removeAttr("disabled");
	MyForm.submit();
}

function verticalPNL( pClass ) {
  popupCenterByPercentages( '/common_files/contracts/contract_profit_analysis.cfm'
		                    + '?verticalPNL=' + pClass
		                    + '&CID=<cfoutput>#URL.CID#</cfoutput>'
		                    + '&displayPreviousVersionMargin=0'
		                    + '&margin_version=current',
		                    'verticalPNL' + pClass,
							90, 90);
}

function refresh() {
	show_loader("PROCESSING, PLEASE WAIT...");
	$j("form[name=refresh]").submit();
}

let previous_level_id = $j("select[name=product_group_level_id]").val();

$j("#apply_groups").click(function(){
	let current_level_id = $j("select[name=product_group_level_id]").val();
	let $level_list = $j("input[name=product_group_level_list]");
	/* update the hidden form element */
	$j("input[name=product_group_level_id]").val( current_level_id );

	if (current_level_id == '0') {
		/* default product level was selected - clear out its level list */
		$level_list.val('');
		refresh();
	}
	else {
		/* reset level list when level id is changed */
        if (current_level_id !== previous_level_id) {
			$level_list.val('');
		}
		previous_level_id = current_level_id;
		let selection_text = $j("select[name=product_group_level_id]").find("option:selected").text();
		dhx_popupInCenter( "/programs/product_groups.cfm?"
								+ "program_id=<cfoutput>#contract_main_id#</cfoutput>"
								+ "&product_group_level_id=" + current_level_id
								+ "&product_group_level_list=" + $level_list.val()
								+ "&text=" + selection_text
							,"Select " + selection_text
							, 500, 600 );
	};
});

function tpa_operator( product_id ) {
	product_id = product_id.replace(/-/g, "_");
	NewWindow('Contract_Trade_Analysis.cfm'
							+ '?ItemId=' + product_id
							+ <cfoutput>'&CID=#URL.CID#'</cfoutput>
							+ '&margin_type=1'
							+ '&TPA_TYPE=0'
							+ '&operator=1', 'componentcostdetails', '800', '600', 'Yes', 'Yes');
}

function tpa_distributor( product_id ) {
	product_id = product_id.replace(/-/g, "_");
	NewWindow('Contract_Trade_Analysis.cfm'
							+ '?ItemId=' + product_id
							+ <cfoutput>'&CID=#URL.CID#'</cfoutput>
							+ '&margin_type=1'
							+ '&TPA_TYPE=0'
							+ '&operator=0', 'componentcostdetails', '800', '600', 'Yes', 'Yes');
}
</script>
