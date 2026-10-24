(function () {
  var groups = {
    package: {
      version: "0.1.4",
      base: "https://github.com/thrustlang/torio/releases/download/",
      platforms: {
        windows: {
          tag: "torio-x86_64-windows-msvc-v{version}",
          file: "torio.exe",
          altFile: "torio-stripped.exe"
        },
        linux: {
          tag: "torio-x86_64-linux-ubuntu-v{version}",
          file: "torio",
          altFile: "torio-stripped"
        },
        macos_intel: {
          tag: "torio-x86_64-macos-v{version}",
          file: "torio",
          altFile: "torio-stripped"
        },
        macos_arm: {
          tag: "torio-aarch64-macos-v{version}",
          file: "torio",
          altFile: "torio-stripped"
        }
      }
    },
    compiler: {
      version: "0.2.4",
      base: "https://github.com/thrustlang/thrustc/releases/download/",
      platforms: {
        windows: {
          version: "0.2.4",
          tag: "thrustc-x86_64-windows-msvc-v{version}",
          file: "thrustc.exe",
          altFile: "thrustc-stripped.exe"
        },
        linux: {
          version: "0.2.4",
          tag: "thrustc-x86_64-linux-ubuntu-v{version}",
          file: "thrustc",
          altFile: "thrustc-stripped"
        },
        macos_intel: {
          version: "0.2.4",
          tag: "thrustc-x86_64-macos-v{version}",
          file: "thrustc",
          altFile: "thrustc-stripped"
        },
        macos_arm: {
          version: "0.2.4",
          tag: "thrustc-aarch64-macos-v{version}",
          file: "thrustc",
          altFile: "thrustc-stripped"
        }
      }
    }
  };

  function fill(template, version) {
    return template.replace("{version}", version);
  }

  function versionFor(group, key) {
    var item = group.platforms[key];

    return (item && item.version) || group.version;
  }

  function releaseUrl(group, item, version, filename) {
    return group.base + fill(item.tag, version) + "/" + filename;
  }

  Object.keys(groups).forEach(function (groupKey) {
    var group = groups[groupKey];

    Object.keys(group.platforms).forEach(function (key) {
      var item = group.platforms[key];
      var version = versionFor(group, key);
      var primary = document.querySelector(
        '[data-group="' + groupKey + '"][data-download="' + key + '"]'
      );
      var secondary = document.querySelector(
        '[data-group="' + groupKey + '"][data-download-alt="' + key + '"]'
      );
      var versionNode = document.querySelector(
        '[data-group="' + groupKey + '"][data-version="' + key + '"]'
      );

      if (primary) {
        primary.href = releaseUrl(group, item, version, item.file);
      }

      if (secondary) {
        secondary.href = releaseUrl(group, item, version, item.altFile);
      }

      if (versionNode) {
        versionNode.textContent = "v" + version;
      }
    });
  });
})();
