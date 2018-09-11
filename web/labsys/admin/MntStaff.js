//////////////////////////////////////////////////////////////
//公用變數
var mainGrid;
var isNew = false; //新增或修改
var hasDetail = false; //是否載入詳細資料
var recorddata; //詳細資料

//起始程式
$(document).ready(function() {
    //系統起始參數與設定
    initSysData();

    //產生表格
    mainGrid = jQuery("#mainlist").jqGrid({
        url: "MntStaffAct.jsp?action=list",
        mtype: 'POST',
        datatype: "json",
        //datatype: "local", //設為local:第一次不載入
        colNames: ["<span id='bAdd' title='新增資料'></span>", "單位", "姓名"],
        colModel: [
            {name:'act', index:'act', width:44, align:'center', sortable:false, resizable:false, frozen:true, formatter: dispActButtons},
            {name:"branchtitle", index:"branchtitle", width:200, sortable:true},
            {name:"descript", index:"descript", width:140, sortable:true}
        ],
        sortname: "branchtitle",
        caption: "使用者權限管理",
        loadonce: false,
        multiselect: false,
        repeatitems: true,
        shrinkToFit: false,
//        width: 450,
//        height: 370,
        width: 'auto',
        height: 'auto',
        rowNum: 15,
        rownumbers: true,
        rownumWidth: 30,
        pager: $("#pager"),
        toppager: true,
        paging: true,
        viewrecords: true,
        recordtext: "{0} - {1} 共 {2} 筆",
        pgtext : " {0} 共 {1} 頁",
        pagerpos: "right",
        recordpos: "left",
        toolbar: [(userDivision === "0000"), "top"], //設定toolbar，職訓局才顯示
        loadError: function(jqXHR, textStatus, errorThrown) {
            alert("HTTP status code: " + jqXHR.status + "\n" + "textStatus: " + textStatus + "\n" + "errorThrown: " + errorThrown);
            alert(jqXHR.responseText);
        },
        //檢查ajax資料是否正確
        beforeProcessing: function(data, status, xhr) {
            if (data.msgid > 0) {
                alert(data.msgtxt);
                if (data.msgid >= 90) { //逾時或權限不足，登出
                    window.location.href = sessionStorage.logoutFile;
                }
            }
        },
        afterInsertRow: function(id, currentData, jsondata) {
            //var edit = "<td style='border:0;'><span class='ui-icon ui-icon-pencil' style='cursor:pointer;' title='編輯資料' onclick=\"actEdit('" + id + "');\"></span></td>";
            //var del = "<td style='border:0;'><span class='ui-icon ui-icon-trash' style='cursor:pointer;' title='刪除資料' onclick=\"actDel('" + id + "');\"></span></td>";
            //var detail = "<td style='border:0;'><span class='ui-icon ui-icon-document' style='cursor:pointer;' title='詳細資料' onclick=\"actEditData('" + options.rowId + "');\"></span></td>";
            //$(this).setCell(id, "act", "<table><tr>"+ edit + del + "</tr></table>");
        },
        loadComplete: function(data) {
        },
        postData: { //查詢欄位
            qbranch: function() { return $("#qbranch").val(); },
            qdescript: function() { return $("#qdescript").val(); }
        },
        onSelectRow: function(id) { //選取欄位
            getData(id);
        }
    }).navGrid("#mainlist_toppager",{refresh:false, search:false, edit:false, add:false, del:false});

    //編輯按鈕
    function dispActButtons(cellvalue, options, rowObject){
        var edit = "<td style='border:0;'><span class='ui-icon ui-icon-pencil' style='cursor:pointer;' title='編輯資料' onclick=\"actEdit('" + options.rowId + "');\"></span></td>";
        var del = "<td style='border:0;'><span class='ui-icon ui-icon-trash' style='cursor:pointer;' title='刪除資料' onclick=\"actDel('" + options.rowId + "');\"></span></td>";
        return "<table><tr>"+ edit + del + "</tr></table>";
    }

    //新增按鈕
	$('#bAdd').css({float:"center", height:"16px"}).button({icons: { primary: "ui-icon-plus" }, text: false}).click(function (e) {
        actAdd();
    });

    //固定欄位
    $("#mainlist").jqGrid('setFrozenColumns');

    //設定toolbar，職訓局才顯示
    if (userDivision === "0000") {
        $("#toolbar").appendTo("#t_mainlist");
        $("#toolbar").show();
    } else {
        $("#toolbar").hide();
    }

    //查詢功能
	$('#bSearch').button({icons: { primary: "ui-icon-search" }, text: false}).click(function (e) {
        mainGrid.trigger("reloadGrid", [{page:1}]);
    });
    $("#qbranch").change(function() {
        //mainGrid.jqGrid("setGridParam", { "datatype" : "json" });
        mainGrid.trigger("reloadGrid", [{page:1}]);
    });

    //儲檔
	$('#bSave').button({icons: { primary: "ui-icon-check" }, text: false}).click(function (e) {
        actSave();
    });
    //取消
	$('#bCancle').button({icons: { primary: "ui-icon-close" }, text: false}).click(function (e) {
        actCancel();
    });

    //設定按鈕欄位狀態
    setButtonStatus(false);
    setEditFieldAttr(true);
    clearData();

    //顯示錯誤訊息
    if (sysErrMsg !== '') alert(sysErrMsg);

    //設定游標位置

});

////////////////////////////////////////////////////////////////////////////////
//編輯按鍵功能
$.blockUI.defaults.overlayCSS.backgroundColor = "#aaa";
$.blockUI.defaults.overlayCSS.opacity = 0.2;
function actAdd() {
    isNew = true;
    setButtonStatus(true);
    setEditFieldAttr(false);
    clearData();
    $("#divlist").block({message: null});
    document.getElementById("id").focus();
}
function actEdit(id) {
    mainGrid.jqGrid('setSelection', id);
    getData(id);
    isNew = false;
    setButtonStatus(true);
    setEditFieldAttr(false);
    $("#divlist").block({message: null});
    document.getElementById("acckind").focus();
}
function actDel(id) {
    mainGrid.jqGrid('setSelection', id);
    getData(id);
    if (window.confirm("是否刪除此筆資料？"+id)) {
        doDelData( recorddata.id );
    };
}
function actSave() {
    doUpdData();
}
function actCancel() {
    if (window.confirm('確定要取消編輯？')) {
        $('#FormError').hide();
        setButtonStatus(false);
        setEditFieldAttr(true);
        fillData();
        $("#divlist").unblock();
        //選擇行
        var selectedRowId = mainGrid.jqGrid("getGridParam", "selrow");
        mainGrid.jqGrid("setSelection", selectedRowId, true);
        if (document.activeElement !== document.body) document.activeElement.blur();
    }
}

////////////////////////////////////////////////////////////////////////////////
//讀取欄位資料
function getData(id) {
    $("#btnEdit").prop("disabled", true);
    $("#btnDel").prop("disabled", true);
    //Ext.get("main-grid").mask();
    //讀取資料 Ajax
    $.ajax({
        url: "MntStaffAct.jsp",
        type: "POST",
        dataType: "json",
        data: {action:"data", id:id},
        success: function(response) {
            //frm.vendname.value = response.data.cname;
            fillData(response.data);
            recorddata = response.data;
            isNew = false;
        },
        error: function(jqXHR, textStatus, errorThrown) {
            alert("HTTP status code: " + jqXHR.status + "\n" + "textStatus: " + textStatus + "\n" + "errorThrown: " + errorThrown);
            alert(jqXHR.responseText);
        }
    });
}
//清除編輯欄位
function clearData() {
    var frm = document.forms["frmEdit"];
    for (var i = 0; i < frm.elements.length; i++) {
        if (frm.elements[i].type === "checkbox") {
            frm.elements[i].checked = false;
        } else if ((frm.elements[i].type !== "button") && (frm.elements[i].type !== "submit")) {
            frm.elements[i].value = "";
        }
    }
    hasDetail = false;
}
//填入編輯欄位
function fillData(data) {
    if (!data) {
        clearData();
        return;
    }
    var frm = document.forms["frmEdit"];
    //frm.id.value = data.id;
    frm.acckind.value = data.acckind;
    frm.pwd.value = data.pwd;
    frm.descript.value = data.descript;
    //frm.psid.value = data.psid;
    frm.branch.value = data.branch;
    frm.department.value = data.department;
    frm.job.value = data.job;
    frm.tel.value = data.tel;
    frm.region.value = data.region;
    frm.logindate.value = data.logindate;
    frm.setdate.value = data.setdate;
    frm.amenduser.value = data.amenduser;
    for (var i=0; i < data.privlist.length; i++) {
        frm.elements[data.privlist[i].id].checked = (data.privlist[i].priv === "1");
    }
}
////////////////////////////////////////////////////////////////////////////////
//執行 -> 刪除
function doDelData(id){
    //Ext.get("divToolbar").mask();
    //Ajax Update
    $.ajax({
        url: "MntStaffAct.jsp",
        type: "POST",
        dataType: "json",
        data: {action:"del", id:id},
        success: function(response) {
            if (response.msgid === "0") {
                window.alert(response.msgtxt);
                clearData();
                $("#mainlist").trigger( "reloadGrid" );
            } else {
                window.alert(response.msgtxt);
            }
        },
        error: function(jqXHR, textStatus, errorThrown) {
            alert("HTTP status code: " + jqXHR.status + "\n" + "textStatus: " + textStatus + "\n" + "errorThrown: " + errorThrown);
            alert(jqXHR.responseText);
        }
    });
}
////////////////////////////////////////////////////////////////////////////////
//執行 -> 新增、修改
function doUpdData(){
    //Ajax Update
    var action = (isNew) ? "add" : "edit";
    var params = {};
    params.action = action;
    var frm = document.forms["frmEdit"];
    for (var i = 0; i < frm.elements.length; i++) {
        if (frm.elements[i].type === "checkbox")
            params[frm.elements[i].name] = frm.elements[i].checked ? "on" : "off";
        else
            params[frm.elements[i].name] = frm.elements[i].value;
    }
    //身分證字號
    if (action === "edit") params.id = recorddata.id;

    $.ajax({
        url: "MntStaffAct.jsp",
        type: "POST",
        dataType: "json",
        data: params,
        success: function(response) {
            if (response.msgid === "0") {
                window.alert(response.msgtxt);
                setButtonStatus(false);
                setEditFieldAttr(true);
                clearData();
                $("#FormError").hide();
                $("#divlist").unblock();
                var selectedRowId = mainGrid.jqGrid("getGridParam", "selrow");
                $("#mainlist").trigger( "reloadGrid" );
                mainGrid.jqGrid("setSelection", selectedRowId, true);
                if (document.activeElement !== document.body) document.activeElement.blur();
            } else {
                $("#FormError").show(); //顯示錯誤訊息
                $("#FormErrorMsg").text(response.msgtxt);
                try {
                    document.getElementById(response.invalidField).focus();
                } catch(e) {};
                window.alert(response.msgtxt);
            }
        },
        error: function(jqXHR, textStatus, errorThrown) {
            alert("HTTP status code: " + jqXHR.status + "\n" + "textStatus: " + textStatus + "\n" + "errorThrown: " + errorThrown);
            alert(jqXHR.responseText);
        }
    });

}

////////////////////////////////////////////////////////////////////////////////
//設定按鈕狀態
function setButtonStatus(isedit) {
    if (isedit) {
        $("#bSave").button("enable");
        $("#bCancle").button("enable");
    } else {
        $("#bSave").button("disable");
        $("#bCancle").button("disable");
    }
}
////////////////////////////////////////////////////////////////////////////////
//設定欄位狀態
function setEditFieldAttr(readonly) {
    var frm = document.forms["frmEdit"];
    for (var i = 0; i < frm.elements.length; i++) {
        if (frm.elements[i].type !== "button" && frm.elements[i].type !== "submit") {
            var isreadonly = readonly;
            //設定唯讀欄位
            var fldname = frm.elements[i].getAttribute("name");
            if ( (!isNew && (fldname === "id")) || ((userDivision !== "0000") && (fldname === "branch"))
                    || (fldname === "logindate") || (fldname === "setdate") || (fldname === "amenduser") ) {
                isreadonly = true;
            }
            //設定屬性
            if (frm.elements[i].type === "checkbox") {
                frm.elements[i].disabled = isreadonly;
            } else if (frm.elements[i].type === "select-one") {
                frm.elements[i].disabled = isreadonly;
                frm.elements[i].className = (isreadonly ? "ab-sel-readonly" : "ab-sel");
            } else {
                frm.elements[i].readOnly = isreadonly;
                frm.elements[i].className = (isreadonly ? "ab-inp-readonly" : "ab-inp");
            }
        }
    }
    //設定權限狀態
    if (!readonly) {
        for (i = 0; i < privList.length; i++) {
            frm.elements["priv"+i].disabled = !privList[i]; //主模組權限
            for (var j = 0; j < 16; j++) { //子模組權限
                if (frm.elements["priv"+i+".sub"+j])
                    frm.elements["priv"+i+".sub"+j].disabled = !privList[i];
                else
                    break;
            }
        }
    }
}

