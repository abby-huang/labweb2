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
String regno = strCheckNull( request.getParameter("regno") );
String bizseq = strCheckNull( request.getParameter("bizseq") );
String natcode = strCheckNull( request.getParameter("natcode") );
String citycode = strCheckNull( request.getParameter("citycode") );

String searchBiz = strCheckNull((String)session.getAttribute("searchEmpBiz"));
String searchLab = strCheckNull((String)session.getAttribute("searchEmpLab"));


String search = "";
String searchTitle = "";
if (regno.length() > 0) {
    searchTitle = "雇主編號【" + regno + "】";

    //限制條件
    search =  " where l.regno = " + AbSql.getEqualStr(regno);

    //建立連線
    Connection con = getConnection( session );
try {
    Statement stmt = con.createStatement();
    ResultSet rs;
    String qs;

    //雇主名稱
    String vendname = "";
    qs = "select cname from labdyn_vend where regno = " + AbSql.getEqualStr(regno);
    rs = common.Comm.querySQL(stmt, qs);
    if (rs.next()) vendname = strCheckNull( rs.getString(1) ).replaceAll("　+$", "");
    rs.close();
    if (vendname.length() > 0) searchTitle += "、雇主名稱【" + vendname + "】";

    //讀取國籍
    String natiname = "";
    if (natcode.length() > 0) {
        natiname = getNatcodeName(natcode, natcodes, natnames);
        search += " and l.natcode = " + AbSql.getEqualStr(natcode);
        searchTitle += "、國籍【" + natiname + "】";
    }

    //縣市轄區
    String citytitle = "";
    if (citycode.length() > 0) {
        qs = "select cityname from fpv_citym"
                + " where citytype='A' and citycode = " + AbSql.getEqualStr(citycode);
        rs = common.Comm.querySQL(stmt, qs);
        if (rs.next()) citytitle = strCheckNull( rs.getString(1) ).trim().replaceAll("　+$", "");
        rs.close();

//        search += " and l.citycode in " + cityCodeToSql( citycode );
        searchTitle += "、縣市轄區【" + citytitle + "】";
    }

    //行職業別
//    String searchBiz = "";
    if (bizseq.length() > 0) {
        int ibiz = Integer.parseInt(bizseq);
        searchTitle += "、行職業別【" + bizkinds[ibiz] + "】";

        ibiz = Integer.parseInt(bizseq);
        if (ibiz == 0)
            searchBiz = " and l.casekind not in " + bizCodeToSql( bizcodes[ibiz] );
        else
            searchBiz = " and l.casekind in " + bizCodeToSql( bizcodes[ibiz] );
//        search += searchBiz;
    }

//    search += searchBiz + searchStatus;

    stmt.close();
} finally {
    con.close();
}

    searchLab =  " where l.regno = " + AbSql.getEqualStr(regno)
            + " and " + searchLab;
    session.setAttribute("searchLab", searchLab);
    session.setAttribute("searchLabTitle", searchTitle);
    response.sendRedirect("../qrylabor/QryLaborDataBrief.jsp");



}
%>


<html>
<head>
<%@ include file="/include/HeaderTimeout.inc" %>
</head>

<BODY bgcolor="#F9CD8A">

<%=searchLab%>

<br><br>
查詢條件必須輸入 "雇主編號"，請重新輸入。
<form action="">
<td align=left width=5%>
    <input type=button value="回上一頁" onClick="javascript:history.back()">
</td>
</form>

</BODY>
</HTML>