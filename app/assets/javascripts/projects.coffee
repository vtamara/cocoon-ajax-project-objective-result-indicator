# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#//= require jquery
#//= require cocoon


# Replaces options of a selection box with new ones
# @idsel identification of existing selection box
# @newops Array of hashes with new options, each hash has properties id and 
#   label
@replace_options_select = (ids, newops) ->
  s = $("#" + ids)
  if (s.length != 1)
    alert('update_select: ' + ids + ' not found')
    return
  sel = s.val()
  nh = ''
  newops.forEach( (v) ->
    id = v["id"]
    nh = nh + "<option value='" + id + "'"
    if id == sel 
      nh = nh + ' selected'
    tx = v["label"]
    nh = nh + ">" + tx + "</option>" 
  )
  s.html(nh)
  return


# Finds all selection boxes with references to objectives and updates them
@update_objectives =  ->
  newops = []
  lobj = $('#objectives .nested-fields[style!="display: none;"]')
  lobj.each((k, v) ->
    id = $(v).find('input[id$=_id]').val()
    code = $(v).find('input[id$=_code]').val()
    newops.push({id: id, label: code})
  )
  $('select[id^=project_results_attributes_][id$=_objective_id]').each((i,r) ->
    replace_options_select($(r).attr('id'), newops) 
  )
  return

# Finds all selection boxes with references to results and updates them
@update_results =  ->
  newops = []
  lobj = $('#results .nested-fields[style!="display: none;"]')
  lobj.each((k, v) ->
    id = $(v).find('input[id$=_id]').val()
    code = $(v).find('input[id$=_code]').val()
    newops.push({id: id, label: code})
  )
  $('select[id^=project_indicators_attributes_][id$=_result_id]').each((i,r) ->
    replace_options_select($(r).attr('id'), newops) 
  )
  return



@submit_form = (f) ->
  t = Date.now()
  d = -1
  if (window.submit_form_t)
    d = (t - window.submit_form_t)/1000
  window.submit_form_t = t
  # Avoid submitting twice in less than 2 seconds
  if (d == -1 || d > 2)
    a = f.attr('action')
    vd = f.serializeArray()
    vd.push({name: 'commit', value: 'Update'})
    vd.push({name: '_submit_form', value: 1})
    dat = $.param(vd)
    # Avoid submitting twice the same informtion
    if (!window.dant || window.dant != dat)
      window.dant = dat
      $.ajax({
        url: a, 
        data: dat,
        method: 'POST',
        dataType: 'json', 
        beforeSend: ((xhr) -> 
          # Ensure CSRF-Token is sent
          xhr.setRequestHeader('X-CSRF-Token', 
            $('meta[name="csrf-token"]').attr('content'))
          ),
        error: ((response) ->
          alert('Error: the service responded with: ' + 
            response.status + '\n' + response.responseText) 
          )
      })
 
  return

