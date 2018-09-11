<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page import="com.absys.user.*"%>
<%@ page import="common.*"%>
<%@ include file="../include/LoginData.jsp" %>

<%
//檢查登入權限
if ((loginUser == null) || !sysModules.hasPrivelege("staff", loginUser.privilege) ) {
    response.sendRedirect(Consts.logoutFile);
}

String pageHeader = "異常使用名冊查詢";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();
String funcid = "QryLogUnusual";

int pmax = 100; //每頁筆數
String errMsg = "";
Connection conn = null;

//建立連線
conn = Comm.getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
Statement stmt = conn.createStatement();
ResultSet rs;
String qs;


%>

<!DOCTYPE html>
<html>

<head>
    <title><%=Consts.appTitle%>--<%=pageHeader%></title>
    <META http-equiv="X-UA-Compatible" content="IE=EDGE,CHROME=1">

    <%@ include file="../part/JsCss.jsp" %>
    <script language="javascript" src="<%=Consts.jsRoot%>/My97DatePicker/WdatePicker.js"></script>

    <script src="<%=Consts.jsRoot%>/simplePagination/jquery.simplePagination.js" id="menuScript" type="text/javascript"></script>
    <link href="<%=Consts.jsRoot%>/simplePagination/simplePagination.css" rel="stylesheet" type="text/css" />

    <script src="QryLogUnusual.js?<%=Consts.jsver%>" type="text/javascript"></script>

    <script type="text/javascript">
        //起始參數
        var sysErrMsg = '<%=errMsg%>';
    </script>

    <style>
    </style>

</head>

<body style="overflow-y: scroll;">
    <!-- 表頭與功能表 -->
    <jsp:include page="<%=Consts.menuFile%>"></jsp:include>

    <center>

    <!--異常使用名冊查詢-->
    <div style="margin:0px; padding: 20px 0px 0px 0px;">
        <table class="tablefrm3" style="width:1000px;">
            <tr>
                <th colspan=2 style="text-align: center; font:15px 標楷體;">
                    異常使用名冊查詢
                </th>
            </tr>
            <tr>
                <td style="text-align: center;">
                    <input id="bPost" type="button" value="查詢" style="font-size: 13px; padding: 2px; width:70px;">
                    <input id="bReset" type="button" value="重新輸入" style="font-size: 13px; padding: 2px; width:70px;">
                    <input id="bExport" type="button" value="名冊下載" style="font-size: 13px; padding: 2px; width:70px;">
                </td>
            </tr>
        </table>
    </div>

    <form id="formQuery" name="formQuery">
    <div style="margin:0px; padding: 3px 0px 0px 0px;">
        <table class="tablefrm3" style="width:1000px;">
            <tr>
                <td class="ab-frmlb1" style="width: 8%; text-align: right;">單位</td>
                <td style="width: 28%;">
                    <select class="ab-sel" style="width:250px; font-size:13px; color: black;" name="branch" size=1>
                        <%if (loginUser.branch.equals("0000")) {%>
                            <option value='' selected>全部</option>
                        <%}%>
                        <%
                        qs = "select * from division order by id";
                        rs = stmt.executeQuery(qs);
                        while (rs.next()) {
                            String id = AbString.rtrimCheck( rs.getString("id") );
                            String title = AbString.rtrimCheck( rs.getString("title") );
                            if (loginUser.branch.equals("0000") || loginUser.branch.equals(id)) {

                        %>
                            <%="<option value='" + id + "'>" + title + "</option>"%>
                        <%
                            }
                        }
                        rs.close();
                        %>
                    </select>
                <td class="ab-frmlbl" style="width: 8%; text-align: right;">下載日期</td>
                <td  style="width: 22%;">
                    <input class="ab-inp" type="text" name="sdate" maxlength="8" size="8">
                    ～
                    <input class="ab-inp" type="text" name="edate" maxlength="8" size="8">
                </td>
                <td class="ab-frmlbl" style="width: 10%; text-align: right;">異常下載時間</td>
                <td width=*>
                    <input class="ab-inp" type="text" name="stime" maxlength="8" size="8">
                    ～
                    <input class="ab-inp" type="text" name="etime" maxlength="8" size="8">
                    <input type="checkbox" name="el1">
                </td>
            </tr>
        </table>
    </div>
    </form>

    <div style="margin:0px; padding: 3px 0px 0px 0px;">
        <table id="tableData" class="tablefrm3" style="width:1000px;">
            <!--頁數-->
            <tr>
                <td colspan="10">
                    <div id="paginator" style="height: 28px; vertical-align: middle; display: inline-table;"></div>
                </td>
            </tr>
            <!--標題-->
            <tr>
                <td style="width: 50px; text-align: center;">
                    <span id='bAdd' style='width: 44px; height: 16px; float: center;' title='新增資料'></span>
                </td>
                <th style="width: 80px;">日誌代碼</th>
                <th style="width: 135px;">日誌說明</th>
                <th style="width: 100px;">單位名稱</th>
                <th style="width: 50px;">姓名</th>
                <th style="width: 60px;">ID</th>
                <th style="width: 60px;">下載日期</th>
                <th style="width: 60px;">下載時間</th>
                <th style="width: auto;">查詢條件</th>
            </tr>
        </table>
    </div>

    <br/><br/>

    </center>

</body>

</html>

<%
//關閉連線
if (stmt != null) stmt.close();
if (conn != null) conn.close();
%>

