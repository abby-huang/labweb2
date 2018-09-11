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
String pageHeader = "藍領外國人清冊";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpblue.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
String errMsg = "";
Connection con = null;
int pmax = 50;
String labdts_cyyyymmdd = (String)session.getAttribute("labdts_cyyyymmdd");

//取得輸入資料
String OLaborSql = AbString.rtrimCheck((String)session.getAttribute("OLaborSql"));
String OLaborTitle = AbString.rtrimCheck((String)session.getAttribute("OLaborTitle"));
if (OLaborSql.length() == 0) OLaborSql += " where cyyyymmdd = '" + labdts_cyyyymmdd + "'";
else OLaborSql += " and cyyyymmdd = '" + labdts_cyyyymmdd + "'";

//建立連線
con = common.Comm.getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

Statement stmt = con.createStatement();
Statement stmt2 = con.createStatement();
ResultSet rs, rs2;
String qs;


//頁數
int p = 1;
try {
    p = Integer.parseInt(request.getParameter("p"));
} catch (Exception e) {
}
session.setAttribute("debugMsg", thisPage + " - " + OLaborSql);

//計算筆數
qs = "select count(distinct regno || wkadseq) from cognos_labdts l"
    + OLaborSql;
if (debug) out.println(qs + "<br>");
session.setAttribute("debugMsg", thisPage + " - " + qs);

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
查無資料，請重新輸入查詢條件。
<form action="">
    <input type=button value="回上一頁" onClick="javascript:history.back()">
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

    <form action="OLaborVendListPrint.jsp" target="_blank">
    <td align=left width=5%>
        <input name=p value=<%=p%> type=hidden>
        <input value="列印此頁" type=submit>
    </td>
    </form>

    <form action="OLaborVendListCsv.jsp">
    <td align=left width=5%>
        <input value=雇主資料下載 type=submit >
    </td>
    </form>

    <form action="OLaborVendLaborListCsv.jsp">
    <td align=left width=5%>
        <input value=外國人清冊下載 type=submit >
    </td>
    </form>

    <td width=85%>
    </td>
</table>


<table border=0 width=1000>
<tr>
  <td width=85>查詢條件：
  </td>
  <td><%=OLaborTitle%>
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


<table width=1000 border = 1 bgcolor=#F8BE67 bordercolor=#FF9900 style="empty-cells: show;">
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
</tr>

<%
//顯示資料
qs = "select distinct l.regno || l.wkadseq, v.* from cognos_labdts l"
        + " left join labdyn_vend v on v.vendno=l.regno and v.wkadseq=l.wkadseq"
        + OLaborSql
        + " order by l.regno || l.wkadseq";
if (debug) out.println(qs + "<br>");
session.setAttribute("debugMsg", thisPage + " - " + qs);

rs = common.Comm.querySQL(stmt, qs);
for (int i=0; i < ((p-1)*pmax); i++) {
    rs.next();
}
int cnt = 0;
while (rs.next() && (cnt < pmax)) {
    cnt++;
    String regno = AbString.rtrimCheck( rs.getString("vendno") );
    String wkadseq = AbString.rtrimCheck( rs.getString("wkadseq") );
    String cname = AbString.rtrimCheck( rs.getString("cname") );
    String addr = AbString.rtrimCheck( rs.getString("addr") );
    String tel = AbString.rtrimCheck( rs.getString("tel") );
    String zipcode = AbString.rtrimCheck( rs.getString("zipcode") );
    String respname = AbString.rtrimCheck( rs.getString("respname") );

    //計算人數
    int[] labnum = {0, 0, 0, 0, 0, 0, 0};

    qs = "select natcode, count(*) from cognos_labdts where cyyyymmdd = '" + labdts_cyyyymmdd + "'"
            + " and regno = " + AbSql.getEqualStr(regno)
            + " and wkadseq = " + AbSql.getEqualStr(wkadseq)
            + " and type = 'SA'"
            + " group by natcode order by natcode";
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

%>



<tr>
    <td align=center><a HREF="../employ/QryVendLaborListCsv.jsp?regno=<%=regno%>&wkadseq=<%=wkadseq%>">清冊下載</a></td>
    <td align=center><a HREF="../employ/QryVendLaborMain.jsp?regno=<%=regno%>&wkadseq=<%=wkadseq%>"><%=regno%><%=wkadseq%></a></td>
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
</tr>

<%
    out.flush();
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
