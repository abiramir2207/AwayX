/**
* Settings is the master settings object returned from CF.
*/  
package com.vos
{
	import flash.events.EventDispatcher;
	/**
	 * Settings is the master settings object returned from CF.
	*/
	[Bindable]
	public class Settings extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var sUserId : String;
		public var sBBID : String;		
		public var sCallerSource :String;		
		public var sBBTitle : String;
		public var sBBStartDate : String;
		public var sBBEndDate : String;
		public var sBBAmount : String;
		public var sBBCode : String;
		public var sBBDate : String;
		public var sPayeeName : String;
		public var sBBDevOvPrice : String; 
		public var sBBUpdApproveAmt : String;
		public var sBBApproveExpRateLessTol : String;
		public var sBBApproveDisAgree: String;
		public var sBBManualRateCheck: String;
		public var sBBVolumeOverride:String;		
		public var sBBRateOverride:String;		
		public var sBBStatusID : String;
		public var sBBEditable : String;
 		public var sExpBtnBgColor : String;
    	public var sExpBtnFontColor : String;
    	public var sEltBtnBgColor : String;
	  	public var sEltBtnFontColor : String;
    	public var sClmBtnBgColor : String;
	  	public var sClmBtnFontColor : String;
    	public var sSelBtnBgColor : String;
    	public var sSelBtnFontColor : String; 
		public var sBBFractionalVolume : String;	
		public var sViewOperatorinBillbackDeviation	: String;	
		public var sBBOverlapDeviationBasedOnOperator : String;
		public var sDeviationGridAllowManualValuesGTClaimed : String;
		public var sBBOperLocationLevelDupChecker : String;
		public var sProfileViewDeviatedItemsOnlyOnLoad : String;
		public var sProfileViewCountColumnInDeviationGrid : String;
		
		public var sBBAllDupGroupID : String;
		public var iProgramId : int;
		public var iDiscountType : int;
		public var logindate : Date;
		public var appSettings : Object;
		public var user : Object;
		public var UIAttributes : Object;
		
	
		/*-.........................................Constructor..........................................*/
		public function Settings(
									sBBID : String 				 					  =	"",
									sBBTitle : String 		 					  	  =	"",
									sBBStartDate : String  							  =	"",
									sBBEndDate : String 	 						  =	"",
									sBBAmount : String 		 						  =	"",
									sBBCode : String 			 					  =	"",
									sBBDate : String 			 					  =	"",
									sPayeeName : String 	 						  =	"",
									sBBDevOvPrice : String 							  = "",
									sBBUpdApproveAmt : String 						  = "",
									sBBApproveExpRateLessTol : String 				  = "",			
									sBBApproveDisAgree : String 					  = "",
									sBBManualRateCheck : String						  = "",			
									sBBVolumeOverride : String						  = "",
									sBBRateOverride : String						  = "",
									sBBStatusID : String 	 						  =	"",
									sBBEditable : String							  = "",
									sExpBtnBgColor : String							  = "",
    								sExpBtnFontColor : String						  = "",
							    	sEltBtnBgColor : String							  = "",
								  	sEltBtnFontColor : String						  = "",		
							    	sClmBtnBgColor : String							  = "",	
								  	sClmBtnFontColor : String						  = "",
							    	sSelBtnBgColor : String							  = "",
							 	   	sSelBtnFontColor : String						  = "", 
								   	sBBFractionalVolume: String						  = "",
									sViewOperatorinBillbackDeviation: String		  = "",
									sBBOverlapDeviationBasedOnOperator: String 		  = "",
									sDeviationGridAllowManualValuesGTClaimed : String = "",
									sBBOperLocationLevelDupChecker : String 		  = "",
									sProfileViewDeviatedItemsOnlyOnLoad : String	  = "",
									sProfileViewCountColumnInDeviationGrid : String	  = "",
									sBBAllDupGroupID : String 						  = "",
									sUserId : String 			 					  = "",
									iProgramId : int 			 					  = 0,
									sCallerSource: String							  = "",
									iDiscountType : int 	 						  = 0,
									appSettings:Object 		 						  = null,
									user:Object 					 				  = null,
									UIAttributes:Object 	 						  = null,
									logindate : Date 			 					  = null
									//sExpBtnBgColor : String						= ""
									)
		{
			this.sBBID 				 					  = sBBID; 	
			this.sBBTitle 		 						  = sBBTitle;
			this.sBBStartDate  							  = sBBStartDate;
			this.sBBEndDate 	 						  = sBBEndDate;
			this.sBBAmount 		 						  = sBBAmount;
			this.sBBCode 			 					  = sBBCode;
			this.sBBDate 			 					  = sBBDate;
			this.sPayeeName 	 						  = sPayeeName;
			this.sBBDevOvPrice 							  = sBBDevOvPrice;
			this.sBBUpdApproveAmt 						  = sBBUpdApproveAmt;
			this.sBBApproveExpRateLessTol 				  = sBBApproveExpRateLessTol;
			this.sBBApproveDisAgree						  = sBBApproveDisAgree;		
			this.sBBManualRateCheck						  = sBBManualRateCheck;	
			this.sBBVolumeOverride 						  = sBBVolumeOverride;
			this.sBBRateOverride 						  = sBBRateOverride;			
			this.sBBStatusID	 						  = sBBStatusID;
			this.sExpBtnBgColor							  = sExpBtnBgColor; 
			this.sExpBtnFontColor						  = sExpBtnFontColor;
		  	this.sEltBtnBgColor							  = sEltBtnBgColor;
			this.sEltBtnFontColor 						  = sEltBtnFontColor;	
		  	this.sClmBtnBgColor 						  = sClmBtnBgColor;
			this.sClmBtnFontColor 						  = sClmBtnFontColor;
		 	this.sSelBtnBgColor						  	  = sSelBtnBgColor;
		 	this.sSelBtnFontColor 						  = sSelBtnFontColor;  
			this.sBBFractionalVolume					  = sBBFractionalVolume;
			this.sViewOperatorinBillbackDeviation		  = sViewOperatorinBillbackDeviation;	
			this.sBBOverlapDeviationBasedOnOperator 	  = sBBOverlapDeviationBasedOnOperator;
			this.sDeviationGridAllowManualValuesGTClaimed = sDeviationGridAllowManualValuesGTClaimed;
			this.sBBOperLocationLevelDupChecker 		  = sBBOperLocationLevelDupChecker;
			this.sProfileViewDeviatedItemsOnlyOnLoad	  = sProfileViewDeviatedItemsOnlyOnLoad;	
			this.sProfileViewCountColumnInDeviationGrid	  = sProfileViewCountColumnInDeviationGrid;
			this.sBBAllDupGroupID						  = sBBAllDupGroupID;
			this.sUserId 		 	 					  = sUserId;
			this.iProgramId 	 					  	  = iProgramId;
			this.sCallerSource							  = sCallerSource;
			this.iDiscountType 							  = iDiscountType;
			this.appSettings 	 						  = new Object(),
			this.user 				 					  = new Object(),
			this.UIAttributes  							  = new Object(),
			this.logindate 		 						  = ( logindate == null ) ?  new Date() : logindate;
		}
			
		
		
		/*-.........................................Methods..........................................*/
		public function load(newSettings:Settings):void 
		{
			this.sBBID 				 						= newSettings.sBBID; 	
			this.sBBTitle 		 							= newSettings.sBBTitle;
			this.sBBStartDate  								= newSettings.sBBStartDate;
			this.sBBEndDate 	 							= newSettings.sBBEndDate;
			this.sBBAmount 		 							= newSettings.sBBAmount;
			this.sBBCode 			 						= newSettings.sBBCode;
			this.sBBDate 			 						= newSettings.sBBDate;
			this.sPayeeName 	 							= newSettings.sPayeeName;
			this.sBBDevOvPrice 								= newSettings.sBBDevOvPrice;
			this.sBBUpdApproveAmt 							= newSettings.sBBUpdApproveAmt;
			this.sBBApproveExpRateLessTol 					= newSettings.sBBApproveExpRateLessTol;			
			this.sBBApproveDisAgree		  					= newSettings.sBBApproveDisAgree;
			this.sBBManualRateCheck		  					= newSettings.sBBManualRateCheck;
			this.sBBVolumeOverride		  					= newSettings.sBBVolumeOverride;
			this.sBBRateOverride		  					= newSettings.sBBRateOverride;			
			// this.appSettings	 			= newSettings.sBBStatusID;
			this.sBBStatusID	 							= newSettings.sBBStatusID;
			this.sExpBtnBgColor								= newSettings.sExpBtnBgColor; 
			this.sExpBtnFontColor							= newSettings.sExpBtnFontColor;
		  	this.sEltBtnBgColor								= newSettings.sEltBtnBgColor;
			this.sEltBtnFontColor 							= newSettings.sEltBtnFontColor;	
		  	this.sClmBtnBgColor 							= newSettings.sClmBtnBgColor;
			this.sClmBtnFontColor 							= newSettings.sClmBtnFontColor;
		  	this.sSelBtnBgColor								= newSettings.sSelBtnBgColor;
		  	this.sSelBtnFontColor 							= newSettings.sSelBtnFontColor; 
		  	this.sBBFractionalVolume 						= newSettings.sBBFractionalVolume;
			this.sViewOperatorinBillbackDeviation			= newSettings.sViewOperatorinBillbackDeviation;	
			this.sBBOverlapDeviationBasedOnOperator 		= newSettings.sBBOverlapDeviationBasedOnOperator;
			this.sDeviationGridAllowManualValuesGTClaimed  	= newSettings.sDeviationGridAllowManualValuesGTClaimed; 
			this.sBBOperLocationLevelDupChecker				= newSettings.sBBOperLocationLevelDupChecker;
			this.sProfileViewDeviatedItemsOnlyOnLoad		= newSettings.sProfileViewDeviatedItemsOnlyOnLoad;
			this.sProfileViewCountColumnInDeviationGrid	  	= newSettings.sProfileViewCountColumnInDeviationGrid;
			this.sBBAllDupGroupID							= newSettings.sBBAllDupGroupID;
			this.sBBEditable	 							= newSettings.sBBEditable;
			this.sUserId 			 						= newSettings.sUserId;
			this.iProgramId 	 							= newSettings.iProgramId;
			this.sCallerSource								= newSettings.sCallerSource;
			this.iDiscountType 								= newSettings.iDiscountType;
			this.logindate 		 							= newSettings.logindate;
			this.appSettings 	 							= newSettings.appSettings;
			this.user 				 						= newSettings.user;
			this.UIAttributes 								= newSettings.UIAttributes;
		
		}

	}
}