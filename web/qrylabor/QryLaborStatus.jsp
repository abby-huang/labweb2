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
String natcode = filterMetaCharacters( request.getParameter("natcode") );
String citycode = filterMetaCharacters( request.getParameter("citycode") );
String startdate = filterMetaCharacters( request.getParameter("startdate") );
String enddate = filterMetaCharacters( request.getParameter("enddate") );
String bizseq = filterMetaCharacters( request.getParameter("bizseq") );
String condition = filterMetaCharacters( request.getParameter("condition") );


//建立連線
Connection con = getConnection( session );
Statement stmt = con.createStatement();

//讀取國籍
String natiname = "";
if (natcode.length() > 0) {
    natiname = getNatcodeName(natcode, natcodes, natnames);
}

//縣市轄區
String citytitle = "";
if (citycode.length() > 0) {
    String qs = "select cityname from fpv_citym"
            + " where citytype='A' and citycode = " + AbSql.getEqualStr(citycode);
    ResultSet rs = stmt.executeQuery(qs);
    if (rs.next()) citytitle = strCheckNull( rs.getString(1) ).trim().replaceAll("　+$", "");
    rs.close();
}


String search = "";
String searchTitle = "";

searchTitle = "、日期區間【" + startdate + "~" + enddate + "】";
if (natcode.length() > 0) searchTitle += "、國籍【" + natiname + "】";
if (citycode.length() > 0) searchTitle += "、縣市轄區【" + citytitle + "】";

String biztitle = "";
if (bizseq.length() > 0) {
    int i = Integer.parseInt(bizseq);
    biztitle = bizkinds[i];
    searchTitle += "、行職業別【" + bizkinds[i] + "】";
}



/////////////////////////////////////////////////////////
//健檢不合格
if (condition.equals("1")) {
    //限制條件
    search = " where f.event_date >= " + AbSql.getEqualStr(startdate)
                    + " and f.event_date <= " + AbSql.getEqualStr(enddate)
                    + " and f.inform_type in ('41', '23')";
    if (natcode.length() > 0) search += " and f.natcode = " + AbSql.getEqualStr(natcode);
    search += " and exists (select * from labdyn_laborm m"
            + " where m.natcode = f.natcode and m.passno = f.passno";
    if (citycode.length() > 0 )
        search += " and m.citycode in " + cityCodeToSql( citycode );
    search += " and m.chng_id <> 'D'";
    search += ")";

    //寫入日誌檔
    String srchdata = "【健檢不合格】";
    srchdata += "，發生區間：" + startdate + "~" + enddate;
    if (natcode.length() > 0) srchdata += "，國籍：" + natiname;
    if (citycode.length() > 0) srchdata += "，縣市轄區：" + citytitle;

    common.Comm.logOpData(stmt, userData, "LaborStatus", srchdata, userAddr);

    stmt.close();
    con.close();

    searchTitle = "【健檢不合格】" + searchTitle;
    session.setAttribute("searchLab", search);
    session.setAttribute("searchLabTitle", searchTitle);
    response.sendRedirect("QryLaborStatusBrief.jsp");


/////////////////////////////////////////////////////////
//遣返
} else if (condition.equals("2")) {
    //限制條件
    search = " where f.event_date >= " + AbSql.getEqualStr(startdate)
                    + " and f.event_date <= " + AbSql.getEqualStr(enddate)
                    + " and f.inform_type = '37'";
    if (natcode.length() > 0) search += " and f.natcode = " + AbSql.getEqualStr(natcode);
    search += " and exists (select * from labdyn_laborm m"
            + " where m.natcode = f.natcode and m.passno = f.passno";
    if (citycode.length() > 0 )
        search += " and m.citycode in " + cityCodeToSql( citycode );
    search += " and m.chng_id <> 'D'";
    search += ")";

    //寫入日誌檔
    String srchdata = "【遣返】";
    srchdata += "，發生區間：" + startdate + "~" + enddate;
    if (natcode.length() > 0) srchdata += "，國籍：" + natiname;
    if (citycode.length() > 0) srchdata += "，縣市轄區：" + citytitle;

    common.Comm.logOpData(stmt, userData, "LaborStatus", srchdata, userAddr);

    stmt.close();
    con.close();

    searchTitle = "【遣返】" + searchTitle;
    session.setAttribute("searchLab", search);
    session.setAttribute("searchsearchLabTitle", searchTitle);
    response.sendRedirect("QryLaborStatusBrief.jsp");


/////////////////////////////////////////////////////////
//最近入境日期
} else if (condition.equals("3")) {
    //限制條件
    search = " where l.findate >= " + AbSql.getEqualStr(startdate)
                    + " and l.findate <= " + AbSql.getEqualStr(enddate);
    if (natcode.length() > 0) search += " and l.natcode = " + AbSql.getEqualStr(natcode);
    if (citycode.length() > 0 ) search += " and l.citycode in " + cityCodeToSql( citycode );
    search += " and l.chng_id <> 'D'";

    //寫入日誌檔
    String srchdata = "【最近入境日期】";
    srchdata += "，發生區間：" + startdate + "~" + enddate;
    if (natcode.length() > 0) srchdata += "，國籍：" + natiname;
    if (citycode.length() > 0) srchdata += "，縣市轄區：" + citytitle;

    common.Comm.logOpData(stmt, userData, "LaborStatus", srchdata, userAddr);

    stmt.close();
    con.close();

    searchTitle = "【最近入境日期】" + searchTitle;
    session.setAttribute("searchLab", search);
    session.setAttribute("searchLabTitle", searchTitle);
    response.sendRedirect("QryLaborDataBrief.jsp");


/////////////////////////////////////////////////////////
//最近聘雇起始日期
} else if (condition.equals("4")) {
    //限制條件
    search = " where l.wkprmtdate >= " + AbSql.getEqualStr(startdate)
                    + " and l.wkprmtdate <= " + AbSql.getEqualStr(enddate);
    if (natcode.length() > 0) search += " and l.natcode = " + AbSql.getEqualStr(natcode);
    if (citycode.length() > 0 ) search += " and l.citycode in " + cityCodeToSql( citycode );
    search += " and l.chng_id <> 'D'";

    //寫入日誌檔
    String srchdata = "【最近聘雇起始日期】";
    srchdata += "，發生區間：" + startdate + "~" + enddate;
    if (natcode.length() > 0) srchdata += "，國籍：" + natiname;
    if (citycode.length() > 0) srchdata += "，縣市轄區：" + citytitle;

    common.Comm.logOpData(stmt, userData, "LaborStatus", srchdata, userAddr);

    stmt.close();
    con.close();

    searchTitle = "【最近聘雇起始日期】" + searchTitle;
    session.setAttribute("searchLab", search);
    session.setAttribute("searchLabTitle", searchTitle);
    response.sendRedirect("QryLaborDataBrief.jsp");


/////////////////////////////////////////////////////////
//行蹤不明外勞清單
} else if (condition.equals("5")) {
    //限制條件
    search = " where f.escapedate >= " + AbSql.getEqualStr(startdate)
                    + " and f.escapedate <= " + AbSql.getEqualStr(enddate);
//    if (natcode.length() > 0) search += " and f.natcode = " + AbSql.getEqualStr(natcode);
    search += " and exists (select * from labdyn_laborm m"
            + " where m.natcode = f.natcode and m.passno = f.passno";
    if (natcode.length() > 0) search += " and m.natcode = " + AbSql.getEqualStr(natcode);
    if (citycode.length() > 0 )
        search += " and m.citycode in " + cityCodeToSql( citycode );
    if (bizseq.length() > 0 ) {
        int i = Integer.parseInt(bizseq);
        if (i == 0)
            search += " and m.casekind not in " + bizCodeToSql( bizcodes[i] );
        else
            search += " and m.casekind in " + bizCodeToSql( bizcodes[i] );
    }
    search += " and m.chng_id <> 'D'";
    search += ")";

    //寫入日誌檔
    String srchdata = "行蹤不明日期：" + startdate + "~" + enddate;
    if (natcode.length() > 0) srchdata += "，國籍：" + natiname;
    if (bizseq.length() > 0) srchdata += "，行職業別：" + biztitle;
    if (citycode.length() > 0) srchdata += "，縣市轄區：" + citytitle;

    common.Comm.logOpData(stmt, userData, "LaborEscape", srchdata, userAddr);

    stmt.close();
    con.close();

    searchTitle = "【行蹤不明外勞清單】" + searchTitle;
    session.setAttribute("searchLab", search);
    session.setAttribute("searchLabTitle", searchTitle);
    response.sendRedirect("QryLaborEscapeBrief.jsp");
}



%>


<html>
<head>
<%@ include file="/include/HeaderTimeout.inc" %>
</head>

<BODY bgcolor="#F9CD8A">

<br><br>
無此項查詢，請重新輸入。
condition = <%=condition%><br>
<%=search%><br>
<%=searchTitle%><br>
<form action="">
<td align=left width=5%>
    <input type=button value="回上一頁" onClick="javascript:history.back()">
</td>
</form>

<%
//關閉連線
stmt.close();
if (con != null) con.close();
%>


</BODY>
</HTML>