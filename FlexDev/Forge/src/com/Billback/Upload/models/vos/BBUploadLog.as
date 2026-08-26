package com.Billback.Upload.models.vos
{
	import com.shared.models.entity.vos.User;
	
	import flash.events.EventDispatcher;

	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBUploadLog")]
    public class BBUploadLog extends EventDispatcher
	{  
          public var uploadID:int;
          public var userUploaded:User;
          public var totalHeaderCount:int;
          public var totalHeaderCountFailed:int;
          public var totalHeaderCountLoaded:int;
          public var totalDetailCount:int;
          public var totalDetailCountFailed:int;
          public var totalDetailCountLoaded:int;
          public var uploadDate:Date;
          public var uploadStatus:String;
          public var deleted:Boolean;
          public var headerFileName:String;
          public var detailFileName:String;
          public var deletedBy:String;
          public var deletedDate:Date;
          public var uploadType:String;
          public var bbUploadHeader:Array;
          public var bbUploadHeaderLog:Array;
		  public var VendorSearchField:String;
		  public var BBTitleSearchField:String;
		  public var BBCodeSearchField:String;
		  
          public function BBUploadLog()
	      {
		  }    
	}
}
