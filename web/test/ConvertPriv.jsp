<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="org.json.*"%>
<%@ page import="com.absys.util.*" %>
<%@ page import="com.absys.user.*"%>

<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComGetLoginData.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%

String pageHeader = "測試 web service";
request.setCharacterEncoding("UTF-8");

String errMsg = "";

//建立連線
Connection conn = getConnection( session );
if (conn == null) errMsg = "對不起! 無法開啟資料庫，請通知系統人員。";
Statement stmt = conn.createStatement();
Statement stmt2 = conn.createStatement();
ResultSet rs;
String qs;


/*
int cnt = 0;
qs = "select rowid, staff2.* from staff2";
rs = stmt.executeQuery(qs);
while (rs.next()) {
    cnt++;
    String rowid = rs.getString("rowid");
    Staff staff = new Staff(stmt2, "staff2", rs.getString("id"));

    //組合權限
    Permission permission = new Permission();
    for (int i=0; i < modules.modulelist.size(); i++) {
        permission.setPermission( modules.modulelist.get(i).id, modules.hasPrivelege(i, staff.privilege) );
        for (int j=0; j < modules.modulelist.get(i).subModule.size(); j++) {
            permission.setPermission( modules.modulelist.get(i).id,
                    modules.modulelist.get(i).subModule.get(j).id,
                    modules.hasPrivelege(i, j+1, staff.privilege) );
        }
    }
    qs = "update staff2 set privilege = " + AbSql.getEqualStr(permission.toString())
            + " where rowid = " + AbSql.getEqualStr(rowid);
    stmt2.executeUpdate(qs);
}
rs.close();

int cnt = 0;
qs = "select rowid, staff2.* from staff2";
rs = stmt.executeQuery(qs);
while (rs.next()) {
    cnt++;
    String rowid = rs.getString("rowid");
    Staff staff = new Staff(stmt2, "staff2", rs.getString("id"));

    //組合權限
    JSONObject jsonMain = new JSONObject();
    String newPriv = jsonMain.toString();
    for (int i=0; i < modules.modulelist.size(); i++) {
        newPriv = setPrivelege(i, modules.hasPrivelege(i, staff.privilege) ? true : false, newPriv, modules);
        for (int j=0; j < modules.modulelist.get(i).subModule.size(); j++) {
            newPriv = setPrivelege(i, j, modules.hasPrivelege(i, j+1, staff.privilege) ? true : false, newPriv, modules);
        }
    }
    qs = "update staff2 set privilege2 = " + AbSql.getEqualStr(newPriv)
            + " where rowid = " + AbSql.getEqualStr(rowid);
    stmt2.executeUpdate(qs);
}
rs.close();
*/

qs = "select * from staff2 where id = 'A222291928'";
rs = stmt.executeQuery(qs);
rs.next();
Permission permission = new Permission( rs.getString("privilege") );
rs.close();

boolean b0 = false;
//b0 = permission.hasPermission("survey");
permission.setPermission("survey", "amend", false);
b0 = permission.hasPermission("survey", "amend");
//priv = Staff.setPrivelege(9, 1, true, priv, modules);



%>

<%!

    /***************************************************************************
     * 檢查權限
     */
    //主模組
    public boolean hasPrivelege(int seq, String privilege, Modules modules) {
        //返回 true or false
        //seq: 模組序號 0 開始
        boolean retval = false;
        if (privilege == null) privilege = "{}";
        //讀取權限
        JSONObject jsonPriv = new JSONObject();
        try {
            jsonPriv = new JSONObject(privilege);
        } catch (Exception e) {
            return false;
        }
        //讀取資料
        if (modules.modulelist.size() >= seq+1) {
            try {
                JSONObject jsonmod = getJsonFieldObject(jsonPriv, modules.modulelist.get(seq).id);
                retval = (jsonmod.getInt("v") == 1) ? true : false;
            } catch (Exception e) {}
        }
        return retval;
    }

    //子模組
    public boolean hasPrivelege(int seq, int subseq, String privilege, Modules modules) {
        //返回 true or false
        //seq: 模組序號 0 開始
        //subseq: 子模組序號 0 開始
        boolean retval = false;
        if (privilege == null) privilege = "{}";
        //讀取權限
        JSONObject jsonPriv = new JSONObject();
        try {
            jsonPriv = new JSONObject(privilege);
        } catch (Exception e) {
            return false;
        }
        //讀取資料
        if (modules.modulelist.size() >= seq+1) {
            try {
                JSONObject jsonmod = getJsonFieldObject(jsonPriv, modules.modulelist.get(seq).id);
                JSONObject jsonmod2 = getJsonFieldObject(jsonmod, "m"); //讀取 module 節點
                JSONObject jsonsub = getJsonFieldObject(jsonmod2, modules.modulelist.get(seq).subModule.get(subseq).id); //讀取子模組 ojbect
                retval = (jsonsub.getInt("v") == 1) ? true : false;
            } catch (Exception e) {}
        }
        return retval;
    }



    /***************************************************************************
     * 設定權限
     */
    //主模組
    public String setPrivelege(int seq, boolean value, String privilege, Modules modules) {
        //返回 privilege
        //seq: 模組序號 0 開始
        //subseq: 子模組序號 0 開始
        if (privilege == null) privilege = "{}";
        //讀取權限
        JSONObject jsonPriv = new JSONObject();
        try {
            jsonPriv = new JSONObject(privilege);
        } catch (Exception e) {}

        //設定資料
        if (modules.modulelist.size() >= seq+1) {
            try {
                JSONObject jsonmod = getJsonFieldObject(jsonPriv, modules.modulelist.get(seq).id);
                jsonmod.put("v", (value ? 1:0));
                jsonPriv.put(modules.modulelist.get(seq).id, jsonmod); //主模組存入權限節點
            } catch (Exception e) {}
        }
        return jsonPriv.toString();
    }

    //子模組
    public String setPrivelege(int seq, int subseq, boolean value, String privilege, Modules modules) {
        //返回 privilege
        //seq: 模組序號 0 開始
        //subseq: 子模組序號 0 開始
        if (privilege == null) privilege = "{}";
        //讀取權限
        JSONObject jsonPriv = new JSONObject();
        try {
            jsonPriv = new JSONObject(privilege);
        } catch (Exception e) {}

        //設定資料
        if (modules.modulelist.size() >= seq+1) {
            if (modules.modulelist.get(seq).subModule.size() >= subseq) { //從 1 開始

                try {
                    JSONObject jsonmod = getJsonFieldObject(jsonPriv, modules.modulelist.get(seq).id);
                    JSONObject jsonmod2 = getJsonFieldObject(jsonmod, "m"); //讀取 module 節點
                    JSONObject jsonsub = getJsonFieldObject(jsonmod2, modules.modulelist.get(seq).subModule.get(subseq).id); //讀取子模組 ojbect
                    jsonsub.put("v", (value ? 1:0));
                    jsonmod2.put(modules.modulelist.get(seq).subModule.get(subseq).id, jsonsub); //jsonsub 子模組存入 module 節點
                    jsonmod.put("m", jsonmod2); //module 存入主模組節點
                    jsonPriv.put(modules.modulelist.get(seq).id, jsonmod); //主模組存入權限節點
                } catch (Exception e) {}

            }
        }
        return jsonPriv.toString();
    }

    public String setPrivelegeX(int seq, int subseq, boolean value, String privilege, Modules modules) {
        //返回 privilege
        //seq: 模組序號 0 開始
        //subseq: 子模組序號 1 開始 - 0 為主模組
        if (privilege == null) privilege = "";
        //讀取權限
        JSONObject jsonPriv = new JSONObject();
        try {
            jsonPriv = new JSONObject(privilege);
        } catch (Exception e) {}

        //設定資料
        if (modules.modulelist.size() >= seq+1) {
            if (modules.modulelist.get(seq).subModule.size() >= subseq) { //從 1 開始

                try {
                    JSONObject jsonmod = getJsonFieldObject(jsonPriv, modules.modulelist.get(seq).id);
                    //主模組
                    if (subseq == 0) {
                        jsonmod.put("v", (value ? 1:0));
                        jsonPriv.put(modules.modulelist.get(seq).id, jsonmod); //主模組存入權限節點

                    } else {
                    //子模組
                        JSONObject jsonmod2 = getJsonFieldObject(jsonmod, "m"); //讀取 module 節點
                        JSONObject jsonsub = getJsonFieldObject(jsonmod2, modules.modulelist.get(seq).subModule.get(subseq-1).id); //讀取子模組 ojbect
                        jsonsub.put("v", (value ? 1:0));
                        jsonmod2.put(modules.modulelist.get(seq).subModule.get(subseq-1).id, jsonsub); //jsonsub 子模組存入 module 節點
                        jsonmod.put("m", jsonmod2); //module 存入主模組節點
                        jsonPriv.put(modules.modulelist.get(seq).id, jsonmod); //主模組存入權限節點
                    }
                } catch (Exception e) {}

            }
        }

        return jsonPriv.toString();
    }

    //***************************************************************************
    // 讀取 JSON Object
    JSONObject getJsonFieldObject(JSONObject record, String key) {
        JSONObject jsonobj = null;
        try {
            jsonobj = record.getJSONObject(key);
        } catch (Exception e) {}
        if (jsonobj == null) {
            try {
                jsonobj = new JSONObject();
            } catch (Exception e) {}
        }
        return jsonobj;
    }

    //***************************************************************************
    // 讀取 JSON 欄位 int
    int getJsonFieldInt(JSONObject record, String key) {
        int retval = 0;
        try {
            retval = record.getInt(key);
        } catch (Exception e) {}
        return retval;
    }

    //***************************************************************************
    // 讀取JSON欄位
    private String getJsonFieldString(JSONObject record, String key) {
        String retval = "";
        try {
            retval = record.getString(key);
        } catch (Exception e) {}
        return retval;
    }


%>

<head>
    <%@ include file="/include/Header.inc" %>
    <script language="javascript">
        if (window != top) {
            top.location.href = location.href;
        }
    </script>
</head>


<body>

    <center>
        <table border="1" style="table-layout:fixed; width:800px;">
            <tr>
                <td align=center>
                    <center>
                        <b>測試資料</b>
                    </center>
                </td>
            </tr>
            <tr>
                <td style="word-wrap: break-word">
                    <%=0%>筆
                </td>
            </tr>
            <tr>
                <td style="word-wrap: break-word">
                    permission = <%=permission%><br>
                    b0 = <%=b0%><br>
                </td>
            </tr>
        </table>
    </center>

<%
//關閉連線
stmt.close();
stmt2.close();
if (conn != null) conn.close();
%>

<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
</script>
<%}%>

</body>
</html>

