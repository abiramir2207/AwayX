var doNotRelocate = 0;

//URL variable
var URLstring="";

//set the skin of the menu (0 or 1, with 1 rendering a default Windows menu like skin)
var menuskin=1

//global context sensititve menu ID
var menuID= 0
LayerID = "ie5menu_" + menuID

//set this variable to 1 if you wish the URLs of the highlighted menu to be displayed in the status bar
var display_url=0

//initialize an array to hold the names off all the select boxes on the page
var dropdown_names = new Array()
var dropdown_style// = new Array()

function getDim(el){
	for (var lx=0,ly=0;el!=null;
		lx+=el.offsetLeft,ly+=el.offsetTop,el=el.offsetParent);
	return {x:lx,y:ly}
}

function showselectboxes()
{
	try
	{
		var thisObj;
		for(var x=0; x< dropdown_names.length; x++)
		{
			eval('thisObj=document.all.' + dropdown_names[x] + ";");
			if(!thisObj.tagName && thisObj.length)
			{
				for(y=0;y<thisObj.length;y++)
				{
					if(thisObj[y].type)
					{
						if(thisObj[y].type == "select-one" || thisObj[y].type == "select-multiple")
						{
							thisObj[y].style.visibility=dropdown_style[x][y];
						}
					}
				}
			}
			else
			{
				thisObj.style.visibility = dropdown_style[x];
			}
		}
	}
	catch(e)
	{
		//alert(e.description  + dropdown_names[x] + " " + dropdown_style[x] + " " + " 2");
	}
}

function coor() {
window.status = "X=" + window.event.x + " Y=" +window.event.y;
}
//document.onmousemove = coor

function findselectboxes() {
	for(var y=0; y < document.all.length; y++){
		if(document.all[y].type != null){
			if(document.all[y].type == "select-one" || document.all[y].type=="select-multiple")
			{
				if(document.all[y].name)
					//setDropDownValues(document.all[y].name,document.all[y].style.visibility)
						setDropDownValues(document.all[y].name)
			}
		}
	}
}


function thisNameExists(ar,n)
{
	var arLen = ar.length;
	for(i=0;i<arLen;i++)
	{
		if(ar[i] == n)
			return true;
	}
	return false;
}

//function setDropDownValues(oName, oStyle){
function setDropDownValues(oName){
	if(!thisNameExists(dropdown_names,oName))
		dropdown_names[dropdown_names.length] = oName;
	//dropdown_style[dropdown_style.length] = oStyle;
}

function hideselectboxes(mouseX,mouseY){
	//alert("hide");
	dropdown_style = new Array()
	try
	{
		for(var x=0; x< dropdown_names.length; x++){
		//alert(dropdown_names[x] + " - " + dropdown_style[x])
		//alert("saving:" + eval('document.all.' + dropdown_names[x] + '.style.visibility'))

		var thisObj;
		eval('thisObj=document.all.' + dropdown_names[x] + ';');
			if(!thisObj.tagName && thisObj.length)
			{

				for(y=0;y<thisObj.length;y++)
				{
					if(thisObj[y].type)
					{
						if(thisObj[y].type == "select-one" || thisObj[y].type == "select-multiple")
						{
							if(!dropdown_style[x])
								dropdown_style[x]=new Array();
							dropdown_style[x][y]=thisObj[y].style.visibility;
							hideThisObj(thisObj[y],mouseX,mouseY);
						}
					}
				}
			}
			else
			{
				dropdown_style[x] = thisObj.style.visibility;
				hideThisObj(thisObj,mouseX,mouseY);
			}
		}
	}
	catch(e)
	{
		//alert(e.description  + dropdown_names[x] + " " + " 1");
	}
}




function hideThisObj(thisObj,mouseX,mouseY)
{
		myFormObject = getDim(thisObj)

		//select box
		//top left
		SB_x1 = myFormObject.x;
		SB_y1 =	myFormObject.y;

		//top right
		SB_x2 = myFormObject.x + thisObj.offsetWidth;
		SB_y2 = myFormObject.y;

		//bottom right
		SB_x3 = myFormObject.x + thisObj.offsetWidth;
		SB_y3 = myFormObject.y + thisObj.offsetHeight;

		//bottom left
		SB_x4 = myFormObject.x;
		SB_y4 = myFormObject.y + thisObj.offsetHeight;

		//alert("(" + SB_x1 + "," + SB_y1 + ")" + "(" + SB_x2 + "," + SB_y2 + ")\n" + "(" + SB_x4 + "," + SB_y4 + ")" + "(" + SB_x3 + "," + SB_y3 + ")")

		//MENU
		//top left
		MU_x1 = mouseX;
		MU_y1 =	mouseY;

		//top right
		MU_x2 = mouseX + parseInt(eval(LayerID + ".clientWidth"));
		MU_y2 = mouseY;

		//bottom right
		MU_x3 = mouseX + parseInt(eval(LayerID + ".clientWidth"));
		MU_y3 = mouseY + parseInt(eval(LayerID + ".clientHeight"));

		//bottom left
		MU_x4 = mouseX;
		MU_y4 = mouseY + parseInt(eval(LayerID + ".clientHeight"));

		//alert("(" + MU_x1 + "," + MU_y1 + ")" + "(" + MU_x2 + "," + MU_y2 + ")\n" + "(" + MU_x4 + "," + MU_y4 + ")" + "(" + MU_x3 + "," + MU_y3 + ")")

		//
		if(MU_x1 >= SB_x1 && MU_x1 <= SB_x2 && MU_y1 <= SB_y4  && MU_y4 >= SB_y4){
			thisObj.style.visibility = 'hidden';
		}

		if(MU_x2 >= SB_x1 && MU_x2 <= SB_x2 && MU_y1 <= SB_y4  && MU_y4 >= SB_y4){
			thisObj.style.visibility = 'hidden';
		}

		if(MU_x1 >= SB_x1 && MU_x1 <= SB_x2 && MU_y4 <= SB_y4  && MU_y4 >= SB_y1){
			thisObj.style.visibility = 'hidden';
		}

		if(MU_x2 >= SB_x1 && MU_x2 <= SB_x2 && MU_y3 <= SB_y3 && MU_y3 >= SB_y2){
			thisObj.style.visibility = 'hidden';
		}

		if(MU_x1 <= SB_x1 && MU_x2 >= SB_x2 && MU_y1 <= SB_y1 && MU_y4 >= SB_y4){
			thisObj.style.visibility = 'hidden';
		}

		if(MU_x1 <= SB_x1 && MU_x2 >= SB_x2 && MU_y1 >= SB_y1 && MU_y1 <= SB_y4){
			thisObj.style.visibility = 'hidden';
		}

		if(MU_x1 <= SB_x1 && MU_x2 >= SB_x2 && MU_y4 >= SB_y1 && MU_y4 <= SB_y4){
			thisObj.style.visibility = 'hidden';
		}
}



var internal_ID = 0;
var an_ID=0 //a global ID for the profiles to use


function showmenuie5()
{
	_active_Element = document.activeElement;   // track focused element for copy/paste
	if(event.ctrlKey) {
		return true;
	}
	hidemenuie5();

	_selected_Text = '';           // track selected text for copy/paste
    if ( window.getSelection ) {
        _selected_Text = window.getSelection().toString();
    }
    else if (document.selection && document.selection.type != "Control") {
        _selected_Text = document.selection.createRange().text;
    }
    if ( 0 && console ) { console.log('_selected_Text = ' + _selected_Text); }

	internal_ID = an_ID;
	LayerID = "ie5menu_" + menuID;
	var rightClickMenu = document.getElementById(LayerID);

	//Find out how close the mouse is to the corner of the window
	var rightedge  = document.body.clientWidth  - event.clientX;
	var bottomedge = document.body.clientHeight - event.clientY;

	var mousePos = mouseClickPosition(event);
	/* The above function returns an array of mouse X and Y positions. */
	var mouseClickPositionX = mousePos[0];
	var mouseClickPositionY = mousePos[1];

	var left_position = null;
	//if the horizontal distance isn't enough to accomodate the width of the context menu
	if (rightedge < rightClickMenu.offsetWidth) {
		//move the horizontal position of the menu to the left by it's width
		left_position = document.body.scrollLeft + event.clientX - rightClickMenu.offsetWidth;
	}
	else {
		//position the horizontal position of the menu where the mouse was clicked
		left_position = mouseClickPositionX;
	}
	rightClickMenu.style.left = left_position + 'px';

	var top_position = null;
	//same concept with the vertical position
	if (bottomedge < rightClickMenu.offsetHeight) {
		top_position = document.body.scrollTop + event.clientY - rightClickMenu.offsetHeight;
	}
	else {
		top_position = mouseClickPositionY;
	}
	rightClickMenu.style.top = top_position + 'px';
	if ( 0 && console ) { console.log("\n\n\n\n left = ", left_position, " top = ", top_position, ' offsetWidth = ', rightClickMenu.offsetWidth); }

	hideselectboxes(parseInt(left_position), parseInt(top_position));
	rightClickMenu.style.visibility = 'visible';

	//reset the menu ID
	menuID = 0;
	return false;
}

function mouseClickPosition(event)
{
	
	arrMouseClickPosition = new Array();
	//All IE browsers meet this condition. 
	if ((event.clientX || event.clientY)
		&& document.body
		&& document.body.scrollLeft!=null)
	{
			clickX = event.clientX + document.body.scrollLeft;
			clickY = event.clientY + document.body.scrollTop;
	}
	//All IE browsers meet this condition. 
	if ((event.clientX || event.clientY)
		&& document.compatMode=='CSS1Compat'
		&& document.documentElement
		&& document.documentElement.scrollLeft!=null)
	{
			clickX = event.clientX + document.documentElement.scrollLeft;
			clickY = event.clientY + document.documentElement.scrollTop;
	}
	// IE 10 and below do not meet this condition.
	//This code is meant for IE 11. Perhaps future IE versions will support it too.
	//
	if (event.pageX || event.pageY)
	{
			clickX = event.pageX /// ChromeFix remove the 'px'
			clickY = event.pageY;
	}
		arrMouseClickPosition.push(clickX);
		arrMouseClickPosition.push(clickY);

	/* return the x and y position where the mouse was clicked. */
	return arrMouseClickPosition;
}

function hidemenuie5()
{
	try
	{
		if(eval(LayerID) != null)
		{
			eval(LayerID + ".style.visibility='hidden'")
		}
		if(dropdown_style)
			showselectboxes()
	}
	catch(e)
	{
		//alert(e.description + " 3");
	}
}

function highlightie5()
{
	if (event.srcElement.className=="menuitems")
	{
		if(event.srcElement.tagName == "DIV"){
			event.srcElement.style.backgroundColor="dddddd"
			event.srcElement.style.color="Navy"
			if (display_url==1)
			window.status=event.srcElement.url
		}

		if(event.srcElement.tagName == "IMG"){
			//event.srcElement.parentElement.fireEvent("onmouseover")
			event.srcElement.style.backgroundColor="dddddd"
			event.srcElement.style.color="Navy"
			if (display_url==1)
			window.status=event.srcElement.url
		}
	}
}

function lowlightie5()
{
	if (event.srcElement.className=="menuitems")
	{
		if(event.srcElement.tagName == "DIV"){
			event.srcElement.style.backgroundColor=""
			event.srcElement.style.color="black"
			window.status=''
		}

		if(event.srcElement.tagName == "IMG"){
			//event.srcElement.parentElement.fireEvent("onmouseout")
			event.srcElement.style.backgroundColor=""
			event.srcElement.style.color="black"
			window.status=''
		}
	}
}

function jumptoie5()
{
	if(menuID=0)
	{
		URLstring="";
	}
	if (event.srcElement.className=="menuitems")
	{
		if(doNotRelocate==0)
		{
			if(event.srcElement.tagName == "IMG") {
				//event.srcElement.parentElement.fireEvent("onclick");
				return false;
			}

			var url = event.srcElement.getAttribute("url");

			if (event.srcElement.getAttribute("target")!=null)
				window.open(url+URLstring,event.srcElement.getAttribute("target"))
			else
				window.location=url+URLstring
		}
	}
	doNotRelocate=0;
}