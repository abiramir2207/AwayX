package com.Billback.Upload.models.vos
{
	import com.Billback.Upload.models.vos.BBUploadHeaderError;
	import com.shared.models.entity.vos.User;
	
	import flash.events.EventDispatcher;
	
	
	
	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBUploadHeader")]
	public class BBUploadHeader extends EventDispatcher
	{  
		public var isSelected:Boolean;
		public var uploadID:int;
		public var bbHdrCounter:int;
		public var bbHeaderID:int;
		public var vendorId:String;//ok
		public var vendorName:String;//ok
		public var shipTo:String;//ok
		public var BBReference:String;//ok
		public var billbackTitle:String;//ok
		public var BBDate:String;//ok
		public var startDate:String;//ok
		public var endDate:String;//ok
		public var BBAmount:String;//ok
		public var TotalVolume:String;
		public var errMsg:String;
		public var errType:String;
		public var errObj:BBUploadHeaderError;
		public var uploadType:String;
		public var locked:Boolean;
		public var lockedUser:User;
		public var lockedByOther:Boolean = false;
		public var lockedDateTime:Date;
		public var uploadDateTime:Date;
		public var updatedDate:Date;
		public var uploadUser:User;		  
		public var processed:Boolean;
		public var bbUploadDetail:Array;
		public var operatorLegacyID:String;
		public var uploadStatus:String;
		public var agreementNum:String;
		public var agreementName:String;

		
		/*-.........................................Constructor..........................................*/
		public function BBUploadHeader( bbh:BBUploadHeader = null)
		{
			if( bbh ) copy( bbh );
		}
		/*-.........................................Methods..........................................*/
		public function copy(bbh:BBUploadHeader):void
		{
			this.isSelected = bbh.isSelected;
			this.uploadID = bbh.uploadID ;
			this.bbHdrCounter = bbh.bbHdrCounter ;
			this.bbHeaderID = bbh.bbHeaderID ;
			this.vendorId = bbh.vendorId;//ok
			this.vendorName = bbh.vendorName;//ok
			this.shipTo = bbh.shipTo;//ok
			this.BBReference = bbh.BBReference;//ok
			this.billbackTitle = bbh.billbackTitle;//ok
			this.BBDate = bbh.BBDate;//ok
			this.startDate = bbh.startDate;//ok
			this.endDate = bbh.endDate;//ok
			this.BBAmount = bbh.BBAmount;//ok
			this.TotalVolume = bbh.TotalVolume;
			this.errMsg = bbh.errMsg;
			this.errType = bbh.errType;
			this.errObj = bbh.errObj;//-----------------
			this.uploadType = bbh.uploadType;
			this.locked = bbh.locked;
			this.lockedUser = bbh.lockedUser;
			this.lockedByOther = bbh.lockedByOther;
			this.lockedDateTime = bbh.lockedDateTime;
			this.uploadDateTime = bbh.uploadDateTime;
			this.updatedDate = bbh.updatedDate;
			this.uploadUser = bbh.uploadUser;		  
			this.processed = bbh.processed;
			this.bbUploadDetail = bbh.bbUploadDetail.concat(); //SHALLOW COPY IS OK HERE WE ARE NOT EDITING ANY OBJECTS (ARRAY OF com.Billback.Upload.models.vos.BBUploadDetail)
																//  BBUploadDetail needs a copy function (and so on) if we want a DEEP Copy
			this.operatorLegacyID = bbh.operatorLegacyID;
			this.uploadStatus = bbh.uploadStatus;
			this.agreementNum = bbh.agreementNum;
			this.agreementName = bbh.agreementName;
			
		}
	}
}
