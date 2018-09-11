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

//設定此頁
session.setAttribute("briefPage", "QryLaborDataBrief.jsp");

//定義變數
String errMsg = "";
Connection con = null;
int pmax = 100;

//取得輸入資料
String search = strCheckNull((String)session.getAttribute("searchLab"));
String searchTitle = strCheckNull((String)session.getAttribute("searchLabTitle"));

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
String qs = "select count(*) from labdyn_laborm l " + search;
ResultSet rs = common.Comm.querySQL(stmt, qs);
rs.next();
int totItem = rs.getInt(1);
rs.close();


//計算頁數
int ptot = ((totItem-1) / pmax) + 1;

//if (debug) response.getWriter().println(qs + "<BR>");

%>


<html>
<head>
<%@ include file="/include/HeaderTimeout.inc" %>
</head>


<BODY bgcolor="#F9CD8A">

<%
//無此外勞資料
if (totItem == 0) {
%>

<br><br>
無此外勞資料，請重新輸入查詢條件。
<form action="">
<td align=left width=5%>
    <input type=button value="回上一頁" onClick="javascript:history.back()">
</td>
</form>


<%
//有外勞資料
} else {
%>

<table border=0 width=600>
    <form action="">
    <td align=left width=5%>
        <input type=button value="回上一頁" onClick="javascript:history.back()">
    </td>
    </form>

    <form action="QryLaborDataPrint.jsp" target="_blank">
    <td align=left width=5%>
        <input name=p value=<%=p%> type=hidden>
        <input value="列印此頁" type=submit>
    </td>
    </form>

    <form action="../servlet/QryLaborDataText">
    <td align=left width=5%>
        <input value=資料下載 type=submit >
    </td>
    </form>

    <td width=85%>
    </td>
</table>

<table border=0 width=1000>
<tr>
  <td width=85>查詢條件：
  </td>
  <td><%=searchTitle%>
  </td>
</tr>
</table>

<!--表頭-->
<table border=0 width=1000>
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


<table border = 1 bgcolor=#F8BE67 bordercolor=#FF9900 width=1000>
<tr>
<td width=5% align=center>國籍</td>
<td width=8% align=center>護照號碼</td>
<td width=11% align=center>英文姓名</td>
<td width=3% align=center>性<br>別</td>
<td width=5% align=center>出生日期</td>
<td width=8% align=center>雇主名稱</td>
<td width=8% align=center>行職業別</td>
<td width=6% align=center>縣市別</td>
<td width=10% align=center>狀態</td>
<td width=11% align=center>仲介名稱</td>
<td width=19% align=center>仲介地址</td>
<td width=6% align=center>仲介<br>電話</td>
</tr>

<%
response.getWriter().flush();

//顯示資料
//從 laborm 讀取資料
qs = "SELECT " + (sqlFirstCmd.length() > 0 ? sqlFirstCmd + (p*pmax) : "")
            + " l.*"
            + " from labdyn_laborm l "
            + " " + search
            + " order by l.natcode, l.passno";

//if (debug) response.getWriter().println(qs + "<BR>");

rs = common.Comm.querySQL(stmt, qs);
for (int i=0; i < ((p-1)*pmax); i++) {
    rs.next();
}
int cnt = 0;

while (rs.next() && (cnt < pmax)) {
    cnt++;

    String natcode = AbString.rtrimCheck( rs.getString("natcode") );
    String passno = AbString.rtrimCheck( rs.getString("passno") );
    common.LaborDetail laborDetail = new common.LaborDetail(natcode, passno);
    laborDetail.getBasic(rs);
    laborDetail.getDetail(stmt2);

%>

<tr>
    <td align=center><%=strCheckNullHtml(laborDetail.nation)%></td>
    <td align=center><a HREF="QryLaborDetail.jsp?natcode=<%=laborDetail.natcode%>
            &passno=<%=laborDetail.passno%>"><%=strCheckNullHtml(laborDetail.passno)%></a></td>
    <td><%=strCheckNullHtml(laborDetail.engname)%></td>
    <td align=center><%=strCheckNullHtml(laborDetail.sex_desc)%></td>
    <td align=center><%=strCheckNullHtml(laborDetail.birthday)%></td>
    <td><%=strCheckNullHtml(laborDetail.vendname)%></td>
    <td><%=strCheckNullHtml(laborDetail.bizkind_desc)%></td>
    <td><%=strCheckNullHtml(laborDetail.city)%></td>
    <td><%=convertChiSymbol( strCheckNullHtml(laborDetail.lstatus_desc) )%></td>
    <td><%=strCheckNullHtml("(" + laborDetail.agenno + ")" + laborDetail.agenname)%></td>
    <td><%=strCheckNullHtml(laborDetail.agenaddr)%></td>
    <td><%=strCheckNullHtml(laborDetail.agentel)%></td>
</tr>

<%
}
rs.close();
%>

</table>

<%
}   //結束有外勞資料
%>


<%
//關閉連線
stmt.close();
stmt2.close();
if (con != null) con.close();
%>


</BODY>
</HTML>
