var GameApp = function (apphtml) {
    var self = this;
    self._apphtml  = apphtml;
}      

GameApp.prototype.init = function() {
    var self = this;
    var apphtml = self._apphtml;

    var url = "http://" + document.location.hostname + ":8089/Game/?action=manager.ulist";
    
    $.post(url, "", function(res){
    	if(res.err){
    		console.log(res.err);
    		return;
    	}
    	self.updateTable(res)
    }, "json").fail(function(){

    })
}

function fmtDate(obj){
    var date =  new Date(obj*1000);
    return date.toLocaleDateString() + " " +date.toLocaleTimeString();
}

GameApp.prototype.updateTable = function(list){
	var apphtml = this._apphtml;
	var tab = apphtml.find("#onlineTable");
	if(tab == null){
		return;
	}

	for (var i = 0; i < list.length; i+=2) {
		var rowItem = '<tr>'
        rowItem += '<td>'+list[i]+'</td>' ;
		rowItem +='<td>'+fmtDate(list[i+1])+'</td>';
        rowItem += '<tr>'
		tab.append(rowItem);
	}
}