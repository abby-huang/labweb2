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
//尚未登入
if (userId.length() == 0) {
    response.sendRedirect("../Logout.jsp");
}

String pageHeader = "查詢行蹤不明外勞";
request.setCharacterEncoding("UTF-8");
//String thisPage = request.getRequestURI();
String thisPage = "EscQuery.jsp";

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

String today = AbDate.getToday();

////////////////////////////////////////////////////////////////////////////////
//執行動作
if (action.equals("返回通報外勞頁")) {
    if (conn != null) conn.close();
    response.sendRedirect("EscNotify.jsp");
} else if (action.equals("重新輸入")) {
    qnatcode = "";
    qpassno = "";
    qvendno = "";
} else if (action.equals("刪除")) {
    String rowid = filterMetaCharacters( request.getParameter("rowid") );
    String natcode = filterMetaCharacters( request.getParameter("natcode") );
    String passno = filterMetaCharacters( request.getParameter("passno") ).toUpperCase();
    String escapedate = filterMetaCharacters( request.getParameter("escapedate") ).toUpperCase();
    //qs = "delete from labdyn_escapelab where natcode=" + AbSql.getEqualStr(natcode)
    qs = "update labdyn_escapelab set chng_id='D', chng_date=sysdate"
            + " where rowid=" + AbSql.getEqualStr(rowid);
            //+ " where natcode=" + AbSql.getEqualStr(natcode)
            //+ " and passno=" + AbSql.getEqualStr(passno)
            //+ " and escapedate=" + AbSql.getEqualStr(escapedate);
    stmt.executeUpdate(qs);
}

//限制條件
String srch = "";
if (qnatcode.length() > 0) srch += " and natcode = " + AbSql.getEqualStr(qnatcode);
if (qpassno.length() > 0) srch += " and passno = " + AbSql.getEqualStr(qpassno);
if (qvendno.length() > 0) srch += " and vendno = " + AbSql.getEqualStr(qvendno);
srch += " and (chng_id <> 'D' or chng_id is null)";

if (srch.length() > 0) srch = " where " + srch.substring(4);

%>

<!DOCTYPE html>
<head>
    <title><%=pageHeader%></title>
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
        <!--行蹤不明通報-->
        <form id="frmMain" action="" method=post>
            <div style="padding: 20px 0px 0px 0px;">
                <table class="ab-box03" style="width:650px;">
                    <tr>
                        <td class="ab-frmlb1" style="border:0px;" align="center" width="70%">
                            <input type="hidden" name="action" value="">
                            <input class="ab-btn00" style="width:70px;" id="btnQuery" name="" type="button" value="查詢"
                                    onclick="this.form.action.value=this.value; this.form.submit();">
                            <input class="ab-btn00" style="width:70px;" id="btnQuery" name="" type="button" value="重新輸入"
                                    onclick="this.form.action.value=this.value; this.form.submit();">
                        </td>
                        <td class="ab-frmlb1" style="border:0px;" align="right" width="30%">
                            <input class="ab-btn00" style="width:100px;" id="btnQuery" name="" type="button" value="返回通報外勞頁"
                                    onclick="this.form.action.value=this.value; this.form.submit();">
                        </td>
                    </tr>
                </table>
            </div>

            <div style="padding: 3px 0px 0px 0px;">
                <table class="ab-box03" style="width:650px;">
                    <tr>
                        <td class="ab-frmlb1" align="right" width=40%>國籍</td>
                        <td align="left" width=20%>
                            <select class="ab-sel00" name="qnatcode" value="<%=qnatcode%>">
                                <option value=""></option>
                                <%
                                for (int i = 0; i < natcodes.length; i++) {
                                %>
                                        <option value='<%=natcodes[i]%>' <%=(natcodes[i].equals(qnatcode) ? "selected" : "")%>><%=natcodes[i] + "-" + natnames[i]%></option>
                                <%}%>
                            </select>
                        </td>
                        <td class="ab-frmlb1" align="right" width=10%>護照號碼</td>
                        <td align="left" width=30%>
                            <input class="ab-inp00" style="width:80px;" type="text" name="qpassno" value="<%=qpassno%>" maxlength="10" onkeypress="return handleEnter(this, event)">
                        </td>
                    </tr>
                    <tr>
                        <td class="ab-frmlb1" align="right" >雇主統一編號、身分證號或居留證號</td>
                        <td colspan=3 align="left">
                            <input class="ab-inp00" style="width:80px;" type="text" name="qvendno" value="<%=qvendno%>" maxlength="10" onkeypress="return handleEnter(this, event)">
                        </td>
                    </tr>
                </table>
            </div>
        </form>

        <div style="padding: 3px 0px 0px 0px;">
            <table class="ab-box03" style="width:650px;">
                <tr>
                    <td class="ab-frmlbl" align="center" width="100">外勞國籍</td>
                    <td class="ab-frmlbl" align="center" width="100">護照號碼</td>
                    <td class="ab-frmlbl" align="center" width="100">行蹤不明日期</td>
                    <td class="ab-frmlbl" align="center" width="100">雇主通報日期</td>
                    <td class="ab-frmlbl" align="center" width="100">縣市轄區</td>
                    <td class="ab-frmlbl" align="center" width="100">尋獲日</td>
                    <td class="ab-frmlbl" align="center" width="50"></td>
                </tr>
                <%
                //顯示資料
                int cnt = 0;
                if ((qpassno+qvendno).length() > 0) {
                    qs = "select rowid,labdyn_escapelab.* from labdyn_escapelab"
                            + srch
                            + " order by escapedate desc, natcode, passno";
                    try {
                        rs = stmt.executeQuery(qs);
                        while (rs.next() && (cnt < pageRows)) {
                            cnt++;
                            String rowid = AbString.rtrimCheck( rs.getString("rowid") );
                            String natcode = AbString.rtrimCheck( rs.getString("natcode") );
                            String passno = AbString.rtrimCheck( rs.getString("passno") );
                            String escapedate = AbString.rtrimCheck( rs.getString("escapedate") );
                            String applydate = AbString.rtrimCheck( rs.getString("applydate") );
                            String citycode = AbString.rtrimCheck( rs.getString("citycode") );
                            String crimedate = AbString.rtrimCheck( rs.getString("crimedate") );
                            if (crimedate.length() == 0) {

                            }
                %>
                    <tr>
                        <td align="center"><%=strCheckNullHtml( common.Comm.getCodeTitle(stmt2, natcode, "fpv_natim", "naticode", "natiname") )%></td>
                        <td align="center">
                            <form id="frmMain" action="EscDetail.jsp" method=post>
                                <input type="hidden" name="natcode" value="<%=natcode%>">
                                <input type="hidden" name="passno" value="<%=passno%>">
                                <input type="hidden" name="escapedate" value="<%=escapedate%>">
                                <label style="font-size:13px; font-family:Verdana; color:#0066cc;"
                                       onMouseOver="this.style.color='#ff0000'; this.style.cursor='pointer';"
                                       onMouseOut ="this.style.color='#0066cc'; this.style.cursor='default';"
                                       onclick="this.form.submit();"><%=passno%></label>
                            </form>
                        </td>
                        <td align="center"><%=strCheckNullHtml(AbDate.fmtDate(escapedate, "-"))%></td>
                        <td align="center"><%=strCheckNullHtml(AbDate.fmtDate(applydate, "-"))%></td>
                        <td align="center"><%=strCheckNullHtml(common.Comm.getCodeTitle(stmt2, citycode, "fpv_zipcitym", "citycode", "cityname"))%></td>
                        <td align="center"><%=strCheckNullHtml(AbDate.fmtDate(crimedate, "-"))%></td>
                        <form method=post action="">
                        <td align="center" valign="top">
                            <% if (crimedate.length() == 0) { %>
                            <input type="hidden" name="rowid" value="<%=rowid%>">
                            <input type="hidden" name="natcode" value="<%=natcode%>">
                            <input type="hidden" name="passno" value="<%=passno%>">
                            <input type="hidden" name="escapedate" value="<%=escapedate%>">
                            <input type="hidden" name="qnatcode" value="<%=qnatcode%>">
                            <input type="hidden" name="qpassno" value="<%=qpassno%>">
                            <input type="hidden" name="qvendno" value="<%=qvendno%>">
                            <input type="hidden" name="action" value="">
                            <input class="ab-btn00" style="width:40px;" type="button" value="刪除" name=""
                                   onclick="if (confirm('是否刪除此筆資料？')) {this.form.action.value=this.value; this.form.submit();}">
                            <% } %>
                        </td>
                        </form>
                    </tr>
                <%
                        }
                        rs.close();

                        if (cnt == 0) errMsg = "查無外勞資料！";
                    } catch (Exception e) {}
                }
                %>
            </table>
        </div>
        <div style="padding: 3px 0px 0px 0px;">
            <table class="ab-box03" style="width:500px;">
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                        1.欲刪除已通報之行蹤不明外勞案件時，請先利用查詢功能找出該筆案件，再按畫面中的刪除鍵刪除該筆案件，但已尋獲之案件不提供刪除。<br>
                        2.雇主完成3日內行蹤不明外勞通報案件，且已確實構成曠職3日失去聯繫時，不論事後尋獲與否，可下載並列印「行蹤不明3日通報書表」。將游標移至外勞護照號碼處，點入即可連結至已載入基本資料之「行蹤不明3日通報書表」；若需空白表格，可逕至<a href="<%=appRoot%>/manual/escapply.pdf">「行蹤不明3日通報書表」</a>下載。相關注意事項，請參考該表「填表說明注意事項」填寫相關資料及簽章用印並備齊文件送勞動力發展署辦理。
                    </td>
                </tr>
            </table>
        </div>

        </br></br>

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

