require "requirement"

class XorgRequirement < Requirement
  fatal true
  default_formula "x11"

  env { ENV.x11 }

  def initialize(name = "xorg", tags = [])
    @name = name
    tags.shift if tags.first =~ /(\d\.)+\d/
    super(tags)
  end

  satisfy build_env: false do
    Formula["linuxbrew/xorg/xorg"].installed?
  end
end
