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

String pageHeader = "已刪除的使用者";
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

if (action.equals("重新輸入")) {
    //qbranch = userData.branch;
    qbranch = "";
}

String srch = "";
if (qbranch.length() > 0) srch += " and division = " + AbSql.getEqualStr(qbranch);

if (srch.length() > 0) srch = " where " + srch.substring(4);


%>

<!DOCTYPE html>
<html>

<head>
    <title><%=Consts.appTitle%>--<%=pageHeader%></title>
    <META http-equiv="X-UA-Compatible" content="IE=EDGE,CHROME=1">

    <%@ include file="../part/JsCss.jsp" %>
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
            <table class="tablefrm3" style="width:530px;">
                <tr>
                    <th colspan=2 align="center" style="font:15px 標楷體;">
                        已刪除的使用者
                    </th>
                </tr>
                <tr>
                    <td class="ab-frmlb1" style="border:0px;" align="center" width="90%">
                        <input type="hidden" name="action" value="">
                        <input class="ab-btn" style="float:center; width:70px;" name="" type="button" value="查詢"
                                onclick="this.form.action.value=this.value; this.form.submit();">
                        <input class="ab-btn" style="float:center; width:70px;" name="" type="button" value="重新輸入"
                                onclick="this.form.action.value=this.value; this.form.submit();">
                    </td>
                </tr>
            </table>
        </div>

        <div style="margin:0px; padding: 3px 0px 0px 0px;">
            <table class="tablefrm3" style="width:530px;">
                <tr>
                    <td class="ab-frmlb1" align="right" width=30%>單位</td>
                    <td class="ab-frmlb1" align="left" width=70%>
                        <select class="ab-sel" style="width:250px; font-size:13px;" id="qbranch" name="qbranch" size=1>
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
                </tr>
            </table>
        </div>
    </form>

        <div style="margin:0px; padding: 3px 0px 0px 0px;">
            <table class="tablefrm3" style="width:530px;">
                <tr>
                    <td class="ab-frmlbl" align="center" width="80">帳號</td>
                    <td class="ab-frmlbl" align="center" width="80">使用人員</td>
                    <td class="ab-frmlbl" align="center" width="200">單位</td>
                    <td class="ab-frmlbl" align="center" width="80">刪除人員</td>
                    <td class="ab-frmlbl" align="center" width="80">刪除日期</td>

                </tr>
                <%
                //顯示資料
                if (srch.length() > 0) {
                    DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
                    qs = "select * from staff_cancel " + srch + " order by division, mntdate desc, id";
                    rs = common.Comm.querySQL(stmt, qs);
                    while (rs.next()) {
                        String id = AbString.rtrimCheck( rs.getString("id") );
                        String division = AbString.rtrimCheck( rs.getString("division") );
                        String title = AbString.rtrimCheck( rs.getString("title") );
                        String tel = AbString.rtrimCheck( rs.getString("tel") );
                        String region = AbString.rtrimCheck( rs.getString("region") );
                        String mntuser = AbString.rtrimCheck( rs.getString("mntuser") );
                        String mntdate = AbString.rtrimCheck( rs.getString("mntdate") );

                %>

                <tr>
                    <td align="left"><%=(id.substring(0,3) + "*******")%></td>
                    <td align="left"><%=(title)%></td>
                    <td align="left"><%=(common.Comm.getCodeTitle(stmt2, division, "division", "id", "title"))%></td>
                    <td align="left"><%=(mntuser)%></td>
                    <td align="left"><%=(mntdate)%></td>

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
