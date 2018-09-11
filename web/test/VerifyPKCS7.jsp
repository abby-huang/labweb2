<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="UTF8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%

request.setCharacterEncoding("UTF-8");
String sigb64 = request.getParameter("b64SignedData");
common.GpkiPkcs7 pkcs7 = new common.GpkiPkcs7(sigb64);


%>

<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=EDGE"/>
<title>Verify Result</title>
</head>
<body>
<H2>
    
PKCS7簽章驗證<br/>
Verify result: <%=pkcs7.verifySignature()%><br/>
Not After: <%=pkcs7.getNotAfter().toString()%><br/>
CertType: <%=pkcs7.getCertType()%><br/>
getDN: <%=pkcs7.getDn()%><br/>

<br/>
PersonId: <%=pkcs7.getPersonId()%><br/>
SERIALNUMBER: <%=pkcs7.getDnField(org.bouncycastle.asn1.x500.style.BCStyle.SERIALNUMBER)%><br/>
SERIALNUMBER: <%=pkcs7.getDnField("SERIALNUMBER")%><br/>
CN: <%=pkcs7.getDnField(org.bouncycastle.asn1.x500.style.BCStyle.CN)%><br/>
CN: <%=pkcs7.getDnField("CN")%><br/>

<br/>
EnterpriseId: <%=pkcs7.getEnterpriseId()%><br/>
O: <%=pkcs7.getDnField(org.bouncycastle.asn1.x500.style.BCStyle.O)%><br/>
O: <%=pkcs7.getDnField("O")%><br/>

</H2></body>
</html>