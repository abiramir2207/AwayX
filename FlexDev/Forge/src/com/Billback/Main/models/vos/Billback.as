package com.Billback.Main.models.vos 
{
	/**
	 * Billback Value Object: Container to hold the properites of a billback.   
	 */	
	

	import com.Billback.Main.models.vos.*;
	
	import flash.events.EventDispatcher;
	import flash.sampler.NewObjectSample;
		
	[Bindable]	
	[RemoteClass(alias="mvc.Models.Billback.vos.Billback")]
    public class Billback extends EventDispatcher
	{  
          public var bbHeader:BBHeader = new BBHeader();
          public var receivedDate:Date;
          public var postDate:Date;
          public var claimedAmount:Number;
          public var claimedCS:Number;
          public var claimedLB:Number;
          public var expectedAmount:Number;
          public var expectedCS:Number;
          public var expectedLB:Number;
          public var variedAmount:Number;
          public var variedCS:Number;
          public var variedLB:Number;
          public var bbNotes:String;
          public var bbDocs:Array = new Array();
          public var bbPrgDistItemRate:Array = new Array();
          public var bbComponent:Array = new Array();
          public var uomDp:Array = new Array();

		  /*-.........................................Constructor..........................................*/
		  public function Billback( bb:Billback = null)
		  {
			  if( bb ) copy( bb );
		  }
		  
		  /*-.........................................Methods..........................................*/
		  public function copy(bb:Billback):void
		  {
			  this.bbHeader = new BBHeader(bb.bbHeader);
			  this.receivedDate = bb.receivedDate;
			  this.postDate = bb.postDate;
			  this.claimedAmount = bb.claimedAmount;
			  this.claimedCS = bb.claimedCS;
			  this.claimedLB = bb.claimedLB;
			  this.expectedAmount = bb.expectedAmount;
			  this.expectedCS = bb.expectedCS;
			  this.expectedLB = bb.expectedLB;
			  this.variedAmount = bb.variedAmount;
			  this.variedCS = bb.variedCS;
			  this.variedLB = bb.variedLB;
			  this.bbNotes= bb.bbNotes;
			  this.bbDocs = bb.bbDocs;//new Array();
			  this.bbPrgDistItemRate = bb.bbPrgDistItemRate;//new Array();
			  this.bbComponent = bb.bbComponent;//new Array();
			  this.uomDp = bb.uomDp;//new Array();
		  }
	}
}
