
	function reset_Form_Fields(filter_id)
	{	//filter_id: 1-invoice, 2-distributor, 3-product, 4-broker
		if(confirm("Are you sure you want to reset these search criteria?")) 
		{
			switch (filter_id) {
				case 1:		
						resetCheckBox("history_period");
						break;
				case 2:
						resetSelect("Family_Name");
						resetSelect("Buying_Group");
						resetSelect("Zone_ID");
						resetSelect("Region_ID");
						resetInput("Ship_To");
						//resetSelect("Line_Of_Biz");
						//resetSelect("Broker");
						//resetSelect("Distributor_Status");
						//resetSelect("State");
						//resetSelect("sort_by");
						//resetSelect("sort_Order");
						//resetInput("searchstring");
						break;
				case 3:
						//resetSelect("Q_Brand_ID");
						resetSelect("Type_Group_Desc_ID");
						resetSelect("Type_Code_Desc_ID");
						resetInput("item_number");
						//resetSelect("Brand_ID");
						//resetSelect("Product_Line_Of_Biz");
						//resetSelect("Product_Status");
						//resetSelect("product_sort_by");
						//resetSelect("product_sort_Order");

						//resetInput("upc_number");
						//resetInput("description_string");
						break;
				case 4:
						resetSelect("Broker_Zone_ID");
						resetSelect("Broker_Region_ID");
						resetSelect("Broker_Line_Of_Biz");
						resetSelect("Broker_Status");
						resetSelect("broker_sort_by");	
						resetSelect("broker_sort_Order");	
						resetInput("broker_searchstring");
						break;
			} 
		}
	}
	
	function resetCheckBox(selName)
	{
		var sObj = document.all.item(selName);
		for (var i=1; i < sObj.length; i++)
		{
			sObj[i].checked = true;
		}
	}
	
	function resetSelect(selName)
	{
		var sObj = document.getElementById(selName);
		if(sObj)
		{
			sObj.selectedIndex = 0;
			sObj.fireEvent('onchange');
		}
		else
		{
			alert("The element about to be reset is either null or empty object");
		}
	}
	
	function resetInput(inputName)
	{
		var sObj = document.getElementById(inputName);
		if(sObj)
		{
			sObj.value = "";
			sObj.fireEvent('onchange');
		}
		else
		{
			alert("The element about to be reset is either null or empty object");
		}
	}
	
	function saveInvoiceReport(thisForm)
	{	
		//thisForm.action = reportSaveActionPage;
			//thisForm.submit();
		//return true;
		var allClear = true;
		//check report name
		if(isSpace(thisForm.rName.value))
		{
			queueMessage("Report Name is a required field", document.all.error_ReportName);
			allClear = false;
		}
		else
		{
			clearQueue(document.all.error_ReportName);
		}
		//////////////////////////////////////////////////////////////
		////check start time and end time
		var dTrue = true;
		var daysDiff = 0;
		//////////////check start time
		if(!validateDate(thisForm.rvStartDate.value))
		{
			queueMessage("Start Date is not correct", document.all.error_Start_Date);
			dTrue = false;
			allClear = false;
		}
		else if((daysDiff=days_less(makeDate(thisForm.rvStartDate.value),thisDate)) < 0)
		{
			queueMessage("Start Date should be greater than or equal to Current Date", document.all.error_Start_Date);
			allClear = false;
		}
		else
		{
			clearQueue(document.all.error_Start_Date);
		}
		
		if(thisForm.rInterval.selectedIndex == 0)
		{
			dTrue = false;
		}
		else if(!validateDate(thisForm.rvEndDate.value))
		{
			queueMessage("End Date is not correct", document.all.error_End_Date);
			dTrue = false;
			allClear = false;
		}
		
		if(dTrue)
		{
			if(days_less(makeDate(thisForm.rvEndDate.value),makeDate(thisForm.rvStartDate.value)) < 0)
			{
				queueMessage("End Date should be greater than or equal to Start Date", document.all.error_End_Date);
				allClear = false;
			}
			else
			{
				clearQueue(document.all.error_End_Date);
			}
		}
		//////////////end check start time
		
		if(daysDiff == 0)
		{
			var selectedTime = getMilitaryTime(thisForm.rStartTime.value);
			var aSelectedTime = selectedTime.split(":");
			var aThisTime = thisTime.split(":");
			if(checkTimelessThan(aThisTime,aSelectedTime))
			{			
				clearQueue(document.all.error_Start_Time);
			}
			else
			{
				queueMessage("Time should be greater than should be greater than " + thisTime + " if you select Start Date as " + thisDate, document.all.error_Start_Time);
				allClear = false;
			}
		}
		
		/////////////////////////////////////////////////
		
		
		////////////////////////////////////////////
		///check email address
		var validEmailAdd = checkMultipleEmail(thisForm.rEmailAddress);
		if(validEmailAdd!=true)
		{
			queueMessage("Invalid Email Address '" + validEmailAdd + "'", document.all.error_Email_Address);
			allClear = false;
		}
		else if(thisForm.rEmailAddress.value.length >= 3000)
		{
			queueMessage("Email Address exceeds available size limit", document.all.error_Email_Address);
			allClear = false;
		}
		else
		{
			clearQueue(document.all.error_Email_Address);
		}
		if(allClear)
		{
			var oldAction = thisForm.action;
			thisForm.action = reportInvoiceSaveActionPage;
			thisForm.submit();		
			thisForm.action = oldAction;
			return;
		}
		else
		{
			showMessageWindow();				
		}
	}
