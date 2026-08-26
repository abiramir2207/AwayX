		Non_Contract_Unlocking_Destination = new Array();
		Non_Contract_Unlocking_Destination[0] = "contract_edit_menu.cfm";
		Non_Contract_Unlocking_Destination[Non_Contract_Unlocking_Destination.length] = "contract_create_1_form.cfm";
		Non_Contract_Unlocking_Destination[Non_Contract_Unlocking_Destination.length] = "select_operators.cfm";
		Non_Contract_Unlocking_Destination[Non_Contract_Unlocking_Destination.length] = "select_brokers.cfm";					
		Non_Contract_Unlocking_Destination[Non_Contract_Unlocking_Destination.length] = "select_distributors.cfm";					
		Non_Contract_Unlocking_Destination[Non_Contract_Unlocking_Destination.length] = "contract_discount_fixed_prices.cfm";					
		Non_Contract_Unlocking_Destination[Non_Contract_Unlocking_Destination.length] = "contract_discount_rebates.cfm";					
		Non_Contract_Unlocking_Destination[Non_Contract_Unlocking_Destination.length] = "contract_discount_lump_sums.cfm";					
		Non_Contract_Unlocking_Destination[Non_Contract_Unlocking_Destination.length] = "contract_discount_growth.cfm";
		Non_Contract_Unlocking_Destination[Non_Contract_Unlocking_Destination.length] = "queries.cfm";
		Non_Contract_Unlocking_Destination[Non_Contract_Unlocking_Destination.length] = "product_select_V1.cfm";
		Non_Contract_Unlocking_Destination[Non_Contract_Unlocking_Destination.length] = "Contract_Discount_Fixed_Prices_Action.cfm";
		Non_Contract_Unlocking_Destination[Non_Contract_Unlocking_Destination.length] = "Contract_Discount_Rebates_Action.cfm";
		Non_Contract_Unlocking_Destination[Non_Contract_Unlocking_Destination.length] = "Contract_Discount_Lump_Sums_Save_New_Lump_Sum.cfm";
		Non_Contract_Unlocking_Destination[Non_Contract_Unlocking_Destination.length] = "Contract_Discount_Lump_Sums_Delete.cfm";
		Non_Contract_Unlocking_Destination[Non_Contract_Unlocking_Destination.length] = "Contract_Discount_Lump_Sums_Save_Products.cfm";
		Non_Contract_Unlocking_Destination[Non_Contract_Unlocking_Destination.length] = "contract_fax_create.cfm";
		Non_Contract_Unlocking_Destination[Non_Contract_Unlocking_Destination.length] = "view_contract_history.cfm";
		Non_Contract_Unlocking_Destination[Non_Contract_Unlocking_Destination.length] = "contract_email_send.cfm";
		Non_Contract_Unlocking_Destination[Non_Contract_Unlocking_Destination.length] = "contract_approve_broker_action.cfm";
		
	
		window.nextURL = "EMPTY";
		
		function shouldProgramUnlock() {
			authorizedFile = 0;
			if(window.nextURL != "EMPTY"){
				for(var x=0; x < Non_Contract_Unlocking_Destination.length; x++) {
					if(Non_Contract_Unlocking_Destination[x].toLowerCase() == window.nextURL.toLowerCase()) {
						authorizedFile = 1
					}
				}
			} // end if
			else{
				/*
				if(window.thisURL != null && window.nextURL == "NONE"){
					for(var x=0; x < Non_Contract_Unlocking_Destination.length; x++) {
						if(Non_Contract_Unlocking_Destination[x].toLowerCase() == window.thisURL.toLowerCase()) {
							authorizedFile = 1
						}
					}
				}
				*/
			}


			//if(authorizedFile == 0) window.status = "I would Unlock it now"
			//if(authorizedFile == 0) alert("UNLOCK")
		}
