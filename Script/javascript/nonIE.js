(function() {
    window.spawn = window.spawn || function(gen) {
        function continuer(verb, arg) {
            var result;
            try {
                result = generator[verb](arg);
            } catch (err) {
                return Promise.reject(err);
            }
            if (result.done) {
                return result.value;
            } else {
                return Promise.resolve(result.value).then(onFulfilled, onRejected);
            }
        }
        var generator = gen();
        var onFulfilled = continuer.bind(continuer, 'next');
        var onRejected = continuer.bind(continuer, 'throw');
        return onFulfilled();
    };
    window.showModalDialog = window.showModalDialog || function(url, arg, opt) {

        url = url || ''; //URL of a dialog
        arg = arg || null; //arguments to a dialog
        opt = opt || 'dialogWidth:300px;dialogHeight:200px'; //options: dialogTop;dialogLeft;dialogWidth;dialogHeight or CSS styles
        var caller = showModalDialog.caller.toString();
        var dialog = document.body.appendChild(document.createElement('dialog'));
        dialog.setAttribute('style', opt.replace(/dialog/gi, ''));

		/* This modal window is not actually a window. If the modal window is bigger than the parent window, then the entire modal window
		cannot be viewed, as the modal window inside the parent window. If the modal window is bigger than the parent window,below code will resize 
		the parent window to be bigger than the modal window.
		Currently this code is not needed, but may be needed in the future, when we use modal window in other places, where the parent window
		is smaller than this modal window.
		*/
		/* resize parent window code (start) */
		var parent_win_height = parent.document.body.clientHeight; // 800; // $(window.parent.document).height();
		var win_height = $(dialog).height();
		var parent_win_width = parent.document.body.clientWidth; // 1000; //$(window.parent.document).width();
		var win_width = $(dialog).width();
		var change_height = 0;
		var change_width = 0;

		if(parent_win_height < win_height)
		{
			parent_win_height = win_height + 150;
			change_height = 1;
		}

		if(parent_win_width < win_width)
		{
			parent_win_width = win_width + 150;
			change_width = 1;
		}
		
		if(change_height == 1 || change_width == 1){
			window.parent.resizeTo(parent_win_width,parent_win_height);
		}
		/* resize parent window code (end) */

        dialog.innerHTML = '<a href="#" id="dialog-close" style="position: absolute; top: 0; right: 4px; font-size: 20px; color: #000; text-decoration: none; outline: none;">&times;</a><iframe id="dialog-body" src="' + url + '" style="border: 0; width: 100%; height: 100%;"></iframe>';
        document.getElementById('dialog-body').contentWindow.dialogArguments = arg;
        document.getElementById('dialog-close').addEventListener('click', function(e) {
            e.preventDefault();
            dialog.close();
        });
        dialog.showModal();
        //if using yield
        if(caller.indexOf('yield') >= 0) {
            return new Promise(function(resolve, reject) {
                dialog.addEventListener('close', function() {
                    var returnValue = document.getElementById('dialog-body').contentWindow.returnValue;
                    document.body.removeChild(dialog);
                    resolve(returnValue);
                });
            });
        }
        //if using eval
        var isNext = false;
        var nextStmts = caller.split('\n').filter(function(stmt) {
            if(isNext || stmt.indexOf('showModalDialog(') >= 0)
                return isNext = true;
            return false;
        });
        dialog.addEventListener('close', function() {
            var returnValue = document.getElementById('dialog-body').contentWindow.returnValue;
            document.body.removeChild(dialog);
            nextStmts[0] = nextStmts[0].replace(/(window\.)?showModalDialog\(.*\)/g, JSON.stringify(returnValue));
            eval('{\n' + nextStmts.join('\n'));
        });
        throw 'Execution stopped until showModalDialog is closed';
    };
})();