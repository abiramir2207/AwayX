
package com.Billback.Main.models
{
	import com.Billback.Upload.models.vos.BBRawEDIHeader;
	import com.shared.models.IModuleBa;
	
	import flash.events.IEventDispatcher;
	
	import mx.core.IUIComponent;
	
	public interface IBBRawEDI  extends IModuleBa
	{
		function setBBRawEDI(bbREH:BBRawEDIHeader):void;
		function getBBRawEDI():BBRawEDIHeader;
	}
}