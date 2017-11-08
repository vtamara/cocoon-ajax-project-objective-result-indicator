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


# Finds all selection boxes with references to objectives and updates
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


