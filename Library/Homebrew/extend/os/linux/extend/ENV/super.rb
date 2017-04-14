module Superenv
  alias x11? x11

  # @private
  def self.bin
    (HOMEBREW_SHIMS_PATH/"linux/super").realpath
  end

  def homebrew_extra_paths
    paths = []
    binutils = Formula["binutils"]
    paths << binutils.opt_bin if binutils.installed?
    paths += self["xorg_formulae"].map(&:opt_bin) if x11?
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
      libs = self["xorg_formulae"].map(&:lib)
      shares = self["xorg_formulae"].map(&:share)
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
      shares = self["xorg_formulae"].map(&:share)
      shares.each do |s|
        paths << s/"aclocal"
      end
    end
    paths
  end

  def self.x11_include_paths
    self["xorg_formulae"].map(&:include).map(&:to_s)
  end

  def self.x11_lib_paths
    self["xorg_formulae"].map(&:lib).map(&:to_s)
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
    xorg = Formula["linuxbrew/xorg/xorg"]
    if xorg.installed?
      self["xorg_formulae"] = xorg.recursive_dependencies.map(&:to_formula)
      ENV.x11 = true
    end
  rescue FormulaUnavailableError
    ENV.x11 = false
  end
end
