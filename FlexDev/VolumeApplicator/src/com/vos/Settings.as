/**
* This package declares the various clases that will hold all the 
* variables that will be used within the settings 
*/ 
package com.vos
{
	/**
	* This class declare the various variables that will be used within the 
	* settings 
	*/ 
	[Bindable]
	public class Settings
	{
		/*-.........................................Properties..........................................*/
		public var userId : String;
		
		public var appAreaTitle : String;
		//public var appQtyUOMIDX : String; 
		//public var appUOMType : String;
		public var volQtyUOMIDX:String;
		public var volUOMType:String;		
		public var appAreaKeyword : String;
		public var appAreaStartDate : String;
		public var appAreaEndDate : String;
		public var appAreaSpanDays : String;
		public var appAreaContractNumber : String;
		public var appProgramType : String
		public var appMinGlobalVolume : String;
		public var appMinGlobalVolumeSizeCS : String;
		public var appMinGlobalVolumeSizeLB : String;
		public var appMaxGlobalVolume : String;
		public var appMaxGlobalVolumeSizeCS : String;
		public var appMaxGlobalVolumeSizeLB : String;
		public var appGroupADefault : String;
		public var appGroupBDefault : String;
		public var appProgramID : String;
		public var profileID :String;
		public var bOpType : String;
		public var bDirectShipmentShow : String;
		public var bBillbackShow : String;
		public var bCreditsShow : String;
		public var bDetailsDisplay : String;
		public var strVolumeHelpText : String;
		public var customer_Label : String;
		public var item_Label : String;
		public var pound_Label : String;
		public var operator_Label : String;
		public var rebatePercentageOnNetSales : Number;
		public var discountType : int;
		public var logindate : Date;
		public var appSettings:Object;
		public var appFlex:Object;
		public var user:Object;
		public var bOpportunityVolumeShow : Boolean;
		public var bCasesVolumeShow : Boolean;
		public var bPoundsVolumeShow : Boolean;
		public var bOpportunityCasesVolumeShow : Boolean;
		public var bOpportunityPoundsVolumeShow : Boolean;
		public var excludeAutoVolumeUpdates : Boolean;
		public var volumePageUOMCS : Number;
		public var volumePageUOMLB : Number;
		public var autoVolumeExcludeUpdatedData : String;
		

		
		/*-.........................................Constructor..........................................*/
		public function Settings(	userId : String 	=	"",
															appAreaTitle : String = "",
															//appQtyUOMIDX : String = "",
															//appUOMType : String = "",
															volQtyUOMIDX : String = "",
															volUOMType : String = "",														
															appAreaKeyword : String = "",
															appAreaStartDate : String = "",
															appAreaEndDate : String = "",
															appAreaSpanDays : String = "",
															appAreaContractNumber : String = "",
															appProgramType : String = "",
															appMinGlobalVolume : String = "",
															appMinGlobalVolumeSizeCS : String = "",
															appMinGlobalVolumeSizeLB : String = "",
															appMaxGlobalVolume : String = "",
															appMaxGlobalVolumeSizeCS : String = "",
															appMaxGlobalVolumeSizeLB : String = "",
															appGroupADefault : String = "",
															appGroupBDefault : String = "",															
															appProgramID : String = "",
															profileID : String = "",
															bOpType : String = "",
															bDirectShipmentShow : String = "",
															bBillbackShow : String = "",
															bCreditsShow : String = "",
															bDetailsDisplay : String = "",
															strVolumeHelpText : String = "",
															customer_Label : String = "",
															item_Label : String = "",
															pound_Label : String = "",
															operator_Label : String = "",
															rebatePercentageOnNetSales : Number = 0,
															bOpportunityVolumeShow :Boolean = false,
															bCasesVolumeShow:Boolean = false,
															bPoundsVolumeShow:Boolean = false,
															bOpportunityCasesVolumeShow:Boolean = false,
															bOpportunityPoundsVolumeShow:Boolean = false,
															excludeAutoVolumeUpdates:Boolean = false,
															volumePageUOMCS:Number = 1,
															volumePageUOMLB:Number = 0,
															autoVolumeExcludeUpdatedData:String = ""
															 
														)
		
									
		{
			this.userId							= userId;
			this.appAreaTitle					= appAreaTitle;
			//this.appUOMType						= appUOMType;
			//this.appQtyUOMIDX					= appQtyUOMIDX;
			this.volUOMType						= volUOMType;
			this.volQtyUOMIDX					= volQtyUOMIDX;			
			this.appAreaKeyword					= appAreaKeyword;
			this.appAreaStartDate				= appAreaStartDate;
			this.appAreaEndDate					= appAreaEndDate ;
			this.appAreaSpanDays				= appAreaSpanDays;			
			this.appAreaContractNumber 			= appAreaContractNumber;
			this.appProgramType					= appProgramType;
			this.appMinGlobalVolume 			= appMinGlobalVolume;
			this.appMinGlobalVolumeSizeCS 		= appMinGlobalVolumeSizeCS;
			this.appMinGlobalVolumeSizeLB 		= appMinGlobalVolumeSizeLB;
			this.appMaxGlobalVolume 			= appMaxGlobalVolume;
			this.appMaxGlobalVolumeSizeCS 		= appMaxGlobalVolumeSizeCS;
			this.appMaxGlobalVolumeSizeLB  		= appMaxGlobalVolumeSizeLB;		
			this.appGroupADefault				= appGroupADefault;
			this.appGroupBDefault				= appGroupBDefault;		
			this.bOpType						= bOpType;
			this.bDirectShipmentShow			= bDirectShipmentShow; 
			this.bBillbackShow					= bBillbackShow;
			this.bCreditsShow					= bCreditsShow;
			this.bDetailsDisplay				= bDetailsDisplay;
			this.strVolumeHelpText				= strVolumeHelpText;
			this.appProgramID					= appProgramID;
			this.profileID						= profileID;
			this.customer_Label					= customer_Label;
			this.item_Label						= item_Label;
			this.pound_Label 					= pound_Label;
			this.operator_Label					= operator_Label;
			this.rebatePercentageOnNetSales 	= rebatePercentageOnNetSales;
			this.bOpportunityVolumeShow 		= bOpportunityVolumeShow;
			this.bCasesVolumeShow				= bCasesVolumeShow;
			this.bPoundsVolumeShow				= bPoundsVolumeShow;
			this.bOpportunityCasesVolumeShow 	= bOpportunityCasesVolumeShow;
			this.bOpportunityPoundsVolumeShow	= bOpportunityPoundsVolumeShow;
			this.excludeAutoVolumeUpdates		= excludeAutoVolumeUpdates;
			this.volumePageUOMCS				= volumePageUOMCS;
			this.volumePageUOMLB				= volumePageUOMLB;
			this.autoVolumeExcludeUpdatedData 	= autoVolumeExcludeUpdatedData;
		}
 
		/*-.........................................Methods..........................................*/
		/**
		* This function loads the differnt variables from the newsettings \
		* structure 
 		*/ 
		public function load(newSettings:Settings):void 
		{
			this.userId 						= newSettings.userId;
			this.appAreaTitle 					= newSettings.appAreaTitle;
			//this.appQtyUOMIDX 					= newSettings.appQtyUOMIDX;
			//this.appUOMType 					= newSettings.appUOMType;
			this.volQtyUOMIDX 					= newSettings.volQtyUOMIDX;
			this.volUOMType 					= newSettings.volUOMType;			
			this.appAreaKeyword 				= newSettings.appAreaKeyword;
			this.appAreaStartDate 				= newSettings.appAreaStartDate;
			this.appAreaEndDate 				= newSettings.appAreaEndDate ;
			this.appAreaSpanDays 				= newSettings.appAreaSpanDays;
			this.appAreaContractNumber 			= newSettings.appAreaContractNumber;
			this.appProgramType 				= newSettings.appProgramType;
			this.appMinGlobalVolume 			= newSettings.appMinGlobalVolume;
			this.appMinGlobalVolumeSizeCS		= newSettings.appMinGlobalVolumeSizeCS;
			this.appMinGlobalVolumeSizeLB 		= newSettings.appMinGlobalVolumeSizeLB;
			this.appMaxGlobalVolume 			= newSettings.appMaxGlobalVolume;
			this.appMaxGlobalVolumeSizeCS 		= newSettings.appMaxGlobalVolumeSizeCS;
			this.appMaxGlobalVolumeSizeLB 		= newSettings.appMaxGlobalVolumeSizeLB;		
			this.appGroupADefault 				= newSettings.appGroupADefault;
			this.appGroupBDefault 				= newSettings.appGroupBDefault;	
			this.bOpType 						= newSettings.bOpType;
			this.bDirectShipmentShow 			= newSettings.bDirectShipmentShow; 
			this.bBillbackShow 					= newSettings.bBillbackShow;
			this.bCreditsShow			 		= newSettings.bCreditsShow;
			this.bDetailsDisplay				= newSettings.bDetailsDisplay;
			this.strVolumeHelpText				= newSettings.strVolumeHelpText;
			this.appProgramID 					= newSettings.appProgramID;
			this.profileID						= newSettings.profileID;
			this.operator_Label 				= newSettings.operator_Label;
			this.item_Label 					= newSettings.item_Label;
			this.pound_Label 					= newSettings.pound_Label;
			this.customer_Label 				= newSettings.customer_Label;
			this.rebatePercentageOnNetSales 	= newSettings.rebatePercentageOnNetSales;
			this.bOpportunityVolumeShow 		= newSettings.bOpportunityVolumeShow;
			this.bCasesVolumeShow				= newSettings.bCasesVolumeShow;
			this.bPoundsVolumeShow				= newSettings.bPoundsVolumeShow;
			this.bOpportunityCasesVolumeShow 	= newSettings.bOpportunityCasesVolumeShow;
			this.bOpportunityPoundsVolumeShow	= newSettings.bOpportunityPoundsVolumeShow;
			this.excludeAutoVolumeUpdates		= newSettings.excludeAutoVolumeUpdates;
			this.volumePageUOMCS				= newSettings.volumePageUOMCS;
			this.volumePageUOMLB				= newSettings.volumePageUOMLB;
			this.autoVolumeExcludeUpdatedData	= newSettings.autoVolumeExcludeUpdatedData;
		}

	}
}