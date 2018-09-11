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
String natcode = strCheckNull( request.getParameter("natcode") );
String passno = strCheckNull( request.getParameter("passno") ).toUpperCase();
String resnum = strCheckNull( request.getParameter("resnum") ).toUpperCase();
String engname = strCheckNull( request.getParameter("engname") ).toUpperCase();
String sex = strCheckNull( request.getParameter("sex") );
String birthday = strCheckNull( request.getParameter("birthday") );
String search = "";

if ((passno.length() > 0) || (resnum.length() > 0) || (engname.length() > 0)) {
    //限制條件
    search =  "";
    if (natcode.length() > 0)    search += " and l.natcode = " + AbSql.getEqualStr(natcode);
    if (passno.length() > 0)    search += " and l.passno = " + AbSql.getEqualStr(passno);
    if (engname.length() > 0)   search += " and l.engname like " + AbSql.getLikeStr(engname);
    if (sex.length() > 0)       search += " and l.sex = " + AbSql.getEqualStr(sex);
    if (birthday.length() > 0)  search += " and l.birthday = " + AbSql.getEqualStr(birthday);
    // 20180502 增加判斷新舊護照對照 fpv_uplabono
    search += " and (l.chng_id <> 'D'"
            + " or exists (select labono from fpv_uplabono o where o.olabono=(l.natcode || l.passno)))";
    if (resnum.length() > 0) {
        search += " and exists (select * from labdyn_resident r where r.resnum = " + AbSql.getEqualStr(resnum)
                + " and l.natcode = r.natcode and l.passno = r.passno)";
    }
    if (search.length() > 0) search = " where " + search.substring(4);

    //建立連線
    Connection con = getConnection( session );
    Statement stmt = con.createStatement();

    //讀取國籍
    String natiname = getNatcodeName(natcode, natcodes, natnames);

    //性別
    String sextitle = "";
    if (sex.equals("F")) sextitle = "女";
    else if (sex.equals("M")) sextitle = "男";

    String searchTitle = "國籍【" + natiname + "】";
    if (passno.length() > 0) searchTitle += "、護照號碼【" + passno + "】";
    if (resnum.length() > 0) searchTitle += "、居留證號【" + resnum + "】";
    if (engname.length() > 0) searchTitle += "、英文姓名【" + engname + "】";
    if (sextitle.length() > 0) searchTitle += "、性別【" + sextitle + "】";
    if (birthday.length() > 0) searchTitle += "、出生日期【" + birthday + "】";


    //寫入日誌檔
    String srchdata = "國籍：" + natiname;
    if (passno.length() > 0) srchdata += "，護照號碼：" + passno;
    if (resnum.length() > 0) srchdata += "，居留證號：" + resnum;
    if (engname.length() > 0) srchdata += "，英文姓名：" + engname;
    if (sextitle.length() > 0) srchdata += "，性別：" + sextitle;
    if (birthday.length() > 0) srchdata += "，出生日期：" + birthday;

    common.Comm.logOpData(stmt, userData, "LaborData", srchdata, userAddr);

    stmt.close();
    con.close();

    session.setAttribute("searchLab", search);
    session.setAttribute("searchLabTitle", searchTitle);
    response.sendRedirect("QryLaborDataBrief.jsp");
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