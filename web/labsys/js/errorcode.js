function MajorErrorReason(rcode){
	switch(rcode){
		case 0x76000001:
			return "未輸入金鑰";
		case 0x76000002:
			return "未輸入憑證";
		case 0x76000003:
			return "未輸入待簽訊息";
		case 0x76000004:
			return "未輸入密文";
		case 0x76000005:
			return "未輸入函式庫檔案路徑";
		case 0x76000006:
			return "未插入IC卡";
		case 0x76000007:
			return "未登入";
		case 0x76000008:
			return "型態錯誤";
		case 0x76000009:
			return "檔案錯誤";
		case 0x7600000A:
			return "檔案過大";
		case 0x7600000B:
			return "JSON格式錯誤";
		case 0x7600000C:
			return "參數錯誤";
		case 0x7600000D:
			return "執行檔錯誤或逾時";
		case 0x7600000E:
			return "不支援的方法";
		case 0x7600000F:
			return "禁止存取的網域";
		case 0x76000998:
			return "未輸入PIN碼";
		case 0x76000999:
			return "使用者已取消動作";
		case 0x76100001:
			return "無法載入IC卡函式庫檔案";
		case 0x76100002:
			return "結束IC卡函式庫失敗";
		case 0x76100003:
			return "無可用讀卡機";
		case 0x76100004:
			return "取得讀卡機資訊失敗";
		case 0x76100005:
			return "取得session失敗";
		case 0x76100006:
			return "IC卡登入失敗";
		case 0x76100007:
			return "IC卡登出失敗";
		case 0x76100008:
			return "IC卡取得金鑰失敗";
		case 0x76100009:
			return "IC卡取得憑證失敗";
		case 0x7610000A:
			return "取得函式庫資訊失敗";
		case 0x7610000B:
			return "IC卡卡片資訊失敗";
		case 0x7610000C:
			return "找不到指定憑證";
		case 0x7610000D:
			return "找不到指定金鑰";
		case 0x76200001:
			return "pfx初始失敗";
		case 0x76200006:
			return "pfx登入失敗";
		case 0x76200007:
			return "pfx登出失敗";
		case 0x76200008:
			return "不支援的CA";
		case 0x76300001:
			return "簽章初始錯誤";
		case 0x76300002:
			return "簽章型別錯誤";
		case 0x76300003:
			return "簽章內容錯誤";
		case 0x76300004:
			return "簽章執行錯誤";
		case 0x76300005:
			return "簽章憑證錯誤";
		case 0x76300006:
			return "簽章DER錯誤";
		case 0x76300007:
			return "簽章結束錯誤";
		case 0x76300008:
			return "簽章驗證錯誤";
		case 0x76300009:
			return "簽章BIO錯誤";
		case 0x76400001:
			return "解密DER錯誤";
		case 0x76400002:
			return "解密型態錯誤";
		case 0x76400003:
			return "解密錯誤";
		case 0x76500001:
			return "憑證尚未生效";
		case 0x76500002:
			return "憑證已逾期";
		case 0x76600001:
			return "Base64編碼錯誤";
		case 0x76600002:
			return "Base64解碼錯誤";
		case 0x76700001:
			return "伺服金鑰解密錯誤";
		case 0x76700002:
			return "未登錄伺服金鑰";
		case 0x76700003:
			return "伺服金鑰加密錯誤";
		case 0x76210001:
			return "身分證字號或外僑號碼比對錯誤";
		case 0x76210002:
			return "未支援的憑證型別";
		case 0x76210003:
			return "非元大寶來憑證";
		case 0x76210004:
			return "非中華電信通用憑證管理中心發行之憑證";

		case 0x77100001:
			return "圖形驗證碼不符";
		case 0x77200001:
			return "未輸入附卡授權SNO碼";
		case 0x77200002:
			return "讀附卡授權證發生錯誤:Buffer太小";
		case 0x77200003:
			return "讀附卡授權證發生錯誤:卡片空間不足";
		case 0x77200004:
			return "讀附卡授權證發生錯誤:資料太大";                        
		case 0x77200005:
			return "讀附卡授權證發生錯誤:DLL載入發生錯誤(E_NOT_LOAD_DLL)";
		case 0x77200006:
			return "讀附卡授權證發生錯誤:支援函數錯誤(E_NOT_SUPPORT_FUNCTION)";
		case 0x77200007:
			return "讀附卡授權證發生錯誤:讀卡slot錯誤(E_SLOT)";
		case 0x77200008:
			return "讀附卡授權證發生錯誤:Index格式錯誤";                      
		case 0x77200009:
			return "讀附卡授權證發生錯誤:讀卡機未選擇(READER_NOT_SELECT_ERROR)";
		case 0x77200010:
			return "讀附卡授權證發生錯誤:SNO碼錯誤(SNO_EXIST)";
		case 0x77200011:
			return "讀附卡授權證發生錯誤:SNO碼錯誤(SNO_NO_EXIST)";    

		case -536870893: //0xE0000013
			return "金鑰不相符";
		case -536870894: //0xE0000012
			return "使用者取消";
		case -536870896: //0xE0000010
			return "建立金鑰容器失敗，可能是因為權限不足";
		case -536870897: //0xE000000F
			return "找不到任一家CA發的該類別用戶憑證，但中華電信該憑證類別中有找到其他用戶";
		case -536870898: //0xE000000E
			return "開啟物件(p7b)失敗";
		case -536870899: //0xE000000D
			return "HEX字串格式錯誤";
		case -536870900: //0xE000000C
			return "HEX字串長度錯誤";
		case -536870901: //0xE000000B
			return "寬位元字串轉多位元字串轉換失敗";
		case -536870902: //0xE000000A
			return "開啟CertStore失敗";
		case -536870903: //0xE0000009
			return "匯出檔案失敗";
		case -536870904: //0xE0000008
			return "匯入檔案失敗";
		case -536870905: //0xE0000007
			return "必須輸入檔案路徑";
		case -536870906: //0xE0000006
			return "找不到任一家CA發的該類別用戶憑證";
		case -536870907: //0xE0000005
			return "找不到中華電信該類別用戶憑證，但找得到其他CA發的該類別用戶憑證";
		case -536870908: //0xE0000004
			return "未支援的參加單位代碼";
		case -536870909: //0xE0000003
			return "金鑰的雜湊值不一致";
		case -536870910: //0xE0000002
			return "程式配置記憶體失敗";
		case -536870911: //0xE0000001
			return "找不到由中華電信所核發且合乎搜尋條件的憑證";
		default:
			return rcode.toString(16);
	}
}
function MinorErrorReason(rcode){
	switch(rcode){
		case 0x06:
			return "函式失敗";
		case 0xA0:
			return "PIN碼錯誤";
		case 0xA2:
			return "PIN碼長度錯誤";
		case 0xA4:
			return "已鎖卡";
		case 0x150:
			return "記憶體緩衝不足";
		case -2147483647:
			return "PIN碼錯誤，剩餘一次機會";
		case -2147483646:
			return "PIN碼錯誤，剩餘兩次機會";
		default:
			return rcode.toString(16);
	}
}