<%@ page errorPage="../ErrorPage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "雇主僱用專業外國人清冊";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpwhite.equals("Y") || !userOpdown.equals("Y")) {
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

function checkIllegal(frm)
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
        alert ("請輸入雇主名稱或雇主編號!");
        return false;
    }
}
</script>

</head>


<BODY bgcolor="#F9CD8A" text="#990000">
<center>
<table width="600" border="0" cellspacing="0" cellpadding="0" >
  <tr>
    <td align=center><img src="../image/qry_wfempbizdown.gif" alt="雇主僱用專業外國人清冊" >
    </td>
  </tr>
  <tr>
    <td align=center><img src="../image/line_main.gif" alt="美化圖形" >
    </td>
  </tr>
</table>


<table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="600">
   <tr bgcolor="#FF9900">
       <td colspan=2><img src="../image/arrow.gif" alt="美化圖形">
         <font color="#FFFFFF">雇主僱用專業外國人清冊</font>
       </td>


            <form method=post action="../common/LogDataList.jsp">
            <td align="right">
<%if (userOpsuper.equals("Y")) { %>
                <input name="logid" type="hidden" value=<%=logWfempList%>>
                <input value=日誌查詢 type=submit>
<%} %>
            </td>
            </form>
   </tr>

<form action="QryWfempListMain.jsp" method="post">
   <tr >
       <td align=right>案件授權單位：
       </td>
       <td colspan=3><select  name="type"  style="HEIGHT: 22px; WIDTH: 240px">
           <option value="1" selected>勞動力發展署</option>
           <option value="2">科學園區及加工出口區</option>
       </td>
   </tr>
   <tr bgcolor="#F8BE67">
       <td width="25%" align=right>縣市轄區：
       </td>
       <td width="75%" bgcolor="#F8BE67" colspan=2>
<%
//全區
if (userRegion.equals("*")) {
%>
                <select name=citycode  style="HEIGHT: 22px; WIDTH: 240px">
                    <option value=""></option>
<%
    qs = "SELECT citycode, cityname FROM fpv_citym"
        + " WHERE citytype='A'"
        + " AND (citycode > '00' AND citycode <= '25')"
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
                </select><%=userDivtitle%>
<%
    //單區
    } else {
%>
                <%=userDivtitle%>
                <input name="citycode" type="hidden" value=<%=userRegion%>>
<%
    }
}
%>
       </td>
   </tr>
   <tr bgcolor="#F8BE67">
       <td align=right>地址類別：
       </td>
       <td colspan=2 >
          <select name=addrtype style="FONT-FAMILY: 細明體, 標楷體; HEIGHT: 22px; WIDTH: 240px" size=1>
              <option value=1>雇主地址</option>
              <option value=2>工作地址</option>

          </select>
       <td colspan=2 >
       </td>
   </tr>
   <tr bgcolor="#F8BE67">
       <td align=right>行職業別：
       </td>
       <td colspan=2 >
              <select name=bizcode style="FONT-FAMILY: 細明體, 標楷體; HEIGHT: 22px; WIDTH: 240px" size=1>
<%
    qs = "SELECT distinct code_1,code_name FROM wcf_pubcoded"
        + " where code_item='02' and (" + fun_length + " (code_1) > 0)"
        + " and (code_2 is null or code_2 = '')"
        + " and (code_1 <> 'L')" //僑生
        + " ORDER BY code_1";
    rs = stmt.executeQuery(qs);
    while (rs.next()) {
%>
                    <option value=<%=rs.getString(1)%>><%=rs.getString(2)%></option>
<%
    }
    rs.close();
%>
              </select>
       </td>
   </tr>
   <tr bgcolor="#F8BE67">
       <td height="37">
       </td>
       <td colspan=2 >
              <input value=查詢 style="HEIGHT: 24px; WIDTH: 58px" type=submit name="submit">
       </td>
   </tr>
</table>
</form>

<table border=0 bgcolor="" bordercolor="" width="600">
    <tr>
        <td>清冊下載特別說明：<br>
            地址類別選擇工作地址時，可以查詢到在該縣市轄區工作的專業外國人，但因為清冊下載功能中必需查詢到雇主所聘用的有效及所有專業外國人，所以在下載檔案中也會同時將該雇主其他的專業外國人一併下載於該檔案中，使用者可以運用excel軟體將此下載檔案，選擇工作地排序就可得到真正於該縣市轄區的專業外國人。
        </td>
    </tr>
</tabel>




<%
//關閉連線
stmt.close();
if (con != null) con.close();
%>

</BODY>
</HTML>

