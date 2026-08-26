package com.vos
{
	import flash.events.EventDispatcher;

	[Bindable]
	[RemoteClass(alias="mvc.Models.Program.vos.SearchGridColumnSize")]
	/**
	 * @author Milan
	 */
	
	public class SearchGridColumnSize extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		/*  These are the default values for the grid's width - for 1024/768 resolution.
		Note: These values will get overwritten by the values saved by the user from the application using the
		slider control.		
		*/
		public var status: int = 55;
		public var rfaAge: int = 55;
		public var program: int = 92;
		public var title: int = 86;
		public var type: int = 92;
		public var startDate: int = 75;
		public var endDate: int = 75;
		public var rsp: int = 65;
		/* optional column */
		public var businessSegment: int = 0;
		/* (start) These 3 columns are added later. One or more may be ON for a client (optional columns) */
		public var tradeDollars: int = 0;
		public var paymentDollars: int = 0;
		public var volume: int = 0;
		/* (end) These 3 columns are added later. One or more may be ON for a client (optional columns)  */
		public var moreInfo: int = 74;			
		public var includeColumnList: Array;
		
		
		/*-.........................................Constructor..........................................*/
		/*
		public function SearchGridColumnSize( 
			status:int = 0,
			rfaAge:int = 0,
			program:int = 0,
			title:int = 0,
			type:int = 0,
			startDate:int  = 0,
			endDate:int  = 0,
			rsp:int  = 0,
			moreInfo:int  = 0
		)
		{
			this.status = status;
			this.rfaAge = rfaAge;
			this.program = program;
			this.title = title;
			this.type = type;
			this.startDate = startDate;
			this.endDate =  endDate;
			this.rsp = rsp;
			this.moreInfo = moreInfo;	
		}		
		*/
	}
}