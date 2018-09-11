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

//取得輸入資料
String regno = AbString.rtrimCheck( request.getParameter("regno") );
String wkadseq = AbString.rtrimCheck( request.getParameter("wkadseq") );

String QryLabdtsSql = "";
String QryLabdtsTitle = "";

if (regno.length() > 0) {
    QryLabdtsTitle = "雇主編號【" + regno + wkadseq + "】";

    //限制條件
    QryLabdtsSql =  " where l.regno = " + AbSql.getEqualStr(regno)
            + " and l.wkadseq = " + AbSql.getEqualStr(wkadseq)
            + " and type = 'SA'";

    //建立連線
    Connection con = common.Comm.getConnection( session );
    Statement stmt = con.createStatement();
    ResultSet rs;
    String qs;

    //雇主名稱
    String vendname = "";
    qs = "select cname from labdyn_vend where vendno = " + AbSql.getEqualStr(regno)
            + " and wkadseq = " + AbSql.getEqualStr(wkadseq);
    rs = common.Comm.querySQL(stmt, qs);
    if (rs.next()) vendname = AbString.rtrimCheck( rs.getString("cname") ).replaceAll("　+$", "");
    rs.close();
    if (vendname.length() > 0) QryLabdtsTitle += "、雇主名稱【" + vendname + "】";

    //寫入日誌檔
    //common.Comm.logOpData(stmt, userData, "EmpName", OLaborTitle, userAddr);

    stmt.close();
    con.close();

    session.setAttribute("QryLabdtsSql", QryLabdtsSql);
    session.setAttribute("QryLabdtsTitle", QryLabdtsTitle);
    response.sendRedirect("../qrylabor/QryLabdtsList.jsp");

}
%>


<html>
<head>
<%@ include file="/include/HeaderTimeout.inc" %>
</head>

<BODY bgcolor="#F9CD8A">

<%=QryLabdtsSql%>

<br><br>
必須輸入查詢條件。
<form action="">
<td align=left width=5%>
    <input type=button value="回上一頁" onClick="javascript:history.back()">
</td>
</form>

</BODY>
</HTML>
