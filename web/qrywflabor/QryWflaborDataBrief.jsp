<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "專業外國人查詢";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpwhite.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//設定此頁
session.setAttribute("briefPage", "QryWflaborDataBrief.jsp");

//定義變數
String errMsg = "";
Connection con = null;
int pmax = 100;

//取得輸入資料
String tblcasem = strCheckNull((String)session.getAttribute("tblcasem"));
String tblengagerec = strCheckNull((String)session.getAttribute("tblengagerec"));
String tblexpirrec = strCheckNull((String)session.getAttribute("tblexpirrec"));
String search = strCheckNull((String)session.getAttribute("searchWflab"));
String searchTitle = strCheckNull((String)session.getAttribute("searchWflabTitle"));

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

//頁數
int p = 1;
try {
    p = Integer.parseInt(request.getParameter("p"));
} catch (Exception e) {
}

Statement stmt = con.createStatement();
Statement stmt2 = con.createStatement();

//計算筆數
String qs = "select count(*) from wcf_laborm l " + search;
if (debug) response.getWriter().println(qs + "<BR>");
ResultSet rs = stmt.executeQuery(qs);
rs.next();
int totItem = rs.getInt(1);
rs.close();

//計算頁數
int ptot = ((totItem-1) / pmax) + 1;

%>


<html>
<head>
<%@ include file="/include/HeaderTimeout.inc" %>
</head>


<BODY bgcolor="#F9CD8A">

<%
//無此專業外國人資料
if (totItem == 0) {
%>

<br><br>
無此專業外國人資料，請重新輸入查詢條件。
<form action="">
<td align=left width=5%>
    <input type=button value="回上一頁" onClick="javascript:history.back()">
</td>
</form>


<%
//有專業外國人資料
} else {
%>

<table border=0 width=100%>
    <form action="">
    <td align=left width=5%>
        <input type=button value="回上一頁" onClick="javascript:history.back()">
    </td>
    </form>

    <form action="QryWflaborDataPrint.jsp" target="_blank">
    <td align=left width=5%>
        <input name=p value=<%=p%> type=hidden>
        <input value="列印此頁" type=submit>
    </td>
    </form>

<!--
    <form action="../servlet/QryWflaborDataText">
    <td align=left width=5%>
        <input value=資料下載 type=submit >
    </td>
    </form>
-->

    <td width=85%>
    </td>
</table>

<table border=0 width=100%>
<tr>
  <td width=85>查詢條件：
  </td>
  <td><%=searchTitle%>
  </td>
</tr>
</table>

<!--表頭-->
<table border=0 width=100%>
    <tr>
        <td width=30% align=left>
            共有 <b><%=totItem%></b> 筆，<b><%=p%>/<%=ptot%></b> 頁
        </td>
        <td align="lefe" width=50%>
<%  //顯示頁數
if (p > ptot) p = ptot;
int p0 = p - 5;
if (p0 < 1) p0 = 1;

if (ptot > 1) {
    if (p > 1) out.print("<a href=\"" + thisPage + "?p=" + (p-1) + "\"><u>上一頁</u></a>");
    for (int i = 0; ((i+p0) <= ptot) && (i < 10); i++) {
        if ((i+p0) == p) {
            out.print("<font color=#ff0000><b>&nbsp;&nbsp;" + (i+p0) + "</b></font>");
        } else {
            out.print("&nbsp;&nbsp;<a href=\"" + thisPage + "?p=" + (i+p0) + "\"><u>" + (i+p0) + "</u></a>");
        }
    }
    if ((p*pmax) < totItem) out.print("&nbsp;&nbsp;<a href=\"" + thisPage + "?p=" + (p+1) + "\"><u>下一頁</u></a>");
}
%>
        </td>
        <td width=20% align=left>
        </td>
    </tr>
</table>


<table border = 1 bgcolor=#F8BE67 bordercolor=#FF9900 width="100%">
<tr>
<td width=10% align=center>國籍</td>
<td width=12% align=center>護照號碼</td>
<td width=13% align=center>統一證號</td>
<td width=20% align=center>英文姓名</td>
<td width=5% align=center>性別</td>
<td width=10% align=center>出生日期</td>
<td width=30% align=center>雇主名稱</td>
</tr>

<%
response.getWriter().flush();

//顯示資料
//從 wcf_laborm 讀取資料
//qs = "SELECT " + (sqlFirstCmd.length() > 0 ? sqlFirstCmd + (p*pmax) : "")
qs = "SELECT "
            + " l.naticode"
            + ",l.passno"
            + ",l.residence_id"
            + ",l.name_eng"
            + ",l.sex"
            + ",l.birthday"
            + " from wcf_laborm l"
            + " " + search
            + " order by l.naticode, l.passno";

rs = stmt.executeQuery(qs);
for (int i=0; i < ((p-1)*pmax); i++) {
    rs.next();
}
int cnt = 0;

while (rs.next() && (cnt < pmax)) {
    cnt++;

    String naticode = strCheckNull(rs.getString(1));
    String passno = strCheckNull(rs.getString(2));
    String residence_id = strCheckNull(rs.getString(3));
    String laboename = strCheckNull(rs.getString(4));
    String labosex = strCheckNull(rs.getString(5));
    if (labosex.equals("M")) labosex = "男";
    else if (labosex.equals("F")) labosex = "女";
    String labobirt = strCheckNull(rs.getString(6));

    //讀取國籍
    String natiname = "";
    qs = "select natiname from fpv_natim where naticode = "
            + AbSql.getEqualStr(naticode);
    ResultSet rs2 = stmt2.executeQuery(qs);
    if (rs2.next()) natiname = strCheckNull(rs2.getString("natiname"));
    rs2.close();

    //聘僱資料
    String vend_seq = "";
    String vend_name_ch = "";
    qs = "select m.disp_date,vend_seq from " + tblengagerec + " m, " + tblcasem + " s "
            + " where m.naticode = " + AbSql.getEqualStr(naticode)
            + " and m.passno = " + AbSql.getEqualStr(passno)
            + " and (s.case_sn = m.case_sn and (s.current_status = '11' or s.current_status = '12'))"
            + " order by m.disp_date desc";
//if (debug) out.println(qs+"</br>");
    rs2 = stmt2.executeQuery(qs);
    if (rs2.next()) vend_seq = strCheckNull(rs2.getString("vend_seq"));
    rs2.close();

    if (vend_seq.length() > 0) {
        qs = "select * from wcf_vendm";
        qs += " where vend_seq = " + AbSql.getEqualStr(vend_seq);
        rs2 = stmt2.executeQuery(qs);
        if (rs2.next()) vend_name_ch = strCheckNull(rs2.getString("vend_name_ch"));
        rs2.close();
    }

%>

<tr>
<td align=><%=strCheckNullHtml(natiname)%></td>
<td align=center><a HREF="QryWflaborDetail.jsp?natcode=<%=naticode%>&passno=<%=passno%>"><%=passno%></a></td>
<td align=center><%=strCheckNullHtml(residence_id)%></td>
<td><%=strCheckNullHtml(laboename)%></td>
<td align=center><%=strCheckNullHtml(labosex)%></td>
<td align=center><%=strCheckNullHtml(labobirt)%></td>
<td align=><%=strCheckNullHtml(vend_name_ch)%></td>
</tr>

<%
}
rs.close();
%>

</table>

<%
}   //結束有專業外國人資料
%>


<%
//關閉連線
stmt.close();
stmt2.close();
if (con != null) con.close();
%>


</BODY>
</HTML>
