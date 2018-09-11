<%@ page pageEncoding="UTF-8" contentType="application/vnd.ms-excel;charset=UTF-8" %>
<%@ page errorPage="../ErrorPage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="com.absys.util.*" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "依外勞資料查詢清冊";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

String errMsg = "";
Connection con = null;
String labdts_cyyyymmdd = (String)session.getAttribute("labdts_cyyyymmdd");

//取得輸入資料
String QryLabdtsSql = AbString.rtrimCheck((String)session.getAttribute("QryLabdtsSql"));
String QryLabdtsTitle = AbString.rtrimCheck((String)session.getAttribute("QryLabdtsTitle"));
if (QryLabdtsSql.length() == 0) QryLabdtsSql += " where cyyyymmdd = '" + labdts_cyyyymmdd + "'";
else QryLabdtsSql += " and cyyyymmdd = '" + labdts_cyyyymmdd + "'";

//建立連線
con = common.Comm.getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

Statement stmt = con.createStatement();
Statement stmt2 = con.createStatement();
stmt.setQueryTimeout(60*90);
ResultSet rs, rs2;
String qs;


//設定輸出
response.setContentType("text/plain; charset=MS950");
response.setHeader("Content-Disposition", "attachment; filename=QryLabdtsListCsv.txt");
ServletOutputStream outputStream = response.getOutputStream();

//輸出參數
String dlm = ";"; //分隔字元
StringBuilder csvtext = new StringBuilder(); //資料內容

//表頭
csvtext.append("查詢條件：" + QryLabdtsTitle);
csvtext.append("\r\n");

//標題
csvtext.append("國籍").append(dlm);
csvtext.append("護照號碼").append(dlm);
csvtext.append("英文姓名").append(dlm);
csvtext.append("性別").append(dlm);
csvtext.append("出生日期").append(dlm);
csvtext.append("工作地址").append(dlm);
csvtext.append("居留地址").append(dlm);

csvtext.append("雇主名稱").append(dlm);
csvtext.append("行職業別").append(dlm);
csvtext.append("縣市別").append(dlm);
csvtext.append("雇主地址").append(dlm);
csvtext.append("狀態").append(dlm);

csvtext.append("核准文號").append(dlm);
csvtext.append("聘僱文號").append(dlm);
csvtext.append("入境日").append(dlm);
csvtext.append("出境日").append(dlm);
csvtext.append("起始日").append(dlm);
csvtext.append("期滿日").append(dlm);
csvtext.append("工程名稱").append(dlm);
csvtext.append("工務所地址").append(dlm);

csvtext.append("仲介公司").append(dlm);
csvtext.append("仲介公司電話").append(dlm);
csvtext.append("仲介公司地址").append(dlm);

csvtext.append("被看護人姓名").append(dlm);
csvtext.append("被看護人身份證號碼");
csvtext.append("\r\n");

//輸出資料
byte[] bytes = csvtext.toString().getBytes("BIG5");
outputStream.write(bytes, 0, bytes.length);
csvtext.setLength(0);

//寫入資料
//從 cognos_labdts 讀取資料
qs = "SELECT l.natcode, l.passno from cognos_labdts l "
            + QryLabdtsSql
        + " order by l.regno, l.wkadseq, l.natcode, l.passno";
rs = common.Comm.querySQL(stmt, qs);
while (rs.next()) {
    String natcode = AbString.rtrimCheck( rs.getString("natcode") );
    String passno = AbString.rtrimCheck( rs.getString("passno") );
    common.LaborDetail laborDetail = new common.LaborDetail(natcode, passno);
    laborDetail.getBasic(stmt2);
    laborDetail.getDetail(stmt2);

    csvtext.append(laborDetail.nation).append(dlm);
    csvtext.append(laborDetail.passno).append(dlm);
    csvtext.append(laborDetail.engname).append(dlm);
    csvtext.append(laborDetail.sex_desc).append(dlm);
    csvtext.append(laborDetail.birthday).append(dlm);
    csvtext.append(laborDetail.wkaddr).append(dlm);
    csvtext.append(laborDetail.resaddr).append(dlm);

    csvtext.append(laborDetail.vendname.replaceAll("　+$", "")).append(dlm);
    csvtext.append(laborDetail.bizkind_desc).append(dlm);
    csvtext.append(laborDetail.city.replaceAll("　+$", "")).append(dlm);
    csvtext.append(laborDetail.vendaddr).append(dlm);
    csvtext.append(laborDetail.lstatus_desc).append(dlm);

    csvtext.append(laborDetail.prmtno).append(dlm);
    csvtext.append(laborDetail.wkprmtno).append(dlm);
    csvtext.append(laborDetail.indate).append(dlm);
    csvtext.append(laborDetail.outdate).append(dlm);
    csvtext.append(laborDetail.wkbdate).append(dlm);
    csvtext.append(laborDetail.conedate).append(dlm);
    csvtext.append(laborDetail.enginame).append(dlm);
    csvtext.append(laborDetail.originalno).append(dlm);

    csvtext.append("(" + laborDetail.agenno + ")" + laborDetail.agenname.replaceAll("　+$", "")).append(dlm);
    csvtext.append(laborDetail.agentel).append(dlm);
    csvtext.append(laborDetail.agenaddr.replaceAll("　+$", "")).append(dlm);

    csvtext.append(laborDetail.commname).append(dlm);
    csvtext.append(laborDetail.commid);

    csvtext.append("\r\n");

    //輸出資料
    bytes = csvtext.toString().getBytes("BIG5");
    outputStream.write(bytes, 0, bytes.length);
    csvtext.setLength(0);
    outputStream.flush();
}
rs.close();

//關閉連線
stmt.close();
stmt2.close();
if (con != null) con.close();

//輸出資料
//byte[] bytes = csvtext.toString().getBytes("BIG5");
//response.setContentLength(bytes.length);
//outputStream.write(bytes, 0, bytes.length);
outputStream.flush();
outputStream.close();

%>

