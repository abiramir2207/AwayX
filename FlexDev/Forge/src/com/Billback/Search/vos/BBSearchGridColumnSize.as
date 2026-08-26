package com.Billback.Search.vos
{
	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBSearchGridColumnSize")]
	/**
	 ****************Payee is a child of Component.prodRate array******************
	 * @author Milan
	 */
	public class BBSearchGridColumnSize
	{
		/*-.........................................Properties..........................................*/
		public var status : int;
		public var BBCode : int;
		public var BBNumber : int;
		public var title : int;
		public var BBDate : int;
		public var payee : int;
		public var startDate : int;
		public var endDate : int;
		public var claimedAmount : int;
		public var approvedAmount : int;		
		public var closingMethod: int;
		public var moreInfo:int;
		public var vendor:int;
		public var BBReceivedDate : int;
		
		/*-.........................................Constructor..........................................*/
		public function BBSearchGridColumnSize( 
									status:int = 0,
									BBCode:int = 0,
									BBNumber:int = 0,
									title:int = 0,
									BBDate:int = 0,
									payee:int = 0,
									startDate:int  = 0,
									endDate:int  = 0,
									claimedAmount:int  = 0,
									approvedAmount:int  = 0,
									closingMethod:int  = 0,
									moreInfo:int = 0,
									vendor:int = 0,
									BBReceivedDate: int = 0
					 )
		{
			this.status = status;
			this.BBCode = BBCode;
			this.BBNumber = BBNumber;
			this.title = title;
			this.BBDate = BBDate;
			this.payee = payee;
			this.startDate = startDate;
			this.endDate =  endDate;
			this.claimedAmount = claimedAmount;
			this.approvedAmount = approvedAmount;
			this.closingMethod = closingMethod;
			this.moreInfo = moreInfo;
			this.vendor = vendor;	
			this.BBReceivedDate = BBReceivedDate;
		}

	}
}