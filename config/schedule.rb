every 1.hour do
    runner "UpdateCountsJob.perform_now"
  end