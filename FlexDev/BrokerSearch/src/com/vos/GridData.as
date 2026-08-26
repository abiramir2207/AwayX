package com.vos
{
	import flash.events.EventDispatcher;
	[Bindable]
	/**
	 * GridData is the object represented in Each row of the datagrid (dataprovider).
	 * @author msaunders
	 */
	public class GridData extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var baItem : String;
		public var distGuid : String;
		public var Description : String;
		public var Address : String;
		public var col1 : String;
		public var col2 : String;
		public var col3 : String;
		public var col4 : String;
		public var col5 : String;
		public var col6 : String;
		public var col7 : String;
		public var col8 : String;
		public var isSelected : Boolean;

		
		/*-.........................................Constructor..........................................*/
		public function GridData(	baItem : String 	=	"",
									distGuid : String 	=	"",
									Description : String 	=	"",
									Address : String 	=	"",
									col1 : String 	=	"",
									col2 : String 	=	"",
									col3 : String 	=	"",
									col4 : String 	=	"",
									col5 : String 	=	"",
									col6 : String 	=	"",
									col7 : String 	=	"",
									col8 : String 	=	"",	
									isSelected : Boolean 	=	false)
		
									
		{
			this.col1 = col1;
			this.baItem = baItem;
			this.distGuid = distGuid;
			this.Description = Description;
			this.Address = Address;
			this.col1 = col1;
			this.col2 = col2;
			this.col3 = col3;
			this.col4 = col4;
			this.col5 = col5;
			this.col6 = col6;
			this.col7 = col7;
			this.col8 = col8;
			this.isSelected = isSelected;
		}
			
		
		
		/*-.........................................Methods..........................................*/
		public function load(newGridData:Object):void 
		{
			this.col1 = newGridData.col1;
			this.baItem = newGridData.baItem;
			this.distGuid = newGridData.distGuid;
			this.Description = newGridData.Description;
			this.Address = newGridData.Address;
			this.col1 = newGridData.col1;
			this.col2 = newGridData.col2;
			this.col3 = newGridData.col3;
			this.col4 = newGridData.col4;
			this.col5 = newGridData.col5;
			this.col6 = newGridData.col6;
			this.col7 = newGridData.col7;
			this.col8 = newGridData.col8;
			this.isSelected = newGridData.isSelected;
			
		}

	}
}
