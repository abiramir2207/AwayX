$.fn.fastSerialize = function() {
    var a = [];
    var f = ['INPUT', 'TEXTAREA', 'SELECT', 'BUTTON'];

    $(f.join(','), this).each(function() {
        var n = this.name || this.id;
        var t = this.type;

        if (!n || this.disabled || t == 'reset' ||
           (t == 'checkbox' || t == 'radio') && !this.checked ||
           (t == 'submit' || t == 'image' || t == 'button') &&
this.form.clicked != this ||
           this.tagName == 'SELECT' && this.selectedIndex == -1)
            return;

        if (t == 'image' && this.form.clicked_x)
            return a.push(
                {name: n+'_x', value: this.form.clicked_x},
                {name: n+'_y', value: this.form.clicked_y}
            );

        if (t == 'select-multiple') {
            $('option', this).each( function() {
                if (this.selected)
                    a.push({name: n, value: this.value ||
$(this).text()});
            });
            return;
        }

        a.push({name: n, value: this.value});
    });

    return a;
};

