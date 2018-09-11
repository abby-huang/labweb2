<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page errorPage="ErrorPage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page import="common.*" %>
<%@ include file="include/ComConstants.inc" %>
<%@ include file="include/ComGetLoginData.inc" %>
<%@ include file="include/ComFunctions.inc" %>

<%
String pageHeader = "主選單";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

String errMsg = "";
Connection con = null;
int counter = 1;

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";


//是否為上班時間
//非假日
String stime = "08:00";
String etime = "19:30";
//一般民眾查詢項目
String xstime = "08:00";
String xetime = "21:00";

String today = AbDate.getTodayYYYYMMDD();
String now = AbDate.getNowTime(":").substring(0, 5);
DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

Statement stmt = con.createStatement();
ResultSet rs;
String qs;

/*
qs = "select * from fpv_holiday where h_date=" + AbSql.getEqualStr(today);
rs = stmt.executeQuery(qs);
if (rs.next()) {
    //假日
    stime = "09:00";
    etime = "17:00";
}
rs.close();

if (userLogin.equals("Y")) {
    //縣市政府登入
    if ( ((now.compareTo(stime) < 0) || (now.compareTo(etime) > 0)) && !userId.equals("G120066663") && !userId.equals("F120539973") ) {
        con.close();
        response.sendRedirect("Logout.jsp");
    }
} else {
    //一般民眾登入
    if ((now.compareTo(xstime) < 0) || (now.compareTo(xetime) > 0)) {
        con.close();
        response.sendRedirect("Logout.jsp");
    }
}
*/

if (errMsg.length() == 0) {
    //讀取計數器
    qs = "select data from param where id = 'counter'";
    rs = Comm.querySQL(stmt, qs);
    if (rs.next()) {
        counter = Integer.parseInt(rs.getString("data").trim()) + 1;
    }
    rs.close();
    if (counter > 1) {
        qs = "update param set data=" + AbSql.getEqualStr( counter + "") + " where id = 'counter'";
    } else {
        qs = "insert into param values('counter', '1')";
    }
    Comm.updateSQL(stmt, qs);
}

//關閉連線
if (stmt != null) stmt.close();
if (con != null) con.close();

%>


<!DOCTYPE html>
<head>
    <META http-equiv="X-UA-Compatible" content="IE=EDGE,CHROME=1">
    <%@ include file="include/Header.inc" %>
    <base target="main">
    <style type="text/css">
        ul{
            margin: 0;
            padding: 0;
        }
        li{
            margin: 0;
            padding: 0;
            display: block;
            height: 25px;
            list-style-type: none;
        }

        .button {
            height: 25px;
            width: 145px;
            margin: 0px;
            padding: 5px 0px 0px 20px;
            font-family: "細明體";
            font-weight: bold;
            font-size: 13px;
            vertical-align: middle;
            letter-spacing: 0;
            text-decoration: none;
            text-shadow: 0 0px 0 #000;
            white-space: nowrap;
            display: inline-block;
            line-height: 1em;
            position: relative;
        }

        .button_2 {
            color: #FFFFFF;
            background: url(resources/images/menubg.gif) no-repeat;
        }

        .button_2:hover {
            color: #F8BE67;
            background: url(resources/images/menubg_hover.gif) no-repeat;
        }

    </style>
</head>

<body bgcolor="#FFFFFF" background="image/bkgd_left.gif" alt="背景圖形" topmargin="0" leftmargin="0" marginwidth="0" marginheight="0">

    <div style="margin-top:30px; padding-left:4px;">
        <ul>
            <%if (userLogin.equals("Y")) {%>
                    <li><a class="button button_2" style="letter-spacing: 0.47em" href="manual/manual.zip">使用手冊下載</a></li>
            <%}%>

            <%if (userLogin.equals("Y") && userOpblue.equals("Y")) {%>
                <%if (userOpdown.equals("Y")) {%>
                    <li><a class="button button_2" style="letter-spacing: 0.23em" href="emplist/QryEmpList.jsp">藍領外國人清冊</a></li>
                    <li><a class="button button_2" style="letter-spacing: 0.15em" href="emplist/OLabor.jsp" target="_blank">藍領外國人清冊新</a></li>
                <%}%>
                    <li><a class="button button_2" style="letter-spacing: -0.1em" href="employ/QryEmp.jsp">藍領外國人雇主查詢</a></li>
                    <li><a class="button button_2" style="letter-spacing: -0.1em" href="employ/QryVend.jsp" target="_blank">藍領外國人雇主查詢新</a></li>
                    <li><a class="button button_2" style="letter-spacing: 0.23em" href="qrylabor/QryLabor.jsp">藍領外國人查詢</a></li>
                    <li><a class="button button_2" style="letter-spacing: -0.03em" href="qrylabor/QrySPLabor.jsp">雙語/廚師人員查詢</a></li>
                <%if (userLogin.equals("Y") && (userId != null) && (modules.hasPrivelege("escnotify", userData.privilege))) {%>
                    <li><a class="button button_2" style="letter-spacing: 0.47em" href="escnotify/EscSearch.jsp" target="_blank">行蹤不明外勞</a></li>
                <%}%>
                    <li><a class="button button_2" style="letter-spacing: 1.5em" href="stat/QryStat.jsp">統計資訊</a></li>
                    <li><a class="button button_2" style="letter-spacing: 0.47em" href="https://agent.wda.gov.tw/agentext/MainMenuExt.jsp" target="_blank">仲介公司查詢</a></li>
            <%}%>

            <!-- 一般民眾查詢 -->
            <%if (!userLogin.equals("Y")) {%>
                    <li><a class="button button_2" style="letter-spacing: -0.1em" href="escape/QryEscape.jsp">藍領外國人行蹤不明</a></li>
                    <li><a class="button button_2" style="letter-spacing: -0.1em" href="dayintw/QryDayintw.jsp">藍領外國人在台天數</a></li>
                    <li><a class="button button_2" style="letter-spacing: 0.05em" href="qrywp065/QryWp065.jsp">主動離境備查查詢</a></li>
                    <li><a class="button button_2" style="letter-spacing: 0.05em" href="https://qry.wda.gov.tw/labweb/qrycase/QryCaseMain.jsp" target="_blank">申辦案件進度查詢</a></li>
                    <li><a class="button button_2" style="letter-spacing: 0.23em" href="http://feeqry.wda.gov.tw/feeweb/login.jsp" target="_blank">就業安定費查詢</a></li>
                    <li><a class="button button_2" style="letter-spacing: 0.47em" href="https://agent.wda.gov.tw/agentext/MainMenuExt.jsp" target="_blank">仲介公司查詢</a></li>
            <%}%>

            <%if (userLogin.equals("Y") && userOpwhite.equals("Y")) {%>
                    <li><a class="button button_2" style="letter-spacing: 0.23em" href="qrywflabor/QryWflabor.jsp">專業外國人查詢</a></li>
                    <li><a class="button button_2" style="letter-spacing: -0.1em" href="qrywfemp/QryWfemp.jsp">專業外國人雇主查詢</a></li>
                <%if (userOpdown.equals("Y")) {%>
                    <li><a class="button button_2" style="letter-spacing: 0.23em" href="qrywfemplist/QryWfempList.jsp">專業外國人清冊</a></li>
                <%} %>
            <%} %>


            <%if (userLogin.equals("Y") && userOpclrtrans.equals("Y")) {%>
                    <li><a class="button button_2" style="letter-spacing: 0.05em" href="clrtransdate/ClrMenu.jsp">下載檔案重傳作業</a></li>
            <%}%>


            <!--
            <%if (userLogin.equals("Y") && (userAuthority.substring(AUNOTIFY_A[0], AUNOTIFY_D[AUNOTIFY_D.length-1]+1).indexOf("1") >= 0)) {%>
                    <li><a class="button button_2" style="letter-spacing: 1.5em" href="labnotify/LabNotify.jsp" target="_blank">通報系統</a></li>
            <%}%>
            -->

            <%if (userLogin.equals("Y") && (userId != null) && (modules.hasPrivelege("outlab", userData.privilege))) {%>
                    <li><a class="button button_2" style="letter-spacing: 0.23em" href="labsys/Enter.jsp?sysid=outlab" target="_top">外展看護工申請</a></li>
            <%}%>

            <%if (userLogin.equals("Y") && userOpsuper.equals("Y") && userDivision.equals(evtaId)) {%>
                    <li><a class="button button_2" style="letter-spacing: 0.23em" href="labsys/Enter.jsp?sysid=mntdivision" target="_top">使用者單位管理</a></li>
            <%}%>

            <%if (userLogin.equals("Y") && userOpsuper.equals("Y")) { %>
                    <li><a class="button button_2" style="letter-spacing: 0.23em" href="labsys/Enter.jsp?sysid=mntstaff" target="_top">使用者帳號管理</a></li>
            <%}%>

            <%if (userLogin.equals("Y") && userData.acckind.equals("01")) { %>
                    <li><a class="button button_2" style="letter-spacing: 1.5em" href="staff/PwdChange.jsp">變更密碼</a></li>
            <%}%>

                    <li><a class="button button_2" style="letter-spacing: 0.84em" href="Logout.jsp">返回主畫面</a></li>
        </ul>
    </div>

    <div style='margin-top:5px; padding-left:12px; font-size:13px; font-family:Arial;'>
        <% if (userOpsuper.equals("Y") && userDivision.equals(evtaId)) { %>
        IP:<%=userAddr%><br>
        上次登入時間:<br><%=(userData.logindate == null) ? "" : df.format(userData.logindate)%><br>
        <% } %>
        瀏覽人數：<%=counter%><br>
        <a href="https://www.wda.gov.tw/News_Content.aspx?n=ABF3F7CEBD3F6243&sms=C243AD1D1D43AEC8&s=10B692A31658C043" target="_blank">外籍工作者申請業務服務電話一覽表</a>
        <br>本系統客服專線：<br>02-8521-9009
    </div>

</body>
</html>

<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
</script>
<%}%>
