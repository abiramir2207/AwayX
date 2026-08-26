<script language="JavaScript">

 var topMargin 	= 30 
 var slideTime	= 500
 //var ns6 = (!document.all && document.getElementById);
 /* Dev Note(57641) - Exclude IE 11. IE 11 code meeets this requirement -  (!document.all && document.getElementById), 
 but needs the IE code and so IE 11 has been exluded below. IE 11 needs the code used for ie4 (defined below)
 and so IE 11 conditional logic has been added for ie4 below.
 */
 var ns6 = (!document.all && document.getElementById) && (navigator.appVersion.indexOf("Trident") == -1); 
 //var ie4 = (document.all);
  /* Dev Note(57641) - IE 10 and below OR IE 11, i.e. all IE versions */
 var ie4 = (navigator.appVersion.indexOf("MSIE") != -1 || navigator.appVersion.indexOf("Trident") != -1);
 var ns4 = (document.layers);
 var Layer_Width = 300;
 var Layer_Height = 85;
 var storeinparent = 1;
 
 window.setInterval("main()", 10) 
	
function floatObject() { 
if (ns4 || ns6) {
 findHt =	window.innerHeight; 
 } else if(ie4) {
 findHt =	document.body.clientHeight;
 }
} 
	
function main() { 
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

 
 
 function layerDisplayToggle() {
	if(window.parent.Is_Layer_Visible == 0){
		if (storeinparent == 1) window.parent.Is_Layer_Visible = 1;
	}
	else {
		if (storeinparent == 1) window.parent.Is_Layer_Visible = 0;
	}
	switch(window.parent.Is_Layer_Visible) {
		case 0: //hide it
			oTable.style.display 		= 'none'
			minLabel.style.display 		= 'none'
			floatLayer.style.width 		= 20;
			floatLayer.style.height 	= 10;
			if (storeinparent == 1) window.parent.Is_Layer_Visible	= 0;
			expandSpan.style.display 	= ''
		break;

		case 1: //show it
			floatLayer.style.width 		= Layer_Width
			floatLayer.style.height 	= Layer_Height
			oTable.style.display 		= ''
			expandSpan.style.display 	= 'none'
			minLabel.style.display 		= ''
			if (storeinparent == 1) window.parent.Is_Layer_Visible 			= 1;
		break;
	}
 }

</script>

<style>
	.dataLabelStyle {
		color: Black;
		font_size: 20px;
	}
	.dataStyle {
		color: Green;
		font_size: 20px;
	}	
</style>

