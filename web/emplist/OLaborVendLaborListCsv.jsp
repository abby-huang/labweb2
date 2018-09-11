<%@ page pageEncoding="UTF-8" contentType="application/vnd.ms-excel;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="com.absys.util.*" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "藍領外國人清冊 - 移工下載";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

String errMsg = "";
Connection con = null;
String labdts_cyyyymmdd = (String)session.getAttribute("labdts_cyyyymmdd");

//建立連線
con = common.Comm.getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";

Statement stmt = con.createStatement();
Statement stmt2 = con.createStatement();
stmt.setQueryTimeout(60*90);
ResultSet rs, rs2;
String qs;

//取得輸入資料
String OLaborSql = AbString.rtrimCheck((String)session.getAttribute("OLaborSql"));
String OLaborTitle = AbString.rtrimCheck((String)session.getAttribute("OLaborTitle"));
if (OLaborSql.length() == 0) OLaborSql += " where cyyyymmdd = '" + labdts_cyyyymmdd + "'";
else OLaborSql += " and cyyyymmdd = '" + labdts_cyyyymmdd + "'";

//設定輸出
response.setContentType("text/plain; charset=MS950");
response.setHeader("Content-Disposition", "attachment; filename=OLaborVendLaborListCsv.txt");
ServletOutputStream outputStream = response.getOutputStream();

//輸出參數
String dlm = ";"; //分隔字元
StringBuilder csvtext = new StringBuilder(); //資料內容

//表頭
//csvtext.append("系統時間：" + new java.text.SimpleDateFormat("yyyyMMdd HH:mm:ss").format(Calendar.getInstance().getTime()) + "\r\n");
csvtext.append("報表名稱：雇主現僱外勞清冊" + "\r\n");
csvtext.append("查詢條件：" + OLaborTitle + "\r\n");
csvtext.append("產生日期：" + AbDate.getToday("/") + "\r\n");

//標題
csvtext.append("雇主編號").append(dlm);
csvtext.append("雇主名稱").append(dlm);
csvtext.append("雇主地址").append(dlm);
csvtext.append("雇主電話").append(dlm);
csvtext.append("郵遞區號").append(dlm);
csvtext.append("負責人").append(dlm);
csvtext.append("國籍").append(dlm);
csvtext.append("護照號碼").append(dlm);
csvtext.append("英文姓名").append(dlm);
csvtext.append("性別").append(dlm);
csvtext.append("出生日期").append(dlm);
csvtext.append("狀態").append(dlm);
csvtext.append("工作地址").append(dlm);
csvtext.append("居留地址").append(dlm);
csvtext.append("核准文號").append(dlm);
csvtext.append("聘僱文號").append(dlm);
csvtext.append("入境日").append(dlm);
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

try {

//寫入資料
//從 cognos_labdts 讀取資料
qs = "select v.*, l.natcode, l.passno, l.citycode, l.caseno12, l.emplcode, l.resaddr, l.indate, l.agenno, l.commid, l.commname from cognos_labdts l"
        + " left join labdyn_vend v on v.vendno=l.regno and v.wkadseq=l.wkadseq"
        + OLaborSql
        + " order by l.regno, l.wkadseq, l.natcode, l.passno";
//csvtext.append(qs + "\r\n");
rs = common.Comm.querySQL(stmt, qs);
while (rs.next()) {
    String natcode = AbString.rtrimCheck( rs.getString("natcode") );
    String passno = AbString.rtrimCheck( rs.getString("passno") );
    common.LaborDetail laborDetail = new common.LaborDetail(natcode, passno);

    //從 labdts 讀取
    laborDetail.vendcitycode = AbString.rtrimCheck( rs.getString("citycode") );
    laborDetail.caseno12 = AbString.rtrimCheck( rs.getString("caseno12") );
    laborDetail.emplcode = AbString.rtrimCheck( rs.getString("emplcode") );
    laborDetail.indate = AbString.rtrimCheck( rs.getString("indate") );
    laborDetail.agenno = AbString.rtrimCheck( rs.getString("agenno") );
    laborDetail.resaddr = AbString.rtrimCheck( rs.getString("resaddr") );
    laborDetail.commid = AbString.rtrimCheck( rs.getString("commid") );
    laborDetail.commname = AbString.rtrimCheck( rs.getString("commname") );

    laborDetail.vendno = AbString.rtrimCheck( rs.getString("vendno") );
    laborDetail.wkadseq = AbString.rtrimCheck( rs.getString("wkadseq") );
    laborDetail.vendname = AbString.rtrimCheck( rs.getString("cname") ).replaceAll("　+$", "");
    laborDetail.vendtel = AbString.rtrimCheck( rs.getString("tel") );
    laborDetail.vendaddr = AbString.rtrimCheck( rs.getString("addr") ).replaceAll("　+$", "");
    laborDetail.vendzipcode = AbString.rtrimCheck( rs.getString("zipcode") );
    laborDetail.vendrespname = AbString.rtrimCheck( rs.getString("respname") ).replaceAll("　+$", "");

    //讀取外勞資料
    laborDetail.getBasic(stmt2);
    laborDetail.getDetailList(stmt2);

    csvtext.append(laborDetail.vendno + laborDetail.wkadseq).append(dlm);
    csvtext.append(laborDetail.vendname).append(dlm);
    csvtext.append(laborDetail.vendaddr).append(dlm);
    csvtext.append(laborDetail.vendtel).append(dlm);
    csvtext.append(laborDetail.vendzipcode).append(dlm);
    csvtext.append(laborDetail.vendrespname).append(dlm);

    csvtext.append(laborDetail.nation).append(dlm);
    csvtext.append(laborDetail.passno).append(dlm);
    csvtext.append(laborDetail.engname).append(dlm);
    csvtext.append(laborDetail.sex_desc).append(dlm);
    csvtext.append(laborDetail.birthday).append(dlm);
    csvtext.append(laborDetail.lstatus_desc).append(dlm);
    csvtext.append(laborDetail.wkaddr).append(dlm);
    csvtext.append(laborDetail.resaddr).append(dlm);

    csvtext.append(laborDetail.prmtno).append(dlm);
    csvtext.append(laborDetail.wkprmtno).append(dlm);
    csvtext.append(laborDetail.indate).append(dlm);
    csvtext.append(laborDetail.conedate).append(dlm);
    csvtext.append(laborDetail.enginame).append(dlm);
    csvtext.append(laborDetail.originalno).append(dlm);

    csvtext.append("(" + laborDetail. agenno +  ")").append(laborDetail.agenname).append(dlm);
    csvtext.append(laborDetail.agentel).append(dlm);
    csvtext.append(laborDetail.agenaddr).append(dlm);

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

} catch (Exception e) {
    System.out.println(e.getMessage());
    System.out.println(e.getStackTrace());
    csvtext.append( e.getMessage() + "\r\n");
    csvtext.append( e.getStackTrace() + "\r\n");
}

//csvtext.append("系統時間：" + new java.text.SimpleDateFormat("yyyyMMdd HH:mm:ss").format(Calendar.getInstance().getTime()) + "\r\n");

//輸出資料
bytes = csvtext.toString().getBytes("BIG5");
//response.setContentLength(bytes.length);
outputStream.write(bytes, 0, bytes.length);
outputStream.flush();
outputStream.close();

%>

