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
    //$.jgrid.formatter.integer = {thousandsSeparator: ''};
    mainGrid = jQuery('#mainlist').jqGrid({
        url: '/labweb/REST/labsys/admin/MntDivisionAct2.jsp?command=list',
        mtype: 'GET',
        datatype: 'json',
        //datatype: 'local', //設為local:第一次不載入
        colNames:["<span id='bAdd' title='新增資料'></span>",
            //"<button name='bAdd' id='bAdd' title='新增資料'></button>",
            '代碼', '單位名稱', '所屬區域代碼'],
        colModel:[
            //按鈕
            {name:'act', index:'act', width:44, align:'center', sortable:false, resizable:false, frozen:true, formatter: dispActButtons},
            //{name:'act', index:'act', width:44, align:'center', sortable:false, resizable:false, frozen:true},
            {name:'id', index:'id', width:60, sortable:true, key:true},
            {name:'title', index:'title', width:300, sortable:true},
            {name:'region', index:'region', width:120, sortable:false}
        ],
        sortname: 'id',
        caption: "使用者單位管理",
        loadonce: false,
        multiselect: false,
        repeatitems: true,
        shrinkToFit: false,
        //width: 600,
        height: 370,
        rowNum: 15,
        rownumbers: true,
        rownumWidth: 30,
        pager: $('#pager'),
        toppager: true,
        paging: true,
        viewrecords: true,
        recordtext: '{0} - {1} 共 {2} 筆',
        pgtext : " {0} 共 {1} 頁",
        pagerpos: 'center',
        recordpos: 'left',
        toolbar: [true, 'top'],
        loadError: function(jqXHR, textStatus, errorThrown) {
            alert('HTTP status code: ' + jqXHR.status + '\n' + 'textStatus: ' + textStatus + '\n' + 'errorThrown: ' + errorThrown);
            alert(jqXHR.responseText);
        },
        //選取列
        onSelectRow: function(id) {
            //getData(id);
        },
        //編輯按鈕
        afterInsertRow: function(id, currentData, jsondata) {
            //var edit = "<td style='border:0;'><span class='ui-icon ui-icon-pencil' style='cursor:pointer;' title='編輯資料' onclick=\"actEdit('" + id + "');\"></span></td>";
            //var del = "<td style='border:0;'><span class='ui-icon ui-icon-trash' style='cursor:pointer;' title='刪除資料' onclick=\"actDel('" + id + "');\"></span></td>";
            //var detail = "<td style='border:0;'><span class='ui-icon ui-icon-document' style='cursor:pointer;' title='詳細資料' onclick=\"actEditData('" + options.rowId + "');\"></span></td>";
            //$(this).setCell(id, "act", "<table><tr>"+ edit + del + "</tr></table>");
        },
        loadComplete: function(data) {
        },
        //查詢欄位
        postData: {
            qid: function() { return $("#qid").val(); },
            qtitle: function() { return $("#qtitle").val(); }
        }
    }).navGrid('#mainlist_toppager',{refresh:false, search:false, edit:false, add:false, del:false});

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
    jQuery("#mainlist").jqGrid('setFrozenColumns');

    //設定toolbar
    $("#toolbar").show().appendTo("#t_mainlist");

    //查詢功能
	$('#bSearch').button({icons: { primary: "ui-icon-search" }, text: false}).click(function (e) {
        mainGrid.trigger("reloadGrid", [{page:1}]);
    });
    //清除功能
	$('#bClear').button({icons: { primary: "ui-icon-refresh" }, text: false}).click(function (e) {
        $('#qid').val('');
        $('#qtitle').val('');
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

    //顯示錯誤訊息
    if (sysErrMsg !== '') alert(sysErrMsg);

    //設定游標位置

});

////////////////////////////////////////////////////////////////////////////////
//顯示第 page 頁
function showPage(page) {
    if (page === 1) {
        //$('#page2').hide("slide", {direction: "down"}, 200);
        //$('#page1').show("slide", {direction: "up"}, 200);
        $('#page2').hide();
        $('#page1').show();
    } else if (page === 2) {
        //$('#page1').hide("slide", {direction: "up"}, 200);
        //$('#page2').show("slide", {direction: "down"}, 200, function() {
        $('#page1').hide();
        $('#page2').show(0, function() {
            if (isNew) document.getElementById("id").focus();
            else document.getElementById("title").focus();
        });
    }
}

////////////////////////////////////////////////////////////////////////////////
//編輯按鍵功能
function actAdd() {
    isNew = true;
    $('#EditMode').text("新增");
    setReadonlyField(document.forms["frmEdit"].id, false);
    clearData();
    showPage(2);
}
function actEdit(id) {
    isNew = false;
    $('#EditMode').text("修改");
    mainGrid.jqGrid('setSelection', id);
    setReadonlyField(document.forms["frmEdit"].id, true);
    getData(id);
    showPage(2);
}
//刪除資料
function actDel(id) {
    mainGrid.jqGrid('setSelection', id);
    if (window.confirm('是否刪除此筆資料？'+id)) {
        doDelData( id );
    };
}
function actSave() {
    doUpdData();
}
function actCancel() {
    if (window.confirm('確定要取消編輯？')) {
        $('#FormError').hide();
        showPage(1);
    }
}


////////////////////////////////////////////////////////////////////////////////
//讀取欄位資料
function getData(id) {
    //讀取資料 Ajax
    $.ajax({
        url: '/labweb/REST/labsys/admin/MntDivisionAct2.jsp',
        type: 'GET',
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        data: {id:id},
        success: function(response) {
            //frm.vendname.value = response.data.cname;
            fillData(response.data);
            recorddata = response.data;
            isNew = false;
        },
        error: function(jqXHR, textStatus, errorThrown) {
            alert('HTTP status code: ' + jqXHR.status + '\n' + 'textStatus: ' + textStatus + '\n' + 'errorThrown: ' + errorThrown);
            alert(jqXHR.responseText);
        }
    });
}
//清除編輯欄位
function clearData() {
    var frm = document.forms["frmEdit"];
    for (var i = 0; i < frm.elements.length; i++) {
        if (frm.elements[i].type === 'checkbox') {
            frm.elements[i].checked = false;
        } else if ((frm.elements[i].type !== 'button') && (frm.elements[i].type !== 'submit')) {
            frm.elements[i].value = '';
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
    frm.id.value = data.id;
    frm.title.value = data.title;
    frm.region.value = data.region;
}

////////////////////////////////////////////////////////////////////////////////
//執行 -> 刪除
function doDelData(id){
    //Ajax Update
    $.ajax({
        url: '/labweb/REST/labsys/admin/MntDivisionAct2.jsp',
        type: 'DELETE',
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        data: {id:id},
        success: function(response) {
            if (response.msgid === '0') {
                window.alert(response.msgtxt);
                $('#mainlist').trigger( 'reloadGrid' );
            } else {
                window.alert(response.msgtxt);
            }
        },
        error: function(jqXHR, textStatus, errorThrown) {
            alert('HTTP status code: ' + jqXHR.status + '\n' + 'textStatus: ' + textStatus + '\n' + 'errorThrown: ' + errorThrown);
            alert(jqXHR.responseText);
        }
    });
}
////////////////////////////////////////////////////////////////////////////////
//執行 -> 新增、修改
function doUpdData(){
    //Ajax Update
    var command = (isNew) ? 'add' : 'edit';
    var params = {};
    var frm = document.forms["frmEdit"];
    for (var i = 0; i < frm.elements.length; i++) {
        if (frm.elements[i].type === 'checkbox')
            params[frm.elements[i].name] = frm.elements[i].checked ? 'on' : 'off';
        else
            params[frm.elements[i].name] = frm.elements[i].value;
    }
    //身分證字號
    if ((!isNew)) params.id = recorddata.id;

    $.ajax({
        url: '/labweb/REST/labsys/admin/MntDivisionAct2.jsp',
        type: (isNew) ? 'POST' : 'PUT',
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        data: params,
        success: function(response) {
            if (response.msgid === '0') {
                window.alert(response.msgtxt);
                $('#FormError').hide();
                $('#mainlist').trigger( 'reloadGrid' );
                showPage(1);
            } else {
                $('#FormError').show(); //顯示錯誤訊息
                $('#FormErrorMsg').text(response.msgtxt);
                try {
                    document.getElementById(response.invalidField).focus();
                } catch(e) {};
                window.alert(response.msgtxt);
            }
        },
        error: function(jqXHR, textStatus, errorThrown) {
            alert('HTTP status code: ' + jqXHR.status + '\n' + 'textStatus: ' + textStatus + '\n' + 'errorThrown: ' + errorThrown);
            alert(jqXHR.responseText);
        }
    });

}

////////////////////////////////////////////////////////////////////////////////
//設定欄位狀態
function setReadonlyField(fld, readonly) {
        if (fld.type !== 'button' && fld.type !== 'submit') {
            var isreadonly = readonly;
            //設定唯讀欄位
            var fldname = fld.getAttribute('name');
            //設定屬性
            if (fld.type === 'checkbox') {
                fld.disabled = isreadonly;
            } else if (fld.type === 'select-one') {
                fld.disabled = isreadonly;
                fld.className = (isreadonly ? 'ab-sel-readonly' : 'ab-sel');
            } else {
                fld.readOnly = isreadonly;
                fld.className = (isreadonly ? 'ab-inp-readonly' : 'ab-inp');
            }
        }
}
//設定全部
function setEditFieldAttr(readonly) {
    var frm = document.forms["frmEdit"];
    for (var i = 0; i < frm.elements.length; i++) {
        setReadonlyField(frm.elements[i], readonly);
    }
}


