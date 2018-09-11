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
int pmax = 50;
String labdts_cyyyymmdd = (String)session.getAttribute("labdts_cyyyymmdd");

//取得輸入資料
String QryLabdtsSql = AbString.rtrimCheck((String)session.getAttribute("QryLabdtsSql"));
String QryLabdtsTitle = AbString.rtrimCheck((String)session.getAttribute("QryLabdtsTitle"));
if (QryLabdtsSql.length() == 0) QryLabdtsSql += " where cyyyymmdd = '" + labdts_cyyyymmdd + "'";
else QryLabdtsSql += " and cyyyymmdd = '" + labdts_cyyyymmdd + "'";

//建立連線
con = common.Comm.getConnection( session );
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
  <td><%=QryLabdtsTitle%>
  </td>
</tr>
</table>

<!--表頭-->
<table border=1 cellspacing=0 width=1000  style="font-size: 13pt; font-family: 標楷體" style="table-layout: fixed;">
<tr>
<td width=5% align=center>國籍</td>
<td width=8% align=center>護照號碼</td>
<td width=10% align=center>英文姓名</td>
<td width=3% align=center>性<br>別</td>
<td width=5% align=center>出生日期</td>
<td width=8% align=center>雇主名稱</td>
<td width=8% align=center>行職業別</td>
<td width=7% align=center>縣市別</td>
<td width=10% align=center>狀態</td>
<td width=10% align=center>仲介名稱</td>
<td width=18% align=center>仲介地址</td>
<td width=8% align=center>仲介<br>電話</td>
</tr>

<%
//顯示資料
//從 laborm 讀取資料
//從 cognos_labdts 讀取資料
qs = "SELECT natcode, passno, agenno, caseno12, emplcode, v.cname from cognos_labdts l "
        + " left join labdyn_vend v on v.vendno=l.regno and v.wkadseq=l.wkadseq"
        + QryLabdtsSql
        + " order by l.regno, l.wkadseq, l.natcode, l.passno";
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

    //從 labdts 讀取 
    laborDetail.agenno = AbString.rtrimCheck( rs.getString("agenno") );
    laborDetail.vendname = AbString.rtrimCheck( rs.getString("cname") );
    laborDetail.caseno12 = AbString.rtrimCheck( rs.getString("caseno12") );
    laborDetail.emplcode = AbString.rtrimCheck( rs.getString("emplcode") );

    laborDetail.getBasic(stmt2);
    laborDetail.getDetailList(stmt2);

%>

<tr>
    <td align=center><%=strCheckNullHtml(laborDetail.nation)%></td>
    <td align=center><%=strCheckNullHtml(laborDetail.passno)%></td>
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
//關閉連線
stmt.close();
stmt2.close();
if (con != null) con.close();
%>


</BODY>
</HTML>
