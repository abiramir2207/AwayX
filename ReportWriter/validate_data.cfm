<cfoutput>
<script language="javascript">
		/* This function accepts two arguments:
				a) Type of interval (days,months etc) 
				b) The number of days, months etc 	
			It then returns the appropriate date.		
		*/
		Date.prototype.add = function (sInterval, iNum)
		{
				var dTemp = this;
				if (!sInterval || iNum == 0) return dTemp;
				switch (sInterval.toLowerCase()){
				case "ms":
				dTemp.setMilliseconds(dTemp.getMilliseconds() + iNum);
				break;
				case "s":
				dTemp.setSeconds(dTemp.getSeconds() + iNum);
				break;
				case "mi":
				dTemp.setMinutes(dTemp.getMinutes() + iNum);
				break;
				case "h":
				dTemp.setHours(dTemp.getHours() + iNum);
				break;
				case "d":
				dTemp.setDate(dTemp.getDate() + iNum);
				break;
				case "mo":
				dTemp.setMonth(dTemp.getMonth() + iNum);
				break;
				case "y":
				dTemp.setFullYear(dTemp.getFullYear() + iNum);
				break;
		}
				return dTemp;
		}

function ValidateDaysOfHistoricalData(SubmitForm)
{
	var DaysOfHistoricalData = #val(application.oApplicationAppSettingsManager.getApplicationAppSettings().getDaysOfHistoricalDataForSpecialPriceList())#
	var DaysOfFutureData = #val(application.oApplicationAppSettingsManager.getApplicationAppSettings().getMaxFutureDaysForClaimRatesORPricingExtract())#
	var current_date = new Date();
	var report_type = 0;
	var Error = 0;
	var CheckSelectedProgram = 0;
	var errors = [];
	report_type = #report_type#;

	var d1 = new Date(document.frmDates.EffectiveDate.value);
	var chkInactive = document.frmDates.chkIncInactive.checked;

	var m = d1.getMonth() + 1;
	var d = d1.getDate();
	var y = d1.getFullYear();

	var cm = current_date.getMonth() + 1;
	var cd = current_date.getDate();
	var cy = current_date.getFullYear();

	var Effective_date_No_Time = new Date(m + '/' + d + '/' + y);
	var current_date_No_Time = new Date(cm + '/' + cd + '/' + cy);

		
	if(document.frmDates.EffectiveDate.value == ''){
		errors.push("You forgot to enter the effective date");
	}
	if (chkInactive)
	{
		document.frmDates.includeInactive.value = 1;
	}
	else
	{
		document.frmDates.includeInactive.value = 0;
	}

	/* For Pricing Report, we cannot enter date in the past */
	if(report_type == 2){
		if(Effective_date_No_Time < current_date_No_Time)
		{
			errors.push("You cannot enter a date in the past for the pricing report");
		}
	}

	var d2 = current_date.add("d", -DaysOfHistoricalData); // get days in the past for historical data
	current_date = new Date();
	var d3 = current_date.add("d", DaysOfFutureData); // get the date which is x days in the future

	/* For Claim Rates Report, we cannot enter date more than X days in the past */
	if(report_type == 1){
		if(d2 > d1)
		{
			errors.push("Effective date provided exceeds limit on past dating - You cannot enter a date beyond " + DaysOfHistoricalData + " days in the past for the claim rates report");
		}
	}


	if(d1 > d3)
	{
		errors.push("Effective date provided exceeds limit on future dating - You cannot enter a date beyond " + DaysOfFutureData + " days in the future");
	}
	
	/* The user should select at least one program. This is applicable only when the user selects multiple
		 programs from the program search result.
		*/
	if ( $('input[name=program_id_list]:not(:hidden)').length == 0) {
		errors.push("There is no program selection available.");
	}
	else if (document.frmDates.program_id_list) {
			if(document.frmDates.program_id_list.length > 1){
				for(i=0;i<= document.frmDates.program_id_list.length-1; i++){
					if(document.frmDates.program_id_list[i].checked){
						CheckSelectedProgram = 1;
						break;
					}
				}
			}
			else{
					if(document.frmDates.program_id_list.checked){
						CheckSelectedProgram = 1;
					}
			}

			if(document.frmDates.program_id_list.type != 'hidden'){
					if(CheckSelectedProgram == 0){
						errors.push("You forgot to select at least one program");
					}
				}
	}

  if ( $("##report_config_id").val() == '' ) {
  	errors.push("You forgot to select a report setting.");
  }
  
		if ( errors.length ){
				alert( errors.join("\n") + "\n\nPlease make the corrections and try again." );
				return false;
	  }
		else {
			mydatagrid.fnFilter('');
			if(SubmitForm == 1){
				frmDates.submit();
			}
		}

}	
/* Removed it because the code was being validated even before the date got formatted by EASYDATE
	if(document.getElementById('EffectiveDate')){
		document.frmDates.EffectiveDate.onchange=new Function ("ValidateDaysOfHistoricalData(0);");
	}
*/
</script>
</cfoutput>
