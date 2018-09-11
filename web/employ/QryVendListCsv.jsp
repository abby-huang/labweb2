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
String pageHeader = "雇主資料查詢 - 雇主個別查詢 - 資料下載";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

String errMsg = "";
Connection con = null;
String labdts_cyyyymmdd = (String)session.getAttribute("labdts_cyyyymmdd");

//取得輸入資料
String QryVendSql = AbString.rtrimCheck((String)session.getAttribute("QryVendSql"));
String QryVendTitle = AbString.rtrimCheck((String)session.getAttribute("QryVendTitle"));

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
response.setHeader("Content-Disposition", "attachment; filename=QryVendListCsv.txt");
ServletOutputStream outputStream = response.getOutputStream();

//輸出參數
String dlm = ";"; //分隔字元
StringBuilder csvtext = new StringBuilder(); //資料內容

//表頭
csvtext.append("查詢條件：" + QryVendTitle);
csvtext.append("\r\n");

//標題
csvtext.append("雇主編號").append(dlm);
csvtext.append("雇主名稱").append(dlm);
csvtext.append("地址").append(dlm);
csvtext.append("電話").append(dlm);
csvtext.append("郵遞區號").append(dlm);
csvtext.append("負責人").append(dlm);
csvtext.append("菲律賓").append(dlm);
csvtext.append("泰國").append(dlm);
csvtext.append("馬來西亞").append(dlm);
csvtext.append("印尼").append(dlm);
csvtext.append("越南").append(dlm);
csvtext.append("蒙古").append(dlm);
csvtext.append("\r\n");

//輸出資料
byte[] bytes = csvtext.toString().getBytes("BIG5");
outputStream.write(bytes, 0, bytes.length);
csvtext.setLength(0);

//寫入資料
qs = "select distinct(m.vendno || m.wkadseq), m.* from labdyn_vend m "
        + QryVendSql
        + " order by m.vendno || m.wkadseq";
rs = common.Comm.querySQL(stmt, qs);
while (rs.next()) {
    String regno = AbString.rtrimCheck( rs.getString("vendno") );
    String wkadseq = AbString.rtrimCheck( rs.getString("wkadseq") );
    String cname = AbString.rtrimCheck( rs.getString("cname") );
    String addr = AbString.rtrimCheck( rs.getString("addr") );
    String tel = AbString.rtrimCheck( rs.getString("tel") );
    String zipcode = AbString.rtrimCheck( rs.getString("zipcode") );
    String respname = AbString.rtrimCheck( rs.getString("respname") );

    //計算人數
    int[] labnum = {0, 0, 0, 0, 0, 0};
    qs = "select natcode, count(*) from cognos_labdts where cyyyymmdd = '" + labdts_cyyyymmdd + "'"
            + " and regno = " + AbSql.getEqualStr(regno)
            + " and wkadseq = " + AbSql.getEqualStr(wkadseq)
            + " and type = 'SA'"
            + " group by natcode order by natcode";
    rs2 = common.Comm.querySQL(stmt2, qs);
    while (rs2.next()) {
        String natcode2 = rs2.getString(1);
        for (int i = 0; i < natcodes.length; i++) {
            if ( natcode2.equals(natcodes[i]) ) {
                labnum[i] += rs2.getInt(2);
                break;
            }
        }
    }
    rs2.close();

    csvtext.append(regno + wkadseq).append(dlm);
    csvtext.append(AbString.rtrimCheck(cname).replaceAll("　+$", "")).append(dlm);
    csvtext.append(AbString.rtrimCheck(addr).replaceAll("　+$", "") ).append(dlm);
    csvtext.append(AbString.rtrimCheck(tel)).append(dlm);
    csvtext.append(AbString.rtrimCheck(zipcode)).append(dlm);
    csvtext.append(AbString.rtrimCheck(respname).replaceAll("　+$", "")).append(dlm);
    csvtext.append(labnum[1]).append(dlm);
    csvtext.append(labnum[3]).append(dlm);
    csvtext.append(labnum[2]).append(dlm);
    csvtext.append(labnum[0]).append(dlm);
    csvtext.append(labnum[4]).append(dlm);
    csvtext.append(labnum[5]).append(dlm);
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

