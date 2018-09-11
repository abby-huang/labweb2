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
if ((loginUser == null) || !sysModules.hasPrivelege("outlab", loginUser.privilege) ) {
    response.sendRedirect(Consts.logoutFile);
}

String pageHeader = "外展看護工網路申請平台";
request.setCharacterEncoding("UTF-8");
String thisPage = request.getRequestURI();

String errMsg = "";

%>

<!DOCTYPE html>
<html lang="zh-Hant">

<head>
    <title><%=Consts.appTitle%>--<%=pageHeader%></title>
    <META http-equiv="X-UA-Compatible" content="IE=EDGE,CHROME=1">

    <script language="javascript" src="<%=Consts.jsRoot%>/My97DatePicker/WdatePicker.js"></script>
    <script type="text/javascript">
        //起始參數
        var sysErrMsg = '<%=errMsg%>';
    </script>

    <%@ include file="../part/JsCss.jsp" %>

    <script src="OutLabMnt.js" type="text/javascript"></script>

    <style type="text/css">
        /*表頭*/
        .toptitle {
            height: 30px;
            margin: 0;
            padding: 0;
            background: #fff url(../images/outlabtoptitle.jpg) repeat-x 0 0;
        }

        /*toolbar 高度*/
        .ui-jqgrid .ui-userdata {
            /*height:45px; /* default value in ui.jqgrid.CSS is 21px */
        }

        /* 超連結 */
        .ab-a2:link     {font-size:13px; font-family:Verdana; color:#0066cc; text-decoration:none;}
        .ab-a2:visited  {font-size:13px; font-family:Verdana; color:#0066cc; text-decoration:none;}
        .ab-a2:hover    {font-size:13px; font-family:Verdana; color:#ff0000; text-decoration:none;}
        .ab-a2:active   {font-size:13px; font-family:Verdana; color:#0066cc; text-decoration:none;}

    </style>


</head>

<body>
    <!-- 表頭與功能表 -->
    <jsp:include page="<%=Consts.menuFile%>"></jsp:include>

    <!-- 第一頁 : 查詢 -->
    <div id="page1" style="display:block; width:100%; text-align:center;">
        <!--查詢內容-->
        <div id='toolbar' style="display:block; float:center; margin-top:20px; padding:2px; font-size:13px; font-weight:normal;">
            <center>
            <table class="tablefrm3" style="width:794px;">
                <tr>
                    <th colspan=2 align="center" style="font:15px 標楷體;">
                        外展看護工網路申請作業
                    </th>
                </tr>
                <tr>
                    <td>
                        <input class="ab-btn" style="float:left; width:140px;" id="btnSave" name="" type="button" value="返回申請條件查驗畫面"
                               onclick="showPage(3);">
                    </td>
                </tr>
                <tr>
                    <td>
                        申請人身分證字號 <input class="ab-inp" style="width:90px; font-size:13px;" type="text" id="qregno" name="qregno" maxlength="15" value="" onkeypress="">
                        &nbsp;被看護人身分證字號 <input class="ab-inp" style="width:90px; font-size:13px;" type="text" id="qcommid" name="qcommid" maxlength="15" value="" onkeypress="">
                        <span style="float:center; width:25px; height:16px;" id="bSearch" title="查詢"></span>
                        <span style="float:center; width:25px; height:16px;" id="bClear" title="清除條件"></span>
                    </td>
                </tr>
            </table>
            </center>
        </div>

        <div id="divlist" style="height:450px; display:block; margin-top:0px; margin-left:auto; margin-right:auto;" >
            <center>
            <!--簡列表格-->
            <table id="mainlist"></table>
            </center>
        </div>
    </div>


    <!-- 第二頁 : 編輯 -->
    <div id="page2" style="width:100%; height:450px; display:none; font-size:13px;" >
        <center>
        <form action="" method=post name="frmEdit">
            <input type="hidden" name ="rowid" value="">

            <table class="tablefrm3" width="500px" style="margin-top:20px; margin-left:auto; margin-right:auto;">
                <tr>
                    <th colspan=2 align="center" style="font:15px 標楷體;">
                        外展看護工網路申請作業 - <span id="EditMode"></span>
                    </th>
                </tr>
                <tr>
                    <td colspan=2 class="ab-frmlb1" align="left" style="height:16px;">
                        說明：
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="right" width="10%" style="height:16px;">
                        1.
                    </td>
                    <td class="ab-frmlb1" align="left" width="90%" style="height:16px;">
                        本系統僅適用於外展看護機構申請外展看護工。
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="right" style="height:16px;">
                        2.
                    </td>
                    <td class="ab-frmlb1" align="left" style="height:16px;">
                        有*者為必填欄位。系統帶出的雇主名稱、外勞姓名、性別可自行修改。
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="right" style="height:16px;">
                        3.
                    </td>
                    <td class="ab-frmlb1" align="left" style="height:16px;">
                        <font color="ff0000">上傳申請案件後可利用查詢功能確認是否已完成申請案</font>。
                    </td>
                </tr>
            </table>

            <table class="tablefrm3" width="500px" style="margin-top:3px; margin-left:auto; margin-right:auto;">
                <tr>
                    <th colspan=2 align="center">
                        <span style="float:center; width:30px; height:16px;" id="bSave" title="上傳申請案"></span>
                        <span style="float:center; width:30px; height:16px;" id="bCancle" title="取消"></span>
                    </th>
                </tr>


                <tr id="FormError" style="display:none;">
                    <td colspan="10" class="ui-state-error" style="text-align:left; padding-left:8px;"><span id="FormErrorMsg"></span></td>
                </tr>


                <tr>
                    <td class="ab-frmlb1" align="left">
                        申請人資料：
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left">
                        *申請人身分證字號或居留證號：
                        <input class="ab-inp" style="width:100px;" type="text" id="regno" name="regno" value="" maxlength="10"
                               onchange="this.value=this.value.toUpperCase(); checkRegno(this);" onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left">
                        *申請人名稱：
                        <input class="ab-inp" style="width:300px;" type="text" id="vendname" name="vendname" value="" maxlength="40" onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left">
                        *申請人地址：
                        <input class="ab-inp" style="width:300px;" type="text" name="vendaddr" value="" maxlength="80" onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left">
                        聯絡電話：
                        <input class="ab-inp" style="width:100px;" type="text" name="vendtel" value="" maxlength="15" onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
            </table>

            <table class="tablefrm3" width="500px" style="margin-top:3px; margin-left:auto; margin-right:auto;">
                <tr>
                    <td class="ab-frmlb1" align="left">
                        被看護人資料：
                    </td>
                <tr>
                    <td class="ab-frmlb1" align="left">
                        *被看護人身分證字號：
                        <input class="ab-inp" style="width:100px;" type="text" name="commid" value="" maxlength="10"
                               onchange="this.value=this.value.toUpperCase(); checkNgbandy(this);" onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left">
                        *被看護人姓名：
                        <input class="ab-inp" style="width:300px;" type="text" name="commname" value="" maxlength="24" onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left">
                        *申請資格：
                        <select class="ab-sel" style="width:150px;" name="style" size="1" onkeypress="return handleEnter(this, event);">
                            <option value=""></option>
                            <option value="1">1 - 傳遞單</option>
                            <option value="2">2 - 核准函</option>
                            <option value="2A">2A - 初次招募許可函</option>
                            <option value="2B">2B - 遞補招募許可函</option>
                            <option value="2C">2C - 重新招募許可函</option>
                            <option value="3">3 - 廢聘函</option>
                            <option value="4">4 - 喘息服務</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left">
                        *評估結果：
                        <input class="ab-inp" style="width:20px;" type="text" name="outcome" value="" maxlength="1" onchange="this.value=this.value.toUpperCase();" onkeypress="return handleEnter(this, event);">（Y：合格&nbsp; N：不合格）
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left">
                        *外展契約起始日：
                        <input class="Wdate" style="height:16px; margin:1px; width:90px;" type="text" name="wrkbdate" value="" onClick="WdatePicker()" onFocus="WdatePicker()" onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left">
                        外展契約廢止日期：
                        <input class="Wdate" style="height:16px; margin:1px; width:90px;" type="text" name="abolishdate" value="" onClick="WdatePicker()" onFocus="WdatePicker()" onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left">
                        *外展機構統編：
                        <input class="ab-inp" style="width:100px;" type="text" name="empid" value="" maxlength="8"
                               onchange="this.value=this.value.toUpperCase(); checkEmpid(this);" onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left">
                        *外展機構名稱：
                        <input class="ab-inp" style="width:300px;" type="text" name="emptitle" value="" maxlength="40" onkeypress="return handleEnter(this, event)">
                    </td>
                </tr>
            </table>

        </form>
        <br>
        </center>
    </div>


    <!-- 第三頁 : 被看護人申請條件查驗 -->
    <div id="page3" style="display:none; width:100%; height:450px; font-size:13px;" >
        <center>
            <form action="" method=post name="frmVerify" onsubmit="verifyNgbandy(this); return false;">

            <table class="tablefrm3" width="500px" style="margin-top:20px; margin-left:auto; margin-right:auto;">
                <tr>
                    <th colspan=2 align="center" style="font:15px 標楷體;">
                        外展看護工網路申請作業 - 被看護人申請條件查驗
                    </th>
                </tr>

                <tr>
                    <td width="80%" class="ab-frmlb1" align="left">
                        <input class="ab-btn" style="width:120px;" name="" type="button" value="進入申請作業畫面"
                               onclick="showPage(1);">
                    </td>
                    <td class="ab-frmlb1" align="center">
                        <input class="ab-btn" style="width:70px;" name="" type="button" value="操作說明"
                               onclick="window.open('../manual/outlab.doc');">
                    </td>
                </tr>
                <tr>
                    <td colspan="2" class="ab-frmlb1" align="left">
                        被看護人身分證字號：
                        <input class="ab-inp" style="width:100px;" type="text" name="commidVerify" value="" maxlength="10"
                               onchange="this.value=this.value.toUpperCase();">
                        <input class="ab-btn" style="width:70px;" type="submit" value="執行查驗">
                    </td>
                </tr>
            </table>

            <table class="tablefrm3" width="500px" style="margin-top:5px; margin-left:auto; margin-right:auto;">
                <tr>
                    <td class="ab-frmlb1" align="left">
                        審核結果：<font color=#FF0000><span id="verifyResult"></span></font>
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left">
                        被看護人身分證字號：<span id="txtcommid"></span>
                    </td>
                </tr>
                <tr>
                    <td class="ab-frmlb1" align="left">
                        被看護人姓名：<span id="txtcommname"></span>
                    </td>
                </tr>
            </table>

        </form>
        <br>
        </center>
    </div>

</body>

</html>

