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

String pageHeader = "使用者權限管理";
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
    <script src="MntStaff.js" type="text/javascript"></script>

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

    <!-- 第一頁 -->
    <div id="page1" style="display:block; width:100%;">
        <table style="width:1100px; border:0; margin-left:auto; margin-right:auto;">
            <tr>
                <td style="width:470px; text-align:right; vertical-align:top;">
                    <div id="divlist" style="width:452px; height:450px; display:block; margin-top:20px; margin-right:10px;" >
                        <!--查詢內容-->
                        <div id='toolbar' style="padding:5px; font-size:13px; font-weight:normal; display:none; float:left;">
                            單位
                            <select class="ab-sel" style="width:200px; font-size:13px;" id="qbranch" name="qbranch" size=1 onkeypress="return handleEnter(this, event);">
                                <option value="">　</option>
                                <%=Comm.getSelectOptionData(out, conn, "division", "id;title", "")%>
                            </select>
                            姓名
                            <input class="ab-inp" type="text" id="qdescript" name="qdescript" size="8" maxlength="40" value="" onkeypress="return handleEnter(this, event);">
                            <span style="float:center; width:25px; height:16px;" id="bSearch" title="查詢"></span>
                        </div>
                        <!--簡列表格-->
                        <table id="mainlist"></table>
                    </div>
                </td>

                <td width="630px" align="left" style="vertical-align:top;">

                    <div style="width:630px; height:770px; display:block; margin-top:20px; margin-left:10px;" >

                    <form action="" method=post name="frmEdit">
                        <table class="tablefrm" style="width:630px;">
                            <tr>
                                <th colspan="10" style="text-align:left;">
                                    <span style="float:center; width:30px; height:16px;" id="bSave" title="儲檔"></span>
                                    <span style="float:center; width:30px; height:16px;" id="bCancle" title="取消"></span>
                                </th>
                            </tr>

                            <tr id="FormError" style="display:none;">
                                <td colspan="10" class="ui-state-error" style="text-align:left; padding-left:8px;"><span id="FormErrorMsg"></span></td>
                            </tr>

                            <tr>
                                <td class="" align="right" width=25% colspan=2>帳號或身分證號</td>
                                <td align="left" width=30% colspan=3>
                                    <input class="ab-inp" type="text" id="id" name="id" maxlength="20" value="" onkeypress="return handleEnter(this, event);">
                                </td>
                                <td class="" align="right" width=15% colspan=2>帳號類型</td>
                                <td align="left" width=30% colspan=3>
                                    <select class="ab-sel" style="width:140px;" id="acckind" name="acckind" size=1 onkeypress="return handleEnter(this, event);">
                                        <option value="00">00 - 自然人憑證</option>
                                        <option value="02">02 - 外人憑證</option>
                                        <option value="01">01 - 帳號密碼</option>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td class="" align="right" colspan=2>密碼</td>
                                <td align="left" width=30% colspan=8>
                                    <input class="ab-inp" type="password" name="pwd" maxlength="20" value="" onkeypress="return handleEnter(this, event);">
                                    <font color="#990000">(帳號類型為自然人憑證者，不必輸入密碼)</font>
                                </td>
                            </tr>
                            <tr>
                                <td class="" align="right" colspan=2>姓名</td>
                                <td align="left" colspan=8>
                                    <input class="ab-inp" type="text" name="descript" maxlength="60" value="" onkeypress="return handleEnter(this, event);">
                                </td>
                            </tr>
                            <tr>
                                <td class="" align="right" colspan=2>單位</td>
                                <td align="left" width=75% colspan=9>
                                    <select class="ab-sel" style="width:300px;" name="branch" size=1 onkeypress="return handleEnter(this, event);">
                                        <option value="">　</option>
                                        <%=Comm.getSelectOptionData(out, conn, "division", "id;title", "")%>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td class="" align="right" colspan=2>部門</td>
                                <td align="left" colspan=3>
                                    <input class="ab-inp" type="text" name="department" maxlength="100" value="" onkeypress="return handleEnter(this, event);">
                                </td>
                                <td class="" align="right" colspan=2>職稱</td>
                                <td align="left" colspan=3>
                                    <input class="ab-inp" type="text" name="job" maxlength="50" value="" onkeypress="return handleEnter(this, event);">
                                </td>
                            </tr>
                            <tr>
                                <td class="" align="right" colspan=2>電話</td>
                                <td align="left" colspan=8>
                                    <input class="ab-inp" type="text" name="tel" maxlength="40" value="" onkeypress="return handleEnter(this, event);">
                                </td>
                            </tr>
                            <tr>
                                <td class="" align="right" colspan=2>所屬區域代碼</td>
                                <td align="left" colspan=8>
                                    <input class="ab-inp" style="width:200px;" type="text" name="region" maxlength="80" value="" onkeypress="return handleEnter(this, event);">
                                    (區域代碼請參考本畫面下方的代碼對照表。區域二個以上者請用逗號分隔，全區者打*)
                                </td>
                            </tr>
                            <tr>
                                <td class="" align="right" colspan=2>最近登入日期</td>
                                <td align="left" colspan=8>
                                    <input class="ab-inp" type="text" name="logindate" maxlength="20" value="" onkeypress="return handleEnter(this, event);">
                                </td>
                            </tr>
                            <tr>
                                <td class="" align="right" colspan=2>建立日期</td>
                                <td align="left" colspan=3>
                                    <input class="ab-inp" type="text" name="setdate" maxlength="20" value="" onkeypress="return handleEnter(this, event);">
                                </td>
                                <td class="" align="right" colspan=2>建立人員</td>
                                <td align="left" colspan=3>
                                    <input class="ab-inp" type="text" name="amenduser" maxlength="20" value="" onkeypress="return handleEnter(this, event);">
                                </td>
                            </tr>



                            <tr>
                                <th align="left" colspan=2>主模組權限</th>
                                <th align="left" colspan=8>子模組權限</th>
                            </tr>
                            <%
                            //功能模組權限
                            for (int i=0; i < sysModules.modulelist.size(); i++) {
                            %>
                            <tr>
                                <td align="left" width=20% colspan=2>
                                    <input class="ab-inp" type="checkbox" name="priv<%=Integer.toString(i)%>">
                                    <%=sysModules.modulelist.get(i).descript%>
                                </td>
                                <td align="left" width="*" colspan=8>
                                    <%
                                    for (int j=0; j < sysModules.modulelist.get(i).subModule.size(); j++) {
                                    %>
                                        <input class="ab-inp" type="checkbox" name="priv<%=i+""%>.sub<%=j+""%>">
                                        <%=sysModules.modulelist.get(i).subModule.get(j).descript%>
                                    <%
                                    }
                                    %>
                                </td>
                            </tr>
                            <%
                            }
                            %>
                        </table>
                    </form>

                    <div style="height:5px; border:0;"></div>

                    <table class="tablefrm" style="width:630px;">
                        <tr>
                            <th align=center width="15%">區域</th><th align=center width="10%">代碼</th>
                            <th align=center width="15%">區域</th><th align=center width="10%">代碼</th>
                            <th align=center width="15%">區域</th><th align=center width="10%">代碼</th>
                            <th align=center width="15%">區域</th><th align=center width="10%">代碼</th>
                        </tr>

                        <%
                            //縣市區域代碼
                            String qs = "select citycode, cityname from fpv_citym"
                                + " where citytype='A'"
                                + " and (citycode > '00' and citycode < '26')"
                            //  + " and (citycode <> '09' and citycode <> '15' and citycode <> '17')"
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
                                <td align=center colspan="<%=colspan%>" style="height: 20px;"><%=cityname%></td>
                                <td align=center style="height:20px;"><font color="#FF000"><%=citycode%></font></td>
                            <%=tre%>
                        <%
                            }
                            rs.close();
                        %>


                    </table>

                </td>

            </tr>
        </table>
    </div>

</body>

</html>

<%
//關閉連線
if (stmt != null) stmt.close();
if (conn != null) conn.close();
%>
