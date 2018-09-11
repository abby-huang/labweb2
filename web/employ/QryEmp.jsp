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
String pageHeader = "藍領外國人雇主資料查詢";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpblue.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

String errMsg = "";
Connection con = null;

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

String qs = "";
Statement stmt = null;
ResultSet rs = null;
if (errMsg.length() == 0) {
    stmt = con.createStatement();
}
%>


<html>
<head>

<%@ include file="/include/HeaderTimeout.inc" %>

<script language="JavaScript">
function checkName(frm)
{
    frm.vendname.value = frm.vendname.value.replace(/^\s+|\s+$/g,'');
    frm.regno.value = frm.regno.value.replace(/^\s+|\s+$/g,'');
    frm.zipcode.value = frm.zipcode.value.replace(/^\s+|\s+$/g,'');
    if ((frm.vendname.value != "") || (frm.regno.value != "") || (frm.zipcode.value != "")) {
        if ((frm.vendname.value != "") && (frm.vendname.value.length < 2)) {
            alert ("雇主名稱請輸入 2 個字以上!");
            return false;
        }
        return true;
    } else {
        alert ("請輸入雇主名稱、雇主編號或郵遞區號!");
        return false;
    }
}
function checkWpgnamd(frm)
{
    frm.commname.value = frm.commname.value.replace(/^\s+|\s+$/g,'');
    frm.commid.value = frm.commid.value.replace(/^\s+|\s+$/g,'');
    if ((frm.commname.value != "") || (frm.commid.value != "")) {
        if ((frm.commname.value != "") && (frm.commname.value.length < 2)) {
            alert ("被看護人名稱請輸入 2 個字以上!");
            return false;
        }
        return true;
    } else {
        alert ("請輸入被看護人名稱、被看護人編號!");
        return false;
    }
}
function checkAgent(frm)
{
    frm.agenno.value = frm.agenno.value.replace(/^\s+|\s+$/g,'');
    if (frm.agenno.value == "") {
        alert ("請輸入仲介公司代碼!");
        return false;
    }
}
function checkIllegal(frm)
{
    frm.vendname.value = frm.vendname.value.replace(/^\s+|\s+$/g,'');
    frm.regno.value = frm.regno.value.replace(/^\s+|\s+$/g,'');
    frm.startdate.value = frm.startdate.value.replace(/^\s+|\s+$/g,'');
    frm.enddate.value = frm.enddate.value.replace(/^\s+|\s+$/g,'');

    if ((frm.vendname.value == "") && (frm.regno.value == "")
        && (frm.startdate.value == "") && (frm.enddate.value == "")) {
        alert ("請輸入雇主名稱或雇主編號或日期區間!");
        return false;
    }

    if ( ((frm.startdate.value != "") && (frm.startdate.value.length != 8)) ||
        ((frm.enddate.value != "") && (frm.enddate.value.length != 8)) ) {
        alert ("日期區間格式輸入錯誤!");
        return false;
    }

    if ((frm.vendname.value != "") || (frm.regno.value != "")) {
        if ((frm.vendname.value != "") && (frm.vendname.value.length < 2)) {
            alert ("雇主名稱請輸入 2 個字以上!");
            return false;
        }
        return true;
    }
}
</script>

</head>


<BODY bgcolor="#F9CD8A" text="#990000">
<center>
<table width="600" border="0" cellspacing="0" cellpadding="0" >
  <tr>
    <td align=center><img src="../image/qry_emp.gif" alt="雇主查詢" >
    </td>
  </tr>
  <tr>
    <td align=center><img src="../image/line_main.gif" alt="美化圖形" >
    </td>
  </tr>
</table>




<table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="550">
    <tr bgcolor="#FF9900">
      <td ><img src="../image/arrow.gif" alt="美化圖形">
        <font color="#FFFFFF">雇主個別查詢</font>
      </td>

            <form method=post action="../common/LogDataList.jsp">
            <td align="right">
<%if (userOpsuper.equals("Y")) { %>
                <input name="logid" type="hidden" value=<%=logEmpName%>>
                <input value=日誌查詢 type=submit>
<%} %>
            </td>
            </form>
    </tr>

<form action="QryEmpName.jsp" method="post" onsubmit="return checkName(this);">
    <input name=type type=hidden value="1">
    <tr >
      <td width=30% align=right >雇主名稱：
      </td>
      <td >
           <input name=vendname type=text style="HEIGHT: 22px; WIDTH: 200px" >
           <br>以此查詢速度較為緩慢  請耐心等候
      </td>
    </tr>
    <tr >
      <td align=right >雇主編號：
      </td>
      <td >
           <input name=regno type=text style="HEIGHT: 22px; WIDTH: 200px">
    <tr >
      <td align=right >郵遞區號：
      </td>
      <td >
          <input name=zipcode type=text maxlength=3 style="HEIGHT: 22px; WIDTH: 50px">
          <input value=查詢 type=submit>
    </tr>
</table>
</form>


<table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="550">
    <tr bgcolor="#FF9900">
      <td ><img src="../image/arrow.gif" alt="美化圖形">
        <font color="#FFFFFF">雇主違法查詢</font>
      </td>

            <form method=post action="../common/LogDataList.jsp">
            <td align="right">
<%if (userOpsuper.equals("Y")) { %>
                <input name="logid" type="hidden" value=<%=logEmpIllegal%>>
                <input value=日誌查詢 type=submit>
<%} %>
            </td>
            </form>
    </tr>

<form action ="QryEmpIllegal.jsp" method="post" onsubmit="return checkIllegal(this);">
   <tr >
       <td width=30% align=right >違法日期區間：
       </td>
       <td width=70%>
           <input type=text name=startdate value="" maxlength=8  style="HEIGHT: 22px; WIDTH: 62px">
           ～
           <input type=text name=enddate value="" maxlength=8  style="HEIGHT: 22px; WIDTH: 62px">
           （yyyymmdd）
       </td>
   </tr>
    <tr >
      <td width="30%" align=right>雇主名稱：
      </td>
      <td width="70%">
          <input name=vendname type=text style="HEIGHT: 22px; WIDTH: 200px" >
          <br>以此查詢速度較為緩慢  請耐心等候
      </td>
    </tr>
    <tr >
      <td align=right>雇主編號：
      </td>
      <td >
              <input name=regno type=text style="HEIGHT: 22px; WIDTH: 200px">
              <input value=查詢 type=submit>
      </td>
    </tr>
</table>
</form>


<table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="550">
    <tr bgcolor="#FF9900">
      <td ><img src="../image/arrow.gif" alt="美化圖形">
        <font color="#FFFFFF">被看護人查詢</font>
      </td>

            <form method=post action="../common/LogDataList.jsp">
            <td align="right">
<%if (userOpsuper.equals("Y")) { %>
                <input name="logid" type="hidden" value=<%=logWpgnamd%>>
                <input value=日誌查詢 type=submit>
<%} %>
            </td>
            </form>
    </tr>

<form action="QryEmpWpgnamdBrief.jsp" method="post" onsubmit="return checkWpgnamd(this);">
    <input name=type type=hidden value="2">
<!--
    <tr >
      <td width=30% align=right >被看護人名稱：
      </td>
      <td >
           <input name=commname type=text style="HEIGHT: 22px; WIDTH: 200px" >
           <br>以此查詢速度較為緩慢  請耐心等候
      </td>
    </tr>
-->
    <tr >
      <td align=right >被看護人編號：
      </td>
      <td >
           <input name=commid type=text style="HEIGHT: 22px; WIDTH: 200px">
      </td>
    </tr>
    <tr >
      <td colspan=2 align=center >
          <input value=查詢 type=submit>
      </td>
    </tr>
</table>
</form>


<table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="550">
    <tr bgcolor="#FF9900">
      <td ><img src="../image/arrow.gif" alt="美化圖形">
        <font color="#FFFFFF">仲介公司查詢</font>
      </td>

            <form method=post action="../common/LogDataList.jsp">
            <td align="right">
<%if (userOpsuper.equals("Y")) { %>
                <input name="logid" type="hidden" value=<%=logEmpAgent%>>
                <input value=日誌查詢 type=submit>
<%} %>
            </td>
            </form>
    </tr>

<form action="QryEmpName.jsp" method="post" onsubmit="return checkAgent(this);">
    <input name=type type=hidden value="3">
    <tr >
      <td width=30% align=right >仲介公司代碼：
      </td>
      <td >
           <input name=agenno type=text style="HEIGHT: 22px; WIDTH: 200px" >
      </td>
    </tr>
    <tr >
      <td colspan=2 align=center >
          <input value=查詢 type=submit>
      </td>
    </tr>
</table>
</form>


</br>

<%
//關閉連線
stmt.close();
if (con != null) con.close();
%>

</BODY>
</HTML>

