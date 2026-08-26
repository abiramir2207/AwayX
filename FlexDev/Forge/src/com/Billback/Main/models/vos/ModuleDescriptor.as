package com.Billback.Main.models.vos
{
	public class ModuleDescriptor
	{
		public var label:String;
		public var url:String;
		
		public function ModuleDescriptor( label:String, url:String )
		{
			this.label = label;
			this.url = url;
		}
	}
}