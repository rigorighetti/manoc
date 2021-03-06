function showDialogForm(url, title, on_close) {
    var modalBox = bootbox.dialog({
        message: '<div id="modalBoxMessage">Loading...</div>',
        title: title,
    });
    var submit_func = function(form) {
	    $.ajax({
	        data: form.serialize(),
	        type: form.attr('method'),
	        url:  url,
	        success: function(data) {
                if (data.html) {
                    $('#modalBoxMessage').html(data.html);
                    form = $('#modalBoxMessage form');
                    form.submit(function(e) { e.preventDefault(e); submit_func(form); });
                    return;
                }
                modalBox.modal('hide');
                on_close(data);
            }
	    });
	};
    $.ajax({
        type: 'GET',
        url: url,
        success: function(data) {
            $('#modalBoxMessage').html(data.html);
            form = $('#modalBoxMessage form');
            form.submit(function(e) { e.preventDefault(e); submit_func(form); });
        }
    });
    return true;
}

/* Manoc Form plugin */
(function( $ ) {
    $.fn.manocAjaxForm = function() {
        var submit_func = function(e) {
            e.preventDefault(e);
            var form = $( this );
	        $.ajax({
	            data: form.serialize(),
	            type: form.attr('method'),
	            url:  window.location,
	            success: function(data) {
                    if (data.html) {
                        form.html(data.html);
                        return;
                    }
                    form.replaceWith('<p>' + data.message + '</p>');
                    if (data.redirect) {
                        window.location.replace(data.redirect);
                    }
                }
	        });
	    };
        this.submit(submit_func);
        return this;
    };
}( jQuery ));

/* Remote Tab */
(function( $ ) {
    $('a[data-toggle="tab"]').on('show.bs.tab', function (e) {
        var currTabTarget = $(e.target).attr('href');
        var remoteUrl = $(this).attr('data-tab-remote');
        var loadedOnce = $(this).data('loaded');
        if (remoteUrl && remoteUrl !== '' && !loadedOnce) {
            $(currTabTarget).load(remoteUrl)
            $(this).data('loaded',true);
        }
    })
}( jQuery ));
