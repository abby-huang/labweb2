<%@ page errorPage="../ErrorPage.jsp" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page import="org.apache.commons.io.*"%>
<%@ page import="org.apache.commons.net.ftp.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "撤銷聘僱檔解黑名單重接收及即時下載作業（.wit檔 -exexpirlab）";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || !userOptrans_linwu.equals("Y")) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
int pageRows = 100;
String tblname = "exfpv_exexpirlab";
String trans_date = "trandate";
String errMsg = "";
Connection con = null;

//取得輸入資料
String action = AbString.rtrimCheck(request.getParameter("action"));
String qexpirwpno = AbString.rtrimCheck(request.getParameter("qexpirwpno")).toUpperCase();
String rowids[] = new String[pageRows];
String seldata[] = new String[pageRows];
for (int i=0; i < pageRows; i++) seldata[i] = AbString.rtrimCheck(request.getParameter("seldata"+i));
for (int i=0; i < pageRows; i++) rowids[i] = AbString.rtrimCheck(request.getParameter("rowids"+i));

//建立連線
con = getConnection( session );
if (con == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
Statement stmt = con.createStatement();
ResultSet rs;
String qs="";

if (action.equals("清除條件")) {
    qexpirwpno = "";
} else if (action.equals("執行清除傳輸日期欄位")) {
    for (int i=0; i < pageRows; i++) {
        if (seldata[i].equals("on")) {
            qs = "update " + tblname + " set " + trans_date + " = '' where rowid = '" + rowids[i] + "'";
            common.Comm.updateSQL(stmt, qs);
/*
提醒abby：再加一段程式，用exexpirelab的資料，直接下載成.wit檔，而.wit檔中的canceltype直接寫入2
程式應取用ExportWit.java 領務局專用，即時下載的.wit檔檔名取用日期+"_"+文號.wit，存入領務局的下載目錄中
*/
            //輸出下載檔
            errMsg = outputWit(con, rowids[i]);
            if (errMsg.length() == 0) {
                qexpirwpno = "";
                errMsg = "已經產生下載檔";
            }
        }
    }
}

%>



<%!

//輸出下載檔
String outputWit(Connection conn, String rowid) throws Exception {
    String retval = "";
    Statement stmt = conn.createStatement();
    Statement stmt2 = conn.createStatement();
    String today = AbDate.getToday();

    //讀取資料
    String lineText = today;
    String expirwpno = "";
    String qs = "select * from exfpv_exexpirlab m where rowid='" + rowid + "'";
    ResultSet rs = common.Comm.querySQL(stmt, qs);
    if (rs.next()) {
        String labono = AbString.rtrimCheck(rs.getString("labono"));
        String natcode = AbString.leftJustify(labono, 13).substring(0, 3).trim();
        String passno = AbString.leftJustify(labono, 13).substring(3).trim();
        expirwpno = AbString.rtrimCheck(rs.getString("expirwpno"));

        String engname = "";
        String birthday = "";
        qs = "select engname, birthday from labdyn_laborm"
                + " where natcode = " + AbSql.getEqualStr( natcode )
                + " and passno = " + AbSql.getEqualStr( passno );
        ResultSet rs2 = common.Comm.querySQL(stmt2, qs);
        if (rs2.next()) {
            engname = AbString.rtrimCheck(rs2.getString("engname"));
            birthday = AbString.rtrimCheck(rs2.getString("birthday"));
        }
        rs2.close();

        //ls_chng_id = "D"
        String ls_chng_id = "D";

        lineText += AbString.leftJustify( ls_chng_id, 1 );
        lineText += AbString.leftJustify( "", 3 );
        lineText += AbString.leftJustify( AbString.getBig5String(natcode).trim(), 3 );
        lineText += AbString.leftJustify( "", 10 );
        lineText += AbString.leftJustify( AbString.getBig5String(passno).trim(), 10 );
        lineText += AbString.leftJustify( "", 10 );
        lineText += AbString.leftJustify( AbString.getBig5String(rs.getString("expirwpno")).trim(), 10 );
        lineText += AbString.leftJustify( AbString.getBig5String(engname), 50 );
        lineText += AbString.leftJustify( AbString.getBig5String(birthday), 8 );
        lineText += AbString.leftJustify( AbString.getBig5String(rs.getString("indate")).trim(), 8 );
        lineText += AbString.leftJustify( AbString.getBig5String(rs.getString("outdate")).trim(), 8 );
        lineText += AbString.leftJustify( AbString.getBig5String(rs.getString("expirdate")).trim(), 8 );
        lineText += AbString.leftJustify( AbString.getBig5String(rs.getString("dynodate")).trim(), 8 );
        lineText += AbString.leftJustify( AbString.getBig5String(rs.getString("happcode")).trim(), 3 );
        lineText += AbString.leftJustify( AbString.getBig5String(rs.getString("laborcode")).trim(), 2 ) + " ";
        lineText += "\r\n";
    }
    rs.close();
    String filename = today + "_" + expirwpno + "_" + rowid.replace("/", "") + ".wit";
    //String filename = today + "_" + expirwpno + "_" + AbDate.getNowTime("") + ".wit";

    //FTP下載資料
    String fptServer = "172.21.45.65";
    String ftpUser = "laboruser";
    String ftpAccess = "Abcd1234";
    String serverDownPath = "EDI/fworker/feedback/linwu";  // 下載主機存放路徑

    FTPClient ftpClient = new FTPClient();
    try {

        ftpClient.connect(fptServer);
        if(!FTPReply.isPositiveCompletion(ftpClient.getReplyCode())) {
            return "FTP 無法連接 Error: " + ftpClient.getReplyCode();
        }
        ftpClient.login(ftpUser, ftpAccess);
        if(!FTPReply.isPositiveCompletion(ftpClient.getReplyCode())) {
            ftpClient.disconnect();
            return "FTP 無法登入 Error: " + ftpClient.getReplyCode();
        }
        ftpClient.enterLocalPassiveMode();

        InputStream inputStream = IOUtils.toInputStream(lineText, "UTF-8");
        boolean done = ftpClient.storeFile(serverDownPath + "/" + filename, inputStream);
        inputStream.close();
        if (!done) {
            retval = "FTP 無法傳輸檔案 Error: " + ftpClient.getReplyCode();
        }
    } catch (Exception e) {
        retval = "FTP 無法開啟: " + e.getMessage();
    } finally {
        if (ftpClient.isConnected()) {
            ftpClient.logout();
            ftpClient.disconnect();
        }
    }

    return retval;
}

%>


<html>
    <head>
        <%@ include file="/include/HeaderTimeout.inc" %>
    </head>

    <body bgcolor="#F9CD8A" text="#990000">
        <center>
            <form action ="<%=thisPage%>" method="post">
                <div style="height:10px;"></div>
                <table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="600">
                    <tr bgcolor="#FF9900">
                        <td colspan=4><img src="../image/arrow.gif" alt="美化圖形">
                            <font color="#FFFFFF"><%=pageHeader%></font>
                        </td>
                    </tr>
                    <tr >
                        <td width=25% align=right>撤銷文號：</td>
                        <td width=25% colspan="3"><input type="text" name="qexpirwpno" value="<%=qexpirwpno%>" size="12"></td>
                    </tr>
                    <tr >
                        <td align="center" colspan=4>
                            <input name="action" value="查詢資料" type=submit>
                            <input name="action" value="清除條件" type=submit>
                        </td>
                    </tr>
                </table>
            </form>


<%
//限制條件
String srch = "";
if (qexpirwpno.length() > 0) srch += " and expirwpno = " + AbSql.getEqualStr(qexpirwpno);
//if (srch.length() > 0) srch += " and substr(laborcode,0,2)='LA' and (happcode='HDE' or happcode='HC3')";
if (srch.length() > 0) srch = " where " + srch.substring(4);

/*
提醒abby：再加上 if (happcode.equals("HDE") || happcode.equals("HC3")) && laborcode前2碼是LA
若是不符上述條件而找不到任一筆資料時，應回應 "本筆撤銷資料不屬於解黑名單作業"
*/

//查詢動作 - 顯示資料
if (srch.length() > 0) {
    //頁數
    int p = 1;

    //寫入日誌檔
    String srchdata = "    ";
    if (qexpirwpno.length() > 0) srchdata += "，撤銷文號：" + qexpirwpno;

    common.Comm.logOpData(stmt, userData, "logClrtransdate", srchdata, userAddr);

%>


    <form action ="<%=thisPage%>" method="post" onsubmit="return confirm('確定要清除傳輸日期欄位嗎？');">
        <input type="hidden" name="qexpirwpno" value="<%=qexpirwpno%>">

        <table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="600">
            <tr bgcolor="#FF9900">
                <td align="left" colspan="8">
                    <input name="action" value="執行清除傳輸日期欄位" type=submit>
                    (只執行被勾選者)
                </td>
            </tr>
            <tr bgcolor="#FF9900">
                <td width=40 align="center">&nbsp;</td>
                <td width=80 align="center">傳輸日期</td>
                <td width=80 align="center">國籍代碼</td>
                <td width=85 align="center">護照號碼</td>
                <td width=70 align="center">laborcode</td>
                <td width=70 align="center">happcode</td>
                <td width=85 align="center">雇主編號</td>
                <td width=80 align="center">異動情形</td>
            </tr>
<%
    //顯示資料
    qs = "select" + (sqlFirstCmd.length() > 0 ? sqlFirstCmd + (p*pageRows) : "") + " rowid, m.* from " + tblname + " m " + srch
            + " order by labono";
    rs = common.Comm.querySQL(stmt, qs);
    for (int i = 0; i < ((p - 1) * pageRows); i++) {
        rs.next();
    }
    int cnt = 0;
    while (rs.next()) {
        cnt++;
        String rowid = AbString.rtrimCheck(rs.getString("rowid"));
        String labono = AbString.rtrimCheck(rs.getString("labono"));
        String natcode = AbString.leftJustify(labono, 13).substring(0, 3).trim();
        String passno = AbString.leftJustify(labono, 13).substring(3).trim();
        String expirwpno = AbString.rtrimCheck(rs.getString("expirwpno"));
        String regno = AbString.rtrimCheck(rs.getString("caseno")).substring(0,10).trim();
        String chng_id = AbString.rtrimCheck(rs.getString("chng_id"));
        String tmp_trans_date = strCheckNullHtml(AbString.rtrim(rs.getString(trans_date)));
        String laborcode = AbString.rtrimCheck(rs.getString("laborcode"));
        String happcode = AbString.rtrimCheck(rs.getString("happcode"));
        boolean enabled = laborcode.startsWith("LA") && (happcode.equals("HC3") || happcode.equals("HDE"));
 %>

            <tr>
                <td align="center">
                    <input type="hidden" name="rowids<%=cnt-1%>" value="<%=rowid%>">
                    <% if (enabled) { %>
                    <input type="checkbox" name="seldata<%=cnt-1%>">
                    <% } %>
                </td>
                <td align="center"><%=tmp_trans_date%></td>
                <td align="center"><%=strCheckNullHtml(natcode)%></td>
                <td align="center"><%=strCheckNullHtml(passno)%></td>
                <td align="center"><%=strCheckNullHtml(laborcode)%></td>
                <td align="center"><%=strCheckNullHtml(happcode)%></td>
                <td align="center"><%=strCheckNullHtml(regno)%></td>
                <td align="center"><%=strCheckNullHtml(chng_id)%></td>
            </tr>

<%
    }
    rs.close();
%>
        </table>
    </form>

<%
}
//資料查詢
%>

        <center>
    </body>
</html>

<%
//關閉連線
stmt.close();
if (con != null) con.close();
%>

<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
</script>
<%}%>
