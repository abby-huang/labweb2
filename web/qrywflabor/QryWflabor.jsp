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
function checkPassnoEngname(frm)
{
    frm.passno.value = frm.passno.value.replace(/^\s+|\s+$/g,'');
    frm.engname.value = frm.engname.value.replace(/^\s+|\s+$/g,'');
    frm.residence_id.value = frm.residence_id.value.replace(/^\s+|\s+$/g,'');
    if ((frm.passno.value != "") || (frm.engname.value != "") || (frm.residence_id.value != ""))
        return true;
    else {
        alert ("請輸入護照號碼、統一證號或英文姓名!");
        return false;
    }
}
</script>

</head>

<BODY bgcolor="#F9CD8A" text="#990000">

<center>
<table width="600" border="0" cellspacing="0" cellpadding="0" >
  <tr>
    <td align=center><img src="../image/qry_wflabor.gif" alt="專業外國人查詢" >
    </td>
  </tr>
  <tr>
    <td align=center><img src="../image/line_main.gif" alt="美化圖形" >
    </td>
  </tr>
</table>


<table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="600">
   <tr bgcolor="#FF9900">
       <td ><img src="../image/arrow.gif" alt="美化圖形"><font color="#FFFFFF">專業外國人查詢</font></td>

           <form method=post action="../common/LogDataList.jsp">
       <td align="" colspan=3>　　　　　　　　　　　　
<%if (userOpsuper.equals("Y")) { %>
                <input name="logid" type="hidden" value=<%=logWflaborData%>>
                <input value=日誌查詢 type=submit>
<%} %>
       </td>
            </form>
   </tr>

 <form action="QryWflaborData.jsp" method="post" onsubmit="return checkPassnoEngname(this);">
   <tr >
       <td align=right>案件授權單位：
       </td>
       <td colspan=3><select  name="type"  style="HEIGHT: 22px; WIDTH: 200px">
           <option value="1" selected>勞動力發展署</option>
           <option value="2">科學園區及加工出口區</option>
       </td>
   </tr>
   <tr >
       <td width=25% align=right>國籍：
       </td>
       <td width=20% ><select  name=natcode style="HEIGHT: 22px; WIDTH: 160px">

<%
    qs = "select naticode, natiname from fpv_natim"
        + " where naticode > '000'"
        + " and naticode < '900'"
        + " order by naticode";
    rs = stmt.executeQuery(qs);
    while (rs.next()) {
        String naticode = strCheckNull( rs.getString("naticode") );
        String natiname = strCheckNull( rs.getString("natiname") );
%>
                    <option value="<%=naticode%>"><%=naticode%>-<%=natiname%></option>
<%
    }
    rs.close();
%>

            </select>
       </td>
       <td width=20% align=right >護照號碼：
       </td>
       <td width=35% ><input type=text name=passno>
       </td>
   </tr>
   <tr >
       <td align=right >統一證號：
       </td>
       <td colspan=3><input type="text" name="residence_id">
       </td>
   </tr>
   <tr >
       <td align=right >英文姓名：
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



<%
//關閉連線
stmt.close();
if (con != null) con.close();
%>

<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
</script>
<%}%>

</BODY>
</HTML>