; BRDUtil.msg

;MESSAGE BOX TITLE
0000      Buffalo RAMDISK Utility

;FONT SIZE
;0001      9

; DIALOG TITLE
2001      Buffalo RAMDISK Utility

; Label
2101      確定
2102      取消

2111      狀態： %s
2112      磁碟機字母：

2120      備份模式
2121      無備份
2122      備份 (關閉電源及休眠)
2123      在開機時自動還原資料。
2124      備份 (適用Expert)
2125      在閒置時備份。
2126      在寫入時備份。
2127      儲存其餘部份
2128      %lld MB
2129      立即備份！
2130      取消立即備份！

2140      其他
2141      在[我的文件]資料夾內建立捷徑
2142      對Internet Explorer使用快取。
2143      對Firefox使用快取。

2160      RAMDISK區域
2161      使用超過4GB及低於4GB
2162      備妥的RAMDISK容量
2163      %d MB
2164      最大%d MB
2165      磁碟大小
2166      設定最大大小。
2171      超過4GB
2181      低於4GB
2191      無

2200      * 在某些電腦中，可能無法從外部使用作業系統管理。
2201      * 外部空間管理的TurboPC快取、作業系統使用。若作業系統無系統管理之外的可用空間，將會使用既有空間進行作業系統管理。

; Restart
3011 Q Y2 某些設定值只有在重新啟動後才會生效。\n\n您是否想要重新啟動？
3012 I O  某些設定值只有在重新啟動後才會生效。
3013 Q Y2 已取消重新啟動驅動程式。\n某些設定值只有在重新啟動後才會生效。\n\n您是否想要重新啟動？

; Memory area configuration
3021 Q C2 變更記憶體區設定值。\n\n[注意] 並未儲存目前已儲存在RAMDISK中的資料。亦已啟動目前RAMDISK設定值。\n\n您是否想要繼續？

; Driver status
3101      預設設定值。
3102      已停止。
3103      運作中。
3105      已中止。
3181      因為系統錯誤而停止。
3182      因為驗證錯誤而停止。
3183      因為位址匯流排錯誤而停止。
3184      因為存取超過4GB的錯誤而停止。
3185      因為組態及實際記憶體之間的衝突而停止。
3186      因為未指定的記憶體區而停止。
3187      RAMDISK至少需要1GB。

; Driver status　（Error message）
3381 E O  因為系統錯誤而停止。
3382 W O  找不到Buffalo記憶體。\n\n至少必須使用一條Buffalo品牌記憶體，才能使用本工具程式。 
3383 W O  因為位址匯流排錯誤而停止。\n\n請再次設定。
3384 W O  因為無法存取超過4GB而停止。\n\n請再次設定。
3385 W O  已減少記憶體容量。\n\n無法使用RAMDISK。\n\n請再次設定。
3387 E O  RAMDISK至少需要1GB。

; Driver status　（Memory capacity）
3401 Q Y  已增加記憶體容量。\n\n是否再次設定？
3402 Q Y  已增加記憶體容量。\n\n是否再次設定？
3403 Q Y  已增加記憶體容量。\n\n是否再次設定？
3404 Q Y  已增加記憶體容量。\n\n是否再次設定？
3411      是
3412      無（保持設定值）
3413      並未顯示。

; Boot error
3501 E O  需要系統管理員權限。
3502 E O  未啟用RAMDISK。
3503 E O  ERROR. QUERY_PARAMETERS
3510 E O  因為發生問題，請解除安裝。

; Configuration error
3600 E O  錯誤的組態。
3601 W O  錯誤的磁碟字母設定。
3602 W O  錯誤的備份模式設定。
3603 W O  錯誤的記憶體區設定。
3611 W O  無法立即備份。
3612 W O  無法取消備份。

3621 W O  未選擇記憶體區。
3622 W O  在作業系統管理區指定無效的磁碟容量。
3623 W O  在總記憶體區指定無效的磁碟容量。

3701 W O  Internet Explorer快取設定錯誤。
3702 W O  FireFox快取設定錯誤。
3703 E O  因為正在執行FireFox而造成設定錯誤。
3704 W O  ReadyBoost設定錯誤。

3711 W O  My RAMDISK 掛載錯誤
3712 W O  My RAMDISK 卸載錯誤

3721 W O  無法將MAXMEM 加入開機選項。
3722 W O  無法將MAXMEM 從開機選項刪除。

; ReadyBoost
4101      (%c:) 的內容
4102    請勿使用本裝置。(&D)
4103     使用本裝置。(&U)

; My RAMDISK
4201      My RAMDISK

; Wizard
5001      RAMDISK Utility安裝
5002      簡易安裝
5003      進階安裝
5004      安裝程式會自動符合您的環境。
5005      選擇本選項以進行自訂安裝。
5006      狀態 : %s
5010 Q Y  建立%ldMB RAMDISK。\n您是否想要繼續？
5011 I O  已完成簡易安裝。

; BRDUtilTray.exe
6001      Buffalo RAMDISK系統列工具程式
6101      組態
6102      結束
6501 E O  檢查CPU閒置錯誤。
6502 Q Y  設定停用CPU效能監視器。\n按一下確定以啟用CPU效能監視器。
6503 E O  無法檢查CPU閒置。\n請設定虛擬記憶體設定值。
6504 E O  無法執行「Buffalo RAMDISK Utility」。

; BRDStartup.exe
7801 E O  驗證錯誤。


