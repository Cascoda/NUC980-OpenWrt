![OpenWrt logo](include/logo.png)

OpenWrt Project is a Linux operating system targeting embedded devices. Instead
of trying to create a single, static firmware, OpenWrt provides a fully
writable filesystem with package management. This frees you from the
application selection and configuration provided by the vendor and allows you
to customize the device through the use of packages to suit any application.
For developers, OpenWrt is the framework to build an application without having
to build a complete firmware around it; for users this means the ability for
full customization, to use the device in ways never envisioned.

This fork of OpenWRT is used as the build system for Cascoda's KNX-IoT Hub
images. The changes to OpenWRT itself & associated are quite minimal - this
is mostly for the convenience of building & releasing images

## Development

To build your own firmware you need a GNU/Linux, BSD or MacOSX system (case
sensitive filesystem required). Cygwin is unsupported because of the lack of a
case sensitive file system.

### Requirements

You need the following tools to compile OpenWrt, the package names vary between
distributions. A complete list with distribution specific packages is found in
the [Build System Setup](https://openwrt.org/docs/guide-developer/build-system/install-buildsystem)
documentation.

```
binutils bzip2 diff find flex gawk gcc-6+ getopt grep install libc-dev libz-dev
make4.1+ perl python3.6+ rsync subversion unzip which
```

### Cascoda-specific requirements

To build the KNX-IoT hub firmware you will need access to several feeds. Please
modify feeds.conf.default to point to the absolute path of the respective cloned
repositories. Unfortunately relative paths do not work.
- openthread - this is Cascoda's fork of the ot-br-posix repository. This is the
  border router firmware and web gui, modified to work with Cascoda's Chili2D/2S 
  dongles and with extra features and usability improvements. This repository
  is open source.
- knxiot - points to the proprietary shared object built on top of the KNX IoT stack.
- knxiotlinker - Cascoda's proprietary KNX-IoT development tool which links points
  together based on their functional blocks (smart linking).
- knxiotproxy - Cascoda's propretary proxy from KNX-IoT to MQTT.
- knxiotubus - Cascoda's proprietary KNX-IoT backend and frontend to allow 
  configuring virtual devices on the border router using a web gui.

Note: Cascoda's logo is displayed in the header through a modification to the bootstrap
theme, in `luci-theme-bootstrap/luasrc/view/themes/bootstrap/header.htm`. This is not
yet in source control - sorry about that!

Here is the patch for said modification:

```patch
diff --git a/themes/luci-theme-bootstrap/luasrc/view/themes/bootstrap/header.htm b/themes/luci-theme-bootstrap/luasrc/view/themes/bootstrap/header.htm
index 37d18a2f07..05d788e1d2 100644
--- a/themes/luci-theme-bootstrap/luasrc/view/themes/bootstrap/header.htm
+++ b/themes/luci-theme-bootstrap/luasrc/view/themes/bootstrap/header.htm
@@ -58,6 +58,7 @@
        <body class="lang_<%=luci.i18n.context.lang%> <% if node then %><%= striptags( node.title ) %><%- end %>" data-page="<%= pcdata(table.concat(disp.context.requestpath, "-")) %>">
                <% if not blank_page then %>
                <header>
+                       <a href="/"><img src="/luci-static/bootstrap/cascoda_logo.png" height=40 style="padding-right: 10px;"></a>
                        <a class="brand" href="/"><%=striptags(boardinfo.hostname or "?")%></a>
                        <ul class="nav" id="topmenu" style="display:none"></ul>
                        <div id="indicators" class="pull-right"></div>
```

### Quickstart

1. Run `./scripts/feeds update -a` to obtain all the latest package definitions
   defined in feeds.conf / feeds.conf.default

2. Run `./scripts/feeds install -a` to install symlinks for all obtained
   packages into package/feeds/

3. Run `make menuconfig` to select your preferred configuration for the
   toolchain, target system & firmware packages.

4. Run `make` to build your firmware. This will download all sources, build the
   cross-compile toolchain and then cross-compile the GNU/Linux kernel & all chosen
   applications for your target system.

### Debugging Quickstart

1. Build and install the gdbserver package into the hub.

2. Enable debug symbols, found in General Build Options. Note that there is not enough
   space to flash an entire image with debug symbols, even after stripping.

3. Flash the package you want to debug using opkg

4. Add a firewall exception for destination port 2335 if the GDB client will be coming
   from the WAN interface.

5. Attach the GDB server to the process you want to debug: ``gdbserver --attach 192.168.202.222:2335 `pidof otbr-agent` ``

6. Attach to the remote GDB from your openwrt folder: `./scripts/remote-gdb 192.168.202.222:2335 ./build_dir/target-mips_24kc_musl/openthread-br-1.0/.pkgdir/openthread-br/usr/sbin/otbr-agent`. It is important to use the binary in the package directory, as the
   one in the root has been stripped of debug information.

### Building for the Alfa Networks R36A

The R36A is the base platform onto which Cascoda's KNX IoT Hub is built. We provide
configuration files for building several types of images for this platform. These
files contain all of the information OpenWRT needs to create an image for the R36A
containing the border router firmware.

To make use of these files:
```bash
cp .config-r36a-linker .config
make
```

There are several config files available:
- `.config-r36a-linker` - this is the default KNX-IoT Hub image upon which the releases
are based. Contains the border router & the linker.
- `.config-r36a` - vanilla border router, with no linker or other Cascoda proprietary software.
- `.config-4g` - configuration for the R36A with a 4G backhaul connected via USB.

### Related Repositories

The main repository uses multiple sub-repositories to manage packages of
different categories. All packages are installed via the OpenWrt package
manager called `opkg`. If you're looking to develop the web interface or port
packages to OpenWrt, please find the fitting repository below.

* [LuCI Web Interface](https://github.com/openwrt/luci): Modern and modular
  interface to control the device via a web browser.

* [OpenWrt Packages](https://github.com/openwrt/packages): Community repository
  of ported packages.

* [OpenWrt Routing](https://github.com/openwrt/routing): Packages specifically
  focused on (mesh) routing.

* [OpenWrt Video](https://github.com/openwrt/video): Packages specifically
  focused on display servers and clients (Xorg and Wayland).

## Support Information

For a list of supported devices see the [OpenWrt Hardware Database](https://openwrt.org/supported_devices)

### Documentation

* [Quick Start Guide](https://openwrt.org/docs/guide-quick-start/start)
* [User Guide](https://openwrt.org/docs/guide-user/start)
* [Developer Documentation](https://openwrt.org/docs/guide-developer/start)
* [Technical Reference](https://openwrt.org/docs/techref/start)

### Support Community

* [Forum](https://forum.openwrt.org): For usage, projects, discussions and hardware advise.
* [Support Chat](https://webchat.oftc.net/#openwrt): Channel `#openwrt` on **oftc.net**.

### Developer Community

* [Bug Reports](https://bugs.openwrt.org): Report bugs in OpenWrt
* [Dev Mailing List](https://lists.openwrt.org/mailman/listinfo/openwrt-devel): Send patches
* [Dev Chat](https://webchat.oftc.net/#openwrt-devel): Channel `#openwrt-devel` on **oftc.net**.

## License

OpenWrt is licensed under GPL-2.0
