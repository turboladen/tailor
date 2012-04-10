def report_turducken(results, performance_results)
  stuffing[:log_files] = { "#{File.basename @logger.log_file_location}" =>
    File.read(@logger.log_file_location).gsub(/(?<f><)(?<q>\/)?(?<w>\w)/,
      '\k<f>!\k<q>\k<w>') }.merge remote_logs

  begin
    Stuffer.login(@config[:turducken_server], @config[:turducken_username],
      @config[:turducken_password])
    suite_result_url = Stuffer.stuff(stuffing)
  rescue Errno::ECONNREFUSED
    @logger.error "Unable to connect to Turducken server!"
  end

  suite_result_url
end
