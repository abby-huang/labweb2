<%@ page errorPage="../ErrorPage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "藍領外國人雇主違法查詢";
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
String searchTitle = strCheckNull((String)session.getAttribute("searchEmpTitle"));

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
    <td width=10% align=center >雇主編號</td>
    <td width=23% align=center >雇　主　名　稱</td>
    <td width=25% align=center >違　法　事　由</td>
    <td width=8% align=center >發生日</td>
    <td width=10% align=center >負責人姓名</td>
    <td width=10% align=center >原處分機關</td>
    <td width=12% align=center >處分來文字號</td>
</tr>

<%
//顯示資料
//從 exprvend 讀取資料
qs = "SELECT " + (sqlFirstCmd.length() > 0 ? sqlFirstCmd + (p*pmax) : "")
            + " m.caseno"
            + ",m.vendname"
            + ",m.reason"
            + ",m.happdate"
            + ",fpv_dyven.dynadesc"
            + ",others_"
            + ",m.fromunit"
            + ",m.fromwpno"
            + " from fpv_exprvend m, fpv_dyven"
            //+ " left join fpv_dyven on (fpv_dyven.dynacode = m.reason)"
            + " " + search
            + " and (fpv_dyven.dynacode = m.reason)"
            + " order by m.caseno";
rs = common.Comm.querySQL(stmt, qs);
for (int i=0; i < ((p-1)*pmax); i++) {
    rs.next();
}
int cnt = 0;
while (rs.next() && (cnt < pmax)) {
    cnt++;

    String others = strCheckNull( rs.getString(6) );
    if (others.length() > 0) others = "，" + others;

    //讀負責人編號姓名
    String regno = strCheckNull( rs.getString(1) );
    if (regno.length() > 10) regno = regno.substring(0, 10);
    String respname = "";
    qs = "select respname from labdyn_vend"
                + " where regno like " + AbSql.getLeadingStr( regno )
                + " order by respname desc";
    ResultSet rs2 = common.Comm.querySQL(stmt2, qs);
    if (rs2.next()) respname = strCheckNull( rs2.getString(1) );
    rs2.close();
%>



<tr>
    <td align=center><%=strCheckNullHtml(regno)%></td>
    <td><%=strCheckNullHtml(rs.getString(2))%></td>
    <td><%=strCheckNullHtml( strCheckNull(rs.getString(5)) + others)%></td>
    <td align=center><%=strCheckNullHtml(rs.getString(4))%></td>
    <td><%=strCheckNullHtml(respname)%></td>
    <td><%=strCheckNullHtml(rs.getString(7))%></td>
    <td><%=strCheckNullHtml(rs.getString(8))%></td>
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