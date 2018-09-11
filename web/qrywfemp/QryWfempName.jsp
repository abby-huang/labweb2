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
String pageHeader = "專業外國人雇主資料查詢";
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
String vendname = strCheckNull( request.getParameter("vendname") );
String regno = strCheckNull( request.getParameter("regno") ).toUpperCase();
String zipcode = strCheckNull( request.getParameter("zipcode") );

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

Statement stmt = con.createStatement();
ResultSet rs;
String qs;

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
if (vendname.length() > 0) search += " and s2.vend_name_ch like " + AbSql.getLeadingStr(vendname);
if (regno.length() > 0) search += " and vend_id = " + AbSql.getEqualStr(regno);
if (zipcode.length() > 0)
    search += " and vend_zone = " + AbSql.getEqualStr(zipcode);

if (search.length() > 0) search = " where" + search.substring(4);
search = " wcf_vendm s2" + search;

String searchTitle = "";
if (type.equals("1")) searchTitle = "、案件授權單位【勞動力發展署】";
    else  searchTitle = "、案件授權單位【科學園區及加工出口區】";
if (zipcode.length() > 0) searchTitle += "、郵遞區號【" + zipcode + "】";
if (vendname.length() > 0) searchTitle += "、雇主名稱【" + vendname + "】";
if (regno.length() > 0) searchTitle += "、雇主編號【" + regno + "】";
searchTitle = searchTitle.substring(1);

//檢查郵遞區號
if (zipcode.length() > 0) {
    qs = "select * from fpv_zipcitym"
            + " where zipcode = " + AbSql.getEqualStr(zipcode);
    rs = stmt.executeQuery(qs);
    if (!rs.next()) errMsg = "郵遞區號輸入錯誤";
    rs.close();
}

if ((vendname.length() > 0) && vendname.length() < 2)
    errMsg = "雇主名稱請輸入 2 個字以上!";

if (errMsg.length() == 0 ) {
    String srchdata = "";
    if (vendname.length() > 0) srchdata = "雇主名稱：" + vendname;
    if (regno.length() > 0) {
        if (srchdata.length() > 0) srchdata += "，";
        srchdata += "雇主編號：" + regno;
    }
    if (zipcode.length() > 0) {
        if (srchdata.length() > 0) srchdata += "，";
        srchdata += "郵遞區號：" + zipcode;
    }

    //寫入日誌檔
    common.Comm.logOpData(stmt, userData, "WfempName", srchdata, userAddr);

    //關閉連線
    stmt.close();
    if (con != null) con.close();

    //查詢表格
    session.setAttribute("tblcasem", tblcasem);
    session.setAttribute("tblengagerec", tblengagerec);
    session.setAttribute("tblexpirrec", tblexpirrec);

    session.setAttribute("searchWfemp", search);
    session.setAttribute("searchWfempTitle", searchTitle);
    response.sendRedirect("QryWfempNameBrief.jsp");
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

<form action="">
<td align=left width=5%>
    <input type=button value="回上一頁" onClick="javascript:history.back()">
</td>
</form>

<%=search%>

<%
//關閉連線
stmt.close();
if (con != null) con.close();
%>


</BODY>
</HTML>