////////////////////////////////////////////////////////////////////////////////
//把 "Enter" 轉為 "跳到下一個輸入欄位"
function handleEnter (field, event) {
  var keyCode = document.all ? event.keyCode : event.which;
    if (keyCode == 13) {
        var i;
        for (i = 0; i < field.form.elements.length; i++)
            if (field == field.form.elements[i])
            break;

        for (j = 0; j < field.form.elements.length; j++) {
            i++;
            i = i % field.form.elements.length;
            var tmp = field.form.elements[i];
            if ((tmp.type == "text" || tmp.type == "textarea" || tmp.type == "select-one"
                    || tmp.type == "select-multiple" || tmp.type == "checkbox" || tmp.type == "password")
                    && (!tmp.readOnly)) {
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
function openHelpWindow(page, winid) {
//    var feature = "dialogWidth:800px,dialogHeight:500px,status:no,unadorned=yes";
//    helpWidnowHandler = window.showModalDialog(page, null, feature);
    var x = 800;
    var y = 500;
    var left = (screen.width - x) / 2;
    var top = (screen.height - y) / 2 - 20;
    left = (left >= 0) ? left : 0;
    top = (top >= 0) ? top : 0;
    var feature = "left=" + left + ",top=" + top + ",width=" + x + ",height=" + y
                + ",toolbar=0,status=0,scrollbars";
    window.open(page, winid, feature).focus();
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

                   