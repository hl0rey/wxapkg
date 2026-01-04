package util

import (
	"os"
	"path/filepath"
	"runtime"
)

// GetDefaultWeChatAppletPath returns the default WeChat applet path for the current platform
func GetDefaultWeChatAppletPath() string {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return ""
	}

	switch runtime.GOOS {
	case "windows":
		// Windows: C:\Users\{username}\Documents\WeChat Files\Applet
		return filepath.Join(homeDir, "Documents", "WeChat Files", "Applet")
	case "darwin":
		// macOS 微信小程序路径可能有多个位置，按优先级尝试
		
		// 路径1: 新版本微信 (实际路径)
		// ~/Library/Containers/com.tencent.xinWeChat/Data/Documents/app_data/radium/Applet/packages
		appletPath1 := filepath.Join(homeDir, "Library", "Containers", "com.tencent.xinWeChat", "Data", "Documents", "app_data", "radium", "Applet", "packages")
		if info, err := os.Stat(appletPath1); err == nil && info.IsDir() {
			return appletPath1
		}
		
		// 路径2: 老版本微信
		// ~/Library/Containers/com.tencent.xinWeChat/Data/Library/Application Support/com.tencent.xinWeChat/{version}/*/Applet
		basePath := filepath.Join(homeDir, "Library", "Containers", "com.tencent.xinWeChat", "Data", "Library", "Application Support", "com.tencent.xinWeChat")
		if dirs, err := os.ReadDir(basePath); err == nil {
			for _, dir := range dirs {
				if dir.IsDir() {
					potentialPath := filepath.Join(basePath, dir.Name())
					if subDirs, err := os.ReadDir(potentialPath); err == nil {
						for _, subDir := range subDirs {
							appletPath := filepath.Join(potentialPath, subDir.Name(), "Applet")
							if info, err := os.Stat(appletPath); err == nil && info.IsDir() {
								return appletPath
							}
						}
					}
				}
			}
		}
		
		// 如果都找不到，返回最常见的路径
		return appletPath1
	case "linux":
		// Linux: Usually uses Wine or native client
		// Try Wine path first
		winePath := filepath.Join(homeDir, ".wine", "drive_c", "users", os.Getenv("USER"), "Documents", "WeChat Files", "Applet")
		if info, err := os.Stat(winePath); err == nil && info.IsDir() {
			return winePath
		}
		// Return generic path
		return filepath.Join(homeDir, "Documents", "WeChat Files", "Applet")
	default:
		return ""
	}
}

// GetExamplePath returns a platform-specific example path for documentation
func GetExamplePath() string {
	switch runtime.GOOS {
	case "windows":
		return "D:\\WeChat Files\\Applet\\wx12345678901234"
	case "darwin":
		return "~/Library/Containers/com.tencent.xinWeChat/Data/Documents/app_data/radium/Applet/packages/wx12345678901234"
	case "linux":
		return "~/.wine/drive_c/users/{username}/Documents/WeChat Files/Applet/wx12345678901234"
	default:
		return ""
	}
}

// GetPlatformName returns a human-readable platform name
func GetPlatformName() string {
	switch runtime.GOOS {
	case "windows":
		return "Windows"
	case "darwin":
		return "macOS"
	case "linux":
		return "Linux"
	default:
		return runtime.GOOS
	}
}

