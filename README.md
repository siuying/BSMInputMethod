# 筆順碼輸入法 for Mac OS X

這是筆順碼輸入法的 Mac OS X 版本。

## 安裝

### 使用 Homebrew

1. ``brew install siuying/tap/bsm``
2. 在 "系統偏好設定" > "語言與文字" > "輸入來源" 下選取 "BSM 筆順碼"
3. 如果你使用的是 Apple Silicon Mac，請先安裝 Rosetta (```/usr/sbin/softwareupdate --install-rosetta --agree-to-license```)，然後手動執行 ```/Library/Input Methods/BSMInputMethod.app``` 一次。
4. 如果你使用的是 Mojave 或以上，需要到 "系統偏好設定" > "安全性和私隱" 容許執行 BSM Input Method。
5. 按 ctrl-space 直到轉到 "BSM 筆順碼"

### 手動安裝

1. 下載[程式](https://www.dropbox.com/s/dnbl52tfasq2hfm/BSMInputMethod_0.3.2.zip)
2. 解壓後，把程式檔 (BSMInputMethod.app) 複制到 ```/Users/<User-Name>/Library/Input Methods``` 資夾下
3. 在 "系統偏好設定" > "語言與地區" > "鍵盤編好設定" > "輸入方式" > "+" > 在「繁體中文」下選取「BSM 筆順碼」
4. 如果你使用的是 Mojave 或以上，需要到 "系統偏好設定" > "安全性和私隱" 容許執行 BSM Input Method
5. 如果你使用的是 Apple Silicon Mac，請先安裝 Rosetta (```/usr/sbin/softwareupdate --install-rosetta --agree-to-license```)，然後手動執行 ```/Library/Input Methods/BSMInputMethod.app``` 一次。
6. 按 command-space 直到轉到 "BSM 筆順碼"

## 為何要做這個輸入法？

因為這個輸入法很簡單很易學，自從 Windows 95 時代用了半小時便學懂，之後我再也不想再學其他的輸入法了。

可惜這個輸入法自2000年便沒有更新，而且香港的代理也倒閉了。本來我一直使用其 Java Applet 版本，但因為最近 Java 的安全性問題，要在 browser 開它也不大方便，終於要自己動手寫一個代用品了。

## 輸入法使用法

筆順碼以數字鍵盤輸入，每個數字代表一種筆畫。跟一般筆劃輸入法不同，筆順碼將每個字的頭三筆和由最尾倒數的三筆代表一個字。因此做到最少一碼，最多六碼代表所有中文字。

十個數字鍵分別代表以下筆畫：

1. 橫 - 如「明」的第二筆、「天」的頭兩筆
2. 直 - 如「工」的第二筆、「作」的第二筆
3. 撇 - 如「我」的第一筆、「的」的第一筆
4. 捺和點 - 如「旅」和「遊」的第一筆
5. 順時針勾 - 如「刀」和「書」的第一筆
6. 逆時針勾 - 如「以」的第一筆、「組」的頭兩筆
7. 交叉 - 如「子」的第一筆、「時」的尾二筆、「切」的第一筆、「文」的最尾一筆
8. 人、八或兩點 - 如「次」的第一筆、「暴」的尾兩筆
9. 十字型 - 如「其」的第一筆、「物」的第二筆、「田」的第二筆
10. 口字型 - 如「各」的最尾一筆和「國」的第一筆

數字鍵的以下鍵有特殊功能：

- . 選字鍵，當選字表有想要的字時，可以按 . 再按字碼數字，如 .3 代表第三字
- Enter 選擇選字表第一個字，和 .1 一樣效果
- * 萬用鍵，代表一個或更代的鍵
- - 減去一個輸入
- Clear 清除所有輸入
- = 選字表上一頁
- / 選字表下一頁
- + 顯示選字表的字的字碼

如「順」字可以輸入 3228 enter 或 322801.3 「順」

標點符號的字碼為 60-62、933-939。

參考：

- [筆順碼筆劃](http://web.archive.org/web/20090106155430/http://www.freefire.com.hk/other/input02.htm)
- [輸入示範 - 常見的首三碼](http://web.archive.org/web/20080615024154/http://www.freefire.com.hk/other/demo01.htm)
- [輸入示範 - 常見的尾三碼](http://web.archive.org/web/20080615180037/http://www.freefire.com.hk/other/demo02.htm)
- [輸入示範 - 示範1](http://web.archive.org/web/20080615180042/http://www.freefire.com.hk/other/demo03.htm)
- [輸入示範 - 示範2](http://web.archive.org/web/20080615180042/http://www.freefire.com.hk/other/demo04.htm)

## 版本

### 0.3.2

- 按空白鍵等同 Enter (選字)

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

