<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "專業外國人詳細資料";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpwhite.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
String errMsg = "";
Connection con = null;

//取得輸入資料
String tblcasem = strCheckNull((String)session.getAttribute("tblcasem"));
String tblengagerec = strCheckNull((String)session.getAttribute("tblengagerec"));
String tblexpirrec = strCheckNull((String)session.getAttribute("tblexpirrec"));
String natcode = strCheckNull( request.getParameter("natcode") );
String passno = strCheckNull( request.getParameter("passno") );

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

Statement stmt = con.createStatement();
Statement stmt2 = con.createStatement();
Statement stmt3 = con.createStatement();
ResultSet rs, rs2, rs3;

//從 laborm 讀取資料
String qs = "SELECT"
            + " naticode"
            + ",passno"
            + ",residence_id"
            + ",name_eng"
            + ",sex"
            + ",birthday"
            + ",domestic_address"
            + " from wcf_laborm"
            + " where naticode = " + AbSql.getEqualStr( natcode )
            + " and passno = " + AbSql.getEqualStr( passno );
rs = stmt.executeQuery(qs);
rs.next();

//response.getWriter().println(qs + "<BR>");

String residence_id = strCheckNull(rs.getString(3));
String laboename = strCheckNull(rs.getString(4));
String labosex = strCheckNull(rs.getString(5));
if (labosex.equals("M")) labosex = "男";
else if (labosex.equals("F")) labosex = "女";
String labobirt = strCheckNull(rs.getString(6));
String domestic_address = strCheckNull(rs.getString(7));
rs.close();

//讀取國籍
String natiname = "";
qs = "select natiname from fpv_natim where naticode = "
        + AbSql.getEqualStr(natcode);
rs = stmt.executeQuery(qs);
if (rs.next()) natiname = strCheckNull(rs.getString("natiname"));
rs.close();

%>

<html>
<head>

<%@ include file="/include/HeaderTimeout.inc" %>

</head>

<body bgcolor="#F9CD8A">

<table border=0 width=600>
    <td align=left width=10%>
    <form action="">
        <input type=button value="回上一頁" onClick="javascript:history.back()">
    </td>
    </form>

    <td width=90%>
    </td>
</table>

<table width=600 border=1>
<tr>
  <td width=15% align=center><b>國　　籍</b></td>
  <td width=18%><%=strCheckNullHtml( natiname )%></td>
  <td width=15% align=center><b>護照號碼</b></td>
  <td wdith=18%><%=strCheckNullHtml( passno )%></td>
  <td width=15% align=center><b>統一證號</b></td>
  <td wdith=19%><%=strCheckNullHtml( residence_id )%></td>
</tr>
<tr>
  <td align=center><b>姓　　名</b></td>
  <td colspan=5><%=strCheckNullHtml( laboename ).trim()%></td>
</tr>
<tr>
  <td align=center><b>性　　別</b></td>
  <td ><%=strCheckNullHtml( labosex )%></td>
  <td align=center><b>出生日期</b></td>
  <td colspan=3><%=fmtDate( strCheckNullHtml( labobirt ), "/" )%></td>
</tr>
<tr>
  <td align=center><b>居住地址</b></td>
  <td colspan=5><%=strCheckNullHtml(domestic_address).trim()%></td>
</tr>
</table>

<%
//聘僱資料
qs = "select m.*,vend_seq,appltype,applbusi,applbusid from " + tblengagerec + " m"
        + " left join " + tblcasem + " s on (s.case_sn = m.case_sn)"
        + " where naticode = " + AbSql.getEqualStr(natcode)
        + " and passno = " + AbSql.getEqualStr(passno)
        + " and rec_no = first_agree_no"
        + " order by m.disp_date desc";
qs = "select m.*,vend_seq,appltype,applbusi,applbusid from " + tblengagerec + " m, " + tblcasem + " s"
        + " where naticode = " + AbSql.getEqualStr(natcode)
        + " and passno = " + AbSql.getEqualStr(passno)
        + " and rec_no = first_agree_no"
        + " and (s.case_sn = m.case_sn and (s.current_status = '11' or s.current_status = '12'))"
        + " order by m.disp_date desc";
if (debug) out.println(qs+"</br>");
rs = stmt.executeQuery(qs);
while (rs.next()) {
    String licwpno = strCheckNull( rs.getString("rec_no") );
    String vend_seq = strCheckNull( rs.getString("vend_seq") );
    String prev_agree_no = strCheckNull( rs.getString("prev_agree_no") );
    String appltype = strCheckNull( rs.getString("appltype") );
    String applbusi = strCheckNull( rs.getString("applbusi") );
    String applbusid = strCheckNull( rs.getString("applbusid") );
    String work_address = strCheckNull( rs.getString("work_address") );
    // 雇主資料
    String vend_name_ch = "";
    String vend_addr = "";
    String vend_tel = "";
    if (vend_seq.length() > 0) {
        qs = "select * from wcf_vendm";
        qs += " where vend_seq = " + AbSql.getEqualStr(vend_seq);
        rs2 = stmt2.executeQuery(qs);
        if (rs2.next()) {
            vend_name_ch = strCheckNull(rs2.getString("vend_name_ch"));
            vend_addr = strCheckNull(rs2.getString("vend_addr"));
            vend_tel = strCheckNull(rs2.getString("vend_tel"));
        }
        rs2.close();
    }
    // 申請類別
    String typedesc = "";
    String busidesc = "";
    String busiddesc = "";
    qs = "select * from wcf_pubcoded"
            + " where code_item='02' and code_1 = " + AbSql.getEqualStr(appltype)
            + " and (code_2 is null or code_2 = '')"
            + " and (code_3 is null or code_3 = '')";
    rs2 = stmt2.executeQuery(qs);
    if (rs2.next()) typedesc = strCheckNull(rs2.getString("code_name"));
    rs2.close();
    // 申請項目
    qs = "select * from wcf_pubcoded"
            + " where code_item='02' and code_1 = " + AbSql.getEqualStr(appltype)
            + " and code_2 = " + AbSql.getEqualStr(applbusi)
            + " and (code_3 is null or code_3 = '')";
    rs2 = stmt2.executeQuery(qs);
    if (rs2.next()) busidesc = strCheckNull(rs2.getString("code_name"));
    rs2.close();
    // 申請細項
    qs = "select * from wcf_pubcoded"
            + " where code_item='02' and code_1 = " + AbSql.getEqualStr(appltype)
            + " and code_2 = " + AbSql.getEqualStr(applbusi)
            + " and code_3 = " + AbSql.getEqualStr(applbusid);
    rs2 = stmt2.executeQuery(qs);
    if (rs2.next()) busiddesc = strCheckNull(rs2.getString("code_name"));
    rs2.close();

%>

<p>
<hr size=5 WIDTH=100% >
<table width=600 border=1>
<tr>
  <td colspan=4><b>聘僱資料：</b></td>
</tr>
<tr>
  <td width=18% align=center><b>聘僱文號</b></td>
  <td width=32%><%=strCheckNullHtml( licwpno )%></td>
  <td width=18% align=center><b>發文日期</b></td>
  <td wdith=32%><%=strCheckNullHtml( rs.getString("disp_date") )%></td>
</tr>
<tr>
  <td align=center><b>雇　　主</b></td>
  <td><%="("+vend_seq+")"+strCheckNullHtml(vend_name_ch).replaceAll("　+$", "").trim()%></td>
  <td align=center><b>電　　話</b></td>
  <td><%=strCheckNullHtml(vend_tel)%></td>
</tr>
<tr>
  <td align=center><b>地　　址</b></td>
  <td colspan=3><%=strCheckNullHtml(vend_addr).trim()%></td>
</tr>
<tr>
  <td align=center><b>申請類別</b></td>
  <td><%=strCheckNullHtml(typedesc).trim()%></td>
  <td align=center><b>申請項目</b></td>
  <td><%=strCheckNullHtml(busidesc).trim()%></td>
</tr>
<tr>
  <td align=center><b>申請細項</b></td>
  <td colspan=3><%=strCheckNullHtml(busiddesc).trim()%></td>
</tr>
<tr>
  <td align=center><b>聘僱起始日</b></td>
  <td><%=strCheckNullHtml(rs.getString("work_apply_sdate"))%></td>
  <td align=center><b>聘僱終止日</b></td>
  <td><%=strCheckNullHtml(rs.getString("work_apply_edate"))%></td>
</tr>
<tr>
  <td align=center><b>工作地址</b></td>
  <td colspan=3><%=strCheckNullHtml(work_address).trim()%></td>
</tr>
</table>

<%
//廢止聘僱
qs = "select * from " + tblexpirrec + " where prev_agree_no = " + AbSql.getEqualStr(licwpno)
        + " and naticode = " + AbSql.getEqualStr(natcode)
        + " and passno = " + AbSql.getEqualStr(passno)
        + " and current_status = '11'";
rs2 = stmt2.executeQuery(qs);
if (rs2.next()) {
%>
<table width=600 border=1>
<tr>
  <td colspan=4><font color=ff0000><b>廢止聘僱：</b></font></td>
</tr>
<tr>
  <td width=24% align=center><b>廢止聘僱文號</b></td>
  <td width=26%><%=strCheckNullHtml( rs2.getString("rec_no") )%></td>
  <td width=24% align=center><b>發文日期</b></td>
  <td wdith=26%><%=strCheckNullHtml( rs2.getString("disp_date") )%></td>
</tr>
<tr>
  <td align=center><b>廢止聘僱日期</b></td>
  <td colspan=3><%=strCheckNullHtml( rs2.getString("status_date") )%></td>
</tr>
</table>
<%
} // 結束廢止聘僱
rs2.close();
%>



<%
//展延聘僱
boolean found = true;
while (found) {
    String oldlicwpno = licwpno;
    qs = "select * from " + tblengagerec + " m, " + tblcasem + " s"
        + " where prev_agree_no = " + AbSql.getEqualStr(licwpno)
        + " and naticode = " + AbSql.getEqualStr(natcode)
        + " and passno = " + AbSql.getEqualStr(passno)
        + " and (s.case_sn = m.case_sn and (s.current_status = '11' or s.current_status = '12'))";
//if (debug) out.write(qs + "<br>");
    rs3 = stmt3.executeQuery(qs);
    prev_agree_no = "";
    if (!rs3.next()) {
        found = false;
    } else {
        licwpno = strCheckNull( rs3.getString("rec_no") );
        prev_agree_no = strCheckNull( rs3.getString("prev_agree_no") );
        work_address = strCheckNull( rs3.getString("work_address") );
%>


<table width=600 border=1>
<tr>
  <td colspan=4><font color=ff0000><b>展延聘僱：</b></font></td>
</tr>
<tr>
  <td width=26% align=center><b>展延聘僱文號</b></td>
  <td width=24%><%=strCheckNullHtml( licwpno )%></td>
  <td width=26% align=center><b>發文日期</b></td>
  <td wdith=24%><%=strCheckNullHtml( rs3.getString("disp_date") )%></td>
</tr>
<tr>
  <td align=center><b>原聘僱文號</b></td>
  <td colspan=3><%=strCheckNullHtml(oldlicwpno)%></td>
</tr>
<tr>
  <td align=center><b>展延聘僱起始日</b></td>
  <td><%=strCheckNullHtml(rs3.getString("work_apply_sdate"))%></td>
  <td align=center><b>展延聘僱終止日</b></td>
  <td><%=strCheckNullHtml(rs3.getString("work_apply_edate"))%></td>
</tr>
<tr>
  <td align=center><b>工作地址</b></td>
  <td colspan=3><%=strCheckNullHtml(work_address).trim()%></td>
</tr>
</table>

<%
        //廢止聘僱
        qs = "select * from " + tblexpirrec + " where prev_agree_no = " + AbSql.getEqualStr(licwpno)
                + " and naticode = " + AbSql.getEqualStr(natcode)
                + " and passno = " + AbSql.getEqualStr(passno)
                + " and current_status = '11'";
        rs2 = stmt2.executeQuery(qs);
        if (rs2.next()) {
%>
<b>廢止聘僱：</b>
<table width=600 border=1>
<tr>
  <td width=18% align=center><b>廢止聘僱文號</b></td>
  <td width=32%><%=strCheckNullHtml( rs2.getString("rec_no") )%></td>
  <td width=18% align=center><b>發文日期</b></td>
  <td wdith=32%><%=strCheckNullHtml( rs2.getString("disp_date") )%></td>
</tr>
<tr>
  <td align=center><b>廢止聘僱日期</b></td>
  <td colspan=3><%=strCheckNullHtml( rs2.getString("status_date") )%></td>
</tr>
</table>
<%
        } // 結束廢止聘僱
        rs2.close();
%>


<%
    }
    rs3.close();
} // 結束展延聘僱

%>


<%
}
// 結束多筆聘僱資料
rs.close();


//關閉連線
stmt.close();
stmt2.close();
stmt3.close();
if (con != null) con.close();

%>

</BODY>
</HTML>
