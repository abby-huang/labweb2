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
String pageHeader = "藍領外國人雇主個別查詢";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpblue.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
String errMsg = "";
Connection con = null;

//取得輸入資料
String type = strCheckNull( request.getParameter("type") );
String vendname = strCheckNull( request.getParameter("vendname") ).trim();
String regno = strCheckNull( request.getParameter("regno") ).toUpperCase().trim();
String zipcode = strCheckNull( request.getParameter("zipcode") );
String commname = strCheckNull( request.getParameter("commname") ).trim();
String commid = strCheckNull( request.getParameter("commid") ).toUpperCase().trim();
String agenno = strCheckNull( request.getParameter("agenno") ).toUpperCase().trim();

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

Statement stmt = con.createStatement();
ResultSet rs;
String qs;

//限制條件
String search = "";
String logid = "";
if (type.equals("1")) {
    //雇主個別查詢
    logid = "EmpName";
    if (vendname.length() > 0) search += " and m.cname like " + AbSql.getLeadingStr(vendname);
    if (regno.length() > 0) {
        char leading = regno.charAt(0);
        if (Character.isDigit(leading)) {
            if (regno.length() < 8) regno = AbString.leftJustify(regno, 8).trim();
        } else {
            if (regno.length() < 10) regno = AbString.leftJustify(regno, 10).trim();
        }
        search += " and m.regno like " + AbSql.getLeadingStr(regno);
    }
    if (zipcode.length() > 0)
        search += " and m.zipcode = " + AbSql.getEqualStr(zipcode);
    if (search.length() > 0) search = " where" + search.substring(4);
} else if (type.equals("2")) {
    //被看護人查詢
    logid = "Wpgnamd";
    //search += " and m.wpinno=s.wkprmtno";
    if (commname.length() > 0) search += " and commname = " + AbSql.getEqualStr(commname);
    if (commid.length() > 0) {
        if (commid.length() < 10) commid = AbString.leftJustify(commid, 10).trim();
        search += " and commid = " + AbSql.getEqualStr(commid);
    }
    if (search.length() > 0)
        //search = " where " + search.substring(4);
        //取消比對 workprmt, 用 caseno 找出 regno - 2010.03.30
        search = ", fpv_wpgnamd s2 where"
                + search.substring(4)
                + " and (m.regno=" + sqlSubstring + "(s2.caseno, 1, 10))";
        //被看護人取消比對公司統編 - 2010.10.15
        //        + " and (m.regno=" + sqlSubstring + "(s2.caseno, 1, 10) or m.regno=" + sqlSubstring + "(s2.caseno, 1, 8))";
        //search = ",labdyn_workprmt s1, fpv_wpgnamd s2 where"
        //        + " s2.wpinno=s1.wkprmtno and m.regno=s1.regno and " + search.substring(4);
        //search = " where regno in (select regno from labdyn_workprmt, fpv_wpgnamd where "
        //        + " fpv_wpgnamd.wpinno=labdyn_workprmt.wkprmtno and " + search.substring(4) + ")";
} else if (type.equals("3")) {
    //仲介公司查詢
    logid = "EmpAgent";
    //search += " and m.wpinno=s.wkprmtno";
    if (agenno.length() > 0)
        search += " and s2.agenno = " + AbSql.getEqualStr(agenno)
                + " and m.vendno = s2.regno";
    if (search.length() > 0)
        //從 fpv_appemp
        search = ", fpv_appemp s2 where"
                + search.substring(4);
}

//外勞狀態
String searchLab = " and (l.lstatus = 'SAA' or l.lstatus = 'SAC')"
        + " and l.chng_id <> 'D'"
        + " and not exists (select * from labdyn_expir x where "
        + " l.natcode = x.natcode and l.passno = x.passno"
        + " and x.outdate > x.indate and x.indate = l.fstindate)";
if (searchLab.length() > 0) searchLab = searchLab.substring(4, searchLab.length());

String searchTitle = "";
if (zipcode.length() > 0) searchTitle += "、郵遞區號【" + zipcode + "】";
if (vendname.length() > 0) searchTitle += "、雇主名稱【" + vendname + "】";
if (regno.length() > 0) searchTitle += "、雇主編號【" + regno + "】";
if (commname.length() > 0) searchTitle += "、被看護人名稱【" + commname + "】";
if (commid.length() > 0) searchTitle += "、被看護人編號【" + commid + "】";
if (searchTitle.length() > 1) searchTitle = searchTitle.substring(1);

//檢查郵遞區號
if (zipcode.length() > 0) {
    qs = "select * from fpv_zipcitym"
            + " where zipcode = " + AbSql.getEqualStr(zipcode);
    rs = common.Comm.querySQL(stmt, qs);
    if (!rs.next()) errMsg = "郵遞區號輸入錯誤";
    rs.close();
}

if ((vendname.length() > 0) && vendname.length() < 2)
    errMsg = "雇主名稱請輸入 2 個字以上!";
if ((commname.length() > 0) && commname.length() < 2)
    errMsg = "被看護人名稱請輸入 2 個字以上!";

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
    if (commname.length() > 0) {
        if (srchdata.length() > 0) srchdata += "，";
        srchdata = "被看護人名稱：" + commname;
    }
    if (commid.length() > 0) {
        if (srchdata.length() > 0) srchdata += "，";
        srchdata += "被看護人編號：" + commid;
    }
    if (agenno.length() > 0) {
        if (srchdata.length() > 0) srchdata += "，";
        srchdata += "仲介公司代碼：" + agenno;
    }

    //寫入日誌檔
    common.Comm.logOpData(stmt, userData, logid, srchdata, userAddr);

    //關閉連線
    stmt.close();
    if (con != null) con.close();

    session.setAttribute("type", type);
    session.setAttribute("searchEmp", search);
    session.setAttribute("searchEmpLab", searchLab);
    session.setAttribute("searchEmpTitle", searchTitle);
    response.sendRedirect("QryEmpNameBrief.jsp");
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