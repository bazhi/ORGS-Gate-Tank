
var f2num = function(n, l) {
    if (typeof l === "undefined") l = 2;
    while (n.length < l) {
        n = "0" + n;
    }
    return n;
}

var HTTP_ENTRY      = "website";

var CDKeyApp = function (apphtml) {
    var self = this;

    self._apphtml  = apphtml;
}

var dataFormatter =  function (date){  
        var y = date.getFullYear();  
        var m = date.getMonth()+1;  
        var d = date.getDate();  
        return y+'-'+(m<10?('0'+m):m)+'-'+(d<10?('0'+d):d);  
    }

CDKeyApp.prototype.init = function() {
    var self = this;

    var apphtml = self._apphtml;

    // sign in
    self._rewards   = apphtml.find("#rewards");
    self._count = apphtml.find("#count");
    self._expiration = apphtml.find("#expiration");
    self._generateButton      = apphtml.find("#generateButton");
    self._filelist = document.getElementById("filelist");
    // init

    self._httpServerAddr = "http://" + document.location.host + "/" + HTTP_ENTRY + "/";

     // log

    self._alertDialogHtml   = apphtml.find("#alertDialog");
    self._logHtml           = apphtml.find("#log");

    apphtml.find("#clearLogsButton").click(function() {
        self._clearLogs();
    });

    apphtml.find("#insertMarkButton").click(function() {
        self._appendLogMark();
    });

    self._updateUI();

    self._generateButton.click(function() {
        var expiration = self._expiration.val();
        var count = self._count.val();
        var rewards = self._rewards.val();
        self._sendHttpRequest("key.Generate", {"expiration":Date.parse(expiration)/1000, "count":count, "rewards":rewards}, function(res) {
            if(res["result"]){
                 var filename = res["filename"];
                self._appendLog(filename);
                self._filelist.contentWindow.location.reload(true);
            }
            
        }, function(){

        })
    });
}

CDKeyApp.prototype._updateUI = function() {
    var self = this;

    var state = self._state;

    self._rewards.prop("disabled", false);
    self._count.prop("disabled", false);
    self._expiration.prop("disabled", false);
    self._generateButton.prop("disabled", false);
    var now = new Date();
    self._count.val(100);
    self._expiration.val(dataFormatter(now));
}

CDKeyApp.prototype._sendHttpRequest = function(action, values, callback, fail) {
    var self = this;

    var url = self._httpServerAddr + "?action=" + action;
    self._appendLog("HTTP: " + url);

    $.post(url, values, function(res) {
        if (res.err) {
            var err = "ERR: " + res.err;
            self._showError(err);
            self._appendLog(err);
        }
        if (callback) {
            callback(res);
        } else {
            if (res.ok) {
                self._appendLog("OK");
            } else {
                self._appendLog("ERR, " + res.err);
            }
        }
    }, "json")
    .fail(function() {
        self._appendLog("HTTP: " + url + " FAILED");
        if (fail) {
            fail();
        }
    });
}


CDKeyApp.prototype._showError = function(message) {
    var self = this;
    self._alertDialogHtml.find("#alertContents").text(message);
    var modal = UIkit.modal(self._alertDialogHtml);
    modal.show();
}

CDKeyApp.prototype._appendLogMark = function() {
    var self = this;

    self._logHtml.prepend("<strong>--------<strong>\n");
    self._logHtml.scrollTop(self._logHtml.prop("scrollHeight"));
}

CDKeyApp.prototype._appendLog = function(message) {
    var self = this;

    var now = new Date();
    var time = f2num(now.getHours().toString())
                 + ":" + f2num(now.getMinutes().toString())
                 + ":" + f2num(now.getSeconds().toString());
    message = $("<div/>").text(message).html();
    message = message.replace("\n", "<br />\n");
    self._logHtml.prepend("[<strong>" + time + "</strong>] " + message + "\n");
    self._logHtml.scrollTop(self._logHtml.prop("scrollHeight"));
}

CDKeyApp.prototype._clearLogs = function() {
    this._logHtml.empty();
}
