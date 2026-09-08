import Foundation
import SwiftUI

// MARK: - Languages

enum FFLanguage: String, CaseIterable, Identifiable {
    static let storageKey = "ffLanguage"

    case english      = "en"
    case indonesian   = "id"
    case brazilian    = "pt-BR"
    case vietnamese   = "vi"
    case taiwanese    = "zh-TW"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english:    return "English"
        case .indonesian: return "Indonesia"
        case .brazilian:  return "Português (BR)"
        case .vietnamese: return "Tiếng Việt"
        case .taiwanese:  return "繁體中文"
        }
    }

    var flagEmoji: String {
        switch self {
        case .english:    return "🇺🇸"
        case .indonesian: return "🇮🇩"
        case .brazilian:  return "🇧🇷"
        case .vietnamese: return "🇻🇳"
        case .taiwanese:  return "🇹🇼"
        }
    }

    // MARK: - String table

    func t(_ key: String) -> String {
        strings[key] ?? key
    }

    private var strings: [String: String] {
        switch self {
        case .english:
            return [
                "select_language": "Select Language",
                "continue": "Continue",
                "login_title": "FF External",
                "login_subtitle": "Enter your license key to continue",
                "key_placeholder": "FFEX-XXXX-XXXX-XXXX",
                "validate": "Validate",
                "validating": "Validating...",
                "key_invalid": "Invalid or expired key",
                "key_valid": "Access granted",
                "device": "Device",
                "expires": "Expires",
                "key_label": "License Key",
                "menu_ff": "Free Fire",
                "menu_ffmax": "Free Fire Max",
                "inject": "Inject Cheat",
                "restore": "Restore Default",
                "injecting": "Injecting...",
                "inject_success": "Inject Success",
                "inject_hint": "Inject features while in lobby and turn off when entering in-game",
                "unavailable": "Unavailable",
                "telegram": "Join Telegram for Updates",
                "aimBody": "AimBody",
                "aimNeck": "AimNeck",
                "aimDrag": "AimDrag",
                "magicBullet": "Magic Bullet",
                "antena": "Antena",
                "hologram": "Hologram",
                "restore_success": "Files Restored",
                "already_injected": "Already Injected",
                "tab_ff": "Free Fire",
                "tab_ffmax": "FF Max",
                "loading_github": "Fetching cheat files...",
            ]
        case .indonesian:
            return [
                "select_language": "Pilih Bahasa",
                "continue": "Lanjutkan",
                "login_title": "FF External",
                "login_subtitle": "Masukkan kunci lisensi Anda untuk melanjutkan",
                "key_placeholder": "FFEX-XXXX-XXXX-XXXX",
                "validate": "Validasi",
                "validating": "Memvalidasi...",
                "key_invalid": "Kunci tidak valid atau kedaluwarsa",
                "key_valid": "Akses diberikan",
                "device": "Perangkat",
                "expires": "Kedaluwarsa",
                "key_label": "Kunci Lisensi",
                "menu_ff": "Free Fire",
                "menu_ffmax": "Free Fire Max",
                "inject": "Inject Cheat",
                "restore": "Pulihkan Default",
                "injecting": "Menginjeksi...",
                "inject_success": "Inject Berhasil",
                "inject_hint": "Inject fitur ketika di lobby dan off ketika dah masuk ingame",
                "unavailable": "Tidak Tersedia",
                "telegram": "Bergabung Telegram untuk Update",
                "aimBody": "AimBody",
                "aimNeck": "AimNeck",
                "aimDrag": "AimDrag",
                "magicBullet": "Magic Bullet",
                "antena": "Antena",
                "hologram": "Hologram",
                "restore_success": "File Dipulihkan",
                "already_injected": "Sudah Diinjeksi",
                "tab_ff": "Free Fire",
                "tab_ffmax": "FF Max",
                "loading_github": "Mengambil file cheat...",
            ]
        case .brazilian:
            return [
                "select_language": "Selecionar Idioma",
                "continue": "Continuar",
                "login_title": "FF External",
                "login_subtitle": "Digite sua chave de licença para continuar",
                "key_placeholder": "FFEX-XXXX-XXXX-XXXX",
                "validate": "Validar",
                "validating": "Validando...",
                "key_invalid": "Chave inválida ou expirada",
                "key_valid": "Acesso concedido",
                "device": "Dispositivo",
                "expires": "Expira em",
                "key_label": "Chave de Licença",
                "menu_ff": "Free Fire",
                "menu_ffmax": "Free Fire Max",
                "inject": "Injetar Cheat",
                "restore": "Restaurar Padrão",
                "injecting": "Injetando...",
                "inject_success": "Injeção Concluída",
                "inject_hint": "Injete funções no lobby e desligue ao entrar no jogo",
                "unavailable": "Indisponível",
                "telegram": "Entre no Telegram para Atualizações",
                "aimBody": "AimBody",
                "aimNeck": "AimNeck",
                "aimDrag": "AimDrag",
                "magicBullet": "Magic Bullet",
                "antena": "Antena",
                "hologram": "Hologram",
                "restore_success": "Arquivos Restaurados",
                "already_injected": "Já Injetado",
                "tab_ff": "Free Fire",
                "tab_ffmax": "FF Max",
                "loading_github": "Buscando arquivos de cheat...",
            ]
        case .vietnamese:
            return [
                "select_language": "Chọn Ngôn Ngữ",
                "continue": "Tiếp Tục",
                "login_title": "FF External",
                "login_subtitle": "Nhập khóa bản quyền để tiếp tục",
                "key_placeholder": "FFEX-XXXX-XXXX-XXXX",
                "validate": "Xác Nhận",
                "validating": "Đang xác nhận...",
                "key_invalid": "Khóa không hợp lệ hoặc đã hết hạn",
                "key_valid": "Truy cập được cấp",
                "device": "Thiết bị",
                "expires": "Hết hạn",
                "key_label": "Khóa Bản Quyền",
                "menu_ff": "Free Fire",
                "menu_ffmax": "Free Fire Max",
                "inject": "Chèn Cheat",
                "restore": "Khôi Phục Mặc Định",
                "injecting": "Đang chèn...",
                "inject_success": "Chèn Thành Công",
                "inject_hint": "Chèn tính năng khi ở sảnh và tắt khi vào game",
                "unavailable": "Không Có Sẵn",
                "telegram": "Tham gia Telegram để cập nhật",
                "aimBody": "AimBody",
                "aimNeck": "AimNeck",
                "aimDrag": "AimDrag",
                "magicBullet": "Magic Bullet",
                "antena": "Antena",
                "hologram": "Hologram",
                "restore_success": "Đã Khôi Phục Tệp",
                "already_injected": "Đã Chèn Rồi",
                "tab_ff": "Free Fire",
                "tab_ffmax": "FF Max",
                "loading_github": "Đang tải file cheat...",
            ]
        case .taiwanese:
            return [
                "select_language": "選擇語言",
                "continue": "繼續",
                "login_title": "FF External",
                "login_subtitle": "輸入您的授權金鑰以繼續",
                "key_placeholder": "FFEX-XXXX-XXXX-XXXX",
                "validate": "驗證",
                "validating": "驗證中...",
                "key_invalid": "金鑰無效或已過期",
                "key_valid": "已授予訪問權限",
                "device": "裝置",
                "expires": "到期",
                "key_label": "授權金鑰",
                "menu_ff": "Free Fire",
                "menu_ffmax": "Free Fire Max",
                "inject": "注入外掛",
                "restore": "還原預設",
                "injecting": "注入中...",
                "inject_success": "注入成功",
                "inject_hint": "在大廳注入功能，進入遊戲後關閉",
                "unavailable": "不可用",
                "telegram": "加入 Telegram 獲取更新",
                "aimBody": "AimBody",
                "aimNeck": "AimNeck",
                "aimDrag": "AimDrag",
                "magicBullet": "Magic Bullet",
                "antena": "Antena",
                "hologram": "Hologram",
                "restore_success": "檔案已還原",
                "already_injected": "已注入",
                "tab_ff": "Free Fire",
                "tab_ffmax": "FF Max",
                "loading_github": "正在獲取外掛檔案...",
            ]
        }
    }
}

// MARK: - Environment Key

private struct FFLanguageKey: EnvironmentKey {
    static let defaultValue = FFLanguage.english
}

extension EnvironmentValues {
    var ffLanguage: FFLanguage {
        get { self[FFLanguageKey.self] }
        set { self[FFLanguageKey.self] = newValue }
    }
}
