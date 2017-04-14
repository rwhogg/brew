module Superenv
  alias x11? x11

  # @private
  def self.bin
    (HOMEBREW_SHIMS_PATH/"linux/super").realpath
  end

  def self.xorg_recursive_deps
    opoo "xorg_recursive_deps"
    if self["xorg_formulae"].nil?
      if x11_installed?
        xorg = Formula["linuxbrew/xorg/xorg"]
        self["xorg_formulae"] = xorg.recursive_dependencies
      end
    end
    self["xorg_formulae"]
  end

  def homebrew_extra_paths
    paths = []
    binutils = Formula["binutils"]
    paths << binutils.opt_bin if binutils.installed?
    paths += xorg_recursive_deps.map(&:opt_bin) if x11?
    paths
  rescue FormulaUnavailableError
    # Fix for brew tests, which uses NullLoader.
    []
  end

  def determine_rpath_paths
    paths = ["#{HOMEBREW_PREFIX}/lib"]
    paths += run_time_deps.map { |d| d.opt_lib.to_s }
    paths += homebrew_extra_library_paths
    paths.to_path_s
  end

  # @private
  def homebrew_extra_pkg_config_paths
    paths = []
    if x11?
      libs = xorg_recursive_deps.map(&:lib)
      shares = xorg_recursive_deps.map(&:share)
      libs.each do |l|
        paths << l/"pkgconfig"
      end
      shares.each do |s|
        paths << s/"pkgconfig"
      end
    end
    paths
  end

  def homebrew_extra_aclocal_paths
    paths = []
    if x11?
      shares = xorg_recursive_deps.map(&:share)
      shares.each do |s|
        paths << s/"aclocal"
      end
    end
    paths
  end

  def self.x11_include_paths
    xorg_recursive_deps.map(&:include).map(&:to_s)
  end

  def self.x11_lib_paths
    xorg_recursive_deps.map(&:lib).map(&:to_s)
  end

  def homebrew_extra_isystem_paths
    paths = []
    paths += x11_include_paths if x11?
    paths
  end

  def homebrew_extra_library_paths
    paths = []
    paths += x11_lib_paths if x11?
    paths
  end

  def homebrew_extra_cmake_include_paths
    paths = []
    paths += x11_include_paths if x11?
    paths
  end

  def homebrew_extra_cmake_library_paths
    paths = []
    paths += x11_lib_paths if x11?
    paths
  end

  def set_x11_env_if_installed
    ENV.x11 = x11_installed?
  end

  def self.x11_installed?
    xorg = Formula["linuxbrew/xorg/xorg"]
    return xorg.installed?
  rescue FormulaUnavailableError
    false
  end
end
