<cfsilent>
<!---
  * ==================================================================================================== 
  *    @File: \billbacks\2020\grid_header_components.cfm
  *  @Author: Sharon Harris
  *    @Date: January 2020
  * 
  * @Remarks: GM Billbacks - ag-grid header components
  *
  * ==================================================================================================== 
--->
</cfsilent>
<style>
	.massEditIcon {
		color: #406be4;
		font-size: 14px;
		margin: 0 0 0 5px;
	}
</style>
<script>
	// DHX Popup window functions
		// For some reason, this only works if the window object is created in the parent window, not in this iframe
		// So my_dhx_windows is a global in the parent window (search_billbacks.cfm)
		// my_dhx_windows   = new dhtmlXWindows();     /* dhx window objects */
		my_dhx_window_id = null;                    /* last dhx window id */

		function dhx_window_close( window_id ) {
			/* if window_id is not passed use the last dhx window id */
			window_id = window_id || my_dhx_window_id;
					if ( my_dhx_windows.isWindow( window_id ) ) {
				my_dhx_windows.window( window_id ).close();
			}
		}

		function dhx_popupInCenter( url, title, width, height, window_id, modal, park ) {
			modal     = modal  || true;
			park      = ( modal 
							? false 
							: park || false );
			title     = title  || "";
			height    = height || 800;
			width     = width  || 1300;
			window_id = window_id || "_popup_" + random367();

			var popup = parent.my_dhx_windows.createWindow({ caption: title,
													id: window_id, 
													modal: modal, 
													park: park,
													height: height, 
													width: width
												});
			popup.attachURL( url );
			if ( !park ) {
				popup.button( "park" ).hide();
			}
			popup.centerOnScreen();

			/* save window id so we can close it by JS function */
			my_dhx_window_id = window_id;   
			return popup;
		}


	// Popup to allow Mass Edit of Column values
	function editPopup (name, nSel) {
		if (nSel === 0) {
			alert ("Please select row(s) to edit.");
			return;
		}
		dhx_popupInCenter( "edit_column_popup.cfm?name="+name+"&nSel="+nSel
									,"Mass Apply Edit"
									,380	// width
									,300	// height
								);
	}

	// --------------------------------------------
	// Define the Mass Edit Header Component - used to trigger an edit for the selected items in this column
	// This includes support for Sorting
	// 
	function MassEditHeaderComponent() {}

	MassEditHeaderComponent.prototype.init = function(params) {
		this.params = params;

		this.eGui = document.createElement('div');
		this.eGui.setAttribute('style','width:100%;');
        this.eGui.innerHTML = '' +
			'<span class="customHeaderLabel">' + this.params.displayName + '</span> ' +
			'<span id="editOn" class="massEditIcon" title="Display edit field to edit all selected"><i class="fa fa-pencil"></i></span>'+
            '<span class="customSortDownLabel inactive" style="float:right;"><i class="ag-icon ag-icon-desc""></i> </span>' +
            '<span class="customSortUpLabel inactive" style="float:right;"><i class="ag-icon ag-icon-asc""></i> </span>'+
            '<span class="customFilterLabel inactive" style="float:right;"><i class="ag-icon ag-icon-filter"></i> </span>'
		;

        this.eLabel = this.eGui.querySelector(".customHeaderLabel");
        this.eSortDownButton = this.eGui.querySelector(".customSortDownLabel");
        this.eSortUpButton = this.eGui.querySelector(".customSortUpLabel");
		this.eFilterInd = this.eGui.querySelector(".customFilterLabel");
		

		// Handle our edit button
		this.eButton = this.eGui.querySelector('#editOn');
		this.eButton.addEventListener('click', this.massEdit.bind(this));
		


		// Handle optional sorting
        if (this.params.enableSorting) {
			let parentDiv = this.eLabel.parentNode;
            parentDiv.addEventListener('click', this.changeSort.bind(this));

            this.onSortChangedListener = this.onSortChanged.bind(this);
            this.params.column.addEventListener('sortChanged', this.onSortChangedListener);
            this.onSortChanged();
		}
		// If filter is active, show icon
        var self = this;
        self.eFilterInd.hidden = !self.params.column.isFilterActive();
        this.params.column.addEventListener('filterChanged', function() {
            self.eFilterInd.hidden = !self.params.column.isFilterActive();
        });


	};


	MassEditHeaderComponent.prototype.massEdit = function(event) {
		event.stopPropagation();	// Don't also run other click handlers (like sort)
		let len = this.params.api.getSelectedNodes().length;
		editPopup (this.params.column.colDef.headerName, len);
	}
	
	MassEditHeaderComponent.prototype.getGui = function() {
		return this.eGui;
	};

    MassEditHeaderComponent.prototype.changeSort = function (event) {
        this.params.progressSort(event.shiftKey);
    }


    MassEditHeaderComponent.prototype.onSortChanged = function () {
        function deactivate(toDeactivateItems) {
            toDeactivateItems.forEach(function (toDeactivate) {
                toDeactivate.hidden = true;
            });
        }

        function activate(toActivate) {
            toActivate.hidden = false;
        }

        if (this.params.column.isSortAscending()) {
            deactivate([this.eSortDownButton]);
            activate(this.eSortUpButton)
        } else if (this.params.column.isSortDescending()) {
            deactivate([this.eSortUpButton]);
            activate(this.eSortDownButton)
        } else {
            deactivate([this.eSortUpButton, this.eSortDownButton]);
        }
    };

    MassEditHeaderComponent.prototype.onSortRequested = function (order, event) {
        this.params.setSort(order, event.shiftKey);
	};

	
	MassEditHeaderComponent.prototype.destroy = function() {
		if (this.onSortChangedListener) {
            this.params.column.removeEventListener('sortChanged', this.onSortChangedListener)
        }
	};


<!---

	// If we use a header component, ag-grid then requires that we take over any Sorting, they don't provide the default
	// use this as a template to implement sorting for a component
	function customHeaderComponent() {
    }

    customHeaderComponent.prototype.init = function (params) {
        this.params = params;
		this.eGui = document.createElement('div');
		this.eGui.setAttribute('style','width:100%;');
        this.eGui.innerHTML = '' +
			'<span class="customHeaderLabel">' + this.params.displayName + '</span> ' +
            '<span class="customSortDownLabel inactive" style="float:right"><i class="ag-icon ag-icon-desc""></i> </span>' +
            '<span class="customSortUpLabel inactive" style="float:right"><i class="ag-icon ag-icon-asc""></i> </span>'+
            '<span class="customFilterLabel inactive" style="float:right"><i class="ag-icon ag-icon-filter"></i> </span>'
        ;

        this.eLabel = this.eGui.querySelector(".customHeaderLabel");
        this.eSortDownButton = this.eGui.querySelector(".customSortDownLabel");
        this.eSortUpButton = this.eGui.querySelector(".customSortUpLabel");
		this.eFilterInd = this.eGui.querySelector(".customFilterLabel");
		

		// Handle optional sorting
        if (this.params.enableSorting) {
			let parentDiv = this.eLabel.parentNode;
            parentDiv.addEventListener('click', this.changeSort.bind(this));

            this.onSortChangedListener = this.onSortChanged.bind(this);
            this.params.column.addEventListener('sortChanged', this.onSortChangedListener);
            this.onSortChanged();
		}
		// If filter is active, show icon
        var self = this;
        self.eFilterInd.hidden = !self.params.column.isFilterActive();
        this.params.column.addEventListener('filterChanged', function() {
            self.eFilterInd.hidden = !self.params.column.isFilterActive();
        });


	};
	
    customHeaderComponent.prototype.getGui = function () {
        return this.eGui;
    };

    customHeaderComponent.prototype.changeSort = function (event) {
        this.params.progressSort(event.shiftKey);
    }


    customHeaderComponent.prototype.onSortChanged = function () {
        function deactivate(toDeactivateItems) {
            toDeactivateItems.forEach(function (toDeactivate) {
                toDeactivate.hidden = true;
            });
        }

        function activate(toActivate) {
            toActivate.hidden = false;
        }

        if (this.params.column.isSortAscending()) {
            deactivate([this.eSortDownButton]);
            activate(this.eSortUpButton)
        } else if (this.params.column.isSortDescending()) {
            deactivate([this.eSortUpButton]);
            activate(this.eSortDownButton)
        } else {
            deactivate([this.eSortUpButton, this.eSortDownButton]);
        }
    };

    customHeaderComponent.prototype.onSortRequested = function (order, event) {
        this.params.setSort(order, event.shiftKey);
    };

    customHeaderComponent.prototype.destroy = function () {
		if (this.onSortChangedListener) {
            this.params.column.removeEventListener('sortChanged', this.onSortChangedListener)
        }
	};
--->	
</script>