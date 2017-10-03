$(document).on('ready turbolinks:reload', function () {

    // begin first table
    $('#customers_table').dataTable({
        "sDom": "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col-sm-6'p>>",
        "sPaginationType": "bootstrap",
        "oLanguage": {
            "sLengthMenu": "_MENU_ records per page",
            "oPaginate": {
                "sPrevious": "Prev",
                "sNext": "Next"
            }
        },
        "aoColumnDefs": [{
            'bSortable': false,
            'aTargets': [0]
        }]
    });

    jQuery('#customers_table_wrapper').find('.dataTables_filter input').addClass("form-control"); // modify table search input
    jQuery('#customers_table_wrapper').find('.dataTables_length select').addClass("form-control"); // modify table per page dropdown

    // begin second table
    $('#summary_table').dataTable({
        "sDom": "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col-sm-6'p>>",
        "sPaginationType": "bootstrap",
        "oLanguage": {
            "sLengthMenu": "_MENU_ per page",
            "oPaginate": {
                "sPrevious": "Prev",
                "sNext": "Next"
            }
        },
        "aoColumnDefs": [{
            'bSortable': false,
            'aTargets': [0]
        }]
    });
    jQuery('#summary_table_wrapper').find('.dataTables_filter input').addClass("form-control"); // modify table search input
    jQuery('#summary_table_wrapper').find('.dataTables_length select').addClass("form-control"); // modify table per page dropdown


});