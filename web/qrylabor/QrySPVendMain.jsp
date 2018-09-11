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
String pageHeader = "雙語/廚師雇主查詢";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpblue.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
String errMsg = "";
Connection con = null;

//取得輸入資料
String vendname = strCheckNull( request.getParameter("vendname") ).trim();
String regno = strCheckNull( request.getParameter("regno") ).toUpperCase().trim();

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

Statement stmt = con.createStatement();
ResultSet rs;
String qs;

//限制條件
String search = "";

if (vendname.length() > 0) search += " and vendname like " + AbSql.getLikeStr(vendname);
if (regno.length() > 0) {
    char leading = regno.charAt(0);
    if (Character.isDigit(leading)) {
        if (regno.length() < 8) regno = AbString.leftJustify(regno, 8).trim();
    } else {
        if (regno.length() < 10) regno = AbString.leftJustify(regno, 10).trim();
    }
    search += " and regno like " + AbSql.getLeadingStr(regno);
}
if (search.length() > 0) search = " where " + search.substring(4);

String searchTitle = "";
if (vendname.length() > 0) searchTitle += "、雇主名稱【" + vendname + "】";
if (regno.length() > 0) searchTitle += "、雇主編號【" + regno + "】";
if (searchTitle.length() > 1) searchTitle = searchTitle.substring(1);

if ((vendname.length() > 0) && vendname.length() < 2)
    errMsg = "雇主名稱請輸入 2 個字以上!";

if (errMsg.length() == 0 ) {
    String srchdata = "";
    if (vendname.length() > 0) srchdata = "雇主名稱：" + vendname;
    if (regno.length() > 0) {
        if (srchdata.length() > 0) srchdata += "，";
        srchdata += "雇主編號：" + regno;
    }

    //寫入日誌檔
    common.Comm.logOpData(stmt, userData, "SPVend", srchdata, userAddr);

    //關閉連線
    stmt.close();
    if (con != null) con.close();

    session.setAttribute("searchSPVend", search);
    session.setAttribute("searchSPVendTitle", searchTitle);
    response.sendRedirect("QrySPVendBrief.jsp");
}

%>


<html>
<head>
<%@ include file="/include/HeaderTimeout.inc" %>
</head>

<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
    history.back();
</script>
<%}%>


<BODY bgcolor="#F9CD8A">

<form action="">
<td align=left width=5%>
    <input type=button value="回上一頁" onClick="javascript:history.back()">
</td>
</form>

<%=search%>

<%
//關閉連線
stmt.close();
if (con != null) con.close();
%>


</BODY>
</HTML>