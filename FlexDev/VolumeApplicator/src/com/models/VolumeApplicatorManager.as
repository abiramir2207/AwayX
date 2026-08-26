package com.models
//package com.models.ProgramSeachManager
{
	import com.events.*;
	import com.views.*;
	
	import flash.display.DisplayObject;
	import flash.events.*;
	import flash.external.*;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.events.*;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;
	import mx.utils.StringUtil;
	
	/**
 	 * This class sets all the data and settings that will be used 
 	 * in the application. 
 	 */
 	
	[Bindable]
	public class VolumeApplicatorManager extends EventDispatcher 
	{
 
		public var _arrAllTemplate:Array 			= new Array();
		public var _arrAllStatus:Array 	   			= new Array();		 
		public var _arrAllUserPositions:Array 		= new Array();
		public var _arrAllBuyingGroups:Array 		= new Array();
		public var _arrAllFamilyNames:Array 		= new Array();
		public var _arrAllUsers:Array 				= new Array();
		public var _arrAllRSP:Array 				= new Array();
	 	public var _iUserId:String					= "";
		public var UserAccess:Array 		 		= new Array();
		public var _Template:String 		 		= "";
		public var _Status:String 			 		= "";
		public var _BuyingGroups:String 	 		= "";
		public var _FamilyName:String 		 		= "";
		public var _UsersAndPositions:String 		= "";
		public var _Positions:String 		 		= "";
		public var _ProgramInfo:String 		 		= "";
		public var _RSP:String 				 		= "";
		public var _UserName:String 		 		= "";
		public var _Program_Info:String 	 		= "";
		public var _Distributor_Info:String  		= "";
		public var _Operator_Info:String     		= "";
		public var _Item_Info:String 		 		= "";
		public var vchStatus:String			 		= "";
		public var _Report_List:String		 		= "";
		private var _UserPositionSelectedIndex:int	= 0;
 
		public var _sURL:String = "";
		public var _acVolumeData:ArrayCollection = null;
		public var _acVolumeDataEdit:ArrayCollection = null;
		public var _OprShowSetting:Boolean = true;
		public var _groupBselected:String = "Invoices"; 
		public var Regular_Access_Program_ID_List : String;
		public var Catalog_Access_Program_ID_List : String;	
		public var Agreed_Access_Program_ID_List : String;
		public var Pending_Approval_Access_Program_ID_List : String;	
		public var Under_Review_Access_Program_ID_List : String;	
		public var arrFinal_Catalog_Access_Program_ID_List:Array = new Array();
		public var strFinal_Catalog_Access_Program_ID_List : String;
		public var Full_Access_Program_ID_List : String;		
		public var arrRegularAccessProgramIDList:Array = new Array();
		public var arrCatalogAccessProgramIDList:Array = new Array();	
		public var arrAgreedAccessProgramIDList:Array = new Array();
		public var arrPendingApprovalAccessProgramIDList:Array = new Array();
		public var arrUnderReviewAccessProgramIDList:Array = new Array();
	 	public var arrValidItems:Array = new Array();
		public var arrInValidItems:Array = new Array();
		public var arrItemsToAdd:Array = new Array();
	  	public var sPrgBuyingGroupLabel:String  = "";
	 	public var sPrgFamilyLabel:String = "";
	  	public var sSeeAwardedInCatalog:String = "";
	  	public var sCustomerLabel:String = "";
	  	public var sItemLabel:String = "";
	  	public var sOperatorLabel:String = "";
    	public var sRFAAgreed:String = "";	
    	public var bBusinessSegment:Boolean;
    	public var groupBsel:String = "Invoices";
		public var _acProductGroupType:ArrayCollection = null;
	 	
	 	public function volumeFilter():void
	 	{
	 	}
 
	 	[Bindable (event="OprControlSetting")]
		public function get OprShowSetting():Boolean
		{	
			return _OprShowSetting; 
		} 
		
		public function fnGetProgramType(appPrgType:String):void
		{
			// these are the two operator based templates which should show
			// the operator radio choice
			if ((appPrgType =="Operator-Deviated Pricing") ||(appPrgType =="Operator-Deviated Pricing")) 
			{			 	
				_OprShowSetting = true;
			}
	  	else
	  	{
	  	 	_OprShowSetting = false;
			}
			dispatchEvent(new Event('OprControlSetting'));
		 
		}
	
		[Bindable (event="updGroupB")]
		public function get groupBselected():String
		{	
			return _groupBselected; 
		} 
	 
		public function fngroupBselected(groupBsel:String):void
		{
		  _groupBselected = groupBsel;
	    dispatchEvent(new Event('updGroupB'));
		}
	 
 		public function fnGetVolume():void
		{
	  	dispatchEvent(new Event('updVolumeEvent'));	
		} 
		
		[Bindable (event="updVolumeDataEvent")]
		public function get acVolumeData():ArrayCollection
		{
			return _acVolumeData;
		} 
	 
	 	public function fnGetVolumeEdit():void
		{
	  	dispatchEvent(new Event('updVolumeEditEvent'));	
		} 
		
		[Bindable (event="updVolumeDataEditEvent")]
		public function get acVolumeDataEdit():ArrayCollection
		{
			return _acVolumeDataEdit;
		}
		
		[Bindable (event="updProgductGroupTypeEvent")]
		public function get acProductGroupType():ArrayCollection
		{
			return _acProductGroupType;
		} 
		
		/**
		 * This function is used to show alerts for testing the coding
		 */			
		public function Alerter(xx:*):void
		{
			Alert.show(ObjectUtil.toString(xx));
		} 
  
		[Bindable (event="updUserIDEvent")]
		public function get getUserID():String
		{
			return _iUserId;
		} 	
	 
	 	/**
		 * This function gets the result from colfusion assigns it to 
		 * a variable and dispatches the event updVolumeDataEvent
		 */ 
 		public function onResult(result:ArrayCollection):void
		{ 
		 _acVolumeData  = ArrayCollection(result);
		 dispatchEvent(new Event('updVolumeDataEvent'));
		}

	 	/**
		 * This function gets the result from colfusion assigns it to 
		 * a variable and dispatches the event updVolumeDataEditEvent
		 */ 		
		public function onResultEdit(resultset:ArrayCollection):void
		{ 
		  _acVolumeDataEdit  = ArrayCollection(resultset);
		  dispatchEvent(new Event('updVolumeDataEditEvent'));
		}		
 
		/**
		 * This function gets the product group types from colfusion and
		 * assigns it to a variable and dispatches the event updProgductGroupTypeEvent
		 */ 		
		public function onResultProductGroupType(productGroupTypeResultSet:ArrayCollection):void
		{ 
			_acProductGroupType  = ArrayCollection(productGroupTypeResultSet);
			dispatchEvent(new Event('updProgductGroupTypeEvent'));
		}
		
		public function setAppSettings(aSettings:ArrayCollection):void
		{
	 
		}
  
	}/* Class end */
}/* Package end */