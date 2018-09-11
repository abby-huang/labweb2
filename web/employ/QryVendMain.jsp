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
String pageHeader = "藍領外國人雇主個別查詢";
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
String type = AbString.rtrimCheck( request.getParameter("type") );
String vendname = AbString.rtrimCheck( request.getParameter("vendname") ).trim();
String regno = AbString.rtrimCheck( request.getParameter("regno") ).toUpperCase().trim();
String zipcode = AbString.rtrimCheck( request.getParameter("zipcode") );

//建立連線
con = common.Comm.getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

Statement stmt = con.createStatement();
ResultSet rs;
String qs;

//限制條件
String QryVendSql = "";
String logid = "EmpName";

//雇主個別查詢
if (vendname.length() > 0) QryVendSql += " and m.cname like " + AbSql.getLeadingStr(vendname);
if (regno.length() > 0) {
    char leading = regno.charAt(0);
    if (Character.isDigit(leading)) {
        if (regno.length() < 8) regno = AbString.leftJustify(regno, 8).trim();
    } else {
        if (regno.length() < 10) regno = AbString.leftJustify(regno, 10).trim();
    }
    QryVendSql += " and m.regno like " + AbSql.getLeadingStr(regno);
}
if (zipcode.length() > 0) QryVendSql += " and m.zipcode = " + AbSql.getEqualStr(zipcode);
QryVendSql += " and chng_id <> 'D'";

if (QryVendSql.length() > 0) QryVendSql = " where" + QryVendSql.substring(4);

String QryVendTitle = "";
if (zipcode.length() > 0) QryVendTitle += "、郵遞區號【" + zipcode + "】";
if (vendname.length() > 0) QryVendTitle += "、雇主名稱【" + vendname + "】";
if (regno.length() > 0) QryVendTitle += "、雇主編號【" + regno + "】";
if (QryVendTitle.length() > 1) QryVendTitle = QryVendTitle.substring(1);

//檢查郵遞區號
if (zipcode.length() > 0) {
    qs = "select * from fpv_zipcitym"
            + " where zipcode = " + AbSql.getEqualStr(zipcode);
    rs = common.Comm.querySQL(stmt, qs);
    if (!rs.next()) errMsg = "郵遞區號輸入錯誤";
    rs.close();
}

if ((vendname.length() > 0) && vendname.length() < 2)
    errMsg = "雇主名稱請輸入 2 個字以上!";

if (errMsg.length() == 0 ) {

    //寫入日誌檔
//    common.Comm.logOpData(stmt, userData, logid, QryVendTitle, userAddr);

    //關閉連線
    stmt.close();
    if (con != null) con.close();

    session.setAttribute("QryVendSql", QryVendSql);
    session.setAttribute("QryVendTitle", QryVendTitle);
    response.sendRedirect("QryVendList.jsp");
}

%>


<html>
<head>
<%@ include file="/include/HeaderTimeout.inc" %>
</head>

<BODY bgcolor="#F9CD8A">

<form action="">
    <input type=button value="回上一頁" onClick="javascript:history.back()">
</form>

<%=QryVendSql%>

<%
//關閉連線
stmt.close();
if (con != null) con.close();
%>


</BODY>
</HTML>