include $(TOPDIR)/rules.mk

PKG_NAME:=openvpn-tracker
PKG_RELEASE:=1
PKG_VERSION:=1.0.0

include $(INCLUDE_DIR)/package.mk

define Package/openvpn-tracker
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=VPN
	TITLE:=OpenVPN Server Tracking
	DEPENDS:=+lua +libubus-lua +libubox-lua +rpcd +libuci-lua
endef

define Package/openvpn-tracker/description
	Program to track OpenVPN server clients via ubus interface.
	Provides ubus methods to list connected clients and disconnect them.
endef
define Build/Compile
endef

define Package/openvpn-tracker/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/api/services
	$(INSTALL_BIN) ./files/usr/lib/lua/api/services/*.lua $(1)/usr/lib/lua/api/services/
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/openvpn-tracking $(1)/etc/init.d/openvpn-tracking
	
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./files/usr/share/rpcd/acl.d/openvpn-acl.json $(1)/usr/share/rpcd/acl.d/
	
	$(INSTALL_DIR) $(1)/usr/share/vuci/pathd
	$(INSTALL_DATA) ./files/usr/share/vuci/pathd/openvpn-path.json $(1)/usr/share/vuci/pathd/
endef

$(eval $(call BuildPackage,openvpn-tracker))
