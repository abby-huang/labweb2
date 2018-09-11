<%@ page errorPage="../ErrorPage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.net.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "藍領外國人雇主依業別、現僱人數、國籍別查詢 - 雇主地址";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();
response.setContentType("text/plain; charset=MS950");
response.setHeader("Content-Disposition", "attachment; filename=QryEmpKindText.txt");

//尚未登入
if (!userLogin.equals("Y") || !userOpblue.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
String errMsg = "";
Connection con = null;

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
Statement stmt = con.createStatement();
String qs;

//取得輸入資料
String citycode = strCheckNull( request.getParameter("citycode") );
String bizseq = strCheckNull( request.getParameter("bizseq") );

//儲存檔案名稱
ResourceBundle prop = ResourceBundle.getBundle("appmain", Locale.getDefault());
//讀取路徑資料
String dataPath = prop.getString("dataPath");
dataPath = new String(dataPath.getBytes("ISO8859-1"), "Big5").trim(); //讀取 Big5
String infile = dataPath + File.separator + "EmpList-" + citycode + "-" + bizseq + ".txt";

//寫入日誌檔
//縣市轄區
String citytitle = "";
int ibiz = Integer.parseInt(bizseq);
if (citycode.length() > 0) {
    qs = "select cityname from fpv_citym"
            + " where citytype='A' and citycode = " + AbSql.getEqualStr(citycode);
    ResultSet     rs = common.Comm.querySQL(stmt, qs);
    if (rs.next()) citytitle = strCheckNull( rs.getString(1) ).trim().replaceAll("　+$", "");
    rs.close();
}
String srchdata = "雇主地址：" + citytitle;
srchdata += "，行職業別：" + bizkinds[ibiz];
common.Comm.logOpData(stmt, userData, "EmpList", srchdata, userAddr);


//關閉連線
stmt.close();
if (con != null) con.close();

String outfile = "清冊-" + citytitle + "-" +  bizkinds[ibiz] + ".txt";
session.setAttribute("infile", infile);
session.setAttribute("outfile", outfile);
session.setAttribute("filetype", "text");
response.sendRedirect(appRoot + "/servlet/DownFile");
//response.sendRedirect(appRoot + "/servlet/DownFile?infile=" + URLEncoder.encode(infile, "Big5") + "&outfile=" + URLEncoder.encode(outfile, "Big5"));

%>


<html>
<head>
<%@ include file="/include/Header.inc" %>
</head>

<BODY bgcolor="#F9CD8A">

<%=infile%>

</BODY>
</HTML>

