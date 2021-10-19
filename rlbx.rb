class Rlbx
  PROG="tlbx".freeze
  LABEL="com.github.yilkalargaw.rlbx".freeze # label to identify it from other images
  LL="--log-level=error".freeze # do i need logs
  IMG="docker.io/library/alpine:latest".freeze #default image

  def self.list
    list_command = "podman \"#{LL}\" ps -af label=\"#{LABEL}=true\" \
			--format \"{{.ID}}	{{.Names}}	{{.Created}}	{{.Image}}	{{.Status}}\""
    `#{list_command}`
  end
end
