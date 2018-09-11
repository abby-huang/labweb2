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
Statement stmt2 = conn.createStatement();
ResultSet rs;
String qs;

String execute = AbString.rtrimCheck(request.getParameter("execute") );
String qbranch = AbString.rtrimCheck(request.getParameter("qbranch") );
String qsdate = AbString.rtrimCheck(request.getParameter("qsdate") );
String qedate = AbString.rtrimCheck(request.getParameter("qedate") );
String qstime = AbString.rtrimCheck(request.getParameter("qstime") );
String qetime = AbString.rtrimCheck(request.getParameter("qetime") );

//頁數
int p = 1;
int totItem = 0;
int ptot = 0;
try {
    p = Integer.parseInt(request.getParameter("p"));
} catch (Exception e) {
}

if (execute.length() == 0) {
    qbranch = AbString.rtrimCheck( (String)session.getAttribute(Consts.appName + "_" + funcid + "_qbranch") );
    qsdate = AbString.rtrimCheck( (String)session.getAttribute(Consts.appName + "_" + funcid + "_qsdate") );
    qedate = AbString.rtrimCheck( (String)session.getAttribute(Consts.appName + "_" + funcid + "_qedate") );
    qstime = AbString.rtrimCheck( (String)session.getAttribute(Consts.appName + "_" + funcid + "_qstime") );
    qetime = AbString.rtrimCheck( (String)session.getAttribute(Consts.appName + "_" + funcid + "_qetime") );
}

//第一次
String isquery = AbString.rtrimCheck( request.getParameter("isquery") );
if ((execute.equals("重新輸入")) || (isquery.length() == 0)) {
    qsdate = AbDate.getToday();
    qedate = qsdate;
    qstime = "22:00:00";
    qetime = "06:00:00";
    p = 1;
}

session.setAttribute(Consts.appName + "_" + funcid + "_qbranch", qbranch);
session.setAttribute(Consts.appName + "_" + funcid + "_qsdate", qsdate);
session.setAttribute(Consts.appName + "_" + funcid + "_qedate", qedate);
session.setAttribute(Consts.appName + "_" + funcid + "_qstime", qstime);
session.setAttribute(Consts.appName + "_" + funcid + "_qetime", qetime);


if ((qsdate.length() == 0) || !AbDate.isValidDate(qsdate)) errMsg = "下載日期錯誤";
if ((qedate.length() == 0) || !AbDate.isValidDate(qedate)) errMsg = "下載日期錯誤";
if(!qstime.matches("([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]")) errMsg = "下載時間錯誤";
if(!qetime.matches("([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]")) errMsg = "下載時間錯誤";

String srch = "";
if (errMsg.length() == 0) {

    if (!loginUser.branch.equals("0000") && (qbranch.length() == 0)) qbranch = loginUser.branch;

    if (qbranch.length() > 0) srch += " and division = " + AbSql.getEqualStr(qbranch);
    srch += " and opdate >= " + AbSql.getEqualStr(qsdate);
    srch += " and opdate <= " + AbSql.getEqualStr(qedate);

    if (qetime.compareTo(qstime) >= 0) { //同一日
        srch += " and optime >= " + AbSql.getEqualStr(qstime);
        srch += " and optime <= " + AbSql.getEqualStr(qetime);
    } else { //跨日
        srch += " and ( optime >= " + AbSql.getEqualStr(qstime);
        srch += " or optime <= " + AbSql.getEqualStr(qetime) + " )";
    }

    if (srch.length() > 0) {
        srch = " where " + srch.substring(4);
    }
}

//計算筆數
qs = "select count(*) from logdata" + srch;
rs = common.Comm.querySQL(stmt, qs);
rs.next();
totItem = rs.getInt(1);
rs.close();

//計算頁數
 ptot = ((totItem-1) / pmax) + 1;

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

    <!--異常使用名冊查詢-->
    <form id="frmMain" action="<%=thisPage%>" method=post>
        <input type="hidden" name="execute" value="">
        <input type="hidden" name="p" value="1">
        <input name="isquery" type="hidden" value="Y">
        <input name="srch" type="hidden" value="<%=srch%>">

        <div style="margin:0px; padding: 20px 0px 0px 0px;">
            <table class="tablefrm3" style="width:1000px;">
                <tr>
                    <th colspan=2 align="center" style="font:15px 標楷體;">
                        異常使用名冊查詢
                    </th>
                </tr>
                <tr>
                    <td style="border:0px;" align="center" width="90%">
                        <input class="ab-btn" style="float:center; width:70px;" name="" type="button" value="查詢"
                                onclick="this.form.execute.value=this.value; this.form.submit();">
                        <input class="ab-btn" style="float:center; width:70px;" name="" type="button" value="重新輸入"
                                onclick="this.form.execute.value=this.value; this.form.submit();">
                        <input class="ab-btn" style="float:center; width:70px;" name="" type="button" value="名冊下載"
                                onclick="this.form.action='/labweb/common/LogDataExcel.jsp'; this.form.submit();">
                    </td>
                </tr>
            </table>
        </div>

        <div style="margin:0px; padding: 3px 0px 0px 0px;">
            <table class="tablefrm3" style="width:1000px;">
                <tr>
                    <td class="ab-frmlb1" align="right" width=8%>單位</td>
                    <td align="left" width=28%>
                        <select class="ab-sel" style="width:250px; font-size:13px;" id="qbranch" name="qbranch" size=1>
                            <%if (loginUser.branch.equals("0000")) {%>
                                <option value=''>全部</option>
                            <%}%>
                            <%
                            qs = "select * from division order by id";
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
                    <td class="ab-frmlb1" align="right" width=8%>下載日期</td>
                    <td width=22%>
                        <input type="text" name="qsdate" maxlength="8" size="8" value="<%=qsdate%>">
                        ～
                        <input type="text" name="qedate" maxlength="8" size="8" value="<%=qedate%>">
                    </td>
                    <td class="ab-frmlb1" align="right" width=10%>異常下載時間</td>
                    <td width=*>
                        <input type="text" name="qstime" maxlength="8" size="8" value="<%=qstime%>">
                        ～
                        <input type="text" name="qetime" maxlength="8" size="8" value="<%=qetime%>">
                    </td>
                </tr>
            </table>
        </div>
    </form>

        <div style="margin:0px; padding: 3px 0px 0px 0px;">
            <table class="tablefrm3" style="width:1000px;">
                <!--頁數-->
                <tr>
                    <td colspan="10">
                        第<%=p%>/<%=ptot%>頁 [<%=totItem%>筆]&nbsp;
                        <%  //顯示頁數
                        if (p > ptot) p = ptot;
                        int p0 = p - 4;
                        if (p0 < 1) p0 = 1;
                        if (ptot > 1) {
                        if (p > 1) {
                            out.print("<font class='ab-page'><a class='ab-a2' href='" + thisPage + "?p=" + (p-1) + "&isquery=Y'>上頁</a></font>");
                        } else {
                            out.print("<font class='ab-pagedim'>上頁</font>");
                        }

                        for (int i = 0; ((i+p0) <= ptot) && (i < 10); i++) {
                            if ((i+p0) == p) {
                                out.print("<font class='ab-pageunsel'>&nbsp;" + AbString.intPadZero(i+p0, 2) + "</font>");
                            } else {
                                out.print("<font class='ab-page'>&nbsp;<a class='ab-a2' href='"
                                + thisPage + "?p=" + (i+p0) + "&isquery=Y'>" + AbString.intPadZero(i+p0, 2) + "</a></font>");
                            }
                        }

                        if ((p*pmax) < totItem) {
                            out.print("<font class='ab-page'>&nbsp;<a class='ab-a2' href='" + thisPage + "?p=" + (p+1) + "&isquery=Y'>下頁</a></font>");
                        } else
                            out.print("<font class='ab-pagedim'>&nbsp;下頁</font>");
                        }
                        %>
                    </td>
                </tr>

                <tr>
                    <th align="center" style="width:80px;">日誌代碼</th>
                    <th align="center" style="width:135px;">日誌說明</th>
                    <th align="center" style="width:100px;">單位名稱</th>
                    <th align="center" style="width:50px;">姓名</th>
                    <th align="center" style="width:60px;">ID</th>
                    <th align="center" style="width:55px;">下載日期</th>
                    <th align="center" style="width:55px;">下載時間</th>
                    <th align="center" width="*">查詢條件</th>
                </tr>

<%
if (errMsg.length() == 0) {
    qs = "select logdata.*, division.title as divtitle"
        + " from logdata left join division on logdata.division=division.id"
        + srch
        + " order by opdate desc, optime desc, division, userid";
    stmt = conn.createStatement();
    rs = common.Comm.querySQL(stmt, qs);
    for (int i=0; i < ((p-1)*pmax); i++) {
    rs.next();
    }
    int cnt = 0;
    while (rs.next() && (cnt < pmax)) {
        cnt++;
        String logid = AbString.rtrimCheck(rs.getString("logid"));
        String divtitle = AbString.rtrimCheck(rs.getString("divtitle"));
        String descript = AbString.rtrimCheck(rs.getString("descript"));
        String userid = AbString.rtrimCheck(rs.getString("userid"));
        String opdate = AbString.rtrimCheck(rs.getString("opdate"));
        String optime = AbString.rtrimCheck(rs.getString("optime"));
        String data = AbString.rtrimCheck(rs.getString("data"));
        if (userid.length() > 3) userid = userid.substring(0,3) + String.join("", Collections.nCopies(userid.length()-3, "*"));
%>
                <tr>
                    <td align="left"><%=logid%></td>
                    <td align="left"><%=common.Comm.getCodeTitle(stmt2, logid, "logid", "logid", "descript")%></td>
                    <td align="left"><%=divtitle%></td>
                    <td align="left"><%=descript%></td>
                    <td align="left"><%=userid%></td>
                    <td align="left"><%=opdate%></td>
                    <td align="left"><%=optime%></td>
                    <td align="left"><%=data%></td>
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

<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
</script>
<%}%>
