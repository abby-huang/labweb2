<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "專業外國人僱用清冊";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpwhite.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
String errMsg = "";
Connection con = null;

//取得輸入資料
String type = strCheckNull( request.getParameter("type") );
String citycode = strCheckNull( request.getParameter("citycode") );
String addrtype = strCheckNull( request.getParameter("addrtype") );
String bizcode = strCheckNull( request.getParameter("bizcode") );

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

Statement stmt = con.createStatement();

//查詢表格 - 本署
String tblcasem = "wcf_casem";
String tblengagerec = "wcf_engagerec";
String tblexpirrec = "wcf_expirrec";
//授權單位
if (type.equals("2")) {
    tblcasem = "wcf_xcasem";
    tblengagerec = "wcf_xengagerec";
    tblexpirrec = "wcf_xexpirrec";
}

//限制條件
String search = "";
String searchTitle = "";

if (type.equals("1")) searchTitle = "案件授權單位【勞動力發展署】";
    else  searchTitle = "案件授權單位【科學園區及加工出口區】";

//縣市郵遞區號
String zipcodes = "";
String qs = "select zipcode from fpv_zipcitym"
        + " where citycode = " + AbSql.getEqualStr(citycode)
        + " order by zipcode";
ResultSet rs = stmt.executeQuery(qs);
while (rs.next()) {
    if (zipcodes.length() > 0) zipcodes += ",";
    zipcodes += "'" + strCheckNull( rs.getString(1) ) + "'";
}
rs.close();
if (zipcodes.length() > 0) zipcodes = "(" + zipcodes + ")";

String citytitle = "";
qs = "select cityname from fpv_citym"
    + " where citytype='A' and citycode = " + AbSql.getEqualStr(citycode);
rs = stmt.executeQuery(qs);
if (rs.next()) citytitle = strCheckNull( rs.getString(1) ).trim().replaceAll("　+$", "");
rs.close();

//行職業別
String biztitle = "";
qs = "SELECT code_name FROM wcf_pubcoded"
    + " where code_item='02' and code_1 = " + AbSql.getEqualStr(bizcode)
    + " and (code_2 is null or code_2 = '')"
    + " and (code_3 is null or code_3 = '')";
rs = stmt.executeQuery(qs);
if (rs.next()) biztitle = strCheckNull( rs.getString(1) ).trim().replaceAll("　+$", "");
rs.close();

//查詢條件
if (addrtype.equals("1")) {
    //雇主地址
    search = tblengagerec + " m, " + tblcasem + " s1, wcf_vendm s2";
    search += " where work_edate > " + AbSql.getEqualStr( AbDate.getToday() );
    if (zipcodes.length() > 0) search += " and vend_zone in " + zipcodes;
    search += " and appltype = " + AbSql.getEqualStr(bizcode);
    search += " and s1.case_sn = m.case_sn";
    search += " and (s1.current_status = '11' or s1.current_status = '12')";
    search += " and s2.vend_seq = s1.vend_seq";
    searchTitle += "、雇主地址【" + citytitle + "】";
} else {
    //工作地址
    search = tblengagerec + " m, " + tblcasem + " s1, wcf_vendm s2";
    search += " where work_edate > " + AbSql.getEqualStr( AbDate.getToday() );
    if (zipcodes.length() > 0) search += " and work_address_zone in " + zipcodes;
    search += " and appltype = " + AbSql.getEqualStr(bizcode);
    search += " and s1.case_sn = m.case_sn";
    search += " and (s1.current_status = '11' or s1.current_status = '12')";
    search += " and s2.vend_seq = s1.vend_seq";
    searchTitle += "、工作地址【" + citytitle + "】";
}

searchTitle += "、行職業別【" + biztitle + "】";

if (errMsg.length() == 0 ) {
    String srchdata = searchTitle;

    //寫入日誌檔
    common.Comm.logOpData(stmt, userData, "WfempList", srchdata, userAddr);

    //關閉連線
    stmt.close();
    if (con != null) con.close();

    //查詢表格
    session.setAttribute("tblcasem", tblcasem);
    session.setAttribute("tblengagerec", tblengagerec);
    session.setAttribute("tblexpirrec", tblexpirrec);

    session.setAttribute("searchWfemp", search);
    session.setAttribute("searchWfempTitle", searchTitle);
    session.setAttribute("wfempCitycode", citycode);
    session.setAttribute("wfempCityTitle", citytitle);
    session.setAttribute("wfempBizcode", bizcode);
    session.setAttribute("wfempBizTitle", biztitle);
    response.sendRedirect("../qrywfemp/QryWfempNameBrief.jsp");
}

%>


<html>
<head>
<%@ include file="/include/HeaderTimeout.inc" %>
</head>

<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
    history.back();
</script>
<%}%>

<BODY bgcolor="#F9CD8A">

<%=search%><br>
<%=searchTitle%><br>
<br>
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