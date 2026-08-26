component alias="mvc.Models.Billback.vos.Billback" output="false"
{
	property name="bbHeader" type="mvc.Models.Billback.vos.BBHeader";
	// Other Billback properties not in BB Header
	property name="receivedDate" type="date";
	property name="postDate" type="date";
	// claimed
	property name="claimedAmount" type="numeric";
	property name="claimedCS" type="numeric";
	property name="claimedLB" type="numeric";
	// exptected
	property name="expectedAmount" type="numeric";
	property name="expectedCS" type="numeric";
	property name="expectedLB" type="numeric";
	// variation
	property name="variedAmount" type="numeric";
	property name="variedCS" type="numeric";
	property name="variedLB" type="numeric";

	property name="bbNotes" type="string";
	property name="bbDocs" type="array";

	// Billback Programs
	property name="bbPrgDistItemRate" type="array";
	/* This is moved BBHeader Object	*/
	/* property name="bbClosingDetail" type="array"; */

	property name="bbComponent"		type="array";

	property name="uomDp" type="array";

	// initialize
	this.BBHeader = '';
	// Other Billback properties not in BB Header
	this.receivedDate = '#now()#';
	this.postDate = '#now()#';
	// claimed
	this.claimedAmount = 0;
	this.claimedCS = 0;
	this.claimedLB = 0;
	// exptected
	this.expectedAmount = 0;
	this.expectedCS = 0;
	this.expectedLB = 0;
	// variation
	this.variedAmount = 0;
	this.variedCS = 0;
	this.variedLB = 0;

	this.bbNotes = '';
	this.bbDocs = '';

	// Billback Programs
	this.bbPrgDistItemRate = arrayNew(1);

// 	this.bbClosingDetail = arrayNew(1);

	this.bbComponent = arrayNew(1);

	this.uomDp = arrayNew(1);

	// init function

	public function init(bbHeader="",
						  receivedDate="#now()#",
						  postDate="#now()#",
						  claimedAmount=0,
						  claimedCS=0,
	                      claimedLB=0,
	                      expectedAmount=0,
	                      expectedCS=0,
	                      expectedLB=0,
	                      variedAmount=0,
	                      variedCS=0,
	                      variedLB=0,
	                      bbNotes="",
	                      bbDocs="",
	                      bbPrgDistItemRate=arrayNew(1),
	                      bbComponent=arrayNew(1),
	                      uomDp=arrayNew(1)) output="false" returntype="mvc.Models.Billback.vos.Billback"
	{
		this.bbHeader 			=	arguments.bbHeader;
		this.receivedDate 		=	arguments.receivedDate ;
		this.postDate 			=	arguments.postDate ;
		this.claimedAmount 		=	arguments.claimedAmount ;
		this.claimedCS 			=	arguments.claimedCS ;
		this.claimedLB 			=	arguments.claimedLB ;
		this.expectedAmount		=	arguments.expectedAmount ;
		this.expectedCS 		=	arguments.expectedCS ;
		this.expectedLB 		=	arguments.expectedLB ;
		this.variedAmount 		=	arguments.variedAmount ;
		this.variedCS 			=	arguments.variedCS ;
		this.variedLB 			=	arguments.variedLB ;
		this.bbNotes			=	arguments.bbNotes;
		this.bbDocs				=	arguments.bbDocs;
		this.bbPrgDistItemRate	= 	arguments.bbPrgDistItemRate;
		// this.bbClosingDetail	= 	arguments.bbClosingDetail;
		this.bbComponent		=	arguments.bbComponent ;
		this.uomDp				=	arguments.uomDp ;
		return this;
	}

}