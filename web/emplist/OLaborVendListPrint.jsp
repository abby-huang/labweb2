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
String pageHeader = "藍領外國人雇主依業別、現僱人數、國籍別查詢";
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

%>


<html>
<head>
    <%@ include file="/include/HeaderTimeout.inc" %>
    <script src="<%=appRoot%>/js/RptLandscape.js"></script>
</head>

<body style="COLOR: black; FONT-FAMILY: 標楷體;">

<!-- MeadCo ScriptX -->
<%@ include file="/include/ScriptX.jsp" %>

<center>
<table border=0 width=1000>
<tr>
  <td width=90>查詢條件：
  </td>
  <td><%=OLaborTitle%>
  </td>
</tr>
</table>

<!--表頭-->

<table width=1000 border=1 cellspacing=0 style="font-size: 13pt; font-family: 標楷體" >
<tr>
    <td width=9% align=center>雇主編號</td>
    <td width=14% align=center>雇主名稱</td>
    <td width=22% align=center>地址</td>
    <td width=7% align=center>電話</td>
    <td width=5% align=center>郵遞<br>區號</td>
    <td width=8% align=center>負責人</td>
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
    <td align=center><%=regno+wkadseq%></td>
    <td><%=cname%></td>
    <td><%=addr%></td>
    <td><%=tel%></td>
    <td align=center><%=zipcode%></td>
    <td><%=respname%></td>
    <td align=center><%=labnum[1]%></td>
    <td align=center><%=labnum[3]%></td>
    <td align=center><%=labnum[2]%></td>
    <td align=center><%=labnum[0]%></td>
    <td align=center><%=labnum[4]%></td>
    <td align=center><%=labnum[5]%></td>
    <td align=center><%=labnum[6]%></td>
</tr>

<%
}
%>

</table>

<%

//關閉連線
stmt.close();
stmt2.close();
if (con != null) con.close();
out.flush();
%>

</BODY>
</HTML>