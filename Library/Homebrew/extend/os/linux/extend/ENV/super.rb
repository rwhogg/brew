module Superenv
  # @private
  def self.bin
    (HOMEBREW_SHIMS_PATH/"linux/super").realpath
  end

  def homebrew_extra_paths
    paths = []
    binutils = Formula["binutils"]
    paths << binutils.opt_bin if binutils.installed?
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

  def x11
    xorg = Formula["linuxbrew/xorg/xorg"]
    if xorg.installed?
      xorg.recursive_dependencies.each do |d|
        dep_formula = d.to_formula
        append_path "PKG_CONFIG_LIBDIR", dep_formula.lib/"pkgconfig"
        append_path "PKG_CONFIG_LIBDIR", dep_formula.share/"pkgconfig"

        append "LDFLAGS", "-L#{dep_formula.lib}"
        append_path "CMAKE_PREFIX_PATH", dep_formula.prefix.to_s
        append_path "CMAKE_INCLUDE_PATH", dep_formula.include.to_s

        append "CPPFLAGS", "-I#{dep_formula.include}"

        append_path "ACLOCAL_PATH", dep_formula.share/"aclocal"
      end
    end
  rescue FormulaUnavailableError
    false
  end
end
