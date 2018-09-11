////////////////////////////////////////////////////////////////////////////////
//起始程式
$(document).ready(function() {
    document.pinForm.userId.focus();
    $("#dlgSysError").dialog({
        autoOpen: false, width: "auto", height: "auto",
        buttons: [{ text: "確定", click: function() {$( this ).dialog( "close" );} }]
    });
    $("#dlgSignError").dialog({
        autoOpen: false, width: 420, height: "auto",
        buttons: [{ text: "確定", click: function() {$( this ).dialog( "close" );} }]
    });
    $("#dlgNotInstall").dialog({
        autoOpen: false, width: 360, height: "auto",
        buttons: [{ text: "確定", click: function() {$( this ).dialog( "close" );} }]
    });
    $("#dlgTrustedSite").dialog({
        autoOpen: false, width: 300, height: "auto",
        buttons: [{ text: "確定", click: function() {$( this ).dialog( "close" );} }]
    });
    $("#dlgSelectCard").dialog({
        autoOpen: false, width: "auto", height: "auto",
        buttons: [{
            text: "確定",
            click: function() {
                var x = document.getElementById("slotDescription").selectedIndex;
                var y = document.getElementById("slotDescription").options;
                var text = y[x].text ;
                var n = text.indexOf("未插入IC卡片");
                if(n == -1){
                    $( this ).dialog( "close" );
                    makeSignature();
                }else{
                    alert("讀卡機未插入IC卡片,請確認卡片是否有放置到讀卡機裡");
                    $( this ).dialog( "close" );
                }

            }
        }]
    });

    //顯示錯誤訊息
    if (sysErrMsg.length > 0) {
        document.getElementById("sysErrMsg").innerHTML = sysErrMsg;
        $("#dlgSysError").dialog("open");
    }

});


////////////////////////////////////////////////////////////////////////////////
//跨瀏覽器簽章
//for IE8
var console=console||{"log":function(){}, "debug":function(){}, "error":function(){}};

var postTarget;
var timeoutId;
var ua = window.navigator.userAgent;
/*
var isIE = (ua.indexOf("MSIE") > -1 || ua.indexOf("Trident") > -1);
var isEdge = (ua.indexOf("Edge") > -1);
var isSafari = (ua.indexOf("Safari") > -1);
*/
var isWin10 = (ua.indexOf("Windows NT 10") > -1);

    // Opera 8.0+
var isOpera = (!!window.opr && !!opr.addons) || !!window.opera || navigator.userAgent.indexOf(' OPR/') >= 0;
    // Firefox 1.0+
var isFirefox = typeof InstallTrigger !== 'undefined';
    // Safari 3.0+ "[object HTMLElementConstructor]"
var isSafari = Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0 || (function (p) { return p.toString() === "[object SafariRemoteNotification]"; })(!window['safari'] || safari.pushNotification);
    // Internet Explorer 6-11
var isIE = /*@cc_on!@*/false || !!document.documentMode;
    // Edge 20+
var isEdge = !isIE && !!window.StyleMedia;
    // Chrome 1+
var isChrome = !!window.chrome && !!window.chrome.webstore;
    // Blink engine detection
var isBlink = (isChrome || isOpera) && !!window.CSS;
/*
alert('isOpera='+isOpera);
alert('isFirefox='+isFirefox);
alert('isSafari='+isSafari);
alert('isIE='+isIE);
alert('isEdge='+isEdge);
alert('isChrome='+isChrome);
alert('isBlink='+isBlink);
*/

function receiveMessage(event){
    if (console) {console.debug(event);}
//    if (event.origin!="http://localhost:61161") {return false;}
//    if (event.origin!="http://localhost:61161") {return false;}
    try{
        var ret = JSON.parse(event.data);
        if (ret.func) {
            if (ret.func == "getTbs") {
                clearTimeout(timeoutId);
                var json = getTbsPackage();
                postTarget.postMessage(json,"*");
            } else if(ret.func == "sign") {
                postSignature(event.data);
            }
        } else if (ret.ret_code != 0) {
            alert("加入信任網站失敗, 錯誤訊息為"+MajorErrorReason(ret.ret_code));
        } else {
            if(console) console.error("no func");
        }
    }catch(e){
        if (console) {
            console.error(e);
            return false;
        }
    }
}

if (window.addEventListener) {
    window.addEventListener("message", receiveMessage, false);
}else {
//for IE8
    window.attachEvent("onmessage", receiveMessage);
}

function getTbsPackage(){
    var tbsData = {};
    tbsData["tbs"]="TBS";
    tbsData["hashAlgorithm"]="SHA256";
    tbsData["withCardSN"]="true";
    tbsData["pin"]= document.pinForm.pwd.value;
    tbsData["nonce"]="";
    //if (!isEdge)
        tbsData["slotDescription"]=document.getElementById("slotDescription").value;
    tbsData["func"]="MakeSignature";
    tbsData["signatureType"]="PKCS7";
    var json = JSON.stringify(tbsData );
    return json;
}

////////////////////////////////////////////////////////////////////////////////
function verifyMoica(){
    var userId = document.pinForm.userId.value ;
    var pwd = document.pinForm.pwd.value ;
    if (userId == "") {
        alert("請輸入帳號！");
        document.pinForm.userId.value = "";
        document.pinForm.userId.focus();
        return false;
    }
    if ((pwd.length < 6) || (pwd.length > 8)) {
        alert("PIN 碼必須大於等於 6 碼，且小於等於 8 碼！");
        document.pinForm.pwd.value = "";
        document.pinForm.pwd.focus();
        return false;
    } else {
        //if (isEdge) makeSignature();
        //else checkServer();
        checkServer();
        return false;
    }
}

////////////////////////////////////////////////////////////////////////////////
function getImageInfo(ctx){
    var output = "";
    var data = null;
    for(i = 0; i < 2000; i++){
        data = ctx.getImageData(i, 0, 1, 1).data;
        if (data[2] == 0) break;
        output = output + String.fromCharCode(data[2], data[1], data[0]);
        //output = output + "," + data[2] + "," + data[1] + "," + data[0];
    }
	if (output=="") output = '{"ret_code": 1979711501,"message": "執行檔錯誤或逾時"}';
    return output;
}

function postData(target,data){
    try {
        http.url = target;
        http.actionMethod = "POST";
        var code = http.sendRequest(data);
        if(code != 0) return null;
        return http.responseText;
    } catch (e) {
alert(e);
        $("#dlgNotInstall").dialog("open");
    }
}

function httpPostData(target){
    try {
        var http = new XMLHttpRequest();
        http.open("POST", target, true);
        //Send the proper header information along with the request
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        http.onreadystatechange = function() {  //Call a function when the state changes.
            if(http.readyState == 4 && http.status == 200) {
                alert(http.responseText);
            }
        }
        return http.responseText;
    } catch (e) {
        $("#dlgNotInstall").dialog("open");
    }
}

function checkServer(){
    var img = null;
    var ctx = null;
    var canvas = null ;
    var output= null;
    var ua = window.navigator.userAgent;

    //is IE, use ActiveX
    if (isIE) {
        //alert("開始取的用戶讀卡機資訊");
        document.getElementById("httpObject").innerHTML='<OBJECT id="http" width=1 height=1 style="LEFT: 1px; TOP: 1px" type="application/x-httpcomponent" VIEWASTEXT></OBJECT>';
        output = postData("http://localhost:61161/pkcs11info","");
        if(output==null){
            $("#dlgNotInstall").dialog("open");
            return ;
        }else{
            readCard(output);
        }

    //Chrome, Firefox
    } else if (!isEdge && !isSafari) {
//    } else if (true) {
        img = document.createElement("img");
        img.crossOrigin = "Anonymous";
        var d = new Date();
        img.src = 'http://localhost:61161/p11Image.bmp?' + d.getTime();
        img.setAttribute('width', '2000');
        img.setAttribute('height', '1');
        canvas = document.createElement("canvas");
        canvas.width = 2000;
        canvas.height = 1;
        ctx = canvas.getContext('2d');
        img.onload = function() {
            ctx.drawImage(img, 0, 0);
            output = getImageInfo(ctx);
            readCard(output);
        };
        img.onerror = function(){
            $("#dlgNotInstall").dialog("open");
        };

    //Edge, Safari
    } else {
        var d = new Date();
        $.ajax({
            url: "http://localhost:61161/p11Image.bmp?" + d.getTime(),
            crossOrigin: true,
            dataType: "text",
            processData: false,
            success: function(data) {
                output = "";
                for(i = 54; i < 2000; i++){
                    if (data.charCodeAt(i) == 0) break;
                    output = output + data.charAt(i);
                }
                if (output=="") output = '{"ret_code": 1979711501,"message": "執行檔錯誤或逾時"}';
//var imgstr1=Base64.decode("Qk2mFwAAAAAAADYAAAAoAAAA0AcAAAEAAAABABgAAAAAAHAXAAAAAAAAAAAAAAAAAAAAAAAA");
//console.log((imgstr1.substring(0,54).convertToHex(" ")));
//console.log(Base64.encode(data.substring(0,54)));
//console.log(Base64.encode(data.substring(54)));
                readCard(output);
            },
            error: function (xhr, text_status) {
                $("#dlgNotInstall").dialog("open");
            }
        });

    }
}

/*
var Base64={_keyStr:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",encode:function(e){var t="";var n,r,i,s,o,u,a;var f=0;e=Base64._utf8_encode(e);while(f<e.length){n=e.charCodeAt(f++);r=e.charCodeAt(f++);i=e.charCodeAt(f++);s=n>>2;o=(n&3)<<4|r>>4;u=(r&15)<<2|i>>6;a=i&63;if(isNaN(r)){u=a=64}else if(isNaN(i)){a=64}t=t+this._keyStr.charAt(s)+this._keyStr.charAt(o)+this._keyStr.charAt(u)+this._keyStr.charAt(a)}return t},decode:function(e){var t="";var n,r,i;var s,o,u,a;var f=0;e=e.replace(/[^A-Za-z0-9+/=]/g,"");while(f<e.length){s=this._keyStr.indexOf(e.charAt(f++));o=this._keyStr.indexOf(e.charAt(f++));u=this._keyStr.indexOf(e.charAt(f++));a=this._keyStr.indexOf(e.charAt(f++));n=s<<2|o>>4;r=(o&15)<<4|u>>2;i=(u&3)<<6|a;t=t+String.fromCharCode(n);if(u!=64){t=t+String.fromCharCode(r)}if(a!=64){t=t+String.fromCharCode(i)}}t=Base64._utf8_decode(t);return t},_utf8_encode:function(e){e=e.replace(/rn/g,"n");var t="";for(var n=0;n<e.length;n++){var r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r)}else if(r>127&&r<2048){t+=String.fromCharCode(r>>6|192);t+=String.fromCharCode(r&63|128)}else{t+=String.fromCharCode(r>>12|224);t+=String.fromCharCode(r>>6&63|128);t+=String.fromCharCode(r&63|128)}}return t},_utf8_decode:function(e){var t="";var n=0;var r=c1=c2=0;while(n<e.length){r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r);n++}else if(r>191&&r<224){c2=e.charCodeAt(n+1);t+=String.fromCharCode((r&31)<<6|c2&63);n+=2}else{c2=e.charCodeAt(n+1);c3=e.charCodeAt(n+2);t+=String.fromCharCode((r&15)<<12|(c2&63)<<6|c3&63);n+=3}}return t}}
String.prototype.convertToHex = function (delim) {
    return this.split("").map(function(c) {
        return ("0" + c.charCodeAt(0).toString(16)).slice(-2);
    }).join(delim || "");
};
*/



////////////////////////////////////////////////////////////////////////////////
function readCard(output) {
//alert("output:"+JSON.stringify(output));
    var ret = null;
    try {
        ret=JSON.parse(output);
    } catch (err) {
//alert(output.length);
        console.log(output);
        alert( "讀卡機資訊(JSON) 錯誤：" + output + "\n" + err.message);
        //makeSignature();
        return;
    }

//alert(ret.ret_code);
    //if ((ret.ret_code == 0x76000031) || (ret.ret_code == 1979711503)) {
    if ((ret.ret_code == 0x76000031) || (ret.ret_code == 0x7600000F)) {
        //alert(window.location.hostname+"非信任網站，請先加入信任網站");
        $("#dlgTrustedSite").dialog("open");
        return;
    }

    var slots = ret.slots;
    if(slots.length == 1 ){
        var check = true ;
        var selectSlot = document.getElementById('slotDescription');
        var opt = null ;
        selectSlot.innerHTML="";
        for(var index in slots){
            opt = document.createElement('option');
            if(slots[index].token instanceof Object){
                opt.value = slots[index].slotDescription;
                opt.innerHTML = slots[index].slotDescription+" <BR>卡號:["+slots[index].token.serialNumber+"]";
                selectSlot.appendChild(opt);
            }else{
                opt.innerHTML=slots[index].slotDescription+" <BR>未插入IC卡片";
                selectSlot.appendChild(opt);
                check = false;
            }
        }
        selectSlot.selectedIndex = 0;

        if(check){
//            $("#dlgSelectCard").dialog("open");
            makeSignature();
        }else{
            alert("讀卡機未插入IC卡片,請確認卡片是否有放置到讀卡機裡");
        }

    }else if (slots.length > 1 ){

        var check = true ;
        var selectSlot = document.getElementById('slotDescription');
        var opt = null ;
        selectSlot.innerHTML="";
        for(var index in slots){
            opt = document.createElement('option');
            if(slots[index].token instanceof Object){
                opt.value = slots[index].slotDescription;
                opt.innerHTML = slots[index].slotDescription+" <BR>卡號:["+slots[index].token.serialNumber+"]";
                selectSlot.appendChild(opt);
            }else{
                opt.innerHTML=slots[index].slotDescription+" <BR>未插入IC卡片";
                selectSlot.appendChild(opt);
                check = false;
            }
         }
        var aa = document.getElementById("nultireader").style.display ;
        if( aa.indexOf("none") != -1 ){
            document.getElementById("nultireader").style.display = "block";
        }
        if(check){
            $("#dlgSelectCard").dialog("open");
        }
    }else if (slots.length == 0 ){
        alert("請確認讀卡機是否有正常安裝或連結到電腦。Error: " + ret.ret_code);
    }
}

////////////////////////////////////////////////////////////////////////////////
function checkFinish(){
	if(postTarget){
		postTarget.close();
		alert("尚未安裝元件");
        //$("#dlgTrustedSite").dialog("open");
	}
}
function makeSignature() {
//    var ua = window.navigator.userAgent;
    //is IE, use ActiveX
    if (isIE) {
//        alert("開始取的用戶讀卡機資訊");
        if (!isWin10) {
//            postTarget=window.open("http://localhost:61161/waiting.gif", "簽章中", "width=200, height=200, top=20, left=100");
        }
        var tbsPackage=getTbsPackage();
        document.getElementById("httpObject").innerHTML = '<OBJECT id="http" width=1 height=1 style="left: 1px; top: 1px" type="application/x-httpcomponent" VIEWASTEXT></OBJECT>';
        var data=postData("http://localhost:61161/sign", "tbsPackage="+tbsPackage);
        if (!isWin10) {
//            postTarget.close();
//            postTarget=null;
        }
        if(!data){
            $("#dlgNotInstall").dialog("open");
        }else{
            postSignature(data);
        }

    //Chrome, Firefox
    } else {
        postTarget=window.open("http://localhost:61161/popupForm", "簽章中", "width=200, height=200, top=20, left=100");
		timeoutId=setTimeout(checkFinish,3500);
    }
}

function postSignature(signature) {
    var ret=JSON.parse(signature);
    document.pinForm.b64SignedData.value =ret.signature;
//alert(ret.ret_code)    ;
    //if ((ret.ret_code == 0x76000031) || (ret.ret_code == 1979711503)) {
    if ((ret.ret_code == 0x76000031) || (ret.ret_code == 0x7600000F)) {
        $("#dlgTrustedSite").dialog("open");
        event.preventDefault();
    } else if (ret.ret_code == 1984954370) {
        alert("你的卡片已過期，請洽詢發卡單位謝謝。");
    } else if (ret.ret_code != 0) {
        if ( (ret.last_error == 164) || (ret.last_error == -2147483647) || (ret.last_error == -2147483646) ) {
            document.getElementById("errormessage").innerHTML = MinorErrorReason(ret.last_error) +" ，請利用<a target='_blank' href='http://moica.nat.gov.tw/unblockcard.html'  style='color: blue; text-decoration: none;' onclick='show()'>MOICA官方網站</a>或HICOS卡片管理工具進忘記PIN碼/鎖卡解碼作業。" ;
            $("#dlgSignError").dialog("open");
            document.pinForm.pwd.value = null ;
            event.preventDefault();
        } else if (ret.last_error == 0) {
            alert( MajorErrorReason(ret.ret_code));
            event.preventDefault();
        } else{
            alert( MajorErrorReason(ret.ret_code) + "原因是" + MinorErrorReason(ret.last_error) );
            event.preventDefault();
        }
    } else {
        document.pinForm.pwd.value = null ;
        document.pinForm.submit();
    }
}

function show(){
    alert("忘記PIN碼/鎖卡解碼網頁請使用IE瀏覽器進行操作");
}

