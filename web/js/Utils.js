////////////////////////////////////////////////////////////////////////////////
//公用變數

////////////////////////////////////////////////////////////////////////////////
//設定唯讀欄位
function setReadonlyField(editor, readonly){
    if (readonly) {
        editor.getEl().dom.className = 'x-form-field-readonly';
        editor.getEl().dom.setAttribute('readOnly', true);
        if (editor.isXType('combo')) editor.on('expand', disableDowndownList);
        if (editor.isXType('datefield')) editor.trigger.setDisplayed(false);
        //if (editor.isXType('combo') || editor.isXType('datefield')) editor.trigger.setDisplayed(false);
        if (editor.isXType('radiogroup')) {
            editor.cls = 'x-form-field-readonly';
            editor.setDisabled(true);
            for (i=0; i < editor.items.length; i++) editor.items.get(i).readOnly = true;
        }
    } else {
        if (editor.isXType('checkbox')) return;
        editor.removeClass('x-form-field-readonly');
        editor.getEl().dom.className = 'x-form-text';
        if (!editor.isXType('combo')) editor.getEl().dom.removeAttribute('readOnly');
        if (editor.isXType('combo')) editor.un('expand', disableDowndownList);
        if (editor.isXType('datefield')) editor.trigger.setDisplayed(true);
        //if (editor.isXType('combo') || editor.isXType('datefield')) editor.trigger.setDisplayed(true);
        if (editor.isXType('radiogroup')) {
            editor.cls = 'x-form-text';
            editor.setDisabled(false);
            for (i=0; i < editor.items.length; i++) editor.items.get(i).readOnly = false;
        }
    }
}
//取消下拉
function disableDowndownList(){this.collapse();}

////////////////////////////////////////////////////////////////////////////////
//把 "Enter" 轉為 "跳到下一個輸入欄位"
function handleEnter(field, event) {
    var keyCode = document.all ? event.keyCode : event.which;
    if (keyCode == 13) {
        var i;
        if (field.type == "submit" || field.type == "button") {
            return true;
        }
        for (i = 0; i < field.form.elements.length; i++)
            if (field == field.form.elements[i])
            break;

        for (j = 0; j < field.form.elements.length; j++) {
            i++;
            i = i % field.form.elements.length;
            var tmp = field.form.elements[i];
            if ((tmp.type == "text" || tmp.type == "textarea" || tmp.type == "select-one"
                    || tmp.type == "select-multiple" || tmp.type == "checkbox"
                    || tmp.type == "password" || tmp.type == "submit" || tmp.type == "button")
                    && (!tmp.readOnly) && (!tmp.disabled)) {
                //if (tmp.type != "submit" && tmp.type != "button") tmp.select();
                tmp.focus();
                break;
            }
        }
        return false;
    } else
        return true;
}
//取消 "回上一頁" 按鍵
function cancelBack(){
    if ((window.event.keyCode == 8
            && (window.event.srcElement.form == null || window.event.srcElement.isTextEdit == false))
            || window.event.keyCode == 37 && window.event.altKey
            || window.event.keyCode == 39 && window.event.altKey )
        {
            window.event.cancelBubble = true;
            window.event.returnValue = false;
        }
}
//開啟輔助視窗
function openHelpWindow(page, winid, w, h) {
    if (!w) w = 800;
    if (!h) h = 500;
    var left = (screen.width - w) / 2;
    var top = (screen.height - h) / 2 - 20;
    left = (left >= 0) ? left : 0;
    top = (top >= 0) ? top : 0;
    var feature = "left=" + left + ",top=" + top + ",width=" + w + ",height=" + h
                + ",resizable=0,menubar=0,toolbar=0,status=0,scrollbars=1";
    var childWin = window.open(page, winid, feature);
    if (childWin.opener == null) childWin.opener = self;
    childWin.focus();
    return childWin;
}
//開啟 Modal 視窗
function openHelpModal(page, winid) {
    var feature = "dialogWidth:800px;dialogHeight:500px;status:no;unadorned=yes";
    var returnValue = window.showModalDialog(page, '', feature);
    return returnValue;
}
//取得代碼名稱 - 從陣列參數
function getCodeTitle(id, codes) {
    if ((id == null) || (id.length == 0)) return "";
    var retval = "";
    for (i = 0; i < codes.length; i++) {
        if (id == codes[i].id) {
            retval = codes[i].data;
            break;
        }
    }
    return retval;
}
//從名稱取得代碼
function getCodeFormTitle(title, codes) {
    if ((title == null) || (title.length == 0)) return "";
    var retval = "";
    for (i = 0; i < codes.length; i++) {
        if (title == codes[i].data) {
            retval = codes[i].id;
            break;
        }
    }
    return retval;
}
//檢查日期 yyyymmdd
function isValidDate(str) {
    //var validformat=/^\d{2}\/\d{2}\/\d{4}$/ //Basic check for format validity
    var validformat=/\d{8}/;
    var retval=false;
    if (validformat.test(str)) {
        var yearfield=str.substring(0, 4);
        var monthfield=str.substring(4, 6);
        var dayfield=str.substring(6, 8);
        var dayobj = new Date(yearfield, monthfield-1, dayfield);
        if ((dayobj.getFullYear()==yearfield)&&(dayobj.getMonth()+1==monthfield)&&(dayobj.getDate()==dayfield))
            retval=true;
    }
    return retval;
}
//加減日期(yyyymmdd)
function dateAdd(str, yy, mm, dd) {
    var retval="";
    if (isValidDate(str)) {
        var yearfield=str.substring(0, 4);
        var monthfield=str.substring(4, 6);
        var dayfield=str.substring(6, 8);
        var dayobj = new Date(yearfield, monthfield-1, dayfield);
        dayobj.setFullYear( dayobj.getFullYear() + yy );
        dayobj.setMonth( dayobj.getMonth() + mm );
        dayobj.setDate( dayobj.getDate() + dd );
        yearfield = dayobj.getFullYear();
        monthfield = (dayobj.getMonth() + 1);
        dayfield = (dayobj.getDate());
        if (monthfield < 10) monthfield = "0" + monthfield;
        if (dayfield < 10) dayfield = "0" + dayfield;
        retval = "" + yearfield + monthfield + dayfield;
    }
    return retval;
}
function dateAddTwoYear(str) {
    var retval="";
    if (isValidDate(str)) {
        var yearfield=str.substring(0, 4);
        var monthfield=str.substring(4, 6);
        var dayfield=str.substring(6, 8);
        var dayobj = new Date(yearfield, monthfield-1, dayfield);
        dayobj.setDate( dayobj.getDate() - 1 );
        dayobj.setFullYear( dayobj.getFullYear() + 2 );
        yearfield = dayobj.getFullYear();
        monthfield = (dayobj.getMonth() + 1);
        dayfield = (dayobj.getDate());
        if (monthfield < 10) monthfield = "0" + monthfield;
        if (dayfield < 10) dayfield = "0" + dayfield;
        retval = "" + yearfield + monthfield + dayfield;
    }
    return retval;
}

