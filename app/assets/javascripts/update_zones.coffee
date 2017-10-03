$("#zones_select").empty()
.append("<%= escape_javascript(render(:partial => @zones)) %>")
console.log("<%= render @zones.to_json %>")