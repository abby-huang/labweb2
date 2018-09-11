<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "藍領外國人清冊";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpblue.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
String errMsg = "";
Connection conn = null;

//取得輸入資料
String addrtype = AbString.rtrimCheck( request.getParameter("addrtype") );
String citycode = AbString.rtrimCheck(request.getParameter("citycode") );
String natcode = AbString.rtrimCheck( request.getParameter("natcode") );
String bizseq = AbString.rtrimCheck( request.getParameter("bizseq") );
String status = AbString.rtrimCheck( request.getParameter("status") );

//建立連線
conn = common.Comm.getConnection(session);
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

Statement stmt = conn.createStatement();
stmt.setQueryTimeout(60*90);
String qs;
ResultSet rs;


//限制條件
String OLaborSql = "";
//條件標題
String OLaborTitle = "";

//縣市名稱
String citytitle = "";
if (citycode.length() > 0) {
    qs = "select cityname from fpv_zipcitym"
            + " where citycode = " + AbSql.getEqualStr(citycode);
    rs = common.Comm.querySQL(stmt, qs);
    if (rs.next()) citytitle = rs.getString("cityname");
    rs.close();
}


//雇主地址
if (addrtype.equals("1")) {
    OLaborSql += " and l.citycode = " + AbSql.getEqualStr(citycode);
    OLaborTitle += "雇主地址【" + citytitle + "】";

//工作地址
} else if (addrtype.equals("2")) {
    //縣市郵遞區號
    String zipcodes = "";
    qs = "select zipcode from fpv_zipcitym"
            + " where citycode = " + AbSql.getEqualStr(citycode)
            + " order by zipcode";
    rs = common.Comm.querySQL(stmt, qs);
    while (rs.next()) {
        if (zipcodes.length() > 0) zipcodes += ",";
        zipcodes += "'" + AbString.rtrimCheck( rs.getString(1) ) + "'";
    }
    rs.close();
    zipcodes = "(" + zipcodes + ")";
    OLaborSql += " and l.workzip in " + zipcodes;
    OLaborTitle += "工作地址【" + citytitle + "】";

//工作地址
} else if (addrtype.equals("3")) {
    if (citytitle.indexOf("台") >= 0) {
        OLaborSql = " and (substr(resaddr, 1, 3) = " + AbSql.getEqualStr( citytitle )
            + " or substr(resaddr, 1, 3) = " + AbSql.getEqualStr( citytitle.replace("台", "臺") ) + ")";
    } else {
        OLaborSql = " and substr(resaddr, 1, 3) = " + AbSql.getEqualStr( citytitle );
    }
    OLaborTitle += "外勞居留地【" + citytitle + "】";
}

//行職業別
int ibiz = 0;
//營建業 labdyn_permit = 'C3051' - 20110106
if (bizseq.length() > 0) {
    ibiz = Integer.parseInt(bizseq);
    if (ibiz == 0) {
        OLaborSql += " and (caseno12 not in " + bizCodeToSql2(bizcodes[ibiz]).replaceAll(" ", "");
        OLaborSql += " and emplcode <> 'C3051')";
    } else {
        OLaborSql += " and (caseno12 in " + bizCodeToSql2(bizcodes[ibiz]).replaceAll(" ", "");
        if (ibiz == 1) {//營造業
            OLaborSql += " or emplcode = 'C3051'";
        }
        OLaborSql += ")";
    }
}
if (bizseq.length() > 0) OLaborTitle += "、行職業別【" + bizkinds[ibiz] + "】";

//國籍
if (natcode.length() > 0) {
    OLaborSql += " and l.natcode = " + AbSql.getEqualStr( natcode );
}
if (natcode.length() > 0) OLaborTitle += "、國籍【" + getNatcodeName(natcode, natcodes, natnames) + "】";

//外勞狀態
if (status.equals("1")) {
    OLaborSql += " and l.type = 'SA'";
}
if (status.equals("1")) OLaborTitle += "、外勞狀態【合法】";
else OLaborTitle += "、外勞狀態【全部】";


OLaborSql = " where " + OLaborSql.substring(4);

//寫入日誌檔
//common.Comm.logOpData(stmt, userData, "EmpList", OLaborTitle, userAddr);

//關閉連線
stmt.close();
if (conn != null) conn.close();

session.setAttribute("OLaborSql", OLaborSql);
session.setAttribute("OLaborTitle", OLaborTitle);
response.sendRedirect("OLaborVendList.jsp");

%>


<html>
<head>
<%@ include file="/include/Header.inc" %>
</head>

<BODY bgcolor="#F9CD8A">

<%
if (debug) out.println(OLaborSql + "<BR>");
%>

沒有資料，請重新輸入查詢條件。
<form action="">
<input type=button value="回上一頁" onClick="javascript:history.back()">
</form>

</BODY>
</HTML>
