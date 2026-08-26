<!-----------------------------------------------------------------------------

FILE NAME:		BBUploadLog.cfc
DESCRIPTION:	BB upload log fields declaration
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	26-May-2011	Created
							
------------------------------------------------------------------------------> 

<cfcomponent output="false" displayname="BBUploadLog" alias="mvc.Models.Billback.vos.BBUploadLog">
 
	<cfproperty name="uploadID" 				type="numeric" 	hint = "" />
	<cfproperty name="userUploaded" 			type="mvc.Models.Entity.vos.User" hint= "User who uploaded the file" />	
	<cfproperty name="totalHeaderCount"			type="numeric" 	hint = "" />
	<cfproperty name="totalHeaderCountFailed"	type="numeric" 	hint = "" />
	<cfproperty name="totalHeaderCountLoaded"	type="numeric" 	hint = "" />
	<cfproperty name="totalDetailCount"			type="numeric" 	hint = "" />
	<cfproperty name="totalDetailCountFailed"	type="numeric" 	hint = "" />
	<cfproperty name="totalDetailCountLoaded" 	type="numeric" 	hint = "" />
	<cfproperty name="uploadDate" 			  	type="Date" 	hint = "" />
	<cfproperty name="uploadStatus" 			type="string" 	hint = "" />
	<cfproperty name="deleted" 					type="boolean" 	hint = "" />		
	<cfproperty name="headerFileName" 			type="string" 	hint = "" />			
	<cfproperty name="detailFileName" 			type="string" 	hint = "" />	
	<cfproperty name="deletedBy" 				type="string" 	hint = "" />	
	<cfproperty name="deletedDate" 				type="Date"		hint = "" />
	<cfproperty name="uploadType"				type="string" 	hint = "" />	
	<cfproperty name="bbUploadHeader"	type="array" 	hint="array of mvc.Models.Billback.vos.BBUploadHeader"  />	
	<cfproperty name="bbUploadHeaderLog"		type="array" 	hint="array of mvc.Models.Billback.vos.BBUploadHeader"  />
    <cfproperty name="VendorSearchField"		type="string" 	hint = "" />	
	<cfproperty name="BBTitleSearchField"		type="string" 	hint = "" />	
	<cfproperty name="BBCodeSearchField"		type="string" 	hint = "" />	
 
	<cfscript>													
		this.uploadID 				= "";
		this.userUploaded 			= "";
		this.totalHeaderCount 		= "";
		this.totalHeaderCountFailed = "";
		this.totalHeaderCountLoaded = "";
		this.totalDetailCount 		= "";
		this.totalDetailCountFailed = "";
		this.totalDetailCountLoaded = "";
		this.uploadDate 			= "";
		this.uploadStatus 			= "";
		this.deleted 				= "";
		this.headerFileName 		= "";
		this.detailFileName 		= "";
		this.deletedBy 				= "";
		this.deletedDate			= "";
		this.uploadType				= "";
		this.bbUploadHeaderErrCorn	=  arrayNew(1);
		this.bbUploadHeaderLog 		=  arrayNew(1);
		this.VendorSearchField		= "";
		this.BBTitleSearchField		= "";
		this.BBCodeSearchField		= "";

	</cfscript>

	<cffunction name="init" output="false" returntype="BBUploadLog">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>