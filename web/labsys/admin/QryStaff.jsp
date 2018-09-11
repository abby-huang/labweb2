<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page buffer="2000kb" autoFlush="true" %>
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

String pageHeader = "使用者名冊查詢";
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

String action = AbString.rtrimCheck(request.getParameter("action") );
String qbranch = AbString.rtrimCheck(request.getParameter("qbranch") );
String qlogindate = AbString.rtrimCheck( request.getParameter("qlogindate") );

if (action.equals("重新輸入")) {
    qbranch = "";
    qlogindate = "";
}
if (!loginUser.branch.equals("0000") && (qbranch.length() == 0)) qbranch = loginUser.branch;

session.setAttribute("QryStaff_qbranch", qbranch);
session.setAttribute("QryStaff_qlogindate", qlogindate);

String srch = "";
if (qbranch.length() > 0) srch += " and branch = " + AbSql.getEqualStr(qbranch);
if (qlogindate.length() > 0) srch += " and (logindate < TO_DATE(" + AbSql.getEqualStr(qlogindate)
        + ", 'YYYY-MM-DD') or logindate is null)";

if (srch.length() > 0) srch = " where " + srch.substring(4);


%>

<!DOCTYPE html>
<html>

<head>
    <title><%=Consts.appTitle%>--<%=pageHeader%></title>
    <META http-equiv="X-UA-Compatible" content="IE=EDGE,CHROME=1">

    <%@ include file="../part/JsCss.jsp" %>
    <script language="javascript" src="<%=Consts.jsRoot%>/My97DatePicker/WdatePicker.js"></script>
    <script type="text/javascript">
        //起始參數
        var sysErrMsg = '<%=errMsg%>';

        $(document).ready(function() {
            //系統起始參數與設定
            initSysData();
        });

    </script>

    <style type="text/css">
        /*toolbar 高度*/
        .ui-jqgrid .ui-userdata {
            height:32px; /* default value in ui.jqgrid.CSS is 21px */
        }
    </style>


</head>

<body>
    <!-- 表頭與功能表 -->
    <jsp:include page="<%=Consts.menuFile%>"></jsp:include>

    <center>
    <!--行蹤不明查詢-->
    <form id="frmMain" action="" method=post>
        <div style="margin:0px; padding: 20px 0px 0px 0px;">
            <table class="tablefrm3" style="width:800px;">
                <tr>
                    <th colspan=2 align="center" style="font:15px 標楷體;">
                        使用者名冊查詢
                    </th>
                </tr>
                <tr>
                    <td class="ab-frmlb1" style="border:0px;" align="center" width="90%">
                        <input type="hidden" name="action" value="">
                        <input class="ab-btn" style="float:center; width:70px;" name="" type="button" value="查詢"
                                onclick="this.form.action.value=this.value; this.form.submit();">
                        <input class="ab-btn" style="float:center; width:70px;" name="" type="button" value="重新輸入"
                                onclick="this.form.action.value=this.value; this.form.submit();">
                        <input class="ab-btn" style="float:center; width:70px;" name="" type="button" value="名冊下載"
                                onclick="window.open('QryStaffExcel.jsp', '_blank');">
                    </td>
                </tr>
            </table>
        </div>

        <div style="margin:0px; padding: 3px 0px 0px 0px;">
            <table class="tablefrm3" style="width:800px;">
                <tr>
                    <td class="ab-frmlb1" align="right" width=10%>單位</td>
                    <td class="ab-frmlb1" align="left" width=40%>
                        <select class="ab-sel" style="width:250px; font-size:13px;" id="qbranch" name="qbranch" size=1>
                            <%if (loginUser.branch.equals("0000")) {%>
                                <option value=''>全部</option>
                            <%}%>
                            <%
                            String qs = "select * from division order by id";
                            rs = common.Comm.querySQL(stmt, qs);
                            while (rs.next()) {
                                String id = AbString.rtrimCheck( rs.getString("id") );
                                String title = AbString.rtrimCheck( rs.getString("title") );
                                String selected = (qbranch.equals(id)) ? "selected" : "";
                                if (loginUser.branch.equals("0000") || loginUser.branch.equals(id)) {

                            %>
                                <%="<option value='" + id + "' " + selected + ">" + title + "</option>"%>
                            <%
                                }
                            }
                            rs.close();
                            %>
                        </select>
                    <td class="ab-frmlb1" align="right" width=15%>未登入開始日期</td>
                    <td class="ab-frmlb1" align="left width=35%">
                        <input class="Wdate" style="height:16px; margin:1px; width:90px;" type="text" name="qlogindate" value="<%=qlogindate%>" onClick="WdatePicker()" onFocus="WdatePicker()">
                        至今
                    </td>
                </tr>
            </table>
        </div>
    </form>

        <div style="margin:0px; padding: 3px 0px 0px 0px;">
            <table class="tablefrm3" style="width:800px;">
                <tr>
                    <td class="ab-frmlbl" align="center" width="80">帳號</td>
                    <td class="ab-frmlbl" align="center" width="80">使用人員</td>
                    <td class="ab-frmlbl" align="center" width="100">職稱</td>
                    <td class="ab-frmlbl" align="center" width="170">單位</td>
                    <td class="ab-frmlbl" align="center" width="100">部門</td>
                    <td class="ab-frmlbl" align="center" width="90">現有權限</td>
                    <td class="ab-frmlbl" align="center" width="80">備註</td>
                    <td class="ab-frmlbl" align="center" width="90">上次登入時間</td>

                </tr>
                <%
                //顯示資料
                if (srch.length() >= 0) {
                    DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
                    qs = "select * from staff2 " + srch + " order by branch, department, id";
                    rs = common.Comm.querySQL(stmt, qs);
                    while (rs.next()) {
                        Staff staff = new Staff(rs);
                        staff.id = AbString.leftJustify(staff.id, 20);
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
                %>

                <tr>
                    <td align="left"><%=(staff.id.substring(0,3) + "*******")%></td>
                    <td align="left"><%=(staff.descript)%></td>
                    <td align="left"><%=(staff.job)%></td>
                    <td align="left"><%=(common.Comm.getCodeTitle(stmt2, staff.branch, "division", "id", "title"))%></td>
                    <td align="left"><%=(staff.department)%></td>
                    <td align="left"><%=(auth)%></td>
                    <td align="left"><%=(memo)%></td>
                    <td align="left"><%=(logindate)%></td>

                </tr>


                <%
                    }
                    rs.close();
                }
                %>
            </table>
        </div>

        <br/><br/>

    </center>

</body>

</html>

<%
//關閉連線
if (stmt != null) stmt.close();
if (stmt2 != null) stmt2.close();
if (conn != null) conn.close();
%>
