
package com.Billback.Main.models
{
	import com.Billback.Upload.models.vos.BBUploadHeader;
	import com.shared.models.IModuleBa;
	
	import flash.events.IEventDispatcher;
	
	import mx.core.IUIComponent;
	
	public interface IBBUpload  extends IModuleBa
	{
		//function setUserId(uid:String):void;
		function setBB(bbh:BBUploadHeader):void;
		function getBB():BBUploadHeader;
	}
}