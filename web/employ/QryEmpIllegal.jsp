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
String pageHeader = "藍領外國人雇主違法查詢";
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
String vendname = strCheckNull( request.getParameter("vendname") );
String regno = strCheckNull( request.getParameter("regno") ).toUpperCase();
String startdate = strCheckNull( request.getParameter("startdate") );
String enddate = strCheckNull( request.getParameter("enddate") );

//限制條件
String search = " where (m.cancel_ <> 'Y' or m.cancel_ is null)";
if (vendname.length() > 0) search += " and m.vendname like " + AbSql.getLeadingStr(vendname);
if (regno.length() > 0) {
    char leading = regno.charAt(0);
    if (Character.isDigit(leading)) {
        if (regno.length() < 8) regno = AbString.leftJustify(regno, 8);
    } else {
        if (regno.length() < 10) regno = AbString.leftJustify(regno, 10);
    }
    search += " and m.caseno like " + AbSql.getLeadingStr(regno);
}
if (startdate.length() > 0) search += " and m.happdate >= " + AbSql.getEqualStr(startdate);
if (enddate.length() > 0) search += " and m.happdate <= " + AbSql.getEqualStr(enddate);


String searchTitle = "";
if (vendname.length() > 0) searchTitle += "雇主名稱【" + vendname + "】";
if (regno.length() > 0) {
    if (searchTitle.length() > 0) searchTitle += "、";
    searchTitle += "雇主編號【" + regno + "】";
}
if ((startdate.length() > 0) || (enddate.length() > 0)) {
    searchTitle += "日期區間【";
    if (startdate.length() > 0) searchTitle += startdate;
    searchTitle += "～";
    if (enddate.length() > 0) searchTitle += enddate;
    searchTitle += "】";
}

if ((vendname.length() > 0) && vendname.length() < 2)
    errMsg = "雇主名稱請輸入 2 個字以上!";


if (errMsg.length() == 0 ) {
    //建立連線
    con = getConnection( session );
    if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
    Statement stmt = con.createStatement();

    String srchdata = "";
    if (vendname.length() > 0) srchdata = "雇主名稱：" + vendname;
    if (regno.length() > 0) {
        if (srchdata.length() > 0) srchdata += "，";
        srchdata += "雇主編號：" + regno;
    }

    //寫入日誌檔
    common.Comm.logOpData(stmt, userData, "EmpIllegal", srchdata, userAddr);

    //關閉連線
    stmt.close();
    if (con != null) con.close();

    session.setAttribute("searchEmp", search);
    session.setAttribute("searchEmpTitle", searchTitle);
    response.sendRedirect("QryEmpIllegalBrief.jsp");
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

<%=search%>
<form action="">
<td align=left width=5%>
    <input type=button value="回上一頁" onClick="javascript:history.back()">
</td>
</form>

</BODY>
</HTML>