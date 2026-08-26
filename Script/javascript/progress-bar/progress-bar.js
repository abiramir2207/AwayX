// Call this after the window is loaded, to instantiate the progress bar
// Params object:
// 	id: required - string, this is the html ID of the div for the progress bar.  Can be hidden until needed.
//	barStyle: optional - string, class name to change the style of the progress bar (ex change background-color)
// 	bIndicate: optional - boolean, if true, will display the % text inside the progress bar
// 	bDemo: optional - boolean, if true, we skip calling the cfc function foregroundColor, helpful for simple html demo
// 
// returns object including a set function.  Call set funtion with percent 0 - 100 to set the progress bar
// 
// see progress-bar.html for example usage
// 

function progressBar (params) {
	params = params || {};
	params.id = params.id || "progressBar";				// (pass this param!) default id to populate
	params.barStyle = params.barStyle || undefined;		// use default bar style
	params.bIndicate = (params.bIndicate === undefined) ? false : params.bIndicate;	// default to no text
	params.bDemo = (params.bDemo === undefined) ? false : params.bDemo;				// default to not demo. Use bDemo to call from html vs FORGE

	// Create the container
	container = document.getElementById (params.id);
	container.classList.add ("container");

	// Create the Colored Progress Bar
	let progress = document.createElement ("div");
	progress.classList.add ("progress");
	if (params.barStyle != undefined) {
		progress.classList.add (params.barStyle);
	}
	container.appendChild (progress);

	// Optional Progress indicator text
	let indicator = null;
	if (params.bIndicate) {
		indicator = document.createElement("div");
		indicator.classList.add("indicator");
		indicator.innerHTML = "0%";
		container.appendChild(indicator);
	}
  
	// Return the fully formed progress bar
	// The "set" function can be used to set the progress value
	return {
		container: container,
		progress: progress,
		indicator: indicator,
		bDemo: params.bDemo,
		set : function (percent, display='0%') {
			if (percent > 100) percent = 100;
			//if (percent < 0) percent = 0;
			this.progress.style.width = percent + "%";
			
    		if (this.indicator) { 
				// Set the color of the indicator text based on the color of the background
				var textBackground = this.container;
				if (percent > 47) {
					// since text is centered, if progress bar is about 1/2 way, use that as the background color
					textBackground = this.progress;
				}
				// The foregroundColor function is available in FORGE - use bDemo flag to skip it in the html demo
				if ( !this.bDemo) {
					let bgc =  getComputedStyle(textBackground).backgroundColor;
					bgc = RGBToHex (bgc);
					this.indicator.style.color = foregroundColor ( bgc ); 
				}

				this.indicator.innerHTML = display; 
			}
    	}
	}
}

// Convert rgb string (ex: "rgb(255,25,10)" to hex string "#FF190A"
function RGBToHex(rgb) {
	// Choose correct separator
	let sep = rgb.indexOf(",") > -1 ? "," : " ";
	// Turn "rgb(r,g,b)" into [r,g,b]
	rgb = rgb.substr(4).split(")")[0].split(sep);
  
	let r = (+rgb[0]).toString(16),
		g = (+rgb[1]).toString(16),
		b = (+rgb[2]).toString(16);
  
	if (r.length == 1)
	  r = "0" + r;
	if (g.length == 1)
	  g = "0" + g;
	if (b.length == 1)
	  b = "0" + b;
  
	return "#" + r + g + b;
  }