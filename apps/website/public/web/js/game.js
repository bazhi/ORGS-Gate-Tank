
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
    return date.Format("yyyy-MM-dd hh:mm:ss");
}

GameApp.prototype.updateTable = function(list){
	var apphtml = this._apphtml;
	var tab = apphtml.find("#onlineTable");
	if(tab == null){
		return;
	}

	for (var i = 0; i < list.length; i++) {
        var info = list[i]
		var rowItem = '<tr>'
        rowItem += '<td>'+info.pid+'</td>' ;
        rowItem += '<td>'+info.nickname+'</td>' ;
		rowItem +='<td>'+fmtDate(info.loginTime)+'</td>';
        rowItem +='<td>'+fmtDate(info.createTime)+'</td>';
        rowItem += '<td>'+info.diamond+'</td>' ;
        rowItem += '<td>'+info.techPoint+'</td>' ;
        rowItem += '</tr>'
		tab.append(rowItem);
	}
}