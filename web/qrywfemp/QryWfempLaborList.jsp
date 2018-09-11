<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "雇主僱用專業外國人清冊";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpwhite.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

int pmax = 100;

//取得輸入資料
String tblcasem = strCheckNull((String)session.getAttribute("tblcasem"));
String tblengagerec = strCheckNull((String)session.getAttribute("tblengagerec"));
String tblexpirrec = strCheckNull((String)session.getAttribute("tblexpirrec"));
String regno = strCheckNull( request.getParameter("regno") );
String all = strCheckNull( request.getParameter("all") );

//沒有雇主編號
if (regno.length() == 0) {
    response.sendRedirect("../MainManager.jsp");
}

String search = "";
String searchTitle = "";
searchTitle = "雇主編號【" + regno + "】";

//建立連線
Connection con = getConnection( session );
Statement stmt = con.createStatement();
Statement stmt2 = con.createStatement();
ResultSet rs, rs2;

//雇主名稱
String vendname = "";
rs = stmt.executeQuery("select vend_name_ch from wcf_vendm where vend_seq = " + AbSql.getEqualStr(regno));
if (rs.next()) vendname = strCheckNull( rs.getString(1) ).replaceAll("　+$", "");
rs.close();
if (vendname.length() > 0) searchTitle += "、雇主名稱【" + vendname + "】";

//頁數
int p = 1;
try {
    p = Integer.parseInt(request.getParameter("p"));
} catch (Exception e) {
}

//計算筆數
/*
String qs = "select distinct vend_seq,naticode,passno from wcf_engagerec m"
    + " left join wcf_casem s on (s.case_sn = m.case_sn)";
if (!all.equals("Y"))
    qs += " and work_edate > " + AbSql.getEqualStr( AbDate.getToday() );
qs += " where s.vend_seq = " + AbSql.getEqualStr( regno )
    + " into TEMP tbl_temp with no log";
*/
String qs = "select count(*) from ( select distinct vend_seq,naticode,passno from " + tblengagerec + " m, " + tblcasem + " s";
qs += " where s.vend_seq = " + AbSql.getEqualStr( regno );
if (!all.equals("Y")) {
    qs += " and work_edate > " + AbSql.getEqualStr( AbDate.getToday() );
}
qs += " and (s.case_sn = m.case_sn and (s.current_status = '11' or s.current_status = '12')) )";

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
//無此專業外國人資料
if (totItem == 0) {
%>

<br><br>
此雇主沒有僱用專業外國人資料。
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

    <form action="QryWfempLaborListPrint.jsp" target="_blank">
    <td align=left width=5%>
        <input name=p value=<%=p%> type=hidden>
        <input name=regno value=<%=regno%> type=hidden>
        <input name=all value="<%=all%>" type=hidden>
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
    if (p > 1) out.print("<a href=\"" + thisPage + "?regno=" + regno + "&all=" + all + "&p=" + (p-1) + "\"><u>上一頁</u></a>");
    for (int i = 0; ((i+p0) <= ptot) && (i < 10); i++) {
        if ((i+p0) == p) {
            out.print("<font color=#ff0000><b>&nbsp;&nbsp;" + (i+p0) + "</b></font>");
        } else {
            out.print("&nbsp;&nbsp;<a href=\"" + thisPage + "?regno=" + regno + "&all=" + all + "&p=" + (i+p0) + "\"><u>" + (i+p0) + "</u></a>");
        }
    }
    if ((p*pmax) < totItem) out.print("&nbsp;&nbsp;<a href=\"" + thisPage + "?regno=" + regno + "&all=" + all +  "&p=" + (p+1) + "\"><u>下一頁</u></a>");
}
%>
        </td>
        <td width=20% align=left>
        </td>
    </tr>
</table>


<table border = 1 bgcolor=#F8BE67 bordercolor=#FF9900 width="100%">
<tr>
    <td width=20% align=center>國籍</td>
    <td width=18% align=center>護照號碼</td>
    <td width=44% align=center>英文姓名</td>
    <td width=8% align=center>性別</td>
    <td width=10% align=center>出生日期</td>
</tr>

<%
response.getWriter().flush();

//顯示資料
//從 tbl_temp 讀取資料
qs = "SELECT " + (sqlFirstCmd.length() > 0 ? sqlFirstCmd + (p*pmax) : "")
    + " vend_seq,naticode,passno"
    + " from tbl_temp "
    + " order by vend_seq,naticode,passno";

//response.getWriter().println(qs + "<BR>");
qs = "select distinct vend_seq,naticode,passno from " + tblengagerec + " m, " + tblcasem + " s";
qs += " where s.vend_seq = " + AbSql.getEqualStr( regno );
if (!all.equals("Y"))
    qs += " and work_edate > " + AbSql.getEqualStr( AbDate.getToday() );
qs += " and (s.case_sn = m.case_sn and (s.current_status = '11' or s.current_status = '12'))";
qs += " order by vend_seq,naticode,passno";

rs = stmt.executeQuery(qs);
for (int i=0; i < ((p-1)*pmax); i++) {
    rs.next();
}
int cnt = 0;

while (rs.next() && (cnt < pmax)) {
    cnt++;

    String naticode = strCheckNull(rs.getString("naticode"));
    String passno = strCheckNull(rs.getString("passno"));
    String laboename = "";
    String labosex = "";
    String labobirt = "";

    //從 wcf_laborm 讀取資料
    qs = "SELECT"
            + " naticode"
            + ",passno"
            + ",name_eng"
            + ",sex"
            + ",birthday"
            + " from wcf_laborm"
            + " where naticode = " + AbSql.getEqualStr(naticode)
            + " and passno = " + AbSql.getEqualStr(passno);

    rs2 = stmt2.executeQuery(qs);
    if (rs2.next()) {
        laboename = strCheckNull(rs2.getString(3));
        labosex = strCheckNull(rs2.getString(4));
        if (labosex.equals("M")) labosex = "男";
        else if (labosex.equals("F")) labosex = "女";
        labobirt = strCheckNull(rs2.getString(5));
    }
    rs2.close();

    //讀取國籍
    String natiname = "";
    qs = "select natiname from fpv_natim where naticode = "
            + AbSql.getEqualStr(naticode);
    rs2 = stmt2.executeQuery(qs);
    if (rs2.next()) natiname = rs2.getString("natiname");
    rs2.close();

%>

<tr>
    <td align=><%=strCheckNullHtml(natiname)%></td>
    <td align=center><a HREF="../qrywflabor/QryWflaborDetail.jsp?natcode=<%=naticode%>
            &passno=<%=passno%>"><%=passno%></a></td>
    <td><%=strCheckNullHtml(laboename)%></td>
    <td align=center><%=strCheckNullHtml(labosex)%></td>
    <td align=center><%=strCheckNullHtml(labobirt)%></td>
</tr>

<%
}
rs.close();
%>

</table>


<%
}//結束有專業外國人資料

//stmt.executeUpdate( "drop table tbl_temp" );
%>

<%
//關閉連線
stmt.close();
stmt2.close();
if (con != null) con.close();
%>

</BODY>
</HTML>