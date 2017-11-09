// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks
//= require jquery 
//= require cocoon
//= require projects


// Tries to remove a row added with cocoon
// @rowelem row to remove from table
// @urlprefix The URL to send AJAX request to DELETE will be urlprefix/id/ (a
//   json answer is expected)
// @seldep Selector to select boxes that depend on the row to remove (if any 
//         exist this function will not remove the row)
function try_to_remove_row(rowelem, urlprefix, seldep) {
  // Avoid running twice in less than 2 seconds 
  // (use to happen with rails+turbolinks+jquery)
  t = Date.now()
  d = -1
  if (window.ajax_t) {
    d = (t - window.ajax_t) / 1000
  }
  window.ajax_t = t
  if (d == -1 || d > 2) {
    // find identification of element to remove
    bid = rowelem.find('input[id$=_id]')
    if (bid.length != 1) {
      return false;
    }
    ide = +$(bid[0]).val()
    if (seldep != null) {
      var num = 0
      $(seldep + ' option:selected').each(function() {
        if ($(this).val() == ide) {
          num+=1
        }
      })
      if (num>0) {
        alert('There are ' + num + 
                ' elements that depend on this; remove them before removing this.')
        return false
      }
      num = 0
    }
    $.ajax({
      url: urlprefix + ide,
      type: 'DELETE',
      dataType: 'json',
      beforeSend: function(xhr) {
	// Ensure CSRF-Token is sent
        xhr.setRequestHeader('X-CSRF-Token', 
          $('meta[name="csrf-token"]').attr('content'))
      },
      success: function(response) { 
        $(rowelem).remove()
      },
      error: function(response) {
        alert('Error: the service responded with: ' + 
	  response.status + '\n' + response.responseText)
      }
    })
  }
  return true
}
  

$(document).on('turbolinks:load ready', function() {
  $('#objectives').on('change', '[id$=_code]', 
      function (e, objective) {
        update_objectives()
      })
  $('#objectives').on('cocoon:after-remove', '', 
      function (e, objective) {
        update_objectives()
      })
  $('#results').on('cocoon:after-insert', '', 
      function(e, result) {
        update_objectives()
      })
  $('#objectives').on('cocoon:before-remove', '', 
      function (e, objective) {
	return try_to_remove_row(objective, '/objectives/', 
	  'select[id^=project_results_attributes][id$=_objective_id]')
      })

  
  $('#results').on('change', '[id$=_code]', 
      function (e, result) {
        update_results()
      })
  $('#results').on('cocoon:after-remove', '', 
      function (e, result) {
        update_results()
      })
  $('#indicators').on('cocoon:after-insert', '', 
      function(e, indicator) {
        update_results()
      })
  $('#results').on('cocoon:before-remove', '', 
      function (e, result) {
	return try_to_remove_row(result, '/results/', 
	  'select[id^=project_indicators_attributes][id$=_result_id]')
      })
  $('#results').on('change', '[id$=_id]', 
      function (e, result) {
        submit_form($('form'))
      })

  $('#indicators').on('change', '[id$=_code]', 
      function (e, result) {
	submit_form($('form'))
      })
  $('#indicators').on('cocoon:before-remove', '', 
      function (e, indicator) {
	return try_to_remove_row(indicator, '/indicators/', null)
      })
  $('#indicators').on('change', '[id$=_id]', 
      function (e, indicator) {
        submit_form($('form'))
      })


});
