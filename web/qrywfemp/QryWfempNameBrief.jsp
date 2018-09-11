<!--%@ page errorPage="../ErrorPage.jsp" %-->
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "專業外國人雇主資料查詢";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpwhite.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
String errMsg = "";
Connection con = null;
int pmax = 100;

//取得輸入資料
String tblcasem = strCheckNull((String)session.getAttribute("tblcasem"));
String tblengagerec = strCheckNull((String)session.getAttribute("tblengagerec"));
String tblexpirrec = strCheckNull((String)session.getAttribute("tblexpirrec"));
String search = strCheckNull((String)session.getAttribute("searchWfemp"));
String searchTitle = strCheckNull((String)session.getAttribute("searchWfempTitle"));

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

String qs;
ResultSet rs, rs2;

//計算筆數
qs = "select count(distinct s2.vend_seq) from " + search;
rs = common.Comm.querySQL(stmt, qs);
rs.next();
int totItem = rs.getInt(1);
rs.close();

//if (debug) response.getWriter().println(qs + "<BR>");

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
無此雇主資料，請重新輸入查詢條件。
<form action="">
<td align=left width=5%>
    <input type=button value="回上一頁" onClick="javascript:history.back()">
</td>
</form>


<%
//有專業外國人資料
} else {
%>

<table border=0 width=1000>
    <form action="">
    <td align=left width=5%>
        <input type=button value="回上一頁" onClick="javascript:history.back()">
    </td>
    </form>

    <form action="QryWfempNamePrint.jsp" target="_blank">
    <td align=left width=5%>
        <input name=p value=<%=p%> type=hidden>
        <input value="列印此頁" type=submit>
    </td>
    </form>

    <form action="../servlet/QryWfempListText">
    <td align=left width=5%>
        <input value=雇主資料下載 type=submit >
    </td>
    </form>

    <form action="../servlet/QryWfempListAllText">
    <td align=left width=5%>
        <input value=外國人有效清冊下載 type=submit >
    </td>
    </form>

    <form action="../servlet/QryWfempListAllText">
    <td align=left width=5%>
        <input name="all" value="Y" type=hidden>
        <input value=外國人所有清冊下載 type=submit >
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
<!--    <td width=8% align=center>聘雇專業外國人<br>清冊</td> -->
    <td width=10% align=center>雇主編號</td>
    <td width=25% align=center>公司名稱</td>
    <td width=35% align=center>地　　址</td>
    <td width=10% align=center>電話</td>
    <td width=10% align=center>負責人</td>
    <td width=5% align=center>有效人數</td>
    <td width=5% align=center>所有人數</td>
</tr>

<%
//顯示資料
//從 tbl_temp 讀取資料
//qs = "SELECT " + (sqlFirstCmd.length() > 0 ? sqlFirstCmd + (p*pmax) : "")
qs = "SELECT "
    + " vend_seq"
    + " from tbl_temp "
    + " order by vend_seq";

qs = "select distinct s2.vend_seq from " + search;
rs = common.Comm.querySQL(stmt, qs);
for (int i=0; i < ((p-1)*pmax); i++) {
    rs.next();
}
int cnt = 0;
while (rs.next() && (cnt < pmax)) {
    cnt++;
    String regno = strCheckNull( rs.getString(1) );

    //讀雇主資料
    qs = "SELECT"
                + " vend_id"
                + ",vend_seq"
                + ",vend_name_ch"
                + ",vend_addr"
                + ",vend_tel"
                + ",vend_zone"
                + ",vend_chairman"
                + " from wcf_vendm m";
    qs += " where vend_seq = " + AbSql.getEqualStr(regno);
    qs +=  " order by vend_seq";
if (debug) session.setAttribute("debugMsg", qs);
    rs2 = stmt2.executeQuery(qs);
    rs2.next();
    String vend_name_ch = strCheckNull( rs2.getString("vend_name_ch") );
    String vend_addr = strCheckNull( rs2.getString("vend_addr") );
    String vend_tel = strCheckNull( rs2.getString("vend_tel") );
    String vend_zone = strCheckNull( rs2.getString("vend_zone") );
    String vend_chairman = strCheckNull( rs2.getString("vend_chairman") );
    rs2.close();

    //計算有效人數
    int labnum = 0;
    qs = "select count(*) from (select distinct vend_seq, naticode,passno from " + tblengagerec + " m, " + tblcasem + " s"
        + " where s.vend_seq = " + AbSql.getEqualStr( regno )
        + " and work_edate > " + AbSql.getEqualStr( AbDate.getToday() )
        + " and (s.case_sn = m.case_sn and (s.current_status = '11' or s.current_status = '12'))"
        + " )";
        //+ " into TEMP tbl_temp2 with no log";
if (debug) session.setAttribute("debugMsg", qs);
    //stmt2.executeUpdate(qs);
    //rs2 = stmt2.executeQuery( "select count(*) from tbl_temp2" );
    rs2 = stmt2.executeQuery( qs );
    rs2.next();
    labnum = rs2.getInt(1);
    rs2.close();
    //stmt2.executeUpdate( "drop table tbl_temp2" );

    //計算所有人數
    int labnum2 = 0;
    qs = "select count(*) from (select distinct vend_seq,naticode,passno from " + tblengagerec + " m, " + tblcasem + " s"
        + " where (s.case_sn = m.case_sn and (s.current_status = '11' or s.current_status = '12'))"
        + " and s.vend_seq = " + AbSql.getEqualStr( regno )
        + " )";
        //+ " into TEMP tbl_temp2 with no log";
//if (debug) out.println(qs+"</br>");
    //stmt2.executeUpdate(qs);
    //rs2 = stmt2.executeQuery( "select count(*) from tbl_temp2" );
    rs2 = stmt2.executeQuery( qs );
    rs2.next();
    labnum2 = rs2.getInt(1);
    rs2.close();
    //stmt2.executeUpdate( "drop table tbl_temp2" );
%>



<tr>
<!--    <td align=center><a HREF="../servlet/QryWfempLaborDownText?regno=<%=regno%>">清冊下載</a></td> -->
    <td align=center><%=regno%></td>
    <td><%=strCheckNullHtml(vend_name_ch.replaceAll("　+$", ""))%></td>
    <td><%=strCheckNullHtml(vend_addr.replaceAll("　+$", ""))%></td>
    <td><%=strCheckNullHtml(vend_tel)%></td>
    <td><%=strCheckNullHtml(vend_chairman.replaceAll("　+$", ""))%></td>
    <td align=center><a HREF="QryWfempLaborList.jsp?regno=<%=regno%>"><%=labnum%></a></td>
    <td align=center><a HREF="QryWfempLaborList.jsp?regno=<%=regno%>&all=Y"><%=labnum2%></a></td>
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
//stmt.executeUpdate( "drop table tbl_temp" );

//關閉連線
stmt.close();
stmt2.close();
if (con != null) con.close();
%>


</BODY>
</HTML>