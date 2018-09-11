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
<script language="JavaScript" src="<%=appRoot%>/js/City.js"></script>

<script language="JavaScript">
function checkPassno(frm)
{
    frm.passno.value = frm.passno.value.replace(/^\s+|\s+$/g,'');
    if (frm.passno.value != "")
        return true;
    else {
        alert ("請輸入護照號碼!");
        return false;
    }
}

function checkPassnoEngname(frm)
{
    frm.passno.value = frm.passno.value.replace(/^\s+|\s+$/g,'');
    frm.resnum.value = frm.resnum.value.replace(/^\s+|\s+$/g,'');
    frm.engname.value = frm.engname.value.replace(/^\s+|\s+$/g,'');
    if ((frm.passno.value != "") || (frm.resnum.value != "") || (frm.engname.value != ""))
        return true;
    else {
        alert ("請輸入護照號碼或居留證號或英文姓名!");
        return false;
    }
}

function checkWkaddr(frm)
{
    frm.city.value = frm.city.value.replace(/^\s+|\s+$/g,'');
    frm.town.value = frm.town.value.replace(/^\s+|\s+$/g,'');
    frm.wkaddr.value = frm.wkaddr.value.replace(/^\s+|\s+$/g,'');
    if ((frm.city.value != "") && (frm.town.value != "") && (frm.wkaddr.value.toString().length >= 3))
        return true;
    else if (((frm.city.value == "新竹市") || (frm.city.value == "嘉義市"))&& (frm.wkaddr.value.toString().length >= 3))
        return true;
    else {
        alert ("請輸縣市鄉鎮與地址!");
        return false;
    }
}

</script>

</head>

<BODY bgcolor="#F9CD8A" text="#990000">

<center>
<table width="600" border="0" cellspacing="0" cellpadding="0" >
  <tr>
    <td align=center><img src="../image/qry_labor.gif" alt="外勞查詢" >
    </td>
  </tr>
  <tr>
    <td align=center><img src="../image/line_main.gif" alt="美化圖形" >
    </td>
  </tr>
</table>



<table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="550">
   <tr bgcolor="#FF9900">
       <td ><img src="../image/arrow.gif" alt="美化圖形"><font color="#FFFFFF">依外勞資料查詢</font></td>

           <form method=post action="../common/LogDataList.jsp">
       <td align="right" colspan=3>
<%if (userOpsuper.equals("Y")) { %>
                <input name="logid" type="hidden" value=<%=logLaborData%>>
                <input value=日誌查詢 type=submit>
<%} %>
       </td>
            </form>
   </tr>

<form action="QryLaborData.jsp" method="post" onsubmit="return checkPassnoEngname(this);">
   <tr >
       <td width=25% align=right>國籍：
       </td>
       <td width=20% >
           <select  name=natcode style="HEIGHT: 22px; WIDTH: 100px">
<%for (int i = 0; i < natcodes.length; i++) {%>
                <option value=<%=natcodes[i]%>><%=natcodes[i]%>-<%=natnames[i]%></option>
<%}%>
            </select>
       </td>
       <td width=20% align=right >護照號碼：
       </td>
       <td width=35% ><input type=text name=passno>
       </td>
   </tr>
   <tr >
       <td align=right >居留證號：
       </td>
       <td colspan=3><input type=text name=resnum>
       </td>
   </tr>
   <tr >
       <td align=right >外勞英文姓名：
       </td>
       <td colspan=3><input type="text" name="engname" size="42">
       <br>此種查詢方式速度較為緩慢 請耐心等候
       </td>
   </tr>
   <tr >
       <td align=right >性別：
       </td>
       <td ><select size="1" name="sex">
              <option value=""></option>
              <option value="M">男</option>
              <option value="F">女</option>
            </select>
       </td>
       <td align=right>出生年月日：
       </td>
       <td ><input type="text" name="birthday" size="8">（yyyymmdd）
       </td>
   </tr>
   <tr >
       <td colspan=4 align=center><input value=查詢  type=submit>
       </td>
   </tr>
</table>
</form>




<table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="550">
   <tr bgcolor="#FF9900">
       <td ><img src="../image/arrow.gif" alt="美化圖形"><font color="#FFFFFF">依工作地址查詢</font></td>

           <form method=post action="../common/LogDataList.jsp">
       <td align="right" colspan=3>
<%if (userOpsuper.equals("Y")) { %>
                <input name="logid" type="hidden" value=<%=logLaborWkaddr%>>
                <input value=日誌查詢 type=submit>
<%} %>
       </td>
            </form>
   </tr>

<form name="form1" action="QryLaborWkaddr.jsp" method="post" onsubmit="return checkWkaddr(this);">
   <tr >
        <td width=25% align=right>工作地址：
       <td width=75% colspan=4 align="left" >
            縣市別
            <select name="city" size="1" onchange="getTown(form1.city, form1.town, ''); return true">
                <script language=JavaScript>
                    getCity(form1.city, '');
                </script>
            </select>
            鄉鎮市別
            <select name="town" size="1">
                <script language=javascript>
                    getTown(form1.city, form1.town, '');
                </script>
            </select>
            <br/>地址 <input type="text" name="wkaddr" size="42">
        </td>
    </tr>
   </tr>
   <tr >
       <td colspan=4 align=center><input value=查詢  type=submit>
       </td>
   </tr>
</table>
</form>





<table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="550">
   <tr bgcolor="#FF9900">
       <td colspan=4><img src="../image/arrow.gif" alt="美化圖形"><font color="#FFFFFF">外勞在台天數</font></td>
           <form method=post action="../common/LogDataList.jsp">
       <td align="right" colspan=3>
<%if (userOpsuper.equals("X")) { %>
                <input name="logid" type="hidden" value=<%=logLaborDayintw%>>
                <input value=日誌查詢 type=submit>
<%} %>
       </td>
            </form>
   </tr>
<form action="../dayintw/QryDayintwDetail.jsp" method="post" onsubmit="return checkPassno(this);">
   <tr >
       <td colspan=2 width=30% align=right >國籍：
       </td>
       <td colspan=2 width=70%>
                <select  name=natcode style="HEIGHT: 22px; WIDTH: 140px">
<%for (int i = 0; i < natcodes.length; i++) {%>
                    <option value=<%=natcodes[i]%>><%=natcodes[i]%>-<%=natnames[i]%></option>
<%}%>
                </select>
       </td>
   </tr>
   <tr >
       <td colspan=2 align=right >護照號碼：
       </td>
       <td colspan=2 >
           <input type=text name=passno> （需搭配國籍別查詢）
       </td>
   </tr>
   <tr >
       <td colspan=4 align=center >
                <input value=查詢  type=submit>
       </td>
   </tr>
</table>
</form>




<table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="550">
   <tr bgcolor="#FF9900">
       <td colspan=4><img src="../image/arrow.gif" alt="美化圖形"><font color="#FFFFFF">行蹤不明外勞查詢</font></td>
           <form method=post action="../common/LogDataList.jsp">
       <td align="right" colspan=3>
<%if (userOpsuper.equals("X")) { %>
                <input name="logid" type="hidden" value=<%=logLaborEscape%>>
                <input value=日誌查詢 type=submit>
<%} %>
       </td>
            </form>
   </tr>

<form action="../escape/QryEscapeDetail.jsp" method="post" onsubmit="return checkPassno(this);">
   <tr >
       <td colspan=2 width=30% align=right >國籍：
       </td>
       <td colspan=2 width=70%>
                <select  name=natcode style="HEIGHT: 22px; WIDTH: 140px">
<%for (int i = 0; i < natcodes.length; i++) {%>
                    <option value=<%=natcodes[i]%>><%=natcodes[i]%>-<%=natnames[i]%></option>
<%}%>
                </select>
   </tr>
   <tr >
       <td colspan=2 align=right >護照號碼：
       </td>
       <td colspan=2 ><input type=text name=passno>（需搭配國籍別查詢）
       </td>
   </tr>
   <tr >
       <td colspan=4 align=center><input value=查詢  type=submit name="submit">
       </td>
   </tr>
</table>
</form>




<table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="550">
   <tr bgcolor="#FF9900">
       <td ><img src="../image/arrow.gif" alt="美化圖形"><font color="#FFFFFF">依外勞狀態查詢</font></td>



            <form method=post action="../common/LogDataList.jsp">
            <td align="right">
<%if (userOpsuper.equals("Y")) { %>
                <input name="logid" type="hidden" value=<%=logLaborStatus%>>
                <input value=日誌查詢 type=submit>
<%} %>
            </td>
            </form>


   </tr>

<form action="QryLaborStatus.jsp" method="post" onsubmit="return checkStartEndDate(this);">
   <tr >
       <td colspan=2>
              <p align="center">
                <input value=1  name=condition type=radio checked>
                健檢不合格
<!--
                <input value=2  name=condition type=radio>
                遣返
-->
                <input value=3  name=condition type=radio>
                最近入境日期
                <input value=4  name=condition type=radio>
                最近聘雇起始日期
       </td>
   </tr>
   <tr >
       <td width=30% align=right >事件發生區間：
       </td>
       <td width=70%>
           <input type=text name=startdate value="" maxlength=8  style="HEIGHT: 22px; WIDTH: 62px">
           ～
           <input type=text name=enddate value="" maxlength=8  style="HEIGHT: 22px; WIDTH: 62px">
           （yyyymmdd）
       </td>
   </tr>
   <tr >
       <td align=right >國籍別：
       </td>
       <td >
                <select  name=natcode style="HEIGHT: 22px; WIDTH: 140px">
                  <option value='' selected>(全選)</option>
<%for (int i = 0; i < natcodes.length; i++) {%>
                    <option value=<%=natcodes[i]%>><%=natcodes[i]%>-<%=natnames[i]%></option>
<%}%>
                </select>
       </td>
   </tr>
   <tr >
       <td align=right >縣市轄區：
       </td>
       <td >
<%
//全區
if (userRegion.equals("*")) {
%>
                <select name=citycode  style="HEIGHT: 22px; WIDTH: 240px">
                    <option value='' selected>(全選)</option>
<%
    qs = "SELECT citycode, cityname FROM fpv_citym"
        + " WHERE citytype='A'"
        + " AND (citycode > '00' AND citycode < '99')"
        + " ORDER BY citycode";
    rs = stmt.executeQuery(qs);
    while (rs.next()) {
                String citycode = rs.getString("citycode");
                String cityname = rs.getString("cityname");
                cityname = checkCityName(citycode, cityname);
%>
                    <option value="<%=citycode%>"><%=cityname%></option>
<%
    }
    rs.close();
%>
                </select>
<%
} else {
    String rgns[] = userRegion.split(",");
    //多區
    if (rgns.length > 1) {
%>
                <select name=citycode  style="HEIGHT: 22px; WIDTH: 240px">
                    <option value=<%=userRegion%> selected>(全選)</option>
<%
        for (int i = 0; i < rgns.length; i++) {
            qs = "SELECT citycode, cityname FROM fpv_citym"
                + " WHERE citytype='A'"
                + " AND citycode = " + AbSql.getEqualStr( rgns[i] );
            rs = stmt.executeQuery(qs);
            if (rs.next()) {
                String citycode = rs.getString("citycode");
                String cityname = rs.getString("cityname").substring(0, 3);
                cityname = checkCityName(citycode, cityname);
%>
                    <option value="<%=citycode%>"><%=cityname%></option>
<%
            }
            rs.close();
        }
%>
                </select>
<%
    //單區
    } else {
%>
                <%=userDivtitle%>
                <input  name="citycode" type="hidden" value=<%=userRegion%>>
<%
    }
}
%>

       </td>
   <tr >
       <td colspan=2 align=center><input value=查詢 type=submit>
       </td>
   </tr>
</table>
</form>







<table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="550">
   <tr bgcolor="#FF9900">
       <td ><img src="../image/arrow.gif" alt="美化圖形"><font color="#FFFFFF">行蹤不明外勞清單</font></td>


            <form method=post action="../common/LogDataList.jsp">
            <td align="right">
<%if (userOpsuper.equals("Y")) { %>
                <input name="logid" type="hidden" value=<%=logLaborEscape%>>
                <input value=日誌查詢 type=submit>
<%} %>
            </td>
            </form>


   </tr>

<form action="QryLaborStatus.jsp" method="post" onsubmit="return checkStartEndDate(this);">
   <tr >
       <td width=30% align=right >行蹤不明日期：
       </td>
       <td width=70%>
                <input type=text name=startdate value="" maxlength=8  style="HEIGHT: 22px; WIDTH: 62px">
                ～
                <input type=text name=enddate value="" maxlength=8  style="HEIGHT: 22px; WIDTH: 62px">
                （yyyymmdd）
       </td>
   </tr>
   <tr >
       <td align=right >國籍別：
       </td>
       <td >
                <select  name=natcode style="HEIGHT: 22px; WIDTH: 140px">
                    <option value='' selected>(全選)</option>
<%for (int i = 0; i < natcodes.length; i++) {%>
                    <option value=<%=natcodes[i]%>><%=natcodes[i]%>-<%=natnames[i]%></option>
<%}%>
                </select>
       </td>
   </tr>
   <tr >
       <td align=right >行職業別：
       </td>
       <td >
                <select  name=bizseq style="HEIGHT: 22px; WIDTH: 140px">
                    <option value='' selected>(全選)</option>
<%for (int i = 0; i < bizkinds.length; i++) {%>
                    <option value=<%=i%>><%=bizkinds[i]%></option>
<%}%>
                </select>
       </td>
   </tr>
   <tr >
       <td align=right >縣市轄區：
       </td>
       <td >
<%
//全區
if (userRegion.equals("*")) {
%>
                <select name=citycode  style="HEIGHT: 22px; WIDTH: 240px">
                    <option value='' selected>(全選)</option>
<%
    qs = "SELECT citycode, cityname FROM fpv_citym"
        + " WHERE citytype='A'"
        + " AND (citycode > '00' AND citycode < '99')"
        + " ORDER BY citycode";
    rs = stmt.executeQuery(qs);
    while (rs.next()) {
                String citycode = rs.getString("citycode");
                String cityname = rs.getString("cityname");
                cityname = checkCityName(citycode, cityname);
%>
                    <option value="<%=citycode%>"><%=cityname%></option>
<%
    }
    rs.close();
%>
                </select>
<%
} else {
    String rgns[] = userRegion.split(",");
    //多區
    if (rgns.length > 1) {
%>
                <select name=citycode  style="HEIGHT: 22px; WIDTH: 240px">
                    <option value=<%=userRegion%> selected>(全選)</option>
<%
        for (int i = 0; i < rgns.length; i++) {
            qs = "SELECT citycode, cityname FROM fpv_citym"
                + " WHERE citytype='A'"
                + " AND citycode = " + AbSql.getEqualStr( rgns[i] );
            rs = stmt.executeQuery(qs);
            if (rs.next()) {
                String citycode = rs.getString("citycode");
                String cityname = rs.getString("cityname").substring(0, 3);
                cityname = checkCityName(citycode, cityname);
%>
                    <option value="<%=citycode%>"><%=cityname%></option>
<%
            }
            rs.close();
        }
%>
                </select>
<%
    //單區
    } else {
%>
                <%=userDivtitle%>
                <input  name="citycode" type="hidden" value=<%=userRegion%>>
<%
    }
}
%>
       </td>
   </tr>
   <tr >
       <td colspan=2 align=center>
                <input name="condition" type="hidden" value="5">
                <input value=查詢 type=submit>
       </td>
   </tr>
</table>
</form>


<table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="550">
    <tr bgcolor="#FF9900">
      <td ><img src="../image/arrow.gif" alt="美化圖形">
        <font color="#FFFFFF">仲介公司引進現聘外勞查詢＊</font>
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

<form action="QryLabdtsAgentMain.jsp" method="post" onsubmit="return checkAgent(this);">
    <input name=type type=hidden value="3">
    <tr >
      <td width=50% align=right >仲介公司代碼：
      </td>
      <td >
           <input name=agenno type=text style="HEIGHT: 22px; WIDTH: 70px" >
      </td>
    </tr>
    <tr >
      <td colspan=2 align=center >
          <input value=查詢 type=submit>
      </td>
    </tr>
</table>
</form>




<%
//關閉連線
stmt.close();
if (con != null) con.close();
%>

</BODY>
</HTML>