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


String qs;
ResultSet rs;
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
<table border=0 width=1000 style="font-size: 13pt; font-family: 標楷體">
<tr>
  <td width=90>查詢條件：
  </td>
  <td><%=searchTitle%>
  </td>
</tr>
</table>

<!--表頭-->
<table border=1 cellspacing=0 width=1000 style="font-size: 13pt; font-family: 標楷體">
<tr>
    <td width=9% align=center>雇主編號</td>
    <td width=13% align=center>雇主名稱</td>
    <td width=27% align=center>地　　址</td>
    <td width=8% align=center>電話</td>
    <td width=5% align=center>郵遞<br>區號</td>
    <td width=8% align=center>負責人</td>
    <td width=5% align=center>菲律<br>賓</td>
    <td width=5% align=center>泰<br>國</td>
    <td width=5% align=center>馬來<br>西亞</td>
    <td width=5% align=center>印<br>尼</td>
    <td width=5% align=center>越<br>南</td>
    <td width=5% align=center>蒙<br>古</td>
</tr>

<%
//顯示資料
//從 vend 讀取資料
qs = "select " + (sqlFirstCmd.length() > 0 ? sqlFirstCmd + (p*pmax) : "")
        + "distinct m.regno from labdyn_vend m "
        + search
        + " order by m.regno";
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
    int[] labnum = {0, 0, 0, 0, 0, 0};

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
                break;
            }
        }
    }
    rs2.close();
%>



<tr>
    <td align=center><%=rs.getString(1)%></td>
    <td><%=strCheckNullHtml(cname).replaceAll("　+$", "")%></td>
    <td><%=strCheckNullHtml(addr).replaceAll("　+$", "")%></td>
    <td><%=strCheckNullHtml(tel).trim()%></td>
    <td align=center><%=strCheckNullHtml(zipcode).trim()%></td>
    <td><%=strCheckNullHtml(respname).replaceAll("　+$", "")%></td>
    <td align=center><%=labnum[1]%></td>
    <td align=center><%=labnum[3]%></td>
    <td align=center><%=labnum[2]%></td>
    <td align=center><%=labnum[0]%></td>
    <td align=center><%=labnum[4]%></td>
    <td align=center><%=labnum[5]%></td>
</tr>

<%
}
rs.close();
%>

</table>

<%

//關閉連線
stmt.close();
stmt2.close();
if (con != null) con.close();
%>


</BODY>
</HTML>