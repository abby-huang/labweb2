<%@ page errorPage="../ErrorPage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%
String pageHeader = "外勞狀況代碼資料重傳";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

//尚未登入
if (!userLogin.equals("Y") || (!userOptrans_linwu.equals("Y") && !userOptrans_weisen.equals("Y"))) {
    response.sendRedirect("../Logout.jsp");
}

//定義變數
int pageRows = 100;
String tblname = "labdyn_dynalm";
String trans_date = "trans_date";
String errMsg = "";
Connection con = null;

//取得輸入資料
String action = AbString.rtrimCheck(request.getParameter("action"));
String qdynacode = AbString.rtrimCheck(request.getParameter("qdynacode")).toUpperCase();
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
    qdynacode = "";
} else if (action.equals("執行清除傳輸日期欄位")) {
    for (int i=0; i < pageRows; i++) {
        if (seldata[i].equals("on")) {
            //qs = "update " + tblname + " set " + trans_date + " = '', chng_id = '" + clrTransdateID
            //        + "' where rowid = '" + rowids[i] + "'";
            qs = "update " + tblname + " set " + trans_date + " = '' where rowid = '" + rowids[i] + "'";
            common.Comm.updateSQL(stmt, qs);
        }
    }
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
                <table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="500">
                    <tr bgcolor="#FF9900">
                        <td colspan=4><img src="../image/arrow.gif" alt="美化圖形">
                            <font color="#FFFFFF"><%=pageHeader%></font>
                        </td>
                    </tr>
                    <tr >
                        <td width=25% align=right>動態代碼：</td>
                        <td width=25% ><input type="text" name="qdynacode" value="<%=qdynacode%>" size="12"></td>
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
if (qdynacode.length() > 0) srch += " and dynacode = " + AbSql.getEqualStr(qdynacode);
if (srch.length() > 0) srch = " where " + srch.substring(4);

//查詢動作 - 顯示資料
if (srch.length() > 0) {
    //頁數
    int p = 1;

    //寫入日誌檔
    String srchdata = "外勞狀況代碼資料（.dyn檔 - dynalm）";
    if (qdynacode.length() > 0) srchdata += "，動態代碼：" + qdynacode;

    common.Comm.logOpData(stmt, userData, "logClrtransdate", srchdata, userAddr);

%>


    <form action ="<%=thisPage%>" method="post" onsubmit="return confirm('確定要清除傳輸日期欄位嗎？');">
        <input type="hidden" name="qdynacode" value="<%=qdynacode%>">

        <table border=1 bgcolor="#F8BE67" bordercolor="#FF9900" width="332">
            <tr bgcolor="#FF9900">
                <td align="left" colspan="4">
                    <input name="action" value="執行清除傳輸日期欄位" type=submit>
                    (只執行被勾選者)
                </td>
            </tr>
            <tr bgcolor="#FF9900">
                <td width=40 align="center">&nbsp;</td>
                <td width=80 align="center">傳輸日期</td>
                <td width=120 align="center">動態代碼</td>
                <td width=80 align="center">&nbsp;</td>
            </tr>
<%
    //顯示資料
    qs = "select" + (sqlFirstCmd.length() > 0 ? sqlFirstCmd + (p*pageRows) : "") + " rowid, m.* from " + tblname + " m " + srch;
    rs = common.Comm.querySQL(stmt, qs);
    for (int i = 0; i < ((p - 1) * pageRows); i++) {
        rs.next();
    }
    int cnt = 0;
    while (rs.next() && (cnt < pageRows)) {
        cnt++;
        String rowid = AbString.rtrimCheck(rs.getString("rowid"));
        String dynacode = AbString.rtrimCheck(rs.getString("dynacode"));
        String tmp_trans_date = strCheckNullHtml(AbString.rtrim(rs.getString(trans_date)));
%>

            <tr>
                <td align="center">
                    <input type="hidden" name="rowids<%=cnt-1%>" value="<%=rowid%>">
                    <input type="checkbox" name="seldata<%=cnt-1%>">
                </td>
                <td align="center"><%=tmp_trans_date%></td>
                <td align="center"><%=strCheckNullHtml(dynacode)%></td>
                <td align="center">&nbsp;</td>
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
