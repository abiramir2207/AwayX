<!---
Name: 			floating_layer.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:	N/A
Created By:		N/A
Description:	This file is a floating window in the program_form.cfm file that shows a summary of billback pounds, cases and amounts.  
--->


<script language="JavaScript">
 var topMargin 	= 5 
 var slideTime	= 500
 //var ns6 = (!document.all && document.getElementById);
 /* Dev Note(57641) - Exclude IE 11. IE 11 code meeets this requirement -  (!document.all && document.getElementById), 
 but needs the IE code and so IE 11 has been exluded below. IE 11 needs the code used for ie4 (defined below)
 and so IE 11 conditional logic has been added for ie4 below.
 */
 var ns6 = (!document.all && document.getElementById) && (navigator.appVersion.indexOf("Trident") == -1); 
 //var ie4 = (document.all); -- This will fail for IE 11 and so below logic needs to be used.
  /* Dev Note(57641) - IE 10 and below OR IE 11, i.e. all IE versions */
 var ie4 = (navigator.appVersion.indexOf("MSIE") != -1 || navigator.appVersion.indexOf("Trident") != -1);
 var ns4 = (document.layers);
 var Layer_Width = 310;
 var Layer_Height = 155;
 var storeinparent = 1;
 var allowScroll = true;
 
 window.setInterval("main()", 10) 
	
function floatObject() { 
if (ns4 || ns6) {
 findHt =	window.innerHeight; 
 } else if(ie4) {
 findHt =	document.body.clientHeight;
 }
} 
	
function main() { 
if(allowScroll == true){
if (ns4) { 
 this.currentY 	= document.floatLayer.top; 
 this.scrollTop	= window.pageYOffset;
 mainTrigger();
 } else if(ns6) {
 this.currentY = parseInt(document.getElementById('floatLayer').style.top); 
 this.scrollTop = scrollY;
  mainTrigger(); 
 } else if(ie4) { 
 this.currentY 	= floatLayer.style.pixelTop;
 this.scrollTop	= document.body.scrollTop;
 mainTrigger();
	} 
 } 
 function mainTrigger() { 
 var newTargetY	= this.scrollTop + this.topMargin 
 if ( this.currentY != newTargetY ) { 
 if ( newTargetY != this.targetY ) { 
 this.targetY = newTargetY
  floatStart();
  } 
  animator(); 
  } 
  } 
  function floatStart() { 
  var now	= new Date() 
  this.A		= this.targetY - this.currentY 
  this.B		= Math.PI / ( 2 * this.slideTime ) 
  this.C		= now.getTime() 
  if (Math.abs(this.A) > this.findHt) { 
  this.D = this.A > 0 ? this.targetY - this.findHt : this.targetY + this.findHt 
  this.A = this.A > 0 ? this.findHt : -this.findHt 
  } else {	 
  this.D = this.currentY 
   } 
  } 
  function animator() { 
  var now	= new Date() 
  var newY	= this.A * Math.sin( this.B * ( now.getTime() - this.C ) ) + this.D 
  newY		= Math.round(newY) 
  if (( this.A > 0 && newY > this.currentY ) || ( this.A < 0 && newY < this.currentY )) { 
  if ( ie4 )floatLayer.style.pixelTop = newY 
  if ( ns4 )document.floatLayer.top = newY
  if ( ns6 )document.getElementById('floatLayer').style.top = newY + "px" 
  } 
 }
 } 

 
 
 function layerDisplayToggle() {
	allowToggle = false;
	if(event != null){
		if(event.srcElement != null) {
			if(event.srcElement.tagName == "TD"){
				if(event.srcElement.id == "minButton"){
					allowToggle = true;
				}
				if(event.srcElement.id == "titlebar"){
					allowToggle = true;
				}
			}
			
			if(event.srcElement.tagName == "IMG"){
				if(event.srcElement.id == "smallLayer"){
					allowToggle = true;
				}
			}			

		}
	}
	
	if(windowStatus == -1) {
		allowToggle = true;
	}
	
	if(allowToggle == true) {

		if(windowStatus != -1) {
			if(oTable.style.display == "none") windowStatus = 1;
			else windowStatus = 0;
		}
		else windowStatus = 0
		
		
		switch(windowStatus) {
			case 0: //hide it
				oTable.style.display 		= 'none';
				minLabel.style.display 		= 'none';
				floatLayer.style.width 		= 80;
				floatLayer.style.height 	= 36;
				if (storeinparent == 1) window.parent.Is_Layer_Visible	= 0;
				expandSpan.style.display 	= '';
				document.getElementById('floatLayer').style.border = 'thin solid Navy';
			break;
	
			case 1: //show it
				floatLayer.style.width 		= Layer_Width;
				floatLayer.style.height 	= Layer_Height;
				oTable.style.display 		= '';
				expandSpan.style.display 	= 'none';
				minLabel.style.display 		= '';
				document.getElementById('floatLayer').style.border = 'thin solid Navy';

			break;
		}
	}
 }

 function RecalculateData()
 {
	AdjustRateTotal();
	updateVolume();
	layerDisplayToggle();
 }
</script>


<style>
	.dataLabelStyle {
		color: Black;
		font_size: 20px;
		font-weight: bold;
	}
	.dataStyle {
		color: Green;
		font_size: 20px;
		font-weight: bold;
	}	
</style>

<div id="floatLayer" style="position: absolute; top:6px; height:155px; width:310px; left:0px; z-index: 100; border: 1; border-style:thin solid; border-color:solid Navy; background-color:#FFFFFF; cursor:pointer;" onMouseover="isHot=true" onMouseout="isHot=false"> 
<!--- <div id="floatLayer" style="position: absolute; height:85px; width:0px; left:15px; top:1px; z-index: 100; border: 1 solid Navy; background-color: #CEEBFF;cursor:pointer;">  --->
  <div id="expandSpan" style="color:red;font-size:12px;cursor:pointer;display: none;" align="center" onclick="layerDisplayToggle();" title="View the itemized total compared to the claim summary"><img id="smallLayer" src="/images/view_summary_sm_txt.gif"></div>
  <table border="0" cellspacing="0" valign="top" cellpadding="2" align="center" id="oTable" onclick="layerDisplayToggle();" width="100%">
  <TR>
		<TD colspan="100%" valign="top" style="cursor:pointer; color: blue; font-weight:bold;" onclick="RecalculateData()">Recalculate <img src="/Images/i.gif" title="Depending on the number of products, this action might take time"></TD>
	</TR>
		<TR align="center">
		<td height="20" colspan="100%" style="color: white; font-weight:bold; background-color: Navy; cursor: move;" id="titleBar">Information Summary</td>
	</TR>
	<!---TSF: Label 9231 - Rearranged table to summarize billback data in a different view--->
	<TR>
		<td></td>
		<TD height="15" align="center"><u><b>$</b></u></TD>
		<TD height="15" align="center"><u><b>Cs</b></u></TD>
		<TD height="15" align="center"><u><b>Lbs</b></u></TD>
	</TR>
	<TR>
		<td><b>Claim Summary:</b></td>
		<TD class="dataStyle" align="center" nowrap="nowrap">$<SPAN id="Expected_Total_Rates"><cfoutput>#numberformat(getPayeeInfo.BB_AMount, ',_.__')#</cfoutput></SPAN></TD>
		<TD class="dataStyle" align="center" nowrap="nowrap"><SPAN id="Expected_Total_CS" nowrap><cfoutput>#numberformat(getPayeeInfo.Claim_Cases, ',_.__')#</cfoutput></SPAN></TD>
		<TD class="dataStyle" align="center" nowrap="nowrap"><SPAN id="Expected_Total_LB" nowrap><cfoutput>#numberformat(getPayeeInfo.Claim_Pounds, ',_.__')#</cfoutput></SPAN></TD>	
	</TR>
	<TR>
		<td><b>Itemized Total:</b></td>
		<TD class="dataStyle" align="center" nowrap="nowrap">$<SPAN id="Total_Rates">0.00</SPAN></TD>
		<TD class="dataStyle" align="center" nowrap="nowrap"><SPAN id="Grand_Total_Vol_CS">0.00</SPAN></TD>
		<TD class="dataStyle" align="center" nowrap="nowrap"><SPAN id="Grand_Total_Vol_LB">0.00</SPAN></TD>
	</TR>
	<TR>
		<td><b>Variance:</b></td>
		<TD class="dataStyle" align="center" nowrap="nowrap"><span id="dollarSign">$</span><SPAN id="Delta_Rates">0.00</SPAN></TD>
		<TD class="dataStyle" align="center" nowrap="nowrap"><SPAN id="Delta_Vol_CS" nowrap>0.00</SPAN></TD>
		<TD class="dataStyle" align="center" nowrap="nowrap"><SPAN id="Delta_Vol_LB" nowrap>0.00</SPAN></TD>
	</TR>
	<SPAN style="visibility:hidden" id="Total_Vol_LB" nowrap>0.00</SPAN>
	<SPAN style="visibility:hidden" id="Total_Vol_CS">0.00</SPAN>
  </table>
	
  <table border="0" cellspacing="0" cellpadding="0" align="center" id="minLabel">
	<TR>
		<TD height="30" style="cursor:pointer; color: blue; font-weight:bold;" onclick="layerDisplayToggle();" id="minButton">minimize this window</TD>		
	</TR>
  </table>
</div>

<form id="rateForm">
 <input type="hidden" name="exTotalRates" id="exTotalRates" value="<cfoutput>#getPayeeInfo.BB_AMount#</cfoutput>" />
 <input type="hidden" name="exTotalCS" id="exTotalCS" value="<cfoutput>#getPayeeInfo.Claim_Cases#</cfoutput>" />
 <input type="hidden" name="exTotalLB" id="exTotalLB" value="<cfoutput>#getPayeeInfo.Claim_Pounds#</cfoutput>" />
</form>

<script language="JavaScript1.2">

// Script Source: CodeLifter.com
// Copyright 2003
// Do not remove this header

isIE=document.all;
isHot=false;

function ddInit(e){
  topDog=isIE ? "BODY" : "HTML";
  whichDog=isIE ? document.all.floatLayer : document.getElementById("floatLayer");  
  hotDog=isIE ? event.srcElement : e.target;  
  while (hotDog.id!="titleBar"&&hotDog.tagName!=topDog){
    hotDog=isIE ? hotDog.parentElement : hotDog.parentNode;
  }  
  if (hotDog.id=="titleBar"){
    offsetx=isIE ? event.clientX : e.clientX;
    offsety=isIE ? event.clientY : e.clientY;
    nowX=parseInt(whichDog.style.left);
    nowY=parseInt(whichDog.style.top);
    ddEnabled=true;
    document.onmousemove=dd;
  }
}

function dd(e){
  if (!ddEnabled) return;
  whichDog.style.left=isIE ? nowX+event.clientX-offsetx : nowX+e.clientX-offsetx;

  <!--- too far left --->
  if (parseInt(whichDog.style.left) < 0) {
  	 whichDog.style.left = 0
  }
 
 <!--- too far right --->
  if((parseInt(whichDog.style.left)+parseInt(document.all.floatLayer.clientWidth))+20> document.frames.document.body.offsetWidth){
  	whichDog.style.left = document.frames.document.body.offsetWidth-parseInt(document.all.floatLayer.clientWidth)-20
  }

 <!--- too up --->
  whichDog.style.top=isIE ? nowY+event.clientY-offsety : nowY+e.clientY-offsety;
  if (parseInt(whichDog.style.top) < 0) {
	 whichDog.style.top=1	
  }

<!---  <!--- too down ---> 
  if (parseInt(whichDog.style.top) > (document.frames.document.body.offsetHeight-parseInt(document.all.floatLayer.clientWidth)-25)) {
	 whichDog.style.top=(document.frames.document.body.offsetHeight-parseInt(document.all.floatLayer.clientWidth)-25)
  } --->
  
  
  allowScroll = false;
  return false;  
}

function mouseUp(){
	ddEnabled=false

	topMargin=floatLayer.style.pixelTop - document.body.scrollTop
	allowScroll = true;
	//window.status=document.all.floatLayer.style.pixelTop
	//window.status=document.frames.document.body.offsetHeight-document.body.scrollTop
	//alert(document.all.floatLayer.offsetTop)
}

document.onmousedown=ddInit;
document.onmouseup=mouseUp;

</script>



