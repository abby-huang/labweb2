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
String pageHeader = "專業外國人查詢";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpwhite.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//設定此頁
session.setAttribute("briefPage", "QryLaborDataBrief.jsp");

//定義變數
String errMsg = "";
Connection con = null;
int pmax = 100;

//取得輸入資料
String tblcasem = strCheckNull((String)session.getAttribute("tblcasem"));
String tblengagerec = strCheckNull((String)session.getAttribute("tblengagerec"));
String tblexpirrec = strCheckNull((String)session.getAttribute("tblexpirrec"));
String search = strCheckNull((String)session.getAttribute("searchWflab"));
String searchTitle = strCheckNull((String)session.getAttribute("searchWflabTitle"));

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
<table border=1 cellspacing=0 width=1000  style="font-size: 13pt; font-family: 標楷體">
<tr>
<td width=10% align=center>國籍</td>
<td width=12% align=center>護照號碼</td>
<td width=13% align=center>統一證號</td>
<td width=20% align=center>英文姓名</td>
<td width=5% align=center>性別</td>
<td width=10% align=center>出生日期</td>
<td width=30% align=center>雇主名稱</td>
</tr>

<%
//顯示資料
//從 wcf_vendm 讀取資料
//qs = "SELECT " + (sqlFirstCmd.length() > 0 ? sqlFirstCmd + (p*pmax) : "")
qs = "SELECT "
            + " l.naticode"
            + ",l.passno"
            + ",l.residence_id"
            + ",l.name_eng"
            + ",l.sex"
            + ",l.birthday"
            + " from wcf_laborm l"
            + " " + search
            + " order by l.naticode, l.passno";

rs = stmt.executeQuery(qs);
for (int i=0; i < ((p-1)*pmax); i++) {
    rs.next();
}
int cnt = 0;
while (rs.next() && (cnt < pmax)) {
    cnt++;

    String naticode = strCheckNull(rs.getString(1));
    String passno = strCheckNull(rs.getString(2));
    String residence_id = strCheckNull(rs.getString(3));
    String laboename = strCheckNull(rs.getString(4));
    String labosex = strCheckNull(rs.getString(5));
    if (labosex.equals("M")) labosex = "男";
    else if (labosex.equals("F")) labosex = "女";
    String labobirt = strCheckNull(rs.getString(6));

    //讀取國籍
    String natiname = "";
    qs = "select natiname from fpv_natim where naticode = "
            + AbSql.getEqualStr(naticode);
    ResultSet rs2 = stmt2.executeQuery(qs);
    if (rs2.next()) natiname = strCheckNull(rs2.getString("natiname"));
    rs2.close();

    //聘僱資料
    String vend_seq = "";
    String vend_name_ch = "";
    qs = "select m.disp_date,vend_seq from " + tblengagerec + " m, " + tblcasem + " s "
            + " where m.naticode = " + AbSql.getEqualStr(naticode)
            + " and m.passno = " + AbSql.getEqualStr(passno)
            + " and (s.case_sn = m.case_sn and (s.current_status = '11' or s.current_status = '12'))"
            + " order by m.disp_date desc";
    rs2 = stmt2.executeQuery(qs);
    if (rs2.next()) vend_seq = strCheckNull(rs2.getString("vend_seq"));
    rs2.close();

    if (vend_seq.length() > 0) {
        qs = "select * from wcf_vendm";
        qs += " where vend_seq = " + AbSql.getEqualStr(vend_seq);
        rs2 = stmt2.executeQuery(qs);
        if (rs2.next()) vend_name_ch = strCheckNull(rs2.getString("vend_name_ch"));
        rs2.close();
    }

%>

<tr>
<td align=><%=strCheckNullHtml(natiname)%></td>
<td align=center><%=passno%></td>
<td align=center><%=strCheckNullHtml(residence_id)%></td>
<td><%=strCheckNullHtml(laboename)%></td>
<td align=center><%=strCheckNullHtml(labosex)%></td>
<td align=center><%=strCheckNullHtml(labobirt)%></td>
<td align=><%=strCheckNullHtml(vend_name_ch)%></td>

</td>
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
