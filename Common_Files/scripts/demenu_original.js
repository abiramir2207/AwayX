//global context sensititve menu ID
var menuID = 0

//set the skin of the menu (0 or 1, with 1 rendering a default Windows menu like skin)
var menuskin=1

//set this variable to 1 if you wish the URLs of the highlighted menu to be displayed in the status bar
var display_url=0

//initialize an array to hold the names off all the select boxes on the page
var dropdown_names = new Array()
var dropdown_style = new Array()

function getDim(el){
	for (var lx=0,ly=0;el!=null;
		lx+=el.offsetLeft,ly+=el.offsetTop,el=el.offsetParent);
	return {x:lx,y:ly}
}

function showselectboxes() {
	for(var x=0; x< dropdown_names.length; x++){
			//alert(dropdown_names[x] + " - " + dropdown_style[x])
			eval('document.all.' + dropdown_names[x] + ".style.visibility = '" + dropdown_style[x] + "'")	
	}
}

function coor() {
window.status = "X=" + window.event.x + " Y=" +window.event.y;
}
//document.onmousemove = coor

function findselectboxes() {
	for(var y=0; y < document.all.length; y++){
		if(document.all[y].type != 'undefined'){
			if(document.all[y].type == "select-one"){
				dropdown_names[dropdown_names.length] = document.all[y].name
				dropdown_style[dropdown_style.length] = document.all[y].style.visibility				
			}
		}
	}
}


function hideselectboxes(mouseX,mouseY){
	for(var x=0; x< dropdown_names.length; x++){
		//alert(dropdown_names[x] + " - " + dropdown_style[x])
		//alert("saving:" + eval('document.all.' + dropdown_names[x] + '.style.visibility'))
		dropdown_style[x] = eval('document.all.' + dropdown_names[x] + '.style.visibility')				
		
		myFormObject = getDim(document.getElementById(dropdown_names[x]))
		
		//select box
		//top left
		SB_x1 = myFormObject.x;
		SB_y1 =	myFormObject.y;

		//top right
		SB_x2 = myFormObject.x + parseInt(eval('document.all.' + dropdown_names[x] + '.offsetWidth'));
		SB_y2 = myFormObject.y;

		//bottom right
		SB_x3 = myFormObject.x + parseInt(eval('document.all.' + dropdown_names[x] + '.offsetWidth'));
		SB_y3 = myFormObject.y + parseInt(eval('document.all.' + dropdown_names[x] + '.offsetHeight'));

		//bottom left
		SB_x4 = myFormObject.x;
		SB_y4 = myFormObject.y + parseInt(eval('document.all.' + dropdown_names[x] + '.offsetHeight'));

		//alert("(" + SB_x1 + "," + SB_y1 + ")" + "(" + SB_x2 + "," + SB_y2 + ")\n" + "(" + SB_x4 + "," + SB_y4 + ")" + "(" + SB_x3 + "," + SB_y3 + ")")

		//MENU
		//top left
		MU_x1 = mouseX;
		MU_y1 =	mouseY;

		//top right
		MU_x2 = mouseX + parseInt(ie5menu.clientWidth);
		MU_y2 = mouseY;
		
		//bottom right
		MU_x3 = mouseX + parseInt(ie5menu.clientWidth);
		MU_y3 = mouseY + parseInt(ie5menu.clientHeight);

		//bottom left
		MU_x4 = mouseX;
		MU_y4 = mouseY + parseInt(ie5menu.clientHeight);
		
		//alert("(" + MU_x1 + "," + MU_y1 + ")" + "(" + MU_x2 + "," + MU_y2 + ")\n" + "(" + MU_x4 + "," + MU_y4 + ")" + "(" + MU_x3 + "," + MU_y3 + ")")
		
		//
		if(MU_x1 >= SB_x1 && MU_x1 <= SB_x2 && MU_y1 <= SB_y4  && MU_y4 >= SB_y4){
			eval('document.all.' + dropdown_names[x] + ".style.visibility = 'hidden'")
		}
		
		if(MU_x2 >= SB_x1 && MU_x2 <= SB_x2 && MU_y1 <= SB_y4  && MU_y4 >= SB_y4){
			eval('document.all.' + dropdown_names[x] + ".style.visibility = 'hidden'")
		}

		if(MU_x1 >= SB_x1 && MU_x1 <= SB_x2 && MU_y4 <= SB_y4  && MU_y4 >= SB_y1){
			eval('document.all.' + dropdown_names[x] + ".style.visibility = 'hidden'")
		}

		if(MU_x2 >= SB_x1 && MU_x2 <= SB_x2 && MU_y3 <= SB_y3 && MU_y3 >= SB_y2){
			eval('document.all.' + dropdown_names[x] + ".style.visibility = 'hidden'")
		}

		if(MU_x1 <= SB_x1 && MU_x2 >= SB_x2 && MU_y1 <= SB_y1 && MU_y4 >= SB_y4){
			eval('document.all.' + dropdown_names[x] + ".style.visibility = 'hidden'")
		}

		if(MU_x1 <= SB_x1 && MU_x2 >= SB_x2 && MU_y1 >= SB_y1 && MU_y1 <= SB_y4){
			eval('document.all.' + dropdown_names[x] + ".style.visibility = 'hidden'")
		}
		
		if(MU_x1 <= SB_x1 && MU_x2 >= SB_x2 && MU_y4 >= SB_y1 && MU_y4 <= SB_y4){
			eval('document.all.' + dropdown_names[x] + ".style.visibility = 'hidden'")
		}

	}
}

function showmenuie5(){
	//getAttributesWindow('', ie5menu)

//Find out how close the mouse is to the corner of the window
var rightedge=document.body.clientWidth-event.clientX
var bottomedge=document.body.clientHeight-event.clientY



//if the horizontal distance isn't enough to accomodate the width of the context menu
if (rightedge<ie5menu.offsetWidth)
//move the horizontal position of the menu to the left by it's width
ie5menu.style.left=document.body.scrollLeft+event.clientX-ie5menu.offsetWidth
else
//position the horizontal position of the menu where the mouse was clicked
ie5menu.style.left=document.body.scrollLeft+event.clientX

//same concept with the vertical position
if (bottomedge<ie5menu.offsetHeight)
ie5menu.style.top=document.body.scrollTop+event.clientY-ie5menu.offsetHeight
else
ie5menu.style.top=document.body.scrollTop+event.clientY

showselectboxes()
hideselectboxes(parseInt(ie5menu.style.left), parseInt(ie5menu.style.top))


ie5menu.style.visibility="visible"



return false


}

function hidemenuie5(){
ie5menu.style.visibility="hidden"
showselectboxes()
}

function highlightie5(){
if (event.srcElement.className=="menuitems"){
event.srcElement.style.backgroundColor="dddddd"
event.srcElement.style.color="Navy"
if (display_url==1)
window.status=event.srcElement.url
}
}

function lowlightie5(){
if (event.srcElement.className=="menuitems"){
event.srcElement.style.backgroundColor=""
event.srcElement.style.color="black"
window.status=''
}
}

function jumptoie5(){
if (event.srcElement.className=="menuitems"){
if (event.srcElement.getAttribute("target")!=null)
window.open(event.srcElement.url,event.srcElement.getAttribute("target"))
else
window.location=event.srcElement.url
}
}