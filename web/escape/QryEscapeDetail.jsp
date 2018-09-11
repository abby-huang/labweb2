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
String pageHeader = "行蹤不明藍領外國人查詢";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();
//尚未登入
if (userId.length() == 0) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
String errMsg = "";
Connection con = null;
Connection con2 = null;

//取得輸入資料
String natcode = strCheckNull( request.getParameter("natcode") );
String passno = strCheckNull( request.getParameter("passno") ).toUpperCase();

//建立連線
con = getConnection( session );
con2 = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
Statement stmt = con.createStatement();
Statement stmt2 = con2.createStatement();
ResultSet rs, rs2;

//從 labom 讀取資料
String laboname = null;
String qs = "select laboname from fpv_labom"
            + " where labono = " + AbSql.getEqualStr(natcode + passno);
rs = common.Comm.querySQL(stmt, qs);
if (rs.next()) laboname = strCheckNull( rs.getString(1) );
rs.close();

//讀取國籍
String natiname = "";
natiname = getNatcodeName( natcode, natcodes, natnames);

//寫入日誌檔
String srchdata = "IP：" + userAddr;
if (natcode.length() > 0) srchdata += "，國籍：" + natiname;
if (passno.length() > 0) srchdata += "，護照號碼：" + passno;

common.Comm.logOpData(stmt, (com.absys.user.Staff)session.getAttribute(appName+"_userData"), "LaborEscape", srchdata, userAddr);

%>



<html>
<head>

<%@ include file="/include/HeaderTimeout.inc" %>
</head>


<BODY bgcolor="#F9CD8A">
<%
//無此外勞資料
if (laboname == null) {
%>

<br><br>
無此外勞資料，請重新輸入查詢條件。
<br><br>
<form action="">
<td align=left width=5%>
    <input type=button value="回上一頁" onClick="javascript:history.back()">
</td>
</form>

<%
//有外勞資料
} else {
%>


<P>
<center><img src="../image/qry_escape.gif" alt="行蹤不明外勞查詢">
<table border=0 width=600>
<tr>
  <td width=35%><font color="#990000">外勞國籍：<%=natiname%></font></td>
  <td width=65%><font color="#990000">護照號碼：<%=passno%></font></td>
</tr>
<tr>
  <td colspan=2><font color="#990000">英文名字：<%=laboname%></font></td>
</tr>　　　
</table>

<table border=1 bgcolor=#F8BE67 bordercolor=#FF9900 width=600>
<tr>
    <!--2010.03.01 取消
    <td width=20% align=center>行蹤不明日期</td>
    -->

    <td width=20% align=center>行蹤不明<br>處分情況</td>

    <!--2007.10.22.編號s961022註消此欄位並增加查獲出國日期
    <td width=20% align=center>居留狀況</td>
    -->

    <td width=20% align=center>行方不明</td>
    <td width=20% align=center>查獲日期</td>
    <td width=20% align=center>查獲出國日期</td>
</tr>

<%
//從 labdyn_resident 讀取資料
qs = "select * from labdyn_resident"
            + " where natcode = " + AbSql.getEqualStr(natcode)
            + " and passno = " + AbSql.getEqualStr(passno)
//            + " and escapedate > '19850101'"
            + " order by chng_date desc";
rs = common.Comm.querySQL(stmt, qs);

if (debug) response.getWriter().println(qs + "<BR>");

//2005.09.26 修改，最後一筆有行蹤不明日期才顯示
//while (rs.next()) {
if (rs.next()) {
    String escapedate = strCheckNull( rs.getString("escapedate") ).trim();
    if (escapedate.equals("19000101")) escapedate = "";
    if (escapedate.length() > 0) {
    //    String escapedate = strCheckNull( rs.getString("escapedate") ).trim();
        String handlecode = strCheckNullHtml( rs.getString("handlecode") ).trim();
        String resstatus = strCheckNull( rs.getString("resstatus") ).trim();
        String misstatus = strCheckNull( rs.getString("misstatus") ).trim();
        String crimedate = strCheckNull( rs.getString("crimedate") ).trim();
        if (crimedate.equals("19000101")) crimedate = "";
        //查獲出國日期 - labinout
        String inoutdate = "";
        String qs2 = "select * from labdyn_labinout where"
                + " natcode = " + AbSql.getEqualStr(natcode)
                + " and passno = " + AbSql.getEqualStr(passno)
                + " and inoutdate is not null"
                + " and kindcode = '2'"
                + " order by inoutdate desc";
        rs2 = common.Comm.querySQL(stmt2, qs2);
if (debug) response.getWriter().println(qs2 + "<BR>");
        if (rs2.next()) {
            inoutdate = strCheckNull( rs2.getString("inoutdate") ).trim();
        }
        rs2.close();

        //居留狀況
        if (resstatus.equals("1")) resstatus = "其它";
        else if (resstatus.equals("2")) resstatus = "在台";
        else if (resstatus.equals("3")) resstatus = "離台";
        else if (resstatus.equals("4")) resstatus = "死亡";
        else if (resstatus.equals("5")) resstatus = "註銷";
        else if (resstatus.equals("6")) resstatus = "其它";
        else resstatus = "";

        //行方不明
        if (misstatus.equals("1")) misstatus = "關係人報案";
        else if (misstatus.equals("2")) misstatus = "警局主動註記";
        else if (misstatus.equals("3")) misstatus = "雇主書面通知";
        else if (misstatus.equals("4")) misstatus = "涉案註記協尋";
        else if (misstatus.equals("5")) misstatus = "服務站主動註記";
        else if (misstatus.equals("6")) misstatus = "專勤隊主動註記";
        else misstatus = "";

        //行蹤不明處理情形
        if (handlecode.equals("31")) handlecode = "行蹤不明";
        else if (handlecode.equals("32")) handlecode = "取消行蹤不明通報";
        else if (handlecode.equals("33")) handlecode = "查獲收容";
        else if (handlecode.equals("34")) handlecode = "取消外勞查獲,收容通報";
        else if (handlecode.equals("35")) handlecode = "查獲收容中,收容費代墊";
        else if (handlecode.equals("36")) handlecode = "取消查獲收容中,收容費代墊通報";
        else if (handlecode.equals("37")) handlecode = "回原雇主,撤銷協尋";
        else handlecode = "";

%>

<tr>
    <!--2010.03.01 取消
    <td align=center><%=escapedate%></td>
    -->

    <td align=center><%=handlecode%></td>

    <!--
    <td align=center><%=resstatus%></td>
    -->

    <td align=center><%=misstatus%></td>
    <td align=center><%=(crimedate.length() > 0) ? crimedate : "&nbsp;"%></td>
    <td align=center><%=((crimedate.length() > 0) && (inoutdate.length() > 0) && (inoutdate.compareTo(crimedate) >= 0)) ? inoutdate : "&nbsp;"%></td>
</tr>


<%
    }
} //完成顯示
rs.close();
%>


</table>

<p>
<font color="#990000">「本畫面有關外勞行蹤不明及出國資料係移民署所提供」</font>

<%
}   //結束有外勞資料


//關閉連線
stmt.close();
stmt2.close();
if (con != null) con.close();
if (con2 != null) con2.close();
%>

</BODY>
</HTML>
