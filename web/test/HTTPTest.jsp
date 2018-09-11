<%@page import="javax.net.ssl.SSLSession"%>
<%@page import="java.security.cert.X509Certificate"%>
<%@page import="javax.net.ssl.X509TrustManager"%>
<%@page import="javax.net.ssl.TrustManager"%>
<%@page import="java.net.URL"%>
<%@page import="javax.net.ssl.HttpsURLConnection"%>
<%@page import="org.apache.http.client.methods.RequestBuilder"%>
<%@page import="org.apache.http.client.methods.HttpUriRequest"%>
<%@page import="org.apache.http.client.HttpClient"%>
<%@page import="org.apache.http.HttpHeaders"%>
<%@page import="org.apache.http.Header"%>
<%@page import="org.apache.http.client.entity.EntityBuilder"%>
<%@page import="org.apache.http.HttpEntity"%>
<%@page import="javax.net.ssl.HostnameVerifier"%>
<%@page import="org.apache.http.conn.ssl.NoopHostnameVerifier"%>
<%@page import="javax.net.ssl.SSLContext"%>
<%@page import="org.apache.http.conn.ssl.SSLConnectionSocketFactory"%>
<%@page import="org.apache.http.conn.ssl.TrustSelfSignedStrategy"%>
<%@page import="org.apache.http.conn.ssl.SSLContextBuilder"%>
<%@page import="org.apache.http.util.EntityUtils"%>
<%@page import="org.apache.http.client.methods.CloseableHttpResponse"%>
<%@page import="org.apache.http.client.entity.UrlEncodedFormEntity"%>
<%@page import="org.apache.http.client.methods.HttpPost"%>
<%@page import="org.apache.http.impl.client.HttpClients"%>
<%@page import="org.apache.http.impl.client.CloseableHttpClient"%>
<%@page import="org.apache.http.client.config.RequestConfig"%>
<%@page import="java.net.HttpURLConnection"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="com.absys.util.*" %>
<%@ page import="com.absys.user.*"%>
<%@ page import="javax.servlet.http.*"%>
<%@ page import="java.security.*"%>
<%@ page import="java.security.spec.*"%>
<%@ page import="javax.crypto.*"%>
<%@ page import="javax.crypto.spec.*"%>
<%@ page import="org.apache.commons.codec.binary.*"%>
<%@ page import="org.apache.commons.io.FileUtils"%>
<%@ page import="org.apache.cxf.endpoint.Client"%>
<%@ page import="org.apache.cxf.endpoint.dynamic.DynamicClientFactory"%>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/ComConstants.inc" %>
<%@ include file="/include/ComFunctions.inc" %>

<%

String pageHeader = "測試 web service";
request.setCharacterEncoding("UTF-8");

String errMsg = "";

        //請求 WebService
        HttpURLConnection httpconnn = null;
        String responseText = "";

        //設定 Timeout
        int reqtimeout = 180 * 1000; //秒

/*
		String url = "https://laborap.wda.gov.tw/labweb/labsys/service/Labor.jsp";
		//String url = "http://192.168.0.2/labweb/labsys/service/Labor.jsp";
		URL obj = new URL(url);
		HttpsURLConnection httpconn = (HttpsURLConnection) obj.openConnection();

        //add reuqest header
        httpconn.setRequestMethod("POST");
        httpconn.setReadTimeout(reqtimeout);
        httpconn.setConnectTimeout(reqtimeout);
        httpconn.setRequestProperty("Accept-Charset","UTF-8");
        httpconn.setRequestProperty("Content-Language", "UTF-8");
        httpconn.setDoInput(true);
        httpconn.setDoOutput(true);


		String urlParameters = "action=data&natcode=009&passno=AR763931";
		// Send post request
		httpconn.setDoOutput(true);
		DataOutputStream wr = new DataOutputStream(httpconn.getOutputStream());
		wr.writeBytes(urlParameters);
//		wr.writeBytes(nameValuePairs.toString());
		wr.flush();
		wr.close();

		int responseCode = httpconn.getResponseCode();
		out.println("\nSending 'POST' request to URL : " + url + "<br>");
		out.println("Post parameters : " + urlParameters + "<br>");
		out.println("Response Code : " + responseCode + "<br>");

        if (responseCode == HttpsURLConnection.HTTP_OK) {

            BufferedReader in = new BufferedReader(new InputStreamReader(httpconn.getInputStream(), "UTF-8"));
            String inputLine;
            StringBuffer httpresponse = new StringBuffer();

            while ((inputLine = in.readLine()) != null) {
                httpresponse.append(inputLine);
            }
            in.close();

            //print result
            //responseText = httpresponse.toString();

        }
*/
            //設定 Timeout
            String wsUrl = "";

            //RequestConfig requestConfig = RequestConfig.custom()
            RequestConfig requestConfig = RequestConfig.copy(RequestConfig.DEFAULT)
                .setSocketTimeout(reqtimeout)
                .setConnectTimeout(reqtimeout)
                .setConnectionRequestTimeout(reqtimeout)
                .build();


            wsUrl = "https://laborap.wda.gov.tw/labweb/labsys/service/Labor.jsp";
//            wsUrl = "https://163.29.20.53:8780/iaod/l0034MAction.do?method=queryDataByPost";
//            CloseableHttpClient httpClient = HttpClients.createDefault();
/*
            // Create a trust manager that does not validate certificate chains
            TrustManager[] trustAllCerts = new TrustManager[] {new X509TrustManager() {
                    public java.security.cert.X509Certificate[] getAcceptedIssuers() {
                        return null;
                    }
                    public void checkClientTrusted(X509Certificate[] certs, String authType) {
                    }
                    public void checkServerTrusted(X509Certificate[] certs, String authType) {
                    }
                }
            };

            // Install the all-trusting trust manager
            SSLContext sslContext = SSLContext.getInstance("TLS");
            sslContext.init(null, trustAllCerts, new java.security.SecureRandom());
*/
            CloseableHttpClient httpClient = HttpClients
                .custom()
                .setSSLContext(com.absys.util.AbNet.createSSLContextTrustAll())
//                .setSSLHostnameVerifier(new NoopHostnameVerifier())
                .build();


            ArrayList<org.apache.http.NameValuePair> nameValuePairs = new ArrayList<org.apache.http.NameValuePair>();
            nameValuePairs.add(new org.apache.http.message.BasicNameValuePair("action", "data"));
            nameValuePairs.add(new org.apache.http.message.BasicNameValuePair("natcode", "009"));
            nameValuePairs.add(new org.apache.http.message.BasicNameValuePair("passno", "AR763931"));
            out.println(nameValuePairs.toString());



            HttpPost httpPost = new HttpPost(wsUrl);
            httpPost.setEntity(new UrlEncodedFormEntity(nameValuePairs));
            httpPost.setConfig(requestConfig);

                try {
                    //org.apache.http.HttpResponse httpresponse = httpclient.execute(httpPost);
                    CloseableHttpResponse httpresponse = httpClient.execute(httpPost);

                    //接收資料 Response
//                    try {
                        int responseCode2 = httpresponse.getStatusLine().getStatusCode();
                        if (responseCode2 != org.apache.http.HttpStatus.SC_OK) {
                            errMsg += "送出 HTTP 請求發生錯誤，第" + 1 + "次，錯誤代碼：" + responseCode2;
                        } else {
                            errMsg = "";
                            responseText = EntityUtils.toString(httpresponse.getEntity());
                        }
/*
                    } catch (Exception e) {
                        out.println(e.getMessage());
                    } finally {
                        httpresponse.close();
                    }
*/

                } catch (Exception e) {
                    errMsg += "送出 HTTP 請求發生錯誤，第" + 1 + "次，請檢查主機狀況：URL=" + wsUrl;
                    errMsg += "\n" + e.getMessage() + "\n";
                    out.println(e.getStackTrace());
                }

        //處理資料
        try {
            responseText = responseText.replace("},{", "},\n{").replace("[{", "[\n{").replace("]}", "\n]}");
        } catch (Exception e) {
             errMsg += "\n" + e.getMessage() + "\n";
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
                     errMsg：<%=errMsg%>
                </td>
            </tr>
            <tr>
                <td style="word-wrap: break-word">
                     <%=responseText%>
                </td>
            </tr>
        </table>
    </center>

<%
//關閉連線
//stmt.close();
//if (conn != null) conn.close();
%>

<%if (errMsg.length() != 0) {%>
<script language=JavaScript>
    alert("<%=errMsg%>");
</script>
<%}%>

</body>
</html>

