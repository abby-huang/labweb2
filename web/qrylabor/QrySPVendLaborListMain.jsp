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
String search = "";
String regno = strCheckNull( request.getParameter("regno") );
if (regno.length() > 0) {
    String searchTitle = "雇主編號【" + regno + "】";

    //限制條件
    search =  " where exists (select * from splab_splabod d where l.lived=d.lived and l.idno=d.idno"
            + " and bywho in ('A','B','D','O','Q')"
            + " and d.regno=" + AbSql.getEqualStr(regno) + ")";

    //建立連線
    Connection con = getConnection( session );
    Statement stmt = con.createStatement();
    ResultSet rs;

    //雇主名稱
    String vendname = "";
    rs = stmt.executeQuery("select cname from labdyn_vend where regno = " + AbSql.getEqualStr(regno));
    if (rs.next()) vendname = strCheckNull( rs.getString(1) ).replaceAll("　+$", "");
    rs.close();
    if (vendname.length() > 0) searchTitle += "、雇主名稱【" + vendname + "】";

    stmt.close();
    con.close();

    session.setAttribute("searchSPLab", search);
    session.setAttribute("searchSPLabTitle", searchTitle);
    response.sendRedirect("QrySPLaborBrief.jsp");
}
%>


<html>
<head>
<%@ include file="/include/HeaderTimeout.inc" %>
</head>

<BODY bgcolor="#F9CD8A">

<%=search%>

<br><br>
查詢條件必須輸入 "雇主編號"，請重新輸入。
<form action="">
<td align=left width=5%>
    <input type=button value="回上一頁" onClick="javascript:history.back()">
</td>
</form>

</BODY>
</HTML>