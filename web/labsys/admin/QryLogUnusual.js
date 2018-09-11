//////////////////////////////////////////////////////////////
//公用變數
var itemsOnPage = 20; //每頁筆數
var queryData = ""; //查詢條件
var showLoading = true; //是否顯示查詢等待

//起始程式
$(document).ready(function() {
    //系統起始參數與設定
    initSysData();

    //起始頁數功能
    $("#paginator").pagination({
        items: 1,
        itemsOnPage: itemsOnPage,
        cssStyle: "compact-theme",
        displayedPages: 7,
        prevText: "&laquo;",
        nextText: "&raquo;",
        useAnchors: false,

        onPageClick: function(page) {
            //JSONToFormData( document.getElementById("formQuery"), JSON.parse(queryData) );
            JSONToFormData( $("#formQuery"), JSON.parse(queryData) );
            loadData(page);
        }
    });
    //產生顯示筆數
    $("#paginator").after("<div/ id='pagination_info' style='margin-left: 10px; font-weight: bold; display: inline-table;'>");

    //初始輸入資料
    initData();
    showItemsInfo(0);

    //按鈕
	$("#bAdd").button({icons: { primary: "ui-icon-plus"}, text: false }).click(function (e) {
        actAdd();
    });
	$("#bPost").button().click(function (e) {
        $(this).blur();
        executeQuery();
    });
	$("#bReset").button().click(function (e) {
        $(this).blur();
        resetQuery();
    });
	$("#bExport").button().click(function (e) {
        $(this).blur();
        exportQuery();
    });

    //顯示錯誤訊息
    if (sysErrMsg !== "") alert(sysErrMsg);

});

////////////////////////////////////////////////////////////////////////////////
//初始資料
function initData() {
    var frm = document.getElementById("formQuery");
    frm.branch.value = "";
    frm.sdate.value = $.datepicker.formatDate("yymmdd", new Date());
    frm.edate.value = $.datepicker.formatDate("yymmdd", new Date());
    frm.stime.value = "22:00:00";
    frm.etime.value = "06:00:00";

    frm.sdate.value = "20170101";
    frm.etime.value = "21:00:00";

    $("#bExport").attr("disabled", true); //按鍵唯讀
    $("#paginator").pagination("disable"); //頁數功能唯讀
}

////////////////////////////////////////////////////////////////////////////////
//執行按鈕
//查詢
function executeQuery() {
    $("#paginator").pagination("enable");
    $("#paginator").pagination("drawPage", 1);
    getQueryData();
    loadData(1);
}
//重新輸入
function resetQuery() {
    initData();
    clearTable();
    $("#paginator").pagination("disable");
}
//名冊下載
function exportQuery() {
    //產生 post from
    var form = document.createElement("form");
    form.target = "_blank";
    form.setAttribute("method", "post");
    form.setAttribute("action", "/labweb/common/LogDataExcel_2.jsp");
    form.style.display = "none";

    //產生 post 欄位
    var hiddenField = document.createElement("input");
    hiddenField.type = "hidden";
    hiddenField.name = "queryData";
    hiddenField.value = queryData;
    form.appendChild(hiddenField);
    document.body.appendChild(form);

    //提交
    form.submit();

    //移除 form
    document.body.removeChild(form);
}

////////////////////////////////////////////////////////////////////////////////
//資料處理
//清除表格
function clearTable() {
    $("#paginator").pagination("updateItems", 0); //筆數 == 0
    $("#bExport").attr("disabled", true); //按鍵唯讀
    showItemsInfo(0);
    //移除表格，只留頁數、標題
    var tableData = document.getElementById("tableData");
    var rowCount = tableData.rows.length;
    for(var i=rowCount-1; i>=2; i--) {
        tableData.deleteRow(i);
    }
}

//讀取查詢條件 -> json
function getQueryData() {
    queryData = JSON.stringify( $("#formQuery").formDataToJSON() );
//alert(queryData);
}

//載入資料 ajax
function loadData(page) {
    $.ajax({
        url: "QryLogUnusualAct.jsp",
        type: "POST",
        dataType: "json",
        crossDomain: false,
        headers: {'X-Requested-With': 'XMLHttpRequest'},
        data: {method: "GET", action: "list", itemsOnPage: itemsOnPage, currentPage: page, data: queryData},
        success: function(response) {
//            alert(JSON.stringify(response));
            if (response.msgid === 0) {
                fillData(response.data);
            } else {
                alert(response.msgtxt);
                if (response.msgid >= 90) { //逾時或權限不足，登出
                    window.location.href = sessionStorage.logoutFile;
                    //$(location).attr("href", sessionStorage.logoutFile);
                }
            }
        },
        beforeSend: function() { //顯示查詢等待
            if (showLoading) {
                $('body').append('<div id="requestOverlay" class="request-overlay"></div>'); /*Create overlay on demand*/
                $("#requestOverlay").show();/*Show overlay*/
            }
        },
        complete: function () { //取消 - 顯示查詢等待
            if (showLoading) {
                $("#requestOverlay").remove();/*Remove overlay*/
            }
        },
        error: function(jqXHR, textStatus, errorThrown) {
            alert("HTTP status code: " + jqXHR.status + "\n" + "textStatus: " + textStatus + "\n" + "errorThrown: " + errorThrown);
            alert(jqXHR.responseText);
        }
    });
}

//編輯按鈕
function dispActButtons(rowid){
    var edit = "<span class='list-edit' style='width: 20px; height: 16px; float: center;' title='編輯資料' onclick=\"actEdit('" + rowid + "');\"></span>";
    var del  = "<span class='list-del'  style='width: 20px; height: 16px; float: center;' title='刪除資料' onclick=\"actDel('" + rowid + "');\"></span>";
/*
    var edit = '<button class="ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only" style="width: 20px; height: 18px;" role="button" aria-disabled="false" title="編輯資料"'
            + ' onclick="actEdit(\'' + rowid + '\');">'
            + '<span class="ui-button-icon-primary ui-icon ui-icon-pencil"></span>'
            + '</button>';
    var del  = '<button class="ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only" style="width: 20px; height: 18px;" role="button" aria-disabled="false" title="刪除資料"'
            + ' onclick="actDel(\'' + rowid + '\');">'
            + '<span class="ui-button-icon-primary ui-icon ui-icon-trash"></span></button>'
*/
    return '<td style="text-align: center;">'+ edit + del + '</td>';
}

//顯示資料
function fillData(data) {
    //清除表格
    clearTable();
    $("#bExport").removeAttr("disabled"); //按鍵移除唯讀
    $("#paginator").pagination("updateItems", data.totalItems); ////頁數
    //填入表格
    for (var i = 0; i < data.list.length; i++) {
        var detail = data.list[i];
        var columns = "";
        var rowid = "rowid";
        columns += dispActButtons(rowid); //編輯按鈕

        columns += "<td>" + detail.logid + "</td>";
        columns += "<td>" + detail.logdescript + "</td>";
        columns += "<td>" + detail.divtitle + "</td>";
        columns += "<td>" + detail.descript + "</td>";
        columns += "<td>" + detail.userid + "</td>";
        columns += "<td>" + detail.opdate + "</td>";
        columns += "<td>" + detail.optime + "</td>";
        columns += "<td>" + detail.data + "</td>";

        $("#tableData").append("<tr>" + columns + "</tr>")
    }
    //編輯按鈕
    $(".list-edit").button({icons: { primary: "ui-icon-pencil" }, text: false});
    $(".list-del").button({icons: { primary: "ui-icon-trash" }, text: false});
    //顯示筆數
    showItemsInfo(data.totalItems);
}
//顯示筆數
function showItemsInfo(totalItems) {
    var startitem = (($("#paginator").pagination("getCurrentPage")-1) * itemsOnPage) + 1; //開始筆數
    var enditem = ($("#paginator").pagination("getCurrentPage") * itemsOnPage); //結束筆數
    if (startitem > totalItems) startitem = totalItems;
    if (enditem > totalItems) enditem = totalItems;

    $("#pagination_info").find("span").remove();
    $("#pagination_info").append($("<span/>").append($("<b/>").text(startitem)))
            .append($("<span/>").text("-"))
            .append($("<span/>").append($("<b/>").text(enditem)))
            .append($("<span/>").text(" of "))
            .append($("<span/>").append($("<b/>").text(totalItems)));
}

////////////////////////////////////////////////////////////////////////////////
//編輯按鍵功能
function actAdd() {
    alert("add");
}
function actEdit(rowid) {
    alert(rowid);
}
//刪除資料
function actDel(rowid) {
    alert(rowid);
}

