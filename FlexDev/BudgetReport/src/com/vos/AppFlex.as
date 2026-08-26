package com.vos
{
	public class AppFlex
	{
		/*-.........................................Properties..........................................*/
		public var var1 : String;
		public var var2 : String;

		
		/*-.........................................Constructor..........................................*/
		public function AppFlex(	var1 : String 	=	"",
									var2 : String 	=	"")
		
									
		{
			this.var1 = var1;
			this.var2 = var2;
		}
			
		
		
		/*-.........................................Methods..........................................*/
		public function load(newAppFlex:AppFlex):void 
		{
			this.var1 = newAppFlex.var1;
			this.var2 = newAppFlex.var2;   
			
		}

	}
}