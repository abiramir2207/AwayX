// ActionScript file
/* Sets text items to their default state */
	   private function format_date_type(datevalue:Date):String
	   {
	     return datevalue.getMonth() + 1 +'/'+datevalue.getDate()+'/'+datevalue.getFullYear();
	   }
	   
	   private function setLabels():void {
		lwProgramNum.text = "LW Program No: ";
		baProgramNum.text = "BA Program No: ";
		progEffDate.text =  "Program Eff Date: ";
		desc.text = "Description: ";
		payToNum.text = "Pay To No: ";
		progEndDate.text = "Program End Date: ";
		payName.text = "Pay To Name: ";
		dist.text = "Distributor: ";
		shipToNum.text = "Ship-To No: ";
		destination.text = "Destination: ";
		stateLbl.text = "St: ";
		corpPgm.text = "Corp PGM: ";
		deductAutosF.text = "Deduct Autos From F: ";
		deduct.text = "Deduct Autos?: ";
		broker.text = "Broker: ";
		brokerNum.text = "Broker No: ";
		pullback.text = "Auto Pullback: ";
		msgTxt.text = "";
		casesTotal.text = "0";
		extAmtTotal.text = "0";
		revisedDate.text = "Revised Date: ";
		// itemTotaltxt.text = "Item Total: ";
		Less_Corp_Allow.headerText = "Less Corp Allow";
		Less_Local_Allow.headerText = "Less Local Allow";			
       }
       
       	private function fillLabels(grid:mx.controls.DataGrid):void {
	     setLabels();
         lwProgramNum.text += grid.selectedItem.Program_Number;
	     baProgramNum.text += grid.selectedItem.Ba_Id;
	     progEffDate.text +=  grid.selectedItem.BeginDate;
	     desc.text += grid.selectedItem.Desc_Number;
	     payToNum.text += grid.selectedItem.PayTo_Num;
	     progEndDate.text += grid.selectedItem.EndDate;
	     payName.text += grid.selectedItem.PayTo_Name;
	     dist.text += grid.selectedItem.Cust_Name;
	     shipToNum.text += grid.selectedItem.Ship_Num;
	     destination.text += grid.selectedItem.Address;
	     stateLbl.text += grid.selectedItem.State;
	     corpPgm.text += grid.selectedItem.Program_Type;
	     deductAutosF.text += grid.selectedItem.Autos_Fixed;
	     deduct.text += grid.selectedItem.Autos_Deduct;
	     broker.text += grid.selectedItem.Broker_Name;
	     brokerNum.text += grid.selectedItem.Broker_Id;
	     pullback.text += grid.selectedItem.Autos_Pullback;
	     revisedDate.text += grid.selectedItem.Sent_Date;

		
		 if (grid.selectedItem.Autos_Deduct == 'P') {
			 Less_Corp_Allow.headerText = "Pull Corp Allow";
			 Less_Local_Allow.headerText = "Pull Local Allow";			
		 }
		 
	     
	     //if (grid.selectedItem.Claim_Date_From != undefined) {claimDateFrom.text = grid.selectedItem.Claim_Date_From; claimDateFromVis.text = grid.selectedItem.Claim_Date_From;}
	     //if (grid.selectedItem.Claim_Date_To != undefined){claimDateTo.text = grid.selectedItem.Claim_Date_To; claimDateToVis.text = grid.selectedItem.Claim_Date_To;}
	     if (grid.selectedItem.Claim_Date_From != undefined) {claimDateFromVis.text = grid.selectedItem.Claim_Date_From;}
	     if (grid.selectedItem.Claim_Date_To != undefined){claimDateToVis.text = grid.selectedItem.Claim_Date_To;}
	     if (grid.selectedItem.Claim_Amt != undefined){amt.text = basicCurrencyFormat.format(grid.selectedItem.Claim_Amt);}   
	     if (grid.selectedItem.casesClaimed != undefined){claimed.text = grid.selectedItem.casesClaimed;}
	     if (grid.selectedItem.Inv_Ref_Num != undefined) {inv.text = grid.selectedItem.Inv_Ref_Num;}
	     //if (grid.selectedItem.Broker_Rcv_Date != undefined) {brkrRecDate.text = grid.selectedItem.Broker_Rcv_Date; brkrRecDateVis.text = grid.selectedItem.Broker_Rcv_Date;}
	     //if (grid.selectedItem.Inv_Date != undefined){invDate.text = grid.selectedItem.Inv_Date; invDateVis.text = grid.selectedItem.Inv_Date;}
	     if (grid.selectedItem.Broker_Rcv_Date != undefined) {brkrRecDateVis.text = grid.selectedItem.Broker_Rcv_Date;}
	     if (grid.selectedItem.Inv_Date != undefined){invDateVis.text = grid.selectedItem.Inv_Date;}
	     else {resetForm();}
	     backToBlack();
        }
        
        private function resetForm():void {
    		  bsProgNum.text = "";
    		  lwProgNum.text = "";
    		  programName.text = "";
    		  shiptoNumTxt.text = "";
    		  distributor.text = "";
    		  dateRange1.text = "";
    		  dateRange2.text = "";
    	 
    	 //if (claimDateFrom.text != "") {claimDateFrom.text = ""; claimDateFromVis.text = "";}
    	 //if (claimDateTo.text != "") {claimDateTo.text = ""; claimDateToVis.text = "";}
    	 if (claimDateFromVis.text != "") {claimDateFromVis.text = "";}
    	 if (claimDateToVis.text != "") {claimDateToVis.text = "";}
    	 if (amt.text != "") amt.text = "";
    	 if (inv.text != "") inv.text = "";
    	 //if (brkrRecDate.text != "") {brkrRecDate.text = ""; brkrRecDateVis.text = "";}
    	 //if (invDate.text != "") {invDate.text = ""; invDateVis.text = "";}
    	 if (brkrRecDateVis.text != "") {brkrRecDateVis.text = "";}
    	 if (invDateVis.text != "") {invDateVis.text = "";}
    	 
    	 if (claimed.text != "") claimed.text = "";
       }