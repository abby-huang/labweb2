<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "藍領外國人詳細資料";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOpblue.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
String errMsg = "";
Connection conn = null;

//取得輸入資料
String natcode = strCheckNull( request.getParameter("natcode") );
String passno = strCheckNull( request.getParameter("passno") );

//建立連線
conn = getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

//讀取詳細
common.LaborDetail laborDetail = new common.LaborDetail(natcode, passno);
laborDetail.getBasic(conn);
laborDetail.getDetail(conn);
laborDetail.getExtend(conn);

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

<table width=600 border=1 style="table-layout: fixed;">
<tr>
  <td width=15% align=center><b>國　　籍</b></td>
  <td width=36%><%=strCheckNullHtml(laborDetail.nation)%></td>
  <td width=20% align=center><b>護照號碼</b></td>
  <td wdith=29%><%=strCheckNullHtml(laborDetail.passno)%></td>
</tr>

<tr>
  <td align=center><b>姓　　名</b></td>
  <td colspan=3><%=strCheckNullHtml(laborDetail.engname)%></td>
</tr>
<tr>
  <td align=center><b>行職業別</b></td>
  <td colspan=3><%=strCheckNullHtml(laborDetail.bizkind_desc)%></td>
</tr>
<tr>
  <td align=center><b>性　　別</b></td>
  <td ><%=strCheckNullHtml(laborDetail.sex_desc)%></td>
  <td align=center><b>出生日期</b></td>
  <td ><%=strCheckNullHtml(AbDate.fmtDate(laborDetail.birthday, "-"))%></td>
</tr>
<tr>
  <td align=center><b>雇　　主</b></td>
  <td><%=strCheckNullHtml(laborDetail.vendname).replaceAll("　+$", "") + " (" + laborDetail.regno + ")"%></td>
  <td align=center><b>電　　話</b></td>
  <td><%=strCheckNullHtml(laborDetail.vendtel)%></td>
</tr>
<tr>
<!--2016.4.11.陸立群將「雇主地址」改成「核准工作地」-->
  <td align=center><b>核准工作地</b></td>
  <td colspan=3><%=strCheckNullHtml(laborDetail.vendaddr)%></td>
</tr>



<%
if (laborDetail.commname.length() > 0) {
%>
<tr>
  <td align=center><b>被看護人</b></td>
  <td><%=laborDetail.commname%></td>
  <td align=center><b>身份證字號</b></td>
  <td><%=laborDetail.commid%></td>
</tr>
<%
}
%>

<tr>
  <td align=center><b>工作地<br>縣市轄區</b></td>
  <td><%=strCheckNullHtml( laborDetail.city ).replaceAll("　+$", "")%></td>
  <td align=center><b>狀　　態</b></td>
  <td><%=convertChiSymbol( strCheckNullHtml(laborDetail.lstatus_desc) )%></td>
</tr>
<tr>
  <td align=center><b>體檢日期</b></td>
  <td><%=strCheckNullHtml(AbDate.fmtDate(laborDetail.healthdate, "-"))%></td>
  <td align=center><b>行蹤不明日期</b></td>
  <td ><%=strCheckNullHtml(AbDate.fmtDate(laborDetail.escapedate, "-"))%></td>
</tr>

<tr>
  <td align=center><b>雇主曾經<br>違法紀錄</b></td>
  <td colspan=3><%=strCheckNullHtml(laborDetail.vendillegal)%></td>
</tr>

<%
//原舊護照
if (laborDetail.onatcode.length() > 0) {
%>
<tr>
  <td align=center><b>原舊護照</b></td>
  <td colspan=3><a HREF="QryLaborDetail.jsp?natcode=<%=laborDetail.onatcode%>&passno=<%=laborDetail.opassno%>"><%=laborDetail.opassno%></a>
  </td>
</tr>
<%
}
%>

<%
//已有新護照
if (laborDetail.npassno.length() > 0) {%>
<tr>
  <td align=center><b>已有新護照</b></td>
  <td colspan=3><a HREF="QryLaborDetail.jsp?natcode=<%=laborDetail.nnatcode%>&passno=<%=laborDetail.npassno%>"><%=laborDetail.npassno%></a>
  </td>
</tr>
<% } %>

</table>

<p>

<%
if (laborDetail.visa.visadate.length() > 0) {
%>

<B>※駐<%=strCheckNullHtml( laborDetail.nation )%>代表處最近之簽證如下：本資料由外交部領務局提供，資料不一致時請以外交部領務局為準</B>
<Table border=1>
<TR>
    <TH ROWSPAN=2 width=80><H3>簽證</TH>
    <TH Width=100>簽發日</TH>
    <TH Width=100>核准文號</TH>
    <TH Width=100>核准函日期</TH>
    <TH Width=120>註銷簽證日期</TH>
</TR>
<TR>
    <TD Width=100><%=strCheckNullHtml( AbDate.fmtDate(laborDetail.visa.visadate, "-") )%></TD>
    <TD><%=strCheckNullHtml( laborDetail.visa.prmtno )%></TD>
    <TD><%=strCheckNullHtml( AbDate.fmtDate(laborDetail.visa.prmtdate, "-") )%></TD>
    <TD><%=strCheckNullHtml( AbDate.fmtDate(laborDetail.visa.canceldate, "-") )%></TD>
</TR>
</Table>
<P>

<%
}
%>


<B>※移民署提供之最近入出境資訊如下：本資料由移民署提供，資料不一致時請以移民署為準</B>
<Table border=1 >
<TR>
    <TH ROWSPAN=2 Width=80><H4>入出境</TH>
    <TH Width=100>入境日期</TH>
    <TH Width=100>出境日期</TH>
</TR>
<TR>
    <TD><%=strCheckNullHtml( AbDate.fmtDate(laborDetail.inout.indate, "-") )%></TD>
    <TD><%=strCheckNullHtml( AbDate.fmtDate(laborDetail.inout.outdate, "-") )%></TD>
</TR>
</Table>
<P>

<%
if (laborDetail.healthchk.chktype.length() > 0) {
%>

<B>※疾病管制署提供之最新體檢資訊如下：本資料由疾病管制署提供，資料不一致時請以疾病管制署為準</B>
<Table border=1>
<TR>
    <TH Width=180>體檢種類</TH>
    <TH Width=100>體檢日期</TH>
    <TH Width=100>總結果</TH>
    <TH Width=100>核備結果</TH>
    <TH Width=100>體檢<br>報告日</TH>
    <TH Width=10%>逾期<br>體檢</TH>
    <TH Width=10%>逾期<br>報備</TH>
</TR>
<TR>
    <TD><%=strCheckNullHtml( laborDetail.healthchk.chktype )%></TD>
    <TD><%=strCheckNullHtml( AbDate.fmtDate(laborDetail.healthchk.chkdate, "-") )%></TD>
    <TD><%=strCheckNullHtml( laborDetail.healthchk.chkresult )%></TD>
    <TD><%=strCheckNullHtml( laborDetail.healthchk.alwresult )%></TD>
    <TD><%=strCheckNullHtml( AbDate.fmtDate(laborDetail.healthchk.rptdate, "-") )%></TD>
    <TD><%=strCheckNullHtml( laborDetail.healthchk.offtime )%></TD>
    <TD><%=strCheckNullHtml( laborDetail.healthchk.offrpt )%></TD>
</TR>
</Table>
<P>

<%
}
%>


<%
if (laborDetail.resident.resnum.length() > 0) {
%>

<B>※移民署提供之最近居留資訊如下：本資料由移民署提供，資料不一致時請以移民署為準</B>
<Table border=1>
<TR><TH Width=10%>居留<br>證號</TH>
    <TH Width=20%>居留<br>效期</TH>
    <TH Width=10%>居留<br>狀況</TH>
    <TH Width=22%>行方不明</TH>
    <TH Width=14%>行蹤不明<br>日期</TH>
    <TH Width=10%>查獲<br>日期</TH>
    <TH Width=14%>重入境<br>期限</TH>
</TR>
<TR>
    <TD><%=strCheckNullHtml( laborDetail.resident.resnum )%></TD>
    <TD><%=strCheckNullHtml( AbDate.fmtDate(laborDetail.resident.resvalid, "-") )%></TD>
    <TD><%=strCheckNullHtml( laborDetail.resident.resstatus )%></TD>
    <TD><%=strCheckNullHtml( laborDetail.resident.misstatus )%></TD>
    <TD><%=strCheckNullHtml( AbDate.fmtDate(laborDetail.resident.escapedate, "-") )%></TD>
    <TD><%=strCheckNullHtml( AbDate.fmtDate(laborDetail.resident.crimedate, "-") )%></TD>
    <TD><%=strCheckNullHtml( AbDate.fmtDate(laborDetail.resident.reentrydate, "-") )%></TD>
</TR>
<TR>
    <TD COLSPAN=2 ALIGN=CENTER><H4>居 留 地 址</TD>
    <TD COLSPAN=6><%=strCheckNullHtml( laborDetail.resident.resaddr )%></TD>
</TR>
</Table>
<P>

<%
}
%>


<%
if (laborDetail.workprmt.size() > 0) {
%>

<B>※勞動力發展署提供之最近聘僱資訊如下：</B>
<Table border=1 width="876">
<TR>
<!--
    <TH ROWSPAN=<%=(laborDetail.workprmt.size()+1)%> Width=40><H4>聘僱</TH>
-->
    <TH Width=80>聘僱文號</TH>
    <TH Width=90>聘僱許可日</TH>
    <TH Width=80>入境日期</TH>
    <TH Width=200>雇主</TH>
    <TH Width=100>工作起迄日</TH>
    <TH Width=200>仲介公司</TH>
    <TH Width=100>聘僱類別註記</TH>
</TR>

<%
    for (int i = laborDetail.workprmt.size()-1; i >= 0; i--) {
        //聘僱類別註記 - 2017.01.06
        String hirekind = laborDetail.workprmt.get(i).hirekind;
        String hirekindTitle = "(" + hirekind + ")";
        if (hirekind.equals("11")) hirekindTitle += "入境聘僱";
        else if (hirekind.equals("12")) hirekindTitle += "期滿續聘";
        else if (hirekind.equals("21")) hirekindTitle += "接續聘僱";
        else if (hirekind.equals("22")) hirekindTitle += "期滿轉聘";
        else hirekindTitle = "";
%>

<TR>
    <TD><%=strCheckNullHtml( (laborDetail.workprmt.get(i).isVirtual ? "*" : "") + laborDetail.workprmt.get(i).wkprmtno )%></TD>
    <TD><%=strCheckNullHtml( AbDate.fmtDate(laborDetail.workprmt.get(i).wkprmtdate, "-") )%></TD>
    <TD><%=strCheckNullHtml( AbDate.fmtDate(laborDetail.workprmt.get(i).indate, "-") )%></TD>
    <TD><%=strCheckNullHtml( laborDetail.workprmt.get(i).vendname + "(" + laborDetail.workprmt.get(i).regno + ")")%></TD>
    <TD><%=strCheckNullHtml( AbDate.fmtDate(laborDetail.workprmt.get(i).wkbdate, "-") )%>～<br><%=strCheckNullHtml( AbDate.fmtDate(laborDetail.workprmt.get(i).conedate, "-") )%></TD>
    <TD><%=strCheckNullHtml( laborDetail.workprmt.get(i).agenname + " " + laborDetail.workprmt.get(i).agentel )%></TD>
    <TD><%=strCheckNullHtml( hirekindTitle )%></TD>
</TR>

<%
    }
%>

</Table>
<%
}
%>

<P>

<%
if (laborDetail.expir.size() > 0) {
%>

<P>
<B>※勞動力發展署提供之廢止聘僱資訊如下：</B>
<Table border=1 Width=720>
<TR>
<!--
    <TH ROWSPAN=<%=(laborDetail.expir.size()+1)%> Width=80><H4>撤銷</TH>
-->
    <TH Width=80>撤銷文號</TH>
    <TH Width=80>撤銷日期</TH>
    <TH Width=80>通知日期</TH>
    <TH Width=160>通知單位</TH>
    <TH Width=80>發生日期</TH>
    <TH Width=160>撤銷案由<br>(狀況內容)</TH>
    <TH align='center' Width=80 >黑名單</TH>
</TR>

<%
    for (int i = laborDetail.expir.size()-1; i >= 0; i--) {
        String cancelstatus = "";
        if (laborDetail.expir.get(i).canceltype.equals("1")) cancelstatus = "黑名單";
        else if (laborDetail.expir.get(i).canceltype.equals("2")) cancelstatus = "解除黑名單";
%>

<TR>
    <TD><%=strCheckNullHtml(laborDetail.expir.get(i).expirwkno)%></TD>
    <TD><%=strCheckNullHtml(AbDate.fmtDate(laborDetail.expir.get(i).expiredate, "-"))%></TD>
    <TD><%=strCheckNullHtml(AbDate.fmtDate(laborDetail.expir.get(i).knowdate, "-"))%></TD>
    <TD><%=strCheckNullHtml("(" + laborDetail.expir.get(i).knowcode + ")" + laborDetail.expir.get(i).knowcode_desc)%></TD>
    <TD><%=strCheckNullHtml(AbDate.fmtDate(laborDetail.expir.get(i).dynadate, "-"))%></TD>
    <TD><%=strCheckNullHtml("(" + laborDetail.expir.get(i).happcode + ")" + laborDetail.expir.get(i).happcode_desc)%></TD>
    <TD><%=strCheckNullHtml(cancelstatus)%></TD>
</TR>

<%
    }
%>

</Table>
<P>

<%
}
%>


<!-- 新增分開顯示 2017.03.14-->
<%
if (laborDetail.expir2.size() > 0) {
%>

<P>
<B>※勞動力發展署提供之外國人安置管理系統資訊如下：</B>
<Table border=1 Width=720>
<TR>
<!--
    <TH ROWSPAN=<%=(laborDetail.expir2.size()+1)%> Width=80><H4>撤銷</TH>
-->
    <TH Width=80>撤銷文號</TH>
    <TH Width=80>撤銷日期</TH>
    <TH Width=80>通知日期</TH>
    <TH Width=160>通知單位</TH>
    <TH Width=80>發生日期</TH>
    <TH Width=160>撤銷案由<br>(狀況內容)</TH>
    <TH align='center' Width=80 >黑名單</TH>
</TR>

<%
    for (int i = laborDetail.expir2.size()-1; i >= 0; i--) {
        String cancelstatus = "";
        if (laborDetail.expir2.get(i).canceltype.equals("1")) cancelstatus = "黑名單";
        else if (laborDetail.expir2.get(i).canceltype.equals("2")) cancelstatus = "解除黑名單";
%>

<TR>
    <TD><%=strCheckNullHtml(laborDetail.expir2.get(i).expirwkno)%></TD>
    <TD><%=strCheckNullHtml(AbDate.fmtDate(laborDetail.expir2.get(i).expiredate, "-"))%></TD>
    <TD><%=strCheckNullHtml(AbDate.fmtDate(laborDetail.expir2.get(i).knowdate, "-"))%></TD>
    <TD><%=strCheckNullHtml("(" + laborDetail.expir2.get(i).knowcode + ")" + laborDetail.expir2.get(i).knowcode_desc)%></TD>
    <TD><%=strCheckNullHtml(AbDate.fmtDate(laborDetail.expir2.get(i).dynadate, "-"))%></TD>
    <TD><%=strCheckNullHtml("(" + laborDetail.expir2.get(i).happcode + ")" + laborDetail.expir2.get(i).happcode_desc)%></TD>
    <TD><%=strCheckNullHtml(cancelstatus)%></TD>
</TR>

<%
    }
%>

</Table>



<%
}
%>

<%
Statement stmt = conn.createStatement();

//取得 case_no - 多筆
ArrayList<String> case_no_list = new ArrayList();
String qs = "select * from fwi_fwms_case_people"
        + " where nat_code = " + AbSql.getEqualStr(natcode)
        + " and ue_id = " + AbSql.getEqualStr(passno)
        + " order by case_no";
ResultSet rs = stmt.executeQuery(qs);
while (rs.next()) {
    String case_no = AbString.rtrimCheck( rs.getString("case_no") );
    case_no_list.add(case_no);
}
rs.close();

//顯示每筆資料
for (int cnt_case_no = 0; cnt_case_no < case_no_list.size(); cnt_case_no++) {
    String case_no = case_no_list.get(cnt_case_no);
%>

<P>

<%  if (cnt_case_no == 0) { %>
<B>※本資料由外籍勞工查察暨諮詢管理資訊系統資料庫提供：</B>
<%  } %>

<Table border=1 Width=600>
    <TR>
        <TH Width=50%>移送書文號</TH>
        <TH Width=50%>移送書日期</TH>
    </TR>
<%
    qs = "select * from fwi_fwms_case where case_no = " + AbSql.getEqualStr(case_no);
    rs = stmt.executeQuery(qs);
    if (rs.next()) {
        String come_no = AbString.rtrimCheck( rs.getString("come_no") );
        String come_no2 = AbString.rtrimCheck( rs.getString("come_no2") );
        String come_date = AbString.rtrimCheck( rs.getString("come_date") );
%>
    <TR>
        <TD ALIGN=CENTER><%=come_no%>&nbsp;<%=come_no2%></TD>
        <TD ALIGN=CENTER><%=come_date%></TD>
    </TR>
<%
    }
    rs.close();
%>
</Table>
<Table border=1 Width=600>
    <TR>
        <TD ALIGN=CENTER><B>非法人員</B></TD>
        <TD ALIGN=CENTER><B>名稱</B></TD>
        <TD ALIGN=CENTER><B>證號</B></TD>
        <TD ALIGN=CENTER><B>仲介許可證字號</B></TD>
    </TR>

<%
    qs = "select * from fwi_fwms_case_people where case_no = " + AbSql.getEqualStr(case_no) + " order by people_type";
    rs = stmt.executeQuery(qs);
    while (rs.next()) {
        String people_type = AbString.rtrimCheck( rs.getString("people_type") );
        String name = AbString.rtrimCheck( rs.getString("name") );
        String ue_id = AbString.rtrimCheck( rs.getString("ue_id") );
        String agency_id = AbString.rtrimCheck( rs.getString("agency_id") );
        String people_type_desc = "";
        String agency_id_desc = "";
        switch (people_type) {
            case "1": people_type_desc = "非法雇主"; break;
            case "2": people_type_desc = "非法仲介"; agency_id_desc = agency_id; break;
            case "3": people_type_desc = "外勞"; break;
            case "4": people_type_desc = "關係人"; break;
            default:
        }
%>
    <TR>
        <TD ALIGN=CENTER><%=people_type_desc%></TD>
        <TD><%=name%></TD>
        <TD><%=ue_id%>&nbsp;</TD>
        <TD><%=agency_id%>&nbsp;</TD>
    </TR>
<%
    }
    rs.close();
%>


</Table>


<%
} //顯示每筆資料
%>


<%

//關閉連線
stmt.close();
if (conn != null) conn.close();
%>

<P>
</BODY>
</HTML>
