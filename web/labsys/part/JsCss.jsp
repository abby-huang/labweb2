
<%@ page pageEncoding="UTF-8" %>

<script>
    //設定自動登出
    var timerID = 0
    function autoLogout() {
        location.href = "<%=common.Consts.appRoot%>/Logout.jsp"
    }
    //清除計時
    function resetTimeout() {
        clearTimeout(timerID);
    }
    timerID = setTimeout('autoLogout()', (1000*60*60)); //60分鐘
</script>

<!-- javascript css 包含檔案 -->
<!-- basic -->
<link href="<%=common.Consts.cssRoot%>/init.css" rel="stylesheet" type="text/css" />
<link href="<%=common.Consts.cssRoot%>/abstyle.css" rel="stylesheet" type="text/css" />
<!-- menu -->
<link href="<%=common.Consts.jsRoot%>/menu/ddlevelsmenu-base.css" rel="stylesheet" type="text/css" />
<link href="<%=common.Consts.jsRoot%>/menu/ddlevelsmenu-topbar.css" rel="stylesheet" type="text/css" />
<script src="<%=common.Consts.jsRoot%>/menu/ddlevelsmenu.js" id="menuScript" type="text/javascript"></script>

<!-- jquery -->
<script src="<%=common.Consts.jsRoot%>/jQuery/jquery-3.3.1.min.js" type="text/javascript"></script>
<link href="<%=common.Consts.jsRoot%>/jQuery/jquery-ui-redmond/jquery-ui.min.css" rel="stylesheet" type="text/css" />
<script src="<%=common.Consts.jsRoot%>/jQuery/jquery-ui-redmond/jquery-ui.js"></script>
<script src="<%=common.Consts.jsRoot%>/jQuery/jquery.blockUI.js" type="text/javascript"></script>

<!-- jqgrid -->
<link href="<%=common.Consts.jsRoot%>/jqGrid-5.3.1/css/ui.jqgrid.css" rel="stylesheet" type="text/css" />
<script src="<%=common.Consts.jsRoot%>/jqGrid-5.3.1/js/jquery.jqGrid.min.js" type="text/javascript"></script>
<script src="<%=common.Consts.jsRoot%>/jqGrid-5.3.1/js/i18n/grid.locale-tw.js" type="text/javascript"></script>

<!-- jq 自訂 -->
<link href="<%=common.Consts.cssRoot%>/jq-custom.css" rel="stylesheet" type="text/css" />

<!-- 工具 -->
<script src="<%=common.Consts.jsRoot%>/SysUtils.js" type="text/javascript"></script>
<script src="<%=common.Consts.jsRoot%>/Utils.js" type="text/javascript"></script>

