class Rlbx
  PROG="tlbx".freeze
  LABEL="com.github.yilkalargaw.rlbx".freeze # label to identify it from other images
  LL="--log-level=error".freeze # do i need logs
  IMG="docker.io/library/alpine:latest".freeze #default image

  def self.create(img=IMG, name=nil, hostname=nil, bindhome=true)
    bindcommand = (bindhome ? "--volume $HOME:/home/$user:rslave" : "")
    name = "#{IMG.split('/').last.split(':').first}-#{PROG}" if (name.nil? || name.empty?)
    hostname = PROG.dup if (hostname.nil? || hostname.empty?)
    command = ["XDG_RUNTIME_DIR=\"${XDG_RUNTIME_DIR:-/run/user/$UID}\"", "podman #{LL} create",
               "--label \"#{LABEL}=true\" ", # remember this
               "--dns none",
               "--hostname \"#{hostname}\" ",
               "--ipc host",
               "--name \"#{name}\"",
               "--network host",
               "--no-hosts",
               "--pid host",
               "--privileged",
               "--security-opt label=disable",
               "--ulimit host",
               "--userns=keep-id",
               "--user root:root",
               "--tz=local",
               "--volume \"$XDG_RUNTIME_DIR:$XDG_RUNTIME_DIR\"",
               "#{bindcommand}",
               "--volume /run/dbus/system_bus_socket:/run/dbus/system_bus_socket",
               "--volume /etc:/run/hostetc",
               "--volume /run:/run/host/run:rslave",
               "--volume /tmp:/run/host/tmp:rslave",
               "--volume /var:/run/host/var:rslave",
               "--volume /dev:/dev:rslave",
               "--volume /mnt:/mnt:rslave",
               "--volume /media:/media:rslave",
               "--volume /srv:/srv:rslave",
               "--volume /tmp/.X11-unix:/tmp/.X11-unix",
               "$([ -d /run/media ] && echo \"--volume /run/media:/run/media:rslave\")",
               "#{IMG}", "/bin/sh",
               "\"$XDG_RUNTIME_DIR/#{PROG}-init\"",
               "\"$UID\" \"$USER\"",
              ]

    if system(command.join(" "))
      puts "Created container '#{name}' from image #{img}"
      puts "Enter with: #{PROG} enter [PODMAN_EXEC_OPTS...] #{name} CMD [ARGS...]"
    end

  end

  def self.list
    list_command = "podman \"#{LL}\" ps -af label=\"#{LABEL}=true\" \
			--format \"{{.ID}}	{{.Names}}	{{.Created}}	{{.Image}}	{{.Status}}\""
    `#{list_command}`
  end
	
  def self.rm(name)
    list_command = "podman \"#{LL}\" ps -af label=#{LABEL}=true --format \"{{.Names}}\""
    `podman rm #{name}` if `#{list_command}`.split("\n").member?(name)
    # puts `#{list_command}`.split("\n")
  end

end
