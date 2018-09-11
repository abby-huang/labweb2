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

String pageHeader = "行蹤不明外勞詳細資料";
request.setCharacterEncoding("UTF-8");
//String thisPage = request.getRequestURI();
String thisPage = "EscNotify.jsp";

//定義變數
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

String prepage = filterMetaCharacters( request.getParameter("prepage") );
String natcode = filterMetaCharacters( request.getParameter("natcode") );
String passno = filterMetaCharacters( request.getParameter("passno") );
String escapedate = filterMetaCharacters( request.getParameter("escapedate") );
String engname = "";
String sex = "";
String vendno = "";
String vendname = "";
String vendtel1 = "";
String vendtel2 = "";
String indate = "";
String missplace = "";
String applydate = "";
String citycode = "";
String crimedate = "";

qs = "select * from labdyn_escapelab"
        + " where natcode=" + AbSql.getEqualStr(natcode)
        + " and passno=" + AbSql.getEqualStr(passno)
        + " and escapedate=" + AbSql.getEqualStr(escapedate)
        + " and chng_id <> 'D' order by chng_date desc " ;
rs = common.Comm.querySQL(stmt, qs);
if (rs.next()) {
    engname = AbString.rtrimCheck( rs.getString("engname") );
    sex = AbString.rtrimCheck( rs.getString("sex") );
    vendno = AbString.rtrimCheck( rs.getString("vendno") );
    vendname = AbString.rtrimCheck( rs.getString("vendname") );
    vendtel1 = AbString.rtrimCheck( rs.getString("vendtel1") );
    vendtel2 = AbString.rtrimCheck( rs.getString("vendtel2") );
    indate = AbString.rtrimCheck( rs.getString("indate") );
    missplace = AbString.rtrimCheck( rs.getString("missplace") );
    applydate = AbString.rtrimCheck( rs.getString("applydate") );
    citycode = AbString.rtrimCheck( rs.getString("citycode") );
    crimedate = AbString.rtrimCheck( rs.getString("crimedate") );
}
rs.close();

//String urlReport = request.getContextPath() + "/reportServlet?reportId=EscNotifyApply" //+ "&converter=PDF_XWPF"
//        + "&natcode=" +natcode + "&passno=" + passno + "&escapedate=" + escapedate;
String urlReport = "EscNotifyApplyOdt.jsp?"
        + "natcode=" +natcode + "&passno=" + passno + "&escapedate=" + escapedate;

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
    </script>
</head>

<body class="ab-body" style="border:2px; margin:0px; padding:0px; overflow:auto;">
    <div id="divMenuTitle" class="ab-body">
        <div id="divAppTitle" style="height:30px; padding:0px; background:url(<%=appRoot%>/resources/images/esctoptitle.jpg) repeat-x;"></div>
    </div>

    <center>
    <form id="frmMain" action="" method=post>
        <div style="padding: 20px 0px 0px 0px;">
            <table class="ab-box03" style="width:500px;">
                <tr>
                    <td class="ab-frmlb1" align="center" width="100%">
                        <input type="hidden" name="action" value="">
                        <input class="ab-btn00" style="width:70px;" id="btnQuery" name="" type="button" value="回上一頁"
                                onclick="history.back();">
                        <input class="ab-btn00" style="width:100px;" name="" type="button" value="雇主列印申請書"
                                onclick="window.open('<%=urlReport%>');">
                    </td>
                </tr>
            </table>
        </div>
    </form>

        <div style="padding: 3px 0px 0px 0px;">
            <table class="ab-box03" style="width:500px;">
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%">
                        行蹤不明外勞：
                    </td>
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                        國籍：<%=strCheckNullHtml( common.Comm.getCodeTitle(stmt2, natcode, "fpv_natim", "naticode", "natiname") )%>
                        &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp護照號碼：<%=passno%>
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                        外勞姓名：<%=engname%>
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                        性別：<%=(sex.equals("F") ? "女" : "男")%>
                        &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp入國日期：<%=indate%>
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                        行蹤不明日期：<%=escapedate%>
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                        失聯地點：<%=missplace%>
                    </td>
                </tr>

                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                        雇主通報日期：<%=applydate%>
                        &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp縣市轄區：<%=strCheckNullHtml(common.Comm.getCodeTitle(stmt2, citycode, "fpv_zipcitym", "citycode", "cityname"))%>
                    </td>
                </tr>

                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                        尋獲日：<%=strCheckNullHtml(crimedate)%>
                    </td>
                </tr>

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
                        雇主統一編號、身分證號或居留證號：<%=vendno%>
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                        事業單位（雇主）名稱：<%=vendname%>
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                        聯繫電話：<%=vendtel1%>
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left" width="100%" >
                        行動電話：<%=strCheckNullHtml(vendtel2)%>
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

