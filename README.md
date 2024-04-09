# SampleList

本專案採用 View-Model-UseCase-Repo-Service 架構進行開發設計。

## 關於架構

View-Model-UseCase-Repo-Service 是一種現代化的軟體架構模式，旨在將應用程式分為多個層次，以提高程式碼的可維護性、可測試性和可擴展性。以下是每個層次的簡要說明：

- **View 層**：負責處理使用者介面的顯示和使用者交互，但不處理業務邏輯。它接收使用者輸入，並將其傳遞給 ViewModel 層進行處理。

- **ViewModel 層**：作為 View 層和 UseCase 層之間的中介，負責處理使用者輸入並調用相應的 UseCase 來執行業務邏輯。它還負責管理視圖的狀態和數據，以便在不同的 View 層之間共享數據。

- **UseCase 層**：包含應用程式的業務邏輯，負責執行特定的用例或操作。它接收來自 ViewModel 層的請求，並使用 Repository 層提供的數據來完成相應的任務。

- **Repository 層**：用於管理數據的獲取和存儲，負責與數據源（例如數據庫、網絡等）進行交互，並向 UseCase 層提供數據。

- **Service 層**：可選的服務層，用於封裝與外部服務的交互，例如與第三方 API 的通信等。

通過將應用程式分解為這些獨立的層次，我們可以實現更清晰、更易於理解和維護的程式碼結構，同時也更方便進行單元測試和程式碼重用。

## AI 模組

在這個專案中，AI 模組扮演著相當重要的角色，其功能包括：

- 基礎程式碼輔助：AI 模組協助完成了一些基礎程式碼的撰寫，例如實現 UICollectionViewDataSource 和添加 NotificationCenter.default.addObserver 等操作。

- 邏輯優化：AI 模組對程式碼邏輯進行了優化，例如對於 PokemonEvolutionChain.collectSpecies() 方法進行了優化。

- 文件確認：AI 模組還負責確認文件的功能，以確保專案文件的完整性和準確性。

- 未來計畫：此外，AI 模組還計畫在未來用於補全單元測試，以提高程式碼的品質和穩定性。

~~撰寫這個 README.md大綱~~
