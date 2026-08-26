function lib_bwcheck(){ //Browsercheck (needed)
	this.ver=navigator.appVersion
	this.agent=navigator.userAgent
	this.dom=document.getElementById?1:0
	this.opera5=this.agent.indexOf("Opera 5")>-1
	this.ie5=(this.ver.indexOf("MSIE 5")>-1 && this.dom && !this.opera5)?1:0; 
	this.ie6=(this.ver.indexOf("MSIE 6")>-1 && this.dom && !this.opera5)?1:0;
	this.ie4=(document.all && !this.dom && !this.opera5)?1:0;
	this.ie=this.ie4||this.ie5||this.ie6
	this.mac=this.agent.indexOf("Mac")>-1
	this.ns6=(this.dom && parseInt(this.ver) >= 5) ?1:0; 
	this.ns4=(document.layers && !this.dom)?1:0;
	this.bw=(this.ie6 || this.ie5 || this.ie4 || this.ns4 || this.ns6 || this.opera5)
	return this
}
var bw=new lib_bwcheck()


// Variables to set:

messages= new Array()
// Write your descriptions in here.
//messages[0]="Toggle fade effect"
// To have more descriptions just add to the array.

fromX= -1           // How much from the actual mouse X should the description box appear?
fromY= 21           // How much from the actual mouse Y should the description box appear?
ns4center= 1        // Centering the text in ns4 doesn't work with css, use this variable instead... the value is 1 or 0
useFading= 0        // 1 for a fading effect in windows explorer 5+ and all platforms ns6, 0 for no fading effect.
animation= 1        // 1 if you want animation, 0 for no animation.
detectiontype= 0    // 1 for 'smooth' window size detection, 0 for 'flip' window size detection.
delay= 1          // The time before showing the popup, in milliseconds.


/*** There should be no need to change anything beyond this. ***/ 

// A unit of measure that will be added when setting the position of a layer.
var px = bw.ns4||window.opera?"":"px";

if(document.layers){ //NS4 resize fix.
    scrX= innerWidth; scrY= innerHeight;
    onresize= function(){if(scrX!= innerWidth || scrY!= innerHeight){history.go(0)} };
}

// object constructor...
function makeTooltip(obj){								
   	this.elm= document.getElementById? document.getElementById(obj):bw.ie4?document.all[obj]:bw.ns4?document.layers[obj]:0;
   	this.css= bw.ns4?this.elm:this.elm.style;
   	this.wref= bw.ns4?this.elm.document:this.elm;
	this.obj= obj+'makeTooltip'; eval(this.obj+'=this');
	this.w= bw.ns4? this.elm.clip.width: this.elm.offsetWidth;
	this.h= bw.ns4? this.elm.clip.height: this.elm.offsetHeight;
};
makeTooltip.prototype.measureIt= function(){
	this.w= bw.ns4? this.elm.clip.width: this.elm.offsetWidth;
	this.h= bw.ns4? this.elm.clip.height: this.elm.offsetHeight;
};
makeTooltip.prototype.writeIt= function(text){
	if (bw.ns4) {this.wref.write(text); this.wref.close()}
	else this.wref.innerHTML= text;
};

// Mousemove detection
var mouseX=0,mouseY=0,setX=0,setY=0;
function getMousemove(e){
	mouseX= (bw.ns4||bw.ns6)? e.pageX: bw.ie&&bw.win&&!bw.ie4? (event.clientX-2)+document.body.scrollLeft : event.clientX+document.body.scrollLeft;
	mouseY= (bw.ns4||bw.ns6)? e.pageY: bw.ie&&bw.win&&!bw.ie4? (event.clientY-2)+document.body.scrollTop : event.clientY+document.body.scrollTop;
	if (isLoaded && hovering && animation) placeIt();
};
function placeIt(){
	if (detectiontype==1) setX= mouseX+fromX+tooltip.w > screenWscrolled ? screenWscrolled-tooltip.w: mouseX+fromX;
	if (detectiontype==1) setY= mouseY+fromY+tooltip.h > screenHscrolled ? screenHscrolled-tooltip.h: mouseY+fromY;
	if (detectiontype==0) setX= mouseX+fromX+tooltip.w > screenWscrolled ? mouseX-fromX-tooltip.w: mouseX+fromX;
	if (detectiontype==0) setY= mouseY+fromY+tooltip.h > screenHscrolled ? mouseY-fromY-tooltip.h: mouseY+fromY;
	if (setX<0) setX= 0;
	if (setY<0) setY= 0;
	tooltip.css.left= setX+px;
	tooltip.css.top= setY+px;
};

// Main popUp function.
var hovering=false, screenWscrolled=0, screenHscrolled=0; pageXOffset=0; pageYOffset=0;
makeTooltip.prototype.showTimer= null;
function popUp(num){
	if(isLoaded){
		clearTimeout(tooltip.popTimer);
		dopopOut();
		if(num >= 0)
		{
			if (bw.ns4){
				var text= '<span class="netscape4Style">' + (ns4center?'<center>':"") + messages[num] + (ns4center?'</center>':"") + '</span>';
				tooltip.writeIt(text);
			}
			if (!bw.ns4) tooltip.writeIt(messages[num]);
		}
		screenWscrolled= screenW + (bw.ie?document.body.scrollLeft:pageXOffset);
		screenHscrolled= screenH + (bw.ie?document.body.scrollTop:pageYOffset);
		hovering= true;
		
		/* I'm using a timeout for ie4 here, because it doesn't store the measurements quickly enough. Does anybody know why this happens? */
		if (bw.ie4) setTimeout('tooltip.measureIt(); placeIt();', delay/2);
		else { tooltip.measureIt(); placeIt(); }
		if (useFading) tooltip.showTimer= setTimeout('tooltip.blendIn()', delay);
		if (!useFading) tooltip.showTimer= setTimeout('tooltip.css.visibility="visible"', delay);
    }
};

// Hiding routines
makeTooltip.prototype.popTimer= null;
function popOut(){
	if (isLoaded) tooltip.popTimer= setTimeout('dopopOut()', 30)
};
function dopopOut(){
	hovering= false;
	clearTimeout(tooltip.showTimer);
	tooltip.css.visibility= 'hidden';
	clearTimeout(tooltip.fadeTimer);
	tooltip.i= 0;
};

// Measure screensize.
var innerWidth = 0;
var innerHeight = 0;
var scrollbarWidth= bw.ns6&&bw.win?14:bw.ns6&&!bw.win?16:bw.ns4?16:0;
function measureScreen() {
	tooltip.css.top= 0+px;
	tooltip.css.left= 0+px;
	screenW= (bw.ie?document.body.clientWidth:innerWidth) - scrollbarWidth;
	screenH= (bw.ie?document.body.clientHeight:innerHeight);
};

// Opacity methods.
makeTooltip.prototype.blendIn= function(){
	if (bw.ie && bw.win && !bw.ie4) {
		this.css.filter= 'blendTrans(duration=0.5)';
		this.elm.filters.blendTrans.apply();
		this.css.visibility= 'visible';
		this.elm.filters.blendTrans.play();
	}
	else {
		this.css.visibility= 'visible';
		if (!bw.ns4) this.fadeIt();
	}
};
makeTooltip.prototype.step= 8;
makeTooltip.prototype.i= 0;
makeTooltip.prototype.fadeTimer= null;
makeTooltip.prototype.fadeIt= function(){
	this.i+= this.step;
	//this.css.filter= 'alpha(opacity='+this.i+')';
	this.css.MozOpacity= this.i/100;
	if (this.i<100) this.fadeTimer= setTimeout(this.obj+'.fadeIt()', 40);
	else this.i= 0;
};

// Init function...
var isLoaded= false;
function popupInit(){
	//Fixing the browsercheck for opera... this can be removed if the browsercheck has been updated!!
	bw.opera5 = (navigator.userAgent.indexOf("Opera")>-1 && document.getElementById)?true:false
	if (bw.opera5) bw.ns6 = 0
	
	//Extending the browsercheck to add windows platform detection.
	bw.win= (navigator.userAgent.indexOf('Windows')>-1)

	tooltip= new makeTooltip('divTooltip');
	tooltip.elm.onmouseover= function(){ clearTimeout(tooltip.popTimer); if(bw.ns4){setTimeout('clearTimeout(tooltip.popTimer)',20)}; };
	tooltip.elm.onmouseout= dopopOut;
	if (bw.ns4) document.captureEvents(Event.MOUSEMOVE);
	document.onmousemove= getMousemove;
	measureScreen();
	if (!bw.ns4) onresize= measureScreen;
	if (!bw.ns4) tooltip.elm.className= 'normalStyle';
	if (bw.ie && bw.win && !bw.ie4) tooltip.css.filter= 'alpha(opacity=100)'; //Preloads the windows filters.
	isLoaded= true;
};

// Initiates page on pageload if the browser is ok.
//if(bw.bw && !isLoaded) onload= popupInit;