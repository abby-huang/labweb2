<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "雙語/廚師人員查詢 - 簡列";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入 
if (!userLogin.equals("Y") || !userOpblue.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
String errMsg = "";
Connection con = null;
int pmax = 100;

//取得輸入資料
String search = strCheckNull((String)session.getAttribute("searchSPVend"));
String searchTitle = strCheckNull((String)session.getAttribute("searchSPVendTitle"));

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

Statement stmt = con.createStatement();
Statement stmt2 = con.createStatement();

//頁數
int p = 1;
try {
    p = Integer.parseInt(request.getParameter("p"));
} catch (Exception e) {
}
session.setAttribute("debugMsg", thisPage + " - " + search);

String qs;
ResultSet rs;

//計算筆數
qs = "select count(distinct regno) from splab_spvendm "
    + search;
rs = stmt.executeQuery( qs );
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
//無此外勞資料
if (totItem == 0) {
%>

<br><br>
無此雇主資料，請重新輸入查詢條件。
<form action="">
<td align=left width=5%>
    <input type=button value="回上一頁" onClick="javascript:history.back()">
</td>
</form>


<%
//有外勞資料
} else {
%>

<table border=0 width=1000>
    <form action="">
    <td align=left width=5%>
        <input type=button value="回上一頁" onClick="javascript:history.back()">
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
        <td align="left" width=50%>
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


<table width=1000 border = 1 bgcolor=#F8BE67 bordercolor=#FF9900 >
<tr>
    <td width=10% align=center>雇主編號</td>
    <td width=25% align=center>公司名稱</td>
    <td width=35% align=center>地　　址</td>
    <td width=15% align=center>電話</td>
    <td width=5% align=center>郵遞<br>區號</td>
    <td width=10% align=center>負責人</td>
</tr>

<%
//顯示資料
qs = "select distinct regno from splab_spvendm "
        + search
        + " order by regno";

session.setAttribute("debugMsg", thisPage + " - " + qs);
rs = stmt.executeQuery(qs);
for (int i=0; i < ((p-1)*pmax); i++) {
    rs.next();
}
int cnt = 0;
while (rs.next() && (cnt < pmax)) {
    cnt++;
    String regno = strCheckNull( rs.getString(1) );

    //改為 fpv_vendm - 20100330
    //讀雇主資料
    qs = "SELECT * from splab_spvendm"
                + " where regno = " + AbSql.getEqualStr(regno)
                + " order by regno, wkadseq desc";
    ResultSet rs2 = stmt2.executeQuery(qs);
    String vendname = "";
    String respname = "";
    String vendaddr = "";
    String vendtel = "";
    String postno = "";
    if (rs2.next()) {
        vendname = AbString.rtrimCheck(rs2.getString("vendname"));
        respname = AbString.rtrimCheck(rs2.getString("respname"));
        vendaddr = AbString.rtrimCheck(rs2.getString("vendaddr"));
        vendtel = AbString.rtrimCheck(rs2.getString("vendtel"));
        postno = AbString.rtrimCheck(rs2.getString("postno"));
    }
    rs2.close();

%>

<tr>
    <td align=center><a HREF="QrySPVendLaborListMain.jsp?regno=<%=regno%>"><%=regno%></a></td>
    <td><%=strCheckNullHtml(vendname)%></td>
    <td><%=strCheckNullHtml(vendaddr)%></td>
    <td><%=strCheckNullHtml(vendtel)%></td>
    <td align=center><%=strCheckNullHtml(postno)%></td>
    <td><%=strCheckNullHtml(respname)%></td>
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