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
int pmax = 100;

//取得輸入資料
String keylistFileId = strCheckNull((String)session.getAttribute("keylistFileId"));
String search = strCheckNull((String)session.getAttribute("searchEmp"));
String searchTitle = strCheckNull((String)session.getAttribute("searchEmpTitle"));
String searchBiz = strCheckNull((String)session.getAttribute("searchEmpBiz"));
String searchLab = strCheckNull((String)session.getAttribute("searchEmpLab"));
String searchStatus = strCheckNull((String)session.getAttribute("searchStatus"));
String bizTitle = strCheckNull((String)session.getAttribute("empBizTitle"));
String natcode = strCheckNull((String)session.getAttribute("empNatcode"));
String bizseq = strCheckNull((String)session.getAttribute("empBizseq"));
String citycode = strCheckNull((String)session.getAttribute("empCitycode"));

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

Statement stmt = con.createStatement();
Statement stmt2 = con.createStatement();
stmt.setQueryTimeout(60*timeout);
stmt2.setQueryTimeout(60*timeout);

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
<table border=0 width=1000>
<tr>
  <td width=90>查詢條件：
  </td>
  <td><%=searchTitle%>
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
    <td width=10% align=center>職業別</td>
    <td width=4% align=center>菲律<br>賓</td>
    <td width=4% align=center>泰<br>國</td>
    <td width=4% align=center>馬來<br>西亞</td>
    <td width=4% align=center>印<br>尼</td>
    <td width=4% align=center>越<br>南</td>
    <td width=4% align=center>蒙<br>古</td>
</tr>

<%
//顯示資料
//讀取資料
ArrayList<String> keys = null;
keys = readKeys(keylistFileId);
int totItem = keys.size();
int cnt = 0;
int start = ((p-1)*pmax);
while (((start+cnt) < totItem) && (cnt < pmax)) {
    cnt++;
    String regno = keys.get(start+cnt-1);

    //讀雇主資料
    qs = "SELECT "
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

    rs2.next();
    String cname = strCheckNull( rs2.getString(2) );
    String addr = strCheckNull( rs2.getString(3) );
    String tel = strCheckNull( rs2.getString(4) );
    String zipcode = strCheckNull( rs2.getString(5) );
    String respname = strCheckNull( rs2.getString(6) );

    //計算人數
    int[] labnum = {0, 0, 0, 0, 0, 0};
    qs = "select natcode, count(*) from labdyn_laborm l"
        + " where regno = " + AbSql.getEqualStr( regno );
    if (searchLab.length() > 0) qs += " and " + searchLab;
    qs += " group by natcode";

    rs2 = common.Comm.querySQL(stmt2, qs);
    while (rs2.next()) {
        String natcode2 = rs2.getString(1);
        for (int i = 0; i < natcodes.length; i++) {
            if ( natcode2.equals(natcodes[i]) ) {
                labnum[i] += rs2.getInt(2);
                break;
            }
        }
    }
    rs2.close();

%>



<tr>
    <td align=center><%=regno%></td>
    <td><%=cname%></td>
    <td><%=addr%></td>
    <td><%=tel%></td>
    <td align=center><%=zipcode%></td>
    <td><%=respname%></td>
    <td><%=bizTitle%></td>
    <td align=center><%=labnum[1]%></td>
    <td align=center><%=labnum[3]%></td>
    <td align=center><%=labnum[2]%></td>
    <td align=center><%=labnum[0]%></td>
    <td align=center><%=labnum[4]%></td>
    <td align=center><%=labnum[5]%></td>
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