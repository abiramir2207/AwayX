/**
 * This is the Manager which sets all the data and settings that will be used 
 * in the application. 
 */
package com.Billback.Deviation.models
{
	import com.Billback.Deviation.components.StringUtils;
	import com.Billback.Deviation.events.*;
	import com.Billback.Deviation.views.*;
	import com.Billback.Deviation.vos.GridData;
	import com.Billback.Deviation.vos.Settings;
	import com.Billback.Main.events.BBMainEvent;
	import com.Billback.Main.models.vos.BBHeader;
	import com.asfusion.mate.events.Dispatcher;
	import com.shared.vos.Settings;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.*;
	import flash.net.SharedObject;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.formatters.NumberBaseRoundType;
	import mx.formatters.NumberFormatter;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectProxy;
	import mx.utils.ObjectUtil;
 	
 	/**
 	* This class sets all the data and settings that will be used 
 	* in the application. 
 	*/
	public class BBMainManager extends EventDispatcher 
	{
		
		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher;
		public function BBMainManager( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		/*-.........................................Properties..........................................*/
		/* local references for combo box arrays and item AC */
		private var _acBBData:ArrayCollection  = new ArrayCollection();
		private var _settings:com.Billback.Deviation.vos.Settings 	= new com.Billback.Deviation.vos.Settings();
	//	private var _reDirector:String = 'EDIT';
		
		private var _nTotClaimed:Number 			 = 0;
		private var _nTotExpected:Number 			 = 0;
		private var _nTotExpectedLT:Number 		 = 0;
		private var _nTotApproved:Number 			 = 0;
		private var _nTotalDeviation:Number 	 = 0;
		 
		private var nFormatter:NumberFormatter = new NumberFormatter();
		
		/*.................sharedSettings......................*/
		public var sharedSettings:com.shared.vos.Settings = new com.shared.vos.Settings();
		/*-.........................................Setters and Getters..........................................*/
		
		/**
		* This getter function returns an Object:_acBBData of type ArrayCollection
		*/  		
		[Bindable (event="evtDataChanged")]
		public function get acBBData():ArrayCollection
		{
			return _acBBData;
		}

		
		/**
		* This setter function sets an Object:_settings of type Settings
		*/  
		public function set settings(s:com.Billback.Deviation.vos.Settings):void 
		{
			this._settings = s;
		}

		/**
		* This getter function returns an Object:_settings of type Settings
		*/  		
		public function get settings():com.Billback.Deviation.vos.Settings 
		{
			return _settings;
		}
		
		/*... redirecotor to detect if the [val] was clicked on the BBSearch .....*/		
		/*[Bindable (event="bbRedirectorChanged")]
		public function get reDirector():String
		{
			return _reDirector;
		}
		public function set reDirector(reDirector:String):void
		{
			this._reDirector = reDirector;
			dispatchEvent(new Event('bbRedirectorChanged'));			
		}	*/
		
		/*................. bbHeader ......................*/
		private var _bbHeader:BBHeader;
		[Bindable (event="bbHeaderChanged")]
		public function get bbHeader():BBHeader
		{
			return _bbHeader;
		}
		public function set bbHeader(bbh:BBHeader):void
		{
			this._bbHeader = bbh;
			dispatchEvent(new Event('bbHeaderChanged'));
		}
		
		//setter for event map to use
		public function setBBHeader(event:MainEvent):void{
			this.bbHeader = event.bbHeader;
		}
 		
		/*-.........................................Methods..........................................*/
		/* itemresutls() gets called on application load.  we pass results from db to this method */ 
 
 /** 
 * RoundDecimals() function hadles the problem with rounding
 * Eg: when we had a value like xxx.905 instead of returning
 * xxx.91 the rounding function returned xxx.9 hence we had to handle 
 * this scenario in this function.
 */
	
	public function RoundDecimals(theNumber:Number):Number
	{
 		var strNumber:String  = theNumber.toString();
 		var nNumber:Number 		= theNumber;
 		var iPointPos:Number 	= strNumber.indexOf("."); // or "," if the floating point is a coma
   	var chrToCheck:String = strNumber.substr(iPointPos+3,1);
   	var chrAfter3:String 	= strNumber.substr(iPointPos+4,4);
   	
   	/* 
   		if the iPointPos is not -1 that means there is a decimal place in the number 
  	 	Process the number only then else return the number as it is.
  	*/ 
  	if (iPointPos != -1)
  	{
	   	// check to see if the character starting at 4th place and beyond are all 9
	   	// if so add a .001 if the value was .025 and got changed to .02499999999 then this will be corrected here. 	   	
	   	if (chrAfter3 == "9999")
	   	{
	   		nNumber = Number(strNumber) + .001;
	   	}
	   	strNumber = strNumber.substr(0, iPointPos + 4); // pickup till 3 places from the decimal
	    // check to see if the third decimal after . is a 5 if so add 1
	 	  if ((chrToCheck == "5"))
			{
	     	nNumber = Number(strNumber) + .001;
			}
	 		nNumber = Math.round((Number(nNumber))*Math.pow(10,2))/Math.pow(10,2);
  	}
		return nNumber; 
	}		
 
 		/**
		 * onResult() function gets the result from colfusion assigns it to 
		 * a variable and dispatches the event evtDataChanged and 
		 * events evtExpTot, evtClaTot &amp; evtAppTot for updating the totals.
		 */ 
 		public function onResult(result:ArrayCollection):void
		{ 
			var nApprovedTotal:Number 	= 0.0; 
   		var nClaimedTotal:Number 		= 0.0;
   		var nExpectedTotal:Number 	= 0.0;
   		var nExpectedLTTotal:Number = 0.0;
   		var nTotalDeviation:Number  = 0.0;
   		
   		var nSelRate:Number;
			var nSelVolume:Number;
			var nSelInvoicePrice:Number;
			var nSelProgramPrice:Number;
			var txtFinalPayment:Number;
			var bExecNextIf:Number = 1;
			var nInvMinusPgmPrice:Number = 0;
			var i:Number = 0;
		  _acBBData  = new ArrayCollection();
		  nFormatter.precision = 2;
			nFormatter.rounding = NumberBaseRoundType.NEAREST;
			nFormatter.useThousandsSeparator = true;
		  
//Start: Added for loading the final_payment correctly the first time
			for each(var item:Object in result)// should be GridData in result for the GridData.as enforce
		  {
				
			  if (this.sharedSettings.appSettings.BB_LS_Claimed_Rebate_Expected == 1 && item.BB_Product_Type_ID == 3){
				  item.Selected_Rate_Type = '1';
				  item.Selected_Vol_Type = '1';
			  }
			  _acBBData.addItem(new ObjectProxy(item));
			  	txtFinalPayment = item.Final_Payment;
				if(item.Selected_Vol_Type=="3")
				{
					nSelVolume = item.Manual_Vol;
				}
				else if(item.Selected_Vol_Type=="2")
				{
					nSelVolume = item.E_Volume;
				} 
				else  
				{ 
							// Volume type is claimed
					nSelVolume = item.Claimed_Volume;
				}
						
			 	if (item.BB_Product_Type_ID == 1 && item.Editable_Rate == 0)
				{
					if(((item.Selected_Invoice_Price_Type ==1) || (item.Selected_Invoice_Price_Type ==2) || 
						(item.Selected_Invoice_Price_Type ==3)) && ((item.Selected_Program_Price_Type == 1) || (item.Selected_Program_Price_Type ==2)))
					{
						if (item.Selected_Invoice_Price_Type ==1)
						{
							nSelInvoicePrice = item.Claim_Invoice_Price;
						}
						else if(item.Selected_Invoice_Price_Type == 2)
						{
							nSelInvoicePrice = item.Expected_Invoice_Price;
						}
						else if (item.Selected_Invoice_Price_Type == 3)
						{
							nSelInvoicePrice = item.Manual_Invoice_Price;
						}
									
						if (item.Selected_Program_Price_Type == 2)
						{
							nSelProgramPrice = item.Expected_Program_Price;
						}
						else if (item.Selected_Program_Price_Type == 1)
						{
							nSelProgramPrice = item.Claimed_Program_Price;
						}
						/* 
 							21598:Solo - Final payment amount not being calculated correctly
 							if Final Payment happens to be a negative value then change it 
 							to 0 [after discussion with Paul on 11-Dec-09]
 						*/ 									
						nInvMinusPgmPrice = nSelInvoicePrice - nSelProgramPrice;
						if (nInvMinusPgmPrice < 0)
						{
							nInvMinusPgmPrice = 0;
						}
						txtFinalPayment = RoundDecimals(nInvMinusPgmPrice * nSelVolume);
						bExecNextIf = 0;
					}
				}   
			  /* 
			  	if the bExecNextIf is set to 0 then this won't get executed and the
			  	txtFinalPayment value set in the earlier "if" will be returned
			  	back to the datagrid
			  */ 
					  
				if (bExecNextIf == 1)
						{
							// if(compExpected_Rate_Selected=="YES" || compExpected_Rate_Selected=="1" || compExpected_Rate_Selected=="true")
							/* 						
							if(item.Selected_Rate_Type == "2")
							{
								nSelRate = parseFloat(item.E_Rate);
							} 
							else
							{
								nSelRate = item.Claimed_Rate;
							} 
							*/
							
							if(item.Selected_Rate_Type == "1")
							{
								nSelRate = parseFloat(item.Claimed_Rate);
							} 
							else if (item.Selected_Rate_Type == "2")
							{
								nSelRate = parseFloat(item.E_Rate);						
							}
							else if (item.Selected_Rate_Type == "6")
							{
								nSelRate = parseFloat(item.ELT_Rate);						
							}
							else
							{
								nSelRate = parseFloat(item.Manual_Rate);		
							}							
  						
							txtFinalPayment =  RoundDecimals(nSelRate * nSelVolume);
						}	
					
					 // parseFloat((nFormatter.format((nSelRate * nSelVolume).toString())));
					 // for 21716 added the logic to round to the nearest two decimal places before summing
						// nApprovedTotal += parseFloat(nFormatter.format(txtFinalPayment.toString()));
  
  				 //	Alert.show(txtFinalPayment.toString())
		  			item.Final_Payment = parseFloat(txtFinalPayment.toString());
		  			 
		  			nClaimedTotal  	 = parseFloat(nClaimedTotal.toString())  	 + parseFloat(item.Claimed_Amount);
		  			nExpectedTotal 	 = parseFloat(nExpectedTotal.toString())   + parseFloat(item.Expected_Amount);
		  			nExpectedLTTotal = parseFloat(nExpectedLTTotal.toString()) + parseFloat(item.ExpectedLT_Amount);
		  			nApprovedTotal 	 = parseFloat(nApprovedTotal.toString())   + parseFloat(item.Final_Payment);
		  			nTotalDeviation  = parseFloat(nTotalDeviation.toString())  + parseFloat(item.Variation_Claim_Expected); 
		  }
//End 		  

		  _nTotClaimed 		 = nClaimedTotal;
		  _nTotExpected 	 = nExpectedTotal;
		  _nTotExpectedLT  = nExpectedLTTotal ;
		  _nTotApproved 	 = nApprovedTotal;
		  _nTotalDeviation = nTotalDeviation;
		  dispatchEvent(new Event('evtDataChanged'));
		  dispatchEvent(new Event('evtExpTot'));
		  dispatchEvent(new Event('evtExpTotLT'));
		  dispatchEvent(new Event('evtClaTot'));
		  dispatchEvent(new Event('evtAppTot'));
  		  dispatchEvent(new Event('evtAppTotDeviation'));		  
			
		    /* sort grid data. */
			var eventDataGridSort:MainEvent = new MainEvent(MainEvent.DATA_GRID_SORT);
			this._dispatcher.dispatchEvent(eventDataGridSort);	
		  }


		/**
		 *  This function recalculates the various totals and sets the values 
		 * based on the sCaller parameter which tell which radiobutton/function
		 * triggered this function and do the calculations based on that
		 * radiobutton/function.
		
		*/
		//public function fnRecalculate(result:Array,sCaller:String):void
		public function fnRecalculate(evtObj:Object,sCaller:String,sOptionalVal:String):void
		{ 
			var nApprovedTotal:Number 	= 0.0; 
   		var nClaimedTotal:Number 		= 0.0;
   		var nExpectedTotal:Number 	= 0.0;
   		var nExpectedLTTotal:Number = 0.0;
   		var nTotalDeviation:Number  = 0.0;
   			
   		var nSelRate:Number;
			var nSelVolume:Number;
			var nSelInvoicePrice:Number;
			var nSelProgramPrice:Number;
			var txtFinalPayment:Number;
			var bExecNextIf:Number = 1;
			var nCompTotalApproved:Number = 0;	
			var nInvMinusPgmPrice:Number = 0;
			nFormatter.precision = 2;
			nFormatter.rounding = NumberBaseRoundType.NEAREST;
			nFormatter.useThousandsSeparator = true;
			
			/* 
			PLEASE DO NOT REMOVE ".source" FROM "_acBBData.source" BELOW.
			
			Dev Note: 39763 (Milan). For some billbacks: When a user sorts the deviation grid. 
			(I tested using "total deviation" column) and then clicks on "claimed $" button (Issue could be for other buttons too), 
			then the volume (expected) (could be other columns too) becomes 0 for 1 or more products. This makes the "selectedAmount"
			on the CF page (populated from the "final_payment" field in the BB_Item_Invoice_Level table) less than the claimed amount.
			Ading ".source", so that the loop happens on the original data and not on the sorted data takes care of the issue.			
			*/ 
			for each(var item:Object in _acBBData.source)// should be GridData in result for the GridData.as enforce
			{
				txtFinalPayment = item.Final_Payment;
				switch (sCaller)
				{
		  		case "fnRdoVolChange":
		  			if (item.Billback_Product_ID == evtObj.data.Billback_Product_ID)
			 			{
			 				/* 
			 					D23035: Solo - Select exp vol for item and other lines switch to claimed
			 					Change made for Deepa
			 				*/
			 				item.Selected_Vol_Type = sOptionalVal;
			 			
			 			//item.Selected_Vol_Type = !item.Selected_Vol_Type;
				 			/* if (item.Selected_Vol_Type == 1)
				 			{
				 			 item.Selected_Vol_Type = 2;
				 			}
				 			else if (item.Selected_Vol_Type == 2)
				 			{
				 			  item.Selected_Vol_Type = 1;
				 			} */
		  			}
		  			break;	
					case "fnRdoInvChange":
		  			if (item.SrNo == evtObj.data.SrNo)
				 	 	{ 
				 			item.Selected_Invoice_Price_Type = sOptionalVal; 
							// commented below so that the value will be retained even if the user change the focus.
				 		/*	if (sOptionalVal!='3')
				 			{
				 				item.Manual_Invoice_Price = '0';
				 			} */
				  	}
		  			break;		  			
					case "fnRdoPgmChange":
		  			if (item.SrNo == evtObj.data.SrNo)
		 				{
		 				// item.Selected_Program_Price_Type = !item.Selected_Program_Price_Type;
		 					if (item.Selected_Program_Price_Type == 1)
			 				{
			 			 		item.Selected_Program_Price_Type = 2;
			 				}
			 				else if (item.Selected_Program_Price_Type == 2)
			 				{
			 			  	item.Selected_Program_Price_Type = 1;
			 				}
		 				}
		  			break;
		  		/* 
		  			We do not have a place for saving the amount changed for lumpsums, 
		  			so we will be using the same field as the program price, as 
		  			prorgram price will not be used when the type is lumpsum. 
		  		*/  			
					case "fnRdoAmtChange":
		  			if (item.SrNo == evtObj.data.SrNo)
		 				{
		 				// item.Selected_Program_Price_Type = !item.Selected_Program_Price_Type;
		 					if (item.Selected_Program_Price_Type == 1)
			 				{
			 			 		item.Selected_Program_Price_Type = 2;
			 				}
			 				else if (item.Selected_Program_Price_Type == 2)
			 				{
			 			  	item.Selected_Program_Price_Type = 1;
			 				}
		 				}
		  			break;				  		
					case "fnCountChange":
		  			if (item.Billback_Product_ID == evtObj.data.Billback_Product_ID)
			 			{
			 				item.Count_Flag = !item.Count_Flag;
			 			}
		  			break;		  			
					case "fnRateChanged":
		  		/* 	if (item.SrNo == evtObj.data.SrNo)
			 			{ */
			 			// item.Selected_Rate_Type = !item.Selected_Rate_Type;
			 				/* if (item.Selected_Rate_Type == 1)
			 				{
			 			 		item.Selected_Rate_Type = 2;
			 				}
			 				else if (item.Selected_Rate_Type == 2)
			 				{
			 			  	item.Selected_Rate_Type = 1;
			 				} */
			 				
			 				/* 
			 						1 = Claimed Rate
			 						2 = Expected Rate
			 						3 = Expected Less Tolerance Rate
			 						4 = Manual Rate
			 				*/
				 			if (item.SrNo == evtObj.data.SrNo)
					 	 	{ 
					 			item.Selected_Rate_Type = sOptionalVal;
								// commented below so that the value will be retained even if the user change the focus.
					 			/*	if (sOptionalVal!='3')
					 			{
					 				item.Manual_Rate = '0';
					 			} */
					  	}
			 			//}
		  			break;
		  		case "fnRateExpClicked":
		  			item.Selected_Rate_Type						= 2;
		  			break;		
					case "fnRateClaimClicked":
		  			item.Selected_Rate_Type						= 1;
		  			break;		  			
					case "fnRateELTClicked":
		  			item.Selected_Rate_Type						= 6;
		  			break;		  			
					case "fnClaimedAmountClicked":
		  			item.Selected_Vol_Type 						= 1;
						item.Selected_Rate_Type						= 1;
						item.Selected_Invoice_Price_Type 	= 1;
						item.Selected_Program_Price_Type 	= 1;	
		  			break;
					case "fnExpectedAmountClicked":
		  			item.Selected_Vol_Type  					= 2; 
						item.Selected_Rate_Type 					= 2;
						item.Selected_Invoice_Price_Type 	= 2;
						item.Selected_Program_Price_Type 	= 2;		
		  			break;
		  		case "fnExpectedAmountLTClicked":
		  			/* ****************************************************************
		  			  Choose the Selected_Vol_Type to be 2 which is Expected Volume
		  			  and the Selected_Rate_Type to be 3 which is Expected Rate Less 
		  			  Tolerance. We are not setting the other values as they will not 
		  			  be available for display and only volume and rate will be visible.  
		  			 ****************************************************************/
		  			item.Selected_Vol_Type  					= 2;
		  			item.Selected_Rate_Type 					= 6;
		  			break;
					case "fnClaimedVolumeClicked":
		  			item.Selected_Vol_Type 						= 1;
						/* item.Selected_Rate_Type				= 1;
						item.Selected_Invoice_Price_Type 	= 1;
						item.Selected_Program_Price_Type 	= 1; */	
		  			break;
					case "fnExpectedVolumeClicked":
		  			item.Selected_Vol_Type  					= 2; 
						/* item.Selected_Rate_Type 				= 2;
						item.Selected_Invoice_Price_Type 	= 2;
						item.Selected_Program_Price_Type 	= 2; */		
		  			break;		  					  			
					case "fnSetInvManual":
		  			if (item.SrNo == evtObj.data.SrNo)
				 		{
				 			//Alert.show(ObjectUtil.toString(evtObj));

				 				item.Manual_Invoice_Price = evtObj.txtMan.text;
				 		}
		  			break;		
		  		case "fnSetRateManual":
						if (item.SrNo == evtObj.data.SrNo)
				 		{
				 			// If the setting is not checked [OFF] that indicates the user cannot enter in a rate that is greater than the claimed rate.
				 			/* 
								Dev Notes: 23156/Anand Rao/26-Apr-10
								User profile to control manual rate override on bb deviation grid
							*/  
			 	 			var strManRate:String = evtObj.txtRateMan.text; 
				 			strManRate = strManRate.replace(",", "");
				 			strManRate = strManRate.replace("$", "");
				 			if ((sOptionalVal == "0") && (parseFloat(strManRate) > parseFloat(item.Claimed_Rate)))
				 			{
				 				Alert.show("You are not allowed to enter a rate greater than the claimed rate.","User Profile Settings Error!");
				 			}
				 			// If the setting is checked [ON] that indicates the user can type in a rate that is greater than the claimed rate.
				 			else
				 			{				 			
				 				item.Manual_Rate = strManRate;
				 			}
				 		}		  		
		  		break;	
					/* Manual Volume Start */		  		
					case "fnSetVolManual":
					if (item.SrNo == evtObj.data.SrNo)
					{
					var strManVol:String = evtObj.txtVolMan.text;
					strManVol = strManVol.replace(",", "");
					strManVol = strManVol.replace("$", "");
					item.Manual_Vol = evtObj.txtVolMan.text;
					}
					break;				 		
	  		  			
					case "fnFocusInDG":
		  			// xxx
		  			break;		  			
					case "fniDoneChanged":
		  			if (item.SrNo == evtObj.data.SrNo)
			 			{
			 				if (item.iDone == "0")
			 				{
			 					item.iDone = "2";
			 				} 
			 				else if (item.iDone == "1" || item.iDone == "2")
			 				{
			 					item.iDone = "0";
			 				}
			 			}
		  			break;		  			
					case "fnVolOverride":
		  			item.E_Volume	= item.Claimed_Volume; 
						item.Volume_Override = 1;
		  			break;		  			
					case "fnRateOverride":
		  			item.E_Rate	= item.Claimed_Rate; 
						item.Rate_Override = 1;
		  			break;		  			
		  	}
		  		// parseFloat was added to the nClaimedTotal for Label No.21890
		  		// as the grid was off by .01 and due to some float overflow during looping 
		  		nClaimedTotal  	 = parseFloat(nClaimedTotal.toString())  	 + parseFloat(item.Claimed_Amount);
		  		nExpectedTotal 	 = parseFloat(nExpectedTotal.toString()) 	 + parseFloat(item.Expected_Amount);
		  		nExpectedLTTotal = parseFloat(nExpectedLTTotal.toString()) + parseFloat(item.ExpectedLT_Amount);
		  		nTotalDeviation  = parseFloat(nTotalDeviation.toString())  + parseFloat(item.Variation_Claim_Expected); 
				  	if(item.Selected_Vol_Type=="3")
						{
							nSelVolume = item.Manual_Vol;
						}
				  	else if(item.Selected_Vol_Type=="2")
						{
							nSelVolume = item.E_Volume;
						} 
						else
						{ 
							// Volume type is claimed
							nSelVolume = item.Claimed_Volume;
						}
						
			 			if (item.BB_Product_Type_ID == 1 && item.Editable_Rate == 0)
						{
							if(((item.Selected_Invoice_Price_Type ==1) || (item.Selected_Invoice_Price_Type ==2) || 
								(item.Selected_Invoice_Price_Type ==3)) && ((item.Selected_Program_Price_Type == 1) || (item.Selected_Program_Price_Type ==2)))
								{
									if (item.Selected_Invoice_Price_Type ==1)
									{
										nSelInvoicePrice = item.Claim_Invoice_Price;
									}
									else if(item.Selected_Invoice_Price_Type == 2)
									{
										nSelInvoicePrice = item.Expected_Invoice_Price;
									}
									else if (item.Selected_Invoice_Price_Type == 3)
									{
										nSelInvoicePrice = item.Manual_Invoice_Price;
									}
									
									if (item.Selected_Program_Price_Type == 2)
									{
										nSelProgramPrice = item.Expected_Program_Price;
									}
									else if (item.Selected_Program_Price_Type == 1)
									{
										nSelProgramPrice = item.Claimed_Program_Price;
									}
									/* 
		 								21598:Solo - Final payment amount not being calculated correctly
		 								if Final Payment happens to be a negative value then change it 
		 								to 0 [after discussion with Paul on 11-Dec-09]
		 							*/ 									
									nInvMinusPgmPrice = nSelInvoicePrice - nSelProgramPrice;
									if (nInvMinusPgmPrice < 0)
									{
										nInvMinusPgmPrice = 0;
									}
									txtFinalPayment = RoundDecimals(nInvMinusPgmPrice * nSelVolume);
									bExecNextIf = 0;
								}
						}   
					  /* 
					  	if the bExecNextIf is set to 0 then this won't get executed and the
					  	txtFinalPayment value set in the earlier "if" will be returned
					  	back to the datagrid
					  */ 
					  
						if (bExecNextIf == 1)
						{
							// if(compExpected_Rate_Selected=="YES" || compExpected_Rate_Selected=="1" || compExpected_Rate_Selected=="true")
							
							if(item.Selected_Rate_Type == "1")
							{
								nSelRate = item.Claimed_Rate;
							} 
							else if (item.Selected_Rate_Type == "2")
							{
								nSelRate = parseFloat(item.E_Rate);						
							}
							else if (item.Selected_Rate_Type == "6")
							{
								nSelRate = parseFloat(item.ELT_Rate);						
							}
							else
							{
								nSelRate = parseFloat(item.Manual_Rate);		
							} 
							 
							txtFinalPayment = RoundDecimals(nSelRate * nSelVolume);
						}	
					 // parseFloat((nFormatter.format((nSelRate * nSelVolume).toString())));
					 // for 21716 added the logic to round to the nearest two decimal places before summing
						
						nApprovedTotal = parseFloat(nApprovedTotal.toString()) + parseFloat(txtFinalPayment.toString());
		  			item.Final_Payment = parseFloat(txtFinalPayment.toString());
						//return txtFinalPayment.toString();
		  }
		  _nTotClaimed 			=	nClaimedTotal;
		  _nTotExpected 		= nExpectedTotal;
		  _nTotExpectedLT 	= nExpectedLTTotal
		  _nTotApproved 		= nApprovedTotal;
		  _nTotalDeviation 	= nTotalDeviation;
		  
		 // this._acBBData  = ArrayCollection(result);
		  dispatchEvent(new Event('evtDataChanged'));
		  dispatchEvent(new Event('evtExpTot'));
		  dispatchEvent(new Event('evtExpTotLT'));
		  dispatchEvent(new Event('evtClaTot'));
		  dispatchEvent(new Event('evtAppTot'));
		  dispatchEvent(new Event('evtAppTotDeviation'));
		 // this._acBBData  = ArrayCollection(result);
		 // this._acBBData.refresh();
		  }

		/**
		* This getter function returns a Number
		*/  
		[Bindable (event="evtClaTot")]
		public function get nTotClaimed():Number
		{
			return _nTotClaimed;
		}
		
		/**
		* This getter function returns a Number
		*/		
		[Bindable (event="evtExpTot")]
		public function get nTotExpected():Number
		{
			return _nTotExpected;
		}

		/**
		* This getter function returns a Number
		*/		
		[Bindable (event="evtExpTotLT")]
		public function get nTotExpectedLT():Number
		{
			return _nTotExpectedLT;
		}

		/**
		* This getter function returns a Number
		*/
		[Bindable (event="evtAppTot")]
		public function get nTotApproved():Number
		{
			return _nTotApproved;
		}
		
		/**
		* This getter function returns a Number
		*/
		[Bindable (event="evtAppTotDeviation")]
		public function get nTotalDeviation():Number
		{
			return _nTotalDeviation;
		}
		
		public function closeBBDeviations(event:com.Billback.Deviation.events.MainEvent):void{
			var e:BBMainEvent = new BBMainEvent(BBMainEvent.CLOSE_DEVIATIONS);
			if(this.bbHeader){
				e.bbHeader  = this.bbHeader;
			}
			e.sState = event.doAction;
			this._dispatcher.dispatchEvent(e);
		}
		
		/** 
		 * Alerter() function is used in the MainEventMap 
		 * to show alerts for testing the coding
		*/			
		public function Alerter(xx:*):void
		{
			Alert.show(ObjectUtil.toString(xx));
		} 

		 
		// close Billback
	/*	public function closeBB():void{
			var e:BBMainEvent = new BBMainEvent(BBMainEvent.CLOSE_BB);
			if(this.bbHeader){
				e.bbHeader  = this.bbHeader;
			}
			this._dispatcher.dispatchEvent(e);
		}
	*/	

	}/* Class end */
}/* Package end */