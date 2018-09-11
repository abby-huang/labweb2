<%@page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8"%>
<%@page import="java.io.*"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="com.absys.util.*"%>
<%@page import="com.absys.user.*"%>
<%@page import="java.text.*"%>
<%@ page import="common.*"%>

<!-- Apache POI -->
<%@page import="org.apache.poi.xssf.usermodel.XSSFCell"%>
<%@page import="org.apache.poi.xssf.usermodel.XSSFRow"%>
<%@page import="org.apache.poi.xssf.usermodel.XSSFSheet"%>
<%@page import="org.apache.poi.xssf.usermodel.XSSFWorkbook"%>

<%@ include file="../include/LoginData.jsp" %>

<%
//檢查登入權限
if ((loginUser == null) || !sysModules.hasPrivelege("staff", loginUser.privilege) ) {
    response.sendRedirect(Consts.logoutFile);
}

String pageHeader = "使用者名冊下載";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

String errMsg = "";
Connection conn = null;

//建立連線
conn = Comm.getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
Statement stmt = conn.createStatement();
Statement stmt2 = conn.createStatement();
ResultSet rs;

String qbranch = AbString.rtrimCheck((String)session.getAttribute("QryStaff_qbranch"));
String qlogindate = AbString.rtrimCheck((String)session.getAttribute("QryStaff_qlogindate"));

String srch = "";
if (qbranch.length() > 0) srch += " and branch = " + AbSql.getEqualStr(qbranch);
if (qlogindate.length() > 0) srch += " and (logindate < TO_DATE(" + AbSql.getEqualStr(qlogindate)
        + ", 'YYYY-MM-DD') or logindate is null)";

if (srch.length() > 0) srch = " where " + srch.substring(4);


//產生報表
//Apache POI
response.setContentType("application/xlsx");
response.setHeader("Content-disposition","attachment; filename=QryStaffExcel.xlsx" );
response.setHeader("Expires:", "0"); // eliminates browser caching
ServletOutputStream outputStream = response.getOutputStream();

//樣板檔名
String rptFilePath = getServletContext().getRealPath("") + "/labsys/admin/QryStaffExcel.xlsx";
XSSFWorkbook wb = new XSSFWorkbook(new FileInputStream(rptFilePath));
XSSFSheet sheet = wb.getSheetAt(0);

//表頭
XSSFCell cell = null;
//製表人員
cell = sheet.getRow(2).getCell(0);
if (cell != null) cell.setCellValue( cell.getStringCellValue() + loginUser.descript );
//審查單位名稱
cell = sheet.getRow(3).getCell(0);
if (cell != null) cell.setCellValue( cell.getStringCellValue() + common.Comm.getCodeTitle(stmt2, loginUser.branch, "division", "id", "title") );
//製表日期
cell = sheet.getRow(2).getCell(3);
if (cell != null) cell.setCellValue( cell.getStringCellValue() + AbDate.getToday(".") );


//讀取資料
if (srch.length() >= 0) {
    //計算筆數
    int total = 0;
    String qs = "select count(*) from staff2" + srch;
    rs = common.Comm.querySQL(stmt, qs);
    if (rs.next()) total = rs.getInt(1);
    rs.close();

    //移動列數
    int rownum = 5; //略過列數
    sheet.shiftRows(rownum, sheet.getLastRowNum(), total, true, false);

    DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
    qs = "select * from staff2 " + srch + " order by branch, department, id";
    rs = common.Comm.querySQL(stmt, qs);
    while (rs.next()) {
        Staff staff = new Staff(rs);
        String logindate = (staff.logindate == null) ? "" : df.format(staff.logindate);

        String auth = "";
        String memo = "";
        String privilege = staff.privilege;
        if (sysModules.hasPrivelege(0, privilege)) {
            auth += "A,";
            memo = "系統管理者";
        }
        if (sysModules.hasPrivelege(1, privilege)) auth += "B,";
        if (sysModules.hasPrivelege(2, privilege)) auth += "C,";
        if (sysModules.hasPrivelege(3, privilege)) auth += "D,";
        if (sysModules.hasPrivelege(4, privilege)) auth += "E,";
        if (sysModules.hasPrivelege(10, privilege)) auth += "K,";
        if (sysModules.hasPrivelege(11, privilege)) auth += "L,";
        if (auth.length() > 0) auth = auth.substring(0, auth.length()-1);

        XSSFRow row = sheet.createRow( rownum++ );
        int cellnum = 0;
        row.createCell(0).setCellValue( staff.id.substring(0,3) + "*******" );
        row.createCell(1).setCellValue( staff.descript );
        row.createCell(2).setCellValue( staff.job );
        row.createCell(3).setCellValue( common.Comm.getCodeTitle(stmt2, staff.branch, "division", "id", "title") );
        row.createCell(4).setCellValue( staff.department );
        row.createCell(5).setCellValue( auth );
        row.createCell(9).setCellValue( memo );
        row.createCell(10).setCellValue( logindate );
        row.createCell(11).setCellValue( staff.tel );
    }
    rs.close();
}

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
