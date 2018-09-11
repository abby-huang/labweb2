<%@ page errorPage="ErrorPage.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="com.absys.util.*" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "主畫面";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
//if (!userLogin.equals("Y")) {
//    response.sendRedirect("Logout.jsp");
//}

String errMsg = "";
Connection conn = null;

//建立連線
conn = getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
Statement stmt = conn.createStatement();
ResultSet rs;
String qs="";

/*
//問券調查
qs = "select count(*) from survey where id='satisfy' and userid=" + AbSql.getEqualStr(userId);
rs = stmt.executeQuery(qs);
rs.next();
//取消問券調查 2015-03-31
if ((!userId.equals("GUEST")) && (rs.getInt(1) == 0)) survey = true;
rs.close();
*/

//變更密碼
boolean isExpired = false;
if ((userData != null) && userData.acckind.equals("01")) {
    String today = AbDate.getToday();
    String pwddate = AbDate.dateAdd( AbDate.fmtDate(userData.pwddate), 0, 0, 60 );
    if ( today.compareTo(pwddate) >= 0 ) isExpired = true;
}

%>

<!DOCTYPE html>
<head>
    <%@ include file="include/HeaderTimeout.inc" %>
    <%if (isExpired) {%>
    <script language=JavaScript>
        alert('密碼期限已到，請變更密碼');
        window.location = 'staff/PwdChange.jsp';
    </script>
    <%}%>
</head>

<body bgcolor="#F9CD8A">
<div align="center">
  <table width="550" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td>
        <div align="center"><img src="image/logo.jpg" alt="本系統logo"  width="346" height="326"></div>
      </td>
    </tr>
  </table>
</div>
</body>

<%
//關閉連線
stmt.close();
if (conn != null) conn.close();
%>

</html>
