# 功能：實現一個 Pokedex 應用程式

## 場景 1: 顯示 Pokemon 列表

**Given** 使用者打開 Pokedex 應用程式  
**When** 使用者瀏覽 Pokemon 列表  
**Then** 應用程式應顯示 Pokemon 列表，按國家圖鑑 ID 編號排序  

## 場景 2: 查看 Pokemon 詳情

**Given** 使用者點擊 Pokemon 項目  
**When** 使用者查看 Pokemon 詳情頁面  
**Then** 應用程式應顯示 Pokemon 的詳細信息，包括 ID、名稱、類型、圖像、進化鏈和圖鑑描述  

## 場景 3: 加載更多 Pokemon 數據

**Given** 使用者滾動到列表底部  
**When** 應用程式自動加載更多 Pokemon 數據  
**Then** 應用程式應加載附加的 Pokemon 數據  

## 場景 4: 標記 Pokemon 為收藏

**Given** 使用者點擊 Pokemon 項目並選擇標記為收藏  
**When** 使用者將 Pokemon 標記為收藏  
**Then** 應用程式應記錄 Pokemon 的收藏狀態並將其保存到本地存儲  

## 場景 5: 過濾收藏的 Pokemon

**Given** 使用者選擇過濾器以顯示收藏的 Pokemon  
**When** 使用者應用過濾器  
**Then** 應用程式應僅顯示收藏的 Pokemon  

## 場景 6: 切換列表和網格視圖

**Given** 使用者點擊切換視圖按鈕  
**When** 使用者切換列表和網格視圖  
**Then** 應用程式應切換 Pokemon 列表的顯示方式  

## 場景 7: 緩存數據以提高加載速度

**Given** 使用者打開 Pokedex 應用程式  
**When** 應用程式啟動  
**Then** 應用程式應從本地緩存加載數據以提高加載速度  

## 場景 8: 查看類型 Pokemon

**Given** 使用者選擇查看類型表  
**When** 使用者打開類型表  
**Then** 應用程式應根據類型顯示 Pokemon ，並允許使用者訪問每個 Pokemon 的詳細信息  

## 補充說明：
- 實現以上功能需要與 Pokemon API 和 Types API 進行交互。
- 可以選擇使用 Swift 的 UIKit 或 SwiftUI 進行布局。
- 可以使用 CocoaPods、Carthage 或 Swift Package Manager 安裝第三方庫。
- 可選任務包括編寫單元測試、UI 測試、實現依賴注入、實現本地數據緩存等。
- 完成後，請將代碼上傳至公共 Git 存儲庫，並在 README 文件中提供項目概述、運行說明、設計模式說明以及使用的 LLM 工具說明。