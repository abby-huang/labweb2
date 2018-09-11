<%@page pageEncoding="UTF-8" contentType="text/html"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.io.*"%>
<%@page import="java.net.*"%>
<%@page import="java.text.*"%>
<%@page import="com.absys.util.*"%>
<!-- JODReports -->
<%@page import="net.sf.jooreports.templates.*"%>
<%@page import="net.sf.jooreports.templates.DocumentTemplate"%>
<%@page import="net.sf.jooreports.templates.DocumentTemplateException"%>
<%@page import="net.sf.jooreports.templates.DocumentTemplateFactory"%>

<%@include file="/include/ComConstants.inc"%>
<%@include file="/include/ComGetLoginData.inc"%>
<%@include file="/include/ComFunctions.inc"%>

<%

String pageHeader = "行蹤不明3日通報書表";
request.setCharacterEncoding("UTF-8");
//String thisPage = request.getRequestURI();
String thisPage = "EscNotify.jsp";

//定義變數
String errMsg = "";
Connection conn = null;
String sessionId = session.getId();

conn = getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
Statement stmt = conn.createStatement();
ResultSet rs;
String qs;

//讀取資料
String natcode = AbString.rtrimCheck( request.getParameter("natcode") );
String nation = common.Comm.getCodeTitle( stmt, natcode, "fpv_natim", "naticode", "natiname");
String passno = AbString.rtrimCheck( request.getParameter("passno") );
String escapedate = AbString.rtrimCheck( request.getParameter("escapedate") );
String engname = "";
String vendno = "";
String vendname = "";
String indate = "";

qs = "select * from labdyn_escapelab"
        + " where natcode=" + AbSql.getEqualStr(natcode)
        + " and passno=" + AbSql.getEqualStr(passno)
        + " and escapedate=" + AbSql.getEqualStr(escapedate);
rs = common.Comm.querySQL(stmt, qs);
if (rs.next()) {
    engname = AbString.rtrimCheck( rs.getString("engname") );
    vendno = AbString.rtrimCheck( rs.getString("vendno") );
    vendname = AbString.rtrimCheck( rs.getString("vendname") );
    indate = AbString.rtrimCheck( rs.getString("indate") );
}
rs.close();


//JODReports 樣板
response.setContentType("application/odt");
response.setHeader("Content-disposition","inline; filename=EscNotifyApply.odt" );

//填入資料
Map parameters = new HashMap();
parameters.put("vendno", vendno);
parameters.put("vendname", vendname);
parameters.put("nation", nation);
parameters.put("passno", passno);
parameters.put("engname", engname);
parameters.put("indate", AbDate.fmtDateTwn(AbDate.YYYYMMDDToTwn(indate), "-"));
parameters.put("escapedate", AbDate.fmtDateTwn(AbDate.YYYYMMDDToTwn(escapedate), "-"));
parameters.put("escapedate2", AbDate.fmtDateTwn(AbDate.YYYYMMDDToTwn(AbDate.dateAdd(escapedate, 0, 0, 1)), "-"));
parameters.put("escapedate3", AbDate.fmtDateTwn(AbDate.YYYYMMDDToTwn(AbDate.dateAdd(escapedate, 0, 0, 2)), "-"));

String rptFilePathTpl = getServletContext().getRealPath("") + "/docx/EscNotifyApply.odt";
File templateFile = new File(rptFilePathTpl);
DocumentTemplateFactory documentTemplateFactory = new DocumentTemplateFactory();
DocumentTemplate template = documentTemplateFactory.getTemplate(templateFile);

ServletOutputStream outputStream = response.getOutputStream();

try {
    template.createDocument(parameters, outputStream);
} catch (DocumentTemplateException e) {
    e.printStackTrace();
}finally {
    outputStream.flush();
    outputStream.close();
}

stmt.close();
conn.close();

%>
