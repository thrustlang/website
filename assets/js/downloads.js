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
      version: "0.2.2",
      base: "https://github.com/thrustlang/thrustc/releases/download/",
      platforms: {
        windows: {
          tag: "thrustc-x86_64-windows-msvc-v{version}",
          file: "thrustc.exe",
          altFile: "thrustc-stripped.exe"
        },
        linux: {
          tag: "thrustc-x86_64-linux-ubuntu-v{version}",
          file: "thrustc",
          altFile: "thrustc-stripped"
        },
        macos_intel: {
          tag: "thrustc-x86_64-macos-v{version}",
          file: "thrustc",
          altFile: "thrustc-stripped"
        },
        macos_arm: {
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

  function releaseUrl(group, item, filename) {
    return group.base + fill(item.tag, group.version) + "/" + filename;
  }

  Object.keys(groups).forEach(function (groupKey) {
    var group = groups[groupKey];

    Object.keys(group.platforms).forEach(function (key) {
      var item = group.platforms[key];
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
        primary.href = releaseUrl(group, item, item.file);
      }

      if (secondary) {
        secondary.href = releaseUrl(group, item, item.altFile);
      }

      if (versionNode) {
        versionNode.textContent = "v" + group.version;
      }
    });
  });
})();
