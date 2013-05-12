# 筆順碼輸入法 for Mac OS X

這是筆順碼輸入法的 Mac OS X 版本。

## 安裝

1. 下載[程式](https://www.dropbox.com/s/addp54iccbze65g/BSMInputMethod_0.3.1.zip)
2. 解壓後，把程式檔 (BSMInputMethod.app) 複制到 ```/Users/<User-Name>/Library/Input Methods``` 資夾下
3. 在 "系統偏好設定" > "語言與文字" > "輸入來源" 下選取 "BSM 筆順碼"
4. 按 command-space 直到轉到 "BSM 筆順碼"

## 用法

請參考這篇 [Blog](http://hkxforce.net/wordpress/543)。

## 為何要做這個輸入法？

因為這個輸入法很簡單很易學，自從 Windows 95 時代用了半小時便學懂，之後我再也不想再學其他的輸入法了。

可惜這個輸入法自2000年便沒有更新，而且香港的代理也倒閉了。本來我一直使用其 Java Applet 版本，但因為最近 Java 的安全性問題，要在 browser 開它也不大方便，終於要自己動手寫一個代用品了。

## 版本

### 0.3.1

- 修正使用 "-" 鍵時遇上的問題

### 0.3.0

- 按 "*" 可以做萬用字元，代表任何字碼
- 按 "+" 可以在選字表顯示字碼
- (實驗性) 以字頻去排序：使用萬用字元時會返回大量的結果，使用字頻去排序使用者更易找到想找的字。不影響正常輸入。
- 其他小改進

### 0.2.0

- 選字時，按 "/" 去下一頁、按 "=" 去上一頁
- 輸入時按 "Clear" 可清除所有已輸入的字碼
- 其他小改進

### 0.1.1

- 修正一些快速輸入時的問題

### 0.1.0

- 第一個版本。以 applet 版輸入法為基本設計。
- 基本功能完成，需要多點時間測試和除錯。

## 授權

本程式碼以 MIT License 授權。

輸入法和其碼表由其原本持有人版權所有。

## Attribution

- data/bsm_applet.dat - 由筆順碼 applet 版抽出的檔案
- data/BIAU1.TXT - 台灣教育部「[字頻總表](http://www.edu.tw/files/site_content/m0001/pin/yu7.htm?open)」

