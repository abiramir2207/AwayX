/**
* GridData is the object represented in Each row of the datagrid (dataprovider).
*/
package com.vos
{

	[Bindable]
	[RemoteClass(alias="mvc.Models.BillbackDevApp.GridData")]
	/**
	 * GridData is the object represented in Each row of the datagrid (dataprovider).
	 */ 
	public class GridData
	{
		/*-.........................................Properties..........................................*/
		public var baData : String;
		public var isSelected : Boolean;

	}
}


/* package com.vos
{
	import flash.events.EventDispatcher;
=======

>>>>>>> 1.2
	[Bindable]
	[RemoteClass(alias="mvc.Models._ProjectTemplate.GridData")]
	public class GridData
	{
		/ * -.........................................Properties.......................................... * /
		public var baData : String;
		public var isSelected : Boolean;

<<<<<<< GridData.as
		
		/ * -.........................................Constructor.......................................... * /
		public function GridData(	baData : String 	=	"",
									isSelected : Boolean 	=	false)
		
									
		{
			this.baData = baData;
			this.isSelected = isSelected;
		}
			
		
		
		/ * -.........................................Methods.......................................... * /
		public function load(newGridData:Object):void 
		{
			this.baData = newGridData.baData;
			this.isSelected = newGridData.isSelected;
			
		}

=======
>>>>>>> 1.2
	}
} */
