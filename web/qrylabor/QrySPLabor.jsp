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
String pageHeader = "雙語/廚師人員查詢";
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
function checkPassnoEngname(frm)
{
    frm.idno.value = frm.idno.value.replace(/^\s+|\s+$/g,'');
    frm.resnum.value = frm.resnum.value.replace(/^\s+|\s+$/g,'');
    frm.engname.value = frm.engname.value.replace(/^\s+|\s+$/g,'');
    if ((frm.idno.value != "") || (frm.resnum.value != "") || (frm.engname.value != ""))
        return true;
    else {
        alert ("請輸入護照號碼或居留證號或英文姓名!");
        return false;
    }
}

function checkName(frm)
{
    frm.vendname.value = frm.vendname.value.replace(/^\s+|\s+$/g,'');
    frm.regno.value = frm.regno.value.replace(/^\s+|\s+$/g,'');
    if ((frm.vendname.value != "") || (frm.regno.value != "")) {
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

</script>

</head>

<BODY bgcolor="#F9CD8A" text="#990000">

<center>
<table width="600" border="0" cellspacing="0" cellpadding="0" >
  <tr>
    <td align=center><img src="../image/qry_splabor.gif" alt="雙語/廚師人員查詢" >
    </td>
  </tr>
  <tr>
    <td align=center><img src="../image/line_main.gif" alt="美化圖形" >
    </td>
  </tr>
</table>



<table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="570">
   <tr bgcolor="#FF9900">
       <td ><img src="../image/arrow.gif" alt="美化圖形"><font color="#FFFFFF">雙語/廚師人員查詢</font></td>

           <form method=post action="../common/LogDataList.jsp">
       <td align="right" colspan=3>
<%if (userOpsuper.equals("Y")) { %>
                <input name="logid" type="hidden" value=<%=logSPLabor%>>
                <input value=日誌查詢 type=submit>
<%} %>
       </td>
            </form>
   </tr>

<form action="QrySPLaborMain.jsp" method="post" onsubmit="return checkPassnoEngname(this);">
   <tr >
       <td width=28% align=right>國籍：
       </td>
       <td width=20% >
           <select  name=lived style="HEIGHT: 22px; WIDTH: 100px">
<%for (int i = 0; i < natcodes.length; i++) {%>
                <option value=<%=natcodes[i]%>><%=natcodes[i]%>-<%=natnames[i]%></option>
<%}%>
            </select>
       </td>
       <td width=20% align=right >護照號碼：
       </td>
       <td width=32% ><input type=text name=idno>
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


<table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="570">
    <tr bgcolor="#FF9900">
      <td ><img src="../image/arrow.gif" alt="美化圖形">
        <font color="#FFFFFF">雇主查詢</font>
      </td>

            <form method=post action="../common/LogDataList.jsp">
            <td align="right">
<%if (userOpsuper.equals("Y")) { %>
                <input name="logid" type="hidden" value=<%=logSPVend%>>
                <input value=日誌查詢 type=submit>
<%} %>
            </td>
            </form>
    </tr>

<form action="QrySPVendMain.jsp" method="post" onsubmit="return checkName(this);">
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

      <td colspan=2 align=center>
          <input value=查詢 type=submit>
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