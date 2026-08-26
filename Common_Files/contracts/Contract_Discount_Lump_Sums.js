/*
 * @author msaunders
 * 
 * 
 * 
 */

var componentManager = {
		  url: "/mvc/Models/Program/Component/ComponentManager.cfc",
		  type: "POST",
		  dataType: "json",
		  data: ""
		};

//SPINNER
jQuery('#spinner')
    .hide()  // hide it initially
    .ajaxStart(function() {
        //jQuery(this).show();
		jQuery(this).fadeIn(400);
    })
    .ajaxStop(function() {
        //jQuery(this).hide();
		jQuery(this).fadeOut(400);
    })
;

function calcPeriods(start,end){

	var lsAmount 		= jQuery("#amount_each_period").val();
	var PaymentCycle 	= jQuery("#PaymentCycle").val();
	var thisComp		= jQuery.extend(true,{},componentManager);
	var request			= '';
	
    if ( PaymentCycle != 0 ) {
		//set up properties for request
		var data = {method:'getPeriodCount', 
		  			startDate: start, 
					endDate: end, 
					paymenCycleId: PaymentCycle};
		
		thisComp.data = data;
		//make remote call to cf
		request = jQuery.ajax( thisComp );
		request.done(getPeriodCountDone);
		request.fail(getPeriodCountFail);
    }
	else{
		setPeriodCount(0);
	}
}

function setAmount(){
	var periodCount 	= jQuery("#periodCount").val();
	var lsAmount 		= jQuery("#amount_each_period").val();
	var PaymentCycle 	= jQuery("#PaymentCycle").val();
	//alert( "paycycle: " + PaymentCycle + ':: periodCount:' + periodCount);
	
	if(isNaN(parseFloat(periodCount)) || periodCount < 1){
		periodCount = 1;
	}
	 jQuery("#periodCount").val( periodCount );
	 jQuery("#div_periodCount").html( periodCount );
	 
	//set the total amount
	jQuery('#new_lump_sum_amount').val(lsAmount * periodCount);
	jQuery('#div_new_lump_sum_amount').html(lsAmount * periodCount);

}

/*29963 - Chris: Created this new function to update the form upon landing on the page & on change of claim mechanic*/
function fade_count_and_total() {
	if( jQuery("#Claim_Mechanics").val() > 0){
		var selectedClaimMech = jQuery("#Claim_Mechanics option:selected");
		var isAutoPay = selectedClaimMech.attr('id');
		//non-autopay only has 1 period
		if(isAutoPay == 0){
			//hide other fields
			jQuery("#tdCountDesc, #tdCountVal, #tdTotalDesc, #tdTotalVal, #help_small_1").fadeOut(400);
			jQuery("#amount_each").html("Amount");
		}
		else{
			jQuery("#tdCountDesc, #tdCountVal, #tdTotalDesc, #tdTotalVal, #help_small_1").slideDown(400);
			jQuery("#amount_each").html("Amount Each");
		}
	}
}
	
function setPeriodCount(count){
	if( jQuery("#Claim_Mechanics").val() > 0){
		var selectedClaimMech = jQuery("#Claim_Mechanics option:selected");
		var isAutoPay = selectedClaimMech.attr('id');
		//non-autopay only has 1 period
		if(isAutoPay == 0){
			count = 1;
		}
		fade_count_and_total();    /*29963*/
	}
	else{
		count = 1;
	}
	 jQuery("#periodCount").val( count );
	 jQuery("#div_periodCount").html( count );
	 //after the period changes we need to update the amount
	 setAmount();
}

function getPeriodCountDone(result) {
 	setPeriodCount(result);
}
function getPeriodCountFail(jqXHR, textStatus) {
 	alert( "Get Period Count calculation failed: " + textStatus );
	setPeriodCount(1);
}


