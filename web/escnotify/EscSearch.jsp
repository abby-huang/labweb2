<%@ page pageEncoding="UTF-8" contentType="text/html"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.text.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page import="com.absys.user.*" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "尋獲行蹤不明外勞";
request.setCharacterEncoding("UTF-8");
//String thisPage = request.getRequestURI();
String thisPage = "EscSearch.jsp";

//尚未登入
if (!userLogin.equals("Y") || (userId == null) || !(modules.hasPrivelege("escnotify", userData.privilege))) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
int pageRows = 100;
String errMsg = "";
Connection conn = null;
String sessionId = session.getId();

conn = getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
Statement stmt = conn.createStatement();
Statement stmt2 = conn.createStatement();
ResultSet rs;
String qs;

String action = filterMetaCharacters( request.getParameter("action") );
String qnatcode = filterMetaCharacters( request.getParameter("qnatcode") );
String qpassno = filterMetaCharacters( request.getParameter("qpassno") ).toUpperCase();
String qvendno = filterMetaCharacters( request.getParameter("qvendno") ).toUpperCase();
String nocrimedate = filterMetaCharacters( request.getParameter("nocrimedate") );
String qcitycode = filterMetaCharacters( request.getParameter("qcitycode") );
String s_qescapedate = filterMetaCharacters( request.getParameter("s_qescapedate") );
String e_qescapedate = filterMetaCharacters( request.getParameter("e_qescapedate") );
String s_qapplydate = filterMetaCharacters( request.getParameter("s_qapplydate") );
String e_qapplydate = filterMetaCharacters( request.getParameter("e_qapplydate") );

String today = AbDate.getToday();

////////////////////////////////////////////////////////////////////////////////
//執行動作
if (action.equals("重新輸入")) {
    qnatcode = "";
    qpassno = "";
    qvendno = "";
    nocrimedate = "";
    qcitycode = "";
    s_qescapedate = "";
    e_qescapedate = "";
    s_qapplydate = "";
    e_qapplydate = "";
} else if (action.equals("通報")) {
    String natcode = filterMetaCharacters( request.getParameter("natcode") );
    String passno = filterMetaCharacters( request.getParameter("passno") );
    String escapedate = filterMetaCharacters( request.getParameter("escapedate") );
    String crimedate = filterMetaCharacters( request.getParameter("crimedate") );
    if ((crimedate.length() == 0) || !AbDate.isValidDate(crimedate, "yyyy-MM-dd")) {
        errMsg = "尋獲日期錯誤";
    }
    if (errMsg.length()==0) {
        qs = "update labdyn_escapelab set"
                + " crimedate=" + AbSql.getEqualStr(crimedate.replaceAll("-", ""))
                + ",branch_=" + AbSql.getEqualStr(userData.branch)
                + ",userid=" + AbSql.getEqualStr(userData.id)
                + ",descript=" + AbSql.getEqualStr(userData.descript)
                + ",applydate2=" + AbSql.getEqualStr(today)
                + ",chng_id='U'"
                + ",chng_date=sysdate"
                + " where natcode=" + AbSql.getEqualStr(natcode)
                + " and passno=" + AbSql.getEqualStr(passno)
                + " and escapedate=" + AbSql.getEqualStr(escapedate);
        stmt.executeUpdate(qs);
        errMsg = "已經完成通報";
    }
    qnatcode = natcode;
    qpassno = passno;
}

//限制條件
String srch = "";
if (qnatcode.length() > 0) srch += " and natcode = " + AbSql.getEqualStr(qnatcode);
if (qpassno.length() > 0) srch += " and passno = " + AbSql.getEqualStr(qpassno);
if (qvendno.length() > 0) srch += " and vendno = " + AbSql.getEqualStr(qvendno);
if ("on".equals(nocrimedate)) srch += " and (crimedate = '' or crimedate is null)";
if (qcitycode.length() > 0) srch += " and citycode = " + AbSql.getEqualStr(qcitycode);
if (s_qescapedate.length() > 0) srch += " and escapedate >= " + AbSql.getEqualStr(s_qescapedate.replaceAll("-", ""));
if (e_qescapedate.length() > 0) srch += " and escapedate <= " + AbSql.getEqualStr(e_qescapedate.replaceAll("-", ""));
if (s_qapplydate.length() > 0) srch += " and applydate >= " + AbSql.getEqualStr(s_qapplydate.replaceAll("-", ""));
if (e_qapplydate.length() > 0) srch += " and applydate <= " + AbSql.getEqualStr(e_qapplydate.replaceAll("-", ""));
srch += " and (chng_id <> 'D' or chng_id is null)";

if (srch.length() > 0) srch = " where " + srch.substring(4);

if (action.equals("docx") || action.equals("pdf")) {
    if (conn != null) conn.close();
    session.setAttribute( "natcode", qnatcode);
    session.setAttribute( "passno", qpassno);
    session.setAttribute( "vendno", qvendno);
    session.setAttribute( "srch", srch);
    String url = request.getContextPath() + "/reportServlet?reportId=EscNotifyList.docx";
    if (action.equals("pdf")) url += "&converter=PDF_XWPF";
    response.sendRedirect( url );
}

%>

<!DOCTYPE html>
<head>
    <title><%=pageHeader%></title>
    <META http-equiv="X-UA-Compatible" content="IE=EDGE,CHROME=1">

    <script language="javascript" src="<%=appRoot%>/js/My97DatePicker/WdatePicker.js"></script>
    <link rel="stylesheet" type="text/css" href="<%=appRoot%>/resources/css/absys0.css" />

    <script>
        //系統名稱與路徑
        var appTitle = '<%=appTitle%>';
        var appName = '<%=appName%>';
        var appRoot = '<%=appRoot%>';
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
    </script>

</head>

<body class="ab-body" style="border:2px; margin:0px; padding:0px; overflow:auto;">
    <div id="divMenuTitle" class="ab-body">
        <div id="divAppTitle" style="height:30px; margin:0px; padding:0px; background:url(<%=appRoot%>/resources/images/esctoptitle.jpg) repeat-x;"></div>
    </div>

    <center>
    <!--行蹤不明查詢-->
    <form id="frmMain" action="" method=post>
        <div style="margin:0px; padding: 20px 0px 0px 0px;">
            <table class="ab-box03" style="width:650px;">
                <tr>
                    <td class="ab-frmlb1" style="border:0px;" align="left" width="10%">
                        <a class="ab-a2" href="../manual/escsearch.pdf">操作說明</a>
                    </td>
                    <td class="ab-frmlb1" style="border:0px;" align="center" width="90%">
                        <input type="hidden" name="action" value="">
                        <input class="ab-btn00" style="width:70px;" type="button" value="查詢"
                                onclick="this.form.action.value=this.value; this.form.submit();">
                        <input class="ab-btn00" style="width:70px;" type="button" value="重新輸入"
                                onclick="this.form.action.value=this.value; this.form.submit();">
                        <!--
                        <input class="ab-btn00" style="width:70px;" id="" name="" type="button" value="docx"
                                onclick="this.form.action.value=this.value; this.form.submit();">
                        <input class="ab-btn00" style="width:70px;" id="" name="" type="button" value="pdf"
                                onclick="this.form.action.value=this.value; this.form.submit();">
                        -->
                    </td>
                </tr>
            </table>
        </div>

        <div style="margin:0px; padding: 3px 0px 0px 0px;">
            <table class="ab-box03" style="width:650px;">
                <tr>
                    <td class="ab-frmlb1" align="right" width=40%>國籍</td>
                    <td align="left" width=20%>
                        <select class="ab-sel00" style="" name="qnatcode" value="<%=qnatcode%>">
                            <option value=""></option>
                            <%
                            for (int i = 0; i < natcodes.length; i++) {
                            %>
                                    <option value='<%=natcodes[i]%>' <%=(natcodes[i].equals(qnatcode) ? "selected" : "")%>><%=natcodes[i] + "-" + natnames[i]%></option>
                            <%}%>
                        </select>
                    </td>
                    <td class="ab-frmlb1" align="right" width=10%>護照號碼</td>
                    <td align="left" width=35%>
                        <input class="ab-inp00" style="width:80px;" type="text" name="qpassno" value="<%=qpassno%>" maxlength="10" onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="right" >雇主統一編號、身分證號或居留證號</td>
                    <td colspan=1 align="left">
                        <input class="ab-inp00" style="width:80px;" type="text" name="qvendno" value="<%=qvendno%>" maxlength="10" onkeypress="return handleEnter(this, event)">
                    </td>
                    <td class="ab-frmlb1" align="right" width=10%>尚未尋獲</td>
                    <td align="left" width=30%>
                        <input type="checkbox" name="nocrimedate" <%=("on".equals(nocrimedate) ? "checked" : "")%> onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
                <tr>
                    <td align="right" >行蹤不明日期區間</td>
                    <td colspan=3 align="left">
                        <input class="Wdate" style="height:16px; margin:1px; width:90px;" type="text" name="s_qescapedate" value="<%=s_qescapedate%>" onClick="WdatePicker()" onFocus="WdatePicker()" onkeypress="return handleEnter(this, event)">
                        ～
                        <input class="Wdate" style="height:16px; margin:1px; width:90px;" type="text" name="e_qescapedate" value="<%=e_qescapedate%>" onClick="WdatePicker()" onFocus="WdatePicker()" onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
                <tr>
                    <td align="right" >雇主通報日期區間</td>
                    <td colspan=3 align="left">
                        <input class="Wdate" style="height:16px; margin:1px; width:90px;" type="text" name="s_qapplydate" value="<%=s_qapplydate%>" onClick="WdatePicker()" onFocus="WdatePicker()" onkeypress="return handleEnter(this, event)">
                        ～
                        <input class="Wdate" style="height:16px; margin:1px; width:90px;" type="text" name="e_qapplydate" value="<%=e_qapplydate%>" onClick="WdatePicker()" onFocus="WdatePicker()" onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
                <tr>
                    <td align=right>縣市轄區：
                    </td>
                    <td align="left" colspan=3>
                        <select class="ab-sel00" name="qcitycode" value="<%=qcitycode%>">
                            <option value=""></option>
                            <%
                                qs = "SELECT citycode, cityname FROM fpv_citym"
                                    + " WHERE citytype='A'"
                                    + " AND (citycode > '00' AND citycode <= '25')"
                                    + " ORDER BY citycode";
                                rs = stmt.executeQuery(qs);
                                while (rs.next()) {
                                            String citycode = rs.getString("citycode");
                                            String cityname = rs.getString("cityname").substring(0, 3);
                                            cityname = checkCityName(citycode, cityname);
                            %>
                            <option value="<%=citycode%>"  <%=(citycode.equals(qcitycode) ? "selected" : "")%>><%=cityname%></option>
                            <%
                                }
                                rs.close();
                            %>
                        </select>

                    </td>
                </tr>
            </table>
        </div>
    </form>

        <div style="margin:0px; padding: 3px 0px 0px 0px;">
            <table class="ab-box03" style="width:650px;">
                <tr>
                    <td class="ab-frmlbl" align="center" width="100">外勞國籍</td>
                    <td class="ab-frmlbl" align="center" width="100">護照號碼</td>
                    <td class="ab-frmlbl" align="center" width="100">行蹤不明日期</td>
                    <td class="ab-frmlbl" align="center" width="100">雇主通報日期</td>
                    <td class="ab-frmlbl" align="center" width="100">縣市轄區</td>
                    <td class="ab-frmlbl" align="center" width="100">尋獲日</td>
                    <td class="ab-frmlbl" align="center" width="50">　</td>
                </tr>
                <%
                //顯示資料
                qs = "select * from labdyn_escapelab"
                        + srch
                        + " order by escapedate desc, natcode, passno";
                try {
                    rs = stmt.executeQuery(qs);
                    int cnt = 0;
                    while (rs.next() && (cnt < pageRows)) {
                        cnt++;
                        String natcode = AbString.rtrimCheck( rs.getString("natcode") );
                        String passno = AbString.rtrimCheck( rs.getString("passno") );
                        String escapedate = AbString.rtrimCheck( rs.getString("escapedate") );
                        String applydate = AbString.rtrimCheck( rs.getString("applydate") );
                        String citycode = AbString.rtrimCheck( rs.getString("citycode") );
                        String crimedate = AbString.rtrimCheck( rs.getString("crimedate") );
                %>
                <tr>
                    <td align="center"><%=strCheckNullHtml( common.Comm.getCodeTitle(stmt2, natcode, "fpv_natim", "naticode", "natiname") )%></td>
                    <td align="center">
                        <form action="EscDetail.jsp" method=post>
                            <input type="hidden" name="natcode" value="<%=natcode%>">
                            <input type="hidden" name="passno" value="<%=passno%>">
                            <input type="hidden" name="escapedate" value="<%=escapedate%>">
                            <label style="font-size:13px; font-family:Verdana; color:#0066cc;"
                                   onMouseOver="this.style.color='#ff0000'; this.style.cursor='pointer';"
                                   onMouseOut ="this.style.color='#0066cc'; this.style.cursor='default';"
                                   onclick="this.parentElement.submit();"><%=passno%></label>
                        </form>
                    </td>
                    <td align="center"><%=strCheckNullHtml(AbDate.fmtDate(escapedate, "-"))%></td>
                    <td align="center"><%=strCheckNullHtml(AbDate.fmtDate(applydate, "-"))%></td>
                    <td align="center"><%=strCheckNullHtml(common.Comm.getCodeTitle(stmt2, citycode, "fpv_zipcitym", "citycode", "cityname"))%></td>

                    <%
                    if (crimedate.length() == 0) { //尚未尋獲
                    %>
                        <form action="" method=post>
                            <input type="hidden" name="action" value="通報">
                            <input type="hidden" name="natcode" value="<%=natcode%>">
                            <input type="hidden" name="passno" value="<%=passno%>">
                            <input type="hidden" name="escapedate" value="<%=escapedate%>">
                            <td align="center">
                                <!--input class="ab-inp00" style="width:70px;" type=text name="crimedate" value="" maxlength=8 size="8">-->
                                <input class="Wdate" style="height:16px; margin:1px; width:90px;" type="text" name="crimedate" value="" onClick="WdatePicker()" onFocus="WdatePicker()">
                            </td>
                            <td align="center">
                                <input class="ab-btn00" style="width:30px;" id="" type="button" value="通報" onclick="this.form.submit();"/>
                            </td>
                        </form>
                    <%
                    } else  { //已尋獲
                    %>
                        <td align="center"><%=strCheckNullHtml(AbDate.fmtDate(crimedate, "-"))%></td>
                        <td align="center">　</td>
                    <%
                    }
                    %>
                </tr>
                <%
                    }
                    rs.close();
                } catch (Exception e) {}
                %>
            </table>
        </div>

        <br/><br/>

    </center>
</body>
</html>

<%
//關閉連線
stmt.close();
stmt2.close();
if (conn != null) conn.close();
%>


<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
</script>
<%}%>

