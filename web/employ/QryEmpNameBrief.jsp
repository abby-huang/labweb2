<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
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
int pmax = 100;

//取得輸入資料
String type = strCheckNull( request.getParameter("type") );
String search = strCheckNull((String)session.getAttribute("searchEmp"));
String searchLab = strCheckNull((String)session.getAttribute("searchEmpLab"));
String searchTitle = strCheckNull((String)session.getAttribute("searchEmpTitle"));
String citycode = strCheckNull((String)session.getAttribute("empCitycode"));

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
/*
    qs = "select distinct m.regno from labdyn_vend m "
        + search
        + " order by m.regno"
        + " into TEMP tbl_temp with no log";
*/
qs = "select count(distinct m.regno) from labdyn_vend m "
    + search;
    //+ " order by m.regno";
session.setAttribute("debugMsg", qs);

rs = common.Comm.querySQL(stmt, qs);
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

    <form action="QryEmpNamePrint.jsp" target="_blank">
    <td align=left width=5%>
        <input name=p value=<%=p%> type=hidden>
        <input value="列印此頁" type=submit>
    </td>
    </form>

    <form action="../servlet/QryEmpNameText">
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
    <td width=8% align=center>聘雇外勞<br>清冊</td>
    <td width=10% align=center>雇主編號</td>
    <td width=12% align=center>公司名稱</td>
    <td width=20% align=center>地　　址</td>
    <td width=7% align=center>電話</td>
    <td width=4% align=center>郵遞<br>區號</td>
    <td width=7% align=center>負責人</td>
    <td width=4% align=center>菲律<br>賓</td>
    <td width=4% align=center>泰<br>國</td>
    <td width=4% align=center>馬來<br>西亞</td>
    <td width=4% align=center>印<br>尼</td>
    <td width=4% align=center>越<br>南</td>
    <td width=4% align=center>蒙<br>古</td>
    <td width=4% align=center>總人數</td>
    <td width=8% align=center>附加案/5級制外勞人數</td>
</tr>

<%
//顯示資料
qs = "select " + (sqlFirstCmd.length() > 0 ? sqlFirstCmd + (p*pmax) : "")
        + "distinct m.regno from labdyn_vend m "
        + search
        + " order by m.regno";

if (debug) response.getWriter().println("SQL:" + search + "<BR>");
if (debug) response.getWriter().println("searchLab:" + searchLab + "<BR>");
session.setAttribute("debugMsg", thisPage + " - " + qs);
rs = common.Comm.querySQL(stmt, qs);
for (int i=0; i < ((p-1)*pmax); i++) {
    rs.next();
}
int cnt = 0;
while (rs.next() && (cnt < pmax)) {
    cnt++;
    String regno = strCheckNull( rs.getString(1) );

    //改為 fpv_vendm - 20100330
    //讀雇主資料
    qs = "SELECT"
                + " regno"
                + ",cname"
                + ",addr"
                + ",tel"
                + ",zipcode"
                + ",respname"
                + ",wkadseq"
                + " from labdyn_vend"
                + " where regno = " + AbSql.getEqualStr(regno)
                + " and chng_id <> 'D'"
                + " order by regno, wkadseq desc";
    ResultSet rs2 = common.Comm.querySQL(stmt2, qs);
    String cname = "";
    String addr = "";
    String tel = "";
    String zipcode = "";
    String respname = "";
    if (rs2.next()) {
        cname = strCheckNull( rs2.getString(2) );
        addr = strCheckNull( rs2.getString(3) );
        tel = strCheckNull( rs2.getString(4) );
        zipcode = strCheckNull( rs2.getString(5) );
        respname = strCheckNull( rs2.getString(6) );
    }
    rs2.close();

    //計算人數
    int[] labnum = {0, 0, 0, 0, 0, 0, 0};

    qs = "select natcode, count(*) from labdyn_laborm l"
        + " where regno = " + AbSql.getEqualStr( regno );
    if (searchLab.length() > 0) qs += " and " + searchLab;
    qs += " group by natcode";
    rs2 = common.Comm.querySQL(stmt2, qs);
    while (rs2.next()) {
        String natcode = rs2.getString(1);
        int tot = rs2.getInt(2);
        for (int i = 0; i < natcodes.length; i++) {
            if ( natcode.equals(natcodes[i]) ) {
                labnum[i] += tot;
                labnum[6] += tot;
                break;
            }
        }
    }
    rs2.close();

    String StatiUrl = "&nbsp;";
    if (regno.matches("[0-9].*")) StatiUrl = "<a HREF='QryEmpLaborStati.jsp?regno=" + regno + "'>附加案/5級制外勞人數</a>";
%>



<tr>
    <td align=center><a HREF="../servlet/QryEmpLaborDownText?regno=<%=regno%>&citycode=<%=citycode%>">清冊下載</a></td>
    <td align=center><a HREF="QryEmpLaborList.jsp?regno=<%=regno%>"><%=regno%></a></td>
    <td><%=strCheckNullHtml(cname.replaceAll("　+$", ""))%></td>
    <td><%=strCheckNullHtml(addr.replaceAll("　+$", ""))%></td>
    <td><%=strCheckNullHtml(tel)%></td>
    <td align=center><%=strCheckNullHtml(zipcode)%></td>
    <td><%=strCheckNullHtml(respname.replaceAll("　+$", ""))%></td>
    <td align=center><%=labnum[1]%></td>
    <td align=center><%=labnum[3]%></td>
    <td align=center><%=labnum[2]%></td>
    <td align=center><%=labnum[0]%></td>
    <td align=center><%=labnum[4]%></td>
    <td align=center><%=labnum[5]%></td>
    <td align=center><%=labnum[6]%></td>
    <td align=center><%=StatiUrl%></td>
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