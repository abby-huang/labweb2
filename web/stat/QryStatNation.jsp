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
String pageHeader = "統計資訊";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpblue.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//取得輸入資料
String citycode = strCheckNull((String)session.getAttribute("citycode"));
String startdate = strCheckNull((String)session.getAttribute("startdate"));
String enddate = strCheckNull((String)session.getAttribute("enddate"));

//對照 citycode
String citycode2 = "00";
if (citycode.equals("01")) citycode2 = "22";
else if (citycode.equals("02")) citycode2 = "23";
else if (citycode.equals("03")) citycode2 = "01";
else if (citycode.equals("04")) citycode2 = "03";
else if (citycode.equals("05")) citycode2 = "04";
else if (citycode.equals("06")) citycode2 = "18";
else if (citycode.equals("07")) citycode2 = "05";
else if (citycode.equals("08")) citycode2 = "17";
else if (citycode.equals("09")) citycode2 = "06";
else if (citycode.equals("10")) citycode2 = "19";
else if (citycode.equals("11")) citycode2 = "07";
else if (citycode.equals("12")) citycode2 = "09";
else if (citycode.equals("13")) citycode2 = "10";
else if (citycode.equals("14")) citycode2 = "20";
else if (citycode.equals("15")) citycode2 = "11";
else if (citycode.equals("16")) citycode2 = "21";
else if (citycode.equals("17")) citycode2 = "12";
else if (citycode.equals("18")) citycode2 = "13";
else if (citycode.equals("19")) citycode2 = "14";
else if (citycode.equals("20")) citycode2 = "15";
else if (citycode.equals("21")) citycode2 = "02";
else if (citycode.equals("22")) citycode2 = "16";
else if (citycode.equals("23")) citycode2 = "08";
else if (citycode.equals("24")) citycode2 = "24";
else if (citycode.equals("25")) citycode2 = "25";


//定義變數
String errMsg = "";
Connection con = null;
Connection con2 = null;

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
con2 = getConnection( session );
if (con2 == null) errMsg = "對不起! 無法開啟資料庫2，請通知系統人員。";

String qs = "";
Statement stmt = null;
Statement stmt2 = null;
ResultSet rs = null;

stmt = con.createStatement();
stmt2 = con2.createStatement();

//縣市
String citytitle = "";
if (citycode.length() > 0) {
    qs = "select cityname from fpv_citym"
            + " where citytype='A' and citycode = " + AbSql.getEqualStr(citycode);
    rs = stmt.executeQuery(qs);
    if (rs.next()) citytitle = strCheckNull( rs.getString(1) ).trim().replaceAll("　+$", "");
    rs.close();
}

//從 timer 讀取資料
qs = "select yymm,prmtnati,sum(stay_m + stay_f) from fpv_timer"
    + " where placcity = " + AbSql.getEqualStr(citycode2)
    + " and yymm >= " + AbSql.getEqualStr(startdate)
    + " and yymm <= " + AbSql.getEqualStr(enddate)
    + " group by yymm,prmtnati"
    + " order by yymm,prmtnati";
rs = stmt2.executeQuery(qs);

%>

<html>
<head>

<%@ include file="/include/HeaderTimeout.inc" %>

</head>


<BODY bgcolor="#F9CD8A" >

<center>
<table width=100% border = 0>
    <tr>
        <td align=center><%=citytitle%>外國人在華人數（按國籍別分）
        </td>
    </tr>
    <tr>
        <td align=center>統計年月區間：<%=startdate.substring(0, 4)%>年<%=startdate.substring(4,6)%>月
                                    至<%=enddate.substring(0, 4)%>年<%=enddate.substring(4,6)%>月止
        </td>
    </tr>
    <tr>
        <td align=right>單位：人
        </td>
    </tr>
</table>

<center>
<table width=100% border = 1 bgcolor=#F8BE67 bordercolor=#FF9900 >
<tr>
    <td width=16% align=center>統計年月</td>
    <td width=12% align=center>人數總計</td>
    <td width=12% align=center>菲律賓</td>
    <td width=12% align=center>泰國</td>
    <td width=12% align=center>馬來西亞</td>
    <td width=12% align=center>印尼</td>
    <td width=12% align=center>越南</td>
    <td width=12% align=center>蒙古</td>
</tr>

<%
boolean hasdata = rs.next();
String oyymm = strCheckNull( rs.getString(1) );
while (hasdata) {
    int[] labnum = {0, 0, 0, 0, 0, 0, 0};
    String yymm = strCheckNull( rs.getString(1) );
    while (oyymm.equals(yymm)) {
        String natcode = strCheckNull( rs.getString(2) );
        int num = rs.getInt(3);
        //總計
        labnum[labnum.length-1] += num;
        for (int i = 0; i < natcodes.length; i++) {
            if ( natcode.equals(natcodes[i]) ) {
                //各國
                labnum[i] += num;
                break;
            }
        }
        hasdata = rs.next();
        if (hasdata) yymm = strCheckNull( rs.getString(1) );
        else yymm = "";
    }
%>

<tr>
    <td align=center><%=oyymm%></td>
    <td align=center><%=labnum[6]%></td>
    <td align=center><%=labnum[1]%></td>
    <td align=center><%=labnum[3]%></td>
    <td align=center><%=labnum[2]%></td>
    <td align=center><%=labnum[0]%></td>
    <td align=center><%=labnum[4]%></td>
    <td align=center><%=labnum[5]%></td>
</tr>

<%
    oyymm = yymm;
}
%>

</table>

</center>


<%
//關閉連線
rs.close();
stmt.close();
stmt2.close();
if (con != null) con.close();
if (con2 != null) con2.close();
%>

</BODY>
</HTML>