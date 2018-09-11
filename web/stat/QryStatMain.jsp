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

//定義變數
String errMsg = "";
Connection con = null;
Connection con2 = null;


//取得輸入資料
String statkind = strCheckNull( request.getParameter("statkind") );
String citycode = strCheckNull( request.getParameter("citycode") );
String startdate = strCheckNull( request.getParameter("startdate") );
String enddate = strCheckNull( request.getParameter("enddate") );
if (enddate.length() == 0) enddate = startdate;

//檢查資料
String startdatechk = startdate + "01";
String enddatechk = enddate + "01";
if (!AbDate.isValidDate(startdatechk) || !AbDate.isValidDate(enddatechk)) {
    errMsg = "日期輸入錯誤，請重新輸入";
}
//檢查區間
if ((errMsg.length() == 0) && (startdate.compareTo(enddate) > 0)) {
    errMsg = "日期區間輸入錯誤，請重新輸入";
}
if (errMsg.length() == 0) {
    String today = AbDate.getTodayYYYYMMDD();
    int ytoday = AbString.zerostrToInt( today.substring(0, 4) );
    int mtoday = AbString.zerostrToInt( today.substring(4, 6) );
    int dtoday = AbString.zerostrToInt( today.substring(6, 8) );
    int yenddatechk = AbString.zerostrToInt( enddatechk.substring(0, 4) );
    int menddatechk = AbString.zerostrToInt( enddatechk.substring(4, 6) );
    int denddatechk = AbString.zerostrToInt( enddatechk.substring(6, 8) );
    //檢查當月
    if ((yenddatechk*12+menddatechk) >= (ytoday*12+mtoday)) {
        errMsg = "您所輸入的月份目前尚無法提供統計資訊，請重新輸入";
    }
    int minday = 21;
    if (errMsg.length() == 0) {
        if (((yenddatechk*12+menddatechk+1) == (ytoday*12+mtoday)) && (dtoday <= minday)) {
            errMsg = "因資料庫轉置之因素，每月" + minday + "日之後方可查詢到前一個月份的統計資訊，不便之處敬請見諒！請重新輸入。";
        }
    }
}

//執行
if (errMsg.length() == 0) {
    try {
        //建立連線
        con = getConnection( session );
        con2 = getConnection( session );
        if ((con == null) || (con2 == null))
            errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
        else {
            con2.close();

            Statement stmt = con.createStatement();

            //縣市轄區
            String citytitle = "";
            if (citycode.length() > 0) {
                String qs = "select cityname from fpv_citym"
                        + " where citytype='A' and citycode = " + AbSql.getEqualStr(citycode);
                ResultSet rs = stmt.executeQuery(qs);
                if (rs.next()) citytitle = strCheckNull( rs.getString(1) ).trim().replaceAll("　+$", "");
                rs.close();
            }

            String srchdata = "";
            if (statkind.equals("01")) srchdata = "【開放項目別統計】";
            else if (statkind.equals("02")) srchdata = "【國籍別人數統計】";
            else if (statkind.equals("03")) srchdata = "【在華人數統計】";
            srchdata += "，縣市轄區：" + citytitle;
            srchdata += "，統計年月：" + startdate + "~" + enddate;

            //寫入日誌檔
            common.Comm.logOpData(stmt, userData, "Stat", srchdata, userAddr);
            stmt.close();
            con.close();



            //startdate = (Integer.parseInt( startdate.substring(0, 4) ) - 1911) + startdate.substring(4, 6);
            //enddate = (Integer.parseInt( enddate.substring(0, 4) ) - 1911) + enddate.substring(4, 6);
            session.setAttribute("citycode", citycode);
            session.setAttribute("startdate", startdate);
            session.setAttribute("enddate", enddate);


            if (statkind.equals("01"))
                response.sendRedirect("QryStatKind.jsp");
            else if (statkind.equals("02"))
                response.sendRedirect("QryStatNation.jsp");
            else if (statkind.equals("03"))
                response.sendRedirect("QryStatSex.jsp");
        }
    } catch (Exception e) {
        errMsg = "日期輸入錯誤，請重新輸入";
    }
}

%>


<html>
<head>
<%@ include file="/include/HeaderTimeout.inc" %>
</head>


<BODY bgcolor="#F9CD8A" text="#990000" leftmargin="0" marginheight="0" marginwidth="0">

<center>
<br><br>
<%=errMsg%>
<br><br>
<a href="QryStat.jsp" title="重新查詢">重新查詢</a>

</center>

</body>
</html>
