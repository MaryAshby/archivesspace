class TrimWhitespaceRunner < JobRunner
  register_for_job_type('trim_whitespace_job')

  def run
    modified_records = []

    RequestContext.open(repo_id: @job.repo_id) do
      [Resource, ArchivalObject, Accession, DigitalObject, DigitalObjectComponent].each do |record_class|
        @job.write_output("Trimming whitespace from #{record_class} titles")

        count = 0
        record_class.this_repo.each do |r|
          next unless r[:title] && (trimmed = r[:title].strip) != r[:title]

          count += 1
          r.update(title: trimmed)
          modified_records << r.uri
        end
        @job.write_output("#{count} records modified.")
        @job.write_output('================================')
      end
    end

    if modified_records.empty?
      @job.write_output('All done, no records modified.')
    else
      @job.write_output('All done, logging modified records.')
    end

    success!

    # just reuse JobCreated api for now...
    @job.record_created_uris(modified_records)
  rescue Exception => e
    @job.write_output(e.message)
    @job.write_output(e.backtrace)
    raise e
  end
end
