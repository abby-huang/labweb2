<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "雙語/廚師人員查詢 - 詳細資料";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpblue.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
String errMsg = "";
Connection conn = null;
conn = getConnection( session );
Statement stmt = conn.createStatement();
Statement stmt2 = conn.createStatement();
ResultSet rs, rs2;
String qs;

//取得輸入資料
String lived = strCheckNull( request.getParameter("lived") );
String idno = strCheckNull( request.getParameter("idno") );

//建立連線
conn = getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

//基本詳細 splab_splabom
String engname = "", chiname = "", sex = "", birthday = "";
qs = "select * from splab_splabom where lived=" + AbSql.getEqualStr(lived)
        + " and idno=" + AbSql.getEqualStr(idno);
rs = stmt.executeQuery(qs);
if (rs.next()) {
    engname = AbString.rtrimCheck( rs.getString("engname") );
    chiname = AbString.rtrimCheck( rs.getString("chiname") );
    sex = AbString.rtrimCheck( rs.getString("sex") );
    birthday = AbString.rtrimCheck( rs.getString("birthday") );
}
rs.close();

//工作資料 splab_splabod
String regno = "", wkadseq = "", wkaddr = "", citycode = "", emplcode = "";
qs = "select * from splab_splabod where lived=" + AbSql.getEqualStr(lived)
        + " and idno=" + AbSql.getEqualStr(idno)
        + " and wrkbdate is not null and bywho in ('A','B','D','O','Q')"
        + " order by wrkbdate desc";
rs2 = stmt2.executeQuery(qs);
if (rs2.next()) {
    regno = AbString.rtrimCheck( rs2.getString("regno") );
    wkadseq = AbString.rtrimCheck( rs2.getString("wkadseq") );
    wkaddr = AbString.rtrimCheck( rs2.getString("wkaddr") );
    citycode = AbString.rtrimCheck( rs2.getString("citycode") );
    emplcode = AbString.rtrimCheck( rs2.getString("emplcode") );
}
rs2.close();

//雇主資料 splab_spvendm
String vendname = "", vendtel = "";
qs = "select * from splab_spvendm where regno=" + AbSql.getEqualStr(regno)
        + " and wkadseq=" + AbSql.getEqualStr(wkadseq);
rs2 = stmt2.executeQuery(qs);
if (rs2.next()) {
    vendname = AbString.rtrimCheck( rs2.getString("vendname") );
    vendtel = AbString.rtrimCheck( rs2.getString("vendtel") );
}
rs2.close();



////////////////////////////////////////////////////////////////////////////////
//最新體檢
String chktype = "", chkdate = "", chkresult = "", alwresult = "", rptdate = "", offtime = "", offrpt = "";
boolean found = false;
//labdyn_healthchk
qs = "select * from labdyn_healthchk"
        + " where natcode = " + AbSql.getEqualStr( lived )
        + " and passno = " + AbSql.getEqualStr( idno )
        + " order by chkdate desc";
rs = stmt.executeQuery(qs);
if (rs.next()) {
    found = true;
    chktype = AbString.rtrimCheck( rs.getString("chktype") );
    chkdate = AbString.rtrimCheck( rs.getString("chkdate") );
    chkresult = AbString.rtrimCheck( rs.getString("chkresult") );
    alwresult = AbString.rtrimCheck( rs.getString("alwresult") );
    rptdate = AbString.rtrimCheck( rs.getString("rptdate") );
    offtime = AbString.rtrimCheck( rs.getString("offtime") );
    offrpt = AbString.rtrimCheck( rs.getString("offrpt") );
}
rs.close();

if (!found) {
    //labdyn_healthchksp
    qs = "select * from labdyn_healthchksp"
            + " where natcode = " + AbSql.getEqualStr( lived )
            + " and passno = " + AbSql.getEqualStr( idno )
            + " order by chkdate desc";
    rs = stmt.executeQuery(qs);
    if (rs.next()) {
        found = true;
        chktype = AbString.rtrimCheck( rs.getString("chktype") );
        chkdate = AbString.rtrimCheck( rs.getString("chkdate") );
        chkresult = AbString.rtrimCheck( rs.getString("chkresult") );
        alwresult = AbString.rtrimCheck( rs.getString("alwresult") );
        rptdate = AbString.rtrimCheck( rs.getString("rptdate") );
        offtime = AbString.rtrimCheck( rs.getString("offtime") );
        offrpt = AbString.rtrimCheck( rs.getString("offrpt") );
    }
    rs.close();
}

if (chktype.equals("0")) chktype = "初次入境";
else if (chktype.equals("1")) chktype = "六個月定期";
else if (chktype.equals("2")) chktype = "十二個月定期";
else if (chktype.equals("3")) chktype = "十八個月定期";
else if (chktype.equals("4")) chktype = "二十四個月定期";
else if (chktype.equals("5")) chktype = "三十個月定期";
else if (chktype.equals("6")) chktype = "三十六個月定期";
else if (chktype.equals("7")) chktype = "四十二個月定期";
else if (chktype.equals("8")) chktype = "其他";
else if (chktype.equals("A")) chktype = "初次入境複檢";
else if (chktype.equals("B")) chktype = "六個月定期複檢";
else if (chktype.equals("C")) chktype = "十二個月定期複檢";
else if (chktype.equals("D")) chktype = "十八個月定期複檢";
else if (chktype.equals("E")) chktype = "二十四個月定期複檢";
else if (chktype.equals("F")) chktype = "三十個月定期複檢";
else if (chktype.equals("G")) chktype = "三十六個月定期複檢";
else if (chktype.equals("H")) chktype = "四十二個月定期複檢";
else if (chktype.equals("I")) chktype = "補充健檢";
else chktype = "";

if (chkresult.equals("0")) chkresult = "合格";
else if (chkresult.equals("1")) chkresult = "不合格";

if (alwresult.equals("0")) alwresult = "准予核備";
else if (alwresult.equals("2")) alwresult = "不予核備";

if (offtime.equals("0")) offtime = "否";
else if (offtime.equals("1")) offtime = "是";

if (offrpt.equals("0")) offrpt = "否";
else if (offrpt.equals("1")) offrpt = "是";



////////////////////////////////////////////////////////////////////////////////
//最近居留
String resnum = "", resvalid = "", resstatus = "", misstatus = "", escapedate = "",
        crimedate = "", reentrydate = "", resaddr = "";
qs = "select * from labdyn_resident"
        + " where natcode = " + AbSql.getEqualStr( lived )
        + " and passno = " + AbSql.getEqualStr( idno )
        + " order by chng_date desc";
rs = stmt.executeQuery(qs);
if (rs.next()) {
    if (!"D".equals(AbString.rtrimCheck( rs.getString("chng_id") ))) {
        resnum = AbString.rtrimCheck( rs.getString("resnum") );
        resvalid = AbString.rtrimCheck( rs.getString("resvalid") );
        resstatus = AbString.rtrimCheck( rs.getString("resstatus") );
        misstatus = AbString.rtrimCheck( rs.getString("misstatus") );
        escapedate = AbString.rtrimCheck( (String)rs.getString("escapedate") );
        crimedate = AbString.rtrimCheck( (String)rs.getString("crimedate") );
        reentrydate = AbString.rtrimCheck( (String)rs.getString("reentrydate") );
        resaddr = AbString.rtrimCheck( rs.getString("resaddr") ).replace("　", "");
    }

    if (resstatus.equals("1")) resstatus = "改變中國籍";
    else if (resstatus.equals("2")) resstatus = "在台";
    else if (resstatus.equals("3")) resstatus = "離台";
    else if (resstatus.equals("4")) resstatus = "死亡";
    else if (resstatus.equals("5")) resstatus = "註銷居留證";
    else if (resstatus.equals("6")) resstatus = "棄原國籍、取我國籍";
    else resstatus = "";

    if (misstatus.equals("1")) misstatus = "關係人報案";
    else if (misstatus.equals("2")) misstatus = "警局主動註記";
    else if (misstatus.equals("3")) misstatus = "雇主書面通知";
    else if (misstatus.equals("4")) misstatus = "涉案註記協尋";
    else if (misstatus.equals("5")) misstatus = "服務站主動註記";
    else if (misstatus.equals("6")) misstatus = "專勤隊主動註記";
    else misstatus = "";

    if (escapedate.equals("19000101")) escapedate = "";
    if (crimedate.equals("19000101")) crimedate = "";
    if (reentrydate.equals("19000101")) reentrydate = "";
}
rs.close();
%>

<html>
<head>

<%@ include file="/include/HeaderTimeout.inc" %>

</head>

<body bgcolor="#F9CD8A">

<table border=0 width=600>
    <form action="">
    <td align=left width=10%>
        <input type=button value="回上一頁" onClick="javascript:history.back()">
    </td>
    </form>

    <td width=90%>
    </td>
</table>


<!-- 基本資料 ------------------------------------------------------------------>
<b>※外勞現況基本資料表</b>
<table width=600 border=1>
    <tr>
      <td width=15% align=center><b>國　　籍</b></td>
      <td width=36%><%=strCheckNullHtml(common.Comm.getCodeTitle(stmt2, lived, "fpv_natim", "naticode", "natiname"))%></td>
      <td width=20% align=center><b>護照號碼</b></td>
      <td width=29%><%=strCheckNullHtml(idno)%></td>
    </tr>
    <tr>
      <td align=center><b>姓　　名</b></td>
      <td colspan=3><%=strCheckNullHtml(engname)%></td>
    </tr>
    <tr>
      <td align=center><b>行職業別</b></td>
      <td colspan=3><%=strCheckNullHtml(common.Comm.getCodeTitle(stmt2,emplcode,"fpv_emplm","emplcode","occuname"))%></td>
    </tr>
    <tr>
      <td align=center><b>性　　別</b></td>
      <td ><%=strCheckNullHtml((sex.equals("M") ? "男" : "女"))%></td>
      <td align=center><b>出生日期</b></td>
      <td ><%=strCheckNullHtml(AbDate.fmtDate(birthday, "-"))%></td>
    </tr>
    <tr>
      <td align=center><b>雇　　主</b></td>
      <td><%=strCheckNullHtml(vendname) + " (" + regno + ")"%></td>
      <td align=center><b>電　　話</b></td>
      <td><%=strCheckNullHtml(vendtel)%></td>
    </tr>
    <tr>
      <td align=center><b>核准工作地</b></td>
      <td colspan=3><%=strCheckNullHtml(wkaddr)%></td>
    </tr>

    <tr>
      <td align=center ><b>工作地<br>縣市轄區</b></td>
      <td colspan=3><%=strCheckNullHtml(common.Comm.getCodeTitle(stmt2, citycode, "fpv_zipcitym", "citycode", "cityname"))%></td>
    </tr>
    <tr>
      <td align=center><b>體檢日期</b></td>
      <td><%=strCheckNullHtml(AbDate.fmtDate(chkdate, "-"))%></td>
      <td align=center><b>行蹤不明日期</b></td>
      <td ><%=strCheckNullHtml(AbDate.fmtDate(escapedate, "-"))%></td>
    </tr>

</table>
<font color='ff0000'><b>下方之「勞動力發展署提供之最近聘僱資訊」表，可查看該外勞過去之聘僱歷程。</b></font>
<p>


<!-- 最近簽證 ------------------------------------------------------------------>
<%
qs = "select * from labdyn_visa"
        + " where natcode = " + AbSql.getEqualStr( lived )
        + " and passno = " + AbSql.getEqualStr( idno )
        + " order by visadate desc";
rs = stmt.executeQuery(qs);
if (rs.next()) {
    String visadate = AbString.rtrimCheck( rs.getString("visadate") );
    String prmtno = AbString.rtrimCheck( rs.getString("prmtno") );
    String prmtdate = AbString.rtrimCheck( rs.getString("prmtdate") );
    String canceldate = AbString.rtrimCheck( rs.getString("canceldate") );

%>

<b>※駐<%=strCheckNullHtml( common.Comm.getCodeTitle(stmt2, lived, "fpv_natim", "naticode", "natiname") )%>代表處最近之簽證如下：本資料由外交部領務局提供，資料不一致時請以外交部領務局為準</b>
<table border=1>
    <tr>
        <th ROWSPAN=2 width=80><H3>簽證</TH>
        <th Width=100>簽發日</TH>
        <th Width=100>核准文號</TH>
        <th Width=100>核准函日期</TH>
        <th Width=120>註銷簽證日期</TH>
    </tr>
    <tr>
        <td Width=100><%=strCheckNullHtml( AbDate.fmtDate(visadate, "-") )%></td>
        <td><%=strCheckNullHtml( prmtno )%></td>
        <td><%=strCheckNullHtml( AbDate.fmtDate(prmtdate, "-") )%></td>
        <td><%=strCheckNullHtml( AbDate.fmtDate(canceldate, "-") )%></td>
    </tr>
</Table>
<P>

<%
}
rs.close();
%>


<!-- 最近入出境 ----------------------------------------------------------------->
<%
String lastindate = "", lastoutdate = "";
//入境日
qs = "select inoutdate from labdyn_labinout"
        + " where natcode = " + AbSql.getEqualStr( lived )
        + " and passno = " + AbSql.getEqualStr( idno )
        + " and kindcode = '1'"
        + " and not chng_id = 'D'"
        + " order by inoutdate desc";
rs = stmt.executeQuery(qs);
if (rs.next()) {
    lastindate = AbString.rtrimCheck( rs.getString("inoutdate") );
}
rs.close();

//出境日
qs = "select inoutdate from labdyn_labinout"
        + " where natcode = " + AbSql.getEqualStr( lived )
        + " and passno = " + AbSql.getEqualStr( idno )
        + " and kindcode = '2'"
        + " and not chng_id = 'D'"
        + " order by inoutdate desc";
rs = stmt.executeQuery(qs);
if (rs.next()) {
    lastoutdate = AbString.rtrimCheck( rs.getString("inoutdate") );
    if (lastoutdate.compareTo(lastindate) <= 0) lastoutdate = "";
}
rs.close();

%>

<B>※移民署提供之最近入出境資訊如下：本資料由移民署提供，資料不一致時請以內政部移民署為準
<table border=1>
    <tr>
        <th ROWSPAN=2 Width=80><H4>入出境</TH>
        <th Width=100>入境日期</TH>
        <th Width=100>出境日期</TH>
    </tr>
    <tr>
        <td><%=strCheckNullHtml( AbDate.fmtDate(lastindate, "-") )%></td>
        <td><%=strCheckNullHtml( AbDate.fmtDate(lastoutdate, "-") )%></td>
    </tr>
</Table>
<P>


<!-- 最新體檢 ------------------------------------------------------------------>
<B>※衛生福利部提供之最新體檢資訊如下：本資料由衛生福利部提供，資料不一致時請以衛生福利部為準
<table border=1>
    <tr>
        <th Width=180>體檢種類</TH>
        <th Width=100>體檢日期</TH>
        <th Width=100>總結果</TH>
        <th Width=100>核備結果</TH>
        <th Width=100>體檢<br>報告日</TH>
        <th Width=10%>逾期<br>體檢</TH>
        <th Width=10%>逾期<br>報備</TH>
    </tr>
    <tr>
        <td><%=strCheckNullHtml( chktype )%></td>
        <td><%=strCheckNullHtml( AbDate.fmtDate(chkdate, "-") )%></td>
        <td><%=strCheckNullHtml( chkresult )%></td>
        <td><%=strCheckNullHtml( alwresult )%></td>
        <td><%=strCheckNullHtml( AbDate.fmtDate(rptdate, "-") )%></td>
        <td><%=strCheckNullHtml( offtime )%></td>
        <td><%=strCheckNullHtml( offrpt )%></td>
    </tr>
</Table>
<P>


<!-- 最近居留 ------------------------------------------------------------------>
<%
if (resnum.length() > 0) {
%>
<B>※移民署提供之最近居留資訊如下：本資料由移民署提供，資料不一致時請以內政部移民署為準
<table border=1>
    <tr><th Width=10%>居留<br>證號</TH>
        <th Width=20%>居留<br>效期</TH>
        <th Width=10%>居留<br>狀況</TH>
        <th Width=22%>行方不明</TH>
        <th Width=14%>行蹤不明<br>日期</TH>
        <th Width=10%>查獲<br>日期</TH>
        <th Width=14%>重入境<br>期限</TH>
    </tr>
    <tr>
        <td><%=strCheckNullHtml( resnum )%></td>
        <td><%=strCheckNullHtml( AbDate.fmtDate(resvalid, "-") )%></td>
        <td><%=strCheckNullHtml( resstatus )%></td>
        <td><%=strCheckNullHtml( misstatus )%></td>
        <td><%=strCheckNullHtml( AbDate.fmtDate(escapedate, "-") )%></td>
        <td><%=strCheckNullHtml( AbDate.fmtDate(crimedate, "-") )%></td>
        <td><%=strCheckNullHtml( AbDate.fmtDate(reentrydate, "-") )%></td>
    </tr>
    <tr>
        <td COLSPAN=2 ALIGN=CENTER><H4>居 留 地 址</td>
        <td COLSPAN=6><%=strCheckNullHtml( resaddr )%></td>
    </tr>
</Table>
<P>

<%
}
%>


<!-- 聘僱資料 ------------------------------------------------------------------>
<B>※勞動力發展署提供之最近聘僱資訊如下：
<table border=1>
    <tr>
        <th Width=80>聘僱文號</TH>
        <th Width=90>聘僱許可日</TH>
        <th Width=80>入境日期</TH>
        <th Width=200>雇主</TH>
        <th Width=100>工作起迄日</TH>
    </tr>

<%
qs = "select * from splab_splabod"
        + " where lived = " + AbSql.getEqualStr( lived )
        + " and idno = " + AbSql.getEqualStr( idno )
        + " and bywho in ('A','B','D','O','Q') order by lived, idno, licdate desc";
rs = stmt.executeQuery(qs);
while (rs.next()) {
    String licwpno = AbString.rtrimCheck( rs.getString("licwpno") );
    String licdate = AbString.rtrimCheck( rs.getString("licdate") );
    String indate = AbString.rtrimCheck( rs.getString("indate") );
    String wrkbdate = AbString.rtrimCheck( rs.getString("wrkbdate") );
    String wrkedate = AbString.rtrimCheck( rs.getString("wrkedate") );

    String regno2 = AbString.rtrimCheck( rs.getString("regno") );
    String wkadseq2 = AbString.rtrimCheck( rs.getString("wkadseq") );

    //雇主資料 splab_spvendm
    String vendname2 = "";
    qs = "select * from splab_spvendm where regno=" + AbSql.getEqualStr(regno2)
            + " and wkadseq=" + AbSql.getEqualStr(wkadseq2);
    rs2 = stmt2.executeQuery(qs);
    if (rs2.next()) {
        vendname2 = AbString.rtrimCheck( rs2.getString("vendname") );
    }
    rs2.close();
%>
    <tr>
        <td><%=strCheckNullHtml( licwpno )%></td>
        <td><%=strCheckNullHtml( AbDate.fmtDate(licdate, "-") )%></td>
        <td><%=strCheckNullHtml( AbDate.fmtDate(indate, "-") )%></td>
        <td><%=strCheckNullHtml( vendname2 + "(" + regno2 + ")")%></td>
        <td><%=strCheckNullHtml( AbDate.fmtDate(wrkbdate, "-") )%>～<br><%=strCheckNullHtml( AbDate.fmtDate(wrkedate, "-") )%></td>
    </tr>
<%
}
rs.close();
%>

</Table>
<P>


<!-- 廢止聘僱 ------------------------------------------------------------------>
<B>※勞動力發展署提供之廢止聘僱資訊如下：
<table border=1 Width=720>
    <tr>
        <th Width=80>撤銷文號</TH>
        <th Width=80>撤銷日期</TH>
        <th Width=80>通知日期</TH>
<!--取消顯示通知單位
        <th Width=160>通知單位</TH>
-->
        <th Width=80>發生日期</TH>
        <th Width=160>撤銷案由<br>(狀況內容)</TH>
    </tr>

<%
qs = "select * from splab_spexpir"
        + " where lived = " + AbSql.getEqualStr( lived )
        + " and idno = " + AbSql.getEqualStr( idno )
        + " order by lived, idno, expirdate desc";
rs = stmt.executeQuery(qs);
while (rs.next()) {
    String expirwpno = AbString.rtrimCheck( rs.getString("expirwpno") );
    String expirdate = AbString.rtrimCheck( rs.getString("expirdate") );
    String knowdate = AbString.rtrimCheck( rs.getString("knowdate") );
    String knowcode = AbString.rtrimCheck( rs.getString("knowcode") );
    String happdate = AbString.rtrimCheck( rs.getString("happdate") );
    String happcode = AbString.rtrimCheck( rs.getString("happcode") );

    //通知日期
    rs2 = stmt2.executeQuery("select * from fpv_wprec where wpinno = " + AbSql.getEqualStr(expirwpno));
    if (rs2.next()) {
        knowdate = AbString.rtrimCheck( rs2.getString("wpindate") );
    }
    rs2.close();

    String knowcode_desc = "";
    rs2 = stmt2.executeQuery("select * from labdyn_dynalm where dynacode = " + AbSql.getEqualStr(knowcode));
    if (rs2.next()) {
        knowcode_desc = AbString.rtrimCheck( rs2.getString("dynadesc") );
    }
    rs2.close();

    String happcode_desc = "";
    rs2 = stmt2.executeQuery("select * from labdyn_dynalm where dynacode = " + AbSql.getEqualStr(happcode));
    if (rs2.next()) {
        happcode_desc = AbString.rtrimCheck( rs2.getString("dynadesc") );
    }
    rs2.close();

%>
    <tr>
        <td><%=strCheckNullHtml(expirwpno)%></td>
        <td><%=strCheckNullHtml(AbDate.fmtDate(expirdate, "-"))%></td>
        <td><%=strCheckNullHtml(AbDate.fmtDate(knowdate, "-"))%></td>
<!--取消顯示通知單位
        <td><%=strCheckNullHtml("(" + knowcode + ")" + knowcode_desc)%></td>
-->
        <td><%=strCheckNullHtml(AbDate.fmtDate(happdate, "-"))%></td>
        <td><%=strCheckNullHtml("(" + happcode + ")" + happcode_desc)%></td>
    </tr>
<%
}
rs.close();
%>

</table>
<P>


<%
//關閉連線
stmt.close();
stmt2.close();
if (conn != null) conn.close();
%>


</body>
</html>
