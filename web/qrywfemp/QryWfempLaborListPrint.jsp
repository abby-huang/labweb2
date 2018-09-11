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
    <td width=20% align=center>國籍</td>
    <td width=18% align=center>護照號碼</td>
    <td width=44% align=center>英文姓名</td>
    <td width=8% align=center>性別</td>
    <td width=10% align=center>出生日期</td>
</tr>

<%
//顯示資料
//從 tbl_temp 讀取資料
String qs = "select distinct vend_seq,naticode,passno from " + tblengagerec + " m, " + tblcasem + " s";
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
    <td align=center><%=strCheckNullHtml(natiname)%></td>
    <td align=center><%=passno%></td>
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
//stmt.executeUpdate( "drop table tbl_temp" );

//關閉連線
stmt.close();
stmt2.close();
if (con != null) con.close();
%>


</BODY>
</HTML>