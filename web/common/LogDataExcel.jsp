<%@page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8"%>
<%@page import="java.io.*"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.*"%>
<%@page import="com.absys.util.*"%>
<%@page import="com.absys.user.*"%>

<!-- Apache POI -->
<%@page import="org.apache.poi.xssf.usermodel.XSSFCell"%>
<%@page import="org.apache.poi.xssf.usermodel.XSSFRow"%>
<%@page import="org.apache.poi.xssf.usermodel.XSSFSheet"%>
<%@page import="org.apache.poi.xssf.usermodel.XSSFWorkbook"%>

<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
//尚未登入
if (!userLogin.equals("Y") || !userOpsuper.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

String pageHeader = "日誌下載";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

String errMsg = "";
Connection conn = null;

//建立連線
conn = getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
Statement stmt = conn.createStatement();
Statement stmt2 = conn.createStatement();
ResultSet rs;

String srch = request.getParameter("srch");

//產生報表
//Apache POI
response.setContentType("application/xlsx");
response.setHeader("Content-disposition","attachment; filename=LogDataList.xlsx" );
response.setHeader("Expires:", "0"); // eliminates browser caching
ServletOutputStream outputStream = response.getOutputStream();

//樣板檔名
XSSFWorkbook wb = new XSSFWorkbook();
XSSFSheet sheet = wb.createSheet("Sheet1") ;

//表頭
int rownum = 0;
XSSFRow row = sheet.createRow( rownum++ );
row.createCell(0).setCellValue( "下載代碼" );
row.createCell(1).setCellValue( "代碼說明" );
row.createCell(2).setCellValue( "單位名稱" );
row.createCell(3).setCellValue( "姓名" );
row.createCell(4).setCellValue( "ID" );
row.createCell(5).setCellValue( "IP" );
row.createCell(6).setCellValue( "下載日期" );
row.createCell(7).setCellValue( "下載時間" );
row.createCell(8).setCellValue( "查詢條件" );

sheet.setColumnWidth(0, 16*256);
sheet.setColumnWidth(1, 30*256);
sheet.setColumnWidth(2, 30*256);
sheet.setColumnWidth(3, 10*256);
sheet.setColumnWidth(4, 15*256);
sheet.setColumnWidth(5, 15*256);
sheet.setColumnWidth(6, 10*256);
sheet.setColumnWidth(7, 10*256);
sheet.setColumnWidth(8, 80*256);

//讀取資料
String qs = "select logdata.*, division.title as divtitle"
    + " from logdata left join division on logdata.division=division.id"
    + srch
    + " order by opdate desc, optime desc, division, userid";
stmt = conn.createStatement();
rs = common.Comm.querySQL(stmt, qs);

while (rs.next()) {
    String logid = AbString.rtrimCheck( rs.getString("logid") );
    String logdescript = common.Comm.getCodeTitle(stmt2, logid, "logid", "logid", "descript");
    String userid = AbString.rtrimCheck(rs.getString("userid"));
    if (userid.length() > 3) userid = userid.substring(0,3) + String.join("", Collections.nCopies(userid.length()-3, "*"));

    row = sheet.createRow( rownum++ );
    row.createCell(0).setCellValue( logid );
    row.createCell(1).setCellValue( logdescript );
    row.createCell(2).setCellValue( AbString.rtrimCheck(rs.getString("divtitle")) );
    row.createCell(3).setCellValue( AbString.rtrimCheck(rs.getString("descript")) );
    row.createCell(4).setCellValue( userid );
    row.createCell(5).setCellValue( AbString.rtrimCheck(rs.getString("userip")) );
    row.createCell(6).setCellValue( AbString.rtrimCheck(rs.getString("opdate")) );
    row.createCell(7).setCellValue( AbString.rtrimCheck(rs.getString("optime")) );
    row.createCell(8).setCellValue( AbString.rtrimCheck(rs.getString("data")) );
}
rs.close();

ByteArrayOutputStream outByteStream = new ByteArrayOutputStream();
wb.write(outByteStream);
byte [] outArray = outByteStream.toByteArray();
response.setContentLength(outArray.length);
outputStream.write(outArray);
outputStream.flush();
outputStream.close();


//關閉連線
if (stmt != null) stmt.close();
if (stmt2 != null) stmt2.close();
if (conn != null) conn.close();
%>
