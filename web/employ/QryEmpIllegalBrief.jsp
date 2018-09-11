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
ResultSet rs;

//計算筆數
String qs = "select count(*) from fpv_exprvend m " + search;
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
目前暫無資料，請重新輸入查詢條件。
<form action="">
<td align=left width=5%>
    <input type=button value="回上一頁" onClick="javascript:history.back()">
</td>
</form>


<%
//有外勞資料
} else {
%>

<center>

<table border=0 width=900>
    <form action="">
    <td align=left width=5%>
        <input type=button value="回上一頁" onClick="javascript:history.back()">
    </td>
    </form>

    <form action="QryEmpIllegalPrint.jsp" target="_blank">
    <td align=left width=5%>
        <input name=p value=<%=p%> type=hidden>
        <input value="列印此頁" type=submit>
    </td>
    </form>

    <form action="../servlet/QryEmpIllegalText">
    <td align=left width=5%>
        <input value=資料下載 type=submit >
    </td>
    </form>

    <td width=85%>
    </td>
</table>

<table border=0 width=800>
<tr>
  <td width=85>查詢條件：
  </td>
  <td><%=searchTitle%>
  </td>
</tr>
</table>

<!--表頭-->
<table border=0 width=900>
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


<table border = 1 bgcolor=#F8BE67 bordercolor=#FF9900 width=900>
<tr>
    <td width=10% align=center >雇主編號</td>
    <td width=20% align=center >雇主名稱</td>
    <td width=23% align=center >違法事由</td>
    <td width=11% align=center >發生狀況日</td>
    <td width=14% align=center >負責人姓名</td>
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
if (debug) response.getWriter().println(qs + "<BR>");

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
    <td align=center><a HREF="QryEmpIllegalLabor.jsp?regno=<%=regno%>"><%=regno%></a></td>
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