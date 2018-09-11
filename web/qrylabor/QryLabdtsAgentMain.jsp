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
String pageHeader = "藍領外國人查詢";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpblue.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//建立連線
Connection con = common.Comm.getConnection( session );
Statement stmt = con.createStatement();

//取得輸入資料
String agenno = AbString.rtrimCheck( request.getParameter("agenno") );

String QryLabdtsSql = "";
String QryLabdtsTitle = "";

QryLabdtsTitle = "仲介代碼【" + agenno + "】";

//限制條件
QryLabdtsSql =  " where l.agenno = " + AbSql.getEqualStr(agenno);

//寫入日誌檔
//common.Comm.logOpData(stmt, userData, "EmpAgent", QryLabdtsTitle, userAddr);

//關閉連線
stmt.close();
if (con != null) con.close();

session.setAttribute("QryLabdtsSql", QryLabdtsSql);
session.setAttribute("QryLabdtsTitle", QryLabdtsTitle);
response.sendRedirect("../qrylabor/QryLabdtsList.jsp");

%>


<html>
<head>
<%@ include file="/include/HeaderTimeout.inc" %>
</head>

<BODY bgcolor="#F9CD8A">

<%=QryLabdtsSql%>

<br><br>
查詢條件必須輸入。
<form action="">
<td align=left width=5%>
    <input type=button value="回上一頁" onClick="javascript:history.back()">
</td>
</form>

</BODY>
</HTML>
