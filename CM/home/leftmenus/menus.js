
	/* MENUS.JS */
	
	var eOpenMenu = null;

	function OpenMenu(eSrc,eMenu)
	{
		//eMenu.style.left = eSrc.offsetLeft + divMenuBar.offsetLeft;			//used if the menus are horizontal
		//eMenu.style.top = divMenuBar.offsetHeight + divMenuBar.offsetTop;		//used if the menus are horizontal
		eMenu.style.top = eSrc.offsetTop + divMenuBar.offsetTop - 1;
		eMenu.style.left = divMenuBar.offsetWidth + divMenuBar.offsetLeft;
		eMenu.style.visibility = "visible";		
		eOpenMenu = eMenu;
		if(window.mainwindow.showHideSelectBoxes)
		{
			window.mainwindow.showHideSelectBoxes(eOpenMenu);
		}
	}

	function CloseMenu(eMenu)
	{
		eMenu.style.visibility = "hidden";
		if(window.mainwindow.showHideSelectBoxes)
		{
			window.mainwindow.showHideSelectBoxes(eOpenMenu);
		}
		eOpenMenu = null;
	}

	function document.onmouseover()
	{
		var eSrc = window.event.srcElement;
		if ("clsMenuBarItem" == eSrc.className)
		{
			eSrc.style.color = "White";											//the color of the text in the mouse-over state
			var eMenu = document.all[eSrc.id.replace("tdMenuBarItem","divMenu")];
			if (eOpenMenu && eOpenMenu != eMenu) 
			{
				CloseMenu(eOpenMenu);
			}
			if (eMenu) 
			{
				OpenMenu(eSrc,eMenu);
			}
		}
		else if (eOpenMenu && !eOpenMenu.contains(eSrc) && !divMenuBar.contains(eSrc)) 
		{
			CloseMenu(eOpenMenu);
		}
	}
	
	function document.onmouseout()
	{
		var eSrc = window.event.srcElement;
		if ("clsMenuBarItem" == eSrc.className)
		{
			eSrc.style.color = ""; 
		}
	}	
