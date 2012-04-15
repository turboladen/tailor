begin
  ssh.upload source, dest
  @logger.info "Successfully copied the file #{source} to " +
    "#{@config[:scp_hostname]}:#{dest}."
rescue SocketError, ArgumentError, SystemCallError,
  Net::SCP::Exception, Timeout::Error => ex
  @logger.error "Failed to copy the file #{source} to #{dest} due to " +
    "#{ex.message}"
end
