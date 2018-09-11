//////////////////////////////////////////////////////////////
//公用變數
var mainGrid;
var isNew = false; //新增或修改
var recorddata; //詳細資料

//起始程式
$(document).ready(function() {
    //系統起始參數與設定
    initSysData();

    //產生表格
    //$.jgrid.formatter.integer.thousandsSeparator=',';
    //$.jgrid.formatter.integer = {thousandsSeparator: ''};
    mainGrid = $('#mainlist').jqGrid({
        url: 'OutLabMntAct.jsp?action=list',
        mtype: 'POST',
        datatype: 'json',
        //datatype: 'local', //設為local:第一次不載入
        colNames:["<span id='bAdd' title='新增資料'></span>",
            //"<button name='bAdd' id='bAdd' title='新增資料'></button>",
            '申請人', '名稱', '被看護人', '姓名', '契約起始日', '契約廢止日', '外展機構名稱'],
        colModel:[
            //按鈕
            {name:'act', index:'act', width:30, align:'center', sortable:false, resizable:false, frozen:true, formatter: dispActButtons},
            //{name:'act', index:'act', width:30, align:'center', sortable:false, resizable:false, frozen:true},
            {name:'regno', index:'regno', width:80, sortable:true},
            {name:'vendname', index:'vendname', width:70, sortable:false},
            {name:'commid', index:'commid', width:80, sortable:true},
            {name:'commname', index:'commname', width:70, sortable:false},
            {name:'wrkbdate', index:'wrkbdate', width:85, sortable:true},
            {name:'abolishdate', index:'abolishdate', width:85, sortable:true},
            {name:'emptitle', index:'emptitle', width:200, sortable:false}
        ],
        sortname: 'wrkbdate',
        sortorder: 'desc', //倒排序
        //caption: "外展看護工網路申請",
        caption: "", //不顯示
        loadonce: false,
        multiselect: false,
        repeatitems: true,
        shrinkToFit: false,
        //width: 705,
        height: 370,
        rowNum: 15,
        rownumbers: true,
        rownumWidth: 30,
        hoverrows: false,
        pager: $('#pager'),
        toppager: true,
        paging: true,
        viewrecords: true,
        recordtext: '{0} - {1} 共 {2} 筆',
        pgtext : " {0} 共 {1} 頁",
        pagerpos: 'center',
        recordpos: 'left',
        //toolbar: [true, 'top'],
        loadError: function(jqXHR, textStatus, errorThrown) {
            alert( 'HTTP status code: ' + jqXHR.status + '\n' + 'textStatus: ' + textStatus + '\n' + 'errorThrown: ' + errorThrown );
            alert( jqXHR.responseText );
        },
        //選取列
        onSelectRow: function(id) {
            //getData(id);
        },
        //編輯按鈕
        afterInsertRow: function(id, currentData, jsondata) {
            //var edit = "<td style='border:0;'><span class='ui-icon ui-icon-pencil' style='cursor:pointer;' title='編輯資料' onclick=\"actEdit('" + id + "');\"></span></td>";
            //var detail = "<td style='border:0;'><span class='ui-icon ui-icon-document' style='cursor:pointer;' title='詳細資料' onclick=\"actEditData('" + options.rowId + "');\"></span></td>";
            //$(this).setCell(id, "act", "<table><tr>"+ edit + "</tr></table>");
        },
        loadComplete: function(data) {
            resetTimeout(); //清除計時
        },
        //查詢欄位
        postData: {
            qregno: function() { return $("#qregno").val(); },
            qcommid: function() { return $("#qcommid").val(); }
        }
    }).navGrid('#mainlist_toppager',{refresh:false, search:false, edit:false, add:false, del:false});

    //編輯按鈕
    function dispActButtons(cellvalue, options, rowObject){
        var edit = "<td style='border:0;'><span class='ui-icon ui-icon-pencil' style='cursor:pointer;' title='編輯資料' onclick=\"actEdit('" + options.rowId + "');\"></span></td>";
        return "<table><tr>"+ edit + "</tr></table>";
    }

    //新增按鈕
	$('#bAdd').css({float:"center", height:"16px"}).button({icons: { primary: "ui-icon-plus" }, text: false}).click(function (e) {
        actAdd();
    });

    //固定欄位
    jQuery("#mainlist").jqGrid('setFrozenColumns');

    //設定toolbar
    //$("#toolbar").show().appendTo("#t_mainlist");

    //查詢功能
	$('#bSearch').button({icons: { primary: "ui-icon-search" }, text: false}).click(function (e) {
        mainGrid.trigger("reloadGrid", [{page:1}]);
    });
    //重新輸入
	$('#bClear').button({icons: { primary: "ui-icon-refresh" }, text: false}).click(function (e) {
        $('#qregno').val('');
        $('#qcommid').val('');
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
    if (sysErrMsg !== '') window.alert('提示', sysErrMsg);

    //顯示第三頁
    showPage(3);
    //載入資料
    //mainGrid.setGridParam({datatype: "json"}).trigger("reloadGrid");

});

////////////////////////////////////////////////////////////////////////////////
//顯示第 page 頁
function showPage(page) {
    if (page === 1) {
        $('#page2').hide();
        $('#page3').hide();
        $('#page1').show();
    } else if (page === 2) {
        $('#page1').hide();
        $('#page3').hide();
        $('#page2').show();
    } else if (page === 3) {
        $('#page1').hide();
        $('#page2').hide();
        $('#page3').show();
    }
}

////////////////////////////////////////////////////////////////////////////////
//編輯按鍵功能
function actAdd() {
    isNew = true;
    $('#EditMode').text("新增");
    //setEditFieldAttr(false);
    clearData();
    showPage(2);
    document.getElementById("regno").focus();
}
function actEdit(id) {
    isNew = false;
    $('#EditMode').text("修改");
    mainGrid.jqGrid('setSelection', id);
    //setReadonlyField(document.forms["frmEdit"].regno, true);
    getData(id);
    showPage(2);
    document.getElementById("regno").focus();
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
        url: 'OutLabMntAct.jsp',
        type: 'GET',
        dataType: "json",
        data: {action:'data', id:id},
        success: function(response) {
            //frm.vendname.value = response.data.cname;
            fillData(response.data);
            recorddata = response.data;
            isNew = false;
        },
        error: function(xhr, textStatus, errorThrown) {
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
}

//填入編輯欄位
function fillData(data) {
    if (!data) {
        clearData();
        return;
    }
    var frm = document.forms["frmEdit"];
    frm.rowid.value = data.rowid;
    frm.regno.value = data.regno;
    frm.vendname.value = data.vendname;
    frm.vendaddr.value = data.vendaddr;
    frm.vendtel.value = data.vendtel;
    frm.commid.value = data.commid;
    frm.commname.value = data.commname;
    frm.style.value = data.style;
    frm.outcome.value = data.outcome;
    frm.wrkbdate.value = data.wrkbdate;
    frm.abolishdate.value = data.abolishdate;
    frm.empid.value = data.empid;
    frm.emptitle.value = data.emptitle;
}

////////////////////////////////////////////////////////////////////////////////
//執行 -> 刪除
function doDelData(id){
    //Ajax Update
    $.ajax({
        url: 'OutLabMntAct.jsp',
        type: 'GET',
        dataType: "json",
        data: {action:'del', id:id},
        success: function(response) {
            if (response.msgid === '0') {
                window.alert(response.msgtxt);
                $('#mainlist').trigger( 'reloadGrid' );
            } else {
                window.alert(response.msgtxt);
            }
        },
        error: function(xhr, textStatus, errorThrown) {
            alert('HTTP status code: ' + jqXHR.status + '\n' + 'textStatus: ' + textStatus + '\n' + 'errorThrown: ' + errorThrown);
            alert(jqXHR.responseText);
        }
    });
}
////////////////////////////////////////////////////////////////////////////////
//執行 -> 新增、修改
function doUpdData(){
    //Ajax Update
    var action = (isNew) ? 'add' : 'edit';
    var params = {};
    params.action = action;
    var frm = document.forms["frmEdit"];
    for (var i = 0; i < frm.elements.length; i++) {
        if (frm.elements[i].type === 'checkbox')
            params[frm.elements[i].name] = frm.elements[i].checked ? 'on' : 'off';
        else
            params[frm.elements[i].name] = frm.elements[i].value;
    }
    //身分證字號
    //if (action === 'edit') params.id = recorddata.id;

    $.ajax({
        url: 'OutLabMntAct.jsp',
        type: 'POST',
        dataType: "json",
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
        error: function(xhr, textStatus, errorThrown) {
            //alert('HTTP status code: ' + jqXHR.status + '\n' + 'textStatus: ' + textStatus + '\n' + 'errorThrown: ' + errorThrown);
            //alert(jqXHR.responseText);
            window.alert('執行 Ajax 錯誤 ! ' + errorThrown);
        }
    });

}

////////////////////////////////////////////////////////////////////////////////
//設定欄位狀態
function setReadonlyField(fld, readonly) {
        if (fld.type !== 'button' && fld.type !== 'submit') {
            var isreadonly = readonly;
            //設定唯讀欄位
            //var fldname = fld.getAttribute('name');
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


////////////////////////////////////////////////////////////////////////////////
//查驗申請人
function checkRegno(field) {
    var frm = document.forms['frmEdit'];
    $.ajax({
        url: 'OutLabMntAct.jsp',
        type: 'POST',
        data: { action: 'vendm', regno: field.value },
        dataType: "json",
        success: function(response) {
            if (response.msgid == '0') {
                frm.vendname.value = response.data.vendname;
                frm.vendaddr.value = response.data.vendaddr;
            } else {
                //frm.vendname.value = '';
                //frm.vendaddr.value = '';
                alert(response.msgtxt);
            }
        },
        error: function(xhr, textStatus, errorThrown) {
            alert('執行 Ajax 錯誤 ! ' + unescape(errorThrown));
        }
    });
}

//查驗外展機構
function checkEmpid(field) {
    var frm = document.forms['frmEdit'];
    $.ajax({
        url: 'OutLabMntAct.jsp',
        type: 'POST',
        data: { action: 'vendm', regno: field.value },
        dataType: "json",
        success: function(response) {
            if (response.msgid == '0') {
                frm.emptitle.value = response.data.vendname;
            } else {
                //frm.emptitle.value = '';
                alert(response.msgtxt);
            }
        },
        error: function(xhr, textStatus, errorThrown) {
            alert('執行 Ajax 錯誤 ! ' + unescape(errorThrown));
        }
    });
}

//查驗被看護人
function checkNgbandy(field) {
    var frm = document.forms['frmEdit'];
    $.ajax({
        url: 'OutLabMntAct.jsp',
        type: 'POST',
        data: { action: 'ngbandy', commid: field.value },
        dataType: "json",
        success: function(response) {
            if (response.msgid == '0') {
                frm.commname.value = response.data.commname;
                if (response.msgtxt != '') alert(response.msgtxt);
            } else {
                //frm.commname.value = '';
                alert(response.msgtxt);
            }
        },
        error: function(xhr, textStatus, errorThrown) {
            alert('執行 Ajax 錯誤 ! ' + unescape(errorThrown));
        }
    });
}

//審核被看護人
function verifyNgbandy(field) {
    resetTimeout(); //清除計時
    var frm = document.forms['frmVerify'];
    if (frm.commidVerify.value != '') {
        $.ajax({
            url: 'OutLabMntAct.jsp',
            type: 'POST',
            data: { action: 'verifyNgbandy', commid: frm.commidVerify.value.toUpperCase() },
            dataType: "json",
            success: function(response) {
                if (response.msgid == '0') {
                    $('#verifyResult').text(response.data.verifyResult);
                    $('#txtcommid').text(response.data.commid);
                    $('#txtcommname').text(response.data.commname);
                    alert(response.data.verifyResult);
                } else {
                    $('#verifyResult').text('');
                    $('#txtcommid').text('');
                    $('#txtcommname').text('');
                    alert(response.msgtxt);
                }
            },
            error: function(xhr, textStatus, errorThrown) {
                alert('執行 Ajax 錯誤 ! ' + unescape(errorThrown));
            }
        });
    }
}

