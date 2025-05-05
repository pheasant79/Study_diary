# 文件夹说明生成脚本
# 在C:\Users\24213下的所有文件夹中创建说明文件

# 定义文件夹说明信息的哈希表
$folderDescriptions = @{
    # 隐藏配置文件夹
    ".AivmVbox" = "[App] - Virtual machine configuration files. Keep if using VM."
    ".anaconda" = "[App] - Anaconda Python configuration for data science. Keep if using Python."
    ".android" = "[App] - Android development files. Keep if developing Android apps."
    ".arduinoIDE" = "[App] - Arduino development environment. Keep if developing for Arduino."
    ".astropy" = "[App] - Astronomy calculation library. Keep if using astronomy Python packages."
    ".bun" = "[App] - JavaScript runtime environment. Keep if doing Web development."
    ".cache" = "[Deletable] - Temporary cache files, can be safely deleted."
    ".cherrystudio" = "[App] - Cherry Studio configuration. Keep if using this software."
    ".conda" = "[App] - Conda environment manager. Keep if using Python."
    ".config" = "[App] - Various application config files. Generally should keep."
    ".continuum" = "[App] - Anaconda related files. Keep if using Anaconda."
    ".crossnote" = "[App] - Markdown editor config. Keep if using this editor."
    ".cursor" = "[App] - Cursor editor configuration. Keep if using Cursor."
    ".docker" = "[App] - Docker container config. Keep if using Docker development."
    ".dotnet" = "[App] - .NET development environment. Keep if developing .NET apps."
    ".EasyOCR" = "[App] - OCR recognition library. Keep if using image text recognition."
    ".eclipse" = "[App] - Eclipse IDE configuration. Keep if developing Java."
    ".i18nupdatemod" = "[App] - Internationalization module. Keep if localizing software."
    ".idlerc" = "[App] - Python IDLE configuration. Keep if using Python IDLE."
    ".ipynb_checkpoints" = "[Deletable] - Jupyter Notebook temporary files. Safe to delete."
    ".ipython" = "[App] - IPython configuration. Keep if using IPython."
    ".jupyter" = "[App] - Jupyter Notebook configuration. Keep if doing data science."
    ".keras" = "[App] - Keras deep learning library configuration. Keep if developing ML models."
    ".leigod" = "[App] - Leigod accelerator configuration. Keep if using this accelerator."
    ".lmstudio" = "[App] - LM Studio LLM tool configuration. Keep if using LLM."
    ".local" = "[App] - Linux compatibility layer. Keep if using WSL development."
    ".matplotlib" = "[App] - Matplotlib plotting library. Keep if doing data visualization."
    ".MUMUVMM" = "[App] - NetEase MuMu emulator configuration. Keep if using Android emulator."
    ".ollama" = "[App] - Ollama LLM tool configuration. Keep if using local LLMs."
    ".openjfx" = "[App] - JavaFX configuration. Keep if developing Java GUI."
    ".platformio" = "[App] - PlatformIO embedded dev tool. Keep if doing embedded development."
    ".ssh" = "[Important] - SSH keys and configuration. Contains authentication info, should backup and keep."
    ".stm32cubeide" = "[App] - STM32 IDE configuration. Keep if developing for STM32."
    ".stm32cubemx" = "[App] - STM32 CubeMX configuration. Keep if developing for STM32."
    ".stmcube" = "[App] - STM32 related tools. Keep if developing for STM32."
    ".stmcufinder" = "[App] - STM32 chip finder tool. Keep if developing for STM32."
    ".thumbnails" = "[Deletable] - Thumbnail cache. Safe to delete."
    ".vscode" = "[App] - VS Code configuration. Keep if using VS Code."
    ".webclipse" = "[App] - Eclipse Web plugin configuration. Keep if doing Web development."
    
    # 常规用户文件夹
    "-p" = "[User] - Possible project folder. Check contents before deciding."
    "ansel" = "[App] - NVIDIA Ansel game screenshot tool. Keep if using game screenshot feature."
    "AppData" = "[Mixed] - Application data folder with important configs and removable cache. Don't delete entirely."
    "Application Data" = "[System Link] - Symlink to AppData\Roaming. Don't delete."
    "Autodesk" = "[App] - Autodesk software data. Keep if using Autodesk software."
    "Contacts" = "[System] - Contact data. Usually empty. Safe to keep."
    "Cookies" = "[System Link] - Browser cookies link. Don't delete."
    "Desktop" = "[User] - Desktop folder containing files shown on desktop. Organize as needed."
    "Documents" = "[User] - Document folder with important user files. Keep but organize contents."
    "Downloads" = "[User] - Downloaded files. Clean unwanted downloads regularly."
    "etc" = "[App] - Unix-like config files. Keep if using WSL or Git."
    "Favorites" = "[System] - Browser favorites. Clean contents as needed but keep folder."
    "IdeaProjects" = "[User] - IntelliJ IDEA projects. Contains Java project code. Keep valuable projects."
    "InstallAnywhere" = "[App] - Installer configuration. Delete if no longer needed."
    "Links" = "[System] - Windows link data. Don't delete."
    "Local Settings" = "[System Link] - Symlink to AppData\Local. Don't delete."
    "Logs" = "[Deletable] - Log files. Safe to delete."
    "Music" = "[User] - Music folder for audio files. Organize as needed."
    "My Documents" = "[System Link] - Symlink to Documents. Don't delete."
    "NetHood" = "[System] - Network shortcuts folder. Don't delete."
    "OneDrive" = "[User] - OneDrive cloud storage files. Evaluate content before decision."
    "Pictures" = "[User] - Picture folder for image files. Organize as needed."
    "PrintHood" = "[System] - Printer shortcuts folder. Don't delete."
    "PSAppDeployToolkit" = "[App] - PowerShell application deployment tool. Delete if not using."
    "Recent" = "[System] - Recent file shortcuts. Don't delete folder but can clean contents."
    "Saved Games" = "[User] - Game save files. Backup before deleting."
    "Searches" = "[System] - Windows search folder. Don't delete."
    "SendTo" = "[System] - Right-click Send To menu items. Don't delete."
    "source" = "[User] - Source code files. Evaluate content before deciding."
    "STM32Cube" = "[App] - STM32 development tool data. Keep if developing embedded systems."
    "STMicroelectronics" = "[App] - STM32 related configuration. Keep if developing embedded systems."
    "Templates" = "[System] - Template folder. Don't delete."
    "Videos" = "[User] - Video folder for video files. Organize as needed."
    "Zotero" = "[App] - Zotero reference management software data. Keep if using Zotero."
    
    # AppData子文件夹
    "AppData\Local" = "[Mixed] - Local application data with removable cache and important configs. Selectively clean."
    "AppData\LocalLow" = "[App] - Low privileges application data. Generally don't delete entirely."
    "AppData\Roaming" = "[App] - Roaming application data (syncs between logins). Contains important configs."
    "AppData\Local\Temp" = "[Deletable] - Temporary files. Safe to delete all."
    "AppData\Local\Microsoft" = "[System] - Microsoft application configs. Don't delete."
    "AppData\Local\NVIDIA" = "[System] - NVIDIA driver configuration. Don't delete driver configs but can clean cache."
    "AppData\Local\Google\Chrome" = "[App] - Chrome browser data. Can clean cache but keep user configs and bookmarks."
}

# 默认说明（对于未在字典中定义的文件夹）
$defaultDescription = "[Unknown] - Unidentified folder. Please check contents manually before deciding."

# 递归函数，创建说明文件
function Create-DescriptionFiles {
    param (
        [string]$path
    )
    
    # 获取当前文件夹的所有子文件夹
    $folders = Get-ChildItem -Path $path -Directory -Force -ErrorAction SilentlyContinue
    
    foreach ($folder in $folders) {
        $folderPath = $folder.FullName
        $relativePath = $folderPath.Replace("C:\Users\24213\", "").Replace("\", "\")
        $fileName = Join-Path -Path $folderPath -ChildPath "shuoming.txt"
        
        # 确定说明内容
        $description = $defaultDescription
        
        # 检查是否有直接匹配
        if ($folderDescriptions.ContainsKey($relativePath)) {
            $description = $folderDescriptions[$relativePath]
        }
        # 检查是否有父文件夹匹配
        else {
            foreach ($key in $folderDescriptions.Keys) {
                if ($relativePath.StartsWith($key)) {
                    $description = $folderDescriptions[$key]
                    break
                }
            }
            
            # 如果是AppData下特定类型的文件夹，添加自动分类
            if ($relativePath -like "AppData\Local\*" -and (-not $folderDescriptions.ContainsKey($relativePath))) {
                if ($relativePath -like "*cache*" -or $relativePath -like "*Cache*") {
                    $description = "[Deletable] - Application cache folder. Safe to delete, will be recreated if needed."
                } elseif ($relativePath -like "*temp*" -or $relativePath -like "*Temp*") {
                    $description = "[Deletable] - Temporary folder. Safe to delete, will be recreated if needed."
                } elseif ($relativePath -like "*log*" -or $relativePath -like "*Log*") {
                    $description = "[Deletable] - Log folder. Safe to delete, won't affect application functionality."
                }
            }
        }
        
        # 检查是否已存在说明文件，避免覆盖
        $descriptionContent = "Folder: $relativePath`r`nDescription: $description`r`nChecked Date: $(Get-Date -Format 'yyyy-MM-dd')"
        
        try {
            # 写入说明文件
            $descriptionContent | Out-File -FilePath $fileName -Encoding UTF8 -Force
            Write-Host "Created: $fileName"
        } catch {
            Write-Host "Creation failed: $fileName - $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # 递归处理子文件夹
        Create-DescriptionFiles -path $folderPath
    }
}

# 主执行逻辑
try {
    # 创建根目录说明
    $rootDescription = "[User] - User personal folder root directory containing personal files and application configurations."
    $rootDescriptionContent = "Folder: C:\Users\24213`r`nDescription: $rootDescription`r`nChecked Date: $(Get-Date -Format 'yyyy-MM-dd')"
    $rootDescriptionContent | Out-File -FilePath "C:\Users\24213\shuoming.txt" -Encoding UTF8 -Force
    
    # 递归创建所有子文件夹的说明
    Create-DescriptionFiles -path "C:\Users\24213"
    
    Write-Host "Complete! Description files created for all folders." -ForegroundColor Green
} catch {
    Write-Host "Error occurred: $($_.Exception.Message)" -ForegroundColor Red
} 