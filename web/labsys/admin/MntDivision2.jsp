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


String pageHeader = "使用者單位管理";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

String errMsg = "";
Connection conn = null;

//建立連線
conn = Comm.getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
Statement stmt = conn.createStatement();
ResultSet rs;
/*
String qs = "select * from division order by id";
rs = stmt.executeQuery(qs);
while (rs.next()) {
    out.println( strCheckNullHtml( AbString.rtrim( rs.getString("id") ) ) + " - ");
    out.println( strCheckNullHtml( AbString.rtrim( rs.getString("title") ) ) + "</br>");
}
rs.close();
*/

String menuApp = "/labsys/part/MenuApp.jsp";
%>

<!DOCTYPE html>

<head>
    <title><%=Consts.appTitle%>--<%=pageHeader%></title>
    <META http-equiv="X-UA-Compatible" content="IE=EDGE,CHROME=1">

    <script type="text/javascript">
        //起始參數
        var pageHeader = '<%=pageHeader%>';
        var sysErrMsg = '<%=errMsg%>';
        var userDivision = '<%=loginUser.branch%>';
        //登入者的權限(主模組） - javascript 使用
        var privList = new Array(<%=sysModules.modulelist.size()%>);
        <%
        //勞動力發展署的帳號權限
        boolean evtaRoot = (loginUser.branch.equals(Consts.evtaId)) &&sysModules.hasPrivelege("staff", loginUser.privilege);
        for (int i=0; i < sysModules.modulelist.size(); i++) {
            //勞動力發展署的帳號權限 -> 全部有權限
            boolean priv = evtaRoot || sysModules.hasPrivelege(i, loginUser.privilege);
            if (!priv && (sysModules.modulelist.get(i).subModule.size() > 0)) { //主模組無權限
                for (int j=0; j < sysModules.modulelist.get(i).subModule.size(); j++) { //檢查子模組
                    priv = sysModules.hasPrivelege(i, j+1, loginUser.privilege);
                    if (priv) break;
                }
            }
        %>
            privList[<%=i+""%>] = <%=priv ? "true" : "false"%>;
        <%
        }
        %>
    </script>

    <%@ include file="../part/JsCss.jsp" %>

    <script src="MntDivision2.js" type="text/javascript"></script>

    <style type="text/css">
        /*表頭*/
        .toptitle {
            height: 30px;
            margin: 0;
            padding: 0;
            background: #fff url(../images/title-bg.jpg) repeat-x 0 0;
        }

        /*toolbar 高度*/
        .ui-jqgrid .ui-userdata {
            height:32px; /* default value in ui.jqgrid.CSS is 21px */
        }
    </style>


</head>

<body>
    <!-- 表頭與功能表 -->
    <jsp:include page="<%=Consts.menuFile%>"></jsp:include>

    <!-- 第一頁 -->
    <div id="page1" style="display:block; width:100%; text-align:center;">
        <div id="divlist" style="height:450px; display:block; margin-top:20px; margin-left:auto; margin-right:auto;" >
            <center>
            <!--查詢內容-->
            <div id='toolbar' style="padding:5px; font-size:13px; font-weight:normal; display:none; float:left;">
                代碼 <input class="ab-inp" style="width:60px; font-size:13px;" type="text" id="qid" name="qid" maxlength="4" value="" onkeypress="return handleEnter(this, event);">
                &nbsp;單位名稱 <input class="ab-inp" style="width:100px; font-size:13px;" type="text" id="qtitle" name="qtitle" maxlength="40" value="" onkeypress="return handleEnter(this, event);">
                <span style="float:center; width:25px; height:16px;" id="bSearch" title="查詢"></span>
                <span style="float:center; width:25px; height:16px;" id="bClear" title="重新查詢"></span>
            </div>
            <!--簡列表格-->
            <table id="mainlist"></table>
            </center>
        </div>
    </div>

    <!-- 第二頁 -->
    <div id="page2" style="width:100%; height:450px; display:none; font-size:13px;" >
        <center>
        <form action="" method=post id="frmEdit" name="frmEdit">

        <table class="tablefrm" width="400px" style="margin-top:20px; margin-left:auto; margin-right:auto;">
            <tr>
                <th colspan=2 align="center">
                    使用者單位管理 - <span id="EditMode"></span>
                </th>
            </tr>
            <tr>
                <th colspan=2 align="center">
                    <span style="float:center; width:30px; height:16px;" id="bSave" title="儲檔"></span>
                    <span style="float:center; width:30px; height:16px;" id="bCancle" title="取消"></span>
                </th>
            </tr>

            <tr id="FormError" style="display:none;">
                <td colspan="10" class="ui-state-error" style="text-align:left; padding-left:8px;"><span id="FormErrorMsg"></span></td>
            </tr>

            <tr>
                <td style="width:30%; text-align:right">單位代碼</td>
                <td style="text-align:left">
                    <input class="ab-inp" type="text" id="id" name="id" size="4" maxlength="4" value="" onkeypress="return handleEnter(this, event);">
                </td>
            </tr>
            <tr>
                <td style="width:30%; text-align:right">單位名稱</td>
                <td style="text-align:left">
                    <input class="ab-inp" type="text" id="title" name="title" size="20" maxlength="40" value="" onkeypress="return handleEnter(this, event);">
                </td>
            </tr>
            <tr>
                <td style="width:30%; text-align:right">所屬區域代碼</td>
                <td style="text-align:left">
                    <input class="ab-inp" type="text" id="region" name="region" size="20" maxlength="80" value="" onkeypress="return handleEnter(this, event);">
                    (區域二個以上者請用逗號分隔，全區者打*)
                </td>
            </tr>
            <tr>
            </tr>
        </table>

        </form>


        <table class="tablefrm" width="400px" style="margin-top:20px; margin-left:auto; margin-right:auto;">
            <tr bgcolor="#FF9900">
                <th align=center>區域</th>
                <th align=center>代碼</th>
                <th align=center>區域</th>
                <th align=center>代碼</th>
                <th align=center>區域</th>
                <th align=center>代碼</th>
                <th align=center>區域</th>
                <th align=center>代碼</th>
            </tr>


            <%
                //縣市區域代碼
                String qs = "select citycode, cityname from fpv_citym"
                    + " where citytype='A'"
                    + " and (citycode > '00' and citycode < '26')"
                    + " and (citycode <> '09' and citycode <> '15' and citycode <> '17')"
                    + " order by citycode";
                rs = stmt.executeQuery(qs);
                int cnt = 0;
                while (rs.next()) {
                    String citycode = rs.getString("citycode");
                    String cityname = rs.getString("cityname");
                    if (citycode.compareTo("25") <= 0) cityname = cityname.substring(0, 3);

                    String colspan = "1";
                    String trs = "";
                    String tre = "";
                    if (citycode.compareTo("25") <= 0) {
                        if ((cnt % 4) == 0) trs = "<tr>";
                        if ((cnt % 4) == 3) tre = "</tr>";
                    } else {
                        colspan = "3";
                        if ((cnt % 2) == 0) trs = "<tr>";
                        if ((cnt % 2) == 3) tre = "</tr>";
                    }
                    cnt++;
            %>
                <%=trs%>
                    <td colspan="<%=colspan%>" style="height: 20px;"><%=cityname%></td>
                    <td align=center style="height: 20px;"><font color="#FF000"><%=citycode%></font></td>
                <%=tre%>
            <%
                }
                rs.close();
            %>

        </table>



        </center>
    </div>

</body>

</html>

<%
//關閉連線
if (stmt != null) stmt.close();
if (conn != null) conn.close();
%>
