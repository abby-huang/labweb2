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

//取得輸入資料
String city = strCheckNull( request.getParameter("city") );
String town = strCheckNull( request.getParameter("town") );
String wkaddr = strCheckNull( request.getParameter("wkaddr") );
wkaddr = city + town + wkaddr;
String search = "";

if (wkaddr.length() > 0) {
    //限制條件
    search =  " where wkaddr like " + AbSql.getLeadingStr(wkaddr);
    search += " and conedate >= " +AbSql.getEqualStr( AbDate.getToday() );
    search += " and exists (select * from labdyn_laborm where labdyn_laborm.natcode = labdyn_workprmt.natcode";
    search += " and labdyn_laborm.passno = labdyn_workprmt.passno)";

    //建立連線
    Connection con = getConnection( session );
    Statement stmt = con.createStatement();

    String searchTitle = "工作地址【" + wkaddr + "】";

    //寫入日誌檔
    String srchdata = "工作地址：" + wkaddr;

    common.Comm.logOpData(stmt, userData, "LaborWkaddr", srchdata, userAddr);

    stmt.close();
    con.close();

    session.setAttribute("searchLab", search);
    session.setAttribute("searchLabTitle", searchTitle);
    response.sendRedirect("QryLaborWkaddrBrief.jsp");
}
%>


<html>
<head>
<%@ include file="/include/HeaderTimeout.inc" %>
</head>

<BODY bgcolor="#F9CD8A">

<%=search%>

<br><br>
查詢條件必須輸入 "縣市鄉鎮與地址"，請重新輸入。
<form action="">
<td align=left width=5%>
    <input type=button value="回上一頁" onClick="javascript:history.back()">
</td>
</form>

</BODY>
</HTML>