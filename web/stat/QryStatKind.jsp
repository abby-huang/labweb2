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
String citytitle = "";
int[][] labtot = new int[25][8];

String today = AbDate.getToday("/");
String now = AbDate.getNowTime(":");

//統計抬頭
String[] sernoTitle = { "總　　　　計"
                       ,"政府重大公共工程", "六行業十五種職業", "養護機構看護工"
                       ,"家庭看護工", "家庭幫傭", "外籍船員"
                       ,"六十八行業", "七十三行業", "陶瓷等六行業"
                       ,"新廠及擴充設備", "經加、科園區專案", "三Ｋ行業專案"
                       ,"重大投資製造業", "重大投資營造業", "七行業專案"
                       ,"製造業二年期滿重整", "非高科技製造業", "高科技製造業"
                       ,"特殊時程產業", "附加外籍勞工", "國內新增投資案"
                       ,"臺商回臺投資案", "外展看護工", "屠宰業"};


if ((con != null) && (con2 != null)) {
    stmt = con.createStatement();
    stmt2 = con2.createStatement();

    //縣市
    if (citycode.length() > 0) {
        qs = "select cityname from fpv_citym"
                + " where citytype='A' and citycode = " + AbSql.getEqualStr(citycode);
        rs = stmt.executeQuery(qs);
        if (rs.next()) citytitle = strCheckNull( rs.getString(1) ).trim().replaceAll("　+$", "");
        rs.close();
    }


    //從 timer 讀取資料
    qs = "select yymm,serno,serno2,prmtnati,sum(stay_m + stay_f) from fpv_timer"
        + " where placcity = " + AbSql.getEqualStr(citycode2)
        + " and yymm = " + AbSql.getEqualStr(startdate)
        + " group by yymm,serno,serno2,prmtnati"
        + " order by yymm,serno,serno2,prmtnati";
    rs = stmt2.executeQuery(qs);

if (debug) out.print(qs);
    for (int i = 0; i < 20; i++) {
        for (int j = 0; j < 7; j++) labtot[i][j] = 0;
    }

    while (rs.next()) {
        String serno = AbString.leftJustify(rs.getString(2), 2);
        String serno2 = AbString.leftJustify(rs.getString(3), 3);

        //找出對應欄
        int y;
        if (serno.substring(0,2).equals("01")) y = 1;
        else if (serno.substring(0,2).equals("02")) y = 2;
        else if (serno.substring(0,2).equals("03")) {
            if (serno2.substring(2,3).equals("F")) y = 3;
            else y = 4;
        } else if (serno.substring(0,2).equals("04")) y = 5;
        else if (serno.substring(0,2).equals("05")) y = 6;
        else if (serno.substring(0,2).equals("06")) y = 7;
        else if (serno.substring(0,2).equals("07")) y = 8;
        else if (serno.substring(0,2).equals("08")) y = 9;
        else if (serno.substring(0,2).equals("09")) y = 10;
        else if (serno.substring(0,2).equals("10")) y = 11;
        else if (serno.substring(0,2).equals("11")) y = 12;
        else if (serno.substring(0,2).equals("12")) y = 13;
        else if (serno.substring(0,2).equals("13")) y = 14;
        else if (serno.substring(0,2).equals("14")) y = 15;
        else if (serno.substring(0,2).equals("15")) y = 16;
        else if (serno.substring(0,2).equals("16")) y = 17;
        else if (serno.substring(0,2).equals("17")) y = 18;
        else if (serno.substring(0,2).equals("18")) y = 19;
        else if (serno.substring(0,2).equals("19")) y = 20;
        else if (serno.substring(0,2).equals("20")) y = 21;
        else if (serno.substring(0,2).equals("21")) y = 22;
        else if (serno.substring(0,2).equals("22")) y = 23;
        else if (serno.substring(0,2).equals("23")) y = 24;
        else y = 0;

        if (y >= 0) {
            //找出國籍
            String natcode = strCheckNull( rs.getString(4) );
            int num = rs.getInt(5);
            labtot[y][7] += num;
            labtot[0][7] += num;
            boolean found = false;
            for (int i = 0; i < natcodes.length; i++) {
                if ( natcode.equals(natcodes[i]) ) {
                    labtot[y][i] += num;
                    labtot[0][i] += num;
                    found = true;
                    break;
                }
            }
            if (!found) {
                labtot[y][6] += num;
                labtot[0][6] += num;
            }
        }
    }
    rs.close();
}
%>

<html>
<head>

<%@ include file="/include/HeaderTimeout.inc" %>

</head>

<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
</script>
<%}%>


<BODY bgcolor="#F9CD8A" >

<center>
<table width=100% border = 0>
    <tr>
        <td align=center><%=citytitle%>外國人在華人數（按開放項目別）
        </td>
    </tr>
    <tr>
        <td align=center>統計年月：<%=startdate.substring(0, 4)%>年<%=startdate.substring(4,6)%>月
        </td>
    </tr>
    <tr>
        <td align=left>查詢日期：<%=today%> - <%=now%>
        </td>
        <td align=right>單位：人
        </td>
    </tr>
</table>

<center>
<table width=100% border = 1 bgcolor=#F8BE67 bordercolor=#FF9900 >
<tr>
    <td rowspan=2 width=22% align=center>項目別</td>
    <td colspan=2 align=center>總計</td>
    <td colspan=2 align=center>菲律賓</td>
    <td colspan=2 align=center>泰國</td>
    <td colspan=2 align=center>馬來西亞</td>
    <td colspan=2 align=center>印尼</td>
    <td colspan=2 align=center>越南</td>
    <td colspan=2 align=center>蒙古</td>
    <td colspan=2 align=center>其他</td>
</tr>

<tr>
    <td colspan=2 width=8% align=center>人數</td>
    <td width=6% align=center>人數</td>
    <td width=4% align=center>％</td>
    <td width=6% align=center>人數</td>
    <td width=4% align=center>％</td>
    <td width=6% align=center>人數</td>
    <td width=4% align=center>％</td>
    <td width=6% align=center>人數</td>
    <td width=4% align=center>％</td>
    <td width=6% align=center>人數</td>
    <td width=4% align=center>％</td>
    <td width=6% align=center>人數</td>
    <td width=4% align=center>％</td>
    <td width=6% align=center>人數</td>
    <td width=4% align=center>％</td>
</tr>


<%

for (int i = 0; i < labtot.length; i++) {
    int p0 = 0;
    int p1 = 0;
    int p2 = 0;
    int p3 = 0;
    int p4 = 0;
    int p5 = 0;
    int p6 = 0;
    if (labtot[i][7] > 0) {
        p0 = labtot[i][0] * 100 / labtot[i][7];
        p1 = labtot[i][1] * 100 / labtot[i][7];
        p2 = labtot[i][2] * 100 / labtot[i][7];
        p3 = labtot[i][3] * 100 / labtot[i][7];
        p4 = labtot[i][4] * 100 / labtot[i][7];
        p5 = labtot[i][5] * 100 / labtot[i][7];
        p6 = labtot[i][6] * 100 / labtot[i][7];
    }
%>

<tr>
    <td align=left><%=sernoTitle[i]%></td>
    <td colspan=2 align=right><%=labtot[i][7]%></td>
    <td align=right><%=labtot[i][1]%></td>
    <td align=right><%=p1%></td>
    <td align=right><%=labtot[i][3]%></td>
    <td align=right><%=p3%></td>
    <td align=right><%=labtot[i][2]%></td>
    <td align=right><%=p2%></td>
    <td align=right><%=labtot[i][0]%></td>
    <td align=right><%=p0%></td>
    <td align=right><%=labtot[i][4]%></td>
    <td align=right><%=p4%></td>
    <td align=right><%=labtot[i][5]%></td>
    <td align=right><%=p5%></td>
    <td align=right><%=labtot[i][6]%></td>
    <td align=right><%=p6%></td>
</tr>

<%
}
%>

</table>

</center>


<%
//關閉連線
stmt.close();
stmt2.close();
if (con != null) con.close();
if (con2 != null) con2.close();
%>

</BODY>
</HTML>