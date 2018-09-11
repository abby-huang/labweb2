<%@ page pageEncoding="UTF-8" contentType="text/html"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.text.*" %>
<%@ page import="com.absys.util.*" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
//尚未登入
if (userId.length() == 0) {
    response.sendRedirect("../Logout.jsp");
}

String pageHeader = "雇主通報行蹤不明外勞";
request.setCharacterEncoding("UTF-8");
//String thisPage = request.getRequestURI();
String thisPage = "EscNotify.jsp";

//定義變數
String errMsg = "";
String redirectUrl = "false"; //是否導向「外籍勞工申請案件網路線上申辦系統」
Connection conn = null;
String sessionId = session.getId();

conn = getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
Statement stmt = conn.createStatement();
ResultSet rs;
String qs;

String action = AbString.rtrimCheck(request.getParameter("action") );
String natcode = AbString.rtrimCheck( request.getParameter("natcode") );
String passno = AbString.rtrimCheck( request.getParameter("passno") ).toUpperCase();
String escapedate = AbString.rtrimCheck( request.getParameter("escapedate") );
String engname = AbString.rtrimCheck( request.getParameter("engname") ).toUpperCase();
String sex = AbString.rtrimCheck( request.getParameter("sex") ).toUpperCase();
String vendno = AbString.rtrimCheck( request.getParameter("vendno") ).toUpperCase();
String vendname = AbString.rtrimCheck( request.getParameter("vendname") );
String vendtel1 = AbString.rtrimCheck( request.getParameter("vendtel1") );
String vendtel2 = AbString.rtrimCheck( request.getParameter("vendtel2") );
String indate = AbString.rtrimCheck( request.getParameter("indate") );
String missplace = AbString.rtrimCheck( request.getParameter("missplace") );
String applydate = AbString.rtrimCheck( request.getParameter("applydate") );
String citycode = AbString.rtrimCheck( request.getParameter("citycode") );
String crimedate = AbString.rtrimCheck( request.getParameter("crimedate") );

String today = AbDate.getToday();

////////////////////////////////////////////////////////////////////////////////
//執行動作
if (action.equals("查詢或刪除行蹤不明外勞")) {
    if (conn != null) conn.close();
    response.sendRedirect("EscQuery.jsp");
} else if (action.equals("上傳通報")) {
    qs = "select * from labdyn_laborm where natcode=" + AbSql.getEqualStr(natcode)
         + " and passno=" + AbSql.getEqualStr(passno);
    rs = stmt.executeQuery(qs);
    if (!rs.next()) {
        errMsg = "查無此外勞，請查明後再行通報";
    } else {
        citycode = AbString.rtrimCheck(rs.getString("citycode"));
    }
    rs.close();

    if (errMsg.length()==0) {
        qs = "select * from labdyn_escapelab where natcode=" + AbSql.getEqualStr(natcode)
             + " and passno=" + AbSql.getEqualStr(passno)
             + " and chng_id <> 'D' "
             + " and escapedate=" + AbSql.getEqualStr(escapedate.replace("-", ""));
        rs = stmt.executeQuery(qs);
        if (rs.next()) {
            errMsg = "此名外勞已有通報資料，請查明後再行通報";
        }
        rs.close();
    }
    if (errMsg.length()==0) {
        qs = "select * from labdyn_escapelab where natcode=" + AbSql.getEqualStr(natcode)
             + " and passno=" + AbSql.getEqualStr(passno)
             + " and chng_id <> 'D' "
             + " and applydate=" + AbSql.getEqualStr(today);
        rs = stmt.executeQuery(qs);
        if (rs.next()) {
            errMsg = "此名外勞已有通報資料，請查明後再行通報";
        }
        rs.close();
    }

    if (errMsg.length()==0) {
        if (engname.length() == 0) {
            errMsg = "外勞姓名必須輸入";
        } else if (AbString.checkCharset(engname, "ISO8859_1") != 0) {
            errMsg = "外勞姓名不可以含有中文";
        }
    }
    if ((errMsg.length()==0) && ((sex.length() == 0) || ("MF".indexOf(sex) < 0)) ) {
        errMsg = "外勞性別錯誤";
    }
    if ((errMsg.length()==0) && ((indate.length() > 0) && !AbDate.isValidDate(indate, "yyyy-MM-dd")) ) {
        errMsg = "入國日期錯誤";
    }
    if ((errMsg.length()==0) && (!AbDate.isValidDate(escapedate, "yyyy-MM-dd") || (escapedate.compareTo(today) > 0)) ) {
        errMsg = "行蹤不明日期錯誤";
    }
    if ((errMsg.length()==0) && (missplace.length() == 0)) {
        errMsg = "失聯地點為必填欄位";
    }
    if ((errMsg.length()==0) && (common.Comm.getCodeTitle(stmt, vendno, "labdyn_vend", "vendno", "cname").length() == 0)) {
        errMsg = "查無此雇主，請查明後再行通報";
    }
    if (errMsg.length()==0) {
        if (vendtel1.length() == 0) {
            errMsg = "聯繫電話為必填欄位";
        } else if (vendtel1.length() < 7) {
            errMsg = "聯繫電話最少要輸入7碼以上";
        } else if (AbString.checkCharset(vendtel1, "ISO8859_1") != 0) {
            errMsg = "聯繫電話不可以含有中文";
        }
    }
    if (errMsg.length()==0) {
        if (vendtel2.length() > 0) {
            if (vendtel2.length() < 7) {
                errMsg = "行動電話最少要輸入7碼以上";
            } else if (AbString.checkCharset(vendtel2, "ISO8859_1") != 0) {
                errMsg = "行動電話不可以含有中文";
            }
        }
    }
    if (errMsg.length()==0){
        //改為工作天 2015.10.13
        //String lastday = AbDate.dateAdd(escapedate.replaceAll("-", ""), 0, 0, 2);
        String lastday = common.Comm.workDayAdd(stmt, escapedate.replaceAll("-", ""), 3);
        if (lastday.compareTo(today) < 0) {
            redirectUrl = "true";
            errMsg = "本系統僅適用外勞行蹤不明未滿3個工作天之通報案件。行蹤不明滿三日，請至「外籍勞工申請案件網路線上申辦系統」申報。(註 ：雇主須以自然人憑證申請系統帳號並設立密碼後，使得申報。)";
        }
        //errMsg = lastday;
    }

    //更新資料庫
    if (errMsg.length()==0) {
        qs = "insert into labdyn_escapelab"
                + " values("
                + AbSql.getEqualStr(natcode)
                + "," + AbSql.getEqualStr(passno)
                + "," + AbSql.getEqualStr(escapedate.replaceAll("-", ""))
                + "," + AbSql.getEqualStr(engname)
                + "," + AbSql.getEqualStr(sex)
                + "," + AbSql.getEqualStr(vendno)
                + "," + AbSql.getEqualStr(vendname)
                + "," + AbSql.getEqualStr(vendtel1)
                + "," + AbSql.getEqualStr(vendtel2)
                + "," + AbSql.getEqualStr(indate.replaceAll("-", ""))
                + "," + AbSql.getEqualStr(missplace)
                + "," + AbSql.getEqualStr(today)
                + "," + AbSql.getEqualStr(citycode)
                + ", null"
                + ", null"
                + ", null"
                + ", null"
                + ", null"
                + ", 'I'"
                + ", sysdate"
                + ")";
        stmt.executeUpdate(qs);
        errMsg = "已經完成通報";
        natcode = "";
        passno = "";
        escapedate = "";
        engname = "";
        sex = "";
        vendno = "";
        vendname = "";
        vendtel1 = "";
        vendtel2 = "";
        indate = "";
        missplace = "";
        applydate = "";
        citycode = "";
        crimedate = "";
    }
}



%>

<!DOCTYPE html>
<head>
    <title><%=pageHeader%></title>
    <script src="<%=appRoot%>/js/jquery.js"></script>
    <script language="javascript" src="<%=appRoot%>/js/My97DatePicker/WdatePicker.js"></script>
    <link rel="stylesheet" type="text/css" href="<%=appRoot%>/resources/css/absys0.css" />

    <script>
        //系統名稱與路徑
        var appTitle = '<%=appTitle%>';
        var appName = '<%=appName%>';
        var appRoot = '<%=appRoot%>';
        //設定 Ext 路徑
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
        //檢查外勞
        function checkLabor(field) {
            var frm = document.forms['frmMain'];
            $.ajax({
                url: 'ajax/CommGetData.jsp',
                type: 'GET',
                data: { action: 'laborm', natcode: frm.natcode.value, passno: frm.passno.value },
                dataType: "json",
                success: function(response) {
                    if (response.msgid == '0') {
                        frm.engname.value = response.data.engname;
                        frm.sex.value = response.data.sex;
                    } else {
                        frm.engname.value = '';
                        frm.sex.value = '';
                        //alert('查無此外勞，請查明後再行通報 !');
                    }
                },
                error: function(xhr, textStatus, errorThrown) {
                    window.alert('執行 Ajax 錯誤 ! ' + errorThrown);
                }
            });
        }
        //檢查雇主
        function checkVend(field) {
            var frm = document.forms['frmMain'];
            $.ajax({
                url: 'ajax/CommGetData.jsp',
                type: 'GET',
                data: { action: 'vend', vendno: frm.vendno.value },
                dataType: "json",
                success: function(response) {
                    if (response.msgid == '0') {
                        frm.vendname.value = response.data.cname;
                    } else {
                        frm.vendname.value = '';
                        //alert('查無此雇主，請查明後再行通報 !');
                    }
                },
                error: function(xhr, textStatus, errorThrown) {
                    window.alert('執行 Ajax 錯誤 ! ' + errorThrown);
                }
            });
        }
    </script>
</head>

<body class="ab-body" style="border:2px; margin:0px; padding:0px; overflow:auto;">
    <div id="divMenuTitle" class="ab-body">
        <div id="divAppTitle" style="height:30px; padding:0px; background:url(<%=appRoot%>/resources/images/esctoptitle.jpg) repeat-x;"></div>
    </div>

    <center>
    <!--行蹤不明外勞通報-->
    <form id="frmMain" action="" method="post">
        <div style="padding: 20px 0px 0px 0px;">
            <table class="ab-box03" style="width:500px;">
                <tr>
                    <td class="ab-frmlb1" style="border:0px;" align="left" width="30%">
                        <a class="ab-a2" href="../manual/escnotify.pdf">操作說明</a>
                    </td>
                    <td class="ab-frmlb1" style="border:0px;" align="center" width="40%">
                        <input type="hidden" name="action" value="">
                        <input class="ab-btn00" style="width:70px;" id="btnSave" name="" type="button" value="上傳通報"
                                onclick="this.form.action.value=this.value; this.form.submit();">
                    </td>
                    <td class="ab-frmlb1" style="border:0px;" align="right" width="30%">
                        <input class="ab-btn00" style="width:150px;" id="btnQuery" name="" type="button" value="查詢或刪除行蹤不明外勞"
                                onclick="this.form.action.value=this.value; this.form.submit();">
                    </td>
                </tr>
            </table>
        </div>

        <div style="padding: 3px 0px 0px 0px;">
            <table class="ab-box03" style="width:500px;">
                <tr>
                    <td colspan=2 class="ab-frmlb1" align="left" >
                        說明：
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="right" width="10%" >
                        1.
                    </td>
                    <td class="ab-frmlb1" align="left" width="90%" >
                        本系統僅適用於外勞行蹤不明未滿3日之通報案件。
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="right">
                        2.
                    </td>
                    <td class="ab-frmlb1" align="left">
                        有*者為必填欄位。系統帶出的雇主名稱、外勞姓名、性別可自行修改。
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="right">
                        3.
                    </td>
                    <td class="ab-frmlb1" align="left">
                        <font color="ff0000">上傳通報後可利用查詢功能確認是否已完成通報</font>。
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="right" valign="top">
                        4.
                    </td>
                    <td class="ab-frmlb1" align="left">
                        <font color="ff0000">外國人連續曠職失去聯繫3日後仍未尋獲者，請依法以書面通知當地主管機關、入出國管理機關、警察機關及本署完成法定通報義務。另可至本署「<a href="https://fwapply.wda.gov.tw/efpv/wSite/Control?function=IndexPage">外籍勞工申請案件網路線上申報系統</a>」辦理線上申報。</font>
                    </td>
                </tr>
            </table>
            <table class="ab-box03" style="width:500px;">
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%">
                        行蹤不明外勞：
                    </td>
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                        *國籍：
                        <select class="ab-sel00" name="natcode" value="<%=natcode%>">
                            <%
                            for (int i = 0; i < natcodes.length; i++) {
                            %>
                                    <option value='<%=natcodes[i]%>' <%=(natcodes[i].equals(natcode) ? "selected" : "")%>><%=natcodes[i] + "-" + natnames[i]%></option>
                            <%}%>
                        </select>
                        &nbsp*護照號碼：
                        <input class="ab-inp00" style="width:80px;" type="text" name="passno" value="<%=passno%>" maxlength="10"
                                onchange="this.value=this.value.toUpperCase(); checkLabor(this);" onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                        *外勞姓名：
                        <input class="ab-inp00" style="width:350px;" type="text" name="engname" value="<%=engname%>" maxlength="120" onchange="this.value=this.value.toUpperCase();" onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                        *性別：
                        <input class="ab-inp00" style="width:20px;" type="text" name="sex" value="<%=sex%>" maxlength="1" onchange="this.value=this.value.toUpperCase();" onkeypress="return handleEnter(this, event)">（F：女&nbspM：男）
                        &nbsp入國日期：
                        <!--input class="ab-inp00" style="width:70px;" type="text" name="indate" value="<%=indate%>" maxlength="8" onkeypress="return handleEnter(this, event)">(格式如:20150101)-->
                        <input class="Wdate" style="height:16px; margin:1px; width:90px;" type="text" name="indate" value="<%=indate%>" onClick="WdatePicker()" onFocus="WdatePicker()" onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                        *行蹤不明日期：
                        <!--input class="ab-inp00" style="width:70px;" type="text" name="escapedate" value="<%=escapedate%>" maxlength="8" onkeypress="return handleEnter(this, event)">(格式如:20150101)-->
                        <input class="Wdate" style="height:16px; margin:1px; width:90px;" type="text" name="escapedate" value="<%=escapedate%>" onClick="WdatePicker()" onFocus="WdatePicker()" onkeypress="return handleEnter(this, event)">
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                         *失聯地點：
                        <input class="ab-inp00" style="width:350px;" type="text" name="missplace" value="<%=missplace%>" maxlength="140" onkeypress="return handleEnter(this, event)">
                        <br>失聯地點填寫例如：雇主處、機場、安置單位或填一個地址等。
                    </td>
                </tr>
<!--
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                        *雇主通報日期
                        <input class="ab-inp01" disabled style="width:70px;" type="text" name="applydate" value="<%=applydate%>" maxlength="8" onkeypress="return handleEnter(this, event)">(格式如:20150101)
                        &nbsp*縣市轄區
                        <input class="ab-inp01" style="width:70px;" type="text" name="citycode" value="<%=citycode%>" maxlength="2" onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
-->
            </table>
        </div>

        <div style="padding: 3px 0px 0px 0px;">
            <table class="ab-box03" style="width:500px;">
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                        雇主聯絡資料：
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                        *雇主統一編號、身分證號或居留證號：
                        <input class="ab-inp00" style="width:80px;" type="text" name="vendno" value="<%=vendno%>" maxlength="10"
                               onchange="this.value=this.value.toUpperCase(); checkVend(this);" onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                        *事業單位（雇主）名稱：
                        <input class="ab-inp00" style="width:300px;" type="text" name="vendname" value="<%=vendname%>" maxlength="120" onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                        *聯繫電話：
                        <input class="ab-inp00" style="width:100px;" type="text" name="vendtel1" value="<%=vendtel1%>" maxlength="20" onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                        行動電話：
                        <input class="ab-inp00" style="width:100px;" type="text" name="vendtel2" value="<%=vendtel2%>" maxlength="20" onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
            </table>
        </div>

        </br></br>
    </form>

    </center>
</body>
</html>

<%
//關閉連線
stmt.close();
if (conn != null) conn.close();
%>


<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    if (<%=redirectUrl%>) { //是否前往申請
        if (!alert("<%=errMsg%>")) {
            window.location = "https://fwapply.wda.gov.tw/efpv/wSite/Control?function=IndexPage";
        }
    } else {
        alert("<%=errMsg%>");
    }
</script>
<%}%>

