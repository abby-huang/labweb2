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
String pageHeader = "藍領外國人主動離境備查案查詢";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();
//尚未登入
if (userId.length() == 0) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
String errMsg = "";
Connection conn = null;

//取得輸入資料
String natcode = AbString.rtrimCheck( request.getParameter("natcode") );
String passno = AbString.rtrimCheck( request.getParameter("passno") ).toUpperCase();

//建立連線
conn = getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
Statement stmt = conn.createStatement();
ResultSet rs;

/*
//從 fpv.wp065 讀取資料
查詢條件：
國籍，護照號碼  wp065.labono

select * from fpv_wp065 where labono='輸入值'
取outwpdate最近一筆
且 wp065.outwpdate + 60天 > 系統日
且retuwpinno為空值
符合條件時才顯示

*/
//從 fpv_wp065 讀取資料
String today = AbDate.getToday();
String inwpno = "";
String outwpdate = "";
String qs = "select * from fpv_wp065"
        + " where labono = " + AbSql.getEqualStr(natcode + passno)
        + " and outwpdate >= " + AbSql.getEqualStr( AbDate.dateAdd(today, 0, 0, -60) )
        + " and retuwpinno is null";
rs = stmt.executeQuery(qs);
if (rs.next()) {
    inwpno = AbString.rtrimCheck( rs.getString("inwpno") );
    outwpdate = AbString.rtrimCheck( rs.getString("outwpdate") );
} else {
    inwpno = "查無資料";
    outwpdate = "查無資料";
}
rs.close();


//讀取國籍
String natiname = "";
natiname = getNatcodeName( natcode, natcodes, natnames);

//寫入日誌檔
String srchdata = "IP：" + userAddr;
if (natcode.length() > 0) srchdata += "，國籍：" + natiname;
if (passno.length() > 0) srchdata += "，護照號碼：" + passno;

common.Comm.logOpData(stmt, (com.absys.user.Staff)session.getAttribute(appName+"_userData"), "LaborWp065", srchdata, userAddr);

%>



<html>
<head>

<%@ include file="/include/HeaderTimeout.inc" %>
</head>


<BODY bgcolor="#F9CD8A">

<center>
<img src="../image/qry_wp065.gif" alt="藍領外國人主動離境備查案查詢">

<p>
<form action="">
    <input type=button value="回上一頁" onClick="javascript:history.back()">
</form>

<table border=0 width=600>
    <tr>
        <td width=35%><font color="#990000">外勞國籍：<%=natiname%></font></td>
        <td width=65%><font color="#990000">護照號碼：<%=passno%></font></td>
    </tr>
    <tr>
        <td width=35%><font color="#990000">收文文號：<%=inwpno%></font></td>
        <td width=65%><font color="#990000">發文日期：<%=outwpdate%></font></td>
    </tr>
</table>

<table border=0 width=600>
    <tr align=left>
        <td colspan=6><font color="#990000">
        <td valign=top><font color="#990000">★★</td>
        <td><font color="#990000"><b>為保護個人資料及資訊安全考量，僅限查詢案件發文後60日內之案件，超過時間則不開放查詢。</b></font></td>
    </tr>
    <tr align=left>
        <td colspan=6><font color="#990000">
        <td valign=top><font color="#990000">★★</td>
        <td><font color="#990000"><b>主動離境備查如有疑義或相關問題，可洽詢勞動部電話服務中心(02)8995-6000，提供相關諮詢服務。</b></font></td>
    </tr>

</table>

<%

//關閉連線
stmt.close();
if (conn != null) conn.close();
%>

</center>
</BODY>
</HTML>
