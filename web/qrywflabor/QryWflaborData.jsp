<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
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

//取得輸入資料
String type = strCheckNull( request.getParameter("type") );
String natcode = strCheckNull( request.getParameter("natcode") );
String passno = strCheckNull( request.getParameter("passno") ).toUpperCase();
String engname = strCheckNull( request.getParameter("engname") ).toUpperCase();
String sex = strCheckNull( request.getParameter("sex") );
String birthday = strCheckNull( request.getParameter("birthday") );
String residence_id = strCheckNull( request.getParameter("residence_id") );
//統一證號不必限制國籍 - 20101214
if (residence_id.length() > 0) natcode = "";
String search = "";

if ((passno.length() > 0) || (engname.length() > 0) || (residence_id.length() > 0)) {
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
    search = "";
    //統一證號不必限制國籍 - 20101214
    if (natcode.length() > 0) search =  " and l.naticode = " + AbSql.getEqualStr(natcode);
    if (passno.length() > 0)    search += " and l.passno = " + AbSql.getEqualStr(passno);
    if (engname.length() > 0)   search += " and l.name_eng like " + AbSql.getLikeStr(engname);
    if (sex.length() > 0)       search += " and l.sex = " + AbSql.getEqualStr(sex);
    if (birthday.length() > 0)  search += " and l.birthday = " + AbSql.getEqualStr(birthday);
    if (residence_id.length() > 0)  search += " and l.residence_id = " + AbSql.getEqualStr(residence_id);
    if (search.length() > 0) search = " where " + search.substring(4);

    //建立連線
    Connection con = getConnection( session );
    Statement stmt = con.createStatement();

    //讀取國籍
    String qs = "";
    String natiname = "";
    //統一證號不必限制國籍 - 20101214
    if (natcode.length() > 0) {
        qs = "select natiname from fpv_natim where naticode = "
                + AbSql.getEqualStr(natcode);
        ResultSet rs = stmt.executeQuery(qs);
        if (rs.next()) natiname = rs.getString("natiname");
        rs.close();
    }

    //性別
    String sextitle = "";
    if (sex.equals("F")) sextitle = "女";
    else if (sex.equals("M")) sextitle = "男";

    String searchTitle = "";
    if (type.equals("1")) searchTitle = "、案件授權單位【勞動力發展署】";
        else  searchTitle = "、案件授權單位【科學園區及加工出口區】";
    if (natiname.length() > 0) searchTitle += "、國籍【" + natiname + "】";
    if (passno.length() > 0) searchTitle += "、護照號碼【" + passno + "】";
    if (residence_id.length() > 0) searchTitle += "、統一證號【" + residence_id + "】";
    if (engname.length() > 0) searchTitle += "、英文姓名【" + engname + "】";
    if (sextitle.length() > 0) searchTitle += "、性別【" + sextitle + "】";
    if (birthday.length() > 0) searchTitle += "、出生日期【" + birthday + "】";
    if (searchTitle.length() > 0) searchTitle =  searchTitle.substring(1);


    //寫入日誌檔
    String srchdata = "";
    if (natiname.length() > 0) srchdata = "，範圍：" + type;
    if (natiname.length() > 0) srchdata = "，國籍：" + natiname;
    if (passno.length() > 0) srchdata += "，護照號碼：" + passno;
    if (residence_id.length() > 0) srchdata += "，統一證號：" + residence_id;
    if (engname.length() > 0) srchdata += "，英文姓名：" + engname;
    if (sextitle.length() > 0) srchdata += "，性別：" + sextitle;
    if (birthday.length() > 0) srchdata += "，出生日期：" + birthday;
    if (srchdata.length() > 0) srchdata =  srchdata.substring(1);

    common.Comm.logOpData(stmt, userData, "WflaborData", srchdata, userAddr);

    stmt.close();
    con.close();

    //查詢表格
    session.setAttribute("tblcasem", tblcasem);
    session.setAttribute("tblengagerec", tblengagerec);
    session.setAttribute("tblexpirrec", tblexpirrec);

    session.setAttribute("searchWflab", search);
    session.setAttribute("searchWflabTitle", searchTitle);
    response.sendRedirect("QryWflaborDataBrief.jsp");
}
%>


<html>
<head>
<%@ include file="/include/HeaderTimeout.inc" %>
</head>

<BODY bgcolor="#F9CD8A">

<%=search%>

<br><br>
查詢條件必須輸入 "護照號碼" 或 "英文姓名"，請重新輸入。
<form action="">
<td align=left width=5%>
    <input type=button value="回上一頁" onClick="javascript:history.back()">
</td>
</form>

</BODY>
</HTML>