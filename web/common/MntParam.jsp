<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ page errorPage="../ErrorPage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "公告欄維護";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpsuper.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

String errMsg = "";
Connection con = null;

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

//執行
String action = strCheckNull(request.getParameter("action"));
String bulletin = strCheckNull(request.getParameter("bulletin"));

Statement stmt = con.createStatement();
if (action.equals("確定")) {
    String qs = "update param set data=" + AbSql.getEqualStr(bulletin)
                + " where id = 'bulletin'";
    common.Comm.updateSQL(stmt, qs);
}

String qs = "select data from param where id = 'bulletin'";
ResultSet rs = common.Comm.querySQL(stmt, qs);
if (rs.next()) bulletin = rs.getString(1).trim();
rs.close();
stmt.close();

%>


<HTML>

<head>
<%@ include file="/include/HeaderTimeout.inc" %>
</head>


<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
</script>
<%}%>

<body bgcolor="#F9CD8A">
<center>
<table width="600" border="0" cellspacing="0" cellpadding="0" >
  <tr>
    <td align=center><img src="../image/mnt_param.gif" alt="公告欄維護" >
    </td>
  </tr>
  <tr>
    <td align=center><img src="../image/line_main.gif" alt="美化圖形" >
    </td>
  </tr>
</table>




<form action="<%=thisPage%>" method=post name="form1">
<table border="1" width=90% bgcolor="#F8BE67" bordercolor="#FF9900">
<tr>
    <td align="right" width=20% >公告內容：</td>
    <td align="left" >
        <input type="text" name="bulletin" maxlength="80" size="60" value="<%=stringToHTMLString(bulletin)%>">
    </td>
</tr>

</table>

<p>
<input type="submit" value="確定" name="action">
</form>


</center>

<%
//關閉連線
if (con != null) con.close();
%>

</body>
</html>
