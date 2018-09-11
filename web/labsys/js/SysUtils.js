////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//讀取系統參數
function initSysData() {
    $.ajax({
        url: "/labweb/labsys/service/SysData.jsp",
        type: "POST",
        dataType: "json",
        data: {},
        async: false,
        success: function(response) {
            if (response.msgid === 0) {
                //系統參數
                $.each(response.data.constants, function(key, value){
                    sessionStorage.setItem(key, value);
                });
                //使用者
                sessionStorage.setItem("user", JSON.stringify(response.data.user));
                //系統選單
                initMenu(response.data.menu);

            } else {
                alert(response.msgtxt);
                if (response.msgid >= 90) { //逾時或權限不足，登出
                    window.location.href = "/labweb/Logout.jsp";
                }
            }
        },
        error: function(jqXHR, textStatus, errorThrown) {
            alert("HTTP status code: " + jqXHR.status + "\n" + "textStatus: " + textStatus + "\n" + "errorThrown: " + errorThrown);
            alert(jqXHR.responseText);
        }
    });
}
//建立系統選單
function initMenu(menuary){
    $.each(menuary, function(i, item){
        if ($.type(item[2]) === "array") { //有子選單
            var submenuid = "submenu_" + i; //子選單 id
            var submenu = $('<ul id="' + submenuid + '" class="ddsubmenustyle"></ul>').appendTo("body");

            $.each(item[2], function(i, itemsub){ //增加所有子選單
                var menu2 = '<li><a href="' + itemsub[1] + '" >' + itemsub[0] + '</a></li>';
                submenu.append(menu2);
            });

            var menu = '<li><a href="javascript:" rel="' + submenuid + '" >' + item[0] + '</a></li>';
            $('#ddtopmenubar ul').append(menu);

        } else { //選單
            var menu = '<li><a href="' + item[1] + '" >' + item[0] + '</a></li>';
            $('#ddtopmenubar ul').append(menu);
        }
    });

    ddlevelsmenu.init("ddtopmenubar", "topbar")

}

////////////////////////////////////////////////////////////////////////////////
//form 資料轉為 json
$.fn.formDataToJSON = function () {
    var o = {};
    var a = this.serializeArray();
    $.each(a, function () {
        if (o[this.name] !== undefined) {
            if (!o[this.name].push) {
                o[this.name] = [o[this.name]];
            }
            o[this.name].push(this.value || '');
        } else {
            o[this.name] = this.value || '';
        }
    });
    var $radio = $('input[type=radio],input[type=checkbox]',this);
    $.each($radio,function(){
        if(!o.hasOwnProperty(this.name)){
            o[this.name] = '';
        }
    });
    return o;
};

//json 轉為 form 資料
function JSONToFormData(frm, json) {
    if (frm instanceof jQuery) { //jQuery 轉為 DOM
        frm = frm.get(0);
    }
    /*
    var keys = Object.keys(json);
    for(var i=0;i<keys.length;i++){
        var key = keys[i];
        var el = frm.elements[ key ];
        if (el) {
            el.value = json[key];
        }
    }
    */
    Object.keys(json).forEach(function(key) {
        var el = frm.elements[key];
        if (el) {
            if (el.type == "text" || el.type == "textarea" || el.type == "select-one" || el.type == "password") {
                el.value = json[key];
            } else if (el.type == "checkbox") {
                el.checked = json[key] === "on";
            }
        }
    })
}

