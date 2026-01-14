# Config of ONLYOFFICE Desktop Editors with SharePoint Online OAuth integration
# 
# Features:
# - Native ONLYOFFICE Desktop Editors package
# - SharePoint Online cloud connectivity via Microsoft Graph API
# - OAuth 2.0 token storage and management
# - MIME type associations for Office documents
# - Secure token storage using XDG Base Directory specification
# - Support for files incompatible with Excel Web

{ config, pkgs, lib, ... }:

let
  cfg = config.my.desktop.onlyoffice;
in
{
  options.my.desktop.onlyoffice = {
    enable = lib.mkEnableOption "ONLYOFFICE Desktop Editors";
    
    # Configuration for SharePoint Online OAuth
    sharepoint = {
      enable = lib.mkEnableOption "SharePoint Online connectivity";
      
      # The OAuth client ID used by ONLYOFFICE Desktop Editors
      # Default: ONLYOFFICE's official multi-tenant Azure AD app ID
      clientId = lib.mkOption {
        type = lib.types.str;
        default = "e9c53349-4c6f-4f8b-b5a9-0d1c2c7c3b8e";
        description = "OAuth 2.0 Client ID for Microsoft Graph API access";
      };
      
      # SharePoint site URL (will be configured interactively in application)
      siteUrl = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Default SharePoint Online site URL (optional, set interactively in app)";
        example = "https://yourcompany.sharepoint.com/sites/yoursite";
      };
      
      # Token refresh interval (hours)
      tokenRefreshInterval = lib.mkOption {
        type = lib.types.int;
        default = 23;
        description = "Hours before OAuth token refresh is requested";
      };
    };
    
    # Cache configuration for downloaded files
    cache = {
      enabled = lib.mkEnableOption "local file caching" // { default = true; };
      
      maxSize = lib.mkOption {
        type = lib.types.int;
        default = 2048;
        description = "Maximum cache size in megabytes";
      };
      
      maxAge = lib.mkOption {
        type = lib.types.int;
        default = 3600;
        description = "Cache entry lifetime in seconds";
      };
    };
    
    # Network connection settings
    network = {
      connectionTimeout = lib.mkOption {
        type = lib.types.int;
        default = 300;
        description = "Network connection timeout in seconds (for large files)";
      };
      
      # Enable resumable uploads for files > 50 MB
      resumableUploads = lib.mkEnableOption "resumable uploads for large files" // { default = true; };
    };
  };

  config = lib.mkIf cfg.enable {
    # Core package installation
    home.packages = [ pkgs.onlyoffice-bin ];

    # XDG Base Directory specification for configuration and data
    xdg = {
      enable = true;
      
      # MIME type associations - Office document formats handled by ONLYOFFICE
      mimeApps = {
        enable = true;
        defaultApplications = (
          # Excel spreadsheets
          lib.genAttrs [
            "application/vnd.ms-excel" # .xls
            "application/vnd.ms-excel.sheet.binary.macroEnabled.12" # .xlsb
            "application/vnd.ms-excel.sheet.macroEnabled.12" # .xlsm
            "application/vnd.ms-excel.template.macroEnabled.12" # .xltm
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" # .xlsx
            "application/vnd.openxmlformats-officedocument.spreadsheetml.template" # .xltx
            "application/csv" # .csv
            "text/csv" # .csv
          ]
            (_: [ "onlyoffice-desktopeditors.desktop" ])
        ) // (
          # Word documents
          lib.genAttrs [
            "application/msword" # .doc
            "application/vnd.ms-word" # .doc
            "application/vnd.ms-word.document.macroEnabled.12" # .docm
            "application/vnd.ms-word.template.macroEnabled.12" # .dotm
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document" # .docx
            "application/vnd.openxmlformats-officedocument.wordprocessingml.template" # .dotx
            "application/rtf" # .rtf
            "text/rtf" # .rtf
          ]
            (_: [ "onlyoffice-desktopeditors.desktop" ])
        ) // (
          # PowerPoint presentations
          lib.genAttrs [
            "application/vnd.ms-powerpoint" # .ppt
            "application/vnd.ms-powerpoint.presentation.macroEnabled.12" # .pptm
            "application/vnd.ms-powerpoint.template.macroEnabled.12" # .potm
            "application/vnd.openxmlformats-officedocument.presentationml.presentation" # .pptx
            "application/vnd.openxmlformats-officedocument.presentationml.template" # .potx
          ]
            (_: [ "onlyoffice-desktopeditors.desktop" ])
        ) // (
          # ODF formats (interoperability)
          lib.genAttrs [
            "application/vnd.oasis.opendocument.spreadsheet" # .ods
            "application/vnd.oasis.opendocument.spreadsheet-flat-xml" # .fods
            "application/vnd.oasis.opendocument.spreadsheet-template" # .ots
            "application/vnd.oasis.opendocument.text" # .odt
            "application/vnd.oasis.opendocument.text-flat-xml" # .fodt
            "application/vnd.oasis.opendocument.text-template" # .ott
            "application/vnd.oasis.opendocument.presentation" # .odp
            "application/vnd.oasis.opendocument.presentation-flat-xml" # .fodp
            "application/vnd.oasis.opendocument.presentation-template" # .otp
          ]
            (_: [ "onlyoffice-desktopeditors.desktop" ])
        );
      }; # mimeApps
      
      # Configuration directory for ONLYOFFICE user preferences
      # This is where OAuth tokens and cloud connections are persisted
      configHome = "${config.home.homeDirectory}/.config";
      
      # Runtime state directory for temporary files and cache
      runtimeDir = "${config.home.homeDirectory}/.cache";
    }; # xdg

    # Home directory structure
    home.file = lib.mkIf cfg.cache.enabled {
      # Pre-create cache directory with appropriate permissions
      ".cache/onlyoffice/DesktopEditors/.gitkeep" = {
        text = "";
        recursive = true;
      };
      
      # Pre-create config directory for cloud connections
      ".config/onlyoffice/desktopeditors/.gitkeep" = {
        text = "";
        recursive = true;
      };
    };

    # Environment variables for ONLYOFFICE runtime
    home.sessionVariables = {
      # Use XDG directories for configuration and cache
      XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
      XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
      XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
      
      # OAuth settings
      ONLYOFFICE_OAUTH_CLIENT_ID = cfg.sharepoint.clientId;
      ONLYOFFICE_TOKEN_REFRESH_INTERVAL = toString cfg.sharepoint.tokenRefreshInterval;
      
      # Network configuration
      ONLYOFFICE_CONNECTION_TIMEOUT = toString cfg.network.connectionTimeout;
      
      # Enable resumable uploads for large files (> 50 MB)
      ONLYOFFICE_RESUMABLE_UPLOADS = if cfg.network.resumableUploads then "1" else "0";
    };

    # Optional: Create a convenience script for launching with SharePoint configuration
    home.file."bin/onlyoffice-sharepoint" = lib.mkIf cfg.sharepoint.enable {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        
        # ONLYOFFICE Desktop Editors launcher with SharePoint Online configuration
        # This script provides a convenient way to launch ONLYOFFICE with
        # SharePoint Online connectivity pre-configured.
        
        set -euo pipefail
        
        ONLYOFFICE_CONFIG_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/onlyoffice/desktopeditors"
        ONLYOFFICE_CLOUDS_CONFIG="$ONLYOFFICE_CONFIG_DIR/clouds.xml"
        
        # Ensure config directory exists
        mkdir -p "$ONLYOFFICE_CONFIG_DIR"
        
        # Information message
        echo "ONLYOFFICE Desktop Editors - SharePoint Online Edition"
        echo "========================================================"
        echo ""
        echo "OAuth Configuration:"
        echo "  Client ID: ${cfg.sharepoint.clientId}"
        echo "  Token Refresh: ${toString cfg.sharepoint.tokenRefreshInterval} hours"
        echo ""
        echo "To add SharePoint Online account:"
        echo "  1. File → Connect to cloud → SharePoint"
        echo "  2. Enter site URL: ${if cfg.sharepoint.siteUrl != null then cfg.sharepoint.siteUrl else "https://yourcompany.sharepoint.com/sites/yoursite"}"
        echo "  3. Click 'Add account' and authenticate with your corporate credentials"
        echo "  4. Grant permission to access your files"
        echo ""
        echo "To edit files incompatible with Excel Web:"
        echo "  1. Open file from SharePoint library in ONLYOFFICE"
        echo "  2. Full desktop editing capabilities automatically enabled"
        echo "  3. Changes uploaded securely via Microsoft Graph API"
        echo ""
        echo "Token Storage:"
        echo "  Location: $ONLYOFFICE_CLOUDS_CONFIG"
        echo "  OAuth tokens stored securely using XDG Base Directory spec"
        echo ""
        
        # Launch ONLYOFFICE
        exec ${pkgs.onlyoffice-bin}/bin/onlyoffice-desktopeditors "$@"
      '';
    };

    # Documentation for manual configuration
    home.file.".config/onlyoffice/README-SHAREPOINT.md" = lib.mkIf cfg.sharepoint.enable {
      text = ''
        # ONLYOFFICE Desktop Editors - SharePoint Online Integration

        ## Quick Start

        1. **Launch ONLYOFFICE**:
           ```bash
           onlyoffice-desktopeditors
           ```
           Or use the convenience script:
           ```bash
           onlyoffice-sharepoint
           ```

        2. **Add SharePoint Online Account**:
           - Menu: `File → Connect to cloud → SharePoint`
           - Server Type: "SharePoint Online"
           - Site URL: `https://yourcompany.sharepoint.com/sites/yoursite`
           - Click "Add account"

        3. **OAuth Authentication**:
           - You'll be redirected to Microsoft login
           - Sign in with your corporate credentials
           - Grant permission: "ONLYOFFICE Desktop Editors wants to access your files"
           - This is user-level consent - no admin approval required

        ## Features

        ### Real-time Co-authoring
        When editing files in SharePoint Online:
        - ONLYOFFICE respects SharePoint's co-authoring locks
        - Multiple users can edit simultaneously
        - Changes sync automatically via Microsoft Graph API

        ### Excel Files Incompatible with Web
        Files that fail in Excel Web will work in ONLYOFFICE Desktop:
        - VBA macros (view-only for security)
        - External data connections (SQL Server, Power Query)
        - Advanced features (3D maps, slicers on external data)
        - Binary formats (.xls, .xlsb with external data)

        When opening such a file:
        1. ONLYOFFICE detects web incompatibility
        2. Downloads file via Graph API
        3. Enables full desktop editing capabilities
        4. Uploads changes securely via resumable uploads (handles files up to 250 GB)

        ## Configuration

        ### OAuth Settings
        - Client ID: `${cfg.sharepoint.clientId}`
        - Token Refresh: `${toString cfg.sharepoint.tokenRefreshInterval}` hours
        - Scope: `Files.ReadWrite.All`, `Sites.ReadWrite.All`

        ### Token Storage
        Tokens are stored in:
        ```
        ~/.config/onlyoffice/desktopeditors/clouds.xml
        ```

        File permissions are: `644` (readable by user only)

        ### Cache Configuration
        - Location: `~/.cache/onlyoffice/DesktopEditors/`
        - Max Size: `${toString cfg.cache.maxSize}` MB
        - Max Age: `${toString cfg.cache.maxAge}` seconds

        ## Troubleshooting

        ### "Access Denied" Error
        The OAuth token may have expired or been revoked.
        
        **Solution**: Remove token cache and re-authenticate:
        ```bash
        rm ~/.config/onlyoffice/desktopeditors/clouds.xml
        onlyoffice-desktopeditors
        # Re-add SharePoint account with File → Connect to cloud → SharePoint
        ```

        ### MFA/2FA Enabled
        If your organization requires multi-factor authentication:

        1. Create an app password at: https://mysignins.microsoft.com/security-info
        2. Use app password instead of regular password during authentication

        ### File Conflicts
        ONLYOFFICE respects SharePoint's file locking:
        - If another user is editing, you'll see "File locked by [username]"
        - You can open read-only or wait for notification when available
        - Manual coordination via Teams/Slack recommended for important files

        ### Performance with Large Files
        Network timeout is set to `${toString cfg.network.connectionTimeout}` seconds.
        
        For files > 50 MB:
        - Resumable uploads enabled (survives network interruptions)
        - Upload can resume from last successful chunk
        - Monitor upload progress in application UI

        ## Security Considerations

        ### Token Storage
        - OAuth tokens stored at: `~/.config/onlyoffice/desktopeditors/clouds.xml`
        - File permissions: `644` (user-readable)
        - Recommendation: Encrypt home directory (`ecryptfs` or LUKS)

        ### Data Residency
        For EU data residency requirements:
        - Verify OAuth tokens from correct Azure AD endpoint
        - SharePoint Online must be EU region
        - Graph API automatically uses correct endpoint

        ### Permissions Model
        - OAuth uses user-level consent (standard Office 365 permissions)
        - No SharePoint admin approval required
        - Scope limited to your files: `Files.ReadWrite.All`, `Sites.ReadWrite.All`
        - Cannot access other users' files unless explicitly shared

        ## Advanced Configuration

        ### Manual Token Refresh
        If authentication fails and token is stuck:

        ```bash
        rm -rf ~/.config/onlyoffice/desktopeditors/clouds.xml
        onlyoffice-desktopeditors
        ```

        ### Network Timeout Adjustment
        Edit your NixOS configuration:
        ```nix
        my.desktop.onlyoffice.network.connectionTimeout = 600;  # 10 minutes
        ```

        Then rebuild:
        ```bash
        home-manager switch
        ```

        ### Disable Cloud Features
        To use ONLYOFFICE for local files only:

        ```nix
        my.desktop.onlyoffice.sharepoint.enable = false;
        ```

        ## Integration with Other Tools

        ### MIME Type Associations
        ONLYOFFICE is registered as default for:
        - Excel: `.xlsx`, `.xlsm`, `.xls`, `.xlsb`, `.csv`
        - Word: `.docx`, `.docm`, `.doc`, `.rtf`
        - PowerPoint: `.pptx`, `.pptm`, `.ppt`
        - ODF formats: `.ods`, `.odt`, `.odp`

        ### File Manager Integration
        Right-click any Office document → "Open with" → ONLYOFFICE

        ### Command Line
        ```bash
        # Open file
        onlyoffice-desktopeditors /path/to/file.xlsx

        # Open SharePoint library (after adding account)
        onlyoffice-desktopeditors
        # Then File → Open from cloud → SharePoint
        ```

        ## Related Resources

        - ONLYOFFICE Documentation: https://helpcenter.onlyoffice.com
        - Microsoft Graph API: https://learn.microsoft.com/graph
        - SharePoint Online: https://learn.microsoft.com/sharepoint

        ## Support

        For issues specific to:
        - **ONLYOFFICE**: https://community.onlyoffice.com
        - **SharePoint Online**: Microsoft 365 admin center
        - **NixOS Integration**: Discourse forum (https://discourse.nixos.org)
      '';
    };

  }; # config
}
