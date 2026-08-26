package com.shared.vos
{

	[Bindable]
	[RemoteClass(alias="mvc.Models.Program.Component.vos.CustomPrint")]
						  
	/**
	 * CustomPrint is a child of Item used to
	 * Calculate Custom charges at the item level.
	 * @author msaunders
	 */
	public class CustomPrint
	{
		/*-.........................................Properties..........................................*/
		public var bCustomPrint : Boolean;
		public var iColors : int = 0;
		public var sGraphics : String = '';
		public var bDigital : Boolean;
		
		/*-.........................................Constructor..........................................*/
		public function CustomPrint( custPrint:CustomPrint = null )
		{
			if( custPrint ) copy( custPrint );
		}
		/*-.........................................Methods..........................................*/
		public function copy( custPrint:CustomPrint ):void
		{
			this.bCustomPrint 		= custPrint.bCustomPrint;
			this.iColors			= custPrint.iColors;
			this.sGraphics			= custPrint.sGraphics;
			this.bDigital			= custPrint.bDigital;
		}
		//reset the options
		public function reset():void{
			this.iColors			= 0;
			this.sGraphics			= '';
			this.bDigital			= false;
		}
	}
}